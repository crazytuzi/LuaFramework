TipsExpInSprieFuBenView = TipsExpInSprieFuBenView or BaseClass(BaseView)

function TipsExpInSprieFuBenView:__init()
	self.ui_config = {"uis/views/tips/expviewtips", "ExpInspireFuBenTips"}
	self.view_layer = UiLayer.Pop
end

function TipsExpInSprieFuBenView:__delete()

end

function TipsExpInSprieFuBenView:LoadCallBack()
	self.damage_text = self:FindVariable("damage_text")
	self.money_text = self:FindVariable("money_text")
	self.before_one = self:FindVariable("before_one")
	self:ListenEvent("IsBuy", BindTool.Bind(self.OnClickIsBuy, self))
	self:ListenEvent("Close", BindTool.Bind(self.ClickClose, self))
end

function TipsExpInSprieFuBenView:ReleaseCallBack()
	-- 清理变量和对象
	self.damage_text = nil
	self.money_text = nil
	self.before_one = nil
end

function TipsExpInSprieFuBenView:OpenCallBack()
	self:Flush()
end

function TipsExpInSprieFuBenView:OnFlush()
	local cfg = FuBenData.Instance:GetExpFBCfg().exp_other_cfg[1]
	self.damage_text:SetValue(cfg.buff_add_gongji_per / 100)
	self.money_text:SetValue(cfg.buff_cost)
	self.before_one:SetValue(FuBenData.Instance:GetInSpireDamage())
end

function TipsExpInSprieFuBenView:ClickClose()
	self:Close()
end

function TipsExpInSprieFuBenView:OnClickIsBuy()
	local exp_fb_info = FuBenData.Instance:GetExpFBInfo()
	local max_guwu = FuBenData.Instance:GetExpFBCfg().exp_other_cfg[1].max_buff_time
	if exp_fb_info.guwu_times >= max_guwu then
		return TipsCtrl.Instance:ShowSystemMsg(Language.FB.InspireLimit)
	end
	local need_money = FuBenData.Instance:GetExpFBCfg().exp_other_cfg[1].buff_cost
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo.gold + vo.bind_gold >= need_money then
		FuBenCtrl.Instance:SendExpFbPayGuwu()
	else
		TipsCtrl.Instance:ShowLackDiamondView()
	end
end

