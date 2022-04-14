---
--- Created by  R2D2
--- DateTime: 2019/5/8 16:01
---
require("game.pet.BaseInfo.PetBaseAttributeView")
require("game.pet.BaseInfo.PetBaseInbornAttributeView")
require("game.pet.BaseInfo.PetBaseSkillView")

PetComposePanel = PetComposePanel or class("PetComposePanel", BaseItem)
local this = PetComposePanel

function PetComposePanel:ctor(parent_node, parent_panel)
    self.abName = "pet"
    self.imageAb = "pet_image"
    self.assetName = "PetComposePanel"
    self.layer = "UI"

    self.model = PetModel:GetInstance()

    self.events = {}
    self.modelEvents = {}

    self.baseAttributeView = self.baseAttributeView or PetBaseAttributeView()
    self.inbornAttributeView = self.inbornAttributeView or PetBaseInbornAttributeView()
    self.skillView = self.skillView or PetBaseSkillView()

    PetComposePanel.super.Load(self)
end

function PetComposePanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    self.model:RemoveTabListener(self.modelEvents)


    for k,v in pairs(self.itemSlots) do
        v:destroy()
    end
    self.itemSlots = nil

    if self.PetModle then
        self.PetModle:destroy()
        self.PetModle = nil
    end

    for _, v in ipairs(self.itemList) do
        v:destroy()
    end

    self.itemList = {}

    if (self.inbornAttributeView) then
        self.inbornAttributeView:destroy()
        self.inbornAttributeView = nil
    end
    
    if(self.epImageList) then
        for _, value in pairs(self.epImageList) do
            value = nil
        end
        self.epImageList = nil
    end
      
    if(self.toggles) then
        for _, value in pairs(self.toggles) do
            value = nil
        end
        self.toggles = nil
    end

    if self.reddot then
        self.reddot:destroy()
        self.reddot = nil
    end
    if self.reddot2 then
        self.reddot2:destroy()
        self.reddot2 = nil
    end
    if self.reddot3 then
        self.reddot3:destroy()
        self.reddot3 = nil
    end

    if self.skillView then
        self.skillView:destroy()
        self.skillView = nil
    end

    if self.baseAttributeView then
        self.baseAttributeView:destroy()
        self.baseAttributeView = nil
    end
end

function PetComposePanel:LoadCallBack()
    self.nodes = {
        "Model",
        "Right",
        ---属性显示
        "Right/AttrView/Condition", "Right/AttrView/QualityNameText",

        "Right/AttrView/BaseAttr/BTitle1", "Right/AttrView/BaseAttr/Slider1", "Right/AttrView/BaseAttr/Slider1/ForeGround1", "Right/AttrView/BaseAttr/Value1",
        "Right/AttrView/BaseAttr/BTitle2", "Right/AttrView/BaseAttr/Slider2", "Right/AttrView/BaseAttr/Slider2/ForeGround2", "Right/AttrView/BaseAttr/Value2",
        "Right/AttrView/BaseAttr/BTitle3", "Right/AttrView/BaseAttr/Slider3", "Right/AttrView/BaseAttr/Slider3/ForeGround3", "Right/AttrView/BaseAttr/Value3",
        "Right/AttrView/BaseAttr/BTitle4", "Right/AttrView/BaseAttr/Slider4", "Right/AttrView/BaseAttr/Slider4/ForeGround4", "Right/AttrView/BaseAttr/Value4",
        "Right/AttrView/BaseAttr/BTitle5", "Right/AttrView/BaseAttr/Slider5", "Right/AttrView/BaseAttr/Slider5/ForeGround5", "Right/AttrView/BaseAttr/Value5",
        "Right/AttrView/BaseAttr/BTitle6", "Right/AttrView/BaseAttr/Slider6", "Right/AttrView/BaseAttr/Slider6/ForeGround6", "Right/AttrView/BaseAttr/Value6",

        "Right/AttrView/InbornAttr/ItemParent", "Right/AttrView/InbornAttr/ItemParent/ItemPrefab", "Right/AttrView/InbornAttr/InbornTip",

        "Right/AttrView/Skills/SkillIcon1", "Right/AttrView/Skills/Lock1", "Right/AttrView/Skills/SkillLevel1", "Right/AttrView/Skills/SkillTitle1",
        "Right/AttrView/Skills/SkillIcon2", "Right/AttrView/Skills/Lock2", "Right/AttrView/Skills/SkillLevel2", "Right/AttrView/Skills/SkillTitle2",
        "Right/AttrView/Skills/SkillIcon3", "Right/AttrView/Skills/Lock3", "Right/AttrView/Skills/SkillLevel3", "Right/AttrView/Skills/SkillTitle3",

        ---名称等基本信息
        "BaseInfo/EP/EP1", "BaseInfo/EP/EP2", "BaseInfo/EP/EP3", "BaseInfo/EP/EP4", "BaseInfo/NameText", 
        "BaseInfo/NoEvolution", "BaseInfo/QualityName",

        ---操作部分
        "SelectView/Slot1", "SelectView/Slot2", "SelectView/Slot3", "SelectView/OneShotBtn", "SelectView/ComposeBtn", "SelectView/TipImg",

        ---列表展示
        "PetView",
        "PetView/ScrollView", "PetView/ScrollView/Viewport/Content", "PetView/Toggle2", "PetView/Toggle1", "PetView/PetItemPrefab", "PetView/Selector",
        "PetView/Tipbtn", "prob", "prob/levlicon",
        "Right/AttrView/hurt_txt",
        "PetView/Toggle1/Label1","PetView/Toggle2/Label2",
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()

    self.toggles[1].isOn = true
    self:RefreshProb()
    SetAlignType(self.PetView.transform, bit.bor(AlignType.Left, AlignType.Null))
    SetAlignType(self.Right.transform, bit.bor(AlignType.Right, AlignType.Null))
end

function PetComposePanel:InitUI()

    ---列表
    self.itemSize = self.PetItemPrefab.sizeDelta
    self.PetItemPrefab.gameObject:SetActive(false)

    self.toggles = {}
    table.insert(self.toggles, GetToggle(self.Toggle1))
    table.insert(self.toggles, GetToggle(self.Toggle2))

    ---基本信息
    self.nameText = GetText(self.NameText)
    self.qualityNameImage = GetImage(self.QualityName)
    self.noEvolutionImg = GetImage(self.NoEvolution)
    self.hurt_txt = GetText(self.hurt_txt)
    self.prob = GetText(self.prob)
    self.levlicon = GetImage(self.levlicon)
    self.Label1 = GetText(self.Label1)
    self.Label2 = GetText(self.Label2)
    self.epImageList = {}
    table.insert(self.epImageList, GetImage(self.EP1))
    table.insert(self.epImageList, GetImage(self.EP2))
    table.insert(self.epImageList, GetImage(self.EP3))
    table.insert(self.epImageList, GetImage(self.EP4))

    ---属性部分
    self.conditionText = GetText(self.Condition)
    self.qualityNameText = GetText(self.QualityNameText)

    self.baseAttributeView:AddItem(self.BTitle1, self.Slider1, self.ForeGround1, self.Value1)
    self.baseAttributeView:AddItem(self.BTitle2, self.Slider2, self.ForeGround2, self.Value2)
    self.baseAttributeView:AddItem(self.BTitle3, self.Slider3, self.ForeGround3, self.Value3)
    self.baseAttributeView:AddItem(self.BTitle4, self.Slider4, self.ForeGround4, self.Value4)
    self.baseAttributeView:AddItem(self.BTitle5, self.Slider5, self.ForeGround5, self.Value5)
    self.baseAttributeView:AddItem(self.BTitle6, self.Slider6, self.ForeGround6, self.Value6)

    self.inbornAttributeView:InitUI(self.ItemPrefab, self.ItemParent, self.InbornTip)

    self.skillView:AddItem(self.SkillIcon1, self.Lock1, self.SkillLevel1, self.SkillTitle1)
    self.skillView:AddItem(self.SkillIcon2, self.Lock2, self.SkillLevel2, self.SkillTitle2)
    self.skillView:AddItem(self.SkillIcon3, self.Lock3, self.SkillLevel3, self.SkillTitle3)

    ---操作部分
    self.itemSlots = {}
    for i = 1, 3 do
        local slot = PetComposeSlotItemView(self["Slot" .. i], nil, i)
        slot:SetCallBack(handler(self, self.OnSlotClick))
        table.insert(self.itemSlots, slot)
    end

end

function PetComposePanel:AddEvent()
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(PetEvent.Pet_Model_ComposePetEvent, handler(self, self.OnComposePet))

    for i, v in ipairs(self.toggles) do
        local function call_back(obj, isOn)
            self:OnSelectType(i)
        end
        AddValueChange(v.gameObject, call_back)
    end

    AddButtonEvent(self.OneShotBtn.gameObject, handler(self, self.OnOneShotBtn))
    AddButtonEvent(self.ComposeBtn.gameObject, handler(self, self.OnComposeBtn))

    local function call_back(target,x,y)
        ShowHelpTip(HelpConfig.Pet.ComposeTip, true)
    end
    AddButtonEvent(self.Tipbtn.gameObject,call_back)
end

function PetComposePanel:OnDisable()
    self:ClearSlots()
end

function PetComposePanel:OnComposePet(id, success)
    self:ClearSlots()
    if success then
        Notify.ShowText(ConfigLanguage.Pet.ComposeSuccess)
    else
        Notify.ShowText("If the combination failed,")
    end
    self:ShowRedDot()
end

function PetComposePanel:OnOneShotBtn()

    local pets, lackNum, name = self:GetViablePet()

    if (lackNum > 0) then
        Notify.ShowText(string.format(ConfigLanguage.Pet.NoComposeCostPet, name, lackNum))
    end
    if (#pets == 0) then
        return
    end

    local tempSlots = {}
    for _, v in ipairs(self.itemSlots) do
        if not v.data then
            table.insert(tempSlots, v)
        end
    end

    local c = math.min(#tempSlots, #pets)

    for i = 1, c do
        tempSlots[i]:SetData(pets[i])
    end

    --if (#pets < #tempSlots) then
    --    Notify.ShowText(string.format(ConfigLanguage.Pet.NoComposeCostPet, name, lackNum))
    --    --Notify.ShowText(ConfigLanguage.Pet.NotEnoughPetToFill)
    --end
    self:RefreshProb()
end

function PetComposePanel:OnComposeBtn()

    local _, lackNum, name = self:GetViablePet()
    if (lackNum > 0) then
        Notify.ShowText(string.format(ConfigLanguage.Pet.NoComposeCostPet, name, lackNum))
        return
    end 

    local slotPetsUid, count, hasEvolution, hasBattlePet, has_bind = self:GetOnSlotUid()

    if (count ~= self.composeCfg.cost[1][2]) then
        Notify.ShowText(ConfigLanguage.Pet.NotFillAllSlot)
        return
    end

    local function call_back()

        local function sub_call_back()
            PetController:GetInstance():RequestComposePet(self.composeCfg.id, slotPetsUid)
        end

        if (hasEvolution) then
            Dialog.ShowTwo("Tip", ConfigLanguage.Pet.HasEvolutionPetToCompose, "Confirm", sub_call_back, nil, "Cancel", nil, nil)
        else
            sub_call_back()
        end
    end
    local function call_back2()
        if (hasBattlePet) then
            Dialog.ShowTwo("Tip", ConfigLanguage.Pet.HadBattlePetToCompose, "Confirm", call_back, nil, "Cancel", nil, nil)
        else
            call_back()
        end
    end
    
    if has_bind then
        Dialog.ShowTwo("Tip","CBound pet is found in the combining materials\nombined pet will bind to you\ncontinue?","Confirm",call_back2)
    else
        call_back2()
    end
end

--function PetComposePanel:RequestCompose()
--    local onSlotPetsUid, _, _ = self:GetOnSlotUid()
--    PetController:GetInstance():RequestComposePet(self.composeCfg.id, onSlotPetsUid)
--end

function PetComposePanel:OnSlotClick(slot)
    if (slot.data) then
        slot:SetData()
    end

    local pets, lackNum, name, item_id = self:GetViablePet()
    if (#pets == 0) then
        --Notify.ShowText(string.format(ConfigLanguage.Pet.NoComposeCostPet, name, lackNum))
        local UITransform = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.UI)
        local tipView = PetGetWayView(UITransform)
        tipView:SetData(item_id)
        return
    end

    local pos = slot.transform.position
    local tipView = PetComposePickPanel()
    tipView:SetData(pets, pos, slot)
    self:RefreshProb()
end

---获取已经安装的Pet uid
function PetComposePanel:GetOnSlotUid()
    local uids = {}
    local count = 0
    local hasEvolution = false
    local hasBattlePet = false
    local has_bind = false
    for _, v in ipairs(self.itemSlots) do
        if v.data and v.data.Data then
            uids[v.data.Data.uid] = true
            count = count + 1
            has_bind = has_bind or v.data.Data.bind
            if (v.data.Data.extra > 0) then
                hasEvolution = true
            end

            if (not v.data.IsInBag) then
                hasBattlePet = true
            end
        end
    end
    return uids, count, hasEvolution, hasBattlePet, has_bind
end

--刷新成功率
function PetComposePanel:RefreshProb()
    local level = RoleInfoModel:GetInstance():GetRoleValue("level")
    local need_level = self.composeCfg.level
    if level < need_level then
        local _, is_under_top, remain = GetLevelShow(need_level)
        if is_under_top then
            SetVisible(self.levlicon, false)
            self.prob.text = string.format("Unlocks at Lv.%s", need_level)
        else
            SetVisible(self.levlicon, true)
            self.prob.text = string.format("Unlocks at Lv.%s", remain)
        end
    else
        SetVisible(self.levlicon, false)
        local count = 0
        for _, v in ipairs(self.itemSlots) do
            if v.data and v.data.Data then
                count = count +1
            end
        end
        if count ~= self.composeCfg.cost[1][2] then
            self.prob.text = "Success Rate: 0%"
        else
            self.prob.text = string.format("Success Rate: %s", self.composeCfg.proba/100) .. "%"
        end
    end
end

---获取可用于安装的pet
function PetComposePanel:GetViablePet()

    local costTab = self.composeCfg.cost[1]
    local needCount = costTab[2]

    local costCfg = Config.db_pet[costTab[1]]
    local costOrder = costCfg.order

    local orderPets = self.model:GetAllList(function(cfg)
        return cfg.order == costOrder
    end)

    local battlePet = self.model:GetBattlePetByOrder(costOrder)
    if (battlePet) then
        table.insert(orderPets, battlePet)
    end

    local onSlotPetsUid, inSlotCount, _, _ = self:GetOnSlotUid()
    local pets = {}

    for i, v in ipairs(orderPets) do
        if (v.Config.id == costTab[1] and (not onSlotPetsUid[v.Data.uid])) then
            table.insert(pets, v)
        end
    end

    local lackNum = needCount - inSlotCount - #pets
    local name = ConfigLanguage.Pet["Quality_Name_" .. costCfg.quality] .. costCfg.name
    return pets, lackNum, name, costTab[1]
end

---列表切换
function PetComposePanel:OnSelectType(typeId)

    SetVisible(self.TipImg, typeId == 2)
    local data = self.model:GetComposeGroupByType(typeId)
    self:CreatePetItem(#data)

    for i, v in ipairs(data) do
        local cfg = Config.db_pet[v.target[1][1]]
        self.itemList[i]:SetData(v, cfg)
        SetVisible(self.itemList[i], true)
    end

    for i = #data + 1, #self.itemList do
        SetVisible(self.itemList[i], false)
    end

    if (#data > 0) then
        self:OnSelectItem(self.itemList[1])
    end
    if typeId == 1 then
        SetColor(self.Label1, 119, 142, 186, 255)
        SetColor(self.Label2, 255, 255, 255, 255)
    else
        SetColor(self.Label2, 119, 142, 186, 255)
        SetColor(self.Label1, 255, 255, 255, 255)
    end
end

function PetComposePanel:CreatePetItem(count)

    self.itemList = self.itemList or {}

    local fullH = count * self.itemSize.y
    local baseY = (fullH - self.itemSize.y) / 2 - 5
    SetSizeDeltaY(self.Content, fullH)

    if count <= #self.itemList then
        return
    end

    for i = #self.itemList + 1, count do
        local tempItem = PetComposeItemView(newObject(self.PetItemPrefab))
        tempItem:SetCallBack(handler(self, self.OnSelectItem))
        tempItem.transform:SetParent(self.Content)
        SetLocalScale(tempItem.transform, 1, 1, 1)
        tempItem.transform.anchoredPosition3D = Vector3(0, baseY - (i - 1) * self.itemSize.y, 0)
        table.insert(self.itemList, tempItem)
    end
end

function PetComposePanel:OnSelectItem(item)
    SetParent(self.Selector, item.transform)
    self.Selector:SetSiblingIndex(1)
    SetAnchoredPosition(self.Selector, 0, 0)
    self:SetCurrPet(item.data, item.Config)
    self:RefreshProb()
end

function PetComposePanel:SetCurrPet(composeCfg, petCfg)

    if (composeCfg == self.composeCfg) then
        return
    end

    self.composeCfg = composeCfg
    self.petData = {
        ["Config"] = petCfg, ["IsActive"] = false, ["HasInBag"] = false
    }

    self:ClearSlots()
    self:RefreshView()
end

---为保持调用一致保留的空方法
function PetComposePanel:SetData()
end

function PetComposePanel:RefreshView()
    self:RefreshAttrView()
    self:RefreshBaseInfoView()
    self:RefreshModel()
    self:ShowRedDot()
end

function PetComposePanel:ClearSlots()
    for _, v in ipairs(self.itemSlots) do
        v:SetData()
    end
    self:RefreshProb()
end

function PetComposePanel:RefreshModel()
    if (self.PetModle) then
        self.PetModle:ReLoadPet(self.petData.Config.model)
    else
        self.PetModle = UIPetCamera(self.Model, nil, self.petData.Config.model)
    end
    ---修正位置
    local located = String2Table(self.petData.Config.located)
    local config = {}
    config.offset = { x = located[1] or 0, y = located[2] or 0, z = located[3] or 0 }
    self.PetModle:SetConfig(config)
end

function PetComposePanel:RefreshAttrView()

    local condition = self.model:GetConditionString(self.petData.Config)

    self.qualityNameText.text = ConfigLanguage.Pet["Quality_Name_" .. self.petData.Config.quality]
    self.conditionText.text = condition and condition or "None"

    self.hurt_txt.text = "Inherit character damage" .. self.petData.Config.atk/100 .. "%"

    self.baseAttributeView:RefreshView(self.petData)
    self.inbornAttributeView:RefreshView(self.petData)
    self.skillView:RefreshView(self.petData)
end

function PetComposePanel:RefreshBaseInfoView()

    if self.petData.Config.type == 2 then
        self.nameText.text = string.format("%s·%s", self.petData.Config.name,ConfigLanguage.Pet.ActivityType)
    else
        self.nameText.text = string.format("%s·T%s", self.petData.Config.name,self.petData.Config.order_show)
    end

    lua_resMgr:SetImageTexture(self, self.qualityNameImage, self.imageAb, "Q_Name_" .. self.petData.Config.quality, true)

    local count = self.petData.Config.evolution
    for i, v in ipairs(self.epImageList) do
        v.enabled = i <= count
    end
    self.noEvolutionImg.enabled = count <= 0
end

function PetComposePanel:ShowRedDot()
    local costTab = self.composeCfg.cost[1]
    local pet_id = costTab[1]
    local need_count = costTab[2]
    local can_compose = self.model:HasEnoughPets(pet_id, need_count, self.composeCfg.level)
    if can_compose then
        if not self.reddot then
            self.reddot = RedDot(self.OneShotBtn)
            SetLocalPosition(self.reddot.transform, 55, 14)
        end
        SetVisible(self.reddot, true)
    else
        if self.reddot then
            SetVisible(self.reddot, false)
        end
    end
    self:SetToggleRedDot()
end

--显示幼体，成体红点
function PetComposePanel:SetToggleRedDot()
    local flag, type_id = self.model:HasCompose()
    if self.reddot2 then
        SetVisible(self.reddot2, false)
    end
    if self.reddot3 then
        SetVisible(self.reddot3, false)
    end
    if type_id == 1 then
        if not self.reddot2 then
            self.reddot2 = RedDot(self.Toggle1)
            SetLocalPosition(self.reddot2.transform, 55, 14)
        end
        SetVisible(self.reddot2, flag)
    elseif type_id == 2 then
        if not self.reddot3 then
            self.reddot3 = RedDot(self.Toggle2)
            SetLocalPosition(self.reddot3.transform, 55, 14)
        end
        SetVisible(self.reddot3, flag)
    end
end
