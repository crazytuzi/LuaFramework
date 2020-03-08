local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local MonkeyRunOutData = Lplus.Class(CUR_CLASS_NAME)
local def = MonkeyRunOutData.define
def.field("number").index = 0
def.field("number").accumulateTurnCount = 0
def.field("number").ticketCount = 0
def.method("table").RawSet = function(self, p)
  self.index = p.index
  self.accumulateTurnCount = p.accumulateTurnCount
  self.ticketCount = p.ticketCount
end
def.method("=>", "number").GetCurrentGridIndex = function(self)
  return self.index
end
def.method("=>", "number").GetAccumulateTurnCount = function(self)
  return self.accumulateTurnCount
end
def.method("=>", "number").GetTicketCount = function(self)
  return self.ticketCount
end
def.method("number").SetTicketCount = function(self, ticketCount)
  self.ticketCount = ticketCount
end
return MonkeyRunOutData.Commit()
