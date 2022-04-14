-- @Author: lwj
-- @Date:   2019-04-17 15:29:32
-- @Last Modified time: 2019-05-21 21:52:02


FirstPayPanel = FirstPayPanel or class("FirstPayPanel", BasePanel)
local FirstPayPanel = FirstPayPanel

function FirstPayPanel:ctor()
    self.abName = "firstPay"
    self.assetName = "FirstPayPanel"
    self.layer = "UI"

    self.model = FirstPayModel.GetInstance()
    self.btn_mode = 0       --0:前往充值   1:可领取    2:已领取   3:not today
    self.last_grade = nil
    self.next_grade = nil
    self.cur_time = 0
    self.eft_show_time = 1.2
    self.model_y = 8
    self.model_x = -4008
    self.model_z = 363
    self.day_item_list = {}

    self.panel_type = 2
    self.is_hide_other_panel = true
end

function FirstPayPanel:dctor()

end

function FirstPayPanel:Open(time)
    self.close_time = time
    FirstPayPanel.super.Open(self)
end

function FirstPayPanel:LoadCallBack()
    self.nodes = {
        "btn_right", "rewa_con", "btn_left", "btn_recha", "btn_leave",
        "btn_recha/Text",
        "title_img",
        "red_con", "day_con", "day_con/FirstPayDayItem",
        "model_con", "sundries/eft_img", "power",
    }
    self:GetChildren(self.nodes)
    self.btn_text = GetText(self.Text)
    self.btn_img = GetImage(self.btn_recha)
    self.title_img = GetImage(self.title_img)
    self.power = GetText(self.power)
    self.day_obj = self.FirstPayDayItem.gameObject
    SetVisible(self.model_con, true)

    self:AddEvent()
    self:SetCD()
    self:InitPanel()
end

function FirstPayPanel:AddEvent()
    AddButtonEvent(self.btn_leave.gameObject, handler(self, self.Close))

    local function callback()
        local ori_day = self.model.cur_show_day
        if ori_day > 1 then
            self.model.cur_show_day = ori_day - 1
            self.model:Brocast(FirstPayEvent.DayItemClick, self.model.cur_show_day)
            self:SetTwoSideGrade(self.model.cur_show_day)
            self:LoadRewards()
            self:UpdateBtnShow()
            self:CheckRD()
            lua_resMgr:SetImageTexture(self, self.title_img, "firstpay_image", "title_" .. self.model.cur_show_day, false, nil, false)
            SetVisible(self.btn_right, true)
            if self.model.cur_show_day == 1 then
                SetVisible(self.btn_left, false)
            end
        end
    end
    AddButtonEvent(self.btn_left.gameObject, callback)

    local function callback()
        local ori_day = self.model.cur_show_day
        local max_index = #Config.db_firstpay
        if ori_day < max_index then
            self.model.cur_show_day = ori_day + 1
            self.model:Brocast(FirstPayEvent.DayItemClick, self.model.cur_show_day)
            self:SetTwoSideGrade(self.model.cur_show_day)
            self:LoadRewards()
            self:UpdateBtnShow()
            self:CheckRD()
            lua_resMgr:SetImageTexture(self, self.title_img, "firstpay_image", "title_" .. self.model.cur_show_day, false, nil, false)
            SetVisible(self.btn_left, true)
            if ori_day + 1 == max_index then
                SetVisible(self.btn_right, false)
            end
        end
    end
    AddButtonEvent(self.btn_right.gameObject, callback)

    local function callback()
        if self.btn_mode == 0 then
            GlobalEvent:Brocast(VipEvent.OpenVipPanel, 2)
            self:Close()
        elseif self.btn_mode == 1 then
            --可领取
            self.model:Brocast(FirstPayEvent.GetFirstPayReward)
        elseif self.btn_mode == 2 then
            Notify.ShowText("You already claimed")
        elseif self.btn_mode == 3 then
            Notify.ShowText("Please come back on" .. ChineseNumber(self.model.cur_show_day) .. "day X")
        end
    end
    AddButtonEvent(self.btn_recha.gameObject, callback)

    self.fetch_success_event_id = self.model:AddListener(FirstPayEvent.FetchSuccess, handler(self, self.HandleSuccess))
    self.day_click_event_id = self.model:AddListener(FirstPayEvent.DayItemClick, handler(self, self.HandleDayClick))
end

function FirstPayPanel:SetCD()
    if self.close_time then
        if self.close_sche then
            GlobalSchedule:Stop(self.close_sche)
            self.close_sche = nil
        end
        local function step()
            self:Close()
        end
        self.close_sche = GlobalSchedule:StartOnce(step, self.close_time)
    end
end

function FirstPayPanel:HandleDayClick(idx)
    self.model.cur_show_day = idx
    self:SetTwoSideGrade(self.model.cur_show_day)
    self:LoadRewards()
    self:UpdateBtnShow()
    self:CheckRD()
    lua_resMgr:SetImageTexture(self, self.title_img, "firstpay_image", "title_" .. self.model.cur_show_day, false, nil, false)
    local max_index = #Config.db_firstpay
    if self.model.cur_show_day == 1 then
        SetVisible(self.btn_left, false)
        SetVisible(self.btn_right, true)
    elseif self.model.cur_show_day == max_index then
        SetVisible(self.btn_left, true)
        SetVisible(self.btn_right, false)
    else
        SetVisible(self.btn_left, true)
        SetVisible(self.btn_right, true)
    end
end

function FirstPayPanel:OpenCallBack()
    self.model:Brocast(FirstPayEvent.CloseGuidePanel)
end

function FirstPayPanel:StopCheckSchedual()
    if self.delay_sch then
        GlobalSchedule:Stop(self.delay_sch)
        self.delay_sch = nil
    end
end
function FirstPayPanel:CheckEftShowTime()
    self.cur_time = self.cur_time + 0.5
    if self.cur_time >= self.eft_show_time then
        self:StopCheckSchedual()
        SetVisible(self.eft_img, true)
    end
end
function FirstPayPanel:InitPanel()
    self.delay_sch = GlobalSchedule.StartFun(handler(self, self.CheckEftShowTime), 0.5, -1)
    self:LoadModel()
    local day
    if self.model:IsFirstPay() then
        local can_get_idx = self.model:GetCanFetchGrade()
        if can_get_idx then
            day = can_get_idx
        else
            day = self.model:GetDay()
            day = day > 3 and 3 or day
        end
    else
        --未首充
        day = 1
    end
    self:SetTwoSideGrade(day)
    self.model.cur_show_day = day
    lua_resMgr:SetImageTexture(self, self.title_img, "firstpay_image", "title_" .. self.model.cur_show_day, false, nil, false)
    self:LoadRewards()
    self:UpdateBtnShow()
    self:CheckArrowShow()
    self:CheckRD()
    self:LoadDayItem()
end

function FirstPayPanel:DestroyDayItem()
    if table.nums(self.day_item_list) == 0 then
        return
    end
    for i, v in pairs(self.day_item_list) do
        if v then
            v:destroy()
        end
    end
    self.day_item_list = {}
end

function FirstPayPanel:LoadDayItem()
    self:DestroyDayItem()
    local num = #Config.db_firstpay
    for i = 1, num do
        local item = FirstPayDayItem(self.day_obj, self.day_con)
        item:SetData(i)
        self.day_item_list[#self.day_item_list + 1] = item
    end
end

function FirstPayPanel:LoadModel()
    if self.role_model then
        return
    end
    local gender = RoleInfoModel.GetInstance():GetSex()
    local model_id
    local cf_id
    if gender == 1 then
        cf_id = "41003@0"
        model_id = 40003
    else
        cf_id = "41003@0"
        model_id = 40004
        self.eft_show_time = 1.9
        self.model_y = 0
        self.model_x = -4025
        self.model_z = 390
    end

    local role = RoleInfoModel.GetInstance():GetMainRoleData()
    local data = {}
    data = clone(role)
    local config = {}
    config.res_id = model_id
    config.is_show_wing = false
    config.is_show_leftHand = false
    config.yPos = -56
    config.xPos = -55
    config.y_rotate = 190
    data.figure.fashion_head = {}
    data.figure.fashion_head.model = model_id
    data.figure.fashion_head.show = true
    data.figure.weapon = {}
    data.figure.weapon.model = model_id
    data.figure.weapon.show = true
    config.trans_offset = { x = 136 }
    config.trans_x = 750
    config.trans_y = 750

    self.role_model = UIRoleCamera(self.model_con, nil, data, 1, false, nil, config)
    self.role_model:AddLoadCallBack(handler(self, self.LoadRoleModelCB))
    self.power.text = "+" .. 32000
end
function FirstPayPanel:LoadRoleModelCB()
    self.role_model:SetAnimation({ "show", "idle" }, false, "idle", 0)
    --SetLocalPosition(self.role_model.transform, self.model_x, self.model_y, self.model_z)
    --SetLocalRotation(self.role_model.transform, 16.5, 546, 0)
    --SetLocalScale(self.role_model.transform, 100, 100, 100)
end

function FirstPayPanel:SetTwoSideGrade(cur_grade)
    self.last_grade = cur_grade - 1
    if self.last_grade < 1 then
        self.last_grade = nil
    end
    self.next_grade = cur_grade + 1
    if self.next_grade > #Config.db_firstpay then
        self.next_grade = nil
    end
end

function FirstPayPanel:CheckRD()
    if self.model:IsCanFetch(self.model.cur_show_day) then
        self:SetRedDot(true)
    else
        self:SetRedDot(false)
    end
end

function FirstPayPanel:CheckArrowShow()
    local max_idx = #Config.db_firstpay
    if #Config.db_firstpay == 1 then
        SetVisible(self.btn_left, false)
        SetVisible(self.btn_right, false)
    end
    if self.model.cur_show_day == 1 then
        SetVisible(self.btn_left, false)
        SetVisible(self.btn_right, true)
    elseif self.model.cur_show_day == max_idx then
        SetVisible(self.btn_right, false)
        SetVisible(self.btn_left, true)
    else
        SetVisible(self.btn_left, true)
        SetVisible(self.btn_right, true)
    end
end

function FirstPayPanel:LoadRewards()
    local cf = Config.db_firstpay[self.model.cur_show_day]
    if not cf then
        return
    end
    local list = String2Table(cf.rewards)
    self:DestroyItems()
    local gender = RoleInfoModel.GetInstance():GetSex()
    self.rewa_item_list = {}
    local len = #list
    for i = 1, len do
        local id = list[i][1]
        if type(id) == "table" then
            id = list[i][1][gender]
        end
        local color = Config.db_item[id].color - 1
        local item
        local param = {}
        local num = GetShowNumber(list[i][2])
        param["model"] = self.model
        param["item_id"] = id
        param["num"] = num
        param["can_click"] = true
        param["color_effect"] = color
        param["effect_type"] = 2
        item = GoodsIconSettorTwo(self.rewa_con)
        item:SetIcon(param)
        self.rewa_item_list[i] = item
    end
end

function FirstPayPanel:HandleSuccess()
    self:SetRedDot(false)
    self:InitPanel()
end

function FirstPayPanel:UpdateBtnShow()
    if self.model:IsFirstPay() then
        if self.model:CheckIsRewarded() then
            --已经获得
            self.btn_mode = 2
            self.btn_text.text = "Claimed"
            ShaderManager.GetInstance():SetImageGray(self.btn_img)
        else
            if self.model.cur_show_day > self.model:GetDay() then
                --not today
                self.btn_text.text = "No." .. ChineseNumber(self.model.cur_show_day) .. "Available on day X"
                ShaderManager.GetInstance():SetImageGray(self.btn_img)
                self.btn_mode = 3
            else
                self.btn_mode = 1
                self.btn_text.text = "Claim"
                ShaderManager.GetInstance():SetImageNormal(self.btn_img)
            end
        end
    else
        self.btn_mode = 0
        self.btn_text.text = "Recharge"
        ShaderManager.GetInstance():SetImageNormal(self.btn_img)
    end
end

function FirstPayPanel:DestroyItems()
    if self.rewa_item_list then
        for i, v in pairs(self.rewa_item_list) do
            if v then
                v:destroy()
            end
        end
        self.rewa_item_list = {}
    end
end

function FirstPayPanel:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end

function FirstPayPanel:CloseCallBack()
    if self.close_sche then
        GlobalSchedule:Stop(self.clse_sche)
        self.close_sche = nil
    end
    self:DestroyDayItem()
    if self.day_click_event_id then
        self.model:RemoveListener(self.day_click_event_id)
        self.day_click_event_id = nil
    end
    self:StopCheckSchedual()
    if self.delay_sch then
        GlobalSchedule:Stop(self.delay_sch)
        self.delay_sch = nil
    end
    if self.role_model then
        self.role_model:destroy()
        self.role_model = nil
    end
    self.model:CheckRD()
    self:DestroyItems()
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
    self.model.cur_show_day = 1
    if self.fetch_success_event_id then
        self.model:RemoveListener(self.fetch_success_event_id)
        self.fetch_success_event_id = nil
    end
end

