local Lplus = require("Lplus")
local LoginQueueMgr = Lplus.Class("LoginQueueMgr")
local LoginModule = Lplus.ForwardDeclare("LoginModule")
local LoginUtility = require("Main.Login.LoginUtility")
local def = LoginQueueMgr.define
def.field("number").numBeforeMe = 0
def.field("number").totalNum = 0
def.field("number").offlineNum = 0
def.field("table").remainTime = nil
local instance
def.static("=>", LoginQueueMgr).Instance = function()
  if instance == nil then
    instance = LoginQueueMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.SLoginQueueInfo", LoginQueueMgr.OnSLoginQueueInfo)
end
def.method("=>", "table").CalcRemainTime = function(self)
  local sec = LoginUtility.GetServerCfgConsts("OFFLINE_PERSON_IN_TIME_SEC")
  local a = self.offlineNum
  if self.offlineNum <= 0 then
    a = 1
  end
  local remainSec = self.numBeforeMe * sec / a
  local t = {
    remainSec = remainSec,
    isAccurately = self.offlineNum > 0 and true or false
  }
  return t
end
def.static("table").OnSLoginQueueInfo = function(p)
  gmodule.network.resumeProtocolUpdate()
  instance.numBeforeMe = p.waitNum
  instance.offlineNum = p.offlineNum or 0
  instance.totalNum = p.totalNum or p.waitNum
  instance.remainTime = instance:CalcRemainTime()
  Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_QUEUE_INFO_UPDATE, {self})
end
LoginQueueMgr.Commit()
return LoginQueueMgr
