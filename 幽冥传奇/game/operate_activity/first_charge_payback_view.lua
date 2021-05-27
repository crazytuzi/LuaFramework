FirstChargePaybackView = FirstChargePaybackView or BaseClass(XuiBaseView)

function FirstChargePaybackView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/limit_activity.png'
	self.texture_path_list[2] = 'res/xui/boss.png'
	self.texture_path_list[3] = 'res/xui/charge.png'
	self.texture_path_list[4] = 'res/xui/operate_activity.png'
	self.texture_path_list[5] = 'res/xui/vip.png'
	-- self.texture_path_list[9] = "res/xui/fight.png"
	self.title_img_path = ResPath.GetCharge("first_back")
	
	self.config_tab = { --类dom模式,数组顺序决定渲染顺序
		{"common_ui_cfg", 1, {0}},
		{"first_charge_payback_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
	}
		
end

function FirstChargePaybackView:__delete()

end

function FirstChargePaybackView:ReleaseCallBack()
	if self.del_act_evt then
		GlobalEventSystem:UnBind(self.del_act_evt)
		self.del_act_evt = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function FirstChargePaybackView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self.del_act_evt = GlobalEventSystem:Bind(OperateActivityEventType.DELETE_CLOSE_ACT, BindTool.Bind(self.CheckIsOpen, self))
		-- self.add_act_evt = GlobalEventSystem:Bind(OperateActivityEventType.ADD_OPEN_ACT, BindTool.Bind(self.SetBtnsListData, self))
		self:CreateNumBar()
		XUI.AddClickEventListener(self.node_t_list.btn_charge_repeat.node, BindTool.Bind(self.OnChargeClick, self), true)
		self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushRemainTime, self), 1)
		self:FlushRemainTime()
	end
	
end

function FirstChargePaybackView:OpenCallBack()
	
end

function FirstChargePaybackView:CloseCallBack()
	
end

function FirstChargePaybackView:ShowIndexCallBack(index)
	self:Flush(index)
end

function FirstChargePaybackView:OnFlush(param_t, index)
	for k, v in pairs(param_t) do
		if k == "all" then

		end
	end
end

function FirstChargePaybackView:CreateNumBar()
	local ph = self.ph_list.ph_num_bar
	self.num_bar = NumberBar.New()
	self.num_bar:SetRootPath(ResPath.GetScene("fb_num_101_"))
	self.num_bar:SetPosition(ph.x, ph.y)
	self.num_bar:SetSpace(-3)
	-- self.num_bar:SetGravity(NumberBarGravity.Center)
	-- self.num_bar:GetView():setScale(2)
	self.node_t_list.layout_panel.node:addChild(self.num_bar:GetView(), 300, 300)
	local num = 0
	local act_cfg = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.FIRST_CHARGE_PAYBACK)
	if act_cfg then
		num = act_cfg.config.precent
	end
	self.num_bar:SetNumber(num)
	-- self.node_t_list.img_percent.node:setScale(2)
end

function FirstChargePaybackView:OnChargeClick()
	ViewManager.Instance:Open(ViewName.ChargePlatForm)
end

function FirstChargePaybackView:CheckIsOpen()
	local is_open = OperateActivityData.Instance:IsShowFirstChargePayback()
	if is_open == false then
		self:Close()
	end
end

function FirstChargePaybackView:FlushRemainTime()
	local time = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.FIRST_CHARGE_PAYBACK)
	if self.node_t_list.txt_rest_time then
		self.node_t_list.txt_rest_time.node:setString(time)
	end
end