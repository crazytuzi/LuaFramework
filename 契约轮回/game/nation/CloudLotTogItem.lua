-- @Author: lwj
-- @Date:   2019-12-20 14:33:30
-- @Last Modified time: 2019-12-20 14:33:30

CloudLotTogItem = CloudLotTogItem or class("CloudLotTogItem", BaseCloneItem)
local CloudLotTogItem = CloudLotTogItem

function CloudLotTogItem:ctor(parent_node, layer)
    CloudLotTogItem.super.Load(self)
end

function CloudLotTogItem:dctor()
    if self.grade_click_event_id then
        self.model:RemoveListener(self.grade_click_event_id)
        self.grade_click_event_id = nil
    end
end

function CloudLotTogItem:LoadCallBack()
    self.model = NationModel.GetInstance()
    self.nodes = {
        "tog", "icon", "tog/des",
    }
    self:GetChildren(self.nodes)
    self.toggle = GetToggle(self.tog)
    self.icon = GetImage(self.icon)
    self.des = GetText(self.des)

    self:AddEvent()
end

function CloudLotTogItem:AddEvent()
    local function cb()
        self.model.cur_cost = self.price
        self.model:Brocast(NationEvent.CloudGradeClick, self.times)
    end
    AddClickEvent(self.toggle.gameObject, cb)

    self.grade_click_event_id = self.model:AddListener(NationEvent.CloudGradeClick, handler(self, self.HandlelClick))
end

function CloudLotTogItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function CloudLotTogItem:UpdateView()
    local m_type = self.data[2][1]
    GoodIconUtil.GetInstance():CreateIcon(self, self.icon, tostring(m_type), true)
    self.price = self.data[2][2]
    self.times = self.data[1]
    self.des.text = string.format("%d/%d times", self.price, self.times)

    if self.times == self.model.cur_buy_times then
        self.model.cur_cost = self.price
        self.model:Brocast(NationEvent.CloudGradeClick, self.times)
    else
        self:HandlelClick(self.model.cur_buy_times)
    end
end

function CloudLotTogItem:HandlelClick(times)
    local is_self = self.times == times
    if is_self then
        self.model.cur_buy_times = times
    end
    self.toggle.isOn = is_self
end
