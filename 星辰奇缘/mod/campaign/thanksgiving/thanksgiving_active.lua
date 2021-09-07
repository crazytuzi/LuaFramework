ThanksgivingActive = ThanksgivingActive or BaseClass(BasePanel)

function ThanksgivingActive:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "ThanksgivingActive"

    self.resList = {
        {file = AssetConfig.thanksgiving_active, type = AssetType.Main},
        {file = AssetConfig.thanksgiving_textures, type = AssetType.Dep},
        {file = AssetConfig.thanksgiving_active_i18n, type = AssetType.Main},
        {file = AssetConfig.doubleeleven_res, type = AssetType.Dep},
    }

    self.itemList = {}
    self.timeString = TI18N("%s月%s日")
    self.resultString = TI18N("点击以上卡牌可进行抽奖")
    self.originPosList = {}

    self.canOpen = true
    self.randomTimes = 10
    self.rotateId = nil

    self.updateListener = function(status) self:Update(status) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function ThanksgivingActive:__delete()
    self.OnHideEvent:Fire()
    if self.openEffect ~= nil then
        self.openEffect:DeleteMe()
        self.openEffect = nil
    end
    if self.buttonEffect ~= nil then
        self.buttonEffect:DeleteMe()
        self.buttonEffect = nil
    end
    if self.itemList ~= nil then
        for i,v in ipairs(self.itemList) do
            if v.tweenId ~= nil then
                Tween.Instance:Cancel(v.tweenId)
                v.tweenId = nil
            end
            if v.scaleId ~= nil then
                Tween.Instance:Cancel(v.scaleId)
                v.scaleId = nil
            end
            if v.sendId ~= nil then
                Tween.Instance:Cancel(v.sendId)
                v.sendId = nil
            end
            if v.slot ~= nil then
                v.slot:DeleteMe()
            end
        end
        self.itemList = nil
    end
    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end
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

function ThanksgivingActive:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.thanksgiving_active))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)
    self.transform = t

    UIUtils.AddBigbg(t:Find("Bg/Top"), GameObject.Instantiate(self:GetPrefab(AssetConfig.thanksgiving_active_i18n)))

    self.timeText = t:Find("Time/Text"):GetComponent(Text)
    self.descExt = MsgItemExt.New(t:Find("Desc"):GetComponent(Text), 540, 15, 16.6)

    local list = t:Find("List")
    local btnList = t:Find("List"):GetComponentsInChildren(Button)

    for i,btn in ipairs(btnList) do
        local tab = {}
        tab.btn = btn
        tab.gameObject = btn.gameObject
        tab.transform = btn.gameObject.transform
        tab.slot = ItemSlot.New()
        tab.slotObj = tab.transform:Find("Slot").gameObject
        tab.nameBg = tab.transform:Find("NameBg").gameObject
        tab.nameText = tab.transform:Find("NameBg/Name"):GetComponent(Text)
        NumberpadPanel.AddUIChild(tab.slotObj, tab.slot.gameObject)
        tab.image = tab.gameObject:GetComponent(Image)
        self.itemList[i] = tab
        self.originPosList[i] = tab.transform.anchoredPosition

        local j = i
        tab.btn.onClick:AddListener(function() self:OnOpenCard(j) end)
    end
    self.container = list

    self.button = t:Find("Button"):GetComponent(Button)
    self.buttonAssets = t:Find("ButtonText"):GetComponent(Button)
    self.buttonExt = MsgItemExt.New(t:Find("ButtonText/Text"):GetComponent(Text), 155, 20, 22)
    self.resultText = t:Find("Result"):GetComponent(Text)
    self.slider = t:Find("Slider"):GetComponent(Slider)
    self.noticeBtn = t:Find("Notice"):GetComponent(Button)
    self.showBtn = t:Find("Show"):GetComponent(Button)

    self.button.onClick:AddListener(function() self:OnClick() end)
    self.buttonAssets.onClick:AddListener(function() self:OnClick() end)
    self.resultText.text = self.resultString

    self.buttonEffect = BibleRewardPanel.ShowEffect(20053, self.button.transform, Vector3(2.2, 0.7, 1), Vector3(-69.9, -15, -400))
    self.noticeBtn.onClick:AddListener(function() self:OnNotice() end)
    self.showBtn.onClick:AddListener(function() self:OnShowItems() end)

    self.noticeBtn.gameObject:SetActive(false)
end

function ThanksgivingActive:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ThanksgivingActive:OnOpen()
    AgendaManager.Instance:Require12004()
    if self.openEffect ~= nil then
        self.openEffect:DeleteMe()
        self.openEffect = nil
    end

    self:RemoveListeners()
    ThanksgivingManager.Instance.cardEvent:AddListener(self.updateListener)

    self:OnTime()

    self:Update()

    self.timerId = LuaTimer.Add(0, 1000, function() self:UpdateActivity() end)
end

function ThanksgivingActive:OnHide()
    self:RemoveListeners()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function ThanksgivingActive:RemoveListeners()
    ThanksgivingManager.Instance.cardEvent:RemoveListener(self.updateListener)
end

function ThanksgivingActive:Reload()
    local model = self.model
    self.resultText.gameObject:SetActive(false)
    self.buttonAssets.gameObject:SetActive(false)
    self.button.gameObject:SetActive(true)

    local num = 0
    for i,v in ipairs(self.itemList) do
        v.image.sprite = self.assetWrapper:GetSprite(AssetConfig.thanksgiving_textures, "CardBack")
        v.transform.rotation = Vector3(0, 0, 0)

        if model.cardData == nil then  -- 没派牌
            v.image.sprite = self.assetWrapper:GetSprite(AssetConfig.thanksgiving_textures, "CardBack")
            v.slotObj:SetActive(false)
            v.gameObject:SetActive(false)
        elseif model.cardData.card_list[i] == nil or model.cardData.card_list[i].flag == 0 then   -- 未翻开
            num = num + 1
            v.image.sprite = self.assetWrapper:GetSprite(AssetConfig.thanksgiving_textures, "CardBack")
            v.slotObj:SetActive(false)
            v.nameBg:SetActive(false)
            v.gameObject:SetActive(true)

            if model.cardData.card_list[i] ~= nil then
                local itemData = ItemData.New()
                itemData:SetBase(DataItem.data_get[model.cardData.card_list[i].base_id])
                v.slot:SetAll(itemData, {inbag = false, nobutton = true})
                v.slot:SetNum(model.cardData.card_list[i].num)
                v.nameText.text = itemData.name
            end
        else
            v.image.sprite = self.assetWrapper:GetSprite(AssetConfig.thanksgiving_textures, "CardFront")
            v.slotObj:SetActive(true)
            v.gameObject:SetActive(true)

            if model.cardData.card_list[i] ~= nil then
                local itemData = ItemData.New()
                v.nameBg:SetActive(true)
                itemData:SetBase(DataItem.data_get[model.cardData.card_list[i].base_id])
                v.slot:SetAll(itemData, {inbag = false, nobutton = true})
                v.slot:SetNum(model.cardData.card_list[i].num)
                v.nameText.text = itemData.name
            end
        end
    end

    self.resultText.gameObject:SetActive(num > 0)
    self.buttonAssets.gameObject:SetActive(false)
    self.button.gameObject:SetActive(model.cardData.temp_list ~= nil and #model.cardData.temp_list == 0 and num == 0)

    self.noticeBtn.gameObject:SetActive(model.cardData.temp_list ~= nil and #model.cardData.temp_list == 0 and num == 0)
end

function ThanksgivingActive:OnTime()
    local campId = CampaignManager.Instance.campaignTree[CampaignEumn.Type.Thanksgiving][CampaignEumn.ThanksgivingType.Active].sub[1].id
    local start_time = DataCampaign.data_list[campId].cli_start_time[1]
    local end_time = DataCampaign.data_list[campId].cli_end_time[1]

    self.timeText.text = string.format(TI18N("活动时间:<color='#ffff00'>%s-%s</color>"),
            string.format(self.timeString, tostring(start_time[2]), tostring(start_time[3])),
            string.format(self.timeString, tostring(end_time[2]), tostring(end_time[3]))
        )

    self.descExt:SetData(DataCampaign.data_list[campId].cond_desc)

    local size = self.descExt.contentRect.sizeDelta
    self.descExt.contentRect.anchoredPosition = Vector2(-size.x / 2, -348)
end

function ThanksgivingActive:GoRandom()
    self.canOpen = false
    self.randomTimes = self.randomTimes - 1
    if self.randomTimes < 1 then
        self.canOpen = true
        self:AfterRandom()
        return
    end
    local tab = {1, 2, 3, 4}
    local random = math.random
    local swap = nil
    local swapIndex = nil
    for i=1,4 do
        swapIndex = random(i,4)
        swap = tab[swapIndex]
        tab[swapIndex] = tab[i]
        tab[i] = swap
    end

    for i,v in ipairs(self.itemList) do
        if v.tweenId ~= nil then
            Tween.Instance:Cancel(v.tweenId)
            v.tweenId = nil
        end
        local j = i
        v.tweenId = Tween.Instance:MoveX(v.transform, self.originPosList[tab[i]].x, 0.3, function()
                local b = true
                self.itemList[j].tweenId = nil
                for i,vv in ipairs(self.itemList) do
                    b = b and (vv.tweenId == nil)
                end
                if b == true then
                    self:GoRandom()
                end
            end, LeanTweenType.linear).id
    end
end

function ThanksgivingActive:AfterRandom()
    self.canOpen = true
    self.button.gameObject:SetActive(false)
    self.buttonAssets.gameObject:SetActive(false)
    self.resultText.gameObject:SetActive(true)
end

function ThanksgivingActive:Deal()
    self.button.gameObject:SetActive(false)
    self.buttonAssets.gameObject:SetActive(false)
    self:SendCards()
    LuaTimer.Add(3800, function()
        self.randomTimes = 10
        self:CloseCard()
    end)
end

function ThanksgivingActive:OnClick()
    ThanksgivingManager.Instance:send14048()
end

function ThanksgivingActive:OnOpenCard(i)
    if self.canOpen ~= true then
        return
    end
    if self.model.cardData.card_list[i] ~= nil and self.model.cardData.card_list[i].flag ~= 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("已翻牌"))
        return
    end
    local activity = (AgendaManager.Instance.activitypoint or {}).activity or 0
    if self.model.receiveNum == 0 then      -- 没领过
        if activity >= 30 then
            ThanksgivingManager.Instance:send14049(i)
            self:OverTurn(i)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("活跃度达到<color='#00ff00'>30</color>才能翻牌"))
        end
    elseif self.model.receiveNum == 1 then -- 领过一次
        if activity >= 80 then
            ThanksgivingManager.Instance:send14049(i)
            self:OverTurn(i)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("活跃度达到<color='#00ff00'>80</color>才能翻牌"))
        end
    elseif self.model.receiveNum < 4 then -- 领过两次或三次
        local confirmData = NoticeConfirmData.New()
        local num = 160
        local num1 = 100
        if self.model.receiveNum == 3 then
            num = 380
            num1 = 300
        end
        confirmData.content = string.format(TI18N("消耗<color='#ffff00'>%s</color>{assets_2, 90002}可额外翻开1张牌，是否继续？(额外获得<color='#00ff00'>%s</color>{assets_2, 90028})"), tostring(num), tostring(num1))
        confirmData.sureCallback = function() ThanksgivingManager.Instance:send14049(i) self:OverTurn(i) end
        NoticeManager.Instance:ConfirmTips(confirmData)
    end
end

function ThanksgivingActive:OverTurn(i)
    self.canOpen = true
    self.itemList[i].transform.localScale = Vector3(1, 1, 1)
    if self.openEffect ~= nil then
        self.openEffect:DeleteMe()
        self.openEffect = nil
    end

    self.itemList[i].image.enabled = false
    self.itemList[i].slotObj:SetActive(false)
    self.openEffect = BibleRewardPanel.ShowEffect(20184, self.itemList[i].transform, Vector3(0.85, 0.85, 1), Vector3(-3, 0, 0))
    LuaTimer.Add(600, function()
            self.itemList[i].image.sprite = self.assetWrapper:GetSprite(AssetConfig.thanksgiving_textures, "CardFront")
            self.itemList[i].image.enabled = true
            self.itemList[i].slotObj:SetActive(true)
        end)
end

function ThanksgivingActive:CollectCards()
    for i,v in ipairs(self.itemList) do
        v.transform.anchoredPosition = Vector2(254,-184.8)
        v.gameObject:SetActive(false)
    end
    self.resultText.gameObject:SetActive(false)
    self.buttonAssets.gameObject:SetActive(false)
    self.button.gameObject:SetActive(true)
    self.canOpen = true
end

function ThanksgivingActive:SendFunc(i)
    local tab = self.itemList[i]
    if tab.sendId ~= nil then
        Tween.Instance:Cancel(tab.sendId)
        tab.sendId = nil
    end
    if tab.scaleId ~= nil then
        Tween.Instance:Cancel(tab.scaleId)
        tab.scaleId = nil
    end
    tab.image.sprite = self.assetWrapper:GetSprite(AssetConfig.thanksgiving_textures, "CardFront")
    tab.slotObj:SetActive(true)

    if self.model.cardData.card_list[i] ~= nil then
        local itemData = ItemData.New()
        itemData:SetBase(DataItem.data_get[self.model.cardData.card_list[i].base_id])
        tab.slot:SetAll(itemData, {inbag = false, nobutton = true})
        tab.slot:SetNum(self.model.cardData.card_list[i].num)
        tab.nameBg.gameObject:SetActive(true)
        tab.nameText.text = itemData.name
    end
    local j = i
    tab.gameObject:SetActive(true)
    local target = Vector3(self.originPosList[self.sendOrder[j]].x, self.originPosList[self.sendOrder[j]].y, 0)
    tab.sendId = Tween.Instance:Move(self.itemList[j].gameObject:GetComponent(RectTransform), target, 0.5, function()
        tab.sendId = nil
        if tab.scaleId == nil and j ~= 4 then
            self:SendFunc(j + 1)
        end
    end, LeanTweenType.linear).id
    -- tab.transform.localScale = Vector3(0.2, 0.2, 1)
    tab.scaleId = Tween.Instance:Scale(self.itemList[j].gameObject, Vector3.one, 0.5, function()
        tab.scaleId = nil
        if tab.sendId == nil and j ~= 4 then
            self:SendFunc(j + 1)
        end
    end, LeanTweenType.linear).id
end

function ThanksgivingActive:SendCards()
    self.sendOrder = {1, 2, 3, 4}
    local random = math.random
    local swap = nil
    local swapIndex = nil
    for i=1,4 do
        swapIndex = random(i,4)
        swap = self.sendOrder[swapIndex]
        self.sendOrder[swapIndex] = self.sendOrder[i]
        self.sendOrder[i] = swap
    end
    self:SendFunc(1)
end

function ThanksgivingActive:CloseCard()
    for i,v in ipairs(self.itemList) do
        if v.rotateId ~= nil then
            Tween.Instance:Cancel(v.rotateId)
            v.rotateId = nil
        end
        local j = i
        v.rotateId = Tween.Instance:RotateY(v.gameObject, 90, 0.5, function()
                self.itemList[j].slotObj:SetActive(false)
                self.itemList[j].nameBg:SetActive(false)
                self.itemList[j].image.sprite = self.assetWrapper:GetSprite(AssetConfig.thanksgiving_textures, "CardBack")
                v.rotateId = Tween.Instance:RotateY(self.itemList[j].gameObject, 0, 0.5, function()
                        v.rotateId = nil
                        local b = true
                        for k,v in pairs(self.itemList) do
                            b = b and (v.rotateId == nil)
                        end
                        if b == true then
                            self:GoRandom()
                        end
                    end).id
            end, LeanTweenType.linear).id
    end
end

function ThanksgivingActive:Update(status)
    if status == true then  -- 刚刚发牌
        self:Deal()
    else
        local datalist = (ThanksgivingManager.Instance.model.cardData or {}).card_list or {}
        if self.model.notOpen == true and (self.model.cardData.temp_list ~= nil and #self.model.cardData.temp_list == 0) then
            self:CollectCards()
        else
            self:Reload()
            self.resultText.gameObject:SetActive(true)
        end
    end
end

function ThanksgivingActive:UpdateActivity()
    if self.model.receiveNum > 1 then
        self.slider.value = 1
    else
        local activity = (AgendaManager.Instance.activitypoint or {}).activity or 0
        local total = 80
        self.slider.value = activity / total
    end
end

function ThanksgivingActive:OnNotice()
    TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = {TI18N("钻石翻牌第一次额外赠送100感恩积分，第二次赠送300感恩积分")}})
end

function ThanksgivingActive:OnShowItems()
    local model = self.model

    if #model.cardData.temp_list == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("当前未发牌，无可查看奖励~"))
    elseif model.allOpen == true then
        NoticeManager.Instance:FloatTipsByString(TI18N("你已经领取了全部奖励"))
    else
        if self.giftPreview == nil then
            self.giftPreview = GiftPreview.New(self.model.mainWin.gameObject)
        end
        local rewardList = {}
        local rewardDataList = model.cardData.temp_list
        for i,v in ipairs(rewardDataList) do
            if v.flag == 0 then
                table.insert(rewardList, {v.base_id, v.num})
            end
        end
        self.giftPreview:Show({reward = rewardList, autoMain = true, text = TI18N("翻牌后必定获得以下奖励中一个：")})
    end
end
