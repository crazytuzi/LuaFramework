-- @Author: lwj
-- @Date:   2019-09-23 15:57:15  
-- @Last Modified time: 2019-09-23 15:57:20

NationSeqDailyItem = NationSeqDailyItem or class("NationSeqDailyItem", BaseCloneItem)
local NationSeqDailyItem = NationSeqDailyItem

function NationSeqDailyItem:ctor(parent_node, layer)
    self.title_x = 13.7
    self.icon_width = 25

    self.rewa_item_list = {}
    NationSeqDailyItem.super.Load(self)
end

function NationSeqDailyItem:dctor()
    for i, v in pairs(self.rewa_item_list) do
        if v then
            v:destroy()
        end
    end
    self.rewa_item_list = {}
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
end

function NationSeqDailyItem:LoadCallBack()
    self.nodes = {
        "fin_img", "title", "rewa_con", "icon", "tail", "btn_go/btn_text", "btn_go", "btn_go/red_con",
    }
    self:GetChildren(self.nodes)
    self.title_rect = GetRectTransform(self.title)
    self.title = GetText(self.title)
    self.icon_rect = GetRectTransform(self.icon)
    self.tail_rect = GetRectTransform(self.tail)
    self.btn_img = GetImage(self.btn_go)
    self.btn_text = GetText(self.btn_text)

    self:AddEvent()
end

function NationSeqDailyItem:AddEvent()
    local function callback()
        if self.ser_data.state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then
            OpenLink(401, 2)
            self.model:Brocast(NationEvent.CloseNationPanel)
        elseif self.ser_data.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
            GlobalEvent:Brocast(OperateEvent.REQUEST_GET_REWARD, self.data.act_id, self.data.id, self.data.level)
        end
    end
    AddButtonEvent(self.btn_go.gameObject, callback)
end

function NationSeqDailyItem:SetData(data, stencil_id, stencil_type, model)
    self.stencil_id = stencil_id
    self.stencil_type = stencil_type
    self.data = data
    self.model = model or NationModel.GetInstance()
    self.ser_data = self.model:GetSingleTaskInfo(self.data.act_id, self.data.id)
    self:UpdateView()
end

function NationSeqDailyItem:UpdateView()
    self:LoadReward()
    local des = self.data.desc
    local tar = String2Table(self.data.task)[2]
    if not tar then
        tar = "0"
    end
    local str = string.format(ConfigLanguage.Nation.DailyRechargeTitle, des, self.ser_data.count, tar)
    self.title.text = str
    self:UpdatePos()
    self:UpdateBtnState()
end

function NationSeqDailyItem:UpdatePos()
    SetAnchoredPosition(self.title_rect, self.title_x, 0)
    local title_width = self.title.preferredWidth
    local icon_x = self.title_x + title_width + 1
    SetAnchoredPosition(self.icon_rect, icon_x, -2)
    local tail_x = icon_x + self.icon_width + 1
    SetAnchoredPosition(self.tail_rect, tail_x, 0)
end

function NationSeqDailyItem:LoadReward()
    self.rewa_item_list = self.rewa_item_list or {}
    local list = String2Table(self.data.reward)
    local len = #list
    for i = 1, len do
        local item = self.rewa_item_list[i]
        if not item then
            item = GoodsIconSettorTwo(self.rewa_con)
            self.rewa_item_list[i] = item
        else
            item:SetVisible(true)
        end
        local data = list[i]
        local param = {}
        local operate_param = {}
        param["item_id"] = data[1]
       -- param["model"] = self.model
        param["can_click"] = true
        param["operate_param"] = operate_param
        param["size"] = { x = 60, y = 60 }
        param["num"] = data[2]
        param.bind = data[3]
        --local color = Config.db_item[data[1]].color - 1
        --param["color_effect"] = color
        --param["effect_type"] = 2  --活动特效：2
        param['stencil_id'] = self.stencil_id
        param['stencil_type'] = self.stencil_type
        item:SetIcon(param)
    end
    for i = len + 1, #self.rewa_item_list do
        local item = self.rewa_item_list[i]
        item:SetVisible(false)
    end
end

function NationSeqDailyItem:UpdateBtnState()
    local state = self.ser_data.state
    if state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then
        SetVisible(self.btn_go, true)
        self:SetRedDot(false)
        SetVisible(self.fin_img, false)
        self.btn_text.text = ConfigLanguage.Nation.Recharge
    elseif state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
        SetVisible(self.fin_img, false)
        SetVisible(self.btn_go, true)
        self:SetRedDot(true)
        self.btn_text.text = ConfigLanguage.Nation.Fetch
    elseif state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
        SetVisible(self.btn_go, false)
        SetVisible(self.fin_img, true)
        self:SetRedDot(false)
        --self.btn_img.raycastTarget = true
        --ShaderManager:GetInstance():SetImageNormal(self.btn_img)
        --self.btn_text.text = ConfigLanguage.Nation.Fetch
    end
end

function NationSeqDailyItem:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end

function NationSeqDailyItem:HandleSuccessExchange(data)
    if data.act_id ~= self.data.act_id or self.data.id ~= data.id then
        return
    end
    self.ser_data.state = enum.YY_TASK_STATE.YY_TASK_STATE_REWARD
    self:UpdateBtnState()
end