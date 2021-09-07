ShouhuModel = ShouhuModel or BaseClass(BaseModel)

function ShouhuModel:__init()
    -- 守护阵法名称
    self.guard_tactic = {
        liuMangXing = 1
    }

    self.guard_equip_type = {
        weapon = 15,
        cloth = 16,
        yaodai = 17,
        shoes = 18,
        lian = 19,
        huwan = 20
    }

    -- 守护职业类型
    self.guard_classes = {
        wind = 2,
        -- 风
        fire = 4,
        -- 火
        forest = 3,
        -- 林
        mountain = 1,
        -- 山
        star = 0-- 星辰
    }

    -- 守护阵位名称
    self.guard_tactic_pos = {
        xue = 1,
        gong = 2,
        zhun = 3,
        bao = 4,
        fang = 5,
        shang = 6
    }

    -- 守护战斗出阵状态
    self.guard_fight_state = {
        idle = 0,
        -- 空闲
        ready = - 1,
        -- 出战, 废弃
        field = 2-- 上阵
    }

    -- 守护分类
    self.shouhu_pub_classify = {
        yongzhe = 1,
        shishi = 2,
        chuangshuo = 3
    }

    self.sh_lang = {
        SH_STAR_ITEM_TIPS_WORD_UNACT = TI18N("角色达到%s级可开启该阵位")
        ,
        SH_STAR_ITEM_TIPS_WORD_1 = TI18N("血 -> 守护助战在当前站位可给予队伍中出战的守护增加生命属性加成")
        ,
        SH_STAR_ITEM_TIPS_WORD_2 = TI18N("攻 -> 守护助战在当前站位可给予队伍中出战的守护增加物攻属性加成")
        ,
        SH_STAR_ITEM_TIPS_WORD_3 = TI18N("御 -> 守护助战在当前站位可给予队伍中出战的守护增加魔防属性加成")
        ,
        SH_STAR_ITEM_TIPS_WORD_4 = TI18N("魔 -> 守护助战在当前站位可给予队伍中出战的守护增加魔攻属性加成")
        ,
        SH_STAR_ITEM_TIPS_WORD_5 = TI18N("盾 -> 守护助战在当前站位可给予队伍中出战的守护增加物防属性加成")
        ,
        SH_STAR_ITEM_TIPS_WORD_6 = TI18N("准 -> 守护助战在当前站位可给予队伍中出战的守护增加命中属性加成")
        ,
        SH_STAR_STATICS_POS_UNOPEN = TI18N("该阵位尚未开启")
        ,
        SH_STAR_STATICS_POS_UNSET = TI18N("请先拖动守护到阵位，再出战")
    }

    self.main_tab_first_opera_type = 0

    self.shouhu_look_lev = 0
    self.shouhu_look_owner_name = ""

    self.one_img_name_height = 24
    self.one_img_name_width = 120

    self.one_big_img_name_width = 190
    self.one_big_img_name_height = 42

    self.nextFrameUpdateStar = false
    -- 当前出战的守护id列表
    self.cur_out_fight_base_ids = nil

    -- 阵法数据列表
    -- public Dictionary<uint,List<SHTacticsData>>
    self.tactic_dic = { }
    self.cur_tactic = self.guard_tactic.liuMangXing

    -- 已获得的守护列表 new List<SHBaseData>( )
    self.my_sh_list = { }

    self.my_sh_selected_data = nil
    self.my_sh_selected_equip = nil

    self.my_sh_selected_look_data = nil
    self.my_sh_selected_look_equip = nil
    self.has_rec_succs_bid = 0
    self.cur_sh_lev = 0
    self.shouhu_icon_effect = false
    self.init_equip_lev = 10
    self.wakeUpOpenLev = 55
    self.wakeUpDataSocketDic = { }
    self.wakeUpSkillDic = { }
    self.wakeUpMaxPoint = 8
    self.wakeUpMaxQuality = 5
    self.wakeUpQualityName = { [1] = TI18N("绿"), [2] = TI18N("蓝"), [3] = TI18N("紫"), [4] = TI18N("橙"), [5] = TI18N("红") }
    self.cur_stone_look_dic = { }

    self.base_prop_vals = { }
    self:init_shouhu_base_prop_val()
    self.main_win = nil
    self.success_win = nil
    self.equip_win = nil
    self.look_win = nil
    self.look_equip_win = nil
    self.wakeup_attr_tip = nil
    self.getWakeUpLookWindow = nil
    self.getWakeUpLookPointWindow = nil
    self.wakeupPointTips = nil
    self.stoneLookPanel = nil

    self.selectedTransferAnotherSH = { }
    self.my_sh_GemsLevelList = {}   --守护最低宝石等级

    self.equipMaxLev = 110
    self.GuardWakeupUpgradeAttr = { }
end

function ShouhuModel:__delete()
    self:CloseShouhuMainUI()
    self:CloseShouhuSuccessUI()
    self:CloseShouhuEquipUI()
end


-----------------------各种界面打开更新逻辑
-- 打开守护主面板
function ShouhuModel:OpenShouhuMainUI(args)
    if self.main_win == nil then
        self.main_win = ShouhuMainWindow.New(self)
    else
        if args ~= nil then
            self.main_win:tabChange(args[1])
        end
    end
    self.main_win:Open()
end

-- 关闭守护主面板
function ShouhuModel:CloseShouhuMainUI()
    WindowManager.Instance:CloseWindow(self.main_win)
    if self.main_win == nil then
        -- print("===================self.main_win is nil")
    else
        -- print("===================self.main_win is not nil")
    end
end

-- 打开守护装备面板
function ShouhuModel:OpenShouhuEquipUI()
    if self.equip_win == nil then
        self.equip_win = ShouhuEquipWindow.New(self)
    end
    self.equip_win:Open()
end

-- 关闭守护装备面板
function ShouhuModel:CloseShouhuEquipUI()
    WindowManager.Instance:CloseWindow(self.equip_win)
    if self.equip_win == nil then
        -- print("===================self.equip_win is nil")
    else
        -- print("===================self.equip_win is not nil")
    end
end

-- 打开守护招募成功面板
function ShouhuModel:OpenShouhuSuccessUI()
    if self.success_win == nil then
        self.success_win = ShouhuSuccessWindow.New(self)
        self.success_win:Open()
    end
end

-- 关闭守护招募成功面板
function ShouhuModel:CloseShouhuSuccessUI()
    WindowManager.Instance:CloseWindow(self.success_win)
    if self.success_win == nil then
        -- print("===================self.success_win is nil")
    else
        -- print("===================self.success_win is not nil")
    end
end

-- 打开守护查看窗口
function ShouhuModel:OpenShouhuLookUI()
    if self.look_win == nil then
        self.look_win = ShouhuLookWindow.New(self)
        self.look_win:Show()
    end
end

-- 关闭守护查看窗口
function ShouhuModel:CloseShouhuLookUI()
    self.look_win:DeleteMe()
    self.look_win = nil
    if self.look_win == nil then
        -- print("===================self.look_win is nil")
    else
        -- print("===================self.look_win is not nil")
    end
end

-- 打开守护装备查看面板
function ShouhuModel:OpenShouhuLookEquipUI()
    if self.look_equip_win == nil then
        self.look_equip_win = ShouhuLookEquipWindow.New(self)
        self.look_equip_win:Show()
    end
end

-- 关闭守护装备查看面板
function ShouhuModel:CloseShouhuLookEquipUI()
    self.look_equip_win:DeleteMe()
    self.look_equip_win = nil
end

-- 打开守护觉醒属性提示
function ShouhuModel:OpenShouhuWakeUpAttrTipsUI(args)
    if self.wakeup_attr_tip == nil then
        self.wakeup_attr_tip = ShouhuWakeUpAttrTips.New(self)
        self.wakeup_attr_tip:Show(args)
    end
end

-- 关闭守护觉醒属性提示
function ShouhuModel:CloseShouhuWakeUpAttrTipsUI()
    self.wakeup_attr_tip:DeleteMe()
    self.wakeup_attr_tip = nil
end

-- 更新守护觉醒提示
function ShouhuModel:UpdateWakeupAttrTips(data)
    if self.wakeup_attr_tip ~= nil then
        self.wakeup_attr_tip:UpdateWakeupAttrTips(data)
    end
end

function ShouhuModel:OpenGetWakeUpLookWindow(args)
    if self.getWakeUpLookWindow == nil then
        self.getWakeUpLookWindow = ShouhuGetLookView.New(self)
    end
    self.getWakeUpLookWindow:Show(args)
end

function ShouhuModel:CloseGetWakeUpLookWindow()
    if self.getWakeUpLookWindow ~= nil then
        self.getWakeUpLookWindow:DeleteMe()
    end
    self.getWakeUpLookWindow = nil
end

function ShouhuModel:OpenGetWakeUpLookPointWindow(args)
    if self.getWakeUpLookPointWindow == nil then
        self.getWakeUpLookPointWindow = ShouhuGetPointLookView.New(self)
    end
    self.getWakeUpLookPointWindow:Show(args)
end

function ShouhuModel:CloseGetWakeUpLookPointWindow()
    if self.getWakeUpLookPointWindow ~= nil then
        self.getWakeUpLookPointWindow:DeleteMe()
    end
    self.getWakeUpLookPointWindow = nil
end

function ShouhuModel:OpenWakeupPointTips(args)
    if self.wakeupPointTips == nil then
        self.wakeupPointTips = ShouhuWakeUpPointTips.New(self)
    end
    self.wakeupPointTips:Show(args)
end

function ShouhuModel:CloseWakeupPointTips()
    if self.wakeupPointTips ~= nil then
        self.wakeupPointTips:DeleteMe()
    end
    self.wakeupPointTips = nil
end


function ShouhuModel:OpeStoneLookTips(args)
    if self.stoneLookPanel == nil then
        self.stoneLookPanel = ShouhuStoneLookWindow.New(self)
    end
    self.stoneLookPanel:Show(args)
end

function ShouhuModel:CloseStoneLookPanel()
    if self.stoneLookPanel ~= nil then
        self.stoneLookPanel:DeleteMe()
    end
    self.stoneLookPanel = nil
end


------------------------------各种面板更新
function ShouhuModel:update_main_win_left_list(args)
    if self.main_win ~= nil then
        self.main_win:update_left_list(args)
    end
end

function ShouhuModel:update_help_fight_red_point()
    if self.main_win ~= nil then
        self.main_win:update_help_fight_red_point()
    end
end

function ShouhuModel:update_red_point(args)
    if self.main_win ~= nil then
        self.main_win:update_red_point(args)
    end
end

-- 更新星阵
function ShouhuModel:update_star_view()
    if self.main_win ~= nil then
        self.main_win:update_star_view()
    end
end

-- 更新装备界面
function ShouhuModel:update_equip_view()
    if self.equip_win ~= nil then
        self.equip_win:update_view()
    end
end

-- 更新选中的守护界面的装备
function ShouhuModel:update_main_win_equip()
    if self.main_win ~= nil then
        self.main_win:update_first_sh_equip()
    end
end

-- 更新守护查看面板的逻辑
function ShouhuModel:update_shouhu_look_view(data)
    if self.look_win ~= nil then
        self.look_win:update_view(data)
    end
end


------------------------------对frozenbutton的click和release调用
-- 装备面板，重置和升级按钮
function ShouhuModel:Frozen_equip_up_reset()
    if self.equip_win ~= nil then
        if self.equip_win.restoreFrozen_reset ~= nil then
            self.equip_win.restoreFrozen_reset:OnClick()
        end
        if self.equip_win.restoreFrozen_upgrade ~= nil then
            self.equip_win.restoreFrozen_upgrade:OnClick()
        end
        if self.equip_win.restoreFrozen_reset_small ~= nil then
            self.equip_win.restoreFrozen_reset_small:OnClick()
        end
    end
end

function ShouhuModel:Release_equip_up_reset()
    if self.equip_win ~= nil then
        if self.equip_win.restoreFrozen_reset ~= nil then
            self.equip_win.restoreFrozen_reset:Release()
        end
        if self.equip_win.restoreFrozen_upgrade ~= nil then
            self.equip_win.restoreFrozen_upgrade:Release()
        end
        if self.equip_win.restoreFrozen_reset_small ~= nil then
            self.equip_win.restoreFrozen_reset_small:Release()
        end
    end
end

-- 宝石升级
function ShouhuModel:Frozen_equip_stone_up()
    if self.equip_win ~= nil then
        if self.equip_win.restoreFrozen_stone_upgrade ~= nil then
            self.equip_win.restoreFrozen_stone_upgrade:OnClick()
        end
    end
end

function ShouhuModel:Release_equip_stone_up()
    if self.equip_win ~= nil then
        if self.equip_win.restoreFrozen_stone_upgrade ~= nil then
            self.equip_win.restoreFrozen_stone_upgrade:Release()
        end
    end
end

-----------------------------各种check，has逻辑
--
function ShouhuModel:build_look_win_data(socket_data, lev)
    local temp_dat = ShouhuManager.Instance.model:get_sh_base_dat_by_id(socket_data.base_id)
    local dat = BaseUtils.copytab(temp_dat)
    -- 从配置data里面复制一个出来就有配置里面的数据了
    dat.sh_lev = lev
    if socket_data.quality ~= nil then
        dat.quality = socket_data.quality
    end
    local temp_skills = ShouhuManager.Instance.model:get_skill_data_dic_by_base_id(socket_data.base_id)
    dat.has_get_skill_list = { }

    for i = 1, #temp_skills do
        local sd = temp_skills[i]
        if sd[2] <= dat.sh_lev then
            table.insert(dat.has_get_skill_list, sd[1])
        end
    end


    dat.guard_fight_state = socket_data.status
    dat.war_id = socket_data.war_id
    -- 0就表示没有上阵

    dat.tactic_index = 1
    dat.tactic_pos = socket_data.tac_pos
    dat.score = socket_data.score

    dat.sh_attrs_list = { }
    dat.sh_attrs_list.hp_max = socket_data.hp_max
    dat.sh_attrs_list.mp_max = socket_data.mp_max
    dat.sh_attrs_list.atk_speed = socket_data.atk_speed
    dat.sh_attrs_list.phy_dmg = socket_data.phy_dmg
    dat.sh_attrs_list.magic_dmg = socket_data.magic_dmg
    dat.sh_attrs_list.phy_def = socket_data.phy_def
    dat.sh_attrs_list.magic_def = socket_data.magic_def
    dat.sh_attrs_list.heal_val = socket_data.heal_val
    dat.equip_list = { }

    for i = 1, #socket_data.eqm do
        -- 守护装备数据
        local item2 = socket_data.eqm[i]
        local cfgEqDat = ShouhuManager.Instance.model:get_equip_data_by_base_id(item2.base_id)
        local eqDat = BaseUtils.copytab(cfgEqDat)
        eqDat.lev = cfgEqDat.lev
        eqDat.base_id = cfgEqDat.base_id
        eqDat.loss_coin = cfgEqDat.loss_coin
        eqDat.reset_coin = cfgEqDat.reset_coin

        eqDat.base_attrs = { }
        eqDat.ext_attrs = { }
        eqDat.eff_attrs = { }

        for i = 1, #item2.eqm_attrs do
            local item3 = item2.eqm_attrs[i]
            if item3.type == GlobalEumn.ItemAttrType.base then
                table.insert(eqDat.base_attrs, item3)
            elseif item3.type == GlobalEumn.ItemAttrType.extra then
                table.insert(eqDat.ext_attrs, item3)
            elseif item3.type == GlobalEumn.ItemAttrType.effect then
                table.insert(eqDat.eff_attrs, item3)
            end
        end

        eqDat.reset_base_id = item2.reset_base_id
        eqDat.reset_base_attrs_next = { }
        eqDat.reset_ext_attrs_next = { }
        eqDat.reset_eff_attrs_next = { }
        if item2.reset_attrs ~= nil then
            for k = 1, #item2.reset_attrs do
                local item3 = item2.reset_attrs[k]
                if item3.type == GlobalEumn.ItemAttrType.base then
                    table.insert(eqDat.reset_base_attrs_next, item3)
                elseif item3.type == GlobalEumn.ItemAttrType.extra then
                    table.insert(eqDat.reset_ext_attrs_next, item3)
                elseif item3.type == GlobalEumn.ItemAttrType.effect then
                    table.insert(eqDat.reset_eff_attrs_next, item3)
                end
            end
        end

        eqDat.gem = item2.gem
        if eqDat.gem == nil then
            eqDat.gem = { }
        end

        dat.equip_list[ShouhuManager.Instance.equip_pos[eqDat.type]] = eqDat
    end
    return dat
end

-- 检查下是否有上阵的守护有装备可以升级
function ShouhuModel:check_has_shouhu_war_equip_canup()
    for i = 1, #self.my_sh_list do
        local data = self.my_sh_list[i]
        if data.war_id ~= 0 then
            for i = 1, #data.equip_list do
                local ed = data.equip_list[i]
                local curlev = ed.lev
                local nextlev = ed.lev + self.init_equip_lev

                if nextlev > data.sh_lev then
                    nextlev = curlev
                end
                while nextlev < data.sh_lev do
                    nextlev = nextlev + self.init_equip_lev
                end

                if nextlev > data.sh_lev then
                    nextlev = nextlev - self.init_equip_lev
                end

                if nextlev - curlev >= self.init_equip_lev then
                    local roleLev = RoleManager.Instance.RoleData.lev
                    if roleLev >= ShouhuManager.Instance.maxRoleLev and ed.lev == ShouhuManager.Instance.maxEquipLev then

                    else
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- 检查当前是否有守护可以招募
function ShouhuModel:check_has_shouhu_can_recruit()
    for k, v in pairs(DataShouhu.data_guard_base_cfg) do
        local dat = v
        if self:check_has_sh_by_id(dat.base_id) == false and dat.recruit_lev <= RoleManager.Instance.RoleData.lev then
            return true
            -- 有可以招募的招募
        end
    end
    return false
end

-- 检查下所有的守护中是否有装备可以升级
function ShouhuModel:check_has_shouhu_equip_canup()
    for i = 1, #self.my_sh_list do
        local data = self.my_sh_list[i]
        if data.war_id ~= 0 then
            for i = 1, #data.equip_list do
                local ed = data.equip_list[i]
                local curlev = ed.lev
                local nextlev = ed.lev + self.init_equip_lev

                if nextlev > data.sh_lev then
                    nextlev = curlev
                end
                while nextlev < data.sh_lev do
                    nextlev = nextlev + self.init_equip_lev
                end

                if nextlev > data.sh_lev then
                    nextlev = nextlev - self.init_equip_lev
                end

                if nextlev - curlev >= self.init_equip_lev then
                    if DataShouhu.data_guard_equip_cfg_two[string.format("%s_%s_%s", nextlev, data.classes, ed.type)] ~= nil then
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- 检查下所有的守护中是否有出战上阵的守护的装备可以升级
function ShouhuModel:check_has_outfight_shouhu_equip_canup()
    for i = 1, #self.my_sh_list do
        local data = self.my_sh_list[i]

        if data.war_id ~= 0 then
            -- 有上阵或者助战or data.guard_fight_state == ShouhuModel:guard_fight_state.field
            for i = 1, #data.equip_list do
                local ed = data.equip_list[i]
                local curlev = ed.lev
                local nextlev = ed.lev + self.init_equip_lev

                if nextlev > data.sh_lev then
                    nextlev = curlev
                end
                while nextlev < data.sh_lev do
                    nextlev = nextlev + self.init_equip_lev
                end
                if nextlev > data.sh_lev then
                    nextlev = nextlev - self.init_equip_lev
                end
                if nextlev - curlev >= self.init_equip_lev then
                    return true
                end
            end
        end
    end
    return false
end

-- 传入守护id检查下是否已经招募了该守护
function ShouhuModel:check_has_sh_by_id(base_id)
    if #self.my_sh_list == 0 then
        return false
    end
    for i = 1, #self.my_sh_list do
        local d = self.my_sh_list[i]
        if d.base_id == base_id then
            return true
        end
    end
    return false
end

-- 根据基础id获取守护基础data
function ShouhuModel:get_sh_base_dat_by_id(base_id)
    return DataShouhu.data_guard_base_cfg[base_id]
end

-- 传入守护基础id获取该守护每个等级段的技能id列表
function ShouhuModel:get_skill_data_dic_by_base_id(base_id)
    local shSkillList = DataShouhu.data_guard_skill_cfg[base_id].skills
    return shSkillList
end

-- 根据等级和类型获取装备data
function ShouhuModel:get_equip_data_by_type_and_lev(_type, lev, _classes)
    for k, v in pairs(DataShouhu.data_guard_equip_cfg) do
        if v.lev == lev and v.type == _type and v.classes == _classes then
            return v
        end
    end
    return nil
end

-- 根据装备id获取装备配置data
function ShouhuModel:get_equip_data_by_base_id(_base_id)
    return DataShouhu.data_guard_equip_cfg[_base_id]
end

-- 检查招募索要消耗的道具数够不够
function ShouhuModel:checkt_loss_num_enough(lossType, lossItemId, lossItemNum)
    if lossType == "coin" then
        if RoleManager.Instance.RoleData.coin >= lossItemNum then
            return true
        end
    elseif lossType == "item_base_id" then
        if BackpackManager.Instance:GetItemCount(lossItemId) >= lossItemNum then
            return true
        end
    end
    return false
end

-- 获取某个守护评分
function ShouhuModel:get_score(dat)
    if dat.score ~= nil then
        return dat.score
    end
    return 0
end

-- 获取守护成长值
function ShouhuModel:get_growth(data)
    return self:KeepPointNum(data.growth / 1000)
end

-- 获取未招募守护的成长值
function ShouhuModel:get_unrecruit_growth(data)
    return self:KeepPointNum(data.growth / 1000)
end

-- 获取未招募守护评分
function ShouhuModel:get_unrecruit_score(dat)
    local attr_whole = 0
    for i = 1, #dat.sh_attrs_list do
        local d = dat.sh_attrs_list[i]
        local key = string.format("%s_%s", dat.classes, d.attr)
        local Factor = DataShouhu.data_guard_prop_score[key].factor
        attr_whole =(d.val * Factor + attr_whole) / 1000
    end
    local score = attr_whole / 55 + dat.base_score
    return math.ceil(score)
end

-- 传入守护id从我的守护列表中获取守护data
function ShouhuModel:get_my_shouhu_data_by_id(base_id)
    for i = 1, #self.my_sh_list do
        local data = self.my_sh_list[i]
        if data.base_id == base_id then
            return data
        end
    end
    return nil
end

-- 根据宝石类型获取一级宝石配置数据
function ShouhuModel:get_stone_cfg_data(_type)
    for k, v in pairs(DataShouhu.data_guard_stone_prop) do
        if v.type == _type and v.lev == 1 then
            return v
        end
    end
end

-- 传入装备数据，获取改装备还可镶嵌的宝石列表
function ShouhuModel:get_equip_can_eqm_stone(ed)
    local can_eqm = { }
    local has_eqm = { }
    for i = 1, #ed.gem do
        local gem_data = ed.gem[i]
        has_eqm[gem_data.type] = gem_data
    end

    local cfg_allow_list = DataShouhu.data_guard_stone_limit[ed.type].allow
    local recommend = DataShouhu.data_guard_recomend_stone[string.format("%s_%s", ed.type, ed.classes)].recommend_gem

    for i = 1, #cfg_allow_list do
        -- 将推荐的宝石放第一位
        local allow_data = cfg_allow_list[i]
        if allow_data.type == recommend then
            local temp = cfg_allow_list[1]
            cfg_allow_list[i] = temp
            cfg_allow_list[1] = allow_data
            break
        end
    end

    local temp_list = { }
    for i = 1, #cfg_allow_list do
        if has_eqm[cfg_allow_list[i].type] == nil or cfg_allow_list[i].val1 >= 2 then
            -- 没有被镶嵌，或者可以镶嵌两次的都属于可镶嵌的宝石
            table.insert(can_eqm, cfg_allow_list[i])
        end
    end
    return can_eqm
end

-- 传入装备数据和孔位id，获取该孔位数据
function ShouhuModel:get_equip_eqm_id_data(ed, id)
    for i = 1, #ed.gem do
        local gem_data = ed.gem[i]
        if gem_data.id == id then
            return gem_data
        end
    end
    return nil
end

-- 传入守护宝石类型，获取宝石可以镶嵌的装备类型
function ShouhuModel:get_stone_equip_type(_stone_type)
    local equip_types = { }
    for k, v in pairs(DataShouhu.data_guard_stone_limit) do
        for i = 1, #v.allow do
            local ad = v.allow[i]
            if ad.type == _stone_type then
                table.insert(equip_types, v.type)
            end
        end
    end
    return equip_types
end

-- 根据阵法类型和出阵位置获取该位置的baseData
function ShouhuModel:get_base_data_by_tactic(pos)
    if #self.my_sh_list == 0 then
        return nil
    end

    for i = 1, #self.my_sh_list do
        local bd = self.my_sh_list[i]
        if bd.tactic_pos == pos then
            return bd
        end
    end
    return nil
end

function ShouhuModel:init_equip_list(dat, _lev)
    local lev = _lev
    if lev == nil then
        lev = self.init_equip_lev
    end
    dat.equip_list = { }
    local cfgEd = self:get_equip_data_by_type_and_lev(self.guard_equip_type.weapon, lev, dat.classes)
    local ed = BaseUtils.copytab(cfgEd)
    table.insert(dat.equip_list, ed)
    cfgEd = self:get_equip_data_by_type_and_lev(self.guard_equip_type.cloth, lev, dat.classes)
    ed = BaseUtils.copytab(cfgEd)
    table.insert(dat.equip_list, ed)
    cfgEd = self:get_equip_data_by_type_and_lev(self.guard_equip_type.yaodai, lev, dat.classes)
    ed = BaseUtils.copytab(cfgEd)
    table.insert(dat.equip_list, ed)
    cfgEd = self:get_equip_data_by_type_and_lev(self.guard_equip_type.lian, lev, dat.classes)
    ed = BaseUtils.copytab(cfgEd)
    table.insert(dat.equip_list, ed)
    cfgEd = self:get_equip_data_by_type_and_lev(self.guard_equip_type.huwan, lev, dat.classes)
    ed = BaseUtils.copytab(cfgEd)
    table.insert(dat.equip_list, ed)
    cfgEd = self:get_equip_data_by_type_and_lev(self.guard_equip_type.shoes, lev, dat.classes)
    ed = BaseUtils.copytab(cfgEd)
    table.insert(dat.equip_list, ed)
end

-- 传入判断是否有超过一件的装备可以升级
function ShouhuModel:get_can_up_equip_num(shdata)
    local count = 0
    for i = 1, #shdata.equip_list do
        local ed = shdata.equip_list[i]
        if (shdata.sh_lev - ed.lev) >= self.init_equip_lev then
            count = count + 1
        end
    end
    return count
end

-- 传入某个守护判断下该守护是否有装备能升级
function ShouhuModel:check_shouhu_equip_can_lev_up(shdata)
    for i = 1, #shdata.equip_list do
        local ed = shdata.equip_list[i]
        if (shdata.sh_lev - ed.lev) >= self.init_equip_lev and ed.lev < 100 then
            return true
        end
    end
    return false
end

-- 检查传入的守护是否可以招募，且材料也够
function ShouhuModel:check_can_recruit(sh_data)
    for i = 1, #self.my_sh_list do
        if self.my_sh_list[i].base_id == sh_data.base_id then
            return false
        end
    end
    if sh_data.recruit_lev > RoleManager.Instance.RoleData.lev then
        return false
    end

    local loss_data = sh_data.loss[1]
    local loss_item_num_str = ""
    local has_num = 0
    local lossItemId = 0
    local lossItemNum = 0
    if loss_data.label == "item_base_id_auto_buy" then
        lossItemId = loss_data.val[1][1]
        lossItemNum = loss_data.val[1][2]
        has_num = BackpackManager.Instance:GetItemCount(lossItemId)
    elseif loss_data.label == "coin" then
        lossItemId = 90000
        lossItemNum = loss_data.val[1]
        has_num = RoleManager.Instance.RoleData.coin
    end

    if has_num < lossItemNum then
        return false
    end
    return true
end

-- 检查下守护列表中是否有上阵守护可以升级或者钻石可以镶嵌
function ShouhuModel:check_has_shouhu_up_stone()
    for i = 1, #self.my_sh_list do
        if self.my_sh_list[i].war_id ~= nil and self.my_sh_list[i].war_id ~= 0 then
            if self:check_shouhu_equip_can_up(self.my_sh_list[i]) then
                return true
            end
        end
    end
    return false
end

-- 传入某个守护判断下该守护是否有装备能升级或有钻石可以镶嵌
function ShouhuModel:check_shouhu_equip_can_up(shdata)
    for i = 1, #shdata.equip_list do
        local ed = shdata.equip_list[i]
        if self:check_equip_can_up_stone(shdata, ed) == true then
            return true
        end
    end
    return false
end

-- 传入某个守护数据和这个守护的某个装备，判断下该装备是否能升级或者是否有钻石可以镶嵌
function ShouhuModel:check_equip_can_up_stone(sh, eq)
    if (sh.sh_lev - eq.lev) >= self.init_equip_lev then
        local roleLev = RoleManager.Instance.RoleData.lev
        if roleLev >= ShouhuManager.Instance.maxRoleLev and eq.lev == ShouhuManager.Instance.maxEquipLev then
            return false
        else
            return true
            -- 可以升级
        end
    end
    if sh.sh_lev >= 50 and self:check_equip_can_stone(eq) == true then
        return true
    end
    return false
end

-- 传入装备数据，判断下这件装备能不能镶嵌宝石
function ShouhuModel:check_equip_can_stone(eq)
    if eq.lev < 40 then
        -- 两个孔位都没开启
        return false
    end
    local gem_data1 = self:get_equip_eqm_id_data(eq, 1)
    local gem_data2 = self:get_equip_eqm_id_data(eq, 2)
    if gem_data1 == nil and eq.lev >= 40 then
        -- 第一个孔位没镶嵌，同时已经开孔
        local cur_can_eqm_list = self:get_equip_can_eqm_stone(eq)
        for i = 1, #cur_can_eqm_list do
            local allow_data = cur_can_eqm_list[i]
            local temp_data = self:get_stone_cfg_data(allow_data.type)
            local need_num = temp_data.loss_coin[1].val
            local has_num = RoleManager.Instance.RoleData:GetMyAssetById(90000)
            if need_num <= has_num then
                return true
            end
        end
    end

    if gem_data2 == nil and eq.lev >= 60 then
        -- 第二个孔位没镶嵌，同时已经开孔
        local cur_can_eqm_list = self:get_equip_can_eqm_stone(eq)
        for i = 1, #cur_can_eqm_list do
            local allow_data = cur_can_eqm_list[i]
            local temp_data = self:get_stone_cfg_data(allow_data.type)
            local need_num = temp_data.loss_coin[1].val
            local has_num = RoleManager.Instance.RoleData:GetMyAssetById(90000)
            if need_num <= has_num then
                return true
            end
        end
    end
    return false
end

-- 检查全部上阵守护没升级过
function ShouhuModel:check_all_shangzhen_no_up()
    for i = 1, #self.my_sh_list do
        local temp = self.my_sh_list[i]
        if temp.war_id ~= nil and temp.war_id ~= 0 then
            for j = 1, #temp.equip_list do
                local ed = temp.equip_list[j]
                if ed.lev >= 40 then
                    return false
                    -- 已经升级过
                end
            end
        end
    end
    return true
end

-- 检查全部上阵守护的全部装备没镶嵌过
function ShouhuModel:check_all_shangzhen_no_stone()
    for i = 1, #self.my_sh_list do
        local temp = self.my_sh_list[i]
        if temp.war_id ~= nil and temp.war_id ~= 0 then
            for i = 1, #temp.equip_list do
                local ed = temp.equip_list[i]
                local gem_data1 = self:get_equip_eqm_id_data(ed, 1)
                local gem_data2 = self:get_equip_eqm_id_data(ed, 2)
                if gem_data1 ~= nil and gem_data2 ~= nil then
                    return false
                end
            end
        end
    end
    return true
end

-- 检查下是否有阵位可以助战
function ShouhuModel:check_can_help_fight()
    local help_fight_list = self:get_star_cfg_data_list()
    for i = 1, #help_fight_list do
        local dat = help_fight_list[i]
        if dat.has_act then
            if self:get_base_data_by_tactic(dat.act_pos) == nil then
                return true
            end
        end
    end

    return false
end

-- 获取助战基础配置数据列表
function ShouhuModel:get_star_cfg_data_list()
    local starDataList = { }
    -- 根据socket和配置构建 curTactic 的数据
    for k, v in pairs(DataShouhu.data_guard_help_fight) do
        local tDat = { }
        tDat.act_pos = v.pos
        tDat.act_lev = v.act_lev
        tDat.has_act = false
        if tDat.act_lev <= RoleManager.Instance.RoleData.lev then
            tDat.has_act = true
        end
        table.insert(starDataList, tDat)
    end
    return starDataList
end


-- 获取基础属性值
function ShouhuModel:init_shouhu_base_prop_val()
    for k, v in pairs(DataShouhu.data_guard_base_prop_val) do
        self.base_prop_vals[k] = { }
        self.base_prop_vals[k][1] = v.attr_hp_max
        self.base_prop_vals[k][2] = v.attr_mp_max
        self.base_prop_vals[k][3] = v.attr_atk_speed
        self.base_prop_vals[k][4] = v.attr_phy_dmg
        self.base_prop_vals[k][5] = v.attr_magic_dmg
        self.base_prop_vals[k][6] = v.attr_phy_def
        self.base_prop_vals[k][7] = v.attr_magic_def
        self.base_prop_vals[k][8] = v.attr_crit
        self.base_prop_vals[k][9] = v.attr_tenacity
        self.base_prop_vals[k][10] = v.attr_accuracy
        self.base_prop_vals[k][11] = v.attr_evasion
        self.base_prop_vals[k][25] = v.attr_enhance_control
        self.base_prop_vals[k][26] = v.attr_anti_control
        self.base_prop_vals[k][43] = v.attr_heal_val
    end
end

-- 找守护装备洗练档次
function ShouhuModel:get_equip_wash_grade(attr)
    local min, max = 0, 0
    for k, v in pairs(DataShouhu.data_guard_base_grade) do
        if v.attr_name == attr then
            if min == 0 then
                min = v.ratio
            else
                if min > v.ratio then
                    min = v.ratio
                end
            end
            if max == 0 then
                max = v.ratio
            else
                if max < v.ratio then
                    max = v.ratio
                end
            end
        end
    end
    return min / 1000, max / 1000
end

-- 传入守护data，获取当前有多少个装备可以升级，同时返回升级需要消耗多少银币
function ShouhuModel:get_shouhu_can_equip_up_num(my_sh_selected_data)
    local nextlev = math.floor(my_sh_selected_data.sh_lev / 10) * 10

    --限制装备等级110花费银币计算
    if nextlev > self.equipMaxLev then nextlev = self.equipMaxLev end

    local cost = 0
    local num = 0
    for i = 1, #my_sh_selected_data.equip_list do
        -- 装备
        local d = my_sh_selected_data.equip_list[i]
        if (my_sh_selected_data.sh_lev - d.lev) >= self.init_equip_lev then
            num = num + 1
            local cfgEqDat = self:get_equip_data_by_base_id(d.base_id)
            local nextCfgDat = DataShouhu.data_guard_equip_cfg_two[string.format("%s_%s_%s", nextlev, cfgEqDat.classes, cfgEqDat.type)]
            if not BaseUtils.isnull(nextCfgDat) then
                cost = cost + nextCfgDat.loss_coin
            end
        end
    end
    return num, cost
end

-- 获取守护的星阵对应技能
function ShouhuModel:get_wakeup_skills(base_id)
    local skillList = self.wakeUpSkillDic[base_id]
    if skillList == nil then
        skillList = DataShouhu.data_guard_wakeup_upgrade[string.format("%s_%s", base_id, 4)].qualitySkills
        self.wakeUpSkillDic[base_id] = skillList
    end
    table.sort(skillList, function(a, b)
        return a[2] < b[2]
    end )
    return skillList
end

-- 传入守护装备类型和等级获取可产出的装备特效
function ShouhuModel:get_can_out_equip_effects(_type, lev)
    for i = 1, #DataShouhu.data_guard_equip_effect do
        local data = DataShouhu.data_guard_equip_effect[i]
        if data.type == _type and data.lev == lev and #data.effect ~= 0 then
            return data.effect
        end
    end
    return { }
end

-- 传入守护装备类型和等级和装备特效类型获取可产出的特效技能id
function ShouhuModel:get_can_out_equip_effects_skill(_type, lev, effect_type)
    local list = self:get_can_out_equip_effects(_type, lev)
    if #list > 0 then
        for i = 1, #list do
            local data = list[i]
            if data.effect_type == effect_type then
                return data.val
            end
        end
    end
    return 0
end

-- 传入操作类型和条件组成描述信息，用于守护觉醒
function ShouhuModel:PackWakeUpCondition(conLabel, op, val)
    local conStr = ""
    local okBool = false
    local tempColor = ""
    if conLabel == "lev" then
        -- 等级
        local bool, opStr = self:CheckWakeUpCondition(op, RoleManager.Instance.RoleData.lev, val)
        local tempColor = ""
        if bool then
            tempColor = ColorHelper.color[1]
        else
            tempColor = ColorHelper.color[6]
        end
        okBool = bool
        conStr = string.format(TI18N("达到<color='#ffff00'>%s</color>级(<color='%s'>%s</color>/%s)"), val, tempColor, RoleManager.Instance.RoleData.lev, val)
    elseif conLabel == "classes" then
        -- 职业
        local bool, opStr = self:CheckWakeUpCondition(op, RoleManager.Instance.RoleData.classes, val)
        okBool = bool
        conStr = string.format("%s%s%s", TI18N("人物职业"), opStr, KvData.classes_name[val])
    elseif conLabel == "guard_num" then
        -- 守护数量
        local shouhuNum = #self.my_sh_list
        local bool, opStr = self:CheckWakeUpCondition(op, shouhuNum, val)
        if bool then
            tempColor = ColorHelper.color[1]
        else
            tempColor = ColorHelper.color[6]
        end
        okBool = bool
        conStr = string.format("%s%s (<color='%s'>%s</color>/%s)", TI18N("守护数量"), val, tempColor, shouhuNum, val)
    elseif conLabel == "guard_id" then
        -- 已招募哪个守护id
        local bool = false
        local shName = string.format("<color='#ffff00'>%s</color>", DataShouhu.data_guard_base_cfg[val].alias)
        local num = 0
        for k, v in pairs(self.my_sh_list) do
            if v.base_id == val then
                bool = true
                break
            end
        end
        if bool then
            num = 1
            tempColor = ColorHelper.color[1]
        else
            tempColor = ColorHelper.color[6]
        end
        okBool = bool
        -- 招募守护 福波斯 （0/1）
        conStr = string.format("%s%s(<color='%s'>%s</color>/%s)", TI18N("招募"), shName, tempColor, num, 1)
    elseif conLabel == "guard_quality" then
        okBool = true

        -- local myShouhuNum = 0 -- 当前守护招募数量
        for k, v in pairs(self.my_sh_list) do
            if v.quality < val then
                okBool = false
            end
            -- myShouhuNum = myShouhuNum + 1
        end

        -- local canRecruitShouhuNum = 0 -- 可守护招募数量
        -- local lev = RoleManager.Instance.RoleData.lev
        -- for k, v in pairs(DataShouhu.data_guard_base_cfg) do 
        --     if lev >= v.recruit_lev then
        --         canRecruitShouhuNum = canRecruitShouhuNum + 1
        --     end
        -- end

        -- if canRecruitShouhuNum > myShouhuNum then -- 没有把可招募守护全部招募，也算是不满足条件
        --     okBool = false
        -- end

        if okBool then
            tempColor = ColorHelper.color[1]
        else
            tempColor = ColorHelper.color[6]
        end
        conStr = string.format(TI18N("进阶所有守护至<color='#ffff00'>%s</color>阶"), self.wakeUpQualityName[val])
    end
    return okBool, conStr
end

-- 传入操作类型，和比较值，返回操作关系
function ShouhuModel:CheckWakeUpCondition(op, leftNum, rightNum)
    if op == "ue" then
        -- 不等于
        return leftNum ~= rightNum, TI18N("不等于")
    elseif op == "eq" then
        -- 等于
        return leftNum == rightNum, TI18N("等于")
    elseif op == "lt" then
        -- 小于
        return leftNum < rightNum, TI18N("小于")
    elseif op == "gt" then
        -- 大于
        return leftNum > rightNum, TI18N("大于")
    elseif op == "le" then
        -- 小于等于
        return leftNum <= rightNum, TI18N("不大于")
    elseif op == "ge" then
        -- 大于等于
        return leftNum >= rightNum, TI18N("不小于")
    end
end


-- 检查守护觉醒星阵是否开启
function ShouhuModel:CheckWakeUpIsOpen()
    if RoleManager.Instance.RoleData.lev >= self.wakeUpOpenLev then
        return true
    else
        return false
    end
end

-- 获取已招募守护的数量
function ShouhuModel:GetAllShouhuNum()
    return #self.my_sh_list
end

-- 获取已招募守护的总评分
function ShouhuModel:GetAllShouhuScore()
    local score = 0
    for k, v in pairs(self.my_sh_list) do
        score = score + v.score
    end
    return score
end

-- 获取已招募守护的觉醒属性加成列表
function ShouhuModel:GetShouhuExtraList()
    local list = { }
    for k, v in pairs(self.my_sh_list) do
        local tempCfgData = DataShouhu.data_guard_wakeup_upgrade[string.format("%s_%s", v.base_id, v.quality)]
        if tempCfgData ~= nil then
            for i = 1, #tempCfgData.role_attrs do
                local tempAttr = tempCfgData.role_attrs[i]
                if tempAttr.classes == RoleManager.Instance.RoleData.classes or tempAttr.classes == 0 then
                    if list[tempAttr.attr] == nil then
                        list[tempAttr.attr] = 0
                    end
                    list[tempAttr.attr] = list[tempAttr.attr] + tempAttr.val
                end
            end
        end
    end

    if list[4] == nil then
        list[4] = 0
    end
    if list[6] == nil then
        list[6] = 0
    end
    if list[5] == nil then
        list[5] = 0
    end
    if list[7] == nil then
        list[7] = 0
    end
    if list[43] == nil then
        list[43] = 0
    end
    if list[3] == nil then
        list[3] = 0
    end
    if list[1] == nil then
        list[1] = 0
    end

    return list
end

-- 检查当前已招募守护，是否有守护的觉醒星阵能够激活或者进阶
function ShouhuModel:CheckHasShouhuCanWakeup()
    for i = 1, #self.my_sh_list do
        local shData = self.my_sh_list[i]
        if self:CheckShouhuCanWakeup(shData) then
            return true
        end
    end
    return false
end

-- 传入守护数据，检查下该守护是否有觉醒星阵能够激活或者进阶
function ShouhuModel:CheckShouhuCanWakeup(data)
    -- if data.base_id == 1012 then
    --     print('------11')
    --     print(self:CheckShouhuCanCharge(data))
    --     print(self:CheckShouhuCanWakeupUpgrade(data))
    --     print(self:CheckShouhuCanWakeupActive(data))

    --     local socketData = self.wakeUpDataSocketDic[data.base_id]

    --     BaseUtils.dump(data)
    --     BaseUtils.dump(socketData)
    -- endd


    if self:CheckShouhuCanWakeupActive(data) then
        return true
    elseif self:CheckShouhuCanWakeupUpgrade(data) then
        return true
    elseif self:CheckShouhuCanCharge(data) then
        return true
        -- 不能激活不能进阶就检查下能否充能
    end
    return false
end

-- 传入守护数据，检查下该守护是否有阵位可以充能
function ShouhuModel:CheckShouhuCanCharge(data)
    local state = false
    if self:CheckShouhuCanWakeupActive(data) == false and self:CheckShouhuCanWakeupUpgrade(data) == false then
        local socketData = self.wakeUpDataSocketDic[data.base_id]

        -- 检查是否已经激活
        if socketData ~= nil and socketData.active < data.quality then
            -- 还没激活
            state = false
        else
            if socketData ~= nil then
                if data.quality < self.wakeUpMaxQuality then
                    local num = self:GetWakeUpNeedPointNum(data)
                    for i = 1, num do
                        if socketData.aroused[i] ~= nil then
                            if socketData.aroused[i].lev < data.quality then
                                -- 未激活，可冲
                                if self:CheckWakeUpChargeEnough(data, i) then
                                    state = true
                                    break
                                end
                            end
                        else
                            -- 有位可冲
                            if self:CheckWakeUpChargeEnough(data, i) then
                                state = true
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    return state
end

-- 传入守护数据，检查下该守护是否有觉醒星阵能够激活
function ShouhuModel:CheckShouhuCanWakeupActive(data)
    local state = false
    local socketData = self.wakeUpDataSocketDic[data.base_id]
    if socketData ~= nil and socketData.active < data.quality then
        state = true
        -- 需要激活
    end
    if state then
        if data.quality == self.wakeUpMaxQuality then
            -- 已满级
            state = false
        else
            local activeData = DataShouhu.data_guard_wakeup_active[string.format("%s_%s", data.base_id, data.quality)]
            -- 检查激活道具够不够
            local costData = activeData.cost[1]
            local hasNum = BackpackManager.Instance:GetItemCount(costData[1])
            local costNum = costData[2]
            if costNum > hasNum then
                state = false
            end

            -- 检查激活条件是否足够
            for i = 1, #activeData.condition do
                local tempData = activeData.condition[i]
                local okBool, conStr = self:PackWakeUpCondition(tempData.label, tempData.op, tempData.val[1])
                if okBool == false then
                    state = false
                    break
                end
            end
        end
    end
    return state
end

-- 传入守护数据，检查下该守护是否有觉醒星阵能够进阶
function ShouhuModel:CheckShouhuCanWakeupUpgrade(data)
    local state = true
    local socketData = self.wakeUpDataSocketDic[data.base_id]
    if socketData ~= nil then
        for i = 1, #socketData.aroused do
            if socketData.aroused[i].lev < data.quality then
                state = false
                break
            end
        end
        if data.quality == self.wakeUpMaxQuality then
            state = false
        else
            local upgardeData = DataShouhu.data_guard_wakeup_upgrade[string.format("%s_%s", data.base_id, data.quality + 1)]
            local upgradeNeedNum = 0
            if upgardeData ~= nil then
                upgradeNeedNum = upgardeData.need_num
            else
                -- 已到顶
                upgradeNeedNum = self.wakeUpMaxPoint
            end
            if socketData.aroused[upgradeNeedNum] == nil or socketData.aroused[upgradeNeedNum].lev < data.quality then
                state = false
            end
            if state then
                -- 检查进阶道具够不够
                local costData = upgardeData.cost[1]
                local hasNum = BackpackManager.Instance:GetItemCount(costData[1])
                local costNum = costData[2]
                if costNum > hasNum then
                    state = false
                end
            end
        end
    end
    return state
end

-- 传入守护觉醒星阵数据，检查下该星阵有多少充能个阵位后才可以进阶
function ShouhuModel:GetWakeUpNeedPointNum(data)
    local upgradeNeedCfgData = DataShouhu.data_guard_wakeup_upgrade[string.format("%s_%s", data.base_id, data.quality + 1)]
    local upgradeNeedNum = 0
    if upgradeNeedCfgData ~= nil then
        upgradeNeedNum = upgradeNeedCfgData.need_num
    else
        -- 已到顶
        upgradeNeedNum = self.wakeUpMaxPoint
    end
    return upgradeNeedNum
end

-- 传入守护数据和要充能你的位置，检查充能道具是否足够
function ShouhuModel:CheckWakeUpChargeEnough(data, index)
    local nextWakeUpCfgData = DataShouhu.data_guard_wakeup[string.format("%s_%s_%s", data.base_id, index, data.quality)]
    if nextWakeUpCfgData ~= nil then
        local base_id = nextWakeUpCfgData.cost[1][1]
        local hasNum = BackpackManager.Instance:GetItemCount(base_id)
        local needNum = nextWakeUpCfgData.cost[1][2]
        if hasNum >= needNum then
            return true
        end
    end
    return false
end

-- 保留三位小数
function ShouhuModel:KeepPointNum(num)
    local temp = num * 1000
    local h = math.floor(temp / 1000)
    local t = math.floor((temp - h * 1000) / 100)
    local tt = math.floor((temp - h * 1000 - t * 100) / 10)
    local ge = math.floor(temp - h * 1000 - t * 100 - tt * 10)

    return string.format("%s.%s%s%s", h, t, tt, ge)
end

-- 获取守护觉醒属性
function ShouhuModel:GetGuardWakeupUpgrade(baseId, quality)
    local key = BaseUtils.Key(baseId, quality)
    local attrData = self.GuardWakeupUpgradeAttr[key]
    if attrData == nil then
        local wakeupData1 = DataShouhu.data_guard_wakeup_upgrade[string.format("%s_%s", baseId, quality)]
        local wakeupData2 = DataShouhu.data_guard_wakeup_upgrade[string.format("%s_%s", baseId, quality + 1)]

        local role_attrs = { }
        if wakeupData1 == nil then
            role_attrs = wakeupData2.role_attrs
        else
            -- 多次双循环，效率好低，因此增加table缓存
            -- 先取出相同职业类型的增加值
            for key2, value2 in pairs(wakeupData2.role_attrs) do
                for key1, value1 in pairs(wakeupData1.role_attrs) do
                    if value1.classes == value2.classes and value1.attr == value2.attr then
                        if value1.val ~= value2.val then
                            local addValue = value2.val - value1.val
                            value2.val = addValue
                            table.insert(role_attrs, value2)
                        end
                    end
                end
            end
             -- 再取出增加的属性值
            for key2, value2 in pairs(wakeupData2.role_attrs) do
                local newAttrMark = true
                for key1, value1 in pairs(wakeupData1.role_attrs) do
                    if value2.attr == value1.attr and value2.classes == value1.classes then
                        newAttrMark = false
                        break
                    end
                end
                if newAttrMark then
                    table.insert(role_attrs, value2)
                end
            end
        end
        for k, v in pairs(role_attrs) do
            if v.classes == RoleManager.Instance.RoleData.classes or v.classes == 0 then
                attrData = v
                break
            end
        end
        self.GuardWakeupUpgradeAttr[key] = attrData
    end
    return attrData
end


function ShouhuModel:GuideGuardWakeup()
    if RoleManager.Instance.RoleData.lev >= 55 then
        local maxActive = nil
        for key, value in pairs(self.wakeUpDataSocketDic) do
            if value.active ~= nil and (maxActive == nil or maxActive < value.active) then
                maxActive = value.active
            end
        end
        if maxActive == 0 and BackpackManager.Instance:GetItemCount(22410) > 0 and BackpackManager.Instance:GetItemCount(22400) > 0 and self:get_my_shouhu_data_by_id(1020) ~= nil then
            -- if MainUIManager.Instance.MainUIIconView ~= nil then
            --     self.button = MainUIManager.Instance.MainUIIconView:getbuttonbyid(11)
            --     GuideManager.Instance.effect:Show(self.button, Vector2(0,40))
            -- end

            return true
        end
    end
    return false
end

--检查给定守护是否橙色品阶
function ShouhuModel:CheckIsPurpleShouhu(shdata)
    if shdata.quality >= 4 then
        return true
    end
end

--检查给定守护是否宝石全部大于1级
function ShouhuModel:CheckAllGemsBiggerOne(shdata)
    local temp = false
    if self.my_sh_GemsLevelList[shdata.base_id] ~= nil then
        if self.my_sh_GemsLevelList[shdata.base_id].Lev ~= nil and self.my_sh_GemsLevelList[shdata.base_id].Lev >= 1 then
            temp = true
        end
    end
    return temp
end

--检查给定守护最低宝石等级
function ShouhuModel:GetLowerGemsLevel(shdata)
    return self.my_sh_GemsLevelList[shdata.base_id].Lev or 0
end


function ShouhuModel:GetTotalGemsLevel(shdata)
    if shdata ~= nil and shdata.base_id ~= nil and self.my_sh_GemsLevelList[shdata.base_id] ~= nil then
        return self.my_sh_GemsLevelList[shdata.base_id].totalLev
    end
    return 0
end
