-- 特殊事件播报

CombatSpecialAction = CombatSpecialAction or BaseClass(CombatBaseAction)

function CombatSpecialAction:__init(brocastCtx, data)
    self.data = data
    self.fighter = self:FindFighter(data.id)

    self.syncSupporter = SyncSupporter.New(brocastCtx)
    self.syncSupporter:AddEvent(CombatEventType.End, self.OnActionEnd, self)
    self:Parse()
end

function CombatSpecialAction:Parse()
    local selfChgList = self.data.self_changes
    for _, chgData in ipairs(selfChgList) do
        if chgData.change_type == 2 then
            if chgData.change_val == 0 then -- 复活
                local reliveAction = ReliveAction.New(self.brocastCtx, self.fighter)
                self.syncSupporter:AddAction(reliveAction)
            end
        elseif chgData.change_type == 0 or chgData.change_type == 1 or chgData.change_type == 9 then
            local attrEffect = AttrChangeEffect.New(self.brocastCtx, {chgData}, self.data.id, false, 1, false)
            self.syncSupporter:AddAction(attrEffect)
        elseif chgData.change_type == 5 then -- 指挥
            local commandaction
            if chgData.change_val ~= 6 then
                commandaction = CommandUpdateAction.New(self.brocastCtx, {id = self.data.id ~= nil and self.data.id or self.data.tid, chgData = chgData.change_val})
            else
                commandaction = CommandUpdateAction.New(self.brocastCtx, {id = self.data.id ~= nil and self.data.id or self.data.tid, chgData = chgData.other_val})
            end
            self.syncSupporter:AddAction(commandaction)
        end
    end
end

function CombatSpecialAction:Play()
    self.syncSupporter:Play()
end

function CombatSpecialAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end
