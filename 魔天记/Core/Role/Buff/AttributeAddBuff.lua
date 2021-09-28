require "Core.Role.Buff.AbsBuff";

-- 属性绝对值增加Buff
AttributeAddBuff = class("AttributeAddBuff", AbsBuff)

function AttributeAddBuff:New(info, castRole)
    self = { };
    setmetatable(self, { __index = AttributeAddBuff });

    self:_Init(info, castRole);
    --self._para = string.split(info.para[1], "|")    
    self.attributs = {};
    for i,v in pairs(info.para) do
        local para = string.split(v, "|")
        self.attributs[para[1]] = tonumber(para[2])
    end
    return self;
end

function AttributeAddBuff:_OnStartHandler()
    local role = self._role;
    if (role) then
        --role.info:AddAttributeValue(self._para[1], tonumber(self._para[2]), true);
    end
end

function AttributeAddBuff:_OnStopHandler()
    local role = self._role;
    if (role) then
        --role.info:RemoveAttributeValue(self._para[1], tonumber(self._para[2]), true);
    end
end