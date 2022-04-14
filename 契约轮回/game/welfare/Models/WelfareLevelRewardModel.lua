---
--- Created by R2D2.
--- DateTime: 2019/1/15 14:44
---

local model = {}

function model:InitData()

    self.LevelData = {}
    --用等级做Key方便设置查找数据，
    self.LevelKeyData = {}

    for _, v in pairs(Config.db_welfare_level_reward) do
        local t = {}
        t["level"] = v.level
        t["reward"] = String2Table(v.reward)
        t["reward2"] = String2Table(v.reward2)
        t["count"] = v.count
        t["remain"] = v.count
        t["chest"] = v.chest
        t["isReceived"] = false
        t["isLimited"] = v.count > 0

        table.insert(self.LevelData, t)
        self.LevelKeyData[t.level] = t
    end
end

function model:Reset()
    self:InitData()
end

function model:GetBaseData()
    local tab = {}
    --for i, v in pairs(self.LevelKeyData) do
    --    tab[i] = v.isReceived
    --end

    for _, v in ipairs(self.LevelData) do
        table.insert(tab, { level = v.level, isReceived = v.isReceived })
    end

    table.sort(tab, function(a, b)
        return a.level < b.level
    end)
    return tab
end

function model:GetInfoData()

    local function sort(a, b)
        if a.isReceived == b.isReceived then
            return a.level < b.level
        end

        return not a.isReceived
    end

    table.sort(self.LevelData, sort)
    return self.LevelData
end

function model:Reward(level)
    if self.LevelKeyData[level] then
        self.LevelKeyData[level].isReceived = true
    end
end

function model:SetInfo(tab)
    for _, v in pairs(tab.level) do
        if self.LevelKeyData[v] then
            self.LevelKeyData[v].isReceived = true
        end
    end
    for k, v in pairs(tab.count) do
        if self.LevelKeyData[k] and self.LevelKeyData[k].count > 0 then
            self.LevelKeyData[k].remain = self.LevelKeyData[k].count - v
        end
    end

    local tab = self:GetBaseData()

    GlobalEvent:Brocast(WelfareEvent.Welfare_Global_LevelRewardDataEvent, tab);

end

return model