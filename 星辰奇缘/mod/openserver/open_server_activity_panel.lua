-- 已弃用

OpenServerActivityPanel = OpenServerActivityPanel or BaseClass(BasePanel)

function OpenServerActivityPanel:__init(model, parent)
    self.model = model
    self.parent = parent

    self.resList = {
        {file = AssetConfig.open_server_activity, type = AssetType.Main}
        , {file = AssetConfig.open_server_textures, type = AssetType.Dep}
    }
    local resList = {}
    for k,v in pairs(model.activities) do
        if v.package ~= nil then
            resList[v.package] = 1
        end
    end
    for k,v in pairs(resList) do
        if v ~= nil then
            table.insert(self.resList, {file = k, type = AssetType.Dep})
        end
    end

    self.panelList = {}
    self.openLevel = {}
    self.tabGroupObjList = {}
    self.tabGroupNormalText = {}
    self.tabGroupSelectText = {}
    self.tabGroupImage = {}
    self.lastSelectIndex = 1

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)

    self.tabArray = {}
    for k,v in pairs(model.activities) do
        table.insert(self.tabArray, v)
        self.tabArray[#self.tabArray].id = k
    end
    table.sort(self.tabArray, function(a,b) return a.index < b.index end)
end

function OpenServerActivityPanel:__delete()
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.panelList ~= nil then
        for k,v in pairs(self.panelList) do
            if v ~= nil then
                v:DeleteMe()
                self.panelList[k] = nil
                v = nil
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

function OpenServerActivityPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_activity))
    self.gameObject.name = "OpenServerActivityPanel"
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)

    self.transform = self.gameObject.transform
    local t = self.transform

    self.downObj = t:Find("Down").gameObject
    self.tabCloner = t:Find("ActivityListPanel/Cloner").gameObject
    self.tabContainer = t:Find("ActivityListPanel/Container")
    self.maxTabGroupHeight = self.transform:Find("ActivityListPanel"):GetComponent(RectTransform).sizeDelta.y
    self.mainPanel = t:Find("MainPanel")

    self.tabCloner:SetActive(false)
    self.downObj:SetActive(false)

    self.tabGroupSetting = {
        notAutoSelect = true,
        openLevel = {0, 0},
        perWidth = 175,
        perHeight = 60,
        isVertical = true,
        spacing = 0
    }
    self.tabGroup = TabGroup.New(self.tabContainer.gameObject, function(index) self:ChangeTab(index) end, self.tabGroupSetting)

    self.OnOpenEvent:Fire()
end

function OpenServerActivityPanel:ChangeTab(index)
    local panel = nil
    if self.lastIndex ~= nil then
        panel = self.panelList[self.lastIndex]
    end
    if panel ~= nil then
        panel:Hiden()
    end
    local currentIndex = self.tabArray[index].index
    panel = self.panelList[currentIndex]
    if panel == nil then
        if currentIndex == 2 then
            self.panelList[currentIndex] = OpenServerRankPanel.New(self.model, self.mainPanel, self.tabArray[index].subList)
        elseif currentIndex == 1 then
            self.panelList[currentIndex] = OpenServerLuckyPanel.New(self.model, self.mainPanel, self.tabArray[index].subList)
        elseif currentIndex == 4 then
            self.panelList[currentIndex] = OpenServerTherionPanel.New(self.model, self.mainPanel, self.tabArray[index].subList)
        elseif currentIndex == 5 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3,2})
            return
        -- elseif currentIndex == 6 then
        --     self.panelList[currentIndex] = OpenServerFirstCharge.New(self.model, self.mainPanel, self.model.activities[6].data)
        -- elseif currentIndex == 3 then
        --     self.panelList[currentIndex] = OpenServerOfficalRebate.New(self.model, self.mainPanel, self.model.activities[3].data)
        -- elseif currentIndex == 3 then
        --     self.panelList[currentIndex] = OpenServerBabyPanel.New(self.model, self.mainPanel)
        end
        panel = self.panelList[currentIndex]
    end
    if panel ~= nil then
        panel:Show()
    end
    self.lastIndex = currentIndex
    self.lastSelectIndex = self.lastIndex
end

function OpenServerActivityPanel:OnOpen()
    self:CheckForOpen()
    self:ReloadTabGroup()

    local unreachableLev = 255
    local tab = self.tabArray[self.lastSelectIndex]
    if tab == nil or tab.lev == unreachableLev or self.lastSelectIndex == 4 then
        for i,v in ipairs(self.tabArray) do
            if (v.lev == nil or v.lev == 0) and v.index ~= 4 then
                self.lastSelectIndex = i
                break
            end
        end
    end

    self.tabGroup:ChangeTab(self.lastSelectIndex)
end

function OpenServerActivityPanel:OnHide()
    -- self.lastSelectIndex = 1
end

function OpenServerActivityPanel:ReloadTabGroup()
    local model = self.model
    local openLevel = {}
    -- BaseUtils.dump(self.tabArray, "<color=#00FF00>self.tabArray</color>")
    for i,v in ipairs(self.tabArray) do
        if self.tabGroupObjList[i] == nil then
            self.tabGroupObjList[i] = GameObject.Instantiate(self.tabCloner)
            self.tabGroupNormalText[i] = self.tabGroupObjList[i].transform:Find("Normal/Text"):GetComponent(Text)
            self.tabGroupSelectText[i] = self.tabGroupObjList[i].transform:Find("Select/Text"):GetComponent(Text)
            self.tabGroupImage[i] = self.tabGroupObjList[i].transform:Find("Icon"):GetComponent(Image)
            self.tabGroupObjList[i].transform:Find("NotifyPoint").gameObject:SetActive(false)
            self.tabGroupObjList[i].name = tostring(i)
        end
        self.tabGroupNormalText[i].text = v.name
        self.tabGroupSelectText[i].text = v.name
        if v.package == nil then
            self.tabGroupImage[i].sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, tostring(v.icon))
        else
            self.tabGroupImage[i].sprite = self.assetWrapper:GetSprite(v.package, tostring(v.icon))
        end
        local obj = self.tabGroupObjList[i]
        obj:GetComponent(Button).onClick:RemoveAllListeners()
        obj.transform:SetParent(self.tabContainer)
        obj.transform.localScale = Vector3.one
        local rect = obj:GetComponent(RectTransform)
        rect.pivot = Vector2(0,0.5)
        if v.lev ~= nil then
            openLevel[i] = v.lev
        else
            openLevel[i] = 0
        end
    end
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
    end
    self.tabGroupSetting.openLevel = openLevel
    self.tabGroup = TabGroup.New(self.tabContainer.gameObject, function(index) self:ChangeTab(index) end, self.tabGroupSetting)
    self.downObj:SetActive(self.tabGroup.rect.sizeDelta.y > self.maxTabGroupHeight)
end

function OpenServerActivityPanel:CheckForOpen()
    local unreachableLev = 255
    self.openLevel = {}
    local openTime = CampaignManager.Instance.open_srv_time
    local base_time = BaseUtils.BASE_TIME
    local hour = tonumber(os.date("%H",openTime))*3600
    hour = hour + tonumber(os.date("%M",openTime))*60
    hour = hour + tonumber(os.date("%S",openTime))

    for k,v in pairs(self.model.activities) do
        if v.subList == nil then
            v.lev = 0
        else
            local end_time = 0
            local begin_time = 999999999999
            for k,v1 in pairs(v.subList) do
                if v1.cli_end_time == 0 then
                else
                    local cli_start_time = v1.cli_start_time[1]
                    local cli_end_time = v1.cli_end_time[1]
                    local beginTime = openTime - hour + cli_start_time[2] * 86400 + cli_start_time[3]
                    local endTime = openTime - hour + cli_end_time[2] * 86400 + cli_end_time[3]
                    if end_time < endTime then
                        end_time = endTime
                    end
                    if begin_time > beginTime then
                        begin_time = beginTime
                    end
                end
            end

            if base_time >= begin_time and base_time < end_time then
                v.lev = 0
            else
                v.lev = unreachableLev
            end
        end
    end

    -- 检查渠道号和
    local platformChanleId = ctx.PlatformChanleId
    local distId = ctx.KKKChanleId

    -- if platformChanleId == 11                   -- 小米
    --     or platformChanleId == 12               -- oppo
    --     or platformChanleId == 13               -- UC
    --     or platformChanleId == 22               -- 步步高
    --     or platformChanleId == 8                -- 华为
    --     or (platformChanleId == 33 and distId == 4)     -- 腾讯联运
    --     then
    --     -- 显示
    --     self.model.activities[6].lev = 0
    --     if self.model.activities[3] ~= nil then
    --         self.model.activities[3].lev = 0
    --     end
    -- else
    --     -- 不显示
    --     self.model.activities[6].lev = 0
    --     if self.model.activities[3] ~= nil then
    --         self.model.activities[3].lev = 0
    --     end
    -- end
end
