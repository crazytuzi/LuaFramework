RareTreasureRewardView = RareTreasureRewardView or BaseClass(BaseView)
local ONCE_NUMBER = 9						-- 一轮数量
function RareTreasureRewardView:__init()
	self.ui_config = {"uis/views/serveractivity/raretreasure", "RewardView"}
	self:SetMaskBg()
	self.reward_seq = -1
	self.word_cell = {}
	self.last_word = nil
end

function RareTreasureRewardView:ReleaseCallBack()
	self.last_word = nil
	self.page_view = nil
	for k,v in pairs(self.word_cell) do
		v:DeleteMe()
	end
	self.word_cell = {}
	self.reward_seq = -1
	Runner.Instance:RemoveRunObj(self)
end

function RareTreasureRewardView:LoadCallBack()
	self:ListenEvent("CloseView", BindTool.Bind(self.Close, self))
	self.page_view = self:FindObj("PageView")
	local page_view_delegate = self.page_view.page_simple_delegate
	page_view_delegate.NumberOfCellsDel = BindTool.Bind(self.WordGetNumberOfCells, self)
	page_view_delegate.CellRefreshDel = BindTool.Bind(self.WordRefreshCell, self)
	self.page_view.list_view:Reload()
	self.cur_index = -1
	self.last_refresh_time = 0
end

function RareTreasureRewardView:OpenCallBack()
	self.reward_seq = -1
	GlobalTimerQuest:AddDelayTimer(function()
		self:TestAnimation()
		end,1)
end

function RareTreasureRewardView:CloseCallBack()
	Runner.Instance:RemoveRunObj(self)
end

---- 中间9个字
function RareTreasureRewardView:WordGetNumberOfCells()
	return #RareTreasureData.Instance:GetWordAllConfig()
end

function RareTreasureRewardView:WordRefreshCell(index, cellObj)
	local cell = self.word_cell[cellObj]
	local cell_data = RareTreasureData.Instance:GetWordConfigBySeq(index)
	if nil == cell then
		cell = RareWordItem.New(cellObj)
		cell:ClearClick()
		self.word_cell[cellObj] = cell
	end
	cell:SetIndex(index)
	cell:SetData(cell_data)
end

--[[
	国家搬砖/刺探的算法
]]
function RareTreasureRewardView:TestAnimation()
	self.interval = 0.1 						 --最后一轮每次增加的时间
	self.run_number = 0 						 --计算最后一轮
	self.test_num = 0 							 --目标次数
	self.total_num = 0 							 --执行总次数
	local cur_seq = RareTreasureData.Instance:GetCurRewardWord()
	if cur_seq == -1 then return end
	self.cur_color = cur_seq + 1 				 --目标位置

	for k,v in pairs(self.word_cell) do
		v:SetEffectHL(false)
	end

	self.test_num = ONCE_NUMBER * 4 + self.cur_color

	GlobalTimerQuest:CancelQuest(self.timer_quest)
	function diff_time_func(elapse_time, total_time)
		self.cur_index = self.cur_index + 1
		self.total_num = self.total_num + 1

		if self.last_word then
			self.last_word:SetEffectHL(false)
		end

		if self.cur_index >= ONCE_NUMBER then
			self.cur_index = 0
		end

		for k,v in pairs(self.word_cell) do
			local word_index = v:GetIndex()
			if word_index == self.cur_index then
				v:SetEffectHL(true)
				self.last_word = v
			end
		end

		if self.total_num >= self.test_num then
			self.timer_quest = GlobalTimerQuest:AddDelayTimer(function()
				Runner.Instance:AddRunObj(self, 8)
				self:RemoveCountDown()
			end,0.1)
		end

		if elapse_time >= total_time then
			self:RemoveCountDown()
		end
	end

	self:RemoveCountDown()
	self.count_down = CountDown.Instance:AddCountDown(10, 0.1, diff_time_func)
end


function RareTreasureRewardView:Update()
	if Status.NowTime - self.interval < self.last_refresh_time then
		return
	end
	self.last_refresh_time = Status.NowTime
	self.interval = self.interval + 0.1

	self.cur_index = self.cur_index + 1
	self.run_number = self.run_number + 1 

	if self.last_word then
		self.last_word:SetEffectHL(false)
	end

	if self.cur_index >= ONCE_NUMBER then
		self.cur_index = 0
	end

	for k,v in pairs(self.word_cell) do
		local word_index = v:GetIndex()
		if word_index == self.cur_index then
			v:SetEffectHL(true)
			self.last_word = v
		end
	end

	if self.run_number >= ONCE_NUMBER then
		Runner.Instance:RemoveRunObj(self)
	end
end

function RareTreasureRewardView:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end