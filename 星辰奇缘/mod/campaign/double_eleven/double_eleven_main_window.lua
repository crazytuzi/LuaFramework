--2016/11/4
--xjlong
--双十一活动主界面
DoubleElevenMainWindow  =  DoubleElevenMainWindow or BaseClass(BaseWindow)

function DoubleElevenMainWindow:__init(model)
    self.name = "DoubleElevenMainWindow"
    self.model = model
    -- 缓存
    self.cacheMode = CacheMode.Visible
    self.windowId = WindowConfig.WinID.double_eleven_window

    local dic = {
        [AssetConfig.dropicon] = 1,
        [AssetConfig.doubleeleven_res] = 1,
        [AssetConfig.midAutumn_textures] = 1,
        [AssetConfig.christmas_textures] = 1,
    }
    for _,v in pairs(model.tabDataList) do
        if v ~= nil and v.res ~= nil then
            dic[v.res] = 1
        end
    end

    self.resList = {
        {file = AssetConfig.double_eleven_main_window, type = AssetType.Main}
    }
    for res,_ in pairs(dic) do
        table.insert(self.resList, {file = res, type = AssetType.Dep})
    end

    self.windowId = WindowConfig.WinID.double_eleven_window

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.tabBtnList = {}
    self.tabPanelList = {}
    self.updatePoint = function()
        self:UpdateRedPoint()
    end
    self.lastPanel = nil
    self.isInit = false
    self.selectIndex = 1
    return self
end

function DoubleElevenMainWindow:OnHide()
    for k, v in pairs(self.tabPanelList) do
        if v ~= nil then
            v:Hiden()
        end
    end
end

function DoubleElevenMainWindow:OnShow()
    DoubleElevenManager.Instance:Send14045()

    if self.openArgs ~= nil then
        self.selectIndex = self.openArgs[1]
    end
    self:UpdateTabList()
end

function DoubleElevenMainWindow:__delete()
    self.lastPanel = nil
    self.OnOpenEvent:RemoveAll()
    if self.tabPanelList ~= nil then
        for k,v in pairs(self.tabPanelList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.tabPanelList = nil
    end

    self.tabBtnList = nil
    self.tabPanelList = nil
    self.isInit = false
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function DoubleElevenMainWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function DoubleElevenMainWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.double_eleven_main_window))
    self.gameObject:SetActive(false)
    self.gameObject.name = "DoubleElevenMainWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.transform:GetComponent(RectTransform).localPosition = Vector3.zero
    self.MainCon = self.transform:Find("MainCon")
    local closeBtn = self.MainCon:Find("CloseButton"):GetComponent(Button)
    closeBtn.onClick:AddListener(function()
        self.model:CloseWindow()
    end)

    self.RightCon = self.MainCon:Find("RightCon")
    self.LeftCon = self.MainCon:Find("LeftCon")
    self.MaskCon = self.LeftCon:Find("MaskCon")
    self.ScrollCon = self.MaskCon:Find("ScrollCon")
    self.Container = self.ScrollCon:Find("Container")
    self.Origin_TabBtn = self.Container:Find("TabBtn")
    self.Origin_TabBtn.gameObject:SetActive(false)
    self.isInit = true

    self.transform:Find("MainCon/Image/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.christmas_textures, "TitleI18N")
end

--更新显示tab,根据对应的一些过滤来显示tab
function DoubleElevenMainWindow:UpdateTabList()
    if self.isInit == false then
        return
    end
    local tabDataList = BaseUtils.copytab(self.model.tabDataList)
    --排序
    table.sort(tabDataList, function(a,b)
        return a.sortIndex < b.sortIndex
    end)
    for k, v in pairs(self.tabBtnList) do
        v.gameObject:SetActive(false)
    end

    local index = 1
    for i=1,#tabDataList do
        local tab_data = tabDataList[i]
        if (tab_data.endTime > BaseUtils.BASE_TIME or tab_data.endTime == 0) and CampaignManager.Instance.campaignTab[tab_data.campId] ~= nil then
            local tab_btn = self.tabBtnList[index]
            if tab_btn == nil then
                tab_btn = self:CreateTabBtn(index)
                table.insert(self.tabBtnList, tab_btn)
            end
            tab_btn.ImgSelected.gameObject:SetActive(false)
            tab_btn.ImgUnSelected.gameObject:SetActive(false)
            self:SetTabBtn(tab_btn, tab_data)
            tab_btn.gameObject:SetActive(true)
            index = index + 1
        end
    end

    if self.tabBtnList[self.selectIndex] == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("活动已结束"))
        self.selectIndex = 1
    end
    self:OnClickTabBtn(self.tabBtnList[self.selectIndex], self.selectIndex)
end


----------------------------------tabBtn创建逻辑
--创建一个tab_btn的表
function DoubleElevenMainWindow:CreateTabBtn(index)
    local tab_btn = {}
    tab_btn.gameObject = GameObject.Instantiate(self.Origin_TabBtn.gameObject)
    tab_btn.gameObject:SetActive(true)
    tab_btn.transform = tab_btn.gameObject.transform
    tab_btn.transform:SetParent(self.Origin_TabBtn.parent)
    tab_btn.ImgSelected = tab_btn.transform:Find("ImgSelected")
    tab_btn.ImgSelected_txt = tab_btn.ImgSelected:Find("TxtSelectedBtn"):GetComponent(Text)
    tab_btn.ImgUnSelected = tab_btn.transform:Find("ImgUnSelected")
    tab_btn.ImgUnSelected_txt = tab_btn.ImgUnSelected:Find("TxtUnSelectedBtn"):GetComponent(Text)
    tab_btn.ImgIcon = tab_btn.transform:Find("ImgIcon"):GetComponent(Image)
    tab_btn.redPointObj = tab_btn.transform:Find("RedPointImage").gameObject
    tab_btn.transform.localPosition = Vector3.one
    tab_btn.transform.localScale = Vector3.one
    tab_btn.transform:GetComponent(Button).onClick:AddListener(function()
        self:OnClickTabBtn(tab_btn, index)
    end)
    local newY = (index - 1)*-60
    local rect = tab_btn.transform:GetComponent(RectTransform)
    rect.anchoredPosition = Vector2(0, newY)
    return tab_btn
end

--对tab_btn进行数据填充
function DoubleElevenMainWindow:SetTabBtn(tab_btn, _data)
    tab_btn.data = _data
    local btn_str = DataCampaign.data_list[_data.campId].name
    tab_btn.ImgSelected_txt.text = btn_str
    tab_btn.ImgUnSelected_txt.text = btn_str
    tab_btn.ImgIcon.sprite = self.assetWrapper:GetSprite(_data.res or AssetConfig.dropicon, _data.iconName)
    tab_btn.ImgIcon.transform:GetComponent(RectTransform).sizeDelta = Vector2(_data.iconW, _data.iconH)
end

--切换按钮选中状态
function DoubleElevenMainWindow:SwitchTabBtn(tab_btn, state)
    tab_btn.ImgSelected.gameObject:SetActive(state)
    tab_btn.ImgUnSelected.gameObject:SetActive(not state)
end

--按钮点击逻辑
function DoubleElevenMainWindow:OnClickTabBtn(tab_btn, index)
    if tab_btn == nil then
        return
    end

    self.selectIndex = index
    for i=1,#self.tabBtnList do
        local temp = self.tabBtnList[i]
        self:SwitchTabBtn(temp, false)
    end
    self:SwitchTabBtn(tab_btn, true)
    --更新右边
    self:UpdateRight(tab_btn)
end

function DoubleElevenMainWindow:UpdateRedPoint()
    local tabDataList = BaseUtils.copytab(self.model.tabDataList)
    --排序
    table.sort(tabDataList, function(a,b)
        return a.sortIndex < b.sortIndex
    end)

    for i=1,#tabDataList do
        local tab_data = tabDataList[i]
        local tab_btn = self.tabBtnList[i]
        if tab_btn ~= nil and DoubleElevenManager.Instance.redPointDataDic[tab_data.id] ~= nil then
            tab_btn.redPointObj:SetActive(DoubleElevenManager.Instance.redPointDataDic[tab_data.id])
        end
    end
end

-----------------------------------------------右边逻辑
function DoubleElevenMainWindow:UpdateRight(tab_btn)
    self.cur_tab_btn= tab_btn
    local selectedPanel = nil
    local openArgs = nil

    if tab_btn.data.id == 1 then
        --双11聚划算
        if self.tabPanelList[tab_btn.data.id] == nil then
            self.tabPanelList[tab_btn.data.id] = DoubleElevenFeedbackPanel.New(self.model, self.RightCon)
        end
        selectedPanel = self.tabPanelList[tab_btn.data.id]
    elseif tab_btn.data.id == 2 then
        --全民团购日
        if self.tabPanelList[tab_btn.data.id] == nil then
            self.tabPanelList[tab_btn.data.id] = DoubleElevenGroupBuyPanel.New(self.model, self.RightCon, self)
        end
        selectedPanel = self.tabPanelList[tab_btn.data.id]
    elseif tab_btn.data.id == 3 then
        -- 萌萌雪人
        if self.tabPanelList[tab_btn.data.id] == nil then
            self.tabPanelList[tab_btn.data.id] = ChristmasDescPanel.New(self.model, self.RightCon)
        end
        openArgs = tab_btn.data.campId
        selectedPanel = self.tabPanelList[tab_btn.data.id]
    elseif tab_btn.data.id == 4 then
        -- 堆雪人
        if self.tabPanelList[tab_btn.data.id] == nil then
            self.tabPanelList[tab_btn.data.id] = ChristmasDescPanel.New(self.model, self.RightCon)
        end
        openArgs = tab_btn.data.campId
        selectedPanel = self.tabPanelList[tab_btn.data.id]
    end

    self:UpdateRedPoint()

    if selectedPanel == self.lastPanel then
        --选中的是同一个
        if self.lastPanel ~= nil then
            self.lastPanel:Show()
        end
        return
    end

    if self.lastPanel ~= nil then
        self.lastPanel:Hiden()
    end

    if selectedPanel ~= nil then
        selectedPanel:Show(openArgs)
    end
    self.lastPanel = selectedPanel
end
