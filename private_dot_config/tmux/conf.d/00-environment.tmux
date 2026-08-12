# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Environment
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# IBus input method support.
set-option -g update-environment "DISPLAY SSH_ASKPASS SSH_AGENT_PID SSH_CONNECTION WINDOWID XAUTHORITY XMODIFIERS GTK_IM_MODULE QT_IM_MODULE DBUS_SESSION_BUS_ADDRESS"
set-environment -g XMODIFIERS @im=ibus
set-environment -g GTK_IM_MODULE ibus
set-environment -g QT_IM_MODULE ibus
