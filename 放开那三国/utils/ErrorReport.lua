-- Filename：	CrashReport.lua
-- Author：		Cheng Liang
-- Date：		2014-6-16
-- Purpose：		提交错误日志

module("ErrorReport", package.seeall)

local report_url = "http://debug.zuiyouxi.com:17801/index.php?"

local max_report_count = 3		-- 相同问题最多report的次数，主要防止定时器触发的错误导致无限report

local err_stack = {}



local function getUserParam( pre_file )

	local param = ""
	param = "&pid=" .. Platform.getPid()
    param = param .. "&env=lua"
    param = param .. "&gn=sanguo_" .. Platform.getPlatformFlag()
    param = param .. "&os="..Platform.getOS()
    param = param .. "&pl="..Platform.getPlatformFlag()
    param = param .. "&publish=" .. g_publish_version
    param = param .. "&script=" .. g_game_version 

    return param
end 

local function isCanReport( err_msg )
	local isReport = true
	
	if(err_stack[err_msg] == nil)then
		isReport = true
		err_stack[err_msg] = 1
	elseif(err_stack[err_msg] < max_report_count)then
		isReport = true
		err_stack[err_msg] = err_stack[err_msg] + 1
	else
		isReport = false
	end

	return isReport
end 

function luaErrorReport( err_msg, file_name )
	if(isCanReport( err_msg ) == false)then
		return
	end
	local param = getUserParam(file_name)
	param = param .. "&err_msg=" .. err_msg .. "&lua_traceback=" .. debug.traceback() .. "&lua_tracebackex=" .. Platform.tracebackex()
	-- param = string.gsub(param,"\n","<br>")
	-- param = string.gsub(param,"\r","<br>")

	local reportCallback = function (  res, hnd )
	    -- local responseData = res:getResponseData()
	    -- local retCode = res:getResponseCode()
	    -- print("responseData==", responseData)
	    -- print("retCode==", retCode)
	end
	local httpClient = CCHttpRequest:open(report_url, kHttpPost)
	
	httpClient:setRequestData(param, string.len(param))
	httpClient:sendWithHandler(reportCallback)
end




