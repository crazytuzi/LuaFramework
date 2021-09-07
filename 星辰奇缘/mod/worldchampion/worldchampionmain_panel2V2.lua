-- 武道会2V2
-- 20170420

WorldChampionMainPanel2V2 = WorldChampionMainPanel2V2 or BaseClass(BasePanel)

function WorldChampionMainPanel2V2:__init(model)
    self.model = model
    self.Mgr = WorldChampionManager.Instance
    self.parent = parent
    self.name = "WorldChampionMainPanel2V2"
    self.Titletimer = nil
    self.btnEffect = "prefabs/effect/20053.unity3d"
    self.resList = {
        {file = AssetConfig.worldchampionmainpanel2v2, type = AssetType.Main},
        {file = self.btnEffect, type = AssetType.Main},
        {file = AssetConfig.agenda_textures, type = AssetType.Dep},
        {file = AssetConfig.classcardgroup_textures, type = AssetType.Dep},
        {file = AssetConfig.worldchampion_LevIcon, type = AssetType.Dep},
        {file = AssetConfig.heads, type = AssetType.Dep},
        {file = AssetConfig.teamres, type = AssetType.Dep},
        {file = AssetConfig.no1inworld_textures, type = AssetType.Dep},
        {file = AssetConfig.badge_icon, type = AssetType.Dep},
        {file = AssetConfig.attr_icon, type = AssetType.Dep},
    }
    self.refreshLev = false
    self.circleTipTimerId = 0
-- PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(shouhuData.classes))
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.Pos = self.Mgr[RoleManager.Instance.RoleData.classes]
    self.updatefunc = function()
        self:OnUpdate()
    end
    self.statuschangefunc = function()
        self:OnStatusChange()
    end

    self.hidemain = function()
        self:HideMainCon()
    end
    self.showmain = function()
        self.PlayerInfoPanel.gameObject:SetActive(false)
        self.refreshLev = true
        -- LuaTimer.Add(1000, function()
            self.Mgr:Require16407()
        -- end)
        self:OnUpdate()
        self.formationoperate:HideAttr()
        self:ShowMainCon()
    end

    self.onleave = function()
        self.Mgr:Require16403()
        self.model:CloseMainPanel2V2()
    end

    self.eventchange = function()
        self:OnEventChange()
    end
    -- self.refreshbadge = function (type)
    --     LuaTimer.Add(200, function()
    --         for i=1,5 do
    --             self:SetBadge(i,self.Mgr.matchdata.teammate[i],type)
    --         end
    --     end)
    -- end
    self.memberList = {}
    self.IamLeader = false
    self.index_position = {
        [1] = Vector2(-158, 61),
        [2] = Vector2(30, 61),
        [3] = Vector2(213, 61),
        [4] = Vector2(-24, 61),
        [5] = Vector2(161, 61),
    }
    self.animating = false
    self.strindex = 1

    self.MatchResultPos = {}

    self.modelPreViewSetting = {
        name = "WorldChampionMainPanel2V2"
        ,orthographicSize = 0.6
        ,width = 155
        ,height = 242
        ,offsetY = -0.35
    }
end

function WorldChampionMainPanel2V2:__delete()
    if self.formationoperate ~= nil then
        self.formationoperate:DeleteMe()
    end
    if self.ItemList ~= nil then
        for i,v in ipairs(self.ItemList) do
            v.Frame.sprite = nil
            v.Bg.sprite = nil
            v.SubFrame.sprite = nil
            v.Bar.sprite = nil
            v.bubbleObj:DeleteMe()
            GameObject.DestroyImmediate(v.Frame.gameObject)
            GameObject.DestroyImmediate(v.Bg.gameObject)
            GameObject.DestroyImmediate(v.SubFrame.gameObject)
            GameObject.DestroyImmediate(v.Bar.gameObject)
            if v.previewComposite ~= nil then
                v.previewComposite:DeleteMe()
            end
        end
        self.ItemList = nil
    end
    self:StopTimer()
    EventMgr.Instance:RemoveListener(event_name.team_update, self.updatefunc)
    EventMgr.Instance:RemoveListener(event_name.begin_fight, self.hidemain)
    EventMgr.Instance:RemoveListener(event_name.end_fight, self.showmain)
    EventMgr.Instance:RemoveListener(event_name.team_leave, self.onleave)

    if self.loop ~= nil then
        -- Tween.Instance:Cancel(self.loop)
        LuaTimer.Delete(self.loop)
    end
    if self.Titletimer ~= nil then
        -- Tween.Instance:Cancel(self.Titletimer)
        LuaTimer.Delete(self.Titletimer)
    end
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function WorldChampionMainPanel2V2:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.worldchampionmainpanel2v2))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(MainUIManager.Instance.MainUICanvasView.gameObject, self.gameObject)
    self.transform = t

    self.data = {}
    self.MainCon = self.transform:Find("MainCon")
    self.TitleTxt = self.transform:Find("TopObj/TDesc"):GetComponent(Text)
    if self.Titletimer ~= nil then
        LuaTimer.Delete(self.Titletimer)
        self.Titletimer = nil
    end
    self.bgPanel = self.transform:Find("bgPanel")
    self.bgPanel:GetComponent(Button).onClick:AddListener(function()
        if self.ismatching == false and #self.memberList ~= 5 then
            self.Mgr:Require16403()
            return
        end
        self:HideMainCon()
    end)
    self.TitleTxt.text = TI18N("武道大会2V2模式")
    self.TitleBtn = self.transform:Find("TopObj"):GetComponent(Button)
    self.TitleInfoBtn = self.transform:Find("TopObj/Rule"):GetComponent(Button)
    self.arrow = self.transform:Find("TopObj/arrow")
    self.arrow.rotation = Quaternion.Euler(0, 0, 0)
    self.TitleBtn.onClick:AddListener(function()
        if CombatManager.Instance.isFighting and self.MainCon.gameObject.activeSelf == false then
            return
        end
        if self.MainCon.gameObject.activeSelf then
            self:HideMainCon()
        else
            self:ShowMainCon()
        end
    end)
    self.TitleInfoBtn.onClick:AddListener(function() self:ShowRule() end)
    if MainUIManager.Instance.mainuitracepanel ~= nil then
        MainUIManager.Instance.mainuitracepanel:TweenHiden()
    end
    self.CardGroup = self.transform:Find("MainCon/CenterGameObject/ItemList")
    -- MainUIManager.Instance.MainUIIconView:hidebaseicon3()
    MainUIManager.Instance.MainUIIconView:Set_ShowTop(false, {17})
    MainUIManager.Instance.MainUIIconView:ShowCanvas(false)
    ChatManager.Instance.model:ShowCanvas(true)
    self.ItemList = {}
    for i=1,5 do
        local Item = self.CardGroup:Find(string.format("Item_%s",i))
        self.ItemList[i] = {}
        self.ItemList[i].transform = Item
        self.ItemList[i].localPosition = Item.localPosition
        self.ItemList[i].Bg = Item:Find("Bg"):GetComponent(Image) --
        self.ItemList[i].ClassBg = Item:Find("ClassBg"):GetComponent(Image)
        self.ItemList[i].Frame = Item:Find("Frame"):GetComponent(Image)  --
        self.ItemList[i].Frame.transform:GetComponent(Button).onClick:AddListener(function() self:ShowTips(i, Item) end)
        self.ItemList[i].SubFrame = Item:Find("SubFrame"):GetComponent(Image) --
        self.ItemList[i].Bar = Item:Find("Bar"):GetComponent(Image) --
        self.ItemList[i].Topdesc = Item:Find("Topdesc"):GetComponent(Text)
        self.ItemList[i].Topdesc1 = Item:Find("Topdesc1"):GetComponent(Text)
        self.ItemList[i].PetImage = Item:Find("PetImage"):GetComponent(Image)
        self.ItemList[i].PosDesc = Item:Find("PosDesc"):GetComponent(Text)
        self.ItemList[i].PosDescicon = Item:Find("PosDesc/icon"):GetComponent(Image)
        self.ItemList[i].MatchDesc = Item:Find("MatchDesc"):GetComponent(Text)
        self.ItemList[i].InviteObj = Item:Find("InviteObj").gameObject
        self.ItemList[i].InviteBtn = Item:Find("InviteObj/InviteBtn"):GetComponent(Button)
        self.ItemList[i].ClassImage = Item:Find("ClassImage"):GetComponent(Image)
        self.ItemList[i].LevText = Item:Find("ClassImage/LevText"):GetComponent(Text)
        self.ItemList[i].TalkBubble = Item:Find("TalkBubble").gameObject
        self.ItemList[i].bubbleObj = WorldChampionTalkBubble.New(Item:Find("TalkBubble").gameObject)
        self.ItemList[i].LeaderIcon = Item:Find("LeaderIcon")
        self.ItemList[i].Nobody = Item:Find("Nobody").gameObject
        self.ItemList[i].Preview = Item:Find("Preview")
        self.ItemList[i].LvlupPro = Item:Find("LvlupPro").gameObject
        self.ItemList[i].threeGame = self.ItemList[i].LvlupPro.transform:Find("threegame")
        self.ItemList[i].fourGame = self.ItemList[i].LvlupPro.transform:Find("fourgame")
        self.ItemList[i].LvlupPro:GetComponent(Button).onClick:AddListener(function ()
            local lev = self.Mgr.rankData.rank_lev
            if lev <= #DataTournament.data_get_promotion_combat then
                local needwin = DataTournament.data_get_promotion_combat[lev].need_win
                local name = DataTournament.data_get_promotion_combat[lev+1].name
                TipsManager.Instance:ShowText({gameObject = self.ItemList[i].LvlupPro,itemData = {string.format(TI18N("1、当前段位达到<color='#ffff00'>100分</color>后进入晋级赛\n2、累计<color='#ffff00'>获胜%s次</color>后即可晋级<color='#ffff00'>%s</color>\n3、晋级过程中会累计一定<color='#ffff00'>积分</color>，将在\n晋级成功后直接获得，不影响上分速度哟"),needwin,name)}})
            end
        end)
    end

    local badgeList = self.transform:Find("MainCon/CenterGameObject/BadgeList")
    for i=1,5 do
        self.ItemList[i].badgeImgBg = badgeList:GetChild(i-1)
        self.ItemList[i].badgeImg = badgeList:GetChild(i-1):GetChild(0):GetComponent(Image)
        self.ItemList[i].badgeBtn = badgeList:GetChild(i-1):GetChild(0):GetComponent(Button)
    end

    self.ExitBtn = self.transform:Find("MainCon/CenterGameObject/ExitBtn"):GetComponent(Button)
    self.RankBtn = self.transform:Find("MainCon/CenterGameObject/RankBtn"):GetComponent(Button)
    self.SingleMatchBtn = self.transform:Find("MainCon/CenterGameObject/SingleMatchBtn"):GetComponent(Button)
    self.timesText = self.transform:Find("MainCon/CenterGameObject/Times"):GetComponent(Text)
    self.SingleEffect = GameObject.Instantiate(self:GetPrefab(self.btnEffect))
    self.SingleEffect.transform:SetParent(self.SingleMatchBtn.gameObject.transform)
    self.SingleEffect.transform.localScale = Vector3(2, 0.68, 1)
    self.SingleEffect.transform.localPosition = Vector3(-64, -16, -1000)
    Utils.ChangeLayersRecursively(self.SingleEffect.transform, "UI")
    -- self.SingleEffect:SetActive(false)

    self.DoubleMatchBtn = self.transform:Find("MainCon/CenterGameObject/DoubleMatchBtn"):GetComponent(Button)
    self.DoubleEffect = GameObject.Instantiate(self.SingleEffect)
    self.DoubleEffect.transform:SetParent(self.DoubleMatchBtn.gameObject.transform)
    self.DoubleEffect.transform.localScale = Vector3(1.8, 0.68, 1)
    self.DoubleEffect.transform.localPosition = Vector3(-54, -16, -1000)
    Utils.ChangeLayersRecursively(self.DoubleEffect.transform, "UI")
    -- self.DoubleEffect:SetActive(false)

    self.CancleMatchBtn = self.transform:Find("MainCon/CenterGameObject/CancleMatchBtn"):GetComponent(Button)
    self.CancleMatchBtnText = self.transform:Find("MainCon/CenterGameObject/CancleMatchBtn/Text"):GetComponent(Text)
    self.TeamBtn = self.transform:Find("MainCon/CenterGameObject/TeamBtn"):GetComponent(Button)
    self.TeamBtnRed = self.transform:Find("MainCon/CenterGameObject/TeamBtn/Red").gameObject
    self.TeamChatBtn = self.transform:Find("MainCon/CenterGameObject/TeamChatBtn"):GetComponent(Button)
    self.FormationText = self.transform:Find("MainCon/CenterGameObject/FormationText"):GetComponent(Text)
    self.RestrainText = self.transform:Find("MainCon/CenterGameObject/FormationText/restrainText"):GetComponent(Text)
    self.RestrainText.transform:GetComponent(Button).onClick:AddListener(function()
        local tipsText = {
            TI18N("1.黄色字体为<color='#ffff00'>强克制</color>，绿色字体为<color='#00ff00'>弱克制</color>"),
            TI18N("2.强克制：对敌方所造成的伤害<color='#ffff00'>提升5%</color>，同时受到敌方的伤害<color='#ffff00'>降低5%</color>"),
            TI18N("3.弱克制：对敌方所造成的伤害<color='#ffff00'>提升5%</color>")
        }
        TipsManager.Instance:ShowText({gameObject = self.RestrainText.gameObject, itemData = tipsText})
    end)
    self.FormationChangeBtn = self.transform:Find("MainCon/CenterGameObject/FormationChangeBtn"):GetComponent(Button)
    self.FormatChangeGuard = self.transform:Find("MainCon/FormatChangeGuard").gameObject
    self.TipCircleCon = self.transform:Find("MainCon/TipCircleCon").gameObject
    self.TipCircleTxt = self.transform:Find("MainCon/TipCircleCon/TxtCricle"):GetComponent(Text)
    self.TipCircleMsg = MsgItemExt.New(self.TipCircleTxt, 279, 18, 23)
    self.TipCircleCon:SetActive(false)

    self.ExitBtn.onClick:AddListener(function() self:OnExit() end)
    self.RankBtn.onClick:AddListener(function() self:OnRank() end)
    self.SingleMatchBtn.onClick:AddListener(function() self:OnSingle() end)
    self.DoubleMatchBtn.onClick:AddListener(function() self:OnDouble() end)
    self.CancleMatchBtn.onClick:AddListener(function() self:OnCancelMatch() end)
    self.TeamBtn.onClick:AddListener(function() self:OnTeamMgr() end)
    self.TeamChatBtn.onClick:AddListener(function() self:OnTeamChat() end)
    self.FormationChangeBtn.onClick:AddListener(function()
        if self.formationoperate.isshow then
            self:OnTeamMgr()
        end
        self.formationoperate:HideBtn()
        self.FormatChangeGuard:SetActive(self.FormatChangeGuard.activeSelf == false)
    end)
    self.FormatChangeGuard.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self.FormatChangeGuard:SetActive(false) end)

    self.InvitePanel = self.transform:Find("MainCon/InviteFriendPanel").gameObject
    self.FriendCon = self.transform:Find("MainCon/InviteFriendPanel/FriendCon/Mask/Grid")
    self.FriendItem = self.FriendCon:Find("friendItem").gameObject
    self.FriendItem:SetActive(false)
    self.friendInviteBtn = self.InvitePanel.transform:Find("FriendCon/Invitebtn"):GetComponent(Button)
    self.friendInviteBtn.onClick:AddListener(function() self:OnInvite() end)
    self.noFriendText = self.transform:Find("MainCon/InviteFriendPanel/FriendCon/Mask/noFriendText").gameObject
    self.NoSelectText = self.transform:Find("MainCon/InviteFriendPanel/FriendCon/NoSelectText").gameObject
    self.FormationSet = self.transform:Find("MainCon/FormationSet").gameObject

    self.formationoperate = WorldChampionFormationOP2V2.New(self.FormationSet, self)

    self.InvitePanel.transform:GetComponent(Button).onClick:AddListener(function()
        self.InvitePanel:SetActive(false)
    end)


    self.memberList = {}
    if TeamManager.Instance:HasTeam() and TeamManager.Instance:MemberCount() == 2 and TeamManager.Instance:GetMemberOrderList()[2].status == 2 then
        self.memberList = TeamManager.Instance:GetMemberOrderList()
    else
        self.memberList = {
            [1] = {
                rid = RoleManager.Instance.RoleData.id,
                name = RoleManager.Instance.RoleData.name,
                platform = RoleManager.Instance.RoleData.platform,
                zone_id = RoleManager.Instance.RoleData.zone_id,
                sex = RoleManager.Instance.RoleData.sex,
                classes = RoleManager.Instance.RoleData.classes,
                lev = RoleManager.Instance.RoleData.lev,
                looks = RoleManager.Instance.RoleData.looks,
                rank_lev = self.Mgr.rankData.rank_lev,
                rank_point = self.Mgr.rankData.rank_point,
                show_badge_id = self.Mgr.rankData.show_badge_id,
                }
        }
    end
    for i=1,5 do
        local data = self.memberList[i]
        self:SetItem(i, data)
        --self:SetBadge(i, data)

    end
    self.refreshLev = false
    self:CancleMatchSuccess()
    self:UpdatePosDesc()
    -- self:InitFriendList()
    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Follow then
        self.ExitBtn.transform:GetComponent("Image").sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
    end

    self.DescInfoPanel = self.transform:Find("MainCon/DescInfoPanel")
    self.ruletextcontent = self.DescInfoPanel:Find("BG/Text"):GetComponent(Text)
    self.RuleExt = MsgItemExt.New(self.ruletextcontent, 410, 18, 30)
    local rule = TI18N("1.<color='#ffff00'>跨服</color>武道会将划分为：70级精锐组、80级骁勇组、90级英雄组独立进行\n2.比武采用5V5形式，可单人匹配或邀请一名同级别好友进行双排\n3.战斗获胜/失败将获得/扣除相应武道胜点，累计100武道胜点将开启晋级战\n4.晋级战获胜将提升等级，共有1-10个常规等级和传说-美猴王级别\n5.级别越高，赛季结算奖励越丰厚，所有服玩家都能看到你的风采喔")
    self.RuleExt:SetData(rule)
    self.DescInfoPanel:GetComponent(Button).onClick:AddListener(function() self.DescInfoPanel.gameObject:SetActive(false) end)

    self.PlayerInfoPanel = self.transform:Find("MainCon/PlayerInfoPanel")
    self.PlayerInfoPanel:GetComponent(Button).onClick:AddListener(function() self.PlayerInfoPanel.gameObject:SetActive(false) end)
    self.Mgr:Require16407()
    self:ShowAnimate()
    if CombatManager.Instance.isFighting then
        self:HideMainCon()
    end
    self.loop = LuaTimer.Add(0,800, function() self:SetMatchText() end)
    EventMgr.Instance:AddListener(event_name.team_update, self.updatefunc)
    EventMgr.Instance:AddListener(event_name.begin_fight, self.hidemain)
    EventMgr.Instance:AddListener(event_name.end_fight, self.showmain)
    EventMgr.Instance:AddListener(event_name.team_leave, self.onleave)
    -- self.loop = Tween.Instance:ValueChange(1, 3, 2.4, function()end, LeanTweenType.linear, function(value) self:SetMatchText(value) end):setLoopPingPong()
end

function WorldChampionMainPanel2V2:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function WorldChampionMainPanel2V2:OnOpen()
    --self.Mgr.onJoin:AddListener(self.refreshbadge)
    self:ShowMainCon()
    self:RemoveAllListeners()
end

function WorldChampionMainPanel2V2:OnHide()
    --self.Mgr.onJoin:RemoveListener(self.refreshbadge)
    self:RemoveAllListeners()
end

function WorldChampionMainPanel2V2:RemoveAllListeners()
end

function WorldChampionMainPanel2V2:SetItem(index, data)
    if self.ItemList == nil then
        return
    end
    local item = self.ItemList[index]
    if data == nil then
        data = self.Mgr.matchdata.teammate[index]
    end

    -- data = {curlev = Random.Range(1,11),lev = Random.Range(50,90), rank_point = 46, maxexp = 100, class = Random.Range(1,5), sex = Random.Range(0,1), name = "阿斯顿萨",}
    if data ~= nil or index == 1 then
        if data.rank_lev == nil then
            data.rank_lev = 1
        end
        local styledata = DataTournament.data_list[data.rank_lev]
        if styledata == nil then
            styledata = DataTournament.data_list[1]
        end
        if data.rank_point == nil then
            data.rank_point = 0
        end
        -- item.ClassBg.sprite = self.assetWrapper:GetSprite(AssetConfig.classcardgroup_textures, string.format("%s_%s", data.classes, data.sex))
        -- item.ClassBg.gameObject:SetActive(true)
        item.ClassBg.gameObject:SetActive(false)

        self:UpdateModel(item, data)

        item.Bg.sprite = self.assetWrapper:GetSprite(AssetConfig.classcardgroup_textures, string.format("bg%s", styledata.stylelev))
        item.Frame.sprite = self.assetWrapper:GetSprite(AssetConfig.classcardgroup_textures, styledata.stylelev)
        if data.rid == RoleManager.Instance.RoleData.id and data.platform == RoleManager.Instance.RoleData.platform and data.zone_id == RoleManager.Instance.RoleData.zone_id then
            item.SubFrame.sprite = self.assetWrapper:GetSprite(AssetConfig.classcardgroup_textures, string.format("f%s", styledata.stylelev))
            local fill = data.rank_point%100/100
            if fill == 0 and data.rank_point/100 == data.rank_lev then
                fill = 1
            elseif data.rank_point/100 > data.rank_lev then
                fill = 1
            end
            item.Bar.fillAmount = fill
            if (data.rank_point%100 == 0 or data.rank_point/100 > data.rank_lev) and data.rank_lev == 10 then
                item.Topdesc.text = TI18N("登峰造极")
                item.Topdesc1.text = TI18N("登峰造极")
                item.LvlupPro.gameObject:SetActive(false)
            elseif (data.rank_point%100 == 0 or data.rank_point/100 > data.rank_lev) and data.rank_lev == 11 then
                item.Topdesc.text = TI18N("星辰王者")
                item.Topdesc1.text = TI18N("星辰王者")
                item.LvlupPro.gameObject:SetActive(false)
            elseif data.rank_point%100 == 0 and data.rank_point > 0 and data.rank_point/100 == data.rank_lev then
                item.Topdesc.text = TI18N("晋级赛")
                item.Topdesc1.text = TI18N("晋级赛")
                item.LvlupPro.gameObject:SetActive(true)
                local needwin = DataTournament.data_get_promotion_combat[data.rank_lev].need_win
                local win = self.Mgr.rankData.promotion_win
                local t
                if needwin < 4 then
                    t = item.threeGame
                    for i=1,3 do
                        t:Find(tostring(i)):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworld_textures,"undone")
                    end
                    if needwin == 2 then
                        t:Find(tostring(3)):GetComponent(Image).color = Color(1, 1, 1, 0.2)
                    end
                    item.threeGame.gameObject:SetActive(true)
                    item.fourGame.gameObject:SetActive(false)
                else
                    t = item.fourGame
                    for i=1,4 do
                        t:Find(tostring(i)):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworld_textures,"undone")
                    end
                    item.threeGame.gameObject:SetActive(false)
                    item.fourGame.gameObject:SetActive(true)
                end
                if win > 0 then
                    for i=1,win do
                        t:Find(tostring(i)):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworld_textures,"done")
                    end
                end
            else
                item.Topdesc.text = string.format("%s/%s", data.rank_point%100, 100)
                item.Topdesc1.text = string.format("%s/%s", data.rank_point%100, 100)
                item.LvlupPro.gameObject:SetActive(false)
            end
            item.Bar.gameObject:SetActive(true)
            item.SubFrame.gameObject:SetActive(true)
            item.Topdesc.gameObject:SetActive(true)
            item.Topdesc1.gameObject:SetActive(true)

        else
            item.Topdesc.gameObject:SetActive(false)
            item.Topdesc1.gameObject:SetActive(false)
            item.Bar.gameObject:SetActive(false)
            item.SubFrame.gameObject:SetActive(false)
            item.LvlupPro.gameObject:SetActive(false)
        end
        -- if self.animating == false then
            item.PetImage.gameObject:SetActive(true)
        -- end
        item.ClassImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(data.classes))
        -- item.LevText.text = string.format("Lv%s %s", data.lev, KvData.classes_name[data.classes])
        local color = Color.white
        local looks = self.Mgr:GetLooks(data.rid, data.platform, data.zone_id)
        if looks ~= nil then
            for i,v in ipairs(looks) do
                if v.looks_type == SceneConstData.looktype_lev_break then -- 等级突破
                    if v.looks_val == 1 then
                        color = ColorHelper.colorObject[10]
                    elseif v.looks_type == 2 then
                        color = ColorHelper.colorObject[11]
                    end
                end
            end
        end
        item.LevText.color = color
        item.LevText.text = data.name
        item.ClassImage.gameObject:SetActive(true)
        item.PosDesc.gameObject:SetActive(false)
        item.MatchDesc.gameObject:SetActive(false)
        item.InviteObj:SetActive(false)
        item.Nobody.gameObject:SetActive(false)
        if data.rank_lev ~= nil and data.best_rank_lev ~= nil then
            if data.rank_lev == 0 then
                item.PetImage.sprite = self.assetWrapper:GetSprite(AssetConfig.worldchampion_LevIcon, 1)
            else
                item.PetImage.sprite = self.assetWrapper:GetSprite(AssetConfig.worldchampion_LevIcon, data.rank_lev)
            end
        else
            item.PetImage.sprite = self.assetWrapper:GetSprite(AssetConfig.worldchampion_LevIcon, 1)
        end
        if not data.isGuard and (data.rank_lev == nil or data.best_rank_lev == nil or self.refreshLev) then
            self.Mgr:Require16405(data.rid, data.platform, data.zone_id)
        end



        if data.show_badge_id ~= nil then
            local badge_id = data.show_badge_id
            if badge_id == 0 then
                print("<color='#ffff00'>徽章ID是0</color>")
                item.badgeImgBg.gameObject:SetActive(false)
            else
                local source_id = DataAchieveShop.data_list[badge_id].source_id
                item.badgeImg.sprite = self.assetWrapper:GetSprite(AssetConfig.badge_icon,tostring(DataAchieveShop.data_list[ZoneManager.Instance:ResIdToId(source_id)].source_id))
                item.badgeBtn.onClick:RemoveAllListeners()
                item.badgeBtn.onClick:AddListener(function() self:BadgeShow({badge_id=badge_id,classes=data.classes}) end)
                item.badgeImgBg.gameObject:SetActive(false)
                LuaTimer.Add(1000,function ()
                    if not BaseUtils.isnull(self.gameObject) and self.ItemList ~= nil then
                        self.ItemList[index].badgeImgBg.gameObject:SetActive(true)
                    end
                end)
            end
        else
            item.badgeImgBg.gameObject:SetActive(false)
        end

        if data.isGuard then
            item.PetImage.gameObject:SetActive(false)
            item.badgeImgBg.gameObject:SetActive(false)
            return
        else
            item.PetImage.gameObject:SetActive(true)
        end

    else
        item.Bg.sprite = self.assetWrapper:GetSprite(AssetConfig.classcardgroup_textures, string.format("bg%s", 1))
        item.Frame.sprite = self.assetWrapper:GetSprite(AssetConfig.classcardgroup_textures, 1)
        item.ClassBg.gameObject:SetActive(false)
        item.Preview.gameObject:SetActive(false)
        item.Topdesc.gameObject:SetActive(false)
        item.Topdesc1.gameObject:SetActive(false)
        item.SubFrame.gameObject:SetActive(false)
        item.PetImage.gameObject:SetActive(false)
        item.ClassImage.gameObject:SetActive(false)
        item.PosDesc.gameObject:SetActive(true)
        item.ClassImage.gameObject:SetActive(false)
        item.Bar.gameObject:SetActive(false)
        item.Nobody.gameObject:SetActive(true)
        item.InviteObj.gameObject:SetActive(false)
        item.LvlupPro.gameObject:SetActive(false)
        -- item.badgeImg.gameObject:SetActive(false)
        -- if RoleManager.Instance.RoleData.event ~= 25 then
        --     item.MatchDesc.gameObject:SetActive(false)
        --     -- if index == 2 then
        --     --     item.InviteObj.gameObject:SetActive(true)
        --     --     item.InviteObj.transform:Find("InviteBtn"):GetComponent(Button).onClick:RemoveAllListeners()
        --     --     item.InviteObj.transform:Find("InviteBtn"):GetComponent(Button).onClick:AddListener(function()
        --     --         self.InvitePanel:SetActive(true)
        --     --     end)
        --     -- else
        --     -- end
        -- else
        --     item.MatchDesc.gameObject:SetActive(true)
        -- end
    end
    item = nil
end

function WorldChampionMainPanel2V2:OnUpdate()
    -- BaseUtils.dump(self.Mgr.matchdata,"???????")
    if self.Mgr.matchdata ~= nil and self.Mgr.matchdata.is_matching == 0 and #self.Mgr.matchdata.teammate > 1 then
        return
    end

    if #self.Mgr.matchdata.teammate == 2 then
        self:MatchResult(self.Mgr.matchdata)
        if CombatManager.Instance.isFighting == false then
            self.formationoperate:ShowAttr()
            self:ShowMainCon()
            self:ShowAnimate()
        end
    elseif TeamManager.Instance:HasTeam() and TeamManager.Instance:MemberCount() >= 2 and TeamManager.Instance:GetMemberOrderList()[2].status == 2 then
        self.memberList = TeamManager.Instance:GetMemberOrderList()
        self.IamLeader = TeamManager.Instance:IsSelfCaptin()
    else
        self.memberList = {
            [1] = {
                rid = RoleManager.Instance.RoleData.id,
                name = RoleManager.Instance.RoleData.name,
                platform = RoleManager.Instance.RoleData.platform,
                zone_id = RoleManager.Instance.RoleData.zone_id,
                sex = RoleManager.Instance.RoleData.sex,
                classes = RoleManager.Instance.RoleData.classes,
                lev = RoleManager.Instance.RoleData.lev,
                looks = RoleManager.Instance.RoleData.looks,
                rank_lev = self.Mgr.rankData.rank_lev,
                rank_point = self.Mgr.rankData.rank_point,
                show_badge_id = self.Mgr.show_badge_id
                }
        }
        self.IamLeader = true
    end
    -- BaseUtils.dump(self.memberList,"???????")
    self.ItemList[1].LeaderIcon.gameObject:SetActive(false)
    for i=1,5 do
        local data = self.memberList[i]
        self:SetItem(i, data)
        --self:SetBadge(i,data)
    end
    self.refreshLev = false
    if self.Mgr.matchdata == nil or self.Mgr.matchdata.is_matching ~= 1 then
        self:CancleMatchSuccess()
    end
    self:UpdatePosDesc()
end

function WorldChampionMainPanel2V2:OnStatusChange()
    -- body
end

function WorldChampionMainPanel2V2:OnExit()
    if self.ismatching then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("当前正在匹配中，关闭将直接退出匹配，是否确定退出？")
        data.sureLabel = TI18N("确认")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function()
            self.Mgr:Require16408()
            self.Mgr:Require16403()
        end

        NoticeManager.Instance:ConfirmTips(data)
        return
    end
    -- if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Follow then
    --     TeamManager.Instance:Send11708()
    --     return
    -- end
    self.Mgr:Require16403()
end

function WorldChampionMainPanel2V2:OnRank()
    WorldChampionManager.Instance.model:OpenMainWindow({2})
end

function WorldChampionMainPanel2V2:OnSingle()
    self.Mgr:Require16402()
end

function WorldChampionMainPanel2V2:OnDouble()
    self.Mgr:Require16402()
end

function WorldChampionMainPanel2V2:OnCancelMatch()
    self.Mgr:Require16408()
end

function WorldChampionMainPanel2V2:OnTeamMgr()
    if self.IamLeader then
        self.Mgr.first = false
        self.TeamBtnRed:SetActive(false)
        if self.formationoperate.isshow then
            self.FormatChangeGuard:SetActive(false)
            self.formationoperate:Hide()
            -- self.formationoperate:ShowBtn()
            self.formationoperate:HideBtn()
            self.TeamBtn.transform:Find("Text"):GetComponent(Text).text = TI18N("队伍调整")
            self.TeamBtn.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        else
            self.formationoperate:Show()
            self.formationoperate:ShowBtn()
            self.TeamBtn.transform:Find("Text"):GetComponent(Text).text = TI18N("完成调整")
            self.TeamBtn.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        end
    else
        local str = TI18N("只有<color='#ffff00'>队长</color>可以调整阵法和站位，是否<color='#ffff00'>顶替队长</color>？（顶替队长将发起投票）")

        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = str
        data.sureLabel = TI18N("顶替队长")
        data.cancelLabel = TI18N("取消")
        data.blueSure = true
        data.sureCallback = function() self.Mgr:Require16409()
        end
        NoticeManager.Instance:ConfirmTips(data)
    end
end

function WorldChampionMainPanel2V2:OnTeamChat()
    ChatManager.Instance.model:ShowChatWindow({2})
end

function WorldChampionMainPanel2V2:ShowTips(index, gameObject)
    local data = self.memberList[index]
    local ap = self.index_position[index]
    self.PlayerInfoPanel.transform.anchoredPosition = ap
    -- BaseUtils.dump(data, "点卡tips的数据")
    if data ~= nil then
    	if data.zone_id == 0 then --如果是守护
            if self.IamLeader then
                self.formationoperate:ShowSelectGuardPanel(index)
            else
    	    	TipsManager.Instance:ShowText({gameObject = gameObject, itemData = {
    	    					TI18N("点击<color='#ffff00'>队伍调整</color>")
    	                    	, TI18N("可更换守护、调整站位")}
    	                })
            end
	    else
	        data.best_rank_lev = (data.best_rank_lev ~= nil and data.best_rank_lev ~= 0 )and data.best_rank_lev or 1
	        -- data.best_rank_lev = math.min(data.best_rank_lev, 9)
	        data.rank_lev = (data.rank_lev ~= nil and data.rank_lev ~= 0 )and data.rank_lev or 1
	        data.best_win_count = data.best_win_count ~= nil and data.best_win_count or 0
	        data.win_count = data.win_count ~= nil and data.win_count or 0

	        local color = Color.white
	        local looks = self.Mgr:GetLooks(data.rid, data.platform, data.zone_id)
	        if looks ~= nil then
	            for i,v in ipairs(looks) do
	                if v.looks_type == SceneConstData.looktype_lev_break then -- 等级突破
	                    if v.looks_val == 1 then
	                        color = ColorHelper.colorObject[10]
	                    elseif v.looks_type == 2 then
	                        color = ColorHelper.colorObject[11]
	                    end
	                end
	            end
	        end
	        self.PlayerInfoPanel:Find("Info1/Text2"):GetComponent(Text).color = color
	        self.PlayerInfoPanel:Find("Info1/Text2"):GetComponent(Text).text = data.name

	        self.PlayerInfoPanel:Find("Info2/Text2"):GetComponent(Text).text = DataTournament.data_list[data.rank_lev].name
	        local rate = 0
	        if data.combat_count ~= nil and data.combat_count > 0 then
	            rate = math.ceil(data.win_count/data.combat_count*100)
	        end
	        self.PlayerInfoPanel:Find("Info3/Text2"):GetComponent(Text).text = string.format("<color='#00ff00'>%s%%</color>(%s/%s)", rate, data.win_count, data.combat_count, rate)
	        -- self.PlayerInfoPanel:Find("Info3/Text2"):GetComponent(Text).text = string.format("<color='#00ff00'>%s胜</color>(总%s胜)" , data.win_count, data.best_win_count)
	        self.PlayerInfoPanel:Find("Info4/Text2"):GetComponent(Text).text = DataTournament.data_list[data.best_rank_lev].name
	        self.PlayerInfoPanel:Find("Info6/Text2"):GetComponent(Text).text = tostring(data.best_win_count)
	        self.PlayerInfoPanel:Find("Info7/Text2"):GetComponent(Text).text = data.liked ~= nil and tostring(data.liked) or "0"
	        local best_partner = TI18N("无")
	        if data.best_partner ~= nil and data.best_partner[1]~= nil and data.best_partner[1].partner_name ~= nil then
	            best_partner = data.best_partner[1].partner_name
	        end
	        self.PlayerInfoPanel:Find("Info5/Text2"):GetComponent(Text).text = best_partner
	        self.PlayerInfoPanel.gameObject:SetActive(true)
	    end
    elseif self.ItemList[index].PosDesc.gameObject.activeSelf then
        if self.ItemList[index].PosDesc.text == TI18N("玩家") then
            TipsManager.Instance:ShowText({gameObject = self.ItemList[index].PosDesc.gameObject, itemData = {
            TI18N("将匹配另一名玩家，"),
            TI18N("匹配后请耐心等待")
            }})
        elseif self.ItemList[index].PosDesc.text == TI18N("守护") then
            TipsManager.Instance:ShowText({gameObject = self.ItemList[index].PosDesc.gameObject, itemData = {
            TI18N("匹配完成后守护上阵，"),
            TI18N("队长可任意调整")
            }})
        end
    end
end

--更新段位信息
function WorldChampionMainPanel2V2:SetLevInfo(data)
    if self.ItemList == nil then
        return
    end

    -- 组装守护数据
    self:MakeGuardData()

    for i,v in ipairs(self.memberList) do
        if data.rid == v.rid and data.platform == v.platform and data.zone_id == v.zone_id then
            self.memberList[i].rank_point = data.rank_point
            self.memberList[i].best_rank_lev = 0
            self.memberList[i].rank_lev = data.rank_lev
            self.memberList[i].show_badge_id = data.show_badge_id
            for k,v in pairs(data) do
                if v ~= "" then
                    self.memberList[i][k] = v
                end
            end
            self:SetItem(i, self.memberList[i])
            --self:SetBadge(i, self.memberList[i])
        end
    end
    self.refreshLev = false
end

--设置徽章信息
-- function WorldChampionMainPanel2V2:SetBadgeInfo(data)
--     local item = self.ItemList[data.order]
--     local badge_id = data.badge_id
--     if badge_id == 0 then
--         item.badgeImgBg.gameObject:SetActive(false)
--     else
--         local source_id = DataAchieveShop.data_list[badge_id].source_id
--         item.badgeImg.sprite = self.assetWrapper:GetSprite(AssetConfig.badge_icon, source_id)
--         item.badgeImgBg.gameObject:SetActive(true)
--         item.badgeBtn.onClick:RemoveAllListeners()
--         item.badgeBtn.onClick:AddListener(function() self:BadgeShow({badge_id=badge_id,classes=data.classes}) end)
--     end
-- end

-- function WorldChampionMainPanel2V2:SetBadge(index, data,type)
--     if self.ItemList == nil then
--         return
--     end
--     local item = self.ItemList[index]
--     if data == nil then
--         data = self.Mgr.matchdata.teammate[index]
--     end

--     if type == 1 then

--         if TeamManager.Instance:HasTeam() and TeamManager.Instance:MemberCount() == 2 and TeamManager.Instance:GetMemberOrderList()[2].status == 2 then
--             data = TeamManager.Instance:GetMemberOrderList()[index]
--         end
--     end

--     if data ~= nil or index == 1 then
--         if data.isGuard then
--             item.badgeImgBg.gameObject:SetActive(false)
--             return
--         else
--             item.badgeImgBg.gameObject:SetActive(true)
--         end
--         local roleData = RoleManager.Instance.RoleData
--         if data.rid == roleData.id and data.platform == roleData.platform and data.zone_id == roleData.zone_id then
--             local badge_id = self.model.curUse
--             if badge_id == 0 then
--                 item.badgeImgBg.gameObject:SetActive(false)
--             else
--                 item.badgeImgBg.gameObject:SetActive(true)
--                 local source_id = DataAchieveShop.data_list[badge_id].source_id
--                 item.badgeImg.sprite = self.assetWrapper:GetSprite(AssetConfig.badge_icon, source_id)
--                 item.badgeBtn.onClick:RemoveAllListeners()
--                 item.badgeBtn.onClick:AddListener(function() self:BadgeShow({badge_id=badge_id,classes=data.classes}) end)
--             end
--         else
--             self.Mgr:Require16438(data.rid, data.platform, data.zone_id,index)
--         end
--     else
--         item.badgeImgBg.gameObject:SetActive(false)
--     end
--     item = nil
-- end


--开始匹配成功
function WorldChampionMainPanel2V2:MatchSuccess()
    if self.ItemList == nil then
        return
    end
    self.ismatching = true
    self.ItemList[1].LeaderIcon.gameObject:SetActive(false)
    self.SingleMatchBtn.gameObject:SetActive(false)
    self.timesText.gameObject:SetActive(false)
    self.DoubleMatchBtn.gameObject:SetActive(false)
    -- self.ExitBtn.gameObject:SetActive(false)
    self.ExitBtn.transform:GetComponent("Image").sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
    -- if TeamManager.Instance:IsSelfCaptin() or not TeamManager.Instance:HasTeam() then
        self.CancleMatchBtn.gameObject:SetActive(true)
    -- end

    for i=#self.memberList,4 do
        self.ItemList[i+1].MatchDesc.gameObject:SetActive(true)
    end
    -- if #self.memberList == 1 then
    --     self.ItemList[2].InviteObj:SetActive(true)
    -- else
    --     self.ItemList[2].InviteObj:SetActive(false)
    -- end
    self.ItemList[2].InviteObj:SetActive(false)
    if self.Titletimer ~= nil then
        LuaTimer.Delete(self.Titletimer)
        self.Titletimer = nil
    end
    self.TitleTxt.text = TI18N("武道会正在匹配中")

    --匹配中
    self:UpdateCircleTips(1)
end

-- 取消匹配成功
function WorldChampionMainPanel2V2:CancleMatchSuccess()
    --取消匹配
    self:UpdateCircleTips(3)

    -- local matchdata = self.Mgr.matchdata
    -- if matchdata.is_matching == 1 then
    --     return
    -- end
    if self.ItemList== nil then
        return
    end
    -- self.ItemList[1].LeaderIcon.gameObject:SetActive(false)
    self.ismatching = false
    if #self.memberList == 1 then
        self.SingleMatchBtn.gameObject:SetActive(true)
        self.DoubleMatchBtn.gameObject:SetActive(false)
    else
        self.SingleMatchBtn.gameObject:SetActive(false)
        self.DoubleMatchBtn.gameObject:SetActive(true)
    end
    self.timesText.gameObject:SetActive(true)
    if self.Mgr.matchdata ~= nil then
        self.timesText.text = string.format(TI18N("挑战次数<color='#ffff00'>(%s/%s)</color>"), tostring(self.Mgr.matchdata.max_join - self.Mgr.matchdata.day_matched), tostring(self.Mgr.matchdata.max_join))
    end
    self.ExitBtn.gameObject:SetActive(true)
    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Follow then
        -- self.ExitBtn.gameObject:SetActive(false)
        self.ExitBtn.transform:GetComponent("Image").sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.SingleMatchBtn.gameObject:SetActive(false)
        self.DoubleMatchBtn.gameObject:SetActive(false)
    else
        self.ExitBtn.transform:GetComponent("Image").sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
    end
    self.CancleMatchBtn.gameObject:SetActive(false)
    for i=1, 5 do
        self.ItemList[i].MatchDesc.gameObject:SetActive(false)
    end
    self.RankBtn.gameObject:SetActive(true)
    self.TeamBtn.gameObject:SetActive(false)
    if self.IamLeader == false then
        self.formationoperate:HideBtn()
    end
    self.TeamChatBtn.gameObject:SetActive(false)
    self.FormationText.text = ""
    self.RestrainText.gameObject:SetActive(false)
    self.FormationChangeBtn.gameObject:SetActive(false)
    self.TitleTxt.text = TI18N("武道大会2V2模式")
end

function WorldChampionMainPanel2V2:InitFriendList()
    local setting12 = {
        axis = BoxLayoutAxis.Y
        ,spacing = 5
        ,Left = 1
        ,Top = 4
    }
    self.Layout2 = LuaBoxLayout.New(self.FriendCon, setting12)
    local list = FriendManager.Instance:GetOnlineList()
    local mylev = math.floor(RoleManager.Instance.RoleData.lev/10)
    local has = false
    for i,v in ipairs(list) do
        if mylev == math.floor(v.lev/10) then
            has = true
            local frienditem = GameObject.Instantiate(self.FriendItem)
            -- frienditem.transform:SetParent(self.FriendCon)
            self.Layout2:AddCell(frienditem)
            frienditem.transform.localScale = Vector3.one
            frienditem:SetActive(true)
            local key = BaseUtils.Key(v.classes,v.sex)
            frienditem.transform:Find("Slot/icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.heads, key)
            frienditem.transform:Find("Slot/icon").gameObject:SetActive(true)
            if v.sex > 0 then
                frienditem.transform:Find("male").gameObject:SetActive(true)
            else
                frienditem.transform:Find("male").gameObject:SetActive(false)
            end
            frienditem.transform:Find("classes"):GetComponent(Text).text = v.name
            -- frienditem.transform:Find("name"):GetComponent(Text).text = v.name
            frienditem.transform:GetComponent(Button).onClick:AddListener(function ()
                if self.lastSelect == nil then
                    self.NoSelectText:SetActive(false)
                    self.friendInviteBtn.gameObject:SetActive(true)
                end
                self:SelectFriend(frienditem, v)
            end)
        end
    end
    self.noFriendText:SetActive(not has)
end

function WorldChampionMainPanel2V2:SelectFriend(item, data)
    if self.lastSelect ~= nil then
        self.lastSelect.transform:Find("select").gameObject:SetActive(false)
    end
    self.selectfriendData = data
    self.lastSelect = item
    self.lastSelect.transform:Find("select").gameObject:SetActive(true)
end

-- 好友邀请按钮
function WorldChampionMainPanel2V2:OnInvite()
    if self.selectfriendData ~= nil then
        TeamManager.Instance:Send11702(self.selectfriendData.id, self.selectfriendData.platform, self.selectfriendData.zone_id)
    end
end
-- 更新位置描述
function WorldChampionMainPanel2V2:UpdatePosDesc()
    for i = 5, #self.memberList+1, -1 do
    	if i <= 2 then
    		self.ItemList[i].PosDesc.text = TI18N("玩家")
    		self.ItemList[i].PosDescicon.sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworld_textures, "atk")
    	else
    		self.ItemList[i].PosDesc.text = TI18N("守护")
    		self.ItemList[i].PosDescicon.sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworld_textures, "sup")
    	end
    end
end

--更新匹配状态循环提示内容
function WorldChampionMainPanel2V2:UpdateCircleTips(tipsType)
    if tipsType == 1 then
        --匹配中
        self.TipCircleCon:SetActive(true)
        self.circleTipsList = self.model:GetCircleTipsList(1)
        self:StartTimer()
    elseif tipsType == 2 then
        --匹配成功
        self.TipCircleCon:SetActive(true)
        self.circleTipsList = self.model:GetCircleTipsList(2)
        self:StartTimer()
    elseif tipsType == 3 then
        --取消匹配
        self.TipCircleCon:SetActive(false)
        self:StopTimer()
        self.circleTipsList = nil
    end
end

-- 匹配队伍信息更新处理
function WorldChampionMainPanel2V2:MatchResult(data)
    self.timesText.gameObject:SetActive(false)
    -- BaseUtils.dump(data, "传递进来的MatchResult@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    if #data.teammate == 2 then
        self.memberList = data.teammate
        self.CancleMatchBtn.gameObject:SetActive(false)
    elseif #data.teammate == 0 then
        local temp = {}
        for i,v in ipairs(data.order) do
            for ii,vv in ipairs(self.memberList) do
                if v.rid == vv.rid and v.platform == vv.platform and v.zone_id == vv.zone_id then
                    table.insert(temp, vv)
                    break
                end
            end
        end
        self.memberList = temp
    else
        local newfirstindex = 1
        for i,v in ipairs(data.teammate) do
            for ii,vv in ipairs(self.memberList) do
                if v.rid == vv.rid and v.platform == vv.platform and v.zone_id == vv.zone_id then
                    if v.is_leader == 1 then
                        newfirstindex = ii
                    end
                    self.memberList[ii] = v
                    break
                end
            end
        end
        local firstdata = self.memberList[newfirstindex]
        self.memberList[newfirstindex] = self.memberList[1]
        self.memberList[1] = firstdata
    end

    if self.ItemList == nil then
        return
    end
    if data.matched_time ~= nil then
        local countdown = function()
            local time = math.max(90 - math.ceil(BaseUtils.BASE_TIME - data.matched_time), 0)
            if time > 0 then
                self.TitleTxt.text = string.format(TI18N("匹配成功，剩余<color='#00ff00'>%ss</color>开战"), time)
            else
                self.TitleTxt.text = TI18N("武道大会2V2模式")
            end
        end
        if self.Titletimer == nil then
            self.Titletimer = LuaTimer.Add(0, 1000, countdown)
        else
            LuaTimer.Delete(self.Titletimer)
            self.Titletimer = LuaTimer.Add(0, 1000, countdown)
        end
        self:ShowMainCon()
    end

    self.MatchResultPos = data.order
    -- 组装守护数据
    self:MakeGuardData()

    local formation = 1
    local formationlev = 1
    self.IamLeader = false
    for i=1,5 do
        local data = self.memberList[i]
        if data == nil then
            break
        end
        if data.rid == RoleManager.Instance.RoleData.id and data.platform == RoleManager.Instance.RoleData.platform and data.zone_id == RoleManager.Instance.RoleData.zone_id then
            self.IamLeader = data.is_leader == 1
        end
        if data.is_leader == 1 then
            formation = data.formation_id
            formationlev = data.formation_lev
        end
        self:SetItem(i, data)
        --self:SetBadge(i, data,2)
    end
    -- 如果不是已匹配状态则返回, 已匹配状态由 MakeGuardData 计算，当非守护人数==2时为已匹配
    if not self.hasMatch then
        return
    end
    self.refreshLev = false
    self.currformation = formation
    self.currformationlev = formationlev
    self.ItemList[1].LeaderIcon.gameObject:SetActive(true)
    self:CancleMatchSuccess()
    self:UpdatePosDesc()
    self.ExitBtn.gameObject:SetActive(false)
    self.ExitBtn.transform:GetComponent("Image").sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
    self.SingleMatchBtn.gameObject:SetActive(false)
    self.timesText.gameObject:SetActive(false)
    self.DoubleMatchBtn.gameObject:SetActive(false)
    self.RankBtn.gameObject:SetActive(false)
    self.TeamBtn.gameObject:SetActive(true)
    if self.TeamBtnRed.activeSelf == false and self.Mgr.first and (self.memberList[1].rid == RoleManager.Instance.RoleData.id and self.memberList[1].platform == RoleManager.Instance.RoleData.platform and self.memberList[1].zone_id == RoleManager.Instance.RoleData.zone_id) then
        self.TeamBtnRed:SetActive(true)
    end
    -- self.formationoperate:HideBtn()
    self.TeamChatBtn.gameObject:SetActive(true)
    local fromationdata = DataFormation.data_list[tostring(formation).."_"..tostring(formationlev)]
    if self.IamLeader then
        self.FormationChangeBtn.gameObject:SetActive(true)
        if formation ~= 1 then
            self.FormationChangeBtn.transform:Find("Text"):GetComponent(Text).text = string.format("%slv.%s", fromationdata.name, fromationdata.lev)
            self.FormationText.text = ""
        else
            self.FormationChangeBtn.transform:Find("Text"):GetComponent(Text).text = string.format("%s", fromationdata.name)
            self.FormationText.text = ""
        end
        self.RestrainText.text = FormationManager.Instance:GetRestrain(formation)
        self.RestrainText.gameObject:SetActive(formation ~= 1)
    else
        if formation ~= 1 then
            self.FormationText.text = string.format(TI18N("队伍阵法：\n%s LV.%s"), fromationdata.name, fromationdata.lev)
        else
            self.FormationText.text = string.format(TI18N("队伍阵法：\n%s"), fromationdata.name)
        end
        self.RestrainText.text = FormationManager.Instance:GetRestrain(formation)
        self.RestrainText.gameObject:SetActive(formation ~= 1)
    end
    self.formationoperate:UpdateAttr(formation,formationlev)

    --匹配到了
    self:UpdateCircleTips(2)
end

function WorldChampionMainPanel2V2:HideMainCon()
    self.formationoperate:Hide()
    local cb = function()
        self.TeamBtn.transform:Find("Text"):GetComponent(Text).text = TI18N("队伍调整")
        self.TeamBtn.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        local panel = self.transform:Find("bgPanel")
        panel.gameObject:SetActive(false)
        self.MainCon.gameObject:SetActive(false)
        MainUIManager.Instance.MainUIIconView:ShowCanvas(true)
        if CombatManager.Instance.isFighting == false then
            MainUIManager.Instance.mainuitracepanel:TweenShow()
        end
        self.MainCon.anchoredPosition = Vector2.zero
        self.MainCon.localScale = Vector3.one
    end
    self.arrow.rotation = Quaternion.Euler(0, 0, 180)
    Tween.Instance:MoveLocalY(self.MainCon.gameObject, 340, 0.4, cb, LeanTweenType.easeOutCubic)
    Tween.Instance:Scale(self.MainCon.gameObject, Vector3.zero, 0.4, function()  end, LeanTweenType.easeOutCubic)

end

function WorldChampionMainPanel2V2:ShowMainCon()
    if CombatManager.Instance.isFighting then
        return
    end
    self.DescInfoPanel.gameObject:SetActive(false)
    local panel = self.transform:Find("bgPanel")
    panel.gameObject:SetActive(true)
    self.MainCon.gameObject:SetActive(true)
    self.arrow.rotation = Quaternion.Euler(0, 0, 0)
    -- MainUIManager.Instance.MainUIIconView:hidebaseicon3()
    MainUIManager.Instance.MainUIIconView:Set_ShowTop(false, {17})
    MainUIManager.Instance.MainUIIconView:ShowCanvas(false)
    MainUIManager.Instance.mainuitracepanel:TweenHiden()
end

function WorldChampionMainPanel2V2:OnEventChange()
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionStart or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionReady or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionSuccess then
    else
        self.model:CloseMainPanel2V2()
    end
end

function WorldChampionMainPanel2V2:ChangeMatchStatus()
    if self.ItemList == nil then
        return
    end
    local matchdata = self.Mgr.matchdata
    if matchdata == nil then
        return
    end
    -- BaseUtils.dump(matchdata, "<color='#ff0000'>转台改变数据22231232131232</color>")
    if self.Mgr.matchdata ~= nil then
        self.timesText.text = string.format(TI18N("挑战次数<color='#ffff00'>(%s/%s)</color>"), tostring(self.Mgr.matchdata.max_join - self.Mgr.matchdata.day_matched), tostring(self.Mgr.matchdata.max_join))
    end

    self:ShowMainCon()
    if #matchdata.teammate == 2 then
        self:MatchResult(matchdata)
        if CombatManager.Instance.isFighting == false then
            self.formationoperate:ShowAttr()
            self:ShowMainCon()
            self:ShowAnimate()
        end
    else
        self.formationoperate:HideAttr()
        if TeamManager.Instance:HasTeam() and TeamManager.Instance:MemberCount() == 2 and TeamManager.Instance:GetMemberOrderList()[2].status == 2 then
            self.memberList = TeamManager.Instance:GetMemberOrderList()
        else
            self.memberList = {
                [1] = {
                    rid = RoleManager.Instance.RoleData.id,
                    name = RoleManager.Instance.RoleData.name,
                    platform = RoleManager.Instance.RoleData.platform,
                    zone_id = RoleManager.Instance.RoleData.zone_id,
                    sex = RoleManager.Instance.RoleData.sex,
                    classes = RoleManager.Instance.RoleData.classes,
                    lev = RoleManager.Instance.RoleData.lev,
					looks = RoleManager.Instance.RoleData.looks,
                    rank_lev = self.Mgr.rankData.rank_lev,
                    rank_point = self.Mgr.rankData.rank_point,
                    show_badge_id = self.Mgr.rankData.show_badge_id,
                    }
            }
        end

        for i=1,5 do
            local data = self.memberList[i]
            self:SetItem(i, data)
            --self:SetBadge(i, data)
        end
        self:UpdatePosDesc()
    end
    if matchdata.is_matching == 1 and #matchdata.teammate ~= 2 then
        self:MatchSuccess()
        self.formationoperate:Hide()
    elseif #matchdata.teammate ~= 2 then
        self:CancleMatchSuccess()
    end
end

function WorldChampionMainPanel2V2:ShowMsg(rid, platform, zone_id, msg, BubbleID)
    for i,v in ipairs(self.memberList) do
        if rid == v.rid and v.platform == platform and v.zone_id == zone_id then
            self.ItemList[i].bubbleObj:ShowMsg(msg, BubbleID)
        end
    end
end

function WorldChampionMainPanel2V2:ShowAnimate()
    if CombatManager.Instance.isFighting or self.animating then
        return
    end

    if self.memberList == nil or #self.memberList == 1 then
        self.SingleMatchBtn.gameObject:SetActive(true)
        self.DoubleMatchBtn.gameObject:SetActive(false)
    else
        self.SingleMatchBtn.gameObject:SetActive(false)
        self.DoubleMatchBtn.gameObject:SetActive(true)
    end
    self.timesText.gameObject:SetActive(true)
    self.ExitBtn.gameObject:SetActive(true)
    self.CancleMatchBtn.gameObject:SetActive(false)
    self.RankBtn.gameObject:SetActive(true)
    self.TeamBtn.gameObject:SetActive(false)
    self.TeamChatBtn.gameObject:SetActive(false)
    self.RestrainText.gameObject:SetActive(false)
    self.FormationChangeBtn.gameObject:SetActive(false)

    LuaTimer.Add(2000, function() AssetPoolManager.Instance:DoUnloadUnusedAssets() end)
    self.animating = true
    local showBtnList = {}
    local isshowBadge = {}
    local scaleT = function( )
        self.animating = false
        for i=1, 5 do
            local tween = function()
                if not BaseUtils.isnull(self.gameObject) and isshowBadge[i] then
                    self.ItemList[i].PetImage.gameObject:SetActive(true)
                    self.ItemList[i].PetImage.gameObject.transform.localScale = Vector3.one*1.5
                    Tween.Instance:Scale(self.ItemList[i].PetImage.transform, Vector3.one, 0.3, function() end, LeanTweenType.easeInBack)

                    -- self.ItemList[i].badgeImg.gameObject:SetActive(true)
                    self.ItemList[i].badgeImgBg.gameObject.transform.localScale = Vector3.one*1.5
                    Tween.Instance:Scale(self.ItemList[i].badgeImgBg.transform, Vector3.one, 0.3, function() end, LeanTweenType.easeInBack)
                end
            end
            LuaTimer.Add(200*i, tween)
        end
        LuaTimer.Add(1000, function()
            for i,v in ipairs(showBtnList) do
                if not BaseUtils.isnull(v) and not BaseUtils.isnull(v.t) then
                    v.t.localPosition = v.p
                end
            end
        end)
    end
    table.insert(showBtnList, {t = self.ExitBtn.transform, p = self.ExitBtn.transform.localPosition})
    table.insert(showBtnList, {t = self.RankBtn.transform, p = self.RankBtn.transform.localPosition})
    table.insert(showBtnList, {t = self.SingleMatchBtn.transform, p = self.SingleMatchBtn.transform.localPosition})
    table.insert(showBtnList, {t = self.DoubleMatchBtn.transform, p = self.DoubleMatchBtn.transform.localPosition})
    table.insert(showBtnList, {t = self.timesText.transform, p = self.timesText.transform.localPosition})
    self.ExitBtn.transform.localPosition = Vector3(2000, 0, 0)
    self.RankBtn.transform.localPosition = Vector3(2000, 0, 0)
    self.SingleMatchBtn.transform.localPosition = Vector3(2000, 0, 0)
    self.DoubleMatchBtn.transform.localPosition = Vector3(2000, 0, 0)
    self.timesText.transform.localPosition = Vector3(2000, 0, 0)
    for i=1,5 do
        local showbadge = self.ItemList[i].PetImage.gameObject.activeSelf
        isshowBadge[i] = showbadge
        self.ItemList[i].PetImage.gameObject:SetActive(false)
        self.ItemList[i].badgeImgBg.gameObject:SetActive(false)
    end
    for i=1,5 do
        local targetpos = self.ItemList[i].localPosition
        self.ItemList[i].transform.localPosition = Vector3(targetpos.x, 400, 0)
        -- self.ItemList[i].transform.localScale = Vector3.zero

        local func = function()
            if self.ItemList == nil or self.ItemList[i] == nil or BaseUtils.isnull(self.ItemList[i].transform) then
                return
            end
            if i == 5 then
                Tween.Instance:MoveLocalY(self.ItemList[i].transform.gameObject, targetpos.y, 0.3, scaleT, LeanTweenType.easeInQuint)
            else
                Tween.Instance:MoveLocalY(self.ItemList[i].transform.gameObject, targetpos.y, 0.3, function() end, LeanTweenType.easeInQuint)
            end
        end
        LuaTimer.Add(100*i, func)
    end
    -- for i=1,5 do
    --     local data = self.memberList[i]
    --     self:SetBadge(i, data)
    --     print("onanimate---------------")
    -- end
end

function WorldChampionMainPanel2V2:ShowRule()
    -- self.DescInfoPanel.gameObject:SetActive(true)
    local currentNpcData = DataUnit.data_unit[20004]
    local extra = {}
    extra.base = BaseUtils.copytab(DataUnit.data_unit[20004])
    extra.base.buttons = {}
    -- extra.base.buttons[1].button_id = actionType.action22
    -- extra.base.buttons[1].button_args = {6, 61, 1, 1}
    extra.base.plot_talk = WorldChampionManager.Instance.OtherDesc2V2
    MainUIManager.Instance.dialogModel:Open(currentNpcData, extra, true)
end

function WorldChampionMainPanel2V2:SetMatchText(value)
    local str = {}
    str[1] = TI18N("匹配中.")
    str[2] = TI18N("匹配中..")
    str[3] = TI18N("匹配中...")
    self.CancleMatchBtnText.text = str[self.strindex]
    self.strindex = self.strindex + 1
    if self.strindex > 3 then
        self.strindex = 1
    end
end

--循环提示计时器
function WorldChampionMainPanel2V2:StartTimer()
    self:StopTimer()
    self.timerCount = 0
    self.circleTipTimerId = LuaTimer.Add(0, 1000, function() self:TickTimer() end)
end

function WorldChampionMainPanel2V2:StopTimer()
    if self.circleTipTimerId ~= 0 then
        LuaTimer.Delete(self.circleTipTimerId)
        self.circleTipTimerId = 0
    end
end

function WorldChampionMainPanel2V2:TickTimer()
    if self.timerCount%8 == 0 then
        --8秒了
        local tempIndex = self.timerCount/8
        local index = 1
        if tempIndex > 0 then
            index = tempIndex%#self.circleTipsList
        end
        if index == 0 then
            index = #self.circleTipsList
        end

        local cfg_data = self.circleTipsList[index]
        self.TipCircleMsg:SetData(cfg_data.tips_content)
    end
    self.timerCount = self.timerCount + 1
end

function WorldChampionMainPanel2V2:UpdateModel(item, data)
	local fun = function(composite)
        if BaseUtils.is_null(self.gameObject) or BaseUtils.is_null(item.Preview) then
            -- bugly #29765622 hosr 20160722
            return
        end
        local rawImage = composite.rawImage
        rawImage.transform:SetParent(item.Preview)
        rawImage.transform.localPosition = Vector3(0, 0, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
        composite.tpose.transform.localRotation = Quaternion.identity

        item.Preview.gameObject:SetActive(true)
    end

    local modelData = {}

    if data.zone_id == 0 then
    	modelData = {type = PreViewType.Shouhu, skinId = data.skin, modelId = data.model, animationId = data.animation, scale = 1}
	else
		modelData = {type = PreViewType.Role, classes = data.classes, sex = data.sex, looks = data.looks}
    end

    item.Preview.gameObject:SetActive(false)
    if item.previewComposite == nil then
        item.previewComposite = PreviewComposite.New(fun, self.modelPreViewSetting, modelData)
        item.previewComposite:BuildCamera(true)
    elseif not BaseUtils.sametab(modelData, item.previewComposite.modelData) then
        item.previewComposite:Reload(modelData, fun)
    else
        item.Preview.gameObject:SetActive(true)
    end
end

-- 组装守护数据
function WorldChampionMainPanel2V2:MakeGuardData()
	local fun = function(base_id, status, war_id, quality)
		local guard_base_cfg = DataShouhu.data_guard_base_cfg[base_id]

		local model = guard_base_cfg.res_id
		local animation = guard_base_cfg.animation_id
		local skin = guard_base_cfg.paste_id
		local wakeUpCfgData = DataShouhu.data_guard_wakeup_upgrade[string.format("%s_%s", base_id, quality)]
		if wakeUpCfgData ~= nil and wakeUpCfgData.model ~= 0 then
		    model = wakeUpCfgData.model
		    skin = wakeUpCfgData.skin
		    animation = wakeUpCfgData.animation
		end

		return {
				isGuard = 1
				, base_id = base_id
				, status = status
				, war_id = war_id
				, quality = quality

				, model = model
				, skin = skin
				, animation = animation

				, name = guard_base_cfg.name
				, sex = guard_base_cfg.sex
				, classes = guard_base_cfg.classes
				, lev = 100

				, is_leader = 0

				, rid = base_id
				, platform = ""
				, zone_id = 0}
	end

	local leader = nil
	for _,member in ipairs(self.memberList) do
	    if member.is_leader == 1 then
	        leader = member
	        break
	    end
	end

    local roleNum = 0
	if leader ~= nil and self.MatchResultPos ~= nil and #self.MatchResultPos > 0 then
		self.leaderGuards = BaseUtils.copytab(leader.guards)
		self.fightGuardsMark = {}

		local guardDataList = {}
		for _,orderData in ipairs(self.MatchResultPos) do
		    for guardIndex, guardData in ipairs(leader.guards) do
		        if orderData.rid == guardData.base_id and orderData.zone_id == 0 then
		            table.insert(guardDataList, fun(guardData.base_id, guardData.status, guardData.war_id, guardData.quality))
		            self.fightGuardsMark[guardData.base_id] = true
		            break
		        end
		    end
		end

		local temp = {}
		for i,v in ipairs(self.MatchResultPos) do
			local isGuard = false
			for ii,vv in ipairs(guardDataList) do
			    if v.rid == vv.base_id and v.zone_id == 0 then
			        table.insert(temp, vv)
			        isGuard = true
			        break
			    end
			end

		    if not isGuard then
			    for ii,vv in ipairs(self.memberList) do
			        if v.rid == vv.rid and v.platform == vv.platform and v.zone_id == vv.zone_id then
			            table.insert(temp, vv)
			            break
			        end
			    end

                roleNum = roleNum + 1 
			end
		end
		self.memberList = temp
	end

    self.hasMatch = (roleNum == 2)

	self.formationoperate:UpdateGuardButton()
	-- print(debug.traceback())
	-- BaseUtils.dump(self.memberList, "self.memberList")
	-- BaseUtils.dump(self.MatchResultPos, "self.MatchResultPos")
end

function WorldChampionMainPanel2V2:BadgeShow(id)
    self.model:OpenBadgeShowWindow(id)
end