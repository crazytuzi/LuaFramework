WorldChampionSubonePanel = WorldChampionSubonePanel or BaseClass(BasePanel)

function WorldChampionSubonePanel:__init(parent, Main)
    self.model = model
    self.Mgr = WorldChampionManager.Instance
    self.parent = parent
    self.Main = Main
    self.name = "WorldChampionSubonePanel"
    self.Titletimer = nil
    self.btnEffect = "prefabs/effect/20053.unity3d"
    self.resList = {
        {file = AssetConfig.worldchampionmainsub1, type = AssetType.Main},
        {file = self.btnEffect, type = AssetType.Main},
        {file = AssetConfig.classcardgroup_textures, type = AssetType.Dep},
        {file = AssetConfig.worldchampion_LevIcon, type = AssetType.Dep},
        {file = AssetConfig.heads, type = AssetType.Dep},
        {file = AssetConfig.no1inworld_textures, type = AssetType.Dep},
        {file  =  AssetConfig.wingsbookbg, type  =  AssetType.Dep},
        {file = AssetConfig.attr_icon,type = AssetType.Dep}
    }
-- PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "sexIcon_" ..  tostring(shouhuData.classes))
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.levChange = function()
        if WorldChampionManager.Instance.model:CheckShowLev() then
            self.BtnMyScore.gameObject:SetActive(true)
            self.BtnShare.gameObject:SetActive(true)
        else
            self.BtnMyScore.gameObject:SetActive(false)
            self.BtnShare.gameObject:SetActive(false)
        end
    end
    self.refreshRankData = function ()
        self:SetInfo()
    end
    -- self.showButtonEft = function() self:ShowButtonEft()  end
    -- self.hideButtonEft = function() self:HideButtonEft()  end


    self.lastclick = 0
end

function WorldChampionSubonePanel:OnOpen()
    self.Mgr.refreshRankData:RemoveListener(self.refreshRankData)
    self.Mgr.refreshRankData:AddListener(self.refreshRankData)
    -- self.Mgr.onOpenBadge:AddListener(self.hideButtonEft)
    -- self.Mgr.onHideBadge:AddListener(self.showButtonEft)
    if self.gameObject ~= nil then
        self.gameObject:SetActive(true)
        if WorldChampionManager.Instance.model:CheckShowLev() then
            self.BtnMyScore.gameObject:SetActive(true)
            self.BtnShare.gameObject:SetActive(true)
        else
            self.BtnMyScore.gameObject:SetActive(false)
            self.BtnShare.gameObject:SetActive(false)
        end
    end
    self.Mgr:Require16405(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
end

function WorldChampionSubonePanel:OnHide()
    -- self.Mgr.onOpenBadge:RemoveListener(self.hideButtonEft)
    -- self.Mgr.onHideBadge:RemoveListener(self.showButtonEft)
    self.Mgr.refreshRankData:RemoveListener(self.refreshRankData)
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
end

function WorldChampionSubonePanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.role_level_change, self.levChange)
    self.Mgr.refreshRankData:RemoveListener(self.refreshRankData)
    if self.quickpanel ~= nil then
        self.quickpanel:DeleteMe()
    end
    if self.headLoader ~= nil then
        self.headLoader:DeleteMe()
        self.headLoader = nil
    end

    if self.preview ~= nil then
        self.preview:DeleteMe()
        self.preview = nil
    end

    if self.GiftPreview ~= nil then
        self.GiftPreview:DeleteMe()
        self.GiftPreview = nil
    end
    if self.effect ~= nil then
        for _,v in pairs(self.effect) do
            v:DeleteMe()
        end
        self.effect = nil
    end
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function WorldChampionSubonePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.worldchampionmainsub1))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)
    self.transform = t

    t:Find("boxbg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")

    self.head = t:Find("head")
    self.PlayerInfo = t:Find("PlayerInfo")
    self.Head = t:Find("midbg/CenterCircle/Head"):GetComponent(Image)
    self.LevText = t:Find("midbg/LevText"):GetComponent(Text)
    self.generalGame = t:Find("midbg/GeneralGame").gameObject
    self.Slider = t:Find("midbg/GeneralGame/Slider"):GetComponent(Slider)
    self.LevText2 = t:Find("midbg/GeneralGame/LevText2"):GetComponent(Text)
    self.BtnMyScore = t:Find("midbg/BtnMyScore"):GetComponent(Button)
    self.BtnShare = t:Find("midbg/BtnShare"):GetComponent(Button)
    self.lvlupGame = t:Find("midbg/LvlupGame").gameObject
    self.threeGame = self.lvlupGame.transform:Find("threegame")
    self.fourGame = self.lvlupGame.transform:Find("fourgame")
    self.lvlupGame.transform:Find("Button"):GetComponent(Button).onClick:AddListener(function ()
        local lev = self.Mgr.rankData.rank_lev
        if lev <= #DataTournament.data_get_promotion_combat then
            local needwin = DataTournament.data_get_promotion_combat[lev].need_win
            local name = DataTournament.data_get_promotion_combat[lev+1].name
            TipsManager.Instance:ShowText({gameObject = self.lvlupGame.transform:Find("Button"),itemData = {string.format(TI18N("1、当前段位达到<color='#ffff00'>100分</color>后进入晋级赛\n2、累计<color='#ffff00'>获胜%s次</color>后即可晋级<color='#ffff00'>%s</color>\n3、晋级过程中会累计一定<color='#ffff00'>积分</color>，将在\n晋级成功后直接获得，不影响上分速度哟"),needwin,name)}})
        end
    end)

    if WorldChampionManager.Instance.model:CheckShowLev() then
        self.BtnMyScore.gameObject:SetActive(true)
        self.BtnShare.gameObject:SetActive(true)
    else
        self.BtnMyScore.gameObject:SetActive(false)
        self.BtnShare.gameObject:SetActive(false)
    end

    self.ShareCon = t:Find("midbg/ShareCon").gameObject
    self.SharePanel = t:Find("midbg/ShareCon/ImgPanel"):GetComponent(Button)
    self.ShareChat = t:Find("midbg/ShareCon/BtnChat"):GetComponent(Button)
    self.ShareFriend = t:Find("midbg/ShareCon/BtnFriend"):GetComponent(Button)
    self.BtnMyScore.onClick:AddListener(function()
        self.Mgr.model:OpenShareWindow()
    end)
    self.showShare = false
    self.BtnShare.onClick:AddListener(function()
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


    self.NextLevText = t:Find("midbg/GeneralGame/NextLevText"):GetComponent(Text)
    self.LvlupText = t:Find("midbg/LvlupGame/Text"):GetComponent(Text)
    self.CenterCircle = t:Find("midbg/CenterCircle")
    self.CenterCircle.gameObject:AddComponent(Button).onClick:AddListener(function()
        self:OnCkickLevIcon()
    end)
    self.midtitlebtn = self.transform:Find("midbg/Title"):GetComponent(Button)
    self.midtitlebtn.onClick:AddListener(function()
        local currentNpcData = DataUnit.data_unit[20004]
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[20004])
        extra.base.buttons = {}
        extra.base.plot_talk = TI18N("<color='#ffff00'>每月20日23:50</color>进行赛季结算，届时将按<color='#00ff00'>头衔</color>发放结算奖励：<color='#ffff00'>赛季荣耀礼包</color>。新赛季将于<color='#ffff00'>当日</color>开启，新赛季初始头衔将根据结算成绩调整。")
        MainUIManager.Instance.dialogModel:Open(currentNpcData, extra, true)
    end)
    self.seasonbtn = self.transform:Find("midbg/Button"):GetComponent(Button)
    self.seasonbtn.onClick:AddListener(function()
        local currentNpcData = DataUnit.data_unit[20004]
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[20004])
        extra.base.buttons = {}
        extra.base.plot_talk = TI18N("<color='#ffff00'>每月21日12:00</color>进行赛季结算，届时将按<color='#00ff00'>头衔</color>发放结算奖励：<color='#ffff00'>赛季荣耀礼包</color>。新赛季将于<color='#ffff00'>当日</color>开启，新赛季初始头衔将根据结算成绩调整。")
        MainUIManager.Instance.dialogModel:Open(currentNpcData, extra, true)
    end)
    self.transform:Find("midbg/Title/Text"):GetComponent(Text).text = string.format(TI18N("第%s赛季"), BaseUtils.NumToChn(self.Mgr.season_id))
    self.boxtitleText = t:Find("boxtitle/Text"):GetComponent(Text)
    self.boxbg = t:Find("boxbg")
    self.BoxName = t:Find("BoxName")
    self.Button = t:Find("Button"):GetComponent(Button)
    self.GiftPreview = GiftPreview.New(self.Main.gameObject)
    self.BoxDesc = t:Find("BoxDesc"):GetComponent(Text)

    self.SingleEffect = GameObject.Instantiate(self:GetPrefab(self.btnEffect))
    self.SingleEffect.transform:SetParent(self.Button.gameObject.transform)
    self.SingleEffect.transform.localScale = Vector3(2, 0.68, 1)
    self.SingleEffect.transform.localPosition = Vector3(-64, -16, -1000)
    Utils.ChangeLayersRecursively(self.SingleEffect.transform, "UI")
    self.SingleEffect:SetActive(self.Mgr.currstatus ~= 0)

    EventMgr.Instance:AddListener(event_name.role_level_change, self.levChange)
    -- self:SetInfo()
end

function WorldChampionSubonePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function WorldChampionSubonePanel:SetInfo()

    local data = self.Mgr.rankData

    self.head:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_%s", RoleManager.Instance.RoleData.classes, RoleManager.Instance.RoleData.sex))
    if data ~= nil then
        data.best_rank_lev = (data.best_rank_lev ~= nil and data.best_rank_lev ~= 0 )and data.best_rank_lev or 1
        data.rank_lev = (data.rank_lev ~= nil and data.rank_lev ~= 0 )and data.rank_lev or 1
        data.best_win_count = data.best_win_count ~= nil and data.best_win_count or 0
        data.win_count = data.win_count ~= nil and data.win_count or 0
        self.PlayerInfo:Find("Info1/Text2"):GetComponent(Text).text = RoleManager.Instance.RoleData.name
        self.PlayerInfo:Find("Info2/Text2"):GetComponent(Text).text = DataTournament.data_list[data.rank_lev].name
        local rate = 0
        if data.combat_count > 0 then
            rate = math.ceil(data.win_count/data.combat_count*100)
        end
        self.PlayerInfo:Find("Info3/Text2"):GetComponent(Text).text = string.format("<color='#00ff00'>%s%%</color>(%s/%s)", rate, data.win_count, data.combat_count, rate)
        self.PlayerInfo:Find("Info4/Text2"):GetComponent(Text).text = DataTournament.data_list[data.best_rank_lev].name
        self.PlayerInfo:Find("Info6/Text2"):GetComponent(Text).text = tostring(data.best_win_count)
        self.PlayerInfo:Find("Info7/Text2"):GetComponent(Text).text = data.liked ~= nil and tostring(data.liked) or "0"
        local best_partner = TI18N("无")
        if data.best_partner ~= nil and data.best_partner[1]~= nil and data.best_partner[1].partner_name  ~= nil then
            best_partner = data.best_partner[1].partner_name
        end
        self.PlayerInfo:Find("Info5/Text2"):GetComponent(Text).text = best_partner
    end

    local lev = self.Mgr.rankData.rank_lev
    -- BaseUtils.dump(self.Mgr.rankData, "数据啊啊啊啊啊啊")
    local LvData = DataTournament.data_list[lev]
    local nextLvData = DataTournament.data_list[lev+1]
    -- if self.Mgr.rankData.best_rank_lev > lev and self.Mgr.rankData.best_rank_lev > lev + 1 then
    --     if self.Mgr.rankData.best_rank_lev+ 1 <= 11 then
    --         nextLvData = DataTournament.data_list[self.Mgr.rankData.best_rank_lev+ 1]
    --     else
    --         nextLvData = DataTournament.data_list[11]
    --     end
    -- else
        if lev + 1 <= 11 then
            nextLvData = DataTournament.data_list[lev+1]
        else
            nextLvData = DataTournament.data_list[11]
        end
    -- end

    if self.headLoader == nil then
        self.headLoader = SingleIconLoader.New(self.Head.gameObject)
    end
    self.headLoader:SetSprite(SingleIconType.Pet, LvData.icon)
    -- self.Head.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(LvData.icon), LvData.icon)
    self.LevText.text = LvData.boxname
    -- self.boxtitleText.text = TI18N(string.format("首次晋级%s奖励", nextLvData.name))
    self.BoxDesc.text = string.format(TI18N("本赛季首次达到%s等级后可获得晋级奖励"), nextLvData.name)
    if data.rank_point == nil then
        data.rank_point = 1
    end

    if lev < #DataTournament.data_list - 1 then
        local currpoint = data.rank_point%100
        if data.rank_point> 0 and currpoint == 0 and data.rank_point/100 == data.rank_lev then
            currpoint = 100
        end
        if currpoint ~= 100 then
            self.lvlupGame:SetActive(false)
            self.generalGame:SetActive(true)
            self.LevText2.text = string.format("%s/100", tostring(currpoint))
            self.Slider.value = currpoint/100
        else
            self.lvlupGame:SetActive(true)
            self.generalGame:SetActive(false)
            --晋级赛显示
            local needwin = DataTournament.data_get_promotion_combat[lev].need_win
            self.LvlupText.text = string.format(TI18N("累计<color='#f6ee65'>%s胜</color>即可晋级<color='#f6ee65'>%s</color>"),needwin,nextLvData.boxname)
            local t
            if needwin < 4 then
                self.threeGame.gameObject:SetActive(true)
                self.fourGame.gameObject:SetActive(false)
                t = self.threeGame
                if needwin == 2 then
                    t:Find(tostring(3)):GetComponent(Image).color = Color(1, 1, 1, 0.2)
                end
            else
                self.threeGame.gameObject:SetActive(false)
                self.fourGame.gameObject:SetActive(true)
                t = self.fourGame
            end
            if data.promotion_win > 0 then
                self.effect = {}
                for i=1,data.promotion_win do
                    t:Find(tostring(i)):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworld_textures,"done")
                    self.effect[i] = BaseUtils.ShowEffect(20463, t:Find(tostring(i)), Vector3(1,1,1), Vector3(0,0,-1000))
                end
            end
        end
    else
        self.lvlupGame:SetActive(false)
        self.generalGame:SetActive(true)
        local currpoint = data.rank_point-900
        self.LevText2.text = string.format("积分：%s", tostring(currpoint))
        self.Slider.value = 1
    end

    if nextLvData ~= nil and lev < #DataTournament.data_list - 1 then
        -- local nextdata = DataTournament.data_list[lev+1]
        self.NextLevText.text = string.format(TI18N("<color='#bef1fc'>下一级：%s</color>"), nextLvData.boxname)
    elseif nextLvData ~= nil and lev == #DataTournament.data_list - 1 then
        self.NextLevText.text = TI18N("前百晋级星辰王者")
    else
        self.NextLevText.text = TI18N("无敌寂寞，强者之巅!")
    end

    self.BoxName:GetComponent(Text).text = string.format(TI18N("<color='#D781F2'>%s礼盒</color>"),nextLvData.boxname)
    self.unit_data = DataUnit.data_unit[nextLvData.boxres]
    local setting = {
        name = "WorldChampionSubonePanel"
        ,orthographicSize = 0.28
        ,width = 190
        ,height = 190
        ,offsetY = -0.17
        ,noDrag = true
    }
    local modelData = {type = PreViewType.Npc, skinId = self.unit_data.skin, modelId = self.unit_data.res, animationId = self.unit_data.animation_id, scale = 1}
    if self.preview == nil then
        self.preview = PreviewComposite.New(function(composite) self:PreViewLoaded(composite) end, setting, modelData)
    end

    self.Button.onClick:AddListener(function()
        self.Mgr.model:CloseMainWindow()
        if RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionStart or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionReady or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionSuccess then
            self.Mgr.model:OpenMainPanel()
        else
            self.Mgr:Require16401()
        end
    end)
end

function WorldChampionSubonePanel:PreViewLoaded(composite)
    local rawImage = composite.rawImage
    if rawImage ~= nil then
        rawImage.transform:SetParent(self.boxbg)
        rawImage.transform.localPosition = Vector3(-4, 18, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
        composite.tpose.transform:Rotate(Vector3(350,340,5))
        local btn = rawImage:AddComponent(Button)
        btn.onClick:AddListener(function() self:OnClickBox() end)
    end
    if self.preview ~= nil then
        self.preview:PlayAnimation("Stand2")
    end

end

function WorldChampionSubonePanel:OnClickBox()
    -- self.preview:PlayAnimation("Dead2")
    self:ShowReward()
end

function WorldChampionSubonePanel:ShowReward()
    local lev = self.Mgr.rankData.rank_lev
    local LvData = DataTournament.data_list[lev]
    local nextLvData = DataTournament.data_list[lev+1]
    -- if self.Mgr.rankData.best_rank_lev > lev and self.Mgr.rankData.best_rank_lev > lev + 1 then
    --     if self.Mgr.rankData.best_rank_lev+ 1 <= 11 then
    --         nextLvData = DataTournament.data_list[self.Mgr.rankData.best_rank_lev+ 1]
    --     else
    --         nextLvData = DataTournament.data_list[11]
    --     end
    -- else
        if lev + 1 <= 11 then
            nextLvData = DataTournament.data_list[lev+1]
        else
            nextLvData = DataTournament.data_list[11]
        end
    local reward = nextLvData.advance_reward
    self.GiftPreview:Show({reward = reward, text = string.format(TI18N("首次晋级%s奖励"), nextLvData.name), autoMain = true})
end

function WorldChampionSubonePanel:OnCkickLevIcon()
    if Time.time - self.lastclick < 2 then
        return
    end
    self.lastclick = Time.time
    local lev = self.Mgr.rankData.rank_lev
    local LvData = DataTournament.data_list[lev]
    self.CenterCircle.localScale = Vector3.one*0.9
    Tween.Instance:Scale(self.CenterCircle, Vector3(1, 1, 1), 0.5, tween2, LeanTweenType.easeOutElastic)
    local msg = LvData.dialog1[Random.Range(1, #LvData.dialog1)]
    if msg ~= nil then
        msg = msg.key
        NoticeManager.Instance:FloatTipsByString(msg)
    else
    end
    -- WorldChampionManager.Instance.model:OpenSuccessWindow({})
end

-- function WorldChampionSubonePanel:ShowButtonEft()
--     self.SingleEffect:SetActive(true)
-- end

-- function WorldChampionSubonePanel:HideButtonEft()
--     self.SingleEffect:SetActive(false)
-- end