FashionModel = FashionModel or BaseClass(BaseModel)

function FashionModel:__init()
    self.current_fashion_list = nil
    self.dyeing_fashion_list = nil
    self.main_win = nil
    self.belt_confirm_panel = nil
    self.open_panel = nil
    self.face_win = nil
    self.face_reward_win = nil
    self.weapon_open_panel = nil

    self.current_head_data = nil
    self.current_cloth_data = nil
    self.current_waist_data = nil --腰饰
    self.current_ring_data = nil
    self.current_head_dress_data = nil --头饰
    self.current_weapon_data = nil --武器

    self.has_onclick_belt_item = false
    self.collect_lev = 0
    self.collect_val = 0
    self.belt_type = 0
    self.classes_eqm = 0

    self.arenaKingList = {}
    self.classesChiefList  = {}
    self.classesChiefList1 = {}
    self.classesChiefList2 = {}
    self.weapon = 0
end

function FashionModel:__delete()

end


--打开/关闭窗口逻辑
function FashionModel:OpenFashionUI()
    if self.main_win == nil then
        self.main_win = FashionMainWindow.New(self)
    end
    self.main_win:Open()
end

function FashionModel:CloseFashionUI()
     WindowManager.Instance:CloseWindow(self.main_win)
    if self.main_win == nil then
        -- print("===================self.main_win is nil")
    else
        -- print("===================self.main_win is not nil")
    end
end

function FashionModel:OpenFashionFaceUI()
    if self.face_win == nil then
        self.face_win = FashionFaceScoreWindow.New(self)
    end
    self.face_win:Open()
end

function FashionModel:CloseFashionFaceUI()
    WindowManager.Instance:CloseWindow(self.face_win)
    if self.face_win == nil then
        -- print("===================self.face_win is nil")
    else
        -- print("===================self.face_win is not nil")
    end
end

function FashionModel:OpenFashionFaceRewardUI()
    if self.face_reward_win == nil then
        self.face_reward_win = FashionFaceRewardWindow.New(self)
    end
    self.face_reward_win:Show()
end

function FashionModel:CloseFashionFaceRewardUI()
    if self.face_reward_win ~= nil then
        self.face_reward_win:DeleteMe()
        self.face_reward_win = nil
    end
end

--升级返回
function FashionModel:OnFaceLevUpSuccess()
    if self.face_win ~= nil then
        self.face_win:OnLevUpSuccess()
        self.face_win:UpdateInfo()
    end
end

--打开饰品快速购买面板
function FashionModel:InitFashionBeltConfirmUI()
    if self.belt_confirm_panel == nil then
        self.belt_confirm_panel = FashionBeltConfirmPanel.New(self)
        self.belt_confirm_panel:Show()
    end
end

function FashionModel:CloseFashionBeltConfirmUI()
    if self.belt_confirm_panel ~= nil then
        self.belt_confirm_panel:DeleteMe()
        self.belt_confirm_panel = nil
    end
end

function FashionModel:InitFashionOpenUI(args)
    if self.open_panel == nil then
        self.open_panel = FashionOpenWindow.New(self)
        self.open_panel:Show(args)
    end
end

function FashionModel:CloseFashionOpenUI()
    if self.open_panel ~= nil then
        self.open_panel:DeleteMe()
        self.open_panel = nil
    end
end

function FashionModel:InitWeaponFashionOpenUI(args)
    if self.weapon_open_panel == nil then
        self.weapon_open_panel = WeaponFashionOpenWindow.New(self)
        self.weapon_open_panel:Show(args)
    end
end

function FashionModel:CloseWeaponFashionOpenUI()
    if self.weapon_open_panel ~= nil then
        self.weapon_open_panel:DeleteMe()
        self.weapon_open_panel = nil
    end
end

function FashionModel:InitWeaponFashionPreviewWindow(args)
    if self.weaponFashionPreviewWindow == nil then
        self.weaponFashionPreviewWindow = WeaponFashionPreviewWindow.New(self)
        self.weaponFashionPreviewWindow:Show(args)
    end
end

function FashionModel:CloseWeaponFashionPreviewWindow()
    if self.weaponFashionPreviewWindow ~= nil then
        self.weaponFashionPreviewWindow:DeleteMe()
        self.weaponFashionPreviewWindow = nil
    end
end

function FashionModel:OpenFashionExchange(args)
    if self.fashionExchange == nil then
        self.fashionExchange = FashionExchangeWindow.New(self)
    end
    self.fashionExchange:Open(args)
end

function FashionModel:CloseFashionExchange()
    if self.fashionExchange ~= nil then
        self.fashionExchange:DeleteMe()
        self.fashionExchange = nil
    end
end

--面板各种更新
function FashionModel:update_socket()
    if self.main_win ~= nil then
        self.main_win:update_socket()
    end
end

function FashionModel:socket_back_put_on()
    if self.main_win ~= nil then
        self.main_win:socket_back_put_on()
    end
end

function FashionModel:socket_back_unload()
    if self.main_win ~= nil then
        self.main_win:socket_back_unload()
    end
end


------------------------------对frozenbutton的click和release调用
function FashionModel:Release_buy_btn()
    if self.main_win ~= nil then
        if self.main_win.suit_tab ~= nil and self.main_win.suit_tab.BtnSave_btn ~= nil then
            self.main_win.suit_tab.BtnSave_btn:ReleaseFrozon()
        end
    end
end


-------------------------------------------各种get/set
--传入socketdata获取配置完整的数据
function FashionModel:get_cfg_data(socket_data)
    if socket_data == nil then
        return nil
    end
    -- BaseUtils.dump(socket_data, "socket_data")
    -- print(socket_data.base_id)
    -- print(DataFashion.data_base[socket_data.base_id])
    local cfg_data = BaseUtils.copytab(DataFashion.data_base[socket_data.base_id])
    cfg_data.is_wear = socket_data.is_wear
    cfg_data.expire_time = socket_data.expire_time
    cfg_data.active = socket_data.active
    return cfg_data
end

--传入套装id，确定该套装是否已经激活
function FashionModel:CheckSuitIsActive(id)
    local list = self:get_suit_data_list()
    return list[id] ~= nil and list[id].active == 1
end

--获取套装数据列表
function FashionModel:get_suit_data_list()
    local result_list = {}
    local temp_list = {}
    for k, v in pairs(self.current_fashion_list) do
        for i, d in pairs(v) do
            local data_base = DataFashion.data_base[d.base_id]
            if data_base ~= nil then
                local cfg_data = BaseUtils.copytab(data_base)
                cfg_data.is_wear = d.is_wear
                cfg_data.expire_time = d.expire_time
                cfg_data.active = 1
                temp_list[cfg_data.set_id] = cfg_data
            end
        end
    end

    for k, v in pairs(DataFashion.data_suit) do
        if temp_list[v.id] == nil and v.sex == RoleManager.Instance.RoleData.sex then
            local cfg_data = BaseUtils.copytab(v)
            cfg_data.is_wear = 0
            cfg_data.expire_time = 0
            cfg_data.active = 0
            cfg_data.special_mark = self:get_suit_special_mark(cfg_data)
            result_list[cfg_data.id] = cfg_data
        elseif temp_list[v.id] ~= nil then
            local cfg_data = BaseUtils.copytab(v)
            cfg_data.is_wear = temp_list[v.id].is_wear
            cfg_data.expire_time = temp_list[v.id].expire_time
            cfg_data.active = temp_list[v.id].active
            cfg_data.special_mark = self:get_suit_special_mark(cfg_data)
            result_list[cfg_data.id] = cfg_data
        end
    end
    return result_list
end

function FashionModel:get_suit_special_mark(data)
    for i, value in ipairs(data.include) do
        local data_base = DataFashion.data_base[value.fashion_id]
        if data_base.special_mark ~= 0 then
            return data_base.special_mark
        end
    end

    return 0
end

--传入类型，获取对应类型和本职业本性别的染色方案
function FashionModel:get_color_prog_list_by_type(_type)
    local result_list = {}
    for k, v in pairs(DataFashion.data_color_prog) do
        if v.type == _type and v.sex == RoleManager.Instance.RoleData.sex and v.classes == RoleManager.Instance.RoleData.classes then
            table.insert(result_list, BaseUtils.copytab(v))
        end
    end
    return result_list
end

--传入类型，获取已经激活的套装里面的头或者身体的数据列表
function FashionModel:get_suit_fashion_list_by_type(_type)
    local socket_list = self.current_fashion_list[_type]
    local result_list = {}
    for k, v in pairs(socket_list) do
        local cfg_data = BaseUtils.copytab(DataFashion.data_base[k])
        cfg_data.active = 1
        cfg_data.is_wear = v.is_wear
        cfg_data.expire_time = v.expire_time
        table.insert(result_list, cfg_data)
    end
    return result_list
end

--传入套装id，确定该套装是否已经激活
function FashionModel:CheckBeltIsActive(id)
    local list = self:get_belt_data_list()
    return list[id] ~= nil and list[id].active == 1
end

--获取饰品数据
function FashionModel:get_belt_data_list()
    local result_list = {}
    local socket_list = self.current_fashion_list[SceneConstData.lookstype_belt]
    for k, v in pairs(DataFashion.data_base) do
        if v.type == SceneConstData.lookstype_belt then

            if (v.sex == RoleManager.Instance.RoleData.sex or v.sex == 2) and v.is_role ~= 1 then
                if socket_list[v.base_id] == nil then
                    local cfg_data = BaseUtils.copytab(v)
                    cfg_data.is_wear = 0
                    cfg_data.expire_time = 0
                    cfg_data.active = 0
                    result_list[cfg_data.base_id] = cfg_data
                else
                    local cfg_data = BaseUtils.copytab(v)
                    cfg_data.is_wear = socket_list[v.base_id].is_wear
                    cfg_data.expire_time = socket_list[v.base_id].expire_time
                    cfg_data.active = 1
                    result_list[cfg_data.base_id] = cfg_data
                end
            end
        end
    end

    socket_list = self.current_fashion_list[SceneConstData.lookstype_headsurbase]
    for k, v in pairs(DataFashion.data_base) do
        if v.type == SceneConstData.lookstype_headsurbase then
            if (v.sex == RoleManager.Instance.RoleData.sex or v.sex == 2) and v.is_role ~= 1 then
                if socket_list[v.base_id] == nil then
                    local cfg_data = BaseUtils.copytab(v)
                    cfg_data.is_wear = 0
                    cfg_data.expire_time = 0
                    cfg_data.active = 0
                    result_list[cfg_data.base_id] = cfg_data
                else
                    local cfg_data = BaseUtils.copytab(v)
                    cfg_data.is_wear = socket_list[v.base_id].is_wear
                    cfg_data.expire_time = socket_list[v.base_id].expire_time
                    cfg_data.active = 1
                    result_list[cfg_data.base_id] = cfg_data
                end
            end
        end
    end
    return result_list
end

--获取武器数据
function FashionModel:get_weapon_data_list()
    local result_list = {}
    local socket_list = self.current_fashion_list[SceneConstData.looktype_weapon]
    local roleData = RoleManager.Instance.RoleData

    for k, v in pairs(DataFashion.data_base) do
        if v.type == SceneConstData.looktype_weapon then
            if v.classes == roleData.classes then
                if (v.sex == roleData.sex or v.sex == 2) and v.is_role ~= 1 then
                    if v.special_mark ~= 1 or (v.special_mark == 1 and self.weapon == v.base_id) then
                        if socket_list[v.base_id] == nil then
                            local cfg_data = BaseUtils.copytab(v)
                            cfg_data.is_wear = 0
                            cfg_data.expire_time = 0
                            cfg_data.active = 0
                            -- cfg_data.special_mark = 0
                            result_list[cfg_data.base_id] = cfg_data
                        else
                            local cfg_data = BaseUtils.copytab(v)
                            cfg_data.is_wear = socket_list[v.base_id].is_wear
                            cfg_data.expire_time = socket_list[v.base_id].expire_time
                            cfg_data.active = 1
                            -- cfg_data.special_mark = socket_list[v.base_id].special_mark
                            result_list[cfg_data.base_id] = cfg_data
                        end
                    end
                end
            end
        end
    end

    return result_list
end

--数据处理
--根据传入的时装类型构造一份数据出来
function FashionModel:get_fashion_data_list(_type)
    local result_list = {}
    local socket_list = self.current_fashion_list[_type]
    for k, v in pairs(DataFashion.data_base) do
        if v.type == _type or (v.type == SceneConstData.lookstype_belt and _type == SceneConstData.lookstype_headsurbase) or (v.type == SceneConstData.lookstype_headsurbase and _type == SceneConstData.lookstype_belt) then

            if (v.sex == RoleManager.Instance.RoleData.sex or v.sex == 2) and v.is_role ~= 1 then
                if socket_list[v.base_id] == nil then
                    local cfg_data = BaseUtils.copytab(v)
                    cfg_data.is_wear = 0
                    cfg_data.expire_time = 0
                    cfg_data.active = 0
                    result_list[cfg_data.base_id] = cfg_data
                else
                    local cfg_data = BaseUtils.copytab(v)
                    cfg_data.is_wear = socket_list[v.base_id].is_wear
                    cfg_data.expire_time = socket_list[v.base_id].expire_time
                    cfg_data.active = 1
                    result_list[cfg_data.base_id] = cfg_data
                end
            end
        end
    end

    return result_list


    -- 旧逻辑暂时屏蔽
    -- --顺便进行一些排序
    -- local result_list = {}
    -- for k, v in pairs(DataFashion.data_base) do
    --     local data = v
    --     if data.type == _type and (data.sex == RoleManager.Instance.RoleData.sex or data.sex == 2) and data.lev <= RoleManager.Instance.RoleData.lev and data.is_role == 0  then
    --         if data.classes == RoleManager.Instance.RoleData.classes or data.classes == 0 then

    --             local temp = BaseUtils.copytab(data)
    --             temp.active = 0
    --             temp.is_wear = 0
    --             temp.expire_time = 0
    --             table.insert(result_list, temp)
    --         end
    --     end
    -- end

    -- local socket_list = self.current_fashion_list[_type]
    -- local temp_list = {}

    -- for k,v in pairs(socket_list) do
    --     local data = v
    --     temp_list[data.base_id] = data
    -- end

    -- local active_list = {}
    -- local unactive_list = {}
    -- for i=1,#result_list do
    --     local data = result_list[i]
    --     local data2 = temp_list[data.base_id]
    --     if data2 ~= nil then
    --         data.active = 1
    --         data.is_wear = data2.is_wear
    --         data.expire_time = data2.expire_time
    --     else
    --         data.is_wear = 0
    --     end

    --     if data.active == 1 then
    --         table.insert(active_list, data)
    --     else
    --         table.insert(unactive_list, data)
    --     end
    -- end

    -- local priority_sort = function(a, b)
    --     return a.id < b.id --根据index从小到大排序
    -- end
    -- table.sort(active_list, priority_sort)
    -- table.sort(unactive_list, priority_sort)

    -- result_list = {}
    -- for i=1,#active_list do
    --     table.insert(result_list, active_list[i])
    -- end
    -- for i=1,#unactive_list do
    --     table.insert(result_list, unactive_list[i])
    -- end

    -- return result_list
end


--获取当前穿戴着的头饰
function FashionModel:get_current_fashion_data(_type)
    local socket_list = self.current_fashion_list[_type]
    if socket_list == nil then
        return nil
    end
    for k, data in pairs(socket_list) do
        if data.is_wear == 1 then
            return data
        end
    end
    return nil
end


--根据职业性别时装类型获取默认时装
function FashionModel:get_default_fashion(_type)
    for k,v in pairs(DataFashion.data_base) do
        if v.type == _type then
            if (v.sex == RoleManager.Instance.RoleData.sex or v.sex == 2)  and (v.classes == RoleManager.Instance.RoleData.classes or v.classes == 0) and v.is_origin == 1 then
                return v
            end
        end
    end
    return nil
end


--传入时装id判断下这件时装是否已经获得
function FashionModel:check_fashion_has_active(_base_id)
    local cfg_data = DataFashion.data_base[_base_id]
    local socket_list = self.current_fashion_list[cfg_data.type]
    if socket_list[_base_id] ~= nil then
        return true
    else
        return false
    end
end

--检查下传入的时装data是否为基础的
function FashionModel:check_fashion_is_base(data)
    if data ~= nil then
        if data.is_origin == 1 then
            return true
        end
    else
        return true
    end
    return false
end


--检查下传进来的两个looks是不是一样
function FashionModel:check_loos_is_same(looks1,looks2)
    if #looks1 ~= #looks2 then
        return false
    end

    local dic_1 = {}
    local dic_2 = {}
    for i=1,#looks1 do
        local temp = looks1[1]
        dic_1[temp.looks_type] = temp
    end

    for i=1,#looks2 do
        local temp = looks2[1]
        dic_2[temp.looks_type] = temp
    end
    for k, v in pairs(looks1) do
        local temp = looks2[k]
        if temp.looks_mode ~= v.looks_mode or temp.looks_val ~= v.looks_val then
            return false
        end
    end
    return true
end


-------------------------------字符串处理
--转换剩余时间为可显示字符串
function FashionModel:convert_left_time_str(left_time)
    local my_date, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(left_time)
    local str = ""
    if my_date > 0 then
        my_date = my_date >= 10 and tostring(my_date) or string.format("0%s", my_date)
        -- my_hour = my_hour >= 10 and tostring(my_hour) or string.format("0%s", my_hour)
        -- str = string.format("%s%s%s%s", my_date, TI18N("天"), my_hour, TI18N("小时"))
        str = string.format("%s%s", my_date, TI18N("天"))
    elseif my_hour > 0 then
        my_hour = my_hour >= 10 and tostring(my_hour) or string.format("0%s", my_hour)
        -- my_minute = my_minute >= 10 and tostring(my_minute) or string.format("0%s", my_minute)
        str = string.format("%s%s", my_hour, TI18N("小时"))
    elseif my_minute >= 0 then
        my_minute = my_minute >= 10 and tostring(my_minute) or string.format("0%s", my_minute)
        my_second = my_second >= 10 and tostring(my_second) or string.format("0%s", my_second)
        -- str = string.format("%s%s%s%s", my_minute, TI18N("分"), my_second, TI18N("秒"))
        str = TI18N("不足1小时")
    end
    return str
end

--------------------------------计算时装消耗
--将两个cost_dic合起来
function FashionModel:merge_cost_dic(cost_dic1, cost_dic2)
    local cost_dic = {}
    for k, v in pairs(cost_dic1) do
        if cost_dic[k] ~= nil then
            cost_dic[k] = cost_dic[k] + v
        else
            cost_dic[k] = v
        end
    end
    for k, v in pairs(cost_dic2) do
        if cost_dic[k] ~= nil then
            cost_dic[k] = cost_dic[k] + v
        else
            cost_dic[k] = v
        end
    end
    return cost_dic
end


function FashionModel:count_current_loss()
    local cost_dic = {}
    self:count_current_loss_help(cost_dic, self.current_head_data)
    self:count_current_loss_help(cost_dic, self.current_cloth_data)
    self:count_current_loss_help(cost_dic, self.current_waist_data)
    self:count_current_loss_help(cost_dic, self.current_ring_data)
    self:count_current_loss_help(cost_dic, self.current_head_dress_data)
    return cost_dic
end

function FashionModel:count_fashion_loss(data)
    local cost_dic = {}
    for i=1,#data.loss do
        cost_dic[data.loss[i].val[1][1]] = data.loss[i].val[1][2]
    end
    return cost_dic
end

function FashionModel:count_current_loss_help(_dic, _data)
    if _data ~= nil and _data.active == 0 then
        local temp_dic = self:count_fashion_loss(_data)
        for k, v in pairs(temp_dic) do
            if _dic[k] ~= nil then
                _dic[k] = _dic[k] + v
            else
                _dic[k] = v
            end
        end
    end
end

--计算套装消耗
function FashionModel:count_suit_loss(data)
    local cost_dic = {}
    for i=1,#data.loss do
        cost_dic[data.loss[i].val[1][1]] = data.loss[i].val[1][2]
    end
    return cost_dic
end

--计算激活的染色的消耗
function FashionModel:count_color_change_loss(data)
    --检查下这个染色方案是不是当前的
    if data.is_use == 1 then
        return {}
    end
    local cost_dic = {}
    for i=1,#data.change_loss do
        cost_dic[data.change_loss[i].val[1][1]] = data.change_loss[i].val[1][2]
    end
    return cost_dic
end

--计算字典颜色
function FashionModel:count_dic_len(cost_dic)
    local len = 0
    for k, v in pairs(cost_dic) do
        len = len + 1
    end
    return len
end

--检查传入的饰品是否可以穿戴
function FashionModel:check_is_belt_can_wear(data)
    if data == nil then
        return false
    elseif data.is_role == 1 then
        return false
    elseif data.active == 0 then
        return false
    else
        return true
    end
end


--检查饰品是否为nil,或者是基础饰品
function FashionModel:check_is_belt_data(data)
    if data == nil then
        return false
    elseif data.is_role == 1 then
        return false
    else
        return true
    end
end

--检查传入的武器是否可以穿戴
function FashionModel:check_is_weapon_can_wear(data)
    if data == nil then
        return false
    -- elseif data.is_role == 1 then
    --     return false
    elseif data.active == 0 then
        return false
    else
        return true
    end
end

--检查武器是否为nil,或者是基础饰品
function FashionModel:check_is_weapon_data(data)
    if data == nil then
        return false
    elseif data.is_role == 1 then
        return false
    else
        return true
    end
end

--检查饰品是否是nil或者是基础的
function FashionModel:check_is_base_data(data)
    if data == nil then
        return true
    elseif data.is_role == 1 then
        return true
    end
    return false
end

--处理服务器发来的时装数据外的武器时装
function FashionModel:InitWeaponFashion()
    if self.current_fashion_list[SceneConstData.looktype_weapon] == nil then
        self.current_fashion_list[SceneConstData.looktype_weapon] = {}
    end

    local useingFashionMark = false -- 正在时装外观标记
    local weaponFashionList = self.current_fashion_list[SceneConstData.looktype_weapon]
    for weaponFashionIndex, weaponFashionData in pairs(weaponFashionList) do
        if weaponFashionData.special_mark == 1 or weaponFashionData.special_mark == 2 then
            weaponFashionList[weaponFashionIndex] = nil
        elseif weaponFashionData.is_wear == 1 then
            useingFashionMark = true
        end
    end

    local equip_type = 1
    for equipDicIndex, equipDicData in pairs(BackpackManager.Instance.equipDic) do
        if equipDicData.pos == 1 then
            equip_type = equipDicData.type
        end
    end

    -- 神器
    local dianhua_data_list  = EquipStrengthManager.Instance.model:get_equip_dianhua_list(equip_type, RoleManager.Instance.RoleData.classes)
    local super = BackpackManager.Instance.equipDic[1].super
    for i=1,#dianhua_data_list do
        if dianhua_data_list[i].looks ~= 0 then
            local dianhua_data = dianhua_data_list[i]
            if (super[dianhua_data.craft] ~= nil and super[dianhua_data.craft].val >= dianhua_data.looks_active_val and dianhua_data.looks_active_val ~= 0) then -- 已获得的神器外观
                if not useingFashionMark and self.classes_eqm == 0 and BackpackManager.Instance.equipDic[1].currLookId == dianhua_data.looks then
                    weaponFashionList[dianhua_data.fashion_id] = {base_id = dianhua_data.fashion_id, active = 1, is_wear = 1, expire_time = 0, special_mark = 2}
                    useingFashionMark = true
                else
                    weaponFashionList[dianhua_data.fashion_id] = {base_id = dianhua_data.fashion_id, active = 1, is_wear = 0, expire_time = 0, special_mark = 2}
                end
            else -- 未获得的神器外观

            end
        end
    end

    -- 职业基础武器
    local base_weapon_data = nil
    -- for key, cfg_base_data in pairs(DataItem.data_equip) do
    --     if cfg_base_data.classes == RoleManager.Instance.RoleData.classes and cfg_base_data.type == equip_type and cfg_base_data.lev <= math.floor(RoleManager.Instance.RoleData.lev/10)*10 then
    --         if base_weapon_data == nil then
    --             base_weapon_data = DataItem.data_get[key]
    --         else
    --             if cfg_base_data.lev > base_weapon_data.lev then
    --                 base_weapon_data = DataItem.data_get[key]
    --             end
    --         end
    --     end
    -- end

    if DataItem.data_equip[self.weapon] then
        base_weapon_data = DataItem.data_get[self.weapon]
    end

    for key, value in ipairs(base_weapon_data.effect_client) do
        if value.effect_type_client == 20 then
            if useingFashionMark then
                weaponFashionList[value.val_client[1]] = {base_id = value.val_client[1], active = 1, is_wear = 0, expire_time = 0, special_mark = 1}
            else
                weaponFashionList[value.val_client[1]] = {base_id = value.val_client[1], active = 1, is_wear = 1, expire_time = 0, special_mark = 1}
            end
        end
    end
end

--获取武器外观的强化特效mode
function FashionModel:GetWeaponLookModel(looks_val)

    local enchant = 0
    if BackpackManager.Instance.equipDic ~= nil and BackpackManager.Instance.equipDic[1] ~= nil then
        enchant = BackpackManager.Instance.equipDic[1].enchant or enchant
    end
    local nomal_enchant = 0
    local other_enchant = 0
    if enchant < 9 then
        nomal_enchant = 0
        other_enchant = 0
    elseif enchant < 12 then
        nomal_enchant = 9
        other_enchant = 0
    else
        nomal_enchant = 12
        other_enchant = 12
    end

    local myData = SceneManager.Instance:MyData()
    for k, v in pairs(myData.looks) do
        if v.looks_type == SceneConstData.looktype_weapon then -- 武器
            local data_weapon = DataLook.data_weapon[string.format("%s_%s", looks_val, other_enchant)]
            if data_weapon ~= nil then
                return data_weapon.effect_id
            end

            local data_nomal_weapon_effect = DataLook.data_nomal_weapon_effect[string.format("%s_%s", looks_val, nomal_enchant)]
            if data_nomal_weapon_effect ~= nil then
                return data_nomal_weapon_effect.effect_id
            end
            return 0
        end
    end
end