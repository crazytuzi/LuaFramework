_G.Const=_G.Const or {}

local lConst=_G.Const
-- 游戏名称常量
lConst.kAgentGameNameJQXS=2 --惊奇先生
lConst.kAgentGameNameXM_VN=3 --降魔_越南
lConst.kAgentGameNameFM=11 --伏魔天师令

-- socket
lConst.kSocketConnectSuccess=1
lConst.kSocketConnectFaild=2

-- 资源加载 常量
lConst.kResourceProgress=0
lConst.kResourceComplete=1
lConst.kResourceFailed=2

-- 资源配置 常量
lConst.kResTypeZIP=1
lConst.kResTypeDEV=2
lConst.kResTypeAPP=3

-- 网络配置 常量
lConst.kNetworkTypeIP=1
lConst.kNetworkTypeRELEARE=2
lConst.kNetworkTypeDOMAIN=3

-- 语言配置 常量
lConst.kLangCodeCN=86
lConst.kLangCodeVN=84

-- 平台 常量
lConst.kPlatformIOS=0
lConst.kPlatformANDROID=1

-- 渠道配置信息 常量
lConst.sKeyChannelName="KEY_CHANNEL_NAME"
lConst.sKeyCID217="KEY_CID_w_217"
lConst.sKeyPrivatekey217="KEY_PRIVATEKEY_W_217"
lConst.sKeyAppId="KEY_APPID"
lConst.sKeyAppKey="KEY_APPID"

-- SDK 常量
-- SDK CODE
lConst.AGENT_SDK_CODE_APP_IOS = 888
lConst.AGENT_SDK_CODE_APP_IOS_GC = 889
lConst.AGENT_SDK_CODE_TEST    = 158
lConst.AGENT_SDK_CODE_ANYSDK  = 911
lConst.AGENT_SDK_CODE_QQ      = 900
lConst.AGENT_SDK_CODE_IFENG   = 166
lConst.AGENT_SDK_CODE_IFENG_IOS = 168
lConst.AGENT_SDK_CODE_ZHUOYI  = 1243
lConst.AGENT_SDK_CODE_KUAIFA  = 1203
lConst.AGENT_SDK_CODE_YIJIE   = 20010
lConst.AGENT_SDK_CODE_UC   = 603
lConst.AGENT_SDK_CODE_19YOU   = 10019
lConst.AGENT_SDK_CODE_YUHUI   = 10201
lConst.AGENT_SDK_CODE_KUNDA   = 10301

-- SDK TYPE
lConst.SDK_TYPE_INIT_FAILD=0
lConst.SDK_TYPE_INIT_SUCCESS=1
lConst.SDK_TYPE_LOGIN_FAILD=2
lConst.SDK_TYPE_LOGIN_CANCEL=3
lConst.SDK_TYPE_LOGIN_SUCCESS=4
lConst.SDK_TYPE_LOGOUT_FAILD=5
lConst.SDK_TYPE_LOGOUT_SUCCESS=6
lConst.SDK_TYPE_RECHARGE_FAILD=7
lConst.SDK_TYPE_RECHARGE_SUCCESS=8
lConst.SDK_TYPE_CHUANGE_ACCOUNT_FAILD=9
lConst.SDK_TYPE_CHUANGE_ACCOUNT_SUCCESS=10

lConst.SDK_COMMAND_LEVEL=1
lConst.SDK_COMMAND_TASK=2
lConst.SDK_COMMAND_COPY=3

-- CWebView
lConst.sWebViewStartLoading="kStartLoading"
lConst.sWebViewFinishLoading="kFinishLoading"
lConst.sWebViewFailLoading="kFailLoading"

-- StagePoolType
lConst.StagePoolTypeSpine=1
lConst.StagePoolTypeGaf=2
lConst.StagePoolTypeNode=3

-- 聊天
lConst.kChatTypeGood=1
lConst.kChatTypeFace=2
lConst.kChatTypeWord=3
lConst.kChatTypeVip=4
lConst.kChatTypeChanel=5
lConst.kChatTypeVoice=6

-- 点击类型
lConst.kChatTouchName=1
lConst.kChatTouchGood=2
lConst.kChatTouchTeam=3
lConst.kChatTouchClan=4
lConst.kChatTouchVoice=5

lConst.kChatVoiceColorPlaySpr={r=155,g=255,b=155}
lConst.kChatVoiceColorEndSpr={r=155,g=155,b=155}
lConst.kChatVoiceColorPlayLab={r=166,g=125,b=61}
lConst.kChatVoiceColorEndLab={r=0,g=0,b=0}

-- 聊天数据类型
lConst.kChatDataTypeSL=1 --私聊
lConst.kChatDataTypeWP=2 --展示物品
lConst.kChatDataTypeTeam=3 --组队界面打开聊天

lConst.kChatChannelColor={
	[lConst.CONST_CHAT_ALL]=lConst.CONST_COLOR_WHITE,
	[lConst.CONST_CHAT_WORLD]=lConst.CONST_COLOR_ORANGE,
	[lConst.CONST_CHAT_CLAN]=lConst.CONST_COLOR_GREEN,
	[lConst.CONST_CHAT_TEAM]=lConst.CONST_COLOR_CYANBLUE,
	[lConst.CONST_CHAT_PM]=lConst.CONST_COLOR_VIOLET,
	[lConst.CONST_CHAT_SYSTEM]=lConst.CONST_COLOR_RED
}

-- 装备位置
lConst.kEquipPosByType={
	[lConst.CONST_EQUIP_ARMOR]=1,
	[lConst.CONST_EQUIP_CLOAK]=2,
	[lConst.CONST_EQUIP_SHOE]=3,
    [lConst.CONST_EQUIP_NECKLACE]=4,
    [lConst.CONST_EQUIP_WEAPON]=5,
	[lConst.CONST_EQUIP_RING]=6,
}

-- 主界面ICON
lConst.kMainIconEmal=1001
lConst.kMainIconTeam=1002
lConst.kMainIconSlave=1003
lConst.kMainIconArena=1004
lConst.kMainIconPK=1005
lConst.kMainIconBoss=1006

-- 主界面ICON位置
lConst.kMainIconPos1=1 --右下角-右1
lConst.kMainIconPos2=2 --右下角-左1
lConst.kMainIconPos3=3 --右下角-右2
lConst.kMainIconPos4=4 --右下角-左2
lConst.kMainIconPos5=5 --右上角
lConst.kMainIconPos6=6 --左边

lConst.kMainIconSize=cc.size(90,72)

-- 按钮点击效果类型
lConst.kCButtonTouchTypeScale=0
lConst.kCButtonTouchTypeGray=1

-- 重启游戏类型
lConst.kResetGameTypeChuangAccount=1
lConst.kResetGameTypeChuangServer=2
lConst.kResetGameTypeChuangRole=3


