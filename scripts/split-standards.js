import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const workspaceRoot = path.resolve(__dirname, '..');

const CATEGORY_MAP = {
  'Authentication & Sessions': 'auth',
  'Security':                  'security',
  'Environment Variables':     'env',
  'Routing':                   'routing',
  'Middleware':                'middleware',
  'Forms':                     'forms',
  'Database':                  'database',
  'Error Handling':            'error-handling',
  'HTTP Headers & Caching':    'headers-caching',
  'Build & Tooling':           'build-tooling',
  'SSR & Streaming':           'ssr-streaming',
  'UI & Components':           'ui-components',
  'Real-Time':                 'real-time',
};

const HONO_FILE_MAP = {
  'api.md':        'api',
  'db.md':         'database',
  'auth.md':       'auth',
  'middleware.md': 'middleware',
  'testing.md':    'testing',
  'cloudflare.md': 'cloudflare',
};

// Parse command line arguments
const isDryRun = process.argv.includes('--dry-run');

function getSlug(title) {
  let part = title.split(/[—–:\(]/)[0].trim();
  if (part.length <= 4) {
    part = title.split(/\(/)[0].trim();
  }
  return part
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

function cleanBody(lines) {
  let body = lines.join('\n').trim();
  body = body.replace(/^(?:\s*---\s*\n+)+/, '');
  body = body.replace(/(?:\n+\s*---\s*)+$/, '');
  return body.trim();
}

function parseFile(filePath, isHono) {
  const fileContent = fs.readFileSync(filePath, 'utf-8');
  const fileLines = fileContent.split(/\r?\n/);
  
  const rules = [];
  let currentCategory = isHono ? HONO_FILE_MAP[path.basename(filePath)] : null;
  let currentRuleTitle = null;
  let currentRuleBodyLines = [];
  
  for (const line of fileLines) {
    if (line.match(/^##\s+Flagged/i)) {
      break; // Hard stop at flagged section
    }
    
    // Check for category heading (Remix only)
    if (!isHono) {
      const catMatch = line.match(/^##\s+(.+)$/);
      if (catMatch) {
        if (currentRuleTitle) {
          rules.push({
            category: currentCategory,
            title: currentRuleTitle,
            body: cleanBody(currentRuleBodyLines),
          });
          currentRuleTitle = null;
          currentRuleBodyLines = [];
        }
        const parsedCatName = catMatch[1].trim();
        currentCategory = CATEGORY_MAP[parsedCatName] || null;
        continue;
      }
    } else {
      // Hono has ## Rules and ## Flagged. Ignore all other ## headings.
      if (line.match(/^##\s+/)) {
        continue;
      }
    }
    
    // Check for rule heading
    const ruleMatch = line.match(/^###\s+(.+)$/);
    if (ruleMatch) {
      if (currentRuleTitle) {
        rules.push({
          category: currentCategory,
          title: currentRuleTitle,
          body: cleanBody(currentRuleBodyLines),
        });
      }
      currentRuleTitle = ruleMatch[1].trim();
      currentRuleBodyLines = [];
      continue;
    }
    
    if (currentRuleTitle !== null) {
      currentRuleBodyLines.push(line);
    }
  }
  
  // Save last rule
  if (currentRuleTitle) {
    rules.push({
      category: currentCategory,
      title: currentRuleTitle,
      body: cleanBody(currentRuleBodyLines),
    });
  }
  
  return rules;
}

function main() {
  const allParsedRules = [];
  
  // 1. Parse Remix
  const remixPath = path.join(workspaceRoot, 'saas-template', 'unified-standards-remix.md');
  console.log(`Parsing Remix standards: ${remixPath}`);
  const remixRules = parseFile(remixPath, false);
  for (const rule of remixRules) {
    allParsedRules.push({ ...rule, source: 'remix' });
  }
  
  // 2. Parse Hono
  const honoDir = path.join(workspaceRoot, 'saas-template', 'unified-hono');
  console.log(`Scanning Hono standards directory: ${honoDir}`);
  const honoFiles = fs.readdirSync(honoDir).filter(f => HONO_FILE_MAP[f]);
  for (const file of honoFiles) {
    const honoFilePath = path.join(honoDir, file);
    console.log(`Parsing Hono standards: ${honoFilePath}`);
    const honoRules = parseFile(honoFilePath, true);
    for (const rule of honoRules) {
      allParsedRules.push({ ...rule, source: 'hono' });
    }
  }
  
  // 3. Process and write (or dry run)
  const registry = new Map(); // category -> Set(slugs)
  const finalCategories = {};
  
  for (const rule of allParsedRules) {
    if (rule.title === 'LLM Markdown Meta Tag') {
      continue;
    }
    if (!rule.category) {
      console.warn(`Warning: Rule "${rule.title}" has no category. Skipping.`);
      continue;
    }
    
    const slug = getSlug(rule.title);
    if (!registry.has(rule.category)) {
      registry.set(rule.category, new Map());
      finalCategories[rule.category] = [];
    }
    
    const categoryRegistry = registry.get(rule.category);
    let finalSlug = slug;
    
    if (categoryRegistry.has(finalSlug)) {
      const existing = categoryRegistry.get(finalSlug);
      if (existing.source !== rule.source) {
        // Source collision, append source
        finalSlug = `${slug}-${rule.source}`;
        // Also update existing if needed (already written, but we should distinguish)
        // Note: For Remix first, the first one was already added as `slug`. We can keep it or rename it.
        // To be safe, the second one gets suffix. If both exist, they are differentiated.
      } else {
        // Same source collision, append counter
        let counter = 1;
        while (categoryRegistry.has(`${slug}-${counter}`)) {
          counter++;
        }
        finalSlug = `${slug}-${counter}`;
      }
    }
    
    categoryRegistry.set(finalSlug, rule);
    
    finalCategories[rule.category].push({
      slug: finalSlug,
      title: rule.title,
      source: rule.source,
      body: rule.body,
    });
  }
  
  // Sort categories and rules alphabetically
  const sortedCategories = Object.keys(finalCategories).sort();
  
  if (isDryRun) {
    console.log('\n=== DRY RUN RESULTS ===\n');
    console.log('Category'.padEnd(20) + 'Rules'.padEnd(10) + 'Source Breakdown');
    console.log('─'.repeat(55));
    
    let grandTotal = 0;
    for (const cat of sortedCategories) {
      const rules = finalCategories[cat];
      const remixCount = rules.filter(r => r.source === 'remix').length;
      const honoCount = rules.filter(r => r.source === 'hono').length;
      console.log(`${cat.padEnd(20)}${String(rules.length).padEnd(10)}remix: ${remixCount} | hono: ${honoCount}`);
      grandTotal += rules.length;
    }
    console.log('─'.repeat(55));
    console.log(`TOTAL`.padEnd(20) + `${grandTotal}`.padEnd(10));
    
    console.log('\nDetail Slugs List:');
    for (const cat of sortedCategories) {
      console.log(`\n[${cat}]`);
      for (const rule of finalCategories[cat]) {
        console.log(`  - ${rule.slug} (${rule.source}) -> "${rule.title}"`);
      }
    }
    return;
  }
  
  // Write actual files
  const outputDir = path.join(workspaceRoot, 'profiles', 'remix-hono', 'standards');
  fs.mkdirSync(outputDir, { recursive: true });
  
  console.log(`\nWriting standards to: ${outputDir}`);
  
  for (const cat of sortedCategories) {
    const catDir = path.join(outputDir, cat);
    fs.mkdirSync(catDir, { recursive: true });
    
    // Sort rules alphabetically by slug within category
    finalCategories[cat].sort((a, b) => a.slug.localeCompare(b.slug));
    
    for (const rule of finalCategories[cat]) {
      const filePath = path.join(catDir, `${rule.slug}.md`);
      const fileContent = `---
source: ${rule.source}
category: ${cat}
---
# ${rule.title}

${rule.body}
`;
      fs.writeFileSync(filePath, fileContent, 'utf-8');
    }
  }
  
  // Generate index.yml
  let yamlContent = `# Auto-generated by scripts/split-standards.js
version: 1
profile: remix-hono
categories:
`;
  
  for (const cat of sortedCategories) {
    yamlContent += `  ${cat}:\n`;
    for (const rule of finalCategories[cat]) {
      yamlContent += `    - slug: ${rule.slug}\n`;
      // Escape double quotes in title
      const escapedTitle = rule.title.replace(/"/g, '\\"');
      yamlContent += `      title: "${escapedTitle}"\n`;
      yamlContent += `      source: ${rule.source}\n`;
    }
  }
  
  const yamlPath = path.join(outputDir, 'index.yml');
  fs.writeFileSync(yamlPath, yamlContent, 'utf-8');
  console.log(`Generated master catalog index: ${yamlPath}`);
  console.log('Splitting successfully completed!');
}

main();
