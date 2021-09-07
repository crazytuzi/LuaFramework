-- @author zyh(花朵收集)
-- @date 2017年9月20日

NationalSecondFlowerRewardPanel = NationalSecondFlowerRewardPanel or BaseClass(BasePanel)


function NationalSecondFlowerRewardPanel:__init(parent,parentTr)
    self.parentTr = parentTr
     self.isInit = false
    self.parent = parent
    -- self.parentTr = parentTr
    self.name = "NationalSecondFlowerRewardPanel"
    -- self.Effect = "prefabs/effect/20298.unity3d"
    self.resList = {
        {file = AssetConfig.nationalsecond_reward_panel, type = AssetType.Main}
        ,{file = AssetConfig.guildleaguebig,type = AssetType.Dep}
        ,{file = AssetConfig.combat_uires,type = AssetType.Dep}
    }

    self.itemSlotList = {}
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)


    self.otherItemInitY = -365
    self.extra = {inbag = false, nobutton = true}
    self.tweenIdList = {}
    self.timeIdList  = {}
    self.tweendId = nil
    self.isHasBuy = false

end


function NationalSecondFlowerRewardPanel:OnInitCompleted()

end

function NationalSecondFlowerRewardPanel:__delete()

    self:OnHide()

    if self.itemSlotList ~= nil then
        for i,v in ipairs(self.itemSlotList) do
            v:DeleteMe()
            v = nil
        end
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()

end

function NationalSecondFlowerRewardPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.nationalsecond_reward_panel))
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    self.gameObject.name = "NationalSecondFlowerRewardPanel"
    self.transform = self.gameObject.transform

    self.mainReward = self.transform:Find("MainCon/MainReward")
    self.mainReward.transform.localScale = Vector3(1,1,1)

    self.textBg = self.transform:Find("MainCon/TextBg")
    -- self.transform:SetAsFirstSibling()

    self.itemCon = self.transform:Find("MainCon/ItemSlotTemplte")
    self.itemCon.gameObject:SetActive(false)
    self.itemContainer = self.transform:Find("MainCon/ItemContainer")

    self.titleText = self.transform:Find("MainCon/TextBg/TItleText"):GetComponent(Text)

    self.panel = self.transform:Find("Panel"):GetComponent(Button)
    self.panel.onClick:AddListener(function() self:ApplyClose() end)
    self.squareBg = self.transform:Find("MainCon/CircleBg/Bg"):GetComponent(Image)
    self.squareBg.sprite = self.assetWrapper:GetTextures(AssetConfig.guildleaguebig, "GuildLeague2")
    self.circleBg = self.transform:Find("MainCon/CircleBg")
    self.transform:SetAsFirstSibling()
    self.panel.gameObject:SetActive(false)
    self.textBg.gameObject:SetActive(false)
    self.circleBg.gameObject:SetActive(false)
    self.bgTr = self.transform:Find("MainCon/CircleBg/Bg"):GetComponent(RectTransform)
    -- self.titleText = self.transform:Find("MainCon/TItleText"):GetComponent(Text)
    self:OnOpen()
end

function NationalSecondFlowerRewardPanel:ApplyClose()
    if self.isHasBuy == true then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("恭喜集齐缤纷花语,另外三个珍宝可在活动期间,按照<color='#FFFF00'>优惠价格</color>购买哟")
        data.sureLabel = TI18N("我再看看")
        data.cancelLabel = TI18N("退 出")
        data.cancelCallback = function ()
            self:Hiden()
        end
        NoticeManager.Instance:ConfirmTips(data)
    else
        self:Hiden()
    end
end

function NationalSecondFlowerRewardPanel:OnHide()
   if  self.floatTimerId ~= nil then
        LuaTimer.Delete(self.floatTimerId)
        self.floatTimerId = nil
    end

    self.parent:ShowEffect(true)
    if self.parent.rewardEffect ~= nil then
        self.parent.rewardEffect:SetActive(false)
        self.parent.rewardEffect = nil
    end
    self.panel.gameObject:SetActive(false)
    self.textBg.gameObject:SetActive(false)
    self.circleBg.gameObject:SetActive(false)
     self.isInit = false
    self.squareBg.gameObject:SetActive(false)
    self.mainReward.transform.localScale = Vector3(1,1,1)
    if self.parent ~= nil then
        self.parent.rewardBtn.gameObject:SetActive(true)
    end
    if self.tweenIdX ~= nil then
        Tween.Instance:Cancel(self.tweenIdX)
        self.tweenIdX = nil
    end

    if self.tweenIdY ~= nil then
        Tween.Instance:Cancel(self.tweenIdY)
        self.tweenIdY = nil
    end

    if self.timeIdList ~= nil then
        for k,v in pairs(self.timeIdList) do
            LuaTimer.Delete(v)
            self.timeIdList[k] = nil
        end
    end

    if self.tweenScalerId ~= nil then
        Tween.Instance:Cancel(self.tweenScalerId)
        self.tweenScalerId = nil
    end

    if self.delayTimerId ~= nil then
        LuaTimer.Delete(self.delayTimerId)
        self.delayTimerId = nil
    end

    if self.itemSlotList ~= nil then
        for i,v in ipairs(self.itemSlotList) do
            v.gameObject:SetActive(false)
        end
    end


    if self.tweenIdList ~= nil then
        for k,v in pairs(self.tweenIdList) do
            if v ~= nil then
                Tween.Instance:Cancel(v)
                self.tweenIdList[k] = nil
            end
        end
    end
end

function NationalSecondFlowerRewardPanel:OnOpen()
    self.parent:ShowEffect(false)
    self.openModel = self.openArgs[1]
    self:ResetPanel()

    if self.isInit == false then
        if self.openModel == NationalSecondFlowerRewardEumn.Model.ShowReward then
            self:InitShowMainReward()
        elseif self.openModel == NationalSecondFlowerRewardEumn.Model.GetReward then
            self:InitGetMainReward()
        end
    end
    self.isInit = true
end

function NationalSecondFlowerRewardPanel:ResetPanel()
    if self.isInit == false then
        self.mainReward.transform.anchoredPosition = Vector2(91,-58)
        self.mainReward.transform.localScale = Vector3(1,1,1)
    end
    self:InitShowOtherReward()
end

function NationalSecondFlowerRewardPanel:InitShowOtherReward()
    print(self.openModel)
    self.isHasBuy = false
    self.rewardDataList = NationalSecondManager.Instance.boxData
    local hasGetNum = 0
    for i,v in ipairs(self.rewardDataList) do
        local itemSlot = nil
        if self.itemSlotList[i] == nil then
            local gameObj = GameObject.Instantiate(self.itemCon.gameObject)
            local t = gameObj.transform
            gameObj.transform:SetParent(self.itemContainer.transform)
            gameObj.transform.localPosition = Vector3(0,0,0)

            gameObj.transform.localScale = Vector3(1,1,1)
            itemSlot = NationalSecondFlowerRewardItem.New(gameObj,nil,i)
            self.itemSlotList[i] = itemSlot
        end

        -- self.itemSlotList[i].gameObject:SetActive(false)
        self.itemSlotList[i]:SetSlot(v.base_id,self.extra,v.num,v)
        if self.isInit == false then
            if self.openModel == NationalSecondFlowerRewardEumn.Model.ShowReward then
                self.itemSlotList[i].transform.anchoredPosition = Vector2(-164 + (i-1)*110,-155)
            else
                self.itemSlotList[i].transform.anchoredPosition = Vector2(-235 + (i-1)*149,-311)
            end
        end


        if self.openModel == NationalSecondFlowerRewardEumn.Model.ShowReward then
            self.itemSlotList[i]:SetIsBg(false)
        else
            self.itemSlotList[i]:SetIsBg(true)
        end

        if self.openModel == NationalSecondFlowerRewardEumn.Model.GetReward then
            self.itemSlotList[i]:SetCharge(true)
        else
            self.itemSlotList[i]:SetCharge(false)
        end

        if v.is_get == 0 then
            hasGetNum = hasGetNum + 1
        end
    end

    if hasGetNum == 2 then
        for k,v in pairs(self.itemSlotList) do
            v:SetIsBuy(false)
        end
        self.titleText.text = "<color='#FFFF00'>恭喜集齐缤纷花语</color>，可优惠购买其它珍宝中的<color='#FFFF00'>一个</color>"
    elseif hasGetNum == 1 then
        self.isHasBuy = true
        self.titleText.text = "<color='#FFFF00'>恭喜集齐缤纷花语</color>，可优惠购买其它珍宝中的<color='#FFFF00'>一个</color>"
    else
        self.titleText.text = "<color='#FFFF00'>集齐缤纷花语</color>，可随机获得以下奖励中的<color='#FFFF00'>一个</color>"
    end

end

function NationalSecondFlowerRewardPanel:InitShowMainReward()
     self.squareBg.transform.sizeDelta = Vector2(771,240)
    if self.tweenIdY == nil then
        self.tweenIdY = Tween.Instance:MoveLocalY(self.mainReward.gameObject,92,0.2, function()  end,LeanTweenType.easeInQuad).id
    end

    if self.tweenIdX == nil then
        self.tweenIdX = Tween.Instance:MoveLocalX(self.mainReward.gameObject,9,0.2, function()  end,LeanTweenType.easeInQuad).id
    end

    if self.tweenScalerId == nil then
        self.tweenScalerId = Tween.Instance:Scale(self.mainReward.gameObject, Vector3(1.3,1.3,1),0.2, function()  end, LeanTweenType.easeInQuad).id
    end

    if self.delayTimerId == nil then
        self.delayTimerId  = LuaTimer.Add(250,function() self:PlayShowReward() end)
    end
end

function NationalSecondFlowerRewardPanel:InitGetMainReward()
    self.squareBg.transform.sizeDelta = Vector2(771,299)
    if self.tweenScalerId == nil then
        self.tweenScalerId = Tween.Instance:Scale(self.mainReward.gameObject, Vector3(1.3,1.3,1),0.2, function()  end, LeanTweenType.easeInQuad).id
    end

     if self.tweenIdY == nil then
        self.tweenIdY = Tween.Instance:MoveLocalY(self.mainReward.gameObject,92,0.2, function()  end,LeanTweenType.easeInQuad).id
    end

    if self.tweenIdX == nil then
        self.tweenIdX = Tween.Instance:MoveLocalX(self.mainReward.gameObject,9,0.2, function()  end,LeanTweenType.easeInQuad).id
    end

    if self.delayTimerId == nil then
        self.delayTimerId  = LuaTimer.Add(250,function() self:PlayShowReward() end)
    end
end


function NationalSecondFlowerRewardPanel:PlayShowReward()
    self.squareBg.gameObject:SetActive(true)
    self.panel.gameObject:SetActive(true)
    self.textBg.gameObject:SetActive(true)
    self.circleBg.gameObject:SetActive(true)
    for k,v in pairs(self.itemSlotList) do
        v.gameObject:SetActive(true)
        if self.timeIdList[k] == nil then
            self.timeIdList[k] = LuaTimer.Add(80*(k-1), function()
                if self.tweenIdList[k] == nil then
                    if self.openModel == NationalSecondFlowerRewardEumn.Model.ShowReward then
                        self.tweenIdList[k] = Tween.Instance:MoveLocalY(v.gameObject, -82,0.2, function() end,LeanTweenType.easeOutQuart).id
                    else
                        self.tweenIdList[k] = Tween.Instance:MoveLocalY(v.gameObject, -74,0.2, function() end,LeanTweenType.easeOutQuart).id
                    end
                end
            end)

        end
    end

    if self.floatTimerId == nil then
        self.floatCounter = 0
        self.floatTimerId = LuaTimer.Add(0, 16, function() self:OnFloatItem() end)
    end
end

function NationalSecondFlowerRewardPanel:OnFloatItem()
    self.floatCounter = self.floatCounter + 1
    local position = self.mainReward.transform.localPosition
    self.mainReward.transform.localPosition = Vector2(position.x, position.y + 0.5 * math.sin(self.floatCounter * math.pi / 90 * 1.5))
end


