
require("game/daycounter/daycounter_data")

DayCounterCtrl = DayCounterCtrl or BaseClass(BaseController)

function DayCounterCtrl:__init()
	if DayCounterCtrl.Instance ~= nil then
		ErrorLog("[DayCounterCtrl] attempt to create singleton twice!")
		return
	end
	DayCounterCtrl.Instance = self
	self.data = DayCounterData.New()
	self:RegisterAllProtocols()
end

function DayCounterCtrl:__delete()
	DayCounterCtrl.Instance = nil

	self.data:DeleteMe()
	self.data = nil
end

function DayCounterCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCDayCounterInfo, 'OnDayCounterInfo')
	self:RegisterProtocol(SCDayCounterItemInfo, 'OnDayCounterItemInfo')
end

function DayCounterCtrl:OnDayCounterInfo(protocol)
	for k, v in pairs(protocol.daycount_list) do
		self.data:SetDayCount(k, v)

		if (DAY_COUNT.DAYCOUNT_ID_ACCEPT_HUSONG_TASK_COUNT) == k then
			YunbiaoCtrl.Instance:OnLingQuCiShuChangeHandler(v)
		elseif (DAY_COUNT.DAYCOUNT_ID_HUSONG_TASK_VIP_BUY_COUNT) == k then
			YunbiaoCtrl.Instance:OnGouMaiCiShuChangeHandler(v)
		elseif (DAY_COUNT.DAYCOUNT_ID_HUSONG_REFRESH_COLOR_FREE_TIMES) == k then
			YunbiaoCtrl.Instance:OnChangeRefreshFreeTimeHandler(v)
		elseif (DAY_COUNT.DAYCOUNT_ID_BUY_MIKU_WERARY) == k then
			BossCtrl.Instance:OnBuyMikuWeraryChange(v)
		elseif (DAY_COUNT.DAYCOUNT_ID_JINGLING_SKILL_COUNT) == k then
			SpiritCtrl.Instance:OnSkillFreeRefreshTimesChange(v)
		elseif (DAY_COUNT.DAYCOUNT_ID_MONEY_TREE_COUNT) == k then
			ZhuanZhuanLeCtrl.Instance:OnDayTreeCount(v)
		elseif DAY_COUNT.DAYCOUNT_ID_XIANJIE_BOSS == k then
			BossCtrl.Instance:SetXianJieBossDayCount(v)
		elseif DAY_COUNT.DAYCOUNT_ID_GUAJI_BOSS_KILL_COUNT == k then
			YewaiGuajiCtrl.Instance:SetCurHasKillBossCount(v)
		elseif DAY_COUNT.DAYCOUNT_ID_ENCOUNTER_BOSS_ENTER_COUNT == k then
			BossCtrl.Instance:OnEncounterBossEnterTimesChange(v)
		elseif DAY_COUNT.DAYCOUNT_ID_YAOSHOUJITAN_JOIN_TIMES == k or DAY_COUNT.DAYCOUNT_ID_TEAM_TOWERDEFEND_JOIN_TIMES == k
		 or DAY_COUNT.DAYCOUNT_ID_EQUIP_TEAM_FB_JOIN_TIMES == k or DAY_COUNT.DAYCOUNT_ID_TEAM_FB_ASSIST_TIMES == k then
			TeamFbCtrl.Instance:SCFBInfo(k,v)
		end
	end
	GlobalEventSystem:Fire(OtherEventType.DAY_COUNT_CHANGE, -1)

	for _, v in ipairs(DayCounterChange) do
		RemindManager.Instance:Fire(v)
	end
end

function DayCounterCtrl:OnDayCounterItemInfo(protocol)
	self.data:SetDayCount(protocol.day_counter_id, protocol.day_counter_value)
	if DAY_COUNT.DAYCOUNT_ID_ACCEPT_HUSONG_TASK_COUNT == protocol.day_counter_id then
		YunbiaoCtrl.Instance:OnLingQuCiShuChangeHandler(protocol.day_counter_value)
	elseif DAY_COUNT.DAYCOUNT_ID_HUSONG_TASK_VIP_BUY_COUNT == protocol.day_counter_id then
		YunbiaoCtrl.Instance:OnGouMaiCiShuChangeHandler(protocol.day_counter_value)
	elseif DAY_COUNT.DAYCOUNT_ID_HUSONG_REFRESH_COLOR_FREE_TIMES == protocol.day_counter_id then
		YunbiaoCtrl.Instance:OnChangeRefreshFreeTimeHandler(protocol.day_counter_value)
	elseif (DAY_COUNT.DAYCOUNT_ID_GUILD_TASK_COMPLETE_COUNT) == protocol.day_counter_id or (DAY_COUNT.DAYCOUNT_ID_COMMIT_DAILY_TASK_COUNT) == protocol.day_counter_id then
		TipsCtrl.Instance:FlushTaskRewardView()
	elseif (DAY_COUNT.DAYCOUNT_ID_BUY_MIKU_WERARY) == protocol.day_counter_id then
		BossCtrl.Instance:OnBuyMikuWeraryChange(protocol.day_counter_value)
	elseif (DAY_COUNT.DAYCOUNT_ID_JINGLING_SKILL_COUNT) == protocol.day_counter_id then
		SpiritCtrl.Instance:OnSkillFreeRefreshTimesChange(protocol.day_counter_value)
	elseif (DAY_COUNT.DAYCOUNT_ID_MONEY_TREE_COUNT) == protocol.day_counter_id then
		ZhuanZhuanLeCtrl.Instance:OnDayTreeCount(protocol.day_counter_value)
	elseif DAY_COUNT.DAYCOUNT_ID_GUAJI_BOSS_KILL_COUNT == protocol.day_counter_id then
			YewaiGuajiCtrl.Instance:SetCurHasKillBossCount(protocol.day_counter_value)
	elseif DAY_COUNT.DAYCOUNT_ID_XIANJIE_BOSS == protocol.day_counter_id then
		BossCtrl.Instance:SetXianJieBossDayCount(protocol.day_counter_value)
	elseif DAY_COUNT.DAYCOUNT_ID_ENCOUNTER_BOSS_ENTER_COUNT == protocol.day_counter_id then
		BossCtrl.Instance:OnEncounterBossEnterTimesChange(protocol.day_counter_value)
	elseif DAY_COUNT.DAYCOUNT_ID_YAOSHOUJITAN_JOIN_TIMES == protocol.day_counter_id or DAY_COUNT.DAYCOUNT_ID_TEAM_TOWERDEFEND_JOIN_TIMES == protocol.day_counter_id
		 or DAY_COUNT.DAYCOUNT_ID_EQUIP_TEAM_FB_JOIN_TIMES == protocol.day_counter_id or DAY_COUNT.DAYCOUNT_ID_TEAM_FB_ASSIST_TIMES == protocol.day_counter_id then
		TeamFbCtrl.Instance:SCFBInfo(protocol.day_counter_id,protocol.day_counter_value)
	end

	GlobalEventSystem:Fire(OtherEventType.DAY_COUNT_CHANGE, protocol.day_counter_id)

	for _, v in ipairs(DayCounterChange) do
		RemindManager.Instance:Fire(v)
	end
end