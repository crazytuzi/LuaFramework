-- 战斗单元控制器
FighterController = FighterController or BaseClass(BaseMonoBehaviour)

-- 战斗位置控制器
function FighterController:__init()

    self.combatMgr = CombatManager.Instance
    self.controller = self.combatMgr.controller
    self.combatCamera = self.controller.combatCamera

    self.transform = nil
    self.tpose = nil
    self.animator = nil
    self.listener = AnimatorListener.New(self)

    self.headTpose = nil
    self.headAnimator = nil
    self.headAnimationData = nil

    self.fighterData = nil
    self.animationData = nil
    self.layout = FighterLayout.EAST

    self.speed = 0.327
    self.stepQueue = {}
    self.stepUIQueue = {}
    self.IsMove = false
    self.isshake = false

    -- hitmove
    self.stepHitQueue = {}
    self.IsHitMove = false
    self.IsDisappear = false

    -- 动作事件计数器
    self.motionIndex = 1
    self.moveIndex = 1

    -- Vector3
    self.originPos = nil
    self.originFaceToPos = nil
    -- GameObject
    self.regionalPoint = nil

    -- Vector3
    self.selfWorldScreenPoint = nil
    self.isScreenPointChange = true

    -- weapon
    self.weaponList = {}

    self.OnPointerDown = function(eventData)
        self:__OnPointerDown(eventData)
    end
    self.OnPointerUp = function(eventData)
        self:__OnPointerUp(eventData)
    end

    -- UI
    self.mainPanel = nil
    self.hpBarPanel = nil
    self.offsetName = 0
    self.offsetHp = 0
    self.orderText = nil
    self.bloodImage = nil
    self.bloodYellow = nil
    self.nameText = nil
    self.namePanel = nil
    self.fnameText = nil
    self.fnameTextShadow = nil
    self.hpBarPanelBuffOffset = 0
    self.bubblePanel = nil
    self.lastbubblePanel = nil
    self.shadow = nil
    self.preparingImage = nil
    self.ShowBlood = true
    self.AttrFlyDic = {}
    self.ShoutFlyDic = {}

    self.originHpPosi = nil

    -- buff
    self.buffCtrl = FighterBuffController.New(self)

    self.downTime = 0
    self.isdown = false
    self.PointerClickEvent = {}
    self.PointerHoldEvent = {}

    -- 变身
    self.originTpose = nil
    self.originAnimationData = nil
    self.tranNpcId = 0

    -- 当前动作
    self.currAction = 0
    self.alpha = 1
    self.color = nil

    self.modelId = 0
    self.defaultScale = nil

    self.maxy = self:FixedMaxY()
end

function FighterController:__delete()
    if self.isSummon and self.fighterData.type ~= 1 and self.fighterData.type ~= 4 then
        if not BaseUtils.isnull(self.tpose) then
            GameObject.Destroy(self.tpose.gameObject)
        end
        if not BaseUtils.isnull(self.hpBarPanel) then
            GameObject.Destroy(self.hpBarPanel.gameObject)
        end
        self.listener = nil
        self.buffCtrl = nil
    end
    if self.bloodtween1 ~= nil then
        Tween.Instance:Cancel(self.bloodtween1)
        self.bloodtween1 = nil
    end
    if self.bloodtween2 ~= nil then
        Tween.Instance:Cancel(self.bloodtween2)
        self.bloodtween2 = nil
    end
    if self.shaker ~= nil then
        Tween.Instance:Cancel(self.shaker.id)
        self.shaker = nil
    end
    if self.bubbletween ~= nil then
        Tween.Instance:Cancel(self.bubbletween)
        self.bubbletween = nil
    end
end
function FighterController:AfterInit(transform)
    self.transform = transform
    self.originPos = self.transform.position
    self.tpose = transform:FindChild("tpose")
    self.originTpose = self.tpose

    self.fnameText = transform:Find("RoleName").gameObject
    self.fnameTextShadow = transform:Find("RoleNameShadow").gameObject

    self.shadow = transform:Find("Shadow").gameObject
    self.shadow.transform.position = self.shadow.transform.position + self.combatCamera.transform.forward*20
    -- 新增了地面遮罩特效类型，导致阴影需要调整层次
    Utils.ChangeLayersRecursively(self.shadow.transform, "TransparentFX")

    self.animator = self.tpose.gameObject:GetComponent(Animator)
    self.animator.cullingMode = AnimatorCullingMode.AlwaysAnimate
end
function FighterController:Start()
    self.originPos = self.transform.position
    self:PlayAction(FighterAction.BattleStand)
end

local Vector3 = UnityEngine.Vector3
function FighterController:FixedUpdate()
    if self.IsMove then
        -- print("IsMove")
        local friction = (Time.time - self.movestarttime)/self.moveduration
        local currposi = Vector3.Lerp(self.movestartpos ,self.movetargetpos, friction)
        if friction <= 1 then
            local position = currposi
            self:SetHpBarPanelPosition()
            -- self.namePanel.transform.localPosition = Vector3(position.x, position.y + self.offsetName, position.z)
        end

        if friction <= 1 then
            self.transform.position = currposi
            self.isScreenPointChange = true
        else
            self.transform.position = self.movetargetpos
            self:SetHpBarPanelPosition()
            self.isScreenPointChange = true
            -- self:GetScreenPoint()
            self.IsMove = false
            self:PlayAction(FighterAction.BattleStand)
            self:OnMoveEnd()
        end
    elseif self.IsHitMove then
        -- print("IsHitMove")
        if #self.stepHitQueue > 0 then
            local pos = self.stepHitQueue[1]
            -- if #self.stepHitQueue%2 == 0 and #self.stepHitQueue ~= 10 then
            --     self.tpose.localPosition = self.tpose.localPosition + self.tpose.forward*-0.15
            -- elseif #self.stepHitQueue%2 ~= 0 and #self.stepHitQueue ~= 1 then
            --     self.tpose.localPosition = self.tpose.localPosition + self.tpose.forward*0.15
            -- elseif #self.stepHitQueue%2 == 0 and #self.stepHitQueue == 10 then
            --     self.tpose.localPosition = self.tpose.localPosition + self.tpose.forward*-0.075
            -- elseif #self.stepHitQueue%2 ~= 0 and #self.stepHitQueue == 1 then
            --     self.tpose.localPosition = self.tpose.localPosition + self.tpose.forward*0.075
            -- else
                if #self.stepHitQueue < 6 then
                self.tpose.localPosition = self.tpose.localPosition + self.tpose.forward*-0.03
            else
                self.tpose.localPosition = self.tpose.localPosition + self.tpose.forward*0.03
            end
            table.remove(self.stepHitQueue, 1)
        else
            self.tpose.localPosition = Vector3.zero
            self.IsHitMove = false
            self.stepHitQueue = {}
        end
    end
end

function FighterController:__OnPointerDown(eventData)
    self.downTime = Time.time
    self.isdown = true
    local pos = CombatUtil.WorldToUIPoint(self.controller.combatCamera, self.transform.position)
    pos = Vector3(pos.x, pos.y+150,pos.z)
    LuaTimer.Add(440, function () self:OnPointerHold() end)
    LuaTimer.Add(100, function () if self.isdown then self.mainPanel.mixPanel:ShowHoldEffect(pos) end end)


end

function FighterController:__OnPointerUp(eventData)
    self.isdown = false
    local time = Time.time
    local offset = time - self.downTime
    if offset < 0.4 then
        for _, event in ipairs(self.PointerClickEvent) do
            event(self.fighterData)
        end
    end
    self.mainPanel.mixPanel:HidHoldEffect()
    self.downTime = 0
end

function FighterController:OnPointerHold()
    local time = Time.time
    local offset = time - self.downTime
    if self.downTime ~= 0 and offset >= 0.37 then
        for _, event in ipairs(self.PointerHoldEvent) do
            event(self.fighterData)
        end
    end
    self.downTime = 0
end

function FighterController:InitHeadInfo()
    self.headAnimator = self.headTpose.transform:GetComponent(Animator)
    self.headAnimator.cullingMode = AnimatorCullingMode.AlwaysAnimate
end

-- 初始化动作数据，usePack == true代表使用替代资源
function FighterController:InitAnimationData(usePack)
    if usePack then
        if self.fighterData.type == FighterType.Role or self.fighterData.type == FighterType.Cloner then
            self.animationData = DataAnimation.data_role_data[BaseUtils.Key(self.fighterData.classes, self.fighterData.sex)]
            if self.controller.enterData.combat_type == 52 then
                --打雪球模式动作都是魔道的
                self.animationData = DataAnimation.data_role_data[BaseUtils.Key(5, self.fighterData.sex)]
            end
        elseif self.fighterData.type == FighterType.Guard then
            self.animationData = DataAnimation.data_npc_data[1100201]
        else
            self.animationData = DataAnimation.data_npc_data[3000101]
        end
    else
        if self.fighterData.type == FighterType.Role or self.fighterData.type == FighterType.Cloner then
            self.animationData = DataAnimation.data_role_data[BaseUtils.Key(self.fighterData.classes, self.fighterData.sex)]
            if self.controller.enterData.combat_type == 52 then
                --打雪球模式动作都是魔道的
                self.animationData = DataAnimation.data_role_data[BaseUtils.Key(5, self.fighterData.sex)]
            end
        elseif self.fighterData.type == FighterType.Unit then
            local npcData = self.combatMgr:GetNpcBaseData(self.fighterData.base_id)
            self.animationData = DataAnimation.data_npc_data[npcData.animation_id]
        elseif self.fighterData.type == FighterType.Pet then
            local petData = self.combatMgr:GetPetBaseData(self.fighterData.base_id)
            self.animationData = DataAnimation.data_npc_data[petData.animation_id]
        elseif self.fighterData.type == FighterType.Child then
            local petData = self.combatMgr:GetChildBaseData(self.fighterData.base_id)
            self.animationData = DataAnimation.data_npc_data[petData.animation_id]

            for k, v in ipairs(self.fighterData.looks) do
                if v.looks_type == SceneConstData.looktype_child_animation then
                    self.animationData = self.combatMgr:GetAnimationData(v.looks_val)
                end
            end
        elseif self.fighterData.type == FighterType.Guard then
            local guardData = self.combatMgr:GetGuardBaseData(self.fighterData.base_id)
            if self.modelId ~= 0 and self:GetModelId() ~= self.modelId then
                guardData = self.combatMgr:GetGuardBaseData(1002)
            end
            self.animationData = DataAnimation.data_npc_data[guardData.animation_id]
            for k, v in ipairs(self.fighterData.looks) do
                if v.looks_type == 71 then
                    self.animationData = self.combatMgr:GetAnimationData(v.looks_mode)
                end
            end
        end
    end
    self.originAnimationData = self.animationData

    -- headAnimationData
    if self.fighterData.type == FighterType.Role or self.fighterData.type == FighterType.Cloner then
        local looksVal = 0
        for k, v in ipairs(self.fighterData.looks) do
            if v.looks_type == SceneConstData.looktype_hair then
                looksVal = v.looks_val
                break
            end
        end
        if looksVal == 0 then
            looksVal = BaseUtils.default_head(self.fighterData.classes, self.fighterData.sex);
        end
        if looksVal ~= 0 then
            local headData = DataFashion.data_base[looksVal]
            -- 不要头部动作了，只分男女
            -- self.headAnimationData = DataAnimation.data_role_head_data[headData.animation_id]
            self.headAnimationData = DataAnimation.data_role_head_data[self.fighterData.sex]
        end
    end
    LuaTimer.Add(1000, function ()
        if self.fighterData.is_die == 1 then
            self:PlayAction(FighterAction.Dead)
            self:HideBloodBar()
            self:SetAlpha(0.5)
            self:HideWing()
            if self.fighterData.is_die_disappear == 1 then
                self:SetDisappear(true)
            end
        end
    end)
end

function FighterController:NextMotionIndex()
    self.motionIndex = self.motionIndex + 1
    return self.motionIndex
end
function FighterController:GetMotionIndex()
    return "Skill_" .. self.motionIndex
end

function FighterController:NextMoveIndex()
    self.moveIndex = self.moveIndex + 1
    return self.moveIndex
end
function FighterController:GetMoveIndex()
    return "Move_" .. self.moveIndex
end


function FighterController:PlayAction(action)
    if self.IsDisappear then
        self:ShowBloodBar()
        self:ShowNameText()
        self:SetDisappear(false)
        self:ShowShadow(true)
        CombatUtil.SetMesh(self.tpose, true)
        self.transform.position = self.originPos
        self.transform.gameObject:SetActive(true)
    end
    if self.currAction == FighterAction.Dead and (action == FighterAction.BattleMove or action == FighterAction.Move or action == FighterAction.BattleStand or action == FighterAction.Stand) then
        return
    end
    if BaseUtils.is_null(self.animator) then
        print("单位模型未加载完成")
        return
    end
    if (self.fighterData.type == FighterType.Role or self.fighterData.type == FighterType.Cloner )and self.tranNpcId == 0 then
        self:RolePlayAction(action)
    else
        self:NpcPlayAction(action)
    end
end

function FighterController:RolePlayAction(action)
    self.currAction = action
    if BaseUtils.is_null(self.animator) then return end
    if action == FighterAction.BattleMove then
        self.animator:Play("Move" .. self.animationData.battlemove_id)
        self.headAnimator:Play(self.headAnimationData.battlemove_id)
    elseif action == FighterAction.Move then
        self.animator:Play("Move" .. self.animationData.move_id)
        self.headAnimator:Play(self.headAnimationData.move_id)
    elseif action == FighterAction.BattleStand then
        self.animator:Play("Stand" .. self.animationData.battlestand_id)
        self.headAnimator:Play(self.headAnimationData.battlestand_id)
        self:SetHpBarPanelPosition()
    elseif action == FighterAction.Stand then
        self.animator:Play("Stand" .. self.animationData.stand_id)
        self.headAnimator:Play(self.headAnimationData.stand_id)
        self:SetHpBarPanelPosition()
    elseif action == FighterAction.Hit then
        self.animator:Play("Hit" .. self.animationData.hit_id)
        self.headAnimator:Play(self.headAnimationData.hit_id)
    elseif action == FighterAction.Dead then
        self.animator:Play("Dead" .. self.animationData.dead_id)
        self.headAnimator:Play(self.headAnimationData.dead_id)
    elseif action == FighterAction.MultiHit then
        self.animator:Play("Hit" .. self.animationData.hit_id)
        self.headAnimator:Play(self.headAnimationData.hit_id)
    elseif action == FighterAction.Upthrow then
        self.animator:Play("Upthrow" .. self.animationData.upthrow_id)
        self.headAnimator:Play(self.headAnimationData.upthrow_id)
    elseif action == FighterAction.Standup then
        self.animator:Play("Standup" .. self.animationData.standup_id)
        self.headAnimator:Play(self.headAnimationData.standup_id)
    elseif action == FighterAction.Defense then
        self.animator:Play("Defense" .. self.animationData.defense_id)
        self.headAnimator:Play(self.headAnimationData.defense_id)
    else
        self.animator:Play("Idle" .. self.animationData.idle_id)
        self.headAnimator:Play(self.headAnimationData.idle_id)
    end
end

function FighterController:NpcPlayAction(action)
    self.currAction = action
    if BaseUtils.is_null(self.animator) then return end
    if action == FighterAction.BattleMove then
        self.animator:Play("Move" .. self.animationData.move_id)
    elseif action == FighterAction.Move then
        self.animator:Play("Move" .. self.animationData.move_id)
    elseif action == FighterAction.BattleStand then
        self.animator:Play("Stand" .. self.animationData.stand_id)
        self:SetHpBarPanelPosition()
    elseif action == FighterAction.Stand then
        self.animator:Play("Stand" .. self.animationData.stand_id)
        self:SetHpBarPanelPosition()
    elseif action == FighterAction.Hit then
        self.animator:Play("Hit" .. self.animationData.hit_id)
    elseif action == FighterAction.Dead then
        self.animator:Play("Dead" .. self.animationData.dead_id)
    elseif action == FighterAction.MultiHit then
        self.animator:Play("Hit" .. self.animationData.hit_id)
    elseif action == FighterAction.Upthrow then
        self.animator:Play("Upthrow" .. self.animationData.upthrow_id)
    elseif action == FighterAction.Standup then
        self.animator:Play("Standup" .. self.animationData.standup_id)
    elseif action == FighterAction.Defense then
        self.animator:Play("Defense" .. self.animationData.defense_id)
    else
        self.animator:Play("Idle" .. self.animationData.idle_id)
    end
end

function FighterController:PlaySkill(motionId, eventList, speed, skill_id)
    if BaseUtils.IsVerify then
        if self.fighterData.type ~= FighterType.Pet then
            if self.fighterData.classes == 1 then
                motionId = 10010
            elseif self.fighterData.classes == 2 then
                motionId = 20010
            elseif self.fighterData.classes == 3 then
                motionId = 30010
            elseif self.fighterData.classes == 4 then
                motionId = 40010
            elseif self.fighterData.classes == 5 then
                motionId = 50011
            elseif self.fighterData.classes == 6 then
                motionId = 60020
            elseif self.fighterData.classes == 7 then
                motionId = 70010
            end
        end
    end

    if eventList ~= nil and #eventList > 0 then
        self:NextMotionIndex()
        for _, event in ipairs(eventList) do
            self.listener:AddListener(event.eventType, self:GetMotionIndex(), event.func, event.owner)
        end
    end
    if not BaseUtils.isnull(self.animator) then
        if motionId == 1000 and self.fighterData.type == FighterType.Unit and self.tranNpcId == 0 then
            local tempID = self:GetNormalAttactMotionID()
            if tempID ~= nil then
                motionId = tempID
                self.animator:Play(tostring(tempID))
            else
                Log.Error(string.format("未能找到嘲讽普通攻击动作ID：单位ID%s", tostring(self.fighterData.base_id)))
            end
        elseif self.tranNpcId ~= 0 --[[and motionId == 1000 ]]then
            local tempID = self:GetTransformerNormalAttactMotionID(motionId)
            if tempID ~= nil then
                motionId = tempID
                self.animator:Play(tostring(tempID))
            else
                Log.Error(string.format("未能找到变身攻击动作ID：单位ID%s", tostring(self.fighterData.base_id)))
            end
        elseif motionId == 1000 then
            local tempID = self:GetNormalAttactMotionID()
            motionId = tempID
            self.animator:Play(tostring(tempID))
        else
            if self.modelId ~= 0 and self:GetModelId() ~= self.modelId and self.fighterData.type == FighterType.Guard then
                motionId = 61005
            end
            self.animator:Play(tostring(motionId))
        end
    else
        return
    end
    if self.fighterData.type == FighterType.Role or self.fighterData.type == FighterType.Cloner then
        local skill_motion = self.animationData.skill_motion
        if skill_motion ~= nil then
            for k, v in ipairs(skill_motion) do
                if k == motionId then
                    self.headAnimator:Play(v)
                    break
                end
            end
        end
    end
    self:RegisterEvent(motionId, speed, skill_id)
end

function FighterController:RegisterEvent(motionId, speed, skill_id)
    local modelId = self:GetModelId()
    local eventData = nil
    local playSpeed = 1
    local soundId = 0
    if speed ~= nil then
        playSpeed = speed
    end
    if self.modelId ~= 0 and self:GetModelId() ~= self.modelId and self.fighterData.type == FighterType.Guard then
        eventData = self.combatMgr:GetMotionEventData(61005, 11002)
    else
        eventData = self.combatMgr:GetMotionEventData(motionId, modelId)
    end
    if eventData == nil then
        eventData = self.combatMgr:GetMotionEventData(motionId, 0)
        Log.Error(string.format("[%s]添加技能动作事件出错,缺少key数据相关信息。motionId:%s, modelId:%s, skillId:%s", self.fighterData.name, motionId, modelId, skill_id))
    end
    if eventData ~= nil then
        self.animator.speed = playSpeed
        LuaTimer.Add(20, function () if self.controller == nil or self.listener == nil then return end self.listener.OnStart(self.listener) end)
        LuaTimer.Add(eventData.hit_time/playSpeed, function () if self.controller == nil or self.listener == nil then return end self.listener.OnHit(self.listener) end)
        LuaTimer.Add(eventData.multi_time/playSpeed, function () if self.controller == nil or self.listener == nil then return end self.listener.OnMultiHit(self.listener) end)
        LuaTimer.Add(eventData.total/playSpeed, function () if not BaseUtils.isnull(self.animator) then self.animator.speed = 1 end if self.controller == nil or self.listener == nil then return end self.listener.OnEnd(self.listener) end)
        if self.fighterData.type == FighterType.Guard and self:PlayGuardSound(skill_id)then
        elseif modelId == 0 and next(eventData.soundcfg)~=nil then
            if self.fighterData.sex == 0 then
                soundId = eventData.soundcfg[1].sound_id1
            else
                soundId = eventData.soundcfg[1].sound_id0
            end
        elseif next(eventData.soundcfg)~=nil then
            soundId = eventData.soundcfg[1].sound_id0
        end
        if soundId ~= 0 and soundId ~= nil then SoundManager.Instance:PlayCombatHiter(soundId)end
    else
        LuaTimer.Add(20, function () if self.controller == nil then return end self.listener.OnStart(self.listener) end)
        LuaTimer.Add(500, function () if self.controller == nil then return end self.listener.OnHit(self.listener) end)
        LuaTimer.Add(500, function () if self.controller == nil then return end self.listener.OnMultiHit(self.listener) end)
        LuaTimer.Add(1000, function () if self.controller == nil then return end self.listener.OnEnd(self.listener) end)
    end
end

function FighterController:FaceTo(point)
    if BaseUtils.isnull(self.tpose) then
        return
    end
    local x = self.tpose.position.x - point.x
    local z = self.tpose.position.z - point.z
    local angle = math.atan2(x, z) * 180 / math.pi
    self.tpose.rotation = Quaternion.identity
    self.tpose:Rotate(Vector3(0, angle, 0))
end

function FighterController:GoTo(point)
    self.isScreenPointChange = true
    self.transform.position = point
    -- self:UpdateHpBar()
    self:ReLocaHpBar()
end

function FighterController:MoveTo(point, mlist)
    if mlist ~= nil and #mlist > 0 then
        self:NextMoveIndex()
        for _, event in ipairs(mlist) do
            self.listener:AddListener(event.eventType, self:GetMoveIndex(), event.func, event.owner)
        end
        self:MoveToXYZ(point.x, point.y, point.z)
    end
end


function FighterController:MoveToXYZ(tx, ty, tz) -- 改写战斗单位移动方式
    if BaseUtils.isnull(self.transform) then
        return
    end
    self.isScreenPointChange = true
    local transf = self.transform

    self.movetargetpos = Vector3(tx, ty, tz)
    local dista =  CombatUtil.Distance(self.transform.position.x, self.transform.position.z, tx, tz)
    self.moveduration = dista / (self.speed*40)
    self.movestarttime = Time.time
    self.movestartpos = self.transform.position

    self.IsMove = true
    -- self.starmovtime = Time.time
    self:PlayAction(FighterAction.BattleMove)
end

function FighterController:BlinkTo(point, mlist) -- 闪烁移动、瞬移
    if mlist ~= nil and #mlist > 0 then
        self:NextMoveIndex()
        for _, event in ipairs(mlist) do
            self.listener:AddListener(event.eventType, self:GetMoveIndex(), event.func, event.owner)
        end
        self:BlinkToXYZ(point.x, point.y, point.z)
    end
end


function FighterController:BlinkToXYZ(tx, ty, tz) -- 改写战斗单位移动方式 -- 闪烁移动、瞬移
    if BaseUtils.isnull(self.transform) then
        return
    end
    self.isScreenPointChange = true
    local transf = self.transform

    self.movetargetpos = Vector3(tx, ty, tz)
    local dista =  CombatUtil.Distance(self.transform.position.x, self.transform.position.z, tx, tz)
    self.moveduration = dista / 10000
    self.movestarttime = Time.time
    self.movestartpos = self.transform.position

    self.IsMove = true
    -- self.starmovtime = Time.time
    self:PlayAction(FighterAction.BattleMove)
end

function FighterController:ReSetStepUIQueue(tx, tz, seed)
    local dx
    local dy

    self.stepUIQueue = {}

    local selfPosition = self.transform.position
    local srcPosition = CombatUtil.WorldToUIPoint(self.combatCamera, selfPosition)
    local targetPosition = CombatUtil.WorldToUIPoint(self.combatCamera, Vector3(tx, selfPosition.y, tz))

    local distX = (targetPosition.x - srcPosition.x) / seed
    local distY = (targetPosition.y - srcPosition.y) / seed

    for i = 1, seed do
        dx = distX * i
        dy = distY * i

        if i == seed then
            table.insert(self.stepUIQueue, Vector3(targetPosition.x, targetPosition.y, targetPosition.z))
        else
            table.insert(self.stepUIQueue, Vector3(srcPosition.x + dx, srcPosition.y + dy, srcPosition.z))
        end
    end

end

function FighterController:OnMoveEnd()
    -- print("移动停止 "..tostring(Time.time - self.starmovtime))
    self.listener:OnMoveEnd()
end

function FighterController:SetSkillShoutPosition(panel)
    if BaseUtils.isnull(panel) or BaseUtils.isnull(self.hpBarPanel) then
        return
    end
    self.isScreenPointChange = true
    -- local position = self:GetScreenPoint()
    -- if position == nil then
    --     return
    -- end
    -- local old = panel.transform.localPosition
    -- panel.transform.localPosition = Vector3(position.x, position.y + self.offsetHp + 30, 0)
    -- if self.ShoutFlyDic[Time.time] == nil then
    --     self.ShoutFlyDic[Time.time] = 0
    -- else
    --     self.ShoutFlyDic[Time.time] = self.ShoutFlyDic[Time.time] + 1
    -- end
    local pos = self.hpBarPanel.transform.localPosition + Vector3(0, 20, 0)
    local max = 270 - panel.transform.sizeDelta.y/2
    if pos.y > max then
        pos = Vector3(pos.x, max, pos.y)
    end
    panel.transform.localPosition = pos
end


function FighterController:SetTopPosition(panel, offset, notmov)
    if BaseUtils.isnull(panel) or BaseUtils.isnull(self.hpBarPanel) then
        return
    end
    self.isScreenPointChange = true

    if self.AttrFlyDic[Time.time] == nil then
        self.AttrFlyDic[Time.time] = 0
    elseif not notmov then
        self.AttrFlyDic[Time.time] = self.AttrFlyDic[Time.time] + 1
    end
    local pos = self.hpBarPanel.transform.localPosition + Vector3(0, 20, 0) + Vector3(20, 26, 0)*self.AttrFlyDic[Time.time]
    local max = 270 - panel.transform.sizeDelta.y/2
    if pos.y > max then
        pos = Vector3(pos.x, max, pos.y)
    end
    panel.transform.localPosition = pos
end

function FighterController:SetTopPosition2(panel, offset, offset2)
    if BaseUtils.isnull(panel) or BaseUtils.isnull(self.hpBarPanel) then
        return
    end
    self.isScreenPointChange = true
    -- local position = self:GetScreenPoint()
    -- local old = panel.transform.localPosition
    -- local finalY = position.y + self.offsetHp + 30 + offset2
    -- local max = self.maxy
    -- if offset then
    --     max = max + offset
    -- end
    -- if finalY > max then
    --     finalY = max
    -- end
    -- panel.transform.localPosition = Vector3(position.x, finalY, 0)
    local pos = self.hpBarPanel.transform.localPosition + Vector3(0, 37+offset2, 0)
    local max = 270 - panel.transform.sizeDelta.y/2
    if pos.y > max then
        pos = Vector3(pos.x, max, pos.y)
    end
    panel.transform.localPosition = pos
end

function FighterController:SetTalkBubblePanel(bubblePanel)
    -- if not BaseUtils.isnull(self.bubblePanel) then
    --     self:DestroyTalkBubble(self.bubbleid)
    -- end
    if BaseUtils.isnull(self.hpBarPanel) then
        return
    end
    self.bubbleid = Time.time
    local bbid = self.bubbleid
    if self.fighterData.is_die == 1 and self.fighterData.type ~= 1 then
        self.bubblePanel = bubblePanel
        self:DestroyTalkBubble()
        return
    end
    local pos = self.hpBarPanel.transform.localPosition + Vector3(0, 65, 0)
    local max = 270 - bubblePanel.transform.sizeDelta.y/2
    if pos.y > max then
        pos = Vector3(pos.x, max, pos.y)
    end
    bubblePanel.transform.localPosition = pos
    if not BaseUtils.isnull(self.bubblePanel) then
        if not BaseUtils.isnull(self.lastbubblePanel) then
            GameObject.DestroyImmediate(self.lastbubblePanel.gameObject)
        end
        self.lastbubblePanel = self.bubblePanel
        local sizeD = self.bubblePanel.transform.sizeDelta
        if not BaseUtils.isnull(self.bubblePanel.transform:Find("arrow")) then
            self.bubblePanel.transform:Find("arrow").gameObject:SetActive(false)
        end
        local target = pos + Vector3(0, bubblePanel.transform.sizeDelta.y/2 + self.bubblePanel.transform.sizeDelta.y/2, 0)
        local bubble_endfunc = function()
            if self.bubbletween ~= nil then
                Tween.Instance:Cancel(self.bubbletween)
                self.bubbletween = nil
            end
        end
        self.bubbletween = Tween.Instance:MoveLocal(self.bubblePanel, target, 0.2, bubble_endfunc, LeanTweenType.easeOutQuart).id
    end
    self.bubblePanel = bubblePanel
    LuaTimer.Add(3000, function()
        if not BaseUtils.isnull(bubblePanel) then
            GameObject.DestroyImmediate(bubblePanel)
        end
    end)
    return self.bubbleid
end
function FighterController:DestroyTalkBubble(id)
    if self.bubbleid ~= id and id ~= nil then
        -- print("<color='#ff0000'>没有删掉啊啊啊啊啊啊</color>")
        return
    end
    if self.bubblePanel ~= nil then
        GameObject.DestroyImmediate(self.bubblePanel)
        self.bubblePanel = nil
    end
end

function FighterController:UpdateBubble()
    if not BaseUtils.isnull(self.bubblePanel) and not BaseUtils.isnull(self.hpBarPanel) then
        local pos = self.hpBarPanel.transform.localPosition + Vector3(0, 65, 0)
        local max = 270 - self.bubblePanel.transform.sizeDelta.y/2
        if pos.y > max then
            pos = Vector3(pos.x, max, pos.y)
        end
        self.bubblePanel.transform.localPosition = pos
        if not BaseUtils.isnull(self.lastbubblePanel) and not BaseUtils.isnull(self.hpBarPanel) then
            local target = pos + Vector3(0, self.bubblePanel.transform.sizeDelta.y/2 + self.lastbubblePanel.transform.sizeDelta.y/2, 0)
            self.lastbubblePanel.transform.localPosition = target
        end
    end
end


function FighterController:GetScreenPoint()
    if BaseUtils.is_null(self.transform) then
        return Vector3.one*10
    end
    if self.selfWorldScreenPoint == nil then
        local position = self.transform.position
        self.isScreenPointChange = false
        self.selfWorldScreenPoint = CombatUtil.WorldToUIPoint(self.combatCamera, position)
        return self.selfWorldScreenPoint
    else
        if not self.isScreenPointChange then
            return self.selfWorldScreenPoint
        else
            local position = self.transform.position
            self.isScreenPointChange = false
            self.selfWorldScreenPoint = CombatUtil.WorldToUIPoint(self.combatCamera, position)
            return self.selfWorldScreenPoint
        end
    end
end

function FighterController:CreateFighterUI(mainPanel)
    self.mainPanel = mainPanel
    local mixPanel = self.mainPanel.mixPanel
    -- self.hpBarPanel = CombatManager.Instance.objPool:Pop("Blood")
    self.hpBarPanel = nil
    if self.hpBarPanel == nil then
        self.hpBarPanel = GameObject.Instantiate(mixPanel.fighterInfoTop)
    end
    -- table.insert(self.controller.uiResCacheList, {id = "Blood", go = self.hpBarPanel})
    self.hpBarPanel.transform:SetParent(mixPanel.PlayerInfoCanvas)
    self.hpBarPanel:SetActive(true)
    local canvasG = self.hpBarPanel.transform:GetComponent(CanvasGroup) or self.hpBarPanel.transform.gameObject:AddComponent(CanvasGroup)
    canvasG.blocksRaycasts = false
    local pos = self.transform.position
    local wpos = CombatUtil.WorldToUIPoint(self.combatCamera, pos)
    local footPos = CombatUtil.WorldToUIPoint(self.combatCamera, Vector3(pos.x, pos.y - 0.19, pos.z))
    local topPos = CombatUtil.WorldToUIPoint(self.combatCamera, Vector3(pos.x, pos.y + 0.9, pos.z))
    self.offsetName = footPos.y - wpos.y
    self.offsetHp = topPos.y - wpos.y

    if self.fighterData.type ~= FighterType.Role and self.fighterData.type ~= FighterType.Cloner then
        local tcc = self.tpose.childCount - 1
        for i = 0, tcc do
            local child = self.tpose:GetChild(i)
            if string.match(child.name, "Mesh_") ~= nil then
                local boundsy = child.renderer.bounds.size.y
                local toph = pos.y + boundsy
                if toph > 1.6 then
                    toph = 1.6
                end
                topPos = CombatUtil.WorldToUIPoint(self.combatCamera, Vector3(pos.x, toph, pos.z))
                self.offsetHp = topPos.y - wpos.y
            end
        end
    end


    -- local fianlY = wpos.y + self.offsetHp
    local fianlY = wpos.y + 125
    if fianlY > self.maxy then
        fianlY = self.maxy
    end
    self.hpBarPanel.transform.localPosition = Vector3(wpos.x, fianlY, wpos.z)
    -- self.orderText = self.hpBarPanel.transform:Find("BloodFrameImage"):Find("OrderText"):GetComponent(Text)
    -- self:SetOrder(self.fighterData.order)
    self.bloodImage = self.hpBarPanel.transform:Find("BloodFrameImage/BloodImage"):GetComponent(Image)
    self.bloodYellow = self.hpBarPanel.transform:Find("BloodFrameImage/Yellow"):GetComponent(Image)
    self.tempbloodImage = self.hpBarPanel.transform:Find("BloodFrameImage/TempBloodImage"):GetComponent(Image)
    self.hpBarPanel.name = "Blood_" .. self.fighterData.order
    self.hpBarPanel.transform.localScale = Vector3(1, 1, 1)

    self.hpBarPanel.transform:Find("BloodFrameImage").gameObject:SetActive(true)
    self:UpdateHpBar()

    local selfData = self.controller.selfData
    local color = Color(1, 1, 1, 1)
    if selfData.id == self.fighterData.id then
        color = Color(0.376, 1, 0.294, 1)
    else
        color = Color(1, 1, 0, 1)
    end
    -- self.nameText.text = self.fighterData.name
    local bloodActive = false
    if self.fighterData.group ~= selfData.group then
        if self.fighterData.type == FighterType.Role or self.fighterData.type == FighterType.Cloner or self.fighterData.type == FighterType.Guard then
            bloodActive = false
        elseif self.fighterData.type == FighterType.Unit then
            local npcData = self.combatMgr:GetNpcBaseData(self.fighterData.base_id)
            if npcData ~= nil and npcData.show_blood == 1 then
                bloodActive = true
            end
        end
    elseif self.fighterData.group == selfData.group then
        bloodActive = true
    end
    if CombatUtil.NotShowBloodType[self.controller.enterData.combat_type] ~= nil and  self.combatMgr.isWatching then
        bloodActive = false
    end
    bloodActive = bloodActive or self.combatMgr.isWatchRecorder
    self.ShowBlood = bloodActive
    self.hpBarPanel.transform:Find("BloodFrameImage").gameObject:SetActive(bloodActive)
    if self.fighterData.master_name ~= nil then
        self.fnameText:GetComponent(TextMesh).text = string.format(TI18N("%s的%s"), self.fighterData.master_name, self.fighterData.name)
    else
        self.fnameText:GetComponent(TextMesh).text = self.fighterData.name
    end
    for i,v in ipairs(self.fighterData.looks) do
        if v.looks_type == SceneConstData.looktype_lev_break then -- 等级突破
            if v.looks_val == 1 then
                color = ColorHelper.colorObject[10]
            elseif v.looks_type == 2 then
                color = ColorHelper.colorObject[11]
            end
        end
    end
    self.fnameText:GetComponent(TextMesh).color = color
    if self.fighterData.master_name ~= nil then
        self.fnameTextShadow:GetComponent(TextMesh).text = string.format(TI18N("%s的%s"), self.fighterData.master_name, self.fighterData.name)
    else
        self.fnameTextShadow:GetComponent(TextMesh).text = self.fighterData.name
    end

    local point = Vector3(0, -0.1, -0.1)
    self.fnameText.transform.rotation = Quaternion.identity
    self.fnameText.transform:Rotate(Vector3(20, 0, 0))
    self.fnameTextShadow.transform.rotation = Quaternion.identity
    self.fnameTextShadow.transform:Rotate(Vector3(20, 0, 0))
    self.fnameText.transform.localPosition = point
    self.fnameTextShadow.transform.localPosition = Vector3(point.x + 0.01, point.y - 0.01, point.z)
    self.fnameTextShadow.transform.localPosition = self.combatCamera.transform.forward*10 + self.fnameTextShadow.transform.localPosition
    self.fnameText.transform.localPosition = self.combatCamera.transform.forward*10 + self.fnameText.transform.localPosition

    -- 准备中文字
    if self.fighterData.type == FighterType.Role then
        local preImage = self.mainPanel.mixPanel.PreparingImage
        -- self.preparingImage = CombatManager.Instance.objPool:Pop("PreparingImage")
        self.preparingImage = nil
        if self.preparingImage == nil then
            self.preparingImage = GameObject.Instantiate(preImage)
        end
        -- table.insert(self.controller.uiResCacheList, {id = "PreparingImage", go = self.preparingImage})
        self.preparingImage.transform:SetParent(self.mainPanel.mixPanel.PlayerInfoCanvas)
        self.preparingImage.transform.localScale = Vector3(1, 1, 1)
        self:SetTopPosition2(self.preparingImage, 0, -14)
        self.preparingImage:SetActive(false)
        local canvasG = self.preparingImage.transform:GetComponent(CanvasGroup) or self.preparingImage.transform.gameObject:AddComponent(CanvasGroup)
        canvasG.blocksRaycasts = false
    end
end

function FighterController:SetOrder(order)
    -- self.orderText.text = tostring(order)
end

function FighterController:UpdateHpBar()
    if BaseUtils.isnull(self.bloodImage) or BaseUtils.isnull(self.bloodImage.transform) then
        return
    end
    local hpMax = self.fighterData.hp_max
    local hp = self.fighterData.hp
    local temphpMax = self.fighterData.tmp_hp_max
    if hpMax == 0 then
        hpMax = 0.00001
    end
    local hpx = hp / hpMax

    if self.fighterData.type == 2
        and (self.fighterData.base_id == 32011
            or self.fighterData.base_id == 32012
            or self.fighterData.base_id == 32013) then
        hpx = GuildDragonManager.Instance:GetRest(BaseUtils.BASE_TIME) / 1000
    end

    if hpx > 1 then
        hpx = 1
    elseif hpx < 0 then
        hpx = 0
    end

    self.bloodImage.fillAmount = hpx
    -- local descr1 = Tween.Instance:Scale(self.bloodYellow.fillAmount, hpx, 0.5, function()  end, LeanTweenType.linear)
    local endfunc1 = function()
        if self.bloodtween1 ~= nil then
            if self.bloodtween1 ~= nil then
                Tween.Instance:Cancel(self.bloodtween1)
                self.bloodtween1 = nil
            end
        end
    end
    self.bloodtween1 = Tween.Instance:ValueChange(self.bloodYellow.fillAmount, hpx, 0.5, endfunc1, LeanTweenType.linear, function(value) if self.bloodYellow ~= nil then self.bloodYellow.fillAmount = value end end).id
    if temphpMax ~= nil then
        local endfunc2 = function()
            if self.bloodtween2 ~= nil then
                if self.bloodtween2 ~= nil then
                    Tween.Instance:Cancel(self.bloodtween2)
                    self.bloodtween2 = nil
                end
            end
        end
        local tempval = Mathf.Clamp((hpMax - temphpMax)/hpMax, 0, 0.5)
        local startval = self.tempbloodImage.gameObject.transform.localScale.x
        self.bloodtween2 = Tween.Instance:ValueChange(startval, tempval, 0.5, endfunc2, LeanTweenType.linear, function(value) if self.tempbloodImage ~= nil and not BaseUtils.isnull(self.tempbloodImage.gameObject) then self.tempbloodImage.gameObject.transform.localScale = Vector3(value, 1, 1) end end).id
    end
    if self.fighterData.id == self.controller.selfData.id then
        self.controller.mainPanel.headInfoPanel:UpdateRoleInfo(self.fighterData)
    elseif self.controller.selfPetData ~= nil and self.controller.selfPetData.id == self.fighterData.id then
        self.controller.mainPanel.headInfoPanel:UpdatePetInfo(self.fighterData)
        self.controller.selfPetData = self.fighterData
    end
end

-- 定位
function FighterController:ReLocaHpBar()
    if BaseUtils.isnull(self.transform) or BaseUtils.isnull(self.tpose) then
        return
    end
    local pos = self.transform.position
    local wpos = CombatUtil.WorldToUIPoint(self.combatCamera, pos)
    local footPos = CombatUtil.WorldToUIPoint(self.combatCamera, Vector3(pos.x, pos.y - 0.19, pos.z))
    local topPos = CombatUtil.WorldToUIPoint(self.combatCamera, Vector3(pos.x, pos.y + 0.9, pos.z))
    self.offsetName = footPos.y - wpos.y
    self.offsetHp = topPos.y - wpos.y
    self.offsetHp = 0

    if self.fighterData.type ~= FighterType.Role and self.fighterData.type ~= FighterType.Cloner then
        local tcc = self.tpose.childCount - 1
        for i = 0, tcc do
            local child = self.tpose:GetChild(i)
            if child.gameObject.activeSelf and child.renderer ~= nil then
                local boundsy = child.renderer.bounds.size.y
                local toph = pos.y + boundsy
                if toph > 1.6 then
                    toph = 1.6
                end
                topPos = CombatUtil.WorldToUIPoint(self.combatCamera, Vector3(pos.x, toph, pos.z))
                self.offsetHp = topPos.y - wpos.y
            end
        end
    end


    -- local fianlY = wpos.y + self.offsetHp
    local fianlY = wpos.y + 100
    if fianlY > self.maxy then
        fianlY = self.maxy
    end
    self.hpBarPanel.transform.localPosition = Vector3(wpos.x, fianlY, wpos.z)

end

function FighterController:SetAlpha(val)
    self.alpha = val
    if not BaseUtils.isnull(self.tpose) then
        CombatUtil.SetAlpha(self.tpose.gameObject, val)
    end
    if not BaseUtils.isnull(self.originTpose) then
        CombatUtil.SetAlpha(self.originTpose.gameObject, val)
    end
    if not BaseUtils.isnull(self.headTpose) then
        CombatUtil.SetAlpha(self.headTpose.gameObject, val)
    end
    for _, weapon in ipairs(self.weaponList) do
        CombatUtil.SetAlpha(weapon, val)
    end
    if self.color ~= nil then
        self:SetColor(self.color)
    end
end

function FighterController:SetScale(val)
    if not BaseUtils.isnull(self.tpose) then
        if val == 1 then
            if self.defaultScale ~= nil then
                self.tpose.transform.localScale = Vector3.one * self.defaultScale
            else
                self.tpose.transform.localScale = Vector3.one
            end
        else
            self.tpose.transform.localScale = Vector3.one*val
        end
    end
end

function FighterController:SetColor(color)
    self.color = color
    self.color.a = self.alpha
    CombatUtil.SetColor(self.tpose.gameObject, color)
end

function FighterController:SetHitQueue(queue)
    self.stepHitQueue = queue
    self.IsHitMove = true
end
function FighterController:HideCommand()
    if self.controller ~= nil and self.controller.mainPanel ~= nil then
        self.controller.mainPanel.mixPanel:HidCommand(self.fighterData.id)
    end
end
function FighterController:HideBloodBar()
    if not BaseUtils.is_null(self.hpBarPanel) then
        self.hpBarPanel.transform:Find ("BloodFrameImage").gameObject:SetActive (false)
    end
end
function FighterController:ShowBloodBar()
    if BaseUtils.is_null(self.hpBarPanel) then
        return
    end
    if self.ShowBlood then
        self.hpBarPanel.transform:Find ("BloodFrameImage").gameObject:SetActive (true)
    end
    if self.buffCtrl ~= nil then
        self:ShowBuffPanel()
    end
end
function FighterController:HideNameText()
    if not BaseUtils.is_null(self.fnameText) then
        self.fnameText:SetActive(false)
        self.fnameTextShadow:SetActive(false)
    end
end
function FighterController:ShowNameText()
    if not BaseUtils.is_null(self.fnameText) then
        self.fnameText:SetActive(true)
        self.fnameTextShadow:SetActive(true)
    end
end

function FighterController:ChangeNameText(name)
    if not BaseUtils.is_null(self.fnameText) then
        if self.fighterData.master_name ~= nil then
            self.fnameText:GetComponent(TextMesh).text = string.format(TI18N("%s的%s"), self.fighterData.master_name, name)
            self.fnameTextShadow:GetComponent(TextMesh).text = string.format(TI18N("%s的%s"), self.fighterData.master_name, name)
        else
            self.fnameText:GetComponent(TextMesh).text = name
            self.fnameTextShadow:GetComponent(TextMesh).text = name
        end
    end
end

function FighterController:ShowShadow(isShow)
    if not BaseUtils.isnull(self.shadow) then
        self.shadow:SetActive(isShow)
    end
end

function FighterController:HideBuffPanel()
    self.buffCtrl:HideBuffPanel()
end

function FighterController:ShowBuffPanel()
    self.buffCtrl:ShowBuffPanel()
end

function FighterController:SetDisappear(disappear)
    self:DoShake(false)
    self.IsDisappear = disappear
    self:ShowShadow(disappear == false)
    -- if not BaseUtils.isnull(self.transform) then
    --     self.transform.gameObject:SetActive(disappear)
    -- end
end

function FighterController:SetHpBarPanelPosition()
    if BaseUtils.isnull(self.transform) or BaseUtils.isnull(self.hpBarPanel) then
        return
    end
    local pos = self.transform.position
    local wpos = CombatUtil.WorldToUIPoint(self.combatCamera, pos)
    local finalY = wpos.y + self.offsetHp + self.hpBarPanelBuffOffset
    local finalY = wpos.y + 100 + self.hpBarPanelBuffOffset
    if finalY > self.maxy then
        finalY = self.maxy
    end
    self.hpBarPanel.transform.localPosition = Vector3(wpos.x, finalY, wpos.z)
    self:UpdateBubble()
end

-- 变身
function FighterController:Transformer(newTpose, animationData, NpcBaseId)
    if BaseUtils.isnull(self.originTpose) then
        return
    end
    if self.originTpose.name == "OldTpose" then --已经变身,保留至特效播完
        self.tpose.gameObject.name = "LastOldTpose"
        local old = self.tpose.gameObject
        CombatUtil.SetMesh(old, false)
        LuaTimer.Add(5000, function() if not BaseUtils.isnull(old) then GameObject.Destroy(old) end  end)
    end
    self.tranNpcId = NpcBaseId
    self.animationData = animationData
    self.tpose = newTpose.transform
    self.animator = self.tpose.gameObject:GetComponent(Animator)
    self.animator.cullingMode = AnimatorCullingMode.AlwaysAnimate
    self.originTpose.name = "OldTpose"
    self.originTpose.gameObject:SetActive(false)
    self:FaceTo(self.originFaceToPos)
    self.buffCtrl:TransformerForEffect(self.tpose)
    local oldEffectnum = 0
    for i = 0, self.originTpose.transform.childCount-1 do
        local cGo = self.originTpose.transform:GetChild(i).gameObject
        if string.sub(cGo.name,-7,-1) == "(Clone)" then
            local eff = GameObject.Instantiate(cGo)
            eff.transform:SetParent(self.tpose)
            Utils.ChangeLayersRecursively(eff.transform, "CombatModel")
            eff.transform.localPosition = Vector3(0, 0, 0)
            eff.transform.localScale = Vector3(1, 1, 1)
        end
    end
    self.tpose.gameObject:SetActive(true)
    -- self:UpdateHpBar()
    self:ReLocaHpBar()
    local rename = BaseUtils.Key(self.fighterData.base_id, NpcBaseId)
    if DataCombatUtil.data_name_change[rename] ~= nil then
        self:ChangeNameText(DataCombatUtil.data_name_change[rename].name)
    end
    self:CreateEffect()
    self:SetAlpha(self.alpha)
end

-- 变身还原
function FighterController:TransformerRevert()
    if (self.fighterData ~= nil and self.fighterData.is_die == 1 and self.fighterData.is_die_disappear == 1) or BaseUtils.isnull(self.originTpose) or BaseUtils.isnull(self.tpose) then
        return
    end
    if self.fighterData.type == FighterType.Role and self:DealLooksTransformer() or self.tranNpcId == 0 then
        return
    end
    self.tranNpcId = 0
    self.animationData = self.originAnimationData
    self.originTpose.gameObject:SetActive(true)
    self.animator = self.originTpose.gameObject:GetComponent(Animator)
    self.originTpose.name = "tpose"
    self.tpose.name = "tpose_desctroy"
    self.tpose.gameObject:SetActive(false)
    self.tpose = self.originTpose
    self.buffCtrl:TransformerForEffect(self.tpose)
    self:FaceTo(self.originFaceToPos)
    if self.fighterData.is_die == 1 and self.fighterData.is_die_disappear == 0 then
        self:PlayAction(FighterAction.Dead)
        self:HideBloodBar()
        self:SetAlpha(0.5)
        self:HideWing()
    else
        self:PlayAction(FighterAction.BattleStand)
    end
    self:UpdateHpBar()
    self:ChangeNameText(self.fighterData.name)
    -- GameObject.Destroy(self.tpose)
end

-- 修正Y
function FighterController:FixedMaxY()
    local real = ctx.ScreenWidth / ctx.ScreenHeight
    local rate = 960 / 540
    local maxy = 270 + (270 * rate / real - 270) / 2
    return maxy - 25
end

-- 准备中
function FighterController:ShowPreparing()
    if BaseUtils.isnull(self.preparingImage) then
        return
    end
    if self.fighterData.type == FighterType.Role then
        self.preparingImage:SetActive(true)
    end
end
function FighterController:HidePreparing()
    if BaseUtils.isnull(self.preparingImage) then
        return
    end
    if self.fighterData.type == FighterType.Role then
        self.preparingImage:SetActive(false)
    end
end

function FighterController:ShowWing()
    if not BaseUtils.isnull(self.wingTpose) then
        self.wingTpose:SetActive(true)
    end
    if not BaseUtils.isnull(self.beltTpose) then
        self.beltTpose:SetActive(true)
    end
    if not BaseUtils.isnull(self.headsurbasetpose) then
        self.headsurbasetpose:SetActive(true)
    end
end

function FighterController:HideWing()
    if not BaseUtils.isnull(self.wingTpose) then
        self.wingTpose:SetActive(false)
    end
    if not BaseUtils.isnull(self.beltTpose) then
        self.beltTpose:SetActive(false)
    end
    if not BaseUtils.isnull(self.headsurbasetpose) then
        self.headsurbasetpose:SetActive(false)
    end
end

function FighterController:GetNormalAttactMotionID()
    if self.fighterData.base_id == 0 then
        return CombatUtil.GetNormalSKillMotion(self.fighterData.classes)
    end
    local res_id
    if self.fighterData.type == FighterType.Guard then
        res_id = DataShouhu.data_guard_base_cfg[self.fighterData.base_id].res_id
        for k, v in ipairs(self.fighterData.looks) do
            if v.looks_type == 70 then
                res_id =  v.looks_mode
            end
        end
    elseif self.fighterData.type == FighterType.Pet then
        local petData = self.combatMgr:GetPetBaseData(self.fighterData.base_id)
        res_id = petData.model_id
    elseif self.fighterData.type == FighterType.Child then
        local childData = self.combatMgr:GetChildBaseData(self.fighterData.base_id)
        res_id = childData.model_id
    else
        local data_unit = DataUnit.data_unit[self.fighterData.base_id]
        if data_unit.res_type == 5 then -- 如果是人形怪这里应该取职业动作
            return CombatUtil.GetNormalSKillMotion(self.fighterData.classes)
        else
            res_id = data_unit.res
        end
        
    end
    if self.modelId ~= 0 and self.tranNpcId == 0 then
        res_id = self.modelId
    end
    if DataMotionEvent.data_motion_event[BaseUtils.Key("1000", res_id)] ~= nil then
        return 1000
    end
    for k,v in pairs(DataMotionEvent.data_motion_event) do
        if v.npc_res_id == res_id and v.is_ooc == 1 then
            return v.motion_id
        end
    end
    return nil
end

function FighterController:GetTransformerNormalAttactMotionID(motionId)
    local res_id = DataUnit.data_unit[self.tranNpcId]
    if res_id == nil then
        res_id = DataTransform.data_transform[self.tranNpcId].res
    else
        res_id = res_id.res
    end
    if res_id == nil then
        Log.Error(string.format("No appropriate Unit for tranNpcId:%s ", tostring(self.tranNpcId)))
        return nil
    -- else
    --     res_id = res_id.res
    end
    if DataMotionEvent.data_motion_event[BaseUtils.Key(tostring(motionId), res_id)] ~= nil then
        return motionId
    end
    for k,v in pairs(DataMotionEvent.data_motion_event) do
        if v.npc_res_id == res_id and v.is_ooc == 1 then
            return v.motion_id
        end
    end
    if DataMotionEvent.data_motion_event[BaseUtils.Key("1000", res_id)] ~= nil then
        return 1000
    end
    return nil
end

function FighterController:DealLooksTransformer()
    -- if self.controller.enterData.combat_type ~= 52 then

        for k,v in pairs(self.fighterData.looks) do
            if v.looks_type == SceneConstData.looktype_transform then -- 变身
                local mark = false -- 显示变身标记
                -- if SceneManager.Instance.sceneElementsModel.Show_Transform_Mark then
                --     mark = true
                -- else
                    -- local transform_data = DataTransform.data_transform[v.looks_val]
                    -- if transform_data ~= nil and transform_data.hard_show == 1 then
                    --     mark = true
                    -- end

                    -- if DataBuff.data_transform_combat_type[CombatManager.Instance.combatType] then
                    --     mark = true
                    -- end
                -- end

                -- if mark then
                    local action = TransformerAction.New(self.controller.brocastCtx, self, v.looks_val)
                    action:Play()
                    return true
                -- end
            end
        end
    -- end
    if self.fighterData.model_id ~= nil and self.fighterData.model_id ~= 0 then
        local action = TransformerAction.New(self.controller.brocastCtx, self, self.fighterData.model_id)
        action:Play()
        return true
    end
    self:CreateEffect()
    if self.tranNpcId == 0 then
        return true
    end
    return false
end

function FighterController:GetModelId()
    local modelId = 0
    if self.fighterData.type == FighterType.Role or self.fighterData.type == FighterType.Cloner then
        modelId = 0
    elseif self.fighterData.type == FighterType.Unit then
        local NpcBaseId = self.fighterData.base_id
        if self.tranNpcId ~= 0 then
            NpcBaseId = self.tranNpcId
        end
        local unitData = self.combatMgr:GetNpcBaseData(NpcBaseId)
        if unitData ~= nil then
            modelId = unitData.res
        end
    elseif self.fighterData.type == FighterType.Pet then
        local petData = self.combatMgr:GetPetBaseData(self.fighterData.base_id)
        modelId = petData.model_id
    elseif self.fighterData.type == FighterType.Child then
        local childData = self.combatMgr:GetChildBaseData(self.fighterData.base_id)
        modelId = childData.model_id
    elseif self.fighterData.type == FighterType.Guard then
        local guardData = self.combatMgr:GetGuardBaseData(self.fighterData.base_id)
        modelId = guardData.res_id
        for k, v in ipairs(self.fighterData.looks) do
            if v.looks_type == 70 then
                modelId =  v.looks_mode
            end
        end
    end
    if self.tranNpcId ~= 0 then
        local unitData = self.combatMgr:GetNpcBaseData(self.tranNpcId)
        if unitData ~= nil then
            modelId = unitData.res
        end
    end
    return modelId
end

function FighterController:PlayGuardSound(skill_id)
    local Key = string.format("%s_%s", skill_id, self.fighterData.base_id)
    local data = DataSkillSound.data_skill_sound_guard[Key]
    local random = Random.Range(1, 100)
    if data ~= nil and random < data.rate then
        SoundManager.Instance:PlayCombatChat(data.sound_id)
        return true
    else
        return false
    end
end


function FighterController:CreateEffect()
    if true then
        return
    end
    local effectId = 0
    for k,v in pairs(self.fighterData.looks) do
        if v.looks_type == SceneConstData.looktype_buff then
            local effect_Id = DataBuff.data_list[v.looks_val].effect_id
            if effect_Id ~= 0 then effectId = effect_Id end
        end
    end
    if effectId == 0 then
        return
    end
    if self.tpose == nil then
        print(string.format("tpose 未创建完 %s \n%s", effectId, debug.traceback()))
        return
    end

    local effectData = DataEffect.data_effect[effectId]
    if effectData == nil then
        print(string.format("effect_data 这个特效id数据没有啊 %s", effectId))
        return
    end

    local callback = function(effect)
        if not BaseUtils.is_null(self.tpose) then
            self:BindEffect(effectData, self.tpose, effect.gameObject)
        else
            GameObject.DestroyImmediate(effect.gameObject)
            effect.gameObject = nil
        end
    end
    local effect = BaseEffectView.New({ effectId = effectData.res_id, callback = callback })
    -- local key = tostring(effectData.id)
    -- if self.effectdict[key] == nil then
    --     self.effectdict[key] = {effect = effect, effectId = effectData.id}
    -- end
end


function FighterController:BindEffect(effectData, tpose, effect, effectlist)

    if BaseUtils.isnull(effect) then
        return
    end
    if effectData.mounter == EffectDataMounter.Origin then
        if BaseUtils.isnull(effect) or BaseUtils.isnull(tpose) then
            -- 可能切换战斗时特效或模型已经被干掉
            return
        end
        effect.transform:SetParent(tpose.transform)
        self:EffectSetting(effect, effectData)
    elseif effectData.mounter == EffectDataMounter.TopOrigin then
        effect.transform:SetParent(tpose.transform.parent)
        self:EffectSetting(effect, effectData)
        effect.transform.localPosition = Vector3(0, 0.75, 0)
    elseif effectData.mounter == EffectDataMounter.Weapon then
        local lmounter = BaseUtils.GetChildPath(tpose, "Bip_L_Weapon")
        local rmounter = BaseUtils.GetChildPath(tpose, "Bip_R_Weapon")
        if lmounter ~= "" or rmounter ~= "" then
            local clone = false
            if lmounter ~= "" then
                local lm = tpose.transform:Find(lmounter)
                if lm ~= nil then
                    effect.transform:SetParent(lm)
                    self:EffectSetting(effect, effectData)
                    clone = true
                end
            end
            if rmounter ~= "" then
                local rm = tpose.transform:Find(rmounter)
                if rm ~= nil then
                    if clone  then
                        reffect.transform:SetParent(rm)
                        self:EffectSetting(reffect, effectData)
                    else
                        effect.transform:SetParent(rm)
                        self:EffectSetting(effect, effectData)
                    end
                end
            end
        else
            effect.transform:SetParent(tpose.transform)
            self:EffectSetting(effect, effectData)
        end
    else
        local mounterPath = nil
        if effectData.mounter == EffectDataMounter.Wing then
            mounterPath = BaseUtils.GetChildPath(tpose, "bp_wing")
        elseif effectData.mounter == EffectDataMounter.WingL1 then
            -- 看以后需求改
            mounterPath = BaseUtils.GetChildPath(tpose, "bp_wing")
        else
            mounterPath = BaseUtils.GetChildPath(tpose, "bp_wing")
        end
        if mounterPath ~= nil then
            local mounter = tpose.transform:Find(mounterPath)
            if mounter ~= nil then
                effect.transform:SetParent(mounter)
                self:EffectSetting(effect, effectData)
            end
        end
    end
end

function FighterController:EffectSetting(effect, effectData)
    effect.transform.localScale = Vector3(1, 1, 1)
    effect.transform.localPosition = Vector3(0, 0, 0)
    effect.transform.localRotation = Quaternion.identity
    if effectData.overlay ~= 1 then
        Utils.ChangeLayersRecursively(effect.transform, "CombatModel")
    else
        Utils.ChangeLayersRecursively(effect.transform, "Ignore Raycast")
    end
    effect:SetActive(true)
end

function FighterController:DoShake(active)
    if active and self.shaker == nil then
        if self.fighterData.is_die ~= 1 then
            LuaTimer.Add(Random.Range(100, 200), function()
                if self.shaker == nil then
                    local pointlist = CombatUtil.GetRandomPointList()
                    self.shaker = Tween.Instance:MoveLocal(self.tpose.gameObject, pointlist, 0.6, nil, LeanTweenType.linear):setLoopClamp()
                end
            end)
        end
    elseif not active and self.shaker ~= nil then
        Tween.Instance:Cancel(self.shaker.id)
        self.tpose.localPosition = Vector3.zero
        self.shaker = nil
    end
    self.isshake = active
end
