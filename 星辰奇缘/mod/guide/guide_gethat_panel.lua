-- -----------------------------
-- 领取头饰
-- hosr
-- -----------------------------
GuideGetHatPanel = GuideGetHatPanel or BaseClass(BasePanel)

function GuideGetHatPanel:__init(model)
	self.model = model
    self.effectPath = string.format(AssetConfig.effect, "20245")
    self.effectPath1 = "prefabs/effect/20118.unity3d"
    self.effect = nil
    self.effect1 = nil
    self.resList = {
        {file = AssetConfig.guideheadshow, type = AssetType.Main},
        {file = AssetConfig.wingsbookbg, type = AssetType.Dep},
        {file = self.effectPath, type = AssetType.Main},
        {file = self.effectPath1, type = AssetType.Main},
        {file = AssetConfig.fashionres, type = AssetType.Dep},
        {file = AssetConfig.attr_icon, type = AssetType.Dep},
    }

    self.attrTxtList = {}
    self.attrImgList = {}
    self.count = 0
    self.limitLev = 10
end

function GuideGetHatPanel:__delete()
    self:EndTime()
    self:CancelTween()
	if self.previewComp ~= nil then
		self.previewComp:DeleteMe()
		self.previewComp = nil
	end

	if self.previewCompHat ~= nil then
		self.previewCompHat:DeleteMe()
		self.previewCompHat = nil
	end

    for i,v in ipairs(self.attrImgList) do
        v.sprite = nil
    end
    self.attrImgList = nil
end

function GuideGetHatPanel:Close()
	self.model:CloseGuideGetHat()
end

function GuideGetHatPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guideheadshow))
    self.gameObject.name = "GuideGetHatPanel"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("Main/Left/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.transform:Find("Main/Right/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.right = self.transform:Find("Main/Right").transform

    self.rolePreview = self.transform:Find("Main/Left/Preview").gameObject
    self.hatPreview = self.transform:Find("Main/Right/Preview").gameObject

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.transform:Find("Main/Right/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.title = self.transform:Find("Main/Right/Title/Text"):GetComponent(Text)
    self.btn = self.transform:Find("Main/Right/Button").gameObject
    self.btnTxt = self.btn.transform:Find("Text"):GetComponent(Text)
    self.btn:GetComponent(Button).onClick:AddListener(function() self:ClickBtn() end)
    self.time = self.transform:Find("Main/Right/Time").gameObject
    self.timeTxt = self.time:GetComponent(Text)
    self.transform:Find("Main/Right/Desc"):GetComponent(Text).text = TI18N("使用后永久增加属性")

    table.insert(self.attrTxtList, self.transform:Find("Main/Right/Attr1"):GetComponent(Text))
    table.insert(self.attrTxtList, self.transform:Find("Main/Right/Attr2"):GetComponent(Text))
    table.insert(self.attrImgList, self.transform:Find("Main/Right/Attr1/Image"):GetComponent(Image))
    table.insert(self.attrImgList, self.transform:Find("Main/Right/Attr2/Image"):GetComponent(Image))

    self.fight = self.transform:Find("Main/Right/Fight/Text"):GetComponent(Text)

    self.title.text = TI18N("绝版头饰")
    self.fight.text = TI18N("战力:200")

    self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    self.effect.transform:SetParent(self.right)
    self.effect.transform.localScale = Vector3.one
    self.effect.transform.localPosition = Vector3(-65, 0, -400)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect:SetActive(true)

    self.effect1 = GameObject.Instantiate(self:GetPrefab(self.effectPath1))
    self.effect1.transform:SetParent(self.btn.transform)
    self.effect1.transform.localScale = Vector3(1.5, 1, 1)
    self.effect1.transform.localPosition = Vector3(-75, 28, -400)
    Utils.ChangeLayersRecursively(self.effect1.transform, "UI")
    self.effect1:SetActive(false)

    self:Update()
end

function GuideGetHatPanel:ClickBtn()
    if RoleManager.Instance.RoleData.lev < self.limitLev then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("%s级可领取"),self.limitLev))
    else
        PetManager.Instance:Send10527()
        self:Close()
    end
end

function GuideGetHatPanel:Update()
    self:EndTime()
    self.effect1:SetActive(false)
	if RoleManager.Instance.RoleData.lev < self.limitLev then
		self.btnTxt.text = string.format(TI18N("%s级可领取"),self.limitLev)
        self.timeTxt.text = string.format(TI18N("%s级可领取"),self.limitLev)
        self.btn:SetActive(false)
        self.time:SetActive(true)
	else
        local timeOut = PetManager.Instance.model:GetNextTime()
        if timeOut == 0 then
            self.btn:SetActive(true)
            self.time:SetActive(false)
            self.btnTxt.text = TI18N("马上领取")
            self.effect1:SetActive(true)
        else
            self.btn:SetActive(false)
            self.time:SetActive(true)
            self.btnTxt.text = MainUIManager.Instance.MainUIIconView:GetTimeStr(PetManager.Instance.model:GetNextTime())
            self.count = PetManager.Instance.model:GetNextTime()
            -- self.timeTxt.text = string.format(TI18N("<color='#00ff00'>%s</color>后可领取"), BaseUtils.formate_time_gap(self.count, ":", 0, BaseUtils.time_formate.HOUR))
            self.timeTxt.text = string.format(TI18N("<color='#00ff00'>%s</color>后可领取"), MainUIManager.Instance.MainUIIconView:GetTimeStr(self.count, {id = 205}))
            self:BeginTime()
        end
	end

    local df = DataFashion.data_base[53045]
    if df ~= nil then
        self.fight.text = df.score
        self.title.text = df.name
        for i,v in ipairs(df.attrs) do
            self.attrTxtList[i].text = string.format("<color='#31f2f9'>%s+%s</color>", KvData.attr_name[v.effect_type], v.val)
            self.attrImgList[i].sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon" .. v.effect_type)
        end
    end

	self:UpdatePreview()
	self:UpdateHatPreview()
    self:FloatPreview()
end

function GuideGetHatPanel:BeginTime()
    self.timeId = LuaTimer.Add(0, 1000, function() self:Loop() end)
end

function GuideGetHatPanel:Loop()
    self.count = self.count - 1
    if self.count < 0 then
        self:Update()
    else
        -- self.timeTxt.text = string.format(TI18N("<color='#00ff00'>%s</color>后可领取"), BaseUtils.formate_time_gap(self.count, ":", 0, BaseUtils.time_formate.HOUR))
        self.timeTxt.text = string.format(TI18N("<color='#00ff00'>%s</color>后可领取"), MainUIManager.Instance.MainUIIconView:GetTimeStr(self.count, {id = 205}))
    end
end

function GuideGetHatPanel:EndTime()
    if self.timeId ~= nil then
        LuaTimer.Delete(self.timeId)
        self.timeId = nil
    end
end

function GuideGetHatPanel:UpdatePreview()
    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "GuideGetHatRole"
        ,orthographicSize = 0.6
        ,width = 341
        ,height = 341
        ,offsetY = -0.4
    }
    local llooks = {}
    local mySceneData = SceneManager.Instance:MyData()
    local hasHat = false
    if mySceneData ~= nil then
        for i,v in ipairs(mySceneData.looks) do
        	if v.looks_type == 6 then
                hasHat = true
        		table.insert(llooks, {looks_val = 53045, looks_str = "", looks_mode = 0, looks_type = 6})
        	else
        		table.insert(llooks, v)
        	end
        end
    end

    if not hasHat then
        table.insert(llooks, {looks_val = 53045, looks_str = "", looks_mode = 0, looks_type = 6})
    end

    local modelData = {type = PreViewType.Role, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, looks = llooks}
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
    end
    self.previewComp:Show()
end

function GuideGetHatPanel:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.rolePreview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3.one
    self.rolePreview:SetActive(true)
end

function GuideGetHatPanel:UpdateHatPreview()
    local callback = function(composite)
        self:SetHatRawImage(composite)
    end
    local setting = {
        name = "GuideGetHatRole"
        ,orthographicSize = 0.15
        ,width = 200
        ,height = 200
        ,offsetY = -0.12
        ,noDrag = true
    }
    local llooks = {{looks_val = 53045, looks_str = "", looks_mode = 0, looks_type = 6}}
    local modelData = {type = PreViewType.HeadSurbase, looks = llooks}
    if self.previewCompHat == nil then
        self.previewCompHat = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewCompHat:Reload(modelData, callback)
    end
    self.previewCompHat:Show()
end

function GuideGetHatPanel:SetHatRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.hatPreview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3.one
    composite.tpose.transform:Rotate(Vector3(0, 0, 270))
    self.hatPreview:SetActive(true)
end

function GuideGetHatPanel:FloatPreview()
    self:CancelTween()
    local to = self.hatPreview:GetComponent(RectTransform).anchoredPosition.y + 10
    self.tweenId = Tween.Instance:MoveLocalY(self.hatPreview, to, 1.5, nil, LeanTweenType.linear):setLoopPingPong().id
end

function GuideGetHatPanel:CancelTween()
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
end