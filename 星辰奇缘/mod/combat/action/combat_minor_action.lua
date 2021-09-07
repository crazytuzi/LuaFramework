-- 子播报
MinorAction = MinorAction or BaseClass(CombatBaseAction)

function MinorAction:__init(brocastCtx, majorCtx, pActionList, majorAct, lastMinor)
    -- print("============MinorAction:__init==================")
    -- BaseUtils.dump(pActionList,"子播报")
    self.brocastCtx.majorCtx = majorCtx
    self.majorCtx = majorCtx
    self.majorAct = majorAct
    self.lastMinor = lastMinor
    self.nextMinor = nil
    self.initActionList = pActionList
    self.actionList = {}
    self.waitpassiveList = {}
    self.firstAction = pActionList[1]
    self.firstAttacker = self:FindFighter(self.firstAction.self_id)
    self.firstDefence = self:FindFighter(self.firstAction.target_id)

    self.protectData = nil

    self.combatSkill = self.brocastCtx.combatMgr:GetCombatSkillObject(self.firstAction.skill_id, self.firstAction.skill_lev)

    -- 资源加载
    self.resourceLoader = AssetWrapperAction.New(brocastCtx, self, {})
    -- 记录替换资源的关系
    self.subpkgEffectDict = {}

    -- 触发时间段
    self.triggerStart = SyncSupporter.New(brocastCtx)
    self.triggerFollow = SyncSupporter.New(brocastCtx) -- 伴随攻击动作
    self.triggerHit= SyncSupporter.New(brocastCtx)
    self.triggerMultiHit = SyncSupporter.New(brocastCtx)
    self.triggerEnd = SyncSupporter.New(brocastCtx)
    self.triggerMoveEnd = SyncSupporter.New(brocastCtx)

    -- 解发子报名结束事件triggerEnd
    self.endTaperSupporter = TaperSupporter.New(brocastCtx)

    self.resourceLoader:AddEvent(CombatEventType.End, self.triggerStart)
end

function MinorAction:Parse()
    -- print(string.format("<color='#ffff00'>解析：%s --》 %s</color>", tostring(self.majorAct.order), tostring(self.initActionList[1].sub_order)))
    self.endTaperSupporter:AddEvent(CombatEventType.End, self.triggerEnd)
    local lastaData = nil
    local skillMotion = nil
    for _, aData in ipairs(self.initActionList) do
        if aData.action_type == 1 or aData.action_type == 9 then      -- 保护
            if self.protectData == nil then
                self.protectData = {}
            end
            table.insert(self.protectData, aData)
        elseif aData.action_type == 2 and #aData.show_passive_skills > 0 then  -- 待机被动
            table.insert(self.waitpassiveList, aData)
        elseif aData.action_type == 2 then  -- 待机
            local waiting = WaitingAction.New(self.brocastCtx, aData)
            self.triggerStart:AddEvent(CombatEventType.End, waiting)
            waiting:AddEvent(CombatEventType.End, self.endTaperSupporter)
        elseif aData.action_type == 3 then  -- 逃跑
            local escapeAction = EscapeAction.New(self.brocastCtx, self, aData)
            self.triggerStart:AddEvent(CombatEventType.End, escapeAction)
            escapeAction:AddTaperEvent(CombatEventType.End, self.endTaperSupporter)
        elseif aData.action_type == 4 then  -- 反射
            self.resourceLoader:AddResPath({"prefabs/effect/16148.unity3d"})
            local feedBackAction = FeedBackAction.New(self.brocastCtx, aData, self)
            self.triggerHit:AddAction(feedBackAction)
        elseif aData.action_type == 5 then  -- 捕宠
            local catchPetAct = CatchPetAction.New(self.brocastCtx, aData)
            self.triggerStart:AddAction(catchPetAct)
            catchPetAct:AddEvent(CombatEventType.End, self.endTaperSupporter)
        elseif aData.action_type == 6 then  -- 自杀
            local suicideAction = SuicideAction.New(self.brocastCtx, aData)
            suicideAction:AddEvent(CombatEventType.End, self.triggerHit)
            self.triggerStart:AddEvent(CombatEventType.End, suicideAction)
            suicideAction:AddEvent(CombatEventType.End, self.endTaperSupporter)
        elseif aData.action_type == 8 then  -- 召唤宠物
            local summonPet = SummonPetAction.New(self.brocastCtx, aData)
            self.triggerStart:AddAction(summonPet)
            summonPet:AddEvent(CombatEventType.Hit, self.triggerHit)
            summonPet:AddEvent(CombatEventType.End, self.endTaperSupporter)
        elseif aData.action_type == 11 then  -- 无动作变化
            local msgaction = CombatFloatMsgAction.New(self.brocastCtx, self, aData)
            self.triggerHit:AddAction(msgaction)

        -- elseif aData.action_type == 10 then  -- 系统消息
        --     local msg = MsgAction.New(self.brocastCtx, aData)
        --     self.triggerStart:AddAction(msg)
        --     msg:AddEvent(CombatEventType.End, self.endTaperSupporter)
        else
            if aData.action_type == 10 then  -- 系统消息
                local msg = MsgAction.New(self.brocastCtx, aData)
                self.triggerStart:AddAction(msg)
            elseif aData.action_type == 0 then
                for _,target_change in ipairs(aData.target_changes) do
                    if target_change.change_type == 15 then
                        table.insert(self.waitpassiveList, aData)
                        break
                    end
                end
            end
            -- msg:AddEvent(CombatEventType.End, self.endTaperSupporter)                                -- 攻击
            if skillMotion == nil then
                skillMotion = SkillMotionAction.New(self.brocastCtx, self.majorCtx, aData)
                self.firstAction = aData
                self.firstAttacker = self:FindFighter(aData.self_id)
                if self.firstAttacker == nil then
                    self.firstAttacker = FighterController.New()
                    self.firstAttacker.transform = self.brocastCtx.controller.MiddleEastPoint.transform
                end
                self.firstDefence = self:FindFighter(aData.target_id)
                self.combatSkill = self.brocastCtx.combatMgr:GetCombatSkillObject(aData.skill_id, aData.skill_lev)
            end
            -- if aData.skill_id == 60075 and lastaData ~= nil then
            --     aData.self_id = lastaData.target_id
            -- end
            lastaData = aData
            table.insert(self.actionList, aData)
        end
    end
    if skillMotion ~= nil then
        self:ParseSkill(skillMotion)
    else
        -- 一下为自杀播报加buff处理
        local buffresList = self.brocastCtx.combatMgr:GetBuffRes(self.brocastCtx.brocastData.buff_play_list)
        self.resourceLoader:AddResPath(buffresList)
        local handlerList = {
            -- MinorEffectHandler.New(self.brocastCtx, self, skillMotion)      -- 特效
            BuffBubBrocastHandler.New(self.brocastCtx, self, skillMotion)  -- buff播报
            ,AttrChangeHandler.New(self.brocastCtx, self, skillMotion)      -- 属性变化
        }
        for _, handler in ipairs(handlerList) do
            handler:Process(self)
        end
        -- 处理结束
        self.triggerEnd:AddEvent(CombatEventType.End, self.OnActionEnd, self)
    end
    self:DealSummonAction(self.initActionList)
    if self.initActionList[1].sub_order == 1 then
        self:AddTalkBubbleAction(self.initActionList)
    end
end

function MinorAction:ParseSkill(skillMotion)
    skillMotion:AddEvent(CombatEventType.Hit, self.triggerHit)
    skillMotion:AddEvent(CombatEventType.MultiHit, self.triggerMultiHit)
    skillMotion:AddTaperEvent(CombatEventType.End, self.endTaperSupporter)


    if DataCombatUtil.data_power_skill[self.firstAction.skill_id] ~= nil then
        self.triggerStart:AddAction(GradualAction.New(self.brocastCtx, true))
        self.triggerEnd:AddAction(GradualAction.New(self.brocastCtx, false))
    end

    local firstAction = self.firstAction
    -- 是否需要移动 近战 攻击
    if firstAction.attack_type == 0 and (firstAction.action_type == 0 or firstAction.action_type == 7) and not BaseUtils.isnull(self.firstDefence)then
        local targetPoint = self.firstDefence.transform.position
        if CombatUtil.SkillRange(self.combatSkill) == EffectRange.Group then
            targetPoint = self.firstDefence.regionalPoint.transform.position
        end
        if not self.majorCtx:IsMove(firstAction) then
            if firstAction.action_type ~= 7 then -- 反击
                if self.firstAction.skill_id == 60526 then -- 幽冥鬼步的特殊处理，移动前播放动作与特效，改移动为瞬移
                    local blink = BlinkAction.New(self.brocastCtx, firstAction, self, self.firstAttacker)
                    blink:AddEvent(CombatEventType.End, skillMotion)
                    blink:AddEvent(CombatEventType.End, self.triggerFollow)
                    blink:AddEvent(CombatEventType.End, self.triggerMoveEnd)
                    self.majorCtx:AddMoveAction(firstAction)
                    self.triggerStart:AddEvent(CombatEventType.End, blink)
                else
                    local move = MoveAction.New(self.brocastCtx, firstAction, MoveType.ToTarget)
                    if self.brocastCtx:IsSameGroup(firstAction.target_id, firstAction.self_id) then
                        local faceToAction = FaceToAction.New(self.brocastCtx, self.firstAttacker, targetPoint)
                        move:AddEvent(CombatEventType.End, faceToAction)
                    end
                    move:AddEvent(CombatEventType.End, skillMotion)
                    move:AddEvent(CombatEventType.End, self.triggerFollow)
                    move:AddEvent(CombatEventType.End, self.triggerMoveEnd)
                    self.majorCtx:AddMoveAction(firstAction)
                    self.triggerStart:AddEvent(CombatEventType.End, move)
                end
            else
                self.triggerStart:AddEvent(CombatEventType.End, skillMotion)
                self.triggerStart:AddEvent(CombatEventType.End, self.triggerFollow)
                self.triggerStart:AddEvent(CombatEventType.End, self.triggerMoveEnd)
            end
        else
            self.triggerStart:AddEvent(CombatEventType.End, skillMotion)
            self.triggerStart:AddEvent(CombatEventType.End, self.triggerFollow)
            self.triggerStart:AddEvent(CombatEventType.End, self.triggerMoveEnd)
        end
        if self.majorCtx:IsFinally(firstAction.sub_order, firstAction.self_id, self.nextMinor) then
            local moveBack = MoveAction.New(self.brocastCtx, firstAction, MoveType.ToSelf)
            self.triggerEnd:AddEvent(CombatEventType.End, moveBack)
        end
        if self.majorCtx:IsMove({self_id = firstAction.target_id, target_id = firstAction.self_id}, self, self.nextMinor)
            and firstAction.action_type == 7
            and firstAction.is_target_die ~= 1 then
            local moveBack = MoveAction.New(self.brocastCtx, firstAction, MoveType.TargetToSelf)
            self.triggerEnd:AddEvent(CombatEventType.End, moveBack)
            moveBack:AddEvent(CombatEventType.End, self.OnActionEnd, self)
        else
            self.triggerEnd:AddEvent(CombatEventType.End, self.OnActionEnd, self)
        end
    elseif not BaseUtils.isnull(self.firstDefence) then
        if firstAction.attack_type == 1 and (firstAction.action_type == 0 or firstAction.action_type == 7) and self.combatSkill.target_type == SkillTargetType.Enemy then
            local targetPoint = self.firstDefence.transform.position
            if CombatUtil.SkillRange(self.combatSkill) == EffectRange.Group then
                targetPoint = self.firstDefence.regionalPoint.transform.position
            end
            if firstAction.self_id ~= firstAction.target_id then
                local faceToAction = FaceToAction.New(self.brocastCtx, self.firstAttacker, targetPoint)
                self.triggerStart:AddAction(faceToAction)
            end
            if firstAction.action_type == 7
                and self.majorCtx:IsMove({self_id = firstAction.target_id, target_id = firstAction.self_id}, self, self.nextMinor)
                and firstAction.is_target_die ~= 1
            then
                local moveBack = MoveAction.New(self.brocastCtx, firstAction, MoveType.TargetToSelf)
                local faceToActionBack = FaceToAction.New(self.brocastCtx, self.firstDefence, self.firstDefence.originFaceToPos)
                local AtkfaceToActionBack = FaceToAction.New(self.brocastCtx, self.firstAttacker, self.firstAttacker.originFaceToPos)
                moveBack:AddEvent(CombatEventType.End, faceToActionBack)
                moveBack:AddEvent(CombatEventType.End, AtkfaceToActionBack)
                self.triggerEnd:AddEvent(CombatEventType.End, moveBack)
            else
                local delay = DelayAction.New(self.brocastCtx, 150)
                local faceToActionBack = FaceToAction.New(self.brocastCtx, self.firstAttacker, self.firstAttacker.originFaceToPos)
                delay:AddEvent(CombatEventType.End, faceToActionBack)
                -- self.triggerEnd:AddAction(faceToActionBack)
                self.triggerEnd:AddAction(delay)
            end
        end
        self.triggerStart:AddEvent(CombatEventType.End, skillMotion)
        self.triggerStart:AddEvent(CombatEventType.End, self.triggerFollow)
        self.triggerEnd:AddEvent(CombatEventType.End, self.OnActionEnd, self)
    else
        -- local errorStr = "找不到firstDefence跳过移动: Round: ".. tostring(self.brocastCtx.controller.mainPanel.round)
        -- if self.brocastCtx~= nil and self.brocastCtx.fighterDict~= nil then
        --     -- local num = 0
        --     -- for k,v in pairs(self.brocastCtx.fighterDict) do
        --     --     errorStr = string.format("%s || %s", errorStr, string.format("%s_%s",k,v.fighterData.name))
        --     -- end

        --     errorStr = string.format("%s || self_id = %s , target_id = %s", errorStr, tostring(self.firstAction.self_id), tostring(self.firstAction.target_id))
        -- end
        -- errorStr = string.format("%s || action_type = %s", errorStr, tostring(self.firstAction.action_type))
        -- Log.Error(errorStr)
        self.triggerStart:AddEvent(CombatEventType.End, self.OnActionEnd, self)
    end

    -- 喊招
    local shoutEffect = ShoutEffect.New(self.brocastCtx, self.firstAction)

    -- print("我要喊了！！！！！")
    -- BaseUtils.dump(self.firstAction)
    local succ = self.majorCtx:AddShoutEffect(self.firstAction.skill_id, self.firstAction.skill_lev)
    if succ then
        self.triggerStart:AddAction(shoutEffect)
    else
        shoutEffect:Recycle()
    end

    -- 处理被动技能
    for _, actionData in ipairs(self.actionList) do
        local pskillList = actionData.show_passive_skills
        local shoutIndex = { 0, 0, 0, 0 }

        for _, pskillData in ipairs(pskillList) do
            local pskillAction = CombatPassiveSkillAction.New(self.brocastCtx, pskillData, self, self.firstAttacker)
            shoutIndex[pskillData.show_type+1] = pskillAction:SetShoutIndex(shoutIndex[pskillData.show_type+1])
            if pskillData.show_type == 0 then
                self.triggerStart:AddAction(pskillAction)
            elseif pskillData.show_type == 1 then
                self.triggerHit:AddAction(pskillAction)
            elseif pskillData.show_type == 2 then
                self.triggerEnd:AddAction(pskillAction)
            elseif pskillData.show_type == 3 then
                self.triggerFollow:AddAction(pskillAction)
            end
        end
    end

    for _, actionData in ipairs(self.waitpassiveList) do
        local pskillList = actionData.show_passive_skills
        for _, data in ipairs(actionData.self_changes) do
            local action = AttrChangeEffect.New(self.brocastCtx, {data}, actionData.self_id, 0, 1, false)
            self.triggerHit:AddAction(action)
        end
        for _, data in ipairs(actionData.target_changes) do
            local action = AttrChangeEffect.New(self.brocastCtx, {data}, actionData.target_id, 0, 1, false)
            self.triggerHit:AddAction(action)
        end
        for _, pskillData in ipairs(pskillList) do
            local pskillAction = CombatPassiveSkillAction.New(self.brocastCtx, pskillData)
            if pskillData.show_type == 0 then
                self.triggerStart:AddAction(pskillAction)
            elseif pskillData.show_type == 1 then
                self.triggerHit:AddAction(pskillAction)
            elseif pskillData.show_type == 2 then
                self.triggerEnd:AddAction(pskillAction)
            elseif pskillData.show_type == 3 then
                self.triggerFollow:AddAction(pskillAction)
            end
        end
    end

    -- 处理技能特效

    local buffresList = self.brocastCtx.combatMgr:GetBuffRes(self.brocastCtx.brocastData.buff_play_list)
    self.resourceLoader:AddResPath(buffresList)

    local handlerList = {
        MinorEffectHandler.New(self.brocastCtx, self, skillMotion)      -- 特效
        ,BuffBubBrocastHandler.New(self.brocastCtx, self, skillMotion)  -- buff播报
        ,AttrChangeHandler.New(self.brocastCtx, self, skillMotion)      -- 属性变化
    }
    for _, handler in ipairs(handlerList) do
        handler:Process(self)
    end

    -- 漂血 攻击 辅助
    if self.combatSkill.type == 0 and self.combatSkill.sub_type == 2 then
        for _, actionData in ipairs(self.actionList) do
            local effect = EffectFactory.AttrChangeEffectByAction(self.brocastCtx, actionData, 1)
            skillMotion:AddEvent(CombatEventType.Hit, effect)
            for _, data in ipairs(actionData.self_changes) do
                if (data.change_type == 0 or data.change_type == 9) and data.change_val < 0 then
                    local action = AttrChangeEffect.New(self.brocastCtx, {data}, actionData.self_id, 0, 1, false)
                    self.triggerStart:AddAction(action)
                end
            end
        end
    end

    -- {"主动", 0}
    -- ,{"被动", 1}
    -- ,{"光环", 2}
    -----------------
    -- {"攻击", 0}
    -- ,{"防御", 1}
    -- ,{"辅助", 2}
    -- 漂血 被动 辅助
    if self.combatSkill.type == 1 and self.combatSkill.sub_type == 2 then
        for _, actionData in ipairs(self.actionList) do
            for _, data in ipairs(actionData.self_changes) do
                if data.change_type == 0 or data.change_type == 9 then
                    local action = AttrChangeEffect.New(self.brocastCtx, {data}, actionData.self_id, 0, 1, false)
                    skillMotion:AddEvent(CombatEventType.Hit, action)
                end
            end
            for _, data in ipairs(actionData.target_changes) do
                if data.change_type == 0 or data.change_type == 9 then
                    local action = AttrChangeEffect.New(self.brocastCtx, {data}, actionData.target_id, 0, 1, false)
                    skillMotion:AddEvent(CombatEventType.Hit, action)
                end
            end
        end
    end

    -- 自身损血 非辅助技能
    if self.combatSkill.type == 0 and self.combatSkill.sub_type ~= 2 then
        for _, actionData in ipairs(self.actionList) do
            for _, data in ipairs(actionData.self_changes) do
                if (data.change_type == 0 or data.change_type == 9) and data.change_val < 0 then
                    local action = AttrChangeEffect.New(self.brocastCtx, {data}, actionData.self_id, 0, 1, false)
                    self.triggerStart:AddAction(action)
                end
            end
        end
    end

    -- 职业技能 处理加怒气
    for _, actionData in ipairs(self.actionList) do
        for _, data in ipairs(actionData.self_changes) do
            if data.change_type == 9 and data.change_val > 0 then
                local classes = self:FindFighter(actionData.self_id).fighterData.classes
                local skill_id = self.combatSkill.id
                if classes ~= 0 then
                    local skill_id_list = DataSkill.data_skill_role_init[classes].skills

                    for _, skill in ipairs(skill_id_list) do
                        if skill == skill_id then
                            local action = AttrChangeEffect.New(self.brocastCtx, {data}, actionData.self_id, 0, 1, false)
                            self.triggerStart:AddAction(action)
                            break
                        end
                    end
                end
            end
        end
    end 

    -- 音效
    local motionId = self.majorCtx:GetMotionId(self.firstAction)
    local soundDataList = self.brocastCtx.combatMgr:GetSoundData(self.firstAction.skill_id, motionId)
    if soundDataList ~= nil then
        for _, soundData in ipairs(soundDataList) do
            if soundData.moment == 1 then
                self.triggerStart:AddAction(SoundAction.New(self.brocastCtx, soundData))
            elseif soundData.moment == 4 then
                self.triggerFollow:AddAction(SoundAction.New(self.brocastCtx, soundData))
            end
        end
    end
end

function MinorAction:AddTalkBubbleAction(actionList)
    local lasttalk = nil
    for _, actionData in ipairs(actionList) do
        if actionData.talk ~= nil and string.len(actionData.talk) > 0 then
            if lasttalk ~= actionData.talk then
                local fighterId = actionData.self_id
                local talkAction = TalkBubbleAction.New(self.brocastCtx, fighterId, actionData.talk)
                self.triggerStart:AddAction(talkAction)
                lasttalk = actionData.talk
            end
        end
    end
end

function MinorAction:DealSummonAction(actionList)
    local order = 0
    local subOrder = 0
    local summonPlayList = self.brocastCtx.brocastData.summon_play_list
    for _, actionData in ipairs(actionList) do
        order = actionData.order
        subOrder = actionData.sub_order
        for _, summonData in ipairs(summonPlayList) do
            if summonData.order == order and summonData.sub_order == subOrder then
                local lastSummon = nil
                for _, data in ipairs(summonData.summons) do
                    if summonData.summon_type == 2 then -- 兽灵大招类型召唤
                        self.triggerHit:AddAction(SummonAction.New(self.brocastCtx, data))
                    else
                        if actionData.action_type == 2 then
                            local delay
                            delay = DelayAction.New(self.brocastCtx, 150)
                            local summonaction = SummonAction.New(self.brocastCtx, data)
                            delay:AddEvent(CombatEventType.End, summonaction)
                            if lastSummon ~= nil then
                                lastSummon:AddEvent(CombatEventType.End, delay)
                            else
                                self.triggerStart:AddAction(delay)
                            end
                            lastSummon = summonaction
                        elseif actionData.action_type == 0 then
                            self.triggerStart:AddAction(SummonAction.New(self.brocastCtx, data))
                        else
                            self.triggerHit:AddAction(SummonAction.New(self.brocastCtx, data))
                        end
                    end
                end
                if lastSummon ~= nil then
                    lastSummon:AddEvent(CombatEventType.End, self.endTaperSupporter)
                    -- self.endTaperSupporter:AddEvent(CombatEventType.End, lastSummon)
                end
            end
        end
    end
end

function MinorAction:Play()
    -- -- print("================MinorAction:Play=============")
    -- self.time = Time.time
    -- print(string.format("<color='#00ff00'>播放：%s --》 %s</color>", tostring(self.majorAct.order), tostring(self.initActionList[1].sub_order)))
    if (self.initActionList[1].self_id == self.brocastCtx.controller.selfData.id or self.brocastCtx.controller.enterData.combat_type == 60) and self.initActionList[1].action_msg ~= "" and self.initActionList[1].action_type ~= 11 and self.initActionList[1].action_type ~= 10 then
        NoticeManager.Instance:FloatTipsByString(self.initActionList[1].action_msg)
    end
    self.brocastCtx.majorCtx = self.majorCtx
    self.resourceLoader:Play()
end

function MinorAction:OnActionEnd()
    -- -- print("================MinorAction:OnActionEnd=============")
    -- print(string.format("%s_%s--->  %s", tostring(self.firstAction.skill_id), "0", tostring((Time.time-self.time)*1000)))
    -- print(string.format("<color='#ff0000'>结束：%s --》 %s</color>", tostring(self.majorAct.order), tostring(self.initActionList[1].sub_order)))
    self:InvokeAndClear(CombatEventType.End)
    if self.assetwrapper ~= nil then
        --延迟卸载，以防资源没用完
        LuaTimer.Add(15000, function()
            self.assetwrapper:DeleteMe()
            self.assetwrapper = nil
            end)
    end
end
