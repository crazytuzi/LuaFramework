---
--- Created by R2D2.
--- DateTime: 2019/5/9 14:24
---
---
require("game.pet.Component.UIBlockChecker")
PetComposePickPanel = PetComposePickPanel or class("PetComposePickPanel", BasePanel)
local PetComposePickPanel = PetComposePickPanel
local blockChecker

function PetComposePickPanel:ctor()
    self.abName = "pet"
    self.assetName = "PetComposePickPanel"
    self.layer = "UI"

    self.use_background = false
    self.show_sidebar = false

    self.Items = {}

    blockChecker = blockChecker or UIBlockChecker()
    PetComposePickPanel.super.Open(self)
end

function PetComposePickPanel:dctor()
    blockChecker:dctor()
    blockChecker = nil

    if (self.Items) then
        for _, v in pairs(self.Items) do
            v:destroy()
        end
        self.Items = {}
    end
    if self.targetSlot then
        self.targetSlot = nil
    end
end

function PetComposePickPanel:LoadCallBack()
    self.nodes = {
        "CloseButton", "ItemPrefab", "Selector", "ScrollView", "ScrollView/Viewport/Content",
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()

    if (self.petsData) then
        self:RefreshView()
    end
end

function PetComposePickPanel:InitUI()
    blockChecker:InitUI(self.gameObject, self.transform)
    blockChecker:SetOverBlockCallBack(handler(self, self.OnOverBlock))

    self.fullSize = Vector2(self.transform.rect.width, self.transform.rect.height)
    ---用非满屏Panel做范围的UI则直接使用全屏幕尺寸
    if (self.fullSize.x < DesignResolutionWidth or self.fullSize.y < DesignResolutionHeight) then
        self.fullSize = Vector2(DesignResolutionWidth, DesignResolutionHeight)
    end

    self.selectorImage = GetImage(self.Selector)
    self.itemPrefab = self.ItemPrefab.gameObject
    self.itemSize = self.ItemPrefab.sizeDelta

    self.selectorImage.enabled = false
    SetVisible(self.ItemPrefab, false)
end

function PetComposePickPanel:SetData(pets, pos, slot)
    self.petsData = pets
    self.posData = pos
    self.targetSlot = slot

    if (self.is_loaded) then
        self:RefreshView()
    end
end

function PetComposePickPanel:AddEvent()
    local function call_back(target,x,y)
        self:Close()
    end
    AddButtonEvent(self.CloseButton.gameObject,call_back)
end

function PetComposePickPanel:RefreshView()
    local tab = self.petsData
    self:CreatePetItem(#tab)

    for i, v in ipairs(tab) do
        self.Items[i]:SetData(v, v.Config)
        SetVisible(self.Items[i], true)
    end

    for i = #tab + 1, #self.Items do
        SetVisible(self.Items[i], false)
    end

    self:SetViewPosition(self.transform)
end

function PetComposePickPanel:CreatePetItem(count)
    local fullH = count * self.itemSize.y
    SetSizeDeltaY(self.Content, fullH)

    self.Items = self.Items or {}
    if count <= #self.Items then
        return
    end

    local baseY = (fullH - self.itemSize.y) * 0.5

    for i = #self.Items + 1, count do
        local tempItem = PetComposeItemView(newObject(self.itemPrefab))
        tempItem:SetCallBack(handler(self, self.OnSelectItem))
        tempItem.transform:SetParent(self.Content)
        SetLocalScale(tempItem.transform, 1, 1, 1)
        SetAnchoredPosition(tempItem.transform, 0, baseY - (i - 1) * self.itemSize.y)
        table.insert(self.Items, tempItem)
    end
end

function PetComposePickPanel:OnSelectItem(item)
    self.targetSlot:SetData(item.data)
    self:Close()
end

function PetComposePickPanel:OnOverBlock()
    self:Close()
end

function PetComposePickPanel:GetArea(size, clickPos)
    local areas = {
        { x = 1, y = 1 }, --右上角
        { x = -1, y = 1 }, --左上角
        { x = 1, y = -1 }, --右下角
        { x = -1, y = -1 } --左下角
    }

    for _, v in ipairs(areas) do
        local newPos = Vector2.__mul(v, 45) ---50为偏移量
        local offset = Vector2(v.x * size.x, v.y * size.y)
        newPos = newPos + clickPos + offset

        if (newPos.x >= 0 and newPos.x <= self.fullSize.x and newPos.y >= 0 and newPos.y <= self.fullSize.y) then
            return v, newPos
        end
    end

    --如果都不合适就放顶左上角
    return areas[1], Vector2(0, self.fullSize.y)
end

function PetComposePickPanel:SetViewPosition(rectView)

    ---转ViewPoint
    local vpPos = LayerManager:UIWorldToViewportPoint(self.posData.x, self.posData.y, self.posData.z)
    ---转窗口坐标
    local clickPos = Vector2(self.fullSize.x * vpPos.x, self.fullSize.y * vpPos.y)
    local size = Vector2(rectView.rect.width, rectView.rect.height)

    local area, screenPos = self:GetArea(size, clickPos)

    local pivot = rectView.pivot
    ---Rect相对位移
    local baseOffset = Vector2(pivot.x * self.fullSize.x, pivot.y * self.fullSize.y)

    local pos = screenPos - baseOffset - Vector2(area.x * size.x * pivot.x, area.y * size.y * pivot.y)

    SetAnchoredPosition(rectView, pos.x, pos.y)
end