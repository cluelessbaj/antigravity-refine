# 🎯 /refine — Context-Aware Task Refinement & Planning Skill for Google Antigravity

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Antigravity](https://img.shields.io/badge/Platform-Google%20Antigravity-4285F4.svg)](https://antigravity.google)

A native skill and instruction hook for **Google Antigravity (AGY)** that intercepts rough, high-level task requests, inspects the concrete repository context—discovering exact file paths, test runners, build systems, and git status—and drafts a **hardened, deterministic execution contract** followed by an **interactive implementation plan** before touching a single line of code.

---

## ⚡ The Problem & The Solution

| The Typical Failure Mode | The `/refine` Workflow |
| :--- | :--- |
| Agent immediately jumps into editing random files based on vague prompts | **Pre-execution Hold**: Zero code edits until scope and plan are agreed upon |
| Hallucinates generic paths (`src/app.py`, `server.go`) | **Context Inspection**: Scans real workspace files, routers, and modules |
| Guesses testing commands or skips verification | **Tooling & Test Gate**: Discovers project-specific test runners (`go test ./...`, `pytest`, `npm test`, `make test`) |
| Silent, unreviewed architecture decisions | **Interactive Planning Mode**: Generates an editable `implementation_plan.md` artifact before execution |
| Unbounded scope creep | **Bounded Execution**: Modifies only what is explicitly approved in the plan |

---

## 🚀 Two-Stage Guardrail Architecture

When triggered with `/refine <prompt>` or `refine: <prompt>`:

```mermaid
flowchart TD
    A["User triggers /refine <prompt>"] --> B["Pre-Execution Hold (Zero Edits)"]
    B --> C["Context Inspection\n- Target files & modules\n- Test runners & linters\n- Git & dependency status"]
    C --> D["Generate Hardened Task Contract"]
    D --> E["Prompt: 'Generate implementation plan?'"]
    E -->|User confirms 'yes'| F["Stage 2: Generate implementation_plan.md Artifact"]
    F --> G["User Reviews & Edits Plan Artifact"]
    G --> H["Prompt: 'Reply with continue to execute'"]
    H -->|User confirms 'continue'| I["Stage 3: Execute Changes Bounded by Plan"]
    I --> J["Verification Gate (Run Tests)"]
    J --> K["Generate walkthrough.md Artifact"]
```

---

### 📋 Stage 1: The Hardened Contract Template

Every refined task produces this deterministic contract for initial alignment:

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

---

### 📝 Stage 2: Interactive Planning Phase

Once the contract is confirmed, `/refine` creates a dedicated `implementation_plan.md` artifact:
- **Component-by-Component Breakdown**: Every file change is designated as `[MODIFY]`, `[NEW]`, or `[DELETE]`.
- **Review Items & Open Questions**: Highlights breaking changes or architectural trade-offs.
- **Editable & Collaborative**: You can edit the plan document directly in Antigravity or ask the agent to tweak specific parts.
- **Continuation Gate**: Code execution only begins when you respond with `continue`, `proceed`, or `run`.

---

## 📦 Installation

### Option 1: Quick Install (One-Liner)

Install to your current project workspace:
```bash
curl -fsSL https://raw.githubusercontent.com/cluelessbaj/antigravity-refine/main/install.sh | bash
```

Or install globally across all Antigravity projects:
```bash
curl -fsSL https://raw.githubusercontent.com/cluelessbaj/antigravity-refine/main/install.sh | bash -s -- global
```

---

### Option 2: Manual Installation

#### Per-Workspace Setup
Copy the files into your repository root:
```bash
mkdir -p .agents/skills/refine .antigravity/skills
cp skills/refine/SKILL.md .agents/skills/refine/SKILL.md
cp .antigravity/skills/refine.md .antigravity/skills/refine.md
cp rules/AGENTS.md ./AGENTS.md
cp rules/GEMINI.md ./GEMINI.md
```

#### Global Setup (Antigravity Plugin)
To enable `/refine` for every workspace on your machine:

1. Clone or copy this repository into `~/.gemini/config/plugins/refine/`:
   ```bash
   git clone https://github.com/cluelessbaj/antigravity-refine.git ~/.gemini/config/plugins/refine
   ```
2. Enable it in `~/.gemini/config/config.json`:
   ```json
   {
     "plugins": {
       "refine": {
         "enabled": true
       }
     }
   }
   ```

---

## 💡 Usage

In the Antigravity chat input box, type your request using either prefix:

```text
/refine add a health check endpoint
```
or
```text
refine: implement redis caching for user profiles
```

> [!NOTE]
> **Client-Side Autocomplete Notice**: 
> Antigravity's chat UI has a client-side autocomplete menu for built-in platform shortcuts (`/goal`, `/schedule`, `/browser`, etc.). When typing `/refine`, the menu may say *"No matching results"*. **This is expected and does not block you.** Simply finish typing your prompt and press **Enter** (or press <kbd>Esc</kbd> to dismiss the popover). The agent will immediately intercept the command and run the contract workflow.

---

## 🔍 Example End-to-End Walkthrough

1. **User Request:**
   ```text
   /refine add a health check endpoint
   ```

2. **Agent Contract Output:**
   > ```markdown
   > ## Refined Task Contract: Add Health Check Endpoint to HTTP Server
   > 
   > - **Target End-State:** Expose GET /health returning {"status": "ok"}.
   > - **Target Files:**
   >   - Modify: `server.py`
   > - **Tooling & Test Gate:**
   >   - Verification command: `python3 -m py_compile server.py`
   > ```
   > *"Would you like me to generate the implementation plan for this specification?"*

3. **User:**
   ```text
   yes
   ```

4. **Agent Interactive Plan Generation:**
   > Creates `implementation_plan.md` artifact outlining architecture, exact file changes, and verification commands.
   > *"Please review the implementation plan. Reply with 'continue' or 'proceed' to execute, or describe any changes you would like to make."*

5. **User:**
   ```text
   continue
   ```

6. **Agent Bounded Execution & Verification:**
   > Executes code changes, runs the verification command, and produces `walkthrough.md`.

---

## 📄 License

[MIT](LICENSE) © [deadass@boi](https://github.com/cluelessbaj)
