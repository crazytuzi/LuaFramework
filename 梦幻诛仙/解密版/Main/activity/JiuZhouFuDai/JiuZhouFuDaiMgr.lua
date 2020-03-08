local Lplus = require("Lplus")
local JiuZhouFuDaiMgr = Lplus.Class("JiuZhouFuDaiMgr")
local def = JiuZhouFuDaiMgr.define
local instance
def.static("=>", JiuZhouFuDaiMgr).Instance = function()
  if instance == nil then
    instance = JiuZhouFuDaiMgr()
  end
  return instance
end
def.const("table").DrawType = {SINGLE = 1, TEN = 2}
local ACT_ID = constant.CLuckyBagCfgConsts.ACTIVITY_CFG_ID
def.field("boolean")._bServerState = false
def.field("number")._lastFudaiType = 0
def.method("=>", "boolean").IsOpen = function(self)
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local open = _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_LUCKY_BAG)
  return open
end
def.method("=>", "boolean").IsActOpen = function(self)
  local ActivityInterface = require("Main.activity.ActivityInterface")
  return ActivityInterface.Instance():isActivityOpend(ACT_ID)
end
def.method("=>", "boolean").GetServerState = function(self)
  return self._bServerState
end
def.method("boolean").SetServerState = function(self, value)
  self._bServerState = value
end
def.method("table").OnSMapCommonResult = function(self, p)
  require("Main.activity.JiuZhouFuDai.FuDaiProtocols").OnSMapCommonResult(p)
end
def.method("=>", "number").GetLastFudaiType = function(self)
  return self._lastFudaiType
end
def.method("number").SetLastFudaiType = function(self, value)
  self._lastFudaiType = value
end
return JiuZhouFuDaiMgr.Commit()
