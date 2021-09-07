CheckWingView = CheckWingView or BaseClass(BaseRender)

function CheckWingView:__init(instance)
	self.gongji = self:FindVariable("gongji")
	self.fangyu = self:FindVariable("fangyu")
	self.shengming = self:FindVariable("shengming")
	self.mingzhong = self:FindVariable("mingzhong")
	self.shanbi = self:FindVariable("shanbi")
	self.baoji = self:FindVariable("baoji")
	self.kangbao = self:FindVariable("kangbao")
	self.zengshang = self:FindVariable("zengshang")
	self.mianshang = self:FindVariable("mianshang")
	self.show_name = self:FindVariable("show_name")
	self.name = self:FindVariable("name")
	self.step = self:FindVariable("step")
	self.level = self:FindVariable("level")
	self.zhan_li = self:FindVariable("zhan_li")
	self.name_text = self:FindVariable("name_text")
	self.show_grade = self:FindVariable("show_grade")
	self.quality = self:FindVariable("QualityBG")
end

function CheckWingView:__delete()
	self.wing_attr = nil
end

function CheckWingView:OnFlush()
	if self.wing_attr then
		self.gongji:SetValue(self.wing_attr.gong_ji)
		self.fangyu:SetValue(self.wing_attr.fang_yu)
		self.shengming:SetValue(self.wing_attr.max_hp)
		self.mingzhong:SetValue(self.wing_attr.ming_zhong)
		self.shanbi:SetValue(self.wing_attr.shan_bi)
		self.baoji:SetValue(self.wing_attr.bao_ji)
		self.kangbao:SetValue(self.wing_attr.jian_ren)
		self.zengshang:SetValue(self.wing_attr.per_pofang)
		self.mianshang:SetValue(self.wing_attr.per_mianshang)
		self.step:SetValue(CheckData.Instance:GetGradeName(self.wing_attr.client_grade))
		self.zhan_li:SetValue(self.wing_attr.capability)
		local grade = self.wing_attr.client_grade + 1
		if self.wing_attr.used_imageid == 0 then
			self.show_name:SetValue(false)
		else
			self.show_name:SetValue(true)
			local used_imageid = self.wing_attr.used_imageid
			if used_imageid > ADVANCE_IMAGE_ID_CHAZHI then
				used_imageid = used_imageid - ADVANCE_IMAGE_ID_CHAZHI
			end
			local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
			local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..WingData.Instance:GetImageListInfo(used_imageid).image_name.."</color>"
			self.name_text:SetValue(name_str)
		end

		if self.wing_attr.client_grade == 0 then
			self.show_grade:SetValue(false)
		else
			self.show_grade:SetValue(true)
			local bundle, asset = nil, nil
			if math.floor(grade / 3 + 1) >= 5 then
				 bundle, asset = ResPath.GetWingGradeQualityBG(5)
			else
				 bundle, asset = ResPath.GetWingGradeQualityBG(math.floor(grade / 3 + 1))
			end
			self.quality:SetAsset(bundle, asset)
		end
		self:SetModle()
	end
end

function CheckWingView:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.wing_attr then
		self.wing_attr = check_attr.wing_attr
		self:Flush()
	end
end

function CheckWingView:SetModle()
	local role_info = CheckData.Instance:GetRoleInfo()
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
	UIScene:SetRoleModelResInfo(role_info, 1, true, false, true, true)
	UIScene:SetActionEnable(false)
end
