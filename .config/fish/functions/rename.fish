set --local function_name (basename (status filename) .fish)

function $function_name --description 'Rename a file' --argument-names from to

    if [ (count $argv) -ne 2 ]
        echo 'Usage: '(status function)' <from> <to>'
        return 1
    end

    if [ ! -e $from ]
        echo (status function)": Does not exist: $from"
        return 1
    end

    if [ -f $to ]
        if confirm "File $to already exists. Delete it?"
            command mv $from $to
        end
    else if [ -d $to ]
        if confirm "Directory $to already exists. Delete it?"
            command rm -rf $to
            command mv $from $to
        end
    else
        command mv $from $to
    end
end
