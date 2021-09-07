BibleWindow = BibleWindow or BaseClass(BaseWindow)

function BibleWindow:__init(model)
    self.model = model
    self.mgr = BibleManager.Instance
    self.name = "BibleWindow"

    self.windowId = WindowConfig.WinID.biblemain

    self.cacheMode = CacheMode.Visible

    local depList = {}
    for _,v in pairs(model.classList) do
        if v.package ~= nil then
            depList[v.package] = true
        end
    end
    depList[AssetConfig.bible_textures] = true
    self.resList = {
        {file = AssetConfig.bible_window, type = AssetType.Main, holdTime = 5}
    }
    for k,_ in pairs(depList) do
        table.insert(self.resList, {file = k, type = AssetType.Dep})
    end

    self.boolTabShow = {false, false, false, false} -- 是否显示右边页签
    self.panelList = {nil, nil, nil, nil}

    self.noticeString = TI18N("活动尚未开启")

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.levelupListener = function() self:ReloadTab() end
    self.redPointListener = function() self:CheckRedPoint() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
    self.txtList = {}
    self.contentList = {}

    self.currentIndex = nil
end

function BibleWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.bible_window))
    self.gameObject.name = "BibleWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    local model = self.model
    self.mainContainer = self.transform:Find("Main").gameObject
    -- self.transform:Find("Main/WelfarePanel").gameObject:SetActive(false)
    -- self.transform:Find("Main/GrowguidePanel").gameObject:SetActive(false)

    self.transform:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function()
        -- for i=1,#self.panelList do
        --     if self.panelList[i] ~= nil then
        --         self.panelList[i]:RemoveListener()
        --     end
        -- end
        self.model:CloseWindow()
    end)

    self.tabListPanel = self.transform:Find("Main/TabListPanel")
    self.tabTemplate = self.tabListPanel:Find("TabButton").gameObject
    self.tabTemplate:SetActive(false)
    self.tabLayout = LuaBoxLayout.New(self.transform:Find("Main/TabListPanel").gameObject, {axis = BoxLayoutAxis.Y, spacing = 0})
    self.tabObjList = {}
    self.tabRedPoint = {}

    for i,v in ipairs(model.classList) do
        if v ~= nil then
            local obj = GameObject.Instantiate(self.tabTemplate)
            self.tabObjList[i] = obj
            obj.name = tostring(i)
            local t = obj.transform
            local content = model.classList[i].name
            self.tabRedPoint[i] = t:Find("RedPoint").gameObject
            local txt = t:Find("Text"):GetComponent(Text)
            txt.text = content
            obj:GetComponent(Button).onClick:AddListener(function() self:SwitchTabs(i) end)
            self.tabLayout:AddCell(obj)

            if v.icon ~= nil then
                t:Find("Text").anchoredPosition = Vector2(-3.4, 8.720001)
                t:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(v.package, v.icon)
                t:Find("Icon").gameObject:SetActive(true)
            else
                t:Find("Text").anchoredPosition = Vector2(-3.4, 21)
                t:Find("Icon").gameObject:SetActive(false)
            end

            table.insert(self.txtList, txt)
            table.insert(self.contentList, content)
        end
    end

    self.localpositionBrew = self.tabObjList[3].transform.localPosition

    self.OnOpenEvent:Fire()
end

function BibleWindow:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.role_level_change, self.levelupListener)
    self.mgr.onUpdateRedPoint:AddListener(self.redPointListener)

    -- BaseUtils.dump(BibleManager.Instance.redPointDic)
    self:ReloadTab()
    if self.currentIndex ~= nil then
        self:EnableTab(self.currentIndex, false)
    end
    if self.model.currentMain == 4 and not self.boolTabShow[4] then
        NoticeManager.Instance:FloatTipsByString(self.noticeString)
        self.model.currentMain = 1
    end
    self:SwitchTabs(self.model.currentMain)
    if self.model.currentMain == 3 then
        self.model.currentMain = 1
    end
    -- self:CheckBrewCanShow()

    -- BaseUtils.dump(CampaignManager.Instance.campaignTree, "<color=#00FF00>campaignTree</color>")
    -- BaseUtils.dump(CampaignManager.Instance.bibleList, "<color=#0000FF>bibleList</color>")
end

function BibleWindow:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.role_level_change, self.levelupListener)
    self.mgr.onUpdateRedPoint:RemoveListener(self.redPointListener)
end

function BibleWindow:CheckBrewCanShow()
    if RoleManager.Instance.RoleData.lev < 10 then
        self.tabObjList[3]:SetActive(false)
    else
        self.tabObjList[3]:SetActive(true)
        if RoleManager.Instance.RoleData.lev < 14 then
            self.tabObjList[3].transform.localPosition = self.tabObjList[2].transform.localPosition
        else
            self.tabObjList[3].transform.localPosition = self.localpositionBrew
        end
    end
end

function BibleWindow:HideAllPanel()
    for k,v in pairs(self.panelList) do
        if v ~= nil then
            self.panelList[k]:Hiden()
        end
    end
end

function BibleWindow:SwitchTabs(main)
    self.model.openArgs = {}
    local model = self.model
    if main ~= self.currentIndex then
        if self.currentIndex ~= nil then
            self:EnableTab(self.currentIndex, false)
            local panel = self.panelList[self.currentIndex]
            if panel ~= nil then
                panel:Hiden()
            end
        end
    end
    if self.currentIndex ~= nil then
        self.txtList[self.currentIndex].text = string.format(ColorHelper.TabButton1NormalStr, self.contentList[self.currentIndex])
    end
    model.currentMain = main
    self.currentIndex = main
    self.txtList[self.currentIndex].text = string.format(ColorHelper.TabButton1SelectStr, self.contentList[self.currentIndex])

    self:EnableTab(model.currentMain, true)
    local panel = self.panelList[main]
    if main == 1 then
        if panel == nil then
            panel = BibleRewardPanel.New(model, self.mainContainer)
            self.panelList[main] = panel
        end
    elseif main == 2 then
        if panel == nil then
            panel = BibleGrowguildPanel.New(model, self.mainContainer)
            self.panelList[main] = panel
        end
    elseif main == 3 then

        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.strategy_window, {1})
        model.currentMain = 1
        return
    elseif main == 4 then
        if panel == nil then
            panel = BibleRealNamePanel.New(model, self.mainContainer)
            -- if CampaignManager.Instance.currentFestival == CampaignEumn.Type.Labour then
            --     panel = LabourBiblePanel.New(model, self.mainContainer)
            -- elseif CampaignManager.Instance.currentFestival == CampaignEumn.Type.May then
            --     panel = MayBiblePanel.New(model, self.mainContainer)
            -- elseif CampaignManager.Instance.currentFestival == CampaignEumn.Type.Children then
            --     panel = ChildBiblePanel.New(model, self.mainContainer)
            -- elseif CampaignManager.Instance.currentFestival == CampaignEumn.Type.MidAutumn then
            --     panel = MidAutumnPanel.New(model, self.mainContainer)
            -- else
            --     panel = CampaignBiblePanel.New(model, self.mainContainer)
            -- end
            -- self.panelList[main] = panel
        end
    end
    if panel ~= nil then
        panel:Show()
    end
end

function BibleWindow:__delete()
    if self.model.brewModel ~= nil then
        self.model.brewModel:CloseWarmTipsUI()
    end


    self.OnHideEvent:Fire()

    if self.tabLayout ~= nil then
        self.tabLayout:DeleteMe()
        self.tabLayout = nil
    end
    if self.panelList ~= nil then
        for i,v in pairs(self.panelList) do
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
    self.panelList = nil
    self:AssetClearAll()
end

function BibleWindow:EnableTab(main, bool)
    if main == 4 then
        if bool == true then
            self.tabObjList[main].transform:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.bible_textures, "AtivityIcon1")
        else
            self.tabObjList[main].transform:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.bible_textures, "AtivityIcon2")
        end
    else
        if bool == true then
            self.tabObjList[main].transform:Find("Bg"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton1Select")
        else
            self.tabObjList[main].transform:Find("Bg"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton1Normal")
        end
    end
end

function BibleWindow:OnHide()
    if self.model.brewModel ~= nil then
        self.model.brewModel:CloseWarmTipsUI()
    end

    self:RemoveListeners()
    self:HideAllPanel()

    if self:CheckFinish() then
        QuestManager.Instance:DoMain()
    end
end

function BibleWindow:CheckRedPoint()
    local redPointDic = BibleManager.Instance.redPointDic
    local bool = nil
    local openLevel = self.model:CheckTabShow()
    for k,v in pairs(redPointDic) do
        bool = false
        for k1,v1 in pairs(v) do
            if k == 1 then
                bool = bool or (v1 == true and openLevel[k1] ~= false)
            else
                bool = bool or v1
            end
        end
        self.tabRedPoint[k]:SetActive(bool)
    end
    BibleManager.Instance:CheckMainUIIconRedPoint()
end

function BibleWindow:ShowActiveTabButton()
    self.tabObjList[4]:SetActive(CampaignManager.Instance.hasFestival)
end

function BibleWindow:ReloadTab()
    self.boolTabShow[1] = true
    self.boolTabShow[2] = (RoleManager.Instance.RoleData.lev >= 10)
    self.boolTabShow[3] = (RoleManager.Instance.RoleData.lev >= 12)

    local show = false --检查是否已经实名制过
    if CampaignManager.Instance.bibleType ~= nil then
        if CampaignManager.Instance.hasBuyThree == true then
            show = CampaignManager.Instance.campaignTree[CampaignManager.Instance.bibleType].count > 1
        else
            show = CampaignManager.Instance.campaignTree[CampaignManager.Instance.bibleType].count > 0
        end
    end
    self.boolTabShow[4] = show

    self.tabLayout:ReSet()
    for i,v in ipairs(self.tabObjList) do
        if v ~= nil then
            v:SetActive(self.boolTabShow[i])
            if self.boolTabShow[i] == true then
                self.tabLayout:AddCell(v)
            end
        end
    end
end

function BibleWindow:CheckFinish()
    local quest = QuestManager.Instance:GetQuest(10084)
    if quest ~= nil then
        if quest.progress_ser[1].finish == 1 and quest.progress_ser[2].finish == 1 then
            return true
        end
    end

    quest = QuestManager.Instance:GetQuest(22084)
    if quest ~= nil then
        if quest.progress_ser[1].finish == 1 and quest.progress_ser[2].finish == 1 then
            return true
        end
    end

    return false
end

