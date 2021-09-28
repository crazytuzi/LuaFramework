--------------------------------------------------------------------------------------
-- 文件名:	TalkingData.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	TalkingData SDK
-- 描  述:	对 c++导出lua的借口封装
-- 应  用:  
---------------------------------------------------------------------------------------
TalkingData = class("TalkingData")
TalkingData.__index = TalkingData

function TalkingData:ctor()
     self.battletype = 0
     self.missionId = 0
end

--赠送原因
TalkingData_Reason =
{
	TalkingData_Reason_Vip = "Vip首冲奖励",
	
}

--战斗失败原因
TDMission_Cause = 
{
	TDMission_Cause_Exit 	= "玩家主动放弃",
	TDMission_Cause_Faile 	= "战斗打不过"
}

TDEvent_Type =
{
	StartGame = "StartGame",
	Update = "Update",
	Create = "Create",
	EnterGame = "EnterGame",
}

--付费点类型
TDPurchase_Type = {
	TDP_CommonOnce = "普通召唤",
	TDP_CommonTenSummon = "普通十连抽",
	TDP_AdvancedOnce = "高级召唤",
	TDP_AdvancedTenSummon = "高级十连抽",
	TDP_FarmFieldExtend = "药田扩建",
	TDP_FarmRemoveCooling ="药田消除冷却",
	TDP_WorshipStorax = "苏合香祭拜",
	TDP_WorshipSkyTimber = "天木香祭拜",
	TDP_FarmQuality ="药田植物刷新",
	TDP_BuyPower = "购买体力",
	TDP_BuyArena = "购买天榜次数",
	TDP_ZhaoCaiFu = "招财进宝",
	TDP_Platina_ShangXiang = "白金香贡",
	TDP_Diamond_ShangXiang = "钻石香贡",
	TDP_Extreme_ShangXiang = "至尊香贡",
	TDP_Reputation_Buy = "声望商店",
	TDP_Mystical_Buy = "神秘商店",
	TDP_Mystical_Gold_Renovation= "神秘商店刷新",
	
	TDP_EQUIP_REFINE_RETAIN_LEVEL = "装备元宝合成",
	TDP_HUNT_FATE_JIANGZIYA = "召唤姜子牙",
	TDP_ELIMINATE_YUANBAO = "元宝感悟",
	TDP_DRAGON_PRAY_NUM = "神龙上供购买",
	TDP_DRAGON_PRAY_CHANGE_LIFE = "神龙上供改运",
	TDP_JY_DEATAIL_ECTYPE_NUM = "精英副本购买",
	TDP_ARENA_CD = "竞技场消除冷却",
	TDP_LOTTERY_NUM = "转盘购买",
	TDP_TURNTABLE_REMOVE_CD = "消除转盘冷却",
	TDP_WORLD_BOSS_REMOVE_CD = "神仙试炼消除冷却",
	TDP_WORLD_BOSS_NUM = "神仙试炼买",
	TDP_WORLD_BOSS_GUWU = "元宝鼓舞消耗",
	TDP_WORLD_BOSS_Auto_Life = "自动复活",
	TDP_WORLD_BOSS_TWO_REMOVE_CD  = "封印妖魔清除冷却",
	TDP_BA_XIAN_GUO_HAI_NUM = "八仙过海打劫",
	TDP_BA_XIAN_GUO_HAI_ROLE = "八仙过海刷新",
	TDP_ACTIVITY_FU_LU_NUM = "活动副本购买",
	TDP_ACTIVITY_CHUAN_CHENG_NUM = "传承消耗",
	TDP_HUNT_FATE_BALIANCHOU_GOLD_COST = "猎妖元宝八连抽",
	TDP_COMPOSE_GOLD_DANYAO = "丹药元宝合成",
	TDP_BUY_ELIMINATE_COUNT = "购买感悟次数",
	TDP_ARENA_KUA_FU_UPADTE_CHALLENGE = "刷新跨服挑战对手", -- 跨服刷新对手
	TDP_ARENA_KUA_FU_REMOVE_CD = "跨服天榜cd消除", -- 跨服
	TDP_ARENA_KUA_FU_BUY_NUM = "跨服天榜次数购买", -- 跨服天榜次数购买
	TDP_ARENA_GUILD_CREATE = "帮派创建响应", -- 帮派创建响应
	TDP_ARENA_BaXianGuoHai_cd = "八仙过海清除打劫cd", -- 八仙过海清除打劫cd
	TDP_ARENA_Universal_Interface = "通用接口消耗", -- 通用接口消耗
	TDP_ARENA_Activity = "参加活动", -- 参加活动

	
}

--[[
   	/** @method  InitPlayerBaseInfo 设置基础信息 登入成功后调用
     *	@param 	accountId       帐号id
     *	@param 	level           升级之后的等级     类型:int
     *	@param 	gender          性别             1男 2女
     *	@param 	accountName     账户名称          类型:string
     *	@param  gameServer      区服             类型:string
     */
]]
function TalkingData:InitPlayerBaseInfo(accountId, level, gender, accountName, gameServer)
	if not accountId or accountId == "" or accountId == 0 then
		return
	end
	
	if not level or level == "" or level == 0 then
		return
	end
	
	if not gender or gender == "" or gender == 0 then
		return
	end
	
	if not accountName or accountName == "" or accountName == 0 then
		return
	end
	
	if not gameServer or gameServer == "" or gameServer == 0 then
		return
	end
	
	CGameData:InitPlayerData(accountId, level, gender, accountName, gameServer)
end


--[[
 	/**
     *	@method	SetLevel  设置等级 
     *	@param 	iLevel    升级之后的等级     类型:int
     */
 ]]
 function TalkingData:SetLevel(iLevel)
 	if not iLevel then return end

 	CGameData:setLevel(iLevel)
 end


--[[
 	/**
     *	@method	onChargeRequst          虚拟币充值请求
     *	@param 	orderId                 订单id 			类型:string
     *	@param 	iapId                   充值包id 			类型:string
     *	@param 	currencyAmount          现金金额 			类型:double
     *	@param 	virtualCurrencyAmount   虚拟币金额 		类型:double
     */
]]
function TalkingData:onChargeRequst(orderId, iapId, currencyAmount, virtualCurrencyAmount)
	if not orderId or
	   not iapId or
	   not currencyAmount or
	   not virtualCurrencyAmount then
	   return
	end

	CGameData:onChargeRequst(orderId, iapId, currencyAmount, virtualCurrencyAmount)
end


--[[
	/**
     *	@method	onChargeSuccess         虚拟币充值成功
     *	@param 	orderId                 订单id        	类型:string
     */
]]

function TalkingData:onChargeSuccess(orderId)
	CGameData:onChargeSuccess(orderId)
end


--[[
	/** 跟踪获赠的虚拟币
     *  @method onReward                虚拟币赠送
     *  @param  virtualCurrencyAmount   虚拟币金额         类型:double
     *  @param  reason                  赠送虚拟币的原因    具体的查看 TalkingData_Reason 定义 。
     * 	调用 例如 onReward(100,TalkingData_Reason.TalkingData_Reason_Vip) 表示 vip首冲奖励 100
     * 
]]
function TalkingData:onReward( virtualCurrencyAmount, reason)
	if not virtualCurrencyAmount or
	   not reason then
	   return 
	end

	CGameData:onReward(virtualCurrencyAmount, reason)
end


--[[
	/** 记录付费点
     *	@method	onPurchase  虚拟物品购买
     *	@param 	item        道具           类型:string
     *	@param 	number      道具个数        类型:int
     *	@param 	price       道具单价        类型:double
     */
]]
function TalkingData:onPurchase(item , number,  price)
	if not item or
	   not number or
	   not price then
	   return
	end
	CGameData:onPurchase(item, number, price)
end


--[[
 /** 消耗物品或服务等
     *	@method	onUse  		虚拟物品消耗
     *	@param 	item        道具           类型:string
     *	@param 	number      道具个数        类型:int
     */
]]
function TalkingData:onUse(item,  itemNumber)
	if not item or
		not itemNumber then
		return 
	end

	CGameData:onUse(item, itemNumber)
end


--[[
 /**
     *	@method	onBegin     开始一项任务
     *	@param 	missionId   副本  string 类型_副本id
     */
]]
function TalkingData:onBegin(missionId)
	if not missionId then return end

	self.missionId = missionId
	CGameData:onBegin(missionId)
end

--[[
    /**
     *	@method	onCompleted 完成一项任务
     *	@param 	missionId   副本  string 类型_副本id
     */
]]
function TalkingData:onCompleted(missionId)
	if not missionId then return end

     CGameData:onCompleted(missionId)
end

--[[
/**
     *	@method	onFailed    一项任务失败
     *	@param 	missionId   副本  string 类型_副本id
     *	@param 	failedCause 失败原因    类型:string
     onFailed(1001, TDMission_Cause.TDMission_Cause_Exit)  1001副本 主动退出
     */
]]
function TalkingData:onFailed(missionId, cause)
	if not cause then return end

	if missionId == nil then
		CGameData:onFailed(self.missionId, cause)
	else
		CGameData:onFailed(missionId, cause)
	end
end

--[[
/**
 *   @method   onEvent     自定义事件
 *   @param    eventId     事件ID    类型:NSString
 *   @param    eventData   事件参数   类型:C++ 自定义封装
 */  
例子：
local TDdata =  CDataEvent:CteateDataEvent()
TDdata:PushDataEvent("第一步", "Finished")
TDdata:PushDataEvent("第二步", "Finished")

gTalkingData:onEvent(TDEvent_Type.StartGame, TDdata)
]]
function TalkingData:onEvent(EventType, EventData)
	cclog("======= EventType"..tostring(EventType).." EventData"..tostring(EventData))
	if not EventType or not EventData then return end

	if type(EventType) == "number" then
		EventType = ""..EventType
	end
	
     CGameData:OnEvent(EventType, EventData)
end

-----------------------------------定义全局对象------------------------------
gTalkingData = TalkingData.new()