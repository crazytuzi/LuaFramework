ClothespressData = ClothespressData or BaseClass(BaseEvent)

function ClothespressData:__init()
	if ClothespressData.Instance then
		print_error("[ClothespressData] Attempt to create singleton twice!")
		return
	end
	ClothespressData.Instance = self

	self.all_suit_info_list = {}

	self.cfg = ConfigManager.Instance:GetAutoConfig("dressing_room_auto") or {}

	self.suit_cfg = self.cfg.suit_des or {}
	self.all_suit_part = self.cfg.suit_cfg or {}
	self.all_suit_attr = self.cfg.suit_attr or {}

	self.all_suit_part_cfg = ListToMapList(self.all_suit_part,"suit_index")
	self.all_suit_attr_cfg = ListToMapList(self.all_suit_attr,"suit_index")
end

function ClothespressData:__delete()
	ClothespressData.Instance = nil
end
-------------------------------协议相关---------------------------------
function ClothespressData:SetAllSuitInfo(protocol)
	self.all_suit_info_list = {}
	local suit_info_list = protocol.info_list or {}
	local count = protocol.single_img_count or 0
	if count == 0 or nil == next(suit_info_list) then return end

	self:SetAllSuitDataByInfo(count, suit_info_list)
end

function ClothespressData:SetSingleSuitInfo(protocol)
	local is_active = protocol.is_active or 0
	local info_list = protocol.info
	local suit_index = info_list and info_list.suit_index + 1
	local part_index = info_list and info_list.img_index + 1

	if self.all_suit_info_list and suit_index and part_index and 
		self.all_suit_info_list[suit_index] and self.all_suit_info_list[suit_index][part_index] then
		self.all_suit_info_list[suit_index][part_index] = is_active
	end
end
-------------------------------协议结束---------------------------------

-------------------------------套装相关---------------------------------
--套装配置
function ClothespressData:GetAllSuitCfg()
	return self.suit_cfg
end

--所有套装信息
function ClothespressData:SetAllSuitDataByInfo(count, info_list)
	for i=1, count do
		local list = info_list[i]
		local single_suit_list = list and bit:d2b(list)
		local suit_part = {}

		if single_suit_list then
			local num = self:GetSingleSuitPartNumBySuitIndex(i)
			if num > 0 then
				for i=0, num-1 do
					if single_suit_list[32 - i] then
						table.insert(suit_part, single_suit_list[32 - i])
					end
				end
			end
		end

		table.insert(self.all_suit_info_list, suit_part)
	end
end

--单个套装的部位数量	suit_index	从1开始
function ClothespressData:GetSingleSuitPartNumBySuitIndex(suit_index)
	local num = 0
	if nil == suit_index or nil == self.all_suit_part_cfg or nil == self.all_suit_part_cfg[suit_index - 1] then
		return num 
	end

	num = #self.all_suit_part_cfg[suit_index - 1]
	return num
end

--单个套装的部位配置	suit_index	从1开始
function ClothespressData:GetSingleSuitPartCfgBySuitIndex(suit_index)
	local cfg = {}
	if nil == suit_index or nil == self.all_suit_part_cfg or nil == self.all_suit_part_cfg[suit_index - 1] then
		return cfg 
	end

	cfg = self.all_suit_part_cfg[suit_index - 1]
	return cfg
end

--单个套装的部位激活信息	suit_index	从1开始
function ClothespressData:GetSingleSuitPartInfoBySuitIndex(suit_index)
	local info = {}
	if nil == suit_index or nil == self.all_suit_info_list or nil == self.all_suit_info_list[suit_index] then
		return info 
	end

	info = self.all_suit_info_list[suit_index]
	return info
end

--单个套装的部位激活数量	suit_index	从1开始
function ClothespressData:GetSingleSuitActivePartNum(suit_index)
	local num = 0
	if nil == suit_index or nil == self.all_suit_info_list or nil == self.all_suit_info_list[suit_index] then
		return num
	end

	local list = self.all_suit_info_list[suit_index]
	for k,v in pairs(list) do
		if v == 1 then
			num = num + 1
		end
	end
	
	return num
end

function ClothespressData:GetAllSuitInfo()
	return self.all_suit_info_list or {}
end

function ClothespressData:GetCurSuitNeedShowModelInfo(suit_index)
	local single_suit_cfg = self:GetSingleSuitPartCfgBySuitIndex(suit_index)
	local info_list = self:SetRoleModleInfo(single_suit_cfg)
	return info_list
end

function ClothespressData:SetRoleModleInfo(single_suit_cfg)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local sprit_res_id = 0
	local goddess_res_id = 0
	local mount_res_id = 0
	local fight_mount_res_id = 0
	local info = {}
	info.prof = main_role_vo.prof
	info.sex = main_role_vo.sex
	info.appearance = {}
		
	for k,v in pairs(single_suit_cfg) do
		if v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_CLOAK then 					-- 披风
			info.appearance.cloak_used_imageid = v.img_id + GameEnum.MOUNT_SPECIAL_IMA_ID
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_FOOTPRINT then			-- 足迹
			info.appearance.footprint_used_imageid = v.img_id + GameEnum.MOUNT_SPECIAL_IMA_ID
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_HALO then				-- 光环
			info.appearance.halo_used_imageid = v.img_id + GameEnum.MOUNT_SPECIAL_IMA_ID
		elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_MASK then					-- 面饰
			info.appearance.mask_used_imageid = v.img_id
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_QILINBI then				-- 麒麟臂
			info.appearance.qilinbi_used_imageid = v.img_id
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_TOUSHI then				-- 头饰
			info.appearance.toushi_used_imageid = v.img_id
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_WING then				-- 羽翼
			info.appearance.wing_used_imageid = v.img_id + GameEnum.MOUNT_SPECIAL_IMA_ID
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_YAOSHI then				-- 腰饰
			info.appearance.yaoshi_used_imageid = v.img_id
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_SHIZHUANG_PART_0 then	-- 时装(武器)
			info.appearance.fashion_wuqi = v.img_id
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_SHIZHUANG_PART_1 then	-- 时装(衣服)
			info.appearance.fashion_body = v.img_id
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_JINGLING then			-- 仙宠
			sprit_res_id = v.img_res_id
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_XIANNV then				-- 伙伴
			goddess_res_id = v.img_res_id
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_FIGHT_MOUNT then			-- 战骑
			fight_mount_res_id = v.img_res_id
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_MOUNT then				-- 坐骑
			mount_res_id = v.img_res_id
		end
	end

	local list = {}
	list.role_info = info
	list.sprit_res_id = sprit_res_id
	list.goddess_res_id = goddess_res_id
	list.mount_res_id = mount_res_id
	list.fight_mount_res_id = fight_mount_res_id

	return list
end

-------------------------------套装结束---------------------------------
-------------------------------套装属性---------------------------------
--得到套装属性面板的显示数据
function ClothespressData:GetSuitAttrDataListBySuitIndex(suit_index)
	local data_ist = {}
	local suit_cfg = self:GetAllSuitCfg()
	if nil == suit_index or nil == next(self.suit_cfg) or nil == self.suit_cfg[suit_index] then
		return data_ist
	end

	local desc = self.suit_cfg[suit_index].suit_effect or ""
	local attr = self:GetSingleSuitAttrySuitIndex(suit_index)
	local part_num = self:GetSingleSuitPartNumBySuitIndex(suit_index)
	local active_part_num = self:GetSingleSuitActivePartNum(suit_index)
	data_ist.desc = desc
	data_ist.attr = attr
	data_ist.part_num = part_num
	data_ist.active_part_num = active_part_num

	return data_ist
end

function ClothespressData:GetAttrList()
	local attr = {}
	attr.sheng_ming = 0
	attr.gong_ji = 0
	attr.fang_yu = 0
	attr.power = 0

	return attr
end

function ClothespressData:GetSingleSuitAttrySuitIndex(suit_index)
	local attr = self:GetAttrList()
	local single_suit_cfg = self:GetSingleSuitPartCfgBySuitIndex(suit_index)

	for k,v in pairs(single_suit_cfg) do
		local img_id = v.img_id or 0
		local suit_system_type = v.suit_system_type or 0
		local single_attr = self:GetSingleSuitPartAttr(img_id, suit_system_type)
		attr.sheng_ming = attr.sheng_ming + single_attr.sheng_ming
		attr.gong_ji = attr.gong_ji + single_attr.gong_ji
		attr.fang_yu = attr.fang_yu + single_attr.fang_yu
		attr.power = attr.power + single_attr.power
	end

	return attr
end

function ClothespressData:GetSingleSuitPartAttr(img_id, suit_system_type)
	local fight_power = 0
	local cfg = {}
	local attr = self:GetAttrList()

	if suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_CLOAK then    				-- 披风
		cfg = CloakData.Instance:GetSpecialImageUpgradeInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_FIGHT_MOUNT then		-- 战骑
		cfg = FightMountData.Instance:GetSpecialImageUpgradeInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_FOOTPRINT then			-- 足迹
		cfg = FootData.Instance:GetSpecialImageUpgradeInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_HALO then				-- 光环
		cfg = HaloData.Instance:GetSpecialImageUpgradeInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_LINGZHU then			-- 灵珠
		cfg = LingZhuData.Instance:GetHuanHuaCfgInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_MASK then				-- 面饰
		cfg = MaskData.Instance:GetHuanHuaCfgInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_MOUNT then				-- 坐骑
		cfg = MountData.Instance:GetSpecialImageUpgradeInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_QILINBI then			-- 麒麟臂
		cfg = QilinBiData.Instance:GetHuanHuaCfgInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_SHENGONG then			-- 神弓
		cfg = ShengongData.Instance:GetSpecialImageUpgradeInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_SHENYI then			-- 神翼
		cfg = ShenyiData.Instance:GetSpecialImageUpgradeInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_TOUSHI then			-- 头饰
		cfg = TouShiData.Instance:GetHuanHuaCfgInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_WING then				-- 羽翼
		cfg = WingData.Instance:GetSpecialImageUpgradeInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_XIANBAO then			-- 仙宝
		cfg = XianBaoData.Instance:GetHuanHuaCfgInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_YAOSHI then			-- 腰饰
		cfg = WaistData.Instance:GetHuanHuaCfgInfo(img_id, 1)	
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_JINGLING then			-- 仙宠
		cfg = SpiritData.Instance:GetSpiritHuanhuaCfgById(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_XIANNV then			-- 伙伴
		cfg = GoddessData.Instance:GetXianNvHuanHuaLevelCfg(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_SHIZHUANG_PART_0 then 	-- 时装:武器
		cfg = FashionData.Instance:GetFashionUpgradeCfg(img_id, 0, false, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_SHIZHUANG_PART_1 then	-- 时装:衣服
		cfg = FashionData.Instance:GetFashionUpgradeCfg(img_id, 1, false, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_MULIT_MOUNT then		-- 双骑
		cfg = MultiMountData.Instance:GetSpecialImageUpgradeInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_LINGGONG then			-- 灵弓
		cfg = LingGongData.Instance:GetHuanHuaCfgInfo(img_id, 1)	
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_LINGQI then			-- 灵骑
		cfg = LingQiData.Instance:GetHuanHuaCfgInfo(img_id, 1)	
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_LINGCHONG then			-- 灵宠
		cfg = LingChongData.Instance:GetHuanHuaCfgInfo(img_id, 1)
	end

	if nil == cfg then return attr end

	local attr_cfg = CommonDataManager.GetAttributteByClass(cfg)
	fight_power = CommonDataManager.GetCapabilityCalculation(attr_cfg)
	if attr_cfg.max_hp then
		attr.sheng_ming = attr_cfg.max_hp
		attr.gong_ji = attr_cfg.gong_ji
		attr.fang_yu = attr_cfg.fang_yu
	end
	attr.power = fight_power

	return attr
end
-----------------------------套装属性结束-------------------------------