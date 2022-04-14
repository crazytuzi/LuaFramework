---
--- Created by  R2D2
--- DateTime: 2019/1/11 17:50
---
WelfareOnlinePanel = WelfareOnlinePanel or class("WelfareOnlinePanel", BaseItem)
local this = WelfareOnlinePanel

function WelfareOnlinePanel:ctor(parent_node, parent_panel)

    self.abName = "welfare"
    self.assetName = "WelfareOnlinePanel"
    self.layer = "UI"

    self.parentPanel = parent_panel
    self.model = WelfareModel.GetInstance():GetOnlineModel()
    self.events = {}

    WelfareOnlinePanel.super.Load(self)
end

function WelfareOnlinePanel:dctor()

    self.model = nil
    GlobalEvent:RemoveTabListener(self.events)

    for _, v in pairs(self.itemList) do
        v:destroy()
    end
    self.itemList = {}
end

function WelfareOnlinePanel:LoadCallBack()
    self.nodes = { "Frame1", "Frame2", "Frame3", }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
end

function WelfareOnlinePanel:InitUI()
    self.itemList = {}
    local tab = self.model:GetInfoData()
    if(#tab ~= 3) then
        print("Online Reward Config error!")
        return
    end

    local tempItem = WelfareOnlineItemView( self.Frame1.gameObject , tab[1])
    self.itemList[1] = tempItem
    tempItem = WelfareOnlineItemView( self.Frame2.gameObject , tab[2])
    self.itemList[2] = tempItem
    tempItem = WelfareOnlineItemView( self.Frame3.gameObject , tab[3])
    self.itemList[3] = tempItem

end

function WelfareOnlinePanel:AddEvent()

    self.events[#self.events + 1] = GlobalEvent.AddEventListener(WelfareEvent.Welfare_OnlineRewardEvent, handler(self, self.OnOnlineReward))
end

function WelfareOnlinePanel:OnOnlineReward(id)
    for  _, v in pairs(self.itemList) do
        if(v.data.id == id) then
            Notify.ShowText("Claimed")
            v:RefreshState()
            break
        end
    end
end