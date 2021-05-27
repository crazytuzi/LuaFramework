	-- 名动传奇
NatiLegendryReputationPage = NatiLegendryReputationPage or BaseClass()

function NatiLegendryReputationPage:__init()
	self.view = nil

end

function NatiLegendryReputationPage:__delete()
	self:RemoveEvent()

	if self.can_reward_avtivity_list then
		self.can_reward_avtivity_list:DeleteMe()
		self.can_reward_avtivity_list = nil 
	end

	self.view = nil
end

function NatiLegendryReputationPage:InitPage(view)
	self.view = view
	XUI.RichTextSetCenter(self.view.node_tree.layout_mingdongchuanqi.rich_my_yb_md.node)
	self:CreateAwarInfoList()
	self:InitEvent()
	self:OnAllDataChange()
end

function NatiLegendryReputationPage:InitEvent()
	-- XUI.AddClickEventListener(self.view.node_tree.btn_recharge_1.node, BindTool.Bind(self.OnClickChongzhiHandler, self), true)
	self.all_data_event = GlobalEventSystem:Bind(OperateActivityEventType.LEGENDRY_REPUTATION_ALLDATA, BindTool.Bind(self.OnAllDataChange, self))
	self.personal_data_event = GlobalEventSystem:Bind(OperateActivityEventType.LEGENDRY_REPUTATION_PERSONAL_DATA, BindTool.Bind(self.OnPersonalDataChange, self))
	-- self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self), 1)
end

function NatiLegendryReputationPage:RemoveEvent()
	if self.all_data_event then
		GlobalEventSystem:UnBind(self.all_data_event)
		self.all_data_event = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function NatiLegendryReputationPage:UpdateData(param_t)
	local cfg = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.LEGENDRY_REPUTATION)
	local content = cfg and cfg.act_desc or ""
	RichTextUtil.ParseRichText(self.view.node_tree.layout_mingdongchuanqi.rich_md_desc.node, content, 22, COLOR3B.YELLOW)
	local act_id = OPERATE_ACTIVITY_ID.LEGENDRY_REPUTATION
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActData(cmd_id, act_id)
	end
	content = OperateActivityData.Instance:GetLegendryReputationNeddMinCond()
	RichTextUtil.ParseRichText(self.view.node_tree.layout_mingdongchuanqi.rich_md_tip.node, content)
end

function NatiLegendryReputationPage:CreateAwarInfoList()
	local ph = self.view.ph_list.ph_legre_world_list
	self.can_reward_avtivity_list = ListView.New()
	self.can_reward_avtivity_list:Create(ph.x, ph.y, ph.w, ph.h, nil, OperateActLegendryRepuRender, nil, nil, self.view.ph_list.ph_legrep_world_item)
	self.can_reward_avtivity_list:SetItemsInterval(5)
	self.can_reward_avtivity_list:SetJumpDirection(ListView.Top)
	self.view.node_tree.layout_mingdongchuanqi.node:addChild(self.can_reward_avtivity_list:GetView(), 20)

	ph = self.view.ph_list.ph_legre_persoanl_list
	self.can_reward_avtivity_list_2 = ListView.New()
	self.can_reward_avtivity_list_2:Create(ph.x, ph.y, ph.w, ph.h, nil, OperateActLegendryRepuRender, nil, nil, self.view.ph_list.ph_legrep_world_item)
	self.can_reward_avtivity_list_2:SetItemsInterval(5)
	self.can_reward_avtivity_list_2:SetJumpDirection(ListView.Top)
	self.view.node_tree.layout_mingdongchuanqi.node:addChild(self.can_reward_avtivity_list_2:GetView(), 20)
end

function NatiLegendryReputationPage:OnAllDataChange()
	self:FlushTime()
	local data = OperateActivityData.Instance:GetLegendryReputationAllSerInfo()
	self.can_reward_avtivity_list:SetDataList(data)
	local data = OperateActivityData.Instance:GetLegendryReputationPersonalInfo()
	self.can_reward_avtivity_list_2:SetDataList(data)
	local content = OperateActivityData.Instance:GetLegendryReputationMyMoney()
	RichTextUtil.ParseRichText(self.view.node_tree.layout_mingdongchuanqi.rich_my_yb_md.node, content)
	content = OperateActivityData.Instance:GetLegendryReputationMyRank()
	RichTextUtil.ParseRichText(self.view.node_tree.layout_mingdongchuanqi.rich_my_rank.node, content)
end

function NatiLegendryReputationPage:OnPersonalDataChange()
	local data = OperateActivityData.Instance:GetLegendryReputationPersonalInfo()
	self.can_reward_avtivity_list_2:SetDataList(data)
end

-- 倒计时
function NatiLegendryReputationPage:FlushTime()
	-- local time_str = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.LEGENDRY_REPUTATION)
	-- if time_str == "" then
	-- 	if self.timer then
	-- 		GlobalTimerQuest:CancelQuest(self.timer)
	-- 		self.timer = nil
	-- 	end
	-- 	return
	-- end
	-- if self.view.node_tree.layout_mingdongchuanqi.text_time_3 then
	-- 	self.view.node_tree.text_time_3.layout_mingdongchuanqi.node:setString(time_str)
	-- end
end

function NatiLegendryReputationPage:OnClickChongzhiHandler()
	if self.view then
		self.view:Close()
		ViewManager.Instance:Open(ViewName.ChargePlatForm)
	end
end



