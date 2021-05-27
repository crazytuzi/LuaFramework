-- 充值送礼界面
SpringChargeGiveGiftPage = SpringChargeGiveGiftPage or BaseClass()

function SpringChargeGiveGiftPage:__init()
	self.view = nil

end

function SpringChargeGiveGiftPage:__delete()
	self:RemoveEvent()
	if self.normal_awar_list then
		self.normal_awar_list:DeleteMe()
		self.normal_awar_list = nil
	end

	if self.special_awar then
		self.special_awar:DeleteMe()
		self.special_awar = nil
	end

	if self.fetch_state_list then
		self.fetch_state_list:DeleteMe()
		self.fetch_state_list = nil
	end

	if self.num_bar then
		self.num_bar:DeleteMe()
		self.num_bar = nil
	end

	if self.num_bar_2 then
		self.num_bar_2:DeleteMe()
		self.num_bar_2 = nil
	end

	self.view = nil
end



function SpringChargeGiveGiftPage:InitPage(view)
	self.view = view
	self.fetch_def_selec_idx = 1
	self:CreateAwarInfoList()
	self:CreateNumBar()
	self:InitEvent()
	self:OnChargeGiveGiftEvent()
	self.view.node_t_list.btn_charge_give_tip.node:setVisible(false)
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_charge_give_tip.node, Language.OperateActivity.Content[OPERATE_ACTIVITY_ID.CHARGE_GIVE_GIFT], 20, COLOR3B.YELLOW)
end

function SpringChargeGiveGiftPage:InitEvent()
	XUI.AddClickEventListener(self.view.node_t_list.btn_charge_give_charge.node, BindTool.Bind(self.OnClickChongzhiHandler, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_charge_give_fetch.node, BindTool.Bind(self.OnClickFetchAwardHandler, self), true)
	self.charge_give_event  = GlobalEventSystem:Bind(OperateActivityEventType.CHARGE_GIVE_GIFT_DATA, BindTool.Bind(self.OnChargeGiveGiftEvent, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self),  1)
end

function SpringChargeGiveGiftPage:RemoveEvent()
	if self.charge_give_event then
		GlobalEventSystem:UnBind(self.charge_give_event)
		self.charge_give_event = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function SpringChargeGiveGiftPage:CreateAwarInfoList()
	local ph = self.view.ph_list.ph_charge_give_normal_awards_list
	self.normal_awar_list = ListView.New()
	self.normal_awar_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, OperateGiveGiftAwarRender, nil, nil, self.view.ph_list.ph_charge_give_nor_award)
	self.normal_awar_list:SetItemsInterval(6)
	-- self.normal_awar_list:SetJumpDirection(ListView.Top)
	self.view.node_t_list.layout_spring_charge_give_gift.node:addChild(self.normal_awar_list:GetView(), 99)

	ph = self.view.ph_list.ph_fetch_state_list
	local item_ui_cfg = self.view.ph_list.ph_fetch_state_item
	local interval = (ph.w - item_ui_cfg.w * 5) / 4
	self.fetch_state_list = ListView.New()
	self.fetch_state_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, OperateGiveGiftFetchStateRender, nil, nil, item_ui_cfg)
	self.fetch_state_list:SetItemsInterval(interval)
	self.fetch_state_list:SetSelectCallBack(BindTool.Bind(self.OnFetchStateListCallback, self))
	self.view.node_t_list.layout_spring_charge_give_gift.node:addChild(self.fetch_state_list:GetView(), 99)

	ph = self.view.ph_list.ph_charge_give_spec_cell
	self.special_awar = BaseCell.New()
	self.special_awar:SetPosition(ph.x, ph.y)
	self.special_awar.bg_img:setVisible(false)
	self.special_awar:GetView():setScale(1.1)
	self.view.node_t_list.layout_spring_charge_give_gift.node:addChild(self.special_awar:GetView(), 99)

end

function SpringChargeGiveGiftPage:CreateNumBar()
	local ph = self.view.ph_list.ph_charge_give_num_bar
	self.num_bar = NumberBar.New()
	self.num_bar:SetRootPath(ResPath.GetVipResPath("vip_"))
	self.num_bar:SetPosition(ph.x, ph.y)
	self.num_bar:SetSpace(-5)
	self.num_bar:SetGravity(NumberBarGravity.Center)
	-- self.num_bar:GetView():setScale(0)
	self.view.node_t_list.layout_spring_charge_give_gift.node:addChild(self.num_bar:GetView(), 300, 300)
	local num = 0
	local act_cfg = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.CHARGE_GIVE_GIFT)
	if act_cfg then
		num = act_cfg.config.rechargeGoldNum
	end
	self.num_bar:SetNumber(num)

	ph = self.view.ph_list.ph_charge_give_num_bar_2
	self.num_bar_2 = NumberBar.New()
	self.num_bar_2:SetRootPath(ResPath.GetVipResPath("vip_"))
	self.num_bar_2:SetPosition(ph.x, ph.y)
	self.num_bar_2:SetSpace(-5)
	self.num_bar_2:SetGravity(NumberBarGravity.Center)
	-- self.num_bar_2:GetView():setScale(0)
	self.view.node_t_list.layout_spring_charge_give_gift.node:addChild(self.num_bar_2:GetView(), 300, 300)
	local data_list = OperateActivityData.Instance:GetChargeGiveAllFetchStateList()
	local num = #data_list
	self.num_bar_2:SetNumber(num)
end

function SpringChargeGiveGiftPage:OnFetchStateListCallback(item, index)
	if nil == item or nil == item:GetData() then return end
	self:FlushShowAwards(index)
end

function SpringChargeGiveGiftPage:OnChargeGiveGiftEvent()
	local data_list = OperateActivityData.Instance:GetChargeGiveAllFetchStateList()
	self.fetch_state_list:SetDataList(data_list)
	local ph = self.view.ph_list.ph_fetch_state_list
	local len = #data_list
	if len < 5 then
		local item_ui_cfg = self.view.ph_list.ph_fetch_state_item
		local interval = self.fetch_state_list:GetView():getItemsInterval()
		local w = item_ui_cfg.w * len + (len - 1) * interval
		self.fetch_state_list:GetView():setPosition(ph.x + (ph.w - w) * 0.5, ph.y)
	else
		self.fetch_state_list:GetView():setPosition(ph.x, ph.y)
	end	


	local opened_day = OperateActivityData.Instance:GetChargeGiveOpenInfo().opened_day
	-- print("opened_day===", opened_day)
	local state = data_list[opened_day] and data_list[opened_day].state or 0
	self.view.node_t_list.btn_charge_give_fetch.node:setVisible(state == 1)
	local my_money = OperateActivityData.Instance:GetChargeGiveOpenInfo().my_money
	local my_money_txt = string.format(Language.OperateActivity.ChargeGiveMyMoney, my_money)
	self.view.node_t_list.txt_charge_give_charge_money.node:setString(my_money_txt)
end

function SpringChargeGiveGiftPage:FlushShowAwards(index)
	index = index or self.fetch_def_selec_idx
	local data_list = OperateActivityData.Instance:GetChargeGiveOneDayAwards(index)
	if data_list then
		self.special_awar:SetData(data_list.special_award)
		self.special_awar:SetQualityBgVis(false)
		self.normal_awar_list:SetDataList(data_list.normal_awards)
	end
end

local charge_give_end_time = 24 * 3600
function SpringChargeGiveGiftPage:FlushTime()
	local opened_day = OperateActivityData.Instance:GetChargeGiveOpenInfo().opened_day
	local time_str = ""
	if opened_day == 1 then
		local now_time = ActivityData.GetNowShortTime()
		local remain_time = charge_give_end_time - now_time
		if remain_time > 0 then
			time_str = TimeUtil.FormatSecond2Str(remain_time, 1)
		end
	end
	if time_str == "" then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
	end
	if time_str ~= "" then
		time_str = Language.Common.RemainTime .. "：" .. time_str
	end
	if self.view.node_t_list.text_charge_give_time then
		self.view.node_t_list.text_charge_give_time.node:setString(time_str)
	end

end

function SpringChargeGiveGiftPage:OnClickChongzhiHandler()
	if self.view then
		self.view:Close()
		ViewManager.Instance:Open(ViewName.ChargePlatForm)
	end
end

function SpringChargeGiveGiftPage:OnClickFetchAwardHandler()
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.CHARGE_GIVE_GIFT)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.CHARGE_GIVE_GIFT)
	end
end

function SpringChargeGiveGiftPage:UpdateData()
	self.fetch_state_list:SelectIndex(self.fetch_def_selec_idx)
	self:FlushTime()
	-- local data = OperateActivityData.Instance:GetConsumeCfg()
	-- self.normal_awar_list:SetDataList(data)
end


