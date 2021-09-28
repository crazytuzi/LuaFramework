--[[
	文件名: GCloudVoiceDefine.lua
	描述: 语音聊天中用到的错误码
	创建人: yuechunlin
	创建时间: 2017.04.12
-- ]]

-- 调用语音函数的返回
gv.GCloudVoiceErrno = {
    GCLOUD_VOICE_SUCC           	= 0,
	--common base err
	GCLOUD_VOICE_PARAM_NULL 		= 0x1001, -- 4097, some param is null
	GCLOUD_VOICE_NEED_SETAPPINFO 	= 0x1002, -- 4098, you should call SetAppInfo first before call other api
	GCLOUD_VOICE_INIT_ERR 			= 0x1003, -- 4099, Init Erro
	GCLOUD_VOICE_RECORDING_ERR 		= 0x1004, -- 4100, now is recording, can't do other operator
	GCLOUD_VOICE_POLL_BUFF_ERR 		= 0x1005, -- 4101, poll buffer is not enough or null 
	GCLOUD_VOICE_MODE_STATE_ERR 	= 0x1006, -- 4102, call some api, but the mode is not correct, maybe you shoud call SetMode first and correct
	GCLOUD_VOICE_PARAM_INVALID 		= 0x1007, -- 4103, some param is null or value is invalid for our request, used right param and make sure is value range is correct by our comment 
	GCLOUD_VOICE_OPENFILE_ERR 		= 0x1008, -- 4104, open a file err
	GCLOUD_VOICE_NEED_INIT 			= 0x1009, -- 4105, you should call Init before do this operator
	GCLOUD_VOICE_ENGINE_ERR 		= 0x100A, -- 4106, you have not get engine instance, this common in use c# api, but not get gcloudvoice instance first
	GCLOUD_VOICE_POLL_MSG_PARSE_ERR = 0x100B, -- 4107, this common in c# api, parse poll msg err
	GCLOUD_VOICE_POLL_MSG_NO 		= 0x100C, -- 4108, poll, no msg to update
	--realtime err
	GCLOUD_VOICE_REALTIME_STATE_ERR = 0x2001, -- 8193, call some realtime api, but state err, such as OpenMic but you have not Join Room first
	GCLOUD_VOICE_JOIN_ERR 			= 0x2002, -- 8194, join room failed
	GCLOUD_VOICE_QUIT_ROOMNAME_ERR 	= 0x2003, -- 8195, quit room err, the quit roomname not equal join roomname
	GCLOUD_VOICE_OPENMIC_NOTANCHOR_ERR = 0x2004, -- 8196, open mic in bigroom,but not anchor role
	--message err
	GCLOUD_VOICE_AUTHKEY_ERR 		= 0x3001, -- 12289, apply authkey api error
	GCLOUD_VOICE_PATH_ACCESS_ERR 	= 0x3002, -- 12290, the path can not access ,may be path file not exists or deny to access
	GCLOUD_VOICE_PERMISSION_MIC_ERR = 0x3003, -- 12291, you have not right to access micphone in android
	GCLOUD_VOICE_NEED_AUTHKEY 		= 0x3004, -- 12292,you have not get authkey, call ApplyMessageKey first
	GCLOUD_VOICE_UPLOAD_ERR 		= 0x3005, -- 12293, upload file err
	GCLOUD_VOICE_HTTP_BUSY 			= 0x3006, -- 12294, http is busy,maybe the last upload/download not finish.
	GCLOUD_VOICE_DOWNLOAD_ERR 		= 0x3007, -- 12295, download file err
	GCLOUD_VOICE_SPEAKER_ERR 		= 0x3008, -- 12296, open or close speaker tve error
	GCLOUD_VOICE_TVE_PLAYSOUND_ERR 	= 0x3009, -- 12297, tve play file error
    GCLOUD_VOICE_AUTHING 			= 0x300a, -- 12298, Already in applying auth key processing
	GCLOUD_VOICE_INTERNAL_TVE_ERR 	= 0x5001, -- 20481, internal TVE err, our used
	GCLOUD_VOICE_INTERNAL_VISIT_ERR = 0x5002, -- 20482, internal Not TVE err, out used
	GCLOUD_VOICE_INTERNAL_USED 		= 0x5003, -- 20483, internal used, you should not get this err num
    GCLOUD_VOICE_BADSERVER 			= 0x06001,-- 24577, bad server address,should be "udp:--capi.xxx.xxx.com"
    GCLOUD_VOICE_STTING 			= 0x07001,-- 28673, Already in speach to text processing
}

-- 回调函数的状态参数的取值    
gv.GCloudVoiceCompleteCode = {
	GV_ON_JOINROOM_SUCC = 1,	--join room succ
	GV_ON_JOINROOM_TIMEOUT = 2,  --join room timeout
	GV_ON_JOINROOM_SVR_ERR = 3,  --communication with svr occur some err, such as err data recv from svr
	GV_ON_JOINROOM_UNKNOWN = 4, --reserved, our internal unknow err
	GV_ON_NET_ERR = 5,  --net err,may be can't connect to network
	GV_ON_QUITROOM_SUCC = 6, --quitroom succ, if you have join room succ first, quit room will alway return succ
	GV_ON_MESSAGE_KEY_APPLIED_SUCC = 7,  --apply message authkey succ
	GV_ON_MESSAGE_KEY_APPLIED_TIMEOUT = 8,		--apply message authkey timeout
	GV_ON_MESSAGE_KEY_APPLIED_SVR_ERR = 9,  --communication with svr occur some err, such as err data recv from svr
	GV_ON_MESSAGE_KEY_APPLIED_UNKNOWN = 10,  --reserved,  our internal unknow err
    GV_ON_UPLOAD_RECORD_DONE = 11,  --upload record file succ
    GV_ON_UPLOAD_RECORD_ERROR = 12,  --upload record file occur error
    GV_ON_DOWNLOAD_RECORD_DONE = 13,	--download record file succ
    GV_ON_DOWNLOAD_RECORD_ERROR = 14,	--download record file occur error
    GV_ON_STT_SUCC = 15, -- speech to text successful
    GV_ON_STT_TIMEOUT = 16, -- speech to text with timeout
    GV_ON_STT_APIERR = 17, -- server's error
	GV_ON_PLAYFILE_DONE = 18,  --the record file played end
    GV_ON_ROOM_OFFLINE = 19, -- Dropped from the room
    GV_ON_UNKNOWN = 20,
}

-- 错误值对应的提示信息
gv.GCloudVoiceErrnoHint = {
	[gv.GCloudVoiceErrno.GCLOUD_VOICE_PARAM_NULL] 			= TR("some param is null"), -- 
	[gv.GCloudVoiceErrno.GCLOUD_VOICE_NEED_SETAPPINFO] 		= TR("需要先调用SetAppInfo"), -- 
	[gv.GCloudVoiceErrno.GCLOUD_VOICE_INIT_ERR] 			= TR("语音功能初始化错误"), -- 
	[gv.GCloudVoiceErrno.GCLOUD_VOICE_RECORDING_ERR] 		= TR("now is recording, can't do other operator"), -- 
	[gv.GCloudVoiceErrno.GCLOUD_VOICE_POLL_BUFF_ERR] 		= TR("poll buffer is not enough or null"), -- 
	[gv.GCloudVoiceErrno.GCLOUD_VOICE_MODE_STATE_ERR] 		= TR("需要先调用SetMode设置成实时模式"), -- 
	[gv.GCloudVoiceErrno.GCLOUD_VOICE_PARAM_INVALID] 		= TR("传入的参数不对"), -- 
	[gv.GCloudVoiceErrno.GCLOUD_VOICE_OPENFILE_ERR] 		= TR("open a file err"), -- 
	[gv.GCloudVoiceErrno.GCLOUD_VOICE_NEED_INIT] 			= TR("需要先调用Init进行初始化"), -- 
	[gv.GCloudVoiceErrno.GCLOUD_VOICE_ENGINE_ERR] 			= TR("you have not get engine instance"), -- 
	[gv.GCloudVoiceErrno.GCLOUD_VOICE_POLL_MSG_PARSE_ERR] 	= TR("this common in c# api, parse poll msg err"), -- 
	[gv.GCloudVoiceErrno.GCLOUD_VOICE_POLL_MSG_NO] 			= TR("poll, no msg to update"), -- 
	[gv.GCloudVoiceErrno.GCLOUD_VOICE_REALTIME_STATE_ERR] 	= TR("实时语音状态不对"), -- 
	[gv.GCloudVoiceErrno.GCLOUD_VOICE_JOIN_ERR] 			= TR("join room failed"), -- 
	[gv.GCloudVoiceErrno.GCLOUD_VOICE_QUIT_ROOMNAME_ERR] 	= TR("quit room err, the quit roomname not equal join roomname"), -- 
	[gv.GCloudVoiceErrno.GCLOUD_VOICE_OPENMIC_NOTANCHOR_ERR] = TR("当前以听众身份加入的大房间，不能开麦"), -- 
	[gv.GCloudVoiceErrno.GCLOUD_VOICE_AUTHKEY_ERR] 			= TR("请求Key的内部错误，此时需要联系GCloud团队，并提供日志进行定位"), -- 
	[gv.GCloudVoiceErrno.GCLOUD_VOICE_PATH_ACCESS_ERR] 		= TR("提供的路径不合法或者不可写"), -- 
	[gv.GCloudVoiceErrno.GCLOUD_VOICE_PERMISSION_MIC_ERR] 	= TR("you have not right to access micphone in android"), -- 
	[gv.GCloudVoiceErrno.GCLOUD_VOICE_NEED_AUTHKEY] 		= TR("需要先调用GetAuthKey申请许可"), -- 
	[gv.GCloudVoiceErrno.GCLOUD_VOICE_UPLOAD_ERR] 			= TR("上传语音文件失败"), -- 
	[gv.GCloudVoiceErrno.GCLOUD_VOICE_HTTP_BUSY] 			= TR("还在上一次上传或者下载中，需要等待后再尝试"), -- 
	[gv.GCloudVoiceErrno.GCLOUD_VOICE_DOWNLOAD_ERR] 		= TR("下载语音文件失败"), -- 
	[gv.GCloudVoiceErrno.GCLOUD_VOICE_SPEAKER_ERR] 			= TR("打开麦克风失败"), -- 
	[gv.GCloudVoiceErrno.GCLOUD_VOICE_TVE_PLAYSOUND_ERR] 	= TR("tve play file error"), -- 
    [gv.GCloudVoiceErrno.GCLOUD_VOICE_AUTHING] 				= TR("Already in applying auth key processing"), -- 
	[gv.GCloudVoiceErrno.GCLOUD_VOICE_INTERNAL_TVE_ERR] 	= TR("无法录音，请在“设置”中允许访问你的手机麦克风"), -- 
	[gv.GCloudVoiceErrno.GCLOUD_VOICE_INTERNAL_VISIT_ERR] 	= TR("internal Not TVE err, out used"), -- 
	[gv.GCloudVoiceErrno.GCLOUD_VOICE_INTERNAL_USED] 		= TR("internal used, you should not get this err num"), -- 
    [gv.GCloudVoiceErrno.GCLOUD_VOICE_BADSERVER] 			= TR("bad server address"), -- 
    [gv.GCloudVoiceErrno.GCLOUD_VOICE_STTING] 				= TR("正在进行上一次的语音转文字"), -- 

    -- 异步返回错误提示信息
	[gv.GCloudVoiceCompleteCode.GV_ON_JOINROOM_TIMEOUT] = TR("加入房间超时"),  --join room timeout
	[gv.GCloudVoiceCompleteCode.GV_ON_JOINROOM_SVR_ERR] = TR("加入房间时服务器错误"),  --communication with svr occur some err, such as err data recv from svr
	[gv.GCloudVoiceCompleteCode.GV_ON_JOINROOM_UNKNOWN] = TR("加入房间时未知错误"), --reserved, our internal unknow err
	[gv.GCloudVoiceCompleteCode.GV_ON_NET_ERR] = TR("网络错误"),  --net err,may be can't connect to network
	[gv.GCloudVoiceCompleteCode.GV_ON_MESSAGE_KEY_APPLIED_TIMEOUT] = TR("获取证书超时"),		--apply message authkey timeout
	[gv.GCloudVoiceCompleteCode.GV_ON_MESSAGE_KEY_APPLIED_SVR_ERR] = TR("获取证书时服务器错误"),  --communication with svr occur some err, such as err data recv from svr
	[gv.GCloudVoiceCompleteCode.GV_ON_MESSAGE_KEY_APPLIED_UNKNOWN] = TR("获取证书时未知错误"),  --reserved,  our internal unknow err
    [gv.GCloudVoiceCompleteCode.GV_ON_UPLOAD_RECORD_ERROR] = TR("上传语音文件失败"),  --upload record file occur error
    [gv.GCloudVoiceCompleteCode.GV_ON_DOWNLOAD_RECORD_ERROR] = TR("下载语音文件失败"),	--download record file occur error
    [gv.GCloudVoiceCompleteCode.GV_ON_STT_TIMEOUT] = TR("语音转文字超时"), -- speech to text with timeout
    [gv.GCloudVoiceCompleteCode.GV_ON_STT_APIERR] = TR("语音转文字失败"), -- server's error
    [gv.GCloudVoiceCompleteCode.GV_ON_UNKNOWN] = TR("未知错误"),
}

-- 回调函数对应的key
gv.GCloudVoiceEventType = {
	EVENT_GCLOUD_VOICE_JOIN_ROOM = 68,
    EVENT_GCLOUD_VOICE_STATUS_UPDATE = 69,
    EVENT_GCLOUD_VOICE_QUIT_ROOM = 70,
    EVENT_GCLOUD_VOICE_MEMBER_VOICE = 71,
    EVENT_GCLOUD_VOICE_UPLOAD_FILE = 72,
    EVENT_GCLOUD_VOICE_DOWNLOAD_FILE = 73,
    EVENT_GCLOUD_VOICE_PLAY_RECORDED_FILE = 74,
    EVENT_GCLOUD_VOICE_APPLY_MESSAGE_KEY = 75,
    EVENT_GCLOUD_VOICE_SPEECH_TO_TEXT = 76,
    EVENT_GCLOUD_VOICE_RECORDING = 77,
}

gv.GCloudLanguage = {
    China       = 0,
    Korean      = 1,
    English     = 2,
    Japanese    = 3,
}
        
gv.GCloudVoiceMode = {
	RealTime = 0,     -- realtime mode for TeamRoom or NationalRoom
	Messages = 1,     -- voice message mode
	Translation = 2,  -- speach to text mode
}
        
gv.GCloudVoiceMemberRole = {
    Anchor = 1,     -- member who can open microphone and say
    Audience = 2,   -- member who can only hear anchor's voice
}

gv.GCloudMemberStatus = {
	TalkEnd = 0, -- 停止说话
	TalkBegin = 1, -- 开始说话
	Talking = 2, -- 正在说话
}

-- 语音Sdk异步任务类型
VoiceAsyncTaskType = {
    eUpload = 1,  -- 上传文件
    eDownload = 2, -- 下载文件
    eSpeechToText = 3,  -- 语音转文字
}
