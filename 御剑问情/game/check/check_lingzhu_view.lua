CheckLingZhu = CheckLingZhu or BaseClass(BaseRender)

function CheckLingZhu:__init(instance)
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
	self.zhan_li = self:FindVariable("zhan_li")
	self.name_text = self:FindVariable("name_text")
	self.show_grade = self:FindVariable("show_grade")
	self.quality = self:FindVariable("QualityBG")

	self.prefab_preload_id = 0

	self.display = self:FindObj("display")
	self.model = RoleModel.New("lingzhu_panel")
	self.model:SetDisplay(self.display.ui3d_display)
end

function CheckLingZhu:__delete()
	self.data = nil

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
end

function CheckLingZhu:OnFlush()
 	if self.data then
 		self.zhan_li:SetValue(self.data.capability)
 		if self.data.grade == 0 then
 			return
 		end
 		self.show_grade:SetValue(true)
 		self.show_name:SetValue(true)
 		local temp_grade_info = LingZhuData.Instance:GetLingZhuGradeCfgInfoByGrade(self.data.grade)
 		if temp_grade_info then
 			local name = ""
 			local image_info = LingZhuData.Instance:GetLingZhuImageCfgInfoByImageId(temp_grade_info.image_id)
 			if nil ~= image_info then
				name = ToColorStr(image_info.image_name, SOUL_NAME_COLOR[image_info.colour])
			end
			self.step:SetValue(temp_grade_info.gradename)
 			self.name_text:SetValue(name)
 			self.shengming:SetValue(temp_grade_info.maxhp)
			self.gongji:SetValue(temp_grade_info.gongji)
			self.fangyu:SetValue(temp_grade_info.fangyu)
			self.mingzhong:SetValue(temp_grade_info.mingzhong)
			self.shanbi:SetValue(temp_grade_info.shanbi)
			self.baoji:SetValue(temp_grade_info.baoji)
			self.kangbao:SetValue(temp_grade_info.jianren)
 		end
 		self:SetModle(self.data.grade)
 	end
end

function CheckLingZhu:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.lingzhu_attr then
		self.data = check_attr.lingzhu_attr
		self:Flush()
	end
end

function CheckLingZhu:SetModle(grade)
	-- 对应等级数据
	local grade_info = LingZhuData.Instance:GetLingZhuGradeCfgInfoByGrade(grade)
	if nil == grade_info then
		return
	end

	--对应资源数据
	local image_info = LingZhuData.Instance:GetLingZhuImageCfgInfoByImageId(grade_info.image_id)
	if nil == image_info then
		return
	end

	local role_info = CheckData.Instance:GetRoleInfo()

	self.model:ResetRotation()
	local bundle, asset = ResPath.GetLingZhuModel(image_info.res_id, true)
	self.model:SetMainAsset(bundle, asset)
end