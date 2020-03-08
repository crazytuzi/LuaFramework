local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BattlefieldMapMgrBase = import(".BattlefieldMapMgrBase")
local BattlefieldMapResMgr = Lplus.Extend(BattlefieldMapMgrBase, MODULE_NAME)
local MiniMapPanel = Lplus.ForwardDeclare("MiniMapPanel")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local BattleFieldMgr = require("Main.CaptureTheFlag.mgr.BattleFieldMgr")
local CaptureTheFlagUtils = require("Main.CaptureTheFlag.CaptureTheFlagUtils")
local MapEntityType = require("netio.protocol.mzm.gsp.map.MapEntityType")
local def = BattlefieldMapResMgr.define
def.field("table").m_resGOs = nil
def.field("userdata").m_templateGO = nil
def.override().OnCreate = function(self)
  self:LoadAll()
  Event.RegisterEventWithContext(ModuleId.MAP, gmodule.notifyId.Map.BATTLEFIELD_GATHERITEM_APPEAR, BattlefieldMapResMgr.OnResAppear, self)
  Event.RegisterEventWithContext(ModuleId.MAP, gmodule.notifyId.Map.BATTLEFIELD_GATHERITEM_DISAPPEAR, BattlefieldMapResMgr.OnResDisappear, self)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.MAP, gmodule.notifyId.Map.BATTLEFIELD_GATHERITEM_APPEAR, BattlefieldMapResMgr.OnResAppear)
  Event.UnregisterEvent(ModuleId.MAP, gmodule.notifyId.Map.BATTLEFIELD_GATHERITEM_DISAPPEAR, BattlefieldMapResMgr.OnResDisappear)
  self.m_resGOs = nil
  self.m_templateGO = nil
end
def.method().LoadAll = function(self)
  self.m_resGOs = {}
  self:AsyncCreateTemplateGO(function(templateGO)
    self.m_templateGO = templateGO
    self:UpdateAllRess()
  end)
end
def.method().UpdateAllRess = function(self)
  if self.m_templateGO == nil then
    return
  end
  local allResInfos = self:GetAllRess()
  for resId, v in pairs(allResInfos) do
    local go = self:GetResInfoGO(resId)
    self:SetResInfoGO(go, v)
  end
end
def.method("string", "=>", "userdata").GetResInfoGO = function(self, resId)
  local resInfoGO = self.m_resGOs[tostring(resId)]
  if resInfoGO == nil then
    resInfoGO = self:AddResInfoGO(resId)
  end
  return resInfoGO
end
def.method("string", "=>", "userdata").AddResInfoGO = function(self, resId)
  local go = GameObject.Instantiate(self.m_templateGO)
  go.name = "battlefield_res_" .. resId
  go:SetActive(true)
  self.m_miniMap:AddUnitToMap(go, {x = 0, y = 0})
  self.m_resGOs[tostring(resId)] = go
  return go
end
def.method("userdata", "table").SetResInfoGO = function(self, go, resInfo)
  if go == nil then
    Debug.LogError(debug.traceback())
    return
  end
  local resInfoCfgId = resInfo.cfgid
  local resInfoCfg = CaptureTheFlagUtils.GetGatherItemCfg(resInfoCfgId)
  if resInfoCfg then
    local iconId = resInfoCfg.icon or 233
    GUIUtils.SetTexture(go, iconId)
  end
  local loc = resInfo:GetLocation()
  self.m_miniMap:SetUnitByWorldPos2D(go, {
    x = loc.x,
    y = loc.y
  })
end
def.method("function").AsyncCreateTemplateGO = function(self, callback)
  local go = GameObject.GameObject("MapRes_Template")
  go:SetLayer(ClientDef_Layer.UI)
  local uiTexture = go:AddComponent("UITexture")
  uiTexture.width = 24
  uiTexture.height = 24
  uiTexture.depth = MiniMapPanel.Depths.bf_res
  go.parent = self.m_miniMap.m_panel
  go.localScale = Vector.Vector3.one
  callback(go)
end
def.method("=>", "table").GetAllRess = function(self)
  local resEntities = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapEntitiesByType(MapEntityType.MET_SINGLE_BATTLE_GATHER_ITEM)
  local resInfos = resEntities or {}
  return resInfos
end
def.method("table").OnResAppear = function(self, params)
  if self.m_templateGO == nil then
    return
  end
  local resId = params.instanceId
  local go = self:GetResInfoGO(tostring(resId))
  local resInfo = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapEntity(MapEntityType.MET_SINGLE_BATTLE_GATHER_ITEM, resId)
  self:SetResInfoGO(go, resInfo)
end
def.method("table").OnResDisappear = function(self, params)
  if self.m_templateGO == nil then
    return
  end
  local resId = params.instanceId
  local go = self:GetResInfoGO(tostring(resId))
  self.m_miniMap:RemoveUnit(go)
  self.m_resGOs[tostring(resId)] = nil
end
return BattlefieldMapResMgr.Commit()
