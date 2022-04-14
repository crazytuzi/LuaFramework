-- @Author: lwj
-- @Date:   2019-06-24 17:33:37 
-- @Last Modified time: 2019-06-24 17:33:39

ServiceMenuItem = ServiceMenuItem or class("ServiceMenuItem", BaseCloneItem)
local ServiceMenuItem = ServiceMenuItem

function ServiceMenuItem:ctor(parent_node, layer)
    ServiceMenuItem.super.Load(self)
end

function ServiceMenuItem:dctor()
    if self.select_event_id then
        self.model:RemoveListener(self.select_event_id)
        self.select_event_id = nil
    end
end

function ServiceMenuItem:LoadCallBack()
    self.model = MailModel.GetInstance()
    self.nodes = {
        "tog/Label", "tog",
    }
    self:GetChildren(self.nodes)
    self.tog = GetToggle(self.tog)
    self.des = GetText(self.Label)

    self:AddEvent()
end

function ServiceMenuItem:AddEvent()
    local function callback()
        self.model.last_ser_title = self.model.cur_ser_title
        self.model.cur_ser_title = self.data
        self.model.cur_ser_id = self.idx
        self.model:Brocast(MailEvent.ServiceTogClick, self.data)
    end
    AddClickEvent(self.tog.gameObject, callback)

    self.select_event_id = self.model:AddListener(MailEvent.ServiceTogClick, handler(self, self.Selecte))
end

function ServiceMenuItem:SetData(data, idx)
    self.data = data
    self.idx = idx
    self:UpdateView()
end

function ServiceMenuItem:UpdateView()
    self.des.text = self.data
    if self.data == "In-game issues" then
        self.model.last_ser_title = self.model.cur_ser_title
        self.model.cur_ser_title = self.data
        self.model.cur_ser_id = self.idx
        self.model:Brocast(MailEvent.ServiceTogClick, self.data)
    end
end

function ServiceMenuItem:Selecte(str)
    self.tog.isOn = self.data == str
end