local Lplus = require("Lplus")
local RoleAndWingModel = Lplus.Class("RoleAndWingModel")
local ECUIModel = require("Model.ECUIModel")
local WingUtils
require("Main.Wing.WingUtils")
local def = RoleAndWingModel.define
def.field("table").model = nil
def.field("number").outlookId = 0
def.field("number").wingDyeId = 0
def.method("number", "number", "function").Create = function(self, outlookId, wingDyeId, callback)
  if self.model == nil then
    self.outlookId = outlookId
    self.wingDyeId = wingDyeId
    local modelId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyModelId()
    local modelPath = GetModelPath(modelId)
    self.model = ECUIModel.new(modelId)
    self.model.m_bUncache = true
    local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
    local modelInfo = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRoleModelInfo(gmodule.moduleMgr:GetModule(ModuleId.HERO).roleId) or nil
    modelInfo = clone(modelInfo)
    modelInfo.extraMap = modelInfo.extraMap or {}
    modelInfo.extraMap[ModelInfo.WING] = self.outlookId
    modelInfo.extraMap[ModelInfo.WING_COLOR_ID] = self.wingDyeId
    local function loaded(ret)
      if self.model == nil or self.model.m_model == nil or self.model.m_model.isnil then
        return
      end
      self.model:SetDir(180)
      self.model:Play("Stand_c")
      self.model:SetScale(1)
      self.model:SetPos(0, 0)
      if callback then
        callback()
      end
    end
    _G.LoadModelWithCallBack(self.model, modelInfo, false, false, loaded)
  end
end
def.method().Stand = function(self)
  if self.model then
    self.model:Play("Stand_c")
    if self.model.mECWingComponent then
      self.model.mECWingComponent:Stand()
    end
  end
end
def.method("number", "number").UpdateWing = function(self, outlookId, wingDyeId)
  if self.model:IsLoaded() then
    self.outlookId = outlookId
    self.wingDyeId = wingDyeId
    self.model:SetWing(self.outlookId, self.wingDyeId)
  else
    self.outlookId = outlookId
    self.wingDyeId = wingDyeId
  end
end
def.method().Destroy = function(self)
  if self.model ~= nil then
    self.model:Destroy()
    self.model = nil
  end
end
def.method("=>", "userdata").GetModelGameObject = function(self)
  if self.model and self.model.m_model and not self.model.m_model.isnil then
    return self.model.m_model
  else
    return nil
  end
end
def.method("=>", "number").GetDir = function(self)
  if self.model then
    return self.model:GetDir()
  else
    return -1
  end
end
def.method("number").SetDir = function(self, dir)
  if self.model then
    self.model:SetDir(dir)
  end
end
RoleAndWingModel.Commit()
return RoleAndWingModel
