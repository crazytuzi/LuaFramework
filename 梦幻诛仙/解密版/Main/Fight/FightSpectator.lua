local Lplus = require("Lplus")
local FightModel = require("Main.Fight.FightModel")
local FightSpectator = Lplus.Extend(FightModel, "FightSpectator")
local def = FightSpectator.define
def.field("number").team = 0
def.field("userdata").roleId = nil
def.field("table").flyMount = nil
def.field("number").pos = 0
def.final("number", "string", "userdata", "number", "=>", FightSpectator).new = function(id, name, nameColor, roleType)
  local obj = FightSpectator()
  obj.m_roleType = roleType
  obj:Init(id)
  obj.defaultLayer = ClientDef_Layer.FightPlayer
  obj:SetName(name, nameColor)
  obj.m_bUncache = true
  return obj
end
def.override().Destroy = function(self)
  if self:IsDestroyed() then
    return
  end
  if self.flyMount then
    self.flyMount:Destroy()
    self.flyMount = nil
  end
  FightModel.Destroy(self)
end
FightSpectator.Commit()
return FightSpectator
