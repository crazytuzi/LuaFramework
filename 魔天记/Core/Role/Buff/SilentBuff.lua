require "Core.Role.Buff.AbsBuff";

--沉默Buff
SilentBuff = class("SilentBuff", AbsBuff)

function SilentBuff:New(info, castRole)
    self = { };
    setmetatable(self, { __index = SilentBuff });
    self:_Init(info, castRole);
    return self;
end

function SilentBuff:_OnStartHandler()
    local role = self._role;
    if (role and (not role:IsDie())) then
        if (role.state == RoleState.SKILL) then
            role:StopAction(3);   
            role:Stand()
        end
        role.state = RoleState.SILENT;
    end
end


function SilentBuff:_OnStopHandler()
    local role = self._role;
    if (role) then
        role.state = RoleState.STAND;
    end
end