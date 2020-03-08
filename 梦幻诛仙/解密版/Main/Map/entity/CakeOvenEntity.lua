local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local EntityBase = import(".EntityBase")
local CakeOvenEntity = Lplus.Extend(EntityBase, CUR_CLASS_NAME)
local ECCakeOven = require("Main.activity.BakeCake.ECCakeOven")
local CakeConsts = require("netio.protocol.mzm.gsp.cake.CakeConsts")
local def = CakeOvenEntity.define
def.field("number").stage = 0
def.field(ECCakeOven).model = nil
def.override("table").UnmarshalExtraInfo = function(self, extra_info)
  local ExtraInfoType = EntityBase.MapEntityExtraInfoType
  self.stage = extra_info.int_extra_infos[ExtraInfoType.MET_CAKE_OVEN_STAGE] or self.stage
end
def.override().OnDestroy = function(self)
  self:OnLeaveView()
end
def.override().OnEnterView = function(self)
  self:DestroyModel()
  local function onCakeOvenLoad(ret)
    if ret and self.model then
      self.model:SetPos(self.loc.x, self.loc.y)
    end
  end
  local modelId = self:GetModelId()
  self.model = ECCakeOven.new(modelId)
  local modelPath = GetModelPath(modelId)
  self.model:Load2(modelPath, onCakeOvenLoad, false)
end
def.override().OnLeaveView = function(self)
  self:DestroyModel()
  self.stage = 0
end
def.method().DestroyModel = function(self)
  if self.model then
    self.model:Destroy()
    self.model = nil
  end
end
def.override("table", "table").OnExtraInfoChange = function(self, extra_info, remove_extra_info_keys)
  self:UnmarshalExtraInfo(extra_info)
  self:OnEnterView()
end
def.method("=>", "number").GetModelId = function(self)
  if self.stage == CakeConsts.STAGE_MAKE_CAKE then
    return constant.FactionMakeCakeConsts.cookModelId
  else
    return constant.FactionMakeCakeConsts.prepareModelId
  end
end
return CakeOvenEntity.Commit()
