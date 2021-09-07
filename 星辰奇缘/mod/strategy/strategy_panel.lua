-- @author 黄耀聪
-- @date 2016年7月6日

StrategyPanel = StrategyPanel or BaseClass(BasePanel)

function StrategyPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "StrategyPanel"
    self.mgr = StrategyManager.Instance

    self.resList = {
        {file = AssetConfig.strategy_panel, type = AssetType.Main},
        {file = AssetConfig.strategy_textures, type = AssetType.Dep},
    }

    self.tabData = {
        {name = TI18N("我的攻略"), icon = "My", index = 5, key = 0},
    }

    for i,v in pairs(model.tabData) do
        table.insert(self.tabData, v)
    end
    table.sort(self.tabData, function(a,b) return a.index < b.index end)

    self.setting = {
        isVertical = true,
        notAutoSelect = true,
        noCheckRepeat = true,
        perWidth = 174.67,
        perHeight = 60,
        spacing = 0,
    }

    self.panelList = {}
    self.changeTabFunc = function(index, extra) self:ChangeTab(index, extra) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.txtList = {}
end

function StrategyPanel:__delete()
    self.OnHideEvent:Fire()
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.panelList ~= nil then
        for k,v in pairs(self.panelList) do
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

function StrategyPanel:InitPanel()
    if self.parent == nil then
        self:AssetClearAll()
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.strategy_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.downObj = t:Find("Down").gameObject
    self.tabContainer = t:Find("ScrollLayer/Container")
    self.tabCloner = t:Find("ScrollLayer/Cloner").gameObject

    self.mainContainer = t:Find("MainPanel")

    for i,v in ipairs(self.tabData) do
        local obj = GameObject.Instantiate(self.tabCloner)
        obj.name = tostring(i)
        obj.transform:SetParent(self.tabContainer)
        obj.transform.localScale = Vector3.one
        obj.transform.localPosition = Vector3.zero
        obj.transform:Find("Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton8Str, v.name)
        obj.transform:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.strategy_textures, v.icon)
        table.insert(self.txtList, obj.transform:Find("Text"):GetComponent(Text))
    end

    self.tabCloner:SetActive(false)
    self.tabGroup = TabGroup.New(self.tabContainer.gameObject, self.changeTabFunc, self.setting)
end

function StrategyPanel:OnInitCompleted()
    self.tabGroup:Layout()
    self.OnOpenEvent:Fire()
end

function StrategyPanel:OnOpen()
    self:RemoveListeners()
    self.mgr.onChangeTab:AddListener(self.changeTabFunc)

    local args = self.openArgs
    args = args or {}

    if args[2] == nil then
        args[2] = 1
    end

    local index = args[2]
    for k,v in pairs(self.tabData) do
        if args[2] == v.key then
            index = k
            break
        end
    end
    -- if args ~= nil and #args == 2 and args[1] == 3 then
    --     self.lastSub = tonumber(args[2])
    -- end
    -- self.lastSub = self.model.mainModel.currentSub
    self.tabGroup:ChangeTab(index)
end

function StrategyPanel:OnHide()
    self:RemoveListeners()
    self.model.lastKey = nil
end

function StrategyPanel:RemoveListeners()
    self.mgr.onChangeTab:RemoveListener(self.changeTabFunc)
end

function StrategyPanel:ChangeTab(index, extra)
    local model = self.model
    model:ClearMyList()
    model:ClearList()
    if self.lastIndex ~= nil then
        if self.panelList[self.lastIndex] ~= nil then
            if self.tabData[self.lastIndex] ~= nil then
                model.lastKey = self.tabData[self.lastIndex].key
            else
                model.lastKey = nil
            end
            self.panelList[self.lastIndex]:Hiden()
        end
    end

    local panel = self.panelList[index]

    local tabData = self.tabData[index] or {}
    if panel == nil then
        if tabData.key == 0 then
            panel = StrategyMylistPanel.New(model,self.mainContainer)
        elseif tabData.key == 1 then
            panel = StrategyListPanel.New(model,self.mainContainer)
            panel.type = self.tabData[index].key
        elseif tabData.key == 2 then
            panel = StrategyListPanel.New(model,self.mainContainer)
            panel.type = self.tabData[index].key
        elseif tabData.key == 3 then
            panel = StrategyListPanel.New(model,self.mainContainer)
            panel.type = self.tabData[index].key
        elseif tabData.key == 4 then
            panel = StrategyListPanel.New(model,self.mainContainer)
            panel.type = self.tabData[index].key
        elseif index == 100 then    -- 编辑面板
            panel = StrategyEditPanel.New(model, self.mainContainer)
        elseif index == 99 then     -- 展示面板
            panel = StrategyContentPanel.New(model, self.mainContainer)
            self.openArgs = self.openArgs or {}
        end
        self.panelList[index] = panel
    end

    if self.lastIndex ~= nil and self.txtList[self.lastIndex] ~= nil then
        self.txtList[self.lastIndex].text = string.format(ColorHelper.DefaultButton8Str, self.tabData[self.lastIndex].name)
    end

    self.lastIndex = index
    if self.txtList[self.lastIndex] ~= nil then
        self.txtList[self.lastIndex].text = string.format(ColorHelper.DefaultButton9Str, self.tabData[self.lastIndex].name)
    end

    if panel ~= nil then
        panel.extra = extra
        panel:Show(self.openArgs)
    end
    self.openArgs = {}
end

