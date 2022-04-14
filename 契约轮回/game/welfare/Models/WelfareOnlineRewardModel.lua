---
--- Created by R2D2.
--- DateTime: 2019/1/14 16:55
---

local model = {}

function model:InitData()

    self.StartTime = 0
    --self.Second = 0
    self.OnLineData = {}

    for _, v in pairs(Config.db_welfare_online_reward) do
        local t = {}
        t["id"] = v.id
        t["reward"] = String2Table(v.reward)
        t["time"] = v.time
        t["isReceived"] = false
        t["endTime"] = TimeManager.Instance:GetServerTime() + v.time
        table.insert(self.OnLineData, t)
    end

    table.sort(self.OnLineData, function(c1, c2)
        return c1.id < c2.id
    end)
end

function model:Reset()
    self:InitData()
    self:StopSchedule()
end

function model:SetInfo(tab)
    --for _,v in  pairs( tab.ids) do
    --    if self.OnLineData[v] then
    --        self.OnLineData[v].isReceived = true
    --    end
    --end

    local serverTime = TimeManager.Instance:GetServerTime()

    self.StartTime = serverTime - tab.online_time

    --logError(  string.format("ServerTime = %s, OnlineTime = %s, StartTime = %s",serverTime , tab.online_time , self.StartTime ))

    for _, v in pairs(self.OnLineData) do
        if tab.ids[v.id] then
            v.isReceived = true
        else
            v.isReceived = false
            v.endTime = self.StartTime + v.time
        end
    end

    self:CheckSchedule()
end

function model:StopSchedule()
    if (self.schedule_id) then
        GlobalSchedule:Stop(self.schedule_id)
        self.schedule_id = nil
    end
end

function model:CheckSchedule()

    local serverTime = TimeManager.Instance:GetServerTime()
    local waitTime = 0
    for _, v in ipairs(self.OnLineData) do
        if (not v.isReceived) then
            if (serverTime < v.endTime) then
                waitTime = v.endTime - serverTime
                break
            end
        end
    end

    if (waitTime > 0) then
        self:StopSchedule()
        self:StartSchedule(waitTime + 1)
    end
end

function model:StartSchedule(waitTime)
    local function call_back()
        --logError("----------->  Welfare_OnlineLocalCountDownEvent ")
        GlobalEvent:Brocast(WelfareEvent.Welfare_OnlineLocalCountDownEvent)
        self:CheckSchedule()
    end
    self.schedule_id = GlobalSchedule:StartOnce(call_back, waitTime)
end

function model:OnlineReward(id)
    for _, v in pairs(self.OnLineData) do
        if v.id == id then
            v.isReceived = true
            break
        end
    end
end

--function model:SetTimeInfo(startTime, second)
--    self.StartTime = startTime
--    self.Second = second
--end

--function model:GetTotalSecond()
--    local currTime = TimeManager.Instance:GetServerTime()
--    return currTime - self.StartTime + self.Second
--end

--function model:IsReceived(id)
--    if self.OnLineData[id] then
--        return self.OnLineData.isReceived
--    end
--
--    return false
--end

function model:GetInfoData()
    return self.OnLineData
end

return model

