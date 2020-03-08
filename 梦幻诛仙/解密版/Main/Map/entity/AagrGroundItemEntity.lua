local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local EntityBase = import(".EntityBase")
local ECPlayer = require("Model.ECPlayer")
local AagrData = require("Main.Aagr.data.AagrData")
local AagrGroundItemEntity = Lplus.Extend(EntityBase, CUR_CLASS_NAME)
local def = AagrGroundItemEntity.define
def.field("table")._ecmodel = nil
def.override().OnDestroy = function(self)
  self:OnLeaveView()
end
def.override().OnEnterView = function(self)
  self:LoadItemModel()
end
def.override().OnLeaveView = function(self)
  if not _G.IsNil(self._ecmodel) then
    self._ecmodel:Destroy()
    self._ecmodel = nil
  end
end
def.method().LoadItemModel = function(self)
  if not _G.IsNil(self._ecmodel) then
    self._ecmodel:Destroy()
    self._ecmodel = nil
  end
  local entityCfg = AagrData.Instance():GetMapEntityCfg(self.cfgid)
  if nil == entityCfg then
    warn("[ERROR][AagrGroundItemEntity:LoadItemModel] entityCfg nil for cfgid:", self.cfgid)
    return
  end
  self._ecmodel = ECPlayer.new(self.instanceid, entityCfg.modelId, entityCfg.name, Color.green, RoleType.ITEM)
  self._ecmodel.showOrnament = true
  self._ecmodel.m_bUncache = true
  self._ecmodel:SetLayer(ClientDef_Layer.NPC)
  self._ecmodel:SetTouchable(false)
  local model_info = {}
  model_info.modelid = entityCfg.modelId
  model_info.extraMap = {}
  _G.LoadModel(self._ecmodel, model_info, self.loc.x, self.loc.y, 180, false, false)
end
return AagrGroundItemEntity.Commit()
