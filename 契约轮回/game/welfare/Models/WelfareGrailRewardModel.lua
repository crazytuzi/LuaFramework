---
--- Created by R2D2.
--- DateTime: 2019/1/17 14:36
---
local model = {}

function model:InitData()
    self["DoublePoint"] = 5
    self["Count"] = 0

    self.GrailData = {}

    for _, v in pairs(Config.db_welfare_grail_reward_exp) do
        local key = v.id
        local t = {}
        t["group"] = v.id
        t["count"] = v.count
        t["reward"] = String2Table(v.exp)

        if not self.GrailData[key] then
            self.GrailData[key] = {}
        end

        table.insert(self.GrailData[key], t)
    end

    for _, v in pairs(self.GrailData) do
        table.sort(v, function(a, b)
            return a.count < b.count
        end)
    end
end

function model:Reset()
    self:InitData()
    self.isHasGrail = nil
end

function model:Reward()
    self.isHasGrail = true
    self["Count"] = self["Count"] + 1
end

--剩余次数
function model:GetRemainCount()
    local data = self:GetGrailData()
    return #data - self.Count
end

function model:GetGroup(lv)
    for _, v in pairs(Config.db_welfare_grail_reward) do
        if lv >= v.down_line and lv <= v.up_line then
            return v.id
        end
    end

    return 0;
    --return Config.db_welfare_grail_reward[#Config.db_welfare_grail_reward].id
end

function model:GetGrailData()
    local lv = RoleInfoModel.GetInstance():GetMainRoleData().level
    local group = self:GetGroup(lv)
    if (group == 0) then
        return {}
    else
        return self.GrailData[group]

    end
end

function model:GetReachDoubleNum()
    local num = self.Count % self.DoublePoint
    return self.DoublePoint - num
end

--function model:GetRemainCount()
--    local data = self:GetGrailData()
--    return #data - self.Count
--end

function model:GetConsumable(num)
    local data
    if Config.db_welfare_grail_cost[num] then
        data = String2Table(Config.db_welfare_grail_cost[num].cost)
    else
        data = String2Table(Config.db_welfare_grail_cost[#Config.db_welfare_grail_cost].cost)
    end

    return data
end

return model
