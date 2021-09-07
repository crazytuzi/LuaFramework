GuildActivityView = GuildActivityView or BaseClass(BaseRender)

function GuildActivityView:__init(instance)
	if instance == nil then
		return
	end

	self.scroller = self:FindObj("Scroller")
	self.scroller_rect = self:FindObj("ScrollerRect"):GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.toggle_group = self.scroller.toggle_group
	self.item_cell = {}
	for i = 1, 3 do
		self.item_cell[i] = {}
		self.item_cell[i].obj = self:FindObj("ItemCell" .. i)
		self.item_cell[i].cell = ItemCell.New()
		self.item_cell[i].cell:SetInstanceParent(self.item_cell[i].obj)
	end
	self.des = self:FindVariable("Des")
	self.cell_list = {}
	self.activity_config = GuildData.Instance:GetActivityConfig()
	self.activity_id = 24
	if self.activity_config and self.activity_config[1] then
		self.activity_id = self.activity_config[1].activity_id
	end
	self.show_red_point_list = {}
	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)

	self:InitScroller()
end

function GuildActivityView:__delete()
	for k,v in pairs(self.item_cell) do
		v.cell:DeleteMe()
	end
	self.item_cell = {}
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end
end

function GuildActivityView:Flush()
	self.show_red_point_list = {}
	self.show_red_point_list[ACTIVITY_TYPE.GUILD_BOSS] = GuildData.Instance.red_point_list[Guild_PANEL.boss]
	self.activity_config = GuildData.Instance:GetActivityConfig()
    if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function GuildActivityView:Click(activity_id, des, item_cell)
	self.activity_id = activity_id
	if des then
		self.des:SetValue(des)
		self.scroller_rect.normalizedPosition = Vector2(1, 1)
	end
	if item_cell then
		for i = 1, 3 do
			if item_cell[i] and item_cell[i].item_id > 0 then
				self.item_cell[i].cell:SetData(item_cell[i])
				self.item_cell[i].obj:SetActive(true)
			else
				self.item_cell[i].cell:SetData()
				self.item_cell[i].obj:SetActive(false)
			end
		end
	end
end

function GuildActivityView:InitScroller()
	self.list_view_delegate = self.scroller.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

function GuildActivityView:GetNumberOfCells()
	if self.activity_config then
		return #self.activity_config
	end
	return 0
end

function GuildActivityView:RefreshView(cell, data_index)
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = GuildActivityScrollCell.New(cell.gameObject)
		self.cell_list[cell] = group_cell
		group_cell:SetHandle(self)
		group_cell:SetToggleGroup(self.toggle_group)
	end
	local data = {data_index = data_index}
	if self.activity_config and self.activity_config[data_index + 1] then
		data.activity_id = self.activity_config[data_index + 1].activity_id
		data.button_name = self.activity_config[data_index + 1].button_name
		-- if data_index == 0 then
		-- 	self.activity_id = data.activity_id
		-- end
	end
	group_cell:SetData(data)
end

function GuildActivityView:ActivityCallBack()
	self:Flush()
end

-------------------------------------------------------- GuildActivityScrollCell ----------------------------------------------------------

GuildActivityScrollCell = GuildActivityScrollCell or BaseClass(BaseCell)

function GuildActivityScrollCell:__init()
	self.play_introduction = ""
	self.bg = self:FindVariable("Bg")
	self.time = self:FindVariable("Time")
	self.level = self:FindVariable("Level")
	self.btn_name = self:FindVariable("BtnName")
	self.name = self:FindVariable("Name")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.gray = self:FindVariable("Gray")
	self.toggle = self:FindObj("Toggle").toggle
	self:ListenEvent("OnClick",
		BindTool.Bind(self.OnClick, self))
	self:ListenEvent("OnClickDetails",
		BindTool.Bind(self.OnClickDetails, self))
	self.show_red_point:SetValue(false)
end

function GuildActivityScrollCell:__delete()

end

function GuildActivityScrollCell:OnFlush()
	local index = (self.data.data_index + 1) % 6
	if index == 0 then
		index = 1
	end
	local asset_bundle, name = ResPath.GetGuildActivtyBg(index)
	self.bg:SetAsset(asset_bundle, name)

	if self.data.activity_id == ACTIVITY_TYPE.GUILD_SHILIAN or self.data.activity_id == ACTIVITY_TYPE.GUILD_BONFIRE then
		local post = GuildData.Instance:GetGuildPost()
		local status = GuildData.Instance:GetMiJingState()
		if self.data.activity_id == ACTIVITY_TYPE.GUILD_BONFIRE then
			status = GuildData.Instance:GetBonFireState()
		end
		self.btn_name:SetValue(Language.Common.Join)
		if status ~= 1 then
			if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
				self.btn_name:SetValue(Language.Common.Open)
			end
		end
	else
		self.btn_name:SetValue(self.data.button_name)
	end

	if self.data.activity_id then
		local config = ActivityData.Instance:GetClockActivityByID(self.data.activity_id)
		if config and config.act_id then
			self.name:SetValue(config.act_name)
			local lv, zhuan = PlayerData.GetLevelAndRebirth(tonumber(config.min_level))
			self.level:SetValue(string.format(Language.Common.ZhuanShneng, lv, zhuan))
			if ActivityData.Instance:GetActivityIsInToday(self.data.activity_id) then
				self.time:SetValue(config.open_time .. " - " .. config.end_time)
			else
				local open_day_list = Split(config.open_day, ":")
				if open_day_list then
					local str = Language.Common.Week
					for i = 1, #open_day_list do
						local day = tonumber(open_day_list[i])
						day = Language.Common.DayToChs[day] or ""
						str = str .. day
						if i ~= #open_day_list then
							str = str .. "、"
						end
					end
					str = str .. Language.Common.Open
					self.time:SetValue(ToColorStr(str, TEXT_COLOR.RED))
				end
			end
			self.play_introduction = config.play_introduction
			self.item_cell = {config.reward_item1, config.reward_item2, config.reward_item3}
		end
		if not ActivityData.Instance:GetActivityIsOpen(self.data.activity_id) and
			(ActivityData.Instance:GetActivityIsOver(self.data.activity_id) or
			not ActivityData.Instance:GetActivityIsInToday(self.data.activity_id)) then
			self.gray:SetValue(true)
		else
			self.gray:SetValue(false)
		end
	end
	self.show_red_point:SetValue(false)
	if self.handle then
		if self.handle.activity_id == self.data.activity_id then
			self.toggle.isOn = true
		else
			self.toggle.isOn = false
		end
		if self.handle.show_red_point_list[self.data.activity_id] then
			self.show_red_point:SetValue(true)
		end
	end
end

function GuildActivityScrollCell:OnClickDetails(state)
	if state then
		if self.handle then
			self.handle:Click(self.data.activity_id, self.play_introduction, self.item_cell)
		end
	end
end

function GuildActivityScrollCell:SetHandle(handle)
	self.handle = handle
end

function GuildActivityScrollCell:OnClick()
	if self.data.activity_id == ACTIVITY_TYPE.GUILD_BOSS then
		ViewManager.Instance:Open(ViewName.GuildBoss)
		return
	end
	local post = GuildData.Instance:GetGuildPost()
	if self.data.activity_id == ACTIVITY_TYPE.GUILD_SHILIAN then
		local status = GuildData.Instance:GetMiJingState()
		if status == 1 then
			GuildMijingCtrl.SendGuildFbEnterReq()
		elseif status == 0 then
			if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
				GuildMijingCtrl.SendGuildFbStartReq()
			else
				SysMsgCtrl.Instance:ErrorRemind(Language.Guild.CallGuilMiJing)
			end
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.GuilMiJingFinish)
		end
		return
	end
	if self.data.activity_id == ACTIVITY_TYPE.GUILD_BONFIRE then
		local status = GuildData.Instance:GetBonFireState()
		if status == 1 then
			GuildBonfireCtrl.SendGuildBonfireGotoReq()
			ViewManager.Instance:Close(ViewName.Guild)
		elseif status == 0 then
			if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
				local scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
				if scene_key ~= 0 then
					local describe = Language.Guild.GoddessMustInLine1
					local yes_func = function() Scene.SendChangeSceneLineReq(0) end
					TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
				else
					GuildCtrl.Instance:SetBonFireOperation(true)
					GuildBonfireCtrl.SendGuildBonfireStartReq()
				end
			else
				SysMsgCtrl.Instance:ErrorRemind(Language.Guild.CallGuildNvShen)
			end
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.GuildNvShenFinish)
		end
		return
	end
	if self.data.activity_id then
		ActivityCtrl.Instance:ShowDetailView(self.data.activity_id)
	end
end

function GuildActivityScrollCell:SetToggleGroup(toggle_group)
	self.toggle.group = toggle_group
end