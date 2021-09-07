WarmHeartGiftWindow = WarmHeartGiftWindow or BaseClass(BaseWindow)

function WarmHeartGiftWindow:__init(model)
	self.model = model

	self.resList = {
	   {file = AssetConfig.WarmHeartGift_window,type = AssetType.Main,holdTime = 5}
	  ,{file = AssetConfig.WarmHeartGift_textures,type = AssetType.Dep}
	  ,{file = AssetConfig.WarmHeartGiftBigbg,type = AssetType.Dep}
      ,{file = AssetConfig.WarmHeartGiftbottombg,type = AssetType.Main}
    }

    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.windowId = WindowConfig.WinID.warmheartgift_window

    self.updateListener = function() self:SetSaleData() end
    self.extra = {inbag = false, nobutton = true}

    self.itemList = {}
    self.itemEffectList = {}

    self.SaleOut = 0  --是否售罄，未售罄

    self.campId = 1389
end

function WarmHeartGiftWindow:__delete()
    self:RemoveListeners()
    if self.effTimerId ~= nil then
		LuaTimer.Delete(self.effTimerId)
		self.effTimerId = nil
    end

    if self.DelTimerId ~= nil then
		LuaTimer.Delete(self.DelTimerId)
		self.DelTimerId = nil
    end

    

    if self.itemEffectList ~= nil then
        for i,v in ipairs(self.itemEffectList) do
          v:DeleteMe()
        end
        self.itemEffectList = {nil}
     end

    if self.itemList ~= nil then
     	for i,v in ipairs(self.itemList) do
     		v:DeleteMe()
     	end
     	self.itemList = {}
    end

     if self.itemLayout ~= nil then
     	self.itemLayout:DeleteMe()
     end
    
     if self.gameObject ~= nil then
     	GameObject.DestroyImmediate(self.gameObject)
     	self.gameObject = nil
     end
     self:AssetClearAll()

end

function WarmHeartGiftWindow:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.WarmHeartGift_window))
	self.gameObject.name = "WarmHeartGiftWindow"

	UIUtils.AddUIChild(ctx.CanvasContainer,self.gameObject)
	local t = self.gameObject.transform
	self.transform = t
	self.bigBgImg  = t:Find("MainCon/Bg/BigBg/BackGround"):GetComponent(Image)
    self.bigBgImg.sprite =self.assetWrapper:GetSprite(AssetConfig.WarmHeartGiftBigbg,"WarmHeartGiftBigbg")
	t:Find("MainCon/CloseButton"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)


    self.Dianum = t:Find("MainCon/Bg/TextBg/Num"):GetComponent(Text)
    self.Dianum.transform.anchoredPosition = Vector2(10.5, 0.5)
    self.Dianum.transform.sizeDelta = Vector2(61, 31)
    self.DiaIcon = t:Find("MainCon/Bg/TextBg/Dia"):GetComponent(Image)
    self.DiaIcon.transform.anchoredPosition = Vector2(57, 0)

    self.giftIcon = t:Find("MainCon/GiftIcon"):GetComponent(Image)

    self.confirmBtn = t:Find("MainCon/ConfirmButton"):GetComponent(Button)
    self.confirmBtn.onClick:AddListener(function() self:ApplyButton() end)
    self.confirmBtnBg = t:Find("MainCon/ConfirmButton"):GetComponent(Image)
    self.confirmBtnTxt = t:Find("MainCon/ConfirmButton/Icon"):GetComponent(Image)

    self.SaleOutTag = t:Find("MainCon/SaleOutTag")
    self.SaleOutTag.gameObject:SetActive(false)

    self.ItemContainer = t:Find("MainCon/ItemContainer")

	self.rewardBg = self.ItemContainer:Find("RewardBg")
	UIUtils.AddBigbg(self.rewardBg, GameObject.Instantiate(self:GetPrefab(AssetConfig.WarmHeartGiftbottombg)))
	--self.bigTextBg.transform.anchoredPosition = Vector2(0,0)

	self.scrollRectRtr = self.ItemContainer:Find("ScrollRect"):GetComponent(RectTransform)
    self.scrollRectTT = self.ItemContainer:Find("ScrollRect"):GetComponent(ScrollRect)
    self.scrollRectTT.onValueChanged:AddListener(function(value)  self:OnRectScroll(value)  end)
    self.ItemContainer2 = self.ItemContainer:Find("ScrollRect/ImageContainer")

    self.itemLayout = LuaBoxLayout.New(self.ItemContainer2.gameObject,{axis = BoxLayoutAxis.X, border = 5})

    self.DeyTimeText = t:Find("MainCon/DelayTime/Time"):GetComponent(Text)

	self:OnOpen()
end

function WarmHeartGiftWindow:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.campaign_change, self.updateListener)

    if self.openArgs ~= nil then
        self.campId = self.openArgs.campId
    end
    self:SetItemData()
    self:SetPrice()
    self:SetTimes()
    self:SetSaleData()
    LuaTimer.Add(200, function() self:OnRectScroll({x = 0}) end)
end

function WarmHeartGiftWindow:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.campaign_change, self.updateListener)
end


function WarmHeartGiftWindow:SetItemData()
    print(self.campId)
    local data = DataCampaign.data_list[self.campId].rewardgift
    self.itemDataList = CampaignManager.Instance.ItemFilter(data)

    for i,v in pairs(self.itemDataList) do
    	local id = v[1]
        local num = v[2]
        local isShowEffect = v[3]
        local ItemData = DataItem.data_get[id]
    	if self.itemList[i] ~= nil then
    	    self.itemList[i].gameObject:SetActive(true)
    	    self.itemList[i]:SetAll(ItemData, self.extra)
    	    self.itemList[i]:SetNum(num)
    	else
    		local itemSlot = ItemSlot.New()
    		itemSlot:SetAll(ItemData, self.extra)
    		itemSlot:SetNum(num)
    		self.itemList[i] = itemSlot
    		self.itemLayout:AddCell(itemSlot.gameObject)
    	end

        --特效
        if isShowEffect == 1 then
            if self.itemEffectList[i] == nil then
                  --self.itemEffectList[i] = BibleRewardPanel.ShowEffect(20223,self.itemList[i].transform, Vector3(1, 1, 1), Vector3(32,0, -400))
                  self.itemEffectList[i] = self.itemList[i]:ShowEffect(true,20223)
            else
                self.itemEffectList[id]:SetActive(true)
            end
        else
            if self.itemEffectList[i] ~= nil then
                self.itemEffectList[i]:SetActive(false)
            end
        end
    end

    local CurrNum = #self.itemDataList
    for j = CurrNum + 1, #self.itemList do
        self.itemList[j].gameObject:SetActive(false)
    end
end

function WarmHeartGiftWindow:SetPrice()
    local data = DataCampaign.data_list[self.campId].loss_items[1]
    if data ~= nil then
        self.DiaIcon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets"..data[1])
        self.Dianum.text = tostring(data[2])
    end
end

function WarmHeartGiftWindow:SetTimes()
    local nowTime = BaseUtils.BASE_TIME
    local data = DataCampaign.data_list[self.campId]
    local start_time = data.cli_start_time[1]
    local end_time = data.cli_end_time[1]
    local Cstart_time = tonumber(os.time{year = start_time[1], month = start_time[2], day = start_time[3], hour = start_time[4], min = start_time[5], sec = start_time[6]}) or 0
    local Cend_time = tonumber(os.time{year = end_time[1], month = end_time[2], day = end_time[3], hour = end_time[4], min = end_time[5], sec = end_time[6]})
    local delayTimes = Cend_time - nowTime
    --倒计时
    print(delayTimes)
    if self.DelTimerId == nil then
        self.DelTimerId = LuaTimer.Add(10, 1000, function()
            if delayTimes > 0 then
                delayTimes = delayTimes - 1
                self.DeyTimeText.text = string.format(TI18N("%d时%d分"), math.floor(delayTimes/3600), math.floor(delayTimes%3600/60))
                --self.DeyTimeText.text = string.format(TI18N("%d时%d分"), tonumber(os.date("%H", delayTimes)),tonumber(os.date("%M", delayTimes)))
            else
                self.DeyTimeText.text = TI18N("0时0分")
            end
        end)
   end
end

function WarmHeartGiftWindow:SetSaleData()
    local data = CampaignManager.Instance.campaignTab[self.campId]
    if data.status == 2 then
        --已经购买过
        self.SaleOut = 1
        self.confirmBtnBg.sprite = self.assetWrapper:GetSprite(AssetConfig.WarmHeartGift_textures, "ButtonBg2")
        self.confirmBtnTxt.sprite = self.assetWrapper:GetSprite(AssetConfig.WarmHeartGift_textures, "buyButton2")
        self.confirmBtnTxt.transform.sizeDelta = Vector2(89, 36)
        self.SaleOutTag.gameObject:SetActive(true)
        if self.effTimerId ~= nil then
            LuaTimer.Delete(self.effTimerId)
            self.effTimerId = nil
        end
    else
        self.SaleOut = 0
        self.confirmBtnBg.sprite = self.assetWrapper:GetSprite(AssetConfig.WarmHeartGift_textures, "ButtonBg1")
        self.confirmBtnTxt.sprite = self.assetWrapper:GetSprite(AssetConfig.WarmHeartGift_textures, "buyButton")
        self.confirmBtnTxt.transform.sizeDelta = Vector2(114, 34)
        self.SaleOutTag.gameObject:SetActive(false)
        --购买按钮特效
        if self.effTimerId == nil then
            self.effTimerId = LuaTimer.Add(1000, 3000, function()
                self.confirmBtn.gameObject.transform.localScale = Vector3(1.1,1.1,1)
                Tween.Instance:Scale(self.confirmBtn.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
            end)
        end
    end
end



function WarmHeartGiftWindow:ApplyButton()
    if self.campId ~= nil then
        if self.SaleOut == 1 then
            NoticeManager.Instance:FloatTipsByString(TI18N("该商品已售罄"))
            return
        end
        CampaignManager.Instance:Send14001(self.campId)
    end
    --WindowManager.Instance:CloseWindow(self)
end

function WarmHeartGiftWindow:OnRectScroll(value)
    local Left = 5
    local Right = 150 + 74
    for i,v in ipairs(self.itemList) do
        local ax = v.transform.anchoredPosition.x + self.ItemContainer2.anchoredPosition.x
        if ax > Right or ax < Left then
            if v.effect ~= nil then
                v.effect:SetActive(false)
            end
        else
            if v.effect ~= nil then
                v.effect:SetActive(true)
            end
        end
    end
end
