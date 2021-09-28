-- Filename：	CheckVerionLogic.lua
-- Author：		Cheng Liang
-- Date：		2014-4-24
-- Purpose：		检测更新的逻辑

module ("CheckVerionLogic", package.seeall)

require "script/GlobalVars"
require "script/ui/network/LoadingUI"
require "script/utils/SupportUtil"

Code_NetWork_Error		= 0 	-- 网络请求出错
Code_WebClient_Error	= -1 	-- Web端出错，返回参数格式不对
Code_Version_Error		= -2 	-- 客户端的脚本版本号不在Web端的DB中
Code_Unkown_ErrorId 	= -3 	-- Web端的返回ErrorId 未知

Code_Update_None		= 1 	-- 无任何更新
Code_Update_Base		= 2 	-- 底包更新
Code_Update_Script		= 3		-- 脚本更新


local m_updateDelegate = nil		-- 更新的代理方法

local m_download_url = nil 		-- 缓存底包下载地址
local m_tip = nil 				-- 下载文本提示

-- check的URL
local g_checkVerion_url = ""
if( g_debug_mode == true)then
	g_checkVerion_url = "http://192.168.1.38/phone/get3dVersion?"
else
	if Platform.getDomain ~= nil then
		g_checkVerion_url = Platform.getDomain() .. "phone/get3dVersion?"
	else
		g_checkVerion_url = Platform.getDomain() .. "phone/get3dVersion?"
		if SupportUtil.isSupportHttps() then
			g_checkVerion_url = Platform.getDomain() .. "phone/get3dVersion?"
		end
	end
end

-- 检查版本信息
function startCheckVersion(updateDelegate)
	m_updateDelegate = updateDelegate

	if(m_updateDelegate == nil or type(m_updateDelegate)~="function")then
		print("error： updateDelegate 必须是一个代理方法 ")
		return
	end

	LoadingUI.addLoadingUI()
	local check_version_url = g_checkVerion_url .. "&packageVer=" .. g_publish_version .. "&scriptVer="..g_game_version  .. Platform.getUrlParam()
	
	if(NSBundleInfo)then
		local extend = "&extend=sysName_" .. string.urlEncode(NSBundleInfo:getSysName()) .. ",sysVersion_" .. string.urlEncode(NSBundleInfo:getSysVersion()) .. ",deviceModel_" .. string.urlEncode(NSBundleInfo:getDeviceModel())
		if( string.checkScriptVersion(g_publish_version, "3.0.0") >= 0 and Platform.getPlatformFlag() == "appstore" )then
			extend = extend .. ",netstatus_" .. NSBundleInfo:getNetworkStatus()
		end
		check_version_url = check_version_url .. extend
	end
	print("check_version_url==", check_version_url)
	local httpClient = CCHttpRequest:open(check_version_url, kHttpGet)
	httpClient:sendWithHandler(checkVersionCallback)
end


-- 版本检查结果
function checkVersionCallback( res, hnd )
	local versionJsonString = res:getResponseData()
	local retCode = res:getResponseCode()
	LoadingUI.reduceLoadingUI()

	local statusCode = Code_NetWork_Error
	local version_info = nil

	if( retCode ~= 200 )then
		-- 请求出错
		statusCode = Code_NetWork_Error
		
	elseif type(versionJsonString) == "string" and string.len(versionJsonString) > 0 then

		local cjson = require "cjson"
	    version_info = cjson.decode(versionJsonString)
	    if( table.isEmpty(version_info) == true )then
	    	-- 结构不对
	    	statusCode = Code_WebClient_Error
	    else
	    	if( version_info.base and not table.isEmpty(version_info.base) and version_info.base.is_force == 1)then
	    		-- 更新底包
	    		statusCode = Code_Update_Base
	    		m_download_url = version_info.base.package.packageUrl
	    		m_tip = version_info.base.package.tip
	    	elseif(version_info.script and not table.isEmpty(version_info.script)  ) then
	    		-- 脚本更新
	    		statusCode = Code_Update_Script
	    		
	    	elseif( version_info.error_id )then
	    		if(version_info.error_id == 200)then
		    		-- 不需要任何更新
		    		statusCode = Code_Update_None

		    	elseif(version_info.error_id == 401)then
		    		-- 客户端的脚本版本号不在Web端的DB中 低于Web端的最小scriptVersion
		    		statusCode = Code_Version_Error

		    	elseif(version_info.error_id == 402)then
		    		-- 客户端的脚本版本号不在Web端的DB中 超过了Web端的最大scriptVersion
		    		statusCode = Code_Version_Error

		    	else
		    		-- Web端的返回ErrorId 未知
		    		statusCode = Code_Unkown_ErrorId
		    	end
	    	else
	    		statusCode = Code_WebClient_Error

	    	end
	    end
	else
		-- 返回值为空
		statusCode = Code_WebClient_Error
	end
	m_updateDelegate(statusCode, version_info)
end


-- 
function getPackDownloadUrl()
	return m_download_url
end

function getTipText()
	return m_tip
end






