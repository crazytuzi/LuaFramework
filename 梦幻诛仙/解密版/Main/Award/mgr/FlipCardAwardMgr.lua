local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local FlipCardAwardMgr = Lplus.Class(CUR_CLASS_NAME)
local FlipCardAwardData = import("..data.FlipCardAwardData")
local def = FlipCardAwardMgr.define
local CResult = {SUCCESS = 0}
def.const("table").CResult = CResult
def.field("table").dataQueue = nil
local instance
def.static("=>", FlipCardAwardMgr).Instance = function()
  if instance == nil then
    instance = FlipCardAwardMgr()
  end
  return instance
end
def.method().Init = function(self)
  self.dataQueue = {}
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.award.SSynMultiRoleAwardItemRes", FlipCardAwardMgr.OnSSynMultiRoleAwardItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.award.STakeSelectAwardRes", FlipCardAwardMgr.OnSTakeSelectAwardRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.award.SMutiRoleAwardEndRes", FlipCardAwardMgr.OnSMutiRoleAwardEndRes)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
end
def.method().Reset = function(self)
  self.dataQueue = {}
end
def.method("=>", FlipCardAwardData).GetCurAwardData = function(self)
  return self.dataQueue[1]
end
def.method("userdata", "=>", "boolean").IsCurAward = function(self, awardUUID)
  local data = self:GetCurAwardData()
  if data == nil then
    return false
  end
  return data.awardUUID:eq(awardUUID)
end
def.method("userdata", "=>", FlipCardAwardData).GetAwardData = function(self, awardUUID)
  for i, v in ipairs(self.dataQueue) do
    if v.awardUUID == awardUUID then
      return v
    end
  end
  return nil
end
def.method("=>", "boolean").HasDrew = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local data = self:GetCurAwardData()
  for i, roleid in ipairs(data.notAwardRoles) do
    if roleid == heroProp.id then
      return true
    end
  end
  for index, v in pairs(data.awarded) do
    if v.roleid == heroProp.id then
      return true
    end
  end
  return false
end
def.method("=>", "boolean").HasAllAwardGiven = function(self)
  local data = self:GetCurAwardData()
  if data == nil then
    return true
  end
  local count = table.nums(data.awarded)
  return count >= #data.roles
end
def.method("number", "=>").SelectAward = function(self, index)
  local awardUUID = self:GetCurAwardData().awardUUID
  self:CTakeMultiRoleAwardReq(awardUUID, index - 1)
end
def.method().MoveToNextAward = function(self)
  table.remove(self.dataQueue, 1)
  GameUtil.AddGlobalLateTimer(0, true, function(...)
    if #self.dataQueue > 0 and not _G.PlayerIsInFight() then
      Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.RECV_MULTI_ROLE_AWARD, nil)
    end
  end)
end
def.method("userdata", "number").CTakeMultiRoleAwardReq = function(self, awardUUID, index)
  warn("CTakeMultiRoleAwardReq", tostring(awardUUID), index)
  local p = require("netio.protocol.mzm.gsp.award.CTakeMultiRoleAwardReq").new(awardUUID, index)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSSynMultiRoleAwardItemRes = function(p)
  local data = FlipCardAwardData.new()
  data.awardUUID = p.awardUUid
  data.roles = p.roles
  data.notAwardRoles = p.notAwardRoles or {}
  table.insert(instance.dataQueue, data)
  if not _G.PlayerIsInFight() and instance:IsCurAward(p.awardUUid) then
    Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.RECV_MULTI_ROLE_AWARD, nil)
  else
    require("Main.Common.OutFightDo").Instance():Do(function()
      Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.RECV_MULTI_ROLE_AWARD, nil)
    end, nil)
  end
end
def.static("table").OnSTakeSelectAwardRes = function(p)
  local data = instance:GetAwardData(p.awardUUid)
  if data == nil then
    warn(string.format("award data not exist(awardUUID=%s)", tostring(p.awardUUid)), debug.traceback())
    return
  end
  local awardInfo = {
    index = p.index + 1,
    roleid = p.roleid,
    awardBean = p.awardBean
  }
  data.awarded[p.index + 1] = awardInfo
  if instance:IsCurAward(p.awardUUid) then
    Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.SYNC_TAKED_MULTI_ROLE_AWARD, {awardInfo})
  end
end
def.static("table").OnSMutiRoleAwardEndRes = function(p)
  local data = instance:GetAwardData(p.awardUUid)
  if data == nil then
    warn(string.format("award data not exist(awardUUID=%s)", tostring(p.awardUUid)), debug.traceback())
    return
  end
  local awardInfoList = {}
  for index, v in pairs(p.index2Award) do
    data.awarded[index + 1] = {
      index = index + 1,
      roleid = Int64.new(0),
      awardBean = v
    }
    table.insert(awardInfoList, data.awarded[index + 1])
  end
  if instance:IsCurAward(p.awardUUid) then
    Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.SYNC_NOT_TAKE_MULTI_ROLE_AWARD, {awardInfoList})
  end
end
return FlipCardAwardMgr.Commit()
