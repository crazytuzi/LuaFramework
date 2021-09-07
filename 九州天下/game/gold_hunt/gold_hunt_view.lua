GoldHuntView = GoldHuntView or BaseClass(BaseView)

function GoldHuntView:__init()
	self:SetMaskBg()
	self.ui_config = {"uis/views/goldhuntview","GoldHuntView"}
	self.full_screen = false
	self.play_audio = true
	self.timer_t = {}
end

function GoldHuntView:LoadCallBack()
	self.cell_list = {}
	self.list_view = self:FindObj("list_view")
	self.list_view_delegate = self.list_view.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self.item_cell_list = {}
	self.items_list_view = self:FindObj("items_list_view")
	self.items_list_view_delegate = self.items_list_view.list_simple_delegate
	self.items_list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetItemsNumberOfCells, self)
	self.items_list_view_delegate.CellRefreshDel = BindTool.Bind(self.ItemsRefreshView, self)

	self.ore_list = {}
	for i = 1, 8 do
		local ore_cell = GoldHuntOreCell.New(self:FindObj("ore_" .. i))
		ore_cell.parent = self
		ore_cell:SetIndex(i)
		table.insert(self.ore_list, ore_cell)
	end

	self.price_text = self:FindVariable("price_text")
	self.hunt_flush_time_text = self:FindVariable("hunt_flush_time_text")
	self.free_hunt_text = self:FindVariable("free_hunt_text")
	self.person_hunt_flush_text = self:FindVariable("all_hunt_flush_text")
	self.show_left_arrow = self:FindVariable("show_left_arrow")
	self.show_right_arrow = self:FindVariable("show_right_arrow")
	self.show_red_point = self:FindVariable("show_red_point")

	self:ListenEvent("left_arrow_click", BindTool.Bind(self.OnLeftClick, self))
	self:ListenEvent("right_arrow_click", BindTool.Bind(self.OnRightClick, self))
	self:ListenEvent("flush_click", BindTool.Bind(self.OnFlushClick, self))
	self:ListenEvent("exchange_click", BindTool.Bind(self.OnExchangeClick, self))
	self:ListenEvent("close_click", BindTool.Bind(self.OnCloseClick, self))
	self:ListenEvent("click_help", BindTool.Bind(self.ClickHelp, self))

	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))

	self.is_auto = false
end

function GoldHuntView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end

	for k,v in pairs(self.ore_list) do
		v:DeleteMe()
	end

	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end

	self:CancelCountDown()
	self.item_list = {}
	self.price_text = nil
	self.hunt_flush_time_text = nil
	self.free_hunt_text = nil
	self.person_hunt_flush_text = nil
	self.list_view = nil
	self.show_left_arrow = nil
	self.show_right_arrow = nil
	self.items_list_view = nil
	self.list_view_delegate = nil
	self.show_red_point = nil
	self.items_list_view_delegate = nil

	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end
end

function GoldHuntView:OpenCallBack()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_MINE)
	if is_open then
		GoldHuntCtrl.SendRandActivityOperaReq(GoldHuntData.GOLD_HUNT_ID, GOLD_HUNT_OPERA_TYPE.OPERA_TYPE_QUERY_INFO)
	end

	-- for k,v in pairs(self.ore_list) do
	-- 	self:PetMove(k, v)
	-- end

	self.cur_index = 1
	self:Flush("items_flush")
end

function GoldHuntView:CloseCallBack()
	for k,v in pairs(self.timer_t) do
		GlobalTimerQuest:CancelQuest(v)
	end
	self.timer_t = {}
	for k,v in pairs(self.ore_list) do
		v:SetMove(false)
	end
	TipsCommonAutoView.AUTO_VIEW_STR_T["Hunt"] = nil
end

local speed = 0.08
function GoldHuntView:PetMove(index, cell)
	if self.timer_t[index] then return end
	local gold_hunt_info = GoldHuntData.Instance:GetHuntInfo()
	local time = nil
	if gold_hunt_info.mine_cur_type_list and gold_hunt_info.mine_cur_type_list[index] ~= 0 and math.random(10) == 1 then
		local pos = cell.root_node.transform.position
		local rand_x = 0
		local rand_y = 0

		for i = 55, 2, -1 do
			rand_x = math.random(i * 2) - i
			if pos.x + rand_x <= 73 and pos.x + rand_x >= -37 then
				break
			end
		end
		for i = 13, 2, -1 do
			rand_y = math.random(i * 2) - i
			if pos.y + rand_y <= 27 and pos.y + rand_y >= -9 then
				break
			end
		end

		local off_x, off_y = pos.x + rand_x, pos.y + rand_y
		local dis = math.sqrt(rand_x * rand_x + rand_y * rand_y)
		time = dis * speed
		cell:SetMove(true)
		cell:SetRotation(off_x > pos.x and 0 or 180)
		local tween = cell.root_node.transform:DOMove(Vector3(off_x, off_y, pos.z), time)
		tween:SetEase(DG.Tweening.Ease.Linear)

	end
	self.timer_t[index] = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.MoveCompare, self, index, cell), time or 2)

end

function GoldHuntView:MoveCompare(index, cell)
	self.timer_t[index] = nil
	cell:SetMove(false)
	self:PetMove(index, cell)
end


function GoldHuntView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "items_flush" then
			self:FlushArrow()
			self:FlushHuntText()
			self:FlushAllHl()
		elseif k == "flush_all_hl" then
			self:FlushAllHl()
		else
			self:FlushHuntInfo()
			self:FlushOreList()
			self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
		end
	end
end

function GoldHuntView:GetNumberOfCells()
	return GoldHuntData.Instance:GetRewardCfgCount()
end

function GoldHuntView:RefreshView(cell, data_index)
	data_index = data_index + 1
	local the_cell = self.cell_list[cell]
	if the_cell == nil then
		the_cell = GoldHuntCell.New(cell.gameObject)
		the_cell.root_node.toggle.group = self.list_view.toggle_group
		the_cell.parent = self
		self.cell_list[cell] = the_cell
	end
	the_cell:SetIndex(data_index)
	the_cell:SetData(GoldHuntData.Instance:GetRewardCfgList()[data_index].reward_item)
end

--物品格子list_view
function GoldHuntView:GetItemsNumberOfCells()
	return math.ceil(GoldHuntData.Instance:GetHuntInfoCfgCount()/2)
end

function GoldHuntView:ItemsRefreshView(cell, data_index)
	data_index = data_index + 1
	local the_cell = self.item_cell_list[cell]
	if the_cell == nil then
		the_cell = GoldHuntItemCell.New(cell.gameObject)
		the_cell.parent = self
		self.item_cell_list[cell] = the_cell
	end
	the_cell:SetIndex(data_index)
	the_cell:SetData(CommonDataManager.GetCellIndexList(data_index, 2, 2))
end

function GoldHuntView:GetCurListViewIndex()
	local position = self.list_view.scroller.ScrollPosition
	return self.list_view.scroller:GetCellViewIndexAtPosition(position)
end

function GoldHuntView:OnLeftClick()
	local jump_index = 0
	local scrollerOffset = 0
	local cellOffset = 0
	local useSpacing = false
	local scrollerTweenType = self.items_list_view.scroller.snapTweenType
	local scrollerTweenTime = 0.2
	local scroll_complete = nil
	self.items_list_view.scroller:JumpToDataIndexForce(
		jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
end

function GoldHuntView:OnRightClick()
	local jump_index = 1
	local scrollerOffset = 0
	local cellOffset = 0
	local useSpacing = false
	local scrollerTweenType = self.items_list_view.scroller.snapTweenType
	local scrollerTweenTime = 0.2
	local scroll_complete = nil
	self.items_list_view.scroller:JumpToDataIndexForce(
		jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
end

function GoldHuntView:OnFlushClick()
	local flush_price = GoldHuntData.Instance:GetFlushPrice()
	local vo_money = GameVoManager.Instance:GetMainRoleVo().gold
	if vo_money >= flush_price then
		function call_back(is_auto)
			self.is_auto = is_auto
			TipsCtrl.Instance:ChangeAutoViewAuto(is_auto)
			if not is_auto then
				TipsCommonAutoView.AUTO_VIEW_STR_T["FlushHunt"] = nil
			else
				TipsCommonAutoView.AUTO_VIEW_STR_T["FlushHunt"] = {is_auto_buy = is_auto}
			end

			GoldHuntCtrl.SendRandActivityOperaReq(GoldHuntData.GOLD_HUNT_ID, GOLD_HUNT_OPERA_TYPE.OPERA_REFRESH)
		end

		function confirm()
			TipsCtrl.Instance:ChangeAutoViewAuto(self.is_auto)
			GlobalTimerQuest:AddDelayTimer(function ()
					local describe = string.format(Language.Common.FlushGoldHunt, flush_price)
					TipsCommonAutoView.AUTO_VIEW_STR_T["FlushHunt"] = nil
					TipsCtrl.Instance:ShowCommonAutoView("FlushHunt", describe, call_back, nil, nil, nil, nil, nil, true, nil)
			end, 0)
			-- TipsCommonAutoView.AUTO_VIEW_STR_T["FlushHunt"] = nil
			-- TipsCtrl.Instance:ShowCommonAutoView("FlushHunt", describe, call_back, nil, nil, nil, nil, nil, true, nil)
		end
		local has_rare = false
		local mine_info = GoldHuntData.Instance:GetHuntInfo().mine_cur_type_list
		for k,v in pairs(mine_info) do
			if v >= 15 then
				has_rare = true
				break
			end
		end
		if has_rare then
			TipsCommonAutoView.AUTO_VIEW_STR_T[""] = nil
			TipsCtrl.Instance:ShowCommonAutoView("", Language.Common.FlushTip, confirm, nil, nil, nil, nil, nil, true, nil)
		else
			confirm()
		end
	else
		TipsCtrl.Instance:ShowLackDiamondView()
	end
end

function GoldHuntView:OnExchangeClick()
	ViewManager.Instance:Open(ViewName.GoldHuntExchangeView)
end

function GoldHuntView:FlushArrow()
	-- self.show_left_arrow:SetValue(self.cur_index ~= 1)
	-- self.show_right_arrow:SetValue(self.cur_index ~= GoldHuntData.Instance:GetRewardCfgCount())
end

function GoldHuntView:OnCloseClick()
	self:Close()
end

function GoldHuntView:ClickHelp()
	local tips_id = 224
    TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function GoldHuntView:SetCurIndex(cur_index)
	self.cur_index = cur_index
end

function GoldHuntView:GetCurIndex()
	return self.cur_index
end

--刷新猎场信息
function GoldHuntView:FlushHuntInfo()
	local gold_hunt_data = GoldHuntData.Instance
	local hunt_info = gold_hunt_data:GetHuntInfo()
	if not next(hunt_info) then
		return
	end

	local server_time = TimeCtrl.Instance:GetServerTime()
	local time_diff = hunt_info.next_refresh_time - server_time
	local time_table = TimeUtil.Timediff(hunt_info.next_refresh_time, server_time)
	local str = string.format("%02d:%02d:%02d", time_table.hour, time_table.min, time_table.sec)
	self.hunt_flush_time_text:SetValue(str)
	self.free_hunt_text:SetValue(hunt_info.free_gather_times .."/".. gold_hunt_data:GetMaxFreeHuntCountCfg())
	self.person_hunt_flush_text:SetValue(hunt_info.role_refresh_times + hunt_info.lover_refresh_times)
	self.price_text:SetValue(gold_hunt_data:GetFlushPrice())

	self:CancelCountDown()
	self.count_down = CountDown.Instance:AddCountDown(time_diff, 1, BindTool.Bind(self.CountDown, self))

	self.show_red_point:SetValue(gold_hunt_data:CanExchange())
end

function GoldHuntView:FlushHuntText()
	local gold_hunt_data = GoldHuntData.Instance
	local hunt_info = gold_hunt_data:GetHuntInfo()
	if not next(hunt_info) then
		return
	end

	self.free_hunt_text:SetValue(hunt_info.free_gather_times .."/".. gold_hunt_data:GetMaxFreeHuntCountCfg())
	self.person_hunt_flush_text:SetValue(hunt_info.role_refresh_times + hunt_info.lover_refresh_times)
end

function GoldHuntView:CountDown(elapse_time, total_time)
	local gold_hunt_data = GoldHuntData.Instance
	local hunt_info = gold_hunt_data:GetHuntInfo()
	local gold_hunt_data = GoldHuntData.Instance
	if not next(hunt_info) then
		return
	end

	local time_table = TimeUtil.Timediff(hunt_info.next_refresh_time, server_time)
	local str = TimeUtil.FormatSecond(total_time - elapse_time)
	-- local str = string.format("%02d:%02d:%02d", time_table.hour, time_table.min, time_table.sec)
	self.hunt_flush_time_text:SetValue(str)
	if elapse_time >= total_time then
		self:CancelCountDown()
	end
end

function GoldHuntView:CancelCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function GoldHuntView:FlushAllHl()

end

function GoldHuntView:FlushOreList()
	for i = 1, 8 do
		self.ore_list[i]:Flush()
	end
end
-------------------------------------------------------------------------
GoldHuntCell = GoldHuntCell or BaseClass(BaseCell)

function GoldHuntCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item"))
	self.vip_text = self:FindVariable("vip_text")
	self.arrive_reward_count = self:FindVariable("arrive_reward_count")
	self.show_point = self:FindVariable("show_point")
	self.show_gray =  self:FindVariable("show_gray")
	self:ListenEvent("item_cell_click", BindTool.Bind(self.OnItemClick, self))
end

function GoldHuntCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil 
	end
	self.parent = nil
	self.show_point = nil
	self.show_gray = nil
	self.vip_text = nil
	self.arrive_reward_count = nil
end

function GoldHuntCell:OnItemClick(is_click)
	if is_click then
		self.parent:SetCurIndex(self.index)
		self.parent:Flush("items_flush")
		self.parent:Flush("flush_all_hl")
	end
	local reward_cfg = GoldHuntData.Instance:GetRewardCfgList()[self.index]
	local seq = reward_cfg.seq
	GoldHuntCtrl.SendRandActivityOperaReq(GoldHuntData.GOLD_HUNT_ID, GOLD_HUNT_OPERA_TYPE.OPERA_FETCH_SERVER_REWARD, seq)
end

function GoldHuntCell:OnFlush()
	local reward_cfg = GoldHuntData.Instance:GetRewardCfgList()[self.index]
	self.item_cell:SetData(self.data)
	self.vip_text:SetValue(reward_cfg.mine_server_reward_vip_limit)
	self.arrive_reward_count:SetValue(reward_cfg.total_refresh_times)
	self.show_point:SetValue(GoldHuntData.Instance:GetIsCanRewardFlag(self.index - 1))
	self.show_gray:SetValue(1 == GoldHuntData.Instance:GetFetchRewardFlag(self.index - 1))
end

-------------------------------------------------------------------------
GoldHuntOreCell = GoldHuntOreCell or BaseClass(BaseCell)

function GoldHuntOreCell:__init()
	self.show_kuangshi = self:FindVariable("show_kuangshi")
	self.model_img = self:FindVariable("modle_img")
	self.name = self:FindVariable("name")
	self.show_bubble = self:FindVariable("show_bubble")
	self.model = self:FindObj("Model")
	self.img_index = 0
	self.is_move = false
	self.count_flag = 0
	self:ListenEvent("click_kuangshi", BindTool.Bind(self.OnClickKuangShi, self))
end

function GoldHuntOreCell:__delete()
	self.parent = nil
	self.name = nil
	self:CancelQuest()
	self.show_kuangshi = nil
	self.show_bubble = nil
	self.model_img = nil
end

function GoldHuntOreCell:OnClickKuangShi()
	local gold_hunt_data = GoldHuntData.Instance
	local gather_index = gold_hunt_data:GetHuntInfo().mine_cur_type_list[self.index]
	if gather_index == 0 then
		return
	end

	local free_time = gold_hunt_data:GetHuntInfo().free_gather_times
	function call_back()
		GoldHuntCtrl.SendRandActivityOperaReq(GoldHuntData.GOLD_HUNT_ID, GOLD_HUNT_OPERA_TYPE.OPERA_GATHER, self.index - 1)
	end
	if free_time > 0 then
		call_back()
	else
		local gather_index = GoldHuntData.Instance:GetHuntInfo().mine_cur_type_list[self.index] - 10  -- 服务器说要减10后才是真正的猎场类型
		-- local info_cfg = GoldHuntData.Instance:GetActivityCfg().mine_info
		-- local show_type = info_cfg[gather_index].type
		local price = gold_hunt_data:GetHuntPrice(gather_index)
		local describe = string.format(Language.Common.ToGoldHunt, price)
		TipsCtrl.Instance:ShowCommonAutoView("Hunt", describe, call_back, nil, nil, nil, nil, nil, true, nil)
	end
end

function GoldHuntOreCell:OnFlush()
	local gold_hunt_data = GoldHuntData.Instance
	local gather_index = gold_hunt_data:GetHuntInfo().mine_cur_type_list[self.index]
	self.root_node:SetActive(gather_index ~= 0)
	if gather_index == 0 then
		self:CancelQuest()
		self.show_kuangshi:SetValue(false)
	else
		local gather_index = gold_hunt_data:GetHuntInfo().mine_cur_type_list[self.index] - 10  -- 服务器说要减10后才是真正的猎场类型

		local name = gold_hunt_data:GetMineralInfo(gather_index)
		local color = gather_index >=5 and TEXT_COLOR.ORANGE or TEXT_COLOR.WHITE
		name = ToColorStr(name, color)
		self.name:SetValue(name)
		-- self.show_bubble:SetValue(gather_index >=5)
		self.show_bubble:SetValue(GoldHuntData.Instance:GetIsShowTip(gather_index))
		if self.timer_quest == nil then
			self.img_index = self:GetNextImgIndex(gold_hunt_data:GetHuntInfo().mine_cur_type_list)
			if gather_index >= 0 then
				self.show_kuangshi:SetValue(true)
				-- local info_cfg = gold_hunt_data:GetActivityCfg().mine_info
				-- local show_type = info_cfg[gather_index].type
				local is_move = self.is_move and "_m_" or "_"
				local asset, name = ResPath.GetGoldHuntModelImg("hunt_img_" .. gather_index + 1 .. is_move .. self.img_index, gather_index + 1)
				self.model_img:SetAsset(asset, name)
			end
			self:StartQuest()
		else
			local is_move = self.is_move and "_m_" or "_"
			local asset, name = ResPath.GetGoldHuntModelImg("hunt_img_" .. gather_index + 1 .. is_move .. self.img_index, gather_index + 1)
			self.model_img:SetAsset(asset, name)
		end
		local scale = gold_hunt_data:GetHuntScale(gather_index)
		self.model.transform.localScale = Vector3(scale, scale, scale)
	end
end

function GoldHuntOreCell:SetMove(value)
	if self.is_move ~= value then
		self.is_move = value
		self.img_index = 0
		self:OnFlush()
	end
end

function GoldHuntOreCell:SetRotation(value)
	if self.model then
		self.model.transform.localRotation = Quaternion.Euler(0, value, 0)
	end
end

function GoldHuntOreCell:StartQuest()
	self.timer_quest = GlobalTimerQuest:AddRunQuest(function()
		self.count_flag = self.count_flag == 0 and 1 or 0
		self.img_index = self:GetNextImgIndex(GoldHuntData.Instance:GetHuntInfo().mine_cur_type_list)
		local gather_index = GoldHuntData.Instance:GetHuntInfo().mine_cur_type_list[self.index] - 10  -- 服务器说要减10后才是真正的猎场类型
		if gather_index >= 0 and (self.is_move or self.count_flag == 1) then
			self.show_kuangshi:SetValue(true)
			local is_move = self.is_move and "_m_" or "_"
			local asset, name = ResPath.GetGoldHuntModelImg("hunt_img_" .. gather_index + 1 .. is_move .. self.img_index, gather_index + 1)
			self.model_img:SetAsset(asset, name)
		end
	end, 0.1)
end

function GoldHuntOreCell:CancelQuest()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function GoldHuntOreCell:GetNextImgIndex()
	if self.img_index == 8 then
		self.img_index = 0
	end
	return self.img_index + 1
end

-------------------------------------------------------------------------
GoldHuntItemCell = GoldHuntItemCell or BaseClass(BaseCell)

function GoldHuntItemCell:__init()
	self.item_list = {}
	self.show_item_list = {}
	for i=1,2 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self:FindObj("item"..i))
		table.insert(self.item_list, item_cell)
		self.show_item_list[i] = self:FindVariable("show_item"..i)
	end
end

function GoldHuntItemCell:__delete()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	self.parent = nil
	self.show_item_list = {}
end

function GoldHuntItemCell:OnFlush()
	local gold_hunt_data = GoldHuntData.Instance
	local info_cfg = gold_hunt_data:GetHuntInfoCfg()
	if not info_cfg then return end
	for i=1,2 do
		local data = gold_hunt_data:GetExchangeShowItems(self.data[i])
		self.item_list[i]:ShowQuality(data ~= nil)
		if data and next(data) then
			self.item_list[i]:SetData(data)
		end
	end
end
