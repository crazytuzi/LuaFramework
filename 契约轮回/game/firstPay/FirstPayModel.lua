-- @Author: lwj
-- @Date:   2019-04-17 15:31:11
-- @Last Modified time: 2019-04-17 15:31:21

FirstPayModel = FirstPayModel or class("FirstPayModel", BaseBagModel)
local FirstPayModel = FirstPayModel

function FirstPayModel:ctor()
    FirstPayModel.Instance = self
    self:Reset()
end

function FirstPayModel:Reset()
    self.first_pay_info = nil
    self.cur_show_day = 1
    self.show_icon_this_time = false
    self.is_show_rd_once = true

    if FirstPayController.GetInstance().firstpaydime_lv_update_event_id then
        GlobalEvent:RemoveListener(FirstPayController.GetInstance().firstpaydime_lv_update_event_id)
        FirstPayController.GetInstance().firstpaydime_lv_update_event_id = nil
    end

    FirstPayController.GetInstance():RemoveLvBind()
end

function FirstPayModel.GetInstance()
    if FirstPayModel.Instance == nil then
        FirstPayModel()
    end
    return FirstPayModel.Instance
end

function FirstPayModel:SetInfo(info)
    self.first_pay_info = info
end

function FirstPayModel:IsFirstPay()
    if not self.first_pay_info then
        return false
    end
    return self.first_pay_info.is_payed
end

function FirstPayModel:GetDay()
    if not self.first_pay_info then
        return 0
    end
    return self.first_pay_info.day
end

function FirstPayModel:IsCanShowIcon()
    local result = true
    local day = self.first_pay_info.day
    if day >= 3 then
        if self:CheckIsRewarded(true, 3) then
            if not self.show_icon_this_time then
                result = false
            end
        end
    end
    return result
end

--是否已领取
function FirstPayModel:CheckIsRewarded(is_order, the_order)
    local result = false
    local order = self.cur_show_day
    if is_order then
        order = the_order
    end
    for i, v in pairs(self.first_pay_info.fetch) do
        if v == order then
            result = true
            break
        end
    end
    return result
end

function FirstPayModel:AddRewarded()
    self.first_pay_info.fetch[#self.first_pay_info.fetch + 1] = self.cur_show_day
end

--获取可以领取奖励的档位
function FirstPayModel:GetCanFetchGrade()
    local result
    for i = 1, 3 do
        if not self:CheckIsRewarded(true, i) then
            --未获取
            if self.first_pay_info.day >= i then
                result = i
                break
            end
        end
    end
    return result
end

--检查主界面红点
function FirstPayModel:CheckRD()
    local is_show = false
    if self:IsFirstPay() then
        local can_get_idx = self:GetCanFetchGrade()
        if can_get_idx then
            is_show = true
        end
    end
    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "firstPay", is_show)
    GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 28, is_show)
end

--当前档位是否可以领取
function FirstPayModel:IsCanFetch(day)
    local is_can_fetch = false
    if self:IsFirstPay() then
        if day <= self.first_pay_info.day then
            if not self:CheckIsRewarded(true, day) then
                --没有领取
                is_can_fetch = true
            end
        end
    end
    return is_can_fetch
end

---首充相关跳转特殊处理
--先首充，否则每日累充
function FirstPayModel:OpenFirstPayPanelOne()
    if self:IsCanShowIcon() then
        OpenLink(840, 1)
    else
        OpenLink(820, 1)
    end
end
