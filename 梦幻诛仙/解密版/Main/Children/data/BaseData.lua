local Lplus = require("Lplus")
local BaseData = Lplus.Class("BaseData")
local ChildBean = require("netio.protocol.mzm.gsp.children.ChildBean")
local ChildPhase = require("consts.mzm.gsp.children.confbean.ChildPhase")
local def = BaseData.define
def.field("userdata").id = nil
def.field("string").name = ""
def.field("number").gender = 0
def.field("number").status = 0
def.field("userdata").owner = nil
def.field("table").fashion = nil
def.field("table").modelMap = nil
def.final(BaseData, BaseData).Copy = function(old, new)
  if old == nil or new == nil then
    return
  end
  new.id = Int64.new(old.id)
  new.name = old.name
  new.gender = old.gender
  new.status = old.status
  new.owner = Int64.new(old.owner)
end
def.virtual("table").RawSet = function(self, child)
  self.id = child.child_id
  self.name = GetStringFromOcts(child.child_name)
  self.gender = child.child_gender
  self.status = child.child_period
  self.owner = child.child_belong_role_id
  if child.fashions then
    for k, v in pairs(child.fashions) do
      self:SetFashion(k, v)
    end
  end
  if child.child_model_cfg_id_map then
    self.modelMap = {}
    for k, v in pairs(child.child_model_cfg_id_map) do
      self.modelMap[k] = v
    end
  end
end
def.method("=>", "boolean").IsBaby = function(self)
  return self.status == ChildPhase.INFANT
end
def.method("=>", "boolean").IsTeen = function(self)
  return self.status == ChildPhase.CHILD
end
def.method("=>", "boolean").IsYouth = function(self)
  return self.status == ChildPhase.YOUTH
end
def.method("=>", "number").GetStatus = function(self)
  return self.status
end
def.method("=>", "string").GetName = function(self)
  return self.name
end
def.method("string", "=>").SetName = function(self, name)
  self.name = name
end
def.method("=>", "number").GetGender = function(self)
  return self.gender
end
def.method("=>", "number").GetModelCfgId = function(self)
  return self:GetModelIdByPhase(self.status)
end
def.method("=>", "userdata").GetOwner = function(self)
  return self.owner
end
def.method("=>", "boolean").IsMine = function(self)
  local myRoleId = _G.GetMyRoleID()
  return self.owner ~= nil and myRoleId ~= nil and self.owner:eq(myRoleId)
end
def.method("=>", "userdata").GetId = function(self)
  return self.id
end
def.method("=>", "table").GetFashionInfo = function(self)
  return self.fashion
end
def.method("=>", "table").GetCurFashion = function(self)
  return self:GetFashionByPhase(self:GetStatus())
end
def.method("number", "=>", "table").GetFashionByPhase = function(self, phase)
  if self.fashion then
    return self.fashion[phase]
  else
    return nil
  end
end
def.method("number", "table").SetFashion = function(self, period, fashionInfo)
  if self.fashion == nil then
    self.fashion = {}
  end
  if fashionInfo then
    self.fashion[period] = {
      fashionId = fashionInfo.fashion_cfgid,
      owner = fashionInfo.owner_roleid
    }
  else
    self.fashion[period] = nil
  end
end
def.method("=>", "number").GetCurModelId = function(self)
  return self:GetModelIdByPhase(self.status)
end
def.method("number", "=>", "number").GetModelIdByPhase = function(self, phase)
  if self.modelMap then
    return self.modelMap[phase] or 0
  else
    return 0
  end
end
def.method("number", "number").SetModelIdByPhase = function(self, phase, modelId)
  if self.modelMap == nil then
    self.modelMap = {}
  end
  self.modelMap[phase] = modelId
end
BaseData.Commit()
return BaseData
