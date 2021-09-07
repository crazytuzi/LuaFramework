-- 家园Canvas
HomeCanvasView = HomeCanvasView or BaseClass(BaseView)

function HomeCanvasView:__init()
    self.model = model
    self.winLinkType = WinLinkType.Single
    self.resList = {
        {file = AssetConfig.homecanvas, type = AssetType.Main}
        , {file = AssetConfig.homeTexture, type = AssetType.Dep}
        , {file = AssetConfig.homeshadowmaterials, type = AssetType.Main}
        , {file = AssetConfig.homeshadowTexture, type = AssetType.Dep}
    }

    self.name = "HomeCanvasView"

    self.gameObject = nil
    self.transform = nil

    self.HoldEffect = nil
    self.Grid = nil
    self.UI = nil
    self.ExtendMainUIButton = nil
    self.timerId = 0

    self.rect = nil

    self.girdSize = 0

    self.home_shader_material = {}

    self:LoadAssetBundleBatch()
end

function HomeCanvasView:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    HomeManager.Instance.canvasInit = false

    self:AssetClearAll()
end

function HomeCanvasView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.homecanvas))
    self.gameObject.name = "HomeCanvasView"
    self.gameObject.transform:SetParent(ctx.CanvasContainer.transform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    local rect = self.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1500)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 0)
    rect.localScale = Vector3.one
    self.rect = rect

    self.transform = self.gameObject.transform

    self.HoldEffect = self.gameObject.transform:Find("HoldEffect").gameObject

    self.Grid = self.gameObject.transform:Find("Grid").gameObject

    self.UnitUI = self.gameObject.transform:Find("UnitUI").gameObject

    self.UIPanel = self.gameObject.transform:Find("UIPanel").gameObject
    self.GridPanel = self.gameObject.transform:Find("GridPanel").gameObject

    self.ExtendMainUIButton = self.gameObject.transform:Find("ExtendMainUIButton").gameObject
    self:InitExtendMainUIButton()

    self.functionButton = self.gameObject.transform:Find("UIPanel/FunctionButton").gameObject
    local btn = self.functionButton.transform:Find("Button"):GetComponent(Button)
    btn.onClick:AddListener(function() HomeManager.Instance.homeElementsModel:functionButtonClick() end)

    HomeManager.Instance:ShowCanvas(HomeManager.Instance.isHomeCanvasShow)

    self:InitHomeShaderMaterial()

    HomeManager.Instance.canvasInit = true
    EventMgr.Instance:Fire(event_name.home_canvas_inited)
end

-- 显示长按特效
function HomeCanvasView:ShowHoldEffect(position)
    self.HoldEffect.transform.localPosition = Vector3(position.x, position.y, -200)
    self.HoldEffect:SetActive(true)
end

-- 隐藏长按特效
function HomeCanvasView:HidHoldEffect()
    if self.HoldEffect ~= nil then
        self.HoldEffect:SetActive(false)
    end
end

-- 获取家具格子大小
function HomeCanvasView:GetGirdSize()
    if self.girdSize == 0 then
        local p1 = SceneManager.Instance.MainCamera.camera:WorldToScreenPoint(Vector2(20 * SceneManager.Instance.Mapsizeconvertvalue, 20 * SceneManager.Instance.Mapsizeconvertvalue))
        local p2 = SceneManager.Instance.MainCamera.camera:WorldToScreenPoint(Vector2(40 * SceneManager.Instance.Mapsizeconvertvalue, 40 * SceneManager.Instance.Mapsizeconvertvalue))
        self.girdSize = p2.x - p1.x
    end
    return self.girdSize
end

-- 初始化左侧按钮面板
function HomeCanvasView:InitExtendMainUIButton()
    local buttoncon = self.ExtendMainUIButton.transform:Find("ScrollMask/ButtonCon")
    local switchcon = self.ExtendMainUIButton.transform:Find("SwitchButton")

    for k,v in pairs(DataSystem.data_icon) do
        local button = buttoncon:Find(v.icon_name)
        if not BaseUtils.is_null(button) and v.lev <= RoleManager.Instance.RoleData.lev then
            button:GetComponent(Button).onClick:RemoveAllListeners()
            button:GetComponent(Button).onClick:AddListener(function ()
                MainUIManager.Instance:btnOnclick(v.id)
            end)
        elseif not BaseUtils.is_null(button) then
            button.gameObject:SetActive(false)
        end
    end
    switchcon:Find("OpenButton"):GetComponent(Button).onClick:RemoveAllListeners()
    switchcon:Find("OpenButton"):GetComponent(Button).onClick:AddListener(function ()    self:ShowExtendButton()    end)
    switchcon:Find("CloseButton"):GetComponent(Button).onClick:RemoveAllListeners()
    switchcon:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function ()   self:HideExtendButton()    end)

    buttoncon:Find("MarketIconButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "I18NMarketButtonIcon")
    buttoncon:Find("ShopIconButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "I18NShopButtonIcon")
    buttoncon:Find("DailyButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "I18NAgenda")
    buttoncon:Find("UpgradeButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "I18NUpgradeButtonIcon")
    buttoncon:Find("SettingsIconButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "I18NSettingsButtonIcon2")
end

function HomeCanvasView:HideExtendButton()
    self.ExtendMainUIButton.transform.anchoredPosition = Vector2(-246, -84)
    self.ExtendMainUIButton.transform:Find("SwitchButton/OpenButton").gameObject:SetActive(true)
    self.ExtendMainUIButton.transform:Find("SwitchButton/CloseButton").gameObject:SetActive(false)
    self.ExtendMainUIButton.transform:Find("ScrollMask").gameObject:SetActive(false)
end

function HomeCanvasView:ShowExtendButton()
    self.ExtendMainUIButton.transform.anchoredPosition = Vector2(0, -84)
    self.ExtendMainUIButton.transform:Find("SwitchButton/OpenButton").gameObject:SetActive(false)
    self.ExtendMainUIButton.transform:Find("SwitchButton/CloseButton").gameObject:SetActive(true)
    self.ExtendMainUIButton.transform:Find("ScrollMask").gameObject:SetActive(true)
end

-- 初始化家园影子材质球
function HomeCanvasView:InitHomeShaderMaterial()
    self.home_shader_material = {}
    local material_obj = GameObject.Instantiate(self:GetPrefab(AssetConfig.homeshadowmaterials)).transform
    material_obj:SetParent(self.gameObject.transform)
    material_obj.localPosition = Vector3(-2000, 0, 0)
    material_obj.localScale = Vector3(1, 1, 1)
    -- SceneManager.Instance.sceneElementsModel.instantiate_object.transform:Find("Materials")
    for i=1, 13 do
        table.insert(self.home_shader_material, material_obj:Find("HomeShadow"..i):GetComponent(MeshRenderer).material)
    end
end