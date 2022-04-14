---
--- Created by  Administrator
--- DateTime: 2020/4/13 16:52
---
RichManModel = RichManModel or class("RichManModel", BaseModel)
local RichManModel = RichManModel

RichManModel.GridCount = 36
RichManModel.touzi = 13200
RichManModel.ykTouzi = 13201

function RichManModel:ctor()
    RichManModel.Instance = self
    self:Reset()
end

--- 初始化或重置
function RichManModel:Reset()
    self.curRound = 0
    self.curGrid =  0
    self.hasLuck = 0
    self.luckyRound = 0
    self.diceGain = {}
    self.touziNum = 0
    self.roundFetch = {}
    self.RoundReward = {}
    self.redPoints = {}
    self.diceMend = 0
    self.diceGineNums = 0  --骰子获取的总数量
    self.isOpenPanel = false
    self.actId = 100002
    self.afterDiceGineNums = 0
    --self:InitRoundReward()
    --self:GetTouZiNum()
end

function RichManModel:GetInstance()
    if RichManModel.Instance == nil then
        RichManModel()
    end
    return RichManModel.Instance
end

function RichManModel:InitRoundReward()
    local cfg = Config.db_yunying_richman_round
    for i = 1, #cfg do
        if not self.RoundReward[cfg.round] then
            self.RoundReward[cfg.round] = 1
        end
    end
end


function RichManModel:GetGridInfo(round)
    local tab =  {}
    local cfg = Config.db_yunying_richman
    for i = 1, RichManModel.GridCount do
        local key = self.actId.."@"..round.."@"..i
        table.insert(tab,cfg[key])
    end
    return tab
end

function RichManModel:GetTouZiNum(day)
    local cfg = Config.db_game["richman_dice_limit"]
    local numTab = String2Table(cfg.val)[1]
    --self.touziNum = 0
    for i = 1, #numTab do
        if day == numTab[i][1] then
            return numTab[i][2]
        end
    end
    return 0
end

function RichManModel:GetTouZiPrice(num)
    local cfg = Config.db_game["richman_dice_mend"]
    local numTab = String2Table(cfg.val)[1]
    --self.touziNum = 0
    for i = 1, #numTab do
        if num == numTab[i][1] then
            return numTab[i][2]
        end
    end
    return 0
end

--补签的数量
function RichManModel:GetMendTimes()
    local openData = OperateModel:GetInstance():GetAct(self.actId)
    local sTime = openData.act_stime
    local curDay = TimeManager:GetInstance():GetDifDay(os.time(),sTime)
    local dayNum = 0
    if curDay > 0 then
        for i = 1, curDay do
           -- local index = self.diceGain[i] or  0
            --dayNum = dayNum + (self:GetTouZiNum(i) - index)
            dayNum = dayNum + self:GetTouZiNum(i)
        end
    end
    return dayNum - self.afterDiceGineNums
    --local curTime =
    --self.curDay = TimeManager:GetInstance():GetDifDay(os.time(),sTime)
end

--领取骰子的总数量
function RichManModel:SetDiceGineNums()
    self.diceGineNums = 0
    for i, v in pairs(self.diceGain) do
        if i~= -1 then
            self.diceGineNums = self.diceGineNums + v
        end

    end
end

function RichManModel:SetAfterDayDiceGineNums()
    local openData = OperateModel:GetInstance():GetAct(self.actId)
    if not openData then
        return
    end
    local sTime = openData.act_stime
    local curDay = TimeManager:GetInstance():GetDifDay(os.time(),sTime)
    self.afterDiceGineNums = 0
    for i, v in pairs(self.diceGain) do
        if i <= curDay  and i ~= -1 then
            self.afterDiceGineNums =  self.afterDiceGineNums + v
        end
    end
end


--需要补签的数量
function RichManModel:GetNeedMendNum()
    return self:GetMendTimes()
end




function RichManModel:CheckRedPoint()
    self.redPoints[1] = false --骰子数
    self.redPoints[2] = false --补签
    self.redPoints[3] = false --圈数奖励
    self.redPoints[4] = false --充值领取
    local yktouziNum = BagModel:GetInstance():GetItemNumByItemID(self.ykTouzi) or 0
    local touziNum = BagModel:GetInstance():GetItemNumByItemID(self.touzi) or 0
    if yktouziNum > 0 or touziNum > 0 then
        self.redPoints[1] = true
    end

    local openData = OperateModel:GetInstance():GetAct(self.actId)
    if openData then
        if self:GetNeedMendNum() > 0 and self.isOpenPanel == false  then
            self.redPoints[2] = true
        end
    end
    --if self.isOpenPanel == false then
    --    self.redPoints[2] = true
    --end




    local idTab = {}
    if not table.isempty(self.roundFetch) then
        for i = 1, #self.roundFetch  do
            local id = self.roundFetch[i]
            idTab[id] = true

        end
    end

    local cfg = Config.db_yunying_richman_round
    
    for i = 1, #cfg do
        if  cfg[i].actid == self.actId and self.curRound > cfg[i].round and not idTab[cfg[i].round] then
            self.redPoints[3] = true
        end
    end

    local info = OperateModel:GetInstance():GetActInfo(self.actId + 1)
    if info then
        for i = 1, #info.tasks do
            if info.tasks[i].state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then --已完成
                self.redPoints[4] = true
                break
            end
        end
    end
    local isRed = false
    for i, v in pairs(self.redPoints) do
        if v == true then
            isRed = true
            break
        end
    end
    OperateModel:GetInstance():UpdateIconReddot(self.actId,isRed)
    self:Brocast(RichManEvent.RichManCheckRedPoint)
end



