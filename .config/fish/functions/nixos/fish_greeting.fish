set --local function_name (basename (status filename) .fish)

function $function_name
    systemctl list-units --no-pager --no-legend --state=failed
end
