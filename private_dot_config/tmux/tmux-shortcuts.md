# Tmux 快捷键速查表

> 基于 `~/.config/tmux/tmux.conf`、tmux 3.6 和当前有效按键表。

## 前缀键

| 按键 | 功能 |
|---|---|
| `Alt-t` | 主前缀 |
| `Ctrl-\` | 次前缀 |
| `prefix + Alt-t` | 向内部程序发送主前缀 |
| `prefix + Ctrl-\` | 向内部程序发送次前缀 |

## Session 管理

| 快捷键 | 功能 |
|---|---|
| `prefix + a` | 打开原生 session tree 和布局预览 |
| `prefix + s` | 使用 sesh 创建或切换到当前 Git 根目录 session |
| `prefix + S` | 使用 fzf 选择并删除 session |
| `prefix + Backspace` | 切换到上一个使用的 session |
| `prefix + (` | 上一个 session |
| `prefix + )` | 下一个 session |
| `prefix + $` | 重命名当前 session |
| `prefix + d` | 分离当前客户端 |
| `prefix + Ctrl-s` | 使用 Resurrect 保存 session |
| `prefix + Ctrl-r` | 使用 Resurrect 恢复 session |

### 原生 tree 模式

`prefix + a` 和 `prefix + w` 进入 tmux 原生 tree 模式：

| 模式内按键 | 功能 |
|---|---|
| `Enter` | 切换到选中的 session、window 或 pane |
| `+` / `-` | 展开或折叠当前项目 |
| `Alt-+` / `Alt--` | 展开或折叠全部项目 |
| `x` | 删除选中项目并要求确认 |
| `t` | 标记或取消标记项目 |
| `X` | 删除所有已标记项目 |
| `Ctrl-s` | 按名称搜索 |
| `n` / `N` | 下一个或上一个搜索结果 |
| `O` | 更换排序字段 |
| `r` | 反转排序 |
| `v` | 显示或隐藏布局预览 |
| `q` | 退出 tree 模式 |

## Window 管理

| 快捷键 | 功能 |
|---|---|
| `prefix + c` | 在当前 pane 目录创建 window |
| `prefix + n` / `prefix + Ctrl-n` | 下一个 window |
| `prefix + p` | 上一个 window |
| `prefix + Tab` | 切换到上一个使用的 window |
| `prefix + 1..9` | 切换到指定编号的 window |
| `prefix + w` | 打开原生 window tree 和布局预览 |
| `prefix + f` | 按名称查找 window |
| `prefix + ,` | 重命名当前 window |
| `prefix + &` | 删除当前 window并要求确认 |
| `prefix + W` | 使用 fzf 选择并删除 window |
| `prefix + <` / `prefix + >` | 向左或向右移动当前 window，可重复 |

Window 从 `1` 开始编号，删除后自动重新编号。

## Pane 管理

### 创建与关闭

| 快捷键 | 功能 |
|---|---|
| `prefix + \|` / `prefix + %` | 在右侧创建 pane，继承当前目录 |
| `prefix + \` | 在左侧创建 pane，继承当前目录 |
| `prefix + -` / `prefix + "` | 在下方创建 pane，继承当前目录 |
| `prefix + _` | 在上方创建 pane，继承当前目录 |
| `prefix + x` | 删除 pane并要求确认 |
| `prefix + !` | 将当前 pane 分离成 window |

### 导航与布局

| 快捷键 | 功能 |
|---|---|
| `prefix + h/j/k/l` | 向左/下/上/右切换 pane |
| `prefix + Ctrl-h/j/k/l` | 向左/下/上/右切换 pane |
| `prefix + o` | 循环切换 pane |
| `prefix + ;` | 切换到上一个使用的 pane |
| `prefix + q` | 显示 pane 编号 |
| `prefix + z` | 最大化或还原当前 pane |
| `prefix + Space` | 循环切换预设布局 |
| `prefix + {` / `prefix + }` | 与上一个或下一个 pane 交换 |
| `prefix + =` | 切换当前 window 的同步输入 |

### 调整大小

| 快捷键 | 功能 |
|---|---|
| `prefix + H` | 向左调整 5 cells，可重复 |
| `prefix + J` | 向下调整 5 cells，可重复 |
| `prefix + K` | 向上调整 5 cells，可重复 |
| `prefix + L` | 向右调整 5 cells，可重复 |

Pane 从 `1` 开始编号。

## Extrakto：提取文本、路径和 URL

`prefix + u` 从当前 window 所有 pane 的最近 500 行中提取内容；`prefix + y` 直接进入完整行过滤模式。

| 快捷键 | 功能 |
|---|---|
| `prefix + u` | 打开全部过滤器，匹配 URL、路径、文本和完整行 |
| `prefix + y` | 直接按完整行提取 |
| `prefix + Y` | 直接复制当前 pane 工作目录 |
| `Enter` | 将选中内容复制到系统剪贴板和 tmux buffer |
| `Tab` | 将选中内容插入当前 pane |
| `Ctrl-o` | 使用 `xdg-open` 打开选中内容 |
| `Ctrl-e` | 使用 Neovim 编辑选中路径 |
| `Ctrl-f` | 切换 all/url/path/line/word 过滤器 |
| `Ctrl-g` | 切换抓取范围 |
| `Ctrl-t` | 切换系统剪贴板和 tmux buffer 模式 |
| `Ctrl-l` | 显示 Extrakto 帮助 |
| `Escape` / `Ctrl-c` | 退出 Extrakto |

## Copy mode 与剪贴板

| 快捷键 | 功能 |
|---|---|
| `prefix + v` / `prefix + [` | 进入 copy mode |
| `v` | 开始选择 |
| `V` | 选择整行 |
| `Ctrl-v` | 切换矩形选择 |
| `y` | 复制到 X11 clipboard，并保持 copy mode |
| `Enter` | 复制到 X11 clipboard，并保持 copy mode |
| `!` | 去除换行后复制 |
| `q` | 退出 copy mode |
| `Escape` | 清除选择 |
| `h/j/k/l` | 移动光标 |
| `g` / `G` | 跳到顶部或底部 |
| `/` / `?` | 向下或向上搜索 |
| `n` / `N` | 下一个或上一个匹配 |
| `Ctrl-u` / `Ctrl-d` | 向上或向下半页 |
| `Ctrl-b` / `Ctrl-f` | 向上或向下整页 |
| 鼠标拖拽 | 选择并复制到 X11 clipboard |
| 双击 / 三击 | 复制单词或整行，并保持 viewport 位置 |

其他剪贴板操作：

| 快捷键 | 功能 |
|---|---|
| `prefix + P` | 选择 tmux paste buffer |
| `prefix + ]` | 粘贴 tmux buffer |
| `prefix + Ctrl-c` | 将 tmux buffer 写入系统剪贴板 |
| `prefix + Ctrl-v` | 从系统剪贴板读取并粘贴 |

## Popup 与实用工具

| 快捷键 | 功能 |
|---|---|
| `prefix + Ctrl-p` | 在当前目录打开 80% shell popup |
| `prefix + B` | 在 90% popup 中打开 btm |
| `prefix + r` | 重新加载 tmux 配置 |
| `prefix + R` | 从桌面会话刷新 DISPLAY 和 DBus 环境 |
| `prefix + b` | 显示或隐藏状态栏 |
| `prefix + ?` | 显示带说明的完整按键列表 |
| `prefix + /` | 按键说明搜索 |
| `prefix + :` | 打开 tmux command prompt |

## 插件与持久化

TPM 管理以下插件目录：

- `tmux-plugins/tpm`
- `tmux-plugins/tmux-resurrect`
- `tmux-plugins/tmux-continuum`
- `laktak/extrakto`
- `dracula/tmux`

| 快捷键 | 功能 |
|---|---|
| `prefix + I` | 安装缺失插件 |
| `prefix + U` | 更新插件 |
| `prefix + Alt-u` | 清理未配置插件 |

Continuum 每 30 分钟调用安全 Resurrect wrapper 保存一次；启动 tmux server 时自动恢复。状态栏位于顶部，Dracula 每 10 秒刷新 SSH、同步输入和时间模块。
