-- 音效
SoundAction = SoundAction or BaseClass(CombatBaseAction)

function SoundAction:__init(brocastCtx, soundData)
    self.soundData = soundData
    self.soundId = soundData.sound_id
    self.firstAction = nil
    if soundData.delay_time ~= nil and soundData.delay_time > 0 and self.soundId > 0 then
        self.firstAction = DelayAction.New(self.brocastCtx, soundData.delay_time)
        self.firstAction:AddEvent(CombatEventType.End, function() self:DoPlay() end)
    end
end

function SoundAction:Play()
    if self.firstAction ~= nil then
        self.firstAction:Play()
    else
        self:DoPlay()
    end
end

function SoundAction:DoPlay()
    if self.soundId > 0 then
        if self.soundId < 800 then
            SoundManager.Instance:PlayCombatHit(self.soundId)
        else
            SoundManager.Instance:PlayCombat(self.soundId)
        end
    end
    self:OnActionEnd()
end

function SoundAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end
