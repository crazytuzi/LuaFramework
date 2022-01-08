--[[
******本地数据存储管理类*******

	-- by david.dai
	-- 2013/12/27
]]

--默认打包在客户端的服务器列表，用于兼容PC客户端登录以及服务器列表未完成对接时能够正确显示服务器使用
local defaultServerList = require('lua.config.server')

local SaveManager = class("SaveManager")

--[[
标记是否总是使用本地服务器列表，如果为true则总是显示本地服务器列表，而不显示与公司对接的服务器列表信息；
否则优先显示与公司对接获取的服务器列表，只有在服务器列表为空时才使用本地服务器列表
]]
local useLocalServerList = true

function SaveManager:ctor()
    self.userInfo = nil
end

--获取用户信息
function SaveManager:getUserInfo()
    if self.userInfo then
        return self.userInfo
    end

    local info = {}
    info.currentServer = CCUserDefault:sharedUserDefault():getStringForKey("current_server")
    info.userName = CCUserDefault:sharedUserDefault():getStringForKey("user_name")
    info.serverHistoryExpression = CCUserDefault:sharedUserDefault():getStringForKey("server_history")
    if info.serverHistoryExpression and string.len(info.serverHistoryExpression) > 0 then
        info.serverHistory = string.split(info.serverHistoryExpression,',')
    else
        info.serverHistory = {}
    end
    self.userInfo = info
    return self.userInfo
end

local MAX_SERVER_HISTORY_COUNT = 4

--存储用户信息
function SaveManager:saveUserInfo()
    if not self.userInfo then
        return
    end

    local info = self.userInfo
    local haveCurrent = info.currentServer and string.len(info.currentServer)
    local existIndex = 0
    if info.serverHistory and #info.serverHistory > 0 and haveCurrent then
        for i = 1,#info.serverHistory do
            if info.serverHistory[i] == info.currentServer then
                existIndex = i
                break
            end
        end
    end

    local tmpIndex = 0
    if existIndex > 0 then
        tmpIndex = existIndex - 1
    elseif info.serverHistory and #info.serverHistory > 0 then
        tmpIndex = #info.serverHistory
    end

    --print("save user info [tmpIndex] : ",tmpIndex,existIndex)

    while tmpIndex > 0 do
        info.serverHistory[tmpIndex + 1] =   info.serverHistory[tmpIndex]
        tmpIndex = tmpIndex - 1
    end

    info.serverHistory[1] = info.currentServer

    --print("save user info [currentServer] : ",info.currentServer,info.serverHistory)

    if info.serverHistory and #info.serverHistory > 0 then
        local expression = ""
        local count = 0
        for i = 1,#info.serverHistory do
            --fix not found server
            local serverList = self:getServerList()
            local found = false
            for k,v in pairs(serverList) do
                if tostring(v.serverId) == info.serverHistory[i] then
                    found = true
                end
            end
            --找得到目标服务器
            if found then
                expression = expression .. info.serverHistory[i]
                --最大服务器记录数目
                count = count + 1
                if count == MAX_SERVER_HISTORY_COUNT then
                    break
                end
                if i < #info.serverHistory then
                    expression = expression .. ","
                end
            end
        end
        info.serverHistoryExpression = expression
    end

    CCUserDefault:sharedUserDefault():setStringForKey("current_server",info.currentServer)
    CCUserDefault:sharedUserDefault():setStringForKey("user_name",info.userName)
    CCUserDefault:sharedUserDefault():setStringForKey("server_history",info.serverHistoryExpression)
    CCUserDefault:sharedUserDefault():flush()
end

--[[
获取服务器列表
]]
function SaveManager:getServerList()
    -- if useLocalServerList then
    --     return defaultServerList
    -- end

    if self.dynamicServerList then
        return self.dynamicServerList
    end
    -- return defaultServerList
    return nil
end

--[[
获取客户端本地默认提供的服务器列表
]]
function SaveManager:getLocalServerList()
    return defaultServerList
end

--[[
获取动态服务器列表，动态服务器列表即从公司验证服务器返回的服务器列表
]]
function SaveManager:getDynamicServerList()
    return self.dynamicServerList
end

--[[
设置动态服务器列表，动态服务器列表即从公司验证服务器返回的服务器列表
{
serverId:   123                   //[int]游戏服 ID，游戏内全局唯一
IP    :       ‘10.10.3.123:5001’,   //[string]游戏服登录IP:PORT
name  :       ‘1区月光宝地’,        //[string]区服名称(显示用)，utf8编码
load  :       50,                   //[int]>0，负载情况(越小越空闲)，=0时无效
ext   :       0,                    //[按位取]1:新服;2:推荐
mark  :                             // 二进制
}
…………
]]
function SaveManager:setDynamicServerList(serverList)
    useLocalServerList = false
    self.dynamicServerList = serverList
end

function SaveManager:setZoneList(zoneList)
    self.zoneList = zoneList
end

function SaveManager:getZoneList()
    return self.zoneList
end

--获取当前选择的服务器信息
function SaveManager:getCurrentSelectedServer()
    local serverInfo = self:getServerInfo(self.userInfo.currentServer)
    if serverInfo then
        return serverInfo
    end
    local serverList = self:getServerList()
    if serverList then
        -- 解决没有服务器列表的报错
        if serverList[1] == nil then
            return nil
        end

        -- self.userInfo.currentServer = tostring(serverList[1].serverId)
        -- return serverList[1]
        local defaultServer = serverList[1]
        for k,v in pairs(serverList) do
            local mark = v.mark
            local tag1 = bit_and(mark,2)

            if tag1 ~= 0 then
                defaultServer = v
                print("查找新服 = ", defaultServer)
            end
        end

        self.userInfo.currentServer = tostring(defaultServer.serverId)
        return defaultServer

    end
end

--[[
获取服务器信息
@param IPAddress 服务器IP
]]
function SaveManager:getServerInfo(id)
    local serverList = self:getServerList()
    if serverList == nil then
        return nil
    end
    
    if not id then
        if serverList then
            self.userInfo.currentServer = tostring(serverList[1].serverId)
            return serverList[1]
        end
    end

    for k,v in pairs(serverList) do
        if tostring(v.serverId) == tostring(id) then
            return v
        end
    end
    return nil
end

function SaveManager:getServerName(server)
    -- if server.index then
    --     return server.index .. " - " ..server.name
    -- end
    -- return server.serverId .. " - " ..server.name

    return server.name
end

function SaveManager:checkServerIsOpen()

    local serverInfo = self:getServerInfo(self.userInfo.currentServer)

    if serverInfo == nil then
        return true
    end
    
    local open = serverInfo.openServer
    if open ~= nil and open == false then
        local msg = "服务器维护中"
        if serverInfo.upkeepMessage then
            msg = serverInfo.upkeepMessage
        end

        toastMessage(msg)
        return false
    end

    return true
end

--获取用户信息
function SaveManager:setUserInfoServer(lastServer)
    if self.userInfo == nil then
        return
    end

    self.userInfo.currentServer = lastServer
end

return SaveManager:new()
