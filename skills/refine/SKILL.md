---
name: refine
description: Intercepts rough task descriptions (/refine <prompt> or refine: <prompt>), inspects repository context, drafts a hardened contract, and offers a flexible choice between immediate bounded execution or generating an interactive implementation plan for review. Fully cross-platform across Linux, macOS, and Windows.
---

# /refine — Context-Aware Task Refinement & Flexible Execution Skill

## Overview
The `/refine` skill intercepts ambiguous or rough task requests, grounds them in the concrete reality of the current workspace, and generates a deterministic, project-specific execution contract. It acts as a safety gate to ensure zero premature code modifications occur, while offering the user a **choice between immediate bounded execution or an interactive planning review**.

## Triggers
Activate this skill whenever user input starts with:
- `/refine <prompt>`
- `refine: <prompt>`

---

## Mandatory Execution Workflow

When `/refine` is invoked, **DO NOT** execute any code edits or file modifications immediately. Follow this strict workflow:

### Stage 1: Contract Refinement & Pre-Execution Hold
1. **Pre-Execution Hold:**
   - Strictly prohibit any immediate code modifications, file creation, or destructive terminal commands.
2. **Context Inspection & Host OS Detection:**
   - Detect host operating system (Linux, macOS, or Windows).
   - Scan the codebase using `find_by_name`, `grep_search`, `list_dir`, and `view_file`.
   - Locate the exact files, modules, and directories directly relevant to the user's rough goal.
   - **Cross-Platform Path Resolution:**
     - On Windows: Format target paths using native backslashes (`\`) and drive letters if absolute, or relative paths (`dir\file.ext`).
     - On Linux/macOS: Format target paths using forward slashes (`/`).
   - **Tooling Discovery:** Detect active build tools and test runners for the platform:
     - Windows: `dotnet test`, `powershell -Command ...`, `mvn.cmd test`, `.\gradlew.bat test`, `python -m pytest`
     - Cross-Platform / Unix: `go test ./...`, `pytest`, `npm test`, `cargo test`, `make test`
   - Check git status (`git status -s`) and identify untouchable files (locks, configs, unrelated code).
3. **Draft Hardened Contract:**
   Output the deterministic specification matching this exact structure:

   ```markdown
   ## Refined Task Contract: [Concise Feature/Fix Name]

   - **Target End-State:** [Measurable deliverable tailored to this repo]
   - **Target Files:**
     - Modify: `[explicit paths to existing files formatted for host OS]`
     - Create: `[explicit paths if new files are needed]`
     - Read-Only / Untouchable: `[configs, locks, dependencies, unrelated modules]`
   - **Tooling & Test Gate:**
     - Verification command: `[exact test/lint command found in the project]`
     - Expected result: Exit code 0, 0 test failures.
   - **Pre-flight Dependencies:** [Required environment variables, services, or ports]
   ```

4. **Awaiting User Decision (Execution Choice):**
   Output the choice prompt:
   > **How would you like to proceed?**
   > - **Direct Execution:** Reply `run`, `execute`, or `yes` to apply changes directly bounded by this contract.
   > - **Interactive Planning:** Reply `plan` to generate a detailed `implementation_plan.md` artifact for review first.
   > - Or reply with any adjustments you'd like to make to the contract.
   - Halt execution and await explicit user input.

---

### Stage 2: Interactive Planning Phase (Optional)
If the user replies `plan`:
1. **Create Implementation Plan Artifact:**
   - Write or update `implementation_plan.md` in the artifact directory (`UserFacing: true`, `RequestFeedback: true`).
   - Structure the plan with:
     - **Goal Description**: Clear summary of what will be accomplished.
     - **User Review Required**: Any critical design decisions or breaking changes.
     - **Proposed Changes**: Ordered components, file-by-file breakdown (`[MODIFY]`, `[NEW]`, `[DELETE]`) with exact paths.
     - **Verification Plan**: Automated test commands and manual verification steps.
2. **User Inspection & Edits:**
   - Direct the user to review the generated implementation plan artifact.
   - Output: `"Please review the implementation plan. Reply with 'continue' or 'proceed' to execute, or describe any changes you would like to make."`
   - Halt execution until explicit continuation prompt (`continue`, `proceed`, `run`) is received.

---

### Stage 3: Bounded Execution & Verification Gate
Triggered either directly from Stage 1 (`run` / `execute` / `yes`) or after Stage 2 approval (`continue` / `proceed`):
1. **Execute Changes:**
   - Perform code modifications strictly bounded by the agreed contract or plan.
2. **Run Test Gate:**
   - Execute the verification command defined in the contract.
   - Ensure exit code 0 and zero test failures.
3. **Create Walkthrough Artifact:**
   - Document all changes, test commands run, and validation results in `walkthrough.md`.
