require("scripts/protocolcommon/protocol/protocol_139_2")

--================================请求================================
CSOprateTianShuTask = CSOprateTianShuTask or BaseClass(BaseProtocolStruct)
function CSOprateTianShuTask:__init( ... )
	self:InitMsgType(139,1)
	self.oprate_type = 0  --  1:领取奖励 2：进入地图 3:购买次数
	self.reward_type = 0  --操作类型为1时有效
end

function CSOprateTianShuTask:Encode( ... )
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.oprate_type)
	MsgAdapter.WriteUChar(self.reward_type)
end


--速传
CSTransmitStoneReq = CSTransmitStoneReq or BaseClass(BaseProtocolStruct)
function CSTransmitStoneReq:__init()
	self:InitMsgType(139, 4)
	self.area_index = 0
	self.btn_index = 0
end

function CSTransmitStoneReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.area_index)
	MsgAdapter.WriteUChar(self.btn_index)
end
--速传
CSQuicklyTransmitReq = CSQuicklyTransmitReq or BaseClass(BaseProtocolStruct)
function CSQuicklyTransmitReq:__init()
	self:InitMsgType(139, 7)
	self.index = 0
end

function CSQuicklyTransmitReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUShort(self.index)
end

--获取野外BOSS个人信息(返回 139 8)
CSGetWildBossOwnInfo = CSGetWildBossOwnInfo or BaseClass(BaseProtocolStruct)
function CSGetWildBossOwnInfo:__init()
	self:InitMsgType(139, 8)
end

function CSGetWildBossOwnInfo:Encode()
	self:WriteBegin()
end

--领取离线经验(返回 139 6)
CSGetOfflineExp = CSGetOfflineExp or BaseClass(BaseProtocolStruct)
function CSGetOfflineExp:__init()
	self:InitMsgType(139, 9)
	self.index = 1					--1单倍, 2双倍, 3五倍
end

function CSGetOfflineExp:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.index)
end

--秘境Boss请求(返回 139 11)
CSSecretBossReq = CSSecretBossReq or BaseClass(BaseProtocolStruct)
function CSSecretBossReq:__init()
	self:InitMsgType(139, 11)
	self.type = 1					-- 1获得秘境信息, 2购买次数
end

function CSSecretBossReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.type)
end

--设置玩家系统类型(无返回)
CSSetPlayerSystemTypeReq = CSSetPlayerSystemTypeReq or BaseClass(BaseProtocolStruct)
function CSSetPlayerSystemTypeReq:__init()
	self:InitMsgType(139, 12)
	self.type = 1					-- 系统类型, 1为ios, !=1为安卓或其它系统
end

function CSSetPlayerSystemTypeReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.type)
end

--发送日常除魔请求(返回 139 15)
CSDailyTasksReq = CSDailyTasksReq or BaseClass(BaseProtocolStruct)
function CSDailyTasksReq:__init()
	self:InitMsgType(139, 15)
	self.type = 0 -- 1请求除魔信息 2接受除魔任务 3一键完成 4继续除魔 5刷新星级 6领取奖励 7下发除魔杀怪数据 8购买除魔次数
	self.index = 0 
end

function CSDailyTasksReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.type)
	if self.type == 6 then
		MsgAdapter.WriteUChar(self.index)
	end
end

--请求特惠礼包信息(返回 139 16)
CSTHGiftInfoReq = CSTHGiftInfoReq or BaseClass(BaseProtocolStruct)
function CSTHGiftInfoReq:__init()
	self:InitMsgType(139, 16)
end

function CSTHGiftInfoReq:Encode()
	-- self:WriteBegin()
end

--请求购买特惠礼包(返回 139 17)
CSTHGiftBuyReq = CSTHGiftBuyReq or BaseClass(BaseProtocolStruct)
function CSTHGiftBuyReq:__init()
	self:InitMsgType(139, 17)
	self.gift_type = 0 --礼包类型
	self.gift_level = 0 --礼包档次	
end

function CSTHGiftBuyReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.gift_type)
	MsgAdapter.WriteUChar(self.gift_level)
end

--请求限时抢购礼包信息(返回 139 18)
CSQGGiftInfoReq = CSQGGiftInfoReq or BaseClass(BaseProtocolStruct)
function CSQGGiftInfoReq:__init()
	self:InitMsgType(139, 18)
	self.id = 1 --事件id 1 请求试炼奖励经验	
end

function CSQGGiftInfoReq:Encode()
	-- self:WriteBegin()
	-- MsgAdapter.WriteUChar(self.id)
end

--请求购买限时抢购礼包(返回 139 19)
CSQGGiftBuyReq = CSQGGiftBuyReq or BaseClass(BaseProtocolStruct)
function CSQGGiftBuyReq:__init()
	self:InitMsgType(139, 19)
	self.gift_type = 0 --礼包类型
	self.gift_level = 0 --礼包档次	
end

function CSQGGiftBuyReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.gift_type)
	MsgAdapter.WriteUChar(self.gift_level)
end

--发送试炼经验奖励请求(返回 139 179)
CSExpAwardReq = CSExpAwardReq or BaseClass(BaseProtocolStruct)
function CSExpAwardReq:__init()
	self:InitMsgType(139, 20)
	self.id = 1 --事件id 1 请求试炼奖励经验	
end

function CSExpAwardReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.id)
end


--发送领取经验奖励请求(返回 139 178)
CSOfflineExpAwardReq = CSOfflineExpAwardReq or BaseClass(BaseProtocolStruct)
function CSOfflineExpAwardReq:__init()
	self:InitMsgType(139, 21)
	self.id = 1 --事件id 1 请求领取离线奖励经验	
end

function CSOfflineExpAwardReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.id)
end

-- 威望任务兑换 (返回 139 21)
CSPrestigeTaskExchangeReq = CSPrestigeTaskExchangeReq or BaseClass(BaseProtocolStruct)
function CSPrestigeTaskExchangeReq:__init()
	self:InitMsgType(139, 22)
	self.index = 0 -- 索引值(从1开始)	
	self.dui_huan_time = 0
	self.item_list = {}
end

function CSPrestigeTaskExchangeReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.index)
	MsgAdapter.WriteUChar(self.dui_huan_time)
	MsgAdapter.WriteUChar(#self.item_list)
	for k, v in pairs(self.item_list) do
		CommonReader.WriteSeries(v)
	end
end

-- 请求进入威望任务场景
CSPrestigeTaskEnterrdReq = CSPrestigeTaskEnterrdReq or BaseClass(BaseProtocolStruct)
function CSPrestigeTaskEnterrdReq:__init()
	self:InitMsgType(139, 23)
end

function CSPrestigeTaskEnterrdReq:Encode()
	self:WriteBegin()
end

--珍宝阁投掷色子
CSThrowDice = CSThrowDice or BaseClass(BaseProtocolStruct)
function CSThrowDice:__init()
	self:InitMsgType(139, 24)
	self.opt_type = 0
end

function CSThrowDice:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.opt_type)
end

--珍宝阁领取步数奖励
CSZhenBaoGeStepReward = CSZhenBaoGeStepReward or BaseClass(BaseProtocolStruct)
function CSZhenBaoGeStepReward:__init()
	self:InitMsgType(139, 25)
end

function CSZhenBaoGeStepReward:Encode()
	self:WriteBegin()
end

--领取珍宝阁层数奖励
CSZhenBaoGeLayerReward = CSZhenBaoGeLayerReward or BaseClass(BaseProtocolStruct)
function CSZhenBaoGeLayerReward:__init()
	self:InitMsgType(139, 26)
    self.index = 0
end

function CSZhenBaoGeLayerReward:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.index)
end

--开服活动元宝转盘请求
CSOpenServerActGoldDrawReq = CSOpenServerActGoldDrawReq or BaseClass(BaseProtocolStruct)
function CSOpenServerActGoldDrawReq:__init()
	self:InitMsgType(139, 27)
    self.req_type = 0
    self.select_award_type = 0
end

function CSOpenServerActGoldDrawReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.req_type)
	MsgAdapter.WriteUChar(self.select_award_type)
end

--请求开服活动寻宝榜活动数据以及领取奖励
CSExploreRankReq = CSExploreRankReq or BaseClass(BaseProtocolStruct)
function CSExploreRankReq:__init()
	self:InitMsgType(139, 28)
    self.index = 0
end

function CSExploreRankReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.index)
end

--请求传送至劫镖点
CSTransmitToRobEscortReq = CSTransmitToRobEscortReq or BaseClass(BaseProtocolStruct)
function CSTransmitToRobEscortReq:__init()
	self:InitMsgType(139, 29)
	self.scene_id = 0
	self.pos_x = 0
	self.pos_y = 0
end

function CSTransmitToRobEscortReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUShort(self.scene_id)
	MsgAdapter.WriteInt(self.pos_x)
	MsgAdapter.WriteInt(self.pos_y)
end

--发送经脉处理
CSSendMeridiansReq = CSSendMeridiansReq or BaseClass(BaseProtocolStruct)
function CSSendMeridiansReq:__init()
	self:InitMsgType(139, 30)
	self.index = 1					--1获取信息, 2升级经脉
end

function CSSendMeridiansReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.index)
end

--发送官职处理
CSSendOfficeReq = CSSendOfficeReq or BaseClass(BaseProtocolStruct)
function CSSendOfficeReq:__init()
	self:InitMsgType(139, 31)
	self.index = 0					--官职事件,1获取官职信息, 2激活, 3升级
end

function CSSendOfficeReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.index)
end

-- 点击复活按钮，请求复活
CSFuhuoReq = CSFuhuoReq or BaseClass(BaseProtocolStruct)
function CSFuhuoReq:__init()
	self:InitMsgType(139, 35)
	self.fuhuo_type = 0 		--(0复活石, 1元宝复活, 2安全复活, 4原地复活)
end

function CSFuhuoReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.fuhuo_type)
end

-- 请求领取开服活动寻宝奖励
CSOpenServerAcitivityXunBaoReq = CSOpenServerAcitivityXunBaoReq or BaseClass(BaseProtocolStruct)
function CSOpenServerAcitivityXunBaoReq:__init()
	self:InitMsgType(139, 36)
	self.receive_index = 0 -- 领取档位从1开始
end

function CSOpenServerAcitivityXunBaoReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.receive_index)
end

-- 请求领取开服活动全民BOSS奖励
CSOpenServerAcitivityBossGiftReq = CSOpenServerAcitivityBossGiftReq or BaseClass(BaseProtocolStruct)
function CSOpenServerAcitivityBossGiftReq:__init()
	self:InitMsgType(139, 37)
	self.receive_index = 0 -- 领取档位从1开始
end

function CSOpenServerAcitivityBossGiftReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.receive_index)
end

-- 请求领取开服活动累充奖励
CSOpenServerAcitivityChargeGiftReq = CSOpenServerAcitivityChargeGiftReq or BaseClass(BaseProtocolStruct)
function CSOpenServerAcitivityChargeGiftReq:__init()
	self:InitMsgType(139, 38)
	self.receive_index = 0 -- 领取档位从1开始
end

function CSOpenServerAcitivityChargeGiftReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.receive_index)
end

-- 请求领取开服活动等级礼包
CSOpenServerAcitivityReceiveLevelGiftReq = CSOpenServerAcitivityReceiveLevelGiftReq or BaseClass(BaseProtocolStruct)
function CSOpenServerAcitivityReceiveLevelGiftReq:__init()
	self:InitMsgType(139, 39)
	self.gift_index = 0
end

function CSOpenServerAcitivityReceiveLevelGiftReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.gift_index)
end

-- 请求开服活动等级礼包数据
CSOpenServerAcitivityLevelGiftInfoReq = CSOpenServerAcitivityLevelGiftInfoReq or BaseClass(BaseProtocolStruct)
function CSOpenServerAcitivityLevelGiftInfoReq:__init()
	self:InitMsgType(139, 40)
end

function CSOpenServerAcitivityLevelGiftInfoReq:Encode()
	self:WriteBegin()
end

-- 请求开服活动竞技奖励
CSOpenServerAcitivitySportGiftReq = CSOpenServerAcitivitySportGiftReq or BaseClass(BaseProtocolStruct)
function CSOpenServerAcitivitySportGiftReq:__init()
	self:InitMsgType(139, 41)
	self.sports_type = 0
	self.gift_index = 0
end

function CSOpenServerAcitivitySportGiftReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.sports_type)
	MsgAdapter.WriteUChar(self.gift_index)
end

-- 请求开服活动竞技榜信息
CSOpenServerAcitivitySportListInfoReq = CSOpenServerAcitivitySportListInfoReq or BaseClass(BaseProtocolStruct)
function CSOpenServerAcitivitySportListInfoReq:__init()
	self:InitMsgType(139, 42)
	self.sports_type = 0
end

function CSOpenServerAcitivitySportListInfoReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.sports_type)
end

-- 请求开服活动抽奖
CSOpenServerAcitivityDrawReq = CSOpenServerAcitivityDrawReq or BaseClass(BaseProtocolStruct)
function CSOpenServerAcitivityDrawReq:__init()
	self:InitMsgType(139, 43)
	self.req_type = 0 	-- 请求抽奖0 表示抽取全部次数，1表示抽取一次
end

function CSOpenServerAcitivityDrawReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.req_type)
end

-- 请求开服活动抽奖全服记录
CSOpenServerAcitivityDrawServerRecordingReq = CSOpenServerAcitivityDrawServerRecordingReq or BaseClass(BaseProtocolStruct)
function CSOpenServerAcitivityDrawServerRecordingReq:__init()
	self:InitMsgType(139, 44)
end

function CSOpenServerAcitivityDrawServerRecordingReq:Encode()
	self:WriteBegin()
end

-- 请求发现boss处理 返回(139, 55)
CSFindBossReq = CSFindBossReq or BaseClass(BaseProtocolStruct)
function CSFindBossReq:__init()
	self:InitMsgType(139, 45)
	self.type = 0  -- 1获取信息, 2抽取boss, 3进入副本, 购买秒杀
end

function CSFindBossReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.type)
end

-- 请求未知暗殿处理 返回(139 20)
CSUnknownDarkHouseReq = CSUnknownDarkHouseReq or BaseClass(BaseProtocolStruct)
function CSUnknownDarkHouseReq:__init()
	self:InitMsgType(139, 46)
	self.type = 0  -- 事件类型, 1获取信息, 2进入场景
	self.index = 0 -- 多倍经验配置索引, 从1开始
end

function CSUnknownDarkHouseReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.type)
	if self.type then
		MsgAdapter.WriteUChar(self.index)
	end
end

-- 请求设置单个类型BOSS提醒标志 返回(139 57)
CSSetOneTypeBossRemindFlag = CSSetOneTypeBossRemindFlag or BaseClass(BaseProtocolStruct)
function CSSetOneTypeBossRemindFlag:__init()
	self:InitMsgType(139, 48)
	self.type = 0 --boss类型
	self.value = 0 --boss标志
end

function CSSetOneTypeBossRemindFlag:Encode()
	self:WriteBegin()
	MsgAdapter.WriteInt(self.type)
	MsgAdapter.WriteLL(self.value)
end

-- 请求特惠礼包信息 返回(139 63)
CSMergeServerDiscountInfo = CSMergeServerDiscountInfo or BaseClass(BaseProtocolStruct)
function CSMergeServerDiscountInfo:__init()
	self:InitMsgType(139, 49)
	self.type = 0 -- 类型==配置id, 从1开始
end

function CSMergeServerDiscountInfo:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.type)
end

-- 请求购买合服特惠礼包
CSBuyMergeServerDiscount = CSBuyMergeServerDiscount or BaseClass(BaseProtocolStruct)
function CSBuyMergeServerDiscount:__init()
	self:InitMsgType(139, 50)
	self.type = 0 -- 类型==配置id, 从1开始
	self.index = 0 -- 档次, 索引, 从1开始
end

function CSBuyMergeServerDiscount:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.type)
	MsgAdapter.WriteUChar(self.index)
end

-- 请求开服活动消费排行处理(返回139, 58)
CSConsumeRankReq = CSConsumeRankReq or BaseClass(BaseProtocolStruct)
function CSConsumeRankReq:__init()
	self:InitMsgType(139, 51)
	self.index = 0 -- 事件, 1领取, 2数据
end

function CSConsumeRankReq:Encode()
	-- self:WriteBegin()
	-- MsgAdapter.WriteUChar(self.index)
end

-- 请求开服活动充值排行处理(返回139, 64)
CSRechargeRankReq = CSRechargeRankReq or BaseClass(BaseProtocolStruct)
function CSRechargeRankReq:__init()
	self:InitMsgType(139, 52)
	self.index = 0 -- 事件, 1领取, 2数据
end

function CSRechargeRankReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.index)
end

-- 请求 钻石回收操作
CSDiamondBackReq = CSDiamondBackReq or BaseClass(BaseProtocolStruct)
function CSDiamondBackReq:__init()
	self:InitMsgType(139, 53)
	self.back_type = 0 			-- uchar操作类型：1-套装回收  2-单件装备回收
	self.back_index = 0 		-- int 回收索引号（从1开始）
end

function CSDiamondBackReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.back_type)
	MsgAdapter.WriteInt(self.back_index)
end

-- 申请钻石回收数据
CSDiamondBackData = CSDiamondBackData or BaseClass(BaseProtocolStruct)
function CSDiamondBackData:__init()
	self:InitMsgType(139, 54)
	self.dia_type = 0 			-- 类型：1-单件限时首爆 2-套装限时回收 3-单件永久回收 4-BOSS首杀 5-回收记录
end

function CSDiamondBackData:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.dia_type)
end

-- 请求特戒融合
CSSpecialRingFusionReq = CSSpecialRingFusionReq or BaseClass(BaseProtocolStruct)
function CSSpecialRingFusionReq:__init()
	self:InitMsgType(139, 65)
	self.main_series = 0
	self.vice_series = 0
end

function CSSpecialRingFusionReq:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.main_series)
	CommonReader.WriteSeries(self.vice_series)
end

-- 请求特戒分离
CSSpecialRingPartReq = CSSpecialRingPartReq or BaseClass(BaseProtocolStruct)
function CSSpecialRingPartReq:__init()
	self:InitMsgType(139, 66)
	self.main_series = 0
	self.slot = 0 -- 分离位置, 从0开始
end

function CSSpecialRingPartReq:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.main_series)
	MsgAdapter.WriteInt(self.slot)
end

-- 请求守护商店信息
CSGuardShopInfoReq = CSGuardShopInfoReq or BaseClass(BaseProtocolStruct)
function CSGuardShopInfoReq:__init()
	self:InitMsgType(139, 69)
end

function CSGuardShopInfoReq:Encode()
	self:WriteBegin()
end

-- 购买守护神装
CSBuyGuardEquipReq = CSBuyGuardEquipReq or BaseClass(BaseProtocolStruct)
function CSBuyGuardEquipReq:__init()
	self:InitMsgType(139, 70)
	self.shop_type = 0 		-- 商铺类型, 从1开始
	self.item_index = 0 	-- 店面物品索引, 从1开始
end

function CSBuyGuardEquipReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.shop_type)
	MsgAdapter.WriteUChar(self.item_index)
end

-- 手动刷新守护神装商铺
CSFlushGuardEquipReq = CSFlushGuardEquipReq or BaseClass(BaseProtocolStruct)
function CSFlushGuardEquipReq:__init()
	self:InitMsgType(139, 71)
	self.shop_type = 0 		-- 商铺类型, 从1开始
end

function CSFlushGuardEquipReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.shop_type)
end

--=====切割=====-----
--切割升级
CSQieGeUpgrade = CSQieGeUpgrade or BaseClass(BaseProtocolStruct)
function CSQieGeUpgrade:__init( ... )
	self:InitMsgType(139,72)
end


function CSQieGeUpgrade:Encode( ... )
	self:WriteBegin()
end

--领取切割效果奖励
CSGetQieGeReweard  = CSGetQieGeReweard or BaseClass(BaseProtocolStruct)
function CSGetQieGeReweard:__init()
	self:InitMsgType(139,73)
	self.index = 0
end

function CSGetQieGeReweard:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.index)
end


--领取任务奖励
CSGetTaskReward = CSGetTaskReward or BaseClass(BaseProtocolStruct)
function CSGetTaskReward:__init( )
	self:InitMsgType(139,74)
	self.index = 0
end

function CSGetTaskReward:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.index)
end

--切割神兵升级
CSQieGeShenBinUpgrade = CSQieGeShenBinUpgrade or BaseClass(BaseProtocolStruct)
function CSQieGeShenBinUpgrade:__init( ... )
	self:InitMsgType(139,75)
	self.index = 0
end

function CSQieGeShenBinUpgrade:Encode( ... )
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.index)
end

CSReqQieGeData = CSReqQieGeData or BaseClass(BaseProtocolStruct)
function CSReqQieGeData:__init( ... )
	self:InitMsgType(139,76)
end

function CSReqQieGeData:Encode( ... )
	self:WriteBegin()
end


--======切割结束=======


--客户端转身请求
CSTurnReq = CSTurnReq or BaseClass(BaseProtocolStruct)
function CSTurnReq:__init()
	self:InitMsgType(139, 82)
end

function CSTurnReq:Encode()
	self:WriteBegin()
end

--兑换转身次数
CSExchangeTurnTimeReq = CSExchangeTurnTimeReq or BaseClass(BaseProtocolStruct)
function CSExchangeTurnTimeReq:__init()
	self:InitMsgType(139, 83)
end

function CSExchangeTurnTimeReq:Encode()
	self:WriteBegin()
end

-- 请求领取每日充值大礼包(返回 139 89)
CSGetChargeEveryDayAwardReq = CSGetChargeEveryDayAwardReq or BaseClass(BaseProtocolStruct)
function CSGetChargeEveryDayAwardReq:__init()
	self:InitMsgType(139, 88)
	self.award_grade = 0
end

function CSGetChargeEveryDayAwardReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.award_grade)
end
 
--请求获取领取礼包标示(返回 139 89)
CSChargeEveryDayInfoReq = CSChargeEveryDayInfoReq or BaseClass(BaseProtocolStruct)
function CSChargeEveryDayInfoReq:__init()
	self:InitMsgType(139, 89)
end

function CSChargeEveryDayInfoReq:Encode()
	self:WriteBegin()
end

--请求获取充值奖励
CSGetChargeEveryDayTreasureReq = CSGetChargeEveryDayTreasureReq or BaseClass(BaseProtocolStruct)
function CSGetChargeEveryDayTreasureReq:__init()
	self:InitMsgType(139, 90)
	self.award_grade = 0
end

function CSGetChargeEveryDayTreasureReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.award_grade)
end

--首充礼包信息
CSFirstChargeInfoReq = CSFirstChargeInfoReq or BaseClass(BaseProtocolStruct)
function CSFirstChargeInfoReq:__init()
	self:InitMsgType(139, 92)
end

function CSFirstChargeInfoReq:Encode()
	self:WriteBegin()
end

--领取首充礼包
CSGetFirstChagreAwardReq = CSGetFirstChagreAwardReq or BaseClass(BaseProtocolStruct)
function CSGetFirstChagreAwardReq:__init()
	self:InitMsgType(139, 93)
	self.award_grade = 0
end

function CSGetFirstChagreAwardReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.award_grade)
end

CSSendRedEnvelopesReq = CSSendRedEnvelopesReq or BaseClass(BaseProtocolStruct)
function CSSendRedEnvelopesReq:__init()
	self:InitMsgType(139, 100)
	self.view_type = 0                      -- 1为天降红包，2为屌丝逆袭
	self.type = 0                           -- 1为请求数据，2为领取操作
	self.act_index = 0
end

function CSSendRedEnvelopesReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.view_type)
	MsgAdapter.WriteUChar(self.type)
	if 2 == self.type then 
		MsgAdapter.WriteUChar(self.act_index)
	end
end

--大礼包领取按钮
CSGetGiftReq = CSGetGiftReq or BaseClass(BaseProtocolStruct)
function CSGetGiftReq:__init()
	self:InitMsgType(139, 101)
	self.gift_type = 0
end

function CSGetGiftReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.gift_type)
end

--领取序列号卡奖励
CSGetSerialNumberRewardsReq = CSGetSerialNumberRewardsReq or BaseClass(BaseProtocolStruct)
function CSGetSerialNumberRewardsReq:__init()
	self:InitMsgType(139, 102)
	self.cd_key = ""
end

function CSGetSerialNumberRewardsReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteStr(self.cd_key)
end

--获取活动tips
CSGetActivityTipsReq = CSGetActivityTipsReq or BaseClass(BaseProtocolStruct)
function CSGetActivityTipsReq:__init()
	self:InitMsgType(139, 103)
end

function CSGetActivityTipsReq:Encode()
	self:WriteBegin()
end

--==抢红包=== -------
CSGrapRedEnvlopeReq = CSGrapRedEnvlopeReq or BaseClass(BaseProtocolStruct)
function CSGrapRedEnvlopeReq:__init()
	self:InitMsgType(139, 104)
end

function CSGrapRedEnvlopeReq:Encode()
	self:WriteBegin()
end

--===领取红包
CSGetRedEnvlopeRewardReq = CSGetRedEnvlopeRewardReq or BaseClass(BaseProtocolStruct)
function CSGetRedEnvlopeRewardReq:__init()
	self:InitMsgType(139, 105)
end

function CSGetRedEnvlopeRewardReq:Encode()
	self:WriteBegin()
end

--请求充值红包数据
CSGetChargeRedEnvlopeReq = CSGetChargeRedEnvlopeReq or BaseClass(BaseProtocolStruct)
function CSGetChargeRedEnvlopeReq:__init()
	self:InitMsgType(139, 106)
end

function CSGetChargeRedEnvlopeReq:Encode()
	self:WriteBegin()
end

--请求领取超级VIP服务
CSGetSVipServiceReq = CSGetSVipServiceReq or BaseClass(BaseProtocolStruct)
function CSGetSVipServiceReq:__init()
	self:InitMsgType(139, 118)
	self.spid = 0
	self.type = 0                      -- 1.请求标记 2.提交个人资料
	self.name = ""
	self.sex = 0                       -- 1.男 2.女
	self.birthday = ""
	self.qq = ""
	self.tel = ""
	self.player_id = 0
end

function CSGetSVipServiceReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.spid)
	MsgAdapter.WriteUChar(self.type)
	MsgAdapter.WriteStr(self.name)
	MsgAdapter.WriteUChar(self.sex)
	MsgAdapter.WriteStr(self.birthday)
	MsgAdapter.WriteStr(self.qq)
	MsgAdapter.WriteStr(self.tel)
	MsgAdapter.WriteUInt(self.player_id)
end

--请求进入BOSS场景 配置:ModBossTips
CSGetInBossSceneReq = CSGetInBossSceneReq or BaseClass(BaseProtocolStruct)
function CSGetInBossSceneReq:__init()
	self:InitMsgType(139, 121)
	self.boss_type = 0
	self.boss_id = 0
end

function CSGetInBossSceneReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.boss_type)
	MsgAdapter.WriteUShort(self.boss_id)
end

--领取7天登陆奖励
CSGetSevenDaysLoadingRewardsReq = CSGetSevenDaysLoadingRewardsReq or BaseClass(BaseProtocolStruct)
function CSGetSevenDaysLoadingRewardsReq:__init()
	self:InitMsgType(139, 125)
	self.days_id = 0
end

function CSGetSevenDaysLoadingRewardsReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.days_id)
end

-- 请求领取开服活动奖励 (返回139 136)
CSGetOpenServerAcitivityRewardReq = CSGetOpenServerAcitivityRewardReq or BaseClass(BaseProtocolStruct)
function CSGetOpenServerAcitivityRewardReq:__init()
	self:InitMsgType(139, 127)
	self.act_type = 0 				-- (byte)活动类型, (1等级竞技  2翅膀竞技  3宝石竞技  4圣珠竞技  5累积充值) 
	self.reward_index = 0 			-- (byte)活动奖励索引, 从 1 开始
end

function CSGetOpenServerAcitivityRewardReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.act_type)
	MsgAdapter.WriteUChar(self.reward_index)
end

--锻造炉装备操作(返回139 145)
CSForgingEquipReq = CSForgingEquipReq or BaseClass(BaseProtocolStruct)
function CSForgingEquipReq:__init()
	self:InitMsgType(139, 130)
	self.equip_type = 0
end

function CSForgingEquipReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.equip_type)
end

--请求进入天关(返回 139  127)
CSLoadingZetaTauriReq = CSLoadingZetaTauriReq or BaseClass(BaseProtocolStruct)
function CSLoadingZetaTauriReq:__init()
	self:InitMsgType(139, 131)
end

function CSLoadingZetaTauriReq:Encode()
	self:WriteBegin()
end

-- 请求经验炼制(返回 139 135)
CSRefiningExpReq = CSRefiningExpReq or BaseClass(BaseProtocolStruct)
function CSRefiningExpReq:__init()
	self:InitMsgType(139, 138)
	self.index = 0
end

function CSRefiningExpReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.index)
end

-- 请求获得开服活动奖励信息(返回 139 137)
CSGetOpenServerAcitivityRewardMsgReq = CSGetOpenServerAcitivityRewardMsgReq or BaseClass(BaseProtocolStruct)
function CSGetOpenServerAcitivityRewardMsgReq:__init()
	self:InitMsgType(139, 139)
end

function CSGetOpenServerAcitivityRewardMsgReq:Encode()
	self:WriteBegin()
end

--请求获取副本信息(返回 139 138)
CSGetFubenEnterInfo = CSGetFubenEnterInfo or BaseClass(BaseProtocolStruct)
function CSGetFubenEnterInfo:__init()
	self:InitMsgType(139, 140)
end

function CSGetFubenEnterInfo:Encode()
	self:WriteBegin()
end

--请求进入副本(返回 26 69)
CSGEnterFubenReq = CSGEnterFubenReq or BaseClass(BaseProtocolStruct)
function CSGEnterFubenReq:__init()
	self:InitMsgType(139, 141)
	self.fuben_id = 0
end

function CSGEnterFubenReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.fuben_id)
end

--领取副本通关奖励(返回 139 140)
CSRecFubenReward = CSRecFubenReward or BaseClass(BaseProtocolStruct)
function CSRecFubenReward:__init()
	self:InitMsgType(139, 142)
	self.reward_type = 0			--1 为单倍奖励，2 为双倍奖励
end

function CSRecFubenReward:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.reward_type)
end

--退出副本
CSOutFubenReq = CSOutFubenReq or BaseClass(BaseProtocolStruct)
function CSOutFubenReq:__init()
	self:InitMsgType(139, 143)
	self.fuben_id = 0
end

function CSOutFubenReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.fuben_id)
end

-- 个人boss扫荡
CSPersonalBossSweep = CSPersonalBossSweep or BaseClass(BaseProtocolStruct)
function CSPersonalBossSweep:__init()
	self:InitMsgType(139, 144)
	self.fuben_id = 0
end

function CSPersonalBossSweep:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.fuben_id)
end

--领取每日充值礼包
CSGetEverydayChargeGiftReq = CSGetEverydayChargeGiftReq or BaseClass(BaseProtocolStruct)
function CSGetEverydayChargeGiftReq:__init()
	self:InitMsgType(139, 145)
	self.gift_type = 0
end

function CSGetEverydayChargeGiftReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.gift_type)
end

--获取7天登陆奖励信息(返回 139 120)
CSGetSevenDaysLoginRewardInfo = CSGetSevenDaysLoginRewardInfo or BaseClass(BaseProtocolStruct)
function CSGetSevenDaysLoginRewardInfo:__init()
	self:InitMsgType(139, 149)
end

function CSGetSevenDaysLoginRewardInfo:Encode()
	self:WriteBegin()
end

--昨天未完成的任务(返回 139 155)
CSYesterdayUnfinishedTaskReq = CSYesterdayUnfinishedTaskReq or BaseClass(BaseProtocolStruct)
function CSYesterdayUnfinishedTaskReq:__init()
	self:InitMsgType(139, 163)
	self.information_id = 0
	self.configurationtable_index = 0
	self.money_type = 0
end

function CSYesterdayUnfinishedTaskReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.information_id)
    if 2 == self.information_id then
    	MsgAdapter.WriteUChar(self.configurationtable_index)	
    	MsgAdapter.WriteUChar(self.money_type)	
    end	
end

-- 挑战试炼关卡
CSChallengeTrialReq = CSChallengeTrialReq or BaseClass(BaseProtocolStruct)
function CSChallengeTrialReq:__init()
	self:InitMsgType(139, 164)
end

function CSChallengeTrialReq:Encode()
	self:WriteBegin()
end

-- 领取试炼关卡额外奖励
CSReceiveTrialAddAwardsReq = CSReceiveTrialAddAwardsReq or BaseClass(BaseProtocolStruct)
function CSReceiveTrialAddAwardsReq:__init()
	self:InitMsgType(139, 165)
	self.guan_num = 0 -- 关卡数, 从1开始
end
function CSReceiveTrialAddAwardsReq:Encode()
	self:WriteBegin()
    MsgAdapter.WriteUShort(self.guan_num)	
end

-- 请求试炼信息
CSTrialDataReq = CSTrialDataReq or BaseClass(BaseProtocolStruct)
function CSTrialDataReq:__init()
	self:InitMsgType(139, 166)
end

function CSTrialDataReq:Encode()
	self:WriteBegin()
end

-- 领取试炼挂机奖励
CSReceiveTrialAwardsReq = CSReceiveTrialAwardsReq or BaseClass(BaseProtocolStruct)
function CSReceiveTrialAwardsReq:__init()
	self:InitMsgType(139, 167)
end

function CSReceiveTrialAwardsReq:Encode()
	self:WriteBegin()
end

-- 进入材料副本
CSReqEnterFuben = CSReqEnterFuben or BaseClass(BaseProtocolStruct)
function CSReqEnterFuben:__init()
	self:InitMsgType(139, 172)
	self.enter_type = 0 -- 1 进入副本 2 一键完成 3 副本信息 4 经验副本奖励领取
	self.enter_fuben_id = 0 -- if type == 1 or 2     enter_fuben 为 fuben static_id
	self.fuben_index = 0 		-- 是否双倍领取，0不是，1是
	self.rew_type = 0 		-- 领取类型写1
end

function CSReqEnterFuben:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.enter_type)
	MsgAdapter.WriteUChar(self.enter_fuben_id)
	if self.enter_type == 4 then
		MsgAdapter.WriteUChar(self.rew_type)
	end
	MsgAdapter.WriteUChar(self.fuben_index)
end

--获取今天剩余转生次数(已经改为今天兑换修为剩余次数)(返回 139 166)
CSExchangeCultivationRemainingTimeReq = CSExchangeCultivationRemainingTimeReq or BaseClass(BaseProtocolStruct)
function CSExchangeCultivationRemainingTimeReq:__init()
	self:InitMsgType(139, 174)
end

function CSExchangeCultivationRemainingTimeReq:Encode()
	self:WriteBegin()
end

--领取累积天数奖励
CSGetAddDaysRewardsReq = CSGetAddDaysRewardsReq or BaseClass(BaseProtocolStruct)
function CSGetAddDaysRewardsReq:__init()
	self:InitMsgType(139, 176)
	self.reward_index = 0
end

function CSGetAddDaysRewardsReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.reward_index)
end

--勇者闯关brave 
CSBraveMakingBreakthroughReq= CSBraveMakingBreakthroughReq or BaseClass(BaseProtocolStruct)
function CSBraveMakingBreakthroughReq:__init()
	self:InitMsgType(139, 177)
	self.msg_id = 0
	self.chong_index = 0
end

function CSBraveMakingBreakthroughReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.msg_id)
	if 2 == self.msg_id then
		MsgAdapter.WriteUChar(self.chong_index)
	elseif 5 == self.msg_id then
		MsgAdapter.WriteUChar(self.chong_index)
	end 
end

--称号title
-- CSTitleReq = CSTitleReq or BaseClass(BaseProtocolStruct)
-- function CSTitleReq:__init()
-- 	self:InitMsgType(139, 178)
-- 	self.information_id = 0
-- 	self.title1 = 0
-- 	self.title2 = 0
-- end

-- function CSTitleReq:Encode()
-- 	self:WriteBegin()
-- 	MsgAdapter.WriteUChar(self.information_id)
-- 	if 2 == self.information_id then
-- 		MsgAdapter.WriteUChar(self.title1)
-- 		MsgAdapter.WriteUChar(self.title2)
-- 	end
-- end

-- 理财
CSFinancingReq = CSFinancingReq or BaseClass(BaseProtocolStruct)
function CSFinancingReq:__init()
	self:InitMsgType(139, 179)
	self.req_type = 0
	self.receive_index = 0
end

function CSFinancingReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.req_type)
	if FINANCING_TYPE_DEF.RECEIVE == self.req_type then		--领取超值理财奖励
		MsgAdapter.WriteUChar(self.receive_index)
	end
end

-- 任务传送
CSTaskTransmitReq = CSTaskTransmitReq or BaseClass(BaseProtocolStruct)
function CSTaskTransmitReq:__init()
	self:InitMsgType(139, 180)
	self.task_id = 0
end

function CSTaskTransmitReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUShort(self.task_id)
end

-- 使用特殊物品
CSUseSpecialItemReq = CSUseSpecialItemReq or BaseClass(BaseProtocolStruct)
function CSUseSpecialItemReq:__init()
	self:InitMsgType(139, 181)
	self.req_id = 0 			-- (uchar)消息id, 查看 specialType
	self.reward_type = 0 		-- (uchar)奖励类型1=免费, 2=VIP1, 3=VIP3, 4=VIP5
	self.item_guid = 0 			-- (int64)物品guid
end

function CSUseSpecialItemReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.req_id)
	if 2 == self.req_id or 5 == self.req_id then
		MsgAdapter.WriteUChar(self.reward_type)
		CommonReader.WriteSeries(self.item_guid)
	end
end

-- 开服活动:获取特惠礼包信息(返回 139 174)
CSGetOpenServerGiftReq = CSGetOpenServerGiftReq or BaseClass(BaseProtocolStruct)
function CSGetOpenServerGiftReq:__init()
	self:InitMsgType(139, 182)
end

function CSGetOpenServerGiftReq:Encode()
	self:WriteBegin()
end

-- 开服活动:购买特惠礼包(成功则返回协议: 139 174)
CSBuyOpenServerGiftReq = CSBuyOpenServerGiftReq or BaseClass(BaseProtocolStruct)
function CSBuyOpenServerGiftReq:__init()
	self:InitMsgType(139, 183)
	self.gift_id = 0 		-- (byte)礼包ID，从1开始
end

function CSBuyOpenServerGiftReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.gift_id)
end
	
	
-- 开服活动:获取BOSS竞技信息(返回 139 175)
CSGetBossMsgReq = CSGetBossMsgReq or BaseClass(BaseProtocolStruct)
function CSGetBossMsgReq:__init()
	self:InitMsgType(139, 184)
end

function CSGetBossMsgReq:Encode()
	self:WriteBegin()
end

-- 开服活动:领取BOSS竞技奖励(成功则返回协议: 139 175)
CSGetBossRewardReq = CSGetBossRewardReq or BaseClass(BaseProtocolStruct)
function CSGetBossRewardReq:__init()
	self:InitMsgType(139, 185)
	self.reward_id = 0 		-- (byte) BOSS竞技奖励，从1开始
end

function CSGetBossRewardReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.reward_id)
end

-- 快速传送到指定场景(没用到)
-- CSTransmitSceneReq = CSTransmitSceneReq or BaseClass(BaseProtocolStruct)
-- function CSTransmitSceneReq:__init()
-- 	self:InitMsgType(139, 186)
-- 	self.index = 0
-- end

-- function CSTransmitSceneReq:Encode()
-- 	self:WriteBegin()
-- 	MsgAdapter.WriteUChar(self.index)
-- end

-- 九龙壁，封灵树 成功则返回协议:139 177
CSJLAndFLSReq = CSJLAndFLSReq or BaseClass(BaseProtocolStruct)
function CSJLAndFLSReq:__init()
	self:InitMsgType(139, 186)
	self.msg_id = 0			--(uchar)消息id(1：获得祈福数据，2：绑金祈福，3：绑元祈福，4：绑金祈福10次，5：绑元祈福10次)
end

function CSJLAndFLSReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.msg_id)
end


-- 离线挂机处理(返回 139 178)
CSOfflineGuajiReq = CSOfflineGuajiReq or BaseClass(BaseProtocolStruct)
function CSOfflineGuajiReq:__init()
	self:InitMsgType(139, 187)
	self.msg_id = 0			--(uchar)离线挂机事件id, 1开始在线挂机, 2领取离线挂机奖励, 3挂机信息, 4停止在线挂机
	self.id = 1
end

function CSOfflineGuajiReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.msg_id)
	if self.msg_id == OfflineData.REQ_ID.OFFLINE_REWARD then
		MsgAdapter.WriteUChar(self.id) -- 1为双倍领取
	elseif self.msg_id == OfflineData.REQ_ID.BEGIN then
		MsgAdapter.WriteUChar(self.id) -- 挂机场景索引
	end
end

-- 求助传送
CSSendHelpTranReq = CSSendHelpTranReq or BaseClass(BaseProtocolStruct)
function CSSendHelpTranReq:__init()
	self:InitMsgType(139, 188)
	self.role_handle = ""
	self.scene_id = 0
	self.pos_x = 0
	self.pos_y = 0
end

function CSSendHelpTranReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteStr(self.role_handle)
	MsgAdapter.WriteInt(self.scene_id)
	MsgAdapter.WriteUShort(self.pos_x)
	MsgAdapter.WriteUShort(self.pos_y)
end

-- 请求精彩活动
CSSendActivityBrillantReq = CSSendActivityBrillantReq or BaseClass(BaseProtocolStruct)
function CSSendActivityBrillantReq:__init()
	self:InitMsgType(139, 189)
	self.type = 0 		--1 请求列表 2请求配置 3 请求数据 4 操作
	self.cmd_id = 0
	self.act_id = 0
	self.activity_index = 0
	self.act_tag = 0
	self.op_type = 0
end

function CSSendActivityBrillantReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.type)
	MsgAdapter.WriteUInt(self.cmd_id)
	MsgAdapter.WriteUChar(self.act_id)
	if self.type == 4 and (self.act_id == 37 or self.act_id == 55 or self.act_id == 57) then
		MsgAdapter.WriteUChar(self.act_tag)
		MsgAdapter.WriteUChar(self.activity_index)
	elseif self.type == 4 and (self.act_id == 48 or self.act_id == 63 or self.act_id == 73 or self.act_id == 80 or self.act_id == 84 or self.act_id == 93 or self.act_id == 33) then
		MsgAdapter.WriteUChar(self.activity_index)
		MsgAdapter.WriteUChar(self.act_tag)
	elseif self.type == 4 and self.act_id == 62 then
		MsgAdapter.WriteUChar(self.act_tag) --1投掷色子移动， 2领取步数奖励， 3领取层数奖励， 4奇珍兑换，5秘闻兑换
		MsgAdapter.WriteUChar(self.activity_index) --索引 tag为1时 1为免费移动，2为元宝移动
	elseif self.type == 4 and self.act_id == ACT_ID.XYFP then
		MsgAdapter.WriteUChar(self.op_type)
		if self.op_type == 1 then		-- 请求翻牌
			MsgAdapter.WriteUChar(self.activity_index)
		end
	elseif self.type == 4 and self.act_id == ACT_ID.SLLB then
		MsgAdapter.WriteUChar(self.activity_index)     --1领取积分奖励 2 炼制
		MsgAdapter.WriteUChar(self.act_tag)           --档次
	elseif self.type == 4 and self.act_id == 71 then
		MsgAdapter.WriteUChar(self.activity_index)     -- 领取档次，1，每天，2累积
		MsgAdapter.WriteUChar(self.act_tag)           --充值档次
	elseif self.type == 4 then
		MsgAdapter.WriteUChar(self.activity_index)
		if self.act_id == ACT_ID.FHB and self.activity_index == 2 then		-- 发红包
			MsgAdapter.WriteUChar(self.act_tag)
		end
		if self.act_id == ACT_ID.KHHD and self.activity_index == 0 then
			MsgAdapter.WriteUChar(self.act_tag)
		end
	end
end

-- 请求元宝护盾
CSSendGoldHudunReq = CSSendGoldHudunReq or BaseClass(BaseProtocolStruct)
function CSSendGoldHudunReq:__init()
	self:InitMsgType(139, 190)
	self.hudun_state = 0
end

function CSSendGoldHudunReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.hudun_state)
end

--合区活动处理(返回 139 184)
CSSendCombinedReq = CSSendCombinedReq or BaseClass(BaseProtocolStruct)
function CSSendCombinedReq:__init()
	self:InitMsgType(139, 191)
	self.act_id = 0 	--1双倍经验, 2合区领取城主奖励, 3元宝派对, 4翅膀派对, 5宝石派对, 6铸魂派对, 7龙魂派对, 8时装礼包, 9幸运大转盘
    self.level = 0
end

function CSSendCombinedReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.act_id)
    if 0 ~= self.level then
        MsgAdapter.WriteUChar(self.level)
    end
    
end

--合区活动信息(返回 139 185)
CSSendCombinedInfo = CSSendCombinedInfo or BaseClass(BaseProtocolStruct)
function CSSendCombinedInfo:__init()
	self:InitMsgType(139, 192)
	self.act_id = 0 	--1累计充值, 2合区领取城主奖励, 3元宝派对, 4翅膀派对, 5宝石派对, 6铸魂派对, 7龙魂派对, 8时装礼包, 9幸运大转盘
end

function CSSendCombinedInfo:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.act_id)
end

-- 请求洪荒之力
CSSendRingHonghuangReq = CSSendRingHonghuangReq or BaseClass(BaseProtocolStruct)
function CSSendRingHonghuangReq:__init()
	self:InitMsgType(139, 193)
	self.msg_id = 0
end

function CSSendRingHonghuangReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.msg_id)
end

--超值寻宝(返回 139 187)
CSSendSupperXunbao = CSSendSupperXunbao or BaseClass(BaseProtocolStruct)
function CSSendSupperXunbao:__init()
	self:InitMsgType(139, 194)
	self.type = 0 	--操作类型, 1抽奖, 2获取抽奖信息
end

function CSSendSupperXunbao:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.type)
end

--通过场景id快速定点传送
CSSceneTransmitReq = CSSceneTransmitReq or BaseClass(BaseProtocolStruct)
function CSSceneTransmitReq:__init()
	self:InitMsgType(139, 195)
	self.scene_id = 0
	self.pos_x = 0
	self.pos_y = 0
end

function CSSceneTransmitReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteInt(self.scene_id)
	MsgAdapter.WriteUShort(self.pos_x)
	MsgAdapter.WriteUShort(self.pos_y)
end

--超值礼包
CSOpServSupperGiftReq = CSOpServSupperGiftReq or BaseClass(BaseProtocolStruct)
function CSOpServSupperGiftReq:__init()
	self:InitMsgType(139, 196)
	self.req_type = 0 	-- 1购买礼包, 2礼包标记信息
	self.gift_type = 0
	self.gift_index = 0
end

function CSOpServSupperGiftReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.req_type)
	if self.req_type == 1 then
		MsgAdapter.WriteUChar(self.gift_type)
		MsgAdapter.WriteUChar(self.gift_index)
	end
end

-- 资源找回
CSResourceRecoveryReq = CSResourceRecoveryReq or BaseClass(BaseProtocolStruct)
function CSResourceRecoveryReq:__init()
	self:InitMsgType(139, 197)
	self.value_type = 0 			-- 事件  1-元宝找回， 2-钻石找回，3-一键元宝找回， 4-一键钻石找回
	self.task_id = 0 				-- 任务id   
end

function CSResourceRecoveryReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.value_type)
	if self.value_type == 1 or self.value_type == 2 then
		MsgAdapter.WriteUChar(self.task_id)
	end
end

--请求轮回信息(返回139 190)
CSLunHuiReq = CSLunHuiReq or BaseClass(BaseProtocolStruct)
function CSLunHuiReq:__init()
	self:InitMsgType(139, 198)	
	self.opt_type = 3				-- 1 提升轮回数; 2 等级兑换修为; 3 获取轮回数据; 4 获取轮回装备数据; 5 升阶魔化
	self.equip_index = 0
	self.btn_index = 0
end

function CSLunHuiReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.opt_type)
	MsgAdapter.WriteUChar(self.equip_index)
	MsgAdapter.WriteUChar(self.btn_index)
end

--开服活动：建功立业，开服竞技 (返回139 191)
CSOpenServerActReq = CSOpenServerActReq or BaseClass(BaseProtocolStruct)
function CSOpenServerActReq:__init()
	self:InitMsgType(139, 199)
	self.event_type = 0			-- 事件id , 1领取活动, 2获取活动数据
	self.act_type = 0     		-- 活动类型, 1建功立业, 6等级竞技, 7官职竞技, 8战将竞技, 9翅膀竞技, 10宝石竞技, 11强化竞技, 12魂珠竞技, 13斗笠竞技, 14 消费竞技, 15 绑元送送送
	self.reward_index = 0
	self.panel_index = 0
	self.fetch_index = 0
end


function CSOpenServerActReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.event_type)
	MsgAdapter.WriteUChar(self.act_type)

	if 1 == self.act_type then
		if 1 == self.event_type then
			MsgAdapter.WriteUChar(self.reward_index)
		end
	elseif self.act_type >= 6 and self.act_type <= 14 then
		if 1 == self.event_type then
			MsgAdapter.WriteUChar(self.panel_index)
			MsgAdapter.WriteUChar(self.fetch_index)
		end
	elseif self.act_type == 15 then
	end
end

--开服活动：全民BOSS (返回139 192)
AllPeopleBossReq = AllPeopleBossReq or BaseClass(BaseProtocolStruct)
function AllPeopleBossReq:__init()
	self:InitMsgType(139, 200)
	self.opera_type = 0			-- 操作类型， 1请求活动配置 2玩家数据 3领取
	self.reward_index = 0 		-- 奖励索引
end

function AllPeopleBossReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.opera_type)
	MsgAdapter.WriteUChar(self.reward_index)
end

--获取玩家特殊属性 (返回139 197)
AllRloeSpecialAttrReq = AllRloeSpecialAttrReq or BaseClass(BaseProtocolStruct)
function AllRloeSpecialAttrReq:__init()
	self:InitMsgType(139, 201)
	self.attr_type = 0			-- 操作类型， 1等级 2战斗力
end

function AllRloeSpecialAttrReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.attr_type)
end

--秘境值 相关 (返回139 194)
-- CSNeedValSceneValReq = CSNeedValSceneValReq or BaseClass(BaseProtocolStruct)
-- function CSNeedValSceneValReq:__init()
-- 	self:InitMsgType(139, 202)
-- 	self.opt_type = 0		-- 操作类型 1购买, 2查询
-- end

-- function CSNeedValSceneValReq:Encode()
-- 	self:WriteBegin()
-- 	MsgAdapter.WriteUChar(self.opt_type)
-- end

--跨服装备 相关 (返回139 195)
CSCrossEqInfoReq = CSCrossEqInfoReq or BaseClass(BaseProtocolStruct)
function CSCrossEqInfoReq:__init()
	self:InitMsgType(139, 203)
	self.opt_type = 0		-- 操作类型 1获取装备信息, 2升阶/魔化
	self.eq_pos = 0			-- 部位 1吊坠 2护肩 3面甲 4护膝 5护心
	self.opt_type2 = 0		-- 1升阶 2魔化
end

function CSCrossEqInfoReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.opt_type)
	if self.opt_type == 2 then
		MsgAdapter.WriteUChar(self.eq_pos)
		MsgAdapter.WriteUChar(self.opt_type2)
	end
end

--一键使用物品
CSOnekeyUseItemReq = CSOnekeyUseItemReq or BaseClass(BaseProtocolStruct)
function CSOnekeyUseItemReq:__init()
	self:InitMsgType(139, 204)
	self.series = 0
end

function CSOnekeyUseItemReq:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.series)
end

-- 特权卡(返回139, 196)
CSPrivilegeReq = CSPrivilegeReq or BaseClass(BaseProtocolStruct)
function CSPrivilegeReq:__init()
	self:InitMsgType(139, 205)
	self.op_type = 0	--操作类型
	self.view_idx = 0	--面板索引
	self.op_idx = 0		--操作索引
end

function CSPrivilegeReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.op_type)
	if self.op_type == 2 then --1为请求内容，2为按钮处理
		MsgAdapter.WriteUChar(self.view_idx)
		if self.view_idx ~= 0 then --0为团购
			MsgAdapter.WriteUChar(self.op_idx) --1购买，2续费，3领取
		end
	end
end

CSYBTurntableReq = CSYBTurntableReq or BaseClass(BaseProtocolStruct)
function CSYBTurntableReq:__init()
	self:InitMsgType(139,206)
	self.type = 0   --1请求数据 2抽奖处理
	self.static_id = 0   --转盘副本id
end

function CSYBTurntableReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.type)
	MsgAdapter.WriteUChar(self.static_id)
end

CSEnterPracticeReq = CSEnterPracticeReq or BaseClass(BaseProtocolStruct)
function CSEnterPracticeReq:__init()
	self:InitMsgType(139, 207)
	self.type = 0   -- 1 进入试炼地图 2 进入试炼关卡 3退出试炼关卡 4 请求关数
end 

function CSEnterPracticeReq:Encode()
	-- body
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.type)
end

CSEnterPracticeGateReq = CSEnterPracticeGateReq or BaseClass(BaseProtocolStruct)
function CSEnterPracticeGateReq:__init()
	self:InitMsgType(139, 208)
end 

function CSEnterPracticeGateReq:Encode()
	-- body
	self:WriteBegin()
end

-- 发送试炼转盘事件 返回(139, 200)
CSShiLianRotaryTableReq = CSShiLianRotaryTableReq or BaseClass(BaseProtocolStruct)
function CSShiLianRotaryTableReq:__init()
	self:InitMsgType(139, 209)
	self.type = 0 -- 操作类型, 1抽奖信息, 2单次抽奖
end 

function CSShiLianRotaryTableReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.type)
end

-- 上线请求每日奖励信息 返回(139, 201)
CSShiLianAwardInfoReq = CSShiLianAwardInfoReq or BaseClass(BaseProtocolStruct)
function CSShiLianAwardInfoReq:__init()
	self:InitMsgType(139, 210)
end 

function CSShiLianAwardInfoReq:Encode()
	self:WriteBegin()
end

-- 请求领取试炼每日奖励
CSShiLianAwardLingQuReq = CSShiLianAwardLingQuReq or BaseClass(BaseProtocolStruct)
function CSShiLianAwardLingQuReq:__init()
	self:InitMsgType(139, 211)
end 

function CSShiLianAwardLingQuReq:Encode()
	self:WriteBegin()
end

--请求 超值投资
CSInvestmentInfo = CSInvestmentInfo or BaseClass(BaseProtocolStruct)
function CSInvestmentInfo:__init()
	self:InitMsgType(139,212)
	self.op_type = 0     --1.请求下发界面信息 2.请求领取奖励 3.vip奖励 4.战力奖励
	self.award_index = 0 	--领取奖励索引
end 

function CSInvestmentInfo:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.op_type)
	if self.op_type >= 2 then		-- 领取奖励索引
		MsgAdapter.WriteUChar(self.award_index)
	end
end

--139 213（返回139 203
--（int）充值有多少档
CSChongZhiInfoReq = CSChongZhiInfoReq or BaseClass(BaseProtocolStruct)
function CSChongZhiInfoReq:__init()
	self:InitMsgType(139, 213)
end

function CSChongZhiInfoReq:Encode()
	self:WriteBegin()
end

--请求洗点
CSInitPointReq = CSInitPointReq or BaseClass(BaseProtocolStruct)
function CSInitPointReq:__init()
	self:InitMsgType(139, 214)
end

function CSInitPointReq:Encode()
	self:WriteBegin()
end

-- 请求运势
CSFortuneReq = CSFortuneReq or BaseClass(BaseProtocolStruct)
function CSFortuneReq:__init()
	self:InitMsgType(139, 215)
	self.fortune_type = 0 			-- 1-重启运势  2-分享运势  3-接受运势  4-拒绝运势（删除所有）
	self.role_id = 0 				-- uint 角色ID
	self.fx_index = 0 				-- uiint 分享索引
end

function CSFortuneReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.fortune_type)
	if self.fortune_type == 2 then
		MsgAdapter.WriteUInt(self.role_id)
	elseif self.fortune_type == 3 then
		MsgAdapter.WriteUInt(self.fx_index)
	end
end

-- 请求福利转盘
CSWelfareTurnbelReq = CSWelfareTurnbelReq or BaseClass(BaseProtocolStruct)
function CSWelfareTurnbelReq:__init()
	self:InitMsgType(139, 216)
	self.idx = 0 			-- 1-抽奖  2-领取boss积分  3-领取在线积分  4-请求数据
end

function CSWelfareTurnbelReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.idx)
end

-- 请求魂环
CSHunHuanReq = CSHunHuanReq or BaseClass(BaseProtocolStruct)
function CSHunHuanReq:__init()
	self:InitMsgType(139, 217)
	self.idx = 0 	 --1下发界面信息 2 请求购买礼包  3请求领取礼包
end

function CSHunHuanReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.idx)
end

-- 请求绝版抢购 购买礼包
CSOutOfPrintReq = CSOutOfPrintReq or BaseClass(BaseProtocolStruct)
function CSOutOfPrintReq:__init()
	self:InitMsgType(139, 218)
	self.gear = 0 -- 从1开始
end

function CSOutOfPrintReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.gear)
end

-- 蚩尤请求投入神石
CSChiyouInputReq = CSChiyouInputReq or BaseClass(BaseProtocolStruct)
function CSChiyouInputReq:__init()
	self:InitMsgType(139, 219)
	self.req_type = 0 					-- 1-请求数据   2-投入神石
end

function CSChiyouInputReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.req_type)
end

--请求 天天返利
CSRebateEveryDayInfo = CSRebateEveryDayInfo or BaseClass(BaseProtocolStruct)
function CSRebateEveryDayInfo:__init()
	self:InitMsgType(139, 220)
	self.op_type = 0     --2.请求数据 3.请求领取奖励
	self.award_index = 0 	--领取奖励索引
end 

function CSRebateEveryDayInfo:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.op_type)
	if self.op_type == 3 then		-- 领取奖励索引
		MsgAdapter.WriteUChar(self.award_index)
	end
end

--请求 天天充值豪礼
CS_139_221 = CS_139_221 or BaseClass(BaseProtocolStruct)
function CS_139_221:__init()
	self:InitMsgType(139, 221)
	self.op_type = 0     -- 事件id, 1玩家数据, 2领取
	self.index = 0
end 
function CS_139_221:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.op_type)
	if self.op_type == 2 then
		MsgAdapter.WriteUChar(self.index)
	end
end

--请求 升级称号等级
CS_139_222 = CS_139_222 or BaseClass(BaseProtocolStruct)
function CS_139_222:__init()
	self:InitMsgType(139, 222)
	self.title_id = 0     -- 称号id
end 
function CS_139_222:Encode()
	self:WriteBegin()
	MsgAdapter.WriteInt(self.title_id)
end

--================================下发================================

--天书任务完成次数
SCGetHadCompeleteTime = SCGetHadCompeleteTime or BaseClass(BaseProtocolStruct)
function SCGetHadCompeleteTime:__init( ... )
	self:InitMsgType(139, 1)
	self.complete_time = 0
	self.buy_time = 0     -- 当前购买次数
end

function SCGetHadCompeleteTime:Decode()
	self.complete_time = MsgAdapter.ReadUChar()
	self.buy_time = MsgAdapter.ReadUChar()
end



-- 离线经验信息
SCOfflineExpInfo = SCOfflineExpInfo or BaseClass(BaseProtocolStruct)
function SCOfflineExpInfo:__init()
	self:InitMsgType(139, 5)
	self.every_hour_exp = 0
	self.add_offline_time = 0
end

function SCOfflineExpInfo:Decode()
	self.every_hour_exp = MsgAdapter.ReadUInt()
	self.add_offline_time = MsgAdapter.ReadUInt()
end

-- 领取离线经验结果
SCGetOfflineExpResult = SCGetOfflineExpResult or BaseClass(BaseProtocolStruct)
function SCGetOfflineExpResult:__init()
	self:InitMsgType(139, 6)
	self.result = 0								--1成功, 0失败
end

function SCGetOfflineExpResult:Decode()
	self.result = MsgAdapter.ReadUChar()
end

-- 下发野外boss个人信息
SCGetWildBossOwnInfo = SCGetWildBossOwnInfo or BaseClass(BaseProtocolStruct)
function SCGetWildBossOwnInfo:__init()
	self:InitMsgType(139, 8)
	self.times = 0								--进入野外BOSS次数
	self.cd_time = 0							--增加次数的CD时间
end

function SCGetWildBossOwnInfo:Decode()
	self.times = MsgAdapter.ReadUChar()
	self.cd_time = CommonReader.ReadServerUnixTime()
end

-- 下发秘境boss个人信息
SCGetSecretBossOwnInfo = SCGetSecretBossOwnInfo or BaseClass(BaseProtocolStruct)
function SCGetSecretBossOwnInfo:__init()
	self:InitMsgType(139, 11)
	self.type = 0								--1获取秘境boss信息, 2购买次数
	self.enter_times = 0								--进入野外BOSS次数
	self.buy_times = 0									--增加次数的CD时间
	self.attribution_list = {}								--归属
end

function SCGetSecretBossOwnInfo:Decode()
	self.type = MsgAdapter.ReadUChar()
	self.enter_times = MsgAdapter.ReadUChar()
	self.buy_times = MsgAdapter.ReadUChar()
	self.attribution_list = {}
	local count = MsgAdapter.ReadInt()
	for i = 1, count do
		local data = {}
		data.boss_id = MsgAdapter.ReadUInt()
		data.role_id = MsgAdapter.ReadUInt()
		data.role_name = MsgAdapter.ReadStr()
		table.insert(self.attribution_list, data)
	end
end

--设置归属(指镖车)
SCSetAscription = SCSetAscription or BaseClass(BaseProtocolStruct)
function SCSetAscription:__init()
	self:InitMsgType(139, 12)
	self.subordinate = 0  --下属句柄
    self.subordinate_name = "" --下属名称
    self.subordinate_model_id = 0
    self.bool_target_point_info = 0 --是否有目标点信息 1表示后面紧跟着目标点信息 0表示后面无目标点信息
    self.target_scene_id = 0
    self.target_npc_name = ""
end

function SCSetAscription:Decode()
	self.subordinate = MsgAdapter.ReadLL()
	self.subordinate_name = MsgAdapter.ReadStr()
	self.subordinate_model_id = MsgAdapter.ReadInt()
	self.bool_target_point_info = MsgAdapter.ReadUChar()
	self.target_scene_id = MsgAdapter.ReadInt()
	self.target_npc_name = MsgAdapter.ReadStr()
end

--通知客户端清理怪物信息
SCNoticeClearUpMonsterInfo = SCNoticeClearUpMonsterInfo or BaseClass(BaseProtocolStruct)
function SCNoticeClearUpMonsterInfo:__init()
	self:InitMsgType(139, 13)
	self.monster_entity = 0   --怪物实体句柄
end

function SCNoticeClearUpMonsterInfo:Decode()
	self.monster_entity = MsgAdapter.ReadLL()
end

-- 接收日常除魔返回结果(139, 15)
SCDailyTasksResult = SCDailyTasksResult or BaseClass(BaseProtocolStruct)
function SCDailyTasksResult:__init()
	self:InitMsgType(139, 15)
	self.index = nil -- 1请求除魔信息 2接受除魔任务 3一键完成 4继续除魔 5刷新星级 6领取奖励 7下发除魔杀怪数据 8购买除魔次数
	self.state = 0 -- 任务状态 (0可接任务, 1进入中, 2完成)
	self.goal = "" -- 除魔目标
	self.times = 0 -- 剩余除魔次数
	self.stars_num = 0 -- 任务星级
	self.goal_tip = "" -- 杀怪描述
	self.buy_time = 0 -- 购买次数
end

function SCDailyTasksResult:Decode()
	self.index = MsgAdapter.ReadUChar() -- 事件类型
	if self.index ~= 7 then
		self.state = MsgAdapter.ReadUChar()
		if self.state == 1 or self.state == 0 then
			self.goal = MsgAdapter.ReadStr()
			self.times = MsgAdapter.ReadUChar()
			self.stars_num = MsgAdapter.ReadUChar()
			self.goal_tip = MsgAdapter.ReadStr()
			self.buy_time = MsgAdapter.ReadUChar()
		elseif self.state == 2 then
			self.times = MsgAdapter.ReadUChar()
			self.stars_num = MsgAdapter.ReadUChar()
			self.goal = MsgAdapter.ReadStr()
		end
	else
		self.goal = MsgAdapter.ReadStr()
	end
end

--下发特惠礼包信息
SCTeHuiGiftInfo = SCTeHuiGiftInfo or BaseClass(BaseProtocolStruct)
function SCTeHuiGiftInfo:__init()
	self:InitMsgType(139, 16)
	self.info_t = nil
end

function SCTeHuiGiftInfo:Decode()
	self.info_t = {}
	local gift_type_num = MsgAdapter.ReadUChar()
	for gift_type = 1, gift_type_num do
		self.info_t[gift_type] = {}
		-- 该类型礼包 每个档次是否购买 1为已购买 0为未购买
		local level_num = MsgAdapter.ReadUChar()
		for type_level = 1, level_num do
			self.info_t[gift_type][type_level] = MsgAdapter.ReadUChar()
		end
	end
end

--购买特惠礼包结果 成功则下发
SCTeHuiGifResult = SCTeHuiGifResult or BaseClass(BaseProtocolStruct)
function SCTeHuiGifResult:__init()
	self:InitMsgType(139, 17)
	self.gift_type = 0
	self.gift_level = 0
end

function SCTeHuiGifResult:Decode()
	self.gift_type = MsgAdapter.ReadUChar()
	self.gift_level = MsgAdapter.ReadUChar()
end

--下发限时抢购礼包信息
SCQiangGouGiftInfo = SCQiangGouGiftInfo or BaseClass(BaseProtocolStruct)
function SCQiangGouGiftInfo:__init()
	self:InitMsgType(139, 18)
	self.info_t = {}
end

function SCQiangGouGiftInfo:Decode()
	local open_day = MsgAdapter.ReadUChar()
	self.gift_type = MsgAdapter.ReadUChar()
	self.info_t[self.gift_type] = {}

	for gift_level = 1, 4 do
		-- 该类型礼包 每个档次的剩余购买次数
		self.info_t[self.gift_type][gift_level] = MsgAdapter.ReadUChar()
	end
end

--购买限时抢购礼包结果
SCQiangGouGifResult = SCQiangGouGifResult or BaseClass(BaseProtocolStruct)
function SCQiangGouGifResult:__init()
	self:InitMsgType(139, 19)
	self.gift_type = 0
	self.gift_level = 0
	self.is_buy_num = 0		--已购买次数
end

function SCQiangGouGifResult:Decode()
	self.gift_type = MsgAdapter.ReadUChar()
	self.gift_level = MsgAdapter.ReadUChar()
	self.is_buy_num = MsgAdapter.ReadUChar()
end

-- 接收未知暗殿结果 请求(139 46)
SCUnknownDarkHouseResult = SCUnknownDarkHouseResult or BaseClass(BaseProtocolStruct)
function SCUnknownDarkHouseResult:__init()
	self:InitMsgType(139, 20)
	self.type = 0 -- 事件类型, 1获取信息, 2进入场景, 3打开窗口
	self.times = 0 -- 每天已进入次数
	self.multiple = 0 -- 倍数
	self.left_time = 0 -- 多倍剩余时间
end

function SCUnknownDarkHouseResult:Decode()
	self.type = MsgAdapter.ReadUChar()
	if self.type ~= 3 then
		self.times = MsgAdapter.ReadUChar()
		self.multiple = MsgAdapter.ReadUChar()
		self.now_time = Status.NowTime
		self.left_time = MsgAdapter.ReadUInt()
	end
end

-- 接收威望任务兑换次数 请求(139 22)
SCPrestigeTaskResult = SCPrestigeTaskResult or BaseClass(BaseProtocolStruct)
function SCPrestigeTaskResult:__init()
	self:InitMsgType(139, 21)
	self.duihuan_list = {}
end

function SCPrestigeTaskResult:Decode()
	self.count = MsgAdapter.ReadUChar()
	self.duihuan_list = {}
	for i = 1, self.count do
		local  times = MsgAdapter.ReadUShort()	
		self.duihuan_list[i] = times
	end
end

--下发珍宝阁数据
SCZhenBaoGeInfo = SCZhenBaoGeInfo or BaseClass(BaseProtocolStruct)
function SCZhenBaoGeInfo:__init()
	self:InitMsgType(139, 23)
	self.step = 0 -- 步数
	self.use_times = 0 --已投免费次数
	self.step_reward = 0 --步数奖励领取标志
	self.layer_reward_mark = 0 --层数奖励领取标志（按位）
end

function SCZhenBaoGeInfo:Decode()
	self.step = MsgAdapter.ReadUShort()
	self.use_times = MsgAdapter.ReadUChar()
	self.step_reward = MsgAdapter.ReadUChar()
	self.layer_reward_mark = MsgAdapter.ReadInt()
end

--下发珍宝阁投掷色子结果
SCDiceResult = SCDiceResult or BaseClass(BaseProtocolStruct)
function SCDiceResult:__init()
	self:InitMsgType(139, 24)
	self.dice_number = 0 --色子的点数
	self.step = 0 -- 步数
	self.use_times = 0 --已投免费次数
	self.step_reward = 0 --领取步数奖励标志（0不可领取，可领取）
end

function SCDiceResult:Decode()
	self.dice_number = MsgAdapter.ReadUChar()
	self.step = MsgAdapter.ReadUShort()
	self.use_times = MsgAdapter.ReadUChar()
	self.step_reward = MsgAdapter.ReadUChar()
end

--下发珍宝阁步数奖励领取结果
SCStepRewardResult = SCStepRewardResult or BaseClass(BaseProtocolStruct)
function SCStepRewardResult:__init()
	self:InitMsgType(139, 25)
	self.step_result  = 0  --（0不可领取 1可以）
end

function SCStepRewardResult:Decode()
	self.step_result = MsgAdapter.ReadUChar()
end

--下发珍宝阁层数奖励领取结果
SCLayerRewardResult = SCLayerRewardResult or BaseClass(BaseProtocolStruct)
function SCLayerRewardResult:__init()
	self:InitMsgType(139, 26)
	self.layer_result  = 0 --按位
end

function SCLayerRewardResult:Decode()
	self.layer_result = MsgAdapter.ReadInt()
end

--修改图像结果Modify
SCModifyImageResult = SCModifyImageResult or BaseClass(BaseProtocolStruct)
function SCModifyImageResult:__init()
	self:InitMsgType(139, 27)
	self.modify_result = 0   --(uchar)0成功, 1失败
end

function SCModifyImageResult:Decode()
	self.modify_result = MsgAdapter.ReadUChar()
end

--开服活动 元宝转盘 数据
SCOpenServeActGoldDrawInfo = SCOpenServeActGoldDrawInfo or BaseClass(BaseProtocolStruct)
function SCOpenServeActGoldDrawInfo:__init()
	self:InitMsgType(139, 28)
	self.draw_num = 0
	self.already_used_num = 0
	self.next_draw_need_gold_num = 0
	self.draw_award_index = 0
	self.record_list = {}
end

function SCOpenServeActGoldDrawInfo:Decode()
	self.draw_num = MsgAdapter.ReadUShort()
	self.already_used_num = MsgAdapter.ReadUShort()
	self.next_draw_need_gold_num = MsgAdapter.ReadUInt()
	self.draw_award_index = MsgAdapter.ReadUShort()
	local record_num = MsgAdapter.ReadUChar()
	for i = 1, record_num do
		self.record_list[i] = {
			name = MsgAdapter.ReadStr(),
			multiple_num = MsgAdapter.ReadUShort(),	--服务端 *100 后下发
			reawrd_gold_num = MsgAdapter.ReadUInt(),
		}
	end
end

--开服活动 元宝转盘 充值结果 主动下发
SCOpenServeActGoldDrawCZResult = SCOpenServeActGoldDrawCZResult or BaseClass(BaseProtocolStruct)
function SCOpenServeActGoldDrawCZResult:__init()
	self:InitMsgType(139, 29)
	self.draw_num = 0
	self.next_draw_need_gold_num = 0
end

function SCOpenServeActGoldDrawCZResult:Decode()
	self.draw_num = MsgAdapter.ReadUShort()
	self.next_draw_need_gold_num = MsgAdapter.ReadUInt()
end

--经脉处理结果
SCMeridiansResult = SCMeridiansResult or BaseClass(BaseProtocolStruct)
function SCMeridiansResult:__init()
	self:InitMsgType(139, 30)
	self.index = 0 -- 1获取信息, 2升级经脉
	self.level = 0 -- 经脉等级
end

function SCMeridiansResult:Decode()
	self.index = MsgAdapter.ReadUChar()
	self.level = MsgAdapter.ReadUShort()
end

--官职处理结果
SCOfficeResult = SCOfficeResult or BaseClass(BaseProtocolStruct)
function SCOfficeResult:__init()
	self:InitMsgType(139, 31)
	self.index = 0 -- 1获取官职信息, 2激活, 3升级
	self.level = 0 -- 官职等级
end

function SCOfficeResult:Decode()
	self.index = MsgAdapter.ReadUChar()
	self.level = MsgAdapter.ReadUShort()
end

--139,32
--寻宝榜活动
SCExploreRankInfo = SCExploreRankInfo or BaseClass(BaseProtocolStruct)
function SCExploreRankInfo:__init()
	self:InitMsgType(139, 32)
	self.is_lingqu = 0
	self.explore_times = 0		
	self.rank_num = 0
	self.rank_info_list = {}
	self.my_rank_number = 0
end

function SCExploreRankInfo:Decode()
	self.is_lingqu = MsgAdapter.ReadUChar()
	self.explore_times = MsgAdapter.ReadInt()
	self.rank_num = MsgAdapter.ReadUChar()
	self.rank_info_list = {}
	for i = 1, self.rank_num do 
		self.rank_info_list[i] = {}
		self.rank_info_list[i].rank_numer = MsgAdapter.ReadUChar()
		self.rank_info_list[i].score = MsgAdapter.ReadUInt()
		self.rank_info_list[i].name = MsgAdapter.ReadStr()
	end
	if self.rank_num == 0 then
		self.rank_info_list = {}
	end
	self.my_rank_number = MsgAdapter.ReadUChar()
end

-- 下发寻宝次数
SCExploreTimes = SCExploreTimes or BaseClass(BaseProtocolStruct)
function SCExploreTimes:__init()
	self:InitMsgType(139, 33)
	self.my_explore_times = 0 		
end

function SCExploreTimes:Decode()
	self.my_explore_times = MsgAdapter.ReadUInt()
end



-- 服务端请求打开复活面板
SCFuhuoAck = SCFuhuoAck or BaseClass(BaseProtocolStruct)
function SCFuhuoAck:__init()
	self:InitMsgType(139, 34)
	self.killer_type = 0 		--0 玩家 1怪物 2其他
	self.killer_name = 0
	self.fall_zhanhun = 0
	self.fall_exp = 0
	self.close_time = 0
	self.btn_vis = 0			--4要判断是否禁止原地复活, 12正常显示
end

function SCFuhuoAck:Decode()
	self.killer_type = MsgAdapter.ReadUChar()
	self.killer_name = MsgAdapter.ReadStr()
	self.fall_zhanhun = MsgAdapter.ReadInt()
	self.fall_exp = MsgAdapter.ReadInt()
	self.close_time = MsgAdapter.ReadInt()
	self.btn_vis = MsgAdapter.ReadUChar()
end

--下发兑换次数
SCDuiHuanCishu = SCDuiHuanCishu or BaseClass(BaseProtocolStruct)
function SCDuiHuanCishu:__init()
	self:InitMsgType(139, 35)
	self.index = 0
	self.times = 0
end

function SCDuiHuanCishu:Decode()
	self.index = MsgAdapter.ReadUChar()
	self.times = MsgAdapter.ReadUShort()
end


-- 下发开服活动寻宝信息
SCOpenServerAcitivityXunBaoInfo = SCOpenServerAcitivityXunBaoInfo or BaseClass(BaseProtocolStruct)
function SCOpenServerAcitivityXunBaoInfo:__init()
	self:InitMsgType(139, 45)
	self.xun_bao_times = 0
	self.receive_state = 0
end

function SCOpenServerAcitivityXunBaoInfo:Decode()
	self.xun_bao_times = MsgAdapter.ReadUInt()
	self.receive_state = MsgAdapter.ReadUInt()
end

-- 下发开服活动全民BOSS信息
SCOpenServerAcitivityBossInfo = SCOpenServerAcitivityBossInfo or BaseClass(BaseProtocolStruct)
function SCOpenServerAcitivityBossInfo:__init()
	self:InitMsgType(139, 46)
	self.kill_num = 0
	self.receive_state = 0
end

function SCOpenServerAcitivityBossInfo:Decode()
	self.kill_num = MsgAdapter.ReadUInt()
	self.receive_state = MsgAdapter.ReadUInt()
end

-- 下发开服活动累充信息
SCOpenServerAcitivityChargeInfo = SCOpenServerAcitivityChargeInfo or BaseClass(BaseProtocolStruct)
function SCOpenServerAcitivityChargeInfo:__init()
	self:InitMsgType(139, 47)
	self.charge_money = 0
	self.receive_state = 0
end

function SCOpenServerAcitivityChargeInfo:Decode()
	self.charge_money = MsgAdapter.ReadUInt()
	self.receive_state = MsgAdapter.ReadUInt()
end

-- 下发开服活动等级礼包信息
SCOpenServerAcitivityLevelGiftInfo = SCOpenServerAcitivityLevelGiftInfo or BaseClass(BaseProtocolStruct)
function SCOpenServerAcitivityLevelGiftInfo:__init()
	self:InitMsgType(139, 48)
	self.receive_state = 0
	self.item_num = 0
	self.left_award_list = {}
end

function SCOpenServerAcitivityLevelGiftInfo:Decode()
	self.receive_state = MsgAdapter.ReadUInt()
	self.item_num = MsgAdapter.ReadUChar()
	self.left_award_list = {}
	for i = 1, self.item_num do
		self.left_award_list[i] = MsgAdapter.ReadUInt()
	end
end

-- 下发开服活动竞技档次信息
SCOpenServerAcitivityAllSportsInfo = SCOpenServerAcitivityAllSportsInfo or BaseClass(BaseProtocolStruct)
function SCOpenServerAcitivityAllSportsInfo:__init()
	self:InitMsgType(139, 49)
	self.activity_num = 0
	self.sports_data_list = {}
end

function SCOpenServerAcitivityAllSportsInfo:Decode()
	self.activity_num = MsgAdapter.ReadUChar()
	self.sports_data_list = {}
	for i = 1, self.activity_num do
		self.sports_data_list[i] = {}
		self.sports_data_list[i].sports_type = MsgAdapter.ReadUChar()
		self.sports_data_list[i].receive_state = MsgAdapter.ReadUInt()
	end
end

-- 下发开服活动单个竞技档次信息
SCOpenServerAcitivitySportsInfo = SCOpenServerAcitivitySportsInfo or BaseClass(BaseProtocolStruct)
function SCOpenServerAcitivitySportsInfo:__init()
	self:InitMsgType(139, 50)
	self.sports_type = 0
	self.receive_state = 0
end

function SCOpenServerAcitivitySportsInfo:Decode()
	self.sports_type = MsgAdapter.ReadUChar()
	self.receive_state = MsgAdapter.ReadUInt()
end

-- 下发开服活动竞技榜信息
SCOpenServerAcitivitySportsListInfo = SCOpenServerAcitivitySportsListInfo or BaseClass(BaseProtocolStruct)
function SCOpenServerAcitivitySportsListInfo:__init()
	self:InitMsgType(139, 51)
	self.sports_type = 0
	self.sports_num = 0
	self.rank_data = {}
	self.my_rank = 0
end

function SCOpenServerAcitivitySportsListInfo:Decode()
	self.sports_type = MsgAdapter.ReadUChar()
	self.sports_num = MsgAdapter.ReadUChar()
	self.rank_data = {}
	for i = 1, self.sports_num do
		self.rank_data[i] = {}
		self.rank_data[i].rank = MsgAdapter.ReadUChar()
		self.rank_data[i].fraction = MsgAdapter.ReadUInt()
		self.rank_data[i].name = MsgAdapter.ReadStr()
	end
	self.my_rank = MsgAdapter.ReadUChar()
end

-- 下发开服活动幸运抽奖结果
SCOpenServerAcitivityDrawResult = SCOpenServerAcitivityDrawResult or BaseClass(BaseProtocolStruct)
function SCOpenServerAcitivityDrawResult:__init()
	self:InitMsgType(139, 52)
	self.draw_index = 0
	self.draw_left_times = 0
	self.award_pool_index = 0
end

function SCOpenServerAcitivityDrawResult:Decode()
	self.draw_index = MsgAdapter.ReadUChar()
	self.draw_left_times = MsgAdapter.ReadUInt()
	self.award_pool_index = MsgAdapter.ReadUShort()
end

-- 下发开服活动幸运抽奖信息
SCOpenServerAcitivityDrawInfo = SCOpenServerAcitivityDrawInfo or BaseClass(BaseProtocolStruct)
function SCOpenServerAcitivityDrawInfo:__init()
	self:InitMsgType(139, 53)
	self.draw_left_times = 0
	self.award_pool_index = 0
end

function SCOpenServerAcitivityDrawInfo:Decode()
	self.draw_left_times = MsgAdapter.ReadUInt()
	self.award_pool_index = MsgAdapter.ReadUShort()
end

-- 下发开服活动幸运抽奖全服记录
SCOpenServerAcitivityDrawServerRecording = SCOpenServerAcitivityDrawServerRecording or BaseClass(BaseProtocolStruct)
function SCOpenServerAcitivityDrawServerRecording:__init()
	self:InitMsgType(139, 54)
	self.logs_num = 0
	self.log_list = {}
end

function SCOpenServerAcitivityDrawServerRecording:Decode()
	self.logs_num = MsgAdapter.ReadUChar()
	self.log_list = {}
	for i = 1, self.logs_num do
		self.log_list[i] = {}
		self.log_list[i].item_id = MsgAdapter.ReadUShort()
		self.log_list[i].item_type = MsgAdapter.ReadUChar()
		self.log_list[i].player_name = MsgAdapter.ReadStr()
	end
end

-- 接收发现boss信息 请求(139, 45)
SCFindBossInfo = SCFindBossInfo or BaseClass(BaseProtocolStruct)
function SCFindBossInfo:__init()
	self:InitMsgType(139, 55)
	self.type = 0 -- 事件类型, 1获取信息, 2抽取数据
	self.times = 0 -- 当天剩余次数
	self.boss_index = 0 -- 上次抽取的boss索引, 0为跨天清除, 可抽取
	self.extract_time = 0 -- 下次可抽取的倒计时
	self.enter_time = 0 -- 进入boss场景倒计时
	self.last_time_lv = 0 -- 上次抽取时的等级
	self.last_time_zs = 0 -- 上次抽取时的转生
	self.client_time = 0
end

function SCFindBossInfo:Decode()
	self.type = MsgAdapter.ReadUChar()
	self.times = MsgAdapter.ReadUChar()
	self.boss_index = MsgAdapter.ReadUChar()
	self.extract_time = MsgAdapter.ReadUInt()
	self.enter_time = MsgAdapter.ReadUInt()
	self.last_time_lv = MsgAdapter.ReadUShort()
	self.last_time_zs = MsgAdapter.ReadUShort()
	self.client_time = Status.NowTime
end

-- 全部boss提醒信息
SCAllTypeBossFlagInfo = SCAllTypeBossFlagInfo or BaseClass(BaseProtocolStruct)
function SCAllTypeBossFlagInfo:__init()
	self:InitMsgType(139, 57)
	self.flag_list = {}
end

function SCAllTypeBossFlagInfo:Decode()
	self.flag_list = {}
	local len = MsgAdapter.ReadInt()
	for i = 1, len, 1 do
		self.flag_list[i] = MsgAdapter.ReadLL()
	end
end


-- 开服活动消费排行处理(139, 58)
SCConsumeRankInfo = SCConsumeRankInfo or BaseClass(BaseProtocolStruct)
function SCConsumeRankInfo:__init()
	self:InitMsgType(139, 58)
	self.tag = 0 -- 领取参与奖标记, 1成功 			
	self.yb_num = 0 -- 消费的元宝数
	self.rank_list = {} -- 排名
end

function SCConsumeRankInfo:Decode()
	self.tag = MsgAdapter.ReadInt()
	self.yb_num = MsgAdapter.ReadInt()
	self.rank_list = {}
	for i = 1, MsgAdapter.ReadUChar() do 
		local index = MsgAdapter.ReadUChar()
		self.rank_list[index] = {
			rank = index,
			rank_count = MsgAdapter.ReadInt(),
			role_name = MsgAdapter.ReadStr(),
		}
	end
	self.my_rank = MsgAdapter.ReadUChar()
end

-- 接收合服特惠礼包信息(请求 139 49)
SCMergeServerDiscountInfo = SCMergeServerDiscountInfo or BaseClass(BaseProtocolStruct)
function SCMergeServerDiscountInfo:__init()
	self:InitMsgType(139, 63)
	self.day = 0 -- 合服第几天
	self.type = 0 -- 配置类型id
	self.buy_times_list = {} -- 每个档次的购买次数
end

function SCMergeServerDiscountInfo:Decode()
	self.day = MsgAdapter.ReadUChar()
	self.type = MsgAdapter.ReadUChar()
	for i = 1, 4 do
		self.buy_times_list[i] = MsgAdapter.ReadUChar()
	end
end

-- 开服活动充值排行处理(139, 64)
SCRechargeRankInfo = SCRechargeRankInfo or BaseClass(BaseProtocolStruct)
function SCRechargeRankInfo:__init()
	self:InitMsgType(139, 64)
	self.tag = 0 -- 领取参与奖标记, 1成功 			
	self.yb_num = 0 -- 充值的元宝数
	self.rank_list = {} -- 排名
end

function SCRechargeRankInfo:Decode()
	self.tag = MsgAdapter.ReadInt()
	self.yb_num = MsgAdapter.ReadInt()
	self.rank_list = {}
	for i = 1, MsgAdapter.ReadUChar() do 
		local index = MsgAdapter.ReadUChar()
		self.rank_list[index] = {
			rank = index,
			rank_count = MsgAdapter.ReadInt(),
			role_name = MsgAdapter.ReadStr(),
		}
	end
	self.my_rank = MsgAdapter.ReadUChar()
end

-- 接收特戒变更信息
SCSpecialRingInfo = SCSpecialRingInfo or BaseClass(BaseProtocolStruct)
function SCSpecialRingInfo:__init()
	self:InitMsgType(139, 65)
	self.slot = 0
	self.type = 0
	self.index = 0
end

function SCSpecialRingInfo:Decode()
	self.slot = MsgAdapter.ReadUChar()
	self.type = MsgAdapter.ReadUChar()
	self.index = MsgAdapter.ReadUChar()
	self.series = CommonReader.ReadSeries()
end

-- 接收守护神装商铺数据
SCGuardShopData = SCGuardShopData or BaseClass(BaseProtocolStruct)
function SCGuardShopData:__init()
	self:InitMsgType(139, 70)
	self.left_time = 0 		-- 商铺刷新倒计时
	self.now_time = 0
	self.shop_type = 0 		-- 商铺类型, 从1开始		
	self.item_list = {}		-- 商铺物品列表
end

function SCGuardShopData:Decode()
	self.left_time = MsgAdapter.ReadUInt()
	self.now_time = Status.NowTime
	self.shop_type = MsgAdapter.ReadUChar()
	local count = MsgAdapter.ReadUChar()
	local list = {}
	for i = 1, count do
		data = {}
		data.shop_index = MsgAdapter.ReadUChar()
		data.cfg_index = MsgAdapter.ReadUShort()
		data.buy_count = MsgAdapter.ReadUShort()
		list[i] = data
	end
	self.item_list = list
end

--======切割==========
--升级切割结果
SCUpgradeQieGeResult = SCUpgradeQieGeResult or BaseClass(BaseProtocolStruct)
function SCUpgradeQieGeResult:__init( ... )
	self:InitMsgType(139, 72)
	self.qiege_level = 0
end

function SCUpgradeQieGeResult:Decode( ... )
	self.qiege_level = MsgAdapter.ReadUShort()
end

--所有切割数据
SCAllQieGeData= SCAllQieGeData or BaseClass(BaseProtocolStruct)
function SCAllQieGeData:__init()
	self:InitMsgType(139, 73)
	self.qiege_level = 0
	self.reweard_sign = 0  -- 按位取

	self.qiege_list = {}
	self.qiege_task_list = {}
end

function SCAllQieGeData:Decode()
	self.qiege_level = MsgAdapter.ReadUShort()
	self.reweard_sign = MsgAdapter.ReadLL()
	self.count = MsgAdapter.ReadUChar()
	self.qiege_list = {}
	for i = 1, self.count  do
		local v = {}
		v.boss_num = MsgAdapter.ReadUChar()
		v.item_num = MsgAdapter.ReadUShort()
		self.qiege_list[i] =v
	end
	self.qiege_task_list  = {}
	self.count1 = MsgAdapter.ReadUChar()
	for i = 1, self.count1 do
		local v = {}
		v.task_id = MsgAdapter.ReadUChar()
		v.boss_num = MsgAdapter.ReadUChar()
		self.qiege_task_list[i] = v
	end
end

--升级切割神兵结果

SCUpgradeQieGeShenbinResult = SCUpgradeQieGeShenbinResult or BaseClass(BaseProtocolStruct)
function SCUpgradeQieGeShenbinResult:__init( ... )
	self:InitMsgType(139,74)
	self.index = 0
	self.qiege_shenbin_level = 0
end

function SCUpgradeQieGeShenbinResult:Decode()
	self.index = MsgAdapter.ReadChar()
	self.qiege_shenbin_level = MsgAdapter.ReadChar()
end



SCQieGeShenBinData = SCQieGeShenBinData or BaseClass(BaseProtocolStruct)
function SCQieGeShenBinData:__init( ... )
	self:InitMsgType(139, 75)
	self.qiege_shenbin_list = {}
end

function SCQieGeShenBinData:Decode( )
	self.count = MsgAdapter.ReadChar()
	self.qiege_shenbin_list = {}
	for i = 1, self.count do
		local  v = {}
		v.index = MsgAdapter.ReadChar()
		v.qiege_shenbin_level = MsgAdapter.ReadChar()
		self.qiege_shenbin_list[i] = v
	end

end


-- 下发分享运势
SCFortuneShareData = SCFortuneShareData or BaseClass(BaseProtocolStruct)
function SCFortuneShareData:__init()
	self:InitMsgType(139, 83)
	self.share_id = 0 			-- uint 分享者id
	self.share_name = 0 		-- string 分享者名字
	self.fortune_lv = 0 		-- uchar 运势等级
end

function SCFortuneShareData:Decode()
	self.share_id = MsgAdapter.ReadUInt()
	self.share_name = MsgAdapter.ReadStr()
	self.fortune_lv = MsgAdapter.ReadUChar()
end

--=======切割结束======

-- 每日充值礼包领取状态
SCChargeEveryDayState = SCChargeEveryDayState or BaseClass(BaseProtocolStruct)
function SCChargeEveryDayState:__init()
	self:InitMsgType(139, 89)
	self.receive_state = 0 		--从0开始，每1位一个标识0和1；0为未领取，1为已领取
	self.today_charge_money = 0	--(uint)今天累积充值的元宝数
end

function SCChargeEveryDayState:Decode()
	self.receive_state = MsgAdapter.ReadUInt()
	self.today_charge_money = MsgAdapter.ReadUInt()
end

-- 每日充值宝箱领取状态
SCChargeEveryDayTreasureState = SCChargeEveryDayTreasureState or BaseClass(BaseProtocolStruct)
function SCChargeEveryDayTreasureState:__init()
	self:InitMsgType(139, 90)
	self.data_type = 0 		-- 下发数据类型 1为宝箱信息，2为领取奖励索引
	self.treasure_total_grade = 0
	self.charge_day_list = {}
	self.award_index = 0
end

function SCChargeEveryDayTreasureState:Decode()
	self.data_type = MsgAdapter.ReadUChar()
	if self.data_type == 1 then
		self.treasure_total_grade = MsgAdapter.ReadUChar()
		for i = 1, self.treasure_total_grade do
			local charge_day = MsgAdapter.ReadUChar()
			self.charge_day_list[i] = charge_day
		end
	else
		self.award_index = MsgAdapter.ReadUChar()
	end
end

-- 首充礼包信息
SCFirstChargeState = SCFirstChargeState or BaseClass(BaseProtocolStruct)
function SCFirstChargeState:__init()
	self:InitMsgType(139, 92)
	self.first_charge_state = 0  --0-7位存档次, 8-10位是否领取
end

function SCFirstChargeState:Decode()
	self.first_charge_state = MsgAdapter.ReadUInt()
end

-- 跨天登陆
SCCrossLogin = SCCrossLogin or BaseClass(BaseProtocolStruct)
function SCCrossLogin:__init()
	self:InitMsgType(139, 93)
	self.is_cross_login = 0  --1 为跨天 0为非跨天
end

function SCCrossLogin:Decode()
	self.is_cross_login = MsgAdapter.ReadUChar()
end

--下发离线挂机处理结果
SCTQOfflineGuajiInfo = SCTQOfflineGuajiInfo or BaseClass(BaseProtocolStruct)
function SCTQOfflineGuajiInfo:__init()
	self:InitMsgType(139, 94)
	self.tq_exp_num = 0
	self.offline_time = 0
end

function SCTQOfflineGuajiInfo:Decode()
	self.tq_exp_num = MsgAdapter.ReadUInt()
	self.offline_time = MsgAdapter.ReadUInt()
end


--====下发充值红包数据
SCChargeRedEnvlopeData = SCChargeRedEnvlopeData or BaseClass(BaseProtocolStruct)
function SCChargeRedEnvlopeData:__init( ... )
	self:InitMsgType(139, 95)
	self.zs_num = 0
	self.reward_flag = 0
	self.first_charge = 0
	self.cur_level = 0
	self.red_envlope_gold = 0
	self.record = "" 
end


function SCChargeRedEnvlopeData:Decode()
	self.zs_num = MsgAdapter.ReadUInt()
	self.reward_flag = MsgAdapter.ReadUInt()
	self.first_charge = MsgAdapter.ReadUChar()
	self.cur_level = MsgAdapter.ReadUChar()
	self.red_envlope_gold = MsgAdapter.ReadUInt()
	self.record = MsgAdapter.ReadStr()
end


-- 天降红包
SCRedEnvelopes = SCRedEnvelopes or BaseClass(BaseProtocolStruct)
function SCRedEnvelopes:__init()
	self:InitMsgType(139, 100)
	self.view_type = 0                 --1为天降红包，2为屌丝逆袭
	self.sign = 0
end

function SCRedEnvelopes:Decode()
	self.view_type = MsgAdapter.ReadUChar()
	self.sign = MsgAdapter.ReadUInt()
end

--系统开启tips
SCSystemOpenTips = SCSystemOpenTips or BaseClass(BaseProtocolStruct)
function SCSystemOpenTips:__init()
	self:InitMsgType(139, 102)
	self.system_funtion_count = {}
end

function SCSystemOpenTips:Decode()
	local count = MsgAdapter.ReadUChar()
	for i=1, count do
		local v = {}
		v.system_funtion_grade = MsgAdapter.ReadUChar()
		self.system_funtion_count[i] = v
	end
end

--获取活动tips
SCGetAcitivityTips = SCGetAcitivityTips or BaseClass(BaseProtocolStruct)
function SCGetAcitivityTips:__init()
	self:InitMsgType(139, 103)
	self.prompt = ""  
	self.tips_content = ""
end

function SCGetAcitivityTips:Decode()
	self.prompt = MsgAdapter.ReadStr()
	self.tips_content = MsgAdapter.ReadStr()
end

--复活是否成功信息
SCFuHuoBoolScucessInformation = SCFuHuoBoolScucessInformation or BaseClass(BaseProtocolStruct)
function SCFuHuoBoolScucessInformation:__init()
	self:InitMsgType(139, 105)
	self.bool_success = 0
end

function SCFuHuoBoolScucessInformation:Decode()
	self.bool_success = MsgAdapter.ReadUChar()
end

--服务端弹出提示框
SCServerOpenAlert = SCServerOpenAlert or BaseClass(BaseProtocolStruct)
function SCServerOpenAlert:__init()
	self:InitMsgType(139, 107)
	self.type = 1
	self.content = ""
end

function SCServerOpenAlert:Decode()
	self.type = MsgAdapter.ReadUChar()
	self.content = MsgAdapter.ReadStr()
end

--下发boss召唤令信息
SCBossCallInfo = SCBossCallInfo or BaseClass(BaseProtocolStruct)
function SCBossCallInfo:__init()
	self:InitMsgType(139, 113)
	self.is_death = 0
	self.boss_id = 0
	self.time = 0
end

function SCBossCallInfo:Decode()
	self.is_death = MsgAdapter.ReadUChar()
	self.boss_id = MsgAdapter.ReadUInt()
	self.time = MsgAdapter.ReadUInt()
end

-- 超级VIP下发
SCSVipGetInfo = SCSVipGetInfo or BaseClass(BaseProtocolStruct)
function SCSVipGetInfo:__init()
	self:InitMsgType(139, 116)
	self.spid = 0
	self.type = 0                   -- 1.请求标记 2.提交个人资料结果
	self.result = 0
end

function SCSVipGetInfo:Decode()
	self.spid = MsgAdapter.ReadUChar()
	self.type = MsgAdapter.ReadUChar()
	self.result = MsgAdapter.ReadUChar()
end

--转生成功下发
SCReincarnationScuccess = SCReincarnationScuccess or BaseClass(BaseProtocolStruct)
function SCReincarnationScuccess:__init()
	self:InitMsgType(139, 118)
	self.reincarnation_success = 0   --(uchar)0转生成功, 1配置错误, 2玩家条件不符号
	self.left_points = 0   --剩余属性点
end

function SCReincarnationScuccess:Decode()
	self.reincarnation_success = MsgAdapter.ReadUChar()
	self.left_points = MsgAdapter.ReadUInt()
end

--下发7天登陆领取信息
SCSevenDaysLoadingGetInformation = SCSevenDaysLoadingGetInformation or BaseClass(BaseProtocolStruct)
function SCSevenDaysLoadingGetInformation:__init()
	self:InitMsgType(139, 120)
	self.add_up_days = 0   
	self.kind_number_rewards = {}
end

function SCSevenDaysLoadingGetInformation:Decode()
	self.add_up_days = MsgAdapter.ReadUChar()
	local count = MsgAdapter.ReadUChar()
	for i=1, count do
		self.kind_number_rewards[i] = MsgAdapter.ReadUChar()  --0不能领取, 1可以领取, 2已领取
	end
end

--下发今天剩余复活次数
SCTodayRemainTimesFuhuo = SCTodayRemainTimesFuhuo or BaseClass(BaseProtocolStruct)
function SCTodayRemainTimesFuhuo:__init()
	self:InitMsgType(139, 122)
	self.remain_fuhuo_times = 0   --(uchar)0转生成功, 1配置错误, 2玩家条件不符号
end

function SCTodayRemainTimesFuhuo:Decode()
	self.remain_fuhuo_times = MsgAdapter.ReadUChar()
end

-- 充值信息
SCChargeInfoData = SCChargeInfoData or BaseClass(BaseProtocolStruct)
function SCChargeInfoData:__init()
	self:InitMsgType(139, 123)
	self.day_charge_gold_num = 0		-- 今天充值元宝数
	self.day_consume_gold_num = 0		-- 今天消费元宝数
end

function SCChargeInfoData:Decode()
	self.day_charge_gold_num = MsgAdapter.ReadUInt()
	self.day_consume_gold_num = MsgAdapter.ReadUInt()
end

--下发当前副本怪物数
SCFubenMonsterNum = SCFubenMonsterNum or BaseClass(BaseProtocolStruct)
function SCFubenMonsterNum:__init()
	self:InitMsgType(139, 125)
	self.fuben_id = 0
	self.cur_monster_num = 0
	-- self.total_monster_num = 0
end

function SCFubenMonsterNum:Decode()
	self.fuben_id = MsgAdapter.ReadUChar()
	self.cur_monster_num = MsgAdapter.ReadUChar()
	-- self.total_monster_num = MsgAdapter.ReadUChar()
end

--下发今天剩余天关剩余次数
SCTodayRemainZetaTauriTimes = SCTodayRemainZetaTauriTimes or BaseClass(BaseProtocolStruct)
function SCTodayRemainZetaTauriTimes:__init()
	self:InitMsgType(139, 127)
	self.remain_times = 0   --(uchar)0转生成功, 1配置错误, 2玩家条件不符号
end

function SCTodayRemainZetaTauriTimes:Decode()
	self.remain_times = MsgAdapter.ReadUChar()
end

--领取下发微信礼包
SCGetWeixinGift = SCGetWeixinGift or BaseClass(BaseProtocolStruct)
function SCGetWeixinGift:__init()
	self:InitMsgType(139, 131)
end

function SCGetWeixinGift:Decode()
end

-- 经验炼制次数下发
SCGetRefiningExpMsg = SCGetRefiningExpMsg or BaseClass(BaseProtocolStruct)
function SCGetRefiningExpMsg:__init()
	self:InitMsgType(139, 135)
	self.refining_exp_count = 0
	self.can_to_level = 0
	self.is_get_award = 0
	self.exp_gold = 0
	self.award_gold = 0
	self.record_list = ""
end

function SCGetRefiningExpMsg:Decode()
	self.refining_exp_count = MsgAdapter.ReadUChar()
	self.can_to_level = MsgAdapter.ReadUChar()
	-- self.is_get_award = MsgAdapter.ReadUChar()
	-- self.exp_gold = MsgAdapter.ReadInt()
	-- self.award_gold = MsgAdapter.ReadInt()
	-- self.record_list = MsgAdapter.ReadStr()
end

-- 下发玩家领取开服活动奖励结果
SCGetOpenServerAcitivityReward = SCGetOpenServerAcitivityReward or BaseClass(BaseProtocolStruct)
function SCGetOpenServerAcitivityReward:__init()
	self:InitMsgType(139, 136)
	self.act_type = 0 				-- (byte)活动类型, (1等级竞技  2翅膀竞技  3宝石竞技  4圣珠竞技  5累积充值  6冠印竞技  7战将竞技  8强化竞技)
	self.reward_index = 0 			-- (byte)活动奖励索引, 从 1 开始
	self.result = 0 				-- (byte)是否成功, 0失败，1成功, 只有成功才下发，所以这里固定为1
	self.surplus_places = 0 		-- (int)已经领取的名额,-1 为不限制
	self.receive_sign_1 = 0 		-- (uint)玩家领取标志1, 每个活动分配了 8 位
	self.receive_sign_2 = 0 		-- (uint)玩家领取标志2, 每个活动分配了 8 位
end

function SCGetOpenServerAcitivityReward:Decode()
	self.act_type = MsgAdapter.ReadUChar()
	self.reward_index = MsgAdapter.ReadUChar()
	self.result = MsgAdapter.ReadUChar()
	self.surplus_places = MsgAdapter.ReadInt()
	self.receive_sign_1 = MsgAdapter.ReadUInt()
	self.receive_sign_2 = MsgAdapter.ReadUInt()
end

-- 下发开服活动奖励信息
SCGetOpenServerAcitivityRewardMsg = SCGetOpenServerAcitivityRewardMsg or BaseClass(BaseProtocolStruct)
function SCGetOpenServerAcitivityRewardMsg:__init()
	self:InitMsgType(139, 137)
	self.surplus_places_list = {} 	-- (ushort)领取名额, 每个活动分配了 8 名额
	self.receive_sign_1 = 0 		-- (uint)玩家领取标志1, 每个活动分配了 8 位
	self.receive_sign_2 = 0 		-- (uint)玩家领取标志2, 每个活动分配了 8 位
end

function SCGetOpenServerAcitivityRewardMsg:Decode()
	self.surplus_places_list = {}
	for i=1, 64 do
		self.surplus_places_list[#self.surplus_places_list + 1] = MsgAdapter.ReadUShort()
	end
	self.receive_sign_1 = MsgAdapter.ReadUInt()
	self.receive_sign_2 = MsgAdapter.ReadUInt()
end

-- 副本进入次数信息
SCFuBenEnterInfo = SCFuBenEnterInfo or BaseClass(BaseProtocolStruct)
function SCFuBenEnterInfo:__init()
	self:InitMsgType(139, 138)
	self.fuben_list = {}
end

function SCFuBenEnterInfo:Decode()
	self.fuben_list = {}
	for i=1, MsgAdapter.ReadUChar() do
		local fuben_id = MsgAdapter.ReadUShort()
		self.fuben_list[fuben_id] = {
			enter_time = MsgAdapter.ReadUChar(),
			cd_time = MsgAdapter.ReadUInt(),
		}
	end
end

-- 副本通关
SCFinishFuBen = SCFinishFuBen or BaseClass(BaseProtocolStruct)
function SCFinishFuBen:__init()
	self:InitMsgType(139, 139)
	self.fuben_id = 0
end

function SCFinishFuBen:Decode()
	self.fuben_id = MsgAdapter.ReadUChar()
end

-- 领取通关奖励结果
SCRecFuBenRewardRes = SCRecFuBenRewardRes or BaseClass(BaseProtocolStruct)
function SCRecFuBenRewardRes:__init()
	self:InitMsgType(139, 140)
	self.fuben_id = 0
	self.result = 0				-- 1成功
end

function SCRecFuBenRewardRes:Decode()
	self.fuben_id = MsgAdapter.ReadUChar()
	self.result = MsgAdapter.ReadUChar()
end

SCCailiaoFubenInfo = SCCailiaoFubenInfo or BaseClass(BaseProtocolStruct)
function SCCailiaoFubenInfo:__init()
	self:InitMsgType(139, 141)
	self.fuben_event_id = 0
	self.is_scuess = 0
	self.fuben_info_data = {}
end

function SCCailiaoFubenInfo:Decode()
	self.fuben_event_id = MsgAdapter.ReadUChar()
	self.fuben_info_data = {}
	if self.fuben_event_id == 4 then
		self.is_scuess = MsgAdapter.ReadUChar()
	else
		local c = MsgAdapter.ReadUChar()
		for i=1,c do
			local info = {}
			info.static_id = MsgAdapter.ReadUChar()				--索引
			info.challge_count = MsgAdapter.ReadUChar()		--挑战次数
			info.sweep_count = MsgAdapter.ReadUChar()		--扫荡次数
			info.vip_count = MsgAdapter.ReadUChar()			--vip次数
			info.is_lingqu = MsgAdapter.ReadUChar()			--是否领取
			table.insert(self.fuben_info_data,info)
		end
	end
end

--下发新每日充值礼包数据
SCEveryDayChrgeGiftData = SCEveryDayChrgeGiftData or BaseClass(BaseProtocolStruct)
function SCEveryDayChrgeGiftData:__init()
	self:InitMsgType(139, 142)
	self.gift_kind_number = {}
end

function SCEveryDayChrgeGiftData:Decode()
	local count = MsgAdapter.ReadUChar()
	for i=1,count do
		local v = {}
		v.state_get = MsgAdapter.ReadUChar() -- 0可领取, 1不可领取, 2已领取
		self.gift_kind_number[i] = v
	end
end

--下发装备升级结果
SCEuipmentUpgradeResult = SCEuipmentUpgradeResult or BaseClass(BaseProtocolStruct)
function SCEuipmentUpgradeResult:__init()
	self:InitMsgType(139, 145)
	self.equipment_type  = 0 --玉佩=1、护盾=2、宝石=3、圣珠=4、麻痹戒指=5、护身戒指=6、复活戒指=7、勋章=8
	self.upgrade_grade = 0
end

function SCEuipmentUpgradeResult:Decode()
	self.equipment_type = MsgAdapter.ReadUChar() 
	self.upgrade_grade = MsgAdapter.ReadUChar() 
end

-- 下发材料副本一键完成
SCFubenOneKeyCpltResult = SCFubenOneKeyCpltResult or BaseClass(BaseProtocolStruct)
function SCFubenOneKeyCpltResult:__init()
	self:InitMsgType(139, 147)
	self.result = 0
	self.fuben_index = 0
end

function SCFubenOneKeyCpltResult:Decode()
	self.result = MsgAdapter.ReadUChar()
	self.fuben_index = MsgAdapter.ReadUChar()
end

--下发昨天未完成的任务信息
SCYestodayUnfinishedTaskInformation = SCYestodayUnfinishedTaskInformation or BaseClass(BaseProtocolStruct)
function SCYestodayUnfinishedTaskInformation:__init()
	self:InitMsgType(139, 155)
	self.information_id = 0
	self.six_kind_task  = {}
end

function SCYestodayUnfinishedTaskInformation:Decode()
	self.information_id = MsgAdapter.ReadUChar() 
	local count = MsgAdapter.ReadUChar()
	for i=1,count do
		local v = {}
		v.finish_task_time = MsgAdapter.ReadUChar()
		self.six_kind_task[i] = v
	end
end

--下发王陵瘴气
SCRoyalTombsMiasma = SCRoyalTombsMiasma or BaseClass(BaseProtocolStruct)
function SCRoyalTombsMiasma:__init()
	self:InitMsgType(139, 160)
	self.Miasma_value = 0 --瘴气值  

end

function SCRoyalTombsMiasma:Decode()
	self.Miasma_value = MsgAdapter.ReadUChar() 
end

--下发王陵数据
SCRoyalTombsData = SCRoyalTombsData or BaseClass(BaseProtocolStruct)
function SCRoyalTombsData:__init()
	self:InitMsgType(139, 161)
	self.enter_royaltombs_time = 0  --进入王陵次数
end

function SCRoyalTombsData:Decode()
	self.enter_royaltombs_time = MsgAdapter.ReadUChar() 
end

--衣橱
SCWardrobe = SCWardrobe or BaseClass(BaseProtocolStruct)
function SCWardrobe:__init()
	self:InitMsgType(139, 162)
	self.information_id = 0  --1激活时装, 2穿上时装, 3脱下时装, 4升级, 5隐藏时装外观
	self.bool_success = 0   --1成功, 失败不返回
end

function SCWardrobe:Decode()
	self.information_id = MsgAdapter.ReadUChar() 
	self.bool_success = MsgAdapter.ReadUChar() 
end

-- 接收试炼关卡信息(139, 164)
SCTrialData = SCTrialData or BaseClass(BaseProtocolStruct)
function SCTrialData:__init()
	self:InitMsgType(139, 164)
	self.guan_num = 0 -- 已通关关卡数
	self.add_awards_tag = 0 -- 领取了奖励的关卡
	self.initial_hang_up_time = 0 -- 初始挂机时间
	self.all_hang_up_times = 0 -- 累计挂机时长(秒)
	self.awards = {}
end

function SCTrialData:Decode()
	self.guan_num = MsgAdapter.ReadUShort() 
	self.add_awards_tag = MsgAdapter.ReadUInt()
	self.initial_hang_up_time = MsgAdapter.ReadUInt()
	self.all_hang_up_times = MsgAdapter.ReadUInt()
	local count  = MsgAdapter.ReadUChar()
	self.awards = {}
	for i = 1, count do
		self.awards[i] = {
			type = MsgAdapter.ReadUChar(),
			item_id = MsgAdapter.ReadUShort(),
			num = MsgAdapter.ReadUInt(),
			is_bind = MsgAdapter.ReadUChar(),
		}
	end
end

--下发今天已兑换转生次数 ExchangeCultivationRemainingTime
SCExchangeCultivationRemainingTime = SCExchangeCultivationRemainingTime or BaseClass(BaseProtocolStruct)
function SCExchangeCultivationRemainingTime:__init()
	self:InitMsgType(139, 166)
	self.cultivation_remaining_time = 0  
end

function SCExchangeCultivationRemainingTime:Decode()
	self.cultivation_remaining_time = MsgAdapter.ReadUChar() 
end

--累计签到领奖标记
SCAddSignAwardMark = SCAddSignAwardMark or BaseClass(BaseProtocolStruct)
function SCAddSignAwardMark:__init()
	self:InitMsgType(139, 168)
	self.add_sign_award_mark = 0 
end

function SCAddSignAwardMark:Decode()
	self.add_sign_award_mark = MsgAdapter.ReadUInt()
end

--再签一次到标记
SCAgainSignOneTimemark = SCAgainSignOneTimemark or BaseClass(BaseProtocolStruct)
function SCAgainSignOneTimemark:__init()
	self:InitMsgType(139, 169)
	self.again_sign = 0  
end

function SCAgainSignOneTimemark:Decode()
	self.again_sign = MsgAdapter.ReadUChar()
end

--勇者闯关
SCBraveCheckpoints = SCBraveCheckpoints or BaseClass(BaseProtocolStruct)
function SCBraveCheckpoints:__init()
	self:InitMsgType(139, 170)
	self.msg_id = 0
	self.passed_gate = 0 		-- 通过的总关数
	self.left_sweep_times = 0 	-- 剩余扫荡次数
	self.pass_state = -1       	-- 0闯关失败(玩家死亡)，1超时，2闯关成功，3完成所有关
end

function SCBraveCheckpoints:Decode()
	self.msg_id = MsgAdapter.ReadUChar()
	if 1 == self.msg_id then
  		self.passed_gate = MsgAdapter.ReadUChar() 
  		self.left_sweep_times = 3 - MsgAdapter.ReadUChar() 
	elseif 2 == self.msg_id then 
        self.pass_state = MsgAdapter.ReadUChar()
    end
end

--称号
-- SCTitle = SCTitle or BaseClass(BaseProtocolStruct)
-- function SCTitle:__init()
-- 	self:InitMsgType(139, 171)
-- 	self.title_sign = 0    --称号标记
-- 	self.loading_days = 0 
-- 	self.xunbao_add_consume_gold = 0  --探索宝藏累计消费达到多少元宝
-- 	self.get_gold_50000 =  0   --累计获得500000绑定元宝
-- 	self.faction_battle_kill_people = 0  --阵营战击杀人数
-- 	self.consume_gold_count = 0  --消耗元宝数
-- end

-- function SCTitle:Decode()
-- 	self.title_sign = MsgAdapter.ReadUInt() 
-- 	self.loading_days = MsgAdapter.ReadInt() 
-- 	self.xunbao_add_consume_gold = MsgAdapter.ReadUInt() 
-- 	self.get_gold_50000 = MsgAdapter.ReadUInt() 
-- 	self.faction_battle_kill_people = MsgAdapter.ReadUInt() 
-- 	self.consume_gold_count = MsgAdapter.ReadUInt() 
-- end

--理财处理
SCFinancing = SCFinancing or BaseClass(BaseProtocolStruct)
function SCFinancing:__init()
	self:InitMsgType(139, 172)
	self.msg_id = 0
	self.financing_flag = 0 
	self.buy_num = 0
end

function SCFinancing:Decode()
	self.msg_id = MsgAdapter.ReadInt() 
	self.financing_flag = MsgAdapter.ReadInt() 
	self.buy_num = MsgAdapter.ReadInt()
end

-- 开服活动:下发特惠礼包信息
SCGetOpenServerGift = SCGetOpenServerGift or BaseClass(BaseProtocolStruct)
function SCGetOpenServerGift:__init()
	self:InitMsgType(139, 174)
	self.buy_level_list = {} 		-- (byte)购买档次， 0为还没有购买
	self.gift_num = 0
end

function SCGetOpenServerGift:Decode()
	self.buy_level_list = {}
	self.gift_num = MsgAdapter.ReadUChar()
	for i=1,self.gift_num do
		local list = {
			gift_id = MsgAdapter.ReadUChar(),
			gift_level = MsgAdapter.ReadUChar(),
		}
		table.insert(self.buy_level_list, list)
	end
end

-- 开服活动:下发BOSS竞技信息
SCGetBossMsg = SCGetBossMsg or BaseClass(BaseProtocolStruct)
function SCGetBossMsg:__init()
	self:InitMsgType(139, 175)
	self.kill_boss_mark = 0 		-- (uint)击杀BOSS标记， 4个BOSS一组
	self.get_reward_mark = 0 		-- (uint)领取标志
end

function SCGetBossMsg:Decode()
	self.kill_boss_mark = MsgAdapter.ReadUInt() 
	self.get_reward_mark = MsgAdapter.ReadUInt() 
end

-- 传送对话框
SCTransmitDialog = SCTransmitDialog or BaseClass(BaseProtocolStruct)
function SCTransmitDialog:__init()
	self:InitMsgType(139, 176)
	self.area_count = 0
	self.area_list = {}
end

function SCTransmitDialog:Decode()
	self.area_count = MsgAdapter.ReadUChar()
	self.area_list = {}

	for i = 1, self.area_count do
		local area_info = {
			title = MsgAdapter.ReadStr(),
			btn_count = MsgAdapter.ReadUChar(),
			btn_list = {},
		}

		for k = 1, area_info.btn_count do
			table.insert(area_info.btn_list, {
					area = i,
					index = k,
					type = MsgAdapter.ReadUChar(),
					scene_id = MsgAdapter.ReadInt(),
					btn_name = MsgAdapter.ReadStr(),
					func_name = MsgAdapter.ReadStr(),
					level = MsgAdapter.ReadUShort(),
					circle = MsgAdapter.ReadUChar(),
				})
		end

		table.insert(self.area_list, area_info)
	end
end

--获得祈福数据（下发）1
SCIssuePrayData = SCIssuePrayData or BaseClass(BaseProtocolStruct)
function SCIssuePrayData:__init()
	self:InitMsgType(139, 177)
	self.bind_gold_time = 0 		--(uchar)祈福绑金次数
	self.bind_yuan_time= 0	    	--(uchar)祈福绑元次数
end

function SCIssuePrayData:Decode()
	self.bind_gold_time = MsgAdapter.ReadUChar()
	self.bind_yuan_time = MsgAdapter.ReadUChar()
end

--下发离线挂机处理结果
SCOfflineGuajiInfo = SCOfflineGuajiInfo or BaseClass(BaseProtocolStruct)
function SCOfflineGuajiInfo:__init()
	self:InitMsgType(139, 178)
	self.msg_id = 0 		--(uchar) 消息类型Id ( 1开始在线挂机, 2领取离线挂机奖励, 4挂机信息, 5停止在线挂机) 
	self.offline_index = 0
	self.offline_time = 0
	self.results = 0
	self.award = {}
end

function SCOfflineGuajiInfo:Decode()
	self.offline_index = 0
	self.offline_time = 0
	self.results = 0
	self.award = {}

	self.msg_id = MsgAdapter.ReadUChar()
	if self.msg_id == OfflineData.REQ_ID.INFO then
		self.offline_time = MsgAdapter.ReadUInt()
		self.award[1] = MsgAdapter.ReadUInt()
		self.award[2] = MsgAdapter.ReadUInt()
		self.award[3] = MsgAdapter.ReadUInt()
		self.offline_index = MsgAdapter.ReadUChar()
		self.results = MsgAdapter.ReadUChar()
	else
		self.results = MsgAdapter.ReadUChar()
	end
end

--下发试炼奖励经验
SCExpAwardInfo = SCExpAwardInfo or BaseClass(BaseProtocolStruct)
function SCExpAwardInfo:__init()
	self:InitMsgType(139, 179)
	self.id = 0
	self.exp_num = 0
end

function SCExpAwardInfo:Decode()
	self.id = MsgAdapter.ReadUChar()
	self.exp_num = MsgAdapter.ReadUInt()
end

-- 接收其它总战力
SCOtherPower = SCOtherPower or BaseClass(BaseProtocolStruct)
function SCOtherPower:__init()
	self:InitMsgType(139, 181)
	self.rexue_power = 0 		-- 热血总战力 用于运营活动 22
	self.guard_equip_power = 0 	-- 守护总战力 用于运营活动 30
end

function SCOtherPower:Decode()
	self.rexue_power = MsgAdapter.ReadUInt()
	self.guard_equip_power = MsgAdapter.ReadUInt()
end

--下发精彩活动
SCActivityBrilliant = SCActivityBrilliant or BaseClass(BaseProtocolStruct)
function SCActivityBrilliant:__init()
	self:InitMsgType(139, 182)
	self.type = 0
	self.activity_num = 0
	self.cmd_id = 0
	self.act_id = 0
	self.activity_index = 0
	self.act_cfg = ""
	self.yaoqian_num = 0
	self.yaoqian_time = 0
	self.jilv = ""
	self.flush_time = 0
	self.item_num = 0
	self.item_list = {}
	self.sign = 0
	self.sign_2 = 0
	self.result = nil
	self.rank_num = 0
	self.rank = 0
	self.rank_name = 0 
	self.feed_gold = 0
	self.mine_feed_gold = 0
	self.mine_rank = 0
	self.jiejing_num = 0
	self.rank_list = {}
	self.xunbao_num = 0
	self.can_list = {}
	self.consum_gold = 0
	self.use_num = 0
	self.zp_record = ""
	self.spare_szxb_num = 0
	self.spare_xb_num = 0
	self.all_charge = 0
	self.lingqu_num = 0
	self.baozan_num = 0
	self.gift_list = {}
	self.mine_num = 0
	self.is_lingqu = 0
	self.hk_jiejing_num = 0
	self.hk_sign = 0
	-- 幸运有礼
	self.item_index = 0
	self.draw_num = 0
	self.buy_num = 0
	--元宝大转盘
	self.jackpot = 0
	self.jc_record = ""

	self.act_day = 0
	self.num_list = {}
	self.num_2_list = {}

	self.is_go = 0

	self.day_charge = 0
	self.lk_draw_num = 0
	self.all_num = 0

	self.fl_time_list = {}
	self.fl_qf_record = ""
	self.fl_gr_record = ""

	self.daily_charge = 0
	self.lingqu_times = {}
	self.sign_times = {}

	self.buy_level = 0
	self.is_exchange = 0
	self.cz_draw_num = 0
	self.record_54 = ""

	--许愿池
	self.information_id = 0
	self.state_get = 0 -- (uint)领取奖励标志(按位取)
	self.red_rope = 0 
	self.red_rope_count = 0
	self.red_rope_type = {}
	self.red_rope_level = 0

	--消费有礼
	self.lingqu_num_52 = 0

	--珍宝阁
	self.cabinet_flush_time = 0
	self.cabinet_num = 0
	self.cabinet_list = {}
	self.flush_times = 0
	self.flush_sign = 0

	--藏宝阁
	self.canbaoge_data = {}

	--极品兑换
	self.super_exc_list = {}

	--通天塔
	self.tower_level = 0
	self.draw_record = ""

	-- 幸运翻牌
	self.can_flip_count = 0		-- 翻牌次数
	self.cards = {}				-- 翻牌结果索引
	self.opt_type = 0
	self.record_type = 0
	self.record_str = ""
	-- 绝版限购
	self.page_count = 0
	self.grade_list = {}
	-- 豪华大礼
	self.charge_total = 0
	self.cur_grade = 0
	-- 连充返利
	self.charge_grade = 0
	self.charge_day = 0
	self.charge_count = 0

	-- 超值连充
	self.everyday_grade = 0
	self.everyday_sign = 0
	self.cumulative_grade = 0
	self.cumulative_sign = 0
	self.cur_day_charge = 0
	self.cumulative_charge = 0
	-- 连充福袋
	self.charge_days = 0
	self.charge_sign_count = 0
	-- 充三反四
	self.charge_grad_list = {}
	self.cur_day = 0
	-- 限时充值
	self.charge_money = 0
	-- 发红包
	self.red_packet_integral = 0
	self.red_packet_record = ""
	self.red_packet_type = 0
	self.rob_red_packet_info = {}
	self.surplus_times = 0
	self.cooling_time = 0
	-- 元宝转盘
	self.cur_draw_grade = 0
	self.cur_charge_money = 0
	self.gold_draw_record = ""
	self.unlock_grade = 0
	-- 元宝大放送
	self.gold_consume = 0

	-- 充值返利
	self.charge_fanli = 0

	-- 超值转盘
	self.draw_integral = 0
	self.cz_draw_record = ""

	-- 连续返利
	self.fanli_list = {}

	--消费争锋
	self.ranking_count = 0
	self.ranking_data = {}
	self.ranktoday_num = 0
	self.today_value = 0
	self.today_getvalue = 0
	self.get_tag = 0

	--充值争锋
	self.topupRank_count = 0
	self.topupRank_data = {}
	self.todayRank_num = 0
	self.Topup_value = 0
	self.Topup_getvalue = 0
	self.Topup_tag = 0 

	--传奇争锋
	self.legendRank_count = 0
	self.legendRank_data = {}
	self.legendRank_num = 0
	self.Legend_value = 0
	self.Legend_getvalue = 0
	self.Legend_tag = 0

	--原石鉴定
	self.All_open_count = 0
	self.Free_open_count = 0
	self.This_reopen_count = 0
	self.This_open_tag = 0
	self.Grif_get_tag = 0
	self.Online_time = 0
	self.Auth_record_str = ""
	self.re_online = 0
	self.shone_num = 0
	self.grift_index = {}
	self.record_index = 0
	self.autn_gift_index = 0
	self.gifts_index = 0
	
	--欢度大鞭炮
	self.firecrackes_open_count = 0
	self.firecrackes_gift_tag = 0
	self.small_firecrackes_count = 0
	self.big_firecrackes_rewardcount = 0
	self.small_gift_index = {}
	self.big_gift_index = {}
	self.lucky_draw_index = 0
	self.lucky_draw_count = 0
	self.lucky_big_index = {}

	--消费有奖
	self.daily_pay_num = 0
	self.ward_get_tag = 0

	--消费奖励
	self.act_pay_num = 0
	self.act_pay_tag = 0

	--经典BOSS
	self.boss_count = 0
	self.boss_kill_tag = {}
	self.boss_num = {}
	self.boss_awake_tag = 0

	--BOSS鉴定
	self.now_bless_value = 0
	self.ident_record_str = ""
	
	--神炉炼宝
	self.treasure_score = 0
	self.treasure_reward = 0
	self.treasure_record = ""
	self.treasure_item_num = 0
	self.treasure_item_index = 0
	self.treasure_item_list = {}
	self.treasure_index = 0

	-- 龙族秘宝
	self.dragon_treasure_data = {} -- 数据接收
	self.dragon_treasure_results = {} -- 操作结果

	--多倍充值，限时直购
	self.rechaege_data = {} 	-- 数据接收

	--61探索秘宝
	self.cound_time = 0
	self.luck_time = 0
	self.xunbao_time = 0
	self.zj_sign = 0
	self.record_list = {}

	--86转盘豪礼
	self.hl_sign = 0
	self.hl_score = 0
	self.day_com_sign = 0

	--94登录就送
	self.lq_sign = 0 
	self.dl_day = 0

	-- 95超值好礼
	self.act_days = 0
	self.item_num = 0
	self.item_list = {}
	self.buy_time = 0 
end

function SCActivityBrilliant:ReadCanbaogeData()
	local num = 0


	self.canbaoge_data = {}
	self.canbaoge_data.free_num = MsgAdapter.ReadUInt()  		--免费已用次数
	self.canbaoge_data.step_num = MsgAdapter.ReadUInt()  		--一共移动多少位置
	self.canbaoge_data.floor_num = MsgAdapter.ReadUInt()    	--下发当前层数,
	self.canbaoge_data.qz_sorce = MsgAdapter.ReadUInt() 		--奇珍分数
	self.canbaoge_data.mw_sorce = MsgAdapter.ReadUInt() 		--秘闻分数
	self.canbaoge_data.step_lingqu_sign = MsgAdapter.ReadUInt() 	--领取移动的标记
	self.canbaoge_data.floor_lingqu_sign = MsgAdapter.ReadUInt() 	--领取爬楼的标记

	self.canbaoge_data.qz_mine_lingqu_num_list = {}
	self.canbaoge_data.qz_qf_lingqu_num_list = {}
	self.canbaoge_data.mw_mine_lingqu_num_list = {}
	self.canbaoge_data.mw_qf_lingqu_num_list = {}

	num = MsgAdapter.ReadUInt()
	for i = 1, num do
		self.canbaoge_data.qz_mine_lingqu_num_list[i] = MsgAdapter.ReadUInt() 	--奇珍个人领取数量
	end

	num = MsgAdapter.ReadUInt()
	for i = 1, num do
		self.canbaoge_data.qz_qf_lingqu_num_list[i] = MsgAdapter.ReadUInt()		--奇珍系统领取数量
	end

	num = MsgAdapter.ReadUInt()
	for i = 1, num do
		self.canbaoge_data.mw_mine_lingqu_num_list[i] = MsgAdapter.ReadUInt()	--秘闻个人领取数量
	end

	num = MsgAdapter.ReadUInt()
	for i = 1, num do
		self.canbaoge_data.mw_qf_lingqu_num_list[i] = MsgAdapter.ReadUInt()		--秘闻系统领取数量
	end
	self.canbaoge_data.awrad_record = MsgAdapter.ReadStr()		--领取奖励记录字符串
	self.canbaoge_data.duihuan_record = MsgAdapter.ReadStr()	--兑换记录字符串
end

function SCActivityBrilliant:Decode()
	self.type = MsgAdapter.ReadUChar()
	if self.type == 1 then	--下发正在开启的活动列表
		self.activity_num = MsgAdapter.ReadUChar()
		self.can_list = {}
		for i = 1 ,self.activity_num  do
			local vo = {}
			vo.cmd_id = MsgAdapter.ReadUInt()
			vo.act_id = MsgAdapter.ReadUChar()


			self.can_list[i] =  vo
		end
	else
		self.cmd_id = MsgAdapter.ReadUInt()
		self.act_id = MsgAdapter.ReadUChar()
		
		if self.type == 2 then 	--下发活动配置
			self.act_cfg = MsgAdapter.ReadStr()
		elseif self.type == 3 then 	--下发活动数据
			self.is_go = MsgAdapter.ReadUChar()
			if self.is_go ~= 0 then return end

			-- 通用变量初始化
			self.act_priority = 0
			self.sign = 0
			self.sign_2 = 0
			self.consum_gold = 0
			self.mine_num = 0
			self.rank_list = {}
			self.receive_count_list = {}
			self.mine_rank = -1
			self.is_lingqu = 0

		 	if self.act_id == 1 then 	--摇钱树
				self.yaoqian_num = MsgAdapter.ReadUChar()
				self.yaoqian_time = MsgAdapter.ReadUInt()
				self.jilv = MsgAdapter.ReadStr() 
			elseif self.act_id == 4 or self.act_id == 26 then 	-- 4 限时抢购
				self.flush_time = CommonReader.ReadServerUnixTime()
				self.item_num = MsgAdapter.ReadUChar()
				self.item_list = {}
				for i=1,self.item_num do
					self.item_list[i] = MsgAdapter.ReadUChar()
				end
				self.sign = MsgAdapter.ReadUInt()	
			elseif self.act_id == 67 or self.act_id == 83 then 		-- 67多倍返利，83限时直购
				local count = MsgAdapter.ReadUChar() 		-- 充值档次数量
				for i = 1, count do
					local vo = {
						zs_num = MsgAdapter.ReadUInt(), 		-- 钻石数量
						change_time = MsgAdapter.ReadUChar(), 	-- 充值次数
					}
					table.insert(self.rechaege_data, vo)
				end
			elseif self.act_id == 94 then 	--登录就送
				self.lq_sign = MsgAdapter.ReadUInt()
				self.dl_day = MsgAdapter.ReadUInt()
			elseif self.act_id == 95 then 	--超值好礼
				self.act_days = MsgAdapter.ReadUChar()
				self.item_list = {}
				self.item_num = MsgAdapter.ReadUChar()
				for i=1,self.item_num do
					local vo = {}
					vo.idx = MsgAdapter.ReadUChar()
					vo.spare_times = MsgAdapter.ReadUChar()
					table.insert(self.item_list, vo)
				end
			elseif self.act_id == 61 then 	--探索秘宝
				self.cound_time = MsgAdapter.ReadUChar() 		--第几轮
				self.luck_time = MsgAdapter.ReadUChar() 		--已抽奖次数
				self.xunbao_time = MsgAdapter.ReadUInt() 		--寻宝次数
				self.zj_sign = MsgAdapter.ReadUInt() 			--中奖标记
				self.record_list = MsgAdapter.ReadStr() 		--全服记录
			elseif self.act_id == 62 then 	--藏宝阁
				self:ReadCanbaogeData()
			elseif self.act_id == 86 then 	--转盘豪礼
				self.hl_score = MsgAdapter.ReadUInt() 		--当前积分
				self.hl_sign = MsgAdapter.ReadUInt() 		--抽中标记，从0开始
				self.day_com_sign = MsgAdapter.ReadUInt() 	--每天完成标记，从0开始，对应配置索引
			elseif self.act_id == 37 then
				-- self.flush_time = CommonReader.ReadServerUnixTime()
				self.act_day = MsgAdapter.ReadUChar()
				self.item_list = {}
				self.item_num = MsgAdapter.ReadUChar()
				for i=1,self.item_num do
					local vo = {}
					vo.idx = MsgAdapter.ReadUChar()
					vo.spare_times = MsgAdapter.ReadUChar()
					table.insert(self.item_list, vo)
				end
				self.sign = MsgAdapter.ReadUInt()
			elseif self.act_id == 6 then					-- 6疯狂寻宝
				self.xunbao_num = MsgAdapter.ReadUInt()
				self.sign = MsgAdapter.ReadUInt()
			elseif self.act_id == 2 or self.act_id == 3 then  -- 2 登陆奖励 3 累充有礼
				self.sign = MsgAdapter.ReadUInt()
			elseif self.act_id == 8 or self.act_id == 9 or self.act_id == 19 or self.act_id == 20 or self.act_id == 21
			or self.act_id == 22 or self.act_id == 23 or self.act_id == 24 or self.act_id == 30 then
				self.sign = MsgAdapter.ReadUInt() -- 个人达标奖励标记, 按位取, 索引从0开始

				local count = MsgAdapter.ReadUChar()
				local list = {}
				for i = 1, count do
					list[#list + 1] = MsgAdapter.ReadUShort() -- 已领取的名额数量
				end
				self.receive_count_list = list

				local count = MsgAdapter.ReadUChar()
				local list = {}
				for i = 1, count do
					local vo = CommonReader.ReadActivityRankingInfo()
					list[vo[1]] = vo --按名次排序
				end
				self.rank_list = list
				self.mine_rank = MsgAdapter.ReadUChar() -- 我的排名(0为未上排行榜)
			elseif self.act_id == 10 then
				self.consum_gold = MsgAdapter.ReadUInt()
				self.use_num = MsgAdapter.ReadUInt()
				self.zp_record = MsgAdapter.ReadStr()
				self.ylq_num = MsgAdapter.ReadUInt()
				self.cqq_num = MsgAdapter.ReadUInt()
			elseif self.act_id == 11 then
				self.spare_szxb_num =  MsgAdapter.ReadUInt()
			elseif self.act_id == 12 then
				self.spare_xb_num = MsgAdapter.ReadUInt()
			elseif self.act_id == 13 then	
				self.all_charge = MsgAdapter.ReadUInt()
				self.sign = MsgAdapter.ReadUInt()
			elseif self.act_id == 14 then	
				self.lingqu_num = MsgAdapter.ReadUInt()
			elseif self.act_id == 15 then	
				self.baozan_num = MsgAdapter.ReadUInt()
				self.sign = MsgAdapter.ReadUInt()
			elseif self.act_id == 5 or self.act_id == 16 or self.act_id == 17 or self.act_id == 18 then
				local rank_num = MsgAdapter.ReadUChar()
				self.rank_list = {}
				for i=1,rank_num do
					local vo = CommonReader.ReadActivityRankingInfo()
	 				
					self.rank_list[vo[1]] = vo
				end
				self.mine_rank =  MsgAdapter.ReadUChar()
				self.mine_num = MsgAdapter.ReadUInt()
				self.is_lingqu = MsgAdapter.ReadUChar()
			elseif self.act_id == 25 then
				self.flush_time = CommonReader.ReadServerUnixTime()
				self.item_index = MsgAdapter.ReadUChar()
				self.buy_num = MsgAdapter.ReadUInt()
				self.draw_num = MsgAdapter.ReadUInt()
				self.sign = MsgAdapter.ReadUChar()
			elseif self.act_id == 27 then
				self.consum_gold = MsgAdapter.ReadUInt()
				self.all_num = MsgAdapter.ReadUShort()	
				self.draw_num = MsgAdapter.ReadUShort()
			elseif self.act_id == 28 or self.act_id == 29 then
				self.consum_gold = MsgAdapter.ReadUInt()
				self.sign = MsgAdapter.ReadUInt()
				self.sign_2 = MsgAdapter.ReadUInt()
			elseif self.act_id == 31 then -- ACT_ID.KHHD
				self.sign = MsgAdapter.ReadUShort() -- 幸福度 借位缓存并非标志位
				self.mine_num = MsgAdapter.ReadUShort() -- 已领取特殊奖励次数 借位缓存
			elseif self.act_id == 33 then
				self.jackpot = MsgAdapter.ReadUInt()
				self.jc_record = MsgAdapter.ReadStr()
				self.draw_num = MsgAdapter.ReadUInt()
				self.sign = MsgAdapter.ReadUInt()
			elseif self.act_id == 35 then
				self.mine_num = MsgAdapter.ReadUInt()
				self.sign = MsgAdapter.ReadUInt()
			elseif self.act_id == 36 then
				self.mine_num = MsgAdapter.ReadUInt()
				self.sign = MsgAdapter.ReadUInt()
			elseif self.act_id == 41 then
				self.sign = MsgAdapter.ReadUInt()
			elseif self.act_id == 40 then
				self.mine_num = MsgAdapter.ReadUInt()
				local num = MsgAdapter.ReadUChar()
				self.num_list = {}
				for i=1,num do
					local vo = {
						pos = MsgAdapter.ReadUChar(),
						count = MsgAdapter.ReadUChar(),
					}
					table.insert(self.num_list, vo.count) 
				end

				local num2 = MsgAdapter.ReadUChar()
				self.num_2_list = {}
				for i=1,num2 do
					local vo = {}
					vo.idx  = MsgAdapter.ReadUChar()
					vo.value = MsgAdapter.ReadUChar()
					table.insert(self.num_2_list, vo.value)
				end
			elseif self.act_id == 34 then
				local num = MsgAdapter.ReadUChar()
				self.num_list = {}
				for i=1,num do
					local vo = {}
					vo.idx  = MsgAdapter.ReadUChar()
					vo.value = MsgAdapter.ReadUChar()
					table.insert(self.num_list, vo)
				end
				local num2 = MsgAdapter.ReadUChar()
				self.num_2_list = {}
				for i=1,num2 do
					local vo = {}
					vo.idx  = MsgAdapter.ReadUChar()
					vo.value = MsgAdapter.ReadUChar()
					table.insert(self.num_2_list, vo)
				end
				MsgAdapter.ReadUChar() -- 砸蛋总数 一直为0,弃用
				self.sign = MsgAdapter.ReadUInt()
			elseif self.act_id == 32 or self.act_id == 42 or self.act_id == ACT_ID.LCFL then --32, 42和70的数据一致
				self.day_charge = MsgAdapter.ReadUInt()
				self.mine_num = MsgAdapter.ReadUChar()
				self.sign = MsgAdapter.ReadUInt() 
			elseif self.act_id == 43 then
				self.mine_num = MsgAdapter.ReadUInt()
				self.sign = MsgAdapter.ReadUInt()
			elseif self.act_id == ACT_ID.THLB then
				local count = MsgAdapter.ReadUChar()
				self.thlb_buy_times_list = {}
				for i = 1, count do
					self.thlb_buy_times_list[i] = MsgAdapter.ReadUChar()
				end
			elseif self.act_id == 45 then
				self.mine_num = MsgAdapter.ReadUInt()
				self.lk_draw_num = MsgAdapter.ReadUInt()
			elseif self.act_id == 46 then
				self.fl_time_list = {}
				for i=1, 8 do
					local vo = {}
					vo.index = MsgAdapter.ReadUChar()
					vo.times = MsgAdapter.ReadInt()
					table.insert(self.fl_time_list, vo)
				end
				self.fl_qf_record = MsgAdapter.ReadStr()
				self.fl_gr_record = MsgAdapter.ReadStr()
				self.gold_46_num = MsgAdapter.ReadInt() --消费金额
				self.draw_46_num = MsgAdapter.ReadInt() --已抽取数量
			elseif self.act_id == 47 then
				self.daily_charge = MsgAdapter.ReadUInt()
				self.lingqu_times = {}
				local list_count = MsgAdapter.ReadUChar()
				for i=1, list_count do
					local vo = {}
					vo.index = MsgAdapter.ReadUChar()
					table.insert(self.lingqu_times, vo)
				end
				self.sign_times = {}
				for i=1, list_count do
					local vo = {}
					vo.times = MsgAdapter.ReadUChar()
					table.insert(self.sign_times, vo)
				end
			elseif self.act_id == 48 then
				self.buy_level = MsgAdapter.ReadUInt()
			elseif self.act_id == ACT_ID.PTTQ then
				self.sign = MsgAdapter.ReadUInt()
			elseif self.act_id == 50 then
				-- self.is_exchange = MsgAdapter.ReadUInt()
		  	elseif self.act_id == 52 then 
		  		self.mine_num = MsgAdapter.ReadUInt()
		  		self.lingqu_num_52 = MsgAdapter.ReadUInt()
		  	elseif self.act_id == 54 then 
		  		self.mine_num = MsgAdapter.ReadUInt()
		  		self.cz_draw_num = MsgAdapter.ReadUInt()
				self.record_54 = MsgAdapter.ReadStr()
		  	elseif self.act_id == 55 then 
		  		self.mine_num = MsgAdapter.ReadUInt()
		  		self.sign = MsgAdapter.ReadUInt()
		  		self.is_lingqu = MsgAdapter.ReadUChar()
				self.rank_list = {}
		  		local rank_num = MsgAdapter.ReadUChar()
				for i=1,rank_num do
					local vo = CommonReader.ReadActivityRankingInfo()
					self.rank_list[vo[1]] = vo --按名次排序
				end
		  	elseif self.act_id == 56 then
		  		self.sign = MsgAdapter.ReadUInt()
		  	elseif self.act_id == 57 then
				self.sign = MsgAdapter.ReadUInt()
				self.red_rope_level = MsgAdapter.ReadUInt()

				self.state_get = MsgAdapter.ReadUInt()
				self.red_rope_count = MsgAdapter.ReadUInt()
				self.red_rope = MsgAdapter.ReadUChar()
				for i=1,self.red_rope do
					local v = {}
					v.finish_target_time = MsgAdapter.ReadUChar()
					self.red_rope_type[i] = v
				end
			elseif self.act_id == 63 then 
				self.cabinet_flush_time = CommonReader.ReadServerUnixTime()
				self.cabinet_num = MsgAdapter.ReadUChar()
				self.cabinet_list = {}
				for i=1,self.cabinet_num do
					self.cabinet_list[i] = MsgAdapter.ReadUChar()
				end
				self.sign = MsgAdapter.ReadUInt()	
				self.flush_times = MsgAdapter.ReadUInt()	
				self.flush_sign = MsgAdapter.ReadUChar()	
			elseif self.act_id == 64 then
				self.tower_level = MsgAdapter.ReadUInt()
				self.draw_record = MsgAdapter.ReadStr()
			elseif self.act_id == 65 then
				self.super_exc_list = {}
				local num = MsgAdapter.ReadUInt()
				for i = 1, num do
					local vo = {}
					vo.gr_num = MsgAdapter.ReadUInt()
					vo.qf_num = MsgAdapter.ReadUInt()
					self.super_exc_list[i] = vo
				end
			elseif self.act_id == ACT_ID.XYFP then
				self.can_flip_count = MsgAdapter.ReadUInt()
				for i = 1, 3 do
					self.cards[i] = {MsgAdapter.ReadUChar(), MsgAdapter.ReadUChar()}
				end
			elseif self.act_id == ACT_ID.JBXG then
				self.page_count = MsgAdapter.ReadUChar()
				self.grade_list = {}
				for i = 1, self.page_count do
					local list = {}
					list.grade = MsgAdapter.ReadUShort()
					list.buy_times = MsgAdapter.ReadUShort()
					self.grade_list[i] = list
				end
			elseif self.act_id == ACT_ID.HHDL then
				self.charge_total = MsgAdapter.ReadUInt()
				self.cur_grade = MsgAdapter.ReadUInt()
			-- elseif self.act_id == ACT_ID.LCFL then
			-- 	self.charge_grade = MsgAdapter.ReadUChar()
			-- 	self.charge_day = MsgAdapter.ReadUShort()
			-- 	self.charge_count = MsgAdapter.ReadUInt()
			elseif self.act_id == ACT_ID.CZLC then
				--self.everyday_grade = MsgAdapter.ReadUChar()
				self.everyday_sign = MsgAdapter.ReadUInt()
				--self.cumulative_grade = MsgAdapter.ReadUChar()
				self.cumulative_sign = MsgAdapter.ReadUInt()
				--print("sssssss", self.cumulative_sign)
				self.cur_day_charge = MsgAdapter.ReadUInt()
				self.cumulative_charge = MsgAdapter.ReadUInt()
			elseif self.act_id == ACT_ID.LCFD then
				self.charge_days = MsgAdapter.ReadUShort()
				self.sign = MsgAdapter.ReadUInt()
				self.charge_sign_count = MsgAdapter.ReadUInt()
			elseif self.act_id == ACT_ID.CSFS then
				self.charge_grad_list = {}
				local num = MsgAdapter.ReadUChar()
				for i = 1, num do
					local list = {}
					list.charge_day = MsgAdapter.ReadUChar()
					list.sign = MsgAdapter.ReadUInt()
					self.charge_grad_list[i] = list
				end
				self.cur_day = MsgAdapter.ReadUInt()
			elseif self.act_id == ACT_ID.XSCZ then
				self.sign = MsgAdapter.ReadUInt()
				self.charge_money = MsgAdapter.ReadUInt()
			elseif self.act_id == ACT_ID.FHB then
				self.red_packet_integral = MsgAdapter.ReadUInt()
				self.red_packet_record = MsgAdapter.ReadStr()
				self.surplus_times = MsgAdapter.ReadUInt()
				self.cooling_time = MsgAdapter.ReadUInt() 
			elseif self.act_id == ACT_ID.GZP then
				self.cur_draw_grade = MsgAdapter.ReadUShort()
				self.cur_charge_money = MsgAdapter.ReadUInt()
				self.gold_draw_record = MsgAdapter.ReadStr()
				self.unlock_grade = MsgAdapter.ReadUShort()
			elseif self.act_id == ACT_ID.YBFS then
				self.gold_consume = MsgAdapter.ReadUInt()
			elseif self.act_id == ACT_ID.CZFL then
				self.charge_fanli = MsgAdapter.ReadUInt()
			elseif self.act_id == ACT_ID.SVZP then
				self.draw_integral = MsgAdapter.ReadUInt()
				self.cz_draw_record = MsgAdapter.ReadStr()
			elseif self.act_id == ACT_ID.LXFL then
				self.fanli_list = {}
				local num = MsgAdapter.ReadUChar()
				for i = 1, num do
					local list = {}
					list.charge_day = MsgAdapter.ReadUChar()
					list.sign = MsgAdapter.ReadUInt()
					self.fanli_list[i] = list
				end
			elseif self.act_id == ACT_ID.XFZF  then
				self.ranking_count = MsgAdapter.ReadUChar()
				self.ranking_data = {}
				for i = 1, self.ranking_count do
					-- table.insert(data, MsgAdapter.ReadUChar()) -- 排名
					-- table.insert(data, MsgAdapter.ReadStr()) -- 玩家名
					-- table.insert(data, MsgAdapter.ReadUInt()) -- 值
					-- table.insert(data, MsgAdapter.ReadUInt()) -- 玩家角色ID
					-- table.insert(data, MsgAdapter.ReadUChar()) -- 玩家职业
					-- table.insert(data, MsgAdapter.ReadUChar()) -- 玩家性别
					local vo = {}
					local data = CommonReader.ReadActivityRankingInfo()
					vo.rank_num = data[1]
					vo.role_name = data[2]
					vo.rank_count = data[3]
					self.ranking_data[vo.rank_num] = vo
				end
				self.ranktoday_num = MsgAdapter.ReadUChar()
				self.today_value = MsgAdapter.ReadUInt()
				self.today_getvalue = MsgAdapter.ReadUInt()
				self.get_tag = MsgAdapter.ReadInt()
			elseif self.act_id == ACT_ID.CZZF then
				self.topupRank_count = MsgAdapter.ReadUChar()
				self.topupRank_data = {}
				for i = 1, self.topupRank_count do
					local vo = {}
					local data = CommonReader.ReadActivityRankingInfo()
					vo.rank_num = data[1]
					vo.role_name = data[2]
					vo.rank_count = data[3]
					self.topupRank_data[vo.rank_num] = vo
				end
				self.todayRank_num = MsgAdapter.ReadUChar()
				self.Topup_value = MsgAdapter.ReadUInt()
				self.Topup_getvalue = MsgAdapter.ReadUInt()
				self.Topup_tag = MsgAdapter.ReadInt()

			elseif self.act_id == ACT_ID.CQZF then
				self.legendRank_count = MsgAdapter.ReadUChar()
				self.legendRank_data = {}
				for i = 1, self.legendRank_count do
					local vo = {}
					vo.rank_num = MsgAdapter.ReadUChar()
					vo.role_name = MsgAdapter.ReadStr()
					vo.rank_count = MsgAdapter.ReadInt()
					self.legendRank_data[i] = vo
				end
				self.legendRank_num = MsgAdapter.ReadUChar()
				self.Legend_value = MsgAdapter.ReadUInt()
				self.Legend_getvalue = MsgAdapter.ReadUInt()
				self.Legend_tag = MsgAdapter.ReadInt()

			elseif	self.act_id == ACT_ID.YSJD then
				self.All_open_count = MsgAdapter.ReadInt()
				self.Free_open_count = MsgAdapter.ReadUChar()
				self.This_reopen_count = MsgAdapter.ReadUChar()
				self.This_open_tag = MsgAdapter.ReadInt()
				self.Grif_get_tag = MsgAdapter.ReadInt()
				self.re_online = MsgAdapter.ReadInt()
				self.shone_num = MsgAdapter.ReadUChar()
				for i = 1, self.shone_num do
					self.grift_index[i] = MsgAdapter.ReadUChar()
				end
				self.Auth_record_str = MsgAdapter.ReadStr()
			elseif self.act_id == ACT_ID.HDBP then
				self.firecrackes_open_count = MsgAdapter.ReadInt()
				self.firecrackes_gift_tag = MsgAdapter.ReadInt()
				self.small_firecrackes_count = MsgAdapter.ReadUChar()
				for i = 1, self.small_firecrackes_count do
					self.small_gift_index[i] = MsgAdapter.ReadUChar()
				end
				self.big_firecrackes_rewardcount = MsgAdapter.ReadUChar()
				for i = 1, self.big_firecrackes_rewardcount do
					self.big_gift_index[i] = MsgAdapter.ReadUChar()
				end
			elseif self.act_id == ACT_ID.XFYJ then
				self.daily_pay_num = MsgAdapter.ReadUInt()
				self.ward_get_tag = MsgAdapter.ReadUInt()
			elseif self.act_id == ACT_ID.XFJL then
				self.act_pay_num = MsgAdapter.ReadUInt()
				self.act_pay_tag = MsgAdapter.ReadUInt()
			elseif self.act_id == ACT_ID.JDBS then
				self.boss_count = MsgAdapter.ReadUChar()
				for i = 1,self.boss_count do
					self.boss_num[i] = MsgAdapter.ReadUChar()
					self.boss_kill_tag[i] = MsgAdapter.ReadInt()
				end
				self.boss_awake_tag = MsgAdapter.ReadInt()
			elseif self.act_id == ACT_ID.BSJD then
				self.now_bless_value = MsgAdapter.ReadUChar()
				self.ident_record_str = MsgAdapter.ReadStr()
			elseif self.act_id == ACT_ID.SLLB then
				self.treasure_score = MsgAdapter.ReadUInt()
				self.treasure_reward = MsgAdapter.ReadUInt()
				self.treasure_record = MsgAdapter.ReadStr()
			elseif self.act_id == ACT_ID.LZMB then
				self.dragon_treasure_data = {
					buy_times = MsgAdapter.ReadUInt(),-- (uint)购买次数
					times_award = MsgAdapter.ReadUInt(),-- (uint)次数奖励领取标志位
					[1] = MsgAdapter.ReadUShort(),-- (ushort)檀木秘宝次数
					[2] = MsgAdapter.ReadUShort(),-- (ushort)青铜秘宝次数
					[3] = MsgAdapter.ReadUShort(),-- (ushort)白银秘宝次数
					[4] = MsgAdapter.ReadUShort(),-- (ushort)黄金秘宝次数
					all_log = MsgAdapter.ReadStr(),-- (string)全服记录
				}
			end
		elseif self.type == 4 then  --下发操作结果
			self.result = MsgAdapter.ReadUChar()
			if self.act_id == 1 or self.act_id == 2 or self.act_id == 3 or self.act_id == 4
		  	or self.act_id == 6 or self.act_id == 7 or self.act_id == 8 or self.act_id == 9
		  	or self.act_id == 10 or self.act_id == 12 or self.act_id == 13 or self.act_id == 27
		  	or self.act_id == 25 or self.act_id == 28 or self.act_id == 29 or self.act_id == 31
		  	or self.act_id == 37 or self.act_id == 45 or self.act_id == 46 or self.act_id == 54 
		  	or self.act_id == 79 then
		  		self.activity_index = MsgAdapter.ReadUChar()
		  	elseif self.act_id == 33 then 
		  		self.activity_index = MsgAdapter.ReadUChar()
		  		if self.activity_index  == 1 then
		  			local award_count = MsgAdapter.ReadUChar()
		  			self.award_list = {}
		  			for i = 1, award_count do
		  				self.award_list[i] = {
		  					grid_index = MsgAdapter.ReadUChar(),
		  					award_index = MsgAdapter.ReadUChar(),
		  				}
		  			end
		  		elseif self.activity_index  == 3 then
		  			
				end
			elseif self.act_id == ACT_ID.DLJS then
				self.activity_index = MsgAdapter.ReadUChar()
				self.lq_sign = MsgAdapter.ReadUInt()
			elseif self.act_id == ACT_ID.CZLB then
				self.activity_index = MsgAdapter.ReadUChar()
				self.buy_time = MsgAdapter.ReadUChar()
			elseif self.act_id == ACT_ID.TSMB then
				self.cound_time = MsgAdapter.ReadUChar()
				self.luck_time = MsgAdapter.ReadUChar()
				self.activity_index = MsgAdapter.ReadUChar()
				self.zj_sign = MsgAdapter.ReadUInt()
			elseif self.act_id == ACT_ID.ZPHL then
				self.activity_index = MsgAdapter.ReadUChar()
				self.hl_sign = MsgAdapter.ReadUInt()
				self.hl_score = MsgAdapter.ReadUInt()
			elseif self.act_id == ACT_ID.XYFP then
				self.opt_type = MsgAdapter.ReadUChar()
				if self.opt_type == 1 then
					for i = 1, 3 do
						self.cards[i] = {MsgAdapter.ReadUChar(), MsgAdapter.ReadUChar()}
					end
				elseif self.opt_type == 3 then
					self.record_type = MsgAdapter.ReadUChar()
					self.record_str = MsgAdapter.ReadStr()
				end
			elseif self.act_id == ACT_ID.XFRY then
				self.lingqu_flag = MsgAdapter.ReadUChar()
			elseif self.act_id == ACT_ID.FHB then
				self.red_packet_type = MsgAdapter.ReadUChar() -- 1 抢红包成功 2 发红包成功
				if self.red_packet_type == 1 then 
					self.rob_red_packet_info = {}
					self.rob_red_packet_info.role_name = MsgAdapter.ReadStr()
					self.rob_red_packet_info.role_id = MsgAdapter.ReadInt()
					self.rob_red_packet_info.role_prof = MsgAdapter.ReadUChar()
					self.rob_red_packet_info.role_sex = MsgAdapter.ReadUChar()
					self.rob_red_packet_info.rob_gold = MsgAdapter.ReadUInt()
					self.rob_red_packet_info.packet_record = MsgAdapter.ReadStr()
					self.surplus_times = MsgAdapter.ReadUInt()
					self.cooling_time = MsgAdapter.ReadUInt()
				elseif self.red_packet_type == 2 then 
					self.surplus_times = MsgAdapter.ReadUInt()
					self.cooling_time = MsgAdapter.ReadUInt()
				end
			elseif self.act_id == ACT_ID.GZP then
				self.cur_draw_grade = MsgAdapter.ReadUShort()
				self.activity_index = MsgAdapter.ReadUChar()
			elseif self.act_id == ACT_ID.YSJD then
				self.op_type = MsgAdapter.ReadUChar()
				if self.op_type == 3 then
					self.record_index = MsgAdapter.ReadUChar()
					self.autn_gift_index = MsgAdapter.ReadUChar()
				elseif self.op_type == 4 then
					self.gifts_index = MsgAdapter.ReadUChar()
				end
			elseif self.act_id == ACT_ID.HDBP then
					self.lucky_draw_index = MsgAdapter.ReadUChar()
					self.lucky_draw_count = MsgAdapter.ReadUChar()
					for i = 1, self.lucky_draw_count do
						self.lucky_big_index[i] = MsgAdapter.ReadUChar()
					end
			elseif self.act_id == ACT_ID.SLLB then
				self.treasure_index = MsgAdapter.ReadUChar()
				if self.treasure_index == 2 then
					self.treasure_item_num = MsgAdapter.ReadUInt()
					self.treasure_item_list = {}
					for i = 1,self.treasure_item_num do
						self.treasure_item_list[i] = MsgAdapter.ReadUChar()
					
					end
				end
			elseif self.act_id == ACT_ID.LZMB then -- 龙族秘宝
				local results = {} 
				results.type = MsgAdapter.ReadUChar()
				if results.type == 1 then -- 转动老虎机
					results.special_count = MsgAdapter.ReadUInt() -- (uint)抽到的特殊物品数量
					results.count = MsgAdapter.ReadUInt() -- (uint)抽到的数量
					local list = {}
					for i = 1, results.count do
						list[i] = MsgAdapter.ReadUChar() -- (byte)物品索引
					end
					results.index_list = list
				elseif results.type == 2 then
					MsgAdapter.ReadUInt()
				elseif results.type == 3 then
					results.box_index = MsgAdapter.ReadUChar()
					results.item_index = MsgAdapter.ReadUChar()
				end
				self.dragon_treasure_results = results
			elseif self.act_id == ACT_ID.THLB then -- 44 每日特惠
				-- 没有实际作用,未保存和使用
				MsgAdapter.ReadUChar() -- 购买索引
				MsgAdapter.ReadUChar() -- 当天购买数量
			end
		elseif self.type == 5 then --增加活动
		elseif self.type == 6 then --减少活动
		end
	end
end


--下发护体神盾请求结果
SCGoldHudun = SCGoldHudun or BaseClass(BaseProtocolStruct)
function SCGoldHudun:__init()
	self:InitMsgType(139, 183)
	self.hudun_state = 0 
	self.result = 0
end

function SCGoldHudun:Decode()
	self.hudun_state = MsgAdapter.ReadUChar()
	self.result = MsgAdapter.ReadUChar()
end

--合区活动处理返回
SCCombinedActReqResult = SCCombinedActReqResult or BaseClass(BaseProtocolStruct)
function SCCombinedActReqResult:__init()
	self:InitMsgType(139, 184)
	self.act_id = 0  		--1累计充值, 2合区领取城主奖励, 3元宝派对, 4翅膀派对, 5宝石派对, 6铸魂派对, 7龙魂派对, 8时装礼包, 9幸运大转盘
	self.result = 0
end

function SCCombinedActReqResult:Decode()
	self.act_id = MsgAdapter.ReadUChar()
    if self.act_id == 1 then
		self.result = MsgAdapter.ReadInt() --1成功, 失败不返回
	elseif self.act_id == 2 then
		self.result = MsgAdapter.ReadUChar() --1成功, 失败不返回
	elseif self.act_id == 8 then
		self.result = MsgAdapter.ReadInt() --领取成功返回剩余次数
	elseif self.act_id == 9 then
		self.result = MsgAdapter.ReadUChar() --中奖索引从1开始
	end
end

--合区活动信息返回
SCCombinedActInfo = SCCombinedActInfo or BaseClass(BaseProtocolStruct)
function SCCombinedActInfo:__init()
	self:InitMsgType(139, 185)
	self.act_id = 0  		--1累计充值, 2合区领取城主奖励, 3元宝派对, 4翅膀派对, 5宝石派对, 6铸魂派对, 7龙魂派对, 8时装礼包, 9幸运大转盘
	self.begin_time = 0
	self.end_time = 0
    
    self.recharge_amount = 0
    self.accumul_state = 0
	self.act_state = 0
	self.xb_count = 0
	self.reward_count = 0
	self.is_open = 0
	self.ylq_count = 0
	self.ylq_gold = 0
	self.cqq_count = 0
	self.cqq_gold = 0
end

function SCCombinedActInfo:Decode()
	self.act_id = MsgAdapter.ReadUChar()
	self.begin_time = CommonReader.ReadServerUnixTime()
	self.end_time = CommonReader.ReadServerUnixTime()
    if self.act_id == CombinedActId.Accumulative then
        self.recharge_amount = MsgAdapter.ReadUInt() --(uint) 累计充值元宝数
        self.accumul_state = MsgAdapter.ReadInt()   --(int) 领取标记位(按位保存)
	elseif self.act_id == CombinedActId.Gongcheng then
		self.act_state = MsgAdapter.ReadUChar() -- 1可领取, 0不可领取
	elseif self.act_id == CombinedActId.Fashion then
		self.xb_count = MsgAdapter.ReadUChar() -- 需要寻宝次数
		self.reward_count = MsgAdapter.ReadUInt() -- 可领取次数
	elseif self.act_id == CombinedActId.DZP then
		self.is_open = MsgAdapter.ReadUChar() -- 是否开启转盘界面, 1开启, 0未开启
		self.ylq_count = MsgAdapter.ReadInt() -- 炎龙券
		self.ylq_gold = MsgAdapter.ReadInt() -- 需要充值的元宝数
		self.cqq_count = MsgAdapter.ReadInt() -- 传奇券
		self.cqq_gold = MsgAdapter.ReadInt() -- 需要消耗的元宝数
	end
end


--合区活动累计充值
SCCombinedActAccumul = SCCombinedActAccumul or BaseClass(BaseProtocolStruct)
function SCCombinedActAccumul:__init()
	self:InitMsgType(139, 22)
	self.amount = 0 
end

function SCCombinedActAccumul:Decode()
	self.amount = MsgAdapter.ReadUInt()
end

-- 所有物品剩余次数
SCItemRestTime = SCItemRestTime or BaseClass(BaseProtocolStruct)
function SCItemRestTime:__init()
	self:InitMsgType(139, 186)
	self.count = 0 
	self.item_list = {}
end

function SCItemRestTime:Decode()
	self.count = MsgAdapter.ReadUInt()
	for i = 1, self.count do
		local item = {}
		item.index = MsgAdapter.ReadUChar()--对应表UseCountItemsConfig下标，从1开始
		item.rest_time = MsgAdapter.ReadUInt()
		self.item_list[i] = item
	end
end

-- 单个物品剩余次数
SCOneItemRestTime = SCOneItemRestTime or BaseClass(BaseProtocolStruct)
function SCOneItemRestTime:__init()
	self:InitMsgType(139, 187)
	self.index = 0 
	self.rest_time = 0
end

function SCOneItemRestTime:Decode()
	self.index = MsgAdapter.ReadUChar()--对应表UseCountItemsConfig下标，从1开始
	self.rest_time = MsgAdapter.ReadUInt()
end
--超值礼包
SCOpServSupperGift = SCOpServSupperGift or BaseClass(BaseProtocolStruct)
function SCOpServSupperGift:__init()
	self:InitMsgType(139, 188)
	self.type = 0 		 	-- 1购买礼包, 2礼包标记信息
	self.buy_flag = 0
	self.buy_level_list = {}
end

function SCOpServSupperGift:Decode()
	self.type = MsgAdapter.ReadUChar()
	self.buy_flag = MsgAdapter.ReadInt()
	self.buy_level_list = {}
	local index = 0
	for k,v in pairs(PreferentialGift.SupervalueGift) do
		for i = 1,#v.GiftLevels do
			if nil == self.buy_level_list[k] and bit:_and(1, bit:_rshift(self.buy_flag, index)) == 0 then
				self.buy_level_list[k] = i - 1
			end
			index = index + 1
		end	
		self.buy_level_list[k] = self.buy_level_list[k] or #v.GiftLevels
	end
end

-- 下发资源找回
SCRetrieveInfo = SCRetrieveInfo or BaseClass(BaseProtocolStruct)
function SCRetrieveInfo:__init()
	self:InitMsgType(139, 189)
	self.task_info = {}
end

function SCRetrieveInfo:Decode()
	self.task_info = {}
	local count = MsgAdapter.ReadUChar()
	for i = 1, count do
		local vo = {
			task_id = MsgAdapter.ReadUChar(),      -- 任务id
			task_num = MsgAdapter.ReadUChar(), 		-- 任务次数
		}
		table.insert(self.task_info, vo)
	end
end

--下发轮回信息
SCLunHui = SCLunHui or BaseClass(BaseProtocolStruct)
function SCLunHui:__init()
	self:InitMsgType(139, 190)
	self.type = 0
	self.protocol_result = 0
	self.lunhui_info = {}
	self.lh_equip_list = {}
end

function SCLunHui:Decode()
	self.type = MsgAdapter.ReadUChar()						-- 操作类型原值返回, 1 提升轮回数; 2 等级兑换修为; 3 获取轮回数据; 4 获取轮回装备信息; 5 升阶魔化;
	self.protocol_result = MsgAdapter.ReadUChar()			-- protocol_result > 0为错误码, 停止下发
	self.lunhui_info = {}
	
	if 0 == self.protocol_result then
		if 3 >= self.type then 
			self.lunhui_info = {
				lh_grade = MsgAdapter.ReadUChar(),
				lh_level = MsgAdapter.ReadUChar(),
				lh_consume = MsgAdapter.ReadUInt(),
				lh_left_exchange_num = MsgAdapter.ReadUChar(),
			}
		elseif 4 == self.type or 5 == self.type then
			self.lh_equip_list = {}
			self.lh_equip_num = MsgAdapter.ReadUChar()
			for i = 1, self.lh_equip_num do
				local lh_equip = {}
				lh_equip.lh_equip_index = MsgAdapter.ReadUChar()
				lh_equip.lh_equip_grade = MsgAdapter.ReadUChar()
				lh_equip.lh_equip_star = MsgAdapter.ReadUChar()
				self.lh_equip_list[lh_equip.lh_equip_index] = lh_equip
			end
		end
	end
end

-- 下发开服活动通知
SCOpenServerActNotify = SCOpenServerActNotify or BaseClass(BaseProtocolStruct)
function SCOpenServerActNotify:__init()
	self:InitMsgType(139, 191)
	self.event_type = 0			-- 事件id， 1领取活动， 2获取活动数据
	self.act_type = 0  			-- 1建功立业, 6等级竞技, 7官职竞技, 8战将竞技, 9翅膀竞技, 10宝石竞技, 11强化竞技, 12魂珠竞技, 13斗笠竞技
	self.param_count = 0
	self.result = -10000
	self.act_info_list = {}
	self.charge_num_t = {}
end

function SCOpenServerActNotify:Decode()
	self.event_type = MsgAdapter.ReadUChar()
	self.act_type = MsgAdapter.ReadUChar()
	self.act_info_list = {}

	if 1 == self.act_type then
		if self.event_type == 1 then

		elseif self.event_type == 2 then
			local act_info = {}
			self.act_info_list[self.act_type] = act_info

			self.param_count = MsgAdapter.ReadUChar()
			for i = 1, self.param_count / 2 do
				local item_award = {}
				item_award.left_award_num = MsgAdapter.ReadInt()
				item_award.award_state = MsgAdapter.ReadInt()  -- 奖励状态： 0未达成, 1可领取, 2已领取, 3已领取完
				table.insert(act_info, item_award)
			end
		end
	elseif self.act_type >= 6 and self.act_type < 14 then
		if 1 == self.event_type then
			self.result = MsgAdapter.ReadUChar()
		elseif 2 == self.event_type then
			local act_info = {}
			self.act_info_list[self.act_type] = act_info

			act_info.btn_count = MsgAdapter.ReadUChar()
			act_info.left_fetch_times = {}
			for i = 1, act_info.btn_count do
				act_info.left_fetch_times[i] = MsgAdapter.ReadUShort()
			end
			act_info.gift_index = MsgAdapter.ReadUChar()
			act_info.receive_sign = MsgAdapter.ReadUInt()
			act_info.act_type = self.act_type
		end
	elseif self.act_type == 14 then
		if 1 == self.event_type then
			self.result = MsgAdapter.ReadUChar()
		elseif 2 == self.event_type then
			self.param_count = MsgAdapter.ReadUChar()
			local act_info = {}
			self.act_info_list[self.act_type] = act_info
			for i = 1, self.param_count do
				act_info[i] = {ranking = 0,player_name = 0,consume_num = 0}
				act_info[i].ranking =  MsgAdapter.ReadUChar()
				act_info[i].player_name = MsgAdapter.ReadStr()
				act_info[i].consume_num = MsgAdapter.ReadUInt()
			end
			self.in_ranking = MsgAdapter.ReadUChar()
			self.is_receive = MsgAdapter.ReadInt()
			self.my_cost = MsgAdapter.ReadInt()
		end
	elseif self.act_type == 15 then
		self.charge_num_t = {}
		for i = 1, MsgAdapter.ReadUChar() do
			self.charge_num_t[#self.charge_num_t + 1] = {
				num = MsgAdapter.ReadUInt(),
				flag = MsgAdapter.ReadUChar(),	-- 0未完成，1已完成
			}
		end
	end
end

-- 下发开服活动通知
SCAllPeopleBossNotify = SCAllPeopleBossNotify or BaseClass(BaseProtocolStruct)
function SCAllPeopleBossNotify:__init()
	self:InitMsgType(139, 192)
	self.opera_type = 0			-- 1请求活动配置， 2玩家数据， 3领取
end

function SCAllPeopleBossNotify:Decode()
	self.opera_type = MsgAdapter.ReadUChar()
	if 1 == self.opera_type then
		self.cfg_count = MsgAdapter.ReadUChar()
		self.info_list = {}
		for i = 1, self.cfg_count do
			local info = {}
			info.kill_num = MsgAdapter.ReadUInt()
			info.reward_count = MsgAdapter.ReadUChar()
			info.reward_cfg = MsgAdapter.ReadStr()
			table.insert(self.info_list, info)
		end
	elseif 2 == self.opera_type then
		self.boss_kill_num = MsgAdapter.ReadUInt()
		self.fetch_flag = MsgAdapter.ReadUInt()
	elseif 3 == self.opera_type then
		self.result = MsgAdapter.ReadUChar()
	end
end

-- 下发玩家特殊变量
SCRloeSpecialAttrInfo = SCRloeSpecialAttrInfo or BaseClass(BaseProtocolStruct)
function SCRloeSpecialAttrInfo:__init()
	self:InitMsgType(139, 193)
	self.attr_type = 0			-- 1请求活动配置， 2玩家数据， 3领取
end

function SCRloeSpecialAttrInfo:Decode()
	self.attr_type = MsgAdapter.ReadUChar()
	self.num = MsgAdapter.ReadUInt()
end

-- 下发秘境值相关
SCNeedValSceneInfo = SCNeedValSceneInfo or BaseClass(BaseProtocolStruct)
function SCNeedValSceneInfo:__init()
	self:InitMsgType(139, 194)
	self.val = 0
	self.can_buy_times = 0
	self.consume = 0
	self.get_val = 0
end

function SCNeedValSceneInfo:Decode()
	self.val = MsgAdapter.ReadUShort()
	self.can_buy_times = MsgAdapter.ReadUShort()
	if self.can_buy_times > 0 then
		self.consume = MsgAdapter.ReadUShort()
		self.get_val = MsgAdapter.ReadUShort()
	end
end

-- 下发跨服装备
SCCrossEquipInfo = SCCrossEquipInfo or BaseClass(BaseProtocolStruct)
function SCCrossEquipInfo:__init()
	self:InitMsgType(139, 195)
	self.opt_type = 0	-- 1 获取装备信息 2 升阶魔化
	self.result = 0		-- 0 成功 ~=0为错误码，停止下发
	self.eq_num = 0
	self.equip_info_list = {}
end

function SCCrossEquipInfo:Decode()
	self.opt_type = MsgAdapter.ReadUChar()
	self.result = MsgAdapter.ReadUChar()
	self.eq_num = 0
	self.equip_info_list = {}
	if self.result == 0 then
		self.eq_num = MsgAdapter.ReadUChar()
		for i = 1, self.eq_num do
			self.equip_info_list[i] = {
				pos = MsgAdapter.ReadUChar(),			-- 位置
				grade = MsgAdapter.ReadUChar(),			-- 阶数
				total_star = MsgAdapter.ReadUChar(),	-- 总星级
			}
		end
	end
end

--下发特权卡信息
SCPrivilegeInfo = SCPrivilegeInfo or BaseClass(BaseProtocolStruct)
function SCPrivilegeInfo:__init()
	self:InitMsgType(139, 196)
	self.v1_sign = 0 --1现是否贵族  2是否曾经激活贵族 3是否可以购买 4是否续费 5是否领取 6掉落次数控制
	self.v1_time = 0
	self.v2_sign = 0
	self.v2_time = 0
	self.v3_sign = 0
	self.v3_time = 0
	self.price = 0
	self.sale_price = 0
end

function SCPrivilegeInfo:Decode()
	self.v1_sign = MsgAdapter.ReadUChar()
	self.v1_time = MsgAdapter.ReadUInt()
	self.v2_sign = MsgAdapter.ReadUChar()
	self.v2_time = MsgAdapter.ReadUInt()
	self.v3_sign = MsgAdapter.ReadUChar()
	self.v3_time = MsgAdapter.ReadUInt()
	self.price = MsgAdapter.ReadUInt()
	self.sale_price = MsgAdapter.ReadUInt()
end

SCTurntableInfo = SCTurntableInfo or BaseClass(BaseProtocolStruct)
function SCTurntableInfo:__init()
	self:InitMsgType(139,197)
	self.info_t = {}
	self.type = 0	--1 剩余次数 2单次抽奖返回
	self.static_id = 0	--对应副本id
	self.pool_yb = 0	--元宝池里元宝数
	self.count = 0		--剩余抽奖次数
	self.extend_str = ""	--追加记录,格式:名字#奖励索引#个数;名字#奖励索引#个数;名字#奖励索引#个数
	self.index = 0     -- 中奖索引 0不转动 >=1 索引
end

function SCTurntableInfo:Decode()
	self.static_id = MsgAdapter.ReadUChar() --对应副本id
	local ope_type = MsgAdapter.ReadUChar()

	local function wirte_sever_award_list()
		local list = {}
		local count = MsgAdapter.ReadUChar()
		for i = 1, count do
			list[i] = {
				idx = MsgAdapter.ReadUChar(),
				award_type = MsgAdapter.ReadUChar(),
			}
		end
		return list
	end

	if ope_type == 3 then
		self.info_t[self.static_id].pool_yb = MsgAdapter.ReadUInt()
		self.info_t[self.static_id].count = MsgAdapter.ReadUChar()
	else
		self.info_t[self.static_id] = {
			ope_type = ope_type,
			pool_yb = MsgAdapter.ReadUInt(),
			count = MsgAdapter.ReadUChar(),
			award_cfg_type = MsgAdapter.ReadUChar(),
			extend_str = MsgAdapter.ReadStr(),
			index = ope_type == 2 and MsgAdapter.ReadUChar() or 0,
		}
	end

	if self.info_t[self.static_id].index > 0 then
		self.index = self.info_t[self.static_id].index
	end
end


SCPracticeInfo = SCPracticeInfo or BaseClass(BaseProtocolStruct)
function SCPracticeInfo:__init()
	self:InitMsgType(139,198)
	self.decode_data  = {
		[1]={
			next_floor = 0,
			cur_bless = 0,
			need_bless = 0,
			decode = function()
				self.decode_data[1].next_floor = MsgAdapter.ReadInt()
				self.decode_data[1].cur_bless = MsgAdapter.ReadUChar()
				self.decode_data[1].need_bless = MsgAdapter.ReadUChar()
			end
		},
		[2]={
			panel_type = 0,
			awards = {},
			decode = function()
				self.decode_data[2].panel_type = MsgAdapter.ReadUChar()
				if self.decode_data[2].panel_type == 1 then	--成功
					local len = MsgAdapter.ReadInt() 
					for i=1, len do
						table.insert(self.decode_data[2].awards,{type = 0,id=MsgAdapter.ReadInt(),count=MsgAdapter.ReadInt()})
					end
				end
			end
		},
		[3]={
			decode = function()
			end
		}
	}
end

function SCPracticeInfo:Decode()
	self.type = MsgAdapter.ReadUChar()
	if self.decode_data[self.type] then
		self.decode_data[self.type].decode()
	end	
end


SCPracticeRefreshBless = SCPracticeRefreshBless or BaseClass(BaseProtocolStruct)
function SCPracticeRefreshBless:__init()
	self:InitMsgType(139, 199)
	self.cur_bless = 0
	self.need_bless = 0
end

function SCPracticeRefreshBless:Decode()
	self.cur_bless = MsgAdapter.ReadUChar()
	self.need_bless = MsgAdapter.ReadUChar()
end

-- 接收试炼转盘数据
SCShiLianRotaryTableResult = SCShiLianRotaryTableResult or BaseClass(BaseProtocolStruct)
function SCShiLianRotaryTableResult:__init()
	self:InitMsgType(139, 200)
	self.type = 0 -- 操作类型, 1抽奖信息, 2单次抽奖, 3抽奖次数
	self.times = 0 -- 剩余次数
	self.pool_index = 0 -- 奖池配置索引, 从1开始
	self.item_index = 0 -- 中奖索引, 从1开始
end

function SCShiLianRotaryTableResult:Decode()
	self.type = MsgAdapter.ReadUChar()
	self.times = MsgAdapter.ReadUChar()
	if self.type ~= 3 then
		self.pool_index = MsgAdapter.ReadUChar()
		self.item_index = MsgAdapter.ReadUChar()
	end
end

-- 接收试炼每日奖励数据
SCShiLianAwardEverydayInfo = SCShiLianAwardEverydayInfo or BaseClass(BaseProtocolStruct)
function SCShiLianAwardEverydayInfo:__init()
	self:InitMsgType(139, 201)
	self.index = 0				--层数
	self.pool_index = 0			--奖池索引
	self.times = 0				--已领取次数
end

function SCShiLianAwardEverydayInfo:Decode()
	self.index = MsgAdapter.ReadUShort()
	self.pool_index = MsgAdapter.ReadUShort()
	self.times = MsgAdapter.ReadUShort()
end

--下发超值投资
SCInvestmentInfo = SCInvestmentInfo or BaseClass(BaseProtocolStruct)
function SCInvestmentInfo:__init()
	self:InitMsgType(139, 202)
	self.op_type = 0
	self.login_day_count = 0
	self.login_mark = 0
	self.award_index = 0
end

function SCInvestmentInfo:Decode()
	self.op_type = MsgAdapter.ReadUChar()
	if self.op_type == 1 then
		self.login_day_count =  MsgAdapter.ReadInt() -- 累积活动登录天数
		self.login_mark = MsgAdapter.ReadInt() -- 领取奖励的标志位，0位代表是否激活该活动（1为激活），1位开始依次对应每天的的奖励是否领取（1位已领取）
		self.vip_mark = MsgAdapter.ReadInt() -- 领取奖励的标志位，0位代表是否激活该活动（1为激活），1位开始依次对应每天的的奖励是否领取（1位已领取）
		self.power_mark = MsgAdapter.ReadInt() -- 领取奖励的标志位，0位代表是否激活该活动（1为激活），1位开始依次对应每天的的奖励是否领取（1位已领取）
	elseif self.op_type >= 2 then
		self.award_index = MsgAdapter.ReadUChar() -- 成功领取奖励索引
	end		

end

-- 139 203
-- （int）已经领取过的档位数
-- for （已经领取过的档位数）
-- {
--     （int）该档位是多少元宝
--     （int）该档位返利了几次
-- }
SCChongZhiInfo = SCChongZhiInfo or BaseClass(BaseProtocolStruct)
function SCChongZhiInfo:__init()
	self:InitMsgType(139, 203)
	self.files = 0 			
	self.chongzhi_info_list = {}
end

function SCChongZhiInfo:Decode()
	self.files = MsgAdapter.ReadInt()
	self.chongzhi_info_list = {}
	if self.files > 0 then
		for i = 1,self.files do 
			local list = {}
			list.money = MsgAdapter.ReadInt()
			list.times = MsgAdapter.ReadInt()
			self.chongzhi_info_list[i] = list
		end
	end	
end

-- boss死亡接收
SCBossDie = SCBossDie or BaseClass(BaseProtocolStruct)
function SCBossDie:__init()
	self:InitMsgType(139, 204)
	self.role_id = 0  -- 击杀者id
	self.scene_id = 0 -- 副本id
	self.fuben_id = 0 -- 场景id
	self.boss_id = 0  -- 怪物id
end

function SCBossDie:Decode()
	self.role_id = MsgAdapter.ReadInt()
	self.scene_id = MsgAdapter.ReadInt()
	self.fuben_id = MsgAdapter.ReadInt()
	self.boss_id = MsgAdapter.ReadInt()
end


-- 下发单件限时首爆数据
SCOneEquipLimitData = SCOneEquipLimitData or BaseClass(BaseProtocolStruct)
function SCOneEquipLimitData:__init()
	self:InitMsgType(139, 206)
	self.one_equ_time = 0 		-- 数量
	self.one_limit_list = {}
end

function SCOneEquipLimitData:Decode()
	self.one_limit_list = {}
	self.one_equ_time = MsgAdapter.ReadUChar()
	for i = 1, self.one_equ_time do
		local data = {
			equ_id = MsgAdapter.ReadInt(),  -- 装备id
			equ_num = MsgAdapter.ReadInt(),  	-- 装备数量
			suc_result = MsgAdapter.ReadChar(), 		-- 0-表示没有完成 1-表示完成
		}
		table.insert(self.one_limit_list, data)
	end
end

-- 下发首杀boss数据
SCBossFirstKillData = SCBossFirstKillData or BaseClass(BaseProtocolStruct)
function SCBossFirstKillData:__init()
	self:InitMsgType(139, 207)
	self.boss_num = 0 		
	self.boss_list = {}
end

function SCBossFirstKillData:Decode()
	self.boss_list = {}
	self.boss_num = MsgAdapter.ReadUChar()
	for i = 1, self.boss_num do
		local data = {
			boss_id = MsgAdapter.ReadInt(),  -- boss id
			role_name = MsgAdapter.ReadStr(), 		-- 角色名字
		}
		table.insert(self.boss_list, data)
	end
end

-- 下发套装限时回收数据
SCSuitLimitData = SCSuitLimitData or BaseClass(BaseProtocolStruct)
function SCSuitLimitData:__init()
	self:InitMsgType(139, 208)
	self.suit_num = 0
	self.suit_list = {}
end

function SCSuitLimitData:Decode()
	self.suit_num = MsgAdapter.ReadShort()
	self.suit_list = {}
	for i = 1, self.suit_num do
		local data = {
			num = MsgAdapter.ReadInt()
		}
		table.insert(self.suit_list, data)
	end
end

-- 下发钻石回收记录
SCBackRecord = SCBackRecord or BaseClass(BaseProtocolStruct)
function SCBackRecord:__init()
	self:InitMsgType(139, 209)
	self.back_num = 0
	self.back_list = {}
end

function SCBackRecord:Decode()
	self.back_list = {}
	self.back_num = MsgAdapter.ReadUChar()
	for i = 1, self.back_num do
		local data = {
			equ_index = i, 
			equ_name = MsgAdapter.ReadStr(),  -- 装备名字
			min_time = CommonReader.ReadServerUnixTime(),		-- 服务器时间
			play_name = MsgAdapter.ReadStr(), 		-- 玩家名字
		}
		table.insert(self.back_list, data)
	end
end

-- 下发单件永久回收数据
SCOneForeverBackData = SCOneForeverBackData or BaseClass(BaseProtocolStruct)
function SCOneForeverBackData:__init()
	self:InitMsgType(139, 210)
	self.one_num = 0
	self.one_list = {}
end

function SCOneForeverBackData:Decode()
	self.one_num = MsgAdapter.ReadShort()
	self.one_list = {}
	for i = 1, self.one_num do
		local data = {
			num = MsgAdapter.ReadInt()
		}
		table.insert(self.one_list, data)
	end
end

-- 下发运势
SCFortuneData = SCFortuneData or BaseClass(BaseProtocolStruct)
function SCFortuneData:__init()
	self:InitMsgType(139, 211)
	self.boss_call_num = 0 			-- uchar 运势BOSS召唤次数
	self.share_num = 0 				-- uchar 分享运势次数
	self.fortune = 0 				-- uchar 运势
end

function SCFortuneData:Decode()
	self.boss_call_num = MsgAdapter.ReadUChar()
	self.share_num = MsgAdapter.ReadUChar()
	self.fortune = MsgAdapter.ReadUChar()
end

-- 下发福利转盘数据
SCWelfareTurnbelChangeInfo = SCWelfareTurnbelChangeInfo or BaseClass(BaseProtocolStruct)
function SCWelfareTurnbelChangeInfo:__init()
	self:InitMsgType(139, 82)
	self.score = 0 				-- int 积分
	self.all_online_time = 0 	-- uint 在线时间
	self.kill_boss_num = 0 		-- uint 击杀boss数量
	self.flag = 0 				-- uint	领取抽奖标记
end

function SCWelfareTurnbelChangeInfo:Decode()
	self.score = MsgAdapter.ReadInt()
	self.all_online_time = MsgAdapter.ReadUInt()
	self.kill_boss_num = MsgAdapter.ReadUInt()
	self.flag = MsgAdapter.ReadUInt()
end

-- 下发福利转盘数据
SCWelfareTurnbelInfo = SCWelfareTurnbelInfo or BaseClass(BaseProtocolStruct)
function SCWelfareTurnbelInfo:__init()
	self:InitMsgType(139, 212)
	self.score = 0 				-- int 积分
	self.all_online_time = 0 	-- uint 在线时间
	self.kill_boss_num = 0 		-- uint 击杀boss数量
	self.flag = 0 				-- uint	领取抽奖标记
	self.award = 0 				-- uchar 抽奖索引
	self.records = {} 			-- table 日志
end

function SCWelfareTurnbelInfo:Decode()
	self.score = MsgAdapter.ReadInt()
	self.all_online_time = MsgAdapter.ReadUInt()
	self.kill_boss_num = MsgAdapter.ReadUInt()
	self.flag = MsgAdapter.ReadUInt()
	self.award = MsgAdapter.ReadUChar()
	self.records = {}
	for i=1, MsgAdapter.ReadUChar() do
		local vo = {
			item_id = MsgAdapter.ReadUShort(),
			item_type = MsgAdapter.ReadUChar(),
			name = MsgAdapter.ReadStr(),
		}
		table.insert(self.records, vo)
	end
end

-- 下发魂环购买结果
SCHunHuanData = SCHunHuanData or BaseClass(BaseProtocolStruct)
function SCHunHuanData:__init()
	self:InitMsgType(139, 213)
	self.flag = 0
end

function SCHunHuanData:Decode()
	self.flag = MsgAdapter.ReadUInt()
end

-- 接受绝版抢购信息
SCOutOfPrintInfo = SCOutOfPrintInfo or BaseClass(BaseProtocolStruct)
function SCOutOfPrintInfo:__init()
	self:InitMsgType(139, 217)
	self.buy_tag = 0 -- 购买档位
end

function SCOutOfPrintInfo:Decode()
	self.buy_tag = MsgAdapter.ReadUInt()
end

--下发蚩尤进度
SCChiyouBossInfo = SCChiyouBossInfo or BaseClass(BaseProtocolStruct)
function SCChiyouBossInfo:__init()
	self:InitMsgType(139, 218)
	self.chiyou_time = 0
end

function SCChiyouBossInfo:Decode()
	self.chiyou_time = MsgAdapter.ReadUChar()
end

--下发天天返利
SCRebateEveryDayInfo = SCRebateEveryDayInfo or BaseClass(BaseProtocolStruct)
function SCRebateEveryDayInfo:__init()
	self:InitMsgType(139, 219)
	self.op_type = 0 			-- 2获取数据，3领取奖励
	self.pay_money_day = 0
	self.charge_state1 = 0
	self.charge_state2 = 0
end

function SCRebateEveryDayInfo:Decode()
	self.op_type = MsgAdapter.ReadUChar()
	self.pay_money_day = MsgAdapter.ReadUInt()
	self.charge_state1 = MsgAdapter.ReadUInt()
	self.charge_state2 = MsgAdapter.ReadUInt()
end


--使用经验珠次数
SCUSeSpecialItemNum = SCUSeSpecialItemNum or BaseClass(BaseProtocolStruct)
function SCUSeSpecialItemNum:__init( ... )
	self:InitMsgType(139, 173)
	self.special_item_type = 0
	self.jianzhu_use_time = 0
end

function SCUSeSpecialItemNum:Decode( ... )
	self.special_item_type = MsgAdapter.ReadUChar()
	if self.special_item_type == ItemSpecialType.ExpBead then
		self.jianzhu_use_time = MsgAdapter.ReadChar()
	end
end

--接收天天充值豪礼数据
SC_139_226 = SC_139_226 or BaseClass(BaseProtocolStruct)
function SC_139_226:__init()
	self:InitMsgType(139, 226)
	self.sign = 0
	self.pay_money_day = 0 -- 累计充值天数
end

function SC_139_226:Decode()
	self.sign = MsgAdapter.ReadLL()
	self.pay_money_day = MsgAdapter.ReadInt()
end

--接收 称号等级数据
SC_139_227 = SC_139_227 or BaseClass(BaseProtocolStruct)
function SC_139_227:__init()
	self:InitMsgType(139, 227)
	self.title_level_list = {} -- 累计充值天数
end

function SC_139_227:Decode()
	local count = MsgAdapter.ReadUChar()
	local list = {}
	for i = 1, count do
		local title_id = MsgAdapter.ReadInt() or 0
		list[title_id] = MsgAdapter.ReadUShort()
	end
	self.title_level_list = list
end
