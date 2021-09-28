CityCombatFBView = CityCombatFBView or BaseClass(BaseView)

function CityCombatFBView:__init()
	self.ui_config = {"uis/views/citycombatview_prefab","CityCombatFBView"}
	self.view_layer = UiLayer.MainUI
	self.active_close = false
	self.fight_info_view = true
	self.auto_guaji = false
end

function CityCombatFBView:ReleaseCallBack()
	GlobalTimerQuest:CancelQuest(self.time_quest)

	GlobalEventSystem:UnBind(self.enter_fight)
	GlobalEventSystem:UnBind(self.exit_fight)
	if self.buttons then
		self.buttons:ListenEvent("ResZoneClick", nil)
		self.buttons:ListenEvent("FlagClick", nil)
		self.buttons:DeleteMe()
		self.buttons = nil
	end

	if self.show_mode_list_event ~= nil then
		GlobalEventSystem:UnBind(self.show_mode_list_event)
		self.show_mode_list_event = nil
	end
	if self.main_role_revive then
		GlobalEventSystem:UnBind(self.main_role_revive)
		self.main_role_revive = nil
	end
	if self.move_by_click then
		GlobalEventSystem:UnBind(self.move_by_click)
		self.move_by_click = nil
	end
	if self.guaji_change then
		GlobalEventSystem:UnBind(self.guaji_change)
		self.guaji_change = nil
	end
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	for k,v in pairs(self.rank_list) do
		v:DeleteMe()
	end
	self.rank_list = {}

	self.reward_count = nil
	self.reward = nil
	self.def_guild_name = nil
	self.def_guild_time = nil
	self.show_count_down = nil
	self.count_down_num = nil
	self.show_panel = nil
	self.is_atk_side = nil
	self.is_fight_state = nil
	self.door_is_destroy = nil
	self.show_skill_image = nil
	self.show_time = nil

	self:RemoveCountDown()
	self:RemoveDelayTime()
end

function CityCombatFBView:ItemManager(list, group_name, item_name, func)
	local obj_group = self:FindObj(group_name)
	local child_number = obj_group.transform.childCount
	local count = 1
	for i = 0, child_number - 1 do
		local obj = obj_group.transform:GetChild(i).gameObject
		if string.find(obj.name, item_name) ~= nil then
			list[count] = func(obj, count, self)
			count = count + 1
		end
	end
end

function CityCombatFBView:PoChengReset()
	if not self:IsLoaded() then
		return
	end
	self.show_count_down:SetValue(true)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	function diff_time_func(elapse_time, total_time)
		local left_time = math.ceil(total_time - elapse_time)
		if elapse_time >= total_time then
			-- GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
			self.show_count_down:SetValue(false)
			self:RemoveCountDown()
		end
		self.count_down_num:SetValue(left_time)
	end
	diff_time_func(0, 3)
	self:RemoveCountDown()
	self.count_down = CountDown.Instance:AddCountDown(
		3, 1, diff_time_func)
end

function CityCombatFBView:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function CityCombatFBView:LoadCallBack()
	local obj = MainUICtrl.Instance:GetCityCombatButtons()
	obj:SetActive(true)
	self.buttons = BaseRender.New(obj)

	self:ListenEvent("ExitClick", BindTool.Bind(self.ExitClick, self))
	self:ListenEvent("TimeClick", BindTool.Bind(self.ToggleChange, self))

	self.buttons:ListenEvent("ResZoneClick", BindTool.Bind(self.ToResourceZone, self))
	self.buttons:ListenEvent("FlagClick", BindTool.Bind(self.CutFlag, self))

	self.rank_list = {}
	self:ItemManager(self.rank_list, "ObjGroup", "ListItem", CityCombatRankCell.New)

	self.reward_count = self:FindVariable("ZhanGongRewardCount")
	self.reward = self:FindVariable("ZhanGongReward")
	self.def_guild_name = self:FindVariable("CuDefGulidName")
	self.def_guild_time = self:FindVariable("CuDefGulidTime")
	self.show_time = self:FindVariable("ShowTime")

	self.is_atk_side = self.buttons:FindVariable("IsAtkSide")			--是否攻方
	self.is_fight_state = self.buttons:FindVariable("IsFightState")
	self.door_is_destroy = self.buttons:FindVariable("DoorIsDestroy")	--城门是否已被摧毁
	self.show_skill_image = self.buttons:FindVariable("ShowSkillImage")

	self.show_count_down = self:FindVariable("ShowCountDown")
	self.count_down_num = self:FindVariable("CountDownNumber")

	self.show_panel = self:FindVariable("ShowPanel")

	self.item_list = {}
	for i = 1, 3 do
		local item_cell = ItemCell.New(self:FindObj("Item" .. i))
		item_cell:SetData(nil)
		table.insert(self.item_list, item_cell)
	end

	self.is_fight_state:SetValue(Scene.Instance:GetMainRole():IsFightState())

	self.def_guild_name:SetValue("")
	self.def_guild_time:SetValue("")
	self.show_count_down:SetValue(false)
	self.select_rank = 1
	self.have_def_guild = false
	self:Flush()
	self:FlushDefGuildTime()

	self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.Timer, self), 1)
	self.enter_fight = GlobalEventSystem:Bind(ObjectEventType.ENTER_FIGHT, BindTool.Bind(self.FightStateChange, self, true))
	self.exit_fight = GlobalEventSystem:Bind(ObjectEventType.EXIT_FIGHT, BindTool.Bind(self.FightStateChange, self, false))
	self.show_mode_list_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON, BindTool.Bind(self.OnMainUIModeListChange, self))
	self.main_role_revive = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_REALIVE, BindTool.Bind(self.MainRoleRevive, self))
	self.move_by_click = GlobalEventSystem:Bind(OtherEventType.MOVE_BY_CLICK, BindTool.Bind(self.OnMoveByClick, self))
	self.guaji_change = GlobalEventSystem:Bind(OtherEventType.GUAJI_TYPE_CHANGE, BindTool.Bind(self.OnGuajiTypeChange, self))

	self.auto_guaji = GuajiCache.guaji_type == GuajiType.Auto
end

function CityCombatFBView:FightStateChange(is_fight)
	self.is_fight_state:SetValue(is_fight)
end

function CityCombatFBView:FlushDefGuildTime()
	if not self:IsLoaded() then
		return
	end
	local def_guild_data = CityCombatData.Instance:GetGlobalInfo()
	if def_guild_data == nil or def_guild_data.shou_guild_name == nil or def_guild_data.shou_guild_name == "" then
		self.def_guild_name:SetValue(Language.Common.No)
		self.def_guild_time:SetValue("")
		self.have_def_guild = false
		return
	end
	self.def_guild_name:SetValue(def_guild_data.shou_guild_name)
	self.time_count = def_guild_data.cu_def_guild_time
	self.have_def_guild = true
end

function CityCombatFBView:Timer()
	if self.have_def_guild then
		self.time_count = self.time_count + 1
		local time_count = TimeUtil.FormatSecond(self.time_count, 2)
		self.def_guild_time:SetValue(string.format(Language.CityCombat.DefenseTime, ToColorStr(time_count, TEXT_COLOR.ACTIVITY_GREEN)))
		CityCombatData.Instance:ReSetRank(self.time_count)
	end
	self:FlushRank()
end

function CityCombatFBView:NumberForShort(num)
	local text = ""
	if num < 10000 then
		text = num
	else
		text = math.floor(num / 10000)..Language.Common.Wan
	end
	return text
end

function CityCombatFBView:FlushItemList()
	local next_zhangong_reward = CityCombatData.Instance:GetNextZhanGongReward()
	--奖励
	for k, v in ipairs(self.item_list) do
		local index = k - 1
		local reward_list = next_zhangong_reward["reward_item"] or {}
		local reward = reward_list[index]
		if reward then
			v:SetActive(true)
			v:SetData(reward)
		else
			if next_zhangong_reward.sheng_wang and next_zhangong_reward.sheng_wang > 0 then
				v:SetActive(true)
				local data = {}
				data.item_id = ResPath.CurrencyToIconId["honor"]
				data.num = next_zhangong_reward.sheng_wang
				v:SetData(data)
			else
				v:SetActive(false)
			end
		end
	end
end

function CityCombatFBView:OnFlush()
	--战功
	local self_info = CityCombatData.Instance:GetSelfInfo()
	local next_zhangong_reward = CityCombatData.Instance:GetNextZhanGongReward()
	local text = ""
	local self_zhangong_text = self:NumberForShort(self_info.zhangong)
	local next_reward_text = next_zhangong_reward.zhangong

	if self.now_max_zhangong ~= next_reward_text then
		self.now_max_zhangong = next_reward_text
		self:FlushItemList()
	end

	if self_info.zhangong > next_zhangong_reward.zhangong then
		text = ToColorStr(self_zhangong_text.." / "..next_reward_text, TEXT_COLOR.ACTIVITY_GREEN)
	else
		text = ToColorStr(self_zhangong_text, TEXT_COLOR.RED)..ToColorStr(" / "..next_reward_text, TEXT_COLOR.ACTIVITY_GREEN)
	end
	self.reward_count:SetValue(text)
	--排名
	self:FlushRank()
	self.is_atk_side:SetValue(CityCombatData.Instance:GetIsAtkSide())
	local is_destroy = CityCombatData.Instance:GetwallIsDestroy()
	self.door_is_destroy:SetValue(is_destroy)
	if CityCombatData.Instance:GetIsAtkSide() then
		self.show_skill_image:SetAsset(ResPath.GetOtherSkill("4001"))
	else
		self.show_skill_image:SetAsset(ResPath.GetOtherSkill("4002"))
	end
end

function CityCombatFBView:FlushRank()
	local rank_data = nil
	if self.select_rank == 1 then
		rank_data = CityCombatData.Instance:GetTimeRankList()
	else
		rank_data = CityCombatData.Instance:GetZhanGongRankList()
	end

	for i=1,#self.rank_list do
		if rank_data[i] ~= nil then
			self.rank_list[i]:SetActive(true)
			self.rank_list[i]:SetData(rank_data[i])
		else
			self.rank_list[i]:SetActive(false)
		end
	end
end

function CityCombatFBView:OpenCallBack()
	self.now_max_zhangong = 0
end

function CityCombatFBView:OnMainUIModeListChange(is_show)
	self.show_panel:SetValue(is_show)
end

function CityCombatFBView:ExitClick()
	local func = function()
		FuBenCtrl.Instance:SendExitFBReq()
	end
	TipsCtrl.Instance:ShowCommonTip(func, nil, Language.Common.ExitFuBen)
end

function CityCombatFBView:ToggleChange(is_on)
	if is_on then
		self.select_rank = 1
	else
		self.select_rank = 2
	end
	self:FlushRank()
end

function CityCombatFBView:SetCityCombatFBTimeValue(value)
	-- self.show_time:SetValue(value)
end

--寻路至资源区
function CityCombatFBView:ToResourceZone()
	CityCombatCtrl.Instance:QuickChangePlace(CITY_COMBAT_MOVE_TYPE.ZHIYUAN_PLACE)
end

--寻路至砍旗
function CityCombatFBView:CutFlag()
	local door_is_destroy = CityCombatData.Instance:GetwallIsDestroy()
	local is_in_res_zone = CityCombatData.Instance:CheckSelfIsInResZone()
	-- if CityCombatData.Instance:GetIsAtkSide() then
		-- if is_in_res_zone then
		-- 	CityCombatCtrl.Instance:QuickChangePlace(CITY_COMBAT_MOVE_TYPE.ATTACK_PLACE)
		-- end
	-- else
		-- if is_in_res_zone then
		-- 	CityCombatCtrl.Instance:QuickChangePlace(CITY_COMBAT_MOVE_TYPE.DEFENCE_PLACE)
		-- end
	-- end
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
end

function CityCombatFBView:OnMoveByClick()
	self.auto_guaji = false
end

function CityCombatFBView:MainRoleRevive()
	if self.auto_guaji then
		self:RemoveDelayTime()
		-- 延迟是因为主角复活后有可能坐标还没有reset
		self.delay_time = GlobalTimerQuest:AddDelayTimer(function() GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto) end, 0.5)
	end
end

function CityCombatFBView:OnGuajiTypeChange(guaji_type)
	if guaji_type == GuajiType.Auto then
		self.auto_guaji = true
	end
end

function CityCombatFBView:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

----------------------------------------------------------------------------
--CityCombatRankCell 		排名格子
----------------------------------------------------------------------------
CityCombatRankCell = CityCombatRankCell or BaseClass(BaseCell)
function CityCombatRankCell:__init(instance, rank_num, parent)
	self.parent_view = parent
	self.rank = self:FindVariable("Rank")
	self.rank:SetValue(rank_num)
	self.name = self:FindVariable("Name")
	self.value = self:FindVariable("Value")
	self.is_self = self:FindVariable("IsSelf")
end

function CityCombatRankCell:__delete()
	self.parent_view = nil
end

function CityCombatRankCell:OnFlush()
	self.name:SetValue(self.data.name)
	local value = self.data.value
	if self.parent_view.select_rank == 1 then
		value = TimeUtil.FormatSecond(self.data.value, 2)
	end
	self.value:SetValue(value)
	self.is_self:SetValue(self.data.is_self)
end
