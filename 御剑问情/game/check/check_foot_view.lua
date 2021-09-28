CheckFootView = CheckFootView or BaseClass(BaseRender)

function CheckFootView:__init(instance)
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
	self.model_view = RoleModel.New("player_check_foot_panel")
	self.model_view:SetDisplay(self.display.ui3d_display)
end

function CheckFootView:__delete()
	self.foot_attr = nil

	if self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end
end

function CheckFootView:OnFlush()
 	if self.foot_attr then
 		local foot_cfg = FootData.Instance:GetFootStarLevelCfg(self.foot_attr.star_level)
 		if foot_cfg then
	 		self.gongji:SetValue(foot_cfg.gongji)
			self.fangyu:SetValue(foot_cfg.fangyu)
			self.shengming:SetValue(foot_cfg.maxhp)
			self.mingzhong:SetValue(foot_cfg.mingzhong)
			self.shanbi:SetValue(foot_cfg.shanbi)
			self.baoji:SetValue(foot_cfg.baoji)
			self.kangbao:SetValue(foot_cfg.jianren)
		end
		-- self.zengshang:SetValue(self.foot_attr.per_pofang)
		-- self.mianshang:SetValue(self.foot_attr.grade)
		self.step:SetValue(CheckData.Instance:GetGradeName(self.foot_attr.grade))
		self.zhan_li:SetValue(self.foot_attr.capability)
		local grade = self.foot_attr.grade + 1
		local used_imageid = self.foot_attr.used_imageid
		local color = (self.foot_attr.used_imageid / 3 + 1) >= 5 and 5 or math.floor(self.foot_attr.used_imageid / 3 + 1)
		local name_str = ""
		if self.foot_attr.used_imageid == 0 then
			self.show_name:SetValue(false)
			self.name_text:SetValue("零阶")
		else
			self.show_name:SetValue(true)
			if used_imageid > ADVANCE_IMAGE_ID_CHAZHI then
				used_imageid = used_imageid - ADVANCE_IMAGE_ID_CHAZHI
				name_str = "<color="..SOUL_NAME_COLOR[color]..">"..FootData.Instance:GetSpecialImageCfg(used_imageid).image_name.."</color>"
			else
				name_str = "<color="..SOUL_NAME_COLOR[color]..">"..FootData.Instance:GetImageListInfo(used_imageid).image_name.."</color>"
			end
			self.name_text:SetValue(name_str)
		end

		if self.foot_attr.grade == 0 then
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

function CheckFootView:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.foot_attr then
		self.foot_attr = check_attr.foot_attr
		self:Flush()
	end
end

function CheckFootView:SetModle()
	-- local color = (index / 3 + 1) >= 5 and 5 or math.floor(index / 3 + 1)
		-- local name_str = image_cfg.image_name
		-- self.foot_name:SetValue(string.format("<color=%s>%s</color>", SOUL_NAME_COLOR[color], name_str))
	local image_list = FootData.Instance:GetImageListInfo(self.foot_attr.used_imageid)
	if self.foot_attr.used_imageid > ADVANCE_IMAGE_ID_CHAZHI then
		local used_imageid = self.foot_attr.used_imageid - ADVANCE_IMAGE_ID_CHAZHI
		image_list = FootData.Instance:GetSpecialImageListInfo(used_imageid)
	end
	if nil == image_list then return end
	-- local call_back = function(model, obj)
	-- 	local cfg = nil--model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.ROLE_WING], FootData.Instance:GetFootModelResCfg(), DISPLAY_PANEL.FULL_PANEL)
	-- 	if obj then
	-- 		if cfg then
	-- 			obj.transform.localPosition = cfg.position
	-- 			obj.transform.localRotation = Quaternion.Euler(cfg.rotation.x, cfg.rotation.y, cfg.rotation.z)
	-- 			obj.transform.localScale = cfg.scale
	-- 		else
	-- 			obj.transform.localPosition = Vector3(0, 0.2, 0)
	-- 			obj.transform.localRotation = Quaternion.Euler(0, 0, 0)
	-- 			obj.transform.localScale = Vector3(1, 1, 1)
	-- 		end
	-- 		obj.transform.localRotation = Quaternion.Euler(0, -90, 0)
	-- 		model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
	-- 	end
	-- end
	-- UIScene:SetModelLoadCallBack(call_back)

	-- PrefabPreload.Instance:StopLoad(self.prefab_preload_id)

	bundle, asset = ResPath.GetFootModel(image_list.res_id)
	self.foot_bundle = bundle
	self.foot_asset = asset
	-- local load_list = {{bundle, asset}}
	-- self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
	-- 		local vo = GameVoManager.Instance:GetMainRoleVo()
	-- 		local info = {}
	-- 		info.foot_info = {used_imageid = self.foot_attr.used_imageid}
	-- 		info.prof = PlayerData.Instance:GetRoleBaseProf()
	-- 		info.sex = vo.sex
	-- 		info.is_not_show_weapon = true
	-- 		info.shizhuang_part_list = {{use_index = 0}, {use_index = vo.appearance.fashion_body}}
	-- 		UIScene:SetRoleModelResInfo(info, 1, false, false, false, false, true)
	-- 	end)
	-- self.res_id = self.foot_attr.used_imageid

	if nil ~= self.foot_bundle and nil ~= self.foot_asset and self.foot_asset_id ~= self.foot_asset then
		local main_role = Scene.Instance:GetMainRole()
		local role_info = CheckData.Instance:GetRoleInfo()
		self.model_view:SetModelResInfo(role_info, true, true, true, true, true, true)
		-- self.model_view:SetRoleResid(main_role:GetRoleResId())
		self.model_view:SetFootResid(self.foot_asset)
		-- self.model_view:SetInteger(ANIMATOR_PARAM.STATUS, 1)
		-- self.model_view:SetMainAsset(bundle, asset)
		-- self.model_view:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.FOOTPRINT], asset, DISPLAY_PANEL.FULL_PANEL)
		-- self.model_view.display:SetRotation(Vector3(0, -90, 0))
		self.foot_asset_id = self.foot_asset
	end
	self.model_view:SetInteger(ANIMATOR_PARAM.STATUS, 1)
end