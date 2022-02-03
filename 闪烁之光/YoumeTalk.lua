YoumeTalk = YoumeTalk or {}
if not cc.YTalk then return end
cc.exports.youmetalk = cc.YTalk:create()
cc.exports.userID = ""
cc.exports.roomID = ""
cc.exports.roleType = 0

local addTips = function (  strTips )
    local event = cc.EventCustom:new("Tips")
    event._usedata = strTips 
    cc.Director:getInstance():getEventDispatcher():dispatchEvent( event ) 
end

cc.exports.youmetalk.OnEvent = function( event, errorcode, channel, param )
	print("收到Talk回调:"..event..","..errorcode..","..channel..","..param)
	if event == 0 then --YOUME_EVENT_INIT_OK:
        print("joinChannelSingleMode", YoumeTalk.joinChannelSingleMode("test", "test", 1, false))
		addTips( "初始化成功" )
	elseif event == 1 then --YOUME_EVENT_INIT_FAILED:
		event( "初始化失败" )
	elseif event == 2 then --YOUME_EVENT_JOIN_OK:
		addTips( "进入房间成功, ID: "..channel)
		print("why?")
	    local evt = cc.EventCustom:new("EnterRoom")
    	cc.Director:getInstance():getEventDispatcher():dispatchEvent( evt ) 
	elseif event == 3 then --YOUME_EVENT_JOIN_FAILED
		addTips("进入房间失败")
	elseif event == 4 then --YOUME_EVENT_LEAVED_ONE
		addTips("退出房间")
	elseif event == 5 then --YOUME_EVENT_LEAVED_ALL
		addTips("退出房间")
	elseif event == 6 then --YOUME_EVENT_PAUSED
		addTips("暂停")
	elseif event == 7 then --YOUME_EVENT_RESUMED
		addTips("恢复")
	elseif event == 8 then --YOUME_EVENT_SPEAK_SUCCESS:切换对指定频道讲话成功（适用于多频道模式）
		--addTips("进入房间失败")
	elseif event == 9 then --YOUME_EVENT_SPEAK_FAILED:切换对指定频道讲话失败（适用于多频道模式）
		--addTips("进入房间失败")
	elseif event == 10 then --YOUME_EVENT_RECONNECTING
		addTips("正在重连")
	elseif event == 11 then --YOUME_EVENT_RECONNECTED
		addTips("重连成功")
	elseif event == 12 and errorcode == -202 then --YOUME_EVENT_REC_PERMISSION_STATUS
		addTips("录音启动失败")
	elseif event == 13 then --YOUME_EVENT_BGM_STOPPED
		addTips("背景音乐播放结束")
	elseif event == 14 then --YOUME_EVENT_BGM_FAILED
		addTips("背景音乐播放失败")
	elseif event == 15 then --YOUME_EVENT_MEMBER_CHANGE
		print("频道成员变化:"..param)
	elseif event == 16 then --YOUME_EVENT_OTHERS_MIC_ON
		print("其他用户麦克风打开:"..param)
	elseif event == 17 then --YOUME_EVENT_OTHERS_MIC_OFF
		print("其他用户麦克风关闭:"..param)
	elseif event == 18 then --YOUME_EVENT_OTHERS_SPEAKER_ON
		print("其他用户扬声器打开"..param)
	elseif event == 19 then --YOUME_EVENT_OTHERS_SPEAKER_OFF
		print("其他用户扬声器关闭"..param)
	elseif event == 20 then --YOUME_EVENT_OTHERS_VOICE_ON
		print("其他用户进入讲话状态:"..param)
	elseif event == 21 then --YOUME_EVENT_OTHERS_VOICE_OFF
		print("其他用户进入静默状态:"..param)
	elseif event == 22 then --YOUME_EVENT_MY_MIC_LEVEL
		print("麦克风的语音级别:"..param)
	elseif event == 23 then --YOUME_EVENT_MIC_CTR_ON
		print("麦克风被其他用户打开:"..param)
	elseif event == 24 then --YOUME_EVENT_MIC_CTR_OFF
		print("麦克风被其他用户关闭:"..param)
	elseif event == 25 then --YOUME_EVENT_SPEAKER_CTR_ON
		print("扬声器被其他用户打开:"..param)
	elseif event == 26 then --YOUME_EVENT_SPEAKER_CTR_OFF
		print("扬声器被其他用户关闭:"..param)
	elseif event == 27 then --YOUME_EVENT_LISTEN_OTHER_ON
		print("取消屏蔽某人语音:"..param)
	elseif event == 28 then --YOUME_EVENT_LISTEN_OTHER_OFF
		print("屏蔽某人语音:"..param)
	end
end


cc.exports.youmetalk.OnMemberChange = function ( channel,  member_list_json, is_update)
    print("OnMemberChange:"..channel..",json:"..member_list_json)
    -- member_list_json 样例：
    -- {"channelid":"123","memchange":[{"isJoin":true,"userid":"u541"},{"isJoin":true,"userid":"u948"}]}
end

cc.exports.youmetalk.OnRequestRestApi = function( requestid, errorcode, command, result )
	print("OnRequestRestApi:"..requestid)
	print(errorcode)
	print(command)
	print(result)
end 

cc.exports.youmetalk.OnBroadcast = function( bctype, channel, param1, param2, content )
	print("OnBroadcast:"..bctype..",channel:"..channel..",P1:"..param1..",P2"..param2..",content:"..content)
end

cc.exports.youmetalk.registerScriptHandler(cc.exports.youmetalk,
	cc.exports.youmetalk.OnEvent,
	cc.exports.youmetalk.OnRequestRestApi,
	cc.exports.youmetalk.OnMemberChange,
	cc.exports.youmetalk.OnBroadcast);


youmetalk_obj = cc.exports.youmetalk
YoumeTalk.strAppKey = "YOUME23C443832F3F84453C257CD8D842320A64320CC2"
YoumeTalk.strAPPSecret = "vNeRSaWi54VMrQ9B3ADFgx9OIUEKj+hSQH0sduwXvcKJ0Egfss4FbK9TpZBKGFv8CT9YHZnTTP1aCkj/q2oyZf6wMU4cwTWMP0wrhvkfP6F6CPFI+7yUqgKBHfUuTV3xM94lq7lP0KW7ub+C7mDJA6J004NaZ2EKyAXADUBcBJkBAAE="

-- 初始化语音引擎，做APP验证和资源初始化
YoumeTalk.init = function()
    if YoumeTalk.is_init == nil then
        YoumeTalk.is_init = true
        return youmetalk_obj:init( YoumeTalk.strAppKey, YoumeTalk.strAPPSecret, 0, 'cn' ) 
    end
end

-- 加入语音频道（单频道模式，每个时刻只能在一个语音频道里面）
YoumeTalk.joinChannelSingleMode = function ( strUserID, strChannelID, roleType, bCheckRoomExist) 
    return youmetalk_obj:joinChannelSingleMode ( strUserID, strChannelID, roleType, bCheckRoomExist)
end

-- 加入语音频道（多频道模式，可以同时听多个语音频道的内容，但每个时刻只能对着一个频道讲话）
YoumeTalk.joinChannelMultiMode = function ( strUserID,strChannelID, bCheckRoomExist)
    return youmetalk_obj:joinChannelMultiMode ( strUserID,strChannelID, bCheckRoomExist)
end

-- 多频道模式下，指定当前要讲话的频道
YoumeTalk.speakToChannel = function( strChannelID)
    return youmetalk_obj:speakToChannel ( strChannelID)
end

-- 多频道模式下，退出指定的语音频道
YoumeTalk.leaveChannelMultiMode = function (strChannelID)
    return youmetalk_obj:leaveChannelMultiMode (strChannelID)
end

-- 退出所有的语音频道（单频道模式下直接调用此函数离开频道即可）
YoumeTalk.leaveChannelAll = function()
    return youmetalk_obj:leaveChannelAll ()
end

-- 设置当前用户的语音消息接收白名单，其语音消息只会转发到白名单的用户，不设置该接口则默认转发至频道内所有人
YoumeTalk.setWhiteUserList = function (strChannelID, strWhiteUserList)
    return youmetalk_obj:setWhiteUserList (strChannelID, strWhiteUserList)
end

-- 默认输出到扬声器，在加入房间成功后设置，如无听筒输出的需求尽量不要调用该接口
YoumeTalk.setOutputToSpeaker = function (bOutputToSpeaker)
    return youmetalk_obj:setOutputToSpeaker (bOutputToSpeaker)
end

-- 打开/关闭扬声器。该状态值在加入房间成功后设置才有效
YoumeTalk.setSpeakerMute = function (mute)
    return youmetalk_obj:setSpeakerMute (mute)
end

-- 获取当前扬声器状态
YoumeTalk.getSpeakerMute = function()
    return youmetalk_obj:getSpeakerMute()
end

-- 设置是否通知别人,自己麦克风和扬声器的开关状态
YoumeTalk.setAutoSendStatus = function( bAutoSend )
    return youmetalk_obj:setAutoSendStatus( bAutoSend )
end

-- 设置当前程序输出音量大小。建议该状态值在加入房间成功后按需再重置一次
YoumeTalk.setVolume = function (uiVolume)
    return youmetalk_obj:setVolume (uiVolume)
end

-- 设置是否用耳机监听自己的声音或背景音乐，当不插耳机时，这个设置不起作用  这是一个同步调用接口
YoumeTalk.setHeadsetMonitorOn = function(micEnabled, bgmEnabled)
    return youmetalk_obj:setHeadsetMonitorOn(micEnabled, bgmEnabled)
end

-- 获取当前程序输出音量大小
YoumeTalk.getVolume = function ()
    return youmetalk_obj:getVolume ()
end

-- 设置是否允许使用移动网络。在WIFI和移动网络都可用的情况下会优先使用WIFI，在没有WIFI的情况下，如果设置允许使用移动网络，那么会使用移动网络进行语音通信，否则通信会失败
YoumeTalk.setUseMobileNetworkEnabled = function (bEnabled)
    return youmetalk_obj:setUseMobileNetworkEnabled (bEnabled)
end

-- 获取是否允许SDK在没有WIFI的情况使用移动网络进行语音通信
YoumeTalk.getUseMobileNetworkEnabled = function ()
    return youmetalk_obj:getUseMobileNetworkEnabled ()
end

-- 控制他人的麦克风状态
YoumeTalk.setOtherMicMute = function ( strUserID, mute)
    return youmetalk_obj:setOtherMicMute ( strUserID, mute)
end

-- 控制他人的扬声器状态
YoumeTalk.setOtherSpeakerMute = function ( strUserID, mute)
    return youmetalk_obj:setOtherSpeakerMute ( strUserID, mute)
end

-- 设置是否听某人的语音
YoumeTalk.setListenOtherVoice = function (strUserID, on)
    return youmetalk_obj:setListenOtherVoice (strUserID, on)
end

-- 设置当麦克风静音时，是否释放麦克风设备（需要在初始化成功后，加入房间之前调用）
YoumeTalk.setReleaseMicWhenMute = function(enabled)
    return youmetalk_obj:setReleaseMicWhenMute(enabled)
end

-- 设置插入耳机时，是否自动退出系统通话模式(禁用手机系统硬件信号前处理)
YoumeTalk.setExitCommModeWhenHeadsetPlugin = function(enabled)
    return youmetalk_obj:setExitCommModeWhenHeadsetPlugin(enabled)
end

-- 暂停通话，释放对麦克风等设备资源的占用。当需要用第三方模块临时录音时，可调用这个接口
YoumeTalk.pauseChannel = function()
    return youmetalk_obj:pauseChannel()
end

-- 恢复通话，调用PauseChannel暂停通话后，可调用这个接口恢复通话
YoumeTalk.resumeChannel = function()
    return youmetalk_obj:resumeChannel()
end

-- 设置是否开启语音检测回调，开启后频道内有人正在讲话与结束讲话都会发起相应回调通知。该状态值在加入房间成功后设置才有效
YoumeTalk.setVadCallbackEnabled = function(bEnabled)
    return youmetalk_obj:setVadCallbackEnabled(bEnabled)
end

-- 播放指定的音乐文件。播放的音乐将会通过扬声器输出，并和语音混合后发送给接收方。这个功能适合于主播/指挥等使用
YoumeTalk.playBackgroundMusic = function ( strFilePath, bRepeat)
    return youmetalk_obj:playBackgroundMusic ( strFilePath, bRepeat)
end

-- 停止播放当前正在播放的背景音乐
YoumeTalk.stopBackgroundMusic = function()
    return youmetalk_obj:stopBackgroundMusic()
end

-- 设定背景音乐的音量。这个接口用于调整背景音乐和语音之间的相对音量，使得背景音乐和语音混合听起来协调
YoumeTalk.setBackgroundMusicVolume = function(vol)
    return youmetalk_obj:setBackgroundMusicVolume(vol)
end

-- 获取变声音调（增值服务，需要后台配置开启）
YoumeTalk.getSoundtouchPitchSemiTones = function ()
    return youmetalk_obj:getSoundtouchPitchSemiTones ()
end

-- 设置变声音调（增值服务，需要后台配置开启），需在进入房间成功后调用，仅对当前房间有效，退出房间时重置为0
YoumeTalk.setSoundtouchPitchSemiTones = function(fPitchSemiTones)
    return youmetalk_obj:setSoundtouchPitchSemiTones (fPitchSemiTones)
end

-- 设置是否开启混响音效，这个主要对主播/指挥有用
YoumeTalk.setReverbEnabled = function( bEnabled)
    return youmetalk_obj:setReverbEnabled( bEnabled)
end

-- 设置当前录音的时间戳。当通过录游戏脚本进行直播时，要保证观众端音画同步，在主播端需要进行时间对齐
YoumeTalk.setRecordingTimeMs = function( timeMs)
    return youmetalk_obj:setRecordingTimeMs( timeMs)
end

-- 设置当前声音播放的时间戳。当通过录游戏脚本进行直播时，要保证观众端音画同步，游戏画面的播放需要和声音播放进行时间对齐
YoumeTalk.setPlayingTimeMs = function( timeMs)
    return youmetalk_obj:setPlayingTimeMs( timeMs)
end

-- 设置首选连接服务器的区域码
YoumeTalk.setServerRegion = function(serverRegionId,strExtRegionName)
    return youmetalk_obj:setServerRegion(serverRegionId,strExtRegionName)
end

-- Rest API , 向服务器请求额外数据。支持主播信息，主播排班等功能查询。需要的话，请联系我们获取命令详情文档
YoumeTalk.requestRestApi = function( strCommand , strQueryBody  )
    return youmetalk_obj:requestRestApi( strCommand , strQueryBody  )
end

-- 设置身份验证的token，需要配合后台接口
YoumeTalk.setToken = function( strToken )
    return youmetalk_obj:setToken( strToken )
end

-- 查询频道当前的用户列表， 并设置是否获取频道用户进出的通知。（必须自己在频道中）
YoumeTalk.getChannelUserList = function( strChannelID,maxCount, notifyMemChange )
    return youmetalk_obj:getChannelUserList( strChannelID,maxCount, notifyMemChange )
end

-- 在语音频道内，广播一个文本消息
YoumeTalk.sendMessage = function( channelID,  content )
    return youmetalk_obj:sendMessage( channelID,  content )
end

-- 把人踢出房间
YoumeTalk.kickOtherFromChannel = function( userID, channelID,  lastTime )
    return youmetalk_obj:kickOtherFromChannel( userID, channelID,  lastTime )
end

-- 设置日志等级
YoumeTalk.setLogLevel = function( level)
    return youmetalk_obj:setLogLevel( level)
end

-- 反初始化引擎，可在退出游戏时调用，以释放SDK所有资源
YoumeTalk.unInit = function()
    if YoumeTalk.is_init then
        YoumeTalk.is_init = nil
        youmetalk_obj:unInit ()
    end
end

print = game_print
print("========= YoumeTalk=== init")

-- cc.exports.youmetalk.setLogLevel( 60 )
-- print("init===", cc.exports.youmetalk.init("YOUME23C443832F3F84453C257CD8D842320A64320CC2", "vNeRSaWi54VMrQ9B3ADFgx9OIUEKj+hSQH0sduwXvcKJ0Egfss4FbK9TpZBKGFv8CT9YHZnTTP1aCkj/q2oyZf6wMU4cwTWMP0wrhvkfP6F6CPFI+7yUqgKBHfUuTV3xM94lq7lP0KW7ub+C7mDJA6J004NaZ2EKyAXADUBcBJkBAAE=", 10001, ""))
-- print("init===", YoumeTalk.init())
-- print("joinChannelSingleMode", YoumeTalk.joinChannelSingleMode("test", "test", 1, false))
-- YoumeTalk.getChannelUserList("test", -1, false)
-- YoumeTalk.sendMessage("test", "abc")
print("========= YoumeTalk=== init end")
