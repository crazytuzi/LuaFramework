--[[
    角色资源数据,主要用于角色的外观形象等
]]
LooksVo = LooksVo or BaseClass()
function LooksVo:__init()
    self.looks_type         = 0     -- 外观类型
    self.looks_mode         = 0     -- 外观子类型
    self.looks_val          = 0     -- 外观值
    self.looks_str          = ""    -- 外观附加串
end

function LooksVo:setAntVo(vo)
    if vo then
        for k, v in pairs(vo) do
            self:setAttrValue(k, v)
        end
    end
end

function LooksVo:setAttrValue(key, val)
    if self[key] ~= val then
        self[key] = val
    end
end

function LooksVo:getAttr(key)
    return self[key]
end

