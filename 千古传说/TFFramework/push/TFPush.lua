TFPushServer = {}

TFPushServer.CLASS_NAME = nil
if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
    TFPushServer.CLASS_NAME = "TFPush"
elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
    TFPushServer.CLASS_NAME = "com/cocos/CCPushHelper"
end

function TFPushServer.checkResult(ok,ret)
    -- body
    if ok then return ret end
    return nil
end

function TFPushServer.setDebugMode(debug)
	if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        TFLuaOcJava.callStaticMethod(TFPushServer.CLASS_NAME,"setDebugMode",{ debug = debug},"(Z)V")
    elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        TFLuaOcJava.callStaticMethod(TFPushServer.CLASS_NAME,"setDebugMode",{ debug},"(Z)V")
    end
end

function TFPushServer.getSDKVersion()
    local ok ,ret = TFLuaOcJava.callStaticMethod(TFPushServer.CLASS_NAME,"getSDKVersion", nil ,"()Ljava/lang/String;")
    return TFDeviceInfo.checkResult(ok,ret)
end

--设置推送开关
function TFPushServer.setPushSwitchState(state)
	if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        TFLuaOcJava.callStaticMethod(TFPushServer.CLASS_NAME,"setPushSwitchState",{ state = state})
    elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        TFLuaOcJava.callStaticMethod(TFPushServer.CLASS_NAME,"setPushSwitchState",{ state},"(Z)V")
    end
end


function TFPushServer.setAccount(account)
	if account == nil then
		return
		-- TFLuaOcJava.callStaticMethod(TFPushServer.CLASS_NAME,"delAccount", nil ,"()V")
	else
		if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
	        TFLuaOcJava.callStaticMethod(TFPushServer.CLASS_NAME,"setAccount",{ account = account})
	    elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
	        TFLuaOcJava.callStaticMethod(TFPushServer.CLASS_NAME,"setAccount",{ account},"(Ljava/lang/String;)V")
	    end
	end
end

function TFPushServer.setTags(tags)
	if tags == nil then
		return;
		-- TFLuaOcJava.callStaticMethod(TFPushServer.CLASS_NAME,"setTags", nil ,"()V")
	else
		if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
	        TFLuaOcJava.callStaticMethod(TFPushServer.CLASS_NAME,"setTags",{ tags = tags})
	    elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
	        TFLuaOcJava.callStaticMethod(TFPushServer.CLASS_NAME,"setTags",{ tags},"(Ljava/lang/String;)V")
	    end
	end
end

function TFPushServer.delTags(tags)
	if tags == nil then
		return
		-- TFLuaOcJava.callStaticMethod(TFPushServer.CLASS_NAME,"delTags", nil ,"()V")
	else
		if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
	        TFLuaOcJava.callStaticMethod(TFPushServer.CLASS_NAME,"delTags",{ tags = tags})
	    elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
	        TFLuaOcJava.callStaticMethod(TFPushServer.CLASS_NAME,"delTags",{ tags},"(Ljava/lang/String;)V")
	    end
	end
end


function TFPushServer.setSilentTime(startHour, startMinute, endHour, endMinute)
	if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
		TFLuaOcJava.callStaticMethod(TFPushServer.CLASS_NAME,"setSilentTime",{ startHour = startHour , startMinute = startMinute ,endHour = endHour ,endMinute = endMinute },"(IIII)I")
	elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
		TFLuaOcJava.callStaticMethod(TFPushServer.CLASS_NAME,"setSilentTime",{ startHour,startMinute,endHour,endMinute},"(IIII)I")
	end
end

function TFPushServer.delSilentTime()
	TFLuaOcJava.callStaticMethod(TFPushServer.CLASS_NAME,"delSilentTime", nil ,"()I")
end

function TFPushServer.setLocalTimer(time, notifyText, key)
	if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
		local args = { time = time , key = key, notifyText = notifyText }
		TFLuaOcJava.callStaticMethod(TFPushServer.CLASS_NAME,"setLocalTimer", args)
	elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
		TFLuaOcJava.callStaticMethod(TFPushServer.CLASS_NAME,"setLocalTimer",{ time, notifyText},"(Ljava/lang/String;Ljava/lang/String;)I")
	end
end

function TFPushServer.cancelLocalTimer(time , notifyText, key)
	if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
		TFLuaOcJava.callStaticMethod(TFPushServer.CLASS_NAME,"cancelLocalTimer",{ key = key})
	elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
		TFLuaOcJava.callStaticMethod(TFPushServer.CLASS_NAME,"cancelLocalTimer",{ time , notifyText}, "(Ljava/lang/String;Ljava/lang/String;)I")
	end
end

function TFPushServer.cancelAllLocalTimer()
	if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
		TFLuaOcJava.callStaticMethod(TFPushServer.CLASS_NAME,"cancelAllLocalTimer", nil)
	elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
		TFLuaOcJava.callStaticMethod(TFPushServer.CLASS_NAME,"cancelAllLocalTimer",{},"()I")
	end
end


return TFPushServer