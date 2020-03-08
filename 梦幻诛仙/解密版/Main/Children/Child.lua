local Lplus = require("Lplus")
local Child = Lplus.Class("Child")
local ECPlayer = require("Model.ECPlayer")
local def = Child.define
local ChildPhase = require("consts.mzm.gsp.children.confbean.ChildPhase")
local ECUIModel = require("Model.ECUIModel")
local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
local ChildrenUtils = require("Main.Children.ChildrenUtils")
def.field("table").model = nil
def.field("string").name = ""
def.field("number").cfgId = 0
def.field("userdata").instanceId = nil
def.field("table").modelInfo = nil
def.static("number", "=>", Child).Create = function(cfgId)
  local child = Child()
  child.cfgId = cfgId
  return child
end
def.static("number", "number", "=>", Child).CreateWithCostume = function(cfgId, costumeId)
  local child = Child()
  child.cfgId = cfgId
  local pseudoModelInfo = ModelInfo.new()
  pseudoModelInfo.modelid = 0
  pseudoModelInfo.extraMap[ModelInfo.CHILDREN_MODEL_ID] = cfgId
  pseudoModelInfo.extraMap[ModelInfo.CHILDREN_FASHION] = costumeId
  child.modelInfo = pseudoModelInfo
  return child
end
def.static("number", "number", "=>", Child).CreateWithFashion = function(cfgId, fashionId)
  local child = Child()
  child.cfgId = cfgId
  local pseudoModelInfo = ModelInfo.new()
  pseudoModelInfo.modelid = 0
  pseudoModelInfo.extraMap[ModelInfo.CHILDREN_MODEL_ID] = cfgId
  if fashionId > 0 then
    local fashionCfg = ChildrenUtils.GetChildrenFashionCfg(fashionId)
    if fashionCfg then
      pseudoModelInfo.extraMap[ModelInfo.CHILDREN_FASHION] = fashionCfg.changeId
    end
  end
  child.modelInfo = pseudoModelInfo
  return child
end
def.static("number", "number", "=>", Child).CreateWithWeapon = function(cfgId, weaponId)
  local child = Child()
  child.cfgId = cfgId
  local pseudoModelInfo = ModelInfo.new()
  pseudoModelInfo.modelid = 0
  pseudoModelInfo.extraMap[ModelInfo.CHILDREN_MODEL_ID] = cfgId
  pseudoModelInfo.extraMap[ModelInfo.CHILDREN_WEAPON_ID] = weaponId
  child.modelInfo = pseudoModelInfo
  return child
end
def.static("number", "number", "number", "=>", Child).CreateWithCostumeAndWeapon = function(cfgId, costumeId, weaponId)
  local child = Child()
  child.cfgId = cfgId
  local pseudoModelInfo = ModelInfo.new()
  pseudoModelInfo.modelid = 0
  pseudoModelInfo.extraMap[ModelInfo.CHILDREN_MODEL_ID] = cfgId
  pseudoModelInfo.extraMap[ModelInfo.CHILDREN_FASHION] = costumeId
  pseudoModelInfo.extraMap[ModelInfo.CHILDREN_WEAPON_ID] = weaponId
  child.modelInfo = pseudoModelInfo
  return child
end
def.static("number", "number", "number", "=>", Child).CreateWithFashionAndWeapon = function(cfgId, fashionId, weaponId)
  local child = Child()
  child.cfgId = cfgId
  local pseudoModelInfo = ModelInfo.new()
  pseudoModelInfo.modelid = 0
  pseudoModelInfo.extraMap[ModelInfo.CHILDREN_MODEL_ID] = cfgId
  pseudoModelInfo.extraMap[ModelInfo.CHILDREN_WEAPON_ID] = weaponId
  if fashionId > 0 then
    local fashionCfg = ChildrenUtils.GetChildrenFashionCfg(fashionId)
    if fashionCfg then
      pseudoModelInfo.extraMap[ModelInfo.CHILDREN_FASHION] = fashionCfg.changeId
    end
  end
  child.modelInfo = pseudoModelInfo
  return child
end
def.static("table", "=>", Child).CreateWithModelInfo = function(modelInfo)
  local child = Child()
  child.modelInfo = modelInfo
  child.cfgId = modelInfo.extraMap[ModelInfo.CHILDREN_MODEL_ID]
  return child
end
def.method("=>", "table").GetModel = function(self)
  return self.model
end
def.method("userdata").SetInstanceId = function(self, instId)
  self.instanceId = instId
  if self.model and self.model:is(ECPlayer) then
    self.model.roleId = self.instanceId
  end
end
def.method("string", "userdata", "number", "number", "number", "table", "function", "=>", "table").LoadModel = function(self, name, nameColor, x, y, dir, modelInfo, cb)
  local cfg = require("Main.Children.ChildrenUtils").GetChildrenCfgById(self.cfgId)
  if cfg == nil then
    return nil
  end
  if self.model and not self.model:is(ECPlayer) then
    self:DestroyModel()
  end
  if self.model == nil then
    local instanceId = self.instanceId
    self.model = ECPlayer.new(instanceId, cfg.modelId, name, nameColor, RoleType.CHILD)
  else
    self.model:Destroy()
    self.model:Init(cfg.modelId)
  end
  self.model.showOrnament = true
  self.model.m_bUncache = true
  self.model:AddOnLoadCallback("OnLoad", cb)
  local model_info = modelInfo or self.modelInfo
  model_info.modelid = cfg.modelId
  self.model.extraInfo = model_info
  _G.LoadModel(self.model, model_info, x, y, dir, false, false)
  return self.model
end
def.method("table", "function", "=>", "table").LoadUIModel = function(self, modelInfo, cb)
  local cfg = require("Main.Children.ChildrenUtils").GetChildrenCfgById(self.cfgId)
  if cfg == nil then
    return nil
  end
  if self.model and not self.model:is(ECUIModel) then
    self:DestroyModel()
  end
  if self.model == nil then
    self.model = ECUIModel.new(cfg.modelId)
  else
    self.model:Destroy()
    self.model:Init(cfg.modelId)
  end
  self.model.showOrnament = true
  self.model.m_bUncache = true
  self.model:AddOnLoadCallback("OnLoad", cb)
  local model_info = modelInfo or self.modelInfo
  model_info.modelid = cfg.modelId
  _G.LoadModel(self.model, model_info, 0, 0, 180, false, false)
  return self.model
end
def.method("number").GetPhase = function(self)
  return self.phase
end
def.method("number", "number").SetPos = function(self, x, y)
  if self.model then
    self.model:SetPos(x, y)
  end
end
def.method("number").SetDir = function(self, ang)
  if self.model then
    self.model:SetDir(ang)
  end
end
def.method("=>", "number").GetDir = function(self)
  if self.model then
    return self.model:GetDir()
  else
    return 0
  end
end
def.method("number").SetScale = function(self, scale)
  if self.model then
    self.model:SetScale(scale)
  end
end
def.method("number", "number").MoveTo = function(self, x, y)
end
def.method("table", "function").RunPath = function(self, path, callback)
  if self.model and self.model:is(ECPlayer) then
    self.model:RunPath(path, self.model.runSpeed, callback)
  end
end
def.method("number").SetCostume = function(self, costumeId)
  if self.modelInfo then
    self.modelInfo.extraMap[ModelInfo.CHILDREN_FASHION] = costumeId
  end
  if self.model then
    _G.SetChildCostume(self.model, self.cfgId, costumeId)
  end
end
def.method("number").SetWeapon = function(self, weaponId)
  if self.modelInfo then
    self.modelInfo.extraMap[ModelInfo.CHILDREN_WEAPON_ID] = weaponId
  end
  if self.model then
    _G.SetChildWeapon(self.model, weaponId, 0)
  end
end
def.method().DestroyModel = function(self)
  if self.model then
    self.model:Destroy()
    self.model = nil
  end
end
def.method("number").Update = function(self, tick)
  if self.model then
    self.model:Update(tick)
  end
end
def.method().Stand = function(self)
  if self.model then
    self.model:Play(ActionName.Stand)
  end
end
def.method().Destroy = function(self)
  self:DestroyModel()
end
Child.Commit()
return Child
