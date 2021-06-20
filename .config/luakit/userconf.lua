-- Use letters instead of numbers for hints.

local select = require "select"

select.label_maker = function()
    local chars = charset("arstdqwfpgjzxcvb")
    return trim(sort(reverse(chars)))
end


-- Keybindings.

local modes = require "modes"

modes.add_binds("normal", {
    {
        ",y", "Yank selection to clipboard",
        function() luakit.selection.clipboard = luakit.selection.primary end
    }
})
