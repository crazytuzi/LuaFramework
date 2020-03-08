local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local PubroleAt = Lplus.Extend(PubroleOperationBase, "PubroleAt")
local def = PubroleAt.define
def.override("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  local AtMgr = require("Main.Chat.At.AtMgr")
  if AtMgr.Instance():IsOpen(false) and roleInfo and roleInfo.bNeedAt then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Chat.At.PUBROLE_OPERATION_NAME
end
def.override("table", "=>", "boolean").Operate = function(self, roleInfo)
  local AtUtils = require("Main.Chat.At.AtUtils")
  AtUtils.AddAtInfoPack(roleInfo)
  return true
end
PubroleAt.Commit()
return PubroleAt
