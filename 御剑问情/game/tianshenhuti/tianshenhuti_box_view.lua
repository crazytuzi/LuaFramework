--无双装备宝箱
TianshenhutiBoxView = TianshenhutiBoxView or BaseClass(BaseRender)

function TianshenhutiBoxView:__init()
	self.next_time = 0
	self.score_str = self:FindVariable("ScroeStr")
	self.gold_str = self:FindVariable("GoldStr")
	self.gold_five_str = self:FindVariable("Gold5Str")
	self.free_time = self:FindVariable("FreeTime")
	self.free_count = self:FindVariable("FreeCount")
	self.can_score_draw = self:FindVariable("CanScoreDraw")
	self.reward_times = self:FindVariable("reward_times")
	self.zhekou = self:FindVariable("zhekou")
	self.show_zhekou = self:FindVariable("show_zhekou")
	-- self. = self:FindObj("")
	self:ListenEvent("OnClickDraw1",BindTool.Bind(self.OnClickDraw, self, 1))
	self:ListenEvent("OnClickDraw2",BindTool.Bind(self.OnClickDraw, self, 2))
	self:ListenEvent("OnClickDraw3",BindTool.Bind(self.OnClickDraw, self, 3))
	self.item_list = {}
	self.list_view = self:FindObj("ListView")
	local scroller_delegate = self.list_view.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function TianshenhutiBoxView:__delete()
	if self.free_timer then
		GlobalTimerQuest:CancelQuest(self.free_timer)
		self.free_timer = nil
	end
	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
end

function TianshenhutiBoxView:OpenCallBack()
	self:Flush()
end

function TianshenhutiBoxView:OnClickDraw(index)
	TianshenhutiCtrl.SendTianshenhutiRoll(index)
end

function TianshenhutiBoxView:CloseCallBack()

end

function TianshenhutiBoxView:GetNumberOfCells()
	local cfg = TianshenhutiData.Instance:GetRewardItemCfg()
	return #cfg
end
function TianshenhutiBoxView:RefreshCell(cell, data_index)
	local cfg = TianshenhutiData.Instance:GetRewardItemCfg()
	data_index = data_index + 1
	local the_cell = self.item_list[cell]
	if nil ~= cfg then
		if the_cell == nil then
			the_cell = RewardBoxItem.New(cell.gameObject)
			self.item_list[cell] = the_cell
		end
		the_cell:SetIndex(data_index)
		the_cell:SetData(cfg[data_index])
	end
end
function TianshenhutiBoxView:OnFlush(param_t)
	self.list_view.scroller:ReloadData(0)
	local data = TianshenhutiData.Instance
	local other_cfg = ConfigManager.Instance:GetAutoConfig("tianshenhuti_auto").other[1]
	local need_store = other_cfg.common_roll_cost
	local week_number = tonumber(os.date("%w", TimeCtrl.Instance:GetServerTime()))
	local zhekou = TianshenhutiData.Instance:GetBoxZheKou()
	local cur_score = data:GetRollScore()
	local color = need_store > cur_score and "#ff0000" or "#00ff00"
	self.score_str:SetValue(string.format(Language.Tianshenhuti.LuckyDrawStr, color, cur_score, need_store))
	local super_roll_cost = other_cfg.super_roll_cost
	local batch_roll_cost = other_cfg.batch_roll_cost
	if 0 == week_number or 6 == week_number then
		super_roll_cost = math.ceil(super_roll_cost * (zhekou / 100))
		batch_roll_cost = math.ceil(batch_roll_cost * (zhekou / 100))
	end
	local gold = GameVoManager.Instance:GetMainRoleVo().gold
	color = super_roll_cost > gold and "#ff0000" or "#00ff00"
	self.gold_str:SetValue(string.format("<color=%s>%d</color>", color, super_roll_cost))
	color = batch_roll_cost > gold and "#ff0000" or "#00ff00"
	self.gold_five_str:SetValue(string.format("<color=%s>%d</color>", color, batch_roll_cost))

	local max_free_time = other_cfg.free_times
	local used_times = data:GetFreeTimes()
	local reward_times = data:GetRewardTimes()
	self.show_zhekou:SetValue(0 == week_number or 6 == week_number)
	self.zhekou:SetValue(zhekou / 10)
	self.next_time = data:GetNextFlushTime()
	local free_count = self.next_time > TimeCtrl.Instance:GetServerTime() and 0 or max_free_time - used_times
	self.free_count:SetValue(free_count)
	self.reward_times:SetValue(reward_times)
	self.can_score_draw:SetValue(free_count > 0 or cur_score >= need_store)
	if self.next_time > TimeCtrl.Instance:GetServerTime() and max_free_time - used_times > 0 then
		if self.free_timer == nil then
			self.free_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
			self:FlushNextTime()
		end
	else
		if self.free_timer then
			GlobalTimerQuest:CancelQuest(self.free_timer)
			self.free_timer = nil
		end
		self.free_time:SetValue("")
	end
end

function TianshenhutiBoxView:FlushNextTime()
	local time = self.next_time - TimeCtrl.Instance:GetServerTime()
	if time > 0 then
		if time > 3600 then
			self.free_time:SetValue(string.format(Language.Tianshenhuti.BoxFreeText, TimeUtil.FormatSecond(time, 1)))
		else
			self.free_time:SetValue(string.format(Language.Tianshenhuti.BoxFreeText, TimeUtil.FormatSecond(time, 2)))
		end
	else
		self:Flush()
	end
end
-------------------------------------------
RewardBoxItem = RewardBoxItem or BaseClass(BaseCell)
function RewardBoxItem:__init()
	self.accumulateTimes = self:FindVariable("AccumulateTimes")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("Item"))
end
function  RewardBoxItem:__delete()
	self.accumulateTimes = nil
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end
function RewardBoxItem:OnFlush()
	if nil == self.data then
		return
	end
	local reward_times = TianshenhutiData.Instance:GetRewardTimes()
	self.accumulateTimes:SetValue(self.data.accumulate_times)
	self.item_cell:SetData(self.data.reward_show[0])
	if reward_times >= self.data.accumulate_times then
		self.item_cell:ShowHaseGet(true)
	end
end