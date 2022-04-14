-- @Author: lwj
-- @Date:   2019-07-19 18:58:02 
-- @Last Modified time: 2019-07-19 18:58:04

HighView = HighView or class("HighView", BaseItem)
local HighView = HighView

function HighView:ctor(parent_node, layer)
    self.abName = "openHigh"
    self.assetName = "HighView"
    self.layer = layer

    self.act_id = 120101
    self.model = OpenHighModel.GetInstance()
    self.countdowntext = nil
    BaseItem.Load(self)
end

function HighView:dctor()
    if self.countdowntext then
        self.countdowntext:destroy()
    end
    self.countdowntext = nil
    for i, v in pairs(self.rewa_item_list) do
        if v then
            v:destroy()
        end
    end
    self.rewa_item_list = {}
    for i, v in pairs(self.task_item_list) do
        if v then
            v:destroy()
        end
    end
    self.task_item_list = {}
    for i, v in pairs(self.model_event) do
        self.model:RemoveListener(v)
    end
    self.model_event = {}
    if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
end

function HighView:LoadCallBack()
    self.nodes = {
        "Right_Scroll/Viewport/right_con", "Left_Scroll/Viewport/left_con", "Left_Scroll/Viewport/left_con/OpenHighRewaItem", "cd", "Right_Scroll/Viewport/right_con/OpenHighTaskItem",
        "cur_pro", "Left_Scroll/Viewport",
    }
    self:GetChildren(self.nodes)
    self.rewa_obj = self.OpenHighRewaItem.gameObject
    self.task_obj = self.OpenHighTaskItem.gameObject
    self.cur_pro = GetText(self.cur_pro)

    local time = OperateModel.GetInstance():GetActEndTimeByActId(self.act_id)
    if time then
        local param = {}
        param.isShowMin = true
        param.isShowHour = true
        param.isShowDay = true
        param.isChineseType = true
        param.formatText = "Countdown: %s"
        self.countdowntext = CountDownText(self.cd, param)
        local function call_back()
            SetVisible(self.countdowntext, false)
            self.countdowntext = nil
        end
        self.countdowntext:StartSechudle(time, call_back)
    else
        SetVisible(self.cf, false)
    end
    self:AddEvent()
    self:SetMask()
    self:InitPanel()
end

function HighView:AddEvent()
    self.model_event = {}
    self.model_event[#self.model_event + 1] = self.model:AddListener(OpenHighEvent.SuccessFetchRewa, handler(self, self.HandleSuccessFetch))
    self.model_event[#self.model_event + 1] = self.model:AddListener(OpenHighEvent.UpdateTaskPro, handler(self, self.HandleUpdatePro))
    self.model_event[#self.model_event + 1] = self.model:AddListener(OpenHighEvent.UpdateHighCurPro, handler(self, self.HandleUpdateCurProText))
end

function HighView:InitPanel()
    self:SortLoadList()
    self:LoadRewaItem()
    self:LoadTaskItem()
    self.cur_pro.text = string.format(ConfigLanguage.OpenHigh.HighViewCurPro, self.model.cur_high_pro)
end

function HighView:SortLoadList()
    local cf = self.model:GetRewaCfByActId(self.act_id)
    self.rewa_list = {}
    self.task_list = {}
    local rewa_fin_list = {}
    local task_fin_list = {}
    local inter = table.pairsByKey(cf)
    for act_task_id, act_task_cf in inter do
        local data = {}
        data.cf = {}
        data.ser_info = {}
        data.ser_info = self.model:GetSingleTaskInfo(self.act_id, act_task_id)
        data.cf = act_task_cf
        if act_task_cf.level == 1 then
            --任务
            if data.ser_info.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
                task_fin_list[#task_fin_list + 1] = data
            else
                self.task_list[#self.task_list + 1] = data
            end
        else
            --奖励
            if data.ser_info.state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
                rewa_fin_list[#rewa_fin_list + 1] = data
            else
                self.rewa_list[#self.rewa_list + 1] = data
            end
        end
    end
    for i = 1, #rewa_fin_list do
        self.rewa_list[#self.rewa_list + 1] = rewa_fin_list[i]
    end
    for i = 1, #task_fin_list do
        self.task_list[#self.task_list + 1] = task_fin_list[i]
    end
end

function HighView:LoadRewaItem()
    local list = self.rewa_list
    self.rewa_item_list = self.rewa_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.rewa_item_list[i]
        if not item then
            item = OpenHighRewaItem(self.rewa_obj, self.left_con)
            self.rewa_item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(list[i], self.StencilId, 3)
    end
    for i = len + 1, #self.rewa_item_list do
        local item = self.rewa_item_list[i]
        item:SetVisible(false)
    end
end

function HighView:LoadTaskItem()
    local list = self.task_list
    self.task_item_list = self.task_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.task_item_list[i]
        if not item then
            item = OpenHighTaskItem(self.task_obj, self.right_con)
            self.task_item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(list[i])
    end
    for i = len + 1, #self.task_item_list do
        local item = self.task_item_list[i]
        item:SetVisible(false)
    end
end

function HighView:HandleSuccessFetch(data)
    if data.act_id ~= self.act_id then
        return
    end
    self:SortLoadList()
    self:LoadRewaItem()
end

function HighView:HandleUpdatePro()
    self:InitPanel()
end

function HighView:HandleUpdateCurProText()
    self.cur_pro.text = string.format(ConfigLanguage.OpenHigh.HighViewCurPro, self.model.cur_high_pro)
end

function HighView:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end