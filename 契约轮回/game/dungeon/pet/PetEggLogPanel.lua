---
--- Created by R2D2.
--- DateTime: 2019/6/15 10:58
---
PetEggLogPanel = PetEggLogPanel or class("PetEggLogPanel", BaseItem)
local this = PetEggLogPanel

function PetEggLogPanel:ctor(parent_node, layer)
    self.abName = "dungeon"
    self.image_ab = "dungeon_image"
    self.assetName = "PetEggLogPanel"
    self.layer = "UI"

    self.model = PetModel:GetInstance()

    self.events = {}
    self.schedules = {}
    PetEggLogPanel.super.Load(self)
end

function PetEggLogPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    self.events = {}

    self.model = nil

    if self.itemList then
        for k, v in pairs(self.itemList) do
            v:destroy()
        end
    end
    self.itemList = nil
end

function PetEggLogPanel:LoadCallBack()

    self:InitUI()
    self:AddEvent()
end

function PetEggLogPanel:InitUI()
    self.nodes = {
        "ItemPrefab", "ScrollView/Viewport/Content",
    }

    self:GetChildren(self.nodes)

    self.itemPrefab = self.ItemPrefab.gameObject
    self.itemSize = self.ItemPrefab.sizeDelta
    self.itemParent = self.Content

    SetVisible(self.ItemPrefab, false)

    PetController:GetInstance():RequestEggRecords()
end

function PetEggLogPanel:AddEvent()
    self.events[#self.events + 1] = GlobalEvent:AddListener(PetEvent.Pet_EggRecordsEvent, handler(self, self.OnEggRecords))
    self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.QueryDroppedEvent, handler(self, self.OnQueryRecords))
end

function PetEggLogPanel:OnEggRecords()
    self.data = self.model:GetEggRecords()
    self:RefreshView()
end

function PetEggLogPanel:OnQueryRecords(pItem)
    local pos = self.currLogItem.transform.position
    if self.view then
        self.view:destroy()
        self.view = nil
    end
    self.view = PetShowTipView()
    self.view:SetData(pItem, PetModel.TipType.PetEgg, pos)

end

function PetEggLogPanel:RefreshView()
    self.itemList = self.itemList or {}
    local count = #self.data
    local fullH = count * self.itemSize.y
    local baseY = (fullH - self.itemSize.y) * 0.5

    SetSizeDeltaY(self.itemParent, fullH)
    self:CreateRecordItem(count, baseY, self.itemSize.y)

    for i, v in ipairs(self.data) do
        self.itemList[i]:SetData(v)
        self.itemList[i]:SetCallBack(handler(self, self.OnClickRecord))
        SetVisible(self.itemList[i], true)
    end

    for i = count + 1, #self.itemList do
        SetVisible(self.itemList[i], false)
    end
end

function PetEggLogPanel:CreateRecordItem(count, baseY, itemY)
    if (count <= #self.itemList) then
        return
    end

    for i = #self.itemList + 1, count do
        local tempItem = PetEggLogItem(newObject(self.itemPrefab))
        tempItem.transform.name = "pet_egg_item" .. i
        SetParent(tempItem.transform, self.itemParent)
        SetLocalScale(tempItem.transform, 1, 1, 1)
        SetLocalPositionZ(tempItem.transform, 0)
        SetAnchoredPosition(tempItem.transform, 0, baseY - (i - 1) * itemY)
        table.insert(self.itemList, tempItem)
    end
end

function PetEggLogPanel:OnClickRecord(logItem, cache_id)
    self.currLogItem = logItem
    self.pet_cache_id = cache_id
    GoodsController:GetInstance():RequestQueryDropped(cache_id)
end