--2016/9/21
--zzl
--国庆活动主界面
NationalDayMainWindow  =  NationalDayMainWindow or BaseClass(BaseWindow)

function NationalDayMainWindow:__init(model)
    self.name = "NationalDayMainWindow"
    self.model = model
    -- 缓存
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList  =  {
        {file  =  AssetConfig.national_day_main_window, type  =  AssetType.Main}
        ,{file  =  AssetConfig.national_day_res, type  =  AssetType.Dep}
        ,{file  =  AssetConfig.dropicon, type  =  AssetType.Dep}
    }

    self.holdTime = 3
    self.windowId = WindowConfig.WinID.national_day_window

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

function NationalDayMainWindow:OnHide()
    for k, v in pairs(self.tabPanelList) do
        if v ~= nil then
            v:Hiden()
        end
    end
end

function NationalDayMainWindow:OnShow()
    NationalDayManager.Instance:Send14080()

    if self.openArgs ~= nil then
        self.selectIndex = self.openArgs[1]
    end
    self:UpdateTabList()
end

function NationalDayMainWindow:__delete()
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

function NationalDayMainWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function NationalDayMainWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.national_day_main_window))
    self.gameObject:SetActive(false)
    self.gameObject.name = "NationalDayMainWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.transform:GetComponent(RectTransform).localPosition = Vector3.zero
    self.MainCon = self.transform:Find("MainCon")
    local closeBtn = self.MainCon:Find("CloseButton"):GetComponent(Button)
    closeBtn.onClick:AddListener(function()
        self.model:CloseMainUI()
    end)

    self.RightCon = self.MainCon:Find("RightCon")
    self.LeftCon = self.MainCon:Find("LeftCon")
    self.MaskCon = self.LeftCon:Find("MaskCon")
    self.ScrollCon = self.MaskCon:Find("ScrollCon")
    self.Container = self.ScrollCon:Find("Container")
    self.Origin_TabBtn = self.Container:Find("TabBtn")
    self.Origin_TabBtn.gameObject:SetActive(false)
    self.isInit = true
end


--更新显示tab,根据对应的一些过滤来显示tab
function NationalDayMainWindow:UpdateTabList()
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

    -- BaseUtils.dump(CampaignManager.Instance.campaignTab)

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
function NationalDayMainWindow:CreateTabBtn(index)
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
function NationalDayMainWindow:SetTabBtn(tab_btn, _data)
    tab_btn.data = _data
    local btn_str = DataCampaign.data_list[_data.campId].name
    tab_btn.ImgSelected_txt.text = btn_str
    tab_btn.ImgUnSelected_txt.text = btn_str
    if _data.id >= 1 and _data.id <= 5 then
        tab_btn.ImgIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.dropicon, _data.iconName)
    else
        tab_btn.ImgIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.national_day_res, _data.iconName)
    end
    tab_btn.ImgIcon.transform:GetComponent(RectTransform).sizeDelta = Vector2(_data.iconW, _data.iconH)
end

--切换按钮选中状态
function NationalDayMainWindow:SwitchTabBtn(tab_btn, state)
    tab_btn.ImgSelected.gameObject:SetActive(state)
    tab_btn.ImgUnSelected.gameObject:SetActive(not state)
end

--按钮点击逻辑
function NationalDayMainWindow:OnClickTabBtn(tab_btn, index)
    if index == 6 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.national_day_other_window, {1})
        return
    elseif index == 7 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.national_day_other_window, {2})
        return
    end
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

function NationalDayMainWindow:UpdateRedPoint()
    local tabDataList = BaseUtils.copytab(self.model.tabDataList)
    --排序
    table.sort(tabDataList, function(a,b)
        return a.sortIndex < b.sortIndex
    end)

    for i=1,#tabDataList do
        local tab_data = tabDataList[i]
        local tab_btn = self.tabBtnList[i]
        if tab_btn ~= nil and NationalDayManager.Instance.redPointDataDic[tab_data.id] ~= nil then
            tab_btn.redPointObj:SetActive(NationalDayManager.Instance.redPointDataDic[tab_data.id])
        end
    end
end

-----------------------------------------------右边逻辑
function NationalDayMainWindow:UpdateRight(tab_btn)
    self.cur_tab_btn= tab_btn
    local selectedPanel = nil

    if tab_btn.data.id == 1 then
        --保卫蛋糕
        if self.tabPanelList[tab_btn.data.id] == nil then
            self.tabPanelList[tab_btn.data.id] = NationalDefensePanel.New(self.model,self)
        end
        selectedPanel = self.tabPanelList[tab_btn.data.id]
    elseif tab_btn.data.id == 2 then
        --五彩遍河山
        if self.tabPanelList[tab_btn.data.id] == nil then
            self.tabPanelList[tab_btn.data.id] = NationalDayFivePanel.New(self.model, self)
        end
        selectedPanel = self.tabPanelList[tab_btn.data.id]
    elseif tab_btn.data.id == 3 then
        --超级智多星
        if self.tabPanelList[tab_btn.data.id] == nil then
           self.tabPanelList[tab_btn.data.id] = NationalDayQuestionPanel.New(self.model,self)
        end
        selectedPanel = self.tabPanelList[tab_btn.data.id]
    elseif tab_btn.data.id == 4 then
        --庆典贺华诞
        if self.tabPanelList[tab_btn.data.id] == nil then
            self.tabPanelList[tab_btn.data.id] = NationDayBolloonPanel.New(self)
        end
        selectedPanel = self.tabPanelList[tab_btn.data.id]
    elseif tab_btn.data.id == 5 then
        --彩虹七天乐
        if self.tabPanelList[tab_btn.data.id] == nil then
           self.tabPanelList[tab_btn.data.id] = NationalDayRollPanel.New(self)
        end
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
        selectedPanel:Show()
    end
    self.lastPanel = selectedPanel
end
