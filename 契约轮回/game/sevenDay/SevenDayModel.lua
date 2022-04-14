---
--- Created by  Administrator
--- DateTime: 2019/3/11 11:03
---
SevenDayModel = SevenDayModel or class("SevenDayModel", BaseBagModel)
local SevenDayModel = SevenDayModel

function SevenDayModel:ctor()
    SevenDayModel.Instance = self
    self:Reset()
end

--- 初始化或重置
function SevenDayModel:Reset()
    self.dayNums = nil-- 累计登录天数
    self.rewardDays = nil --已经领奖的天数
    self.isReLoad = false
    self.redPoints = {}
    self.firstOpen = true
end

function SevenDayModel:GetInstance()
    if SevenDayModel.Instance == nil then
        SevenDayModel()
    end
    return SevenDayModel.Instance
end


--设置选中的天数
function SevenDayModel:SetSeleteDay()
    local day = 1
    if self.dayNums <= #self.rewardDays then -- 当前没有可领取的天数
        day = self.dayNums
    else  --有未领奖的天数
       -- table.isempty()
        table.sort(self.rewardDays)
        if #self.rewardDays == 1 then
            if self.rewardDays[1] == 1 then
                day = self.rewardDays[1] +1
            else
                day = 1
            end

        elseif #self.rewardDays == 0 then
            day = 1
        else
            day = self.rewardDays[#self.rewardDays] + 1
            for i = 1, #self.rewardDays do
                if i == #self.rewardDays then
                    break
                end
                if self.rewardDays[i] < self.rewardDays[i+1] - 1 then
                    day = self.rewardDays[i] + 1
                    break
                end
            end

        end
    end
    return day

end


--当前天是否已经领取
function SevenDayModel:IsGetReward(day)
    local isBol = false
    for i, v in pairs(self.rewardDays) do
        if v == day then
            isBol = true
            break
        end
    end
    return isBol
end
--获取累计登录天数
function SevenDayModel:GetDayNum()
    return self.dayNums or 0
end