-- ----------------------------------------------------------
-- UI - 家园窗口
-- ljh 20160712
-- ----------------------------------------------------------
HomeWindow = HomeWindow or BaseClass(BaseWindow)

function HomeWindow:__init(model)
    self.model = model
    self.name = "HomeWindow"
    self.windowId = WindowConfig.WinID.home_window
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
        {file = AssetConfig.homewindow, type = AssetType.Main},
        {file = AssetConfig.homeTexture, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

    self.mainTransform = nil

    ------------------------------------------------
    self.currentIndex = 1

    self.childIndex = {
        info = 1,
        build = 2,
        shop = 3,
        extension = 4,
    }

    ------------------------------------------------
    self.tabGroup = nil
    self.tabGroupObj = nil

    self.childTab = {}
    self.headbar = nil

    ------------------------------------------------
    self._update_red = function() self:update_red() end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function HomeWindow:__delete()
    self:OnHide()

    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end

    if self.childTab ~= nil then
        for _, child in pairs(self.childTab) do
            child:DeleteMe()
        end
        self.childTab = nil
    end

    self:AssetClearAll()
end

function HomeWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.homewindow))
    self.gameObject.name = "HomeWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.tabGroupObj = self.mainTransform:FindChild("TabButtonGroup")

    local tabGroupSetting = {
        notAutoSelect = true,
        openLevel = {0, 0, 0, 0},
        perWidth = 62,
        perHeight = 100,
        isVertical = true
    }
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index)
        self:ChangeTab(index)
    end, tabGroupSetting)

    ----------------------------

    self:OnShow()
end

function HomeWindow:OnClickClose()
    self:OnHide()
    WindowManager.Instance:CloseWindow(self)
end

function HomeWindow:OnShow()
    if self.openArgs ~= nil and #self.openArgs > 0 then
        if self.childTab[self.currentIndex] ~= nil then
            self.childTab[self.currentIndex]:Hiden()
        end
        self.currentIndex = tonumber(self.openArgs[1])
    end

    self.tabGroup.noCheckRepeat = true
    self.tabGroup:ChangeTab(self.currentIndex)
    self.tabGroup.noCheckRepeat = false
    self:update_red()
    self:addevents()

    -- 隔日重新请求11221协议，属性建筑使用次数信息
    if os.date("%d", BaseUtils.BASE_TIME) ~= HomeManager.Instance.last11221 then
        HomeManager.Instance:Send11221()
    end
end

function HomeWindow:OnHide()
    self.openArgs = nil
    local child = self.childTab[self.currentIndex]
    if child ~= nil then
        child:Hiden()
    end
    GuideManager.Instance:CloseWindow(self.windowId)
    self:removeevents()
end

function HomeWindow:ChangeTab(index)
    if self.currentIndex ~= 0 and self.currentIndex ~= index then
        if self.childTab[self.currentIndex] ~= nil then
            self.childTab[self.currentIndex]:Hiden()
        end
    end
    self.currentIndex = index
    local child = self.childTab[self.currentIndex]
    if child == nil then
        if index == self.childIndex.info then
            child = HomeWindow_Info.New(self)
        elseif index == self.childIndex.build then
            child = HomeWindow_Build.New(self)
        elseif index == self.childIndex.shop then
            child = HomeShopSubPanel.New(self.model, self.mainTransform)
        elseif index == self.childIndex.extension then
            child = HomeWindow_Extension.New(self)
        else
            child = HomeWindow_Info.New(self)
        end
        self.childTab[self.currentIndex] = child
    end
    child:Show(self.openArgs)
end

function HomeWindow:addevents()
    EventMgr.Instance:AddListener(event_name.home_base_update, self._update_red)
    EventMgr.Instance:AddListener(event_name.home_use_info_update, self._update_red)
    EventMgr.Instance:AddListener(event_name.home_train_info_update, self._update_red)

    -- EventMgr.Instance:AddListener(event_name.role_asset_change, self._update_item)
    -- SkillManager.Instance.OnUpdateMarrySkill:Add(self._update_marryskill)
end

function HomeWindow:removeevents()
    EventMgr.Instance:RemoveListener(event_name.home_base_update, self._update_red)
    EventMgr.Instance:RemoveListener(event_name.home_use_info_update, self._update_red)
    EventMgr.Instance:RemoveListener(event_name.home_train_info_update, self._update_red)
    -- EventMgr.Instance:RemoveListener(event_name.role_asset_change, self._update_item)
    -- SkillManager.Instance.OnUpdateMarrySkill:Remove(self._update_marryskill)
end

function HomeWindow:update_red()
    if self.gameObject == nil then return end

    self.tabGroup:ShowRed(4, self.model:GetHomeMaxLev() > self.model.home_lev)

    -- 宠物室的空位
    local red = false

    local build = self.model:getbuild(2)
    if build == nil then
        return
    end
    local petItem_list = self.model:getpettrainlist()
    local length = self.model:getbuilddataeffecttype(2, build.lev, 6)
    if build.lev == 0 then  -- 如果当前等级为0，则打开1个宠物栏
        length = 1
    end
    for i=1, length do
        red = red or (petItem_list[i] == nil)
    end

    -- 卧室的使用
    local all_times = self.model:geteffecttypevalue(12)
    local used_times = self.model:getbuildeffecttypevalue(55)
    red = red or (all_times - used_times > 0)

    self.tabGroup:ShowRed(1, red)
end


