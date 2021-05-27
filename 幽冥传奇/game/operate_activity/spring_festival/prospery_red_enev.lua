SpringProsperyRedEnvePage = SpringProsperyRedEnvePage or BaseClass()

function SpringProsperyRedEnvePage:__init()
	self.view = nil
	self.selec_item_index = 1
end

function SpringProsperyRedEnvePage:__delete()
	self:RemoveEvent()
	if self.awards_list then
		self.awards_list:DeleteMe()
		self.awards_list = nil
	end
	self.view = nil
end

function SpringProsperyRedEnvePage:InitPage(view)
	self.view = view
	self:InitEvent()
	self:CreateAwardsList()
	-- XUI.AddClickEventListener(self.view.node_t_list.btn_fetch_gift.node, BindTool.Bind(self.OnFetchClick, self), true)
end

function SpringProsperyRedEnvePage:InitEvent()
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushRemainTime, self), 1)
end

function SpringProsperyRedEnvePage:RemoveEvent()
	if self.seven_event then
		GlobalEventSystem:UnBind(self.seven_event)
		self.seven_event = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

--更新视图界面
function SpringProsperyRedEnvePage:UpdateData(data)
	local cfg = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.PROSPERY_RED_EVEV)
	if cfg then
		RichTextUtil.ParseRichText(self.view.node_t_list.rich_prospery_red_des.node, cfg.act_desc)
	end
	local data = OperateActivityData.Instance:GetProsperyRedEnveAwards()
	self.awards_list:SetData(data)
	self:FlushRemainTime()
end	

function SpringProsperyRedEnvePage:FlushRemainTime()
	local time = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.PROSPERY_RED_EVEV)

	if self.view.node_t_list.spring_act_rest_time_3 then
		self.view.node_t_list.spring_act_rest_time_3.node:setString(time)
	end
end

function SpringProsperyRedEnvePage:CreateAwardsList()
	if not self.awards_list then
		local ph = self.view.ph_list.ph_sp_redenve_list
		self.awards_list = ListView.New()
		self.awards_list:Create(ph.x, ph.y, ph.w, ph.h, direction, ProsperyRedEnveInfoItem, nil, false, self.view.ph_list.ph_sp_redenve_item)
		self.awards_list:SetItemsInterval(2)
		self.awards_list:SetJumpDirection(ListView.Top)
		self.view.node_t_list.layout_prospery_red_env.node:addChild(self.awards_list:GetView(), 100)
	end
end
