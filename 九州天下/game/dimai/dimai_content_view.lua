DiMaiContentView = DiMaiContentView or BaseClass(BaseRender)

function DiMaiContentView:__init()
end

function DiMaiContentView:__delete()
	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	self.role_place_name = nil
	self.role_power_count = nil
	self.show_role_buff = nil
	self.role_buff_icon = nil
	self.show_red_point = nil

	UnityEngine.PlayerPrefs.DeleteKey("auto_buy_dimai_plus")
end

function DiMaiContentView:LoadCallBack()
	self.role_place_name = self:FindVariable("PlaceName")
	self.role_power_count = self:FindVariable("PowerCount")
	self.show_role_buff = self:FindVariable("ShowRoleBuff")
	self.role_buff_icon = self:FindVariable("RoleBuffIcon")
	self.show_red_point = self:FindVariable("ShowRedPoint")

	self:ListenEvent("OnClickTarget", BindTool.Bind(self.OnClickTarget, self))
	self:ListenEvent("OnClickRoleBuff", BindTool.Bind(self.OnClickRoleBuff, self))
	self:ListenEvent("OnClickCampBuff", BindTool.Bind(self.OnClickCampBuff, self))
	self:ListenEvent("OnClickPlus", BindTool.Bind(self.OnClickPlus, self))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.DiMaiTask)
end

-- 红点回调
function DiMaiContentView:RemindChangeCallBack(remind_name, num)
    if RemindName.DiMaiTask == remind_name then
    	if self.show_red_point then
        	self.show_red_point:SetValue(num > 0)
        end
    end
end

function DiMaiContentView:OpenCallBack()
	DiMaiCtrl.Instance:SendReqDimaiOpera(DIMAI_OPERA_TYPE.DIMAI_OPERA_TYPE_ROLE_INFO, 0, 0)
end

function DiMaiContentView:OnFlush()
	local other_cfg = DiMaiData.Instance:GetDiMaiOtherCfg()
	local role_dimai_info = DiMaiData.Instance:GetRoleDimaiInfo()
	if other_cfg and role_dimai_info then
		local dimai_info = role_dimai_info.dimai_info

		local day_count = DiMaiData.Instance:GetDiMaiChallengeCount()
		local challenge_times = other_cfg.challenge_times_limit + role_dimai_info.dimai_buy_times - day_count
		self.role_power_count:SetValue(ToColorStr(challenge_times, challenge_times > 0 and COLOR.GREEN or COLOR.RED))

	 	local dimai_info_cfg = DiMaiData.Instance:GetDiMaiInfoCfg(dimai_info.layer, dimai_info.point)
		self.role_place_name:SetValue(dimai_info_cfg and dimai_info_cfg.dimai_name or Language.Common.ZanWu)

		self.show_role_buff:SetValue(dimai_info.layer >= 0)
		self.role_buff_icon:SetAsset(ResPath.GetDiMaiBuffIcon(dimai_info.layer >= 0 and dimai_info.layer or 0))

		DiMaiCtrl.Instance:SendReqDimaiOpera(DIMAI_OPERA_TYPE.DIMAI_OPERA_TYPE_DIMAI_INFO, DiMaiData.Instance:GetDiMaiLayer(), 0)
	end
end

function DiMaiContentView:OnClickTarget()
	TipsCtrl.Instance:OpenDiMaiTargetTaskTip()

	ClickOnceRemindList[RemindName.DiMaiTask] = 0
	RemindManager.Instance:CreateIntervalRemindTimer(RemindName.DiMaiTask)
end

function DiMaiContentView:OnClickRoleBuff()
	local dimai_info = DiMaiData.Instance:GetRoleDimaiInfo().dimai_info
	if not dimai_info then return end
	if dimai_info.layer >= 0 then
		TipsCtrl.Instance:OpenDiMaiRoleBuffTip(dimai_info)
	else
		TipsCtrl.Instance:ShowReminding(Language.QiangDiMai.NoBuff)
	end
end

function DiMaiContentView:OnClickCampBuff()
	self:OpenCallBack()
	local camp_info = DiMaiData.Instance:GetRoleDimaiInfo().camp_dimai_list
	if not camp_info then return end
	TipsCtrl.Instance:OpenDiMaiCampBuffTip(camp_info)
end

function DiMaiContentView:OnClickPlus()
	local buy_times = DiMaiData.Instance:GetRoleDimaiInfo().dimai_buy_times
	if buy_times then
		local buy_times_cfg = DiMaiData.Instance:GetDiMaiBuyTimesCfg(buy_times)
		if buy_times_cfg then
			if buy_times == buy_times_cfg.cur_buy_times then
				local ok_callback = function ()
					DiMaiCtrl.Instance:SendReqDimaiOpera(DIMAI_OPERA_TYPE.DIMAI_OPERA_TYPE_BUY_TIMES, 0, 0)
				end

				local gold = buy_times_cfg.need_gold > 0 and buy_times_cfg.need_gold or buy_times_cfg.need_bind_gold
				local str = buy_times_cfg.need_gold > 0 and Language.QiangDiMai.UsedGoldBuyRemind or Language.QiangDiMai.UsedBindGoldBuyRemind
				
				if UnityEngine.PlayerPrefs.GetInt("auto_buy_dimai_plus") == 1 then
					ok_callback()
				else
					TipsCtrl.Instance:ShowCommonTip(ok_callback, nil, string.format(str, gold), nil, nil, true, false, "auto_buy_dimai_plus")
				end
			end
		else
			TipsCtrl.Instance:ShowReminding(Language.QiangDiMai.BuyTimesMax)
		end
	end
end

function DiMaiContentView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(215)
end