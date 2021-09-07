ShopRechargeItem = ShopRechargeItem or BaseClass()

function ShopRechargeItem:__init(model, gameObject, assetWrapper, callback)
    self.model = model
    self.gameObject = gameObject
    self.assetWrapper = assetWrapper
    self.callback = callback

    local t = self.gameObject.transform

    self.diamondImage = t:Find("Diamonds"):GetComponent(Image)
    self.moneyText = t:Find("Money"):GetComponent(Text)
    self.moneyIcon = t:Find("Money/Icon"):GetComponent(Image)
    self.assetText = t:Find("AssetBg/Asset"):GetComponent(Text)
    self.tokes = t:Find("Tokes")
    self.tokesImage = t:Find("Tokes"):GetComponent(Image)



    self.tokesCurrencyLoader = SingleIconLoader.New(t:Find("Tokes/Image").gameObject)
    self.tokesText = t:Find("Tokes/Value"):GetComponent(Text)
    self.tokesTextImage = t:Find("Tokes/TextImg"):GetComponent(Image)
    self.tipsLabelObj = t:Find("TipsLabel").gameObject


    self.tipsSecondLabelTr = t:Find("TipsSecondLabel")
    self.tipsSecondLabelText = t:Find("TipsSecondLabel/Text"):GetComponent(Text)
    self.tipsSecondLabelTr.gameObject:SetActive(false)
    self.btn = gameObject:GetComponent(Button)

    self.isFirstRecharge = true
    self.rebateNum = 0
    self.rebateObject = t:Find("RebateTokes")
    self.rebateText1 = t:Find("RebateTokes/Value1"):GetComponent(Text)
    self.rebateText2 = t:Find("RebateTokes/Value2"):GetComponent(Text)

end

function ShopRechargeItem:SetData(data, index ,num,rebateData)
    self.rebateNum = 0
    local model = self.model
    if BaseUtils.GetLocation() == KvData.localtion_type.sg then
        self.moneyText.text = tostring(data.rmb / 100)
        self.moneyIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.shop_textures, "MoneyIcon_dl")
    else
        self.moneyText.text = tostring(data.rmb)
        self.moneyIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.shop_textures, "MoneyIcon_cn")
    end
    self.assetText.text = tostring(data.gold)
    self.btn.onClick:RemoveAllListeners()
    self.btn.onClick:AddListener(function() self.callback(self.model.chargeList[index]) end)
    self.diamondImage.sprite = self.assetWrapper:GetSprite(AssetConfig.shop_textures, "Excharge"..tostring(math.ceil(6 / #self.model.chargeList * index)))
    self.tokesCurrencyLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90002"))
    self.tokesImage.sprite = self.assetWrapper:GetSprite(AssetConfig.shop_textures, "Tokes")
    if data.tokes ~= nil and data.tokes > 0 then
        self.tokesImage.gameObject:SetActive(true)
        self.tokesText.text = tostring(data.tokes)
        self.rebateNum = data.tokes
    else
        self.tokesImage.gameObject:SetActive(false)
    end

    model.rechargeLog = model.rechargeLog or {}
    model.rechargeLogRed = model.rechargeLogRed or {}
    self.tokesTextImage.sprite = self.assetWrapper:GetSprite(AssetConfig.shop_textures, "Give_I18N_Normal")


    -- 首充
    if model.rechargeLogRed[data.gold] == nil and not ShopManager.Instance.openThreeCharge then
        self.tipsLabelObj:SetActive(true)
        self.tokesText.text = tostring(data.gold)
        self.tokesImage.sprite = self.assetWrapper:GetSprite(AssetConfig.shop_textures, "Tokes1")
        self.tokesTextImage.sprite = self.assetWrapper:GetSprite(AssetConfig.shop_textures, "Give_I18N")
        self.tokesCurrencyLoader:SetOtherSprite(self.assetWrapper:GetSprite(AssetConfig.shop_textures, "RedEdge"))
        self.isFirstRecharge = true
    elseif model.rechargeLog.open_time == nil or model.rechargeLog.open_time > BaseUtils.BASE_TIME then
        self.tipsLabelObj:SetActive(false)
        self.isFirstRecharge = false
    elseif model.rechargeLog[data.gold] == nil then
        self.tipsLabelObj:SetActive(true)
        self.tokesText.text = tostring(data.gold)
        self.tokesCurrencyLoader:SetSprite(SingleIconType.Item, 90002)
    else
        self.tipsLabelObj:SetActive(false)
        self.isFirstRecharge = false
    end

   local chanleId = ctx.PlatformChanleId
   if DataRecharge.data_turn_score[string.format("%s_%s",data.gold,chanleId)] == nil then
       chanleId = 0
   end

   if  DataRecharge.data_turn_score[string.format("%s_%s",data.gold,chanleId)] ~= nil and DataRecharge.data_turn_score[string.format("%s_%s",data.gold,chanleId)].tokes ~= 0 and self:CheckRechargeTab() == true then
       self:SetLabelNum(DataRecharge.data_turn_score[string.format("%s_%s",data.gold,chanleId)].tokes)
   end


   ----------------------------------------- 充值返利新功能


   -- if num > 0 then
   --      if self.isFirstRecharge == true and rebateData ~= nil then
   --          if rebateData.camp_cond[1][4] == 1 then
   --               self.rebateText1:GetComponent(Text).text = tostring(data.gold)
   --               self.rebateText2:GetComponent(Text).text = tostring(rebateData.camp_cond[1][2])
   --               self.rebateObject.gameObject:SetActive(true)
   --               self.tokesImage.transform:GetComponent(RectTransform).anchoredPosition = Vector2(-50,10)
   --               self.tokesImage.gameObject:SetActive(false)
   --          elseif rebateData.camp_cond[1][4] == 2 then
   --              self.rebateObject.gameObject:SetActive(false)
   --              self.tokesImage.gameObject:SetActive(true)
   --              self.tokesText.text = tostring(data.gold + rebateData.camp_cond[1][2])
   --          end
   --      else
   --          if rebateData.camp_cond[1][4] == 1 then
   --              self.rebateObject.gameObject:SetActive(false)
   --              self.tokesImage.transform:GetComponent(RectTransform).anchoredPosition = Vector2(45,10)
   --              self.tokesImage.gameObject:SetActive(true)
   --              self.tokesText.text = tostring(rebateData.camp_cond[1][2] + self.rebateNum)
   --          elseif rebateData.camp_cond[1][4] == 2 then
   --              self.rebateObject.gameObject:SetActive(true)
   --              self.tokesImage.gameObject:SetActive(false)
   --              self.rebateText1:GetComponent(Text).text = tostring(rebateData.camp_cond[1][2])
   --              self.rebateText2:GetComponent(Text).text = tostring(self.rebateNum)
   --          end
   --      end
   -- else
   --      self.rebateObject.gameObject:SetActive(false)
   --      self.tokesImage.transform:GetComponent(RectTransform).anchoredPosition = Vector2(45,10)
   --      self.tokesImage.gameObject:SetActive(true)
   --  end



    -- for i=1,self.tokes.childCount do
    --     self.tokes:GetChild(i-1).gameObject:SetActive(false)
    -- end
    -- self.tokesImage.sprite = self.assetWrapper:GetSprite(AssetConfig.shop_textures, "I18NFirstCharge")

    -- self.tipsLabelObj:SetActive(false)

    self:SetActive(true)
end

function ShopRechargeItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function ShopRechargeItem:__delete()
    self.tokesImage.sprite = nil
    self.diamondImage.sprite = nil
    self.moneyIcon.sprite = nil
    self.tokesTextImage.sprite = nil
    self.btn.onClick:RemoveAllListeners()
    self.callback = nil
    self.assetWrapper = nil
    if self.tokesCurrencyLoader ~= nil then
        self.tokesCurrencyLoader:DeleteMe()
        self.tokesCurrencyLoader = nil
    end

    if self.rebateCurrencyLoader ~= nil then
        self.rebateCurrencyLoader:DeleteMe()
        self.rebateCurrencyLoader = nil
    end
end

function ShopRechargeItem:SetLabelNum(num)
    if num > 0 then
      self.tipsSecondLabelText.text = string.format(TI18N("赠送好礼<color='#ffff00'>%s</color>份"),num)
      self.tipsSecondLabelTr.gameObject:SetActive(true)
    end
end

function ShopRechargeItem:CheckRechargeTab()
    local openTime = CampaignManager.Instance.open_srv_time

    local oy = tonumber(os.date("%Y", openTime))
    local om = tonumber(os.date("%m", openTime))
    local od = tonumber(os.date("%d", openTime))


    local beginTime = tonumber(os.time{year = oy, month = om, day = od, hour = 0, min = 00, sec = 0})
    local baseTime = BaseUtils.BASE_TIME
    local distanceTime = baseTime - beginTime
    local d = math.ceil(distanceTime / 86400)

    if d > 14 then
        return true
    end
    return false
end


