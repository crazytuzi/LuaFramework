-- @Author: lwj
-- @Date:   2019-12-26 10:17:49 
-- @Last Modified time: 2019-12-26 10:17:54

CloudTopItem = CloudTopItem or class("CloudTopItem", BaseCloneItem)
local CloudTopItem = CloudTopItem

function CloudTopItem:ctor(parent_node, layer)
    self.color_str = ""

    CloudTopItem.super.Load(self)
end

function CloudTopItem:dctor()
    if self.sel_event_id then
        self.model:RemoveListener(self.sel_event_id)
        self.sel_event_id = nil
    end
end

function CloudTopItem:LoadCallBack()
    self.model = NationModel.GetInstance()
    self.nodes = {
        "bg", "des", "sel_img",
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)

    self:AddEvent()
end

function CloudTopItem:AddEvent()
    local function callback()
        self.model:Brocast(NationEvent.CloundTogClick, self.data, true)
    end
    AddClickEvent(self.bg.gameObject, callback)

    self.sel_event_id = self.model:AddListener(NationEvent.CloundTogClick, handler(self, self.Select))
end

function CloudTopItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function CloudTopItem:UpdateView()
    if self.data == self.model.defa_top_idx then
        self.model:Brocast(NationEvent.CloundTogClick, self.data, false)
    else
        self:Select(self.model.defa_top_idx)
    end
end

function CloudTopItem:Select(idx)
    local is_self = idx == self.data
    SetVisible(self.sel_img, is_self)
    local str = is_self and "8584b0" or "fefefe"
    if str ~= self.color_str then
        self.color_str = str
        local name = self.data == 1 and "Diamond" or "Bound Diamond"
        self.des.text = string.format("<color=#%s>%s</color>", str, name)
    end
end