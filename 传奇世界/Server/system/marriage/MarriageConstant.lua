--MarriageConstant.lua
--/*-----------------------------------------------------------------
 --* Module:  MarriageConstant.lua
 --* Author:  goddard
 --* Modified: 2016年8月15日
 --* Purpose: 婚姻常量定义
 -------------------------------------------------------------------*/

--结婚最低等级
MARRIAGE_MIN_LEVEL = 48

 --婚姻状态
MarriageStatus = {
	UnTour	= 1, --未开启巡礼
	Touring	= 2, --巡礼中
	Married	= 3, --已婚状态
	CoolingPeriod = 4,--冷静期
}

 --举办婚礼状态
WeddingStatus = {
	UnWedding = 0, --未开启婚礼
	Wedding	= 1, --举办婚礼中
	Wedded	= 2, --举办过婚礼
}

MARRIAGE_TIMER_PERIOD = 1000

 --巡礼任务采集浇灌类型
MarriageTourOpt = {
	CollectFlowersAir = 2,		--采集飞舞之花
	CollectWellWater = 3,			--采集井水
	CollectHotFlowerMale = 5,		--浇灌炙热之花(男)
	CollectHotFlowerFemale = 6,		--浇灌炙热之花(女)
	CollectFlowersRock = 7,		--采集磐石之花
}

--巡礼任务采集浇灌阶段
MarriageTourTaskStep = {
	Start = 1,		--开始
	Finish = 2,		--完成
}

--巡礼任务阶段
MarriageTaskStep = {
	UnFinish = 0,	--未完成所有任务
	AllFinish = 1,	--已完成所有任务
}

--错误码
MarriageErrorCode = {
--巡礼相关
	ErrorReqTour = 1,		--请求巡礼错误
	HasTourErr = 2,			--请求巡礼时, 双方至少有一方还有巡礼或者婚姻状态
	StartTourErr = 3,		--请求巡礼时, 已经开启巡礼
	TourGenderErr = 4,		--请求巡礼时, 性别有问题
	TourLevelErr = 5,		--请求巡礼时, 等级有问题
	TourTeamErr = 6,		--请求巡礼时, 组队有问题
	TourNotSameScreen = 7,	--请求巡礼时, 不在同屏
	TourNotTeam = 8,		--请求巡礼时, 没有组队
	TourRecvTaskNoMore = 9,	--接收巡礼任务时, 任务已经全部完成

--婚礼相关
	ReqWeddingUnMarried = 30,		--用户请求开启婚礼, 不处于结婚状态
	ReqWeddingHasOpened = 31,		--用户请求开启婚礼, 已开启过婚礼
	ReqWeddingIngotFailed = 32,		--用户请求开启婚礼, 元宝扣除失败
	ReqWeddingBagNotEnough = 33,	--用户请求开启婚礼, 包裹不足
	ReqWeddingNoVenue = 34,			--用户请求开启婚礼, 地图使用完, 请等待一段时间

--婚礼会场相关
	WeddingVenueMaxPlayer = 60,		--用户请求进入婚礼会场，会场人数已达上限
	WeddingVenueLevelNotEnough = 61,	--用户请求进入婚礼会场，等级不够
	WeddingVenueKickOut = 62,		--用户请求进入婚礼会场，被踢出的用户不能再次进入
	WeddingVenueInvitationSpouse = 63,		--用户请求进入婚礼会场，夫妻不能通过请柬进入
	WeddingVenueNoStartWeddingVenue =  64,	--用户请求进入婚礼会场，未开启婚礼会场
	WeddingVenueWeddingVenueFini = 65,		--用户请求进入婚礼会场，婚礼已结束
	WeddingVenueWeddingGuestListNoStart = 66, --夫妻请求宾客列表，未开启婚礼
	WeddingVenueWeddingGuestListFini = 67, --夫妻请求宾客列表，婚礼已结束
	WeddingVenueWeddingSendBonusType = 68, --宾客请求送红包, 类型有错
	WeddingVenueWeddingSendBonusNoStart = 69, --宾客请求送红包, 婚礼未开启
	WeddingVenueWeddingSendBonusFini = 70, --宾客请求送红包, 婚礼已结束
	WeddingVenueWeddingSendBonusNotIn = 71, --宾客请求送红包, 宾客不在婚礼会场
	WeddingVenueWeddingSendBonusNotEnough = 72, --宾客请求送红包, 宾客元宝不足
	WeddingVenueWeddingSendBonusPay = 73, --宾客请求送红包, 扣除宾客元宝失败
	WeddingVenueWeddingSendBonusSended = 74, --宾客请求送红包, 已经送过
	WeddingVenueWeddingKickoutFini = 75, --夫妻请求踢出嘉宾, 婚礼已结束
	WeddingVenueWeddingKickoutNoStart = 76, --夫妻请求踢出嘉宾, 婚礼未开始
	WeddingVenueWeddingKickoutNotIn = 77, --夫妻请求踢出嘉宾, 嘉宾不在婚礼会场
	WeddingVenueWeddingAmbienceFini = 78, --夫妻请求气氛功能, 婚礼已结束
	WeddingVenueWeddingAmbienceNoStart = 79, --夫妻请求气氛功能, 婚礼未开始
	WeddingVenuePlayNoSpouse = 80,		--夫妻请求开启玩法功能, 不是夫妻双方
	WeddingVenuePlayFini = 81,		--夫妻请求开启玩法功能, 婚礼已结束
	WeddingVenuePlayNoStart = 82,		--夫妻请求开启玩法功能, 婚礼未开启
	WeddingVenuePlayStatus = 83,		--夫妻请求开启玩法功能, 当前处于不可开启状态,另外一个玩法在开启或者当前活动不处于未开启状态(可能开启或者冷却中)
	WeddingVenuePlayNoPlayer = 84,		--夫妻请求开启玩法功能, 当前会场没有嘉宾在场不能开启
	WeddingVenueWeddingGuestListNoSpouse = 85, --请求宾客列表，不是夫妻双方
	WeddingVenueWeddingBonusInfoNoStart = 86, --请求红包信息, 婚礼未开启
	WeddingVenueWeddingBonusInfoFini = 87, --请求红包信息, 婚礼已结束
	WeddingVenueWeddingBonusInfoSpouse = 88, --请求红包信息, 夫妻双方不能送红包没有红包信息
	WeddingVenueWeddingBonusInfoNoVenue = 89, --请求红包信息, 不在婚礼会场
	WeddingVenueWeddingDrinkNoVenue = 90,	--宾客请求喝酒, 不在婚礼会场
	WeddingVenueWeddingDrinkPlayNoStart = 91,	--宾客请求喝酒, 拼酒玩法未开始
	WeddingVenueWeddingDrinkStatus = 92,	--宾客请求喝酒, 宾客当前处于冷却中状态

--婚车相关
	WeddingCarOnFini = 300,			--夫妻请求上婚车, 婚礼已结束
	WeddingCarUnderFini = 301,		--夫妻请求下婚车, 婚礼已结束
	WeddingCarOnNoStart = 302,			--夫妻请求上婚车, 婚车未开始
	WeddingCarUnderNoStart = 303,		--夫妻请求下婚车, 婚车未开始
	WeddingCarOnNoSpouse = 304,		--夫妻请求上婚车, 不是夫妻双方
	WeddingCarUnderNoSpouse = 305,		--夫妻请求下婚车, 不是夫妻双方
	WeddingCarOnNoCar = 306,		--夫妻请求上婚车, 婚车不存在
}

--巡礼进入仪式之地男女同意拒绝值
MarriageCeremonyBit = {
	MaleAgreeValue = 1,	--男方同意位值
	FemaleAgreeValue = 2,	--女方同意位值
}

MARRIAGE_CEREMONY_MAP_ID = 2200

WeddingType = {
	CLASSIC = 1,
	LUXURY = 2,
}

WeddingInfoConfig = {
	  { q_type = WeddingType.CLASSIC, q_price = 2888, q_broadcast = true, q_wedding_car = false, q_basic = true, q_time = 180, q_arrange = 1, q_cooling = 15, q_name = "经典婚礼",},
	  { q_type = WeddingType.LUXURY, q_price = 6888, q_broadcast = true, q_wedding_car = true, q_basic = true, q_time = 200, q_arrange = 2, q_cooling = 15, q_name = "豪华婚礼",},
}

MARRIAGE_WEDDING_BROADCAST_TOTALTIME = 900 	--单位分钟 婚礼开启后多久时间内需要广播
MARRIAGE_WEDDING_BROADCAST_PERIOD = 300		--单位分钟 广播间隔

WeddingCarConfig = {
	q_continue_npc = 15, q_continue_destination = 60, q_drop_period = 20, q_drop_last = 10, q_monster_id = 80100, q_map_id = 2100, q_running_dropid = 898, q_last_dropid = 898, }

--[[
WEDDINGCAR_RUNNING_ROUTE = {
	{ x = 123, y = 134 }, 
	{ x = 72, y = 174 }, 
	{ x = 135, y = 222 }, 
	{ x = 196, y = 175 },
	{ x = 75, y = 76 },
	{ x = 134, y = 36 },
	{ x = 195, y = 80 },
	{ x = 123, y = 134 },
}
]]

WEDDINGCAR_RUNNING_ROUTE = {
	{ x = 123, y = 135 },
	{ x = 106, y = 147 }, 
	{ x = 89, y = 159 }, 
	{ x = 69, y = 177 },
	{ x = 124, y = 223 },
	{ x = 136, y = 223 },
	{ x = 158, y = 200 },
	{ x = 178, y = 198 },
	{ x = 198, y = 176 },
	{ x = 182, y = 161 },
	{ x = 177, y = 161 },
	{ x = 163, y = 148 },
	{ x = 159, y = 148 },
	{ x = 141, y = 132 },
	{ x = 133, y = 132 },
	{ x = 105, y = 103 },
	{ x = 99, y = 103 },
	{ x = 75, y = 77 },
	{ x = 132, y = 34 },
	{ x = 152, y = 53 },
	{ x = 160, y = 53 },
	{ x = 196, y = 80 },
	{ x = 186, y = 89 },
	{ x = 183, y = 89 },
	{ x = 164, y = 107 },
	{ x = 143, y = 119 },
	{ x = 123, y = 135 }, 
}

WEDDING_CAR_SPEED = 40

INVITATION_CARD_ITEM_ID = 5201314

WEDDING_VENUE_MIN = 2211
WEDDING_VENUE_MAX = 2260
WEDDING_VENUE_AVAILABLE = {}

WEDDING_VENUE_INIT_POINT = {
	x = 21,
	y = 72,
}

WEDDING_VENUE_KICKOUT_POINT = {
	x = 133,
	y = 127,
}

WEDDINGCAR_STATUS = {
	UnFinish = 1,
	Finish = 2,
}

WEDDINGCAR_MOVE_STATUS = {
	UNSTART = 1,
	MOVING = 2,
	ARRIVED = 3,
}

WEDDINGVENUE_STATUS = {
	UnFinish = 1,
	Finish = 2,
}

WEDDING_CAR_CREATE_PERIOD = 5
WEDDING_CAR_START_PERIOD = 15

WEDDING_CAR_BROADCAST_PERIOD = 5

WEDDINGBROADCAST_STATUS = {
	UnFinish = 1,
	Finish = 2,
}

WEDDING_TOTAL_TIME = {
	[WeddingType.CLASSIC] = 10800,
	[WeddingType.LUXURY] = 12000,
}

MAX_VENUE_PLAYERCOUNT = 100
MIN_VENUE_PLAYERLEVEL = 10

--宾客送红包标记值
MarriageBonusBit = {
	GreetingCardBonusBit = 1,			--祝福贺卡红包
	CelebrateWineBonusBit = 2,			--庆贺美酒红包
	WeddingRedBonusBit = 4,				--新婚红包红包
}

--宾客红包
MarriageBonusType = {
	GreetingCardBonus = 1,			--祝福贺卡红包
	CelebrateWineBonus = 2,			--庆贺美酒红包
	WeddingRedBonus = 3,			--新婚红包红包
}

--红包元宝值
GREETING_CARD_BONUS = 88 	--祝福贺卡
CELEBRATE_WINE_BONUS = 288 	--庆贺美酒
WEDDING_RED = 488			--新婚红包

AmbienceType = {
	RomanticPetals = 1, 	--浪漫花瓣功能
	MusicTeacher = 2, 	--礼乐师	
}

AmbienceStatus = {
	unUse = 1, 	--未使用
	using = 2, 	--使用中
	cooling = 3,	--冷却中
}

RomanticPetalsContinue = 300  --浪漫花瓣持续时间
MusicTeacherContinue = 300 	--礼乐师持续时间

RomanticPetalsCooling = 900 	--浪漫花瓣冷却时间
MusicTeacherCooling = 900 	--礼乐师冷却时间

PlayType = {
	Hydrangea = 1, 	--抢绣球
	Drink = 2, 		--拼酒	
}

PlayStatus = {
	unUse = 1, 	--未使用
	using = 2, 	--使用中
	cooling = 3,	--冷却中
}

HydrangeaContinue = 600  	--抢绣球持续时间
DrinkContinue = 300 		--拼酒持续时间

HydrangeaCooling = 900  	--抢绣球冷却时间
DrinkCooling = 900 		--拼酒冷却时间

HydrangeaContinueWin = 60 		--绣球持有多久之后获胜

DrinkStatus = {
	Sober = 1,			--清醒状态
	Drunk = 2,			--喝醉状态
	Cooling = 3,		--冷却状态
}

DRUNK_RATIO = 20

DrinkSoberCooling = 5 	--拼酒没有喝醉情况下冷却时间
DrinkDrunkCooling = 30 	--拼酒喝醉情况下冷却时间

DRINK_RANK_LIMIT = 5
DRINK_RANK_INTERVAL = 10

MARRIAGE_WINE_ITEM_ID = 5201315

BROADCAST_FINI_TIME = {
	900,
	300,
	60,
}

MARRIAGE_BONUS_EMAIL_ID = 520