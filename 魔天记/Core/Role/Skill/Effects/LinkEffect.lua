LinkEffect = class("LinkEffect")
function LinkEffect:New(role, to, src)
    self = { };
    setmetatable(self, { __index = LinkEffect });
    self._role = role;
    self._to = to;
    self:_Init(src);
    return self;
end

function LinkEffect:_Init(src)
    self._effect = Resourcer.Get("Effect/SkillEffect", src);
    if (self._effect ~= nil) then
        self._effect.transform:SetParent(nil);
        self._effect:SetActive(true);
        self:_InitTimer();
        self:_OnTimerHandler();
    end
end

function LinkEffect:_InitTimer()
    if (self._timer == nil) then
        self._timer = Timer.New( function(val) self:_OnTimerHandler(val) end, 0, -1, false);
        self._timer:Start();
    end
    
end;

function LinkEffect:_OnTimerHandler()
    local role = self._role;
    local to = self._to;
    local effect = self._effect;
    if (role ~= nil and to ~= nil and role.transform ~= nil and to.transform ~= nil and(not role:IsDie()) and(not to:IsDie()) and effect ~= nil) then
        local pt1 = role:GetCenter().position;
        local pt2 = to:GetCenter().position;
        local d = Vector3.Distance2(pt1, pt2);

        effect.transform.localScale = Vector3.New(1, 1, d);
        Util.SetPos(effect, pt1.x, pt1.y, pt1.z)
        --        effect.transform.position = pt1;
        effect.transform:LookAt(pt2);
    else
        self:Dispose();
    end
end

function LinkEffect:AddListener(func)
    self._callback = func;
end

function LinkEffect:Dispose()
    if (self._callback ~= nil) then
        self._callback(self);
        self._callback = nil;
    end
    if (self._timer ~= nil) then
        self._timer:Stop();
        self._timer = nil;
    end
    if (self._effect ~= nil) then
        Resourcer.Recycle(self._effect);
        self._effect = nil;
    end
    self._role = nil;
    self._to = nil;
end