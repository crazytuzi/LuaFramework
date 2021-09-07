-- ----------------
-- -- 组队模块
-- -- lqg
-- ----------------
TeamManager = TeamManager or BaseClass(BaseManager)

function TeamManager:__init()
    if TeamManager.Instance then
        return
    end
    TeamManager.Instance = self
    self.model = TeamModel.New()

    self:InitHandler()

    -- 标志是否是刚刚登录
    self.IsLogined = false

    -- 以uniqueid为key
    self.memberOrderList = {}
    self.memberTab = {}
    self.captinId = ""
    self.captinData = nil

    -- 邀请列表
    self.requestsTab = {}
    -- 申请列表
    self.applysTab = {}

    -- 队伍类型
    self.TypeOptions = {}
    -- 等级类型
    self.LevelOption = 0
    -- 缓存上次队伍类型
    self.TempTypeOptions = {}
    -- 缓存上次等级类型
    self.TempLevelOption = 0

    -- 当前队伍类型信息
    self.TypeData = TeamTypeData.New()
    -- 当前匹配状态
    self.matchStatus = TeamEumn.MatchStatus.None

    self.sureBack = function() self:Send11707() end

    -- 记录需要在取消招募后重新招募
    self.needReMatch = false

    -- 处理出来的一级标签
    self.FirstList = {}
    -- 处理出来的二级标签
    self.FirstToSecond = {}

    self.sceneListener = function() self:OnSceneLoaded() end

    -- 自己请求归队
    self.selfBack = false

    -- 聊天显示的匹配信息列表
    self.chatShowMatchTab = {}

    -- 队伍人数
    self.teamNumber = 0

    self.offerCheckSure = function()
        self.TypeOptions = {}
        self.TypeOptions[5] = 0
        self.LevelOption = 1
        self.needReMatch = true
        self:ReMatch()
    end

    self.fairylandCheckSure = function()
        self.TypeOptions = {}
        self.TypeOptions[6] = 62
        self.LevelOption = 1
        self.needReMatch = true
        self:ReMatch()
    end

    -- 同意替换队长
    self.sureChangeCaptin = function()
        self:Send11731(1)
    end

    -- 发对替换队长
    self.refuseChangeCaption = function()
        self:Send11731(0)
    end

    -- 战斗退出退队标志
    self.endFightQuit = false
    -- 战斗中创建队伍标志
    self.endFightCreate = false
    -- 战斗中归队标志
    self.endFightBack = false
    -- 战斗中顶替队长标志
    self.endFightChange = false
    -- 战斗中委任队长
    self.endFightGive = false
    self.giveRid = 0
    self.givePlatform = 0
    self.giveZoneId = 0
    self.giveName = 0
    -- 战斗中踢在线
    self.endFightKick = false
    self.kickRid = 0
    self.kickPlatform = 0
    self.kickZoneId = 0
    self.kickName = 0

    -- 标志需要提示双倍
    self.showDoubleTips = true

    -- 是否跨服
    self.IsCross = nil
    -- 匹配倒计时
    self.crossTime = nil
    self.crossTimeEndCall = function() self:ShowCrossTimeTips() end
    self.crossMatchTimeCall = function() self:CrossMatchTimeEnd() end
    self.hasShowMatchNotice = false -- 是否已经显示提示
    self.needContuineMatch = false -- 需要继续匹配
    self.crossAutoMatch = true -- 是否进入跨服后自动匹配

    -- 队伍精准匹配信息
    self.recruitDataList = {}

    self.OnUpdateRecruitDataList = EventLib.New()

    self.OnUpdateRecruitDataList:Add(self.model._UpdateRecruitDataList)

    -- 招募喊话
    self.worldMatchFlag = 0

    self.teamCrossType = nil
end

function TeamManager:RequestInitData()
    self:StopCrossTime()
    self.endFightQuit = false
    self.endFightCreate = false
    self.endFightBack = false
    self.endFightChange = false
    self.endFightKick = false
    self.kickRid = 0
    self.kickPlatform = 0
    self.kickZoneId = 0
    self.kickName = 0
    self.endFightGive = false
    self.giveRid = 0
    self.givePlatform = 0
    self.giveZoneId = 0
    self.giveName = 0
    self.IsCross = nil
    self.hasShowMatchNotice = false
    self.needContuineMatch = false

    self:MatchData()

    self:Send11700()
    self:Send11735()

    self:Send11737(2)

    local role = RoleManager.Instance.RoleData
    self.selfUniqueid = BaseUtils.get_unique_roleid(role.id, role.zone_id, role.platform)

    --设置默认值
    TeamManager.Instance.TypeOptions[5] = 0
    TeamManager.Instance.LevelOption = 1

    EventMgr.Instance:AddListener(event_name.role_level_change, function() self:MatchData() end)
    EventMgr.Instance:AddListener(event_name.server_end_fight, function() self:OnEndFight() end)
end

function TeamManager:OnEndFight()
    if self.endFightQuit then
        -- 退队 
        self.endFightQuit = false
        LuaTimer.Add(500, function() self:Send11708() end)
    elseif self.endFightCreate then
        -- 创建
        self.endFightCreate = false
        LuaTimer.Add(500, function() self:Send11701() end)
    elseif self.endFightBack then
        -- 归队
        self.endFightBack = false
        LuaTimer.Add(500, function() self:Send11707() end)
    elseif self.endFightChange then
        -- 顶替队长
        self.endFightChange = false
        LuaTimer.Add(500, function() self:Send11730() end)
    elseif self.endFightKick then
        -- 踢出队伍
        self.endFightKick = false
        LuaTimer.Add(500, function() self:Send11710(self.kickRid, self.kickPlatform, self.kickZoneId, self.kickName) end)
    elseif self.endFightGive then
        self.endFightGive = false
        LuaTimer.Add(500, function() self:Send11705(self.giveRid, self.givePlatform, self.giveZoneId, self.giveName) end)
    end
end

function TeamManager:OnSceneLoaded()
    EventMgr.Instance:RemoveListener(event_name.current_trasport_succ, self.sceneListener)
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.sceneListener)
    local func = function()
        if self.captinData ~= nil then
            local uniqueid = BaseUtils.get_unique_roleid(self.captinData.rid, self.captinData.zone_id, self.captinData.platform)
            local captinSceneData = SceneManager.Instance.sceneElementsModel:GetSceneData_OneRole(uniqueid)
            if captinSceneData ~= nil and captinSceneData.status == RoleEumn.Status.Fight then
                -- 归队成功后，如果队长在战斗中，请求观战
                CombatManager.Instance:Send10705(self.captinData.rid, self.captinData.platform, self.captinData.zone_id)
            end
        end
    end
    LuaTimer.Add(500, func)
end

-- 获取当前等级段的匹配或招募选项列表
-- 或者在当前活动场景的限制
function TeamManager:MatchData()
    self.FirstList = {}
    self.FirstToSecond = {}
    local roleLev = RoleManager.Instance.RoleData.lev
    for id,data in pairs(DataTeam.data_match) do
        local tab_id = data.tab_id
        -- if roleLev >= data.open_lev then
            if self.FirstToSecond[tab_id] == nil then
                self.FirstToSecond[tab_id] = {}
            end
            table.insert(self.FirstToSecond[tab_id], data)
        -- end
    end
    for tab_id,list in pairs(self.FirstToSecond) do
        self.FirstList[tab_id] = list[1]
        if #list == 1 then
            self.FirstToSecond[tab_id] = nil
        elseif tab_id == 15 then
            local type = StarChallengeManager.Instance.model:GetTeamType()
            self.FirstList[tab_id] = DataTeam.data_match[type]
            self.FirstToSecond[tab_id] = nil
        elseif tab_id == 16 then
            local type = ApocalypseLordManager.Instance.model:GetTeamType()
            self.FirstList[tab_id] = DataTeam.data_match[type]
            self.FirstToSecond[tab_id] = nil
        elseif tab_id == 20 then
            local type = CanYonManager.Instance:GetTeamTypeID()
            self.FirstList[tab_id] = DataTeam.data_match[type]
            -- self.FirstToSecond[tab_id] = nil
        end
    end
end

function TeamManager:FirstTab(id)
    return self.FirstList[id]
end

function TeamManager:SecondTab(id)
    return DataTeam.data_match[id]
end

function TeamManager:OpenMain(args)
    self.model:OpenMain(args)
end

function TeamManager:CloseMain()
    self.model:CloseMain()
end

function TeamManager:Notice(msg)
    if msg ~= nil and msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(msg)
    end
end

-- -------------------------------
-- 外部调用数据接口
-- -------------------------------
function TeamManager:ReMatch()
    if self.needReMatch then
        self.needReMatch = false
        self:AutoFind()
    end
end

function TeamManager:IsSelfCaptin()
    if self:MyStatus() == RoleEumn.TeamStatus.Leader then
        return true
    else
        return false
    end
end

function TeamManager:HasTeam()
    if self:MyStatus() == RoleEumn.TeamStatus.None then
        return false
    else
        return true
    end
end

-- 获取成员数量
function TeamManager:MemberCount()
    return #self:GetMemberOrderList()
end

-- 获取自己的队伍状态
function TeamManager:MyStatus()
    local member = self.memberTab[self.selfUniqueid]
    if member ~= nil then
        return member.status
    end
    return RoleEumn.TeamStatus.None
end

-- 获取自己的匹配状态
function TeamManager:MyMatchStatus()
    return self.matchStatus
end

-- 获取某人队伍状态，队伍里的的才有结果
function TeamManager:SomeOneStatus(uniqueid)
    local member = self.memberTab[uniqueid]
    if member ~= nil then
        return member.status
    end
    return RoleEumn.TeamStatus.None
end

-- 按队伍状态获取的队员列表
function TeamManager:GetMemberByTeamStatus(teamStatus)
    local list = {}
    for uniqueid,member in pairs(self.memberTab) do
        if member.status == teamStatus then
            table.insert(list, member)
        end
    end
    return list
end

-- 队伍是否有人暂离
function TeamManager:HasLeave()
    local result = false
    for k,v in pairs(self.memberTab) do
        if v.status == RoleEumn.TeamStatus.Away then
            result = true
        end
    end
    return result
end

-- 队伍是否有人离线
function TeamManager:HasOffline()
    local result = false
    for k,v in pairs(self.memberTab) do
        if v.status == RoleEumn.TeamStatus.Offline then
            result = true
        end
    end
    return result
end

function TeamManager:Clear()
    self:StopCrossTime()
    self.endFightQuit = false
    self.showDoubleTips = true
    self.memberTab = {}
    self.applysTab = {}
    self.requestsTab = {}
    self.memberOrderList = {}
    self.captinId = ""
    self.captinData = nil
    self.TypeData:Reset()
    self.matchStatus = TeamEumn.MatchStatus.None
    RoleManager.Instance.RoleData.team_status = RoleEumn.TeamStatus.None
    EventMgr.Instance:Fire(event_name.team_list_update)
    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath_AndTopEffect()

    if self.hasShowMatchNotice then
        NoticeManager.Instance:CloseConfrimTips()
        self.hasShowMatchNotice = false
    end
end

-- 获取按位置排好的成员列表
function TeamManager:GetMemberOrderList()
    local list = {}
    for uniqueid,member in pairs(self.memberTab) do
        table.insert(list, member)
    end
    table.sort(list, function(a,b) return a.number < b.number end)
    return list
end

--检查自己是否能够进行操作
function TeamManager:CanRun()
    if self:MyStatus() == RoleEumn.TeamStatus.Follow then
        -- 只有跟随状态下自己不能操作
        return false
    else
        return true
    end
end

-- 查看某人是否在自己队列
function TeamManager:IsInMyTeam(uniqueid)
    if self:MyStatus() == RoleEumn.TeamStatus.None then
        return false
    else
        return self.memberTab[uniqueid] ~= nil
    end
end

-- 获取申请或邀请列表
function TeamManager:GetList()
    local list = {}
    if self:MyStatus() == RoleEumn.TeamStatus.Leader then
        for k,v in pairs(self.applysTab) do
            table.insert(list, v)
        end
    elseif self:MyStatus() == RoleEumn.TeamStatus.None then
        for k,v in pairs(self.requestsTab) do
            table.insert(list, v)
        end
    end
    return list
end

-- 邀请组队
function TeamManager:CallAndCreate(rid, platform, zone_id)
    -- 有对就邀请，没队就先创建再邀请
    if not self:HasTeam() then
        self:Send11701()
    end
    self:Send11702(rid, platform, zone_id)
end

-- 申请入队
function TeamManager:LetMeIn(rid, platform, zone_id)
    if not self:HasTeam() then
        self:Send11704(rid, platform, zone_id)
    end
end

-- 踢出队伍
function TeamManager:KickOut(rid, platform, zone_id, name)
    if self:MyStatus() == RoleEumn.TeamStatus.Leader then
        self:Send11710(rid, platform, zone_id, name)
    end
end

-- 招募或匹配
function TeamManager:AutoFind()
    self.TempTypeOptions = BaseUtils.copytab(self.TypeOptions)
    self.TempLevelOption = self.LevelOption

    local types = {}
    for first,second in pairs(self.TypeOptions) do
        if second == 0 then
            local id = self.FirstList[first].id
            table.insert(types, {type = id})
        else
            local id = DataTeam.data_match[second].id
            table.insert(types, {type = id})
        end
    end

    if #types == 0 then
        return
    end

    if self:MyStatus() == RoleEumn.TeamStatus.Leader then
        if not self.needReMatch and self.matchStatus == TeamEumn.MatchStatus.Recruiting then
            self:Send11719()
        else
            self:Send11711(types[1].type, self.LevelOption)
        end
    elseif self:MyStatus() == RoleEumn.TeamStatus.None then
        if not self.needReMatch and self.matchStatus == TeamEumn.MatchStatus.Matching then
            self:Send11720()
        else
            self:Send11714(types)
        end
    end
    self.needReMatch = false
end

-- 是否有未处理的邀请/申请
function TeamManager:HasApply()
    for k,v in pairs(self.applysTab) do
        return true
    end
    return false
end

function TeamManager:HasRequest()
    for k,v in pairs(self.requestsTab) do
        return true
    end
    return false
end

function TeamManager:DefaultSetting()
    if self.TypeData.lev_flag ~= 0 then
        self.LevelOption = self.TypeData.lev_flag
    end
    if self.TypeData.type ~= 0 then
        self.TypeOptions = {}
        local tdata = DataTeam.data_match[self.TypeData.type]
        local tab_id = tdata.tab_id
        if self.FirstToSecond[tab_id] ~= nil then
            self.TypeOptions[tab_id] = tdata.id
        else
            self.TypeOptions[tab_id] = 0
        end
    end
    if self.TypeData.status == 1 then
        self.matchStatus = TeamEumn.MatchStatus.Recruiting
    else
        self.matchStatus = TeamEumn.MatchStatus.None
    end
end

-- 获取场景上的附近队伍
function TeamManager:GetSceneTeam(needNum)
    local list = {}
    for uniqueid,npcView in pairs(SceneManager.Instance.sceneElementsModel.RoleView_List) do
        if #list == needNum then
            return list
        end
        local data = npcView.data
        if data.team_status == 1 and data.uniqueid ~= self.selfUniqueid then
            -- 取队长
            table.insert(list, data)
        end
    end
    for uniqueid,data in pairs(SceneManager.Instance.sceneElementsModel.WaitForCreateUnitData_List) do
        if #list == needNum then
            return list
        end
        if data.team_status == 1 and data.uniqueid ~= self.selfUniqueid then
            -- 取队长
            table.insert(list, data)
        end
    end
    table.sort(list,  function(a,b)
                            if a.team_num == 5 then
                                return a.team_num < b.team_num
                            end
                            return a.team_num > b.team_num
                        end)
    return list
end

-- 获取场景上的人
function TeamManager:GetSceneMember(needNum)
    local list = {}
    for uniqueid,npcView in pairs(SceneManager.Instance.sceneElementsModel.RoleView_List) do
        if #list == needNum then
            return list
        end
        local data = npcView.data
        if data.team_status == 0 and data.uniqueid ~= self.selfUniqueid and not self:IsInMyTeam(data.uniqueid) then
            -- 取队长
            table.insert(list, data)
        end
    end
    for uniqueid,data in pairs(SceneManager.Instance.sceneElementsModel.WaitForCreateUnitData_List) do
        if #list == needNum then
            return list
        end
        if data.team_status == 0 and data.uniqueid ~= self.selfUniqueid and not self:IsInMyTeam(data.uniqueid) then
            -- 取队长
            table.insert(list, data)
        end
    end
    return list
end

-- 检查是否满足任务追踪引导
function TeamManager:CheckGuideQuestTrace()
    if RoleManager.Instance.RoleData.lev > 26 then
        return
    end
    if MainUIManager.Instance.mainuitracepanel ~= nil and MainUIManager.Instance.mainuitracepanel.traceQuest ~= nil then
        if self:MemberCount() > 1 then
            MainUIManager.Instance.mainuitracepanel.traceQuest:HideEffectBefore()
        else
            MainUIManager.Instance.mainuitracepanel.traceQuest:PlayEffect()
        end
    end
end

-- -------------------------------------------------------------------
-- 接受协议处理
-- -------------------------------------------------------------------
function TeamManager:InitHandler()
    self:AddNetHandler(11700, self.On11700)
    self:AddNetHandler(11701, self.On11701)
    self:AddNetHandler(11702, self.On11702)
    self:AddNetHandler(11703, self.On11703)
    self:AddNetHandler(11704, self.On11704)
    self:AddNetHandler(11705, self.On11705)
    self:AddNetHandler(11706, self.On11706)
    self:AddNetHandler(11707, self.On11707)
    self:AddNetHandler(11708, self.On11708)
    self:AddNetHandler(11709, self.On11709)
    self:AddNetHandler(11710, self.On11710)
    self:AddNetHandler(11711, self.On11711)
    self:AddNetHandler(11712, self.On11712)
    self:AddNetHandler(11713, self.On11713)
    self:AddNetHandler(11714, self.On11714)
    self:AddNetHandler(11715, self.On11715)
    self:AddNetHandler(11716, self.On11716)
    self:AddNetHandler(11717, self.On11717)
    self:AddNetHandler(11718, self.On11718)
    self:AddNetHandler(11719, self.On11719)
    self:AddNetHandler(11720, self.On11720)
    self:AddNetHandler(11721, self.On11721)
    self:AddNetHandler(11722, self.On11722)
    self:AddNetHandler(11723, self.On11723)
    self:AddNetHandler(11724, self.On11724)
    self:AddNetHandler(11725, self.On11725)
    self:AddNetHandler(11726, self.On11726)
    self:AddNetHandler(11727, self.On11727)
    self:AddNetHandler(11728, self.On11728)
    self:AddNetHandler(11729, self.On11729)
    self:AddNetHandler(11730, self.On11730)
    self:AddNetHandler(11731, self.On11731)
    self:AddNetHandler(11732, self.On11732)
    self:AddNetHandler(11733, self.On11733)
    self:AddNetHandler(11734, self.On11734)
    self:AddNetHandler(11735, self.On11735)
    self:AddNetHandler(11736, self.On11736)
    self:AddNetHandler(11737, self.On11737)
    self:AddNetHandler(11738, self.On11738)
    self:AddNetHandler(11739, self.On11739)
end

-- 队伍信息更新
function TeamManager:Send11700()
    self:Send(11700, {})
end

function TeamManager:On11700(dat)
    --BaseUtils.dump(dat, "队伍信息")
    self:Clear()

    self.TypeData:Update(dat)
    self:DefaultSetting()
    -- BaseUtils.dump(self.TypeData, "队伍信息")
    if #dat.members > 5 then
        Debug.LogError("On11700 队伍人数超过5，现为："..tostring(#dat.members))
    end

    for i,proto in ipairs(dat.members) do
        local member = TeamData.New()
        local uniqueid = BaseUtils.get_unique_roleid(proto.rid, proto.zone_id, proto.platform)
        member:Update(proto)
        member.uniqueid = uniqueid
        self.memberTab[uniqueid] = member
        if member.status == RoleEumn.TeamStatus.Leader then --队长
            self.captinId = member.uniqueid
            self.captinData = member
        end
        if uniqueid == self.selfUniqueid then
            -- 自己
            RoleManager.Instance.RoleData.team_status = member.status
        end
    end
    for i,order in ipairs(dat.order) do
        local uniqueid = BaseUtils.get_unique_roleid(order.rid, order.zone_id, order.platform)
        table.insert(self.memberOrderList, uniqueid)
        self.memberTab[uniqueid].number = i
    end

    self.teamNumber = #self.memberOrderList

    if self:MyStatus() ~= RoleEumn.TeamStatus.Leader then
        self.matchStatus = TeamEumn.MatchStatus.None
    end

    EventMgr.Instance:Fire(event_name.team_update)

    if self.IsLogined then
        if self:MyStatus() == RoleEumn.TeamStatus.Away then
            -- 进队自动归队
            self:Send11707()
        end
        self.chatShowMatchTab = {}
        ChatManager.Instance.model:UpdateMatchMsg()
    end
    self.IsLogined = true

    self:CheckGuideQuestTrace()

    if self:MyStatus() == RoleEumn.TeamStatus.None then
        -- 请求匹配时间，恢复显示
        self:Send11714({})
    elseif self:MyStatus() == RoleEumn.TeamStatus.Leader and self.needContuineMatch then
        self.needContuineMatch = false
        self:AutoFind()
    end
end

--创建队伍
function TeamManager:Send11701()
    if RoleManager.Instance.RoleData.status == RoleEumn.Status.Fight and not CombatManager.Instance.isWatching and not CombatManager.Instance.isWatchRecorder then
        self.endFightCreate = true
        NoticeManager.Instance:FloatTipsByString(TI18N("将在战斗结束后创建队伍"))
    else
        self:Send(11701, {})
    end
end

function TeamManager:On11701(dat)
    self:Notice(dat.msg)
end

--邀请进队
function TeamManager:Send11702(id, pf, zone)
    local uniqueid = BaseUtils.get_unique_roleid(id, zone, pf)
    if uniqueid ~= self.selfUniqueid  then
        self:Send(11702,{rid = id, platform = pf, zone_id = zone})
    else
        self:Notice(TI18N("不能对自己操作"))
    end
end

function TeamManager:On11702(dat)
    self:Notice(dat.msg)
end

--请求进队
function TeamManager:Send11704(id, pf, zone)
    local uniqueid = BaseUtils.get_unique_roleid(id, zone, pf)
    if uniqueid ~= self.selfUniqueid  then
        self:Send(11704,{rid = id, platform = pf, zone_id = zone})
    else
        self:Notice(TI18N("不能对自己操作"))
    end
end

function TeamManager:On11704(dat)
    self:Notice(dat.msg)
end

--委任队长
function TeamManager:Send11705(id, pf, zone, name)
    self.giveRid = id
    self.givePlatform = pf
    self.giveZoneId = zone
    self.giveName = name
    if RoleManager.Instance.RoleData.status == RoleEumn.Status.Fight and not CombatManager.Instance.isWatching and not CombatManager.Instance.isWatchRecorder then
        self.endFightGive = not self.endFightGive
        if self.endFightGive then
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("将在战斗结束后委任<color='#ffff00'>%s</color>为队长，点击<color='#ffff00'>取消委任</color>可取消"), self.giveName))
        end
        return
    end

    local uniqueid = BaseUtils.get_unique_roleid(id, zone, pf)
    if uniqueid ~= self.selfUniqueid  then
        if QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.teacher) ~= nil then
            -- 如果身上有师徒任务的话，要提示转让会删除任务
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("您当前正在进行师徒任务，若把队长转让给第三者将<color='#ffff00'>删除任务</color>，需重新领取。")
            data.sureLabel = TI18N("确定")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = function() self:Send(11705,{rid = id, platform = pf, zone_id = zone}) end
            NoticeManager.Instance:ConfirmTips(data)
        elseif CanYonManager.Instance:CanyonRunningStatus() then 
            CanYonManager.Instance:ChangeTeamStopCanyonRunning()
        else
            self:Send(11705,{rid = id, platform = pf, zone_id = zone})
        end
    else
        self:Notice(TI18N("不能对自己操作"))
    end
end

function TeamManager:On11705(dat)
    self:Notice(dat.msg)
end

--暂离
function TeamManager:Send11706()
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.DragonBoat then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = string.format(TI18N("%s活动中，暂离将<color='#ffff00'>无法归队</color>，也<color='#ffff00'>不能取得成绩</color>，是否<color='#ffff00'>暂离</color>"), DragonBoatManager.Instance.title_name)
        data.sureLabel = TI18N("取 消")
        data.cancelLabel = TI18N("依然暂离")
        data.cancelCallback = function() self:Send(11706,{}) end
        NoticeManager.Instance:ConfirmTips(data)
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.GodsWar then
        GodsWarManager.Instance:TeamChange(11706, function() self:Send(11706,{}) end)
    elseif CanYonManager.Instance:CanyonRunningStatus() then 
        CanYonManager.Instance:ChangeTeamStopCanyonRunning()
    else
        self:Send(11706,{})
    end
end

function TeamManager:On11706(dat)
    self:Notice(dat.msg)
end

--归队
function TeamManager:Send11707()
    if RoleManager.Instance.RoleData.status == RoleEumn.Status.Fight and not CombatManager.Instance.isWatching and not CombatManager.Instance.isWatchRecorder then
        self.endFightBack = not self.endFightBack
        if self.endFightBack then
            NoticeManager.Instance:FloatTipsByString(TI18N("将在战斗结束后归队，点击<color='#ffff00'>取消归队</color>可取消"))
        end
    else
        EventMgr.Instance:AddListener(event_name.current_trasport_succ, self.sceneListener)
        EventMgr.Instance:AddListener(event_name.scene_load, self.sceneListener)
        self:Send(11707,{})
    end
end

function TeamManager:On11707(dat)
    self:Notice(dat.msg)
end

--退队
function TeamManager:Send11708()
    if RoleManager.Instance.RoleData.status == RoleEumn.Status.Fight and not CombatManager.Instance.isWatching and not CombatManager.Instance.isWatchRecorder then
        self.endFightQuit = not self.endFightQuit
        if self.endFightQuit then
            NoticeManager.Instance:FloatTipsByString(TI18N("将在战斗结束后退出队伍，点击<color='#ffff00'>取消退队</color>可取消"))
        end
        return
    end

    if QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.teacher) ~= nil then
        -- 如果身上有师徒任务的话，要提示离队会删除任务
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("您当前正在进行师徒任务，离队后将<color='#ffff00'>删除任务</color>，需重新领取。")
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function() self:Send(11708, {}) end
        NoticeManager.Instance:ConfirmTips(data)
    elseif self:MemberCount() >= 3 and self:CheckPunish(self.selfUniqueid) then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        if self:MyStatus() == RoleEumn.TeamStatus.Leader then
            data.content = TI18N("队友才刚匹配进来，如果退出队伍需要消耗{assets_1,90006,10}，是否确定？")
        else
            data.content = TI18N("你才刚匹配进队伍，如果退出队伍需要消耗{assets_1,90006,10}，是否确定？")
        end
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function() self:Send(11708, {}) end
        NoticeManager.Instance:ConfirmTips(data)
    elseif PetLoveManager.Instance.cur_type == 2 then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("退队后将清空双方任务进度<color='#ffff00'>（奖励不能重复获得）</color>")
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function() self:Send(11708, {}) end
        NoticeManager.Instance:ConfirmTips(data)
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.GodsWar then
        GodsWarManager.Instance:TeamChange(11708, function() self:Send(11708,{}) end)
    elseif CanYonManager.Instance:CanyonRunningStatus() then 
        CanYonManager.Instance:ChangeTeamStopCanyonRunning()
    else
        self:Send(11708,{})
    end
end

function TeamManager:On11708(dat)
    self:Notice(dat.msg)
    if dat.result == 1 then
        self:Clear()
        EventMgr.Instance:Fire(event_name.team_leave)
        self:CheckNoticeLeave()
    end
end

--召唤归队
function TeamManager:Send11709(id, pf, zone, name)
    local uniqueid = BaseUtils.get_unique_roleid(id, zone, pf)
    if uniqueid ~= self.selfUniqueid  then
        self:Send(11709,{rid = id, platform = pf, zone_id = zone})
    else
        self:Notice(TI18N("不能对自己操作"))
    end
end

function TeamManager:On11709(dat)
    self:Notice(dat.msg)
end

--踢出队伍
function TeamManager:Send11710(id, pf, zone, name)
    self.kickRid = id
    self.kickPlatform = pf
    self.kickZoneId = zone
    self.kickName = name or TI18N("队员")
    if RoleManager.Instance.RoleData.status == RoleEumn.Status.Fight and not CombatManager.Instance.isWatching and not CombatManager.Instance.isWatchRecorder then
        self.endFightKick = not self.endFightKick
        if self.endFightKick then
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("将在战斗结束后把<color='#ffff00'>%s</color>踢出队伍，点击<color='#ffff00'>取消踢出</color>可取消"), self.kickName))
        end
        return
    end


    local uniqueid = BaseUtils.get_unique_roleid(id, zone, pf)
    local selectedMember = self.memberTab[uniqueid]
    local func = function()
        if uniqueid ~= self.selfUniqueid  then
            self:Send(11710,{rid = id, platform = pf, zone_id = zone})
        else
            self:Notice(TI18N("不能对自己操作"))
        end
    end

    if QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.teacher) ~= nil then
        -- 如果身上有师徒任务的话，要提示踢人会删除任务
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("您当前正在进行师徒任务，若将有任务的徒弟踢出队伍，将<color='#ffff00'>删除师徒任务</color>，需重新领取。")
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = func
        NoticeManager.Instance:ConfirmTips(data)
    elseif self:CheckPunish(uniqueid) then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("对方才刚匹配进来，如果踢出队伍需要消耗{assets_1,90006,10}，是否确定？")
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = func
        NoticeManager.Instance:ConfirmTips(data)
    elseif PetLoveManager.Instance.cur_type == 2 then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("退队后将清空双方任务进度<color='#ffff00'>（奖励不能重复获得）</color>")
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = func
        NoticeManager.Instance:ConfirmTips(data)
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.GodsWar then
        GodsWarManager.Instance:TeamChange(11710, func)
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.Dungeon and selectedMember.status == RoleEumn.TeamStatus.Follow then
        -- 获取目前的event状态，若为副本中且要踢的队员处于在线状态则弹窗，由于队长不可能自踢，且踢暂离和离线队员无惩罚，所以弹窗仅针对状态为跟随的队员。
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("正在进行副本攻略，踢出玩家需要消耗{assets_1,90006,100}，是否确定？")
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = func
        NoticeManager.Instance:ConfirmTips(data)
    elseif CanYonManager.Instance:CanyonRunningStatus() then 
        CanYonManager.Instance:ChangeTeamStopCanyonRunning()
    else
        -- print("ggggggggggggggggggggggggggggg")
        -- print(RoleManager.Instance.RoleData.event)
        -- print(selectedMember.name)

        func()
    end
end

function TeamManager:On11710(dat)
    self:Notice(dat.msg)
end

--队伍招募
function TeamManager:Send11711(_type, lev)
    print(string.format("招募类型:%s,等级:%s", _type, lev))
    self.TypeData.type = _type
    self:Send(11711,{type = _type, lev_flag = lev})
end

function TeamManager:On11711(dat)
    self:Notice(dat.msg)
    if dat.result == 1 then
        self.matchStatus = TeamEumn.MatchStatus.Recruiting
        self.TypeData.status = self.matchStatus
        EventMgr.Instance:Fire(event_name.team_update_match)
        self:BeginCrossTime()
        if self:GetWorldMatchFlag() == 1 then
            TeamMatchManager.Instance:WorldShow(self.TypeData)
        end
    else
        self.TypeData.type = 0
    end
end

--大厅当前状态
function TeamManager:Send11712()
    self:Send(11712,{})
end

function TeamManager:On11712(dat)
    -- BaseUtils.dump(dat, "大厅当前状态")
    -- 把具体值更新到具体监听的地方
    EventMgr.Instance:Fire(event_name.team_hall_update, {role_num = dat.matching_roles, team_num = dat.matching_teams})
end


--尝试匹配
function TeamManager:Send11714(_types)
    --BaseUtils.dump(_types, "匹配类型")
    self:Send(11714,{types = _types})
end

function TeamManager:On11714(dat)
    self:Notice(dat.msg)
    if dat.result == 1 then
        self.matchStatus = TeamEumn.MatchStatus.Matching
        self.TypeData.status = self.matchStatus
        self.TypeData.type = dat.types[1]
        if dat.types[1] ~= nil then
            local td = DataTeam.data_match[dat.types[1].type]
            if td ~= nil then
                self.TypeOptions = {}
                self.TypeOptions[td.tab_id] = td.id
            end
        end
        self.TypeData.match_time = dat.mtime
        EventMgr.Instance:Fire(event_name.team_update_match)
        self:BeginCrossTime()
    end
end

--邀请列表
function TeamManager:Send11713()
    self:Send(11713,{})
end

function TeamManager:On11713(dat)
    -- BaseUtils.dump(dat, "邀请列表")
    self.requestsTab = {}
    for i,v in ipairs(dat.inviting) do
        local uniqueid = BaseUtils.get_unique_roleid(v.rid, v.zone_id, v.platform)
        self.requestsTab[uniqueid] = v
    end
    EventMgr.Instance:Fire(event_name.team_list_update)
end

--收到邀请
function TeamManager:On11715(dat)
    self.teamCrossType = dat.cross_type
    local typeName = ""
    local dt = DataTeam.data_match[dat.type]
    if dt ~= nil then
        typeName = dt.type_name
    end

    self:Notice(dat.msg)
    local uniqueid = BaseUtils.get_unique_roleid(dat.rid, dat.zone_id, dat.platform)
    self.requestsTab[uniqueid] = dat
    EventMgr.Instance:Fire(event_name.team_list_update)

    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal

    local extra = ""
    if dat.inviter_status ~= 1 and dat.inviter_status ~= 0 then
        extra = TI18N("(队员)")
    end

    local rid = dat.rid
    local pf = dat.platform
    local zone_id = dat.zone_id
    data.sureCallback = function() self:Send11703(rid, pf, zone_id, 1) end
    data.cancelCallback = function() self:Send11703(rid, pf, zone_id, 0) end
    data.cancelSecond = 30
    data.sureLabel = TI18N("接受")
    data.cancelLabel = TI18N("拒绝")

    -- 不同服处理
    local cross_desc = ""
    if RoleManager.Instance:CanConnectCenter() then
        if dat.cross_type ~= nil and dat.cross_type ~= RoleManager.Instance.RoleData.cross_type then
            if dat.cross_type == 1 then
                data.sureLabel = TI18N("跨服入队")
                cross_desc = TI18N("，是否<color='#ffff00'>跨服</color>入队？")
                RoleManager.Instance.jump_over_call = function() self:Send11703(rid, pf, zone_id, 1) end
                data.sureCallback = SceneManager.Instance.enterCenter
            else
                data.sureLabel = TI18N("返回原服")
                cross_desc = TI18N("，是否<color='#ffff00'>返回原服</color>入队？")
                RoleManager.Instance.jump_over_call = function() self:Send11703(rid, pf, zone_id, 1) end
                data.sureCallback = SceneManager.Instance.quitCenter
            end
        end
    end

    if typeName == "" then
        data.content = string.format(TI18N("<color='#01c0ff'>%sLv.%s%s</color>邀请你加入队伍%s"), dat.name, dat.lev, extra, cross_desc)
    else
        data.content = string.format(TI18N("<color='#01c0ff'>%sLv.%s%s</color>邀请你加入队伍,目标<color='#4dd52b'>[%s]</color>%s"), dat.name, dat.lev, extra, typeName, cross_desc)
    end

    NoticeManager.Instance:ConfirmTips(data)
end

--回应邀请
function TeamManager:Send11703(id, pf, zone, agree)
    local uniqueid = BaseUtils.get_unique_roleid(id, zone, pf)
    self.requestsTab[uniqueid] = nil
    self:Send(11703,{rid = id, platform = pf, zone_id = zone, type = agree})

    if agree == 1 then
        -- 同意邀请，进入队伍，邀请列表清空
        self.requestsTab = {}
    end
    EventMgr.Instance:Fire(event_name.team_list_update)
end

function TeamManager:On11703(dat)
    self:Notice(dat.msg)
end

--申请列表
function TeamManager:Send11716()
    self:Send(11716,{})
end

function TeamManager:On11716(dat)
    -- BaseUtils.dump(dat, "申请列表")
    self:Notice(dat.msg)
    self.applysTab = {}
    local count = 0
    for i,v in ipairs(dat.applys) do
        local uniqueid = BaseUtils.get_unique_roleid(v.rid, v.zone_id, v.platform)
        self.applysTab[uniqueid] = v
        count = count + 1
    end
    EventMgr.Instance:Fire(event_name.team_list_update)
end

--收到进队申请
function TeamManager:On11717(dat)
    self:Notice(dat.msg)
    local uniqueid = BaseUtils.get_unique_roleid(dat.rid, dat.zone_id, dat.platform)
    self.applysTab[uniqueid] = dat
    EventMgr.Instance:Fire(event_name.team_list_update)

    self:CheckApplyNumber()
end

--回应进队申请
function TeamManager:Send11718(id, pf, zone, agree)
    local uniqueid = BaseUtils.get_unique_roleid(id, zone, pf)
    self.applysTab[uniqueid] = nil
    self:Send(11718,{rid = id, platform = pf, zone_id = zone, type = agree})

    EventMgr.Instance:Fire(event_name.team_list_update)
end

-- 招募队伍列表
function TeamManager:Send11728()
    self:Send(11728, {type = 0})
end

function TeamManager:On11728(dat)
    -- BaseUtils.dump(dat, "招募队伍列表")
    EventMgr.Instance:Fire(event_name.team_match_list, dat.recruitment_list)
end


function TeamManager:On11718(dat)
    self:Notice(dat.msg)
end

--队伍取消招募
function TeamManager:Send11719()
    self:Send(11719,{})
end

function TeamManager:On11719(dat)
    self:Notice(dat.msg)
    -- BaseUtils.dump(dat, "取消招募")
    if dat.result == 1 then
        self.matchStatus = TeamEumn.MatchStatus.None
        self.TypeData.status = TeamEumn.MatchStatus.None
        EventMgr.Instance:Fire(event_name.team_update_match)
        self:StopCrossTime()
    end
end

--取消匹配
function TeamManager:Send11720()
    self:Send(11720,{})
end

function TeamManager:On11720(dat)
    self:Notice(dat.msg)
    if dat.result == 1 then
        self.matchStatus = TeamEumn.MatchStatus.None
        self.TypeData.status = TeamEumn.MatchStatus.None
        EventMgr.Instance:Fire(event_name.team_update_match)
        self:StopCrossTime()
    end
end

--收到队长招呼归队
function TeamManager:Send11721()
    self:Send(11721,{})
end

function TeamManager:On11721(dat)
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = TI18N("队长召还你归队，是否立即归队？")
    data.sureLabel = TI18N("接受")
    data.cancelLabel = TI18N("拒绝")
    data.sureCallback = self.sureBack
    NoticeManager.Instance:ConfirmTips(data)
end

--收到目标玩家组队状态， status, "状态：0队长，1跟随，2暂离，3离线, -1没队伍"
function TeamManager:Send11722(id, pf, zone)
    self:Send(11722,{rid = id, platform = pf, zone_id = zone })
end

function TeamManager:On11722(dat)
    -- BaseUtils.dump(dat, "收到目标玩家组队状态，")
    TipsManager.Instance.model.playerTips:SetTeamStatus(dat.status)
end

--查看聊天窗队伍招募信息
function TeamManager:Send11723()
    self:Send(11723,{})
end

function TeamManager:On11723(dat)
    -- BaseUtils.dump(dat, "11723")
    local needUpdate = false
    TeamMatchManager.Instance:ShowMatch(dat)

    for i,v in ipairs(dat.add) do
        local td = DataTeam.data_match[v.team_type]
        local typeName = TI18N("附近队伍")
        if td ~= nil then
            typeName = td.type_name
        end

        local level = string.format(TI18N("%s~%s级"), v.lev_min, v.lev_max)
        local str = string.format("<color='#13fc60'>%s</color><color='#00ffcc'>%s</color>", typeName, level)
        local member_max = 5
        local extraStr = ""
        local btnOffestY = 0

        local sex = nil
        local petBaseId = nil
        for _,arg in ipairs(v.args) do
            if arg.key == TeamEumn.MatchExtraType.PetBaseId then
                petBaseId = arg.value
            elseif arg.key == TeamEumn.MatchExtraType.Sex then
                sex = arg.value
            end
        end

        if v.team_type == 65 then
            -- 星座挑战
            local star = 0
            for i,extra in ipairs(v.args) do
                if extra.key == TeamEumn.MatchExtraType.Constellation then
                    star = extra.value
                end
            end
            typeName = string.format(TI18N("%s<color='#ffff00'>%s星</color>"), typeName, tostring(math.min(star + 1, 12)))
            str = string.format("<color='#13fc60'>%s</color><color='#00ffcc'>%s</color>", typeName, level)
        elseif v.team_type == 81 then
            -- 剧情任务
            extraStr = TI18N("\n<color='#ffff00'>每天帮杀<color='#00ff00'>5次</color>剧情可获人品礼盒</color>")
            -- btnOffestY = 22
        elseif v.team_type == 91 then
            -- 情缘任务
            member_max = 2
            local sexStr = ""
            if sex == 1 then
                sexStr = TI18N("来帅哥")
            else
                sexStr = TI18N("来妹子")
            end
            str = string.format("<color='#13fc60'>%s</color><color='#00ffcc'>%s</color>", typeName, sexStr)
        elseif v.team_type == 94 then
            -- 七夕任务
            member_max = 2
            local sexStr = ""
            if sex == 1 then
                sexStr = TI18N("来帅哥")
            else
                sexStr = TI18N("来妹子")
            end
            str = string.format("<color='#13fc60'>%s</color><color='#00ffcc'>%s</color>", typeName, sexStr)

        end

        local msgData = MsgData.New()
        msgData.sourceString = string.format("%s(%s/%s)%s", str, v.member_num, member_max, extraStr)
        msgData.showString = msgData.sourceString
        NoticeManager.Instance.model.calculator:ChangeFoneSize(17)
        local allWidth = NoticeManager.Instance.model.calculator:SimpleGetWidth(msgData.sourceString)
        msgData.allWidth = allWidth
        local chatData = ChatData.New()
        chatData.showType = MsgEumn.ChatShowType.Match
        chatData.msgData = msgData
        -- v.btnOffestY = btnOffestY
        v.btnOffestY = 0
        chatData.extraData = v
        chatData.extraData.member_max = member_max
        chatData.prefix = MsgEumn.ChatChannel.Team
        chatData.channel = MsgEumn.ChatChannel.Team
        self.chatShowMatchTab[v.id] = chatData

        ChatManager.Instance.model:ShowMsg(chatData)
    end

    for i,v in ipairs(dat.update) do
        local chatData = self.chatShowMatchTab[v.id]
        if chatData ~= nil then
            local td = DataTeam.data_match[v.team_type]
            local typeName = TI18N("附近队伍")
            if td ~= nil then
                typeName = td.type_name
            end

            local member_max = 5
            local sex = nil
            local petBaseId = nil
            for _,arg in ipairs(v.args) do
                if arg.key == TeamEumn.MatchExtraType.PetBaseId then
                    petBaseId = arg.value
                elseif arg.key == TeamEumn.MatchExtraType.Sex then
                    sex = arg.value
                end
            end

            local level = string.format(TI18N("%s~%s级"), v.lev_min, v.lev_max)
            local str = string.format("<color='#13fc60'>%s</color><color='#00ffcc'>%s</color>", typeName, level)
            local extraStr = ""
            local btnOffestY = 0

            if v.team_type == 65 then
                local star = 0
                for i,extra in ipairs(v.args) do
                    if extra.key == TeamEumn.MatchExtraType.Constellation then
                        star = extra.value
                    end
                end
                typeName = string.format(TI18N("%s<color='#ffff00'>%s星</color>"),typeName, tostring(math.min(star + 1, 12)))
                str = string.format("<color='#13fc60'>%s</color><color='#00ffcc'>%s</color>", typeName, level)
            elseif v.team_type == 81 then
                -- 剧情任务
                extraStr = TI18N("\n<color='#ffff00'>每天帮杀<color='#00ff00'>5次</color>剧情可获人品礼盒</color>")
                -- btnOffestY = 22
            elseif v.team_type == 91 then
                -- 情缘任务
                member_max = 2
                local sexStr = ""
                if sex == 1 then
                    sexStr = TI18N("来帅哥")
                else
                    sexStr = TI18N("来美女")
                end
                str = string.format("<color='#13fc60'>%s</color><color='#00ffcc'>%s</color>", typeName, sexStr)
            end

            chatData.msgData.sourceString = string.format("%s(%s/%s)%s", str, v.member_num, member_max, extraStr)
            chatData.msgData.showString = chatData.msgData.sourceString
            -- v.btnOffestY = btnOffestY
            v.btnOffestY = 0
            chatData.extraData = v
            chatData.extraData.member_max = member_max
            self.chatShowMatchTab[v.id] = chatData

            needUpdate = true
        end
    end

    for i,v in ipairs(dat.del) do
        self.chatShowMatchTab[v.id] = nil
        needUpdate = true
    end

    if needUpdate then
        ChatManager.Instance.model:UpdateMatchMsg()
    end
end

--直接加入队伍返回
function TeamManager:Send11724(id, pf, zone)
    self:Send(11724,{rid = id, platform = pf, zone_id = zone})
end

function TeamManager:On11724(dat)
    self:Notice(dat.msg)
end

-- 更新队伍信息
function TeamManager:On11725(dat)
    -- BaseUtils.dump(dat, "更新队伍信息")
    self.TypeData:Update(dat)
    self:DefaultSetting()
    EventMgr.Instance:Fire(event_name.team_info_update)
end

-- 新增/更新队员
function TeamManager:On11726(dat)
    -- BaseUtils.dump(dat, "新增/更新队员")
    local lastMyStatus = self:MyStatus()
    local lastCount = self:MemberCount()
    local updateList = {}
    for i,proto in ipairs(dat.members) do
        local uniqueid = BaseUtils.get_unique_roleid(proto.rid, proto.zone_id, proto.platform)
        local member = self.memberTab[uniqueid]
        if member == nil then
            member = TeamData.New()
        end
        member:Update(proto)
        member.uniqueid = uniqueid
        self.memberTab[uniqueid] = member
        table.insert(updateList, uniqueid)

        if uniqueid == self.selfUniqueid then
            -- 自己
            RoleManager.Instance.RoleData.team_status = member.status
        end
        if member.status == RoleEumn.TeamStatus.Leader then --队长
            self.captinId = member.uniqueid
            self.captinData = member
        end
    end

    local tempOrder = BaseUtils.copytab(self.memberOrderList)
    local needUpdateOrder = false
    self.memberOrderList = {}
    for i,order in ipairs(dat.order) do
        local uniqueid = BaseUtils.get_unique_roleid(order.rid, order.zone_id, order.platform)
        if self.memberTab[uniqueid] ~= nil then
            self.memberTab[uniqueid].number = i
        end
        table.insert(self.memberOrderList, uniqueid)
        local old = tempOrder[i]
        if old ~= uniqueid then
            -- 有不一样的,要更新
            needUpdateOrder = true
        end
    end

    tempOrder = nil

    self.teamNumber = #self.memberOrderList

    if self:MyStatus() == RoleEumn.TeamStatus.Leader then
        self:CheckApplyNumber()
        local nowCount = self:MemberCount()
        if lastCount ~= nowCount then
            self:CheckEnough3()
        end
    else
        self.matchStatus = TeamEumn.MatchStatus.None
    end

    if #updateList > 0 then
        EventMgr.Instance:Fire(event_name.team_update, updateList)
    end

    if needUpdateOrder then
        EventMgr.Instance:Fire(event_name.team_position_change)
    end

    if lastMyStatus == RoleEumn.TeamStatus.Away and self:MyStatus() == RoleEumn.TeamStatus.Follow then
        -- 归队成功后，如果队长在战斗中，请求观战
        if self.captinData ~= nil then
            local uniqueid = BaseUtils.get_unique_roleid(self.captinData.rid, self.captinData.zone_id, self.captinData.platform)
            local captinSceneData = SceneManager.Instance.sceneElementsModel:GetSceneData_OneRole(uniqueid)
            if captinSceneData ~= nil and captinSceneData.status == RoleEumn.Status.Fight then
                CombatManager.Instance:Send10705(self.captinData.rid, self.captinData.platform, self.captinData.zone_id)
            end
        end
    elseif (lastMyStatus == RoleEumn.TeamStatus.Leader and self:MyStatus() ~= RoleEumn.TeamStatus.Leader)
        or (lastMyStatus ~= RoleEumn.TeamStatus.Leader and self:MyStatus() == RoleEumn.TeamStatus.Leader) then
        EventMgr.Instance:Fire(event_name.team_update_match)
    end

    self:CheckGuideQuestTrace()

    -- debug信息，查清问题后删除 20180824
    local nowCount = self:MemberCount()
    if nowCount > 5 then
        local members_string = "现队伍成员"
        for key, member in pairs(self.memberTab) do
            members_string = string.format("%s, { uniqueid = %s, name = %s}", members_string, key, member.name)
        end

        members_string = string.format("%s,     11726协议发来的队伍成员", members_string)
        for i,proto in ipairs(dat.members) do
            members_string = string.format("%s, { uniqueid = %s_%s_%s, name = %s}", members_string, proto.platform, proto.zone_id, proto.rid, proto.name)
        end

        Debug.LogError("On11726 "..members_string)
    end
end

-- 删除队员
function TeamManager:On11727(dat)
    local updateList = {}
    for i,v in ipairs(dat.members) do
        local uniqueid = BaseUtils.get_unique_roleid(v.rid, v.zone_id, v.platform)
        self.memberTab[uniqueid] = nil
        table.insert(updateList, uniqueid)
    end
    self.memberOrderList = {}
    for i,order in ipairs(dat.order) do
        local uniqueid = BaseUtils.get_unique_roleid(order.rid, order.zone_id, order.platform)
        if self.memberTab[uniqueid] ~= nil then
            self.memberTab[uniqueid].number = i
        end
        table.insert(self.memberOrderList, uniqueid)
    end

    if self:MyStatus() == RoleEumn.TeamStatus.Leader and self.matchStatus ~= TeamEumn.MatchStatus.Recruiting and #self.memberOrderList < self.teamNumber then
        -- 不在招募中的才进行检查
        self:CheckNoticeLeader()
    end

    self.teamNumber = #self.memberOrderList

    if #updateList > 0 then
        EventMgr.Instance:Fire(event_name.team_update, updateList)
    end

    EventMgr.Instance:Fire(event_name.team_position_change)

    self:CheckGuideQuestTrace()
end

function TeamManager:On11729(dat)
    for i,v in ipairs(dat.members) do
        local uniqueid = BaseUtils.get_unique_roleid(v.rid, v.zone_id, v.platform)
        if self.memberTab[uniqueid] ~= nil then
            self.memberTab[uniqueid].combat_num = v.combat_num
        end
    end
end

-- 发起顶替队长
function TeamManager:Send11730()
    -- if RoleManager.Instance.RoleData.status == RoleEumn.Status.Fight then
    --     self.endFightChange = not self.endFightChange
    --     if self.endFightChange then
    --         NoticeManager.Instance:FloatTipsByString("将在战斗结束后发起顶替队长投票，点击<color='#ffff00'>取消顶替</color>可取消")
    --     end
    --     return
    -- end
    if CanYonManager.Instance:CanyonRunningStatus() then 
        CanYonManager.Instance:ChangeTeamStopCanyonRunning()
    else
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("是否发起投票顶替队长？ <color='#ffff00'>（投票持续约40秒）</color>")
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.blueSure = true
        data.sureCallback = function() self:Send(11730, {}) end
        NoticeManager.Instance:ConfirmTips(data)
    end
end

function TeamManager:On11730(dat)
    if dat.msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(dat.msg)
    end
end

-- 投票顶替队长
function TeamManager:Send11731(decision)
    self:Send(11731, {decision = decision})
end

function TeamManager:On11731(dat)
    if dat.result == 1 then
        -- 关掉提示
        NoticeManager.Instance:CloseConfrimTips()
    end
    if dat.msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(dat.msg)
    end
end

-- 收到投票邀请
function TeamManager:Send11732()
    self:Send(11730, {})
end

function TeamManager:On11732(dat)
    -- local uniqueid = BaseUtils.get_unique_roleid(dat.rid, dat.zone_id, dat.platform)
    local str = ""
    local time = 40
    if self:MyStatus() == RoleEumn.TeamStatus.Leader then
        str = string.format(TI18N("<color='#03B0EC'>%sLv.%s</color>想替代你成为队长,是否同意?"), dat.name, dat.lev)
    else
        str = string.format(TI18N("队员<color='#03B0EC'>%sLv.%s</color>想成为队长,是否同意?"), dat.name, dat.lev)
    end

    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = str
    data.sureLabel = TI18N("同意")
    data.cancelLabel = TI18N("拒绝")
    data.sureSecond = time
    data.blueSure = true
    data.sureCallback = self.sureChangeCaptin
    data.cancelCallback = self.refuseChangeCaption
    NoticeManager.Instance:ConfirmTips(data)
end

function TeamManager:On11733(dat)
    -- BaseUtils.dump(dat, "11733")
    if dat.del ~= nil then
        local del_mark = false
        for index, value in pairs(dat.del) do
            self.recruitDataList[value.id] = nil
            del_mark = true
        end
        if del_mark then self.OnUpdateRecruitDataList:Fire("del") end
    end

    if dat.add ~= nil then
        local add_mark = false
        for index, value in pairs(dat.add) do
            self.recruitDataList[value.id] = value
            add_mark = true
        end
        if add_mark then self.OnUpdateRecruitDataList:Fire("add") end
    end

    if dat.update ~= nil then
        local update_mark = false
        for index, value in pairs(dat.update) do
            self.recruitDataList[value.id] = value
            update_mark = true
        end
        if update_mark then self.OnUpdateRecruitDataList:Fire("update") end
    end
end

function TeamManager:Send11734(team_id)
    self:Send(11734, { team_id = team_id })
end

function TeamManager:On11734(dat)
    NoticeManager.Instance:FloatTipsByString(dat.msg)
end

function TeamManager:Send11735()
    self:Send(11735, { })
end

function TeamManager:On11735(dat)
    --BaseUtils.dump(dat,"<color='#ffff00'>队标数据数据数据数据</color>")
    self.model.team_mark = dat.team_mark
    AchievementManager.Instance.onUpdateBuyPanel:Fire()
end

function TeamManager:Send11736(rid,platform,zone_id)
    self:Send(11736, {rid = rid,platform = platform,zone_id = zone_id})
end

function TeamManager:On11736(dat)
    if GuildLeagueManager.Instance.model.teamsetwindow ~= nil then
        GuildLeagueManager.Instance.model.teamsetwindow:updateTeamInfo(dat)
        return
    end
    if GuildFightEliteManager.Instance ~= nil then
        GuildFightEliteManager.Instance.model:ShowTeamInfoPanel(dat)
    end
end

-- 是否直接加入跨服
function TeamManager:Send11737(type)
    self:Send(11737, {flag = type})
end

function TeamManager:On11737(dat)
    if self.IsCross ~= nil then
        if dat.flag == 1 then
            NoticeManager.Instance:FloatTipsByString(TI18N("已<color='#ffff00'>开启</color>自动跨服组队"))
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("已<color='#ffff00'>关闭</color>自动跨服组队"))
        end
    end
    self.IsCross = dat.flag
    EventMgr.Instance:Fire(event_name.team_cross_change)
end

-- 申请进队时，检查是否同服
function TeamManager:Send11738()
    self:Send(11738, {})
end

function TeamManager:On11738(dat)
    local rid = dat.rid
    local pf = dat.platform
    local zone_id = dat.zone_id
    local name = dat.name
    local lev = dat.lev
    local cross_type = dat.cross_type

    local desc = string.format(TI18N("<color='#01c0ff'>%sLV.%s</color>当前处于<color='#ffff00'>%s</color>，是否<color='#ffff00'>%s</color>后入队？"), name, lev, (cross_type == 0 and TI18N("原服") or TI18N("跨服区域")), (cross_type == 0 and TI18N("返回原服") or TI18N("跨服")))

    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = desc
    data.cancelLabel = TI18N("取消")
    RoleManager.Instance.jump_over_call = function() self:Send11702(rid, pf, zone_id) end
    if cross_type == 0 then
        data.sureLabel = TI18N("返回原服")
        data.sureCallback = SceneManager.Instance.quitCenter
    else
        data.sureLabel = TI18N("进入跨服")
        data.sureCallback = SceneManager.Instance.enterCenter
    end
    NoticeManager.Instance:ConfirmTips(data)
end

-- 请求，传送到队长身边（防错用）
function TeamManager:Send11739()
    self:Send(11739, {})
end

function TeamManager:On11739(dat)
    NoticeManager.Instance:FloatTipsByString(dat.msg)
end

-- 检查是否是人员变动，需要提示队长重新招募
function TeamManager:CheckNoticeLeader()
    local needNotice = false
    local callback = nil
    local sureSecond = -1
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.Event_fairyland then
        -- 幻境寻宝活动状态
        needNotice = true
        callback = self.fairylandCheckSure
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.None then
        -- 有悬赏任务在身上的都这样判断
        local questData = QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.offer)
        if questData ~= nil then
            needNotice = true
            callback = self.offerCheckSure
        end
    end

    if needNotice then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("你的队伍现在人数没满哦，再招募点队员吧？")
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureSecond = sureSecond
        data.sureCallback = callback
        NoticeManager.Instance:ConfirmTips(data)
    end
end

-- 退队检查是否提示
function TeamManager:CheckNoticeLeave()
    local needNotice = false
    local callback = nil
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.Event_fairyland then
        -- 幻境寻宝活动状态
        needNotice = true
        callback = self.fairylandCheckSure
    end

    if needNotice then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("活动需要组队参与，是否重新匹配?")
        data.sureLabel = TI18N("匹配")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = callback
        NoticeManager.Instance:ConfirmTips(data)
    end
end

function TeamManager:CheckApplyNumber()
    local count = 0
    for k,v in pairs(self.applysTab) do
        count = count + 1
    end
    MainUIManager.Instance.noticeView:set_teamnotice_num(count)
end

-- 判断是否满足惩罚条件
function TeamManager:CheckPunish(uniqueid)
    local member = self.memberTab[uniqueid]
    if member == nil then
        return false
    end

    if member.status == RoleEumn.TeamStatus.Leader then
        -- 自己是队长退队
        local t = BaseUtils.BASE_TIME - self.TypeData.last_join_time
        local c = self.TypeData.combat_num
        if c < 2 and t < 180 then
            return true
        end
    else
        if member.status == RoleEumn.TeamStatus.Follow and member.join_type == TeamEumn.EnterType.Match and member.join_sub_type == 51 then
            -- 自己是队长踢人
            -- 自己是队员退队
            local t = BaseUtils.BASE_TIME - member.join_time
            if member.combat_num < 2 and t < 180 then
                return true
            end
        end
    end
    return false
end

-- 检查是否满3，提示领取悬赏任务
-- 2016-12-13  修改为2人
function TeamManager:CheckEnough3()
    local questData = QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.offer)
    if questData == nil and self:MyStatus() == RoleEumn.TeamStatus.Leader and self.TypeData.type == 51 and self.TypeData.status == TeamEumn.MatchStatus.Recruiting and self:MemberCount() >= 2 then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("当前已经组够任务人数，快去领取悬赏任务吧！")
        data.sureSecond = 15
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function() QuestManager.Instance:Send10211(QuestEumn.TaskType.offer) end
        NoticeManager.Instance:ConfirmTips(data)
    end
end

-- 队伍里和自己 师徒关系成立的数量
function TeamManager:TeacherShipCount()
    local count = 0
    if self:MyStatus() == RoleEumn.TeamStatus.Leader then
        local myStatus = TeacherManager.Instance.model.myTeacherInfo.status
        if myStatus == TeacherEnum.Type.Teacher then
            for k,v in pairs(self.memberTab) do
                if TeacherManager.Instance.model:IsMyStudent({id = v.rid, platform = v.platform, zone_id = zone_id}) then
                    count = count + 1
                end
            end
        elseif myStatus == TeacherEnum.Type.Student then
            for k,v in pairs(self.memberTab) do
                if TeacherManager.Instance.model:IsMyTeacher({id = v.rid, platform = v.platform, zone_id = zone_id}) then
                    count = count + 1
                end
            end
        end
    end
    return count
end

function TeamManager:BeginCrossTime()
    self:StopCrossTime()

    if not RoleManager.Instance:CanConnectCenter() then
        return
    end

    if RoleManager.Instance.RoleData.cross_type == 1 then
        self.crossTime = LuaTimer.Add(30000, self.crossMatchTimeCall)
    else
        self.crossTime = LuaTimer.Add(30000, self.crossTimeEndCall)
    end
end

function TeamManager:StopCrossTime()
    if self.crossTime ~= nil then
        LuaTimer.Delete(self.crossTime)
        self.crossTime = nil
    end
end

-- 非跨服中，匹配超时提示
function TeamManager:ShowCrossTimeTips()
    self:StopCrossTime()

    if not RoleManager.Instance:CanConnectCenter() then
        return
    end

    if RoleManager.Instance.RoleData.cross_type == 1 then
        return
    end

    if self:MemberCount() >= 2 then
        return
    end

    if self:MyStatus() ~= RoleEumn.TeamStatus.Leader and self.IsCross == 1 then
        return
    end

    local ok = false
    RoleManager.Instance.jump_match_type = nil
    for first,second in pairs(self.TypeOptions) do
        if first == 5 or first == 7 or (first == 4 and second ~= 41 and second ~= 43 and second ~= 45 and second ~= 46) or first == 3 then
            -- 悬赏，天空，副本，上古通过
            RoleManager.Instance.jump_match_type = {first = first, second = second, status = self:MyStatus()}
            ok = true
        end
    end

    if not ok then
        return
    end

    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal

    if self:MyStatus() == RoleEumn.TeamStatus.Leader then
        data.content = TI18N("进入<color='#ffff00'>跨服练级</color>地图，将更容易招募队员")
        data.sureLabel = TI18N("前往跨服")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function()
            LuaTimer.Add(100,
                function()
                    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.team)
                    -- RoleManager.Instance:CheckEnterCenter()
                    self:Send11708()
                    SceneManager.Instance.enterCenter()
                end)
        end
    else
        data.content = TI18N("是否进入<color='#ffff00'>跨服练级</color>地图，将更容易匹配队员（建议勾选自动跨服组队）")
        data.cancelLabel = TI18N("自动跨服")
        data.sureLabel = TI18N("前往跨服")
        data.showClose = 1
        data.sureCallback = function()
            LuaTimer.Add(100,
                function()
                    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.team)
                    RoleManager.Instance:CheckEnterCenter()
                end)
        end
        data.cancelCallback = function() self:Send11737(1) end
    end
    NoticeManager.Instance:ConfirmTips(data)
end

-- 跨服中，匹配时间超时提示
function TeamManager:CrossMatchTimeEnd()
    self:StopCrossTime()

    if not RoleManager.Instance:CanConnectCenter() then
        return
    end

    if RoleManager.Instance.RoleData.cross_type == 0 then
        return
    end

    if self:MemberCount() >= 2 then
        return
    end

    if self:MyStatus() == RoleEumn.TeamStatus.Leader then
        return
    end

    local ok = false
    RoleManager.Instance.jump_match_type = nil
    for first,second in pairs(self.TypeOptions) do
        if first == 5 or first == 7 or first == 4 or first == 3 then
            -- 悬赏，天空，副本，上古通过
            ok = true
        end
    end

    if not ok then
        return
    end

    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = TI18N("当前队伍较少，<color='#ffff00'>创建队伍</color>可更快组队")
    data.cancelLabel = TI18N("取消")
    data.sureLabel = TI18N("创建队伍")
    data.cancelCallback = function()
        NoticeManager.Instance:CloseConfrimTips()
        self.needContuineMatch = false
        self.hasShowMatchNotice = false
    end
    data.sureCallback = function()
        self.hasShowMatchNotice = false
        LuaTimer.Add(100,
            function()
                self.needContuineMatch = true
                self:Send11701()
            end)
    end
    NoticeManager.Instance:ConfirmTips(data)
    self.hasShowMatchNotice = true
end

function TeamManager:GetWorldMatchFlag()
    self.worldMatchFlag = tonumber(PlayerPrefs.GetString("WorldMatchFlag")) or 0
    return self.worldMatchFlag
end

function TeamManager:SetWorldMatchFlag(val)
    self.worldMatchFlag = val
    PlayerPrefs.SetString("WorldMatchFlag", tostring(val))
end

-- 直接进入招募中队伍
function TeamManager:JoinRecruitTeam(rid, platform, zone_id)
    if not BaseUtils.IsTheSamePlatform(platform, zone_id) then
        SceneManager.Instance:Send10170(10001)
    end
    TeamManager.Instance:Send11724(rid, platform, zone_id)
end

-- 直接进入招募中队伍
function TeamManager:OrganizeATeam(rid, platform, zone_id)
    if not BaseUtils.IsTheSamePlatform(platform, zone_id) then
        SceneManager.Instance:Send10170(10001)
    end
    TeamManager.Instance:Send11702(rid, platform, zone_id)
end