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

	self.display = self:FindObj("display")
	self.model = RoleModel.New("player_check_halo_panel")
	self.model:SetDisplay(self.display.ui3d_display)
end

function CheckHaloView:__delete()
	self.halo_attr = nil

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
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
			local halo_grade_cfg = HaloData.Instance:GetHaloGradeCfg(grade)
			if halo_grade_cfg ~= nil then
				local image_id = halo_grade_cfg.image_id
				local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
				local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..HaloData.Instance:GetHaloImageCfg(image_id)[image_id].image_name.."</color>"
				self.name_text:SetValue(name_str)
			end
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
	local role_info = CheckData.Instance:GetRoleInfo()
	self.model:SetModelResInfo(role_info, true, true, false, true)
end


