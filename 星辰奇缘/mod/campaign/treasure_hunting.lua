TreasureHunting = TreasureHunting or BaseClass(BasePanel)

function TreasureHunting:__init(model, parent)
    self.model = CampaignManager.Instance.model
    self.parent = parent
    self.name = "TreasureHunting"

    self.resList = {
        {file = AssetConfig.treasurehunting, type = AssetType.Main},
        {file = AssetConfig.thanksgiving_textures, type = AssetType.Dep},
        {file = AssetConfig.treasurehunting_textures, type = AssetType.Dep},
        {file = AssetConfig.i18ntreasurehuntingbg, type = AssetType.Main},
        {file = AssetConfig.doubleeleven_res, type = AssetType.Dep},
        {file = AssetConfig.worldlevgiftitem1,type = AssetType.Dep},
    }

    self.itemList = {}
    self.timeString = TI18N("%s月%s日")
    self.resultString = TI18N("点击以上贝壳可进行抽奖")
    self.originPosList = {}
    self.textItemList = {}

    self.canOpen = true
    self.randomTimes = 10
    self.rotateId = nil

    self.updateListener = function(status) self:Update(status) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

end

function TreasureHunting:__delete()
    self.OnHideEvent:Fire()
    if self.openEffect ~= nil then
        self.openEffect:DeleteMe()
        self.openEffect = nil
    end
    if self.buttonEffect ~= nil then
        self.buttonEffect:DeleteMe()
        self.buttonEffect = nil
    end
    if self.naughtyIconLoader ~= nil then
        self.naughtyIconLoader:DeleteMe()
        self.naughtyIconLoader = nil
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

            if v.closeEffect ~= nil then
                v.closeEffect:DeleteMe()
                v.closeEffect = nil
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

function TreasureHunting:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.treasurehunting))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)
    self.transform = t

    UIUtils.AddBigbg(t:Find("Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.i18ntreasurehuntingbg)))

    self.timeText = t:Find("Time/Text"):GetComponent(Text)
    self.descExt = MsgItemExt.New(t:Find("Desc"):GetComponent(Text), 540, 15, 16.6)

    local list = t:Find("List")
    for i=1, 4 do
        local tab = {}
        local btn = t:Find("List/"..i)
        tab.btn = btn
        tab.gameObject = btn.gameObject
        tab.transform = btn.gameObject.transform
        tab.slot = ItemSlot.New()
        tab.slotObj = tab.transform:Find("Slot").gameObject
        tab.nameBg = tab.transform:Find("Slot/NameBg").gameObject
        tab.nameText = tab.transform:Find("Slot/NameBg/Name"):GetComponent(Text)
        NumberpadPanel.AddUIChild(tab.slotObj.transform:Find("Slot").gameObject, tab.slot.gameObject)
        tab.image = tab.gameObject:GetComponent(Image)
        tab.lightImage = tab.transform:Find("Slot/Light"):GetComponent(Image)
        tab.lightImage.sprite = self.assetWrapper:GetSprite(AssetConfig.worldlevgiftitem1,"worldlevitemlight1")
        tab.effect = BibleRewardPanel.ShowEffect(20142, tab.transform:Find("Button"), Vector3(1, 1, 1), Vector3(0, 30, 0))
        -- tab.closeEffect = BibleRewardPanel.ShowEffect(20411, tab.transform, Vector3(1, 1, 1), Vector3(0, 0, 0))
        -- tab.closeEffect:SetActive(false)
        self.itemList[i] = tab
        self.originPosList[i] = tab.transform.anchoredPosition

        local j = i
        tab.btn:Find("Button"):GetComponent(Button).onClick:AddListener(function() self:OnOpenCard(j) end)
    end
    self.container = list

    self.button = t:Find("Button"):GetComponent(Button)
    self.buttonAssets = t:Find("ButtonText"):GetComponent(Button)
    self.buttonExt = MsgItemExt.New(t:Find("ButtonText/Text"):GetComponent(Text), 155, 20, 22)
    self.resultText = t:Find("Result"):GetComponent(Text)
    self.slider = t:Find("Slider"):GetComponent(Slider)
    self.noticeBtn = t:Find("Notice"):GetComponent(Button)
    self.showBtn = t:Find("Show"):GetComponent(Button)
    t:Find("ActButton"):GetComponent(Button).onClick:AddListener(function()
        -- AgendaManager.Instance:OpenWindow({1})
        -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.campaign_uniwin, {737})

        local myItemData = ItemData.New()
        local baseData = DataItem.data_get[90045]
        myItemData:SetBase(baseData)
        TipsManager.Instance:ShowItem({gameObject = t:Find("ActButton").gameObject,itemData = myItemData})
    end)

    self.naughtyIconLoader = SingleIconLoader.New(t:Find("Naughty/Image").gameObject)
    self.naughtyIconLoader:SetSprite(SingleIconType.Item, DataItem.data_get[90045].icon)
    self.naughtyText = t:Find("Naughty/NumText"):GetComponent(Text)
    t:Find("Naughty").gameObject:SetActive(false)

    self.textItemCloner = t:Find("Slider/TextItem").gameObject
    self.textItemCloner:SetActive(false)

    self.button.onClick:AddListener(function() self:OnClick() end)
    self.buttonAssets.onClick:AddListener(function() self:OnClick() end)
    self.resultText.text = self.resultString

    self.buttonEffect = BibleRewardPanel.ShowEffect(20053, self.button.transform, Vector3(2.2, 0.7, 1), Vector3(-69.9, -15, -400))
    self.noticeBtn.onClick:AddListener(function() self:OnNotice() end)
    self.showBtn.onClick:AddListener(function() self:OnShowItems() end)

    self.noticeBtn.gameObject:SetActive(false)
end

function TreasureHunting:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function TreasureHunting:OnOpen()
    CampaignManager.Instance:Send17875()
    AgendaManager.Instance:Require12004()
    if self.openEffect ~= nil then
        self.openEffect:DeleteMe()
        self.openEffect = nil
    end

    self:RemoveListeners()
    OpenServerManager.Instance.onUpdateCard:AddListener(self.updateListener)

    self:OnTime()

    self:Update()

    self.timerId = LuaTimer.Add(0, 1000, function() self:UpdateActivity() end)
end

function TreasureHunting:OnHide()
    self:RemoveListeners()



    if self.giftPreview ~= nil then
        self.giftPreview:DeleteMe()
        self.giftPreview = nil
    end

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function TreasureHunting:RemoveListeners()
    OpenServerManager.Instance.onUpdateCard:RemoveListener(self.updateListener)
end

function TreasureHunting:Reload()
    local model = self.model
    self.resultText.gameObject:SetActive(false)
    self.buttonAssets.gameObject:SetActive(false)
    self.button.gameObject:SetActive(true)

    local num = 0
    for i,v in ipairs(self.itemList) do
        v.image.sprite = self.assetWrapper:GetSprite(AssetConfig.treasurehunting_textures, "IconClose")
        v.image:SetNativeSize()
        v.transform.rotation = Vector3(0, 0, 0)
        v.slotObj.transform.localPosition = Vector2(0, -8)
        if v.slotObjTweenId ~= nil then
            Tween.Instance:Cancel(v.slotObjTweenId)
            v.slotObjTweenId = nil
        end

        if model.cardData == nil then  -- 没派牌
            v.image.sprite = self.assetWrapper:GetSprite(AssetConfig.treasurehunting_textures, "IconClose")
            v.image:SetNativeSize()
            v.slotObj:SetActive(false)
            v.gameObject:SetActive(false)
        elseif model.cardData.card_list[i] == nil or model.cardData.card_list[i].flag == 0 then   -- 未翻开
            num = num + 1
            v.image.sprite = self.assetWrapper:GetSprite(AssetConfig.treasurehunting_textures, "IconClose")
            v.image:SetNativeSize()
            v.slotObj:SetActive(false)
            v.nameBg:SetActive(false)
            v.gameObject:SetActive(true)

            if model.cardData.card_list[i] ~= nil then
                local itemData = ItemData.New()
                itemData:SetBase(DataItem.data_get[model.cardData.card_list[i].base_id])
                v.slot:SetAll(itemData, {inbag = false, nobutton = true})
                v.slot:SetNum(model.cardData.card_list[i].num)
                v.nameText.text = itemData.name

                if self:NeedEffect(i) and v.slot.effect == nil then
                    self:CreatEffect(v.slot.transform, function(effectView) v.slot.effect = effectView end)
                elseif self:NeedEffect(i) and v.slot.effect ~= nil then
                    v.slot.effect.gameObject:SetActive(true)
                elseif not self:NeedEffect(i) and v.slot.effect ~= nil then
                    v.slot.effect.gameObject:SetActive(false)
                end
            end
        else
            v.image.sprite = self.assetWrapper:GetSprite(AssetConfig.treasurehunting_textures, "IconOpen")
            v.image:SetNativeSize()
            v.slotObj:SetActive(true)
            if self.openingCard == i then
                v.slotObjTweenId = Tween.Instance:MoveLocalY(v.slotObj, 65, 0.5, function() end, LeanTweenType.linear).id
            else
                v.slotObj.transform.localPosition = Vector2(0, 65)
            end
            v.gameObject:SetActive(true)

            if model.cardData.card_list[i] ~= nil then
                local itemData = ItemData.New()
                v.nameBg:SetActive(true)
                itemData:SetBase(DataItem.data_get[model.cardData.card_list[i].base_id])
                v.slot:SetAll(itemData, {inbag = false, nobutton = true})
                v.slot:SetNum(model.cardData.card_list[i].num)
                v.nameText.text = itemData.name
                if self:NeedEffect(i) and v.slot.effect == nil then
                    self:CreatEffect(v.slot.transform, function(effectView) v.slot.effect = effectView end)
                elseif self:NeedEffect(i) and v.slot.effect ~= nil then
                    v.slot.effect.gameObject:SetActive(true)
                elseif not self:NeedEffect(i) and v.slot.effect ~= nil then
                    v.slot.effect.gameObject:SetActive(false)
                end
            end
        end
    end

    self.resultText.gameObject:SetActive(num > 0 and not self:CandWash())
    self.buttonAssets.gameObject:SetActive(false)
    self.button.gameObject:SetActive(self.model.cardData ~= nil and self.model.cardData.temp_list ~= nil and #self.model.cardData.temp_list == 0 and self.model.cardData.times ~= 4)
    if self:CandWash() and self.model.cardData.times == 4 and self.model.last_group > 0 then
        LuaTimer.Add(2000, function()
            -- self.model.cardData.temp_list = {}
            self:OnClick()
            self:CloseCard()
        end)
    end
    self.noticeBtn.gameObject:SetActive(model.cardData.temp_list ~= nil and #model.cardData.temp_list == 0 and num == 0)
    self:DealButtonAndText()

    self.openingCard = nil
end

function TreasureHunting:OnTime()
    if CampaignManager.Instance.model.cardData == nil then
        return
    end
    local month = os.date("%m", self.model.start_time)
    local day = os.date("%d", self.model.start_time)
    local endmonth = os.date("%m", self.model.end_time)
    local endday = os.date("%d", self.model.end_time)

    self.timeText.text = string.format(TI18N("活动时间:  <color='#ffff00'>%s-%s</color>"),
            string.format(self.timeString, month, day),
            string.format(self.timeString, endmonth, endday)
        )

    self:DealButtonAndText()
end

function TreasureHunting:GoRandom()
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

function TreasureHunting:AfterRandom()
    self.canOpen = true
    self.button.gameObject:SetActive(false)
    self.buttonAssets.gameObject:SetActive(false)
    self.resultText.gameObject:SetActive(true)
    self:DealButtonAndText()
end
--发牌
function TreasureHunting:Deal()
    self.canOpen = false
    self.button.gameObject:SetActive(false)
    self.buttonAssets.gameObject:SetActive(false)
    local delay = 2500
    if self.model.cardData.times == 4 then
        delay = 1
    else
        self:SendCards()
    end
    LuaTimer.Add(delay, function()
        self.randomTimes = 10
        self:CloseCard()
    end)
end

function TreasureHunting:OnClick()
    CampaignManager.Instance:Send17876()
end

function TreasureHunting:OnOpenCard(i)
    if self.canOpen ~= true then
        return
    end

    local model = self.model
    -- local activity = (AgendaManager.Instance.activitypoint or {}).activity or 0
    local activity = RoleManager.Instance.RoleData.naughty
    if self.model.cardData ~= nil and self.model.cardData.times ~= nil then
        if self.model.card_act_cost[self.model.cardData.times+1] ~= nil then
            if model.cardData.card_list[i] ~= nil and model.cardData.card_list[i].flag ~= 0 then
                -- NoticeManager.Instance:FloatTipsByString(TI18N("你已经翻过这张牌了"))
                return
            end

            local card_data = model.cardData.temp_list[i]
            local card_act_cost = model.card_act_cost[self.model.cardData.times+1]

            if card_act_cost.acticity > activity then
                NoticeManager.Instance:FloatTipsByString(string.format(TI18N("淘气值达到<color='#00ff00'>%s</color>才能点开贝壳"), tostring(card_act_cost.acticity)))
                return
            end
            if #card_act_cost.cost > 0 then
                local confirmData = NoticeConfirmData.New()
                local num = card_act_cost.cost[1].num
                local num2 = card_act_cost.cost[1].id
                confirmData.content = string.format(TI18N("消耗<color='#ffff00'>%s</color>{assets_2, %s}可额外点开1个贝壳，是否继续？"), tostring(num), tostring(num2))
                confirmData.sureCallback = function() CampaignManager.Instance:Send17877(i) self:OverTurn(i) end
                NoticeManager.Instance:ConfirmTips(confirmData)
            else
                CampaignManager.Instance:Send17877(i) self:OverTurn(i)
            end
        end
    else
        CampaignManager.Instance:Send17877(i) self:OverTurn(i)
    end
end

function TreasureHunting:OverTurn(i)
    self.canOpen = true
    self.openingCard = i
    self.itemList[i].transform.localScale = Vector3(1, 1, 1)
    if self.openEffect ~= nil then
        self.openEffect:DeleteMe()
        self.openEffect = nil
    end

    -- self.itemList[i].image.enabled = false
    self.itemList[i].slotObj:SetActive(false)
    self.openEffect = BibleRewardPanel.ShowEffect(20411, self.itemList[i].transform, Vector3(1, 1, 1), Vector3(0, 13, 0))
    LuaTimer.Add(600, function()
            self.itemList[i].image.sprite = self.assetWrapper:GetSprite(AssetConfig.treasurehunting_textures, "IconOpen")
            -- self.itemList[i].image.enabled = true
            self.itemList[i].slotObj:SetActive(true)
            -- self.itemList[i].slotObj.transform.localPosition = Vector2(0, -8)
        end)
end

function TreasureHunting:CollectCards()
    for i,v in ipairs(self.itemList) do
        v.transform.anchoredPosition = Vector2(254,-184.8)
        v.gameObject:SetActive(false)
    end
    self.resultText.gameObject:SetActive(false)
    self.buttonAssets.gameObject:SetActive(false)
    self.button.gameObject:SetActive(true)
    self.canOpen = true
end

function TreasureHunting:SendFunc(i)
print("SendFunc")
    local tab = self.itemList[i]
    if tab.sendId ~= nil then
        Tween.Instance:Cancel(tab.sendId)
        tab.sendId = nil
    end
    if tab.scaleId ~= nil then
        Tween.Instance:Cancel(tab.scaleId)
        tab.scaleId = nil
    end
    tab.image.sprite = self.assetWrapper:GetSprite(AssetConfig.treasurehunting_textures, "IconOpen")
    tab.slotObj:SetActive(true)
    tab.slotObj.transform.localPosition = Vector2(0, -8)

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

function TreasureHunting:SendCards()
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

function TreasureHunting:CloseCard()
    for i,v in ipairs(self.itemList) do
        -- if v.rotateId ~= nil then
        --     Tween.Instance:Cancel(v.rotateId)
        --     v.rotateId = nil
        -- end
        -- local j = i
        -- v.rotateId = Tween.Instance:RotateY(v.gameObject, 90, 0.5, function()
        --         self.itemList[j].slotObj:SetActive(false)
        --         self.itemList[j].nameBg:SetActive(false)
        --         self.itemList[j].image.sprite = self.assetWrapper:GetSprite(AssetConfig.treasurehunting_textures, "IconClose")
        --         v.rotateId = Tween.Instance:RotateY(self.itemList[j].gameObject, 0, 0.5, function()

        --                 v.rotateId = nil
        --                 local b = true
        --                 for k,v in pairs(self.itemList) do
        --                     b = b and (v.rotateId == nil)
        --                 end
        --                 if b == true then
        --                     self:GoRandom()
        --                 end
        --             end).id
        --     end, LeanTweenType.linear).id
        if v.closeTimerId ~= nil then
            LuaTimer.Delete(v.closeTimerId)
            v.closeTimerId = nil
        end

        if v.closeEffectTimerId ~= nil then
            LuaTimer.Delete(v.closeEffectTimerId)
            v.closeEffectTimerId = nil
        end
        -- v.closeEffect:SetActive(false)
        -- v.closeEffect:SetActive(true)
        local callback = function()
            v.slotObj:SetActive(false)
            v.nameBg:SetActive(false)
            v.image.sprite = self.assetWrapper:GetSprite(AssetConfig.treasurehunting_textures, "IconClose")
            v.image:SetNativeSize()
            -- v.closeEffect:SetActive(false)

            LuaTimer.Delete(v.closeTimerId)
            v.closeTimerId = nil
            local b = true
            for k,v in pairs(self.itemList) do
                b = b and (v.closeTimerId == nil)
            end
            if b == true then
                self.randomTimes = 10
                self:GoRandom()
            end
            v.closeEffect:SetActive(false)
        end

        v.closeTimerId = LuaTimer.Add(100, function()
                if v.closeEffect == nil then
                    v.closeEffect = BibleRewardPanel.ShowEffect(20416,v.slotObj.transform, Vector3(0.7, 0.7, 1), Vector3(0, 13, 0))
                end
                v.closeEffect:SetActive(true)

                v.closeEffectTimerId =LuaTimer.Add(900,function()
                    callback()
                end)
            end)
    end
end

function TreasureHunting:Update(status)
    if CampaignManager.Instance.model.cardData == nil then
        print("CampaignManager.Instance.model.cardData == nil")
        return
    end

    if status == true then  -- 刚刚发牌
        self:Deal()
    else
        local datalist = (CampaignManager.Instance.model.cardData or {}).card_list or {}
        if self.model.notOpen == true and (self.model.cardData.temp_list ~= nil and #self.model.cardData.temp_list == 0) then
            self:CollectCards()
        else
            self:Reload()
            self.resultText.gameObject:SetActive(true and not self:CandWash())
        end
    end
    self:DealButtonAndText()

    self:UpdateSlider()
    self:UpdateNaughty()
end

function TreasureHunting:UpdateSlider()
    local sliderWidth = self.slider.transform:GetComponent(RectTransform).sizeDelta.x
    for i=1, #self.model.card_act_cost do
        local acticity = self.model.card_act_cost[i].acticity
        if acticity ~= 0 then
            local textItem = self.textItemList[i]
            if textItem == nil then
                textItem = GameObject.Instantiate(self.textItemCloner)
                textItem.transform:SetParent(self.slider.transform)
                textItem:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
                self.textItemList[i] = textItem
            end

            textItem:SetActive(true)

            textItem:GetComponent(RectTransform).localPosition = Vector3(acticity / self.model.card_act_cost_max * sliderWidth - 10 - (sliderWidth / 2), 0, 0)
            textItem.transform:Find("Text"):GetComponent(Text).text = tostring(acticity)
        end
    end

    for i=#self.model.card_act_cost+1, #self.textItemList do
        self.textItemList[i]:SetActive(false)
    end
end

function TreasureHunting:UpdateActivity()
    if self.model.receiveNum == nil then
        return
    end

    -- if self.model.receiveNum > 1 then
    --     self.slider.value = 1
    -- else
        -- local activity = (AgendaManager.Instance.activitypoint or {}).activity or 0
        local activity = RoleManager.Instance.RoleData.naughty
        local total = 50
        self.slider.value = activity / total
    -- end
end

function TreasureHunting:OnNotice()
    TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = {TI18N("钻石翻牌第一次额外赠送100感恩积分，第二次赠送300感恩积分")}})
end

function TreasureHunting:OnShowItems()
    local model = self.model

    if #model.cardData.temp_list == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("当前没有贝壳，无可查看奖励~"))
    elseif model.allOpen == true then
        NoticeManager.Instance:FloatTipsByString(TI18N("你已经领取了全部奖励"))
    else
        if self.giftPreview == nil then
            self.giftPreview = GiftPreview.New(self.parent.transform.parent.parent.parent)
        end
        local rewardList = {}
        local rewardDataList = model.cardData.temp_list
        for i,v in ipairs(rewardDataList) do
            if v.flag == 0 then
                table.insert(rewardList, {v.base_id, v.num})
            end
        end
        self.giftPreview:Show({reward = rewardList, autoMain = true, text = TI18N("点开贝壳后必定获得以下奖励中一个：")})
    end
end

function TreasureHunting:CandWash()
    if (self.model.cardData ~= nil and self.model.cardData.temp_list ~= nil and #self.model.cardData.temp_list == 0) then
        return true
    elseif self.model.cardData.temp_list ~= nil and #self.model.cardData.card_list == 4 and self.model.last_group > 0 then
        for k,v in pairs(self.model.cardData.temp_list) do
            if v.flag == 0 then
                return false
            end
        end
        return true
    end
    return false
end

function TreasureHunting:CreatEffect(trans, callback)
    local funTemp = function(effectView)
        local effectObject = effectView.gameObject

        effectObject.transform:SetParent(trans)
        effectObject.transform.localScale = Vector3(1, 1, 1)
        effectObject.transform.localPosition = Vector3.zero
        effectObject.transform.localRotation = Quaternion.identity

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
        effectObject:SetActive(true)
        callback(effectView)
    end
    BaseEffectView.New({effectId = 20223, time = nil, callback = funTemp})
end

function TreasureHunting:NeedEffect(index)
    if self.model.cardData ~= nil and self.model.cardData.card_list[index] ~= nil then
        local card_data = self.model.cardData.card_list[index]
        -- local card = DataCampaignNewFlop.data_card_list[string.format("%s_%s", card_data.group, card_data.reward_id)]
        -- if card ~= nil then
        --     return card.effect ~= 0
        -- end
        return card_data.effect ~= 0
    end
end
--deal 发牌按钮和文字
function TreasureHunting:DealButtonAndText()
    if CampaignManager.Instance.model.cardData == nil then
        print("CampaignManager.Instance.model.cardData == nil")
        return
    end

    if self.model.cardData ~= nil and self.model.cardData.times ~= nil then
        local times = self.model.cardData.times+1
        -- local activity = (AgendaManager.Instance.activitypoint or {}).activity or 0
        local activity = RoleManager.Instance.RoleData.naughty
        if self.model.card_act_cost[times] ~= nil then
            local limit = self.model.card_act_cost[times]
            self.resultText.text = self.resultString
            if #limit.cost > 0 then
                local num = limit.cost[1].num
                local num2 = limit.cost[1].id
                self.descExt:SetData(string.format(TI18N("消耗<color='#ffff00'>%s</color>{assets_2, %s}即可点开贝壳，祝你好运{face_1,3}"), tostring(num), tostring(num2)))
            end

            if limit.acticity > 0 then
                self.descExt:SetData(string.format(TI18N("当天达到<color='#00ff00'>%s</color>淘气值后可点开贝壳，祝你好运{face_1,3}"), tostring(limit.acticity)))
                if limit.acticity > activity then
                    self.resultText.text = TI18N("达到以上条件即可进行抽奖")
                end
            end
        else
            if self.model.card_act_cost[4] ~= nil then
                local limit = self.model.card_act_cost[4]
                self.resultText.text = self.resultString
                if #limit.cost > 0 then
                    local num = limit.cost[1].num
                    local num2 = limit.cost[1].id
                    self.descExt:SetData(string.format(TI18N("消耗<color='#ffff00'>%s</color>{assets_2, %s}即可点开贝壳，祝你好运{face_1,3}"), tostring(num), tostring(num2)))
                end

                if limit.acticity > 0 then
                    self.descExt:SetData(string.format(TI18N("当天达到<color='#00ff00'>%s</color>淘气值后可点开贝壳，祝你好运{face_1,3}"), tostring(limit.acticity)))
                end
            else
                self.descExt:SetData("")
            end
            self.resultText.text = TI18N("全部的奖励已获得！")
        end
    else
        self.resultText.text = self.resultString
    end
    local size = self.descExt.contentRect.sizeDelta
    self.descExt.contentRect.anchoredPosition = Vector2(-size.x / 2, -348)
    self.resultText.gameObject:SetActive(not self:CandWash())
    -- self.button.gameObject:SetActive(self:CandWash())
end

function TreasureHunting:UpdateNaughty()
    self.naughtyText.text = tostring(RoleManager.Instance.RoleData.naughty)
end