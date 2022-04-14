-- @Author: lwj
-- @Date:   2019-01-29 19:16:43
-- @Last Modified time: 2019-01-29 19:16:46


WeekItem = WeekItem or class("WeekItem", BaseCloneItem)
local WeekItem = WeekItem

function WeekItem:ctor(parent_node, layer)
    WeekItem.super.Load(self)
end

function WeekItem:dctor()
    if self.selectshow_event_id then
        self.model:RemoveListener(self.selectshow_event_id)
    end
    self.selectshow_event_id = nil
end

function WeekItem:LoadCallBack()
    self.model = DailyModel.GetInstance()
    self.nodes = {
        "sel", "cont",
    }
    self:GetChildren(self.nodes)
    self.cont = GetText(self.cont)
    self:AddEvent()
end

function WeekItem:AddEvent()
    self.selectshow_event_id = self.model:AddListener(DailyEvent.SelectWeekItem, handler(self, self.Select))
end

function WeekItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function WeekItem:UpdateView()
    local tbl = string.split(self.data.cont, "&")
    if tbl[2] then
        self.cont.text = tbl[1] .. "\n" .. tbl[2]
    else
        self.cont.text = tbl[1]
    end
    if self.cont.text == "empty" then
        self.cont.text = ""
    end
end

function WeekItem:Select(index)
    local is_sel = index == self.data.index
    SetVisible(self.sel, is_sel)
    if is_sel then
        SetColor(self.cont, 103, 83, 68, 255)
    else
        SetColor(self.cont, 122, 72, 59, 255)
    end
end