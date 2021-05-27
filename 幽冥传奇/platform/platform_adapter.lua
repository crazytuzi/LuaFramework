require("scripts/platform/platform_binder")

PlatformAdapter = PlatformAdapter or {}
PlatformAdapter.cache_path = ""

function PlatformAdapter:GetPackageInfo()
	--new
	if cc.FileUtils:getInstance():isFileExist("agentres/agent_cfg.txt") or PLATFORM == cc.PLATFORM_OS_WINDOWS then
		local agent_package_info = cjson.decode(UtilEx:readText("agentres/agent_cfg.txt"))
		if agent_package_info ~= nil and agent_package_info.config ~= nil then
		return agent_package_info
		end
	end
	
	return cjson.decode(PlatformBinder:JsonCall("call_get_package_info")) or {}
end

function PlatformAdapter:GetAssetsInfo()
	return cjson.decode(UtilEx:readText("version.txt")) or {}
end

-- function PlatformAdapter:GetLocalConfig()
	-- local local_cfg = cjson.decode(UtilEx:readText(UtilEx:getDataPath() .. "config.txt")) or {}
	-- if nil == local_cfg.init_url then
		-- local pkg_info = self:GetPackageInfo()
		-- local_cfg.init_url = pkg_info.config.init_url
	-- end
	-- if nil == local_cfg.report_url then
		-- local pkg_info = self:GetPackageInfo()
		-- local_cfg.report_url = pkg_info.config.countly_report_url
	-- end
	-- return local_cfg
-- end

--new
function PlatformAdapter.GetServerIp()
	local clienturl = "http://192.168.1.4"
	
	return clienturl
end

--注册
function PlatformAdapter.GetregisterIp()
	local clienturl = PlatformAdapter.GetServerIp() .. "/login_reg/register.php"
	return clienturl
end

--登录
function PlatformAdapter.GetloginIp()
	local clienturl = PlatformAdapter.GetServerIp() .. "/login_reg/login.php"
	return clienturl
end
function PlatformAdapter:GetLocalConfig()
	local getweburl=PlatformAdapter.GetServerIp()
	return 
	{
		init_url = getweburl .. "/args.php"
	}
end


function PlatformAdapter:SaveLocalConfig(local_cfg)
	if nil == local_cfg then return end

	local cfg_text = cjson.encode(local_cfg)
	if nil ~= cfg_text then
		UtilEx:writeText(UtilEx:getDataPath() .. "config.txt", cfg_text)
	end
end

function PlatformAdapter:GetShareDataFromFile()
	local local_cfg = cjson.decode(UtilEx:readText(UtilEx:getDataPath() .. "sharedata.txt")) or {}
	return local_cfg
end

function PlatformAdapter:SaveShareDataToFile(data)
	if nil == data then return end
	local cfg_text = cjson.encode(data)
	if nil ~= cfg_text then
		UtilEx:writeText(UtilEx:getDataPath() .. "sharedata.txt", cfg_text)
	end
end

function PlatformAdapter:GetShareValueByKey(key)
	return GLOBAL_CONFIG.share_data[key]
end

function PlatformAdapter:SaveShareValue(key, value)
	GLOBAL_CONFIG.share_data[key] = value
	self:SaveShareDataToFile(GLOBAL_CONFIG.share_data)
end

function PlatformAdapter:UpdatePackage(pkg_info)
	PlatformBinder:JsonCall("call_update_package", cjson.encode(pkg_info))
end

function PlatformAdapter:GetNetState()
	return tonumber(PlatformBinder:JsonCall("call_get_net_state")) or 0
end

--format = { icon = 1, title = "退出", message = "退出", positive = "确定", negative = "取消", neutral = "一般", }
function PlatformAdapter:OpenAlertDialog(format, callback)
	PlatformBinder:JsonCall("call_open_alert_dialog", cjson.encode(format), "", callback)
end

function PlatformAdapter:OpenExitDialog()
	local format = { title = "退出", message = "退出游戏?", positive = "确定", negative = "取消", }

	self:OpenAlertDialog(format, function (result) if "positive" == result then AdapterToLua:endGame() end end)
end

function PlatformAdapter:OpenBrowser(url)
	PlatformBinder:JsonCall("call_open_browser", url)
end

-- 获取缓存目录
function PlatformAdapter.GetCachePath()
	if "" == PlatformAdapter.cache_path then
		PlatformAdapter.cache_path = UtilEx:getDataPath() .. "cache/"
	end
	
	return PlatformAdapter.cache_path
end

-- 复制文字到剪切板
function PlatformAdapter.CopyStrToClipboard(str)
	PlatformBinder:JsonCall("call_copy_to_clipboard", str)
end

-- 获取电池电量，return(0 ~ 100)
function PlatformAdapter.GetBatteryPercent()
	return tonumber(PlatformBinder:JsonCall("call_get_battery_level")) or 0
end

-- 打开相册
function PlatformAdapter.OpenPhoto(callback)
	PlatformBinder:JsonCall("call_create_avatar", "{\"open_camera\":false}", "", 
		function(path) GlobalTimerQuest:AddDelayTimer(function() callback(path) end, 0) end)
end

-- 打开相机
function PlatformAdapter.OpenCamera(callback)
	PlatformBinder:JsonCall("call_create_avatar", "{\"open_camera\":true}", "", 
		function(path) GlobalTimerQuest:AddDelayTimer(function() callback(path) end, 0) end)
end

-- 移动文件, return是否成功
function PlatformAdapter.MoveFile(srcpath, dstpath)
	print("PlatformAdapter.MoveFile " .. srcpath .. " -> " .. dstpath)
	
	return UtilEx:moveFile(srcpath, dstpath)
end

-- 删除文件, return是否成功
function PlatformAdapter.RemoveFile(path)
	return UtilEx:removeFile(path)
end

-- 获取内存状态 { rss, pss, uss }
function PlatformAdapter.GetMemStatus()
	return cjson.decode(PlatformBinder:JsonCall("call_get_mem_status"))
end

-- 获取设备内存大小
function PlatformAdapter.GetDeviceMemSize()
	return tonumber(PlatformBinder:JsonCall("call_get_device_mem_size")) or 0
end
--请求打开浏览器
function PlatformAdapter.openURL(url)
	if not url then return end

	if PLATFORM == cc.PLATFORM_OS_WINDOWS then
		Log("open url ",url)
	elseif PLATFORM == cc.PLATFORM_OS_ANDROID then
		local luaj=require("scripts/cocos2d/luaj")
		local javaClassName = "org/cocos2dx/lib/Cocos2dxActivity"
		local javaMethodName = "openURL"
		local javaParams = {url}
		local javaMethodSig = "(Ljava/lang/String;)V"
		local ok,ret = luaj.callStaticMethod(javaClassName,javaMethodName,javaParams,javaMethodSig)
		if not ok then
			Log("luaj error:", ret)
		else
			Log("openURL success")
		end
	elseif PLATFORM == 2 then
		local ocMethodName = "openURL"
		local ocParams = {url=url}
		luaoc.callStaticMethod(ocClassName,ocMethodName,ocParams)
	end
end					   														   
--请求打开webview
function PlatformAdapter.OpenWebView(url, is_need_back_btn, can_portrait)
	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()
	local arg_t = {url = url, screen_w = screen_w, screen_h = screen_h}
	if is_need_back_btn then
		arg_t.is_need_back_btn = 1
	end
	if can_portrait then
		arg_t.can_portrait = 1
	end

	PlatformBinder:JsonCall("call_open_webview", cjson.encode(arg_t))
end

--关闭webview
function PlatformAdapter.CloseWebView()
	PlatformBinder:JsonCall("call_close_webview", cjson.encode(arg_t))
end

--获得手机的唯一id
function PlatformAdapter.GetPhoneUniqueId()
	return PlatformBinder:JsonCall("call_get_phone_unique_id")
end

--获得安卓手机的imei
function PlatformAdapter.GetPhoneUniqueIMEI()
	return PlatformBinder:JsonCall("call_get_android_imei") or ""
end

--获得设备系统版本号
function PlatformAdapter.GetPhoneVsersion()
	return PlatformBinder:JsonCall("call_get_phone_version") or ""
end


--获得当前ip地址
function PlatformAdapter.GetIpAddress()
	-- return PlatformBinder:JsonCall("call_get_ip_address") 
	if nil ~= GLOBAL_CONFIG.param_list and nil ~= GLOBAL_CONFIG.param_list.client_ip then
		return GLOBAL_CONFIG.param_list.client_ip
	end

	return "0.0.0.0"
end

function PlatformAdapter.GetListZipPath()
	return "list.zip"
end

function PlatformAdapter.GetIosVersion()
	return PlatformBinder:JsonCall("call_get_ios_version")	
end

function PlatformAdapter.GetDeviceType()
	if cc.PLATFORM_OS_ANDROID == PLATFORM then
		return "a"
	elseif cc.PLATFORM_OS_IPHONE == PLATFORM 
	or cc.PLATFORM_OS_IPAD == PLATFORM 
	or cc.PLATFORM_OS_MAC == PLATFORM then
		return "i"
	elseif cc.PLATFORM_OS_WINDOWS == PLATFORM then
		return "w"
	else
		return "u"
	end
end

--获得刘海屏高度
function PlatformAdapter.GetStatusBarHeight()
	return tonumber(PlatformBinder:JsonCall("call_get_statusBar_height")) or 0
end




