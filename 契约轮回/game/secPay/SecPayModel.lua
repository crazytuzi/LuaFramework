-- @Author: lwj
-- @Date:   2019-04-17 15:31:11
-- @Last Modified time: 2019-04-17 15:31:21

SecPayModel = SecPayModel or class("SecPayModel", BaseBagModel)
local SecPayModel = SecPayModel

function SecPayModel:ctor()
    SecPayModel.Instance = self
    self:Reset()
end

function SecPayModel:Reset()
    self.act_info = nil
    self.cur_show_day = 1
    self.show_icon_this_time = false
    self.cache_act_name = { "opdays_eight_" }
    self.show_icon_this_time_list = { [1] = false }

    self.sec_week_recha_id = 1
    self.cur_fetch_rewa_act_id = nil
    self.cur_fetch_rewa_day = nil
end

function SecPayModel.GetInstance()
    if SecPayModel.Instance == nil then
        SecPayModel()
    end
    return SecPayModel.Instance
end

function SecPayModel:SetInfo(info)
    self.act_info = info
end

function SecPayModel:IsFirstPay(id)
    local info = self.act_info[id]
    if not info then
        return false
    end
    return info.day ~= 0
end

function SecPayModel:GetDay(id)
    local day = 0
    local info = self.act_info[id]
    if not info then
        return day
    end
    return info.day
end

function SecPayModel:IsShowIconThisTime(id)
    return self.show_icon_this_time_list[id]
end

--第二周累充
function SecPayModel:IsCanShowIcon(id)
    local info = self.act_info[id]
    if not info then
        return
    end
    local result = true
    local opdays = LoginModel.GetInstance():GetOpenTime()
    local cf = Config.db_actpay[id]
    if not cf then
        logError("SecPayModel: actpay配置没有该id: ", id)
        return false
    end
    local need_day = cf.opdays
    if opdays >= need_day then
        local day = info.day
        if day >= 3 then
            if self:IsAllFetch(id) then
                if not self:IsShowIconThisTime(id) then
                    result = false
                end
            else
                result = true
            end
        end
        return result
    end
end

--是否已领取
function SecPayModel:CheckIsRewarded(day, id)
    local info = self.act_info[id]
    if not info then
        logError("SecPayModel: 没有该id的活动数据 :", id)
        return true
    end
    local result = false
    for i, v in pairs(info.fetch) do
        if v == day then
            result = true
            break
        end
    end
    return result
end

function SecPayModel:IsAllFetch(id)
    local info = self.act_info[id]
    if not info then
        logError("SecPayModel: 没有该id的活动数据 :", id)
        return true
    end
    if #info.fetch < 3 then
        return false
    end
    return true
end

function SecPayModel:AddRewarded(id, day)
    self.act_info[self.cur_fetch_rewa_act_id].fetch[#self.act_info[self.cur_fetch_rewa_act_id].fetch + 1] = self.cur_fetch_rewa_day
end

--获取可以领取奖励的档位
function SecPayModel:GetCanFetchGrade(id)
    local info = self.act_info[id]
    if not info then
        return
    end
    local result
    for i = 1, 3 do
        if not self:CheckIsRewarded(i, id) then
            --未获取
            if info.day >= i then
                result = i
                break
            end
        end
    end
    return result
end

--检查主界面红点
function SecPayModel:CheckRD(id, key, stronger_id)
    local is_show = false
    if self:IsFirstPay(id) then
        local can_get_idx = self:GetCanFetchGrade(id)
        if can_get_idx then
            is_show = true
        end
    end
    if key then
        GlobalEvent:Brocast(MainEvent.ChangeRedDot, key, is_show)
    end
    if stronger_id then
        GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, stronger_id, is_show)
    end
end

--当前档位是否可以领取
function SecPayModel:IsCanFetch(day, id)
    local info = self.act_info[id]
    if not info then
        return
    end
    local is_can_fetch = false
    if self:IsFirstPay(id) then
        if day <= info.day then
            if not self:CheckIsRewarded(day, id) then
                --没有领取
                is_can_fetch = true
            end
        end
    end
    return is_can_fetch
end

function SecPayModel:GetAnyRunningActId()
    return self.act_info[1].act_id
end