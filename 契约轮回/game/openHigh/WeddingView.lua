-- @Author: lwj
-- @Date:   2019-08-01 15:02:13 
-- @Last Modified time: 2019-08-01 15:02:16

WeddingView = WeddingView or class("WeddingView", BaseItem)
local WeddingView = WeddingView

function WeddingView:ctor(parent_node, layer)
    self.abName = "openHigh"
    self.assetName = "WeddingView"
    self.layer = layer

    self.act_id = 120201
    self.model = OpenHighModel.GetInstance()
    self.model_event = {}
    BaseItem.Load(self)
end

function WeddingView:dctor()
    if self.role_model then
        self.role_model:destroy()
        self.role_model = nil
    end
    if self.reco_item_list then
        for i, v in pairs(self.reco_item_list) do
            if v then
                v:destroy()
            end
        end
        self.reco_item_list = {}
    end
    if self.recive_yy_log_event_id then
        GlobalEvent:RemoveListener(self.recive_yy_log_event_id)
        self.recive_yy_log_event_id = nil
    end
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
end

function WeddingView:LoadCallBack()
    GlobalEvent:Brocast(OperateEvent.REQUEST_YY_LOG, self.act_id)
    self.nodes = {
        "Left/Left_Show", "Left/eft_con", "Right/TitleBg/act_time", "Right/Task_Bg/TaskScroll/Viewport/task_con/WeddingTaskItem",
        "Right/Task_Bg/TaskScroll/Viewport/task_con", "Right/btn_go", "Right/btn_go/btn_text", "Left/left_scroll",
        "Left/Left_Title", "Left/left_scroll/Reco_Scroll/Viewport/reco_con/WeddingRecoItem", "Left/left_scroll/Reco_Scroll/Viewport/reco_con",
        "Left/model_con", "Left/Doco",
    }
    self:GetChildren(self.nodes)
    self.act_time = GetText(self.act_time)
    self.btn_text = GetText(self.btn_text)
    self.btn_img = GetImage(self.btn_go)

    self.task_obj = self.WeddingTaskItem.gameObject
    self.reco_obj = self.WeddingRecoItem.gameObject
    SetLocalPositionY(self.eft_con.transform, -137)
    SetLocalPositionY(self.model_con.transform, 0)
    SetLocalPositionY(self.act_time.transform, -35.7)

    self:AddEvent()
    self:InitPanel()
end

function WeddingView:AddEvent()
    local function callback()
        --勋鹿
        if self.model.wedding_btn_mode == 1 then
            MarryModel.GetInstance():GoNpc()
        elseif self.model.wedding_btn_mode == 2 then
            GlobalEvent:Brocast(OperateEvent.REQUEST_GET_REWARD, self.act_id, 4, 4)
        end
    end
    AddButtonEvent(self.btn_go.gameObject, callback)

    self.model_event[#self.model_event + 1] = self.model:AddListener(OpenHighEvent.SuccessFetchRewa, handler(self, self.HandleSuccessFetch))
    self.model_event[#self.model_event + 1] = self.model:AddListener(OpenHighEvent.UpdateTaskPro, handler(self, self.HandleUpdateTaskPro))

    self.recive_yy_log_event_id = GlobalEvent:AddListener(OperateEvent.DELIVER_YY_LOG, handler(self, self.HandleReciveYYLog))
end

function WeddingView:HandleUpdateTaskPro()
    self:LoadTaskItem()
    self:UpdateBtnShow()
end

function WeddingView:InitPanel()
    self:LoadRoleModel()
    self:LoadEft()
    self:InitTopShow()
    self:LoadTaskItem()
    self:UpdateBtnShow()
end

function WeddingView:LoadEft()
    if self.eft ~= nil then
        self.eft:destroy()
        self.eft = nil
    end
    self.eft = UIEffect(self.eft_con, 10311, false, self.layer)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.Left_Show.transform, nil, true, nil, false, 2)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.left_scroll.transform, nil, true, nil, false, 3)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.Left_Title.transform, nil, true, nil, false, 4)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.Doco.transform, nil, true, nil, false, 2)
end

function WeddingView:InitTopShow()
    local start_stamp = OperateModel.GetInstance():GetActStartTimeByActId(self.act_id)
    local start_time_tbl = TimeManager.GetInstance():GetTimeDate(start_stamp)
    local end_stamp = self.model.act_end_list[self.act_id]
    local end_time_tbl = TimeManager.GetInstance():GetTimeDate(end_stamp)
    local s_min = self:FormatNum(start_time_tbl.min)
    local s_hour = self:FormatNum(start_time_tbl.hour)
    local e_min = self:FormatNum(end_time_tbl.min)
    local e_hour = self:FormatNum(end_time_tbl.hour)
    self.act_time.text = string.format(ConfigLanguage.OpenHigh.WeddingOpenTime, start_time_tbl.year, start_time_tbl.month, start_time_tbl.day, tostring(s_hour), tostring(s_min), end_time_tbl.year, end_time_tbl.month, end_time_tbl.day, tostring(e_hour), tostring(e_min))
end

function WeddingView:FormatNum(num)
    return string.format("%02d", num)
end

function WeddingView:LoadTaskItem()
    local list = self.model:GetRewaCfByActId(self.act_id)
    self.task_item_list = self.task_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.task_item_list[i]
        if not item then
            item = WeddingTaskItem(self.task_obj, self.task_con)
            self.task_item_list[i] = item
        else
            item:SetVisible(true)
        end
        list[i].index = i
        item:SetData(list[i])
    end
    for i = len + 1, #self.task_item_list do
        local item = self.task_item_list[i]
        item:SetVisible(false)
    end
end

function WeddingView:UpdateBtnShow()
    local info = self.model:GetSingleTaskInfo(self.act_id, 4)
    local state = info.state
    if state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then
        self.model.wedding_btn_mode = 1
        ShaderManager:GetInstance():SetImageNormal(self.btn_img)
        self.btn_img.raycastTarget = true
        self.btn_text.text = ConfigLanguage.OpenHigh.WeddingBtnGoText
    elseif state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
        self.model.wedding_btn_mode = 2
        ShaderManager:GetInstance():SetImageNormal(self.btn_img)
        self.btn_img.raycastTarget = true
        self.btn_text.text = ConfigLanguage.OpenHigh.WeddingFetchBtnText
    elseif state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
        ShaderManager:GetInstance():SetImageGray(self.btn_img)
        self.btn_text.text = ConfigLanguage.OpenHigh.WeddingFeftchedText
        self.btn_img.raycastTarget = false
    end
end

function WeddingView:HandleSuccessFetch(data)
    if data.act_id == self.act_id and data.id == 4 then
        Notify.ShowText("Claimed")
        self:UpdateBtnShow()
    end
end

function WeddingView:HandleReciveYYLog(act_id, data)
    if act_id ~= self.act_id then
        return
    end
    self.model.wedding_reco_info = data
    --dump(self.model.wedding_reco_info, "<color=#6ce19b>WeddingView   WeddingView  WeddingView  WeddingView</color>")
    self:LoadReco()
end

function WeddingView:LoadReco()
    local list = self.model.wedding_reco_info
    self.reco_item_list = self.reco_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.reco_item_list[i]
        if not item then
            item = WeddingRecoItem(self.reco_obj, self.reco_con)
            self.reco_item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(list[i])
    end
    for i = len + 1, #self.reco_item_list do
        local item = self.reco_item_list[i]
        item:SetVisible(false)
    end
end

function WeddingView:LoadRoleModel()
    local role = RoleInfoModel.GetInstance():GetMainRoleData()
    local data = {}
    data = clone(role)
    local config = {}
    local model_id = role.gender == 1 and 11201 or 12201
    config.res_id = model_id
    config.is_show_wing = false
    --config.yPos = -56
    --config.y_rotate = 200
    data.figure.fashion_head = {}
    data.figure.fashion_head.model = model_id
    data.figure.fashion_head.show = true
    data.figure.weapon = {}
    data.figure.weapon.model = model_id
    data.figure.weapon.show = true

    config.trans_x = 400
    config.trans_y = 400
    self.role_model = UIRoleCamera(self.model_con, nil, data, 1, false, nil, config)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.role_model.transform, nil, true, nil, false, 2)
end