GuildWarView = GuildWarView or BaseClass(BaseRender)

local CityNum = 5

function GuildWarView:__init(instance)
	if instance == nil then
		return
	end

	self.city_name_list = {}
	self.is_capture_list = {}
	self.leader_name_list = {}
	self.guild_name_list = {}
	self.city_Anim_list = {}
	self.box_anim_list = {}
	for i = 1, CityNum do
		self.city_name_list[i] = self:FindVariable("GuildName_" .. i)
		self.is_capture_list[i] = self:FindVariable("Iscapture_" .. i)
		self.leader_name_list[i] = self:FindVariable("Leader_Name_" .. i)
		self.guild_name_list[i] = self:FindVariable("Guild_Name_" .. i)
		self.city_Anim_list[i] = self:FindObj("CityIcon_" .. i).animator
		self.box_anim_list[i] = self:FindObj("Box_" .. i).animator
		-- self.city_Anim_list[i]:SetBool("Shake", false)
		-- self.box_anim_list[i]:SetBool("Shake", true)

		self:ListenEvent("OnClickBox" .. i, function() self:OnClickBox(i) end)
	end

	--获取组件
	self.item_list = {}
	for i = 1, 3 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("Item_" .. i))
		table.insert(self.item_list, item)
	end

	self.explain = self:FindVariable("Explain")
	self.explain_2 = self:FindVariable("Explain_2")

	self.show_item_list = self:FindVariable("ShowItemList")

	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickEnter", BindTool.Bind(self.OnClickEnter, self))

	self:SetAnimTime()
end

function GuildWarView:__delete()
	self.explain = nil
	self.explain_2 = nil
	self.city_icon_list = nil
	self.show_item_list = nil
	self.city_name_list = nil
	self.is_capture_list = nil
	self.leader_name_list = nil
	self.guild_name_list = nil

	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	if self.statr_time_timer then
		CountDown.Instance:RemoveCountDown(self.statr_time_timer)
        self.statr_time_timer = nil
	end
end

function GuildWarView:GetSkillIcon(skill_id)
	return ResPath.GetGuildSkillIcon(skill_id)
end

-- 刷新页面
function GuildWarView:OnFlush()
	self.act_info = ActivityData.Instance:GetActivityInfoById(ACTIVITY_TYPE.GUILDBATTLE)
	if not next(self.act_info) then
		return
	end

	self.open_day_list = Split(self.act_info.open_day, ":")
	self:SetExplain(self.act_info)
	self:SetRewardState(self.act_info)
	self:SetCityPro()
	self:FlushBoxRemind()
end

-- 设置城池信息
function GuildWarView:SetCityPro()
	local rank_list = RankData.Instance:GetGetGuildWarRankListAck()
	local reward_cfg = GuildFightData.Instance:GetConfig().daily_reward
	if not reward_cfg then
		return
	end

	local global_info = GuildFightData.Instance:GetGlobalInfo()
	for i = 1, CityNum do
		if reward_cfg[i] then
			self.city_name_list[i]:SetValue(reward_cfg[i].occupy_name)
		end

		if rank_list and rank_list[i] then
	        self.leader_name_list[i]:SetValue(rank_list[i].tuan_zhang_name)
	        self.guild_name_list[i]:SetValue(rank_list[i].guild_name)
	    else
	    	self.leader_name_list[i]:SetValue(Language.Competition.NoRank)
	        self.guild_name_list[i]:SetValue(Language.Competition.NoRank)
	    end
	end
end

-- 点击城池
function GuildWarView:OnClickBox(index)
	if nil == index then
		return
	end

	local guild_war_cfg = GuildFightData.Instance:GetConfig()
	if not guild_war_cfg then
		return
	end

	local other_cfg = guild_war_cfg.other[1]
	local reward_cfg = guild_war_cfg.daily_reward
	local guild_war_info = GuildFightData.Instance:GetGuildBattleDailyRewardFlag()
	local show_gray = nil
	local show_button = nil

	local reward_list = reward_cfg[index].reward_item
	local title_id = other_cfg.title_id
	local top_title_id = reward_cfg[index].occupy_name
	local act_type = ACTIVITY_TYPE.GUILDBATTLE

	local function ok_callback()
		GuildFightCtrl.Instance:SendGuildWarOperate(GUILD_WAR_TYPE.TYPE_FETCH_REQ)
	end

	if guild_war_info then
		show_button = guild_war_info.my_guild_rank == index
		show_gray = show_button and (guild_war_info.had_fetch == 1)
	end

	if index == 1 then
		KuafuGuildBattleCtrl.Instance:OpenRewardTip(reward_list, show_gray, ok_callback, show_button, title_id, top_title_id, act_type)
	else
		TipsCtrl.Instance:TipsGuildWarRewardShow(reward_list, show_gray, ok_callback, show_button, top_title_id)
	end
end

--描述
function GuildWarView:SetExplain(act_info)
	local min_level = tonumber(act_info.min_level)
	local level_str = PlayerData.GetLevelString(min_level)
	local time_des = ""

	time_des = self:GetChineseWeek(act_info)

	local detailexplain = string.format(Language.Activity.DetailExplain_2, level_str)
	local detailexplain_2 = string.format(Language.Activity.DetailExplain_3, time_des)

	local svr_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if svr_day <= 2 then
		detailexplain_2 = string.format(Language.Activity.DetailExplain_3, "20：00-20:30")
	end

	self.explain:SetValue(detailexplain)
	self.explain_2:SetValue(detailexplain_2)
end

function GuildWarView:GetChineseWeek(act_info)
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

--设置是否显示奖励
function GuildWarView:SetRewardState(act_info)
	if next(act_info.reward_item1) then
		self.show_item_list:SetValue(true)
		for k, v in ipairs(self.item_list) do
			if act_info["reward_item" .. k] and next(act_info["reward_item" .. k]) and act_info["reward_item" .. k].item_id ~= 0 then
				self.item_list[k].root_node:SetActive(true)
				act_info["reward_item" .. k].is_bind = 0
				self.item_list[k]:SetData(act_info["reward_item" .. k])
			else
				self.item_list[k]:SetInteractable(false)
				self.item_list[k].root_node:SetActive(false)
			end
		end
	else
		self.show_item_list:SetValue(false)
	end
end

function GuildWarView:OnClickHelp()
	local act_info = ActivityData.Instance:GetClockActivityByID(ACTIVITY_TYPE.GUILDBATTLE)
	if not next(act_info) then return end
	TipsCtrl.Instance:ShowHelpTipView(act_info.play_introduction)
end

function GuildWarView:OnClickEnter()
	local act_info = ActivityData.Instance:GetClockActivityByID(ACTIVITY_TYPE.GUILDBATTLE)
	if not next(act_info) then return end

	if GameVoManager.Instance:GetMainRoleVo().level < act_info.min_level then
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Common.JoinEventActLevelLimit, act_info.min_level))
		return
	end

	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILDBATTLE) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
		return
	end

	ActivityCtrl.Instance:SendActivityEnterReq(ACTIVITY_TYPE.GUILDBATTLE, index)
	ViewManager.Instance:CloseAll()
end

function GuildWarView:SetAnimTime()
	if self.statr_time_timer then
		CountDown.Instance:RemoveCountDown(self.statr_time_timer)
        self.statr_time_timer = nil
	end

	local one_time = math.random(0.1)
	local one_time_num = 1
	self.statr_time_timer = CountDown.Instance:AddCountDown(5, 0.1, function (elapse_time, total_time)
			if one_time_num <= CityNum then
				self.city_Anim_list[one_time_num]:SetBool("Shake", true)
			end
			one_time_num = one_time_num + 1

			if elapse_time >= total_time then
				for k,v in pairs(self.city_Anim_list) do
					v:SetBool("Shake", true)
				end
			end
        end)
end

function GuildWarView:FlushBoxRemind()
	local guild_war_info = GuildFightData.Instance:GetGuildBattleDailyRewardFlag()
	if nil == guild_war_info then
		return
	end

	local show_button = nil
	local shake_button = nil
	for k,v in pairs(self.box_anim_list) do
		show_button = guild_war_info.my_guild_rank == k
		shake_button = show_button and (guild_war_info.had_fetch == 0)
		self.box_anim_list[k]:SetBool("Shake", shake_button)
	end
end