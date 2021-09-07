-- @author 黄耀聪
-- @date 2016年7月21日

BackendWindow = BackendWindow or BaseClass(BaseWindow)

function BackendWindow:__init(model)
    self.model = model
    self.name = "BackendWindow"
    self.mgr = BackendManager.Instance
    self.windowId = WindowConfig.WinID.backend
    self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.backend_window, type = AssetType.Main},
        {file = AssetConfig.backend_textures, type = AssetType.Dep},
    }

    self.timeString1 = TI18N("%s后截止")
    self.timeFormat1 = TI18N("%s天%s小时")
    self.timeFormat2 = TI18N("%s小时")
    self.timeFormat3 = TI18N("%s分钟")
    self.timeFormat4 = TI18N("%s秒")
    self.timeString2 = TI18N("活动已结束")

    self.tabData = {}

    self.tabList = {}
    self.panelTypeList = {}
    self.timeListener = function() self:OnTime() end
    self.checkRedListener = function() self:CheckRed() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function BackendWindow:__delete()
    self.OnHideEvent:Fire()
    if self.panelTypeList ~= nil then
        for _,v in pairs(self.panelTypeList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.panelTypeList = nil
    end
    if self.tabList ~= nil then
        for _,v in pairs(self.tabList) do
            if v ~= nil then
                v.icon.sprite = nil
            end
        end
        self.tabList = nil
    end
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
    self.model.windowLastIndex = nil
end

function BackendWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.backend_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    local model = self.model

    local main = t:Find("Main")
    self.close = main:Find("Close"):GetComponent(Button)
    self.verCloner = main:Find("VerTabGroup/Cloner").gameObject
    self.verContainer = main:Find("VerTabGroup/Scroll/Container")
    self.panelContainer = main:Find("Panel")
    self.nothing = self.panelContainer:Find("Nothing").gameObject
    self.titleText = main:Find("Title/Text"):GetComponent(Text)
    self.titleRect = main:Find("Title"):GetComponent(RectTransform)

    self.close.onClick:AddListener(function() self:OnClose() end)
    self.tabGroup = TabGroup.New(self.verContainer.gameObject, function(index) self:ChangeTab(index) end, {isVertical = true, perWidth = 179, perHeight = 70, notAutoSelect = true, noCheckRepeat = false})
    self.verCloner:SetActive(false)
end

function BackendWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function BackendWindow:OnOpen()
    self:RemoveListeners()
    self.timerId = LuaTimer.Add(0, 200, function() self.mgr.onTick:Fire() end)
    self.mgr.onTick:AddListener(self.timeListener)
    self.mgr.onCheckRed:AddListener(self.checkRedListener)

    if self.openArgs == nil then
        self.openArgs = self.model.openArgs
    else
        self.model.openArgs = self.openArgs
    end

    self.campId = tonumber(self.openArgs[1])
    self.iconId = tonumber(self.model.backendCampaignTab[self.campId].ico)

    self:ReloadTab()
    self:CheckRed()

    local index = self.model.windowLastIndex or 1
    if index == 0 then index = 1 end
    self.tabGroup:ChangeTab(index)
end

function BackendWindow:OnHide()
    self:RemoveListeners()
    self.model.windowLastIndex = self.tabGroup.currentIndex
    self.tabGroup.currentIndex = 0
end

function BackendWindow:RemoveListeners()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    self.mgr.onTick:RemoveListener(self.timeListener)
    self.mgr.onCheckRed:RemoveListener(self.checkRedListener)
end

function BackendWindow:OnClose()
    self.model:CloseWindow()
end

function BackendWindow:ChangeTab(index)
    local model = self.model
    local tabData = self.tabData[index]

    if tabData ~= nil then
        self:OpenTypePanel(tabData.campId, tabData.menuId)
    else
        self.nothing:SetActive(true)
    end
end

function BackendWindow:OpenTypePanel(campId, menuId)
    local model = self.model
    local menuData = model.backendCampaignTab[campId].menu_list[menuId]
    local type = tonumber(menuData.panel_type)

    if self.lastType ~= nil then
        self.panelTypeList[self.lastType]:Hiden()
    end
    self.nothing:SetActive(false)

    local panel = self.panelTypeList[type]
    if panel == nil then
        if type == BackendEumn.PanelType.BgList then
            panel = BackendBackgroundList.New(model, self.panelContainer)
        elseif type == BackendEumn.PanelType.TextList then
            panel = BackendTextList.New(model, self.panelContainer)
    -- panel = BackendRankPanel.New(model, self.panelContainer)
        elseif type == BackendEumn.PanelType.Exchange then
            panel = BackendExchangeList.New(model, self.panelContainer)
        elseif type == BackendEumn.PanelType.Continue then
            panel = BackendContinue.New(model, self.panelContainer)
        elseif type == BackendEumn.PanelType.MultiExchange then
            panel = BackendMultipageExchange.New(model, self.panelContainer)
        elseif type == BackendEumn.PanelType.BgShort then
            panel = BackendShortList.New(model, self.panelContainer)
        elseif type == BackendEumn.PanelType.HorizontalList then
            panel = BackendHorizontalList.New(model, self.panelContainer)
        elseif type == BackendEumn.PanelType.MarryEasy then
            panel = BackendMarryEasy.New(model, self.panelContainer)
        elseif type == BackendEumn.PanelType.ImageDesc then
            panel = BackendDescPanel.New(model, self.panelContainer)
        elseif type == BackendEumn.PanelType.Rank then
            panel = BackendRankPanel.New(model, self.panelContainer)
        elseif type == BackendEumn.PanelType.RechargeReturn then
            panel = BackendFeedbackPanel.New(model, self.panelContainer)
        elseif type == BackendEumn.PanelType.Jump then
            local strlist = StringHelper.Split(menuData.tran_info, "|")
            local windowId = tonumber(strlist[1])
            local tab = {}
            for i=2,#strlist do
                table.insert(tab, tonumber(strlist[i]))
            end
            if windowId ~= nil and windowId > 0 then
                WindowManager.Instance:OpenWindowById(windowId, tab)
                return
            end
        end
    end
    self.panelTypeList[type] = panel
    if panel ~= nil then
        panel:Show({campId = campId, menuId = menuId})
        self.lastType = type
    else
        self.nothing:SetActive(true)
    end
end

function BackendWindow:ReloadTab()
    local openLevel = {}
    local model = self.model
    local unreachable = 999

    self.tabData = model:GetTabData(self.campId)
    table.sort(self.tabData, function(a,b) return a.sortIndex > a.sortIndex end)

    for i,v in ipairs(self.tabData) do
        local data = self.tabData[i]
        local tab = self.tabList[i]
        if tab == nil then
            tab = {}
            tab.obj = GameObject.Instantiate(self.verCloner)
            tab.transform = tab.obj.transform
            tab.icon = tab.transform:Find("Icon"):GetComponent(Image)
            tab.text = tab.transform:Find("Text"):GetComponent(Text)
            tab.time = tab.transform:Find("Time"):GetComponent(Text)
            tab.transform:SetParent(self.verContainer)
            tab.transform.localScale = Vector3.one
            tab.red = tab.transform:Find("NotifyPoint").gameObject
            self.tabList[i] = tab
        end
        openLevel[i] = 0
        tab.icon.sprite = self.assetWrapper:GetSprite(AssetConfig.backend_textures, data.icon)
        tab.text.text = data.text
        tab.endTime = model.backendCampaignTab[data.campId].menu_list[data.menuId].end_time
    end
    for i=#self.tabData + 1, #self.tabList do
        openLevel[i] = unreachable
    end
    self.tabGroup.openLevel = openLevel
    self.tabGroup:Init()

    self.titleText.text = model.backendCampaignTab[self.campId].title
    self.titleRect.sizeDelta = Vector2(math.ceil(self.titleText.preferredWidth) + 60, 32)
end

function BackendWindow:ToTime(seconds)
    local d = nil
    local h = nil
    local m = nil
    local s = nil
    if seconds < 0 then
        return self.timeString2
    else
        d,h,m,s = BaseUtils.time_gap_to_timer(seconds)
        if d > 0 then
            return string.format(self.timeString1, string.format(self.timeFormat1, tostring(d), tostring(h)))
        elseif h > 0 then
            return string.format(self.timeString1, string.format(self.timeFormat2, tostring(h)))
        elseif m > 0 then
            return string.format(self.timeString1, string.format(self.timeFormat3, tostring(m)))
        elseif s > 0 then
            return string.format(self.timeString1, string.format(self.timeFormat4, tostring(s)))
        else
            return self.timeString2
        end
    end
end

function BackendWindow:OnTime()
    for i,v in ipairs(self.tabData) do
        if self.tabList[i] ~= nil then
            local str = self:ToTime(self.tabList[i].endTime - BaseUtils.BASE_TIME)
            self.tabList[i].time.text = str
        end
    end
end

function BackendWindow:CheckRed()
    for i,v in ipairs(self.tabList) do
        local data = self.tabData[i]
        local redDic = BackendManager.Instance.redDic[self.iconId] or {}
        v.red:SetActive(redDic[data.menuId] == true)
    end
end

