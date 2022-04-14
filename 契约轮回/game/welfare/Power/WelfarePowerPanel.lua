---
--- Created by  R2D2
--- DateTime: 2019/1/15 20:15
---
WelfarePowerPanel = WelfarePowerPanel or class("WelfarePowerPanel", BaseItem)
local this = WelfarePowerPanel

function WelfarePowerPanel:ctor(parent_node, parent_panel)
    self.abName = "welfare"
    self.assetName = "WelfarePowerPanel"
    self.layer = "UI"
    self.parentPanel = parent_panel

    self.model = WelfareModel.GetInstance():GetPowerModel()
    self.events = {}

    WelfarePowerPanel.super.Load(self)
end

function WelfarePowerPanel:dctor()
    if(self.itemList) then
        for _, v in pairs(self.itemList) do
            v:destroy()
        end

        self.itemList = nil
    end

    self.model = nil
    GlobalEvent:RemoveTabListener(self.events)
end

function WelfarePowerPanel:LoadCallBack()
    self.nodes = { "Prefab", "ScrollView/Viewport/Content", }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
end

function WelfarePowerPanel:InitUI()
    self.contentRect = self.Content:GetComponent("RectTransform")

    local tab = self.model:GetInfoData()
    local spacX = 23
    local startX = 17
    local cellW = self.Prefab:GetComponent("RectTransform").sizeDelta.x
    local fullW = #tab * cellW + (#tab - 1) * spacX + startX
    local baseX = (fullW - cellW) * -0.5 + startX

    self.contentRect.sizeDelta = Vector2(fullW + 10, self.contentRect.sizeDelta.y)
    self.itemList = {}
    self:CreateItems(tab, baseX, cellW + spacX)
    self.Prefab.gameObject:SetActive(false)
end

function WelfarePowerPanel:AddEvent()
    self.events[#self.events + 1] = GlobalEvent.AddEventListener(WelfareEvent.Welfare_PowerRewardEvent, handler(self, self.OnPowerReward))
    self.events[#self.events + 1] = GlobalEvent.AddEventListener(WelfareEvent.Welfare_PowerDataEvent, handler(self, self.OnPowerData))
end

function WelfarePowerPanel:OnPowerData()
    for  _, v in pairs(self.itemList) do
        --此时仅刷新限量的
        if(v.data.count > 0 ) then
            v:RefreshState()
        end
    end
end

function WelfarePowerPanel:OnPowerReward(power)
    --for  _, v in pairs(self.itemList) do
    --    if(v.data.power == power) then
    --        Notify.ShowText("领取成功")
    --        v:RefreshState()
    --        break
    --    end
    --end

    self:RefreshOrder()
end

function WelfarePowerPanel:RefreshOrder()
    Notify.ShowText("Claimed")

    local tab = self.model:GetInfoData()
    local itemView
    for i = 1, #tab, 1 do
        itemView = self.itemList[i]
        if(itemView) then
            itemView:RefreshData(tab[i])
        end
    end
end

function WelfarePowerPanel:CreateItems(tab, baseX, offsetX)
    for i = 1, #tab, 1 do
        local tempItem = WelfarePowerItemView(newObject(self.Prefab), tab[i])
        tempItem.transform:SetParent(self.contentRect)
        SetLocalScale(tempItem.transform, 1, 1, 1)
        tempItem.transform.anchoredPosition3D = Vector3(baseX + (i - 1) * offsetX,-19, 0)

        self.itemList[i] = tempItem
    end
end