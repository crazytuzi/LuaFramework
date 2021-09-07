--2017/1/10
--zzl
--宠物洗髓
PetWashWindow  =  PetWashWindow or BaseClass(BaseWindow)

function PetWashWindow:__init(model)
    self.name = "PetWashWindow"
    self.model = model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.pet_wash_window, type  =  AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
        ,{file = string.format(AssetConfig.effect, 20260), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }

    self.windowId = WindowConfig.WinID.pet_wash

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.isInit = false

    local setting = {
        name = "PetWashWindow"
        ,orthographicSize = 1
        ,width = 328
        ,height = 341
        ,offsetY = -0.4
    }
    self.leftModelData = nil
    self.leftModelPreview = nil
    self.leftPreviewComposite = PreviewComposite.New(nil, setting, {})
    self.leftPreviewComposite:BuildCamera(true)

    self.rightModelData = nil
    self.rightModelPreview = nil
    self.rightPreviewComposite = PreviewComposite.New(nil, setting, {})
    self.rightPreviewComposite:BuildCamera(true)

    self.leftTimeIdPlayAction = nil
    self.leftTimeIdPlayIdleAction = nil
    self.rightTimeIdPlayAction = nil
    self.rightTimeIdPlayIdleAction = nil
    self.curRightData = nil
    self.sliderTweenIdList = {0, 0, 0, 0, 0}
    self.leftSliderFenmuList = {0, 0, 0, 0, 0}
    self.recommendValList = {0, 1, 1.05, 1.1, 1.2}
    self.playEffectFinish = true
    self.effectTimeId = 0
    self.guideScript = nil
    self.saveFinishLocationTweenId = 0
    self.saveFinishAlphaTweenId = 0
    self.saveFinishLeftAlphaTweenId = 0
    self.isClickWash = false
    self.toggleWashManual = 0
    self.freeStatus = false
    self.sliderFunList = {
        [1] = function(val) self.rightSliderList[1]:FindChild("Slider"):GetComponent(Slider).value = val end,
        [2] = function(val) self.rightSliderList[2]:FindChild("Slider"):GetComponent(Slider).value = val end,
        [3] = function(val) self.rightSliderList[3]:FindChild("Slider"):GetComponent(Slider).value = val end,
        [4] = function(val) self.rightSliderList[4]:FindChild("Slider"):GetComponent(Slider).value = val end,
        [5] = function(val) self.rightSliderList[5]:FindChild("Slider"):GetComponent(Slider).value = val end,
    }

    self.onUpdateItem = function()
        self:UpdateCost()
    end
    self.onUpdateOne = function()
        self:UpdateView()
    end
    self.onPetTmpAttrUpdate = function(data)
        self:UpdateTmpAttr(data)
    end
    self.onUpdateSave = function(data)
        self:PlaySaveFinish()
    end

    self._onUpdateFreeCount = function(data)
        self:UpdateFreeCount(data)
    end


    self.saveFinishLocationTweened = function()
        self.RightConNotData.gameObject:SetActive(true)
        self.RightCon.gameObject:SetActive(false)
        self.LeftCon:GetComponent(CanvasGroup).alpha = 1
        self.RightCon:GetComponent(CanvasGroup).alpha = 1
        self.RightCon:GetComponent(RectTransform).anchoredPosition = Vector2(197.5, 0)
    end
    return self
end

function PetWashWindow:OnHide()
    self.model.canGuideThree = false
    if self.leftTimeIdPlayIdleAction ~= nil then LuaTimer.Delete(self.leftTimeIdPlayIdleAction) end
    if self.leftTimeIdPlayAction ~= nil then LuaTimer.Delete(self.leftTimeIdPlayAction) end

    if self.rightTimeIdPlayIdleAction ~= nil then LuaTimer.Delete(self.rightTimeIdPlayIdleAction) end
    if self.rightTimeIdPlayAction ~= nil then LuaTimer.Delete(self.rightTimeIdPlayAction) end
end

function PetWashWindow:OnShow()

end

function PetWashWindow:__delete()
    if self.washItemSolt ~= nil then
        self.washItemSolt:DeleteMe()
        self.washItemSolt = nil
    end

    if self.washItemSolt2 ~= nil then
        self.washItemSolt2:DeleteMe()
        self.washItemSolt2 = nil
    end

    if self.guideScript ~= nil then
        self.guideScript:DeleteMe()
        self.guideScript = nil
    end
    if self.BtnWashBuyBtn ~= nil then
        self.BtnWashBuyBtn:DeleteMe()
        self.BtnWashBuyBtn = nil
    end
    self.curRightData = nil
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.onUpdateItem)
    PetManager.Instance.OnPetUpdate:Remove(self.onUpdateOne)
    PetManager.Instance.OnPetTmpAttrUpdate:Remove(self.onPetTmpAttrUpdate)
    PetManager.Instance.OnPetSaveFnish:Remove(self.onUpdateSave)
    PetManager.Instance.OnPetWashFreeCount:Remove(self._onUpdateFreeCount)
    for i=1,5 do
        Tween.Instance:Cancel(self.sliderTweenIdList[i])
    end
    Tween.Instance:Cancel(self.saveFinishLocationTweenId)
    Tween.Instance:Cancel(self.saveFinishAlphaTweenId)
    Tween.Instance:Cancel(self.saveFinishLeftAlphaTweenId)

    -- 你的宠物未保存新的资质
    for _, data in ipairs(self.leftSkillList) do
        data:DeleteMe()
        data = nil
    end
    for _, data in ipairs(self.rightSkillList) do
        data:DeleteMe()
        data = nil
    end
    if self.leftTimeIdPlayIdleAction ~= nil then LuaTimer.Delete(self.leftTimeIdPlayIdleAction) end
    if self.leftTimeIdPlayAction ~= nil then LuaTimer.Delete(self.leftTimeIdPlayAction) end

    if self.rightTimeIdPlayIdleAction ~= nil then LuaTimer.Delete(self.rightTimeIdPlayIdleAction) end
    if self.rightTimeIdPlayAction ~= nil then LuaTimer.Delete(self.rightTimeIdPlayAction) end
    if self.leftPreviewComposite ~= nil then
        self.leftPreviewComposite:DeleteMe()
        self.leftPreviewComposite = nil
    end

    if self.rightPreviewComposite ~= nil then
        self.rightPreviewComposite:DeleteMe()
        self.rightPreviewComposite = nil
    end

    self.OnOpenEvent:RemoveAll()
    self.isInit = false
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function PetWashWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pet_wash_window))
    self.gameObject:SetActive(false)
    self.gameObject.name = "PetWashWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.transform = self.gameObject.transform
    -- self.transform:GetComponent(RectTransform).localPosition = Vector3.zero
    self.MainCon = self.transform:Find("MainCon")
    local closeBtn = self.MainCon:Find("CloseButton"):GetComponent(Button)
    closeBtn.onClick:AddListener(function()
        self.model:ClosepetWashWindow()
    end)
    self.gameObject:SetActive(true)

    self.transform:FindChild("GiftTips"):GetComponent(Button).onClick:AddListener(function() self:HideGiftImageTips() end)
    --左边逻辑
    self.TopCon = self.MainCon:Find("TopCon")
    self.LeftCon = self.TopCon:Find("LeftCon")
    self.LeftModelCon = self.LeftCon:Find("ModelCon")
    self.LeftPreview = self.LeftModelCon:Find("Preview")
    self.LeftNameText = self.LeftModelCon:Find("NameText"):GetComponent(Text)
    self.LeftGenreImage = self.LeftModelCon:Find("GenreImage"):GetComponent(Image)
    self.LeftGifeText = self.LeftModelCon:Find("GifeText"):GetComponent(Text)
    self.LeftLockBtn = self.LeftModelCon:Find("LockBtn"):GetComponent(Button)
    self.LeftBtnSelectPet = self.LeftModelCon:Find("BtnSelectPet"):GetComponent(Button)

    self.LeftQualityCon = self.LeftCon:Find("QualityCon")
    self.TopCon:Find("GrowthCon/GrowthImage"):GetComponent(Button).onClick:AddListener(function() self:ShowGiftImageTips() end)
    self.TopCon:Find("GrowthCon/GrowthText"):GetComponent(Button).onClick:AddListener(function() self:ShowGiftImageTips() end)
    self.LeftGrowthImage = self.TopCon:Find("GrowthCon/GrowthImage"):GetComponent(Image)
    self.LeftGrowthText = self.TopCon:Find("GrowthCon/GrowthText"):GetComponent(Text)
    self.leftSliderList = {}
    self.leftRecommendList = {}
    for i = 1, 5 do
        local recommend = self.LeftQualityCon:Find(string.format("Recommend%s", i)).gameObject
        local slider = self.LeftQualityCon:Find(string.format("ValueSlider%s", i))
        table.insert(self.leftSliderList, slider)
        table.insert(self.leftRecommendList, recommend)
    end

    self.LeftSkillCon = self.LeftCon:Find("SkillCon")
    self.LeftSoltPanel = self.LeftSkillCon:Find("SoltPanel")
    self.LeftSkillContainer = self.LeftSoltPanel:Find("Container")
    self.leftSkillList = {}
    for i = 1, 12 do
        local slotCon = self.LeftSkillContainer:Find(string.format("Solt%s", i))
        local slot = SkillSlot.New()
        table.insert(self.leftSkillList, slot)
        UIUtils.AddUIChild(slotCon.gameObject, slot.gameObject)
    end

    --右边逻辑
    self.RightCon = self.TopCon:Find("RightCon")
    self.RightSaveEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20260)))
    self.RightSaveEffect.transform:SetParent(self.RightCon)
    self.RightSaveEffect.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.RightSaveEffect.transform, "UI")
    -- self.RightSaveEffect.transform.localScale = Vector3(0.9, 1.05, 1)
    self.RightSaveEffect.transform.localScale = Vector3(1, 1, 1)
    self.RightSaveEffect.transform.localPosition = Vector3(0, -19, -400)
    self.RightSaveEffect:SetActive(false)

    self.RightConNotData = self.TopCon:Find("RightConNotData")
    self.RightConNotData.gameObject:SetActive(true)
    self.RightCon.gameObject:SetActive(false)
    self.RightModelCon = self.RightCon:Find("ModelCon")
    self.RightPreview = self.RightModelCon:Find("Preview")
    self.RightNameText = self.RightModelCon:Find("NameText"):GetComponent(Text)
    self.RightGenreImage = self.RightModelCon:Find("GenreImage"):GetComponent(Image)
    self.RightGifeText = self.RightModelCon:Find("GifeText"):GetComponent(Text)
    self.RightLockBtn = self.RightModelCon:Find("LockBtn"):GetComponent(Button)
    self.RightArrowScore = self.RightModelCon:Find("ArrowScore").gameObject
    self.RightTipsLabel = self.RightModelCon:Find("TipsLabel").gameObject
    self.RightQualityCon = self.RightCon:Find("QualityCon")
    self.RightQualityCon:Find("GrowthCon/GrowthImage"):GetComponent(Button).onClick:AddListener(function() self:ShowGiftImageTips() end)
    self.RightQualityCon:Find("GrowthCon/GrowthText"):GetComponent(Button).onClick:AddListener(function() self:ShowGiftImageTips() end)
    self.RightGrowthImage = self.RightQualityCon:Find("GrowthCon/GrowthImage"):GetComponent(Image)
    self.RightGrowthText = self.RightQualityCon:Find("GrowthCon/GrowthText"):GetComponent(Text)
    self.RightArrowGrowth = self.RightQualityCon:Find("ArrowGrowth").gameObject
    self.rightSliderList = {}
    self.rightArrowList = {}
    for i = 1, 5 do
        local slider = self.RightQualityCon:Find(string.format("ValueSlider%s", i))
        local arrow = self.RightQualityCon:Find(string.format("Arrow%s", i)).gameObject
        table.insert(self.rightSliderList, slider)
        table.insert(self.rightArrowList, arrow)
    end

    self.RightTitleGenreImage = self.TopCon:Find("ImgTitle/GenreImage").gameObject
    self.RightSkillCon = self.RightCon:Find("SkillCon")
    self.RightSoltPanel = self.RightSkillCon:Find("SoltPanel")
    self.RightSkillContainer = self.RightSoltPanel:Find("Container")
    self.rightSkillList = {}
    for i = 1, 12 do
        local slotCon = self.RightSkillContainer:Find(string.format("Solt%s", i))
        local slot = SkillSlot.New()
        table.insert(self.rightSkillList, slot)
        UIUtils.AddUIChild(slotCon.gameObject, slot.gameObject)
    end

    --底部逻辑
    self.BottomCon = self.MainCon:Find("BottomCon")
    self.BottomTipsBtn = self.BottomCon:Find("RightCon/DescButton"):GetComponent(Button)
    self.BtnReplace = self.BottomCon:Find("RightCon/BtnReplace"):GetComponent(Button)
    self.BtnWash = self.BottomCon:Find("RightCon/BtnWash")
    self.ItemNumText = self.BottomCon:Find("RightCon/SlotCon1/ItemNumText"):GetComponent(Text)
    self.ItemNumText2 = self.BottomCon:Find("RightCon/SlotCon2/ItemNumText2"):GetComponent(Text)
    self.ItemNameText2 = self.BottomCon:Find("RightCon/SlotCon2/ItemName"):GetComponent(Text)
    self.ItemDesc = self.BottomCon:Find("RightCon/SlotCon2/ItemDesc"):GetComponent(Text)
    self.washItemToggle = self.BottomCon:Find("RightCon/Toggle"):GetComponent(Toggle)
    self.FreeCountText = self.BottomCon:Find("RightCon/FreeCount"):GetComponent(Text)
    self.FreeCountText.fontSize = 17
    self.washItemToggle.onValueChanged:AddListener(function(on)
        if on then
            self.toggleWashManual = 1
        else
            self.toggleWashManual = 2
        end
    end)
    self.washItemSolt = ItemSlot.New()
    UIUtils.AddUIChild(self.BottomCon:Find("RightCon/SlotCon1/SlotCon").gameObject, self.washItemSolt.gameObject)
    self.washItemSolt2 = ItemSlot.New()
    UIUtils.AddUIChild(self.BottomCon:Find("RightCon/SlotCon2/SlotCon").gameObject, self.washItemSolt2.gameObject)
    self.BottomCon:Find("RightCon/SlotCon2").gameObject:SetActive(false)


    self.BtnWash:GetComponent(RectTransform).sizeDelta = Vector2(120, 46)
    self.BtnWashBuyBtn = BuyButton.New(self.BtnWash, TI18N("洗 髓"), false)
    self.BtnWashBuyBtn.key = "PetWash"
    self.BtnWashBuyBtn.protoId = 10505
    self.BtnWashBuyBtn:Show()
    self.BtnWashBuyBtn:Set_btn_img("DefaultButton3")


    self.FreeBtnWash = self.BottomCon:Find("RightCon/BtnWash1"):GetComponent(Button)

    local item_flag = 0

    self.FreeBtnWash.onClick:RemoveAllListeners()
    self.FreeBtnWash.onClick:AddListener(function()
        self:OnWash()
    end)

    --注册监听
    self.LeftLockBtn.onClick:AddListener(function() end)
    self.LeftBtnSelectPet.onClick:AddListener(function() end)
    self.RightLockBtn.onClick:AddListener(function() end)
    self.BtnReplace.onClick:AddListener(function()
        if self.curRightData == nil or self.curRightData.is_valid == 0 then
            NoticeManager.Instance:FloatTipsByString(TI18N("暂无可替换属性"))
            return
        end
        PetManager.Instance:Send10554(self.curPetData.id)
    end)
    -- self.BtnWash.onClick:AddListener(function() end)
    self.BottomTipsBtn.onClick:AddListener(function()
        local tipsData = { TI18N("使用<color='#ffff00'>星辰精华</color>进行洗髓，会出现以下效果：")
            ,TI18N("1.改变宠物的资质和技能")
            ,TI18N("2.有几率<color='#00ff00'>变异</color>，变异后洗髓有几率变回普通宠物")
            ,TI18N("3.变异后可能附带<color='#ffff00'>额外技能</color>")
            ,TI18N("4.变异后可能出现资质最大值<color='#ffff00'>突破基础上限</color>")
            ,TI18N("5.使用<color='#ffff00'>苏醒仙泉</color>洗髓必定使宠物<color='#ffff00'>发生变异</color>")
            ,TI18N("6.使用<color='#ffff00'>仙灵卷轴</color>洗髓必定使变异宠<color='#ffff00'>保持变异</color>")
            ,TI18N("7.洗髓一定次数后将会触发<color='#ffff00'>多技能保底</color>（必定获得4技能，且变异宠物不生效）")
            ,TI18N("8.当天内洗髓每消耗一定量的星辰精华，将会获得一张<color='#ffff00'>仙灵卷轴</color>")
            ,TI18N("9.专有技能<color='#ffff00'>不会</color>被学习技能/洗髓<color='#00ff00'>替换掉</color>，会一直存在")
            ,TI18N("10.<color='#01f803'>【月卡特权：每天前3次洗髓免费】</color>")
        }
        TipsManager.Instance:ShowText({gameObject = self.BottomTipsBtn.gameObject, itemData = tipsData, isChance = true})
        --TipsManager.Instance.model:OpenChancePanel(10001)
        TipsManager.Instance.model:ShowChance({chanceData = {(TI18N("   1.宠物洗髓后有5%概率变异\n   2.宠物洗髓成长概率:\n    蓝  10%   紫  25%\n    橙   34%   红   31%"))}, special = true, isMutil = true})
    end)

    self.isInit = true
    PetManager.Instance.OnPetUpdate:Add(self.onUpdateOne)
    PetManager.Instance.OnPetTmpAttrUpdate:Add(self.onPetTmpAttrUpdate)
    PetManager.Instance.OnPetSaveFnish:Add(self.onUpdateSave)
    PetManager.Instance.OnPetWashFreeCount:Add(self._onUpdateFreeCount)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.onUpdateItem)

    self.OnClickWash = function()
        self:OnWash()
    end
    self.OnPriceBack = function()
        self:OnPrice()
    end

    self.FreeCountText.transform:GetComponent(Button).onClick:AddListener(function()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {4})
    end)

    self:UpdateView()
    self:ChangeCheck()
    PetManager.Instance:Send10555(self.curPetData.id)
    PetManager.Instance:Send10572()
end

function PetWashWindow:ShowGiftImageTips(go)
    if self.curPetData ~= nil then
        self.transform:FindChild("GiftTips").gameObject:SetActive(true)
        self.transform:FindChild("GiftTips/Tips/Text"):GetComponent(Text).text = string.format("%.2f", self.curPetData.growth / 500)
    end
end

function PetWashWindow:HideGiftImageTips()
    self.transform:FindChild("GiftTips").gameObject:SetActive(false)
end

--洗练按钮点击监听
function PetWashWindow:OnWash()
    local petData = self.curPetData
    if petData == nil then return end
    local item_flag = 0
    if self.washItemToggle.isOn then item_flag = 1 end

    self.isClickWash = true
    if not self.model.isnotify_watch then
        if petData.genre == 1 and not self.washItemToggle.isOn then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("宠物已经<color='#ffff00'>发生变异</color>，继续洗髓将有概率将变异宠物变为普通宝宝，是否继续进行洗髓？")
            data.sureLabel = TI18N("同意")
            data.cancelLabel = TI18N("拒绝")
            data.sureCallback = function()
                    self.BtnWashBuyBtn:Freeze()
                    PetManager.Instance:Send10505(petData.id, item_flag)
                    self.model.isnotify_watch = true
                end
            NoticeManager.Instance:ConfirmTips(data)
            return
        end
    end

    -- if not self.model.isnotify_watch_baobao and not self.model.canGuideThree then
    --     if petData.genre == 0 then
    --         local data = NoticeConfirmData.New()
    --         data.type = ConfirmData.Style.Normal
    --         data.content = TI18N("这种宠物是<color='#ffff00'>宝宝</color>，确定要对其进行洗髓吗？")
    --         data.sureLabel = TI18N("同意")
    --         data.cancelLabel = TI18N("拒绝")
    --         data.sureCallback = function()
    --                 self.BtnWashBuyBtn:Freeze()
    --                 PetManager.Instance:Send10505(petData.id, item_flag)
    --                 self.model.isnotify_watch_baobao = true
    --             end
    --         NoticeManager.Instance:ConfirmTips(data)
    --         return
    --     end
    -- end
    self.BtnWashBuyBtn:Freeze()
    PetManager.Instance:Send10505(petData.id, item_flag)
end

--更新
function PetWashWindow:UpdateView()
    self.curPetData = self.model.cur_petdata
    self:UpdateLeft()
    -- self:UpdateRight()
end

--更新左边
function PetWashWindow:UpdateLeft()
    self.LeftNameText.text = self.curPetData.name
    self.LeftGenreImage.sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("I18N_Genre%s", (self.curPetData.genre+1)))
    self.LeftGifeText.text = string.format("%s(%s)", self.model:gettalentclass(self.curPetData.talent), self.curPetData.talent)
    self.LeftGrowthText.text = string.format("%.2f", self.curPetData.growth / 500)
    self.LeftGrowthImage.sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("PetGrowth%s", self.curPetData.growth_type))

    --属性
    local propDic = {
        {self.curPetData.phy_aptitude, self.curPetData.base.phy_aptitude, self.curPetData.max_phy_aptitude},
        {self.curPetData.pdef_aptitude, self.curPetData.base.pdef_aptitude, self.curPetData.max_pdef_aptitude},
        {self.curPetData.hp_aptitude, self.curPetData.base.hp_aptitude, self.curPetData.max_hp_aptitude},
        {self.curPetData.magic_aptitude, self.curPetData.base.magic_aptitude, self.curPetData.max_magic_aptitude},
        {self.curPetData.aspd_aptitude, self.curPetData.base.aspd_aptitude, self.curPetData.max_aspd_aptitude}
    }

    for i = 1, #propDic do
        local propData = propDic[i]
        if (propData[1] / propData[2]) > 0.97 then
            self.leftSliderList[i]:FindChild("Text"):GetComponent(Text).text = string.format("<color='#ffffff'>%s/%s</color>", propData[1], propData[3])
        else
            self.leftSliderList[i]:FindChild("Text"):GetComponent(Text).text = string.format("%s/%s", propData[1], propData[3])
        end
        self.leftSliderFenmuList[i] = propData[3]
        self.leftSliderList[i]:FindChild("Slider"):GetComponent(Slider).value = ((propData[1] - propData[2] * 0.8) / (propData[3] - propData[2] * 0.8 + 0.0001) * 0.8 + 0.2)
    end
    for i = 1, 5 do
        self.leftRecommendList[i]:SetActive(table.containValue(self.curPetData.base.recommend_aptitudes, i))
    end

    --技能
    local skills = self.model:makeBreakSkill(self.curPetData.base.id, self.curPetData.skills)
    for i=1,#skills do
        local skilldata = skills[i]
        local icon = self.leftSkillList[i]
        icon.gameObject.name = skilldata.id
        local skill_data = DataSkill.data_petSkill[string.format("%s_1", skilldata.id)]
        icon:SetAll(Skilltype.petskill, skill_data)
        icon:ShowState(skilldata.source == 2)
        icon:ShowLabel(skilldata.source == 4 or skilldata.isBreak, TI18N("<color='#ffff00'>突破</color>"))
        icon:ShowBreak(skilldata.isBreak, TI18N("<color='#FF0000'>未激活</color>"))
    end
    for i=#skills+1,#self.leftSkillList do
        local icon = self.leftSkillList[i]
        icon.gameObject.name = ""
        icon:Default()
        icon:ShowState(false)
        icon.skillData = nil
    end

    --模型
    self:UpdateLeftModel()
end

--更新消耗
function PetWashWindow:UpdateCost()
    if self.curRightData == nil then
        return
    end
    --更新星辰精华
    local cost = self.curPetData.base.cost[1]
    local itembase = BackpackManager.Instance:GetItemBase(cost[1])
    local watchItemData = ItemData.New()
    watchItemData:SetBase(itembase)
    self.washItemSolt:SetAll(watchItemData)
    local neednum = cost[2]
    local num = BackpackManager.Instance:GetItemCount(cost[1])
    self.ItemNumText.text = string.format("%s/%s", num, neednum)
    if num < neednum then
        self.ItemNumText.color = Color.red
    else
        self.ItemNumText.color = Color.green
    end
    self.BtnWashBuyBtn:Layout({[cost[1]] = {need = neednum}}, self.OnClickWash , nil, { antofreeze = false})


    local petData = self.curPetData
    if petData == nil then return end
    local item_flag = 0


    --更新苏醒仙泉和仙灵卷轴
    self.BottomCon:Find("RightCon/SlotCon2").gameObject.gameObject:SetActive(false)
    self.BottomTipsBtn.gameObject.gameObject:SetActive(false)
    self.washItemToggle.gameObject:SetActive(false)
    local cost2 = 0
    local str = ""

    if self.curPetData.genre ~= 1 then
        --当前未变异
        if self.curRightData.is_valid == 0 then
            --无
            cost2 = 29100 --苏醒仙泉
            str = TI18N("使用可变异")
        elseif self.curRightData.tmp_genre ~= 1 then
            --未变异
            cost2 = 29100
            str = TI18N("使用可变异")
        else
            --变异
            cost2 = 29101
            str = TI18N("可保持变异")
        end
    else
        --当前变异
        if self.curRightData.is_valid == 0 then
            --无
            cost2 = 29101
            str = TI18N("可保持变异")
        elseif self.curRightData.tmp_genre ~= 1 then
            --未变异
            cost2 = 29100
            str = TI18N("使用可变异")
        else
            --变异
            cost2 = 29101
            str = TI18N("可保持变异")
        end
    end
    self.ItemDesc.text = str
    local itembase2 = BackpackManager.Instance:GetItemBase(cost2)
    local washItemData2 = ItemData.New()
    washItemData2:SetBase(itembase2)
    self.washItemSolt2:SetAll(washItemData2)
    local num = BackpackManager.Instance:GetItemCount(cost2)
    self.ItemNumText2.text = string.format("%s/%s", num, 1)
    if num < 1 then
        self.ItemNumText2.color = Color.red
    else
        self.ItemNumText2.color = Color.green
    end
    self.ItemNameText2.text = ColorHelper.color_item_name(itembase2.quality, itembase2.name)
    if self.toggleWashManual == 0 then
        -- self.washItemToggle.isOn = num >= 1
        self.washItemToggle.isOn = false
    elseif self.toggleWashManual == 1 then
        self.washItemToggle.isOn = true
    elseif self.toggleWashManual == 2 then
        self.washItemToggle.isOn = false
    end


    -- if num < 1 then --or self.model.cur_petdata.grade ~= 0 or self.curPetData.genre == 1
    --     self.BottomCon:Find("RightCon/SlotCon2").gameObject.gameObject:SetActive(false)
    --     self.washItemToggle.gameObject:SetActive(false)
    --     self.BottomTipsBtn.gameObject.gameObject:SetActive(false)
    --     self.washItemToggle.isOn = false
    -- else
        self.BottomCon:Find("RightCon/SlotCon2").gameObject.gameObject:SetActive(true)
        self.washItemToggle.gameObject:SetActive(true)
        self.BottomTipsBtn.gameObject.gameObject:SetActive(true)
    -- end
end

--播放保存成功效果
function PetWashWindow:PlaySaveFinish()
    self.BtnWashBuyBtn:Set_btn_txt(TI18N("洗 髓"))
    self.BtnReplace.gameObject:SetActive(false)
    local time = 0.3
    Tween.Instance:Cancel(self.saveFinishLocationTweenId)
    Tween.Instance:Cancel(self.saveFinishAlphaTweenId)
    Tween.Instance:Cancel(self.saveFinishLeftAlphaTweenId)
    self.saveFinishLeftAlphaTweenId = Tween.Instance:ValueChange(1, 0, time, nil, LeanTweenType.linear, function(val)
        self.LeftCon:GetComponent(CanvasGroup).alpha = val
    end).id
    self.saveFinishAlphaTweenId = Tween.Instance:ValueChange(1, 0.5, time, nil, LeanTweenType.linear, function(val)
        self.RightCon:GetComponent(CanvasGroup).alpha = val
    end).id
    self.saveFinishLocationTweenId = Tween.Instance:ValueChange(197.5, -197.5, time, self.saveFinishLocationTweened, LeanTweenType.linear, function(val)
        self.RightCon:GetComponent(RectTransform).anchoredPosition = Vector2(val, 0)
    end).id
end

--更新右边
function PetWashWindow:UpdateRight(data)
    self.curRightData = data
    local baseData = self.curPetData.base
    self.BtnWashBuyBtn:ReleaseFrozon()
    --更新底部消耗
    self:UpdateCost()
    if data.is_valid == 0 then
        self.RightConNotData.gameObject:SetActive(true)
        self.RightCon.gameObject:SetActive(false)
        self.BtnWashBuyBtn:Set_btn_txt(TI18N("洗 髓"))

        self.RightSaveEffect:SetActive(false)
        self.BtnReplace.gameObject:SetActive(false)
        return
    end
    self.BtnReplace.gameObject:SetActive(true)

    --特效
    if self.isClickWash then
        self.RightSaveEffect:SetActive(false)
        self.RightSaveEffect:SetActive(true)
        if self.effectTimeId ~= 0 then
            LuaTimer.Delete(self.effectTimeId)
            self.effectTimeId = 0
        end
        self.effectTimeId = LuaTimer.Add(1000, function()
            if self.isInit == false then
                return
            end
            self.RightSaveEffect:SetActive(false)
        end)
        self.isClickWash = false
    end

    local neednum = self.curPetData.base.cost[1][2]
    local num = BackpackManager.Instance:GetItemCount(self.curPetData.base.cost[1][1])
    if num >= neednum then
        self.BtnWashBuyBtn:Set_btn_txt(TI18N("继续洗髓"))
    else
        self.BtnWashBuyBtn:Set_btn_txt(TI18N("洗 髓"))
    end

    self.RightConNotData.gameObject:SetActive(false)
    self.RightCon.gameObject:SetActive(true)

    --设置推荐状态
    self.RightTipsLabel:SetActive(false)
    if data.tmp_growth_type > 2 then
        --推荐
        -- local newVal = data.talent*self.recommendValList[data.tmp_growth_type]/500
        -- local oldVal = self.curPetData.talent*self.recommendValList[self.curPetData.growth_type]/500
        local newVal = data.talent
        local oldVal = self.curPetData.talent
        if newVal > oldVal then
            self.RightTipsLabel:SetActive(true)
        end
    end

    --基础属性
    self.RightNameText.text = self.curPetData.name
    self.RightGenreImage.sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("I18N_Genre%s", (data.tmp_genre+1)))
    self.RightGifeText.text = string.format("%s(%s)", self.model:gettalentclass(data.talent), data.talent)
    self.RightGrowthText.text = string.format("%.2f", data.tmp_growth / 500)
    self.RightGrowthImage.sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("PetGrowth%s", data.tmp_growth_type))
    self:SetArrow(self.curPetData.growth, data.tmp_growth, self.RightArrowGrowth)
    self:SetArrow(self.curPetData.talent, data.talent, self.RightArrowScore)
    if data.tmp_genre == 1 then --变异
        -- self.RightGenreImage
        self.RightTitleGenreImage:SetActive(true)
        self.RightTitleGenreImage.transform.localScale = Vector3.one * 3
        Tween.Instance:Scale(self.RightTitleGenreImage, Vector3.one, 1, nil, LeanTweenType.easeOutElastic)
    else
        self.RightTitleGenreImage:SetActive(false)
    end

    --属性
    for i=1,5 do
        Tween.Instance:Cancel(self.sliderTweenIdList[i])
    end

    local propDic = {
        {data.phy_aptitude, baseData.phy_aptitude, data.max_phy_aptitude},
        {data.pdef_aptitude, baseData.pdef_aptitude, data.max_pdef_aptitude},
        {data.hp_aptitude, baseData.hp_aptitude, data.max_hp_aptitude},
        {data.magic_aptitude, baseData.magic_aptitude, data.max_magic_aptitude},
        {data.aspd_aptitude, baseData.aspd_aptitude, data.max_aspd_aptitude}
    }

    local fun1 = function(value) slider1.value = value end
    for i = 1, #propDic do
        local propData = propDic[i]
        if (propData[1] / propData[2]) > 0.97 then
            self.rightSliderList[i]:FindChild("Text"):GetComponent(Text).text = string.format("<color='#ffffff'>%s/%s</color>", propData[1], propData[3])
        else
            self.rightSliderList[i]:FindChild("Text"):GetComponent(Text).text = string.format("%s/%s", propData[1], propData[3])
        end
        local slider = self.rightSliderList[i]:FindChild("Slider"):GetComponent(Slider)
        local newVal = ((propData[1] - propData[2] * 0.8) / (propData[3] - propData[2] * 0.8 + 0.0001) * 0.8 + 0.2)
        local oldVal = slider.value
        self.sliderTweenIdList[i] = Tween.Instance:ValueChange(slider.value, newVal, 0.3, nil, LeanTweenType.linear, self.sliderFunList[i]).id
        self:SetArrow(self.leftSliderFenmuList[i], propData[3], self.rightArrowList[i])
    end

     --技能
    local skills = self.model:makeBreakSkill(baseData.id, data.tmp_skills)
    for i=1,#skills do
        local skilldata = skills[i]
        local icon = self.rightSkillList[i]
        icon.gameObject.name = skilldata.id
        local skill_data = DataSkill.data_petSkill[string.format("%s_1", skilldata.id)]
        icon:SetAll(Skilltype.petskill, skill_data)
        icon:ShowState(skilldata.source == 2)
        icon:ShowLabel(skilldata.source == 4 or skilldata.isBreak, TI18N("<color='#ffff00'>突破</color>"))
        icon:ShowBreak(skilldata.isBreak, TI18N("<color='#FF0000'>未激活</color>"))
    end
    for i=#skills+1,#self.rightSkillList do
        local icon = self.rightSkillList[i]
        icon.gameObject.name = ""
        icon:Default()
        icon:ShowState(false)
        icon.skillData = nil
    end

    self:UpdateRightModel(data)
end

function PetWashWindow:SetArrow(leftNum, rightNum, arrow)
    if leftNum > rightNum then
        arrow:SetActive(true) --下
        arrow.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow2")
    elseif leftNum < rightNum then
        arrow:SetActive(true) --上
        arrow.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow1")
    else
        arrow:SetActive(false)
    end
end

-------------------模型逻辑
--更新左边模型
function PetWashWindow:UpdateLeftModel()
    local petData = self.curPetData
    local petModelData = self.model:getPetModel(petData)
    local data = {type = PreViewType.Pet, skinId = petModelData.skin, modelId = petModelData.modelId, animationId = petData.base.animation_id, scale = petData.base.scale / 100, effects = petModelData.effects}
    self:LoadLeftpreview(self.LeftPreview, data)
end

function PetWashWindow:LoadLeftpreview(modelPreview, data)
    if not BaseUtils.sametab(data, self.leftModelData) then
        self.leftModelData = data
        self.leftModelPreview = modelPreview
        local leftModelData = BaseUtils.copytab(self.leftModelData)
        self.leftPreviewComposite:Reload(data, function(composite) self:LoadedLeftPreview(composite) end)
    else
        self.leftModelPreview = modelPreview
        local rawImage = self.leftPreviewComposite.rawImage
        rawImage.transform:SetParent(self.leftModelPreview)
        rawImage.transform.localPosition = Vector3(0, 0, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
    end
end

function PetWashWindow:LoadedLeftPreview(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.leftModelPreview)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    composite.tpose.transform.localRotation = Quaternion.identity
    composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))
    if self.leftTimeIdPlayIdleAction ~= nil then LuaTimer.Delete(self.leftTimeIdPlayIdleAction) end
    self.leftTimeIdPlayIdleAction = LuaTimer.Add(0, 15000, function() self:PlayLeftIdleAction() end)
    -- self:showmodeleffectlist()
end

function PetWashWindow:PlayLeftIdleAction()
    if self.leftTimeIdPlayAction == nil and self.leftPreviewComposite ~= nil and self.leftPreviewComposite.tpose ~= nil and self.leftModelData ~= nil then
        local animationData = DataAnimation.data_npc_data[self.leftModelData.animationId]
        self.leftPreviewComposite:PlayMotion(FighterAction.Idle)
    end
end

--更新左边模型
function PetWashWindow:UpdateRightModel(socketData)
    local petData = BaseUtils.copytab(self.curPetData)
    petData.genre = socketData.tmp_genre
    local petModelData = self.model:getPetModel(petData)
    local data = {type = PreViewType.Pet, skinId = petModelData.skin, modelId = petModelData.modelId, animationId = petData.base.animation_id, scale = petData.base.scale / 100, effects = petModelData.effects}
    self:LoadRightpreview(self.RightPreview, data)
end

function PetWashWindow:LoadRightpreview(modelPreview, data)
    if not BaseUtils.sametab(data, self.rightModelData) then
        self.rightModelData = data
        self.rightModelPreview = modelPreview
        local rightModelData = BaseUtils.copytab(self.rightModelData)
        self.rightPreviewComposite:Reload(data, function(composite) self:LoadedRightPreview(composite) end)
    else
        self.rightModelPreview = modelPreview
        local rawImage = self.rightPreviewComposite.rawImage
        rawImage.transform:SetParent(self.rightModelPreview)
        rawImage.transform.localPosition = Vector3(0, 0, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
    end
end

function PetWashWindow:LoadedRightPreview(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.rightModelPreview)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    composite.tpose.transform.localRotation = Quaternion.identity
    composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))
    if self.rightTimeIdPlayIdleAction ~= nil then LuaTimer.Delete(self.rightTimeIdPlayIdleAction) end
    self.rightTimeIdPlayIdleAction = LuaTimer.Add(0, 20000, function() self:PlayRightIdleAction() end)
    -- self:showmodeleffectlist()
end

function PetWashWindow:PlayRightIdleAction()
    if self.rightTimeIdPlayAction == nil and self.rightPreviewComposite ~= nil and self.rightPreviewComposite.tpose ~= nil and self.rightModelData ~= nil then
        local animationData = DataAnimation.data_npc_data[self.rightModelData.animationId]
        self.rightPreviewComposite:PlayMotion(FighterAction.Idle)
    end
end

-- function PetWashWindow:showmodeleffectlist()
--     for k,v in pairs(self.model_effect_list) do
--         self:showmodeleffect(v)
--     end
--     self.model_effect_list = {}
-- end

-- function PetWashWindow:showmodeleffect(effectid)
--     if self.previewComposite.tpose ~= nil then
--         print( string.format("effectid %s ", effectid))
--         local fun = function(effectView)
--             -- bugly #29717687 hosr 20160722
--             if BaseUtils.isnull(self.previewComposite) or BaseUtils.isnull(self.previewComposite.tpose) then
--                 GameObject.Destroy(effectView.gameObject)
--                 return
--             end

--             local effectObject = effectView.gameObject

--             effectObject.transform:SetParent(self.previewComposite.tpose.transform)
--             effectObject.transform.localScale = Vector3.one
--             effectObject.transform.localPosition = Vector3.zero
--             effectObject.transform.localRotation = Quaternion.identity

--             effectObject.transform:SetParent(PreviewManager.Instance.container.transform)

--             Utils.ChangeLayersRecursively(effectObject.transform, "ModelPreview")
--         end
--         BaseEffectView.New({effectId = effectid, time = 1000, callback = fun})
--     end
-- end

function PetWashWindow:UpdateTmpAttr(data)
    if data.id == self.cur_petdata then
        self:UpdateRight(data)
    else
        self.curPetData = self.model:getpet_byid(data.id)
        self:UpdateLeft()
        self:UpdateRight(data)
    end
end

-------------引导逻辑
function PetWashWindow:ChangeCheck()
    if RoleManager.Instance.RoleData.lev >= 15 and PetManager.Instance.model:getpetid_bybaseid(10003) ~= nil and not PetManager.Instance.isWash then
        local questData = QuestManager.Instance.questTab[10300]
        if questData == nil then
            questData = QuestManager.Instance.questTab[22300]
        end

        local petData,_ = PetManager.Instance.model:getpet_byid(PetManager.Instance.model:getpetid_bybaseid(10003))
        if questData ~= nil and questData.finish ~= QuestEumn.TaskStatus.Finish then
            local data = self.model.cur_petdata
            if self.guideScript ~= nil then
                self.guideScript:DeleteMe()
                self.guideScript = nil
            end
            if data ~= nil and data.base_id == 10003 and petData.status == 0 then
                if self.guideScript == nil then
                    self.model.canGuideThree = true
                    self.guideScript = GuidePetWashThree.New(self)
                    self.guideScript:Show()
                end
            end
        end
    end
end


function PetWashWindow:UpdateFreeCount(data)
    if data ~= nil then
        if  data.flag ==  1 then
            if data.times ~= 0 then
            self.FreeCountText.text = string.format(TI18N("<color='#ffff00'>剩余次数（%d/3）</color>"),data.times)
            self.freeStatus = true
            else
                self.FreeCountText.text = string.format(TI18N("<color='#e8e8e8'>免费次数用完</color>"))
                self.freeStatus = false
            end
        else
            self.FreeCountText.text = string.format(TI18N("<color='#00ff00'>月卡特权</color><color='#e8e8e8'>（未开启）</color>"))
            self.freeStatus = false
        end
    end
    self.FreeBtnWash.gameObject:SetActive(self.freeStatus)
end
