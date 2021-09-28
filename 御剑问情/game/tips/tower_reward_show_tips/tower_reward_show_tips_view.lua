TowerRewardInfoShowTips = TowerRewardInfoShowTips or BaseClass(BaseView)

local VIEW_STATE = {
	TOWER_MOJIE = 1,

}
function TowerRewardInfoShowTips:__init()
	self.ui_config = {"uis/views/tips/towermojieshowtips_prefab", "TowerRewardInfoShowTips"}
end

function TowerRewardInfoShowTips:__delete()

end

function TowerRewardInfoShowTips:LoadCallBack()
	self.info_image = self:FindVariable("info_image")
	self.desc = self:FindVariable("desc")

	self:ListenEvent("OnClickOK", BindTool.Bind(self.OnClickOK, self))
end

function TowerRewardInfoShowTips:ReleaseCallBack()
	self.info_image = nil
	self.desc = nil
end

function TowerRewardInfoShowTips:OpenCallBack()
	self.view_state = VIEW_STATE.TOWER_MOJIE
	self.ok_callback = function ()
		self:Close()
	end
end

function TowerRewardInfoShowTips:CloseCallBack()

end

function TowerRewardInfoShowTips:OnFlush(param_list)
	self:SetFlag(param_list)
	self:ConstructData()
	self:ShowIcon()
end

-----------------------显示处理---------------------

function TowerRewardInfoShowTips:SetFlag(param_list)
	for k,v in pairs(param_list) do
		if k == ViewName.FuBenTowerInfoView then
			self.view_state = VIEW_STATE.TOWER_MOJIE
			self.ok_callback = v.ok_callback
			return
		end
	end
end

function TowerRewardInfoShowTips:ConstructData()
	if self.view_state == VIEW_STATE.TOWER_MOJIE then
		local cfg = FuBenData.Instance:GetCurMojie()
		if cfg then
			self.skill_id = cfg.skill_id
			self.info_image_bundle, self.info_image_asset = ResPath.GetTowerMojieIcon(self.skill_id + 1)
			self.desc_value = FuBenData.Instance:GetSkillDesc(self.skill_id)
		else
			self:Close()
		end
	end
end

function TowerRewardInfoShowTips:ShowIcon()
	if CheckInvalid(self.info_image_bundle) or CheckInvalid(self.info_image_asset) then return end
	if self.view_state == VIEW_STATE.TOWER_MOJIE then
		self.info_image:SetAsset(self.info_image_bundle, self.info_image_asset)
		self.desc:SetValue(self.desc_value)
	end
end


----------------------点击事件--------------------

function TowerRewardInfoShowTips:OnClickOK()
	if self.view_state == VIEW_STATE.TOWER_MOJIE then
		self:ok_callback()
		self:Close()
	end
end