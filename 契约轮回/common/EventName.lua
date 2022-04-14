--
-- Author: LaoY
-- Date: 2018-06-29 14:31:10
--
-- 通用的全局事件

EventName = {
	ConnectSuccess 		= "EventName.ConnectSuccess",		--连接网络成功
	HotUpdateSuccess 	= "EventName.HotUpdateSuccess",		--热更新成功

	LoadComponent 		= "EventName.LoadComponent",		--预加载
	PreLoadObject 		= "EventName.PreLoadObject",		--预加载 Instantiate 对象

	GameStart 			= "EventName.GameStart",			--游戏开始
	ChangeSceneStart 	= "EventName.ChangeSceneStart",		--切换场景开始
	ChangeSceneEnd 		= "EventName.ChangeSceneEnd",		--切换场景完成
	ChangeSameScene 	= "EventName.ChangeSameScene",		--切换同一个场景
    CLOSE_LOADING 		= "EventName.CloseLoading",			--关闭loading界面
    DestroyLoading 		= "EventName.DestroyLoading",		-- 当前loading界面 销毁事件；同时存在两个，只会派发最后一个
    BLOCK_LOAD_FINISH = "EventName.BlockLoadFinish",    --某个地图块加载完

	GameReset 		= "EventName.GameReset",		--切换账号

	OpenNextSysTipPanel = "EventName.OpenNextSysTipPanel",			--打开下一个系统开放界面
	UpdateOpenFunction 	= "EventName.UpdateOpenFunction",			--打开新功能
	OpenFunctionState 	= "EventName.OpenFunctionState",			--打开新功能
	ShowSpecifiedMainRightIcon	=	"EventName.ShowSpecifiedMainRightIcon",		--显示指定的主界面右下角图标

	OpenPanel 			= "EventName.OpenPanel",			-- 打开界面 参数:界面名字__cname 界面层级layer 界面panel_type
	ClosePanel 			= "EventName.ClosePanel",			-- 关闭界面 参数:界面名字__cname 界面层级layer 界面panel_type

	ChangeLevel  		= "EventName.ChangeLevel", 			-- 等级改变,level

	KeyRelease  		= "EventName.KeyRelease", 			-- 按下键盘 开发服有效 参数见：InputManager.KeyCode

	SDKLoginSucess  	= "EventName.SDKLoginSucess", 			-- SDK登录成功
	REQ_PAYINFO  		= "EventName.REQ_PAYINFO", 			-- SDK登录成功
	SDKLogOut  			= "EventName.SDKLogOut", 			-- SDK登录成功


	-- 语音模块
	TestVoice 			= "EventName.TestVoice",			--测试语音
	TestModel 			= "EventName.TestModel",			--测试模块

	JoinRoomVoiceState 	= "EventName.JoinRoomVoiceState",	--加入房间 1.是否成功，2.加入的房间名，3.如果加入成功的话，表示加入的成员ID
	QuitRoomVoiceState 	= "EventName.QuitRoomVoiceState",	--退出房间 1.是否成功，2.退出的房间名，3.如果退出成功的话，表示退出的成员ID
	OnMemberVoiceState 	= "EventName.OnMemberVoiceState",	--成员状态变化 1.成员ID，2.成员状态(“0”：停止说话; “1”：开始说话; “2”:继续说话)

	UploadVoiceState 	= "EventName.UploadVoiceState",	    --上传语音文件状态 1.是否成功 2.文件名 3.fileid
	DownloadVoiceState 	= "EventName.DownloadVoiceState",	--下载语音文件状态 1.是否成功 2.文件名 3.fileid
	PlayRecordState 	= "EventName.PlayRecordState",		--播放语音文件结束 1.是否成功 2.文件名
	SpeechToTextState 	= "EventName.SpeechToTextState",	--语音转文字  1.是否成功 2.fileid 3.如果成功，返回翻译后得字符串

	EnergySavingModeEvent  =  "EventName.OnEnergySavingMode", --是否开户节能模式

    MONSTER_BE_LOCK = "EventName.MONSTER_BE_LOCK",--带大血条的精英怪被锁定
    ROLE_BE_LOCK = "EventName.ROLE_BE_LOCK",--角色被锁定


	CrossDay        =  "EventName.CrossDay", 			--跨天
	CrossDayAfter    =  "EventName.CrossDayAfter", 			--跨天后再过1分钟
	HotUpdateConfig =  "EventName.HotUpdateConfig", 	--热更配置 参数：config_name 配置名字


	NewSceneObject =  "EventName.NewSceneObject", 		--加载完场景对象  参数：sceneobject

    CLEAR_BLOOD_MONSTER  = "EventName.CLEAR_BLOOD_MONSTER",--其它人不要用,除了@ling

	GetPhoto =  "EventName.GetPhoto", 		--获取摄像机相片 
											-- type:1 TakePhoto 照相 2 SelectPhoto 选择相册 
											-- file_path 路径 
											-- file_name 名字 注意要用名字来识别是否为自己模块的功能 

	UIOriChange = "UIOriChange", --设备旋转方向事件
    -- oss 相关的方法均是异步
    -- ////////////////////////
    PutObject 		= "EventName.PutObject",		-- 上传文件到oss，用于相片上传
    GetObject 		= "EventName.GetObject",		-- 从oss下载文件，用于相片下载
    ObjectExists 	= "EventName.ObjectExists",		-- 从oss检查文件是否存在
    -- ////////////////////////

    -- 切换后台 后台回到游戏
    OnResume = 	"EventName.OnResume", 	-- 恢复
    OnPause = 	"EventName.OnPause", 	-- 挂起

    -- 
	FirstLanding = 	"EventName.FirstLanding", 	-- 首次登陆 参数：bool 是否首次登陆。true 是，false 否
	
	StartHandleTimeline = "EventName.StartHandleTimeline",  --开始处理时间轴
	EndHandleTimeline = "EventName.EndHandleTimeline",	--结束处理时间轴

	UpdateCameraSize = "EventName.UpdateCameraSize",  -- 改变摄像机大小

	StartRace = "EventName.StartRace",  --开始机甲竞速
	EndRace = "EventName.EndRace",	--结束机甲竞速

	SDKPlayerInfo = "EventName.SDKPlayerInfo",
	PaySucc = "EventName.PaySucc",  --儲值成功

	FbShareInfo = "EventName.FbShareInfo",  --Facebook分享
	DianZanInfo = "EventName.DianZanInfo",	--Facebook點贊
	BindEmailInfo = "EventName.BindEmailInfo", --綁定郵箱
	BindEmailState = "EventName.BindEmailState", --綁定郵箱狀態 登陸自動獲取，參數0未綁定，1已綁定


	StartDownLoadInfo = "EventName.StartDownLoadInfo", --綁定郵箱狀態 登陸自動獲取，參數0未綁定，1已綁定

	FbShareInfo = "EventName.FbShareInfo",  --Facebook分享
	DianZanInfo = "EventName.DianZanInfo",	--Facebook点赞
	BindEmailInfo = "EventName.BindEmailInfo", --绑定邮箱
	
}