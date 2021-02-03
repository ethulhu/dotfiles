set --local function_name (basename (status filename) .fish)

function $function_name --description 'Run before every command.'
    if command --quiet gpg-connect-agent
        gpg-connect-agent updatestartuptty /bye >/dev/null
    end
end
