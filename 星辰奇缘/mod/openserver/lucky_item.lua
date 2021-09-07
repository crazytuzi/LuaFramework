LuckyItem = LuckyItem or BaseClass()

function LuckyItem:__init(model, gameObject, img, haseffect)
    self.model = model
    self.gameObject = gameObject
    self.assetWrapper = assetWrapper
    self.effect = nil

    local t = gameObject.transform
    self.nameText = t:Find("Name"):GetComponent(Text)
    self.descText = t:Find("Desc"):GetComponent(Text)
    self.timesText = t:Find("Times"):GetComponent(Text)
    self.luckyObj = t:Find("Image").gameObject
    self.btn = gameObject:GetComponent(Button)

    self.luckyObj.transform:GetComponent(Image).sprite = img
    self.luckyObj.transform.sizeDelta = Vector2(120, 120)
    self.luckyObj.transform.anchoredPosition3D = Vector2(0, 0)
    -- UIUtils.AddBigbg(self.luckyObj.transform, obj)
    -- obj.transform.anchoredPosition = Vector2(-30.6,40.7)
    -- obj.transform.localScale = Vector3(90/100, 90/100, 1)
    if haseffect then
        local funTemp = function(effectView)
            local effectObject = effectView.gameObject

            effectObject.transform:SetParent(self.luckyObj.transform)
            effectObject.transform.localScale = Vector3(1, 1, 1)*0.5
            effectObject.transform.localPosition = Vector3(-2.8, -61.4, -400)
            effectObject.transform.localRotation = Quaternion.identity

            Utils.ChangeLayersRecursively(effectObject.transform, "UI")
            effectObject:SetActive(true)
        end
        self.effect = BaseEffectView.New({effectId = 20241, time = nil, callback = funTemp})
    end
end

function LuckyItem:SetData(data, index)
    -- local luckyProgress = self.model.luckyProgress[data.id]
    local campaignData = CampaignManager.Instance.campaignTab[data.id]
    self.data = data
    -- if luckyProgress == nil then
        local luckyProgress = {0,20}
    -- end
    self.nameText.text = data.conds
    self.descText.text = data.cond_desc
    self.timesText.text = TI18N("奖励次数:<color=#00FF00>")..tostring(campaignData.reward_max - campaignData.reward_can).."</color>/"..tostring(campaignData.reward_max)
    self.btn.onClick:RemoveAllListeners()
    self.btn.onClick:AddListener(function() self:ShowReward() end)
    if index == 3 then
        if self.effect == nil then
            -- self.effect = BibleRewardPanel.ShowEffect(20154, self.luckyObj.transform, Vector3(0.68, 0.65,1), Vector3(-2.01,-89.27,-400))
        end
    end
end

function LuckyItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function LuckyItem:__delete()
    self.luckyObj.transform:GetComponent(Image).sprite = nil
    self.btn.onClick:RemoveAllListeners()
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
end

function LuckyItem:ShowReward()
    if self.data == nil then return end

    if self.model.mainWin ~= nil then
        if self.model.giftPreview == nil then
            self.model.giftPreview = GiftPreview.New(self.model.mainWin.gameObject)
        end
        self.model.giftPreview:Show({reward = self.data.rewardgift, autoMain = true, text = TI18N("随机获得以下道具其中一个"), width = 120, height = 120})
    end
end
