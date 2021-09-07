-- -------------------------------------------------
-- 诸神之战 分组列表
-- hosr
-- -------------------------------------------------
GodsWarFightListPanel = GodsWarFightListPanel or BaseClass(BasePanel)

function GodsWarFightListPanel:__init(parent)
	self.parent = parent
	self.resList = {
		{file = AssetConfig.godswarfightlist, type = AssetType.Main},
		{file = AssetConfig.godswarres, type = AssetType.Dep},
	}

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.itemList = {}
    self.currIndex = 0
    self.zone = 1

    self.listener = function() self:Update(true) end
    self.selectListener = function(index) self:ChangeZone(index) self:Update() end
    self.helpNormal = {
    	TI18N("1.出战成员需组成<color='#ffff00'>4人以上</color>队伍，否则当做弃权"),
    	TI18N("2.每场比赛最大限时<color='#ffff00'>1小时</color>，超过则根据<color='#ffff00'>存活情况</color>判断"),
    	TI18N("3.若出现<color='#ffff00'>轮空</color>，则己方<color='#ffff00'>自动获胜</color>"),
    	TI18N("4.当场如果出现<color='#ffff00'>双方弃权</color>，队伍<color='#ffff00'>战力高方获胜</color>"),
        TI18N("5.小组赛结束时积分<color='#ffff00'>前2名</color>可晋级淘汰赛，若小组内出现同分，则按战力排序"),
	}
end

function GodsWarFightListPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.godswar_match_update, self.listener)
    EventMgr.Instance:RemoveListener(event_name.godswar_select_update, self.selectListener)
	if self.tabGroup ~= nil then
		self.tabGroup:DeleteMe()
		self.tabGroup = nil
	end

	for i,v in ipairs(self.itemList) do
		v:DeleteMe()
	end
	self.itemList = nil
end

function GodsWarFightListPanel:OnShow()
    local roleData = RoleManager.Instance.RoleData
    local myData = GodsWarManager.Instance.myData
    if myData == nil or myData.tid == 0 then
        self:ChangeZone(GodsWarEumn.Group(roleData.lev, roleData.lev_break_times))
    else
        self:ChangeZone(myData.lev)
    end
    self:UpdateMyGroup()
	if self.currIndex == 0 then
		self.tabGroup:ChangeTab(1)
	else
		self.tabGroup:ChangeTab(self.currIndex)
	end

    EventMgr.Instance:RemoveListener(event_name.godswar_match_update, self.listener)
    EventMgr.Instance:RemoveListener(event_name.godswar_select_update, self.selectListener)
    EventMgr.Instance:AddListener(event_name.godswar_match_update, self.listener)
    EventMgr.Instance:AddListener(event_name.godswar_select_update, self.selectListener)
end

function GodsWarFightListPanel:OnHide()
end

function GodsWarFightListPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarfightlist))
    self.gameObject.name = "GodsWarFightListPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.rect.anchoredPosition = Vector2(0, -25)

    self.main = self.transform:Find("Main").gameObject
    self.nothing = self.transform:Find("Nothing").gameObject

    self.title = self.transform:Find("Main/Title/Text"):GetComponent(Text)
    self.tips = self.transform:Find("Main/Tips"):GetComponent(Text)
    self.tips.text = TI18N("所有小组<color='#00ff00'>随机</color>分为<color='#00ff00'>4</color>区\n小组<color='#00ff00'>前2名</color>晋级淘汰赛")

    self.helpBtn = self.transform:Find("Main/Help").gameObject
    self.helpBtn:GetComponent(Button).onClick:AddListener(function() self:ClickHelp() end)

    self.group = self.transform:Find("Main/Group"):GetComponent(Text)

    self.transform:Find("Main/Button"):GetComponent(Button).onClick:AddListener(function() GodsWarManager.Instance.model:OpenSelect() end)
    self.buttonTxt = self.transform:Find("Main/Button/Text"):GetComponent(Text)

    local tabGroupSetting = {
        notAutoSelect = true,
        noCheckRepeat = false,
    }
    self.tabGroup = TabGroup.New(self.transform:Find("Main/TabButtonGroup"), function(index) self:ChangeTab(index) end, tabGroupSetting)

    self.scroll = self.transform:Find("Main/Right/Scroll").gameObject
    local container = self.transform:Find("Main/Right/Scroll/Container")
    local len = container.childCount
    for i = 1, len do
    	local item = GodsWarFightListItem.New(container:GetChild(i - 1).gameObject, self, i)
    	table.insert(self.itemList, item)
    end

    self:OnShow()
end

function GodsWarFightListPanel:ChangeTab(index)
	self.currIndex = index
	self:Update()
end

function GodsWarFightListPanel:Update(isProto)
	local round = GodsWarEumn.Round(GodsWarManager.Instance.status)
	self.title.text = string.format(TI18N("小组赛第%s轮"), round)

    local dataList = {}
    if not isProto and GodsWarEumn.IsFighting() then
        GodsWarManager.Instance:Send17917(self.zone, self.currIndex)
    else
        dataList = GodsWarManager.Instance:GetMatchData(self.zone, self.currIndex)
    end

	local list = {{}, {}, {}, {}, {}, {}, {}, {}}
	if dataList ~= nil and #dataList ~= 0 then
		for i,v in ipairs(dataList) do
			local index = ((v.team_group_256 - 1) % 32) - (self.currIndex - 1) * 8 + 1
			table.insert(list[index], v)
		end
		self.nothing:SetActive(false)
		self.scroll:SetActive(true)
	else
		self.nothing:SetActive(true)
		self.scroll:SetActive(false)
	end

	for i,item in ipairs(self.itemList) do
		item:SetData(list[i])
	end
end

function GodsWarFightListPanel:ChangeZone(zone)
	self.zone = zone
	self.buttonTxt.text = GodsWarEumn.GroupName(self.zone)
end

function GodsWarFightListPanel:ClickHelp()
	TipsManager.Instance:ShowText({gameObject = self.helpBtn, itemData = self.helpNormal})
end

function GodsWarFightListPanel:UpdateMyGroup()
    local myData = GodsWarManager.Instance.myData
    if myData == nil or myData.tid == 0 then
        self.group.text = ""
    else
        if myData.team_group_256 ~= 0 then
            -- local group = GodsWarEumn.Group(myData.lev, myData.break_times)
            local group = myData.lev
            local zone = 1
            local index = 1
            local val = myData.team_group_256 % 32
            if val == 0 then
                zone = 4
                index = 8
            else
                zone = math.ceil((myData.team_group_256 % 32) / 8)
                index = ((myData.team_group_256 - 1) % 32) + 1 - (zone - 1) * 8
            end
            self.group.text = string.format(TI18N("所属分组:%s<color='#ffff00'>%s</color>第<color='#ffff00'>%s</color>小组"), GodsWarEumn.GroupNameSample(group), GodsWarEumn.ZoneName[zone], index)
            self.currIndex = zone
            self.zone = group
            self.buttonTxt.text = GodsWarEumn.GroupName(self.zone)
        else
            self.group.text = ""
        end
    end
end