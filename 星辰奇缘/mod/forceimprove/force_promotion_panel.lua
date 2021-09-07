ForcePromotionPanel = ForcePromotionPanel or BaseClass(BasePanel)

function ForcePromotionPanel:__init(parent)
    self.parent = parent
    self.mgr = ForceImproveManager.Instance
    self.model = self.mgr.model

    self.depPath = "textures/ui/forceimprove.unity3d"

    self.resList = {
        {file = AssetConfig.force_promotion_panel, type = AssetType.Main}
        , {file = self.depPath, type = AssetType.Dep}
        ,{file = AssetConfig.half_length, type = AssetType.Dep}
        ,{file = AssetConfig.guidetaskicon, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
        , {file = AssetConfig.rolebgnew, type = AssetType.Dep}
        , {file = AssetConfig.rolebgstand, type = AssetType.Dep}
        , {file = string.format(AssetConfig.effect, 20053), type = AssetType.Main}
        , {file = string.format(AssetConfig.effect, 20260), type = AssetType.Main}
        , {file = string.format(AssetConfig.effect, 20272), type = AssetType.Main}
    }

    self.level0Mark = false

    self.nextLevelData = nil

    self.pointEffect20053 = nil
    self.pointEffect20053_2 = nil
    self.pointEffect20260 = nil
    self.pointEffect20272 = nil

    self.upgradeLocationTweened = function()
        self.nowPanel:GetComponent(CanvasGroup).alpha = 1
        self.nextPanel:GetComponent(CanvasGroup).alpha = 1
        self.nextPanel:GetComponent(RectTransform).anchoredPosition = Vector2(-20, -43)

        self:Update()
    end

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.updateListener = function() self:Update() end
    self.upgradeListener = function() self:Upgrade() end
    self.updateslowListener = function() 
            local mark = self.toggleTick.activeSelf
            self.toggleTick:SetActive(not mark) 
            self:Update()
        end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function ForcePromotionPanel:__delete()
    self.OnHideEvent:Fire()
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.detailLayout ~= nil then
        self.detailLayout:DeleteMe()
        self.detailLayout = nil
    end

    if self.itemSolt ~= nil then
        self.itemSolt:DeleteMe()
        self.itemSolt = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ForcePromotionPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.force_promotion_panel))
    self.gameObject.name = "ForcePromotionPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.mainTransform)
    self.transform.localPosition = Vector3(0, 0, 0)
    self.transform.localScale = Vector3(1, 1, 1)

    local t = self.transform
    self.halfImage = t:Find("RoleInfo/Half"):GetComponent(Image)
    self.scoreText = t:Find("RoleInfo/ScoreValue"):GetComponent(Text)
    self.badgeIcon = t:Find("RoleInfo/BadgeIcon")
    self.badgeText = t:Find("RoleInfo/BadgeText"):GetComponent(Text)
    self.slider = t:Find("RoleInfo/Slider"):GetComponent(Slider)
    -- self.okButton = t:Find("RoleInfo/OkButton"):GetComponent(Button)
    self.sliderText = t:Find("RoleInfo/Slider/ProgressTxt"):GetComponent(Text)

    self.panel = t:Find("Panel")
    self.nowPanel = t:Find("Panel/NowPanel")
    self.nextPanel = t:Find("Panel/NextPanel")

    self.toggle = t:Find("SpeedToggle"):GetComponent(Button)
    self.toggleTick = t:Find("SpeedToggle/Tick").gameObject
    self.toggle.onClick:AddListener(function() self:OnSpeed() end)
    

    self.level0Panel = t:Find("Level0Panel")

    self.itemSolt = ItemSlot.New()
    UIUtils.AddUIChild(self.panel:Find("ItemPanel/ItemSlot").gameObject, self.itemSolt.gameObject)

    self.nowPanel:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew, "RoleBgNew")
    self.nextPanel:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew, "RoleBgNew")
    self.level0Panel:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew, "RoleBgNew")
    self.level0Panel:Find("Bg3"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgstand, "RoleStandBottom")

    self.okButton = t:Find("Panel/OkButton"):GetComponent(Button)
    self.okButton.onClick:AddListener(function() self:OnOkButtonClick() end)
    self.okButton2 = t:Find("Level0Panel/OkButton"):GetComponent(Button)
    self.okButton2.onClick:AddListener(function() self:OnOkButtonClick() end)
    -- self.okButton.onClick:AddListener(function() self:OnOkButtonClick() end)
end

function ForcePromotionPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ForcePromotionPanel:OnOpen()
    -- 测试特效用
    -- self.model.fcLevel = 0

    ForceImproveManager.Instance:send10018()

    --龟速流玩法
    self.toggleTick:SetActive(ForceImproveManager.Instance.is_no_speed == 1)

    self:Update()


    self:RemoveListeners()
    -- self.mgr.onUpdateForce:AddListener(self.updateListener)
    self.mgr.onUpgradeForceLevel:AddListener(self.upgradeListener)

    self.mgr.onUpdataSlowState:AddListener(self.updateslowListener)

    self.parent.transform:FindChild("Main/Title/Text"):GetComponent(Text).text = TI18N("头衔晋级")
end

function ForcePromotionPanel:OnHide()
    self:RemoveListeners()

    self.upgradeLocationTweened()
    if self.upgradeLocationTweenId ~= nil then
        Tween.Instance:Cancel(self.upgradeLocationTweenId)
        self.upgradeLocationTweenId = nil
    end
    if self.upgradeAlphaTweenId ~= nil then
        Tween.Instance:Cancel(self.upgradeAlphaTweenId)
        self.upgradeAlphaTweenId = nil
    end
    if self.upgradeLeftAlphaTweenId ~= nil then
        Tween.Instance:Cancel(self.upgradeLeftAlphaTweenId)
        self.upgradeLeftAlphaTweenId = nil
    end

    if self.progBarEffectTimerId ~= nil then
        LuaTimer.Delete(self.progBarEffectTimerId)
        self.progBarEffectTimerId = nil
    end

    self:ShowLevel0PanelEffect(false)
    self:ShowProgBarEffect(false)
end

function ForcePromotionPanel:RemoveListeners()
    -- self.mgr.onUpdateForce:RemoveListener(self.updateListener)
    self.mgr.onUpgradeForceLevel:RemoveListener(self.upgradeListener)
    self.mgr.onUpdataSlowState:RemoveListener(self.updateslowListener)
end

function ForcePromotionPanel:Update()
    self:UpdateRoleInfo()

    local roleData = RoleManager.Instance.RoleData
    local data = DataFcUpdate.data_reward[string.format("%s_%s", self.model.fcLevel, roleData.classes)]
    if data == nil then
        self.level0Mark = true

        self.panel.gameObject:SetActive(false)
        self.level0Panel.gameObject:SetActive(true)
        self.toggle.transform.anchoredPosition = Vector2(160, -194)

        data = DataFcUpdate.data_reward[string.format("%s_%s", self.model.fcLevel + 1, roleData.classes)]
        if data ~= nil then
            self:UpdatePanelLevel0(self.level0Panel, data)
            self.level0Panel:Find("OkButton").gameObject:SetActive(true)
            self.level0Panel:Find("ActivePanel").gameObject:SetActive(false)
        end

        self.nextLevelData = DataFcUpdate.data_reward[string.format("%s_%s", self.model.fcLevel + 1, roleData.classes)]
    else
        self.level0Mark = false

        self.nextLevelData = DataFcUpdate.data_reward[string.format("%s_%s", self.model.fcLevel + 1, roleData.classes)]
        if self.nextLevelData == nil then
            self.nextLevelData = nil
            self.toggle.transform.anchoredPosition = Vector2(160, -194)
            self.panel.gameObject:SetActive(false)
            self.level0Panel.gameObject:SetActive(true)
            self:UpdatePanelLevel0(self.level0Panel, data)
            self.level0Panel:Find("OkButton").gameObject:SetActive(false)
            self.level0Panel:Find("ActivePanel").gameObject:SetActive(true)
        else
            self.panel.gameObject:SetActive(true)
            self.level0Panel.gameObject:SetActive(false)
            self.toggle.transform.anchoredPosition = Vector2(278,-140)
            self:UpdatePanel(self.nowPanel, data)
            self:UpdatePanel(self.nextPanel, self.nextLevelData)
            self:UpdateItemPanel(self.panel, self.nextLevelData)
        end
    end
end

function ForcePromotionPanel:UpdateRoleInfo()
    local roleData = RoleManager.Instance.RoleData
    self.halfImage.sprite = self.assetWrapper:GetSprite(AssetConfig.half_length, "half_"..roleData.classes..roleData.sex)
    self.halfImage.gameObject:SetActive(true)
    self.scoreText.text = tostring(roleData.fc)

    local data_reward = DataFcUpdate.data_reward[string.format("%s_%s", self.model.fcLevel, roleData.classes)]
    if data_reward == nil then
        self.badgeIcon.gameObject:SetActive(false)
        self.badgeText.text = ""
    else
        self.badgeIcon.gameObject:SetActive(true)
        self.badgeIcon:GetComponent(Image).sprite = self.assetWrapper:GetSprite(self.depPath, data_reward.icon)
        self.badgeText.text = data_reward.score_name
    end

    local next_data_reward = DataFcUpdate.data_reward[string.format("%s_%s", self.model.fcLevel+1, roleData.classes)]
    if next_data_reward == nil then
        self.slider.value = 1
        self.sliderText.text = string.format("%s/--", roleData.fc)
        self:ShowButtonEffect(false)
    else
        self.slider.value = roleData.fc/next_data_reward.score
        self.sliderText.text = string.format("%s/%s", roleData.fc, next_data_reward.score)

        if roleData.fc >= next_data_reward.score then
            self:ShowButtonEffect(true)
        else
            self:ShowButtonEffect(false)
        end
    end
end

function ForcePromotionPanel:UpdatePanel(transform, data)
    transform:Find("BadgeIcon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(self.depPath, data.icon)
    transform:Find("BadgeIcon"):GetComponent(Image):SetNativeSize()
    transform:Find("BadgeText"):GetComponent(Text).text = string.format(TI18N("称号:<color='%s'>[%s]</color>"), data.score_name_color, data.score_name)

    transform:Find("Text1"):GetComponent(Text).text = string.format(TI18N("需要评分：%s"), data.score)
    -- transform:Find("Text3"):GetComponent(Text).text = string.format(TI18N("获得<color='#ffff00'>[%s]</color>称号"), DataHonor.data_get_honor_list[data.honor].name)
    transform:Find("Text3"):GetComponent(Text).text = ""

    for i=1, 6 do
        local reward_data = data.reward[i]
        local item = transform:Find("Item"..i)
        if reward_data == nil then
            item.gameObject:SetActive(false)
        else
            item.gameObject:SetActive(true)
            -- item:Find("NameText"):GetComponent(Text).text = KvData.attr_name[reward_data.attr_name]
            -- item:Find("ValueText"):GetComponent(Text).text = string.format("+%s", reward_data.val1)

            --龟速流特殊处理
            local temp_val = reward_data.val1
            if self.toggleTick.activeSelf and reward_data.attr_name == 3 then 
                temp_val = 0
            end
            item:Find("NameText"):GetComponent(Text).text = string.format("%s +%s", KvData.attr_name[reward_data.attr_name], temp_val)
            item:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon"..KvData.attr_icon[reward_data.attr_name])
        end
    end
end

function ForcePromotionPanel:UpdateItemPanel(transform, data)
    if #data.loss == 0 then
        transform:Find("ItemPanel").gameObject:SetActive(false)
    else
        transform:Find("ItemPanel").gameObject:SetActive(true)

        local itembase = BackpackManager.Instance:GetItemBase(data.loss[1][1])
        local itemData = ItemData.New()
        itemData:SetBase(itembase)
        self.itemSolt:SetAll(itemData)
        transform:Find("ItemPanel/NameText"):GetComponent(Text).text = itemData.name

        local num = BackpackManager.Instance:GetItemCount(data.loss[1][1])
        local need = data.loss[1][2]
        self.enough = num >= need
        local color = self.enough and ColorHelper.color[1] or ColorHelper.color[4]
        transform:Find("ItemPanel/NumText"):GetComponent(Text).text = string.format("<color='%s'>%s</color>/%s", color, num, need)
    end
end

function ForcePromotionPanel:UpdatePanelLevel0(transform, data)
    transform:Find("BadgeIcon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(self.depPath, data.icon)
    transform:Find("BadgeIcon"):GetComponent(Image):SetNativeSize()
    transform:Find("BadgeText"):GetComponent(Text).text = string.format(TI18N("获得<color='%s'>[%s]</color>称号"), data.score_name_color, data.score_name)

    transform:Find("Text1"):GetComponent(Text).text = string.format(TI18N("需要评分：%s"), data.score)
    -- transform:Find("Text3"):GetComponent(Text).text = string.format(TI18N("获得<color='#ffff00'>[%s]</color>称号"), DataHonor.data_get_honor_list[data.honor].name)
    transform:Find("Text3"):GetComponent(Text).text = ""

    for i=1, 6 do
        local reward_data = data.reward[i]
        local item = transform:Find("Item"..i)
        if reward_data == nil then
            item.gameObject:SetActive(false)
        else
            item.gameObject:SetActive(true)
            -- item:Find("NameText"):GetComponent(Text).text = KvData.attr_name[reward_data.attr_name]
            -- item:Find("ValueText"):GetComponent(Text).text = string.format("+%s", reward_data.val1)

            --龟速流特殊处理
            local temp_val = reward_data.val1
            if self.toggleTick.activeSelf and reward_data.attr_name == 3 then
                temp_val = 0
            end

            item:Find("NameText"):GetComponent(Text).text = string.format("%s +%s", KvData.attr_name[reward_data.attr_name], temp_val)
            item:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon"..KvData.attr_icon[reward_data.attr_name])
        end
    end
end

function ForcePromotionPanel:OnOkButtonClick()
    if self.nextLevelData ~= nil then
        if self.nextLevelData.score > RoleManager.Instance.RoleData.fc then
            NoticeManager.Instance:FloatTipsByString(TI18N("角色评分不足，无法晋级"))
        else
            ForceImproveManager.Instance:send10033()
            -- 测试特效用
            -- self:Upgrade()
            -- self.model.fcLevel = 1
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("已到达最高级"))
    end
end

function ForcePromotionPanel:ShowButtonEffect(show)
    if self.pointEffect20053 == nil then
        self.pointEffect20053 = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20053)))
        self.pointEffect20053.transform:SetParent(self.okButton.transform)
        self.pointEffect20053.transform.localRotation = Quaternion.identity
        Utils.ChangeLayersRecursively(self.pointEffect20053.transform, "UI")
        self.pointEffect20053.transform.localScale = Vector3(1.8, 0.7, 1)
        self.pointEffect20053.transform.localPosition = Vector3(-57, -15, -400)
        -- self.pointEffect20053.transform:Find("20219liuguang/guangtiao").gameObject:SetActive(false)
    end

    self.pointEffect20053:SetActive(show)

    if self.pointEffect20053_2 == nil then
        self.pointEffect20053_2 = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20053)))
        self.pointEffect20053_2.transform:SetParent(self.okButton2.transform)
        self.pointEffect20053_2.transform.localRotation = Quaternion.identity
        Utils.ChangeLayersRecursively(self.pointEffect20053_2.transform, "UI")
        self.pointEffect20053_2.transform.localScale = Vector3(1.8, 0.7, 1)
        self.pointEffect20053_2.transform.localPosition = Vector3(-57, -15, -400)
        -- self.pointEffect20053_2.transform:Find("20219liuguang/guangtiao").gameObject:SetActive(false)
    end

    self.pointEffect20053_2:SetActive(show)
end

--设置进度条特效
function ForcePromotionPanel:ShowProgBarEffect(show)
    if self.pointEffect20272 == nil then
        self.pointEffect20272 = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20272)))
        self.pointEffect20272.transform:SetParent(self.slider.transform)
        self.pointEffect20272.transform.localRotation = Quaternion.identity
        Utils.ChangeLayersRecursively(self.pointEffect20272.transform, "UI")
        self.pointEffect20272.transform.localScale = Vector3(1.3, 0.4, 1)
        self.pointEffect20272.transform.localPosition = Vector3(-230, 0, -400)
        -- self.pointEffect20272.transform:Find("20219liuguang/guangtiao").gameObject:SetActive(false)
    end

    self.pointEffect20272:SetActive(show)
end

--设置0级面板闪光特效
function ForcePromotionPanel:ShowLevel0PanelEffect(show)
    if self.pointEffect20260 == nil then
        self.pointEffect20260 = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20260)))
        self.pointEffect20260.transform:SetParent(self.transform)
        self.pointEffect20260.transform.localRotation = Quaternion.identity
        Utils.ChangeLayersRecursively(self.pointEffect20260.transform, "UI")
        self.pointEffect20260.transform.localScale = Vector3(2.08, 1.14, 1)
        self.pointEffect20260.transform.localPosition = Vector3(-4, -62, -400)
    end

    self.pointEffect20260:SetActive(show)
end

function ForcePromotionPanel:Upgrade()
    self:ShowProgBarEffect(false)
    self:ShowProgBarEffect(true)

    if self.level0Mark then
        self:ShowLevel0PanelEffect(false)
        self:ShowLevel0PanelEffect(true)
        local fun = function()
            self:Update()

            self.progBarEffectTimerId = LuaTimer.Add(300, function()
                self:ShowLevel0PanelEffect(false)
                self:ShowProgBarEffect(false)
            end)
        end
        self.progBarEffectTimerId = LuaTimer.Add(200, fun)
    else
        local fun = function()
            self:ShowProgBarEffect(false)
            self:ShowButtonEffect(false)

            local time = 0.5
            if self.upgradeLocationTweenId ~= nil then
                Tween.Instance:Cancel(self.upgradeLocationTweenId)
                self.upgradeLocationTweenId = nil
            end
            if self.upgradeAlphaTweenId ~= nil then
                Tween.Instance:Cancel(self.upgradeAlphaTweenId)
                self.upgradeAlphaTweenId = nil
            end
            if self.upgradeLeftAlphaTweenId ~= nil then
                Tween.Instance:Cancel(self.upgradeLeftAlphaTweenId)
                self.upgradeLeftAlphaTweenId = nil
            end
            self.upgradeLeftAlphaTweenId = Tween.Instance:ValueChange(1, 0, time, nil, LeanTweenType.linear, function(val)
                self.nowPanel:GetComponent(CanvasGroup).alpha = val
            end).id
            self.upgradeAlphaTweenId = Tween.Instance:ValueChange(1, 0.5, time, nil, LeanTweenType.linear, function(val)
                self.nextPanel:GetComponent(CanvasGroup).alpha = val
            end).id
            self.upgradeLocationTweenId = Tween.Instance:ValueChange(-20, -397.5, time, self.upgradeLocationTweened, LeanTweenType.linear, function(val)
                self.nextPanel:GetComponent(RectTransform).anchoredPosition = Vector2(val, -43)
            end).id
        end
        self.progBarEffectTimerId = LuaTimer.Add(500, fun)
    end
end

-- 攻速选择
function ForcePromotionPanel:OnSpeed()
    local mark = self.toggleTick.activeSelf
    if mark then
        ForceImproveManager.Instance:send10041(0)
    else
        local confirmData = NoticeConfirmData.New()
        confirmData.content = TI18N("该操作将会屏蔽头衔加成的攻速，该操作适用于<color='#ffff00'>龟速流派</color>，是否继续（再次勾选可恢复）？")
        confirmData.sureCallback = function() ForceImproveManager.Instance:send10041(1) end
        NoticeManager.Instance:ConfirmTips(confirmData)
    end
end
