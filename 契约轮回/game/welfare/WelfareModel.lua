---
--- Created by R2D2.
--- DateTime: 2019/1/8 15:06
---

WelfareModel = WelfareModel or class("WelfareModel", BaseModel)
local WelfareModel = WelfareModel

local OnlineModel = require('game.welfare.Models.WelfareOnlineRewardModel')
local LevelModel = require('game.welfare.Models.WelfareLevelRewardModel')
local PowerModel = require('game.welfare.Models.WelfarePowerRewardModel')
local NoticeModel = require('game.welfare.Models.WelfareNoticeRewardModel')
local DownloadModel = require('game.welfare.Models.WelfareDownloadRewardModel')
local GrailModel = require('game.welfare.Models.WelfareGrailRewardModel')

function WelfareModel:ctor()
    WelfareModel.Instance = self

    OnlineModel:InitData()
    LevelModel:InitData()
    PowerModel:InitData()
    NoticeModel:InitData()
    DownloadModel:InitData()
    GrailModel:InitData()

    self:BindRedPointFunc()

end

--- 初始化或重置
function WelfareModel:Reset()

    if (self.signInfo) then
        self.signInfo = nil
    end

    OnlineModel:Reset()
    LevelModel:Reset()
    PowerModel:Reset()
    NoticeModel:Reset()
    GrailModel:Reset()
end

function WelfareModel:GetInstance()
    if WelfareModel.Instance == nil then
        WelfareModel()
    end
    return WelfareModel.Instance
end

function WelfareModel:GetOnlineModel()
    return OnlineModel
end

function WelfareModel:GetLevelModel()
    return LevelModel
end

function WelfareModel:GetPowerModel()
    return PowerModel
end

function WelfareModel:GetNoticeModel()
    return NoticeModel
end

function WelfareModel:GetDownloadModel()
    return DownloadModel
end

function WelfareModel:GetGrailModel()
    return GrailModel
end

--剩余补签次数
function WelfareModel:GetRemainTimes()
    if self.signInfo then
        local vipKey = "vip" .. RoleInfoModel:GetInstance():GetMainRoleVipLevel()  --RoleInfoModel.GetInstance():GetMainRoleData().viplv
        local num = tonumber(Config.db_vip_rights[17][vipKey])
        if not num then
            return 0
        end

        return math.max(num - self.signInfo.count, 0)
    end
    return 0
end

--福利类型标签列表（有些标签可能不需要显示）
function WelfareModel:GetWelfareType(sidebar_data)
    local tab1 = {}
  
    self.welfareTypeTab = {}

    for _, v in pairs(Config.db_welfare_type) do
        if v.isShow == 1 and self:CheckWelfareType(v.id) then
            table.insert(tab1, v)
        end
    end

    if sidebar_data then
        local tab2 = {}

        for _, v in ipairs(tab1) do
            local id, _ = math.modf( v.id / 100)
            local info = sidebar_data[id]

            if info then
                local level = info.show_lv or 1
                local task = info.show_task or 0

                if info.show_func then
                    if info.show_func() then
                       table.insert(tab2, v )
                    end
                elseif IsOpenModular(level, task) then
                    table.insert(tab2, v )
                end
            else
                table.insert(tab2, v )
            end
        end

        self.welfareTypeTab = tab2

    else        
        self.welfareTypeTab = tab1
    end  

    table.sort(self.welfareTypeTab, function(tab1, tab2)
        return tab1.order < tab2.order
    end)

    return self.welfareTypeTab
end

function WelfareModel:CheckWelfareType(typeId)
    if (typeId == 700) then
        return not DownloadModel:GetInfoData().isReceived
    -- elseif (typeId == 800) and PlatformManager:GetInstance():IsIos() then
    elseif (typeId == 800) and LoginModel.IsIOSExamine then
        return false
    else
        return true
    end
end

function WelfareModel:SetSignData(data)

    if self.signInfo then

        local tempSignInfo = self.signInfo
        self.signInfo = data

        --是不是补签
        local isSupplement = not tempSignInfo.is_sign

        if tempSignInfo.signs < self.signInfo.signs then
            GlobalEvent:Brocast(WelfareEvent.Welfare_SignedEvent, isSupplement);
        end

    else
        self.signInfo = data
        GlobalEvent:Brocast(WelfareEvent.Welfare_SignDataEvent, data)
    end
end

function WelfareModel:UpdateDailyValue(value)
    self.DailyValue = value
end

function WelfareModel:GetSupplementActiveValue()
    local id = self.signInfo.count + 1
    local cfg = Config.db_welfare_sign_count[id]
    if (not cfg) then
        cfg = Config.db_welfare_sign_count[#Config.db_welfare_sign_count]
    end
    return cfg.active
end

---签到配置
function WelfareModel:GetSignRewardConfig()
    local signs = self.signInfo.signs == 0 and 1 or self.signInfo.signs
    if not self.signInfo.is_sign then
        signs = signs == 28 and 29 or signs
    end
    local id = math.min(signs, self.signInfo.max_days)
    local cfg = Config.db_welfare_sign_reward[id]

    return cfg
end

---签到奖品列表
function WelfareModel:GetSignRewardList()

    local cfg = self:GetSignRewardConfig()
    local group = cfg.month

    self.signRewardTab = {}

    for _, v in pairs(Config.db_welfare_sign_reward) do
        if v.month == group then
            table.insert(self.signRewardTab, v)
        end
    end

    table.sort(self.signRewardTab, function(tab1, tab2)
        return tab1.day < tab2.day
    end)

    return self.signRewardTab
end
--
----签到奖品列表
--function WelfareModel:GetSignReward(month)
--    self.signRewardTab = {}
--
--    for _, v in pairs(Config.db_welfare_sign_reward) do
--        if v.month == month then
--            table.insert(self.signRewardTab, v)
--        end
--    end
--
--    table.sort(self.signRewardTab, function(tab1, tab2)
--        return tab1.day < tab2.day
--    end)
--
--    return self.signRewardTab
--end
----------红点相关----------

function WelfareModel:BindRedPointFunc()
    self.RedPointFuncList = {}
    self.RedPointFuncList[100] = handler(self, self.HasOnlineReward)
    self.RedPointFuncList[200] = handler(self, self.HasSign)
    self.RedPointFuncList[300] = handler(self, self.HasLevelReward)
    self.RedPointFuncList[400] = handler(self, self.HadPowerReward)
    self.RedPointFuncList[500] = handler(self, self.HadGrailTimes)
end

function WelfareModel:GetRedPointByType(typeId)
    if (self.RedPointFuncList and self.RedPointFuncList[typeId]) then
        return self.RedPointFuncList[typeId]()
    else
        return false
    end
end

---在线奖励有无可领取
function WelfareModel:HasOnlineReward()
    local infoData = OnlineModel:GetInfoData()
    local serverTime = TimeManager.Instance:GetServerTime()
    for _, v in ipairs(infoData) do
        if (not v.isReceived) then
            if (v.endTime <= serverTime) then
                return true
            end
        end
    end

    return false
end

---是否可以签到
function WelfareModel:HasSign()
    if(not self.signInfo) then
        print("<color=#ff0000>-----------> sign info is nil</color>")
        return false
    end

    return (not self.signInfo.is_sign)
end

---是否有等级奖励
function WelfareModel:HasLevelReward()
    local infoData = LevelModel:GetInfoData()
    local lv = RoleInfoModel:GetInstance():GetRoleValue("level")

    for _, v in ipairs(infoData) do
        if (not v.isReceived) then
            if (v.level <= lv) then

                if v.count == 0 then
                    return true
                else
                    return v.remain > 0
                end

            end
        end
    end

    return false
end

---是否有战力奖励
function WelfareModel:HadPowerReward()
    local infoData = PowerModel:GetInfoData()
    local power = RoleInfoModel:GetInstance():GetRoleValue("power") or 0

    for _, v in ipairs(infoData) do
        if (not v.isReceived) then
            if (v.power <= power) then
                if v.count == 0 then
                    return true
                else
                    return v.remain > 0
                end
            end
        end
    end

    return false
end

function WelfareModel:CheckGrailTimes()
    local isOpen = OpenTipModel:GetInstance():IsOpenSystem(500,5)
    if(not isOpen) then
        return false
    end

    local count = GrailModel:GetRemainCount()
    if count <=0 then
        return false
    end

    return true
end

---有无可用的祈祷次数
function WelfareModel:HadGrailTimes()
    local isOpen = OpenTipModel:GetInstance():IsOpenSystem(500,5)
    if(not isOpen) then
        return false
    end

    local count = GrailModel:GetRemainCount()
    if count <= 0 then
        return false
    end

    if GrailModel.isHasGrail then
        return false
    end

    local num =  GrailModel.Count
    local costData = GrailModel:GetConsumable(num + 1)
    return costData[1][2] == 0
    --return self:CheckGoods(costData)
end


function WelfareModel:CheckGoods(goods)

    for _, v in ipairs(goods) do
        local num = BagModel:GetInstance():GetItemNumByItemID(v[1])
        if (num < v[2]) then
            return false
        end
    end

    return true
end

---有无任意红点
function WelfareModel:AnyRedPoint()
    return self:HasOnlineReward() or self:HasSign() or self:HasLevelReward() or
            self:HadPowerReward() or self:HadGrailTimes()
end

---变强用点刷新
function WelfareModel:RefreshStrongRedPoint()
    GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 33, self:HasOnlineReward())
    GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 34, self:HasSign())
    GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 35, self:HasLevelReward())
    GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 36, self:HadPowerReward())
end

---主界面刷新
function WelfareModel:RefreshMainRedPoint()
    self:RefreshStrongRedPoint()

    local isShow = self:AnyRedPoint()
    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "welfare", isShow)
end