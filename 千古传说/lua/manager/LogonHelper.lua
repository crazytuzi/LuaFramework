--[[
	登录帮助类
	-- @author david.dai
	-- @date 2015/4/20
]]

local LogonHelper = class("LogonHelper")


local UserCenterHttpClient = TFClientNetHttp:GetInstance()
local SERVER_LIST_URL = 'http://192.168.10.100:9000/server/list.do'

LogonHelper.MSG_DOWNLOAD_SEVERLIST  = "LogonHelper.MSG_DOWNLOAD_SEVERLIST"	-- 

function LogonHelper:ctor(data)
end

function LogonHelper:restart()
end

function LogonHelper:requestServerList(url)
	if url == nil then
		-- url = SERVER_LIST_URL
        print("LogonHelper request ServerList is nil")
        hideLoading()
        return
	end

	self.serverListCallback = function (type, ret, data)
        hideLoading()

        -- print("data = ", data)

        if not data then return end

        --local decode_data = string.url_decode(data)
        local server_data = json.decode(data)

        -- print("json server_data", server_data)
        --  and string.len(server_data) > 0 
        if server_data then
            -- for i=1,#server_data do
            --     server_data[i].index = #server_data -i + 1
            -- end
            SaveManager:setDynamicServerList(server_data.server_list)
            SaveManager:setZoneList(server_data.zone_list)
            -- local lastLoginServerId = server_data.server_data or 1
            if server_data.lastLoginServerId then
                SaveManager:setUserInfoServer(server_data.lastLoginServerId)
            end
            -- 下载完成通知
            TFDirector:dispatchGlobalEventWith(self.MSG_DOWNLOAD_SEVERLIST, {})
        end
    end
    UserCenterHttpClient:addMERecvListener(self.serverListCallback)
    print("requestServerList : ",TFHTTP_TYPE_GET,url)
	UserCenterHttpClient:httpRequest(TFHTTP_TYPE_GET,url)
end


function LogonHelper:requestServerListAgain()
    local platformid = nil
    local userId     = nil

    if HeitaoSdk then
        platformid = HeitaoSdk.getplatformId()
        userId     = HeitaoSdk.getuserid()
    else
        platformid = "win2015"
        userId     = "winUser001"
    end

    local serverList_url = TFPlugins.serverList_url

    local system = 0    -- pc
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        system = 1      --ios
    elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        system = 2      --android
    end

    serverList_url = serverList_url .. "?system=" .. system
    if platformid ~= nil then
        serverList_url = serverList_url .. "&channel=" .. platformid
    end
        serverList_url = serverList_url .. "&userid=" .. userId
    if userId ~= nil then
    end
    
    -- add app verison
    serverList_url = serverList_url .. "&appverison=" .. TFDeviceInfo.getCurAppVersion()
    -- TFPlugins.serverList_url = serverList_url
    
    print("再次请求服务器列表 = ", serverList_url)

    self:requestServerList(serverList_url)
end

return LogonHelper:new()