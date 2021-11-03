function open_app(name)
    return function()
        hs.application.launchOrFocus(name)
    end
end

hs.hotkey.bind({"cmd"}, "1", open_app("kitty"))
hs.hotkey.bind({"cmd"}, "2", open_app("brave browser"))
hs.hotkey.bind({"cmd"}, "3", open_app("spotify"))
hs.hotkey.bind({"cmd"}, "4", open_app("WhatsApp"))
