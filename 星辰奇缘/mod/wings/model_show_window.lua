-- @author 黄耀聪
-- @date 2017年5月26日

ModelShowWindow = ModelShowWindow or BaseClass(BaseWindow)

function ModelShowWindow:__init(model)
    self.model = model
    self.name = "ModelShowWindow"
    self.windowId = WindowConfig.WinID.model_show_window

    self.texture = AssetConfig.getpet_textures

    self.resList = {
        {file = AssetConfig.model_show_window, type = AssetType.Main},
        {file = AssetConfig.wing_textures, type = AssetType.Dep},
        {file = self.texture, type = AssetType.Dep},
        {file = AssetConfig.getpetbtn, type = AssetType.Dep},
        {file = AssetConfig.getpethalo1, type = AssetType.Dep},
        {file = AssetConfig.getpetlight1, type = AssetType.Dep},
        {file = AssetConfig.geti18ngetwingtitle,type = AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function ModelShowWindow:__delete()
    self.OnHideEvent:Fire()
    if self.wingComposite ~= nil then
        self.wingComposite:DeleteMe()
        self.wingComposite = nil
    end
    self:AssetClearAll()
end

function ModelShowWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.model_show_window))
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    self.titleObj = t:Find("Main/Title").gameObject

    self.previewContainer = t:Find("Main/Preview")

    self.button = t:Find("Main/Button"):GetComponent(Button)
    self.buttonText = t:Find("Main/Button/Text"):GetComponent(Text)
    self.nameText = t:Find("Main/Name"):GetComponent(Text)

    self.halo = t:Find("Main/Halo")
    self.light = t:Find("Main/Light")

    self.button.gameObject:SetActive(false)

     self.halo.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpethalo1,"GetPetHalo1")
    self.light.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpetlight1,"GetPetLight1")
    self.button.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpetbtn,"GetPetBtn")
    self.titleObj.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.geti18ngetwingtitle,"GetI18NGetWingTitle")
    self.button.onClick:AddListener(function()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.backpack, {3})
        -- if DataWing.data_base[self.wing_id].group_id == 100 then
        --     WindowManager.Instance:OpenWindowById(WindowConfig.WinID.backpack, {3})
        -- else
        --     WindowManager.Instance:CloseWindow(self)
        -- end
    end)
end

function ModelShowWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ModelShowWindow:OnOpen()
    self:RemoveListeners()

    self.wing_id = (self.openArgs or {})[1]
    self:ReloadWing(self.wing_id)

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 20, function() self:Rotate() end)
    end

    self.titleObj.transform.localScale = Vector3(0.2, 0.2, 0.2)
    self.button.transform.localScale = Vector3.one * 3

    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
    end
    self.tweenId1 = Tween.Instance:Scale(self.titleObj, Vector3.one, 1,function()
        self.titleObj.transform.localScale = Vector3.one
        self.tweenId1 = nil
    end,
    LeanTweenType.easeOutElastic).id
    -- Tween.Instance:Scale(self.titleObj, Vector3.one, 1, , )
    -- Tween.Instance:Scale(self.button.transform, Vector3.one, 1, function()  end, LeanTweenType.easeOutElastic)
    self.delayId = LuaTimer.Add(600, function()
        self.button.gameObject:SetActive(true)
        self.tweenId2 = Tween.Instance:Scale(self.button.gameObject, Vector3.one, 1, function() self.button.transform.localScale = Vector3.one self.tweenId2 = nil end,LeanTweenType.easeOutElastic).id
    end)
end

function ModelShowWindow:OnHide()
    self:RemoveListeners()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.tweenId1 ~= nil then
        Tween.Instance:Cancel(self.tweenId1)
        self.tweenId1 = nil
    end
    if self.tweenId2 ~= nil then
        Tween.Instance:Cancel(self.tweenId2)
        self.tweenId2 = nil
    end
    if self.delayId ~= nil then
        LuaTimer.Delete(self.delayId)
        self.delayId = nil
    end
end

function ModelShowWindow:RemoveListeners()
end

function ModelShowWindow:ReloadWing(wing_id)
    local cfgData = DataWing.data_base[wing_id]
    if cfgData == nil then
        cfgData = DataWing.data_base[20000]
    end

    local modelData = {type = PreViewType.Wings, looks = {{looks_type = SceneConstData.looktype_wing, looks_val = cfgData.wing_id}}}

    self.setting = self.setting or {
        name = "wing"
        ,orthographicSize = 0.6
        ,width = 341
        ,height = 300
        ,offsetY = -0.1
        ,noDrag = true
    }

    if cfgData.grade < 2000 then
        self.nameText.text = string.format(TI18N("翅膀:%s"), cfgData.name)
    else
        self.nameText.text = string.format(TI18N("激活幻化翅膀:%s"), cfgData.name)
    end

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
end

function ModelShowWindow:Rotate()
    self.count = (self.count or 0) + 1
    self.halo.localRotation = Quaternion.Euler(0, 0, self.count)
end

