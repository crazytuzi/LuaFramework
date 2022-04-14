---
--- Created by R2D2.
--- DateTime: 2019/4/8 20:19
---
PetBaseInbornAttributeItemView = PetBaseInbornAttributeItemView or class("PetBaseInbornAttributeItemView", Node)
local this = PetBaseInbornAttributeItemView

function PetBaseInbornAttributeItemView:ctor(obj, data)
    self.transform = obj.transform

    self.gameObject = self.transform.gameObject;
    self.transform_find = self.transform.Find;

    self:InitUI();
end

function PetBaseInbornAttributeItemView:dctor()

end

function PetBaseInbornAttributeItemView:InitUI()
    self.is_loaded = true
    self.nodes = { "Title", "Slider", "Slider/ForeGround", "Value",}
    self:GetChildren(self.nodes)

    self.titleText = GetText(self.Title)
    self.textOutline = self.Title:GetComponent('Outline')
    self.sliderImage = GetImage(self.ForeGround)
    self.valueText = GetText(self.Value)

    SetVisible(self.Slider, false)
end

---激活时
function PetBaseInbornAttributeItemView:SetActiveData(data)
    self.sliderImage.fillAmount = data[6] / data[3]
    --SetVisible(self.Slider, true)
    local attrId = data[1]
    self.titleText.text = PetModel:GetInstance():InsertBlankInChsWord(enumName.ATTR[attrId]) .. "："
    if IsValueTypeProperty(attrId) then
        --self.valueText.text = string.format("%d/%d", data[6], data[3])
        self.valueText.text = string.format("%d", data[6])
    else
        --self.valueText.text = string.format("%.2f%%/%.2f%%", data[6] * 0.0001, data[3] * 0.0001)
        self.valueText.text = string.format("%.2f%%", data[6] * 0.01)
    end
    self:SetAttrColor(data[5])
end

---未激活时
function PetBaseInbornAttributeItemView:SetInactiveData(data)
    SetVisible(self.Slider, false)
    local attrId = data[1]
    self.titleText.text = PetModel:GetInstance():InsertBlankInChsWord(enumName.ATTR[attrId]) .. "："
    if IsValueTypeProperty(attrId) then
        self.valueText.text = string.format("%d-%d", data[2], data[3])
    else
        if (data[2] == data[3]) then
            self.valueText.text = string.format("%.2f%%", data[2] * 0.01)        
        else
            self.valueText.text = string.format("%.2f%%-%.2f%%", data[2] * 0.01, data[3] * 0.01)
        end
    end

    self:SetAttrColor(data[5])
end

function PetBaseInbornAttributeItemView:SetAttrColor(id)
    --[[if (id == 2) then
        SetColor(self.titleText, 181, 94, 255, 255)
        SetOutLineColor(self.textOutline, 59, 7, 64, 255)
    elseif id == 3 then
        SetColor(self.titleText, 255, 164, 47, 255)
        SetOutLineColor(self.textOutline, 86, 40, 2, 255)
    else
        SetColor(self.titleText, 83, 231, 255, 255)
        SetOutLineColor(self.textOutline, 49, 71, 105, 255)
    end--]]
end