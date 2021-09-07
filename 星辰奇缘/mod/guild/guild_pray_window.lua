--2017/2/16
--zzl
--公会祈祷

GuildPrayWindow  =  GuildPrayWindow or BaseClass(BaseWindow)

function GuildPrayWindow:__init(model)
    self.name  =  "GuildPrayWindow"
    self.model  =  model
    -- 缓存

    self.resList  =  {
        {file  =  AssetConfig.guild_pray_win, type  =  AssetType.Main}
        , {file = AssetConfig.guild_dep_res, type = AssetType.Dep}
    }

    self.subFirst = nil
    self.subSecond = nil

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.curIndex = 1
    return self
end

function GuildPrayWindow:OnShow()
    self.tabgroup:ChangeTab(1)
end

function GuildPrayWindow:OnHide()
end

function GuildPrayWindow:__delete()
    self.is_open  =  false
    if self.subFirst ~= nil then
        self.subFirst:DeleteMe()
        self.subFirst = nil
    end
    if self.subSecond ~= nil then
        self.subSecond:DeleteMe()
        self.subSecond = nil
    end
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end


function GuildPrayWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_pray_win))
    self.gameObject:SetActive(false)
    self.gameObject.name = "GuildPrayWindow"

    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)
    self.transform = self.gameObject.transform
    self.main = self.transform:Find("Main")
    self.mainObj = self.main:Find("PanelCon")
    local closeBtn = self.gameObject.transform:Find("Main/CloseButton"):GetComponent(Button)
    closeBtn.onClick:AddListener(function()
        self.model:ClosePrayUI()
    end)
    local go = self.transform:Find("Main/TabButtonGroup").gameObject
    self.tabgroup = TabGroup.New(go, function (tab) self:OnTabChange(tab) end)

end

function GuildPrayWindow:OnTabChange(index)
    self.curIndex = index
    if index == 1 then
        self:OnShowTabFirst()
    elseif index == 2 then
        self:OnShowTabSecond()
    end
end

function GuildPrayWindow:OnShowTabFirst()
    if self.subSecond ~= nil then
        self.subSecond:Hiden()
    end
    if self.subFirst == nil then
        self.subFirst = GuildPrayPanel.New(self)
    end
    self.subFirst:Show(self.openArgs)
end

function GuildPrayWindow:OnShowTabSecond()
    if self.subFirst ~= nil then
        self.subFirst:Hiden()
    end
    if self.subSecond == nil then
        self.subSecond = GuildPrayManagePanel.New(self)
    end
    self.subSecond:Show(self.openArgs)
end

function GuildPrayWindow:PlayPraySuccessEffect(data)
    if self.subFirst ~= nil then
        self.subFirst:PlayEffect(data)
    end
end

function GuildPrayWindow:UpdatePrayPanelAttr(data)
    if self.subFirst ~= nil then
        self.subFirst:UpdatePrayPanelAttr(data)
    end
end


function GuildPrayWindow:OnSwitchPrayToggle()
    if self.subFirst ~= nil then
        self.subFirst:OnSwitchPrayToggle()
    end
end


function GuildPrayWindow:UpdateManagePanel()
    if self.subSecond ~= nil then
        self.subSecond:UpdateLeftList()
    end
end

function GuildPrayWindow:UpdateElementUpPrice(data)
    if self.subSecond ~= nil then
        self.subSecond:UpdateRightBottom(data)
    end
end