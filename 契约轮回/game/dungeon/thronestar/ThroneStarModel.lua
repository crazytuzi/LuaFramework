---
--- Created by  Administrator
--- DateTime: 2020/3/31 17:27
---
ThroneStarModel = ThroneStarModel or class("ThroneStarModel", BaseModel)
local ThroneStarModel = ThroneStarModel

ThroneStarModel.sceneIds = {[1] = 80101 , [2] = 80102,  [3] = 80103 }
ThroneStarModel.actId = 12000
function ThroneStarModel:ctor()
    ThroneStarModel.Instance = self
    self:Reset()
end

--- 初始化或重置
function ThroneStarModel:Reset()
    self.bossInfos = {}
    self.throneBossTab = {}
    self.isLock = true
    self:SetBossTab()
end

function ThroneStarModel:GetInstance()
    if ThroneStarModel.Instance == nil then
        ThroneStarModel()
    end
    return ThroneStarModel.Instance
end

function ThroneStarModel:DealBossInfo(bossList)
    for i, v in pairs(bossList) do
        self.bossInfos[v.id] = v
    end
end

function ThroneStarModel:SetBossTab()
    local cfg = Config.db_throne_boss
    for i, v in pairs(cfg) do
        table.insert(self.throneBossTab, v);
        --local scene = v.scene
        --if not self.throneBossTab[scene] then
        --    self.throneBossTab = {}
        --end
        --table.insert(self.throneBossTab[scene], v);
    end
end