--Unity和C#定义的枚举或者常量

module(...)

UpdateMode = {
    NoUpdate = 0,
    TestUpdate = 1,
    Update = 2,
}

TcpEvent = {
    ConnnectSuccess = 1,
    ConnnectFail = 2,
    SendSuccess = 4,
    ReceiveSuccess = 5,
    Exception = 6,
    Disconnect = 7,
    SendFail = 8,
    ReceiveFail = 9,
    ReceiveMessage = 255,
}

DOTween ={
	LoopType ={
        Restart = 0,
        Yoyo = 1,
        Incremental = 2,
	},
	RotateMode ={
		Fast = 0,
		FastBeyond360 = 1,
		WorldAxisAdd = 2,
		LocalAxisAdd = 3,
	},
	Ease = 
	{
		Unset = 0,
		Linear = 1,
		InSine = 2,
		OutSine = 3,
		InOutSine = 4,
		InQuad = 5,
		OutQuad = 6,
		InOutQuad = 7,
		InCubic = 8,
		OutCubic = 9,
		InOutCubic = 10,
		InQuart = 11,
		OutQuart = 12,
		InOutQuart = 13,
		InQuint = 14,
		OutQuint = 15,
		InOutQuint = 16,
		InExpo = 17,
		OutExpo = 18,
		InOutExpo = 19,
		InCirc = 20,
		OutCirc = 21,
		InOutCirc = 22,
		InElastic = 23,
		OutElastic = 24,
		InOutElastic = 25,
		InBack = 26,
		OutBack = 27,
		InOutBack = 28,
		InBounce = 29,
		OutBounce = 30,
		InOutBounce = 31,
		Flash = 32,
		InFlash = 33,
		OutFlash = 34,
		InOutFlash = 35,
	},
	PathType =
	{
		Linear = 0,
		CatmullRom = 1,
		InOutQuad = 7,
	}
}

UILabel ={
	Overflow= {
		ShrinkContent = 0,
		ClampContent = 1,
		ResizeFreely = 2,
		ResizeHeight = 3,
	},
	Alignment = {
		Automatic = 0,
		Left = 1,
		Center = 2,
		Right = 3,
		Justified = 4,
	}
}

UIAnchor = {
	Side = {
		BottomLeft = 0,
		Left = 1,
		TopLeft = 2,
		Top = 3,
		TopRight = 4,
		Right = 5,
		BottomRight = 6,
		Bottom = 7,
		Center = 8,
	}
}

UIWidget = {
	Pivot = {
		TopLeft =0,
		Top =1,
		TopRight =2,
		Left = 3,
		Center = 4,
		Right = 5,
		BottomLeft = 6,
		Bottom = 7,
		BottomRight = 8,
	},
}

UIScrollView =
{
	Movement =
	{
		Horizontal = 0,
		Vertical = 1,
		Unrestricted = 2,
		Custom = 3,
	}
}

UIEvent = {
	submit = 1,
	click = 2,
	doubleclick = 3,
	hover = 4,
	press = 5, 
	select = 6,
	scroll = 7,
	change = 8,
	focuschange = 9,

	dragstart = 11,
	drag = 12,
	dragout = 13,
	dragover = 14,
	dragend = 15,

	scrolldragstarted = 21,
	scrolldragfinished = 22,
	scrollmomentummove = 23,
	scrollstoppedmoving = 24,
	onenable = 30,

    UICenterOnChildOnCenter = 31,
    UIPanelOnClipMove = 41,
    UIInputOnValidate = 51,
    UIWrapContentOnInitializeItem = 52,

	longpress = 101,
	repeatpress = 102,
}

UISprite = 
{
	Flip = 
	{
		Nothing = 0,
		Horizontally = 1,
		Vertically = 2,
		Both = 3,
	}	
}

Space = {
	World = 0,
	Self = 1,
}

Task = {
	NpcMark = {
		Nothing = 0,
		Accept = 1,--"task_npcaccept",
		Doing = 2,--"task_npcfinishnot",
		Done = 3,--"task_npcfinish",

	}
}

Seeker = {
	TraversableTag ={
		BasicGround = 1,
		Sky = 2,
	}
}

QiniuType = {
	None = 0,
	Image = 1,
	Audio = 2,
}

AudioRecordError = 
{
	None = 0,
	FileNotExist = 1,
	AudioNoData = 2,
	NoMicrophone = 3,
	IsRecording = 4,
	IsNotRecording = 5,
	RecordTooShort = 6,
	IsSilence = 7,
	IsToShort = 8,
}

KeyCode ={
	Escape = 27,
	A = 97,
}

UIDrawCall={
	Clipping = {
		None = 0,
		TextureMask = 1,
		SoftClip = 3,
		ConstrainButDontClip = 4,
	}
}

UIBasicSprite = {
	Nothing = 0,
	Horizontally = 1,
	Vertically = 2,
	Both = 3,
}

Sdk = {
	UploadType = {
		create_role = "0",
		level_up = "0",
		start_instance = "0",
		finish_instance = "0",
		vip_level_up = "0",
		start_game = "0",
	}
}

Kaopu = {
	UploadType = {
		create_role = "1",
		level_up = "2",
		start_instance = "3",
		finish_instance = "4",
		vip_level_up = "5",
		start_game = "6",
	},
	DkpConfig ={
		LOGIN_YSDK_ERROR = -1, --获取错误, 当前未登录或者非YSDK渠道
		LOGIN_YSDK_ELSE = 0, --其他方式登录
		LOGIN_YSDK_QQ = 1, --QQ登录
		LOGIN_YSDK_WX = 2, --微信登录
	},
}

ShouMeng ={
	UploadType = {
		create_role = "createRole",
		level_up = "levelUp",
		start_game = "enterServer",
	}
}

RenderTextureFormat = {
	ARGB32 = 0,
	Depth = 1,
	ARGBHalf = 2,
	Shadowmap = 3,
	RGB565 = 4,
	ARGB4444 = 5,
	ARGB1555 = 6,
	Default = 7,
}

RenderTextureReadWrite = {
	Default = 0,
	Linear = 1,
	sRGB = 2,
}



Share = {
	PlatformType = {
		Unknown = 0,
		SinaWeibo = 1,			--Sina Weibo         
		TencentWeibo = 2,		--Tencent Weibo          
		DouBan = 5,				--Dou Ban           
		QZone = 6, 				--QZone           
		Renren = 7,				--Ren Ren           
		Kaixin = 8,				--Kai Xin          
		Pengyou = 9,			--Friends          
		Facebook = 10,			--Facebook         
		Twitter = 11,			--Twitter         
		Evernote = 12,			--Evernote        
		Foursquare = 13,		--Foursquare      
		GooglePlus = 14,		--Google+       
		Instagram = 15,			--Instagram      
		LinkedIn = 16,			--LinkedIn       
		Tumblr = 17,			--Tumblr         
		Mail = 18, 				--Mail          
		SMS = 19,				--SMS           
		Print = 20, 			--Print       
		Copy = 21,				--Copy             
		WeChat = 22,		    --WeChat Friends    
		WeChatMoments = 23,	    --WeChat WechatMoments   
		QQ = 24,				--QQ              
		Instapaper = 25,		--Instapaper       
		Pocket = 26,			--Pocket           
		YouDaoNote = 27, 		--You Dao Note           
		Pinterest = 30, 		--Pinterest    
		Flickr = 34,			--Flickr          
		Dropbox = 35,			--Dropbox          
		VKontakte = 36,			--VKontakte       
		WeChatFavorites = 37,	--WeChat Favorited        
		YiXinSession = 38, 		--YiXin Session   
		YiXinTimeline = 39,		--YiXin Timeline   
		YiXinFav = 40,			--YiXin Favorited  
		MingDao = 41,          	--明道
		Line = 42,             	--Line
		WhatsApp = 43,         	--Whats App
		KakaoTalk = 44,         --KakaoTalk
		KakaoStory = 45,        --KakaoStory 
		FacebookMessenger = 46, --FacebookMessenger
		Bluetooth = 48,         --Bluetooth
		Alipay = 50,
	},
	NotifyType = {
		Auth = 1,
		Share = 2,
		ShowUser = 3,
		GetFriends = 4,
		FollowFriend = 5,
	},
	ContentType ={
		Auto = 0,		--自动(iOS为自动，安卓仅为Text)
		Text = 1, 		--文字分享
		Image = 2,		--图文分享
		Webpage = 4,	--链接分享
		Music = 5,		--音乐分享 
		Video = 6,		--视频分享 
		App = 7, 		--应用分享
		File = 8,		--附件分享
		Emoji = 9,		--表情分享
	},
	ResponseState = {
		Begin = 0,
		Success = 1,
		Fail = 2,
		Cancel = 3
	}
}

SpineAnimationEvent = {
	Sync = 0,
	Start = 1,
	Complete = 2,
}

BatchCall=
{	
	ObjType = {
		RenderObjectHandler = 1,
		HudHandler = 2,
	},
	FuncType =
	{
		--RenderObjectHandler
		SetMatsColor = 1,
		SetMatsFloat = 2,
		SetMatsInt = 3,
		SetMatsVector = 4,
		DoMatsActionList = 5,
		SetMats = 6,
		shadowHeight = 7,
		matColor = 8,
		outline = 9,
		RenderAddMat = 10,
		RenderResizeMatCnt = 11,
		FadeShow = 12,
		FadeHide = 13,
		RenderDelMat = 14,
		AddRenderObj = 15,
		DelRenderObj = 16,
		--Hud
		target = 1,
		gameCamera = 2,
		uiCamera = 3,
		isAutoUpdate = 4,
		walkerEventHandler = 5,
		ResetHud = 6,
	}
}

FullScreenMovieControlMode = {
	Full = 0,
	Minimal = 1,
	CancelOnInput = 2,
	Hidden = 3,
}

ErrorCorrectionType ={
	L = 0,
	M = 1,
	Q = 2,
	H = 3,
}