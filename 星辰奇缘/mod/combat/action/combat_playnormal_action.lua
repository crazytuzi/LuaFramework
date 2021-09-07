-- 播放普通动作
PlayNormalAction = PlayNormalAction or BaseClass(CombatBaseAction)

-- timeout(秒)
function PlayNormalAction:__init(brocastCtx, fighterCtrl, action, timeout)
    self.fighterCtrl = fighterCtrl
    self.action = action
    self.timeout = timeout
end

function PlayNormalAction:Play()
    self.fighterCtrl:PlayAction(self.action)
    self:InvokeDelay(self.OnActionEnd, self.timeout, self)
end

function PlayNormalAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end
