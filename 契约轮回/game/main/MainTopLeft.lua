-- 
-- @Author: LaoY
-- @Date:   2018-08-15 15:30:41
-- 

MainTopLeft = MainTopLeft or class("MainTopLeft", BaseItem)
local MainTopLeft = MainTopLeft

function MainTopLeft:ctor(parent_node, layer)
    self.abName = "main"
    self.assetName = "MainTopLeft"
    self.layer = layer

    self.model = MainModel:GetInstance()
    self.isNeedLoadmarryIcon = true
    self.buff_list = {}
    self.time_id = nil
    self.lastVipEnd = 0
    self.isCanGetVipExpPool = false
    self.countDownList = {}
    self.is_can_show_exp_btn = true
    self.is_can_show_vfour_btn = self:IsEnoughLevelShowVFourIcon()
    self.is_can_show_vip_small_btn = VipSmallModel.GetInstance():IsCanShowVipSmallIcon()
    self.tips_clsoe_time = 10
    self.loaded_call_back = nil
    self.switch_state = nil
    self.model_event_list = {}
    self.icon_list = {}
    self.show_gundam_time = 1860        --机甲图标开始显示的时间戳
    self.show_gundam_lv = 180
    self.loop_wait_for_lv_up_time = 72000
    self.act_time = TimeManager.DaySec * 3          --活动持续时间

    self.vipsmall_reddot = nil  --小贵族icon红点
    self.vipsmall_icon_reddot_change_event_id = nil  --小贵族icon红点改变事件

    self.handle_vip2_fetch_event_id = nil  --小贵族奖励领取事件
    self.handle_vip2_info_event_id = nil --小贵族信息返回事件
    MainTopLeft.super.Load(self)
end

function MainTopLeft:LoadCallBack()
    self.nodes = {
        "text_lv", "text_bgold", "text_gold", "blood", "text_blood", "img_buff_icon", "img_buff_click", "vip_con/btn_Vip/vipIconText", "text_power", "btn_realname", "vip_con/btn_Vip/red_con",
        "vip_con/btn_exp/exp_red_con", "icon_con", "vip_con/tasteArea", "vip_con/tasteArea/TitleText", "vip_con/btn_Vip", "vip_con/btn_exp", "vip_con/vfour_icon", "vip_con/vfour_icon/timer", "vip_con/vfour_icon/tip", "vip_con/vfour_icon/tip/des",
        "btn_marry", "img_main_role_lv_bg_1", "vip_con/vfour_icon/vfour_rd_con",
        "MainTopLeftItem", "btn_gundam/text_bg", "btn_gundam/gundam_red_con",
        "btn_gundam", "btn_gundam/time_con", "btn_gundam/bg",
        "vip_con/btn_vipsmall","vip_con/btn_vipsmall/vipsmall_red_con",
        "vip_con",
        
    }
    self:GetChildren(self.nodes)
    self.MainTopLeftItem_gameObject = self.MainTopLeftItem.gameObject
    SetVisible(self.MainTopLeftItem, false)

    self.text_blood_component = self.text_blood:GetComponent('Text')
    --LayerManager.GetInstance():AddOrderIndexByCls(self, self.des.transform, nil, true, nil, false, 12)
    --LayerManager.GetInstance():AddOrderIndexByCls(self, self.tip.transform, nil, true, nil, false, 14)

    self.lv_frame_img = GetImage(self.img_main_role_lv_bg_1)

    SetVisible(self.text_blood, true)

    --- 屏蔽VIP    
    SetVisible(self.vip_con, false)

    self.text_lv_component = self.text_lv:GetComponent('Text')
    self.text_bgold_component = self.text_bgold:GetComponent('Text')
    self.text_gold_component = self.text_gold:GetComponent('Text')

    self.blood_component = self.blood:GetComponent('Image')
    self.vipText = self.vipIconText:GetComponent('Text')

    self.text_power_component = self.text_power:GetComponent('Text')

    SetVisible(self.img_buff_icon, false)
    self.img_buff_icon_gameobject = self.img_buff_icon.gameObject
    local x, y = GetLocalPosition(self.img_buff_icon)
    self.buff_start_pos = { x = x, y = y }

    self.gundam_icon_img = GetImage(self.text_bg)

    if self.is_need_setdata then
        self:SetData()
    end
    self:AddEvent()
    local function step()
        self:UpdateVipOutDate()
        self.lastVipEnd = self.role_data.vipend
    end
    self.delay_sche = GlobalSchedule:StartOnce(step, 2)

    if self.role_icon then
        self.role_icon:destroy()
        self.role_icon = nil
    end
    local param = {}
    param['is_hide_frame'] = true
    param['is_can_click'] = true
    param['size'] = 92
    local function callback()
        GlobalEvent:Brocast(RoleInfoEvent.OpenRoleInfoPanel)
    end
    param['click_fun'] = callback
    self.role_icon = RoleIcon(self.icon_con)
    self.role_icon:SetData(param)
    --
    if self.isNeedLoadmarryIcon then
        self:CheckMarryShow()
    end

    self.transform:SetAsFirstSibling()
    --SetVisible(self.tasteArea, false)
    local function step()
        if not self.model.is_init_vfour_mention then
            self.model.is_init_vfour_mention = true
            self:CheckMentionShow()
            self:StartVFourMention()
        end
    end
    GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Best)

    self.firstpaytip_schedule = GlobalSchedule:Start(handler(self, self.FirstPayTip), 1)

    self:checkAdaptUI()

    if self.loaded_call_back then
        self.loaded_call_back()
        self.loaded_call_back = nil
    end

    self:LoadIcon(true)
    self:CheckIsShowGundam()

    VipSmallController.GetInstance():RequestVip2Info()
    WelfareController.GetInstance():RequestWelfareOnline2()
end

function MainTopLeft:checkAdaptUI()
    UIAdaptManager:GetInstance():AdaptUIForBangScreenLeft(self.btn_marry)
end

function MainTopLeft:AddEvent()
    -----------机甲活动图标
    local function callback()
        lua_panelMgr:GetPanelOrCreate(GundamActPanel):Open()
        CacheManager.GetInstance():SetFloat("gundam_act_check_red_dot_stamp", os.time())
        if not GundamActModel.GetInstance().is_showing_task_rd then
            --没有在显示奖励红点
            self:SetGundamRedDot(false)
        end
    end
    AddButtonEvent(self.bg.gameObject, callback)

    local function callback(is_show)
        self:SetGundamRedDot(is_show)
    end
    self.update_gundam_rd_event_id = GlobalEvent:AddListener(GundamActEvent.UpdateGundamIconRD, callback)
    ------------

    local function callback()
        if not self.model.is_init_vfour_mention then
            self.model.is_init_vfour_mention = true
            self:CheckMentionShow()
            self:StartVFourMention()
        end
    end
    self.loading_destroy_event_id = GlobalEvent:AddListener(EventName.DestroyLoading, callback)

    local function call_back(target, x, y)
        GlobalEvent:Brocast(VipEvent.OpenVipPanel)
    end
    AddButtonEvent(self.btn_Vip.gameObject, call_back)

    local function call_back(target, x, y)
        GlobalEvent:Brocast(VipEvent.RequestOutDateSaveExp, self.isCanGetVipExpPool)
    end
    AddButtonEvent(self.btn_exp.gameObject, call_back)

    local function callback()
        lua_panelMgr:GetPanelOrCreate(VipVFourPanel):Open()
        SetVisible(self.tip, false)
    end
    AddButtonEvent(self.vfour_icon.gameObject, callback)

    local function call_back(target, x, y)
        local list = self.role_data:GetShowBuffList()
        if table.isempty(list) then
            return
        end
        lua_panelMgr:GetPanelOrCreate(BuffShowPanel):Open()
    end
    AddClickEvent(self.img_buff_click.gameObject, call_back)

    local function call_back(target, x, y)
        lua_panelMgr:GetPanelOrCreate(RealNamePanel):Open()
    end
    AddClickEvent(self.btn_realname.gameObject, call_back)

    self.role_data = RoleInfoModel:GetInstance():GetMainRoleData()
    if not self.role_data then
        local function call_back()
            self.role_data = RoleInfoModel:GetInstance():GetMainRoleData()
            self:BindRoleUpdate()
            if not self.is_set_data then
                self:SetData()
            end
            RoleInfoModel:GetInstance():RemoveListener(self.event_id)
            self.event_id = nil
        end
        self.event_id = RoleInfoModel:GetInstance():AddListener(RoleInfoEvent.ReceiveRoleInfo, call_back)
    else
        self:BindRoleUpdate()
        self:SetData()
    end

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(MarryMatchingPanel):Open()
    end
    AddButtonEvent(self.btn_marry.gameObject, call_back)

    local function call_back()
        SetVisible(self.btn_exp, false)
        self.is_can_show_exp_btn = false
    end
    self.hidebtnexpicon_event_id = GlobalEvent:AddListener(VipEvent.SuccessToGetExpPool, call_back)

    function call_back(data)
        self.isShowRename = data
        SetVisible(self.btn_realname, data)
    end
    self.realName_event_id = GlobalEvent:AddListener(RealNameEvent.RealNameShowIcon, call_back) --实名认证

    self.vip_rd_event_id = GlobalEvent:AddListener(VipEvent.ShowMainVipRD, handler(self, self.SetRedDot))

    local function callback(  )
        self:CheckIsShowGundam()

        self.is_can_show_vip_small_btn = VipSmallModel.GetInstance():IsCanShowVipSmallIcon()
        self:CheckIsShowVipSmallIcon()
    end
    self.cross_day_event_id = GlobalEvent:AddListener(EventName.CrossDay, callback)
    --function call_back(isShow)
    --    if not self.is_loaded then
    --        self.isNeedLoadmarryIcon = true
    --        return
    --    end
    --    self.isNeedLoadmarryIcon = false
    --    self:ShowMarryIcon()
    --    -- SetVisible(self.btn_marry, isShow)
    --end
    --self.marrymatch_event_id = GlobalEvent:AddListener(MarryEvent.ShowMarrIcon, call_back)

    function call_back()
        if not self.is_loaded then
            self.isNeedLoadmarryIcon = true
            return
        end
        self.isNeedLoadmarryIcon = false
        self:CheckMarryShow()
    end
    self.marrymatch_event_id = GlobalEvent:AddListener(TaskEvent.GlobalAddTask, call_back)
    self.marrymatch_event_id2 = TaskModel:GetInstance():AddListener(TaskEvent.AccTaskList, call_back)
    local function callback()
        self:UpdateVipOutDate()
        self:CheckIsShowVipIcon()
        self:CheckIsShowRenameIcon()
        self:CheckMarryShow()
        self:CheckIsShowVipSmallIcon()
    end
    self.scene_change_end_event_id = GlobalEvent:AddListener(EventName.ChangeSceneEnd, callback)
    self.close_loading_event_id = GlobalEvent:AddListener(EventName.DestroyLoading, callback)
    local function callback()
        self:UpdateVipOutDate()
        self:StartVFourMention()
        self:CheckIsShowGundam()
    end
    --self.bind_data_event = RoleInfoModel:GetInstance():GetMainRoleData():BindData("level", handler(self, self.UpdateVipOutDate))
    self.bind_data_event = RoleInfoModel:GetInstance():GetMainRoleData():BindData("level", callback)

    self.fetch_vfour_rebate_event_id = GlobalEvent:AddListener(VipEvent.SuccessFetchRebate, handler(self, self.UpdateVipOutDate))
    self.vfour_rd_event_id = GlobalEvent:AddListener(VipEvent.ChangeVFourRD, handler(self, self.SetVFourRedDot))

    -----活动图标相关
    local function call_back(id)
        local item = self.icon_list[id]
        if not item then
            self:LoadIcon()
        end
    end
    self.model_event_list[#self.model_event_list + 1] = self.model:AddListener(MainEvent.AddLeftIcon, call_back)

    local function call_back(id)
        local item = self.icon_list[id]
        if item then
            item:destroy()
            self.icon_list[id] = nil
            self:LoadIcon()
        end
    end
    self.model_event_list[#self.model_event_list + 1] = self.model:AddListener(MainEvent.RemoveLeftIcon, call_back)

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
    self.model_event_list[#self.model_event_list + 1] = self.model:AddListener(MainEvent.UpdateLeftIcon, call_back)

    self.load_icon_event_id = GlobalEvent:AddListener(MainEvent.CheckLoadMainIcon, handler(self, self.HandleLoadIcon))
    ----------------------------

    --小贵族icon点击
    local function callback(  )
        GlobalEvent:Brocast(VipSmallEvent.OpenVipSmallPanel)
    end
    AddClickEvent(self.btn_vipsmall.gameObject,callback)

    --小贵族icon红点改变事件
    local function callback(is_show)
        self:SetVipSmallIconRedDot(is_show)
    end
    self.vipsmall_icon_reddot_change_event_id = GlobalEvent:AddListener(VipSmallEvent.VipSmallIconReddotChange, callback)

    --小贵族等级奖励领取事件
    local function callback(  )
        self.is_can_show_vip_small_btn = VipSmallModel.GetInstance():IsCanShowVipSmallIcon()
        self:CheckIsShowVipSmallIcon()
    end
    self.handle_vip2_fetch_event_id = VipSmallModel.GetInstance():AddListener(VipSmallEvent.HandleVip2Fetch,callback)

    --小贵族信息返回事件
    local function callback(  )
        self.is_can_show_vip_small_btn = VipSmallModel.GetInstance():IsCanShowVipSmallIcon()
        self:CheckIsShowVipSmallIcon()
    end
    self.handle_vip2_info_event_id = VipSmallModel.GetInstance():AddListener(VipSmallEvent.HandleVip2Info,callback)
end

function MainTopLeft:HandleLoadIcon(id)
    local item = self.icon_list[id]
    if not item then
        self:LoadIcon()
    end
end

function MainTopLeft:CheckIsShowRenameIcon()
    local switch_type = MainModel:GetInstance():GetSwitchType()
    if switch_type == MainModel.SwitchType.City then
        if self.isShowRename then
            SetVisible(self.btn_realname, true)
        end
    elseif switch_type == MainModel.SwitchType.Dungeon then
        SetVisible(self.btn_realname, false)
    end
end

function MainTopLeft:CheckIsShowVipIcon()
    local switch_type = MainModel:GetInstance():GetSwitchType()
    if switch_type == MainModel.SwitchType.City then
        if self.is_can_show_vfour_btn then
            SetVisible(self.vfour_icon, true)
        end
        if self.is_can_show_exp_btn then
            SetVisible(self.btn_exp, true)
        end
    elseif switch_type == MainModel.SwitchType.Dungeon then
        SetVisible(self.btn_exp, false)
    end
end

function MainTopLeft:ShowVFourCD()
    local day_sec = TimeManager.GetInstance().DaySec
    local end_time = VipModel.GetInstance().taste_etime + day_sec
    if end_time <= os.time() then
        SetVisible(self.timer, false)
        return
    end
    if not self.CDT then
        local param = {}
        param.isShowMin = true
        param.isShowHour = true
        param.nodes = { "cd" }
        param.formatText = "<color=#3dff58>%s</color>"
        self.CDT = CountDownText(self.timer, param)
        local function call_back()
            SetVisible(self.CDT, false)
        end
        self.CDT:StartSechudle(end_time, call_back)
    end
    SetVisible(self.timer, true)
end

function MainTopLeft:BindRoleUpdate(data)
    self.role_update_list = self.role_update_list or {}
    -- local function call_back()

    -- end
    -- self.role_update_list[#self.role_update_list+1] = self.role_data:BindData("name",call_back)
    local function call_back()
        self:SetLevel()
        self:SetExpVisible()
        self:CheckMarryShow()
        self:StartVFourMention()
    end
    self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData("level", call_back)
    local function call_back()
        self:SetPower()
    end
    self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData("power", call_back)

    local function call_back()
        self:UpdateVipOutDate()
        self:StartVFourMention()

        self.is_can_show_vip_small_btn = VipSmallModel.GetInstance():IsCanShowVipSmallIcon()
    end
    self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData("viplv", call_back)

    local function call_back()

        self:UpdateVipOutDate()
        self:StartVFourMention()
    end
    self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData("vipend", call_back)

    local function call_back()

        self:UpdateVipOutDate()
        self:StartVFourMention()
    end
    self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData("viptype", call_back)

    local function call_back()
        self:UpdateHp()
    end
    self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData("hp", call_back)
    local function call_back()
        self:UpdateHp()
    end
    self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData("hpmax", call_back)

    local function call_back()
        self:UpdateBuff()
    end
    self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData("buffs", call_back)

    -- 已经注释
    -- local function call_back()
    --     self:SetHead()
    -- end
    -- self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData("gender", call_back)

    local function call_back()
        self:SetGold()
    end
    self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData(Constant.GoldType.Gold, call_back)
    local function call_back()
        self:SetBGold()
    end
    self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData(Constant.GoldType.BGold, call_back)

    -- local function call_back()

    -- end
    -- self.role_update_list[#self.role_update_list+1] = self.role_data:BindData("coin",call_back)
    -- local function call_back()

    -- end
    -- self.role_update_list[#self.role_update_list+1] = self.role_data:BindData("bcoin",call_back)
end

function MainTopLeft:SetExpVisible()
    if self.role_data.level >= 300 then
        SetVisible(self.btn_exp, false)
        self.is_can_show_exp_btn = false
    end
end

function MainTopLeft:SetLevel()
    if not self.role_data or not self.is_loaded then
        return
    end
    local lv = self.role_data.level
    local result = lv
    local img_idx = 1
    local critical = String2Table(Config.db_game.level_max.val)[1]
    if lv > critical then
        result = lv - critical
        img_idx = 2
    end
    lua_resMgr:SetImageTexture(self, self.lv_frame_img, "main_image", "img_main_role_lv_bg_" .. img_idx, false, nil, false)
    self.text_lv_component.text = result
end

function MainTopLeft:SetGold()
    if not self.role_data or not self.is_loaded then
        return
    end
    local value = self.role_data[Constant.GoldType.Gold] or 0
    self.text_gold_component.text = GetShowNumber(value)
end

function MainTopLeft:SetBGold()
    if not self.role_data or not self.is_loaded then
        return
    end
    local value = self.role_data[Constant.GoldType.BGold] or 0
    self.text_bgold_component.text = GetShowNumber(value)
end

function MainTopLeft:UpdateHp()
    if not self.role_data or not self.role_data.attr or not self.role_data.hp or not self.role_data.hpmax or not self.is_loaded then
        return
    end
    local value = self.role_data.hp / self.role_data.hpmax
    -- self.blood_component.fillAmount = value
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.blood_component)
    local value_action = cc.ValueTo(0.2, value, self.blood_component, "fillAmount")
    cc.ActionManager:GetInstance():addAction(value_action, self.blood_component)
    self.text_blood_component.text = string.format("%s/%s", GetShowNumber(self.role_data.hp, 13), GetShowNumber(self.role_data.hpmax, 13))
    -- self.text_blood_component.text = string.format("%s/%s", (self.role_data.hp), (self.role_data.hpmax))
end

function MainTopLeft:SetPower()
    if not self.role_data or not self.is_loaded then
        return
    end
    self.text_power_component.text = (self.role_data.power or 0)
end

function MainTopLeft:SetData()
    if not self.is_loaded then
        self.is_need_setdata = true
        return
    end
    self.is_need_setdata = false
    self.is_set_data = true

    self:SetLevel()
    self:SetPower()
    self:SetBGold()
    self:SetGold()
    self:UpdateHp()
    self:UpdateBuff()
end

function MainTopLeft:UpdateBuff()
    if not self.is_loaded then
        self.is_need_update_buff = true
        return
    end
    local function call_back()
        self:UpdateBuff()
    end
    local list = self.role_data:GetShowBuffList() or {}
    local start_index = 1
    local len = #list
    if len > 7 then
        start_index = #list - 7 + 1
    end
    local count = 0
    for i = start_index, len do
        count = count + 1
        local item = self.buff_list[count]
        if not item then
            item = MainBuffIconItem(self.img_buff_icon_gameobject)
            item:SetCallBack(call_back)
            self.buff_list[count] = item
            local x = self.buff_start_pos.x + (count - 1) * 34 + 8.5
            local y = self.buff_start_pos.y + 1.5
            item:SetPosition(x, y)
        end
        item:SetData(list[i], i)
    end

    local length = #self.buff_list
    for i = count + 1, length do
        local item = self.buff_list[i]
        item:destroy()
        self.buff_list[i] = nil
    end
end

function MainTopLeft:UpdateVipOutDate()
    if not self.role_data.viplv then
        return
    end
    local switch_type = MainModel:GetInstance():GetSwitchType()
    if self.role_data.viplv ~= 0 then
        local restTime = self.role_data.vipend - os.time()
        if restTime <= 0 then
            self:SetOutDate()
        else
            SetVisible(self.timer, false)
            --未过期
            self.model.is_vip_out_date = false
            if self.role_data.viplv < 4 then
                local is_show = self:IsEnoughLevelShowVFourIcon()
                SetVisible(self.vfour_icon, is_show)
                self.is_can_show_vfour_btn = is_show
            else
                --尚未获取返利
                local is_show = false
                if not VipModel.GetInstance():IsFetchedRebate() then
                    is_show = true
                end
                SetVisible(self.vfour_icon, is_show)
                self.is_can_show_vfour_btn = is_show
            end
            self.vipText.text = "v" .. self.role_data.viplv
            --SetVisible(self.btn_exp, false)
            if self.role_data.viptype == 1 then
                SetVisible(self.tasteArea, true)
                SetVisible(self.vfour_icon, false)
                self.is_can_show_vfour_btn = false
                if not self.countdowntext then
                    --SetVisible(self.TitleText,false)
                    local item = TitleText(newObject(self.TitleText))
                    SetVisible(self.TitleText, false)
                    self.countdowntext = CountDownText(item, { isShowMin = true, isShowHour = true })
                    table.insert(self.countDownList, item)
                    item.transform:SetParent(self.tasteArea.transform);
                    SetLocalScale(item.transform, 1, 1, 1);
                    SetLocalPosition(item.transform, -53, 1.7, 0);
                end
                local function call_back()
                    self:SetOutDate()
                    if self.countdowntext then
                        SetVisible(self.countdowntext, false)
                        self.countdowntext = nil
                    end
                end
                self.countdowntext:StartSechudle(self.role_data.vipend, call_back)
                self.is_can_show_exp_btn = false
            else
                SetVisible(self.tasteArea, false)
                local exp = VipModel.GetInstance():GetVipExpPool()
                if exp > 0 then
                    local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
                    if lv >= 300 then
                        SetVisible(self.btn_exp, false)
                        self.is_can_show_exp_btn = false
                    else
                        if switch_type == MainModel.SwitchType.City then
                            SetVisible(self.btn_exp, true)
                        end
                        self.isCanGetVipExpPool = true
                        self.is_can_show_exp_btn = true
                    end
                    self:SetExpRedDot(true)
                else
                    self.isCanGetVipExpPool = false
                    SetVisible(self.btn_exp, false)
                    self.is_can_show_exp_btn = false
                    self:SetExpRedDot(false)
                end
            end
            if self.schedule then
                GlobalSchedule:Stop(self.schedule)
                self.schedule = nil
            end
            self.schedule = GlobalSchedule.StartFun(handler(self, self.CoutVipTime), 1, -1)
        end
    else
        if self.model.is_vip_out_date then
            self.model.is_vip_out_date = false
        end
        self.vipText.text = "v" .. self.role_data.viplv
        SetVisible(self.btn_exp, false)
        self.is_can_show_exp_btn = false
        self.is_can_show_vfour_btn = self:IsEnoughLevelShowVFourIcon()
    end
end

function MainTopLeft:IsEnoughLevelShowVFourIcon()
    local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    return lv >= 61
end

function MainTopLeft:SetExpRedDot(isShow)
    if not self.exp_red_dot then
        self.exp_red_dot = RedDot(self.exp_red_con, nil, RedDot.RedDotType.Nor)
    end
    self.exp_red_dot:SetPosition(0, 0)
    self.exp_red_dot:SetRedDotParam(isShow)
end

function MainTopLeft:CoutVipTime()
    if self.model.is_vip_out_date then
        self.model.is_vip_out_date = false
    end
    local timeTab = TimeManager:GetLastTimeData(os.time(), self.role_data.vipend);
    if not timeTab then
        if self.schedule then
            GlobalSchedule:Stop(self.schedule);
        end
        self:SetOutDate()
        self.schedule = nil
    end
end

function MainTopLeft:SetOutDate()
    local switch_type = MainModel:GetInstance():GetSwitchType()
    if RoleInfoModel.GetInstance():GetRoleValue("viptype") == enum.VIP_TYPE.VIP_TYPE_TASTE and self.model.is_vip_out_date == false then
        local end_time = VipModel.GetInstance().taste_etime + 5
        --在第一次结束体验之后，不打开
        self.model.is_vip_out_date = true
        self:ShowVFourCD()
        if os.time() <= end_time then
            MainIconOpenLink(403, 1)
        end
    end
    self.isCanGetVipExpPool = false
    self.vipText.text = "x"
    local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    if lv >= 300 then
        SetVisible(self.btn_exp, false)
        self.is_can_show_exp_btn = false
    else
        if switch_type == MainModel.SwitchType.City then
            SetVisible(self.btn_exp, true)
        end
        self.is_can_show_exp_btn = true
    end
    SetVisible(self.tasteArea, false)
    --新手体验之后才显示
    local is_show = self.role_data.viplv < 4
    if is_show then
        is_show = self:IsEnoughLevelShowVFourIcon()
    else
        --大于V4,尚未领取返利
        if not VipModel.GetInstance():IsFetchedRebate() then
            is_show = true
        end
    end
    SetVisible(self.vfour_icon, is_show)
    self.is_can_show_vfour_btn = is_show
end

--vip按钮红点
function MainTopLeft:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
        self.red_dot:SetPosition(0, 0)
        self.red_dot:SetVisible(true)
        LayerManager.GetInstance():AddOrderIndexByCls(self, self.red_dot.transform, nil, true, nil, false, 2)
    end
    self.red_dot:SetRedDotParam(isShow)
end

function MainTopLeft:ShowMarryIcon()
    self.isMarryShow = MarryModel:GetInstance().isShowMatchIcon
    SetVisible(self.btn_marry, self.isMarryShow)
end

function MainTopLeft:CheckMarryShow()
    local level = RoleInfoModel:GetInstance():GetRoleValue("level")
    local lv = Config.db_advertise[4].level
    local taskID = Config.db_advertise[4].task_id
    local closeLV = 75
    self.isMarryShow = false
    if (level >= lv and level < closeLV) or lv == 0 then
        if taskID == 0 or TaskModel:GetInstance():IsFinishMainTask(taskID) or
                (TaskModel:GetInstance():GetTask(taskID) and TaskModel:GetInstance():GetTask(taskID).state == enum.TASK_STATE.TASK_STATE_ACCEPT) then
            self.isMarryShow = true
        end
    end

    if level > closeLV then
        self.isMarryShow = false
    end

    local switch_type = MainModel:GetInstance():GetSwitchType()
    if switch_type == MainModel.SwitchType.Dungeon then
        self.isMarryShow = false
    end
    SetVisible(self.btn_marry, self.isMarryShow)
end

--------------------V4气泡提醒
function MainTopLeft:StartVFourMention()
    self:StopMention()
    local lv = RoleInfoModel.GetInstance():GetMainRoleVipLevel(true)
    local end_time = VipModel.GetInstance().taste_etime
    if end_time <= os.time() and lv < 4 then
        local time = 60 * 15
        self.mention_sche = GlobalSchedule.StartFun(handler(self, self.CheckMentionShow), time, -1)
    end
end

function MainTopLeft:CheckMentionShow()
    local lv = RoleInfoModel.GetInstance():GetMainRoleVipLevel(true) or 0
    local is_show = lv < 4
    if not is_show then
        self:StopMention()
        SetVisible(self.tip, is_show)
        return
    end
    SetVisible(self.tip, is_show)
    --显示气泡之后
    if is_show then
        if self.close_tip_sche then
            GlobalSchedule:Stop(self.close_tip_sche)
            self.close_tip_sche = nil
        else
            self.close_tip_sche = GlobalSchedule.StartFun(handler(self, self.CheckCloseMention), 1, -1)
        end
    end
end

function MainTopLeft:CheckCloseMention()
    self.tips_clsoe_time = self.tips_clsoe_time - 1
    if self.tips_clsoe_time == 5 or self.tips_clsoe_time == 1 then
        self:ShowBlinkAct()
    elseif self.tips_clsoe_time == 0 then
        if self.close_tip_sche then
            GlobalSchedule:Stop(self.close_tip_sche)
            self.close_tip_sche = nil
        end
        self.tips_clsoe_time = 10
        SetVisible(self.tip, false)
    end
end

function MainTopLeft:ShowBlinkAct()
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.tip)
    local action_zero = cc.ScaleTo(0.1, 0.8)
    local action = cc.Sequence(action_zero, cc.ScaleTo(0.1, 1))
    action = cc.Repeat(action, 2)
    cc.ActionManager:GetInstance():addAction(action, self.tip)
end

function MainTopLeft:StopMention()
    if self.mention_sche then
        GlobalSchedule:Stop(self.mention_sche)
        self.mention_sche = nil
    end
end

function MainTopLeft:SetVFourRedDot(isShow)
    if not self.vfour_rd then
        self.vfour_rd = RedDot(self.vfour_rd_con, nil, RedDot.RedDotType.Nor)
    end
    self.vfour_rd:SetPosition(0, 0)
    self.vfour_rd:SetRedDotParam(isShow)
end

function MainTopLeft:FirstPayTip()
    local open_time = RoleInfoModel:GetInstance():GetRoleValue("ctime")
    local now = os.time()
    if now >= open_time then
        local x, y, scale = -224, 115, 0.8
        if now - open_time <= 1800 and not FirstPayModel.GetInstance():IsFirstPay() then
            local level = RoleInfoModel:GetInstance():GetRoleValue("level")
            if level >= 76 then
                if not self.firstpay_item then
                    self.firstpay_item = MainFirstPayTipItem(self.transform)
                    SetLocalPositionXY(self.firstpay_item.transform, x, y)
                end
                local oldx, oldy = GetLocalPosition(self.firstpay_item.transform)
                if oldx ~= x or oldy ~= y then
                    SetLocalPositionXY(self.firstpay_item.transform, x, y)
                    SetLocalScale(self.firstpay_item.transform, scale, scale, scale)
                end
            end
        else
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
end
-----------------

---------------------------------------活动图标
function MainTopLeft:LoadIcon(is_first)
    local list = {}
    for key_str, v in pairs(self.model.left_top_icon_list) do
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
    local pos = { -300, 240 }
    local start_pos = { x = pos[1], y = pos[2] }
    local offx = 0
    local count = 1
    for i = 1, #list do
        local info = list[i]
        local cf = info.cf
        local item = self.icon_list[info.key]
        local is_exist = true
        if not item then
            item = MainTopLeftItem(self.MainTopLeftItem_gameObject, self.transform)
            self.icon_list[info.key] = item
            item:SetData(info)
            item:SetRowIdx(cf.row)
            SetAsFirstSibling(item.transform)
            is_exist = false
        end

        local x, y
        local line = cf.row
        local line_index
        if line == 1 then
            line_index1 = line_index1 + 1
            line_index = line_index1 - 1
            x, y = start_pos.x + line_index * width, start_pos.y
        elseif line == 2 then
            line_index2 = line_index2 + 1
            line_index = line_index2 - 1
            x = (start_pos.x + 2 * width) + line_index * width
            y = start_pos.y - height
        else
            line_index3 = line_index3 + 1
            line_index = line_index3 - 1
            x = (start_pos.x + 2 * width) + line_index * width
            y = start_pos.y - height * 2
            -- ffh 刘海屏适配
            x = x - UIAdaptManager:GetInstance():GetBanScreenOffsetX()
        end

        local sibling_index = #list - i + 1
        item:SetSiblingIndex(sibling_index)
        item:SetStartPos(x, y)

        item:SetLineIndex(line, line_index, i, cf.is_Show)
        if not is_exist then
            item:SetVisible(true)
        end
        if not is_exist and not is_first then
            item:BirthAction()
            local sibling_index = #list
            item:SetSiblingIndex(sibling_index)
        end

        --z轴改成0 要不然无法合批
        SetLocalPositionZ(item.transform, 0)
    end
end

function MainTopLeft:AddTopRightListen()
    local function call_back(id)
        if id ~= "sevenDayActive" then
            return
        end
        local item = self.icon_list[id]
        if not item then
            self:LoadIcon()
        end
    end
    self.model_event_list[#self.model_event_list + 1] = self.model:AddListener(MainEvent.AddRightIcon, call_back)

    local function call_back(id)
        if id ~= "sevenDayActive" then
            return
        end
        local item = self.icon_list[id]
        if item then
            item:destroy()
            self.icon_list[id] = nil
            self:LoadIcon()
        end
    end
    self.model_event_list[#self.model_event_list + 1] = self.model:AddListener(MainEvent.RemoveRightIcon, call_back)

    local function call_back(id, update_type)
        if id ~= "sevenDayActive" then
            return
        end
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

end
--------------------------------------

function MainTopLeft:dctor()
    destroySingle(self.gundam_red_dot)
    self.gundam_red_dot = nil
    if self.cross_day_event_id then
        GlobalEvent:RemoveListener(self.cross_day_event_id)
        self.cross_day_event_id = nil
    end
    destroySingle(self.loop_wait_cdt)
    self.loop_wait_cdt = {}
    if self.delay_show_gundam_sche_id then
        GlobalSchedule:Stop(self.delay_show_gundam_sche_id)
        self.delay_show_gundam_sche_id = nil
    end
    if self.load_icon_event_id then
        GlobalEvent:RemoveListener(self.load_icon_event_id)
        self.load_icon_event_id = nil
    end
    if not table.isempty(self.model_event_list) then
        for i, v in pairs(self.model_event_list) do
            self.model:RemoveListener(v)
        end
        self.model_event_list = {}
    end
    destroyTab(self.icon_list)
    self.icon_list = {}
    if self.vfour_rd then
        self.vfour_rd:destroy()
        self.vfour_rd = nil
    end
    if self.close_tip_sche then
        GlobalSchedule:Stop(self.close_tip_sche)
        self.close_tip_sche = nil
    end
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.tip)
    self:StopMention()
    if self.bind_data_event then
        RoleInfoModel.GetInstance():GetMainRoleData():RemoveListener(self.bind_data_event)
        self.bind_data_event = nil
    end
    if self.CDT then
        self.CDT:destroy()
        self.CDT = nil
    end
    if self.delay_sche then
        GlobalSchedule:Stop(self.delay_sche)
        self.delay_sche = nil
    end
    if self.loading_destroy_event_id then
        GlobalEvent:RemoveListener(self.loading_destroy_event_id)
        self.loading_destroy_event_id = nil
    end
    if self.fetch_vfour_rebate_event_id then
        GlobalEvent:RemoveListener(self.fetch_vfour_rebate_event_id)
        self.fetch_vfour_rebate_event_id = nil
    end
    if self.vfour_rd_event_id then
        GlobalEvent:RemoveListener(self.vfour_rd_event_id)
        self.vfour_rd_event_id = nil
    end
    if self.scene_change_end_event_id then
        GlobalEvent:RemoveListener(self.scene_change_end_event_id)
        self.scene_change_end_event_id = nil
    end
    if self.role_icon then
        self.role_icon:destroy()
        self.role_icon = nil
    end
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.blood_component)
    if self.event_id then
        RoleInfoModel:GetInstance():RemoveListener(self.event_id)
        self.event_id = nil
    end
    if self.role_update_list and self.role_data then
        for k, event_id in pairs(self.role_update_list) do
            self.role_data:RemoveListener(event_id)
        end
        self.role_update_list = nil
    end
    if self.hidebtnexpicon_event_id then
        GlobalEvent:RemoveListener(self.hidebtnexpicon_event_id)
        self.hidebtnexpicon_event_id = nil
    end
    if self.close_loading_event_id then
        GlobalEvent:RemoveListener(self.close_loading_event_id)
        self.close_loading_event_id = nil
    end
    for k, item in pairs(self.buff_list) do
        item:destroy()
    end
    self.buff_list = {}

    for k, item in pairs(self.countDownList) do
        item:destroy()
    end
    self.countDownList = {}

    if self.countdowntext then
        self.countdowntext:destroy()
    end
    self.countdowntext = nil

    if self.schedule then
        GlobalSchedule:Stop(self.schedule);
    end
    self.schedule = nil

    if self.realName_event_id then
        GlobalEvent:RemoveListener(self.realName_event_id)
        self.realName_event_id = nil
    end

    if self.vip_rd_event_id then
        GlobalEvent:RemoveListener(self.vip_rd_event_id)
        self.vip_rd_event_id = nil
    end

    if self.marrymatch_event_id then
        GlobalEvent:RemoveListener(self.marrymatch_event_id)
        self.marrymatch_event_id = nil
    end
    if self.marrymatch_event_id2 then
        GlobalEvent:RemoveListener(self.marrymatch_event_id2)
        self.marrymatch_event_id2 = nil
    end

    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
    if self.exp_red_dot then
        self.exp_red_dot:destroy()
        self.exp_red_dot = nil
    end
    if self.firstpaytip_schedule then
        GlobalSchedule:Stop(self.firstpaytip_schedule)
        self.firstpaytip_schedule = nil
    end
    if self.firstpay_item then
        self.firstpay_item:destroy()
        self.firstpay_item = nil
    end

    destroySingle(self.vipsmall_reddot)
    self.vipsmall_reddot = nil
    if self.vipsmall_icon_reddot_change_event_id then
        GlobalEvent:RemoveListener(self.vipsmall_icon_reddot_change_event_id)
        self.vipsmall_icon_reddot_change_event_id = nil
    end

    if self.handle_vip2_fetch_event_id then
        VipSmallModel.GetInstance():RemoveListener(self.handle_vip2_fetch_event_id)
        self.handle_vip2_fetch_event_id = nil
    end

    if self.handle_vip2_info_event_id then
        VipSmallModel.GetInstance():RemoveListener(self.handle_vip2_info_event_id)
        self.handle_vip2_info_event_id = nil
    end
end

---------------------------------------------------------------------机甲活动
--机甲图标
function MainTopLeft:CheckIsShowGundam()
    local create_time = RoleInfoModel.GetInstance():GetMainRoleData().ctime
    local game_time = os.time() - create_time
    local is_show = true
    if game_time <= 0 then
        is_show = false
    end
    local opdays = LoginModel.GetInstance():GetOpenTime()
    if opdays < 0 or opdays > 3 then
        --活动过期
        is_show = false
    end
    if not is_show then
        self:EndGundamAct()
        return
    end
    if game_time < self.show_gundam_time then
        --未到显示时间，开始显示的计时
        SetVisible(self.btn_gundam, false)
        self:StartShowGundamCD(create_time)
    else
        self:ShowGundamIcon()
    end

   
end

function MainTopLeft:StartShowGundamCD(c_time)
    if self.delay_show_gundam_sche_id then
        return
    end
    local tar_stamp = c_time + self.show_gundam_time
    self.delay_stamp = tar_stamp - os.time()

    self.delay_show_gundam_sche_id = GlobalSchedule.StartFun(handler(self, self.CountTime), 1, -1);
end
function MainTopLeft:CountTime()
    self.delay_stamp = self.delay_stamp - 1
    if self.delay_stamp <= 0 then
        self:StopDelayShowGundamSch()
        self:ShowGundamIcon()
    end
end
function MainTopLeft:StopDelayShowGundamSch()
    if self.delay_show_gundam_sche_id then
        GlobalSchedule:Stop(self.delay_show_gundam_sche_id)
        self.delay_show_gundam_sche_id = nil
    end
end

--31分钟之后显示
function MainTopLeft:ShowGundamIcon()
    local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    local text_str = "gundam_text_1"
    if lv < self.show_gundam_lv then
        --未到达机甲任务开启等级,开启循环20小时倒计时
        self:StartLoopCD()
    else
        --到达
        self:StartActCD()
        text_str = "gundam_text_2"
    end
    lua_resMgr:SetImageTexture(self, self.gundam_icon_img, "main_image", text_str, false, nil, false)
    SetVisible(self.btn_gundam, true)
end
--到达180级之前的循环倒计时 20小时
function MainTopLeft:StartLoopCD()
    local create_time = RoleInfoModel.GetInstance():GetMainRoleData().ctime
    --角色时间
    local play_time = os.time() - create_time
    --已经过的循环次数
    local times = math.ceil(play_time / self.loop_wait_for_lv_up_time)
    --此次倒计时循环 剩余倒数时间
    local remain = play_time - (times * self.loop_wait_for_lv_up_time)
    if remain <= 0 then
        remain = (times * self.loop_wait_for_lv_up_time) - play_time
    end
    local param = {}
    param.isShowMin = true
    param.isShowHour = true
    param.nodes = { "cd" }
    if self.loop_wait_cdt then
        self.loop_wait_cdt:StopSchedule()
        self.loop_wait_cdt:ResetParam(param)
    else
        self.loop_wait_cdt = CountDownText(self.time_con, param)
    end
    local function call_back()
        --时间到了之后再次执行倒计时（由升级事件进行中断）
        self:CheckIsShowGundam()
    end
    self.loop_wait_cdt:StartSechudle(os.time() + remain, call_back)
end

function MainTopLeft:StartActCD()
    local opdays = LoginModel.GetInstance():GetOpenTime()
    if opdays < 0 or opdays > 3 then
        self:EndGundamAct()
    end
    local tar_stamp = TimeManager:GetTomorZeroTime()
    for i = opdays, 3 do
        if i ~= 3 then
            tar_stamp = tar_stamp + TimeManager.DaySec
        end
    end
    local param = {}
    param.isShowMin = true
    param.isShowHour = true
    param.nodes = { "cd" }
    if self.loop_wait_cdt then
        self.loop_wait_cdt:StopSchedule()
        self.loop_wait_cdt:ResetParam(param)
    else
        self.loop_wait_cdt = CountDownText(self.time_con, param)
    end
    local function call_back()
        --时间到了之后再次执行倒计时（由升级事件进行中断）
        self:StartLoopCD()
    end
    self.loop_wait_cdt:StartSechudle(tar_stamp, call_back)
end

function MainTopLeft:EndGundamAct()
    SetVisible(self.btn_gundam, false)
    if self.loop_wait_cdt then
        self.loop_wait_cdt:StopSchedule()
    end
    self:StopDelayShowGundamSch()
end

function MainTopLeft:SetGundamRedDot(isShow)
    if not self.gundam_red_dot then
        self.gundam_red_dot = RedDot(self.gundam_red_con, nil, RedDot.RedDotType.Nor)
    end
    self.gundam_red_dot:SetPosition(0, 0)
    self.gundam_red_dot:SetRedDotParam(isShow)
end

---------------------------------------------------------------------机甲活动

--检查是否显示小贵族图标
function MainTopLeft:CheckIsShowVipSmallIcon(  )
    --logError("CheckIsShowVipSmallIcon,--"..tostring(self.is_can_show_vip_small_btn))
    local switch_type = MainModel:GetInstance():GetSwitchType()
    if switch_type == MainModel.SwitchType.City then
        SetVisible(self.btn_vipsmall,self.is_can_show_vip_small_btn)
    elseif switch_type == MainModel.SwitchType.Dungeon then
        SetVisible(self.btn_vipsmall,false)
    end
end

--设置小贵族红点显示
function MainTopLeft:SetVipSmallIconRedDot(is_show)
    --logError("SetVipSmallIconRedDot,--"..tostring(is_show))
    if not self.vipsmall_reddot then
        self.vipsmall_reddot = RedDot(self.vipsmall_red_con)
    end
    self.vipsmall_reddot:SetPosition(0, 0)
    self.vipsmall_reddot:SetRedDotParam(is_show)
end