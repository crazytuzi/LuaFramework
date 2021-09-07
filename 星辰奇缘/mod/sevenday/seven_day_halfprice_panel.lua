-- @author 黄耀聪
-- @date 2016年7月13日

SevendayHalfPrice = SevendayHalfPrice or BaseClass(BasePanel)

function SevendayHalfPrice:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "SevendayHalfPrice"
    self.mgr = SevendayManager.Instance

    self.resList = {
        {file = AssetConfig.sevenday_halfprice, type = AssetType.Main},
        {file = AssetConfig.masquerade_textures, type = AssetType.Dep},
        {file = AssetConfig.totembg, type = AssetType.Dep},
        {file = AssetConfig.i18n_sevenday_desc, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }

    self.updateListener = function() self:Update() end
    self.slotItemIList = {}
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.updateNumListener = function()
        if self.hasInit == false then
            return
        end
        local cfgData = DataGoal.data_discount[self.openArgs]
        local leftNum = cfgData.total_count
        for i=1,#self.model.halfpriceData.discount_info do
            local tempData = self.model.halfpriceData.discount_info[i]
            if cfgData.id == tempData.id then
                leftNum = cfgData.total_count - tempData.count
            end
        end
        leftNum = leftNum < 0 and 0 or leftNum
        self.Desc_I18N.text = string.format( TI18N("今日全服限购次数：%s（剩余：<color='#00ff00'>%s</color>)"), cfgData.total_count, math.ceil(leftNum*0.8))
    end
    self.effTimerId = nil
    self.itemEffectList = {}
    self.hasInit = false
end

function SevendayHalfPrice:__delete()
    if self.itemEffectList ~= nil then
        for _,v in pairs(self.itemEffectList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemEffectList = nil
    end
    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end
    self.hasInit = false
    for i=1,#self.slotItemIList do
        local item = self.slotItemIList[i]
        if item.slot ~= nil then
            item.slot:DeleteMe()
        end
    end
    self.OnHideEvent:Fire()
    if self.giftPreview ~= nil then
        self.giftPreview:DeleteMe()
        self.giftPreview = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function SevendayHalfPrice:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.sevenday_halfprice))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    local obj = GameObject.Instantiate(self:GetPrefab(AssetConfig.i18n_sevenday_desc))
    UIUtils.AddBigbg(t:Find("Bg/Title"), obj)

    self.MaskCon = t:Find("Bg/MaskCon")
    self.ScrollCon = t:Find("Bg/MaskCon/ScrollCon")
    self.Container = t:Find("Bg/MaskCon/ScrollCon/Container")
    self.SlotCon = t:Find("Bg/MaskCon/ScrollCon/Container/SlotCon").gameObject
    self.SlotCon:SetActive(false)

    self.originText = t:Find("Bg/Origin/PriceBg/Panel"):GetComponent(Text)
    self.currentText = t:Find("Bg/Current/PriceBg/Panel"):GetComponent(Text)
    self.originIcon = t:Find("Bg/Origin/PriceBg/Image"):GetComponent(Image)
    self.currentIcon = t:Find("Bg/Current/PriceBg/Image"):GetComponent(Image)

    self.button = t:Find("Bg/Button"):GetComponent(Button)
    self.itemContainer = t:Find("Bg/ItemBg")
    self.nameText = t:Find("Bg/Name"):GetComponent(Text)
    -- self.itemBtn = t:Find("Bg/Image"):GetComponent(Button)
    self.Desc_I18N = t:Find("Bg/Desc_I18N"):GetComponent(Text)

    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end
    self.effTimerId = LuaTimer.Add(1000, 3000, function()
       self.button.gameObject.transform.localScale = Vector3(1.2,1.1,1)
       Tween.Instance:Scale(self.button.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
    end)

    -- self.itemBtn.onClick:AddListener(function() self:OnClick() end)
    self.itemContainer:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.totembg, "ToTemBg")
    self.hasInit = true
end

function SevendayHalfPrice:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SevendayHalfPrice:ShowEffect(id, transform, scale, position, time)
    local fun = function(effectView)
        local effectObject = effectView.gameObject
        effectObject.transform:SetParent(transform)
        effectObject.name = "Effect"
        effectObject.transform.localScale = scale
        effectObject.transform.localPosition = position
        effectObject.transform.localRotation = Quaternion.identity

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
        effectObject:SetActive(true)
    end
    return BaseEffectView.New({effectId = id, time = time, callback = fun})
end

function SevendayHalfPrice:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.seven_day_halfprice_upgrade, self.updateNumListener)
    self.mgr.onUpdateDiscount:AddListener(self.updateListener)

    local data = DataGoal.data_discount[self.openArgs]

    self.originText.text = tostring(data.show_price)
    self.currentText.text = tostring(data.price)
    self.originIcon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[data.assets_type])
    self.currentIcon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[data.assets_type])
    self.nameText.text = data.name

    self.button.onClick:RemoveAllListeners()
    self.button.onClick:AddListener(function() self:OnBuy() end)

    if self.itemEffectList ~= nil then
        for _,v in pairs(self.itemEffectList) do
            if v ~= nil and v.gameObject ~= nil and not BaseUtils.is_null(v.gameObject) then
                v.gameObject:SetActive(false)
            end
        end
    end
    for i=1, #self.slotItemIList do
        local item = self.slotItemIList[i]
        item.gameObject:SetActive(false)
    end
    for i=1,#data.item_reward do
        local item = self.slotItemIList[i]
        if item == nil then
            item = self:CreateSlotItem(i)
            table.insert(self.slotItemIList, item)
        end
        local basedata = DataItem.data_get[data.item_reward[i][1]]
        self:SetSlotData(item.slot, basedata)
        item.slot:SetNum(data.item_reward[i][2])
        item.TxtName.text = ColorHelper.color_item_name(basedata.quality , basedata.name)
        item.gameObject:SetActive(true)

        --检查下是否需要显示特效
        local showEffect = false
        for j=1, #data.item_effect do
            if data.item_effect[j][1] == data.item_reward[i][1] then
                showEffect = true
            end
        end
        if showEffect then
            if self.itemEffectList[i] == nil then
                self.itemEffectList[i] = self:ShowEffect(20223,item.transform,Vector3(1, 1, 1), Vector3(0, 0, 0))
            end
            local effectObj = self.itemEffectList[i]
            if effectObj ~= nil and effectObj.gameObject ~= nil and not BaseUtils.is_null(effectObj.gameObject) then
                effectObj.gameObject:SetActive(true)
            end
        end
    end
    self.Desc_I18N.text = string.format( TI18N("今日全服限购次数：%s（剩余：<color='#00ff00'>%s</color>)"), data.total_count, data.total_count)
    SevendayManager.Instance:send14107()
    self:Update()
end

--获取一个itemSlot
function SevendayHalfPrice:CreateSlotItem(index)
    local item = {}
    item.index = index
    item.gameObject = GameObject.Instantiate(self.SlotCon)
    item.transform = item.gameObject.transform
    item.transform:SetParent(self.Container)
    item.transform.localScale = Vector3.one
    item.TxtName = item.transform:Find("TxtName"):GetComponent(Text)
    item.slot = self:CreateSlot(item.gameObject)
    -- item.transform:GetComponent(RectTransform).anchoredPosition = Vector2((index - 1)*120, -8)
    return item
end

function SevendayHalfPrice:CreateSlot(slot_con)
    local stone_slot = ItemSlot.New()
    stone_slot.gameObject.transform:SetParent(slot_con.transform)
    stone_slot.gameObject.transform.localScale = Vector3.one
    stone_slot.gameObject.transform.localPosition = Vector3.zero
    stone_slot.gameObject.transform.localRotation = Quaternion.identity
    local rect = stone_slot.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 2)
    rect.localScale = Vector3.one
    return stone_slot
end

--对slot设置数据
function SevendayHalfPrice:SetSlotData(slot, data, _nobutton)
    if slot == nil then
        return
    end
    local cell = ItemData.New()
    cell:SetBase(data)
    if nobutton == nil then
        slot:SetAll(cell, {_nobutton = true})
    else
        slot:SetAll(cell, {nobutton = _nobutton})
    end
end

function SevendayHalfPrice:OnHide()
    self:RemoveListeners()
end

function SevendayHalfPrice:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.seven_day_halfprice_upgrade, self.updateNumListener)
    self.mgr.onUpdateDiscount:RemoveListener(self.updateListener)
end

function SevendayHalfPrice:OnBuy()
    local confirmData = NoticeConfirmData.New()
    local data = DataGoal.data_discount[self.openArgs]
    confirmData.content = string.format(TI18N("确定花费%s{assets_2,90002}购买<color='#ffff00'>%s</color>?"), tostring(data.price), tostring(data.name))
    confirmData.sureCallback = function() SevendayManager.Instance:send10239(self.openArgs) end
    NoticeManager.Instance:ConfirmTips(confirmData)
end

function SevendayHalfPrice:Update()
    local model = self.model
    self.button.gameObject:SetActive(model.discountTab[self.openArgs] == nil)
end

function SevendayHalfPrice:OnClick()
    if self.giftPreview == nil then
        self.giftPreview = GiftPreview.New(self.model.mainWin.gameObject)
    end
    self.giftPreview:Show({reward = DataGoal.data_discount[self.openArgs].item_reward, text = TI18N("打开礼包将获得以下奖励"), autoMain = true})
end

