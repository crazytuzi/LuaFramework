
WingDialogView = WingDialogView or BaseClass(XuiBaseView)
function WingDialogView:__init()
	self:SetModal(true)
	self.def_index = 1

	self.config_tab = {
		{"wing_ui_cfg", 3, {0}},
	}
	self.cd = 0
end

function WingDialogView:__delete()
end

function WingDialogView:ReleaseCallBack()
	if self.wing_clear_cd then
		GlobalTimerQuest:CancelQuest(self.wing_clear_cd)
		self.wing_clear_cd = nil
	end
end

function WingDialogView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self.node_t_list.btn_OK.node:addClickEventListener(BindTool.Bind(self.OnOkhandler, self))
		self.node_t_list.btn_cancel.node:addClickEventListener(BindTool.Bind(self.OnCancelhandler, self))

	end
end

function WingDialogView:SetCancelFunc(cancel_func)
	self.cancel_func = cancel_func
end

function WingDialogView:ShowIndexCallBack(index)
	local wind_star = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_EXP)
	local wing_cfg, grade = WingData.GetWingUpLevelCfg(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_ID))
	local startLv_cfg = nil
	if wing_cfg then
		startLv_cfg = wing_cfg.startLv[wind_star + 1]
	end
	if startLv_cfg then
		local per = math.min(WingData.Instance:GetWingStar() / startLv_cfg[1] * 100, 100)

		local prog = XUI.CreateLoadingBar(250, 251.5, ResPath.GetCommon("prog_104_progress"), XUI.IS_PLIST, nil, true, 380, 23, cc.rect(20, 3, 5, 5))
		--XUI.CreateLoadingBar(190, 75, ResPath.GetCommon("prog_104_progress"), true, ResPath.GetCommon("prog_104"))
		prog:setScaleX(0.85)
		prog:setLocalZOrder(5)
		self.node_t_list.layout_wing_dialog.node:addChild(prog)
		self.wing_progressbar = ProgressBar.New()
		self.wing_progressbar:SetView(prog)
		self.wing_progressbar:SetTailEffect(991, nil, true)
		self.wing_progressbar:SetEffectOffsetX(-20)
		self.wing_progressbar:SetPercent(per)

		--self.node_t_list.prog_clear_val.node:setScaleX(0.9)
		--self.node_t_list.prog_clear_val.node:setPercent(per)
	end
	local now_time = TimeCtrl.Instance:GetServerTime()
	local time_t = os.date("*t", now_time)
	local target_time = os.time{year = time_t.year, month = time_t.month, day = time_t.day + (time_t.hour >= 6 and 1 or 0), hour=6, min = 0, sec=0}
	self.cd = target_time - now_time + 1
	self:UpdateClearCd()
	if self.wing_clear_cd then
		GlobalTimerQuest:CancelQuest(self.wing_clear_cd)
	end
	self.wing_clear_cd = GlobalTimerQuest:AddTimesTimer(BindTool.Bind1(self.UpdateClearCd, self), 1, target_time - now_time)
end
	
function WingDialogView:UpdateClearCd()
	self.cd = self.cd - 1
	if self.cd <= 0 then
		if self.wing_clear_cd then
			GlobalTimerQuest:CancelQuest(self.wing_clear_cd)
		end
		self:Close()
	end
	local format_time = TimeUtil.FormatSecond(self.cd, 3)
	self.node_t_list.lbl_clear_cd.node:setString(format_time)
end
	
function WingDialogView:OpenCallBack()

end

function WingDialogView:CloseCallBack()
	self.cancel_func = nil
end

function WingDialogView:OnFlush(param_t, index)
	
end

function WingDialogView:OnOkhandler()
	self:Close()
end

function WingDialogView:OnCancelhandler()
	if self.cancel_func then
		self.cancel_func()
	end
	self:Close()
end