CheckHaloView = CheckHaloView or BaseClass(BaseRender)
function CheckHaloView:__init(instance)
	self.gongji = self:FindVariable("gongji")
	self.fangyu = self:FindVariable("fangyu")
	self.shengming = self:FindVariable("shengming")
	self.mingzhong = self:FindVariable("mingzhong")
	self.shanbi = self:FindVariable("shanbi")
	self.baoji = self:FindVariable("baoji")
	self.kangbao = self:FindVariable("kangbao")
	self.zengshang = self:FindVariable("zengshang")
	self.mianshang = self:FindVariable("mianshang")
	self.grade = self:FindVariable("step")
	self.zhan_li = self:FindVariable("zhan_li")
	self.name = self:FindVariable("name")
	self.name_text = self:FindVariable("name_text")
	self.show_name = self:FindVariable("show_name")
	self.show_grade = self:FindVariable("show_grade")
	self.quality = self:FindVariable("QualityBG")
end

function CheckHaloView:__delete()
	self.halo_attr = nil
end

function CheckHaloView:OnFlush()
	if self.halo_attr then
		self.gongji:SetValue(self.halo_attr.gong_ji)
		self.fangyu:SetValue(self.halo_attr.fang_yu)
		self.shengming:SetValue(self.halo_attr.max_hp)
		self.mingzhong:SetValue(self.halo_attr.ming_zhong)
		self.shanbi:SetValue(self.halo_attr.shan_bi)
		self.baoji:SetValue(self.halo_attr.bao_ji)
		self.kangbao:SetValue(self.halo_attr.jian_ren)
		self.zengshang:SetValue(self.halo_attr.per_pofang)
		self.mianshang:SetValue(self.halo_attr.per_mianshang)
		self.grade:SetValue(CheckData.Instance:GetGradeName(self.halo_attr.client_grade))
		self.zhan_li:SetValue(self.halo_attr.capability)
		local grade = self.halo_attr.client_grade + 1
		if self.halo_attr.used_imageid == 0 then
			self.show_name:SetValue(false)
		else
			self.show_name:SetValue(true)
			local image_id = HaloData.Instance:GetHaloGradeCfg(grade).image_id
			local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
			local halo_cfg = HaloData.Instance:GetHaloImageCfg(image_id)
			local str = halo_cfg ~= nil and halo_cfg.image_name or ""
			local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..str.."</color>"
			self.name_text:SetValue(name_str)
		end
		if self.halo_attr.client_grade == 0 then
			self.show_grade:SetValue(false)
		else
			self.show_grade:SetValue(true)
			local bundle, asset = nil, nil
			if math.floor(grade / 3 + 1) >= 5 then
				 bundle, asset = ResPath.GetHaloGradeQualityBG(5)
			else
				 bundle, asset = ResPath.GetHaloGradeQualityBG(math.floor(grade / 3 + 1))
			end
			self.quality:SetAsset(bundle, asset)
		end
		self:SetModle()
	end
end

function CheckHaloView:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.halo_attr then
		self.halo_attr = check_attr.halo_attr
		self:Flush()
	end
end

function CheckHaloView:SetModle()
	local call_back = function(model, obj)
		local cfg = ConfigManager.Instance:GetAutoConfig("model_display_parameter_auto").role_model[001001][DISPLAY_PANEL.RANK]
		if obj then
			if cfg then
				obj.transform.localPosition = cfg.position
				obj.transform.localRotation = Quaternion.Euler(cfg.rotation.x, cfg.rotation.y, cfg.rotation.z)
				obj.transform.localScale = cfg.scale
			else
				obj.transform.localPosition = Vector3(0, 0, 0)
				obj.transform.localRotation = Quaternion.Euler(0, 0, 0)
				obj.transform.localScale = Vector3(1, 1, 1)
			end
		end
	end
	UIScene:SetModelLoadCallBack(call_back)
	local role_info = CheckData.Instance:GetRoleInfo()
	UIScene:SetRoleModelResInfo(role_info, 1, true, true, false, true)
	UIScene:SetActionEnable(false)
end


