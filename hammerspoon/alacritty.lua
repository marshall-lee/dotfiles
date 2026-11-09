-- Every time Alacritty becomes the front app, hide the other apps, like ⌥⌘H, so
-- its transparent window shows the wallpaper and not the windows behind it.
-- Switching to another app shows that app again.
local M = {}

local function hideOthers(except)
  for _, app in ipairs(hs.application.runningApplications()) do
    -- Kind 1 is an app with a Dock icon; the others have no windows to hide.
    if app ~= except and app:kind() == 1 and not app:isHidden() then
      app:hide()
    end
  end
end

-- Kept in the module, which require keeps loaded, so the watcher isn't garbage
-- collected and stopped.
M.watcher = hs.application.watcher.new(function(_, event, app)
  if event == hs.application.watcher.activated and app:bundleID() == 'org.alacritty' then
    hideOthers(app)
  end
end)
M.watcher:start()

return M
