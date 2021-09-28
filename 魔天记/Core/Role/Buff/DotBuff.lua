require "Core.Role.Buff.AbsBuff";

--持续伤害Buff
DotBuff = class("DotBuff", AbsBuff)

function DotBuff:New(info, castRole)
    self = { };
    setmetatable(self, { __index = DotBuff });
    self:_Init(info, castRole);
    return self;
end

function DotBuff:_OnStartHandler()
    local role = self._role;
    if (role) then
        --role.state = RoleState.STUN;        
    end
end


function DotBuff:_OnStopHandler()
    local role = self._role;
    if (role) then
        --role.state = RoleState.STAND;
    end
end