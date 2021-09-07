-- 子播报负责链
MinorBaseHandler = MinorBaseHandler or BaseClass()

function MinorBaseHandler:__init(brocastCtx, minorAction, skillMotion)
    self.brocastCtx = brocastCtx
    self.minorAction = minorAction
    self.skillMotion = skillMotion

    self.resourceLoader = minorAction.resourceLoader
    self.triggerStart = minorAction.triggerStart
    self.triggerFollow = minorAction.triggerFollow
    self.triggerHit = minorAction.triggerHit
    self.triggerMultiHit = minorAction.triggerMultiHit
    self.triggerEnd = minorAction.triggerEnd
    self.triggerMoveEnd = minorAction.triggerMoveEnd
    self.endTaperSupporter = minorAction.endTaperSupporter
end

function MinorBaseHandler:Process()
    Logger.Error("你不应该看得到我")
end

function MinorBaseHandler:RegEffect(action, trigger)
    if trigger == EffectTrigger.ActionStart then
        self.minorAction.triggerStart:AddAction(action)
    elseif trigger == EffectTrigger.MultiHit then
        self.minorAction.triggerMultiHit:AddAction(action)
    elseif trigger == EffectTrigger.Hit then
        self.minorAction.triggerHit:AddAction(action)
    elseif trigger == EffectTrigger.MoveEnd then
        self.minorAction.triggerMoveEnd:AddAction(action)
    elseif trigger == EffectTrigger.ActionEnd then
        self.minorAction.triggerEnd:AddAction(action)
    elseif trigger == EffectTrigger.Follow then
        self.minorAction.triggerFollow:AddAction(action)
    end
end
