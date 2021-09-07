RankWindow = RankWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function RankWindow:__init(model)
    self.model = model

    self.windowId = WindowConfig.WinID.ui_rank
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.rank_window, type = AssetType.Main},
        {file = AssetConfig.rank_textures, type = AssetType.Dep},
        {file = AssetConfig.sing_res, type = AssetType.Dep},
    }

    self.gameObject = nil
    self.transform = nil

    self.mainTransform = nil

    ------------------------------------------------
    self.model_data = nil

    self.currentIndex = 1

    self.childIndex = {
        rank = 1,
        achievement = 2,
    }
    self.tabData = {
        [self.childIndex.rank] = {name = TI18N("排行"), icon = "Rankicon"},
        [self.childIndex.achievement] = {name = TI18N("成就"), icon = "Achieve"},
    }

    ------------------------------------------------
    self.tabGroup = nil
    self.tabGroupObj = nil

    self.childTab = {}
    self.headbar = nil

    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function RankWindow:__delete()
    self:OnHide()

    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end

    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end

    for k,v in pairs(self.childTab) do
        if v ~= nil then
            v:DeleteMe()
            self.childTab[k] = nil
        end
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function RankWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.rank_window))
    self.gameObject.name = "RankWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.tabGroupObj = self.mainTransform:FindChild("TabButtonGroup")
    self.tabCloner = self.mainTransform:FindChild("Button").gameObject

    local tabGroupSetting = {
        notAutoSelect = true,
        openLevel = {0, 0},
        perWidth = 46.5,
        perHeight = 114,
        isVertical = true
    }
    for i,v in ipairs(self.tabData) do
        local obj = GameObject.Instantiate(self.tabCloner)
        obj.name = tostring(i)
        obj.transform:SetParent(self.tabGroupObj.transform)
        obj.transform.localScale = Vector3.one
        obj.transform:Find("Normal/Text"):GetComponent(Text).text = v.name
        obj.transform:Find("Select/Text"):GetComponent(Text).text = v.name
        obj.transform:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, v.icon)
    end
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:ChangeTab(index) end, tabGroupSetting)
    self.tabCloner:SetActive(false)
    ----------------------------

    self.OnOpenEvent:Fire()
    self:ClearMainAsset()
end

function RankWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function RankWindow:OnShow()
    self.openArgs = self.model.args
    self.model.args = nil
    local currentIndex = self.currentIndex
    if self.openArgs ~= nil and #self.openArgs > 0 then
        currentIndex = self.openArgs[1]
    end

    self.tabGroup.noCheckRepeat = true
    self.tabGroup:ChangeTab(currentIndex)
    self.tabGroup.noCheckRepeat = false

    self:ShowTabRedPoint()
end

function RankWindow:OnHide()
    if self.headbar ~= nil then
        self.headbar:Hiden()
    end

    for k,v in pairs(self.childTab) do
        if v ~= nil then
            v:Hiden()
        end
    end

    GuideManager.Instance:CloseWindow(self.windowId)
end

function RankWindow:ChangeTab(index)
    if self.currentIndex ~= 0 and self.currentIndex ~= index and self.childTab[self.currentIndex] ~= nil then
        self.childTab[self.currentIndex]:Hiden()
    end
    self.currentIndex = index
    local child = self.childTab[self.currentIndex]
    if child == nil then
        if index == self.childIndex.rank then
            child = RankPanel.New(self)
        elseif index == self.childIndex.achievement then
            child = AchievementView.New(self)
        else
            child = RankPanel.New(self)
        end
        self.childTab[self.currentIndex] = child
    end
    child:Show()
end

function RankWindow:ShowTabRedPoint()
    local show = AchievementManager.Instance.model:getRedPoint()
    self.tabGroup:ShowRed(2, show)
end