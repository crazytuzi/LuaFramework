RefineData = RefineData or BaseClass()

local attr_colors = {
    [COLOR3B.GREEN] = {
        GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MIN_ADD,
        GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MIN_POWER,
        GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MAX_ADD,
        GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MAX_POWER,
        GAME_ATTRIBUTE_TYPE.MAGIC_ATTACK_MIN_ADD,
        GAME_ATTRIBUTE_TYPE.MAGIC_ATTACK_MIN_POWER,
        GAME_ATTRIBUTE_TYPE.MAGIC_ATTACK_MAX_ADD,
        GAME_ATTRIBUTE_TYPE.MAGIC_ATTACK_MAX_POWER,
        GAME_ATTRIBUTE_TYPE.WIZARD_ATTACK_MIN_ADD,
        GAME_ATTRIBUTE_TYPE.WIZARD_ATTACK_MIN_POWER,
        GAME_ATTRIBUTE_TYPE.WIZARD_ATTACK_MAX_ADD,
        GAME_ATTRIBUTE_TYPE.WIZARD_ATTACK_MAX_POWER,
    },

    [COLOR3B.WHITE] = {
        GAME_ATTRIBUTE_TYPE.PHYSICAL_DEFENCE_MIN_ADD,
        GAME_ATTRIBUTE_TYPE.PHYSICAL_DEFENCE_MIN_POWER,
        GAME_ATTRIBUTE_TYPE.PHYSICAL_DEFENCE_MAX_ADD,
        GAME_ATTRIBUTE_TYPE.PHYSICAL_DEFENCE_MAX_POWER,
        GAME_ATTRIBUTE_TYPE.MAGIC_DEFENCE_MIN_ADD,
        GAME_ATTRIBUTE_TYPE.MAGIC_DEFENCE_MIN_POWER,
        GAME_ATTRIBUTE_TYPE.MAGIC_DEFENCE_MAX_ADD,
        GAME_ATTRIBUTE_TYPE.MAGIC_DEFENCE_MAX_POWER,
    },

    [COLOR3B.BLUE] = {
        GAME_ATTRIBUTE_TYPE.HP_ADD,
        GAME_ATTRIBUTE_TYPE.HP_POWER,
        GAME_ATTRIBUTE_TYPE.MAX_HP_ADD,
        GAME_ATTRIBUTE_TYPE.MAX_HP_POWER,
        GAME_ATTRIBUTE_TYPE.ATTACK_BOSS_CRIT_RATE,
        GAME_ATTRIBUTE_TYPE.ATTACK_BOSS_CRIT_VALUE,
        GAME_ATTRIBUTE_TYPE.DAMAGE_ADD_RATE,
        GAME_ATTRIBUTE_TYPE.DAMAGE_ADD_VALUE,
    },   
}

RefineData.LOOK_CHANGE = "look_change"

function RefineData:__init()
	if RefineData.Instance then
		ErrorLog("[RefineData]:Attempt to create singleton twice!")
	end
	
    RefineData.Instance = self
    GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

    -- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetCanRefineNum, self), RemindName.EquipRefine, true)
end

function RefineData:__delete()
    RefineData.Instance = nil
end

function RefineData:SetConsumeData()
    self:DispatchEvent(RefineData.LOOK_CHANGE)
end

function RefineData:GetShowNormalEquipData()
    local data_list = {}
	for i = EquipData.EquipIndex.Weapon, EquipData.EquipIndex.Shoes do
		local equip = EquipData.Instance:GetEquipDataBySolt(i - 1)
		local item_data = {equip = nil, remind = false}
        if equip then
            item_data.equip = equip
            item_data.remind = RefineData.EquipCanRefine(equip)
        end
		table.insert(data_list, item_data)
    end
    return data_list
end

function RefineData:GetCurSelectIndex()
	local data_list = self:GetShowNormalEquipData()
	for i,v in ipairs(data_list) do
		if v and v.equip then
			return i
		end
	end
	return 0
end

function RefineData:GetShowAttrDataFromEquip(equip)
    local data_list = {}
    if equip and equip.refine_count and equip.refine_count > 0 then
        for i = 1, equip.refine_count do
            local data = {is_open = false, open_circle = 0, refine_attr = nil, max_value = 0}
            data.open_circle = 2 * (i + 1) - 1
            local eq_level, eq_circle = ItemData.GetItemLevel(equip.item_id)
            data.is_open = eq_circle >= data.open_circle 
            
            data.attr_str = {type_str = Language.Role.BuffAttrName[equip.refine_attr[i].type] or "", 
                            value_str = RoleData.FormatValueStr(equip.refine_attr[i].type, equip.refine_attr[i].value) }
            data.refine_attr = equip.refine_attr[i]
            if data.refine_attr then
                local skill_id = RefineData.GetSkillIdAndLevel(data.refine_attr.value)
                -- local skill_id = bit:_and(data.refine_attr.value, 0x00ff)
                data.max_value = self:GetMaxAttrValue(eq_circle, i, data.refine_attr.type, skill_id)
            end
            table.insert(data_list, data)
        end
    end
    return data_list
end

function RefineData:GetMaxAttrValue(circle, attr_index, type, value)
    local cfg_index = RefineData.GetCfgIndex(circle)
    if SmithConfig[cfg_index] then
        for i, v in ipairs(SmithConfig[cfg_index][attr_index]) do
            if type == v.type then
                if type == GAME_ATTRIBUTE_TYPE.ADD_SKILL_LEVEL then
                    if value == v.value then
                        return v.max_value
                    end
                else
                    return v.max_value
                end
            end
        end
    end
    return 0
end

function RefineData.GetCfgIndex(circle)
    for k, v in pairs(SmithConsumeCfg) do
        if circle == v.equipCircle[1] or circle == v.equipCircle[2] then
            return k
        end
    end
    return 0
end

function RefineData.GetRefineConsume(index)
    return SmithConsumeCfg[index] and SmithConsumeCfg[index].smithConsumes
end

function RefineData.GetLockConsume(index)
    return SmithConsumeCfg[index] and SmithConsumeCfg[index].lockConsumes
end

function RefineData.IsRefineEquip(type, hand_pos)
    local index = EquipData.Instance:GetEquipIndexByType(type, hand_pos)
    if index >= EquipData.EquipIndex.Weapon and index <= EquipData.EquipIndex.Shoes then
        return true
    end
    
    return false
end


function RefineData.GetAttrColor(type, value, max_value)
    if type == GAME_ATTRIBUTE_TYPE.ADD_SKILL_LEVEL then
        return COLOR3B.RED
    end

    local color = COLOR3B.WHITE
    if value >= max_value / 2 then
        color = COLOR3B.ORANGE
    else
        for k, v in pairs(attr_colors) do
            if IsInTable(type, v) then
                color = k
                break
            end
        end
    end
    return color
end

function RefineData.GetSkillIdAndLevel(value)
    local skill_id = bit:_and(value, 0x00ff)
    local level = bit:_and(bit:_rshift(value, 8), 0x00ff)
    return skill_id, level
end

function RefineData.EquipCanRefine(equip)
    if not equip then return false end

    local _, circle = ItemData.GetItemLevel(equip.item_id)
    local cfg_index = RefineData.GetCfgIndex(circle)
    
    if cfg_index == 0 then return false end
    
    local refine_attr_data = RefineData.Instance:GetShowAttrDataFromEquip(equip)
    local total_count = 0
    for i = 1, #refine_attr_data do
        if refine_attr_data[i].is_open then
            local consume_cfg = RefineData.GetRefineConsume(cfg_index)
            total_count = total_count + consume_cfg[i].count
        end
    end

    local num = BagData.Instance:GetItemNumInBagById(2541)
    return num >= total_count
end

function RefineData:GetCanRefineNum()
    local num = 0
    for i = EquipData.EquipIndex.Weapon, EquipData.EquipIndex.Shoes do
        local equip = EquipData.Instance:GetEquipDataBySolt(i - 1)
        if RefineData.EquipCanRefine(equip) then
            num = num + 1
        end
    end
    return num
end