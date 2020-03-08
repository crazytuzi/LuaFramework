local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local NpcAwardPanel = Lplus.Extend(ECPanelBase, "NpcAwardPanel")
local NPCAwardActivityMgr = require("Main.activity.NPCAwardActivityMgr")
local def = NpcAwardPanel.define
local instance
def.field("number")._activityId = 0
def.field("number")._timerId = 0
def.static("=>", NpcAwardPanel).Instance = function()
  if instance == nil then
    instance = NpcAwardPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.m_TrigGC = true
end
def.method("number").ShowPanel = function(self, activityId)
  self._activityId = activityId
  if self:IsShow() == false then
    self:CreatePanel(RESPATH.PREFAB_COMMON_RED_BAG, _G.GUILEVEL.NORMAL)
    self:SetModal(true)
  end
end
def.method().HideDlg = function(self)
  if self.m_panel then
    local p = require("netio.protocol.mzm.gsp.npcreward.CGetReward").new(self._activityId)
    gmodule.network.sendProtocol(p)
    if self._timerId ~= 0 then
      GameUtil.RemoveGlobalTimer(self._timerId)
    end
    self:DestroyPanel()
  end
end
def.method("string").onClick = function(self, id)
  warn("NpcAwardPanel click id:", id)
  local strs = string.split(id, "_")
  if id == "Point_Effect" then
    self:HideDlg()
  end
end
def.override().OnCreate = function(self)
end
def.override().OnDestroy = function(self)
end
def.override("boolean").OnShow = function(self, b)
  if b then
    local npcAwarCfg = NPCAwardActivityMgr.GetNPCAWardCfg(self._activityId)
    local effres = _G.GetEffectRes(npcAwarCfg.effectCfgid)
    if effres then
      local Point_Effect = self.m_panel:FindDirect("Point_Effect")
      require("Fx.GUIFxMan").Instance():PlayAsChildLayerWithCallback(Point_Effect, effres.path, "effect", 0, 0, 1, 1, -1, false, function()
      end)
    else
      warn("!!!!!!!!!NpcAwardPanel invalid effectId:", effectId)
    end
    GameUtil.AddGlobalTimer(5, true, function()
      self._timerId = 0
      self:HideDlg()
    end)
  end
end
NpcAwardPanel.Commit()
return NpcAwardPanel
