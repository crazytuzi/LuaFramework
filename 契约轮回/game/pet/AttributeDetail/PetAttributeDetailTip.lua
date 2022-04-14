---
--- Created by R2D2.
--- DateTime: 2019/6/20 15:18
---
require("game.pet.Component.UIBlockChecker")
PetAttributeDetailTip = PetAttributeDetailTip or class("PetAttributeDetailTip", BasePanel)

local PetAttributeDetailTip = PetAttributeDetailTip
local blockChecker

function PetAttributeDetailTip:ctor()
    self.abName = "pet"
    self.assetName = "PetAttributeDetailTip"
    self.layer = "UI"

    self.use_background = true
    self.show_sidebar = false
    self.touch_close = false
    self.model = PetModel:GetInstance()
    self.events = {}

    blockChecker = blockChecker or UIBlockChecker()
    PetAttributeDetailTip.super.Open(self)
end

function PetAttributeDetailTip:dctor()
    blockChecker:dctor()
    blockChecker = nil

    if (self.items) then
        for _, v in pairs(self.items) do
            v:destroy()
        end
        self.items = nil
    end
end

function PetAttributeDetailTip:LoadCallBack()
    self.nodes = { "Tip", "Tip/ItemPrefab", "Tip/ScrollView",
                   "Tip/ScrollView/Viewport/Content", }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()

    if (self.PetData) then
        self:RefreshView()
    end
end

function PetAttributeDetailTip:InitUI()
    blockChecker:InitUI(self.gameObject, self.Tip)
    blockChecker:SetOverBlockCallBack(handler(self, self.OnOverBlock))

    self.itemPrefab = self.ItemPrefab.gameObject
    self.itemParent = self.Content
    self.itemSize = self.ItemPrefab.sizeDelta

    SetVisible(self.ItemPrefab, false)
end

function PetAttributeDetailTip:AddEvent()
end

function PetAttributeDetailTip:SetData(data)
    self.PetData = data
    if (self.is_loaded) then
        self:RefreshView()
    end
end

function PetAttributeDetailTip:RefreshView()

    self.items = self.items or {}

    local attrTab = self:GetAttribute()
    local count = #attrTab
    local fullH = count * self.itemSize.y
    SetSizeDeltaY(self.itemParent, fullH)

    self:CreateAttrItem(count)

    for i, v in ipairs(attrTab) do
        self.items[i]:SetData(v)
        self.items[i]:SetSplitVisible(i % 2 == 0)
        SetVisible(self.items[i], true)
    end

    for i = count + 1, #self.items do
        SetVisible(self.items[i], false)
    end
end

function PetAttributeDetailTip:CreateAttrItem(count)
    if (count <= #self.items) then
        return
    end

    for i = #self.items + 1, count do
        local tempItem = PetAttributeDetailItem(newObject(self.ItemPrefab))
        tempItem.transform.name = "pet_attr_detail_item" .. i
        SetParent(tempItem.transform, self.itemParent)
        SetLocalScale(tempItem.transform, 1, 1, 1)
        table.insert(self.items, tempItem)
    end
end

function PetAttributeDetailTip:OnOverBlock()
    self:Close()
end

function PetAttributeDetailTip:GetAttribute()
    ---{属性ID，基础值，训练值，突破值}
    local tab = {}

    local attr = self.model:GetValidValueAttr(self.PetData.Data.pet.base)
    local trainAttr, trainPercent = self.model:GetTrainValues(self.PetData.Config.order,
            self.PetData.Data.pet.cross, self.PetData.Data.pet.strong)
    local evolutionAttr = self:GetEvolutionAttr(self.PetData)

    local baseTab = String2Table(self.PetData.Config.base)
    for _, v in ipairs(baseTab) do
        local key = v[1]
        local tempTab = { v[1], attr[key] or 0, trainAttr[key] and trainAttr[key][1] or -1, evolutionAttr[key] or -1 }
        table.insert(tab, tempTab)
    end

    return tab
end

function PetAttributeDetailTip:GetEvolutionAttr(petData)
    ---突破增加的属性
    local extra = petData.Data.extra or 0
    local Cfg = Config.db_pet_evolution[petData.Config.order .. "@" .. extra]
    local tab = String2Table(Cfg.attr)
    local attr = {}
    for _, v in ipairs(tab) do
        attr[v[1]] = v[2]
    end

    return attr
end