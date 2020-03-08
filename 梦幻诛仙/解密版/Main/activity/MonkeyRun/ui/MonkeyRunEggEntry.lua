local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TopFloatBtnBase = require("Main.MainUI.ui.TopFloatBtnBase")
local MonkeyRunEggEntry = Lplus.Extend(TopFloatBtnBase, "MonkeyRunEggEntry")
local GUIUtils = require("GUI.GUIUtils")
local def = MonkeyRunEggEntry.define
local instance
def.static("=>", MonkeyRunEggEntry).Instance = function()
  if instance == nil then
    instance = MonkeyRunEggEntry()
  end
  return instance
end
def.override("=>", "boolean").IsOpen = function(self)
  return require("Main.activity.MonkeyRun.MonkeyRunMgr").Instance():IsEggAwardActivityOpened()
end
def.override("string").onClick = function(self, id)
  if id == "Btn_MonkeyEggs" then
    require("Main.activity.MonkeyRun.MonkeyRunMgr").Instance():OpenMonkeyRunEggAwardActivity()
  end
end
return MonkeyRunEggEntry.Commit()
