local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local SocialSpaceModule = Lplus.Extend(ModuleBase, MODULE_NAME)
local def = SocialSpaceModule.define
local Network = require("netio.Network")
local ECGame = require("Main.ECGame")
local ECSocialSpaceMan = require("Main.SocialSpace.ECSocialSpaceMan")
local ECSocialSpaceCosMan = require("Main.SocialSpace.ECSocialSpaceCosMan")
local ECSocialSpaceConfig = require("Main.SocialSpace.ECSocialSpaceConfig")
local SocialSpaceSettingMan = require("Main.SocialSpace.SocialSpaceSettingMan")
local SocialSpaceProtocol = require("Main.SocialSpace.SocialSpaceProtocol")
local SocialSpaceFocusMan = require("Main.SocialSpace.SocialSpaceFocusMan")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local instance
def.static("=>", SocialSpaceModule).Instance = function()
  if instance == nil then
    instance = SocialSpaceModule()
  end
  return instance
end
def.override().Init = function(self)
  self:InitSSPConfig()
  SocialSpaceProtocol.Init()
  ECSocialSpaceCosMan.Instance():InitCache()
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, SocialSpaceModule.OnFeatureOpenInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, SocialSpaceModule.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, SocialSpaceModule.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, SocialSpaceModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD_STAGE, SocialSpaceModule.OnLeaveWorldStage)
  Event.RegisterEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.ReqFocusOnMsg, SocialSpaceModule.OnReqFocusOnMsg)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, SocialSpaceModule.OnHeroLevelUp)
end
def.method().InitSSPConfig = function(self)
  local sspConfig
  do
    local DirVersionXMLHelper = require("Common.DirVersionXMLHelper")
    local doc = DirVersionXMLHelper.GetXmlDoc()
    if doc == nil then
    else
      for i, elem in ipairs(doc.root.el) do
        if elem.name == "social_space" then
          sspConfig = {}
          sspConfig.address = elem.attr.address
          sspConfig.key = elem.attr.key
          break
        end
      end
    end
  end
  sspConfig = sspConfig or {}
  require("Main.SocialSpace.SSRequestBase").SetSSPConfig(sspConfig)
end
def.method("=>", "boolean", "string").IsOpen = function(self)
  if not self:IsFeatureOpen() then
    return false, textRes.SocialSpace[21]
  end
  local heroProp = _G.GetHeroProp()
  if heroProp == nil then
    return false, "hero prop error"
  end
  local openLevel = ECSocialSpaceConfig.getOpenLevelLimit()
  if openLevel > heroProp.level then
    return false, textRes.SocialSpace[22]:format(openLevel)
  end
  return true, "ok"
end
def.method("=>", "boolean").IsFeatureOpen = function(self)
  local isFeatureOpen = _G.IsFeatureOpen(Feature.TYPE_FRIENDS_CIRCLE)
  return isFeatureOpen
end
def.method().EnterSelfSpace = function(self)
  self:EnterSpace(_G.GetMyRoleID())
end
def.method("userdata").EnterSpace = function(self, ownerId)
  self:EnterSpaceWithParams({roleId = ownerId})
end
def.method("table").EnterSpaceWithParams = function(self, params)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local roleId = params.roleId
  if roleId == nil then
    roleId = _G.GetMyRoleID()
  end
  if roleId == _G.GetMyRoleID() then
    if self:CheckSelfSpaceOpenConditions() == false then
      return
    end
  elseif self:CheckOtherSpaceOpenConditions() == false then
    return
  end
  params.roleId = roleId
  ECSocialSpaceMan.Instance():EnterSpaceWithParams(params)
end
def.method("=>", "boolean").CheckSelfSpaceOpenConditions = function(self)
  local isOpen, reason = self:IsOpen()
  if not isOpen then
    Toast(reason)
    return false
  end
  return true
end
def.method("=>", "boolean").CheckOtherSpaceOpenConditions = function(self)
  if not self:IsFeatureOpen() then
    Toast(textRes.SocialSpace[21])
    return false
  end
  return true
end
def.method("string", "=>", "boolean").SendPhotoToSpace = function(self, photoPath)
  local isAvailable, msg = self:IsUploadPictureAvailable()
  if not isAvailable then
    Toast(msg)
    return false
  end
  if not _G.FileExists(photoPath) then
    Toast(textRes.SocialSpace[120])
    return false
  end
  local tempPhotoPath = ECSocialSpaceCosMan.Instance():GetPictureTempPath()
  GameUtil.CreateDirectoryForFile(tempPhotoPath)
  local cos_cfg = ECSocialSpaceCosMan.Instance():GetCosCfg()
  local ret, tempPhotoPath = ECSocialSpaceCosMan.Instance():CutImage(photoPath, tempPhotoPath, cos_cfg.upload_quality, cos_cfg.upload_image_size_limit)
  local function onSpacePanelReady(panel)
    local panel = require("Main.SocialSpace.ui.SpacePublishPicturePanel").Instance()
    panel:ShowPanel({tempPhotoPath}, nil)
  end
  self:EnterSpaceWithParams({onPanelReady = onSpacePanelReady})
  return true
end
def.method("=>", "boolean", "string").IsUploadPictureAvailable = function(self)
  local isOpen, msg = self:IsOpen()
  if not isOpen then
    return false, msg
  end
  local SocialSpaceUtils = require("Main.SocialSpace.SocialSpaceUtils")
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if not _G.IsFeatureOpen(Feature.TYPE_UPLOAD_PICTURE) then
    return false, textRes.SocialSpace[45]
  end
  local isSupported, msg = ECSocialSpaceMan.Instance():IsUploadPictureSupported()
  if not isSupported then
    return false, msg
  end
  return true, "ok"
end
def.method("=>", "number").GetSelfSpaceUnreadMsgNum = function(self)
  local setting = SocialSpaceSettingMan.GetSpaceSetting()
  if setting.remindNewMsg == SocialSpaceSettingMan.SETTING_DISABLE then
    return 0
  end
  return ECSocialSpaceMan.Instance():GetUnreadMsgCount()
end
def.method("boolean", "=>", "boolean").IsDecorateFeatureOpen = function(self, bToast)
  local _Toast = Toast
  local function Toast(content)
    if bToast then
      _Toast(content)
    end
  end
  local isOpen, reason = self:IsOpen()
  if not isOpen then
    Toast(reason)
    return false
  end
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if not _G.IsFeatureOpen(Feature.TYPE_FRIENDS_CIRCLE_ORNAMENT) then
    Toast(textRes.SocialSpace[71])
    return false
  end
  return true
end
def.method("userdata").UseDecorateItem = function(self, item_uuid)
  if not self:IsDecorateFeatureOpen(true) then
    return
  end
  ECSocialSpaceMan.Instance():UseDecorateItem(item_uuid)
end
def.method("number", "=>", "boolean").HasDecorationQueryByItemId = function(self, itemId)
  return ECSocialSpaceMan.Instance():HasDecorationQueryByItemId(itemId)
end
def.method("userdata", "function", "table").LoadSpaceData = function(self, roleId, callback, extra)
  ECSocialSpaceMan.Instance():LoadSpaceData(roleId, callback, extra)
end
def.method("=>", "boolean").IsFocusFeatureOpen = function(self)
  if _G.IsFeatureOpen(Feature.TYPE_FRIENDS_CIRCLE_PAY_ATTENTION) then
    return true
  end
  return false
end
def.method("=>", "boolean").HasFocusListInited = function(self)
  return SocialSpaceFocusMan.Instance():HasFocusListInited()
end
def.method("=>", "boolean").IsFocusOpen = function(self)
  if not self:IsOpen() then
    return false
  end
  if not self:IsFocusFeatureOpen() then
    return false
  end
  return true
end
def.method("=>", "boolean").IsFocusAvailable = function(self)
  if not self:IsFocusOpen() then
    return false
  end
  if not self:HasFocusListInited() then
    return false
  end
  return true
end
def.method("=>", "boolean").CheckAndInitFocusList = function(self)
  if SocialSpaceFocusMan.Instance():HasFocusListInited() then
    return true
  end
  if self:IsFocusOpen() then
    SocialSpaceFocusMan.Instance():InitFocusList()
  end
  return false
end
def.method("userdata", "=>", "boolean").HasFocusOnRole = function(self, roleId)
  return SocialSpaceFocusMan.Instance():HasFocusOnRole(roleId)
end
def.method("userdata").ReqAddFocusOnRole = function(self, roleId)
  SocialSpaceFocusMan.Instance():ReqAddFocusOnRole(roleId)
end
def.method("userdata").ReqDelFocusOnRole = function(self, roleId)
  SocialSpaceFocusMan.Instance():ReqDelFocusOnRole(roleId)
end
def.method("userdata").ReqChangeFocusOnRole = function(self, roleId)
  SocialSpaceFocusMan.Instance():ReqChangeFocusOnRole(roleId)
end
def.static("table", "table").OnFeatureOpenInit = function(params, context)
  ECSocialSpaceMan.Instance():OnInit()
end
def.static("table", "table").OnFeatureOpenChange = function(params, context)
  local switchId = params.feature
  if switchId == Feature.TYPE_FRIENDS_CIRCLE then
    instance:CheckAndInitFocusList()
  elseif switchId == Feature.TYPE_FRIENDS_CIRCLE_PAY_ATTENTION then
    instance:CheckAndInitFocusList()
    Event.DispatchEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.FocusFeatureChanged, nil)
  end
end
def.static("table", "table").OnEnterWorld = function(params, context)
end
def.static("table", "table").OnLeaveWorld = function(params, context)
  SocialSpaceProtocol.Clear()
  ECSocialSpaceMan.Instance():OnLeaveWorldClear()
end
def.static("table", "table").OnLeaveWorldStage = function(params, context)
  ECSocialSpaceMan.Instance():OnLeaveWorldStageClear()
end
def.static("table", "table").OnReqFocusOnMsg = function(params, context)
  local roleId = Int64.ParseString(params[1])
  local msgId = Int64.ParseString(params[2])
  instance:EnterSpaceWithParams({roleId = roleId, msgId = msgId})
end
def.static("table", "table").OnHeroLevelUp = function(params, context)
  instance:CheckAndInitFocusList()
end
return SocialSpaceModule.Commit()
