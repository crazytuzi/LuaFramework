-- @author 黄耀聪
-- @date 2017年6月19日, 星期一

IngotCrashManager = IngotCrashManager or BaseClass(BaseManager)

function IngotCrashManager:__init()
    if IngotCrashManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    IngotCrashManager.Instance = self

    self.model = IngotCrashModel.New()

    self.onUpdateInfo = EventLib.New()
    self.onUpdateRank = EventLib.New()
    self.onUpdateVote = EventLib.New()
    self.onUpdateWatch = EventLib.New()
    self.onUpdateMove = EventLib.New()
    self.onUpdateDamaku = EventLib.New()

    self.blockAreaList = {
        list = {
            Vector2(2480, 280),
            Vector2(3080, 720),
            Vector2(2280,1360),
            Vector2(1000, 1760),
            Vector2(440 ,1320),
            Vector2(1040 ,600),
        },
        area = nil
    }

    self.group_id = 1
    self.isShowDamaku = true
    self.phase = IngotCrashEumn.Phase.Close
    self.activityName = TI18N("钻石联赛")

    self.on_role_event_change = function() self:SceneEnter() end

    self:InitHandler()
end

function IngotCrashManager:__delete()
end

function IngotCrashManager:InitHandler()
    self:AddNetHandler(20000, self.on20000)
    self:AddNetHandler(20001, self.on20001)
    self:AddNetHandler(20002, self.on20002)
    self:AddNetHandler(20003, self.on20003)
    self:AddNetHandler(20004, self.on20004)
    self:AddNetHandler(20005, self.on20005)
    self:AddNetHandler(20006, self.on20006)
    self:AddNetHandler(20007, self.on20007)
    self:AddNetHandler(20008, self.on20008)
    self:AddNetHandler(20009, self.on20009)
    self:AddNetHandler(20010, self.on20010)
    self:AddNetHandler(20011, self.on20011)
    self:AddNetHandler(20012, self.on20012)
    self:AddNetHandler(20013, self.on20013)
    self:AddNetHandler(20014, self.on20014)
    self:AddNetHandler(20015, self.on20015)
    self:AddNetHandler(20016, self.on20016)
    self:AddNetHandler(20018, self.on20018)
    self:AddNetHandler(20019, self.on20019)
    self:AddNetHandler(20020, self.on20020)
    self:AddNetHandler(20021, self.on20021)
    self:AddNetHandler(20022, self.on20022)
    self:AddNetHandler(20023, self.on20023)
    self:AddNetHandler(20024, self.on20024)
    self:AddNetHandler(20025, self.on20025)
    self:AddNetHandler(20026, self.on20026)
    self:AddNetHandler(20027, self.on20027)

    EventMgr.Instance:AddListener(event_name.role_event_change, function(event) self:OnEventChange(event) end)
    EventMgr.Instance:AddListener(event_name.scene_load, function() self:SceneEnter() end)
    EventMgr.Instance:AddListener(event_name.scene_load, function() self:SceneLoad() end)
    EventMgr.Instance:AddListener(event_name.begin_fight, function(combat_type) self:OnBeginFight(combat_type) end)
    EventMgr.Instance:AddListener(event_name.end_fight, function(combat_type, res) self:OnEndFight(combat_type, res) end)
    EventMgr.Instance:AddListener(event_name.mainui_loaded, function()
        EventMgr.Instance:AddListener(event_name.role_event_change, self.on_role_event_change)
        self.on_role_event_change()
    end)
end

function IngotCrashManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

function IngotCrashManager:OpenRank(args)
    self.model:OpenRank(args)
end

function IngotCrashManager:OpenVote(args)
    self.model:OpenVote(args)
end

function IngotCrashManager:OpenReward(args)
    self.model:OpenReward(args)
end

function IngotCrashManager:RequestInitData()
    self.model.personData = {}
    self.model.guessTab = {}
    self.model.best16Tab = {}
    self.model.guessNumTab = {}
    self.pushTimes = 0
    self.hasRegister = false
    self.model.canWalk = false
    self.model.drugTimes = {{}, {}}

    self:send20000()
    self:send20024()
    self:send20007()
end

function IngotCrashManager:OnExit()
    self.confirmData = self.confirmData or NoticeConfirmData.New()
    if SceneManager.Instance:CurrentMapId() == 53002 then
        self.confirmData.content = string.format(TI18N("是否退出<color='#01FB02'>%s</color>？\n<color='#ffff00'>(准备阶段可再次入场）</color>"), self.activityName)
    else
        self.confirmData.content = string.format(TI18N("是否退出<color='#01FB02'>%s</color>？\n(正式阶段退出后将<color='#ED1C24'>不能继续参与</color>）"), self.activityName)
    end
    self.confirmData.sureCallback = function() self:send20002() end
    NoticeManager.Instance:ConfirmTips(self.confirmData)
end

function IngotCrashManager:UpdateMainui()
    if (RoleManager.Instance.RoleData.event == RoleEumn.Event.IngotCrashReady or RoleManager.Instance.RoleData.event == RoleEumn.Event.IngotCrashPVP or RoleManager.Instance.RoleData.event == RoleEumn.Event.IngotCrashMatch) and self.phase ~= IngotCrashEumn.Phase.Close then
        self.model:EnterScene()
    else
        self.model:ExitScene()
    end
end

function IngotCrashManager:SetIcon()
    self.activeIconData = self.activeIconData or AtiveIconData.New()
    local iconData = DataSystem.data_daily_icon[122]
    self.activeIconData.id = iconData.id
    self.activeIconData.iconPath = iconData.res_name
    self.activeIconData.sort = iconData.sort
    self.activeIconData.lev = iconData.lev

    MainUIManager.Instance:DelAtiveIcon(iconData.id)
    if self.phase == IngotCrashEumn.Phase.Predict then
    elseif self.phase == IngotCrashEumn.Phase.Ready then
        self.activeIconData.text = nil
        self.activeIconData.timestamp = (self.time - BaseUtils.BASE_TIME) + Time.time
        self.activeIconData.clickCallBack = function() self:GetIn() end
        MainUIManager.Instance:AddAtiveIcon(self.activeIconData)
    elseif self.phase == IngotCrashEumn.Phase.Qualifier then
        -- if self:IsActive() then
        --     self.activeIconData.text = string.format(TI18N("资格赛第%s轮"), tostring((self.model.personData.win or 0) + (self.model.personData.loss or 0)))
        -- else
        -- end
        -- self.activeIconData.clickCallBack = function () WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ingot_crash_rank) end
            self.activeIconData.text = TI18N("<color='#ffff00'>资格赛</color>")
        self.activeIconData.clickCallBack = function() self:GetIn() end
        self.activeIconData.timestamp = nil
        MainUIManager.Instance:AddAtiveIcon(self.activeIconData)
    elseif self.phase == IngotCrashEumn.Phase.Kickout then
        -- if self:IsActive() then
        --     self.activeIconData.text = string.format(TI18N("淘汰赛第%s轮"), self.now_round)
        -- else
        -- end
        if self.now_round == self.max_round then
            self.activeIconData.text = TI18N("<color='#ffff00'>决赛可观战</color>")
        elseif self.now_round == self.max_round - 1 then
            self.activeIconData.text = TI18N("半决赛")
        elseif self.now_round == self.max_round - 2 then
            self.activeIconData.text = TI18N("8进4比赛")
        elseif self.now_round == self.max_round - 3 then
            self.activeIconData.text = TI18N("16进8比赛")
        else
            self.activeIconData.text = TI18N("淘汰赛预选")
        end
        self.activeIconData.timestamp = nil
        self.activeIconData.clickCallBack = function () WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ingot_crash_content) end
        MainUIManager.Instance:AddAtiveIcon(self.activeIconData)
    elseif self.phase == IngotCrashEumn.Phase.Guess then
        if self.now_round == self.max_round then
            self.activeIconData.text = TI18N("决赛下注")
        elseif self.now_round == self.max_round - 1 then
            self.activeIconData.text = TI18N("半决赛下注")
        elseif self.now_round == self.max_round - 2 then
            self.activeIconData.text = TI18N("8强下注")
        elseif self.now_round == self.max_round - 3 then
            self.activeIconData.text = TI18N("16强下注")
        else
            self.activeIconData.text = TI18N("淘汰赛预选")
        end
        self.activeIconData.timestamp = nil
        self.activeIconData.clickCallBack = function () WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ingot_crash_content) end
        MainUIManager.Instance:AddAtiveIcon(self.activeIconData)
    elseif self.phase == IngotCrashEumn.Phase.Champion then
        self.activeIconData.clickCallBack = function () WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ingot_crash_content) end
        self.activeIconData.text = TI18N("<color='#ffff00'>决赛可观战</color>")
        self.activeIconData.timestamp = nil
        MainUIManager.Instance:AddAtiveIcon(self.activeIconData)
    elseif self.phase == IngotCrashEumn.Phase.GlobalPreview then
        self.activeIconData.clickCallBack = function () WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ingot_crash_show) end
        if self.hasRegister then
            self.activeIconData.text = TI18N("已报名")
        else
            self.activeIconData.text = TI18N("正在报名")
        end
        self.activeIconData.timestamp = nil
        MainUIManager.Instance:AddAtiveIcon(self.activeIconData)
    end


    if self.phase == IngotCrashEumn.Phase.Ready
        and (
                RoleManager.Instance.RoleData.event ~= RoleEumn.Event.IngotCrashReady
                or RoleManager.Instance.RoleData.event ~= RoleEumn.Event.IngotCrashPVP
                or RoleManager.Instance.RoleData.event ~= RoleEumn.Event.IngotCrashMatch
            )
        then
        self:OnPush()
    end
end

function IngotCrashManager:GetIn()
    -- if not self:IsActive() then
    --     self:Enter()
    -- else
    --     NoticeManager.Instance:FloatTipsByString(TI18N("不能重复报名"))
    -- end
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ingot_crash_show)
end

function IngotCrashManager:IsActive()
    return RoleManager.Instance.RoleData.event == RoleEumn.Event.IngotCrashReady or RoleManager.Instance.RoleData.event == RoleEumn.Event.IngotCrashPVP or RoleManager.Instance.RoleData.event == RoleEumn.Event.IngotCrashMatch
end

function IngotCrashManager:OnPush()
    LuaTimer.Add(math.random(1, 100) * 100, function()
        self.pushTimes = self.pushTimes + 1
        if self.pushTimes > 1 then
            return
        end

        if RoleManager.Instance.RoleData.event == RoleEumn.Event.IngotCrashReady
            or RoleManager.Instance.RoleData.event == RoleEumn.Event.IngotCrashPVP
            or RoleManager.Instance.RoleData.event == RoleEumn.Event.IngotCrashMatch
            then
            return
        end
        local iconData = DataSystem.data_daily_icon[122]
        if RoleManager.Instance.RoleData.lev < iconData.lev then
            return
        end

        if ActivityManager.Instance:GetNoticeState(GlobalEumn.ActivityEumn.ingot_crash) == false then
            -- local data = {}
            -- data.agenda_id = 2056
            -- data.title_text = string.format(TI18N("<color='#00ff00'>%s</color>开始啦{face_1,36}"), self.activityName)
            -- data.desc_text = TI18N("1、每参加1场比赛即可获得<color='#ffff00'>钻石奖励</color>，获胜奖励更丰厚\n2、预选赛排名前列即可<color='#ffff00'>晋级</color>淘汰赛，争夺总冠军\n3、优胜者将获得<color='#ffff00'>[钻石联赛]</color>荣誉称号以及大量钻石奖励\n4、从8强赛开始，可参与下注竞猜、赢取钻石奖励！")
            -- data.endtime = self.time
            -- data.callback = function () self:Enter() end
            -- NewExamManager.Instance.model:OpenDescPanel(data)
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ingot_crash_show)
        end
    end)
end

function IngotCrashManager:OnEventChange(event)
    self:UpdateMainui()
    if event == RoleEumn.Event.IngotCrashPVP then
        self.model:OpenUse()
    else
        self.model:CloseUse()
    end
end

function IngotCrashManager:OpenSettle(args)
    self.model:OpenSettle(args)
end

function IngotCrashManager:OpenWatchList(args)
    self.model:OpenWatchList(args)
end

function IngotCrashManager:OpenShow(args)
    self.model:OpenShow(args)
end

function IngotCrashManager:CurrentType()
    if self.phase == IngotCrashEumn.Phase.Qualifier then
        return 9        -- 预选赛
    elseif self.phase == IngotCrashEumn.Phase.Kickout then
        if self.max_round == self.now_round then
            local me = nil
            local roleData = RoleManager.Instance.RoleData
            for _,v in ipairs(self.model.best16Tab) do
                if v.rid == roleData.id and v.platform == roleData.platform and v.zone_id == roleData.zone_id then
                    me = v
                    break
                end
            end
            if me ~= nil then
                if me.is_loss == 1 and me.loss_round == self.max_round - 1 then
                    return 2
                else
                    return 1
                end
            else
                return 0
            end
        elseif self.max_round == self.now_round + 1 then
            return 3
        elseif self.max_round == self.now_round + 2 then
            return 4
        elseif self.max_round == self.now_round + 3 then
            return 5
        elseif self.max_round == self.now_round + 4 then
            return 6
        elseif self.max_round == self.now_round + 5 then
            return 7
        elseif self.max_round == self.now_round + 6 then
            return 8
        end
    else
        return 9
    end
end

function IngotCrashManager:Enter()
    local confirmData = NoticeConfirmData.New()
    if self.hasRegister == true then
        -- confirmData.content = TI18N("是否消耗<color='#ffff00'>5000</color>{assets_2, 90003}报名入场？\n冠军将获得1500{assets_2, 90026}，参赛至少获得60{assets_2, 90026}")
        self:send20001()
        return
    else
        confirmData.content = TI18N("是否消耗<color='#ffff00'>5000</color>{assets_2, 90003}报名入场？\n冠军将获得1500{assets_2, 90026}，参赛至少获得150{assets_2, 90026}")
    end
    confirmData.sureCallback = function() self:send20001() end
    NoticeManager.Instance:ConfirmTips(confirmData)

    -- self:send20001()
end

function IngotCrashManager:SceneEnter()
    -- print(string.format("self.currstatus: %s  Event: %s  loading: %s", tostring(self.currstatus), tostring(RoleManager.Instance.RoleData.event), tostring(self.loading)))
    -- if self.model.canWalk == true then
    --     return
    -- end
    --print("什么时候sceneEnter...")


    if self:IsActive() then
        local num = 0

        local map_id = 53004
        if IngotCrashManager.Instance.combat_stemp ~= nil and (IngotCrashManager.Instance.combat_stemp < BaseUtils.BASE_TIME or IngotCrashManager.Instance.combat_stemp - BaseUtils.BASE_TIME > 30) then
            return
        end

        -- if SceneManager.Instance:CurrentMapId() == map_id and RoleManager.Instance.RoleData.event == RoleEumn.Event.IngotCrashPVP then
        --     --Set_isovercontroll false为不能移动
        --     SceneManager.Instance.sceneElementsModel:Set_isovercontroll(self.model.canWalk == true)
        -- else
        --     SceneManager.Instance.sceneElementsModel:Set_isovercontroll(true)
        -- end

        -- local datapos = {}
        -- for i,v in ipairs(DataMap.active_region[map_id]) do
        --     local key = math.ceil(num/100)
        --     if datapos[key] == nil then
        --         datapos[key] = {}
        --     end
        --     table.insert(datapos[key], {x = v[1], y = v[2]})
        --     num = num + 1
        -- end

        -- if IS_DEBUG then
        --     if self.model.canWalk == true then
        --         NoticeManager.Instance:FloatTipsByString("关闭阻挡")
        --     else
        --         NoticeManager.Instance:FloatTipsByString("开启阻挡")
        --     end
        -- end

        -- for k,v in pairs(datapos) do
        --     if self.model.canWalk then
        --         -- SceneManager.Instance:On10102({base_id = map_id, flag = 1, pos = v})
        --         LuaTimer.Add(k*100, function() SceneManager.Instance:On10102({base_id = map_id, flag = 0, pos = v}) end)
        --     else
        --         -- SceneManager.Instance:On10102({base_id = map_id, flag = 0, pos = v})
        --         LuaTimer.Add(k*100, function() SceneManager.Instance:On10102({base_id = map_id, flag = 1, pos = v}) end)
        --     end
        -- end
    end
end

-- ====================================== 协议监听 ======================================

-- 战场状态
function IngotCrashManager:send20000()
    Connection.Instance:send(20000, {})
end

function IngotCrashManager:on20000(data)
    -- BaseUtils.dump(data, "<color='#00ff00'>on20000</color>")

    self.ori_group_id = nil
    for i=1,DataGoldLeague.data_group_length do
        local groudData = DataGoldLeague.data_group[i]
        if RoleManager.Instance.RoleData.lev >= groudData.min_lev and RoleManager.Instance.RoleData.lev <= groudData.max_lev then
            self.ori_group_id = groudData.id
        end
    end

    local bool = false
    for i,v in ipairs(data.ids) do
        bool = bool or (v.group_id1 == self.ori_group_id)
    end

    if #data.ids == 0 then
        if data.phase == IngotCrashEumn.Phase.Qualifier or data.phase == IngotCrashEumn.Phase.Kickout or data.phase == IngotCrashEumn.Phase.Guess then
            return
        end
    elseif not bool then
        return
    end

    for k,v in pairs(data) do
        self[k] = v
    end

    self:SetIcon()
    self:UpdateMainui()
    self.onUpdateInfo:Fire()

    if RoleManager.Instance.RoleData.event == RoleEumn.Event.IngotCrashPVP then
        self:send20019()
    end

    AgendaManager.Instance:SetCurrLimitID(2056, data.phase ~= IngotCrashEumn.Phase.Close and data.phase ~= IngotCrashEumn.Phase.Predict and data.phase ~= IngotCrashEumn.Phase.Champion)

    if self.phase ~= IngotCrashEumn.Phase.Close and self.phase ~= IngotCrashEumn.Phase.Predict and self.phase ~= IngotCrashEumn.Phase.Ready then
        self:send20018()
    end
end

-- 进入战场
function IngotCrashManager:send20001()
    Connection.Instance:send(20001, {})
end

function IngotCrashManager:on20001(data)
    -- self.hasRegister = (data.op_code == 1)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 退出战场
function IngotCrashManager:send20002()
    Connection.Instance:send(20002, {})
end

function IngotCrashManager:on20002(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 发起战斗
function IngotCrashManager:send20003()
    Connection.Instance:send(20003, {})
end

function IngotCrashManager:on20003(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 回应发起战斗
function IngotCrashManager:send20004(flag)
    Connection.Instance:send(20004, {flag = flag})
end

function IngotCrashManager:on20004(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 收到发起战斗
function IngotCrashManager:send20005()
    Connection.Instance:send(20005, {})
end

function IngotCrashManager:on20005(data)
    local confirmData = NoticeConfirmData.New()
    confirmData.content = string.format(TI18N("你的对手<color='#00ff00'>%s</color>向你发起挑战，是否迎战？"), data.name)
    confirmData.sureCallback = function() self:send20004(1) end
    confirmData.sureSecond = 5
    confirmData.cancelCallback = function() self:send20004(0) end
    NoticeManager.Instance:ConfirmTips(confirmData)
end

-- 结算
function IngotCrashManager:send20006()
    Connection.Instance:send(20006, {})
end

function IngotCrashManager:on20006(data)
    -- BaseUtils.dump(data, "<color='#ff8800'>------------------on20006-------------------</color>")
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ingot_crash_settle, data)
end

-- 个人信息
function IngotCrashManager:send20007()
-- print("<color='#00ff00'>=================================================================</color>")
    Connection.Instance:send(20007, {})
end

function IngotCrashManager:on20007(data)
    -- BaseUtils.dump(data, "==========<color='#ff8800'>on20007</color>==========")
    self.model.personData.score = data.score
    self.model.personData.win = data.win
    self.model.personData.lose = data.lose
    self.model.personData.reward = data.reward

    -- 个人排名信息需要特殊处理
    self.model.personData.rank = data.rank

    self.onUpdateInfo:Fire()
end

-- 排行榜信息
function IngotCrashManager:send20008()
    Connection.Instance:send(20008, {})
end

function IngotCrashManager:on20008(data)
    -- BaseUtils.dump(data, "==========<color='#ff8800'>on20008</color>==========")
    self.model.rankData = data.gold_league
    self.model.canUpgradeNum = data.num
    self.onUpdateRank:Fire()
end

-- 使用药品
function IngotCrashManager:send20009(id)
-- print("发送20009 ————" .. tostring(id))
    Connection.Instance:send(20009, {id = id})
end

function IngotCrashManager:on20009(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 观战
function IngotCrashManager:send20010(rid, platform, zone_id)
    Connection.Instance:send(20010, {rid = rid, platform = platform, zone_id = zone_id})
end

function IngotCrashManager:on20010(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 十六强
function IngotCrashManager:send20011()
    Connection.Instance:send(20011, {})
end

function IngotCrashManager:on20011(data)
    -- BaseUtils.dump(data, "on20011")
    self.group_id = data.group_id
    for _,v in ipairs(data.gold_league) do
        self.model.best16Tab[v.pos] = v
        v.id = v.rid
    end

    self.model.guessTab = {}
    for _,v in ipairs(data.guess_id) do
        self.model.guessTab[BaseUtils.Key(v.rid1, v.platform1, v.zone_id1)] = 1
    end
    self.onUpdateInfo:Fire()
end

-- 药品状态
function IngotCrashManager:send20012()
    Connection.Instance:send(20012, {})
end

function IngotCrashManager:on20012(data)
    for i=1,2 do
        self.model.drugTimes[i].times = data[string.format("times%s", i)]
        self.model.drugTimes[i].times_use = data[string.format("times_use%s", i)]
        self.model.drugTimes[i].times_all = data[string.format("times_all%s", i)]
    end
    self.onUpdateInfo:Fire()
end

-- 设置弹幕开关
function IngotCrashManager:send20013(flag)
    Connection.Instance:send(20013, {flag = flag})
end

function IngotCrashManager:on20013(data)
    self.model.showDamaku = data.flag
end

-- 发送弹幕
function IngotCrashManager:send20014(msg)
    -- print("fasong " .. msg)
    Connection.Instance:send(20014, {msg = string.gsub(msg, "{(%l-_%d.-),(.-)}", "")})
end

function IngotCrashManager:on20014(data)
    -- BaseUtils.dump(data, "on20014")
    local func = function()
        if (WindowManager.Instance.currentWin ~= nil and WindowManager.Instance.currentWin.windowId == WindowConfig.WinID.ingot_crash_content and WindowManager.Instance.currentWin.isOpen == true)
            or (SceneManager.Instance:CurrentMapId() == 53002 or SceneManager.Instance:CurrentMapId() == 53003 or SceneManager.Instance:CurrentMapId() == 53004)
            or (CombatManager.Instance.isWatching == true and CombatManager.Instance.combatType == 114)
            then
            if data.op_code == 1 then
                if self.isShowDamaku == true then
                    NoticeManager.Instance:On9902({type = MsgEumn.NoticeType.NormalDanmaku, msg = data.msg})
                end
            else
                NoticeManager.Instance:FloatTipsByString(data.msg)
            end
        end
    end

    for _,v in ipairs(data.ids) do
        if v.group_id1 == self.group_id then
            func()
            return
        end
    end
end

-- 请求玩家下注信息
function IngotCrashManager:send20015(rid1, platform1, zone_id1, rid2, platform2, zone_id2)
    Connection.Instance:send(20015, {rid1 = rid1, platform1 = platform1, zone_id1 = zone_id1, rid2 = rid2, platform2 = platform2, zone_id2 = zone_id2})
end

function IngotCrashManager:on20015(data)
    -- BaseUtils.dump(data, "on20015")
    self.model.guessNumTab[BaseUtils.Key(data.rid1, data.platform1, data.zone_id1)] = {num = data.num1, odds = data.odds1}
    self.model.guessNumTab[BaseUtils.Key(data.rid2, data.platform2, data.zone_id2)] = {num = data.num2, odds = data.odds1}

    self.onUpdateVote:Fire(data.rid1, data.platform1, data.zone_id1, data.rid2, data.platform2, data.zone_id2)
end

-- 下注
function IngotCrashManager:send20016(rid1, platform1, zone_id1, grade)
    Connection.Instance:send(20016, {rid1 = rid1, platform1 = platform1, zone_id1 = zone_id1, grade = grade})
end

function IngotCrashManager:on20016(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 查看录像
function IngotCrashManager:send20027(rid1, platform1, zone_id1, rid2, platform2, zone_id2)
    Connection.Instance:send(20027, {rid1 = rid1, platform1 = platform1, zone_id1 = zone_id1, rid2 = rid2, platform2 = platform2, zone_id2 = zone_id2})
end

function IngotCrashManager:on20027(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 战场信息
function IngotCrashManager:send20018()
    Connection.Instance:send(20018, {})
end

function IngotCrashManager:on20018(data)
    -- BaseUtils.dump(data, "on20018")
    self.group_id = data.group_id
    self.num = data.num

    self.onUpdateInfo:Fire()
end

-- 对手信息
function IngotCrashManager:send20019()
    Connection.Instance:send(20019, {})
end

function IngotCrashManager:on20019(data)
    data.id = data.rid          -- 不要问我为什么
    self.model.enemyData = data
    self.combat_stemp = data.combat_time

    self.onUpdateInfo:Fire()
end

-- 观战推送
function IngotCrashManager:send20021()
    Connection.Instance:send(20021, {})
end

function IngotCrashManager:on20021(data)
    if not CombatManager.Instance.isFighting then
        local confirmData = NoticeConfirmData.New()
        confirmData.content = data.msg
        confirmData.cancelSecond = 30
        confirmData.sureCallback = function() self:send20010(data.rid1, data.platform1, data.zone_id1) end
        NoticeManager.Instance:ConfirmTips(confirmData)
    end
end

-- 观战列表
function IngotCrashManager:send20022()
    Connection.Instance:send(20022, {})
end

function IngotCrashManager:on20022(data)
    -- BaseUtils.dump(data, "on20022")
    self.model.watchList = data.gold_league_combat
    self.onUpdateWatch:Fire()
end

-- 冠军展示
function IngotCrashManager:send20023()
    Connection.Instance:send(20023, {})
end

function IngotCrashManager:on20023(data)
    BaseUtils.dump(data, "on20023")
    for i,v in ipairs(data.ids) do
        if self.group_id == v.group_id1 then
            self.model:ShowChampions(data.gold_league)
            return
        end
    end
end

-- 报名状态
function IngotCrashManager:send20024()
    Connection.Instance:send(20024, {})
end

function IngotCrashManager:on20024(data)
    self.hasRegister = (data.flag == 1)
    self:SetIcon()
end

-- 随机观战
function IngotCrashManager:send20025()
    Connection.Instance:send(20025, {})
end

function IngotCrashManager:on20025(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 随机观战
function IngotCrashManager:send20026()
    Connection.Instance:send(20026, {})
end

function IngotCrashManager:on20026(data)
    if self.noAtttention ~= true then
        local confirmData = NoticeConfirmData.New()
        confirmData.sureCallback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ingot_crash_content) end
        confirmData.sureLabel = TI18N("前往下注")
        confirmData.content = data.msg
        confirmData.cancelSecond = 30
        confirmData.showToggle = true
        confirmData.toggleLabel = TI18N("不再提示")
        confirmData.toggleCallback = function() self.noAtttention = not (self.noAtttention or false) end
        NoticeManager.Instance:ConfirmTips(confirmData)
    end
    -- NoticeManager.Instance:FloatTipsByString(data.msg)
end

function IngotCrashManager:Simulation()
    self.max_round = 5
    local data = {
        gold_league = {
            {id = 0, platform = "1", zone_id = 1, name = "aaa", classes = 1, sex = 0, face_id = 0, rank = 1, score = 10, pos = 1, group_id = 1, is_loss = 0, loss_round = 0},
            {id = 0, platform = "1", zone_id = 1, name = "bbb", classes = 1, sex = 0, face_id = 0, rank = 1, score = 10, pos = 2, group_id = 1, is_loss = 1, loss_round = 2},
            {id = 0, platform = "1", zone_id = 1, name = "ccc", classes = 1, sex = 0, face_id = 0, rank = 1, score = 10, pos = 3, group_id = 1, is_loss = 0, loss_round = 0},
            {id = 0, platform = "1", zone_id = 1, name = "ddd", classes = 1, sex = 0, face_id = 0, rank = 1, score = 10, pos = 4, group_id = 1, is_loss = 1, loss_round = 2},
            {id = 0, platform = "1", zone_id = 1, name = "eee", classes = 1, sex = 0, face_id = 0, rank = 1, score = 10, pos = 5, group_id = 1, is_loss = 1, loss_round = 2},
            {id = 0, platform = "1", zone_id = 1, name = "fff", classes = 1, sex = 0, face_id = 0, rank = 1, score = 10, pos = 6, group_id = 1, is_loss = 0, loss_round = 0},
            {id = 0, platform = "1", zone_id = 1, name = "ggg", classes = 1, sex = 0, face_id = 0, rank = 1, score = 10, pos = 7, group_id = 1, is_loss = 1, loss_round = 2},
            {id = 0, platform = "1", zone_id = 1, name = "hhh", classes = 1, sex = 0, face_id = 0, rank = 1, score = 10, pos = 8, group_id = 1, is_loss = 0, loss_round = 0},
            {id = 0, platform = "1", zone_id = 1, name = "iii", classes = 1, sex = 0, face_id = 0, rank = 1, score = 10, pos = 9, group_id = 1, is_loss = 0, loss_round = 0},
            {id = 0, platform = "1", zone_id = 1, name = "jjj", classes = 1, sex = 0, face_id = 0, rank = 1, score = 10, pos = 10, group_id = 1, is_loss = 0, loss_round = 0},
            {id = 0, platform = "1", zone_id = 1, name = "kkk", classes = 1, sex = 0, face_id = 0, rank = 1, score = 10, pos = 11, group_id = 1, is_loss = 0, loss_round = 0},
            -- {id = 0, platform = "1", zone_id = 1, name = "lll", classes = 1, sex = 0, face_id = 0, rank = 1, score = 10, pos = 12, group_id = 1, is_loss = 0, loss_round = 0},
            -- {id = 0, platform = "1", zone_id = 1, name = "mmm", classes = 1, sex = 0, face_id = 0, rank = 1, score = 10, pos = 13, group_id = 1, is_loss = 0, loss_round = 0},
            {id = 0, platform = "1", zone_id = 1, name = "nnn", classes = 1, sex = 0, face_id = 0, rank = 1, score = 10, pos = 14, group_id = 1, is_loss = 0, loss_round = 0},
            {id = 0, platform = "1", zone_id = 1, name = "ooo", classes = 1, sex = 0, face_id = 0, rank = 1, score = 10, pos = 15, group_id = 1, is_loss = 0, loss_round = 0},
            {id = 0, platform = "1", zone_id = 1, name = "ppp", classes = 1, sex = 0, face_id = 0, rank = 1, score = 10, pos = 16, group_id = 1, is_loss = 0, loss_round = 0},
        },
        guess_id = {
            {rid1 = 0, platform1 = "1", zone_id1 = 1}
        }
    }

    self:on20011(data)
end

function IngotCrashManager:OnBeginFight(combat_type)
    if combat_type == 114 then
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.ingot_crash_content)

        -- Log.Error("=========================!========!==================")
        print(CombatManager.Instance.isWatching)
        if CombatManager.Instance.isWatching then
            self.model:OpenDamaku()
        else
            self.model:CloseDamaku()
        end
    end
end

function IngotCrashManager:OnEndFight(combat_type, result)
    if combat_type == 114 then
        if SceneManager.Instance:CurrentMapId() == 53002 or SceneManager.Instance:CurrentMapId() == 53003 then
            self.model:OpenDamaku()
        else
            self.model:CloseDamaku()
        end
    end
end

function IngotCrashManager:SceneLoad()
    if (SceneManager.Instance:CurrentMapId() == 53002 or SceneManager.Instance:CurrentMapId() == 53003) or (CombatManager.Instance.isWatching and CombatManager.Instance.combat_type == 114) then
        self.model:OpenDamaku()
    else
        self.model:CloseDamaku()
    end
end


--阻挡区域
function IngotCrashManager:IsLegal(target,x,y)
    if target == nil then
        return false
    end
    --print("3333")
    self.tempPos = target:GetCachedTransform().localPosition
    self.tempPos = SceneManager.Instance.sceneModel:transport_big_pos(self.tempPos.x, self.tempPos.y)
    local currentZone = self:CheckZone(self.tempPos)

    self.tempPos = SceneManager.Instance.sceneModel:transport_big_pos(x, y)

    --BaseUtils.dump(self.tempPos,"self.tempPos:")

    local targetZone = self:CheckZone(self.tempPos)
    if SceneManager.Instance:CurrentMapId() == 53004 and RoleManager.Instance.RoleData.event == RoleEumn.Event.IngotCrashPVP then
        if self.model.canWalk == false then
            if targetZone == IngotCrashEumn.Area.Block then
                --and currentZone == GuildDragonEnum.Area.Block
                --NoticeManager.Instance:FloatTipsByString(TI18N("暂时无法进入!"))
                return false
            else
                return true
            end
        else
            return true
        end
    else
        return true
    end
end

function IngotCrashManager:CheckZone(pos)
    if self:InRect(self.blockAreaList, pos) then
        return IngotCrashEumn.Area.Block
    else
        return IngotCrashEumn.Area.Walk
    end
end

function IngotCrashManager:InRect(rect, pos)
    local area = 0
    local length = #rect.list
    for i,v in ipairs(rect.list) do
        area = area + math.abs((v.x - pos.x) * (rect.list[i % length + 1].y - pos.y) - (v.y - pos.y) * (rect.list[i % length + 1].x - pos.x))
    end
    area = area / 2
    return self:GetArea(rect) >= area
end

function IngotCrashManager:GetArea(rect)
    if rect.area == nil then
        rect.area = 0
        local length = #rect.list
        for i=2,length - 1 do
            rect.area = rect.area + math.abs((rect.list[1].x - rect.list[i].x) * (rect.list[1].y - rect.list[i + 1].y) - (rect.list[1].y - rect.list[i].y) * (rect.list[1].x - rect.list[i + 1].x))
        end
        rect.area = rect.area / 2
    end
    return rect.area
end