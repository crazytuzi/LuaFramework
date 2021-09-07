-- @author hze
-- @date #2019/05/15#
-- @宠物内丹学习界面

PetRuneStudyPanel = PetRuneStudyPanel or BaseClass(BasePanel)

function PetRuneStudyPanel:__init(model)
    self.resList = {
        {file = AssetConfig.petrunestudypanel, type = AssetType.Main},
    }

    self.model = model
    self.name = "PetRuneStudyPanel"

    self.itemList = {}

    
    self.on_item_update = function() self:OnUpdateItem() end
    

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function PetRuneStudyPanel:__delete()
    self.OnHideEvent:Fire()

    if self.studyButton ~= nil then 
        self.studyButton:DeleteMe()
    end
    self.studyButton = nil

    if self.layout ~= nil then 
        self.layout:DeleteMe()
    end
    self.layout = nil

    if self.runeShowLoader ~= nil then 
        self.runeShowLoader:DeleteMe()
    end
    self.runeShowLoader = nil

    if self.itemSlot ~= nil then 
        self.itemSlot:DeleteMe()
    end
    self.itemSlot = nil

    if self.itemList ~= nil then 
        for k,v in ipairs(self.itemList) do
            if v.iconloader ~= nil then 
                v.iconloader:DeleteMe()
            end
        end
    end
end

function PetRuneStudyPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.petrunestudypanel))
    if self.model.window ~= nil and not BaseUtils.isnull(self.model.window.gameObject) then
        UIUtils.AddUIChild(self.model.window.gameObject, self.gameObject)
    else
        UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    end

    self.gameObject.name = self.name
    self.transform = self.gameObject.transform

    self.transform:GetComponent(RectTransform).localPosition = Vector3(0,0,-500)

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self.model:ClosePetRuneStudyPanel() end)
    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self.model:ClosePetRuneStudyPanel() end)

    self.itemContainer = self.transform:Find("Main/RuneBar/HeadContainer")
    self.runeItem = self.transform:Find("Main/RuneBar/RuneItem").gameObject
    self.runeItem:SetActive(false)

    self.right = self.transform:Find("Main/Right")
    self.runeShowItem = self.right:Find("RuneItem")
    self.runeShowTxt = self.runeShowItem:Find("NameText"):GetComponent(Text)
    self.runeShowIcon = self.runeShowItem:Find("IconBg/Icon"):GetComponent(Image)
    self.runeShowLoader = SingleIconLoader.New(self.runeShowIcon.gameObject)
    self.descTxt = self.right:Find("DescText"):GetComponent(Text)

    self.costItem = self.right:Find("CostItem")
    self.costSlotItem = self.costItem:Find("SlotItem")
    self.costSlotItemNumTxt = self.costItem:Find("TxtBg/Text"):GetComponent(Text)
    self.costItem:Find("TxtBg").gameObject:SetActive(false)

    self.costMoney = self.right:Find("CostMoney")
    self.costMoneyIcon =  self.costMoney:Find("Icon"):GetComponent(Image)
    self.costMoneyTxt =  self.costMoney:Find("DescText"):GetComponent(Text)

    self.itemSlot = ItemSlot.New()
    UIUtils.AddUIChild(self.costSlotItem.gameObject, self.itemSlot.gameObject)

    self.studyButton = BuyButton.New(self.right:Find("StudyButton"), TI18N("学习"), false)
    self.studyButton:Set_btn_img("DefaultButton3")
    self.studyButton.key = "PetRuneStudyButton"
    self.studyButton.protoId = 10575
    self.studyButton:Show()

    self._OnClickBtn = function() 
        if self.rune_id == nil then 
            NoticeManager.Instance:FloatTipsByString(TI18N("请在左侧选择想要学习的内丹"))
        else
            PetManager.Instance:Send10575(self.model.cur_petdata.id, self.rune_index, self.rune_id)  
        end
    end

    self._OnPricesBack = function(prices) 
        -- BaseUtils.dump(prices, "prices")

        local data = nil
        for _, value in pairs(prices) do
            data = value
        end
        if data == nil then
            self.costItem.anchoredPosition = Vector2(0, -77.2)
            self.costMoney.gameObject:SetActive(false)
            return
        end
        self.costItem.anchoredPosition = Vector2(0, -54)
    
        local allprice = data.allprice
        local price_str = ""
        if allprice >= 0 then
            price_str = string.format("<color='%s'>%s</color>", ColorHelper.color[1], allprice)
        else
            price_str = string.format("<color='%s'>%s</color>", ColorHelper.color[6], - allprice)
        end
        self.costMoneyTxt.text = price_str
        self.costMoneyIcon:GetComponent(Image).sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[data.assets])
    
        self.costMoney.gameObject:SetActive(true)
    end

    self.studyButton:Layout({}, self._OnClickBtn, self._OnPricesBack, {antofreeze = false})

    self.layout = LuaBoxLayout.New(self.itemContainer, {axis = BoxLayoutAxis.Y, cspacing = 0, border = 5})
end

function PetRuneStudyPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function PetRuneStudyPanel:OnOpen()
    self:RemoveListeners()

    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.on_item_update)

    self.type = self.openArgs.type
    self.rune_index = self.openArgs.rune_index

    self.data = self.model:GetQualityRuneData(self.type)
    --推荐列表  
    local recommend_data = self.model:GetRecommendRuneDataByPet()
    for _,v in ipairs(self.data) do
        if table.containValue(recommend_data, v.id) then 
            v.recommend = 1 
        else
            v.recommend = 0
        end

        if self.model:JudgeStudyStatus(v.id) then 
            v.study = 1
        else
            v.study = 0
        end
    end
    table.sort( self.data, function(a,b) 
            if a.study ~= b.study then 
                return a.study > b.study
            end

            if a.recommend ~= b.recommend then 
                return a.recommend > b.recommend 
            end
            return a.id < b.id
        end)
        
    -- BaseUtils.dump(self.data,"内丹学习数据")
    for i, v in ipairs(self.data) do
        local item = self.itemList[i] or self:CreateItem()
        self.itemList[i] = item
        self:SetItemData(item, v)
        self.layout:AddCell(item.gameObject)
    end
end

function PetRuneStudyPanel:OnHide()
    self:RemoveListeners()
end

function PetRuneStudyPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.on_item_update)
end

function PetRuneStudyPanel:CreateItem()
    local item = {}
    item["gameObject"] = GameObject.Instantiate(self.runeItem)
    item["transform"] = item.gameObject.transform
    item["btn"] = item.transform:GetComponent(Button)
    item["select"] = item.transform:Find("Select").gameObject
    item["nameTxt"] = item.transform:Find("NameText"):GetComponent(Text)
    item["iconImg"] = item.transform:Find("IconBg/Icon")
    item["iconloader"] = SingleIconLoader.New(item.iconImg.gameObject)
    item["using"] = item.transform:Find("Using").gameObject
    item["recommendTxt"] = item.transform:Find("Text").gameObject
    return item
end 

function PetRuneStudyPanel:SetItemData(item, data)
    item.btn.onClick:RemoveAllListeners()
    item.btn.onClick:AddListener(function() self:ClickItemBtn(item, data) end)
    item.select:SetActive(false)
    item.nameTxt.text = data.name
    item.iconloader:SetSprite(SingleIconType.SkillIcon, DataSkill.data_petSkill[BaseUtils.Key(data.skill_id, "1")].icon)
    -- item.iconloader:SetSprite(SingleIconType.Item, DataItem.data_get[data.id].icon)
    item.using:SetActive(self.model:JudgeStudyStatus(data.id))
    item.recommendTxt:SetActive(data.recommend == 1)
end 

--判断是否已学习该内丹
function PetRuneStudyPanel:JudgeStudyStatus(dat)
    if self.model.cur_petdata == nil then return false end
    local study_rune_data = BaseUtils.copytab(self.model.cur_petdata.pet_rune)
    for _,v in ipairs(study_rune_data) do
        if dat.id == v.rune_id then 
            return true
        end
    end
    return false
end

function PetRuneStudyPanel:ClickItemBtn(item, data)
    -- print("点击Item:"..data)
    -- BaseUtils.dump(data,"选中的内丹效果")
    if self.lastSelectedItem == item then return end
    if self.lastSelectedItem ~= nil then 
        self.lastSelectedItem.select:SetActive(false)
    end
    item.select:SetActive(true)
    self.lastSelectedItem = item
    self.rune_id = data.id
    self.runeShowTxt.text = data.name
    
    
    local skillData = DataSkill.data_petSkill[BaseUtils.Key(data.skill_id, "1")]
    self.runeShowIcon.gameObject:SetActive(true)
    self.runeShowLoader:SetSprite(SingleIconType.SkillIcon, skillData.icon)
    self.descTxt.text = skillData.desc

    --消耗物
    local itemData = DataItem.data_get[data.id]

    local item_data = ItemData.New()
    item_data:SetBase(itemData)
    self.itemSlot:SetAll(item_data)
    
    

    self.cur_cost_id = data.id
    self:OnUpdateItem()
end

function PetRuneStudyPanel:OnUpdateItem()
    if self.cur_cost_id == nil then return end

    self.itemSlot:SetNum(BackpackManager.Instance:GetItemCount(self.cur_cost_id), 1)
    self.studyButton:Layout({[self.cur_cost_id] = {need = 1}}, self._OnClickBtn, self._OnPricesBack , {antofreeze = false})
end