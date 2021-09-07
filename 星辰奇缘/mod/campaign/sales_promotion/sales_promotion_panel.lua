SalesPromotionPanel = SalesPromotionPanel or BaseClass(BasePanel)

function SalesPromotionPanel:__init(parent)

    self.parent = parent
    self.name = "SalesPromotionPanel"
    self.mgr = SalesPromotionManager.Instance
    self.model = self.mgr.model


    self.resList = {
        {file = AssetConfig.sales_promotion_panel, type = AssetType.Main}
       ,{file = AssetConfig.sales_promotion_texture, type = AssetType.Dep}
       --,{file = AssetConfig.playkillbgcycle, type = AssetType.Dep}
       ,{file = AssetConfig.effectbg2, type = AssetType.Dep}

       ,{file = AssetConfig.playkillbg_yellow, type = AssetType.Dep}
       ,{file = AssetConfig.LunarypreferenceTopTitleI18N, type = AssetType.Dep}
    }
    
    for _, v in ipairs(DataCampSalesPromotion.data_pack_icon) do
        table.insert( self.resList, {file = string.format(AssetConfig.pack, v.iconid ), type = AssetType.Dep})
    end

    self.itemList = {}
    self.goldBuyNum = 0
    self.onbuy = function ()
        self:SetStatus()
    end
    self.onfresh = function ()
        self:SetBase()
        self:SetStatus()
        self.mgr.opened = true
    end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function SalesPromotionPanel:__delete()
    self:OnHide()

    if self.possibleReward ~= nil then
        self.possibleReward:DeleteMe()
        self.possibleReward = nil
    end

    for i=1,3 do
        if self.itemList[i] ~= nil then
            if self.itemList[i].slot ~= nil then
                self.itemList[i].slot:DeleteMe()
                self.itemList[i].slot = nil

                self.itemList[i].itemBgImg.sprite = nil
                self.itemList[i].lightImg.sprite = nil
            end
        end
    end

    self.itemList = nil

    if self.packImg ~= nil and self.packImg.sprite ~= nil then
        self.packImg.sprite = nil
    end

    if self.packBgImg ~= nil and self.packBgImg.sprite ~= nil then
        self.packBgImg.sprite = nil
    end

    self:AssetClearAll()
end



function SalesPromotionPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.sales_promotion_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent,self.gameObject)
    UIUtils.AddBigbg(t:Find("BigBg"), GameObject.Instantiate(self:GetPrefab(self.bg)))
    t:Find("TopTitle"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.LunarypreferenceTopTitleI18N, "LunarypreferenceTopTitleI18N")
    t:Find("TopTitle").anchoredPosition = Vector2(-150, 171)

    self.payButton = t:Find("BuyButton"):GetComponent(CustomButton)
    self.payButton.onClick:AddListener(function() self:OnBuy() end)
    self.payButton.onHold:AddListener(function() self:OnNumberpad() end)
    self.payButton.onDown:AddListener(function() self:OnDown() end)
    self.payButton.onUp:AddListener(function() self:OnUp() end)

    self.payImg = t:Find("BuyButton"):GetComponent(Image)
    self.payTxt = t:Find("BuyButton/Text"):GetComponent(Text)

    self.pack = t:Find("Pack/Image"):GetComponent(Button)
    self.packImg = t:Find("Pack/Image"):GetComponent(Image)
    -- self.packImg.sprite = self.assetWrapper:GetSprite(AssetConfig.pack_eight, "pack8")
    self.packBgImg = t:Find("Pack"):GetComponent(Image)
    self.packBgImg.sprite = self.assetWrapper:GetSprite(AssetConfig.playkillbg_yellow, "Playkillbg_yellow")
    self.soldout = t:Find("Pack/soldout").gameObject
    -- self.pack_bag = t:Find("Pack/Image"):GetComponent(Image)


    self.numberpadSetting = {               -- 弹出小键盘的设置
        gameObject = self.payButton.gameObject,
        min_result = 1,
        max_by_asset = 10,
        max_result = 10,
        textObject = nil,
        show_num = false,
        returnKeep = true,
        funcReturn = function(num) self.goldBuyNum = num  self:OnBuy()  end,
        callback = nil,
        show_num = true,
        returnText = TI18N("购买"),
    }

    local campData = DataCampaign.data_list[self.campId]

    t:Find("Time"):GetComponent(Text).text = string.format("活动时间:%s月%s日-%s月%s日", campData.cli_start_time[1][2],campData.cli_start_time[1][3],campData.cli_end_time[1][2],campData.cli_end_time[1][3])

    t:Find("Notice"):GetComponent(Button).onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = t:Find("Notice").gameObject, itemData = {TI18N("长按购买可以批量购买")}}) end)

    for i=1,3 do
        self.itemList[i] = {}
        local item = t:Find("Reward"..i)
        --self.itemList[i].discount = item:Find("discount"):GetComponent(Text)
        self.itemList[i].reward = item:GetComponent(Image)
        self.itemList[i].reward.sprite = self.assetWrapper:GetSprite(AssetConfig.sales_promotion_texture, "rewardBg")
        self.itemList[i].get = item:Find("get/Text"):GetComponent(Text)
        self.itemList[i].item = item:Find("itembg/item")
        self.itemList[i].itemBgImg = item:Find("itembg"):GetComponent(Image)
        self.itemList[i].itemBgImg.sprite = self.assetWrapper:GetSprite(AssetConfig.playkillbg_yellow, "Playkillbg_yellow")
        self.itemList[i].lightImg = item:Find("light"):GetComponent(Image)
        self.itemList[i].lightImg.sprite = self.assetWrapper:GetSprite(AssetConfig.effectbg2, "EffectBg2")
        item:Find("light").localScale = Vector3(1.3, 1.3, 1)
    end

    self.price = t:Find("Price/Text"):GetComponent(Text)
    self.count = t:Find("Count"):GetComponent(Text)

    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end

    self.effTimerId = LuaTimer.Add(1000, 3000, function()
            self.packImg.gameObject.transform.localScale = Vector3(1.2,1.1,1)
            Tween.Instance:Scale(self.packImg.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
        end)

end

function SalesPromotionPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end


function SalesPromotionPanel:OnOpen()
    self:RemoveListeners()
    self:AddListeners()
    self.goldBuyNum = 1
    self:SetBase()
    self:SetStatus()
    self.mgr.opened = true
    CampaignManager.Instance.model:CheckActiveRed(self.campId)
end

function SalesPromotionPanel:OnHide()
    self:RemoveListeners()

    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end

    if self.arrowEffect ~= nil then
        self.arrowEffect.gameObject:SetActive(false)
    end
end

function SalesPromotionPanel:AddListeners()
    self.mgr.onBuy:AddListener(self.onbuy)
    self.mgr.onFresh:AddListener(self.onfresh)
end


function SalesPromotionPanel:RemoveListeners()
    self.mgr.onBuy:RemoveListener(self.onbuy)
    self.mgr.onFresh:RemoveListener(self.onfresh)
end

function SalesPromotionPanel:ShowReward()
    if self.model.promotion == nil then
        return
    end
    local data = self.model.rewardList
    local itemShow = {}
    for k,v in pairs(data) do
        local temp = {}
        temp.item_id = v.item_id2
        temp.num = v.num2
        temp.is_effet = v.spec_effects
        table.insert(itemShow,temp)
    end

    local callBack = function(myself) myself.gameObject.transform.localPosition = Vector3(myself.gameObject.transform.localPosition.x,myself.gameObject.transform.localPosition.y,200) end
    if self.possibleReward == nil then
        self.possibleReward = SevenLoginTipsPanel.New(self,callBack)
    end
    self.possibleReward:Show({itemShow,4,{130,130,100,120},self.model.title})
end

function SalesPromotionPanel:OnNumberpad()
    if self.model.promotion == nil then
        return
    end
    if self.model.purchased_num < self.model.num then
        self.numberpadSetting.max_result = self.model.num - self.model.purchased_num
        self.numberpadSetting.max_by_asset = self.model.num - self.model.purchased_num
        NumberpadManager.Instance:set_data(self.numberpadSetting)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("今日的特惠礼包已售罄，请明天再来{face_1,3}"))
    end
end

function SalesPromotionPanel:OnBuy()
    if self.model.promotion == nil then
        return
    end
    if self.model.purchased_num < self.model.num then
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.content = string.format("是否确认消耗<color='#00ff00'>%s</color>{assets_2,90002}购买<color='#00ff00'>%s</color>个<color='#ffff00'>%s</color>?",self.goldBuyNum*self.model.price ,self.goldBuyNum,self.model.name)
        confirmData.sureSecond = -1
        confirmData.cancelSecond = -1
        confirmData.sureLabel = TI18N("确认")
        confirmData.cancelLabel = TI18N("取消")
        confirmData.sureCallback = function()
            self.mgr:Send20408(self.model.item_id,self.goldBuyNum)
        end
        NoticeManager.Instance:ConfirmTips(confirmData)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("今日的特惠礼包已售罄，请明天再来{face_1,3}"))
    end
end

function SalesPromotionPanel:OnDown()
    if self.model.promotion == nil then
        return
    end
    if self.model.purchased_num < self.model.num then
        self.isUp = false
        LuaTimer.Add(150, function()
            if self.isUp ~= false then
                return
            end
            if self.arrowEffect == nil then
                self.arrowEffect = BibleRewardPanel.ShowEffect(20009, self.payButton.gameObject.transform, Vector3(1, 1, 1), Vector3(0, 61, -400))
            else
                if not BaseUtils.is_null(self.arrowEffect.gameObject) then
                    self.arrowEffect.gameObject:SetActive(false)
                    self.arrowEffect.gameObject:SetActive(true)
                end
            end
        end)
    end
end

function SalesPromotionPanel:OnUp()
    if self.model.promotion == nil then
        return
    end
    if self.model.purchased_num < self.model.num then
        self.goldBuyNum = 1
        self.isUp = true
        if self.arrowEffect ~= nil then
            self.arrowEffect:DeleteMe()
            self.arrowEffect = nil
        end
    end
end

function SalesPromotionPanel:SetBase()
    if self.model.promotion == nil then
        return
    end
    self.pack.onClick:RemoveAllListeners()
    self.pack.onClick:AddListener(function ()
        self:ShowReward()
    end)
    self.price.text = self.model.price

    for i=1,3 do
        if self.itemList[i].slot == nil then
            self.itemList[i].slot = ItemSlot.New()
            UIUtils.AddUIChild(self.itemList[i].item, self.itemList[i].slot.gameObject)
        end
        local itemBaseData = BackpackManager.Instance:GetItemBase(self.model.promotion[i].present_id)
        local itemData = ItemData.New()
        itemData:SetBase(itemBaseData)
        self.itemList[i].slot:SetAll(itemData,{nobutton=true})
        --self.itemList[i].discount.text = string.format(TI18N("买%s送  <color='#fff100'>%s</color>"), self.model.promotion[i].cost_num,self.model.promotion[i].present_num)
    end
end

function SalesPromotionPanel:SetStatus()
    if self.model.promotion == nil then
        return
    end
    self.count.text = string.format(TI18N("今日剩余：<color='#fff45c'>%s/%s</color>"), 10-self.model.purchased_num,self.model.num)

    local baseTime = BaseUtils.BASE_TIME
    local campData = DataCampaign.data_list[self.campId]
    local beginTimeData = campData.cli_start_time[1]
    local endTimeData = campData.cli_end_time[1]
    local beginTime = tonumber(os.time{year = beginTimeData[1], month = beginTimeData[2], day = beginTimeData[3], hour = beginTimeData[4], min = beginTimeData[5], sec = beginTimeData[6]})
    local endTime = tonumber(os.time{year = endTimeData[1], month = endTimeData[2], day = endTimeData[3], hour = endTimeData[4], min = endTimeData[5], sec = endTimeData[6]})



    self.packImg.sprite = self.assetWrapper:GetSprite(string.format(AssetConfig.pack, DataCampSalesPromotion.data_pack_icon[1].iconid), "pack"..DataCampSalesPromotion.data_pack_icon[1].iconid)
    
    if baseTime >= (beginTime + 86400) and baseTime <= (beginTime + 86400 * 2) then
        self.packImg.sprite = self.assetWrapper:GetSprite(string.format(AssetConfig.pack, DataCampSalesPromotion.data_pack_icon[2].iconid), "pack"..DataCampSalesPromotion.data_pack_icon[2].iconid)
    elseif baseTime > (beginTime + 86400 * 2) and baseTime <= endTime then
        self.packImg.sprite = self.assetWrapper:GetSprite(string.format(AssetConfig.pack, DataCampSalesPromotion.data_pack_icon[3].iconid), "pack"..DataCampSalesPromotion.data_pack_icon[3].iconid)
    end

    for i=1,3 do
        if self.model.purchased_num < self.model.promotion[i].cost_num then
            self.itemList[i].get.text = TI18N("<color='##defbff'>未达成</color>")
        else
            self.itemList[i].get.text = TI18N("<color='#fff799'>已达成</color>")
        end
    end
    if self.model.purchased_num < self.model.num then
        self.soldout:SetActive(false)
        self.payTxt.text = TI18N("购买")
        self.payImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
    else
        self.soldout:SetActive(true)
        self.payTxt.text = TI18N("已购买")
        self.payImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
    end
end
