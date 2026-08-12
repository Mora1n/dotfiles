# Prevent accidental deletion of root directory
function rm
    for arg in $argv
        if string match -qr '^-{0,2}(r|rf|fr)' -- $arg; and string match -q '/' -- $argv
            echo "Error: Deletion of root directory is prohibited" >&2
            return 1
        end
    end
    command rm $argv
end
