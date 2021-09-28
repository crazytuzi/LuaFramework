require "Core.Role.Buff.AbsBuff";

--持续回复Buff
HealBuff = class("HealBuff", AbsBuff)

function HealBuff:New(info, castRole)
    self = { };
    setmetatable(self, { __index = HealBuff });
    self:_Init(info, castRole);
    return self;
end

function HealBuff:_OnStartHandler()
    local role = self._role;
    if (role) then
        --role.state = RoleState.STUN;        
    end
end

function HealBuff:_OnStopHandler()
    local role = self._role;
    if (role) then
        --role.state = RoleState.STAND;
    end
end