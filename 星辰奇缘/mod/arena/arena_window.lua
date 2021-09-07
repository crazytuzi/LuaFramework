ArenaWindow = ArenaWindow or BaseClass(BaseWindow)

function ArenaWindow:__init(model)
    self.model = model
    self.mgr = ArenaManager.Instance

    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
        {file = AssetConfig.arena_window, type = AssetType.Main}
        , {file = AssetConfig.arena_textures, type = AssetType.Dep}
        , {file = AssetConfig.half_length, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
    }

    self.tabName = {TI18N("竞技"), TI18N("排名")}
    if BaseUtils.IsVerify == true then
        self.tabName = {TI18N("竞技")}
    end
    self.tabObjList = {}

    self.windowId = WindowConfig.WinID.arena_window

    self.checkRedListener = function() self:OnCheckRed() end

    self.subPanel = {}

    self.OnOpenEvent:Add(function() self:OnOpen() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function ArenaWindow:OnHide()
    self:RemoveListeners()
    if self.tabGroup ~= nil and IS_DEBUG then
        self.tabGroup.currentIndex = 0
        for k,v in pairs(self.subPanel) do
            if v ~= nil then
                v:Hiden()
            end
        end
    end
end

function ArenaWindow:__delete()
    if self.gameObject == nil then
        print("第二次进行Delete")
        print(debug.traceback())
    end

    self.OnHideEvent:Fire()
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.model.guardTips ~= nil then
        self.model.guardTips:DeleteMe()
        self.model.guardTips = nil
    end
    if self.subPanel ~= nil then
        for k,v in pairs(self.subPanel) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.subPanel = nil
    end
    if self.model.giftPreview ~= nil then
        self.model.giftPreview:DeleteMe()
        self.model.giftPreview = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ArenaWindow:CloseWin()
    self.model:CloseWin()
end

function ArenaWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.arena_window))
    self.gameObject.name = "ArenaWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.main = t:Find("Main")
    self.tabButtonGroup = self.main:Find("TabButtonGroup")
    self.tabTemplate = self.main:Find("Button").gameObject
    self.tabTemplate:SetActive(false)
    self.main:Find("Close"):GetComponent(Button).onClick:AddListener(function ()

        self:CloseWin()
    end)

    local obj = nil
    for i,v in ipairs(self.tabName) do
        if v ~= nil then
            if self.tabObjList[i] == nil then
                obj = GameObject.Instantiate(self.tabTemplate)
                obj.name = tostring(i)
                self.tabObjList[i] = obj
                obj:SetActive(true)
                t = obj.transform
                t:Find("Normal/Text").anchoredPosition = Vector2(-4,3)
                t:Find("Select/Text").anchoredPosition = Vector2(-4,3)
                t:Find("Normal/Text"):GetComponent(Text).text = self.tabName[i]
                t:Find("Select/Text"):GetComponent(Text).text = self.tabName[i]
                t:SetParent(self.tabButtonGroup)
                t.localScale = Vector3.one
                t.localPosition = Vector3(0, (1 - i) * 100, 0)
            end
        end
    end

    local setting = {
        perWidth = 62
        , perHeight = 100
        , isVertical = true
        , notAutoSelect = true
        , noCheckRepeat = false
        , spacing = 0
    }
    self.tabGroup = TabGroup.New(self.tabButtonGroup.gameObject, function(index) self:ChangeTab(index) end, setting)

    self.OnOpenEvent:Fire()
end

function ArenaWindow:OnOpen()
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end

    self.tabGroup:Init()
    self.tabGroup:ChangeTab(self.model.currentTab)

    self:RemoveListeners()
    self.mgr.onUpdateRed:AddListener(self.checkRedListener)

    self.mgr.onUpdateRed:Fire()
end

function ArenaWindow:ChangeTab(index)
    if self.currentIndex ~= nil and self.subPanel[self.currentIndex] ~= nil then
        self.subPanel[self.currentIndex]:Hiden()
    end
    self.currentIndex = index
    self.model.currentTab = index
    if self.subPanel[index] == nil then
        if index == 2 then
            self.subPanel[index] = ArenaRankPanel.New(self.model, self.main)
        else
            self.subPanel[index] = ArenaFightPanel.New(self.model, self.main)   -- 默认转跳第一页
        end
    end
    self.subPanel[index]:Show()
end

function ArenaWindow:OnCheckRed()
    for k,v in pairs(self.mgr.redPoint) do
        self.tabGroup.buttonTab[k].red:SetActive(v == true)
    end
end

function ArenaWindow:RemoveListeners()
    self.mgr.onUpdateRed:RemoveListener(self.checkRedListener)
end
