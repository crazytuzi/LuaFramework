-- @Author: lwj
-- @Date:   2019-08-12 11:37:08 
-- @Last Modified time: 2019-08-12 11:37:11

CreateClubItem = CreateClubItem or class("CreateClubItem", BaseCloneItem)
local CreateClubItem = CreateClubItem

function CreateClubItem:ctor(parent_node, layer)
    CreateClubItem.super.Load(self)
end

function CreateClubItem:dctor()
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
    if self.success_exchange_event_id then
        self.model:RemoveListener(self.success_exchange_event_id)
        self.success_exchange_event_id = nil
    end
    if self.rewa_item_list then
        for i, v in pairs(self.rewa_item_list) do
            if v then
                v:destroy()
            end
        end
        self.rewa_item_list = {}
    end
end

function CreateClubItem:LoadCallBack()
    self.model = OpenHighModel.GetInstance()
    self.nodes = {
        "count", "title", "rewa_con", "btn_get", "btn_gray", "btn_get/red_con",
    }
    self:GetChildren(self.nodes)
    self.title = GetText(self.title)
    self.count = GetText(self.count)

    self:AddEvent()
    self:SetRedDot(true)
end

function CreateClubItem:AddEvent()
    local function callback()
        GlobalEvent:Brocast(OperateEvent.REQUEST_GET_REWARD, self.data.act_id, self.data.id, self.data.level)
    end
    AddButtonEvent(self.btn_get.gameObject, callback)

    self.success_exchange_event_id = self.model:AddListener(OpenHighEvent.SuccessFetchRewa, handler(self, self.HandleSuccessExchange))
end

function CreateClubItem:SetData(data)
    self.data = data
    self.ser_data = self.model:GetSingleTaskInfo(self.data.act_id, self.data.id)
    self:UpdateView()
end

function CreateClubItem:UpdateView()
    self.title.text = self.data.name
    self:LoadRewa()
    self:UpdateState()
end

function CreateClubItem:LoadRewa()
    local list = String2Table(self.data.reward)
    self.rewa_item_list = self.rewa_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.rewa_item_list[i]
        if not item then
            item = GoodsIconSettorTwo(self.rewa_con)
            self.rewa_item_list[i] = item
        else
            item:SetVisible(true)
        end
        local id = list[i][1]
        local param = {}
        local operate_param = {}
        param["item_id"] = id
        param["model"] = self.model
        param["can_click"] = true
        param["operate_param"] = operate_param
        param["size"] = { x = 70, y = 70 }
        param["num"] = list[i][2]
        param.bind = list[i][3]
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

function CreateClubItem:UpdateState()
    local sum = String2Table(self.data.limit)[2]
    local remain = sum - self.ser_data.count
    local color_str = "FFF3DD"
    local no_rest = remain <= 0
    if no_rest then
        color_str = "fd2c2c"
        remain = 0
    end
    local is_can_get = self.ser_data.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH
    SetVisible(self.btn_get, is_can_get)
    SetVisible(self.btn_gray, not is_can_get)
    if no_rest and is_can_get then
        SetVisible(self.btn_get, not no_rest)
        SetVisible(self.btn_gray, no_rest)
    end
    self.count.text = "<color=#" .. color_str .. ">" .. remain .. "</color>"
end

function CreateClubItem:HandleSuccessExchange(data)
    if data.act_id ~= self.data.act_id or self.data.id ~= data.id then
        return
    end
    self.ser_data.count = self.ser_data.count + 1
    self.ser_data.state = enum.YY_TASK_STATE.YY_TASK_STATE_REWARD
    self:UpdateState()
end

function CreateClubItem:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end