-- ------------------------
-- 诸神之战 -- 对战面板
-- hosr
-- ------------------------
GodsWarFightPanel = GodsWarFightPanel or BaseClass(BasePanel)

function GodsWarFightPanel:__init(parent)
	self.parent = parent
	self.resList = {
		{file = AssetConfig.godswarfight, type = AssetType.Main},
		{file = AssetConfig.godswarres, type = AssetType.Dep},
	}

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.panelList = {}
    self.currIndex = 0
    self.listener = function() self:UpdateTab() end
end

function GodsWarFightPanel:__delete()
	EventMgr.Instance:RemoveListener(event_name.godswar_fighter_update, self.listener)

	if self.tabGroup ~= nil then
		self.tabGroup:DeleteMe()
		self.tabGroup = nil
	end

	for i,v in pairs(self.panelList) do
		v:DeleteMe()
	end
	self.panelList = nil
end

function GodsWarFightPanel:OnShow()
	self:UpdateTab()
	self.args = self.parent.args
	local index = 2
	local status = GodsWarManager.Instance.status

    if status == GodsWarEumn.Step.None then
    	index = 4
	elseif status < GodsWarEumn.Step.Publicity then
		index = 2
	elseif status >= GodsWarEumn.Step.Audition1Idel and status <= GodsWarEumn.Step.Audition7 then
		index = 2
	elseif status >= GodsWarEumn.Step.Elimination32Idel and status <= GodsWarEumn.Step.Elimination8 then
		index = 3
	elseif status >= GodsWarEumn.Step.Elimination4Idel then
		index = 4
	end

    if status == GodsWarEumn.Step.None then
    	index = 4
    else
    	if self.args ~= nil and self.args[1] == 3 and self.args[2] ~= nil then
    		index = self.args[2]
    	end
    end

	self.tabGroup:ChangeTab(index)

	GodsWarManager.Instance:Send17918()
end

function GodsWarFightPanel:OnHide()
end

function GodsWarFightPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarfight))
    self.gameObject.name = "GodsWarFightPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.mainTransform)
    self.transform.localScale = Vector3.one
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.rect.anchoredPosition = Vector2(0, -30)

    self.container = self.transform:Find("PanelContainer")

    local tabGroupSetting = {
        notAutoSelect = true,
        noCheckRepeat = true,
        perWidth = 120,
        perHeight = 40,
        isVertical = false,
        spacing = 10,
        openLevel = {999, 999, 999, 999},
    }
    self.tabGroup = TabGroup.New(self.transform:Find("TabButtonGroup"), function(index) self:ChangeTab(index) end, tabGroupSetting)
    self.panelList = {
    	GodsWarFightMyPanel.New(self),
    	GodsWarFightListPanel.New(self),
    	GodsWarFightElimintionPanel.New(self),
    	GodsWarFightFinalPanel.New(self),
	}
	EventMgr.Instance:AddListener(event_name.godswar_fighter_update, self.listener)

    self:OnShow()
end

function GodsWarFightPanel:ChangeTab(index)
	if self.panelList[self.currIndex] ~= nil then
		self.panelList[self.currIndex]:Hiden()
	end
	self.currIndex = index
	self.panelList[self.currIndex]:Show()
end

function GodsWarFightPanel:UpdateTab()
    local setting = {
        notAutoSelect = true,
        noCheckRepeat = true,
        perWidth = 120,
        perHeight = 40,
        isVertical = false,
        spacing = 10,
        openLevel = {999, 999, 999, 999},
    }

    local status = GodsWarManager.Instance.status
    local fighter = GodsWarManager.Instance.myFighter
    local flag = GodsWarManager.Instance.flag
    local showFight = false

	if fighter ~= nil and flag > 0 then
		if fighter.flag == 2 then
			-- 轮空
			showFight = true
		else
			if fighter.tid ~= 0 then
				showFight = true
			end
		end
	end

    if status == GodsWarEumn.Step.None then
        setting.openLevel = {999, 999, 999, 1}
	elseif status <= GodsWarEumn.Step.Publicity then
		setting.openLevel = {(showFight and 1 or 999), 1, 999, 999}
	elseif status >= GodsWarEumn.Step.Audition1Idel and status <= GodsWarEumn.Step.Audition7 then
		setting.openLevel = {(showFight and 1 or 999), 1, 999, 999}
	elseif status >= GodsWarEumn.Step.Elimination32Idel and status <= GodsWarEumn.Step.Elimination8 then
		setting.openLevel = {(showFight and 1 or 999), 999, 1, 999}
	elseif status >= GodsWarEumn.Step.Elimination4Idel then
		setting.openLevel = {(showFight and 1 or 999), 999, 999, 1}
	end

	self.tabGroup:UpdateSetting(setting)
	self.tabGroup:Layout()
end