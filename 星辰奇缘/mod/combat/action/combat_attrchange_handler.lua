-- 属性变化
AttrChangeHandler = AttrChangeHandler or BaseClass(MinorBaseHandler)

function AttrChangeHandler:__init(brocastCtx, minorAction, skillMotion)
    self.brocastCtx = brocastCtx
    self.minorAction = minorAction
    self.skillMotion = skillMotion

    self.actionList = minorAction.actionList
    self.triggerHit = minorAction.triggerHit
    self.triggerEnd = minorAction.triggerEnd
end

function AttrChangeHandler:Process()
    for _, actionData in ipairs(self.actionList) do
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
            --     if chgData.change_val > 0 then 
            --         self.brocastCtx.controller.enterData.anger = chgData.change_val + self.brocastCtx.controller.enterData.anger                
            --     end
            end
        end
    end
end
