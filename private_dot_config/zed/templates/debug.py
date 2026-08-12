#!/usr/bin/env python3
"""在项目根目录生成 .zed/debug.json 和 .zed/tasks.json"""
import json
import os
import shlex
import sys


WORKTREE_ROOT = "$ZED_WORKTREE_ROOT"
WORKTREE_PYTHON = "$ZED_WORKTREE_ROOT/.venv/bin/python"


def maybe_with_env(entry: dict, env: dict[str, str]) -> dict:
    if env:
        entry["env"] = env.copy()
    return entry


def make_program_debug_entry(label: str, *, program: str, program_args: list[str], env: dict[str, str]) -> dict:
    entry = {
        "label": label,
        "adapter": "Debugpy",
        "request": "launch",
        "python": WORKTREE_PYTHON,
        "program": program,
        "cwd": WORKTREE_ROOT,
        "console": "integratedTerminal",
        "justMyCode": True,
    }
    if program_args:
        entry["args"] = program_args
    return maybe_with_env(entry, env)


def make_debug_entry(label: str, *, module: str, module_args: list[str], env: dict[str, str]) -> dict:
    entry = {
        "label": label,
        "adapter": "Debugpy",
        "request": "launch",
        "python": WORKTREE_PYTHON,
        "module": module,
        "cwd": WORKTREE_ROOT,
        "console": "integratedTerminal",
        "justMyCode": True,
    }
    if module_args:
        entry["args"] = module_args
    return maybe_with_env(entry, env)


def make_task_entry(label: str, *, module: str, module_args: list[str], env: dict[str, str]) -> dict:
    entry = {
        "label": label,
        "command": WORKTREE_PYTHON,
        "args": ["-m", module, *module_args],
        "cwd": WORKTREE_ROOT,
        "use_new_terminal": False,
        "allow_concurrent_runs": False,
        "reveal": "always",
        "reveal_target": "dock",
        "hide": "never",
        "shell": "system",
    }
    return maybe_with_env(entry, env)


def make_file_task_entry(label: str, *, file_args: list[str], env: dict[str, str]) -> dict:
    entry = {
        "label": label,
        "command": WORKTREE_PYTHON,
        "args": ["$ZED_RELATIVE_FILE", *file_args],
        "cwd": WORKTREE_ROOT,
        "use_new_terminal": False,
        "allow_concurrent_runs": False,
        "reveal": "always",
        "reveal_target": "dock",
        "hide": "never",
        "shell": "system",
    }
    return maybe_with_env(entry, env)


def parse_run_args(raw_args: str) -> list[str]:
    if not raw_args.strip():
        return []
    try:
        return shlex.split(raw_args)
    except ValueError as exc:
        raise SystemExit(f"Invalid run args: {exc}") from exc


def parse_env_assignments(raw_env: str) -> dict[str, str]:
    if not raw_env.strip():
        return {}

    try:
        tokens = shlex.split(raw_env)
    except ValueError as exc:
        raise SystemExit(f"Invalid environment variables: {exc}") from exc

    env = {}
    for token in tokens:
        if "=" not in token:
            raise SystemExit(
                f"Invalid environment variable '{token}': expected KEY=VALUE"
            )

        key, value = token.split("=", 1)
        if not key:
            raise SystemExit(
                f"Invalid environment variable '{token}': key must not be empty"
            )
        if key in env:
            raise SystemExit(
                f"Invalid environment variable '{token}': duplicate key '{key}'"
            )
        env[key] = value

    return env


def open_prompt_streams():
    try:
        prompt_in = open("/dev/tty", "r", encoding="utf-8")
        prompt_out = open("/dev/tty", "w", encoding="utf-8", buffering=1)
        return prompt_in, prompt_out
    except OSError:
        return sys.stdin, sys.stdout


def close_prompt_streams(prompt_in, prompt_out) -> None:
    for stream, std_stream in ((prompt_in, sys.stdin), (prompt_out, sys.stdout)):
        if stream is not std_stream:
            stream.close()


def prompt_value(
    prompt_in,
    prompt_out,
    prompt_text: str,
    *,
    default: str | None = None,
) -> str:
    prompt_out.write(prompt_text)
    prompt_out.flush()

    line = prompt_in.readline()
    if line == "":
        raise SystemExit("Prompt input closed")

    value = line.rstrip("\r\n")
    if value:
        return value
    if default is not None:
        return default
    return ""


def prompt_yes_no(prompt_in, prompt_out, prompt_text: str, *, default: bool = False) -> bool:
    default_text = "Y/n" if default else "y/N"

    while True:
        value = prompt_value(
            prompt_in,
            prompt_out,
            f"{prompt_text} [{default_text}]: ",
        ).strip().lower()
        if not value:
            return default
        if value in {"y", "yes"}:
            return True
        if value in {"n", "no"}:
            return False
        prompt_out.write("Please answer y or n.\n")
        prompt_out.flush()


def main():
    prompt_in, prompt_out = open_prompt_streams()
    try:
        module = prompt_value(
            prompt_in,
            prompt_out,
            "Python module path (e.g. my_app.main) [app.main]: ",
            default="app.main",
        )
        fastapi_module = module
        if prompt_yes_no(prompt_in, prompt_out, "Override FastAPI module?", default=False):
            fastapi_module = prompt_value(
                prompt_in,
                prompt_out,
                f"FastAPI module path [{module}]: ",
                default=module,
            )
        port = prompt_value(
            prompt_in,
            prompt_out,
            "Port [8000]: ",
            default="8000",
        )
        run_args = parse_run_args(
            prompt_value(
                prompt_in,
                prompt_out,
                "Run args (leave blank for none): ",
            )
        )
        env = parse_env_assignments(
            prompt_value(
                prompt_in,
                prompt_out,
                "Environment variables (shell-style KEY=VALUE, quote values with spaces, leave blank for none): ",
            )
        )
    finally:
        close_prompt_streams(prompt_in, prompt_out)

    pkg = module.split(".")[0]
    fastapi_pkg = fastapi_module.split(".")[0]
    fastapi_args = [f"{fastapi_module}:app", "--host", "127.0.0.1", "--port", port, "--reload"]

    debug = [
        make_program_debug_entry(
            "Python: Current File (uv, project env)",
            program="$ZED_RELATIVE_FILE",
            program_args=[],
            env=env,
        ),
        make_debug_entry(
            "Pytest: Current File (uv, project env)",
            module="pytest",
            module_args=["$ZED_RELATIVE_FILE", "-q"],
            env=env,
        ),
        make_debug_entry(
            f"Python: Module ({pkg})",
            module=module,
            module_args=[],
            env=env,
        ),
        make_debug_entry(
            f"FastAPI: uvicorn ({fastapi_pkg})",
            module="uvicorn",
            module_args=fastapi_args,
            env=env,
        ),
    ]

    tasks = [
        make_file_task_entry(
            "Python: Run Current File (uv, project env)",
            file_args=[],
            env=env,
        ),
        make_task_entry(
            "Pytest: Current File (uv, project env)",
            module="pytest",
            module_args=["$ZED_RELATIVE_FILE", "-q"],
            env=env,
        ),
        make_task_entry(
            f"FastAPI: Uvicorn ({fastapi_pkg})",
            module="uvicorn",
            module_args=fastapi_args,
            env=env,
        ),
    ]

    if run_args:
        debug.append(
            make_debug_entry(
                f"Python: Module with Args ({pkg})",
                module=module,
                module_args=run_args,
                env=env,
            )
        )
        tasks.append(
            make_task_entry(
                f"Python: Run Module with Args ({pkg})",
                module=module,
                module_args=run_args,
                env=env,
            )
        )

    zed_dir = os.path.join(os.getcwd(), ".zed")
    os.makedirs(zed_dir, exist_ok=True)

    debug_path = os.path.join(zed_dir, "debug.json")
    with open(debug_path, "w", encoding="utf-8") as f:
        json.dump(debug, f, indent=2)
        f.write("\n")
    print(f"Created {debug_path}")

    tasks_path = os.path.join(zed_dir, "tasks.json")
    with open(tasks_path, "w", encoding="utf-8") as f:
        json.dump(tasks, f, indent=2)
        f.write("\n")
    print(f"Created {tasks_path}")


if __name__ == "__main__":
    main()
