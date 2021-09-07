KuaFu1v1LevelUpView = KuaFu1v1LevelUpView or BaseClass(BaseView)

function KuaFu1v1LevelUpView:__init(instance)
	self.ui_config = {"uis/views/kuafu1v1","KuaFu1v1LevelUp"}
	self.view_layer = UiLayer.MainUIHigh
	self.play_audio = true
	self:SetMaskBg()
end

function KuaFu1v1LevelUpView:__delete()

end

function KuaFu1v1LevelUpView:LoadCallBack()
	self.fightpower = self:FindVariable("FightPower")
	self.ranktype = self:FindVariable("RankType")
	self.rankindex = self:FindVariable("RankIndex")
	self.display = self:FindObj("Display")
	self.model_view = RoleModel.New("kf1v1_level_model")
	self.model_view:SetDisplay(self.display.ui3d_display)

	self:ListenEvent("OnClickContinue",BindTool.Bind(self.OnClickContinue, self))
end

function KuaFu1v1LevelUpView:ReleaseCallBack()
	self.fightpower = nil
	self.ranktype = nil
	self.rankindex = nil
	self.display = nil

	if nil ~= self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end
end

function KuaFu1v1LevelUpView:ShowIndexCallBack()
	self:Flush()
end

function KuaFu1v1LevelUpView:OnFlush()
	local role_info = KuaFu1v1Data.Instance:GetRoleData()
	if nil == role_info then
		return
	end

	local current_config = KuaFu1v1Data.Instance:GetRankByScore(role_info.cross_score_1v1)
	if nil == current_config then
		return
	end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.fightpower:SetValue(vo.capability)
	local bundle, asset = ResPath.GetKuaFu1v1Image("rank_type_" .. current_config.rank_str_res)
	self.ranktype:SetAsset(bundle, asset)

	bundle, asset = ResPath.GetKuaFu1v1Image("rank_index_" .. current_config.rank_index)
	self.rankindex:SetAsset(bundle, asset)

	local main_role = Scene.Instance:GetMainRole()
	self.model_view:SetRoleResid(main_role:GetRoleResId())
end

function KuaFu1v1LevelUpView:OnClickContinue()
	self:Close()
	local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.KF_ONEVONE)
	if act_info ~= nil and act_info.status == ACTIVITY_STATUS.OPEN then
		KuaFu1v1Data.Instance:SetIsOutFrom1v1Scene(true)
		ViewManager.Instance:Open(ViewName.KuaFu1v1)
	else
		TipsCtrl.Instance:ShowReminding(Language.Kuafu1V1.MatchFailTxt2)
	end
end