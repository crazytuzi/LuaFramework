---
--- Created by  Administrator
--- DateTime: 2020/6/1 16:55
---
FactionSerWarHelpPanel = FactionSerWarHelpPanel or class("FactionSerWarHelpPanel", BasePanel)
local this = FactionSerWarHelpPanel

function FactionSerWarHelpPanel:ctor()
    self.abName = "faction"
    self.assetName = "FactionSerWarHelpPanel"
    self.layer = "UI"
   -- self.parentPanel = parent_panel
    self.events = {}
    self.curPageIndex = 1
    self.use_background = true
    --FactionSerWarHelpPanel.super.Load(self)
    self.model = FactionSerWarModel.GetInstance()

end

function FactionSerWarHelpPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function FactionSerWarHelpPanel:LoadCallBack()
    self.nodes = {
        "ScrollView/Viewport/itemContent/bg2","ScrollView/Viewport/itemContent/bg1","leftBtn","rightBtn",
        "ScrollView/Viewport/itemContent/bg2/okBtn","ScrollView","closeBtn"
    }
    self:GetChildren(self.nodes)
    self.ScrollView = GetScrollRect(self.ScrollView)
  --  self.ScrollView.enabled = false
    SetVisible(self.leftBtn,false)
    self:InitUI()
    self:AddEvent()
end

function FactionSerWarHelpPanel:InitUI()

end

function FactionSerWarHelpPanel:AddEvent()
    local function call_back()
        self:LastPage()
    end
    AddClickEvent(self.leftBtn.gameObject,call_back)
    local function call_back()
        self:NextPage()
    end
    AddClickEvent(self.rightBtn.gameObject,call_back)
    
    local function call_back()
        self:Close()
    end
    AddButtonEvent(self.okBtn.gameObject,call_back)
    local function call_back()
        self:Close()
    end
    AddButtonEvent(self.closeBtn.gameObject,call_back)

end

function FactionSerWarHelpPanel:NextPage()
    self.curPageIndex = 2
    SetVisible(self.rightBtn,false)
    SetVisible(self.leftBtn,true)
    local action = cc.ValueTo(0.2,1,self.ScrollView,"horizontalNormalizedPosition")
    cc.ActionManager:GetInstance():addAction(action,self.ScrollView)
end
function FactionSerWarHelpPanel:LastPage()
    self.curPageIndex = 1
    SetVisible(self.rightBtn,true)
    SetVisible(self.leftBtn,false)
    local action = cc.ValueTo(0.2,0,self.ScrollView,"horizontalNormalizedPosition")
    cc.ActionManager:GetInstance():addAction(action,self.ScrollView)
end