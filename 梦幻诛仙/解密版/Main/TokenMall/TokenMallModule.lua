local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local TokenMallModule = Lplus.Extend(ModuleBase, "TokenMallModule")
local TokenMallMgr = require("Main.TokenMall.mgr.TokenMallMgr")
local def = TokenMallModule.define
local instance
def.static("=>", TokenMallModule).Instance = function()
  if instance == nil then
    instance = TokenMallModule()
    instance.m_moduleId = ModuleId.TOKEN_MALL
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  TokenMallMgr.Instance():Init()
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, TokenMallModule.OnLeaveWorld)
end
def.static("table", "table").OnLeaveWorld = function(params, context)
  TokenMallMgr.Instance():Clear()
end
def.method("number").OpenTokenMallByActivityId = function(self, activityId)
  TokenMallMgr.Instance():OpenTokenMallByActivityId(activityId)
end
return TokenMallModule.Commit()
