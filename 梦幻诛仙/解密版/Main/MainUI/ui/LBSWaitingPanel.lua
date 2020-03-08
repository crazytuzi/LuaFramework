local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ECMSDK = require("ProxySDK.ECMSDK")
local Vector = require("Types.Vector3")
local LBSWaitingPanel = Lplus.Extend(ECPanelBase, "LBSWaitingPanel")
local def = LBSWaitingPanel.define
def.field("number").m_TimerID = 0
local instance
def.static("=>", LBSWaitingPanel).Instance = function()
  if not instance then
    instance = LBSWaitingPanel()
    instance.m_depthLayer = GUIDEPTH.TOPMOST
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_LBS_WAITING_PANEL, GUILEVEL.DEPENDEND)
end
def.override().OnCreate = function(self)
  self.m_TimerID = GameUtil.AddGlobalTimer(5, true, function()
    self:DestroyPanel()
  end)
end
def.override().OnDestroy = function(self)
  if self.m_TimerID ~= 0 then
    GameUtil.RemoveGlobalTimer(self.m_TimerID)
    self.m_TimerID = 0
  end
end
def.method("string").onClick = function(self, id)
end
return LBSWaitingPanel.Commit()
