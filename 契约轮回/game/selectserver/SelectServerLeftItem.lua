---
--- Created by  Administrator
--- DateTime: 2019/2/21 10:48
---
SelectServerLeftItem = SelectServerLeftItem or class("SelectServerLeftItem", BaseCloneItem)
local this = SelectServerLeftItem

function SelectServerLeftItem:ctor(obj, parent_node, parent_panel)
    SelectServerLeftItem.super.Load(self)
    self.events = {}
    self.model = SelectServerModel:GetInstance()
end

function SelectServerLeftItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function SelectServerLeftItem:LoadCallBack()
    self.nodes =
    {
        "bg","name","select"
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self:InitUI()
    self:AddEvent()
end

function SelectServerLeftItem:InitUI()

end

function SelectServerLeftItem:AddEvent()
    local function call_back()
        self.model:Brocast(SelectServerEvent.SelectServerLeftClick,self.data,self.index)
    end
    AddClickEvent(self.bg.gameObject,call_back)
end

function SelectServerLeftItem:SetData(list,index)
    self.data = list
    self.index = index
    self:SetInfo()
end
function SelectServerLeftItem:SetInfo()
    if self.index == 1 then  --推荐服务器
        self.name.text = "Recommended"
    elseif self.index == 2 then  --最近登录过的服务器
        self.name.text = "Recent login"
    else
        local str = string.format("S%s-%s",(self.index-3)*100 + 1,(self.index - 2) * 100)
        self.name.text = str
    end
end

function SelectServerLeftItem:Select(show)
    SetVisible(self.select,show)
end