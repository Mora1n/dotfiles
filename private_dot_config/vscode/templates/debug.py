#!/usr/bin/env python3
"""在项目根目录生成 .vscode/launch.json 和 .vscode/tasks.json"""
import argparse
import json
import os
import re
import sys


def merge_launch(path, new_configs):
    if os.path.exists(path):
        with open(path) as f:
            data = json.load(f)
    else:
        data = {"version": "0.2.0", "configurations": []}

    existing = {c["name"] for c in data.get("configurations", [])}
    added = 0
    for cfg in new_configs:
        if cfg["name"] not in existing:
            data.setdefault("configurations", []).append(cfg)
            existing.add(cfg["name"])
            added += 1

    with open(path, "w") as f:
        json.dump(data, f, indent=4)
        f.write("\n")
    return added


def merge_tasks(path, new_tasks):
    if os.path.exists(path):
        with open(path) as f:
            data = json.load(f)
    else:
        data = {"version": "2.0.0", "tasks": []}

    existing = {t["label"] for t in data.get("tasks", [])}
    added = 0
    for task in new_tasks:
        if task["label"] not in existing:
            data.setdefault("tasks", []).append(task)
            existing.add(task["label"])
            added += 1

    with open(path, "w") as f:
        json.dump(data, f, indent=4)
        f.write("\n")
    return added


def main():
    parser = argparse.ArgumentParser(description="Generate VS Code Python debug/task configs")
    parser.add_argument("--module", required=True, help="Python module path (e.g. app.main)")
    parser.add_argument("--port", default="8000", help="Port for uvicorn (default: 8000)")
    parser.add_argument("--with-args", default="no", choices=["yes", "no"], help="Add Module with Args config")
    args = parser.parse_args()

    module = args.module.strip()
    if not re.fullmatch(r"[a-zA-Z_]\w*(\.[a-zA-Z_]\w*)*", module):
        print(f"Invalid module path: '{module}'")
        sys.exit(1)

    pkg = module.split(".")[0]
    port = args.port
    has_args = args.with_args == "yes"

    debug = [
        {
            "name": f"Python: Module ({pkg})",
            "type": "debugpy",
            "request": "launch",
            "module": module,
            "cwd": "${workspaceFolder}",
            "console": "integratedTerminal",
            "justMyCode": True,
        },
        {
            "name": f"FastAPI: uvicorn ({pkg})",
            "type": "debugpy",
            "request": "launch",
            "module": "uvicorn",
            "args": [f"{module}:app", "--host", "127.0.0.1", "--port", port, "--reload"],
            "cwd": "${workspaceFolder}",
            "console": "integratedTerminal",
            "justMyCode": True,
        },
    ]

    tasks = [
        {
            "label": f"FastAPI: Uvicorn ({pkg})",
            "type": "shell",
            "command": "${workspaceFolder}/.venv/bin/python",
            "args": ["-m", "uvicorn", f"{module}:app", "--host", "127.0.0.1", "--port", port, "--reload"],
            "options": {"cwd": "${workspaceFolder}"},
            "presentation": {"reveal": "always", "panel": "shared"},
            "problemMatcher": [],
        },
    ]

    if has_args:
        debug.append({
            "name": f"Python: Module with Args ({pkg}, edit args)",
            "type": "debugpy",
            "request": "launch",
            "module": module,
            "args": ["--example", "value"],
            "cwd": "${workspaceFolder}",
            "console": "integratedTerminal",
            "justMyCode": True,
        })
        tasks.append({
            "label": f"Python: Run Module with Args ({pkg}, edit args)",
            "type": "shell",
            "command": "${workspaceFolder}/.venv/bin/python",
            "args": ["-m", module, "--example", "value"],
            "options": {"cwd": "${workspaceFolder}"},
            "presentation": {"reveal": "always", "panel": "shared"},
            "problemMatcher": [],
        })

    vscode_dir = os.path.join(os.getcwd(), ".vscode")
    os.makedirs(vscode_dir, exist_ok=True)

    launch_path = os.path.join(vscode_dir, "launch.json")
    added_launch = merge_launch(launch_path, debug)
    print(f"launch.json: {added_launch} config(s) added")

    tasks_path = os.path.join(vscode_dir, "tasks.json")
    added_tasks = merge_tasks(tasks_path, tasks)
    print(f"tasks.json: {added_tasks} task(s) added")


if __name__ == "__main__":
    main()
