-- ----------------------------------------------------------
-- UI - 突破成功界面
-- xjlong 20160926
-- ----------------------------------------------------------
LevelBreakSuccessWindow = LevelBreakSuccessWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function LevelBreakSuccessWindow:__init(model)
    self.model = model
    self.name = "LevelBreakSuccessWindow"
    self.windowId = WindowConfig.WinID.levelbreaksuccesswindow
    self.winLinkType = WinLinkType.Single
    -- self.cacheMode = CacheMode.Visible
    self.rewardEffectFile = "prefabs/effect/20186.unity3d"

    self.resList = {
        {file = AssetConfig.levelbreaksuccesswindow, type = AssetType.Main}
        ,{file = AssetConfig.levelbreak_texture, type = AssetType.Dep}
        ,{file = AssetConfig.levelbreakeffect1, type = AssetType.Dep}
        ,{file = AssetConfig.levelbreakeffect2, type = AssetType.Dep}
        ,{file = self.rewardEffectFile, type = AssetType.Main}
    }

    self.gameObject = nil
    self.transform = nil

    self.mainTransform = nil
    self.previewComp = nil

    self.closeBtn = nil
    self.Title = nil
    self.Congratulations = nil
    self.RoleBg1 = nil
    self.RoleBg2 = nil

    self.rotateId = 0
    self.TitleTimerId = 0
    self.timerIdList = {}
    ------------------------------------------------

    self.classes = 0
    self.sex = 0
    self.maleShowTimes = {2.5, 2.4, 2.533, 3.533, 3.167, 2.567, 3.267} --2.5 第一位空位，狂剑，魔导，战弓，兽灵，密言，月魂，圣骑
    self.femaleShowTimes = {3.367,3.167,2.533, 3.533, 3.167, 2.567, 3.267} --3.367

    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function LevelBreakSuccessWindow:__delete()
    self:OnHide()

    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    if self.rotateId ~= 0 then
        LuaTimer.Delete(self.rotateId)
    end

    if self.TitleTimerId ~= 0 then
        LuaTimer.Delete(self.TitleTimerId)
    end

    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
    end

    for k, v in pairs(self.timerIdList) do
        LuaTimer.Delete(v)
        v = nil
    end

    if self.gameObject ~= nil then
        GameObject.Destroy(self.gameObject)
        self.gameObject = nil
    end


    self:AssetClearAll()
end

function LevelBreakSuccessWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.levelbreaksuccesswindow))
    self.gameObject.name = "LevelBreakSuccessWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.closeBtn = self.mainTransform:FindChild("OKButton")
    self.closeBtn:GetComponent(Button).onClick:AddListener(function() self:OnClickClose() end)

    self.Title = self.mainTransform:Find("Title")
    self.Congratulations = self.mainTransform:Find("Congratulations")

    self.RoleBg1 = self.mainTransform:Find("RoleBg1")
    self.RoleBg2 = self.mainTransform:Find("RoleBg2")
    for i=1,2 do
        self.RoleBg1:FindChild("Image"..i):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.levelbreakeffect1, "LevelBreakEffect1")
    end

    for i=1,4 do
        self.RoleBg2:FindChild("Image"..i):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.levelbreakeffect2, "LevelBreakEffect2")
    end

    self.preview = self.mainTransform:Find("Preview").gameObject
    self.preview:SetActive(false)

    local rewardTextList = {
        TI18N("等级上限提升至<color='#00ff00'>110</color>"),
        TI18N("开启<color='#00ff00'>属性点兑换</color>功能"),
        TI18N("获得突破专属<color='#00ff00'>名称颜色</color>"),
        TI18N("<color='#00ff00'>冒险技能</color>等级上限解锁"),
        TI18N("<color='#00ff00'>强壮精通</color>等级上限解锁"),
    }

    self.rewardListObj = self.mainTransform:Find("RewardList")
    self.rewardList = {}
    for i=1,5 do
        local rewardInfo = {}
        rewardInfo.obj = self.rewardListObj:Find("Reward"..i)
        rewardInfo.obj:Find("Text"):GetComponent(Text).text = rewardTextList[i]
        rewardInfo.effect = GameObject.Instantiate(self:GetPrefab(self.rewardEffectFile))
        rewardInfo.effect.transform:SetParent(self.rewardListObj.transform)
        rewardInfo.effect.transform.localScale = Vector3(1, 1, 1)
        rewardInfo.effect.transform.localPosition = Vector3(rewardInfo.obj.localPosition.x-160, rewardInfo.obj.localPosition.y, -1000)
        Utils.ChangeLayersRecursively(rewardInfo.effect.transform, "UI")
        rewardInfo.effect:SetActive(false)

        table.insert(self.rewardList, rewardInfo)
    end
    ----------------------------

    self:OnShow()
    self:ClearMainAsset()
end

function LevelBreakSuccessWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function LevelBreakSuccessWindow:OnShow()
    self:Update()
    self:UpdatePreview()
end

function LevelBreakSuccessWindow:OnHide()
    if self.previewComp ~= nil then
        self.previewComp:Hide()
    end
end

function LevelBreakSuccessWindow:Update()
    self.classes = RoleManager.Instance.RoleData.classes
    self.sex = RoleManager.Instance.RoleData.sex

    self:showBgAni()

    self.closeBtn.gameObject:SetActive(false)
    self.Congratulations.gameObject:SetActive(false)
    for i=1,5 do
        self.rewardList[i].obj.gameObject:SetActive(false)
    end

    self.TitleTimerId = LuaTimer.Add(0, 500, function() self:showTitle() end)
end

function LevelBreakSuccessWindow:UpdatePreview()
    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "LevelBreakSuccessWindow"
        ,orthographicSize = 0.7
        ,width = 341
        ,height = 341
        ,offsetY = -0.4
    }
    local llooks = {}
    local mySceneData = SceneManager.Instance:MyData()
    if mySceneData ~= nil then
        llooks = mySceneData.looks
    end
    local modelData = {type = PreViewType.Role, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, looks = llooks}
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
    end
    self.previewComp:Show()
end

function LevelBreakSuccessWindow:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    self.preview:SetActive(true)

    local state_id = BaseUtils.GetShowActionId(self.classes, self.sex)
    composite:PlayAnimation(tostring(state_id))

    local showTime = 1
    if self.sex == 0 then
        showTime = self.femaleShowTimes[self.classes]
    else
        showTime = self.maleShowTimes[self.classes]
    end
    if showTime == nil then
        showTime = 1
    end

    local timerId = LuaTimer.Add(showTime*1000, function () self:ActionDelay(composite) end)
    table.insert(self.timerIdList, timerId)
end

function LevelBreakSuccessWindow:ActionDelay(composite)
    composite:PlayAnimation("Stand"..composite.animationData.stand_id)
end

function LevelBreakSuccessWindow:showTitle()
    if self.TitleTimerId ~= 0 then
        LuaTimer.Delete(self.TitleTimerId)
    end

    self.Title.localScale = Vector3.one * 3
    self.tweenId = Tween.Instance:Scale(self.Title.gameObject, Vector3.one, 1, function() 
            local timerId = LuaTimer.Add(100, function() self:showRewardEffect(1) end) 
            table.insert(self.timerIdList, timerId)
        end, LeanTweenType.easeOutElastic).id
end

function LevelBreakSuccessWindow:showRewardEffect(index)
    if self.rewardList[index] == nil then
        self.closeBtn.gameObject:SetActive(true)
        self.Congratulations.gameObject:SetActive(true)
    else
        self.rewardList[index].effect:SetActive(true)
        local timerId = LuaTimer.Add(700, function() self:showReward(index) end)
        table.insert(self.timerIdList, timerId)
        timerId = LuaTimer.Add(100, function() self:showRewardEffect(index + 1) end)
        table.insert(self.timerIdList, timerId)
    end
end

function LevelBreakSuccessWindow:showReward(index)
    self.rewardList[index].effect:SetActive(false)
    self.rewardList[index].obj.gameObject:SetActive(true)
end

function LevelBreakSuccessWindow:showBgAni()
    self.rotateId = LuaTimer.Add(0, 10, function() self:Rotate() end)
end

function LevelBreakSuccessWindow:Rotate()
    self.RoleBg1.transform:Rotate(Vector3(0, 0, 0.3))
    self.RoleBg2.transform:Rotate(Vector3(0, 0, -0.5))
end
