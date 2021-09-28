local RoleService = class("RoleService")
local storage = require("app.storage.storage")



function RoleService:ctor()
    self._remoteList = {}

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_PLATFORM_LOGIN_OK, handler(self,self._onUpdateUuid), self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CREATED_ROLE, handler(self, self._onCreatedRole), self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FINISH_LOGIN, handler(self, self._onFinishLogin), self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_USER_LEVELUP, handler(self, self._onLevelUp), self)

end

function RoleService:_onUpdateUuid()
    if G_PlatformProxy:getYzuid() ~= "" then
        self:checkUpdateList() 
        
    else
        self._remoteList = {}
    end
end

function RoleService:_getDomain()
    if G_NativeProxy.platform == "windows" then
        -- return "http://192.168.1.187:8080"
        return "http://patch.n.m.youzu.com"
    else
        if LANG == "tw" then            
            return "http://sspatch.icantw.com"
        end
        return "http://patch.n.m.youzu.com"
    end
end

function RoleService:_onCreatedRole()
    self:add(G_Me.userData.name, 1, self:getBaseId())
end

function RoleService:_onFinishLogin()
    self:add(G_Me.userData.name, G_Me.userData.level, self:getBaseId(), true)
end

function RoleService:_onLevelUp()
    self:add(G_Me.userData.name, G_Me.userData.level, self:getBaseId())
end



function RoleService:getUuid()
    return tostring(G_PlatformProxy:getYzuid())
end

function RoleService:getBaseId()
    if G_Me and G_Me.bagData and G_Me.bagData.knightsData then
        local mainKnight = G_Me.bagData.knightsData:getMainKightInfo()
        local kid = mainKnight and mainKnight["base_id"] or 0
        return kid
    else
        return 0
    end
end



function RoleService:checkUpdateList()
    self:_getRemoteRoleList()
end





function RoleService:_getRemote(url, callback)
    if G_Setting:get('open_remote_role_history') ~= "1" then
        return
    end

    -- print("get rmote:" .. url)
    local request = uf_netManager:createHTTPRequestGet(url, function(event) 
        local request = event.request
        local errorCode = request:getErrorCode()

        if errorCode ~= 0 then
            --error..
            if callback then
                callback()
            end
            return
        end

        local response = request:getResponseString()
        -- print(response)
        local t=json.decode(response)
        if t then
            local ok = (event.name == "completed")
            if ok then
               
                if callback then
                   callback(t)
                end

            end
        else
           --error
           if callback then
               callback()
           end
        end

    end)
    request:start()

end

local function url_encode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w %-%_%.%~])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str    
end

function RoleService:_getRemoteRoleList()
 

    local url =  self:_generateUrl(string.format("%s/nconfig/services/role?action=list", self:_getDomain()), 
        {
            uuid =self:getUuid(),
        }
    )


    self:_getRemote(url, function(result)
        if result ~= nil and type(result) == "table" and #result > 0 then
            self._remoteList = result
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_UPDATE_ROLE_LIST, nil, false)

        end
        
    end
     )
end



function RoleService:getList()
    --merge local list and remote list
    -- if conflict, use   the higher level data
    local data = storage.load(storage.path("roles.history")  )
    if data == nil then
        data = {}
    end

    local list = {}
    local uuid = self:getUuid()
    local localData = data[uuid]
    if localData == nil then
        localData = {}
    end
    for sid, info in pairs(localData) do 
        table.insert(list, info)
    end
    for i, info in ipairs(self._remoteList) do 
        local sid = tostring(info.serverId)
        if localData[sid] == nil or localData[sid].level < info.level  then
           table.insert(list, info)  
        end
    end

    --sort by level desc
    local sortFunc = function(a,b)
        return a.level > b.level
    end
    table.sort(list, sortFunc)

    return list
end

function RoleService:add(role_name, level, baseid, checkLevel)
    local serverId = ""
    if G_PlatformProxy:getLoginServer() then
        serverId = tostring(G_PlatformProxy:getLoginServer().id)
    end
    local uuid = self:getUuid()
    local opId = G_PlatformProxy:getOpId()
    local device = G_PlatformProxy:getDeviceId()
    local info = {
        serverId = serverId,
        role_name = role_name,
        level = level,
        baseid = baseid,
        uuid = uuid,
        device = device,
        opId = opId,
    }

    --save in local and then send it to remote
    self:addLocal(info)
 
    if checkLevel then
        local ignore = false
        for i, v in ipairs(self._remoteList) do 

            if tostring(v.serverId) == info.serverId and tostring(v.uuid) == info.uuid and info.level <= v.level  then
               ignore = true
               break 
            end
        end
        if not ignore then
            self:addRemote(info)
        end
    else
        self:addRemote(info)
    end
    
end


function RoleService:addLocal(info)
    local data = storage.load(storage.path("roles.history")  )
    if data == nil then
        data = {}
    end
    if data[info.uuid] == nil then
        data[info.uuid]  = {}
    end
    data[info.uuid][info.serverId] = info
    storage.save(storage.path("roles.history") ,data)

end



function RoleService:_generateUrl(url, params)
    if string.find(url, "?") == nil then
        url = url .. "?" 
    else
        url = url .. "&" 
    end



    local keys = {
      "baseid",
      "level",
      "opId",
      "role_name",
      "serverId" ,
      "uuid",
    }



    local str = ""
    local sns = {}
    for i,v in ipairs(keys) do
        if params[v] ~= nil then
          table.insert(sns, v .. "=" .. params[v])
        end
    end
    local str = table.concat(sns, "&")
    str = str .. "ngamesuifengsb123456123"
    local sig = require("framework.crypto").md5(str)

    --uuid, role_name, device need url encode


    local params_str = {}
    for k,v in pairs(params) do 
        if k == "uuid" or k == "role_name" or k == "device"  then
            v = url_encode(v)
        end
        table.insert(params_str, k .. "=" .. tostring(v) )
    end
    table.insert(params_str, "sig=" .. sig )

    local gurl = url .. table.concat( params_str, "&")


    return gurl

end   

function RoleService:addRemote(info)   

    local url =  self:_generateUrl(string.format("%s/nconfig/services/role?action=add", self:_getDomain()), 
        {
            uuid = info.uuid,
            serverId = info.serverId,
            role_name = info.role_name,
            baseid = info.baseid,
            device = info.device,
            opId = info.opId,
            level = info.level
        }
    )

    -- string.format("%s/nconfig/services/role?action=add&uuid=%s&serverId=%s&role_name=%s&level=%s&baseid=%s&device=%s&opId=%s&ngamenosig", 
    --     RoleService.domain, tostring(info.uuid),tostring(info.serverId),url_encode(info.role_name),tostring(info.level),tostring(info.baseid), url_encode(info.device),tostring(info.opId)
    -- )
    self:_getRemote(url, function(result)
        if result ~= nil and type(result) == "table" then
            if result.ret == "ok" then
                --update remote list
                local updated = false
                for i, v in ipairs(self._remoteList) do 

                    if tostring(v.serverId) == info.serverId and tostring(v.uuid) == info.uuid   then
                       updated = true
                       v.level = info.level
                       break 
                    end
                end
                if not updated then
                    table.insert(self._remoteList, info)
                end
               
            end

        end
        
    end)

end

--另外备份玩家绑定的手机号码， 以备万一平台数据损坏

function RoleService:bindMobile(mobile_no)
    local serverId = ""
    if G_PlatformProxy:getLoginServer() then
        serverId = tostring(G_PlatformProxy:getLoginServer().id)
    end
    local uuid = self:getUuid()
    local opId = G_PlatformProxy:getOpId()
    local device = G_PlatformProxy:getDeviceId()
    local role_name = tostring(G_Me.userData.name)
    local level = G_Me.userData.level
    local vip= G_Me.userData.vip
    local url =  self:_generateUrl(string.format("%s/nconfig/services/role?action=add_mobile", self:_getDomain()), 
        {
            uuid = uuid,
            serverId = serverId,
            role_name = role_name,
            device = device,
            level = level,
            vip = vip,
            mobile_no = mobile_no,

        }
    )
    -- print(url)
    -- http://10.3.99.43/nconfig/services/role?action=add_mobile&ngamenosig&uuid=1_luo001&serverId=1&role_name=luo001&mobile_no=1352432&level=90&device=iphone&vip=10
    -- string.format("%s/nconfig/services/role?action=add&uuid=%s&serverId=%s&role_name=%s&level=%s&baseid=%s&device=%s&opId=%s&ngamenosig", 
    --     RoleService.domain, tostring(info.uuid),tostring(info.serverId),url_encode(info.role_name),tostring(info.level),tostring(info.baseid), url_encode(info.device),tostring(info.opId)
    -- )
    self:_getRemote(url, function(result)
        -- dump(result)
    end)
end

return RoleService
