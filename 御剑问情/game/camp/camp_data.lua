CampData = CampData or BaseClass()
function CampData:__init()
	if CampData.Instance ~= nil then
		print_error("[CampData] attempt to create singleton twice!")
		return
	end
	CampData.Instance = self
	self.camp_scene_info = {}
	self.camp_equip_list = {}
	self.beast_level = 0
	self.beast_exp = 0
	self.camp_info = {}										--阵营信息
	self.camp_info_power = {}								--阵营实力信息
	self.statue_info = {									--阵营雕像信息
		self_hurt = 0,
		statue_attr = {{hp = 0, maxhp = 0}, {hp = 0, maxhp = 0}, {hp = 0, maxhp = 0}},
		rank_list ={},
		camp_statue_list = {},								--雕像信息{{roleid, name, hp, max_hp, prof, sex}}
	}

	self.notify_datalist_change_callback_list = {} 	--物品列表有变化时回调，一般是整理时，或初始化物品列表时
	self.notify_data_change_callback_list = {}
end

function CampData:__delete()
	CampData.Instance = nil
	self.camp_scene_info = {}
	self.notify_datalist_change_callback_list = {}
	self.notify_data_change_callback_list = {}
end

--绑定数据改变时的回调方法.用于任意物品有更新时进行回调
function CampData:NotifyDataChangeCallBack(callback, notify_datalist)
	if notify_datalist == true then
		for k,v in pairs(self.notify_datalist_change_callback_list) do
			if v == callback then
				return
			end
		end
		self.notify_datalist_change_callback_list[#self.notify_datalist_change_callback_list + 1] = callback
	else
		for k,v in pairs(self.notify_data_change_callback_list) do
			if v == callback then
				return
			end
		end
		self.notify_data_change_callback_list[#self.notify_data_change_callback_list + 1] = callback
		if #self.notify_data_change_callback_list >= 30 then
			print_log(string.format("监听物品数据的地方多达%d条，请检查！",#self.notify_data_change_callback_list))
		end
	end
end

--移除绑定回调
function CampData:UnNotifyDataChangeCallBack(callback)
	for k,v in pairs(self.notify_data_change_callback_list) do
		if v == callback then
			self.notify_data_change_callback_list[k] = nil
			return
		end
	end
	for k,v in pairs(self.notify_datalist_change_callback_list) do
		if v == callback then
			self.notify_datalist_change_callback_list[k] = nil
			return
		end
	end
end

function CampData:GetHunlianCfg(index, level)
	local hunlian_cfg = ConfigManager.Instance:GetAutoConfig("campconfg_auto").camp_equip_hunlian
	for k,v in pairs(hunlian_cfg) do
		if index == v.equip_index and level == v.level then
			return v
		end
	end
	return nil
end

function CampData.IsCampEquip(sub_type)
	if sub_type == GameEnum.E_TYPE_CAMP_TOUKUI or
		sub_type == GameEnum.E_TYPE_CAMP_YIFU or
		sub_type == GameEnum.E_TYPE_CAMP_HUTUI or
		sub_type == GameEnum.E_TYPE_CAMP_XIEZI or
		sub_type == GameEnum.E_TYPE_CAMP_HUSHOU or
		sub_type == GameEnum.E_TYPE_CAMP_XIANGLIAN or
		sub_type == GameEnum.E_TYPE_CAMP_WUQI or
		sub_type == GameEnum.E_TYPE_CAMP_JIEZHI then
		return true
	end
	return false
end

function CampData:SetCampInfo(info)
	self.camp_info = info
end

function CampData:SetCampPowerInfo(info)
	self.camp_info_power = info
end

--获得阵营实力信息
function CampData:GetCampPowerInfo()
	return self.camp_info_power
end

-- 推荐加入阵营(战力=>人数)
function CampData:GetRecommendCamp()
	local recommend = 1
	local min_power = nil
	local min_count = nil
	for k, power in pairs(self.camp_info_power) do
		local count = self.camp_info[k]
		if min_power == nil then
			min_power = power
			min_count = count
			recommend = k
		else
			if power < min_power then
				min_power = power
				min_count = count
				recommend = k
			elseif power == min_power and count < min_count then
				min_power = power
				min_count = count
				recommend = k
			end
		end
	end
	return recommend
end

--穿戴的军团装备
function CampData:GetCampEquipList()
	return self.camp_equip_list
end

--获得某个格子的数据
function CampData:GetGridData(index)
	return self.camp_equip_list[index]
end

function CampData:SetCampEquipList(list)
	for k,v in pairs(list) do
		self.camp_equip_list[v.index] = v
	end

	for k, v in pairs(self.notify_datalist_change_callback_list) do
		v()
	end
end

function CampData:SetBeastLevel(level)
	self.beast_level = level
end

function CampData:GetBeastLevel()
	return self.beast_level
end

function CampData:SetBeastExp(exp)
	self.beast_exp = exp
end

function CampData:GetBeastExp()
	return self.beast_exp
end

--背包军团装备数据
function CampData:GetCampBagItemDataList()
	local bag_item_data_list = {}
	local bag_item_index_count = 0
	local role_bag_data_list = ItemData.Instance:GetBagItemDataList()
	for k, v in pairs(role_bag_data_list) do
		local item_config = ItemData.Instance:GetItemConfig(v.item_id)
		if nil ~= item_config and CampData.IsCampEquip(item_config.sub_type) then
			bag_item_data_list[bag_item_index_count] = v
			bag_item_index_count = bag_item_index_count + 1
		end
	end
	return bag_item_data_list
end

function CampData.GetEquipBg(index)
	if index == GameEnum.E_INDEX_CAMP_TOUKUI then
		return "HelmetBG"
	elseif index == GameEnum.E_INDEX_CAMP_YIFU then
		return "ClothesBG"
	elseif index == GameEnum.E_INDEX_CAMP_HUTUI then
		return "LegGuardBG"
	elseif index == GameEnum.E_INDEX_CAMP_XIEZI then
		return "ShoesBG"
	elseif index == GameEnum.E_INDEX_CAMP_HUSHOU then
		return "GlovesBG"
	elseif index == GameEnum.E_INDEX_CAMP_XIANGLIAN then
		return "NecklaceBG"
	elseif index == GameEnum.E_INDEX_CAMP_WUQI then
		return "WeaponsBG"
	elseif index == GameEnum.E_INDEX_CAMP_JIEZHI then
		return "RingBG"
	end
end

function CampData:GetShenShouConfig(level)
	local shenshou_cfg = ConfigManager.Instance:GetAutoConfig("campconfg_auto").camp_beast
	for k,v in pairs(shenshou_cfg) do
		if level == v.level then
			return v
		end
	end
	return nil
end

function CampData:GetIsFlyUpMaxLevel(level)
	return nil == self:GetShenShouConfig(level + 1)
end

function CampData:GetEquipMonsterExp(item_id_in_client)
	local exp = 0
	local item = ItemData.Instance:GetItemConfig(item_id_in_client)
	if nil ~= item and nil ~= item.search_type and item.search_type == 104 then
		if item_id_in_client ~= nil then
			local cfg = ConfigManager.Instance:GetAutoConfig("campconfg_auto").camp_equip_recyle
			for k1, v1 in pairs (cfg) do
				if item.limit_level == v1.limit_level and item.color == v1.color then
					exp = exp + v1.experience
				end
			end
		end
	end
	return exp
end

-- 根据当前层普通夺宝配置
function CampData:GetCaveCfgByLayer(cur_layer)
	local nor_boss_cfg = ConfigManager.Instance:GetAutoConfig("campconfg_auto").normalduobao
	local camp = GameVoManager.Instance:GetMainRoleVo().camp
	for k,v in pairs(nor_boss_cfg) do
		if v.camp == camp and v.layer == (cur_layer) then
			return v
		end
	end
end
-- 获取普通夺宝配置
function CampData:GetCaveCfg()
	local nor_boss_cfg = ConfigManager.Instance:GetAutoConfig("campconfg_auto").normalduobao
	local camp = GameVoManager.Instance:GetMainRoleVo().camp
	local boss_list = {}
	for i,v in ipairs(nor_boss_cfg) do
		if v.camp == camp then
			boss_list[v.layer] = v
		end
	end
	return boss_list
end

-- 设置当前查询boss数量
function CampData:SetRecordCurLayerBossInfo(protocol)
	local scene_id = protocol.scene_id

	local count = 0
	for k,v in pairs(protocol.boss_list) do
		if 0 == v.next_refresh_time then
			count = count + 1
		end
	end
	self.camp_scene_info[scene_id] = count
end

-- 获取场景boss数量
function CampData:GetRecordCurLayerBossInfo(scene_id)
	return self.camp_scene_info[scene_id] or 10
end

function CampData:GetStatueSceneId(camp)
	local other_cfg = ConfigManager.Instance:GetAutoConfig("campconfg_auto").other[1]
	return other_cfg["dx_sceneid" .. camp] or 0
end

--雕像信息
function CampData:SetStatueInfo(info)
	if info.self_hurt ~= nil then
		self.statue_info.self_hurt = info.self_hurt
	end
	if info.statue_attr ~= nil then
		self.statue_info.statue_attr = info.statue_attr
	end
	if info.rank_list ~= nil then
		self.statue_info.rank_list = info.rank_list
	end
	if info.camp_statue_list ~= nil then
		self.statue_info.camp_statue_list = info.camp_statue_list
	end
	--print_log("***************** SetStatueInfo() ", TabToStr(info.camp_statue_list, true))
end

function CampData:GetStatueInfo()
	return self.statue_info
end

function CampData.ShowCampStatueFollow()
	local scene_id = Scene.Instance:GetSceneId()
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.CAMP_DEFEND1) and scene_id == CampData.Instance:GetStatueSceneId(1) then
		return true
	elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.CAMP_DEFEND2) and scene_id == CampData.Instance:GetStatueSceneId(2)  then
		return true
	elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.CAMP_DEFEND3) and scene_id == CampData.Instance:GetStatueSceneId(3)  then
		return true
	end
	return false
end