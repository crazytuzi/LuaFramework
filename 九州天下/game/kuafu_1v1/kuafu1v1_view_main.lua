KuaFu1v1ViewMain = KuaFu1v1ViewMain or BaseClass(BaseRender)

function KuaFu1v1ViewMain:__init(instance)
	if instance == nil then
		return
	end

	self.rank = self:FindVariable("Rank")
	self.next_rank = self:FindVariable("NextRank")
	self.exp = self:FindVariable("Exp")
	self.value = self:FindVariable("Value")
	self.level = self:FindVariable("Level")
	self.time = self:FindVariable("Time")
	self.join_count = self:FindVariable("JoinCount")
	self.reward_count = self:FindVariable("RewardCount")
	self.wei_wang = self:FindVariable("WeiWang")
	self.button_name = self:FindVariable("ButtonName")
	self.is_can_click = self:FindVariable("IsCanClick")
	self.gray = self:FindVariable("Gray")
	self.lian_sheng_count = self:FindVariable("LianShengCount")
	self.explain = self:FindVariable("ExPlain")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.my_score = self:FindVariable("MyScore")
	self.my_rank_name = self:FindVariable("MyRankName")
	self.cur_rank = self:FindVariable("CurRank")
	self.max_rank = self:FindVariable("MaxRank")
	self.my_rank_num = self:FindVariable("MyRankNum")
	self.has_rank_type = self:FindVariable("HasRankType")
	self.max_rank:SetValue(true)

	self:ListenEvent("OnClickEnter",
		BindTool.Bind(self.OnClickEnter, self))
	self:ListenEvent("OnClickRankReward",
		BindTool.Bind(self.OnClickRankReward, self))
	self:ListenEvent("OnClickHelp",
		BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickExchange",
		BindTool.Bind(self.OnClickExchange, self))
	self:ListenEvent("OnClickHead",
		BindTool.Bind(self.OnClickHead, self))
	self:ListenEvent("OnClickRank",
		BindTool.Bind(self.OnClickRank, self))

	self.open_day_list = {}
	self:InitInfo()
end

function KuaFu1v1ViewMain:__delete()
	if self.preview_next_cell then
		for k,v in pairs(self.preview_next_cell) do
			v:DeleteMe()
		end
	end
	self.preview_next_cell = {}

	if self.preview_final_cell then
		for k,v in pairs(self.preview_final_cell) do
			v:DeleteMe()
		end
	end
	self.preview_final_cell = {}

	self.my_score = nil
	self.my_rank_name = nil
	self.my_rank_num = nil
	self.has_rank_type = nil
end

function KuaFu1v1ViewMain:InitInfo()
	local act_info = ActivityData.Instance:GetActivityInfoById(ACTIVITY_TYPE.KF_ONEVONE)
	if act_info then
		if not next(act_info) then return end
		local min_level = tonumber(act_info.min_level)
		local level = PlayerData.GetLevelString(min_level)
		self.open_day_list = Split(act_info.open_day, ":")
		self.level:SetValue(level)
		self:SetTitleTime(act_info)
		self:SetExplain(act_info)
	end
end

function KuaFu1v1ViewMain:OnClickEnter()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.KF_ONEVONE) then
		SysMsgCtrl.Instance:ErrorRemind(Language.CompetitionActivity.HasNotOpen)
		return
	end
	local scene_type = Scene.Instance:GetSceneType()
	local main_role = Scene.Instance:GetMainRole()

	if scene_type ~= SceneType.Common or GuajiCtrl.Instance:IsSpecialCommonScene() or main_role:IsAtk() or main_role.vo.husong_taskid > 0 or
		main_role.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Kuafu1V1.CantPiPei)
		return
	end
	KuaFu1v1Ctrl.Instance.view:SendPiPen()
	KuaFu1v1Ctrl.Instance:SendCrossMatch1V1Req()
end

function KuaFu1v1ViewMain:OnClickRankReward()
	KuaFu1v1Ctrl.Instance.view:OpenRankView()
end

function KuaFu1v1ViewMain:OnFlush()
	local info = KuaFu1v1Data.Instance:GetRoleData()
	if info then
		local index = KuaFu1v1Data.Instance:GetIndexByScore(info.cross_score_1v1)
		if KuaFu1v1Data.Instance:GetReminder() > 0 then
			self.show_red_point:SetValue(true)
		else
			self.show_red_point:SetValue(false)
		end

		local total_count = info.cross_day_win_1v1_count or 0
		self.join_count:SetValue(total_count)
		local lian_sheng_count = info.cross_dur_win_1v1_count or 0
		self.lian_sheng_count:SetValue(lian_sheng_count)
		local cross_honor = info.cross_honor or 0
		self.wei_wang:SetValue(cross_honor)
		local cur_honor = info.cross_1v1_curr_activity_add_honor or 0
		self.reward_count:SetValue(cur_honor)
		self.button_name:SetValue(Language.Common.PiPei)
		self.my_score:SetValue(info.cross_score_1v1)

		local current_config, next_config = KuaFu1v1Data.Instance:GetRankByScore(info.cross_score_1v1)
		if current_config then
			self.cur_rank:SetValue(current_config.rank_type)
			self.gray:SetValue(false)
			self.rank:SetValue(current_config.rank_name)
			self.has_rank_type:SetValue(true)
			local bundle, asset = ResPath.GetKuaFu1v1Image("rank_type_" .. current_config.rank_str_res)
			self.my_rank_name:SetAsset(bundle, asset)
			bundle, asset = ResPath.GetKuaFu1v1Image("rank_index_" .. current_config.rank_index)
			self.my_rank_num:SetAsset(bundle, asset)
			if next_config then
				self.exp:SetValue(info.cross_score_1v1 .. "/".. next_config.rank_score)
				local temp = next_config.rank_score - current_config.rank_score
				self.value:SetValue((info.cross_score_1v1 - current_config.rank_score) / temp)
				self.next_rank:SetValue(next_config.rank_name)
				self.max_rank:SetValue(true)
			else
				self.exp:SetValue(info.cross_score_1v1)
				self.value:SetValue(1)
				self.next_rank:SetValue("")
				self.max_rank:SetValue(false)
			end
		elseif next_config then
			self.exp:SetValue(info.cross_score_1v1 .. "/".. next_config.rank_score)
			self.gray:SetValue(true)
			self.rank:SetValue(Language.Common.WuDuanWei)
			self.next_rank:SetValue(next_config.rank_name)
			self.has_rank_type:SetValue(false)
			self.cur_rank:SetValue(0)
			self.value:SetValue(info.cross_score_1v1 / next_config.rank_score)
		end
	end

	local flag = KuaFu1v1Data.Instance:GetIsOutFrom1v1Scene()
	if flag then
		self:OnClickEnter()
	end
	KuaFu1v1Data.Instance:SetIsOutFrom1v1Scene(false)
end

function KuaFu1v1ViewMain:SetTitleTime(act_info)
	local server_time = TimeCtrl.Instance:GetServerTime()
	local now_weekday = tonumber(os.date("%w", server_time))
	if now_weekday == 0 then now_weekday = 7 end
	local time_str = Language.Activity.YiJieShu

	if act_info.is_allday == 1 or ActivityData.Instance:GetActivityIsOpen(act_info.act_id) then
		time_str = Language.Activity.KaiQiZhong
	else
		local open_day_list = Split(act_info.open_day, ":")
		for _, v in ipairs(open_day_list) do
			if tonumber(v) == now_weekday then
				local open_time_tbl = Split(act_info.open_time, "|")
				local open_time_str = open_time_tbl[1]
				local end_time_tbl = Split(act_info.end_time, "|")

				if #end_time_tbl > 1 then
					local server_time_str = os.date("%H:%M", server_time)
					for k2, v2 in ipairs(end_time_tbl) do
						open_time_str = open_time_tbl[k2]
						if v2 > server_time_str then
							break
						end
					end
				end
				time_str = string.format("%s  %s", open_time_str, Language.Common.Open)
				break
			end
		end
	end
	self.time:SetValue(time_str)
end

function KuaFu1v1ViewMain:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(93)
end

function KuaFu1v1ViewMain:OnClickExchange()
	ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_rongyao)
	--ExchangeData.Instance:SetCurIndex(8)
end

function KuaFu1v1ViewMain:OnClickHead()

end


function KuaFu1v1ViewMain:OnClickRank()
	ViewManager.Instance:FlushView(ViewName.KuaFu1v1, "rank")
end

function KuaFu1v1ViewMain:SetExplain(act_info)
	local min_level = tonumber(act_info.min_level)
	local level_str = PlayerData.GetLevelString(min_level)
	local time_des = ""

	if act_info.is_allday == 1 then
		time_des = Language.Activity.AllDay
	else
		time_des = self:GetChineseWeek(act_info)
	end

	local detailexplain = string.format(Language.Activity.DetailExplain, level_str, time_des, act_info.dec)
	if self.act_id == ACTIVITY_TYPE.CLASH_TERRITORY then
		local guild_id = PlayerData.Instance.role_vo.guild_id or 0
		local match_name = ClashTerritoryData.Instance:GetTerritoryWarMatch(guild_id)
		detailexplain = string.format(Language.Activity.TerritoryWarExplain, level_str, time_des, match_name)
	end
	self.explain:SetValue(detailexplain)
end

function KuaFu1v1ViewMain:GetChineseWeek(act_info)
	local open_time_tbl = Split(act_info.open_time, "|")
	local end_time_tbl = Split(act_info.end_time, "|")

	local time_des = ""

	if #self.open_day_list >= 7 then
		if #open_time_tbl > 1 then
			local time_str = ""
			for i = 1, #open_time_tbl do
				if i == 1 then
					time_str = string.format("%s-%s", open_time_tbl[1], end_time_tbl[1])
				else
					time_str = string.format("%s,%s-%s", time_str, open_time_tbl[i], end_time_tbl[i])
				end
			end
			time_des = string.format("%s %s", Language.Activity.EveryDay, time_str)
		else
			time_des = string.format("%s %s-%s", Language.Activity.EveryDay, act_info.open_time, act_info.end_time)
		end
	else
		local week_str = ""
		for k, v in ipairs(self.open_day_list) do
			local day = tonumber(v)
			if k == 1 then
				week_str = string.format("%s%s", Language.Activity.WeekDay, Language.Common.DayToChs[day])
			else
				week_str = string.format("%s、%s", week_str, Language.Common.DayToChs[day])
			end
		end
		if #open_time_tbl > 1 then
			local time_str = ""
			for i = 1, #open_time_tbl do
				if i == 1 then
					time_str = string.format("%s-%s", open_time_tbl[1], end_time_tbl[1])
				else
					time_str = string.format("%s,%s-%s", time_str, open_time_tbl[i], end_time_tbl[i])
				end
			end
			time_des = string.format("%s %s", week_str, time_str)
		else
			time_des = string.format("%s %s-%s", week_str, act_info.open_time, act_info.end_time)
		end
	end
	return time_des
end