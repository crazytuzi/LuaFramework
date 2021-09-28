require "Core.Role.Buff.AbsBuff";

--切换普攻Buff
ForceBuff = class("ForceBuff", AbsBuff)

function ForceBuff:New(info, castRole)
    self = { };
    setmetatable(self, { __index = ForceBuff });
    self:_Init(info, castRole);
    return self;
end

function ForceBuff:_OnStartHandler()
    local role = self._role;    
    if (role and role.info) then
        role.info:ReplaceBaseSkill();
    end
end


function ForceBuff:_OnStopHandler()
    local role = self._role;
    
    if (role and role.info) then
        role.info:ResumeBaseSkill();
    end
end