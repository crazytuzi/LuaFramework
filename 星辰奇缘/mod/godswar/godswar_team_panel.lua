-- ------------------------------
-- 诸神之战 -- 战队面板
-- hosr
-- ------------------------------
GodsWarTeamPanel = GodsWarTeamPanel or BaseClass(BasePanel)

function GodsWarTeamPanel:__init(parent)
	self.parent = parent
	self.resList = {
		{file = AssetConfig.godswarteam, type = AssetType.Main},
		{file = AssetConfig.godswarres, type = AssetType.Dep},
	}

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.currIndex = 0
    self.panelList = {}

    self.listener = function() self:Update() end
end

function GodsWarTeamPanel:__delete()
	EventMgr.Instance:RemoveListener(event_name.godswar_team_update, self.listener)
	for i,v in ipairs(self.panelList) do
		v:DeleteMe()
	end
	self.panelList = nil

	if self.tabGroup ~= nil then
		self.tabGroup:DeleteMe()
		self.tabGroup = nil
	end
end

function GodsWarTeamPanel:OnShow()
	if self.openArgs ~= nil and self.openArgs[1] ~= nil then
		self.args = self.openArgs[1]
	else
		self.args = nil
	end
	self:Update()
	EventMgr.Instance:AddListener(event_name.godswar_team_update, self.listener)
end

function GodsWarTeamPanel:OnHide()
	EventMgr.Instance:RemoveListener(event_name.godswar_team_update, self.listener)
	for i,v in ipairs(self.panelList) do
		v:Hiden()
	end
end

function GodsWarTeamPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarteam))
    self.gameObject.name = "GodsWarTeamPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.mainTransform)
    self.transform.localScale = Vector3.one
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.rect.anchoredPosition = Vector2(0, -30)

    local tabGroupSetting = {
        notAutoSelect = true,
        noCheckRepeat = true,
    }

    self.tabGroup = TabGroup.New(self.transform:Find("TabButtonGroup"), function(index) self:ChangeTab(index) end, tabGroupSetting)
    self.panelList = {
    	GodsWarTeamInfoPanel.New(self),
    	GodsWarTeamRequestPanel.New(self),
    	GodsWarTeamListPanel.New(self),
	}

	self:OnShow()
end

function GodsWarTeamPanel:ChangeTab(index)
	self.tabGroup:ShowRed(index, false)
	if self.panelList[self.currIndex] ~= nil then
		self.panelList[self.currIndex]:Hiden()
	end
	self.currIndex = index
	self.panelList[self.currIndex]:Show()
	if self.currIndex == 2 then
		GodsWarManager.Instance.requestRed = false
	end
end

function GodsWarTeamPanel:Update()
	self:UpdateRed()
	self.data = GodsWarManager.Instance.myData
	if self.data ~= nil and self.data.tid ~= 0 then
		-- self.tabGroup.buttonTab[1].gameObject:SetActive(true)
		-- self.tabGroup.buttonTab[2].gameObject:SetActive(true)
		for i,v in ipairs(self.tabGroup.buttonTab) do
			v.gameObject:SetActive(true)
		end
		if self.args ~= nil then
            if #GodsWarManager.Instance.myData.applys <= 0 and self.args == 2 then
                self.tabGroup:ChangeTab(1)
            else
            	if self.args <= 3 then
				    self.tabGroup:ChangeTab(tonumber(self.args))
				else
					self.tabGroup:ChangeTab(1)
				end
            end
		else
			if self.currIndex == 0 then --or self.currIndex == 3 then
				self.tabGroup:ChangeTab(1)
			else
				self.tabGroup:ChangeTab(self.currIndex)
			end
		end
	else
		for i,v in ipairs(self.tabGroup.buttonTab) do
			v.gameObject:SetActive(false)
		end
		self.tabGroup:ChangeTab(3)
	end
end

function GodsWarTeamPanel:UpdateRed()
	self.tabGroup:ShowRed(2, GodsWarManager.Instance.requestRed)
end