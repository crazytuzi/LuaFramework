EquipStrengthModel = EquipStrengthModel or BaseClass(BaseModel)

function EquipStrengthModel:__init()
    self.main_win = nil
    self.hufu_win = nil
    self.stone_look_win = nil
    self.trans_win = nil
    self.dianhua_look_win = nil
    self.dianhua_book_win = nil
    self.dianhua_get_win = nil
    self.dianhua_share_win = nil
    self.dianhua_badge_panel = nil
    self.strength_buy_panel = nil
    self.stone_quick_buy_data = nil
    self.hero_stone_quick_buy_data = nil

    self.backsmith_lev = 0
    self.backsmith_count = 0
    self.strength_lev = 0
    self.max_strength_lev = 15 --装备中强化等级最高的等级
    self.min_strength_lev = 7
    self.strength_count = 0
    self.next_strength_count = 0 --装备强化套装下一个套装的个数

    self.strength_data = nil
    self.trans_type = 1

    self.is_from_backpack = false

    self.last_equip_opera = 0

    self.temp_data_base_prop_val = nil

    self.equip_reset_val = 0
    self.max_equip_reset_val = 100

    self.build_reset_id = 0

    self.equip_can_switch_lev = 80 --80级开启装备切换

    self.max_backsmith_lev = 120

    self.is_active_req_back = false --是否主动请求备用属性

    self.equip_spare_attr_list = {} --装备备用属性列表

    self.no_confirm_equip_reset = false

    self.selected_effect = nil --装备洗练指定特效》当前已选择特效
    self.selected_effect_flag = false

    --已激活的强化套装
    self.last_strength_lev = {
        [8] = 7,
        [9] = 8,
        [10] = 9,
        [11] = 10,
        [12] = 11,
    }


    --根据电话类型获取精炼名称
    self.dianhua_name = {
        [0] = TI18N("无")
        ,[1] = TI18N("精良")
        ,[2] = TI18N("稀有")
        ,[3] = TI18N("优秀")
        ,[4] = TI18N("卓越")
        ,[5] = TI18N("完美")
        ,[6] = TI18N("逆天")
        ,[7] = TI18N("史诗")
        ,[8] = TI18N("传说")
        ,[9] = TI18N("至尊")
       ,[10] = TI18N("起源")
       ,[11] = TI18N("远古")
       ,[12] = TI18N("神话")
       ,[13] = TI18N("不朽")
    }

    self.dianhua_color = {
        [0] =  ColorHelper.color[1]
        ,[1] = ColorHelper.color[1] --绿
        ,[2] = ColorHelper.color[1]


        ,[3] = ColorHelper.color[2] -- 蓝
        ,[4] = ColorHelper.color[2]
        ,[5] = ColorHelper.color[2]

        ,[6] = ColorHelper.color[3] --紫
        ,[7] = ColorHelper.color[3]
        ,[8] = ColorHelper.color[3]

        ,[9] = ColorHelper.color[4]
       ,[10] = ColorHelper.color[4] --橙
       ,[11] = ColorHelper.color[4] --橙
       ,[12] = ColorHelper.color[4] --橙
       ,[13] = ColorHelper.color[4] --橙
    }
    self.craftLockLev = 3
end

function EquipStrengthModel:__delete()

end


-------------打开界面逻辑
--打开强化主面板
function EquipStrengthModel:OpenEquipStrengthMainUI(args)
    if self.main_win == nil then
        self.main_win = EquipStrengthMainWindow.New(self)
    end
    self.main_win:Open(args)
end

--关闭守护主面板
function EquipStrengthModel:CloseEquipStrengthMainUI()
    WindowManager.Instance:CloseWindow(self.main_win)
    if self.main_win == nil then
        -- print("===================self.main_win is nil")
    else
        -- print("===================self.main_win is not nil")
    end
end

--打开保护符选择界面
function EquipStrengthModel:OpenEquipHufuUI()
    if self.hufu_win == nil then
        self.hufu_win = EquipStrengthHufuWindow.New(self)
    end
    self.hufu_win:Show()
end

--关闭守护主面板
function EquipStrengthModel:CloseEquipHufuUI()
    self.hufu_win:DeleteMe()
    self.hufu_win = nil
    if self.hufu_win == nil then
        -- print("===================self.hufu_win is nil")
    else
        -- print("===================self.hufu_win is not nil")
    end
end

--打开宝石查看界面
function EquipStrengthModel:OpenEquipStoneLookUI(kongType)
    if self.stone_look_win == nil then
        self.stone_look_win = EquipStrengthStoneLookWindow.New(self)
    end
    self.stone_look_win.kongType = kongType
    self.stone_look_win:Open()
end

--关闭守护主面板
function EquipStrengthModel:CloseEquipStoneLookUI()
    WindowManager.Instance:CloseWindow(self.stone_look_win)
    if self.stone_look_win == nil then
        -- print("===================self.stone_look_win is nil")
    else
        -- print("===================self.stone_look_win is not nil")
    end
end


--打开属性转换界面
function EquipStrengthModel:OpenEquipTransUI()
    if self.trans_win == nil then
        self.trans_win = EquipStrengthTransformWindow.New(self)
    end
    self.trans_win:Open()
end

--关闭属性转换主面板
function EquipStrengthModel:CloseEquipTransUI()
    WindowManager.Instance:CloseWindow(self.trans_win)
    if self.trans_win == nil then
        -- print("===================self.trans_win is nil")
    else
        -- print("===================self.trans_win is not nil")
    end
end



--打开精炼查看界面
function EquipStrengthModel:OpenEquipDianhuaLooksUI(info, craft)
    self.dianhua_look_info = info
    self.dianhua_look_craft = craft
    if self.dianhua_look_win == nil then
        self.dianhua_look_win = EquipStrengthDianhuaLookWindow.New(self)
    end
    self.dianhua_look_win:Show()
end

--关闭属性转换主面板
function EquipStrengthModel:CloseEquipDianhuaLooksUI()
    if self.dianhua_look_win ~= nil then
        self.dianhua_look_win:DeleteMe()
        self.dianhua_look_win = nil
    else
        -- print("===================self.dianhua_look_win is not nil")
    end
end

--打开精炼徽章查看界面
function EquipStrengthModel:OpenEquipDianhuaBadgeUI(info, craft)
    if self.dianhua_badge_panel == nil then
        self.dianhua_badge_panel = EquipStrengthDianhuaBadgePanel.New(self)
    end
    self.dianhua_badge_panel:Show()
end

--关闭精炼徽章查看界面
function EquipStrengthModel:CloseEquipDianhuaBadgeUI()
    if self.dianhua_badge_panel ~= nil then
        self.dianhua_badge_panel:DeleteMe()
        self.dianhua_badge_panel = nil
    else
        -- print("===================self.dianhua_badge_panel is not nil")
    end
end



--打开精炼徽章查看界面
function EquipStrengthModel:OpenStrengthBuyUI(args)
    if self.strength_buy_panel == nil then
        self.strength_buy_panel = EquipStrengthBuyPanel.New(self)
    end
    self.strength_buy_panel:Show(args)
end

--关闭精炼徽章查看界面
function EquipStrengthModel:CloseStrengthBuyUI()
    if self.strength_buy_panel ~= nil then
        self.strength_buy_panel:DeleteMe()
        self.strength_buy_panel = nil
    else
        -- print("===================self.strength_buy_panel is not nil")
    end
end


--打开强化主面板
function EquipStrengthModel:OpenEquipDianhuaBooksUI(args)
    if self.dianhua_book_win == nil then
        self.dianhua_book_win = EquipStrengthDianhuaBookWindow.New(self)
    end
    self.dianhua_book_win:Open(args)
end

--关闭守护主面板
function EquipStrengthModel:CloseEquipDianhuaBooksUI()
    WindowManager.Instance:CloseWindow(self.dianhua_book_win)
    if self.dianhua_book_win == nil then
        -- print("===================self.dianhua_book_win is nil")
    else
        -- print("===================self.dianhua_book_win is not nil")
    end
end

--打开神器获得界面
function EquipStrengthModel:OpenEquipDianhuaGetsUI(new_shenqi_id)
    self.new_shenqi_id = new_shenqi_id
    if self.dianhua_get_win == nil then
        self.dianhua_get_win = EquipStrengthDianhuaGetWindow.New(self)
    end
    self.dianhua_get_win:Show()
end

--关闭神器获得面板
function EquipStrengthModel:CloseEquipDianhuaGetsUI()
    if self.dianhua_get_win ~= nil then
         self.dianhua_get_win:DeleteMe()
        self.dianhua_get_win = nil
    else
        -- print("===================self.dianhua_get_win is not nil")
    end
end

--打开点化徽章分享界面
function EquipStrengthModel:OpenEquipDianhuaShareUI(args)
    if self.dianhua_share_win == nil then
        self.dianhua_share_win = EquipStrengthDianhuaSharePanel.New(self)
    end
    self.dianhua_share_win:Show(args)
end

--关闭点化徽章分享界面
function EquipStrengthModel:CloseEquipDianhuaShareUI()
    if self.dianhua_share_win ~= nil then
         self.dianhua_share_win:DeleteMe()
        self.dianhua_share_win = nil
    else
        -- print("===================self.dianhua_share_win is not nil")
    end
end

--协议返回，更新点化徽章分享界面左边内容
function EquipStrengthModel:OnUpdateDianhuaShareInfo(data)
    if self.dianhua_share_win ~= nil then
         self.dianhua_share_win:OnSocketBack(data)
    end
end

------------------------------对frozenbutton的click和release调用
--精炼按钮
function EquipStrengthModel:Release_equip_dianhua()
    if self.main_win ~= nil then
        if self.main_win.subFirst ~= nil and self.main_win.subFirst.dianhua_con ~= nil then
            if self.main_win.subFirst.dianhua_con.dianHuaBuyBtn ~= nil then
                self.main_win.subFirst.dianhua_con.dianHuaBuyBtn:ReleaseFrozon()
            end
        end
    end
end

--重铸按钮
function EquipStrengthModel:Release_equip_reset()
    if self.main_win ~= nil then
        if self.main_win.subFirst ~= nil and self.main_win.subFirst.build_con ~= nil then
            if self.main_win.subFirst.build_con.BuildCon_BtnBuild_buy_btn ~= nil then
                self.main_win.subFirst.build_con.BuildCon_BtnBuild_buy_btn:ReleaseFrozon()
            end
        end
    end
end

--完美锻造按钮
function EquipStrengthModel:Release_equip_perfect()
    if self.main_win ~= nil then
        if self.main_win.subFirst ~= nil and self.main_win.subFirst.build_con ~= nil then
            if self.main_win.subFirst.build_con.PerfectCon_BtnBuil_buy_btn ~= nil then
                self.main_win.subFirst.build_con.PerfectCon_BtnBuil_buy_btn:ReleaseFrozon()
            end
        end
    end
end

--强化按钮
function EquipStrengthModel:Frozen_equip_strength()
    if self.main_win ~= nil then
        if self.main_win.subFirst ~= nil and self.main_win.subFirst.strength_con ~= nil then
            if self.main_win.subFirst.strength_con.restoreFrozen_strength ~= nil then
                self.main_win.subFirst.strength_con.restoreFrozen_strength:OnClick()
            end
        end
    end
end

function EquipStrengthModel:Release_equip_strength()
    if self.main_win ~= nil then
        if self.main_win.subFirst ~= nil and self.main_win.subFirst.strength_con ~= nil then
            if self.main_win.subFirst.strength_con.restoreFrozen_strength ~= nil then
                self.main_win.subFirst.strength_con.restoreFrozen_strength:Release()
            end
        end
    end
end

--宝石升级按钮
function EquipStrengthModel:Frozen_equip_stone_up()
    if self.main_win ~= nil then
        if self.main_win.subSecond ~= nil then
            if self.main_win.subSecond.restoreFrozen_stone ~= nil then
                self.main_win.subSecond.restoreFrozen_stone:OnClick()
            end
        end
    end
end

function EquipStrengthModel:Release_equip_stone_up()
    if self.main_win ~= nil then
        if self.main_win.subSecond ~= nil then
            if self.main_win.subSecond.restoreFrozen_stone ~= nil then
                self.main_win.subSecond.restoreFrozen_stone:Release()
            end
        end
    end
end

function EquipStrengthModel:Release_equip_trans_buybtn()
    if self.trans_win ~= nil then
        if self.trans_win.subFirst.trans_btn ~= nil then
            self.trans_win.subFirst.trans_btn:ReleaseFrozon()
        end
        if self.trans_win.subSecond.trans_btn ~= nil then
            self.trans_win.subSecond.trans_btn:ReleaseFrozon()
        end
    end
end

-------------------------------------------各种get/set
--获取一级装备可镶嵌宝石
function EquipStrengthModel:get_first_lev_stones()
    local temp_dic = {}
    for k,v in pairs(DataBacksmith.data_gem_base) do
        if v.lev == 1 then
            temp_dic[v.type] = v
        end
    end
    return temp_dic
end

--获取一级装备可镶嵌英雄宝石
function EquipStrengthModel:get_first_lev_hero_stones()
    local temp_dic = {}
    for k,v in pairs(DataBacksmith.data_hero_stone_base) do
        if v.lev == 1 then
            temp_dic[v.type] = v
        end
    end
    return temp_dic
end

--传入宝石的baseid获取该类型宝石1级的宝石配置
function EquipStrengthModel:get_first_lev_stone_by_id(base_id)
    local cur_cfg_data = DataBacksmith.data_gem_base[base_id]
    local dic = self:get_first_lev_stones()
    local result = BaseUtils.copytab(dic[cur_cfg_data.type])
    result.max_exp = cur_cfg_data.max_exp
    return result
end

--传入英雄宝石的baseid获取该类型英雄宝石1级的宝石配置
function EquipStrengthModel:get_first_lev_hero_stone_by_id(base_id)
    local cur_cfg_data = DataBacksmith.data_hero_stone_base[base_id]
    local dic = self:get_first_lev_hero_stones()
    local result = BaseUtils.copytab(dic[cur_cfg_data.type])
    result.max_exp = cur_cfg_data.max_exp
    return result
end

--计算装备等级
function EquipStrengthModel:count_backsmith_info(equips)
    local t30 = 0
    local t40 = 0
    local t50 = 0
    local t60 = 0
    local t70 = 0
    local t80 = 0
    local t90 = 0
    local t100 = 0
    local t110 = 0
    local t120 = 0

    for i,v in ipairs(equips) do
        if v.lev >= 30 then
            t30 = t30 + 1
        end
        if v.lev >= 40 then
            t40 = t40 + 1
        end
        if v.lev >= 50 then
            t50 = t50 + 1
        end
        if v.lev >= 60 then
            t60 = t60 + 1
        end
        if v.lev >= 70 then
            t70 = t70 + 1
        end
        if v.lev >= 80 then
            t80 = t80 + 1
        end
        if v.lev >= 90 then
            t90 = t90 + 1
        end
        if v.lev >= 100 then
            t100 = t100 + 1
        end
        if v.lev >= 110 then
            t110 = t110 + 1
        end
        if v.lev >= 120 then
            t120 = t120 + 1
        end
    end

    if t120 == 8 then
        self.backsmith_lev = 130
        self.backsmith_count = 8
    elseif t110 == 8 then
        self.backsmith_lev = 120
        self.backsmith_count = t120
    elseif t100 == 8 then
        self.backsmith_lev = 110
        self.backsmith_count = t110
    elseif t90 == 8 then
        self.backsmith_lev = 100
        self.backsmith_count = t100
    elseif t80 == 8 then
        self.backsmith_lev = 90
        self.backsmith_count = t90
    elseif t70 == 8 then
        self.backsmith_lev = 80
        self.backsmith_count = t80
    elseif t60 == 8 then
        self.backsmith_lev = 70
        self.backsmith_count = t70
    elseif t50 == 8 then
        self.backsmith_lev = 60
        self.backsmith_count = t60
    elseif t40 == 8 then
        self.backsmith_lev = 50
        self.backsmith_count = t50
    elseif t30 == 8 then
        self.backsmith_lev = 40
        self.backsmith_count = t40
    else
        self.backsmith_lev = 30
        self.backsmith_count = t30
    end
end

--计算强化等级
function EquipStrengthModel:count_strength_info(equips)
    local s7 = 0
    local s8 = 0
    local s9 = 0
    local s10 = 0
    local s11 = 0
    local s12 = 0
    local s13 = 0
    local s14 = 0
    local s15 = 0

    for i,v in ipairs(equips) do
        if v.enchant >= 7 then
            s7 = s7 + 1
        end
        if v.enchant >= 8 then
            s8 = s8 + 1
        end
        if v.enchant >= 9 then
            s9 = s9 + 1
        end
        if v.enchant >= 10 then
            s10 = s10 + 1
        end
        if v.enchant >= 11 then
            s11 = s11 + 1
        end
        if v.enchant >= 12 then
            s12 = s12 + 1
        end

        if v.enchant >= 13 then
            s13 = s13 + 1
        end
        if v.enchant >= 14 then
            s14 = s14 + 1
        end
        if v.enchant >= 15 then
            s15 = s15 + 1
        end
    end

    if s15 == 8 then
        self.strength_lev = 15
        self.strength_count = s15
    elseif s14 == 8 then
        self.strength_lev = 14
        self.strength_count = s14
    elseif s13 == 8 then
        self.strength_lev = 13
        self.strength_count = s13
    elseif s12 == 8 then
        self.strength_lev = 12
        self.strength_count = s12
    elseif s11 == 8 then
        self.strength_lev = 11
        self.strength_count = s11
        self.next_strength_count = s12
    elseif s10 == 8 then
        self.strength_lev = 10
        self.strength_count = s10
        self.next_strength_count = s11
    elseif s9 == 8 then
        self.strength_lev = 9
        self.strength_count = s9
        self.next_strength_count = s10
    elseif s8 == 8 then
        self.strength_lev = 8
        self.strength_count = s8
        self.next_strength_count = s9
    elseif s7 == 8 then
        self.strength_lev = 7
        self.strength_count = s7
        self.next_strength_count = s8
    else
        self.strength_lev = 6
        self.strength_count = 0
        self.next_strength_count = s7
    end
end


---传入装备类型和等级获取装备基础属性值列表
function EquipStrengthModel:get_equip_base_prop_list(type_lev)
    if self.temp_data_base_prop_val ~= nil then
        if self.temp_data_base_prop_val[type_lev] ~= nil then
            return self.temp_data_base_prop_val[type_lev]
        else
            self.temp_data_base_prop_val[type_lev] = {}
            local temp_data = DataEqm.data_base_prop_val[type_lev]
            self.temp_data_base_prop_val[type_lev][1] = temp_data.attr_hp_max
            self.temp_data_base_prop_val[type_lev][2] = temp_data.attr_mp_max
            self.temp_data_base_prop_val[type_lev][3] = temp_data.attr_atk_speed
            self.temp_data_base_prop_val[type_lev][4] = temp_data.attr_phy_dmg
            self.temp_data_base_prop_val[type_lev][5] = temp_data.attr_magic_dmg
            self.temp_data_base_prop_val[type_lev][6] = temp_data.attr_phy_def
            self.temp_data_base_prop_val[type_lev][7] = temp_data.attr_magic_def
            self.temp_data_base_prop_val[type_lev][8] = temp_data.attr_crit
            self.temp_data_base_prop_val[type_lev][9] = temp_data.attr_tenacity
            self.temp_data_base_prop_val[type_lev][10] = temp_data.attr_accuracy
            self.temp_data_base_prop_val[type_lev][11] = temp_data.attr_evasion
            self.temp_data_base_prop_val[type_lev][25] = temp_data.attr_enhance_control
            self.temp_data_base_prop_val[type_lev][26] = temp_data.attr_anti_control
            self.temp_data_base_prop_val[type_lev][43] = temp_data.attr_heal_val
        end
    else
        self.temp_data_base_prop_val = {}
        self.temp_data_base_prop_val[type_lev] = {}
        local temp_data = DataEqm.data_base_prop_val[type_lev]
        self.temp_data_base_prop_val[type_lev][1] = temp_data.attr_hp_max
        self.temp_data_base_prop_val[type_lev][2] = temp_data.attr_mp_max
        self.temp_data_base_prop_val[type_lev][3] = temp_data.attr_atk_speed
        self.temp_data_base_prop_val[type_lev][4] = temp_data.attr_phy_dmg
        self.temp_data_base_prop_val[type_lev][5] = temp_data.attr_magic_dmg
        self.temp_data_base_prop_val[type_lev][6] = temp_data.attr_phy_def
        self.temp_data_base_prop_val[type_lev][7] = temp_data.attr_magic_def
        self.temp_data_base_prop_val[type_lev][8] = temp_data.attr_crit
        self.temp_data_base_prop_val[type_lev][9] = temp_data.attr_tenacity
        self.temp_data_base_prop_val[type_lev][10] = temp_data.attr_accuracy
        self.temp_data_base_prop_val[type_lev][11] = temp_data.attr_evasion
        self.temp_data_base_prop_val[type_lev][25] = temp_data.attr_enhance_control
        self.temp_data_base_prop_val[type_lev][26] = temp_data.attr_anti_control
        self.temp_data_base_prop_val[type_lev][43] = temp_data.attr_heal_val
    end
    return self.temp_data_base_prop_val[type_lev]
end

--传入类型和等级读取装备属性值
function EquipStrengthModel:get_eqm_prop_by_type_lev(type_lev)
    -- print("========== EquipStrengthModel:get_eqm_prop_by_type_lev ==============" .. tostring(type_lev))
    local temp_data = DataEqm.data_base_prop_val[type_lev]
    local attr = {}
    table.insert(attr, {name = 1, val = temp_data.attr_hp_max})
    table.insert(attr, {name = 2, val = temp_data.attr_mp_max})
    table.insert(attr, {name = 3, val = temp_data.attr_atk_speed})
    table.insert(attr, {name = 4, val = temp_data.attr_phy_dmg})
    table.insert(attr, {name = 5, val = temp_data.attr_magic_dmg})
    table.insert(attr, {name = 6, val = temp_data.attr_phy_def})
    table.insert(attr, {name = 7, val = temp_data.attr_magic_def})
    table.insert(attr, {name = 8, val = temp_data.attr_crit})
    table.insert(attr, {name = 9, val = temp_data.attr_tenacity})
    table.insert(attr,  {name = 10, val = temp_data.attr_accuracy})
    table.insert(attr,  {name = 11, val = temp_data.attr_evasion})
    table.insert(attr,  {name = 25, val = temp_data.attr_enhance_control})
    table.insert(attr,  {name = 26, val = temp_data.attr_anti_control})
    table.insert(attr,  {name = 43, val = temp_data.attr_heal_val})
    return attr
end


--判断下是否有装备可以提升
function EquipStrengthModel:check_has_equip_can_up()
    for k, v in pairs(BackpackManager.Instance.equipDic) do
        local cfg_data = DataBacksmith.data_forge[string.format("%s_%s_%s", v.base_id, RoleManager.Instance.RoleData.sex, RoleManager.Instance.RoleData.classes)]
        if cfg_data ~= nil then
            local bottom_base_data_1 = DataItem.data_get[cfg_data.need_item[1][1]]
            local bottom_base_data_2 = DataItem.data_get[cfg_data.need_item[2][1]]
            local bottom_base_data_3 = DataItem.data_get[cfg_data.need_item[3][1]]

            local has_num_1 = BackpackManager.Instance:GetItemCount(bottom_base_data_1.id)
            local has_num_2 = BackpackManager.Instance:GetItemCount(bottom_base_data_2.id)
            local has_num_3 = BackpackManager.Instance:GetItemCount(bottom_base_data_3.id)
            local need_num_1 = cfg_data.need_item[1][2]
            local need_num_2 = cfg_data.need_item[2][2]
            local need_num_3 = cfg_data.need_item[3][2]
            if has_num_1 >= need_num_1 and has_num_2 >= need_num_2 and has_num_3 >= need_num_3 then
                return true
            end
        end
    end
    return false
end

--传入装备类型，强化等级，属性类型，获取对应的加成
function EquipStrengthModel:get_equip_enchant_add(_type, en_lev, attr)
    local key = string.format("%s_%s", _type, en_lev)
    local cfg_data = DataEqm.data_enchant[key]
    for i=1, #cfg_data.target do
        local d = cfg_data.target[i]
        if d.effect_type == attr then
            return d.val
        end
    end
end

--检查下当前是否有装备可以升级,只判断等级，不判断材料
function EquipStrengthModel:check_has_equip_can_lev_up()
    for k,v in pairs(BackpackManager.Instance.equipDic) do
        local cfg_data = DataBacksmith.data_forge[string.format("%s_%s_%s",v.base_id,RoleManager.Instance.RoleData.sex, RoleManager.Instance.RoleData.classes)]
        if cfg_data ~= nil then
            local baseData = DataItem.data_get[cfg_data.base_id]
            local next_cfg_base_data = DataItem.data_get[cfg_data.next_id]
            local curEquipType = baseData.type
            if (curEquipType == BackpackEumn.ItemType.cloth or curEquipType == BackpackEumn.ItemType.waistband or curEquipType == BackpackEumn.ItemType.trousers or curEquipType == BackpackEumn.ItemType.shoe) then
                --衣服、腰带、裤子、鞋子 特殊处理
                -- 为什么特殊处理
                if cfg_data.need_lev <= RoleManager.Instance.RoleData.lev and cfg_data.need_break_times <= RoleManager.Instance.RoleData.lev_break_times then
                    return true
                end
            else
                if cfg_data.need_lev <= RoleManager.Instance.RoleData.lev and cfg_data.need_break_times <= RoleManager.Instance.RoleData.lev_break_times then
                    return true
                end
            end
        end
    end
    return false
end

--判断下重铸只是否已满
function EquipStrengthModel:check_rebuild_val_enough()
    if self.equip_reset_val >= self.max_equip_reset_val then
        return true
    end
    return false
end

--检查重铸奖励的显示条件
--身上有至少一件70装备,人物等级70级
function EquipStrengthModel:check_show_rebuild_reward()
    if RoleManager.Instance.RoleData.lev >= 70 then
        for k,v in pairs(BackpackManager.Instance.equipDic) do
            if v.lev >= 70 then
                return true
            end
        end
    end
    return false
end


--检查是否有装备有宝石可以镶嵌
function EquipStrengthModel:check_has_equip_can_stone()
    local state = false


    local base_id_dic = {}
    for k,v in pairs(BackpackManager.Instance.equipDic) do
        if v.lev >= 30 then
            local ok_state = false
            local allow_list = DataBacksmith.data_gem_limit[v.type].allow
            local temp_dic = self:get_first_lev_stones()

            for i=1,#allow_list do
                local allow_data = allow_list[i]
                local temp_dic_data = temp_dic[allow_data.attr_name]

                if temp_dic_data ~= nil then
                    base_id_dic[temp_dic_data.id] = true
                end
            end

            for k,d in pairs(BackpackManager.Instance.itemDic) do
                if base_id_dic[d.base_id] ~= nil then
                    ok_state = true
                    break
                end
            end


            local stone_num = 0
            for i=1,#v.attr do
                local ed = v.attr[i]
                if ed.type == GlobalEumn.ItemAttrType.gem then
                    stone_num = stone_num + 1
                end
            end

            if stone_num == 0 or (stone_num == 1 and v.lev >= 60) then
                if RoleManager.Instance.RoleData.lev < 50 then
                    --50级以下背包有就显示红点
                    if ok_state then
                        state = true
                        break
                    end
                else
                    state = true
                end
            end
        end
    end


    return state
end



--传入装备类型和职业，获取该装备的可以电话的品质列表
function EquipStrengthModel:get_equip_dianhua_list(_type, _classes)
    local dianhua_list = {}
    for i=1,#DataBacksmith.data_equip_dianhua do
        local data = DataBacksmith.data_equip_dianhua[i]
        if data.type == _type and data.classes == _classes then
            table.insert(dianhua_list, BaseUtils.copytab(data))
        end
    end
    table.sort(dianhua_list, function(a,b) return a.craft < b.craft end)
    return dianhua_list
end

--传入装备品阶、类型和职业，获取该装备的可以点化的品质配置数据
function EquipStrengthModel:get_equiip_dianhua_data(_type, _classes, _craft)
    local tempData = nil
    for i=1,#DataBacksmith.data_equip_dianhua do
        local data = DataBacksmith.data_equip_dianhua[i]
        if data.type == _type and data.classes == _classes and data.craft == _craft then
            tempData = data
            break
        end
    end
    return tempData
end

--检查传入的武器数据和对应的品接判断是否有神器外观
function EquipStrengthModel:check_is_shenqi_craf(equip_data, _craft)

    if equip_data.type == 6 or equip_data.type == 7 or equip_data.type == 9 or equip_data.type == 10 or equip_data.type == 11 or equip_data.type == 12 or equip_data.type == 13 or equip_data.type == 14 then
        return false
    end

     local hasOpenAttrList = {}
    for i=1,#equip_data.attr do
        if equip_data.attr[i].type == 5 then
            table.insert(hasOpenAttrList, equip_data.attr[i])
        end
    end
    local cfg_data_list = self:get_equip_dianhua_list(equip_data.type, RoleManager.Instance.RoleData.classes)
    local show_shenqi = false
    local last_dianhua_cfg_data = nil

    --找到当前已精炼的最高等级的品阶
    for i=1,#hasOpenAttrList do
        local temp_has_open_data = hasOpenAttrList[i]
        for j=1,#cfg_data_list do
            local temp_cfg_data = cfg_data_list[j]
            if temp_cfg_data.craft ==  temp_has_open_data.flag then
                if last_dianhua_cfg_data == nil then
                    last_dianhua_cfg_data = temp_cfg_data
                elseif last_dianhua_cfg_data.lev < temp_cfg_data.lev then
                    last_dianhua_cfg_data = temp_cfg_data
                end
            end
        end
    end
    if last_dianhua_cfg_data == nil then
        --还没有精炼任何品阶
        show_shenqi = true
    else
        if last_dianhua_cfg_data.craft == _craft then
            show_shenqi = true
        else
            local next_temp_cfg_data = nil
            for j=1,#cfg_data_list do
                local temp_cfg_data = cfg_data_list[j]
                if temp_cfg_data.lev >  last_dianhua_cfg_data.lev then
                    next_temp_cfg_data = temp_cfg_data
                    break
                end
            end

            if next_temp_cfg_data ~= nil and next_temp_cfg_data.craft == _craft then
                show_shenqi = true
            end
        end
    end

    return show_shenqi
end


--传入点化装备data，检查该武器是否有品阶可以点化(初次点化)
function EquipStrengthModel:check_can_dianhua(equip_data)
    local hasOpenAttrList = {}
    for i=1,#equip_data.attr do
        local attr_data = equip_data.attr[i]
        if attr_data.type == 5 then
            hasOpenAttrList[attr_data.flag] = attr_data
        end
    end
    local dianhua_list = EquipStrengthManager.Instance.model:get_equip_dianhua_list(equip_data.type, RoleManager.Instance.RoleData.classes)
    for i=1,#dianhua_list do
        local cfg_data = dianhua_list[i]
        if cfg_data.lev <= RoleManager.Instance.RoleData.lev then
            --已开启
            if hasOpenAttrList[cfg_data.craft] == nil then
                --未点化
                local base_data = DataItem.data_get[cfg_data.loss[1][1]]
                local has_num = BackpackManager.Instance:GetItemCount(base_data.id)
                local cost_num = cfg_data.loss[1][2]
                if has_num >= cost_num then
                    return true
                end
            end
        end
    end
    return false
end


--检查下是否有装备可以点化
function EquipStrengthModel:check_has_equip_can_craft()
    for k,v in pairs(BackpackManager.Instance.equipDic) do
        if self:check_can_dianhua(v) then
            return true
        end
    end
    return false
end

--传入装备data和品阶，检查该装备的这个品阶是否已经精炼过
function EquipStrengthModel:check_craft_has_done(data, craft)
    local has_done = false
    for i=1,#data.attr do
        local attr_data = data.attr[i]
        if attr_data.type == 5 then
            if attr_data.flag == craft then
                has_done = true
                break
            end
        end
    end
    return has_done
end

--传入装备data和点化data，获取装备这个点化数据所增加的属性类型
function EquipStrengthModel:get_equip_dianhua_attr(equip_data, craft_data)
    local tempAttrData = nil
    for i=1,#equip_data.attr do
        local attr_data = equip_data.attr[i]
        if attr_data.type == 5 then
            if attr_data.flag == craft_data.craft then
                --已经精炼过
                tempAttrData = attr_data
                break
            end
        end
    end
    return tempAttrData
end

function EquipStrengthModel:GetStarCount(val, max, openval)
    local light_star_num = 0
    local star_num = 5
    --     -- 当前星级计算方法:
    --     -- a => 已经通过精炼获得的属性点之和
    --     -- b => 已经开启的精炼项的最大值之和
    --     -- c => 当前能显示到的最大的星数
    --     -- d => 当前需要显示点亮的星数
    --     -- d = (a / b) * c (四舍五入)
    if openval == 0 then
        light_star_num = math.floor(star_num * (val / max) + 0.5)
    else
        if val > openval then
            light_star_num = 5
        elseif val == openval then
            light_star_num = 4
        else
            light_star_num = 4 - (openval - val)
        end
    end
    return light_star_num
end

--检查传入的装备数据对应的装备是否切换在备用状态，如果是则返回备用等级，如果不是则返回当前等级
function EquipStrengthModel:check_equip_is_last_lev(equip_data)
    local last_lev_data = self.equip_spare_attr_list[equip_data.id]
    if last_lev_data ~= nil then
        if last_lev_data.now_lev ~= last_lev_data.back_lev then
            return last_lev_data.back_lev
        end
    end
    return equip_data.lev
end

--传入装备data，检查该装备是否切在备用装备的状态中
function EquipStrengthModel:check_equip_is_last_lev_state(equip_data)
    local last_lev_data = self.equip_spare_attr_list[equip_data.id]
    if last_lev_data ~= nil then
        if last_lev_data.now_lev ~= last_lev_data.back_lev then
            return true
        end
    end
    return false
end


--检查传入的数据是不是神器
function EquipStrengthModel:check_equip_is_shenqi(itemData)
    local shenqi_id = 0
    local shenqi_flag = 0
    if itemData.type == BackpackEumn.ItemType.swords or itemData.type == BackpackEumn.ItemType.gloves or itemData.type == BackpackEumn.ItemType.wands or itemData.type == BackpackEumn.ItemType.bows or itemData.type == BackpackEumn.ItemType.magicbook then
        --检查下是不是神器
        if itemData.extra ~= nil then
            --组织神器的名字
            for i=1,#itemData.extra do
                 if itemData.extra[i].name == 9 then
                    local is_shenqi = true
                    shenqi_id = itemData.extra[i].value

                    for j=1,#itemData.attr do
                        if itemData.attr[j].type == GlobalEumn.ItemAttrType.shenqi then
                            if itemData.attr[j].flag > shenqi_flag then
                                shenqi_flag = itemData.attr[j].flag
                            end
                        end
                    end
                    break
                 end
            end
        end
    end
    return shenqi_id, shenqi_flag
end

--传入装备baseid，确定当前该装备是否为神器
function EquipStrengthModel:check_has_equip_is_shenqi(_base_id)
    local shenqi_id = 0
    local shenqi_flag = 0
    for k,v in pairs(BackpackManager.Instance.equipDic) do
        if v.base_id == _base_id then
            shenqi_id, shenqi_flag = self:check_equip_is_shenqi(v)
            break
        end
    end
    return shenqi_id, shenqi_flag
end

--传入装备data，检查下该装备是否需要突破
function EquipStrengthModel:check_equip_need_break(data)
    local needBreak = false
    if data.enchant == 12 and data.lev >= 80 then
        needBreak = true --强12了，需要突破
    end
    for i=1,#data.extra do
        if data.extra[i].name == 10 then
            needBreak = false --已经突破过了
            break
        end
    end
    return needBreak
end

--传入装备data，检查该装备是否已经突破过
function EquipStrengthModel:check_equip_has_broken(data)
    local has_broken = false
    for i=1,#data.extra do
        if data.extra[i].name == 10 then
            has_broken = true --已经突破过了
            break
        end
    end
    return has_broken
end

--检查下是否有装备可以转职免费重置
function EquipStrengthModel:check_has_equip_changeclasses_dianhua()
    for key,data in pairs(BackpackManager.Instance.equipDic) do
        for i=1,#data.extra do
            local name = data.extra[i].name
            if name >= BackpackEumn.ExtraName.comprehend_free_1 and name <= BackpackEumn.ExtraName.comprehend_free_10 then
                return true --可以转职免费重置
            end
        end
    end
    return false
end

-- 查找是否有转职免费重置
function EquipStrengthModel:check_changeclasses_dianhua(data, craft)
    local free_mark = false

    if craft > 10 then
        -- 没办法啦，先这样吧,反正这几个不免费
        -- hosr
        return false
    end

    for i=1,#data.extra do
        if data.extra[i].name == craft + 10 then
            free_mark = true --可以转职免费重置
            break
        end
    end
    return free_mark
end

-- 计算基础宝石计算高等级宝石市场价
function EquipStrengthModel:count_gem_prive(id)
    if self.gem_priceByBaseid == nil then
        return 0
    end

    local data_stone_classes_modify = DataBacksmith.data_stone_classes_modify[id]
    if data_stone_classes_modify == nil then
        return 0
    else
        return self.gem_priceByBaseid[data_stone_classes_modify.stone_base_id].price * data_stone_classes_modify.count
    end
end

--计算当前人物装备已经升到哪个徽章
function EquipStrengthModel:GetCurEquipBadge()
    local id = -1
    local neeLightStarNum = 4
    local tempList = {}
    for k,v in pairs(BackpackManager.Instance.equipDic) do
        if tempList[v.type] == nil then
            tempList[v.type] = {}
            tempList[v.type].flag = 0
        end
        tempList[v.type].light_star_num = 0
        local dianhuaCfgList = EquipStrengthManager.Instance.model:get_equip_dianhua_list(v.type, RoleManager.Instance.RoleData.classes)

        table.sort(v.attr, function(a, b)
            return a.flag < b.flag
        end)
        for i=1,#v.attr do
            --找到改装备最大的精炼等级
            local attr_data = v.attr[i]
            local light_star_num = 0

            if attr_data.type == 5 then
                for j = 1, #dianhuaCfgList do
                    if dianhuaCfgList[j].craft == attr_data.flag then
                        light_star_num = self:GetStarCount(attr_data.val, dianhuaCfgList[j].max_val, dianhuaCfgList[j].looks_active_val)
                    end
                end
                if light_star_num < neeLightStarNum then
                    break
                end

                if (attr_data.flag > tempList[v.type].flag or tempList[v.type].flag == 0)  then
                    tempList[v.type].flag = attr_data.flag
                end
                tempList[v.type].light_star_num = light_star_num
            end
        end
    end

    for k, v in pairs(tempList) do
        local nextCfgData = DataEqm.data_dianhua_suit[string.format("%s_%s", v.flag, RoleManager.Instance.RoleData.classes)]
        while nextCfgData ~= nil and nextCfgData.ignore == 0 and v.flag <= 10 do
            v.flag = v.flag - 1
            nextCfgData = DataEqm.data_dianhua_suit[string.format("%s_%s", v.flag, RoleManager.Instance.RoleData.classes)]
        end
    end

    for k, v in pairs(tempList) do
        if id == -1 then
            id = v.flag
        else
            if v.flag < id then
                id = v.flag
            end
        end
    end
    return id
end

--传入装备id，传入品质，确定该装备是否也已经满足该精炼徽章的条件
function EquipStrengthModel:CheckDianhuaCondition(equipData, flag)
    local neeLightStarNum = 4
    local light_star_num = 0

    local dianhuaCfgList = EquipStrengthManager.Instance.model:get_equip_dianhua_list(equipData.type, RoleManager.Instance.RoleData.classes)
    local curBadgeId = 0
        table.sort(equipData.attr, function(a, b)
            return a.flag < b.flag
        end)
        for i=1,#equipData.attr do
            --找到改装备最大的精炼等级
            local attr_data = equipData.attr[i]
            local light_star_num = 0
            if attr_data.type == 5 then
                for j = 1, #dianhuaCfgList do
                    if dianhuaCfgList[j].craft == attr_data.flag then
                        light_star_num = self:GetStarCount(attr_data.val, dianhuaCfgList[j].max_val, dianhuaCfgList[j].looks_active_val)
                    end
                end
                if light_star_num < neeLightStarNum then
                    break
                end

                if (attr_data.flag > curBadgeId or curBadgeId == 0)  then
                    curBadgeId = attr_data.flag
                end
            end
        end

    if curBadgeId >= flag then
        return true
    else
        return false
    end
end

function EquipStrengthModel:OpenGetRoleHalo(args)
    if self.getRoleHalo == nil then
        self.getRoleHalo = GetRoleView.New(self)
    end
    self.getRoleHalo:Show(args)
end

function EquipStrengthModel:CloseGetRoleHalo()
    if self.getRoleHalo ~= nil then
        self.getRoleHalo:DeleteMe()
        self.getRoleHalo = nil
    end
end

function EquipStrengthModel:OpenAppointEffectWindow(args)
    if self.appointeffectwin == nil then
        self.appointeffectwin = AppointEffectWindow.New(self)
    end
    self.appointeffectwin:Open(args)
end

function EquipStrengthModel:CloseAppointEffectWindow()
    if self.appointeffectwin ~= nil then
        self.appointeffectwin:DeleteMe()
        self.appointeffectwin = nil
    end
end