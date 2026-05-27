---
name: git-atomic-commit
description: >
  Handles atomic git commits with appropriate icons and pushes changes 
  after task completion and user approval.
---

# Git Atomic Commit Skill

This skill automates the process of committing and pushing changes once a task has been completed and approved by the user. It ensures that commit messages follow a consistent format with descriptive icons.

## Trigger Conditions

Use this skill when:
1. You have completed an implementation task (T-XXX).
2. You have updated the corresponding summary report and task breakdown as per the `task-completion-reporting` skill.
3. You are ready to finalize the work in the repository.

## Workflow

### 1. Request Approval
Before committing, you MUST ask the user for explicit approval in your response:
> "The implementation of **{Task ID} — {Task Title}** is complete and the summary report has been generated. Is this work approved for atomic commit and push?"

### 2. Identify Changes
Identify all files modified or created as part of the specific task. Use `git add` to stage only these files (atomic commit).

### 3. Generate Commit Message
The commit message should follow this format:
`{icon} {type}: {Task ID} - {short-description}`

#### Icon Mapping:
- ✨ `:sparkles:` - New features / functionality (feat)
- 🐛 `:bug:` - Bug fixes (fix)
- 📝 `:memo:` - Documentation changes (docs)
- 🎨 `:art:` - UI/UX, styling, or aesthetic improvements (style)
- ♻️ `:recycle:` - Refactorings (refactor)
- ⚡️ `:zap:` - Performance improvements (perf)
- ✅ `:white_check_mark:` - Adding or updating tests (test)
- 🔧 `:wrench:` - Configuration or infrastructure changes (chore)

### 4. Execute Git Operations
Once approved:
1. `git add <task-files>`
2. `git commit -m "<formatted-message>"`
3. `git push`

## Integration with @/implement-carefully
When following the `implement-carefully` workflow, ensure that the "careful" mindset extends to the commit process:
- Verify that the commit message accurately reflects the careful implementation.
- Ensure only relevant files are included in the atomic commit.
