--[[
	灰度策略文件
	本策略文件根据两个ID进行匹配
	remote.user.userId和上次登录记录的localUserId
	对于灰名单来说id为空则视为匹配
	对于白名单来说id为空则视为不匹配

	注意：白名单和黑名单同时存在只生效白名单
	example:
		"ENABLE_INCREMENTAL_UPDATE": 					--key值
		{
			"value":false, 								--value值，直接设置该key值是多少
			"IDType":"offline",							--在value值未设置的情况下，检查IDType的类型是多少
			"whiteList":								--白名单
			[
				"7180029f-1f50-4fb1-9bd7-543de9d8e3a6",
				"8bc5dd89-8bb9-4e04-b912-6e88c7c1a587"
			],
			"blackList":								--黑名单
			[
				"a76b840d-2daf-4f34-99f7-9b16e0750557"
			]
			"exeStr":"print(1) app.isNativeLargerEqualThan = function() return true end", --执行脚本
		}
]]--
local QGray = class("QGray")


QGray.QGRAY_LAST_USER_ID = "QGRAY_LAST_USER_ID"

QGray.GRAY_ID_TYPE_OFFLINE = "offline" --本地存储上一次登陆的ID，如果ID不存在则视为false
QGray.GRAY_ID_TYPE_ONLINE = "online" --当前在线登陆之后的ID，如果ID不存在则视为false

function QGray:ctor(options)
	self._list = {}
	self:loadGrayId()
	if ENABLE_GRAY then
		self:checkNetWork()
	end
end

function QGray:checkNetWork( ... )
	if CCNetwork:isInternetConnectionAvailable() then
		self:downloadPolicy()
	else
		device.showAlert("提示", "读取配置文件失败，确认连接网络重试！", {"重试"}, function (event)
	        print("event", event.buttonIndex)
	        if event.buttonIndex == 1 then
	        	self:checkNetWork()
	        end
	    end)
	end
end

--加载本地记录的上一次ID
function QGray:loadGrayId()
	self._lastLoginId = QUserDefault:sharedUserDefault():getStringForKey(QGray.QGRAY_LAST_USER_ID)
end

--记录最后一次登录的ID
function QGray:setGrayId(userId)
	QUserDefault:sharedUserDefault():setStringForKey(QGray.QGRAY_LAST_USER_ID, userId)
	self._currentLoginId = userId
	self:_applyPolicy()
end

--获取最后一次登录的ID
function QGray:getGrayId()
	return  self._lastLoginId
end

--获取最后一次登录的ID
function QGray:getLoginId()
	return  self._currentLoginId
end

--获取线上的策略文件
function QGray:downloadPolicy()
	local downloader = QDownloader:new(CCFileUtils:sharedFileUtils():getWritablePath(), 1)
	local policyFile = downloader:downloadContent(VERSION_URL..string.format("grayPolicy.json?v=%s", q.serverTime()), false)
	-- local URL = string.format("http://7x2w5y.com1.z0.glb.clouddn.com/grayPolicy.json?v=%s", q.serverTime())
	-- local policyFile = downloader:downloadContent(URL, false)
   	local policyConfig = json.decode(policyFile)
   	self.policyConfig = policyConfig
	self:_applyPolicy()
    if downloader.removeSelf then
        downloader:removeSelf()
    elseif  downloader.purge then
        downloader:purge()
    end
end

--使用线上的策略文件
function QGray:_applyPolicy()
	if self.policyConfig == nil then
		return
	end
	for k,v in pairs(self.policyConfig) do
		local result = self:_analysisPolicy(v)
		if result ~= nil then
			_G[k] = result
		end
	end
end

function QGray:_analysisPolicy(v)
	if v.exeStr ~= nil then
		local state = pcall(load(v.exeStr))
		if state == false then
			print("try runing code: ", v.exeStr)
		end
		return
	end
	
	if v.value ~= nil then
		return v.value == true
	end

	if v.IDType ~= nil then
		local checkId = nil
		if v.IDType == QGray.GRAY_ID_TYPE_OFFLINE then
			checkId = self:getGrayId()
		elseif v.IDType == QGray.GRAY_ID_TYPE_ONLINE then
			checkId = self:getLoginId()
		end
		if checkId == nil then
			return false
		end
		if v.whiteList ~= nil then
			for _,id in ipairs(v.whiteList) do
				if id == checkId then
					return true
				end
			end
			return false
		elseif v.blackList ~= nil then
			for _,id in ipairs(v.blackList) do
				if id == checkId then
					return false
				end
			end
			return true
		end
	end
	return false
end

return QGray