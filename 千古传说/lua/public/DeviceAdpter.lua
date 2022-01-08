--[[
    设备适配，负责：
    1、管理内存释放
    2、管理图片在内存中的格式规则
]]
local DeviceAdpter = {}

--[[
	指定设备自动释放内存的最小占用内存大小
]]
DeviceAdpter.MaxOccupyMemorySize = 102400
--[[
	低剩余内存大小定义
]]
DeviceAdpter.lowFreeMemorySize = 8 * 1024

--[[
	是否跳过资源释放检测
]]
DeviceAdpter.skipMemoryWarning = false


function substringForMemoryExpression(str)
	if type(str) == 'string' and (str[#str] == 'K' or str[#str] == 'k') then 
		str = str[{1, #str-1}]
	end
	return str
end

--[[
	IOS内存警告监听
]]
function MemoryWarning()
	--当设备剩余内存小于指定值时，释放内存
	local freeMem = tonumber(substringForMemoryExpression(TFDeviceInfo.getFreeMem()))
	if freeMem < DeviceAdpter.lowFreeMemorySize then
		-- me.ArmatureDataManager:removeUnusedArmatureInfo()
		-- CCDirector:sharedDirector():purgeCachedData()
		autoMemoryByGame()
		return
	end

	--当设备占用内存比指定的内存自动释放大小时，释放内存
	local useCount,totalCount,useMemory,totalMemory = calculateTextureCache()
	if totalMemory > DeviceAdpter.MaxOccupyMemorySize then
		if totalMemory > useMemory then
			-- me.ArmatureDataManager:removeUnusedArmatureInfo()
			-- CCDirector:sharedDirector():purgeCachedData()
			autoMemoryByGame()
			return
		end
	end

	if DeviceAdpter.skipMemoryWarning then
		return
	end

	-- me.ArmatureDataManager:removeUnusedArmatureInfo()
	-- CCDirector:sharedDirector():purgeCachedData()
end

--[[
初始化
]]
function DeviceAdpter:init()
	if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
		DeviceAdpter:initForAndroid()
	elseif CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
		DeviceAdpter:initForIOS()
	end
	print("DeviceAdpter.MaxOccupyMemorySize : ",DeviceAdpter.MaxOccupyMemorySize)
end

--[[
	IOS初始化
]]
function DeviceAdpter:initForIOS()
	DeviceAdpter.totalMemory = tonumber(substringForMemoryExpression(TFDeviceInfo.getTotalMem()))
	local freeMemory = tonumber(substringForMemoryExpression(TFDeviceInfo.getFreeMem()))
	
	if DeviceAdpter.totalMemory < 700 * 1024 then
		if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
			DeviceAdpter.MaxOccupyMemorySize = 102400
		else
			DeviceAdpter.MaxOccupyMemorySize = freeMemory - 8192
		end
		CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	else
		DeviceAdpter.MaxOccupyMemorySize = 204800
	end
end

--[[
	Android初始化
]]
function DeviceAdpter:initForAndroid()
	DeviceAdpter.totalMemory = tonumber(substringForMemoryExpression(TFDeviceInfo.getTotalMem()))
	local freeMemory = tonumber(substringForMemoryExpression(TFDeviceInfo.getFreeMem()))
	
	if freeMemory > 163840 then
		DeviceAdpter.MaxOccupyMemorySize = freeMemory - 16384
	else
		if DeviceAdpter.totalMemory < 700 * 1024 then
			DeviceAdpter.MaxOccupyMemorySize = freeMemory - 8192
			CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
		else
			DeviceAdpter.MaxOccupyMemorySize = 204800
		end
	end
end

--[[
	注册内存释放定时器
]]
function registMemoryReleaseTimer(delay)
	if CC_TARGET_PLATFORM ~= CC_PLATFORM_ANDROID then
		return
	end

	local repeatMS = delay or 1000
	TFDirector:addTimer(repeatMS,-1,nil,autoMemoryRelease)
end

--[[
  自动释放内存
]]
function autoMemoryRelease()
	print("autoMemoryRelease .... ")
	if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
		autoMemoryReleaseForAndroid()
	end
end

--[[
	Android平台内存自动释放
]]
function autoMemoryReleaseForAndroid()
	local freeMemory = tonumber(substringForMemoryExpression(TFDeviceInfo.getFreeMem()))
	if freeMemory < DeviceAdpter.lowFreeMemorySize then
		-- me.ArmatureDataManager:removeUnusedArmatureInfo()
		-- CCDirector:sharedDirector():purgeCachedData()
		autoMemoryByGame()
	end
end
--[[
	游戏过程中内存不足逐步释放内存
]]
function autoMemoryByGame()
	local currentScene = Public:currentScene()
    if currentScene.__cname == "FightResultScene" or currentScene.__cname == "FightScene" then
		if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
			AlertManager:MemoryWarning()
		else
			AlertManager:clearAllCache()
		end
    else
		if GameResourceManager:MemoryWarning() then
			return
		end
		AlertManager:MemoryWarning()
    end
end


registMemoryReleaseTimer(30*1000)

DeviceAdpter:init()
return DeviceAdpter