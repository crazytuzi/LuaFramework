--[[
文件名: ChatLayer.lua
描述: 聊天页面
创建人: liaoyuangang
创建时间: 2016.12.20
-- ]]

require("Chat.GCloudVoiceDefine")
CloudVoiceMng = {
}

-- 初始化管理对象
local function initMngObj()
	-- 语音引擎当前的模式
	CloudVoiceMng.mCurrMode = nil
	-- 语音消息模式或语音转文字模式下是否正在录音
	CloudVoiceMng.mIsRecording = false
	-- 实时语音成员的状态信息列表，其中每个条目的格式为：
	--[[
		{
			[memberId] = {
				memberId = 1,  -- 成员Id
				status = 0,    -- 状态
			}
			...
		}
	]]
	CloudVoiceMng.mMemberStatus = {}

	local voicePath = "GCloudVoice/"
	-- 语音文件的保存路径
	local fileUtilsObj = cc.FileUtils:getInstance()
	CloudVoiceMng.mSavePath = fileUtilsObj:getWritablePath() .. voicePath
	if not fileUtilsObj:isDirectoryExist(CloudVoiceMng.mSavePath) then
		fileUtilsObj:createDirectory(CloudVoiceMng.mSavePath)
	end
	-- 保存消息语音文件信息列表的文件名
	CloudVoiceMng.mMsgVoiceInfosFile = voicePath .. "msgVoiceInfos.txt"
	-- 正在录制的语音消息文件的临时Id
	CloudVoiceMng.mTempRecordedFileId = "TempRecordedFileId"
	-- 消息语音文件信息列表，其格式为:
	--[[
		{
			[voiceIdMd5] = { -- voiceIdMd5 为skd回调返回的voiceId字符串通过md5编码的字符串，正在录制的消息语音还没有voiceIdMd5，则用 self.mTempRecordedFileId
				mode: 录制语音消息的模式（语音消息或消息转文字消息）
				text: 语音消息转换成的文字
				filename: 文件名, 不包含路径
				isPlayed: 文件是否已播放
			},  
		}
	]] 
	CloudVoiceMng.mMsgVoiceInfos = LocalData:readFileData(CloudVoiceMng.mMsgVoiceInfosFile)
end

initMngObj()

-- ============================== 对外公共接口 =====================

-- 初始化腾讯语音管理对象
function CloudVoiceMng:init()
	if self.mEngine then
		return 
	end

	-- 语音引擎当前的模式
	self.mCurrMode = nil
	-- 语音消息模式或语音转文字模式下是否正在录音
	self.mIsRecording = false
	-- 实时语音成员的状态信息列表，其中每个条目的格式为：
	self.mMemberStatus = {}

	-- 初始化语音sdk对象
	local openId = "temp"
	if Player.mIsLogin then
		openId = PlayerAttrObj:getPlayerInfo().PlayerId
	else
		openId = IPlatform:getInstance():getDeviceUUID() .. "mqkkshediao"
	end
	self.mEngine = gv.IGCloudVoiceEngine:GetVoiceEngine()
    local errno = self.mEngine:SetAppInfo("1269293413", "8219216989fd5117ac85b5f2948781ae", openId)
    if errno ~= gv.GCloudVoiceErrno.GCLOUD_VOICE_SUCC then
    	return errno
    end
    local errno = self.mEngine:Init()
    if errno ~= gv.GCloudVoiceErrno.GCLOUD_VOICE_SUCC then
    	return errno
    end
    local errno = self.mEngine:SetNotify()
    if errno ~= gv.GCloudVoiceErrno.GCLOUD_VOICE_SUCC then
    	return errno
    end

    -- 注册回调函数
    local eventType = gv.GCloudVoiceEventType
    -- 
    self.mEngine:RegisterScriptHandler(eventType.EVENT_GCLOUD_VOICE_JOIN_ROOM, handler(self, self.OnJoinRoom))
    --
    self.mEngine:RegisterScriptHandler(eventType.EVENT_GCLOUD_VOICE_STATUS_UPDATE, handler(self, self.OnStatusUpdate))
    --
    self.mEngine:RegisterScriptHandler(eventType.EVENT_GCLOUD_VOICE_QUIT_ROOM, handler(self, self.OnQuitRoom))
    --
    self.mEngine:RegisterScriptHandler(eventType.EVENT_GCLOUD_VOICE_MEMBER_VOICE, handler(self, self.OnMemberVoice))
    --
    self.mEngine:RegisterScriptHandler(eventType.EVENT_GCLOUD_VOICE_UPLOAD_FILE, handler(self, self.OnUploadFile))
    --
    self.mEngine:RegisterScriptHandler(eventType.EVENT_GCLOUD_VOICE_DOWNLOAD_FILE, handler(self, self.OnDownloadFile))
    --
    self.mEngine:RegisterScriptHandler(eventType.EVENT_GCLOUD_VOICE_PLAY_RECORDED_FILE, handler(self, self.OnPlayRecordedFile))
    --
    self.mEngine:RegisterScriptHandler(eventType.EVENT_GCLOUD_VOICE_APPLY_MESSAGE_KEY, handler(self, self.OnApplyMessageKey))
    --
    self.mEngine:RegisterScriptHandler(eventType.EVENT_GCLOUD_VOICE_SPEECH_TO_TEXT, handler(self, self.OnSpeechToText))
    --
    self.mEngine:RegisterScriptHandler(eventType.EVENT_GCLOUD_VOICE_RECORDING, handler(self, self.OnRecording))

    return gv.GCloudVoiceErrno.GCLOUD_VOICE_SUCC
end

-- 语音sdk是否已经初始化
function CloudVoiceMng:isInitialized()
	return self.mEngine ~= nil
end

-- 处理调用接口返回的错误值
function CloudVoiceMng:dealErrNo(errno)
	errno = errno or gv.GCloudVoiceErrno.GCLOUD_VOICE_SUCC
	if errno == gv.GCloudVoiceErrno.GCLOUD_VOICE_SUCC then
		return 
	end

	local hintStr = gv.GCloudVoiceErrnoHint[errno] or TR("未知错误，错误码(%d)", errno)
	ui.showFlashView(TR("语音错误：") .. hintStr)
end

-- 设置回调函数
--[[
-- 参数
	callbackList：以枚举 "gv.GCloudVoiceEventType" 值为key，函数为 value 的表，比如
	{
		[gv.GCloudVoiceEventType.EVENT_GCLOUD_VOICE_JOIN_ROOM] = function(...) end
	} 
]]
function CloudVoiceMng:setCallbackList(callbackList, callbackObj)
	-- 回调功能模块的回调函数列表
	self.mCallbackList = callbackList or {}
	-- 回调功能模块的回调对象，如果 self.mCallbackObj不为nil并且为无效对象时，不会调用功能模块的回调函数 
	self.mCallbackObj = callbackObj
end

-- 设置语音模式
--[[
-- 参数
	voiceMode: 语音模式，取值为 “gv.GCloudVoiceMode”枚举类型, 默认为 gv.GCloudVoiceMode.Messages
]]
function CloudVoiceMng:setMode(voiceMode)
	voiceMode = voiceMode or gv.GCloudVoiceMode.Messages
	-- 如果没有初始化引擎，或 设置的模式与当前模式相同，则直接返回
	if not self.mEngine or voiceMode == self.mCurrMode then
		if not self.mEngine then
			print("CloudVoiceMng:setMode self.mEngine is nil")
		end
		return 
	end

	self.mCurrMode = voiceMode
	local errno = self.mEngine:SetMode(voiceMode)
	self:dealErrNo(errno)
	return errno
end

-- 查询回调信息，需要定时调用
function CloudVoiceMng:Poll()
	if not self.mEngine then
		print("CloudVoiceMng:Poll self.mEngine is nil")
		return
	end

	local errno = self.mEngine:Poll()
	self:dealErrNo(errno)
	return errno
end

-- 暂停语音sdk
function CloudVoiceMng:Pause()
	if not self.mEngine then
		print("CloudVoiceMng:Pause self.mEngine is nil")
		return 
	end

	local errno = self.mEngine:Pause()
	self:dealErrNo(errno)
	return errno
end

-- 唤醒语音sdk
function CloudVoiceMng:Resume()
	if not self.mEngine then
		print("CloudVoiceMng:Resume self.mEngine is nil")
		return 
	end

	local errno = self.mEngine:Resume()
	self:dealErrNo(errno)
	return errno
end

-- 设置音量
--[[
-- 参数
	vol: Android & IOS, value range is 0-800, 100 means original voice volume, 50 means only 1/2 original voice volume, 200 means double original voice volume
		 value range is 0x0-0xFFFF, suggested value bigger than 0xff00, then you can hear you speaker sound
-- 返回值：
	if success return GCLOUD_VOICE_SUCC, failed return other errno @see GCloudVoiceErrno
]]
function CloudVoiceMng:SetSpeakerVolume(vol)
	if not self.mEngine then
		print("CloudVoiceMng:SetSpeakerVolume self.mEngine is nil")
		return 
	end

	local errno = self.mEngine:SetSpeakerVolume(vol)
	self:dealErrNo(errno)
	return errno
end

-- 获取语音消息安全密钥key信息
--[[
-- 参数 params 中的各项为
	{
		msTimeout: time for apply, it is micro second.value range[5000, 60000], default is 10000
		token:
		timestamp:
	}
]]
function CloudVoiceMng:ApplyMessageKey(params)
	if not self.mEngine then
		print("CloudVoiceMng:ApplyMessageKey self.mEngine is nil")
		return 
	end

	params = params or {}
	local msTimeout = params.msTimeout or 10000

	local errno
	if params.token and params.timestamp then
		errno = self.mEngine:ApplyMessageKeyEx(params.token, params.timestamp, msTimeout)
	else
		errno = self.mEngine:ApplyMessageKey(msTimeout)
	end
	self:dealErrNo(errno)
	return errno
end

-- ============================ 及时语音相关接口 =====================

-- Join in team room.
--[[
-- 参数 params 中的各项为:
	{
		roomName: the room to join, should be less than 127byte, composed by alpha
		msTimeout: time for join, it is micro second. value range[5000, 60000], default is 10000
		token: 
		timestamp: 
	}
-- 返回值
	if success return GCLOUD_VOICE_SUCC, failed return other errno @see GCloudVoiceErrno
]]
function CloudVoiceMng:JoinTeamRoom(params)
	if not params or not params.roomName then
		print("CloudVoiceMng:JoinTeamRoom params.roomName is nil")
		return 
	end
	if not self.mEngine then
		print("CloudVoiceMng:JoinTeamRoom self.mEngine is nil")
		return 
	end

	local msTimeout = params.msTimeout or 10000
	local errno
	if params.token and params.timestamp then
		errno = self.mEngine:JoinTeamRoomEx(params.roomName, params.token, params.timestamp, msTimeout)
	else
		errno = self.mEngine:JoinTeamRoom(params.roomName, msTimeout)
	end
	self:dealErrNo(errno)
	return errno
end

-- Join in a national room.
--[[
-- 参数 params 中的各项为:
	{
		roomName: the room to join, should be less than 127byte, composed by alpha.
		role: a GCloudVoiceMemberRole value illustrate wheather can send voice data.
		msTimeout: time for join, it is micro second. value range[5000, 60000] default is 10000
		token: 
		timestamp: 
	}
-- 返回值
	if success return GCLOUD_VOICE_SUCC, failed return other errno @see GCloudVoiceErrno
]]
function CloudVoiceMng:JoinNationalRoom(params)
	if not params or not params.roomName or not params.role then
		print("CloudVoiceMng:JoinNationalRoom params.roomName or params.role is nil")
		return 
	end

	if not self.mEngine then
		print("CloudVoiceMng:JoinNationalRoom self.mEngine is nil")
		return 
	end

	local msTimeout = params.msTimeout or 10000
	local errno
	if params.token and params.timestamp then
		errno = self.mEngine:JoinNationalRoomEx(params.roomName, params.role, params.token, params.timestamp, msTimeout)
	else
		errno = self.mEngine:JoinNationalRoom(params.roomName, params.role, msTimeout)
	end
	self:dealErrNo(errno)
	return errno
end

-- Join in a FM room.
--[[
-- 参数
	roomName: the room to join, should be less than 127byte, composed by alpha.
	msTimeout: time for join, it is micro second. value range[5000, 60000], default is 10000
-- 返回值
	if success return GCLOUD_VOICE_SUCC, failed return other errno @see GCloudVoiceErrno
]]
function CloudVoiceMng:JoinFMRoom(roomName, msTimeout)
	if not self.mEngine then
		print("CloudVoiceMng:JoinFMRoom self.mEngine is nil")
		return 
	end

	msTimeout = msTimeout or 10000
	local errno = self.mEngine:JoinFMRoom(roomName, msTimeout)
	self:dealErrNo(errno)
	return errno
end

-- Quit the voice room.
--[[
-- 参数
	roomName: the room to join, should be less than 127byte, composed by alpha.
	msTimeout: time for quit, it is micro second.value range[5000, 60000]，default is 10000
-- 返回值
	if success return GCLOUD_VOICE_SUCC, failed return other errno @see GCloudVoiceErrno
]]
function CloudVoiceMng:QuitRoom(roomName, msTimeout)
	if not self.mEngine then
		print("CloudVoiceMng:QuitRoom self.mEngine is nil")
		return 
	end

	msTimeout = msTimeout or 10000
	local errno = self.mEngine:QuitRoom(roomName, msTimeout)
	self:dealErrNo(errno)
	return errno
end

-- Open player's micro phone  and begin to send player's voice data.
--[[
-- 返回值
	if success return GCLOUD_VOICE_SUCC, failed return other errno @see GCloudVoiceErrno
]]
function CloudVoiceMng:OpenMic()
	if not self.mEngine then
		print("CloudVoiceMng:OpenMic self.mEngine is nil")
		return
	end

	local errno = self.mEngine:OpenMic()
	self:dealErrNo(errno)
	return errno
end

-- Close players's micro phone and stop to send player's voice data.
--[[
-- 返回值
	if success return GCLOUD_VOICE_SUCC, failed return other errno @see GCloudVoiceErrno
]]
function CloudVoiceMng:CloseMic()
	if not self.mEngine then
		print("CloudVoiceMng:CloseMic self.mEngine is nil")
		return 
	end

	local errno = self.mEngine:CloseMic()
	self:dealErrNo(errno)
	return errno
end

-- Open player's speaker and begin recvie voice data from the net .
--[[
-- 返回值
	if success return GCLOUD_VOICE_SUCC, failed return other errno @see GCloudVoiceErrno
]]
function CloudVoiceMng:OpenSpeaker()
	if not self.mEngine then
		print("CloudVoiceMng:OpenSpeaker self.mEngine is nil")
		return 
	end

	local errno = self.mEngine:OpenSpeaker()
	self:dealErrNo(errno)
	return errno
end

-- Close player's speaker and stop to recive voice data from the net.
--[[
-- 返回值
	if success return GCLOUD_VOICE_SUCC, failed return other errno @see GCloudVoiceErrno
]]
function CloudVoiceMng:CloseSpeaker()
	if not self.mEngine then
		print("CloudVoiceMng:CloseSpeaker self.mEngine is nil")
		return 
	end

	local errno = self.mEngine:CloseSpeaker()
	self:dealErrNo(errno)
	return errno
end

-- 屏蔽某人的语音
--[[
-- 参数
	memberId: member to forbid
	enable: do forbid if it is true

-- 返回值
	if success return GCLOUD_VOICE_SUCC, failed return other errno @see GCloudVoiceErrno
]]
function CloudVoiceMng:ForbidMemberVoice(memberId, enable)
	if not self.mEngine then
		print("CloudVoiceMng:ForbidMemberVoice self.mEngine is nil")
		return 
	end

	local errno = self.mEngine:ForbidMemberVoice(memberId, enable)
	self:dealErrNo(errno)
	return errno
end

-- ====================== 语音消息相关接口 =================

-- 设置语音消息的最大长度
--[[
-- 参数
	msTime : message's largest time in micro second.value range[1000, 2*60*1000]

-- 返回值
	if success return GCLOUD_VOICE_SUCC, failed return other errno @see GCloudVoiceErrno
]]
function CloudVoiceMng:SetMaxMessageLength(msTime)
	if not self.mEngine then
		print("CloudVoiceMng:SetMaxMessageLength self.mEngine is nil")
		return
	end

	msTime = math.max(1000, math.min(2 * 60 * 1000, msTime or 2 * 60 * 1000))
	local errno = self.mEngine:SetMaxMessageLength(msTime)
	self:dealErrNo(errno)
	return errno
end

-- 开始录制消息语音
--[[
-- 参数
	filename: 保存消息语音的文件名，不包含路径，比如：10001.spx、10002.dat
]]
function CloudVoiceMng:StartRecording(filename)
	if not self.mEngine then
		print("CloudVoiceMng:StartRecording self.mEngine is nil")
		return 
	end

	-- 检查模式
	if self.mCurrMode ~= gv.GCloudVoiceMode.Messages and self.mCurrMode ~= gv.GCloudVoiceMode.Translation then
		print("CloudVoiceMng:StartRecording self.mCurrMode is error:", self.mCurrMode)
		return 
	end

	-- 如果正在录制，停止之前的录制
	if self.mIsRecording then
		ui.showFlashView(TR("正在录制语音消息"))
		return 
	end

	local tempStr = self.mSavePath .. filename
	local errno = self.mEngine:StartRecording(tempStr)
	if errno == gv.GCloudVoiceErrno.GCLOUD_VOICE_SUCC then
		self.mIsRecording = true
		self.mMsgVoiceInfos[self.mTempRecordedFileId] = {
			filename = filename,
			mode = self.mCurrMode,
			isPlayed = true, -- 本地录制的文件标记为已播放
		}
	end
	self:dealErrNo(errno)
	return errno
end

-- 结束录制消息语音
function CloudVoiceMng:StopRecording()
	if not self.mEngine then
		print("CloudVoiceMng:StopRecording self.mEngine is nil")
		return 
	end

	if not self.mIsRecording then
		return 
	end

	local errno = self.mEngine:StopRecording()
	self:dealErrNo(errno)
	self.mIsRecording = false
	return errno
end

-- 上传消息语音
--[[
-- 参数
	filename: 保存消息语音的文件名，不包含路径，比如：10001.spx、10002.dat
	msTimeout: time for upload, it is micro second.value range[5000, 60000]， 默认为60000
]]
function CloudVoiceMng:UploadRecordedFile(filename, msTimeout)
	if not self.mEngine then
		print("CloudVoiceMng:UploadRecordedFile self.mEngine is nil")
		return 
	end

	msTimeout = math.max(50000, math.min(msTimeout or 60000, 60000)) 
	local tempName = string.onlyFilename(filename)
	if tempName then
		local errno = self.mEngine:UploadRecordedFile(self.mSavePath .. tempName, msTimeout)
		self:dealErrNo(errno)
		return errno
	end
end

-- 下载消息语音
--[[
-- 参数
	voiceId: 需要下载语音的Id, 这个参数时上传语音消息成功后，sdk返回的
	filename: 保存消息语音的文件名，不包含路径，比如：10001.spx、10002.dat
	msTimeout: time for download, it is micro second.value range[5000, 60000], 默认为 60000
]]
function CloudVoiceMng:DownloadRecordedFile(voiceId, filename, msTimeout)
	if not self.mEngine then
		print("CloudVoiceMng:DownloadRecordedFile self.mEngine is nil")
		return 
	end

	msTimeout = math.max(50000, math.min(msTimeout or 60000, 60000)) 
	local tempName = string.onlyFilename(filename)
	tempName = tempName or string.format("%s.spx", tostring(os.time()))
	local errno = self.mEngine:DownloadRecordedFile(voiceId, self.mSavePath .. tempName, msTimeout)
	self:dealErrNo(errno)
	return errno
end

-- 播发语音消息
--[[
-- 参数
	filename: 保存消息语音的文件名，不包含路径，比如：10001.spx、10002.dat
]]
function CloudVoiceMng:PlayRecordedFile(filename)
	if not self.mEngine then
		print("CloudVoiceMng:PlayRecordedFile self.mEngine is nil")
		return 
	end

	local tempName = string.onlyFilename(filename)
	if tempName then
		local tempStr = self.mSavePath .. tempName
		dump("PlayRecordedFile:" .. tempStr .. ")")
		local errno = self.mEngine:PlayRecordedFile(tempStr)
		self:dealErrNo(errno)

		-- 如果原来的状态为未播放，标记为已播放
		for key, item in pairs(self.mMsgVoiceInfos) do
			if item.filename == filename then
				if not item.isPlayed then
					item.isPlayed = true
					LocalData:saveDataToFile(self.mMsgVoiceInfosFile, self.mMsgVoiceInfos)

					-- 通知该语音是否已播放状态发生改变
					Notification:postNotification(EventsName.eVoiceIsPlayedPrefix .. key)
					Notification:postNotification(EventsName.eVoiceIsPlayedPrefix .. item.filename)
				end
				-- 通知开始播放该语音
				Notification:postNotification(EventsName.eVoicePlayBeginPrefix .. key)
				Notification:postNotification(EventsName.eVoicePlayBeginPrefix .. item.filename)
				
				break
			end
		end

		return errno
	end
end

-- 判断语音消息Id在本地有没有对应的文件
--[[
-- 参数
	voiceId：语音的Id，由语音sdk生成
-- 返回值
	如果有本地文件返回true， 否则返回false
]]
function CloudVoiceMng:haveLocalFile(voiceId)
	local fileInfo = self.mMsgVoiceInfos[string.md5Content(voiceId)]
	local filename = fileInfo and fileInfo.filename
	return filename and io.exists(self.mSavePath .. filename) or false
end

-- 根据语音Id获取语音存储在本地的文件名
function CloudVoiceMng:getFilenameByVoiceId(voiceId)
	local fileInfo = self.mMsgVoiceInfos[string.md5Content(voiceId)]
	return fileInfo and fileInfo.filename or ""
end

-- 根据语音Id播放语音消息
function CloudVoiceMng:PlayRecordedByFileId(voiceId)
	local fileInfo = self.mMsgVoiceInfos[string.md5Content(voiceId)]
	local filename = fileInfo and fileInfo.filename
	if filename and io.exists(self.mSavePath .. filename) then
		return self:PlayRecordedFile(filename)
	end
end

-- 根据语音Id判读语音是否已播放
function CloudVoiceMng:voiceIsPlayedById(voiceId)
	local fileInfo = self.mMsgVoiceInfos[string.md5Content(voiceId)]
	return fileInfo and fileInfo.isPlayed
end

-- 根据文件名判断语音是否已播放
function CloudVoiceMng:voiceIsPlayed(filename)
	for _, item in pairs(self.mMsgVoiceInfos) do
		if item.filename == filename then
			return tem.isPlayed
		end
	end
	return false
end

-- 停止播放语音消息
function CloudVoiceMng:StopPlayFile()
	if not self.mEngine then
		print("CloudVoiceMng:StopPlayFile self.mEngine is nil")
		return 
	end

	-- 通知停止播放语音
	Notification:postNotification(EventsName.eVoiceStopPlay)

	local errno = self.mEngine:StopPlayFile()
	self:dealErrNo(errno)
	return errno
end

-- 获取语音消息文件的大小和播放时长
--[[
-- 参数
	filename: 语音消息的文件名
-- 返回值中的各项为:
	{
		errno: 函数调用是返回错误码
		bytes: on return for file's size
		seconds: on return for voice's length
	}
]]
function CloudVoiceMng:GetFileParam(filename)
	if not self.mEngine then
		print("CloudVoiceMng:GetFileParam self.mEngine is nil")
		return 
	end

	local tempName = string.onlyFilename(filename)
	if not tempName or tempName == "" then
		return {}
	end

	local errno, bytes, seconds = self.mEngine:GetFileParam(self.mSavePath .. tempName)
	local ret = {
		Errno = errno,
		Bytes = bytes or 0, 
		Seconds = seconds or 0,
	}
	if errno ~= gv.GCloudVoiceErrno.GCLOUD_VOICE_SUCC then
		self:dealErrNo(errno)
	end
	return ret
end

-- 删除本地语音文件
function CloudVoiceMng:deleteRecordFile(filename)
	local fileUtilsObj = cc.FileUtils:getInstance()

	local tempName = string.onlyFilename(filename)
	local filePath = self.mSavePath .. tempName
	if fileUtilsObj:isFileExist(filePath) then  
		for key, item in pairs(self.mMsgVoiceInfos) do
			if item.filename == filename then
				self.mMsgVoiceInfos[key] = nil
			end
		end

        fileUtilsObj:removeFile(filePath)
    end
end

-- ============================== 语音转文字相关接口 =====================
-- 语音消息转化为文字
--[[
-- 参数 params 中各项为:
	{
		voiceId: file to be translate
		msTimeout: timeout for translate, default is 60000
		language: a GCloudLanguage indicate which language to be translate, default is China
		token:
		timestamp:
	}
]]
function CloudVoiceMng:SpeechToText(params)
	if not params or not params.voiceId then
		print("CloudVoiceMng:SpeechToText params.fileId is nil")
		return 
	end
	if not self.mEngine then
		print("CloudVoiceMng:SpeechToText self.mEngine is nil")
		return 
	end

	local msTimeout = params.msTimeout or 60000
	local language = params.language or gv.GCloudLanguage.China
	local errno
	if params.token and params.timestamp then
		errno = self.mEngine:SpeechToTextEx(params.voiceId, params.token, params.timestamp, msTimeout, language)
	else
		errno = self.mEngine:SpeechToText(params.voiceId, msTimeout, language)
	end
	self:dealErrNo(errno)
	return errno
end

-- 判断语音消息Id是否已有转化好的文字
function CloudVoiceMng:haveSpeechText(voiceId)
	local md5Str = string.md5Content(voiceId)
	local fileInfo = self.mMsgVoiceInfos[md5Str]
	return fileInfo and fileInfo.text and true or false
end

-- ============================== 语音sdk 回调函数 ======================
-- Callback when JoinXxxRoom successful or failed.
--[[
-- 参数：
	completeCode: a GCloudVoiceCompleteCode code . You should check this first.
	roomName: name of your joining, should be 0-9A-Za-Z._- and less than 127 bytes
	memberId: if success, return the memberID
]]
function CloudVoiceMng:OnJoinRoom(completeCode, roomName, memberId)
	self.mMemberStatus = {}
	print("CloudVoiceMng:OnJoinRoom completeCode, roomName, memberId:", completeCode, roomName, memberId)
	if completeCode == gv.GCloudVoiceCompleteCode.GV_ON_JOINROOM_SUCC then
		-- 进入房间成功
		Notification:postNotification(EventsName.eVoiceJoinRoomSuccPrefix .. roomName)
		Notification:postNotification(EventsName.eVoiceJoinRoomSuccPrefix)
	else
		-- 加入房间失败
		Notification:postNotification(EventsName.eVoiceJoinRoomFaildPrefix .. roomName)
		Notification:postNotification(EventsName.eVoiceJoinRoomFaildPrefix)
	end
end

-- Callback when dropped from the room
--[[
-- 参数
	completeCode: a GCloudVoiceCompleteCode code . You should check this first.
	roomName: name of your joining, should be 0-9A-Za-Z._- and less than 127 bytes
	memberId: if success, return the memberID
]]
function CloudVoiceMng:OnStatusUpdate(completeCode, roomName, memberId)
	print("CloudVoiceMng:OnStatusUpdate completeCode, roomName, memberId:", completeCode, roomName, memberId)
end

-- Callback when QuitRoom successful or failed.
--[[
-- 参数
	completeCode: a GCloudVoiceCompleteCode code . You should check this first.
	roomName: name of your joining, should be 0-9A-Za-Z._- and less than 127 bytes
]]
function CloudVoiceMng:OnQuitRoom(completeCode, roomName)
	print("CloudVoiceMng:OnQuitRoom completeCode, roomName:", completeCode, roomName)

	-- 消息通知离开房间
	Notification:postNotification(EventsName.eVoiceQuitRoomPrefix .. roomName)
	Notification:postNotification(EventsName.eVoiceQuitRoomPrefix)
end
        
-- Callback when someone saied or silence in the same room.
--[[
-- 参数
	members: a int array composed of [memberid_0, status,memberid_1, status ... memberid_2*count, status],
			here, status could be 0, 1, 2. 0 meets silence and 1/2 means saying
	count: count of members who's status has changed.
]]
function CloudVoiceMng:OnMemberVoice(members, count)
	print("CloudVoiceMng:OnMemberVoice count:", count)
	dump(members, "CloudVoiceMng:OnMemberVoice members:")

	for index = 1, count do
		local memberId = members[(index - 1) * 2 + 1]
		local status = members[(index - 1) * 2 + 2]
		if memberId and status then
			self.mMemberStatus[memberId] = {
				memberId = memberId,
				status = status
			}
		end
	end
	Notification:postNotification(EventsName.eVoiceMemberStatusChange)
end

-- Voice Message Callback
--[[
-- 参数
	completeCode: a GCloudVoiceCompleteCode code . You should check this first.
	filePath: file to upload
	voiceId: if success ,get back the id for the file.
]]
function CloudVoiceMng:OnUploadFile(completeCode, filePath, voiceId)
	print("CloudVoiceMng:OnUploadFile completeCode, filePath, voiceId:", completeCode, filePath, voiceId)
	local filename = string.onlyFilename(filePath)
	if completeCode == gv.GCloudVoiceCompleteCode.GV_ON_UPLOAD_RECORD_DONE then
		self.mMsgVoiceInfos[string.md5Content(voiceId)] = {
			filename = filename,
			mode = self.mCurrMode,
			isPlayed = true, -- 上传的文件都标记为已播放
		}
		LocalData:saveDataToFile(self.mMsgVoiceInfosFile, self.mMsgVoiceInfos)
	end

	local postData = {
		taskType = VoiceAsyncTaskType.eUpload,
		completeCode = completeCode,
		filename = filename,
		voiceId = voiceId
	}
	Notification:postNotification(EventsName.eVoiceAsyncTaskReturn, postData)
end

-- Callback when download voice file successful or failed.
--[[
-- 参数
	completeCode: a GCloudVoiceCompleteCode code . You should check this first.
	filePath: file to download to .
	voiceId: if success ,get back the id for the file.
]]
function CloudVoiceMng:OnDownloadFile(completeCode, filePath, voiceId)
	print("CloudVoiceMng:OnDownloadFile completeCode, filePath, voiceId:", completeCode, filePath, voiceId)
	local filename = string.onlyFilename(filePath)
	if completeCode == gv.GCloudVoiceCompleteCode.GV_ON_DOWNLOAD_RECORD_DONE then
		self.mMsgVoiceInfos[string.md5Content(voiceId)] = {
			filename = filename,
			mode = self.mCurrMode,
			isPlayed = false,
		}
		LocalData:saveDataToFile(self.mMsgVoiceInfosFile, self.mMsgVoiceInfos)
	end

	local postData = {
		taskType = VoiceAsyncTaskType.eDownload,
		completeCode = completeCode,
		filename = filename,
		voiceId = voiceId
	}
	Notification:postNotification(EventsName.eVoiceAsyncTaskReturn, postData)
end
       
-- Callback when finish a voice file play end.
--[[
-- 参数
	completeCode: a GCloudVoiceCompleteCode code . You should check this first.
	filePath: file had been plaied.
]]
function CloudVoiceMng:OnPlayRecordedFile(completeCode, filePath)
	print("CloudVoiceMng:OnPlayRecordedFile completeCode, filePath:", completeCode, filePath)
	-- 播放某条语音消息结束
	local tempFile = string.onlyFilename(filePath)

	-- 查找voiceId
	for key, item in pairs(self.mMsgVoiceInfos) do
		if item.filename == tempFile then
			Notification:postNotification(EventsName.eVoicePlayEndPrefix .. key)
			break
		end
	end

	Notification:postNotification(EventsName.eVoicePlayEndPrefix .. tempFile)
	Notification:postNotification(EventsName.eVoicePlayEndPrefix)
end
        
-- Callback when query message key successful or failed.
--[[
-- 参数
	completeCode: a GCloudVoiceCompleteCode code . You should check this first.
]]
function CloudVoiceMng:OnApplyMessageKey(completeCode)
	print("CloudVoiceMng:OnApplyMessageKey completeCode:", completeCode)
	-- 获取语音消息安全密钥key信息返回
	local postData = {
		completeCode = completeCode,
	}
	Notification:postNotification(EventsName.eVoiceApplyMessageKeyReturn, postData)
end

-- Callback when translate voice to text successful or failed.
--[[
-- 参数：
	completeCode: a GCloudVoiceCompleteCode code . You should check this first.
	voiceId: file to translate
	result: the destination text of the destination language.
]]
function CloudVoiceMng:OnSpeechToText(completeCode, voiceId, result)
	print("CloudVoiceMng:OnSpeechToText completeCode, voiceId, result:", completeCode, voiceId, result)
	if completeCode == gv.GCloudVoiceCompleteCode.GV_ON_STT_SUCC then
		local md5Str = string.md5Content(voiceId)
		self.mMsgVoiceInfos[md5Str] = self.mMsgVoiceInfos[md5Str] or {}
		local tempInfo = self.mMsgVoiceInfos[md5Str]

		tempInfo.mode = gv.GCloudVoiceMode.Translation
		tempInfo.text = result
		LocalData:saveDataToFile(self.mMsgVoiceInfosFile, self.mMsgVoiceInfos)
	end

	local postData = {
		taskType = VoiceAsyncTaskType.eSpeechToText,
		completeCode = completeCode,
		voiceId = voiceId,
		text = result,
	}
	Notification:postNotification(EventsName.eVoiceAsyncTaskReturn, postData)
end
 
-- Callback when client is using microphone recording audio
--[[
-- 参数
	audioData: audio data pointer 
	dataLength: audio data length
]]
function CloudVoiceMng:OnRecording(audioData, dataLength)
	print("CloudVoiceMng:OnRecording dataLength:", dataLength)
end


