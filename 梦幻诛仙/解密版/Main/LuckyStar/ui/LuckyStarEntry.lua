local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TopFloatBtnBase = require("Main.MainUI.ui.TopFloatBtnBase")
local LuckyStarEntry = Lplus.Extend(TopFloatBtnBase, "LuckyStarEntry")
local GUIUtils = require("GUI.GUIUtils")
local LuckyStarUIMgr = require("Main.LuckyStar.mgr.LuckyStarUIMgr")
local def = LuckyStarEntry.define
local instance
def.static("=>", LuckyStarEntry).Instance = function()
  if instance == nil then
    instance = LuckyStarEntry()
  end
  return instance
end
def.override("=>", "boolean").IsOpen = function(self)
  return LuckyStarUIMgr.Instance():IsShowLuckyStarEntry()
end
def.override().OnShow = function(self)
  self:UpdateNotifyBadge()
  Event.RegisterEvent(ModuleId.LUCKYSTAR, gmodule.notifyId.LuckyStar.LUCKYSTAR_NOTIFY_CHANGE, LuckyStarEntry.OnNotifyUpdate)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, LuckyStarEntry.OnNotifyUpdate)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.LUCKYSTAR, gmodule.notifyId.LuckyStar.LUCKYSTAR_NOTIFY_CHANGE, LuckyStarEntry.OnNotifyUpdate)
  Event.UnregisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, LuckyStarEntry.OnNotifyUpdate)
end
def.method().UpdateNotifyBadge = function(self)
  local Btn_LuckyStar = self.m_node
  local Img_Red = Btn_LuckyStar:FindDirect("Img_ActivityRed")
  local hasNotify = LuckyStarUIMgr.Instance():HasLuckyStarNotify()
  if hasNotify then
    GUIUtils.SetLightEffect(Btn_LuckyStar, GUIUtils.Light.Round)
    Img_Red:SetActive(true)
  else
    GUIUtils.SetLightEffect(Btn_LuckyStar, GUIUtils.Light.None)
    Img_Red:SetActive(false)
  end
end
def.override("string").onClick = function(self, id)
  if id == "Btn_LuckyStar" then
    LuckyStarUIMgr.Instance():MarkTodayAsShowed()
    Event.DispatchEvent(ModuleId.LUCKYSTAR, gmodule.notifyId.LuckyStar.OPEN_LUCKYSTAR_PANEL, nil)
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.LUCKYSTAR, {3})
  end
end
def.static("table", "table").OnNotifyUpdate = function(params)
  instance:UpdateNotifyBadge()
end
return LuckyStarEntry.Commit()
