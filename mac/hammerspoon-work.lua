-- TODO: figure out how to dynamically assign hotkeys based on what applications are open

local function open_app(name)
  hs.application.launchOrFocus(name)
end

-- local function open_primary_app()
--   return function()
--     app = "kitty"
--     if hs.application.find("Live") then
--         app = "Live"
--     end
--     open_app(app)
--   end
-- end

local function open_other_apps(name)
  return function() open_app(name) end
end

-- hs.hotkey.bind({"cmd"}, "1", open_primary_app())
hs.hotkey.bind({"cmd"}, "1", open_other_apps("iterm"))
hs.hotkey.bind({"cmd"}, "2", open_other_apps("arc"))
hs.hotkey.bind({"cmd"}, "3", open_other_apps("slack"))
hs.hotkey.bind({"cmd"}, "4", open_other_apps("goland"))
hs.hotkey.bind({"cmd"}, "5", open_other_apps("spotify"))
hs.hotkey.bind({"cmd"}, "6", open_other_apps("Pritunl"))
