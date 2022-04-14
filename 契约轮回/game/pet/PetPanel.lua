---
--- Created by R2D2.
--- DateTime: 2019/4/4 15:47
---
PetPanel = PetPanel or class("PetPanel", WindowPanel)
local PetPanel = PetPanel

function PetPanel:ctor()
    self.abName = "pet"
    self.imageAb = "pet_image"
    self.assetName = "PetPanel"
    self.layer = "UI"

    self.is_show_money = {
        { Constant.GoldType.Coin, true },
        { Constant.GoldType.BGold, true },
        { Constant.GoldType.Gold, true },
        { Constant.GoldType.PetCream, false }
    }
    --{ PetModel.DecomposeItemId, false } }
    self.win_type = 1 --窗体样式  1 1280*720
    self.show_sidebar = true --是否显示侧边栏
    self.sidebar_style = 2
    self.model = PetModel:GetInstance()
    self.pet_equip_model = PetEquipModel.GetInstance()
    self.bag_model = BagModel.GetInstance()
    self.currentIndex = -1
    self.panels = {}
    self.modelEvents = {}
    self.pet_equip_model_events = {}
    self.bag_model_events = {}
    self.role_events = {}
    self.globalEvents = {}
    self.skillView = self.skillView or PetBaseSkillView()

    self.pet_equip_items = {}
end

function PetPanel:dctor()
    self:StopAction()
    self:StopSchedule()

    self.model:RemoveTabListener(self.modelEvents)
    self.modelEvents = {}

    self.pet_equip_model:RemoveTabListener(self.pet_equip_model_events)
    self.pet_equip_model_events = nil

    self.bag_model:RemoveTabListener(self.bag_model_events)
    self.bag_model_events = nil

    for _, event_id in pairs(self.role_events) do
        RoleInfoModel:GetInstance():GetMainRoleData():RemoveListener(event_id)
    end
    self.role_events = nil

    GlobalEvent:RemoveTabListener(self.globalEvents)
    self.globalEvents = {}

    for _, v in pairs(self.itemList) do
        v:destroy()
    end
    self.itemList = nil

    if (self.redPoints) then
        for _, v in pairs(self.redPoints) do
            v:destroy()
        end
        self.redPoints = nil
    end

    if self.PetModle then
        self.PetModle:destroy()
        self.PetModle = nil
    end

    for _, item in pairs(self.panels) do
        item:destroy()
    end
    self.panels = {}

    if (self.epImageList) then
        for _, value in pairs(self.epImageList) do
            value = nil
        end

        self.epImageList = nil
    end

    if (self.levelItem) then
        self.levelItem:destroy()
        self.levelItem = nil
    end
    if (self.skillView) then
        self.skillView:destroy()
        self.skillView = nil
    end

    for k,v in pairs(self.pet_equip_items) do
        v:destroy()
    end
    self.pet_equip_items = nil
end

function PetPanel:Open(default_tag, default_tog)
    -- self.default_table_index = default_tag or 1
    -- self.default_toggle_index = default_tog or 1

    self.default_table_index = 1
    self.default_toggle_index = 1    
    PetPanel.super.Open(self)
end

function PetPanel:LoadCallBack()
    self.nodes = {
        "Right",
        "Right/SubPanel",
        "Model",
        "EffectParent",
        "Left",
        "Right/BaseInfo",
        "OtherInfo",
        "Left/ScrollView",
        "Left/ScrollView/Viewport/Content",
        "Left/PetItem",
        "Left/Selector",
        "Left/DownArrow",
        "Right/BaseInfo/QualityName",
        "OtherInfo/NameText",
        "OtherInfo/parent/EP","OtherInfo/parent/EP/EP1","OtherInfo/parent/EP/EP2","OtherInfo/parent/EP/EP3","OtherInfo/parent/EP/EP4",
        "OtherInfo/NoEvolution",
        --"OtherInfo/Power/PowerValue",
        "OtherInfo/State/StateImage",
        "OtherInfo/parent/ChangeBtn","OtherInfo/parent/BattleBtn",
        "OtherInfo/GetWay",
        "OtherInfo/GetWayText",
        "OtherInfo/RenewalBtn",
        "OtherInfo/CountDownText",
        "composeparent",
        "OtherInfo/parent/skills/SkillIcon1","OtherInfo/parent/skills/Lock1","OtherInfo/parent/skills/SkillLevel1",
        "OtherInfo/parent/skills/SkillIcon2","OtherInfo/parent/skills/Lock2","OtherInfo/parent/skills/SkillLevel2",
        "OtherInfo/parent/skills/SkillIcon3","OtherInfo/parent/skills/Lock3","OtherInfo/parent/skills/SkillLevel3",
    
        "OtherInfo/parent/skills",
        "petequipbagparent",
        "OtherInfo/equips/equip_8001","OtherInfo/equips/equip_8004","OtherInfo/equips/equip_8002","OtherInfo/equips","OtherInfo/equips/equip_8003",
        "OtherInfo/parent",
    }
    self:GetChildren(self.nodes)

    self:SetTileTextImage(self.imageAb, "pet_title_txt11asdasdas1")
    --SetSizeDelta(self.transform, ScreenWidth, ScreenHeight)
    self:SetBackgroundImage("iconasset/icon_big_bg_pet_bg", "pet_bg", false)

    self:InitUI()
    self:AddEvent()

    self:SelectItem(self.itemList[1])
    SetAlignType(self.Left.transform, bit.bor(AlignType.Left, AlignType.Null))
    SetAlignType(self.Right.transform, bit.bor(AlignType.Right, AlignType.Null))
    SetAlignType(self.petequipbagparent.transform, bit.bor(AlignType.Right, AlignType.Null))
    self.layerIndex = LuaPanelManager:GetInstance():GetPanelInLayerIndex(self.layer, self)
    
    self.left_old_x, self.left_old_y = GetLocalPosition(self.Left.transform)

end

function PetPanel:SetCurrPet(petData)
    self.CurrPetData = petData
    self:ShowPetModle()

    if (not petData.IsActive) and petData.HasInBag then
        PetController:GetInstance():RequestItemInfo(petData.BagPet.bag, petData.BagPet.uid)
    else
        self:RefreshView()
    end

    self:RefreshRedPoint()
    PetEquipModel.GetInstance().cur_pet_data = petData
    self.model:Brocast(PetEvent.Pet_Model_SelectPetEvent, petData)

    --切换宠物后，请求下宠物装备
    PetController.GetInstance():RequestPetEquips(self.pet_equip_model.cur_pet_data.Config.order)
end

function PetPanel:ShowPetModle()
    if (self.CurrPetData) then
        if (self.PetModle) then
            self.PetModle:ReLoadPet(self.CurrPetData.Config.model)
        else
            self.PetModle = UIPetCamera(self.Model, nil, self.CurrPetData.Config.model, nil, nil, self.layerIndex)
        end

        local located = String2Table(self.CurrPetData.Config.located)
        local config = {}
        config.offset = { x = located[1] or 0, y = located[2] or 0, z = located[3] or 0 }
        self.PetModle:SetConfig(config)
    end
end

function PetPanel:InitUI()
    self.scrollView = GetScrollRect(self.ScrollView)
    --self.powerValueText = GetText(self.PowerValue)
    self.stateImage = GetImage(self.StateImage)
    self.qualityNameImage = GetImage(self.QualityName)

    self.nameText = GetText(self.NameText)
    self.getwayText = GetText(self.GetWayText)
    self.noEvolutionImg = GetImage(self.NoEvolution)

    self.countDownText = GetText(self.CountDownText)

    self.epImageList = {}
    table.insert(self.epImageList, GetImage(self.EP1))
    table.insert(self.epImageList, GetImage(self.EP2))
    table.insert(self.epImageList, GetImage(self.EP3))
    table.insert(self.epImageList, GetImage(self.EP4))

    self.itemSize = self.PetItem.sizeDelta
    self.itemList = {}

    local data = self.model:GetShowList()
    local count = #data
    local fullH = count * self.itemSize.y
    local baseY = (fullH - self.itemSize.y) / 2 - 4

    SetSizeDeltaY(self.Content, fullH)

    self:CreateItems(data, baseY)
    self.PetItem.gameObject:SetActive(false)

    self.skillView:AddItem(self.SkillIcon1, self.Lock1, self.SkillLevel1)
    self.skillView:AddItem(self.SkillIcon2, self.Lock2, self.SkillLevel2)
    self.skillView:AddItem(self.SkillIcon3, self.Lock3, self.SkillLevel3)
end

function PetPanel:AddEvent()
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(PetEvent.Pet_Model_BattlePetDataEvent, handler(self, self.OnBattlePetData))
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(PetEvent.Pet_Model_ChangeBattlePetEvent, handler(self, self.OnChangeBattlePet))

    ---及时刷新红点用
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(PetEvent.Pet_Model_TrainBattlePetEvent, handler(self, self.OnTrainBattlePet))
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(PetEvent.Pet_Model_CrossBattlePetEvent, handler(self, self.OnCrossBattlePet))
    -- self.modelEvents[#self.modelEvents + 1] =
    --     self.model:AddListener(PetEvent.Pet_Model_EvolutionBattlePetEvent, handler(self, self.OnEvolutionBattlePet))
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(PetEvent.Pet_Model_ComposePetEvent, handler(self, self.OnComposePet))

    local function call_back()
        self:RefreshPagRedPoint()
        self:RefreshBtnRedPoint()
    end
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(PetEvent.Pet_Model_BackEvolutionBattlePetEvent, call_back)
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(PetEvent.Pet_Model_DeleteBagPetEvent, call_back)
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(PetEvent.Pet_Model_AddBagPetEvent, call_back)
    
  

    local function call_back(  )
        local flag = self.pet_equip_model:CheckStrenOrUporderReddotByTargetPet()
        self:SetIndexRedDotParam(5, flag)
    end
    self.role_events[#self.role_events + 1] = RoleInfoModel:GetInstance():GetMainRoleData():BindData("PetEquipExp", call_back)


    local function call_back()
        self:RefreshPagRedPoint()
        self:RefreshBtnRedPoint()
    end
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)

    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(GoodsEvent.GoodsDetail, handler(self, self.OnGetItemDetail))

    local function call_back()
        ----lua_panelMgr:GetPanelOrCreate(PetReplacePanel):Open()
        lua_panelMgr:GetPanelOrCreate(PetBagPanel):Open() --(self.CurrPetData.Config.order)
        --PetController:GetInstance():RequestTrainPet(self.CurrPetData.Config.order)
    end
    AddClickEvent(self.ChangeBtn.gameObject, call_back)

    local function call_back()
        if self.scrollView and self.scrollView.verticalNormalizedPosition > 0 then
            self.scrollView.verticalNormalizedPosition = self.scrollView.verticalNormalizedPosition - 0.2
        end
    end
    AddClickEvent(self.DownArrow.gameObject, call_back)

    local function call_back()
        local UITransform = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.UI)
        local tipView = PetGetWayView(UITransform)
        tipView:SetData(self.CurrPetData.Config.id)
    end
    AddButtonEvent(self.GetWay.gameObject, call_back)

    AddButtonEvent(self.BattleBtn.gameObject, handler(self, self.OnGoBattle))

    local function call_back()
        local itemCfg = Config.db_item[self.CurrPetData.Config.id]
        local jumpTab = String2Table(itemCfg.guide)
        if (#jumpTab < 1) then
            return
        end
        OpenLink(unpack(jumpTab))
    end
    AddButtonEvent(self.RenewalBtn.gameObject, call_back)

    --宠物装备相关事件
    self.pet_equip_model_events[#self.pet_equip_model_events + 1] = PetEquipModel.GetInstance():AddListener(PetEquipEvent.HandlePetEquips,handler(self, self.UpdatePetEquip))
   
    --宠物装备相关红点页签刷新
    local function call_back(pet_id,equips)
        --当前宠物穿戴的装备变化后刷新下装备页签红点
        if pet_id ~= self.pet_equip_model.cur_pet_data.Config.order then
            return
        end

        self:CheckTab5Reddot(self.CurrPetData.Config)
      
    end
    self.pet_equip_model_events[#self.pet_equip_model_events + 1] = self.pet_equip_model:AddListener(PetEquipEvent.HandlePetEquips, call_back)

    local function call_back(bag_id)
        --宠物装备背包变化后刷新下装备页签红点
        if bag_id ~= BagModel.PetEquip then
            return
        end
     
        self:CheckTab5Reddot(self.CurrPetData.Config)

    end
    self.bag_model_events[#self.bag_model_events + 1] = self.bag_model:AddListener(BagEvent.LoadItemByBagId,call_back )
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(BagEvent.AddItems,call_back)
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(GoodsEvent.DelItems,call_back)
end

---训练宠物成功
function PetPanel:OnTrainBattlePet()
    self:RefreshPagRedPoint()

    local efft = UIEffect(self.EffectParent, 10117, false)
    local cfg = { scale = 1.25 }
    efft:SetConfig(cfg)
end

---突破宠物成功
function PetPanel:OnCrossBattlePet()
    self:RefreshPagRedPoint()

    local efft = UIEffect(self.EffectParent, 10116, false)
    local cfg = { scale = 1.25 }
    efft:SetConfig(cfg)
end

-- ---觉醒成功
-- function PetPanel:OnEvolutionBattlePet()
--     self:RefreshPagRedPoint()
--     local efft = UIEffect(self.EffectParent, 10121, false)
--     local cfg = {scale = 1.25}
--     efft:SetConfig(cfg)
-- end
---融合成功
function PetPanel:OnComposePet(id, success)
    if success then
        local efft = UIEffect(self.EffectParent, 10114, false)
        local cfg = { scale = 1.25 }
        efft:SetConfig(cfg)
    end
    local hasCompose = self.model:HasCompose()
    self:SetIndexRedDotParam(4, hasCompose)
end

function PetPanel:OnGetItemDetail(pItem)
    if (not self.CurrPetData.IsActive) and self.CurrPetData.HasInBag and pItem.uid == self.CurrPetData.BagPet.uid then
        self.CurrPetData.Data = pItem
        self:RefreshView()
    end
end

---宠物出战
function PetPanel:OnGoBattle()
    local uid = 0
    if (self.CurrPetData) then
        if (not self.CurrPetData.IsActive and self.CurrPetData.HasInBag) then
            local p = self.model:GetBestBagPet(self.CurrPetData.Config.order)
            uid = p.uid
        else

            local isOverdue = self.CurrPetData:CheckOverdue()

            if (isOverdue) then
                local p = self.model:GetBestBagPet(self.CurrPetData.Config.order)
                if p then
                    uid = p.uid
                end
            elseif not self.CurrPetData.IsFighting and self.CurrPetData.Data then
                uid = self.CurrPetData.Data.uid
            end
        end
    end

    if uid > 0 then
        PetController:GetInstance():RequestPetSet(uid, 1)
        PetModel:SaveRequestPetSetValue(1)
    end
end

---刷新全部红点
function PetPanel:RefreshRedPoint()
    for _, v in ipairs(self.itemList) do
        v:RefreshPoint()
    end

    self:RefreshPagRedPoint()
end

---刷新页签红点
function PetPanel:RefreshPagRedPoint()
    local isOverdue = self.CurrPetData:CheckOverdue()

    if (self.CurrPetData == nil or not self.CurrPetData.IsActive or isOverdue) then
        self:SetIndexRedDotParam(2, false)
        self:SetIndexRedDotParam(3, false)
        return
    end

    local _, hasTrain, hasCross = PetModel:GetInstance():HasTrainOrCross(self.CurrPetData)
    local hasEvolution = PetModel:GetInstance():HasEvolution(self.CurrPetData)

    self:SetIndexRedDotParam(2, hasTrain or hasCross)
    self:SetIndexRedDotParam(3, hasEvolution)
    local hasCompose = self.model:HasCompose()
    self:SetIndexRedDotParam(4, hasCompose)
end

---按钮上红点
function PetPanel:RefreshBtnRedPoint()
    if (not self.CurrPetData.IsActive) then
        local isHadInBag = self.model:HasBagPet(self.CurrPetData.Config.order)
        local HasRefining = false
        if not isHadInBag then
            HasRefining = self.model:HasRefining()
        end

        self:SetRedPoint(self.BattleBtn, isHadInBag, 30, 32)
        self:SetRedPoint(self.ChangeBtn, isHadInBag or HasRefining, 32, 22)
    else
        local hasBetter = self.model:HasBetter(self.CurrPetData.Config.order, self.CurrPetData.Data.score)
        self:SetRedPoint(self.BattleBtn, false, 30, 32)
        local HasRefining = false
        if not hasBetter then
            HasRefining = self.model:HasRefining()
        end
        self:SetRedPoint(self.ChangeBtn, hasBetter or HasRefining, 32, 22)
    end
end

function PetPanel:SetRedPoint(key, isShow, x, y)
    self.redPoints = self.redPoints or {}

    if not self.redPoints[key] then
        self.redPoints[key] = RedDot(key, nil, RedDot.RedDotType.Nor)
        self.redPoints[key]:SetPosition(x, y)
    end

    self.redPoints[key]:SetRedDotParam(isShow)
end

function PetPanel:OnBattlePetData()
    newPetUid = nil
    local data = self.model:GetShowList()
    local currOrder = -1

    if (self.CurrPetData) then
        currOrder = self.CurrPetData.Config.order
    end

    local select_index = 1
    for i, v in ipairs(data) do
        ---如果只更新一个，则传过来UID，做为唯一刷新标识，否则全部都重刷
        if (newPetUid) then
            if (v.Data and v.Data.uid == newPetUid) then
                self.itemList[i]:SetData(v)
            end
        else
            self.itemList[i]:SetData(v)
        end

        if (v.Config.order == currOrder) then
            self.CurrPetData = v
            self:RefreshView()
            self:ShowPetModle()
            select_index = i
            --self.model:Brocast(PetEvent.Pet_Model_SelectPetEvent, v)
        end
    end
    self:SelectItem(self.itemList[select_index])
end

function PetPanel:OnChangeBattlePet(petData, value, fightOrder)
    for _, v in ipairs(self.itemList) do
        v:RefreshState(fightOrder)
    end

    if (value == 0) then
        Notify.ShowText(string.format(ConfigLanguage.Pet.AssistSuccess))
    end

    if (value == 1) then
        Notify.ShowText(string.format(ConfigLanguage.Pet.BattleSuccess))
    end

    --self:RefreshPagRedPoint()
end

function PetPanel:RefreshView()

    self:StopSchedule()

    if self.CurrPetData.Config.type == 2 then
        self.nameText.text = string.format("%s·%s", self.CurrPetData.Config.name,ConfigLanguage.Pet.ActivityType)
    else
        self.nameText.text = string.format("%s·T%s", self.CurrPetData.Config.name,self.CurrPetData.Config.order_show)
    end

    lua_resMgr:SetImageTexture(
            self,
            self.qualityNameImage,
            self.imageAb,
            "Q_Name_" .. self.CurrPetData.Config.quality,
            false
    )

    self.countDownText.text = ""
    SetVisible(self.RenewalBtn, false)

    if (self.CurrPetData.Data) then
        self:HideGetwayText()
        self:SetEvolutionPoint(self.CurrPetData.Config.evolution, self.CurrPetData.Data.extra)
        local config = self.CurrPetData.Config
        local extra_power = String2Table(Config.db_pet_evolution[config.order .. "@" .. self.CurrPetData.Data.extra].fight_attr)[1][2]
        --self.powerValueText.text = tostring(self.CurrPetData.Data.pet.power)

        ---是否过期
        local isOverdue = self.CurrPetData:CheckOverdue()

        ---上阵的宠物
        if (self.CurrPetData.IsActive) then
            self.stateImage.enabled = true
            self.getwayText.text = ""

            if (isOverdue) then

                local inBagPet = self.model:GetBestBagPet(self.CurrPetData.Config.order)

                if (inBagPet) then
                    SetVisible(self.BattleBtn, true)
                    SetVisible(self.RenewalBtn, false)
                else
                    SetVisible(self.BattleBtn, false)
                    SetVisible(self.RenewalBtn, true)
                end

                SetVisible(self.GetWay, false)

                lua_resMgr:SetImageTexture(self, self.stateImage, self.imageAb, "State_Overdue")
            else
                SetVisible(self.BattleBtn, not self.CurrPetData.IsFighting)
                SetVisible(self.GetWay, false)
                --SetVisible(self.RenewalBtn, false)
                lua_resMgr:SetImageTexture(
                        self,
                        self.stateImage,
                        self.imageAb,
                        self.CurrPetData.IsFighting and "State_Battle" or "State_Assist"
                )

                self:ShowCountDown()
            end
        else
            ---背包中的宠物
            SetVisible(self.BattleBtn, not isOverdue)
            SetVisible(self.GetWay, false)
            self.stateImage.enabled = false
            self.getwayText.text = ""
        end
    else
        self:SetEvolutionPoint(self.CurrPetData.Config.evolution, 0)

        if (self.CurrPetData.HasInBag) then
            SetVisible(self.BattleBtn, true)
            SetVisible(self.GetWay, false)
            self.stateImage.enabled = false
            self:HideGetwayText()
        else
            SetVisible(self.BattleBtn, false)
            SetVisible(self.GetWay, true)
            lua_resMgr:SetImageTexture(self, self.stateImage, self.imageAb, "State_Inactive")
            self.stateImage.enabled = true
            self:GetGetwayText()
        end
        --self.powerValueText.text = "wwwwwww"
    end
    self:RefreshBtnRedPoint()
    self.skillView:RefreshView(self.CurrPetData)

    if self.currentIndex == 5 then
        --刷新宠物装备
        PetController.GetInstance():RequestPetEquips(self.CurrPetData.Config.order)
    end
  
end

function PetPanel:ShowCountDown()
    if (self.CurrPetData.Data.etime == 0) then
        return
    end

    self:StartCountDown()
    self.scheduleId = GlobalSchedule.StartFun(handler(self, self.StartCountDown), 1, -1)
end

function PetPanel:StopSchedule()
    if self.scheduleId then
        GlobalSchedule:Stop(self.scheduleId)
        self.scheduleId = nil
    end
end

function PetPanel:StartCountDown()
    local serverTime = TimeManager.Instance:GetServerTime()
    local endTime = self.CurrPetData.Data.etime
    local timeTab = TimeManager:GetLastTimeData(serverTime, endTime)
    local hourStr = ""
    local minStr = ""
    local secStr = ""

    if timeTab then
        hourStr = string.format("%02d", timeTab.hour or 0)
        minStr = string.format("%02d", timeTab.min or 0)
        secStr = string.format("%02d", timeTab.sec or 0)
        self.countDownText.text = string.format("%s:%s:%s", hourStr, minStr, secStr)
    else
        self:StopSchedule()
        self:RefreshView()
    end
end

function PetPanel:SetEvolutionPoint(count, point)
    for i, v in ipairs(self.epImageList) do
        if (i <= point) then
            SetVisible(self["EP" .. i], true)
            lua_resMgr:SetImageTexture(self, v, self.imageAb, "EvolutionPoint")
        elseif (i <= count) then
            SetVisible(self["EP" .. i], true)
            lua_resMgr:SetImageTexture(self, v, self.imageAb, "EvolutionPoint_Gray")
        else
            SetVisible(self["EP" .. i], false)
        end
    end

    self.noEvolutionImg.enabled = count <= 0
end

function PetPanel:SelectItem(item)
    SetParent(self.Selector, item.transform)
    SetAnchoredPosition(self.Selector, 0, 0)
    self:SetCurrPet(item.data)
    --
    --local v = item.data:CheckOverdue()
    --logError(tostring(v))



end

function PetPanel:CreateItems(dataList, baseY)
    for i = 1, #dataList, 1 do
        local tempItem = PetItemView(newObject(self.PetItem), dataList[i])
        tempItem:SetCallBack(handler(self, self.SelectItem))
        tempItem.transform:SetParent(self.Content)
        SetLocalScale(tempItem.transform, 1, 1, 1)
        tempItem.transform.anchoredPosition3D = Vector3(0, baseY - (i - 1) * self.itemSize.y, 0)
        self.itemList[i] = tempItem
    end
end

function PetPanel:RelocationForCompose()
    self.isRelocation = true

    self:StopAction()
    local moveXPos = (ScreenWidth * -0.5) - 120

    SetVisible(self.OtherInfo, false)
    SetVisible(self.BaseInfo, false)
    SetVisible(self.Model, false)

    self.location1Action = cc.MoveTo(0.5, moveXPos, -25)
    self.location1Action = cc.EaseQuadraticActionOut(self.location1Action)

    --self.location2Action = cc.MoveTo(0.5, 154, 67)
    --self.location2Action = cc.EaseQuadraticActionOut(self.location2Action)
    cc.ActionManager:GetInstance():addAction(self.location1Action, self.Left)
    --cc.ActionManager:GetInstance():addAction(self.location2Action, self.BaseInfo)

    
end

function PetPanel:ResetLocation()
    if (self.isRelocation) then
        self.isRelocation = nil
        self:StopAction()

        SetVisible(self.OtherInfo, true)
        SetVisible(self.BaseInfo, true)
        SetVisible(self.Model, true)

        self.location1Action = cc.MoveTo(0.5, self.left_old_x, self.left_old_y)
        self.location1Action = cc.EaseQuadraticActionOut(self.location1Action)

        --self.location2Action = cc.MoveTo(0.5, 64, 67)
        --self.location2Action = cc.EaseQuadraticActionOut(self.location2Action)
        cc.ActionManager:GetInstance():addAction(self.location1Action, self.Left)
        --cc.ActionManager:GetInstance():addAction(self.location2Action, self.BaseInfo)
    end
end

function PetPanel:StopAction()
    if self.location1Action then
        cc.ActionManager:GetInstance():removeAction(self.location1Action)
        self.location1Action = nil
    end

    --if self.location2Action then
    --    cc.ActionManager:GetInstance():removeAction(self.location2Action)
    --    self.location2Action = nil
    --end
end

function PetPanel:SwitchCallBack(index, toggle_id, update_toggle)
    if (self.currentIndex == index) then
        return
    else
        self:SwitchView(index)
    end
end

function PetPanel:SwitchView(index)
    self.currentIndex = index
    if self.currentView then
        --self.currentView:SetVisible(false)
        self.currentView = nil
    end

    if (self.currentIndex == 4) then
        self:RelocationForCompose()
    else
        self:ResetLocation()
    end

    --宠物装备界面 隐藏部分UI元素
    if self.currentIndex == 5 then
        SetVisible(self.parent,false)
        SetVisible(self.equips,true)

        --请求刷新宠物装备
        --PetController.GetInstance():RequestPetEquips(self.CurrPetData.Config.order)
    else
        SetVisible(self.parent,true)
        SetVisible(self.equips,false)
    end

    if self.panels[self.currentIndex] then
        self.currentView = self.panels[self.currentIndex]
    else
        local p
        if self.currentIndex == 2 then
            p = PetTrainPanel(self.SubPanel)
        elseif self.currentIndex == 3 then
            p = PetEvolutionPanel(self.SubPanel)
        elseif self.currentIndex == 4 then
            p = PetComposePanel(self.composeparent)
        elseif self.currentIndex == 5 then
            p = PetEquipBagPanel(self.petequipbagparent)
        else
            p = PetBaseInfoPanel(self.SubPanel)
        end

        self.panels[self.currentIndex] = p
        self.currentView = p
    end

    if self.currentView then
        if (self.CurrPetData) then
            self.currentView:SetData(self.CurrPetData)
        end
        self:PopUpChild(self.currentView)
    end
end

function PetPanel:HideGetwayText()
    self.getwayText.text = ""
    if (self.levelItem) then
        SetVisible(self.levelItem.transform, false)
    end
end

function PetPanel:GetGetwayText()

    local condition = {}
    if self.CurrPetData.Config.wake > 0 then
        table.insert(condition, string.format("%d Awakening", self.CurrPetData.Config.wake))
    end

    if self.CurrPetData.Config.level > 1 then
        table.insert(condition, "Lv.%s")
    end

    if (#condition > 0) then
        local formatStr ="Unlock at " .. table.concat(condition, "")
        if (self.CurrPetData.Config.level > 1) then
            if (self.levelItem == nil) then
                self.levelItem = LevelShowItem(self.GetWayText)
            end
            SetVisible(self.levelItem.transform, true)
            self.getwayText.text = ""
            self.levelItem:SetData(28, self.CurrPetData.Config.level, "ffffff", "866237", formatStr)
        else
            self.getwayText.text = formatStr
            if (self.levelItem) then
                SetVisible(self.levelItem.transform, false)
            end
        end
    else
        self.getwayText.text = "None"
        if (self.levelItem) then
            SetVisible(self.levelItem.transform, false)
        end
    end
end


--刷新宠物装备
function PetPanel:UpdatePetEquip()
    if not self.pet_equip_items then
        self.pet_equip_items = {}
    end

    for i=8001,8004 do
        self:UpdatePetEquipBySlot(nil,i)
    end
end

--根据格子刷新宠物装备
function PetPanel:UpdatePetEquipBySlot(pet_id,slot)

    local item = PetEquipModel.GetInstance().cur_pet_equips[slot]
    self.pet_equip_items[slot] = self.pet_equip_items[slot] or PetEquipItem(self["equip_"..slot])
    local data = {}
    data.item = item
    self.pet_equip_items[slot]:SetData(data)
end

--检查宠物装备页签的红点
function PetPanel:CheckTab5Reddot(pet_config)
    local flag1 = self.pet_equip_model:CheckStrenOrUporderReddotByTargetPet(pet_config.order)
    local flag2 = self.pet_equip_model:CheckCanPutonReddotByTarget(pet_config.quality)
    --logError("宠物装备页签红点检查,pet_id-"..self.CurrPetData.Config.order)
    self:SetIndexRedDotParam(5, flag1 or flag2)
    return  flag1 or flag2
end