---
--- Created by R2D2.
--- DateTime: 2019/4/17 19:06
---
PetBagPanel = PetBagPanel or class("PetBagPanel", WindowPanel)
local PetBagPanel = PetBagPanel

function PetBagPanel:ctor()
    self.abName = "pet"
    self.imageAb = "pet_image"
    self.assetName = "PetBagPanel"
    self.layer = "UI"

    self.panel_type = 3
    self.show_sidebar = false

    self.item_list = {}
    self.modelEvents = {}
    self.events = {}

    self.qualityFilterKey = 0
    self.orderFilterKey = -1
    self.model = PetModel:GetInstance()
    self.UILayerTransform = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.UI)
end

function PetBagPanel:dctor()
    self.UITransform = nil
    self.currSelectItem = nil
    self.scrollViewUtil:OnDestroy()
    self.scrollViewUtil = nil
    
    GlobalEvent:RemoveTabListener(self.events)
    self.events = {}
    self.model:RemoveTabListener(self.modelEvents)
    self.modelEvents = {}

    if self.reddot then
        self.reddot:destroy()
        self.reddot = nil
    end
end

function PetBagPanel:Open(orderFilter)
    self.openOrderFilter = orderFilter
    PetBagPanel.super.Open(self)
end

function PetBagPanel:LoadCallBack()
    self.nodes = { "ScrollView", "ScrollView/Viewport/Content",
                   "QualityDropdown", "OrderDropdown", "RefiningBtn", "ArrangeBtn", }
    self:GetChildren(self.nodes)

    self:SetPanelSize(640, 495)
    self:SetTileTextImage(self.imageAb, "Pet_Bag_Title_Txt")
    self:SetTitleIcon(self.imageAb, "Pet_title_Icon")

    self:InitUI()
    self:AddEvent()

    self:RefreshData()
    self:CreateItems(self.model.BagCellCount)
end

function PetBagPanel:InitUI()
    self.qualityDropdown = GetDropDown(self.QualityDropdown)
    self.orderDropdown = GetDropDown(self.OrderDropdown)
    self.qualityRealKey = { 0 }
    self.orderRealKey = { -1, 0 }

    local c = { ConfigLanguage.Pet.All }

    for _, v in ipairs(self.model.qualityList) do
        table.insert(self.qualityRealKey, v)
        table.insert(c, ConfigLanguage.Pet["Quality_Name_" .. v])
    end
    self:FillDropDownData(self.qualityDropdown, c)

    local c = { ConfigLanguage.Pet.All, ConfigLanguage.Pet.ActivityType }
    for k, v in ipairs(self.model.orderShowList) do
        table.insert(self.orderRealKey, self.model.orderList[k])
        if v>0 then
            table.insert(c, ConfigLanguage.Pet.Rank..ChineseNumber(v))
        end
    end
    self:FillDropDownData(self.orderDropdown, c)

    self:CheckOpenParam()
    self:ShowReddot()
end

function PetBagPanel:AddEvent()
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(PetEvent.Pet_Model_DeleteBagPetEvent, handler(self, self.OnDeleteBagPet))
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(PetEvent.Pet_Model_AddBagPetEvent, handler(self, self.OnAddBagPet))
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(PetEvent.Pet_Model_ChangeBattlePetEvent, handler(self, self.OnChangeBattlePet))
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(PetEvent.Pet_Model_BackEvolutionBattlePetEvent, handler(self, self.OnBackEvolutionPet))

    self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.GoodsDetail, handler(self, self.OnGetItemDetail))

    AddValueChange(self.QualityDropdown.gameObject, handler(self, self.OnQualityDropdown))
    AddValueChange(self.OrderDropdown.gameObject, handler(self, self.OnOrderDropdown))

    local function call_back()
        --Notify.ShowText(string.format(ConfigLanguage.Mix.NotOpen))
        lua_panelMgr:GetPanelOrCreate(PetDecomposePanel):Open()
    end
    AddButtonEvent(self.RefiningBtn.gameObject, call_back)

end

function PetBagPanel:FillDropDownData(dropdown, data)
    dropdown:ClearOptions()
    local options = dropdown.options;
    for _, v in ipairs(data) do
        options:Add(UnityEngine.UI.Dropdown.OptionData(v))
    end
end

function PetBagPanel:OnOrderDropdown(go, index)

    local key = self.orderRealKey[index+1]

    if (self.orderFilterKey == key) then
        return
    else
        self.orderFilterKey = key
        self:FilterRefresh()
    end
end

--function PetBagPanel:OnArrangeBtn()
--    self:ArrangeData()
--    self:RefreshItems()
--end

function PetBagPanel:OnQualityDropdown(go, index)
    local key = self.qualityRealKey[index + 1]

    if (self.qualityFilterKey == key) then
        return
    else
        self.qualityFilterKey = key
        self:FilterRefresh()
    end
end

function PetBagPanel:OnGetItemDetail(itemData)
    if (itemData.bag == self.CurrPetData.Data.bag and itemData.uid == self.CurrPetData.Data.uid) then

        --local view = PetShowTipView()
        --local config = Config.db_pet[itemData.id]
        --local data = { ["Data"] = itemData, ["Config"] = config,
        --               ["IsActive"] = true, ["ItemVpPos"] = self.ItemVpPos }

        --view:SetData(data)
        local view = PetShowTipView()
        local pos = self.currSelectItem.transform.position
        view:SetData(itemData, PetModel.TipType.PetBag, pos)
    end
end

function PetBagPanel:OnDeleteBagPet(uid)
    self:FilterRefresh()
    self:ShowReddot()
end

function PetBagPanel:OnAddBagPet()
    self:FilterRefresh()
    self:ShowReddot()
end

function PetBagPanel:OnChangeBattlePet(petData)
    self:RefreshItems()
end

function PetBagPanel:OnBackEvolutionPet(petData)
    self:FilterRefresh()
end

---检查打开时传递的参数
function PetBagPanel:CheckOpenParam()
    if (self.openOrderFilter) then
        local index = self.model:GetOrderIndex(self.openOrderFilter)
        self.orderDropdown.value = index

        self.orderFilterKey = self.openOrderFilter
        self.openOrderFilter = nil
    end
end

function PetBagPanel:RefreshData()

    local qFilter = self.qualityFilterKey
    local oFilter = self.orderFilterKey

    self.itemData = self.model:GetAllList(function(config)
        if (qFilter ~= 0) then
            if (config.quality ~= qFilter) then
                return false
            end
        end
        if (oFilter == -1) then
            return true
        elseif oFilter == 0 then
            return config.order_show == oFilter
        else
            if (config.order ~= oFilter) then
                return false
            end
        end

        return true
    end)

    self:ArrangeData()
end

function PetBagPanel:ArrangeData()
    if (self.itemData and #self.itemData > 1) then
        table.sort(self.itemData, function(a, b)
            local u1 = self:IsUsable(a.Config)
            local u2 = self:IsUsable(b.Config)

            if (u1 == u2) then
                if (a.Config.order == b.Config.order) then
                    if (a.Config.quality == b.Config.quality) then
                        return a.Data.score > b.Data.score
                    else
                        return a.Config.quality > b.Config.quality
                    end
                else
                    return a.Config.order > b.Config.order
                end
            else
                return u1 > u2
            end
        end)
    end
end

function PetBagPanel:FilterRefresh()
    self:RefreshData()
    self:RefreshItems()
end

function PetBagPanel:RefreshItems()
    if (self.scrollViewUtil) then
        for _, v in pairs(self.scrollViewUtil.loadedCellObjs) do
            self:UpdateCellCB(v)
        end
    end
end

function PetBagPanel:CreateItems(cellCount)
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

function PetBagPanel:CreateCellCB(itemCLS)
    self:UpdateCellCB(itemCLS, true)
end

function PetBagPanel:UpdateCellCB(itemCLS)
    local index = itemCLS.__item_index
    local item = self.itemData[index]

    if item then
        itemCLS:SetData(item, handler(self, self.SelectItem))
        self.item_list[index] = itemCLS
    else
        itemCLS:SetData()
    end
end

function PetBagPanel:SelectItem(item)

    if (self.currSelectItem) then
        self.currSelectItem:SetSelect(false)
    end

    self.currSelectItem = item
    self.currSelectItem:SetSelect(true)

    local pos = item.transform.position
    self.ItemVpPos = LayerManager:UIWorldToViewportPoint(pos.x, pos.y, pos.z)

    self.CurrPetData = item.data
    PetController:GetInstance():RequestItemInfo(self.CurrPetData.Data.bag, self.CurrPetData.Data.uid)
end

---是否可用(1,-1)
function PetBagPanel:IsUsable(config)

    local lv = RoleInfoModel.GetInstance():GetRoleValue("level")
    local wake = RoleInfoModel.GetInstance():GetRoleValue("wake")

    if (config.level <= lv and config.wake <= wake) then
        return 1
    else
        return -1
    end
end

function PetBagPanel:ShowReddot()
    local flag = self.model:HasRefining()
    if flag then
        if not self.reddot then
            self.reddot = RedDot(self.RefiningBtn)
            SetLocalPosition(self.reddot.transform, 40, 14)
        end
        SetVisible(self.reddot, true)
    else
        if self.reddot then
            SetVisible(self.reddot, false)
        end
    end
end
