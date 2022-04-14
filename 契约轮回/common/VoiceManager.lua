--
-- @Author: LaoY
-- @Date:   2018-11-10 16:53:47
--
VoiceManager = VoiceManager or class("VoiceManager",BaseManager)
local VoiceManager = VoiceManager

local GCloudVoiceCompleteCode = 
	{
        GV_ON_JOINROOM_SUCC = "GV_ON_JOINROOM_SUCC",    --join room succ
        GV_ON_JOINROOM_TIMEOUT = "GV_ON_JOINROOM_TIMEOUT",  --join room timeout
        GV_ON_JOINROOM_SVR_ERR = "GV_ON_JOINROOM_SVR_ERR",  --communication with svr occur some err, such as err data recv from svr
        GV_ON_JOINROOM_UNKNOWN = "GV_ON_JOINROOM_UNKNOWN", --reserved, our internal unknow err

        GV_ON_NET_ERR = "GV_ON_NET_ERR",  --net err,may be can't connect to network

        GV_ON_QUITROOM_SUCC = "GV_ON_QUITROOM_SUCC", --quitroom succ, if you have join room succ first, quit room will alway return succ

        GV_ON_MESSAGE_KEY_APPLIED_SUCC = "GV_ON_MESSAGE_KEY_APPLIED_SUCC",  --apply message authkey succ
        GV_ON_MESSAGE_KEY_APPLIED_TIMEOUT = "GV_ON_MESSAGE_KEY_APPLIED_TIMEOUT",      --apply message authkey timeout
        GV_ON_MESSAGE_KEY_APPLIED_SVR_ERR = "GV_ON_MESSAGE_KEY_APPLIED_SVR_ERR",  --communication with svr occur some err, such as err data recv from svr
        GV_ON_MESSAGE_KEY_APPLIED_UNKNOWN = "GV_ON_MESSAGE_KEY_APPLIED_UNKNOWN",  --reserved,  our internal unknow err

        GV_ON_UPLOAD_RECORD_DONE = "GV_ON_UPLOAD_RECORD_DONE",  --upload record file succ
        GV_ON_UPLOAD_RECORD_ERROR = "GV_ON_UPLOAD_RECORD_ERROR",  --upload record file occur error
        GV_ON_DOWNLOAD_RECORD_DONE = "GV_ON_DOWNLOAD_RECORD_DONE", --download record file succ
        GV_ON_DOWNLOAD_RECORD_ERROR = "GV_ON_DOWNLOAD_RECORD_ERROR",    --download record file occur error

        GV_ON_STT_SUCC = "GV_ON_STT_SUCC", -- speech to text successful
        GV_ON_STT_TIMEOUT = "GV_ON_STT_TIMEOUT", -- speech to text with timeout
        GV_ON_STT_APIERR = "GV_ON_STT_APIERR", -- server's error

        GV_ON_RSTT_SUCC = "GV_ON_RSTT_SUCC", -- speech to text successful
        GV_ON_RSTT_TIMEOUT = "GV_ON_RSTT_TIMEOUT", -- speech to text with timeout
        GV_ON_RSTT_APIERR = "GV_ON_RSTT_APIERR", -- server's error

        GV_ON_PLAYFILE_DONE = "GV_ON_PLAYFILE_DONE",  --the record file played end

		GV_ON_ROOM_OFFLINE = "GV_ON_ROOM_OFFLINE", -- Dropped from the room

        GV_ON_UNKNOWN = "GV_ON_UNKNOWN",
        GV_ON_ROLE_SUCC = "GV_ON_ROLE_SUCC",    -- Change Role Success
        GV_ON_ROLE_TIMEOUT = "GV_ON_ROLE_TIMEOUT", -- Change Role with tiemout
        GV_ON_ROLE_MAX_AHCHOR = "GV_ON_ROLE_MAX_AHCHOR", -- To much Anchor
        GV_ON_ROLE_NO_CHANGE = "GV_ON_ROLE_NO_CHANGE", -- The same role
        GV_ON_ROLE_SVR_ERROR = "GV_ON_ROLE_SVR_ERROR", -- server's error

        GV_ON_RSTT_RETRY = "GV_ON_RSTT_RETRY", -- need retry stt
    };

local GCloudVoiceMode = 
{
	RealTime = 0, 
	Messages = 1,     
	Translation = 2,  
    RSTT = 3, 
	HIGHQUALITY =4, 
}

function VoiceManager:ctor()
	VoiceManager.Instance = self
	-- voiceMgr
	self.voice_file_path = Util.VoicePath
	self.voice_extname = ".dat"
	self.gcloud_voice_mode = nil
	self:Reset()
end

function VoiceManager:Reset()
end

function VoiceManager.GetInstance()
	if VoiceManager.Instance == nil then
		VoiceManager()
	end
	return VoiceManager.Instance
end

--[[
	@author LaoY
	@des	初始化gvoice
	@param1 user_id 用户唯一ID
--]]
function VoiceManager:SetGVoiceAppInfo(user_id)
	if self.is_init_gvoice then
		return
	end
	voiceMgr:SetGVoiceAppInfo(user_id)
	if not self.is_init_gvoice then
		self:JoinRoomHandler()
		self:QuitRoomHandler()
		self:OnMemberVoice()
		self:ApplyMessageKeyCompleteHandler()
		self:UploadReccordFileCompletehandler()
		self:DownloadRecordFileCompletehandler()
		self:PlayRecordFilCompletehandler()
		self:OnSpeechToText()
	end
	self.is_init_gvoice = true
end

function VoiceManager:SetMode(voice_model)
	if not voice_model then
		return
	end
	if self.gcloud_voice_mode == voice_model then
		return
	end
	self.gcloud_voice_mode = voice_model
	voiceMgr:SetMode(voice_model)
end

-- 暂停
function VoiceManager:GVoicePause()
	voiceMgr:GVoicePause()
end

-- 恢复
function VoiceManager:GVoiceResume()
	voiceMgr:GVoiceResume()
end

--/*实时语音*/
--[[
	@author LaoY
	@des	加入团队语音
	@param1 
--]]
function VoiceManager:JoinTeamRoom(roomName,msTimeout)
	self:SetMode(GCloudVoiceMode.RealTime)
	local code
	if msTimeout then
		code = voiceMgr:JoinTeamRoom(roomName,msTimeout)
	else
		code = voiceMgr:JoinTeamRoom(roomName)
	end
	if code ~= 0 then
		log('--LaoY VoiceManager.lua,JoinTeamRoom-- code=',code)
	end
end

--[[
	@author LaoY
	@des	加入国战语音
	@param1 roomName
	@param2 is_can_anchor 是否能发言
	@return number
--]]
function VoiceManager:JoinNationalRoom(roomName,is_can_anchor,msTimeout)
	self:SetMode(GCloudVoiceMode.RealTime)
	local code
	if msTimeout then
		code = voiceMgr:JoinNationalRoom(roomName,is_can_anchor,msTimeout)
	else
		code = voiceMgr:JoinNationalRoom(roomName,is_can_anchor)
	end
	if code ~= 0 then
		log('--LaoY VoiceManager.lua,JoinNationalRoom-- code=',code)
	end
end

-- 退出 小队语音 国战语音
function VoiceManager:QuitRoom(roomName,msTimeout)
	local code
	if msTimeout then
		code = voiceMgr:QuitRoom(roomName,msTimeout)
	else
		code = voiceMgr:QuitRoom(roomName)
	end
	if code ~= 0 then
		log('--LaoY VoiceManager.lua,QuitRoom-- code=',code)
	end
end

-- 打开麦克风
function VoiceManager:OpenMic()
	local code = voiceMgr:OpenMic()
	if code ~= 0 then
		log('--LaoY VoiceManager.lua,OpenMic-- code=',code)
	end
end

-- 关闭麦克风
function VoiceManager:CloseMic()
	local code = voiceMgr:CloseMic()
	if code ~= 0 then
		log('--LaoY VoiceManager.lua,CloseMic-- code=',code)
	end
end

-- 打开扬声器
function VoiceManager:OpenSpeaker()
	local code = voiceMgr:OpenSpeaker()
	if code ~= 0 then
		log('--LaoY VoiceManager.lua,OpenSpeaker-- code=',code)
	end
end

-- 关闭扬声器
function VoiceManager:CloseSpeaker()
	local code = voiceMgr:CloseSpeaker()
	if code ~= 0 then
		log('--LaoY VoiceManager.lua,CloseSpeaker-- code=',code)
	end
end

--[[
	@author LaoY
	@des	加入房间的回调
			GCloudVoiceCompleteCode code, string roomName, int memberID
	@param1 code 参见GCloudVoiceCompleteCode定义
	@param2 roomName 加入的房间名
	@param3 memberID 如果加入成功的话，表示加入后的成员ID
--]]
function VoiceManager:JoinRoomHandler(func)
	local function func(code,roomName,memberID)
		code = tostring(code)
		GlobalEvent:Brocast(EventName.JoinRoomVoiceState,code == GCloudVoiceCompleteCode.GV_ON_JOINROOM_SUCC,roomName,memberID)
		if code ~= GCloudVoiceCompleteCode.GV_ON_JOINROOM_SUCC then
			log("---------VoiceManager:JoinRoomHandler------",code)
		end
	end
	voiceMgr:JoinRoomHandler(func)
end

--[[
	@author LaoY
	@des	退出房间的回调
			GCloudVoiceCompleteCode code, string roomName, int memberID
	@param1 code 参见GCloudVoiceCompleteCode定义
	@param2 roomName 退出的房间名
	@param3 memberID 如果加入成功的话，表示加入后的成员ID
--]]
function VoiceManager:QuitRoomHandler(func)
	local function func(code,roomName,memberID)
		code = tostring(code)
		GlobalEvent:Brocast(EventName.QuitRoomVoiceState,code == GCloudVoiceCompleteCode.GV_ON_QUITROOM_SUCC,roomName,memberID)
		if code ~= GCloudVoiceCompleteCode.GV_ON_QUITROOM_SUCC then
			log("---------VoiceManager:QuitRoomHandler------",code)
		end
	end
	voiceMgr:QuitRoomHandler(func)
end

--[[
	@author LaoY
	@des	退出房间的回调
			int[] members, int count
	@param1 members 改变状态的member成员，其值为[memberID | status]这样的对，总共有count对，status有“0”：停止说话; “1”：开始说话; “2”:继续说话。
			ps:members[1]成员 members[2]成员状态
	@param2 count 改变状态的成员的数目
--]]
function VoiceManager:OnMemberVoice(func)
	local function func(members,count)
		for i=0,count - 1 do
			local memberID = members[i*2]
			local status = members[i*2 + 1]
			GlobalEvent:Brocast(EventName.OnMemberVoiceState,memberID,status)
		end
	end
	voiceMgr:OnMemberVoice(func)
end

-- 禁言
function VoiceManager:ForbidMemberVoice(member,bEnable)
	local code = voiceMgr:ForbidMemberVoice(member,bEnable)
	if code ~= 0 then
		log('--LaoY VoiceManager.lua,ForbidMemberVoice-- code=',code)
	end
	return code == 0
end

--/*语音消息*/
--[[
	@author LaoY
	@des	设置超时时间，需要提前设置
	@param1 param1
--]]
function VoiceManager:ApplyMessageKey(msTimeout)
	if self.gcloud_voice_mode == GCloudVoiceMode.Messages then
		return
	end
	self:SetMode(GCloudVoiceMode.Messages)
	self.apply_message_state = false
	local code
	if msTimeout then
		code = voiceMgr:ApplyMessageKey(msTimeout)
	else
		code = voiceMgr:ApplyMessageKey()
	end
	if code ~= 0 then
		log('--LaoY VoiceManager:ApplyMessageKey-- code=',code)
	end
end

--[[
	@author LaoY
	@des	ApplyMessageKey的回调
			int[] members, int count
	@param1 code 参见GCloudVoiceCompleteCode定义
--]]
function VoiceManager:ApplyMessageKeyCompleteHandler()
	local function func(code)
		-- local enum_code = code:ToInt()
		code = tostring(code)
		self.apply_message_state = code == GCloudVoiceCompleteCode.GV_ON_MESSAGE_KEY_APPLIED_SUCC
		if not self.apply_message_state then
			log("---------VoiceManager:ApplyMessageKeyCompleteHandler------",code)
		end
	end
	voiceMgr:ApplyMessageKeyCompleteHandler(func)
end

-- 设置单个语音最长的长度
function VoiceManager:SetMaxMessageLength(msTimeout)
	local code
	if msTimeout then
		code = voiceMgr:SetMaxMessageLength(msTimeout)
	else
		code = voiceMgr:SetMaxMessageLength()
	end
	if code ~= 0 then
		log('--LaoY VoiceManager:SetMaxMessageLength-- code=',code)
	end
end

-- 开始录音
function VoiceManager:StartRecording(file_name)
	if not self.apply_message_state then
		return
	end
	local filePath = self.voice_file_path .. file_name .. self.voice_extname
	local code = voiceMgr:StartRecording(filePath)
	if code ~= 0 then
		log('--LaoY VoiceManager:StartRecording-- code=',code)
	end
end

-- 停止录音
function VoiceManager:StopRecording()
	local code = voiceMgr:StopRecording()
	if code ~= 0 then
		log('--LaoY VoiceManager:StopRecording-- code=',code)
	end
end

-- 上传语音文件到服务器
function VoiceManager:UploadRecordedFile(file_name,msTimeout)
	local filePath = self.voice_file_path .. file_name .. self.voice_extname
	local code
	if msTimeout then
		code = voiceMgr:UploadRecordedFile(filePath,msTimeout)
	else
		code = voiceMgr:UploadRecordedFile(filePath)
	end
	if code ~= 0 then
		log('--LaoY VoiceManager:UploadRecordedFile-- code=',code)
	end
end

--[[
	@author LaoY
	@des	上传文件回调
			(GCloudVoiceCompleteCode code, string filepath, string fileid)
	@param1 code 参见GCloudVoiceCompleteCode定义
	@param2 filepath 文件路径
	@param3 fileid 云服务器保存的ID
--]]
function VoiceManager:UploadReccordFileCompletehandler()
	local function func(code,filepath,fileid)
		code = tostring(code)
		local file_name = string.gsub(filepath,self.voice_file_path, "")
		file_name = string.gsub(file_name,self.voice_extname, "")
		GlobalEvent:Brocast(EventName.UploadVoiceState,code == GCloudVoiceCompleteCode.GV_ON_UPLOAD_RECORD_DONE,file_name,fileid)
		if code ~= GCloudVoiceCompleteCode.GV_ON_UPLOAD_RECORD_DONE then
			log("---------VoiceManager:UploadReccordFileCompletehandler------",code)
		end
	end
	voiceMgr:UploadReccordFileCompletehandler(func)
end

-- 下载文件
--[[
	@author LaoY
	@des	
	@param4 force 是否强制下载，如果不是强制下载，检查是否存在音频文件，存在就不下载；
--]]
function VoiceManager:DownloadRecordedFile(fileId,downloadFileName,msTimeout,force)
	local code
	local downloadFilePath = self.voice_file_path .. downloadFileName .. self.voice_extname
	if not force and self:IsExistFile(downloadFilePath) then
		GlobalEvent:Brocast(EventName.DownloadVoiceState,true,downloadFileName,fileId)
		return
	end
	if msTimeout then
		code = voiceMgr:DownloadRecordedFile(fileId,downloadFilePath,msTimeout)
	else
		code = voiceMgr:DownloadRecordedFile(fileId,downloadFilePath)
	end
	if code ~= 0 then
		log('--LaoY VoiceManager:DownloadRecordedFile-- code=',code)
	end
end

--[[
	@author LaoY
	@des	下载文件回调
			(GCloudVoiceCompleteCode code, string filepath, string fileid)
	@param1 code 参见GCloudVoiceCompleteCode定义
	@param2 filepath 文件路径
	@param3 fileid 云服务器保存的ID
--]]
function VoiceManager:DownloadRecordFileCompletehandler()
	local function func(code,filepath,fileid)
		code = tostring(code)
		local file_name = string.gsub(filepath,self.voice_file_path, "")
		file_name = string.gsub(file_name,self.voice_extname, "")
		GlobalEvent:Brocast(EventName.DownloadVoiceState,code == GCloudVoiceCompleteCode.GV_ON_DOWNLOAD_RECORD_DONE,file_name,fileid)
		if code ~= GCloudVoiceCompleteCode.GV_ON_DOWNLOAD_RECORD_DONE then
			log("---------VoiceManager:DownloadRecordFileCompletehandler------",code)
		end
	end
	voiceMgr:DownloadRecordFileCompletehandler(func)
end

-- 播放语音文件
function VoiceManager:PlayRecordedFile(downloadFileName)
	if not self.apply_message_state then
		return
	end
	local downloadFilePath = self.voice_file_path .. downloadFileName .. self.voice_extname
	local code = voiceMgr:PlayRecordedFile(downloadFilePath)
	if code ~= 0 then
		log('--LaoY VoiceManager:PlayRecordedFile-- code=',code)
	end
end

--[[
	@author LaoY
	@des	播放结束回调
			(GCloudVoiceCompleteCode code, string filepath)
	@param1 code 参见GCloudVoiceCompleteCode定义
	@param2 filepath 文件路径
--]]
function VoiceManager:PlayRecordFilCompletehandler()
	local function func(code,filepath)
		code = tostring(code)
		local file_name = string.gsub(filepath,self.voice_file_path, "")
		file_name = string.gsub(file_name,self.voice_extname, "")
		GlobalEvent:Brocast(EventName.PlayRecordState,code == GCloudVoiceCompleteCode.GV_ON_PLAYFILE_DONE,file_name)
		if code ~= GCloudVoiceCompleteCode.GV_ON_PLAYFILE_DONE then
			log("---------VoiceManager:PlayRecordFilCompletehandler------",code)
		end
	end
	voiceMgr:PlayRecordFilCompletehandler(func)
end

-- 停止播放文件
function VoiceManager:StopPlayFile()
	local code = voiceMgr:StopPlayFile()
	if code ~= 0 then
		log('--LaoY VoiceManager:StopPlayFile-- code=',code)
	end
end

-- 获取语音文件时长
function VoiceManager:GetFileParam(filepath)
	return voiceMgr:GetFileParam(filepath)
end

--/*语音转文字*/
--[[
	@author LaoY
	@des	
	@param1 fileID 		上传云服务器返回的id
	@param1 language    0 才是中文，其他语音不详
--]]
function VoiceManager:SpeechToText(fileID,language,msTimeout)
	self:SetMode(GCloudVoiceMode.Translation)
	language = language or 0
	local code
	if msTimeout then
		code = voiceMgr:SpeechToText(fileID,language,msTimeout)
	else
		code = voiceMgr:SpeechToText(fileID,language)
	end
	if code ~= 0 then
		log('--LaoY VoiceManager:SpeechToText-- code=',code)
	end
end

--[[
	@author LaoY
	@des	语音转文字回调
			(GCloudVoiceCompleteCode code, string fileID, string result)
	@param1 code 参见GCloudVoiceCompleteCode定义
	@param2 fileID
	@param3 result 成功返回文字字符串
--]]
function VoiceManager:OnSpeechToText()
	local function func(code,fileID,result)
		-- local file_name = string.gsub(filepath,self.voice_file_path, "")
		-- file_name = string.gsub(file_name,self.voice_extname, "")
		code = tostring(code)
		GlobalEvent:Brocast(EventName.SpeechToTextState,code == GCloudVoiceCompleteCode.GV_ON_STT_SUCC,fileID,result)
		if code ~= GCloudVoiceCompleteCode.GV_ON_STT_SUCC then
			log("--------VoiceManager:OnSpeechToText---------",code)
		end
	end
	voiceMgr:OnSpeechToText(func)
end

-- 获取麦克风等级
function VoiceManager:GetMicLevel()
	return voiceMgr:GetMicLevel()
end

-- 获取扬声器等级
function VoiceManager:GetSpeakerLevel()
	return voiceMgr:GetSpeakerLevel()
end

-- 设置扬声器声音
function VoiceManager:SetSpeakerVolume(vol)
	local code = voiceMgr:SetSpeakerVolume(vol)
	if code ~= 0 then
		log('--LaoY VoiceManager:SetSpeakerVolume-- code=',code)
	end
end

--是否存在音频文件，如果存在而且时长大于0，返回true；否则返回false
function VoiceManager:IsExistFile(file_path)
	return voiceMgr:IsExistFile(file_path) == 1
end