---
--- Created by  Administrator
--- DateTime: 2019/6/5 14:37
---
MarryFriendTagItem = MarryFriendTagItem or class("MarryFriendTagItem", BaseItem)
local this = MarryFriendTagItem

function MarryFriendTagItem:ctor(parent_node,layer)
    self.abName = "marry"
    self.assetName = "MarryFriendTagItem"
    self.layer = layer
    self.events = {}
    self.model = MarryModel:GetInstance()
    self.is_need_setData = false
    MarryFriendTagItem.super.Load(self)
end

function MarryFriendTagItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function MarryFriendTagItem:LoadCallBack()
    self.nodes = {
        "name","bg"
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self:InitUI()
    if self.is_need_setData then
        self:SetData(self.data,self.type)
    end
    self:AddEvent()
end

function MarryFriendTagItem:InitUI()

end

function MarryFriendTagItem:AddEvent()
    local function call_back()
        if self.type ~= 1 then
            return
        end
        lua_panelMgr:GetPanelOrCreate(MarryTagsPanel):Open()
    end
    AddClickEvent(self.bg.gameObject,call_back)
end

--type == 1自己的 type == 2他人的
function MarryFriendTagItem:SetData(data,type)
    self.data = data
    self.type = type
    if not self.is_loaded then
        self.is_need_setData = true
        return
    end
    local cfg = Config.db_dating_tag[self.data]
    if not cfg then
        return
    end
    self.name.text = cfg.tag
end