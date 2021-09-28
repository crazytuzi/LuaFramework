CheckMountView = CheckMountView or BaseClass(BaseRender)
local DISPLAYNAME = {
	[7005001] = "player_check_mount_panel_1"
}

function CheckMountView:__init(instance)
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

	self.display = self:FindObj("display")
	self.model = RoleModel.New("player_check_mount_panel")
	self.model:SetDisplay(self.display.ui3d_display)
end

function CheckMountView:__delete()
	self.mount_attr = nil

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
end

function CheckMountView:OnFlush()
	if self.mount_attr then
		local mount_attr = self.mount_attr
		self.gongji:SetValue(self.mount_attr.gong_ji)
		self.fangyu:SetValue(self.mount_attr.fang_yu)
		self.shengming:SetValue(self.mount_attr.max_hp)
		self.mingzhong:SetValue(self.mount_attr.ming_zhong)
		self.shanbi:SetValue(self.mount_attr.shan_bi)
		self.baoji:SetValue(self.mount_attr.bao_ji)
		self.kangbao:SetValue(self.mount_attr.jian_ren)
		self.zengshang:SetValue(self.mount_attr.per_pofang)
		self.mianshang:SetValue(self.mount_attr.per_mianshang)
		self.step:SetValue(CheckData.Instance:GetGradeName(self.mount_attr.client_grade))
		self.zhan_li:SetValue(self.mount_attr.capability)
		local grade = self.mount_attr.client_grade + 1
		local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
		local used_imageid = self.mount_attr.used_imageid
		if used_imageid == 0 then
			self.show_name:SetValue(false)
		else
			self.show_name:SetValue(true)
			local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..MountData.Instance:GetMountCfg(used_imageid).image_name.."</color>"
			self.name_text:SetValue(name_str)
		end

		if self.mount_attr.client_grade == 0 then
			self.show_grade:SetValue(false)
		else
			self.show_grade:SetValue(true)
			local bundle, asset = nil, nil
			if math.floor(grade / 3 + 1) >= 5 then
				 bundle, asset = ResPath.GetMountGradeQualityBG(5)
			else
				 bundle, asset = ResPath.GetMountGradeQualityBG(math.floor(grade / 3 + 1))
			end
			self.quality:SetAsset(bundle, asset)
		end
		self:SetModle()
	end
end

function CheckMountView:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.mount_attr then
		self.mount_attr = check_attr.mount_attr
		self:Flush()
	end
end

function CheckMountView:SetModle()
	if self.mount_attr.client_grade + 1 ~= 0 then
		local mount_res_id = MountData.Instance:GetMountCfg(self.mount_attr.used_imageid).res_id
		-- local call_back = function(model, obj)
		-- 	local cfg = model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.MOUNT], mount_res_id, DISPLAY_PANEL.RANK)
		-- 	if obj then
		-- 		if cfg then
		-- 			obj.transform.localPosition = cfg.position
		-- 			obj.transform.localRotation = Quaternion.Euler(cfg.rotation.x, cfg.rotation.y, cfg.rotation.z)
		-- 			obj.transform.localScale = cfg.scale
		-- 		else
		-- 			obj.transform.localPosition = Vector3(0, 0, 0)
		-- 			obj.transform.localRotation = Quaternion.Euler(0, 0, 0)
		-- 			obj.transform.localScale = Vector3(1, 1, 1)
		-- 		end
		-- 	end
		-- 	model:SetTrigger("rest")
		-- end
		-- UIScene:SetModelLoadCallBack(call_back)

		-- local bundle_list = {[SceneObjPart.Main] = bundle}
		-- local asset_list = {[SceneObjPart.Main] = asset}
		-- UIScene:ModelBundle(bundle_list, asset_list)
		local display_name = "player_check_mount_panel"
		for k,v in pairs(DISPLAYNAME) do
			if mount_res_id == k then
				display_name = v
				break
			end
		end
		self.model:SetPanelName(display_name)
		local bundle, asset = ResPath.GetMountModel(mount_res_id)
		self.model:SetMainAsset(bundle, asset)
		-- self.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.MOUNT], asset, DISPLAY_PANEL.RANK)
	end
end