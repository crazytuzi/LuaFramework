-- 公会加速冻结按钮
GuildSpeedFrozenButton = GuildSpeedFrozenButton or BaseClass()

function GuildSpeedFrozenButton:__init(buttonObj, setting)
    setting = setting or {}
    self.buttonObj = buttonObj
    self.transition = buttonObj:GetComponent(TransitionButton)
    self.button = buttonObj:GetComponent(Button)
    self.transitionEnabled = true
    self.buttonEnabled = true
    if self.transition ~= nil then
        self.transitionEnabled = self.transition.enabled
    end
    if self.button ~= nil then
        self.buttonEnabled = self.button.enabled
    end
    self.timer = 0
    self.image = buttonObj:GetComponent(Image)

    -- 超时时间
    self.timeout = setting.timeout or 5

    -- 该控件的状态
    self.enabled = self.buttonEnabled
end

function GuildSpeedFrozenButton:__delete()
    if self.timer ~= 0 then
        LuaTimer.Delete(self.timer)
    end
    self.buttonObj = nil
    self.transition = nil
end

function GuildSpeedFrozenButton:OnClick()
    if self.timer ~= 0 then
        LuaTimer.Delete(self.timer)
    end
    self.enabled = false
    self.timer = LuaTimer.Add(self.timeout * 1000, function() self:Release() end)
    if self.transition ~= nil then
        self.transition.enabled = false
    end
    if self.image ~= nil then

    end
    if self.button ~= nil then
        self.button.enabled = false
    end
end

function GuildSpeedFrozenButton:Release()
    if not self.enabled then
        if self.timer ~= 0 then
            LuaTimer.Delete(self.timer)
        end
        if self.image ~= nil then

        end
        if self.transition ~= nil then
            self.transition.enabled = self.transitionEnabled
        end
        if self.button ~= nil then
            self.button.enabled = self.buttonEnabled
        end
    end
    self.enabled = true
end
