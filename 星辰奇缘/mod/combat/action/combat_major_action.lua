-- 主播报
MajorAction = MajorAction or BaseClass(CombatBaseAction)

function MajorAction:__init(brocastCtx, majorData, lastid)
    self.order = majorData.order
    self.actionList = majorData.sub_action_list
    for _, data in ipairs(self.actionList) do
        data.order = self.order
    end
    self.firstAction = nil
    self:Parse()
    self.self_id = 1
    self.lastid = lastid
end

function MajorAction:Parse()
    self.brocastCtx.majorCtx = nil
    table.sort(self.actionList, CombatUtil.SortSubData)
    local majorCtx = MajorContext.New()
    local gList = self:GroupBySubOrder(self.actionList)
    local initList = {}
    local lastminor = nil
    majorCtx.groupList = gList
    for _, aList in ipairs(gList) do
        table.sort(aList, CombatUtil.SortSubListData)
        local minoraction = MinorAction.New(self.brocastCtx, majorCtx, aList, self, lastminor)
        if lastminor ~= nil then
            lastminor.nextMinor = minoraction
        end
        lastminor = minoraction
        table.insert(initList, minoraction)
    end
    self.self_id = self.actionList[1].self_id
    local lastAction = nil
    lastAction = self:ParseBeginTalk()
    self.firstAction = lastAction
    for _, action in ipairs(initList) do
        action:Parse()
        if (self.firstAction == nil) then
            self.firstAction = action
            lastAction = action
        else
            lastAction:AddEvent(CombatEventType.End, action)
            lastAction = action
        end
    end
    local endtalk = self:ParseEndTalk()
    endtalk:AddEvent(CombatEventType.End, self.OnActionEnd, self)
    lastAction:AddEvent(CombatEventType.End, endtalk)
end

-- sub_order相等的放在一组
function MajorAction:GroupBySubOrder(actionList)
    local gList = {}
    local subOrder = -1
    local iList = {}
    for _, data in ipairs(actionList) do
        if data.sub_order ~= subOrder then
            subOrder = data.sub_order
            iList = {data}
            table.insert(gList, iList)
        else
            table.insert(iList, data)
        end
    end
    return gList
end

function MajorAction:Play()
    -- print("=====MajorAction:Play============")
    if self.brocastCtx.combatMgr.RecorderSkip then
        self:OnActionEnd()
    else
        self.brocastCtx.majorCtx = nil
        self.firstAction:Play()
    end
end

function MajorAction:OnActionEnd()
    -- print("=====MajorAction:OnActionEnd============")
    self:InvokeAndClear(CombatEventType.End)
end


function MajorAction:ParseBeginTalk()
    if self.brocastCtx.controller.mainPanel == nil then
        local delay = DelayAction.New(self.brocastCtx, 0)
        return delay
    end
    local round = self.brocastCtx.controller.mainPanel.round
    local guide = 0
    if self.brocastCtx.controller.mainPanel.lastSkillSelectData ~= nil then
        guide = self.brocastCtx.controller.mainPanel.lastSkillSelectData.guide
    end
    if self.brocastCtx.fighterDict ~= nil and self.self_id ~= self.lastid then
        local startTalk = SyncSupporter.New(self.brocastCtx)
        local notalk = true
        local maxdelay = 1
        local fighter = self.brocastCtx.fighterDict[self.self_id]
        if fighter ~= nil then
            local data = self.brocastCtx.combatMgr:GetNpcTalkData(fighter.fighterData.base_id, round, 2)
            for _,talkdata in pairs(data) do
                if talkdata.delay > maxdelay then
                    maxdelay = talkdata.delay
                end
                local delay = DelayAction.New(self.brocastCtx, talkdata.delay)
                local talkAction = TalkBubbleAction.New(self.brocastCtx, fighter.fighterData.id, talkdata.talk)
                delay:AddEvent(CombatEventType.End, talkAction)
                startTalk:AddAction(delay)
                notalk = false
            end
        end
        if self.brocastCtx.controller.selfData.id == self.self_id and self.self_id ~= self.lastid then
            local data = self.brocastCtx.combatMgr:GetNpcTalkData(guide, round, 2)
            for _,talkdata in pairs(data) do
                if talkdata.delay > maxdelay then
                    maxdelay = talkdata.delay
                end
                local delay = DelayAction.New(self.brocastCtx, talkdata.delay)
                local talkAction = TalkBubbleAction.New(self.brocastCtx, self.brocastCtx.controller.selfData.id, talkdata.talk)
                delay:AddEvent(CombatEventType.End, talkAction)
                startTalk:AddAction(delay)
            end
        end
        local delay = DelayAction.New(self.brocastCtx, maxdelay)
        delay:AddEvent(CombatEventType.Start, startTalk)
        return delay
    end
end


function MajorAction:ParseEndTalk()
    if self.brocastCtx.controller.mainPanel == nil then
        local delay = DelayAction.New(self.brocastCtx, 0)
        return delay
    end
    local round = self.brocastCtx.controller.mainPanel.round
    local guide = 0
    if self.brocastCtx.controller.mainPanel.lastSkillSelectData ~= nil then
        guide = self.brocastCtx.controller.mainPanel.lastSkillSelectData.guide
    end
    if self.brocastCtx.fighterDict ~= nil and self.self_id ~= self.lastid then
        local startTalk = SyncSupporter.New(self.brocastCtx)
        local notalk = true
        local maxdelay = 1
        local fighter = self.brocastCtx.fighterDict[self.self_id]
        if fighter ~= nil then
            local data = self.brocastCtx.combatMgr:GetNpcTalkData(fighter.fighterData.base_id, round, 3)
            for _,talkdata in pairs(data) do
                if talkdata.delay > maxdelay then
                    maxdelay = talkdata.delay
                end
                local delay = DelayAction.New(self.brocastCtx, talkdata.delay)
                local talkAction = TalkBubbleAction.New(self.brocastCtx, fighter.fighterData.id, talkdata.talk)
                delay:AddEvent(CombatEventType.End, talkAction)
                startTalk:AddAction(delay)
                notalk = false
            end
        end
        if self.brocastCtx.controller.selfData.id == self.self_id and self.self_id ~= self.lastid then
            local data = self.brocastCtx.combatMgr:GetNpcTalkData(guide, round, 3)
            for _,talkdata in pairs(data) do
                if talkdata.delay > maxdelay then
                    maxdelay = talkdata.delay
                end
                local delay = DelayAction.New(self.brocastCtx, talkdata.delay)
                local talkAction = TalkBubbleAction.New(self.brocastCtx, self.brocastCtx.controller.selfData.id, talkdata.talk)
                delay:AddEvent(CombatEventType.End, talkAction)
                startTalk:AddAction(delay)
            end
        end
        local delay = DelayAction.New(self.brocastCtx, maxdelay)
        delay:AddEvent(CombatEventType.Start, startTalk)
        return delay
    end
end


---------------------------------------------------------------------
-- MajorContext
---------------------------------------------------------------------
MajorContext = MajorContext or BaseClass()
function MajorContext:__init()
    self.moveList = {}
    -- {{actionData, ...}, ...}
    self.groupList = {}
    self.shoutEffectList = {}
    self.assetwrapper = nil
end

function MajorContext:AddMoveAction(data)
    table.insert(self.moveList, data)
end

function MajorContext:AddShoutEffect(skillId, skillLev)
    local key = CombatUtil.Key(skillId, skillLev)
    if self.shoutEffectList[key] ~= nil then
        return false
    else
        self.shoutEffectList[key] = true
        return true
    end
end

function MajorContext:IsMove(data, currminor, nextMinor)
    if currminor ~= nil and currminor.firstAction.sub_order ~= 1 and nextMinor ~= nil and nextMinor.firstAction.attack_type ~= 3 then
        return false
    end
    for _, actionData in ipairs(self.moveList) do
        if data.self_id == actionData.self_id and data.target_id == actionData.target_id then
            return true
        end
    end
    return false
end

function MajorContext:IsFinally(subOrder, attackId, nextMinor)
    if nextMinor ~= nil and nextMinor.firstAction.self_id ~= nextMinor.firstAction.target_id then
        if nextMinor.firstAction.self_id == attackId then
            return false    
        end
    end
    for _, aList in ipairs(self.groupList) do
        -- local data = aList[1]
        for _,data in ipairs(aList) do
            if data.sub_order > subOrder and (data.self_id == attackId or (data.action_type == 7 and data.target_id == attackId)) then
                return false
            end
        end
    end
    return true
end

function MajorContext:GetMotionId(actionData)
    local combatSkillObj = CombatManager.Instance:GetCombatSkillObject(actionData.skill_id, actionData.skill_lev)
    if combatSkillObj == nil then
        return 0
    end
    local motionIdList = combatSkillObj.motion_id
    if #motionIdList < 0 then
        return 0
    elseif #motionIdList == 1 then
        return 0
    else
        local index = 1
        local find = false
        for _, aList in ipairs(self.groupList) do
            for _, data in ipairs(aList) do
                if data.self_id == actionData.self_id and data.skill_id == actionData.skill_id then
                    index = index + 1
                    if data.sub_order == actionData.sub_order then
                        find = true
                        break
                    end
                end
            end
            if find then
                break
            end
        end
        if #motionIdList >= index then
            return motionIdList[index - 1]
        elseif #motionIdList < index then
            return motionIdList[#motionIdList]
        else
            return motionIdList[1]
        end
    end
end

function MajorContext:releaseRes()
    self.assetwrapper:DeleteMe()
end
