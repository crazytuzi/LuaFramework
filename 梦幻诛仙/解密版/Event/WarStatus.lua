local Lplus = require("Lplus")
local WarStatus = Lplus.Class("WarStatus")
local def = WarStatus.define
def.const("table").Step = {
  None = 0,
  Start = 1,
  Doing = 2,
  Stop = 3
}
def.field("number").status = 0
def.field("number").attack = 0
def.field("number").defence = 0
def.field("number").flag = 0
def.static("number", "number", "number", "number", "=>", WarStatus).new = function(status, attack, defence, flag)
  local obj = WarStatus()
  obj.status = status
  obj.attack = attack
  obj.defence = defence
  obj.flag = flag
  return obj
end
def.method("=>", "string").debugStr = function(self)
  return string.format("NationWar: %s(%d)==>>%s(%d),status(%d),flag(%d)", self.attack > 0 and StringTable.Get(15 + self.attack - 1) or "", self.attack, 0 < self.defence and StringTable.Get(15 + self.defence - 1) or "", self.defence, self.status, self.flag)
end
WarStatus.Commit()
return WarStatus
