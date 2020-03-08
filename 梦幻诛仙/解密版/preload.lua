local step = 0
local function preload()
  step = step + 1
  if step == 1 then
    require("Utility.init")
    require("protobuf.protobuf")
    require("Main.ECConfigs")
    require("Common.ECResPath")
  elseif step == 2 then
  elseif step == 3 then
  elseif step == 4 then
    require("Common.ECClientDef")
  elseif step == 5 then
    require("Main.ECGame")
  elseif step == 6 then
    require("GUI.GUIPreload")
    require("Main.EntryPoint")
    require("Event.EventsPreRegister")
    require("Sound.SoundPreload")
    require("Common.ECMsgBox")
    require("Common.ECFlashTip")
    require("CG.Preload")
  else
    if step ~= 7 then
      error("preload")
    end
    require("Main.ECGame").Instance():Init()
    return true
  end
  return false
end
return preload
