-- ----------------------------------------------------------
-- UI - 元素副本窗口 
-- ljh 20161215
-- ----------------------------------------------------------
ElementDungeonWindow = ElementDungeonWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function ElementDungeonWindow:__init(model)
    self.model = model
    self.name = "ElementDungeonWindow"
    self.windowId = WindowConfig.WinID.elementdungeonwindow
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
        {file = AssetConfig.elementdungeonwindow, type = AssetType.Main}
        , {file = AssetConfig.elementdungeon_textures, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

	------------------------------------------------
	self.currentIndex = 0
	self.maxIndex = 1

	self.mapItemList = {}

    self.mapList = {}
	------------------------------------------------
    self.cloneItem = nil
    self.ItemBarContainer = nil

	self.moneyPreMinText = nil
    self.moneyNowText = nil
    self.moneyMaxText = nil
    self.energySlider = nil
    self.energyText = nil
    ------------------------------------------------

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function ElementDungeonWindow:__delete()
    self:OnHide()

    for _, mapItem in pairs(self.mapList) do
        mapItem:DeleteMe()
        mapItem = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function ElementDungeonWindow:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.elementdungeonwindow))
    self.gameObject.name = "ElementDungeonWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.cloneItem_ItemBar = self.mainTransform:FindChild("ItemBar/Item").gameObject
    self.cloneItem_ItemBar:SetActive(false)
    self.ItemBarContainer = self.mainTransform:FindChild("ItemBar/mask/Container").gameObject

    self.infoPanel = self.mainTransform:FindChild("InfoPanel").gameObject
    self.moneyPreMinText = self.infoPanel.transform:FindChild("MoneyPreMinText"):GetComponent(Text)
    self.moneyNowText = self.infoPanel.transform:FindChild("MoneyNowText"):GetComponent(Text)
    self.moneyMaxText = self.infoPanel.transform:FindChild("MoneyMaxText"):GetComponent(Text)
    self.energySlider = self.infoPanel.transform:FindChild("EnergySlider"):GetComponent(Slider)
    self.energyText = self.infoPanel.transform:FindChild("EnergyText"):GetComponent(Text)

    self.mapPanel = self.mainTransform:FindChild("MapPanel").gameObject
    self.mapContainer = self.mapPanel.transform:FindChild("Map").gameObject
    self.cloneItem_MapPanel = self.mapPanel.transform:FindChild("Item").gameObject
    self.cloneItem_MapPanel:SetActive(false)
    
    self.enemyPanel = self.transform:FindChild("EnemyPanel").gameObject
    self.enemyPanel.transform:FindChild("Panel"):GetComponent(Button).onClick:AddListener(function() self:HideEnemyPanel() end)
    self.enemyPanel.transform:FindChild("MainCon/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:HideEnemyPanel() end)

    self.nameText_EnemyPanel = self.enemyPanel.transform:FindChild("MainCon/NameText"):GetComponent(Text)
    self.levelText_EnemyPanel = self.enemyPanel.transform:FindChild("MainCon/LevelText"):GetComponent(Text)
    self.OkButtonText_EnemyPanel = self.enemyPanel.transform:FindChild("MainCon/OkButton/Text"):GetComponent(Text)
    self.CancelButtonText_EnemyPanel = self.enemyPanel.transform:FindChild("MainCon/CancelButton/Text"):GetComponent(Text)
    self.OkButton_EnemyPanel = self.enemyPanel.transform:FindChild("MainCon/OkButton"):GetComponent(Button)
    self.OkButton_EnemyPanel.onClick:AddListener(function() self:OnClickOkButton_EnemyPanel() end)
    self.CancelButton_EnemyPanel = self.enemyPanel.transform:FindChild("MainCon/CancelButton"):GetComponent(Button)
    self.CancelButton_EnemyPanel.onClick:AddListener(function() self:OnClickCancelButton_EnemyPanel() end)

    self.preview_EnemyPanel = self.enemyPanel.transform:FindChild("MainCon/Preview")

    local setting = {
        name = "ElementDungeonWindow"
        ,orthographicSize = 1
        ,width = 300
        ,height = 300
        ,offsetY = -0.4
    }
    self.previewComposite = PreviewComposite.New(nil, setting, {})
    self.previewComposite:BuildCamera(true)

    ----------------------------
    self.OnHideEvent:AddListener(function() self.previewComposite:Hide() end)
    self.OnOpenEvent:AddListener(function() self.previewComposite:Show() end)
    ----------------------------

    self:OnShow()
    self:ClearMainAsset()
end

function ElementDungeonWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function ElementDungeonWindow:OnShow()
    -- if self.openArgs ~= nil and #self.openArgs > 0 then
    --     self.currentIndex = self.openArgs[1]
    -- end

    self:Update()
end

function ElementDungeonWindow:OnHide()
	local mapItem = self.mapList[self.currentIndex]
    if mapItem ~= nil then
        mapItem:Hiden()
    end
end

function ElementDungeonWindow:Update()
	self:UpdateBar()
	self:UpdateInfo()
    self:UpdateMapItem()

    -- self:ShowEnemyPanel()
end

function ElementDungeonWindow:UpdateBar()
    local mapItemDataList = { 
        { icon = 1, name = "第一关"}
        , { icon = 1, name = "第二关"}        
        , { icon = 1, name = "第3关"}        
        , { icon = 1, name = "第00000关"}        
    }

    for i=1, 4 do
        local mapItem = self.mapItemList[i]
        local data = mapItemDataList[i]
        if mapItem == nil then
            mapItem = GameObject.Instantiate(self.cloneItem_ItemBar)
            mapItem:SetActive(true)
            mapItem.transform:SetParent(self.ItemBarContainer.transform)
            mapItem:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
            mapItem:GetComponent(Button).onClick:AddListener(function() self:OnMapItemClick(i) end)
            self.mapItemList[i] = mapItem
        end

        mapItem.transform:FindChild("Text"):GetComponent(Text).text = data.name
    end
end

function ElementDungeonWindow:UpdateInfo()

end

function ElementDungeonWindow:UpdateMapItem()
    -- local map = self.mapList[self.currentIndex]
    -- if map ~= nil then
    --     map:Update()
    -- end
end

function ElementDungeonWindow:ShowEnemyPanel()
    self.enemyPanel:SetActive(true)

    local fun = function(composite)
        local rawImage = composite.rawImage
        rawImage.transform:SetParent(self.preview_EnemyPanel)
        rawImage.transform.localPosition = Vector3(0, 0, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
        composite.tpose.transform.localRotation = Quaternion.identity
        composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))
    end

    local data_unit = DataUnit.data_unit[20000]
    local modelData = {type = PreViewType.Npc, skinId = data_unit.skin, modelId = data_unit.res, animationId = data_unit.animation_id, scale = data_unit.scale/100}
    self.previewComposite:Reload(modelData, fun)
end

function ElementDungeonWindow:HideEnemyPanel()
    self.enemyPanel:SetActive(false)
end

function ElementDungeonWindow:OnMapItemClick(index)
    if self.currentIndex ~= 0 and self.currentIndex ~= index then
        self.mapList[self.currentIndex]:Hiden()
    end
    self.currentIndex = index

    local map = self.mapList[self.currentIndex]
    if map == nil then
        map = ElementDungeonMapPanel.New(self.currentIndex, self)
        self.mapList[self.currentIndex] = map
    end
    map:Show()
end