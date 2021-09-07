
BaobaoData = BaobaoData or BaseClass()
BaobaoData.Attr = {"gong_ji", "max_hp", "fang_yu", "ming_zhong",  "shan_bi",  "bao_ji", "jian_ren"}
BaobaoData.BabyModel = {16001001, 16002001, 16003001}

function BaobaoData:__init()
    if BaobaoData.Instance then
        print_error("[BaobaoData] Attemp to create a singleton twice !")
    end
    BaobaoData.Instance = self

    self.baby_other_cfg = ConfigManager.Instance:GetAutoConfig("baby_cfg_auto").other[1]
    self.baby_info_cfg = ConfigManager.Instance:GetAutoConfig("baby_cfg_auto").baby_info
    self.baby_upgrade_cfg = ConfigManager.Instance:GetAutoConfig("baby_cfg_auto").baby_upgrade
    self.baby_uplevel_cfg = ConfigManager.Instance:GetAutoConfig("baby_cfg_auto").baby_uplevel
    self.qifu_tree_cfg = ConfigManager.Instance:GetAutoConfig("baby_cfg_auto").qifu_tree
    self.baby_spirit_cfg = ConfigManager.Instance:GetAutoConfig("baby_cfg_auto").baby_spirit
    self.baby_chaosheng_cfg= ConfigManager.Instance:GetAutoConfig("baby_cfg_auto").baby_chaosheng
    self.baby_xilian_cfg= ListToMap(ConfigManager.Instance:GetAutoConfig("baby_cfg_auto").baby_master_value, "master_level", "baby_grade")

    self.baby_list = {}
    self.seq_select_index = 0
    self.spirit_index = 0
    self.all_baby_sprite_list = {}
    self.can_up_grade = {}
    self.aptitude_redpoint_list = {}

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
    self.display_baby_index = protocol.display_baby_index
    self:SetSelectedBabyDefaultIndex()
end

function BaobaoData:SetBabyUseIndex(protocol)
    self.display_baby_index = protocol.display_baby_index
end

function BaobaoData:GetBabyChaoShengCount()
    return self.baby_chaosheng_count or 0
end

function BaobaoData:GetUseBabyIndex()
    return self.display_baby_index or -1
end

function BaobaoData:GetBabyInfo(baby_index)
    if self.baby_list == nil or nil == self.baby_list[baby_index] then return end

    return self.baby_list[baby_index]
end

function BaobaoData:GetBabyLevelCfg(baby_id, level)
    if nil == baby_id or nil == level then return end

    return self.baby_uplevel_cfg[baby_id * (GameEnum.BABY_MAX_LEVEL + 1) + level + 1]
end

function BaobaoData:GetBabyUpgradeCfg(grade)
    if nil == grade then return end

    return self.baby_upgrade_cfg[grade + 1]
end

-- 只需要三个属性显示，别的属于隐藏属性
function BaobaoData:GetBabyInfoCfgList()
    local baby_cfg = {}
    for k,v in pairs(self.baby_info_cfg) do
        local data = {}
        data.maxhp = v.maxhp
        data.gongji = v.gongji
        data.fangyu = v.fangyu
        baby_cfg[k] = data
    end

    return baby_cfg
end

function BaobaoData:GetBabyInfoCfg(id)
    if id == nil then
        return {}
    end

    return self.baby_info_cfg[id] or {}
end

function BaobaoData:GetBabyQiFuTreeCfg()
    return self.qifu_tree_cfg or {}
end

function BaobaoData:GetBabyNumByType(baby_id)
    local num = 0
    if baby_id == nil then
        return num
    end

    if self.baby_list == nil then
        return num
    end

    for k,v in pairs(self.baby_list) do
        if v ~= nil and v.baby_id >= 0 then
            if v.baby_id >= baby_id or baby_id == BABY_TYPE_LIMIT.FREE then
                num = num + 1
            end
        end
    end

    return num
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
        for k,v in pairs(baby_data) do
            if v.baby_index + 1 == self.selected_baby_index then
                return v
            end
        end
    end
    return nil
end

function BaobaoData:GetAptitudeCfg(id, level)
    local data = {}
    if id == nil or level == nil then
        return data
    end

    local common_attr = CommonStruct.Attribute()
    local cur_cfg = self:GetBabyLevelAttribute(id,level)
    local next_cfg = self:GetBabyLevelAttribute(id,level + 1)
    local cur_attr = CommonDataManager.GetAttributteByClass(cur_cfg)
    local next_attr = CommonDataManager.GetAttributteByClass(next_cfg)
    local lerp_attr = CommonDataManager.LerpAttributeAttr(cur_attr, next_attr)    -- 属性差
    
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
            --table.sort(data_list, SortTools.KeyLowerSorters("sort","baby_index"))
            data_index = data_index + 1
        end
    end

    table.sort(data_list, SortTools.KeyLowerSorters("sort","baby_index"))
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
    --local base_attr = CommonDataManager.GetAttributteByClass(baby_cfg_list[baby_id])
    local level_attr = CommonDataManager.GetAttributteByClass(self:GetBabyLevelCfg(baby_id, level))
    return CommonDataManager.GetAttributteByClass(level_attr)
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
    return attr_red_point
end

function BaobaoData:GetZiZhiPanelRedPoint()
    local aptitude_red_point = self:GetAptitudeRedPoint()
    return aptitude_red_point
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
        if tonumber(v.grade) < GameEnum.BABY_MAX_GRADE and lover_name == v.lover_name then        
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

function BaobaoData:GetAttrRedPointByIndex(index)
    local is_can = 0
    if index == nil then
        return index
    end

    if self.can_up_grade ~= nil and self.can_up_grade[index] ~= nil then
        is_can = self.can_up_grade[index]
    end

    return is_can
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

function BaobaoData:GetAptitudeRedByIndex(index)
    local is_can = 0
    if index == nil then
        return is_can
    end

    if self.aptitude_redpoint_list ~= nil and self.aptitude_redpoint_list[index] ~= nil then
        is_can = self.aptitude_redpoint_list[index]
    end

    return is_can
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
            if cur_attr ~= nil and next(cur_attr) ~= nil then
                train_val = cur_attr.train_val or 0
                spirit_train = v.spirit_train or 0
                spirit_has_count = train_val - spirit_train or 0
                consume_item_id = cur_attr.consume_item or 0
                local item_num = ItemData.Instance:GetItemNumInBagById(consume_item_id) or 0

                if item_num >= spirit_has_count then
                    return 1
                end
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

function BaobaoData:GetBabyResId(baby_type)
    if baby_type == nil then
        return nil
    end

    local data = self.baby_info_cfg[baby_type] or {}
    return data.res_id
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

    for k,v in pairs(data_list) do
        if v.id == 0 then
            max_length = max_length + 1
        end
    end

    return max_length - 1
end

function BaobaoData:GetBabySpiritAttr(id,level)
    local common_attr = CommonStruct.Attribute()
    local cur_cfg = self:GetBabySpiritAttrCfg(id,level)
    local next_cfg = self:GetBabySpiritAttrCfg(id,level +1)
    local cur_attr = CommonDataManager.GetAttributteByClass(cur_cfg)
    local next_attr = CommonDataManager.GetAttributteByClass(next_cfg)
    local lerp_attr = CommonDataManager.LerpAttributeAttr(cur_attr, next_attr)    -- 属性差
    local data = {}
    local sort_list = CommonDataManager.no_line_sort_list

    for k,v in pairs(common_attr) do
        if lerp_attr[k] > 0 then
            local attr_data = {name = k,cur_value = cur_attr[k],next_value = lerp_attr[k], sort = sort_list[k] or 0}
            table.insert(data,attr_data)
        elseif cur_attr[k] > 0 or lerp_attr[k] < 0 then
            local attr_data = {name = k, cur_value = cur_attr[k], next_value = math.abs(lerp_attr[k]), sort = sort_list[k] or 0}
            table.insert(data,attr_data)
        end
    end

    function sort_attr(a, b)
        return a.sort < b.sort
    end
    table.sort(data, sort_attr)

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
            return v.need_gold, v.replace_item
        end
    end
    return nil, nil
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

function BaobaoData:GetBabyOtherCfgByStr(str)
    if str == nil then
        return
    end

    return self.baby_other_cfg[str]
end

function BaobaoData:SetBabyMasterValue(protocol)
    self.baby_index = protocol.baby_index or 0
    self.master_type = protocol.master_type or 0
    self.master_level = protocol.master_level or 0

    self.baby_list[self.baby_index + 1].master_type = self.master_type
    self.baby_list[self.baby_index + 1].master_level = self.master_level
end

function BaobaoData:GetBabyMasterValue()
    return self.baby_index or 0, self.master_type or 0, self.master_level or 0
end

function BaobaoData:GetMasterValue(master_level, baby_grade)
    local value = 0
    if master_level == nil or baby_grade == nil then
        return value
    end

    if self.baby_xilian_cfg[master_level] ~= nil and self.baby_xilian_cfg[master_level][baby_grade] ~= nil then
        value = self.baby_xilian_cfg[master_level][baby_grade].master_value or 0
    end

    return value
end