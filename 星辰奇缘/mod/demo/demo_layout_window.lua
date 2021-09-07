DemoLayoutWindow = DemoLayoutWindow or BaseClass(BaseWindow)

function DemoLayoutWindow:__init(model)
    self.model = model
    self.name = "DemoLayoutWindow"
    -- 缓存
    self.cacheMode = CacheMode.Visible
    self.holdTime = 10
    self.resList = {
        {file = AssetConfig.demo_layout_window, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }

    self.name = "DemoLayoutWindow"
    self.closeBut = nil

    self.gridPanel = nil
    self.vPanel = nil
    self.hPanel = nil

    self.gridLayout = nil
    self.boxXLayout = nil
    self.boxYLayout = nil
end

function DemoLayoutWindow:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    -- 卸载资源 非依赖资源可以在UI创建完就可以卸载
    self:AssetClearAll()

    self.gridLayout:DeleteMe()
    self.gridLayout = nil
    self.boxXLayout:DeleteMe()
    self.boxXLayout = nil
    self.boxYLayout:DeleteMe()
    self.boxYLayout = nil
end

function DemoLayoutWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.demo_layout_window))
    self.gameObject:SetActive(false)
    self.gameObject.name = "DemoLayWindow"
    self.gameObject.transform:SetParent(ctx.CanvasContainer.transform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)
    self.closeBut = self.gameObject.transform:FindChild("Window/Close").gameObject
    self.closeBut:GetComponent(Button).onClick:AddListener(function() self:OnCloseButtonClick() end)

    self.gridPanel = self.gameObject.transform:FindChild("Window/Grid/Container").gameObject
    self.hPanel = self.gameObject.transform:FindChild("Window/Horizontal/Container").gameObject
    self.vPanel = self.gameObject.transform:FindChild("Window/Vertical/Container").gameObject
    self.gameObject:SetActive(true)

    self:TestGridLayout()
    self:TestBoxXLayout()
    self:TestBoxYLayout()

    -- 非依赖资源，UI创建完就可以卸载
    self:ClearMainAsset()

    -- 测试NPC模型加载
    self:TestNpcModel()
end

function DemoLayoutWindow:OnCloseButtonClick()
    self.model:CloseLayoutWindow()
end

function DemoLayoutWindow:TestGridLayout()
    local setting = {
        column = 5
        ,cspacing = 5
        ,rspacing = 5
        ,cellSizeX = 60
        ,cellSizeY = 60
    }
    self.gridLayout = LuaGridLayout.New(self.gridPanel, setting)
    local cloner = self.gridPanel.transform:FindChild("Cloner").gameObject
    cloner:SetActive(false)
    for i = 1, 30 do
        local cell = GameObject.Instantiate(cloner)
        self.gridLayout:AddCell(cell)
    end
end

function DemoLayoutWindow:TestBoxXLayout()
    local setting = {
        axis = BoxLayoutAxis.X
        ,spacing = 5
    }
    self.boxXLayout = LuaBoxLayout.New(self.hPanel, setting)
    local cloner = self.hPanel.transform:FindChild("Cloner").gameObject
    cloner:SetActive(false)
    for i = 1, 30 do
        local cell = GameObject.Instantiate(cloner)
        self.boxXLayout:AddCell(cell)
    end
end

function DemoLayoutWindow:TestBoxYLayout()
    local setting = {
        axis = BoxLayoutAxis.Y
        ,spacing = 5
    }
    self.boxYLayout = LuaBoxLayout.New(self.vPanel, setting)
    local cloner = self.vPanel.transform:FindChild("Cloner").gameObject
    cloner:SetActive(false)
    for i = 1, 30 do
        local cell = GameObject.Instantiate(cloner)
        self.boxYLayout:AddCell(cell)
    end
end

function DemoLayoutWindow:TestNpcModel()
    local skinId = 30000
    local modelId = 30000
    local animationId = 3000001
    local callback = function(newTpose, animationData)
        self:OnNpcTposeLoaded(newTpose, animationData)
    end
    local loader = NpcTposeLoader.New(skinId, modelId, animationId, 1, callback)

    local roleCallback = function(animationData, tpose, headAnimationData, headTpose)
        self:OnRoleTposeLoaded(animationData, tpose, headAnimationData, headTpose)
    end
    RoleTposeLoader.New(1, 1, {}, roleCallback)
end

function DemoLayoutWindow:OnNpcTposeLoaded(newTpose, animationData)
    local origin = SceneManager.Instance.sceneElementsModel.instantiate_object_npc
    local npc = GameObject.Instantiate(origin)
    newTpose.transform:SetParent(npc.transform)
    newTpose.transform.localPosition = Vector3(0, 0, 0)
end

function DemoLayoutWindow:OnRoleTposeLoaded(animationData, newTpose, headAnimationData, headTpose)
    local origin = SceneManager.Instance.sceneElementsModel.instantiate_object_role
    local role = GameObject.Instantiate(origin)
    newTpose.transform:SetParent(role.transform)
    newTpose.transform.localPosition = Vector3(0, 0, 0)
end

