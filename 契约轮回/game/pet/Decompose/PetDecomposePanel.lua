---
--- Created by R2D2.
--- DateTime: 2019/5/14 14:57
---

PetDecomposePanel = PetDecomposePanel or class("PetDecomposePanel", WindowPanel)
local PetDecomposePanel = PetDecomposePanel

function PetDecomposePanel:ctor()
    self.abName = "pet"
    self.imageAb = "pet_image"
    self.assetName = "PetDecomposePanel"
    self.layer = "UI"

    self.panel_type = 3
    self.show_sidebar = false

    self.item_list = {}
    self.modelEvents = {}
    self.events = {}

    self.selectedUid = {}
    self.qualityFilterKey = 4

    self.model = PetModel:GetInstance()
    self.UILayerTransform = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.UI)
end

function PetDecomposePanel:dctor()
    self.currSelectItem = nil
    self.scrollViewUtil:OnDestroy()
    self.scrollViewUtil = nil

    GlobalEvent:RemoveTabListener(self.events)
    self.model:RemoveTabListener(self.modelEvents)

    self.events = {}
    self.modelEvents = {}
    self.selectedUid = {}
    if self.reddot then
        self.reddot:destroy()
        self.reddot = nil
    end
end

function PetDecomposePanel:Open()
    PetDecomposePanel.super.Open(self)
end

function PetDecomposePanel:LoadCallBack()
    self.nodes = { "ScrollView", "ScrollView/Viewport/Content", "DecomposeBtn",
                   "DecomposeTip", "DecomposeTip/Num", "DecomposeTip/ItemIcon", "HelpBtn", "QualityDropdown", "Toggle", }
    self:GetChildren(self.nodes)

    self:SetPanelSize(640, 495)
    self:SetTileTextImage(self.imageAb, "Pet_Decompose_Title_Txt")
    self:SetTitleIcon(self.imageAb, "Pet_title_Icon")

    self:InitUI()
    self:AddEvent()

    self:RefreshData()
    self:RefreshDecomposeTip()
    self:CreateItems(self.model.BagCellCount)

    self.qualityDropdown.value = self.dropdownSelectIndex - 1
end

function PetDecomposePanel:InitUI()

    self.decomposeIcon = GetImage(self.ItemIcon)
    self.decomposeNumText = GetText(self.Num)

    self.autoDecomposeToggle = GetToggle(self.Toggle)
    self.autoDecomposeToggle.isOn = self.model.IsAutoDecompose

    self.qualityDropdown = GetDropDown(self.QualityDropdown)
    self.qualityRealKey = { }

    local c = {}

    for k, v in ipairs(self.model.qualityList) do
        if(self.qualityFilterKey == v) then
            self.dropdownSelectIndex = k
        end
        table.insert(self.qualityRealKey, v)
        table.insert(c, ConfigLanguage.Pet["Quality_Name_" .. v] .. "and below")
    end
    self:FillDropDownData(self.qualityDropdown, c)
    self:ShowReddot()
end

function PetDecomposePanel:AddEvent()
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(PetEvent.Pet_Model_DeleteBagPetEvent, handler(self, self.OnDeleteBagPet))
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(PetEvent.Pet_Model_DecomposePetEvent, handler(self, self.OnDecomposePet))

    AddValueChange(self.QualityDropdown.gameObject, handler(self, self.OnQualityDropdown))
    AddValueChange(self.Toggle.gameObject, handler(self, self.OnToggleChange))

    AddButtonEvent(self.DecomposeBtn.gameObject, handler(self, self.OnDecomposeBtn))

    local function helpTip ()
        ShowHelpTip(HelpConfig.Pet.DecomposeTip)
    end
    AddClickEvent(self.HelpBtn.gameObject, helpTip)
end

function PetDecomposePanel:FillDropDownData(dropdown, data)
    dropdown:ClearOptions()
    local options = dropdown.options;
    for _, v in ipairs(data) do
        options:Add(UnityEngine.UI.Dropdown.OptionData(v))
    end
end

function PetDecomposePanel:OnQualityDropdown(go, index)
    local q = self.qualityRealKey[index + 1]

    self.selectedUid = {}

    for _, v in ipairs(self.itemData) do
        if (v.Config.quality <= q) then
            self.selectedUid[v.Data.uid] = v
        end
    end

    self:RefreshDecomposeTip()
    self:RefreshItems()
end

function PetDecomposePanel:OnToggleChange(obj, isOn)
    self.model:SaveSettings(isOn)
end

function PetDecomposePanel:OnDecomposeBtn()

    local tab = {}
    for _, v in pairs(self.selectedUid) do
        local q = v.Config.quality

        if (q >= PetModel.DecomposeQualityDivide) then
            if (tab[q]) then
                if tab[q][v.Config] then
                    tab[q][v.Config] = tab[q][v.Config] + 1
                else
                    tab[q][v.Config] = 1
                end
            else
                tab[q] = { [v.Config] = 1}
            end
        end
    end

    local qualityList = self.model.qualityList
    local tipTab = {}
    for _, v in ipairs(qualityList) do
        if (tab[v]) then
            for k, w in pairs(tab[v]) do
                local str = self.model:GeneratePetDescribe(k, w)
                table.insert(tipTab, str)
            end
            --local str = string.format("%sx%s", ConfigLanguage.Pet["Quality_Name_" .. v], tab[v])
        end
    end

    if (#tipTab > 0) then
        local str = string.format(ConfigLanguage.Pet.HasHighQualityPetToDecompose, table.concat(tipTab, ","))
        Dialog.ShowTwo("Tip", str, "Confirm", handler(self, self.ReqDecompose), nil, "Cancel", nil, nil)
    else
        self:ReqDecompose()
    end
end



function PetDecomposePanel:ReqDecompose()
    local uids = {}
    for k, _ in pairs(self.selectedUid) do
        table.insert(uids, k)
    end

    if (#uids > 0) then
        PetController:GetInstance():RequestDecomposePet(uids)
    else
        Notify.ShowText(ConfigLanguage.Pet.NoPetSelectedToDecompose)
    end
end

function PetDecomposePanel:OnDeleteBagPet(uid)
    --self:FilterRefresh()
end

function PetDecomposePanel:OnDecomposePet()
    self.selectedUid = {}
    self:FilterRefresh()
    self:RefreshDecomposeTip()

    Notify.ShowText(ConfigLanguage.Pet.DecomposeSuccess)
    self:ShowReddot()
end

function PetDecomposePanel:RefreshData()
    self.itemData = self.model:GetAllList()
    self:ArrangeData()
end

function PetDecomposePanel:ArrangeData()
    if (self.itemData and #self.itemData > 1) then
        table.sort(self.itemData, function(a, b)
            --local u1 = self:IsUsable(a.Config)
            --local u2 = self:IsUsable(b.Config)

            --if (u1 == u2) then
            if (a.Config.order == b.Config.order) then
                if (a.Config.quality == b.Config.quality) then
                    return a.Data.score > b.Data.score
                else
                    return a.Config.quality > b.Config.quality
                end
            else
                return a.Config.order > b.Config.order
            end
            --else
            --    return u1 > u2
            --end
        end)
    end
end

function PetDecomposePanel:FilterRefresh()
    self:RefreshData()
    self:RefreshItems()
end

function PetDecomposePanel:RefreshItems()
    if (self.scrollViewUtil) then
        for _, v in pairs(self.scrollViewUtil.loadedCellObjs) do
            self:UpdateCellCB(v)
        end
    end
end

function PetDecomposePanel:CreateItems(cellCount)
    local param = {}
    local cellSize = { width = 70, height = 70 }
    param["scrollViewTra"] = self.ScrollView
    param["cellParent"] = self.Content
    param["cellSize"] = cellSize
    param["cellClass"] = PetBagItemView
    param["begPos"] = Vector2(4, -4)
    param["spanX"] = 3
    param["spanY"] = 4
    param["createCellCB"] = handler(self, self.CreateCellCB)
    param["updateCellCB"] = handler(self, self.UpdateCellCB)
    param["cellCount"] = cellCount
    self.scrollViewUtil = ScrollViewUtil.CreateItems(param)
end

function PetDecomposePanel:CreateCellCB(itemCLS)
    self:UpdateCellCB(itemCLS)
end

function PetDecomposePanel:UpdateCellCB(itemCLS)
    local index = itemCLS.__item_index
    local item = self.itemData[index]

    if item then
        itemCLS:SetData(item, handler(self, self.SelectItem), true)
        itemCLS:SetSelect(self.selectedUid[item.Data.uid] ~= nil)

        self.item_list[index] = itemCLS
    else
        itemCLS:SetData()
    end
end

function PetDecomposePanel:SelectItem(item)

    self.selectedUid = self.selectedUid or {}

    if (item.isSelected) then
        self.selectedUid[item.data.Data.uid] = nil
    else
        self.selectedUid[item.data.Data.uid] = item.data
    end

    item:SetSelect(not item.isSelected)
    self:RefreshDecomposeTip()
end

function PetDecomposePanel:RefreshDecomposeTip()

    local tab
    local gainTab = {}
    for _, v in pairs(self.selectedUid) do
        tab = String2Table(v.Config.gain)

        if gainTab[tab[1]] then
            gainTab[tab[1]] = gainTab[tab[1]] + tab[2]
        else
            gainTab[tab[1]] = tab[2]
        end
    end

    local itemId, num = next(gainTab)
    itemId = itemId or self.model.DecomposeItemId
    num = num or 0

    local itemCfg = Config.db_item[itemId]
    local abName = "iconasset/" .. GoodIconUtil.GetInstance():GetABNameById(itemCfg.icon)
    lua_resMgr:SetImageTexture(self, self.decomposeIcon, abName, tostring(itemCfg.icon), true)

    self.decomposeNumText.text = "x" .. tostring(num)
end


function PetDecomposePanel:ShowReddot()
    local flag = self.model:HasRefining()
    if not self.reddot then
        self.reddot = RedDot(self.DecomposeBtn)
        SetLocalPosition(self.reddot.transform, 55, 14)
    end
    SetVisible(self.reddot, flag)
end
