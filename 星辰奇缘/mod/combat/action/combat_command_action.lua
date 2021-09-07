-- 指挥更新播报
CommandUpdateAction = CommandUpdateAction or BaseClass(CombatBaseAction)
--commandData = {id = fighter_id,chgData = commandID}
function CommandUpdateAction:__init(brocastCtx, commandData)
    self.commandData = commandData
    if commandData.id == nil then
        self.targetCtrl = self.brocastCtx:FindFighter(self.commandData.tid)
    else
        self.targetCtrl = self.brocastCtx:FindFighter(self.commandData.id)
    end
end

function CommandUpdateAction:Play()
    -- if self.brocastCtx.controller.selfData.group == self.targetCtrl.fighterData.group then
    --     self:OnActionEnd()
    --     return
    -- end
    if self.commandData.id ~= nil then
        self.brocastCtx.controller.mainPanel.selectID = self.commandData.id
    else
        self.brocastCtx.controller.mainPanel.selectID = self.commandData.tid
    end
    self.brocastCtx.controller:SetCommand(self.commandData.chgData)
    self:OnActionEnd()
end

function CommandUpdateAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end
