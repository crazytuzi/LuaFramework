---
--- Created by R2D2.
--- DateTime: 2019/1/16 19:34
---
local model = {}

function model:InitData()
    self.DownloadData = {}

    local value = Config.db_welfare_res_reward[1]
    local t = {}
    t["reward"] = String2Table(value.reward)
    t["isReceived"] = false

    table.insert(self.DownloadData, t)
end

function model:GetInfoData()
    return self.DownloadData[1]
end

function model:Reward()
    self.DownloadData[1].isReceived = true
end

return model