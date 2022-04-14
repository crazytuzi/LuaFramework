---
--- Created by R2D2.
--- DateTime: 2019/1/19 11:45
---
NoticeModel = NoticeModel or class("NoticeModel", BaseModel)
local NoticeModel = NoticeModel

function NoticeModel:ctor()
    NoticeModel.Instance = self

    self:InitData()
end

function NoticeModel:InitData()

    self.NoticeData = {}

    local currTime = TimeManager.GetInstance():GetClient()
    local startTime, endTime

    for _, v in pairs(Config.db_welfare_notice_reward) do
        if v.state == 1 then
            startTime = TimeManager.GetInstance():String2Time(v.start_time)
            endTime = TimeManager.GetInstance():String2Time(v.end_time)

            if startTime <= currTime and endTime > currTime then
                table.insert(self.NoticeData, v)
            end
        end
    end

    table.sort(self.NoticeData, function(a, b)
        return a.id < b.id
    end)
end

--- 初始化或重置
function NoticeModel:Reset()
    self.OnlineNotice = nil
end

function NoticeModel:HasNotice()
    if self.OnlineNotice ~= nil and #self.OnlineNotice > 0 then
        return true
    end

    return false
end

function NoticeModel:SetOnlineNotice(tab)
    self.OnlineNotice = tab
end

function NoticeModel:GetInstance()
    if NoticeModel.Instance == nil then
        NoticeModel()
    end
    return NoticeModel.Instance
end