ArenaManager = ArenaManager or BaseClass(BaseManager)

function ArenaManager:__init()
    if ArenaManager.Instance ~= nil then
        return
    end

    self.redPoint = {
        false               -- 被挑战
        , false             -- 招募新守护
    }

    if BaseUtils.IsVerify == true then
        self.redPoint = {
            false               -- 被挑战
        }
    end

    self.onUpdateJobs = EventLib.New()
    self.onUpdatePersonal = EventLib.New()
    self.onUpdateFriends = EventLib.New()
    self.onUpdateCombatForce = EventLib.New()
    self.onUpdateMyScore = EventLib.New()
    self.onUpdateFellowGuard = EventLib.New()
    self.onUpdateTime = EventLib.New()
    self.onUpdateNewGuard = EventLib.New()
    self.onUpdateRed = EventLib.New()
    self.onUpdateVic = EventLib.New()
    self.onUpdateRoll = EventLib.New()
    self.onUpdatePet = EventLib.New()

    ArenaManager.Instance = self
    self.model = ArenaModel.New()

    self.hasNewGuard = false
    self.isWatching = false

    self.endfrightfunct = function (type, result)
        self:OpenWindowEndFright(type, result)
    end

    EventMgr.Instance:AddListener(event_name.guard_recruit_success, function()
        self.hasNewGuard = true
        self.redPoint[2] = self.redPoint[2] or (self.model.arenaWin == nil or self.model.arenaWin.isOpen ~= true)
        self.onUpdateNewGuard:Fire()
        self.onUpdateRed:Fire()
    end)

    EventMgr.Instance:AddListener(event_name.end_fight, function()
        if self.isWatching == true then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.arena_window)
            self.isWatching = false
        end
    end)

    self.onUpdateRed:AddListener(function()
        local bool = false
        for k,v in pairs(self.redPoint) do
            bool = bool or v
        end
        if MainUIManager.Instance.MainUIIconView ~= nil then
            MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(28, bool)
        end
    end)

    self:InitHandlers()
end

function ArenaManager:__delete()
    if self.onUpdateJobs ~= nil then
        self.onUpdateJobs:DeleteMe()
        self.onUpdateJobs = nil
    end
    if self.onUpdatePersonal ~= nil then
        self.onUpdatePersonal:DeleteMe()
        self.onUpdatePersonal = nil
    end
    if self.onUpdateFriends ~= nil then
        self.onUpdateFriends:DeleteMe()
        self.onUpdateFriends = nil
    end
    if self.onUpdateCombatForce ~= nil then
        self.onUpdateCombatForce:DeleteMe()
        self.onUpdateCombatForce = nil
    end
    if self.onUpdateMyScore ~= nil then
        self.onUpdateMyScore:DeleteMe()
        self.onUpdateMyScore = nil
    end
    if self.onUpdateFellowGuard ~= nil then
        self.onUpdateFellowGuard:DeleteMe()
        self.onUpdateFellowGuard = nil
    end
    if self.onUpdatePet ~= nil then
        self.onUpdatePet:DeleteMe()
        self.onUpdatePet = nil
    end
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end

    self:RemoveHandlers()
end

function ArenaManager:InitHandlers()
    self:AddNetHandler(12200, self.on12200)
    self:AddNetHandler(12201, self.on12201)
    self:AddNetHandler(12202, self.on12202)
    self:AddNetHandler(12203, self.on12203)
    self:AddNetHandler(12204, self.on12204)
    self:AddNetHandler(12205, self.on12205)
    self:AddNetHandler(12206, self.on12206)
    self:AddNetHandler(12207, self.on12207)
    self:AddNetHandler(12208, self.on12208)
    self:AddNetHandler(12209, self.on12209)
    self:AddNetHandler(12210, self.on12210)
    self:AddNetHandler(12211, self.on12211)
    self:AddNetHandler(12212, self.on12212)
    self:AddNetHandler(12213, self.on12213)
    self:AddNetHandler(12214, self.on12214)
    self:AddNetHandler(12215, self.on12215)
    self:AddNetHandler(12216, self.on12216)
    self:AddNetHandler(12217, self.on12217)
end

function ArenaManager:RemoveHandlers()
end

function ArenaManager:OpenWindow(args)
    -- MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(28, false)
    local need_lev = DataAgenda.data_list[1002].open_leve
    if RoleManager.Instance.RoleData.lev >= need_lev then
        self.model:OpenWindow(args)
    else
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("竞技场%s级开启"), tostring(need_lev)))
    end
end

function ArenaManager:CloseWindow()
    self.model:CloseWin()
end

function ArenaManager:send12200(callback)
  -- print("发送12200")
    self.on12200_callback = callback
    Connection.Instance:send(12200, {})
end

function ArenaManager:send12201(data)
  -- print("发送12201")
    Connection.Instance:send(12201, data)
end

function ArenaManager:send12202(callback)
  -- print("发送12202")
    self.on12202_callback = callback
    Connection.Instance:send(12202, {})
end

function ArenaManager:send12203()
    Connection.Instance:send(12203, {})
end

function ArenaManager:send12204(record_id)
    -- self.on12204_callback = callback
  -- print("发送12204 "..record_id)
    Connection.Instance:send(12204, {log_id = record_id})
end

function ArenaManager:send12205(callback)
    self.on12205_callback = callback
    Connection.Instance:send(12205, {})
end

function ArenaManager:on12200(data)
    -- BaseUtils.dump(data, "接收12200")
    local model = self.model
    model:SetData(data)
    self.onUpdateMyScore:Fire()
end

function ArenaManager:on12201(data)
    BaseUtils.dump(data, "接收12201")
    local flag = data.flag
    local msg = data.msg
    if flag == 0 then
        NoticeManager.Instance:FloatTipsByString(msg)
    else
        self:CloseWindow()
        -- EventMgr.Instance:RemoveListener(event_name.end_fight, self.endfrightfunct)
        -- EventMgr.Instance:AddListener(event_name.end_fight, self.endfrightfunct)
    end
end

function ArenaManager:on12202(data)
    -- BaseUtils.dump(data, "接收12202")
    local model = self.model
    if model ~= nil then
        if data.flag == 1 then
            model.fellows = data.enemy
            model.fellowGuards = {}
            model:SortFellows()
            NoticeManager.Instance:FloatTipsByString(TI18N("刷新成功"))
            model:ReloadFellows()
            self.onUpdateMyScore:Fire()
        end
    end
end

function ArenaManager:on12203(data)
    -- BaseUtils.dump(data, "接收12203")
    local model = self.model
    if model ~= nil then
        model.records = data.log
        -- BaseUtils.dump(data, "战斗记录")
        model.cup = data.cup
        model.has_soul = data.has_soul

        local roleinfo = RoleManager.Instance.RoleData
        if model.records[1].s_name ~= roleinfo.name then
            self.redPoint[1] = self.redPoint[1] or (model.arenaWin == nil or model.arenaWin.isOpen ~= true)
            self.onUpdateRed:Fire()
        end

        self.onUpdateMyScore:Fire()
        self.onUpdateTime:Fire()
    end
end

function ArenaManager:on12204(data)
    local model = self.model
    if data.flag == 0 then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    else
        self:CloseWindow()
        -- EventMgr.Instance:RemoveListener(event_name.end_fight, self.endfrightfunct)
        -- EventMgr.Instance:AddListener(event_name.end_fight, self.endfrightfunct)
    end
end

function ArenaManager:on12205(data)
    -- BaseUtils.dump(data, "接收12205")
    local model = self.model
    for k,v in pairs(data) do
        model[k] = v
    end
    self.model.roll_time = data.roll_time
    self.redPoint[1] = self.redPoint[1] or (data.roll_time > 0)
    self.onUpdateRed:Fire()
    self.onUpdateTime:Fire()
    self.onUpdateRoll:Fire()
end

function ArenaManager:OpenWindowEndFright(type, result)
    if result == 1 then
    end
    EventMgr.Instance:RemoveListener(event_name.end_fight, self.endfrightfunct)
    -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.arena_window, {1})
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.arenasettlementwindow)
end

function ArenaManager:send12206()
  -- print("发送12206")
    Connection.Instance:send(12206, {})
end

function ArenaManager:send12207(formationId, id1, id2, id3, id4)
    if id1 == nil then id1 = 0 end
    if id2 == nil then id2 = 0 end
    if id3 == nil then id3 = 0 end
    if id4 == nil then id4 = 0 end
    local dat = {formation = formationId, guard_id_1 = id1, guard_id_2 = id2, guard_id_3 = id3, guard_id_4 = id4}
    -- BaseUtils.dump(dat, "<color=#0000FF>发送12207</color>")
    Connection.Instance:send(12207, dat)
end

function ArenaManager:send12208()
  -- print("发送12208")
    Connection.Instance:send(12208, {})
end

function ArenaManager:on12206(data)
    -- BaseUtils.dump(data, "返回12206, <color=#FF0000>请求个人数据统计</color>")
    local model = self.model
    model:SetPersonalData(data)
end

function ArenaManager:on12207(data)
    -- BaseUtils.dump(data, "返回12207, <color=#00FF00>更改个人防御阵型</color>")
    NoticeManager.Instance:FloatTipsByString(data.msg)

    if data.flag == 1 then
        local model = self.model
        model.formation = data.formation
        model.formation_lev = data.formation_lev
        for i=1,4 do
            model["guardId"..i] = nil
        end
        for i,v in ipairs(data.guards) do
            model["guardId"..(v.war_id - 1)] = v.guard_id
        end
        self.onUpdateCombatForce:Fire()
    end
end

function ArenaManager:on12208(data)
    -- BaseUtils.dump(data, "返回12208, <color=#00FF00>请求好友排行榜</color>")
    local model = self.model
    model:SetFriendsData(data)
end

function ArenaManager:send12209(index)
    -- print("请求12209")
    local dat = {order = index}
    -- BaseUtils.dump(dat)
    Connection.Instance:send(12209, dat)
end

function ArenaManager:on12209(data)
    -- BaseUtils.dump(data, "返回12209")
    self.model.fellowGuards[data.order] = data.guards
    self.onUpdateFellowGuard:Fire(data.order)
end

function ArenaManager:ClearData()
    self.model:SetData({})
    if RoleManager.Instance.RoleData.lev >= DataSystem.data_icon[28].lev then
        self:send12205()
        self:send12211()
    end
end

function ArenaManager:OpenVictoryWindow()
    self.model:OpenVictoryWindow()
end

function ArenaManager:send12210()
  -- print("发送12210")
    Connection.Instance:send(12210, {})
end

function ArenaManager:on12210(data)
    BaseUtils.dump(data, "接收12210")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.model.has_soul = data.soul
    if data.flag == 1 then
        local gain = {}
        for i,v in ipairs(data.gain) do
            table.insert(gain, {id = v.base_id, num = v.num})
        end
        FinishCountManager.Instance.model.reward_win_data = {
            titleTop = TI18N("战魂之心")
            -- , val = string.format("目前排名：<color='#ffff00'>%s</color>", self.rank)
            , val2 = TI18N("战魂之心开启！")
            , val1 = TI18N("恭喜您集满战魂，开启了战魂之心宝箱！")
            , val = TI18N("这是您的奖励")
            , title = TI18N("战魂之心奖励")
            , confirm_str = TI18N("确 认")
            , reward_list = gain
            , confirm_callback = function() end
            , share_callback = nil
        }
        FinishCountManager.Instance.model:InitRewardWin_Common()
    end
    self.onUpdateMyScore:Fire()
end

-- 胜利之路面板
function ArenaManager:send12211()
  -- print("发送12211")
    Connection.Instance:send(12211, {})
end

function ArenaManager:on12211(data)
    --BaseUtils.dump(data, "接收12211")
    self.model.vicData = data
    self.model.roll_id = data.roll_id
    self.model.roll_time = data.roll_time
    self.redPoint[1] = self.redPoint[1] or (data.roll_time > 0)
    self.model.roll_id = data.roll_id
    self.onUpdateVic:Fire()
    self.onUpdateRed:Fire()
end

-- roll点
function ArenaManager:send12212()
  -- print("发送12212")
    Connection.Instance:send(12212, {})
end

function ArenaManager:on12212(data)
    -- BaseUtils.dump(data, "接收12212")
    if data.flag == 0 then
        NoticeManager.Instance:FloatTipsByString(data.msg)
        self.model.failed = true
    else
        self.model.failed = false
        self.model.rollPointData = data
        self.model.roll_time = data.roll_time
        self.redPoint[1] = self.redPoint[1] or (data.roll_time > 0)
        self.model.roll_id = data.roll_id
        self.onUpdateMyScore:Fire()
    end
    self.onUpdateRoll:Fire()
    self.onUpdateRed:Fire()
    -- self:send12205()
end

-- 分享
function ArenaManager:send12213()
  -- print("发送12213")
    Connection.Instance:send(12213, {})
end

function ArenaManager:on12213(data)
    BaseUtils.dump(data, "接收12213")
end

function ArenaManager:send12214()
  -- print("发送12214")
    Connection.Instance:send(12214, {})
end

function ArenaManager:on12214(data)
    BaseUtils.dump(data, "接收12214")
    self.model.has_soul = data.has_soul
    self.onUpdateMyScore:Fire()
end

function ArenaManager:send12215(log_id)
  -- print("发送12215")
    Connection.Instance:send(12215, {log_id = log_id})
end

function ArenaManager:on12215(data)
    BaseUtils.dump(data, "接收12215")
    if data.result == 1 then
        self.isWatching = true
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.arena_window)
    else
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end

function ArenaManager:on12216(data)
    BaseUtils.dump(data, "接收12216")
    if #data.t_statistics > 0 and #data.s_statistics > 0 then
        -- SoundManager.Instance:Play(230)
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.arenasettlementwindow, { data })
    end
end

function ArenaManager:send12217(pet_id)
  -- print("发送12217")
    Connection.Instance:send(12217, {pet_id = pet_id})
end

function ArenaManager:on12217(data)
    BaseUtils.dump(data, "接收12217")

    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.model.pet_id = data.pet_id
    self.onUpdatePet:Fire()
end
