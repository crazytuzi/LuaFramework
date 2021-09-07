-- -------------------------------
-- 场景活动单位存活情况
-- hosr
-- -------------------------------
UnitStatePanel = UnitStatePanel or BaseClass(BasePanel)

function UnitStatePanel:__init(model)
	self.model = model
	self.resList = {
		{file = AssetConfig.unitstate, type = AssetType.Main}
	}
	self.itemList = {}
	self.currIndex = 1
	self.count = 0

	self.bossTeam = {
		[71001] = 11,
		[71002] = 12,
		[71003] = 13,
		[71004] = 14,
		[71005] = 15,
		[71006] = 16,
		[71007] = 17,
	}

	self.listener = function() self:Update() end
	self.matchListener = function() self:UpdateMatch() end
end

function UnitStatePanel:__delete()
    UnitStateManager.Instance.OnDataUpdate:Remove(self.listener)
    EventMgr.Instance:RemoveListener(event_name.team_update_match, self.matchListener)
	for i,v in ipairs(self.itemList) do
		v:DeleteMe()
	end
	self.itemList = nil

	self:EndTime()
end

function UnitStatePanel:Close()
	self.model:CloseStatePanel()
end

function UnitStatePanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.unitstate))
    self.gameObject.name = "UnitStatePanel"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    local btn = self.transform:Find("Main/Refresh")
    btn:GetComponent(Button).onClick:AddListener(function() self:ClickRefresh() end)
    self.freshTxt = btn:Find("Text"):GetComponent(Text)
    self.fresh = btn.gameObject
    self.freshRect = btn:GetComponent(RectTransform)

    btn = self.transform:Find("Main/Match")
    btn:GetComponent(Button).onClick:AddListener(function() self:ClickMatch() end)
    self.matchTxt = btn:Find("Text"):GetComponent(Text)
    self.match = btn.gameObject

    self.tabSetting = {
        noCheckRepeat = true,
        notAutoSelect = true,
        perWidth = 108,
        perHeight = 42,
        spacing = 5,
    }
    self.tabList = {}
    self.tabcon = self.transform:Find("Main/TabScroll/TabButtonGroup")
    self.tabGroup = TabGroup.New(self.transform:Find("Main/TabScroll/TabButtonGroup").gameObject, function(index) self:ChangeTab(index) end, self.tabSetting)

	-- 临时活动的寻怪放在第五个，对应data_team第113条
	if DataTeam.data_match[113] then
		local str = DataTeam.data_match[113].type_name
		self.tabGroup.transform:GetChild(4):Find("Normal/Text"):GetComponent(Text).text = str
		self.tabGroup.transform:GetChild(4):Find("Select/Text"):GetComponent(Text).text = str
	end
	
    self.Container = self.transform:Find("Main/Scroll/Container")
    self.ScrollCon = self.transform:Find("Main/Scroll")
    self.rank_item_list = {}
    local len = self.Container.childCount
    for i = 1, len do
        local go = self.Container:GetChild(i - 1).gameObject
        local item = UnitStateItem.New(go, self)
        go:SetActive(false)
        table.insert(self.rank_item_list, item)
    end
    self.single_item_height = self.rank_item_list[1].transform:GetComponent(RectTransform).sizeDelta.y
    self.item_con_last_y = self.Container:GetComponent(RectTransform).anchoredPosition.y
    self.scroll_con_height = self.ScrollCon:GetComponent(RectTransform).sizeDelta.y

    self.setting = {
       item_list = self.rank_item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.Container  --item列表的父容器
       ,single_item_height = self.single_item_height --一条item的高度
       ,item_con_last_y = self.item_con_last_y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll_con_height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    self.vScroll = self.ScrollCon:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting) end)

    self:UpdateMatch()
    self:Update()

    UnitStateManager.Instance.OnDataUpdate:Add(self.listener)
    EventMgr.Instance:AddListener(event_name.team_update_match, self.matchListener)

 	self:ClickRefresh(true)
end

function UnitStatePanel:ClickRefresh(force)
    if force and BaseUtils.BASE_TIME - UnitStateManager.Instance.internalRefresh < 1.2 then
        return
    end
	if self.count > 0 then
		NoticeManager.Instance:FloatTipsByString(string.format(TI18N("%s秒后才能刷新"), self.count))
		return
	end

	if	RoleManager.Instance.RoleData.cross_type == 1  then
		local confirmData = NoticeConfirmData.New()
		confirmData.type = ConfirmData.Style.Normal
		confirmData.sureLabel = TI18N("返回原服")
		confirmData.cancelLabel = TI18N("取消")
		confirmData.sureCallback = SceneManager.Instance.quitCenter
		confirmData.content = string.format(TI18N("请<color='#ffff00'>返回原服</color>再前往参与"))
		NoticeManager.Instance:ConfirmTips(confirmData)
		return
	end

	-- if self.currIndex == 1 then
		ConstellationManager.Instance:Send15205()
	-- elseif self.currIndex == 2 then
		GuildManager.Instance:request11188()
	-- elseif self.currIndex == 3 then
		WorldBossManager.Instance:request13000()
	-- end
        NewLabourManager.Instance:Send17842()
		NewLabourManager.Instance:Send17899()
		NewLabourManager.Instance:Send20458()
    if force then
        UnitStateManager.Instance.internalRefresh = BaseUtils.BASE_TIME
    else
	   self:BeginTime()
    end
end

function UnitStatePanel:BeginTime()
	self:EndTime()
	self.count = 5
	self.timeid = LuaTimer.Add(0, 1000, function() self:LoopTime() end)
end

function UnitStatePanel:LoopTime()
	if self.count <= 0 then
		self.count = 0
		self:EndTime()
		self.freshTxt.text = TI18N("刷新")
		return
	end
	self.freshTxt.text = string.format(TI18N("%s秒"), self.count)
	self.count = self.count - 1
end

function UnitStatePanel:EndTime()
	if self.timeid ~= nil then
		LuaTimer.Delete(self.timeid)
		self.timeid = nil
	end
end

function UnitStatePanel:ClickMatch()
	if TeamManager.Instance:MyStatus() ~= RoleEumn.TeamStatus.Leader and TeamManager.Instance:MyStatus() ~= RoleEumn.TeamStatus.None then
		NoticeManager.Instance:FloatTipsByString(TI18N("勇士，你已在队伍中"))
		return
	end

	if	RoleManager.Instance.RoleData.cross_type == 1  then
		local confirmData = NoticeConfirmData.New()
		confirmData.type = ConfirmData.Style.Normal
		confirmData.sureLabel = TI18N("返回原服")
		confirmData.cancelLabel = TI18N("取消")
		confirmData.sureCallback = SceneManager.Instance.quitCenter
		confirmData.content = string.format(TI18N("请<color='#ffff00'>返回原服</color>再前往参与"))
		NoticeManager.Instance:ConfirmTips(confirmData)
		return
	end

    if self.currIndex == 1 then
    	TeamManager.Instance.TypeOptions = {}
	    TeamManager.Instance.TypeOptions[6] = 65
	    TeamManager.Instance.LevelOption = 1
	    TeamManager.Instance:AutoFind()
    elseif self.currIndex == 2 then
    	TeamManager.Instance.TypeOptions = {}
	    TeamManager.Instance.TypeOptions[1] = self:GetBossMatchId()
	    TeamManager.Instance.LevelOption = 1
	    TeamManager.Instance:AutoFind()
    elseif self.currIndex == 3 then
	elseif self.currIndex == 4 then
        TeamManager.Instance.TypeOptions = {}
        TeamManager.Instance.TypeOptions[6] = 113
        TeamManager.Instance.LevelOption = 1
        TeamManager.Instance:AutoFind()
    elseif self.currIndex == 6 then
        TeamManager.Instance.TypeOptions = {}
        TeamManager.Instance.TypeOptions[6] = 66
        TeamManager.Instance.LevelOption = 1
		TeamManager.Instance:AutoFind()
	elseif self.currIndex == 7 then
        TeamManager.Instance.TypeOptions = {}
        TeamManager.Instance.TypeOptions[6] = 67
        TeamManager.Instance.LevelOption = 1
        TeamManager.Instance:AutoFind()
	end
end

function UnitStatePanel:GetBossMatchId()
	local role_lev = RoleManager.Instance.RoleData.lev
	local list = UnitStateManager.Instance:GetBossList()
	table.sort(list, function(a,b) return a.id > b.id end)
	for i,v in ipairs(list) do
		local cfg_data = DataBoss.data_base[v.id]
		if role_lev >= cfg_data.lev then
			return self.bossTeam[v.id]
		end
	end
	return 11
end

function UnitStatePanel:Update()
	self.tabSetting.openLevel = {0, 0, 0, 0, 0, 0}
	local has1 = true
	local has2 = true
    local has3 = true
	local has4 = true
    local has5 = false
	local has6 = false
	local has7 = false
    local roleLev = RoleManager.Instance.RoleData.lev
	local canBoss = (DataAgenda.data_list[1007].engaged < 2) and roleLev >= 40
	local canStar = (DataAgenda.data_list[2013].engaged < 3) and roleLev >= 40
    local canFox = (DataAgenda.data_list[2051].engaged < 3) and roleLev >= 40
	local canStarTrial = RoleManager.Instance.world_lev >= 60 and roleLev >= 60
	local canMoonStar = RoleManager.Instance.world_lev >= 80 and roleLev >= 80

	local list = UnitStateManager.Instance:GetStarList()
	if #list == 0 then
		self.tabSetting.openLevel[1] = 999
		has1 = false
	end

	if not canStar then
		self.tabSetting.openLevel[1] = 999
		has1 = false
	end

	list = UnitStateManager.Instance:GetBossList()
	if #list == 0 then
		self.tabSetting.openLevel[2] = 999
		has2 = false
	else
		table.sort(list, function(a,b) return a.id < b.id end)
	end

	if not canBoss then
		self.tabSetting.openLevel[2] = 999
		has2 = false
	end

	list = UnitStateManager.Instance:GetRobberList()
	if #list == 0 then
        self.tabSetting.openLevel[3] = 999
        has3 = false
    end

    list = UnitStateManager.Instance:GetFoxList()
    if #list == 0 or not canFox then
		self.tabSetting.openLevel[4] = 999
        has4 = false
    end

    list = UnitStateManager.Instance:GetColdList()
    if #list ~= 0 then
        -- canFox = false
        has5 = true
    else
        self.tabSetting.openLevel[5] = 999
    end

    list = UnitStateManager.Instance:GetStarTrialList()
    if #list ~= 0 and canStarTrial then
        has6 = true
    else
        self.tabSetting.openLevel[6] = 999
    end

	list = UnitStateManager.Instance:GetMoonStarList()
    if #list ~= 0 and canMoonStar then
        has7 = true
    else
        self.tabSetting.openLevel[7] = 999
	end
	
	self.tabGroup:UpdateSetting(self.tabSetting)
 	self.tabGroup:Layout()

 	if has1 then
 		self.tabGroup:ChangeTab(1)
 	elseif has2 then
 		self.tabGroup:ChangeTab(2)
 	elseif has3 then
 		self.tabGroup:ChangeTab(3)
    elseif has4 then
        self.tabGroup:ChangeTab(4)
    elseif has5 then
        self.tabGroup:ChangeTab(5)
    elseif has6 then
		self.tabGroup:ChangeTab(6)
	elseif has7 then
        self.tabGroup:ChangeTab(7)
 	end

end

function UnitStatePanel:ChangeTab(index)
	local list = {}
	self.currIndex = index
	if index == 1 then
		list = UnitStateManager.Instance:GetStarList()
	elseif index == 2 then
		list = UnitStateManager.Instance:GetBossList()
	elseif index == 3 then
        list = UnitStateManager.Instance:GetRobberList()
    elseif index == 4 then
		list = UnitStateManager.Instance:GetFoxList()
	elseif index == 5 then
        list = UnitStateManager.Instance:GetColdList()
    elseif index == 6 then -- 星辰试炼
		list = UnitStateManager.Instance:GetStarTrialList()
	elseif index == 7 then -- 幻月灵兽
        list = UnitStateManager.Instance:GetMoonStarList()
    end
	self.setting.data_list = list
	BaseUtils.refresh_circular_list(self.setting)

	if index == 3 then
		self.match:SetActive(false)
		self.freshRect.anchoredPosition = Vector3(0, -129.9, 0)
	else
		self.match:SetActive(true)
		self.freshRect.anchoredPosition = Vector3(-101, -129.9, 0)
	end
end

function UnitStatePanel:UpdateMatch()
	if TeamManager.Instance:MyMatchStatus() == TeamEumn.MatchStatus.Recruiting then
		self.matchTxt.text = TI18N("招募中")
	elseif TeamManager.Instance:MyMatchStatus() == TeamEumn.MatchStatus.Matching then
		self.matchTxt.text = TI18N("匹配中")
	else
		if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
			self.matchTxt.text = TI18N("开始招募")
		else
			self.matchTxt.text = TI18N("自动匹配")
		end
	end
end