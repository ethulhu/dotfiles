set --local function_name (basename (status filename) .fish)

function $function_name --description 'Move one or more files or folders into a folder'

    if [ (count $argv) -lt 2 ]
        echo 'Usage: '(status function)' <file> [<file>...] <folder>'
        return 1
    end

    if [ ! -d $argv[-1] ]
        echo (status function)": Not a directory: $argv[-1]"
        return 1
    end

    command mv $argv
end
