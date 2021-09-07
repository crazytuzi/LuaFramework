-- @author 黄耀聪
-- @date 2017年5月15日

WingPanel = WingPanel or BaseClass(BasePanel)

function WingPanel:__init(parent)
    self.parent = parent
    self.model = WingsManager.Instance.model
    self.name = "WingPanel"

    self.resList = {
        {file = AssetConfig.backpack_wings, type = AssetType.Main},
        {file = AssetConfig.wing_panel_bg, type = AssetType.Main},
        {file = AssetConfig.wing_textures, type = AssetType.Dep},
        {file = AssetConfig.shouhu_texture, type = AssetType.Dep},
        {file = AssetConfig.playkillbgcycle, type = AssetType.Dep},
    }

    self.updateListener = function() self:Update() end
    self.critListener = function(crit) self:UpdateCrit(crit) end
    self.refreshred = function () self:CheckRed() end

    self.ballList = {}
    self.panelList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function WingPanel:__delete()
    self.OnHideEvent:Fire()
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.upgradeEffect ~= nil then
        self.upgradeEffect:DeleteMe()
        self.upgradeEffect = nil
    end
    if self.powEffect ~= nil then
        self.powEffect:DeleteMe()
        self.powEffect = nil
    end
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
    if self.wingComposite ~= nil then
        self.wingComposite:DeleteMe()
        self.wingComposite = nil
    end
    if self.mergeEffect ~= nil then
        self.mergeEffect:DeleteMe()
        self.mergeEffect = nil
    end
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    if self.panelList ~= nil then
        for _,v in pairs(self.panelList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.panelList = nil
    end
    if self.model.skillPanel ~= nil then
        self.model.skillPanel:DeleteMe()
        self.model.skillPanel = nil
    end
    self:AssetClearAll()
end

function WingPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.backpack_wings))
    UIUtils.AddUIChild(self.parent.transform:Find("Main").gameObject, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    local bg = GameObject.Instantiate(self:GetPrefab(AssetConfig.wing_panel_bg))
    UIUtils.AddBigbg(t:Find("Bg"), bg)
    bg.transform:SetSiblingIndex(0)

    self.tabGroup = TabGroup.New(t:Find("Bg/TabButtonGroup").gameObject, function(index) self:ChangeTab(index) end, {perWidth = 110, perHeight = 37, isVertical = false, cspacing = 5, notAutoSelect = true, noCheckRepeat = true})

    local left = t:Find("Bg/Left")
    self.slider = left:Find("Slider"):GetComponent(Slider)
    self.sliderText = left:Find("Slider/Text"):GetComponent(Text)
    self.nameText = left:Find("Title/Text"):GetComponent(Text)
    self.bottomText = left:Find("Bottom"):GetComponent(Text)
    self.levText = left:Find("Slider/Lev"):GetComponent(Text)
    self.pow = left:Find("Slider/Pow").gameObject
    self.powText = left:Find("Slider/Pow/Text"):GetComponent(Text)
    self.gradeText = left:Find("Grade/Text"):GetComponent(Text)
    self.previewContainer = left:Find("Preview")
    self.ballContainer = left:Find("BallList")
    for i=1,10 do
        local tab = {}
        tab.transform = self.ballContainer.transform:GetChild(i - 1)
        tab.gameObject = tab.transform.gameObject
        tab.selectImage = tab.transform:Find("Select"):GetComponent(Image)
        tab.normalImage = tab.transform:Find("Normal"):GetComponent(Image)
        tab.lev = tab.transform:Find("LevBg").gameObject
        tab.levText = tab.transform:Find("LevBg/LevText"):GetComponent(Text)
        tab.button = tab.gameObject:GetComponent(Button)
        tab.button.onClick:AddListener(function() self:OnBallNotice() end)
        self.ballList[i] = tab
    end

    -- self.ballContainerImage.fillAmount = 0
    self.bottomText.alignment = 4

    local right = t:Find("Bg/Right")
    self.infoObj = right:Find("Info").gameObject
    self.skillObj = right:Find("Skill").gameObject

    -- t:Find("Close"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)

    self.panelList[1] = WingInfoPanel.New(self.model, right:Find("Info").gameObject, self.assetWrapper)
    self.panelList[3] = WingsSkillInfo.New(self.model, right:Find("Skill").gameObject, self.assetWrapper)

    for _,panel in pairs(self.panelList) do
        if panel ~= nil then
            panel.gameObject:SetActive(false)
        end
    end
    self.pow.gameObject:SetActive(false)

    -- left:Find("Handbook"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.wing_book) end)

end

function WingPanel:CheckWingGuide()
    local quest = QuestManager.Instance:GetQuest(22222)
    if quest ~= nil and quest.finish ~= QuestEumn.TaskStatus.Finish then
        return true
    end
    return false
end
function WingPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function WingPanel:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.role_wings_change, self.updateListener)
    WingsManager.Instance.onUpdateWing:AddListener(self.critListener)
    WingsManager.Instance.onGetReward:AddListener(self.refreshred)

    if self.upgradeEffect ~= nil then
        self.upgradeEffect:SetActive(false)
    end
    self.model.cur_selected_option = WingsManager.Instance.valid_plan
    if self:CheckWingGuide() then
        local upgradeBtn = self.transform:Find("Bg/Right/Info/Upgrade");
        GuideManager.Instance.effect:Hide()
        GuideManager.Instance.effect:Show(upgradeBtn.gameObject, Vector2.zero,WindowConfig.WinID.backpack)
        TipsManager.Instance:ShowGuide({gameObject = upgradeBtn.gameObject, data = TI18N("消耗翅膀灵羽升级翅膀"), forward = TipsEumn.Forward.Left})
    end
    self:Update()
end

function WingPanel:Update()
    self:ReloadWing(WingsManager.Instance.wing_id)
    self:ReloadInfo()
    self:SetTween()

    self.tabGroup:ChangeTab(WingsManager.Instance.lastIndex or self.lastIndex or 1)
    WingsManager.Instance.lastIndex = nil
    self:CheckRed()
end

function WingPanel:OnHide()
    self:RemoveListeners()
    if self.delayId ~= nil then
        LuaTimer.Delete(self.delayId)
        self.delayId = nil
    end
    if self.mergeEffect ~= nil then
        self.mergeEffect:DeleteMe()
        self.mergeEffect = nil
    end
    if self.upgradeEffect ~= nil then
        self.upgradeEffect:DeleteMe()
        self.upgradeEffect = nil
    end
    if self.wingComposite ~= nil then
        self.wingComposite:Hide()
    end
    if self.powId ~= nil then
        LuaTimer.Delete(self.powId)
        self.powId = nil
        self.pow.gameObject:SetActive(false)
    end
    if self.powTweenAlpha ~= nil then
        Tween.Instance:Cancel(self.powTweenAlpha)
        self.powTweenAlpha = nil
    end
    if self.powEffect ~= nil then
        self.powEffect:DeleteMe()
        self.powEffect = nil
    end
end

function WingPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.role_wings_change, self.updateListener)
    WingsManager.Instance.onUpdateWing:RemoveListener(self.critListener)
    WingsManager.Instance.onGetReward:RemoveListener(self.refreshred)
end

function WingPanel:ChangeTab(index)
    if index == 3 and WingsManager.Instance.grade < 8 then
        self.tabGroup:ChangeTab(1)
        NoticeManager.Instance:FloatTipsByString(TI18N("<color='#00ff00'>八阶</color>翅膀可开启强力<color='#ffff00'>翅膀技能</color>"))
    else
        if index == 3 then
            if WingsManager.Instance:CheckSkillRed() then
                WingsManager.Instance.isCheckSkillPanel = true
            end
        elseif index == 2 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.wing_book)
            return
        end
        if self.lastIndex ~= nil then
            self.panelList[self.lastIndex]:Hiden()
        end
        self.lastIndex = index
        self.panelList[index]:Show()
    end

    self:CheckRed()
end

function WingPanel:GotoLevelSlider(lev)
    local lastLev = self.lastLev
    if self.lastGrade ~= nil and WingsManager.Instance.grade > self.lastGrade then
    -- if lev > 1 then
        self:PlayUpgradeSucc()
    elseif self.lastLev ~= nil and self.lastLev ~= WingsManager.Instance.star and lev >= 1 then
        self:PlayMergeSucc()
    end
    local length = #DataWing.data_grade_star[self.lastGrade]
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
        self.lastLev = WingsManager.Instance.star
        self.lastGrade = WingsManager.Instance.grade
        -- self.panelList[1]:Unfreeze()
    end
    if self.slider.value ~= lev then
        self.tweenId = Tween.Instance:ValueChange(self.slider.value, lev, 1, function()
            self.lastGrade = WingsManager.Instance.grade
            self.lastLev = WingsManager.Instance.star
            self.tweenId = nil
            -- self.panelList[1]:Unfreeze()
            self:ReloadInfo()
        end, LeanTweenType.linear,
        function(value)
            self.slider.value = value - math.floor(value)
            -- self.panelList[1]:Freeze()
            if DataWing.data_grade_star[WingsManager.Instance.grade] ~= nil then
                self:SetCircleValue(WingsManager.Instance.grade, ((lastLev - 1) + value) / #DataWing.data_grade_star[WingsManager.Instance.grade])
            end
        end).id
    end
end

function WingPanel:SetTween()
    local grade = nil
    local lev = nil
    local next_grade = nil
    local next_lev = nil
    next_grade,next_lev = WingsManager.Instance:GetNext(WingsManager.Instance.grade, WingsManager.Instance.star)
    -- local value = 0
    -- if WingsManager.Instance.star > 0 then
    --     value = ((WingsManager.Instance.star - 1) + WingsManager.Instance.exp / DataWing.data_upgrade[string.format(TI18N("%s_%s"), WingsManager.Instance.grade, WingsManager.Instance.star)].exp) / #DataWing.data_grade_star[WingsManager.Instance.grade]
    -- end
    -- self:SetCircleValue(WingsManager.Instance.grade, value)

    if self.lastGrade == nil then
        if next_grade == nil then
            -- 满级
            self.slider.value = 1
            self.sliderText.text = TI18N("已满级")
        else
            self.slider.value = WingsManager.Instance.exp / DataWing.data_upgrade[string.format(TI18N("%s_%s"), WingsManager.Instance.grade, WingsManager.Instance.star)].exp
            self.sliderText.text = string.format("%s/%s", WingsManager.Instance.exp, DataWing.data_upgrade[string.format(TI18N("%s_%s"), WingsManager.Instance.grade, WingsManager.Instance.star)].exp)
        end
    else
        local targetValue = nil
        if next_grade == nil then
            -- 满级
            self.slider.value = 1
            self.sliderText.text = TI18N("已满级")
            targetValue = 1
            if self.lastGrade < WingsManager.Instance.grade or self.lastLev < WingsManager.Instance.star then
                grade = self.lastGrade
                lev = self.lastLev
                while grade ~= nil and (grade < WingsManager.Instance.grade or lev < WingsManager.Instance.star) do
                    grade,lev = WingsManager.Instance:GetNext(grade,lev)
                    targetValue = targetValue + 1
                end
            end
        else
            targetValue = WingsManager.Instance.exp / DataWing.data_upgrade[string.format(TI18N("%s_%s"), WingsManager.Instance.grade, WingsManager.Instance.star)].exp

            if self.lastGrade < next_grade or self.lastLev < next_lev then
                grade = self.lastGrade
                lev = self.lastLev
                while grade ~= nil and (grade < WingsManager.Instance.grade or lev < WingsManager.Instance.star) do
                    grade,lev = WingsManager.Instance:GetNext(grade,lev)
                    targetValue = targetValue + 1
                end
            end
        end

        self:GotoLevelSlider(targetValue)
    end

    self.lastLev = WingsManager.Instance.star
    self.lastGrade = WingsManager.Instance.grade
end

function WingPanel:ReloadInfo()
    local cfgData = DataWing.data_base[WingsManager.Instance.wing_id]
    local grade = nil
    local lev = nil
    grade,lev = WingsManager.Instance:GetNext(WingsManager.Instance.grade, WingsManager.Instance.star)

    self.levText.text = string.format("Lv.%s", WingsManager.Instance.star)
    self.gradeText.text = string.format(TI18N("%s阶"), BaseUtils.NumToChn(WingsManager.Instance.grade))

    local name = nil
    for _,v in pairs(DataWing.data_base) do
        if v.grade == WingsManager.Instance.grade + 1 then
            name = v.name
            break
        end
    end
    if name ~= nil then
        if WingsManager.Instance.grade == 0 then
            self.bottomText.text = string.format(TI18N("再升<color='#ffff00'>%s级</color>可激活翅膀外观"), #DataWing.data_grade_star[WingsManager.Instance.grade] - WingsManager.Instance.star + 1)
        else
            self.bottomText.text = string.format(TI18N("再升<color='#ffff00'>%s级</color>可激活下阶翅膀外观"), #DataWing.data_grade_star[WingsManager.Instance.grade] - WingsManager.Instance.star + 1)
        end
    else
        if #DataWing.data_grade_star[WingsManager.Instance.grade] - WingsManager.Instance.star < 2 then
            self.bottomText.text = TI18N("当前已达最高级")
        else
            self.bottomText.text = string.format(TI18N("再升<color='#ffff00'>%s级</color>可达最高级"), #DataWing.data_grade_star[WingsManager.Instance.grade] - WingsManager.Instance.star + 1)
        end
    end
    self.sliderText.text = string.format("%s/%s", WingsManager.Instance.exp, DataWing.data_upgrade[string.format(TI18N("%s_%s"), WingsManager.Instance.grade, WingsManager.Instance.star)].exp)
    self:ReloadCircle()
end

function WingPanel:ReloadCircle()
    local value = 0
    if WingsManager.Instance.star > 0 then
        local next_grade = nil
        local next_lev = nil
        next_grade,next_lev = WingsManager.Instance:GetNext(WingsManager.Instance.grade, WingsManager.Instance.star)
        if next_grade ~= nil then
            if WingsManager.Instance.exp == 0 then
                value = WingsManager.Instance.star / #DataWing.data_grade_star[WingsManager.Instance.grade]
            else
                if WingsManager.Instance.star < #DataWing.data_grade_star[WingsManager.Instance.grade] then
                    value = ((WingsManager.Instance.star - 1) + WingsManager.Instance.exp / DataWing.data_upgrade[string.format(TI18N("%s_%s"), WingsManager.Instance.grade, WingsManager.Instance.star)].exp) / #DataWing.data_grade_star[WingsManager.Instance.grade]
                else
                    value = ((WingsManager.Instance.star - 1) + WingsManager.Instance.exp / DataWing.data_upgrade[string.format(TI18N("%s_%s"), WingsManager.Instance.grade, WingsManager.Instance.star)].exp) / #DataWing.data_grade_star[WingsManager.Instance.grade]
                end
            end
        else
            value = 1
        end
    end
    self:SetCircleValue(WingsManager.Instance.grade, value)
end

function WingPanel:SetCircleValue(grade, value)
    local length = #DataWing.data_grade_star[grade]
    local count = math.ceil(value * length)
    local theta = 90 - (180 / length)
    self.ballContainer.transform.localRotation = Quaternion.Euler(0, 0, theta)
    for i,item in ipairs(self.ballList) do
        if i <= length then
            item.gameObject:SetActive(true)
            item.lev:SetActive(i == count)
            item.transform.anchoredPosition3D = Vector3(-math.cos(math.pi * 2 * (i - 1) / length) * 155, math.sin(math.pi * 2 * (i - 1) / length) * 155, 0)
            if i < count then
                item.normalImage.color = Color(1, 1, 1, 1)
                item.selectImage.gameObject:SetActive(false)
                item.transform.sizeDelta = Vector2(48, 48)
            elseif i == count then
                item.normalImage.color = Color(1, 1, 1, 1)
                item.selectImage.gameObject:SetActive(false)
                item.transform.sizeDelta = Vector2(64, 64)
                item.levText.text = string.format("Lv.%s", i)
                self:ShowEffect(item.transform)
            elseif i > count then
                item.normalImage.color = Color(1, 1, 1, 0.3)
                item.selectImage.gameObject:SetActive(false)
                item.transform.sizeDelta = Vector2(48, 48)
            end
            item.transform.localRotation = Quaternion.Euler(0, 0, 360 - theta)
        else
            item.gameObject:SetActive(false)
        end
    end

    if count == 0 then
        if self.effect ~= nil then
            self.effect:DeleteMe()
            self.effect = nil
        end
    end
    -- if star > 0 then
    --     self.ballContainerImage.fillAmount = ((star - 1) + exp / DataWing.data_upgrade[string.format(TI18N("%s_%s"), grade, star)].exp) / length
    -- else
    --     self.ballContainerImage.fillAmount = 0
    -- end
    -- self.ballContainerImage.fillAmount = value
end

function WingPanel:ReloadWing(wingId)
    if self.wingComposite ~= nil and wingId == self.showWingId then
        self.wingComposite:Show()
        return
    end

    local cfgData = DataWing.data_base[wingId]
    if cfgData == nil then
        cfgData = DataWing.data_base[20000]
    end

    self.nameText.text = cfgData.name

    local modelData = {type = PreViewType.Wings, looks = {{looks_type = SceneConstData.looktype_wing, looks_val = cfgData.wing_id}}}

    self.setting = self.setting or {
        name = "wing"
        ,orthographicSize = 0.6
        ,width = 341
        ,height = 300
        ,offsetY = -0.1
        ,noDrag = true
    }

    self.wingCallback = self.wingCallback or function(comp)
        comp.rawImage.transform:SetParent(self.previewContainer)
        comp.rawImage.transform.localScale = Vector3.one
        comp.rawImage.transform.localPosition = Vector3.zero
    end
    if self.wingComposite ~= nil then
        self.wingComposite:Show()
        self.wingComposite:Reload(modelData, self.wingCallback)
    else
        self.wingComposite = PreviewComposite.New(self.wingCallback, self.setting, modelData)
    end

    self.showWingId = wingId
end

function WingPanel:PlayMergeSucc()
    -- -- if self.lastGrade ~= nil and WingsManager.Instance.grade > self.lastGrade then
    --     if self.mergeEffect ~= nil then
    --         self.mergeEffect:SetActive(false)
    --         self.mergeEffect:SetActive(true)
    --     else
    --     end

    --     self.delayId = LuaTimer.Add(2000, function()
    --         if self.mergeEffect ~= nil then
    --             self.mergeEffect:SetActive(false)
    --         end
    --     end)
    -- -- end
    if self.mergeEffect ~= nil then
        self.mergeEffect:DeleteMe()
        self.mergeEffect = nil
    end
    self.mergeEffect = BibleRewardPanel.ShowEffect(20167, self.previewContainer, Vector3(1, 1, 1), Vector3(0, 0, -400))
end

function WingPanel:PlayUpgradeSucc()
    -- if self.upgradeEffect ~= nil then
    --     self.upgradeEffect:SetActive(false)
    --     self.upgradeEffect:SetActive(true)
    -- else
    --     self.upgradeEffect = BibleRewardPanel.ShowEffect(20060, self.previewContainer, Vector3(1, 1, 1), Vector3(0, 0, -400))
    -- end
    if self.upgradeEffect ~= nil then
        self.upgradeEffect:DeleteMe()
        self.upgradeEffect = nil
    end
    self.upgradeEffect = BibleRewardPanel.ShowEffect(20060, self.previewContainer, Vector3(1, 1, 1), Vector3(0, 0, -400))
end

function WingPanel:ReloadPanel()
    self.tabGroup:ChangeTab( self.lastIndex or 1)
end

function WingPanel:CheckRed()
    self.tabGroup:ShowRed(3, WingsManager.Instance:CheckSkillRed() and not WingsManager.Instance.isCheckSkillPanel)
    self.tabGroup:ShowRed(2, WingsManager.Instance:CheckCollectRed())
    -- WingsManager.Instance.onUpdateRed:Fire()
end

function WingPanel:UpdateCrit(crit)
    if crit ~= nil and crit > 1 then
        self.pow:SetActive(true)
        self.pow:GetComponent(CanvasRenderer):SetAlpha(1)
        self.powText.text = string.format("X%s", crit)
        if self.powId ~= nil then
            LuaTimer.Delete(self.powId)
            self.powId = nil
        end
        if self.powTweenAlpha ~= nil then
            Tween.Instance:Cancel(self.powTweenAlpha)
            self.powTweenAlpha = nil
        end
        self:ShowPowEffect()
        self.powId = LuaTimer.Add(1600, function()
            self.powId = nil
            self.powTweenAlpha = Tween.Instance:Alpha(self.pow.gameObject, 0, 0.5, function() self.pow.gameObject:SetActive(false) self.powTweenAlpha = nil end, LeanTweenType.linear).id
        end)
    else
        self.pow.gameObject:SetActive(false)
    end
end

function WingPanel:ShowEffect(parent)
    if self.effect == nil then
        self.effect = BaseUtils.ShowEffect(20430, parent.transform, Vector3.one, Vector3(0, 0, -200))
    elseif self.effect.transform ~= nil then
        self.effect.transform:SetParent(parent.transform)
        self.effect.transform.localPosition = Vector3(0, 0, -400)
    end
end

function WingPanel:ShowPowEffect()
    if self.powEffect ~= nil then
        self.powEffect:DeleteMe()
    end
    self.powEffect = BaseUtils.ShowEffect(20220, self.pow.transform, Vector3.one, Vector3(0, 0, -200))
end

function WingPanel:OnBallNotice()
    local name = nil
    for _,v in pairs(DataWing.data_base) do
        if v.grade == WingsManager.Instance.grade + 1 then
            name = v.name
            break
        end
    end
    local str = nil
    if name ~= nil then
        if WingsManager.Instance.grade == 0 then
            str = string.format(TI18N("再升<color='#ffff00'>%s级</color>可激活翅膀外观"), #DataWing.data_grade_star[WingsManager.Instance.grade] - WingsManager.Instance.star + 1)
        else
            str = string.format(TI18N("再升<color='#ffff00'>%s级</color>可激活下阶翅膀外观"), #DataWing.data_grade_star[WingsManager.Instance.grade] - WingsManager.Instance.star + 1)
        end
    else
        if #DataWing.data_grade_star[WingsManager.Instance.grade] - WingsManager.Instance.star < 2 then
            str = TI18N("恭喜你达到最高阶")
        else
            str = string.format(TI18N("再升<color='#ffff00'>%s级</color>可达最高级"), #DataWing.data_grade_star[WingsManager.Instance.grade] - WingsManager.Instance.star + 1)
        end
    end
    NoticeManager.Instance:FloatTipsByString(str)
end
