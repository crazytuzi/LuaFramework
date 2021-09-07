BadgeRewardWindow = BadgeRewardWindow or BaseClass(BaseWindow)

function BadgeRewardWindow:__init(model)
    self.model = model
    self.Mgr = self.model.mgr
    self.name = "BadgeRewardWindow"
    self.cacheMode = CacheMode.Destroy

    self.resList = {
        {file = AssetConfig.badgerewardwindow, type = AssetType.Main},
        {file = AssetConfig.no1inworldbadge_textures, type = AssetType.Dep},
        --{file = AssetConfig.childrentextures, type = AssetType.Dep},
        --{file = AssetConfig.base_textures, type = AssetType.Dep},
        {file = AssetConfig.badge_icon, type = AssetType.Dep},
    }

    self.OnOpenEvent:Add(function() self:OnOpen() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.OnHideEvent:AddListener(self.Mgr.showProcessEft)
end

function BadgeRewardWindow:__delete()
    self.OnHideEvent:Fire()
    self.OnHideEvent:RemoveListener(self.Mgr.showProcessEft)
    if self.iconloader ~= nil then
        self.iconloader:DeleteMe()
        self.iconloader = nil
    end
    if self.openEffect ~= nil then
        self.openEffect:DeleteMe()
        self.openEffect = nil
    end
    self:AssetClearAll()
end

function BadgeRewardWindow:InitPanel()

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.badgerewardwindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    self.data = self.openArgs
    self.transform:Find("Main"):GetComponent(Button).onClick:AddListener(function() self:OnClickBtn() end)
    self:OnOpen()
    self.clickCount = 0
    self.getBadge = false
    self.nameTxt = self.transform:Find("Main/Name"):GetComponent(Text)
    self.itemBg = self.transform:Find("Main/ItemBg").gameObject
    self.itemImg = self.transform:Find("Main/ItemImg"):GetComponent(Image)
    self.desTxt = self.transform:Find("Main/Des"):GetComponent(Text)
    self.badgeNotice =  self.transform:Find("Main/Text").gameObject
    self.badgeNotice:GetComponent(Text).text = TI18N("徽章已自动使用，可以在<color='#ffff00'>武道会匹配</color>界面看见哦")
    self.badgeNotice:GetComponent(RectTransform).anchoredPosition = Vector2(-8,-130)
    self.index = 0
    self.clickCount = 0
    --self.transform:Find("Panel"):GetComponent(Button).onClick:RemoveAllListeners()
    self.des = {[1] = "提示：升星可以获得丰厚奖励，升星进度完成即可解锁王者徽章。",
                [2] = "提示：升星可以获得丰厚奖励，升星进度完成即可解锁王者徽章。"}

    if self.openEffect == nil then
        self.openEffect = BaseUtils.ShowEffect(20417, self.transform, Vector3(1,1,1), Vector3(0,0,-1000))
    end
    self.openEffect:SetActive(false)

end

function BadgeRewardWindow:OnOpen()

end

function BadgeRewardWindow:OnInitCompleted()

    --BaseUtils.dump(self.data)
    if self.data.reward ~= nil then
        self.clickCount = #self.data.reward
    end
    if self.data.badge_id ~= 0 then
        self.getBadge = true
        self.itemBg:SetActive(false)
        -- self.clickCount = self.clickCount + 1
        local data = DataAchieveShop.data_list[self.data.badge_id]
        self.nameTxt.text = data.name
        self.desTxt.text = data.desc
        self.itemImg.sprite = self.assetWrapper:GetSprite(AssetConfig.badge_icon,tostring(DataAchieveShop.data_list[ZoneManager.Instance:ResIdToId(data.source_id)].source_id))
        self.itemImg:SetNativeSize()
        self.badgeNotice:SetActive(true)
        SoundManager.Instance:Play(268)
        self.openEffect:SetActive(false)
        self.openEffect:SetActive(true)
    else
        self.index = 1
        self:ShowData(1)
    end
    self.transform:Find("Panel"):GetComponent(Button).onClick:RemoveAllListeners()
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:OnClickBtn() end)
end


function BadgeRewardWindow:OnHide()

end

function BadgeRewardWindow:ShowData(index)
    local data = DataItem.data_get[self.data.reward[index].item_id]
    self.itemBg:SetActive(true)
    if data ~= nil then
        self.nameTxt.text = data.name
        self.desTxt.text = self.des[index]
        local iconId = data.icon
        if self.iconloader == nil then
            self.iconloader = SingleIconLoader.New(self.itemImg.gameObject)
        end
        self.iconloader:SetSprite(SingleIconType.Item, iconId, true)
        self.badgeNotice:SetActive(false)
        SoundManager.Instance:Play(268)
        self.openEffect:SetActive(false)
        self.openEffect:SetActive(true)
    end
end

function BadgeRewardWindow:OnClickBtn()
    -- if self.getBadge == false then
        if  self.index < self.clickCount  then
            self.index = self.index + 1
            self:ShowData(self.index)
        else
            self.model:CloseBadgeRewardWindow()
        end
    -- else
    --     if  self.index < self.clickCount - 1 then
    --         self.index = self.index + 1
    --         self:ShowData(self.index)
    --     elseif self.index < self.clickCount  then
    --         self.index = self.index + 1

    --         local data = DataAchieveShop.data_list[self.data.badge_id]
    --         self.nameTxt.text = data.name
    --         self.desTxt.text = data.desc
    --         if self.iconloader == nil then
    --             self.iconloader = SingleIconLoader.New(self.itemImg.gameObject)
    --         end
    --         self.iconloader:SetSprite(SingleIconType.Item, data.source_id)
    --         SoundManager.Instance:Play(268)
    --         self.openEffect:SetActive(false)
    --         self.openEffect:SetActive(true)
    --     else
    --         self.model:CloseBadgeRewardWindow()
    --     end
    -- end
end



