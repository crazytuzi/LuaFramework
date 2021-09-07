-- @author 黄耀聪
-- @date 2016年8月8日
-- 公测活动

OpenBetaWindow = OpenBetaWindow or BaseClass(BaseWindow)

function OpenBetaWindow:__init(model)
    self.model = model
    self.name = "OpenBetaWindow"
    self.windowId = WindowConfig.WinID.openbetawindow
    self.mgr = OpenBetaManager.Instance

    self.resList = {
        {file = AssetConfig.open_beta_window, type = AssetType.Main},
        {file = AssetConfig.open_beta_textures, type = AssetType.Dep},
    }

    self.tabData = {
        {id = 309, icon = "Recharge"},
        {id = 310, icon = "Ceremony"},
        {id = 311, icon = "Lotary"},
    }

    self.tabList = {}
    self.panelList = {}
    self.relaodTabListener = function() self:ReloadTab() end
    self.redListener = function() self:CheckRed() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function OpenBetaWindow:__delete()
    self.OnHideEvent:Fire()
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.panelList ~= nil then
        for _,v in pairs(self.panelList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.panelList = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function OpenBetaWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.open_beta_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    local main = t:Find("Main")
    self.closeBtn = main:Find("Close"):GetComponent(Button)
    self.tabContainer = main:Find("TabListPanel")
    self.tabCloner = self.tabContainer:Find("TabButton").gameObject
    self.panelContainer = main:Find("Panel")

    for i,v in ipairs(self.tabData) do
        local tab = {}
        tab.obj = GameObject.Instantiate(self.tabCloner)
        tab.obj.name = tostring(i)
        tab.trans = tab.obj.transform
        tab.text = tab.trans:Find("Text"):GetComponent(Text)
        tab.centerText = tab.trans:Find("CenterText"):GetComponent(Text)
        tab.icon = tab.trans:Find("Icon"):GetComponent(Image)
        tab.trans:SetParent(self.tabContainer)
        tab.trans.localScale = Vector3.one

        if v.icon ~= nil then
            tab.icon.gameObject:SetActive(true)
            tab.text.gameObject:SetActive(true)
            tab.centerText.gameObject:SetActive(false)
            tab.icon.sprite = self.assetWrapper:GetSprite(AssetConfig.open_beta_textures, v.icon)
            tab.text.text = DataCampaign.data_list[v.id].name
        else
            tab.icon.gameObject:SetActive(false)
            tab.text.gameObject:SetActive(false)
            tab.centerText.gameObject:SetActive(true)
            tab.centerText.text = DataCampaign.data_list[v.id].name
        end
    end
    self.tabCloner.transform:SetParent(main)
    self.tabCloner:SetActive(false)

    self.closeBtn.onClick:AddListener(function() self.model:CloseWindow() end)

    self.tabGroup = TabGroup.New(self.tabContainer, function(index) self:ChangeTab(index) end, {notAutoSelect = true, noCheckRepeat = false, perWidth = 112, perHeight = 40, isVertical = false, spacing = 0})
end

function OpenBetaWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function OpenBetaWindow:OnOpen()
    self:RemoveListeners()
    self.timerId = LuaTimer.Add(0, 300, function() self:OnTick() end)
    EventMgr.Instance:AddListener(event_name.campaign_change, self.relaodTabListener)
    self.mgr.onCheckRed:AddListener(self.redListener)

    self.openArgs = self.openArgs or {}
    self:ReloadTab()

    local lev = RoleManager.Instance.RoleData.lev
    local index = self.openArgs[1] or 1
    if lev < self.tabGroup.openLevel[index] then
        for i,v in ipairs(self.tabGroup.openLevel) do
            if lev >= v then
                index = i
                break
            end
        end
    end
    self.tabGroup:ChangeTab(self.openArgs[1] or 1)
    self:CheckRed()
end

function OpenBetaWindow:OnHide()
    self:RemoveListeners()
end

function OpenBetaWindow:RemoveListeners()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    EventMgr.Instance:RemoveListener(event_name.campaign_change, self.relaodTabListener)
    self.mgr.onCheckRed:RemoveListener(self.redListener)
end

function OpenBetaWindow:ChangeTab(index)
    local model = self.model
    if self.lastIndex ~= nil then
        if self.panelList[self.lastIndex] ~= nil then
            self.panelList[self.lastIndex]:Hiden()
        end
    end

    local panel = self.panelList[index]

    if panel == nil then
        if index == 1 then
            panel = OpenBetaCeremony.New(model, self.panelContainer)
        elseif index == 2 then
            panel = OpenBetaRecharge.New(model, self.panelContainer)
        elseif index == 3 then
            panel = OpenBetaLotary.New(model, self.panelContainer)
        end
        self.panelList[index] = panel
    end

    self.lastIndex = index
    if panel ~= nil then
        if OpenBetaManager.Instance.redPointDic[index] == true then
            OpenBetaManager.Instance.hasOpen[index] = true
        end
        panel:Show(self.openArgs)
    end
    self.openArgs = {}
end

function OpenBetaWindow:OnTick()
    self.mgr.onTickTime:Fire()
end

function OpenBetaWindow:CheckRed()
    if self.tabGroup ~= nil and self.tabGroup.buttonTab ~= nil then
        for i,_ in ipairs(self.tabGroup.buttonTab) do
            self.tabGroup:ShowRed(i, self.mgr.redPointDic[i] == true)
        end
    end
end

function OpenBetaWindow:ReloadTab()
    local unreachableLev = 999
    local openLevel = {}
    for i,v in ipairs(self.tabData) do
        if CampaignManager.Instance.campaignTab[v.id] == nil then
            openLevel[i] = unreachableLev
            -- openLevel[i] = 0
        else
            openLevel[i] = 0
        end
    end
    self.tabGroup.openLevel = openLevel
    self.tabGroup:Layout()
end
