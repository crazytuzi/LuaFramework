-- 新连续累充
OperActNewContiAddupChargePage = OperActNewContiAddupChargePage or BaseClass()

function OperActNewContiAddupChargePage:__init()
	self.view = nil
	
end

function OperActNewContiAddupChargePage:__delete()
	self:RemoveEvent()
	if self.awards_info_list then
		self.awards_info_list:DeleteMe()
		self.awards_info_list = nil
	end

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
	self.tab_index = 1
	self.view = nil
end



function OperActNewContiAddupChargePage:InitPage(view)
	self.tab_index = 1
	self.view = view
	self:CreateShowItemsList()
	self:InitTabbar()
	self:InitEvent()
	self:OnDataChangeEvt()
end

function OperActNewContiAddupChargePage:InitEvent()
	XUI.RichTextSetVCenter(self.view.node_t_list.rich_conti_addup_c_money_new.node)
	XUI.RichTextSetCenter(self.view.node_t_list.rich_conti_addup_c_money_new.node)
	self.data_evt = GlobalEventSystem:Bind(OperateActivityEventType.NEW_CONTI_ADDUP_CHARGE_DATA, BindTool.Bind(self.OnDataChangeEvt, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushRemainTime, self), 1)
	XUI.AddClickEventListener(self.view.node_t_list.btn_conti_addup_c_go_charge_new.node, BindTool.Bind(self.OnClickChongzhiHandler, self), true)

end

function OperActNewContiAddupChargePage:RemoveEvent()
	if self.data_evt then
		GlobalEventSystem:UnBind(self.data_evt)
		self.data_evt = nil
	end
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function OperActNewContiAddupChargePage:UpdateData()
	-- local act_cfg = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.CONTINUOUS_ADDUP_CHARGE_NEW)
	-- local content = act_cfg and act_cfg.act_desc or ""
	-- RichTextUtil.ParseRichText(self.view.node_t_list.rich_conti_addup_c_des_new.node, content, 24, COLOR3B.YELLOW)
	local act_id = OPERATE_ACTIVITY_ID.CONTINUOUS_ADDUP_CHARGE_NEW
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActData(cmd_id, act_id)
	end
	self:FlushRemainTime()
end

function OperActNewContiAddupChargePage:InitTabbar()
	if nil == self.tabbar then
		self.tabbar = Tabbar.New()
		local ph = self.view.ph_list.ph_new_conti_add_tabbar
		local TabGroup = OperateActivityData.Instance:GetNewContiAddupNameTab()
		self.tabbar:CreateWithNameList(self.view.node_t_list.layout_conti_addup_charge_new.node, ph.x, ph.y,
			function(index) self:ChangeToIndex(index) end,
			TabGroup,
			false, ResPath.GetCommon("toggle_106"), 18)
		self.tabbar:SetSpaceInterval(15)
		self.tabbar:ChangeToIndex(self.tab_index)
	end
end

function OperActNewContiAddupChargePage:ChangeToIndex(index)
	index = index or self.tab_index
	self.tab_index = index
	self:OnDataChangeEvt()
end

function OperActNewContiAddupChargePage:CreateShowItemsList()
	if not self.awards_info_list then
		local ph = self.view.ph_list.ph_conti_addup_c_list_new
		self.awards_info_list = ListView.New()
		self.awards_info_list:Create(ph.x, ph.y, ph.w, ph.h, direction, NewContiAddupChargeItem, nil, false, self.view.ph_list.ph_conti_addup_c_item_new)
		self.awards_info_list:SetItemsInterval(2)
		self.awards_info_list:SetJumpDirection(ListView.Top)
		self.view.node_t_list.layout_conti_addup_charge_new.node:addChild(self.awards_info_list:GetView(), 100)
	end
end

function OperActNewContiAddupChargePage:OnDataChangeEvt()
	for i , v in ipairs(OperateActivityData.Instance:GetNewContiAddupAllPlanRemindNum()) do
		self.tabbar:SetRemindByIndex(i, v ~= nil and v > 0)
	end
	local data = OperateActivityData.Instance:GetNewContinousAddupChargeData()
	if data then
		local content = string.format(Language.OperateActivity.DayNumTexts[4], data.money) 
		RichTextUtil.ParseRichText(self.view.node_t_list.rich_conti_addup_c_money_new.node, content)
	end
	data = OperateActivityData.Instance:GetNewContinousAddupChargeAwards(self.tab_index)
	if data then
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
		self.awards_info_list:SetData(awar_data)
	end
end

function OperActNewContiAddupChargePage:FlushRemainTime()
	local time = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.CONTINUOUS_ADDUP_CHARGE_NEW)
	if time == "" then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		return
	end
	if self.view.node_t_list.lbl_conti_addup_c_rest_time_new then
		self.view.node_t_list.lbl_conti_addup_c_rest_time_new.node:setString(Language.Common.RemainTime.."："..time)
	end
end

function OperActNewContiAddupChargePage:OnClickChongzhiHandler()
	if self.view then
		self.view:Close()
		ViewManager.Instance:Open(ViewName.ChargePlatForm)
	end
end