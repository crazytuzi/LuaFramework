OpenActZhiZunHuiYuan = OpenActZhiZunHuiYuan or BaseClass(BaseRender)

function OpenActZhiZunHuiYuan:__init()
	self:ListenEvent("ClickToRechage", BindTool.Bind(self.ClickToRechage, self))
	self:ListenEvent("ClickCanRechage", BindTool.Bind(self.OnClickRecharge, self))
	self.has_spec_recharge = self:FindVariable("HasSpecRecharge")
	self.show_red_point = self:FindVariable("show_red_point")

	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if cur_day > -1 then
		UnityEngine.PlayerPrefs.SetInt(main_role_id .. "zhizunhuiyuanred", cur_day)
		RemindManager.Instance:Fire(RemindName.KaiFu)
	end
end

function OpenActZhiZunHuiYuan:__delete()
	self.hasspecrecharge = nil
	self.show_red_point = nil
end

function OpenActZhiZunHuiYuan:OpenCallBack()
	self:Flush()
	KaifuActivityCtrl.Instance:FlushZhiZunHuiYuan()
end

function OpenActZhiZunHuiYuan:Flush()
	local is_special_member = RechargeData.Instance:HasBuy7DayChongZhi()
	local is_fetch = RechargeData.Instance:GetChongZhi7DayRewardIsFetch()
	self.has_spec_recharge:SetValue(is_special_member)
	self.show_red_point:SetValue(is_fetch > 0)
end

function OpenActZhiZunHuiYuan:FlushTotalConsume()
end

function OpenActZhiZunHuiYuan:ClickToRechage()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function OpenActZhiZunHuiYuan:OnClickRecharge()
	RechargeCtrl.Instance:SendChongZhi7DayFetchReward()
end