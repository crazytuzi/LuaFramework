-- ErrorCodeManager
-- Author: Stephen
-- Date: 2014-03-03 12:22:10
--


local TFBaseManager 		= require('TFFramework.client.manager.TFBaseManager')
local ErrorCodeManager 	= class('ErrorCodeManager', TFBaseManager)
local ErrorCodeManagerModel 	= {}
local TextIndex = require('language.textIndex')
local reportErrorTime = 0

function ErrorCodeManager:reset()
	ErrorCodeManagerModel.tEvents = {}
end

function ErrorCodeManager:ctor()
	ErrorCodeManagerModel.tEvents = {}
	TFDirector:addProto(s2c.ERROR_CODE, self, self.ErrorCodeMsg)	
end

local function nilCheck(obj, szName)
	if not obj then 
		TFLOGINFO("ErrorCodeManager:[" .. szName .. '] can not be nil')
		return true
	end
	return false
end


--[[--
	添加指定对象的指定协议的指定监听
	@param nProtoType:协议号
	@param func:监听回调
]]
function ErrorCodeManager:addProtocolListener(nProtoType, func)
	if 	nilCheck(nProtoType, 'nProtoType') or
		nilCheck(func, 'func') then
		return	
	end
	local tEvents = ErrorCodeManagerModel.tEvents
	tEvents[nProtoType] = tEvents[nProtoType] or {}

	local tFuncs = tEvents[nProtoType]
	for k, v in pairs(tFuncs) do
		if v.func and v.func == func then return end
	end
	tFuncs[#tFuncs + 1] = {func = func}
end

--[[--
	移除指定对象的指定协议的指定监听
	@param nProtoType:协议号, 如果为空,表示移除所有协议的监听
	@param func:监听回调, 如果为空,表示移除指定对象的所有监听
]]
function ErrorCodeManager:removeProtocolListener(nProtoType, func)
	if not nProtoType then
		ErrorCodeManagerModel.tEvents = {}
		return
	end

	local tEvents = ErrorCodeManagerModel.tEvents
	if not tEvents[nProtoType] then
		TFLOGWARNING("ErrorCodeManager: Not exist [" .. tostring(nProtoType) .. "]'s Handle")
		return
	end

	local tFuncs = tEvents[nProtoType]
	if not tFuncs then return end
	for k, v in pairs(tFuncs) do
		if v.func == func or func == nil then
			tFuncs[k] = nil
		end
	end
	if #tFuncs == 0 then tEvents[nProtoType] = nil end
	local nLen = 0
	for _ in pairs(tEvents[nProtoType]) do nLen = nLen + 1 end
	if nLen <= 0 then tEvents[nProtoType] = nil end
end


function ErrorCodeManager:execute(callBack, event)
	return TFFunction.call(callBack, event.target, event)
end


--[[--
	派发指定协议事件
	@param nProtoType:协议号
	@param errorCode:协议数据
]]
function ErrorCodeManager:dispatchWith(nProtoType, errorCode)
	if 	nilCheck(nProtoType, 'nProtoType') then
		return false
	end
	local tEvents = ErrorCodeManagerModel.tEvents
	if tEvents[nProtoType] then
		for k, v in pairs(tEvents[nProtoType]) do
			if self:execute(v.func, {name = nProtoType, errorCode = errorCode}) then 
				return true
			end
		end
	end
	return false
end

--[[--
	获取指定协议号下注册的事件列表: {objTargets}:{callbacks}
	如果未指定协议号, 则返回所有协议事件: {nProtoType}:{objTargets}:{callbacks}
	@param nProtoType:协议号
	@return 事件列表
]]
function ErrorCodeManager:list(nProtoType)
	if nProtoType then
		return ErrorCodeManagerModel.tEvents[nProtoType]
	else
		return ErrorCodeManagerModel.tEvents
	end
end


function ErrorCodeManager:getCodeLayer( type , errorCode)
	local data = {}
	data.type = type
	data.errorCode = errorCode

    local str = TFLanguageManager:getString(errorCode)
    if str == "" or str == nil then
    	--toastMessage("未知错误：" .. errorCode)
    	toastMessage(stringUtils.format(localizable.ErrorCodeManager_unknowen_error, errorCode))
    else
    	toastMessage(str)
    end


	-- local layer = require('lua.logic.message.ErrorCodeLayer'):new(data)
	-- AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY)
 --   	AlertManager:show()
 --   	return layer
end

function ErrorCodeManager:ErrorCodeMsg(event)
--[[
// code = 0x7FFF
//通用错误消息，在任意模块操作不能正常完成时下发通用的错误代号，在客户端进行相应的显示和逻辑跳转
message ErrorCodeMsg {
	required int32 errorCode = 1;  //错误代号，全局唯一。在客户端需要实现多语言支持，通过错误代号能够映射到对应的错误提示信息
	optional int32 cmdId = 2; //出现错误的指令请求id，客户端请求服务器时的指令号
}
]]
	hideAllLoading();

	local data = event.data
	local nProtoType = data.cmdId




	if self:dispatchWith(nProtoType, data.errorCode) == false then
		self:getCodeLayer(nil , data.errorCode)
	end

-- TextIndex.server_refuse_service                                             = 3347     --服务器暂时拒绝服务
-- TextIndex.regist_player_already_max                                         = 3348     --注册人数已达到上限，请更换服务器
-- TextIndex.online_number_already_max                                         = 3349     --在线人数已满，请稍后再尝试或者更换服务器登录
-- TextIndex.server_is_maintenance                                             = 3350     --服务器处于维护中，请耐心等待
-- TextIndex.server_open_time_is_not                                           = 3351     --服务器开放时间未到，请耐心等待
-- TextIndex.GAG                                          		 			   = 3358     --您已被禁止发言
-- TextIndex.BAN                                           					   = 3359     --您已被禁止登录
	-- 服务器已满  主动断开连接
	if (data.errorCode >= TextIndex.server_refuse_service and data.errorCode <= TextIndex.server_open_time_is_not) or data.errorCode == TextIndex.BAN then
		print("服务器报错 ，需要主动断开连接")
		CommonManager:closeConnection()
		return
	end

	--quanhuan add
	if data.cmdId == c2s.GET_OTHER_ROLE_DETAILS then
		TFDirector:dispatchGlobalEventWith(OtherPlayerManager.REFRESHDATAOFRANK ,nil)
	end

	if data.errorCode == TextIndex.GUILD_NOT_EXIST then
		FactionManager:initPersonalInfo(0,3)
		TFDirector:dispatchGlobalEventWith(FactionManager.guildNotExist ,nil)
	end

	if data.errorCode == 17429 then
		-- toastMessage(TFLanguageManager:getString(ErrorCodeData.Zone_somebody_attacking))
		toastMessage(localizable.Zone_somebody_attacking)
		FactionManager:requestGuildZoneInfo()
	end


	if data.errorCode == TextIndex.not_pass_level then
		-- 不能扫荡 重置标记
		BloodFightManager.showQuickPassLayer = false
	end 
end



function ErrorCodeManager:checkFileExist(szFullPath)
	if not szFullPath then return true end

	if szFullPath[#szFullPath] == "/" then
		return TFFileUtil:existFile(szFullPath)
	else
		local fileHandle = io.open(szFullPath,'r')
		if not fileHandle then
			return false
		else
			fileHandle:close()
		end

		return true
	end
end


function ErrorCodeManager:createDirIfNotExist(szPath)
	-- body
	local dir = string.match(szPath,".*/")
	if not dir then
		self.szErr = szPath .. " format error"
		return false
	end

	if not self:checkFileExist(dir) then
		bCreateDir = TFFileUtil:createDir(dir)
		if not bCreateDir then
			self.szErr             = "wirte file " .. szPath .."error"
			return false
		end
	end

	return true
end

function ErrorCodeManager:writeToFile(szPath,szContent)
	-- body
	if not szPath then return end

	local fileHandle = nil
	local bWriteRet  = false
	local bCreateDir = false
	
	if not self:createDirIfNotExist(szPath) then
		return false
	end

	fileHandle = io.open(szPath,"wb",szPath)
	if not fileHandle then
		self.szErr             = "wirte file " .. szPath .." error"
		return false
	else
		if szContent then
			bWriteRet = fileHandle:write(szContent)
		end
		fileHandle:close()
	end

	return true
end

function ErrorCodeManager:writeError(errorMsg)

    local sdPath        = ""
    local sPackName     = ""
    local updatePath    = ""

    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        updatePath = CCFileUtils:sharedFileUtils():getWritablePath()
        updatePath = updatePath .. '../Library/'
        updatePath = updatePath .. "TFDebug/"
        updatePath = updatePath .. "/log/"

    elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        sdPath      = TFDeviceInfo.getSDPath()  
        sPackName   = TFDeviceInfo.getPackageName()
        updatePath  = sdPath .."playmore/" .. sPackName .. "/log/"
    else
    	updatePath = updatePath .. "../Library/log/"
    end


    print("updatePath = ", updatePath)
    -- local date = os.date()
    local date      = os.date("*t", os.time())

    print("date = ", date)
    local filename = date.year .. "_" .. date.month .. "_".. date.day .. "_".. date.hour .. "_".. date.min .. "_".. date.sec .. "_error.log"
    
    filename = updatePath..filename

    print("filename = ", filename)
    self:writeToFile(filename, errorMsg)
end

function ErrorCodeManager:reportErrorMsg(errorMsg)

	print("===================ErrorCodeManager:reportErrorMsg=====================")
 
	if reportErrorTime == nil then
		print("reportErrorTime is nil")
		reportErrorTime = os.time()
		print("os.time() = ", os.time())
	end

	local nowTime = os.time()
	print("reportErrorTime = ",reportErrorTime)
	print("nowTime = ",nowTime)
	local timeGap = nowTime - reportErrorTime
	if timeGap < 30 then
		print("每30秒发一次错误报告， 防止定时器内的错误重复报告")
		return
	end
	reportErrorTime = nowTime
	TFDirector:send(c2s.ERROR_REPORT, {errorMsg})


	-- -- 加入打开了写文件 , 记录文件错误
	-- self:writeError(errorMsg)

end

return ErrorCodeManager:new()