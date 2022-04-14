-- @Author: lwj
-- @Date:   2019-08-30 15:45:27 
-- @Last Modified time: 2019-08-30 15:45:29

ClubFightItem = ClubFightItem or class("ClubFightItem", BaseCloneItem)
local ClubFightItem = ClubFightItem

function ClubFightItem:ctor(parent_node, layer)
    ClubFightItem.super.Load(self)
end

function ClubFightItem:dctor()
    if not table.isempty(self.rewa_item_list) then
        for i, v in pairs(self.rewa_item_list) do
            if v then
                v:destroy()
            end
        end
        self.rewa_item_list = {}
    end
    if self.success_exchange_event_id then
        self.model:RemoveListener(self.success_exchange_event_id)
        self.success_exchange_event_id = nil
    end
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
end

function ClubFightItem:LoadCallBack()
    self.model = OpenHighModel.GetInstance()
    self.nodes = {
        "des", "rewa_con", "btn_fetch", "btn_gray", "btn_gray/Text", "btn_fetch/red_con",
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)
    self.gray_text = GetText(self.Text)

    self:AddEvent()
    self:SetRedDot(true)
end

function ClubFightItem:AddEvent()
    local function callback()
        GlobalEvent:Brocast(OperateEvent.REQUEST_GET_REWARD, self.data.act_id, self.data.id, self.data.level)
    end
    AddButtonEvent(self.btn_fetch.gameObject, callback)

    self.success_exchange_event_id = self.model:AddListener(OpenHighEvent.SuccessFetchRewa, handler(self, self.HandleSuccessFetch))
end

function ClubFightItem:SetData(data)
    self.data = data
    self.ser_data = self.model:GetSingleTaskInfo(self.data.act_id, self.data.id)
    self:UpdateView()
end

function ClubFightItem:UpdateView()
    self.des.text = self.data.name
    self:LoadRewa()
    self:UpdateBtnShow()
end

function ClubFightItem:LoadRewa()
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
        local rewa_data = list[i]
        local param = {}
        local operate_param = {}
        param["item_id"] = rewa_data[1]
        param["model"] = self.model
        param["can_click"] = true
        param["operate_param"] = operate_param
        param["size"] = { x = 64, y = 64 }
        param["num"] = rewa_data[2]
        param.bind = rewa_data[3]
        --local color = Config.db_item[id].color - 1
        --param["color_effect"] = color
        --param["effect_type"] = 2  --活动特效：2
        item:SetIcon(param)
    end
    for i = len + 1, #self.rewa_item_list do
        local item = self.rewa_item_list[i]
        item:SetVisible(false)
    end
end

function ClubFightItem:UpdateBtnShow()
    if self.ser_data.state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then
        SetVisible(self.btn_gray, true)
        SetVisible(self.btn_fetch, false)
        self.gray_text.text = ConfigLanguage.OpenHigh.FetchText
    elseif self.ser_data.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
        SetVisible(self.btn_gray, false)
        SetVisible(self.btn_fetch, true)
    elseif self.ser_data.state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
        SetVisible(self.btn_gray, true)
        SetVisible(self.btn_fetch, false)
        self.gray_text.text = ConfigLanguage.OpenHigh.AlreadyFetch
    end
end

function ClubFightItem:HandleSuccessFetch(data)
    if data.act_id ~= self.data.act_id or self.data.id ~= data.id then
        return
    end
    self.ser_data.state = enum.YY_TASK_STATE.YY_TASK_STATE_REWARD
    self:UpdateBtnShow()
end

function ClubFightItem:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end
