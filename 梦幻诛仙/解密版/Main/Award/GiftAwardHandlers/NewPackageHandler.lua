local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local NewPackageHandler = Lplus.Class(AwardMgrBase, CUR_CLASS_NAME)
local GiftAwardMgr = require("Main.Award.mgr.GiftAwardMgr")
local UseType = require("consts.mzm.gsp.giftaward.confbean.UseType")
local def = NewPackageHandler.define
local AWARD_USE_TYPE = UseType.NEW_CLIENT_BAG_170628
local AWARD_CLIENT_VERSION = 123
local instance
def.static("=>", NewPackageHandler).Instance = function()
  if instance == nil then
    instance = NewPackageHandler()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, NewPackageHandler.OnEnterWorld)
end
def.method("=>", "number").GetAwardClientVersion = function(self)
  return AWARD_CLIENT_VERSION
end
def.static("table", "table").OnEnterWorld = function(params)
  local enterType = params and params.enterType
  if enterType == _G.EnterWorldType.RECONNECT then
    return
  end
  local programVersion, versionName, version3 = GameUtil.GetProgramCurrentVersionInfo()
  local programVersion = tonumber(programVersion)
  if programVersion ~= AWARD_CLIENT_VERSION then
    return
  end
  GiftAwardMgr.Instance():DrawAward(AWARD_USE_TYPE)
end
return NewPackageHandler.Commit()
