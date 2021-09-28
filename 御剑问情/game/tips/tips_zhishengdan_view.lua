TipsZhishengdanView = TipsZhishengdanView or BaseClass(BaseView)

function TipsZhishengdanView:__init()
	self.ui_config = {"uis/views/tips/zhishengdantips_prefab","ZhishengdanTips"}
	self.play_audio = true
	self.tab_index = 0
	self.cur_grade_index = 0
end

function TipsZhishengdanView:__delete()

end

function TipsZhishengdanView:LoadCallBack()
	self:ListenEvent("CloseView", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("ClickBuy", BindTool.Bind(self.ClickBuy, self))
	self.cost_text = self:FindVariable("CostText")
	self.display = self:FindObj("Display")
	self.cur_grade = self:FindVariable("cur_grade")
end

function TipsZhishengdanView:ReleaseCallBack()
	self.cost_text = nil
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self.display = nil
	self.cur_grade = nil
end

function TipsZhishengdanView:OpenCallBack()
	self:Flush()
end

function TipsZhishengdanView:CloseCallBack()
	self.tab_index = 0
	self.cur_grade_index = 0
end

function TipsZhishengdanView:SetData(tab_index, cur_grade_index)
	self.tab_index = tab_index
	self.cur_grade_index = cur_grade_index
end

function TipsZhishengdanView:OnClickClose()
	self:Close()
end

function TipsZhishengdanView:ClickBuy()
	if (self.tab_index == TabIndex.wing_jinjie or self.tab_index == TabIndex.mount_jinjie) and self.cur_grade_index == 7 then
		VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.VIP)
		if self.tab_index == TabIndex.wing_jinjie then
			VipData.Instance:SetOpenParam(5)
		elseif self.tab_index == TabIndex.mount_jinjie then
			VipData.Instance:SetOpenParam(4)
		end

		ViewManager.Instance:Open(ViewName.VipView)
	else
		LeiJiRDailyCtrl.Instance:SetBiPinState(true)
		ViewManager.Instance:Open(ViewName.LeiJiDailyView)
	end

	self:Close()
end

function TipsZhishengdanView:SetModel()
    if self.model == nil then
        self.model = RoleModel.New()
        self.model:SetDisplay(self.display.ui3d_display)
    end

  	CompetitionActivityData.Instance:ChangeModelByZSD(self.model, 0, self.tab_index, self.cur_grade_index)
end

function TipsZhishengdanView:OnFlush()
	self:SetModel()
	self.cur_grade:SetValue(self.cur_grade_index)

	if (self.tab_index == TabIndex.wing_jinjie or self.tab_index == TabIndex.mount_jinjie) and self.cur_grade_index == 7 then
		if self.tab_index == TabIndex.wing_jinjie then
			self.cost_text:SetValue(VipData.Instance:GetVipExp(4) or 0)
		elseif self.tab_index == TabIndex.mount_jinjie then
			self.cost_text:SetValue(VipData.Instance:GetVipExp(3) or 0)
		end
	end
end