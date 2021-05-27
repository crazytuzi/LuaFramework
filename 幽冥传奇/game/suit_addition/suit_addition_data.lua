SuitAdditionData = SuitAdditionData or BaseClass()

function SuitAdditionData:__init()
    if SuitAdditionData.Instance then
        ErrorLog("[SuitAdditionData]:Attempt to create singleton twice!")
    end

    SuitAdditionData.Instance = self

end

function SuitAdditionData:__delete()
    SuitAdditionData.Instance = nil
end

function SuitAdditionData.GetLevel(tab_index)
    if tab_index == TabIndex.suit_ad_strength then
        return QianghuaData.Instance:GetAllStrengthLevelIgnoreEquip()
    elseif tab_index == TabIndex.suit_ad_stone then
        local stone_level = SuitAdditionData.GetTipLevel(tab_index)
        return RoleRuleData.Instance:GetALLGemNum(stone_level)
    elseif tab_index == TabIndex.suit_ad_soul then
        return MoldingSoulData.Instance:GetAllMsStrengthLevel()
    elseif tab_index == TabIndex.suit_ad_legend then
        local tip_lv = SuitAdditionData.GetTipLevel(tab_index)
        return tip_lv > 1 and EquipmentData.Instance:GetAllBmStrengthLevel() or RoleRuleData.GetPeerlessSuitNum(EquipData.Instance:GetPeerlessEquipLevel())
    elseif tab_index == TabIndex.suit_ad_god then
        local tip_lv = RoleRuleData.GetApotheosisTipsLevel()
        local level = 0
        if tip_lv > 0 and tip_lv <= #ApotheosisPlusCfg then
            for k, v in pairs(AffinageData.Instance:GetAffinageLevelList()) do
                if v >= ApotheosisPlusCfg[tip_lv].ApotheosisLv then
                    level = level + 1
                end
            end
        end
        return level
    elseif tab_index == TabIndex.suit_ad_samsara then
        return LunHuiData.GetCountByTipLevel(LunHuiData.GetLunhuiTipLevel())
    end
end

function SuitAdditionData.GetTipLevel(tab_index)
    if tab_index == TabIndex.suit_ad_strength then
        return RoleRuleData.GetQiangHuaTipsLevel()
    elseif tab_index == TabIndex.suit_ad_stone then
        return EquipData.Instance:GetCurrentLevel()
    elseif tab_index == TabIndex.suit_ad_soul then
        return RoleRuleData.GetMoldingSoulTipsLevel()
    elseif tab_index == TabIndex.suit_ad_legend then
        local tip_lv = EquipData.Instance:GetPeerlessEquipLevel()
        return tip_lv > 0 and tip_lv + RoleRuleData.GetXueLianTipsLevel() or tip_lv
    elseif tab_index == TabIndex.suit_ad_god then
        return RoleRuleData.GetApotheosisTipsLevel()
    elseif tab_index == TabIndex.suit_ad_samsara then
        return LunHuiData.GetLunhuiTipLevel()
    end
end

function SuitAdditionData.GetPlusConfig(tab_index, level)
    local cfg = nil
    if tab_index == TabIndex.suit_ad_strength then
        for k, v in pairs(SlotPlusCfg) do 
            if level == k then
                cfg = v
                break
            end
        end
    elseif tab_index == TabIndex.suit_ad_stone then
        for i,v in pairs(StonePlusCfg) do
			if level == v.level then
				cfg = v
                break
			end
		end
    elseif tab_index == TabIndex.suit_ad_soul then
        for i,v in pairs(MoldingSoulPlusCfg) do
			if level == i then
				cfg = v
                break
			end
		end
    elseif tab_index == TabIndex.suit_ad_legend then
        -- local xuelian_tip_lv = RoleRuleData.GetXueLianTipsLevel()
        -- local suit_tip_lv = EquipData.Instance:GetPeerlessEquipLevel()
        local t = TableCopy(RoleRuleData.Instance:GetPeerlessSuitPlusConfig())
        table.remove(t)
        for k, v in pairs(BloodSlotPlusConfig) do
            table.insert( t, v )
        end
        for i,v in pairs(t) do
			if level == i then
                cfg = v
                break
			end
		end
        
    elseif tab_index == TabIndex.suit_ad_god then
        for i,v in pairs(ApotheosisPlusCfg) do
			if level == i then
				cfg = v
                break
			end
		end
    elseif tab_index == TabIndex.suit_ad_samsara then
        return LunHuiSuitAttrCfg[level]
    end
    return cfg
end

function SuitAdditionData.GetOpenBtnCfg(tab_index)
    local config = {
        [TabIndex.suit_ad_strength] = {label = Language.SuitAddition.SuitName[1], view_name = ViewName.Equipment, index = TabIndex.equipment_qianghua},
        [TabIndex.suit_ad_stone] = {label = Language.SuitAddition.SuitName[2], view_name = ViewName.Equipment, index = TabIndex.equipment_stone},
        [TabIndex.suit_ad_soul] = {label = Language.SuitAddition.SuitName[3], view_name = ViewName.Equipment, index = TabIndex.equipment_molding_soul},
        [TabIndex.suit_ad_legend] = {label = Language.SuitAddition.SuitName[5], view_name = ViewName.Equipment, index = TabIndex.equipment_blood_mixing},
        [TabIndex.suit_ad_god] = {label = Language.SuitAddition.SuitName[4], view_name = ViewName.Equipment, index = TabIndex.equipment_god},
        [TabIndex.suit_ad_samsara] = {label = Language.SuitAddition.SuitName[6], view_name = ViewName.CrossBattle, index = TabIndex.crossbattle_equip},
    }
    return config[tab_index]
end

function SuitAdditionData.GetSuitEquipList(tab_index)
    local data_list = {}
    if tab_index == TabIndex.suit_ad_strength or tab_index == TabIndex.suit_ad_stone then
        for i = 1, 10 do
            local equip_data = EquipData.Instance:GetGridData(i)
            table.insert(data_list, {tab_index = tab_index, equip_data = equip_data})
        end
    elseif tab_index == TabIndex.suit_ad_soul then
        for i = 1, 10 do
            local equip_data = EquipData.Instance:GetGridData(i)
            local soul_level = MoldingSoulData.Instance:GetEqSoulLevel(i)
            table.insert(data_list, {tab_index = tab_index, equip_data = equip_data, soul_level = soul_level})
        end
    elseif tab_index == TabIndex.suit_ad_legend then
        for i = 1, 10 do
            local equip_data = EquipData.Instance:GetGridData(i + EquipData.EquipIndex.PeerlessBeginIndex - 1)
            local blood_level = EquipmentData.Instance:GetEqBmLevel(i)
            table.insert(data_list, {tab_index = tab_index, equip_data = equip_data, blood_level = blood_level})
        end
    elseif tab_index == TabIndex.suit_ad_god then
        for i = 1, 10 do
            local equip_data = EquipData.Instance:GetGridData(i)
            local god_level = AffinageData.Instance:GetAffinageLevelBySlot(i)
            table.insert(data_list, {tab_index = tab_index, equip_data = equip_data, god_level = god_level})
        end
    elseif tab_index == TabIndex.suit_ad_samsara then
        for i = 1, 5 do
            local equip_data = EquipData.Instance:GetGridData(i + EquipData.EquipIndex.CrossEquipBeginIndex - 1)
            table.insert(data_list, {tab_index = tab_index, equip_data = equip_data})
        end
    end
    
    return data_list
end