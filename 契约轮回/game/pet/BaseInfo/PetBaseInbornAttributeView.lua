---
--- Created by R2D2.
--- DateTime: 2019/4/8 19:24
---

PetBaseInbornAttributeView = PetBaseInbornAttributeView or class("PetBaseInbornAttributeView",Node)

function PetBaseInbornAttributeView:ctor()

end

function PetBaseInbornAttributeView:dctor()

    if (self.attrItems) then
        for _, v in pairs(self.attrItems) do
            v:destroy()
        end
        self.attrItems = {}
    end
end

function PetBaseInbornAttributeView:InitUI(itemPrefab, itemParent, tip)
    self.InactiveTip = tip
    self.ItemPrefab = itemPrefab.gameObject
    self.ItemParent = itemParent

    SetVisible(self.ItemPrefab, false)
end

function PetBaseInbornAttributeView:RefreshView(petData)

    if (petData.IsActive or petData.Data) then
        if (self.InactiveTip) then
            SetVisible(self.InactiveTip, false)
        end
        local inbornAttr = self:GetActiveInbornAttr(petData)
        self:RefreshActive(inbornAttr)
    else

        local inbornAttr = self:GetInactiveInbornAttr(petData, { [1] = true })

        if (self.InactiveTip) then
            SetVisible(self.InactiveTip, true)
        end

        self:RefreshInactive(inbornAttr)
    end
end

---激活的
function PetBaseInbornAttributeView:RefreshActive(inbornAttr)
    self:CreateItem(#inbornAttr)

    for i, v in ipairs(inbornAttr) do
        self.attrItems[i]:SetActiveData(v)
        self.attrItems[i]:SetVisible(true)
    end

    for i = #inbornAttr + 1, #self.attrItems do
        self.attrItems[i]:SetVisible(false)
    end
end

---未激活的
function PetBaseInbornAttributeView:RefreshInactive(inbornAttr)
    self:CreateItem(#inbornAttr)

    for i, v in ipairs(inbornAttr) do
        self.attrItems[i]:SetInactiveData(v)
        self.attrItems[i]:SetVisible(true)
    end

    for i = #inbornAttr + 1, #self.attrItems do
        self.attrItems[i]:SetVisible(false)
    end
end

function PetBaseInbornAttributeView:CreateItem(count)
    self.attrItems = self.attrItems or {}

    if count <= #self.attrItems then
        return
    end

    for i = #self.attrItems + 1, count do
        local tempItem = PetBaseInbornAttributeItemView(newObject(self.ItemPrefab))
        tempItem.transform:SetParent(self.ItemParent)
        SetLocalScale(tempItem.transform, 1, 1, 1)
        table.insert(self.attrItems, tempItem)
    end
end

---激活后的天生属性
function PetBaseInbornAttributeView:GetActiveInbornAttr(petData)
    local t = PetModel:GetInstance():GetValidValueAttrs(petData.Data.pet.rare1, petData.Data.pet.rare2, petData.Data.pet.rare3)
    ---读取的配置attr中，1=属性类型，2=下限，3=上限，5=颜色类型
    local attr = self:GetInactiveInbornAttr(petData)
    local tab = {}

    for _, v in ipairs(attr) do
        if t[v[1]] then
            ---将实际值插入到6位
            table.insert(v, t[v[1]])
            table.insert(tab, v)
        end
    end

    return tab
end

---未激活时的天生属性
function PetBaseInbornAttributeView:GetInactiveInbornAttr(petData, skipRare)

    local countTab = String2Table(petData.Config.count)
    local colName
    local mergeTab = {}
    local tempTab
    for i = #countTab[1], 1, -1 do

        if (skipRare and skipRare[i]) then
            ---跳过的rare属性列,未激活的情况下不显示蓝色（rare1）的属性
        else
            if countTab[1][i] > 0 then
                colName = "rare" .. i
                tempTab = AttrConfigString2Table(petData.Config[colName])
                for _, v in ipairs(tempTab) do
                    table.insert(v, i)
                    table.insert(mergeTab, v)
                end
            end
        end
    end

    return mergeTab
end