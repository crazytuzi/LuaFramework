local Lplus = require("Lplus")
local CrossBattleFightInfo = Lplus.Class("CrossBattleFightInfo")
local def = CrossBattleFightInfo.define
def.field("userdata").corpsAId = nil
def.field("number").corpsAState = 0
def.field("userdata").corpsBId = nil
def.field("number").corpsBState = 0
def.field("number").calFightState = 0
def.field("userdata").fightRecordId = nil
def.method("table").RawSet = function(self, p)
  self.corpsAId = p.corps_a_id
  self.corpsAState = p.corps_a_state
  self.corpsBId = p.corps_b_id
  self.corpsBState = p.corps_b_state
  self.calFightState = p.cal_fight_result
  self.fightRecordId = p.record_id
end
def.method("=>", "userdata").GetCorpsAId = function(self)
  return self.corpsAId
end
def.method("=>", "number").GetCorpsAState = function(self)
  return self.corpsAState
end
def.method("=>", "userdata").GetCorpsBId = function(self)
  return self.corpsBId
end
def.method("=>", "number").GetCorpsBState = function(self)
  return self.corpsBState
end
def.method("=>", "number").GetCalFightState = function(self)
  return self.calFightState
end
def.method("=>", "userdata").GetFightRecordId = function(self)
  return self.fightRecordId
end
CrossBattleFightInfo.Commit()
return CrossBattleFightInfo
