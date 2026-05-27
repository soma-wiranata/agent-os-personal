---
name: task-completion-reporting
description: Use when completing a task or implementation topic to ensure consistent reporting across the progress dashboard and task history.
---

# Task Completion Reporting

## Overview
Every time an agent completes work in the Japanese Learning App project, it MUST follow this reporting standard to ensure consistency across the progress dashboard and task history.

## When to Use
Use this skill at the end of every implementation task or non-task implementation to:
- Generate a summary report.
- Update task status in the master breakdown.
- Synchronize the progress dashboard.
- Provide a final walkthrough to the user.

if this was used on fresh session/chat, use git to figure out what are the current unstaged changes, read those file for context of what to write

## Workflow

### 1. Create Summary Report
Generate a detailed markdown report for the specific task or implementation topic.

- **Path (Task):** `docs/reports/summary/{YYYYMMDD_HHMMSS}_{TASK_ID}_{short-description}.md`
- **Path (Non-Task Implementation):** `docs/reports/summary/{YYYYMMDD_HHMMSS}_{implementation-topic}.md`

- **Content Template:**
  The report MUST contain the following sections at minimum:

  ```markdown
  # Summary: {Task ID} — {Task Title}
  (OR # Summary: {Implementation Topic} if no Task ID)

  **Timestamp:** {YYYYMMDD_HHMMSS}
  **Status:** Completed | Blocked | Partially Complete

  ## What was done
  (Brief description of what was executed)

  ## Approach taken
  (What method was used — and if it differs from the PRD suggestion, why)

  ## Outputs produced
  (List of files created or modified, with paths)

  ## Deviations from PRD
  (Any decision that differs from the Phase PRDs — including acceptable ones)

  ## Blockers or open questions
  (Anything that was left unresolved or requires follow-up)

  ## Notes for next tasks
  (Anything a downstream task should know — data shape quirks, naming conventions chosen, etc.)
  ```

### 2. Update Master Task Breakdown
If the work is part of a specific task ID (T-XXX), mark the task as completed in the corresponding task breakdown file.
- **Path:** `prd/phase-X/phase-X-task-breakdown.md`
- **Action:** Change the task header to include `[x]` (e.g., `### [x] T-014 — ...`).

### 3. Update Progress Dashboard
Synchronize the global progress overview if applicable.
- **Path:** `docs/reports/phase-X-progress.md`
- **Actions:**
  - **Stats:** Increment the `Completed` count in the metadata section.
  - **Group Summary:** Update the `Done / Total` count for the relevant group.
  - **Main Table:** Update the task row's status to `✅` and add the relative link to the summary report.
  - **Timestamp:** Update the `Last Updated` date to today's date.

### 4. Final Walkthrough
Provide the user with a concise summary of the work, highlighting any new UI features or important technical changes.