ShouhuManager = ShouhuManager or BaseClass(BaseManager)

function ShouhuManager:__init()
    if ShouhuManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    ShouhuManager.Instance = self;
    self:InitHandler()
    self.equip_pos = {[15]=1, [16]=2, [17]=3, [19]=4, [20] = 5, [18] = 6}
    self.model = ShouhuModel.New()
    self.autoUseData = {}

    -- 是否做阿瑞斯引导
    self.needGuide = false

    --self.OnTransferSuccess = EventLib.New()
    --self.OnGemsLevelUpdate = EventLib.New()
    self.OnGemsLevelUpdate = EventLib.New()
    self.OnAddPriceEvent = EventLib.New()

    self.maxRoleLev = 110
    self.maxEquipLev = self.model.equipMaxLev
end

function ShouhuManager:__delete()
    self.model:DeleteMe()
    self.model = nil
end

function ShouhuManager:InitHandler()
    self:AddNetHandler(10900, self.on10900)
    self:AddNetHandler(10901, self.on10901)
    self:AddNetHandler(10902, self.on10902)
    self:AddNetHandler(10903, self.on10903)
    self:AddNetHandler(10905, self.on10905)
    self:AddNetHandler(10906, self.on10906)
    self:AddNetHandler(10907, self.on10907)
    self:AddNetHandler(10909, self.on10909)

    self:AddNetHandler(10910, self.on10910)
    self:AddNetHandler(10911, self.on10911)
    self:AddNetHandler(10912, self.on10912)

    self:AddNetHandler(10913, self.on10913)
    self:AddNetHandler(10914, self.on10914)
    self:AddNetHandler(10915, self.on10915)
    self:AddNetHandler(10916, self.on10916)
    self:AddNetHandler(10917, self.on10917)
    self:AddNetHandler(10918, self.on10918)
    self:AddNetHandler(10919, self.on10919)
    self:AddNetHandler(10920, self.on10920)
    self:AddNetHandler(10921, self.on10921)
    self:AddNetHandler(10922, self.on10922)

    self.on_guard_pos_change = function(data)
        self:on_guardposition(data)
    end
    EventMgr.Instance:AddListener(event_name.guard_position_change, self.on_guard_pos_change)

    self.on_role_change = function(data)
        self:on_role_levup()
    end
    EventMgr.Instance:AddListener(event_name.role_level_change, self.on_role_change)

    self.on_mainui_loaded = function(data)
        self:on_show_red_point()
    end
    EventMgr.Instance:AddListener(event_name.mainui_btn_init, self.on_mainui_loaded)

    self.on_backpack_change = function(data)
        self:on_show_red_point()
    end
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.on_backpack_change)

    if MainUIManager.Instance.MainUIIconView ~= nil then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(11, true)
    end
end

--检查下是否有已上阵的守护的装备可以升级,可以则主ui则显示红点
function ShouhuManager:on_show_red_point()
    local state = self.model:check_has_shouhu_war_equip_canup()
    if state == false then
        state = self.model:check_has_shouhu_up_stone()
    end
    if state == false then
        --检查下有没有守护可以招募
        for k,v in pairs(DataShouhu.data_guard_base_cfg) do
            if self.model:check_can_recruit(v) then
                state = true
                break
            end
        end
    end
    if state == false then
        --检查下觉醒星阵是否开启，检查下是否有道具满足激活或者进阶
        if self.model:CheckWakeUpIsOpen() then
            state = self.model:CheckHasShouhuCanWakeup()
        end
    end

    if state == false and RoleManager.Instance.RoleData.lev >= 55 then
        local maxActive = 0
        for key, value in pairs(self.model.wakeUpDataSocketDic) do
            if value.active ~= nil and maxActive < value.active then
                maxActive = value.active
            end
        end
        if maxActive == 0 then
            state = true
        end
    end
    if MainUIManager.Instance.MainUIIconView ~= nil then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(11, state)
    end

    self.model:GuideGuardWakeup()
end

--主ui加载完成
function ShouhuManager:on_mainui_load_finish()
    if self.has_done == nil then
        self.has_done = true
        self:on_role_levup()
    end
end

--人物等级升级检查下前四只守护能不能招募
function ShouhuManager:on_role_levup()
    --从配置里面取出数据
    local result_list = {}
    for k,v in pairs(DataShouhu.data_guard_base_cfg) do
        if v.classify == 1 and v.display_lev <= RoleManager.Instance.RoleData.lev then
            local data = BaseUtils.copytab(v)
            table.insert(result_list, data)
        end
    end
    local recruit_lev_sort = function(a, b)
        return a.recruit_lev < b.recruit_lev
    end
    table.sort(result_list, recruit_lev_sort)

    for i=1,#result_list do
        local d = result_list[i]
        if i > 4 then
            return
        end

        if d.recruit_lev <= RoleManager.Instance.RoleData.lev and self.model:check_has_sh_by_id(d.base_id) == false then
            if d.base_id == 1018 then
                -- 改成引导不用快速使用
                GuideManager.Instance:Start(10007)
                return
            else
                local recruit_callback = function()
                    self:request10900(d.base_id)
                end
                if self.autoUseData[d.base_id] == nil or self.autoUseData[d.base_id].inChain ~= true then
                    self.autoUseData[d.base_id] = AutoUseData.New()
                    self.autoUseData[d.base_id].type = AutoUseEumn.types.shouhu
                    self.autoUseData[d.base_id].shData = d
                    self.autoUseData[d.base_id].callback = recruit_callback
                    NoticeManager.Instance:AutoUse(self.autoUseData[d.base_id])
                end
            end
        end
    end
end

--守护阵位状态改变
function ShouhuManager:on_guardposition(data)
    if data == nil then
        return
    end
    local list = data[1]
    local temp_list = {}
    for i=1,#list do
        temp_list[list[i].guard_id] = list[i]
    end
    for i=1,#self.model.my_sh_list do
        local td = self.model.my_sh_list[i]
        if temp_list[td.base_id] ~= nil then
            td.guard_fight_state=temp_list[td.base_id].status
            td.war_id = temp_list[td.base_id].number --0就表示没有上阵
        end
    end

    self.model:update_main_win_left_list()
end

--------协议接收
function ShouhuManager:on10900(data)
    -- print("-------------------10900")
    if #data.recruit_guard == 0 then
        NoticeManager.Instance:FloatTipsByString(data.msg)
        return
    end
    self.model.has_rec_succs_bid = data.recruit_guard[1].base_id
    if data.flag == 1 then --成功
        self.model.wakeUpDataSocketDic[data.recruit_guard[1].base_id] = data.recruit_guard[1]
        local dat = self:update_shouhu_data_socket(data.recruit_guard[1])
        table.insert(self.model.my_sh_list, dat)
        self.model:OpenShouhuSuccessUI()
        if dat.base_id == 1020 and dat.war_id == 0 and RoleManager.Instance.RoleData.lev <= 45 then
            -- 阿瑞斯引导
            self.needGuide = true
        end
        EventMgr.Instance:Fire(event_name.guard_recruit_success)
        SoundManager.Instance:Play(230)
    else --失败

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)

    self.model:update_red_point()
    self.on_mainui_loaded()
end

--请求所有守护数据返回
function ShouhuManager:on10901(data)
    --print("on10901")
    --BaseUtils.dump(data, "on10901")
    self.model.cur_sh_lev = RoleManager.Instance.RoleData.lev
    -- 已获得的守护列表
    self.model.my_sh_list = {}
    for i=1,#data.guards do
        local item = data.guards[i]
        local dat = self:update_shouhu_data_socket(item)
        self.model.wakeUpDataSocketDic[item.base_id] = item
        table.insert(self.model.my_sh_list, dat)
    end

    -----------------对守护列表进行排序
    local taticList = {}
    local qualityList = {}
    while #self.model.my_sh_list >0 do
        local d = self.model.my_sh_list[1]
        if d.tactic_index~=0 then
            table.insert(taticList, d)
        else
            table.insert(qualityList, d)
        end
        table.remove(self.model.my_sh_list,1)
    end

    local quality_sort = function(a, b)
        return a.quality > b.quality --根据index从小到大排序
    end
    table.sort(taticList, quality_sort)
    table.sort(qualityList, quality_sort)

    for i=1,#taticList do
        local d = taticList[i]
        table.insert(self.model.my_sh_list, d)
    end

    for i=1,#qualityList do
        local d = qualityList[i]
        table.insert(self.model.my_sh_list, d)
    end

    local war_sort = function(a, b)
        if a.war_id ~= b.war_id then
            return a.war_id > b.war_id --根据index从大到小排序
        else
            return a.guard_fight_state > b.guard_fight_state --根据index从大到小排序
        end
    end
    table.sort(self.model.my_sh_list, war_sort)

    --更新守护列表
    self.model:update_help_fight_red_point()
    self.model:update_red_point()
    self.on_mainui_loaded()

    --更新界面
    self.model:update_star_view()
    self:on_mainui_load_finish()
    self:on_show_red_point()
end

--升级或重置守护装备
function ShouhuManager:on10902(data)
    self.model:Release_equip_up_reset()
    for i=1, #self.model.my_sh_list do
        local temp = self.model.my_sh_list[i]
        if temp.base_id == data.id then
            for j=1, #temp.equip_list do
                local temp2 = temp.equip_list[j]
                if temp2.base_id == data.base_id then
                    temp2.reset_base_attrs = {}
                    temp2.reset_ext_attrs = {}
                    temp2.timeout = data.timeout
                    temp2.back_effect_timeout = data.back_effect_timeout
                    temp2.back_effect_attr = data.back_effect_attr
                    for k=1, #data.eqm_attrs do
                        local item3 = data.eqm_attrs[k]
                        if item3.type == GlobalEumn.ItemAttrType.base then
                            table.insert(temp2.reset_base_attrs, item3)
                        elseif item3.type == GlobalEumn.ItemAttrType.extra then
                            table.insert(temp2.reset_ext_attrs, item3)
                        end
                    end

                    temp2.reset_base_id = data.reset_base_id
                    temp2.reset_base_attrs_next = {}
                    temp2.reset_ext_attrs_next = {}
                    temp2.reset_eff_attrs_next = {}
                    for k=1, #data.reset_attrs do
                        local item3 = data.reset_attrs[k]
                        if item3.type == GlobalEumn.ItemAttrType.base then
                            table.insert(temp2.reset_base_attrs_next, item3)
                        elseif item3.type == GlobalEumn.ItemAttrType.extra then
                            table.insert(temp2.reset_ext_attrs_next, item3)
                        elseif item3.type == GlobalEumn.ItemAttrType.effect then
                            table.insert(temp2.reset_eff_attrs_next, item3)
                        end
                    end
                end
            end

        end
    end

    if #data.reset_attrs > 0 then
        --是重置
        local cfgEqDat = self.model:get_equip_data_by_base_id(data.base_id)
        self:request10907(data.id, cfgEqDat.type)
    end

    --更新装备界面
    self.model:update_equip_view()
    self.model:update_main_win_equip()
    self.model:update_main_win_left_list()
    self.model:update_red_point()
    self.on_mainui_loaded()

    EventMgr.Instance:Fire(event_name.guard_recruit_success)
end

--更新守护属性
function ShouhuManager:on10903(data)
    print("=====================收到10903")
    -- BaseUtils.dump(data)
    local update = false
    self.model.wakeUpDataSocketDic[data.base_id] = data
    for i=1, #self.model.my_sh_list do
        local temp = self.model.my_sh_list[i]
        if temp.base_id == data.base_id then
            self.model.my_sh_list[i] = self:update_shouhu_data_socket(data)
            update = true
            break
        end
    end

    if update == false then
        table.insert(self.model.my_sh_list, self:update_shouhu_data_socket(data))
    end

    --更新守护列表sdf
    local passList = {[2] = true}
    self.model:update_red_point(passList)

    --更新装备界面
    self.model:update_equip_view()
    self.model:update_main_win_equip()

end

function ShouhuManager:update_shouhu_data_socket(socket_dat)
    local temp_dat = self.model:get_sh_base_dat_by_id(socket_dat.base_id)
    local dat = BaseUtils.copytab(temp_dat) --从配置data里面复制一个出来就有配置里面的数据了
    dat.sh_lev = self.model.cur_sh_lev
    dat.quality = socket_dat.quality
    dat.growth = socket_dat.growth
    dat.is_init = socket_dat.is_init

    local temp_skills = self.model:get_skill_data_dic_by_base_id(socket_dat.base_id)
    dat.has_get_skill_list = {}
    for i=1,#temp_skills do
        local sd = temp_skills[i]
        if sd[2] <= dat.sh_lev then
            table.insert(dat.has_get_skill_list, sd[1])
        end
    end

    dat.guard_fight_state=socket_dat.status
    dat.war_id = socket_dat.war_id --0就表示没有上阵

    dat.tactic_index = 1
    dat.tactic_pos=socket_dat.tac_pos
    dat.score = socket_dat.score

    dat.sh_attrs_list = {}
    dat.sh_attrs_list.hp_max = socket_dat.hp_max
    dat.sh_attrs_list.mp_max = socket_dat.mp_max
    dat.sh_attrs_list.atk_speed = socket_dat.atk_speed
    dat.sh_attrs_list.phy_dmg = socket_dat.phy_dmg
    dat.sh_attrs_list.magic_dmg = socket_dat.magic_dmg
    dat.sh_attrs_list.phy_def = socket_dat.phy_def
    dat.sh_attrs_list.magic_def = socket_dat.magic_def
    dat.sh_attrs_list.heal_val = socket_dat.heal_val
    dat.equip_list = {}

    for i=1,#socket_dat.eqm do --守护装备数据
        local item2 = socket_dat.eqm[i]
        local cfgEqDat = self.model:get_equip_data_by_base_id(item2.base_id)
        local eqDat = BaseUtils.copytab(cfgEqDat)
        eqDat.is_init = item2.is_init
        eqDat.timeout = item2.timeout
        eqDat.back_effect_timeout = item2.back_effect_timeout
        eqDat.back_effect_attr = item2.back_effect_attr

        eqDat.lev = cfgEqDat.lev
        eqDat.base_id = cfgEqDat.base_id
        eqDat.loss_coin = cfgEqDat.loss_coin
        eqDat.reset_coin = cfgEqDat.reset_coin

        eqDat.base_attrs = {}
        eqDat.ext_attrs = {}
        eqDat.eff_attrs = {}

        for i=1, #item2.eqm_attrs do
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
        eqDat.reset_base_attrs_next = {}
        eqDat.reset_ext_attrs_next = {}
        eqDat.reset_eff_attrs_next = {}

        if item2.reset_attrs ~= nil then
            for k=1, #item2.reset_attrs do
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
            eqDat.gem = {}
        end

        dat.equip_list[self.equip_pos[eqDat.type]] = eqDat
    end

    return dat
end

--守护上阵结果返回
function ShouhuManager:on10905(data)
    if data.op_code == 0 then
        --失败
    elseif data.op_code == 1 then
        --先还原掉所有的守护助战状态
        for i=1,#self.model.my_sh_list do
            local my_dat = self.model.my_sh_list[i]
            my_dat.tactic_pos = 0
            if my_dat.guard_fight_state == self.model.guard_fight_state.field then
                my_dat.guard_fight_state = self.model.guard_fight_state.idle
            end
        end
        --成功
        for i=1,#data.change_fields do
            local my_dat = self.model:get_my_shouhu_data_by_id(data.change_fields[i].base_id)
            if my_dat ~= nil then
                my_dat.tactic_pos = data.change_fields[i].pos
                my_dat.guard_fight_state = self.model.guard_fight_state.field
            end
        end
        --更新阵位
        self.model:update_star_view()
        self.model:update_main_win_left_list()
        self.model:update_help_fight_red_point()
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--请求助战属性
function ShouhuManager:on10906(data)

end

--保存守护装备重置属性
function ShouhuManager:on10907(data)
    if data.op_code == 0 then
        --失败
    elseif data.op_code == 1 then
        --成功
        self.model:update_main_win_left_list()
    end

    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--守护离阵
function ShouhuManager:on10909(data)
    if data.op_code == 0 then
        --失败
    elseif data.op_code == 1 then
        --成功
        local my_dat = self.model:get_my_shouhu_data_by_id(data.base_id)
        if my_dat ~= nil then
            my_dat.tactic_pos = 0
            my_dat.guard_fight_state = self.model.guard_fight_state.idle
        end

        --更新阵位
        self.model:update_star_view()
        self.model:update_main_win_left_list()
        self.model:update_help_fight_red_point()
    end

    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--镶嵌宝石
function ShouhuManager:on10910(data)
    if data.op_code == 0 then
        --失败
    elseif data.op_code == 1 then
        --成功
        self.model:update_red_point()
        self.on_mainui_loaded()
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--升级宝石
function ShouhuManager:on10911(data)
    self.model:Release_equip_stone_up()
    if data.op_code == 0 then
        --失败
    elseif data.op_code == 1 then
        --成功
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--摘除宝石
function ShouhuManager:on10912(data)
    if data.op_code == 0 then
        --失败
    elseif data.op_code == 1 then
        --成功
        self.model:update_red_point()
        self.on_mainui_loaded()
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--激活星阵
function ShouhuManager:on10913(data)
    -- print('-------------=-------收到10913')
    -- BaseUtils.dump(data)
    if data.op_code == 1 then
        --成功
        SoundManager.Instance:Play(264)
    else

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--星阵充能
function ShouhuManager:on10914(data)
    -- print('-------------=-------收到10914')
    if data.op_code ~= 0 then
        --成功
        EventMgr.Instance:Fire(event_name.shouhu_wakeup_point_light, data)
    else

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--星阵进阶
function ShouhuManager:on10915(data)
    -- print('-------------=-------收到10915')
    if data.op_code == 1 then--成功
        --检查是否有新外观

    else

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--获取星阵数据
function ShouhuManager:on10916(data)
    -- print('-------------=-------收到10916')
    self.model.wakeUpDataSocketDic[data.base_id] = data
    EventMgr.Instance:Fire(event_name.shouhu_wakeup_update, data)
    self:on_show_red_point()
end

--收到
function ShouhuManager:on10917(data)
    -- print('-------------=-------收到10917')
    -- BaseUtils.dump(data)
    self.model:UpdateWakeupAttrTips(data)
end

--刻印
function ShouhuManager:on10918(data)
    print('-------------=-------收到10918')
    -- BaseUtils.dump(data)
    if data.flag == 1 then
        --成功
        local hasEffect = false
        for  i = 1, #data.eqm_attrs do
            local temp = data.eqm_attrs[i]
            if temp.type == GlobalEumn.ItemAttrType.effect then
                hasEffect = true
                break
            end
        end
        if not hasEffect then
            local cfgEqDat = self.model:get_equip_data_by_base_id(data.base_id)
            self:request10919(data.id, cfgEqDat.type)
        else
            for i = 1, #self.model.my_sh_list do
                local shData = self.model.my_sh_list[i]
                if shData.base_id == data.id then
                    local cfgEqDat = self.model:get_equip_data_by_base_id(data.base_id)
                    local eqDat = shData.equip_list[self.equip_pos[cfgEqDat.type]]
                    eqDat.timeout = data.timeout
                    eqDat.back_effect_timeout = data.back_effect_timeout
                    eqDat.back_effect_attr = data.back_effect_attr
                    eqDat.base_attrs = {}
                    eqDat.ext_attrs = {}
                    eqDat.eff_attrs = {}
                    for j=1, #data.eqm_attrs do
                        local item3 = data.eqm_attrs[j]
                        if item3.type == GlobalEumn.ItemAttrType.base then
                            table.insert(eqDat.base_attrs, item3)
                        elseif item3.type == GlobalEumn.ItemAttrType.extra then
                            table.insert(eqDat.ext_attrs, item3)
                        elseif item3.type == GlobalEumn.ItemAttrType.effect then
                            table.insert(eqDat.eff_attrs, item3)
                        end
                    end
                end
            end
        end
        self.model:update_equip_view()
    else

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--刻印
function ShouhuManager:on10919(data)
    print("======================收到10919")
    -- BaseUtils.dump(data)
    if data.flag == 1 then
        --成功
    else

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-----------------各种请求逻辑
--请求招募守护
function ShouhuManager:request10900(_base_id)
    if self.autoUseData[_base_id] ~= nil then
        self.autoUseData[_base_id]:DeleteMe()
        self.autoUseData[_base_id] = nil
    end
    Connection.Instance:send(10900, {base_id=_base_id})
end

function ShouhuManager:request10901()
    Connection.Instance:send(10901, {})
end

--请求守护装备升级，重置守护装备
function ShouhuManager:request10902(_base_id, _type)
    self.model:Frozen_equip_up_reset()
    Connection.Instance:send(10902, {id=_base_id, type=_type})
end

--更新守护属性
function ShouhuManager:request10903()
    Connection.Instance:send(10903, {})
end

--请求守护上阵
function ShouhuManager:request10905(_pos, _base_id)
    -- sound_player:PlayOption(222)
    Connection.Instance:send(10905, {pos=_pos, base_id=_base_id})
end

--请求守护出战
function ShouhuManager:request10906(_type, _base_id)
    Connection.Instance:send(10906, {type=_type, base_id=_base_id})
end

--请求保存装备属性
function ShouhuManager:request10907(_base_id, _type)
    Connection.Instance:send(10907, {type=_type, base_id=_base_id})
end

--请求守护离阵
function ShouhuManager:request10909(_base_id)
    Connection.Instance:send(10909, {base_id=_base_id})
end

--镶嵌宝石
function ShouhuManager:request10910(_base_id, _type, _hole_id, _gem_base_id)
    Connection.Instance:send(10910, {base_id = _base_id, type = _type, hole_id = _hole_id, gem_base_id = _gem_base_id})
end

--升级宝石
function ShouhuManager:request10911(_base_id, _type, _hole_id)
    self.model:Frozen_equip_stone_up()
    Connection.Instance:send(10911, {base_id = _base_id, type = _type, hole_id = _hole_id})
end

--摘除宝石
function ShouhuManager:request10912(_base_id, _type, _hole_id)
    Connection.Instance:send(10912, {base_id = _base_id, type = _type, hole_id = _hole_id})
end

--激活星阵
function ShouhuManager:request10913(_base_id)
    -- print("----------------发送10913")
    Connection.Instance:send(10913, {base_id = _base_id})
end

--星阵充能
function ShouhuManager:request10914(_base_id, _star_id)
    -- print("----------------发送10914")
    Connection.Instance:send(10914, {base_id = _base_id, star_id = _star_id})
end

--星阵进阶
function ShouhuManager:request10915(_base_id)
    -- print("----------------发送10915")
    Connection.Instance:send(10915, {base_id = _base_id})
end

--获取星阵数据
function ShouhuManager:request10916(_base_id)
    Connection.Instance:send(10916, {base_id = _base_id})
end

--获取指定分享数据
function ShouhuManager:request10917(role_id, platform, zone_id)
    Connection.Instance:send(10917, {role_id = role_id, platform = platform, zone_id = zone_id})
end

--刻印
function ShouhuManager:request10918(base_id, type)
    print('------------------------发送10918')
    Connection.Instance:send(10918, {base_id = base_id, type = type})
end

--保存刻印
function ShouhuManager:request10919(base_id, type)
    print('------------------------发送10919')
    Connection.Instance:send(10919, {base_id = base_id, type = type})
end

function ShouhuManager:Send10920(base_id1, base_id2)
    print('------------------------发送10920')
    Connection.Instance:send(10920, {base_id1 = base_id1, base_id2 = base_id2})
end

function ShouhuManager:on10920(data)
    print("======================收到10920")
    --BaseUtils.dump(data,"on10920:")
    if data.err_code == 1 then
        --成功
        NoticeManager.Instance:FloatTipsByString("转换成功{face_1,3}")
        if data.base_id1 ~= nil and data.base_id2 ~= nil then
            self.model.selectedTransferAnotherSH[data.base_id1] = nil
            self.model.selectedTransferAnotherSH[data.base_id2] = nil
            --self.OnTransferSuccess:Fire()
            --刷新界面
            LuaTimer.Add(1000,function() self.model:update_red_point() end)

        end
    end
    --NoticeManager.Instance:FloatTipsByString(data.msg)
end
--守护宝石等级相关
function ShouhuManager:Send10921()
    print('------------------------发送10921')
    Connection.Instance:send(10921, {})
end

function ShouhuManager:on10921(data)
    print("======================收到10921")
    --BaseUtils.dump(data,"on10921:")
    if data ~= nil then
        for i,v in pairs(data.minlev_gem_list) do
            self.model.my_sh_GemsLevelList[v.base_id] = {}
            self.model.my_sh_GemsLevelList[v.base_id].Lev = v.lev
            self.model.my_sh_GemsLevelList[v.base_id].totalLev = v.total_lev
        end
        self.OnGemsLevelUpdate:Fire()
    end
    --BaseUtils.dump(self.model.my_sh_GemsLevelList,"self.model.my_sh_GemsLevelList:")
end
--守护转换价格请求
function ShouhuManager:Send10922(base_id1, base_id2)
    print('------------------------发送10922')
    Connection.Instance:send(10922, {base_id1 = base_id1, base_id2 = base_id2})
end

function ShouhuManager:on10922(data)
    print("======================收到10922")
    --BaseUtils.dump(data,"on10922:")
    if data ~= nil then
        self.OnAddPriceEvent:Fire(data.val)
    end

end


-- 检查凯恩是否能招募
function ShouhuManager:Checkaien()
    local data = DataShouhu.data_guard_base_cfg[1018]
    if data.recruit_lev <= RoleManager.Instance.RoleData.lev and self.model:check_has_sh_by_id(1018) == false then
        return true
    end
    return false
end

function ShouhuManager:HasEmpty()
    local count = 0
    for i,v in ipairs(self.model.my_sh_list) do
        if v.war_id ~= 0 then
            count = count + 1
        end
    end

    if count == 4 then
        return false
    else
        return true
    end
end

-- 检查是否要菲亚下阵引导
function ShouhuManager:CheckFeya()
    if not self.needGuide then
        return false
    end

    local data = self.model:get_my_shouhu_data_by_id(1002)
    if data == nil then
        return false
    else
        if data.war_id == 0 then
            return false
        else
            return true
        end
    end
end

-- 检查是否要阿瑞斯引导
function ShouhuManager:CheckAruis()
    if not self.needGuide then
        return false
    end

    local data = self.model:get_my_shouhu_data_by_id(1020)
    if data == nil then
        return false
    else
        if data.war_id == 0 then
            return true
        else
            return false
        end
    end
end

-- 检查是否要助战引导
function ShouhuManager:CheckHelpGuide()
    local data = self.model:get_my_shouhu_data_by_id(1014)
    if data == nil then
        return false
    else
        if data.war_id == 0 then
            return false
        else
            if RoleManager.Instance.RoleData.lev < 50 and DramaManager.Instance.onceDic[DramaEumn.OnceGuideType.GuardHelp] == nil then
                local need = true
                for i,v in ipairs(self.model.my_sh_list) do
                    if v.guard_fight_state == self.model.guard_fight_state.field then
                        need = false
                    end
                end
                return need
            else
                return false
            end
        end
    end
end