-- 仓库主窗口
-- @author zgs
StoreWindow = StoreWindow or BaseClass(BaseWindow)

function StoreWindow:__init(model)
    self.model = model
    self.name = "StoreWindow"

    -- self.cacheMode = CacheMode.Visible
    self.winLinkType = WinLinkType.Link

    self.currentTabIndex = 1
    self.panelList = {}

    self.resList = {
        {file = AssetConfig.store_window, type = AssetType.Main}
        --,{file  =  AssetConfig.FashionBg, type  =  AssetType.Dep}
        --, {file = AssetConfig.pet_textures, type = AssetType.Dep}
    }
    self.OnOpenEvent:AddListener(function()
        local index = self.currentTabIndex
        if self.openArgs ~= nil then
            index = tonumber(self.openArgs[1])
        end
        self.tabGroup:ChangeTab(index)
        -- self:TabChange(index)
    end)
end

function StoreWindow:OnInitCompleted()
    local index = self.currentTabIndex
    if self.openArgs ~= nil then
        index = tonumber(self.openArgs[1])
    end
    self.tabGroup:ChangeTab(index)
    -- self:TabChange(index)
end

function StoreWindow:__delete()
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    for k,v in pairs(self.panelList) do
        v:DeleteMe()
    end
    self.panelList = {}
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.OnOpenEvent:RemoveAll()
    self.gameObject = nil
    self.model = nil
end

function StoreWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.store_window))
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.closeBtn = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function()
                self:OnClickClose()
            end)
    self.tabGroupObj = self.gameObject.transform:Find("Main/TabButtonGroup").gameObject
    local setting = {
        notAutoSelect = true,
        noCheckRepeat = true,
        openLevel = {0,0,0,999},
        perWidth = 62,
        perHeight = 100,
        isVertical = true
    }
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:TabChange(index) end, setting)
    -- self.tabGroupObj:SetActive(false)
    -- self:TabChange(1)
    self.tabGroup.buttonTab[1].normalTxt.text = TI18N("道\n具")
    self.tabGroup.buttonTab[1].selectTxt.text = TI18N("道\n具")
end

function StoreWindow:init()
    if self.currentTabIndex == 1 then --道具仓库
        self.panelList[self.currentTabIndex] = ToolsStorePanel.New(self.model,self.transform)
    elseif self.currentTabIndex == 2 then --宠物仓库
        self.panelList[self.currentTabIndex] = PetStorePanel.New(self.model,self.transform)
    elseif self.currentTabIndex == 3 then --道具仓库
        self.panelList[self.currentTabIndex] = ToolsHomeStorePanel.New(self.model,self.transform)
    end
end

function StoreWindow:TabChange(index)
    if self.currentTabIndex ~= index then
        if self.panelList[self.currentTabIndex] ~= nil then
            self.panelList[self.currentTabIndex]:Hiden()
        end
    end
    self.currentTabIndex = index
    if self.panelList[self.currentTabIndex] == nil then
        self:init()
    end
    self.panelList[self.currentTabIndex]:Show()
end

function StoreWindow:OnClickClose()
    self.model:CloseMain()
end


