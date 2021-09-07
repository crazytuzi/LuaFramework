HalloweenModel = HalloweenModel or BaseClass(BaseModel)

function HalloweenModel:__init()
    self.mainWin = nil
    self.menu = nil
    self.title = nil
    self.rankWindow = nil
    self.killEvilCardWindow = nil
    self.halloweenMatchWindow = nil
    self.halloweensignup = nil
    self.halloweendeadtips = nil

    self.pumpkingoblinData = nil
    self.rank_list = {}
    self.red_score = 0
    self.blue_score = 0
    self.end_time = 0
    self.red_list = {}
    self.blue_list = {}
    self.win_camp = 1
    self.reward = {}
    self.match_data = {}
    self.skillStatusList = {}

    self.fire_times = 0
    self.cooldowm = 0
    self.less_times = 0
    self.match_time = 0
    self.killEvilMapData = nil

    self.status = 0
    self.timestamp = 0

    self.killerName = nil

    self.selfIcon = nil

    self.mainUIIconHideTop = false
end

function HalloweenModel:Clear()
    self:DeleteTitle()
    self:DeleteHalloweenSignup()
    self:CloseHalloweenDeadTips()
    if MainUIManager.Instance.MainUIIconView ~= nil then
        MainUIManager.Instance.MainUIIconView:Set_ShowTop(true)
    end
    SceneManager.Instance.sceneElementsModel:Show_Self_Pet(true)

    self.pumpkingoblinData = nil
    self.rank_list = {}
    self.red_score = 0
    self.blue_score = 0
    self.end_time = 0
    self.red_list = {}
    self.blue_list = {}
    self.win_camp = 1
    self.reward = {}
    self.match_data = {}

    self.fire_times = 0
    self.cooldowm = 0
    self.less_times = 0
    self.match_time = 0

    self.status = 0
    self.timestamp = 0

    self.killerName = nil

    self.selfIcon = nil

    self.mainUIIconHideTop = false
end

function HalloweenModel:__delete()
    if self.mainWin ~= nil then
        WindowManager.Instance:CloseWindow(self.mainWin)
    end
end

function HalloweenModel:InitMainUI(args)
    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.Halloween] == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("活动尚未开启"))
        return
    end
    if self.mainWin == nil then
        self.mainWin = HalloweenWindow.New(self)
    end
    self.mainWin:Open(args)
end

function HalloweenModel:CloseMainUI()
    if self.mainWin ~= nil then
        WindowManager.Instance:CloseWindow(self.mainWin)
    end
end

function HalloweenModel:InitRankWindow(args)
    if self.rankWindow == nil then
        self.rankWindow = HalloweenRankWindow.New(self)
    end
    self.rankWindow:Open(args)
end

function HalloweenModel:CloseRankWindow()
    if self.rankWindow ~= nil then
        WindowManager.Instance:CloseWindow(self.rankWindow)
    end
end

function HalloweenModel:OpenHalloweenMatchWindow(args)
    if self.halloweenMatchWindow == nil then
        self.halloweenMatchWindow = HalloweenMatchWindow.New(self)
    end
    self.halloweenMatchWindow:Open(args)
end

function HalloweenModel:CloseHalloweenMatchWindow()
    if self.halloweenMatchWindow ~= nil then
        WindowManager.Instance:CloseWindow(self.halloweenMatchWindow)
    end
end

--驱除邪灵结算界面
function HalloweenModel:InitKillEvilCardUI(args)
    if self.killEvilCardWindow == nil then
        self.killEvilCardWindow = HalloweenKillEvilCardWindow.New(self)
    else
        self:CloseKillEvilCardUI()
        self.killEvilCardWindow = HalloweenKillEvilCardWindow.New(self)
    end
    self.killEvilCardWindow:Open(args)
end

--关闭驱除邪灵结算界面
function HalloweenModel:CloseKillEvilCardUI()
    if self.killEvilCardWindow ~= nil then
        WindowManager.Instance:CloseWindow(self.killEvilCardWindow)
    end
end

function HalloweenModel:OpenKillEvilBox(data)
    if self.killEvilCardWindow ~= nil then
        self.killEvilCardWindow:OpenBox(data.order, data.gain_list[1])
        local callback =  function()
            local lastorder = 0
            for k,v in pairs(data.show_list) do
                local ok = false
                for i = 1, 3 do
                    if i ~= data.order and i ~= lastorder and not ok then
                        lastorder = i
                        ok = true
                        if self.killEvilCardWindow ~= nil then
                            self.killEvilCardWindow:OpenBox(lastorder, v)
                        end
                    end
                end
            end
        end
        LuaTimer.Add(500, function() callback() end)
    end
end

function HalloweenModel:ShowtMenu()
    if self.menu == nil then
        self.menu = HalloweenMenuView.New(self)
    end
    self.menu:Show()
end

function HalloweenModel:HideMenu()
    if self.menu ~= nil then
        self.menu:Hide()
    end
end

function HalloweenModel:DeleteMenu()
    if self.menu ~= nil then
        self.menu:DeleteMe()
    end
end

function HalloweenModel:ShowTitle()
    if self.title == nil then
        self.title = HalloweenTitleView.New(self)
    end
    self.title:Show()
end

function HalloweenModel:HideTitle()
    if self.title ~= nil then
        self.title:Hiden()
    end
end

function HalloweenModel:DeleteTitle()
    if self.title ~= nil then
        self.title:DeleteMe()
        self.title = nil
    end
end

function HalloweenModel:ShowHalloweenSignup()
    if self.halloweensignup == nil then
        self.halloweensignup = HalloweenSignup.New(self)
    end
    self.halloweensignup:Show()
end

function HalloweenModel:HideHalloweenSignup()
    if self.halloweensignup ~= nil then
        self.halloweensignup:Hide()
    end
end

function HalloweenModel:DeleteHalloweenSignup()
    if self.halloweensignup ~= nil then
        self.halloweensignup:DeleteMe()
        self.halloweensignup = nil
    end
end


function HalloweenModel:OpenHalloweenDeadTips()
    if self.halloweendeadtips == nil then
        self.halloweendeadtips = HalloweenDeadTips.New(self)
    end
    self.halloweendeadtips:Show()
end

function HalloweenModel:CloseHalloweenDeadTips()
    if self.halloweendeadtips ~= nil then
        self.halloweendeadtips:DeleteMe()
        self.halloweendeadtips = nil
    end
end

----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
function HalloweenModel:On17800(data)
    -- BaseUtils.dump(data, "On17800")
    --StarParkManager.Instance.agendaTab[2102] = nil
    self.status = data.statue
    self.timestamp = data.mtime - BaseUtils.BASE_TIME + Time.time

    --local cfg_data = DataSystem.data_daily_icon[121]
    local cfg_data = DataSystem.data_daily_icon[317]

    if self.status == 0 or self.status == 1 then
        self.match_data = {}
        -- self.match_time = 0
    elseif self.status == 2 and self.less_times < HalloweenManager.Instance.pumpkingoblinTimes  then
        --StarParkManager.Instance.agendaTab[2102] = {time = self.timestamp}

        local roleData = RoleManager.Instance.RoleData
        if roleData.lev >= cfg_data.lev and self.less_times < HalloweenManager.Instance.pumpkingoblinTimes
            and roleData.event ~= RoleEumn.Event.Camp_halloween_pre and roleData.event ~= RoleEumn.Event.Halloween
            and roleData.event ~= RoleEumn.Event.Halloween_sub and roleData.event ~= RoleEumn.Event.camp_halloween_pre_enter then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("<color='#ffff00'>淘气南瓜</color>活动正在进行中，是否前往参加？")
            data.sureLabel = TI18N("确认")
            data.cancelLabel = TI18N("取消")
            data.cancelSecond = 30
            data.sureCallback = function()
                    if self.less_times < HalloweenManager.Instance.pumpkingoblinTimes then
                        self:GoCheckIn()
                    end
                end

            NoticeManager.Instance:ActiveConfirmTips(data)
        end
    end
    --StarParkManager.Instance:ShowIcon()
    self:ShowIcon(data)
end

function HalloweenModel:ShowIcon(data)
    MainUIManager.Instance:DelAtiveIcon(317)
    if data ~= nil and data.statue ~= 0 then
        self.activeIconData = AtiveIconData.New()
        local iconData = DataSystem.data_daily_icon[317]
        self.activeIconData.id = iconData.id
        self.activeIconData.iconPath = iconData.res_name
        self.activeIconData.sort = iconData.sort
        self.activeIconData.lev = iconData.lev
        self.activeIconData.timestamp = data.timestamp
        self.activeIconData.clickCallBack = function()
            --StarParkManager.Instance.model:OpenStarParkMainUI({data.index})
            --寻路到20002
            local target = BaseUtils.get_unique_npcid(3, 1)
            SceneManager.Instance.sceneElementsModel:Self_AutoPath(10001, target, nil, nil, true)
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
        end
        MainUIManager.Instance:AddAtiveIcon(self.activeIconData)
    end
end

function HalloweenModel:On17808(data)
    -- BaseUtils.dump(data, "On17808")
    if data.type == 1 then
        self.match_data = data.list
        local roleData = RoleManager.Instance.RoleData
        for key,value in ipairs(data.list) do
            if value.rid == roleData.id and value.platform == roleData.platform and value.r_zone_id == roleData.zone_id then
                self.match_time = value.mtime
            end
        end
    elseif data.type == 2 then
        local roleData = RoleManager.Instance.RoleData
        for key,value in ipairs(data.list) do
            for i=1,10 do
                if self.match_data[i] == nil then
                    self.match_data[i] = value
                    break
                end
            end
            if value.rid == roleData.id and value.platform == roleData.platform and value.r_zone_id == roleData.zone_id then
                self.match_time = value.mtime
            end
        end
    elseif data.type == 3 then
        local emptyPos = {}
        for key,value in ipairs(data.list) do
            for key2,value2 in ipairs(self.match_data) do
                if value.rid == value2.rid and value.platform == value2.platform and value.r_zone_id == value2.r_zone_id then
                    table.insert(emptyPos, key2)
                    break
                end
            end
        end
        for _,v in pairs(emptyPos) do
            self.match_data[v] = nil
        end
    end
    EventMgr.Instance:Fire(event_name.halloween_match_update)
end

function HalloweenModel:On17809(data)
    self.last_data = self.match_data
    self.match_data = data.list
    self.match_time = BaseUtils.BASE_TIME + 8
    EventMgr.Instance:Fire(event_name.halloween_match_update, true)

    self:OpenHalloweenMatchWindow()
end

function HalloweenModel:On17810(data)
    local key = BaseUtils.get_unique_npcid(data.id, data.bid)
    local nv = SceneManager.Instance.sceneElementsModel.NpcView_List[key]

    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    if nv ~= nil then
        local callback = function(effect)
            if BaseUtils.is_null(nv.gameObject) then
                GameObject.Destroy(effect.gameObject)
                return
            end

            effect.gameObject.transform:SetParent(nv.gameObject.transform)
            effect.gameObject.transform.localPosition = Vector3 (0, 0, -20)
            effect.gameObject.transform.localRotation = Quaternion.identity
            effect.gameObject.transform.localScale = Vector3 (1, 1, 1)
            Utils.ChangeLayersRecursively(effect.gameObject.transform, "Model")
        end

        self.effect = BaseEffectView.New({ effectId = 30156, time = 1500, callback = callback })

        -- print(string.format("17810协议 <color='#00ff00'>x = %s, y = %s</color>", data.x, data.y))
        -- local p = SceneManager.Instance.sceneModel:transport_big_pos(nv.gameObject.transform.position.x, nv.gameObject.transform.position.y)
        -- print(string.format("本地坐标 <color='#00ff00'>x = %s, y = %s</color>", p.x, p.y))
    end

    self.key = key
end
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------

function HalloweenModel:ClickRole(clickRoleData)
    local isReture = false
    if clickRoleData.event == RoleEumn.Event.Halloween then
        local self_view = SceneManager.Instance.sceneElementsModel.self_view
        if self_view ~= nil then
            if self_view.data.event == RoleEumn.Event.Halloween_sub then
                NoticeManager.Instance:FloatTipsByString(TI18N("你已经死了"))
                isReture = true
            else
                -- print(string.format("点击了玩家 %s， looks长度 %s", clickRoleData.name, #clickRoleData.looks))
                local roleData = RoleManager.Instance.RoleData
                for k,v in ipairs(clickRoleData.looks) do
                    if v.looks_type == SceneConstData.looktype_camp_name then
                        -- print(string.format("玩家的camp_name %s， 自己的camp_name %s ", v.looks_val, roleData.camp))
                        if roleData.camp ~= 0 and v.looks_val ~= 0 and roleData.camp ~= v.looks_val then
                            self.pumpkingoblinData = { isNpc = false, data = clickRoleData }
                            -- self:ShowtMenu()
                            self:UpdateSceneTalk()
                            isReture = true
                        end
                    end
                end
            end
        end
    end
    -- if clickRoleData.event == RoleEumn.Event.Halloween_sub then
    --     self.pumpkingoblinData = { isNpc = false, data = clickRoleData }
    --     -- self:ShowtMenu()
    --     self:UpdateSceneTalk()
    --     isReture = true
    -- end
    return isReture
end

function HalloweenModel:ClickNpc(objectName)
    local isReture = false

    local sceneElementsModel = SceneManager.Instance.sceneElementsModel
    local touchNpcView = SceneManager.Instance.sceneElementsModel.NpcView_List[objectName]
    if touchNpcView ~= nil then -- 点击到场景单位的处理
        local data = touchNpcView.data
        local baseData = touchNpcView.baseData
        if data.no_click then return isReture end

        if baseData.type == SceneConstData.unittype_pumpkingoblin then
            isReture = true
            self.pumpkingoblinData = { isNpc = true, data = data }
            -- self:ShowtMenu()
            self:UpdateSceneTalk()

            if not BaseUtils.is_null(touchNpcView.gameObject) then
                sceneElementsModel:Set_Selected_Effect(touchNpcView:GetCachedTransform(), true)
                sceneElementsModel.Selected_Effect_Parent = touchNpcView
            end
        end
    end

    return isReture
end


function HalloweenModel:UpdateSceneTalk()
    if self.lastSceneTack ~= nil then
        if self.lastSceneTack.isNpc then
            local data = self.lastSceneTack.data
            HalloweenSceneTalk.Instance:HideBtn_Npc(data.id, data.battleid)
        else
            local data = self.lastSceneTack.data
            HalloweenSceneTalk.Instance:HideBtn_Player(data.roleid, data.platform, data.zoneid)
        end
    end

    if self.pumpkingoblinData ~= nil then
        if self.pumpkingoblinData.isNpc then
            local data = self.pumpkingoblinData.data
            HalloweenSceneTalk.Instance:ShowBtn_NPC(data.id, data.battleid, function() self:DoCheck() end)
        else
            local data = self.pumpkingoblinData.data
            HalloweenSceneTalk.Instance:ShowBtn_Player(data.roleid, data.platform, data.zoneid, function() self:DoCheck() end)
        end

        self.lastSceneTack = self.pumpkingoblinData
    end
end

function HalloweenModel:DoCheck()
    if self.pumpkingoblinData ~= nil then
        if self.pumpkingoblinData.isNpc then
            HalloweenManager.Instance:Send17806(2, 0, "", 0)
        else
            local data = self.pumpkingoblinData.data
            if data.event == RoleEumn.Event.Halloween then
                HalloweenManager.Instance:Send17806(1, data.roleid, data.platform, data.zoneid)
            elseif data.event == RoleEumn.Event.Halloween_sub then
                HalloweenManager.Instance:Send17806(1, data.roleid, data.platform, data.zoneid)
            end
        end
    end
end

function HalloweenModel:UpdateEvent(event, old_event)
    if event == RoleEumn.Event.camp_halloween_pre_enter then
        self:HideHalloweenSignup()
    end

    if event == RoleEumn.Event.Halloween or event == RoleEumn.Event.Halloween_sub then
        self:ShowTitle()
        if MainUIManager.Instance.MainUIIconView ~= nil then
            MainUIManager.Instance.MainUIIconView:Set_ShowTop(false)
        end
        SceneManager.Instance.sceneElementsModel:Show_Self_Pet(false)

        HalloweenSceneTalk.Instance:LoadPrefabs()
    end

    if (event ~= RoleEumn.Event.Halloween and event ~= RoleEumn.Event.Halloween_sub)
        and (old_event == RoleEumn.Event.Halloween or old_event == RoleEumn.Event.Halloween_sub) then
        self:DeleteTitle()
        if MainUIManager.Instance.MainUIIconView ~= nil then
            MainUIManager.Instance.MainUIIconView:Set_ShowTop(true)
        end
        SceneManager.Instance.sceneElementsModel:Show_Self_Pet(true)

        self:DeleteMenu()
        self:CloseHalloweenDeadTips()
    end
end

function HalloweenModel:UpdateMap()
    local mapid = SceneManager.Instance:CurrentMapId()

    if mapid == 30015 then
        -- if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.camp_halloween_pre_enter then
        self:ShowHalloweenSignup()
        -- HalloweenManager.Instance:Send17801()
    else
        self:HideHalloweenSignup()
    end

    -- if mapid == 30015 or mapid == 30014 then
    if mapid == 30014 then
        self:SetCrossIcon(false)
        LuaTimer.Add(1500, function() self:SetCrossIcon(false) end)
        MainUIManager.Instance.MainUIIconView:Set_ShowTop(false, {107})
        self.mainUIIconHideTop = true
    elseif self.mainUIIconHideTop then
        MainUIManager.Instance.MainUIIconView:Set_ShowTop(true, {107})
        self:SetCrossIcon(RoleManager.Instance.RoleData.cross_type == 1)
        self.mainUIIconHideTop = false
    end
end

function HalloweenModel:OpenExchange(args)
    local datalist = {}
    for i,v in pairs(ShopManager.Instance.model.datalist[2][9]) do
        table.insert(datalist, v)
    end

    if self.exchangeWin == nil then
        self.exchangeWin = MidAutumnExchangeWindow.New(self)
    end
    self.exchangeWin:Open({datalist = datalist, title = TI18N("万圣节兑换"), extString = ""})
end

function HalloweenModel:SelfDead()
    self:OpenHalloweenDeadTips()

    local fun = function(effectView)
        local effectObject = effectView.gameObject
        effectObject.transform:SetParent(MainUIManager.Instance.MainUICanvasView.gameObject.transform)
        effectObject.transform.localScale = Vector3.one
        effectObject.transform.localPosition = Vector3(0, 0, -400)
        effectObject.transform.localRotation = Quaternion.identity
        effectObject.name = "DeadEffect"

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
    end
    BaseEffectView.New({effectId = 20193, time = 1500, callback = fun})
end

function HalloweenModel:ShowSuccessEffect()
    local fun = function(effectView)
        local effectObject = effectView.gameObject
        effectObject.transform:SetParent(MainUIManager.Instance.MainUICanvasView.gameObject.transform)
        effectObject.transform.localScale = Vector3.one
        effectObject.transform.localPosition = Vector3(0, 0, -400)
        effectObject.transform.localRotation = Quaternion.identity
        effectObject.name = "SuccessEffect"

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
    end
    BaseEffectView.New({effectId = 20192, time = 1500, callback = fun})
end

function HalloweenModel:GoCheckIn()
    if RoleManager.Instance:CanConnectCenter() then
        if RoleManager.Instance.RoleData.cross_type == 1 then
            SceneManager.Instance.sceneElementsModel:Self_Transport(30015, 0, 0)
        else
            SceneManager.Instance:Send10170(30015)
        end
    else
        SceneManager.Instance.sceneElementsModel:Self_Transport(30015, 0, 0)
    end
end

function HalloweenModel:SetCrossIcon(show)
    MainUIManager.Instance:DelAtiveIcon3(303)
    if show ~= true then
        return
    end
    local cfg_data = DataSystem.data_daily_icon[303]
    local data = AtiveIconData.New()
    data.id = cfg_data.id
    data.iconPath = cfg_data.res_name
    data.sort = cfg_data.sort
    data.lev = cfg_data.lev
    data.clickCallBack = function()
        if CombatManager.Instance.isFighting then
            NoticeManager.Instance:FloatTipsByString(TI18N("战斗中无法返回原服"))
            return
        end
        RoleManager.Instance:CheckQuitCenter()
        if RoleManager.Instance.returnicon_effectView ~= nil then
            RoleManager.Instance.returnicon_effectView:DeleteMe()
            RoleManager.Instance.returnicon_effectView = nil
            -- SettingManager.Instance:SetResult("RetrunToLocalEffect", 1)
        end
    end
    data.createCallBack = function(gameObject)
        -- if self.returnicon_effectView == nil and SettingManager.Instance:GetResult("RetrunToLocalEffect") == false then
        if RoleManager.Instance.returnicon_effectView == nil or BaseUtils.is_null(RoleManager.Instance.returnicon_effectView.gameObject) then
            local fun = function(effectView)
                if BaseUtils.is_null(gameObject) then
                    effectView:DeleteMe()
                    return
                end
                RoleManager.Instance.returnicon_effectView = effectView
                local effectObject = effectView.gameObject

                effectObject.transform:SetParent(gameObject.transform)
                effectObject.transform.localScale = Vector3(0.9, 0.9, 0.9)
                effectObject.transform.localPosition = Vector3(-1.6, 30, -400)
                effectObject.transform.localRotation = Quaternion.identity

                Utils.ChangeLayersRecursively(effectObject.transform, "UI")
            end
            BaseEffectView.New({effectId = 20121, time = nil, callback = fun})
        end
    end
    MainUIManager.Instance:AddAtiveIcon3(data)
end

function HalloweenModel:OpenDamaku()
    if self.damakuWin == nil then
        self.damakuWin = PumpkinDamakuWindow.New(self)
    end
    self.damakuWin:Open()
end
