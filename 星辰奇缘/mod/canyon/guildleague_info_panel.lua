-- 公会联赛信息面板
GuildLeagueInfoPanel = GuildLeagueInfoPanel or BaseClass(BasePanel)

function GuildLeagueInfoPanel:__init(parent, Main)
    self.model = model
    self.Mgr = GuildLeagueManager.Instance
    self.parent = parent
    self.Main = Main
    self.name = "GuildLeagueInfoPanel"
    self.Titletimer = nil
    self.btnEffect = "prefabs/effect/20053.unity3d"
    self.resList = {
        {file = AssetConfig.guildleague_info_panel, type = AssetType.Main},
        {file = self.btnEffect, type = AssetType.Main},
        {file = AssetConfig.guildleague_texture, type = AssetType.Dep},
        {file = AssetConfig.guildleague_levicon, type = AssetType.Dep},
        {file = AssetConfig.guild_totem_icon, type = AssetType.Dep},
        {file = AssetConfig.blue_light, type = AssetType.Dep},
        {file = AssetConfig.guildsiege, type = AssetType.Dep},
        -- {file = AssetConfig.guildleaguebig, type = AssetType.Dep},

    }
    self.Updatefunc = function()
        self:SetInfo()
        self:InitList()
    end
    self.statuschangefunc = function()
        self:OnStatusChange()
    end

    self.checkRedListener = function() self:CheckRed() end
    self.openTime = Time.time
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GuildLeagueInfoPanel:OnOpen()
    GuildLeagueManager.Instance.LeagueFightScheduleUpdate:AddListener(self.checkRedListener)
    if Time.time - self.openTime >= 10 then
        self.openTime = Time.time
        self.Mgr:Require17619()
    end
    if self.gameObject ~= nil then
        self.gameObject:SetActive(true)
    end
    self:CheckRed()

    if GuildSiegeManager.Instance:IsMyGuildIn() then
        self:SetSiege(1)
    else
        self:SetSiege(0)
    end
end

function GuildLeagueInfoPanel:OnHide()
    GuildLeagueManager.Instance.LeagueFightScheduleUpdate:RemoveListener(self.checkRedListener)
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
end

function GuildLeagueInfoPanel:__delete()
    self.transform:Find("Mid/Light"):GetComponent(Image).sprite = nil
    self.Mgr.LeagueSummaryUpdate:RemoveListener(self.Updatefunc)
    self.Mgr.LeagueStatusChange:RemoveListener(self.statuschangefunc)
    if self.preview ~= nil then
        self.preview:DeleteMe()
    end
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function GuildLeagueInfoPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildleague_info_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)
    self.transform = t
    -- xpcall(function() self.transform:Find("bgImage"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.bible_daily_gfit_bg2, "DailyGiftBigBg") end,
    --         function()  self.transform:Find("bgImage").gameObject:SetActive(false) end )
    -- self.transform:Find("bgImage"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.bible_daily_gfit_bg2, "DailyGiftBigBg")
    self.Left = self.transform:Find("Left")
    self.Icon = self.transform:Find("Left/Icon"):GetComponent(Image)
    self.Name = self.transform:Find("Left/Name"):GetComponent(Text)
    self.SvrName = self.transform:Find("Left/SvrName"):GetComponent(Text)
    self.Info1 = self.transform:Find("Left/Info1"):GetComponent(Text)
    self.Info2 = self.transform:Find("Left/Info2"):GetComponent(Text)
    self.Info3 = self.transform:Find("Left/Info3"):GetComponent(Text)
    self.Info4 = self.transform:Find("Left/Info4"):GetComponent(Text)
    self.Info5 = self.transform:Find("Left/Info5"):GetComponent(Text)
    self.Info6 = self.transform:Find("Left/Info6"):GetComponent(Text)
    xpcall(function() self.transform:Find("Mid/Light"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.blue_light, "blue_light") end,
            function()  self.transform:Find("Mid/Light").gameObject:SetActive(false) end )
    -- self.transform:Find("Mid/Light"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.blue_light, "blue_light")
    self.transform:Find("Right/Title/Text"):GetComponent(Text).text = TI18N("本公会近期对阵")

    self.InfoButton = self.transform:Find("Mid/InfoButton"):GetComponent(Button)
    self.InfoButton.onClick:AddListener(function()
        local currentNpcData = DataUnit.data_unit[20004]
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[20004])
        extra.base.buttons = {}
        extra.base.plot_talk = TI18N("1、<color='#ffff00'>冠军联赛</color>将在世界等级<color='#ffff00'>80</color>级时开启，每<color='#ffff00'>2</color>个月作为一个赛季，每周安排<color='#ffff00'>2</color>次跨服比赛\n2、联赛划分为<color='#ffff00'>超级、甲级、乙级和丙级4个级别</color>，赛季结算时将按积分排名进行<color='#ffff00'>升降级</color>")
        MainUIManager.Instance.dialogModel:Open(currentNpcData, extra, true)
    end)
    self.MidIcon = self.transform:Find("Mid/icon"):GetComponent(Image)
    self.SeasonText = self.transform:Find("Mid/SeasonText"):GetComponent(Text)
    self.ScoreText = self.transform:Find("Mid/ScoreText"):GetComponent(Text)
    self.RankText = self.transform:Find("Mid/RankText"):GetComponent(Text)
    self.GOButton = self.transform:Find("Mid/GOButton"):GetComponent(Button)
    self.MgrButton = self.transform:Find("Mid/MgrButton"):GetComponent(Button)
    self.mgrNotify = self.transform:Find("Mid/MgrButton/NotifyPoint").gameObject

    self.StartEffect = GameObject.Instantiate(self:GetPrefab(self.btnEffect))
    self.StartEffect.transform:SetParent(self.GOButton.gameObject.transform)
    self.StartEffect.transform.localScale = Vector3(1.7, 0.6, 1)
    self.StartEffect.transform.localPosition = Vector3(-52.8, -14.6, -1000)
    Utils.ChangeLayersRecursively(self.StartEffect.transform, "UI")
    self.StartEffect:SetActive(false)
    self.MgrButton.onClick:AddListener(function()
        self:OnMgr()
    end)
    self.GOButton.onClick:AddListener(function()
        self:OnGo()
    end)
    self.tipsText = self.transform:Find("Right/tipsText"):GetComponent(Text)
    self.tipsText.text = TI18N("预选赛小组<color='#e8faff'>前2名</color>将获得<color='#e8faff'>冠军联赛</color>资格")
    self.MaskScroll = self.transform:Find("Right/MaskScroll")
    self.List = self.transform:Find("Right/MaskScroll/List")
    self.BaseItem = self.transform:Find("Right/MaskScroll/List/Item")

    self.groupTitle = self.transform:Find("Right/GroupTitle").gameObject
    self.GroupText = self.transform:Find("Right/GroupTitle/GroupText"):GetComponent(Text)
    self.Icon = self.transform:Find("Right/MaskScroll/List/Item/Icon"):GetComponent(Image)
    self.NameText = self.transform:Find("Right/MaskScroll/List/Item/NameText")
    self.DayText = self.transform:Find("Right/MaskScroll/List/Item/DayText")
    self.LookButton = self.transform:Find("Right/MaskScroll/List/Item/LookButton")
    self.SetButton = self.transform:Find("Right/MaskScroll/List/Item/SetButton")

    self.siegeEntry = self.transform:Find("Right/SiegeEntry").gameObject
    self.siegeEntryBtn = self.transform:Find("Right/SiegeEntry/Entry"):GetComponent(Button)
    self.siegeEntryTitleText = self.transform:Find("Right/SiegeEntry/Title/Text"):GetComponent(Text)
    self.siegeEntryRulsText = self.transform:Find("Right/SiegeEntry/CompetitionRuls"):GetComponent(Text)
    self.siegeEntryDescText = self.transform:Find("Right/SiegeEntry/Desc"):GetComponent(Text)
    self.siegeEntryAgainstText = self.transform:Find("Right/SiegeEntry/Against"):GetComponent(Text)
    self.siegeEntryImage = self.transform:Find("Right/SiegeEntry/Entry/Castle"):GetComponent(Image)
    self.siegeEntry:SetActive(false)

    self.transform:Find("Right/DetialButton"):GetComponent(Button).onClick:AddListener(function()
        self:OnDetial()
    end)
    local setting11 = {
        axis = BoxLayoutAxis.Y
        ,spacing = 0
        ,Left = 6
        ,Top = 0.1
        ,scrollRect = self.MaskScroll
    }
    self.Layout1 = LuaBoxLayout.New(self.List, setting11)
    self.Mgr:Require17619()
    self:SetInfo()
    self:InitList()
    self.Mgr.LeagueSummaryUpdate:AddListener(self.Updatefunc)
    self.Mgr.LeagueStatusChange:AddListener(self.statuschangefunc)
    self:OnStatusChange()

    self.MaskScroll.gameObject:SetActive(false)
    self.groupTitle.gameObject:SetActive(false)
    self.siegeEntry.gameObject:SetActive(true)
end

function GuildLeagueInfoPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildLeagueInfoPanel:SetInfo()
    if self.Mgr.guild_LeagueInfo == nil then
        return
    end
    self.data = self.Mgr.guild_LeagueInfo
    local summary = self.data
    self.Icon.sprite = self.assetWrapper:GetSprite(AssetConfig.guild_totem_icon, summary.totem)
    self.Name.text = summary.name
    if summary.ld_platform == "" then
        self.Name.text = GuildManager.Instance.model.my_guild_data.Name
    end
    for k,v in pairs(DataServerList.data_server_name) do
        if v.platform == GuildManager.Instance.model.my_guild_data.PlatForm and v.zone_id == GuildManager.Instance.model.my_guild_data.ZoneId then
            self.SvrName.text = v.platform_name
        end
    end
    local grade = {
        [1] = TI18N("<color='#ff00ff'>冠军联赛</color>"),
        [2] = TI18N("<color='#ffff00'>甲级联赛</color>"),
        [3] = TI18N("<color='#01c0ff'>乙级联赛</color>"),
        [4] = TI18N("<color='#13fc60'>丙级联赛</color>"),
    }
    if summary.grade == 0 then
        self.Info1.text = TI18N("联赛级别: 未分配")
        self.GroupText.text = TI18N("暂无对阵信息")
    else
        self.Info1.text = string.format(TI18N("联赛级别: <color='#205696'>%s</color>"), grade[summary.grade])
        if self.data.cur_phase < 4 then
            self.GroupText.text = string.format(TI18N("%s预选赛<color='#ffff00'>(第%s小组)</color>"), grade[summary.grade], tostring(summary.group))
        else
            if summary.grade < 1 then
                self.GroupText.text = string.format(TI18N("%s"), grade[summary.grade])
            else
                self.GroupText.text = string.format(TI18N("%s淘汰赛<color='#ffff00'>(第%s小组)</color>"), grade[summary.grade], tostring(summary.group))
            end
        end
    end
    self.Info2.text = string.format(TI18N("赛季胜场: <color='#205696'>%s</color>"), summary.season_win)
    self.Info3.text = string.format(TI18N("历史总胜: <color='#205696'>%s</color>"), summary.total_win)
    self.Info4.text = string.format(TI18N("公会等级: <color='#205696'>%s</color>"), summary.lev)
    self.Info5.text = string.format(TI18N("公会会长: <color='#205696'>%s</color>"), summary.leader_name)
    if summary.ld_platform == "" then
        self.Info5.text = string.format(TI18N("公会会长: <color='#205696'>%s</color>"), GuildManager.Instance.model.my_guild_data.LeaderName)
    end
    self.Info6.text = string.format(TI18N("公会成员: <color='#205696'>%s</color>"), tostring(GuildManager.Instance.model.my_guild_data.MemNum))
    self.SeasonText.text = string.format(TI18N("第%s赛季"), self.data.season_id)
    self.ScoreText.text = string.format(TI18N("赛季积分: <color='#205696'>%s</color>"), summary.season_score)
    self.RankText.text = string.format(TI18N("当前名次: <color='#205696'>%s</color>"), summary.rank)
    if summary.grade == 0 then
        self.MidIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.guildleague_levicon, string.format("lev%s", "1"))
    else
        self.MidIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.guildleague_levicon, string.format("lev%s", tostring(summary.grade)))
    end
    self:CheckRed()
end

function GuildLeagueInfoPanel:OnMgr()
    local ready = false

    ready = self.data ~= nil and self.data.trump_enable == 1

    if self.Mgr.currstatus == 1 or self.Mgr.currstatus == 2 or ready then
        self.Mgr.model:OpenTeamSetWindow()
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("活动未开始"))
    end
end

function GuildLeagueInfoPanel:OnGo()
    if self.Mgr.currstatus == 1 or self.Mgr.currstatus == 2 then
        self.Mgr:Require17602()
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.guild_league_window, false)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("活动未开始"))
    end
end

function GuildLeagueInfoPanel:OnDetial()
    self.Main.tabgroup:ChangeTab(2)
end

function GuildLeagueInfoPanel:InitList()
    if self.data == nil then
        return
    end
    local num = self.List.childCount
    for i = 0, num-1 do
        local go = self.List:GetChild(i).gameObject
        if go.activeSelf == true then
            GameObject.Destroy(go)
        end
    end
    local data = self.data.guild_league_guild
    self.Layout1:ReSet()

    table.sort( data, function(a,b) return a.time<b.time end)
    for i,v in ipairs(data) do
        if BaseUtils.isnull(self.BaseItem) then
            return
        end
        local Item = GameObject.Instantiate(self.BaseItem.gameObject)
        self:SetItem(Item, v, i)
        local trans = Item.transform
        self.Layout1:AddCell(Item)
    end
end

function GuildLeagueInfoPanel:SetItem(item, data, index)
    item.transform:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guild_totem_icon, "101")
    item.transform:Find("NameText"):GetComponent(Text).text = data.name
    local month = os.date("%m", data.time)
    local day = os.date("%d", data.time)
    local week = os.date("%w", data.time)
    if week == "0" then week = "7" end
    week = BaseUtils.NumToChn(tonumber(week))
    if week == TI18N("七") then
        week = TI18N("日")
    end
    local timeText = string.format("周%s %s月%s日", week, month, day)
    item.transform:Find("DayText"):GetComponent(Text).text = timeText
    item.transform:Find("SortText"):GetComponent(Text).text = string.format(TI18N("第%s场"), tostring(index))
    local x = 1
    for k,v in pairs(DataServerList.data_server_name) do
        if v.platform == data.platform and v.zone_id == data.zone_id then
            item.transform:Find("SvrNameText"):GetComponent(Text).text = v.platform_name
        end
    end

    item.transform:Find("LookButton"):GetComponent(Button).onClick:AddListener(function()
        self.Mgr:Require17621(data.match_id)
    end)
    item.transform:Find("SetButton"):GetComponent(Button).onClick:AddListener(function()
        local ready = false
        for k,v in pairs(self.data.guild_league_guild) do
            if v.is_win == 0 then
                ready = true
            end
        end
        if self.Mgr.currstatus == 1 or self.Mgr.currstatus == 2 or ready then
            -- if GuildManager.Instance.model:get_my_guild_post() < GuildManager.Instance.model.member_positions.elder then
            --     NoticeManager.Instance:FloatTipsByString(TI18N("您没有足够的权限"))
            -- else
                self:OnMgr()
            -- end
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("比赛尚未开始"))
        end
    end)
    if data.is_win == 0 then
        item.transform:Find("SetButton").gameObject:SetActive(true)
    else
        item.transform:Find("LookButton").gameObject:SetActive(true)
    end
end

function GuildLeagueInfoPanel:UpdatePanel()
    -- body
end

function GuildLeagueInfoPanel:OnStatusChange()
    if self.Mgr.currstatus == 1 or self.Mgr.currstatus == 2 then
        -- if GuildManager.Instance.model:get_my_guild_post() < GuildManager.Instance.model.member_positions.elder then
        --     self.MgrButton.gameObject:SetActive(false)
        -- else
            -- self.MgrButton.gameObject:SetActive(true)
        -- end
        self.MgrButton.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        self.transform:Find("Mid/MgrButton/I18N_Text"):GetComponent(Text).color = ColorHelper.DefaultButton2
        -- self.GOButton.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        self.StartEffect:SetActive(true)
    else
        self.MgrButton.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        self.GOButton.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")

        self.transform:Find("Mid/GOButton/I18N_Text"):GetComponent(Text).color = ColorHelper.DefaultButton1
        self.transform:Find("Mid/MgrButton/I18N_Text"):GetComponent(Text).color = ColorHelper.DefaultButton1

        self.StartEffect:SetActive(false)
        -- self.MgrButton.gameObject:SetActive(false)
    end
end

function GuildLeagueInfoPanel:CheckRed()
    local ready = false
    if self.data ~= nil and self.data.guild_league_guild ~= nil then
        for k,v in pairs(self.data.guild_league_guild) do
            if v.is_win == 0 then
                ready = true
            end
        end
    end
    self.mgrNotify:SetActive(GuildLeagueManager.Instance:CheckRed())
end

-- status == 0 表示未开放
-- status == 1 表示显示的是公会攻城战
-- status == 2 表示显示的是冠军联赛
-- status == 3 表示显示的是季后赛
function GuildLeagueInfoPanel:SetSiege(status)
    -- self.MaskScroll.gameObject:SetActive(status ~= true)
    -- self.groupTitle.gameObject:SetActive(status ~= true)
    -- self.siegeEntry.gameObject:SetActive(status == true)

    self.siegeEntryBtn.onClick:RemoveAllListeners()
    if status == 0 then
        self.siegeEntryTitleText.text = TI18N("赛制:<color='#ffff00'>暂未公布</color>")
        self.siegeEntryBtn.gameObject:SetActive(false)
        self.siegeEntryDescText.gameObject:SetActive(true)
        self.siegeEntryAgainstText.gameObject:SetActive(false)
        self.siegeEntryDescText.text = TI18N("对阵信息将于活动当天\n<color='#00ff00'>14:00</color>公布")
        self.tipsText.gameObject:SetActive(false)
    elseif status == 1 then
        self.siegeEntryTitleText.text = TI18N("预选赛")
        self.siegeEntryBtn.gameObject:SetActive(true)
        self.siegeEntryAgainstText.gameObject:SetActive(true)
        self.siegeEntryRulsText.text = TI18N("赛制:<color='#ffff00'>公会攻城战</color>")
        local guild = (((GuildSiegeManager.Instance.statusData or {}).guild_match_list or {})[1] or {})
        self.siegeEntryAgainstText.text = string.format(TI18N("对阵:<color='#c7f9ff'>%s-%s</color>"), tostring(BaseUtils.GetServerNameMerge(guild.guild_plat, guild.guild_zone)), tostring(guild.guild_name or TI18N("暂无数据")))

        self.siegeEntryDescText.gameObject:SetActive(false)
        self.siegeEntryImage.sprite = self.assetWrapper:GetSprite(AssetConfig.guildsiege, "Castle0")
        self.siegeEntryBtn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guild_siege_castle_window) end)
        self.tipsText.gameObject:SetActive(true)
        self.tipsText.text = TI18N("预选赛小组<color='#e8faff'>前2名</color>将获得<color='#e8faff'>冠军联赛</color>资格")
    elseif status == 2 then
        self.siegeEntryTitleText.text = TI18N("冠军联赛")
        self.siegeEntryImage.sprite = self.assetWrapper:GetSprite(AssetConfig.guildsiege, "Castle1")
        self.siegeEntryDescText.gameObject:SetActive(false)
        self.siegeEntryBtn.gameObject:SetActive(true)
        self.siegeEntryRulsText.text = TI18N("赛制:<color='#ffff00'>冠军联赛</color>")
        self.siegeEntryAgainstText.gameObject:SetActive(true)
        self.tipsText.gameObject:SetActive(true)
        self.tipsText.text = TI18N("目标<color='#ffff00'>冠军联赛</color>胜利奖杯！")
    elseif status == 3 then
        self.siegeEntryTitleText.text = TI18N("季后赛")
        self.siegeEntryBtn.gameObject:SetActive(true)
        self.siegeEntryAgainstText.gameObject:SetActive(true)
        self.siegeEntryRulsText.text = TI18N("赛制:<color='#ffff00'>公会攻城战</color>")
        local guild = (((GuildSiegeManager.Instance.statusData or {}).guild_match_list or {})[1] or {})
        self.siegeEntryAgainstText.text = string.format("对阵:<color='#c7f9ff'>%s-%s</color>", BaseUtils.GetServerNameMerge(guild.guild_plat, guild.guild_zone), guild.guild_name)

        self.siegeEntryDescText.gameObject:SetActive(false)
        self.siegeEntryImage.sprite = self.assetWrapper:GetSprite(AssetConfig.guildsiege, "Castle0")
        self.siegeEntryBtn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guild_siege_castle_window) end)
        self.tipsText.gameObject:SetActive(true)
        self.tipsText.text = TI18N("团结一心迎战对手\n为下赛季做好准备")
    end
end

