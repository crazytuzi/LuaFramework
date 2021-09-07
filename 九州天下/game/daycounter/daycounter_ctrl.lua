
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
			RemindManager.Instance:Fire(RemindName.CampWarYunBiao)
		--elseif (DAY_COUNT.DAYCOUNT_ID_FREE_CHEST_BUY_1) == k then
			--XunbaoCtrl.Instance:OnMianfeiNum(v)
		--elseif (DAY_COUNT.DAYCOUNT_ID_MAZE_MOVE) == k then
		elseif (DAY_COUNT.DAYCOUNT_ID_HUSONG_TASK_VIP_BUY_COUNT) == k then
			YunbiaoCtrl.Instance:OnGouMaiCiShuChangeHandler(v)
			RemindManager.Instance:Fire(RemindName.CampWarYunBiao)
		elseif (DAY_COUNT.DAYCOUNT_ID_HUSONG_REFRESH_COLOR_FREE_TIMES) == k then
			YunbiaoCtrl.Instance:OnChangeRefreshFreeTimeHandler(v)
			RemindManager.Instance:Fire(RemindName.CampWarYunBiao)
		elseif (DAY_COUNT.DAYCOUNT_ID_GUILD_REWARD) == k then
			GuildData.Instance:SetGuildNewFuLiCount(v)
		elseif DAY_COUNT.DAYCOUNT_ID_FB_EXP == k then
			FuBenData.Instance:SetExpDayCount(v)
			RemindManager.Instance:Fire(RemindName.FuBenExp)
		elseif DAY_COUNT.DAYCOUNT_ID_CAMP_TASK_YINGJIU_ACCEPT_TIMES == k or DAY_COUNT.DAYCOUNT_ID_CAMP_TASK_YINGJIU_BUY_TIMES == k then
			NationalWarfareCtrl.Instance:Flush("flush_yingjiu_view")
			NationalWarfareCtrl.Instance:FlushYingJiuTask()
			RemindManager.Instance:Fire(RemindName.CampWarYingJiu)
		elseif DAY_COUNT.DAYCOUNT_ID_CAMP_TASK_BANZHUAN_ACCEPT_TIMES == k or DAY_COUNT.DAYCOUNT_ID_CAMP_TASK_BANZHUAN_BUY_TIMES == k then
			NationalWarfareCtrl.Instance:Flush("flush_banzhuan_view")
			RemindManager.Instance:Fire(RemindName.CampWarBanzhuang)
		elseif DAY_COUNT.DAYCOUNT_ID_CAMP_TASK_CITAN_ACCEPT_TIMES == k or DAY_COUNT.DAYCOUNT_ID_CAMP_TASK_CITAN_BUY_TIMES == k then
			NationalWarfareCtrl.Instance:Flush("flush_citian_view")
			RemindManager.Instance:Fire(RemindName.CampWarCiTan)
		elseif (DAY_COUNT.DAYCOUNT_ID_MONEY_TREE_COUNT) == k then
			ZhuanZhuanLeCtrl.Instance:OnDayTreeCount(v)
		elseif (DAY_COUNT.DAYCOUNT_ID_JINGLING_SKILL_COUNT) == k then
			AdvanceSkillData.Instance:SetPlayerRefreshCount(v)
		elseif  DAY_COUNT.DAYCOUNT_ID_TEAM_TOWERDEFEND_JOIN_TIMES == k  or DAY_COUNT.DAYCOUNT_ID_EQUIP_TEAM_FB_JOIN_TIMES == k then
			TeamFbCtrl.Instance:SCFBInfo(k,v)

		--elseif (DAY_COUNT.DAYCOUNT_ID_YAOSHOUJITAN_JOIN_TIMES) == k then
			--DailyData.Instance:SetTeamFbEnterTimes(TEAM_TYPE.YAOSHOUJITANG, v)
		--elseif (DAY_COUNT.DAYCOUNT_ID_VIP_FREE_REALIVE) == k then
		--elseif (DAY_COUNT.VAT_TOWERDEFEND_FB_FREE_AUTO_TIMES) == k then
		--elseif (DAY_COUNT.DAYCOUNT_ID_CHALLENGE_FREE_AUTO_FB_TIMES) == k then
		--elseif (DAY_COUNT.DAYCOUNT_ID_GCZ_DAILY_REWARD_TIMES) == k then
		--elseif (DAY_COUNT.DAYCOUNT_ID_XIANMENGZHAN_RANK_REWARD_TIMES) == k then
			--GuildCtrl.Instance:SetXianMengZhanRewardCounter(v)
		--elseif (DAY_COUNT.DAYCOUNT_ID_MOBAI_CHENGZHU_REWARD_TIMES) == k then
		--elseif (DAY_COUNT.DAYCOUNT_ID_FB_COIN) == k
		--		or (DAY_COUNT.DAYCOUNT_ID_FB_XIANNV) == k
		--		or (DAY_COUNT.DAYCOUNT_ID_FB_QIBING) == k
		--		or (DAY_COUNT.DAYCOUNT_ID_FB_WING) == k
		--		or (DAY_COUNT.DAYCOUNT_ID_FB_XIULIAN) == k then
		--elseif (DAY_COUNT.DAYCOUNT_ID_GUILD_ZHUFU_TIMES) == k then
			--GuildCtrl.Instance:FlushLuck()
		--elseif DAY_COUNT.DAYCOUNT_ID_TEAM_TOWERDEFEND_JOIN_TIMES == k then
			--DailyData.Instance:SetTeamFbEnterTimes(TEAM_TYPE.DUORENTAFANG, v)
		--elseif DAY_COUNT.DAYCOUNT_ID_MIGOGNXIANFU_JOIN_TIMES == k then
			--DailyData.Instance:SetTeamFbEnterTimes(TEAM_TYPE.MIGONGXIANFU, v)
		end
	end
	GlobalEventSystem:Fire(OtherEventType.DAY_COUNT_CHANGE, -1)
end

function DayCounterCtrl:LockOpenTaskRewardPanel(is_lock)
	self.is_lock_open_task_reward_panel = is_lock
end

function DayCounterCtrl:GetLockOpenTaskRewardPanel()
	return self.is_lock_open_task_reward_panel
end

function DayCounterCtrl:OnDayCounterItemInfo(protocol)
	self.data:SetDayCount(protocol.day_counter_id, protocol.day_counter_value)

	if DAY_COUNT.DAYCOUNT_ID_ACCEPT_HUSONG_TASK_COUNT == protocol.day_counter_id then
		YunbiaoCtrl.Instance:OnLingQuCiShuChangeHandler(protocol.day_counter_value)
		RemindManager.Instance:Fire(RemindName.CampWarYunBiao)
	--elseif DAY_COUNT.DAYCOUNT_ID_FREE_CHEST_BUY_1 == protocol.day_counter_id then
		--XunbaoCtrl.Instance:OnChangeMianfeiNum(protocol.day_counter_value)
	--elseif DAY_COUNT.DAYCOUNT_ID_MAZE_MOVE == protocol.day_counter_id then
	elseif DAY_COUNT.DAYCOUNT_ID_HUSONG_TASK_VIP_BUY_COUNT == protocol.day_counter_id then
		YunbiaoCtrl.Instance:OnGouMaiCiShuChangeHandler(protocol.day_counter_value)
		RemindManager.Instance:Fire(RemindName.CampWarYunBiao)
	elseif DAY_COUNT.DAYCOUNT_ID_HUSONG_REFRESH_COLOR_FREE_TIMES == protocol.day_counter_id then
		YunbiaoCtrl.Instance:OnChangeRefreshFreeTimeHandler(protocol.day_counter_value)
		RemindManager.Instance:Fire(RemindName.CampWarYunBiao)
	elseif (DAY_COUNT.DAYCOUNT_ID_GUILD_TASK_COMPLETE_COUNT) == protocol.day_counter_id then
		GuildData.Instance:SetRiChangTask(protocol.day_counter_value)
		TipsCtrl.Instance:OpenTaskRewardPanle()
		TaskCtrl.Instance:CancelTask()
	elseif (DAY_COUNT.DAYCOUNT_ID_COMMIT_DAILY_TASK_COUNT) == protocol.day_counter_id then
		GuildData.Instance:SetRiChangTask(protocol.day_counter_value)
		if not self.is_lock_open_task_reward_panel then
			TipsCtrl.Instance:OpenTaskRewardPanle()
		end
		self:LockOpenTaskRewardPanel(false)
		TaskCtrl.Instance:CancelTask()
	elseif DAY_COUNT.DAYCOUNT_ID_GUILD_REWARD == protocol.day_counter_id then
		GuildData.Instance:SetGuildNewFuLiCount(protocol.day_counter_value)
	elseif DAY_COUNT.DAYCOUNT_ID_FB_EXP == protocol.day_counter_id then
		FuBenData.Instance:SetExpDayCount(protocol.day_counter_value)
		RemindManager.Instance:Fire(RemindName.FuBenExp)
	elseif DAY_COUNT.DAYCOUNT_ID_CAMP_TASK_YINGJIU_ACCEPT_TIMES == protocol.day_counter_id or DAY_COUNT.DAYCOUNT_ID_CAMP_TASK_YINGJIU_BUY_TIMES == protocol.day_counter_id then
		NationalWarfareCtrl.Instance:Flush("flush_yingjiu_view")
		NationalWarfareCtrl.Instance:FlushYingJiuTask()
		RemindManager.Instance:Fire(RemindName.CampWarYingJiu)
	elseif DAY_COUNT.DAYCOUNT_ID_CAMP_TASK_BANZHUAN_ACCEPT_TIMES == protocol.day_counter_id or DAY_COUNT.DAYCOUNT_ID_CAMP_TASK_BANZHUAN_BUY_TIMES == protocol.day_counter_id then
		NationalWarfareCtrl.Instance:Flush("flush_banzhuan_view")
		RemindManager.Instance:Fire(RemindName.CampWarBanzhuang)
	elseif DAY_COUNT.DAYCOUNT_ID_CAMP_TASK_CITAN_ACCEPT_TIMES == protocol.day_counter_id or DAY_COUNT.DAYCOUNT_ID_CAMP_TASK_CITAN_BUY_TIMES == protocol.day_counter_id then
		NationalWarfareCtrl.Instance:Flush("flush_citian_view")
		RemindManager.Instance:Fire(RemindName.CampWarCiTan)
	elseif DAY_COUNT.DAYCOUNT_ID_JINGLING_SKILL_COUNT == protocol.day_counter_id then
		AdvanceSkillData.Instance:SetPlayerRefreshCount(protocol.day_counter_value)
	elseif DAY_COUNT.DAYCOUNT_ID_TEAM_TOWERDEFEND_JOIN_TIMES == protocol.day_counter_id or DAY_COUNT.DAYCOUNT_ID_EQUIP_TEAM_FB_JOIN_TIMES == protocol.day_counter_id then
		TeamFbCtrl.Instance:SCFBInfo(protocol.day_counter_id, protocol.day_counter_value)
	--elseif DAY_COUNT.DAYCOUNT_ID_YAOSHOUJITAN_JOIN_TIMES == protocol.day_counter_id then
		--DailyData.Instance:SetTeamFbEnterTimes(TEAM_TYPE.YAOSHOUJITANG, v)
	--elseif DAY_COUNT.DAYCOUNT_ID_VIP_FREE_REALIVE == protocol.day_counter_id then
	--elseif DAY_COUNT.VAT_TOWERDEFEND_FB_FREE_AUTO_TIMES == protocol.day_counter_id then
	--elseif DAY_COUNT.DAYCOUNT_ID_CHALLENGE_FREE_AUTO_FB_TIMES == protocol.day_counter_id then
	--elseif (DAY_COUNT.DAYCOUNT_ID_GCZ_DAILY_REWARD_TIMES) == protocol.day_counter_id then
	--elseif (DAY_COUNT.DAYCOUNT_ID_XIANMENGZHAN_RANK_REWARD_TIMES) == protocol.day_counter_id then
		--GuildCtrl.Instance:SetXianMengZhanRewardCounter(protocol.day_counter_value)
	--elseif (DAY_COUNT.DAYCOUNT_ID_MOBAI_CHENGZHU_REWARD_TIMES) == protocol.day_counter_id then
	--elseif DAY_COUNT.DAYCOUNT_ID_FB_COIN  == protocol.day_counter_id
	--		or DAY_COUNT.DAYCOUNT_ID_FB_XIANNV == protocol.day_counter_id
	--		or DAY_COUNT.DAYCOUNT_ID_FB_QIBING == protocol.day_counter_id
	--		or DAY_COUNT.DAYCOUNT_ID_FB_WING == protocol.day_counter_id
	--		or DAY_COUNT.DAYCOUNT_ID_FB_XIULIAN == protocol.day_counter_id then
	--elseif (DAY_COUNT.DAYCOUNT_ID_GUILD_ZHUFU_TIMES) == protocol.day_counter_id then
		--GuildCtrl.Instance:FlushLuck()
	--elseif DAY_COUNT.DAYCOUNT_ID_TEAM_TOWERDEFEND_JOIN_TIMES == protocol.day_counter_id then
		--DailyData.Instance:SetTeamFbEnterTimes(TEAM_TYPE.DUORENTAFANG, protocol.day_counter_value)
	--elseif DAY_COUNT.DAYCOUNT_ID_MIGOGNXIANFU_JOIN_TIMES == protocol.day_counter_id then
		--DailyData.Instance:SetTeamFbEnterTimes(TEAM_TYPE.MIGONGXIANFU, protocol.day_counter_value)
	end
	GlobalEventSystem:Fire(OtherEventType.DAY_COUNT_CHANGE, protocol.day_counter_id)
end