local MODULE_NAME = (...)
local Lplus = require("Lplus")
local SocialSpaceProfileMan = Lplus.Class(MODULE_NAME)
local def = SocialSpaceProfileMan.define
local ECSocialSpaceMan = Lplus.ForwardDeclare("ECSocialSpaceMan")
local ECSpaceMsgs = require("Main.SocialSpace.ECSpaceMsgs")
def.const("number").CACHE_LIFE_TIME = 120
def.field(ECSocialSpaceMan).m_spaceMan = nil
def.field("table").m_roleProfileCaches = nil
def.field("number").m_cacheTimerId = 0
local instance
def.static("=>", SocialSpaceProfileMan).Instance = function()
  if instance == nil then
    instance = SocialSpaceProfileMan()
  end
  return instance
end
def.method(ECSocialSpaceMan).Init = function(self, spaceMan)
  self.m_roleProfileCaches = nil
  self.m_spaceMan = spaceMan
end
def.method().Clear = function(self)
  self:FullClearCache()
end
def.method("userdata", "function").AsyncGetRoleProfile = function(self, roleId, callback)
  local cachedProfile = self:GetRoleProfileFromCache(roleId)
  if cachedProfile then
    _G.SafeCallback(callback, cachedProfile)
    return
  end
  self:ReqRoleProfile(roleId, callback)
end
def.method("userdata", "function").ReqRoleProfile = function(self, roleId, callback)
  local myRoleId = _G.GetMyRoleID()
  if roleId == myRoleId then
    local profile = self:GetSelfProfile()
    self:AddRoleProfileToCache(profile)
    _G.SafeCallback(callback, profile)
    return
  end
  local serverId = self.m_spaceMan:GetRoleServerId(roleId)
  if self.m_spaceMan:IsTheSameServerWithHost(serverId) then
    gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):ReqRoleInfo(roleId, function(roleInfo)
      local profile = self:CovertRoleInfoToProfile(roleInfo)
      self:AddRoleProfileToCache(profile)
      _G.SafeCallback(callback, profile)
    end)
  else
    self.m_spaceMan:Req_GetRoleProfile(roleId, function(data)
      local profile
      if data.retcode == 0 then
        profile = self:ParseRoleProfile(data.profile)
        self:AddRoleProfileToCache(profile)
      end
      _G.SafeCallback(callback, profile)
    end)
  end
end
def.method("=>", ECSpaceMsgs.ECRoleProfile).GetSelfProfile = function(self)
  local hp = self.m_spaceMan:GetHostPlayerInfos()
  local profile = ECSpaceMsgs.ECRoleProfile()
  profile.roleId = hp.roleId
  profile.name = hp.name
  profile.level = hp.level
  profile.prof = hp.occupation
  profile.gender = hp.gender
  profile.avatarId, profile.avatarFrameId = hp.avatarId, hp.avatarFrameId
  return profile
end
def.method("table", "=>", ECSpaceMsgs.ECRoleProfile).CovertRoleInfoToProfile = function(self, roleInfo)
  local profile = ECSpaceMsgs.ECRoleProfile()
  profile.roleId = roleInfo.roleId
  profile.name = roleInfo.name
  profile.level = roleInfo.level
  profile.prof = roleInfo.occupationId
  profile.gender = roleInfo.gender
  profile.avatarId, profile.avatarFrameId = roleInfo.avatarId, roleInfo.avatarFrameId
  return profile
end
def.method("table", "=>", ECSpaceMsgs.ECRoleProfile).ParseRoleProfile = function(self, rawData)
  local profile = ECSpaceMsgs.ECRoleProfile()
  profile.roleId = Int64.ParseString(rawData.roleId)
  profile.name = rawData.roleName
  profile.level = tonumber(rawData.level) or 0
  profile.prof = tonumber(rawData.prof) or 0
  profile.gender = tonumber(rawData.gender) or 0
  profile.avatarId, profile.avatarFrameId = ECSpaceMsgs.ParsePhoto(rawData.photoId)
  return profile
end
def.method("table", "=>", "table").AddRoleProfileToCache = function(self, profile)
  local roleId = profile.roleId
  local profileCache = {}
  profileCache.profile = profile
  profileCache.expireTime = self:GetCacheExpireTimeFromNow()
  self.m_roleProfileCaches = self.m_roleProfileCaches or {}
  self.m_roleProfileCaches[tostring(roleId)] = profileCache
  self:RevokeCacheTimer()
  return profileCache
end
def.method("=>", "number").GetCacheExpireTimeFromNow = function(self)
  local curTime = _G.GetServerTime()
  return self:GetCacheExpireTime(curTime)
end
def.method("number", "=>", "number").GetCacheExpireTime = function(self, beginTime)
  return beginTime + SocialSpaceProfileMan.CACHE_LIFE_TIME
end
def.method("userdata", "=>", "table").GetRoleProfileFromCache = function(self, roleId)
  if self.m_roleProfileCaches == nil then
    return nil
  end
  local profileCache = self.m_roleProfileCaches[tostring(roleId)]
  if profileCache == nil then
    return nil
  end
  return profileCache.profile
end
def.method().RevokeCacheTimer = function(self)
  if self.m_cacheTimerId ~= 0 then
    return
  end
  self.m_cacheTimerId = GameUtil.AddGlobalTimer(1, false, function()
    self:CheckAndClearCache()
  end)
end
def.method().CheckAndClearCache = function(self)
  if self.m_roleProfileCaches == nil then
    return
  end
  local curTime = _G.GetServerTime()
  local toBeReomvedKeys = {}
  for key, cache in pairs(self.m_roleProfileCaches) do
    if curTime >= cache.expireTime then
      table.insert(toBeReomvedKeys, key)
    end
  end
  for i, key in ipairs(toBeReomvedKeys) do
    self.m_roleProfileCaches[key] = nil
  end
  if table.nums(self.m_roleProfileCaches) == 0 then
    self:FullClearCache()
  end
end
def.method().FullClearCache = function(self)
  self.m_roleProfileCaches = nil
  self:RemoveCacheTimer()
end
def.method().RemoveCacheTimer = function(self)
  if self.m_cacheTimerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.m_cacheTimerId)
    self.m_cacheTimerId = 0
  end
end
return SocialSpaceProfileMan.Commit()
