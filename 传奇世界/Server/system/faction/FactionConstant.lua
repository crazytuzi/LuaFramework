--FactionConstant.lua
--帮会职务
FACTION_POSITION =
{
	Member				= 1,	--帮众
	Excellent			= 2,	--精英
	AssociateLeader		= 3,	--副帮主
	Leader				= 4,	--帮主
}
FACTION_ADD_FIRE_TIMES = 1

FACTION_BUFFF =
{
	[1]			= 17,
	[2]			= 25,
	[3]			= 26,
	[4]			= 27,
	[5]			= 28,
	[6]			= 328,
	[7]			= 329,
	[8]			= 330,
	[9]			= 331,
}

FACTION_POS_2_STR = {"会员", "精英", "副会长", "会长"}

EMEMY_WORD = "君子报仇，十年不晚！"

--帮会功能
FACTION_DROIT =
{
	EditComment			= 1,	--编辑公告
	Appoint				= 2,	--任命职务
	TakeInMember		= 3,	--招收帮众
	RemoveMember		= 4,	--踢出帮会
	FactionLvUp			= 5,	--帮会升级
	ApplyBattle			= 6,	--帮战申请
	SabukBattle			= 7,	--沙巴克报名
}
local facLvlData = require("data.FactionLvl")

CREATE_HORNID = tonumber(facLvlData[1].syhj) --号角对应物品ID
CREATE_HORN_COUNT = tonumber(facLvlData[1].syhj_1)	--创建帮会需要的号角数量 
CREATE_FACTION_INGOT = tonumber(facLvlData[1].syyb) --创建帮会所需元宝
CREATE_FACTION_MONEY = tonumber(facLvlData[1].syjb) --创建帮会所需金币
CONTRIBUTION_DATA = unserialize(facLvlData[1].contriScale)	--祈福相关数据

local droitData = require("data.FactionDroit")
FACTION_POS_DROIT = {}	--帮会职务对应功能
table.insert(FACTION_POS_DROIT, droitData[2].FACTION_POSITION, droitData[2].FACTION_DROIT and unserialize(droitData[2].FACTION_DROIT) or {})
table.insert(FACTION_POS_DROIT, droitData[3].FACTION_POSITION, droitData[3].FACTION_DROIT and unserialize(droitData[3].FACTION_DROIT) or {})
table.insert(FACTION_POS_DROIT, droitData[4].FACTION_POSITION, droitData[4].FACTION_DROIT and unserialize(droitData[4].FACTION_DROIT) or {})
table.insert(FACTION_POS_DROIT, droitData[5].FACTION_POSITION, droitData[5].FACTION_DROIT and unserialize(droitData[5].FACTION_DROIT) or {})
	

CREATE_FACTION_LEVEL = 1 --创建帮会所需等级
--CREATE_FACTION_MONEY = 300000 --创建帮会所需金币
FACTION_NAME_LENTH = 6 --帮会名字长度限制
FACTION_MAX_APPLY_COUNT = 5	--帮会最多申请数量
FACTION_MAX_BE_APPLY_COUNT = 30	--帮会最多可接受的申请数量
ASSLEADER_NUM = 1 --副帮主数量
FACTION_COMMENT_LEN = 160	--帮会公告长度
UPDATE_HOUR = 8	--数据更新时间点
MAX_MSG_COUNT = 50	--日志记录最大条数
FACTION_EVENT_MAX_COUNT = 50	--军机处记录最大条数
EXIT_FACTION_BUFFID = 18
EXIT_FACTION_SPECIAL = 16	--不能参加帮会活动的buff效果
FACTION_AREA_MAP_ID = 6017	--帮会据点地图ID
FACTION_AREA_NEED_LEVEL = 3	--帮会据点等级要求

--创建帮会的模式
CREATE_MODE = 
{
	Force = 0,	--强制创建
	HornCreate = 1,	--号角
	MoneyCreate =2,	--元宝
}

--捐献类型
FACTION_CONTRI_TYPE = 
{
	MONEY = 1,	--捐献金币
	INGOT = 2,	--捐献元宝
	MATERIAL = 3,	--道具
}

--帮会配置数据类型
FACTION_DATA_TYPE = 
{
	FACTION = 1,	--帮会
	BANNER = 2,		--旗帜
	STORE = 3,		--商店
}

--帮会升级类型
FACTION_UPLVL_TYPE =
{
	FacLevel = 1,	--帮会等级
	StoreLevel = 2,	--帮会商店等级
	BannerLevel = 3,	--帮会旗帜等级
}

--获取贡献类型
FACTION_GETCONTRI_TYPE = 
{
	Instant = 1,	--今日贡献
	Total = 2,	--累计贡献
}

ONEDAY_SECOND = 24*3600 --一天的秒数
FACTION_RANK_TIME = 1800 --帮会排名更新时间
FACTION_STATUE_ID = 1081	--魔神雕像ID
FACTION_STATUE_MAX_RD = 20	--魔神雕像捐献记录最大条数
FACTION_STATUE_SCALE = 50	--魔神雕像捐献帮贡比例


---------------------------error code---------------------------
FACERR_NEED_LEVEL = -1 --创建帮会等级不够
FACERR_NO_HORN = -2 --没有号角
FACERR_NO_ENOUGH_INGOT = -3 --没有足够的元宝创建帮会
FACERR_FACNAMETOOLONG = -4 --帮会名字过长
FACERR_FACTIONHASEXIST = -5 --帮会名字已存在
FACERR_HAS_FACTION = -6	--玩家已经有帮会了
FACERR_HAS_APPLY = -7	--已经申请过了
FACERR_MAX_APPLY = -8	--达到最大申请个数	
FACERR_NOT_APPLY = -9	--没有申请过
FACERR_HAS_NO_FACTION = -10 --没有帮会
--FACERR_HAS_OFFLINE	= -13	--角色已下线
FACERR_MAX_MEMBER	= -11	--帮会已经达到最大人数 无参数
FACERR_NO_DROIT		= -12	--没有权限 无参数
FACERR_NO_CONTRI_MONEY = -13	--没有足够的金币捐献 无参数
FACERR_NO_CONTRI_INGOT = -14	--没有足够的元宝捐献 无参数
FACERR_MAX_LEVEL = -15	--帮会达到最大等级 无参数
FACERR_NO_ENOUGH_WEALTH = -16	--没有足够的帮会财富进行升级 无参数
FACERR_LEVEL_TOOBIG = -17	--无法超过帮会等级 无参数 珍宝阁升级
FACERR_ISIN_APPLY = -18	--是否在申请列表里面
FACERR_APPLY_REFUSED = -19	--加入帮会申请被拒绝 参数两个 拒绝操作者名字 帮会名字 
FACERR_OUT_OF_DATE = -20	--操作已过期
FACERR_NO_THIS_MEMBER = -21	--帮会没有这个成员
FACERR_ASSLEADER_IS_MAX = -22	--副帮主数量已经达到最大值
FACERR_LEADER_LEAVE	= -23	--帮主不能退出帮会
FACERR_NO_ENOUGH_MONEY = -24	--用号角创建帮会情况下没有足够的金币创建帮会
FACERR_HAS_EXIT_BUFF = -25	--还有退帮BUFF 不能参加帮会活动
FACERR_ILLEGAL_NAME = -26	--帮会名字有非法字符，不能包含空格和&符号
FACERR_FACTION_MAX_APPLY = -27	--帮会申请人数已经达到最大人数,不能在申请了，帮会最多只能有25个人申请
FACERR_BANNER_TIME	= -28	--帮会战期间不能进行帮会职位变更
FACERR_NOT_ALLOW_STATUE = -29 --沙巴克开战期间无法操作
FACERR_STATUE_NOT_ENOUGH = -30 --魔神雕像数量不足
FACERR_ADD_STATUE_SUCCESS = -31 --魔神雕像捐献成功
FACERR_LEVEL2_TOOBIG = -32	--无法超过帮会等级 无参数 旗帜升级
FACERR_APPLY_OUT_TIME = -33	--帮会申请过期
FACERR_BEINVITE_OFFLINE = -34	--被邀请人不在线
FACERR_BEINVITE_ONLY_LEADER = -35	--只有会长和副会长有邀请权限
FACERR_BEINVITE_ALREADY_HAS_FACTION = -36	--受邀人已有公会
FACERR_ALREADY_HAS_FACTION = -37	--已有公会不能接受邀请
FACERR_INVITE_FACTION_CHANGE = -38	--邀请人公会已改变
FACERR_INVITE_FACTION_NOT_EXIST = -39	--公会不存在
FACERR_SHA_TIME	= -40	--沙城战不能进行帮会职位变更
FACERR_INVITE_HAS_BUFF_CANNOT_BEINVITE = -41	--受邀人有不能入会的BUFF

FACTION_DART_NOJOIN = -42	--你没有加入行会，无法开启物资护送
FACTION_DART_NOMANOR = -43	--你所在行会没有领地，无法开启物资护送
FACTION_DART_LEADER = -44	--只有行会会长和副会长可以开启物资护送
FACTION_DART_NOFACTION_NOPICKUP = -45	--你没有加入行会，无法拾取该物品
FACTION_DART_NOT_TIME = -46	--时间未到，活动暂未开启
FACTION_DART_ALREADY_JOIN = -47	 -- 你所在行会今日已参与过物资运送，请明日再来
FACTION_DART_RUNING			= -48 --你所在行会正在参与物资运送
FACTION_DART_NO_GOODS		= -49 --你没有可上交的物资
FACTION_DART_NO_PICK 		= -50 --你已携带物资，无法捡取物资
FACTION_DART_NO_GIVEN		= -51 --你已携带物资，无法开启物资运送
FACTION_DART_NO_RIDE		= -52 -- 该状态下不可骑乘
FACTION_DART_RELEASE		= -53 --活动时间已到，物资上交失败，物资消失

FACTION_PRAY_SUC		= -59 --祈福成功，经验+xx,贡献+xx
FACTION_PRAY_CAN_NOT_IN_AREA	= -60 --叛逃者无法进入驻地
FACTION_PRAY_LEVEL_NOT_IN_AREA	= -61 --行会等级不足，无法进入驻地
FACERR_COMMENT_TOOLONG		= -64 --行会宣言太长

----行会语音错误码
FACTION_VOICE_CREATE_ROOM_ERROR = -100 --实时语音创建房间失败
FACTION_VOICE_JOIN_ROOM_NOT_EXIST = -101 --实时语音加入房间时房间不存在
FACTION_VOICE_JOIN_ROOM_FACTION_ID_NOT_SAME = -102 --实时语音加入房间回调时公会ID改变
FACTION_VOICE_JOIN_ROOM_FAILED = -103 --实时语音加入房间失败
FACTION_VOICE_EXIT_ROOM_NOT_EXIST = -104 --退出房间时房间不存在

FACTION_SET_COMMAND_PERMISSION_ERROR = -105 --设定指挥时权限错误
FACTION_SET_COMMAND_DBID_ERROR = -106 --设定的指挥者不在本帮会
FACTION_VOICE_CREATE_ROOM_PERMISSION_ERROR = -107 --只有指挥者能创建和关闭房间
FACTION_DART_END_DELETE_SHOW_ITEM = -108 -- 活动时间结束，未上交的物资将会消失
FACTION_DART_GIVE_GOOD		= -109 --物资上交成功，奖励通过有ian发放

FACTION_OPENID_BIND_SUCESS = -110		--绑定QQ群成功
FACTION_OPENID_BIND_FACTIONID_ERROR = -111	--非法行会 绑定QQ群
FACTION_OPENID_BIND_PERMISSION_ERROR = -112	--只有会长才能绑定QQ群

FACTION_CREATE_SUCCESS = 1	--创建帮会成功
FACTION_SEND_APPLYSUCCEED = 2	--申请加入帮会成功
FACTION_CANCEL_APPLYSUCCEED = 3	--取消帮会申请成功
FACTION_CONTRI_MONEY = 4	--捐献金钱成功
FACTION_CONTRI_INGOT = 5	--捐献元宝成功
FACTION_UPLEVEL = 6	--升级帮会成功 参数一个 等级
FACTION_UPSTORE = 7 --升级商店成功	参数一个 等级
FACTION_UPBANNER = 8	--升级旗帜成功 参数一个 等级
FACTION_ADD_NEWMEMBER = 9	--新成员加入 参数一个 加入者名字
FACTION_JOIN_SUCCESS = 10	--加入帮会成功提示
--FACTION_REFUSE_APPLY = 11	--拒绝加入帮会申请 参数一个 被拒绝者的名字
--FACTION_REFUSE_ALL = 12	--拒绝所有的加入帮会申请
--FACTION_AGREE_ALL = 13	--同意所有的加入帮会申请
FACTION_APPOINT_SUCCESS = 11	--任命职务成功 参数三个 操作者名字 被操作者名字 被操作者被任命的职务
FACTION_LEAVE_FACTION = 12	--退出帮会成功 参数一个 离开者名字
FACTION_LEAVE_FACTION_RET = 13	--退出帮会成功,给离开者的消息
FACTION_REMOVE_MEMBER_RET = 14	--踢出帮会成功 参数一个 被踢出者名字
FACTION_EDIT_COMMENT = 15	--修改帮会公告成功
FACTION_DISBAND_FACTION = 16 --解散帮会

FACTION_EVENT_UP_FACTION = 17 --xx帮会升级到xx级
FACTION_EVENT_MANOR_WIN = 18 --xx帮会占领XX
FACTION_EVENT_SHA_WIN = 19 --xx帮会占领沙城
FACTION_EVENT_INVADE = 20 --xx行会入侵xx行会
FACTION_EVENT_UNION = 21 --xx行会结盟xx行会
FACTION_EVENT_HOSTILITY = 22 --xx行会宣战xx行会
FACTION_EVENT_GET_GOODS = 23 --xx行会物资获得xx行会的物资
----------------------------------------------------------------行会外交----------------------------------------------------------------
--外交状态
SocialState = 
{
	Neutral = 0,		--中立
	ApplyUnion = 1,		--申请联盟
	Union = 2,		--联盟
	Hostility = 3,		--敌对
}

--外交操作
SocialOperator = 
{	
	None = 0,
	ApplyUnion = 1,		--申请联盟
	AcceptUnion = 2,	--同意联盟
	RefuseUnion = 3,	--拒绝联盟
	StopUnion = 4,		--终止联盟
	ApplyHostility = 5,	--宣战
	ServerSet = 6,		--服务器设置
}

SocialOperatorCoolDown = 24*60*60	--操作冷却时间 单位(:秒)
HostilityLastTime = 2*60*60		--敌对状态持续时间 单位(:秒)
ApplyUnionLastTime = 24*60*60		--申请联盟状态持续时间 单位(:秒)

ApplyUnionItemID = 30009
ApplyUnionItemNum = 1
ApplyHostilityItemID = 30008
ApplyHostilityItemNum = 1
SocialOperatorItemLogSource = 200	--行会外交道具日志source
SocialItemEmail1	= 55		--行会外交道具回退邮件ID
SocialItemEmail2	= 56		--行会外交道具回退邮件ID

--外交操作返回错误码
SocialOperator_Success		= 0	--外交操作成功
SocialOperatorError_InvalidRSID	= 1	--非法的角色ID
SocialOperatorError_InvalidFID	= 2	--非法的行会ID
SocialOperatorError_NoRight	= 3	--权限不够
ApplyUnionError_State		= 4	--申请联盟时 非中立状态	收取的道具将以邮件的形式退回		
ApplyUnionError_NoItem		= 5	--申请联盟时 缺少道具
AcceptOrRefuseUnionError_State  = 6	--接受/拒绝(联盟)时 非申请联盟状态
StopUnionError_State		= 7	--终止联盟时 非联盟状态
ApplyHostilityError_State	= 8	--宣战时 非中立状态 收取的道具将以邮件的形式退回
ApplyHostilityError_NoItem	= 9	--宣战时 缺少道具
SocialOperatorError_InCD	= 10	--外交操作冷却中
SocialOperatorError_Invalid	= 11	--外交操作非法
SocialOperatorError_InBusy	= 12	--服务器繁忙 稍后再来
----------------------------------------------------------------行会祈福----------------------------------------------------------------
--祈福类型
FactionPrayType = 
{	
	Free = 1,	--免费
	Ingot = 2,	--元宝
}

--祈福消耗
--消耗类型
ConsumeType = 
{
	None = 0,
	MONEY = 1,	--金币(非绑定)
	INGOT = 2,	--元宝(非绑定)
}



FactionPrayYBTest = false				--元宝测试 改消耗绑定元宝
FactionPrayLogSource = 201				--行会祈福日志source
FactionPrayMsgID = 5					--行会祈福行会见闻ID

--祈福操作返回错误码
FactionPray_Success		= 0	--祈福操作成功
FactionPrayError_InvalidRSID	= 1	--非法的角色ID
FactionPrayError_NoFaction	= 2	--没有行会
FactionPray_InvalidType		= 3	--祈福类型非法
FactionPrayError_NoTimes	= 4	--当天次数不够
FactionPrayError_NoMoney	= 5	--金币不够
FactionPrayError_NoIngot	= 6	--元宝不够
FactionPrayError_InBusy		= 7	--服务器繁忙 稍后再来
FactionPrayError_LeaveBuff  = 8 --您拥有“离会者”状态，暂时不能参与该活动
FactionPrayError_NoBindIngot	= 9	--绑定元宝不够
----------------------------------------------------------------行会公共任务----------------------------------------------------------------
--数据库中字符串数据保存的格式
DatasDBFmt = 
{
	protobuf = 1,		--以protobuf序列化保存
	string   = 2,		--以字符串进行保存
}

FACTIONTASK_DBDATAS_FMT = DatasDBFmt.string			--行会任务数据在DB中的存储格式
FACTIONTASK_DAILYREFRESH_HOUR = 0				--行会任务每天的刷新时间
FACTIONTASK_DAILYREFRESH_NEXTDAY = 24*60*60
FACTIONTASK_ALLTASK_ID = 0					--获取所有行会任务信息标志
FactionTaskRewardEmail1	= 63					--行会任务完成发奖通知
FACTIONTASK_DAILYREWARD_HOUR = 22				--行会任务每天定时发奖时间

--行会公共任务领取奖励错误码
FactionTaskReward_Success		= 0	--领取成功
FactionTaskReward_Rewarded		= -1	--已经领取过
FactionTaskReward_InvalidTaskID		= -2	--非法的任务ID
FactionTaskReward_TaskNotEnd		= -3	--任务还未完成
FactionTaskReward_InBusy		= -4	--服务器繁忙 稍后再来
FactionTaskReward_InvalidFactionID	= -5	--非法的行会ID
FactionTaskReward_InvalidRoleSID	= -6	--非法的角色ID

----------------------------------------------------------------------------
--------------------------   行会运镖数据  ---------------------------------

FACTION_DART_ITEM_MIN_ID  = 6200052--行会物资物品ID
FACTION_DART_ITEM_MAX_ID  = 6200058--行会物资物品ID
FACTION_DART_MAP_ID        = 4100        --行会运跃马平原地图ID
FACTION_DART_SPACE_TIME		= 30     -- 跑马灯间隔时间
FACTION_DART_RELEASE_ITEM_TIME = 90		--行会物资掉落自动释放时间
FACTION_DART_OPEN_TIME 		='*,*,*,*,12:00:00-18:30:00'

--行会镖车错误提示

--[[
FACTION_DART_SIGLE_EMAIL_ID = 68 --尊贵的勇士：\n由于你在本次物资争夺中的英勇表现，为你所在的行会赢得了荣誉。特给予你如下奖励
FACTION_DART_ALL_EMAIL_ID = 69 --尊贵的勇士：\n由于你在本次物资争夺中贡献了自己的力量，帮助了你所在的行会赢得了荣誉。特给予你如下奖励

FACTION_DART_LEADER_EMAIL_ID = 70 --尊贵的勇士：\n本次运送物资活动已结束。系统已发放XXXX点行会财富奖励至你所在行会。
]]


FACTION_DART_GIVE_UP_EMAIL_ID = 68  -- 上交奖励
FACTION_DART_PART_IN_EMAIL_ID = 69  -- 参与奖励
FACTION_DART_FAQI_EMAIL_ID = 70  -- 发起奖励

--行会活动邮件通知
FactionNotifyEmailSource = 242
FactionHD = {
	GOU_HUO = 1,			--行会篝火
	INVADE = 2,			--山贼入侵
	YUNBIAO = 3,			--行会运镖
	FACTION_BOSS_OPEN = 4,		--行会BOSS开启
	FACTION_BOSS_SETTIME = 5,	--行会BOSS修改
}

FactionNotifyEmail = 
{
	[FactionHD.GOU_HUO] = 90,
	[FactionHD.INVADE] = 91,
	[FactionHD.YUNBIAO] = 92,
	[FactionHD.FACTION_BOSS_OPEN] = 93,
	[FactionHD.FACTION_BOSS_SETTIME] = 94,
}

