    -- @author huangzefeng
-- @date 2016年6月21日,星期二

WorldChampionManager = WorldChampionManager or BaseClass(BaseManager)

function WorldChampionManager:__init()
    if WorldChampionManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    WorldChampionManager.Instance = self
    self.first = true
    self.Poseumn = {
        carry1 = TI18N("输出位"),
        carry2 = TI18N("输出位"),
        carry3 = TI18N("输出位"),
        support1 = TI18N("辅助位"),
        auto = TI18N("自由位"),
    }
    self.class2pos = {
        [1] = {"carry1", "carry2", "auto"},
        [2] = {"carry1", "carry2", "auto"},
        [3] = {"carry1", "carry2", "auto"},
        [4] = {"support1", "auto"},
        [5] = {"support1", "auto"},
        [6] = {"carry1", "carry1", "auto"},
        [7] = {"carry1", "carry1", "auto"},
    }
    self.pos2class = {
        [self.Poseumn.carry1]  =  {1,2,3,6,7},
        [self.Poseumn.support1]  =  {4,5},
        [self.Poseumn.auto]  =  {1,2,3,4,5,6,7},
    }
    self.lev2Icon = {
        [1] = {icon = 10001, stylelev = 1, str = TI18N("1级-波波球")},
        [2] = {icon = 10003, stylelev = 1, str = TI18N("2级-花莹")},
        [3] = {icon = 10005, stylelev = 1, str = TI18N("3级-龙龟")},
        [4] = {icon = 10010, stylelev = 2, str = TI18N("4级-波波球")},
        [5] = {icon = 10011, stylelev = 2, str = TI18N("5级-波波球")},
        [6] = {icon = 10014, stylelev = 3, str = TI18N("6级-波波球")},
        [7] = {icon = 10017, stylelev = 3, str = TI18N("7级-波波球")},
        [8] = {icon = 10019, stylelev = 4, str = TI18N("8级-波波球")},
        [9] = {icon = 10022, stylelev = 5, str = TI18N("9级-波波球")},
        [10] = {icon = 10025, stylelev = 6, str = TI18N("10级-波波球")},
        [11] = {icon = 20004, stylelev = 7, str = TI18N("11级-波波球")},
    }

    self.rankData = {rank_lev = 1,season_rank_lev = 1}
    self.lvupListener = function()
        self:OnLvUp()
    end
    self.model = WorldChampionModel.New(self)
    self:InitHandler()

    self.rankList = {[1]= {},[2] = {},[3] = {},[4] = {}} --1跨服榜，2本服，3好友榜
    self.famousList = {}
    self.isRankNeedRefresh = true
    self.refreshInterval = 300 -- 分钟
    self.timerId = 0
    self.currstatus = 0
    self.season_id = 1

    self.pk_type = 1
    self.onUpdateTimes = EventLib.New()
    self.onStarChange = EventLib.New()
    -- self.onOpenBadge = EventLib.New()
    -- self.onHideBadge = EventLib.New()
    self.onGetBadgeData = EventLib.New()
    --self.onJoin = EventLib.New()
    self.refreshRankData = EventLib.New()

    self.complainSuccess = EventLib.New()

    self.WindowDesc = TI18N("1.<color='#00ff00'>跨服</color>武道会将划分为：70级精锐组、80级骁勇组、90级英雄组独立进行\n\n2.比武采用<color='#00ff00'>5V5</color>形式，单人参与，由系统匹配队友和对手\n\n3.战斗获胜/失败将获得/扣除相应积分，累计<color='#00ff00'>100</color>积分将开启晋级战\n\n4.晋级战获胜将提升等级，共有<color='#00ff00'>10</color>个常规等级和<color='#ffff00'>星辰王者</color>级别\n\n5.每晚武道会结束时，达到<color='#ffff00'>登峰造极50分以上</color>且全部服务器排名前<color='#ffff00'>100</color>玩家将晋级至<color='#ffff00'>星辰王者</color>！\n\n（注意：星辰王者连输后仍然有可能掉级，努力捍卫王者的荣誉吧）\n\n6.级别越高，赛季结算奖励越丰厚，所有服玩家都能看到你的风采喔")
    self.WindowDesc2V2 = TI18N("1.<color='#00ff00'>跨服</color>武道会将划分为：70级精锐组、80级骁勇组、90级英雄组独立进行\n\n2.比武采用<color='#00ff00'>2V2</color>和<color='#00ff00'>5V5</color>形式，可单人或双人组队参与，由系统匹配队友和对手\n\n3.周二将开启2V2模式，当天获得5次挑战机会，除周二外每天开启5V5模式，每天拥有3次挑战机会\n\n4.两种模式武道积分互通，累计获得<color='#00ff00'>100</color>积分将开启晋级战\n\n5.晋级战获胜将提升头衔，共有<color='#00ff00'>10</color>个常规头衔和<color='#ffff00'>星辰王者</color>头衔\n\n6.每晚武道会结束时，达到<color='#ffff00'>登峰造极50分以上</color>且全部服务器排名前<color='#ffff00'>100</color>玩家将晋级至<color='#ffff00'>星辰王者</color>！\n\n（注意：星辰王者连输后仍然有可能掉级，努力捍卫王者的荣誉吧）\n\n7.级别越高，赛季结算奖励越丰厚，所有服玩家都能看到你的风采喔")
    self.OtherDesc = TI18N("<color='#ffff00'>星辰英豪群雄四起，武道大会一战封神！</color>\n今天将进行<color='#ffff00'>5V5</color>对决（每周二开启2V2，其他时间为5V5模式）\n温馨提示：可单人应战或邀请一名<color='#ffff00'>好友双排</color>匹配\n1、<color='#00ff00'>每天中午12：30-13：30</color>准时开战\n2、5V5模式每天可挑战<color='#ffff00'>3</color>次，最多可累计<color='#ffff00'>6</color>次\n3、<color='#00ff00'>晚上22:30-23:30</color>有剩余次数的英雄们可继续挑战\n注：每晚<color='#ffff00'>23:50</color> 位列全部服务器前100名，且达到<color='#ffff00'>登峰造极50分以上</color>，将加冕为<color='#ffff00'>星辰王者</color>{face_1,29}")
    self.OtherDesc2V2 = TI18N("<color='#ffff00'>星辰英豪群雄四起，武道大会一战封神！</color>\n今天将进行<color='#ffff00'>2V2</color>对决（每周二开启2V2，其他时间为5V5模式）\n温馨提示：可单人应战或邀请一名<color='#ffff00'>好友双排</color>匹配\n1、<color='#00ff00'>每天中午12：30-13：30</color>准时开战\n2、2V2模式当天可挑战<color='#ffff00'>5</color>次、隔天不累计，与5V5模式次数相独立\n3、<color='#00ff00'>晚上22:30-23:30</color>有剩余次数的英雄们可继续挑战\n注：每晚<color='#ffff00'>23:50</color> 位列全部服务器前100名，且达到<color='#ffff00'>登峰造极50分以上</color>，将加冕为<color='#ffff00'>星辰王者</color>{face_1,29}")

    self.championMap = {70, 80, 90, 101, 106, 116, 126}
end

function WorldChampionManager:__delete()
end

function WorldChampionManager:InitHandler()
    self:AddNetHandler(16400, self.On16400)
    self:AddNetHandler(16401, self.On16401)
    self:AddNetHandler(16402, self.On16402)
    self:AddNetHandler(16403, self.On16403)
    self:AddNetHandler(16404, self.On16404)
    self:AddNetHandler(16405, self.On16405)
    self:AddNetHandler(16406, self.On16406)
    self:AddNetHandler(16407, self.On16407)
    self:AddNetHandler(16408, self.On16408)
    self:AddNetHandler(16409, self.On16409)
    self:AddNetHandler(16410, self.On16410)
    self:AddNetHandler(16411, self.On16411)
    self:AddNetHandler(16412, self.On16412)
    self:AddNetHandler(16413, self.On16413)
    self:AddNetHandler(16414, self.On16414)
    self:AddNetHandler(16415, self.On16415)
    self:AddNetHandler(16416, self.On16416)
    self:AddNetHandler(16417, self.On16417)
    self:AddNetHandler(16418, self.On16418)
    self:AddNetHandler(16419, self.On16419)
    self:AddNetHandler(16420, self.On16420)
    self:AddNetHandler(16421, self.On16421)
    self:AddNetHandler(16422, self.On16422)
    self:AddNetHandler(16423, self.On16423)
    self:AddNetHandler(16424, self.On16424)
    self:AddNetHandler(16425, self.On16425)
    self:AddNetHandler(16426, self.On16426)
    self:AddNetHandler(16427, self.On16427)
    self:AddNetHandler(16428, self.On16428)
    self:AddNetHandler(16429, self.On16429)

    self:AddNetHandler(16430,self.On16430)
    self:AddNetHandler(16431,self.On16431)
    self:AddNetHandler(16432,self.On16432)
    self:AddNetHandler(16433,self.On16433)
    self:AddNetHandler(16434,self.On16434)
    self:AddNetHandler(16435,self.On16435)
    self:AddNetHandler(16436,self.On16436)
    self:AddNetHandler(16437,self.On16437)
    self:AddNetHandler(16438,self.On16438)

    EventMgr.Instance:AddListener(event_name.role_level_change, self.lvupListener)
end


function WorldChampionManager:RequireOnConnect()
    self:Require16407()
    self:Require16435()
    self:Require16437()
    LuaTimer.Add(500,function()
             self:Require16400()
         end)
    self:Require16405(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
    for i,v in ipairs(DataTournament.data_list) do
        self.lev2Icon[i] = v
        self.lev2Icon[i].str = v.name
    end
end

function WorldChampionManager:ReqOnSelfLoaded()
    self:Require16407()
    self:Require16405(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
end
-- 匹配界面
function WorldChampionManager:OpenMainPanel(args)
    self.model:OpenMainPanel(args)
end

function WorldChampionManager:CloseMainPanel(args)
    self.model:CloseMainPanel(args)
end

-- 匹配界面
function WorldChampionManager:OpenMainPanel2V2(args)
    self.model:OpenMainPanel2V2(args)
end

function WorldChampionManager:CloseMainPanel2V2(args)
    self.model:CloseMainPanel2V2(args)
end

-- 战斗胜利界面
function WorldChampionManager:OpenSuccessWindow(args)
    self.model:OpenSuccessWindow(args)
end

function WorldChampionManager:CloseSuccessWindow()
    self.model:CloseSuccessWindow()
end

-- 晋级界面
function WorldChampionManager:OpenLvupWindow(args)
    self.model:OpenLvupWindow(args)
end

function WorldChampionManager:CloseLvupWindow()
    self.model:CloseLvupWindow()
end

-- 赛季宝箱
function WorldChampionManager:OpenQuarterBoxWindow(args)
    self.model:OpenQuarterBoxPanel(args)
end

function WorldChampionManager:CloseQuarterBoxWindow()
    self.model:CloseQuarterBoxPanel()
end

--赛季结算
function WorldChampionManager:OpenQuarterWindow(args)
    self.model:OpenQuarterPanel(args)
end

function WorldChampionManager:CloseQuarterWindow()
    self.model:CloseQuarterPanel()
end


------------------------------------------------------------------------------------------------------------
function WorldChampionManager:Require16400()
    Connection.Instance:send(16400,{})
end


function WorldChampionManager:On16400(data)
    -- print("<color='#ff0000'>=============================收到On16400</color>")
    -- BaseUtils.dump(data)

    self.pk_type = data.pk_type
    self.model.pk_type = data.pk_type
    if data.pk_type == 1 then
        self:UpdateWorldChampionIcon(data)
    elseif data.pk_type == 2 then
        self:UpdateWorldChampionIcon2V2(data)
    end

    self.isRankNeedRefresh = true
    if self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
        self.timerId = 0
    end
end


function WorldChampionManager:Require16401()
    if self.currstatus == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("天下第一武道会尚未开始"))
        return
    end
    if (RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionStart or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionReady or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionSuccess) then
        if self.pk_type == 1 then
            self.model:OpenMainPanel()
        elseif self.pk_type == 2 then
            self.model:OpenMainPanel2V2()
        end
        return
    end

    Connection.Instance:send(16401,{})
end


function WorldChampionManager:On16401(data)
    -- BaseUtils.dump(data, "On16401")
    if data.result == 1 then
        if self.pk_type == 1 then
            self.model:OpenMainPanel()
        else
            self.model:OpenMainPanel2V2()
        end
    -- else
    --     self:Require16403()
    end
    if data.result == 1 then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    elseif data.msg ~= "" then
        local currentNpcData = DataUnit.data_unit[20004]
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[20004])
        extra.base.buttons = {}
        -- extra.base.buttons[1].button_id = actionType.action22
        -- extra.base.buttons[1].button_args = {6, 61, 1, 1}
        extra.base.plot_talk = data.msg
        MainUIManager.Instance.dialogModel:Open(currentNpcData, extra, true)
    end
end


function WorldChampionManager:Require16402()
    Connection.Instance:send(16402,{})
    -- local data = {result = 1,msg = ""}
    -- LuaTimer.Add(20,function () self:On16402(data) end)
end


function WorldChampionManager:On16402(data)
    -- BaseUtils.dump(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        self.model:doMatchResult(true)
    -- else
    --     self:Require16404()
    end
end


function WorldChampionManager:Require16403()
    Connection.Instance:send(16403,{})
end


function WorldChampionManager:On16403(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        if self.pk_type == 1 then
            self:CloseMainPanel()
        elseif self.pk_type == 2 then
            self:CloseMainPanel2V2()
        end
    end
end


function WorldChampionManager:Require16404()
    Connection.Instance:send(16404,{})
end


function WorldChampionManager:On16404(data)
    if IS_DEBUG then
        Log.Error("On16404_____________________________________武道会匹配人数：" .. #data.teammate)
    end
    -- Debug.Log("On16404_____________________________________武道会匹配人数：" .. #data.tournament_role)
    -- BaseUtils.dump(data, "")
    -- NoticeManager.Instance:FloatTipsByString(TI18N("武道会匹配成功，将在<color='#ffff00'>90</color>秒后开始战斗"))
    self.matchdata.teammate = data.teammate
    self.model:GetMatchResult(data)
end


function WorldChampionManager:Require16405(rid, platform, zone_id)
    -- print(string.format("Require16405 %s %s %s", rid, platform, zone_id))
    Connection.Instance:send(16405,{rid = rid, platform = platform, zone_id = zone_id})
    local data = {rid = rid, platform = platform, zone_id = zone_id, rank_point = Random.Range(50,90), rank_lev = Random.Range(1,11)}
    -- LuaTimer.Add(20,function () self:On16405(data) end)
end


function WorldChampionManager:On16405(data)
    -- BaseUtils.dump(data, "On16405")
    if data.rid == RoleManager.Instance.RoleData.id and data.platform == RoleManager.Instance.RoleData.platform and data.zone_id == RoleManager.Instance.RoleData.zone_id then
        self.rankData = data
    end
    self.model:SetLevInfo(data)
    self.refreshRankData:Fire()
    -- self.model:OpenLvupWindow(data)
end


function WorldChampionManager:Require16406()
    Connection.Instance:send(16406,{})
end


function WorldChampionManager:On16406(data)
    BaseUtils.dump(data, "武道结算数据On16406")
    if self.currstatus == 0 then
        self:Require16403()
    end
    -- self:Require16405(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)

    local copytab = BaseUtils.copytab(data)

    local mark = {}
    for i = 1, #data.mates do
        for j = 1, #copytab.mates do
            local a = data.mates[i]
            local b = copytab.mates[j]
            if a ~= nil and b ~= nil and a.rid == b.rid and a.zone_id == b.zone_id and a.platform == b.platform then
                local key = string.format("%s_%s_%s", a.rid, a.zone_id, a.platform)
                if mark[key] then
                    table.remove(data.mates, i)
                    i = i - 1
                    break
                else
                    mark[key] = true
                end
            end
        end
    end

    mark = {}
    for i = 1, #data.rival do
        for j = 1, #copytab.rival do
            local a = data.rival[i]
            local b = copytab.rival[j]
            if a ~= nil and b ~= nil and a.rid == b.rid and a.zone_id == b.zone_id and a.platform == b.platform then
                local key = string.format("%s_%s_%s", a.rid, a.zone_id, a.platform)
                if mark[key] then
                    table.remove(data.rival, i)
                    i = i - 1
                    break
                else
                    mark[key] = true
                end
            end
        end
    end

    table.sort(data.mates, function(a,b) return a.zone_id ~= 0 and b.zone_id == 0 end)
    table.sort(data.rival, function(a,b) return a.zone_id ~= 0 and b.zone_id == 0 end)

    self.model:OpenSuccessWindow(data)
    self.model:OnEndFight()
    self:Require16405(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
end


function WorldChampionManager:Require16407()
    -- print("请求16407")
    Connection.Instance:send(16407,{})
end


function WorldChampionManager:On16407(data)
    -- if IS_DEBUG then
    --     Log.Error("On16407_____________________________________武道会匹配人数：" .. #data.teammate)
    -- end
    -- BaseUtils.dump(data, "On16407_____________________________________")
    self.matchdata = data
    if self.rechargeIconEffect ~= nil then
        self.rechargeIconEffect:DeleteMe()
    end
    local cfg_data = DataSystem.data_daily_icon[115]
    if self.matchdata.day_matched >= 6 then
        MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
    elseif self.currstatus == 2 then
        MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
        local iconData = AtiveIconData.New()
        iconData.id = cfg_data.id
        iconData.iconPath = cfg_data.res_name
        iconData.clickCallBack = self.sureCallback
        iconData.sort = cfg_data.sort
        iconData.lev = cfg_data.lev
        iconData.effectId = 20256
        iconData.effectPos = Vector3(0, 32, -400)
        iconData.effectScale = Vector3(1, 1, 1)
        iconData.timestamp = self.model.activity_time
        iconData.timeoutCallBack = function()
            self:Require16400()
        end
        MainUIManager.Instance:AddAtiveIcon(iconData)
        -- local fun = function(effectView)
        --     local effectObject = effectView.gameObject
        --     if BaseUtils.isnull(self.icon) or BaseUtils.isnull(self.icon.transform) then
        --         if self.rechargeIconEffect ~= nil then
        --             self.rechargeIconEffect:DeleteMe()
        --             self.rechargeIconEffect = nil
        --         end
        --         return
        --     end
        --     effectObject.transform:SetParent(self.icon.transform)
        --     effectObject.transform.localScale = Vector3(1, 1, 1)
        --     effectObject.transform.localPosition = Vector3(0, 32, -400)
        --     effectObject.transform.localRotation = Quaternion.identity

        --     Utils.ChangeLayersRecursively(effectObject.transform, "UI")
        --     effectObject:SetActive(true)
        -- end
        -- if self.rechargeIconEffect == nil or self.rechargeIconEffect.gameObject == nil then
        --     -- -- print("----------"..debug.traceback())
        --     self.rechargeIconEffect = BaseEffectView.New({effectId = 20256, time = nil, callback = fun})
        --     -- print(BaseUtils.isnull(self.rechargeIconEffect.gameObject))
        -- elseif BaseUtils.isnull(self.rechargeIconEffect.gameObject) == false then
        --     -- print(BaseUtils.isnull(self.rechargeIconEffect.gameObject))
        --     fun(self.rechargeIconEffect)
        -- end
    end
    self.model:OnMatchingStatus()
    --self.onJoin:Fire(1)
end

function WorldChampionManager:Require16430(myRid,myPlatform,myZoneId)
    local data = {id = myRid,platform = myPlatform,zone_id = myZoneId}
    -- BaseUtils.dump(data,"发送协议16430==============================================================================")
    Connection.Instance:send(16430,data)
end


function WorldChampionManager:On16430(data)
    -- BaseUtils.dump(data,"接收协议16430==============================================================================")
    self.times = data.times
    self.onUpdateTimes:Fire()
end



function WorldChampionManager:Require16408()
    Connection.Instance:send(16408,{})
    local data = {result = 1,msg = ""}
    -- LuaTimer.Add(20,function () self:On16408(data) end)
end


function WorldChampionManager:On16408(data)
    -- BaseUtils.dump(data, "On16408")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        self.model:doMatchResult(false)
    end
end

function WorldChampionManager:Require16409()
    Connection.Instance:send(16409,{})
    local data = {result = 1,msg = ""}
    -- LuaTimer.Add(20,function () self:On16409(data) end)
end


function WorldChampionManager:On16409(data)
    -- BaseUtils.dump(data, "On16409")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function WorldChampionManager:Require16410(decision)
    Connection.Instance:send(16410,{decision = decision})

end


function WorldChampionManager:On16410(data)
    -- BaseUtils.dump(data, "On16410")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function WorldChampionManager:Require16411()
    Connection.Instance:send(16411,{})
end


function WorldChampionManager:On16411(data)
    local str = ""
    local time = 30
    if data.lev > 100 then
        data.lev = data.lev - 6
    end
    str = string.format(TI18N("<color='#03B0EC'>%sLv.%s</color>想成为队长,是否同意?"), data.name, data.lev)

    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = str
    data.sureLabel = TI18N("同意")
    data.cancelLabel = TI18N("拒绝")
    data.sureSecond = time
    data.blueSure = true
    data.sureCallback = function() self:Require16410(1) end
    data.cancelCallback = function() self:Require16410(0) end
    NoticeManager.Instance:ConfirmTips(data)
end

function WorldChampionManager:Require16412(rid, platform, zone_id)
    Connection.Instance:send(16412,{rid = rid, platform = platform, zone_id = zone_id})

end


function WorldChampionManager:On16412(data)
    -- BaseUtils.dump(data, "On16412")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


function WorldChampionManager:On16413(data)
    -- BaseUtils.dump(data, "On16413")
    self.model:GetMatchResult(data)
end

function WorldChampionManager:Require16414(role_id1, platform1, zone_id1, role_id2, platform2, zone_id2)
    print(string.format("%s %s %s, %s %s %s", role_id1, platform1, zone_id1, role_id2, platform2, zone_id2))
    Connection.Instance:send(16414,{role_id1 = role_id1, platform1 = platform1, zone_id1 = zone_id1, role_id2 = role_id2, platform2 = platform2, zone_id2 = zone_id2})

end

function WorldChampionManager:On16414(data)
    -- BaseUtils.dump(data, "On16414")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    --self.onJoin:Fire(2)
end
--获取排行榜
function WorldChampionManager:Require16416(typeTemp,groupTemp)
    --print("-----Require16416-----------"..typeTemp.."---"..groupTemp)
    -- Connection.Instance:send(16416,{type = typeTemp})
    if self.isRankNeedRefresh == true or self.rankList[typeTemp][groupTemp] == nil then
        self.isRankNeedRefresh = false
        Connection.Instance:send(16416,{type = typeTemp,group = groupTemp})
        if self.timerId ~= 0 then
            LuaTimer.Delete(self.timerId)
            self.timerId = 0
        end
        self.refreshInterval = 300
    end
    if self.isRankNeedRefresh == false then
        if self.timerId == 0 then
            self.timerId = LuaTimer.Add(0, 1000, function()
                if self.refreshInterval > 0 then
                    self.refreshInterval = self.refreshInterval - 1
                else
                    LuaTimer.Delete(self.timerId)
                    self.refreshInterval = 300
                    self.timerId = 0
                    self.isRankNeedRefresh = true
                end
            end)
        else
            EventMgr.Instance:Fire(event_name.no1world_rank_data_change)
        end
    end
end
--排行榜数据
function WorldChampionManager:On16416(data)
    BaseUtils.dump(data, "On16416")
    for i,v in ipairs(data) do
        v.rank_lev = math.min(v.rank_lev,11)
    end
    self.rankList[data.type][data.group] = data
    local typeIndex = 1
    local group = data.group
    for i,v in pairs(self.championMap) do
        if group == v then
            typeIndex = i
            break
        end
    end

    local pos = RankManager.Instance.model.rankTypeToPageIndexList[RankManager.Instance.model.rank_type.WorldchampionElite + typeIndex -1]

    local sortFun = function(a, b)
        if a.rank_lev > b.rank_lev then
            return true
        elseif a.rank_lev < b.rank_lev then
            return false
        else
            if a.rank_point > b.rank_point then
                return true
            elseif a.rank_point < b.rank_point then
                return false
            else
                if a.rid < b.rid then
                    return true
                else
                    return false
                end
            end
        end
    end
    local tempData = {}
    local WrankData = BaseUtils.copytab(data.rank)
    table.sort(WrankData, sortFun)
    tempData.rank_list = WrankData
    for i =1, #tempData.rank_list do
        tempData.rank_list[i].rank = i
    end
    --BaseUtils.dump(tempData.rank_list,"tempData.rank_list")
    RankManager.Instance.model:SetData(pos.main, pos.sub, 1, tempData)

    EventMgr.Instance:Fire(event_name.no1world_rank_data_change)
end

function WorldChampionManager:Require16415(id)
    -- print("改变阵法："..id)
    Connection.Instance:send(16415,{id = id})

end

function WorldChampionManager:On16415(data)
    -- BaseUtils.dump(data, "On16415")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function WorldChampionManager:Require16417()
    -- print("请求奖励")
    Connection.Instance:send(16417,{})

end

function WorldChampionManager:On16417(data)
    -- BaseUtils.dump(data, "On16417")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        self.model:ShowLevUpBox()
    end
end

--获取排行榜名人堂数据
function WorldChampionManager:Require16418(typeTemp, range)
    -- print(debug.traceback() .."-----Require16418-----------"..typeTemp)
    -- Connection.Instance:send(16416,{type = typeTemp})
    if self.isRankNeedRefresh == true or self.famousList[tostring(typeTemp)..tostring(range)] == nil then
        self.isRankNeedRefresh = false
        Connection.Instance:send(16418,{type = typeTemp, range = range})
        if self.timerId ~= 0 then
            LuaTimer.Delete(self.timerId)
            self.timerId = 0
        end
        self.refreshInterval = 300
    end
    if self.isRankNeedRefresh == false then
        if self.timerId == 0 then
            self.timerId = LuaTimer.Add(0, 1000, function()
                if self.refreshInterval > 0 then
                    self.refreshInterval = self.refreshInterval - 1
                else
                    LuaTimer.Delete(self.timerId)
                    self.refreshInterval = 300
                    self.timerId = 0
                    self.isRankNeedRefresh = true
                end
            end)
        else
            EventMgr.Instance:Fire(event_name.no1world_rank_data_change)
        end
    end
end
--排行榜名人堂数据
function WorldChampionManager:On16418(data)
    -- BaseUtils.dump(data, "On16418")
    self.famousList[tostring(data.type)..tostring(data.range)] = data
    EventMgr.Instance:Fire(event_name.no1world_rank_data_change)
end

function WorldChampionManager:OnLvUp()
    local cfg_data = DataSystem.data_daily_icon[115]
    if self.currstatus == nil or 70 == RoleManager.Instance.RoleData.lev then
        return
    else
        self:Require16400()
    end
    -- if self.currstatus == 0 then
    --     --关闭
    --     MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
    --     self:CloseMainPanel()
    -- elseif self.currstatus == 1 then
    --     MainUIManager.Instance:DelAtiveIcon(cfg_data.id)

    -- elseif self.currstatus == 2 then
    --     --进行中
    --     MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
    --     local iconData = AtiveIconData.New()
    --     iconData.id = cfg_data.id
    --     iconData.iconPath = cfg_data.res_name
    --     iconData.clickCallBack = self.sureCallback
    --     iconData.sort = cfg_data.sort
    --     iconData.lev = cfg_data.lev
    --     iconData.timestamp = self.model.activity_time
    --     iconData.timeoutCallBack = function()
    --         self:Require16400()
    --     end
    --     MainUIManager.Instance:AddAtiveIcon(iconData)

    -- end
end


function WorldChampionManager:Require16419(rid ,platform, zone_id)
    -- print("点赞")
    Connection.Instance:send(16419,{rid = rid, platform = platform, zone_id = zone_id})

end

function WorldChampionManager:On16419(data)
    -- BaseUtils.dump(data, "On16419")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        self.model:GoodSucc(data.rid, data.platform, data.zone_id)
    end
end

function WorldChampionManager:Require16420()
    -- print("随机观战")
    Connection.Instance:send(16420,{})

end

function WorldChampionManager:On16420(data)
    -- BaseUtils.dump(data, "On16420")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


function WorldChampionManager:Require16421()
    -- print("赛季奖励情况")
    Connection.Instance:send(16421,{})

end

function WorldChampionManager:On16421(data)
    -- BaseUtils.dump(data, "On16421")
    -- NoticeManager.Instance:FloatTipsByString(data.msg)
    --self.model:OpenQuarterPanel(data)
end


function WorldChampionManager:Require16422()
    Connection.Instance:send(16422,{})
end

function WorldChampionManager:On16422(data)
    -- BaseUtils.dump(data, "On16422")
    if data.flag == 1 then
        self.model:OpenQuarterPanelBox()
    end
end


function WorldChampionManager:Require16423(content, mentions)
    -- print("分享战斗结果到朋友圈")
    Connection.Instance:send(16423,{content = content, mentions = mentions})
end

function WorldChampionManager:On16423(data)
    -- BaseUtils.dump(data, "On16423")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


function WorldChampionManager:Require16424(id, platform, zone_id)
    -- print("获取战斗结算记录")
    Connection.Instance:send(16424,{id = id, platform = platform ,zone_id = zone_id})
end

function WorldChampionManager:On16424(data)
    -- BaseUtils.dump(data, "On16424")
    data.type = 1
    if data.r_id == 0 or #data.mates == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("该记录已经失效"))
        return
    end

        local copytab = BaseUtils.copytab(data)

    local mark = {}
    for i = 1, #data.mates do
        for j = 1, #copytab.mates do
            local a = data.mates[i]
            local b = copytab.mates[j]
            if a ~= nil and b ~= nil and a.rid == b.rid and a.zone_id == b.zone_id and a.platform == b.platform then
                local key = string.format("%s_%s_%s", a.rid, a.zone_id, a.platform)
                if mark[key] then
                    table.remove(data.mates, i)
                    i = i - 1
                    break
                else
                    mark[key] = true
                end
            end
        end
    end

    mark = {}
    for i = 1, #data.rival do
        for j = 1, #copytab.rival do
            local a = data.rival[i]
            local b = copytab.rival[j]
            if a ~= nil and b ~= nil and a.rid == b.rid and a.zone_id == b.zone_id and a.platform == b.platform then
                local key = string.format("%s_%s_%s", a.rid, a.zone_id, a.platform)
                if mark[key] then
                    table.remove(data.rival, i)
                    i = i - 1
                    break
                else
                    mark[key] = true
                end
            end
        end
    end

    table.sort(data.mates, function(a,b) return a.zone_id ~= 0 and b.zone_id == 0 end)
    table.sort(data.rival, function(a,b) return a.zone_id ~= 0 and b.zone_id == 0 end)

    self.model:OpenCountInfoWindow(data)
end


function WorldChampionManager:Require16425(rid, platform, zone_id, rec_id)
    -- print("获取战斗结算记录")
    Connection.Instance:send(16425,{rid = rid, platform = platform ,zone_id = zone_id, rec_id = rec_id})
end

function WorldChampionManager:On16425(data)
    -- BaseUtils.dump(data, "On16425")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag then 
        local unique_id = string.format( "%s,%s,%s",data.platform,data.zone_id,data.rid)
        self.complainSuccess:Fire(unique_id)
    end
end

function WorldChampionManager:Require16426(id, platform, zone_id)
    -- print("获取战斗结算记录")
    Connection.Instance:send(16426,{id = id, platform = platform ,zone_id = zone_id})
end

function WorldChampionManager:On16426(data)
    -- BaseUtils.dump(data, "On16426")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function WorldChampionManager:GetLooks(id, platform, zone_id)
    if self.matchdata ~= nil and self.matchdata.teammate ~= nil then
        for i,v in ipairs(self.matchdata.teammate) do
            if v.platform == platform and v.zone_id == zone_id and v.rid == id then
                return v.looks
            end
        end
    end
    return {}
end

function WorldChampionManager:Require16427(id, platform, zone_id)
    -- print("--------------------发送16427")
    Connection.Instance:send(16427,{rid = id, platform = platform ,zone_id = zone_id})
end

function WorldChampionManager:On16427(data)
    -- print("-----------------------------收到16427")
    self.model.fightScoreData = data
    self.model:UpdateShareWin(data)
end

function WorldChampionManager:Require16428(id, platform, zone_id)
    -- print("--------------------发送16428")
    Connection.Instance:send(16428,{rid = id, platform = platform ,zone_id = zone_id})
end

function WorldChampionManager:On16428(data)
    -- print("-----------------------------收到16428")
    self.model:UpdateFightScore(data)
end

function WorldChampionManager:Require16429(id, order)
    -- print("--------------------发送16429")
    Connection.Instance:send(16429,{id = id, order = order})
end

function WorldChampionManager:On16429(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function WorldChampionManager:UpdateWorldChampionIcon(data)
    self.currstatus = data.status
    self.season_id = data.season_id
    local cfg_data = DataSystem.data_daily_icon[115]
    if cfg_data.lev > RoleManager.Instance.RoleData.lev then
        return
    end
    if self.rechargeIconEffect ~= nil then
        self.rechargeIconEffect:DeleteMe()
    end
    self.click_callback = function()
        if RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionStart or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionReady or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionSuccess then
            self.model:OpenMainPanel()
        else
            self:Require16401()
        end
    end
    self.sureCallback = function()
        if RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionStart or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionReady or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionSuccess then
            self.model:OpenMainPanel()
        else
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_PathToTarget("54_1")
        end
    end

    AgendaManager.Instance:SetCurrLimitID(2028, data.status == 2)
    self.currstatus = data.status
    if data.status == 0 then
        --关闭
        MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
        if not (RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionStart or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionReady or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionSuccess) then
            self:CloseMainPanel()
        end
    elseif data.status == 1 then
        self:Require16407()
        MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
        if not (RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionStart or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionReady or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionSuccess) then
            self:CloseMainPanel()
        end
    elseif data.status == 2 then
        --进行中
        MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
        if self.matchdata ~= nil and self.matchdata.day_matched >= 2 then
        else
            local iconData = AtiveIconData.New()
            iconData.id = cfg_data.id
            iconData.iconPath = cfg_data.res_name
            iconData.clickCallBack = self.sureCallback
            iconData.sort = cfg_data.sort
            iconData.lev = cfg_data.lev
            iconData.timestamp = data.time + Time.time
            iconData.effectId = 20256
            iconData.effectPos = Vector3(0, 32, -400)
            iconData.effectScale = Vector3(1, 1, 1)
            iconData.timeoutCallBack = function()
                self:Require16400()
            end
            self.icon = MainUIManager.Instance:AddAtiveIcon(iconData)
            -- local fun = function(effectView)
            --     local effectObject = effectView.gameObject
            --     if BaseUtils.isnull(self.icon) then
            --         self.rechargeIconEffect:DeleteMe()
            --         self.rechargeIconEffect = nil
            --         return
            --     end
            --     print("啊啊啊啊啊")
            --     print(self.icon.transform)
            --     effectObject.transform:SetParent(self.icon.transform)
            --     effectObject.transform.localScale = Vector3(1, 1, 1)
            --     effectObject.transform.localPosition = Vector3(0, 32, -400)
            --     effectObject.transform.localRotation = Quaternion.identity

            --     Utils.ChangeLayersRecursively(effectObject.transform, "UI")
            --     effectObject:SetActive(true)
            -- end
            -- if self.rechargeIconEffect == nil or self.rechargeIconEffect.gameObject == nil then
            --     -- -- print("----------"..debug.traceback())
            --     self.rechargeIconEffect = BaseEffectView.New({effectId = 20256, time = nil, callback = fun})
            --     -- print(BaseUtils.isnull(self.rechargeIconEffect.gameObject))
            -- elseif BaseUtils.isnull(self.rechargeIconEffect.gameObject) == false then
            --     -- print(BaseUtils.isnull(self.rechargeIconEffect.gameObject))
            --     fun(self.rechargeIconEffect)
            -- end
        end
        if (self.matchdata == nil or self.matchdata.day_matched < self.matchdata.max_join) and RoleManager.Instance.RoleData.lev >= cfg_data.lev and not (RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionStart or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionReady or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionSuccess) then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("<color='#ffff00'>天下第一武道会</color>活动正在进行中，是否前往参加？")
            data.sureLabel = TI18N("确认")
            data.cancelLabel = TI18N("取消")
            data.cancelSecond = 180
            data.sureCallback = self.sureCallback
            NoticeManager.Instance:ActiveConfirmTips(data)
        elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionStart or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionReady or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionSuccess then
            self.model:OpenMainPanel()
        end
    end
    self.model.activity_time = data.time + Time.time
    -- print('-------------------------收到更新计时')
    if (RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionStart or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionReady or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionSuccess) and data.status == 2 then
        -- print("在武道会event打开界面")
        self:OpenMainPanel()
    end
end

function WorldChampionManager:UpdateWorldChampionIcon2V2(data)
    self.currstatus = data.status
    self.season_id = data.season_id
    local cfg_data = DataSystem.data_daily_icon[115]
    if cfg_data.lev > RoleManager.Instance.RoleData.lev then
        return
    end
    if self.rechargeIconEffect ~= nil then
        self.rechargeIconEffect:DeleteMe()
    end
    self.click_callback = function()
        if RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionStart or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionReady or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionSuccess then
            self.model:OpenMainPanel2V2()
        else
            self:Require16401()
        end
    end
    self.sureCallback = function()
        if RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionStart or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionReady or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionSuccess then
            self.model:OpenMainPanel2V2()
        else
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_PathToTarget("54_1")
        end
    end

    AgendaManager.Instance:SetCurrLimitID(2028, data.status == 2)
    self.currstatus = data.status
    if data.status == 0 then
        --关闭
        MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
        if not (RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionStart or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionReady or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionSuccess) then
            self:CloseMainPanel()
        end
    elseif data.status == 1 then
        self:Require16407()
        MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
        if not (RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionStart or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionReady or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionSuccess) then
            self:CloseMainPanel()
        end
    elseif data.status == 2 then
        --进行中
        MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
        if self.matchdata ~= nil and self.matchdata.day_matched >= 2 then
        else
            local iconData = AtiveIconData.New()
            iconData.id = cfg_data.id
            iconData.iconPath = cfg_data.res_name
            iconData.clickCallBack = self.sureCallback
            iconData.sort = cfg_data.sort
            iconData.lev = cfg_data.lev
            iconData.timestamp = data.time + Time.time
            iconData.effectId = 20256
            iconData.effectPos = Vector3(0, 32, -400)
            iconData.effectScale = Vector3(1, 1, 1)
            iconData.timeoutCallBack = function()
                self:Require16400()
            end
            self.icon = MainUIManager.Instance:AddAtiveIcon(iconData)
            -- local fun = function(effectView)
            --     local effectObject = effectView.gameObject
            --     if BaseUtils.isnull(self.icon) then
            --         self.rechargeIconEffect:DeleteMe()
            --         self.rechargeIconEffect = nil
            --         return
            --     end
            --     print("啊啊啊啊啊")
            --     print(self.icon.transform)
            --     effectObject.transform:SetParent(self.icon.transform)
            --     effectObject.transform.localScale = Vector3(1, 1, 1)
            --     effectObject.transform.localPosition = Vector3(0, 32, -400)
            --     effectObject.transform.localRotation = Quaternion.identity

            --     Utils.ChangeLayersRecursively(effectObject.transform, "UI")
            --     effectObject:SetActive(true)
            -- end
            -- if self.rechargeIconEffect == nil or self.rechargeIconEffect.gameObject == nil then
            --     -- -- print("----------"..debug.traceback())
            --     self.rechargeIconEffect = BaseEffectView.New({effectId = 20256, time = nil, callback = fun})
            --     -- print(BaseUtils.isnull(self.rechargeIconEffect.gameObject))
            -- elseif BaseUtils.isnull(self.rechargeIconEffect.gameObject) == false then
            --     -- print(BaseUtils.isnull(self.rechargeIconEffect.gameObject))
            --     fun(self.rechargeIconEffect)
            -- end
        end
        if (self.matchdata == nil or self.matchdata.day_matched < self.matchdata.max_join) and RoleManager.Instance.RoleData.lev >= cfg_data.lev and not (RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionStart or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionReady or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionSuccess) then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("<color='#ffff00'>天下第一武道会</color>活动正在进行中，是否前往参加？")
            data.sureLabel = TI18N("确认")
            data.cancelLabel = TI18N("取消")
            data.cancelSecond = 180
            data.sureCallback = self.sureCallback
            NoticeManager.Instance:ActiveConfirmTips(data)
        elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionStart or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionReady or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionSuccess then
            self.model:OpenMainPanel2V2()
        end
    end
    self.model.activity_time = data.time + Time.time
    -- print('-------------------------收到更新计时')
    if (RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionStart or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionReady or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionSuccess) and data.status == 2 then
        -- print("在武道会event打开界面")
        self:OpenMainPanel2V2()
    end
end

function WorldChampionManager:Require16431()
    -- print("--------------------发送16431")
    Connection.Instance:send(16431)
end

function WorldChampionManager:On16431(data)
    -- print("-----------------------------收到16431")
    -- BaseUtils.dump(data,"16431-------------------")
    self.onStarChange:Fire(data)
end

function WorldChampionManager:Require16432(type)
    -- print("--------------------发送16432".."--参数："..type)
    Connection.Instance:send(16432,{type = type})
end

function WorldChampionManager:On16432(data)
    -- print("-----------------------------收到16432")
    -- BaseUtils.dump(data,"16432----------------")
end

function WorldChampionManager:On16433(data)
    -- print("-----------------------------收到16433")
    -- BaseUtils.dump(data,"16433奖励数据---------")
    LuaTimer.Add(200,function() self.model:OpenBadgeRewardWindow(data) end)
end

function WorldChampionManager:Require16435()
    -- print("--------------------发送16435")
    Connection.Instance:send(16435)
end

function WorldChampionManager:On16435(data)
    -- print("-----------------------------收到16435")
    -- BaseUtils.dump(data,"16435----------------")
    self.model:GetBadgeData(data)
    self.onGetBadgeData:Fire()
end

function WorldChampionManager:Require16434(id)
    -- print("--------------------发送16434")
    Connection.Instance:send(16434,{badge_id = id})
end

function WorldChampionManager:On16434(data)
    -- print("-----------------------------收到16434")
    -- BaseUtils.dump(data,"16434----------------")
    NoticeManager.Instance:FloatTipsByString(TI18N(data.msg))
end

function WorldChampionManager:Require16437()
    -- print("--------------------发送16437")
    Connection.Instance:send(16437)
end

function WorldChampionManager:On16437(data)
    -- print("-----------------------------收到16437")
    -- BaseUtils.dump(data,"16437----------------")
    self.model.curUse = data.badge_id
end

function WorldChampionManager:Require16436(id, platform, zone_id)
    -- print("--------------------发送16436")
    Connection.Instance:send(16436,{rid = id, platform = platform, zone_id = zone_id})
end

function WorldChampionManager:On16436(data)
    -- print("-----------------------------收到16436")
    -- BaseUtils.dump(data,"16436----------------")
end

function WorldChampionManager:Require16438(id, platform, zone_id,order)
    -- print("--------------------发送16438")
    Connection.Instance:send(16438,{rid = id, platform = platform, zone_id = zone_id,order = order})
end

function WorldChampionManager:On16438(data)
    -- print("-----------------------------收到16438")
    -- BaseUtils.dump(data,"16438----------------")
    self.model:SetBadgeInfo(data)
end


