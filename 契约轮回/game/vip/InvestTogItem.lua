-- @Author: lwj
-- @Date:   2019-06-04 18:00:20
-- @Last Modified time: 2019-06-04 19:05:08

InvestTogItem = InvestTogItem or class("InvestTogItem", BaseCloneItem)
local InvestTogItem = InvestTogItem

function InvestTogItem:ctor(parent_node, layer)
    InvestTogItem.super.Load(self)
end

function InvestTogItem:dctor()
    for i = 1, #self.model_event do
        self.model:RemoveListener(self.model_event[i])
    end
    self.model_event = {}
end

function InvestTogItem:LoadCallBack()
    self.model = VipModel.GetInstance()
    self.nodes = {
        "tog/Background", "Label", "tog", "icon",
    }
    self:GetChildren(self.nodes)
    self.tog = GetToggle(self.tog)
    self.icon = GetImage(self.icon)
    self.num = GetText(self.Label)

    self:AddEvent()
end

function InvestTogItem:AddEvent()
    local function callback()
        self:ClickFun()
    end
    AddClickEvent(self.tog.gameObject, callback)

    self.model_event = {}
    self.model_event[#self.model_event + 1] = self.model:AddListener(VipEvent.InvestTogClick, handler(self, self.Selected))
end

function InvestTogItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function InvestTogItem:UpdateView()
    local is_default = self.data.grade == self.model.default_tog
    if is_default then
        self:ClickFun()
    end
    self.grade_tbl = String2Table(self.data.price)[1]
    self.num.text = self.grade_tbl[2]
    GoodIconUtil.GetInstance():CreateIcon(self, self.icon, tostring(self.grade_tbl[1]), true)
end

function InvestTogItem:ClickFun()
    self.model.cur_sel_grade = self.data.grade
    self.model:Brocast(VipEvent.InvestTogClick, self.data.grade)
end

function InvestTogItem:Selected(grade)
    local is_show = self.data.grade == grade
    self.tog.isOn = is_show
end