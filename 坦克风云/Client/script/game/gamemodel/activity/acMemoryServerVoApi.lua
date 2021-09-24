acMemoryServerVoApi = {}

function acMemoryServerVoApi:getAcVo()
    return activityVoApi:getActivityVo("hjld")
end

function acMemoryServerVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage3.plist")
	spriteController:addTexture("public/activeCommonImage3.png")
end

function acMemoryServerVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage3.plist")
	spriteController:removeTexture("public/activeCommonImage3.png")
end

--获取绑定服务器列表(排除怀旧服)
function acMemoryServerVoApi:getBindServerList()
	if self.bindServerList == nil then
		self.bindServerList = {}
		if G_curPlatName() == "0" then --本地开发调试服务器
			for k, v in pairs(serverCfg.allserver) do
				for kk, vv in pairs(v) do
					if G_isMemoryServer(vv) == false then
						table.insert(self.bindServerList, vv)
					end
				end
			end
		else
			for k, v in pairs(serverCfg.allserver[G_country]) do
				if G_isMemoryServer(v) == false then
					table.insert(self.bindServerList, v)
				end
			end
		end
	end
	return self.bindServerList
end

--获取玩家的UID
--@userName : 用户名(游戏登录账号)
--@zoneId : 用户所在的服务器ID
function acMemoryServerVoApi:httpRequestUID(userName, zoneId, serverData)
	local domain = serverData.userip or base.serverUserIp
	local httpURL = "http://" .. domain .. ((G_isTestServer() == true) and "/gucenter_test/" or "/gucenter/") .."getuid.php"
	-- local userName = (base.tmpUserName == "" or base.tmpUserName == nil) and G_getTankUserName() or base.tmpUserName
	local requestParams = "username=" .. userName .. "&zoneid=" .. zoneId
	local responseStr = G_sendHttpRequestPost(httpURL, requestParams)
	print("cjl ------>>> http URL:\n", httpURL .. "?" .. requestParams)
	print("cjl ------>>> http response:\n", responseStr)
	return tonumber(responseStr)
end

--@taskType : 任务类型(1-怀旧服新兵任务，2-新兵和老兵的协同任务)
function acMemoryServerVoApi:getTaskList(taskType)
	local vo = self:getAcVo()
	if vo and vo.activityCfg and type(taskType) == "number" then
		return vo.activityCfg["taskList" .. taskType]
	end
end

--获取任务奖励
--@taskType : 任务类型(1-怀旧服新兵任务，2-新兵和老兵的协同任务)
function acMemoryServerVoApi:getTaskReward(taskType, taskKey, taskIndex)
	local vo = self:getAcVo()
	if vo and vo.activityCfg and type(taskType) == "number" and vo.activityCfg["reward" .. taskType] 
		and taskKey and vo.activityCfg["reward" .. taskType][taskKey] and taskIndex then
		if vo.activityCfg["reward" .. taskType][taskKey][taskIndex] then
			return FormatItem(vo.activityCfg["reward" .. taskType][taskKey][taskIndex], nil, true)
		end
	end
end

--获取任务描述
function acMemoryServerVoApi:getTaskDesc(taskKey, curNum, needNum, aiQuality)
	taskKey = (taskKey == "gb") and "gba" or taskKey
    taskKey = (taskKey == "eb") and "eb2" or taskKey
    if taskKey == "zy" then
    	curNum = FormatNumber(curNum)
    	needNum = FormatNumber(needNum)
    end
    local taskDescStr = getlocal("activity_chunjiepansheng_" .. taskKey .. "_title", {curNum, needNum})
    if taskKey == "ai" then
    	local param1
        if aiQuality == nil or aiQuality == 0 then
        	param1 = getlocal("fleetInfoTitle2") .. " " .. curNum
        else
            param1 = getlocal("aitroops_troop" .. aiQuality) .. " " .. curNum
        end
        taskDescStr = getlocal("activity_chunjiepansheng_" .. taskKey .. "_title", {param1, needNum .. " "})
    elseif taskKey == "hy" then
    	taskDescStr = getlocal("activity_smcz_hy_title", {curNum, needNum})
    end
    return taskDescStr
end

--任务跳转
function acMemoryServerVoApi:taskJumpTo(taskKey)
	local typeName = taskKey
	typeName = typeName =="gba" and "gb" or typeName--heroM
	typeName = (typeName =="bc" or typeName == "gd") and "cn" or typeName
	typeName = (typeName =="ua" or typeName == "ta") and "armor" or typeName
	typeName = (typeName =="uh" or typeName == "th") and "heroM" or typeName
	typeName = typeName =="pr" and "tp" or typeName
	typeName = (typeName == "ac" or typeName == "ai" or typeName == "ai1" or typeName == "ai2") and "aiTroop" or typeName
	typeName = (typeName == "st" or typeName == "sj") and "emblemTroop" or typeName
	typeName = typeName == "zy" and "pp" or typeName
	typeName = typeName == "zt" and "tankfactory" or typeName
	local useIdx = nil
	if taskKey == "st" then
		useIdx = 2
	elseif taskKey == "sj" then
		useIdx = 1
	end
	G_goToDialog2(typeName, 4, true, useIdx)
end

--获取任务完成次数
--@taskType : 任务类型(1-怀旧服新兵任务，2-新兵和老兵的协同任务)
function acMemoryServerVoApi:getTaskCompleteNum(taskKey, taskType)
	local vo = self:getAcVo()
	if vo and vo.rd then
		if type(taskType) == "number" and vo.rd[taskType] then
			return (vo.rd[taskType][taskKey] or 0)
		end
	end
	return 0
end

--获取任务当前进行的数量
function acMemoryServerVoApi:getTaskCurNum(taskKey, isLocalServer)
	local bindData = self:getBindPlayerData()
	if isLocalServer then
		local vo = self:getAcVo()
		if vo and vo.tk and vo.tk[taskKey] then
			return vo.tk[taskKey]
		end
	elseif bindData and bindData.tk and bindData.tk[taskKey] then
		return bindData.tk[taskKey]
	end
	if taskKey == "gd" then --指挥官等级达到{1}/{2}等级
		if isLocalServer then
			return playerVoApi:getPlayerLevel()
		else
			if bindData then
				return (bindData.level or 0)
			end
		end
	elseif taskKey == "vip" then --VIP等级达到{1}/{2}等级
		if isLocalServer then
			return playerVoApi:getVipLevel()
		else
			if bindData then
				return (bindData.vip or 0)
			end
		end
	elseif taskKey == "cr" then --指挥中心等级达到{1}/{2}等级
		if isLocalServer then
			local bvo = buildingVoApi:getBuildiingVoByBId(1)
			if bvo then
				return (bvo.level or 0)
			end
		else
			if bindData then
				return (bindData.crlevel or 0)
			end
		end
	elseif taskKey == "zd" then --战斗力达到{1}/{2}
		if isLocalServer then
			return playerVoApi:getPlayerPower()
		else
			if bindData then
				return (bindData.fc or 0)
			end
		end
	end
	return 0
end

--获取老服最多能够得到的金币数
function acMemoryServerVoApi:getMaxRewardGoldNum()
	local goldNum = 0
	local taskList = self:getTaskList(1)
	if taskList then
		for k, v in pairs(taskList) do
			if v.gb then
				for kk, vv in pairs(v.gb) do
					goldNum = goldNum + vv
				end
			end
		end
	end
	return goldNum
end

--获取绑定限制等级(限制的是要绑定的角色等级)
function acMemoryServerVoApi:getBindLimitLevel()
	local vo = self:getAcVo()
	if vo and vo.activityCfg then
		return (vo.activityCfg.Lv or 0)
	end
	return 0
end

--获取绑定玩家的服务器名
function acMemoryServerVoApi:getBindPlayerServerName()
	local vo = self:getAcVo()
	if vo and vo.bind then
		local zid, ozid = tonumber(vo.bind[2]), tonumber(vo.bind[3])
		for k, v in pairs(serverCfg.allserver[G_country]) do
    		if v.oldzoneid and tonumber(v.oldzoneid) > 0 and tonumber(v.oldzoneid) == ozid then --如果oldzoneid>0 说明已合服
    			return v.name
    		elseif (v.oldzoneid == nil or tonumber(v.oldzoneid) == 0) and tonumber(v.zoneid) == zid then
    			return v.name
    		end
    	end
	end
	return ""
end

--获取绑定的玩家当前所在服的数据
function acMemoryServerVoApi:getBindCurServerData()
	local b_zoneId, b_host, b_port
    local vo = self:getAcVo()
	if vo and vo.bind then
    	local zid, ozid = tonumber(vo.bind[2]),tonumber(vo.bind[3])
		for k, v in pairs(serverCfg.allserver[G_country]) do
    		if (v.oldzoneid and tonumber(v.oldzoneid) > 0 and tonumber(v.oldzoneid) == ozid) or ((v.oldzoneid == nil or tonumber(v.oldzoneid) == 0) and tonumber(v.zoneid) == zid) then --如果oldzoneid>0 说明已合服
    			b_zoneId = v.zoneid
    			b_host = tostring(v.ip)
				b_port = tonumber(v.port)
				do break end
    		end
    	end
    end
    return b_zoneId, b_host, b_port
end

--判断是否绑定了账号
function acMemoryServerVoApi:isBind()
	local vo = self:getAcVo()
	if vo and vo.bind and vo.bind[1] and vo.bind[2] and tonumber(vo.bind[1]) > 0 and tonumber(vo.bind[2]) > 0 then
		return true
	end
	return false
end

--获取绑定的玩家数据
function acMemoryServerVoApi:getBindPlayerData()
	local vo = self:getAcVo()
	if vo and vo.bindData then
		return vo.bindData
	end
end

function acMemoryServerVoApi:requestInitData(callback)
	if self:isBind() then
		local function socketCallback(fn, data)
			local ret, sData = base:checkServerData(data)
	        if ret == true then
	        	if sData and sData.data then
	        		if sData.data.hjld then
	        			self:updateData(sData.data.hjld)
	        		end
	        		if sData.data.bindudata then
	        			self:updateData(sData.data)
	        		end
		        	if type(callback) == "function" then
		        		callback()
		        	end
		        end
	        end
	    end
	    local b_zoneId, b_host, b_port = self:getBindCurServerData()
		socketHelper:acMemoryServer_initData(socketCallback, b_zoneId, b_host, b_port)
	end
end

--获取要绑定的老服玩家信息(角色名称、等级)
--@b_uid<int> : 要绑定的老号uid
--@b_zoneId<int> : 要绑定的老号当前所在服务器id
--@b_host<string> : 要绑定的老号当前所在服务器地址
--@b_port<int> : 要绑定的老号当前所在服务器端口号
function acMemoryServerVoApi:requestBindUserInfo(callback, b_uid, b_zoneId, b_host, b_port)
	local function socketCallback(fn, data)
		local ret, sData = base:checkServerData(data)
        if ret == true then
        	if sData and sData.data then
        		if sData.data.hjld then
        			self:updateData(sData.data.hjld)
        		end
	        	if type(callback) == "function" then
	        		callback(sData.data.udata)
	        	end
	        end
        end
    end
	socketHelper:acMemoryServer_bindUserInfo(socketCallback, b_uid, b_zoneId, b_host, b_port)
end

--绑定老服账号
--@b_uid<int> : 要绑定的老号uid
--@b_zoneId<int> : 要绑定的老号服务器id
--@b_host<string> : 要绑定的老号服务器地址
--@b_port<int> : 要绑定的老号服务器端口号
--@b_oldZoneId<int> : 要绑定的老号初始服务器id
function acMemoryServerVoApi:requestBind(callback, b_uid, b_zoneId, b_host, b_port, b_oldZoneId)
	local function socketCallback(fn, data)
		local ret, sData = base:checkServerData(data)
        if ret == true then
        	if sData and sData.data then
        		if sData.data.hjld then
        			self:updateData(sData.data.hjld)
        		end
        		if sData.data.bindudata then
        			self:updateData(sData.data)
	        	end
	        	if type(callback) == "function" then
	        		callback()
	        	end
	        end
        end
    end
    local localOldZoneId = (base.curOldZoneID ~= nil and tonumber(base.curOldZoneID) > 0) and tonumber(base.curOldZoneID) or tonumber(base.curZoneID)
	socketHelper:acMemoryServer_bind(socketCallback, b_uid, b_zoneId, b_host, b_port, b_oldZoneId, localOldZoneId)
end

--任务领奖
--@taskType<int> : 任务类型(1-怀旧服新兵任务，2-新兵和老兵的协同任务)
--@taskId<int> : 任务序号id
--@taskIndex<int> : 任务完成进度序号
function acMemoryServerVoApi:requestTaskReward(callback, taskType, taskId, taskIndex)
	local function socketCallback(fn, data)
		local ret, sData = base:checkServerData(data)
        if ret == true then
        	if sData and sData.data then
        		if sData.data.hjld then
        			self:updateData(sData.data.hjld)
        		end
	        	if type(callback) == "function" then
	        		callback()
	        	end
	        end
        end
    end
    local b_zoneId, b_host, b_port = self:getBindCurServerData()
	socketHelper:acMemoryServer_taskReward(socketCallback, taskType, taskId, taskIndex, b_zoneId, b_host, b_port)
end

function acMemoryServerVoApi:canReward()
	if G_isMemoryServer() then
		for taskType = 1, 2 do
			local taskList = self:getTaskList(taskType)
			if taskList then
				for k, v in pairs(taskList) do
					local completeNum = self:getTaskCompleteNum(v.key, taskType)
					local totalNum = SizeOfTable(v.num)
					local taskIndex = (completeNum == totalNum) and completeNum or (completeNum + 1)
					if taskType == 1 then
						local needNum = (v.num[taskIndex] or v.num[totalNum])
						local curNum = self:getTaskCurNum(v.key, true)
						if curNum >= needNum then
							return true
						end
					elseif taskType == 2 then
						local needNumTb = (v.num[taskIndex] or v.num[totalNum])
						local oldCurNum, oldNeedNum = self:getTaskCurNum(v.key, false), needNumTb[2]
				        local newCurNum, newNeedNum = self:getTaskCurNum(v.key, true), needNumTb[1]
				        if oldCurNum >= oldNeedNum and newCurNum >= newNeedNum then
				        	return true
				        end
					end
				end
			end
		end
	end
	return false
end

function acMemoryServerVoApi:updateData(data)
	if data then
        local vo = self:getAcVo()
        if vo then
        	vo:updateData(data)
        	activityVoApi:updateShowState(vo)
        end
    end
end

function acMemoryServerVoApi:clearAll()
	self.bindServerList = nil
end