local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TopFloatBtnBase = require("Main.MainUI.ui.TopFloatBtnBase")
local DragonBaoKuEntry = Lplus.Extend(TopFloatBtnBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local DragonBaoKuMgr = require("Main.activity.DragonBaoKu.DragonBaoKuMgr")
local def = DragonBaoKuEntry.define
local instance
def.static("=>", DragonBaoKuEntry).Instance = function()
  if instance == nil then
    instance = DragonBaoKuEntry()
  end
  return instance
end
def.override("=>", "boolean").IsOpen = function(self)
  warn("====>>>>>>>>DragonBaoKuEntry:", DragonBaoKuMgr.Instance():isOpen())
  return DragonBaoKuMgr.Instance():isOpen()
end
def.override().OnShow = function(self)
  self:UpdateNotifyBadge()
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.ACTIVITY_DRAGON_BAOKU_NOTIFY_CHANGE, DragonBaoKuEntry.OnNotifyUpdate)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.LOTTERY_AWARD_UPDATE, DragonBaoKuEntry.OnNotifyUpdate)
end
def.method().UpdateNotifyBadge = function(self)
  local flag = DragonBaoKuMgr.Instance():isNotify()
  warn("@@@@@@@@@@@@@@@@UpdateNotifyBadge:", flag)
  if flag then
    GUIUtils.SetLightEffect(self.m_node, GUIUtils.Light.Round)
  else
    GUIUtils.SetLightEffect(self.m_node, GUIUtils.Light.None)
  end
end
def.override("string").onClick = function(self, id)
  if id == "Btn_DragonBaoKu" then
    require("Main.activity.DragonBaoKu.ui.DragonBaoKuPanel").Instance():ShowPanel()
  end
end
def.static("table", "table").OnNotifyUpdate = function(params)
  instance:UpdateNotifyBadge()
end
return DragonBaoKuEntry.Commit()
