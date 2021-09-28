require('game/puzzle/puzzle_item_render')

PuzzleView = PuzzleView or BaseClass(BaseView)
local MAX_PUZZLE = 80

local function ExchangeSortList(exchange_num, index)
	return function(a, b)
		local order_a = 100000
		local order_b = 100000
		if a[exchange_num] > b[exchange_num] then
			order_a = order_a + 1000
		elseif a[exchange_num] < b[exchange_num] then
			order_b = order_b + 1000
		else
			if a[index] < b[index] then
				order_a = order_a + 1000
			elseif a[index] > b[index] then
				order_b = order_b + 1000
			end
		end

		return order_a > order_b
	end
end

function PuzzleView:__init()
	self.ui_config = {"uis/views/randomact/puzzle_prefab","PuzzleView"}
	self.play_audio = true

	self.puzzle_cell = {}
	self.exchange_cell = {}
	self.reward_cell = {}
	self.exchange_data = {}
	self.puzzle_data_list = {}
	self.select_index = nil
end

function PuzzleView:__delete()

end

function PuzzleView:ReleaseCallBack()
	for k,v in pairs(self.puzzle_cell) do
		v:DeleteMe()
	end
	self.puzzle_cell = {}
	for k,v in pairs(self.exchange_cell) do
		v:DeleteMe()
	end
	self.exchange_cell = {}
	for k,v in pairs(self.reward_cell) do
		v:DeleteMe()
	end
	self.reward_cell = {}

	if self.puzzle_left_time then
		CountDown.Instance:RemoveCountDown(self.puzzle_left_time)
		self.puzzle_left_time = nil
	end
	if self.puzzle_reset_time then
		CountDown.Instance:RemoveCountDown(self.puzzle_reset_time)
		self.puzzle_reset_time = nil
	end
	self.flip_panel = nil
	self.exchange_scroll = nil
	self.act_time = nil
	self.turn_one_need = nil
	self.restar_need = nil
	self.restar_btn_enble = nil
	self.auto_btn_enble = nil
	self.free_times = nil
	self.restart_time = nil
	self.turn_times = nil
	self.is_start_fast_flip = nil
end

-------------------回调---------------------
function PuzzleView:LoadCallBack()
	self.act_time = self:FindVariable("ActTime")
	self.turn_one_need = self:FindVariable("TurnOneNeed")
	self.restar_need = self:FindVariable("RestartNeed")
	self.restar_btn_enble = self:FindVariable("RestartBtnEnble")
	self.auto_btn_enble = self:FindVariable("AutoBtnEnble")
	self.free_times = self:FindVariable("FreeTimes")
	self.restart_time = self:FindVariable("RestartTime")
	self.turn_times = self:FindVariable("TurnTimes")
	self.is_start_fast_flip = self:FindVariable("IsStartFastFlip")

	-- 创建抽奖网格
	do
		self.flip_panel = self:FindObj("PuzzleList")
		local list_delegate = self.flip_panel.page_simple_delegate
		list_delegate.NumberOfCellsDel = BindTool.Bind(self.PuzzleGetNumberOfCells, self)
		list_delegate.CellRefreshDel = BindTool.Bind(self.PuzzleRefreshCell, self)
		self.flip_panel.list_view:JumpToIndex(0)
		self.flip_panel.list_view:Reload()
	end

	-- 创建兑换显示列表
	self:InitExchangeList()

	-- 创建保底显示列表
	do
		self.reward_cell = {}
		for i=1, 5 do
			GameObjectPool.Instance:SpawnAsset("uis/views/randomact/puzzle_prefab","PuzzleRewardItem", function(obj)
				if nil == obj then
					return
				end
				obj.transform:SetParent(self:FindObj("Reward" .. i).transform, false)
				local cell = PuzzleBaoDiItemRender.New(obj)
				cell:ShowHighLight(false)
				self.reward_cell[i] = cell
				if #self.reward_cell == 5 then
					self:FlushBaodiRender()
				end
			end)
		end
	end

	-- 注册事件
	self:RegisterAllEvents()
end

-- 注册所有所需事件
function PuzzleView:RegisterAllEvents()
	self:ListenEvent("Close",BindTool.Bind(self.Close, self))
	self:ListenEvent("ClickRestart",BindTool.Bind(self.OnClickBtnReset, self))
	self:ListenEvent("ClickAutoTurn",BindTool.Bind(self.OnClickBtnAutoFlip, self))
	self:ListenEvent("ClickHelp",BindTool.Bind(self.OnClickBtnDescTip, self))
	self:ListenEvent("ClickStore",BindTool.Bind(self.OnClickBtnCangKu, self))
	self:ListenEvent("ClickFastFlip", BindTool.Bind(self.ClickOpenFastFlipView, self))
end

function PuzzleView:OpenCallBack()
	PuzzleCtrl.Instance:SendReq()
	self:FlushFastFlipButtonText()
end

function PuzzleView:CloseCallBack()
	TipsCtrl.Instance:ChangeAutoViewAuto(false)
	TipsCommonAutoView.AUTO_VIEW_STR_T.puzzle_turn = nil
	self.select_index = nil
	PuzzleCtrl.Instance:CacleSendDelayTime()
	PuzzleCtrl.Instance:ClearData()
end

function PuzzleView:PuzzleGetNumberOfCells()
	return MAX_PUZZLE
end

function PuzzleView:PuzzleRefreshCell(index, cellObj)
	-- 构造Cell对象.

	local grid_index = math.floor(index / 8) * 8 + (8 - index % 8)
	local cell = self.puzzle_cell[grid_index]
	if nil == cell then
		cell = PuzzleFlipCellItemRender.New(cellObj)
		self.puzzle_cell[grid_index] = cell
	end
	-- 获取数据信息
	local data = self.puzzle_data_list[grid_index] or {}
	cell:SetIndex(grid_index)
	cell:SetData(data)
	cell:ShowHighLight(false)
	cell:ListenEvent("OnClick", BindTool.Bind(self.OnClickPuzzleFlipCellItemRender, self, cell))
	if self.select_index and (type(self.select_index) == "table" or grid_index == self.select_index) then
		cell:RunFilpAnim()
		if type(self.select_index) == "table" then
			table.insert(self.select_index, 1)
			if #self.select_index == MAX_PUZZLE then
				self.select_index = nil
			end
		else
			self.select_index = nil
		end
	end
end

function PuzzleView:OnClickPuzzleFlipCellItemRender(item)
	if item.data == nil or item.data.seq_type ~= 0 then return end
	local freetime = PuzzleData.Instance:GetCurFreeFlipTimes()
	
	local puzzle_gold = 20
	if freetime <= 0 then
		local str = string.format(Language.Puzzle.FlipNotice, puzzle_gold)
		TipsCtrl.Instance:ShowCommonAutoView("puzzle_turn", str, BindTool.Bind(self.FlipTheCell, self, item), nil, nil, nil, nil, nil, true)
	else
		self:FlipTheCell(item)
	end
end

-- 翻牌
function PuzzleView:FlipTheCell(view)
	self.select_index = view.index
	PuzzleCtrl.Instance:SendReq(RA_FANFAN_OPERA_TYPE.RA_FANFAN_OPERA_TYPE_FAN_ONCE, view.index - 1)
end

function PuzzleView:InitExchangeList()
	self.exchange_scroll = self:FindObj("ExchangeList")
	local delegate = self.exchange_scroll.list_simple_delegate
	-- 生成数量
	self.exchange_data = {}
	for i=0, PuzzleData.Instance:GetWrodInfoCount() - 1 do
		table.insert(self.exchange_data, {index = i, exchange_num = PuzzleData.Instance:GetWrodExchangeNum(i) or 0})
	end
	table.sort(self.exchange_data, ExchangeSortList("exchange_num", "index"))
	PuzzleData.Instance:SetWordList(self.exchange_data)
	delegate.NumberOfCellsDel = function()
		return #self.exchange_data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.exchange_cell[cell]

		if nil == target_cell then
			self.exchange_cell[cell] =  RewardExchangeItemRender.New(cell.gameObject)
			target_cell = self.exchange_cell[cell]
			target_cell:SetToggleGroup(self.exchange_scroll.toggle_group)
		end
		target_cell:SetData(self.exchange_data[data_index])
		target_cell:ShowHighLight(false)
	end
end

-- 按下一键翻牌按钮事件
function PuzzleView:OnClickBtnAutoFlip()
	local price = 0
	for k,v in pairs(self.puzzle_cell) do
		if not v.is_front then price = price + PuzzleData.Instance:GetFlipConsume() end
	end
	price = math.max(0, price - PuzzleData.Instance:GetCurFreeFlipTimes() * PuzzleData.Instance:GetFlipConsume())
	local str = string.format(Language.Puzzle.AutoFlipNotice, price)
	TipsCtrl.Instance:ShowCommonAutoView("show_puzzle_auto_buy1", str, BindTool.Bind1(self.OnAutoFlip, self), nil, nil, nil, nil, nil, true, true)
end

-- 按下重置按钮事件
function PuzzleView:OnClickBtnReset()
	if PuzzleData.Instance:CanFanZhuan() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Puzzle.NeedClickToResert)
		return
	end

	local str = string.format(Language.Puzzle.ResetNotice, PuzzleData.Instance:GetResetConsume())
	TipsCtrl.Instance:ShowCommonAutoView("show_puzzle_auto_buy2", str, BindTool.Bind1(self.OnResetAllCell, self), nil, nil, nil, nil, nil, true, true)
end

-- 按下规则描述按钮事件
function PuzzleView:OnClickBtnDescTip()
	TipsCtrl.Instance:ShowHelpTipView(227)
end

function PuzzleView:OnClickBtnCangKu()
	ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_warehouse)
end

-- 一键翻牌
function PuzzleView:OnAutoFlip()
	self.select_index = {}
	PuzzleCtrl.Instance:SendReq(RA_FANFAN_OPERA_TYPE.RA_FANFAN_OPERA_TYPE_FAN_ALL, 1)
end

-- 重置翻牌
function PuzzleView:OnResetAllCell()
	self.select_index = {}
	PuzzleCtrl.Instance:SendReq(RA_FANFAN_OPERA_TYPE.RA_FANFAN_OPERA_TYPE_REFRESH, 1, -1)

end

-- 一键寻字
function PuzzleView:ClickOpenFastFlipView()
	local state = PuzzleData.Instance:GetFastFilpState()
	local flip_state = PuzzleData.Instance:GetFilpState()
	if not state and not flip_state then
		PuzzleCtrl.Instance:OpenFastFlipView()
	else
		PuzzleCtrl.Instance:EndFastFilp()
	end
end

function PuzzleView:FlushFastFlipButtonText()
	local state = PuzzleData.Instance:GetFastFilpState()
	self.is_start_fast_flip:SetValue(state)
end

function PuzzleView:SetSelectIndex()
	self.select_index = {}
end

-------------------行为---------------------

-- 刷新
function PuzzleView:OnFlush()
	self:FlushFlipPanel()
	self:FlushExchangeView()

	self:FlushMainInfo()
	self:FlushBaodiRender()
end

-- 刷新主面板面板
function PuzzleView:FlushMainInfo()
	local info_baodi_total = PuzzleData.Instance:GetBaodiTotal()
	self.turn_times:SetValue(info_baodi_total or 0)
	self.turn_one_need:SetValue(PuzzleData.Instance:GetFlipConsume())
	self.restar_need:SetValue(PuzzleData.Instance:GetResetConsume())
	local cur_has_time = ToColorStr(PuzzleData.Instance:GetCurFreeFlipTimes(), TEXT_COLOR.YELLOW)
	local all_free_time = PuzzleData.Instance:GetAllFreeFlipTimes()
	self.free_times:SetValue(cur_has_time .. " / " .. all_free_time)

	local act_cornucopia_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FANFAN) or {}
	if self.puzzle_left_time then
		CountDown.Instance:RemoveCountDown(self.puzzle_left_time)
	end
	if act_cornucopia_info and act_cornucopia_info.status == ACTIVITY_STATUS.OPEN then
		local next_time = act_cornucopia_info.next_time or 0
		self:UpdataRollerTime(TimeCtrl.Instance:GetServerTime(), next_time)
		self.puzzle_left_time = CountDown.Instance:AddCountDown(next_time, 1, BindTool.Bind1(self.UpdataRollerTime, self), BindTool.Bind1(self.CompleteRollerTime, self))
	else
		self:CompleteRollerTime()
	end

	local mul_time = PuzzleData.Instance:GetNextResetTime() - TimeCtrl.Instance:GetServerTime()
	if mul_time > 0 then
		if self.puzzle_reset_time then
			CountDown.Instance:RemoveCountDown(self.puzzle_reset_time)
		end

		self.restart_time:SetValue(TimeUtil.FormatSecond2HMS(mul_time))

		self.puzzle_reset_time = CountDown.Instance:AddCountDown(PuzzleData.Instance:GetNextResetTime(), 1, function(elapse_time, total_time)
			if total_time - TimeCtrl.Instance:GetServerTime() > 0 then
				self.restart_time:SetValue(TimeUtil.FormatSecond2HMS(total_time - TimeCtrl.Instance:GetServerTime()))
			end
		end,
		function() self.restart_time:SetValue(TimeUtil.FormatSecond2HMS(0)) end)
	else
		self.restart_time:SetValue(TimeUtil.FormatSecond2HMS(0))
	end
end

-- 刷新翻转面板
function PuzzleView:FlushFlipPanel()
	self.puzzle_data_list = {}
	local is_flip_all = true
	for i=0, GameEnum.RA_FANFAN_CARD_COUNT - 1 do
		local seq_type, info = PuzzleData.Instance:GetFlipCell(i)
		local data = {}
		data.seq_type = seq_type
		data.info = info
		self.puzzle_data_list[i + 1] = data

		if seq_type == 0 then is_flip_all = false end
	end

	if is_flip_all then
		self.auto_btn_enble:SetValue(false)
	else
		self.auto_btn_enble:SetValue(true)
	end
	for k,v in pairs(self.puzzle_cell) do
		if v.data == nil or v.data.seq_type ~= self.puzzle_data_list[k].seq_type then
			v:SetData(self.puzzle_data_list[k])
			if self.select_index and (type(self.select_index) == "table" or k == self.select_index) then
				v:RunFilpAnim()
				if type(self.select_index) == "table" then
					table.insert(self.select_index, 1)
					if #self.select_index == MAX_PUZZLE then
						self.select_index = nil
					end
				else
					self.select_index = nil
				end
			end
		end
	end
end

-- 刷新兑换列表
function PuzzleView:FlushExchangeView()
	self.exchange_data = {}
	for i=0, PuzzleData.Instance:GetWrodInfoCount() - 1 do
		table.insert(self.exchange_data, {index = i, exchange_num = PuzzleData.Instance:GetWrodExchangeNum(i) or 0})
	end
	table.sort(self.exchange_data, ExchangeSortList("exchange_num", "index"))
	if self.exchange_scroll.scroller.isActiveAndEnabled then
		self.exchange_scroll.scroller:RefreshAndReloadActiveCellViews(true)
	end
	PuzzleData.Instance:SetWordList(self.exchange_data)
end

function PuzzleView:FlushBaodiRender()
	if #self.reward_cell < 5 then return end
	for k,v in pairs(self.reward_cell) do
		v:SetData(PuzzleData.Instance:GetBaoDiListCfg()[k])
	end
end


function PuzzleView:UpdataRollerTime(elapse_time, next_time)
	local time = next_time - TimeCtrl.Instance:GetServerTime()
	if time > 0 then
		local format_time = TimeUtil.Format2TableDHMS(time)
		local str_list = Language.Common.TimeList
		local time_str = ""
		if format_time.day > 0 then
			time_str = format_time.day .. str_list.d
		end
		if format_time.hour > 0 then
			time_str = time_str .. format_time.hour .. str_list.h
		end
		if format_time.min > 0 then
			time_str = time_str .. format_time.min .. str_list.min
		end
		if format_time.s > 0 then
			time_str = time_str .. format_time.s .. str_list.s
		end

		self.act_time:SetValue(time_str)
	end
end

function PuzzleView:CompleteRollerTime()
	self.act_time:SetValue("00:00:00")
end