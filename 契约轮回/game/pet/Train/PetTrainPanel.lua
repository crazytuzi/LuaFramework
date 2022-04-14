---
--- Created by  R2D2
--- DateTime: 2019/4/19 17:01
---
PetTrainPanel = PetTrainPanel or class("PetTrainPanel", BaseItem)
local this = PetTrainPanel

function PetTrainPanel:ctor(parent_node, parent_panel)
    self.abName = "pet"
    self.assetName = "PetTrainPanel"
    self.layer = "UI"

    self.model = PetModel:GetInstance()

    self.events = {}
    self.modelEvents = {}

    self.goodItems = {}

    PetTrainPanel.super.Load(self)
end

function PetTrainPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    self.model:RemoveTabListener(self.modelEvents)

    if (self.Items) then
        for _, v in pairs(self.Items) do
            v:destroy()
        end
        self.Items = {}
    end

    for _, v in pairs(self.goodItems) do
        v:destroy()
    end
    self.goodItems = {}
end

function PetTrainPanel:LoadCallBack()
    self.nodes = {
        "ValueTip",
        "Value",
        "ItemParent",
        "Item",
        "GoodItem",
        "InActiveBtn",
        "RefiningBtn",
        "TrainBtn",
        "GoodParent",
        "BestTip",
        "Power/PowerValue",
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()

    if (self.petData and self.gameObject.activeSelf) then
        self:RefreshView()
    end
end

function PetTrainPanel:InitUI()
    self.valueTipText = GetText(self.ValueTip)
    self.valueText = GetText(self.Value)
    self.ItemPrefab = self.Item.gameObject
    self.goodItemPrefab = self.GoodItem.gameObject

    self.trainBtnImage = GetImage(self.TrainBtn)
    self.refiningBtnImage = GetImage(self.RefiningBtn)
    self.PowerValue = GetText(self.PowerValue)

    SetVisible(self.ItemPrefab, false)
    SetVisible(self.goodItemPrefab, false)
end

function PetTrainPanel:AddEvent()
    self.modelEvents[#self.modelEvents + 1] =
        self.model:AddListener(PetEvent.Pet_Model_SelectPetEvent, handler(self, self.OnSelectPet))
    self.modelEvents[#self.modelEvents + 1] =
        self.model:AddListener(PetEvent.Pet_Model_TrainBattlePetEvent, handler(self, self.TrainBattlePet))
    self.modelEvents[#self.modelEvents + 1] =
        self.model:AddListener(PetEvent.Pet_Model_CrossBattlePetEvent, handler(self, self.CrossBattlePet))
    self.modelEvents[#self.modelEvents + 1] =
        self.model:AddListener(PetEvent.Pet_Model_ChangeBattlePetEvent, handler(self, self.OnChangeBattlePet))
    self.modelEvents[#self.modelEvents + 1] =
        self.model:AddListener(PetEvent.Pet_Model_DecomposePetEvent, handler(self, self.OnDecomposePet))

    AddButtonEvent(self.RefiningBtn.gameObject, handler(self, self.OnRefiningBtn))
    AddButtonEvent(self.TrainBtn.gameObject, handler(self, self.OnTrainBtn), nil, nil, 0.5)

    local function call_back()
        Notify.ShowText(ConfigLanguage.Pet.NotObtainment)
    end
    AddButtonEvent(self.InActiveBtn.gameObject, call_back)
end

function PetTrainPanel:OnSelectPet(petData)
    self.petData = petData
    self:RefreshView()
end

function PetTrainPanel:OnDecomposePet()
    local _, trainConfig, isFull, isMax = self.model:GetPetTrainValue(self.petData)

    self:RefreshState(trainConfig, isFull, isMax)
end

function PetTrainPanel:TrainBattlePet(petData)
    if (self.petData.Config.order == petData.Config.order) then
        self.petData = petData
        self:RefreshValue()
    end
end

function PetTrainPanel:CrossBattlePet(petData)
    if (self.petData.Config.order == petData.Config.order) then
        self.petData = petData
        self:RefreshValue(true)
    end
end

function PetTrainPanel:OnChangeBattlePet(petData)
    --[[if (self.petData.Config.order == petData.Config.order and self.gameObject.activeSelf) then
        self.petData = petData
        self:RefreshView()
    end--]]
end

function PetTrainPanel:OnRefiningBtn()
    local isCanCost = self:CheckCost(true)
    if (isCanCost) then
        PetController:GetInstance():RequestCrossPet(self.petData.Config.order)
    end
end

function PetTrainPanel:OnTrainBtn()
    local isCanCost = self:CheckCost(true)
    if (isCanCost) then
        PetController:GetInstance():RequestTrainPet(self.petData.Config.order)
    end
end

---检测消耗品是否足够
function PetTrainPanel:CheckCost(isNotice)
    local _, trainConfig, isFull = self.model:GetPetTrainValue(self.petData)

    local cost = isFull and String2Table(trainConfig.cross_cost) or String2Table(trainConfig.strength_cost)

    local result = {}
    local isEnough = true

    for _, v in ipairs(cost) do
        local num = BagModel:GetInstance():GetGoldAndItemNumByItemID(v[1])
        if (num < v[2]) then
            local name = Config.db_item[v[1]].name
            table.insert(result, string.format("%s * %s", name, v[2] - num))
            isEnough = false
        end
    end

    if (isNotice and #result > 0) then
        Notify.ShowText("Insufficient:" .. table.concat(result, " , "))
    end

    return isEnough
end

function PetTrainPanel:SetData(petData)
    self.petData = petData

    if (self.is_loaded) then
        self:RefreshView()
    end
end

function PetTrainPanel:RefreshValue(isCross)
    local values, trainConfig, isFull, isMax = self.model:GetPetTrainValue(self.petData)

    for i, v in ipairs(values) do
        self.Items[i]:RefreshData(v, isMax)
    end

    if (isCross) then
        self:RefreshBaseInfo(trainConfig, isFull, isMax)
    else
        self:RefreshState(trainConfig, isFull, isMax)
    end
end

function PetTrainPanel:RefreshState(trainConfig, isFull, isMax)
    if (isFull) then
        if isMax then
            SetVisible(self.GoodParent.gameObject, false)
        else
            SetVisible(self.GoodParent.gameObject, true)
            self:RefreshGoodItem(String2Table(trainConfig.cross_cost))
        end
    else
        SetVisible(self.GoodParent.gameObject, true)
        self:RefreshGoodItem(String2Table(trainConfig.strength_cost))
    end

    local isOverdue = self.petData:CheckOverdue()
    SetVisible(self.RefiningBtn, false)
    if self.petData.IsActive and (not isOverdue) then
        --if (isFull and isMax) then
        --    SetVisible(self.RefiningBtn, false)
        --    SetVisible(self.TrainBtn, false)
        --    SetVisible(self.InActiveBtn, false)
        --    SetVisible(self.BestTip, true)
        --    --self.bestImage.enabled = true
        --else
        --    SetVisible(self.RefiningBtn, isFull)
        --    SetVisible(self.TrainBtn, not isFull)
        --    SetVisible(self.InActiveBtn, false)
        --    SetVisible(self.BestTip, false)
        --
        --    --self.bestImage.enabled = false
        --end
        if (isFull) then
            if (isMax) then
                SetVisible(self.RefiningBtn, false)
                SetVisible(self.TrainBtn, false)
                SetVisible(self.InActiveBtn, false)
                SetVisible(self.BestTip, true)
            else
                SetVisible(self.RefiningBtn, true)
                SetVisible(self.TrainBtn, false)
                SetVisible(self.InActiveBtn, false)
                SetVisible(self.BestTip, false)

                local isCanCost = self:CheckCost(false)
                local resName = isCanCost and "btn_yellow_3" or "btn_gray_3"
                lua_resMgr:SetImageTexture(self, self.refiningBtnImage, "common_image", resName, true)
            end
        else
            SetVisible(self.RefiningBtn, false)
            SetVisible(self.TrainBtn, true)
            SetVisible(self.InActiveBtn, false)
            SetVisible(self.BestTip, false)

            local isCanCost = self:CheckCost(false)
            local resName = isCanCost and "btn_yellow_3" or "btn_gray_3"
            lua_resMgr:SetImageTexture(self, self.trainBtnImage, "common_image", resName, true)
        end
    else
        --self.bestImage.enabled = false
        SetVisible(self.RefiningBtn, false)
        SetVisible(self.TrainBtn, false)
        SetVisible(self.InActiveBtn, true)
        SetVisible(self.BestTip, false)
    end
end

function PetTrainPanel:RefreshView()
    local values, trainConfig, isFull, isMax = self.model:GetPetTrainValue(self.petData)

    self:RefreshBaseInfo(trainConfig, isFull, isMax)
    self:RefreshTrainItem(values, isMax)
end

function PetTrainPanel:RefreshBaseInfo(trainConfig, isFull, isMax)
    local tab = String2Table(trainConfig.plus_percent)
    local attrName = enumName.ATTR[tab[1][1]]

    self.valueTipText.text = string.format(ConfigLanguage.Pet.TrainPercentTip, self.petData.Config.name, attrName)
    self.valueText.text = string.format("%.2f%%", tab[1][2] / 100)

    --self.valueTipText.text = string.format(ConfigLanguage.Pet.TrainPercentTip, self.petData.Config.name)
    --self.valueText.text = string.format("%.2f%%", trainConfig.percent / 100)

    self:RefreshState(trainConfig, isFull, isMax)
    if self.petData.IsActive then
        self.PowerValue.text = self.petData.Data.pet.power
    else
        self.PowerValue.text = "wwwwwww"
    end
end

function PetTrainPanel:RefreshTrainItem(values, isMax)
    self:CreateTrainItem(#values)

    for i, v in ipairs(values) do
        self.Items[i]:SetData(v, isMax)
        SetVisible(self.Items[i], true)
    end

    for i = #values + 1, #self.Items do
        SetVisible(self.Items[i], false)
    end
end

function PetTrainPanel:RefreshGoodItem(goods)
    self:CreateGoodItem(#goods)

    for i, v in ipairs(goods) do
        self.goodItems[i]:SetData(v)
        SetVisible(self.goodItems[i], true)
    end

    for i = #goods + 1, #self.goodItems do
        SetVisible(self.goodItems[i], false)
    end
end

function PetTrainPanel:CreateGoodItem(count)
    self.goodItems = self.goodItems or {}

    if count <= #self.goodItems then
        return
    end

    for i = #self.goodItems + 1, count do
        local tempItem = PetTrainGoodItemView(newObject(self.goodItemPrefab))
        tempItem.transform:SetParent(self.GoodParent)
        SetLocalScale(tempItem.transform, 1, 1, 1)
        table.insert(self.goodItems, tempItem)
    end
end

function PetTrainPanel:CreateTrainItem(count)
    self.Items = self.Items or {}

    if count <= #self.Items then
        return
    end

    for i = #self.Items + 1, count do
        local tempItem = PetTrainItemView(newObject(self.ItemPrefab))
        tempItem.transform:SetParent(self.ItemParent)
        SetLocalScale(tempItem.transform, 1, 1, 1)
        table.insert(self.Items, tempItem)
    end
end
--
--function PetTrainPanel:GetPetCurrValue()
--
--    local isMax = self.model:GetMaxTrainByOrder(self.petData.Config.order)
--    isMax = self.petData.IsActive and isMax <= self.petData.Data.equip.stren_phase or false
--
--    local tKey = self.petData.Config.order .. "@" .. (self.petData.IsActive and self.petData.Data.equip.stren_phase or 0)
--    local tConfig = Config.db_pet_strong[tKey]
--
--    local base = String2Table(tConfig.base)
--    local max = String2Table(tConfig.max)
--    local stones = self.petData.IsActive and self.petData.Data.equip.stones or {}
--
--    local values = {}
--    local isFull = true
--    for i, v in ipairs(base) do
--        local v2 = stones[v[1]] or v[2]
--
--        if (v2 < max[i][2]) then
--            isFull = false
--        end
--        table.insert(values, { v[1], v2, max[i][2] })
--    end
--
--    return values, tConfig, isFull, isMax
--end
