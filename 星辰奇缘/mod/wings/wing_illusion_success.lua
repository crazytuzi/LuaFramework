-- @author 黄耀聪
-- @date 2017年5月31日

WingIllusionSuccess = WingIllusionSuccess or BaseClass(BasePanel)

function WingIllusionSuccess:__init(model)
    self.model = model
    self.name = "WingIllusionSuccess"

    self.resList = {
        {file = AssetConfig.wing_illusion_success, type = AssetType.Main},
        {file = AssetConfig.totembg, type = AssetType.Dep},
        {file = AssetConfig.attr_icon, type = AssetType.Dep},
    }

    self.propertyList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function WingIllusionSuccess:__delete()
    self.OnHideEvent:Fire()
    if self.wingComposite ~= nil then
        self.wingComposite:DeleteMe()
        self.wingComposite = nil
    end
    self:AssetClearAll()
end

function WingIllusionSuccess:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.wing_illusion_success))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas, self.gameObject)
    self.transform = t

    t:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self.model:CloseIllusion() end)

    local main = t:Find("Main")
    main:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.totembg, "ToTemBg")
    self.nameText = main:Find("Bg/Name"):GetComponent(Text)
    self.previewContainer = main:Find("Preview")

    local property = main:Find("Property")
    for i=1,5 do
        local tab = {}
        tab.transform = property:GetChild(i - 1)
        tab.gameObject = tab.transform.gameObject
        tab.iconImage = tab.transform:Find("Icon"):GetComponent(Image)
        tab.attrText = tab.transform:Find("AttrName"):GetComponent(Text)
        tab.nowText = tab.transform:Find("Now"):GetComponent(Text)
        tab.newText = tab.transform:Find("New"):GetComponent(Text)
        self.propertyList[i] = tab
    end
end

function WingIllusionSuccess:LoadWing(wing_id)
    local cfgData = DataWing.data_base[wing_id]
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
end

function WingIllusionSuccess:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function WingIllusionSuccess:OnOpen()
    self:RemoveListeners()
end

function WingIllusionSuccess:OnHide()
    self:RemoveListeners()
end

function WingIllusionSuccess:RemoveListeners()
end


