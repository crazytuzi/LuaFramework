---
--- Created by  R2D2
--- DateTime: 2019/1/16 19:25
---
WelfareDownloadPanel = WelfareDownloadPanel or class("WelfareDownloadPanel", BaseItem)
local this = WelfareDownloadPanel

function WelfareDownloadPanel:ctor(parent_node, parent_panel)
    self.abName = "welfare"
    self.assetName = "WelfareDownloadPanel"
    self.layer = "UI"
    self.parentPanel = parent_panel

    self.model = WelfareModel.GetInstance():GetDownloadModel()
    self.events = {}

    WelfareDownloadPanel.super.Load(self)
end

function WelfareDownloadPanel:dctor()
    self.model = nil
    GlobalEvent:RemoveTabListener(self.events)
    if self.goodItem then
        self.goodItem:destroy()
    end
    self.goodItem = nil
end

function WelfareDownloadPanel:LoadCallBack()
    self.nodes = {
        "ItemParent", "Tip1", "Slider", "StartButton", "FinishButton", "UnfinishButton", "ReceivedImage", "CompleteImage",
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
    self:RefreshView()
end

function WelfareDownloadPanel:InitUI()
    self.goodsParent = self.ItemParent
    self.tipText = GetText(self.Tip1)
    self.sliderBar = GetSlider(self.Slider)
    self.completeImg = GetImage(self.CompleteImage)
    self.receivedImg = GetImage(self.ReceivedImage)

    self.sliderBar.value = 0
end

function WelfareDownloadPanel:AddEvent()
    local function OnDownload()
        self.sliderBar.value = 1
    end
    AddButtonEvent(self.StartButton.gameObject, OnDownload)

    local function OnFinishButton()
        WelfareController:GetInstance():RequestResReward()
    end
    AddButtonEvent(self.FinishButton.gameObject, OnFinishButton)
    self.events[#self.events + 1] = GlobalEvent.AddEventListener(WelfareEvent.Welfare_ResRewardEvent, handler(self, self.OnResReward))
end

function WelfareDownloadPanel:OnResReward()
    Notify.ShowText("Claimed")
    self:RefreshView()
end

function WelfareDownloadPanel:RefreshView()
    local tab = self.model:GetInfoData()
    self:InitGoodItem(tab.reward)

    if tab.isReceived then
        SetGameObjectActive(self.FinishButton, false)
        SetGameObjectActive(self.UnfinishButton, false)
        self.receivedImg.enabled = true
    else
        SetGameObjectActive(self.FinishButton, true)
        SetGameObjectActive(self.UnfinishButton, false)
        self.receivedImg.enabled = false
    end
end

function WelfareDownloadPanel:InitGoodItem(goods)
    self.goodItems = {}

    for i = 1, #goods, 1 do
        local item = AwardItem(self.goodsParent)
        item:SetData(goods[i][1], goods[i][2])
        item:AddClickTips()
        SetLocalScale(item.transform, 1, 1, 1)
        SetLocalPosition(item.transform, (i - 1) * 80, 0, 0)
        table.insert(self.goodItems, item)
    end
end