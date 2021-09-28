KuaFuXiuLuoTowerFuBenInfoView = KuaFuXiuLuoTowerFuBenInfoView or BaseClass(BaseView)

function KuaFuXiuLuoTowerFuBenInfoView:__init()
	self.ui_config = {"uis/views/kuafuxiuluotower_prefab","XiuLuoFuBenInfoView"}
	self.active_close = false
	self.fight_info_view = true
	-- self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.mode_vis = true
	self.menu_vis = true
end

function KuaFuXiuLuoTowerFuBenInfoView:ReleaseCallBack()
	if self.rank_list then
		self.rank_list:DeleteMe()
		self.rank_list = nil
	end
	if self.task_view then
		self.task_view:DeleteMe()
		self.task_view = nil
	end
	if self.score_view then
		self.score_view:DeleteMe()
		self.score_view = nil
	end
	-- if self.victory_view then
	-- 	self.victory_view:DeleteMe()
	-- end

	if self.show_mode_list_event ~= nil then
		GlobalEventSystem:UnBind(self.show_mode_list_event)
		self.show_mode_list_event = nil
	end
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
	self.is_drop_level = nil
	self.tips_level_value = nil
	self.in_or_out_text = nil
	self.change_level = nil
	self.task_view = nil
	self.score_view = nil
	self.show_panel = nil
	self.change_layer_tips = nil
end

function KuaFuXiuLuoTowerFuBenInfoView:LoadCallBack()
	local id = GameVoManager.Instance:GetMainRoleVo().role_id
	self.is_drop_level = self:FindVariable("IsDropLevel")
	self.tips_level_value = self:FindVariable("TipsLevelValue")
	self.in_or_out_text = self:FindVariable("InOrOutText")
	self.change_level = self:FindVariable("ChangeLevel")

	self.task_view = XiuLuoTaskView.New(self:FindObj("TaskView"))
	self.score_view = XiuLuoScoreView.New(self:FindObj("ScoreView"))
	-- self.victory_view = XiuLuoVictoryView.New(self:FindObj("VictoryPlane"))
	-- self.victory_view:SetActive(false)
	self.rank_list = KuaFuXiuLuoTowerRankList.New(self:FindObj("RankList"))
	self.rank_list:SetActive(false)

	self.show_panel = self:FindVariable("ShowPanel")

	self.change_layer_tips = self:FindObj("ChangeLayerTips")

	self:ListenEvent("ExitClick",BindTool.Bind(self.ExitClick, self))
	self:ListenEvent("CloseRankList",BindTool.Bind(self.SetRankListVisable, self, false))
	self:ListenEvent("OpenRankList",BindTool.Bind(self.SetRankListVisable, self, true))
	self.show_mode_list_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, BindTool.Bind(self.OnMainUIModeListChange, self))
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
end
function KuaFuXiuLuoTowerFuBenInfoView:OpenCallBack()
	FuBenCtrl.Instance:SetMonsterClickCallBack(BindTool.Bind(self.ClickBoss, self), 1)
	FuBenCtrl.Instance:SetMonsterInfo(KuaFuXiuLuoTowerData.Instance:GetMonsterID())
	self:Flush()
end

function KuaFuXiuLuoTowerFuBenInfoView:SwitchButtonState(enable)
	self.menu_vis = enable
	self.show_panel:SetValue(self.menu_vis and self.mode_vis)
end

function KuaFuXiuLuoTowerFuBenInfoView:CloseCallBack()
	FuBenCtrl.Instance:ClearMonsterClickCallBack()
end

function KuaFuXiuLuoTowerFuBenInfoView:SetRankListVisable(is_show)
	self.rank_list:SetActive(is_show)
end

function KuaFuXiuLuoTowerFuBenInfoView:OnMainUIModeListChange(is_show)
	self.mode_vis = not is_show
	self.show_panel:SetValue(self.menu_vis and self.mode_vis)
end

function KuaFuXiuLuoTowerFuBenInfoView:FlushRank()
	if self:IsLoaded() then
		self.rank_list:Flush()
	end
end

--改层提示
function KuaFuXiuLuoTowerFuBenInfoView:OnLayerChange(data)
	if not self:IsLoaded() or data == nil then
		return
	end
	if data.is_drop_layer == 1 then
		--掉层
		self.in_or_out_text:SetValue(Language.XiuLuo.GoBack)
		self.change_level:SetValue(KuaFuXiuLuoTowerData.Instance:GetCurrentLayer() - 1)
	else
		--升层
		self.in_or_out_text:SetValue(Language.XiuLuo.GoForward)
		self.change_level:SetValue(KuaFuXiuLuoTowerData.Instance:GetCurrentLayer() + 1)
	end

	GlobalTimerQuest:AddDelayTimer(function()
		self.change_layer_tips.animator:SetTrigger("Show")
	end, 0.5)
end

function KuaFuXiuLuoTowerFuBenInfoView:OnFlush()
	-- local cu_layer = KuaFuXiuLuoTowerData.Instance:GetCurrentLayer()
	-- local is_drop_level = KuaFuXiuLuoTowerData.Instance:GetIsDropLayer(cu_layer)
	local is_show_drop_des = KuaFuXiuLuoTowerData.Instance:GetCurLayerDes()
	if nil ~= is_show_drop_des then
		self.is_drop_level:SetValue(is_show_drop_des)
	end
	self.task_view:Flush()
	self.score_view:Flush()
end

function KuaFuXiuLuoTowerFuBenInfoView:ExitClick()
	local func = function()
		CrossServerCtrl.Instance:GoBack()
	end
	TipsCtrl.Instance:ShowCommonTip(func, nil, Language.Common.ExitFuBen)
end

function KuaFuXiuLuoTowerFuBenInfoView:OnSelfInfoChange()
	self:Flush()
end


function KuaFuXiuLuoTowerFuBenInfoView:ClickBoss()
	local cu_layer = KuaFuXiuLuoTowerData.Instance:GetCurrentLayer()
	local max_layer = KuaFuXiuLuoTowerData.Instance:GetMaxLayer()
	if cu_layer >= max_layer then
		-- GuajiCtrl.Instance:SetGuajiType(GuajiType.Monster)
		-- GuajiCache.monster_id = KuaFuXiuLuoTowerData.Instance:GetMonsterID()
		-- MoveCache.end_type = MoveEndType.FightByMonsterId
		-- MoveCache.param1 = KuaFuXiuLuoTowerData.Instance:GetMonsterID()
		local x, y = KuaFuXiuLuoTowerData.Instance:GetGuajiXY()
		MoveCache.end_type = MoveEndType.Auto
		GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
		GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), x, y, 10, 1)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.XiuLuo.PleaseUp)
	end
end

----------------------任务View----------------------
XiuLuoTaskView = XiuLuoTaskView or BaseClass(BaseRender)
function XiuLuoTaskView:__init()
	self.kill_count = self:FindVariable("KillCount")
	self.progress_value = self:FindVariable("ProcessValue")
	self.now_level = self:FindVariable("NowLevel")
	self.next_level = self:FindVariable("NextLevel")
	self.progress_text = self:FindVariable("ProgressText")
	self.is_max_layer = self:FindVariable("IsMaxLayer")
	self.reward_all = self:FindVariable("RewardAll")
	self.boss_state = self:FindVariable("BossState")
	self.boss_has_kill = self:FindVariable("BossHasKill")
	self.kill_one_honor = self:FindVariable("KillOneHonor")
	self.cur_all_honor = self:FindVariable("CurAllHonor")

	self.boss_reward_list = {}
	self.gather_reward_list = {}
	self.boss_name = ""
	for i = 1, 3 do
		self.boss_reward_list[i] = ItemCell.New()
		self.boss_reward_list[i]:SetInstanceParent(self:FindObj("BossReward"..i))

		self.gather_reward_list[i] = ItemCell.New()
		self.gather_reward_list[i]:SetInstanceParent(self:FindObj("GatherReward" .. i))

		self["box_count" .. i] = self:FindVariable("BoxCount" .. i)
		self:ListenEvent("ClickBox" .. i,BindTool.Bind(self.ClickBox, self, i))
	end

	local boss_id = KuaFuXiuLuoTowerData.Instance:GetMonsterID()
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	if monster_cfg then
		local cfg = monster_cfg[boss_id]
		if cfg then
			self.boss_name = cfg.name
		end
	end

	self:GatherRewardFlush()
	self:BossRewardFlush()
end

function XiuLuoTaskView:__delete()
	for k,v in pairs(self.boss_reward_list) do
		v:DeleteMe()
	end
	self.boss_reward_list = {}

	for k,v in pairs(self.gather_reward_list) do
		v:DeleteMe()
	end
	self.gather_reward_list = {}

	GlobalTimerQuest:CancelQuest(self.boss_countdown)
end

local old_layer = -1
function XiuLuoTaskView:Flush()
	GlobalTimerQuest:CancelQuest(self.boss_countdown)
	local cu_layer = KuaFuXiuLuoTowerData.Instance:GetCurrentLayer()
	local max_layer = KuaFuXiuLuoTowerData.Instance:GetMaxLayer()
	local history_max_layer = KuaFuXiuLuoTowerData.Instance:GetHistoryMaxLayer()
	local boss_num = KuaFuXiuLuoTowerData.Instance:GetBossNum()
	local kill_count = KuaFuXiuLuoTowerData.Instance:GetCurrentLayerKillCount()
	local kill_role_count = KuaFuXiuLuoTowerData.Instance:GetAllKillRoleCount()
	local kill_one_honor = ConfigManager.Instance:GetAutoConfig("kuafu_rongyudiantang_auto").other[1].Kill_rongyao
	self.kill_one_honor:SetValue(string.format(Language.Honorhalls.SkillRewardTxt[1], 1, kill_one_honor))
	local all_honor = kill_role_count * kill_one_honor
	all_honor = all_honor > 2000 and 2000 or all_honor
	self.cur_all_honor:SetValue(string.format(Language.Honorhalls.SkillRewardTxt[2], all_honor))
	local cur_layer_cfg = KuaFuXiuLuoTowerData.Instance:GetLayerCfgByLayer(cu_layer)
	self.reward_all:SetValue(history_max_layer >= max_layer)
	self.progress_value:SetValue(kill_count / cur_layer_cfg.need_kill_count)
	self.progress_text:SetValue(kill_count.." / "..cur_layer_cfg.need_kill_count)
	if boss_num > 0 then
		FuBenCtrl.Instance:ShowMonsterHadFlush(true)
		self.boss_state:SetValue("")
		self.boss_has_kill:SetValue(false)
	else
		FuBenCtrl.Instance:ShowMonsterHadFlush(false)
		self.boss_has_kill:SetValue(true)
		local gather_info_list = KuaFuXiuLuoTowerData.Instance:GetGatherInfo()
		if gather_info_list then
			for i = 1, 2 do
				local count = gather_info_list[i] and gather_info_list[i].gather_count or 0
				local gather_id = gather_info_list[i] and gather_info_list[i].gather_id or 0
				local index = KuaFuXiuLuoTowerData.Instance:GetGatherIndex(gather_id) or 1
				self["box_count".. index]:SetValue(count)
			end
		end
	end

	self.now_level:SetValue(cu_layer)

	self.is_max_layer:SetValue(cu_layer >= max_layer)
	if old_layer ~= cu_layer then
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
		GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	end
	if cu_layer >= max_layer then
		--到达顶层
		self.next_level:SetValue("")
	elseif old_layer ~= cu_layer then
		self.next_level:SetValue(cu_layer + 1)
	end
	local total_kill_count = KuaFuXiuLuoTowerData.Instance:GetAllKillRoleCount() or 0
	self.kill_count:SetValue(total_kill_count)
	if boss_num <= 0 then
		if self.boss_countdown then
			GlobalTimerQuest:CancelQuest(self.boss_countdown)
			self.boss_countdown = nil
		end
		self.boss_countdown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.BossTimeCountDown, self), 1)
		self:BossTimeCountDown()
		local boss_refresh_time = KuaFuXiuLuoTowerData.Instance:GetBossRefreshTime()
		local rest_time = math.floor(boss_refresh_time - TimeCtrl.Instance:GetServerTime())
		if rest_time > 0 then
			FuBenCtrl.Instance:SetMonsterDiffTime(rest_time)
		end
	end
	old_layer = cu_layer
end

function XiuLuoTaskView:BossTimeCountDown()
	local boss_refresh_time = KuaFuXiuLuoTowerData.Instance:GetBossRefreshTime()
	local seconds = math.floor(boss_refresh_time - TimeCtrl.Instance:GetServerTime())
	if seconds <= 0 then
		self.boss_state:SetValue(string.format(Language.XiuLuo.BossState[2], TimeUtil.FormatSecond(0, 3)))
		GlobalTimerQuest:CancelQuest(self.boss_countdown)
		return
	end
	self.boss_state:SetValue(string.format(Language.XiuLuo.BossState[2], TimeUtil.FormatSecond(seconds, 3)))
end

function XiuLuoTaskView:ClickBox(index)
end

function XiuLuoTaskView:GatherRewardFlush()
	local gather_reward_list = KuaFuXiuLuoTowerData.Instance:GetGatherBoxReward()
	for k,v in ipairs(self.gather_reward_list) do
		v:SetData(gather_reward_list[k - 1])
		v.root_node:SetActive(gather_reward_list[k - 1] ~= nil)
	end
end

function XiuLuoTaskView:BossRewardFlush()
	local reward_list = KuaFuXiuLuoTowerData.Instance:GetBossReward()
	for k,v in ipairs(self.boss_reward_list) do
		v:SetData(reward_list[k - 1])
		v.root_node:SetActive(reward_list[k - 1] ~= nil)
	end
end

----------------------积分View----------------------
XiuLuoScoreView = XiuLuoScoreView or BaseClass(BaseRender)
function XiuLuoScoreView:__init()
	self.my_score = self:FindVariable("MyScore")
	self.reach_score = self:FindVariable("ReachScore")
	self.reward_all = self:FindVariable("RewardAll")
	self.reward_list = {}
	for i = 1, 3 do
		self.reward_list[i] = ItemCell.New(self:FindObj("Item" .. i))
	end
	self.old_index = -1
	self:ListenEvent("GetRewardClick",BindTool.Bind(self.GetRewardClick, self))
end

function XiuLuoScoreView:__delete()
	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}
end

function XiuLuoScoreView:GetRewardClick()
	KuaFuXiuLuoTowerCtrl.Instance:SendGetScoreReward()
end

function XiuLuoScoreView:Flush()
	local score = KuaFuXiuLuoTowerData.Instance:GetScoreValue()
	self.my_score:SetValue(score)
	local reward_cfg, index = KuaFuXiuLuoTowerData.Instance:GetCanGetRewardUI()
	reward_cfg = reward_cfg or {}
	if self.old_index ~= index then
		for k,v in pairs(self.reward_list) do
			v:SetData(reward_cfg["reward_item"..k])
			v.root_node:SetActive(reward_cfg["reward_item"..k] ~= nil and reward_cfg["reward_item"..k].item_id ~= 0)
		end
	end
	if reward_cfg.score then
		self.reach_score:SetValue(reward_cfg.score)
	else
		self.reach_score:SetValue(Language.XiuLuo.HaveGotAll)
	end
	self.reward_all:SetValue(reward_cfg.score == nil)
	self.old_index = index
end

----------------------胜利面板----------------------
XiuLuoVictoryView = XiuLuoVictoryView or BaseClass(BaseRender)
function XiuLuoVictoryView:__init()

end

function XiuLuoVictoryView:__delete()

end

function XiuLuoVictoryView:Flush()

end

function XiuLuoVictoryView:SetActive(is_show)
	self.root_node:SetActive(is_show)
end