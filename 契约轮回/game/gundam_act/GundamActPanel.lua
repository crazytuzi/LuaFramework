-- @Author: lwj
-- @Date:   2020-01-06 11:11:14
-- @Last Modified time: 2020-01-06 11:11:19

GundamActPanel = GundamActPanel or class("GundamActPanel", BasePanel)
local GundamActPanel = GundamActPanel

function GundamActPanel:ctor()
    self.abName = "gundam_act"
    self.assetName = "GundamActPanel"
    self.layer = "UI"

    self.model = GundamActModel.GetInstance()
    self.panel_type = 2
    self.use_background = true
    self.is_hide_other_panel = true
    self.res_name = 10002
    self:GetAllCf()
    self.day_item_start_y = 0
    self.day_item_height = 95.5
    self.model_event = {}
end

function GundamActPanel:GetAllCf()
    local list = self.model.act_id_list
    self.cf_list = {}
    for i = 1, #list do
        local id = list[i]
        local cf = OperateModel.GetInstance():GetRewardConfig(id)
        local sin_cf = {}
        if cf then
            local inter = table.pairsByKey(cf)
            for id, single_config in inter do
                sin_cf[#sin_cf + 1] = single_config
            end
        end
        GlobalEvent:Brocast(OperateEvent.REQUEST_GET_YY_INFO, id)
        self.cf_list[i] = sin_cf
    end
end

function GundamActPanel:dctor()

end

function GundamActPanel:Open()
    GundamActPanel.super.Open(self)
end

function GundamActPanel:OpenCallBack()
end

function GundamActPanel:LoadCallBack()
    self.nodes = {
        "task_con/GundamActTaskItem", "task_con", "model_con", "day_con", "day_con/GundamActDayItem", "btn_close",
    }
    self:GetChildren(self.nodes)
    self.task_obj = self.GundamActTaskItem.gameObject
    self.day_obj = self.GundamActDayItem.gameObject

    SetLocalPositionXY(self.day_con.transform, 492, 77)
    SetLocalPositionXY(self.model_con.transform, -180, -82)

    self:AddEvent()
    self:InitPanel()
end

function GundamActPanel:AddEvent()
    AddButtonEvent(self.btn_close.gameObject, handler(self, self.Close))
    self.model_event[#self.model_event + 1] = self.model:AddListener(GundamActEvent.ReciveYYInfo, handler(self, self.HandleReciveInfo))
    self.model_event[#self.model_event + 1] = self.model:AddListener(GundamActEvent.ClosePanel, handler(self, self.Close))
end

function GundamActPanel:InitPanel()
    self:LoadModel()
    self:LoadDayItem()
end

function GundamActPanel:LoadModel()
    destroySingle(self.ui_model)
    local cfg = {}
    cfg.pos = { x = -2000, y = -458, z = 700 }
    local ratio = 300
    cfg.scale = { x = ratio, y = ratio, z = ratio }
    cfg.trans_x = 900
    cfg.trans_y = 900
    cfg.trans_offset = { x = -126, y = 0 }
    cfg.carmera_size = 6
    self.ui_model = UIModelCommonCamera(self.model_con, nil, "model_machiaction_" .. self.res_name)
    self.ui_model:SetConfig(cfg)
end

function GundamActPanel:LoadDayItem()
    local function callback(idx)
        local opdays = LoginModel.GetInstance():GetOpenTime()
        if opdays < idx or opdays > 3 then
            Notify.ShowText("Locked")
            return
        end
        self.model.cur_day = idx
        local item = self.day_item_list[idx]
        if item then
            item.transform:SetAsLastSibling()
            item:Select(idx)
        end
        self:LoadTaskItem(idx)
        self.model:Brocast(GundamActEvent.DayItemClick, idx)
    end

    local cur_y = self.day_item_start_y
    self.day_item_list = self.day_item_list or {}
    for i = 1, 3 do
        local item = self.day_item_list[i]
        if not item then
            item = GundamActDayItem(self.day_obj, self.day_con)
            self.day_item_list[i] = item
        else
            item:SetVisible(true)
        end
        local data = {}
        data.pos_y = cur_y
        cur_y = cur_y - self.day_item_height
        data.idx = i
        item:SetData(data)
        item:AddCallBack(callback)
        item.transform:SetAsFirstSibling()
    end
    for i = 3 + 1, #self.day_item_list do
        local item = self.day_item_list[i]
        item:SetVisible(false)
    end
    callback(1)
end

function GundamActPanel:LoadTaskItem(idx)
    local list = self.cf_list[idx]
    self.task_item_list = self.task_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.task_item_list[i]
        if not item then
            item = GundamActTaskItem(self.task_obj, self.task_con)
            self.task_item_list[i] = item
        else
            item:SetVisible(true)
        end
        list[i].idx = i
        item:SetData(list[i])
    end
    for i = len + 1, #self.task_item_list do
        local item = self.task_item_list[i]
        item:SetVisible(false)
    end
end

function GundamActPanel:HandleReciveInfo()
    local cur_act_id = self.model.act_id_list[self.model.cur_day]
    local data = self.model:GetInfo(cur_act_id)
    if cur_act_id == data.idx then
        self:UpdateTaskState(data.tasks, cur_act_id)
    end
end

function GundamActPanel:UpdateTaskState(data, cur_act_id)
    if (not self.task_item_list) or table.isempty(self.task_item_list) then
        return
    end
    for i = 1, #self.task_item_list do
        local item = self.task_item_list[i]
        item:SetSerData()
    end
end

function GundamActPanel:CloseCallBack()
    if not table.isempty(self.model_event) then
        for i, v in pairs(self.model_event) do
            self.model:RemoveListener(v)
        end
        self.model_event = {}
    end
    self.model.cur_day = 1
    destroySingle(self.ui_model)
    destroyTab(self.day_item_list, true)
    destroyTab(self.task_item_list, true)
end