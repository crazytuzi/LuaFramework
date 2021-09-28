CityOwnerObj = CityOwnerObj or BaseClass(SceneObj)
local default_statue = 6091001 --默认雕像
local default_weapon = 910100101 --默认武器
function CityOwnerObj:__init(vo)
	self.obj_type = SceneObjType.CityOwnerObj
	self.draw_obj:SetObjType(self.obj_type)
	
	if self.draw_obj then
		local transform = self.draw_obj:GetRoot().transform
		transform.localScale = Vector3(1.7, 1.7, 1.7)
	end

	self:UpdateAppearance()
end

function CityOwnerObj:__delete()

end

function CityOwnerObj:OnClick()
	return
end

function CityOwnerObj:OnClicked(param)

end

function CityOwnerObj:CancelSelect()
	return
end

function CityOwnerObj:GetObjKey()
	return self.vo.obj_id
end

function CityOwnerObj:InitShow()
	Character.InitShow(self)

	if self.role_res_id ~= nil and self.role_res_id ~= 0 then
		local bundle, asset = ResPath.GetRoleModel(self.role_res_id)
		if default_statue == self.role_res_id then
			bundle, asset = ResPath.GetGatherModel(self.role_res_id)
		end
		self:InitModel(bundle, asset)
	end

	if self.weapon_res_id ~= nil and self.weapon_res_id ~= 0 then
		self:ChangeModel(SceneObjPart.Weapon, ResPath.GetWeaponModel(self.weapon_res_id))
	end

	if self.weapon2_res_id ~= nil and self.weapon2_res_id ~= 0 then
		self:ChangeModel(SceneObjPart.Weapon2, ResPath.GetWeaponModel(self.weapon2_res_id))
	end

	if self.wing_res_id ~= nil and self.wing_res_id ~= 0 then
		self:ChangeModel(SceneObjPart.Wing, ResPath.GetWingModel(self.wing_res_id))
	end
end

function CityOwnerObj:InitModel(bundle, asset)
	if AssetManager.Manifest ~= nil and not AssetManager.IsVersionCached(bundle) then
		local default_res_id = nil
		if self.vo.sex == 0 then
			default_res_id = "100" .. PROF_ROLE[self.vo.prof] .. "001"
		else
			default_res_id = "110" .. PROF_ROLE[self.vo.prof] .. "001"
		end
		self:ChangeModel(SceneObjPart.Main, ResPath.GetRoleModel(default_res_id))

		DownloadHelper.DownloadBundle(bundle, 3, function(ret)
			if ret then
				self:ChangeModel(SceneObjPart.Main, bundle, asset)
			end
		end)
	else
		self:ChangeModel(SceneObjPart.Main, bundle, asset)
	end
end


function CityOwnerObj:UpdateAppearance()
	--清空缓存
	self.role_res_id = 0
	self.weapon_res_id = 0
	self.weapon2_res_id = 0
	self.wing_res_id = 0

	-- 先查找时装的武器和衣服
	self:UpdateWeaponResId()
	self:UpdateRoleResId()
	self:UpdateWingResId()

	-- 最后查找职业表
	local prof = self.vo.prof
	local sex = self.vo.sex
	local job_cfgs = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job
	if nil == job_cfgs then
		return
	end
	
	local role_job = job_cfgs[prof]
	if role_job ~= nil then
		if self.role_res_id == 0 then
			self.role_res_id = default_statue
		end

		if self.weapon_res_id == 0 and default_statue ~= self.role_res_id then
			-- 武器颜色为红色时，使用特殊的模型
			if self.vo.wuqi_color >= GameEnum.ITEM_COLOR_RED then
				self.weapon_res_id = role_job["right_red_weapon" .. sex]
			else
				self.weapon_res_id = role_job["right_weapon" .. sex]
			end
		end
	else
		if self.role_res_id == 0 then
			self.role_res_id = default_statue
		end

		if self.weapon_res_id == 0 and default_statue ~= self.role_res_id then
			self.weapon_res_id = default_weapon
		end
	end
end

function CityOwnerObj:UpdateWeaponResId()
	local prof = self.vo.prof
	local sex = self.vo.sex
	if nil == self.vo.appearance  then
		return
	end

	local fashion_cfg_list = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").cfg
	if nil == fashion_cfg_list or 0 == self.vo.appearance.fashion_wuqi then
		return
	end

	local wuqi_cfg = self:GetFashionConfig(fashion_cfg_list, SHIZHUANG_TYPE.WUQI, self.vo.appearance.fashion_wuqi)
	if nil == wuqi_cfg then
		return
	end

	local cfg = wuqi_cfg["resouce" .. prof .. sex]
	if type(cfg) == "string" then
		local temp_table = Split(cfg, ",")
		if temp_table then
			self.weapon_res_id = temp_table[1]
			self.weapon2_res_id = temp_table[2]
		end
	elseif type(cfg) == "number" then
		self.weapon_res_id = cfg
	end
end

function CityOwnerObj:UpdateRoleResId()
	local prof = self.vo.prof
	local sex = self.vo.sex
	if nil == self.vo.appearance  then
		return
	end

	local fashion_cfg_list = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").cfg
	if  nil == fashion_cfg_list or 0 == self.vo.appearance.fashion_body  then
		return
	end

	local clothing_cfg = self:GetFashionConfig(fashion_cfg_list, SHIZHUANG_TYPE.BODY, self.vo.appearance.fashion_body)
	if clothing_cfg then
		local index = string.format("resouce%s%s", prof, sex)
		local res_id = clothing_cfg[index]
		self.role_res_id = res_id
	end
end

function CityOwnerObj:UpdateWingResId()
	if nil == self.vo.appearance  then
		return
	end

	local index = self.vo.appearance.wing_used_imageid or 0
	local wing_config = ConfigManager.Instance:GetAutoConfig("wing_auto")
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local image_cfg = nil
	self.wing_res_id = 0
	if wing_config then
		if index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = wing_config.special_img[index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = wing_config.image_list[index]
		end
		if image_cfg then
			self.wing_res_id = image_cfg.res_id
		end
	end
end

--根据type, index获取服装的配置
function CityOwnerObj:GetFashionConfig(fashion_cfg_list, part_type, index)
	for k, v in pairs(fashion_cfg_list) do
		if v.part_type == part_type and index == v.index then
			return v
		end
	end
	return nil
end