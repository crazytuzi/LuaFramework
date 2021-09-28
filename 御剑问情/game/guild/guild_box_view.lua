require("game/guild/guild_box_preview_view")
GuildBoxView = GuildBoxView or BaseClass(BaseRender)

local ListViewDelegate = ListViewDelegate

function GuildBoxView:__init(instance)
	if instance == nil then
		return
	end

	self.temp_info_list = {}
	self.current_box_index = 0

	self.scroller = self:FindObj("Scroller")
	self.reward_cell = ItemCell.New()
	self.reward_cell:SetInstanceParent(self:FindObj("Reward"))
	self.toggle = self:FindObj("Toggle").toggle
	self.assist_window = self:FindObj("AssistWindow")
	self.color_toggle = self:FindObj("ColorToggle")
	self.scroller_assist = self:FindObj("ScrollerAssist")
	self.auto_toggle = self:FindObj("AutoToggle").toggle

	self.icon = self:FindVariable("Icon")
	self.is_usd_all = self:FindVariable("IsUsdAll")
	self.box_name = self:FindVariable("BoxName")
	self.rest_count = self:FindVariable("RestCount")
	self.level_up_count = self:FindVariable("LevelUpCount")
	self.assist_count = self:FindVariable("AssistCount")
	self.time = self:FindVariable("Time")
	self.has_free_level_up = self:FindVariable("HasFreeLevelUp")
	self.has_assist = self:FindVariable("HasAssist")
	self.has_rest_count = self:FindVariable("HasRestCount")
	self.open_block = self:FindVariable("OpenBlock")
	self.show_color_list = self:FindVariable("ShowColorList")
	self.show_block = self:FindVariable("ShowBlock")
	self.price = self:FindVariable("Price")
	self.show_free_times = self:FindVariable("ShowFreeTimes")
	self.is_free_level_up = self:FindVariable("IsFreeLevelUp")
	self.zan_wu_xie_zhu = self:FindVariable("zanwuxiezhu")
	self.box_color = self:FindVariable("BoxColor")
	self.show_cd = self:FindVariable("show_cd")
	self.show_row = self:FindVariable("show_row")
	self.show_paycount = self:FindVariable("show_paycount")
	self.show_freecount = self:FindVariable("show_freecount")
	self.show_full_level = self:FindVariable("show_full_level")
	self.zan_wu_xie_zhu:SetValue("")

	self.open_block:SetValue(false)
	self.show_color_list:SetValue(false)
	self.show_block:SetValue(false)

	self:ListenEvent("LevelUpFree",
		BindTool.Bind(self.LevelUpFree, self))
	self:ListenEvent("LevelUpPay",
		BindTool.Bind(self.LevelUpPay, self))
	self:ListenEvent("OpenColorList",
		BindTool.Bind(self.OpenColorList, self))
	self:ListenEvent("CloseColorList",
		BindTool.Bind(self.CloseColorList, self))
	self:ListenEvent("AssistList",
		BindTool.Bind(self.AssistList, self))
	self:ListenEvent("WaBao",
		BindTool.Bind(self.WaBao, self))
	self:ListenEvent("WaBao2",
		BindTool.Bind(self.WaBao2, self))
	self:ListenEvent("StopAutoLevelUp",
		BindTool.Bind(self.StopAutoLevelUp, self))
	self:ListenEvent("ClickHelp",
		BindTool.Bind(self.ClickHelp, self))
	self:ListenEvent("ClickClearTime",
		BindTool.Bind(self.ClickClearTime, self))
	self:ListenEvent("ClickAutoClear",
		BindTool.Bind(self.ClickAutoClear, self))
	self:ListenEvent("ClickPre",
		BindTool.Bind(self.ClickPre, self))
	self:ListenEvent("ClickNext",
		BindTool.Bind(self.ClickNext, self))
	self:ListenEvent("closetips",
		BindTool.Bind(self.CloseTips, self))
	self:ListenEvent("OnClickBox",
		BindTool.Bind(self.OnClickBox, self))
	self:ListenEvent("OnClickPre",
		BindTool.Bind(self.OnClickPre, self))

	for i = 1, 4 do
		self:ListenEvent("OnClickColor" .. i,
			function() self:OnClickColor(i) end)
	end

	self.other_config = GuildData.Instance:GetOtherConfig()
	self.box_config = GuildData.Instance:GetBoxConfig()

	self.free_count = true
	self.rest_box_count = 0
	self.temp_level_up_count = 0
	self.select_color = 1
	self.min = 0
	self.sec = 0
	self.hour = 0
	self.cur_shake_box = 1
	self.cur_shake_box_info = nil
	self.shake_box_list = {}
	self.cell_list = {}
	self.show_free_value = true
	self:OnClickColor(self.select_color)

	if self.other_config then
		local price = self.other_config.box_up_gold or 0
		self.price:SetValue(price)
	end

	self.preview_window = GuildBoxPreviewView.New()
	self:InitScroller()
	self:InitScrollerAssist()

	self.item_change_callback = BindTool.Bind(self.OnItemDataChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)
end

function GuildBoxView:__delete()
	self:RemoveCountDown()
	self:StopAutoLevelUp()
	-- for k,v in pairs(self.preview_cell) do
	-- 	if v.cell then
	-- 		v.cell:DeleteMe()
	-- 	end
	-- end
	-- self.preview_cell = {}
	if self.reward_cell then
		self.reward_cell:DeleteMe()
		self.reward_cell = nil
	end
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k,v in pairs(self.cell_list_assist) do
		v:DeleteMe()
	end
	self.cell_list_assist = {}

	if self.item_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
		self.item_change_callback = nil
	end

	if self.preview_window then
		self.preview_window:DeleteMe()
		self.preview_window = nil
	end

end

--初始化滚动条
function GuildBoxView:InitScroller()
	self.list_view_delegate = ListViewDelegate()
	self.scroller = self:FindObj("Scroller")

	PrefabPool.Instance:Load(AssetID("uis/views/guildview_prefab", "BoxCell"), function (prefab)
		if nil == prefab then
			return
		end
		local enhanced_cell_type = prefab:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		PrefabPool.Instance:Free(prefab)

		self.enhanced_cell_type = enhanced_cell_type
		self.scroller.scroller.Delegate = self.list_view_delegate

		self.list_view_delegate.numberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		self.list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		self.list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)
	end)
end

function GuildBoxView:OnItemDataChange(change_item_id, change_item_index, change_reason, put_reason, old_num, new_num)
	if put_reason == PUT_REASON_TYPE.PUT_REASON_GUILD_BOX_REWARD then
		TipsCtrl.Instance:OpenGuildRewardView({item_id = change_item_id, num = new_num - old_num})
	end
end

--滚动条数量
function GuildBoxView:GetNumberOfCells()
	local count = 0
	self.box_info = GuildData.Instance:GetBoxInfo()
	if self.box_info then
		if self.box_info.info_list then
			for i = 1, MAX_GUILD_BOX_COUNT do
				if self.box_info.info_list[i] then
					if self.box_info.info_list[i].open_time ~= 0 then
						count = count + 1
					end
				end
			end
		end
		-- self.level_up_count:SetValue(self.box_info.uplevel_count .. "/" .. 3)
	end
	return count
end

--滚动条大小
function GuildBoxView:GetCellSize(data_index)
	return 143
end

--滚动条刷新
function GuildBoxView:GetCellView(scroller, data_index, cell_index)
	if nil == next(self.temp_info_list) then return end
	local cell_view = scroller:GetCellView(self.enhanced_cell_type)
	local cell = self.cell_list[cell_view]
	if cell == nil then
		self.cell_list[cell_view] = GuildBoxViewScrollCell.New(cell_view)
		cell = self.cell_list[cell_view]
		cell.sell_view = self
		cell:SetClickCallBack(BindTool.Bind(self.OpenBox, self))
	end
	local data = self.temp_info_list[data_index + 1]
	data.data_index = data_index
	cell:SetData(data)
	return cell_view
end

function GuildBoxView:ClickPre()
	local position = self.scroller.scroller.ScrollPosition
	local index = self.scroller.scroller:GetCellViewIndexAtPosition(position)
	index = index - 1
	self:JumpToIndex(index)
end

function GuildBoxView:ClickNext()
	local position = self.scroller.scroller.ScrollPosition
	local index = self.scroller.scroller:GetCellViewIndexAtPosition(position)
	index = index + 1
	self:JumpToIndex(index)
end

function GuildBoxView:CloseTips()
	self.show_free_times:SetValue(false)
	self.show_free_value = true
end

function GuildBoxView:JumpToIndex(index)
	local max_count = self:GetNumberOfCells()
	index = index >= max_count and max_count - 1 or index
	if index < 0 then
		index = 0
	end
	local width = self.scroller.transform:GetComponent(typeof(UnityEngine.RectTransform)).sizeDelta.x
	local space = self.scroller.scroller.spacing
	-- 当前页面可以显示的数量
	local count = math.floor((width + space) / (self:GetCellSize() + space))
	if max_count <= count or index + count > max_count then
		return
	end

	local jump_index = index
	local scrollerOffset = 0
	local cellOffset = 0
	local useSpacing = false
	local scrollerTweenType = self.scroller.scroller.snapTweenType
	local scrollerTweenTime = 0.1
	local scroll_complete = nil
	self.scroller.scroller:JumpToDataIndexForce(
		jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
end

function GuildBoxView:Flush()
	self:CloseColorList()
	self.box_info = GuildData.Instance:GetBoxInfo()

	self.temp_info_list = {}
	local count = 1
	for k,v in pairs(self.box_info.info_list) do
		if v.open_time ~= 0 then
			self.temp_info_list[count] = v
			count = count + 1
		end
	end
	table.sort(self.temp_info_list, function(a, b)
			if a.is_reward == 1 and b.is_reward == 1 then
				return a.open_time > b.open_time
			else
				return a.is_reward < b.is_reward
			end
		end)

	if self.box_info then
		self.temp_level_up_count = self.box_info.uplevel_count
		if self.box_info.uplevel_count >= self.other_config.box_free_up_count then
			self.has_free_level_up:SetValue(false)
			self.free_count = false
		else
			self.has_free_level_up:SetValue(true)
			self.free_count = true
		end
		if self.box_info.info_list then
			local has_no_open_box = false
			for i = 1, MAX_GUILD_BOX_COUNT do
				if self.box_info.info_list[i] then
					if self.box_info.info_list[i].is_reward == 0 and self.box_info.info_list[i].open_time == 0 then
						self.current_box_index = i - 1
						local bundle, asset = ResPath.GetGuildBoxIcon(self.box_info.info_list[i].box_level)
						self.icon:SetAsset(bundle, asset)
						self.box_color:SetValue(Language.Guild.GuildBox[self.box_info.info_list[i].box_level])
						if self.box_config then
							local config = self.box_config[self.box_info.info_list[i].box_level + 1]
							if config then
								local item_id = ResPath.CurrencyToIconId.bind_diamond
								local num = config.be_assist_reward_bind_gold

								self.reward_cell:SetData({item_id = item_id, num = num})
							end
						end
						has_no_open_box = true
						break
					end
				end
			end
			if not has_no_open_box then
				self.is_usd_all:SetValue(true)
			else
				self.is_usd_all:SetValue(false)
			end
		end
		self.level_up_count:SetValue(math.max(self.other_config.box_free_up_count - self.box_info.uplevel_count, 0) .. " / " .. self.other_config.box_free_up_count)

		self.select_color = 4
		self:OnClickColor(self.select_color)

		local rest_count = GuildData.Instance:GetRestOpenBoxCount()
		if rest_count then
			self.rest_box_count = rest_count
			self.rest_count:SetValue(math.max(rest_count, 0))

			if rest_count > 0 and not GuildData.Instance:IsGuildCD() and GuildData.Instance:IsGuildBoxStart() and GuildData.Instance:IsCanWaQuBox() then
				self.has_rest_count:SetValue(true)
			else
				self.has_rest_count:SetValue(false)
			end
		end
	end

	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end

	local info = self.box_info.info_list[self.current_box_index + 1]
	if info and info.box_level >= GUILD_MAX_BOX_LEVEL then
		self.show_full_level:SetValue(true)
	else
		self.show_full_level:SetValue(false)
	end

	self:FlushAssist()
	self:StartCountDown()
end

function GuildBoxView:AssistList()
	GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_QUERY_NEED_ASSIST)
	if self.assist_window then
		self.assist_window:SetActive(true)
		-- self:FlushAssist()
	end
end

function GuildBoxView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(149)
end

function GuildBoxView:ClickAutoClear(state)
	if state then
		local des = Language.Guild.AutoClearTime
		TipsCtrl.Instance:ShowCommonAutoView(nil, des, nil, function() self.auto_toggle.isOn = false end)
	end
end

function GuildBoxView:LevelUpFree()
	if self.rest_box_count == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.MaxBoxLevelUp)
		return
	end

	if GuildData.Instance:IsGuildCD() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.ExitGuildBoxCD)
		return
	end

	if not GuildData.Instance:IsGuildBoxStart() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.BoxNotStart)
		return
	end

	local info = self.box_info.info_list[self.current_box_index + 1]
	if info then
		if self.toggle.isOn == true then
			if info.box_level >= self.select_color then
				SysMsgCtrl.Instance:ErrorRemind(Language.Guild.MaxBoxLevel2)
				return
			end
		else
			if info.box_level >= GUILD_MAX_BOX_LEVEL then
				SysMsgCtrl.Instance:ErrorRemind(Language.Guild.MaxBoxLevel)
				return
			end
		end
	end

	if self.toggle.isOn == true then
		self:AutoLevelUp()
		return
	end

	self.temp_level_up_count = self.temp_level_up_count + 1
	if self.temp_level_up_count > 2 then
		self.has_free_level_up:SetValue(false)
		self.free_count = false
	else
		self.has_free_level_up:SetValue(true)
		self.free_count = true
	end
	self.level_up_count:SetValue(math.max(self.other_config.box_free_up_count - self.temp_level_up_count, 0) .. " / " .. self.other_config.box_free_up_count)
	GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_UPLEVEL, self.current_box_index)
end

function GuildBoxView:LevelUpPay()
	local info = self.box_info.info_list[self.current_box_index + 1]
	if info then
		if self.toggle.isOn == true then
			if info.box_level >= self.select_color then
				SysMsgCtrl.Instance:ErrorRemind(Language.Guild.MaxBoxLevel2)
				return
			end
		else
			if info.box_level >= GUILD_MAX_BOX_LEVEL then
				SysMsgCtrl.Instance:ErrorRemind(Language.Guild.MaxBoxLevel)
				return
			end
		end
	end

	if self.rest_box_count == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.MaxBoxLevelUp)
		return
	end

	if GuildData.Instance:IsGuildCD() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.ExitGuildBoxCD)
		return
	end

	if not GuildData.Instance:IsGuildBoxStart() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.BoxNotStart)
		return
	end

	if self.toggle.isOn == true then
		self:AutoLevelUp()
		return
	end

	local describe = string.format(Language.Guild.PayBoxLevelUp, self.other_config.box_up_gold)
	local yes_func = function() GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_UPLEVEL, self.current_box_index) end

	TipsCtrl.Instance:ShowCommonAutoView("guild_box" ,describe, yes_func)
end

function GuildBoxView:AutoLevelUp()
	-- local index = self.select_color
	-- local str = Language.Guild.GuildBox[index]
	-- local describe = ""
	-- if self.free_count then
	-- 	describe = string.format(Language.Guild.AutoBoxLevelUp2, str)
	-- else
	-- 	describe = string.format(Language.Guild.AutoBoxLevelUp, str)
	-- end
	-- local yes_func = function() self:DoAutoLevelUp(index) end
	-- TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	local index = self.select_color
	self:DoAutoLevelUp(index)
end

function GuildBoxView:DoAutoLevelUp(color)
	self.aim_color = color
	if self.rest_box_count == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.MaxBoxLevelUp)
		self:StopAutoLevelUp()
		return
	end

	if not GuildData.Instance:IsGuildBoxStart() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.BoxNotStart)
		self:StopAutoLevelUp()
		return
	end

	self.show_block:SetValue(true)
	if self.box_info then
		local info = self.box_info.info_list[self.current_box_index + 1]
		if info then
			if info.box_level >= self.aim_color then
				self:StopAutoLevelUp()
				SysMsgCtrl.Instance:ErrorRemind(Language.Guild.MaxBoxLevel2)
			else
				local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
				if self.temp_level_up_count >= self.other_config.box_free_up_count and main_role_vo.gold < self.other_config.box_up_gold then
					self:StopAutoLevelUp()
					GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_UPLEVEL, self.current_box_index)
				else
					GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_UPLEVEL, self.current_box_index)
					self.timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.DoAutoLevelUp, self, self.aim_color), 0.5)

					self.temp_level_up_count = self.temp_level_up_count + 1
					if self.temp_level_up_count > 2 then
						self.has_free_level_up:SetValue(false)
					else
						self.has_free_level_up:SetValue(true)
					end
					self.level_up_count:SetValue(math.max(self.other_config.box_free_up_count - self.temp_level_up_count, 0) .. " / " .. self.other_config.box_free_up_count)
				end
			end
		end
	end
end

function GuildBoxView:StopAutoLevelUp()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	self.show_block:SetValue(false)
end

function GuildBoxView:OpenColorList()
	local state = self.color_toggle.animator:GetBool("Open")
	if state then
		self.color_toggle.animator:SetBool("Open", false)
		self.open_block:SetValue(false)
	else
		self.open_block:SetValue(true)
		self.show_color_list:SetValue(true)
		self.color_toggle.animator:SetBool("Open", true)
	end
end

function GuildBoxView:CloseColorList()
	if self.color_toggle.animator.isActiveAndEnabled then
		self.color_toggle.animator:SetBool("Open", false)
		self.open_block:SetValue(false)
	end
end

function GuildBoxView:ShowColorList(state)
	self.show_color_list:SetValue(false)
end

function GuildBoxView:OnClickColor(index)
	self.select_color = index
	local str = Language.Guild.GuildBox[index]
	self.box_name:SetValue(str)
	self:CloseColorList()
end

function GuildBoxView:WaBao()
	if self.rest_box_count == 0 then
		TipsCtrl.Instance:ShowLockVipView(VIPPOWER.GUILD_BOX_COUNT)
		return
	end

	if not GuildData.Instance:IsCanWaQuBox() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.CanNotWaBao)
		return
	end

	if not GuildData.Instance:IsGuildBoxStart() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.BoxNotStart)
		self:StopAutoLevelUp()
		return
	end

	local info = self.box_info.info_list[self.current_box_index + 1]
	if self.other_config.box_free_up_count - self.box_info.uplevel_count > 0 and self.show_free_value then
		self.show_free_times:SetValue(true)
		self.show_freecount:SetValue(true)
		self.show_paycount:SetValue(false)
		self.show_free_value = false
		return
	else
		self.show_free_times:SetValue(false)
		self.show_free_value = true
	end

	--没满级宝箱就提示
	if info.box_level < 4 and self.box_info.uplevel_count >= self.other_config.box_free_up_count then
		self.show_free_times:SetValue(true)
		self.show_freecount:SetValue(false)
		self.show_paycount:SetValue(true)
		return
	else
		self.show_free_times:SetValue(false)
	end

	GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_OPEN, self.current_box_index)
end

function GuildBoxView:WaBao2()
	self.show_free_times:SetValue(false)
	GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_OPEN, self.current_box_index)
end

function GuildBoxView:StartCountDown()
	if self.count_down then return end
	self.count_down = CountDown.Instance:AddCountDown(99999999, 1, BindTool.Bind(self.CountDown, self, nil))
end

function GuildBoxView:CountDown(callback, elapse_time, total_time)
	for k,v in pairs(self.cell_list) do
		v:FlushTime(elapse_time)
	end
	self:FlushAssistTime()
	self:ShakeBox()
end

function GuildBoxView:ShakeBox()
	local count = #self.shake_box_list
	if self.cur_shake_box > count then
		self.cur_shake_box = 1
		self.shake_box_list = {}
		for k,v in pairs(self.cell_list) do
			if v.can_open then
				table.insert(self.shake_box_list, v)
			end
		end
		table.sort(self.shake_box_list, function(a,b) return a.data.data_index < b.data.data_index end)
	end
	local box = self.shake_box_list[self.cur_shake_box]
	while(true) do
		self.cur_shake_box_info = box
		if box == nil then break end
		if box.can_open then
			box:Shake()
			self.cur_shake_box = self.cur_shake_box + 1
			break
		else
			table.remove(self.shake_box_list)
			box = self.shake_box_list[self.cur_shake_box]
		end
	end
end

function GuildBoxView:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function GuildBoxView:OpenBox(info)
	if not info.index then return end
	GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_FETCH, info.index)
	if self.cur_shake_box_info and self.cur_shake_box_info.data.index == info.index then
		GlobalTimerQuest:AddDelayTimer(function() GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_QUERY_SELF) end, 1)
	else
		GlobalTimerQuest:AddDelayTimer(function() GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_QUERY_SELF) end, 0.1)
	end
end

function GuildBoxView:OnClickBox()
	local info = self.box_info.info_list[self.current_box_index + 1]
	if info then
		local config = GuildData.Instance:GetBoxConfigByLevel(info.box_level)
		if config then
			local reward = {config.item_reward}
			TipsCtrl.Instance:ShowRewardView(reward)
		end
	end
end

--------------------------------------------------------------Cell---------------------------------------------------------
GuildBoxViewScrollCell = GuildBoxViewScrollCell or BaseClass(BaseCell)

function GuildBoxViewScrollCell:__init()
	self.root_node.list_cell.refreshCell = BindTool.Bind(self.Flush, self)
	self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.time = self:FindVariable("Time")
	self.is_can_open = self:FindVariable("IsCanOpen")
	self.anim = self:FindObj("Icon").animator
	self.can_open = false
	self.callback = nil
	self:ListenEvent("OnClick", BindTool.Bind(self.OnClickBox, self))
end

function GuildBoxViewScrollCell:__delete()

end

function GuildBoxViewScrollCell:Flush()
	self.name:SetValue("")
	-- if self.data.assist_uid[1] == 0 then
	-- 	self.name:SetValue("")
	-- else
	-- 	self.name:SetValue(self.data.assist_name[1])
	-- end
	local bundle, asset = ResPath.GetGuildBoxIcon(self.data.box_level, false)
	self.icon:SetAsset(bundle, asset)
	if self.data.is_reward == 0 then
		self.time:SetValue(Language.Common.CanOpen)
		self.is_can_open:SetValue(true)
	else
		self.time:SetValue(Language.Common.HasOpen)
		self.can_open = false
		self.is_can_open:SetValue(false)
		bundle, asset = ResPath.GetGuildBoxIcon(self.data.box_level, true)
		self.icon:SetAsset(bundle, asset)
	end
	self:ShowTime()
end

function GuildBoxViewScrollCell:SetClickCallBack(callback)
	self.callback = callback
end

function GuildBoxViewScrollCell:OnClickBox()
	-- for k,v in pairs(self.data) do
	-- 	print_log('Key:'..k..'--Value:'..v)
	-- end
    --TipsCtrl.Instance:ShowRewardView(reward)
	if not self.can_open and self.data.is_reward == 0 then
		local config = GuildData.Instance:GetBoxConfigByLevel(self.data.box_level)
		if config then
			local reward = {config.item_reward}
			TipsCtrl.Instance:ShowRewardView(reward)
		end
	else
		self.callback(self.data)
	end
end

function GuildBoxViewScrollCell:FlushTime(elapse_time)
	if not self.t_time then
		return
	end
	self:ShowTime()
end

function GuildBoxViewScrollCell:Shake()
	self.anim:SetTrigger("Shake")
end

function GuildBoxViewScrollCell:ShowTime()
	local now_time = TimeCtrl.Instance:GetServerTime()
	if self.data.open_time > now_time then
		self.is_can_open:SetValue(false)
		self.can_open = false
		self.t_time = TimeUtil.Timediff(self.data.open_time, now_time)
		local min = self.t_time.min
		local sec = self.t_time.sec
		local hour = self.t_time.hour
		if min < 10 then
			min = 0 .. min
		end
		if sec < 10 then
			sec = 0 .. sec
		end
		if hour <= 0 then
			self.time:SetValue(min .. Language.Common.Minute .. sec .. Language.Common.Second)
		else
			self.time:SetValue(hour .. Language.Common.Hour .. min .. Language.Common.Minute)
		end
	else
		if self.data.is_reward == 0 then
			self.time:SetValue(Language.Common.CanOpen)
			self.is_can_open:SetValue(true)
			self.can_open = true
		end
		self.t_time = nil
	end
end

---------------------------------------------------顶级预览---------------------------------------------------------------

-- function GuildBoxView:InitPreview()
-- 	self.preview = self:FindObj("Preview")
-- 	local name_table = self.preview:GetComponent(typeof(UINameTable))
-- 	self.preview_cell = {}
-- 	for i = 1, 5 do
-- 		self.preview_cell[i] = {}
-- 		self.preview_cell[i].obj = name_table:Find("ItemCell" .. i)
-- 		self.preview_cell[i].cell = ItemCell.New()
-- 		self.preview_cell[i].cell:SetInstanceParent(self.preview_cell[i].obj)
-- 	end

-- 	self:FlushPreview()
-- end

	function GuildBoxView:OnClickPre()
		self.preview_window:Open()
	end

-----------------------------------------------------------协助窗口----------------------------------------------------
--初始化滚动条
function GuildBoxView:InitScrollerAssist()
	self.cell_list_assist = {}
	self.list_view_delegate_assist = ListViewDelegate()
	self.scroller_assist = self:FindObj("ScrollerAssist")

	PrefabPool.Instance:Load(AssetID("uis/views/guildview_prefab", "AssistInfo"), function (prefab)
		if nil == prefab then
			return
		end
		local enhanced_cell_type = prefab:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		PrefabPool.Instance:Free(prefab)

		self.enhanced_cell_type_assist = enhanced_cell_type
		self.scroller_assist.scroller.Delegate = self.list_view_delegate_assist

		self.list_view_delegate_assist.numberOfCellsDel = BindTool.Bind(self.GetNumberOfCellsAssist, self)
		self.list_view_delegate_assist.cellViewSizeDel = BindTool.Bind(self.GetCellSizeAssist, self)
		self.list_view_delegate_assist.cellViewDel = BindTool.Bind(self.GetCellViewAssist, self)
	end)
end

--滚动条数量
function GuildBoxView:GetNumberOfCellsAssist()
	local info = GuildData.Instance:GetAssistInfo()
	if info then
		if info.box_count > 0 then
			self.zan_wu_xie_zhu:SetValue("")
		else
			self.zan_wu_xie_zhu:SetValue(Language.Guild.ZanWuXieZhu)
		end
		return info.box_count
	end
	return 0
end

--滚动条大小
function GuildBoxView:GetCellSizeAssist(data_index)
	return 126
end

--滚动条刷新
function GuildBoxView:GetCellViewAssist(scroller, data_index, cell_index)
	local cell_view = scroller:GetCellView(self.enhanced_cell_type_assist)

	local cell = self.cell_list_assist[cell_view]
	if cell == nil then
		self.cell_list_assist[cell_view] = GuildBoxViewScrollAssistCell.New(cell_view)
		cell = self.cell_list_assist[cell_view]
		cell.sell_view = self
		cell:ListenAllEvent()
	end
	local info = GuildData.Instance:GetAssistInfo().info_list
	table.sort(info, SortTools.KeyUpperSorter("box_level"))
	if info then
		local data = info[data_index + 1]
		if data then
			data.data_index = data_index
			cell:SetData(data)
		end
	end
	return cell_view
end

function GuildBoxView:OnClickAssist(info)
	if self.rest_assist_count == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.MaxBoxAssist)
		return
	end
	if info.open_time <= TimeCtrl.Instance:GetServerTime() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.BoxCanNotAssist)
		return
	end
	if self.auto_toggle.isOn == true then
		if info.box_level >= 3 and self.box_info.assist_cd_end_time ~= 0 then
			if self.hour > 0 or self.min >= 20 then
				GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_CLEAN_ASSIST_CD)
				GlobalTimerQuest:AddDelayTimer(function() GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_ASSIST, info.box_index, info.uid) end , 0.5)
				return
			end
		end
	end
	GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_ASSIST, info.box_index, info.uid)
end

function GuildBoxView:FlushAssist()
	if self.scroller_assist.scroller.isActiveAndEnabled then
		self.scroller_assist.scroller:RefreshAndReloadActiveCellViews(true)
	end
	local info = GuildData.Instance:GetBoxInfo()
	if info and self.other_config then
		self.rest_assist_count = self.other_config.box_assist_max_count - info.assist_count
		self.assist_count:SetValue(self.rest_assist_count)
	end
	self:FlushAssistTime()
end

function GuildBoxView:FlushAssistTime()
	local now_time = TimeCtrl.Instance:GetServerTime()
	local info = GuildData.Instance:GetBoxInfo()
	self.has_assist:SetValue(false)
	local assist_info = GuildData.Instance:GetAssistInfo()
	if info then
		if info.assist_cd_end_time > now_time then
			local t_time = TimeUtil.Timediff(info.assist_cd_end_time, now_time)
			local min = t_time.min
			local sec = t_time.sec
			local hour = t_time.hour

			self.min = min
			self.sec = sec
			self.hour = hour

			local flag = false
			if assist_info then
				if assist_info.box_count > 0 then
					if self.rest_assist_count > 0 then
						local other_config = GuildData.Instance:GetOtherConfig()
						if other_config then
							local box_assist_cd_limit = other_config.box_assist_cd_limit
							if box_assist_cd_limit then
								if info.assist_cd_end_time - now_time <= box_assist_cd_limit then
									self.has_assist:SetValue(true)
								else
									flag = true
								end
							end
						end
					else
						flag = true
					end
				end
			end

			if min > 20 then
				min = min - 20
			end
			if min < 10 then
				min = 0 .. min
			end
			if hour < 10 then
				hour = 0 .. hour
			end
			if sec < 10 then
				sec = 0 .. sec
			end
			local str = hour .. ":" .. min .. ":" .. sec
			if flag then
				str = ToColorStr(str, TEXT_COLOR.RED)
			end
			self.time:SetValue(str)
			self.show_cd:SetValue(self.hour > 0 or self.min >= 20)
			self.show_row:SetValue(self.hour > 0 or self.min >= 20)
		else
			self.min = 0
			self.sec = 0
			self.hour = 0
			local str = "00:00:00"
			if assist_info then
				if assist_info.box_count > 0 then
					if self.rest_assist_count > 0 then
						self.has_assist:SetValue(true)
					else
						str = ToColorStr(str, TEXT_COLOR.RED)
					end
				end
			end
			self.time:SetValue(str)
			self.show_cd:SetValue(self.hour > 0 or self.min >= 20)
			self.show_row:SetValue(self.hour > 0 or self.min >= 20)
		end
	end
end

function GuildBoxView:ClickClearTime()
	if self.rest_assist_count <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.MaxBoxAssist)
		return
	end

	if self.hour == 0 and self.min < 20 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotNeedBuyAssistTime)
		return
	end

	local gold = GameVoManager.Instance:GetMainRoleVo().gold
	local cost = math.ceil((self.hour * 60 + self.min + (self.sec > 0 and 1 or 0)) / 2)
	local str = ""
	if cost <= gold then
		str = ToColorStr(cost, TEXT_COLOR.GREEN)
	else
		str = ToColorStr(cost, TEXT_COLOR.RED)
	end
	local describe = string.format(Language.Guild.BuyAssistTime, str)
	local yes_func = function() GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_CLEAN_ASSIST_CD) end
	TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
end
--------------------------------------------------------------AssistCell---------------------------------------------------------
GuildBoxViewScrollAssistCell = GuildBoxViewScrollAssistCell or BaseClass(BaseCell)

function GuildBoxViewScrollAssistCell:__init()
	self.root_node.list_cell.refreshCell = BindTool.Bind(self.Flush, self)

	self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.master_name = self:FindVariable("MasterName")
	self.reward_cell = ItemCell.New()
	self.reward_cell:SetInstanceParent(self:FindObj("Reward"))
end

function GuildBoxViewScrollAssistCell:__delete()
	if self.reward_cell then
		self.reward_cell:DeleteMe()
		self.reward_cell = nil
	end
end

function GuildBoxViewScrollAssistCell:Flush()
	local index = self.data.box_level
	local str = Language.Guild.GuildBox[index]
	self.name:SetValue(str)

	local bundle, asset = ResPath.GetGuildBoxIcon(index)
	self.icon:SetAsset(bundle, asset)
	self.master_name:SetValue(self.data.user_name)

	local config = GuildData.Instance:GetBoxConfig()[self.data.box_level + 1]
	if config then
		local item_id = config.assist_reward.item_id
		local num = config.assist_reward.num

		self.reward_cell:SetData({item_id = item_id, num = num})
	end
end

function GuildBoxViewScrollAssistCell:ListenAllEvent()
	self:ListenEvent("Assist",
		function() GuildCtrl.Instance.view.box_view:OnClickAssist(self.data) end)
end