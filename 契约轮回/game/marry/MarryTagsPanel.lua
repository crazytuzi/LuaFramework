---
--- Created by  Administrator
--- DateTime: 2019/6/4 15:48
---
MarryTagsPanel = MarryTagsPanel or class("MarryTagsPanel", BasePanel)
local this = MarryTagsPanel

function MarryTagsPanel:ctor(parent_node, parent_panel)
    self.abName = "marry"
    self.assetName = "MarryTagsPanel"
    self.image_ab = "marry_image";
    self.layer = "UI"
    self.use_background = true
  --  self.panel_type = 3
    self.events = {}
    self.topItems = {}
    self.downItems = {}
    self.myTagsItems = {}
    self.model = MarryModel:GetInstance()
    self.show_sidebar = false        --是否显示侧边栏

end

function MarryTagsPanel:dctor()
    self.model:RemoveTabListener(self.events)

    for i, v in pairs(self.topItems) do
        v:destroy()
    end
    self.topItems = {}

    for i, v in pairs(self.downItems) do
        v:destroy()
    end
    self.downItems = {}

    for i, v in pairs(self.myTagsItems) do
        v:destroy()
    end
    self.myTagsItems = {}


    MarryController:GetInstance():RequsetDatingTag(self.model.selectTags)
end

function MarryTagsPanel:LoadCallBack()
    self.nodes = {
        "MarryTagsTopItem","topObj","ScrollView/Viewport/Content","MarryTagsTagItem","myObj/tagParent","myObj/num",
        "closeBtn"
    }
    self:GetChildren(self.nodes)
    self.num = GetText(self.num)
    self:InitUI()
    self:AddEvent()
   dump(self.model:GetTagList())
   -- dump(self.model:InitTagList())
   -- dump(self.model:InitTagList())
end

function MarryTagsPanel:InitUI()
    self:InitTopItems(self.model:GetTagList())
end

function MarryTagsPanel:InitTopItems(tab)
    local list = tab
    for i = 1, #list do
        self.topItems[i] = MarryTagsTopItem(self.MarryTagsTopItem.gameObject,self.topObj,"UI")
        self.topItems[i]:SetData(list[i],i)
    end
    self:ClickMarryTagsTopItem(1)
end

function MarryTagsPanel:AddEvent()


    local function call_back()
        self:Close()
    end
    AddClickEvent(self.closeBtn.gameObject,call_back)
    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.ClickMarryTagsTopItem,handler(self,self.ClickMarryTagsTopItem))
    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.ClickMarryTagsTagItem,handler(self,self.ClickMarryTagsTagItem))

  --  ClickMarryTagsTopItem
end

function MarryTagsPanel:ClickMarryTagsTopItem(groupId)
    self:UpdateLineItems(groupId)
    self:SetSelect(groupId)
end

function MarryTagsPanel:ClickMarryTagsTagItem(item)
    if item.isSelect == true then
        table.insert(self.model.selectTags,item.data.id)
    else
        table.removebyvalue(self.model.selectTags,item.data.id)
    end
    if item.type == 1 then
        item:SetSelect(item.isSelect)
    else
        for i = 1, #self.downItems do
            if item.data.id == self.downItems[i].data.id then
                self.downItems[i]:SetSelect(false)
                break
            end
        end
    end
    self:UpdateMyTagsItems(self.model.selectTags)
    dump(self.model.selectTags)
end

function MarryTagsPanel:SetSelect(groupId)
    for i = 1, #self.topItems do
        if groupId == self.topItems[i].groupId then
            self.topItems[i]:SetShow(true)
        else
            self.topItems[i]:SetShow(false)
        end
    end
end

function MarryTagsPanel:UpdateLineItems(groupId)
    local tab = self.topItems[groupId].data
    table.sort(tab, function(a,b)
            return a.id < b.id
    end)
    self.downItems = self.downItems or {}
    for i = 1, #tab do
        local item =  self.downItems[i]
        if  not item then
            item = MarryTagsTagItem(self.MarryTagsTagItem.gameObject,self.Content,"UI")
            self.downItems[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(tab[i],1,self.model:isMyTagsShow(tab[i].id))
    end
    for i = #tab + 1,#self.downItems do
        local item = self.downItems[i]
        item:SetVisible(false)
    end
    self:UpdateMyTagsItems(self.model.selectTags)
end

function MarryTagsPanel:UpdateMyTagsItems(tags)
    local tab = tags
    self.myTagsItems = self.myTagsItems or {}

    for i = 1, #tab do
        local item =  self.myTagsItems[i]
        if  not item then
            item = MarryTagsTagItem(self.MarryTagsTagItem.gameObject,self.tagParent,"UI")
            self.myTagsItems[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(Config.db_dating_tag[tab[i]],2,self.model:isMyTagsShow(tab[i]))
    end
    for i = #tab + 1,#self.myTagsItems do
        local item = self.myTagsItems[i]
        item:SetVisible(false)
    end
    self.num.text = string.format("(%s/3)",#tab)
end

function MarryTagsPanel:SetSelectTags()
    
end

function MarryTagsPanel:InitLine()

end