---
--- Created by  Administrator
--- DateTime: 2019/6/5 15:00
---
MarryTagsTagItem = MarryTagsTagItem or class("MarryTagsTagItem", BaseCloneItem)
local this = MarryTagsTagItem

function MarryTagsTagItem:ctor(obj, parent_node, parent_panel)
    MarryTagsTagItem.super.Load(self)
    self.model = MarryModel:GetInstance()
    self.isSelect = false
    self.events = {}
end

function MarryTagsTagItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function MarryTagsTagItem:LoadCallBack()
    self.nodes = {
        "name","bg","select","closeBtn"
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self:InitUI()
    self:AddEvent()
end

function MarryTagsTagItem:InitUI()

end

function MarryTagsTagItem:AddEvent()
    local function call_back()
        if self.type ~= 1 then
            return
        end
        if #self.model.selectTags >= 3 and self.isSelect == false then
            Notify.ShowText("You can set up to 3 tags!")
            return
        end
        self.isSelect = not self.isSelect
        self.model:Brocast(MarryEvent.ClickMarryTagsTagItem,self)
    end
    AddClickEvent(self.bg.gameObject,call_back)


    local function call_back()
        if self.type ~= 2  then
            return
        end
        self.isSelect = false
        self.model:Brocast(MarryEvent.ClickMarryTagsTagItem,self)
    end
    AddClickEvent(self.closeBtn.gameObject,call_back)
end

function MarryTagsTagItem:SetData(data,type,isShow)
    self.data = data
    self.type = type
    self.isSelect = isShow
    if type == 1 then
        self:SetSelect(self.isSelect)
    end
    SetVisible(self.closeBtn,self.type == 2)
    self.name.text = data.tag
end

function MarryTagsTagItem:SetSelect(isShow)
    self.isSelect = isShow
    SetVisible(self.select,isShow)
end