function z --description 'Launch Zed editor in background'
    setsid zed $argv > /dev/null 2>&1 &
end
