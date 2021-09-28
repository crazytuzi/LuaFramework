require "Core.Role.Buff.AbsBuff";

-- 定身Buff
StillBuff = class("StillBuff", AbsBuff)

function StillBuff:New(info, castRole)
    self = { };
    setmetatable(self, { __index = StillBuff });
    self:_Init(info, castRole);
    return self;
end

function StillBuff:_OnStartHandler()
    local role = self._role;
    if (role and (not role:IsDie())) then
        if (role.state == RoleState.MOVE) then
            role:StopAction(3);
            role:Stand();
        end
        role.state = RoleState.STILL;
    end
end

function StillBuff:_OnStopHandler()
    local role = self._role;
    if (role) then
        role.state = RoleState.STAND;
    end
end