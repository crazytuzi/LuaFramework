-- @Author: lwj
-- @Date:   2019-03-07 19:32:36
-- @Last Modified time: 2019-09-28 14:41:18

CandyBuyPanel = CandyBuyPanel or class("CandyBuyPanel", BasePanel)
local CandyBuyPanel = CandyBuyPanel

function CandyBuyPanel:ctor()
    self.abName = "candy"
    self.assetName = "CandyBuyPanel"
    self.layer = "UI"

    self.cur_input = 1
    self.cur_remain = 0
    self.max_limit = 99
    self.single_cost_tbl = String2Table(Config.db_candyroom.buy_cost.val)
    self.balance_type = tonumber(self.single_cost_tbl[1])
    self.model = CandyModel.GetInstance()
end

function CandyBuyPanel:dctor()

end

function CandyBuyPanel:Open(remain)
    CandyBuyPanel.super.Open(self)
    self.cur_remain = remain
end

function CandyBuyPanel:LoadCallBack()
    self.nodes = {
        "buyBtn", "Count_Group/keypad", "btn_cancle", "Count_Group/plus_btn", "Count_Group/reduce_btn", "Count_Group/num", "allPrice",
        "static/stText", "money_icon",
        "Count_Group/btn_reuce_gray",
        "mask"
    }
    self:GetChildren(self.nodes)
    self.sum = GetText(self.allPrice)
    self.des = GetText(self.stText)
    self.text_num = GetText(self.num)
    self.money_icon = GetImage(self.money_icon)

    self:AddEvent()
    self:InitPanel()
end

function CandyBuyPanel:AddEvent()
    self.change_end_event_id = GlobalEvent:AddListener(EventName.ChangeSceneEnd, handler(self, self.Close))
    local function callback()
        local text_num = tonumber(self.text_num.text)
        local after_cal_num = text_num + 1
        if after_cal_num > self.max_limit then
            Notify.ShowText("You can't buy anymore")
        else
            local isEnough = self:CheckIsMoneyEnough(after_cal_num)
            if isEnough then
                self.cur_input = tonumber(after_cal_num)
                self.text_num.text = after_cal_num
                SetVisible(self.reduce_btn, true)
                self:CheckSumShow()
            end
        end
    end
    AddButtonEvent(self.plus_btn.gameObject, callback)

    local function callback()
        local text_num = tonumber(self.text_num.text)
        local after_cal_num = text_num - 1
        if after_cal_num > 0 then
            self.text_num.text = after_cal_num
            if after_cal_num == 1 then
                SetVisible(self.reduce_btn, false)
            end
            self.cur_input = tonumber(after_cal_num)
            self:CheckSumShow()
        end
    end
    AddButtonEvent(self.reduce_btn.gameObject, callback)

    local function callback()
        self.numKeyPad = lua_panelMgr:GetPanelOrCreate(NumKeyPad, self.num, handler(self, self.ClickCheckInput), handler(self, self.ClickCheckInput), handler(self, self.ClickCheckInput), 3, -60, 0)
        self.numKeyPad:Open()
    end
    AddClickEvent(self.num.gameObject, callback)

    local function callback()
        self:Close()
    end
    AddClickEvent(self.mask.gameObject, callback)
    AddButtonEvent(self.btn_cancle.gameObject, callback)

    local function callback()
        if self.cur_input ~= 0 then
            if self:CheckIsMoneyEnough(self.cur_input) then
                self.model:Brocast(CandyEvent.RequestBuyGiftCount, tonumber(self.cur_input))
            end
        else
            Notify.ShowText("Not enough diamond")
        end
    end
    AddButtonEvent(self.buyBtn.gameObject, callback)

    self.update_count_event_id = self.model:AddListener(CandyEvent.UpdateBuyCount, handler(self, self.UpdateByCountShow))
end

function CandyBuyPanel:ClickCheckInput()
    local roleBalance = RoleInfoModel:GetInstance():GetRoleValue(self.balance_type)
    local text_num = tonumber(self.text_num.text)
    local after_cal_sum = text_num * self.single_cost_tbl[2]
    local finalText = nil
    if roleBalance < after_cal_sum then
        local rest = roleBalance % self.single_cost_tbl[2]
        finalText = (roleBalance - rest) / self.single_cost_tbl[2]
    else
        finalText = text_num
    end
    if finalText > 99 then
        self.text_num.text = 99
        Notify.ShowText("You can't buy anymore")
    else
        self.text_num.text = finalText
    end
    self.cur_input = tonumber(self.text_num.text)
    self:CheckSumShow()
end

function CandyBuyPanel:InitPanel()
    GoodIconUtil.GetInstance():CreateIcon(self, self.money_icon, tostring(self.single_cost_tbl[1]), true)
    self:CheckRemainTextColor()
    self:CheckSumShow()
end

function CandyBuyPanel:CheckRemainTextColor()
    local cost_name = FreeGiftModel.GetInstance():GetMoneyTypeNameByItemId(self.single_cost_tbl[1])
    local remain_text_str = ""
    if self.cur_remain == 0 then
        remain_text_str = "<color=#e63232>0</color>"
    else
        remain_text_str = "<color=#478DC1>" .. self.cur_remain .. "</color>"
    end
    self.des.text = string.format(ConfigLanguage.Candy.BuyGiveGiftCountDes, remain_text_str, cost_name)
end

function CandyBuyPanel:CheckIsMoneyEnough(num)
    local isEnough = false
    local roleBalance = RoleInfoModel:GetInstance():GetRoleValue(self.balance_type)
    local after_cal_sum = self.single_cost_tbl[2] * num
    if after_cal_sum > roleBalance then
        isEnough = false
        if num - 1 == 1 then
            Notify.ShowText("Not enough diamond")
        else
            Notify.ShowText("You can't buy anymore with the diamonds you have")
        end
    else
        isEnough = true
    end
    return isEnough
end

function CandyBuyPanel:CheckSumShow()
    local roleBalance = RoleInfoModel:GetInstance():GetRoleValue(self.balance_type)
    local sum = self.single_cost_tbl[2] * self.cur_input
    if roleBalance < sum then
        SetColor(self.sum, 230, 50, 50, 255)
    else
        SetColor(self.sum, 71, 141, 193, 255)
    end
    self.sum.text = sum
end

function CandyBuyPanel:UpdateByCountShow(num)
    self.cur_remain = num
    self:CheckRemainTextColor()
    self:CheckSumShow()
end

function CandyBuyPanel:CloseCallBack()
    if self.change_end_event_id then
        GlobalEvent:RemoveListener(self.change_end_event_id)
        self.change_end_event_id = nil
    end
    if self.update_count_event_id then
        self.model:RemoveListener(self.update_count_event_id)
    end
    self.update_count_event_id = nil
end

