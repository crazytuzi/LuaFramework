-- @author 黄耀聪
-- @date 2017年11月13日, 星期一

GuildDragonManager = GuildDragonManager or BaseClass(BaseManager)

function GuildDragonManager:__init()
    if GuildDragonManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    GuildDragonManager.Instance = self

    self.end_time = 0
    self.start_time = 0
    self.boss_end_time = 0
    self.boss_start_time = 0
    self.pushTimes = 0

    self.model = GuildDragonModel.New()
    self.stateEvent = EventLib.New()
    self.myInfoEvent = EventLib.New()
    self.updateRankEvent = EventLib.New()
    self.looksEvent = EventLib.New()
    self.rewardEvent = EventLib.New()
    self.activityName = TI18N("巨龙宝藏")

    self.mapId = 53009

    self.jumpPos = Vector2(640,720)
    self.landPos = Vector2(1120, 480)
    self.monsterPos = Vector2(1400, 400)

    self.jumpVertexList = {
        list = {
            Vector2(480,558),
            Vector2(400,638),
            Vector2(720,840),
            Vector2(840,720),
        },
        area = nil
    }

    self.landAreaList = {
        list = {
            Vector2(842, 40),
            Vector2(842, 678),
            Vector2(1880, 678),
            Vector2(1880, 40),
        },
        area = nil
    }

    self.blockAreaList = {
        list = {
            Vector2(81 ,1294),
            Vector2(920 ,1299),
            Vector2(1561,1757),
            Vector2(1520, 1920),
            Vector2(81 ,1920),
        },
        area = nil
    }

    self.baseIdList = {
        32011,
        32011,
        32011,
        32012,
        32013,
    }

    self:InitHandler()
end

function GuildDragonManager:__delete()
end

function GuildDragonManager:InitHandler()
    self:AddNetHandler(20500, self.on20500)
    self:AddNetHandler(20501, self.on20501)
    self:AddNetHandler(20502, self.on20502)
    self:AddNetHandler(20503, self.on20503)
    self:AddNetHandler(20504, self.on20504)
    self:AddNetHandler(20505, self.on20505)
    self:AddNetHandler(20506, self.on20506)
    self:AddNetHandler(20507, self.on20507)
    self:AddNetHandler(20508, self.on20508)
    self:AddNetHandler(20509, self.on20509)
    self:AddNetHandler(20510, self.on20510)
    self:AddNetHandler(20511, self.on20511)
    self:AddNetHandler(20512, self.on20512)
    self:AddNetHandler(20513, self.on20513)
    self:AddNetHandler(20514, self.on20514)

    EventMgr.Instance:AddListener(event_name.end_fight, function(type,result) self:EndFight(type, result) end)
    EventMgr.Instance:AddListener(event_name.role_event_change, function() self:OnEventChange() end)
    EventMgr.Instance:AddListener(event_name.scene_load, function() self:ChangeCD() end)
end

function GuildDragonManager:OpenMain(args)
    self.model:OpenMain(args)
end

function GuildDragonManager:OpenRod(args)
    self.model:OpenRod(args)
end

function GuildDragonManager:OpenSettle(args)
    self.model:OpenSettle(args)
end

function GuildDragonManager:Enter()
    if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.GuildDragon
        and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.GuildDragonFight
        and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.GuildDragonRod
        then
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.guildwindow)
        self:send20503()
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("你已经在巨龙巢穴中了"))
    end
end

function GuildDragonManager:Exit()
    if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.GuildDragon
        and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.GuildDragonFight
        and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.GuildDragonRod
        then
        NoticeManager.Instance:FloatTipsByString(TI18N("你已经走出巨龙巢穴了"))
    elseif CombatManager.Instance.isFighting then
        NoticeManager.Instance:FloatTipsByString(TI18N("你已无法逃脱巨龙的魔爪"))
    else
        local confirmData = NoticeConfirmData.New()
        confirmData.content = string.format(TI18N("是否要退出<color='#ffff00'>%s</color>？"), self.activityName)
        confirmData.sureCallback = function() self:send20509() end
        NoticeManager.Instance:ConfirmTips(confirmData)
    end
end

function GuildDragonManager:OnEventChange()
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildDragon
        or RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildDragonFight
        or RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildDragonRod
        then
        self.model:StartCheck()
    else
        self.model:EndCheck()
    end
end

function GuildDragonManager:Clean()
    self.model.rank_list = {}
    self.model.player_info = {}
    self.model.myData = nil
    self.model.myRankData = nil
end

function GuildDragonManager:RequestInitData()
    self:Clean()
    self:send20501()
end

-- 魔龙副本角色信息
function GuildDragonManager:send20500()
    Connection.Instance:send(20500, {})
end

function GuildDragonManager:on20500(data)
    if IS_DEBUG then
        BaseUtils.dump(data, "<color='#00ff00'>on20500</color>")
    end
    self.model.myData = data
    self.myInfoEvent:Fire()
end

-- 魔龙副本状态
function GuildDragonManager:send20501()
    Connection.Instance:send(20501, {})
end

function GuildDragonManager:on20501(data)
    if Application.platform == RuntimePlatform.WindowsEditor then
        --BaseUtils.dump(data, "<color='#00ff00'>on20501</color>")
    end

    self.state = data.state
    self.start_time = data.start_time
    self.end_time = data.end_time
    self.boss_start_time = data.boss_start_time
    self.boss_end_time = data.boss_end_time

    self.stateEvent:Fire()

    if self.state == GuildDragonEnum.State.Ready then
        self.model.hasNotified = false
    end

    if self:IsActive() then
        self:send20500()
    end

    if (self.state == GuildDragonEnum.State.Ready
        or self.state == GuildDragonEnum.State.First
        or self.state == GuildDragonEnum.State.Second
        or self.state == GuildDragonEnum.State.Third
        or self.state == GuildDragonEnum.State.Countdown)
        and (RoleManager.Instance.RoleData.event ~= RoleEumn.Event.GuildDragon
            and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.GuildDragonFight
            and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.GuildDragonRod)
        then
        self:OnPush()
    else
    end

    if self:IsActive() then
        if self.state == GuildDragonEnum.State.Second then
            NoticeManager.Instance:FloatTipsByString(TI18N("巨龙已经到了<color='#ffff00'>第二阶段</color>，此时挑战可以获得<color='#ffff00'>1.5倍</color>龙币！"))
        elseif self.state == GuildDragonEnum.State.Third then
            NoticeManager.Instance:FloatTipsByString(TI18N("巨龙已经到了<color='#ffff00'>第三阶段</color>，此时挑战可以获得<color='#ffff00'>2倍</color>龙币！"))
        end
    end

    self:OnEventChange()
    self:SetIcon()
end

-- 魔龙副本排行榜
function GuildDragonManager:send20502(rank_type, rank_num)
    Connection.Instance:send(20502, {rank_type = rank_type, rank_num = rank_num})
end

function GuildDragonManager:on20502(data)
    if Application.platform == RuntimePlatform.WindowsEditor then
        BaseUtils.dump(data, "<color='#00ff00'>on20502</color>")
    end
    local roleData = RoleManager.Instance.RoleData
    for _,v in ipairs(data.rank_list) do
        if v.id == roleData.id and v.platform == roleData.platform and v.zone_id == roleData.zone_id then
            self.model.myRankData = v
        end
        v.rank_type = data.rank_type
    end

    if data.rank_type == GuildDragonEnum.Rank.Personal then
        self.model.player_info = self.model.player_info or {}
        self.model.rank_list[data.rank_type] = {}
        for _,v in ipairs(data.rank_list) do
            self.model.player_info[BaseUtils.Key(v.id, v.platform, v.zone_id)] = v
        end
        for key,player in pairs(self.model.player_info) do
            table.insert(self.model.rank_list[data.rank_type], player)
        end
    else
        self.model.rank_list[data.rank_type] = data.rank_list
    end
    table.sort(self.model.rank_list[data.rank_type], function(a,b) if a.point == b.point then return a.rank_index < b.rank_index else return a.point > b.point end end)
    self.updateRankEvent:Fire(data.rank_type)
end

-- 进入魔龙副本
function GuildDragonManager:send20503()
    Connection.Instance:send(20503, {})
end

function GuildDragonManager:on20503(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        ActivityManager.Instance:StopNotice(GlobalEumn.ActivityEumn.guild_dragon)
    end
end

-- 请求掠夺信息
function GuildDragonManager:send20504()
    Connection.Instance:send(20504, {})
end

function GuildDragonManager:on20504(data)
    BaseUtils.dump(data, "on20504")
    self.model.loot_list = data.loot_list
    self.updateRankEvent:Fire(4)
end

-- 发起挑战魔龙
function GuildDragonManager:send20505()
    Connection.Instance:send(20505, {})
end

function GuildDragonManager:on20505(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 挑战魔龙完成
function GuildDragonManager:send20506()
    -- 一般不请求
    -- Connection.Instance:send20506(20506, {})
end

function GuildDragonManager:on20506(data)
    if Application.platform == RuntimePlatform.WindowsEditor then
        BaseUtils.dump(data, "on20506")
    end
    self.endFightData = data
    if not CombatManager.Instance.isFighting then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guilddragon_endfight, self.endFightData)
        self.endFightData = nil
    end
end

-- 发起掠夺
function GuildDragonManager:send20507(id, platform, zone_id)
    Connection.Instance:send(20507, {id = id, platform = platform, zone_id = zone_id})
end

function GuildDragonManager:on20507(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 掠夺玩家完成
function GuildDragonManager:send20508()
    Connection.Instance:send(20508, {})
end

function GuildDragonManager:on20508(data)
    if Application.platform == RuntimePlatform.WindowsEditor then
        BaseUtils.dump(data, "on20508")
    end
    self.endRodData = data
    if not CombatManager.Instance.isFighting then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guilddragon_endrod, self.endRodData)
        self.endRodData = nil
    end
end

-- 退出魔龙副本
function GuildDragonManager:send20509()
    Connection.Instance:send(20509, {})
end

function GuildDragonManager:on20509(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 请求玩家looks
function GuildDragonManager:send20510(id, platform, zone_id)
    Connection.Instance:send(20510, {id = id, platform = platform, zone_id = zone_id})
end

function GuildDragonManager:on20510(data)
    if Application.platform == RuntimePlatform.WindowsEditor then
        BaseUtils.dump(data, "on20510")
    end
    self.model.looks_list[BaseUtils.Key(data.id, data.platform, data.zone_id)] = {looks = data.looks, honor_id = data.honor_id, pre_id = data.pre_id}
    self.looksEvent:Fire(BaseUtils.Key(data.id, data.platform, data.zone_id))
end

-- 请求奖励信息
function GuildDragonManager:send20511(type, id, platform, zone_id)
    -- print("发送send20511")
    Connection.Instance:send(20511, {type = type, id = id, platform = platform, zone_id = zone_id})
end

function GuildDragonManager:on20511(data)
    if Application.platform == RuntimePlatform.WindowsEditor then
        BaseUtils.dump(data, "on20511")
    end
    self.model.rewardList[data.type][BaseUtils.Key(data.id, data.platform, data.zone_id)] = data.rewards
    self.rewardEvent:Fire()
end

function GuildDragonManager:send20512(data)
end

function GuildDragonManager:on20512(data)
    if Application.platform == RuntimePlatform.WindowsEditor then
        BaseUtils.dump(data, "<color='#ffff00'>====================on20512==================</color>")
    end
    for _,v in ipairs(data.person_rank_list) do
        v.rank_type = GuildDragonEnum.Rank.Personal
    end
    table.sort(data.person_rank_list, function(a,b) return a.rank_index < b.rank_index end)
    self.model.rank_list[GuildDragonEnum.Rank.Personal] = data.person_rank_list

    for _,data in ipairs(data.point_rewards) do
        data.id = data.base_id
    end

    if next(data.point_rewards) == nil then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guilddragon_settle)
    else
        FinishCountManager.Instance.model.reward_win_data = {
            titleTop = self.activityName
            , val1 = ""
            , val2 = data.msg
            , title = string.format(TI18N("%s奖励"), self.activityName)
            , confirm_str = TI18N("确 定")
            , reward_list = data.point_rewards
            , reward_title = TI18N("龙币奖励")
            , confirm_callback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guilddragon_settle) end
        }
        FinishCountManager.Instance.model:InitRewardWin_Common()
    end
end

-- 设置弹幕
function GuildDragonManager:send20513(type, value)
    Connection.Instance:send(20513, {type = type, value = value})
end

function GuildDragonManager:on20513(data)
    if data.flag == 1 then
        if data.type == GuildDragonEnum.DamakuType.System then
            self.model.myData.sys_value = data.value
        else
            self.model.myData.ply_value = data.value
        end
    end
    self.myInfoEvent:Fire()

    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 发送魔龙挑战弹幕
function GuildDragonManager:send20514(msg)
    Connection.Instance:send(20514, {msg = msg})
end

function GuildDragonManager:on20514(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function GuildDragonManager:EndFight(type, result)
    if not LoginManager.Instance.has_connected then
        return
    end

    if type == 65 then
        if self.endFightData ~= nil and self.endFightData.point ~= nil and self:IsActive() then
            if self.endFightData.point > 0 then
                NoticeManager.Instance:FloatTipsByString(string.format(TI18N("挑战成功获得%s龙币！"), self.endFightData.point or 0))
            end
            self.model:OpenEndFight(self.endFightData)
        end
        self.endFightData = nil
    elseif type == 66 then
        if self.endRodData ~= nil and self.endRodData.loot_point ~= nil and self:IsActive() then
            if self.endRodData.loot_point > 0 then
                NoticeManager.Instance:FloatTipsByString(string.format(TI18N("掠夺玩家获得%s龙币！"), self.endRodData.loot_point or 0))
            end
            self.model:OpenEndRod(self.endRodData)
        end
        self.endRodData = nil
    end
end

function GuildDragonManager:BeginFight()
    self:send20505()
end

function GuildDragonManager:CheckRedPoint()
    return self:IsActive()
end

function GuildDragonManager:GetRest(stemp)
    if self.state == GuildDragonEnum.State.Ready then
        return 1000
    -- elseif self.state == GuildDragonEnum.State.First then
    --     if stemp < self.end_time then
    --         return 667 + math.floor((self.end_time - stemp)  * 1000 / (self.end_time - self.start_time) / 3)
    --     else
    --         return 667
    --     end
    -- elseif self.state == GuildDragonEnum.State.Second then
    --     if stemp < self.end_time then
    --         return 333 + math.floor((self.end_time - stemp) * 1000 / (self.end_time - self.start_time) / 3)
    --     else
    --         return 333
    --     end
    -- elseif self.state == GuildDragonEnum.State.Third then
    --     if stemp < self.end_time then
    --         return 0 + math.floor((self.end_time - stemp) * 1000 / (self.end_time - self.start_time) / 3)
    --     else
    --         return 0
    --     end
    elseif self.state == GuildDragonEnum.State.First or self.state == GuildDragonEnum.State.Second or self.state == GuildDragonEnum.State.Third then
        return (self.boss_end_time - stemp) * 1000 / (self.boss_end_time - self.boss_start_time)
    else
        return 0
    end
end

function GuildDragonManager:Challenge()
    local dis = self:CanChallenge()
    if dis == 0 then
        if self.state == GuildDragonEnum.State.First
            or self.state == GuildDragonEnum.State.Second
            or self.state == GuildDragonEnum.State.Third
            then
            self:GotoJumpArea()
        elseif self.state == GuildDragonEnum.State.Ready then
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("巨龙已经被消灭，请自行退出"))
        end
        -- self:FindMonster()
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("受到巨龙龙威影响，无法进入巨龙峡谷！"))
    end
end

-- 正在活动中
function GuildDragonManager:IsActive()
    return (RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildDragon
        or RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildDragonFight
        or RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildDragonRod)
    and (self.state == GuildDragonEnum.State.Ready
        or self.state == GuildDragonEnum.State.Countdown
        or self.state == GuildDragonEnum.State.First
        or self.state == GuildDragonEnum.State.Second
        or self.state == GuildDragonEnum.State.Third)
end

function GuildDragonManager:IsJumpZone(target)
    if SceneManager.Instance:CurrentMapId() ~= self.mapId then return end

    local targetPoint = target:GetCachedTransform().localPosition
    targetPoint = SceneManager.Instance.sceneModel:transport_big_pos(targetPoint.x, targetPoint.y)


    if self:CheckZone(targetPoint) ~= GuildDragonEnum.Area.Jump then
        return
    end
    -- if not self:InRect(self.jumpVertexList, targetPoint) then
    --     return
    -- end

    local roleJump = SceneJump.New()
        SceneManager.Instance.sceneElementsModel:Set_isovercontroll(false)
    if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
        SceneManager.Instance.sceneElementsModel.self_view.noSendMove = true
    end
    roleJump.callback = function()
        roleJump:DeleteMe()
        SceneManager.Instance.sceneElementsModel:Set_isovercontroll(true)
        if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
            SceneManager.Instance.sceneElementsModel.self_view.noSendMove = false
        end
        -- self.tempPos = SceneManager.Instance.sceneModel:transport_small_pos(self.monsterPos.x, self.monsterPos.y)
        SceneManager.Instance.sceneElementsModel:Self_AutoPath(self.mapId, nil, self.monsterPos.x, self.monsterPos.y, true, function() LuaTimer.Add(400, function() self:send20505() end) end)
        -- LuaTimer.Add(500, function() self:FindMonster() end)
    end
    roleJump:Show({target = target, val = { targetPoint, self.landPos} })
end

function GuildDragonManager:GetArea(rect)
    if rect.area == nil then
        rect.area = 0
        local length = #rect.list
        for i=2,length - 1 do
            rect.area = rect.area + math.abs((rect.list[1].x - rect.list[i].x) * (rect.list[1].y - rect.list[i + 1].y) - (rect.list[1].y - rect.list[i].y) * (rect.list[1].x - rect.list[i + 1].x))
        end
        rect.area = rect.area / 2
    end
    return rect.area
end

function GuildDragonManager:InRect(rect, pos)
    local area = 0
    local length = #rect.list
    for i,v in ipairs(rect.list) do
        area = area + math.abs((v.x - pos.x) * (rect.list[i % length + 1].y - pos.y) - (v.y - pos.y) * (rect.list[i % length + 1].x - pos.x))
    end
    area = area / 2
    return self:GetArea(rect) >= area
end

function GuildDragonManager:CheckOnArena()
    if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
        if not SceneManager.Instance.sceneElementsModel.self_view.noSendMove then
            self:IsJumpZone(SceneManager.Instance.sceneElementsModel.self_view)
        end
    end
end

-- 是否在别的区,如果是则跳跃过去（根据别的玩家移动包处理）
function GuildDragonManager:CheckInOtherZone(target, x, y)
    if target.gameObject == nil then return false end
    if SceneManager.Instance:CurrentMapId() ~= self.mapId then return false end

    self.tempPos = target:GetCachedTransform().localPosition
    self.tempPos = SceneManager.Instance.sceneModel:transport_big_pos(self.tempPos.x, self.tempPos.y)

    local currentZone = self:CheckZone(self.tempPos)
    local clickZone = self:CheckZone(Vector2(x, y))
    -- self.tempPos = SceneManager.Instance.sceneModel:transport_big_pos(x, y)

    if currentZone ~= GuildDragonEnum.Area.Land and clickZone == GuildDragonEnum.Area.Land then
        self:JumpToPoint(target, x, y)
        -- self:IsJumpZone(target)
        return true
    end

    return false
end

function GuildDragonManager:CheckZone(pos)
    if self:InRect(self.jumpVertexList, pos) then
        return GuildDragonEnum.Area.Jump
    elseif self:InRect(self.landAreaList, pos) then
        return GuildDragonEnum.Area.Land
    elseif self:InRect(self.blockAreaList, pos) then
        return GuildDragonEnum.Area.Block
    else
        return GuildDragonEnum.Area.Walk
    end
end

function GuildDragonManager:IsLegal(target, x, y)
    if target == nil then
        return false
    end

    self.tempPos = target:GetCachedTransform().localPosition
    self.tempPos = SceneManager.Instance.sceneModel:transport_big_pos(self.tempPos.x, self.tempPos.y)

    local currentZone = self:CheckZone(self.tempPos)

    self.tempPos = SceneManager.Instance.sceneModel:transport_big_pos(x, y)
    local targetZone = self:CheckZone(self.tempPos)

    if self.state == GuildDragonEnum.State.Ready then
        -- return currentZone == GuildDragonEnum.Area.Block and currentZone == targetZone
        return true
    else
        if self:InDragonCD() then
            if targetZone == GuildDragonEnum.Area.Block or currentZone ~= GuildDragonEnum.Area.Block then
                return true
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("受龙威影响暂时无法进入，可掠夺其他玩家"))
            end
        else
            -- return ((currentZone == GuildDragonEnum.Area.Walk or currentZone == GuildDragonEnum.Area.Block) and targetZone ~= GuildDragonEnum.Area.Land) or (currentZone == targetZone)
            return currentZone ~= GuildDragonEnum.Area.Land or targetZone == GuildDragonEnum.Area.Land
        end
    end
end

function GuildDragonManager:JumpToPoint(target, x, y)
    target:StopMoveTo()
    local roleJump = SceneJump.New()
    roleJump.callback = function()
        roleJump:DeleteMe()
        target.data.x = x
        target.data.y = y
    end

    local targetPoint = target:GetCachedTransform().localPosition
    targetPoint = SceneManager.Instance.sceneModel:transport_big_pos(targetPoint.x, targetPoint.y)
    local jumpToPoint = { x = x, y = y }
    roleJump:Show({ target = target, val = { targetPoint, jumpToPoint } })
end

function GuildDragonManager:GotoJumpArea()
    if self.state == GuildDragonEnum.State.Ready then
        NoticeManager.Instance:FloatTipsByString(TI18N("当前还在准备阶段，请稍后~"))
    else
        if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
            local targetPoint = SceneManager.Instance.sceneElementsModel.self_view:GetCachedTransform().localPosition
            targetPoint = SceneManager.Instance.sceneModel:transport_big_pos(targetPoint.x, targetPoint.y)
            if self:CheckZone(Vector2(targetPoint.x, targetPoint.y)) == GuildDragonEnum.Area.Land then
                NoticeManager.Instance:FloatTipsByString(TI18N("您已经在魔龙的领域内，快去挑战吧！"))
            else
                SceneManager.Instance.sceneElementsModel:Self_AutoPath(self.mapId, nil, self.jumpPos.x, self.jumpPos.y, false, nil)
            end
        end
    end
end

function GuildDragonManager:FindMonster()
    QuestManager.Instance.model:FindNpc(string.format("%s_%s", self.baseIdList[self.state], 54))
end

function GuildDragonManager:SetIcon()
    if self.state == GuildDragonEnum.State.Close then
        MainUIManager.Instance:DelAtiveIcon(364)
        if self.activeIconData ~= nil then
            self.activeIconData:DeleteMe()
            self.activeIconData = nil
        end
    else
        self.activeIconData = self.activeIconData or AtiveIconData.New()
        local iconData = DataSystem.data_daily_icon[364]
        self.activeIconData.id = iconData.id
        self.activeIconData.iconPath = iconData.res_name
        self.activeIconData.sort = iconData.sort
        self.activeIconData.lev = iconData.lev
        if self.state == GuildDragonEnum.State.Ready then
            self.activeIconData.timestamp = Time.time + self:GetRestTime() + 25 * 60
        else
            self.activeIconData.timestamp = Time.time + self:GetRestTime()
        end
        self.activeIconData.clickCallBack = function() self:Enter() end

        MainUIManager.Instance:AddAtiveIcon(self.activeIconData)
    end
end

function GuildDragonManager:GetRestTime()
    if self.state == GuildDragonEnum.State.Countdown then
        return self.end_time - BaseUtils.BASE_TIME + 25 * 60 + 5
    elseif self.state == GuildDragonEnum.State.Reward
        or self.state == GuildDragonEnum.State.Third
        or self.state == GuildDragonEnum.State.Ready
        then
        return self.end_time - BaseUtils.BASE_TIME
    elseif self.state == GuildDragonEnum.State.First then
        return self.end_time - BaseUtils.BASE_TIME + 17 * 60
    elseif self.state == GuildDragonEnum.State.Second then
        return self.end_time - BaseUtils.BASE_TIME + 9 * 60
    end
    return 0
end

function GuildDragonManager:CanChallenge()
    if (self.model.myData == nil or self.model.myData.challenge_time == nil or self.model.myData.challenge_time == 0 or BaseUtils.BASE_TIME >= self.model.myData.challenge_time) then
        return 0
    else
        return self.model.myData.challenge_time - BaseUtils.BASE_TIME
    end
end

function GuildDragonManager:ChangeCD()
    if self:IsActive() and self:InDragonCD() and not CombatManager.Instance.isFighting then
        if self.maincamera_effect == nil then
            local fun = function(effectView)
                local effectObject = effectView.gameObject

                effectObject.transform:SetParent(SceneManager.Instance.MainCamera.gameObject.transform)
                effectObject.transform.localScale = Vector3(1.95 / SceneManager.Instance.DefaultCameraSize, 1, 1)
                effectObject.transform.localPosition = Vector3(0, 0, 0)
                effectObject.transform.localRotation = Quaternion.identity

                Utils.ChangeLayersRecursively(effectObject.transform, "Default")

                if BaseUtils.IsWideScreen() then
                    local scaleX = (ctx.ScreenWidth / ctx.ScreenHeight) / (16 / 9)
                    effectObject.transform.localScale = Vector3(scaleX, 1, 1)
                else
                    local scaleY = (ctx.ScreenHeight/ ctx.ScreenWidth) / (9 / 16)
                    effectObject.transform.localScale = Vector3(1, scaleY, 1)
                end
            end
            self.maincamera_effect = BaseEffectView.New({effectId = 20061, time = nil, callback = fun})
        end

        if self.scene_effect == nil then
            local fun = function(effectView)
                local effectObject = effectView.gameObject

                effectObject.transform:SetParent(SceneManager.Instance.sceneModel.sceneView.gameObject.transform)
                effectObject.transform.localScale = Vector3.one
                local p = SceneManager.Instance.sceneModel:transport_small_pos(1477, 1347)
                effectObject.transform.localPosition = Vector3(p.x, p.y, 0)
                effectObject.transform.localRotation = Quaternion.identity

                Utils.ChangeLayersRecursively(effectObject.transform, "Default")
            end
            self.scene_effect = BaseEffectView.New({effectId = 30063, time = nil, callback = fun})
        end
    else
        if self.maincamera_effect ~= nil then
            self.maincamera_effect:DeleteMe()
            self.maincamera_effect = nil
        end
        if self.scene_effect ~= nil then
            self.scene_effect:DeleteMe()
            self.scene_effect = nil
        end
    end
end

function GuildDragonManager:InDragonCD()
    return self.state ~= GuildDragonEnum.State.Ready and self.model.myData ~= nil and (self.model.myData.challenge_time > BaseUtils.BASE_TIME or self.state == GuildDragonEnum.State.Countdown)
end

function GuildDragonManager:InLootCD()
    return self.state ~= GuildDragonEnum.State.Ready and self.model.myData ~= nil and self.model.myData.loot_time > BaseUtils.BASE_TIME
end

function GuildDragonManager:InAfterReadyCD()
    return GuildDragonManager.Instance.state == GuildDragonEnum.State.First and (BaseUtils.BASE_TIME - GuildDragonManager.Instance.start_time < 5)
end

function GuildDragonManager:OnPush()
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildDragon
        or RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildDragonFight
        or RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildDragonRod
        then
        ActivityManager.Instance:StopNotice(GlobalEumn.ActivityEumn.guild_dragon)
        return
    end

    local iconData = DataSystem.data_daily_icon[364]
    if RoleManager.Instance.RoleData.lev < iconData.lev then
        return
    end

    if ActivityManager.Instance:GetNoticeState(GlobalEumn.ActivityEumn.guild_dragon) == false then
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.content = string.format(TI18N("<color=#FFFF00>%s</color>活动已开启，是否前往参加？"), self.activityName)
        confirmData.sureSecond = -1
        confirmData.cancelSecond = 180
        confirmData.sureLabel = TI18N("确认")
        confirmData.cancelLabel = TI18N("取消")
        confirmData.sureCallback = function() self:Enter() end

        if RoleManager.Instance.RoleData.cross_type == 1 then
            -- 如果处在中央服，先回到本服在参加活动
            RoleManager.Instance.jump_over_call = function() self:Enter() end
            confirmData.sureCallback = SceneManager.Instance.quitCenter
            confirmData.content = string.format(TI18N("<color='#ffff00'>%s</color>活动已开启，是否<color='#ffff00'>返回原服</color>参加？"), self.activityName)
        end

        NoticeManager.Instance:ActiveConfirmTips(confirmData, GlobalEumn.ActivityEumn.guild_dragon)
        ActivityManager.Instance:MarkNoticeState(GlobalEumn.ActivityEumn.guild_dragon)
    end
end

function GuildDragonManager:GetMyRank()
    return self.model.myRankData
end

