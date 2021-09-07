-- @author 黄耀聪
-- @date 2016年9月8日
-- 中秋活动

MidAutumnFestivalManager = MidAutumnFestivalManager or BaseClass(BaseManager)

function MidAutumnFestivalManager:__init()
    if MidAutumnFestivalManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    MidAutumnFestivalManager.Instance = self

    self.skyLanternStatus = {
        Nobegin = 0,
        FirstWave = 1,
        Fight = 2,
        Clean = 3,
        Wait = 4,
        Finish = 5,
    }

    self.model = MidAutumnFestivalModel.New()

    self.answerEvent = EventLib.New()
    self.tickEvent = EventLib.New()
    self.infoEvent = EventLib.New()
    self.rankEvent = EventLib.New()

    self.timerId = LuaTimer.Add(0, 1000, function() self:OnTick() end)

    self.enjoymoon_isOpen = false
    self.enjoymoon_hasAsk = false
    self.hasConfirmed = false

    -- 弹幕冷却
    self.dammakuCoolDown = 0
    self.dammakuCoolDownCallBack = nil

    self:InitHandler()
end

function MidAutumnFestivalManager:__delete()
end

function MidAutumnFestivalManager:InitHandler()
    self:AddNetHandler(14055,self.on14055)
    self:AddNetHandler(14056,self.on14056)
    self:AddNetHandler(14057,self.on14057)
    self:AddNetHandler(14058,self.on14058)
    self:AddNetHandler(14059,self.on14059)
    self:AddNetHandler(14060,self.on14060)
    self:AddNetHandler(14061,self.on14061)
    self:AddNetHandler(14062,self.on14062)
    self:AddNetHandler(14063,self.on14063)
    self:AddNetHandler(14064,self.on14064)
    self:AddNetHandler(14065,self.on14065)
    self:AddNetHandler(14066,self.on14066)
    self:AddNetHandler(14067,self.on14067)
    self:AddNetHandler(14068,self.on14068)
    self:AddNetHandler(14069,self.on14069)

    EventMgr.Instance:AddListener(event_name.role_event_change, function()
        if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.SkyLantern then
            self:CloseLanternMainUI()
        else
            self:ShowLanternMainUI()
        end
        if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.EnjoyMoon then
            self:CloseEnjoyMoonMainUI()
        end
    end)
end

function MidAutumnFestivalManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

function MidAutumnFestivalManager:OpenQuestion(args)
    self.model:OpenQuestion(args)
end

function MidAutumnFestivalManager:OpenSettle(args)
    self.model:OpenSettle(args)
end

function MidAutumnFestivalManager:OpenLetItGo(args)
    self.model:OpenLetItGo(args)
end

function MidAutumnFestivalManager:send14055(battle_id, unit_id)
    local dat = {battle_id = battle_id, unit_id = unit_id}
    -- BaseUtils.dump(dat,"发送14055")
    Connection.Instance:send(14055, dat)
end

function MidAutumnFestivalManager:on14055(data)
    -- BaseUtils.dump(data,"接收14055")
    if data.err_code == 1 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_question, data.askid)
        -- self.model.autoAnswerTime = BaseUtils.BASE_TIME + 60
    else
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end

-- 孔明灯解题，解题成功进行孔明等会入场
function MidAutumnFestivalManager:send14056(anwer)
    Connection.Instance:send(14056, {anwer = anwer})
end

function MidAutumnFestivalManager:on14056(data)
    -- BaseUtils.dump(data,"接收14056")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.answerEvent:Fire(data.anwer, data.result)

    if data.result == data.anwer then
        self.isCorrect = true
        self.model:OnQuestionPlayEffect()
        self:send14057()
        LuaTimer.Add(2000, function()
            WindowManager.Instance:CloseWindowById(WindowConfig.WinID.mid_autumn_question)
        end)
    else
        self.isCorrect = false
        LuaTimer.Add(1000, function()
            WindowManager.Instance:CloseWindowById(WindowConfig.WinID.mid_autumn_question)
        end)
    end
end

-- 孔明灯会信息
function MidAutumnFestivalManager:send14057()
    Connection.Instance:send(14057, {})
end

function MidAutumnFestivalManager:on14057(data)
    -- BaseUtils.dump(data,"接收14057")
    local model = self.model

    model.lantern_state = model.lantern_state or 0
    if model.lantern_state ~= data.state then
        self.isCorrect = nil
    end
    for k,v in pairs(data) do
        model["lantern_"..k] = v
    end
    model.lantern_target_time = BaseUtils.BASE_TIME + data.left_time
    self.infoEvent:Fire()
end

function MidAutumnFestivalManager:send14058()
    Connection.Instance:send(14058, {})
end

function MidAutumnFestivalManager:on14058(data)
    -- BaseUtils.dump(data,"接收14058")
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_settle, data)
end

function MidAutumnFestivalManager:send14059()
    Connection.Instance:send(14059, {})
end

function MidAutumnFestivalManager:on14059(data)
    -- BaseUtils.dump(data,"接收14059")
end

function MidAutumnFestivalManager:RequestInitData()
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.SkyLantern then
        self:send14057()
    end
    if self.enjoymoon_hasAsk ~= true then
        self:send14065()
        self:send14069()
        self.enjoymoon_hasAsk = true
    end
end

function MidAutumnFestivalManager:ShowLanternMainUI()
    self.model:ShowLanternMainUI()
end

function MidAutumnFestivalManager:CloseLanternMainUI()
    self.model:CloseLanternMainUI()
end

function MidAutumnFestivalManager:ShowEnjoyMoonMainUI()
    self.model:ShowEnjoyMoonMainUI()
end

function MidAutumnFestivalManager:CloseEnjoyMoonMainUI()
    self.model:CloseEnjoyMoonMainUI()
end

function MidAutumnFestivalManager:OnTick()
    self.tickEvent:Fire()
end

function MidAutumnFestivalManager:SetIcon()
    MainUIManager.Instance:DelAtiveIcon3(311)

    local base_time = BaseUtils.BASE_TIME

    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.MidAutumn] == nil then
        if self.activeIconData ~= nil then
            self.activeIconData:DeleteMe()
            self.activeIconData = nil
        end
        return
    end


    if self.activeIconData == nil then
        self.activeIconData = AtiveIconData.New()
        local iconData = DataSystem.data_daily_icon[311]
        self.activeIconData.id = iconData.id
        self.activeIconData.iconPath = iconData.res_name
        self.activeIconData.sort = iconData.sort
        self.activeIconData.lev = iconData.lev
        self.activeIconData.clickCallBack = function()
            local count = 0
            for k,v in pairs(CampaignManager.Instance.campaignTree[CampaignEumn.Type.MidAutumn]) do
                if k ~= "count" then
                    count = count + 1
                end
            end
            if count == 1 and CampaignManager.Instance.campaignTree[CampaignEumn.Type.MidAutumn][CampaignEumn.MidAutumnType.Exchange] ~= nil then
                local datalist = {}
                local lev = RoleManager.Instance.RoleData.lev
                for i,v in pairs(ShopManager.Instance.model.datalist[2][7]) do
                    table.insert(datalist, v)
                end
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_exchange, {datalist = datalist, title = TI18N("中秋兑换"), extString = "{assets_2,90025}可在孔明灯、赏月夜获得"})
            else
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_window)
            end
        end
    end
    MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)
end

-- 进入赏月会
function MidAutumnFestivalManager:send14060()
    Connection.Instance:send(14060, {})
end

function MidAutumnFestivalManager:on14060(data)
    -- BaseUtils.dump(data,"接收14060")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 退出赏月会
function MidAutumnFestivalManager:send14061()
    Connection.Instance:send(14061, {})
end

function MidAutumnFestivalManager:on14061(data)
    -- BaseUtils.dump(data,"接收14061")
end

-- 孔明灯火祈愿
function MidAutumnFestivalManager:send14062(type, msg)
    local dat = {type = type, msg = msg}
    -- BaseUtils.dump(dat)
    Connection.Instance:send(14062, dat)

    self:CoolDown()
end

function MidAutumnFestivalManager:on14062(data)
    -- BaseUtils.dump(data,"接收14062")
    -- if data.err_code == 1 then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    -- end
end

-- 孔明灯火祈愿祝福信息列表,单条时为更新，多条时为总列表
function MidAutumnFestivalManager:send14063()
    Connection.Instance:send(14063, {})
end

function MidAutumnFestivalManager:on14063(data)
    -- BaseUtils.dump(data,"接收14063")
end

-- 拾取礼盒
function MidAutumnFestivalManager:send14064(battle_id, uint_id)
    Connection.Instance:send(14064, {battle_id = battle_id, uint_id = uint_id})
end

function MidAutumnFestivalManager:on14064(data)
    -- BaseUtils.dump(data,"接收14064")
end

-- 推送赏月会信息
function MidAutumnFestivalManager:send14065()
    Connection.Instance:send(14065, {})
end

function MidAutumnFestivalManager:on14065(data)
    -- BaseUtils.dump(data,"<color='#00ff00'>接收14065</color>")
    local model = self.model
    for k,v in pairs(data) do
        model["enjoymoon_" .. k] = v
    end
    self.enjoymoon_isOpen = (data.left_time > 0)

    if data.status == 1 and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.EnjoyMoon and self.hasConfirmed ~= true then
        self:ConfirmEnjoyMoon()
    end
    if data.status ~= 1 then
        self.hasConfirmed = false
    end

    if self.enjoymoon_isOpen ~= true then
        model.enjoymoon_reward_list = {}
        model.enjoymoon_wish_val = 0
        model.enjoymoon_rank_info = {}
    end

    self:OnActiveIcon()

    self.infoEvent:Fire()
end

-- 赏月会开启
function MidAutumnFestivalManager:send14066()
    Connection.Instance:send(14066, {})
end

function MidAutumnFestivalManager:on14066(data)
    -- BaseUtils.dump(data,"接收14066")
    local model = self.model
    for k,v in pairs(data) do
        model["enjoymoon_" .. k] = v
    end

    self.enjoymoon_isOpen = (data.status == 1)

    if data.status == 1 and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.EnjoyMoon and self.hasConfirmed ~= true then
        self:ConfirmEnjoyMoon()
    end
    if data.status ~= 1 then
        self.hasConfirmed = false
    end

    self:OnActiveIcon()
end

-- 领取放飞进度奖励
function MidAutumnFestivalManager:send14067(process)
    local dat = {process = process}
    Connection.Instance:send(14067, dat)
end

function MidAutumnFestivalManager:on14067(data)
    -- BaseUtils.dump(data,"接收14067")
    local model = self.model
    model.enjoymoon_reward_list = model.enjoymoon_reward_list or {}
    if model.enjoymoon_reward_index ~= nil then
        if data.err_code == 1 then
            model.enjoymoon_reward_list[model.enjoymoon_reward_index] = true
        else
            model.enjoymoon_wish_val = model.enjoymoon_wish_val or 0
            if model.enjoymoon_wish_val < DataCampMidAutumn.data_pivot[model.enjoymoon_reward_index].type_name then
                model.enjoymoon_reward_list[model.enjoymoon_reward_index] = false
            else
                model.enjoymoon_reward_list[model.enjoymoon_reward_index] = true
            end
        end
    end
    model.enjoymoon_reward_index = nil
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.infoEvent:Fire()
    self.tickEvent:Fire()
end

function MidAutumnFestivalManager:OpenExchange(args)
    self.model:OpenExchange(args)
end

function MidAutumnFestivalManager:OpenDanmaku(args)
    self.model:OpenDanmaku(args)
end

function MidAutumnFestivalManager:ConfirmEnjoyMoon()
    local confirmData = NoticeConfirmData.New()
    confirmData.type = ConfirmData.Style.Normal
    confirmData.cancelSecond = 30
    confirmData.sureLabel = TI18N("确认")
    confirmData.cancelLabel = TI18N("取消")
    confirmData.sureCallback = function()
        MidAutumnFestivalManager.Instance:send14060()
    end
    confirmData.content = TI18N("赏月会已经开启，是否前往参加？")

    NoticeManager.Instance:ActiveConfirmTips(confirmData)
    self.hasConfirmed = true
end

function MidAutumnFestivalManager:OnActiveIcon()
    if self.enjoymoon_isOpen == true then
        if self.enjoymoonIconData == nil then
            self.enjoymoonIconData = AtiveIconData.New()
            local iconData = DataSystem.data_daily_icon[312]
            self.enjoymoonIconData.id = iconData.id
            self.enjoymoonIconData.iconPath = iconData.res_name
            self.enjoymoonIconData.sort = iconData.sort
            self.enjoymoonIconData.lev = iconData.lev
            self.enjoymoonIconData.createCallBack = nil
            -- self.enjoymoonIconData.text = TI18N("赏月中")
            self.enjoymoonIconData.clickCallBack = function () self:Go() end
            self.enjoymoonIconData.timestamp = (self.model["enjoymoon_left_time"] or 0) + Time.time
            self.enjoymoonIconData.timeoutCallBack = nil
            MainUIManager.Instance:AddAtiveIcon(self.enjoymoonIconData)
        end
    else
        MainUIManager.Instance:DelAtiveIcon(312)
        if self.enjoymoonIconData ~= nil then
            self.enjoymoonIconData:DeleteMe()
            self.enjoymoonIconData = nil
        end
    end
end

function MidAutumnFestivalManager:Go()
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.EnjoyMoon then
        -- NoticeManager.Instance:FloatTipsByString(TI18N("你已经在赏月会中了哦~"))
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_letitgo, {1})
    else
        self:send14060()
    end
end

function MidAutumnFestivalManager:send14068()
    Connection.Instance:send(14068, {})
end

function MidAutumnFestivalManager:on14068(data)
    -- BaseUtils.dump(data, "on14068")
    self.model.rankDataList = data.role_info or {}

    self.rankEvent:Fire()
end

function MidAutumnFestivalManager:SkyLanternMainUITrace()
    local model = self.model
    local status = model.lantern_state
    local lanternTrace = nil

    if MainUIManager.Instance.mainuitracepanel ~= nil then
        lanternTrace = MainUIManager.Instance.mainuitracepanel.skylantern
    end
end

function MidAutumnFestivalManager:CoolDown()
    self:EndCoolDown()
    self.dammakuCoolDown = 6
    self.coolId = LuaTimer.Add(0, 1000, function() self:UpdateTime() end)
end

function MidAutumnFestivalManager:EndCoolDown()
    if self.coolId ~= nil then
        LuaTimer.Delete(self.coolId)
        self.coolId = nil
    end
end

function MidAutumnFestivalManager:UpdateTime()
    self.dammakuCoolDown = self.dammakuCoolDown - 1
    if self.dammakuCoolDownCallBack ~= nil then
        self.dammakuCoolDownCallBack()
    end
    if self.dammakuCoolDown <= 0 then
        self:EndCoolDown()
    end
end

function MidAutumnFestivalManager:send14069()
    Connection.Instance:send(14069, {})
end

function MidAutumnFestivalManager:on14069(data)
    -- BaseUtils.dump(data, "on14069")

    local model = self.model
    model.enjoymoon_reward_list = model.enjoymoon_reward_list or {}
    for _,v in pairs(data.info) do
        model.enjoymoon_reward_list[v.type] = (v.flag == 1)
    end

    self.infoEvent:Fire()
end

-- 是否开启功能的省流量同屏，只在活动期间有效
function MidAutumnFestivalManager:SetEnjoymoonHide(isHide)
    if self.enjoymoon_isOpen == true then
        self.model.hideStatus = isHide
        SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(isHide)
    end
end
