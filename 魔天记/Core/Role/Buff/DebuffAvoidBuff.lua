require "Core.Role.Buff.AbsBuff";

--霸体Buff
DebuffAvoidBuff = class("DebuffAvoidBuff", AbsBuff)

function DebuffAvoidBuff:New(info, castRole)
    self = { };
    setmetatable(self, { __index = DebuffAvoidBuff });
    self:_Init(info, castRole);
    return self;
end

function DebuffAvoidBuff:_OnStartHandler()
    local role = self._role;
    if (role) then
        --role.state = RoleState.STUN;        
    end
end

function DebuffAvoidBuff:_OnStopHandler()
    local role = self._role;
    if (role) then
        --role.state = RoleState.STAND;
    end
end