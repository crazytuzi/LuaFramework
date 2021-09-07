ArenaModel = ArenaModel or BaseClass(BaseModel)

function ArenaModel:__init()
    self.mgr = ArenaManager.Instance
    self.countDown = 0

    self.settlementWindow = nil

    self.rank_list = {}
    self.fellowGuards = {}
    self.max_soul = 25
    self.roll_time = 0
    self.roll_id = 0
    self.has_soul = 0

    self.achievements = {
        {name = TI18N("总场次"), order = 1, rate = "0"}
        , {name = TI18N("进攻胜率"), order = 2, rate = "0%"}
        , {name = TI18N("防守胜率"), order = 3, rate = "0%"}
        , {name = TI18N("历史最高分"), order = 4, rate = "0"}
        , {name = TI18N("全服最高分"), order = 5, rate = "0"}
    }

    self.jobList = {}
    for i,v in ipairs(KvData.classes_name) do
        self.jobList[i] = {name = v, rate = "--"}
    end

    self.formation = nil
    self.formation_lev = nil
    self.guardId1 = nil
    self.guardId2 = nil
    self.guardId3 = nil
    self.guardId4 = nil

    self.times = 10
end

function ArenaModel:__delete()
    if self.arenaWin ~= nil then
        self.arenaWin:DeleteMe()
        self.arenaWin = nil
    end
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function ArenaModel:OpenWindow(args)
    if RoleManager.Instance.RoleData.cross_type == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("跨服暂不支竞技场战斗"))
        return
    end
    if self.arenaWin == nil then
        self.arenaWin = ArenaWindow.New(self)
    end

    if args == nil or args[1] == nil or (args[1] > 3 or args[1] < 1) then
        self.currentTab = 1
    else
        self.currentTab = args[1]
    end

    if BaseUtils.IsVerify == true then
        self.currentTab = 1
    end

    self.arenaWin.isOpen = true
    self.arenaWin:Open()
end

function ArenaModel:SetData(data)
    self.cup = data.cup or 0
    self.records = data.log
    self.fellows = data.enemy
    self.has_soul = data.has_soul or 0
    self:SortFellows()
end

function ArenaModel:SortFellows()
    if self.fellows ~= nil then
        table.sort(self.fellows, function(a, b) return a.order < b.order end)
    end
end

function ArenaModel:CloseWin()
    if self.arenaWin ~= nil then
        WindowManager.Instance:CloseWindow(self.arenaWin)
    end
end

function ArenaModel:GetFellow(i)
    if self.fellows == nil then
        return nil
    end
    return self.fellows[i]
end

function ArenaModel:GetRecord(i)
    if self.records == nil then
        return nil
    end
    return self.records[i]
end

function ArenaModel:ReloadFellows()
    self.countDown = 10
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
    end
    self.timerId = LuaTimer.Add(0, 1000, function() self:CountDown() end)
end

function ArenaModel:CountDown()
    if self.countDown > 0 then
        self.countDown = self.countDown - 1
    else
        if self.timerId ~= nil then
            LuaTimer.Delete(self.timerId)
            self.timerId = nil
        end
    end
end

function ArenaModel:SetPersonalData(data)
    local arena_role = data
    for k,v in pairs(arena_role) do
        if v ~= nil then
            self[k] = v
        end
    end

    if self.init_def ~= 1 then
        local ids = {}
        for k,v in pairs(ShouhuManager.Instance.model.my_sh_list) do
            if v.war_id ~= nil and v.war_id > 0 then
                table.insert(ids, v.base_id)
            end
        end
        self.mgr:send12207(FormationManager.Instance.formationId, ids[1], ids[2], ids[3], ids[4])
    end

    -- 个人胜率
    self.achievements[1].rate = tostring(self.acc_num)

    -- 进攻胜率
    if self.acc_num == 0 then
        self.achievements[2].rate = "<color=#ffffff>--</color>"
    elseif self.win > self.acc_num then
        self.achievements[2].rate = "<color=#ffffff>100%</color>"
    else
        self.achievements[2].rate = "<color=#ffffff>"..tostring(math.ceil(self.win * 100 / self.acc_num)).."%</color>"
    end

    if self.def_acc_num == 0 then
        self.achievements[3].rate = "--"
    elseif self.def_win > self.def_acc_num then
        self.achievements[3].rate = "100%"
    else
        self.achievements[3].rate =tostring(math.ceil(self.def_win * 100 / self.def_acc_num)).."%"
    end

    self.achievements[4].rate = tostring(self.max_cup)
    self.achievements[5].rate = tostring(self.world_max_cup)
    self.mgr.onUpdatePersonal:Fire()

    -- 对各职业胜率
    if self.acc_sword_num > 0 then
        self.jobList[1].rate = tostring(math.ceil(self.win_sword * 100 / self.acc_sword_num)).."%"
    end
    if self.acc_mage_num > 0 then
        self.jobList[2].rate = tostring(math.ceil(self.win_mage * 100 / self.acc_mage_num)).."%"
    end
    if self.acc_archer_num > 0 then
        self.jobList[3].rate = tostring(math.ceil(self.win_archer * 100 / self.acc_archer_num)).."%"
    end
    if self.acc_orc_num > 0 then
        self.jobList[4].rate = tostring(math.ceil(self.win_orc * 100 / self.acc_orc_num)).."%"
    end
    if self.acc_devine_num > 0 then
        self.jobList[5].rate = tostring(math.ceil(self.win_devine * 100 / self.acc_devine_num)).."%"
    end
    if self.acc_moon_num ~= nil and self.acc_moon_num > 0 then
        self.jobList[6].rate = tostring(math.ceil(self.win_moon * 100 / self.acc_moon_num)).."%"
    end
    if self.acc_templar_num ~= nil and self.acc_templar_num > 0 then
        self.jobList[7].rate = tostring(math.ceil(self.win_templar * 100 / self.acc_templar_num)).."%"
    end

    for i,v in ipairs(self.guards) do
        self["guardId"..(v.war_id - 1)] = v.guard_id
    end
    self.mgr.onUpdateJobs:Fire()

    self.mgr.onUpdateCombatForce:Fire()
    self.mgr.onUpdatePet:Fire()
end

function ArenaModel:SetFriendsData(data)
    self.rank_list = data.rank_list
    self.mgr.onUpdateFriends:Fire()
end

function ArenaModel:OpenGuardTips(args)
    if self.guardTips == nil then
        self.guardTips = ArenaGuardPanel.New(self.arenaWin.gameObject, self)
    end
    self.guardTips:Show(args)
end

function ArenaModel:CloseGuardTips()
    if self.guardTips ~= nil then
        self.guardTips:Hiden()
    end
end

function ArenaModel:OpenVictoryWindow()
    if self.vicWin == nil then
        self.vicWin = ArenaVictoryWindow.New(self)
    end
    self.vicWin:Open()
end

function ArenaModel:CloseVic()
    if self.vicWin ~= nil then
        WindowManager.Instance:CloseWindow(self.vicWin)
    end
end

function ArenaModel:OpenGiftPreview(args)
    if self.giftPreview == nil then
        self.giftPreview = GiftPreview.New(self.vicWin.gameObject)
    end
    self.giftPreview:Show(args)
end

function ArenaModel:CloseGiftPreview()
    if self.giftPreview ~= nil then
        self.giftPreview:DeleteMe()
        self.giftPreview = nil
    end
end

function ArenaModel:OpenSettlementWindow(args)
    if self.settlementWindow == nil then
        self.settlementWindow = ArenaSettlementWindow.New(self)
    end
    self.settlementWindow:Open(args)
end

function ArenaModel:CloseSettlementWindow()
    if self.settlementWindow ~= nil then
        self.settlementWindow:DeleteMe()
        self.settlementWindow = nil
    end
end
