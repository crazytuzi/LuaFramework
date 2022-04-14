---
--- Created by  Administrator
--- DateTime: 2020/5/15 16:03
---
FactionSerWarMainPanel = FactionSerWarMainPanel or class("FactionSerWarMainPanel", BaseItem)
local this = FactionSerWarMainPanel

function FactionSerWarMainPanel:ctor(parent_node, parent_panel)
    self.abName = "faction"
    self.assetName = "FactionSerWarMainPanel"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.model = FactionSerWarModel.GetInstance()
    self.events = {}
    self.itemicon = {}
    FactionSerWarMainPanel.super.Load(self)
end

function FactionSerWarMainPanel:dctor()
    self.model:RemoveTabListener(self.events)
    if  self.panels  then
        self.panels:destroy()
    end
    self.panels = nil
end

function FactionSerWarMainPanel:LoadCallBack()
    self.nodes = {
        "PanelParent","wenhao"
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
    FactionSerWarController:GetInstance():RequstMainPanelInfo()
end

function FactionSerWarMainPanel:InitUI()

end

function FactionSerWarMainPanel:AddEvent()
    
    local function call_back()
        ShowHelpTip(self.model.helpTex,true)
    end
    AddButtonEvent(self.wenhao.gameObject,call_back)

    self.events[#self.events + 1] = self.model:AddListener(FactionSerWarEvent.MainPanelInfo,handler(self,self.MainPanelInfo))
end

function FactionSerWarMainPanel:MainPanelInfo()
    local period = self.model.period
    if period == 2 then
        self.panels = FactionSerWarAppPanel(self.PanelParent)
    elseif period == 3 then
        self.panels = FactionSerWarVsPanel(self.PanelParent)
    else
        self.panels = FactionSerWarPanel(self.PanelParent)
    end

end

