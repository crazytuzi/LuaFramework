-- 新充值排行
OperActContiAddupChargePage = OperActContiAddupChargePage or BaseClass()

function OperActContiAddupChargePage:__init()
	self.view = nil

end

function OperActContiAddupChargePage:__delete()
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



function OperActContiAddupChargePage:InitPage(view)
	self.view = view
	self:CreateShowItemsList()
	self:InitEvent()
	self:OnDataChangeEvt()
	self.view.node_t_list.rich_conti_addup_c_extr_awar_title.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	-- LimitedActivityCtrl.Instance:TimeLimitedGoodsDataReq()
end



function OperActContiAddupChargePage:InitEvent()
	XUI.RichTextSetVCenter(self.view.node_t_list.rich_conti_addup_c_money.node)
	self.data_evt = GlobalEventSystem:Bind(OperateActivityEventType.CONTINOUS_ADDUP_CHARGE_DATA, BindTool.Bind(self.OnDataChangeEvt, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushRemainTime, self), 1)
	XUI.AddClickEventListener(self.view.node_t_list.btn_conti_addup_c_sp_awar_get.node, BindTool.Bind(self.OnFetchAwards, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_conti_addup_c_go_charge.node, BindTool.Bind(self.OnClickChongzhiHandler, self), true)

end

function OperActContiAddupChargePage:RemoveEvent()
	if self.data_evt then
		GlobalEventSystem:UnBind(self.data_evt)
		self.data_evt = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end


function OperActContiAddupChargePage:UpdateData()
	local act_cfg = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.CONTINUOUS_ADDUP_CHARGE)
	local content = act_cfg and act_cfg.act_desc or ""
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_conti_addup_c_des.node, content, 24, COLOR3B.YELLOW)

	local data = OperateActivityData.Instance:GetContinousAddupChargeData()
	if data then
		self.show_items_list:SetData(data.extr_awards)
		local content = string.format(Language.OperateActivity.ContiAddupChargeTxts[1], data.total_day)
		RichTextUtil.ParseRichText(self.view.node_t_list.rich_conti_addup_c_extr_awar_title.node, content, 20, COLOR3B.YELLOW)
	end

	local act_id = OPERATE_ACTIVITY_ID.CONTINUOUS_ADDUP_CHARGE
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActData(cmd_id, act_id)
	end
	self:FlushRemainTime()
end

function OperActContiAddupChargePage:CreateShowItemsList()
	if not self.show_items_list then
		local ph = self.view.ph_list.ph_conti_addup_c_spec_awar_list
		local cell_ui_cfg = self.view.ph_list.ph_conti_addup_c_ex_cell
		self.show_items_list = ListView.New()
		self.show_items_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, OperateGiveGiftAwarRender, gravity, is_bounce, cell_ui_cfg)
		local margin = 1
		-- local gap = (ph.w - 2 * margin - 3 * self.view.ph_list.ph_shop_item.w) / 3
		self.show_items_list:SetItemsInterval(3)
		self.show_items_list:SetMargin(margin)
		self.show_items_list:SetJumpDirection(ListView.Left)
		self.view.node_t_list.layout_conti_addup_charge.node:addChild(self.show_items_list:GetView(), 90)
	end

	if not self.sports_rank_list then
		local ph = self.view.ph_list.ph_conti_addup_c_list
		self.sports_rank_list = ListView.New()
		self.sports_rank_list:Create(ph.x, ph.y, ph.w, ph.h, direction, ContiAddupChargeItem, nil, false, self.view.ph_list.ph_conti_addup_c_item)
		self.sports_rank_list:SetItemsInterval(2)
		self.sports_rank_list:SetJumpDirection(ListView.Top)
		self.view.node_t_list.layout_conti_addup_charge.node:addChild(self.sports_rank_list:GetView(), 100)
	end
end

function OperActContiAddupChargePage:OnDataChangeEvt()
	local data = OperateActivityData.Instance:GetContinousAddupChargeData()
	if data then
		local day = data.day <= #data.awar_info and data.day or #data.awar_info
		local money = data.awar_info[day].money or 0
		local content = string.format(Language.OperateActivity.DayNumTexts[4], money) 
			-- string.format(Language.OperateActivity.SportsRankTexts[7], data.cur_money))
		RichTextUtil.ParseRichText(self.view.node_t_list.rich_conti_addup_c_money.node, content)
		self.view.node_t_list.btn_conti_addup_c_sp_awar_get.node:setVisible(data.extr_state ~= DAILY_CHARGE_FETCH_ST.CNNOT)
		local txt = Language.OperateActivity.FetchStateTexts[1]
		content = ""
		if data.extr_state == DAILY_CHARGE_FETCH_ST.CNNOT then
			local less_day = OperateActivityData.Instance:GetContinousAddupLessDay()
			content = string.format(Language.OperateActivity.ContiAddupChargeTxts[4],less_day)
		end
		RichTextUtil.ParseRichText(self.view.node_t_list.rich_conti_addup_c_extr_awar_less_day.node, content)
		if data.extr_state == DAILY_CHARGE_FETCH_ST.FETCHED then
			txt = Language.OperateActivity.FetchStateTexts[2]
		end
		self.view.node_t_list.btn_conti_addup_c_sp_awar_get.node:setTitleText(txt)
		local awar_data = TableCopy(data.awar_info)
		local function sort_list()	--可领取在上面,已领取在最后,未完成在中间
			return function(a, b)
				if a.client_rank ~= b.client_rank then
					return a.client_rank > b.client_rank
				end
				return a.idx < b.idx
			end
		end
		table.sort(awar_data, sort_list()) 
		self.sports_rank_list:SetData(awar_data)
	end
end

function OperActContiAddupChargePage:FlushRemainTime()
	local time = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.CONTINUOUS_ADDUP_CHARGE)
	if time == "" then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		return
	end
	if self.view.node_t_list.lbl_conti_addup_c_rest_time then
		self.view.node_t_list.lbl_conti_addup_c_rest_time.node:setString(Language.Common.RemainTime.."："..time)
	end
end

function OperActContiAddupChargePage:OnFetchAwards()
	local act_id = OPERATE_ACTIVITY_ID.CONTINUOUS_ADDUP_CHARGE
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, act_id, award_index, 2, oper_time, dindan_id, role_id, join_type)
	end
end

function OperActContiAddupChargePage:OnClickChongzhiHandler()
	if self.view then
		self.view:Close()
		ViewManager.Instance:Open(ViewName.ChargePlatForm)
	end
end