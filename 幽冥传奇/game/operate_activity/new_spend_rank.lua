-- 新充值排行
OperateActNewSpendRankPage = OperateActNewSpendRankPage or BaseClass()

function OperateActNewSpendRankPage:__init()
	self.view = nil

end

function OperateActNewSpendRankPage:__delete()
	self:RemoveEvent()
	if self.show_items_list then
		self.show_items_list:DeleteMe()
		self.show_items_list = nil
	end

	if self.sports_rank_list then
		self.sports_rank_list:DeleteMe()
		self.sports_rank_list = nil
	end

	self.view = nil
end



function OperateActNewSpendRankPage:InitPage(view)
	self.view = view
	self:CreateShowItemsList()
	self:InitEvent()
	self:OnNewSpendRankEvt()
	self.view.node_t_list.btn_rank_tip_new_1.node:setVisible(false)
	self.view.node_t_list.rich_spec_awar_title_1.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	-- LimitedActivityCtrl.Instance:TimeLimitedGoodsDataReq()
end



function OperateActNewSpendRankPage:InitEvent()
	self.time_limited_goods_evt = GlobalEventSystem:Bind(OperateActivityEventType.NEW_SPEND_RANK_DATA, BindTool.Bind(self.OnNewSpendRankEvt, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushRemainTime, self), 1)
	XUI.AddClickEventListener(self.view.node_t_list.btn_sp_awar_get_1.node, BindTool.Bind(self.OnFetchAwards, self), true)
	
end

function OperateActNewSpendRankPage:RemoveEvent()
	if self.time_limited_goods_evt then
		GlobalEventSystem:UnBind(self.time_limited_goods_evt)
		self.time_limited_goods_evt = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end


function OperateActNewSpendRankPage:UpdateData()

	local act_cfg = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.NEW_SPEND_RANK)
	local content = act_cfg and act_cfg.act_desc or ""
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_rank_des_new_1.node, content, 24, COLOR3B.YELLOW)

	local data = OperateActivityData.Instance:GetNewSpendRankAwards()
	if data then
		self.show_items_list:SetData(data.special_awards)
		self.sports_rank_list:SetData(data.rank_awards)
		RichTextUtil.ParseRichText(self.view.node_t_list.rich_spec_awar_title_1.node, data.spec_des, 20, COLOR3B.YELLOW)
	end

	local act_id = OPERATE_ACTIVITY_ID.NEW_SPEND_RANK
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActData(cmd_id, act_id)
	end
end

function OperateActNewSpendRankPage:CreateShowItemsList()
	if not self.show_items_list then
		local ph = self.view.ph_list.ph_spec_awar_list_1
		local cell_ui_cfg = self.view.ph_list.ph_spec_cell_item_1
		self.show_items_list = ListView.New()
		self.show_items_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, OperateGiveGiftAwarRender, gravity, is_bounce, cell_ui_cfg)
		local margin = 1
		-- local gap = (ph.w - 2 * margin - 3 * self.view.ph_list.ph_shop_item.w) / 3
		self.show_items_list:SetItemsInterval(3)
		self.show_items_list:SetMargin(margin)
		self.show_items_list:SetJumpDirection(ListView.Left)
		self.view.node_t_list.layout_spend_rank_new.node:addChild(self.show_items_list:GetView(), 90)
	end

	if not self.sports_rank_list then
		local ph = self.view.ph_list.ph_item_list_8_new_1
		self.sports_rank_list = ListView.New()
		self.sports_rank_list:Create(ph.x, ph.y, ph.w, ph.h, direction, OperateSportsRankItem, nil, false, self.view.ph_list.ph_list_item_8_new_1)
		self.sports_rank_list:SetItemsInterval(2)
		self.sports_rank_list:SetJumpDirection(ListView.Top)
		self.view.node_t_list.layout_spend_rank_new.node:addChild(self.sports_rank_list:GetView(), 100)
	end
end

function OperateActNewSpendRankPage:OnNewSpendRankEvt()
	local data = OperateActivityData.Instance:GetNewSpendRankData()
	if data then
		local content = string.format(Language.OperateActivity.SportsRankTexts[1], data.my_rank, 
			string.format(Language.OperateActivity.SportsRankTexts[6], data.cur_money))
		RichTextUtil.ParseRichText(self.view.node_t_list.rich_my_rank_new_1.node, content)

		self.view.node_t_list.btn_sp_awar_get_1.node:setEnabled(data.my_fetch_state == 1)
		local txt = Language.OperateActivity.FetchStateTexts[1]
		if data.my_fetch_state == 2 then
			txt = Language.OperateActivity.FetchStateTexts[2]
		end
		self.view.node_t_list.btn_sp_awar_get_1.node:setTitleText(txt)
	end
end

function OperateActNewSpendRankPage:FlushRemainTime()
	local time = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.NEW_SPEND_RANK)
	if time == "" then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		return
	end

	if self.view.node_t_list.lbl_rank_remain_time_new_1 then
		self.view.node_t_list.lbl_rank_remain_time_new_1.node:setString(time)
	end
end

function OperateActNewSpendRankPage:OnFetchAwards()
	local act_id = OPERATE_ACTIVITY_ID.NEW_SPEND_RANK
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, act_id)
	end
end