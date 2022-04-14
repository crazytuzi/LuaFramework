---
--- Created by R2D2.
--- DateTime: 2019/4/8 16:11
---

PetBaseAttributeView = PetBaseAttributeView or class("PetBaseAttributeView")

function PetBaseAttributeView:ctor()

end

function PetBaseAttributeView:dctor()
    self.attrItems = nil
end

function PetBaseAttributeView:AddItem(title, slider, foreGround, value)
    self.attrItems = self.attrItems or {}

    local item = {}
    item["Title"] = GetText(title)
    item["Slider"] = slider.gameObject;
    item["SliderValue"] = GetImage(foreGround)
    item["Text"] = GetText(value)

    table.insert(self.attrItems, item)
end

function PetBaseAttributeView:RefreshView(petData)
    if (petData.IsActive or petData.Data) then
        local attr = PetModel:GetInstance():GetValidValueAttr(petData.Data.pet.base)
        local tab = String2Table(petData.Config.base)
        for _, v in ipairs(tab) do
            local key = v[1]
            table.insert(v, attr[key] or 0)
        end
        self:RefreshActive(tab)
    else
        self:RefreshInactive(petData.Config.base)
    end
end

--function PetBaseAttributeView:RefreshView(petData)
--
--    if (petData.IsActive) then
--        local attr = PetModel:GetInstance():GetValidValueAttr(petData.Data.pet.base)
--        -----训练增加的属性
--        --local trainAttr, trainPercent = PetModel:GetInstance():GetTrainValues(petData.Config.order,
--        --        petData.Data.equip.stren_phase, petData.Data.equip.stones)
--        --
--        --local evolutionAttr = self:GetEvolutionAttr(petData)
--        --
--        local tab = String2Table(petData.Config.base)
--        for _, v in ipairs(tab) do
--            local key = v[1]
--            table.insert(v, attr[key] or 0)
--        --    if trainAttr[key] then
--        --        v[4] = (v[4] + trainAttr[key][1])
--        --        v[3] = (v[3] + trainAttr[key][2])
--        --    end
--        --
--        --    if evolutionAttr[key] then
--        --        v[4] = (v[4] + evolutionAttr[key])
--        --        v[3] = (v[3] + evolutionAttr[key])
--        --    end
--        --
--        --    v[4] = math.floor(v[4] * (1 + trainPercent / 10000))
--        --    v[3] = math.floor(v[3] * (1 + trainPercent / 10000))
--        --
--        end
--
--        self:RefreshActive(tab)
--    else
--        self:RefreshInactive(petData.Config.base)
--    end
--end

--function PetBaseAttributeView:GetEvolutionAttr(petData)
--    ---突破增加的属性
--    local extra = petData.Data.extra or 0
--    local Cfg = Config.db_pet_evolution[petData.Config.order .. "@" .. extra]
--    local tab = String2Table(Cfg.attr)
--    local attr = {}
--    for _, v in ipairs(tab) do
--        attr[v[1]] = v[2]
--    end
--
--    return attr
--end

---激活的
function PetBaseAttributeView:RefreshActive(tab)
    if (tab) then
        for i, v in ipairs(tab) do
            local item = self.attrItems[i]
            item.Title.text = PetModel:GetInstance():InsertBlankInChsWord(enumName.ATTR[v[1]]) .. "："
            item.Text.text = string.format("%d/%d", v[4], v[3])

            item.SliderValue.fillAmount = v[4] / v[3]
            SetVisible(item.Slider, true)
        end
    end
end

---未激活的
function PetBaseAttributeView:RefreshInactive(baseAttr)
    local tab = String2Table(baseAttr)
    if (tab) then
        for i, v in ipairs(tab) do
            local item = self.attrItems[i]
            item.Title.text = PetModel:GetInstance():InsertBlankInChsWord(enumName.ATTR[v[1]]) .. "："
            item.Text.text = string.format("%d-%d", v[2], v[3])
            SetVisible(item.Slider, false)
        end
    end
end