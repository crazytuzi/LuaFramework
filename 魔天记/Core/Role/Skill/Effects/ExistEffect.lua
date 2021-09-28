ExistEffect = class("ExistEffect")

function ExistEffect:New(skill, role)
    self = { };
    setmetatable(self, { __index = ExistEffect });
    self._role = role;
    self._info = skill.existEffect;
    self._delayTime = self._info.delayTime / 1000;
    self._totalTime = self._info.totalTime / 1000;
    self:_Init();
    return self;
end

function ExistEffect:_Init()
    local role = self._role;
    local info = self._info;
    if (role and info) then
        local scale = role.transform.localScale.x;
        self._effects = { }
        for i, v in pairs(self._info.pos) do
            local pos = role:GetHangingPoint(v);
            if (pos) then
                local eff = Resourcer.Get("Effect/SkillEffect", info.model);
                if (eff) then
                    eff:SetActive(false);
                    eff.transform:SetParent(pos);
                    Util.SetLocalPos(eff, 0, 0, 0)
                    -- 				eff.transform.localPosition = Vector3.zero;
                    UIUtil.ScaleParticleSystem(eff, scale);
                    self._effects[i] = eff;
                end
            end
        end
        self:_InitTimer();
        self:_OnTimerHandler();
    end
end

function ExistEffect:_InitTimer()
    if (self._timer) then
        self._timer = FixedTimer.New( function(val) self:_OnTimerHandler(val) end, 0, -1, false);
        self._timer:Start();
    end

end;

function ExistEffect:_OnTimerHandler()
    local role = self._role;
    if (role ~= nil and role.transform ~= nil and self._totalTime > 0) then
        self._totalTime = self._totalTime - Time.fixedDeltaTime;
        if (self._delayTime and self._delayTime > 0) then
            self._delayTime = self._delayTime - Time.fixedDeltaTime;
            if (self._delayTime <= 0) then
                if (self._effects) then
                    for i, v in pairs(self._effects) do
                        v:SetActive(true);
                    end
                end
                self._delayTime = nil;
            end
        end
    else
        self:Dispose();
    end
end

function ExistEffect:AddListener(func)
    self._callback = func;
end

function ExistEffect:Dispose()
    if (self._callback ~= nil) then
        self._callback(self);
        self._callback = nil;
    end
    if (self._timer ~= nil) then
        self._timer:Stop();
        self._timer = nil;
    end
    if (self._effects ~= nil) then
        for i, v in pairs(self._effects) do
            Resourcer.Recycle(v);
        end
        self._effects = nil;
    end
end