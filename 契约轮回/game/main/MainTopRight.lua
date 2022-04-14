-- 
-- @Author: LaoY
-- @Date:   2018-08-15 15:36:29
-- 
MainTopRight = MainTopRight or class("MainTopRight", BaseItem)
local MainTopRight = MainTopRight

function MainTopRight:ctor(parent_node, layer)
    self.abName = "main"
    self.assetName = "MainTopRight"
    self.layer = layer
    self.icon_list = {}
    self.model = MainModel:GetInstance()

    self.switch_state = nil
    self.model_event_list = {}
    self.predic_start_pos = { 474, 43 }
    self.predic_hide_pos = { 1197, 35 }
    self.is_show_sys_eft = true

    self.pos_y = -52
    self.pos_z = 300
    self.pos_x = -97991
    self.rota_y = 0
    self.icon_click_area_list = { 363, 54 }
    self.model_click_area_list = { 165, 159 }
    self.model_click_area_pos = { 98, 52 }
    MainTopRight.super.Load(self)
end

function MainTopRight:dctor()
    if self.predi_model_eft then
        self.predi_model_eft:destroy()
        self.predi_model_eft = nil
    end
    if self.texture_cpn then
        self.texture_cpn.texture = nil
    end
    if self.cam then
        self.cam.targetTexture = nil
    end
    if self.texture then
        ReleseRenderTexture(self.texture)
        self.texture = nil
    end

    self:DestroyModel()
    if self.sys_eft then
        self.sys_eft:destroy()
        self.sys_eft = nil
    end
    self:StopAction()
    self:StopPredictionAct()
    if self.global_event_list then
        GlobalEvent:RemoveTabListener(self.global_event_list)
        self.global_event_list = {}
    end

    if self.model_event_list then
        self.model:RemoveTabListener(self.model_event_list)
        self.model_event_list = {}
    end

    for k, item in pairs(self.icon_list) do
        item:destroy()
    end
    self.icon_list = {}
    self:DestroyModel()

    if self.switchBtn_red then
        self.switchBtn_red:destroy()
        self.switchBtn_red = nil
    end

    if self.role_info_event_list then
        RoleInfoModel:GetInstance():GetMainRoleData():RemoveTabListener(self.role_info_event_list)
    end
    self.role_info_event_list = {}
    if self.firstpaytip_schedule then
        GlobalSchedule:Stop(self.firstpaytip_schedule)
        self.firstpaytip_schedule = nil
    end
    if self.firstpay_item then
        self.firstpay_item:destroy()
        self.firstpay_item = nil
    end
end

function MainTopRight:LoadCallBack()
    self.nodes = {
        "text_cur_pos", "text_scene_name", "img_map_info_bg_1", "btn_switch", "MainTopRightItem",
        "sysPrediction/icon_part/limit", "sysPrediction/icon_part/icon", "sysPrediction/icon_part/des",
        "sysPrediction/icon_part",
        "sysPrediction/icon_part/bg", "sysPrediction/mask",
        "sysPrediction", "sysPrediction/model_part/eft_con",
        "sysPrediction/model_part/model_con", "sysPrediction/model_part",
        "sysPrediction/model_part/model_limit",
        "sysPrediction/model_part/model_con/Camera",
        "img_map_text_bg_1",
    }
    self:GetChildren(self.nodes)
    self.text_cur_pos_component = self.text_cur_pos:GetComponent('Text')
    self.text_scene_name_component = self.text_scene_name:GetComponent('Text')
    self.limit = GetText(self.limit)
    self.des = GetText(self.des)
    self.sysicon = GetImage(self.icon)
    self.model_limit = GetText(self.model_limit)

    self.texture = CreateRenderTexture()
    self.texture_cpn = self.model_con:GetComponent("RawImage")
    self.texture_cpn.texture = self.texture
    self.cam = self.Camera:GetComponent("Camera")
    self.cam.targetTexture = self.texture
    self.syspredi_mask_rect = GetRectTransform(self.mask)
    SetRotation(self.eft_con.transform, 15, 0, 0)
    SetLocalScale(self.eft_con.transform, 0.6, 0.6, 0.6)
    SetLocalPosition(self.eft_con.transform, 85.7, 38, 1)
    SetLocalPosition(self.model_con.transform, 75, 98, 10000)

    self.MainTopRightItem_gameObject = self.MainTopRightItem.gameObject
    SetVisible(self.MainTopRightItem, false)

    self.switchBtn_red = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
    self.switchBtn_red:SetPosition(508, 329)

    self:SetData()
    self:AddEvent()

    self:checkAdaptUI()

    self:LoadIcon(true)
    self:IsShowPredic(true)
end

function MainTopRight:checkAdaptUI()
    if self.predic_hide_pos and self.predic_hide_pos[1] then
        self.predic_hide_pos[1] = self.predic_hide_pos[1] - UIAdaptManager:GetInstance():GetBanScreenOffsetX()
    end

    if self.predic_start_pos and self.predic_start_pos[1] then
        self.predic_start_pos[1] = self.predic_start_pos[1] - UIAdaptManager:GetInstance():GetBanScreenOffsetX()
    end

    UIAdaptManager:GetInstance():AdaptUIForBangScreenRight(self.sysPrediction)
end

function MainTopRight:AddEvent()
    local function cb()
        if self.sys_eft then
            self.is_show_sys_eft = false
            self.sys_eft:destroy()
            self.sys_eft = nil
        end
        lua_panelMgr:GetPanelOrCreate(SysPredictionPanel):Open(self.next_show_cfg)
    end
    AddClickEvent(self.mask.gameObject, cb)

    local function call_back(target, x, y)
        -- Notify.ShowText("小地图功能还未开放")
        GlobalEvent:Brocast(MainEvent.OpenMapPanel)
    end
    AddClickEvent(self.img_map_info_bg_1.gameObject, call_back)

    local function switch_call_back(target, x, y)
        self:Switch(not self.switch_state)
    end
    AddClickEvent(self.btn_switch.gameObject, switch_call_back)

    self.global_event_list = self.global_event_list or {}

    local function call_back(x, y)
        self:UpdatePos(x, y)
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(SceneEvent.MainRolePos, call_back)

    local function call_back()
        self:SetSceneName()
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(SceneEvent.UpdateInfo, call_back)

    local function call_back()
        local switch_type = MainModel:GetInstance():GetSwitchType()
        if switch_type == MainModel.SwitchType.City then
            if not self.switch_state then
                self:Switch(true)
            end
        elseif switch_type == MainModel.SwitchType.Dungeon then
            if self.switch_state then
                self:Switch(false)
            else
                self:Switch(false)
            end
        end
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(EventName.ChangeSceneEnd, call_back)

    -- local function call_back(state)
    -- 	self:Switch(state)
    -- end
    -- self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(MainEvent.SwithRight, call_back)

    local function call_back(id)
        local item = self.icon_list[id]
        if not item then
            self:LoadIcon()
        end
    end
    self.model_event_list[#self.model_event_list + 1] = self.model:AddListener(MainEvent.AddRightIcon, call_back)

    local function call_back(id, update_type)
        local item = self.icon_list[id]
        if item then
            item:UpdateInfo()
        else
            if not update_type or update_type == "data" then
                self:LoadIcon()
            end
        end
    end
    self.model_event_list[#self.model_event_list + 1] = self.model:AddListener(MainEvent.UpdateRightIcon, call_back)

    local function call_back(id)
        local item = self.icon_list[id]
        if item then
            item:destroy()
            self.icon_list[id] = nil
            self:LoadIcon()
        end
    end
    self.model_event_list[#self.model_event_list + 1] = self.model:AddListener(MainEvent.RemoveRightIcon, call_back)

    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(MainEvent.UpdateNextSysPrediction, handler(self, self.UpdateSysShow))


    -- 角色信息相关要用其他绑定
    self.role_info_event_list = {}
    self.role_info_event_list[#self.role_info_event_list + 1] = RoleInfoModel:GetInstance():GetMainRoleData():BindData("level", handler(self, self.UpdateSysShow))

    local function callback(key)
        local item = self.icon_list[key]
        if item then
            SetVisible(item, false)
        end
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(MainEvent.CheckNeedPopSysShow, callback)

    local function call_back()
        self:CheckRedPoint()

    end
    self.model_event_list[#self.model_event_list + 1] = self.model:AddListener(MainEvent.UpdateRedDot, call_back)

    self.firstpaytip_schedule = GlobalSchedule:Start(handler(self, self.FirstPayTip), 1)
end

function MainTopRight:UpdatePos(x, y)
    if not self.is_loaded then
        return
    end
    self.text_cur_pos_component.text = string.format("%d,%d", x, y)
end

function MainTopRight:SetSceneName()
    if not self.is_loaded then
        return
    end
    local name = SceneManager:GetInstance():GetSceneName()
    if name then
        self.text_scene_name_component.text = name
    end
end

function MainTopRight:SetData()
    if not self.is_loaded then
        return
    end
    local main_role = SceneManager:GetInstance():GetMainRole()
    if main_role then
        local pos = main_role:GetPosition()
        local x, y = pos.x, pos.y
        self:UpdatePos(x, y)
    end
    self:SetSceneName()
end
function MainTopRight:CheckRedPoint()
    if self.switch_state == true then
        self.switchBtn_red:SetRedDotParam(false)
        return
    end
    local isRed = false
    for i, v in pairs(self.icon_list) do
        local cfg = IconConfig.TopRightConfig[v.data.key_str]
        if cfg.is_Show == false then
            local param = self.model:GetRedDotParam(v.data.key_str, v.data.sign)
            if param then
                isRed = true
                break
            end
        end
    end
    self.switchBtn_red:SetRedDotParam(isRed)
end

function MainTopRight:Switch(switch_state)
    local switch_type = MainModel:GetInstance():GetSwitchType()
    if self.switch_state == switch_state and switch_type ~= MainModel.SwitchType.Dungeon then
        return
    end
    self.switch_state = switch_state
    self:CheckRedPoint()
    local time = 0.3
    -- local item = self.icon_list[5]
    -- local rate = item and item:GetActionTimeRate(self.switch_state,switch_type) or 1
    if self.last_action_time and Time.time - self.last_action_time < time then
        local last_time = Time.time - self.last_action_time
        time = last_time
    end
    self.last_action_time = Time.time
    local action
    if self.switch_state then
        for k, item in pairs(self.icon_list) do
            item:StartAction(time, true, switch_type)
        end
        action = cc.RotateTo(time, 360)
        action = cc.Sequence(action, cc.RotateTo(0, 0))
    else
        if (switch_type ~= MainModel.SwitchType.City or table.nums(self.icon_list) >= 5) then
            for k, item in pairs(self.icon_list) do
                item:StartAction(time, false, switch_type)
            end
        end
        action = cc.RotateTo(time, -180)
        action = cc.Sequence(action, cc.RotateTo(0, 180))
    end
    self:StopAction()
    local function end_call_back()
        if switch_state then
            -- show icon
            -- GlobalEvent:Brocast(MainEvent.ShowTopRightIcon)
        else
            -- hide icon
            GlobalEvent:Brocast(MainEvent.HideTopRightIcon)
        end
    end
    local call_action = cc.CallFunc(end_call_back)
    action = cc.Sequence(action, call_action)
    cc.ActionManager:GetInstance():addAction(action, self.btn_switch)
    if switch_state then
        GlobalEvent:Brocast(MainEvent.ShowTopRightIcon)
    end
    self:StartPredicAct()
end

function MainTopRight:StopAction()
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.btn_switch)
end

function MainTopRight:LoadIcon(is_first)
    local main_role = RoleInfoModel.GetInstance():GetMainRoleData()

    if self.switch_state == nil then
        local switch_type = MainModel:GetInstance():GetSwitchType()
        if switch_type == MainModel.SwitchType.City then
            self.switch_state = true
        else
            self.switch_state = false
        end
    end

    local list = {}
    for key_str, v in pairs(self.model.right_top_icon_list) do
        --if v.cf.level or v.cf.task then
        if OpenTipModel.GetInstance():IsOpenSystem(v.cf.id, v.cf.sub_id) then
            list[#list + 1] = v
        end
        --else
        --    --print2(string.format("请检查配置%s，没有配开启等级", v.key))
        --    --print2(string.format("请检查配置%s，没有配开启等级", v.key))
        --    --print2(string.format("请检查配置%s，没有配开启等级", v.key))
        --end
        --list[#list + 1] = v
    end
    -- dump(list)
    local function sortFunc(a, b)
        local sort
        if a.cf.row == b.cf.row then
            if a.cf.index == b.cf.index then
                sort = a.create_index < b.create_index
            else
                sort = a.cf.index < b.cf.index
            end
        else
            sort = a.cf.row < b.cf.row
        end
        return sort
    end
    table.sort(list, sortFunc)

    local width = 77
    local height = 77
    local line_count = 2
    local line_index1 = 0
    local line_index2 = 0
    local line_index3 = 0
    local special_count = MainTopRightItem.special_count
    local pos = { 436, 310 }
    local start_pos = { x = pos[1], y = pos[2] }
    local switch_type = MainModel:GetInstance():GetSwitchType()
    local offx = 0
    local count = 1
    for i = 1, #list do
        local info = list[i]
        local cf = info.cf
        local item = self.icon_list[info.key]
        local is_exist = true
        if not item then
            item = MainTopRightItem(self.MainTopRightItem_gameObject, self.transform)
            self.icon_list[info.key] = item
            item:SetData(info)
            item:SetRowIdx(cf.row)
            is_exist = false
        end

        local x, y
        local evade_x
        local line = cf.row
        local line_index
        if line == 1 then
            --x,y = start_pos.x,start_pos.y
            line_index1 = line_index1 + 1
            line_index = line_index1 - 1
            x, y = start_pos.x - line_index * width, start_pos.y
        elseif line == 2 then
            line_index2 = line_index2 + 1
            line_index = line_index2 - 1
            x = (start_pos.x + 2 * width) - line_index * width
            y = start_pos.y - height
        else
            line_index3 = line_index3 + 1
            line_index = line_index3 - 1
            x = (start_pos.x + 2 * width) - line_index * width
            y = start_pos.y - height * 2

            evade_x = (start_pos.x + 2 * width) - (line_index + 2) * width
            -- ffh 刘海屏适配
            x = x - UIAdaptManager:GetInstance():GetBanScreenOffsetX()
        end

        local hide_pos = { x = x, y = y }
        local hide_pos2 = { x = start_pos.x, y = start_pos.y }
        if not cf.is_Show then
            hide_pos.x = start_pos.x
            hide_pos.y = y
        end
        local sibling_index = #list - i + 1
        item:SetSiblingIndex(sibling_index)
        item:SetStartPos(x, y)
        item:SetHidePos(hide_pos, hide_pos2)
        item:SetEvadeX(evade_x, y)

        item:SetLineIndex(line, line_index, i, cf.is_Show)
        if not is_exist then
            if not self.switch_state then
                if switch_type == MainModel.SwitchType.City then
                    item:SetVisible(cf.is_Show)
                else
                    item:SetVisible(false)
                    -- item:SetIsCanShow(false)
                end
            else
                item:SetVisible(true)
            end
        end

        if self.switch_state then
            if is_exist then
                item:StartMoveAction()
            else
                local set_x = self.model.is_showing_model_predi and evade_x or x
                item:SetPosition(set_x, y)
            end
            if not is_exist and not is_first then
                local cf = IconConfig.TopRightConfig[info.key_str]
                local key = cf.id .. "@" .. cf.sub_id
                if OpenTipModel.GetInstance():IsNeedMove(cf.id, cf.sub_id) then
                    item:SetVisible(false)
                    item:SetIsCanShow(false)
                    self:Switch(true)
                else
                    item:BirthAction()
                end
                local sibling_index = #list
                item:SetSiblingIndex(sibling_index)
            end
        else
            if switch_type == MainModel.SwitchType.City then
                item:SetPosition(hide_pos.x, hide_pos.y)
            else
                item:SetPosition(hide_pos2.x, hide_pos2.y)
            end
        end
    end
end

function MainTopRight:GetItemPos(key_str)
    local item = self.icon_list[key_str]
    if not item then
        return 0, 0
    end
    local x, y = item:GetCurPosition()
    x = x * 100
    y = y * 100
    return x, y
end

function MainTopRight:StartPredicAct()
    if not self.next_show_cfg then
        return
    end
    self:StopPredictionAct()
    local time = 0.3
    local target_pos = nil
    local isShow = false
    if self.switch_state then
        target_pos = self.predic_start_pos
        isShow = true
    else
        isShow = false
        local cur_type = MainModel.GetSwitchType()
        if cur_type ~= MainModel.SwitchType.City then
            target_pos = self.predic_hide_pos
        end
    end
    if not target_pos then
        return
    end
    local moveAction = cc.MoveTo(time, target_pos[1], target_pos[2], 0)
    local function end_call_back()
        SetVisible(self.sysPrediction, isShow)
        GlobalEvent:Brocast(MainEvent.SwitchLittleAngleShow, not isShow)
    end
    local call_action = cc.CallFunc(end_call_back)
    local action = cc.Sequence(moveAction, call_action)
    cc.ActionManager:GetInstance():addAction(action, self.sysPrediction)
end

function MainTopRight:StopPredictionAct()
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.sysPrediction)
end

function MainTopRight:IsShowPredic(isInLoadCB)
    local role_lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    if role_lv <= 0 then
        SetVisible(self.sysPrediction, false)
        self.model.isShowPredi = false
        return
    end
    local cur_type = MainModel.GetSwitchType()
    local isShowP = false
    if cur_type == MainModel.SwitchType.City then
        SetVisible(self.sysPrediction, true)
        self.model.isShowPredi = true
        self:StartPredicAct()
        isShowP = true
    else
        if isInLoadCB then
            self.model.isShowPredi = true
        else
            self.model.isShowPredi = false
        end
    end
    if isShowP then
        if not self.sys_eft and self.is_show_sys_eft then
            self.sys_eft = UIEffect(self.sysicon.transform, 10201, false)
        end
    end
    self:UpdateSysShow(isInLoadCB, isShowP)
end

function MainTopRight:UpdateSysShow(isInLoadCB, isShowP)
    local cfg = OpenTipModel.GetInstance():GetNextWillOpenSys()
    if not cfg then
        SetVisible(self.sysPrediction, false)
        self.model.isShowPredi = false
        return
    end
    if self.next_show_cfg then
        local cur_key = self.next_show_cfg.id .. "@" .. self.next_show_cfg.sub_id
        local key = cfg.id .. "@" .. cfg.sub_id
        if cur_key == key then
            return
        else
            for i, v in pairs(cfg) do
                self.next_show_cfg[i] = v
            end
        end
    elseif cfg then
        self.next_show_cfg = {}
        for i, v in pairs(cfg) do
            self.next_show_cfg[i] = v
        end
    else
        SetVisible(self.sysPrediction, false)
        self.model.isShowPredi = false
        return
    end
    local key = self.next_show_cfg.id .. "@" .. self.next_show_cfg.sub_id
    self.sysData = GetOpenByKey(key)
    local sysopen_cf = Config.db_sysopen[key]
    local res_tab
    local str
    if sysopen_cf.type == 3 then
        str = String2Table(sysopen_cf.res)[2]
    elseif sysopen_cf.type == 4 then
        str = sysopen_cf.res
    elseif self.sysData ~= nil then
        self.sysData = GetIconDataByKey(Config.db_sysopen[key].key)
        str = self.sysData
    else
        str = self.next_show_cfg.res_tbl[1] .. ":" .. self.next_show_cfg.res_tbl[2]
    end
    res_tab = string.split(str, ":")
    self.next_show_cfg.res_tbl = res_tab
    --self.next_show_cfg.type = 1
    local str = ""
    local lv = GetLevelShow(self.next_show_cfg.level)
    if self.next_show_cfg.task ~= 0 then
        str = "At Lv.%s Main quest unlock <color=#f3ff33>%s</color>"
    elseif self.next_show_cfg.level ~= 0 then
        str = "Unlocked at LV.%s <color=#f3ff33>%s</color>"
    end
    self.model.is_showing_model_predi = false
    if self.next_show_cfg.type == 3 or self.next_show_cfg.type == 2 then
        self.model.is_showing_model_predi = true
    end

    local cur_type = MainModel.GetSwitchType()
    if cur_type == MainModel.SwitchType.City then
        self.model:Brocast(MainEvent.ChangeThirdTopRightIconPos, self.switch_state)
    end
    self:InitClickAreaSize(self.model.is_showing_model_predi)
    if self.next_show_cfg.type == 1 or self.next_show_cfg.type == 4 then
        --图标
        SetVisible(self.icon_part, true)
        SetVisible(self.model_part, false)
        local abName = res_tab[1]
        local assetName = res_tab[2]
        lua_resMgr:SetImageTexture(self, self.sysicon, abName, assetName, true, nil, false)
        self.des.text = self.next_show_cfg.title
        self.limit.text = string.format(str, lv, self.next_show_cfg.title)
    else
        --模型
        SetVisible(self.icon_part, false)
        SetVisible(self.model_part, true)
        self:DestroyModel()
        local res_id = self.next_show_cfg.res
        self:GetRightPos(self.next_show_cfg.res)
        local res_tbl = String2Table(self.next_show_cfg.res)
        if self.next_show_cfg.id == 130 and self.next_show_cfg.sub_id == 1 then
            self.syspredi_model = UIMountModel(self.model_con.transform, res_id, handler(self, self.Loadui_modelCallBack));
        else
            self.syspredi_model = UIModelManager:GetInstance():InitModel(nil, res_tbl[1], self.model_con.transform, handler(self, self.model_cb), true)
        end

        --self.model_limit.text = string.format("<color=#fffd43>%d级</color><color=#ffffff>开启</color>", self.next_show_cfg.level)
        self.model_limit.text = string.format(str, lv, self.next_show_cfg.title)
        self:LoadPrediEft()
    end
    if isInLoadCB and isShowP == false then
        SetVisible(self.sysPrediction, false)
    end
end

function MainTopRight:LoadPrediEft()
    if self.predi_model_eft then
        self.predi_model_eft:destroy()
        self.predi_model_eft = nil
    end
    local function cb()
        LayerManager.GetInstance():AddOrderIndexByCls(self, self.texture_cpn, nil, true, nil, 1, 6)
    end
    self.predi_model_eft = UIEffect(self.eft_con, 10313, false, "Bottom", cb)
    self.predi_model_eft:SetOrderIndex(101)
end

function MainTopRight:InitClickAreaSize(is_showing_model_predi)
    local size = is_showing_model_predi and self.model_click_area_list or self.icon_click_area_list
    local pos = is_showing_model_predi and self.model_click_area_pos or { 0, 0, 0 }
    SetSizeDelta(self.syspredi_mask_rect, size[1], size[2])
    SetLocalPosition(self.mask, pos[1], pos[2], pos[3])
end

function MainTopRight:DestroyModel()
    if self.syspredi_model ~= nil then
        self.syspredi_model:destroy()
        self.syspredi_model = nil
    end
end

function MainTopRight:Loadui_modelCallBack()
    --self.syspredi_model:SetReplayMode(false)
    SetLocalPosition(self.syspredi_model.transform, self.pos_x, self.pos_y, self.pos_z)
    --SetLocalRotation(self.ui_model.transform, 1, -124.5, 1)
    SetLocalRotation(self.syspredi_model.transform, 0, 230, 0)
    SetLocalScale(self.syspredi_model.transform, 100, 100, 100)
end
function MainTopRight:LoadMgrModelCallB()
    --self.syspredi_model:SetReplayMode(false)
    SetLocalPosition(self.syspredi_model.transform, self.pos_x, self.pos_y, self.pos_z)
    local v3 = self.syspredi_model.transform.localScale;
    SetLocalScale(self.syspredi_model.transform, 100, 100, 100);
    SetLocalRotation(self.syspredi_model.transform, 0, self.rota_y, 0);
end
function MainTopRight:WeaponCallBack()
    --self.syspredi_model:SetReplayMode(false)
    SetLocalPosition(self.syspredi_model.transform, self.pos_x, self.pos_y, self.pos_z)
    local v3 = self.syspredi_model.transform.localScale;
    SetLocalScale(self.syspredi_model.transform, 100, 100, 100);
    SetLocalRotation(self.syspredi_model.transform, 0, self.rota_y, 0);

    self.syspredi_model:AddAnimation({ "show", "idle2" }, false, "idle2", 0)--,"casual"
    self.syspredi_model.animator:CrossFade("idle2", 0)
end

function MainTopRight:GetRightPos(res_str)
    self.model_cb = handler(self, self.LoadMgrModelCallB)
    local tbl = string.split(res_str, "_")
    local type = tbl[2]
    if type == "fabao" then
        self.pos_y = -18
        self.pos_z = 220
        self.rota_y = 180
    elseif type == "monster" then
        self.pos_y = 0
    elseif type == "mount" then
        self.pos_y = -75
        self.pos_z = 420
    elseif type == "npc" then
        self.pos_y = 0
    elseif type == "pet" then
        self.rota_y = 180
    elseif type == "role" then
        self.pos_y = 0
    elseif type == "wing" then
        self.pos_y = 0
        self.pos_z = 300
    elseif type == "weapon" then
        self.pos_y = 20
        self.pos_z = 300
        self.rota_y = 180
        self.model_cb = handler(self, self.WeaponCallBack)
    elseif type == "hand" then
        self.pos_y = 0
        self.pos_z = 400
        self.rota_y = 0
    elseif type == 'machiaction' then
        self.rota_y = 180
        self.pos_y = -130
        self.pos_z = 600
    end
end

function MainTopRight:ChangeToShowMode(state)
    if state then
        if not self.switch_state then
            self:Switch(true)
        end
    else
        if self.switch_state then
            self:Switch(false)
        end
    end
end

function MainTopRight:GetItemGlobalPos(key)
    local item = self.icon_list[key]
    if not item then
        return 0, 0, 0
    end
    return item:GetGlobalPosition()
end

function MainTopRight:FirstPayTip()
    local open_time = RoleInfoModel:GetInstance():GetRoleValue("ctime")
    local now = os.time()
    local level = RoleInfoModel:GetInstance():GetRoleValue("level")
    if level >= 1 and level <= 64 and now - open_time <= 1800 and not FirstPayModel.GetInstance():IsFirstPay() then
        if not self.firstpay_item and self.icon_list["firstPay"] then
            self.firstpay_item = MainFirstPayTipItem2(self.icon_list["firstPay"].transform)
            --[[elseif self.firstpay_item and self.icon_list["firstPay"] then
                SetVisible(self.firstpay_item, true)
                self.firstpay_item:UpdateView()--]]
        end
    elseif level > 64 then
        if self.firstpaytip_schedule then
            GlobalSchedule:Stop(self.firstpaytip_schedule)
            self.firstpaytip_schedule = nil
        end
        if self.firstpay_item then
            self.firstpay_item:destroy()
            self.firstpay_item = nil
        end
    end
end

function MainTopRight:DestroyModel()
    if self.syspredi_model then
        self.syspredi_model:destroy()
        self.syspredi_model = nil
    end
end