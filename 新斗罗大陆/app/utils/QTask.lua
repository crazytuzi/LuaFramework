--
-- Author: wkwang
-- Date: 2014-11-11 14:35:59
--
local QBaseModel = import("..models.QBaseModel")
local QTask = class("QTask",QBaseModel)

local QStaticDatabase = import("..controllers.QStaticDatabase")
local QUIViewController = import("..ui.QUIViewController")
local QVIPUtil = import("..utils.QVIPUtil")
local QLogFile = import("..utils.QLogFile")
local QQuickWay = import("..utils.QQuickWay")

QTask.TASK_COMPLETE = 0	--标志任务完成并上交
QTask.TASK_DONE = 99		--标志任务完成没上交
QTask.TASK_DONE_TOKEN = 98 --标志任务过期  通过完成
QTask.TASK_NONE = 1		--标志任务没完成
QTask.WEEKLY_TASK_OFFSIDE = 8
QTask.EVENT_DONE = "EVENT_DONE"
QTask.EVENT_TIME_DONE = "EVENT_TIME_DONE"

QTask.TASK_TYPE_NONE = 0
QTask.TASK_TYPE_DAILY = 1
QTask.TASK_TYPE_WEEKLY = 2


function QTask:ctor()
	QTask.super.ctor(self)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._dailyTask = {}
	self._weeklyTaskSvr = {} --服务器给的任务列表 存储 task_id和 任务完成数量

	self.weeklyTaskRewardInfo = {}
	self.weeklyTaskRewardIntegral = 0

	self.weeklyTaskMap = {}
	self.weeklyTaskMapCount = {}


	self._cur_task_type = QTask.TASK_TYPE_NONE

end

function QTask:init()
	local taskConfig = QStaticDatabase:sharedDatabase():getTask()
	for _,task in pairs(taskConfig) do
		task = q.cloneShrinkedObject(task)
		task.index = tostring(task.index)
		if task.module == "每日任务" or task.module == "月卡" or task.module == "每周任务" then
			self:getDailyTaskById(task.index, true) --防止为空
			self._dailyTask[task.index].config = task
			if self._dailyTask[task.index].state == nil then
				self._dailyTask[task.index].state = QTask.TASK_NONE
			end
			if self._dailyTask[task.index].isShow == nil then
				self._dailyTask[task.index].isShow = true
			end
			self._dailyTask[task.index].name = task.name
		end
	end

	self:initRegisterFun()
	self._userEventProxy = cc.EventProxy.new(remote.user)
    self._userEventProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self.checkAllTask))
    self._userEventProxy:addEventListener(remote.user.EVENT_TIME_REFRESH, handler(self, self.timeRefreshHandler))
end

--[[
	注册函数
]]
function QTask:initRegisterFun()

	self:registerHandlerFun("100000", handler(self, self.mealTimesEveryday)) --午间能量豪礼
	self:registerHandlerFun("100001", handler(self, self.mealTimesEveryday)) --晚间能量豪礼
	self:registerHandlerFun("100002", handler(self, self.mealTimesEveryday)) --午夜能量豪礼

	self:registerHandlerFun("100100", handler(self, self.dungeonEveryday)) --副本终结者
	self:registerHandlerFun("100200", handler(self, self.dungeonEliteEveryday)) --精英副本终结者
	self:registerHandlerFun("100300", handler(self, self.skillEveryday)) --勤修苦练
	self:registerHandlerFun("100400", handler(self, self.luckydrawEveryday)) --酒馆畅饮
	self:registerHandlerFun("100500", handler(self, self.exchangeMoneyEveryday)) --点石成金
	self:registerHandlerFun("100600", handler(self, self.timeMachineEveryday)) --传送达人
	self:registerHandlerFun("100700", handler(self, self.goldBattleEveryday)) --试炼高手
	self:registerHandlerFun("100800", handler(self, self.arenaBattleEveryday)) --勇者精神
	self:registerHandlerFun("100900", handler(self, self.freeSweepCouponforVIP)) --VIP免费领取扫荡券
	self:registerHandlerFun("101000", handler(self, self.equipmentStrengEveryday)) --越来越强
	self:registerHandlerFun("101100", handler(self, self.equipmentMagicEveryday)) --魔能灌注
	self:registerHandlerFun("101600", handler(self, self.sunWellEveryday)) --每天太阳井
	self:registerHandlerFun("101700", handler(self, self.jewelryStrengEveryday)) --饰品强化

	self:registerHandlerFun("101800", handler(self, self.eliteTavernEveryDay)) --酒馆豪饮
	self:registerHandlerFun("101900", handler(self, self.buyEnergyEveryDay)) --补充能量
	self:registerHandlerFun("102000", handler(self, self.soulStoreEveryDay)) --英灵收集
	self:registerHandlerFun("102100", handler(self, self.breakthroughEquipmentEveryDay)) --突破自我
	self:registerHandlerFun("102200", handler(self, self.trainEveryday)) --培养魂师
	self:registerHandlerFun("102300", handler(self, self.useExpEveryday)) --提升魂师
	self:registerHandlerFun("102400", handler(self, self.refreshStoreEveryday)) --新的商品
	self:registerHandlerFun("102500", handler(self, self.gloryTowerEveryday)) --荣耀之战
	self:registerHandlerFun("102600", handler(self, self.thunderFightEveryday)) --战胜雷电
	self:registerHandlerFun("102700", handler(self, self.breakthroughJewelyEveryDay)) --突破饰品
	self:registerHandlerFun("102800", handler(self, self.welfareEveryday)) --史诗副本
	self:registerHandlerFun("102900", handler(self, self.arenaWorshipEveryDay)) --斗魂场膜拜
	self:registerHandlerFun("103000", handler(self, self.useTokenEveryDay)) --消耗符石

	self:registerHandlerFun("103100", handler(self, self.invasionShareEveryDay)) --要塞分享
	self:registerHandlerFun("103200", handler(self, self.invasionChestEveryDay)) --要塞宝箱
	self:registerHandlerFun("103300", handler(self, self.maritimeRobberyEveryday)) --海商运送一次
	self:registerHandlerFun("103400", handler(self, self.unionDragonWarFight)) --宗门武魂争霸一次
	self:registerHandlerFun("103500", handler(self, self.sparFieldEventDay)) --通关一次晶石场
	self:registerHandlerFun("103600", handler(self, self.nightmareEventDay)) --通关一次噩梦副本
	self:registerHandlerFun("103700", handler(self, self.fightClubQuickFight)) --完成一次搏击俱乐部的直升挑战
	self:registerHandlerFun("103701", handler(self, self.monopolyEveryday)) --大富翁投骰子一次
	self:registerHandlerFun("103702", handler(self, self.stormBattleEveryday)) --索托斗魂场战斗一次
	self:registerHandlerFun("103703", handler(self, self.sotoTeamBattleEveryday)) --云顶之战一次
	
	self:registerHandlerFun("200001", handler(self, self.monthCard1)) --月卡
	self:registerHandlerFun("200002", handler(self, self.monthCard2)) --至尊月卡
	self:registerHandlerFun("210001", handler(self, self.vipLuckydrawEveryday)) --vip赠送高级召唤令
	self:registerHandlerFun("220001", handler(self, self.giveFriendsEnergy)) --vip赠送好友体力
	self:registerHandlerFun("230001", handler(self, self.battlefieldFightEveryDay)) --海神岛
	self:registerHandlerFun("260001", handler(self, self.silverMineEveryday)) --魂兽森林
	self:registerHandlerFun("270001", handler(self, self.glyphUpgradeEveryday)) --体技升级
	self:registerHandlerFun("290001", handler(self, self.metalCityEventDay)) --通关一次噩梦副本

	self:registerHandlerFun("103704", handler(self, self.blackBattleEveryday))	--传灵塔战斗胜利
	self:registerHandlerFun("103705", handler(self, self.soulTowerBattleEveryday))	--升灵台战斗
	self:registerHandlerFun("103706", handler(self, self.offerRewardEveryday))	--魂师派遣次数
	self:registerHandlerFun("103707", handler(self, self.metalAbyssFightEveryday))	-- 金属深渊任务



	--由于本地存储与服务器刷新冲突 需要对服务器字段进行处理
	self:registerLocalPropType("110000", "todayActivity1_1Count".."^".."todayActivity2_1Count".."^".."todayActivity3_1Count".."^".."todayActivity4_1Count") --试炼宝屋
	self:registerLocalPropType("110001", "todayWelfareCount") --史诗副本
	self:registerLocalPropType("110002", "todayLuckyDrawAnyCount") --武魂殿召唤
	self:registerLocalPropType("110003", "todayAdvancedDrawCount") --武魂殿高级召唤
	self:registerLocalPropType("110004", "addupBuyEnergyCount") --购买体力
	self:registerLocalPropType("110005", "todayIntrusionBoxOpenCount") --魂兽宝箱
	self:registerLocalPropType("110006", "todaymealTimes") --领取体力
	self:registerLocalPropType("110007", "todayWorldBossFightCount") --魔鲸讨伐
	self:registerLocalPropType("110008", "todayWorldBossBuyCount") --魔鲸战斗次数
	self:registerLocalPropType("110009", "todayUnionPlunderFightCount") --极北之地攻击
	self:registerLocalPropType("110010", "todayUnionPlunderBuyCount") --极北之地购买次数
	self:registerLocalPropType("110011", "todayConsortiaWarFightCount") --宗门战进攻
	self:registerLocalPropType("110012", "todayConsortiaWarDestoryFlagCount") --宗门战夺旗
	self:registerLocalPropType("110013", "todayMockBattleTurnCount") --大师模拟战战斗轮数
	self:registerLocalPropType("110014", "todayMockBattleFightCount") --大师模拟战战斗次数
	self:registerLocalPropType("110015", "todayMockBattleShopCount") --大师模拟战购买商店次数
	self:registerLocalPropType("110016", "todaySanctuarySignUpCount") --全大陆精英赛报名
	self:registerLocalPropType("110017", "todaySanctuaryFightCount") --全大陆精英赛战斗
	self:registerLocalPropType("110018", "todaySanctuaryBetCount") --全大陆精英赛投注
	self:registerLocalPropType("110019", "todaySanctuaryShopCount") --全大陆精英赛商店购买次数
	self:registerLocalPropType("110020", "todayTotemChallengeChapterCount") --圣柱挑战通关第一章
	self:registerLocalPropType("110021", "todayTotemChallengeFightCount") --圣柱挑战战胜次数
	self:registerLocalPropType("110022", "todayTotemChallengeShopCount") --圣柱挑战商店购买次数
	self:registerLocalPropType("110023", "todaySoulTowerFightCount") --圣柱挑战商店购买次数
	self:registerLocalPropType("110024", "todaySilvesArenaChallengeFightCount") --希尔维斯
	self:registerLocalPropType("110025", "todayShareCount") --每周分享
	self:registerLocalPropType("110026", "todaySilvesArenaPeakStakeCount") --希尔维斯押注
	self:registerLocalPropType("103707", "todayMetalAbyssFightCount") --金属深渊任务



	self:registerHandlerFun("110000", handler(self, self.handlerWeeklyTask)) --试炼宝屋
	self:registerHandlerFun("110001", handler(self, self.handlerWeeklyTask)) --史诗副本
	self:registerHandlerFun("110002", handler(self, self.handlerWeeklyTask)) --武魂殿召唤
	self:registerHandlerFun("110003", handler(self, self.handlerWeeklyTask)) --武魂殿高级召唤
	self:registerHandlerFun("110004", handler(self, self.handlerWeeklyTask)) --购买体力
	self:registerHandlerFun("110005", handler(self, self.handlerWeeklyTask)) --魂兽宝箱
	self:registerHandlerFun("110006", handler(self, self.handlerWeeklyTask)) --领取体力
	self:registerHandlerFun("110007", handler(self, self.handlerWeeklyTask)) --魔鲸讨伐
	self:registerHandlerFun("110008", handler(self, self.handlerWeeklyTask)) --魔鲸战斗次数
	self:registerHandlerFun("110009", handler(self, self.handlerWeeklyTask)) --极北之地攻击
	self:registerHandlerFun("110010", handler(self, self.handlerWeeklyTask)) --极北之地购买次数
	self:registerHandlerFun("110011", handler(self, self.handlerWeeklyTask)) --宗门战进攻
	self:registerHandlerFun("110012", handler(self, self.handlerWeeklyTask)) --宗门战夺旗
	self:registerHandlerFun("110013", handler(self, self.handlerWeeklyTask)) --大师模拟战战斗轮数
	self:registerHandlerFun("110014", handler(self, self.handlerWeeklyTask)) --大师模拟战战斗次数
	self:registerHandlerFun("110015", handler(self, self.handlerWeeklyTask)) --大师模拟战购买商店次数
	self:registerHandlerFun("110016", handler(self, self.handlerWeeklyTask)) --全大陆精英赛报名
	self:registerHandlerFun("110017", handler(self, self.handlerWeeklyTask)) --全大陆精英赛战斗
	self:registerHandlerFun("110018", handler(self, self.handlerWeeklyTask)) --全大陆精英赛投注
	self:registerHandlerFun("110019", handler(self, self.handlerWeeklyTask)) --全大陆精英赛商店购买次数
	self:registerHandlerFun("110020", handler(self, self.handlerWeeklyTask)) --圣柱挑战通关第一章
	self:registerHandlerFun("110021", handler(self, self.handlerWeeklyTask)) --圣柱挑战战斗
	self:registerHandlerFun("110022", handler(self, self.handlerWeeklyTask)) --圣柱挑战商店购买次数
	self:registerHandlerFun("110023", handler(self, self.handlerWeeklyTask)) --圣柱挑战商店购买次数
	self:registerHandlerFun("110024", handler(self, self.handlerWeeklyTask)) --希尔维斯
	self:registerHandlerFun("110025", handler(self, self.handlerWeeklyTask)) --每周分享
	self:registerHandlerFun("110026", handler(self, self.handlerWeeklyTask)) --希尔维斯押注
end

function QTask:disappear()
	if self._userEventProxy ~= nil then
    	self._userEventProxy:removeAllEventListeners()
    	self._userEventProxy = nil
    end
	local taskInfo = self:getDailyTaskById("100000")
	if taskInfo and taskInfo.timeHandler  ~= nil then
		scheduler.unscheduleGlobal(taskInfo.timeHandler)
		taskInfo.timeHandler = nil
	end
	local taskInfo = self:getDailyTaskById("100001")
	if taskInfo and taskInfo.timeHandler  ~= nil then
		scheduler.unscheduleGlobal(taskInfo.timeHandler)
		taskInfo.timeHandler = nil
	end
	local taskInfo = self:getDailyTaskById("100002")
	if taskInfo and taskInfo.timeHandler  ~= nil then
		scheduler.unscheduleGlobal(taskInfo.timeHandler)
		taskInfo.timeHandler = nil
	end
	self.weeklyTaskRewardInfo = {}
	self.weeklyTaskRewardIntegral = 0
	self.weeklyTaskMapCount = {}
	self.weeklyTaskMap = {}
	self._weeklyTaskSvr = {}

end

function QTask:clearWeeklyData()
	self.weeklyTaskRewardInfo = {}
	self.weeklyTaskRewardIntegral = 0
	self.weeklyTaskMapCount = {}
	self.weeklyTaskMap = {}
	self._weeklyTaskSvr = {}


end


--获取每日任务列表
function QTask:getDailyTask()
	local dailyTask = {}
	for k,v in pairs(self._dailyTask) do
		if  v.config.module ~= "每周任务" then
			table.insert(dailyTask,v)
		end
	end
	return dailyTask
	-- return self._dailyTask
end

--获取每日任务列表
function QTask:getWeeklyTask()
	local weeklyTask = {}
	for k,v in pairs(self._dailyTask) do
		if  v.config.module == "每周任务"  then
			if self:checkSpecialWeeklyTask(k) then
				table.insert(weeklyTask,v)
			end
		end
	end
	return weeklyTask
end

function QTask:checkSpecialWeeklyTask(task_id)
	if task_id == "110016" or task_id == "110017" or task_id == "110018" then -- 除去精英商店购买 屏蔽未开启的全大陆精英赛 
		return remote.sanctuary:getIsInSeasonTimeForWeeklyTask()
	end
	if task_id == "110019"  then
		return remote.sanctuary:checkSanctuaryIsOpen() --精英商店购买 只需要判断是否开启玩法
	end

	if task_id == "110011" or task_id == "110012" then -- 屏蔽未开启的宗门副本挑战
		return remote.consortiaWar:getIsInSeasonTimeForWeeklyTask()
		-- return remote.consortiaWar:getIsInSeasonTime()
	end
	if task_id == "110013" or task_id == "110014" or task_id == "110015" then -- 屏蔽未开启的宗门副本挑战
		return app.unlock:checkLock("UNLOCK_MOCK_BATTLE", false)
		-- return remote.consortiaWar:getIsInSeasonTime()
	end
	if task_id == "110025" then
		return remote.shareSDK:checkIsOpen()
	end

	return true
end

function QTask:updateWeeklyDataByNewDay()
	for k,v in pairs(self._dailyTask) do
		if  v.config.module ~= "每周任务" then
			table.insert(dailyTask,v)
		end
	end

end


function QTask:getCurTaskType()
	if self._cur_task_type == QTask.TASK_TYPE_DAILY or self._cur_task_type == QTask.TASK_TYPE_WEEKLY then
		return  self._cur_task_type
	end
	return  QTask.TASK_TYPE_NONE
end

function QTask:setCurTaskType(_type)
	 self._cur_task_type = _type
end

--周常任务开启等级
function QTask:checkWeeklyTaskUnlock(isTips)
	return app.unlock:checkLock("UNLOCK_WEEKLY_MISSION", isTips)
end

--周常任务一键领取开启等级
function QTask:checkWeeklyTaskOneKeyUnlock(isTips)
	return app.unlock:checkLock("UNLOCK_WEEKLY_REWARDS", isTips)
end

--获取任务信息通过任务ID
function QTask:getDailyTaskById(taskId, isCreat)
	if self._dailyTask[taskId] == nil and isCreat == true then
		self._dailyTask[taskId] = {}
	end
	return self._dailyTask[taskId]
end

function QTask:getWeeklyTaskNumById(taskId)
	if self._weeklyTaskSvr[taskId] ~= nil and  self._weeklyTaskSvr[taskId].num ~= nil then
		return self._weeklyTaskSvr[taskId].num
	end
	return 0
end

--检查任务完成时间如果在刷新时间之前将所有任务重置
-- function QTask:checkTaskTime()
-- 	if self._updateTime == nil then
-- 		self._updateTime = q.serverTime()
-- 		return 
-- 	end
-- 	if self._updateTime < q.refreshTime(remote.user.c_systemRefreshTime) then
-- 		for _,taskInfo in pairs(self._dailyTask) do
-- 			taskInfo.state = QTask.TASK_NONE
-- 		end
-- 	end
-- 	self._updateTime = q.serverTime()
-- end

--更新任务完成
function QTask:updateComplete(data)
	-- self:checkTaskTime()
	for id,value in pairs(data) do
		value = tostring(value)
		self:getDailyTaskById(value) --防止为空
		if self._dailyTask[value] ~= nil then
			self._dailyTask[value].state = QTask.TASK_COMPLETE
			self._dailyTask[value].isShow = false
		else
			printf("task ID: "..value.." can't find in config! ")
		end
	end
end
-- /***
--  *周常规任务
--  */
-- message UserWeekTaskInfo{
--     optional string taskInfo = 1;           //任务完成进度 任务id^任务进度;任务id^任务进度;
--     optional string taskCompleteInfo = 2;   //任务领取情况 任务id;任务id;任务id;
--     optional string boxCompleteInfo = 3;    //宝箱领取情况 宝箱id;宝箱id;宝箱id;
--     optional int32 score = 4;               //任务积分
-- }
function QTask:updateUserWeekTaskInfo(_userWeekTaskInfo)
	self:clearWeeklyData()
	if _userWeekTaskInfo.taskInfo then
		local task_list = string.split(_userWeekTaskInfo.taskInfo, ";")
		-- QPrintTable(task_list)
		for k,v in pairs(task_list) do
			local id_num = string.split(v, "^")
			if #id_num >= 2 then
				local task_id = id_num[1] or 0
				local task_num = id_num[2] or 0
				task_num = tonumber(task_num)
				if task_num > 0 then
					local local_num = self:getTaskLocalTotleNum(task_id)
					-- print("task_id  ".. task_id.."  local_num  ".. local_num.."   task_num  ".. task_num)
					if local_num <= task_num then
						task_num = task_num - local_num
					else
						self:setTaskLocalTotleNumToZero(task_id)
					end
				end
				-- print("self._weeklyTaskSvr[task_id]  ".. task_num)
				self._weeklyTaskSvr[task_id] = {num = tonumber(task_num)}
			end

		end
	end
	QPrintTable(self._weeklyTaskSvr)

	if _userWeekTaskInfo.taskCompleteInfo then
		local task_list = string.split(_userWeekTaskInfo.taskCompleteInfo, ";")
		for id,value in pairs(task_list) do
			value = tostring(value)
			self:getDailyTaskById(value) --防止为空
			if self._dailyTask[value] ~= nil then
				self._dailyTask[value].state = QTask.TASK_COMPLETE
				self._dailyTask[value].isShow = false
			else
				printf("task ID: "..value.." can't find in config! ")
			end
		end
	end

	if _userWeekTaskInfo.boxCompleteInfo then
		self.weeklyTaskRewardInfo = {}
		local task_list = string.split(_userWeekTaskInfo.boxCompleteInfo, ";")
		self.weeklyTaskRewardInfo = task_list
	end
	if _userWeekTaskInfo.score then
		self.weeklyTaskRewardIntegral = 0
		self.weeklyTaskRewardIntegral = _userWeekTaskInfo.score
	end

end

function QTask:updateUserWeekTaskInfoCount(propType)
	if self.weeklyTaskMap[propType] ~= nil  then
		local task_id = self.weeklyTaskMap[propType]
		if self._weeklyTaskSvr[task_id] and not self._weeklyTaskSvr[task_id].special then 
			local svr_num = self._weeklyTaskSvr[task_id].num or 0
			local local_num = self:getTaskLocalTotleNum(task_id) or 0
			if svr_num >= local_num then
				local task_num = svr_num - local_num
				self._weeklyTaskSvr[task_id] = {num = tonumber(task_num) , special = true}
			end
		end
	end
end

function QTask:getTaskLocalTotleNum(taskId)
	local num = 0
	local taskInfo = self:getDailyTaskById(taskId)
	if taskInfo ~= nil and taskInfo.propType ~= nil then
		local _propList = string.split(taskInfo.propType, "^")
		for id,value in pairs(_propList) do
			num = num + self:getPropNumForKey(value)
		end
	end
	return num
end


function QTask:setTaskLocalTotleNumToZero(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	if taskInfo ~= nil and taskInfo.propType ~= nil then
		local _propList = string.split(taskInfo.propType, "^")
		for id,value in pairs(_propList) do
			 self:setPropNumForKey(value , 0)
		end
	end
end

--[[
	注册任务的检查函数
]]
function QTask:registerHandlerFun(taskId, handlerFun)
	local taskInfo = self:getDailyTaskById(taskId)
	if taskInfo ~= nil then
		taskInfo.handlerFun = handlerFun
	end
end


--[[
	注册任务的本地记录字段
]]
function QTask:registerLocalPropType(taskId, propType)
	local taskInfo = self:getDailyTaskById(taskId)
	if taskInfo ~= nil then
		taskInfo.propType = propType
		self.weeklyTaskMap[propType] = taskId
		self.weeklyTaskMapCount[propType] = 0
	end
end
--[[
	记录一套服务与每周任务的数据
]]
function QTask:addPropNumForKey(key, value)
	if not key then
		return 
	end

	if not self:checkWeeklyTaskUnlock(false) then
		print(" QTask:addPropNumForKey is lock")
		return 
	end	
	if value == nil then value = 1 end
	if self.weeklyTaskMapCount[key] == nil then
		self.weeklyTaskMapCount[key] = value
	else
		self.weeklyTaskMapCount[key] = self.weeklyTaskMapCount[key] + value
	end
end


function QTask:setPropNumForKey(key, value)
	if not key or not self.weeklyTaskMapCount  then
		return 
	end	
	if not self:checkWeeklyTaskUnlock(false) then
		print(" QTask:addPropNumForKey is lock")
		return 
	end	
	if value == nil then value = 0 end
	if self.weeklyTaskMapCount[key] ~= nil then
		self.weeklyTaskMapCount[key] =  value
	end
end


function QTask:getPropNumForKey(key)

	-- if key == "todayActivity1_1Count" or key == "todayActivity2_1Count" or key == "todayActivity3_1Count" or key == "todayActivity4_1Count" then
		
	-- 	return remote.user:getPropForKey(key) or 0 --特殊出来 这些为服务器更新的今日数据
	-- end

	return self.weeklyTaskMapCount[key] or 0
end

function QTask:timeRefreshHandler(event)
	if event.time == nil or event.time == 5 then
		for _,taskInfo in pairs(self._dailyTask) do
			taskInfo.state = QTask.TASK_NONE
		end
		self:clearWeeklyData()
		self:checkAllTask()
		self:weeklyTaskGetInfo()
		-- self:dispatchEvent({name = QTask.EVENT_DONE})
	end
end

--检查所有任务是否完成
function QTask:checkAllTask(dispatchEvent)
	local haveDone = false
	for _,taskInfo in pairs(self._dailyTask) do
		if taskInfo.config ~= nil and self:checkTaskById(taskInfo.config.index) == true and self:checkSpecialWeeklyTask(taskInfo.config.index) then
			if taskInfo.config.module ~= "月卡" then
				haveDone = true
			end
		end 
	end
	if haveDone == false then
		haveDone = self:checkTaskAchievement() or self:checkWeeklyTaskAchievement()
	end
	if haveDone == true and dispatchEvent ~= false then
		self:dispatchEvent({name = QTask.EVENT_DONE})
	end
	return haveDone
end


function QTask:dailyTaskRedTips()
	local haveDone = false
	for _,taskInfo in pairs(self._dailyTask) do
		if taskInfo.config ~= nil and self:checkTaskById(taskInfo.config.index) == true and taskInfo.config.module ~= "每周任务" and self:checkSpecialWeeklyTask(taskInfo.config.index) then
			if taskInfo.config.module ~= "月卡" then
				haveDone = true
			end
		end 
	end
	if haveDone == false then
		haveDone = self:checkTaskAchievement() 
	end
	return haveDone
end

function QTask:weeklyTaskRedTips()
	local haveDone = false
	for _,taskInfo in pairs(self._dailyTask) do
		if taskInfo.config ~= nil and self:checkTaskById(taskInfo.config.index) == true and taskInfo.config.module == "每周任务" and self:checkSpecialWeeklyTask(taskInfo.config.index) then
			if taskInfo.config.module ~= "月卡" and self:checkSpecialWeeklyTask(taskInfo.config.index) then
				haveDone = true
			end
		end 
	end
	if haveDone == false then
		haveDone = self:checkWeeklyTaskAchievement() 
	end
	return haveDone
end



--检查每日任务积分领取
function QTask:checkTaskAchievement()
	local haveDone = false
	local teamLevel = remote.user.dailyTeamLevel or 1
	local awardsData = QStaticDatabase:sharedDatabase():getDaliyTaskScoreAwardsByLevel(teamLevel, 1)
	local dailyTaskRewardInfo = remote.user.dailyTaskRewardInfo or {}
	local dailyTaskRewardIntegral = remote.user.dailyTaskRewardIntegral or 0
	for i = 1, 4 do
		local isGet = false
		for _,index in ipairs(dailyTaskRewardInfo) do
			if index == i then
				isGet = true
				break
			end
		end
		if isGet == false then
			if dailyTaskRewardIntegral >= awardsData[i ].condition then
				haveDone = true
				break
			end
		end
	end
	return haveDone
end


--检查每周任务积分领取
function QTask:checkWeeklyTaskAchievement()

	if not self:checkWeeklyTaskUnlock(false) then
		return false
	end

	local haveDone = false
	local teamLevel = remote.user.level or 1
	local awardsData = QStaticDatabase:sharedDatabase():getDaliyTaskScoreAwardsByLevel(teamLevel, 3)
	for i = 1+ QTask.WEEKLY_TASK_OFFSIDE, 4 + QTask.WEEKLY_TASK_OFFSIDE do
		local isGet = false
		for _,index in ipairs(self.weeklyTaskRewardInfo or {}) do
			if tonumber(index) == i then
				isGet = true
				break
			end
		end
		if isGet == false then
			local award_data =awardsData[i]  
			if  award_data and self.weeklyTaskRewardIntegral >= award_data.condition then
				haveDone = true
				print("checkWeeklyTaskAchievement")
				break
			end
		end
	end
	return haveDone
end


--nie 检查所有任务是否可以去完成 （除去  领取体力因为等待时间无法完成 ）
function QTask:checkAllTaskCanComplete()
	local haveDone = false
	for k,taskInfo in pairs(self._dailyTask) do
		local config = taskInfo.config
		local vip = taskInfo.config.show_vip or 0
		if app.unlock:checkLevelUnlock(taskInfo.display_level) and app.unlock:checkDungeonUnlock(taskInfo.unlock) and vip <= QVIPUtil:VIPLevel() and taskInfo.isShow == true then
			if (k == "100000" or k == "100001" or k == "100002")then
				if taskInfo.state == QTask.TASK_DONE then
					haveDone = true
					break
				end
			elseif k == "200001" or k == "200002" then

				--月卡迁移到活动里面
			elseif k == "210001"  then
				if (taskInfo.state == QTask.TASK_DONE or taskInfo.state == QTask.TASK_NONE) and QVIPUtil:VIPLevel() >=9 then
					haveDone = true
					break
				end
			elseif (taskInfo.state == QTask.TASK_DONE or taskInfo.state == QTask.TASK_NONE) then
				haveDone = true
				break
			end
		end
	end
	return haveDone
end

--检查任务是否完成通过ID
function QTask:checkTaskById(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	if taskInfo ~= nil then
		if taskInfo.state == QTask.TASK_DONE then
			return true
		end
		if taskInfo.state == QTask.TASK_COMPLETE then
			return false
		end
		if taskInfo.handlerFun ~= nil then
			local state = taskInfo.state
			local result = taskInfo.handlerFun(taskId)
			return result
		end
	end
	return false
end

--[[
	任务处理函数区块
]]
--根据配置中的Num判定是否完成
function QTask:taskDoneForNum(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	if taskInfo ~= nil then
		if remote.user.level == nil then
			taskInfo.isShow = false --用户数据还没有则不做判断
			return false
		 end
		local isUnlock = false
		if app.unlock ~= nil then
			local vip = taskInfo.config.show_vip or 0
			isUnlock = app.unlock:checkLevelUnlock(taskInfo.config.show_level) and app.unlock:checkDungeonUnlock(taskInfo.config.unlock) and vip <= QVIPUtil:VIPLevel()
		end
		taskInfo.isShow = isUnlock 
		if taskInfo.stepNum ~= nil and taskInfo.stepNum >= (taskInfo.config.num or 0) and isUnlock then
			taskInfo.state = QTask.TASK_DONE
			return true
		end
	end
	return false
end

function QTask:checkTaskisDone(index)
    local taskInfo = self:getDailyTaskById(index)
    return taskInfo.state == QTask.TASK_DONE
end

function QTask:checkTaskisComplete(index)
    local taskInfo = self:getDailyTaskById(index)
    return taskInfo.state == QTask.TASK_COMPLETE
end

--点石成金
function QTask:exchangeMoneyEveryday(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayMoneyBuyCount")
	return self:taskDoneForNum(taskId)
end

--酒馆畅饮
function QTask:luckydrawEveryday(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayLuckyDrawAnyCount")
	return self:taskDoneForNum(taskId)
end

--副本终结者
function QTask:dungeonEveryday(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("c_todayNormalPass") + remote.user:getPropForKey("c_todayElitePass") + remote.user:getPropForKey("todayWelfareCount")
	return self:taskDoneForNum(taskId)
end

--精英副本终结者
function QTask:dungeonEliteEveryday(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("c_todayElitePass")
	return self:taskDoneForNum(taskId)
end

--勤修苦练
function QTask:skillEveryday(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todaySkillImprovedCount")
	return self:taskDoneForNum(taskId)
end

--传送达人
function QTask:timeMachineEveryday(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayActivity1_1Count") + remote.user:getPropForKey("todayActivity2_1Count") + remote.user:getPropForKey("todayActivity3_1Count") + remote.user:getPropForKey("todayActivity4_1Count")
	return self:taskDoneForNum(taskId)
end

--试练高手
function QTask:goldBattleEveryday(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	-- taskInfo.stepNum = remote.user:getPropForKey("todayActivity3_1Count") + remote.user:getPropForKey("todayActivity4_1Count")
	return self:taskDoneForNum(taskId)
end

--勇者精神
function QTask:arenaBattleEveryday(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayArenaFightCount")
	return self:taskDoneForNum(taskId)
end

function QTask:stormBattleEveryday(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayStormFightCount")
	return self:taskDoneForNum(taskId)
end

function QTask:artifactEnhanceEveryday(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayArtifactEnhanceCount")
	return self:taskDoneForNum(taskId)
end

function QTask:monopolyEveryday(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayMonopolyMoveCount")
	return self:taskDoneForNum(taskId)
end

--酒馆豪饮
function QTask:eliteTavernEveryDay(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayAdvancedDrawCount")
	return self:taskDoneForNum(taskId)
end

--补充能量
function QTask:buyEnergyEveryDay(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayEnergyBuyCount")
	return self:taskDoneForNum(taskId)
end

--英灵收集
function QTask:soulStoreEveryDay(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayRefreshShop501Count")
	return self:taskDoneForNum(taskId)
end

--突破自我
function QTask:breakthroughEquipmentEveryDay(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayEquipBreakthroughCount")
	return self:taskDoneForNum(taskId)
end

--培养魂师
function QTask:trainEveryday(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayHeroTrainCount")
	return self:taskDoneForNum(taskId)
end

--提升魂师
function QTask:useExpEveryday(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayHeroExpCount")
	return self:taskDoneForNum(taskId)
end

--新的商品
function QTask:refreshStoreEveryday(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayRefreshShopCount")
	return self:taskDoneForNum(taskId)
end

--荣耀之战
function QTask:gloryTowerEveryday(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayTowerFightCount")
	return self:taskDoneForNum(taskId)
end

--战胜雷电
function QTask:thunderFightEveryday(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayThunderFightCount")
	return self:taskDoneForNum(taskId)
end

--突破饰品
function QTask:breakthroughJewelyEveryDay(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayAdvancedBreakthroughCount")
	return self:taskDoneForNum(taskId)
end

--VIP免费领取扫荡券
function QTask:freeSweepCouponforVIP(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	if taskId == 100900 and QVIPUtil:getFreeSweepCount() > 0 then
		taskInfo.config.type_1 = "sweep"
		taskInfo.config.num_1 = QVIPUtil:getFreeSweepCount()
		taskInfo.state = QTask.TASK_DONE
		return true
	end
end

--魔能灌注
function QTask:equipmentMagicEveryday(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayEquipEnchantCount")
	return self:taskDoneForNum(taskId)
end

--越来越强
function QTask:equipmentStrengEveryday(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayEquipEnhanceCount")
	return self:taskDoneForNum(taskId)
end

--太阳井
function QTask:sunWellEveryday(taskId)
	if (remote.user.sunwarLastFightAt or 0) > q.refreshTime(remote.user.c_systemRefreshTime)*1000 then
		local taskInfo = self:getDailyTaskById(taskId)
		taskInfo.stepNum = 1
	else
		local taskInfo = self:getDailyTaskById(taskId)
		taskInfo.stepNum = 0
	end
	return self:taskDoneForNum(taskId)
end

--饰品强化
function QTask:jewelryStrengEveryday(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayAdvancedEnhanceCount")
	return self:taskDoneForNum(taskId)
end

--福利副本
function QTask:welfareEveryday(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayWelfareCount")
	return self:taskDoneForNum(taskId)
end

--斗魂场膜拜
function QTask:arenaWorshipEveryDay(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayArenaWorshipCount")
	return self:taskDoneForNum(taskId)
end

--消耗符石
function QTask:useTokenEveryDay(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayTokenConsume")
	return self:taskDoneForNum(taskId)
end

--要塞分享
function QTask:invasionShareEveryDay(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayIntrusionShareCount")
	return self:taskDoneForNum(taskId)
end

--要塞宝箱
function QTask:invasionChestEveryDay(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayIntrusionBoxOpenCount")
	return self:taskDoneForNum(taskId)
end

--[[
	赠送好友体力
]]
function QTask:giveFriendsEnergy( taskId )
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todaySendEnergyCount")
	return self:taskDoneForNum(taskId)
end

--[[
	每日海神岛
]]
function QTask:battlefieldFightEveryDay( taskId )
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayBattlefieldFightCount")
	return self:taskDoneForNum(taskId)
end

--[[
	魂兽森林
]]
function QTask:silverMineEveryday( taskId )
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todaySilverMineOccupyCount")
	return self:taskDoneForNum(taskId)
end

--[[
	体技升级
]]
function QTask:glyphUpgradeEveryday( taskId )
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayGlyphImproveCount")
	return self:taskDoneForNum(taskId)
end

--[[
	海商运送
]]
function QTask:maritimeRobberyEveryday( taskId )
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayMaritimeShipCount")
	return self:taskDoneForNum(taskId)
end

--[[
	晶石场战斗
]]
function QTask:sparFieldEventDay(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	local myInfo = remote.sparField:getSparFieldMyInfo()
	taskInfo.stepNum = 0
	if myInfo.passedWaveIds ~= nil then
		taskInfo.stepNum = #myInfo.passedWaveIds
	end
	return self:taskDoneForNum(taskId)
end

--[[
	噩梦副本
]]
function QTask:nightmareEventDay(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayNightmareDungeonFightCount")
	return self:taskDoneForNum(taskId)
end

--[[
	金属之城
]]
function QTask:metalCityEventDay(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayMetalCityFightCount")
	return self:taskDoneForNum(taskId)
end

--[[
	地狱杀戮场挑战
]]
function QTask:fightClubQuickFight(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayFightClubCount")
	return self:taskDoneForNum(taskId)
end

--[[
	宗门武魂争霸
]]
function QTask:unionDragonWarFight(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayDragonWarFightCount")
	return self:taskDoneForNum(taskId)
end

-- 云顶之战
function QTask:sotoTeamBattleEveryday(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todaySotoTeamFightCount")
	return self:taskDoneForNum(taskId)
end

-- 	传灵塔
function QTask:blackBattleEveryday(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayBlackFightCount")
	return self:taskDoneForNum(taskId)
end

--升灵台战斗
function QTask:soulTowerBattleEveryday( taskId )
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todaySoulTowerFightCount")
	return self:taskDoneForNum(taskId)	
end

function QTask:offerRewardEveryday( taskId )
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayOfferRewardCount")
	return self:taskDoneForNum(taskId)	
end

function QTask:metalAbyssFightEveryday( taskId )
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = remote.user:getPropForKey("todayMetalAbyssFightCount")
	return self:taskDoneForNum(taskId)	
end

function QTask:monthCard1(taskId)
	if remote.recharge.monthCard1EndTime then
		local taskInfo = self:getDailyTaskById(taskId)

		-- local remainingTime = remote.recharge.monthCard1EndTime/1000 - q.serverTime()
		-- remainingTime = remainingTime < 0 and 0 or remainingTime
		-- local remainingDays = math.ceil(remainingTime/(3600 * 24))
		local remainingDays = (remote.recharge.monthCard1EndTime/1000 - q.refreshTime(remote.user.c_systemRefreshTime))/(3600 * 24)
		-- QLogFile:debug(string.format("month card1 end time %d, remainingDays %d", remote.recharge.monthCard1EndTime, remainingDays))

		if remainingDays > 0 then
			if taskInfo.state ~= QTask.TASK_COMPLETE then
				taskInfo.state = QTask.TASK_DONE
				taskInfo.isShow = true
			end
		else
			taskInfo.isShow = true
		end
	end
end

function QTask:monthCard2(taskId)
	if remote.recharge.monthCard2EndTime then
		local taskInfo = self:getDailyTaskById(taskId)

		-- local remainingTime = remote.recharge.monthCard2EndTime/1000 - q.serverTime()
		-- remainingTime = remainingTime < 0 and 0 or remainingTime
		-- local remainingDays = math.ceil(remainingTime/(3600 * 24))
		local remainingDays = (remote.recharge.monthCard2EndTime/1000 - q.refreshTime(remote.user.c_systemRefreshTime))/(3600 * 24)
		-- QLogFile:debug(string.format("month card2 end time %d, remainingDays %d", remote.recharge.monthCard2EndTime, remainingDays))
		
		if remainingDays > 0 then
			if taskInfo.state ~= QTask.TASK_COMPLETE then
				taskInfo.state = QTask.TASK_DONE
				taskInfo.isShow = true
			end
		else
			taskInfo.state = QTask.TASK_NONE
			taskInfo.isShow = true
		end
	end
end

--vip赠送高级召唤令
function QTask:vipLuckydrawEveryday(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	taskInfo.stepNum = QVIPUtil:VIPLevel()
	return self:taskDoneForNum(taskId)
end

--用餐时间领取体力
--这里开启一个计时器

function QTask:mealTimesEveryday(taskId)
	-- print("---s-a--sa-as--- -- -",  q.serverTime())
	local firstTaskInfo = self:getDailyTaskById("100000")
	firstTaskInfo.isShow = false
	local secondTaskInfo = self:getDailyTaskById("100001")
	secondTaskInfo.isShow = false
	local thirdTaskInfo = self:getDailyTaskById("100002")
	thirdTaskInfo.isShow = false

	local result = self:mealTimesEverydayById("100000", "12:00:00;14:00:00")
	local taskInfo = self:getDailyTaskById("100000")
	if taskInfo.timeHandler ~= nil then
		return result
	end

	local result = self:mealTimesEverydayById("100001", "18:00:00;20:00:00")
	local taskInfo = self:getDailyTaskById("100001")
	if taskInfo.timeHandler ~= nil then
		return result
	end
	
	local result = self:mealTimesEverydayById("100002", "21:00:00;24:00:00")
	local taskInfo = self:getDailyTaskById("100002")
	if taskInfo.timeHandler ~= nil then
		return result
	end

	return false
end

function QTask:mealTimesEverydayById(taskId, timeStr)

	local taskInfo = self:getDailyTaskById(taskId)
	if taskInfo.timeHandler  ~= nil then
		scheduler.unscheduleGlobal(taskInfo.timeHandler)
		taskInfo.timeHandler = nil
	end
	if taskInfo.state == QTask.TASK_COMPLETE then
		return false
	end
	local timeList = string.split(timeStr,";")
	
	local startTime = string.split(timeList[1],":")
	local endTime = string.split(timeList[2],":")
	startTime = q.getTimeForHMS(startTime[1], startTime[2], startTime[3])
	endTime = q.getTimeForHMS(endTime[1], endTime[2], endTime[3])
	-- print("startTime , endTime", taskId, startTime, endTime)
	--每日任务 5点刷新  当前时间小于5点  翻天
	local currTime = q.serverTime()
	local currdata = q.date("*t", q.serverTime())
	if currdata.hour < 5 then
		currTime = currTime + 24*60*60
	end

	--在吃饭之前 
	if currTime < startTime then
		if taskInfo.timeHandler == nil then
			taskInfo.timeHandler = scheduler.performWithDelayGlobal(function ()
				taskInfo.timeHandler = nil
				self:mealTimesEveryday()
				self:dispatchEvent({name = QTask.EVENT_TIME_DONE})
			end,(startTime-currTime))
		end
		taskInfo.isShow = true
		return false
	end
	--在吃饭之中
	if currTime >= startTime and currTime <= endTime then
		if taskInfo.timeHandler == nil then
			taskInfo.timeHandler = scheduler.performWithDelayGlobal(function ()
				taskInfo.timeHandler = nil
				self:mealTimesEveryday()
				self:dispatchEvent({name = QTask.EVENT_TIME_DONE})
			end,(endTime-currTime))
		end
		taskInfo.isShow = true
		if taskInfo.state ~= QTask.TASK_COMPLETE then
			taskInfo.state = QTask.TASK_DONE
			return true
		end
	end
	--吃饭之后
	if currTime > endTime then
		if taskInfo.state ~= QTask.TASK_COMPLETE then
			taskInfo.state = QTask.TASK_DONE_TOKEN
			taskInfo.token = QStaticDatabase.sharedDatabase():getConfigurationValue("energy_buy") 
			taskInfo.isShow = true
			return true
		else
			taskInfo.state = QTask.TASK_NONE
			taskInfo.isShow = false
		end
		-- if taskInfo.state ~= QTask.TASK_NONE then
		-- 	taskInfo.state = QTask.TASK_NONE
		-- 	self:dispatchEvent({name = QTask.EVENT_TIME_DONE})
		-- else
		-- 	taskInfo.state = QTask.TASK_NONE
		-- end
	end
	return false
end

-- 获取月卡每日领取的奖励倍数
function QTask:getCardMultiple()
	local multipleTime = db:getConfigurationValue("month_card_token_award_buff_day") or "6,7"

	multipleTime = string.split(multipleTime, ",")
	local curWday = q.date("*t", q.serverTime()).wday - 1
	if curWday == 0 then
		curWday = 7
	end
	curWday = tostring(curWday)

	if multipleTime then
		for _, val in ipairs(multipleTime) do
			if val == curWday then
				return db:getConfigurationValue("month_card_token_award_buff_ multiple") or 2
			end
		end
	end
	return 1
end

function QTask:drawCard(index)
	local taskInfo = self:getDailyTaskById(index)
	local awards = {}
	local multiple = self:getCardMultiple()
	if taskInfo.config.id_1 ~= nil or taskInfo.config.type_1 ~= nil then
		table.insert(awards, {id = taskInfo.config.id_1, typeName = taskInfo.config.type_1, count = taskInfo.config.num_1 * multiple})
	end

	app:getClient():dailyTaskComplete({index}, false, function()
		remote.activity:updateLocalDataByType(503, 1)
  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    		options = {awards = awards, callBack = function ()
				remote.user:checkTeamUp()
    		end}}, {isPopCurrentDialog = false} )
    	dialog:setTitle("恭喜您获得月卡奖励")

    	remote.activity:dispatchEvent({name = remote.activity.EVENT_CHANGE})
	end)
end





--每周任务相关
--周常数据请求服务发送
--

--每周任务总处理方法
function QTask:handlerWeeklyTask(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	-- if taskId == "110000" then
	-- 	remote.task:updateUserWeekTaskInfoCount("todayActivity1_1Count".."^".."todayActivity2_1Count".."^".."todayActivity3_1Count".."^".."todayActivity4_1Count")
	-- end
	taskInfo.stepNum = self:getWeeklyTaskNumById(taskId) + self:getTaskLocalTotleNum(taskId)
	return self:taskDoneForNum(taskId)
end

--[[
	任务的快捷链接
]]
function QTask:quickLink(taskId)
	local taskInfo = self:getDailyTaskById(taskId)
	if taskId == "210001" then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVip", options = {vipContentLevel = taskInfo.config.num}})
	elseif taskId == "102900" then
		remote.arena:openArena(0)
	elseif taskInfo.config.link then
		-- 检查shortcut表
		local shortcutInfo = QStaticDatabase.sharedDatabase():getShortcut()
		local quickInfo = {}
		for _, value in pairs(shortcutInfo) do
			if value.cname == taskInfo.config.link then
				quickInfo = value
				break
			end
		end
		-- 检查item_user_link表
		if next(quickInfo) == nil then
			local linkInfo = QStaticDatabase.sharedDatabase():getItemUseLink()
			for _, value in pairs(linkInfo) do
				if value.cname == taskInfo.config.link then
					quickInfo = value
					break
				end
			end
		end

		if next(quickInfo) then
			QQuickWay:clickGoto(quickInfo)
		end
	end
end


function QTask:responseHandler(data, success, fail, succeeded)
	-- if data.userWeekTaskInfo then
	-- 	self:updateUserWeekTaskInfo(data.userWeekTaskInfo)
	-- 	self:dispatchEvent({name = remote.TASK_UPDATE_EVENT})
	-- 	 print("self:dispatchEvent({name = remote.TASK_UPDATE_EVENT}) -- weekly。QTask")
	-- end
	if succeeded == true then
        if success ~= nil then
            success(data)
        end
    else
        if fail ~= nil then
            fail(data)
        end
    end
end


function QTask:weeklyTaskGetInfo(success,fail)
    local request = {api = "WEEK_TASK_GET_INFO"}
	app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end, nil, nil, false)
end



return QTask