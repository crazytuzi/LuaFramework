local Lplus = require("Lplus")
local FightTeam = Lplus.Class("FightTeam")
local FightUnit = Lplus.ForwardDeclare("FightUnit")
local def = FightTeam.define
def.field("number").fightTeamType = 0
def.field("table").fighters = nil
def.field("number").teamId = 0
def.field("number").formation = 0
def.field("number").formationLevel = 1
def.field("table").formationInfo = nil
def.final("=>", FightTeam).new = function()
  local obj = FightTeam()
  obj.fighters = {}
  return obj
end
def.method(FightUnit).AddFightUnit = function(self, unit)
  self.fighters[unit.id] = unit
end
def.method("number", "=>", "boolean").IsInTeam = function(self, id)
  return self.fighters[id] ~= nil
end
def.method("number", "=>", FightUnit).GetFightUnit = function(self, id)
  return self.fighters[id]
end
def.method("number").RemoveMember = function(self, unitid)
  self.fighters[unitid] = nil
end
def.method("number", "=>", FightUnit).GetFightUnitByPos = function(self, pos)
  for _, v in pairs(self.fighters) do
    if v.pos == pos then
      return v
    end
  end
  return nil
end
def.method("=>", "table").GetAllMembers = function(self)
  return self.fighters
end
def.method("number", "=>", "number").GetFightUnitIdx = function(self, id)
  local idx = 0
  local k, unit
  while true do
    idx = idx + 1
    k, unit = next(self.fighters, k)
    if k == id or k == nil then
      break
    end
  end
  return idx
end
return FightTeam.Commit()
