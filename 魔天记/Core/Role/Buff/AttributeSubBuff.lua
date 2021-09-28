require "Core.Role.Buff.AbsBuff";

--属性绝对值减少Buff
AttributeSubBuff = class("AttributeSubBuff", AbsBuff)

function AttributeSubBuff:New(info, castRole)
    self = { };
    setmetatable(self, { __index = AttributeSubBuff });
    self:_Init(info, castRole);
    self._attrName = info.para[1];
    self._value = info.para[2];
    return self;
end

function AttributeSubBuff:_OnStartHandler()
    local role = self._role;
    if (role) then
        role.info[self._attrName] = role.info[self._attrName] - self._value
    end
end

function AttributeSubBuff:_OnStopHandler()
    local role = self._role;
    if (role) then
        role.info[self._attrName] = role.info[self._attrName] + self._value
    end
end