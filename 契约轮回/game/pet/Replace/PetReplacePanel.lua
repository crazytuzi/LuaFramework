---
--- Created by R2D2.
--- DateTime: 2019/4/13 10:43
---

PetReplacePanel = PetReplacePanel or class("PetReplacePanel", WindowPanel)
local PetReplacePanel = PetReplacePanel

function PetReplacePanel:ctor()
    self.abName = "pet"
    self.imageAb = "pet_image"
    self.assetName = "PetReplacePanel"
    self.layer = "UI"

    self.panel_type = 2
    self.show_sidebar = false
    self.modelEvents = {}

    self.qualityFilterKey = 0
    self.orderFilterKey = 0
    self.model = PetModel:GetInstance()
end

function PetReplacePanel:dctor()
    self.model:RemoveTabListener(self.modelEvents)
    self.modelEvents = {}
end

function PetReplacePanel:Open()
    PetReplacePanel.super.Open(self)
end

function PetReplacePanel:LoadCallBack()
    self.nodes = { "Model", "ScrollView", "ScrollView/Viewport/Content", "PetItem", "Selector",
                   "QualityDropdown", "OrderDropdown", "BattleBtn", "AssistBtn", }
    self:GetChildren(self.nodes)

    self:ShowPetModle()
    --self.nodes = { "DownArrow",
    --               "Power", "Power/PowerValue", "State", "State/StateImage",
    --               "QualityName", "NameBg", "RankText", "NameText", "EP1", "EP2", "EP3", "EP4", "ChangeBtn", }
    --self:GetChildren(self.nodes)
    --
    --self:SetTileTextImage(self.imageAb, "pet_title_txt")
    --self:SetBackgroundImage("iconasset/icon_big_bg_pet_bg", "pet_bg")
    --
    self:InitUI()
    self:AddEvent()

    self:RefreshItemListView()
    --
    --self:SelectItem(self.itemList[1])
end

function PetReplacePanel:FillDropDownData(dropdown, data)
    dropdown:ClearOptions()
    local options = dropdown.options;
    for _, v in ipairs(data) do
        options:Add(UnityEngine.UI.Dropdown.OptionData(v))
    end
end

function PetReplacePanel:SetCurrPet(petData)
    self.CurrPetData = petData
    self:ShowPetModle()
    --self:RefreshView()
    --self.model:Brocast(PetEvent.Pet_Model_SelectPetEvent, petData)

end

function PetReplacePanel:ShowPetModle()
    if (self.CurrPetData) then
        if (self.PetModle) then
            self.PetModle:ReLoadPet(self.CurrPetData.Config.model)
        else
            self.PetModle = UIPetCamera(self.Model, nil, self.CurrPetData.Config.model)
        end

        ---修正位置
        local located = String2Table(self.CurrPetData.Config.located)
        local config = {}
        config.offset = { x = located[1] or 0, y = located[2] or 0, z = located[3] or 0 }
        self.PetModle:SetConfig(config)
    end
end

function PetReplacePanel:InitUI()

    self.itemSize = self.PetItem.sizeDelta
    self.PetItem.gameObject:SetActive(false)
    self.scrollView = GetScrollRect(self.ScrollView)
    --self.powerValueText = GetText(self.PowerValue)
    --self.stateImage = GetImage(self.StateImage)
    --self.qualityNameImage = GetImage(self.QualityName)
    --self.nameBgImage = GetImage(self.NameBg)
    --self.rankText = GetText(self.RankText)
    --self.nameText = GetText(self.NameText)
    --
    --self.epImageList = {}
    --table.insert(self.epImageList, GetImage(self.EP1))
    --table.insert(self.epImageList, GetImage(self.EP2))
    --table.insert(self.epImageList, GetImage(self.EP3))
    --table.insert(self.epImageList, GetImage(self.EP4))
    --
    self.qualityDropdown = GetDropDown(self.QualityDropdown)
    self.orderDropdown = GetDropDown(self.OrderDropdown)

    self.qualityRealKey = { 0 }
    self.orderRealKey = { 0 }

    local c = { "All" }

    for _, v in ipairs(self.model.qualityList) do
        table.insert(self.qualityRealKey, v)
        table.insert(c, "Quality" .. v)
    end
    self:FillDropDownData(self.qualityDropdown, c)

    local c = { "All" }
    for k, v in ipairs(self.model.orderShowList) do
        table.insert(self.orderRealKey, self.model.orderList[k])
        table.insert(c, ChineseNumber(v) .. "Stage")
    end
    self:FillDropDownData(self.orderDropdown, c)

end

function PetReplacePanel:AddEvent()

    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(PetEvent.Pet_Model_DeleteBagPetEvent, handler(self, self.OnDeleteBagPet))
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(PetEvent.Pet_Model_AddBagPetEvent, handler(self, self.OnAddBagPet))

    AddValueChange(self.QualityDropdown.gameObject, handler(self, self.OnQualityDropdown))
    AddValueChange(self.OrderDropdown.gameObject, handler(self, self.OnOrderDropdown))
    AddButtonEvent(self.BattleBtn.gameObject, handler(self, self.OnBattle))
    AddButtonEvent(self.AssistBtn.gameObject, handler(self, self.OnAssist))
end

function PetReplacePanel:OnOrderDropdown(go, index)

    local key = self.orderRealKey[index + 1]

    if (self.orderFilterKey == key) then
        return
    else
        self.orderFilterKey = key
        self:FilterRefresh()
    end
end

function PetReplacePanel:OnQualityDropdown(go, index)
    local key = self.qualityRealKey[index + 1]

    if (self.qualityFilterKey == key) then
        return
    else
        self.qualityFilterKey = key
        self:FilterRefresh()
    end
end

function PetReplacePanel:FilterRefresh()

    local qFilter = self.qualityFilterKey
    local oFilter = self.orderFilterKey
    self:RefreshItemListView(function(config)
        if (qFilter ~= 0) then
            if (config.quality ~= qFilter) then
                return false
            end
        end
        if (oFilter ~= 0) then
            if (config.order ~= oFilter) then
                return false
            end
        end

        return true
    end)
end

---出战
function PetReplacePanel:OnBattle()
    PetController:GetInstance():RequestPetSet(self.CurrPetData.Data.uid, 1)
end

---助战
function PetReplacePanel:OnAssist()
    PetController:GetInstance():RequestPetSet(self.CurrPetData.Data.uid, 0)
end

function PetReplacePanel:OnDeleteBagPet(uid)
    self:RefreshItemListView()
end

function PetReplacePanel:OnAddBagPet()
    self:RefreshItemListView()
end

--
--function PetReplacePanel:RefreshView()
--
--    self.rankText.text = self.CurrPetData.Config.order_show .. "阶"
--    self.nameText.text = self.CurrPetData.Config.name
--
--    if (self.CurrPetData.IsActive) then
--        self.powerValueText.text = tostring(self.CurrPetData.Data.equip.power)
--        lua_resMgr:SetImageTexture(self, self.stateImage, self.imageAb, self.CurrPetData.IsFighting and "State_Battle" or "State_Assist")
--        lua_resMgr:SetImageTexture(self, self.qualityNameImage, self.imageAb, "Q_Name_" .. self.CurrPetData.Config.quality)
--
--        self:ActiveStyle(self.CurrPetData.Config.evolution, self.CurrPetData.Data.extra)
--
--        local t = self.model:GetValidValueAttrs(self.CurrPetData.Data.equip.rare1, self.CurrPetData.Data.equip.rare2, self.CurrPetData.Data.equip.rare3)
--    else
--        self:InactiveStyle(self.CurrPetData.Config.evolution)
--    end1
--end
--
--function PetReplacePanel:ActiveStyle(count, point)
--    self.qualityNameImage.enabled = true
--
--    SetVisible(self.Power, true)
--    SetVisible(self.State, true)
--    SetVisible(self.ChangeBtn, true)
--    self:SetEvolutionPoint(count, point)
--end
--
--function PetReplacePanel:InactiveStyle(count)
--    self.qualityNameImage.enabled = false
--
--    SetVisible(self.Power, false)
--    SetVisible(self.State, false)
--    SetVisible(self.ChangeBtn, false)
--    self:SetEvolutionPoint(count, 0)
--end
--
--function PetReplacePanel:SetEvolutionPoint(count, point)
--    for i, v in ipairs(self.epImageList) do
--        if (i <= point) then
--            v.enabled = true
--            lua_resMgr:SetImageTexture(self, v, self.imageAb, "EvolutionPoint");
--        elseif (i <= count) then
--            v.enabled = true
--            lua_resMgr:SetImageTexture(self, v, self.imageAb, "EvolutionPoint_Gray");
--        else
--            v.enabled = false
--        end
--    end
--end

function PetReplacePanel:SelectItem(item)
    SetParent(self.Selector, item.transform)
    self.Selector:SetSiblingIndex(1)
    SetAnchoredPosition(self.Selector, 0, 0)
    self:SetCurrPet(item.data)
end

function PetReplacePanel:RefreshItemListView(filter)

    local data = self.model:GetAllList(filter)
    self:CreateItem(#data)

    for i, v in ipairs(data) do
        self.itemList[i]:SetData(v)
        SetVisible(self.itemList[i], true)
    end

    for i = #data + 1, #self.itemList do
        SetVisible(self.itemList[i], false)
    end

    self.scrollView.verticalNormalizedPosition = 1
    if (#data > 0) then
        self:SelectItem(self.itemList[1])
    else

    end
end

function PetReplacePanel:CreateItem(count)

    self.itemList = self.itemList or {}

    local fullH = count * self.itemSize.y
    local baseY = (fullH - self.itemSize.y) / 2 - 4
    SetSizeDeltaY(self.Content, fullH)

    if count <= #self.itemList then
        return
    end

    for i = #self.itemList + 1, count do
        local tempItem = PetReplaceItemView(newObject(self.PetItem))
        tempItem:SetCallBack(handler(self, self.SelectItem))
        tempItem.transform:SetParent(self.Content)
        SetLocalScale(tempItem.transform, 1, 1, 1)
        tempItem.transform.anchoredPosition3D = Vector3(0, baseY - (i - 1) * self.itemSize.y, 0)
        table.insert(self.itemList, tempItem)
    end
end

--function PetReplacePanel:CreateItems(dataList, baseY)
--
--    for i = 1, #dataList, 1 do
--        local tempItem = PetReplaceItemView(newObject(self.PetItem), dataList[i])
--        tempItem:SetCallBack(handler(self, self.SelectItem))
--        tempItem.transform:SetParent(self.Content)
--        SetLocalScale(tempItem.transform, 1, 1, 1)
--        tempItem.transform.anchoredPosition3D = Vector3(0, baseY - (i - 1) * self.itemSize.y, 0)
--        self.itemList[i] = tempItem
--    end
--end