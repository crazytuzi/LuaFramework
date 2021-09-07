-- 国家战事（气运界面）
CampQiYunView = CampQiYunView or BaseClass(BaseRender)

CampQiYunView.QiYunTaModelRes = {
	7034001,
	7035001,
	7036001
}

function CampQiYunView:__init()
	self.lbl_camp_title_name = {}
	self.model_display = {}
	self.role_model = {}
	self.is_show_eff = {}
end

function CampQiYunView:__delete()
	if self.role_model then
		for k,v in pairs(self.role_model) do
			v:DeleteMe()
		end
	end
	self.role_model = {}
end

function CampQiYunView:LoadCallBack(instance)
	self.is_fate_truce = self:FindVariable("IsFateTruce")
	self.lbl_fate_truce_text = self:FindVariable("lbl_fate_truce_text")
	for i = 1, GameEnum.MAX_CAMP_NUM do
		self.lbl_camp_title_name[i] = self:FindVariable("CampTitleName" .. i)
		self.is_show_eff[i] = self:FindVariable("ShowEff" .. i)
	end

	for i = 1, GameEnum.MAX_CAMP_NUM do
		self:ListenEvent("OnModelDisplay" .. i, BindTool.Bind(self.OnModelDisplayHandler, self))
		self.model_display[i] = self:FindObj("Display" .. i)
		if nil == self.role_model[i] then
			self.role_model[i] = RoleModel.New("camp_qi_yun_view")
			self.role_model[i]:SetDisplay(self.model_display[i].ui3d_display)
		
			local bundle, asset = ResPath.GetMonsterModel(CampQiYunView.QiYunTaModelRes[i])
			self.role_model[i]:SetMainAsset(bundle, asset)
		end
	end
end

function CampQiYunView:OnFlush(param_list)
	local my_camp = PlayerData.Instance.role_vo.camp
	local fate_tower_status_info = CampData.Instance:GetCampQiyunTowerStatus()

	for i = 1, GameEnum.MAX_CAMP_NUM do
		local item_list = fate_tower_status_info.item_list[i]
		if item_list then
			if my_camp == i then
				self.lbl_camp_title_name[i]:SetValue(Language.Camp.FateBottomBtnText[1])
			elseif item_list.is_alive == 1 then
				self.lbl_camp_title_name[i]:SetValue(Language.Camp.FateBottomBtnText[2])
			else
				self.lbl_camp_title_name[i]:SetValue(Language.Camp.FateBottomBtnText[3])
			end
		end

		local item_list = fate_tower_status_info.item_list[i]
		if item_list then
			if item_list.is_alive == 0 then
				self.role_model[i]:SetInteger("status", ActionStatus.Die)
			end
			self.is_show_eff[i]:SetValue(item_list.is_alive == 0)
		end
	end

	if fate_tower_status_info.is_xiuzhan == 1 then
		self.is_fate_truce:SetValue(true)
		local campwar_fate_other_cfg = NationalWarfareData.Instance:GetCampWarFateOtherCfg()
		if campwar_fate_other_cfg.wudi_time then
			local wudi_time = campwar_fate_other_cfg.wudi_time
			local hour, min = math.floor(wudi_time / 100), string.format("%02d", wudi_time % 100)
			self.lbl_fate_truce_text:SetValue(string.format(Language.Camp.FateTruceText, hour .. ":" .. min))
		end
	else
		self.is_fate_truce:SetValue(false)
	end
end

function CampQiYunView:OnModelDisplayHandler()
	ViewManager.Instance:Close(ViewName.NationalWarfare)
	ViewManager.Instance:Open(ViewName.Camp, TabIndex.camp_fate)
end
