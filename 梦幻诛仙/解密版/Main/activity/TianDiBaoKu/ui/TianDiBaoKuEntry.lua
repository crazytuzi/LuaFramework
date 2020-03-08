local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TopFloatBtnBase = require("Main.MainUI.ui.TopFloatBtnBase")
local TianDiBaoKuEntry = Lplus.Extend(TopFloatBtnBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local LotteryAwardMgr = require("Main.Award.mgr.LotteryAwardMgr")
local def = TianDiBaoKuEntry.define
local instance
def.static("=>", TianDiBaoKuEntry).Instance = function()
  if instance == nil then
    instance = TianDiBaoKuEntry()
  end
  return instance
end
def.override("=>", "boolean").IsOpen = function(self)
  return LotteryAwardMgr.Instance():IsActivityOpen()
end
def.override().OnShow = function(self)
  self:UpdateNotifyBadge()
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.LOTTERY_AWARD_UPDATE, TianDiBaoKuEntry.OnNotifyUpdate)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.LOTTERY_AWARD_UPDATE, TianDiBaoKuEntry.OnNotifyUpdate)
end
def.method().UpdateNotifyBadge = function(self)
  local Btn_TianDi = self.m_node
  local Img_Red = Btn_TianDi:FindDirect("Img_ActivityRed")
  local hasNotify = LotteryAwardMgr.Instance():HasNotify()
  if Img_Red then
    Img_Red:SetActive(false)
  end
  if hasNotify then
    GUIUtils.SetLightEffect(Btn_TianDi, GUIUtils.Light.Round)
  else
    GUIUtils.SetLightEffect(Btn_TianDi, GUIUtils.Light.None)
  end
end
def.override("string").onClick = function(self, id)
  if id == "Btn_TianDi" then
    require("ProxySDK.ECMSDK").SendTLogToServer(_G.TLOGTYPE.BAOKU, {})
    require("Main.activity.TianDiBaoKu.ui.TianDiBaoKuPanel").Instance():ShowPanel()
  end
end
def.static("table", "table").OnNotifyUpdate = function(params)
  instance:UpdateNotifyBadge()
end
return TianDiBaoKuEntry.Commit()
