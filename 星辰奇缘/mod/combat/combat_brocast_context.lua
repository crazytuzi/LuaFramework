-- 播报的上下文
BrocastContext = BrocastContext or BaseClass()

function BrocastContext:__init(controller)
    self.combatMgr = CombatManager.Instance
    self.controller = controller
    -- self.gameObjectpool = CombatObjectPool.New()
    -- self.gameObjectpool = CombatManager.Instance.objPool
    self.brocastData = nil
    self.nextbrocastData = nil
    self.firstAction = nil
    -- [fighterId] = FighterController
    self.fighterDict = {}
    self.fighterResDict = {} -- 无节操小包新增，保证只调用一次SubpackageManager.Instance:RoleResources替代资源方法，避免两次调用之间资源下载完成导致报错

    self.majorCtx = nil

    self.buffBroadData = nil
    self.syncBuffAction = nil

    self.specialData = nil
    self.syncSpecialAction = nil

    self.buffupdateData = nil
    self.brocastEndData = nil

    self.islastRound = false

    self.OnBrocastEnd = {}
end

function BrocastContext:__delete()
    -- if self.gameObjectpool ~= nil then
    --     self.gameObjectpool:DeleteMe()
    -- end
    self.gameObjectpool = nil
end

function BrocastContext:Release()
    self.brocastData = nil
end

function BrocastContext:Parse()
    local actionList = BaseUtils.copytab(self.brocastData.action_list)
    -- table.sort(actionList, CombatUtil.SortMojorData)
    table.sort(actionList, function(a,b)
        return a.order < b.order
    end)
    local lastAction = nil
    self.firstAction = nil
    local talkAction = self:ParseTalk()
    self.firstAction = talkAction
    lastAction = talkAction
    self.buffupdateData = self.controller:BuildBuffUpdateData(self.brocastData)
    for _, data in ipairs(actionList) do
        if self.firstAction == nil then
            self.firstAction = MajorAction.New(self, data)
            lastAction = self.firstAction
        else
            local current = MajorAction.New(self, data, lastAction.self_id)
            lastAction:AddEvent(CombatEventType.End, current)
            lastAction = current
        end
    end
    local statusAction = ResetStatusAction.New(self, self.brocastData.fighter_status_list, false)
    statusAction:AddEvent(CombatEventType.End, self.PlayEnd, self)
    if lastAction ~= nil then
        lastAction:AddEvent(CombatEventType.End, statusAction)
    else
        Log.Error("[Warning] lastAction is nil!!!")
        statusAction:Play()
    end
end

function BrocastContext:Play()
    if self.firstAction ~= nil then
        self.firstAction:Play()
    end
end

function BrocastContext:PlayEnd()
    -- self.combatMgr.RecorderSkip = false
    self.controller:UpdateSelfHpBar()
    if self.buffupdateData ~= nil then
        local updatadata = self.buffupdateData
        LuaTimer.Add(100, function ()self.controller:PlayBuff(updatadata) end)
        -- self.controller:PlayBuff(self.buffupdateData)
        -- self.buffupdateData = nil
    end
    self.combatMgr.isBrocasting = false
    self.combatMgr.FireEndFightBroad = true
    self:ReleaseSpecial()
    self:SetSpecialData(self.brocastData.fighter_changes)
    self:ParseSpecial()
    self:PlaySpecial()
    if self.brocastEndData ~= nil then
        if self.nextbrocastData == nil then
            if not self.islastRound then
                local endData = self.brocastEndData
                LuaTimer.Add(400, function () if not (self.controller.mainPanel == nil or self.controller.isdestroying) then self.controller:BeforeTurnBegin()   self.controller.mainPanel:OnBeginFighting(endData)  end end)
                self.brocastEndData = nil
            else
                LuaTimer.Add(1500, function () self.controller:EndOfCombat() end)
            end
        else
            self.controller:OnFighting(self.nextbrocastData)
            self.nextbrocastData = nil
        end
    end
    self.firstAction = nil
    LuaTimer.Add(600, function () self:FireBrocastEndEvent() end)

end

function BrocastContext:FindFighter(fighterId)
    -- if self.fighterDict[fighterId] == nil then
    --     local str = ""
    --     for k,v in pairs(self.fighterDict) do
    --         str = string.format("%s || %s",str ,string.format("%s_%s",k,v.fighterData.name))
    --     end
    --     Log.Error("FindFighterError"..str .. "\n" .. debug.traceback())
    -- end
    return self.fighterDict[fighterId]
end

function BrocastContext:FindFighterByUid(id, platform, zone_id)
    -- utils.dump(self.fighterDict,"aaaaaaa")
    if self.fighterDict ~= nil then
        for k,v in pairs(self.fighterDict) do
            if v.fighterData.rid == id and v.fighterData.platform == platform and v.fighterData.zone_id == zone_id then
                return v
            end
        end
    end
    return nil
end

function BrocastContext:FindFighterByMaster_id(master_id)
    if master_id == 0 then
        return nil
    end
    local temp = {}
    if self.fighterDict ~= nil then
        for k,v in pairs(self.fighterDict) do
            if v.fighterData.master_fid == master_id or v.fighterData.guard_fid == master_id then
                table.insert(temp, v)
                print(v.fighterData.id)
            end
        end
        return temp
    end
    return nil
end

function BrocastContext:IsSameGroup(selfid, targetid)
    local selfFig = self:FindFighter(selfid)
    local targetFig = self:FindFighter(targetid)
    if selfFig ~= nil and targetFig ~= nil then
        return (selfFig.fighterData.group == targetFig.fighterData.group)
    else
        return false
    end
end

function BrocastContext:FindFighterByName(name)
    if self.fighterDict ~= nil then
        for k,v in pairs(self.fighterDict) do
            if v.fighterData.name == name then
                return v
            end
        end
    end
end

function BrocastContext:ReleaseBuff()
    self.buffBroadData = nil
    self.syncBuffAction = nil
end

function BrocastContext:SetBuffBroadData(data)
    self.buffBroadData = data
end

function BrocastContext:ParseBuffBroad()
    self.syncBuffAction = SyncSupporter.New(self)
    local buffPlayList = self.buffBroadData.buff_play_list
    table.sort(buffPlayList, CombatUtil.SortBuffPlayData)
    local buffList = self.buffBroadData.buff_list
    for _, simpleData in ipairs(buffList) do
        local buffAction = BuffSimplePlayAction.New(self, simpleData)
        self.syncBuffAction:AddAction(buffAction)
    end

    for _, buffPlay in ipairs(buffPlayList) do
        local buffAction = BuffPlayAction.New(self, buffPlay)
        self.syncBuffAction:AddAction(buffAction)
    end

    local statusAction = ResetStatusAction.New(self, self.buffBroadData.fighter_status_list, true)
    self.syncBuffAction:AddEvent(CombatEventType.End, statusAction)
end

function BrocastContext:PlayBuffBroad()
    if self.syncBuffAction ~= nil then
        local action = self.syncBuffAction
        -- LuaTimer.Add(200, function()
            action:Play()
        -- end)
    end
    self.buffBroadData = nil
    self.syncBuffAction = nil
end

-- 特殊事件播报
function BrocastContext:ReleaseSpecial()
    self.specialData = nil
    self.syncSpecialAction = nil
end

function BrocastContext:SetSpecialData(data)
    self.specialData = data
end

function BrocastContext:ParseSpecial()
    self.syncSpecialAction = SyncSupporter.New(self)
    if self.specialData ~= nil then
        for _, data in ipairs(self.specialData) do
            self.syncSpecialAction:AddAction(CombatSpecialAction.New(self, data))
        end
    end
end

function BrocastContext:PlaySpecial()
    if self.syncSpecialAction ~= nil then
        self.syncSpecialAction:Play()
    end
    self.specialData = nil
    self.syncSpecialAction = nil
end

-- 保存10731数据
function BrocastContext:SetEndData(data)
    self.brocastEndData = data
end

function BrocastContext:SetNextBrocastData(data)
    if self.nextbrocastData == nil then
        self.nextbrocastData = data
    else
        -- self.combatMgr.RecorderSkip = false
        print("上回合播报出错跳过")
        self.combatMgr.isBrocasting = false
        self.nextbrocastData = nil
        self.controller:OnFighting(data)
    end
end

function BrocastContext:AddEndEvent(func)
    table.insert(self.OnBrocastEnd,func)
end

function BrocastContext:RemoveEvent(func)
    local index = nil
    for i,v in ipairs(self.OnBrocastEnd) do
        if func == v then
            index = i
        end
    end
    if index ~= nil then
        table.remove(self.OnBrocastEnd,index)
    end
end

function BrocastContext:FireBrocastEndEvent()
    for i,v in ipairs(self.OnBrocastEnd) do
        local status, err = xpcall(v, function(errinfo)
            Log.Error("FireBrocastEndEvent报错了 " .. tostring(errinfo)); Log.Error(debug.traceback())
        end)
        if not status then
            Log.Error("FireBrocastEndEvent报错了 " .. tostring(err))
        end

    end
    self.OnBrocastEnd = {}
end


function BrocastContext:ParseTalk()
    if self.controller.mainPanel == nil then
        local delay = DelayAction.New(self, 0)
        return delay
    end
    local round = self.controller.mainPanel.round
    local guide = 0
    if self.controller.mainPanel.lastSkillSelectData ~= nil then
        guide = self.controller.mainPanel.lastSkillSelectData.guide
    end
    if self.fighterDict ~= nil then
        local startTalk = SyncSupporter.New(self)
        local maxdelay = 0
        for k,fighter in pairs(self.fighterDict) do
            local data = self.combatMgr:GetNpcTalkData(fighter.fighterData.base_id, round, 1)
            for _,talkdata in pairs(data) do
                if talkdata.delay > maxdelay then
                    maxdelay = talkdata.delay
                end
                local delay = DelayAction.New(self, talkdata.delay)
                local talkAction = TalkBubbleAction.New(self, fighter.fighterData.id, talkdata.talk)
                delay:AddEvent(CombatEventType.End, talkAction)
                startTalk:AddAction(delay)
            end
        end
        local data = self.combatMgr:GetNpcTalkData(guide, round, 1)
        for _,talkdata in pairs(data) do
            if talkdata.delay > maxdelay then
                maxdelay = talkdata.delay
            end
            local delay = DelayAction.New(self, talkdata.delay)
            local talkAction = TalkBubbleAction.New(self, self.controller.selfData.id, talkdata.talk)
            delay:AddEvent(CombatEventType.End, talkAction)
            startTalk:AddAction(delay)
        end
        local delay = DelayAction.New(self, maxdelay)
        delay:AddEvent(CombatEventType.Start, startTalk)
        return delay
    end
end