-- @Author: lwj
-- @Date:   2019-06-17 11:10:08
-- @Last Modified time: 2019-06-17 11:10:10

SecPayDayItem = SecPayDayItem or class("SecPayDayItem", BaseCloneItem)
local SecPayDayItem = SecPayDayItem

function SecPayDayItem:ctor(parent_node, layer)
    SecPayDayItem.super.Load(self)
end

function SecPayDayItem:dctor()
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

function SecPayDayItem:LoadCallBack()
    self.model = SecPayModel.GetInstance()
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

function SecPayDayItem:AddEvent()
    self.select_event_id = self.model:AddListener(SecPayEvent.DayItemClick, handler(self, self.Selecte))

    local function callback()
        self.model:Brocast(SecPayEvent.DayItemClick, self.data)
    end
    AddClickEvent(self.bg.gameObject, callback)

    self.fetch_success_event_id = self.model:AddListener(FirstPayEvent.FetchSuccess, handler(self, self.HandleSuccess))
end

function SecPayDayItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function SecPayDayItem:UpdateView()
    self.des.text = "Day ".. self.data
    if self.model.cur_show_day == self.data then
        self.model:Brocast(SecPayEvent.DayItemClick, self.data)
    end

    self:SetRedDot(self.model:IsCanFetch(self.data, 1))
    if self.data == self.model.cur_show_day then
        self.model:Brocast(FirstPayEvent.DayItemClick, self.data)
    end
end

function SecPayDayItem:Selecte(idx)
    SetVisible(self.sel_img, self.data == idx)
end

function SecPayDayItem:HandleSuccess()
    if not self.data == self.model.cur_show_day then
        return
    end
    self:SetRedDot(false)
end

function SecPayDayItem:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end