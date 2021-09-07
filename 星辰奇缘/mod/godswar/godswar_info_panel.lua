-- ----------------------------------
-- 诸神之战--信息面板
-- hosr
-- ----------------------------------
GodsWarInfoPanel = GodsWarInfoPanel or BaseClass(BasePanel)

function GodsWarInfoPanel:__init(parent)
	self.parent = parent
	self.resList = {
		{file = AssetConfig.godswarinfo, type = AssetType.Main},
		{file = AssetConfig.godswarres, type = AssetType.Dep},
	}

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.panelList = {}
    self.currIndex = 0
end

function GodsWarInfoPanel:__delete()
	if self.tabGroup ~= nil then
		self.tabGroup:DeleteMe()
		self.tabGroup = nil
	end

	for i,v in ipairs(self.panelList) do
		v:DeleteMe()
	end
	self.panelList = nil
end

function GodsWarInfoPanel:OnShow()
	self.args = self.parent.args
	if self.args == nil or self.args[1] ~= 1 or self.args[2] == nil then
		self.tabGroup:ChangeTab(1)
	else
		self.tabGroup:ChangeTab(self.args[2])
	end
end

function GodsWarInfoPanel:OnHide()
end

function GodsWarInfoPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarinfo))
    self.gameObject.name = "GodsWarInfoPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.mainTransform)
    self.transform.localScale = Vector3.one
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.rect.anchoredPosition = Vector2(0, -30)

    self.container = self.transform:Find("PanelContainer")

    local tabGroupSetting = {
        notAutoSelect = true,
        noCheckRepeat = false,
    }
    self.tabGroup = TabGroup.New(self.transform:Find("TabButtonGroup"), function(index) self:ChangeTab(index) end, tabGroupSetting)
    self.panelList = {
    	GodsWarRulePanel.New(self),
    	GodsWarArrangePanel.New(self),
    	GodsWarRankPanel.New(self),
	}
	self.tabGroup.buttonTab[3].gameObject:SetActive(false)

    self:OnShow()
end

function GodsWarInfoPanel:ChangeTab(index)
	if self.currIndex == index then
		return
	end

	if self.panelList[self.currIndex] ~= nil then
		self.panelList[self.currIndex]:Hiden()
	end
	self.currIndex = index
	self.panelList[self.currIndex]:Show()
end