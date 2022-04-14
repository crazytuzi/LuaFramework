---
--- Created by R2D2.
--- DateTime: 2019/5/5 16:40
---

PetEvolutionItemView = PetEvolutionItemView or class("PetEvolutionItemView", Node)
local this = PetEvolutionItemView

function PetEvolutionItemView:ctor(obj, data)
    self.transform = obj.transform

    self.gameObject = self.transform.gameObject;
    self.transform_find = self.transform.Find;

    self:InitUI();
end

function PetEvolutionItemView:dctor()

end

function PetEvolutionItemView:InitUI()
    self.is_loaded = true
    self.nodes = { "Name", "Value", "UpValue", "Arrow", }
    self:GetChildren(self.nodes)

    self.titleText = GetText(self.Name)
    self.valueText = GetText(self.Value)
    self.upValueText = GetText(self.UpValue)
    self.arrowImage = GetImage(self.Arrow)
end

function PetEvolutionItemView:SetData(data)
    self.Data = data

    self:RefreshView()
end

function PetEvolutionItemView:RefreshView()
    local data = self.Data
    self.titleText.text = PetModel:GetInstance():InsertBlankInChsWord(enumName.ATTR[data[1]]) .. "："
    self.valueText.text = tostring(data[2])

    if (data[3] == 0) then
        self.arrowImage.enabled = false
        --SetColor(self.upValueText, 180, 180, 180, 255)
        self.upValueText.text = ConfigLanguage.Pet.NoEvolution
    elseif (data[3] == data[2]) then
        self.arrowImage.enabled = false
        --SetColor(self.upValueText, 138, 217, 64, 255)
        self.upValueText.text = ConfigLanguage.Pet.FullEvolution
    else
        self.arrowImage.enabled = true
        --SetColor(self.upValueText, 138, 217, 64, 255)
        self.upValueText.text = tostring(data[3])
    end
end

