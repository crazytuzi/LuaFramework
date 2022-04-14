-- @Author: lwj
-- @Date:   2019-06-17 11:10:08
-- @Last Modified time: 2019-06-17 11:10:10

FirstPayDayItem = FirstPayDayItem or class("FirstPayDayItem", BaseCloneItem)
local FirstPayDayItem = FirstPayDayItem

function FirstPayDayItem:ctor(parent_node, layer)
    FirstPayDayItem.super.Load(self)
end

function FirstPayDayItem:dctor()
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
    if self.fetch_success_event_id then
        self.model:RemoveListener(self.fetch_success_event_id)
        self.fetch_success_event_id = nil
    end
    if self.select_event_id then
        self.model:RemoveListener(self.select_event_id)
        self.select_event_id = nil
    end
end

function FirstPayDayItem:LoadCallBack()
    self.model = FirstPayModel.GetInstance()
    self.nodes = {
        "bg",
        "des",
        "sel_img",
        'red_con',
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)

    self:AddEvent()
end

function FirstPayDayItem:AddEvent()
    self.select_event_id = self.model:AddListener(FirstPayEvent.DayItemClick, handler(self, self.Selecte))

    local function callback()
        self.model:Brocast(FirstPayEvent.DayItemClick, self.data)
    end
    AddClickEvent(self.bg.gameObject, callback)

    self.fetch_success_event_id = self.model:AddListener(FirstPayEvent.FetchSuccess, handler(self, self.HandleSuccess))
end

function FirstPayDayItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function FirstPayDayItem:UpdateView()
    self.des.text = "Day "..self.data
    if self.model.cur_show_day == self.data then
        self.model:Brocast(FirstPayEvent.DayItemClick, self.data)
    end
    self:SetRedDot(self.model:IsCanFetch(self.data))
    if self.data == self.model.cur_show_day then
        self.model:Brocast(FirstPayEvent.DayItemClick, self.data)
    end
end

function FirstPayDayItem:Selecte(idx)
    SetVisible(self.sel_img, self.data == idx)
end

function FirstPayDayItem:HandleSuccess()
    if not self.data == self.model.cur_show_day then
        return
    end
    self:SetRedDot(false)
end

function FirstPayDayItem:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end