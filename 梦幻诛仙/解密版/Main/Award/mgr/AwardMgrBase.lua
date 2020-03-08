local Lplus = require("Lplus")
local AwardMgrBase = Lplus.Class("AwardMgrBase")
local def = AwardMgrBase.define
def.virtual("=>", "boolean").IsHaveNotifyMessage = function(self)
  return false
end
def.virtual("=>", "number").GetNotifyMessageCount = function(self)
  return 0
end
def.virtual("=>", "boolean").IsOpen = function(self)
  return true
end
return AwardMgrBase.Commit()
