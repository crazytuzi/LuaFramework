require "Core.Role.Buff.AbsBuff";

--属性百分比增加Buff
AttributePreAddBuff = class("AttributePreAddBuff", AbsBuff)

function AttributePreAddBuff:New(info, castRole)
    self = { };
    setmetatable(self, { __index = AttributePreAddBuff });
    self:_Init(info, castRole);
    self._attrName = info.para[1];
    self._value = info.para[2] / 100;
    return self;
end

function AttributePreAddBuff:_OnStartHandler()
    local role = self._role;
    if (role) then
        local v = role.info[self._attrName];
        self._attrValue = v * (1 + self._value) - v;
        role.info[self._attrName] = v + self._attrValue;
    end
end

function AttributePreAddBuff:_OnStopHandler()
    local role = self._role;
    if (role) then
        role.info[self._attrName] = role.info[self._attrName] - self._attrValue;
    end
end