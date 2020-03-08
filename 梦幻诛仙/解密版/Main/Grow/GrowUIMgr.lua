local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local GrowUIMgr = Lplus.Class(MODULE_NAME)
local def = GrowUIMgr.define
local UISet = {
  GrowGuide = "GrowGuidePanel"
}
def.const("table").UISet = UISet
local instance
def.static("=>", GrowUIMgr).Instance = function()
  if instance == nil then
    instance = GrowUIMgr()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_GROW_GUIDE_CLICK, GrowUIMgr.OnGrowGuideButtonClicked)
end
def.method("string", "=>", "table").GetUI = function(self, uiName)
  return import(".ui." .. uiName, MODULE_NAME)
end
def.static("table", "table").OnGrowGuideButtonClicked = function(params, context)
  instance:GetUI(UISet.GrowGuide).Instance():ShowDlg()
end
def.static("varlist").OpenBianqiangPanel = function(bqType)
  local GrowGuidePanel = instance:GetUI(UISet.GrowGuide)
  GrowGuidePanel.Instance():ShowDlgEx(GrowGuidePanel.NodeId.AdvanceGuide, {bqType = bqType})
end
def.method().OnReset = function(self)
end
return GrowUIMgr.Commit()
