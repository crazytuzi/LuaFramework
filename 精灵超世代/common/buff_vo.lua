-- Created by IntelliJ IDEA.
-- User: lfl
-- Date: 2015/3/6
-- Time: 15:10
-- [[文件功能：buff的数据vo部分]]
BuffVo = BuffVo or BaseClass()
function BuffVo:__init()
    self.bid        = 0       --buff的bid
    self.duration   = 0       --持续数值
    self.count      = 0       --叠加数量
    self.effect     = {}      --额外效果
    self.exts       = {}      --扩展字段，用于特殊功能，当前用于天赋技能buff
end

function BuffVo:initVo(vo)
    if vo then
        for k, v in pairs(vo) do
            if k ~= "effect" then
                if k ~= "duration" then
                    self:setBuffValue(k, v)
                else
                    self["duration"] = v + GameNet:getInstance():getTime()
                end
            else
                self:setBuffEffect(v)
            end
        end
    end
end

function BuffVo:setBuffEffect(effect)
    if effect then
        for k, v in pairs(effect) do
            self.effect[v.key] = v.val
        end
    end
end

--获取buff效果的数量
function BuffVo:getEffectNum()
    local num = 0
    for k, v in pairs(self.effect) do
        num = num + 1
    end
    return num
end

function BuffVo:getBuffEffectByKey(key)
    local value = 0
    if self.effect then
        for k, v in pairs(self.effect) do
            if k == key then
                value = v
                break
            end
        end
    end
    return value
end

function BuffVo:setBuffValue(key, val)
    if self[key] ~= val then
        self[key] = val
    end
end


function BuffVo:getBuffValue(key)
    return self[key]
end


