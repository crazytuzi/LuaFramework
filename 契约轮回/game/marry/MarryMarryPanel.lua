---
--- Created by  Administrator
--- DateTime: 2019/6/3 14:40
---
MarryMarryPanel = MarryMarryPanel or class("MarryMarryPanel", BaseItem)
local this = MarryMarryPanel

function MarryMarryPanel:ctor(parent_node, parent_panel)
    self.abName = "marry";
    self.assetName = "MarryMarryPanel"
    self.layer = "UI"
    self.events = {}
    self.items = {}
    self.model = MarryModel:GetInstance()
    MarryMarryPanel.super.Load(self)
end

function MarryMarryPanel:dctor()
    self.model:RemoveTabListener(self.events)
    for _, item in pairs(self.items) do
        item:destroy()
    end
    self.items = {}
end

function MarryMarryPanel:LoadCallBack()
    self.nodes = {
        "MarryMarryItem","content",
    }
    self:GetChildren(self.nodes)
    --self:InitUI()
    self:AddEvent()
    MarryController:GetInstance():ResusetMarriageStep()  --三步走信息
end

function MarryMarryPanel:InitUI()
    local cfg = Config.db_marriage_step
    for i = 1, #cfg do
        local item = self.items[i]
        if not item then
            self.items[i] = MarryMarryItem(self.MarryMarryItem.gameObject,self.content,"UI")
            self.items[i]:SetData(cfg[i])
        else
            item:SetData(cfg[i])
        end
    end
end
function MarryMarryPanel:AddEvent()
   self.events[#self.events + 1] = self.model:AddListener(MarryEvent.MarryMarriageInfo,handler(self,self.MarryMarriageInfo))
end

function MarryMarryPanel:MarryMarriageInfo(data)
    print2("三步走信息")
    dump(data)
    self:InitUI()
end

