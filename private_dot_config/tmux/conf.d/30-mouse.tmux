# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Mouse wheel (原生复刻 tmux-better-mouse-mode 的核心行为)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# 滚轮上滚:
#   1) 程序自带鼠标支持(如 vim mouse=a) → 透传事件
#   2) alternate-buffer 程序(less/man/vi) → 转成 ↑ 键,可翻页
#   3) 已在 copy-mode → 继续滚动;否则进入 copy-mode(-e:滚到底自动退出)
#   全程用 -t= 作用于鼠标所在窗格,不切换 active pane
bind -n WheelUpPane if -F "#{mouse_any_flag}" "send -M" {
    if -F "#{alternate_on}" "send -t= -N 3 Up" {
        if -F "#{pane_in_mode}" "send -M" "copy-mode -e -t="
    }
}

# 滚轮下滚:
#   1) 程序自带鼠标支持 → 透传
#   2) alternate-buffer 程序 → 转成 ↓ 键
#   3) 其余情况透传(copy-mode 中即向下滚,滚到底退出)
bind -n WheelDownPane if -F "#{mouse_any_flag}" "send -M" {
    if -F "#{alternate_on}" "send -t= -N 3 Down" "send -M"
}
