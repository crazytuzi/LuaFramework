---
--- Created by  Administrator
--- DateTime: 2020/6/2 16:38
---
LuckyWheelModel = LuckyWheelModel or class("LuckyWheelModel", BaseModel)
local LuckyWheelModel = LuckyWheelModel

LuckyWheelModel.maxRoundNum = 8
LuckyWheelModel.help =
[[
    1、Spend diamonds to spin the wheel to get abundant diamonds
    2、Raise the lvl of VIP and can get more times to spin the wheel
    3. It won’t increase VIP exp when spend diamonds in lucky wheel
    4.It won’t increase myth points of mythical plunder when spend diamonds in lucky wheel
    5.on't increase VIP exp and won't count in other Total Top Up events and Consume events either

]]

function LuckyWheelModel:ctor()
    LuckyWheelModel.Instance = self
    self:Reset()
end

--- 初始化或重置
function LuckyWheelModel:Reset()
    self.round = 0
    self.act_id = 0
    self.roundIndex = 0
end

function LuckyWheelModel:GetInstance()
    if LuckyWheelModel.Instance == nil then
        LuckyWheelModel()
    end
    return LuckyWheelModel.Instance
end

function LuckyWheelModel:DealInfo(data)
    self.round = data.round
    --if self.round >= self:GetMaxRound() then
    --    self.round = self.round - 1
    --end
    self.act_id = data.act_id
  --  self.roundIndex = table.nums(data.fetch)
end

function LuckyWheelModel:DealTurnInfo(data)
    if data.type == 0 then
        self:Brocast(LuckyWheelEvent.LuckyWheelReadyTurnInfo,data)
    else
        self.round = self.round + 1
        --if self.round > self:GetMaxRound() then
        --    self.round = self:GetMaxRound()
        --end
        self:Brocast(LuckyWheelEvent.LuckyWheelTurnInfo,data)
    end
end

function LuckyWheelModel:GetImageName(index)
    local round = self.round
    if round > self:GetMaxRound() then
        round = self:GetMaxRound()
    end
    local key = round.."@"..self.act_id
    local cfg = Config.db_yunying_luckywheel[key]
    local imgTab = String2Table(cfg.icon)
    for i = 1, #imgTab do
        if index == i then
            return imgTab[i][1]
        end
    end
    return nil
end

function LuckyWheelModel:GetdimNum(index,round)
    local key = round.."@"..self.act_id
    local cfg = Config.db_yunying_luckywheel[key]
    local rewardTab = String2Table(cfg.reward)
    for i = 1, #rewardTab do
        if index == rewardTab[i][1] then
            return rewardTab[i][2]
        end
    end
    return nil
end


function LuckyWheelModel:GetMaxNum(tab)
    local max = tab[1][2]
    for i = 2, #tab do
        if max < tab[i][2] then
            max = tab[i][2]
        end
    end
    return max
end


function LuckyWheelModel:GetMaxRound()
    local cfg = Config.db_game["luckluck"]
    local numTab = String2Table(cfg.val)[1]
    return numTab

end



