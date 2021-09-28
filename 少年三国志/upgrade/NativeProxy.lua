


local NativeCallUtils = require("upgrade.NativeCallUtils")

local NativeProxy = {}
NativeProxy._callback = nil





function NativeProxy.new()

	local sharedApplication = CCApplication:sharedApplication()

	local target = sharedApplication:getTargetPlatform()
	NativeProxy.model = ""
	NativeProxy.platform = ""
	
	if target == kTargetWindows then
	    NativeProxy.platform = "windows"
	elseif target == kTargetMacOS then
	    NativeProxy.platform = "mac"
	elseif target == kTargetAndroid then
	    NativeProxy.platform = "android"
	    NativeProxy.model = tostring(NativeProxy.native_call("getDeviceType", {}, "string"))
	    NativeProxy.memory= tostring(NativeProxy.native_call("getDeviceMemory", {}, "string"))
	    NativeProxy.cpu= tostring(NativeProxy.native_call("getDeviceCpu", {}, "string"))
	elseif target == kTargetWP8 or target == kTargetWinRT then
		print("wp8 or wrt")
		NativeProxy.platform = "wp8"
	elseif target == kTargetIphone or target == kTargetIpad then
	    NativeProxy.platform = "ios"

	    local deviceString, ret = NativeProxy.native_call("getDeviceString", nil, "string")
	    if ret and deviceString then
	    	deviceString = string.gsub(tostring(deviceString), ",", "_")

	    	NativeProxy.model = deviceString
	    else
	    	if target == kTargetIphone then
	    	    NativeProxy.model = "iphone"
	    	else
	    	    NativeProxy.model = "ipad"
	    	end
	    end
	  
	end

	NativeProxy.native_call("registerScriptHandler", {{listener = NativeProxy._native_callback}}  )

	return NativeProxy
end




function NativeProxy.native_call(func, param, returnType)
	if NativeProxy.platform == "ios" then
		--ios
		local SDK_CLASS_NAME = "NativeProxy"
		return NativeCallUtils.call(NativeProxy.platform, SDK_CLASS_NAME, func, param, returnType)

	elseif NativeProxy.platform == "android" then
		--android
		local SDK_CLASS_NAME = "com.youzu.sanguohero.platform.NativeProxy"

		return NativeCallUtils.call(NativeProxy.platform, SDK_CLASS_NAME, func, param, returnType)
	elseif NativeProxy.platform == "wp8" then
		return NativeCallUtils.call(NativeProxy.platform, "", func, param, returnType)
	end

end


--弹框
function NativeProxy.showAlert(title, message, buttonLabels, listener)
	if type(buttonLabels) ~= "table" then
	    buttonLabels = {tostring(buttonLabels)}
	end
	local defaultLabel = ""
	if #buttonLabels > 0 then
	    defaultLabel = buttonLabels[1]
	    table.remove(buttonLabels, 1)
	end

	CCNative:createAlert(title, message, defaultLabel)
	for i, label in ipairs(buttonLabels) do
	    CCNative:addAlertButton(label)
	end

	if type(listener) ~= "function" then
	    listener = function() end
	end

	CCNative:showAlert(listener)
end

--打开游戏外网页
function NativeProxy.openURL(url)
print("NativeProxy openURL Url ",url,title)
	-- CCNative:openURL(url)
	NativeProxy.native_call("openURL", {{url = url}})
end

function NativeProxy.playMedia( path, format )
	NativeProxy.native_call("playMedia", {{filePath = path}, {format = format}})
end

--打开游戏内网页
function NativeProxy.openInnerUrl(url, title)
			print("Open Url ",url,title)
	NativeProxy.native_call("openInnerUrl", {{url=url}, {title=title}})

end


--下载文件APK
function NativeProxy.downloadAndInstallAPK(url)
	--print("start download")
	NativeProxy.native_call("download", {{url=url}})

end

--底层是否有网络连接
function NativeProxy.hasNetwork()
	return 	NativeProxy.native_call("hasNetwork", nil, "boolean")
end

--获取内存
function NativeProxy.getUsedMemory()
	if NativeProxy.platform == "ios" or NativeProxy.platform == "android" then
		return NativeProxy.native_call("getUsedMemory", nil, "int")

	else
		return "0"
	end
end



--监听底层传来的消息
function NativeProxy.registerNativeCallback(func)
	--table.insert(NativeProxy.callbacks, func)
	NativeProxy._callback = func
end

function NativeProxy._native_callback( rawdata)
	--data is json string
	local json = require("framework.json")

	local data = json.decode(rawdata) 
	print("###from native callback : ")
	if NativeProxy._callback ~= nil then
		NativeProxy._callback(data)
	end

end

-- 判断对应包是否已经安装  存在返回true
function NativeProxy.isPackageNameExist( tempName )
	return NativeProxy.native_call("isPackageNameExist", {{name = tempName}} , "boolean")
end

-- 分享游戏
function NativeProxy.shareGame( tempUri )
	NativeProxy.native_call("shareGame", {{uri = tempUri}} )
end

return NativeProxy


