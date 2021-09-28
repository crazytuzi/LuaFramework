require "Core.Role.Buff.AbsBuff";

--变身Buff
ChangeBuff = class("ChangeBuff", AbsBuff)

function ChangeBuff:New(info, castRole)
    self = { };
    setmetatable(self, { __index = ChangeBuff });
    self:_Init(info, castRole);
    return self;
end

function ChangeBuff:_OnStartHandler()
    local role = self._role;
    if (role) then
        --role.state = RoleState.SILENT;   
        self._roleInfo = role.info;
    end
end

function ChangeBuff:_OnStopHandler()
    local role = self._role;
    if (role) then
        role.info = self._roleInfo;        
    end
end