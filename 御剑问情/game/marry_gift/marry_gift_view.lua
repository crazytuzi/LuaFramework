MarryGiftView = MarryGiftView or BaseClass(BaseView)

function MarryGiftView:__init()
	self.ui_config = {"uis/views/marrygiftview_prefab","MarryGiftView"}
	self.play_audio = true
	self.is_async_load = false
	self.marry_gift_endtime = 0
end

function MarryGiftView:__delete()

end

function MarryGiftView:LoadCallBack()
	self:ListenEvent("CloseView", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("ClickBuy", BindTool.Bind(self.ClickBuy, self))
	self.item_cell_list = {}
	self.item_cell_node_list = {}
	for i = 1, 4 do
		self.item_cell_node_list[i] = self:FindObj("Item"..i)
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.item_cell_node_list[i])
		self.item_cell_list[i] = item_cell
	end
	self.res_time = self:FindVariable("res_time")
	self.cost_text = self:FindVariable("CostText")
end

function MarryGiftView:ReleaseCallBack()
	self.item_cell_node_list = {}
	if self.item_cell_list then
		for k,v in pairs(self.item_cell_list) do
			v:DeleteMe()
		end
		self.item_cell_list = {}
	end
	if self.marry_gift_timer then
		GlobalTimerQuest:CancelQuest(self.marry_gift_timer)
		self.marry_gift_timer = nil
	end
	self.res_time = nil
	self.cost_text = nil
end

function MarryGiftView:OpenCallBack()
	self:Flush()
end

function MarryGiftView:CloseCallBack()

end

function MarryGiftView:OnClickClose()
	self:Close()
end

function MarryGiftView:ClickBuy()
	local cur_seq = MarryGiftData.Instance:CurPurchasedSeq()
	MarriageCtrl.Instance:SendQingYuanOperate(QINGYUAN_OPERA_TYPE.QINGYAN_OPREA_TYPE_BUY_TIME_LIMIT_GIFT, cur_seq + 1)
end


function MarryGiftView:OnFlush()
	local cur_seq = MarryGiftData.Instance:CurPurchasedSeq()
	local cfg = MarryGiftData.Instance:GetMarryGiftSeqCfg(cur_seq + 1)
	if cfg then
		local all_list = {}
		local libao_list = nil
		local sex = GameVoManager.Instance:GetMainRoleVo().sex
		local reward_list = sex == 1 and cfg.male_reward_item or cfg.famale_reward_item
		for i=0, #reward_list do
			if reward_list[i] then
				local _, big_type = ItemData.Instance:GetItemConfig(reward_list[i].item_id)
				if big_type ~= GameEnum.ITEM_BIGTYPE_GIF then
					table.insert(all_list, reward_list[i])
				else
				    libao_list = ItemData.Instance:GetGiftItemList(reward_list[i].item_id)
				    for i,v1 in ipairs(libao_list) do
				       table.insert(all_list, v1)
				    end
		        end
		    end
		end
		for k,v in pairs(self.item_cell_list) do
			self.item_cell_node_list[k]:SetActive(all_list[k] ~= nil)
			v:SetData(all_list[k])
		end
		self.marry_gift_endtime = TimeUtil.NowDayTimeEnd(TimeCtrl.Instance:GetServerTime())
		if self.marry_gift_timer == nil then
			self.marry_gift_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
			self:FlushNextTime()
		end
		self.cost_text:SetValue(cfg.gold_price)
	else
		if self.marry_gift_timer then
			GlobalTimerQuest:CancelQuest(self.marry_gift_timer)
			self.marry_gift_timer = nil
		end
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NoMarryGiftTxt)
		self:Close()
	end
end

function MarryGiftView:FlushNextTime()
	local time = self.marry_gift_endtime - TimeCtrl.Instance:GetServerTime()
	if time > 0 then
		if time > 3600 then
			self.res_time:SetValue(string.format(Language.Marriage.MarryGiftTimeTxt, TimeUtil.FormatSecond(time, 1)))
		else
			self.res_time:SetValue(string.format(Language.Marriage.MarryGiftTimeTxt, TimeUtil.FormatSecond(time, 2)))
		end
	else
		self:Flush()
	end
end