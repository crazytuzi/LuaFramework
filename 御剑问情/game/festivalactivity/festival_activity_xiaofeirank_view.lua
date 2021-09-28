FestivalXiaoFeiRankView = FestivalXiaoFeiRankView or BaseClass(BaseRender)

function FestivalXiaoFeiRankView:__init()
	self.model_panel_names = {
		[DISPLAY_TYPE.MOUNT] = "festival_rank_mount_panel",
		[DISPLAY_TYPE.WING] = "festival_rank_wing_panel",
		[DISPLAY_TYPE.FOOTPRINT] = "festival_rank_foot_panel",
		[DISPLAY_TYPE.FASHION] = "festival_rank_fashion_panel",
		[DISPLAY_TYPE.HALO] = "festival_rank_fashion_panel",
		[DISPLAY_TYPE.SPIRIT] = "festival_rank_spirit_panel",
		[DISPLAY_TYPE.FIGHT_MOUNT] = "festival_rank_fight_mount_panel",
		[DISPLAY_TYPE.SHENGONG] = "festival_rank_xiannv_panel",
		[DISPLAY_TYPE.SHENYI] = "festival_rank_xiannv_panel",
		[DISPLAY_TYPE.XIAN_NV] = "festival_rank_xiannv_panel",
		[DISPLAY_TYPE.ZHIBAO] = "festival_rank_zhibao_panel",
		[DISPLAY_TYPE.SPIRIT_FAZHEN] = "festival_rank_xiannv_panel",
	}
	self.specical_id = {
		[22518] = "festival_rank_fight_mount_panel_1",
		[24024] = "festival_rank_mount_panel_1",
		[24015] = "festival_rank_mount_panel_2",
	}
	self.display = self:FindObj("DisPlay")
	self.list_view = self:FindObj("ListView")
	self.my_rank = self:FindVariable("my_rank")
	self.cost_money = self:FindVariable("cost_money")
	self.model_name = self:FindVariable("model_name")
	self.flush_time = self:FindVariable("time")
	self.power = self:FindVariable("power")

	self:ListenEvent("GoShopping", BindTool.Bind(self.GoShopping,self))

	self.model = RoleModel.New("festival_rank_fashion_panel")
	self.model:SetDisplay(self.display.ui3d_display)

	self.cell_list = {}
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.data_listen = BindTool.Bind(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
end

function FestivalXiaoFeiRankView:__delete()
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	if self.least_time_timer then
	    CountDown.Instance:RemoveCountDown(self.least_time_timer)
	    self.least_time_timer = nil
	end

	self.display = nil
	self.listview = nil
	self.my_rank = nil
	self.cost_money = nil
	self.model_name = nil
	self.flush_time = nil
	self.power = nil

	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end

	self.cell_list = {}

	if nil ~= self.model then
		self.model:DeleteMe()
		self.model = nil
	end
end

function FestivalXiaoFeiRankView:OpenCallBack()
	RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_CONSUME_GOLD_RANK_2)
	self:Flush()
end

function FestivalXiaoFeiRankView:GoShopping()
	ViewManager.Instance:Open(ViewName.Shop)
end

function FestivalXiaoFeiRankView:GetNumberOfCells()
	local num = #(FestivalActivityData.Instance:GetXiaoFeiRewardCfg()) or 0
	return num
end

function FestivalXiaoFeiRankView:RefreshCell(cell, cell_index)
	local rank_cell = self.cell_list[cell]
	if nil == rank_cell then
		rank_cell = FestivalXiaoFeiRankCell.New(cell.gameObject)
		self.cell_list[cell] = rank_cell
	end

	local index = cell_index + 1
	local item_id_group = FestivalActivityData.Instance:GetXiaoFeiRewardCfg()
	local data = item_id_group[index]
	rank_cell:SetIndex(index)
	rank_cell:SetData(data)
end

function FestivalXiaoFeiRankView:OnFlush()
	self:FlushTime()
	self.list_view.scroller:ReloadData(0)
	local cfg = FestivalActivityData.Instance:GetXiaoFeiRewardCfg() or {}
	local model_id = 0
	if cfg[1] then
		model_id = cfg[1].figure_id or 0
	end

	ItemData.ChangeModel(self.model, model_id)
	local item_cfg = ItemData.Instance:GetItemConfig(model_id)
	if item_cfg == nil then
		return
	end

	if self.specical_id[model_id] then
		self.model:SetPanelName(self.specical_id[model_id])
	else
		self.model:SetPanelName(self.model_panel_names[item_cfg.is_display_role] or self.model_panel_names[DISPLAY_TYPE.FASHION])
	end

	self.model_name:SetValue(item_cfg.name)
	local power = ItemData.GetFightPower(item_cfg.id)
	self.power:SetValue(power)
	local cost_money = FestivalActivityData.Instance:GetXiaoFeiRankInfo() or 0
	local rank = FestivalActivityData.Instance:GetXiaoFeiRank() or 0
	self.cost_money:SetValue(cost_money)

	if rank > 0 then
		self.my_rank:SetValue(rank)
	else
		self.my_rank:SetValue(Language.Competition.NotOnTheList)
	end
end

function FestivalXiaoFeiRankView:FlushTime()
	local info = FestivalActivityData.Instance:GetActivityOpenListByActId(FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_XIAOFEI_RANK)

	if nil == info or nil == next(info) or nil == info.time_data or nil == info.time_data.end_time then
		return
	end

	local end_time = info.time_data.end_time
	local svr_time = TimeCtrl.Instance:GetServerTime()
	local rest_time = math.floor(end_time - svr_time)

	if self.least_time_timer then
	    CountDown.Instance:RemoveCountDown(self.least_time_timer)
	    self.least_time_timer = nil
	end

	if rest_time > 0 then
		self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function (elapse_time, total_time)
			local left_time = total_time - elapse_time

			if left_time <= 0 then
				left_time = 0
				if self.least_time_timer then
	    			CountDown.Instance:RemoveCountDown(self.least_time_timer)
	    			self.least_time_timer = nil
	   			end

	   			self.flush_time:SetValue("")
	   		else
				local time = TimeUtil.FormatSecond(left_time, 7)
		        self.flush_time:SetValue(string.format(Language.Activity.FestivalActivityShowTime, time))

		    end
	    end)
	end
end

function FestivalXiaoFeiRankView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "gold" then
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_CONSUME_GOLD_RANK_2)
	end
end

--------Cell-------
FestivalXiaoFeiRankCell = FestivalXiaoFeiRankCell or BaseClass(BaseCell)
function FestivalXiaoFeiRankCell:__init()
	self.rank = self:FindVariable("rank")
	self.cost = self:FindVariable("cost")

	for i = 1, 3 do
		self["item_" .. i] = self:FindObj("item_" .. i)
	end

	for i = 1, 3 do
		self["item_cell_" .. i] = ItemCell.New()
		self["item_cell_" .. i]:SetInstanceParent(self["item_" .. i])
		self["item_cell_" .. i]:ShowHighLight(false)
	end

end

function FestivalXiaoFeiRankCell:__delete()
	for i = 1, 3 do
		if self["item_cell_" .. i] then
			self["item_cell_" .. i]:DeleteMe()
		end
	end
end

function FestivalXiaoFeiRankCell:OnFlush()
	if nil == self.data or nil == next(self.data) then
		return
	end

	local cost_money = FestivalActivityData.Instance:GetXiaoFeiRankInfo() or 0
	-- local money = cost_money .. "/" .. (self.data.limit_comsume or 0)
	local money = self.data.limit_comsume or 0
	self.rank:SetValue(self.data.need_rank or 0)
	self.cost:SetValue(money)
	for i = 1, 3 do
		if self.data.reward_item and self.data.reward_item[i - 1] then
			self["item_cell_" .. i]:SetData(self.data.reward_item[i - 1])
			self["item_cell_" .. i]:SetShowRedPoint(false)
		else
			self["item_" .. i]:SetActive(false)
		end
	end
end