local CacheLoginData = class("CacheLoginData")
function CacheLoginData:ctor() 
    self._userId = 0
    self._user = nil
    self._serverId = ""
    self._userCacheStartTime = 0
end


function CacheLoginData:setBaseData(user) 
    self._user = user 
    self._userId = user.id
    self._serverId = G_PlatformProxy:getLoginServer().id
    self._userCacheStartTime =  FuncHelperUtil:getCurrentTime()
end

function CacheLoginData:hasBaseData() 

    if G_Me and G_Me.userData and G_Me.userData.id == self._userId and self._userId  ~= 0
        and tostring(self._serverId) == tostring(G_PlatformProxy:getLoginServer().id) 
        and (FuncHelperUtil:getCurrentTime() - self._userCacheStartTime) < 60  then
        --cache for 2 minutes
        return true
    end
    return false
end

function CacheLoginData:getBaseData() 
    if self:hasBaseData() then
        return self._user 
    end
    return nil
end

return CacheLoginData
