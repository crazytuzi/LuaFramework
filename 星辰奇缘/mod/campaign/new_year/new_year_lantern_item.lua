NewYearLanternItem = NewYearLanternItem or BaseClass()

function NewYearLanternItem:__init(gameObject, assetWrapper)
    self.gameObject = gameObject
    self.assetWrapper = assetWrapper

    self.transform = gameObject.transform
    self.rechargeString = "%s{assets_2, 90002}"

    local t = self.transform
    self.normal = t:Find("Normal")
    self.extBg = t:Find("Normal/Bg")
    self.extBg:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.newyear_textures, "di")
    --self.extBg.localPosition = Vector3()
    self.extBg.sizeDelta = Vector2(72,30)
    self.extBg.anchoredPosition = Vector2(4, 55)
    self.normalExt = MsgItemExt.New(t:Find("Normal/Text"):GetComponent(Text), 100, 18, 17)
    self.normalImage = self.normal:GetComponent(Image)
    self.arrow = t:Find("Arrow").gameObject
    self.canGetText = self.normal:Find("I18N"):GetComponent(Text)
    self.canGetText.transform.anchoredPosition = Vector2(0, 55)

    --self.extBg.gameObject:SetActive(false)


    self.isDown = false

    self.isLingQu = false

    self.effect2 = false

    gameObject:GetComponent(Button).onClick:AddListener(function() self:OnClick() end)
end

function NewYearLanternItem:__delete()
    self.assetWrapper = nil

    if self.normalExt ~= nil then
        self.normalExt:DeleteMe()
        self.normalExt = nil
    end
    if self.normalImage ~= nil then
        self.normalImage.sprite = nil
        self.normalImage = nil
    end
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
end

function NewYearLanternItem:SetData(data)
    local protoData = data.protoData
    local baseData = data.baseData

    self.protoData = data.protoData
    self.id = baseData.id

    self.normalExt:SetData(string.format(self.rechargeString, baseData.camp_cond_client))
    --self.normalImage.sprite = self.assetWrapper:GetSprite(AssetConfig.newyear_textures, "FutureUnSelect")
    self.transform:Find("Normal/Text"):GetComponent(Text).color = Color(1, 1, 201/255, 1)
    self.normalImage.sprite = self.assetWrapper:GetSprite(AssetConfig.newyear_textures, "NewYearUnSelect")
    self.normalImage:SetNativeSize()
    self.normalExt.contentTrans.anchoredPosition = Vector2(-self.normalExt.contentTrans.sizeDelta.x / 2 + 6, 55)
    --self.extBg.sizeDelta = Vector2(self.normalExt.contentTrans.sizeDelta.x + 4, 20)
    self.canGetText.transform.anchoredPosition = Vector2(0,55)
    self.extBg.gameObject:SetActive(false)
    self.arrow:SetActive(self.isDown)

    if protoData.status == CampaignEumn.Status.Finish then
        self.canGetText.gameObject:SetActive(true)
        self.canGetText.text = TI18N("<color='#00ff00'>可领取</color>")
        self.normalExt.contentTrans.gameObject:SetActive(false)
        self.isLingQu = true
    elseif protoData.status == CampaignEumn.Status.Doing then
        self.canGetText.gameObject:SetActive(false)
        self.normalExt.contentTrans.gameObject:SetActive(true)
        self.isLingQu = false
    else
        self.canGetText.gameObject:SetActive(true)
        self.normalExt.contentTrans.gameObject:SetActive(false)
        self.canGetText.text = TI18N("已领取")
        self.isLingQu = false
    end
    self:ShowEffect(self.isDown)
end

function NewYearLanternItem:OnClick()
    if self.clickCallback ~= nil then
        self.clickCallback()
    end
    self:TweenDown()
end

function NewYearLanternItem:TweenDown()
    if CampaignManager.Instance.campaignTab[self.id].status == CampaignEumn.Status.Finish then
        self.canGetText.gameObject:SetActive(true)
        self.canGetText.text = TI18N("<color='#00ff00'>可领取</color>")
        self.normalExt.contentTrans.gameObject:SetActive(false)
    elseif CampaignManager.Instance.campaignTab[self.id].status == CampaignEumn.Status.Doing then
        self.normalExt.contentTrans.gameObject:SetActive(true)
        self.canGetText.gameObject:SetActive(false)
    else
        self.normalExt.contentTrans.gameObject:SetActive(false)
        self.canGetText.gameObject:SetActive(true)
        self.canGetText.text = TI18N("已领取")
    end
    self.normalExt.contentTrans.anchoredPosition = Vector2(-self.normalExt.contentTrans.sizeDelta.x / 2 + 2,55)
    self.canGetText.transform.anchoredPosition = Vector2(0,55)
    -- self.extBg.anchoredPosition = Vector2(2,72)
    -- self.extBg.sizeDelta = Vector2(72,30)
    self.extBg.gameObject:SetActive(true)
    --self.normalImage.sprite = self.assetWrapper:GetSprite(AssetConfig.newyear_textures, "FutureSelect")
    self.transform:Find("Normal/Text"):GetComponent(Text).color = Color(1, 1, 201/255, 1)
    self.normalImage.sprite = self.assetWrapper:GetSprite(AssetConfig.newyear_textures, "NewYearSelect")
    self.normalImage:SetNativeSize()

    -- if self.tweenId ~= nil then
    --     Tween.Instance:Cancel(self.tweenId)
    -- end
    -- self.isDown = true
    -- self.arrow:SetActive(true)
    -- self.tweenId = Tween.Instance:ValueChange(self.normal.sizeDelta.y, 142, 0.3, function() self.tweenId = nil end, LeanTweenType.easeOutQuad, function(value)
    --         self.normal.sizeDelta = Vector2(116, value)
    --     end).id
    --self.isDown = true
    self.effect2 = true
    -- self:ShowEffect(self.isDown)
end

function NewYearLanternItem:TweenUp()
    if CampaignManager.Instance.campaignTab[self.id].status == CampaignEumn.Status.Finish then
        self.canGetText.gameObject:SetActive(true)
        self.canGetText.text = TI18N("<color='#00ff00'>可领取</color>")
        self.normalExt.contentTrans.gameObject:SetActive(false)
    elseif CampaignManager.Instance.campaignTab[self.id].status == CampaignEumn.Status.Doing then
        self.canGetText.gameObject:SetActive(false)
        self.normalExt.contentTrans.gameObject:SetActive(true)
    else
        self.canGetText.gameObject:SetActive(true)
        self.normalExt.contentTrans.gameObject:SetActive(false)
        self.canGetText.text = TI18N("已领取")
    end

     self.normalExt.contentTrans.anchoredPosition = Vector2(-self.normalExt.contentTrans.sizeDelta.x / 2 + 6, 55)
    self.canGetText.transform.anchoredPosition = Vector2(0,55)
    self.extBg.gameObject:SetActive(false)
    --self.extBg.anchoredPosition = Vector2(2,68)
    self.transform:Find("Normal/Text"):GetComponent(Text).color = Color(1, 1, 201/255, 1)
    self.normalImage.sprite = self.assetWrapper:GetSprite(AssetConfig.newyear_textures, "NewYearUnSelect")
    self.normalImage:SetNativeSize()
    -- self.arrow:SetActive(false)

    -- self.isDown = false
    -- if self.tweenId ~= nil then
    --     Tween.Instance:Cancel(self.tweenId)
    -- end
    -- self.isDown = false
    -- self.tweenId = Tween.Instance:ValueChange(self.normal.sizeDelta.y, 128, 0.3, function() self.tweenId = nil end, LeanTweenType.easeOutQuad, function(value)
    --         self.normal.sizeDelta = Vector2(84, value)
    --     end).id
    self.effect2 = false
    -- self:ShowEffect(self.isDown)
end

function NewYearLanternItem:Hide()
    if self.effect ~= nil then
        self.effect:SetActive(false)
    end
end

function NewYearLanternItem:ShowEffect(bool)
    if bool then
        if self.effect == nil then
            self.effect = BaseUtils.ShowEffect(20410, self.transform, Vector3(0.65, 0.65, 1), Vector3(54, 7, -400))
        else
            self.effect:SetActive(true)
        end
    else
        if self.effect ~= nil then
            self.effect:SetActive(false)
        end
    end
end

