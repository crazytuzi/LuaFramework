local ServerList = class("ServerList")

local SERVER_FILE = "server.data"
local ComSdkUtils = require("upgrade.ComSdkUtils")
local storage = require("app.storage.storage")

function ServerList:ctor()
    if patchMe and patchMe("ServerList", self) then return end  

    self._inited =false
    self._useTestList = false
    self._lastRemoteTime = 0
    self._lastRandServer = nil
end


function ServerList:_shouldUseRemoteList()
    --if G_NativeProxy.platform == "ios" or G_NativeProxy.platform == "android" then
    if G_NativeProxy.platform == "ios" or G_NativeProxy.platform == "android" or G_NativeProxy.platform == "wp8" or G_NativeProxy.platform == "winrt" then
        return true
    else
        return false
    end
end

function ServerList:checkUpdateList(callback)
    if self:_shouldUseRemoteList() and not self._useTestList then
        if self._lastRemoteTime == 0 or ( FuncHelperUtil:getCurrentTime() - self._lastRemoteTime) >  60 then
            self:_getRemoteServerList(callback)
            return
        end
    end

    if callback then
        callback()
    end
end



function ServerList:init()

    if not self._inited then
        self._inited = true
        local useDefaultServerList = false
        local request=uf_netManager:createHTTPRequestGet("http://192.168.221.128:3880/serverlist",function(event)
            local request = event.request
            --print("===============================================")
            
            local servers = request:getResponseString()
            print("servers:" .. servers)
            local tables=json.decode(servers)
            print(tables)
            self._list=tables["data"]
            --self:getFirstServer()
            --[[self._list =  {
                    {name="GR3测试服", id=9, login="http://192.168.2.102/web/hook_login/login.php", status=1, gateway="120.26.205.212",port=8118},}]]
            --print("serverlist: " .. sz_T2S(self._list))        
            self._useTestList = true
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_UPDATE_SERVER_LIST, nil, true)
            end
         )
        request:start()
            --http://mp.uuzu.com/Api/ServerList?gameId=94&gameOpId=2013&opId=2106
            --http://mp.uuzu.com/ServerList?gameId=94&opId=2120&time=1&sign=0e9316391d2147fb2a0fe987fe2c45ba&isGzip=0&gameOpId=2033&columns=gateway_domain|gateway_port

        self._list =  {
                    {name="演示服", id=101, login="http://127.0.0.1", status=1, gateway="192.168.221.128",port=8118},
					{name="王者之墓002", id=100, login="http://127.0.0.1", status=1, gateway="192.168.221.128",port=9000},}            

            --[[self._list =  {
                    {name="GR3测试服", id=9, login="http://192.168.2.102/web/hook_login/login.php", status=1, gateway="120.26.205.212",port=8118},
                    --[[{name="压测服(勿进)", id=123, login="http://192.168.1.159/web/hook_login/login.php", status=1,gateway="10.3.99.10",port=38422},
                    {name="精英测试服", id=2013420001, login="http://192.168.1.159/web/hook_login/login.php", status=1,gateway="61.174.11.44",port=38422},

                    {name="商务测试服", id=2013440002, login="http://122.226.211.181/web/hook_login/login.php", status=1, gateway="g1.n.m.uuzuonline.net",port=38422},
                    
                    {name="androidS2", id=2055310002, login="http://192.168.1.159/web/hook_login/login.php", status=1, gateway="10.3.99.91",port=38422},

                    {name="S1", id=2033310001, login="http://192.168.1.159/web/hook_login/login.php", status=1, gateway="g1.n.m.uuzuonline.net",port=38422, first_opentime="1417662000"},
                    {name="S2", id=2033310002, login="http://192.168.1.159/web/hook_login/login.php", status=1, gateway="g1.n.m.uuzuonline.net",port=38422},
                    
                    {name="9 内网服", id=9, login="http://192.168.1.159/web/hook_login/login.php", status=1, gateway="192.168.1.159",port=38422},

                    {name="1 司靖", id=1, login="http://192.168.1.159/web/hook_login/login.php", status=1,gateway="192.168.1.159",port=38422},
                    {name="2 廖廖", id=2, login="http://192.168.1.159/web/hook_login/login.php", status=2,gateway="192.168.1.159",port=38422},
                    {name="3 随风", id=3, login="http://192.168.1.159/web/hook_login/login.php", status=2,gateway="192.168.1.159",port=38422},
                    {name="4 东东", id=4, login="http://192.168.1.159/web/hook_login/login.php", status=2,gateway="192.168.1.159",port=38422},
                    {name="5 马东", id=5, login="http://192.168.1.159/web/hook_login/login.php", status=2,gateway="192.168.1.159",port=38422},
                    {name="6 砖头", id=6, login="http://192.168.1.159/web/hook_login/login.php", status=2,gateway="192.168.1.159",port=38422},
                    {name="11云雀", id=11, login="http://192.168.1.159/web/hook_login/login.php", status=2,gateway="192.168.1.159",port=38422},
                    {name="12嘉诚", id=12, login="http://192.168.1.159/web/hook_login/login.php", status=2,gateway="192.168.1.159",port=38422},
                    {name="13发发", id=13, login="http://192.168.1.159/web/hook_login/login.php", status=2,gateway="192.168.1.159",port=38422},
                    {name="33三号", id=33, login="http://192.168.1.159/web/hook_login/login.php", status=2,gateway="192.168.1.159",port=38422},
                    {name="新的压测服", id=2013430001, login="http://192.168.1.159/web/hook_login/login.php", status=2,gateway="10.3.99.76",port=38422},
                    {name="应用宝测试服", id=2072440001, login="http://192.168.1.159/web/hook_login/login.php", status=3,gateway="g1.n.ttceshi.uuzuonline.net",port=38422},

                    {name="新QA3服", id=2013440005, login="http://192.168.1.159/web/hook_login/login.php", status=3,gateway="61.153.101.19",port=38422},

                    {name="新QA2服", id=2013440003, login="http://192.168.1.159/web/hook_login/login.php", status=3,gateway="61.153.101.19",port=38422},
                    {name="新QA1服", id=2013440004, login="http://192.168.1.159/web/hook_login/login.php", status=3,gateway="61.153.101.19",port=38422},
                    {name="永测服", id=2034410001, login="http://192.168.1.159/web/hook_login/login.php", status=2,gateway="g1.n.m.uuzuonline.net",port=38422},
                    {name="三国群雄", id=2035420001, login="http://192.168.1.159/web/hook_login/login.php", status=2,gateway="g1.n.m.gtarcade.com",port=38422},
                    {name="越狱封测服", id=2013420003, login="http://192.168.1.159/web/hook_login/login.php", status=2,gateway="g1.n.m.uuzuonline.net",port=38422},
                    {name="APP提审服", id=2021430001, login="http://192.168.1.159/web/hook_login/login.php", status=2,gateway="g1.n.m.uuzuonline.net",port=38422},
                    {name="版署", id=2035430001, login="http://122.226.211.181/web/hook_login/login.php", status=2,gateway="g1.n.m.uuzuonline.net",port=38422},

                    {name="海外APP提审服", id=2035420001, login="http://192.168.1.159/web/hook_login/login.php", status=2,gateway="g1.n.m.gtarcade.com",port=38422},
            }
            -- self:_getRemoteServerList()
        end ]]
        
        
    end

end


function ServerList:_getRemoteServerList(callback)
    G_WaitingLayer:show(true)


    -- local url = string.format("http://mp.uuzu.com/Api/ServerList?gameId=%s&gameOpId=%s&opId=%s", ComSdkUtils.getGameId(), ComSdkUtils.getGameOpId(), ComSdkUtils.getOpId())

    local url = string.format("http://mpzip.uuzu.com/ServerList?gameId=%s&gameOpId=%s&opId=%s&time=%s&sign=0e9316391d2147fb2a0fe987fe2c45ba&isGzip=0&columns=gateway_domain|gateway_port|first_opentime", ComSdkUtils.getGameId(), ComSdkUtils.getGameOpId(), ComSdkUtils.getOpId(), os.time())

    --print("get server list: " .. tostring(url))
    

    local request = uf_netManager:createHTTPRequestGet(url, function(event) 
        local request = event.request
        local errorCode = request:getErrorCode()
        G_WaitingLayer:show(false)

        if errorCode ~= 0 then
            MessageBoxEx.showOkMessage(nil, 
                G_lang:get("LANG_ERROR_NETWORK"), false, 
                function ( ... )
                    self:_getRemoteServerList()
                end
            )
            return
        end

        local response = request:getResponseString()
        local t=json.decode(response)
        if t then
            local ok = (event.name == "completed")
            if ok then

                if t.status == "1" then
                    --convert t.data -> serverList
                    local list =  {}

                    if not t.data then
                        MessageBoxEx.showOkMessage(nil, 
                            G_lang:get("LANG_ERROR_SERVERLIST"), false, 
                            function ( ... )
                                self:_getRemoteServerList()
                            end
                        )
                        return
                    end


                    for i=1,#t.data do 
                        if tostring(t.data[i].status) ~= '7' then

                            local server = {
                                name = t.data[i].name,
                                id = t.data[i].server_id,
                                login = "http://192.168.1.159/web/hook_login/login.php",  --测试时才需要
                                status = t.data[i].status,
                                gateway=t.data[i].gateway_domain,
                                port=t.data[i].gateway_port,
                                first_opentime = t.data[i].first_opentime,
                                locked = false,
                                openTimeRank = 1,
                            }


                            self:checkServerShouldAddLock(server)
                           

                            table.insert(list,  server)
                        end
                        
                    end
                    if #list > 0 then

                        --对没有lock的服务器列表进行开服时间排序， 赋值给openTimeRank
                        self:_setOpenTimeRankForList(list)

                        self._lastRemoteTime = FuncHelperUtil:getCurrentTime()
                        self._list = list
                        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_UPDATE_SERVER_LIST, nil, false)

                        if callback then
                            callback()
                        end
                    end
                    


                else
                    MessageBoxEx.showOkMessage(nil, 
                        G_lang:get("LANG_ERROR_SERVERLIST"), false, 
                        function ( ... )
                            self:_getRemoteServerList()
                        end
                    )
                end

            end
        else
            MessageBoxEx.showOkMessage(nil, 
                G_lang:get("LANG_ERROR_SERVERLIST"), false, 
                function ( ... )
                    self:_getRemoteServerList()
                end
            )
        end

    end)
    request:start()
end


function ServerList:_isValid(server)
    if server['showTime'] ~= nil and os.time() < toint(server['showTime']) then
        return false
    else
        return true
    end

end

function ServerList:getList()
    self:init()

    --if .showTime is not nil , it should be hidden until the time arrives
    local list = {}

    for i,v in ipairs(self._list) do
        if self:_isValid(v) then
            table.insert(list, v)
        end
    end

    return list
end

function ServerList:getServerById(serverId)
    self:init() 
    if(self._list==nil) then 
        return nil
    end
    for i,server in ipairs(self._list) do
        if tostring(server.id) == tostring(serverId) then
            return server
        end
    end
    
    return nil
end

function ServerList:getFirstServer()
    self:init()

    local default_server = toint( G_Setting:get("default_server"))

    if default_server == nil then
        default_server = 0
    end

    default_server = tostring(default_server)

    local list = self:getList()

    if list and #list then
        for i,server in ipairs(list) do 
            if tostring(server.id) ==default_server then
                return server
            end
        end

        --if no default server, if there is random server , pick one from them
        local randomServers = {}
        for i,server in ipairs(list) do 
            if server.random ~= nil  then
                table.insert(randomServers, server)
            end
        end
        if #randomServers > 0 then
            if self._lastRandServer then
                return self._lastRandServer
            end

            math.randomseed( os.time() )
            local serverIndex = math.random(#randomServers)
            self._lastRandServer = randomServers[serverIndex]
            return self._lastRandServer
        end


        return list[1]
    end
    return nil
end







function ServerList:getLastServer()
    local serverInfo =  storage.load(storage.path(SERVER_FILE))
    if serverInfo then
        return self:getServerById(serverInfo.lastServerId)
    else
        return nil
    end
end

function ServerList:setLastServerId(sid)
    storage.save(storage.path(SERVER_FILE), {lastServerId = sid})

end

function ServerList:checkServerShouldAddLock(server)
    local locked = false
    if tostring(server.status) == "9" or tostring(server.status) == "10" or tostring(server.status) == "11" then
        locked = true
    end

    --测试网关
    if  server.gateway == "61.153.101.19" or server.gateway == "119.29.59.32" then
        locked = true
    end
   
    server.locked = locked
end

function ServerList:_setOpenTimeRankForList(list)
    local unlockList = {}

    for i, server in ipairs(list) do 
        if (server.locked == nil or server.locked == false ) and server.first_opentime ~= nil then
            table.insert(unlockList, server)
        end
    end


    local sortFunc = function(a,b)
        return a.first_opentime > b.first_opentime        
    end
    table.sort(unlockList, sortFunc)


    for i, server in ipairs(unlockList) do 
        server.openTimeRank = i
    end

end


function ServerList:addTestServer(serverId, serverName, gateway)
    local port = 38422
    local url = "http://192.168.1.159/web/hook_login/login.php"

    if LANG == "tw" then
        url = "http://192.168.1.159/web/hook_login/login_tw.php"
    end
    
    local server = {
        name = serverName,
        id = serverId,
        login = url,  --测试时才需要
        status = 2,
        gateway=gateway,
        port=port,
        locked = false,
        openTimeRank = 1,
    }
    --table.insert(self._list, 1, server)
    return server
end



return ServerList
