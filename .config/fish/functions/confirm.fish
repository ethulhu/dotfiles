set --local function_name (basename (status filename) .fish)

function $function_name --description 'Ask the user for confirmation' --argument-names prompt
    switch (count $argv)
        case 0
            contains -- (read --prompt-str '[y/N] ' --nchars 1) y Y

        case 1
            contains -- (read --prompt-str "$prompt [y/N] " --nchars 1) y Y

        case '*'
            echo 'Usage: '(status function)' [prompt]'
            return 1
    end
end
