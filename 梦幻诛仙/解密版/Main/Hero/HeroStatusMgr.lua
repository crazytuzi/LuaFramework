local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local HeroStatusMgr = Lplus.Class(CUR_CLASS_NAME)
local def = HeroStatusMgr.define
_G.HeroStatusAction = {ADD = 1, DEL = 2}
_G.HeroStatusEnum = require("netio.protocol.mzm.gsp.status.StatusEnum")
local HeroStatusAction = _G.HeroStatusAction
def.field("table")._statusSet = nil
local instance
def.static("=>", HeroStatusMgr).Instance = function()
  if instance == nil then
    instance = HeroStatusMgr()
  end
  return instance
end
def.method().Init = function(self)
  self._statusSet = {}
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, HeroStatusMgr._OnLeaveWorld)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.status.SStatusTipRes", HeroStatusMgr._OnSStatusTipRes)
end
def.method("number", "=>", "boolean").HaveStatus = function(self, status)
  return self._statusSet[status] ~= nil
end
def.method("=>", "table").GetStatusList = function(self)
  local list = {}
  for status, _ in pairs(self._statusSet) do
    table.insert(list, status)
  end
  return list
end
def.static("table")._OnSStatusTipRes = function(p)
  local ProtocolErrorCode = require("netio.protocol.mzm.gsp.status.ErrorCode")
  local retCode = p.ret
  if retCode == ProtocolErrorCode.ST_STATUS_ROAM_SERVER_NOT_DO_THIS then
    return
  end
  local text = textRes.HeroStatus.ErrorCode[retCode]
  if text == nil then
    text = textRes.HeroStatus.ErrorCode[0]
    warn(text .. "(unhandled error code " .. retCode .. ")")
  end
  Toast(text)
end
def.static("table", "table")._OnLeaveWorld = function(p)
  local self = instance
  self._statusSet = {}
end
return HeroStatusMgr.Commit()
