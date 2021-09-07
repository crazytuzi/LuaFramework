--师徒主窗口
-- @author zgs
TeacherWindow = TeacherWindow or BaseClass(BaseWindow)

function TeacherWindow:__init(model)
    self.model = model
    self.name = "TeacherWindow"
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end

    self.selectIndex = 1

    self.resList = {
        {file = AssetConfig.teacher_window, type = AssetType.Main}
        -- ,{file = AssetConfig.guild_dep_res, type = AssetType.Dep}
        -- ,{file = AssetConfig.guild_totem_icon, type = AssetType.Dep}
        -- ,{file = AssetConfig.shop_textures, type = AssetType.Dep}
    }

    self.checkRedListener = function() self:CheckRed() end
    self.checkSwornRedListener = function()
        self:CheckSwornRed()
    end

    self.OnOpenEvent:AddListener(function()
        -- local index = self.selectIndex
        -- if self.openArgs ~= nil and self.openArgs[1] ~= nil then
        --     index = tonumber(self.openArgs[1])
        -- end
        -- self.tabgroup:ChangeTab(1)
        -- self:updateWindow(1)
        self:OnOpen()
    end)

    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.panelList = {}

    -- self.guildfightDataUpdateFun = function ()
    --     if self.tabgroup ~= nil then
    --         self.tabgroup:ChangeTab(self.selectIndex)
    --     end
    -- end
    -- EventMgr.Instance:AddListener(event_name.guild_fight_data_update, self.guildfightDataUpdateFun)

end

function TeacherWindow:OnInitCompleted()
    -- GuildfightManager.Instance:send15501()
    -- GuildfightManager.Instance:send15506()
    -- self.isNeedShowTips = false
    -- local index = self.selectIndex
    -- if self.openArgs ~= nil and self.openArgs[1] ~= nil then
    --     index = tonumber(self.openArgs[1])
    -- end
    -- self.tabgroup:ChangeTab(1)
    -- self:updateWindow(1)
    self.OnOpenEvent:Fire()
end

function TeacherWindow:__delete()
    self.OnHideEvent:Fire()

    if self.panelList ~= nil then
        for i,v in pairs(self.panelList) do
            v:DeleteMe()
        end
        self.panelList = nil
    end
    if self.tabgroup ~= nil then
        self.tabgroup:DeleteMe()
        self.tabgroup = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
    self.model.gaWin = nil
    self.model = nil
end

function TeacherWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.teacher_window))
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.closeBtn = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function()
        self:OnClickClose()
    end)

    self.titleText = self.transform:Find("Main/Title/Text"):GetComponent(Text)

    self.container = self.transform:Find("Main").gameObject

    local setting = {
            notAutoSelect = true,
            noCheckRepeat = true,
            openLevel = {0, 0},
            perWidth = 62,
            perHeight = 120,
            isVertical = true
        }
    self.tabGroupObj = self.container.transform:Find("TabButtonGroup").gameObject

    self.tabgroup = TabGroup.New(self.tabGroupObj, function (tab) self:OnTabChange(tab) end,setting)

    self.OnOpenEvent:Fire()
end

function TeacherWindow:OnOpen()
    self.tabgroup.openLevel = self.tabgroup.openLevel or {1, 1, 1}
    if TeacherManager.Instance.showIcon == true then
        self.tabgroup.openLevel[1] = 1
        if self.model.myTeacherInfo ~= nil and self.model.myTeacherInfo.status == TeacherEnum.Type.Teacher and self.model.myTeacherInfo.rid > 0 then
            --是出师的徒弟
            self.tabgroup.openLevel[2] = 1
        else
            self.tabgroup.openLevel[2] = 255
        end
    else
        self.tabgroup.openLevel[1] = 255
        self.tabgroup.openLevel[2] = 255
    end
    if SwornManager.Instance.showIcon == true then
        self.tabgroup.openLevel[3] = 1
    else
        self.tabgroup.openLevel[3] = 255
    end

    self.tabgroup:Layout()

    local index = (self.openArgs or {})[1] or self.selectIndex or 1
    local lev = RoleManager.Instance.RoleData.lev
    if self.tabgroup.openLevel[index] > lev then
        for i,v in ipairs(self.tabgroup.openLevel) do
            if lev >= v then
                index = i
                break
            end
        end
    end
    self.tabgroup:ChangeTab(index)
    -- self.tabGroupObj.transform:GetChild(2).gameObject:SetActive(false)
    self:RemoveListeners()
    TeacherManager.Instance.onUpdateDailyRed:AddListener(self.checkRedListener)
    EventMgr.Instance:AddListener(event_name.sworn_status_change, self.checkSwornRedListener)
    self:CheckSwornRed()
end

function TeacherWindow:OnHide()
    self:RemoveListeners()
end

function TeacherWindow:RemoveListeners()
    TeacherManager.Instance.onUpdateDailyRed:RemoveListener(self.checkRedListener)
    EventMgr.Instance:RemoveListener(event_name.sworn_status_change, self.checkSwornRedListener)
end

function TeacherWindow:OnTabChange(tab)
    self:updateWindow(tab)
end

function TeacherWindow:updateWindow(index)
    if self.panelList[self.selectIndex] ~= nil then
        self.panelList[self.selectIndex]:Hiden()
    end
    self.selectIndex = index
    if self.panelList[self.selectIndex] == nil then
        if self.selectIndex == 1 then
            self.panelList[self.selectIndex] = TeacherPanel.New(self.model,self.container)
        -- elseif self.selectIndex == 2 then
        --     self.panelList[self.selectIndex] = StudentPanel.New(self.model,self.container)
        elseif self.selectIndex == 2 then
            local stuData = {rid = RoleManager.Instance.RoleData.id,platform = RoleManager.Instance.RoleData.platform,zone_id = RoleManager.Instance.RoleData.zone_id}
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.apprenticeship, {stuData, 1})
            return
        elseif self.selectIndex == 3 then
            self.panelList[self.selectIndex] = SwornPanel.New(SwornManager.Instance.model, self.container)
        end
    end

    if index == 1 then
        self.titleText.text = TI18N("我的师门")
    elseif index == 3 then
        self.titleText.text = TI18N("结 拜")
    end

    self.panelList[self.selectIndex]:Show()
end
-- function TeacherWindow:updateTeacherWindow()
--     if self.panelList[self.selectIndex] ~= nil then
--         self.panelList[self.selectIndex]:UpdateWindow()
--     end
-- end
function TeacherWindow:OnClickClose()
    self.model:CloseMain()
end

function TeacherWindow:CheckRed()
    local roleData = RoleManager.Instance.RoleData
    if self.tabgroup.buttonTab[2] ~= nil then
        self.tabgroup.buttonTab[2].red:SetActive(TeacherManager.Instance.dailyInitRed[BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id)] == true)
    end
end

function TeacherWindow:CheckSwornRed()
    if self.tabgroup.buttonTab[3] ~= nil then
        local state = SwornManager.Instance:CheckRedPointState()
        self.tabgroup.buttonTab[3].red:SetActive(state)
    end
end