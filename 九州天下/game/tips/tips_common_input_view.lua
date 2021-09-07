TipsCommonInputView = TipsCommonInputView or BaseClass(BaseView)

function TipsCommonInputView:__init()
	self.ui_config = {"uis/views/tips/commontips", "InputNumTip"}
	self.view_layer = UiLayer.Pop
	self:SetMaskBg(true)
	self.ok_callback = nil
	self.cancel_callback = nil

	self.max_num = 999
	self.play_audio = true
	self.cell_list = {}
	self.is_bet_content = false	

	self.rank_data = nil
end

function TipsCommonInputView:LoadCallBack()
	self:ListenEvent("OnClickYes",BindTool.Bind(self.OnClickYes, self))
	self:ListenEvent("OnClickClose",BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickClean",BindTool.Bind(self.OnClickClean, self))
	self:ListenEvent("OnClickMax",BindTool.Bind(self.OnClickMaxNum, self))
	self:ListenEvent("OnClickZero",BindTool.Bind(self.OnClickNum, self, 0))
	self:ListenEvent("OnClickOne",BindTool.Bind(self.OnClickNum, self, 1))
	self:ListenEvent("OnClickTwo",BindTool.Bind(self.OnClickNum, self, 2))
	self:ListenEvent("OnClickThree",BindTool.Bind(self.OnClickNum, self, 3))
	self:ListenEvent("OnClickFour",BindTool.Bind(self.OnClickNum, self, 4))
	self:ListenEvent("OnClickFive",BindTool.Bind(self.OnClickNum, self, 5))
	self:ListenEvent("OnClickSix",BindTool.Bind(self.OnClickNum, self, 6))
	self:ListenEvent("OnClickSeven",BindTool.Bind(self.OnClickNum, self, 7))
	self:ListenEvent("OnClickEight",BindTool.Bind(self.OnClickNum, self, 8))
	self:ListenEvent("OnClickNight",BindTool.Bind(self.OnClickNum, self, 9))
	self:ListenEvent("OnClickTouZhu",BindTool.Bind(self.OnClickTouZhu, self))

	self.isbetcontent = self:FindVariable("isbetcontent")
	self.present_bet_num = self:FindVariable("present_bet_num")
	self.all_bet_num = self:FindVariable("all_bet_num")
	self.ranking = self:FindVariable("ranking")
	self.my_name = self:FindVariable("name")
	self.me_bet_num = self:FindVariable("me_bet_num")
	self.distance_open_time = self:FindVariable("distance_open_time")	

	self.input_flied = self:FindObj("InputField")
	self.list_view = self:FindObj("listview")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self:ClearTimer()	
end

function TipsCommonInputView:ReleaseCallBack()
	-- 清理变量和对象
	self.input_flied = nil
	self.isbetcontent = nil
	self.present_bet_num = nil
	self.all_bet_num = nil
	self.ranking = nil
	self.my_name = nil
	self.me_bet_num = nil
	self.distance_open_time	= nil
	self.list_view = nil
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end	

	self.is_bet_content = false
end

function TipsCommonInputView:__delete()
	self.cur_str = nil
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}	
end

function TipsCommonInputView:CloseCallBack()
	self.max_num = 999
	self.max_len = nil
	self.cur_str = ""
	self.ok_callback = nil
	self.cancel_callback = nil

	self.rank_data = nil
end

function TipsCommonInputView:OpenCallBack()
	if self.rank_data == nil then return end 
	TallPriceLotteryCtrl.Instance:SendLotteryInfo(1, self.rank_data.param_1 - 1)
end

function TipsCommonInputView:SetCallback(ok_callback, cancel_callback)
	self.ok_callback = ok_callback
	self.cancel_callback = cancel_callback
end

function TipsCommonInputView:OnClickYes()
	if self.ok_callback ~= nil then
		if self.cur_str == "" then
			self.cur_str = 0
		end
		self.ok_callback(self.cur_str)
	end
	if self.cancel_callback ~= nil then
		self.cancel_callback()
	end
	self:Close()
end

function TipsCommonInputView:OnClickTouZhu()
	local function ok_callback()
		if self.rank_data ~= nil and next(self.rank_data) ~= nil then
			TallPriceLotteryCtrl.Instance:SendLotteryInfo(2, self.rank_data.param_1 - 1 or 0, self.input_flied.input_field.text or 0)
		end
		self:Close()	
	end
	local all_bet_num = TallPriceLotteryData.Instance:GetBetNum()
	local str = string.format(Language.LotteryBet.AutoViewText, self.input_flied.input_field.text)
	if tonumber(self.input_flied.input_field.text) >= 1 then
		TipsCtrl.Instance:ShowCommonAutoView("", str, ok_callback, nil, nil, nil, nil, nil, nil)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.LotteryBet.ErrorCodeText)
	end
end

function TipsCommonInputView:OnClickClose()
	if self.cancel_callback ~= nil then
		self.cancel_callback()
	end
	self:Close()
end

function TipsCommonInputView:OnClickClean()
	if self.cur_str == "" or self.cur_str == nil or self.cur_str == 0 then
		self.cur_str = 0
		return
	end
	local str = string.sub(self.cur_str, 1, -2)
	self.input_flied.input_field.text = str
	self.cur_str = str
end

function TipsCommonInputView:OnClickMaxNum()
	self.input_flied.input_field.text = self.max_num
	self.cur_str = self.max_num
end

function TipsCommonInputView:SetText(str, max_num)
	if str and str ~= "" then
		self.cur_str = tostring(str)
	elseif str == "" and max_num then
		self.cur_str = tostring(max_num)
	else
		self.cur_str = ""
	end

	self.max_num = max_num or self.max_num

	self:Open()
	self:Flush()
end

function TipsCommonInputView:SetMaxLen(max_len)
	self.max_len = max_len
end

function TipsCommonInputView:OnClickNum(index)
	local str = self.input_flied.input_field.text
	if tonumber(str) == 0 and index == 0 then
		self.input_flied.input_field.text = 0
		self.cur_str = 0
		return
	end

	if string.len(str) == 1 then
		local s = string.sub(str, 1, -1)
		if tonumber(s) == 0 then
			str = string.sub(str, -1, 0)
		end
	end

	str = str .. index
	if self.max_len then
		if string.len(str) > self.max_len then
			str = string.sub(str, 1, self.max_len)
		end
	end

	if tonumber(str) >= self.max_num and not self.max_len then
		self.input_flied.input_field.text = tostring(self.max_num)
		self.cur_str = tostring(self.max_num)
		return
	end

	self.input_flied.input_field.text = str
	self.cur_str = str
end

function TipsCommonInputView:OnFlush(param_t)	
	self.input_flied.input_field.text = self.cur_str
	self.init_str = self.input_flied.input_field.text	
	self:FlushRankData()
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:ReloadData(0)
	end	
	self.isbetcontent:SetValue(self.is_bet_content)

	if self.is_bet_content and self.timer_quest == nil then
		self.timer_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind2(self.ResidueTime, self), 1)
	elseif not self.is_bet_content then
		if self.timer_quest ~= nil then
			GlobalTimerQuest:CancelQuest(self.timer_quest)
			self.timer_quest = nil
		end
	end	
end

function TipsCommonInputView:GetNumberOfCells()
	return TallPriceLotteryData.Instance:GetReturnNoZeroBetNum() or 0
end

function TipsCommonInputView:RefreshCell(cell, data_index)
	data_index = data_index + 1	
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = BetInfoItemCell.New(cell.gameObject)
		self.cell_list[cell] = group_cell
	end
	local data = {}
	data.present = data_index
	data.role_id = self.rank_role_id[data_index] or 0	
	data.bet = self.rank_bet_num[data_index]
	group_cell:SetData(data)
end

function TipsCommonInputView:FlushRankData()
	if self.rank_data == nil or next(self.rank_data) == nil then
		return
	end
	local name = PlayerData.Instance:GetRoleVo().name
	local my_rank = TallPriceLotteryData.Instance:GetRankMyRank() + 1 
	local rank_value = TallPriceLotteryData.Instance:GetRankMyBetNum()
	self.my_name:SetValue(name)
	if my_rank > 10 then
		self.ranking:SetValue(Language.Rank.NoRank)
	else
		self.ranking:SetValue(my_rank)
	end
	self.me_bet_num:SetValue(rank_value)
	self.rank_role_id = TallPriceLotteryData.Instance:GetRankRoleId()
	self.rank_bet_num = TallPriceLotteryData.Instance:GetRankBetNum()	

	local reward_seq = TallPriceLotteryData.Instance:GetRewardSeq()
	local get_reward_cfg = TallPriceLotteryData.Instance:GetLotteryRewardLotteryCfg(reward_seq[self.rank_data.param_1])	
	local present_bet_num_list = TallPriceLotteryData.Instance:GetRankBetNum()	
	local all_present_bet_num = 0
	for i, v in ipairs(present_bet_num_list) do
		all_present_bet_num = all_present_bet_num + v
	end
	self.present_bet_num:SetValue(all_present_bet_num)
	self.all_bet_num:SetValue(get_reward_cfg.most_votes)
end

function TipsCommonInputView:ResidueTime()
	local info_residue_open_time = TallPriceLotteryData.Instance:GetResidueOpenTime()
	local cur_time = TimeCtrl.Instance:GetServerTime()
	local residue_open_time	= info_residue_open_time - cur_time
	self.distance_open_time:SetValue(TimeUtil.FormatSecond(residue_open_time))
end

function TipsCommonInputView:ClearTimer()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function TipsCommonInputView:SetRankData(rank_data)
	if self.isbetcontent ~= nil then
		self.isbetcontent:SetValue(not (rank_data == nil or next(rank_data) == nil))
	end
	self.rank_data = rank_data
end

function TipsCommonInputView:IsBetContent(is_bool)
	self.is_bet_content = is_bool or false
end

BetInfoItemCell = BetInfoItemCell or BaseClass(BaseCell)

function BetInfoItemCell:__init()
	self.present = self:FindVariable("present")
	self.name = self:FindVariable("name")
	self.bet = self:FindVariable("bet")

	self.role_info_callback = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.RoleInfoCallBack, self))
end

function BetInfoItemCell:__delete()
	if self.role_info_callback then
		GlobalEventSystem:UnBind(self.role_info_callback)
		self.role_info_callback = nil
	end
end

function BetInfoItemCell:OnFlush()
	if self.data == nil then return end
	self.present:SetValue(self.data.present or 0)
	self.bet:SetValue(self.data.bet or 0)	
	CheckCtrl.Instance:SendQueryRoleInfoReq(self.data.role_id)
end

function BetInfoItemCell:RoleInfoCallBack(uid, info)
	if uid == self.data.role_id then
		self.name:SetValue(info.role_name or "")
	end
end