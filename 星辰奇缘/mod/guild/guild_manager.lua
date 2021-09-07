GuildManager = GuildManager or BaseClass(BaseManager)

function GuildManager:__init()
    if GuildManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    GuildManager.Instance = self;
    self:InitHandler()

    self.model = GuildModel.New()
    self.gotoGuildAreaModel = GuildGotoGuildArea.New()
    -- self.pray_model = GuildPrayModel.New()
    self.collection = CollectPanel.New()
    self.randomIndex = -1 --公会宣读地点下标
    -- self.randomPlantFlowerPos = nil --公会种花坐标
    self.isNeedShowPlantFlowerPanel = false

    self.isFirstReceive11100 = true

    self.invite_List = {}
    self.dealinginvite = false
    self.isPlayPraySuccessEffect = false

    self.OnUpdateFundStart = EventLib.New()
    self.funNum = 0
    self.OnUpdateFundGet = EventLib.New()

    self.OnUpdateSpeedUpWin = EventLib.New() -- 当玩家点击加速时重新绘制界面
    self.OnUpdateRightInfo = EventLib.New() -- 当会长/副会长点击解锁额度按钮时重新绘制右边界面
end

function GuildManager:__delete()
    self.model:DeleteMe()
    self.model = nil
    if self.OnUpdateSpeedUpWin ~= nil then
        self.OnUpdateSpeedUpWin:DeleteMe()
        self.OnUpdateSpeedUpWin = nil
    end
    if self.OnUpdateRightInfo ~= nil then
        self.OnUpdateRightInfo:DeleteMe()
        self.OnUpdateRightInfo = nil
    end
end

function GuildManager:InitHandler()
    self:AddNetHandler(11100,self.on11100)
    self:AddNetHandler(11101,self.on11101)
    self:AddNetHandler(11102,self.on11102)
    self:AddNetHandler(11103,self.on11103)
    self:AddNetHandler(11104,self.on11104)
    self:AddNetHandler(11105,self.on11105)
    self:AddNetHandler(11106,self.on11106)
    self:AddNetHandler(11107,self.on11107)
    self:AddNetHandler(11108,self.on11108)
    self:AddNetHandler(11109,self.on11109)
    self:AddNetHandler(11110,self.on11110)
    self:AddNetHandler(11111,self.on11111)
    self:AddNetHandler(11112,self.on11112)
    self:AddNetHandler(11113,self.on11113)
    self:AddNetHandler(11114,self.on11114)
    self:AddNetHandler(11115,self.on11115)
    self:AddNetHandler(11116,self.on11116)
    self:AddNetHandler(11117,self.on11117)
    self:AddNetHandler(11118,self.on11118)
    self:AddNetHandler(11119,self.on11119)
    self:AddNetHandler(11120,self.on11120)
    self:AddNetHandler(11121,self.on11121)
    self:AddNetHandler(11122,self.on11122)
    self:AddNetHandler(11123,self.on11123)
    self:AddNetHandler(11124,self.on11124)
    self:AddNetHandler(11125,self.on11125)
    self:AddNetHandler(11126,self.on11126)
    self:AddNetHandler(11127,self.on11127)
    self:AddNetHandler(11128,self.on11128)
    self:AddNetHandler(11129,self.on11129)
    self:AddNetHandler(11130,self.on11130)
    self:AddNetHandler(11131,self.on11131)
    self:AddNetHandler(11132,self.on11132)
    self:AddNetHandler(11133,self.on11133)
    self:AddNetHandler(11134,self.on11134)
    self:AddNetHandler(11135,self.on11135)
    self:AddNetHandler(11136,self.on11136)
    self:AddNetHandler(11137,self.on11137)
    self:AddNetHandler(11138,self.on11138)
    self:AddNetHandler(11139,self.on11139)
    self:AddNetHandler(11140,self.on11140)
    self:AddNetHandler(11141,self.on11141)
    self:AddNetHandler(11142,self.on11142)
    self:AddNetHandler(11143,self.on11143)
    self:AddNetHandler(11144,self.on11144)
    self:AddNetHandler(11145,self.on11145)
    -- self:AddNetHandler(11146,self.on11146)
    -- self:AddNetHandler(11147,self.on11147)
    -- self:AddNetHandler(11148,self.on11148)
    -- self:AddNetHandler(11149,self.on11149)
    -- self:AddNetHandler(11150,self.on11150)
    -- self:AddNetHandler(11151,self.on11151)
    -- self:AddNetHandler(11152,self.on11152)
    -- self:AddNetHandler(11153,self.on11153)
    -- self:AddNetHandler(11154,self.on11154)
    -- self:AddNetHandler(11155,self.on11155)
    self:AddNetHandler(11156,self.on11156)


    self:AddNetHandler(11157,self.on11157)
    self:AddNetHandler(11158,self.on11158)
    self:AddNetHandler(11159,self.on11159)

    self:AddNetHandler(11161,self.on11161)
    self:AddNetHandler(11162,self.on11162)
    self:AddNetHandler(11163,self.on11163)
    self:AddNetHandler(11164,self.on11164)
    self:AddNetHandler(11165,self.on11165)
    self:AddNetHandler(11166,self.on11166)
    self:AddNetHandler(11167,self.on11167)

    self:AddNetHandler(11168,self.on11168)
    self:AddNetHandler(11169,self.on11169)

    self:AddNetHandler(11170,self.on11170)
    self:AddNetHandler(11171,self.on11171)
    self:AddNetHandler(11172,self.on11172)
    self:AddNetHandler(11173,self.on11173)
    self:AddNetHandler(11174,self.on11174)
    self:AddNetHandler(11175,self.on11175)
    self:AddNetHandler(11176,self.on11176)
    self:AddNetHandler(11177,self.on11177)
    self:AddNetHandler(11178,self.on11178)
    self:AddNetHandler(11179,self.on11179)
    self:AddNetHandler(11180,self.on11180)
    self:AddNetHandler(11181,self.on11181)
    self:AddNetHandler(11182,self.on11182)
    self:AddNetHandler(11183,self.on11183)
    self:AddNetHandler(11184,self.on11184)
    self:AddNetHandler(11185,self.on11185)

    self:AddNetHandler(11186,self.on11186)

    self:AddNetHandler(11187,self.on11187)
    self:AddNetHandler(11188,self.on11188)

    self:AddNetHandler(11189,self.on11189)
    self:AddNetHandler(11190,self.on11190)

    self:AddNetHandler(11191,self.on11191)
    self:AddNetHandler(11192,self.on11192)
    self:AddNetHandler(11193,self.on11193)

    self:AddNetHandler(11194,self.on11194)

    self:AddNetHandler(11195,self.on11195)
    self:AddNetHandler(11196,self.on11196)
    self:AddNetHandler(11197,self.on11197)
    self:AddNetHandler(11198,self.on11198)
    self:AddNetHandler(11199,self.on11199)

    self.on_scene_load = function()
        self:on_switch_scene()
    end

    EventMgr.Instance:AddListener(event_name.scene_load, self.on_scene_load)
    -- EventMgr.Instance:AddListener(event_name.mainui_btn_init, mod_guild.main_ui_loaded)


    self.on_role_change = function(data)
        if self.model:check_has_join_guild() then
            return
        end
        if RoleManager.Instance.RoleData.lev >= 40 then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("你已经达到入会等级，需要一键申请么？")
            data.sureLabel = TI18N("确认")
            data.cancelLabel = TI18N("取消")
            data.cancelSecond = 30
            data.sureCallback = function()
                self:request11161()
            end
            NoticeManager.Instance:ConfirmTips(data)
        end
    end
    EventMgr.Instance:AddListener(event_name.role_level_change, self.on_role_change)

    self.sceneListener = function() self:OnMapLoaded() end
    self.sceneListener1 = function() self:UnitListUpdate() end
end

function GuildManager:UnitListUpdate()
    EventMgr.Instance:RemoveListener(event_name.npc_list_update, self.sceneListener1)
    self:GoToSpecial()
end

function GuildManager:OnMapLoaded()
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.sceneListener)
    self:GoToSpecial()
end

function GuildManager:FindSpecialUnit()
    --有队伍且处于归队状态
    if TeamManager.Instance:HasTeam() and TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Follow then
        NoticeManager.Instance:FloatTipsByString(TI18N("您当前处于归队状态，无法前往公会领地建造祭坛{face_1,15}"))
        return
    end
    if SceneManager.Instance:CurrentMapId() == 30001 then
        self:GoToSpecial()
    else
        EventMgr.Instance:AddListener(event_name.scene_load, self.sceneListener)
        EventMgr.Instance:AddListener(event_name.npc_list_update, self.sceneListener1)
        QuestManager.Instance:Send(11128, {})
    end
end

function GuildManager:GoToSpecial()
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.sceneListener)
    EventMgr.Instance:RemoveListener(event_name.npc_list_update, self.sceneListener1)

    for uniqueid,_ in pairs(SceneManager.Instance.sceneElementsModel.NpcView_List) do
        if string.find(uniqueid, tostring(20101)) ~= nil then
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_AutoPath(30001, uniqueid)
            return
        end
    end
    for uniqueid,_ in pairs(SceneManager.Instance.sceneElementsModel.WaitForCreateUnitData_List) do
        if string.find(uniqueid, tostring(20101)) ~= nil then
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_AutoPath(30001, uniqueid)
            return
        end
    end

    for uniqueid,_ in pairs(SceneManager.Instance.sceneElementsModel.NpcView_List) do
        if string.find(uniqueid, tostring(20102)) ~= nil then
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_AutoPath(30001, uniqueid)
            return
        end
    end
    for uniqueid,_ in pairs(SceneManager.Instance.sceneElementsModel.WaitForCreateUnitData_List) do
        if string.find(uniqueid, tostring(20102)) ~= nil then
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_AutoPath(30001, uniqueid)
            return
        end
    end
end



--监听到场景切换
function GuildManager:on_switch_scene()

    if SceneManager.Instance.sceneModel.sceneView.mapid == self.model.occupy_id then
        --在公会领地中
        self:request11101()
        -- self:request11146()
        self.model:CloseMainUI()
    else
        -- ActivityTrack.Instance:GuildQuestionStop()
    end
end

--主ui加载完成
function GuildManager:main_ui_loaded()
    --请求申请列表
    if self.model:get_my_guild_post() >= GuildManager.Instance.model.member_positions.elder then
        self:request11123()
    end
end

------------------------协议接收逻辑
-- 获取我的公会信息返回
function GuildManager:on11100(data)
    -- Log.Error("GuildManager:on11100(data)------------------------------")
    -- BaseUtils.dump(data,"on11100")
    if self.model.my_guild_data==nil then
        self.model.my_guild_data = {}
    end
    RoleManager.Instance.RoleData.guild_name = self.model.my_guild_data.Name


    self.model.my_guild_data.limit_mode = data.limit_mode -- Insert by 嘉俊 : 加入了保存加速额度的变量limit_mode 2017/8/8
    self.model.my_guild_data.GuildId=data.guild_id
    self.model.my_guild_data.PlatForm=data.platform
    self.model.my_guild_data.ZoneId=data.zone_id
    self.model.my_guild_data.Name=data.name
    self.model.my_guild_data.Name_used=data.name_used
    self.model.my_guild_data.Lev=data.lev
    self.model.my_guild_data.academy_lev=data.academy_lev
    self.model.my_guild_data.exchequer_lev=data.exchequer_lev
    self.model.my_guild_data.store_lev = data.store_lev
    self.model.my_guild_data.Board=data.board
    self.model.my_guild_data.Announcement=data.announcement
    self.model.my_guild_data.Health = data.health
    self.model.my_guild_data.Assets=data.assets
    self.model.my_guild_data.MaxAssets = data.max_assets
    self.model.my_guild_data.UpKeep = data.upkeep
    self.model.my_guild_data.LeaderName = data.leader_name
    self.model.my_guild_data.LeaderRid=data.rid
    self.model.my_guild_data.LeaderPlatform=data.r_platform
    self.model.my_guild_data.LeaderZoneId=data.r_zone_id
    self.model.my_guild_data.LeaderSex = data.leader_sex
    self.model.my_guild_data.LeaderClasses = data.leader_classes
    self.model.my_guild_data.MemNum=data.mem_num
    self.model.my_guild_data.MaxMemNum=data.max_mem_num
    self.model.my_guild_data.FreshNum=data.fresh_num
    self.model.my_guild_data.MaxFreshNum=data.max_fresh_num
    self.model.my_guild_data.MyPost=data.post
    self.model.my_guild_data.ToTem = data.id
    self.model.my_guild_data.ToTemChangeable = data.changeable
    self.model.my_guild_data.lev_time = data.lev_time
    self.model.my_guild_data.academy_time = data.academy_time
    self.model.my_guild_data.exchequer_time = data.exchequer_time
    self.model.my_guild_data.store_time = data.store_time
    self.model.my_guild_data.create_time = data.create_time --创建时间
    self.model.my_guild_data.formalizing_lev = data.formalizing_lev
    self.model.my_guild_data.element_info = data.element_info
    self.model.my_guild_data.upgrade_element_time = data.upgrade_element_time
    self.model.unfresh_man_lev = data.formalizing_lev
    self.model:update_left_guild_info()
    -- EventMgr.Instance:Fire(event_name.guild_update)

    self.model:update_merge_tips_win()

    self.on_mainui_loaded = function(data)
        GuildManager.Instance:request11115()
        EventMgr.Instance:RemoveListener(event_name.mainui_btn_init, self.on_mainui_loaded)
    end
    EventMgr.Instance:AddListener(event_name.mainui_btn_init, self.on_mainui_loaded)


    self.on_guild_fight_status_update = function()
        if self.model:check_has_join_guild() then
            self:on_show_red_point()
        end
    end
    EventMgr.Instance:AddListener(event_name.guild_fight_status_update, self.on_guild_fight_status_update)
    GuildAuctionManager.Instance.OnGoodsUpdate:Add(self.on_guild_fight_status_update)

    self.on_guild_elite_fight_status_update = function()
        if self.model:check_has_join_guild() then
            self:on_show_red_point()
        end
    end
    EventMgr.Instance:AddListener(event_name.guildfight_elite_acitveinfo_change, self.on_guild_elite_fight_status_update)
    EventMgr.Instance:AddListener(event_name.guildfight_elite_leaderinfo_change, self.on_guild_elite_fight_status_update)

    if self.isFirstReceive11100 == true then
        self.isFirstReceive11100 = false
        if GuildManager.Instance.model:has_guild() == true then
            GuildfightManager.Instance:send15500() --登陆后，请求活动状态
            GuildfightManager.Instance:send15501()

            GuildFightEliteManager.Instance:send16200() --公会精英战状态
        end
    end
    self:request11192()
    -- 判断公会攻城战
    GuildSiegeManager.Instance:SetIcon()

    GuildDungeonManager.Instance:Send19500()

    if self.model.build_speedup_win ~= nil and self.model.build_speedup_win.is_open then
        self.OnUpdateSpeedUpWin:Fire()
    end
end

--对主ui上面的图标设置红点，申请列表有人则设置红点
function GuildManager:on_show_red_point()
    local state = false
    if self.model:check_has_join_guild() then
        if self.model.apply_list ~= nil and #self.model.apply_list > 0 then
            state = true
        else
            state = false
        end


        if self.model:get_my_guild_post() ~= nil and self.model:get_my_guild_post() < self.model.member_positions.elder then
            state = false
        end

        --如果申请列表的红点提示为false，就判断下是否有工资可以领取
        if state == false then
            state = self.model:check_can_get_pay()
        end

        if state == false then
            state = GuildfightManager.Instance:IsGuildFightStart()
        end

        if state == false then
            state = GuildFightEliteManager.Instance:checkRedPoint()
        end

        if state == false then
            state = self.model.guild_store_has_refresh
        end

        -- 冠军联赛
        if state == false then
            state = GuildLeagueManager.Instance:CheckRed()
        end

        -- 攻城战
        if state == false then
            state = GuildSiegeManager.Instance:IsMyGuildIn() and GuildSiegeManager.Instance:CheckMeIn() and GuildSiegeManager.Instance.model.status ~= GuildSiegeEumn.Status.Disactive
        end

        if state == false then
            state = (TruthordareManager.Instance.model.openState == 1)
        end

        if state ~= true then
            state = GuildAuctionManager.Instance:CheckRedPonint(true)
        end
    end

    if MainUIManager.Instance.MainUIIconView ~= nil then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(2, state)
    end
end

-- 成员列表
function GuildManager:on11101(data)
    -- print("------------------------------收到11101")
    if self.model.guild_member_list==nil then
        self.model.guild_member_list = {}
    else
        self.model.guild_member_list= {}
    end
    local members=data.members
    for i=1,#members do
        local d = members[i]
        local md = {}

        md.Rid=d.rid
        md.PlatForm=d.platform
        md.ZoneId=d.zone_id
        md.Unique=BaseUtils.get_unique_roleid(md.Rid, md.ZoneId, md.PlatForm)
        md.Name = d.name
        md.Sex = d.sex
        md.Classes=d.classes
        md.Lev=d.lev
        md.Post=d.post
        md.EnterTime = d.enter_time
        md.LastLogin=d.last_login
        md.Status=d.status
        md.Signature=d.signature
        md.GongXian=d.value
        md.TotalGx=d.total_value
        md.cup = d.cup
        md.signed = d.signed
        md.last_signed = d.last_signed
        md.fc = d.fc --战力
        md.guildWarScore = 0 --公会战积分

        md.LeftRedBagNum = d.num
        md.LeftRedBagValue = d.remain
        md.RedBagAmount = d.amount
        md.requirement = d.requirement
        md.active = d.active
        md.ability = d.ability
        table.insert(self.model.guild_member_list, md)
    end

    -- print(BaseUtils.serialize(self.model.guild_member_list, nil, true, 0))

    if self.model.my_guild_data==nil then
        self.model.my_guild_data = {}
    end
    self.model.my_guild_data.MemNum = data.mem_num
    self.model.my_guild_data.MaxMemNum = data.max_mem_num
    self.model.my_guild_data.FreshNum = data.fresh_num
    self.model.my_guild_data.MaxFreshNum = data.max_fresh_num
    self.model.my_guild_data.insist_pray = data.insist_pray
    self.model.my_guild_data.pious_pray = data.pious_pray
    self.model.my_guild_data.grace_pray = data.grace_pray

    self.model:update_left_guild_info()
    self.model:update_member_list()
    self.model:update_info_pray()
    self.model:update_totem_btn()

    -- self.pray_model:update_view()
    -- ui_invite_win.update_item_list()
end



--搜索公会返回
function GuildManager:on11102(data)

    local templist={}
    for i=1,#data.guild_list do
        local data = data.guild_list[i]
        local gd = {}
        gd.GuildId=data.guild_id
        gd.ToTem = data.id
        gd.PlatForm=data.platform
        gd.ZoneId=data.zone_id
        gd.Name=data.name
        gd.Lev=data.lev
        gd.LeaderName = data.leader_name
        gd.LeaderRid=data.leader_id
        gd.LeaderPlatform=data.r_platform
        gd.LeaderZoneId=data.r_zone_id
        gd.LeaderSex=data.leader_sex
        gd.LeaderClasses=data.leader_classes
        gd.LeaderLev=data.leader_lev
        gd.MemNum=data.mem_num
        gd.MaxMemNum=data.max_mem_num
        gd.FreshNum=data.fresh_num
        gd.MaxFreshNum=data.max_fresh_num
        gd.hasApply = false

        table.insert(templist, gd)
    end

    if #templist <= 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("搜索不到对应的公会"))
        return
    end

    self.model:find_win_display_items(templist)
end

-- 创建公会返回
function GuildManager:on11103(data)
    local result=data.result
    local msg=data.msg

    if result==0 then --失败
        -- self.model:CloseCreateUI()
        -- self.model:InitFindUI()
    else--成功
        EventMgr.Instance:Fire(event_name.enter_guild_succ)
        self.model:InitMainUI()
        if self.model.main_win ~= nil then
            GuildManager.Instance:request11101()
        end
    end
    NoticeManager.Instance:FloatTipsByString(msg)
end

-- 申请加入公会返回
function GuildManager:on11104(data)
    -- print("==========================================收到11104")
    local result=data.result
    local msg=data.msg
    if result==0 then--失败

    else--成功
        -- self.model:InitMainUI()
        EventMgr.Instance:Fire(event_name.enter_guild_succ)
        GuildManager.Instance:request11100()
        GuildManager.Instance:request11101()
    end
    self.model:CloseApplyMsgWindow()
    NoticeManager.Instance:FloatTipsByString(msg)
end

-- 主动退出公会或者被开除公会
function GuildManager:on11105(data)
    -- print("============================================收到11105")
    local result=data.result
    local msg=data.msg

    if result==0 then--失败

    else--成功
        self.model.my_guild_data = {}
        self.model.my_guild_data.GuildId = 0
        RoleManager.Instance.RoleData.guild_name = ""
        self.model:CloseMainUI()
        EventMgr.Instance:Fire(event_name.leave_guild_succ)
    end
    NoticeManager.Instance:FloatTipsByString(msg)
end

-- 公会列表返回
function GuildManager:on11106(_data)
    -- print('-------------------------------------收到11106')
    if self.model.guild_list==nil then
        self.model.guild_list = {}
    else
        self.model.guild_list = {}
    end

    local guilds=_data.guild_list

    for i=1,#guilds do
        local data = guilds[i]
        local gd = {}
        gd.GuildId=data.guild_id
        gd.PlatForm=data.platform
        gd.ZoneId=data.zone_id
        gd.Name=data.name
        gd.Lev=data.lev
        gd.LeaderName = data.leader_name
        gd.LeaderRid=data.rid
        gd.LeaderPlatform=data.r_platform
        gd.LeaderZoneId=data.r_zone_id
        gd.LeaderSex=data.leader_sex
        gd.LeaderClasses=data.leader_classes
        gd.LeaderLev=data.leader_lev
        gd.MemNum=data.mem_num
        gd.MaxMemNum=data.max_mem_num
        gd.FreshNum=data.fresh_num
        gd.MaxFreshNum=data.max_fresh_num
        gd.Board = data.board
        gd.Announcement = data.announcement
        gd.Health = data.health
        gd.hasApply = false
        gd.ToTem = data.id
        table.insert(self.model.guild_list, gd)
    end

    self.model:find_win_update_view()
end

-- 我的个人信息
function GuildManager:on11107(data)
    if self.model.my_guild_data==nil then
        self.model.my_guild_data={}
    end
    self.model.my_guild_data.MyPost=data.post
end

-- 设置职务
function GuildManager:on11108(data)
    local result=data.result
    local msg=data.msg

    if result==0 then--失败

    else--成功
        self.model:ClosePositionUI()
    end
    NoticeManager.Instance:FloatTipsByString(msg)
end

-- 开除成员
function GuildManager:on11109(data)
    local result=data.result
    local msg=data.msg

    if result==0 then--失败

    else--成功

    end
    NoticeManager.Instance:FloatTipsByString(msg)
end

-- 单个成员更新
function GuildManager:on11110(data)
    -- print("-----------------------------收到11110")
    local flag = data.flag
    local rid = data.rid
    local platForm=data.platform
    local zoneId=data.zone_id
    local post=data.post
    local GongXian = data.value
    local total_value = data.total_value
    local signed = data.signed
    local last_signed = data.last_signed
    local signature = data.signature
    local num = data.num
    local remain = data.remain

    if self.model.guild_member_list == nil then
        return
    end

    local is_new = true
    for i=1,#self.model.guild_member_list do
        local d = self.model.guild_member_list[i]
        if d ~= nil then
            d.updated = false
            if d.Rid==data.rid and d.PlatForm==data.platform and d.ZoneId==data.zone_id then
                is_new = false
                if flag==1 then--刷新,职位
                    d.Rid= data.rid
                    d.PlatForm= data.platform
                    d.ZoneId= data.zone_id
                    d.Name = data.name
                    d.Sex = data.sex
                    d.Classes= data.classes
                    d.Lev= data.lev
                    d.Post= data.post
                    d.EnterTime = data.enter_time
                    d.LastLogin= data.last_login
                    d.Status= data.status
                    d.Signature= data.signature
                    d.GongXian= data.value
                    d.TotalGx= data.total_value
                    d.cup = data.cup
                    d.signed = data.signed
                    d.last_signed = data.last_signed
                    d.fc = data.fc -- 战力

                    d.LeftRedBagNum = data.num
                    d.LeftRedBagValue = data.remain
                    d.RedBagAmount = data.amount
                    d.requirement = data.requirement
                    d.active = data.active
                    d.ability = data.ability
                    d.updated = true
                    self.model:update_one_member(d)

                elseif flag==2 then--删除
                    d.deleted = true
                    self.model:delete_fire_member(d)
                end
            end
        end
    end

    if flag == 1 and is_new == true then
        --是新增的
        local md = {}
        md.Rid= data.rid
        md.PlatForm= data.platform
        md.ZoneId= data.zone_id
        md.Name = data.name
        md.Sex = data.sex
        md.Classes= data.classes
        md.Lev= data.lev
        md.Post= data.post
        md.EnterTime = data.enter_time
        md.LastLogin= data.last_login
        md.Status= data.status
        md.Signature= data.signature
        md.GongXian= data.value
        md.TotalGx= data.total_value
        md.cup = data.cup
        md.signed = data.signed
        md.last_signed = data.last_signed
        md.fc = data.fc -- 战力
        md.guildWarScore = 0 --公会战积分

        md.LeftRedBagNum = data.num
        md.LeftRedBagValue = data.remain
        md.RedBagAmount = data.amount
        md.requirement = data.requirement
        table.insert(self.model.guild_member_list, md)
    end
    if is_new == true then
        self.model:update_member_list()
    end
end

-- 升级建筑返回
function GuildManager:on11111(data)
    local result=data.result
    local msg=data.msg
    if result==0 then--失败

    else--成功
        -- self:request11100()
        self.model:CloseBuildRestrictionSelectUI()
    end
    NoticeManager.Instance:FloatTipsByString(msg)
end

-- 加速升级返回
function GuildManager:on11112(data)
    self.model:Release_build_speed()
    local result=data.result
    local msg=data.msg
    if result==0 then--失败

    else--成功

    end
    NoticeManager.Instance:FloatTipsByString(msg)
end

-- 公会信息等级
function GuildManager:on11113(data)
    if self.model.my_guild_data==nil then
        self.model.my_guild_data = {}
    end
    -- BaseUtils.dump(data,"gggggggggggggggggggggggggggggggggg")
    self.model.my_guild_data.Lev=data.lev
    self.model.my_guild_data.academy_lev=data.academy_lev
    self.model.my_guild_data.exchequer_lev=data.exchequer_lev
    self.model.my_guild_data.store_lev=data.store_lev
    self.model.my_guild_data.Assets = data.assets

    self.model.my_guild_data.lev_time = data.lev_time
    self.model.my_guild_data.academy_time = data.academy_time
    self.model.my_guild_data.exchequer_time = data.exchequer_time
    self.model.my_guild_data.store_time = data.store_time
    self.model.my_guild_data.element_info = data.element_info
    self.model.my_guild_data.upgrade_element_time = data.upgrade_element_time
    self.model.my_guild_data.formalizing_lev = data.formalizing_lev
    self.model.unfresh_man_lev = data.formalizing_lev

    self.model.my_guild_data.limit_mode = data.limit_mode

    self.model:build_win_update()
    self.OnUpdateSpeedUpWin:Fire()
    self.model:update_left_guild_info()
    self.model:update_fresh_man_win()
    self.model:UpdateManagePanel()
    -- self.pray_model:update_guild_assets()
end

-- 设置公会宗旨返回
function GuildManager:on11114(data)
    if data.result==0 then--失败

    else--成功
        if data.type == 1 then
            --宗旨
            self.model.my_guild_data.Board = data.content
        else
            self.model.my_guild_data.Announcement = data.content
        end
        self.model:ClosePurposeUI()
        self.model:update_left_guild_info()
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 工资信息返回
function GuildManager:on11115(data)
    self.model.pay_data = data
    self.model:update_welfare_pay_item()
    self:on_show_red_point()
    self.model:update_tab_red_point(2)
end

-- 领取工资信息返回
function GuildManager:on11116(data)
    local result=data.result
    local msg=data.msg


    if result==0 then--失败

    else--成功

    end
    NoticeManager.Instance:FloatTipsByString(msg)
end

--公会拆除建筑返回
function GuildManager:on11117(data)
    if data.result==0 then--失败

    else--成功

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function GuildManager:on11118(data)
    local list=data.store_list
    if self.model.store_list==nil then
        self.model.store_list = {}
    else
        self.model.store_list = {}
    end

    -- print("------------------------------收到货栈协议")

    local gsdata = nil
    for i=1,#data.store_list do
        local d = data.store_list[i]
        gsdata = {}
        gsdata.Id=d.id
        gsdata.BaseId=d.base_id
        gsdata.Num=d.num
        gsdata.prices=d.price
        gsdata.Limit=d.limit
        gsdata.RoleNum=d.role_num
        gsdata.type = 1
        table.insert(self.model.store_list, gsdata)
    end

    -- print("--------------store----------------")

    for i=1,#data.normal_goods do
        local d = data.normal_goods[i]
        gsdata = {}
        gsdata.Id=d.id
        gsdata.BaseId=d.base_id
        gsdata.Num=0
        gsdata.prices=d.price
        gsdata.Limit=d.limit
        gsdata.RoleNum=d.role_num
        gsdata.type = 2
        table.insert(self.model.store_list, gsdata)
    end

    -- print("-----------------normal----------------")

    --从配置里面读取
    local cfg_list = self.model:get_store_next_cfg_list()
    for i=1,#cfg_list do
        local dat = cfg_list[i]
        local good_dat = DataGuild.data_get_store_good_data[dat.id]
        local gsdata = {}

        gsdata.Id=good_dat.id
        gsdata.BaseId=good_dat.base_id
        gsdata.Num=good_dat.num
        local prices = {}
        for j=1,#good_dat.assets do
            local price_data = good_dat.assets[j]
            table.insert(prices, {name = price_data.key, val = price_data.val})
        end
        gsdata.prices= prices
        gsdata.Limit=good_dat.limit
        gsdata.RoleNum= 0
        gsdata.type = 3
        table.insert(self.model.store_list, gsdata)
    end

    self.model:update_store_view()
end

-- 返回个人货栈购买记录
function GuildManager:on11119(data)
    self.model:Release_store_exchange()
    local result=data.result
    local msg=data.msg
    local flag = data.flag
    if result==0 then--失败

    else--成功
        -- if  mod_guild.store_win ~= nil and mod_guild.store_win.is_open == true then
        --      mod_guild.store_win.update_right()
        -- end
        self.model:update_store_right()
    end
    if  flag == 0 then--不需要重新请求

    elseif  flag == 1 then--需要重新请求

    end

    self:request11118()


    NoticeManager.Instance:FloatTipsByString(msg)
end



-- 请求货栈刷新时间返回
function GuildManager:on11120(data)
    -- print("-----------------------------收到11120")
    if self.model.my_guild_data.store_lev >= 1 and data.time == 0 then
        self.model.guild_store_has_refresh = true
    end

    self.model.store_flesh_time=data.time
    self.model:update_store_view()
    self:on_show_red_point()

    if self.model.guild_store_has_refresh and self.model.guild_store_is_warm_tips then
        MainUIManager.Instance.noticeView:set_guildnotice_num(1)
    else
        MainUIManager.Instance.noticeView:set_guildnotice_num(0)
    end

    -- if  ui_guild_info_win.is_open == true then
    --     -- ui_guild_info_win.update_wf() --更新货栈
    -- end
    -- if  mod_guild.store_win~=nil and mod_guild.store_win.is_open == true then
    --     self:request11118()
    -- end
end

-- 转让会长返回
function GuildManager:on11121(data)
    local result = data.result
    local msg = data.msg
    if  result == 0 then--失败

    else--成功
        GuildManager.Instance:request11100()
        GuildManager.Instance:request11101()
    end
    NoticeManager.Instance:FloatTipsByString(msg)
end


-- 申请列表返回
function GuildManager:on11123(dat)
    if  self.model.apply_list == nil then
        self.model.apply_list = {}
    else
        self.model.apply_list = {}
    end

    local list = dat.apply_list
    for i=1,#list do
        local data = list[i]
        local ad = {}
        ad.Rid = data.rid
        ad.PlatForm = data.platform
        ad.ZoneId = data.zone_id
        ad.Name = data.name
        ad.Lev = data.lev
        ad.Classes = data.classes
        ad.Sex = data.sex
        ad.Time = data.time
        ad.tag = data.tag
        ad.msg = data.msg
        table.insert(self.model.apply_list, ad)
    end

    self.model:update_apply_list()
    self.model:update_info_apply_list()

    if self.model.my_guild_data ~= nil and self.model:get_my_guild_post() >= GuildManager.Instance.model.member_positions.elder then
        --公会职位比较高的要显示红点
        self:on_show_red_point()
    end
end

--处理加入公会申请返回
function GuildManager:on11124(data)
    -- print("----------------------------------收到11124")
    local result = data.result
    local msg = data.msg
    local flag = data.flag --1删除，0不需要
    local rid = data.rid
    local platForm = data.platform
    local zoneId = data.zone_id
    if  result == 0 then--失败

    else--成功
        self:request11101()
    end
    if  flag == 1 then--需要删除
        if  self.model.apply_list ~= nil then
            for i=1,#self.model.apply_list do
                local d = self.model.apply_list[i]
                if  d.Rid == rid and d.PlatForm == platForm and d.ZoneId == zoneId then
                    table.remove(self.model.apply_list,i)
                    break
                end
            end
        end

        self.model:update_apply_list()
    end

    if self.model:get_my_guild_post() >= GuildManager.Instance.model.member_positions.elder then
        --公会职位比较高的要显示红点
        self:on_show_red_point()
    end
    -- self.model:update_member_list()
    self.model:update_info_apply_list()
    NoticeManager.Instance:FloatTipsByString(msg)
end

-- 修改个性签名返回
function GuildManager:on11125(data)
    local result = data.result
    local msg = data.msg
    local rid = data.rid
    local platForm = data.platform
    local zoneId = data.zone_id
    local signature = data.signature
    local signable = data.signable

    self.model.my_guild_data.Signable = signable

    if  result == 0 then--失败

    else--成功
        self.model:CloseChangeSignatureUI()
        self.model:update_guild_signature(signature)

    end


    NoticeManager.Instance:FloatTipsByString(msg)
end

-- 公会事件列表返回
function GuildManager:on11126(data)
end

-- 清空申请列表返回
function GuildManager:on11127(data)
    local result = data.result
    local msg = data.msg
    if  result == 0 then--失败

    else--成功
        self.model.apply_list = {}
        self.model:update_apply_list()
    end
    NoticeManager.Instance:FloatTipsByString(msg)

    -- print("================================清空列表返回")
    if self.model:get_my_guild_post() >= GuildManager.Instance.model.member_positions.elder then
        --公会职位比较高的要显示红点
        self:on_show_red_point()
    end
end

-- 请求进入公会领地返回
function GuildManager:on11128(data)
    local result = data.result
    local msg = data.msg

    if  result == 0 then--失败

    else--成功

    end
    NoticeManager.Instance:FloatTipsByString(msg)
end

-- 请求进入公会领地返回
function GuildManager:on11129(data)
    local result = data.result
    local msg = data.msg
    if  result == 0 then--失败
    else--成功
        self.model:CloseMainUI()
        -- HomeManager.Instance:ShowOtherUI()
    end
    NoticeManager.Instance:FloatTipsByString(msg)
end


--公会捐献
function GuildManager:on11130(data)
    if  data.result == 0 then--失败
    else--成功
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--发红包
function GuildManager:on11131(data)
    self.model:CloseRedBagSetUI()

    if RoleManager.Instance.RoleData.id == data.id and RoleManager.Instance.RoleData.zone_id == data.zone_id and RoleManager.Instance.RoleData.platform == data.platform then
        NoticeManager.Instance:FloatTipsByString(TI18N("你的红包成功派发到公会"))
    end

    -- 收到红包广播，丢到聊天里面
    local msgData = MessageParser.GetMsgData(data.title)
    local chatData = ChatData.New()
    chatData.rid = data.id
    chatData.platform = data.platform -- 平台
    chatData.zone_id = data.zone_id -- 区号
    chatData.name = data.name -- 名字
    chatData.sex = data.sex -- 性别
    chatData.classes = data.classes -- 职业
    chatData.lev = data.lev
    chatData.msg = data.title -- 内容
    chatData.showType = MsgEumn.ChatShowType.Redpack
    chatData.msgData = msgData
    chatData.prefix = MsgEumn.ChatChannel.Guild
    chatData.channel = MsgEumn.ChatChannel.Guild
    ChatManager.Instance.model:ShowMsg(chatData)
end

--红包信息
function GuildManager:on11132(data)
    -- print("----------------------------收到11132")
    self.model.current_red_bag = data
    --抢夺记录里面有自己说明已经抢夺过了
    for i=1, #data.log do
        local lo = data.log[i]
        if RoleManager.Instance.RoleData.id == lo.rid and RoleManager.Instance.RoleData.zone_id == lo.r_zone_id and RoleManager.Instance.RoleData.platform == lo.r_platform then
            --已经领取过
            self.model:InitRedBagUI()
            return
        end
    end
    if data.num > 0 then
        --未领取
        self.model:InitUnRedBagUI()
    else
        --已经被领完
        self.model:InitRedBagUI()
    end
end

--抢夺祈祷红包
function GuildManager:on11133(data)
    local s_uniqueid = BaseUtils.get_unique_roleid(data.s_id, data.s_zone_id, data.s_platform)
    local t_uniqueid = BaseUtils.get_unique_roleid(data.t_id, data.t_zone_id, data.t_platform)
    local str = ""
    if s_uniqueid == t_uniqueid then
        -- 自己操作自己
        -- 如果自己是发送者，显示别人领取自己的红包的情况
        str = TI18N("自己领取了自己的红包")
    else
        if t_uniqueid == BaseUtils.get_self_id() then
            str = string.format(TI18N("{role_2,%s}领取了你的红包"), data.s_name)
        else
            -- 如果不是自己发的，显示自己领取了了谁的红包
            str = string.format(TI18N("你领取了{role_2,%s}的红包"), data.t_name)
        end
    end
    local msgData = MessageParser.GetMsgData(str)
    local chatData = ChatData.New()
    chatData.rid = data.t_id
    chatData.platform = data.t_platform -- 平台
    chatData.zone_id = data.t_zone_id -- 区号
    chatData.name = data.t_name -- 名字
    chatData.msg = msgData.showString
    chatData.showType = MsgEumn.ChatShowType.RedpackNotice
    chatData.msgData = msgData
    chatData.prefix = MsgEumn.ChatChannel.System
    chatData.channel = MsgEumn.ChatChannel.Guild
    ChatManager.Instance.model:ShowMsg(chatData)
end

--神兽信息
function GuildManager:on11134(data)
    if self.model.shenshou_data == nil then
        self.model.shenshou_data = {}
    end
    self.model.shenshou_data.name = data.name
    self.model.shenshou_data.lev = data.lev
    self.model.shenshou_data.step = data.step --阶数
    self.model.shenshou_data.exp = data.exp --当前经验
    self.model.shenshou_data.called = data.called -- 0未召唤出来，1已召唤出来
    self.model.shenshou_data.last_renamed = data.last_renamed
    self.model.shenshou_data.log = data.log

    -- if mod_guild.shenshou_win ~= nil and mod_guild.shenshou_win.is_open == true then
    --     mod_guild.shenshou_win.update_view()
    -- end
end

--喂养神兽
function GuildManager:on11135(data)
    local result = data.result
    local msg = data.msg
    if  result == 0 then--失败

    else--成功
        -- if mod_guild.shenshou_win ~= nil and mod_guild.shenshou_win.is_open == true then
        --     mod_guild.shenshou_win.update_view()
        -- end
    end
    NoticeManager.Instance:FloatTipsByString(msg)
end

--召唤神兽
function GuildManager:on11136(data)
    local result = data.result
    local msg = data.msg
    if  result == 0 then--失败

    else--成功

    end
    NoticeManager.Instance:FloatTipsByString(msg)
end

--获取佣兵营地数据
function GuildManager:on11137(data)
    self.model.guild_soldiers = data.mercenarys
    -- if mod_guild.soldier_win ~= nil and mod_guild.soldier_win.is_open == true then
    --     ui_guild_soldier_win.update_view()
    -- end
end

--派遣雇佣兵
function GuildManager:on11138(data)
    local result = data.result
    local msg = data.msg
    if  result == 0 then--失败

    else--成功
        self:request11141()
    end
    NoticeManager.Instance:FloatTipsByString(msg)
end

--召回雇佣兵
function GuildManager:on11139(data)
    local result = data.result
    local msg = data.msg
    if  result == 0 then--失败

    else--成功
        self:request11141()
    end
    NoticeManager.Instance:FloatTipsByString(msg)
end

--公会成员外观返回
function GuildManager:on11140(data)
    self.model:update_info_mem_model(data.looks)
end

--获取自己已派遣的佣兵
function GuildManager:on11141(data)
    self.model.mine_soldier = {}
    for i=1,#data.mercenarys do
        local dat = data.mercenarys[i]
        self.model.mine_soldier[dat.base_id] = dat
    end
        -- if mod_guild.soldier_win ~= nil and mod_guild.soldier_win.is_open == true then
            -- ui_guild_soldier_win.update_view()
        -- end

    -- ui_guild_info_win.update_info_mem_model(data.looks)
end


--获取某个佣兵数据
function GuildManager:on11142(data)
    local base_id = data.base_id --守护id

    local temp_dat = mod_shouhu.get_sh_base_dat_by_id(base_id)
    local dat = utils.copytab(temp_dat) --从配置data里面复制一个出来就有配置里面的数据了
    dat.rid = data.rid
    dat.platform = data.platform
    dat.zone_id = data.zone_id
    dat.owner_name = data.name
    dat.lev = data.lev
    dat.recruited = data.recruited
    dat.dispatched = data.dispatched

    dat.score = data.score
    dat.has_get_skill_list = {}

    local skills = data.skills
    for i=1,#skills do --守护已获得的技能id
        local item2 = skills[i]
        local skillId = item2.skill_id
        table.insert(dat.has_get_skill_list, skillId)
    end

    dat.guard_fight_state=data.status
    dat.tactic_index = data.tactic
    dat.tactic_pos=data.tac_pos

    if dat.sh_attrs_list == nil then
        dat.sh_attrs_list = {}
    end
    local shAttrs=data.attrs
    for i=1,#shAttrs do
        local item2 = shAttrs[i]
        local attrData = {}
        attrData.attr=item2.attr
        attrData.val = item2.value
        table.insert(dat.sh_attrs_list, attrData)
    end

    dat.equip_list = {}
    mod_shouhu.init_equip_list(dat)
    local equips = data.eqm
    for i=1,#equips do --守护装备数据
        local item2 = equips[i]
        local equipBid = item2.base_id
        local _type = item2.type --装备类型
        local lev = item2.lev --装备等级

        local cfgEqDat = mod_shouhu.get_equip_data_by_type_and_lev(_type,lev, dat.classes)
        local eqDat = nil
        for i=1,#dat.equip_list do
            local tempd = dat.equip_list[i]
            if tempd.type == _type then
                eqDat =  tempd
                break
            end
        end
        eqDat.lev = lev
        eqDat.base_id = cfgEqDat.base_id --服务端返回的base_id有错误，还是客户端直接去配置取算了
        eqDat.loss = cfgEqDat.loss

        eqDat.base_attrs = item2.base_attrs


        eqDat.ext_attrs =item2.ext_attrs

        eqDat.reset_base_attrs =item2.reset_base_attrs

        eqDat.reset_ext_attrs =item2.reset_ext_attrs

        local iSaveReset = item2.is_save_reset
        eqDat.is_save_reset=iSaveReset
    end

    -- if mod_guild.soldier_look_win ~= nil and mod_guild.soldier_look_win.is_open == true then
    --     mod_guild.soldier_look_win.update_view(dat)
    -- end
end

function GuildManager:on11143(data)
    local result = data.result
    local msg = data.msg

    if  result == 0 then--失败

    else--成功
        -- if mod_guild.change_shenshou_win ~= nil and mod_guild.change_shenshou_win.is_open == true then
        --     mod_guild.change_shenshou_win.close_my_self()
        -- end

        -- local str = data.name
        -- if mod_guild.shenshou_win ~= nil and mod_guild.shenshou_win.is_open == true then
        --     mod_guild.shenshou_win.update_shenshou_name(str)
        -- end
    end
    NoticeManager.Instance:FloatTipsByString(msg)
end

function GuildManager:on11144(data)
    local result = data.result
    local msg = data.msg
    local totem = data.totem
    if  result == 0 then--失败

    else--成功
        self.model.my_guild_data.ToTemChangeable = self.model.my_guild_data.ToTemChangeable - 1
        self.model.my_guild_data.ToTem = totem
        self.model:CloseTotemUI()
        self.model:update_ToTem_icon(totem)

    end

    NoticeManager.Instance:FloatTipsByString(msg)
end

function GuildManager:on11145(data)
    local result = data.result
    local msg = data.msg
    local totem = data.changeable
    if  result == 0 then--失败

    else--成功
        self.model.my_guild_data.ToTemChangeable = totem
        self.model:update_totem_change_time()
    end
    NoticeManager.Instance:FloatTipsByString(msg)
end

function GuildManager:on11156(data)
    -- print("--------------------------------11156回来拉")
    local str = ""
    if data.time > 0 then
        str = string.format("%s%s%s", TI18N("宝箱里可能藏有巨大的宝藏，需要在"), data.time, TI18N("秒后才可开启"))
    else
        str = TI18N("宝箱里可能藏有巨大的宝藏")
    end
    str = string.format("%s<color='%s'>%s</color>", str, utils.color[4], TI18N("（长老职位以上的成员才可打开）"))
    -- mod_notify.open_confirm_win(str, TI18N("提示"), function()
        if self.model:get_my_guild_post() < GuildManager.Instance.model.member_positions.elder then
    --         local str2 = string.format("<color='%s'>%s</color>%s", utils.color[1], TI18N("长老"), TI18N("以上的成员才可打开宝箱"))
    --         mod_notify.append_scroll_win(str2)
    --         return
        end
end

--获取自荐会长列表返回
function GuildManager:on11157(data)
    self.model:update_recommend_list(data.usurpers)
end

--自荐会长返回
function GuildManager:on11158(data)
    if data.flag == 0 then
        --失败
    elseif data.flag == 1 then
        --成功
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--反对自荐
function GuildManager:on11159(data)
    if data.flag == 0 then
        --失败
    elseif data.flag == 1 then
        --成功
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--反对自荐
function GuildManager:on11161(data)
    if data.flag == 0 then
        --失败
    elseif data.flag == 1 then
        --成功
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--反对自荐
function GuildManager:on11162(data)
    self.model:Release_store_exchange()
    if data.result == 0 then
        --失败
    elseif data.result == 1 then
        --成功
        self.model:update_store_right()
    end
    self:request11118()
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--收到公会邮件返回
function GuildManager:on11168(data)
    -- print("---------------------------------收到11168")

    if data.result == 0 then
        --失败
    elseif data.result == 1 then
        --成功
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function GuildManager:on11163(data)
    --BaseUtils.dump(data, "on11163")
    --Log.Error("公会宣读 开始读条")
    if data.result == 1 then
        --宣读成功
        --self:ShowPublicityCollection()
    else
        --宣读失败
    end
end

function GuildManager:on11169(data)
    QuestManager.Instance.model.questGuild:GoPlantFlower(data.battle_id,data.id)
end

function GuildManager:on11164(data)
    if data.result == 1 then
        --宣读完成
    else
        --宣读未完成
    end
end

function GuildManager:on11165(data)
    -- BaseUtils.dump(data, "on11165")
    if data.result == 1 then
        --种花成功
    else
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end

function GuildManager:on11166(data)
    -- BaseUtils.dump(data, "on11166--打开种花界面")
    --打开种花界面
    self.model:ShowGuildPlantFlowerPanel(data)
end

function GuildManager:on11167(data)
    if data.result == 0 then
    elseif data.result == 1 then

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--获取合并请求列表
function GuildManager:on11170(data)
    -- print("--------------------------------------收到11170")

    --组装一个数据列表给合并界面
    local list = {}
    local temp_list = {}
    for i=1,#data.applys do
        local d = data.applys[i]
        temp_list[string.format("%s_%s_%s", d.g_id, d.g_platform, d.g_zone_id)] = d
    end
    for i=1, #self.model.guild_list do
        local d = self.model.guild_list[i]
        if d.GuildId ~= self.model.my_guild_data.GuildId or d.PlatForm ~= self.model.my_guild_data.PlatForm or d.ZoneId ~= self.model.my_guild_data.ZoneId then
            if temp_list[string.format("%s_%s_%s", d.GuildId, d.PlatForm, d.ZoneId)] ~= nil then
                --存在
                table.insert(list, d)
            else
                if self.model.my_guild_data.Health >= 40 and self.model.my_guild_data.Health <= 60 then
                    if d.Health >= 21 and d.Health <= 39 then
                        table.insert(list, d)
                    end
                end
            end
        end
    end
    self.model.merge_list = list
    self.model:update_merge_win_list(list)
end

--获取已发过的合并请求
function GuildManager:on11171(data)
    -- print("--------------------------------------收到11171")


    --组装一个数据列表给合并界面
    local list = {}
    local temp_list = {}
    for i=1,#data.applyed do
        local d = data.applyed[i]
        temp_list[string.format("%s_%s_%s", d.a_id, d.a_platform, d.a_zone_id)] = d
    end
    --从公会列表中过滤已经申请过的
    for i=1, #self.model.guild_list do
        local d = self.model.guild_list[i]

        -- print("公会id:"..d.GuildId..",监看度："..d.Health)
        if d.GuildId ~= self.model.my_guild_data.GuildId or d.PlatForm ~= self.model.my_guild_data.PlatForm or d.ZoneId ~= self.model.my_guild_data.ZoneId then
            if temp_list[string.format("%s_%s_%s", d.GuildId, d.PlatForm, d.ZoneId)] == nil then
                -- if d.Health >= 61 and d.Health <= 80 then
                -- if d.Health >= 40 and d.Health <= 100 then
                --     if self.model.my_guild_data.Health <= 80 then
                        table.insert(list, d)
                    -- end
                -- end
            end
        end
    end
    self.model.merge_list = list
    self.model:update_merge_win_list(list)
end

--申请被合并
function GuildManager:on11172(data)
    -- print("--------------------------------------收到11172")
    if data.result == 0 then

    elseif data.result == 1 then
        self.model.reset_info = true
        self.model:CloseGuildMergeUI()
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--合并指定公会
function GuildManager:on11173(data)
    -- print("--------------------------------------收到11173")
    if data.result == 0 then

    elseif data.result == 1 then
        self.model.reset_info = true
        GuildManager.Instance:request11100()
        self.model:CloseGuildMergeUI()
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--兑换贡献
function GuildManager:on11174(data)
    -- print("--------------------------------------收到11174")
    if data.result == 0 then

    elseif data.result == 1 then

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--获取剩余兑换贡献次数
function GuildManager:on11175(data)
    -- print("--------------------------------------收到11175")
    self.model.npc_exchange_left_num = data.remain
    self.model:update_left_exchange_num()
    self.model:update_welfare_left_exchange()
end

--获取剩余兑换贡献次数
function GuildManager:on11176(data)
    -- print("--------------------------------------收到11175")
    local n_data = NoticeConfirmData.New()
    n_data.type = ConfirmData.Style.Normal
    local str = string.format("<color='#01c0ff'>%s</color>%s<color='#2fc823'>%s</color>%s", data.name, TI18N("的"), data.leader_name,TI18N("对我们公会发出合并申请，是否要同意请求（可在NPC-公会议长查看请求列表列表再同意对方）"))
    n_data.content = str
    n_data.sureLabel = TI18N("同意合并")
    n_data.cancelLabel = TI18N("我再想想")
    n_data.sureCallback = function()
        self:request11173(data.g_id, data.g_platform, data.g_zone_id, 1)
    end
    n_data.cancelCallback = function()
        NoticeManager.Instance:FloatTipsByString(TI18N("你已经暂时拒绝，可在公会议长处查看公会合并列表"))
        -- self:request11173(data.g_id, data.g_platform, data.g_zone_id, 0)
    end
    NoticeManager.Instance:ConfirmTips(n_data)
end
--公会秘藏
function GuildManager:on11177(data)
    self.model.guildTreasure = data

    GuildfightManager.Instance.model:OpenGuildFightSetTimePanelFrom11177()
    if MainUIManager.Instance.dialogModel.isOpenning == true then
        MainUIManager.Instance.dialogModel:UpdateDialogData()
    end
end

--设定宝藏开启时间
function GuildManager:on11178(data)
    if data.result == 1 then
         NoticeManager.Instance:FloatTipsByString(TI18N("开启时间设定成功"))
    else
        if data.msg ~= "" then
            NoticeManager.Instance:FloatTipsByString(data.msg)
        end
    end
end

--打开宝藏
function GuildManager:on11179(data)
end
--功勋宝箱（战利品宝库）
function GuildManager:on11180(data)
    -- Log.Error("GuildManager:on11180(data) ----------------------------------------")
    local guildfightbox = {items = {}, log = {}, allocated = {}}
    local guildleaguebox = {items = {}, log = {}, allocated = {}}
    for k,v in pairs(data.items) do
        if v.base_id == 23020 then
            guildleaguebox.items = {v}
        else
            guildfightbox.items = {v}
        end
    end
    for k,v in pairs(data.log) do
        if v.base_id == 23020 then
            table.insert(guildleaguebox.log, v)
        else
            table.insert(guildfightbox.log, v)
        end
    end
    for k,v in pairs(data.allocated) do
        if v.base_id == 23020 then
            table.insert(guildleaguebox.allocated, v)
        else
            table.insert(guildfightbox.allocated, v)
        end
    end
    self.model.guildLoot = guildfightbox
    self.model.guildLeagueLoot = guildleaguebox
    EventMgr.Instance:Fire(event_name.guild_box_count_change)
end
----分配宝箱
function GuildManager:on11181(data)
    if data.result == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("发放成功"))
    else
        if data.msg ~= "" then
            NoticeManager.Instance:FloatTipsByString(data.msg)
        end
    end
end

--公会改名
function GuildManager:on11187(data)
    -- print('----------------------收到11187')
    if data.result == 1 then
        self.model:CloseChangeNameUI()
        self.model.my_guild_data.Name=data.name
        self.model.my_guild_data.Name_used=data.name_used
        --更新公会主面板显示
        self.model:update_left_guild_info()
    else

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--------------------------------------------------------------请求逻辑
--请求获取我的公会信息
function GuildManager:request11100()
    Connection.Instance:send(11100, {})
end

--请求公会成员列表
function GuildManager:request11101()
    Connection.Instance:send(11101, {})
end

--搜索公会成员列表
function GuildManager:request11102(_name)
    -- print("=====================================请求11102，搜索:".._name)
    Connection.Instance:send(11102, {name = _name})
end

--传入公会和公告，请求创建公会
function GuildManager:request11103(_name,_notice)
    if name=="" then
        NoticeManager.Instance:FloatTipsByString(TI18N("请输入公会名称！"))
        return
    end
    Connection.Instance:send(11103, {name=_name,notice=_notice})
end

--申请加入公会
function GuildManager:request11104(_guild_id,_platform,_zone_id, tag, msg)
    -- print("-------------------------发送11104")
    Connection.Instance:send(11104, {guild_id=_guild_id,platform=_platform,zone_id=_zone_id, tag = tag, msg = msg})
end

--请求退出公会
function GuildManager:request11105()
    Connection.Instance:send(11105, {})
end

--请求公会列表
function GuildManager:request11106()
    Connection.Instance:send(11106, {})
end


--请求设置职务
function GuildManager:request11108(_rid,_platform,_zone_id,_post)
    Connection.Instance:send(11108, {rid=_rid,platform=_platform,zone_id=_zone_id,post=_post})
end

--开除成员
function GuildManager:request11109(_rid,_platform,_zone_id)
    Connection.Instance:send(11109, {rid=_rid,platform=_platform,zone_id=_zone_id})
end

--升级建筑，"类型 0:公会 1:研究 2:金库 3:货栈
function GuildManager:request11111(type, model)
    Connection.Instance:send(11111, {type = type, mode = model})
end

--请求加速升级建筑,1-4方式，类型 0:公会 1:城堡 2:研究 3:锻造 4:货栈
function GuildManager:request11112 (_type,_use_mode)
    self.model:Frozen_build_speed()
    Connection.Instance:send(11112, {type=_type,mode=_use_mode})
end

-- 请求公会信息等级
function GuildManager:request11113()
    Connection.Instance:send(11113, {})
end

-- 请求设置公会公告
function GuildManager:request11114 (_content, _type)
    Connection.Instance:send(11114, {content=_content, type = _type})
end

-- 请求工资信息
function GuildManager:request11115()
    Connection.Instance:send(11115, {})
end

-- 请求领取工资 1:今天 2:本周
function GuildManager:request11116(_type)
    Connection.Instance:send(11116, {type = _type})
end

-- 请求拆除建筑
function GuildManager:request11117(_type)
    -- print("---------------------------发送11117")
    Connection.Instance:send(11117, {type = _type})
end

-- 请求货栈数据
function GuildManager:request11118()
    Connection.Instance:send(11118, {})
end

-- 请求购买货栈数据
function GuildManager:request11119(_id,_num)
    self.model:Frozen_store_exchange()
    Connection.Instance:send(11119, {id=_id,num=_num})
end

-- 请求货栈刷新时间
function GuildManager:request11120()
    Connection.Instance:send(11120, {})
end

-- 转让会长
function GuildManager:request11121(_rid,_platform,_zone_id)
    Connection.Instance:send(11121, {rid=_rid,platform=_platform,zone_id=_zone_id})
end

-- 申请加入条件设置
function GuildManager:request11122(_flag,_type,_lev)
    Connection.Instance:send(11122, {flag=_flag,type=_type,lev=_lev})
end

-- 请求申请列表
function GuildManager:request11123()
    Connection.Instance:send(11123, {})
end

-- 处理申请
-- <param name="type">0拒绝，1统一</param>
function GuildManager:request11124(_rid, _platform, _zone_id, _type)
    Connection.Instance:send(11124, {rid=_rid,platform=_platform,zone_id=_zone_id,type=_type})
end

-- 请求设置个性签名
function GuildManager:request11125(_rid, _platform, _zone_id, _signature)
    Connection.Instance:send(11125, {rid=_rid,platform=_platform,zone_id=_zone_id,signature=_signature})
end

-- 请求公会事件列表
function GuildManager:request11126()
    Connection.Instance:send(11126, {})
end

-- 请求清空申请列表
function GuildManager:request11127()
    -- print("=-======================================发送11127")
    Connection.Instance:send(11127, {})
end

-- 请求进入公会领地
function GuildManager:request11128()
    self.model:CloseMainUI()
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(2)
    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
    Connection.Instance:send(11128, {})
end

-- 请求进入公会领地
function GuildManager:request11129()
    Connection.Instance:send(11129, {})
end

-- 公会捐献
function GuildManager:request11130(_num) --数量
    Connection.Instance:send(11130, {num=_num})
end

-- 发红包
function GuildManager:request11131(_title, _num, _type, _source)
    -- print("-------------------发送11131")
    Connection.Instance:send(11131, {title = tostring(_title), num = tonumber(_num), type = tonumber(_type), source = _source})
end

-- 抢夺红包
function GuildManager:request11132(_id, _zone_id, _platform)
    -- print("---------------------发送11132")
    Connection.Instance:send(11132, {id = _id, platform=_platform, zone_id=_zone_id})
end

-- 抢夺祈祷红包
function GuildManager:request11133(_id, _platform, _zone_id)
    Connection.Instance:send(11133, {id = _id, platform=_platform, zone_id=_zone_id})
end

-- 神兽信息
function GuildManager:request11134()
    Connection.Instance:send(11134, {})
end

-- 喂养神兽
--类型，0:银币 1:金币
function GuildManager:request11135(_type)
    Connection.Instance:send(11135, {type=_type})
end

-- 召唤神兽
function GuildManager:request11136()
    Connection.Instance:send(11136, {})
end

-- 获取佣兵营地数据
function GuildManager:request11137()
    Connection.Instance:send(11137, {})
end

-- 派遣雇佣兵
--守护类型id
function GuildManager:request11138(_base_id)
    Connection.Instance:send(11138, {base_id=_base_id})
end

-- 召回雇佣兵
function GuildManager:request11139(_base_id)
    Connection.Instance:send(11139, {base_id=_base_id})
end

--11140请求公会成员外观
function GuildManager:request11140(_rid, _platform, _zone_id)
    Connection.Instance:send(11140, {rid=_rid, platform=_platform, zone_id=_zone_id})
end


--获取自己已派遣的佣兵
function GuildManager:request11141()
    Connection.Instance:send(11141, {})
end


--获取某个佣兵数据
function GuildManager:request11142(_rid, _platform, _zone_id, _base_id)
    Connection.Instance:send(11142, {rid = _rid, platform = _platform, zone_id = _zone_id, base_id = _base_id})
end

--请求修改神兽的名字
function GuildManager:request11143(_name)
    Connection.Instance:send(11143, {name = _name})
end

--请求修改图腾形象
function GuildManager:request11144(_id)
    Connection.Instance:send(11144, {totem = _id})
end

--请求增加修改图腾的次数
function GuildManager:request11145()
    Connection.Instance:send(11145, {})
end

--请求公会强盗宝箱时间
function GuildManager:request11156(_battle_id, _id)
    -- print("---------------------------------发送11156")
    Connection.Instance:send(11156, {battle_id = _battle_id, id = _id})
end


--获取自荐会长列表
function GuildManager:request11157()
    -- print("---------------------------------发送11157")
    Connection.Instance:send(11157, {})
end

--自荐会长
function GuildManager:request11158()
    -- print("---------------------------------发送11158")
    Connection.Instance:send(11158, {})
end

--反对自荐
function GuildManager:request11159(_rid, _platform, _zone_id)
    -- print("---------------------------------发送11159")
    Connection.Instance:send(11159, {rid = _rid, platform = _platform, zone_id = _zone_id})
end

--登录获取公会聊天记录
function GuildManager:request11160()
    Connection.Instance:send(11160, {})
end

--登录获取公会聊天记录
function GuildManager:request11161()
    Connection.Instance:send(11161, {})
end

-- 请求购买货栈普通道具
function GuildManager:request11162(_id,_num)
    self.model:Frozen_store_exchange()
    Connection.Instance:send(11162, {id=_id,num=_num})
end

function GuildManager:request11163()
    --公会宣读
    Connection.Instance:send(11163,{})
end

function GuildManager:request11164()
    --公会宣读完成
    --Log.Error("11164 发协议到后端，公会宣读任务完成")
    LuaTimer.Add(100, function () Connection.Instance:send(11164,{}) end)
end

function GuildManager:request11165(xPos,yPos)
    --公会种花
    Connection.Instance:send(11165,{x=xPos,y=yPos})
end

function GuildManager:request11166(battleid,uid)
    --鲜花信息
    Connection.Instance:send(11166,{battle_id=battleid,id = uid})
end

function GuildManager:request11167(battleid,idTemp)
    --浇水
    Connection.Instance:send(11167,{battle_id=battleid,id = idTemp})
end

---发送公会邮件
function GuildManager:request11168(_title, _content)
    -- print("--------------------------------------发送11168")
    Connection.Instance:send(11168,{title=_title, content=_content})
end


function GuildManager:request11169()
    --获取自己种的花
    Connection.Instance:send(11169,{})
end

--获取合并请求列表
function GuildManager:request11170()
    -- print('----------------------------------发送11170')
    Connection.Instance:send(11170,{})
end

--获取已发过的合并请求
function GuildManager:request11171()
    -- print('----------------------------------发送11171')
    Connection.Instance:send(11171,{})
end

--申请被合并
function GuildManager:request11172(_id, _platform, _zone_id)
    -- print('----------------------------------发送11172')
    Connection.Instance:send(11172,{id = _id, platform = _platform, zone_id = _zone_id})
end

--合并指定公会
function GuildManager:request11173(_id, _platform, _zone_id, _decision)
    -- print('----------------------------------发送11173')
    -- print(_decision)
    local d = _decision
    if d == nil then
        d = 1
    end
    Connection.Instance:send(11173,{id = _id, platform = _platform, zone_id = _zone_id, decision = d})
end

--兑换贡献
function GuildManager:request11174(_type)
    -- print('----------------------------------发送11174')
    Connection.Instance:send(11174,{type = _type})
end

--获取剩余兑换贡献次数
function GuildManager:request11175()
    -- print('----------------------------------发送11175')
    Connection.Instance:send(11175,{})
end
--获取宝藏信息
function GuildManager:request11177()
    -- print('----------------------------------发送11177')
    Connection.Instance:send(11177,{})
end
--设定宝藏开启时间
function GuildManager:request11178(openTime)
    -- print('----------------------------------发送11178')
    Connection.Instance:send(11178,{time = openTime})
end

--打开宝藏
function GuildManager:request11179()
    -- print('----------------------------------发送11179')
    Connection.Instance:send(11179,{})
end
--功勋宝箱（战利品宝库
function GuildManager:request11180()
    -- print('----------------------------------发送11180')
    Connection.Instance:send(11180,{})
end
--分配宝箱
function GuildManager:request11181(tableTemp)
    -- print('----------------------------------发送11181')
    Connection.Instance:send(11181,{alloc = tableTemp})
end


--登录初始化
function GuildManager:RequestInitData()
    self:request11100()
    self:request11160()
    self:request11123()
    self:request11101()
    -- if self.model:has_guild() == true then
    --     self:request11177()
    -- end
    self:request11177()
end
---------------------------------------------其他一些接口
function GuildManager:ShowPublicityCollection(lastTime,cancelCB)
    local func = function()
        --Log.Error("发协议到后端，公会宣读任务完成")
        --GuildManager.Instance:request11164()
        GuildManager.Instance:request11163()
        self.randomIndex = -1
    end
    self.collection.callback = func
    self.collection.cancelCallBack = cancelCB
    self.collection.unitActionType = SceneConstData.UnitAction.Stand
    self.collection:Show({msg = TI18N("宣读中......"), time = lastTime})
end

function GuildManager:ShowPlantFlowerCollection(lastTime,pos)
    local func = function()
        --GuildManager.Instance:request11164()
        -- Log.Error("发协议到后端 开始种花")
        self.isNeedShowPlantFlowerPanel = true
        QuestManager.Instance.model.questGuild.posData = nil
        GuildManager.Instance:request11165(pos.x,pos.y)
    end
    self.collection.callback = func
    self.collection.unitActionType = nil
    self.collection:Show({msg = TI18N("种花中......"), time = lastTime})
end

function GuildManager:ShowWaterFlowerCollection(lastTime)
    local func = function()
        --GuildManager.Instance:request11164()
        if self.model.plant_flower_panel ~= nil then
            self.model.plant_flower_panel:SendSureWater()
        end
    end
    self.collection.callback = func
    self.collection.unitActionType = nil
    self.collection:Show({msg = TI18N("浇水中......"), time = lastTime})
end

-------------------公会邀请功能
function GuildManager:request11182(rid, platform, zone_id)
    Connection.Instance:send(11182, {rid = rid, platform = platform, zone_id = zone_id})
end

function GuildManager:request11183(rid, platform, zone_id, type)
    Connection.Instance:send(11183, {rid = rid, platform = platform, zone_id = zone_id, type = type})
end

--设定新秀转正等级
function GuildManager:request11186(_lev)
    Connection.Instance:send(11186, {lev = _lev})
end

--公会改名
function GuildManager:request11187(_name)
    Connection.Instance:send(11187, {name = _name})
end

function GuildManager:on11182(data)
    -- print(data.msg)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function GuildManager:on11183(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    -- print(data.msg)
end

function GuildManager:on11184(data)
    -- BaseUtils.dump(data, "收到邀请列表")
    self.invite_List = data.invitations
    self:checkNextInvitations()
    -- local cdata = NoticeConfirmData.New()
    -- cdata.type = ConfirmData.Style.Normal
    -- cdata.content = TI18N(string.format("%s邀请你加入%s", data[1].name, data[1].guild_name))
    -- cdata.sureLabel = "接受"
    -- cdata.sureLabel = "拒绝"
    -- cdata.sureCallback = function() self:request11183(data[1].rid, data[1].platform, data[1].zone_id, 1) end
    -- cdata.cancelCallback = function() self:request11183(data[1].rid, data[1].platform, data[1].zone_id, 0) end
    -- NoticeManager.Instance:ConfirmTips(cdata)
end

function GuildManager:on11185(data)
    -- BaseUtils.dump(data, "推送邀请列表")
    table.insert(self.invite_List, data)
    self:checkNextInvitations()
end


--修改公会新秀转正等级
function GuildManager:on11186(data)
    -- print('----------------------收到11186')
    if data.result == 1 then

    else

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


function GuildManager:checkNextInvitations()
    if #self.invite_List > 0 and not self.dealinginvite then
        local idata = self.invite_List[#self.invite_List]
        table.remove(self.invite_List)
        LuaTimer.Add(250, function() self:DealInvite(idata)end)
    end
end

function GuildManager:DealInvite(invitedata)
    self.dealinginvite = true
    local cdata = NoticeConfirmData.New()
    cdata.type = ConfirmData.Style.Normal
    cdata.content = string.format(TI18N("<color='#00ff00'>%s</color>邀请你加入<color='#00ff00'>%s</color>"), invitedata.name, invitedata.guild_name)
    cdata.sureLabel = TI18N("接受")
    cdata.cancelLabel = TI18N("拒绝")
    cdata.sureCallback = function() self:request11183(invitedata.rid, invitedata.platform, invitedata.zone_id, 1) self.dealinginvite = false self:checkNextInvitations() end
    cdata.cancelCallback = function() self:request11183(invitedata.rid, invitedata.platform, invitedata.zone_id, 0) self.dealinginvite = false self:checkNextInvitations() end
    NoticeManager.Instance:ConfirmTips(cdata)
end

function GuildManager:request11188()
    self:Send(11188, {})
end

function GuildManager:on11188(data)
    UnitStateManager.Instance:Update(UnitStateEumn.Type.Robber, data)
end

--解锁公会元素
function GuildManager:request11189()
    self:Send(11189, {})
end

--解锁公会元素
function GuildManager:on11189(data)
    if data.result==0 then --失败
    else--成功
        self:request11100()
        -- self.model:OpenGetNewBuildWindow()
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--进行公会祈福
function GuildManager:request11190(type, use_type,cost_type)
    -- print("------------------发送11190")
    self:Send(11190, {type = type,use_type = use_type , cost_type = cost_type})
    -- local p = SceneManager.Instance.sceneModel:transport_big_pos(13.94, 4.1)
    -- print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkdddddddddddddddddddddddd")
    -- BaseUtils.dump(p)
end

--进行公会祈福
function GuildManager:on11190(data)
    -- print("----------------------收到11190")
    -- BaseUtils.dump(data)
    if data.result==0 then --失败
        self.isPlayPraySuccessEffect = false
        self:request11192()
    else--成功
        self.isPlayPraySuccessEffect = true
        self:request11192()
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--保存祈福效果
function GuildManager:request11191(type)
    -- print("==========================发送11191")
    self:Send(11191, {type = type})
end

--保存祈福效果
function GuildManager:on11191(data)
    -- print("==========================收到11191")
    -- BaseUtils.dump(data)
    if data.result==0 then --失败
    else--成功
        self:request11192()
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--祈福信息
function GuildManager:request11192()
    -- print("==========================发送11192")
    self:Send(11192, {})
end

--祈福信息
function GuildManager:on11192(data)
    -- print("==========================收到11192")
    -- BaseUtils.dump(data)
    self.model.prayElementData = data
    if self.isPlayPraySuccessEffect then
        self.isPlayPraySuccessEffect = false
        self.model:PlayPraySuccessEffect(data)
    else
        self.model:UpdatePrayPanelAttr(data)
    end
    EventMgr.Instance:Fire(event_name.buff_update)
end

--查询升级元素价格
function GuildManager:request11193(build_type)
    -- print("==========================发送11193")
    self:Send(11193, {build_type = build_type})
end

--查询升级元素价格
function GuildManager:on11193(data)
    -- print("==========================收到11193")
    -- BaseUtils.dump(data)
    self.model:UpdateElementUpPrice(data)
end


--查询本服最高的元素
function GuildManager:request11194()
    print("==========================发送11194")
    self:Send(11194, {})
end

--查询本服最高的元素
function GuildManager:on11194(data)
    print("==========================收到11194")
    BaseUtils.dump(data)
    self.model:UpdatePrayConfirmWindow(data)
end

function GuildManager:request11195(num)
    self:Send(11195,{type = num})
end
function GuildManager:on11195(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self:request11196()
end

function GuildManager:request11196()
self:Send(11196,{})
end
function GuildManager:on11196(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.fundNum = data.remain
    self.OnUpdateFundStart:Fire()
end

-- 解锁公会加速额度限制，会长、副会长会发出11197的request
function GuildManager:request11197()
    self:Send(11197,{mode = 0})
end
function GuildManager:on11197(data)

    local result=data.result
    local msg=data.msg

    if result == 0 then --失败

    else--成功
        self.model.my_guild_data.limit_mode = 0
    end
    NoticeManager.Instance:FloatTipsByString(msg)
end

-- 11198 用来获取角色本身的已用加速额度
function GuildManager:request11198()
    self:Send(11198,{})
end

function GuildManager:on11198(data)
    if data.result == 0 then -- 失败

    else -- 成功
        self.model.my_guild_data.total_donate = data.total_donate
    end
end

-- 11199协议主要是用来通知公会全体成员额度限制已经解除，并通知界面把锁按钮隐藏
function GuildManager:request11199()
    self:Send(11199,{})
end
function GuildManager:on11199(data)
    if data.result == 0 then --失败

    else--成功
        self.model.my_guild_data.limit_mode = 0
        self.model:build_win_update()
    end
end
