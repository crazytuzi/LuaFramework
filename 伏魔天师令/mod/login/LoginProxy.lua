local LoginProxy = classGc(function(self)
    self.m_serverId      = -1
    self.m_serverList    = {}
    self.m_serverNameList= {}
    self:resetGameData()
end)

function LoginProxy.setUid(self, _uid)
    self._uid=_uid
    -- CUserCache:sharedUserCache():setObject("uid", tostring(_uid))
end
function LoginProxy.getUid(self)
    return self._uid
end

function LoginProxy.setServerId(self, _sid)
    self.m_serverId = tonumber(_sid)
    -- CUserCache:sharedUserCache():setObject("sid", tostring(_sid))
end
function LoginProxy.getServerId(self)
    return self.m_serverId
end

function LoginProxy.setServerList(self,_list)
    if _list == nil then return end

    self.m_serverList = {}
    self.m_serverNameList = {}
    for i,oneServerData in ipairs(_list) do
        local sid=tonumber(oneServerData.s)
        self.m_serverList[sid] = oneServerData
        self.m_serverNameList[sid] = oneServerData.n
    end
end
function LoginProxy.getServerList(self)
    return self.m_serverList
end
function LoginProxy.getServerData(self,_sid)
    if self.m_serverList==nil or _sid==nil then return nil end

    return self.m_serverList[_sid]
end
function LoginProxy.getCurServerData(self)
    return self:getServerData(self.m_serverId)
end
function LoginProxy.getServerName(self,_sid)
    local sid=_sid or self.m_serverId
    return self.m_serverNameList[sid] or [[nil]]
end
function LoginProxy.getServerNameList(self)
    return self.m_serverNameList
end
function LoginProxy.addServerName(self,_sid,_name)
    if _sid and _name then
        self.m_serverNameList[_sid]=_name
    end
end

--是否第一次登陆   默认否
function LoginProxy.setFirstLogin( self, _bool )
    self._isFirstLogin = _bool
end
function LoginProxy.getFirstLogin( self )
    return self._isFirstLogin
end
function LoginProxy.isLoginCity(self)
    return self.m_isLoginCity
end
function LoginProxy.loginCity(self)
    self.m_isLoginCity=true
end

function LoginProxy.setRoleMediator(self,_view)
    if self._mediator==nil then
        self._mediator=require("mod.login.LoginMediator")()
    end
    self._mediator._roleView=_view
    print("setRoleMediator-->",_view)
end
function LoginProxy.setCreateMediator(self,_view)
    if self._mediator==nil then
        self._mediator=require("mod.login.LoginMediator")()
    end
    self._mediator._createView=_view
    print("setCreateMediator-->",_view)
end
function LoginProxy.clearMediator(self)
    if self._mediator~=nil then
        self._mediator:destroy()
        self._mediator=nil
    end
end

function LoginProxy.resetGameData(self)
    self._uid           = 0
    self._isFirstLogin  = false
    self._mediator      = nil
end

return LoginProxy
