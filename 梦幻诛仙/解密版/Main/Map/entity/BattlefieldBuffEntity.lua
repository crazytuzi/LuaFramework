local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local EntityBase = import(".EntityBase")
local BattlefieldBuffEntity = Lplus.Extend(EntityBase, CUR_CLASS_NAME)
local ECModel = require("Model.ECModel")
local CaptureTheFlagUtils = require("Main.CaptureTheFlag.CaptureTheFlagUtils")
local def = BattlefieldBuffEntity.define
def.field("table").m_model = nil
def.override().OnCreate = function(self)
end
def.override("table").UnmarshalExtraInfo = function(self, extra_info)
end
def.override().OnDestroy = function(self)
  self:OnLeaveView()
end
def.override().OnEnterView = function(self)
  self:UpdateBuffModel()
  Event.DispatchEvent(ModuleId.MAP, gmodule.notifyId.Map.BATTLEFIELD_BUFF_APPEAR, {
    instanceId = self.instanceid
  })
end
def.override().OnLeaveView = function(self)
  Event.DispatchEvent(ModuleId.MAP, gmodule.notifyId.Map.BATTLEFIELD_BUFF_DISAPPEAR, {
    instanceId = self.instanceid
  })
  self:DestroyModel()
end
def.method().DestroyModel = function(self)
  if self.m_model == nil then
    return
  end
  self.m_model:Destroy()
  self.m_model = nil
end
def.override("number", "table", "table").OnInfoChange = function(self, cfgid, loc, extra_info)
end
def.override("table", "table").OnExtraInfoChange = function(self, extra_info, remove_extra_info_keys)
end
def.method().UpdateBuffModel = function(self)
  self:DestroyModel()
  local modelId = self:GetModelId()
  self.m_model = ECModel.new(-1)
  self.m_model.m_create_node2d = true
  self.m_model:Init(modelId)
  self.m_model:SetDefaultParentNode(gmodule.moduleMgr:GetModule(ModuleId.MAP).mapPlayerNodeRoot)
  local modelPath = GetModelPath(modelId)
  if modelPath ~= "" then
    local function onBuffModelLoaded(ret)
      if ret then
        self.m_model:SetPos(self.loc.x, self.loc.y)
      end
    end
    self.m_model:Load2(modelPath, onBuffModelLoaded, false)
  end
end
def.method("=>", "number").GetModelId = function(self)
  local buffInfoCfg = CaptureTheFlagUtils.GetBuffInfoCfg(self.cfgid)
  if buffInfoCfg then
    return buffInfoCfg.model_id
  else
    return 0
  end
end
return BattlefieldBuffEntity.Commit()
