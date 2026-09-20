# Workspace Instructions

## Command Interception: `/refine`

Intercept any user input beginning with `/refine <prompt>` or `refine: <prompt>`.

When this command is triggered:
1. **Pre-execution Hold (Strict Zero Modifications):**
   - Under no circumstances make code modifications, create new files, or apply edits immediately.
2. **Context Inspection:**
   - Scan the codebase to identify exact relevant files, modules, and directory structures.
   - Detect the configured test runners, linters, and build tools (e.g. `Makefile`, `package.json`, `go test ./...`, `pytest`, `python3 -m unittest`, etc.).
   - Check workspace status and identify read-only or untouchable files (e.g., config, dependencies, lock files).
3. **Hardened Contract Output:**
   - Output the deterministic contract matching this exact structure:

   ```markdown
   ## Refined Task Contract: [Concise Feature/Fix Name]

   - **Target End-State:** [Measurable deliverable tailored to this repo]
   - **Target Files:**
     - Modify: `[explicit paths to existing files]`
     - Create: `[explicit paths if new files are needed]`
     - Read-Only / Untouchable: `[configs, locks, dependencies, unrelated modules]`
   - **Tooling & Test Gate:**
     - Verification command: `[exact test/lint command found in the project]`
     - Expected result: Exit code 0, 0 test failures.
   - **Pre-flight Dependencies:** [Required environment variables, services, or ports]
   ```

4. **Awaiting Contract Approval:**
   - Output: `"Would you like me to generate the implementation plan for this specification?"`
   - Halt execution and await explicit user confirmation (`yes`, `run`, `proceed`).

5. **Interactive Planning Phase (Upon Approval):**
   - Create or update the `implementation_plan.md` artifact (`UserFacing: true, RequestFeedback: true`).
   - Present the plan artifact for user review without modifying source files.
   - Output: `"Please review the implementation plan. Reply with 'continue' or 'proceed' to execute, or describe any changes you would like to make."`
   - Halt execution until explicit continuation prompt is received.

6. **Bounded Execution & Verification:**
   - Apply edits strictly as defined in the approved plan.
   - Run the verification gate command.
   - Document results in a `walkthrough.md` artifact.
