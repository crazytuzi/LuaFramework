ForceImproveRecommendWindow = ForceImproveRecommendWindow or BaseClass(BaseWindow)

function ForceImproveRecommendWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.force_improve_recommend
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.mgr = ForceImproveManager.Instance

    self.depPath = "textures/ui/forceimprove.unity3d"

    self.resList = {
        {file = AssetConfig.force_improve_recommend_window, type = AssetType.Main}
        , {file = self.depPath, type = AssetType.Dep}
        ,{file = AssetConfig.half_length, type = AssetType.Dep}
        ,{file = AssetConfig.guidetaskicon, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
    }


    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end

    self.updateListener = function() self:Update() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function ForceImproveRecommendWindow:__delete()
    self.OnHideEvent:Fire()

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ForceImproveRecommendWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.force_improve_recommend_window))
    self.gameObject.name = "ForceImproveRecommendWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.mainTransform:FindChild("Close"):GetComponent(Button).onClick:AddListener(function() self:OnClickClose() end)

    self.halfImage = self.mainTransform:Find("RoleInfo/Half"):GetComponent(Image)
    self.scoreText = self.mainTransform:Find("RoleInfo/ScoreValue"):GetComponent(Text)
    self.badgeIcon = self.mainTransform:Find("RoleInfo/BadgeIcon")
    self.badgeText = self.mainTransform:Find("RoleInfo/BadgeText"):GetComponent(Text)
    self.slider = self.mainTransform:Find("RoleInfo/Slider"):GetComponent(Slider)
    self.okButton = self.mainTransform:Find("RoleInfo/OkButton"):GetComponent(Button)
    self.cancelButton = self.mainTransform:Find("RoleInfo/CancelButton"):GetComponent(Button)
    self.sliderText = self.mainTransform:Find("RoleInfo/Slider/ProgressTxt"):GetComponent(Text)

    self.item1 = self.mainTransform:Find("Panel/Item1")
    self.item2 = self.mainTransform:Find("Panel/Item2")

    self.mainTransform:Find("Panel/TitleText1"):GetComponent(Text).text = TI18N("根据您当前的角色评分，我们推荐您<color='#ffff00'>优先提升</color>以下两个系统")

    self.okButton.onClick:AddListener(function() self.model:OpenWindow({1}) end)
    self.cancelButton.onClick:AddListener(function() self:OnClickClose() end)
end

function ForceImproveRecommendWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function ForceImproveRecommendWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ForceImproveRecommendWindow:OnOpen()
    ForceImproveManager.Instance:send10018()

    self:Update()

    self.mgr.onUpdateForce:AddListener(self.updateListener)
end

function ForceImproveRecommendWindow:OnHide()
    self.mgr.onUpdateForce:RemoveListener(self.updateListener)
    self.mgr.onUpgradeForceLevel:RemoveListener(self.upgradeListener)
end

function ForceImproveRecommendWindow:Update()
    self:UpdateRoleInfo()
    self:UpdateItems()
end

function ForceImproveRecommendWindow:UpdateRoleInfo()
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
    else
        self.slider.value = roleData.fc/next_data_reward.score
        self.sliderText.text = string.format("%s/%s", roleData.fc, next_data_reward.score)
    end
end

function ForceImproveRecommendWindow:UpdateItems()
    local list = self.model:SortRecommendData()

    self:UpdateItem(self.item1, list[1])
    self:UpdateItem(self.item2, list[2])
end

function ForceImproveRecommendWindow:UpdateItem(transform, data)
    local data_base = DataFcUpdate.data_base[data.id]
    local myScore = self.model.subTypeList[data.id].myScore
    local serverTop = self.model.subTypeList[data.id].serverTop

    local myScore = self.model.subTypeList[data.id].myScore
    local serverTop = self.model.subTypeList[data.id].serverTop

    transform:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guidetaskicon, tostring(data_base.icon))
    transform:Find("Text1"):GetComponent(Text).text = data_base.name
    local recommendText = ""
    if myScore >= data.val then
        recommendText = TI18N("<color='#ffff00'>不分伯仲</color>")
    elseif myScore >= data.val * 0.7 then
        recommendText = TI18N("<color='#ffff00'>不分伯仲</color>")
    elseif myScore > data.val * 0.5 then
        recommendText = TI18N("<color='#00ff00'>推荐提升</color>")
    else
        recommendText = TI18N("<color='#ff0000'>强烈推荐</color>")
    end

    transform:Find("Text2"):GetComponent(Text).text = string.format(TI18N("评价：%s"), recommendText)
    transform:Find("Text3"):GetComponent(Text).text = string.format(TI18N("当前评分：%s"), myScore)
    transform:Find("Text4"):GetComponent(Text).text = string.format(TI18N("推荐评分：%s"), data.val)

    local btn = transform:Find("OkButton"):GetComponent(Button)
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function() self:JumpTo(data_base.link) end)
end

function ForceImproveRecommendWindow:JumpTo(link)
    local openArgs = {}
    local args = StringHelper.Split(link, ",")
    local winId = tonumber(args[1])
    if winId == 0 then return end

    for i=2,#args do
        table.insert(openArgs, tonumber(args[i]))
    end
    WindowManager.Instance:OpenWindowById(winId, openArgs)
end
