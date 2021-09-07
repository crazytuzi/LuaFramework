TipsCampTaBuildView = TipsCampTaBuildView or BaseClass(BaseView)
function TipsCampTaBuildView:__init()
	self.ui_config = {"uis/views/camp", "BuildTowerTip"}
	self.view_layer = UiLayer.Pop
	self:SetMaskBg()
end

function TipsCampTaBuildView:LoadCallBack()
	self.title_str = self:FindVariable("TowerName")
	self.desc_str = self:FindVariable("ToweDes")
	self.need_money = self:FindVariable("NeedMoney")
	self.tower_res = self:FindVariable("TowerImg")

	self:ListenEvent("OnClickConfirm", BindTool.Bind(self.OnClickOk, self))
	self:ListenEvent("OnClickCancel", BindTool.Bind(self.OnClickCancel, self))
end

function TipsCampTaBuildView:ReleaseCallBack()
	self.title_str = nil
	self.desc_str = nil
	self.need_money = nil
	self.tower_res = nil	
end

function TipsCampTaBuildView:SetData(seq)
	self.tower_seq = seq
	if not self:IsOpen() then
		self:Open()
	end
end

function TipsCampTaBuildView:CloseCallBack()
	self.tower_seq = nil
end

function TipsCampTaBuildView:OpenCallBack()
	self:Flush()
end

function TipsCampTaBuildView:OnClickOk()
	if self.tower_seq == nil then
		return
	end

	CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_NEIZHENG_MONSTER_SIEGE_BUILD_TOWER, self.tower_seq)
	self:Close()
end

function TipsCampTaBuildView:OnClickCancel()
	self:Close()
end

function TipsCampTaBuildView:OnFlush(param_t)
	if self.tower_seq == nil then
		return
	end

	local data = CampData.Instance:GetTowerCfgBySeq(self.tower_seq)
	if data == nil or next(data) == nil then
		return
	end

	if self.need_money ~= nil then
		self.need_money:SetValue(data.build_need_gold or 0)
	end

	if self.title_str ~= nil then
		local cfg = BossData.Instance:GetMonsterInfo(data.monster_id)
		self.title_str:SetValue(cfg.name or "")
	end

	if self.desc_str ~= nil then
		self.desc_str:SetValue(data.desc or "")
	end

	if self.tower_res ~= nil then
		self.tower_res:SetAsset(ResPath.GetCampRawRes("camp_tower_" .. data.tower_type or 0))
	end
end