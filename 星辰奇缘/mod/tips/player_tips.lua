-- ------------------------------
-- 道具tips
-- hzf
-- ------------------------------
PlayerTips = PlayerTips or BaseClass(BaseTips)

function PlayerTips:__init(model)
    self.model = model
    self.resList = {
        {file = AssetConfig.tips_player, type = AssetType.Main},
        {file = AssetConfig.attr_icon, type = AssetType.Dep},
        {file = AssetConfig.badge_icon, type = AssetType.Dep},
        {file = AssetConfig.wingsbookbg, type = AssetType.Dep},
        {file = AssetConfig.rolebgnew, type = AssetType.Dep},
        {file = AssetConfig.worldchampion_LevIcon, type = AssetType.Dep}
    }
    self.mgr = TipsManager.Instance
    self.gameObject = nil
    self.previewComp = nil
    self.lastkey = {}

    self.teamCall = nil

    self.guildCall = nil

end

function PlayerTips:__delete()
    self.mgr = nil
    self.buttons = {}
    if self.headSlot ~= nil then
        self.headSlot:DeleteMe()
        self.headSlot = nil
    end
end


function PlayerTips:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.tips_player))
    self.gameObject.name = "PlayerTips"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.model.tipsCanvas.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3(-480, -270, 0)
    self.transform:SetSiblingIndex(1)

    self.gameObject:GetComponent(Button).onClick:AddListener(function() self.model:Closetips() end)
    self.transform:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() self.model:Closetips() end)
    self.cross = self.transform:Find("Cross").gameObject

    self.rect = self.gameObject:GetComponent(RectTransform)

    self.TopCon = self.transform:Find("Top")
    self.preview = self.TopCon:Find("preview").gameObject
    self.showHeadBtn = self.TopCon:Find("preview/Button"):GetComponent(Button)
    self.TopCon:Find("preview/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.nameTxt = self.TopCon:Find("nameTxt"):GetComponent(Text)
    self.levTxt = self.TopCon:Find("levTxt"):GetComponent(Text)
    self.guildTxt = self.TopCon:Find("guildTxt"):GetComponent(Text)
    self.achiveTxt = self.TopCon:Find("AchiveTxt"):GetComponent(Text)
    self.likeTxt = self.TopCon:Find("likeTxt"):GetComponent(Text)
    self.honorTxt = self.TopCon:Find("HonorTxt"):GetComponent(Text)
    self.RankTxt = self.TopCon:Find("RankTxt"):GetComponent(Text)
    self.name_usedBtn = self.TopCon:Find("LastNameButton"):GetComponent(Button)
    self.achiveBadge_Image = self.TopCon:Find("AchiveBadgeButton"):GetComponent(Image)
    self.achiveBadge_Btn = self.TopCon:Find("AchiveBadgeButton"):GetComponent(Button)
    self.RankBadge_Image = self.TopCon:Find("RankBadgeButton"):GetComponent(Image)
    self.RankBadgeButton = self.TopCon:Find("RankBadgeButton"):GetComponent(Button)

    self.headSlot = HeadSlot.New(nil,true)
    self.portraitObj = self.TopCon:Find("BigPortrait").gameObject
    self.protraitObjBg = self.TopCon:Find("BigPortrait/Bg"):GetComponent(Image)
    self.protraitObjBg.sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew, "RoleBgNew")

    self.headSlot:SetRectParent(self.TopCon:Find("BigPortrait"))
    -- self.headSlot.gameObject.transform:SetAsFirstSibling()
    self.showModule = self.TopCon:Find("BigPortrait/Button"):GetComponent(Button)

    self.BotCon = self.transform:Find("BotMask/Bot")
    self.FriendBtn = self.BotCon:Find("Friend"):GetComponent(Button)
    self.ZoneBtn = self.BotCon:Find("Zone"):GetComponent(Button)
    self.GiftBtn = self.BotCon:Find("Gift"):GetComponent(Button)
    self.ChatBtn = self.BotCon:Find("Chat"):GetComponent(Button)
    self.TeamBtn = self.BotCon:Find("Team"):GetComponent(Button)
    self.GuildBtn = self.BotCon:Find("Guild"):GetComponent(Button)
    self.GuildPosBtn = self.BotCon:Find("GuildPos"):GetComponent(Button)
    self.WatchorPKBtn = self.BotCon:Find("WatchorPK"):GetComponent(Button)
    self.ForbidBtn = self.TopCon:Find("Forbid"):GetComponent(Button)
    self.ForbidTxt = self.ForbidBtn.gameObject.transform:Find("I18N_Name"):GetComponent(Text)
    self.ForbidRect = self.ForbidBtn.gameObject:GetComponent(RectTransform)
    self.ReportBtn = self.BotCon:Find("Report"):GetComponent(Button)
    self.HomeBtn = self.BotCon:Find("Home"):GetComponent(Button)
    self.TeacherBtn = self.BotCon:Find("Teacher"):GetComponent(Button)
    self.WorldChampionBtn = self.BotCon:Find("WorldChampion"):GetComponent(Button)
    self.WorldChampionBtnTxt = self.BotCon:Find("WorldChampion/name"):GetComponent(Text)
    self.WorldChampionBtnIcon = self.BotCon:Find("WorldChampion/icon"):GetComponent(Image)
    self.BotCon:Find("Forbid").gameObject:SetActive(false)
    self.atSomeOne = self.BotCon:Find("AtSomeOne"):GetComponent(Button)
    self.atSomeOneTxt = self.BotCon:Find("AtSomeOne/name"):GetComponent(Text)

    self.FriendBtn.onClick:AddListener(function() self:OnFriend() end)
    self.ZoneBtn.onClick:AddListener(function() self:OnZone() end)
    self.GiftBtn.onClick:AddListener(function() self:OnGift() end)
    self.ChatBtn.onClick:AddListener(function() self:OnChat() end)
    self.TeamBtn.onClick:AddListener(function() self:OnTeam() end)
    self.GuildBtn.onClick:AddListener(function() self:OnGuild() end)
    self.GuildPosBtn.onClick:AddListener(function() self:OnGuildPos() end)
    self.WatchorPKBtn.onClick:AddListener(function() self:OnWatchPK() end)
    self.ForbidBtn.onClick:AddListener(function() self:OnForbid() end)
    self.ReportBtn.onClick:AddListener(function() self:OnReport() end)
    self.HomeBtn.onClick:AddListener(function() self:OnHome() end)
    self.TeacherBtn.onClick:AddListener(function() self:OnTeacher() end)
    self.atSomeOne.onClick:AddListener(function() self:OnAt() end)
    self.WorldChampionBtn.onClick:AddListener(function() self:OnWorldChampion() end)

    self.infoBtn = self.TopCon:Find("infoButton"):GetComponent(Button)
    self.infoBtn.onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.infoBtn.gameObject, itemData = {
            TI18N("1、赠送好友玫瑰可以增加亲密度"),
            TI18N("2、好友之间组队参与<color='#ffff00'>世界boss、天空之塔、段位赛</color>可增加亲密度"),
            TI18N("3、亲密度达到<color='#00ff00'>100点</color>可赠送道具"),
            }, special = true})
        end)
    self.name_usedBtn.onClick:AddListener(function()  RoleManager.Instance:Send10017(self.tips_data.roleid, self.tips_data.platform, self.tips_data.zoneid, self.name_usedBtn.gameObject)end)
    self.achiveBadge_Btn.onClick:AddListener(function() self.model:Closetips() AchievementManager.Instance.model.Send10233Name = self.tips_data.name AchievementManager.Instance:Send10233(self.tips_data.roleid, self.tips_data.platform, self.tips_data.zoneid)end)
    self.RankBadgeButton.onClick:AddListener(function() self:ShowRankTips() end)
    self:ReceiveData(self.tips_data)
end

-- ------------------------------------
-- 外部调用更新数据
-- 参数说明:
-- info = 数据
-- ------------------------------------

function PlayerTips:UpdateInfo(info)

    self.tips_data = info
--数据格式兼容
    self.tips_data.roleid = (self.tips_data.roleid ~= nil and self.tips_data.roleid) or (self.tips_data.rid ~= nil and self.tips_data.rid ~= 0 and self.tips_data.rid) or (self.tips_data.id ~= nil and self.tips_data.id ~= 0 and self.tips_data.id)
    self.tips_data.id = self.tips_data.roleid
    self.tips_data.rid = self.tips_data.id
    self.tips_data.zoneid = (self.tips_data.zoneid ~= nil and self.tips_data.zoneid) or (self.tips_data.zone_id ~= nil and self.tips_data.zone_id)
    self.tips_data.zone_id = self.tips_data.zoneid

    -- 陌生人禁止聊天
    self.noChatStranger = info.noChatStranger or false

    if self.tips_data.looks == nil then
        self.tips_data.looks = {}
    end
    if self.tips_data.roleid == RoleManager.Instance.RoleData.id and RoleManager.Instance.RoleData.platform == self.tips_data.platform and self.tips_data.zone_id == RoleManager.Instance.RoleData.zone_id then
        NoticeManager.Instance:FloatTipsByString(TI18N("这是您自己"))
        self:Hiden()
        return
    end
    self.model:SetPlayerTipsInfo(nil)
    if self.tips_data.rid~= nil and  self.tips_data.rid ~= 0 then
        RoleManager.Instance:send10016(self.tips_data.rid, self.tips_data.platform, self.tips_data.zone_id)
    else
        RoleManager.Instance:send10016(self.tips_data.id, self.tips_data.platform, self.tips_data.zone_id)
    end
    -- TeamManager.Instance:Send11722(self.tips_data.roleid, self.tips_data.platform, self.tips_data.zone_id)
end

function PlayerTips:SetData(info)
    self.tips_data = info
--数据格式兼容
    self.tips_data.roleid = (self.tips_data.roleid ~= nil and self.tips_data.roleid) or (self.tips_data.rid ~= nil and self.tips_data.rid) or (self.tips_data.id ~= nil and self.tips_data.id)
    self.tips_data.id = self.tips_data.roleid
    self.tips_data.zoneid = (self.tips_data.zoneid ~= nil and self.tips_data.zoneid) or (self.tips_data.zone_id ~= nil and self.tips_data.zone_id)
    self.tips_data.zone_id = self.tips_data.zoneid
end

function PlayerTips:ReceiveData(info)

      if self.gameObject ~= nil then
        self.GiftBtn.gameObject:SetActive(true)
        self.ChatBtn.gameObject:SetActive(true)
        self.TeamBtn.gameObject:SetActive(true)
        self.GuildBtn.gameObject:SetActive(true)
        self.GuildPosBtn.gameObject:SetActive(true)
        self.WatchorPKBtn.gameObject:SetActive(true)
        self.ForbidBtn.gameObject:SetActive(true)
        self.ReportBtn.gameObject:SetActive(true)
        self.HomeBtn.gameObject:SetActive(true)
        self.TeacherBtn.gameObject:SetActive(true)
        self.atSomeOne.gameObject:SetActive(true)
    end


    self.honorTxt.text = TI18N("无")
    if info ~= nil then
        self:SetData(info)
        -- BaseUtils.dump(self.tips_data, "请求到玩家数据")
        self:SetHonor()
    end
    if self.tips_data.roleid == RoleManager.Instance.RoleData.id and RoleManager.Instance.RoleData.platform == self.tips_data.platform and self.tips_data.zone_id == RoleManager.Instance.RoleData.zone_id then
        NoticeManager.Instance:FloatTipsByString(TI18N("这是您自己"))
        self:Hiden()
        return
    end
    if self.previewComp ~= nil then
        self.previewComp:Show()
    end
    self:LoadPreview()
    self.selfdata = RoleManager.Instance.RoleData
    if self:IsFriend() then
        self.FriendBtn.transform:Find("name"):GetComponent(Text).text = TI18N("删除好友")
    else
        self.FriendBtn.transform:Find("name"):GetComponent(Text).text = TI18N("添加好友")
    end
    self.nameTxt.text = self.tips_data.name
    self.levTxt.text = self.tips_data.lev
    if self.tips_data.classes ~= nil then
        self.levTxt.text = string.format(TI18N("%s级<color='#00ff00'>%s</color>"), tostring(self.tips_data.lev), KvData.classes_name[self.tips_data.classes])
    end
    self.guildTxt.text = self.tips_data.guild == "" and TI18N("无") or self.tips_data.guild
    if self.tips_data.guild_name ~= nil then
        self.guildTxt.text = self.tips_data.guild_name == "" and TI18N("无") or self.tips_data.guild_name
    end
    self.tips_data.intimacy = FriendManager.Instance:GetIntimacy(self.tips_data.roleid, self.tips_data.platform, self.tips_data.zone_id)
    self.likeTxt.text = tostring(self.tips_data.intimacy)
    self:FriendCheck()
    self:TeamCheck()
    self:GuildCheck()
    self:BattleCheck()
    self:GuildPosCheck()
    self:ReportCheck()
    self:ForbidCheck()
    self:HomeCheck()
    self:TeacherCheck()
    self:WorldChampionBntCheck()
    self:PraseTeamStatus(self.tips_data)
    if self.tips_data.achievement_point ~= nil then
        self:SetAchivePoint(self.tips_data.achievement_point)
    else
        self:SetAchivePoint(0)
    end

    if self.tips_data.tournament_lev ~= nil then
        self:SetRankLev(self.tips_data.tournament_lev)
    else
        self:SetRankLev(1)
    end
    self.headSlot:HideSlotBg(false, 0.02)
    self:AfterLoadCustom()
    -- BaseUtils.dump(self.tips_data)
    if self.tips_data.classes ~= nil and self.tips_data.classes ~= 0 and self.tips_data.sex ~= nil then
        self.headSlot:SetAll({id = self.tips_data.roleid, platform = self.tips_data.platform, zone_id = self.tips_data.zone_id, classes = self.tips_data.classes, sex = self.tips_data.sex}, {isSmall = false, loadCallback = function(success) self:AfterLoadCustom(success) end})
    end
    self:UpdateAtTxt()
    self.cross:SetActive(not BaseUtils.IsTheSamePlatform(self.tips_data.platform, self.tips_data.zone_id))

    if self.gameObject ~= nil then
         if self.tips_data.classes == nil or self.tips_data.sex == nil then
                    self.GiftBtn.gameObject:SetActive(false)
                    self.ChatBtn.gameObject:SetActive(false)
                    self.TeamBtn.gameObject:SetActive(false)
                    self.GuildBtn.gameObject:SetActive(false)
                    self.GuildPosBtn.gameObject:SetActive(false)
                    self.WatchorPKBtn.gameObject:SetActive(false)
                    self.ForbidBtn.gameObject:SetActive(false)
                    self.ReportBtn.gameObject:SetActive(false)
                    self.HomeBtn.gameObject:SetActive(false)
                    self.TeacherBtn.gameObject:SetActive(false)
                    self.atSomeOne.gameObject:SetActive(false)
                    self.WorldChampionBtn.gameObject:SetActive(false)

            end
    end
end




------------------------------好友相关
function PlayerTips:OnFriend()
    if self.friendCall ~= nil then
        self.friendCall(self.tips_data.roleid, self.tips_data.platform, self.tips_data.zoneid)
    end
    self.model:Closetips()
end

function PlayerTips:IsFriend()
    return FriendManager.Instance:IsFriend(self.tips_data.roleid, self.tips_data.platform, self.tips_data.zoneid)
end

function PlayerTips:FriendCheck()
    if self:IsFriend() then
        self.FriendBtn.transform:Find("name"):GetComponent(Text).text = TI18N("删除好友")
        self.friendCall = function(rid, platform, zone) FriendManager.Instance:DeleteFriend(rid, platform, zone) end
    else
        self.FriendBtn.transform:Find("name"):GetComponent(Text).text = TI18N("添加好友")
        self.friendCall = function(rid, platform, zone) FriendManager.Instance:AddFriend(rid, platform, zone) end
    end
end
------------------------------空间

function PlayerTips:OnZone()
    -- body
    self.model:Closetips()
    ZoneManager.Instance:OpenOtherZone(self.tips_data.roleid, self.tips_data.platform, self.tips_data.zoneid)
end

-------------------------------聊天相关
function PlayerTips:OnChat()
    if self.noChatStranger and not FriendManager.Instance:IsFriend(self.tips_data.roleid, self.tips_data.platform, self.tips_data.zone_id) then
        self.model:Closetips()
        local confirmData = NoticeConfirmData.New()
        confirmData.content = TI18N("该玩家还不是你的<color='#ffff00'>好友</color>，加为<color='#ffff00'>好友</color>后即可私聊{face_1, 6}是否添加该玩家为<color='#ffff00'>好友</color>？")
        confirmData.sureCallback = function() FriendManager.Instance:AddFriend(self.tips_data.roleid, self.tips_data.platform, self.tips_data.zone_id) end
        confirmData.sureLabel = TI18N("添加好友")
        confirmData.cancelLabel = TI18N("我再想想")
        NoticeManager.Instance:ConfirmTips(confirmData)
        return
    end

    self.tips_data.online = 1
    FriendManager.Instance:TalkToUnknowMan(self.tips_data)
    self.model:Closetips()
end

-----------------------------队伍相关
function PlayerTips:OnTeam()
    -- body
    if self.teamCall ~= nil then
        self.teamCall(self.tips_data.roleid, self.tips_data.platform, self.tips_data.zoneid)
    end
    self.model:Closetips()
end

--------------------------- 拜师按钮相关
function PlayerTips:OnTeacher()
    local key = string.format("%s_%s_%s", self.tips_data.roleid, self.tips_data.platform, self.tips_data.zoneid)
    if self.lastkey[key] ~= nil and Time.time - self.lastkey[key] < 300 then
        self.model:Closetips()
        NoticeManager.Instance:FloatTipsByString(TI18N("你已经发起过拜师申请了，请耐心等待"))
        return
    end
    TeacherManager.Instance:send15819(self.tips_data.roleid, self.tips_data.platform, self.tips_data.zoneid, 1)
    FriendManager.Instance:TalkToUnknowMan(self.tips_data, 1)
    self.lastkey[key] = Time.time
    self.model:Closetips()
end

function PlayerTips:TeamCheck()
    -- body
end

function PlayerTips:PraseTeamStatus(data)
    -- print("目标玩家队伍状态："..tostring(self.tips_data.team_status))
    local uniqueroleid = BaseUtils.get_unique_roleid(self.tips_data.roleid, self.tips_data.zone_id, self.tips_data.platform)
    self.TeamBtn.gameObject:SetActive(true)
    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
        -- 自己是队长的时候的处理
        if TeamManager.Instance:IsInMyTeam(uniqueroleid) then
            -- 点到的人不再队伍
            self.TeamBtn.transform:Find("name"):GetComponent(Text).text = TI18N("踢出队伍")
            self.teamCall = function(rid, platform, zone) TeamManager.Instance:KickOut(rid, platform, zone) end
        else --[[if data.team_status == RoleEumn.TeamStatus.None or data.team_status == nil then]]
            self.TeamBtn.transform:Find("name"):GetComponent(Text).text = TI18N("组 队")
            self.teamCall = function(rid, platform, zone)
                    TeamManager.Instance:OrganizeATeam(rid, platform, zone)
                    -- TeamManager.Instance:Send11702(rid, platform, zone)
                end
            -- 点到的人在自己队里
        -- else
        --     -- 点到的人有自己的队伍
        --     self.TeamBtn.gameObject:SetActive(false)
        --     self.teamCall = nil
        end
    else
        -- 自己不是队长的时候
        -- if TeamManager.Instance:HasTeam() then
        --     self.TeamBtn.transform:Find("name"):GetComponent(Text).text = TI18N("组队")
        --     self.teamCall = function(rid, platform, zone) NoticeManager.Instance:FloatTipsByString("只有队长才能发起邀请") end
        -- else--[[if data.team_status == RoleEumn.TeamStatus.None then]]
            self.TeamBtn.transform:Find("name"):GetComponent(Text).text = TI18N("组 队")
            self.teamCall = function(rid, platform, zone)
                    TeamManager.Instance:OrganizeATeam(rid, platform, zone)
                    -- TeamManager.Instance:Send11702(rid, platform, zone)
                end
        -- else
        --     self.TeamBtn.transform:Find("name"):GetComponent(Text).text = TI18N("申请入队")
        --     self.teamCall = function(rid, platform, zone) TeamManager.Instance:LetMeIn(rid, platform, zone) end
        -- end
    end
end

-----------------------------赠送
function PlayerTips:OnGift()
    -- if not BaseUtils.IsTheSamePlatform(self.tips_data.platform, self.tips_data.zone_id) then
    --     NoticeManager.Instance:FloatTipsByString("跨服暂不支持赠送礼物")
    --     return
    -- end
    if RoleManager.Instance.RoleData.lev >= 30 then
        GivepresentManager.Instance:OpenGiveWin(self.tips_data)
        self.model:Closetips()
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("30级开启"))
    end
end

-----------------------------武道战绩
function PlayerTips:WorldChampionCheck()
    if GuildManager.Instance.model:has_guild() then
        --我有公会
        --检查他是否在我公会里面
        local mem = GuildManager.Instance.model:get_guild_member_by_id(self.tips_data.roleid, self.tips_data.platform, self.tips_data.zone_id)
        if mem == nil then
            --不在同个公会，检查下是否为好友
            local bool = FriendManager.Instance:IsFriend(self.tips_data.roleid, self.tips_data.platform, self.tips_data.zone_id)
            if bool then
                return true
            end
        else
            return true
        end
    else
        --我没有公会，检查下是否好友
        local bool = FriendManager.Instance:IsFriend(self.tips_data.roleid, self.tips_data.platform, self.tips_data.zone_id)
        if bool then
            return true
        end
    end
    return false
end

function PlayerTips:WorldChampionBntCheck()
    local bool = self:WorldChampionCheck()
    if bool then
        -- self.WorldChampionBtn.transform:Find("bgImage"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton5")
        -- self.WorldChampionBtnTxt.color = ColorHelper.DefaultButton5
        BaseUtils.SetGrey(self.WorldChampionBtnIcon, false)
    else
        -- self.WorldChampionBtn.transform:Find("bgImage"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        -- self.WorldChampionBtnTxt.color = ColorHelper.DefaultButton4
        BaseUtils.SetGrey(self.WorldChampionBtnIcon, true)
    end
    if self.tips_data.lev ~= nil and self.tips_data.lev < 70 then
        self.WorldChampionBtn.gameObject:SetActive(false)
    else
        self.WorldChampionBtn.gameObject:SetActive(true)
    end
end

-----------------------------公会
function PlayerTips:OnGuild()
    if self.guildCall ~= nil then
        self.guildCall()
    end
    self.model:Closetips()
end

function PlayerTips:GuildCheck()
    -- print("=================================================================================2333333333333333333")
    if GuildManager.Instance.model:has_guild() then
        if self.tips_data.g_id == nil or self.tips_data.g_id == 0 and self.tips_data.lev >= 30 then
            self.GuildBtn.gameObject.transform:Find("name"):GetComponent(Text).text = TI18N("邀请入会")
            self.GuildBtn.gameObject:SetActive(true)
            self.guildCall = function() GuildManager.Instance:request11182(self.tips_data.roleid, self.tips_data.platform, self.tips_data.zone_id) end
        else
            self.GuildBtn.gameObject:SetActive(false)
            self.guildCall = nil
        end
    else
        -- BaseUtils.dump(self.tips_data,"这个人的工会============================================================================================")
        if self.tips_data.g_id == nil or self.tips_data.g_id == 0   then
            self.GuildBtn.gameObject:SetActive(false)
            self.guildCall = nil
        else
            self.GuildBtn.gameObject:SetActive(true)
            self.GuildBtn.gameObject.transform:Find("name"):GetComponent(Text).text = TI18N("申请入会")
            self.guildCall = function()
                local guildName = ""
                if self.tips_data.guild_name ~= nil and self.tips_data.guild_name == ""  then
                    guildName = self.tips_data.guild_name
                end
                if guildName == "" and self.tips_data.guild ~= nil and self.tips_data.guild ~= "" then
                    guildName = self.tips_data.guild
                end
                if self.tips_data.g_id ~= nil then
                    local data = { GuildId = self.tips_data.g_id, PlatForm = self.tips_data.g_platform, ZoneId = self.tips_data.g_zone_id, Name = guildName}
                    GuildManager.Instance.model:OpenApplyMsgWindow(data)
                else
                    local data = { GuildId = self.tips_data.guild_id, PlatForm = self.tips_data.g_platform, ZoneId = self.tips_data.g_zone_id, Name = guildName}
                    GuildManager.Instance.model:OpenApplyMsgWindow(data)
                end
            end
        end
    end
end

-----------------------------公会职位检查
function PlayerTips:GuildPosCheck()
    --检查下我是否为长老
    self.GuildPosBtn.gameObject:SetActive(false)
    if GuildManager.Instance.model:check_has_join_guild() then
        if GuildManager.Instance.model:get_my_guild_post() >= GuildManager.Instance.model.member_positions.elder then
            --检查下选中的人是否在我的公会
            local mem_data = GuildManager.Instance.model:get_guild_member_by_id(self.tips_data.roleid, self.tips_data.platform, self.tips_data.zone_id)
            if mem_data ~= nil then
                if mem_data.Post < GuildManager.Instance.model:get_my_guild_post() then
                    self.GuildPosBtn.gameObject:SetActive(true)
                    self.GuildBtn.gameObject:SetActive(false)
                end
            end
        end
    end
end

function PlayerTips:OnGuildPos()
    local mem_data = GuildManager.Instance.model:get_guild_member_by_id(self.tips_data.roleid, self.tips_data.platform, self.tips_data.zone_id)
    if mem_data ~= nil then
        GuildManager.Instance.model.update_mem_mange_data = mem_data
        GuildManager.Instance.model:InitGuildMemManageUI()

        --打开设置职位
        -- GuildManager.Instance.model.select_mem_oper_data = {}
        -- GuildManager.Instance.model.select_mem_oper_data.guildMemData = mem_data
        -- GuildManager.Instance.model:InitPositionUI()
    end
end

-----------------------------战斗相关
function PlayerTips:OnWatchPK()
    -- CombatManager.Instance:Send10705(self.tips_data.roleid, self.tips_data.platform, self.tips_data.zoneid)
    -- CombatManager.Instance:Send10760(self.tips_data.roleid, self.tips_data.platform, self.tips_data.zoneid)
    if self.pkCallback ~= nil then
        self.pkCallback()
    end
    self.model:Closetips()
end

function PlayerTips:BattleCheck()
    self.WatchorPKBtn.gameObject:SetActive(true)
    if self.tips_data.status == RoleEumn.Status.Fight then
        self.WatchorPKBtn.transform:Find("name"):GetComponent(Text).text = TI18N("观 战")
        self.pkCallback = function() CombatManager.Instance:Send10705(self.tips_data.roleid, self.tips_data.platform, self.tips_data.zoneid)  end
    elseif self.tips_data.status == RoleEumn.Status.Normal then
        self.WatchorPKBtn.transform:Find("name"):GetComponent(Text).text = TI18N("切 磋")
        if self.selfdata.lev >= 30 and self.tips_data.lev >= 30 then
            self.pkCallback = function() CombatManager.Instance:Send10760(self.tips_data.roleid, self.tips_data.platform, self.tips_data.zoneid)  end
        elseif self.selfdata.lev >= 30 then
            self.pkCallback = function() NoticeManager.Instance:FloatTipsByString(TI18N("对方还是个新人，怎么能欺负他")) end
        else
            self.pkCallback = function() NoticeManager.Instance:FloatTipsByString(TI18N("你的等级太低，30级才可以切磋")) end
        end
    else
        self.WatchorPKBtn.transform:Find("name"):GetComponent(Text).text = TI18N("切 磋")
        if self.selfdata.lev >= 30 and (self.tips_data.lev == nil or self.tips_data.lev >= 30) then
            self.pkCallback = function() CombatManager.Instance:Send10760(self.tips_data.roleid, self.tips_data.platform, self.tips_data.zoneid)  end
        elseif self.selfdata.lev >= 30 then
            self.pkCallback = function() NoticeManager.Instance:FloatTipsByString(TI18N("对方还是个新人，怎么能欺负他")) end
        else
            self.pkCallback = function() NoticeManager.Instance:FloatTipsByString(TI18N("你的等级太低，30级才可以切磋")) end
        end
        -- self.WatchorPKBtn.gameObject:SetActive(false)
    end
end

------------------------------屏蔽
function PlayerTips:ForbidCheck()
    local key = string.format("%s_%s_%s", self.tips_data.roleid, self.tips_data.platform, self.tips_data.zoneid)
    if ShieldManager.Instance:CheckIsSheild(key) then
        self.ForbidTxt.text = TI18N("取消屏蔽")
    else
        self.ForbidTxt.text = TI18N("屏 蔽")
    end
    self.ForbidRect.sizeDelta = Vector2(self.ForbidTxt.preferredWidth + 54, 30)
end

function PlayerTips:OnForbid()
    -- body
    local key = string.format("%s_%s_%s", self.tips_data.roleid, self.tips_data.platform, self.tips_data.zoneid)
    if ShieldManager.Instance:CheckIsSheild(key) then
        ShieldManager.Instance:RemoveChatSheild(key)
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("对<color='#ffff00'>%s</color>取消屏蔽成功"), self.tips_data.name))
    else
        ShieldManager.Instance:AddChatSheild(key)
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("对<color='#ffff00'>%s</color>屏蔽成功<color='#ffff00'>(本次登录内有效)</color>"), self.tips_data.name))
    end
    self.model:Closetips()
end

------------------------------举报
function PlayerTips:ReportCheck()
    if RoleManager.Instance.RoleData.lev < 30 then
        self.ReportBtn.gameObject:SetActive(false)
    else
        self.ReportBtn.gameObject:SetActive(true)
    end
end

function PlayerTips:OnReport()
    -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.reportwindow, {self.tips_data})
    ReportManager.Instance.model:ReportChat({self.tips_data}, 1)
    self.model:Closetips()
end

------------------------------举报
function PlayerTips:HomeCheck()
    --BaseUtils.dump(self.tips_data, "HomeCheck")
    --print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")
    if self.tips_data.fid == nil or self.tips_data.fid == 0 then
        self.HomeBtn.gameObject:SetActive(false)
    else
        self.HomeBtn.gameObject:SetActive(true)
    end
end

function PlayerTips:OnHome()
    HomeManager.Instance:EnterOtherHome(self.tips_data.fid, self.tips_data.family_platform, self.tips_data.family_zone_id)
    self.model:Closetips()
end
------------------------------
function PlayerTips:LoadPreview()
    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "PlayerTips"
        ,orthographicSize = 0.5
        ,width = 173
        ,height = 163
        ,offsetY = -0.4
    }
    local modelData = {type = PreViewType.Role, classes = self.tips_data.classes, sex = self.tips_data.sex, looks = self.tips_data.looks}

    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:DeleteMe()
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
        -- self.previewComp:Reload(modelData, callback)
    end
    self.showHeadBtn.transform:SetAsLastSibling()
end

function PlayerTips:SetRawImage(composite)
    local rawImage = composite.rawImage
    if rawImage ~= nil then
        rawImage.transform:SetParent(self.preview.transform)
        rawImage.transform.localPosition = Vector3(0, 0, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
        if self.isSuccess ~= true then
            self.preview:SetActive(true)
            self.protraitObjBg.gameObject:SetActive(false)
        end
    end
end

function PlayerTips:Hiden()
    if self.gameObject ~= nil then
        if self.previewComp ~= nil then
            self.previewComp:Hide()
        end
        self.gameObject:SetActive(false)
        self.OnHideEvent:Fire()
    end
end

function PlayerTips:SetTeamStatus(status)
    self.tips_data.team_status = status
    self:PraseTeamStatus(self.tips_data)
end

function PlayerTips:SetAchivePoint(point)
    self.tips_data.achivePoint = point
    self.achiveTxt.text = tostring(point)
    -- print("此人的成就point" .. point)
    local source_id = AchievementManager.Instance.model:getBadgeSourceId(point)
    -- print(source_id)
    self.achiveBadge_Image.sprite = self.assetWrapper:GetSprite(AssetConfig.badge_icon,tostring(source_id))
    self.achiveBadge_Image.gameObject:SetActive(true)
    self:PraseTeamStatus(self.tips_data)
end

function PlayerTips:SetHonor()
    local honor_name = TI18N("无")
    self.honorTxt.text = honor_name
    local honor_data = DataHonor.data_get_honor_list[self.tips_data.honor_id]
    if  honor_data == nil then
        self.honorTxt.text = honor_name
        return
    end
    if honor_data.type == 3 then
        honor_name = string.format("%s%s", self.tips_data.guild_name, honor_data.name)
    elseif honor_data.type == 7 then
        honor_name = string.format("%s%s", self.tips_data.teacher_name, honor_data.name)
    elseif honor_data.type == 6 then
        honor_name = string.format(TI18N("%s的%s"), self.tips_data.lover_name, honor_data.name)
    else
        honor_name = honor_data.name
    end
    if self.tips_data.looks == nil then
        self.tips_data.looks = {}
    end
    for k,v in pairs(self.tips_data.looks) do
        if v.looks_type == SceneConstData.looktype_honor then
            if v.looks_mode == 2 then
                honor_data = DataHonor.data_get_honor_list[v.looks_val]
                if honor_data ~= nil then
                    if honor_data.type == 6 then
                        honor_name = string.format(TI18N("%s的%s"), v.looks_str, honor_data.name)
                    elseif honor_data.type == 7 then -- 师徒
                        honor_name = string.format("%s%s", v.looks_str, honor_data.name)
                    elseif v.looks_str ~= nil and string.len(v.looks_str) > 0 then
                        honor_name = v.looks_str
                    elseif honor_data.type ~= 3 then
                        honor_name = honor_data.name
                    end
                end
            end
        end
    end

    if DataHonor.data_get_pre_honor_list[self.tips_data.pre_honor_id] ~= nil then
        honor_name = DataHonor.data_get_pre_honor_list[self.tips_data.pre_honor_id].pre_name.. "·" .. honor_name
    end
    self.honorTxt.text = honor_name
end

function PlayerTips:SetRankLev(lev)
    if self.tips_data.lev == nil or self.tips_data.lev < 70 then
        self.RankTxt.text = TI18N("无")
        self.RankBadge_Image.gameObject:SetActive(false)
    else
        local levData = DataTournament.data_list[lev]
        if levData == nil then
            levData = DataTournament.data_list[1]
        end
        self.RankBadge_Image.sprite = self.assetWrapper:GetSprite(AssetConfig.worldchampion_LevIcon, tostring(lev))
        self.RankTxt.text = levData.alias
        self.RankBadge_Image.gameObject:SetActive(true)
    end
end

function PlayerTips:ShowRankTips()
    local lev = self.tips_data.tournament_lev
    local levData = DataTournament.data_list[lev]
    -- self.RankBadgeButton.onClick:RemoveAllListeners()
    if levData == nil then
        return
    end
    -- self.RankBadgeButton.onClick:AddListener(function()
        TipsManager.Instance:ShowText({special = true ,gameObject = self.RankBadgeButton.gameObject, itemData = {
            TI18N("天下第一武道会："),
            TI18N(string.format("<color='#ffff00'>%s</color>",levData.name)),
            }})
    -- end)
end

function PlayerTips:AfterLoadCustom(success)
    self.showModule.gameObject:SetActive(false)
    self.showHeadBtn.gameObject:SetActive(false)
    self.showModule.onClick:RemoveAllListeners()
    self.showHeadBtn.onClick:RemoveAllListeners()

    self.isSuccess = (success == true)
    if success == true then
        self.showModule.gameObject:SetActive(true)
        self.showHeadBtn.gameObject:SetActive(true)
        self.headSlot.gameObject:SetActive(true)
        self.previewComp:Hide()
        self.preview:SetActive(false)
        self.protraitObjBg.gameObject:SetActive(true)
        self.portraitObj:SetActive(true)
        self.showModule.onClick:AddListener(function()
            self.preview:SetActive(true)
            self.previewComp:Show()
            self:LoadPreview()
            self.portraitObj:SetActive(false)
        end)
        self.showHeadBtn.onClick:AddListener(function()
            self.portraitObj:SetActive(true)
            self.preview:SetActive(false)
            self.previewComp:Hide()
        end)
    else
        self.headSlot.gameObject:SetActive(false)
        self.previewComp:Show()
        self.preview:SetActive(true)
        self.protraitObjBg.gameObject:SetActive(false)
    end
end


function PlayerTips:TeacherCheck()
    if self.tips_data.lev == nil then
        return
    end
    if self.tips_data.lev-5 >= RoleManager.Instance.RoleData.lev and RoleManager.Instance.RoleData.lev >= 20 and RoleManager.Instance.RoleData.lev <= 50 and not TeacherManager.Instance.model:IsHasTeahcerStudentRelationShip() and self.tips_data.lev >= 50 then
        self.TeacherBtn.gameObject:SetActive(true)
    else
        self.TeacherBtn.gameObject:SetActive(false)
    end
end

function PlayerTips:OnAt()
    if self.tips_data == nil then
        return
    end

    local str = string.format("@%s", self.tips_data.name)
    local element = {}
    element.type = MsgEumn.AppendElementType.Prefix1
    element.showString = string.format("@%s ", self.tips_data.name)
    element.sendString = string.format("{prefix_1,%s,%s,%s,%s,%s,%s}", RoleManager.Instance.RoleData.name, self.tips_data.name, self.tips_data.id, self.tips_data.platform, self.tips_data.zone_id, ChatManager.Instance:CurrentChannel())
    element.matchString = str
    ChatManager.Instance:AppendInputElement(element, MsgEumn.ExtPanelType.Chat)

    self.model:Closetips()
    WindowManager.Instance:CloseCurrentWindow()
    ChatManager.Instance.model:ShowChatWindow()
end

function PlayerTips:OnWorldChampion()
    if self.tips_data == nil then
        return
    end
    if not self:WorldChampionCheck() then
        NoticeManager.Instance:FloatTipsByString(TI18N("仅<color='#ffff00'>好友</color>和<color='#ffff00'>同公会成员</color>可以查看"))
        return
    end
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.worldchampionshare, {[2] = self.tips_data.roleid, [3] = self.tips_data.platform, [4] = self.tips_data.zoneid})
end

function PlayerTips:UpdateAtTxt()
    if self.tips_data.sex == 0 then
        self.atSomeOneTxt.text = TI18N("@她")
    elseif self.tips_data.sex == 1 then
        self.atSomeOneTxt.text = TI18N("@他")
    end
end