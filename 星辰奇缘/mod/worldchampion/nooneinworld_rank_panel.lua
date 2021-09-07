-- 天下第一武道会群雄榜
-- @author zgs
NoOneInWorldRankPanel = NoOneInWorldRankPanel or BaseClass(BasePanel)

function NoOneInWorldRankPanel:__init(model)
    self.model = model
    self.name = "NoOneInWorldRankPanel"
    self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.worldchampionrankpanel, type = AssetType.Main},
    }


    self.OnOpenEvent:Add(function() self:OnOpen() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.currentTabIndex = 1

    self.panelList = {}
end

function NoOneInWorldRankPanel:__delete()
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.model = nil
    self.openArgs = nil
end

function NoOneInWorldRankPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.worldchampionrankpanel))
    self.gameObject.name = "NoOneInWorldRankPanel"
    self.transform = self.gameObject.transform

    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.closeBtn = self.transform:Find("MainCon/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function()
        self:Hiden()
    end)

    self.mainCon = self.gameObject.transform:Find("MainCon")
    self.title = self.gameObject.transform:Find("MainCon/ImgTitle/Text"):GetComponent(Text)
    self:ChangeTitle(TI18N("群雄榜"))
    self.closeBtn = self.gameObject.transform:Find("MainCon/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)
    self.tabGroupObj = self.gameObject.transform:Find("MainCon/TabButtonGroup").gameObject
    local setting = {
        notAutoSelect = true,
        noCheckRepeat = true,
        openLevel = {0, 0, 12},
        perWidth = 62,
        perHeight = 100,
        isVertical = true
    }
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:TabChange(index) end, setting)

    self:OnOpen()
end

function NoOneInWorldRankPanel:OnInitCompleted()
end

function NoOneInWorldRankPanel:OnClickClose()
    --
end

function NoOneInWorldRankPanel:ChangeTitle(str)
    if str ~= nil and str ~= "" then
        self.title.text = str
    end
end

function NoOneInWorldRankPanel:OnOpen()
    if self.openArgs ~= nil then
        self.tabGroup:ChangeTab(self.openArgs[1])
    else
        self.tabGroup:ChangeTab(self.currentTabIndex)
    end
end

function NoOneInWorldRankPanel:OnHide()

end

function NoOneInWorldRankPanel:TabChange(index)
    if self.curPanel ~= nil then
        self.curPanel:Hiden()
    end
    self.currentTabIndex = index
    if self.currentTabIndex == 1 then
        if self.panelList[self.currentTabIndex] == nil then
            self.panelList[self.currentTabIndex] = NoOneAllRankPanel.New(self.model,self.mainCon)
        end
        self.curPanel = self.panelList[self.currentTabIndex]
        self.curPanel:Show(1)
    elseif self.currentTabIndex == 2 then
        if self.panelList[self.currentTabIndex] == nil then
            self.panelList[self.currentTabIndex] = NoOneAllRankPanel.New(self.model,self.mainCon)
        end
        self.curPanel = self.panelList[self.currentTabIndex]
        self.curPanel:Show(3)
    end
end




