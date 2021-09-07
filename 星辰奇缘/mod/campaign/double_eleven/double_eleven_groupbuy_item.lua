--2016/11/4
--xjlong
--双十一全民团购item
DoubleElevenGroupBuyItem = DoubleElevenGroupBuyItem or BaseClass(BasePanel)

function DoubleElevenGroupBuyItem:__init(gameObject, mainWindow)
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    self.mainWindow = mainWindow

    self.nameTxt = self.transform:Find("Name"):GetComponent(Text)
    local itembgBtn = self.transform:Find("Icon"):GetComponent(Button)
    self.itemIcon = self.transform:Find("Icon/Image"):GetComponent(Image)
    self.itemIcon.gameObject:SetActive(false)
    self.itemSlot = ItemSlot.New()
    self.itemData = ItemData.New()
    self.itemSlot.noTips = true
    self.itemSlot.clickSelfFunc = function() self:ClickSlot() end
    NumberpadPanel.AddUIChild(itembgBtn.transform, self.itemSlot.gameObject)

    self.remainTime = self.transform:Find("RemainTime"):GetComponent(Text)
    self.remainCount = self.transform:Find("RemainCount"):GetComponent(Text)
    local nowTrans = self.transform:Find("Now")
    self.nowPrice = nowTrans:Find("PriceText"):GetComponent(Text)
    self.nowPriceIcon = nowTrans:Find("Text/Icon"):GetComponent(Image)
    local lastTrans = self.transform:Find("Last")
    self.lastPrice = lastTrans:Find("PriceText"):GetComponent(Text)
    self.lastPriceIcon = lastTrans:Find("Text/Icon"):GetComponent(Image)

    self.discountListObj = self.transform:Find("DiscountList")
    self.discountItem = self.discountListObj:Find("DiscountItem")
    self.discountItem.gameObject:SetActive(false)
    self.BtnGo = self.transform:Find("BtnGo"):GetComponent(Button)
    self.BtnGoImage = self.BtnGo:GetComponent(Image)
    self.BtnGoText = self.BtnGo.transform:Find("Text"):GetComponent(Text)

    self.BtnGo.onClick:AddListener(
        function()
            if self.canBuy then
                if self.data.price_type == 90002 then
                    local confirmData = NoticeConfirmData.New()
                    local itemData = DataItem.data_get[self.data.base_id]
                    confirmData.content = string.format(TI18N("购买<color='#ffff00'>%s</color>将消耗<color='#00ff00'>%s</color>{assets_2,90002}，是否继续？"), tostring(itemData.name), tostring(self.nowPrice.text))
                    confirmData.sureLabel = TI18N("确 定")
                    confirmData.cancelLabel = TI18N("取 消")
                    confirmData.sureCallback = function() DoubleElevenManager.Instance:Send14046(self.data.id, 1) end
                    NoticeManager.Instance:ConfirmTips(confirmData)
                else
                    DoubleElevenManager.Instance:Send14046(self.data.id, 1)
                end
            else
                NoticeManager.Instance:FloatTipsByString(string.format(TI18N("这个礼包您已经不能再购买啦~")))
            end
        end
    )

    self.giftPreview = nil

    self.slider = self.transform:Find("CountSlider"):GetComponent(Slider)
    -- self.handleObj = self.slider.transform:Find("Handle Slide Area/Handle")
    -- local funTemp = function(effectView)
    --     local effectObject = effectView.gameObject

    --     effectObject.transform:SetParent(self.handleObj)
    --     print(self.handleObj.name)
    --     effectObject.transform.localScale = Vector3(1, 1, 1)
    --     effectObject.transform.localPosition = Vector3(0, 0, -400)
    --     effectObject.transform.localRotation = Quaternion.identity

    --     Utils.ChangeLayersRecursively(effectObject.transform, "UI")
    --     effectObject:SetActive(true)
    -- end
    -- self.effectObj = BaseEffectView.New({effectId = 20161, time = nil, callback = funTemp})

    self.data = nil
    self.index = 0
    self.timerId = 0
    self.countData = 0
    self.endTime = 0
    self.startTime = 0
    self.discountList = {}
    self.canBuy = true

    self.discountPosXTemp = {beginPos = -234, endPos = 116, lengthMax = 350}
end

function DoubleElevenGroupBuyItem:__delete()
    if self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
        self.timerId = 0
    end

    -- if self.effectObj ~= nil then
    --     self.effectObj:DeleteMe()
    -- end
    if self.giftPreview ~= nil then
        self.giftPreview:DeleteMe()
        self.giftPreview = nil
    end

    if self.discountList ~= nil then
        for i,v in ipairs(self.discountList) do
            if v.effectObj ~= nil then
                v.effectObj:DeleteMe()
                v.effectObj = nil
            end
        end
        self.discountList = nil
    end

    if self.itemData ~= nil then
        self.itemData:DeleteMe()
        self.itemData = nil
    end

    if self.itemSlot ~= nil then
        self.itemSlot:DeleteMe()
        self.itemSlot = nil
    end

    self.gameObject = nil
    self.transform = nil
end

function DoubleElevenGroupBuyItem:update_my_self(data, i)
    if data == nil then return end

    self.data = data
    self.index = i

    local itemData = DataItem.data_get[data.base_id]
    self.nameTxt.text = itemData.name
    self.itemData:SetBase(itemData)
    self.itemSlot:SetAll(self.itemData, {inbag = false, nobutton = true})
    self.itemSlot:SetNum(data.num)

    local nowPriceTemp = math.floor(data.price * data.discount / 1000 + 0.5)
    self.nowPrice.text = tostring(nowPriceTemp)
    self.lastPrice.text = tostring(data.price)
    self.nowPriceIcon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[data.price_type])
    self.lastPriceIcon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[data.price_type])

    self.startTime = data.start_time
    self.endTime = data.end_time

    local count = data.limit_num - data.self_buy_num
    if count <= 0 then
        count = 0
        self.canBuy = false
        self.BtnGoImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.BtnGoText.color = ColorHelper.DefaultButton4
    else
        self.canBuy = true
        self.BtnGoText.color = ColorHelper.DefaultButton3
        self.BtnGoImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
    end

    self.remainCount.text = string.format("%d/%d", count, data.limit_num)
    self:UpdateDiscountObj(data.discount_list)
    self:UpdateTime()
end

function DoubleElevenGroupBuyItem:UpdateTime()
    if self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
        self.timerId = 0
    end
    self.timeTemp = Time.time -- 当前时间
    self.timeT = Time.time --上次的时间
    local end_time = self.endTime
    self.countData = end_time - BaseUtils.BASE_TIME
    self.timerId = LuaTimer.Add(0, 1000, function()
        if self.countData > 0 then
            self.timeTemp = Time.time
            self.countData = self.countData - (self.timeTemp - self.timeT)
            self.timeT = Time.time

            local day,hour = BaseUtils.time_gap_to_timer(math.floor(self.countData))
            self.remainTime.text = string.format(TI18N("%s天%s小时"), day, hour)
        else
            self.remainTime.text = TI18N("0天0小时")
            if self.timerId ~= 0 then
                LuaTimer.Delete(self.timerId)
                self.timerId = 0
            end
        end
    end)
end

function DoubleElevenGroupBuyItem:UpdateDiscountObj(discount_list)
    local maxNeedNum = 0
    for i,v in ipairs(discount_list) do
        if v.need_num > maxNeedNum then
            maxNeedNum = v.need_num
        end
    end

    self.slider.value = self.data.buy_num / maxNeedNum

    for i,v in ipairs(self.discountList) do
        v.gameObject:SetActive(false)
        if v.effectObj ~= nil then
            v.effectObj:SetActive(false)
        end
    end

    for i,v in ipairs(discount_list) do
        local itemInfo = self.discountList[i]
        if itemInfo == nil then
            itemInfo = {}
            local obj = GameObject.Instantiate(self.discountItem)
            obj.transform:SetParent(self.discountListObj.transform)
            obj.gameObject:SetActive(false)
            obj.transform.localScale = Vector3.one
            obj.transform.localRotation = Quaternion.identity
            itemInfo.gameObject = obj.gameObject
            itemInfo.normalText = obj.transform:Find("NormalText"):GetComponent(Text)
            itemInfo.normalText.color = Color(232/255, 250/255, 255/255, 1)
            itemInfo.discountIcon = obj.transform:Find("DiscountIcon"):GetComponent(Image)
            itemInfo.discountText = itemInfo.discountIcon.transform:Find("Text"):GetComponent(Text)

            self.discountList[i] = itemInfo
        end

        itemInfo.gameObject.transform.localPosition = Vector3(self.discountPosXTemp.beginPos + self.discountPosXTemp.lengthMax * v.need_num / maxNeedNum, -45, 0)
        itemInfo.gameObject:SetActive(true)
        local text = string.format(TI18N("%s折"), math.floor(v.id / 10) / 10)
        itemInfo.normalText.text = text
        itemInfo.discountText.text = text
        if self.data.discount == v.id then
            itemInfo.normalText.gameObject:SetActive(false)
            itemInfo.discountIcon.gameObject:SetActive(true)

            if self.index == 1 then
                if itemInfo.effectObj == nil then
                    itemInfo.effectObj = BaseUtils.ShowEffect(20199, itemInfo.discountIcon.transform, Vector3.one, Vector3(0, 0, -50))
                else
                    itemInfo.effectObj:SetActive(true)
                end
            end
        else
            itemInfo.normalText.gameObject:SetActive(true)
            itemInfo.discountIcon.gameObject:SetActive(false)

            if itemInfo.effectObj ~= nil then
                itemInfo.effectObj:SetActive(false)
            end
        end
    end
end

function DoubleElevenGroupBuyItem:ClickSlot()
    -- local data = DataCampaignGroupPurchase.data_gift_show_item[self.data.base_id]



    if self.giftPreview == nil then
        self.giftPreview = GiftPreview.New(self.mainWindow.gameObject)
    end

    --local rewardList = {{20020,25},{20021,10}}
    --local rewardList1 = {{20020,25},{20021,10},{20022,2},{29086,1},{20022,2},{29086,1},{20022,2},{29086,1},{20022,2},{29086,1},{20022,2},{29086,1}}
    --self.giftPreview:Show({reward = rewardList, autoMain = true, text = "使用必定获得以下所有道具:"})

    local list = {}
    if #self.data.list1 > 0 then
        for k,v in ipairs(self.data.list1) do
            table.insert(list,{v.base_id, v.num})
        end
        self.giftPreview:Show({reward = list, autoMain = true, text = "使用必定获得以下所有道具:"})
    elseif #self.data.list2 > 0 then
        for k,v in ipairs(self.data.list2) do
            table.insert(list,{v.base_id, v.num})
        end
        self.giftPreview:Show({reward = CampaignManager.ItemFilter(list), autoMain = true, text = "打开可随机获得以下任一道具:"})
    else
        TipsManager.Instance:ShowItem({gameObject = self.itemSlot.gameObject, itemData = DataItem.data_get[self.data.base_id]})
    end
end

