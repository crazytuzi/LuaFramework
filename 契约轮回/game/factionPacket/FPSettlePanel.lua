-- @Author: lwj
-- @Date:   2019-05-14 15:00:58
-- @Last Modified time: 2019-05-14 15:01:01

FPSettlePanel = FPSettlePanel or class("FPSettlePanel", BasePanel)
local FPSettlePanel = FPSettlePanel

function FPSettlePanel:ctor()
    self.abName = "factionPacket"
    self.assetName = "FPSettlePanel"
    self.layer = "UI"

    self.use_background = true
    self.model = FPacketModel.GetInstance()
end

function FPSettlePanel:dctor()

end

function FPSettlePanel:Open(is_settle, cf_data, ser_data)
    self.is_settle = is_settle
    self.cf_data = cf_data
    local limit = String2Table(self.cf_data.num)
    self.max = limit[2]
    self.min = limit[1]
    self.ser_data = ser_data
    FPSettlePanel.super.Open(self)
end

function FPSettlePanel:OpenCallBack()
end

function FPSettlePanel:LoadCallBack()
    self.nodes = {
        "Count_Bg/btn_reduce", "btn_send", "Des_Bg/des", "money_icon", "Count_Bg/btn_plus", "money", "Count_Bg/input", "btn_close", "Sum_Bg/sum",
        "Count_Bg/btn_reduce_gray",
        "input_count/btn_in_reduce_gray", "input_count/btn_in_plus", "input_count/btn_in_reduce", "input_count", "Des_Bg", "de_input/Placeholder", "de_input", "input_count/in_input", "de_input/Text", "bg_2", "Sum_Bg",
    }
    self:GetChildren(self.nodes)
    self.sum = GetText(self.sum)
    self.money_icon = GetImage(self.money_icon)
    self.money = GetText(self.money)
    self.des = GetText(self.des)
    self.input = GetText(self.input)

    self.in_input = GetText(self.in_input)
    self.place_hode = GetText(self.Placeholder)
    self.in_des = GetText(self.Text)

    self:AddEvent()
    self:InitPanel()
end

function FPSettlePanel:AddEvent()
    AddButtonEvent(self.btn_close.gameObject, handler(self, self.Close))

    local function callback()
        local cur_t = tonumber(self.input.text)
        if cur_t <= self.min then
            return
        end
        local final_t = cur_t - 1
        if final_t == self.min then
            self:ShowMinGray()
        end
        self.input.text = final_t
    end
    AddButtonEvent(self.btn_reduce.gameObject, callback)

    local function callback()
        local cur_t = tonumber(self.input.text)
        local cur_sum = tonumber(self.in_input.text)
        if cur_t >= self.max then
            Notify.ShowText(string.format(ConfigLanguage.FPacket.ReachTheMaxNum, self.max))
            return
        end
        local final_t = cur_t + 1
        if not self.is_settle and cur_sum < final_t then
            Notify.ShowText(ConfigLanguage.FPacket.CanNotGreaterThanSum)
            return
        end
        self:HideMinGray()
        self.input.text = final_t
    end
    AddButtonEvent(self.btn_plus.gameObject, callback)

    --输入金额按钮
    local function callback()
        local balan = RoleInfoModel.GetInstance():GetRoleValue(self.cf_data.item_id)
        local cur_t = self.in_input.text
        local final_t = cur_t + 1
        if balan < final_t then
            final_t = balan
            Notify.ShowText(ConfigLanguage.FPacket.ArriveMaxOfBalan)
        end
        SetVisible(self.btn_in_reduce_gray, false)
        SetVisible(self.btn_in_reduce, true)
        self.in_input.text = final_t
        self:SynchorSumShow()
    end
    AddButtonEvent(self.btn_in_plus.gameObject, callback)

    local function callback()
        local cur_t = tonumber(self.in_input.text)
        local final_t = cur_t - 1
        local num_t = tonumber(self.input.text)
        if final_t < num_t then
            self.input.text = final_t
            if tonumber(self.input.text) < 2 then
                self:ShowMinGray()
            end
        end
        if final_t < 2 then
            SetVisible(self.btn_in_reduce_gray, true)
            SetVisible(self.btn_in_reduce, false)
        end
        self.in_input.text = final_t
        self:SynchorSumShow()
    end
    AddButtonEvent(self.btn_in_reduce.gameObject, callback)

    local function callback()
        local numKeyPad = lua_panelMgr:GetPanelOrCreate(NumKeyPad, self.input, handler(self, self.ClickCheckInput), nil, nil, 3, -52.8, 113, handler(self, self.ClickCheckInput))
        numKeyPad:Open()
    end
    AddClickEvent(self.input.gameObject, callback)

    local function callback()
        local numKeyPad = lua_panelMgr:GetPanelOrCreate(NumKeyPad, self.in_input, handler(self, self.SumCheckInPut), nil, nil, 3, -52.8, 184.38, handler(self, self.SumCheckInPut))
        numKeyPad:Open()
    end
    AddClickEvent(self.in_input.gameObject, callback)

    local function callback()
        local sum = tonumber(self.in_input.text)
        local uid = 0
        local desc
        if self.in_des.text == "" then
            desc = self.place_hode.text
        else
            desc = self.in_des.text
        end
        if self.is_settle then
            sum = self.cf_data.money
            uid = self.ser_data.uid
            desc = self.des.text
        end
        self.model:Brocast(FPacketEvent.RequestSendFP, tonumber(self.input.text), uid, self.cf_data.id, sum, desc)
    end
    AddButtonEvent(self.btn_send.gameObject, callback)

    self.model_event = {}
    self.model_event[#self.model_event + 1] = self.model:AddListener(FPacketEvent.SuccessSendFP, handler(self, self.Close))
end

function FPSettlePanel:SumCheckInPut()
    local balan = RoleInfoModel.GetInstance():GetRoleValue(self.cf_data.item_id)
    local cur_t = tonumber(self.in_input.text)
    local is_show_count_gray = false
    if cur_t == self.min then
        self:ShowSumMinGray()
        is_show_count_gray = true
    elseif cur_t >= self.max then
        cur_t = self.max
        self:HideSumMinGray()
    else
        self:HideSumMinGray()
    end
    if balan < cur_t then
        cur_t = balan
    end
    if tonumber(self.input.text) > cur_t then
        self.input.text = cur_t
        if tonumber(self.input.text) == self.min then
            self:ShowMinGray()
        end
    end
    self.in_input.text = cur_t
    self:SynchorSumShow()
end

function FPSettlePanel:ClickCheckInput()
    local cur_t = tonumber(self.input.text)
    local final_t
    local sum_t = tonumber(self.in_input.text)
    if cur_t < self.min then
        final_t = self.min
        self:ShowMinGray()
        Notify.ShowText(string.format(ConfigLanguage.FPacket.ReachTheMinNum, self.min))
    elseif cur_t == self.min then
        self:ShowMinGray()
    elseif cur_t >= self.max then
        self:HideMinGray()
        final_t = self.max
        if not self.is_settle and final_t > sum_t then
            final_t = sum_t
        else
            Notify.ShowText(string.format(ConfigLanguage.FPacket.ReachTheMaxNum, self.max))
        end
    else
        if not self.is_settle and cur_t > sum_t then
            final_t = sum_t
        end
        self:HideMinGray()
    end
    if not final_t then
        final_t = cur_t
    end
    self.input.text = final_t
end

function FPSettlePanel:SynchorSumShow()
    self.money.text = self.in_input.text
end

function FPSettlePanel:InitPanel()
    self:ChangeStyle()
    if not self.is_settle then
        self:SynchorSumShow()
    end
    self.input.text = self.min
    if self.is_settle then
        --固定红包
        local mon = self.cf_data.money
        self.sum.text = mon
        self.money.text = mon
        self.des.text = self.cf_data.desc
    else
        self.place_hode.text = self.cf_data.desc
    end
    local icon_name = Config.db_item[self.cf_data.item_id].icon
    GoodIconUtil.GetInstance():CreateIcon(self, self.money_icon, tostring(icon_name), true)
end

function FPSettlePanel:ShowMinGray()
    SetVisible(self.btn_reduce_gray, true)
    SetVisible(self.btn_reduce, false)
end

function FPSettlePanel:HideMinGray()
    SetVisible(self.btn_reduce_gray, false)
    SetVisible(self.btn_reduce, true)
end

function FPSettlePanel:ChangeStyle()
    SetVisible(self.bg_2, not self.is_settle)
    SetVisible(self.de_input, not self.is_settle)
    SetVisible(self.Des_Bg, not self.is_settle)
    SetVisible(self.Sum_Bg, self.is_settle)
    SetVisible(self.input_count, not self.is_settle)
end

function FPSettlePanel:ShowSumMinGray()
    SetVisible(self.btn_in_reduce_gray, true)
    SetVisible(self.btn_in_reduce, false)
end

function FPSettlePanel:HideSumMinGray()
    SetVisible(self.btn_in_reduce_gray, false)
    SetVisible(self.btn_in_reduce, true)
end

function FPSettlePanel:CloseCallBack()
    for i, v in pairs(self.model_event) do
        self.model:RemoveListener(v)
    end
    self.model_event = {}
end


