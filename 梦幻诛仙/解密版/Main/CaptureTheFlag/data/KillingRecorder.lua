local Lplus = require("Lplus")
local KillingRecorder = Lplus.Class("KillingRecorder")
local def = KillingRecorder.define
def.field("table").roleData = nil
def.static("=>", KillingRecorder).new = function()
  local recorder = KillingRecorder()
  recorder.roleData = {}
  return recorder
end
def.method("userdata", "table").SetKillData = function(self, roleId, info)
  self.roleData[roleId:tostring()] = {
    kill = info.killCount,
    die = info.dieCount,
    respawn = info.reviveTime
  }
end
def.method("userdata", "userdata", "number").RecordKill = function(self, killer, victim, respawn)
  self:AddKill(killer)
  self:AddDie(victim, respawn)
end
def.method("userdata").AddKill = function(self, roleId)
  if self.roleData[roleId:tostring()] then
    local rd = self.roleData[roleId:tostring()]
    rd.kill = rd.kill + 1
  else
    self.roleData[roleId:tostring()] = {
      kill = 1,
      die = 0,
      respawn = 0
    }
  end
end
def.method("userdata", "number").AddDie = function(self, roleId, respawn)
  if self.roleData[roleId:tostring()] then
    local rd = self.roleData[roleId:tostring()]
    rd.die = rd.die + 1
    rd.respawn = respawn
  else
    self.roleData[roleId:tostring()] = {
      kill = 0,
      die = 1,
      respawn = respawn
    }
  end
end
def.method("userdata", "=>", "table").GetInfo = function(self, roleId)
  if self.roleData[roleId:tostring()] then
    return self.roleData[roleId:tostring()]
  else
    return {
      kill = 0,
      die = 0,
      respawn = 0
    }
  end
end
def.method("=>", "table").Tick = function(self)
  local respawnRole = {}
  local curTime = GetServerTime()
  for k, v in pairs(self.roleData) do
    if v.respawn > 0 and curTime >= v.respawn then
      table.insert(respawnRole, k)
      v.respawn = 0
    end
  end
  return respawnRole
end
return KillingRecorder.Commit()
