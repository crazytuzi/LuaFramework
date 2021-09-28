GuildActivityView = GuildActivityView or BaseClass(BaseRender)

function GuildActivityView:__init(instance)
	if instance == nil then
		return
	end

	self.cur_page = 1
	self.scroller = self:FindObj("Scroller")
	self.scroller_rect = self:FindObj("ScrollerRect"):GetComponent(typeof(UnityEngine.UI.ScrollRect))
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
	self.scroller.page_view:JumpToIndex(0)
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
 --    if self.scroller.scroller.isActiveAndEnabled then
	-- 	self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	-- end
end

function GuildActivityView:SelectCell(cell, ani_speed)
	local speed = ani_speed or -1
	self.activity_id = cell.data.activity_id
	if cell.play_introduction then
		self.des:SetValue(cell.play_introduction)
		self.scroller_rect.normalizedPosition = Vector2(1, 1)
	end
	if cell.item_cell then
		for i = 1, 3 do
			if cell.item_cell[i] and cell.item_cell[i].item_id > 0 then
				self.item_cell[i].cell:SetData(cell.item_cell[i])
				self.item_cell[i].obj:SetActive(true)
			else
				self.item_cell[i].cell:SetData()
				self.item_cell[i].obj:SetActive(false)
			end
		end
	end
	self.scroller.page_view:JumpToIndex(cell.data.data_index, 0, speed)
end

function GuildActivityView:InitScroller()
	self.page_delegate = self.scroller.page_simple_delegate
	self.page_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.page_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
	self.scroller.scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChanged, self))
	self.scroller.page_view:Reload(function ()
		for k,v in pairs(self.cell_list) do
			if v.data.data_index == 0 then
				self:SelectCell(v)
				v:SetIsSelect(true)
			end
		end
	end)
	-- self.SelectCell(self.cell_list)
end

function GuildActivityView:GetNumberOfCells()
	if self.activity_config then
		return #self.activity_config
	end
	return 0
end

function GuildActivityView:RefreshView(data_index, cell)
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = GuildActivityScrollCell.New(cell.gameObject)
		group_cell:SetHandle(self)
		self.cell_list[cell] = group_cell
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

function GuildActivityView:OnValueChanged()
	local page = self.scroller.page_view.ActiveCellsMiddleIndex + 1
	if self.cur_page ~= page then
		self.cur_page = page
		for k, v in pairs(self.cell_list) do
			v:SetIsSelect((v.data.data_index + 1) == self.cur_page)
		end
		self:Flush()
	end
end
function GuildActivityView:FlushCellData()
	for k,v in pairs(self.cell_list) do
		v:Flush()
	end
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
	self.is_select = self:FindVariable("IsSeleted")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	-- self.gray = self:FindVariable("Gray")
	-- self.toggle = self:FindObj("Toggle").toggle
	self:ListenEvent("OnClick",
		BindTool.Bind(self.OnClick, self))
	self:ListenEvent("OnClickDetails",
		BindTool.Bind(self.OnClickDetails, self))
	self.show_red_point:SetValue(false)
end

function GuildActivityScrollCell:__delete()

end

function GuildActivityScrollCell:SetData(data)
	self.data = data
	if self.data ~= nil then
		self:OnFlush()
	end
end

function GuildActivityScrollCell:OnFlush()
	local asset_bundle, name = ResPath.GetGuildActivtyBg(self.data.activity_id)
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
			local lv = PlayerData.GetLevelString(tonumber(config.min_level))
			self.level:SetValue(lv)
			if ActivityData.Instance:GetActivityIsInToday(self.data.activity_id) then
				local time = math.abs(TimeUtil.GetTimeStr(config.open_time) - TimeUtil.GetTimeStr(config.end_time)) % 3600 * 24
				if time ~= 0 then
					self.time:SetValue(ToColorStr(config.open_time .. " - " .. config.end_time, TEXT_COLOR.WHITE))
				else
					self.time:SetValue(ToColorStr(Language.Common.AllDayOpen, TEXT_COLOR.WHITE))
				end
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
					self.time:SetValue(ToColorStr(str, TEXT_COLOR.WHITE))
				end
			end
			self.play_introduction = config.play_introduction
			self.item_cell = {config.reward_item1, config.reward_item2, config.reward_item3}
		end
		if not ActivityData.Instance:GetActivityIsOpen(self.data.activity_id) and
			(ActivityData.Instance:GetActivityIsOver(self.data.activity_id) or
			not ActivityData.Instance:GetActivityIsInToday(self.data.activity_id)) then
			-- self.gray:SetValue(true)
		else
			-- self.gray:SetValue(false)
		end
	end
	-- 暂定，后续优化为红点传递模式
	self.show_red_point:SetValue(false)
	if self.data.activity_id == ACTIVITY_TYPE.GUILD_BOSS then
		local feed_id = GuildData.Instance:GetBossFeedItemId()
		local number = 0
		if feed_id then
			number = ItemData.Instance:GetItemNumInBagById(feed_id)
		end
		local boss_info = GuildData.Instance:GetBossInfo()
		if number > 0 and boss_info.boss_normal_call_count <= 0 then
			self.show_red_point:SetValue(true)
		end
	end

	if self.handle then
		-- if self.handle.activity_id == self.data.activity_id then
		-- 	self.toggle.isOn = true
		-- else
		-- 	self.toggle.isOn = false
		-- end
		if self.handle.show_red_point_list[self.data.activity_id] then
			self.show_red_point:SetValue(true)
		end
	end
end

function GuildActivityScrollCell:OnClickDetails()
	if self.handle then
		self.handle:SelectCell(self, 3)
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

	if self.data.activity_id == ACTIVITY_TYPE.GUILD_MONEYTREE then
		ActivityCtrl.Instance:ShowDetailView(self.data.activity_id)
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
				local scene_id = Scene.Instance:GetSceneId()
				if scene_id ~= 103 then
					local describe = Language.Guild.GoddessMustInLine2
					local yes_func = function()
						Scene.SendChangeSceneLineReq(0)
						GuajiCtrl.Instance:MoveToScene(103)
					end
					TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
				elseif scene_key ~= 0 then
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

function GuildActivityScrollCell:SetIsSelect(bool)
	self.is_select:SetValue(bool)
end