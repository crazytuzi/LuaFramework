--作者:hzf
--11/01/2016 11:00:50
--功能:公会联赛直播

GuildLeagueLiveWindow = GuildLeagueLiveWindow or BaseClass(BaseWindow)
function GuildLeagueLiveWindow:__init(parent)
	self.parent = parent
    self.Mgr = GuildLeagueManager.Instance
	self.resList = {
		{file = AssetConfig.guildleaguelivewindow, type = AssetType.Main}
        ,{file = AssetConfig.guildleaguebig, type = AssetType.Dep}
        ,{file = AssetConfig.guild_totem_icon, type = AssetType.Dep}
        ,{file = AssetConfig.guildleague_texture, type = AssetType.Dep}
        ,{file = AssetConfig.dropicon, type = AssetType.Dep}
	}
	self.OnOpenEvent:Add(function() self:OnOpen() end)
	self.OnHideEvent:Add(function() self:OnHide() end)
    self.cacheMode = CacheMode.Destroy
    self.winLinkType = WinLinkType.Single
	self.isopen = false
    self.curr_matchid = 0
    self.index = 1
    self.cachdata = {}
    self.lastcheck = Time.time
    self.timer = nil
    self.refreshtimer = nil
    self.phaseType = {
        [4] = TI18N("冠军联赛8强赛"),
        [5] = TI18N("冠军联赛4强赛"),
        [6] = TI18N("冠军联赛半决赛"),
        [7] = TI18N("冠军联赛决赛"),
        [8] = TI18N("冠军联赛决赛"),
    }
    self.updatelivedate = function()
        self:UpdateCurrLiveData()
    end
    self.beginFcallback = function()
        self.model:CloseLivePanel()
    end
end

function GuildLeagueLiveWindow:__delete()
    EventMgr.Instance:RemoveListener(event_name.begin_fight, self.beginFcallback)
    if self.timer ~= nil then
        LuaTimer.Delete(self.timer)
        self.timer = nil
    end
    if self.refreshtimer ~= nil then
        LuaTimer.Delete(self.refreshtimer)
        self.refreshtimer = nil
    end
    self.bh = nil
    self.rh = nil
    self.b = nil
    self.r = nil
    self.broken = nil
    self.Mgr.liveDataRefresh:RemoveListener(self.updatelivedate)
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function GuildLeagueLiveWindow:OnHide()
    self.isopen = false
end

function GuildLeagueLiveWindow:OnOpen()
    self.isopen = true
end

function GuildLeagueLiveWindow:InitPanel()
    EventMgr.Instance:AddListener(event_name.begin_fight, self.beginFcallback)
    self.isopen = true
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildleaguelivewindow))
	self.gameObject.name = "GuildLeagueLiveWindow"
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

	self.transform = self.gameObject.transform
	self.Panel = self.transform:Find("Panel")
	self.Main = self.transform:Find("Main")
	self.Title = self.transform:Find("Main/Title")
	self.Text = self.transform:Find("Main/Title/Text"):GetComponent(Text)
	self.CloseButton = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.CloseButton.onClick:AddListener(function()
        self.model:CloseLivePanel()
    end)
	self.TabMaskScroll = self.transform:Find("Main/TabMaskScroll")
    self.moreArrow = self.TabMaskScroll:Find("moreArrow").gameObject
	self.TabButton = self.transform:Find("Main/TabMaskScroll/Button"):GetComponent(Button)
    self.bh = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture , "bh")
    self.rh = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture , "rh")
    self.b = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture , "b")
    self.r = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture , "r")
    self.broken = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture , "broken")

	self.TabButtonGroup = self.transform:Find("Main/TabMaskScroll/TabButtonGroup")
	self.Con = self.transform:Find("Main/Con")
	self.transform:Find("Main/Con/TitleBar"):GetComponent(Image).sprite = self.assetWrapper:GetTextures(AssetConfig.guildleaguebig , "GuildLeague1")
	self.VS = self.transform:Find("Main/Con/TitleBar/VS")
	self.Time = self.transform:Find("Main/Con/TitleBar/Timebg/Time")
	self.Tower1 = self.transform:Find("Main/Con/TitleBar/Tower1")
    self.Tower2 = self.transform:Find("Main/Con/TitleBar/Tower2")
	self.winTick = self.transform:Find("Main/Con/TitleBar/winTick")
	self.MaskScroll = self.transform:Find("Main/Con/MaskScroll")

    self.NewMsgButton = self.transform:Find("Main/Con/NewMsgButton"):GetComponent(Button)
    self.NewMsgButton.onClick:AddListener(function()
        self:CheckCachData(true)
    end)
    self.NewMsgText = self.transform:Find("Main/Con/NewMsgButton/Text"):GetComponent(Text)
	self.List = self.transform:Find("Main/Con/MaskScroll/List")
	self.GuessButton = self.transform:Find("Main/Button"):GetComponent(Button)
    self.GuessButton.onClick:AddListener(function()
        GuildLeagueManager.Instance.model:OpenGuessWindow()
    end)
    self.NewMsgButton.gameObject:SetActive(false)
	self.tablayout = LuaBoxLayout.New(self.TabButtonGroup, {axis = BoxLayoutAxis.Y, cspacing = 0})
    self.NoImg = self.transform:Find("Main/Con/NoIMG").gameObject
	self.item_list = {}
	local num = self.List.childCount
    for i=1,num do
        local go = self.List:GetChild(i-1).gameObject
        go.transform.sizeDelta = Vector2(510, 77)
        local item = GuildLeagueLiveItem.New(go, self)
        table.insert(self.item_list, item)
    end
    self.setting_data = {
       item_list = self.item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.List  --item列表的父容器
       ,single_item_height = self.item_list[1].transform:GetComponent(RectTransform).sizeDelta.y --一条item的高度
       ,item_con_last_y = self.List:GetComponent(RectTransform).anchoredPosition.y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.MaskScroll:GetComponent(RectTransform).sizeDelta.y--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }
    self.vScroll = self.MaskScroll:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)
    self.vScroll.onValueChanged:AddListener(function()
        self:CheckCachData()
    end)
    BaseUtils.refresh_circular_list(self.setting_data)
    -- self:UpdateLiveData()
    self:InitTab()
    self.Mgr.liveDataRefresh:AddListener(self.updatelivedate)
end

function GuildLeagueLiveWindow:InitTab(data)
	BaseUtils.DestroyChildObj(self.TabButtonGroup)
    local data = self.Mgr.liveList
    table.sort(data, function(a, b)
        return a.type < b.type or a.time > b.time
    end)
	for i,v in ipairs(data) do
		local tabitem = GameObject.Instantiate(self.TabButton.gameObject)
        tabitem.transform:Find("Normal/Text"):GetComponent(Text).text = string.format("<color='#225ee7'>%s</color>\n<color='#c23934'>%s</color>", v.names1[1].name1, v.names2[1].name2)
        tabitem.transform:Find("Select/Text"):GetComponent(Text).text = string.format("<color='#225ee7'>%s</color>\n<color='#c23934'>%s</color>", v.names1[1].name1, v.names2[1].name2)
        tabitem.transform:Find("NotifyPoint").gameObject:SetActive(self.Mgr.guild_LeagueInfo.cur_phase ~= nil and self.Mgr.guild_LeagueInfo.cur_phase == v.phase and self.Mgr.currstatus == 2)
		self.tablayout:AddCell(tabitem)
	end
    if self.tabgroup == nil then
        self.tabgroup = TabGroup.New(self.TabButtonGroup.gameObject, function (tab) self:OnTabChange(tab) end)
    else
        self.tabgroup:Init()
    end
    self.moreArrow:SetActive(#data>6)
end

function GuildLeagueLiveWindow:UpdateLiveData(data)
    if self.gameObject == nil then
        return
    end
    -- self.index = self.index + 1
    -- LuaTimer.Add(Random.Range(500, 4000), function()
    --     self:UpdateLiveData()
    -- end)
    if self.List:GetComponent(RectTransform).anchoredPosition.y > 70 then
        table.insert(self.cachdata, data)
        self.NewMsgButton.gameObject:SetActive(true)
        self.NewMsgText.text = string.format(TI18N("有<color='#00ff00'>%s</color>条新的战报"), tostring(#self.cachdata))
        return
    end
    table.insert(self.setting_data.data_list, data)
    table.sort(self.setting_data.data_list, function(a, b)
        return a.log_time > b.log_time
    end)
    -- BaseUtils.static_refresh_circular_list(self.setting_data)
    BaseUtils.refresh_circular_list(self.setting_data)
end

function GuildLeagueLiveWindow:CheckCachData(force)
    if not force and (Time.time - self.lastcheck < 0.3 or self.List:GetComponent(RectTransform).anchoredPosition.y > 70) then
        return
    end
    self.NewMsgButton.gameObject:SetActive(false)
    self.lastcheck = Time.time
    if #self.cachdata > 0 then
        for k,v in pairs(self.cachdata) do
            table.insert(self.setting_data.data_list, v)
        end
    else
        return
    end
    self.cachdata = {}
    table.sort(self.setting_data.data_list, function(a, b)
        if a.time == nil or b.time == nil then
            return false
        end
        return a.time > b.time
    end)
    BaseUtils.refresh_circular_list(self.setting_data)
end

function GuildLeagueLiveWindow:OnTabChange(tab)
    self.index = tab
    -- self.curr_matchid = self.Mgr.liveList[tab].id
    self.setting_data.data_list = {}
    self.Mgr:Require17628(self.Mgr.liveList[tab].id)
end

function GuildLeagueLiveWindow:UpdateCurrLiveData()
    local data = self.Mgr.currLiveData.logs
    if #data > 0 and self.curr_matchid == self.Mgr.currLiveData.guild_league_alliance[1].match_id then
        self:InsertNewData(data)
    else
        self.curr_matchid = self.Mgr.currLiveData.guild_league_alliance[1].match_id
        self.setting_data.data_list = data
        BaseUtils.refresh_circular_list(self.setting_data)
    end
    self.NoImg:SetActive(#self.setting_data.data_list <= 0)
    self:SetTitleBar()
end

function GuildLeagueLiveWindow:InsertNewData(data)
    local newtemp = {}
    for i, v in ipairs(data) do
        local new = true
        for ii, vv in ipairs(self.setting_data.data_list) do
            if v.log_id == vv.log_id then
                new = false
                self.setting_data.data_list[ii] = v
            end
        end
        for ii, vv in ipairs(self.cachdata) do
            if v.log_id == vv.log_id then
                new = false
                self.cachdata[ii] = v
            end
        end
        if new then
            table.insert(newtemp, v)
        end
    end
    if #newtemp > 0 then
        for i,v in ipairs(newtemp) do
            self:UpdateLiveData(v)
        end
    else
        if self.List:GetComponent(RectTransform).anchoredPosition.y <= 70 then
            BaseUtils.refresh_circular_list(self.setting_data)
        end
    end
end

function GuildLeagueLiveWindow:SetTitleBar()
    local guilds = self.Mgr.currLiveData.guild_league_alliance
    BaseUtils.dump(guilds, "aaaa")
    local isend = false
    for k,v in pairs(guilds) do

        if v.is_win == 1 then
            isend = true
            self.winTick.anchoredPosition = Vector2(64*(math.pow(-1,v.side)), -5)
            self.winTick.gameObject:SetActive(true)
        elseif v.is_win == 0 then
            self.winTick.gameObject:SetActive(false)
        end
        self.transform:Find("Main/Con/TitleBar/icon"..v.side):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guild_totem_icon , tostring(v.totems[1].totem))
        self.transform:Find("Main/Con/TitleBar/Name"..v.side):GetComponent(Text).text = v.names[1].name
        if self.phaseType[v.phase] ~= nil then
            self.transform:Find("Main/Con/TitleBar/Text"):GetComponent(Text).text = self.phaseType[v.phase]
            if self.Mgr.currLiveData.type == 2 then
                self.transform:Find("Main/Con/TitleBar/Text"):GetComponent(Text).text = TI18N("冠军联赛季军赛")
            end
        else
            self.transform:Find("Main/Con/TitleBar/Text"):GetComponent(Text).text = TI18N("冠军联赛")
        end
    end
    if #self.Mgr.currLiveData.guild_league_unit > 0 then
        self.transform:Find("Main/Con/TitleBar/Timebg/Time"):GetComponent(Text).text = BaseUtils.formate_time_gap(self.Mgr.model.activity_time - Time.time,":",0,BaseUtils.time_formate.MIN)
        for i,v in ipairs(self.Mgr.currLiveData.guild_league_unit) do
            local half = v.side == 1 and self.bh or self.rh
            local full = v.side == 1 and self.b or self.r
            if v.duration > 0 and v.duration/DataGuildLeague.data_tower_info[v.unit_id].duration < 0.5 then
                self.transform:Find(string.format("Main/Con/TitleBar/Tower%s/%s", v.side, tostring((v.unit_id-1)%3+1))):GetComponent(Image).sprite = half
            elseif v.duration <= 0 then
                self.transform:Find(string.format("Main/Con/TitleBar/Tower%s/%s", v.side, tostring((v.unit_id-1)%3+1))):GetComponent(Image).sprite = self.broken
            else
                self.transform:Find(string.format("Main/Con/TitleBar/Tower%s/%s", v.side, tostring((v.unit_id-1)%3+1))):GetComponent(Image).sprite = full
            end
        end
    else
        if isend then
            self.transform:Find("Main/Con/TitleBar/Timebg/Time"):GetComponent(Text).text = TI18N("已结束")
        else
            self.transform:Find("Main/Con/TitleBar/Timebg/Time"):GetComponent(Text).text = TI18N("未开始")
        end
        self.Tower1.gameObject:SetActive(false)
        self.Tower2.gameObject:SetActive(false)
    end
    self:StartRefreshTimer()
    self:StartCountDown(isend)
end

function GuildLeagueLiveWindow:StartCountDown(isend)
    if self.Mgr.currstatus ~= 2 then
        if self.timer ~= nil then
            LuaTimer.Delete(self.timer)
            self.timer = nil
        end
        self.transform:Find("Main/Con/TitleBar/Timebg/Time"):GetComponent(Text).text = TI18N("未开始")
    elseif isend then
        if self.timer ~= nil then
            LuaTimer.Delete(self.timer)
            self.timer = nil
        end
        self.transform:Find("Main/Con/TitleBar/Timebg/Time"):GetComponent(Text).text = TI18N("已结束")
    else
        if self.timer == nil then
            self.timer = LuaTimer.Add(0, 800, function()
                self.transform:Find("Main/Con/TitleBar/Timebg/Time"):GetComponent(Text).text = BaseUtils.formate_time_gap(self.Mgr.model.activity_time - Time.time,":",0,BaseUtils.time_formate.MIN)
            end)
        end
    end
end

function GuildLeagueLiveWindow:StartRefreshTimer()
    if self.refreshtimer == nil then
        self.refreshtimer = LuaTimer.Add(5000, 7000, function()
            if self.Mgr.liveList[self.index] ~= nil then
                self.Mgr:Require17628(self.Mgr.liveList[self.index].id)
            end
        end)
    end
end