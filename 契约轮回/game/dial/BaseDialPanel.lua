-- @Author: lwj
-- @Date:   2019-12-05 14:55:20 
-- @Last Modified time: 2019-12-05 14:55:22

BaseDialPanel = BaseDialPanel or class("BaseDialPanel", BasePanel)
local BaseDialPanel = BaseDialPanel

function BaseDialPanel:ctor()
    self.model = DialModel.GetInstance()
    self.panel_type = 2
    self.is_hide_other_panel = true
    self.use_background = true
    self.pointer_ab_name = "dial_image"
    self.pointer_res_name = "recha_dial_pointer"
    self.global_event = {}
    self.model_event = {}
    self.is_can_click = true
end

function BaseDialPanel:dctor()

end

function BaseDialPanel:Open()
    self.act_id = OperateModel.GetInstance():GetActIdByType(750)
    if self.act_id ~= 0 then
        self.cf = OperateModel.GetInstance():GetConfig(self.act_id)
        self.openData = OperateModel:GetInstance():GetAct(self.act_id)
    end
    local limit = String2Table(self.cf.reqs)
    self.sin_cost = limit[1][2]
    self.max_pro = limit[2][2]
    BaseDialPanel.super.Open(self)
end

function BaseDialPanel:OpenCallBack()
end

function BaseDialPanel:LoadCallBack()
    self.nodes = {
        "btn_turn", "time_con/countdowntext", "remain", "slider", "item_con/RechargeDialItem", "turn_con", "item_con", "btn_close",
        "slider/pro", "btn_reco",
    }
    self:GetChildren(self.nodes)
    self.right_obj = self.RechargeDialItem.gameObject
    self.remain = GetText(self.remain)
    self.pro = GetText(self.pro)
    self.slider = GetSlider(self.slider)
    self.cd = GetText(self.countdowntext)

    self:AddEvent()
    self:InitPanel()
    self.schedules = GlobalSchedule:Start(handler(self, self.CountDown), 0.2, -1);
end

function BaseDialPanel:AddEvent()
    local function callback()
        if self.turn_table then
            if self.turn_table:IsAction() then
                Notify.ShowText("Roulette in progress")
                return
            end
            self:Close()
        end
    end
    AddButtonEvent(self.btn_close.gameObject, callback)

    local function callback()
        if self.turn_table then
            if self.turn_table:IsAction() then
                Notify.ShowText("Roulette in progress")
                return
            end
            if not self.is_can_click then
                Notify.ShowText("Slow down a bit")
                return
            end
            if self.cur_times < 1 then
                Notify.ShowText("Insufficient attempts")
                return
            end
            GlobalEvent:Brocast(OperateEvent.REQ_D_TURN, self.act_id)
        end
    end
    AddButtonEvent(self.btn_turn.gameObject, callback)

    local function callback()
        if self.delay_OpenPanel then
            GlobalSchedule:Stop(self.delay_OpenPanel)
            self.delay_OpenPanel = nil
        end
        local function step()
            lua_panelMgr:GetPanelOrCreate(RechargeRecoPanel):Open(self.act_id)
        end
        self.delay_OpenPanel = GlobalSchedule:StartOnce(step, 0.2)
    end
    AddClickEvent(self.btn_reco.gameObject, callback)

    --self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(OperateEvent.UPDATE_D_PRO, handler(self, self.UpdateProgress))
    self.model_event[#self.model_event + 1] = self.model:AddListener(DialEvent.UpdateDPanel, handler(self, self.HandlePanelUpdate))
    self.model_event[#self.model_event + 1] = self.model:AddListener(DialEvent.StartTurnDial, handler(self, self.HandleStartTurn))
end

function BaseDialPanel:InitPanel()
    self:InitDialShow()
    self:UpdateRightShow()
    self:UpdateProgress()
end

function BaseDialPanel:HandlePanelUpdate()
    self:InitDialShow()
    self:UpdateProgress()
end

function BaseDialPanel:InitDialShow()
    if not self.turn_table then
        self.turn_table = TurnTable(self.turn_con, nil, nil, 1.0, true, -1800)
        self.turn_table:SetPointer(self.pointer_ab_name, self.pointer_res_name)
    end
    local round = self.model:GetCurRound(self.act_id)
    local list = self.model:GetLotteryCf(self.act_id, round)
    self.cur_loto_cf = list
    if table.isempty(list) then
        return
    end
    local data = {}
    for i = 1, #list do
        local sin_cf = list[i]
        local tbl = String2Table(sin_cf.rewards)[1]
        data[i] = { tbl[1], tbl[2], tbl[3] }
    end
    self.turn_table:SetData(data, 175, 128)
    if self.turn_table:IsAction() then
        return
    end
    self:UpdateTableHit()
end

function BaseDialPanel:GetIndxById(loto_id)
    local result = 1
    for i = 1, #self.cur_loto_cf do
        local sin_cf = self.cur_loto_cf[i]
        if sin_cf.id == loto_id then
            result = i
            break
        end
    end
    return result
end

function BaseDialPanel:UpdateTableHit()
    local item_list = self.turn_table:GetItemList()
    for k, item in pairs(item_list) do
        item:SetHaveGetVisible(self:IsHit(item.index))
    end
end

function BaseDialPanel:IsHit(item_index)
    local hits = self.model:GetCurHits(self.act_id)
    for _, index in pairs(hits) do
        local idx = self:GetIndxById(index)
        if idx == item_index then
            return true
        end
    end
    return false
end

function BaseDialPanel:UpdateRightShow()
    local list = String2Table(self.cf.sundries)
    self.right_item_list = self.right_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.right_item_list[i]
        if not item then
            item = RechargeDialItem(self.right_obj, self.item_con)
            self.right_item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(list[i])
    end
    for i = len + 1, #self.right_item_list do
        local item = self.right_item_list[i]
        item:SetVisible(false)
    end
end

function BaseDialPanel:UpdateProgress()
    local pro = self.model:GetCurPro(self.act_id)
    local cur_pro = pro
    if not pro then
        pro = 0
    end
    if pro > self.max_pro then
        cur_pro = self.max_pro
    end
    local cur_times = math.floor(cur_pro / self.sin_cost)
    local round = self.model:GetCurRound(self.act_id)
    local list = self.model:GetLotteryCf(self.act_id, round) or {}
    local num = #list
    local hits = self.model:GetCurHits(self.act_id) or {}
    local hits_num = #hits or 0
    local rest = num - hits_num
    local rewa_count = round == 1 and rest + 6 or rest
    local result_times = cur_times < rewa_count and cur_times or rewa_count
    self.cur_times = result_times
    self.remain.text = string.format("Attempts left: %d", result_times)
    self.pro.text = string.format("%d/%d", cur_pro, self.sin_cost)
    self.slider.value = cur_pro / self.sin_cost
end

function BaseDialPanel:CheckIsEmpty()
    if self.model:GetHitsNum(self.act_id) >= 6 then
        self.is_can_click = false
        if self.refresh_sche then
            GlobalSchedule:Stop(self.refresh_sche)
            self.refresh_sche = nil
        end
        local function step()
            GlobalEvent:Brocast(OperateEvent.REQUEST_D_INFO, self.act_id)
            self.is_can_click = true
        end
        self.refresh_sche = GlobalSchedule:StartOnce(step, 2)
    end
end

function BaseDialPanel:HandleStartTurn(id, hits)
    if id ~= self.act_id then
        return
    end
    self:UpdateProgress()
    local idx = self:GetIndxById(hits)
    self.turn_table:SetTurnToIndex(idx, handler(self, self.OnTurnCallBack))
end

function BaseDialPanel:OnTurnCallBack()
    self:UpdateTableHit()
    self:CheckIsEmpty()
end

function BaseDialPanel:CountDown()
    local timeTab = nil;
    local timestr = "";
    local formatTime = "%d";
    timeTab = TimeManager:GetLastTimeData(os.time(), self.openData.act_etime);
    if table.isempty(timeTab) then
        self.cd.text = string.format("Event countdown: <color=#%s>%s</color>", "ff0000", "Ended")
        GlobalSchedule.StopFun(self.schedules);
    else
        if timeTab.day then
            timestr = timestr .. string.format(formatTime, timeTab.day) .. "Days";
        end
        if timeTab.hour then
            timestr = timestr .. string.format(formatTime, timeTab.hour) .. "hr";
        end
        if timeTab.min then
            timestr = timestr .. string.format(formatTime, timeTab.min) .. "min";
        end
        if timeTab.sec then
            timestr = timestr .. string.format(formatTime, timeTab.sec) .. "sec";
        end
        if timeTab.sec and not timeTab.day and not timeTab.hour and not timeTab.min then
            timestr = "1 pts"
        end
        local color = "27C31F"
        if not timeTab.day then
            color = "ff0000"
        end
        self.cd.text = string.format("Event countdown: <color=#%s>%s</color>", color, timestr)
    end
end

function BaseDialPanel:CloseCallBack()
    if self.delay_OpenPanel then
        GlobalSchedule:Stop(self.delay_OpenPanel)
        self.delay_OpenPanel = nil
    end
    if self.refresh_sche then
        GlobalSchedule:Stop(self.refresh_sche)
        self.refresh_sche = nil
    end
    if self.schedules then
        GlobalSchedule:Stop(self.schedules);
    end
    if not table.isempty(self.model_event) then
        for i, v in pairs(self.model_event) do
            self.model:RemoveListener(v)
        end
        self.model_event = {}
    end
    if not table.isempty(self.global_event) then
        for i, v in pairs(self.global_event) do
            GlobalEvent:RemoveListener(v)
        end
        self.global_event = {}
    end
    if self.turn_table then
        self.turn_table:destroy()
        self.turn_table = nil
    end
    destroyTab(self.right_item_list, true)
end