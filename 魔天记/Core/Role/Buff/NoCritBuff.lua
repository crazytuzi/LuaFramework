require "Core.Role.Buff.AbsBuff";

--暴击压制Buff
NoCritBuff = class("NoCritBuff", AbsBuff)

function NoCritBuff:New(info, castRole)
    self = { };
    setmetatable(self, { __index = NoCritBuff });
    self:_Init(info, castRole);
    return self;
end

function NoCritBuff:_OnStartHandler()
    local role = self._role;
    if (role) then
        --role.state = RoleState.SILENT;        
    end
end


function NoCritBuff:_OnStopHandler()
    local role = self._role;
    if (role) then
        --role.state = RoleState.STAND;
    end
end