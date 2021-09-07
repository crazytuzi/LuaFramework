-- ---------------------------
-- 诸神之战 淘汰赛分组界面
-- hosr
-- ---------------------------
GodsWarFightElimintionPanel = GodsWarFightElimintionPanel or BaseClass(BasePanel)

function GodsWarFightElimintionPanel:__init(parent)
    self.parent = parent
    self.effectPath = "prefabs/effect/20194.unity3d"
	self.resList = {
		{file = AssetConfig.godswarelimination, type = AssetType.Main},
		{file = AssetConfig.godswarres, type = AssetType.Dep},
        {file = AssetConfig.bible_daily_gfit_bg2, type = AssetType.Dep},
        {file = AssetConfig.godswarresultbg, type = AssetType.Main},
        {file = self.effectPath, type = AssetType.Main},
	}
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.currIndex = 0
    self.zone = 1

    self.listener = function() self:Update(true) end
    self.selectListener = function(index) self:ChangeZone(index) end

    self.lineList = {}
    self.itemList = {}
    self.indexDataList = {}
    self.finalData = nil

    self.helpNormal = {
        TI18N("1.出战成员需组成<color='#ffff00'>4人以上</color>队伍，否则当做弃权"),
        TI18N("2.每场比赛最大限时<color='#ffff00'>1小时</color>，超过则根据<color='#ffff00'>存活情况</color>判断"),
        TI18N("3.若出现<color='#ffff00'>轮空</color>，则己方<color='#ffff00'>自动获胜</color>"),
        TI18N("4.当场如果出现<color='#ffff00'>双方弃权</color>，队伍<color='#ffff00'>战力高方获胜</color>"),
        TI18N("5.小组赛结束时积分<color='#ffff00'>前2名</color>可晋级淘汰赛，若小组内出现同分，则按战力排序"),
    }
end

function GodsWarFightElimintionPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.godswar_match_update, self.listener)
	EventMgr.Instance:RemoveListener(event_name.godswar_select_update, self.selectListener)
end

function GodsWarFightElimintionPanel:OnShow()
    self.finalData = nil
    self:UpdateMyGroup()
	if self.currIndex == 0 then
		self.tabGroup:ChangeTab(1)
	else
		self.tabGroup:ChangeTab(self.currIndex)
	end
end

function GodsWarFightElimintionPanel:OnHide()
end

function GodsWarFightElimintionPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarelimination))
    self.gameObject.name = "GodsWarFightElimintionPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.rect.anchoredPosition = Vector2(0, -25)

    self.title = self.transform:Find("Main/Title/Text"):GetComponent(Text)

    local tabGroupSetting = {
        notAutoSelect = true,
        noCheckRepeat = true,
    }
    self.tabGroup = TabGroup.New(self.transform:Find("Main/Scroll/TabButtonGroup"), function(index) self:ChangeTab(index) end, tabGroupSetting)

    for i,v in ipairs(self.tabGroup.buttonTab) do
    	v.normalTxt.text = GodsWarEumn.EliminationName[i]
        v.selectTxt.text = GodsWarEumn.EliminationName[i]
    end

    self.helpBtn = self.transform:Find("Main/Help").gameObject
    self.helpBtn:GetComponent(Button).onClick:AddListener(function() self:ClickHelp() end)

    self.transform:Find("Main/Button"):GetComponent(Button).onClick:AddListener(function() GodsWarManager.Instance.model:OpenSelect() end)
    self.buttonTxt = self.transform:Find("Main/Button/Text"):GetComponent(Text)

    self.transform:Find("Main/Right/Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.bible_daily_gfit_bg2, "DailyGiftBigBg")
    self.transform:Find("Main/Right/BigIcon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.godswarresultbg, "GodsWarResultBg")

    self.watchBtn = self.transform:Find("Main/Right/WatchBtn").gameObject
    self.watchBtn:GetComponent(Button).onClick:AddListener(function() self:ClickWatch() end)
    self.videoBtn = self.transform:Find("Main/Right/VideoButton").gameObject
    self.videoBtn:GetComponent(Button).onClick:AddListener(function() self:ClickVideo() end)

    self.transform:Find("Main/Right/Final"):GetComponent(Button).onClick:AddListener(function() self:ClickFinal() end)
    self.finalName = self.transform:Find("Main/Right/Final/Name"):GetComponent(Text)
    self.finalName.text = TI18N("虚位以待")

    local right = self.transform:Find("Main/Right")
    for i = 1, 8 do
        local effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
        local item = GodsWarFightElimintionItem.New(right:Find("Team" .. i).gameObject, self, effect)
        table.insert(self.itemList, item)
    end

    local line = self.transform:Find("Main/Right/Light")
    for i = 1 , 8 do
        local team = line:Find("Team" .. i)
        local tab = {}
        table.insert(tab, team:Find("1").gameObject)
        table.insert(tab, team:Find("2").gameObject)
        table.insert(self.lineList, tab)
    end

	EventMgr.Instance:AddListener(event_name.godswar_select_update, self.selectListener)
    EventMgr.Instance:AddListener(event_name.godswar_match_update, self.listener)

    self:OnShow()
end

function GodsWarFightElimintionPanel:ChangeTab(index)
	self.currIndex = index
	self:Update()
end

function GodsWarFightElimintionPanel:ChangeZone(zone)
	self.zone = zone
	self.buttonTxt.text = GodsWarEumn.GroupName(self.zone)
	self:Update()
end

function GodsWarFightElimintionPanel:Update(isProto)
    local round = GodsWarEumn.Round(GodsWarManager.Instance.status)
    self.title.text = string.format(TI18N("淘汰赛第%s轮"), round)

    local dataList = {}
    if not isProto and GodsWarEumn.IsFighting() then
        GodsWarManager.Instance:Send17925(self.zone)
    else
        dataList = GodsWarManager.Instance:GetElimintionData(self.zone) or {}
    end
    self.indexDataList = {}
    self.indexDataList = self:GetCurrentIndexData(dataList)
    for i,v in ipairs(self.itemList) do
        if type(self.indexDataList[i]) == "number" then
            v:SetData(nil)
        else
            v:SetData(self.indexDataList[i])
        end
    end
    self:UpdateProgress()
end

-- 拿到到当前分区的数据
function GodsWarFightElimintionPanel:GetCurrentIndexData(list)
    local posList = GodsWarEumn.PosDataIndex(self.currIndex)
    local newlist = {}
    for i,v in ipairs(posList) do
        if list[v] == nil then
            table.insert(newlist, 0)
        else
            table.insert(newlist, list[v])
        end
    end
    return newlist
end

function GodsWarFightElimintionPanel:UpdateProgress()
    self.finalName.text = TI18N("虚位以待")
    local list1 = {}
    local list2 = {}
    for i,v in ipairs(self.itemList) do
        v:PlayEffect(false)
        if v.data == nil then
            self.lineList[i][1]:SetActive(false)
            self.lineList[i][2]:SetActive(false)
        else
            if v.data.qualification >= GodsWarEumn.Quality.Q32 then
                self.lineList[i][1]:SetActive(true)
                table.insert(list1, v)
            else
                self.lineList[i][1]:SetActive(false)
            end

            if v.data.qualification >= GodsWarEumn.Quality.Q16 then
                self.lineList[i][2]:SetActive(true)
                table.insert(list2, v)
            else
                self.lineList[i][2]:SetActive(false)
            end

            if v.data.qualification == GodsWarEumn.Quality.Q8 then
                self.finalName.text = v.data.name
                self.finalData = v.data
            end
        end
    end

    if #list2 == 0 then
        for i,v in ipairs(list1) do
            v:PlayEffect(true)
        end
    else
        for i,v in ipairs(list2) do
            v:PlayEffect(true)
        end
    end
end

function GodsWarFightElimintionPanel:ClickFinal()
    if self.finalData ~= nil then
        GodsWarManager.Instance.model:OpenTeam(self.finalData)
    end
end

function GodsWarFightElimintionPanel:ClickHelp()
    TipsManager.Instance:ShowText({gameObject = self.helpBtn, itemData = self.helpNormal})
end

function GodsWarFightElimintionPanel:ClickWatch()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godswar_video, {type = 2, group = self.zone})
end

function GodsWarFightElimintionPanel:ClickVideo()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godswar_video, {type = 1, group = self.zone})
end

function GodsWarFightElimintionPanel:UpdateMyGroup()
    local my = GodsWarManager.Instance.myData
    if my ~= nil and my.tid ~= 0 then
        if my.qualification >= GodsWarEumn.Quality.Q64 then
            for i,list in ipairs(GodsWarEumn.PositionIndex) do
                for j,team_group_64 in ipairs(list) do
                    if team_group_64 == my.team_group_64 then
                        self.currIndex = i
                        break
                    end
                end
            end
        end
        -- self.zone = GodsWarEumn.Group(my.lev, my.break_times)
        self.zone = my.lev
    else
        self.zone = GodsWarEumn.Group(RoleManager.Instance.world_lev, RoleManager.Instance.RoleData.lev_break_times)
    end
    self.zone = math.max(1, self.zone)
    self.buttonTxt.text = GodsWarEumn.GroupName(self.zone)
end