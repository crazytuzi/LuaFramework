Sdk.szQQAppId = "1105054046";
Sdk.szWxAppId = "wxacbfe7e1bb3e800f";
Sdk.szQQAppKey = "M8n98P39CQCUWJFX";
Sdk.szWXAppKey = "b53b55619b2a92414ad42aef480974fd";

Sdk.szDaojuiOSOfferId = "1450006821";
Sdk.sziOSOfferId = "1450006278";
Sdk.szAndroidOfferId = "1450005929";
Sdk.szMsdkAid = "aid=mvip.yx.inside.jxqy_1105054046";

Sdk.szQGameKitWnsAppId = "203098";
Sdk.szIconUrl = "http://download.wegame.qq.com/gc/formal/common/1105054046/thumImg.png";

Sdk.ANDROID_PERMISSON_RECORD_AUDIO = "android.permission.RECORD_AUDIO";

Sdk.bQQGroupApiV2 = false; -- QQ群接口使用的v2api
Sdk.bHideQQGroupOpt = true; -- 屏蔽Q群相关信息

-- C#里面也有这个的定义，如果要调整，注意两边一起调整  Assets/Script/SdkInterface.cs:38
Sdk.tbPCVersionChannels = {
	["10026640"] = true;
	["10028405"] = true;
};

Sdk.tbPCVersionChannelNums = {};
for k,v in pairs(Sdk.tbPCVersionChannels) do
	Sdk.tbPCVersionChannelNums[tonumber(k)] = v;
end

Sdk.szWXInvitationUrl = "http://dwz.cn/5O6n7O";
Sdk.szQQInvitationUrl = "http://youxi.vip.qq.com/m/act/891cb717ef_jxqy_186532.html?_wv=1";
Sdk.szIOSBuluoUrl = "http://xiaoqu.qq.com/cgi-bin/bar/qqgame/handle_ticket?redirect_url=http%3A%2F%2Fxiaoqu.qq.com%2Fmobile%2Fbarindex.html%3F%26_bid%3D%26_wv%3D1027%26from%3Dgameblog_jxqy%23bid%3D304889&sourcetype=1";
Sdk.szAndroidBuluoUrl = "http://xiaoqu.qq.com/cgi-bin/bar/qqgame/handle_ticket?redirect_url=http%3A%2F%2Fxiaoqu.qq.com%2Fmobile%2Fbarindex.html%3F%26_bid%3D%26_wv%3D1027%26from%3Dgameblog_jxqy%23bid%3D304889&sourcetype=1";
Sdk.szXinyueUrl = "http://apps.game.qq.com/php/tgclub/v2/mobile_open/redirect";
Sdk.szXinyueGameId = "63";

-- 平台枚举
Sdk.ePlatform_None    = 0;
Sdk.ePlatform_Weixin  = 1;
Sdk.ePlatform_QQ      = 2;
Sdk.ePlatform_WTLogin = 3;
Sdk.ePlatform_QQHall  = 4;
Sdk.ePlatform_Guest   = 5;

-- WorldServer AreaId 定义于WorldServerConfig.h emAreaType
Sdk.eServerAreaWeiXin = 0;
Sdk.eServerAreaQQ     = 1;

-- os type
Sdk.eOSType_Windows = 0;
Sdk.eOSType_iOS     = 1;
Sdk.eOSType_Android = 2;

-- QGameKit 相关定义
Sdk.eQGameKit_CaptureType_AudioCapture     = 1;		--采集麦克风声音
Sdk.eQGameKit_CaptureType_AudioApolloVoice = 2;		--Apollo Voice组件提供声音
Sdk.eQGameKit_CaptureType_AudioGCloudVoice = 4;		--GCloud Voice组件提供声音
Sdk.eQGameKit_CaptureType_AudioCustom      = 8;		--自定义声音数据
Sdk.eQGameKit_CaptureType_VideoCapture     = 16;	--SDK录制视频数据
Sdk.eQGameKit_CaptureType_VideoCustom      = 32;	--自定义视频数据

Sdk.eQGameKit_Environment_Release = 0;	--正式环境
Sdk.eQGameKit_Environment_Debug   = 1;	--测试环境
Sdk.eQGameKit_Environment_Pre     = 2;	--预发布环境

Sdk.eQGameKit_LiveStatus_Unknown       = 0; --未知状态（在获取状态过程中发生了错误）
Sdk.eQGameKit_LiveStatus_Uninitialized = 1; --尚未初始化
Sdk.eQGameKit_LiveStatus_Prepared      = 2; --已准备好
Sdk.eQGameKit_LiveStatus_LiveStarting  = 3; --直播开启中
Sdk.eQGameKit_LiveStatus_LiveStarted   = 4; --直播已开始
Sdk.eQGameKit_LiveStatus_LivePaused    = 5; --直播已暂停
Sdk.eQGameKit_LiveStatus_LiveResume    = 6; --暂停恢复中
Sdk.eQGameKit_LiveStatus_LiveStopping  = 7; --直播结束中
Sdk.eQGameKit_LiveStatus_LiveStopped   = 8; --直播已结束
Sdk.eQGameKit_LiveStatus_Error         = 9; --直播过程出错

-- 定义的详细注释到WGPublicDefine.cs当中查找
Sdk.eFlag_Succ                       = 0;
Sdk.eFlag_QQ_NoAcessToken            = 1000;
Sdk.eFlag_QQ_UserCancel              = 1001;
Sdk.eFlag_QQ_LoginFail               = 1002;
Sdk.eFlag_QQ_NetworkErr              = 1003;
Sdk.eFlag_QQ_NotInstall              = 1004;
Sdk.eFlag_QQ_NotSupportApi           = 1005;
Sdk.eFlag_QQ_AccessTokenExpired      = 1006;
Sdk.eFlag_QQ_PayTokenExpired         = 1007;
Sdk.eFlag_WX_NotInstall              = 2000;
Sdk.eFlag_WX_NotSupportApi           = 2001;
Sdk.eFlag_WX_UserCancel              = 2002;
Sdk.eFlag_WX_UserDeny                = 2003;
Sdk.eFlag_WX_LoginFail               = 2004;
Sdk.eFlag_WX_RefreshTokenSucc        = 2005;
Sdk.eFlag_WX_RefreshTokenFail        = 2006;
Sdk.eFlag_WX_AccessTokenExpired      = 2007;
Sdk.eFlag_WX_RefreshTokenExpired     = 2008;
Sdk.eFlag_Error                      = -1;
Sdk.eFlag_Local_Invalid              = -2;
Sdk.eFlag_NotInWhiteList             = -3;
Sdk.eFlag_LbsNeedOpenLocationService = -4;
Sdk.eFlag_LbsLocateFail              = -5;
Sdk.eFlag_NeedLogin                  = 3001;
Sdk.eFlag_UrlLogin                   = 3002;
Sdk.eFlag_NeedSelectAccount          = 3003;
Sdk.eFlag_AccountRefresh             = 3004;
Sdk.eFlag_NeedRealNameAuth           = 3005;
Sdk.eFlag_Checking_Token             = 5001;
Sdk.eFlag_InvalidOnGuest             = -7;
Sdk.eFlag_Guest_AccessTokenInvalid   = 4001;
Sdk.eFlag_Guest_LoginFailed          = 4002;
Sdk.eFlag_Guest_RegisterFailed       = 4003;

Sdk.eMidas_PAYRESULT_ERROR      = -1;
Sdk.eMidas_PAYRESULT_SUCC       = 0;
Sdk.eMidas_PAYRESULT_CANCEL     = 2;
Sdk.eMidas_PAYRESULT_PARAMERROR = 3;
Sdk.eMidas_PAYSTATE_PAYSUCC     = 0;

Sdk.eMidasServerRet_Sussess              = 0;
Sdk.eMidasServerRet_ParamError           = 1001;
Sdk.eMidasServerRet_SystemBusy           = 1002; -- 系统繁忙
Sdk.eMidasServerRet_LoginError           = 1018; -- 登入校验失败
Sdk.eMidasServerRet_LackMoney            = 1004; -- 余额不足
Sdk.eMidasServerRet_RepeatBillNo         = 1002215; -- 订单号重复
Sdk.eMidasServerRet_BillDealing          = 3000111; -- 订单正在处理中..
Sdk.eMidasServerRet_PayRiskPunish        = 1145; -- 风控, 扣砖惩罚
Sdk.eMidasServerRet_PayRiskSeal          = 1146; -- 风控, 封号
Sdk.eMidasServerRet_PayRiskIntercept     = 1147; -- 风控, 拦截
Sdk.eMidasServerRet_PresentRiskIntercept = 1148; -- 风控, 拦截
Sdk.eMidasServerRet_PresentRiskSeal      = 1149; -- 风控, 封号

Sdk.eWXGroupRet_Suss          = 0;
Sdk.eQQGroupRet_Suss          = 0;
Sdk.eQQGroupRet_NotBind       = 2002; -- 没有绑定记录，
Sdk.eQQGroupRet_NotJoined     = 2003; --  查询失败，当前用户尚未加入QQ群，请先加入QQ群。
Sdk.eQQGroupRet_NotFoundGroup = 2007; -- 查询失败，当前公会绑定的QQ群已经解散或者不存在。

Sdk.eQQGroupRet2_HadBind   = 221001;
Sdk.eQQGroupRet2_NotBind   = 221002;
Sdk.eQQGroupRet2_BindOther = 221019;
Sdk.eQQGroupRet2_TokenFail = -120000;
Sdk.eQQGroupRet2_NotJoined = 4;

Sdk.eWXGroupRet_Suss          = 0;
Sdk.eWXGroupRet_NotPermit     = {[-10001] = true, [2009] = true}; -- 游戏没有建群权限
Sdk.eWXGroupRet_ParamErr      = {[-10002] = true, [2010] = true}; -- 参数错误
Sdk.eWXGroupRet_IDExist       = {[-10005] = true, [2011] = true}; -- 群ID已存在
Sdk.eWXGroupRet_OverCreateNum = {[-10006] = true, [2012] = true}; -- 建群数量超过上限
Sdk.eWXGroupRet_IDNotExist    = {[-10007] = true, [2013] = true}; -- 群ID不存在

Sdk.Def = {};
Sdk.Def.tbLaunchPrivilegeAward = {"Contrib", 50}; -- 登入特权每日签到额外
Sdk.Def.tbQQVipEveryDayAward   = {"item", 2393, 1}; -- QQ会员每日奖励
Sdk.Def.tbQQSVipEveryDayAward  = {"item", 2394, 1}; -- QQ超级会员每日奖励
Sdk.Def.tbQQVipGreenAward      = {"item", 2391, 1}; -- QQ会员新手礼包
Sdk.Def.tbQQSvipGreenAward     = {"item", 2392, 1}; -- QQ超级会员新手礼包
Sdk.Def.tbQQVipOpenAward       = {"item", 2389, 1}; -- QQ会员开通礼包
Sdk.Def.tbQQSvipOpenAward      = {"item", 2390, 1}; -- QQ超级会员开通礼包
Sdk.Def.tbWeixinTitleAward     = {"AddTimeTitle", 2005, -1}; -- 微信游戏中心首次
Sdk.Def.nWeixinTitleId = 2005;
Sdk.Def.nQQVipTitleId  = 2006;

Sdk.Def.TX_VIP_SAVEGROUP             = 86;
Sdk.Def.TX_VIP_DAY_REWARD            = 7;
Sdk.Def.TX_VIP_OPEN_REWARD           = 8;
Sdk.Def.TX_VIP_GREEN_REWARD          = 9;
Sdk.Def.TX_VIP_OPEN_MONTH            = 10;
Sdk.Def.TX_VIP_LATEST_OPEN_VIP       = 15;
Sdk.Def.TX_XINYUE_CHECK_DAY          = 13;
Sdk.Def.TX_XINYUE_LEVEL              = 14;
Sdk.Def.XG_EFUN_FACEBOOK_GROUP       = 108;
Sdk.Def.XG_EFUN_FACEBOOK_KEY         = 1;

Sdk.Def.SDK_INFO_SAVEGROUP                = 86;
Sdk.Def.SDK_INFO_BINDED_PHONE             = 16; -- 海外版本绑定手机
Sdk.Def.SDK_INFO_BINDED_PHONE_TX          = 16; -- 腾讯版本绑定手机
Sdk.Def.SDK_INFO_FB_INVITE_DAY            = 17;
Sdk.Def.SDK_INFO_FB_INVITE_COUNT          = 18;
Sdk.Def.SDK_INFO_FB_INVITE_PRICE_DAY      = 19;
Sdk.Def.SDK_INFO_XM_FB_CLICK_ED           = 20;
Sdk.Def.SDK_INFO_XM_EVALUEATE_ED          = 21;
Sdk.Def.SDK_INFO_QQ_INVITE_DISABLE        = 22;
Sdk.Def.SDK_INFO_SS_PARTNER_COUNT         = 23;
Sdk.Def.SDK_INFO_PC_VERSION_LOGIN_COUNT   = 24;

Sdk.Def.SDK_INFO_QQ_FRIEND_INVITE_VERSION = 25;
Sdk.Def.SDK_INFO_QQ_FRIEND_INVITED_COUNT  = 26;
Sdk.Def.SDK_INFO_QQ_FRIEND_INVITE_AWARDED = 27;

Sdk.Def.nAddQQFriendImityLine     = 5; -- 添加QQ好友所需的亲密度等级
Sdk.Def.bIsEfunTWHKWeekendActOpen = false;

Require("CommonScript/lib.lua");
-- 手Q邀请好友，活动配置
Sdk.Def.tbQQInviteFriendSetting = {
--[[	{-- 时间段不可重叠
		nBegin = Lib:ParseDateTime("2017-03-08 00:00:00"),
		nEnd  = Lib:ParseDateTime("2018-03-08 00:00:00"),
		nVersion = 1; -- 每次活动的version必须不同
	};--]]
};

-- 手Q邀请好友奖励
Sdk.Def.tbQQInviteFriendAward = {
	{nCount = 2, tbAward = {{"item", 1234, 10}, {"item", 1235, 10}} };
	{nCount = 5, tbAward = {{"Coin", 5000}} };
	{nCount = 10, tbAward = {{"Renown", 2000}} };
	{nCount = 20, tbAward = {{"Contrib", 5000}} };
};

-- Efun平台绑定手机奖励邮件
Sdk.Def.tbBindPhoneMail = {
	Title = "绑定手机奖励";
	Text = "绑定手机奖励";
	From = "系统";
	tbAttach = {{"Gold", 200}, {"item", 212, 10}, {"item", 785, 5}};
	nLogReazon = Env.LogWay_BindPhoneReward;
};

if version_kor then
	-- 韩国版本关联帐号奖励，200元宝
	Sdk.Def.tbBindPhoneMail = {
		Title = "关联账号奖励标题";
		Text = "关联账号奖励邮件内容";
		From = "系统";
		tbAttach = {{"Gold", 200}};
		nLogReazon = Env.LogWay_BindPhoneReward;
	};
end


Sdk.Def.tbPCVersionNoticeMail = {
	Title = "电脑版使用说明";
	Text = [[      亲爱的少侠，欢迎使用《剑侠情缘手游》电脑版。在电脑版中可以使用键盘进行基本操作。您可以通过 [FFFE0D]角色信息界面--操作--PC操作设置[-] 界面进行快捷键设置。
      电脑版目前暂不支持充值，您仍需[FFFE0D]回到手机端来完成充值支付[-]。对此带来的不便，敬请见谅。]];
	From = "系统";
}

Sdk.Def.tbFBInviteFriendsAward = {"item", 222, 5}; -- facebook邀请好友奖励,5个绿水晶
Sdk.Def.nFBInviteFriendsPriceCount = 40; -- facebook邀请好友人数(以上则有奖励)

-- 新马点击facebook奖励
Sdk.Def.tbXMFacebookClickAwardMail = {
	Title = "剑侠情缘论坛关注奖励";
	Text = "剑侠情缘论坛关注奖励http://www.jxqy.org";
	From = "系统";
	tbAttach = {{"Gold", 10}};
};

-- 新马评论任务奖励
Sdk.Def.tbXMEvaluateAwardMail = {
	Title = "商店评论任务奖励";
	Text = "商店评论任务奖励";
	From = "系统";
	tbAttach = {{"item", 785, 1}};
};

Sdk.Def.tbPlatformIcon = {
	[Sdk.ePlatform_Weixin]  = "WeiXinMark";
	[Sdk.ePlatform_QQ]      = "QQMark";
	[Sdk.ePlatform_Guest]   = "TouristMark";
};

Sdk.Def.tbPlatformName = {
	[Sdk.ePlatform_Weixin]  = "微信";
	[Sdk.ePlatform_QQ]      = "手Q";
	[Sdk.ePlatform_QQHall]  = "手Q";
	[Sdk.ePlatform_Guest]   = "游客";
}

Sdk.Def.tbWeixinLuckBagSetting = {
	["VIP6"] = --
		{"hongbaocard_4109_3222164606", "恭喜您达到[FFFE0D]剑侠尊享6[-]！"};
	["VIP9"] = --
		{"hongbaocard_4110_3222164606", "恭喜您达到[FFFE0D]剑侠尊享9[-]！"};
	["VIP12"] = --
		{"hongbaocard_4111_3222164606", "恭喜您达到[FFFE0D]剑侠尊享12[-]！"};
	["VIP15"] = --
		{"hongbaocard_4112_3222164606", "恭喜您达到[FFFE0D]剑侠尊享15[-]！"};
	["FactionNew"] = -- 门派新人王
		{"hongbaocard_4109_3222164606", "恭喜您获得[FFFE0D]门派新人王[-]！"};
	["FactionMonkey"] = -- 门派大师兄
		{"hongbaocard_4111_3222164606", "恭喜您当选[FFFE0D]门派大师兄[-]！"};
	["Honor6"] = -- 潜龙头衔
		{"hongbaocard_4109_3222164606", "恭喜您达到[FFFE0D]潜龙[-]头衔！"};
	["Honor7"] = -- 傲世头衔
		{"hongbaocard_4109_3222164606", "恭喜您达到[FFFE0D]傲世[-]头衔！。"};
	["Honor8"] = -- 倚天头衔
		{"hongbaocard_4110_3222164606", "恭喜您达到[FFFE0D]倚天[-]头衔！"};
	["Honor9"] = -- 至尊头衔
		{"hongbaocard_4110_3222164606", "恭喜您达到[FFFE0D]至尊[-]头衔！"};
	["Honor12"] = -- 武圣头衔
		{"hongbaocard_4111_3222164606", "恭喜您达到[FFFE0D]武圣[-]头衔！"};
	["Honor15"] = -- 无双头衔
		{"hongbaocard_4111_3222164606", "恭喜您达到[FFFE0D]无双[-]头衔！"};
	["Honor20"] = -- 传说头衔
		{"hongbaocard_4112_3222164606", "恭喜您达到[FFFE0D]传说[-]头衔！"};
	["Honor21"] = -- 神话头衔
		{"hongbaocard_4112_3222164606", "恭喜您达到[FFFE0D]神话[-]头衔！"};

-------------------新增------------------------------
	["WeekActive700"] =
		{"hongbaocard_4109_3222164606", "恭喜您[FFFE0D]连续一周[-]活跃度100！"};
	["KillEmperor"] =
		{"hongbaocard_4110_3222164606", "恭喜您[FFFE0D]击杀[-]了秦始皇！"};
	["KillFemaleEmperor"] =
		{"hongbaocard_4110_3222164606", "恭喜您[FFFE0D]击杀[-]了武则天！"};
	["InDifferBattleWin"] =
		{"hongbaocard_4110_3222164606", "恭喜您在心魔幻境获得[FFFE0D]优胜[-]！"};
	["FirstSSPartner"] =
		{"hongbaocard_4110_3222164606", "恭喜您获得首个[FFFE0D]地级同伴[-]！"};
	["Power100w"] =
		{"hongbaocard_4111_3222164606", "恭喜您首次战力达到[FFFE0D]100万[-]！"};
	["Power200w"] =
		{"hongbaocard_4112_3222164606", "恭喜您首次战力达到[FFFE0D]200万[-]！"};
	["1Friend20L"] =
		{"hongbaocard_4109_3222164606", "恭喜您首次与[FFFE0D]1名好友亲密度达20级[-]！"};
	["3Friend20L"] =
		{"hongbaocard_4110_3222164606", "恭喜您首次与[FFFE0D]3名好友亲密度达20级[-]！"};
	["FirstStudentEliteOut"] =
		{"hongbaocard_4109_3222164606", "恭喜您首个[FFFE0D]杰出徒弟[-]出师！"};
};


Sdk.Def.tbQQLuckyBagSetting = {
	["VIP6"] = --
		{126, 100, 5,
		 "恭喜您达到[FFFE0D]剑侠尊享6[-]！"};
	["VIP9"] = --
		{127, 300, 10,
		 "恭喜您达到[FFFE0D]剑侠尊享9[-]！"};
	["VIP12"] = --
		{128, 600, 10,
		 "恭喜您达到[FFFE0D]剑侠尊享12[-]！"};
	["VIP15"] = --
		{129, 1500, 15,
		 "恭喜您达到[FFFE0D]剑侠尊享15[-]！"};
	["FactionNew"] = -- 门派新人王
		{126, 100, 5,
		 "恭喜您获得[FFFE0D]门派新人王[-]！"};
	["FactionMonkey"] = -- 门派大师兄
		{128, 600, 10,
		 "恭喜您当选[FFFE0D]门派大师兄[-]！"};
	["Honor6"] = -- 潜龙头衔
		{126, 100, 5,
		 "恭喜您达到[FFFE0D]潜龙[-]头衔！"};
	["Honor7"] = -- 傲世头衔
		{126, 100, 5,
		 "恭喜您达到[FFFE0D]傲世[-]头衔！。"};
	["Honor8"] = -- 倚天头衔
		{127, 300, 10,
		 "恭喜您达到[FFFE0D]倚天[-]头衔！"};
	["Honor9"] = -- 至尊头衔
		{127, 300, 10,
		 "恭喜您达到[FFFE0D]至尊[-]头衔！"};
	["Honor12"] = -- 武圣头衔
		{128, 600, 10,
		 "恭喜您达到[FFFE0D]武圣[-]头衔！"};
	["Honor15"] = -- 无双头衔
		{128, 600, 10,
		 "恭喜您达到[FFFE0D]无双[-]头衔！"};
	["Honor20"] = -- 传说头衔
		{129, 1500, 15,
		 "恭喜您达到[FFFE0D]传说[-]头衔！"};
	["Honor21"] = -- 神话头衔
		{129, 1500, 15,
		 "恭喜您达到[FFFE0D]神话[-]头衔！"};

-------------------新增------------------------------
	["WeekActive700"] =
		{126, 100, 5,
		 "恭喜您[FFFE0D]连续一周[-]活跃度100！"};
	["KillEmperor"] =
		{127, 300, 10,
		 "恭喜您[FFFE0D]击杀[-]了秦始皇！"};
	["KillFemaleEmperor"] =
		{127, 300, 10,
		 "恭喜您[FFFE0D]击杀[-]了武则天！"};
	["InDifferBattleWin"] =
		{127, 300, 10,
		 "恭喜您在心魔幻境获得[FFFE0D]优胜[-]！"};
	["FirstSSPartner"] =
		{127, 300, 10,
		 "恭喜您获得首个[FFFE0D]地级同伴[-]！"};
	["Power100w"] =
		{128, 600, 10,
		 "恭喜您首次战力达到[FFFE0D]100万[-]！"};
	["Power200w"] =
		{129, 1500, 15,
		 "恭喜您首次战力达到[FFFE0D]200万[-]！"};
	["1Friend20L"] =
		{126, 100, 5,
		 "恭喜您首次与[FFFE0D]1名好友亲密度达20级[-]！"};
	["3Friend20L"] =
		{127, 300, 10,
		 "恭喜您首次与[FFFE0D]3名好友亲密度达20级[-]！"};
	["FirstStudentEliteOut"] =
		{126, 100, 5,
		 "恭喜您首个[FFFE0D]杰出徒弟[-]出师！"};
};

function Sdk:GetQQVipRewardState(pPlayer)
	local nLastDayRewardDay = pPlayer.GetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_VIP_DAY_REWARD);
	local nLastOpenRewardMonth = pPlayer.GetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_VIP_OPEN_REWARD);
	local nLastOpenMonth = pPlayer.GetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_VIP_OPEN_MONTH);
	local nLatestOpenVip = pPlayer.GetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_VIP_LATEST_OPEN_VIP);
	local nToday = Lib:GetLocalDay();
	local nThisMonth = Lib:GetLocalMonth();
	return nLastDayRewardDay < nToday, nLastOpenRewardMonth < nThisMonth and nLastOpenRewardMonth < nLastOpenMonth, nLatestOpenVip;
end

function Sdk:IsPhoneBinded(pPlayer)
	return pPlayer.GetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_BINDED_PHONE) ~= 0;
end

function Sdk:ShowPhoneBindRedPoint(pPlayer)
	if not version_tx then
		return false;
	end

	local nOrgMonth = pPlayer.GetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_BINDED_PHONE_TX);
	return pPlayer.IsUserValueValid() and nOrgMonth ~= Lib:GetLocalMonth();
end

function Sdk:GetFBInviteCount()
	local nToday = Lib:GetLocalDay();
	local nInviteDay = me.GetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_FB_INVITE_DAY);
	if nToday ~= nInviteDay then
		return 0;
	end

	local nCurCount = me.GetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_FB_INVITE_COUNT);
	return nCurCount;
end

function Sdk:SetQQVipRewardTime(pPlayer, bDayReward, bOpenReward)
	if bDayReward then
		local nToday = Lib:GetLocalDay();
		pPlayer.SetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_VIP_DAY_REWARD, nToday);
	end

	if bOpenReward then
		local nThisMonth = Lib:GetLocalMonth();
		pPlayer.SetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_VIP_OPEN_REWARD, nThisMonth);
		pPlayer.SetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_VIP_OPEN_MONTH, 0);
	end
end

function Sdk:XMIsFacebookClickAwardSend(pPlayer)
	local nFBClicked = pPlayer.GetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_XM_FB_CLICK_ED);
	return nFBClicked > 0;
end

function Sdk:XMISEvaluateAwardSend(pPlayer)
	local nEvaluated = pPlayer.GetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_XM_EVALUEATE_ED);
	return nEvaluated > 0;
end

function Sdk:IsQQAddFriendAvailable(pPlayer)
	return pPlayer.GetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_QQ_INVITE_DISABLE) == 0;
end

function Sdk:IsXinyuePlayer(pPlayer)
	local nXinyueLevel = pPlayer.GetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_XINYUE_LEVEL);
	return nXinyueLevel > 0;
end

function Sdk:IsQQInviteFriendActOn()
	local nNow = GetTime();

	for _, tbActInfo in ipairs(Sdk.Def.tbQQInviteFriendSetting) do
		if tbActInfo.nBegin < nNow and nNow < tbActInfo.nEnd then
			return true, tbActInfo.nVersion;
		end
	end

	return false, 0;
end

function Sdk:GetQQInviteFriendPlayerInfo(pPlayer)
	local bOpenAct, nVersion = Sdk:IsQQInviteFriendActOn();
	if not bOpenAct then
		return 0, 0;
	end

	local nMyVersion = pPlayer.GetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_QQ_FRIEND_INVITE_VERSION);
	if nMyVersion == nVersion then
		local nInvitedCount = pPlayer.GetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_QQ_FRIEND_INVITED_COUNT);
		local nAwardStep = pPlayer.GetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_QQ_FRIEND_INVITE_AWARDED);
		return nInvitedCount, nAwardStep;
	end

	if MODULE_GAMESERVER then
		pPlayer.SetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_QQ_FRIEND_INVITE_VERSION, nVersion);
		pPlayer.SetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_QQ_FRIEND_INVITED_COUNT, 0);
		pPlayer.SetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_QQ_FRIEND_INVITE_AWARDED, 0);
	end

	return 0, 0;
end

function Sdk:GetServerId(nServerId)
	if MODULE_GAMESERVER then
		nServerId = GetServerIdentity();
	else
		nServerId = Player.nServerIdentity or SERVER_ID;
	end

	if Sdk:IsTest() and Sdk:IsMsdk() then
		return nServerId + 50000;
	else
		return nServerId;
	end
end

function Sdk:GetPayUid(pPlayer)
	local nServerId = pPlayer.nOrgServerId;
	if nServerId > 0 and Sdk:IsTest() and Sdk:IsMsdk() then
		nServerId = nServerId + 50000;
	end

	if nServerId <= 0 then
		me.CenterMsg("获取交易信息异常，请稍后再试");
		Log("Sdk:GetPayUid Error", pPlayer.dwID, pPlayer.szName, nServerId, pPlayer.szAccount);
		assert(false);
		return;
	end
	return string.format("%d_%d", nServerId, pPlayer.dwID);
end

function Sdk:IsTest()
	return SDK_TEST;
end

function Sdk:IsXgSdk()
	return IS_XG_SDK;
end

function Sdk:IsMsdk()
	return not IS_XG_SDK;
end

function Sdk:IsEfunHKTW()
	return version_hk or version_tw;
end

function Sdk:HasEfunRank()
	return version_tw or version_hk or version_xm;
end

local tbMsdkTypeInfo = {
	nOsType       = "number",
	nPlatform     = "number",
	szOpenId      = "string",
	szOpenKey     = "string",
	szPayOpenKey  = "string",
	szPayToken    = "string",
	szSessionId   = "string",
	szSessionType = "string",
	szPf          = "string",
	szPfKey       = "string",
}

function Sdk:CheckMsdkTypeInfo(tbMsdkInfo)
	if type(tbMsdkInfo) ~= "table" then
		return false;
	end

	for szKey, szType in pairs(tbMsdkTypeInfo) do
		if type(tbMsdkInfo[szKey]) ~= szType then
			Log("[Error]Sdk:CheckMsdkTypeInfo", szKey, szType, type(tbMsdkInfo[szKey]));
			return false;
		end
	end
	return true;
end

local tbMainId2ZoneName = {
	[10000] = "卓微";
	[20000] = "卓Q";
	[30000] = "果微";
	[40000] = "果Q";
	[50000] = "游客";
}

function Sdk:GetServerDesc(nServerId, bSimple)
	local nSubServerId = nServerId % 10000;
	local nMainId = nServerId - nSubServerId;
	if not version_tx or bSimple then
		return string.format("%d服", nSubServerId);
	end

	return string.format("%s%d服", tbMainId2ZoneName[nMainId] or "null", nSubServerId), tbMainId2ZoneName[nMainId];
end

function Sdk:GetAreaIdByPlatform(nPlatform)
	if nPlatform == Sdk.ePlatform_Weixin then
		return 1;
	elseif nPlatform == Sdk.ePlatform_QQ then
		return 2;
	elseif nPlatform == Sdk.ePlatform_Guest then
		return 3;
	end
	return 0;
end


local tbAreaMap = {
	[1] = 1; -- 卓微
	[2] = 2; -- 卓Q
	[3] = 1; -- 果微
	[4] = 2; -- 果Q
	[5] = 3; -- 游客
}

function Sdk:GetAreaIdByServerId(nServerId)
	local nMain = math.floor(nServerId / 10000);
	return tbAreaMap[nMain] or 0;
end