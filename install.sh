#!/usr/bin/env bash
set -euo pipefail

# Antigravity Refine Skill Installer
# Usage:
#   ./install.sh [workspace|global]
#   curl -sSL https://raw.githubusercontent.com/cluelessbaj/antigravity-refine/main/install.sh | bash

MODE="${1:-workspace}"

echo "==========================================="
echo " Installing /refine skill for Antigravity  "
echo "==========================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"

install_to_workspace() {
    local target_dir="${PWD}"
    echo "Installing to workspace: ${target_dir}"

    mkdir -p "${target_dir}/.antigravity/skills"
    mkdir -p "${target_dir}/.agents/skills/refine"

    if [ -n "${SCRIPT_DIR}" ] && [ -f "${SCRIPT_DIR}/skills/refine/SKILL.md" ]; then
        cp "${SCRIPT_DIR}/skills/refine/SKILL.md" "${target_dir}/.agents/skills/refine/SKILL.md"
        cp "${SCRIPT_DIR}/.antigravity/skills/refine.md" "${target_dir}/.antigravity/skills/refine.md"
        cp "${SCRIPT_DIR}/rules/AGENTS.md" "${target_dir}/AGENTS.md"
        cp "${SCRIPT_DIR}/rules/GEMINI.md" "${target_dir}/GEMINI.md"
    else
        echo "Downloading latest skill files from GitHub..."
        local base_url="https://raw.githubusercontent.com/cluelessbaj/antigravity-refine/main"
        curl -fsSL "${base_url}/skills/refine/SKILL.md" -o "${target_dir}/.agents/skills/refine/SKILL.md"
        curl -fsSL "${base_url}/.antigravity/skills/refine.md" -o "${target_dir}/.antigravity/skills/refine.md"
        curl -fsSL "${base_url}/rules/AGENTS.md" -o "${target_dir}/AGENTS.md"
        curl -fsSL "${base_url}/rules/GEMINI.md" -o "${target_dir}/GEMINI.md"
    fi

    echo "✓ Workspace installation complete!"
    echo "  - .agents/skills/refine/SKILL.md"
    echo "  - .antigravity/skills/refine.md"
    echo "  - AGENTS.md"
    echo "  - GEMINI.md"
}

install_globally() {
    local config_dir="${HOME}/.gemini/config"
    local app_dir="${HOME}/.gemini/antigravity"
    echo "Installing globally to: ${config_dir} and ${app_dir}"

    mkdir -p "${config_dir}/plugins/refine/skills/refine"
    mkdir -p "${config_dir}/plugins/refine/rules"
    mkdir -p "${config_dir}/skills/refine"
    mkdir -p "${app_dir}/builtin/skills/refine"
    mkdir -p "${app_dir}/rules"

    if [ -n "${SCRIPT_DIR}" ] && [ -f "${SCRIPT_DIR}/skills/refine/SKILL.md" ]; then
        cp "${SCRIPT_DIR}/plugin.json" "${config_dir}/plugins/refine/plugin.json"
        cp "${SCRIPT_DIR}/skills/refine/SKILL.md" "${config_dir}/plugins/refine/skills/refine/SKILL.md"
        cp "${SCRIPT_DIR}/rules/AGENTS.md" "${config_dir}/plugins/refine/rules/AGENTS.md"
        cp "${SCRIPT_DIR}/skills/refine/SKILL.md" "${config_dir}/skills/refine/SKILL.md"
        cp "${SCRIPT_DIR}/skills/refine/SKILL.md" "${app_dir}/builtin/skills/refine/SKILL.md"
        cp "${SCRIPT_DIR}/rules/AGENTS.md" "${app_dir}/rules/refine.md"
    else
        echo "Downloading latest skill files from GitHub..."
        local base_url="https://raw.githubusercontent.com/cluelessbaj/antigravity-refine/main"
        curl -fsSL "${base_url}/plugin.json" -o "${config_dir}/plugins/refine/plugin.json"
        curl -fsSL "${base_url}/skills/refine/SKILL.md" -o "${config_dir}/plugins/refine/skills/refine/SKILL.md"
        curl -fsSL "${base_url}/rules/AGENTS.md" -o "${config_dir}/plugins/refine/rules/AGENTS.md"
        curl -fsSL "${base_url}/skills/refine/SKILL.md" -o "${config_dir}/skills/refine/SKILL.md"
        curl -fsSL "${base_url}/skills/refine/SKILL.md" -o "${app_dir}/builtin/skills/refine/SKILL.md"
        curl -fsSL "${base_url}/rules/AGENTS.md" -o "${app_dir}/rules/refine.md"
    fi

    echo "✓ Global installation complete!"
}

case "${MODE}" in
    workspace)
        install_to_workspace
        ;;
    global)
        install_globally
        ;;
    all)
        install_to_workspace
        install_globally
        ;;
    *)
        echo "Unknown mode: ${MODE}. Use 'workspace', 'global', or 'all'."
        exit 1
        ;;
esac

echo ""
echo "Done! You can now use '/refine <prompt>' or 'refine: <prompt>' in Antigravity."
