---
--- Created by R2D2.
--- DateTime: 2019/4/20 11:21
---

require("game.pet.Component.UIBlockChecker")
PetGetWayView = PetGetWayView or class("PetGetWayView", BasePanel)
local this = PetGetWayView
local blockChecker

function PetGetWayView:ctor()
    self.abName = "pet"
    self.assetName = "PetGetWayView"
    self.layer = "UI"

    self.use_background = false
    self.show_sidebar = false

    self.Items = {}
    blockChecker = blockChecker or UIBlockChecker()

    PetGetWayView.super.Open(self)
end

function PetGetWayView:dctor()
    blockChecker:dctor()
    blockChecker = nil

    if (self.Items) then
        for _, v in pairs(self.Items) do
            v:destroy()
        end
        self.Items = {}
    end
end

function PetGetWayView:LoadCallBack()
    self.nodes = {
        "CloseButton", "ItemPrefab", "Selector", "ScrollView", "ScrollView/Viewport/Content",
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()

    if (self.Data) then
        self:RefreshView()
    end
end

function PetGetWayView:InitUI()
    blockChecker:InitUI(self.gameObject, self.transform)
    blockChecker:SetOverBlockCallBack(handler(self, self.OnOverBlock))

    self.selectorImage = GetImage(self.Selector)

    self.itemPrefab = self.ItemPrefab.gameObject
    self.itemSize = self.ItemPrefab.sizeDelta

    self.selectorImage.enabled = false
    SetVisible(self.ItemPrefab, false)
    SetAnchoredPosition(self.transform, -188, -189)
end

function PetGetWayView:SetData(itemId)
    local item = Config.db_item[itemId]
    self.Data = String2Table(item.guide)

    if (self.is_loaded) then
        self:RefreshView()
    end
end

function PetGetWayView:AddEvent()
    local function call_back(target,x,y)
        self:Close()
    end
    AddButtonEvent(self.CloseButton.gameObject,call_back)
end

function PetGetWayView:RefreshView()

    local list = self.Data
    local tab = {}
    if type(list[1]) == "number" then
        tab[1] = list
    else
        tab = list
    end
    self:CreateGetItem(#tab)

    local function callback(data)

        --local tab = string.split(data, "@")
        OpenLink(unpack(data))
        self:destroy()

    end

    for i, v in ipairs(tab) do
        self.Items[i]:SetData(v, callback)
        SetVisible(self.Items[i], true)
    end

    for i = #tab + 1, #self.Items do
        SetVisible(self.Items[i], false)
    end

end

function PetGetWayView:CreateGetItem(count)
    local fullH = count * self.itemSize.y
    SetSizeDeltaY(self.Content, fullH)

    self.Items = self.Items or {}
    if count <= #self.Items then
        return
    end

    local baseY = (fullH - self.itemSize.y) * 0.5

    for i = #self.Items + 1, count do
        local tempItem = PetGetWayItemView(newObject(self.itemPrefab))
        tempItem.transform:SetParent(self.Content)
        SetLocalScale(tempItem.transform, 1, 1, 1)
        SetAnchoredPosition(tempItem.transform, 0, baseY - (i - 1) * self.itemSize.y)
        table.insert(self.Items, tempItem)
    end
end

function PetGetWayView:OnOverBlock()
    self:Close()
end