-- @author 黄耀聪
-- @date 2016年9月26日

InfoPanel = InfoPanel or BaseClass(BasePanel)

function InfoPanel:__init(model, parent)
    self.model = model
    self.name = "InfoPanel"
    self.cacheMode = CacheMode.Visible

    self.parent = parent

    self.resList = {
        {file = AssetConfig.info_window, type = AssetType.Main},
        {file = AssetConfig.mainuitrace, type = AssetType.Dep},
        {file = AssetConfig.no1inworld_textures, type = AssetType.Dep},
        {file = AssetConfig.worldchampion_LevIcon, type = AssetType.Dep},
        {file = AssetConfig.playkillicon, type = AssetType.Dep},
        {file = AssetConfig.playerkilltexture, type = AssetType.Dep},
        {file = AssetConfig.info_textures, type = AssetType.Dep},
    }

    self.titleString = TI18N("信息")
    self.infoItemList = {}
    self.scoreTextList = {}
    self.assetItemList = {}

    self.imgLoader = nil
    self.refreshWorldChampion = function ()
        self:InitWorldChampion()
    end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function InfoPanel:__delete()
    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end

    if not BaseUtils.isnull(self.transform) then
        local left = self.transform:Find("Left")
        left:Find("NoOne/NoOneTitle/Icon"):GetComponent(Image).sprite = nil
        left:Find("NoOne/NoOneBg"):GetComponent(Image).sprite = nil
        left:Find("NoOne/NoOneBg/ExtBg"):GetComponent(Image).sprite = nil
        left:Find("NoOne/NoOneBg/Bg"):GetComponent(Image).sprite = nil
        left:Find("NoOne/NoOneBg"):GetComponent(Image).sprite = nil
    end

    if self.worldChampionImage ~= nil then
        self.worldChampionImage.sprite = nil
    end
    if self.playKillImage ~= nil then
        self.playKillImage.sprite = nil
    end

    if self.quickpanel ~= nil then
        self.quickpanel:DeleteMe()
    end
    self.OnHideEvent:Fire()
    if self.infoItemList ~= nil then
        for _,v in pairs(self.infoItemList) do
            v.btn.onClick:RemoveAllListeners()
            v.iconImage.sprite = nil
        end
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function InfoPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.info_window))
    UIUtils.AddUIChild(self.parent, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    local left = t:Find("Left")
    local right = t:Find("Right")

    self.worldChampionImage = left:Find("NoOne/NoOneBg/Image"):GetComponent(Image)
    self.worldChampionBtn = left:Find("NoOne/NoOneBg"):GetComponent(Button)
    self.ShareCon = left:Find("NoOne/ShareCon").gameObject
    self.SharePanel = left:Find("NoOne/ShareCon/ImgPanel"):GetComponent(Button)
    self.ShareChat = left:Find("NoOne/ShareCon/BtnChat"):GetComponent(Button)
    self.ShareFriend = left:Find("NoOne/ShareCon/BtnFriend"):GetComponent(Button)
    -- self.worldChampionShareBtn = left:Find("NoOne/ImgShare"):GetComponent(Button)
    self.worldChampionBtnMyScore = left:Find("NoOne/BtnMyScore"):GetComponent(Button)
    self.worldChampionBtnShare = left:Find("NoOne/BtnShare"):GetComponent(Button)
    self.worldChampionBtnMyScore.onClick:AddListener(function()
         WorldChampionManager.Instance.model:OpenShareWindow()
    end)

    self.worldChampionTitleText = left:Find("NoOne/NoOneTitleBg/Text"):GetComponent(Text)
    self.worldChampionExtText = left:Find("NoOne/NoOneTitleBg/Ext"):GetComponent(Text)
    self.worldChampionNoticeBtn = left:Find("NoOne/NoOneTitle/Notice"):GetComponent(Button)
    self.worldChampionText = left:Find("NoOne/NoOneTitle/Text"):GetComponent(Text)
    self.worldChampionSlider = left:Find("NoOne/NoOneTitleBg/Slider"):GetComponent(Slider)
    self.playKillImage = left:Find("PlayKill/PlayKillBg/Image"):GetComponent(Image)
    self.playKillBtn = left:Find("PlayKill/PlayKillBg"):GetComponent(Button)
    self.playKillNoticeBtn = left:Find("PlayKill/Notice"):GetComponent(Button)
    self.playKillTitleBg = left:Find("PlayKill/PlayKillTitleBg"):GetComponent(Image)
    self.playKillText = left:Find("PlayKill/PlayKillTitleBg/Text"):GetComponent(Text)

    self.playKillNoticeBtn.onClick:AddListener(function() self:OnNoticePlayKill() end)

    left:Find("NoOne/NoOneTitle/Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworld_textures, "rankicon")
    left:Find("NoOne/NoOneBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworld_textures, "Circle3")
    left:Find("NoOne/NoOneBg/ExtBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworld_textures, "CircleFrame")
    left:Find("NoOne/NoOneBg/Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworld_textures, "Bgcircle")
    left:Find("NoOne/NoOneBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworld_textures, "Circle3")

    self.showShare = false
    self.worldChampionBtnShare.onClick:AddListener(function()
        self.showShare = not self.showShare
        self.ShareCon.gameObject:SetActive(self.showShare)
    end)

    self.SharePanel.onClick:AddListener(function()
        self.showShare = not self.showShare
        self.ShareCon.gameObject:SetActive(self.showShare)
    end)

    self.ShareChat.onClick:AddListener(function()
        self.showShare = not self.showShare
        self.ShareCon.gameObject:SetActive(self.showShare)
        WorldChampionManager.Instance.model:OnShareFightScore()
    end)
    local setting = {title = TI18N("武道战绩分享"), type = 2}
    self.quickpanel = ZoneQuickShareStr.New(setting)
    self.ShareFriend.onClick:AddListener(function()
        self.showShare = not self.showShare
        self.ShareCon.gameObject:SetActive(self.showShare)
        self.quickpanel:Show()
    end)


    local right = t:Find("Right")
    for i=1,6 do
        local tab = {}
        tab.transform = right:Find("Info"):GetChild(i - 1)
        if tab.transform:Find("Icon") ~= nil then
            tab.iconImage = tab.transform:Find("Icon"):GetComponent(Image)
            tab.text = tab.transform:Find("Bg/Text"):GetComponent(Text)
            tab.btn = tab.transform:Find("Detail"):GetComponent(Button)
            if tab.transform:Find("Slider") ~= nil then
                tab.slider = tab.transform:Find("Slider"):GetComponent(Slider)
                tab.sliderText = tab.transform:Find("Slider/Text"):GetComponent(Text)
            end
            table.insert(self.infoItemList, tab)
        end
    end

    local scoreContainer = right:Find("Assets/Container")
    for i=1,7 do
        local tab = {}
        tab.transform = scoreContainer:GetChild(i - 1)
        tab.text = tab.transform:Find("Name/Value"):GetComponent(Text)
        tab.btn = tab.transform:GetComponent(Button)
        tab.transform:GetComponent(TransitionButton).scaleSetting = true
        table.insert(self.scoreTextList, tab)
    end

    self.gridLayout = LuaGridLayout.New(right:Find("Assets/Container"), {cellSizeX = 150, cellSizeY = 40, column = 2})
    self.cloner = right:Find("Assets/Cloner").gameObject

    self.exchangeBtn = right:Find("Button"):GetComponent(Button)

    self.exchangeBtn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {2, 1}) end)
    self.playKillBtn.onClick:AddListener(function() self:GotoPlaykill() end)
    self.worldChampionBtn.onClick:AddListener(function() self:JumpToWorldChampion() end)
    self.worldChampionNoticeBtn.onClick:AddListener(function() self:OnNotice() end)

    if self.imgLoader == nil then
        local go = right:Find("Assets/Container/KingScore/Icon").gameObject
        self.imgLoader = SingleIconLoader.New(go)
    end
    self.imgLoader:SetSprite(SingleIconType.Item, 90020)
end

function InfoPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end
function InfoPanel:OnOpen()
    self:RemoveListeners()
    WorldChampionManager.Instance.refreshRankData:AddListener(self.refreshWorldChampion)

    -- self:InitWorldChampion()
    WorldChampionManager.Instance:Require16405(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
    self:InitPlaykill()
    self:InitInfo()
    self:InitScore()
end

function InfoPanel:OnHide()
    if self.playkillTimerId ~= nil then
        LuaTimer.Delete(self.playkillTimerId)
        self.playkillTimerId = nil
    end
    self:RemoveListeners()
end

function InfoPanel:RemoveListeners()
    WorldChampionManager.Instance.refreshRankData:RemoveListener(self.refreshWorldChampion)
end

function InfoPanel:InitWorldChampion()
    local worldChampionData = WorldChampionManager.Instance.rankData
    self.worldChampionImage.sprite = self.assetWrapper:GetSprite(AssetConfig.worldchampion_LevIcon, tostring(worldChampionData.rank_lev))
    BaseUtils.SetGrey(self.worldChampionImage, RoleManager.Instance.RoleData.lev < 70)
    self.worldChampionTitleText.text = DataTournament.data_list[worldChampionData.rank_lev].name
    self.worldChampionExtText.text = string.format(TI18N("<color='#0c52b0'>历史最高:</color><color='#13fc60'>%s</color>"), DataTournament.data_list[worldChampionData.best_rank_lev].boxname)
    self.worldChampionSlider.value = (worldChampionData.rank_point % 100) / 100
    self.worldChampionText.text = string.format(TI18N("武道会头衔 <color='#23f0f7'>[第%s赛季]</color>"), tostring(WorldChampionManager.Instance.season_id or 0))
end

function InfoPanel:InitPlaykill()
    local protoData = PlayerkillManager.Instance.myData
    local cfg_data = nil
    if protoData ~= nil then
        cfg_data = DataRencounter.data_info[protoData.rank_lev or 1]
    end
    if cfg_data == nil then
        cfg_data = DataRencounter.data_info[1]
    end
    self.playKillImage.sprite = self.assetWrapper:GetSprite(AssetConfig.playkillicon, "Lev" .. tostring(cfg_data.index))
    self.playKillText.text = string.format("%s%s(%s阶)", cfg_data.rencounter, cfg_data.title, tostring(cfg_data.index))
    if RoleManager.Instance.RoleData.lev < 65 then
        BaseUtils.SetGrey(self.playKillImage, true)
        BaseUtils.SetGrey(self.playKillTitleBg, true)
        self.playKillText.color = Color(0.5, 0.5, 0.5)
        if self.playkillTimerId == nil then
            self.playkillTimerId = LuaTimer.Add(0, 10, function() self:FloatPlaykill() end)
        end
    else
        BaseUtils.SetGrey(self.playKillImage, false)
        BaseUtils.SetGrey(self.playKillTitleBg, false)
        self.playKillText.color = ColorHelper.DefaultButton3
        if self.playkillTimerId ~= nil then
            LuaTimer.Delete(self.playkillTimerId)
            self.playkillTimerId = nil
        end
    end
end

function InfoPanel:GotoPlaykill()
    if RoleManager.Instance.RoleData.lev < 65 then
        NoticeManager.Instance:FloatTipsByString(TI18N("<color='#ffff00'>英雄擂台</color>将于65级后开放哟~{face_1, 54}"))
    else
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.backpack)
        PlayerkillManager.Instance.model:OpenMainWindow()
    end
end

function InfoPanel:FloatPlaykill()
    self.playkillCounter = (self.playkillCounter or 0) + 1
    self.playKillImage.transform.anchoredPosition = Vector2(0, -18 + 4*math.sin(self.playkillCounter * math.pi / 60))
end

function InfoPanel:InitInfo()
    if WorldChampionManager.Instance.model:CheckShowLev() then
        self.worldChampionBtnMyScore.gameObject:SetActive(true)
        self.worldChampionBtnShare.gameObject:SetActive(true)
    else
        self.worldChampionBtnMyScore.gameObject:SetActive(false)
        self.worldChampionBtnShare.gameObject:SetActive(false)
    end

    -- 工会
    local guildMgr = GuildManager.Instance
    if guildMgr.model:check_has_join_guild() then
        if guildMgr.model.member_position_names[guildMgr.model:get_my_guild_post()] ~= nil then
            self.infoItemList[1].text.text = string.format("%s<color='#ff88ff'>[%s]</color>", GuildManager.Instance.model.my_guild_data.Name, guildMgr.model.member_position_names[guildMgr.model:get_my_guild_post()])
        else
            self.infoItemList[1].text.text = GuildManager.Instance.model.my_guild_data.Name
        end
    else
        self.infoItemList[1].text.text = TI18N("无")
    end
    self.infoItemList[1].btn.onClick:RemoveAllListeners()
    self.infoItemList[1].btn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guildwindow) end)

    -- 伴侣
    self.infoItemList[2].btn.onClick:RemoveAllListeners()
    if RoleManager.Instance.RoleData.wedding_status == 3 then
        self.infoItemList[2].text.text = RoleManager.Instance.RoleData.lover_name
        MarryManager.Instance.model.windowId = self.windowId
        self.infoItemList[2].btn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.marriage_certificate_window) end)
    else
        self.infoItemList[2].text.text = TI18N("无")
        self.infoItemList[2].btn.onClick:AddListener(function() WindowManager.Instance:CloseWindowById(WindowConfig.WinID.backpack) QuestManager.Instance.model:FindNpc("44_1") end)
    end

    -- 称号
    -- self.infoItemList[3].text.text =
    self.infoItemList[3].btn.onClick:RemoveAllListeners()
    self.infoItemList[3].btn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.info_honor_window) end)
    self:OnUpdateHonor()

    -- 活力
    local energyBase = DataAgenda.data_energy_max[RoleManager.Instance.RoleData.lev] or {}
    local max_energy = energyBase.max_energy or 0
    if PrivilegeManager.Instance.monthlyExcessDays > 0 then
        max_energy = max_energy + 200
    end
    self.infoItemList[4].sliderText.text = string.format("%s/%s", RoleManager.Instance.RoleData.energy, max_energy)
    if max_energy == 0 then
        self.infoItemList[4].slider.value = 0
    else
        self.infoItemList[4].slider.value = RoleManager.Instance.RoleData.energy / max_energy
    end
    self.infoItemList[4].btn.onClick:RemoveAllListeners()
    self.infoItemList[4].btn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.skill_use_energy) end)

    -- 结拜
    self.infoItemList[5].btn.onClick:RemoveAllListeners()
    self.infoItemList[5].btn.onClick:AddListener(function() self:GoToSworn() end)

    if SwornManager.Instance.model.swornData ~= nil and SwornManager.Instance.model.swornData.status == SwornManager.Instance.statusEumn.Sworn
        and SwornManager.Instance.model.swornData.members ~= nil and next(SwornManager.Instance.model.swornData.members) ~= nil
        and SwornManager.Instance.model.rankList ~= nil and next(SwornManager.Instance.model.rankList) ~= nil
        then
        self.infoItemList[5].text.text = string.format(TI18N("%s之%s%s"), SwornManager.Instance.model.swornData.name, SwornManager.Instance.model.rankList[SwornManager.Instance.model.myPos], SwornManager.Instance.model.swornData.members[SwornManager.Instance.model.myPos].name_defined)
    else
        self.infoItemList[5].text.text = TI18N("无")
    end

    -- 段位赛
    self.infoItemList[6].btn.onClick:RemoveAllListeners()
    self.infoItemList[6].btn.onClick:AddListener(function() self:GotoQualify() end)
    local portoData = QualifyManager.Instance.model.mine_qualify_data
    local cfg_data = DataQualifying.data_qualify_data_list[portoData.rank_lev]
    if cfg_data ~= nil then
        self.infoItemList[6].text.text = string.format("<color='#205696'>%s</color>\n<color='#3155ad'>%s</color>", cfg_data.lev_name, tostring(portoData.rank_point))
    else
        self.infoItemList[6].text.text = TI18N("无")
    end
end

function InfoPanel:GotoQualify()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.qualifying_window)
end

function InfoPanel:GoToSworn()
    if SwornManager.Instance.model.swornData == nil or SwornManager.Instance.model.swornData.status ~= SwornManager.Instance.statusEumn.Sworn then
        -- 无结拜
        if CombatManager.Instance.isFighting then
            -- 战斗中
            NoticeManager.Instance:FloatTipsByString(TI18N("请战斗结束后再前往结拜"))
        elseif CombatManager.Instance.isWatching then
            NoticeManager.Instance:FloatTipsByString(TI18N("请观战结束后再前往结拜"))
        else
            if TeamManager.Instance:MyStatus() ~= RoleEumn.TeamStatus.Follow then
                -- 非跟随
                NoticeManager.Instance:FloatTipsByString(TI18N("正在前往<color='#ffff00'>结拜使者</color>处"))
                QuestManager.Instance.model:FindNpc("77_1")
                --WindowManager.Instance:OpenWindowById(WindowConfig.WinID.teacher_window, {3})
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("正在队伍中，结拜需要队长带队前往"))
            end
        end
    else
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.backpack)
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.teacher_window, {3})
    end
end

function InfoPanel:InitScore()
    local roleData = RoleManager.Instance.RoleData
    self.scoreTextList[1].text.text = tostring(roleData.stars_score)     -- 星辰积分
    self.scoreTextList[1].btn.onClick:RemoveAllListeners()
    self.scoreTextList[1].btn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = self.scoreTextList[1].btn.gameObject, itemData = ShopManager.Instance.model.helpRPText[1]}) end)

    self.scoreTextList[2].text.text = tostring(roleData.character)       -- 人品值
    self.scoreTextList[2].btn.onClick:RemoveAllListeners()
    self.scoreTextList[2].btn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = self.scoreTextList[2].btn.gameObject, itemData = ShopManager.Instance.model.helpRPText[2]}) end)

    self.scoreTextList[3].text.text = tostring(roleData.tournament)      -- 王者积分
    self.scoreTextList[3].btn.onClick:RemoveAllListeners()
    self.scoreTextList[3].btn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = self.scoreTextList[3].btn.gameObject, itemData = ShopManager.Instance.model.helpRPText[5]}) end)

    self.scoreTextList[4].text.text = tostring(roleData.love)            -- 恩爱值
    self.scoreTextList[4].btn.onClick:RemoveAllListeners()
    self.scoreTextList[4].btn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = self.scoreTextList[4].btn.gameObject, itemData = ShopManager.Instance.model.helpRPText[3]}) end)

    self.scoreTextList[6].text.text = tostring(roleData.teacher_score)   -- 师道值
    self.scoreTextList[6].btn.onClick:RemoveAllListeners()
    self.scoreTextList[6].btn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = self.scoreTextList[6].btn.gameObject, itemData = ShopManager.Instance.model.helpRPText[4]}) end)


    local guildContribute = 0
    -- print(BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id))
    -- BaseUtils.dump(GuildManager.Instance.model.guild_member_list, "GuildManager.Instance.model.guild_member_list")
    if GuildManager.Instance.model.guild_member_list ~= nil then
        for i,v in ipairs(GuildManager.Instance.model.guild_member_list) do
            if v.Rid == roleData.id and v.PlatForm == roleData.platform and v.ZoneId == roleData.zone_id then
                guildContribute = v.TotalGx
            end
        end
    end
    self.scoreTextList[5].text.text = tostring(guildContribute)          -- 公会贡献
    self.scoreTextList[5].btn.onClick:RemoveAllListeners()
    self.scoreTextList[5].btn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = self.scoreTextList[5].btn.gameObject, itemData = {TI18N("<color='#ffff00'>公会贡献</color>可以通过<color='#00ff00'>公会任务</color>和<color='#00ff00'>公会建设</color>获得"),TI18N("1.公会任务：<color='#ffff00'>50</color>{assets_2, 90011}/天"), TI18N("2.公会捐献：<color='#ffff00'>1000</color>{assets_2, 90011}/周"), TI18N("3.公会建设：<color='#ffff00'>大量</color>{assets_2, 90011}")}}) end)

    self.scoreTextList[7].transform.gameObject:SetActive(false)
end

function InfoPanel:OnUpdateHonor()
    if is_open == false then
        return
    end
    local honor_data = HonorManager.Instance.model:get_current_honor()
    local honor_name = TI18N("无")
    if honor_data ~= nil then
        if honor_data.type == 3 then
            if GuildManager.Instance.model.my_guild_data ~= nil and GuildManager.Instance.model.my_guild_data.Name ~= nil then
                honor_name = string.format("%s%s%s", GuildManager.Instance.model.my_guild_data.Name, TI18N("的"), honor_data.name)
            end
        elseif honor_data.type == 7 then
            if TeacherManager.Instance.model.myTeacherInfo.name ~= "" then
                honor_name = string.format("%s%s", TeacherManager.Instance.model.myTeacherInfo.name, honor_data.name)
            elseif TeacherManager.Instance.model.myTeacherInfo.status == 3 then     -- 师傅
                honor_name = honor_data.name
            elseif TeacherManager.Instance.model.myTeacherInfo.status ~= 0 then -- 徒弟或者已出师
                honor_name = string.format("%s%s", TeacherManager.Instance.model.myTeacherInfo.name, honor_data.name)
            end
        elseif honor_data.type == 10 then
            if SwornManager.Instance.model.swornData ~= nil and SwornManager.Instance.model.swornData.status == SwornManager.Instance.statusEumn.Sworn then
                honor_name = string.format(TI18N("%s之%s%s"), SwornManager.Instance.model.swornData.name, SwornManager.Instance.model.rankList[SwornManager.Instance.model.myPos], SwornManager.Instance.model.swornData.members[SwornManager.Instance.model.myPos].name_defined)
            end
        else
            honor_name = honor_data.name
        end
    end
    self.infoItemList[3].text.text = honor_name
end

function InfoPanel:ShowHonor()
    HonorManager.Instance.model:InitMainUI()
end

function InfoPanel:JumpToWorldChampion()
    if RoleManager.Instance.RoleData.lev < 70 then
        NoticeManager.Instance:FloatTipsByString(TI18N("<color='#ffff00'>天下第一武道会</color>将于70级后开放哟~{face_1, 54}"))
    else
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.worldchampion)
    end
end

function InfoPanel:OnNotice()
    local currentNpcData = DataUnit.data_unit[20004]
    local extra = {}
    extra.base = BaseUtils.copytab(DataUnit.data_unit[20004])
    extra.base.buttons = {}
    extra.base.plot_talk = TI18N("<color='#ffff00'>每月20日23:50</color>进行赛季结算，届时将按<color='#00ff00'>头衔</color>发放结算奖励：<color='#ffff00'>赛季荣耀礼包</color>。新赛季将于<color='#ffff00'>当日</color>开启，新赛季初始头衔将根据结算成绩调整。")
    MainUIManager.Instance.dialogModel:Open(currentNpcData, extra, true)
end

function InfoPanel:OnNoticePlayKill()
    local npcBase = DataUnit.data_unit[20104]
    local extra = {base = BaseUtils.copytab(npcBase)}
    local buttons = {}
    for i,v in ipairs(extra.base.buttons) do
        if v.button_id == 4 then
            extra.base.plot_talk = v.button_show
            break
        end
    end
    extra.base.buttons = {}
    MainUIManager.Instance:OpenDialog({baseid = npcBase.id, name = npcBase.name}, extra, true)
end
