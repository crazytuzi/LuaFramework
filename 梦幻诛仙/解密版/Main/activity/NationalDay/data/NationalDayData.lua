local Lplus = require("Lplus")
local NationalDayData = Lplus.Class("NationalDayData")
local def = NationalDayData.define
local _instance
def.field("table")._shareCfg = nil
def.field("table")._prayInfo = nil
def.field("table")._prayTimes = nil
def.field("table")._breakEggResult = nil
def.field("table")._breakEggRolelist = nil
def.field("table")._myInfo = nil
def.const("table").BREAK_EGG_PHASE = {
  NONE = 0,
  PREPARE = 1,
  PRE_PERFORM = 2,
  PERFORM = 3
}
def.field("number")._breakEggPhase = 0
def.field("boolean")._isInviter = true
def.static("=>", NationalDayData).Instance = function()
  if _instance == nil then
    _instance = NationalDayData()
  end
  return _instance
end
def.method().Init = function(self)
  self:Reset()
end
def.method().Reset = function(self)
  self._shareCfg = nil
  self._prayTimes = nil
  self._prayInfo = nil
  self:ResetBreakEggData()
end
def.method().ResetBreakEggData = function(self)
  self._breakEggResult = nil
  self._breakEggRolelist = nil
  self._breakEggPhase = 0
  self._isInviter = true
  self._myInfo = nil
end
def.method("number", "=>", "table").GetShareCfg = function(self, share_type)
  if self._shareCfg then
    return self._shareCfg
  end
  local AwardMgr = require("Main.Award.mgr.GiftAwardMgr")
  self._shareCfg = AwardMgr.Instance():GetGiftAwardCfg(share_type)
  return self._shareCfg
end
def.method("table").SetPrayTimes = function(self, tbl)
  if self._prayTimes == nil then
    self._prayTimes = {}
  end
  for k, v in pairs(tbl) do
    self._prayTimes[k] = v:ToNumber()
  end
end
def.method("=>", "table").GetPrayTimes = function(self)
  return self._prayTimes
end
def.method("table").SetPrayInfo = function(self, tbl)
  if self._prayInfo == nil then
    self._prayInfo = {}
  end
  for k, v in pairs(tbl) do
    self._prayInfo[k] = v
  end
end
def.method("=>", "table").GetPrayInfo = function(self)
  return self._prayInfo
end
def.method("table").SetBreakEggResult = function(self, tbl)
  if self._breakEggResult == nil then
    self._breakEggResult = {}
  end
  for k, v in pairs(tbl) do
    self._breakEggResult[k + 1] = v
  end
end
def.method("=>", "table").GetBreakEggResult = function(self)
  return self._breakEggResult
end
def.method("=>", "boolean").HasDone = function(self)
  if self._breakEggResult == nil then
    return false
  end
  local myId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
  for _, v in pairs(self._breakEggResult) do
    if v.role_id:eq(myId) then
      return true
    end
  end
  return false
end
def.method("table").SetBreakEggRolelist = function(self, tbl)
  self._breakEggRolelist = tbl
end
def.method("=>", "table").GetBreakEggRolelist = function(self)
  return self._breakEggRolelist
end
def.method("userdata", "=>", "table").GetBreakEggRole = function(self, roleId)
  if roleId == nil or self._breakEggRolelist == nil then
    return nil
  end
  for _, v in pairs(self._breakEggRolelist) do
    if v.roleId:eq(roleId) then
      return v
    end
  end
  return nil
end
def.method("=>", "table").GetMyRoleInfo = function(self)
  if self._myInfo then
    return self._myInfo
  end
  local myId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  local avatarInterface = require("Main.Avatar.AvatarInterface").Instance()
  self._myInfo = {}
  self._myInfo.roleId = myId
  self._myInfo.roleName = heroProp.name
  self._myInfo.gender = heroProp.gender
  self._myInfo.occupationId = heroProp.occupation
  self._myInfo.roleLevel = heroProp.level
  self._myInfo.avatarId = avatarInterface:getCurAvatarId()
  self._myInfo.avatarFrameId = avatarInterface:getCurAvatarFrameId()
  return self._myInfo
end
def.method("number").SetBreakEggPhase = function(self, phase)
  self._breakEggPhase = phase
end
def.method("=>", "number").GetBreakEggPhase = function(self)
  return self._breakEggPhase
end
def.method("boolean").SetIsInviter = function(self, val)
  self._isInviter = val
end
def.method("=>", "boolean").GetIsInviter = function(self)
  return self._isInviter
end
NationalDayData.Commit()
return NationalDayData
