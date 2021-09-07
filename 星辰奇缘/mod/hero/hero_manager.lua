HeroEumn = HeroEumn or BaseClass()

HeroEumn.Phase = {
    Nostart = 0,    -- 未开始
    Broadcast = 1,  -- 广播
    Ready = 2,      -- 报名大厅组队阶段
    Battle = 3,     -- 开战阶段
    Settle = 4,     -- 战斗结束，结算阶段
    Reward = 5,     -- 拾取奖励阶段
    Ended = 6,      -- 时间已过
}

HeroManager = HeroManager or BaseClass(BaseManager)

function HeroManager:__init()
    if HeroManager.Instance ~= nil then
        Log.Error("不可重复实例化")
        return
    end
    HeroManager.Instance = self

    self.name = TI18N("荣耀战场")
    self.readyDescPattern = TI18N("活动开启剩余:<color=#FFC900>%s</color>")

    self.phase = HeroEumn.Phase.Nostart
    self.campNames = {TI18N("部落"), TI18N("联盟")}

    self.panel = nil        -- 追踪面板
    self.timerId = nil      -- 功能倒计时

    self.ruleDesc = TI18N("1.同阵营可自由组齐<color='#ffff00'>5人</color>队伍\n2.正式开启后系统将<color='#ffff00'>自动匹配</color>对手\n3.每人有<color='#ffff00'>3次</color>复活的机会，胜利后将会洒出<color='#ffff00'>胜利宝箱</color>")

    self.statusDesc = {
        TI18N("系统正在匹配对手...")
        , TI18N("恭喜获得胜利\n请拾取战利品！")
    }

    self.THidePersons = "herohidepersons"
    self.pushTimes = 0

    self.model = HeroModel.New()
    self.onUpdateRank = EventLib.New()  -- 更新排行榜
    self.onUpdateTime = EventLib.New()  -- 更新时间
    self.onUpdateInfo = EventLib.New()  -- 更新我的信息
    self.onUpdateField = EventLib.New()  -- 更新战场信息
    self.onUpdateReward = EventLib.New() -- 更新奖励信息
    self.onUpdateTeam = EventLib.New()  -- 更新队伍信息

    EventMgr.Instance:AddListener(event_name.role_event_change, function(event, old_event)
        if event == RoleEumn.Event.HeroReady then
            self:SetHeroHide(self.model.hideStatus)
        elseif event == RoleEumn.Event.Hero then
            self.model:EnterScene()

            local trace = MainUIManager.Instance.mainuitracepanel
            if trace == nil then return end
            for _,btnType in ipairs(trace.showList) do
                trace.tabGroup.buttonTab[btnType].gameObject:SetActive(false)
            end
            trace.showList = TraceEumn.ShowTypeDetail[TraceEumn.ShowType.Hero]

            for i,btnType in ipairs(trace.showList) do
                local btn = trace.tabGroup.buttonTab[btnType].gameObject
                btn.transform.localPosition = Vector2(92 * (i - 1), 0)
                btn:SetActive(true)
            end
            -- 变化后选中第一个
            trace.tabGroup:ChangeTab(trace.showList[1], true)
        elseif old_event == RoleEumn.Event.Hero or old_event == RoleEumn.Event.HeroReady then
            self.model:ExitScene()
        end
    end)

    EventMgr.Instance:AddListener(event_name.setting_change, function(key, value)
        if key == SettingManager.Instance.THidePerson then
            if self.panel ~= nil and self.panel.toggle ~= nil then
                self.panel.toggle.isOn = value
            end
        end
    end)

    EventMgr.Instance:AddListener(event_name.role_level_change, function() self:CheckActivityIcon() end)

    self:InitHandler()
end

function HeroManager:__delete()
end

function HeroManager:InitHandler()
    self:AddNetHandler(16300, self.on16300)
    self:AddNetHandler(16301, self.on16301)
    self:AddNetHandler(16302, self.on16302)
    self:AddNetHandler(16303, self.on16303)
    self:AddNetHandler(16304, self.on16304)
    self:AddNetHandler(16305, self.on16305)
    self:AddNetHandler(16306, self.on16306)
    self:AddNetHandler(16307, self.on16307)
    self:AddNetHandler(16308, self.on16308)
    self:AddNetHandler(16309, self.on16309)
end

function HeroManager:GotoPhase(phase)
    -- print("<color=#00FF00>---------------------------------------</color> "..tostring(phase))
    if self.panel ~= nil and self.panel.isInit == true then
        self.panel:GotoPhase(phase)
    end
end

function HeroManager:OpenRankWindow(args)
    self.model:OpenRankWindow(args)
end

function HeroManager:send16300()
    -- print("发送16300")
    Connection.Instance:send(16300, {})
end

-- 接收状态
function HeroManager:on16300(data)
    -- BaseUtils.dump(data, "接收16300")
    self.phase = data.statue
    self.model:SetTime(data.mtime)

    if RoleManager.Instance.RoleData.event == RoleEumn.Event.Hero
        or RoleManager.Instance.RoleData.event == RoleEumn.Event.HeroReady then
        self.model:EnterScene()
    end

    if self:InActivity() then
        self:send16304()
    end

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    if self.phase == HeroEumn.Phase.Ready
        or self.phase == HeroEumn.Phase.Battle
        or self.phase == HeroEumn.Phase.Settle
        or self.phase == HeroEumn.Phase.Reward
        then
        self:send16303()
        self.timerId = LuaTimer.Add(0, 1000, function() self:CountDown() end)
    elseif self.phase == HeroEumn.Phase.Nostart
        or self.phase == HeroEumn.Phase.Broadcast
        then
        self.getReward = false
        self.noRank = true
        self.model:ExitScene()
        self.model.myInfo = {}
    end

    if self.phase == HeroEumn.Phase.Ready then
        self:OnPush()
    end

    AgendaManager.Instance:SetCurrLimitID(2019, self:InActivity())

    self:CheckActivityIcon()
end

-- 报名
function HeroManager:send16301()
  -- print("发送16301")
    Connection.Instance:send(16301, {})
end

function HeroManager:on16301(data)
    -- BaseUtils.dump(data, "接收16301")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 手动退出
function HeroManager:send16302()
    -- print("发送16302")
    Connection.Instance:send(16302, {})
end

function HeroManager:on16302(data)
    -- BaseUtils.dump(data, "接收16302")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.model.myInfo = {}
end

-- 接收两个阵营的信息
function HeroManager:send16303()
    -- print("发送16303")
    Connection.Instance:send(16303, {})
end

function HeroManager:on16303(data)
    -- BaseUtils.dump(data, "接收16303")
    self.model.campList = data.list
    self.onUpdateField:Fire()
end

-- 接收我的信息
function HeroManager:send16304()
    -- print("发送16304")
    Connection.Instance:send(16304, {})
end

function HeroManager:on16304(data)
    -- BaseUtils.dump(data, "接收16304")
    self.model.myInfo = data.list[1]
    self.onUpdateInfo:Fire()

    if self.model.myInfo.group ~= nil then
        if self.phase == HeroEumn.Phase.Ready then
            -- self.model:ExitScene()
        elseif self.phase == HeroEumn.Phase.Battle
            or self.phase == HeroEumn.Phase.Settle
            or self.phase == HeroEumn.Phase.Reward
            then
        elseif self.phase == HeroEumn.Phase.Nostart
            or self.phase == HeroEumn.Phase.Broadcast
            then
            -- self.model:ExitScene()
        else
            -- self.model:ExitScene()
        end

        -- print("<color=#00FF00>---------------------------</color> "..tostring(self.phase))
        self:GotoPhase(self.phase)
    else

    end
end

-- 活动排行榜
function HeroManager:send16305()
    -- print("发送16305")
    Connection.Instance:send(16305, {})
end

function HeroManager:on16305(data)
    -- BaseUtils.dump(data, "接收16305")
    self.model.settleData.rank_list = data.list
    self.onUpdateRank:Fire()
end

-- 获取结算数据
function HeroManager:send16306()
    -- print("发送16306")
    Connection.Instance:send(16306, {})
end

function HeroManager:on16306(data)
    -- BaseUtils.dump(data, "接收16306")
    self.model.settleData = data
    self.onUpdateInfo:Fire()

    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.hero_rank_window)
end

-- 获取宝箱数据
function HeroManager:send16307()
    -- print("发送16307")
    Connection.Instance:send(16307, {})
end

function HeroManager:on16307(data)
    -- BaseUtils.dump(data, "接收16307")
    self.model.treasureData = data

    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.onUpdateInfo:Fire()
end

-- 获取奖励数据
function HeroManager:send16308()
    -- print("发送16308")
    Connection.Instance:send(16308, {})
end

function HeroManager:on16308(data)
    -- BaseUtils.dump(data, "接收16308")
    self.model.rewardData = data
    self.getReward = true
    self.onUpdateReward:Fire()

    if (self.model.settleWin == nil or self.model.settleWin.is_open ~= true) -- 排名窗口当前没被打开
        and (self.noRank ~= true        -- 排名窗口被打开过
            or (data.is_win == 0 and data.die == 0))    -- 没有复活次数只能死出来
        then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.hero_settle_window, data)
    end
end

function HeroManager:CountDown()
    if self.model.restTime > 0 then
        self.model.restTime = self.model.restTime - 1
    end
    self.onUpdateTime:Fire()
end

-- 是否开启功能的省流量同屏，只在活动期间有效
function HeroManager:SetHeroHide(isHide)
    if self:InActivity() then
        self.model.hideStatus = isHide
        SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(isHide)
    end
end

-- 是否在活动状态
function HeroManager:InActivity()
    local phaseEumn = HeroEumn.Phase
    return not (self.phase == phaseEumn.Nostart or self.phase == phaseEumn.Broadcast)
end

function HeroManager:OnOpen()
    if not self:InActivity() then
        self:send16301()
    end
end

function HeroManager:OnQuit()
    local phaseEumn = HeroEumn.Phase
    if self:InActivity() then
        local exit = function() self:send16302() end
        if self.phase == phaseEumn.Battle then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("退出后即视为放弃，<color=#FF0000>无法</color>再次参加。\n是否退出？")
            data.sureLabel = TI18N("退 出")
            data.cancelLabel = TI18N("取消")
            data.cancelSecond = 180
            data.sureCallback = exit
            NoticeManager.Instance:ConfirmTips(data)
        else
            exit()
        end
    end
end

function HeroManager:OnPush()
    -- self.pushTimes = self.pushTimes + 1
    -- if self.pushTimes > 0 then
    --     return
    -- end

    if tonumber(os.date("%w", BaseUtils.BASE_TIME)) == 3 then
        local cfg_data = DataSystem.data_daily_icon[123]
        if RoleManager.Instance.RoleData.lev >= cfg_data.lev and RoleManager.Instance.world_lev >= 70 then -- 世界等级≥70，则角色等级≥70，不显示荣耀图标
            return
        end
    end

    local iconData = DataSystem.data_daily_icon[114]
    if RoleManager.Instance.RoleData.lev < iconData.lev or RoleManager.Instance.RoleData.event == RoleEumn.Event.Hero or RoleManager.Instance.RoleData.event == RoleEumn.Event.HeroReady then
        return
    end
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = TI18N("<color=#FFFF00>荣耀战场</color>活动已开启，是否前往参加？")
    data.sureLabel = TI18N("确认")
    data.cancelLabel = TI18N("取消")

    local maxTime = self.model.restTime
    if maxTime > 180 then maxTime = 180 end
    data.cancelSecond = maxTime
    data.sureCallback = function() self:send16301() end

    if RoleManager.Instance.RoleData.cross_type == 1 then
        -- 如果处在中央服，先回到本服在参加活动
        RoleManager.Instance.jump_over_call = function() self:send16301() end
        data.sureCallback = SceneManager.Instance.quitCenter
        data.content = TI18N("<color=#FFFF00>荣耀战场</color>活动已开启，是否<color='#ffff00'>返回原服</color>参加？")
    end

    NoticeManager.Instance:ActiveConfirmTips(data)
end

function HeroManager:RequestInitData()
    self.getReward = false
    self.model.rewardData = {}
    self.model.myInfo = {}
    self:send16300()
    self:send16304()
end

function HeroManager:OpenSettleWindow(args)
    self.model:OpenSettleWindow(args)
end

function HeroManager:CheckActivityIcon()
    if tonumber(os.date("%w", BaseUtils.BASE_TIME)) == 3 then
        local cfg_data = DataSystem.data_daily_icon[123]
        if RoleManager.Instance.RoleData.lev >= cfg_data.lev and RoleManager.Instance.world_lev >= 70 then -- 世界等级≥70，则角色等级≥70，不显示荣耀图标
            return
        end
    end

    local activeIconData = AtiveIconData.New()
    local iconData = DataSystem.data_daily_icon[114]
    activeIconData.id = iconData.id
    activeIconData.iconPath = iconData.res_name
    activeIconData.sort = iconData.sort
    activeIconData.lev = iconData.lev
    MainUIManager.Instance:DelAtiveIcon(114)

    if self.phase == HeroEumn.Phase.Broadcast
        then
        -- activeIconData.text = TI18N("即将开启")
        -- activeIconData.clickCallBack = function() NoticeManager.Instance:FloatTipsByString(TI18N("活动即将开启，请留意活动公告")) end
        -- MainUIManager.Instance:AddAtiveIcon(activeIconData)
    elseif self.phase == HeroEumn.Phase.Ready
        then
        -- 暂时去除特效
        activeIconData.createCallBack = nil
        activeIconData.text = TI18N("准备中")
        activeIconData.clickCallBack = function () self:HeroCheckIn() end
        MainUIManager.Instance:AddAtiveIcon(activeIconData)
    elseif self.phase == HeroEumn.Phase.Battle
        then
        activeIconData.clickCallBack = function()
            if BaseUtils.BASE_TIME > self.model.registerTime then
                NoticeManager.Instance:FloatTipsByString(TI18N("报名时间已过，请留意下次活动公告"))
            else
                self:HeroCheckIn()
            end
        end
        activeIconData.timestamp = self.model.restTime + Time.time
        activeIconData.timeoutCallBack = nil
        MainUIManager.Instance:AddAtiveIcon(activeIconData)
    end
end

function HeroManager:send16309()
    Connection.Instance:send(16309, {})
end

function HeroManager:on16309(data)
    -- BaseUtils.dump(data, "接收16309")
    self.model.teamList = data.list
    self.onUpdateTeam:Fire()
end

function HeroManager:HeroCheckIn()
    if tonumber(os.date("%w", BaseUtils.BASE_TIME)) == 3 then
        local cfg_data = DataSystem.data_daily_icon[123]
        if RoleManager.Instance.RoleData.lev >= cfg_data.lev and RoleManager.Instance.world_lev >= 70 then -- 世界等级≥70，则角色等级≥70，不显示荣耀图标
            return
        end
    end

    if RoleManager.Instance.RoleData.cross_type == 1 then
        -- 如果处在中央服，先回到本服在参加活动
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.sureSecond = -1
        confirmData.cancelSecond = 180
        confirmData.sureLabel = TI18N("确认")
        confirmData.cancelLabel = TI18N("取消")
        RoleManager.Instance.jump_over_call = function() self:send16301() end
        confirmData.sureCallback = SceneManager.Instance.quitCenter
        confirmData.content = TI18N("<color='#ffff00'>荣耀战场</color>活动已开启，是否<color='#ffff00'>返回原服</color>参加？")
        NoticeManager.Instance:ConfirmTips(confirmData)
    else
        self:send16301()
    end
end