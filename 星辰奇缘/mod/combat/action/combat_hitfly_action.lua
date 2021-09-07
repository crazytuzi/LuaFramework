-- 击飞
HitFlyAction = HitFlyAction or BaseClass(CombatBaseAction)

function HitFlyAction:__init(brocastCtx, actionData)
    self.actionData = actionData
    self.targetCtrl = self:FindFighter(actionData.target_id)
    self.target = self.targetCtrl.transform.gameObject
    self.tpose = self.target.transform:FindChild("tpose").gameObject
    self.tposeClone = GameObject.Instantiate(self.tpose)
    self.tposeClone.transform:SetParent(self.brocastCtx.controller.CombatScene.transform, true)
    self.tposeClone.transform.position = Vector3.one*100
    table.insert(self.brocastCtx.controller.rubbishList, {id = "tposeClone", go = self.tposeClone})
    self.shaker = nil
    self.isEnd = false
    CombatUtil.SetMesh(self.tposeClone, false)
    local fighterData = self.targetCtrl.fighterData
    local animator = self.tposeClone:GetComponent(Animator)
    animator:Play("Upthrow"..self.targetCtrl.animationData.upthrow_id)
    -- self.targetCtrl:PlayAction(FighterAction.Upthrow)
    local childnum = self.tposeClone.transform.childCount
    for i=1, childnum do
        local child = self.tposeClone.transform:GetChild(i-1)
        if string.find(child.gameObject.name, 'BuffEffect') ~= nil then
            GameObject.Destroy(child.gameObject)
        end
    end
    self.up = false
end

function HitFlyAction:Play()
    -- CombatUtil.SetAlpha(self.tpose, 0)
    self.tpose = self.target.transform:FindChild("tpose").gameObject  -- 可能被变身
    CombatUtil.SetMesh(self.tpose, false)
    -- CombatUtil.SetAlpha(self.tposeClone, 1)
    CombatUtil.SetMesh(self.tposeClone, true)
    self:InvokeDelay(self.SetTposePosition, 0.02, self)
end

function HitFlyAction:SetTposePosition()
    if not self.isEnd and not BaseUtils.isnull(self.tposeClone) then
        self.tpose = self.target.transform:FindChild("tpose").gameObject
        CombatUtil.SetMesh(self.tpose, false)
        if BaseUtils.isnull(self.tposeClone) then
            self.tposeClone = GameObject.Instantiate(self.tpose)
            local animator = self.tposeClone:GetComponent(Animator)
            animator:Play("Upthrow"..self.targetCtrl.animationData.upthrow_id)
        end
        if BaseUtils.isnull(self.shaker) then
            if self.up then
                self.tposeClone.transform.position = self.tposeClone.transform.position + Vector3.one
            else
                self.tposeClone.transform.position = self.tposeClone.transform.position - Vector3.one
            end
            self.up = not self.up
        else
            self.tposeClone.transform.position = self.shaker.transform.position
        end
        self:InvokeDelay(self.SetTposePosition, 0.02, self)
    end
end

function HitFlyAction:OnActionEnd()
    self.isEnd = true
    -- CombatUtil.SetAlpha(self.tpose, 1)
    CombatUtil.SetMesh(self.tpose, true)
    if self.actionData.is_target_die == 1 then
        local dead = DeadAction.New(self.brocastCtx, self.targetCtrl.fighterData.id)
        dead:AddEvent(CombatEventType.End, self.OnEnd, self)
        if self.actionData.is_target_die_disappear == 1 then
            local delay = DelayAction.New(self.brocastCtx, 100)
            local disapper = DisapperAction.New(self.brocastCtx, self.targetCtrl.fighterData.id)
            delay:AddEvent(CombatEventType.End, disapper)
            print(self.targetCtrl.fighterData.name .. "击飞死亡")
            -- disapper:Play()
            delay:Play()
        end
        dead:Play()
    else
        local standup = StandupAction.New(self.brocastCtx, self.targetCtrl)
        local battlesStand = BattleStandAction.New(self.brocastCtx, self.targetCtrl)
        standup:AddEvent(CombatEventType.End, battlesStand)
        battlesStand:AddEvent(CombatEventType.End, self.OnEnd, self)
        standup:Play()
    end
    GameObject.DestroyImmediate(self.tposeClone)
end

function HitFlyAction:OnEnd()
    self:InvokeAndClear(CombatEventType.End)
end

function HitFlyAction:InitCloneTpose()
end

