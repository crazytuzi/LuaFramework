
ImageFuLingData = ImageFuLingData or BaseClass()

function ImageFuLingData:__init()
	if ImageFuLingData.Instance then
		print_error("[ItemData] Attemp to create a singleton twice !")
	end
	ImageFuLingData.Instance = self

	local image_fuling_cfg = ConfigManager.Instance:GetAutoConfig("img_fuling_cfg_auto")

	self.image_fuling_level_cfg = ListToMap(image_fuling_cfg.fuling_level, "system_type", "level")
	self.image_fuling_skill_level_cfg = ListToMap(image_fuling_cfg.fuling_skill, "system_type", "skill_level")
	self.image_fuling_stuff_cfg = ListToMap(image_fuling_cfg.fuling_stuff, "system_type", "stuff_id")
	self.jingjie_equip_per_add = image_fuling_cfg.jingjie_equip_per_add

	self.fuling_tab_info_list = {
		IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_MOUNT,
		IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_WING,
		IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_HALO,
		IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FIGHT_MOUNT,
		IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENGONG,
		IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENYI,
		IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FOOT_PRINT,
	}

	self.fuling_info_list = {}

	RemindManager.Instance:Register(RemindName.ImgFuLing, BindTool.Bind(self.GetImgFuLingRemind, self))
end

function ImageFuLingData:__delete()
	if ImageFuLingData.Instance then
		ImageFuLingData.Instance = nil
	end

	RemindManager.Instance:UnRegister(RemindName.ImgFuLing)
end

function ImageFuLingData:SetImgFuLingData(protocol)
	self.fuling_info_list = protocol.fuling_list
end

function ImageFuLingData:GetImgFuLingData(img_fuling_type)
	return self.fuling_info_list[img_fuling_type]
end

function ImageFuLingData:GetImgFuLingCapability(img_fuling_type, level)
	level = level or self.fuling_info_list[img_fuling_type].level
	local level_cfg = self:GetImgFuLingLevelCfg(img_fuling_type, level)
	if nil ~= level_cfg then
		local level_attr = CommonDataManager.GetAttributteByClass(level_cfg)
		return CommonDataManager.GetCapabilityCalculation(level_attr)
	end
	return 0
end

function ImageFuLingData:GetImgFuLingLevelCfg(img_fuling_type, level)
	if self.image_fuling_level_cfg[img_fuling_type] and self.image_fuling_level_cfg[img_fuling_type][level] then
		return self.image_fuling_level_cfg[img_fuling_type][level]
	end
end

function ImageFuLingData:GetImgFuLingSkillName(skill_index)
	for k,v in pairs(self.image_fuling_skill_level_cfg) do
		if nil ~= v[1] and v[1].index == skill_index then
			return v[1].skill_name
		end
	end
	return ""
end

function ImageFuLingData:GetImgFuLingSkillLevelCfg(img_fuling_type, level)
	level = level > 0 and level or 1
	if self.image_fuling_skill_level_cfg[img_fuling_type] and self.image_fuling_skill_level_cfg[img_fuling_type][level] then
		return self.image_fuling_skill_level_cfg[img_fuling_type][level]
	end
end

function ImageFuLingData:GetImgFuLingAllUpStuffCfg(img_fuling_type)
	return self.image_fuling_stuff_cfg[img_fuling_type]
end

function ImageFuLingData:GetJinJieEquipAddPer(min_level)
	for k,v in pairs(self.jingjie_equip_per_add) do
		if v.min_level == min_level then
			return v
		end
	end
end

function ImageFuLingData:GetFuLingTabInfoList()
	return self.fuling_tab_info_list
end

function ImageFuLingData:GetFuLingExtraCapabilityByType(img_fuling_type, level)
	local attr = CommonStruct.Attribute()
	if IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_MOUNT == img_fuling_type then
		attr = MountData.Instance:GetLevelAttribute()
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_WING == img_fuling_type then
		attr = WingData.Instance:GetLevelAttribute()
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_HALO == img_fuling_type then
		attr = HaloData.Instance:GetLevelAttribute()
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FIGHT_MOUNT == img_fuling_type then
		attr = FightMountData.Instance:GetLevelAttribute()
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENGONG == img_fuling_type then
		attr = ShengongData.Instance:GetLevelAttribute()
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENYI == img_fuling_type then
		attr = ShenyiData.Instance:GetLevelAttribute()
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FOOT_PRINT == img_fuling_type then
		attr = FootData.Instance:GetLevelAttribute()
	end

	local extra_attr = CommonStruct.Attribute()
	local fuling_level_cfg = self:GetImgFuLingLevelCfg(img_fuling_type, level)
	if nil ~= fuling_level_cfg then
		for k, v in pairs(attr) do
			extra_attr[k] = v * (fuling_level_cfg.per_add / 10000)
		end
	end

	return CommonDataManager.GetCapabilityCalculation(extra_attr)
end

function ImageFuLingData:GetSpecialImageActiveItemId(img_fuling_type, img_id)
	local cfg = {}
	if IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_MOUNT == img_fuling_type then
		cfg = ConfigManager.Instance:GetAutoConfig("mount_auto").special_img
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_WING == img_fuling_type then
		cfg = ConfigManager.Instance:GetAutoConfig("wing_auto").special_img
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_HALO == img_fuling_type then
		cfg = ConfigManager.Instance:GetAutoConfig("halo_auto").special_img
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FIGHT_MOUNT == img_fuling_type then
		cfg = ConfigManager.Instance:GetAutoConfig("fight_mount_auto").special_img
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENGONG == img_fuling_type then
		cfg = ConfigManager.Instance:GetAutoConfig("shengong_auto").special_img
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENYI == img_fuling_type then
		cfg = ConfigManager.Instance:GetAutoConfig("shenyi_auto").special_img
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FOOT_PRINT == img_fuling_type then
		cfg = ConfigManager.Instance:GetAutoConfig("footprint_auto").special_img
	end

	for k,v in pairs(cfg) do
		if v.image_id == img_id then
			return v.item_id
		end
	end
end

function ImageFuLingData:GetFuLingStuffItemConfig(img_fuling_type, item_id)
	if self.image_fuling_stuff_cfg[img_fuling_type] and self.image_fuling_stuff_cfg[img_fuling_type][item_id] then
		return self.image_fuling_stuff_cfg[img_fuling_type][item_id]
	end
end

function ImageFuLingData:GetItemIsActiveImage(img_fuling_type, item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	local img_id = item_cfg.param1

	local is_active = false
	if IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_MOUNT == img_fuling_type then
		is_active = MountData.Instance:GetSpecialImageIsActive(img_id)
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_WING == img_fuling_type then
		is_active = WingData.Instance:GetSpecialImageIsActive(img_id)
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_HALO == img_fuling_type then
		is_active = HaloData.Instance:GetSpecialImageIsActive(img_id)
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FIGHT_MOUNT == img_fuling_type then
		is_active = FightMountData.Instance:GetSpecialImageIsActive(img_id)
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENGONG == img_fuling_type then
		is_active = ShengongData.Instance:GetSpecialImageIsActive(img_id)
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENYI == img_fuling_type then
		is_active = ShenyiData.Instance:GetSpecialImageIsActive(img_id)
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FOOT_PRINT == img_fuling_type then
		is_active = FootData.Instance:GetSpecialImageIsActive(img_id)
	end

	return is_active
end

function ImageFuLingData:GetCanConsumeStuff(img_fuling_type)
	local stuff_cfg = self:GetImgFuLingAllUpStuffCfg(img_fuling_type)
	local item_list = ItemData.Instance:GetBagItemDataList()
	local temp_list = {}
	if stuff_cfg == nil then
		return temp_list
	end
	for k,v in pairs(item_list) do
		local next_fuling_level_cfg = nil
		if self.fuling_info_list[img_fuling_type] then
			next_fuling_level_cfg = self:GetImgFuLingLevelCfg(img_fuling_type, self.fuling_info_list[img_fuling_type].level + 1)
		end
		if stuff_cfg[v.item_id] and self:GetItemIsActiveImage(img_fuling_type, v.item_id) and nil ~= next_fuling_level_cfg then
			table.insert(temp_list, v)
		end
	end
	return temp_list
end

function ImageFuLingData:GetImgFuLingTypeByDisplayType(display_type)
	if display_type == DISPLAY_TYPE.MOUNT then
		return IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_MOUNT
	elseif display_type == DISPLAY_TYPE.FIGHT_MOUNT then
		return IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FIGHT_MOUNT
	elseif display_type == DISPLAY_TYPE.WING then
		return IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_WING
	elseif display_type == DISPLAY_TYPE.HALO then
		return IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_HALO
	elseif display_type == DISPLAY_TYPE.FOOTPRINT then
		return IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FOOT_PRINT
	elseif display_type == DISPLAY_TYPE.SHENGONG then
		return IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENGONG
	elseif display_type == DISPLAY_TYPE.SHENYI then
		return IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENYI
	end
end

function ImageFuLingData:GetImgFuLingRemind()
	for img_fuling_type = 0, GameEnum.IMG_FULING_JINGJIE_TYPE_MAX - 1 do
		local item_list = self:GetCanConsumeStuff(img_fuling_type)
		local next_fuling_level_cfg = nil
		if self.fuling_info_list[img_fuling_type] then
			next_fuling_level_cfg = self:GetImgFuLingLevelCfg(img_fuling_type, self.fuling_info_list[img_fuling_type].level + 1)
		end
		if nil ~= next_fuling_level_cfg and #item_list > 0 then
			return 1
		end
	end
	return 0
end


