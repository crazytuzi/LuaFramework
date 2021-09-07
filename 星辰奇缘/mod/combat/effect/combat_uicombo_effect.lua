-- 组合
UIComboEffect = UIComboEffect or BaseClass(CombatBaseAction)

function UIComboEffect:__init(brocastCtx, target)
    self.target = target
    self.syncAction = SyncSupporter.New(brocastCtx)
    self.awakeAction = SyncSupporter.New(brocastCtx)
    self.effectEndEvent = {}

    self.syncAction:AddEvent(CombatEventType.End, self.OnEffectEnd, self)
    self.awakeAction:AddEvent(CombatEventType.End, self.EndWake, self)
end

function UIComboEffect:AddAction(action)
    self.syncAction:AddAction(action)
end

function UIComboEffect:AddAwakdAction(action)
    self.awakeAction:AddAction(action)
end

function UIComboEffect:Play()
    self.awakeAction:Play()
end

function UIComboEffect:EndWake()
    if BaseUtils.isnull(self.target) then
        self:OnActionEnd()
        return
    end
    self.target:SetActive(true)
    self.syncAction:Play()
    self:OnActionEnd()
end

function UIComboEffect:AddEffectEndEvent(action)
    table.insert(self.effectEndEvent, action)
end

function UIComboEffect:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end

function UIComboEffect:OnEffectEnd()
    for _, func in ipairs(self.effectEndEvent) do
        func()
    end
end

