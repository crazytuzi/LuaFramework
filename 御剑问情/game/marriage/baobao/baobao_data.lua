
BaobaoData = BaobaoData or BaseClass()
BaobaoData.Attr = {"gong_ji", "max_hp", "fang_yu", "ming_zhong",  "shan_bi",  "bao_ji", "jian_ren"}
BaobaoData.BabyModel = {10997001, 10998001, 10999001}
function BaobaoData:__init()
	if BaobaoData.Instance then
		print_error("[BaobaoData] Attemp to create a singleton twice !")
	end
	BaobaoData.Instance = self

	local baby_cfg = ConfigManager.Instance:GetAutoConfig("baby_cfg_auto")

	self.baby_other_cfg = baby_cfg.other[1]
	self.baby_info_cfg = baby_cfg.baby_info
	self.baby_upgrade_cfg = baby_cfg.baby_upgrade
    self.max_grade = #self.baby_upgrade_cfg - 1
	self.baby_uplevel_cfg = ListToMap(baby_cfg.baby_uplevel, "id", "level")
	self.qifu_tree_cfg = baby_cfg.qifu_tree
	self.baby_spirit_cfg = baby_cfg.baby_spirit
	self.baby_chaosheng_cfg= baby_cfg.baby_chaosheng

	self.super_baby_cfg = baby_cfg.super_baby_info
	self.super_baby_grade_cfg = ListToMap(baby_cfg.super_baby_upgrade, "grade")
	self.super_baby_max_garde = 0
	self:CalcSuperBabyMaxGrade()

	self.baby_list = {}
	self.seq_select_index = 0
	self.spirit_index = 0
	self.all_baby_sprite_list = {}
	self.little_target_award_flag = -1
	self.super_award_flag = -1
	self.func_open_timestamp = 0

	RemindManager.Instance:Register(RemindName.MarryBaoBaoAttr, BindTool.Bind(self.GetAttrPanelRedPoint, self))
	RemindManager.Instance:Register(RemindName.MarryBaoBaoZiZhi, BindTool.Bind(self.GetZiZhiPanelRedPoint, self))
	RemindManager.Instance:Register(RemindName.MarryBaoBaoGuard, BindTool.Bind(self.GetGuradRedPointNew, self))
end

function BaobaoData:__delete()
	BaobaoData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.MarryBaoBaoAttr)
	RemindManager.Instance:UnRegister(RemindName.MarryBaoBaoZiZhi)
	RemindManager.Instance:UnRegister(RemindName.MarryBaoBaoGuard)
end

--计算超级宝宝最大等级
function BaobaoData:CalcSuperBabyMaxGrade()
	for k, _ in pairs(self.super_baby_grade_cfg) do
		if k > self.super_baby_max_garde then
			self.super_baby_max_garde = k
		end
	end
end

function BaobaoData:GetSuperBabyMaxGrade()
	return self.super_baby_max_garde
end

function BaobaoData:SetBabyInfo(protocol)
	self.baby_list[protocol.baby_info.baby_index + 1] = protocol.baby_info
	self.seq_select_index = protocol.baby_info.baby_index + 1
	self.all_baby_sprite_list[protocol.baby_info.baby_index] = protocol.baby_info.baby_spirit_list
	self:SetSelectedBabyDefaultIndex()
end

function BaobaoData:SetBabyAllInfo(protocol)
	self.baby_list = protocol.baby_list or {}

	for k,v in pairs(self.baby_list) do
		self.all_baby_sprite_list[v.baby_index] = v.baby_spirit_list
	end
	self.baby_chaosheng_count = protocol.baby_chaosheng_count
	self:SetSelectedBabyDefaultIndex()

	self.super_baby_info = protocol.super_baby_info

	self.func_open_timestamp = protocol.func_open_timestamp
end

function BaobaoData:GetBabyChaoShengCount()
	return self.baby_chaosheng_count
end

function BaobaoData:GetBabyInfo(baby_index)
	if nil == self.baby_list[baby_index] then return end

	return self.baby_list[baby_index]
end

function BaobaoData:GetBabyLevelCfg(baby_id, level)
    if nil == baby_id or nil == level or self.baby_uplevel_cfg[baby_id] == nil then return end

    return self.baby_uplevel_cfg[baby_id][level]
end

function BaobaoData:GetBabyUpgradeCfg(grade)
	if nil == grade then return end

	return self.baby_upgrade_cfg[grade + 1]
end

-- 只需要三个属性显示，别的属于隐藏属性
function BaobaoData:GetBabyInfoCfgList()
	local baby_cfg = {}
	for k,v in pairs(self.baby_info_cfg) do
		baby_cfg.maxhp = v.maxhp
		baby_cfg.gongji = v.gongji
		baby_cfg.fangyu = v.fangyu
	end
	return baby_cfg
end

function BaobaoData:GetBabyInfoCfg(id)
	return self.baby_info_cfg[id]
end

function BaobaoData:GetBabyQiFuTreeCfg()
	return self.qifu_tree_cfg
end

-- 宝宝属性-----------------------------------
function BaobaoData:SetSelectedBabyIndex(index)
	self.selected_baby_index = index
end
function BaobaoData:SetSelectedBabyDefaultIndex()
	local list = self:GetListBabyData()
	if self.selected_baby_index == nil then    
	   if list[1] then
			self.selected_baby_index = list[1].baby_index + 1
	   end
   else
		local is_del = true
		for k,v in pairs(list) do
		   if v.baby_index + 1 == self.selected_baby_index then
				is_del = false
		   end
		end

		if is_del then
			self.selected_baby_index = nil
			self:SetSelectedBabyDefaultIndex()
		end
	end 
end

function BaobaoData:GetSelectedBabyIndex()
	if self.selected_baby_index == nil then
	   local list = self:GetListBabyData()
	   if list[1] then
			self.selected_baby_index = list[1].baby_index + 1
	   end
	end 
	return self.selected_baby_index or 1
end

function BaobaoData:GetSelectedBabyInfo()
	if nil == self.selected_baby_index then return end
	local baby_data = self:GetListBabyData()
	if baby_data and #baby_data > 0 then
		for k,v in pairs(self:GetListBabyData()) do
			if v.baby_index + 1 == self.selected_baby_index then
				return v
			end
		end
	end
	return nil
end

function BaobaoData:GetAptitudeCfg(id,level)
	local common_attr = CommonStruct.Attribute()
	local cur_cfg = self:GetBabyLevelAttribute(id,level)
	local next_cfg = self:GetBabyLevelAttribute(id,level+1)
	local cur_attr = CommonDataManager.GetAttributteByClass(cur_cfg)
	local next_attr = CommonDataManager.GetAttributteByClass(next_cfg)
	local lerp_attr = CommonDataManager.LerpAttributeAttr(cur_attr, next_attr)    -- 属性差
	local data = {}
	for k,v in pairs(common_attr) do
		if lerp_attr[k] > 0 then
			local attr_data = {name = k,cur_value = cur_attr[k],next_value = lerp_attr[k]}
			table.insert(data,attr_data)
		end
		if cur_attr[k] >0 and lerp_attr[k] <= 0 then
			local attr_data = {name = k,cur_value = cur_attr[k],next_value = lerp_attr[k]}
			table.insert(data,attr_data)
		end
	end
	return data
end

function BaobaoData:GetListBabyData()
	local data_list = {}
	local data_index = 1
	for i = 1, GameEnum.BABY_MAX_COUNT do
		local data = self:GetBabyInfo(i)
		if nil == data then return {} end
		data.sort = 1
		if data.baby_id ~= -1 then
			local love_name = self:GetLoveID()
			if love_name == data.lover_name then
				data.sort = 0
			end
			data_list[data_index] = data
			table.sort(data_list, SortTools.KeyLowerSorters("sort","baby_index"))
			data_index = data_index + 1
		end
	end
	return data_list
end

function BaobaoData:GetGridUpgradeStuffDataList()
	if nil == self.selected_baby_index then return end

	local data_list = {}
	local baby_info = self:GetBabyInfo(self.selected_baby_index)
	if nil == baby_info then return end

	local level_cfg = self:GetBabyLevelCfg(baby_info.baby_id, baby_info.level)
	if nil == level_cfg then return end

	for i = 0, 3 do
		local data = {}
		data.item_id = level_cfg["uplevel_consume_item_" .. i + 1]
		data.nedd_stuff_num = level_cfg["uplevel_consume_num_" .. i + 1]
		data.is_bind = 0
		data_list[i] = data
	end

	return data_list
end

function BaobaoData:GetBabyLevelAttribute(baby_id, level)
	local baby_cfg_list = BaobaoData.Instance:GetBabyInfoCfgList()
	local base_attr = CommonDataManager.GetAttributteByClass(baby_cfg_list[baby_id])
	local level_attr = CommonDataManager.GetAttributteByClass(self:GetBabyLevelCfg(baby_id, level))
	return CommonDataManager.AddAttributeAttr(base_attr, level_attr)
end

function BaobaoData:GetBabyJieAttribute(grade)
	return CommonDataManager.GetAttributteByClass(self:GetBabyUpgradeCfg(grade))
end

function BaobaoData:GetBabyAllAttribute(baby_id, level, grade)
	local level_attr = self:GetBabyLevelAttribute(baby_id, level)
	local grade_attr = CommonDataManager.GetAttributteByClass(self:GetBabyUpgradeCfg(grade))
	return CommonDataManager.AddAttributeAttr(level_attr, grade_attr)
end

function BaobaoData:GetBaoBaoRemind()
	local falg_1 = self:GetAttrRedPoint()
	if falg_1 then
		return 1
	end
	return 0

end

function BaobaoData:GetAttrPanelRedPoint()
	local attr_red_point = self:GetAttrRedPoint()
	if attr_red_point <= 0 then
		local little_target_remind = self:CalcLittleTargetRemind()
		if little_target_remind > 0 then
			return little_target_remind
		end
		return self:CalcSuperBabyRemind()
	end
	return attr_red_point
end

function BaobaoData:GetZiZhiPanelRedPoint()
    local aptitude_red_point = self:GetAptitudeRedPoint()
    return aptitude_red_point
end

function BaobaoData:GetMaxBabyGrade()
    return self.max_grade
end

function BaobaoData:GetAttrRedPoint()
    local value = 0
    local baby_list = self:GetListBabyData() or {}
    local upgrade_cfg = {}
    local item_num = 0
    local index = 0
    local lover_name = self:GetLoveID()
    local baby_can_upgrade = {}
    for k,v in pairs(baby_list) do
        if tonumber(v.grade) < self.max_grade and lover_name == v.lover_name then
            upgrade_cfg = self:GetBabyUpgradeCfg(v.grade)
            if nil == upgrade_cfg then return 0 end
            item_num = ItemData.Instance:GetItemNumInBagById(upgrade_cfg.consume_stuff_id)
            if upgrade_cfg.consume_stuff_num <= item_num then
               value = 1
               baby_can_upgrade[index] = 1
            else
               baby_can_upgrade[index] = 0
            end
        else
            baby_can_upgrade[index] = 0
        end
        index = index + 1
    end
    self.can_up_grade = baby_can_upgrade
    return value
end

function BaobaoData:GetAptitudeRedPoint()
	local baby_list = self:GetListBabyData() or {}
	local max_length = self:GetMaxBabyUpleveCfgLength()
	local index = 0
	local redpoint_xount = 0
	local redpoint_list = {}
	local lover_name = self:GetLoveID()
	if #baby_list <= 0 then
		return 0
	end

	for k,v in pairs(baby_list) do
		if v.level < max_length and lover_name == v.lover_name  then
			local up_level_config = self:GetBabyLevelCfg(v.baby_id,v.level)
			if nil == up_level_config then return end

			local item_list = {}
			local count = 0
			for i = 1 , 4 do
				item_list[i] = ItemData.Instance:GetItemNumInBagById(up_level_config["uplevel_consume_item_"..i])
				if up_level_config["uplevel_consume_num_"..i] <= item_list[i] then
				   count = count + 1
				   redpoint_xount = redpoint_xount + 1
				end
			end
			if count >= 4 then
				redpoint_list[index] = 1
			else
				redpoint_list[index] = 0
			end
		else
			redpoint_list[index] = 0
		end
		index = index + 1
	end

	self.aptitude_redpoint_list = redpoint_list
	for k,v in pairs(self.aptitude_redpoint_list) do
		if v == 1 then
			return 1
		end
	end

	return 0
end

function BaobaoData:GetGuradRedPointNew()
	local hava_baobao_data = self:GetHaveBaoBaoData()
	local red_point_list = {}
	local flag = 0
	local lover_name = self:GetLoveID()

	for k,v in pairs(hava_baobao_data) do
		if lover_name == v.lover_name then
			local value = self:GetBaobaoRedPointForSpirit(k)
			red_point_list[k-1] = value
			flag = flag + value
		end
	end
	self.gurad_red_point_list = red_point_list
	return flag
end

function BaobaoData:GetGuradRedPointList()
	return self.gurad_red_point_list
end

-- 宝宝list红点（守护精灵用）
function BaobaoData:SetBaobaoRedPoint(index)
	local red_t = {}
	local hava_baobao_data = self:GetHaveBaoBaoData()
	local lover_name = self:GetLoveID()
	if hava_baobao_data[index] then
		if hava_baobao_data[index].lover_name == lover_name then
			local spirit_list = hava_baobao_data[index].baby_spirit_list or {}    
			for k,v in pairs(spirit_list) do
				local spirt_cfg = self:GetBabySpiritCfg(k, v.spirit_level + 1)
				if spirt_cfg then
					local item_num = ItemData.Instance:GetItemNumInBagById(spirt_cfg.consume_item)
					if item_num >= spirt_cfg.train_val - v.spirit_train then
						red_t[k] = true
					end
				end
			end
		end
	end
	local num = next(red_t) == nil  and 0 or 1
	return num, red_t
end

function BaobaoData:GetBaobaoRedPointForSpirit(index)
	local hava_baobao_data = self:GetHaveBaoBaoData()
	local spirit_list = hava_baobao_data[index].baby_spirit_list
	local cur_attr = {}
	local train_val = 0
	local spirit_train = 0
	local spirit_has_count = 0
	local consume_item_id = 0
	local level = 0
	local max_level = self:GetBabySpiritMaxLevel() 
	local value = 0

	for k,v in pairs(spirit_list) do

		if v.spirit_level < max_level then   
			level = v.spirit_level == 0 and 1 or v.spirit_level + 1
			cur_attr = self:GetBabySpiritAttrCfg(k,level)
			train_val = cur_attr.train_val
			spirit_train = v.spirit_train
			spirit_has_count = train_val - spirit_train
			consume_item_id = cur_attr.consume_item
			local item_num = ItemData.Instance:GetItemNumInBagById(consume_item_id)

			if item_num >= spirit_has_count then
				return 1
			end
		end
	end
	return 0
end

--获取拥有的宝宝
function BaobaoData:GetHaveBaoBaoData()
	local data = {}
	for k,v in pairs(self.baby_list) do
		if v.baby_id >= 0 then
			table.insert(data,v)
		end
	end
	return data
end

function BaobaoData:GetBabyTotalAttr()
	local baby_list = self:GetListBabyData() or {}
	local total_attr = CommonStruct.Attribute()
	for k,v in pairs(baby_list) do
		local baby_info = self:GetBabyInfo(v.baby_index + 1)
		if nil == baby_info then return total_attr end

		local level_attr = self:GetBabyLevelAttribute(v.baby_id, baby_info.level)
		local jie_attr = self:GetBabyJieAttribute(baby_info.grade)
		local attr = CommonDataManager.AddAttributeAttr(level_attr, jie_attr)
		total_attr = CommonDataManager.AddAttributeAttr(total_attr, attr)
	end

	return total_attr
end

function BaobaoData:GetCapabilityLerp(cur_attr, next_attr)
	return CommonDataManager.GetCapability(CommonDataManager.LerpAttributeAttr(cur_attr, next_attr), true)
end

function BaobaoData:GetBabyUpgradeCfgLength()
	return #self.baby_upgrade_cfg
end

----------宝宝守护精灵-------------
function BaobaoData:GetBabySpiritAttrCfg(id, level)
	local cfg = CommonStruct.Attribute()
	if self.baby_spirit_cfg == nil then return cfg end
	for k,v in pairs(self.baby_spirit_cfg) do
		if v.id == id and v.level == level then
			cfg = CommonDataManager.GetAttributteByClass(v)
			cfg.consume_item = v.consume_item
			cfg.train_val = v.train_val
			cfg.level = v.level
			cfg.name = v.name
			cfg.pack_num = v.pack_num
			break
		end
	end
	return cfg
end

function BaobaoData:GetBabySpiritCfg(id, level)
	for k,v in pairs(self.baby_spirit_cfg) do
		if v.id == id and v.level == level then
			return v
		end
	end
	return nil
end

function BaobaoData:GetMaxBabyUpleveCfgLength()
	local data_list = self.baby_uplevel_cfg
	local max_length = 0

    if data_list[1] then
        return #data_list[1]
    end

    return max_length
end

function BaobaoData:GetBabySpiritAttr(id,level)
	local common_attr = CommonStruct.Attribute()
	local cur_cfg = self:GetBabySpiritAttrCfg(id,level)
	local next_cfg = self:GetBabySpiritAttrCfg(id,level +1)
	local cur_attr = CommonDataManager.GetAttributteByClass(cur_cfg)
	local next_attr = CommonDataManager.GetAttributteByClass(next_cfg)
	local lerp_attr = CommonDataManager.LerpAttributeAttr(cur_attr, next_attr)    -- 属性差
	local data = {}
	for k,v in pairs(common_attr) do
		if lerp_attr[k] > 0 then
			local attr_data = {name = k,cur_value = cur_attr[k],next_value = lerp_attr[k]}
			table.insert(data,attr_data)
		end
		if cur_attr[k]>0 and lerp_attr[k]<=0 then
			local attr_data = {name = k,cur_value = cur_attr[k],next_value = lerp_attr[k]}
			table.insert(data,attr_data)
		end
	end
	return data
end

function BaobaoData:SetBabySpiritInfo(protocol)
	self.baby_index = protocol.baby_index
	self.baby_spirit_list = protocol.baby_spirit_list
	if self.baby_index ~= nil and self.baby_spirit_list ~= nil then
		self.all_baby_sprite_list[self.baby_index] = self.baby_spirit_list
		self.baby_list[self.baby_index+1].baby_spirit_list = self.baby_spirit_list
	end
 end

 function  BaobaoData:GetAllBabySpiritInfo()
	return self.all_baby_sprite_list
 end

 function BaobaoData:GetBabyTotalSpriteAttr()
	local total_attr = CommonStruct.Attribute()
	local baby_list = self:GetListBabyData()
	for k,v in pairs(baby_list) do
		for i=0,3 do
			local temp_attr = self:GetBabySpiritAttrCfg(i, v.baby_spirit_list[i].spirit_level)
			total_attr = CommonDataManager.AddAttributeAttr(total_attr, temp_attr)
		end
	end
	return total_attr
 end

 function BaobaoData:GetBabyChaoShengCount()
	return self.baby_chaosheng_count
 end

 function BaobaoData:GetBabyChaoShengCfg()
	return self.baby_chaosheng_cfg
 end

 function BaobaoData:GetCurSpiritLevel()
	local baby_select_index = self:GetSelectedBabyIndex()
	local all_baby_sprite_list = self:GetAllBabySpiritInfo()
	local spirit_level = all_baby_sprite_list[baby_select_index-1][self.spirit_index].spirit_level
	return spirit_level
end

function BaobaoData:SetCurSpiritIndex(index)
	self.spirit_index = index or 0
end

 function BaobaoData:GetBabyChaoShengGold()
	local chaosheng_count = self:GetBabyChaoShengCount()
	local chaosheng_cfg = self:GetBabyChaoShengCfg()
	for k,v in pairs(chaosheng_cfg) do
		if v.chaosheng_num == chaosheng_count + 1 then
			return v.need_gold
		end
	end
	return nil
 end

 function BaobaoData:GetBabyCfgAttr(attr)

 end

 -- 获取是否可继续生娃
function BaobaoData:GetCanBirthBaby()
	for k,v in pairs(self.baby_list) do
		if -1 ~= v.baby_id and v.grade < 4 then
			return false
		end
	end
	return true
end

function BaobaoData:GetBabySpiritMaxLevel()
	local max_level = 0
	for k,v in pairs(self.baby_spirit_cfg) do
		if v.id == 0 then
			max_level = max_level +1
		end
	end
	return max_level
end

function BaobaoData:GetLoveID()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	return main_role_vo.lover_name 
end

function BaobaoData:SetCurTabIndex(index)
	self.tab_index = index or 0
end

-- 获取当前的标签页
function BaobaoData:GetCurTabIndex()
	return self.tab_index
end

-- 宝宝信息配置
function BaobaoData:GetBaoBaoInfoCfg()
	return self.baby_info_cfg
end

function BaobaoData:GetBabyOtherCfg()
	return self.baby_other_cfg
end

--获取所有宝宝的基础属性加进阶属性总和
function BaobaoData:GetAllBabyAttrInfo()
	local all_attr_info = CommonStruct.AttributeNoUnderline()

	for k, v in pairs(self.baby_list) do
		if v.baby_id >= 0 then
			local normal_attr = self:GetBabyInfoCfg(v.baby_id)			--基础属性
			local jie_attr = self:GetBabyJieAttribute(v.grade)			--进阶属性

			all_attr_info.maxhp = all_attr_info.maxhp + normal_attr.maxhp + jie_attr.max_hp
			all_attr_info.fangyu = all_attr_info.fangyu + normal_attr.fangyu + jie_attr.fang_yu
			all_attr_info.gongji = all_attr_info.gongji + normal_attr.gongji + jie_attr.gong_ji
		end
	end

	return all_attr_info
end

function BaobaoData:SetSuperBabyInfo(super_baby_info)
	self.super_baby_info = super_baby_info
end

function BaobaoData:GetSuperBabyInfo()
	return self.super_baby_info
end

-- 0 不可领取 1 可以领取 2 已经领取
function BaobaoData:SetAwardFlag(protocol)
	self.little_target_award_flag = protocol.little_target_award_flag
	self.super_award_flag = protocol.award_flag
end

--是否可以领取小目标奖励
function BaobaoData:CanGetLittleTargetReward()
	return self.little_target_award_flag == 1
end

--是否可以领取超级宝宝奖励
function BaobaoData:CanGetSuperReward()
	return self.super_award_flag == 1
end

--计算小目标红点
function BaobaoData:CalcLittleTargetRemind()
	return self:CanGetLittleTargetReward() and 1 or 0
end

function BaobaoData:CalcSuperBabyRemind()
	--已激活不再处理
	if not self.super_baby_info or self:IsActiveSuperBaby() then
		return 0
	end

	--可领取的时候有红点
	if self:CanGetSuperReward() then
		return 1
	end

	--背包有相关升级物品的时候有红点
	local item_id = self:GetSuperBabyItemId()
	if ItemData.Instance:GetItemNumInBagById(item_id) > 0 then
		return 1
	end

	return 0
end

--是否已领取小目标奖励
function BaobaoData:IsFetchLittleTarget()
	return self.little_target_award_flag == 2
end

function BaobaoData:IsActiveSuperBaby()
	if self.super_baby_info then
		return self.super_baby_info.baby_id >= 0
	end

	return false
end

function BaobaoData:GetSuperBabyCfgInfo(baby_id)
	baby_id = baby_id or -1
	return self.super_baby_cfg[baby_id]
end

function BaobaoData:GetSuperBabyGradeCfg(grade)
	grade = grade or 0
	return self.super_baby_grade_cfg[grade]
end

function BaobaoData:GetSuperBabyItemId()
	return self.baby_other_cfg.sup_baby_card_item_id
end

function BaobaoData:GetSuperBabyResId(baby_id)
	local cfg_info = self:GetSuperBabyCfgInfo(baby_id)
	if cfg_info then
		return cfg_info.res_id
	end

	return 0
end

function BaobaoData:LeftTimeByTotalTime(total_time)
	if self.func_open_timestamp <= 0 then
		return 0
	end

	local server_time = TimeCtrl.Instance:GetServerTime()
	local last_time_stamp = self.func_open_timestamp + total_time
	return math.max(last_time_stamp - server_time, 0)
end