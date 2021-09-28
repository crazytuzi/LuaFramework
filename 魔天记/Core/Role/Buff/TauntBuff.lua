require "Core.Role.Buff.AbsBuff";

--嘲讽Buff
TauntBuff = class("TauntBuff", AbsBuff)

function TauntBuff:New(info, castRole)
    self = { };
    setmetatable(self, { __index = TauntBuff });
    self:_Init(info, castRole);
    return self;
end

function TauntBuff:_OnStartHandler()
    local role = self._role;
    if (role) then
        --role.state = RoleState.STUN;        
    end
end


function TauntBuff:_OnStopHandler()
    local role = self._role;
    if (role) then
        --role.state = RoleState.STAND;
    end
end