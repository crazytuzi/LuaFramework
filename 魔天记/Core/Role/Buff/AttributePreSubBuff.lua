require "Core.Role.Buff.AbsBuff";

--属性百分比减少Buff
AttributePreSubBuff = class("AttributePreSubBuff", AbsBuff)

function AttributePreSubBuff:New(info, castRole)
    self = { };
    setmetatable(self, { __index = AttributePreSubBuff });
    self:_Init(info, castRole);
    self._attrName = info.para[1];
    self._value = info.para[2] / 100;
    return self;
end

function AttributePreSubBuff:_OnStartHandler()
    local role = self._role;
    if (role) then
        local v = role.info[self._attrName];
        self._attrValue = v * (1 - self._value) - v;
        role.info[self._attrName] = v + self._attrValue;
    end
end

function AttributePreSubBuff:_OnStopHandler()
    local role = self._role;
    if (role) then
        role.info[self._attrName] = role.info[self._attrName] - self._attrValue;
    end
end