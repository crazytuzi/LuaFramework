EquipStrengthManager = EquipStrengthManager or BaseClass(BaseManager)

function EquipStrengthManager:__init()
    if EquipStrengthManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    EquipStrengthManager.Instance = self;
    self:InitHandler()
    self.model = EquipStrengthModel.New()

    self.buy_listener = function(val) self:OnBuyResult(val) end
    self.findbackid = 0
    self.onAppointEffect = EventLib.New()
end

function EquipStrengthManager:__delete()
    self.model:DeleteMe()
    self.model = nil
end

function EquipStrengthManager:InitHandler()
    self:AddNetHandler(10600, self.on10600)
    self:AddNetHandler(10601, self.on10601)
    self:AddNetHandler(10602, self.on10602)
    self:AddNetHandler(10603, self.on10603)
    self:AddNetHandler(10604, self.on10604)
    self:AddNetHandler(10605, self.on10605)
    self:AddNetHandler(10606, self.on10606)
    self:AddNetHandler(10607, self.on10607)
    self:AddNetHandler(10608, self.on10608)
    self:AddNetHandler(10609, self.on10609)

    self:AddNetHandler(10610, self.on10610)
    self:AddNetHandler(10611, self.on10611)

    self:AddNetHandler(10612, self.on10612)
    self:AddNetHandler(10613, self.on10613)

    self:AddNetHandler(10614, self.on10614)

    self:AddNetHandler(10615, self.on10615)
    self:AddNetHandler(10616, self.on10616)

    self:AddNetHandler(10617, self.on10617)
    self:AddNetHandler(10618, self.on10618)
    self:AddNetHandler(10619, self.on10619)

    self:AddNetHandler(10620, self.on10620)
    self:AddNetHandler(10621, self.on10621)
    self:AddNetHandler(10622, self.on10622)

    self:AddNetHandler(10623, self.on10623)
    self:AddNetHandler(10624, self.on10624)
    self:AddNetHandler(10626, self.on10626)
    self:AddNetHandler(10629, self.on10629)
    self:AddNetHandler(10333, self.on10333)

    self.on_role_change = function(data)
        self:on_show_red_point()
    end
    EventMgr.Instance:AddListener(event_name.role_level_change, self.on_role_change)

    self.on_mainui_loaded = function(data)
        self:on_show_red_point()
    end
    EventMgr.Instance:AddListener(event_name.mainui_btn_init, self.on_mainui_loaded)

    EventMgr.Instance:AddListener(event_name.equip_item_change, self.on_mainui_loaded)
end

--设置红点逻辑
--对主ui上面的图标设置红点，申请列表有人则设置红点
function EquipStrengthManager:on_show_red_point()
    if RoleManager.Instance.RoleData.lev < 40 then
        return
    end
    local state = self.model:check_has_equip_can_lev_up()
    if state == false then
        state = self.model:check_has_equip_can_stone()
    end

    if MainUIManager.Instance.MainUIIconView ~= nil then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(5, state)
    end
end


--检查下是否显示装备属性切换
function EquipStrengthManager:on_check_is_last_lev_equip(_id, str)
    if EquipStrengthManager.Instance.model.equip_spare_attr_list[_id] ~= nil then
        --检查下是否切换在备用属性下
        local socket_data = EquipStrengthManager.Instance.model.equip_spare_attr_list[_id]
        if socket_data.back_lev == socket_data.now_lev then
            --该装备没在备用属性下
            return false
        else
            local str2 = string.format("%s<color='#ffff00'>%s</color>%s<color='#2fc823'>%s</color>%s<color='#ffff00'>%s</color>", TI18N("当前拥有"), TI18N("更高级装备"), TI18N("需要"), TI18N("切换") , TI18N("后再"), str)

            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = str2
            data.sureLabel = TI18N("切换装备")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = function()
                self:request10621(_id)
            end
            NoticeManager.Instance:ConfirmTips(data)
            return true
        end
    end
    return false
end

-- 英雄宝石找回
function EquipStrengthManager:HeroFindBack()
    local result = self:GetCanFindHero()
    if result then
        self.findbackid = result.id
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = string.format(TI18N("根据当前身上的装备条件，仍可找回<color='#ffff00'>%s次</color>英雄宝石，每次找回需要消耗一张<color='#ffff00'>英雄卷轴</color>，本次可找回<color='#ffff00'>%s颗</color>英雄宝石，是否继续？"), result.total, result.num)
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function() LuaTimer.Add(10, function() self:SureFindHero() end) end
        NoticeManager.Instance:ConfirmTips(data)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("身上已经没有可找回的英雄宝石了{face_1,24}"))
    end
end

function EquipStrengthManager:SureFindHero()
    if BackpackManager.Instance:GetItemCount(20406) == 0 then
        local shop = ShopManager.Instance.itemPriceTab[28]
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = string.format(TI18N("<color='#ffff00'>英雄卷轴</color>不足，可消耗{assets_1,%s,%s}购买，是否继续？"), 90002, shop.price)
        data.sureLabel = string.format(TI18N("%s{assets_2,90002}购买"), shop.price)
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function() self:SureBuyHero(shop) end
        NoticeManager.Instance:ConfirmTips(data)
    else
        self:request10626(self.findbackid)
        self.findbackid = 0
    end
end

function EquipStrengthManager:SureBuyHero(shop)
    EventMgr.Instance:RemoveListener(event_name.shop_buy_result, self.buy_listener)
    EventMgr.Instance:AddListener(event_name.shop_buy_result, self.buy_listener)
    ShopManager.Instance:send11303(shop.id, 1)
end

function EquipStrengthManager:OnBuyResult(result)
    EventMgr.Instance:RemoveListener(event_name.shop_buy_result, self.buy_listener)
    if result == 1 then
        self:SureFindHero()
    end
end

function EquipStrengthManager:GetCanFindHero()
    local backnum = 0
    local id = 0
    local total = 0
    local list = {}
    for i = 1, 8 do
        local equip = BackpackManager.Instance.equipDic[i]
        local num = 0
        local canback = false
        for k,v in pairs(equip.attr) do
            if v.type == GlobalEumn.ItemAttrType.gem and v.name == 112 then
                local data = DataBacksmith.data_hero_stone_base[v.val]
                if data ~= nil and data.lev >= 6 then
                    local degrade = DataBacksmith.data_stone_degrade[v.val]
                    if degrade ~= nil then
                        num = degrade.subtract_exp / 5
                    end
                end
            end
        end

        for k,v in pairs(equip.extra) do
            if v.name == BackpackEumn.ExtraName.hero_back then
                canback = true
            end
        end

        if canback then
            table.insert(list, {equip = equip, num = num})
        end
    end

    if #list == 0 then
        return nil
    end

    table.sort(list, function(a,b) return a.num > b.num end)

    local result = {}
    result.id = list[1].equip.id
    result.num = list[1].num
    result.total = #list
    return result
end

----------协议接收处理逻辑
--锻造装备返回
function EquipStrengthManager:on10600(data)
    --print('--------------------------收到10600')

    self.model:Release_equip_reset()
    self.model:Release_equip_perfect()
    if data.flag == 1 then --成功
        self.model.build_reset_id = self.model.build_reset_id + 1
        SoundManager.Instance:Play(220)
    elseif data.flag == 0 then --失败

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--锻造保存返回
function EquipStrengthManager:on10601(data)
    if data.flag == 1 then --成功

    elseif data.flag == 0 then --失败

    end
    -- --print(data.msg)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--强化装备返回
function EquipStrengthManager:on10602(data)
    self.model:Release_equip_strength()
    if data.flag == 1 then --强化成功
        SoundManager.Instance:Play(220)
    elseif data.flag == 2 then --操作失败
    elseif data.flag == 0 then --失败
        SoundManager.Instance:Play(221)
    end
    -- --print(data.msg)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--重铸装备返回
function EquipStrengthManager:on10603(data)
    self.model:Release_equip_reset()
    self.model:Release_equip_perfect()
    if data.flag == 1 then --成功
        self.model.build_reset_id = self.model.build_reset_id + 1
        SoundManager.Instance:Play(220)
    elseif data.flag == 0 then --失败

    end

    local eq_data = BackpackManager.Instance.equipDic[data.id]
    eq_data.reset_attr = data.reset_attr
    eq_data.lucky_val = data.lucky_val
    EventMgr.Instance:Fire(event_name.equip_strength_attr_back, data.reset_attr)
    -- --print(data.msg)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--镶嵌宝石返回
function EquipStrengthManager:on10604(data)
    if data.flag == 1 then --成功
        SoundManager.Instance:Play(219)
    elseif data.flag == 0 then --失败

    end
    -- --print(data.msg)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--升级宝石返回
function EquipStrengthManager:on10605(data)
    self.model:Release_equip_stone_up()
    if data.flag == 1 then --成功
        SoundManager.Instance:Play(219)
    elseif data.flag == 0 then --失败

    end
    -- --print(data.msg)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--摘除宝石返回
function EquipStrengthManager:on10606(data)
    if data.flag == 1 then --成功

    elseif data.flag == 0 then --失败

    end
    -- ---- print("-------------------------------收到10606")
    -- --print(data.msg)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--合成物品返回
function EquipStrengthManager:on10607(data)
    local next_base_id = data.next_base_id
    if data.flag == 1 then --成功

    elseif data.flag == 0 then --失败

    end
    -- --print(data.msg)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--选择重铸属性
function EquipStrengthManager:on10608(data)
    ---- print("----------------------收到10608")
    if data.flag == 1 then --成功
        local eq_data = BackpackManager.Instance.equipDic[data.id]
        eq_data.reset_attr = {}
        EventMgr.Instance:Fire(event_name.equip_strength_attr_back)
    elseif data.flag == 0 then --失败

    end
    -- --print(data.msg)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--请求属性返回
function EquipStrengthManager:on10609(data)
    ---- print("------------------------收到10609")
    local eq_data = BackpackManager.Instance.equipDic[data.id]
    if eq_data ~= nil then
        eq_data.reset_attr = data.backup_attr
        eq_data.lucky_val = data.lucky_val
        EventMgr.Instance:Fire(event_name.equip_strength_attr_back, data.backup_attr)
    end
end


--装备转换
function EquipStrengthManager:on10611(data)
    self.model:Release_equip_trans_buybtn()
    if data.flag == 1 then --成功

    elseif data.flag == 0 then --失败

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end



--请求重铸值
function EquipStrengthManager:on10612(data)
    ---- print("---------------------------收到10612")
    self.model.equip_reset_val = data.reset_val
    EventMgr.Instance:Fire(event_name.equip_build_resetval_update)
end


--领取重铸宝箱
function EquipStrengthManager:on10613(data)
    self.model:Release_equip_reset()
    self.model:Release_equip_perfect()
    if data.flag == 1 then --成功
        self.model.equip_reset_val = data.reset_val
        EventMgr.Instance:Fire(event_name.equip_build_resetval_update)
    elseif data.flag == 0 then --失败

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


--领取重铸宝箱
function EquipStrengthManager:on10614(data)
    -- {uint8,   flag,  "是否成功,0:失败 1:成功"}
    --             ,{string,  msg,  "提示语"}
    --             ,{uint32,  id,   "装备id"}

    self.model:Release_equip_trans_buybtn()
    if data.flag == 1 then --成功

    elseif data.flag == 0 then --失败

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end



--领取重铸宝箱
function EquipStrengthManager:on10615(data)
    --print('-----------------------------------收到10615')
    EventMgr.Instance:Fire(event_name.equip_strength_trans_attr_back, {id = data.id, attr = data.reset_attr})
end

--领取重铸宝箱
function EquipStrengthManager:on10616(data)
    --print('-----------------------------------收到10616')
    if data.flag == 1 then --成功
        EventMgr.Instance:Fire(event_name.equip_build_resetval_save_ok)
    elseif data.flag == 0 then --失败

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end



--神器精炼
function EquipStrengthManager:on10617(data)
    --print('-----------------------------------收到10616')
    self.model:Release_equip_dianhua()
    if data.flag == 1 then --成功
        -- data.id --装备id
        EventMgr.Instance:Fire(event_name.equip_dianhua_success)

    elseif data.flag == 0 then --失败

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 保存神器属性
function EquipStrengthManager:on10618(data)
    ---- print("--------------------------------10618")
    if data.flag == 1 then
        local equip_data = BackpackManager.Instance.equipDic[1]
        local _type = equip_data.type
        if self.model.cur_craft_eq_id == 1 then
            for i=1,#DataBacksmith.data_equip_dianhua do
                local cfg_data = DataBacksmith.data_equip_dianhua[i]

                if cfg_data.lev <= RoleManager.Instance.RoleData.lev  and cfg_data.classes == RoleManager.Instance.RoleData.classes and cfg_data.craft == self.model.cur_craft and cfg_data.type == _type then

                    local star_num = self.model:GetStarCount(equip_data.super[self.model.cur_craft].val, cfg_data.max_val, cfg_data.looks_active_val)
                    if star_num >=4 and self.model.cur_craft_star < 4 then
                        if cfg_data.looks ~= 0 then
                            EquipStrengthManager.Instance.model:OpenEquipDianhuaGetsUI(cfg_data.looks)
                        end
                    end
                end
            end
        end
        --炼化保存成功
        EventMgr.Instance:Fire(event_name.equip_dianhua_save_success)
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 选择神器外观
function EquipStrengthManager:on10619(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


-- 查询装备备用属性
function EquipStrengthManager:on10620(data)
    print('--------------------------------收到10620===============================================================')
    -- local temp_data = BackpackManager.Instance.equipDic[1]

    if self.model.is_active_req_back then
        --是主动请求
        self.model.is_active_req_back = false
        -- if data.back_lev ~= 0 and data.now_lev ~= 0 and #data.attr_list ~= 0 then
            EventMgr.Instance:Fire(event_name.equip_last_lev_attr_back, data)
        -- end
    else
        EventMgr.Instance:Fire(event_name.equip_item_change, {})
    end
    self.model.equip_spare_attr_list[data.id] = data


    EventMgr.Instance:Fire(event_name.equip_last_lev_attr_update)
end

-- 切换备用属性
function EquipStrengthManager:on10621(data)
    --print('--------------------------------收到10621')
    -- data.id --装备id
    if data.flag == 1 then
        --成功

    else

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--装备突破
function EquipStrengthManager:on10622(data)
    -- print("--------------------------------收到10622")
    if data.flag == 1 then
        --成功

    else

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

---------------请求协议逻辑
--请求锻造装备
function EquipStrengthManager:request10600(_id, _is_perfect, use_hero_paper)
    if use_hero_paper == nil then
        use_hero_paper = 0
    end
    local is_switch = self:on_check_is_last_lev_equip(_id, TI18N("锻造"))
    if is_switch == false then
        -- print('-------------------------------发送10600 ' .. tostring(use_hero_paper))
        Connection.Instance:send(10600, {id=_id, is_perfect = _is_perfect, use_hero_paper = use_hero_paper})
    else
        self.model:Release_equip_perfect()
        self.model:Release_equip_reset()
    end
end

--请求锻造保存
function EquipStrengthManager:request10601(_id)
    Connection.Instance:send(10601, {id=_id})
end

--请求强化装备
function EquipStrengthManager:request10602(_id, _luck_list, _is_protect)
    self.model:Frozen_equip_strength()
    local data = {id=_id, luck_list = _luck_list, protect_id = _is_protect}
    Connection.Instance:send(10602, data)
end

--请求重铸装备
function EquipStrengthManager:request10603(_id, reset_attr)
--    if self.model.equip_reset_val >= self.model.max_equip_reset_val and EquipStrengthManager.Instance.model:check_show_rebuild_reward() then
--        local str = string.format("%s%s%s", TI18N("你已累积"), self.model.max_equip_reset_val, TI18N("点重铸能量，可领取重铸大师宝箱"))

--        local data = NoticeConfirmData.New()
--        data.type = ConfirmData.Style.Sure
--        data.content = str
--        data.sureLabel = TI18N("确定")
--        data.sureCallback = function()
--            self.model:Release_equip_reset()
--            self.model:Release_equip_perfect()
--        end
--        NoticeManager.Instance:ConfirmTips(data)
--    else
    local is_switch = self:on_check_is_last_lev_equip(_id, TI18N("重铸"))
    if is_switch == false then
        --检查当前要重铸的装备是否有特效未保存
        if reset_attr == nil or #reset_attr == 0 then
            --没有需要保存的重铸属性
            Connection.Instance:send(10603, {id=_id})
        else
            --有需要保存的，检查属性中是否有特效
            local hasEffect = false
            local effect_attr = {}
            for i=1,#reset_attr  do
                local attr_v = reset_attr[i]
                if attr_v.type == GlobalEumn.ItemAttrType.effect or attr_v.type == GlobalEumn.ItemAttrType.wing_skill then
                    hasEffect = true
                    break
                end
            end
            if hasEffect then
                if self.model.no_confirm_equip_reset then
                    Connection.Instance:send(10603, {id=_id})
                else
                    self.model:Release_equip_reset()
                    local data = NoticeConfirmData.New()
                    data.type = ConfirmData.Style.Normal
                    data.content = TI18N("当前装备具有未保存的稀有特效，是否不进行保存并进行重铸？")
                    data.sureLabel = TI18N("确认重铸")
                    data.cancelLabel = TI18N("我再想想")
                    data.blueSure = true
                    data.greenCancel = true
                    data.showToggle = true
                    data.toggleLabel = TI18N("不再提示")
                    data.toggleCallback = function()
                        self.model.no_confirm_equip_reset = true
                    end
                    data.sureCallback = function()
                        Connection.Instance:send(10603, {id=_id})
                    end
                    NoticeManager.Instance:ConfirmTips(data)
                end
            else
                --没有需要保存的特效
                Connection.Instance:send(10603, {id=_id})
            end
        end
--        else
--            self.model:Release_equip_reset()
--        end
    end
end

--请求镶嵌宝石
function EquipStrengthManager:request10604(_id, _hole_id, _stone_id)
    Connection.Instance:send(10604, {id=_id, hole_id = _hole_id, stone_id = _stone_id})
end

--请求升级宝石
function EquipStrengthManager:request10605(_id, _hole_id, _stone_id)
    self.model:Frozen_equip_stone_up()
    Connection.Instance:send(10605, {id=_id, hole_id = _hole_id, stone_id = _stone_id})
end

--请求摘除宝石
function EquipStrengthManager:request10606(_id, _hole_id)
    Connection.Instance:send(10606, {id=_id, hole_id = _hole_id})
end


--请求合成物品
function EquipStrengthManager:request10607(_base_id)
    Connection.Instance:send(10607, {base_id=_base_id})
end


--请求选择重铸属性
function EquipStrengthManager:request10608(_id)
    -- ---- print("---------------------------发送10608")
    local is_switch = self:on_check_is_last_lev_equip(_id, TI18N("保存属性"))
    if is_switch == false then
        Connection.Instance:send(10608, {id=_id})
    else

    end
end

--请求属性
function EquipStrengthManager:request10609(_id, _type)
    ---- print("------------------------请求10609")
    Connection.Instance:send(10609, {id=_id})
end


--请求装备转换
function EquipStrengthManager:request10611(_id, _side)
    local is_switch = self:on_check_is_last_lev_equip(_id, TI18N("转换"))
    if is_switch == false then
        Connection.Instance:send(10611, {id=_id, side = _side})
    else
        self.model:Release_equip_trans_buybtn()
    end
end


--请求重铸值
function EquipStrengthManager:request10612()
    ---- print("---------------------------请求10612")
    Connection.Instance:send(10612, {})
end


--领取重铸宝箱
function EquipStrengthManager:request10613()
    ---- print("---------------------------请求10613")
    Connection.Instance:send(10613, {})
end

--特效转换
function EquipStrengthManager:request10614(_id)
    ---- print("---------------------------请求10614")
    local is_switch = self:on_check_is_last_lev_equip(_id, TI18N("保存特技"))
    if is_switch == false then
        Connection.Instance:send(10614, {id = _id})
    else
        self.model:Release_equip_trans_buybtn()
    end
end



--查询特效转换信息
function EquipStrengthManager:request10615(_id)
    ---- print("---------------------------请求10615")
    Connection.Instance:send(10615, {id = _id})
end


--保存特技
function EquipStrengthManager:request10616(_id)
    ---- print("---------------------------请求10616")
    local is_switch = self:on_check_is_last_lev_equip(_id, TI18N("保存特技"))
    if is_switch == false then
        Connection.Instance:send(10616, {id = _id})
    else

    end
end


--神器精炼
function EquipStrengthManager:request10617(_id, _craft, _lock)
    ---- print("---------------------------请求10617")
    Connection.Instance:send(10617, {id = _id, craft = _craft, lock = _lock})
end

-- 保存神器属性
function EquipStrengthManager:request10618(id, craft, star_num)
    self.model.cur_craft_eq_id = id
    self.model.cur_craft = craft
    self.model.cur_craft_star = star_num
    Connection.Instance:send(10618, {id = id, craft = craft})
end

-- 选择神器外观
function EquipStrengthManager:request10619(id, looks)
    Connection.Instance:send(10619, {id = id, looks = looks})
end


-- 查询装备备用属性
function EquipStrengthManager:request10620(_id)
    --print('-----------------------------请求10620')
    self.model.is_active_req_back = true
    Connection.Instance:send(10620, {id = _id})
end

--切换备用属性
function EquipStrengthManager:request10621(_id)
    --print('-----------------------------请求10621')
    Connection.Instance:send(10621, {id = _id})
end

--装备突破
function EquipStrengthManager:request10622(_id)
    print('-----------------------------请求10622')
    Connection.Instance:send(10622, {id = _id})
end

function EquipStrengthManager:request10623(id)
    Connection.Instance:send(10623, {id = id})
end

function EquipStrengthManager:on10623(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--升级英雄宝石
function EquipStrengthManager:request10624(id, hole_id, num)
    Connection.Instance:send(10624, {id = id, hole_id = hole_id, num = num})
end

--升级英雄宝石返回
function EquipStrengthManager:on10624(data)
    if data.flag == 1 then
        --成功

    else

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function EquipStrengthManager:request10626(id)
    Connection.Instance:send(10626, {id = id})
end

function EquipStrengthManager:on10626(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--请求获取指定精炼分享数据返回
function EquipStrengthManager:request10333(role_id, platform, zone_id)
    print('=-------------------发送10333')
    Connection.Instance:send(10333, {role_id = role_id, platform = platform, zone_id = zone_id})
end

--获取指定精炼分享数据返回
function EquipStrengthManager:on10333(data)
    print('=-------------------收到10333')
    BaseUtils.dump(data)
    self.model:OnUpdateDianhuaShareInfo(data)
end

--指定特效进行洗练
function EquipStrengthManager:request10629(id, attr_name, attr_val)
    print('=-------------------发送10629')
    Connection.Instance:send(10629, {id = id, attr_name = attr_name, attr_val = attr_val})
end

function EquipStrengthManager:on10629(data)
    print('=-------------------收到10629')
    if data.flag == 1 then 
        self.model.selected_effect_flag = false 
        self.model.selected_effect = nil 
        EquipStrengthManager.Instance.onAppointEffect:Fire()
    end 
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
