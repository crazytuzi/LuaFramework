---
--- Created by  Administrator
--- DateTime: 2019/9/24 19:51
---
StigmasSelectItem = StigmasSelectItem or class("StigmasSelectItem", BaseCloneItem)
local this = StigmasSelectItem

function StigmasSelectItem:ctor(obj, parent_node, parent_panel)
    StigmasSelectItem.super.Load(self)
    self.events = {}
    self.subItems = {}
end

function StigmasSelectItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.subItems then
        for i, v in pairs(self.subItems) do
            v:destroy()
        end
    end
    self.subItems = {}
end

function StigmasSelectItem:LoadCallBack()
    self.nodes = {
        "StigmasSelectSubItem","title","itemParent","bg"
    }
    self:GetChildren(self.nodes)
    self.title = GetImage(self.title)
    self.bg = GetImage(self.bg)
    self:InitUI()
    self:AddEvent()
end

function StigmasSelectItem:InitUI()

end

function StigmasSelectItem:AddEvent()

end

function StigmasSelectItem:SetData(data,color)
    self.data = data
    self.color = color
    dump(self.data)
    self:InitGods()
    self:UpdateInfo()
end

function StigmasSelectItem:InitGods()
    for godId, v in table.pairsByKey(self.data) do
        local item = self.subItems[godId]
        if not item then
            item = StigmasSelectSubItem(self.StigmasSelectSubItem.gameObject,self.itemParent,"UI")
            self.subItems[godId] = item
            item:SetData(godId)
        end
    end
end
function StigmasSelectItem:UpdateInfo()
    lua_resMgr:SetImageTexture(self, self.bg, "stigmas_image", "stigmas_godbg" .. self.color, true)
    lua_resMgr:SetImageTexture(self, self.title, "stigmas_image", "stigmas_godTitle" .. self.color, true)
end

function StigmasSelectItem:UpdateSubInfo()
    for i, v in pairs(self.subItems) do
        v:UpdateInfo()
    end
end

function StigmasSelectItem:UpdateSubBtnState()
    for i, v in pairs(self.subItems) do
        v:SetBtnState()
    end
end