---
--- Created by R2D2.
--- DateTime: 2019/1/15 20:24
---

local model = {}

function model:InitData()

    self.CombatData = {}
    --用等级做Key方便设置查找数据，
    self.CombatKeyData = {}

    for _,v in pairs(Config.db_welfare_power_reward) do
        local t ={}
        t["power"] = v.power
        t["reward"] = String2Table(v.reward)
        t["reward2"] = String2Table(v.reward2)
        t["count"] = v.count
        t["remain"] = v.count
        t["chest"] = v.chest
        t["isReceived"] = false
        t["isLimited"] = v.count > 0
        
        table.insert(self.CombatData, t)
        self.CombatKeyData[t.power] = t
    end
end

function model:Reset()
    self:InitData()
end

function model:GetInfoData()
    local function sort(a, b)
        if a.isReceived == b.isReceived then
            return  a.power < b.power
        end

        return  not a.isReceived
    end

    table.sort(self.CombatData, sort)
    return self.CombatData
end

function model:Reward(power)
    if self.CombatKeyData[power] then
        self.CombatKeyData[power].isReceived = true
    end
end

function model:SetInfo(tab)
    for _, v in pairs(tab.power) do
        if self.CombatKeyData[v] then
            self.CombatKeyData[v].isReceived = true
        end
    end
    for k, v in pairs(tab.count) do
        if self.CombatKeyData[k] and self.CombatKeyData[k].count > 0 then
            self.CombatKeyData[k].remain = self.CombatKeyData[k].count - v
        end
    end
end

return model