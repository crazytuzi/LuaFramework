---
--- Created by R2D2.
--- DateTime: 2019/1/16 14:55
---
local model = {}

function model:InitData()
    self.NoticeData = {}
    self.NoticeKeyData = {}
    self.title = "Update Notice"

    for _, v in pairs(Config.db_welfare_notice_reward) do
        if v.name == self.title and v.state == 1 then
            local t = {}
            t["id"] = v.id
            t["reward"] = String2Table(v.reward)
            t["startTime"] = TimeManager.GetInstance():String2Time(v.start_time)
            t["endTime"] = TimeManager.GetInstance():String2Time(v.end_time)
            t["isReceived"] = false

            table.insert(self.NoticeData, t)
            self.NoticeKeyData[t.id] = t
        end
    end

    table.sort(self.NoticeData, function(a, b)
        return a.startTime < b.startTime
    end)
end

function model:Reset()
    self:InitData()
end

function model:SetInfo(id)
    if self.NoticeKeyData[id] then
        self.NoticeKeyData[id].isReceived = true
    end
end

function model:GetNoticeInfo()
    local time = TimeManager.GetInstance():GetServerTime()

    for i = 1, #self.NoticeData, 1 do
        if self.NoticeData[i].startTime <= time and self.NoticeData[i].endTime > time then
            return self.NoticeData[i]
        end
    end

    return nil
end

return model
