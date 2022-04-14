-- @Author: lwj
-- @Date:   2019-09-21 17:03:48 
-- @Last Modified time: 2019-09-21 17:03:50

NationSeqRewaItem = NationSeqRewaItem or class("NationSeqRewaItem", BaseCloneItem)
local NationSeqRewaItem = NationSeqRewaItem

function NationSeqRewaItem:ctor(parent_node, layer, model)
    self.model = model
    NationSeqRewaItem.super.Load(self)
end

function NationSeqRewaItem:dctor()
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
    if self.good then
        self.good:destroy()
        self.good = nil
    end
    if self.success_exchange_event_id then
        GlobalEvent:RemoveListener(self.success_exchange_event_id)
        self.success_exchange_event_id = nil
    end
    if self.update_info_event_id then
        self.model:RemoveListener(self.update_info_event_id)
        self.update_info_event_id = nil
    end
end

function NationSeqRewaItem:LoadCallBack()
    self.nodes = {
        "mask", "item_con", "tag", "red_con",
    }
    self:GetChildren(self.nodes)

    self:AddEvent()
end

function NationSeqRewaItem:AddEvent()
    local function callback()
        GlobalEvent:Brocast(OperateEvent.REQUEST_GET_REWARD, self.data.act_id, self.data.id, self.data.level)
    end
    AddClickEvent(self.mask.gameObject, callback)

    self.success_exchange_event_id = GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD, handler(self, self.HandleSuccessExchange))
    self.update_info_event_id = self.model:AddListener(NationEvent.UpdateRewardInfo, handler(self, self.HandleUpdateRewardInfo))
end

function NationSeqRewaItem:SetData(data, stencil_id, stencil_type)
    self.stencil_id = stencil_id
    self.stencil_type = stencil_type
    self.data = data

    self.ser_data = self.model:GetSingleTaskInfo(self.data.act_id, self.data.id)
    self:UpdateView()
end

function NationSeqRewaItem:UpdateView()
    local rewa_tbl = String2Table(self.data.reward)[1]
    local item_id = rewa_tbl[1]
    local num = rewa_tbl[2]
    if not self.good then
        self.good = GoodsIconSettorTwo(self.item_con)
    end
    local param = {}
    local operate_param = {}
    param["item_id"] = item_id
   -- param["model"] = self.model
    param["can_click"] = true
    param["operate_param"] = operate_param
    param["size"] = { x = 76, y = 76 }
    param["num"] = num
    if self.ser_data.state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then
        param["color_effect"] = nil
        param["effect_type"] = nil
        SetVisible(self.mask, false)
        SetVisible(self.tag, false)
        self:SetRedDot(false)
    elseif self.ser_data.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
        SetVisible(self.mask, true)
        SetVisible(self.tag, false)
        local color = Config.db_item[item_id].color - 1
        param["color_effect"] = color
        param["effect_type"] = 2
        param['stencil_id'] = self.stencil_id
        param['stencil_type'] = self.stencil_type
        self:SetRedDot(true)
    elseif self.ser_data.state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
        param["color_effect"] = nil
        param["effect_type"] = nil
        SetVisible(self.mask, false)
        SetVisible(self.tag, true)
        self:SetRedDot(false)
    end
    self.good:SetIcon(param)
end

function NationSeqRewaItem:HandleSuccessExchange(data)
    if data.act_id ~= self.data.act_id or data.id ~= self.data.id then
        return
    end
    self.ser_data.state = enum.YY_TASK_STATE.YY_TASK_STATE_REWARD
    self:UpdateView()
end

function NationSeqRewaItem:HandleUpdateRewardInfo()
    self.ser_data = self.model:GetSingleTaskInfo(self.data.act_id, self.data.id)
    self:UpdateView()
end

function NationSeqRewaItem:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end