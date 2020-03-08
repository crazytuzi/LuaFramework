local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local AagrUtils = require("Main.Aagr.AagrUtils")
local BallInfo = Lplus.Class(CUR_CLASS_NAME)
local def = BallInfo.define
def.field("userdata").roleId = nil
def.field("table").status = nil
def.field("number").coolTime = 0
def.final("userdata", "table", "number", "=>", BallInfo).New = function(roleId, status, coolTime)
  local ballInfo = BallInfo()
  ballInfo.roleId = roleId
  ballInfo.status = status
  ballInfo.coolTime = coolTime
  return ballInfo
end
def.method("table").SyncStatus = function(self, status)
  self.status = status
end
def.method("number").SyncCoolTime = function(self, coolTime)
  warn("[BallInfo:SyncCoolTime] coolTime:", Int64.tostring(self.roleId), os.date("%c", coolTime))
  self.coolTime = coolTime
end
def.method("number", "=>", "boolean").CheckState = function(self, state)
  local result = false
  if self.status then
    result = AagrUtils.CheckBallState(state, self.status.states)
  end
  return result
end
def.method("=>", "number").GetLevel = function(self)
  if self.status then
    return self.status.level
  else
    return 0
  end
end
def.method("=>", "number").GetGene = function(self)
  if self.status then
    return self.status.gene
  else
    return 0
  end
end
def.method("=>", "table").GetStates = function(self)
  if self.status then
    return self.status.states
  else
    return nil
  end
end
def.method("=>", "table").GetStatus = function(self)
  return self.status
end
def.method().ClearStatus = function(self)
  self.status = nil
end
return BallInfo.Commit()
