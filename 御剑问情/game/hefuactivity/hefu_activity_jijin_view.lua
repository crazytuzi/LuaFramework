HeFuJiJinView = HeFuJiJinView or BaseClass(BaseRender)

function HeFuJiJinView:__init()
	self.time = self:FindVariable("Time")

	self.list_cell = {}
	self.list_view = self:FindObj("ListView")

	local list_view_delegate = self.list_view.list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self.list_view.scroller:ReloadData(0)
	self:StartTime()
end

function HeFuJiJinView:__delete()
	self:CloseCallBack()
end

function HeFuJiJinView:OnFlush()
	self.list_view.scroller:RefreshActiveCellViews()
	self:StartTime()
end

function HeFuJiJinView:StartTime()
	rest_time = HefuActivityData.Instance:GetCombineActTimeLeft(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_JIJIN)
	self:CloseCallBack()
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
            self:SetTime(rest_time)
        end)
end

function HeFuJiJinView:SetTime(rest_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local temp = {}
	for k,v in pairs(time_tab) do
		if k ~= "day" then
			if v < 10 then
				v = tostring('0'..v)
			end
		end
		temp[k] = v
	end
	local str = string.format(Language.Activity.ChongZhiRankRestTime, temp.day, temp.hour, temp.min, temp.s)
	self.time:SetValue(str)
end

function HeFuJiJinView:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function HeFuJiJinView:RefreshView(cell, data_index)
	data_index = data_index + 1
	local item_cell = self.list_cell[cell]
	if nil == item_cell then
		item_cell = HeFuJiJinItem.New(cell)
		self.list_cell[cell] = item_cell
	end

	local data = HefuActivityData.Instance:GetFoundationByIndex(data_index)
	item_cell:SetIndex(data_index)
	item_cell:SetData(data)
end

function HeFuJiJinView:GetNumberOfCells()
	return HefuActivityData.Instance:GetHeFuJiJinNum() or 0
end


HeFuJiJinItem = HeFuJiJinItem or BaseClass(BaseCell)

function HeFuJiJinItem:__init()
	self.is_buy = false				--是否购买
	self.is_get_all = false			--是否领完
	self.money = 0
	self.gold = 0

	self.text_desc = self:FindVariable("TextDesc")
	self.text_button = self:FindVariable("TextButton")
	self.image = self:FindVariable("Image")
	self.not_show_desc = self:FindVariable("ShowDesc")
	self.diamond_text = self:FindVariable("DiamondText")

	self.button = self:FindObj("Button")
	self.text = self:FindObj("Text")

	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))
end

function HeFuJiJinItem:__delete()

end

function HeFuJiJinItem:OnFlush()
	if nil == self.data then
		return
	end

	local seq = self.index - 1
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local cfg = HefuActivityData.Instance:GetFoundationBySeq(seq)
	local cfg_single = HefuActivityData.Instance:GetFoundation(seq, self.data.reward_phase)
	
	local is_open = HefuActivityData.Instance:GetFoundationIsOpen()
	if nil ~= cfg_single then
		self.money = cfg_single.rmb
		--活动状态
		self.diamond_text:SetValue(cfg_single.gold)
	else
		self.diamond_text:SetValue(HefuActivityData.Instance:GetFoundationGold(seq, self.data.reward_phase)) 
	end

	if self.data.buy_level == 0 then
		--没有购买
		--活动结束，过期
		self.is_buy = false
		self.text_desc:SetValue(string.format(Language.Foundation.TextDesc, cfg_single.need_up_level, cfg_single.reward_gold))
		if is_open == CSActState.OPEN then
			self.is_get_all = false
			self.button.grayscale.GrayScale = 0
			self.text.grayscale.GrayScale = 0
			self.not_show_desc:SetValue(self.is_get_all)
			self.text_button:SetValue(string.format(Language.Foundation.ButtonDesc_1, cfg_single.rmb))
		else
			self.button.grayscale.GrayScale = 255
			self.text.grayscale.GrayScale = 255
			self.text_button:SetValue(Language.Foundation.ButtonDesc_4)
		end
	else
		self.is_buy = true
		if nil == cfg_single then
			--没有下一阶段配置，证明已经领完
			self.is_get_all = true
			self.button.grayscale.GrayScale = 255
			self.text.grayscale.GrayScale = 255
			self.not_show_desc:SetValue(self.is_get_all)
			self.text_button:SetValue(Language.Foundation.ButtonDesc_3)
		else
			--通过等级判断是否可领取
			local last_cfg = HefuActivityData.Instance:GetFoundation(seq, self.data.reward_phase - 1)
			local target_level = self.data.buy_level + cfg_single.need_up_level
			if HefuActivityData.Instance:CanRewardJiJin(seq, self.data.reward_phase) then
				self.button.grayscale.GrayScale = 0
				self.text.grayscale.GrayScale = 0
			else
				self.button.grayscale.GrayScale = 255
				self.text.grayscale.GrayScale = 255
			end

			self.is_get_all = false
			local main_vo = GameVoManager.Instance:GetMainRoleVo()
			local dif = target_level - main_vo.level
			if dif < 0 then
				dif = 0
			end
			self.not_show_desc:SetValue(self.is_get_all)

			self.text_desc:SetValue(string.format(Language.Foundation.TextDesc, dif, cfg_single.reward_gold))

			self.text_button:SetValue(Language.Foundation.ButtonDesc_2)
		end
	end
end

function HeFuJiJinItem:OnClick()
	if self.is_get_all then
		return
	end
	--获得状态是否结束
	if self.is_buy then
		--领奖
		local seq = self.index - 1
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_JIJIN, CSA_FOUNDATION_OPERA.CSA_FOUNDATION_FETCH_REQ, seq)
	else
		local seq = self.index - 1
		local fun = function()
			RechargeCtrl.Instance:Recharge(self.money)
		end
		if HefuActivityData.Instance:CanRewardAllJiJin(seq) then
			fun()
		else
			local desc = Language.Fishing.CanNotRewardAll
			TipsCtrl.Instance:ShowCommonAutoView(nil, desc, fun)
		end		
	end
end


