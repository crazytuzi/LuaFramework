-- @Author: lwj
-- @Date:   2019-09-20 17:14:34 
-- @Last Modified time: 2019-09-20 17:14:37

NationHighView = NationHighView or class("NationHighView", BaseItem)
local NationHighView = NationHighView

function NationHighView:ctor(parent_node, layer)
    self.abName = "nation"
    self.assetName = "NationHighView"
    self.layer = layer

    self.act_id = OperateModel.GetInstance():GetActIdByType(403)
    self.model = NationModel.GetInstance()
    BaseItem.Load(self)
end

function NationHighView:dctor()
    if self.CDT then
        self.CDT:destroy()
        self.CDT = nil
    end
    if self.success_fetch_event_id then
        GlobalEvent:RemoveListener(self.success_fetch_event_id)
        self.success_fetch_event_id = nil
    end
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

function NationHighView:LoadCallBack()
    self.nodes = {
        "Right_Scroll/Viewport/right_con", "Left_Scroll/Viewport/left_con", "Left_Scroll/Viewport/left_con/NationHighRewaItem", "cd", "Right_Scroll/Viewport/right_con/NationHighTaskItem",
        "cur_pro", "Left_Scroll/Viewport", "time_con", "time_con/countdowntext",
    }
    self:GetChildren(self.nodes)
    self.rewa_obj = self.NationHighRewaItem.gameObject
    self.task_obj = self.NationHighTaskItem.gameObject
    self.cur_pro = GetText(self.cur_pro)
    self.time = GetText(self.countdowntext)

    self:AddEvent()
    self:SetMask()
    self:InitPanel()
end

function NationHighView:AddEvent()
    self.model_event = {}
    self.model_event[#self.model_event + 1] = self.model:AddListener(NationEvent.UpdateTaskPro, handler(self, self.HandleUpdatePro))
    self.model_event[#self.model_event + 1] = self.model:AddListener(NationEvent.UpdateHighCurPro, handler(self, self.HandleUpdateCurProText))

    self.success_fetch_event_id = GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD, handler(self, self.HandleSuccessFetch))

end

function NationHighView:InitPanel()
    self:InitTime()
    self:SortLoadList()
    self:LoadRewaItem()
    self:LoadTaskItem()
    self.cur_pro.text = string.format(ConfigLanguage.OpenHigh.HighViewCurPro, self.model.cur_high_pro)
end

function NationHighView:InitTime()
    if self.CDT then
        return
    end
    self.end_time = self.model:GetEndTimeByActId(OperateModel.GetInstance():GetActIdByType(403))
    if self.end_time then
        local param = {}
        param.isShowMin = true
        param.isShowHour = true
        param.isShowDay = true
        param.isShowSec = true
        param.isChineseType = true
        param.formatText = "Time left: %s"
        self.CDT = CountDownText(self.time_con, param)
        local function call_back()
            self.time.text = ConfigLanguage.Nation.ActivityIsOver
        end
        self.CDT:StartSechudle(self.end_time, call_back)
    end
end

function NationHighView:SortLoadList()
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
            if act_task_cf.id == 9 then
                print('')
            end
            if data.ser_info.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
                task_fin_list[#task_fin_list + 1] = data
            else
                local sundries = String2Table(data.cf.sundries)
                local jump = {}
                for _, tbl in pairs(sundries) do
                    if tbl[1] == "jump" then
                        jump = tbl[2]
                        break
                    end
                end
                local sub_id = jump[2]
                if jump[#jump] == "true" then
                    sub_id = jump[#jump - 1]
                end
                if jump[1] and OpenTipModel.GetInstance():IsOpenSystem(jump[1], sub_id) then
                    self.task_list[#self.task_list + 1] = data
                end
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

function NationHighView:LoadRewaItem()
    local list = self.rewa_list
    self.rewa_item_list = self.rewa_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.rewa_item_list[i]
        if not item then
            item = NationHighRewaItem(self.rewa_obj, self.left_con)
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

function NationHighView:LoadTaskItem()
    local list = self.task_list
    self.task_item_list = self.task_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.task_item_list[i]
        if not item then
            item = NationHighTaskItem(self.task_obj, self.right_con)
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

function NationHighView:HandleSuccessFetch(data)
    if data.act_id ~= self.act_id then
        return
    end
    self:SortLoadList()
    self:LoadRewaItem()
end

function NationHighView:HandleUpdatePro()
    self:InitPanel()
end

function NationHighView:HandleUpdateCurProText()
    self.cur_pro.text = string.format(ConfigLanguage.OpenHigh.HighViewCurPro, self.model.cur_high_pro)
end

function NationHighView:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end