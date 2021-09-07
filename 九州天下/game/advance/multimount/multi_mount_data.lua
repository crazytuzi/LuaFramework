MultiMountData = MultiMountData or BaseClass()

function MultiMountData:__init()
	if MultiMountData.Instance then
		print_error("[ItemData] Attemp to create a singleton twice !")
	end
	MultiMountData.Instance = self

	self.image_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("multi_mount_auto").mount_info, "mount_id")
	self.grade_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("multi_mount_auto").grade, "mount_id", "grade")
	self.level_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("multi_mount_auto").level, "mount_id", "level")
	self.mount_info = {}


	self.huanhua_data = {}
	--self.is_init = true
	self.multi_mount_special_image_level_list = {}
	self.multi_mount_data_list = {}

	self.last_bless = 0
	self.last_grade = 0
	self.last_opera_image = nil

	self.can_up_grade_data = nil
	RemindManager.Instance:Register(RemindName.AdvanceMultiMount, BindTool.Bind(self.GetMultiMountRed, self))
end

function MultiMountData:__delete()
	RemindManager.Instance:UnRegister(RemindName.AdvanceMultiMount)
	if MultiMountData.Instance then
		MultiMountData.Instance = nil
	end
	self.mount_info = {}
end

function MultiMountData:SetLastInfo(bless, grade)
	self.last_bless = bless or 0
	self.last_grade = grade or 0
end

function MultiMountData:GetLastGrade()
	return self.last_grade
end

function MultiMountData:ChangeShowInfo()
	--self.show_bless = self.mount_info.grade_bless_val
	if self.multi_mount_data_list ~= nil then
		for k,v in pairs(self.multi_mount_data_list) do
			if self.last_opera_image ~= nil and self.last_opera_image == v.index then
				self.show_bless = v.grade_bless
				break
			end
		end
	end	
end

function MultiMountData:GetShowBless()
	return self.show_bless or self.last_bless
end

function MultiMountData:GetMultiMountInfo()
	local data = {}
	data.grade_bless_val = 0
	data.grade = 0

	if self.multi_mount_data_list ~= nil then
		for k,v in pairs(self.multi_mount_data_list) do
			if self.last_opera_image ~= nil and self.last_opera_image == v.index then
				data.grade_bless_val = v.grade_bless
				data.grade = v.grade
				break
			end
		end
	end

	return data
end

function MultiMountData:SetMultiMountAllInfo(protocol)
	self.cur_use_mount_id = protocol.cur_use_mount_id or -1
	self.multi_mount_data_list = protocol.mount_list or {}
	self:FindCanUpData()
end

function MultiMountData:FindCanUpData()
	if self.multi_mount_data_list == nil then
		return
	end

	local check_grade = nil
	local check_bless = nil
	for k,v in pairs(self.multi_mount_data_list) do
		if v.grade > -1 then
			if check_grade == nil and check_bless == nil then
				check_grade = v.grade
				check_bless = v.grade_bless
				self.can_up_grade_data = v
			else
				if check_grade > v.grade or (check_grade == v.grade and check_bless > v.grade_bless) then
					check_grade = v.grade
					check_bless = v.grade_bless
					self.can_up_grade_data = v
				end
			end
		end
	end
end

function MultiMountData:SetMultiMountChangeNotifyInfo(protocol)
	self.notify_type = protocol.notify_type
	self.param_1 = protocol.param_1
	self.param_2 = protocol.param_2
	self.param_3 = protocol.param_3

	if self.notify_type == MULTI_MOUNT_CHANGE_NOTIFY_TYPE.MULTI_MOUNT_CHANGE_NOTIFY_TYPE_SELECT_MOUNT then
		self.cur_use_mount_id = self.param_1
	elseif self.notify_type == MULTI_MOUNT_CHANGE_NOTIFY_TYPE.MULTI_MOUNT_CHANGE_NOTIFY_TYPE_UPGRADE then
		self.multi_mount_data_list[self.param_1 + 1].grade = self.param_2
		self.multi_mount_data_list[self.param_1 + 1].grade_bless = self.param_3

		self:FindCanUpData()
	elseif self.notify_type == MULTI_MOUNT_CHANGE_NOTIFY_TYPE.MULTI_MOUNT_CHANGE_NOTIFY_TYPE_UPLEVEL then
		self.multi_mount_data_list[self.param_1 + 1].level = self.param_2
	elseif self.notify_type == MULTI_MOUNT_CHANGE_NOTIFY_TYPE.MULTI_MOUNT_CHANGE_NOTIFY_TYPE_ACTIVE_SPECIAL_IMG then
		local special_img_active_flag = {}
		local temp_flag = bit:d2b(self.param_1)						-- 特殊坐骑激活标志，0未激活，1激活
		for i=1,10 do
			special_img_active_flag[i] = temp_flag[32-i]
		end
		self.huanhua_data.active_special_img_flag = special_img_active_flag
	elseif self.notify_type == MULTI_MOUNT_CHANGE_NOTIFY_TYPE.MULTI_MOUNT_CHANGE_NOTIFY_TYPE_USE_SPECIAL_IMG then
		self.huanhua_data.used_special_img_id = self.param_1
	elseif self.notify_type == MULTI_MOUNT_CHANGE_NOTIFY_TYPE.MULTI_MOUNT_CHANGR_NOTIFY_TYPE_UPGRADE_EQUIP then
		self.equip_level_list[self.param_1] = self.param_2
	elseif self.notify_type == MULTI_MOUNT_CHANGE_NOTIFY_TYPE.MULTI_MOUNT_CHANGE_NOTIFY_TYPE_UPLEVEL_SPECIAL_IMG then
		if self.huanhua_data.special_img_lv_list then
			self.huanhua_data.special_img_lv_list[protocol.param_1] = protocol.param_2
		end
	end
end

function MultiMountData:GetMultiMountChangeNotify()
	return {notify_type = self.notify_type, param_1 = self.param_1, param_2 = self.param_2, param_3 = self.param_3}
end

function MultiMountData:GetCurUseMountId()
	return self.cur_use_mount_id or -1
end

-- function MultiMountData:GetCurMulitMountResId()
-- 	local huanhua_resid = self:GetMultiMountHuanhuaResId()
-- 	if self.cur_use_mount_id > 0 and huanhua_resid > 0 then
-- 		return huanhua_resid
-- 	end

-- 	local mount_cfg = self.mount_info_cfg[self.cur_use_mount_id]
-- 	return nil ~= mount_cfg and mount_cfg.res_id or 0
-- end

function MultiMountData:GetMulitMountResId(mount_id)
	local mount_cfg = self.image_cfg[mount_id]
	return nil ~= mount_cfg and mount_cfg.res_id or 0
end

function MultiMountData:GetImageListCfg()
	local data = {}
	for k,v in pairs(self.image_cfg) do
		table.insert(data, v)
	end
	return #data or 0, data
end

function MultiMountData:GetImageCfgById(mount_id)
	local data = {}
	if mount_id ~= nil then
		if self.image_cfg[mount_id] ~= nil then
			data = self.image_cfg[mount_id]
		end
	end

	return data
end

function MultiMountData:GetGradeInfoById(mount_id, grade)
	local data = {}
	local max_grade = 0

	if mount_id ~= nil then
		local cfg = self.grade_cfg[mount_id]
		if cfg ~= nil then
			max_grade = #cfg
			if cfg[grade] ~= nil then
				data = cfg[grade]
			end
		end
	end

	return data, max_grade
end

function MultiMountData:GetDataById(mount_id)
	local data = {}
	if mount_id ~= nil and self.multi_mount_data_list ~= nil then
		for k,v in pairs(self.multi_mount_data_list) do
			if mount_id == v.index then
				data = v
				break
			end
		end
	end

	return data
end

function MultiMountData:GetNeedItemCfg(mount_id, is_active)
	local info_info = self:GetDataById(mount_id)
	--local cfg_data = self:GetImageCfgById(mount_id)
	if info_info == nil or next(info_info) == nil then
		return nil, 0, false
	end

	-- if cfg_data == nil or next(cfg_data) == nil then
	-- 	return nil, 0, false
	-- end

	local need_item = nil
	local need_num = 0
	local has_str = ""
	local need_str = ""

	--local active_item = cfg_data.active_need_item_id
	--local count = ItemData.Instance:GetItemNumInBagById(active_item)
	local is_grade = info_info.grade ~= -1
	if is_active then
		is_grade = false
	end

	if not is_grade then
		local level_cfg = self:GetLeveInfoById(mount_id, info_info.level)
		if level_cfg ~= nil and next(level_cfg) ~= nil then
			need_item = level_cfg.upgrade_stuff_id
			need_num = level_cfg.upgrade_stuff_num
		end
	else
		local grade_cfg = self:GetGradeInfoById(mount_id, info_info.grade)
		if grade_cfg ~= nil and next(grade_cfg) ~= nil then
			need_item = grade_cfg.upgrade_stuff_id
			need_num = grade_cfg.upgrade_stuff_num
		end
	end

	return need_item, need_num, is_grade
end

function MultiMountData:GetLeveInfoById(mount_id, level)
	local data = {}
	local max_level = 0

	if mount_id ~= nil then
		local cfg = self.level_cfg[mount_id]
		if cfg ~= nil then
			max_level = #cfg
			if cfg[level] ~= nil then
				data = cfg[level]
			end
		end
	end

	return data, max_level
end

function MultiMountData:GetMultiMountSitTypeByResid(mount_id)
	if mount_id == nil or mount_id == -1 then
		return 0, 0
	end

	local cfg = self.image_cfg[mount_id]
	if cfg ~= nil then
		return cfg.sit_1, cfg.sit_2
	end

	return 0, 0
end

function MultiMountData:GetRenderRed(mount_id)
	local show_red = false
	if self.multi_mount_data_list == nil or mount_id == nil then
		return show_red
	end

	local data = self.multi_mount_data_list[mount_id + 1]
	if data == nil then
		return show_red
	end

	local can_active = false
	local can_up_level = false
	local can_up_grade = false
	
	if data.grade == -1 then
		local image_info = self.image_cfg[mount_id]
		if image_info ~= nil then
			local active_item_num = ItemData.Instance:GetItemNumInBagById(image_info.active_need_item_id)
			if active_item_num > 0 then
				can_active = true
			end
		end
	else
		if self.can_up_grade_data ~= nil and self.can_up_grade_data.index == data.index then
			local grade_cfg, max_grade = self:GetGradeInfoById(mount_id, data.grade)
			if grade_cfg ~= nil and next(grade_cfg) ~= nil and data.grade < max_grade then
				local grade_item_num = ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id)
				if grade_item_num >= grade_cfg.upgrade_stuff_num then
					can_up_grade = true
				end
			end	
		end	

		local level_cfg, max_level = self:GetLeveInfoById(mount_id, data.level)
		if level_cfg ~= nil and next(level_cfg) ~= nil and data.level < max_level then
			local level_item_num = ItemData.Instance:GetItemNumInBagById(level_cfg.upgrade_stuff_id)
			if level_item_num >= level_cfg.upgrade_stuff_num then
				can_up_level = true
			end
		end
	end

	show_red = can_active or can_up_grade or can_up_level

	return show_red, can_active, can_up_grade, can_up_level
end

function MultiMountData:GetMultiMountRed()
	local _, list = self:GetImageListCfg()
	local is_show = 0
	if not OpenFunData.Instance:CheckIsHide("multi_mount") then
		return is_show
	end

	if list ~= nil and next(list) ~= nil then
		for k,v in pairs(list) do
			local show_red = self:GetRenderRed(v.mount_id)
			if show_red then
				is_show = 1
				break
			end
		end
	end

	return is_show
end

function MultiMountData:GetRemindTimer()
	local other = ConfigManager.Instance:GetAutoConfig("multi_mount_auto").other[1]
	local date = os.date("*t", TimeCtrl.Instance:GetServerTime())
	local cur_data = nil
	if date ~= nil then
		cur_data = date.hour * 3600 + date.min * 60 + date.sec
	end

	local timer_list = {}
	if other.remind_list ~= nil and cur_data ~= nil then
		local timer_tab = Split(other.remind_list, "|")
		if timer_tab ~= nil then
			for k,v in pairs(timer_tab) do
				local time = 0
				if v ~= nil then
					local tab = Split(v, ",")
					if tab ~= nil then
						if tab[1] ~= nil then
							time = time + tab[1] * 60 * 60
						end

						if tab[2] ~= nil then
							time = time + tab[2] * 60
						end

						if tab[3] ~= nil then
							time = time + tab[3]
						end
					end
				end 


				if time ~= 0 then
					-- if time < cur_data then
					-- 	time = time + 24 * 3600 - cur_data
					-- else
					-- 	time = time - cur_data
					-- end
					if time > cur_data then
						time = time - cur_data
						timer_list[time] = time
					end
				end
			end
		end
	end

	return timer_list
end

function MultiMountData:GetMultiDataList()
	return self.multi_mount_data_list or {}
end

function MultiMountData:GetRemindGrade()
	local other = ConfigManager.Instance:GetAutoConfig("multi_mount_auto").other[1]
	return other.clear_bless_day_need_grade or 0
end
-- ----------双人坐骑幻化--------------
-- function MultiMountData:GetMultiMountHuanhuaData()
-- 	return self.huanhua_data
-- end

-- -- 获取双人坐骑幻化配置
-- function MultiMountData:GetMultiMountHuanhuaCfg()
-- 	return self.special_img_cfg
-- end

-- -- 获取双人坐骑幻化配置
-- function MultiMountData:GetMultiMountHuanhuaCfgByIndex(index)
-- 	return self.special_img_cfg[index]
-- end

-- -- 获取双人坐骑幻化配置
-- function MultiMountData:GetSpecialImageUpgradeCfg()
-- 	return self.special_img_grade_cfg
-- end

-- -- 获取双人坐骑幻化配置
-- function MultiMountData:GetMultiMountHuanhuaId()
-- 	return self.huanhua_data.used_special_img_id or 0
-- end

-- -- 获取双人坐骑幻化总属性(已激活)
-- function MultiMountData:GetMultiMountAllAttr()
-- 	local special_img_cfg = self:GetMultiMountHuanhuaCfg()
-- 	local m_attribute = CommonStruct.Attribute()
-- 	for k,v in pairs(special_img_cfg) do
-- 		if self:IsMultiMountImageActive(v.image_id) then
-- 			local attr_list = CommonDataManager.GetAttributteByClass(v)
-- 			m_attribute = CommonDataManager.AddAttributeAttr(m_attribute, attr_list)
-- 		end
-- 	end
-- 	return m_attribute
-- end

-- -- 通过位运算，判断双人坐骑特殊形象是否激活
-- function MultiMountData:IsMultiMountImageActive(img_id)
-- 	local huanhua_data = self:GetMultiMountHuanhuaData()
-- 	if nil == huanhua_data.active_special_img_flag then return false end

-- 	if 0 ~= huanhua_data.active_special_img_flag[img_id] then
-- 		return true
-- 	else
-- 		return false
-- 	end
-- end

-- -- 通过幻化id获取坐骑幻化配置
-- function MultiMountData:GetHuanhuaCfgByImageId(image_id)
-- 	local special_img = self.special_img_cfg
-- 	if special_img == nil then return nil end

-- 	for i,v in pairs(special_img) do
-- 		if v.image_id == image_id then
-- 			return v
-- 		end
-- 	end
-- 	return nil
-- end

-- function MultiMountData:GetMultiMountHuanhuaResId()
-- 	if nil ~= self.huanhua_data and nil ~= self.huanhua_data.used_special_img_id and self.huanhua_data.used_special_img_id > 0 then
-- 		local huanhuacfg = self:GetHuanhuaCfgByImageId(self.huanhua_data.used_special_img_id)
-- 		return huanhuacfg and huanhuacfg.res_id or 0
-- 	end
-- 	return 0
-- end

-- function MultiMountData:GetMountImgIdByResID(res_id)
-- 	for k,v in pairs(self.mount_info_cfg or {}) do
-- 		if v.res_id == res_id then
-- 			return v.mount_id
-- 		end
-- 	end
-- 	return 1
-- end

-- --双人坐骑幻化物品展示
-- function MultiMountData:GetMultiMountResByItemId(item_id)
-- 	if nil == item_id then return nil end
-- 	for k,v in pairs(self.special_img_cfg) do
-- 		if v.item_id == item_id then
-- 			return v.res_id, v
-- 		end
-- 	end
-- 	return nil
-- end

-- function MultiMountData:CanHuanhuaUpgrade()
-- 	if self.huanhua_data.special_img_lv_list == nil then return nil end

-- 	for i, v in pairs(self.special_img_grade_cfg) do
-- 		local cur_grade = self.huanhua_data.special_img_lv_list[i] or 1
-- 		if cur_grade < #v and v[cur_grade] and v[cur_grade].stuff_num <= ItemData.Instance:GetItemNumInBagById(v[cur_grade].stuff_id) then
-- 			return v[cur_grade].special_img_id
-- 		end
-- 	end

-- 	return nil
-- end

-- function MultiMountData:GetMaxSpecialImage()
-- 	return #self.special_img_grade_cfg
-- end

-- -- 获取当前点击坐骑特殊形象的配置
-- function MultiMountData:GetSpecialImageUpgradeInfo(index, grade, is_next)
-- 	if (index == 0) or self.huanhua_data.special_img_lv_list == nil then
-- 		return
-- 	end
-- 	local grade = grade or self.huanhua_data.special_img_lv_list[index] or 0
-- 	if is_next or grade == 0 then
-- 		grade = grade + 1
-- 	end
-- 	if self.special_img_grade_cfg[index] then
-- 		return self.special_img_grade_cfg[index][grade]
-- 	end

-- 	return nil
-- end

-- -- 获取幻化最大等级
-- function MultiMountData:GetSpecialImageMaxUpLevelById(image_id)
-- 	if not image_id then return 0 end
-- 	return #(self.special_img_grade_cfg[image_id] or {})
-- end


-- ---- /坐骑幻化 ---------------------------------------


-- ---- 坐骑战甲 ----------------------------------------
-- function MultiMountData:GetMuoutEquipLvlBySeq(seq)
-- 	return self.equip_level_list[seq] or 0
-- end

-- function MultiMountData:GetMountEquipCfgBySeq(seq)
-- 	local cfg = {}
-- 	for k, v in pairs(self.equip_cfg) do
-- 		if v.equip_type == seq then
-- 			cfg = v
-- 		end
-- 	end

-- 	return cfg
-- end

-- function MultiMountData:GetMountEquipCfgByItemId(item_id)
-- 	local cfg = {}
-- 	for k, v in pairs(self.equip_cfg) do
-- 		if v.upgrade_need_stuff == item_id then
-- 			cfg = v
-- 		end
-- 	end

-- 	return cfg
-- end

-- function MultiMountData:GetMountZhanjiaGridShowData()
-- 	local item_list = {}
-- 	local index = 0

-- 	for k, v in pairs(self.equip_cfg) do
-- 		local item = {}
-- 		item.seq = v.equip_type
-- 		item.item_id = v.upgrade_need_stuff
-- 		item.is_bind = 0
-- 		item.upgrade_stuff_count = v.upgrade_stuff_count
-- 		item.max_level = v.max_level
-- 		item_list[index] = item
-- 		index = index + 1
-- 	end

-- 	return item_list
-- end

-- function MultiMountData:GetMountEquipTotalAttr()
-- 	local total_attr = CommonStruct.Attribute()
-- 	for k, v in pairs(self.equip_level_list) do
-- 		local cfg = CommonDataManager.GetAttributteByClass(self:GetMountEquipCfgBySeq(k))
-- 		local attr = CommonDataManager.MulAttribute(cfg, v)
-- 		total_attr = CommonDataManager.AddAttributeAttr(total_attr, attr)
-- 	end

-- 	return total_attr
-- end

-- ---- /坐骑战甲 ---------------------------------------

-- ---- 双人化形进阶 ---------------------------------------
-- function MultiMountData:GetSepcialMultiMountLevelByImageId(image_id)
-- 	return self.multi_mount_special_image_level_list[image_id]
-- end

-- function MultiMountData:GetSepcialMultiMountUpgradeCfg(image_id, level)
-- 	for k,v in pairs(self.multi_mount_cfg.image_upgrade) do
-- 		if v.level == level and v.image_id == image_id then
-- 			return v
-- 		end
-- 	end
-- end

-- function MultiMountData:CanJinjie()
-- 	for i,v in ipairs(self.grade_cfg) do
-- 		if self:MountCanJinjie(i) then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end

-- function MultiMountData:MountCanJinjie(index)
-- 	local is_act = self:GetMountIsActiveByIndex(index)
-- 	local grade = self:GetMountLevelByIndex(index)
-- 	local v = self.grade_cfg[index]
-- 	if v and (index == 1 or is_act or self:GetMountIsActiveByIndex(index - 1)) and grade < #v then
-- 		local stuff_item_id = v[grade].upgrade_stuff_id
-- 		if stuff_item_id then
-- 			if v[grade].upgrade_stuff_num <= ItemData.Instance:GetItemNumInBagById(stuff_item_id) then
-- 				return true
-- 			end
-- 		end
-- 	end
-- 	return false
-- end

-- function MultiMountData:GetMultiMountRemind()
-- 	if self:CanJinjie() then
-- 		return 1
-- 	elseif self:CanHuanhuaUpgrade() ~= nil then
-- 		return 1
-- 	end
-- 	return 0
-- end
