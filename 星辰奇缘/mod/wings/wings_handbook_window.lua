WingsHandbookWindow = WingsHandbookWindow or BaseClass(BaseWindow)

function WingsHandbookWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.wing_book
    self.cacheMode = CacheMode.Visible
    self.mgr = WingsManager.Instance
    self.resList = {
        {file = AssetConfig.wings_handbook_window, type = AssetType.Main}
        ,{file = AssetConfig.attr_icon, type = AssetType.Dep}
        ,{file = AssetConfig.wing_textures, type = AssetType.Dep}
        ,{file = AssetConfig.wingsbookbg, type = AssetType.Dep}
        ,{file = AssetConfig.book_bg, type = AssetType.Main}
    }
    self.attrList = {}
    self.rowList = {}
    self.itemList = {}
    self.tabList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.updateListener = function() self:ReloadTab() end
    self.getrewardListener = function() self:CheckRed() end
end

function WingsHandbookWindow:__delete()
    self.OnHideEvent:Fire()

    self.lastItem = nil

    if self.gridLayout ~= nil then
        self.gridLayout:DeleteMe()
        self.gridLayout = nil
    end

    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end

    if self.infoPanel ~= nil then
        self.infoPanel:DeleteMe()
        self.infoPanel = nil
    end

    if self.itemList ~= nil then
        for _,item in pairs(self.itemList) do
            item:DeleteMe()
        end
        self.itemList = nil
    end

    self:AssetClearAll()
end

function WingsHandbookWindow:InitPanel()
    local model = self.model
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.wings_handbook_window))
    self.gameObject.name = "WingsHandbookWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    local main = self.gameObject.transform:Find("Main")
    self.main = main
    UIUtils.AddBigbg(main:Find("Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.book_bg)))

    local tabContainer1 = main:Find("TabContainer1")
    self.tabCloner1 = tabContainer1:Find("Cloner").gameObject

    self.cloner = main:Find("WingScroll/Cloner").gameObject
    self.nothing = main:Find("WingScroll/Nothing").gameObject
    self.gridLayout = LuaGridLayout.New(main:Find("WingScroll/Container"), {column = 2, bordertop = 0, borderleft = 0, cellSizeX = 150, cellSizeY = 188, cspacing = 11, rspacing = 8})
    main:Find("WingScroll").sizeDelta = Vector2(400, 416)
    main:Find("WingScroll").anchoredPosition = Vector2(200, -3)
    self.infoObj = main:Find("Info").gameObject
    self.titleRect = main:Find("Title")
    self.titleText = main:Find("Title/Text"):GetComponent(Text)

    local func = function(gameObject)
        local tab = {}
        tab.gameObject = gameObject
        tab.transform = tab.gameObject.transform
        tab.tick = tab.transform:Find("Tick").gameObject
        tab.gameObject.transform:SetParent(tabContainer1)
        tab.transform:SetAsLastSibling()
        tab.gameObject.transform.localScale = Vector3.one
        tab.normalTxt = tab.transform:Find("Normal/Text"):GetComponent(Text)
        tab.selectTxt = tab.transform:Find("Select/Text"):GetComponent(Text)
        tab.redPoint = tab.transform:Find("Normal/RedPoint").gameObject
        tab.tick:SetActive(false)
        return tab
    end

    self.tabList[0] = func(self.tabCloner1)
    self.tabList[0].group_id = 0
    for i,group in ipairs(DataWing.data_group_info) do
        table.insert(self.tabList, func(GameObject.Instantiate(self.tabCloner1)))
        self.tabList[i].group_id = group.group_id
    end

    -- 幻化
    self.tabList[#self.tabList+1] = func(GameObject.Instantiate(self.tabCloner1))
    self.tabList[#self.tabList].group_id = 100

    self.tabGroup = TabGroup.New(tabContainer1.gameObject, function(index) self:ChangeTab(index) end, {notAutoSelect = true, noCheckRepeat = false, perWidth = 100, perHeight = 57, isVertical = true, spacing = 10})
    for _,tab in pairs(self.tabList) do
        tab.normalTxt.text = DataWing.data_group_info_show[tab.group_id].short_title
        tab.selectTxt.text = DataWing.data_group_info_show[tab.group_id].long_title
    end
    self.cloner:SetActive(false)

    self.tabLayout = LuaBoxLayout.New(tabContainer1, {axis = BoxLayoutAxis.Y, cspacing = 0, border = 5})
end

function WingsHandbookWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function WingsHandbookWindow:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    self.preview:SetActive(true)
end

function WingsHandbookWindow:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.role_wings_change, self.updateListener)
    WingsManager.Instance.onGetReward:AddListener(self.getrewardListener)

    self:ResortTab()
    self:ReloadTab()
    self.tabGroup:ChangeTab(WingsManager.Instance.currentTab or 1)
    WingsManager.Instance.currentTab = nil
end

function WingsHandbookWindow:ResortTab()
    self.tabLayout:ReSet()

    self.tabLayout:AddCell(self.tabGroup.buttonTab[1].gameObject)

    local bool = false
    for _,v in ipairs(WingsManager.Instance.illusionTab) do
        bool = bool or (v ~= nil and BaseUtils.BASE_TIME <= v.timeout)
    end

    if bool then
        self.tabLayout:AddCell(self.tabGroup.buttonTab[#self.tabGroup.buttonTab].gameObject)
    end

    local maxGroup = 0
    for wing_id,v in pairs(WingsManager.Instance.hasGetIds) do
        if DataWing.data_base[wing_id].group_id ~= 100 and DataWing.data_base[wing_id].group_id > maxGroup then
            maxGroup = DataWing.data_base[wing_id].group_id
        end
    end
    -- for _,v in pairs(self.tabList) do
    for i=#self.tabList,1,-1 do
        local v = self.tabList[i]
        if v.group_id <= maxGroup then
            self.tabLayout:AddCell(v.gameObject)
        else
            v.gameObject:SetActive(false)
        end
    end

    if not bool then
        self.tabLayout:AddCell(self.tabGroup.buttonTab[#self.tabGroup.buttonTab].gameObject)
    end
end

function WingsHandbookWindow:ChangeTab(index)

    local group_id = self.tabList[index - 1].group_id

    if self:ReloadList(group_id) then
        if self.lastIndex ~= nil then
            self.itemList[self.lastIndex]:Select(false)
        end
        self.lastIndex = 1

        if self.notFirst then
            self:ShowEffect()
            self.delayId = LuaTimer.Add(1000, function()
                if self.delayId ~= nil and self.itemList[1] ~= nil then
                    self.itemList[WingsManager.Instance.wingIndex or 1]:OnClick()
                    WingsManager.Instance.wingIndex = nil
                end
            end)
        else
            if self.itemList[1] ~= nil then
                self.itemList[WingsManager.Instance.wingIndex or 1]:OnClick()
                WingsManager.Instance.wingIndex = nil
            end
            self.notFirst = true
        end
    else
        if self.notFirst then
            self:ShowEffect()
            self.delayId = LuaTimer.Add(1000, function() if self.delayId ~= nil then self:ClickWing() end end)
        else
            self.notFirst = true
            self:ClickWing()
        end
    end

    self.titleText.text = DataWing.data_group_info_show[group_id].title
    self.titleRect.sizeDelta = Vector2(self.titleText.preferredWidth + 70, 36)
end

function WingsHandbookWindow:ReloadList(group_id)
    local idList = {}
    if group_id == 0 then
        for _,base in pairs(DataWing.data_base) do
            if WingsManager.Instance.hasGetIds[base.wing_id] or WingsManager.Instance.illusionTab[base.wing_id] then
                table.insert(idList, base.wing_id)
            end
        end
        table.sort(idList, function(a,b)
            if DataWing.data_base[a].group_id == 100 then
                if DataWing.data_base[b].group_id == 100 then
                    return a > b
                else
                    return true
                end
            else
                if DataWing.data_base[b].group_id == 100 then
                    return false
                else
                    return a > b
                end
            end
        end)
    elseif group_id == 100 then
        for _,base in pairs(DataWing.data_base) do
            if base.grade >= 2000 then
                table.insert(idList, base.wing_id)
            end
        end
        table.sort(idList, function(a,b) return a<b end)
    else
        for _,v in ipairs(DataWing.data_group_info[group_id].wing_ids) do
            table.insert(idList, v[1])
        end
    end

    self.gridLayout:ReSet()
    for i,id in ipairs(idList) do
        local tab = self.itemList[i]
        if tab == nil then
            local j = i
            tab = WingHandbookItem.New(self.model, GameObject.Instantiate(self.cloner))
            tab.clickCallback = function(ids) self:ClickItem(ids, j)end
            self.itemList[i] = tab
        end
        self.gridLayout:AddCell(tab.gameObject)
        tab:update_my_self(id, i)
        tab:SetActive(true)
    end
    for i=#idList+1,#self.itemList do
        self.itemList[i]:SetActive(false)
    end

    self.nothing:SetActive(#idList == 0)

    return idList[1]
end

function WingsHandbookWindow:ClickItem(id, index)
    if self.delayId ~= nil then
        LuaTimer.Delete(self.delayId)
        self.delayId = nil
    end

    if self.lastIndex ~= nil then
        self.itemList[self.lastIndex]:Select(false)
    end
    self.lastIndex = index

    self:ClickWing(id)
end

function WingsHandbookWindow:ReloadTab()
    for _,v in pairs(self.tabList) do
        if v.group_id == 0 then
            v.tick:SetActive(false)
        else
            v.tick:SetActive(WingsManager.Instance.wing_groups[v.group_id] ~= nil and #WingsManager.Instance.wing_groups[v.group_id].wing_ids == #DataWing.data_group_info[v.group_id].wing_ids)
        end
    end
    self:CheckRed()
end

function WingsHandbookWindow:ShowSkillPreviewWindow()
    WingsManager.Instance:OpenSkillPreview()
end

function WingsHandbookWindow:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.role_wings_change, self.updateListener)
    WingsManager.Instance.onGetReward:RemoveListener(self.getrewardListener)
end

function WingsHandbookWindow:OnHide()
    self:RemoveListeners()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.delayId ~= nil then
        LuaTimer.Delete(self.delayId)
        self.delayId = nil
    end
    if self.infoPanel ~= nil then
        self.infoPanel:Hiden()
    end
    if self.tabGroup.currentIndex > 0 then
        self.tabGroup:UnSelect(self.tabGroup.currentIndex)
        self.tabGroup.currentIndex = 0
    end
    self.notFirst = false
end

-- 点击翅膀
function WingsHandbookWindow:ClickWing(id)
    if self.infoPanel == nil then
        self.infoPanel = WingsHandbookInfo.New(self.model, self.infoObj)
    end
    self.infoPanel:Show({id,self.lastIndex})
end

function WingsHandbookWindow:Countdown(timeout)
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if timeout ~= nil then
        self.timeArea.gameObject:SetActive(true)
        self.noticeArea.gameObject:SetActive(false)
        if timeout == 0 then
            -- 永久幻化翅膀
            self.timeText.text = string.format(TI18N("幻化剩余时间:%s"), TI18N("永久"))
        else
            --
            self.timerId = LuaTimer.Add(0, 50, function()
                if BaseUtils.BASE_TIME < timeout then
                    if timeout - BaseUtils.BASE_TIME < 60 then
                        self.timeText.text = string.format(TI18N("幻化剩余时间:%s"), string.format("%s秒", timeout - BaseUtils.BASE_TIME))
                    elseif timeout - BaseUtils.BASE_TIME < 3600 then
                        self.timeText.text = string.format(TI18N("幻化剩余时间:%s"), string.format("%s分钟", math.floor((timeout - BaseUtils.BASE_TIME) / 60)))
                    elseif timeout - BaseUtils.BASE_TIME < 86400 then
                        self.timeText.text = string.format(TI18N("幻化剩余时间:%s"), string.format("%s小时", math.floor((timeout - BaseUtils.BASE_TIME) / 3600)))
                    else
                        self.timeText.text = string.format(TI18N("幻化剩余时间:%s"), string.format("%s天", math.floor((timeout - BaseUtils.BASE_TIME) / 86400)))
                    end
                else
                    self.timeText.text = TI18N("已过期")
                end
            end)
        end
    else
        self.timeArea.gameObject:SetActive(false)
        self.noticeArea.gameObject:SetActive(true)
    end
end

function WingsHandbookWindow:GetIndexGroup(group)
    for i,id in pairs(group.ids) do
        if WingsManager.Instance.hasGetIds[id] == 1 then
            return i
        end
    end
    for i,id in pairs(group.ids) do
        if WingsManager.Instance.illusionTab[id] ~= nil then
            return i
        end
    end
    return 1
end

function WingsHandbookWindow:ShowEffect()
    if self.effect ~= nil then
        self.effect:DeleteMe()
    end
    self.effect = BaseUtils.ShowEffect(20429, self.main, Vector3(0.96, 0.993, 0.98), Vector3(5,2.5,-400))
end

function WingsHandbookWindow:CheckRed()
    for i=1,#self.tabList-1 do
        if WingsManager.Instance.wing_groups[i] ~= nil and WingsManager.Instance.wing_groups[i].fullCollected == true and WingsManager.Instance.wing_groups[i].rewarded == 0 then
            self.tabList[i].redPoint:SetActive(true)
        else
            self.tabList[i].redPoint:SetActive(false)
        end
    end
end