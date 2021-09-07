MoonGiftView = MoonGiftView or BaseClass(BaseView)

function MoonGiftView:__init()
	self.ui_config = {"uis/views/moongiftview","MoonGiftView"}
	self.play_audio = true
	self:SetMaskBg()
end

function MoonGiftView:_delete()

end

function MoonGiftView:LoadCallBack()
	self.need_chongzhi_value = self:FindVariable("NeedChongzhiValue")
	self.lianxu_value = self:FindVariable("LianXuValue")
	self.is_show_right = self:FindVariable("IsShowRight")
	self.slider_value = self:FindVariable("SliderValue")
	self.res_time = self:FindVariable("ResTime")

	self.chongzhi_lable = {}
	self.is_had_receieve = {}
	self.lianchong_red = {}
	self.chongzhi_btn = {}
	self.continue_item = {}
	self.btn_flag = {}
	self.receive_flag = {}
	for i = 1, 2 do
		self.btn_flag[i] = 1 	--1,前往充值 2，可领取 3，已领取
		self.receive_flag[i] = 1	-- 领取标记
		self.chongzhi_lable[i] = self:FindVariable("ChongZhiLable" .. i)
		self.is_had_receieve[i] = self:FindVariable("IsHadRec" .. i)
		self.lianchong_red[i] = self:FindVariable("LianChongRed" .. i)
		self.chongzhi_btn[i] = self:FindObj("ChongZhiBtn" .. i)

		self.continue_item[i] = ItemCell.New()
		self.continue_item[i]:SetInstanceParent(self:FindObj("LItem" .. i))
	end

	self.item_list = {}
	for i = 1, 4 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("Item" .. i))
	end

	self.select_index = 1
	self.select_lianxu_index = 1
	self.reward_cell_list = {}
	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self:ListenEvent("CloseView", BindTool.Bind(self.OnClickClose, self))
	for i = 1, 2 do
		self:ListenEvent("LianChongClick" .. i, BindTool.Bind(self.OnLianChongClick, self, i))
		self:ListenEvent("ChongZhiClick" .. i, BindTool.Bind(self.OnChongZhiClick, self, i))
	end

	self.is_lianchong = false 	-- 是否连充界面
	self.lianchong_seq = {}		-- 领取连续充值奖励 param1 传入索引

	self.need_chongzhi_cfg = {}
	self.reward_num = 0
	local act_day = ActivityData.GetActivityDays(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIDAUTUMNMYYL)
	self.need_chongzhi_cfg, self.reward_num = MoonGiftData.Instance:GetRewardInfo(act_day)
	self.myyl_continue_chongzhi = MoonGiftData.Instance:GetMyylContinueCfg()

	if nil == self.least_time_timer then		
		local activity_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIDAUTUMNMYYL)
		if activity_info then
				local rest_time = activity_info.next_time - TimeCtrl.Instance:GetServerTime()	
				self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
					rest_time = rest_time - 1
				self:SetTime(rest_time)
			end)
		end
	end
end

function MoonGiftView:ReleaseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
	self.need_chongzhi_value = nil
	self.chongzhi_lable = {}
	self.is_show_right = nil
	self.lianxu_value = nil
	self.lianxu_value = nil
	self.list_view = nil
	self.select_index = nil
	self.res_time = nil
	self.chongzhi_btn = {}
	self.is_had_receieve = {}
	self.lianchong_red = {}
	self.btn_flag = {}
	self.receive_flag = {}

	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	for k, v in ipairs(self.continue_item) do
		v:DeleteMe()
	end
	self.continue_item = {}

	for k, v in ipairs(self.reward_cell_list ) do
		v:DeleteMe()
	end
	self.reward_cell_list = {}
	self.reward_num = nil
	self.slider_value = nil
	self.is_lianchong = nil
	self.lianchong_seq = nil
end

function MoonGiftView:OpenCallBack()
	self:FlushArrowState()
	self:Flush()
end

function MoonGiftView:CloseCallBack()

end

function MoonGiftView:SetTime(rest_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local str = ""
	if time_tab.day > 0 then
		str = TimeUtil.FormatSecond2DHMS(rest_time, 1)
	else
		str = TimeUtil.FormatSecond(rest_time)
	end

	if self.res_time then
		self.res_time:SetValue(str)
	end
end

function MoonGiftView:GetNumberOfCells()
	return self.reward_num or 0
end

function MoonGiftView:RefreshCell(cell, cell_index)
	cell_index = cell_index + 1
	local reward_cell = self.reward_cell_list[cell]
	if reward_cell == nil then
		reward_cell = MidAtmRewardItem.New(cell.gameObject)
		reward_cell:SetClickCallBack(BindTool.Bind(self.OnClickItemCallBack, self))
		self.reward_cell_list[cell] = reward_cell
	end
	reward_cell:SetToggleGroup(self.list_view.toggle_group)
	reward_cell:SetIndex(cell_index)
	reward_cell:SetData(self.need_chongzhi_cfg[cell_index])
end

function MoonGiftView:OnClickItemCallBack(cell)
	self.select_index = cell.index
	self.is_show_right:SetValue(false)
	self.is_lianchong = false
	self:SetItemList()
	self:FlushArrowState()
	self:SetChongZhiValue()
end

function MoonGiftView:SetItemList()
	if nil == self.need_chongzhi_cfg or nil == next(self.need_chongzhi_cfg) then return end
	local now_reward = self.need_chongzhi_cfg[self.select_index].reward
	if nil ~= now_reward then
		local item_gift_list = ItemData.Instance:GetGiftItemList(now_reward.item_id)
		if not item_gift_list then return end
		for k, v in pairs(item_gift_list) do
			if v then
				self.item_list[k]:SetData(v)
			end
		end
	end
end

function MoonGiftView:SetChongZhiValue()
	if nil == self.need_chongzhi_cfg or nil == next(self.need_chongzhi_cfg) then return end
	local rolo_chongzhi = MoonGiftData.Instance:GetChongZhiInfo()
	local need_chongzhi = self.need_chongzhi_cfg[self.select_index].need_chongzhi
	local flag = false
	if need_chongzhi then
		if rolo_chongzhi < need_chongzhi then
			self.btn_flag[1] = MOON_GIFT.QIANWANG_CHONGZHI
			flag = true
			self.need_chongzhi_value:SetValue(need_chongzhi - rolo_chongzhi)
		else
			local seq =  self.need_chongzhi_cfg[self.select_index].reward_seq
			self.receive_flag[1] = MoonGiftData.Instance:GeReceiveFlag(seq)
			self.need_chongzhi_value:SetValue(0)
			if self.receive_flag[1] == 1 then	--已领取
				flag = false
				self.btn_flag[1] = MOON_GIFT.GANXIE_CANYU
			elseif self.receive_flag[1] == 0 then	--未领取
				flag = true
				self.btn_flag[1] = MOON_GIFT.LINGQU_JIANGLI
			end
		end	
	end
	self:SetBtnState(flag, 1)
end

function MoonGiftView:OnFlush()
	self:SetItemList()
	self:SetChongZhiValue()
	self:SetLianChongValue(self.select_lianxu_index)
	if self.list_view and self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:ReloadData(0)
	end
end

-- 充值按钮
function MoonGiftView:OnChongZhiClick(index)
	if self.btn_flag[index] == MOON_GIFT.QIANWANG_CHONGZHI then	--前往充值
		VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
		ViewManager.Instance:Open(ViewName.VipView)
	elseif self.btn_flag[index] == MOON_GIFT.LINGQU_JIANGLI then	-- 可领取		
		if self.is_lianchong then
			for i, v in ipairs(self.lianchong_seq) do
				MoonGiftCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIDAUTUMNMYYL, 2, v)
			end	
		else
			local send_seq = self.need_chongzhi_cfg[self.select_index].reward_seq
			if send_seq then
				MoonGiftCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIDAUTUMNMYYL, 1, send_seq)
			end	
		end		
	end
end

function MoonGiftView:OnLianChongClick(index)
	self.select_lianxu_index = index
	self.is_lianchong = true
	self.is_show_right:SetValue(true)

	self:SetLianChongValue(index)
end

function MoonGiftView:SetLianChongValue(index)
	if nil == self.need_chongzhi_cfg or nil == next(self.need_chongzhi_cfg) then return end
	local lianxu_value = self.need_chongzhi_cfg[index + 1].need_chongzhi
	if lianxu_value then
		self.lianxu_value:SetValue(lianxu_value)
	end

	for i = 1, 2 do
		local item_cfg = self.myyl_continue_chongzhi[index][i].reward
		if nil ~= next(item_cfg) then
			self.continue_item[i]:SetData(item_cfg)
		end
		local is_show = MoonGiftData.Instance:SetDownTagRedPoint(i)
		self.lianchong_red[i]:SetValue(is_show)
	end
	self:SetRewardState(index)
end

function MoonGiftView:SetRewardState(index)
	local ra_myyl_meet_condition_days = MoonGiftData.Instance:GetConditionDays()
	local reward_seq = self.myyl_continue_chongzhi[index][1].reward_seq

	if ra_myyl_meet_condition_days == nil or next(ra_myyl_meet_condition_days) == nil then
		return
	end

	if reward_seq ~= nil then
		local btn_canclick = false
		local btn_str = MOON_GIFT.QIANWANG_CHONGZHI
		local chongzhi_day = ra_myyl_meet_condition_days[reward_seq] or 0
		self.lianchong_seq = {}
		local data = self.myyl_continue_chongzhi[index]
		if data == nil or next(data) == nil then
			return
		end

		self.slider_value:SetValue(chongzhi_day / 3)

		for i = 1, 2 do
			if data[i] ~= nil then
				local btn_data = MoonGiftData.Instance:GetRewardFlag(data[i].seq)
				if btn_data ~= nil then
					if btn_data == 0 then
						btn_canclick = true						
						if data[i].meet_condition_days <= chongzhi_day then
							btn_str = MOON_GIFT.LINGQU_JIANGLI
							table.insert(self.lianchong_seq, data[i].seq)
						end					
					end
				end
				self:SetIsLingQu(i, btn_data == 1)
			end
		end

		if not btn_canclick then
			btn_str = MOON_GIFT.GANXIE_CANYU
		end

		self.btn_flag[2] = btn_str
		self:SetBtnState(btn_canclick, 2)
	end
end

function MoonGiftView:SetBtnState(flag, index)
	if flag then
		self.chongzhi_btn[index].button.interactable = true
		self.chongzhi_btn[index].grayscale.GrayScale = 0
	else
		self.chongzhi_btn[index].button.interactable = false
		self.chongzhi_btn[index].grayscale.GrayScale = 255
	end
	self.chongzhi_lable[index]:SetValue(Language.MidAutumn.MyylBtnLab[self.btn_flag[index]])
end

function MoonGiftView:SetIsLingQu(index, flag)
	self.is_had_receieve[index]:SetValue(flag)
end

function MoonGiftView:FlushArrowState()
	for k, v in pairs(self.reward_cell_list) do
		v:SetToggleOn(self.select_index)
	end
end

function MoonGiftView:OnClickClose()
	self:Close()
end

-------------------------MidAtmRewardItem-----------------------------------
MidAtmRewardItem = MidAtmRewardItem or BaseClass(BaseCell)

function MidAtmRewardItem:__init()
	self.cur_value = self:FindVariable("CurValue")
	self.is_show = self:FindVariable("IsShow")
	self:ListenEvent("ItemClick",BindTool.Bind(self.OnIconBtnClick, self))
end

function MidAtmRewardItem:_delete()

end

function MidAtmRewardItem:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function MidAtmRewardItem:SetToggleOn(index)
	self.root_node.toggle.isOn = self.index == index
end

function MidAtmRewardItem:OnIconBtnClick()
	self:OnClick()
end

function MidAtmRewardItem:OnFlush()
	self.cur_value:SetValue(self.data.need_chongzhi)
	self.is_show:SetValue(MoonGiftData.Instance:SetLeftTagRetPoint(self.index))
end