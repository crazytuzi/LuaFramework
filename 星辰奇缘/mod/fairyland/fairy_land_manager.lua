FairyLandManager = FairyLandManager or BaseClass(BaseManager)

function FairyLandManager:__init()
    if FairyLandManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    FairyLandManager.Instance = self;
    self:InitHandler()
    self.timer_id = 0

    -- self.mark_lev = RoleManager.Instance.RoleData.lev
    self.model = FairyLandModel.New()

    self.OnUpdate = EventLib.New()
end

function FairyLandManager:__delete()
    self.model:DeleteMe()
    self.model = nil
    self.OnUpdate:DeleteMe()
    self.OnUpdate = nil
end

function FairyLandManager:InitHandler()
    self:AddNetHandler(14600,self.on14600)
    self:AddNetHandler(14601,self.on14601)
    self:AddNetHandler(14602,self.on14602)
    self:AddNetHandler(14603,self.on14603)
    self:AddNetHandler(14604,self.on14604)
    self:AddNetHandler(14605,self.on14605)
    self:AddNetHandler(14606,self.on14606)
    self:AddNetHandler(19200,self.on19200)
    self:AddNetHandler(19201,self.on19201)
    self:AddNetHandler(19202,self.on19202)
    self:AddNetHandler(19203,self.on19203)

    self.on_mainui_btn_init = function(data)
        FairyLandManager.Instance:request14600()
        FairyLandManager.Instance:request19200()
    end
    EventMgr.Instance:AddListener(event_name.mainui_btn_init, self.on_mainui_btn_init)

    self.on_scene_loaded = function(data)
        self:on_scene_loaded_finish()
    end
    EventMgr.Instance:AddListener(event_name.scene_load, self.on_scene_loaded)

    self.on_role_change = function(data)
        self:request14600()
        self:request19200()
    end
    EventMgr.Instance:AddListener(event_name.role_level_change, self.on_role_change)


end

--场景地图加载完成
function FairyLandManager:on_scene_loaded_finish()
    if self.model:check_player_in_fairy_land() == false and SceneManager.Instance:CurrentMapId() ~= DataFairy.data_layer[0].map then
        if self.baseEffectView == nil then
            local fun = function(effectView)
                local effectObject = effectView.gameObject
                effectObject.transform:SetParent(SceneManager.Instance.MainCamera.gameObject.transform)
                effectObject.transform.localScale = Vector3.one
                effectObject.transform.localPosition = Vector3(0, 0, 0)
                effectObject.transform.localRotation = Quaternion.identity
                Utils.ChangeLayersRecursively(effectObject.transform, "SceneEffect")

                if BaseUtils.IsWideScreen() then
                    local scaleX = (ctx.ScreenWidth / ctx.ScreenHeight) / (16 / 9)
                    effectObject.transform.localScale = Vector3(scaleX, 1, 1)
                else
                    local scaleY = (ctx.ScreenHeight/ ctx.ScreenWidth) / (9 / 16)
                    effectObject.transform.localScale = Vector3(1, scaleY, 1)
                end
            end
            self.baseEffectView = BaseEffectView.New({effectId = 20120, time = nil, callback = fun})
        end
    else
        if self.baseEffectView ~= nil then
            self.baseEffectView:DeleteMe()
        end
    end
end


-----------------------------------协议接收逻辑
--活动状态返回
function FairyLandManager:on14600(data)
    -- print("--------------------------------------收到14600")

    local cfg_data = DataSystem.data_daily_icon[101]
    if cfg_data.lev > RoleManager.Instance.RoleData.lev then
        --等级不够，图标和弹窗都不要
        return
    end
    AgendaManager.Instance:SetCurrLimitID(2006, data.status == 2 or data.status == 1)
    if self.model.status ~= data.status and data.status ~= 0 then
        if self.model:check_player_in_fairy_land() then
            --弹出确认框，通知是否参加
            if ActivityManager.Instance:GetNoticeState(GlobalEumn.ActivityEumn.fairy) == false then
                --没有提示，则提示一下
                local str = string.format("%s%s", TI18N("彩虹冒险") , TI18N("活动即将开启，是否前往参加？"))
                if data.status == 2 then
                    str = string.format("%s%s", TI18N("彩虹冒险") , TI18N("活动已经开启，是否前往参加？"))
                end

                local confirmData = NoticeConfirmData.New()
                confirmData.type = ConfirmData.Style.Normal
                confirmData.content = str
                confirmData.sureLabel = TI18N("确认")
                confirmData.cancelLabel = TI18N("取消")
                confirmData.cancelSecond = 180
                confirmData.sureCallback = function() self:EnterSureCall() end

                if RoleManager.Instance.RoleData.cross_type == 1 then
                    -- 如果处在中央服，先回到本服在参加活动
                    RoleManager.Instance.jump_over_call = function() self:EnterSureCall() end
                    confirmData.sureCallback = SceneManager.Instance.quitCenter
                    if data.status == 2 then
                        confirmData.content = TI18N("<color=#FFFF00>彩虹冒险</color>活动已开启，是否<color='#ffff00'>返回原服</color>参加？")
                    else
                        confirmData.content = TI18N("<color=#FFFF00>彩虹冒险</color>活动即将开启，是否<color='#ffff00'>返回原服</color>参加？")
                    end
                end

                NoticeManager.Instance:ActiveConfirmTips(confirmData)

                ActivityManager.Instance:MarkNoticeState(GlobalEumn.ActivityEumn.fairy)
            end
        end
    end
    self.model.status = data.status --"0未开始，1通知，2开始"
    self:stop_timer()
    if self.model.status ~= 0 then
        --出现按钮
        local click_callback = function()
            if RoleManager.Instance.RoleData.cross_type == 1 then
                -- 如果处在中央服，先回到本服在参加活动
                local confirmData = NoticeConfirmData.New()
                confirmData.type = ConfirmData.Style.Normal
                confirmData.sureSecond = -1
                confirmData.cancelSecond = 180
                confirmData.sureLabel = TI18N("确认")
                confirmData.cancelLabel = TI18N("取消")
                RoleManager.Instance.jump_over_call = function() self:request14601() end
                confirmData.sureCallback = SceneManager.Instance.quitCenter
                confirmData.content = string.format("<color='#ffff00'>%s</color>%s", TI18N("彩虹冒险"), TI18N("活动已开启，是否<color='#ffff00'>返回原服</color>参加？"))
                NoticeManager.Instance:ConfirmTips(confirmData)
            else
                self:request14601()
            end
        end

        local timeout_callback = function()
            self:request14600()
        end
        local timestamp = data.timeout

        MainUIManager.Instance:DelAtiveIcon(cfg_data.id)

        local iconData = AtiveIconData.New()
        iconData.id = cfg_data.id
        iconData.iconPath = cfg_data.res_name
        iconData.clickCallBack = click_callback
        iconData.sort = cfg_data.sort
        iconData.lev = cfg_data.lev
        if self.model.status == 2 then
            -- iconData.text = TI18N("已开启")
            iconData.timestamp = timestamp + Time.time
            iconData.timeoutCallBack = timeout_callback
            MainUIManager.Instance:AddAtiveIcon(iconData)
        else
            iconData.text = TI18N("报名中")
            MainUIManager.Instance:AddAtiveIcon(iconData)
        end
        self.model.left_time = data.timeout
        self:start_timer()
        if RoleManager.Instance.RoleData.event == RoleEumn.Event.Event_fairyland then
            if MainUIManager.Instance.mainuitracepanel ~= nil then
                if MainUIManager.Instance.mainuitracepanel.childTab[TraceEumn.ShowType.FairyLand] ~= nil then
                    MainUIManager.Instance.mainuitracepanel.childTab[TraceEumn.ShowType.FairyLand]:update_info(data)
                end
            end
        end
    else
        --关闭按钮
        MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
        self:stop_timer()
    end
end

function FairyLandManager:EnterSureCall()
    --寻路到npc
    local cfg_data = DataFairy.data_layer[99]
    local id_battle_id = BaseUtils.get_unique_npcid(cfg_data.neutral_unit[1], 10)
    SceneManager.Instance.sceneElementsModel:Self_AutoPath(cfg_data.map, id_battle_id, nil, nil, true)
end

--累计总耗时计时器
function FairyLandManager:start_timer()
    self:stop_timer()
    self.timer_id = LuaTimer.Add(0, 1000, function() self:timer_tick() end)
end

function FairyLandManager:stop_timer()
    if self.timer_id ~= 0 then
        LuaTimer.Delete(self.timer_id)
        self.timer_id = 0
    end
end

function FairyLandManager:timer_tick()
    self.model.left_time = self.model.left_time - 1
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.Event_fairyland then
        if MainUIManager.Instance.mainuitracepanel ~= nil then
            if MainUIManager.Instance.mainuitracepanel.childTab[TraceEumn.ShowType.FairyLand] ~= nil then
                MainUIManager.Instance.mainuitracepanel.childTab[TraceEumn.ShowType.FairyLand]:timer_tick(data)
            end
        end
    end
end


--参与返回
function FairyLandManager:on14601(data)
    -- print("-----------------------------------收到14601")
    if data.flag == 0 then
        --失败
    elseif data.flag == 1 then
        --成功

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--退出返回
function FairyLandManager:on14602(data)
    -- print("-----------------------------------收到14602")
    if data.flag == 0 then
        --失败
    elseif data.flag == 1 then
        --成功
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--查看当前活动状态返回
function FairyLandManager:on14603(data)
    -- print("-----------------------------------收到14603")
    self.model.cur_fairy_data = data
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.Event_fairyland then
        if MainUIManager.Instance.mainuitracepanel.childTab[TraceEumn.ShowType.FairyLand] ~= nil then
            MainUIManager.Instance.mainuitracepanel.childTab[TraceEumn.ShowType.FairyLand]:update_info(data)
        end
    end
end

--收到boss奖励抽取机会
function FairyLandManager:on14604(data)
    -- print("---------------------------------收到14604")

    FinishCountManager.Instance.model.box_click_back_fun = function()
        self:request14605(data.boss_id)
    end
    FinishCountManager.Instance.model:InitBoxWin()
end

--收到boss奖励抽取结果
function FairyLandManager:on14605(data)
    -- print("---------------------------------收到14605")

    if data.flag == 0 then
        --失败
        FinishCountManager.Instance.model:CloseBoxWin()
    elseif data.flag == 1 then
        --成功
        local result_index = FinishCountManager.Instance.model.selected_box_index

        local one, two = 0, 0
        if result_index == 1 then
            one, two = 2, 3
        elseif result_index == 2 then
            one, two = 1, 3
        elseif result_index == 3 then
            one, two = 1, 2
        end
        local one_index = Random.Range(1, DataFairy.data_boss_reward_length/2)
        local two_index = Random.Range(DataFairy.data_boss_reward_length/2+1, DataFairy.data_boss_reward_length)

        local cfg_data_1 = DataFairy.data_boss_reward[one_index]
        local cfg_data_2 = DataFairy.data_boss_reward[two_index]
        --显示另外两个
        local data1 = {id = data.item_id, num = 1}
        local data2 = {id = cfg_data_1.item_id, num = 1}
        local data3 = {id = cfg_data_2.item_id, num = 1}
        FinishCountManager.Instance.model:UpdateBoxWinResult(result_index , data1)

        FinishCountManager.Instance.model:OpenOtherBox(one, two, data2, data3)
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--抽到宝箱惩罚
function FairyLandManager:on14606(data)
    -- print("====================================收到14606")
    --幻境宝箱
    self.model.roll_key = data.base_id
    self.model.roll_type = 1
    self.model.roll_id = data.type --1扣饱食度，2到指定层，3退指定层"
    self.model.roll_punish = data.num --"惩罚值"
    self.model:InitBoxUI()
end

--彩虹魔盒 活动通知
function FairyLandManager:on19200(data)
    self.model.luckDrawStatus = data.status
    self.model.luckDrawTimeout = data.timeout
    self:UpdateLuckDrawIcon()
end

--彩虹魔盒 传闻
function FairyLandManager:on19201(data)
    self.model.luckDrawLogs = data.logs
    self.OnUpdate:Fire("LuckdrawHearsay")
end

--彩虹魔盒 抽奖
function FairyLandManager:on19202(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        self.model.luckDrawTimes = data.times
        self.model.luckDrawId = data.id
        self.model.luckDrawPrizes = data.prizes
        self.OnUpdate:Fire("LuckdrawBegin")
    end
end

--彩虹魔盒 领奖
function FairyLandManager:on19203(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function FairyLandManager:UpdateLuckDrawIcon()
    local cfg_data = DataSystem.data_daily_icon[330]
    if cfg_data.lev > RoleManager.Instance.RoleData.lev then
        --等级不够，图标和弹窗都不要
        return
    end

    if self.model.luckDrawStatus ~= 0 then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("彩虹冒险已经结束，可消耗七彩水晶在<color='#ffff00'>魔盒</color>中抽奖，是否前去抽奖？")
        data.sureLabel = TI18N("抽奖")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function()
            self.model:InitFairylandLuckDrawWindow()
        end
        NoticeManager.Instance:ConfirmTips(data)
    end

    if RoleManager.Instance.RoleData.crystal < DataRaffle.data_cost[1].cost[1][2] then
        return
    end
    if self.model.luckDrawStatus ~= 0 then
        --出现按钮
        local click_callback = function()
            self.model:InitFairylandLuckDrawWindow()
        end

        local timeout_callback = function()
            MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
        end
        local timestamp = self.model.luckDrawTimeout

        MainUIManager.Instance:DelAtiveIcon(cfg_data.id)

        local iconData = AtiveIconData.New()
        iconData.id = cfg_data.id
        iconData.iconPath = cfg_data.res_name
        iconData.clickCallBack = click_callback
        iconData.sort = cfg_data.sort
        iconData.lev = cfg_data.lev
        iconData.timestamp = timestamp + Time.time
        iconData.timeoutCallBack = timeout_callback
        MainUIManager.Instance:AddAtiveIcon(iconData)

        self:UpdateLuckDrawIconRedPoint()
    else
        --关闭按钮
        MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
    end
end

function FairyLandManager:UpdateLuckDrawIconRedPoint()
    if RoleManager.Instance.RoleData.crystal > DataRaffle.data_cost[1].cost[1][2] then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(330, true)
    else
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(330, false)
    end
end

--------------------------------协议请求逻辑
--请求活动状态
function FairyLandManager:request14600()
    -- print("-----------------------------------请求14600")
    Connection.Instance:send(14600, {})
end

--请求参与
function FairyLandManager:request14601()
    -- print("-----------------------------------请求14601")
    Connection.Instance:send(14601, {})
end

--请求退出
function FairyLandManager:request14602(str)
    local notify_msg = str
    if notify_msg == nil then
        notify_msg = TI18N("确定要退出活动吗？")
    end
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = notify_msg
    data.sureLabel = TI18N("确认")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function()
        -- print("-----------------------------------请求14602")
        Connection.Instance:send(14602, {})
    end
    NoticeManager.Instance:ConfirmTips(data)
end

--请求查看当前活动状态
function FairyLandManager:request14603()
    -- print("-----------------------------------请求14603")
    Connection.Instance:send(14603, {})
end


--请求抽取奖励
function FairyLandManager:request14605(_boss_id)
    -- print("-----------------------------------请求14605")
    Connection.Instance:send(14605, {boss_id = _boss_id})
end

--彩虹魔盒 活动通知
function FairyLandManager:request19200()
    Connection.Instance:send(19200, {})
end

--彩虹魔盒 传闻
function FairyLandManager:request19201()
    Connection.Instance:send(19201, {})
end

--彩虹魔盒 抽奖
function FairyLandManager:request19202(times)
    Connection.Instance:send(19202, {times=times})
end

--彩虹魔盒 领奖
function FairyLandManager:request19203()
    Connection.Instance:send(19203, {})
end