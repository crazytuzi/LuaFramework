TempMountView = TempMountView or BaseClass(BaseView)

function TempMountView:__init()
	self.ui_config = {"uis/views/tempmountview","TempMountView"}
end

function TempMountView:__delete()

end

function TempMountView:LoadCallBack()

	self.boss_display = self:FindObj("BossDisplay")
	self.boss_display2 = self:FindObj("BossDisplay2")
	self.boss_display3 = self:FindObj("BossDisplay3")

	self.use_decs = self:FindVariable("use_decs")
	self.has_select = self:FindVariable("has_select")
	self.use_name = self:FindVariable("imagename3")
	self.use_time = self:FindVariable("use_time")

	self.btn_on = self:FindVariable("btn_on")

	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickTakeOff", BindTool.Bind(self.OnClickTakeOff, self))
	self:ListenEvent("OnClickSelect", BindTool.Bind(self.OnClickSelect, self))
	self.name_list = {}
	for i =1, 2 do
		self:ListenEvent("OnClickUse" .. i, BindTool.Bind(self.OnClickUse, self, i))
		self.name_list[i] = self:FindVariable("imagename" .. i)
	end
end

function TempMountView:ReleaseCallBack()
	if self.boss_model then
		self.boss_model:DeleteMe()
		self.boss_model = nil
	end
	if self.boss_model2 then
		self.boss_model2:DeleteMe()
		self.boss_model2 = nil
	end
	if self.boss_model3 then
		self.boss_model3:DeleteMe()
		self.boss_model3 = nil
	end
	self.boss_display = nil
	self.boss_display2 = nil
	self.boss_display3 = nil

	self.use_decs = nil
	self.has_select = nil
	self.use_name = nil
	self.use_time = nil

	self.btn_on = nil

	self.name_list = {}
end

function TempMountView:OpenCallBack()
	self:Flush()
end

function TempMountView:CloseCallBack()
	self:RemoveCountDown()
end

function TempMountView:OnFlush()
	if false == MountData.Instance:IsShowTempMountIcon() then
		self:Close()
	end
	self.has_select:SetValue(MountData.Instance:HasChooseTempMount())
	if MountData.Instance:HasChooseTempMount() then
		local image_id = MountData.Instance:GetTempImgId()
		local res_id = TempMountData.Instance:GetResIdById(image_id)
		if nil ~= res_id then
			self:FlushThreeBoss(res_id)
		end
		self.use_name:SetValue(TempMountData.Instance:GetMountNameById(image_id))
		self:RemoveCountDown()
		local temp_time = MountData.Instance:GetTempMountTime()
		if nil == self.count_down and temp_time > 0 then
			local servre_time = TimeCtrl.Instance:GetServerTime()
			self.count_down = CountDown.Instance:AddCountDown(temp_time - servre_time, 1, BindTool.Bind(self.CountDownTime, self))
			self:CountDownTime(0, temp_time - servre_time)
		end
	else
		for i = 1, 2 do
			local temp_cfg = TempMountData.Instance:GetTempMountInfoByIndex(i)
			self.name_list[i]:SetValue(temp_cfg.image_name)
		end
		self:FlushBossModel(TempMountData.Instance:GetTempMountInfoByIndex(1).res_id)
		self:FlushSurperBossModel(TempMountData.Instance:GetTempMountInfoByIndex(2).res_id)
	end
end

function TempMountView:CountDownTime(elapse_time, total_time)
	if total_time - elapse_time <= 0 then return end
	local time_str = TimeUtil.FormatSecond(total_time - elapse_time, 2)
	self.use_time:SetValue(time_str)
end

function TempMountView:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function TempMountView:FlushBossModel(resid)
	if not self.boss_model then
		self.boss_model = RoleModel.New()
	end
	self.boss_model:SetDisplay(self.boss_display.ui3d_display)
	self.boss_model:SetMainAsset(ResPath.GetMountModel(resid))
end

function TempMountView:FlushSurperBossModel(resid)
	if not self.boss_model2 then
		self.boss_model2 = RoleModel.New()
	end
	self.boss_model2:SetDisplay(self.boss_display2.ui3d_display)
	self.boss_model2:SetMainAsset(ResPath.GetMountModel(resid))
end

function TempMountView:FlushThreeBoss(resid)
	if not self.boss_model3 then
		self.boss_model3 = RoleModel.New()
	end
	self.boss_model3:SetDisplay(self.boss_display3.ui3d_display)
	self.boss_model3:SetMainAsset(ResPath.GetMountModel(resid))
end

function TempMountView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(61)
end

function TempMountView:OnClickClose()
	self:Close()
end

function TempMountView:OnClickTakeOff()
	MountCtrl.Instance:SendUseMountImage(0, MOUNT_TYPE.TEMP_IMAGE)
	self.btn_on:SetValue(false)
	self:Close()
end

function TempMountView:OnClickSelect()
	local image_id = MountData.Instance:GetTempImgId()
	MountCtrl.Instance:SendUseMountImage(image_id, MOUNT_TYPE.TEMP_IMAGE)
	self.btn_on:SetValue(true)
	self:Close()
end

function TempMountView:OnClickUse(i)
	local temp_cfg = TempMountData.Instance:GetTempMountInfoByIndex(i)
	MountCtrl.Instance:SendUseMountImage(temp_cfg.temporary_image_id, MOUNT_TYPE.TEMP_IMAGE)
end
