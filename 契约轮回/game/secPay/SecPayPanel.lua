-- @Author: lwj
-- @Date:   2019-04-17 15:29:32
-- @Last Modified time: 2019-05-21 21:52:02


SecPayPanel = SecPayPanel or class("SecPayPanel", BasePanel)
local SecPayPanel = SecPayPanel

function SecPayPanel:ctor()
    self.abName = "secPay"
    self.assetName = "SecPayPanel"
    self.layer = "UI"

    self.model = SecPayModel.GetInstance()
    self.btn_mode = 0       --0:前往充值   1:可领取    2:已领取   3:not today
    self.last_grade = nil
    self.next_grade = nil
    self.cur_time = 0
    self.eft_show_time = 1.2
    self.day_item_list = {}

    self.panel_type = 2
    self.is_hide_other_panel = true
end

function SecPayPanel:dctor()

end

function SecPayPanel:Open(time)
    self.close_time = time
    SecPayPanel.super.Open(self)
end

function SecPayPanel:LoadCallBack()
    self.nodes = {
        "btn_right", "rewa_con", "btn_left", "btn_recha", "btn_leave",
        "btn_recha/Text",
        "title_img",
        "red_con", "day_con", "day_con/SecPayDayItem",
         "model_con", "sundries/eft_img", "power",
    }
    self:GetChildren(self.nodes)
    self.btn_text = GetText(self.Text)
    self.btn_img = GetImage(self.btn_recha)
    self.title_img = GetImage(self.title_img)
    self.power = GetText(self.power)
    self.day_obj = self.SecPayDayItem.gameObject

    self:AddEvent()
    self:SetCD()
    self:InitPanel()
end

function SecPayPanel:AddEvent()
    AddButtonEvent(self.btn_leave.gameObject, handler(self, self.Close))

    local function callback()
        local ori_day = self.model.cur_show_day
        if ori_day > 1 then
            self.model.cur_show_day = ori_day - 1
            self.model:Brocast(SecPayEvent.DayItemClick, self.model.cur_show_day)
            self:SetTwoSideGrade(self.model.cur_show_day)
            self:LoadRewards()
            self:UpdateBtnShow()
            self:CheckRD()
            lua_resMgr:SetImageTexture(self, self.title_img, "secpay_image", "title_" .. self.model.cur_show_day, false, nil, false)
            SetVisible(self.btn_right, true)
            if self.model.cur_show_day == 1 then
                SetVisible(self.btn_left, false)
            end
        end
    end
    AddButtonEvent(self.btn_left.gameObject, callback)

    local function callback()
        local ori_day = self.model.cur_show_day
        local max_index = #Config.db_actpay_reward
        if ori_day < max_index then
            self.model.cur_show_day = ori_day + 1
            self.model:Brocast(SecPayEvent.DayItemClick, self.model.cur_show_day)
            self:SetTwoSideGrade(self.model.cur_show_day)
            self:LoadRewards()
            self:UpdateBtnShow()
            self:CheckRD()
            lua_resMgr:SetImageTexture(self, self.title_img, "secpay_image", "title_" .. self.model.cur_show_day, false, nil, false)
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
            self.model.cur_fetch_rewa_act_id = self.model.sec_week_recha_id
            self.model.cur_fetch_rewa_day = self.model.cur_show_day
            self.model:Brocast(SecPayEvent.GetFirstPayReward, self.model.cur_fetch_rewa_act_id, self.model.cur_fetch_rewa_day)
        elseif self.btn_mode == 2 then
            Notify.ShowText("You already claimed")
        elseif self.btn_mode == 3 then
            Notify.ShowText("Please come back on" .. ChineseNumber(self.model.cur_show_day) .. "day X")
        end
    end
    AddButtonEvent(self.btn_recha.gameObject, callback)

    self.fetch_success_event_id = self.model:AddListener(SecPayEvent.FetchSuccess, handler(self, self.HandleSuccess))
    self.day_click_event_id = self.model:AddListener(SecPayEvent.DayItemClick, handler(self, self.HandleDayClick))
end

function SecPayPanel:SetCD()
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

function SecPayPanel:HandleDayClick(idx)
    self.model.cur_show_day = idx
    self:SetTwoSideGrade(self.model.cur_show_day)
    self:LoadRewards()
    self:UpdateBtnShow()
    self:CheckRD()
    lua_resMgr:SetImageTexture(self, self.title_img, "secpay_image", "title_" .. self.model.cur_show_day, false, nil, false)
    local max_index = #Config.db_actpay_reward
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

function SecPayPanel:OpenCallBack()
    if self.model:IsShowIconThisTime(self.model.sec_week_recha_id) then
        GlobalEvent:Brocast(MainEvent.ChangeRedDot, "secPay", false)
        self.model.show_icon_this_time_list[self.model.sec_week_recha_id] = false
    end
    self.model:Brocast(SecPayEvent.CloseGuidePanel)
end

function SecPayPanel:StopCheckSchedual()
    if self.delay_sch then
        GlobalSchedule:Stop(self.delay_sch)
        self.delay_sch = nil
    end
end
function SecPayPanel:CheckEftShowTime()
    self.cur_time = self.cur_time + 0.5
    if self.cur_time >= self.eft_show_time then
        self:StopCheckSchedual()
        SetVisible(self.eft_img, true)
    end
end
function SecPayPanel:InitPanel()
    self.delay_sch = GlobalSchedule.StartFun(handler(self, self.CheckEftShowTime), 0.5, -1)
    self:LoadModel()
    local id = self.model.sec_week_recha_id
    local day
    if self.model:IsFirstPay(id) then
        local can_get_idx = self.model:GetCanFetchGrade(id)
        if can_get_idx then
            day = can_get_idx
        else
            day = self.model:GetDay(id)
            day = day > 3 and 3 or day
        end
    else
        --未首充
        day = 1
    end
    self:SetTwoSideGrade(day)
    self.model.cur_show_day = day
    lua_resMgr:SetImageTexture(self, self.title_img, "secpay_image", "title_" .. self.model.cur_show_day, false, nil, false)
    self:LoadRewards()
    self:UpdateBtnShow()
    self:CheckArrowShow()
    self:CheckRD()
    self:LoadDayItem()
    local function step()
        SetVisible(self.model_con, true)
    end
    self.delay_show_sche = GlobalSchedule:StartOnce(step, 0.5)
end

function SecPayPanel:DestroyDayItem()
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

function SecPayPanel:LoadDayItem()
    self:DestroyDayItem()
    local num = #Config.db_actpay_reward
    for i = 1, num do
        local item = SecPayDayItem(self.day_obj, self.day_con)
        item:SetData(i)
        self.day_item_list[#self.day_item_list + 1] = item
    end
end

function SecPayPanel:LoadModel()
    if self.role_model then
        return
    end
    local gender = RoleInfoModel.GetInstance():GetSex()
    local model_id = gender == 1 and 40006 or 40007
    self.scale = gender == 1 and 1.2 or 1.1
    self.eft_show_time = 1.9

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
    self.power.text = "+" .. 26950
end
function SecPayPanel:LoadRoleModelCB()
    self.role_model:SetAnimation({ "idle" }, false, "idle", 0)
    local gender = RoleInfoModel.GetInstance():GetSex()
    if gender == 1 then
        SetLocalPosition(self.role_model.transform, 55, 102, 0)
    else
        SetLocalPosition(self.role_model.transform, 79, 24, 0)
    end
    --SetLocalRotation(self.role_model.transform, 16.5, 546, 0)
    SetLocalScale(self.role_model.transform, self.scale, self.scale, self.scale)
end

function SecPayPanel:SetTwoSideGrade(cur_grade)
    self.last_grade = cur_grade - 1
    if self.last_grade < 1 then
        self.last_grade = nil
    end
    self.next_grade = cur_grade + 1
    if self.next_grade > #Config.db_actpay_reward then
        self.next_grade = nil
    end
end

function SecPayPanel:CheckRD()
    if self.model:IsCanFetch(self.model.cur_show_day, self.model.sec_week_recha_id) then
        self:SetRedDot(true)
    else
        self:SetRedDot(false)
    end
end

function SecPayPanel:CheckArrowShow()
    local max_idx = #Config.db_actpay_reward
    if #Config.db_actpay_reward == 1 then
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

function SecPayPanel:LoadRewards()
    local cf = Config.db_actpay_reward[self.model.cur_show_day]
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

function SecPayPanel:HandleSuccess()
    self:SetRedDot(false)
    self:InitPanel()
end

function SecPayPanel:UpdateBtnShow()
    if self.model:IsFirstPay(self.model.sec_week_recha_id) then
        if self.model:CheckIsRewarded(self.model.cur_show_day, self.model.sec_week_recha_id) then
            --已经获得
            self.btn_mode = 2
            self.btn_text.text = "Claimed"
            ShaderManager.GetInstance():SetImageGray(self.btn_img)
        else
            if self.model.cur_show_day > self.model:GetDay(self.model.sec_week_recha_id) then
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

function SecPayPanel:DestroyItems()
    if self.rewa_item_list then
        for i, v in pairs(self.rewa_item_list) do
            if v then
                v:destroy()
            end
        end
        self.rewa_item_list = {}
    end
end

function SecPayPanel:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end

function SecPayPanel:CloseCallBack()
    if self.close_sche then
        GlobalSchedule:Stop(self.close_sche)
        self.close_sche = nil
    end
    if self.delay_show_sche then
        GlobalSchedule:Stop(self.delay_show_sche)
        self.delay_show_sche = nil
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

