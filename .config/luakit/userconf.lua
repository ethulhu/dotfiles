-- Use letters instead of numbers for hints.

local select = require "select"

select.label_maker = function()
    local chars = charset("arstdqwfpgjzxcvb")
    return trim(sort(reverse(chars)))
end

-- Follow hint size.

local follow = require "follow"

follow.stylesheet = follow.stylesheet .. [[
#luakit_select_overlay .hint_label {
  font-size: 12px;
}
]]

-- Keybindings.

local modes = require "modes"

modes.add_binds("normal", {
    {
        ",y", "Yank selection to clipboard", function(w)
            luakit.selection.clipboard = luakit.selection.primary
            w:notify("Yanked selection to clipboard")
        end
    }
})


-- Misc settings.

local settings = require "settings"

settings.set_setting("session.always_save", true, {})
settings.set_setting("webview.enable_accelerated_2d_canvas", true, {})
settings.set_setting("window.default_search_engine", "duckduckgo", {})

settings.set_setting("webview.javascript_can_access_clipboard", true,
                     {domain = "moji.eth.moe"})
