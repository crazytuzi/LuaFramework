local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local AvatarModule = Lplus.Extend(ModuleBase, "AvatarModule")
local AvatarInterface = require("Main.Avatar.AvatarInterface")
local avatarInterface = AvatarInterface.Instance()
local def = AvatarModule.define
local instance
def.static("=>", AvatarModule).Instance = function()
  if instance == nil then
    instance = AvatarModule()
    instance.m_moduleId = ModuleId.AVATAR
  end
  return instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.avatar.SSyncAvatarInfo", AvatarModule.OnSSyncAvatarInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.avatar.SNotifyNewAvatar", AvatarModule.OnSNotifyNewAvatar)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.avatar.SSetAvatarSuccess", AvatarModule.OnSSetAvatarSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.avatar.SActivateAvatarSuccess", AvatarModule.OnSActivateAvatarSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.avatar.SSetAvatarFail", AvatarModule.OnSSetAvatarFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.avatar.SActivateAvatarFail", AvatarModule.OnSActivateAvatarFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.avatar.SNotifyExtendedAvatar", AvatarModule.OnSNotifyExtendedAvatar)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.avatar.SUseUnlockItemFail", AvatarModule.OnSUseUnlockItemFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.avatar.SNotifyExpiredAvatar", AvatarModule.OnSNotifyExpiredAvatar)
  require("Main.Avatar.AvatarFrameMgr").Instance():Init()
  ModuleBase.Init(self)
  avatarInterface.activeAvatarList = {}
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, AvatarModule.OnFunctionOpenChange)
end
def.override().OnReset = function(self)
  avatarInterface:Reset()
end
def.static("table").OnSSyncAvatarInfo = function(p)
  warn("------OnSSyncAvatarInfo\239\188\154", p.current_avatar, p.active_avatar)
  avatarInterface.curAvatarId = p.current_avatar
  avatarInterface.curAttrAvatarId = p.active_avatar
  avatarInterface.activeAvatarList = {}
  for i, v in pairs(p.unlocked_avatars) do
    avatarInterface:addActiveAvatarId(v)
    warn("------avatarInfo:", v.expire_time)
  end
  Event.DispatchEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Change, nil)
end
def.static("table").OnSNotifyNewAvatar = function(p)
  warn("---------OnSNotifyNewAvatar:", #p.new_avatars)
  local avatarId = 0
  for i, v in pairs(p.new_avatars) do
    avatarInterface:addActiveAvatarId(v)
    avatarInterface:addNewAvatarId(v.avatar)
    avatarId = v.avatar
  end
  Toast(textRes.Avatar[5])
  if avatarId > 0 and avatarId ~= avatarInterface.curAvatarId then
    local function callback(id)
      if id == 1 then
        local p = require("netio.protocol.mzm.gsp.avatar.CSetAvatarReq").new(avatarId)
        gmodule.network.sendProtocol(p)
      end
    end
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    local dlg = CommonConfirmDlg.ShowConfirm("", textRes.Avatar[22], callback, {})
    dlg.btn1 = textRes.Avatar[23]
  end
  Event.DispatchEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Get_New_Avatar, p.new_avatars)
end
def.static("table").OnSSetAvatarSuccess = function(p)
  warn("------OnSSetAvatarSuccess:", p.avatar)
  avatarInterface.curAvatarId = p.avatar
  avatarInterface:removeNewAvatarId(p.avatar)
  Event.DispatchEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Change, nil)
end
def.static("table").OnSSetAvatarFail = function(p)
  warn("-------OnSSetAvatarFail:", p.retcode)
  if p.retcode == p.EXPIRED then
    Toast(textRes.Avatar[3])
  end
end
def.static("table").OnSActivateAvatarSuccess = function(p)
  warn("-----OnSActivateAvatarSuccess:", p.avatar)
  avatarInterface.curAttrAvatarId = p.avatar
  Event.DispatchEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Attr_Change, nil)
end
def.static("table").OnSActivateAvatarFail = function(p)
  warn("---------OnSActivateAvatarFail\239\188\154", p.retcode)
  if p.retcode == p.EXPIRED then
    Toast(textRes.Avatar[3])
  end
end
def.static("table").OnSNotifyExtendedAvatar = function(p)
  for i, v in pairs(p.extended_avatars) do
    avatarInterface:addActiveAvatarId(v)
  end
  Toast(textRes.Avatar[6])
  Event.DispatchEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Extended_Success, p.extended_avatars)
end
def.static("table").OnSUseUnlockItemFail = function(p)
  if p.retcode == p.ALREADY_UNLOCKED then
    Toast(textRes.Avatar[2])
  elseif p.retcode == p.CANNOT_UNLOCK then
    Toast(textRes.Avatar[4])
  end
end
def.static("table").OnSNotifyExpiredAvatar = function(p)
  warn("-------OnSNotifyExpiredAvatar:", p.current_avatar, p.active_avatar)
  for i, v in pairs(p.expired_avatars) do
    avatarInterface:removeActiveAvatarId(v.avatar)
    avatarInterface:removeNewAvatarId(v.avatar)
  end
  if p.current_avatar ~= avatarInterface.curAvatarId then
    avatarInterface.curAvatarId = p.current_avatar
    Event.DispatchEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Change, nil)
  end
  if p.active_avatar ~= avatarInterface.curAttrAvatarId then
    avatarInterface.curAttrAvatarId = p.active_avatar
    Event.DispatchEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Attr_Change, nil)
  end
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  if p1.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_AVATAR then
    Event.DispatchEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Change, nil)
  end
end
return AvatarModule.Commit()
