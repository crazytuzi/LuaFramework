HistroyItem = HistroyItem or class("HistroyItem", BaseCloneItem)
local HistroyItem = HistroyItem

function HistroyItem:ctor(parent_node, layer)
    HistroyItem.super.Load(self)
end

function HistroyItem:dctor()
end

function HistroyItem:LoadCallBack()
    --self.model = CanMdyModel.GetInstance()
    self.nodes = {
        "bg", "Text",
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.Text)

    self:AddEvent()
end

function HistroyItem:AddEvent()
    local function callback()
        GlobalEvent:Brocast(MainEvent.UpdateGMPanelInput, self.data)
    end
    AddClickEvent(self.bg.gameObject, callback)
end

function HistroyItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function HistroyItem:UpdateView()
    self.des.text = self.data
end