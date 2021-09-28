require "Core.Role.Buff.AbsBuff";

-- 晕眩Buff
StunBuff = class("StunBuff", AbsBuff)

function StunBuff:New(info, castRole)
    self = { };
    setmetatable(self, { __index = StunBuff });
    self:_Init(info, castRole);
    return self;
end

function StunBuff:_OnStartHandler()
    local role = self._role;
    if (role and (not role:IsDie())) then
        role:StopAction(3);        
        role.state = RoleState.STUN;
    end
end


function StunBuff:_OnStopHandler()
    local role = self._role;
    if (role) then
        role.state = RoleState.STAND;
    end
end