-- 公会战主窗口
-- @author zgs
GuildfightWindow = GuildfightWindow or BaseClass(BaseWindow)

function GuildfightWindow:__init(model)
    self.model = model
    self.name = "GuildfightWindow"
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.selectIndex = 1

    self.resList = {
        {file = AssetConfig.guild_fight_window, type = AssetType.Main}
        -- ,{file = AssetConfig.guild_dep_res, type = AssetType.Dep}
        -- ,{file = AssetConfig.guild_totem_icon, type = AssetType.Dep}
        -- ,{file = AssetConfig.shop_textures, type = AssetType.Dep}
    }
    self.isNeedShowTips = false
    self.OnOpenEvent:AddListener(function()
        GuildfightManager.Instance:send15501()
        GuildfightManager.Instance:send15506()
        self.isNeedShowTips = false
        local index = self.selectIndex
        if self.openArgs ~= nil and self.openArgs[1] ~= nil then
            index = tonumber(self.openArgs[1])
        end
        self.tabgroup:ChangeTab(index)
    end)

    self.panelList = {}

    self.guildfightDataUpdateFun = function ()
        if self.tabgroup ~= nil then
            self.tabgroup:ChangeTab(self.selectIndex)
        end
    end
    EventMgr.Instance:AddListener(event_name.guild_fight_data_update, self.guildfightDataUpdateFun)

end

function GuildfightWindow:OnInitCompleted()
    GuildfightManager.Instance:send15501()
    GuildfightManager.Instance:send15506()
    self.isNeedShowTips = false
    local index = self.selectIndex
    if self.openArgs ~= nil and self.openArgs[1] ~= nil then
        index = tonumber(self.openArgs[1])
    end
    self.tabgroup:ChangeTab(index)
end

function GuildfightWindow:__delete()
    for i,v in ipairs(self.panelList) do
        v:DeleteMe()
    end
    if self.tabgroup ~= nil then
        self.tabgroup:DeleteMe()
        self.tabgroup = nil
    end
    EventMgr.Instance:RemoveListener(event_name.guild_fight_data_update, self.guildfightDataUpdateFun)
    self.OnOpenEvent:RemoveAll()
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.model = nil
end

function GuildfightWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_fight_window))
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.closeBtn = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function()
        self:OnClickClose()
    end)

    self.container = self.transform:Find("Main/Con").gameObject

    local go = self.transform:Find("Main/TabButtonGroup").gameObject
    local setting = {
            notAutoSelect = true,
            noCheckRepeat = true,
            openLevel = {0, 0, 0},
            perWidth = 100,
            perHeight = 38,
            isVertical = false
        }
    self.tabgroup = TabGroup.New(go, function (index)
        self:OnTabChange(index)
    end,setting)
    -- print(self.tabgroup)
end

--进入界面时，刷新整个界面
function GuildfightWindow:OnTabChange(index)
    -- print("GuildfightWindow:OnTabChange "..debug.traceback())
    self:updateWindow(index)
end

function GuildfightWindow:updateWindow(index)
    if self.panelList[self.selectIndex] ~= nil then
        self.panelList[self.selectIndex]:Hiden()
    end
    self.selectIndex = index
    if index == 1 then
        local dataList = GuildfightManager.Instance.myGuildFightList
        if GuildManager.Instance.model:check_has_join_guild() == false then
            --当前还未加入公会
            if self.isNeedShowTips == true then
                NoticeManager.Instance:FloatTipsByString(TI18N("当前还未加入公会"))
            end
            --没有加入公会，显示第二个页签
            self.tabgroup:ChangeTab(2)
            return
        elseif dataList == nil or #dataList ~= 2 then
            if self.isNeedShowTips == true then
                NoticeManager.Instance:FloatTipsByString(TI18N("暂无公会对阵信息"))
            end
            self.tabgroup:ChangeTab(2)
            return
        end
    end

    if self.panelList[self.selectIndex] == nil then
        if self.selectIndex == 1 then
            self.panelList[self.selectIndex] = GuildfightMinePanel.New(self.model,self.container)
        elseif self.selectIndex == 2 then
            self.panelList[self.selectIndex] = GuildfightListPanel.New(self.model,self.container)
        end
    end

    if self.selectIndex == 3 then
        --打开排行榜
        -- self.tabgroup:ChangeTab(2)
        self.selectIndex = 2
        -- self:OnClickClose()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ui_rank, {1, 40})
    elseif self.selectIndex == 4 then
        --打开
        self.selectIndex = 2
        GuildManager.Instance.model:InitFindUI()
    else
        self.panelList[self.selectIndex]:Show()
    end
    if self.isNeedShowTips == false then
        self.isNeedShowTips = true
    end
end

function GuildfightWindow:OnClickClose()
    self.model:CloseMain()
end


