local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local EntityBase = import(".EntityBase")
local GatherItemEntity = Lplus.Extend(EntityBase, CUR_CLASS_NAME)
local CaptureTheFlagUtils = require("Main.CaptureTheFlag.CaptureTheFlagUtils")
local ECGatherItem = require("Main.CaptureTheFlag.model.ECGatherItem")
local def = GatherItemEntity.define
def.field("table").itemCfg = nil
def.field(ECGatherItem).model = nil
def.override().OnCreate = function(self)
  self.itemCfg = CaptureTheFlagUtils.GetGatherItemCfg(self.cfgid)
end
def.override().OnDestroy = function(self)
  self:OnLeaveView()
end
def.override().OnEnterView = function(self)
  self:DestroyModel()
  local function onItemLoad(ret)
    if ret then
      self.model:CreateHUD()
      self.model:SetDir(180)
      self.model:SetPos(self.loc.x, self.loc.y)
    end
  end
  self.model = ECGatherItem.new(self.cfgid, self.instanceid)
  local modelPath = GetModelPath(self.itemCfg.modelId)
  self.model:SetName(self.itemCfg.name, Color.white)
  self.model:Load2(modelPath, onItemLoad, false)
  Event.DispatchEvent(ModuleId.MAP, gmodule.notifyId.Map.BATTLEFIELD_GATHERITEM_APPEAR, {
    instanceId = self.instanceid
  })
end
def.override().OnLeaveView = function(self)
  Event.DispatchEvent(ModuleId.MAP, gmodule.notifyId.Map.BATTLEFIELD_GATHERITEM_DISAPPEAR, {
    instanceId = self.instanceid
  })
  self:DestroyModel()
  self.itemCfg = nil
end
def.method().DestroyModel = function(self)
  if self.model then
    self.model:Destroy()
    self.model = nil
  end
end
def.override("number", "table", "table").OnInfoChange = function(self, cfgid, loc, extra_info)
  self.cfgid = cfgid
  self.loc = loc
  self:DestroyModel()
  self:OnEnterView()
end
def.override("table").OnSyncMove = function(self, locs)
  if self.model then
    self.model:SetPos(self.loc.x, self.loc.y)
  end
end
return GatherItemEntity.Commit()
