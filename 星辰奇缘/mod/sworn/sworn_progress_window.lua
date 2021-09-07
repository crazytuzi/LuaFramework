-- @author 黄耀聪
-- @date 2016年10月22日

-- 结拜进度窗口

SwornProgressWindow = SwornProgressWindow or BaseClass(BaseWindow)

function SwornProgressWindow:__init(model)
    self.model = model 
    self.name = "SwornProgressWindow"
    self.mgr = SwornManager.Instance
    self.windowId = WindowConfig.WinID.sworn_progress_window
    self.EffectPath = "prefabs/effect/20103.unity3d"
    self.resList = {
        {file = AssetConfig.sworn_progress_window, type = AssetType.Main},
        -- {file = AssetConfig.wingsbookbg, type = AssetType.Dep},
        {file = AssetConfig.sworn_textures, type = AssetType.Dep},
        {file = self.EffectPath, type = AssetType.Main},
        {file = AssetConfig.shop_textures, type = AssetType.Dep},
        {file = AssetConfig.ridebg, type = AssetType.Main},
        {file = AssetConfig.rank_textures, type = AssetType.Dep},
    }

    self.panelList = {}
    self.tabText = {
        TI18N("结拜试炼"),
        TI18N("长幼有序"),
        TI18N("结拜契约"),
    }
    self.fakeList = {}

    self.statusListener = function(status) self:StatusChange(status) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function SwornProgressWindow:__delete()
    self.OnHideEvent:Fire()
    if self.panelList ~= nil then
        for _,v in pairs(self.panelList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.panelList = nil
    end
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function SwornProgressWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.sworn_progress_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    local main = t:Find("Main")
    self.closeBtn = main:Find("Close"):GetComponent(Button)
    self.tabGroup = TabGroup.New(main:Find("TabContainer").gameObject, function(index) self:ChangeTab(index) end, {notAutoSelect = true, noCheckRepeat = false, isVertical = false})
    -- self.preview:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")

    self.descObj = main:Find("Try").gameObject
    self.voteObj = main:Find("Vote").gameObject
    self.confirmObj = main:Find("Confirm").gameObject

    self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    for i,v in pairs(self.tabGroup.buttonTab) do
        v.gameObject:GetComponent(Button).enabled = false
        v.text.text = self.tabText[i]
    end

    local fake = main:Find("Fake")
    for i=1,3 do
        local tab = {}
        tab.transform = fake:GetChild(i - 1)
        tab.gameObject = tab.transform.gameObject
        tab.normal = tab.transform:Find("Normal").gameObject
        tab.select = tab.transform:Find("Select").gameObject
        tab.btn = tab.gameObject:GetComponent(Button)
        local k = i
        tab.btn.onClick:AddListener(function() self:OnFakeClick(k) end)
        tab.transform:Find("Text"):GetComponent(Text).text = self.tabText[i]
        self.fakeList[i] = tab
    end

    self.descObj:SetActive(false)
    self.voteObj:SetActive(false)
    self.confirmObj:SetActive(false)
    -- UIUtils.AddBigbg(main:Find("Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.sworn_bg)))

    main:Find("Title/Text"):GetComponent(Text).text = TI18N("结 拜")
    self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
end

function SwornProgressWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SwornProgressWindow:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.sworn_status_change, self.statusListener)

    self:StatusChange(self.mgr.status)
    -- self.tabGroup:ChangeTab(3)
end

function SwornProgressWindow:OnHide()
    self:RemoveListeners()
    if self.previewComp ~= nil then
        self.previewComp:Hide()
    end

    if self.panelList ~= nil then
        for _,v in pairs(self.panelList) do
            if v ~= nil then
                v:Hiden()
            end
        end
    end
end

function SwornProgressWindow:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.sworn_status_change, self.statusListener)
end

function SwornProgressWindow:ChangeTab(index)
    local model = self.model
    if self.lastIndex ~= nil then
        if self.panelList[self.lastIndex] ~= nil then
            self.panelList[self.lastIndex]:Hiden()
        end
    end

    local panel = self.panelList[index]

    if panel == nil then
        if index == 1 then
            panel = SwornDescPanel.New(model, self.descObj, self.assetWrapper)
        elseif index == 2 then
            panel = SwornVotePanel.New(model, self.voteObj, self.assetWrapper)
        elseif index == 3 then
            panel = SwornConfirmPanel.New(model, self.confirmObj, self.assetWrapper)
        end
        self.panelList[index] = panel
        if panel ~= nil then
            panel:InitPanel()
        end
    end

    self.lastIndex = index
    if panel ~= nil then
        panel:Show(self.openArgs)
    end
end

function SwornProgressWindow:StatusChange(status)
    for i,v in ipairs(self.fakeList) do
        v.normal:SetActive(true)
        v.select:SetActive(false)
    end
    self.tabGroup.gameObject:SetActive(true)
    if status == self.mgr.statusEumn.None
        or status == self.mgr.statusEumn.Want
        or status == self.mgr.statusEumn.EndWant
        or status == self.mgr.statusEumn.Fight then
        self.tabGroup:ChangeTab(1)
        self.fakeList[1].select:SetActive(true)
    elseif status == self.mgr.statusEumn.Vote then
        self.tabGroup:ChangeTab(2)
        self.fakeList[2].select:SetActive(true)
    elseif status == self.mgr.statusEumn.Honor or status == self.mgr.statusEumn.SubHonor or status == self.mgr.statusEumn.Confirm then
        self.tabGroup:ChangeTab(3)
        self.fakeList[3].select:SetActive(true)
    end
    self.tabGroup.gameObject:SetActive(false)
end

function SwornProgressWindow:OnFakeClick(i)
    local status = self.mgr.status
    if status == self.mgr.statusEumn.None
        or status == self.mgr.statusEumn.Want
        or status == self.mgr.statusEumn.EndWant
        or status == self.mgr.statusEumn.Fight then
        if i == 1 then
            NoticeManager.Instance:FloatTipsByString(TI18N("正在进行此环节哦{face_1,2}"))
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("正在进行<color='#00ff00'>结拜试炼</color>环节哦{face_1,2}"))
        end
    elseif status == self.mgr.statusEumn.Vote then
        if i == 2 then
            NoticeManager.Instance:FloatTipsByString(TI18N("正在进行此环节哦{face_1,2}"))
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("正在进行<color='#00ff00'>长幼有序</color>环节哦{face_1,2}"))
        end
    elseif status == self.mgr.statusEumn.Honor
        or status == self.mgr.statusEumn.SubHonor
        or status == self.mgr.statusEumn.Confirm then
        if i == 3 then
            NoticeManager.Instance:FloatTipsByString(TI18N("正在进行此环节哦{face_1,2}"))
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("正在进行<color='#00ff00'>结拜契约</color>环节哦{face_1,2}"))
        end
    end
end

