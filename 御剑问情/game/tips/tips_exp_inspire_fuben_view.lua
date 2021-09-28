TipsExpInSprieFuBenView = TipsExpInSprieFuBenView or BaseClass(BaseView)

function TipsExpInSprieFuBenView:__init()
	self.ui_config = {"uis/views/tips/expviewtips_prefab", "ExpInspireFuBenTips"}
	self.view_layer = UiLayer.Pop
end

function TipsExpInSprieFuBenView:__delete()

end

function TipsExpInSprieFuBenView:LoadCallBack()
	self.damage_text = self:FindVariable("damage_text")
	self.money_text = self:FindVariable("money_text")
	self.before_one = self:FindVariable("before_one")
	self.limit = self:FindVariable("Limit")
	self.is_bind = self:FindVariable("is_bind")		--图标是否为绑元

	self:ListenEvent("IsBuy", BindTool.Bind(self.OnClickIsBuy, self))
	self:ListenEvent("Close", BindTool.Bind(self.ClickClose, self))
end

function TipsExpInSprieFuBenView:ReleaseCallBack()
	-- 清理变量和对象
	self.damage_text = nil
	self.money_text = nil
	self.before_one = nil
	self.limit = nil
	self.is_bind = nil
end

function TipsExpInSprieFuBenView:OpenCallBack()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type and scene_type == SceneType.ChaosWar then	-- 一战到底
		self.is_bind:SetValue(false)
	else
		self.is_bind:SetValue(true)
	end
	self:Flush()
end

function TipsExpInSprieFuBenView:OnFlush()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.ChaosWar then	-- 一战到底
		self:SetYiZhanDaoDiText()
	else
		local cfg = FuBenData.Instance:GetExpFBCfg().exp_other_cfg[1]
		self.damage_text:SetValue(cfg.buff_add_gongji_per / 100)
		self.money_text:SetValue(cfg.buff_cost)
		self.before_one:SetValue(FuBenData.Instance:GetInSpireDamage())
		self.limit:SetValue(100)
	end
end

function TipsExpInSprieFuBenView:SetYiZhanDaoDiText()
	local user_info = YiZhanDaoDiData.Instance:GetYiZhanDaoDiUserInfo()
	local other_cfg = YiZhanDaoDiData.Instance:GetOtherCfg() or {}

	self.before_one:SetValue(user_info.gongji_guwu_per or 0)
	self.damage_text:SetValue(other_cfg.gongji_guwu_add_per or 0)
	self.money_text:SetValue(other_cfg.gongji_guwu_gold or 0)
	self.limit:SetValue(other_cfg.gongji_guwu_max_per or 0)
end

function TipsExpInSprieFuBenView:ClickClose()
	self:Close()
end

function TipsExpInSprieFuBenView:OnClickBuyInYiZhanDaoDiScene()
	local user_info = YiZhanDaoDiData.Instance:GetYiZhanDaoDiUserInfo()
	if nil == next(user_info) then return end

	local other_cfg = YiZhanDaoDiData.Instance:GetOtherCfg()
	if nil == other_cfg then return end

	if user_info.gongji_guwu_per >= other_cfg.gongji_guwu_max_per then
		TipsCtrl.Instance:ShowSystemMsg(Language.YiZhanDaoDi.MaxGuWu)
		return
	end

	YiZhanDaoDiCtrl.Instance:SendYiZhanDaoDiGuwuReq(YIZHANDAODI_GUWU_TYPE.YIZHANDAODI_GUWU_TYPE_GONGJI)
end

function TipsExpInSprieFuBenView:OnClickIsBuy()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.ChaosWar then	-- 一战到底
		self:OnClickBuyInYiZhanDaoDiScene()
	else
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
end

function TipsExpInSprieFuBenView:IsGuWuFull()
	local user_info = YiZhanDaoDiData.Instance:GetYiZhanDaoDiUserInfo()
	if nil == next(user_info) then return end

	local other_cfg = YiZhanDaoDiData.Instance:GetOtherCfg()
	if nil == other_cfg then return end
	return user_info.gongji_guwu_per >= other_cfg.gongji_guwu_max_per
end
