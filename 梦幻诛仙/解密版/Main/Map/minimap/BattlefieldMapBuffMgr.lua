local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BattlefieldMapMgrBase = import(".BattlefieldMapMgrBase")
local BattlefieldMapBuffMgr = Lplus.Extend(BattlefieldMapMgrBase, MODULE_NAME)
local MiniMapPanel = Lplus.ForwardDeclare("MiniMapPanel")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local BattleFieldMgr = require("Main.CaptureTheFlag.mgr.BattleFieldMgr")
local CaptureTheFlagUtils = require("Main.CaptureTheFlag.CaptureTheFlagUtils")
local MapEntityType = require("netio.protocol.mzm.gsp.map.MapEntityType")
local def = BattlefieldMapBuffMgr.define
def.field("table").m_buffGOs = nil
def.field("userdata").m_templateGO = nil
def.override().OnCreate = function(self)
  self:LoadAll()
  Event.RegisterEventWithContext(ModuleId.MAP, gmodule.notifyId.Map.BATTLEFIELD_BUFF_APPEAR, BattlefieldMapBuffMgr.OnBuffAppear, self)
  Event.RegisterEventWithContext(ModuleId.MAP, gmodule.notifyId.Map.BATTLEFIELD_BUFF_DISAPPEAR, BattlefieldMapBuffMgr.OnBuffDisappear, self)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.MAP, gmodule.notifyId.Map.BATTLEFIELD_BUFF_APPEAR, BattlefieldMapBuffMgr.OnBuffAppear)
  Event.UnregisterEvent(ModuleId.MAP, gmodule.notifyId.Map.BATTLEFIELD_BUFF_DISAPPEAR, BattlefieldMapBuffMgr.OnBuffDisappear)
  self.m_buffGOs = nil
  self.m_templateGO = nil
end
def.method().LoadAll = function(self)
  self.m_buffGOs = {}
  self:AsyncCreateTemplateGO(function(templateGO)
    self.m_templateGO = templateGO
    self:UpdateAllBuffs()
  end)
end
def.method().UpdateAllBuffs = function(self)
  if self.m_templateGO == nil then
    return
  end
  local allBuffInfos = self:GetAllBuffs()
  for buffId, v in pairs(allBuffInfos) do
    local go = self:GetBuffInfoGO(buffId)
    self:SetBuffInfoGO(go, v)
  end
end
def.method("string", "=>", "userdata").GetBuffInfoGO = function(self, buffId)
  local buffInfoGO = self.m_buffGOs[tostring(buffId)]
  if buffInfoGO == nil then
    buffInfoGO = self:AddBuffInfoGO(buffId)
  end
  return buffInfoGO
end
def.method("string", "=>", "userdata").AddBuffInfoGO = function(self, buffId)
  local go = GameObject.Instantiate(self.m_templateGO)
  go.name = "battlefield_buff_" .. buffId
  go:SetActive(true)
  self.m_miniMap:AddUnitToMap(go, {x = 0, y = 0})
  self.m_buffGOs[tostring(buffId)] = go
  return go
end
def.method("userdata", "table").SetBuffInfoGO = function(self, go, buffInfo)
  if go == nil then
    Debug.LogError(debug.traceback())
    return
  end
  local buffInfoCfgId = buffInfo.cfgid
  local buffInfoCfg = CaptureTheFlagUtils.GetBuffInfoCfg(buffInfoCfgId)
  if buffInfoCfg then
    local iconId = buffInfoCfg.mini_map_icon_id
    GUIUtils.SetTexture(go, iconId)
  end
  local loc = buffInfo:GetLocation()
  self.m_miniMap:SetUnitByWorldPos2D(go, {
    x = loc.x,
    y = loc.y
  })
end
def.method("function").AsyncCreateTemplateGO = function(self, callback)
  local go = GameObject.GameObject("MapBuff_Template")
  go:SetLayer(ClientDef_Layer.UI)
  local uiTexture = go:AddComponent("UITexture")
  uiTexture.width = 36
  uiTexture.height = 36
  uiTexture.depth = MiniMapPanel.Depths.bf_buff
  go.parent = self.m_miniMap.m_panel
  go.localScale = Vector.Vector3.one
  callback(go)
end
def.method("=>", "table").GetAllBuffs = function(self)
  local buffEntities = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapEntitiesByType(MapEntityType.MET_SINGLE_BATTLE_BUFF)
  local buffInfos = buffEntities or {}
  return buffInfos
end
def.method("string").RemoveBuff = function(self, buffId)
  local go = self:GetBuffInfoGO(buffId)
  self.m_miniMap:RemoveUnit(go)
  self.m_buffGOs[buffId] = nil
end
def.method("table").OnBuffAppear = function(self, params)
  if self.m_templateGO == nil then
    return
  end
  local buffId = params.instanceId
  local go = self:GetBuffInfoGO(tostring(buffId))
  local buffInfo = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapEntity(MapEntityType.MET_SINGLE_BATTLE_BUFF, buffId)
  self:SetBuffInfoGO(go, buffInfo)
end
def.method("table").OnBuffDisappear = function(self, params)
  if self.m_templateGO == nil then
    return
  end
  local buffId = params.instanceId
  self:RemoveBuff(tostring(buffId))
end
return BattlefieldMapBuffMgr.Commit()
