-------------------------------------------
-- 装备属性加成
-------------------------------------------
RoleRuleData = RoleRuleData or BaseClass()

function RoleRuleData:__init()
    if RoleRuleData.Instance then
        ErrorLog("[RoleRuleData] Attemp to create a singleton twice !")
    end
    RoleRuleData.Instance = self
    self.peerless_suit_plus_config = nil
end

function RoleRuleData:__delete()
    RoleRuleData.Instance = nil
end

function RoleRuleData:InitPeerlessSuitPlusConfig()
    self.peerless_suit_plus_config = {}
    local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
    for i, v in ipairs(PeerlessSuitPlusConfig) do
        if v.sex == sex then
            table.insert(self.peerless_suit_plus_config, v)
        end
    end
    return self.peerless_suit_plus_config
end

function RoleRuleData:GetPeerlessSuitPlusConfig()
    return self.peerless_suit_plus_config or self:InitPeerlessSuitPlusConfig()
end

function RoleRuleData.GetConfigData(index, level)
    if index == 1 then
        for i, v in ipairs(SlotPlusCfg) do
            if level == i then
                return v
            elseif level == 0 then
                if i == 1 then
                    return v
                end
            end
        end
    elseif index == 2 then
        for i, v in ipairs(StonePlusCfg) do
            if level == v.level then
                return v
            elseif level == 0 then
                if i == 1 then
                    return v
                end
            end
        end
    elseif index == 3 then
        for i, v in ipairs(LunHuiSuitAttrCfg) do
            if level == i then
                return v
            elseif level == 0 then
                if i == 1 then
                    return v
                end
            end
        end
    elseif index == 4 then
        for i, v in ipairs(BloodSlotPlusConfig) do
            if level == i then
                return v
            elseif level == 0 then
                if i == 1 then
                    return v
                end
            end
        end
    elseif index == 5 then
        for i, v in ipairs(RoleRuleData.Instance:GetPeerlessSuitPlusConfig()) do
            if level == i then
                return v
            elseif level == 0 then
                if i == 1 then
                    return v
                end
            end
        end
    elseif index == 6 then
        for i, v in ipairs(MoldingSoulPlusCfg) do
            if level == i then
                return v
            elseif level == 0 then
                if i == 1 then
                    return v
                end
            end
        end
    elseif index == 7 then
        for i, v in ipairs(ApotheosisPlusCfg) do
            if level == i then
                return v
            elseif level == 0 then
                if i == 1 then
                    return v
                end
            end
        end
    end
    return nil
end
function RoleRuleData.GetQiangHuaTipsLevel()
    local z = 0
    local level = QianghuaData.Instance:GetAllStrengthLevelIgnoreEquip()
    if level < 60 then
        return z
    elseif level >= 480 or level > 30 and level % 30 == 0 then
        return math.ceil((level - 60) / 30) + 1
    else
        return math.ceil((level - 60) / 30)
    end
end

function RoleRuleData.GetXueLianTipsLevel()
    local level = 0
    local all_xuelian = EquipmentData.Instance:GetAllBmStrengthLevel()
    for i, v in ipairs(BloodSlotPlusConfig) do
        if v.level <= all_xuelian then
            level = i
        else
            return level
        end
    end

    return level
end

function RoleRuleData.GetMoldingSoulTipsLevel()
    local level = 0
    local all_level = MoldingSoulData.Instance:GetAllMsStrengthLevel()
    for k, v in ipairs(MoldingSoulPlusCfg) do
        if v.count <= all_level then
            level = k
        else
            return level
        end
    end
    return level
end

function RoleRuleData.GetApotheosisTipsLevel()
    local level = 0
    for k, v in ipairs(ApotheosisPlusCfg) do
        local count = 0
        for k1, v1 in ipairs(AffinageData.Instance:GetAffinageLevelList()) do
            if v1 >= v.ApotheosisLv then
                count = count + 1
            end
        end
        if count >= v.count then
            level =  k
        end
    end
    return level
end

--根据宝石等级得到其个数
function RoleRuleData:GetALLGemNum(gem_level)
    local gem_Lv_list = EquipData.Instance:GetGemData()
    local num = 0
    for k, v in pairs(gem_Lv_list) do
        if v >= gem_level then
            num = num + 1
        end
    end
    return num
end

--通过等级得到套装数量
function RoleRuleData.GetSuitNum(suit_level)
    local num = 0
    local level_num_list = EquipData.Instance:GetSuitLevelList()
    for k, v in pairs(level_num_list) do
        if k >= suit_level then
            num = num + v
        end
    end
    return num
end

--通过等级得到绝世套装数量
function RoleRuleData.GetPeerlessSuitNum(suit_level)
    local num = 0
    local level_num_list = EquipData.Instance:GetPeerlessLevelList()
    for k, v in pairs(level_num_list) do
        if k >= suit_level then
            num = num + v
        end
    end
    return num
end

function RoleRuleData.GetData(gem_level)
    local level_num_list = EquipData.Instance:GetGemData()
    local data = {}
    for k, level in pairs(level_num_list) do
        if level >= gem_level then
            data[k] = 1
        else
            data[k] = 0
        end
    end
    return data
end

function RoleRuleData:GetSuitData(suit_level)
    local suit_index_t = EquipData.Instance:GetSuitIndexLevel()
    local data = {}
    local z = 0
    for k, v in pairs(suit_index_t) do
        z = z + 1
    end
    for i = 1, 5 do
        if z ~= 0 then
            for k, v in pairs(suit_index_t) do
                if k - 20 == i then
                    if v >= suit_level then
                        data[i] = 1
                    else
                        data[i] = 0
                    end
                end
            end
        else
            data[i] = 0
        end
    end
    return data
end


function RoleRuleData:GetPeerlessSuitData(suit_level)
    local suit_index_t = EquipData.Instance:GetPeerlessIndexLevel()
    local data = {}
    local z = 0
    for k, v in pairs(suit_index_t) do
        z = z + 1
    end
    
    for i = 0, 9 do
        if z > 0 then
            for k, v in pairs(suit_index_t) do
                if k - EquipData.EquipIndex.PeerlessWeaponPos == i then
                    if v >= suit_level then
                        data[i + 1] = 1
                    else
                        data[i + 1] = 0
                    end
                end
            end
        else
            data[i + 1] = 0
        end
    end
    return data
end
