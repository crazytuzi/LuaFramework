RuneTreasureView = RuneTreasureView or BaseClass(BaseRender)

local COLUMN = 4
function RuneTreasureView:__init()
	self.other_cfg = RuneData.Instance:GetOtherCfg()
	self.free_count_down = nil

	self.list_data = {}
	self.cell_list = {}
	self.list_view = self:FindObj("ListView")
	local scroller_delegate = self.list_view.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCellNumber, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.CellRefresh, self)

	self.free_time = self:FindVariable("FreeTime")
	self.one_cost = self:FindVariable("OneCost")
	self.ten_cost = self:FindVariable("TenCost")
	self.is_free = self:FindVariable("IsFree")
	self.show_shuijing_des = self:FindVariable("ShowShuiJingDes")
	self.shuijing_num = self:FindVariable("ShuiJingNum")
	self.suipian_num = self:FindVariable("SuiPianNum")

	self:ListenEvent("OpenBag", BindTool.Bind(self.OpenBag, self))
	self:ListenEvent("OpenExchange", BindTool.Bind(self.OpenExchange, self))
	self:ListenEvent("TreasureOne", BindTool.Bind(self.TreasureOne, self))
	self:ListenEvent("TreasureTen", BindTool.Bind(self.TreasureTen, self))
	self.rune_fetch_cfg = RuneData.Instance:RuneFetchCfg()
end

function RuneTreasureView:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self:StopCountDown()
end

function RuneTreasureView:InitView()
	GlobalTimerQuest:AddDelayTimer(function()

		local open_list = RuneData.Instance:GetTreasureShowList()
		self.open_num = RuneData.Instance:GetTreasureOpenNum()

		local new_list_data = {}
		local quality = 0
		local types = 0
		local base_data = {}
		for k,v in pairs(open_list) do
			quality, types = RuneData.Instance:GetQualityTypeByItemId(v.rune_id)
			base_data = RuneData.Instance:GetAttrInfo(quality, types, 1)
			table.insert(new_list_data,
			{
				item_id = v.rune_id,
				in_layer_open = v.in_layer_open,
				quality = base_data.quality,
				type = base_data.types,
				level = base_data.level,
				attr_type_0 = base_data.attr_type_0,
				add_attributes_0 = base_data.add_attributes_0,
				attr_type_1 = base_data.attr_type_1,
				add_attributes_1 = base_data.add_attributes_1,
				power = base_data.power,
				dispose_fetch_jinghua = base_data.dispose_fetch_jinghua,
			})
		end
		self.list_data = new_list_data
		self.list_view.scroller:ReloadData(0)
		self:FlushView()
	end, 0)
end

function RuneTreasureView:FlushView()
	local pass_layer = RuneData.Instance:GetPassLayer()
	local need_pass_layer = self.other_cfg.rune_compose_need_layer
	self.show_shuijing_des:SetValue(pass_layer >= need_pass_layer)

	local rune_suipian_num_low = self.other_cfg.rune_suipian_num_low
	local rune_suipian_num_high = self.other_cfg.rune_suipian_num_high
	local suipian_des = rune_suipian_num_low .. "-" .. rune_suipian_num_high
	self.suipian_num:SetValue(suipian_des)

	self.shuijing_num:SetValue(self.other_cfg.xunbao_one_magic_crystal)
--符文铭刻抽奖字体颜色
--单抽
	local have_num = ItemData.Instance:GetItemNumInBagById(self.other_cfg.xunbao_consume_itemid)
	local one_consume_num = self.other_cfg.xunbao_one_consume_num
	local one_color = "#0000f1"
	if have_num < one_consume_num then
		one_color = TEXT_COLOR.RED_3
	end
	local str = string.format(Language.Rune.TreasureOneCost, one_color, have_num,one_consume_num)
	--local str = ToColorStr(have_num .. "/" .. one_consume_num, one_color)
	self.one_cost:SetValue(str)
--十连
	local ten_consume_num = self.other_cfg.xunbao_ten_consume_num
	local ten_color = "#0000f1"
	if have_num < ten_consume_num then
		ten_color = TEXT_COLOR.RED_3
	end
	str = string.format(Language.Rune.TreasureOneCost, ten_color, have_num,ten_consume_num)
	--str = ToColorStr(have_num .. "/" .. ten_consume_num, ten_color)
	self.ten_cost:SetValue(str)

	self:StarCountDown()
end

function RuneTreasureView:StopCountDown()
	if self.free_count_down then
		CountDown.Instance:RemoveCountDown(self.free_count_down)
		self.free_count_down = nil
	end
end

function RuneTreasureView:StarCountDown()
	self:StopCountDown()
	local next_free_xunbao_timestamp = RuneData.Instance:GetNextFreeXunBaoTimestamp()
	local server_time = TimeCtrl.Instance:GetServerTime()
	local diff_time = next_free_xunbao_timestamp - server_time
	local function timer_func(elapse_time, total_time)
		if elapse_time >= total_time then
			self:StopCountDown()
			self.free_time:SetValue("")
			return
		end
		local temp_diff_time = math.ceil(total_time - elapse_time)
		local time_str = TimeUtil.FormatSecond(temp_diff_time, 8)
		time_str = string.format(Language.Rune.FreeDes, time_str)
		self.free_time:SetValue(time_str)
	end
	if diff_time > 0 then
		diff_time = math.ceil(diff_time)
		self.free_count_down = CountDown.Instance:AddCountDown(diff_time, 1, timer_func)
		local time_str = TimeUtil.FormatSecond(diff_time, 8)
		time_str = string.format(Language.Rune.FreeDes, time_str)
		self.free_time:SetValue(time_str)
		self.is_free:SetValue(false)
	else
		self.is_free:SetValue(true)
		self.free_time:SetValue("")
	end
end

function RuneTreasureView:OpenBag()
	ViewManager.Instance:Open(ViewName.RuneBag)
end

function RuneTreasureView:OpenExchange()
	ViewManager.Instance:Open(ViewName.Rune, TabIndex.rune_exchange)
end

function RuneTreasureView:TreasureOne()
	if RuneData.Instance:GetFreeTimes() > 0 then
		RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_XUNBAO_ONE)
		return
	end
	local item_id = self.other_cfg.xunbao_consume_itemid
	local one_consume_num = self.other_cfg.xunbao_one_consume_num
	local num = ItemData.Instance:GetItemNumInBagById(item_id)
	if num >= one_consume_num then
		--物品充足
		RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_XUNBAO_ONE)
	else
		--物品不足
		local shop_data = ShopData.Instance:GetShopItemCfg(item_id)
		if not shop_data then
			return
		end
		local function ok_callback()
			RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_XUNBAO_ONE, 1)
		end
		local differ_num = one_consume_num - num
		local item_cfg = ItemData.Instance:GetItemConfig(item_id) or {}
		local color = item_cfg.color or 1
		local color_str = ITEM_COLOR[color]
		local name = item_cfg.name or ""
		local cost = shop_data.gold * differ_num
		local des = string.format(Language.Rune.NotEnoughDes, color_str, name, cost)
		TipsCtrl.Instance:ShowCommonAutoView("rune_one_xunbao", des, ok_callback)
	end
end

function RuneTreasureView:TreasureTen()
	local item_id = self.other_cfg.xunbao_consume_itemid
	local ten_consume_num = self.other_cfg.xunbao_ten_consume_num
	local num = ItemData.Instance:GetItemNumInBagById(item_id)
	if num >= ten_consume_num then
		--物品充足
		RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_XUNBAO_TEN)
	else
		--物品不足
		local shop_data = ShopData.Instance:GetShopItemCfg(item_id)
		if not shop_data then
			return
		end
		local function ok_callback()
			RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_XUNBAO_TEN, 1)
		end
		local differ_num = ten_consume_num - num
		local item_cfg = ItemData.Instance:GetItemConfig(item_id) or {}
		local color = item_cfg.color or 1
		local color_str = ITEM_COLOR[color]
		local name = item_cfg.name or ""
		local cost = shop_data.gold * differ_num
		local des = string.format(Language.Rune.NotEnoughDes, color_str, name, cost)
		TipsCtrl.Instance:ShowCommonAutoView("rune_ten_xunbao", des, ok_callback)
	end
end

function RuneTreasureView:GetCellNumber()
	return math.ceil(#self.list_data/COLUMN)
end

function RuneTreasureView:CellRefresh(cell, data_index)
	local group_cell = self.cell_list[cell]
	if nil == group_cell then
		group_cell = RuneAnalyzeGroupCell.New(cell.gameObject)
		group_cell:SetGrayCount(self.open_num)
		group_cell:SetIsAnalyze(false)
		self.cell_list[cell] = group_cell
	end

	for i = 1, COLUMN do
		local index = (data_index)*COLUMN + i
		group_cell:SetIndex(i, index)
		local data = self.list_data[index]
		group_cell:SetData(i, data)
		group_cell:SetActive(i, data ~= nil)
		group_cell:SetClickCallBack(i, BindTool.Bind(self.ItemCellClick, self))
	end
end

function RuneTreasureView:ItemCellClick(cell)
	local data = cell:GetData()
	if not data or not next(data) then
		return
	end

	local function callback()
		if not cell:IsNil() then
			cell:SetToggleHighLight(false)
		end
	end
	RuneCtrl.Instance:SetTipsData(data)
	RuneCtrl.Instance:SetTipsCallBack(callback)
	ViewManager.Instance:Open(ViewName.RuneItemTips)
end