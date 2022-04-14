-- 
-- @Author: LaoY
-- @Date:   2018-08-15 15:32:48
-- 
MainBottomRight = MainBottomRight or class("MainBottomRight", BaseItem)
local MainBottomRight = MainBottomRight

function MainBottomRight:ctor(parent_node, layer)
    self.abName = "main"
    self.assetName = "MainBottomRight"
    self.layer = layer

    self.model = MainModel:GetInstance()
    self.switch_state = false
    self.skill_list = {}
    self.normal_list = {}
    self.isLimitSkillSlot = false
    self.isShowLittleAngle = false
    self.is_show_stronger_eft = true

    self.isInCandy = false;

    MainBottomRight.super.Load(self)
end

function MainBottomRight:dctor()
    if self.stronger_eft then
        self.stronger_eft:destroy()
        self.stronger_eft = nil
    end
    if self.stronger_rd then
        self.stronger_rd:destroy()
        self.stronger_rd = nil
    end

    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end

    if self.event_tab then
        GlobalEvent:RemoveTabListener(self.event_tab)
        self.event_tab = nil
    end

    self:StopAction()
    if self.skill_list then
        for k, item in pairs(self.skill_list) do
            item:destroy()
        end
        self.skill_list = {}
    end

    if self.normal_list then
        for k, item in pairs(self.normal_list) do
            item:destroy()
        end
        self.normal_list = {}
    end

    if self.role_update_list and self.role_data then
        self.role_data:RemoveTabListener(self.role_update_list)
        self.role_update_list = {}
    end

    if self.rightIconList then
        for i, v in pairs(self.rightIconList) do
            if v then
                v:destroy()
            end
        end
    end

    self.rightIconList = {}

end


function MainBottomRight:CreateItem(obj)
    MainBottomRight.super.CreateItem(self, obj)
    BagModel.GetInstance():SetBagPos(self.btn_bag)
end

function MainBottomRight:LoadCallBack()
    self.nodes = {
        "btn_bag", "btn_main_switch", "btn_role", "btn_select", "btn_select_bg",
        "img_btn_fairy", "btn_stronger", "btn_stronger/red_con",
        "btn_dancing", "btn_dance",
    }
    self:GetChildren(self.nodes)
    self:AddEvent()
    self:BindRoleUpdate()

    self.img_btn_fairy_component = self.img_btn_fairy:GetComponent('Image')

    self:LoadSkill()
    self:LoadNormal()
    self:UpdateFairy()
    if not self.stronger_rd then
        self.stronger_rd = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.stronger_rd:SetPosition(25, 27)
    self.stronger_rd:SetRedDotParam(true)
    
    -- ffh 刘海屏适配
    self:checkAdaptUI()
    
    self.btn_select_pos_x, self.btn_select_pos_y = GetLocalPosition(self.btn_select)
    self.btn_select_bg_pos_x, self.btn_select_bg_pos_y = GetLocalPosition(self.btn_select_bg)

    self.btn_select_component = self.btn_select:GetComponent('Image')
    self.btn_select_bg_component = self.btn_select_bg:GetComponent('Image')

    self.btn_select_hide_x = self.btn_select_pos_x + DesignResolutionWidth / 2
    self.btn_select_bg_hide_x = self.btn_select_bg_pos_x + DesignResolutionWidth / 2

    local roleInfoData = RoleInfoModel.GetInstance():GetMainRoleData()
    if roleInfoData.guild ~= "0" then
        GlobalEvent:Brocast(FactionEvent.RequestMember)
    end

    --跳舞UI相关
    self.btn_dance_pos_x, self.btn_dance_pos_y = GetLocalPosition(self.btn_dance)
    self.btn_dance_hide_x = self.btn_dance_pos_x + DesignResolutionWidth / 2

    --初始场景在糖果屋 需要隐藏技能
    local cur_scene_id = SceneManager:GetInstance():GetSceneId()
    self.isInCandy = cur_scene_id == 30342 or cur_scene_id == 30341
    if self.isInCandy then
        for k, item in pairs(self.skill_list) do
            item:SetVisibleWithLoaded(false)
        end
        SetVisible(self.btn_select_bg, false)
        SetVisible(self.btn_select, false)
        SetVisible(self.btn_dance, not self.is_dance_state)
        SetVisible(self.btn_dancing, self.is_dance_state)
    end
    
    --进入糖果屋后自动切换到跳舞
    local main_role = SceneManager:GetInstance():GetMainRole();
    local function call_back(action_name)
        if action_name == SceneConstant.ActionName.Fly2 then
            local cur_scene_id = SceneManager:GetInstance():GetSceneId()
            self.isInCandy = cur_scene_id == 30342 or cur_scene_id == 30341
            if self.isInCandy then
                self:StartDance()
            end
        end
    end
    main_role.fly_down_on_exit_call_back = call_back
  
end

function MainBottomRight:checkAdaptUI()

    UIAdaptManager:GetInstance():AdaptUIForBangScreenLeft(self.btn_select)
    UIAdaptManager:GetInstance():AdaptUIForBangScreenLeft(self.btn_select_bg)

end

function MainBottomRight:AddEvent()
    --EquipController.Instance:RequestEquipList()
    --BagController.Instance:RequestBagInfo(BagModel.bagId)
    local function call_back(target, x, y)
        --背包事件
        GlobalEvent:Brocast(BagEvent.OpenBagPanel, 1)
        --OpenLink(101,1,1)
    end
    AddClickEvent(self.btn_bag.gameObject, call_back)

    local function call_back(target, x, y)
        --切换目标
        SceneManager:GetInstance():SwitchLockCreep()
    end
    AddClickEvent(self.btn_select.gameObject, call_back)

    local function call_back(target, x, y)
        local fairy_id = EquipModel:GetInstance():GetEquipDevil()
        if fairy_id then
            local fairy_type = EquipModel:GetInstance():GetFairyType(fairy_id)
            local same_type_uid, same_type_index = EquipModel:GetInstance():GetSameFairyTypeMaxUid()
            local other_type_uid, other_type_index = EquipModel:GetInstance():GetOtherFairyTypeUid()
            if same_type_index then
                if not other_type_index or same_type_index >= other_type_uid then
                    -- 升级
                    EquipController:GetInstance():RequestPutOnEquip(same_type_uid)
                else
                    -- 切换
                    EquipController:GetInstance():RequestPutOnEquip(other_type_uid)
                end
            elseif other_type_index then
                -- 切换
                EquipController:GetInstance():RequestPutOnEquip(other_type_uid)
            else

                local item_id
                -- 跳转购买
                if fairy_type == EquipModel.FairyType.Devil then
                    -- 购买天使
                    item_id = EquipModel.FairyList[EquipModel.FairyType.Angel][1]
                else
                    -- 购买恶魔
                    item_id = EquipModel.FairyList[EquipModel.FairyType.Devil][1]
                end
                local config = Config.db_fairy[item_id]
                UnpackLinkConfig("180@1@2@2@" .. config.mall)
            end
        else
            local uid = EquipModel:GetInstance():GetBagFairUid()
            if uid then
                -- 穿戴
                EquipController:GetInstance():RequestPutOnEquip(uid)
            else
                local item_id = EquipModel.FairyList[EquipModel.FairyType.Devil][1]
                -- 默认购买恶魔
                local config = Config.db_fairy[item_id]
                UnpackLinkConfig("180@1@2@2@" .. config.mall)
            end
        end
    end
    AddClickEvent(self.img_btn_fairy.gameObject, call_back)

    EquipSuitModel.GetInstance():CleanActiveSuit()
    EquipController.Instance:RequestEquipSuit(1)
    EquipController.Instance:RequestEquipSuit(2)
    EquipController.Instance:RequestStrongSuite()

    -- local function call_back(target,x,y)                  --强化事件
    -- 	GlobalEvent:Brocast(EquipEvent.ShowEquipUpPanel,1)
    -- end
    -- AddClickEvent(self.btn_strong.gameObject,call_back)

    -- local function call_back(target,x,y)                  --强化事件
    -- 	GlobalEvent:Brocast(EquipEvent.ShowEquipCombinePanel,1)
    -- end
    -- AddClickEvent(self.btn_combine.gameObject,call_back)

    GlobalEvent:Brocast(EquipEvent.RequestEquipList)
    -- local function call_back(target,x,y)                  --角色属性事件
    -- 	GlobalEvent:Brocast(RoleInfoEvent.OpenRoleInfoPanel,1)
    -- end
    -- AddClickEvent(self.btn_role.gameObject,call_back)

    self.event_tab = self.event_tab or {}
    self.events = self.events or {}

    local function call_back(...)
        --Yzprint('--LaoY MainBottomRight.lua,line 98-- data=',...,os.clock())
    end
    self.event_tab[#self.event_tab + 1] = GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)

    local function call_back(id)
        -- Yzprint('--LaoY MainBottomRight.lua,line 116-- id=', id)
        self:LoadNormal()
    end
    self.event_tab[#self.event_tab + 1] = GlobalEvent:AddListener(EventName.UpdateOpenFunction, call_back)

    local function call_back(key_str, param, sign)
        if "bag" == key_str then
            self:UpdateBagRedDot()
        end
    end
    --self.event_tab[#self.event_tab + 1] = self.model:AddListener(MainEvent.UpdateRedDot, call_back)
    self.event_tab[#self.event_tab + 1] = GlobalEvent:AddListener(MainEvent.ChangeRedDot, call_back)

    local function call_back()
        self:SceneChangeEndFun()
    end
    self.event_tab[#self.event_tab + 1] = GlobalEvent:AddListener(EventName.ChangeSceneEnd, call_back)

    --监听人物跳舞动画切换
    local function call_back(state_name, flag)
        if state_name == SceneConstant.ActionName.dance1 or state_name == SceneConstant.ActionName.dance2 then
            self.is_dance_state = flag
            SetVisible(self.btn_dance, not self.is_dance_state)
            SetVisible(self.btn_dancing, self.is_dance_state)
        end
    end
    self.event_tab[#self.event_tab + 1] = GlobalEvent:AddListener(SceneEvent.MainRoleMachineStateUpdate, call_back)

    local function call_back(state, id)
        if state == MainModel.OpenFunctionState.Start then
            if self.switch_state then
                self:Switch(not self.switch_state)
            end
            self:SetNormalIconVisible(id, false)
        elseif state == MainModel.OpenFunctionState.End then
            self:SetNormalIconVisible(id, true)
        end
    end
    -- self.event_tab[#self.event_tab+1] = GlobalEvent:AddListener(EventName.OpenFunctionState, call_back)

    --local function call_back()
    --    self:UpdateFairy()
    --end
    --self.event_tab[#self.event_tab + 1] = GlobalEvent:AddListener(EventName.ChangeSceneEnd, call_back)

    local function call_back(slot, data)
        if slot == enum.ITEM_STYPE.ITEM_STYPE_FAIRY then
            self:UpdateFairy()
        end
    end
    self.event_tab[#self.event_tab + 1] = GlobalEvent:AddListener(EquipEvent.PutOnEquip, call_back)

    local function call_back(target, x, y)
        if self:IsInAction(self.skill_list) or self:IsInAction(self.normal_list) then
            return
        end
        self:Switch(not self.switch_state)

        --if self.isLimitSkillSlot then
        --  Notify.ShowText("糖果屋场景内不可攻击")
        --end

    end
    AddClickEvent(self.btn_main_switch.gameObject, call_back)
    local function callback(flag)
        flag = false
        if flag then
            -- SetVisible(self.img_btn_fairy, true)
            SetVisible(self.img_btn_fairy, false)
            self.isShowLittleAngle = true
        else
            SetVisible(self.img_btn_fairy, false)
            self.isShowLittleAngle = false
        end
    end
    self.event_tab[#self.event_tab + 1] = GlobalEvent:AddListener(MainEvent.SwitchLittleAngleShow, callback)

    --变强etc
    local function callback()
        -- self.is_show_stronger_eft = false
        lua_panelMgr:GetPanelOrCreate(StrongerPanel):Open()
    end
    AddClickEvent(self.btn_stronger.gameObject, callback)
    local function callback(cf_id, is_add)
        if is_add then
            local stro_cf = Config.db_stronger[cf_id]
            if not stro_cf then
                return
            end
            local tbl = String2Table(stro_cf.jump)
            local last = tbl[#tbl]
            if last == "true" then
                local id = tbl[1]
                local sub_id = stro_cf.sub_id
                if not Config.db_sysopen[id .. "@" .. sub_id] then
                    logError("在变强的显示判断中， SysOpen中没有这个配置:", id, "@", sub_id, " 这个系统就会不显示")
                    return
                end
                if not OpenTipModel.GetInstance():IsOpenSystem(id, sub_id) then
                    return
                end
            end
            if self.model:CheckSysExist(cf_id) then
                return
            end
            self.model:SetStrongerSys(cf_id)
            self:CheckIsShowStronger()
        else
            if not self.model:CheckSysExist(cf_id) then
                return
            end
            self.model:DelStrongerSys(cf_id)
            self:CheckIsShowStronger()
        end
    end
    self.event_tab[#self.event_tab + 1] = GlobalEvent:AddListener(MainEvent.ChangeSystemShowInStronger, callback)
    self.role_update_list = self.role_update_list or {}
    self.role_update_list[#self.role_update_list + 1] = RoleInfoModel.GetInstance():GetMainRoleData():BindData("level", callback)

    local function callback()
        self:UpdateMachineArmorBuff()
    end
    self.role_update_list[#self.role_update_list + 1] = RoleInfoModel.GetInstance():GetMainRoleData():BindData("buffs", callback)


    --跳舞按钮
    local function callback()
        self:ChangeDanceState();
    end
    AddButtonEvent(self.btn_dance.gameObject, callback)
    AddButtonEvent(self.btn_dancing.gameObject, callback)

    --默认隐藏跳舞按钮
    SetVisible(self.btn_dance, false)
    SetVisible(self.btn_dancing, false)
end

function MainBottomRight:CheckIsShowStronger()
    local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    if self.model:GetStrongSysNum() > 0 and lv >= 60 then
        SetVisible(self.btn_stronger, true)
        if not self.stronger_eft and self.is_show_stronger_eft then
            self.stronger_eft = UIEffect(self.btn_stronger, 10201, false)
        end
    else
        SetVisible(self.btn_stronger, false)
    end
end

function MainBottomRight:UpdateFairy()
    -- 临时处理
    do
        SetVisible(self.img_btn_fairy, false)
        return
    end
    local scene_type = SceneConfigManager:GetInstance():GetSceneType()
    if scene_type == SceneConstant.SceneType.Feild or scene_type == SceneConstant.SceneType.City then
        SetVisible(self.img_btn_fairy, false)
        return
    end
    if self.model.isShowPredi == false or self.isShowLittleAngle then
        -- SetVisible(self.img_btn_fairy, true)
        SetVisible(self.img_btn_fairy, false)
    end
    local fairy_id = EquipModel:GetInstance():GetEquipDevil()
    if fairy_id then
        local fairy_type = EquipModel:GetInstance():GetFairyType(fairy_id)
        local same_type_uid, same_type_index = EquipModel:GetInstance():GetSameFairyTypeMaxUid()
        local other_type_uid, other_type_index = EquipModel:GetInstance():GetOtherFairyTypeUid()
        if same_type_index then
            if not other_type_index or same_type_index >= other_type_uid then
                -- 升级
                if fairy_type == EquipModel.FairyType.Devil then
                    self:LoadFairyImage("img_btn_devil")
                else
                    self:LoadFairyImage("img_btn_angel")
                end
            else
                -- 切换
                if fairy_type == EquipModel.FairyType.Devil then
                    self:LoadFairyImage("img_btn_devil")
                else
                    self:LoadFairyImage("img_btn_angel")
                end
            end
        elseif other_type_index then
            -- 切换
            if fairy_type == EquipModel.FairyType.Devil then
                self:LoadFairyImage("img_btn_devil")
            else
                self:LoadFairyImage("img_btn_angel")
            end
        else
            -- 跳转购买 另外一个
            if fairy_type == EquipModel.FairyType.Devil then
                -- 购买天使
                self:LoadFairyImage("img_btn_devil")
            else
                -- 购买恶魔
                self:LoadFairyImage("img_btn_angel")
            end
        end
    else
        local uid = EquipModel:GetInstance():GetBagFairUid()
        if uid then
            -- 穿戴
            if fairy_type == EquipModel.FairyType.Devil then
                self:LoadFairyImage("img_btn_devil")
            else
                self:LoadFairyImage("img_btn_angel")
            end
        else
            -- 购买默认 配置
            if fairy_type == EquipModel.FairyType.Devil then
                self:LoadFairyImage("img_btn_devil")
            else
                self:LoadFairyImage("img_btn_angel")
            end
        end
    end
end

function MainBottomRight:LoadFairyImage(assetName)
    local abName = 'main_image'
    if self.fairy_assetName == assetName then
        return
    end
    self.fairy_assetName = assetName
    lua_resMgr:SetImageTexture(self, self.img_btn_fairy_component, abName, assetName, true)
end

function MainBottomRight:BindRoleUpdate()
    self.role_data = RoleInfoModel:GetInstance():GetMainRoleData()
    local function call_back()
        -- self:SetLevel()
        self:LoadNormal()
    end
    -- self.role_update_list[#self.role_update_list+1] = self.role_data:BindData("level",call_back)
end

function MainBottomRight:GetBagTransform()
    if not self.is_loaded then
        return
    end
    return self.btn_bag
end

--右下角切页
function MainBottomRight:Switch(switch_state)

    --print("右下角切页，当前状态：" .. tostring(switch_state))

    local is_action = false
    local time = 0.25
    local delay_time = 0
    local action
    local btn_select_action
    local btn_select_bg_action

    local btn_dance_action
    local btn_dancing_action

    if switch_state then

        action = cc.RotateTo(time, 90)

        --跳舞和技能一起隐藏

        --跳舞
        local delay_action = cc.DelayTime(delay_time)
        local moveAction = cc.MoveTo(time, self.btn_dance_hide_x, self.btn_dance_pos_y, 0)
        local function end_call_back()
            SetVisible(self.btn_dance, false)
        end
        local call_action = cc.CallFunc(end_call_back)
        btn_dance_action = cc.Sequence(delay_action, moveAction, call_action);

        --跳舞中
        local delay_action = cc.DelayTime(delay_time)
        local moveAction = cc.MoveTo(time, self.btn_dance_hide_x, self.btn_dance_pos_y, 0)
        local function end_call_back()
            SetVisible(self.btn_dancing, false)
        end
        local call_action = cc.CallFunc(end_call_back)
        btn_dancing_action = cc.Sequence(delay_action, moveAction, call_action);

        for k, item in pairs(self.skill_list) do
            item:StartAction(delay_time, time, item.hide_pos, false)
        end

        local delay_action = cc.DelayTime(delay_time)
        local moveAction = cc.MoveTo(delay_time, self.btn_select_hide_x, self.btn_select_pos_y, 0)
        local function end_call_back()
            SetVisible(self.btn_select, false)
        end
        local call_action = cc.CallFunc(end_call_back)
        btn_select_action = cc.Sequence(delay_action, moveAction, call_action)

        local delay_action = cc.DelayTime(delay_time)
        local moveAction = cc.MoveTo(delay_time, self.btn_select_bg_hide_x, self.btn_select_bg_pos_y, 0)
        local function end_call_back()
            SetVisible(self.btn_select_bg, false)
        end
        local call_action = cc.CallFunc(end_call_back)
        btn_select_bg_action = cc.Sequence(delay_action, moveAction, call_action)


        --显示normal按钮
        is_action = self:IsInAction(self.normal_list)

        for i = 1, #self.normal_list do
            local item = self.normal_list[i]
            if not is_action then
                delay_time = (MainBottomRightItem.list_count - item.line) * 0.15 + time
            else
                delay_time = 0
            end
            item:StartAction(delay_time, time, item.start_pos, true)
        end

    else

        action = cc.RotateTo(time, 0)

        --隐藏normal按钮
        for i = 1, #self.normal_list do
            local item = self.normal_list[i]
            item:StartAction(delay_time, time, item.hide_pos, false)
        end

        --改变跳舞的显示状态（根据是否在糖果屋内和是否跳舞中来决定是否显示）
        SetVisible(self.btn_dance, self.isInCandy and not self.is_dance_state)
        SetVisible(self.btn_dancing, self.isInCandy and self.is_dance_state)

        local delay_action = cc.DelayTime(delay_time)
        local moveAction = cc.MoveTo(time, self.btn_dance_pos_x, self.btn_dance_pos_y, 0)

        btn_dance_action = cc.Sequence(delay_action, moveAction);

        local delay_action = cc.DelayTime(delay_time)
        local moveAction = cc.MoveTo(time, self.btn_dance_pos_x, self.btn_dance_pos_y, 0)

        btn_dancing_action = cc.Sequence(delay_action, moveAction);

        is_action = self:IsInAction(self.skill_list)
        if not is_action then
            delay_time = time
        end
        for k, item in pairs(self.skill_list) do
            item:StartAction(delay_time, time, item.start_pos, not self.isInCandy)
        end

        SetVisible(self.btn_select, not self.isInCandy)
        local delay_action = cc.DelayTime(delay_time)
        local moveAction = cc.MoveTo(time, self.btn_select_pos_x, self.btn_select_pos_y, 0)
        btn_select_action = cc.Sequence(delay_action, moveAction)

        SetVisible(self.btn_select_bg, not self.isInCandy)
        local delay_action = cc.DelayTime(delay_time)
        local moveAction = cc.MoveTo(time, self.btn_select_bg_pos_x, self.btn_select_bg_pos_y, 0)
        btn_select_bg_action = cc.Sequence(delay_action, moveAction)


    end
    -- btn_main_switch
    self:StopAction()
    cc.ActionManager:GetInstance():addAction(action, self.btn_main_switch)

    cc.ActionManager:GetInstance():addAction(btn_select_action, self.btn_select)
    cc.ActionManager:GetInstance():addAction(btn_select_bg_action, self.btn_select_bg)
    cc.ActionManager:GetInstance():addAction(btn_dance_action, self.btn_dance)
    cc.ActionManager:GetInstance():addAction(btn_dancing_action, self.btn_dancing)
    self.switch_state = switch_state
    GlobalEvent:Brocast(MainEvent.SwithRight, self.switch_state)
end

function MainBottomRight:StopAction()
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.btn_main_switch)
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.btn_select)
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.btn_select_bg)
end

function MainBottomRight:IsInAction(list)
    if table.isempty(list) then
        return false
    end
    for k, cls in pairs(list) do
        if cc.ActionManager:GetInstance():isTargetInAction(cls.transform) then
            return true
        end
    end
    return false
end

function MainBottomRight:UpdateMachineArmorBuff()
    local buff_id = RoleInfoModel:GetInstance():GetMainRoleData():IsHaveBuffEffectType(enum.BUFF_EFFECT.BUFF_EFFECT_MECHA_MORPH)    
    local bo = toBool(buff_id)
    if self.machine_armor_buff_flag == bo then
        return
    end
    -- test
    -- if self.machine_armor_buff_flag then
    --     return
    -- end
    self:LoadSkill()
    self:UpateSelImage()
end

function MainBottomRight:UpateSelImage()
    if self.machine_armor_buff_flag then
        lua_resMgr:SetImageTexture(self, self.btn_select_component, "machinearmor_scene_image", "img_select_icon",false,nil,false)
        lua_resMgr:SetImageTexture(self, self.btn_select_bg_component, "machinearmor_scene_image", "img_select_icon_bg",false,nil,false)
    else
        lua_resMgr:SetImageTexture(self, self.btn_select_component, "main_image", "img_select_icon",false,nil,false)
        lua_resMgr:SetImageTexture(self, self.btn_select_bg_component, "main_image", "img_select_icon_bg",false,nil,false)
    end
end

function MainBottomRight:LoadSkill()
    local buff_id = RoleInfoModel:GetInstance():GetMainRoleData():IsHaveBuffEffectType(enum.BUFF_EFFECT.BUFF_EFFECT_MECHA_MORPH)
    self.machine_armor_buff_flag = toBool(buff_id)
    local pos_list
    if self.machine_armor_buff_flag then
        pos_list = {
            [1] = { 550, -272 },
            [2] = { 412, -301 },
            [3] = { 452, -200 }, --3
            [4] = { 547, -145 }, --4
        }
    else
        pos_list = {
            [1] = { 551, -263 },
            [2] = { 436, -303 },
            [3] = { 447, -215 }, --3
            [4] = { 513, -150 }, --4
            [5] = { 597, -120 }, --5
            [6] = { 345, -303 }, --2
            [7] = { 254, -303 },
            [8] = { 254, -215 },
            [9] = { 345, -216 },
            [14] = {418, -126},
        }
    end

    -- 107
    -- 100
    -- 普攻算1
    -- local line_row_list = {
    --     [2] = { 2, 3 },
    --     [3] = { 2, 2 },
    --     [4] = { 3, 1 },
    --     [5] = { 4, 1 },
    --     [6] = { 1, 3 },
    --     [7] = { 1, 2 },
    --     [8] = { 1, 1 },
    --     [9] = { 2, 1 },
    -- }

    -- for k, v in pairs(line_row_list) do
    --     local x = 172 + v[1] * 105
    --     local y = -28 - v[2] * 93
    --     pos_list[k] = { x, y }
    -- end

    local offx = DesignResolutionWidth / 2
	
	for k,item in pairs(self.skill_list) do
		item:destroy()
		self.skill_list[k] = nil
	end
	
    for i,v in pairs(pos_list) do
        local skill_item
        if i == 1 then
            skill_item = MainSkillItem(self.transform)
            skill_item:SetSkillIndex(i - 1,self.machine_armor_buff_flag)
            skill_item:SetType(MainSkillItem.SkillType.Nor)
        elseif i <= 9 then
            skill_item = MainSkillItem(self.transform)
            skill_item:SetSkillIndex(i - 1,self.machine_armor_buff_flag)
			skill_item:SetType(MainSkillItem.SkillType.Skill)
        elseif i == 14 then
            --怒气技能
            skill_item = AngerSkillItem(self.transform)
        end
        local pos = pos_list[i]
        if pos then
            --ffh 刘海屏适配
            if skill_item.IsNorAttack and skill_item:IsNorAttack() then
                pos[1] = pos[1] + UIAdaptManager:GetInstance():GetBanScreenOffsetX()
            end
            
            skill_item:SetStartPos(pos[1], pos[2])
            skill_item:SetHidePos(pos[1] + offx, pos[2])
            if self.switch_state then
                skill_item:SetPosition(pos[1] + offx, pos[2])
            else
                skill_item:SetPosition(pos[1], pos[2])
            end
        end
        skill_item:SetIndex(i)
        skill_item:SetData()
        self.skill_list[i] = skill_item
    end

    -- self.btn_select:SetAsLastSibling()
    -- self.btn_select:SetAsFirstSibling()
end

function MainBottomRight:SetNormalIconVisible(id, flag)
    for k, item in pairs(self.normal_list) do
        if item.config.id == id then
            item:SetVisible(flag)
        end
    end
end

function MainBottomRight:LoadNormal()
    local list = {}
    self.rightIconList = self.rightIconList or {}
    -- for i=1,13 do
    -- 	list[i] = i
    -- end
    for k, v in pairs(IconConfig.BottomRightConfig) do
        -- if IsOpenModular(v.level,v.task) then
        if OpenTipModel:GetInstance():IsOpenSystem(v.id, v.sub_id) or v.id == 999 or v.id == 1100 then
            list[#list + 1] = v
        end
    end
    local function sortFunc(a, b)
        return a.index < b.index
    end
    table.sort(list, sortFunc)

    local width = 82
    local height = 94
    local list_count = MainBottomRightItem.list_count
    local line_count = MainBottomRightItem.line_count
    local count = 0
    local start_pos = { 596, -311 }
    local offx = MainBottomRightItem.line_count * width
    for i = 1, #list do
        local vo = list[i]
        local item = self.normal_list[i]
        if not item then
            item = MainBottomRightItem(self.transform)
            self.normal_list[i] = item
            local line, line_index
            line = (i - 1) % list_count + 1
            line = list_count - line + 1
            line_index = math.floor((i - 1) / list_count) + 1
            local x = (1 - line_index) * width + start_pos[1]
            local y = (line - 1) * height + start_pos[2]
            item:SetVisible(self.switch_state)
            item:SetStartPos(x, y)
            item:SetHidePos(x + offx, y)
            if vo.id == 860 and vo.sub_id == 1 then
                --logError("Main Bottom Right", self.switch_state)
            end
            if self.switch_state then
                item:SetPosition(x, y)
            else
                item:SetPosition(x + offx, y)
            end
            item:SetLineIndex(line, line_index)
        end
        item:SetData(vo)
        if OpenTipModel.GetInstance():IsNeedMove(vo.id, vo.sub_id) then
            self:Switch(true)
            item:SetPosition(item.start_pos.x, item.start_pos.y)
            item:SetVisible(false)
        end
        self.rightIconList[vo.key_str] = item
    end
end

function MainBottomRight:SetData(data)

end

--获取技能孔位置
function MainBottomRight:GetSkillSlotPos(pos)
    pos = pos + 1
    local pos = self.skill_list[pos].transform.anchoredPosition
    local off_set = self.transform.anchoredPosition
    return pos.x + off_set.x, pos.y + off_set.y
end

function MainBottomRight:GetRightIconPos(key_str)
    local item = self.rightIconList[key_str]
    if not item then
        return 0, 0
    end
    local x, y = item:GetCurPosition()
    x = x * 100
    y = y * 100
    return x, y
end

function MainBottomRight:SwitchToIcons(flag)
    if self:IsInAction(self.skill_list) or self:IsInAction(self.normal_list) then
        return
    end
    if self.switch_state == flag then
        return
    end
    self:Switch(flag)
end

--刷新背包红点
function MainBottomRight:UpdateBagRedDot()
    if not self.btn_bag then
        return
    end
    if not self.red_dot then
        self.red_dot = RedDot(self.btn_bag.transform)
        self.red_dot:SetPosition(25, 27)
    end
    local param = self.model:GetRedDotParam("bag")
    self.red_dot:SetRedDotParam(param)
end

--切换跳舞状态
function MainBottomRight:ChangeDanceState()
    if self.is_dance_state then
        self:StopDance();
    else
        self:StartDance();
    end
end

function MainBottomRight:StartDance()
    local main_role = SceneManager:GetInstance():GetMainRole()
    main_role:PlayDance()
end

function MainBottomRight:StopDance()
    local main_role = SceneManager:GetInstance():GetMainRole()
    main_role:ChangeToMachineDefalutState()
end

function MainBottomRight:SceneChangeEndFun()
    local cur_scene_id = SceneManager:GetInstance():GetSceneId()
    self.isInCandy = cur_scene_id == 30342 or cur_scene_id == 30341

    local switch_type = MainModel:GetInstance():GetSwitchType()
    if switch_type == MainModel.SwitchType.City then
        -- if not self.switch_state then
        -- 	self:Switch(not self.switch_state)
        -- end
    elseif switch_type == MainModel.SwitchType.Dungeon then
        if self.switch_state and not self.isInCandy then
            self:Switch(not self.switch_state)
        end
    end
    self:UpdateFairy()

    if self.isInCandy then
        self:Switch(false)  --糖果屋内自动切换到技能页
    else
        if not self.switch_state then
            self:Switch(false)  --当前为技能页时需要刷新一下技能页
        end
    end

    
end

