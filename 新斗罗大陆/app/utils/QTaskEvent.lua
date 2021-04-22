-- @Author: xurui
-- @Date:   2017-11-18 10:59:46
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-09-11 18:04:52
local QTaskEvent = class("QTaskEvent")

local QUIViewController = import("..ui.QUIViewController")
local QVIPUtil = import("..utils.QVIPUtil")
local QQuickWay = import("..utils.QQuickWay")

--需要在相关功能处更新

--狀態類任務（登陸，進度，隶属）
QTaskEvent.ARCHAEOLOGY_ACTIVE_EVENT = "ARCHAEOLOGY_ACTIVE_EVENT" 								--【鬥羅武魂】點亮進度
QTaskEvent.SOULTRIAL_ACTIVE_EVENT = "SOULTRIAL_ACTIVE_EVENT" 									--【魂力試煉】點亮進度
QTaskEvent.THUNDER_ACTIVE_EVENT = "THUNDER_ACTIVE_EVENT" 										--【殺戮之都】通關進度
QTaskEvent.UNION_STATE_EVENT = "UNION_STATE_EVENT" 												--【宗门】隶属于宗门（自建或加入他人宗门）
QTaskEvent.SUN_WAR_ACTIVE_EVENT = "SUN_WAR_ACTIVE_EVENT" 										--【海神島】通關進度
QTaskEvent.SILVERMINE_OCCUPY_EVENT = "SILVERMINE_OCCUPY_EVENT"									--【魂兽森林】占领成功
QTaskEvent.GLORY_ARENA_CLASS_UP_EVENT = "GLORY_ARENA_CLASS_UP_EVENT"							--【大魂師賽】段位提升
QTaskEvent.FIGHT_CLUB_CLASS_UP_EVENT = "FIGHT_CLUB_CLASS_UP_EVENT"								--【地獄殺戮場】晉升
QTaskEvent.BLACKROCK_PASS_EVENT = "BLACKROCK_PASS_EVENT"										--【傳靈塔】通關
QTaskEvent.BLACKROCK_PASS_WITHOUT_REWARD_EVENT = "BLACKROCK_PASS_WITHOUT_REWARD_EVENT"			--【傳靈塔】無獎勵情況下通關
QTaskEvent.MARITIME_SHIP_START_EVENT = "MARITIME_SHIP_START_EVENT"								--【冰火聚宝盆】运送开始
QTaskEvent.MONOPOLY_REFINE_MEDICINE_SUCCESS_EVENT = "MONOPOLY_REFINE_MEDICINE_SUCCESS_EVENT"	--【冰火兩儀眼】煉藥成功（即解毒成功）
QTaskEvent.MONOPOLY_PLANT_SUCCESS_EVENT = "MONOPOLY_PLANT_SUCCESS_EVENT"						--【冰火兩儀眼】种植（或培养）仙品成功



--领奖类任务（）
QTaskEvent.ACTIVITY_CARNIVAL_PRIZE_EVENT = "ACTIVITY_CARNIVAL_PRIZE_EVENT" 						--【嘉年華】領獎次數
QTaskEvent.ACTIVITY_CARNIVAL_SCORE_EVENT = "ACTIVITY_CARNIVAL_SCORE_EVENT" 						--【嘉年華】積分領獎次數
QTaskEvent.ACTIVE_SKIN_EVENT = "ACTIVE_SKIN_EVENT"												--【皮膚】激活皮肤次数
QTaskEvent.UNION_SACRIFICE_REWARD_COUNT_EVENT = "UNION_SACRIFICE_REWARD_COUNT_EVENT"			--【宗门】領取宗門建設獎勵次數
QTaskEvent.WELFARE_DUNGEON_REWARD_COUNT_EVENT = "WELFARE_DUNGEON_REWARD_COUNT_EVENT"			--【副本】領取史詩副本獎勵寶箱次數
QTaskEvent.INVATION_REWARD_COUNT_EVENT = "INVATION_REWARD_COUNT_EVENT"							--【魂兽入侵】領取寶箱次數
QTaskEvent.SUN_WAR_REWARD_COUNT_EVENT = "SUN_WAR_REWARD_COUNT_EVENT"							--【海神島】領取寶箱次數
QTaskEvent.WORLD_BOSS_AWARD_COUNT_EVENT = "WORLD_BOSS_AWARD_COUNT_EVENT"						--【世界BOSS】領取目標獎勵次數
QTaskEvent.GLORY_ARENA_CLASS_AWARD_COUNT_EVENT = "GLORY_ARENA_CLASS_AWARD_COUNT_EVENT"			--【大魂師賽】領取段位寶箱次數
QTaskEvent.SOTO_TEAM_REWARD_COUNT_EVENT = "SOTO_TEAM_REWARD_COUNT_EVENT"						--【云顶之战】積分領獎次數
		

--戰鬥類任務（）
QTaskEvent.ARENA_TASK_EVENT = "ARENA_TASK_EVENT"                                        		--【斗魂场】战斗次数 
QTaskEvent.DRAGON_WAR_TASK_EVENT = "DRAGON_WAR_TASK_EVENT"										--【武魂争霸】战斗次数
QTaskEvent.SUN_WAR_TASK_EVENT = "SUN_WAR_TASK_EVENT"											--【海神岛】战斗次数
QTaskEvent.INVATION_EVENT = "INVATION_EVENT"													--【魂兽入侵】战斗次数
QTaskEvent.METAILCITY_EVENT = "METAILCITY_EVENT"												--【金属之城】战斗次数
QTaskEvent.THUNDER_EVENT = "THUNDER_EVENT"														--【杀戮之都】战斗次数
QTaskEvent.FIGHT_CLUB_TASK_EVENT = "FIGHT_CLUB_TASK_EVENT"										--【地狱杀戮场】战斗次数
QTaskEvent.TIMEMACHINE_TASK_EVENT = "TIMEMACHINE_TASK_EVENT"									--【試煉寶屋】战斗次数
QTaskEvent.WELFARE_DUNGEON_TASK_EVENT = "WELFARE_DUNGEON_TASK_EVENT"							--【副本】史詩副本战斗次数
QTaskEvent.WORLD_BOSS_TASK_EVENT = "WORLD_BOSS_TASK_EVENT"										--【世界BOSS】战斗次数
QTaskEvent.GLORY_ARENA_TASK_EVENT = "GLORY_ARENA_TASK_EVENT"									--【大魂師賽】战斗次数
QTaskEvent.STORM_ARENA_TASK_EVENT = "STORM_ARENA_TASK_EVENT"									--【索托鬥魂場】战斗次数
QTaskEvent.SANCTUARY_TASK_EVENT = "SANCTUARY_TASK_EVENT"										--【全大陸精英賽】海選战斗次数
QTaskEvent.MARITIME_TASK_EVENT = "MARITIME_TASK_EVENT"											--【冰火聚宝盆】掠夺战斗次数
QTaskEvent.SOTO_TEAM_TASK_EVENT = "SOTO_TEAM_TASK_EVENT"										--【云顶之战】战斗次数
		
-- QTaskEvent.NORMAL_DUNGEON_TASK_EVENT = "NORMAL_DUNGEON_TASK_EVENT"								--【副本】普通副本战斗次数
-- QTaskEvent.ELITE_DUNGEON_TASK_EVENT = "ELITE_DUNGEON_TASK_EVENT"								--【副本】精英副本战斗次数
-- QTaskEvent.MARITIME_ROBBERY_TASK_EVENT = "MARITIME_ROBBERY_TASK_EVENT"							--【仙品聚寶盆】掠夺次数
-- QTaskEvent.GLORY_TOWER_TASK_EVENT = "GLORY_TOWER_TASK_EVENT"									--【荣耀之塔】战斗次数
-- QTaskEvent.SILVER_MINE_TASK_EVENT = "SILVER_MINE_TASK_EVENT"									--【宝石矿洞】战斗次数
-- QTaskEvent.BLACK_ROCK_TASK_EVENT = "BLACK_ROCK_TASK_EVENT"										--【熔火組隊戰】战斗次数
-- QTaskEvent.SPAR_FIELD_TASK_EVENT = "SPAR_FIELD_TASK_EVENT"										--【晶石幻境】战斗次数
-- QTaskEvent.UNION_DUNGEON_TASK_EVENT = "UNION_DUNGEON_TASK_EVENT"								--【公会副本】战斗次数
-- QTaskEvent.TEAM_ARENA_TASK_EVENT = "TEAM_ARENA_TASK_EVENT"										--组队竞技战斗次数 


--社交類任務（膜拜、協助、紅包）
QTaskEvent.STORM_ARENA_WORSHIP_EVENT = "STORM_ARENA_WORSHIP_EVENT"								--【索托斗魂场】膜拜次数
QTaskEvent.ARENA_WORSHIP_EVENT = "ARENA_WORSHIP_EVENT"											--【斗魂场】膜拜次数
QTaskEvent.SILVERMINE_HELP_EVENT = "SILVERMINE_HELP_EVENT"										--【魂兽森林】發出协助邀請次数
QTaskEvent.SILVERMINE_ASSIST_EVENT = "SILVERMINE_ASSIST_EVENT"									--【魂兽森林】接受协助邀請次数
QTaskEvent.TOKEN_REDPACKET_EVENT = "TOKEN_REDPACKET_EVENT"										--【宗門紅包】发钻石福袋次数
QTaskEvent.ITEM_REDPACKET_EVENT = "ITEM_REDPACKET_EVENT"										--【宗門紅包】发活动福袋次数
QTaskEvent.INVATION_SHARE_BOSS_EVENT = "INVATION_SHARE_BOSS_EVENT"								--【魂兽入侵】分享次数
QTaskEvent.MARITIME_JOIN_ESCORT_EVENT = "MARITIME_JOIN_ESCORT_EVENT"							--【冰火聚宝盆】加入保护
		
		
--貨幣類任務（消耗貨幣、道具）		
QTaskEvent.TKOEN_CONSUME_EVENT = "TKOEN_CONSUME_EVENT"											--【玩家】消耗钻石数量
QTaskEvent.BUY_ENERGY_EVENT = "BUY_ENERGY_EVENT"												--【玩家】购买体力次数
QTaskEvent.ARENA_BUY_FIGHT_COUNT_EVENT = "ARENA_BUY_FIGHT_COUNT_EVENT"							--【鬥魂場】购买挑戰次数
QTaskEvent.METAILCIT_BUY_FIGHT_COUNT_EVENT = "METAILCIT_BUY_FIGHT_COUNT_EVENT"					--【金屬之城】购买挑戰次数
QTaskEvent.SANCTUARY_BET_COUNT_EVENT = "SANCTUARY_BET_COUNT_EVENT"								--【全大陸精英賽】押注次數
QTaskEvent.MONOPOLY_CHEAT_EVENT = "MONOPOLY_CHEAT_EVENT"										--【冰火两仪眼】使用遥控骰子
QTaskEvent.SILVESARENA_PEAK_STAKE_COUNT_EVENT = "SILVESARENA_PEAK_STAKE_COUNT_EVENT"			--【希尔维斯巅峰赛】押注次數

		
--商店類任務（商店、商城）		
QTaskEvent.MALL_BUY_TASK_EVENT = "MALL_BUY_TASK_EVENT"											--【商城】购买道具次数
QTaskEvent.THUNDER_STORE_BUY_TASK_EVENT = "THUNDER_STORE_BUY_TASK_EVENT"						--【殺戮之都】购买道具次数
QTaskEvent.METALCITY_STORE_BUY_TASK_EVENT = "METALCITY_STORE_BUY_TASK_EVENT"					--【金屬之城】购买道具次数
QTaskEvent.SPAR_STORE_BUY_TASK_EVENT = "SPAR_STORE_BUY_TASK_EVENT"								--【地獄殺戮場】购买道具次数
QTaskEvent.BLACKROCK_STORE_BUY_TASK_EVENT = "BLACKROCK_STORE_BUY_TASK_EVENT"					--【傳靈塔】购买道具次数
QTaskEvent.SANCTUARY_STORE_BUY_TASK_EVENT = "SANCTUARY_STORE_BUY_TASK_EVENT"					--【全大陸精英賽】购买道具次数
		
		
--其他類任務（）		
QTaskEvent.MONOPOLY_MOVE_EVENT = "MONOPOLY_MOVE_EVENT"											--【冰火两仪眼】掷骰子次数（移动次数）
QTaskEvent.SILVER_CHEST_BUY_EVENT = "SILVER_CHEST_BUY_EVENT"									--【武魂殿】普通召唤次数
QTaskEvent.GOLD_CHEST_BUY_EVENT = "GOLD_CHEST_BUY_EVENT"										--【武魂殿】豪华召唤次数
QTaskEvent.UNION_QUESTION_EVENT = "UNION_QUESTION_EVENT"										--【宗门答题】次数
QTaskEvent.TRANSPORT_SUPER_SHIP_TASK_EVENT = "TRANSPORT_SUPER_SHIP_TASK_EVENT"					--【仙品聚寶盆】超级仙品运送次数
QTaskEvent.THUNDER_RESET_COUNT_EVENT = "THUNDER_RESET_COUNT_EVENT"								--【殺戮之都】重置次数
QTaskEvent.UNION_SACRIFICE_COUNT_EVENT = "UNION_SACRIFICE_COUNT_EVENT"							--【宗门】建设次数
QTaskEvent.STORM_ARENA_SET_DEFENCE_EVENT = "STORM_ARENA_SET_DEFENCE_EVENT"						--【索托鬥魂場】配置防守陣容



--需要统一进行更新的事件，如item、hero 信息发生变化
QTaskEvent.HERO_STAR_TASK_EVENT = "HERO_STAR_TASK_EVENT"								--【英雄】星级数

function QTaskEvent:ctor()
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._taskSystemTypes = {}

	self._heroTaskEvent = {
		
	}

	self._sigleHeroTaskEvent = {
		HERO_STAR_TASK_EVENT = {updateFunc = handler(self, self.updateHeroStarNumber)}
	}

	self._itemTaskEvent = {
		
	}
end

--初始化
function QTaskEvent:init()
	self._remoteProxy = cc.EventProxy.new(remote)
	self._remoteProxy:addEventListener(remote.HERO_UPDATE_EVENT, handler(self, self.updateEventHandler))

	self._remoteHerosProxy = cc.EventProxy.new(remote.herosUtil)
	self._remoteHerosProxy:addEventListener(remote.herosUtil.EVENT_SINGLE_HERO_UPDATE, handler(self, self.updateEventHandler))

	self._remoteItemsProxy = cc.EventProxy.new(remote.items)
	self._remoteItemsProxy:addEventListener(remote.items.EVENT_ITEMS_UPDATE, handler(self, self.updateEventHandler))
end

function QTaskEvent:disappear()
	self._remoteProxy:removeAllEventListeners()
	self._remoteProxy = nil

	self._remoteHerosProxy:removeAllEventListeners()
	self._remoteHerosProxy = nil

	self._remoteItemsProxy:removeAllEventListeners()
	self._remoteItemsProxy = nil
end

--[[
/*  
*	注册任务事件监听
*	param	 eventType:事件类型
*	param	 taskSystemType: config中定义的任务系统类型
*	param	 listener:对应功能的任务进度更新方法名
*	param	 options:需要传递的参数
*/
]]--
function QTaskEvent:registerTaskEvent(eventType, taskSystemType, listener)
	if eventType == nil or taskSystemType == nil then return end

	if self._taskSystemTypes[eventType] == nil then
		self._taskSystemTypes[eventType] = {}
	end

	self._taskSystemTypes[eventType][taskSystemType] = {listener = listener}
end
 
--[[
/*  
*	注销任务事件监听
*	param	 eventType:事件类型，当eventType为空时，默认注销当前系统所有任务事件监听
*	param	 taskSystemType: config中定义的任务系统类型
*/
]]--
function QTaskEvent:unregisterTaskEvent(eventType, taskSystemType)
	if eventType == nil or taskSystemType == nil then return end

	if self._taskSystemTypes[eventType] then
		self._taskSystemTypes[eventType][taskSystemType] = nil
	end
end

--[[
/*  
*	对已注册的普通任务事件进行通知
*	param	 eventType:事件类型
*	param	 number:事件完成进度
*	param	 isReplace:是否对任务进度直接进行替换
*	param	 isWin:战斗类事件的输赢
*	param	 param:特殊参数
*/
]]--
function QTaskEvent:updateTaskEventProgress(eventType, number, isReplace, isWin, param)
	local taskSystems = self._taskSystemTypes[eventType] or {}

	if taskSystems then
		for _, taskSystem in pairs(taskSystems) do
			if taskSystem.listener then
				taskSystem.listener(eventType, number, isReplace, isWin, param)
			end
		end
	end
end

--[[
/*
*  	对特殊任务事件进行通知
*/
]]--
function QTaskEvent:updateEventHandler(event)
	if event == nil then return end

	local eventListeners = {}
	if event.name == remote.herosUtil.EVENT_SINGLE_HERO_UPDATE then
		eventListeners = self._sigleHeroTaskEvent
	elseif event.name == remote.HERO_UPDATE_EVENT then
		eventListeners = self._heroTaskEvent
	elseif event.name == remote.items.EVENT_ITEMS_UPDATE then
		eventListeners = self._itemTaskEvent
	end


	for eventType, listener in pairs(eventListeners) do
		if listener.updateFunc then
			listener.updateFunc(event, eventType)
		end
	end
end

---------------------------------- 特殊事件的更新方法 ----------------------------------

-- 更新单个英雄累计星级任务
function QTaskEvent:updateHeroStarNumber(event, eventType)
	if event == nil or event.actorId or eventType == nil then return end

	local taskSystems = self._taskSystemTypes[eventType] or {}
	for _, taskSystem in pairs(taskSystems) do
		local heroInfo = remote.herosUtil:getHeroByID(event.actorId)
		if heroInfo and taskSystem.listener then
			taskSystem.listener(eventType, heroInfo.grade+1, true, event.actorId)
		end
	end
end

return QTaskEvent