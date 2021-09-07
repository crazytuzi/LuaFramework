-- @author zyh(花朵收集)
-- @date 2017年9月20日

NationalSecondFlowerShowPanel = NationalSecondFlowerShowPanel or BaseClass(BasePanel)


function NationalSecondFlowerShowPanel:__init(parent,parentTr)
    self.parentTr = parentTr
    self.parent = parent
    -- self.parentTr = parentTr
    self.name = "NationalSecondFlowerShowPanel"
    -- self.Effect = "prefabs/effect/20298.unity3d"
    self.resList = {
        {file = AssetConfig.nationalsecond_show_panel, type = AssetType.Main}
        ,{file = AssetConfig.nationalsecond_accept_texture,type = AssetType.Dep}
    }

    self.itemSlotList = {}
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)


    self.extra = {inbag = false, nobutton = true}
    self.timeIdList  = {}
    self.tweendId = nil
    self.openIndex = nil

end


function NationalSecondFlowerShowPanel:OnInitCompleted()

end

function NationalSecondFlowerShowPanel:__delete()

    self:OnHide()


    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function NationalSecondFlowerShowPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.nationalsecond_show_panel))
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    self.gameObject.name = "NationalSecondFlowerShowPanel"
    self.transform = self.gameObject.transform

    self.mainTr = self.transform:Find("MainCon")
    self.mainReward = self.transform:Find("MainCon/MainReward")
    self.mainRewardImg = self.transform:Find("MainCon/MainReward/CircleBg/Circle/RewardImg"):GetComponent(Image)

    self.isFlashImg = self.transform:Find("MainCon/MainReward/CircleBg/Circle/IsFlashImg"):GetComponent(Image)

    self.giveButton = self.transform:Find("MainCon/GiveButton"):GetComponent(Button)
    self.giveButtonImg = self.transform:Find("MainCon/GiveButton"):GetComponent(Image)
    self.giveButtonText = self.transform:Find("MainCon/GiveButton/Text"):GetComponent(Text)

    self.topNoticeText = self.transform:Find("MainCon/TopTextBg/Text"):GetComponent(Text)
    self.topNoticeBg = self.transform:Find("MainCon/TopTextBg")

    self.topNoticeBg.transform.sizeDelta = Vector2(400,30)
    self.topNoticeText.transform.sizeDelta = Vector2(400,30)
    self.topNameText = self.transform:Find("MainCon/TopBg/FlowerName"):GetComponent(Text)
    self.numText = self.transform:Find("MainCon/NumText"):GetComponent(Text)

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)
    self.transform:SetAsFirstSibling()
    -- self.transform:SetAsFirstSibling()



    self.leftChooseBtn = self.transform:Find("MainCon/LeftBtn"):GetComponent(Button)
    self.rightChooseBtn = self.transform:Find("MainCon/RightBtn"):GetComponent(Button)

    self.leftChooseBtn.onClick:AddListener(function() self:ApplyLeftButton() end)
    self.rightChooseBtn.onClick:AddListener(function() self:ApplyRightButton() end)

    -- self.bgTr = self.transform:Find("MainCon/Bg"):GetComponent(RectTransform)
    -- self.titleText = self.transform:Find("MainCon/TItleText"):GetComponent(Text)
    self:OnOpen()
end

function NationalSecondFlowerShowPanel:OnHide()


    if  self.timerInitId ~= nil then
        LuaTimer.Delete(self.timerInitId)
        self.timerInitId = nil
    end
    -- if self.tweenScalerId ~= nil then
    --     Tween.Instance:Cancel(self.tweenScalerId)
    --     self.tweenScalerId = nil
    -- end

end

function NationalSecondFlowerShowPanel:OnOpen()
    self:OnHide()
    self.transform.gameObject:SetActive(false)
    if self.timerInitId == nil then
        self.timerInitId = LuaTimer.Add(400, function() self:IntiMyPanel() end)
    end
    -- if self.tweenScalerId == nil then
    --     self.tweenScalerId = Tween.Instance:Scale(self.mainTr.gameObject, Vector3(1,1,1),0.4, function()  self.tweenScalerId = nil end, LeanTweenType.easeOutQuad).id
    -- end



end

function NationalSecondFlowerShowPanel:IntiMyPanel()
    self.transform.gameObject:SetActive(true)
    self.giveButton.onClick:RemoveAllListeners()
    self.openIndex = self.openArgs[1]
    self.nowIndex = self.openIndex

    self:RefreshButton()


    self.flowerData = NationalSecondManager.Instance.flowerAcceptData.flowers_info
    self:ResetPanel()
end

function NationalSecondFlowerShowPanel:RefreshButton()
    if (NationalSecondManager.Instance.flowerAcceptData.flowers_info[self.nowIndex].num <=0 and NationalSecondManager.Instance.flowerAcceptData.final_reward_state == 0) or (NationalSecondManager.Instance.flowerAcceptData.flowers_info[self.nowIndex].num <=1 and NationalSecondManager.Instance.flowerAcceptData.final_reward_state == 1) then
        self.giveButton.gameObject:SetActive(false)

    else
        self.giveButton.gameObject:SetActive(true)
        self.giveButton.onClick:AddListener(function() self:ApplyGiveButton() end)
    end
end


function NationalSecondFlowerShowPanel:ApplyGiveButton()
    self:Hiden()
    local data = {index = 2}
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.giftwindow,data)
end

function NationalSecondFlowerShowPanel:ResetPanel()

    self:RefreshData()
    self:IsFlash()
end
function NationalSecondFlowerShowPanel:RefreshData()
    local sprite = nil
    sprite = self.assetWrapper:GetSprite(AssetConfig.nationalsecond_accept_texture,tostring(NationalSecondManager.Instance.flowerAcceptData.flowers_info[self.nowIndex].id))
    if sprite == nil then
        sprite = PreloadManager.Instance:GetSprite(AssetConfig.nationalsecond_accept_texture,tostring(NationalSecondManager.Instance.flowerAcceptData.flowers_info[self.nowIndex].id))
    end
    self.mainRewardImg.sprite = sprite
    if NationalSecondManager.Instance.flowerAcceptData.flowers_info[self.nowIndex].num <= 0 then
        self.numText.gameObject:SetActive(false)
    else
        self.numText.gameObject:SetActive(true)
        self.numText.text = string.format("当前拥有数量:%s",NationalSecondManager.Instance.flowerAcceptData.flowers_info[self.nowIndex].num)
    end

    self.topNoticeText.text = string.format("<color='#B031D5'>%s</color>",DataCampaignCollection.data_get_all_flowers[NationalSecondManager.Instance.flowerAcceptData.flowers_info[self.nowIndex].id].says)
    self.topNameText.text = DataCampaignCollection.data_get_all_flowers[NationalSecondManager.Instance.flowerAcceptData.flowers_info[self.nowIndex].id].name .. "仙子"
end

function NationalSecondFlowerShowPanel:ApplyLeftButton()
    self.nowIndex = self.nowIndex - 1
    if self.nowIndex < 1 then
        self.nowIndex = 9
    end
    self:RefreshData()
    self:IsFlash()
    self:RefreshButton()
end

function NationalSecondFlowerShowPanel:ApplyRightButton()
    self.nowIndex = self.nowIndex + 1
    if self.nowIndex > 9 then
        self.nowIndex = 1
    end
    self:RefreshData()
    self:IsFlash()
    self:RefreshButton()

end

function NationalSecondFlowerShowPanel:IsFlash()
    local sprite = nil
    if (self.flowerData[self.nowIndex].num > 0)  or NationalSecondManager.Instance.flowerAcceptData.final_reward_state == 0 then
        sprite = self.assetWrapper:GetSprite(AssetConfig.nationalsecond_accept_texture,"i18nHasFlash")
        if sprite == nil then
            sprite = PreloadManager.Instance:GetSprite(AssetConfig.nationalsecond_accept_texture,"i18nHasFlash")
        end
    else
        sprite = self.assetWrapper:GetSprite(AssetConfig.nationalsecond_accept_texture,"i18nNotHasFlash22")
        if sprite == nil then
            sprite = PreloadManager.Instance:GetSprite(AssetConfig.nationalsecond_accept_texture,"i18nNotHasFlash22")
        end
    end

    if sprite ~= nil then
        self.isFlashImg.sprite = sprite
    end

end

