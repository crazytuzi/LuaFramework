-- Filename：	ActivityConfigUtil.lua
-- Author：		lichenyang
-- Date：		2011-1-8
-- Purpose：		活动配置工具类

require "script/model/utils/ActivityConfig"
require "script/ui/login/ServerList"
require "script/utils/TimeUtil"
module("ActivityConfigUtil" , package.seeall)

-- 新活动观察者容器
local observerContainer = {}

-- 活动配置持久化文件路径
local persistentFile = CCFileUtils:sharedFileUtils():getWritablePath() .. "ActivityConfig.cfg"
local newPersistentFile = CCFileUtils:sharedFileUtils():getWritablePath() .. "ActivityConfig.cfg." .. ServerList.getSelectServerInfo().group
--[[
	@des:	根据活动key 得到活动相关数据
	@parm:	
--]]
function getDataByKey(key )
	return ActivityConfig.ConfigCache[tostring(key)]
end

--[[
	@des:判断活动是否开启
--]]
function isActivityOpen( key )
	local activity_data  = ActivityConfig.ConfigCache[tostring(key)]
	if(activity_data == nil) then
		--如果没有活动数据，则默认认为活动没有开启
		return false
	end 

	local openServerTime = tonumber(ServerList.getSelectServerInfo().openDateTime)
	local startTime 	 = tonumber(activity_data.start_time)
	local overTime 		 = tonumber(activity_data.end_time)
	local needOpenTime 	 = tonumber(activity_data.need_open_time)
	local nowTime 		 = tonumber(BTUtil:getSvrTimeInterval())

	print("startTime:", startTime, "overTime:", overTime, "needOpenTime:", needOpenTime, "openServerTime:",openServerTime, "nowTime:", nowTime)

	--单时间短判断条件
	local isBigActivityOpen = false
	if(nowTime > startTime and nowTime < overTime and needOpenTime >= openServerTime) then
		isBigActivityOpen =  true
	else
		isBigActivityOpen = false
	end

	--判断是否支持多时间端 severTime 等同于 need_open_time
	local isSuportMany = false
	for k,v in pairs(activity_data.data) do
		if(v.openTime ~= nil and v.endId ~= nil and v.severTime ~= nil) then
			isSuportMany = true
			break
		end
	end
	if(isSuportMany) then
		local openDataIndex = 0
		for k,v in pairs(activity_data.data) do
			print("startTime:", v.openTime, "overTime:", v.endId, "needOpenTime:", v.severTime)

			if(nowTime > TimeUtil.getIntervalByTimeDesString(v.openTime) and nowTime < TimeUtil.getIntervalByTimeDesString(v.endId) and TimeUtil.getIntervalByTimeDesString(v.severTime) >= openServerTime) then
				openDataIndex = tonumber(k)
				break
			end
		end
		if(openDataIndex > 0) then
			--替换数据为 当前开启活动的数据
			local openData = {}
			table.hcopy(activity_data.data[openDataIndex], openData)
			activity_data.data[openDataIndex] = activity_data.data[1]
			activity_data.data[1] = openData
			startTime = TimeUtil.getIntervalByTimeDesString(openData.openTime)
			overTime = TimeUtil.getIntervalByTimeDesString(openData.endId)
			needOpenTime = TimeUtil.getIntervalByTimeDesString(openData.severTime)
			isBigActivityOpen =  true
		else
			isBigActivityOpen = false
		end
	end
	--屏蔽活动判断
	if isOpenValid() then
		local validityData  = ActivityConfig.ConfigCache["validity"].data[1]
		local validStaTime = tonumber(ActivityConfig.ConfigCache["validity"].start_time)
		local validEndTime = tonumber(ActivityConfig.ConfigCache["validity"].end_time)
		if validityData and validityData.content then
			local validnames = string.split(validityData.content, "|")
			for k,v in pairs(validnames) do
				if key == v and validStaTime <= startTime and validEndTime >= overTime then
					isBigActivityOpen =  false
				end
			end
		end
	end
	return isBigActivityOpen
end

--[[
	@des:判断屏蔽活动是否开启
--]]
function isOpenValid()
	local activity_data  = ActivityConfig.ConfigCache["validity"]
	if(activity_data == nil) then
		--如果没有活动数据，则默认认为活动没有开启
		return false
	end
	local openServerTime = tonumber(ServerList.getSelectServerInfo().openDateTime)
	local startTime 	 = tonumber(activity_data.start_time)
	local overTime 		 = tonumber(activity_data.end_time)
	local needOpenTime 	 = tonumber(activity_data.need_open_time)
	local nowTime 		 = tonumber(BTUtil:getSvrTimeInterval())
	--单时间短判断条件
	local isBigActivityOpen = false
	if(nowTime > startTime and nowTime < overTime and needOpenTime >= openServerTime) then
		isBigActivityOpen =  true
	else
		isBigActivityOpen = false
	end
	return isBigActivityOpen
end



--[[
	@des	:	处理活动数据，并持久化数据
	@parm	:	bool 是否是推送数据
--]]
function process( activity_data, isPushMsg )

	--版本对比
	local serverVersion = tonumber(activity_data.version)
	-- if(serverVersion < tonumber(ActivityConfig.ConfigCache.version)) then
	-- 	return
	-- end
	ActivityConfig.ConfigCache.version = serverVersion	--更新本地版本
	local newActivityKeys = {}	--新活动
	--添加缓存数据
	for k,v in pairs(activity_data.arrData) do
		ActivityConfig.ConfigCache[tostring(k)] 				= {}
		ActivityConfig.ConfigCache[tostring(k)].version 		= tonumber(v.version)
		ActivityConfig.ConfigCache[tostring(k)].start_time		= tonumber(v.start_time)
		ActivityConfig.ConfigCache[tostring(k)].end_time		= tonumber(v.end_time)
		ActivityConfig.ConfigCache[tostring(k)].need_open_time	= tonumber(v.need_open_time)
		if(v.data ~= nil or v.data ~= "") then
			ActivityConfig.ConfigCache[tostring(k)].data = assemble(ActivityConfig.keyConfig[k], v.data)
		end
		--处理开服活动
		if(v.newServerActivity ~= nil) then
			ActivityConfig.ConfigCache[tostring(k)].data = assembleNewServerActivity(k)
		end
		--处理新活动通知
		if(isPushMsg == true) then
			table.insert(newActivityKeys, tostring(k))
		end
	end
	reviceNewActivity(newActivityKeys)
	--持久化新配置
	persistentActivity(ActivityConfig.ConfigCache)
end

--[[
	@des	:	把csv生成的数据数据转换成lua的带字符key的table
	@parm	:	keys 键值描述表，datas 数据表csv
	@return	:	table
--]]
function assemble( keys,datas )
	if(keys == nil) then
		return {}
	end

	local assembleLine = function ( keyTable, lineData )
		local rs= {}
		local i = 1
		for k,v in pairs(keyTable) do
			rs[tostring(v)] = lineData[tonumber(i)]
			i = i + 1
		end
		return rs
	end
	require "script/utils/CsvParse"
	local resTable 	= {}
	local luaData 	= CsvParse.parse(datas)
	-- print("luaData = :")
	-- print_t(luaData)
	for k,v in pairs(luaData) do
		if(v[1] ~= nil and v[1] ~= "") then
			resTable[tonumber(v[1])] = assembleLine(keys, v)
		else
			break
		end
	end
	return resTable
end


--[[
	@des	:	组装开服活动数据
--]]
function assembleNewServerActivity( key)
	print("assembleNewServerActivity", key)
	local assembleLine = function ( keyTable, lineData )
		local rs= {}
		local i = 1
		for k,v in pairs(keyTable) do
			rs[tostring(v)] = lineData[tonumber(i)]
			i = i + 1
		end
		return rs
	end

	local data = ActivityConfig.getNewServerData(key)
	local retData = {}
	local count = table.count(data)
	for i=1,count do
		local lineData
		if key == "weal" then
			lineData = data["id_11"]
		else
			lineData = data["id_" .. i]
		end
		retData[i] = assembleLine(ActivityConfig.keyConfig[key], lineData)
		if key == "weal" then
			local activity_data  = ActivityConfig.ConfigCache[key]
			retData[i]["openTime"] = TimeUtil.getTimeDesStringByInterval(tonumber(activity_data.start_time))
			retData[i]["endId"] = TimeUtil.getTimeDesStringByInterval(tonumber(activity_data.end_time))
		end
	end
	return retData
end




--[[
	@des	:	持久化活动数据
--]]
function persistentActivity( activity_data )
	--删除老的配置文件
	os.remove(newPersistentFile)
	--序列号活动配置数据
	local activityBuffer =  table.serialize(activity_data)
	print("persistentActivity activityBuffer = ", activityBuffer)
	--持久化新活动配置文件

	local activityBufferMd5Code = BTUtil:getMd5SumByString(activityBuffer)
	-- 存储 配置md5值
	CCUserDefault:sharedUserDefault():setStringForKey("ActivityConfigBufferCode_" .. ServerList.getSelectServerInfo().group, activityBufferMd5Code)
	CCUserDefault:sharedUserDefault():flush()

	local file = io.open(newPersistentFile,"w")
	file:write(activityBuffer)
	file:close()
end

--[[
	@des	:	加载持久化的活动配置文件
--]]
function loadPersitentActivityConfig()

	local inputFile = nil
	--判断文件是否存在
	if(CCFileUtils:sharedFileUtils():isFileExist(newPersistentFile) == true) then
		inputFile      = newPersistentFile
		persistentFile = newPersistentFile
	else
		ActivityConfig.ConfigCache.version = 0
		if(CCFileUtils:sharedFileUtils():isFileExist(persistentFile) == true) then
			inputFile = persistentFile
		else
			--读取失败
			print("ActivityConfig file don't find")
			return
		end
	end
	--读取持久化的活动配置
	io.input(inputFile)
	local activityBuffer = io.read("*all")
	print("loadPersitentActivityConfig activityBuffer:\n", activityBuffer)

	if(activityBuffer == nil or activityBuffer == "") then
		--读取失败
		ActivityConfig.ConfigCache.version = 0
		return
	end

	--验证配置md5值
	local newConfigMd5Code = BTUtil:getMd5SumByString(activityBuffer)
	local oldConfigMd5Code = CCUserDefault:sharedUserDefault():getStringForKey("ActivityConfigBufferCode_" .. ServerList.getSelectServerInfo().group)
	if(newConfigMd5Code ~= oldConfigMd5Code) then
		--文件未能完整存储
		ActivityConfig.ConfigCache.version = 0
		return
	end

	--加载配置数据
	ActivityConfig.ConfigCache = table.unserialize(activityBuffer)
	if ActivityConfig.ConfigCache == nil then
		--如果本地数据出错，处理方法
		ActivityConfig.ConfigCache = {}
		ActivityConfig.ConfigCache.version = 0
		return
	end
end


--[[
	@des:	接受新活动方法
--]]
function reviceNewActivity( newActivityKeys )
	for k,observerFunc in pairs(observerContainer) do
		if(observerFunc ~= nil) then
			observerFunc(newActivityKeys)
		end
	end
end

--[[
	@des:	注册观察者
--]]
function addObserver( observerFunc )
	table.insert(observerContainer, observerFunc)
end

--[[
	@des:	移除观察者
--]]
function removeObserver( observerFunc )
	for k,v in pairs(observerContainer) do
		if(observerFunc == v) then
			observerContainer[k] = nil
		end
	end
end
