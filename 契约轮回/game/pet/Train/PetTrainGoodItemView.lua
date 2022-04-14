---
--- Created by R2D2.
--- DateTime: 2019/6/24 16:11
---
PetTrainGoodItemView = PetTrainGoodItemView or class("PetTrainGoodItemView", Node)
local this = PetTrainGoodItemView

function PetTrainGoodItemView:ctor(obj)
    self.transform = obj.transform

    self.gameObject = self.transform.gameObject;
    self.transform_find = self.transform.Find;

    self:InitUI();
end

function PetTrainGoodItemView:dctor()
    if (self.goodItem) then
        self.goodItem:destroy()
        self.goodItem = nil
    end
end

function PetTrainGoodItemView:InitUI()
    self.is_loaded = true
    self.nodes = { "Parent", "Count" }
    self:GetChildren(self.nodes)

    self.goodParent = self.Parent
    self.countText = GetText(self.Count)
end

function PetTrainGoodItemView:SetData(data)
    self.Data = data
    self:RefreshView()
end

function PetTrainGoodItemView:RefreshView()
    local itemId = self.Data[1]
    local needNum = self.Data[2]

    self.goodItem = self.goodItem or AwardItem(self.goodParent)
    self.goodItem:SetData(itemId, 0)
    self.goodItem:AddClickTips()

    local num = BagModel:GetInstance():GetItemNumByItemID(itemId)

    if (num >= needNum) then
        self.countText.text = (string.format("<color=#3ab60e>%s/%s</color>", GetShowNumber(num), GetShowNumber(needNum)))
    else
        self.countText.text = (string.format("<color=#eb0000>%s/%s</color>", GetShowNumber(num), GetShowNumber(needNum)))
    end
end
