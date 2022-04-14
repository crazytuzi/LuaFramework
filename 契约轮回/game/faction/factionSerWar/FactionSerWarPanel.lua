---
--- Created by  Administrator
--- DateTime: 2020/5/14 14:14
---
FactionSerWarPanel = FactionSerWarPanel or class("FactionSerWarPanel", BaseItem)
local this = FactionSerWarPanel

function FactionSerWarPanel:ctor(parent_node, parent_panel)
    self.abName = "faction"
    self.assetName = "FactionSerWarPanel"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.model = FactionSerWarModel.GetInstance()
    self.events = {}
    self.itemicon = {}
    FactionSerWarPanel.super.Load(self)
end

function FactionSerWarPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function FactionSerWarPanel:LoadCallBack()
    self.nodes = {
        "content/des","content/TextObj/text5/time5","content/rewardBtn",
    }
    self:GetChildren(self.nodes)
    self.time5 = GetText(self.time5)
    self:InitUI()
    self:AddEvent()
end

function FactionSerWarPanel:InitUI()
    --self.time5.text = string.format("%s后赛季结束")
   -- self.model.nextTime
    local timeTab = TimeManager:GetInstance():GetTimeDate(self.model.nextTime)
    local timeStr = ""
    if timeTab.month then
        timeStr = timeStr .. string.format("%02d", timeTab.month) .. FactionSerWarModel.desTab.month
    end
    if timeTab.day then
        timeStr = timeStr .. string.format("%02d", timeTab.day) .. FactionSerWarModel.desTab.day
    end
    self.time5.text = string.format(FactionSerWarModel.desTab.seasonEnd,timeStr)
end

function FactionSerWarPanel:AddEvent()
    
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(FactionSerWarRewardPanel):Open()
    end
    AddClickEvent(self.rewardBtn.gameObject,call_back)
end