-- 战斗上浮消息消息
CombatFloatMsgAction = CombatFloatMsgAction or BaseClass(CombatBaseAction)

function CombatFloatMsgAction:__init(brocastCtx, minorAction, actionData)
    self.actionData = actionData
    self.brocastCtx = brocastCtx
    self.minorAction = minorAction
    self.triggerHit = minorAction.triggerHit
    self.triggerEnd = minorAction.triggerEnd
    self.msgdata = {
        type = 3,
        msg = actionData.action_msg,
        limit = {}
    }

    -- 如果战斗提示出问题了，看看是不是这里被我注释掉了
    actionData.action_msg = nil

    self:Process()
end


function CombatFloatMsgAction:Process()
    local actionData = self.actionData
    local targetChgList = actionData.target_changes
    for _, chgData in ipairs(targetChgList) do
        if chgData.change_type == 2 then
            if chgData.change_val == 0 then -- 复活
                if actionData.self_id == actionData.target_id then
                    local fighterCtrl = self.minorAction:FindFighter(actionData.target_id)
                    local reliveAction = ReliveAction.New(self.brocastCtx, fighterCtrl)
                    self.triggerEnd:AddAction(reliveAction)
                else
                    local fighterCtrl = self.minorAction:FindFighter(actionData.target_id)
                    local reliveAction = ReliveAction.New(self.brocastCtx, fighterCtrl)
                    self.triggerHit:AddAction(reliveAction)
                end
            end
        elseif chgData.change_type == 3 then -- 变身
            local fighterCtrl = self.minorAction:FindFighter(actionData.target_id)
            if fighterCtrl ~= nil then
                local transformer = TransformerAction.New(self.brocastCtx, fighterCtrl, chgData.change_val)
                self.triggerHit:AddAction(transformer)
            end
        -- elseif chgData.change_type == 9 then
        --     self.brocastCtx.controller.enterData.anger = chgData.change_val + self.brocastCtx.controller.enterData.anger
        end
    end
    local selfChgList = actionData.self_changes
    for _, chgData in ipairs(selfChgList) do
        if chgData.change_type == 2 then
            if chgData.change_val == 0 then -- 复活
                local fighterCtrl = self.minorAction:FindFighter(actionData.self_id)
                local reliveAction = ReliveAction.New(self.brocastCtx, fighterCtrl)
                self.triggerEnd:AddAction(reliveAction)
            end
        elseif chgData.change_type == 3 then -- 变身
            local fighterCtrl = self.minorAction:FindFighter(actionData.self_id)
            if fighterCtrl ~= nil then
                local transformer = TransformerAction.New(self.brocastCtx, fighterCtrl, chgData.change_val)
                self.triggerHit:AddAction(transformer)
            end
        -- elseif chgData.change_type == 9 then
        --     self.brocastCtx.controller.enterData.anger = chgData.change_val + self.brocastCtx.controller.enterData.anger
        end
    end
end


function CombatFloatMsgAction:Play()
    NoticeManager.Instance.dispatcher:Dispatch(self.msgdata)
    -- NoticeManager.Instance:FloatTipsByString(self.actionData.action_msg)
    self:OnActionEnd()
end

function CombatFloatMsgAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end
