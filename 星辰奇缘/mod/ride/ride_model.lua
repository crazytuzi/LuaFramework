-- 坐骑数据
-- @ljh 2016.5.24

RideModel = RideModel or BaseClass(BaseModel)

function RideModel:__init()
    self.window = nil

    self.ride_mount = 0
    self.ride_nums = 5
    self.ridelist = {}
    self.cur_ridedata = nil
    self.using_ridedata = nil
    self.show_ridedata = nil
    self.rideDyeWindow = nil

    self.appearance_list = {} -- 坐骑可幻化列表

    self.combat_active_times = {} -- 蛋的孵化值数据，战斗次数

    self.prop_preview_type = 1 --属性预览界面类型
    self.prop_preview_ride_id = 0 --属性预览界面的坐骑id

    self.goal_list = {} -- 坐骑蛋目标

    self.contractPetTab = {}

    self.last_combat_active_times = 0 -- 上次更新孵蛋战斗数据的时间

    -- 可升级
    self.canUpgrade = false
    -- 可激活幻化形象
    self.canActivation = false
    self.rideChooseWindow = nil
    self.rideChooseEndWindow = nil
end

function RideModel:__delete()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function RideModel:OpenWindow(args)

    local roleData = RoleManager.Instance.RoleData
    if roleData.lev < 7 then
        NoticeManager.Instance:FloatTipsByString(TI18N("功能尚未开启"))
        return
    end

    if self:CheckIsEgg() then
        args = nil
    elseif self:CheckIsLowRide() and (args ~= nil and args[1] ~= 5 and args[1] ~= 1) then
        args = nil
    end

    if self.window == nil then
        self.window = RideView.New(self)
    end
    self.window:Open(args)
end


function RideModel:OpenRideChooseWindow(args)
    if self.rideChooseWindow == nil then
        self.rideChooseWindow = RideChooseWindow.New(self)
    end
    self.rideChooseWindow:Open(args)
end

function RideModel:OpenRideChooseEndWindow(args)
    if self.rideChooseEndWindow == nil then
        self.rideChooseEndWindow = RideChooseEndWindow.New(self)
    end
    self.rideChooseEndWindow:Open(args)
end

function RideModel:CloseWindow()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function RideModel:OpenRideEquipWindow(args)
    local roleData = RoleManager.Instance.RoleData
    if DataMount.data_ride_new_data[self.cur_ridedata.base.base_id] == nil then
        if roleData.lev < 75  then
            NoticeManager.Instance:FloatTipsByString(TI18N("功能尚未开启"))
            return
        end
    elseif DataMount.data_ride_new_data[self.cur_ridedata.base.base_id] ~= nil then
        if  RideManager.Instance.rideStatus ~= 2 then
            NoticeManager.Instance:FloatTipsByString(TI18N("功能尚未开启"))
            return
        end

        if roleData.lev < 50  then
            NoticeManager.Instance:FloatTipsByString(TI18N("<color='#ffff00'>50级</color>后激活<color='#00ff00'>逐风彩云</color>，坐骑就能自由飞行了哟~{face_1, 3}"))
            return
        end
    end

    if self:CheckIsEgg() then
        self:OpenWindow()
        return
    end

    if self.rideequip_window == nil then
        self.rideequip_window = RideEquipView.New(self)
    end
    self.rideequip_window:Show(args)
end

function RideModel:CloseRideEquipWindow()
    if self.rideequip_window ~= nil then
        self.rideequip_window:DeleteMe()
        self.rideequip_window = nil
    end
end

function RideModel:OpenRideWashWindow(args)
    local roleData = RoleManager.Instance.RoleData
    if roleData.lev < 75 then
        NoticeManager.Instance:FloatTipsByString(TI18N("功能尚未开启"))
        return
    end

    if self:CheckIsEgg() then
        self:OpenWindow()
        return
    end

    if self.rideWashWindow == nil then
        self.rideWashWindow = RideWashView.New(self)
    end
    self.rideWashWindow:Open(args)
end

function RideModel:CloseRideWashWindow()
    if self.rideWashWindow ~= nil then
        self.rideWashWindow:DeleteMe()
        self.rideWashWindow = nil
    end
end

function RideModel:OpenRidePet(args)
    if self.ridepet == nil then
        self.ridepet = RidePetPanel.New(self)
    end
    self.ridepet:Show(args)
end

function RideModel:CloseRidePet()
    if self.ridepet ~= nil then
        self.ridepet:DeleteMe()
        self.ridepet = nil
    end
end

--打开属性洗髓坐骑选择面板
function RideModel:InitRideSelectUI(args)
    if self.ride_select_win == nil then
        self.ride_select_win = RideSelectView.New(self)
    end
    self.ride_select_win:Show(args)
end

--关闭公会自荐列表面板
function RideModel:CloseRideSelectUI()
    self.ride_select_win:DeleteMe()
    self.ride_select_win = nil
    if self.ride_select_win == nil then
        -- print("===================self.ride_select_win is nil")
    else
        -- print("===================self.ride_select_win is not nil")
    end
end

--打开属性洗髓坐骑选择面板
function RideModel:InitRidePropPreviewUI(_type, _ride_id)
    self.prop_preview_type = _type -- 1:不显示技能。2:显示技能
    self.prop_preview_ride_id = _ride_id
    if self.ride_prop_preview_win == nil then
        self.ride_prop_preview_win = RidePropPreviewWindow.New(self)
        self.ride_prop_preview_win:Show()
    end
end

--关闭公会自荐列表面板
function RideModel:CloseRidePropPreviewUI()
    self.ride_prop_preview_win:DeleteMe()
    self.ride_prop_preview_win = nil
    if self.ride_prop_preview_win == nil then
        -- print("===================self.ride_prop_preview_win is nil")
    else
        -- print("===================self.ride_prop_preview_win is not nil")
    end
end

-- 打开坐骑技能洗炼
function RideModel:OpenRideSkillWash(args)
    if self.rideSkillWash == nil then
        self.rideSkillWash = RideSkillWashWindow.New(self)
    end
    self.rideSkillWash:Open(args)
end


function RideModel:OpenRideSkillPreview()
    if self.skillpreview == nil then
        self.skillpreview = RideSkillPreviewPanel.New(self)
    end
    self.skillpreview:Show()
end

function RideModel:CloseRideSkillPreview()
    if self.skillpreview ~= nil then
        self.skillpreview:DeleteMe()
    end
    self.skillpreview = nil
end

function RideModel:OpenGetRideWindow(args)
    if self.getRideWindow == nil then
        self.getRideWindow = GetRideView.New(self)
    end
    self.getRideWindow:Show(args)
end

function RideModel:CloseGetRideWindow()
    if self.getRideWindow ~= nil then
        self.getRideWindow:DeleteMe()
    end
    self.getRideWindow = nil
end

function RideModel:OpenRideShowWindow(args)
    if self.rideShowWindow == nil then
        self.rideShowWindow = RideShowView.New(self)
    end
    self.rideShowWindow:Show(args)
end

function RideModel:CloseRideShowWindow()
    if self.rideShowWindow ~= nil then
        self.rideShowWindow:DeleteMe()
    end
    self.rideShowWindow = nil
end

function RideModel:OpenRideFeedPanel()
    if self.rideFeedPanel == nil then
        self.rideFeedPanel = RideUseItemPanel.New()
    end
    self.rideFeedPanel:Open()
end

function RideModel:CloseRideFeedPanel()
    if self.rideFeedPanel ~= nil then
        WindowManager.Instance:CloseWindow(self.rideFeedPanel)
    end
end

function RideModel:OpenRideDyeWindow(args)
    if self.rideDyeWindow == nil then
        self.rideDyeWindow = RideDyeWindow.New(self)
    end
    self.rideDyeWindow:Open(args)
end

function RideModel:CloseRideDyeWindow()
    if self.rideDyeWindow ~= nil then
        -- self.rideDyeWindow:DeleteMe()
        WindowManager.Instance:CloseWindow(self.rideDyeWindow)
    end
    -- self.rideDyeWindow = nil
end

------------ 协议 ---------------------

function RideModel:On17000(data)
    self.myRideData = data
    self.myTransfigurationList = self.myRideData.evolution_list
    self.ride_mount = self.myRideData.ride_mount
    self.egg = self.myRideData.egg
    self.tryEgg = 0
	-- self.ridelist = self:getallridedata()

 --    local list = {}
 --    for key,value in pairs(data.mount_list) do
 --        list[value.index] = self:updateridebasedata(value)
 --    end

 --    for key,value in pairs(self.ridelist) do
 --        if list[value.index] ~= nil then
 --            list[value.index].base = value.base
 --            self.ridelist[key] = list[value.index]
 --        end
 --    end
    self.ridelist = {}
    for _,value in ipairs(self.myRideData.mount_list) do
        table.insert(self.ridelist, self:updateridebasedata(value))
    end

    self:makeEgg()
    if self.myRideData.pre_egg == 0 then
        self:tryMakeEgg()
    end

    local function sortfun(a,b)
        return a.index < b.index
    end

    table.sort(self.ridelist, sortfun)

    self.appearance_list = self.myRideData.appearance_list
    self.dye_list = self.myRideData.dye_list
    self.combat_active_times = self.myRideData.combat_active_times
    self.last_combat_active_times = os.date("%d", BaseUtils.BASE_TIME)

    self:update_cur_ridedata()
    self:updateRedPoint()
	RideManager.Instance.OnUpdateRide:Fire()
	-- for _,value in ipairs(self.ridelist) do
	-- 	if value.status == 1 then
	-- 		self.using_ridedata = value
	-- 	end
	-- end
    self:ContractPet()
end



function RideModel:On17008(data)
    for i, goal in ipairs(data.goal_list) do
        local mark = true
        for key,value in pairs(self.goal_list) do
            if goal.id == value.id then
                self.goal_list[key] = goal
                mark = false
            end
        end
        if mark then
            table.insert(self.goal_list, goal)
        end
    end
    if #self.ridelist == 0 then
        self:makeEgg()
    end
    self:updateRedPoint()
end

function RideModel:On17012(data)
    for key,value in ipairs(self.ridelist) do
        if data.index == value.index then
            self.ridelist[key] = self:updateridebasedata(data)
        end
    end
    self:update_cur_ridedata()
    self:updateRedPoint()
    RideManager.Instance.OnUpdateOneRide:Fire()
    self:ContractPet()
end

function RideModel:update_cur_ridedata()
    for key,value in ipairs(self.ridelist) do
        if self.cur_ridedata ~= nil then
            if self.cur_ridedata.index == value.index then
                self.cur_ridedata = value
                return
            end
        else
            -- 初始化
            if self.ride_mount == 0 then
                -- 没骑乘取第一个
                self.cur_ridedata = value
                return
            end

            if value.index == self.ride_mount then
                self.cur_ridedata = value
                return
            end
        end
    end
end

function RideModel:getallridedata()
    local list = {}
    local classes = RoleManager.Instance.RoleData.classes
    for key, value in pairs(DataMount.data_ride_data) do
        if value.classes == classes then
            table.insert(list, { index = value.index, live_status = 0, mount_base_id = value.base_id, base = value })
        end
    end
    return list
end

function RideModel:updateridebasedata(data)
    local lev = data.lev
    if lev == 0 then lev = 1 end
    local basedata = DataMount.data_ride_data[data.mount_base_id]
    if basedata ~= nil then
        data.base = basedata
    end
    return data
end

function RideModel:makeEgg()
    local eggData = { index = 0, lev = 0, live_status = 0, mount_base_id = self.egg, base = { name = TI18N("坐骑蛋"), head_id = 0 } }

    local ride_goal_list = {}
    for _, value in pairs(DataMount.data_ride_goal) do
        if RoleManager.Instance.RoleData.lev >= value.lev and self.egg == value.day and self.egg ~= 0 then
            table.insert(ride_goal_list, value)
        end
    end

    if #ride_goal_list ~= 0 then
        eggData.index = #self.ridelist + 1
        eggData.base.ride_goal_list = ride_goal_list
        table.insert(self.ridelist, eggData)
    end


end

--试用的蛋
function RideModel:tryMakeEgg()
     local eggData = { index = 100, lev = 0, live_status = 0, mount_base_id = 0, base = { name = TI18N("新手蛋"), head_id = 0 } }

     --新手坐骑需要做特殊处理
    local ride_goal_list = {}
    for _, value in pairs(DataMount.data_ride_goal) do
        if RoleManager.Instance.RoleData.lev >= value.lev and value.day == 100 then
            table.insert(ride_goal_list, value)
        end
    end

    if #ride_goal_list ~= 0 then
        eggData.index = #self.ridelist + 1
        eggData.base.ride_goal_list = ride_goal_list
        table.insert(self.ridelist, eggData)
    end
end

--传入坐骑id，获取坐骑完整数据
function RideModel:get_ride_data_by_id(id)
    for key,value in pairs(self.ridelist) do
        if value.mount_base_id == id then
            return value
        end
    end
end

--获取当前没有被管制的宠物列表
function RideModel:get_uncontrol_pet_list()
    local pet_list = {}

    local has_list = {}
    for i=1,#PetManager.Instance.model.petlist do
        local pet_data = PetManager.Instance.model.petlist[i]
        table.insert(has_list, pet_data.base.id)
    end

    local used_list = {}
    for key,value in pairs(self.ridelist) do
        if value.manger_pets ~= nil then
            for i=1,#value.manger_pets do
                used_list[value.manger_pets[i].pet_id] = value.manger_pets[i].pet_id
            end
        end
    end

    for i=1,#has_list do
        if used_list[has_list[i]] == nil then
            table.insert(pet_list, has_list[i])
        end
    end

    return pet_list
end


--传入坐骑id，获取该坐骑所有属性的值
function RideModel:get_ride_all_attr_val(_id)
    local ride_data = self:get_ride_data_by_id(_id)

    return self:get_all_attr_val(ride_data.lev, ride_data.base.classes, ride_data.index, ride_data.growth)
end

--传入坐骑id，获取该坐骑所有属性的值
function RideModel:get_all_attr_val(lev, classes, index, growth)
    local list = {}
    local data_ride_attr = DataMount.data_ride_attr[string.format("%s_%s_%s", lev, classes, index)]
    if data_ride_attr == nil then
        return list
    end

    for i=1,#data_ride_attr.attr do
        local attr_data = data_ride_attr.attr[i]
        if attr_data.attr_name == 3 then
            local attr_val = self:count_ride_attr_val(attr_data.attr_name, attr_data.val1, growth)
            table.insert(list, { key = attr_data.attr_name, value = attr_val})
        else
            local attr_val = self:count_ride_attr_val(attr_data.attr_name, attr_data.val1, growth)
            table.insert(list, { key = attr_data.attr_name, value = attr_val})
        end
    end
    return list
end

--传入坐骑id和属性类型，获取该坐骑对应属性的值
function RideModel:get_ride_attr_val(_id, _type)
    -- local ride_data = self:get_ride_data_by_id(_id)
    -- if _type == 3 then
    --     --移动速度
    --     local cfg_data = DataMount.data_ride_reset[ride_data.speed_lev]
    --     return 1
    -- else
    --     for i=1,#ride_data.base.attr do
    --         local attr_data = ride_data.base.attr[i]
    --         if attr_data.attr_name == _type then
    --             local attr_val = self:count_ride_attr_val(ride_data.base.attr_ratio, attr_data.val1, ride_data.growth)
    --             return attr_val
    --         end
    --     end
    -- end
end

--传入洗髓属性的系数、属性值和成长值计算出对应的属性val
function RideModel:count_ride_attr_val(attr_name, val1, growth)
    local data_ride_reduce = DataMount.data_ride_reduce[growth]
    for i,value in ipairs(data_ride_reduce.attr) do
        if value.attr_name == attr_name then
            return val1*value.percent/1000
        end
    end
    return 0
end

-- 获取坐骑洗出的装备
function RideModel:get_ride_equip_data(base_id, equip_index)
    for _,value in ipairs(DataMount.data_ride_jewelry) do
        if base_id == value.mount_base_id and equip_index == value.type then
            return value
        end
    end
end

-- 获取蛋的任务进度
function RideModel:get_ride_goal(id)
    for _,value in pairs(self.goal_list) do
        if value.id == id then
            return value
        end
    end
    return nil
end

-- 获取第几阶的幻化坐骑列表, step == 0 代表获取所有阶数的
function RideModel:get_ride_transformation_list(step)
    local index = 0
    local transformation_id = 0
    if self.cur_ridedata ~= nil then
        transformation_id = self.cur_ridedata.transformation_id
        index = self.cur_ridedata.index
    end

    local classes = RoleManager.Instance.RoleData.classes
    local list = {}
    for _,value in pairs(DataMount.data_ride_transformation) do
        if (step == 0 or value.index == step) and (value.classes == 0 or value.classes == classes) then
            if self:check_condition_ride(value.pre_condition_ride) then
                local data = BaseUtils.copytab(value)
                local ride_data = BaseUtils.copytab(DataMount.data_ride_data[value.id])
                if ride_data ~= nil then
                    data.base = ride_data
                end

                data.expire_time = 0
                for i=1,#self.appearance_list do
                    if self.appearance_list[i].base_id == data.id then
                        data.active = true
                        data.expire_time = self.appearance_list[i].expire_time
                    end
                end
                if transformation_id == data.id then
                    data.useing = true
                end
                table.insert(list, data)
            end
        end
    end

    -- if index == step then
        local data = {id = self.cur_ridedata.mount_base_id, index = index, color = "#2fc823", mount_lev = 1, classes = 0, access = TI18N("<color='#ffff00'>本职业限定坐骑</color>"), collect_attr = {}}
        data.normal = true
        data.active = true
        local ride_data = BaseUtils.copytab(DataMount.data_ride_data[self.cur_ridedata.mount_base_id])
        if ride_data ~= nil then
            data.base = ride_data
        end
        data.expire_time = 0
        table.insert(list, data)
    -- end

    local function sortfun(a,b)
        return (a.useing and not b.useing)
            or (a.useing == b.useing and (a.normal and not b.normal))
            or (a.useing == b.useing and (a.normal == b.normal) and (a.active and not b.active))
            or (a.useing == b.useing and (a.normal == b.normal) and a.active == b.active and a.id < b.id)
    end

    table.sort(list, sortfun)

    return list
end

-- 获取全部的幻化坐骑列表
function RideModel:get_all_ride_transformation_list()
    local list = {}
    for _,value in pairs(DataMount.data_ride_transformation) do
        local data = BaseUtils.copytab(value)
        local ride_data = BaseUtils.copytab(DataMount.data_ride_data[value.id])
        if ride_data ~= nil then
            data.base = ride_data
        end
        for i=1,#self.appearance_list do
            if self.appearance_list[i].base_id == data.id then
                data.active = true
            end
        end
        if transformation_id == data.id then
            data.useing = true
        end
        table.insert(list, data)
    end

    return list
end

-- 获取所有可用于展示的坐骑(基础坐骑+幻化坐骑)
-- 这功能已被屏蔽
function RideModel:get_all_ride_show_list()
    local list = {}
    for _,value in pairs(DataMount.data_ride_transformation) do
        local data = BaseUtils.copytab(value)
        local ride_data = BaseUtils.copytab(DataMount.data_ride_data[value.id])
        data.normal = false
        if ride_data ~= nil then
            data.base = ride_data
        end

        table.insert(list, data)
    end

    local classes = RoleManager.Instance.RoleData.classes

    if self.cur_ridedata ~= nil and self.cur_ridedata.live_status >= 3 then
        local data = {id = self.cur_ridedata.mount_base_id, index = index, color = "#2fc823", mount_lev = 1, classes = 0, access = TI18N("<color='#ffff00'>本职业限定坐骑</color>"), collect_attr = {}}
        data.normal = true
        data.attr = {}

        -- 表改为key_func了，是遍历不了的
        -- for key, value in pairs(DataMount.data_ride_attr) do
        --     if value.classes == classes and value.lev == self.cur_ridedata.lev then
        --         data.attr = value.attr
        --     end
        -- end

        local ride_data = BaseUtils.copytab(DataMount.data_ride_data[self.cur_ridedata.mount_base_id])
        if ride_data ~= nil then
            data.base = ride_data
        end
        table.insert(list, data)
    else
        local ride_data
        for key, value in pairs(DataMount.data_ride_data) do
            if value.classes == classes and value.base_id % 10 == 2 then
                ride_data = BaseUtils.copytab(value)
            end
        end

        if ride_data ~= nil then
            local data = {id = ride_data.base_id, index = index, color = "#2fc823", mount_lev = 1, classes = 0, access = TI18N("<color='#ffff00'>本职业限定坐骑</color>"), collect_attr = {}}
            data.normal = true
            data.attr = {}

            -- 表改为key_func了，是遍历不了的
            -- for key, value in pairs(DataMount.data_ride_attr) do
            --     if value.classes == classes and value.lev == 1 then
            --         data.attr = value.attr
            --     end
            -- end

            data.base = ride_data
            table.insert(list, data)
        end
    end

    local function sortfun(a,b)
        return a.id < b.id
    end

    table.sort(list, sortfun)
    return list
end

-- 获取技能槽技能列表根据第几阶坐骑来取
function RideModel:get_ride_skill_list(index)
    local temp = {}
    for i,v in ipairs(DataMount.data_ride_skill) do
        if v.index == index then
            local tab = BaseUtils.copytab(v)
            table.insert(temp, tab)
        end
    end
    return temp
end


-- 获取坐骑技能的技能序列
function RideModel:get_ride_skill_subindex(skillid)
    for i,v in pairs(DataMount.data_ride_skill) do
        if v.id == skillid then
            return v.skill_index
        end
    end
end

-- 获取坐骑蛋的孵化数据，战斗次数
function RideModel:get_ride_combat_active_times(combat_type)
    if os.date("%d", BaseUtils.BASE_TIME) ~= self.last_combat_active_times then
        return 0
    end
    for i,v in pairs(self.combat_active_times) do
        if v.combat_type == combat_type then
            return v.fighter_times
        end
    end
    return 0
end

function RideModel:update_item()
    -- local cost = DataMount.data_ride_lev[0].lev_cost[1]
    -- local num = BackpackManager.Instance:GetItemCount(cost[1])
    -- if num > 0 then
        self:updateRedPoint()
    -- end
end

function RideModel:updateRedPoint()
    local mark = false
    --　判断可激活
    if not mark then
        mark = self:updateRedPoint_GetEgg()
    end

    -- 判断可孵化
    if not mark then
        mark = self:updateRedPoint_Egg()
    end

    -- 判断可升级或突破
    if not mark then
        mark = self:updateRedPoint_Upgrade()
    end

    -- 判断可幻化形象可激活
    if not mark then
        mark = self:updateRedPoint_Transformation()
    end

    MainUIManager.Instance.OnUpdateIcon:Fire(35, mark)
end

function RideModel:updateRedPoint_GetEgg()
    local mark = false
    for _,rideData in pairs(self.ridelist) do
        local nofinish = false
        if rideData.base.ride_goal_list ~= nil then
            for i=1, #rideData.base.ride_goal_list do
                local ride_goal_data = rideData.base.ride_goal_list[i]

                local ride_goal = self:get_ride_goal(ride_goal_data.id)
                if ride_goal == nil or ride_goal.finish == 0 then
                    nofinish = true
                    break
                end
            end
            if not nofinish then -- 全部条件达成，则检查物品数量
                local key = string.format("0_%s", rideData.base.ride_goal_list[1].day)
                local cost = DataMount.data_ride_lev[key].lev_cost[1]
                local num = BackpackManager.Instance:GetItemCount(cost[1])
                if num >= cost[2] then
                    mark = true
                    break
                end
            end
        end
    end
    return mark
end

function RideModel:updateRedPoint_Egg()
    local mark = false
    for key,value in pairs(self.ridelist) do
        if value.live_status == 2 then
            mark = true
            break
        end
    end
    return mark
end

function RideModel:updateRedPoint_Upgrade()
    local mark = false
    local role = RoleManager.Instance.RoleData
    for _,rideData in pairs(self.ridelist) do
        if rideData.live_status >= 3 then
            local key = string.format("%s_%s", rideData.lev, rideData.index)
            local levData = DataMount.data_ride_lev[key]
            local nextLevelkey = string.format("%s_%s", rideData.lev+1, rideData.index)
            local nextLevData = DataMount.data_ride_lev[nextLevelkey]
            if levData ~= nil then
                local can = false
                if role.lev_break_times > levData.break_times then
                    can = true
                elseif role.lev_break_times == levData.break_times and role.lev >= levData.role_lev then
                    can = true
                end

                if levData.is_up_lev == 1 and rideData.upgrade_lev ~= rideData.lev then
                    -- 突破
                    local baseId = levData.upgrade_cost[1][1]
                    local num = levData.upgrade_cost[1][2]
                    local has = BackpackManager.Instance:GetItemCount(baseId)
                    if can and has >= num then
                        mark = true
                    end
                else
                    local nextLevelkey = string.format("%s_%s", rideData.lev+1, rideData.index)
                    local nextLevData = DataMount.data_ride_lev[nextLevelkey]
                    if levData.lev_cost[1] ~= nil and nextLevData ~= nil then
                        local baseId = levData.lev_cost[1][1]
                        local num = levData.lev_cost[1][2]
                        local has = BackpackManager.Instance:GetItemCount(baseId)
                        if can and has >= num then
                            mark = true
                        end
                    end
                end
            end
        end
    end
    self.canUpgrade = mark
    return mark
end

function RideModel:updateRedPoint_Transformation()
    local mark = false
    if self:CheckHasRide() then
        local list = self:get_all_ride_transformation_list()
        for _,rideData in pairs(list) do
            if not rideData.active then
                local cost = rideData.synthetise_cost[1]
                if cost ~= nil then
                    local num = BackpackManager.Instance:GetItemCount(cost[1])
                    if num >= cost[2] then
                        mark = true
                    end
                end
            end
        end
    end
    self.canActivation = mark
    return mark
end

-- 已经契约的宠物记录
function RideModel:ContractPet()
    self.contractPetTab = {}
    for _,v in ipairs(self.ridelist) do
        if v.manger_pets ~= nil then
            for _,pet in ipairs(v.manger_pets) do
                self.contractPetTab[pet.pet_id] = v.index
            end
        end
    end
end

-- 宠物面板需要取到对应契约的坐骑进行展示
function RideModel:GetContractRideByPetId(petId)
    local index = self.contractPetTab[petId]
    if index == nil then
        return nil
    end

    for i,v in ipairs(self.ridelist) do
        if v.index == index then
            return BaseUtils.copytab(v)
        end
    end
    return nil
end

-- 检查是不是蛋，如果是就只能打开主界面
function RideModel:CheckIsEgg()
    if self.cur_ridedata ~= nil and self.cur_ridedata.live_status < 3 then
        return true
    end
    return false
end

-- 检查当前坐骑是不是新手坐骑，如果是就只能打开信息和幻化两个次级页签
function RideModel:CheckIsLowRide()
    if self.cur_ridedata ~= nil and DataMount.data_ride_new_data[self.cur_ridedata.mount_base_id] ~= nil then
        return true
    end
    return false
end

-- 在背包使用坐骑口粮
function RideModel:UseFood()
    local rideData = self.cur_ridedata
    if rideData == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("这是坐骑吃的东西哦，请先驯养一只坐骑吧{face_1, 14}"))
    else

    end
end

-- 检查坐骑列表里面是否有孵化的坐骑
function RideModel:CheckHasRide()
    local result = false
    for k,v in pairs(self.ridelist) do
        if v.live_status >= 3 then
            result = true
        end
    end
    return result
end

-- 检查坐骑列表里面是否有孵化的坐骑(不算新手坐骑)
function RideModel:CheckHasRideEx()
    local result = false
    for k,v in pairs(self.ridelist) do
        if v.live_status >= 3 and DataMount.data_ride_new_data[v.base.base_id] == nil then
            result = true
        end
    end
    return result
end



-- 检查坐骑列表里面是否有孵化的坐骑
function RideModel:CheckRideCanUpgrade_Level()
    local message = ""
    local data_ride_lev = DataMount.data_ride_lev[string.format("%s_%s", self.cur_ridedata.lev, self.cur_ridedata.index)]
    local roleData = RoleManager.Instance.RoleData
    if data_ride_lev ~= nil and ((roleData.lev_break_times > data_ride_lev.break_times) or (roleData.lev_break_times == data_ride_lev.break_times and roleData.lev >= data_ride_lev.role_lev)) then
        return true, message
    end

    if data_ride_lev ~= nil then
        if data_ride_lev.break_times == 0 then
            message = string.format(TI18N("%s级"), data_ride_lev.role_lev)
        elseif data_ride_lev.break_times == 1 then
            message = string.format(TI18N("突破%s级"), data_ride_lev.role_lev)
        end
    end
    return false, message
end

-- 检查是否已拥有前置坐骑
function RideModel:check_condition_ride(condition_ride_list)
    if #condition_ride_list == 0 then
        return true
    end
    for _, condition_ride_id in ipairs(condition_ride_list) do
        for rideIndex, rideData in ipairs(self.ridelist) do
            if condition_ride_id == rideData.mount_base_id then
                return true
            end
        end
    end
    return false
end

-- 坐骑获取坐骑契约栏开启数量
function RideModel:GetContractData(index, growth)
    local num = 0
    local maxNum = 0
    local nextGrowth = 0
    local nextNum = 0
    local openSlotData = {}

    for _, data_ride_contract in ipairs(DataMount.data_ride_contract) do
        if index == data_ride_contract.index and growth >= data_ride_contract.growth then
            if num < data_ride_contract.num then
                num = data_ride_contract.num
            end
        end

        if index == data_ride_contract.index then
            if maxNum < data_ride_contract.num then
                maxNum = data_ride_contract.num
            end
        end

        if index == data_ride_contract.index and growth < data_ride_contract.growth then
            if nextNum == 0 or nextNum > data_ride_contract.num then
                nextNum = data_ride_contract.num
                nextGrowth = data_ride_contract.growth
            end

            if openSlotData[data_ride_contract.num] == nil then
                openSlotData[data_ride_contract.num] = { num = data_ride_contract.num, growth = data_ride_contract.growth }
            end
        end
    end
    return { num = num, maxNum = maxNum, nextGrowth = nextGrowth, nextNum = nextNum, openSlotData = openSlotData }
end

-- 获取幻化染色，如果没有染色则直接返回幻化id
function RideModel:GetTransformationDye(transformation_id)
    for index, value in ipairs(self.dye_list) do
        if transformation_id == value.trans_id and value.dye_id ~= 0 then
            self.isSet = true
            return value.dye_id
        end
    end
    return transformation_id
end

-- 获取幻化染色
function RideModel:GetDyeData(transformation_id)
    for index, value in ipairs(self.dye_list) do
        if transformation_id == value.trans_id then
            return value
        end
    end
    return nil
end

-- 获取幻化染色
function RideModel:MakeRideLook(rideData)
    local look = rideData.base.base_id
    self.isSet = false
    if rideData.transformation_id ~= 0 then
        look = self:GetTransformationDye(rideData.transformation_id)
        if self.isSet == false then
            look = self:GetTransfigurationDataById(rideData.transformation_id)
        end
    end
    local _scale = DataMount.data_ride_data[look].scale / 100 * 1.6
    local data = {type = PreViewType.Ride, classes = 1, sex = 1, looks = {}, scale = _scale, effects = {}}
    table.insert(data.looks, { looks_type = SceneConstData.looktype_ride, looks_val = look })
    return data
end


function RideModel:GetTransfigurationData(transformation_id)
    for k,value in pairs(self.myTransfigurationList) do
        if transformation_id == value.trans_id then
            return value
        end
    end
    return nil
end

-- 获取变换染色，如果没有染色则直接返回幻化id
function RideModel:GetTransfigurationDataById(transformation_id)
    for k,value in pairs(self.myTransfigurationList) do
        if transformation_id == value.trans_id then
            return value.evolution_id
        end
    end
    return transformation_id
end

-- 检查是不是多人坐骑(id为空返回当前坐骑的数据)
function RideModel:CheckIsMultiplayerRide(id)
    id = id or (self.cur_ridedata or {}).transformation_id
    if id ~= nil and DataMount.data_ride_data[id] ~= nil and DataMount.data_ride_data[id].multiplayer == 1 then
        return true
    end
    return false
end

--检查当前坐骑是否有飞行道具
function RideModel:CheckFly()
    local isCan = false
    local decorate = self.cur_ridedata.decorate_list
    for i,v in pairs(decorate) do
        if v.decorate_index == 2 then
            isCan = true
        end
    end
    return isCan
end