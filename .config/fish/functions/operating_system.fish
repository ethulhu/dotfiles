set --local function_name (basename (status filename) .fish)

function $function_name --description 'Return the current Operating System.'
    set --local uname (uname -s)
    switch $uname
        case Darwin
            echo 'macOS'

        case Linux
            if [ -f /etc/debian_version ]
                echo 'Debian'
            else if [ -d /nix/store ]
                echo 'NixOS'
            else
                echo 'Linux'
            end

        case '*'
            echo $uname
    end
end
