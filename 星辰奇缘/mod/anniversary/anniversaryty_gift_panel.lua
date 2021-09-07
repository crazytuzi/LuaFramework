-- @author ###
-- @date 2018年4月28日,星期六

AnniversaryTyGiftPanel = AnniversaryTyGiftPanel or BaseClass(BasePanel)

function AnniversaryTyGiftPanel:__init(model, parent)
    self.model = AnniversaryTyManager.Instance.model
    self.parent = parent
    self.name = "AnniversaryTyGiftPanel"

    self.resList = {
        {file = AssetConfig.anniversarygiftPanel, type = AssetType.Main}
        ,{file = AssetConfig.anniversary_flower, type = AssetType.Main}
        ,{file = AssetConfig.pack_seven, type = AssetType.Dep}
        ,{file = AssetConfig.anniversarygiftclose, type = AssetType.Dep}
        ,{file = AssetConfig.anniversary_textures, type = AssetType.Dep}

    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.effectDirection = -1
end

function AnniversaryTyGiftPanel:__delete()
    self.OnHideEvent:Fire()

    if self.DelayTimer ~= nil then
        LuaTimer.Delete(self.DelayTimer)
        self.DelayTimer = nil
    end

    if self.tweeneffectId ~= nil then
        Tween.Instance:Cancel(self.tweeneffectId)
        self.tweeneffectId = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function AnniversaryTyGiftPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.anniversarygiftPanel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas, self.gameObject)
    self.transform = t

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:ClickGift() end)

    local bg = GameObject.Instantiate(self:GetPrefab(AssetConfig.anniversary_flower))
    UIUtils.AddBigbg(t:Find("FlowerBg"), bg)
    self.transform:Find("MainCon/Gift").sizeDelta = Vector2(250,250)
    self.giftImg = self.transform:Find("MainCon/Gift"):GetComponent(Image)
    self.giftBtn = self.transform:Find("MainCon/Gift"):GetComponent(Button)
    self.giftBtn.onClick:AddListener(function() self:ClickGift() end)
end

function AnniversaryTyGiftPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function AnniversaryTyGiftPanel:OnOpen()
    self:RemoveListeners()
    self:SetData()
    local timer = 0
    self:RotateGift(timer)
end

function AnniversaryTyGiftPanel:OnHide()
    self:RemoveListeners()
    if self.DelayTimer ~= nil then
        LuaTimer.Delete(self.DelayTimer)
        self.DelayTimer = nil
    end

    if self.tweeneffectId ~= nil then
        Tween.Instance:Cancel(self.tweeneffectId)
        self.tweeneffectId = nil
    end
end

function AnniversaryTyGiftPanel:RemoveListeners()

end

function AnniversaryTyGiftPanel:SetData()
    self.giftImg.sprite = self.assetWrapper:GetSprite(AssetConfig.anniversarygiftclose, "AnniversarygiftClose")
end

function AnniversaryTyGiftPanel:RotateGift(timer)
    local timer = timer
    if timer < 4 then
        if self.tweeneffectId ~= nil then
            Tween.Instance:Cancel(self.tweeneffectId)
            self.tweeneffectId = nil
        end
        timer = timer + 1
        self.tweeneffectId = Tween.Instance:ValueChange(-8 * self.effectDirection,8 * self.effectDirection,0.2, function() self.tweeneffectId = nil self:RotateGift(timer) end, LeanTweenType.Linear,function(value) self:RotateValueChange(value) end).id
        self.effectDirection = self.effectDirection * -1

    else
        self.DelayTimer = LuaTimer.Add(100,function() self:RotateGift(0) end)
    end
end

function AnniversaryTyGiftPanel:RotateValueChange(value)
    self.giftImg.transform.localRotation = Quaternion.Euler(0, 0, value)
end

function AnniversaryTyGiftPanel:ClickGift()
    AnniversaryTyManager.Instance:Send11895()   --领奖
    local reward = {
        item_list = {
            [1] = { base_id = 90026, num = 100, bind = 0}
            ,[2] = { base_id = 70129, num = 1, bind = 1}
        }
    }
    if reward ~= nil then
        AnniversaryTyManager.Instance.afterGiftShow:Fire()
        self.model:OpenGiftShow(reward)
    end
    self.model:CloseGiftPanel()
end





