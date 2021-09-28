
ArenaView = ArenaView or BaseClass(BaseRender)

function ArenaView:__init()
	self.is_show_hook = false
	self.is_show_bubble = false

	self:ListenEvent("Refresh", BindTool.Bind(self.SendRefreshCompetitor, self))
	self:ListenEvent("open_honor_shop", BindTool.Bind(self.OpenHonorShop, self))
	self:ListenEvent("open_rank_list", BindTool.Bind(self.OpenRankListView, self))
	self:ListenEvent("mask_change", BindTool.Bind(self.CheckBoxClick, self))
	self:ListenEvent("Buff", BindTool.Bind(self.OnClickBuffBtn, self))
	self:ListenEvent("buy_times", BindTool.Bind(self.SendBuyJoinTimes, self))
	for i=1,5 do
		self:ListenEvent("click_player"..i, BindTool.Bind2(self.ToggleEvent,self,i))
	end

	--给秒杀图标添加触发事件
	for i=1,5 do
		self:ListenEvent("kill_"..i, BindTool.Bind2(self.ToggleEvent,self,i))
	end

	self.is_show = self:FindVariable("is_show_wing")
	self.is_click = self:FindVariable("is_click")

	self.click_cd = self:FindVariable("click_cd")
	self.arena_self_rank = self:FindVariable("arena_self_rank")
	self.arena_self_zhanli = self:FindVariable("arena_self_zhanli")
	self.arena_self_honor = self:FindVariable("arena_self_honor")
	self.arena_tz_num = self:FindVariable("arena_tz_num")
	self.show_bubble1 = self:FindVariable("show_bubble1")
	self.show_bubble2 = self:FindVariable("show_bubble2")
	self.show_bubble3 = self:FindVariable("show_bubble3")
	self.buff_hp = self:FindVariable("buff_hp")
	self.buff_gongji = self:FindVariable("buff_gongji")
	self.show_buff = self:FindVariable("show_buff")
	self.display1 = self:FindObj("Display1")
	self.display2 = self:FindObj("Display2")
	self.display3 = self:FindObj("Display3")
	self.display4 = self:FindObj("Display4")
	self.display5 = self:FindObj("Display5")
	self.show_mask = self:FindObj("show_mask")
	self.jie_suan_time = self:FindVariable("JiesuanTime")

	for i=1,5 do
		self["model" .. i] = RoleModel.New("arena_panel_"..i)
		self["model" .. i]:SetDisplay(self["display" .. i].ui3d_display)
		self["player_rank_" .. i] = self:FindVariable("rank_" .. i)
		self["player_zhanli_" .. i] = self:FindVariable("zhanli_" .. i)
		self["player_name_" .. i] = self:FindVariable("name_" .. i)
		self["show_kill" .. i] = self:FindVariable("show_kill" .. i)
		self["is_mine_" .. i] = self:FindVariable("is_mine_" .. i)
	end

	self.time_value = 9
	self.bubble_time = 10
	self.kill_list = {}
	self.click_cd:SetValue(Language.Common.RefreshQuery)
	self.remind_rank_reward = self:FindVariable("remind_rank_reward")

	--引导用按钮
	self.first_role_stand = self:FindObj("FirstRoleStand")
	self.jiesuan_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
	self:FlushNextTime()
end

function ArenaView:__delete()
	self.arena_self_rank = nil
	self.arena_self_zhanli = nil
	self.arena_self_honor = nil
	self.arena_tz_num = nil
	self.show_mask = nil
	self.click_cd = nil
	self.remind_rank_reward = nil
	self.show_bubble1 = nil
	self.show_bubble2 = nil
	self.show_bubble3 = nil
	self.buff_hp = nil
	self.buff_gongji = nil
	self.show_buff = nil

	self.is_click = true
	self.is_show_hook = false
	self.is_show = false
	self.kill_list = {}

	for i=1,5 do
		self["model" .. i]:DeleteMe()
		self["model" .. i] = nil

		self["display" .. i] = nil
		self["player_zhanli_" .. i] = nil
		self["player_rank_" .. i] = nil
		self["player_name_" .. i] = nil
		self["show_kill" .. i] = nil
		self["is_mine_" .. i] = nil
		self.uid_list = nil
	end

	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.count_down2 ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down2)
		self.count_down2 = nil
	end
	if self.jiesuan_timer then
		GlobalTimerQuest:CancelQuest(self.jiesuan_timer)
		self.jiesuan_timer = nil
	end
end

function ArenaView:FlushNextTime()
	local cur_time = TimeCtrl.Instance:GetServerTime()
	local over_time = TimeUtil.NowDayTimeStart(cur_time) + 3600 * 20
	local time = over_time - cur_time
	if time < 0 then
		time = time + 3600 * 24
	end
	if time > 3600 then
		self.jie_suan_time:SetValue(TimeUtil.FormatSecond(time, 1))
	else
		self.jie_suan_time:SetValue(TimeUtil.FormatSecond(time, 2))
	end
end

function ArenaView:GetFirstRoleStand()
	return self.first_role_stand
end

function ArenaView:CheckBoxClick()
	self.is_show_hook = not self.is_show_hook
	self.is_show:SetValue(self.is_show_hook)
	self:FlushArenaView()
end

function ArenaView:StartBubbleCountDown()
	if not self.is_show_bubble then
		if self.count_down2 ~= nil then
			CountDown.Instance:RemoveCountDown(self.count_down2)
			self.count_down2 = nil
		end
		self.count_down2 = CountDown.Instance:AddCountDown(11, 1, BindTool.Bind(self.ChangeBubbleTime, self))
		self.is_show_bubble = true
	end
end

function ArenaView:CalToShowAnim()
	self.timer = FIX_SHOW_TIME
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		self.timer = self.timer - UnityEngine.Time.deltaTime
		if self.timer <= 0 then
			local random_index = math.random(1,5)
			self["model" .. random_index]:SetTrigger("combo1_1")
			self["model" .. random_index]:SetTrigger("combo1_2")
			self["model" .. random_index]:SetTrigger("combo1_3")
			self.timer = FIX_SHOW_TIME
		end
	end, 0)
end

function ArenaView:ToggleEvent(index)
	local role_info = ArenaData.Instance:GetRoleInfoByUid(self.uid_list[index])
	if not role_info then return end
	local tz_info = ArenaData.Instance:GetRoleTiaoZhanInfoByUid(role_info.role_id)
	local tz_num = ArenaData.Instance:GetResidueTiaoZhanNum()
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if self.uid_list[index] == main_role_id then
		return
	end
	if tz_info then
		local data = {}
		data.opponent_index = tz_info.index
		data.rank_pos = tz_info.rank_pos
		data.is_auto_buy = 0
		ArenaCtrl.Instance:ResetFieldFightReq(data)
			------

		if not self.kill_list[index] then
			ViewManager.Instance:Close(ViewName.Activity, TabIndex.arena_view)
		elseif tz_num > 0 and Scene.Instance:GetSceneId() == SceneType.Common then
			ArenaCtrl.Instance:ReqFieldGetUserInfo()
			ArenaCtrl.Instance:ResetOpponentList()
			ArenaCtrl.Instance:ReqOtherRoleInfo(0)
		end
	end
end


function ArenaView:SetModel()--设置模型的
	for i=1,5 do
		local role_info = ArenaData.Instance:GetRoleInfoByUid(self.uid_list[i])
		self["model" .. i]:SetModelResInfo(role_info, nil,not self.is_show_hook, true)--第三个参数，表示是否显示翅膀
		self["model" .. i]:SetPanelName("arena_panel_".. i)
	end
	-- self:CalToShowAnim()
end

function ArenaView:OpenCallBack()
	ArenaCtrl.Instance:ReqFieldGetUserInfo()
	--ArenaCtrl.Instance:ResetOpponentList()
	ArenaCtrl.Instance:ReqOtherRoleInfo(0)
end

function ArenaView:SendRefreshCompetitor()
	ArenaCtrl.Instance:ResetOpponentList()
	local cfg =ConfigManager.Instance:GetAutoConfig("challengefield_auto").other[1]
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.count_down2 ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down2)
		self.count_down2 = nil
	end
	self.time_value = cfg.refresh_cooldown
	self.count_down = CountDown.Instance:AddCountDown(99999, 1, BindTool.Bind(self.ChangeTime, self))
	self:ChangeTime()
end

function ArenaView:OpenHonorShop()
	ViewManager.Instance:Close(ViewName.ArenaActivityView)
	ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_guanghui)
end

function ArenaView:OnClickBuffBtn()
	ArenaCtrl.Instance:OpenArenaBuffView()
end

function ArenaView:OpenRankListView()
	ArenaCtrl.Instance:OpenHistoryRewardPreview()
end

function ArenaView:SendBuyJoinTimes()
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	local max_goumai = VipData.Instance:GetVipPowerList(vip_level)[VIPPOWER.BUY_ARENA_CHALLENGE_COUNT]
	local max_count = VipData.Instance:GetVipPowerList(15)[VIPPOWER.BUY_ARENA_CHALLENGE_COUNT]
	local describe = ""
	local yes_func = nil
	local goumaicishu = ArenaData.Instance:GetBuyJoinTimesTimes()
	if max_goumai - goumaicishu > 0 then
		local gold_cost = ConfigManager.Instance:GetAutoConfig("challengefield_auto").other[1].buy_join_times_cost
		describe = string.format(Language.Field1v1.AddNumTip, ToColorStr(gold_cost, TEXT_COLOR.BLUE1), ToColorStr(goumaicishu + 1, TEXT_COLOR.BLUE1))
		yes_func = function() ArenaCtrl.Instance:FieldBuyJoinTimes() end
	elseif goumaicishu < max_count then
		TipsCtrl.Instance:ShowLockVipView(VIPPOWER.BUY_ARENA_CHALLENGE_COUNT)
		return
	else
		describe = Language.Field1v1.AddNumTip2
		SysMsgCtrl.Instance:ErrorRemind(describe)
		return
	end

	TipsCtrl.Instance:ShowCommonAutoView("arena_view", describe, yes_func)
end

function ArenaView:ChangeTime()
	if self.time_value <= 0 then
		self.click_cd:SetValue(Language.Common.RefreshQuery)
		self.is_click:SetValue(false)
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	else
		local time = TimeUtil.FormatSecond(self.time_value, 2)
		self.click_cd:SetValue(time)
		self.is_click:SetValue(true)
	end
	self.time_value = self.time_value - 1
end

function ArenaView:ChangeBubbleTime()
	if self.bubble_time == 10 then
		self.show_bubble2:SetValue(true)
	elseif self.bubble_time == 8 then
		self.show_bubble2:SetValue(false)
	elseif self.bubble_time == 6 then
		self.show_bubble3:SetValue(true)
	elseif self.bubble_time == 4 then
		self.show_bubble3:SetValue(false)
	elseif self.bubble_time == 2 then
		self.show_bubble1:SetValue(true)
	elseif self.bubble_time == 0 then
		self.show_bubble1:SetValue(false)
	end
	self.bubble_time = self.bubble_time - 1
end

function ArenaView:FlushArenaView()
    local fetch_rank_reward = ArenaData.Instance:GetIsCanFetchRankReward()
	local cfg = ConfigManager.Instance:GetAutoConfig("challengefield_auto").other[1]
	self.remind_rank_reward:SetValue(fetch_rank_reward)
	local info = ArenaData.Instance:GetUserInfo()
	if nil == info then
		return
	end
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	self.uid_list = {}
	local sorted_list = info.rank_list
	table.sort(sorted_list, SortTools.KeyUpperSorter("rank"))
	local have_mine = false
	for k,v in pairs(sorted_list) do
		if v.user_id == main_role_vo.role_id then
			have_mine = true
			break
		end
	end
	if info.rank <= 5 and have_mine == false then
		local data = {}
		data.user_id = main_role_vo.role_id
		data.rank = info.rank
		sorted_list[2] = data
		table.sort(sorted_list, SortTools.KeyUpperSorter("rank"))
	end
	local tz_num = ArenaData.Instance:GetResidueTiaoZhanNum()
	for k,v in pairs(sorted_list) do
		table.insert(self.uid_list, v.user_id)
	end

	if info.rank > 5 and have_mine == false then
		self.uid_list[2] = main_role_vo.role_id
	end
	local my_capability = main_role_vo.capability


	for i=1,#self.uid_list do
		local rank = ArenaData.Instance:GetRankByUid(self.uid_list[i])
		local role_info = ArenaData.Instance:GetRoleInfoByUid(self.uid_list[i])
		if role_info then
			local capability_color = TEXT_COLOR.GREEN
			if my_capability < role_info.capability then
				capability_color = TEXT_COLOR.RED
			end
			local zhanli_str = string.format(role_info.capability)

			ArenaData.Instance:SetCapabilityList(role_info.role_id,zhanli_str)		--初始戰力表

			self["player_rank_" .. i]:SetValue(rank)
			self["player_zhanli_" .. i]:SetValue(zhanli_str)
			self["player_name_" .. i]:SetValue(role_info.name)
			self.kill_list[i] = (role_info.capability < my_capability and rank > info.rank) and true or false
			self["show_kill" .. i]:SetValue(self.kill_list[i])
			self["is_mine_" .. i]:SetValue(self.uid_list[i] == main_role_vo.role_id)
		end
	end

	self.arena_self_rank:SetValue(info.rank)
	self.arena_self_zhanli:SetValue(my_capability)
	self.arena_self_honor:SetValue(main_role_vo.guanghui)
	self.arena_tz_num:SetValue(tz_num)

	local buy_buff_num = ArenaData.Instance:GetBuffBuyTimes()
	if 0 == buy_buff_num then
		self.show_buff:SetValue(false)
	else
		self.show_buff:SetValue(true)
	end

	local buff_gongji = string.format(Language.Field1v1.AddGongji, cfg.buff_add_gongji_per / 100 * buy_buff_num)
	local buff_hp = string.format(Language.Field1v1.AddHp, cfg.buff_add_maxhp_per / 100 * buy_buff_num)
	self.buff_hp:SetValue(buff_hp)
	self.buff_gongji:SetValue(buff_gongji)
	self:SetModel()
end

