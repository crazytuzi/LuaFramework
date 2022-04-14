---
--- Created by  Administrator
--- DateTime: 2019/9/24 19:43
---
StigmasSelectPanel = StigmasSelectPanel or class("StigmasSelectPanel", WindowPanel)
local this = StigmasSelectPanel

function StigmasSelectPanel:ctor(parent_node, parent_panel)
    self.abName = "stigmas"
    self.assetName = "StigmasSelectPanel"
    self.image_ab = "stigmas_image";
    self.layer = "UI"
    self.panel_type = 2
    self.events = {}
    self.slotsItems = {}
    self.selectItems = {}
    self.model = StigmasModel:GetInstance()
end

function StigmasSelectPanel:dctor()
    self.model:RemoveTabListener(self.events)
    if self.slotsItems then
        for i, v in pairs(self.slotsItems) do
            v:destroy()
        end
    end
    self.slotsItems = {}

    if self.selectItems then
        for i, v in pairs(self.selectItems) do
            v:destroy()
        end
    end
    self.selectItems = {}
end

function StigmasSelectPanel:Open(index)
    self.index = index
    WindowPanel.Open(self)
end

function StigmasSelectPanel:LoadCallBack()
    self.nodes = {
        "ScrollView/Viewport/Content","StigmasSelectItem","LeftScrollView/Viewport/LeftContent",
    }
    self:GetChildren(self.nodes)

    self:AddEvent()

    StigmasController:GetInstance():RequstDungeSoulPanel()
    self:SetTileTextImage("stigmas_image", "stigmas_title_tex1");
end

function StigmasSelectPanel:InitUI()
    for i = 1, 6 do
        local item = self.slotsItems[i]
        if not item then
            item = StigmasItem(self.LeftContent,"UI")
            self.slotsItems[i] = item
            item:SetData(i,2)
        end
    end
    self:StigmasItemClick2(self.index or 1)

    self:InitRightUI()
end

function StigmasSelectPanel:AddEvent()
    self.events[#self.events + 1] = self.model:AddListener(StigmasEvent.StigmasItemClick2,handler(self,self.StigmasItemClick2))
    self.events[#self.events + 1] = self.model:AddListener(StigmasEvent.DungeSoulPanel,handler(self,self.HandleDungeSoulPanel))
    self.events[#self.events + 1] = self.model:AddListener(StigmasEvent.DungeSoulSelect,handler(self,self.HandleDungeSoulSelect))
end

function StigmasSelectPanel:InitRightUI()
    local godColors = GodModel:GetInstance().FoldData
    for i, v in table.pairsByKey(godColors) do
        local item = self.selectItems[i]
        if not item then
            item =  StigmasSelectItem(self.StigmasSelectItem.gameObject,self.Content,"UI")
            self.selectItems[i] = item
            item:SetData(v,i)
        end
    end
end


function StigmasSelectPanel:StigmasItemClick2(index)
    for i, v in pairs(self.slotsItems) do
        if v.index == index then
            self.model.curSlot = index
            v:SetSelect(true)
            for i, v in pairs(self.selectItems) do
                v:UpdateSubBtnState()
            end
        else
            v:SetSelect(false)
        end
    end
end

function StigmasSelectPanel:HandleDungeSoulPanel(data)
    self:InitUI()
end

function StigmasSelectPanel:HandleDungeSoulSelect(data)
    for i, v in pairs(self.slotsItems) do
        v:UpdateInfo()
    end
    for i, v in pairs(self.selectItems) do
        v:UpdateSubInfo()
    end

end