---
--- Created by R2D2.
--- DateTime: 2019/6/20 15:22
---

PetAttributeDetailItem = PetAttributeDetailItem or class("PetAttributeDetailItem", Node)
local this = PetAttributeDetailItem

function PetAttributeDetailItem:ctor(obj)
    self.transform = obj.transform
    self.gameObject = self.transform.gameObject
    self.transform_find = self.transform.Find

    self:InitUI()
end

function PetAttributeDetailItem:dctor()
end

function PetAttributeDetailItem:InitUI()
    self.is_loaded = true
    self.nodes = { "Split","Title","Title2","Title3", "BaseValue", "Value2", "Value3", }
    self:GetChildren(self.nodes)

    self.splitImage = GetImage(self.Split)
    self.titleText = GetText(self.Title)
    self.baseValueText = GetText(self.BaseValue)
    self.trainValueText = GetText(self.Value2)
    self.evolutionValueText = GetText(self.Value3)
end

function PetAttributeDetailItem:SetData(data)
    self.data = data

    self:RefreshView()
end

function PetAttributeDetailItem:SetSplitVisible(flag)
    local bool = toBool(flag)
    self.splitImage.enabled = bool
end

function PetAttributeDetailItem:RefreshView()
    local attrId = self.data[1]
    self.titleText.text = PetModel:GetInstance():InsertBlankInChsWord(enumName.ATTR[attrId]) .. "："

    self:SetText(self.baseValueText, self.Title, attrId, self.data[2], "")
    self:SetText(self.trainValueText, self.Title2, attrId, self.data[3], "+")
    self:SetText(self.evolutionValueText, self.Title3, attrId, self.data[4], "+")
end

function PetAttributeDetailItem:SetText(textBox, titleTextBox, attrId, value, prefix)

    if(value < 0 ) then
        SetVisible(titleTextBox, false)
        textBox.text = "/"
        return
    end

    SetVisible(titleTextBox, true)
    if IsValueTypeProperty(attrId) then
        textBox.text = prefix .. value
    else
        textBox.text = prefix .. string.format("%.2f%%", value * 0.0001)
    end
end

