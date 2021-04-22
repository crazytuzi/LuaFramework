local QLoginHistory = {}

local fileName = "loginHistory.json"


function QLoginHistory.checkHasFile()
	-- body
	return fileExists(fileName)
end

function QLoginHistory.saveLoginHistory( jsonStr )
	-- body
	writeToBinaryFile(fileName,jsonStr)
end

function QLoginHistory.getLoginHistory()
	-- body
	-- local userName = app:getUserName()
	if fileExists(fileName) then
		local content = readFromBinaryFile(fileName)
		return json.decode(content)
	end
	
	-- if tbl then
	-- 	if tbl.servers and tbl.servers[userName] then
	-- 		return tbl.servers[userName]
	-- 	end
	-- end 
end

function QLoginHistory.getLoginHistoryFromServer(downloader)
	-- body
	local userName = app:getUserName()
	local history = {}
	if not userName then
		return 
	end
	local group_id = remote.serverListGroupId or ""
	local opId = ""
	if remote.serverListOpId and remote.serverListOpId ~= "" then
		opId = "_"..remote.serverListOpId
	end
	userName = userName .. opId
	local isNeedGetLoginHistory = true 
	local tbl
    if QLoginHistory.checkHasFile() then
        tbl = QLoginHistory.getLoginHistory()
        if not tbl then
        	tbl = {}
        	tbl.servers = {}
        elseif not tbl.servers then
        	tbl.servers = {}
        elseif tbl.servers[userName] then
        	isNeedGetLoginHistory = false
        	
        	local serverTbls = tbl.servers[userName]
        	if remote.serverInfos then
	        	for k, v in pairs(serverTbls)do
        			for k1,v1 in pairs(remote.serverInfos) do
        				if v1.zoneId == v.zoneId and v1.serverId == v.serverId then
        					v.status = v1.status
        					v.name = v1.name
        					v.address = v1.address
        					v.is_hot_blood = v1.is_hot_blood or false
        					table.insert(history, v)
        					break;
        				end
        			end
	        		
	        	end
	        end
	        if history and #history == 0 then
	         	if remote.serverInfos then
		        	for k, v in pairs(serverTbls)do
	        			for k1,v1 in pairs(remote.serverInfos) do
	        				if v1.zoneId == v.zoneId then
	        					v.status = v1.status
	        					v.name = v1.name
	        					v.address = v1.address
	        					v.serverId = v1.serverId
	        					v.is_hot_blood = v1.is_hot_blood or false
	        					table.insert(history, v)
	        					break;
	        				end
	        			end
		        	end
		        end
	        end 
        	QLoginHistory.saveLoginHistoryByTable(tbl)
        	return history
        end
    else
    	tbl = {}
       	tbl.servers = {}
    end

    --获取历史失败
    if isNeedGetLoginHistory then
	    local param = string.format("/json_req?action=loadLoginServers&account=%s&time=%s&group_id=%s", userName, q.serverTime(), group_id)
	    printInfo("get data from "..LOGINHISTORY_URL..param)
	    -- local loginHistoryJson = downloader:downloadContent(LOGINHISTORY_URL..param, false)
	    local loginHistoryJson = httpGet(LOGINHISTORY_URL..param, 1)
	    local data = json.decode(loginHistoryJson)
	    if data and data.ret == "ok" then
	        tbl.servers[userName] = data.servers
	        local serverTbls = tbl.servers[userName]
	        if remote.serverInfos then
		        for k, v in pairs(serverTbls)do
        			for k1,v1 in pairs(remote.serverInfos) do
        				if v1.zoneId == v.zoneId and v1.serverId == v.serverId then
        					v.status = v1.status
        					v.name = v1.name
        					v.address = v1.address
        					v.is_hot_blood = v1.is_hot_blood or false
        					table.insert(history, v)
        					break;
        				end
        			end
	        	end 
	        end
	        if history and #history == 0 then
	         	if remote.serverInfos then
		        	for k, v in pairs(serverTbls)do
	        			for k1,v1 in pairs(remote.serverInfos) do
	        				if v1.zoneId == v.zoneId then
	        					v.status = v1.status
	        					v.name = v1.name
	        					v.address = v1.address
	        					v.serverId = v1.serverId
	        					v.is_hot_blood = v1.is_hot_blood or false
	        					table.insert(history, v)
	        					break;
	        				end
	        			end
		        	end
		        end
	        end
	        QLoginHistory.saveLoginHistoryByTable(tbl)
	        return history
	    else
	    	tbl.servers[userName] = {}
	        QLoginHistory.saveLoginHistoryByTable(tbl)
	    end
    end
    return history
end

function QLoginHistory.saveLoginHistoryByTable(tbl)
	-- body
	local jsonStr = json.encode(tbl)
	if jsonStr then
		writeToBinaryFile(fileName,jsonStr)
	end
end

function QLoginHistory.changeLoginHistory( no_loginTime )
	-- body
	if remote.selectServerInfo == nil then return end
	local curZoneId = remote.selectServerInfo.zoneId
	local curServerId = remote.selectServerInfo.serverId
	local userName = app:getUserName()
	if not userName then
		return 
	end
	local opId = ""
	if remote.serverListOpId and remote.serverListOpId ~= "" then
		opId = "_"..remote.serverListOpId
	end	
	userName = userName .. opId
	local tbl = QLoginHistory.getLoginHistory()

	if not (tbl and tbl.servers and tbl.servers[userName])then
		return
	end

	local serverTbls = tbl.servers[userName]
	for k, v in pairs(serverTbls)do
		if curZoneId == v.zoneId and curServerId == v.serverId then
			if remote.user then
				v.avatar = remote.user.avatar
				v.teamLv = remote.user.level
				v.nickname = remote.user.nickname
				if not no_loginTime then
					v.loginTime = q.serverTime() * 1000
				end
				QLoginHistory.saveLoginHistoryByTable(tbl)
			end
			return 
		end
	end
	--
	local serverInfo = clone(remote.selectServerInfo)
	serverInfo.avatar = remote.user.avatar
	serverInfo.teamLv = remote.user.level
	serverInfo.nickname = remote.user.nickname
	serverInfo.loginTime = q.serverTime() * 1000
	table.insert(serverTbls,serverInfo)
	QLoginHistory.saveLoginHistoryByTable(tbl)
end



return QLoginHistory