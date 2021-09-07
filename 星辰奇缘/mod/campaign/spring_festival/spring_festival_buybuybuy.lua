-- ----------------------------
-- 春节活动-- 礼包购买
-- hosr
-- ----------------------------
BuyBuyBuy = BuyBuyBuy or BaseClass(BasePanel)

function BuyBuyBuy:__init(model, parent, data)
    self.model = model
    self.data = data
    self.parent = parent

    self.path = "prefabs/ui/springfestival/buybuybuy.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = AssetConfig.springfestival_texture, type = AssetType.Dep},
        {file = AssetConfig.shop_textures, type = AssetType.Dep},
    }
    -- self.type = SpringFestivalEumn.Type.BuyBuyBuy
    self.type = 1
    self.index = 1
    self.itemList = {}

    self.OnHideEvent:Add(function() self:OnHide() end)
    self.OnOpenEvent:Add(function() self:OnShow() end)

    self.giftPreview = nil

    self.listener = function() self:UpdateStatus() end

    self.campaignData = nil
end

function BuyBuyBuy:__delete()
    if self.giftPreview ~= nil then
        self.giftPreview:DeleteMe()
        self.giftPreview = nil
    end
    EventMgr.Instance:RemoveListener(event_name.campaign_change, self.listener)
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
end

function BuyBuyBuy:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "BuyBuyBuy"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.talkTxt = self.transform:Find("TalkBg/Text"):GetComponent(Text)
    self.infoBtn = self.transform:Find("InfoBtn"):GetComponent(Button)
    self.infoBtn.gameObject:SetActive(false)

    self.infoBtn.onClick:AddListener(function() self:ClickInfo() end)

    local container = self.transform:Find("Container")
    for i = 1, 3 do
        local transform = container:GetChild(i - 1)
        local item = {}
        item.icon = transform:Find("Bg/Icon"):GetComponent(Image)
        item.bgBtn = transform:Find("Bg"):GetComponent(Button)
        item.last = transform:Find("Last").gameObject
        item.lastTxt = transform:Find("Last/Text"):GetComponent(Text)
        item.lastTxtRect = item.lastTxt.gameObject:GetComponent(RectTransform)
        item.lastIconRect = transform:Find("Last/Text/Icon"):GetComponent(RectTransform)
        item.now = transform:Find("Now").gameObject
        item.nowTxt = transform:Find("Now/Text"):GetComponent(Text)
        item.nowTxtRect = item.nowTxt.gameObject:GetComponent(RectTransform)
        item.nowIconRect = transform:Find("Now/Text/Icon"):GetComponent(RectTransform)
        item.button = transform:Find("Button"):GetComponent(Button)
        item.label = transform:Find("Button/Text"):GetComponent(Text)
        item.buttonImg = item.button.gameObject:GetComponent(Image)

        local index = i
        item.button.onClick:AddListener(function() self:ClickOne(index) end)
        item.bgBtn.onClick:AddListener(function() self:ClickBgItem(index) end)
        table.insert(self.itemList, item)
    end

    self.talkTxt.text = TI18N("三折优惠礼包只能选择其中一个购买,\n《星辰奇缘》祝大家新年快乐!")

    self:OnShow(true)

    EventMgr.Instance:AddListener(event_name.campaign_change, self.listener)
end

function BuyBuyBuy:OnShow(isInit)
    self.dataList = self.data.datalist

    if isInit then
        self:ShowItems()
    end

    self:UpdateStatus()
end

function BuyBuyBuy:ShowItems()
    self.talkTxt.text = ""
    for i,protoData in ipairs(self.dataList) do
        local campaignData = DataCampaign.data_list[protoData.id]
        if self.talkTxt.text == "" then
            self.talkTxt.text = campaignData.cond_desc
        end

        local loss = campaignData.loss_items[1]
        local price = 0
        if loss ~= nil then
            price = loss[2]
        end
        local item = self.itemList[i]
        item.data = campaignData
        item.reward = campaignData.rewardgift
        item.price = tonumber(campaignData.camp_cond_client)
        item.lastTxt.text = string.format(TI18N("价值:%s"), campaignData.camp_cond_client)
        if tonumber(price) == 0 then
            item.nowTxt.text = string.format(TI18N("现价:免费"))
        else
            item.nowTxt.text = string.format(TI18N("现价:%s"), price)
        end

        item.lastTxtRect.sizeDelta = Vector2(item.lastTxt.preferredWidth, 30)
        item.nowTxtRect.sizeDelta = Vector2(item.nowTxt.preferredWidth, 30)

        item.lastTxtRect.anchoredPosition = Vector2(-15, 0)
        item.nowTxtRect.anchoredPosition = Vector2(-15, 0)
    end
end

function BuyBuyBuy:UpdateStatus()
    for i,item in ipairs(self.itemList) do
        local campaignData = item.data
        if self.campaignData == nil then
            self.campaignData = campaignData
        end
        local protoData = CampaignManager.Instance:GetCampaignData(campaignData.id)
        item.protoData = protoData
        if protoData ~= nil then
            if protoData.status == CampaignEumn.Status.Doing then
                item.buttonImg.color = Color(1,1,1,1)
                item.label.text = TI18N("我要购买")
                item.buttonImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            elseif protoData.status == CampaignEumn.Status.Finish then
                item.buttonImg.color = Color(1,1,1,1)
                if i == 1 then
                    item.label.text = TI18N("可领取")
                    item.buttonImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton2")
                else
                    item.label.text = TI18N("<color='#fbfad8'>我要购买</color>")
                    item.buttonImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                end
            elseif protoData.status == CampaignEumn.Status.Accepted then
                item.buttonImg.color = Color(1,1,1,0)
                if i == 1 then
                    item.label.text = TI18N("<color='#ffff00'>已领取</color>")
                else
                    item.label.text = TI18N("<color='#ffff00'>已完成购买</color>")
                end
                item.buttonImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            end
        end
    end
end

function BuyBuyBuy:OnHide()
end

function BuyBuyBuy:ClickOne(index)
    local item = self.itemList[index]
    if item.data ~= nil and item.protoData ~= nil then

        if item.protoData.status == CampaignEumn.Status.Accepted then
            return
        end

        local sure = function()
            CampaignManager.Instance:Send14001(item.data.id)
        end

        if index == 1 then
            sure()
        else
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("限时礼包只能选择其中一个购买，<color='#ffff00'>仅有一次选择机会</color>，请考虑清楚哦！")
            data.sureLabel = TI18N("查看奖励")
            data.cancelLabel = TI18N("我要购买")
            data.sureCallback = function() self:ClickBgItem(index) end
            data.showClose = 1
            data.blueSure = true
            data.greenCancel = true
            data.cancelCallback = sure
            NoticeManager.Instance:ConfirmTips(data)
        end
    end
end

function BuyBuyBuy:ClickBgItem(index)
    local item = self.itemList[index]
    if item.reward ~= nil and #item.reward > 0 then
        if self.giftPreview == nil then
            self.giftPreview = GiftPreview.New(self.model.bibleWin.gameObject)
        end
        self.giftPreview:Show({reward = item.reward, price = item.price})
    end
end

function BuyBuyBuy:ClickInfo()
    local start = self.campaignData.cli_end_time[1]
    local str = string.format(TI18N("%s年%s月%s日%s时"), start[1], start[2], start[3], start[4])
    TipsManager.Instance:ShowText({gameObject = self.infoBtn.gameObject, itemData = {string.format(TI18N("限时礼包购买截止时间为<color='#00ff00'>%s</color>，只能选择一个购买，机会难得不要错过哦！"), str)}})
end
