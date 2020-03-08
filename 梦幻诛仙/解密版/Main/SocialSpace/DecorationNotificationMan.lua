local MODULE_NAME = (...)
local Lplus = require("Lplus")
local DecorationNotificationMan = Lplus.Class(MODULE_NAME)
local def = DecorationNotificationMan.define
local LuaUserDataIO = require("Main.Common.LuaUserDataIO")
local SocialSpaceUtils = require("Main.SocialSpace.SocialSpaceUtils")
def.const("string").STORE_FILE_PATTERN = "SocialSpace/ReadedDecoNotifications/%s.lua"
def.field("table").m_readedNotifications = nil
def.field("string").m_storeFilePath = ""
def.field("dynamic").m_hasNewDecoNotification = nil
local instance
def.static("=>", DecorationNotificationMan).Instance = function()
  if instance == nil then
    instance = DecorationNotificationMan()
  end
  return instance
end
def.method().Clear = function(self)
  self.m_storeFilePath = ""
  self.m_readedNotifications = nil
  self.m_hasNewDecoNotification = nil
end
def.method("=>", "table").GetReadedNotifications = function(self)
  if self.m_readedNotifications == nil then
    local storeFilePath = self:GetStoreFilePath()
    local notifications = LuaUserDataIO.ReadUserData(storeFilePath)
    if notifications == nil then
      notifications = {}
    end
    self.m_readedNotifications = notifications
  end
  return self.m_readedNotifications
end
def.method("=>", "string").GetStoreFilePath = function(self)
  if self.m_storeFilePath == "" then
    local roleId = _G.GetMyRoleID()
    self.m_storeFilePath = string.format(DecorationNotificationMan.STORE_FILE_PATTERN, tostring(roleId))
  end
  return self.m_storeFilePath
end
def.method("=>", "boolean").HasNewDecoNotification = function(self)
  if self.m_hasNewDecoNotification ~= nil then
    return self.m_hasNewDecoNotification
  end
  local readedNotifications = self:GetReadedNotifications()
  local items = SocialSpaceUtils.GetAllNewDecorationItems()
  self.m_hasNewDecoNotification = false
  for i, v in ipairs(items) do
    if not readedNotifications[v.itemId] then
      self.m_hasNewDecoNotification = true
      break
    end
  end
  return self.m_hasNewDecoNotification
end
def.method("number", "=>", "boolean").HasNewDecoNotificationOnDecoType = function(self, decoType)
  if not self:HasNewDecoNotification() then
    return false
  end
  local readedNotifications = self:GetReadedNotifications()
  local items = SocialSpaceUtils.GetAllNewDecorationItems()
  for i, v in ipairs(items) do
    if v.decoType == decoType and not readedNotifications[v.itemId] then
      return true
    end
  end
  return false
end
def.method("number", "=>", "boolean").HasNewDecoNotificationOnItem = function(self, itemId)
  if not self:HasNewDecoNotification() then
    return false
  end
  local decoItemCfg = SocialSpaceUtils.GetDecorationItemCfg(itemId)
  if decoItemCfg == nil then
    return false
  end
  if not decoItemCfg.isNew then
    return false
  end
  local itemId = decoItemCfg.itemId
  local readedNotifications = self:GetReadedNotifications()
  if readedNotifications[itemId] then
    return false
  end
  return true
end
def.method().IgnoreAllNewDecoNotifications = function(self)
  if self.m_hasNewDecoNotification == false then
    return
  end
  local items = SocialSpaceUtils.GetAllNewDecorationItems()
  local readedNotifications = self:GetReadedNotifications()
  for i, v in ipairs(items) do
    readedNotifications[v.itemId] = true
  end
  local storeFilePath = self:GetStoreFilePath()
  LuaUserDataIO.WriteUserData(storeFilePath, "readedNotifications", readedNotifications)
  self.m_hasNewDecoNotification = false
  Event.DispatchEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.NewDecoNotificationChanged, nil)
end
return DecorationNotificationMan.Commit()
