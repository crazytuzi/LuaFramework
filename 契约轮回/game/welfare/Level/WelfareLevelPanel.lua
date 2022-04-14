---
--- Created by  R2D2
--- DateTime: 2019/1/15 14:42
---
WelfareLevelPanel = WelfareLevelPanel or class("WelfareLevelPanel", BaseItem)
local this = WelfareLevelPanel

function WelfareLevelPanel:ctor(parent_node, parent_panel)
    self.abName = "welfare"
    self.assetName = "WelfareLevelPanel"
    self.layer = "UI"
    self.parentPanel = parent_panel

    self.model = WelfareModel.GetInstance():GetLevelModel()
    self.events = {}

    WelfareLevelPanel.super.Load(self)
end

function WelfareLevelPanel:dctor()

    self.model = nil
    GlobalEvent:RemoveTabListener(self.events)

    if(self.itemList) then
        for _, v in pairs(self.itemList) do
            --v:dctor()
            v:destroy()
        end
        self.itemList = nil
    end
end

function WelfareLevelPanel:LoadCallBack()
    self.nodes = { "Prefab", "ScrollView/Viewport/Content", }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
end

function WelfareLevelPanel:InitUI()
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

function WelfareLevelPanel:AddEvent()
    self.events[#self.events + 1] = GlobalEvent.AddEventListener(WelfareEvent.Welfare_LevelRewardEvent, handler(self, self.OnLevelReward))
    self.events[#self.events + 1] = GlobalEvent.AddEventListener(WelfareEvent.Welfare_LevelDataEvent, handler(self, self.OnLevelData))
end

function WelfareLevelPanel:OnLevelData()
    for  _, v in pairs(self.itemList) do
        --此时仅刷新限量的
        if (v.data.isLimited) then
            v:RefreshState()
        end
    end
end

function WelfareLevelPanel:OnLevelReward(level)
    --for  _, v in pairs(self.itemList) do
    --    if(v.data.level == level) then
    --        Notify.ShowText("领取成功")
    --        v:RefreshState()
    --        break
    --    end
    --end

    self:RefreshOrder()
end

function WelfareLevelPanel:RefreshOrder()
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

function WelfareLevelPanel:CreateItems(tab, baseX, offsetX)
    for i = 1, #tab, 1 do
        local tempItem = WelfareLevelItemView(newObject(self.Prefab), tab[i])
        tempItem.transform:SetParent(self.contentRect)
        SetLocalScale(tempItem.transform, 1, 1, 1)
        tempItem.transform.anchoredPosition3D = Vector3(baseX + (i - 1) * offsetX,-19, 0)

        self.itemList[i] = tempItem
    end
end