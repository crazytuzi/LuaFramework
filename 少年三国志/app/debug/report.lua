require("upgrade.VersionUtils")

local Report  = {}

local storage = require("app.storage.storage")


-- 日志记录开关 G_Setting.report_save
-- 日志记录策略:
-- 在一次进程里, 同样的错误只保存一次, 
-- 本地缓存的日志为数量最多为 max_save_report, 如果超过, 则先进先出,只保留最后max_save_report


--local max_save_report = 1 -- 5 暂时改成1, 开发期间,每次发生错误都上传,


-- 日志发送开关 G_Setting.report_send
-- 日志发送策略
-- 在进程启动的时候, 未登陆游戏前, 发送所有日志
-- 在产生日志的时候, 如果本地日志数量>=max_save_report,也会触发马上发送

-- 注意发送是异步的,发送的过程中游戏还可能产生错误日志, (todo:这个时候需要缓存错误, 现在可以先处理成 发送过程不缓存任何错误), 
-- 如果发送失败, 保留日志,等待下次发送机会
-- 如果发送成功, 清空日志
-- 发送结束后, (todo:刚才缓存的日志再进行本地序列化)


local saved_report_this_process = {}

local ERROR_REPORT_FILE = "error_report.data"


local sending = false

local userHistory = {}
local reversedNetMsgId = nil

function Report:setLastBattle(battle)
    print("set las battle")
    --不发战报了
    if true then
        return
    end

	if G_Setting == nil then
		return
	end

	if G_Setting:get("report_save") == "0" then
		return
	end

	self._lastBattle = battle

end

function Report:onTrackBack(errorMessage, trackback)
	if G_Setting == nil then
		return
	end
            

	if  G_Setting:get("report_save") == "0" then
		return
	end

	-- 记日志,先保存起来

    if saved_report_this_process[errorMessage] then
        return
    end




	--错误堆栈是否包含  scenes/battle/ ?
    local battle = {}
	if string.find(trackback, "scenes/battle/") ~= nil then
        if self._lastBattle then
            battle = self._lastBattle
            self._lastBattle = nil
        end
	end


	local localErrors = self:saveReport(errorMessage, trackback, battle)

    if #localErrors >= G_Setting:get("report_max_len") then
        self:sendReport(localErrors)
    end

end

function Report:saveReport(errorMessage, trackback, battle)
    local errorTime = 0
    if G_ServerTime ~= nil  then
        errorTime = G_ServerTime:getTime()
    end

    local serverId = 0
    local serverName = ""
    if G_PlatformProxy ~= nil  and G_PlatformProxy:getLoginServer() ~= nil then
        serverId = G_PlatformProxy:getLoginServer().id
        serverName = G_PlatformProxy:getLoginServer().name
    end

    local roleId = 0
    local roleName = ""
    if G_Me ~= nil  and G_Me.userData ~= nil then
        roleId = G_Me.userData.id
        roleName  = G_Me.userData.name
    end

    local platformUid = ""
    if G_PlatformProxy ~= nil then
        plaformUid = G_PlatformProxy:getPlatformUid()
    end

    local localUpgradeVersionNo = getLocalVersionNo()
    local versionStr = tostring(GAME_VERSION_NAME) .. "-" .. tostring(localUpgradeVersionNo)
    local other = ""

    local now = FuncHelperUtil:getCurrentTime()
    local history = ""
    for i=#userHistory,1,-1 do 
       local before = userHistory[i][1] - now
       --convert id to string

       history =  tostring(before ) .. "s:" .. userHistory[i][2]  .."(" .. userHistory[i][3] .. ")" .. "\n"..  history 
    end

    other = other .. history

    if G_NativeProxy then
        other = other .. "mem:" .. tostring(G_NativeProxy:getUsedMemory() ) .. "KB" .. "\n"
        other = other .. "os:" .. tostring(G_NativeProxy.platform )  .. "\n"

    end
    local report = {
        errorMessage = errorMessage,
        trackback = trackback,
        battle = battle,
        errorTime =  errorTime,
        errorTick = FuncHelperUtil:getTickCount(),
        serverId = serverId,
        serverName = serverName,   
        roleId = roleId,   
        roleName = roleName,
        plaformUid = plaformUid,
        buildVersion = versionStr,
        other = other
    }

   

    --读取本地队列
    local localErrors =  storage.load(storage.path(ERROR_REPORT_FILE))
    if localErrors == nil then
        localErrors = {}
    end

    --插入并保证队列最大数量为max_save_report
    local max_save_report = G_Setting:get("report_max_len")
    table.insert(localErrors, 1, report)
    if #localErrors > max_save_report then
        for i=#localErrors,max_save_report+1,-1 do
            table.remove(localErrors, i)
        end
    end

    --保存
    storage.save(storage.path(ERROR_REPORT_FILE), localErrors)

    saved_report_this_process[errorMessage] = true

    return localErrors
end

local function convertToNetworkId(id)
    if reversedNetMsgId == nil then
        --init
        reversedNetMsgId = {}
        for k,v in pairs(NetMsg_ID) do
           reversedNetMsgId[v] = k 
        end
        
    end

    local str = reversedNetMsgId[id] 
    if str == nil then
        str = id
    end
    return str
end

function Report:addHistory(type, msg)
    if  G_Setting:get("report_save") == "0" then
        return
    end
    if #userHistory > 100 then
        table.remove(userHistory, 1) 
    end

    
    if type == "send" or type == "recv" then
        msg = convertToNetworkId(msg)
    end
    table.insert(userHistory, { FuncHelperUtil:getCurrentTime(), type,msg})

end



function Report:sendReport(localErrors)
    if sending then
        return
    end

    if G_NativeProxy  and G_NativeProxy.platform == "windows" then
        return
    end

    local url = G_Setting:get("report_send_url");
  
    local fun = function ( request )
        if not request then 
            return 
        end

        local response = request:getResponseString()
            local t=json.decode(response)
            if t ~= nil then
                if t.ret ~= nil and t.ret == "ok" then
                    print("send report done")
                    storage.save(storage.path(ERROR_REPORT_FILE), {})
                end
            end
    end
    print("sending report ")
    local sharedApplication = CCApplication:sharedApplication()
    local target = sharedApplication:getTargetPlatform()
    local request = uf_netManager:createHttpRequestPost(url, function(event) 
        local request = event.request
        if target == kTargetWP8 or target == kTargetWinRT then
            if event.name and event.name == "completed" then 
                fun(request)
            end
        else
            fun(request)
        end
        sending = false

    end)
    request:setPOSTData(json.encode(localErrors))
    request:start()
    sending = true
end

function Report:sendLocalReports()
    if  G_Setting:get("report_save") == "0" then
        return
    end
    local localErrors =  storage.load(storage.path(ERROR_REPORT_FILE))
    if localErrors == nil then
        localErrors = {}
    end

    if #localErrors > 0 then
        self:sendReport(localErrors)
    end


end



return Report