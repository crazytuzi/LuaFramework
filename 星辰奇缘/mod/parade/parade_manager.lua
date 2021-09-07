ParadeManager = ParadeManager or BaseClass(BaseManager)

function ParadeManager:__init()
    if ParadeManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    ParadeManager.Instance = self
    self.status = 0
    self.selfstatus = 0
    self:InitHandler()
    self.queue = {}
    self.playerInfo = {}
    self.Timer = nil
    self.TalkTimer = nil

    self.remain_time = 0
    self.getexp = 0
    self.figure_score = 0
    self.figure = 0
    self.retry = 0

    self.onlyUpdate_time = false

    self.cdtimer = nil
end
--------status:0未开启，1开启中，2即将开启

function ParadeManager:__delete()
    self.model:DeleteMe()
end

function ParadeManager:InitHandler()
    self:AddNetHandler(13300, self.On13300)
    self:AddNetHandler(13301, self.On13301)
    self:AddNetHandler(13302, self.On13302)
    self:AddNetHandler(13303, self.On13303)
    self:AddNetHandler(13304, self.On13304)
    self:AddNetHandler(13305, self.On13305)
    self:AddNetHandler(13306, self.On13306)
    self:AddNetHandler(13307, self.On13307)
    self:AddNetHandler(13308, self.On13308)

    EventMgr.Instance:AddListener(event_name.self_loaded, function() self:CheckoutSelfStatus()end)
    EventMgr.Instance:AddListener(event_name.scene_load, function() self:StopTimer() self:Require13300()end)
    EventMgr.Instance:AddListener(event_name.role_level_change, function() self:Require13300()end)
    -- EventMgr.Instance:AddListener(event_name.logined, function() self:LoadDailyList()    self:LoadTimeLimit()    self:LoadCommingSoon() self:LoadDungeonList() end)
    -- EventMgr.Instance:AddListener(event_name.role_level_change, function() self:LoadDailyList()    self:LoadTimeLimit()    self:LoadCommingSoon() self:LoadDungeonList() end)

end

--活动状态
function ParadeManager:Require13300()
    Connection.Instance:send(13300,{})
end

function ParadeManager:On13300(data)
    AgendaManager.Instance:SetCurrLimitID(1008, data.status == 1)
    -- BaseUtils.dump(data, "On13300")
    local cfg_data = DataSystem.data_daily_icon[102]
    -- if RoleManager.Instance.RoleData.event == RoleEumn.Event.None then
    if data.status ~= 1 then
        self:StopTimer()
    end
    if data.status == 1 then
        self.remain_time = data.timeout
        -- if self.onlyUpdate_time == true then
        --     self.onlyUpdate_time = false
        --     return
        -- end
        if self.cdtimer == nil then
            self.cdtimer = LuaTimer.Add(0, 1000, function() self:CountDownTime() end)
        end
        if self.Timer == nil then
            LuaTimer.Add(100, function() self:SetAllNpc() self:Require13303() end)
        end
        self:CheckoutSelfStatus()
        if self.status ~= 1 and RoleManager.Instance.RoleData.event == RoleEumn.Event.None and RoleManager.Instance.RoleData.lev >= cfg_data.lev then --由未开启变成开启弹窗

            if ActivityManager.Instance:GetNoticeState(GlobalEumn.ActivityEumn.para) == false and not(RoleManager.Instance.RoleData.lev >= 70 and RoleManager.Instance.connect_type == 1)  then
                 if self.selfstatus ~= 1 then
                    local confirm = function()
                        ParadeManager.Instance:Require13301()
                    end
                    local data = NoticeConfirmData.New()
                    data.type = ConfirmData.Style.Normal
                    data.content = TI18N("是否参加吃货巡游?")
                    data.sureLabel = TI18N("确 定")
                    data.cancelLabel = TI18N("取 消")
                    data.sureCallback = confirm

                    if RoleManager.Instance.RoleData.cross_type == 1 then
                        -- 如果处在中央服，先回到本服在参加活动
                        RoleManager.Instance.jump_over_call = confirm
                        data.sureCallback = SceneManager.Instance.quitCenter
                        data.content = TI18N("是否<color='#ffff00'>返回原服</color>参加吃货巡游?")
                    end

                    NoticeManager.Instance:ActiveConfirmTips(data)
                else
                    print("你已经参加")
                end
                ActivityManager.Instance:MarkNoticeState(GlobalEumn.ActivityEumn.para)
            end
        end
    elseif data.status == 0 then
        if self.status == 1 and self.selfstatus == 1 then
            MainUIManager.Instance.mainuitracepanel:AutoShowType()
            self.selfstatus = 0
        end
        self:CheckoutSelfStatus()
        self:ReleaseAll()
    end
    self.status = data.status
    if self.status ~= 0 and self.status ~= 2  then
        --出现按钮
        local click_callback = function()
            if self.selfstatus ~= 1 then
                local confirm = function()
                    ParadeManager.Instance:Require13301()
                end
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = TI18N("是否参加吃货巡游?")
                data.sureLabel = TI18N("确 定")
                data.cancelLabel = TI18N("取 消")
                data.sureCallback = confirm

                if RoleManager.Instance.RoleData.cross_type == 1 then
                    -- 如果处在中央服，先回到本服在参加活动
                    RoleManager.Instance.jump_over_call = confirm
                    data.sureCallback = SceneManager.Instance.quitCenter
                    data.content = TI18N("是否<color='#ffff00'>返回原服</color>参加吃货巡游?")
                end

                NoticeManager.Instance:ConfirmTips(data)
            else
                print("你已经参加")
            end
        end

        local timeout_callback = function()

        end
        local timestamp = data.timeout

        MainUIManager.Instance:DelAtiveIcon(cfg_data.id)

        local iconData = AtiveIconData.New()
        iconData.id = cfg_data.id
        iconData.iconPath = cfg_data.res_name
        iconData.clickCallBack = click_callback
        iconData.sort = cfg_data.sort
        iconData.lev = cfg_data.lev
        if self.status == 1 then
            -- iconData.text = TI18N("已开启")
            iconData.timestamp = Time.time + data.timeout
            -- iconData.timestamp = timestamp
            MainUIManager.Instance:AddAtiveIcon(iconData)
        else
            iconData.timeoutCallBack = timeout_callback
            iconData.text = TI18N("准备中")
            MainUIManager.Instance:AddAtiveIcon(iconData)
        end
    else
        --关闭按钮
        MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
    end
end

--加入队列
function ParadeManager:Require13301()
    -- if TeamManager.Instance:HasTeam() then
    --     if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
    --         Connection.Instance:send(13301,{})
    --         LuaTimer.Add(1500, function() TeamManager.Instance:Send11708() end)
    --     else
    --         TeamManager.Instance:Send11708()
    --         LuaTimer.Add(1500, function() Connection.Instance:send(13301,{}) end)
    --     end
    -- else
        Connection.Instance:send(13301,{})
    -- end
end

function ParadeManager:On13301(data)
    -- BaseUtils.dump(data, "On13301")
    if data.flag == 1 then
        -- if TeamManager.Instance:HasTeam() then
        --     LuaTimer.Add(50, function() TeamManager.Instance:Send11708() end)
        -- end
        self.selfstatus = 1
        RoleManager.Instance.RoleData.Event = RoleEumn.Event.Parade
        SceneManager.Instance.sceneElementsModel:Set_isovercontroll(false)
        -- MainUIManager.Instance.mainuitracepanel.traceParade:Update()
        SceneManager.Instance.sceneElementsModel:Show_Self_Pet(false)
        MainUIManager.Instance.mainuitracepanel:ChangeShowType(TraceEumn.ShowType.Parade)
    else
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end

--离开队列
function ParadeManager:Require13302()
    Connection.Instance:send(13302,{})
end

function ParadeManager:On13302(data)
    -- BaseUtils.dump(data, "On13302")
    if data.flag == 1 then
        self.selfstatus = 0
        RoleManager.Instance.RoleData.Event = RoleEumn.Event.None
        SceneManager.Instance.sceneElementsModel:Set_isovercontroll(true)
        MainUIManager.Instance.mainuitracepanel:AutoShowType()
    end
end

--查看队列
function ParadeManager:Require13303()
    -- print("查看队列")
    Connection.Instance:send(13303,{})
end

function ParadeManager:On13303(data)
    -- BaseUtils.dump(data, "On13303")
    self:InitQueue(data)
end

--加入队列推送
function ParadeManager:Require13304()
    Connection.Instance:send(13304,{})
end

function ParadeManager:On13304(data)
    -- BaseUtils.dump(data, "On13304")
    LuaTimer.Add(300, function() self:InsertPlayer(data) end)

end

--退出队列推送
function ParadeManager:Require13305()
    Connection.Instance:send(13305,{})
end

function ParadeManager:On13305(data)
    -- BaseUtils.dump(data, "On13305")
    self:RemovePlayer(data)
end

-- 获取经验推送
function ParadeManager:Require13306()
    Connection.Instance:send(13306,{})
end

function ParadeManager:On13306(data)
    -- BaseUtils.dump(data, "On13306")
    self.getexp = data.exp
    self.figure_score = data.figure_score
    if MainUIManager.Instance.mainuitracepanel ~= nil and MainUIManager.Instance.mainuitracepanel.traceParade ~= nil then
        MainUIManager.Instance.mainuitracepanel.traceParade:Update()
    else
        LuaTimer.Add(1000, function()
            if MainUIManager.Instance.mainuitracepanel ~= nil and MainUIManager.Instance.mainuitracepanel.traceParade ~= nil then
                MainUIManager.Instance.mainuitracepanel.traceParade:Update()
            end
        end)
    end
end

--抢食物
function ParadeManager:Require13307(id, platform, zone_id)
    Connection.Instance:send(13307,{id = id ,platform = platform, zone_id = zone_id})
end

function ParadeManager:On13307(data)
    -- BaseUtils.dump(data, "On13307")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--参与者变化推送
function ParadeManager:Require13308()
    Connection.Instance:send(13308,{})
end

function ParadeManager:On13308(data)
    -- BaseUtils.dump(data, "On13308")
    self:OnStatusChange(data)
end


function ParadeManager:InitQueue(data)
    self.queue = {}
    local procession = data.parade_procession
    -- BaseUtils.dump(procession,"领导数据")
    for i,queue in ipairs(procession) do
        local LeaderObj = self:GetNpcObj(queue.uid, queue.battle_id)
        -- BaseUtils.dump(LeaderObj,"领头")
        if LeaderObj == nil then
            if self.retry < 20 then
                -- print("重试初始化队列")
                LuaTimer.Add(1000, function() self:InitQueue(data) end)
                    self.retry = self.retry + 1
            end
            return
        end
        self:InitLeader(LeaderObj, queue.uid, queue.unit_base_id)
        if self.queue[i] == nil then
            self.queue[i] = {}
        end
        table.insert( self.queue[i], {roleObj = LeaderObj, data = {uid = queue.uid, battle_id = queue.uid}})
        local num = 0
        for ii,v in ipairs(queue.participants) do
            num = num + 1
            v.uid = queue.uid
            LuaTimer.Add(ii*100, function() self:InsertPlayer(v) end)
            -- self:InsertPlayer(v)
            if RoleManager.Instance.RoleData.id == v.id and RoleManager.Instance.RoleData.zone_id == v.zone_id and RoleManager.Instance.RoleData.platform == v.platform then
                self.figure_score = v.figure_score
                self.figure = v.figure
                MainUIManager.Instance.mainuitracepanel.traceParade:Update()
            end
            if num > 15 then
                break
            end
        end
    end
    if self.Timer == nil then
        self.Timer = LuaTimer.Add(0,500,function()self:MoveUp() end)
    else
        -- LuaTimer.Delete(self.Timer)
        -- self.Timer = LuaTimer.Add(0,500,function() self:MoveUp() end)
    end
end

function ParadeManager:MoveUp()
    for i,queue in ipairs(self.queue) do
        local lastObj = nil
        for ii,obj in ipairs(queue) do
            if lastObj ~= nil then
                self:MovPlayer(obj,lastObj, queue[1].roleObj, i,ii)
                if obj.roleObj ~= nil and not BaseUtils.isnull(obj.roleObj) and not BaseUtils.isnull(obj.roleObj.gameObject) then
                    lastObj = obj
                else
                    -- BaseUtils.dump(obj,"有问题啊啊啊啊斯蒂芬斯蒂芬大师傅萨范德萨发生大范围的说法是d")
                end
            else
                -- if obj.roleObj ~= nil and not BaseUtils.isnull(obj.roleObj.gameObject)then
                    lastObj = obj
                -- else
                    -- BaseUtils.dump(obj,"222有问题啊啊啊啊斯蒂芬斯蒂芬大师傅萨范德萨发生大范围的说法是d")
                -- end
            end
        end
    end
end

function ParadeManager:MovPlayer(RoleObj, lastObj, leader, i, ii)
    if lastObj.roleObj ~= nil then
        if  lastObj.roleObj == nil or RoleObj.roleObj == nil or lastObj.roleObj.gameObject == nil or (RoleObj.roleObj.data.name == lastObj.roleObj.data.name) then
            -- print("上面空的")
            return
        end
        -- print(RoleObj.roleObj.data.name.."->跟随->"..tostring(lastObj.roleObj.data.name))
        if lastObj.roleObj ~= nil and RoleObj.roleObj ~= nil then
            if lastObj.roleObj.gameObject ~= nil and RoleObj.roleObj.gameObject ~= nil then
                local prePos = lastObj.roleObj.gameObject.transform.position
                local selfPos = RoleObj.roleObj.gameObject.transform.position
                local pos = prePos+(prePos-selfPos)*2
                local dis = Vector3.Distance(prePos, selfPos)
                local speed = math.min(dis/0.4*0.329, 2)
                if dis > 2 then
                    -- print("<color=#FF0000>距离太远进行跃迁</color>")
                    RoleObj.roleObj.gameObject.transform.position = prePos
                end
                RoleObj.roleObj.Speed = speed
                -- local pos = SceneManager.Instance.sceneModel:transport_small_pos(pos.x, pos.y)
                RoleObj.roleObj:MoveTo_NoPaths(pos.x, pos.y)
            else
                if lastObj.roleObj.gameObject == nil then
                    if lastObj.data.uid ~= nil then
                        local LeaderObj = self:GetNpcObj(lastObj.data.uid, lastObj.data.battle_id)
                        lastObj.roleObj = LeaderObj
                    else
                        local bData = self:BuildPlayerData(lastObj.data, leader)
                        local uniqueid = BaseUtils.get_unique_roleid(lastObj.data.id, lastObj.data.zone_id, lastObj.data.platform)
                        SceneManager.Instance.sceneElementsModel:CreateVirtual_Unit(uniqueid, bData, nil)
                        local roleObj = self:GetRoleObj(lastObj.data.id, lastObj.data.zone_id, lastObj.data.platform)
                        lastObj.roleObj = roleObj
                    end
                end
                if RoleObj.roleObj.gameObject == nil then
                    local bData = self:BuildPlayerData(RoleObj.data, leader)
                    local uniqueid = BaseUtils.get_unique_roleid(RoleObj.data.id, RoleObj.data.zone_id, RoleObj.data.platform)
                    SceneManager.Instance.sceneElementsModel:CreateVirtual_Unit(uniqueid, bData, nil)
                    local roleObj = self:GetRoleObj(RoleObj.data.id, RoleObj.data.zone_id, RoleObj.data.platform)
                    -- -- RoleObj.roleObj = roleObj
                    self.queue[i][ii] = {roleObj = roleObj, data = RoleObj.data}
                end
                return
            end
        else
            if lastObj.roleObj == nil then
                if lastObj.data.uid ~= nil then
                    local LeaderObj = self:GetNpcObj(lastObj.data.uid, lastObj.data.battle_id)
                    lastObj.roleObj = LeaderObj
                else
                    local bData = self:BuildPlayerData(lastObj.data, leader)
                    local uniqueid = BaseUtils.get_unique_roleid(lastObj.data.id, lastObj.data.zone_id, lastObj.data.platform)
                    SceneManager.Instance.sceneElementsModel:CreateVirtual_Unit(uniqueid, bData, nil)
                    local roleObj = self:GetRoleObj(lastObj.data.id, lastObj.data.zone_id, lastObj.data.platform)
                    lastObj.roleObj = roleObj

                end
            end
            if RoleObj.roleObj == nil then
                local bData = self:BuildPlayerData(RoleObj.data, leader)
                local uniqueid = BaseUtils.get_unique_roleid(RoleObj.data.id, RoleObj.data.zone_id, RoleObj.data.platform)
                SceneManager.Instance.sceneElementsModel:CreateVirtual_Unit(uniqueid, bData, nil)
                local roleObj = self:GetRoleObj(RoleObj.data.id, RoleObj.data.zone_id, RoleObj.data.platform)
                -- RoleObj.roleObj = roleObj
                -- print("再次创建")
                self.queue[i][ii] = {roleObj = roleObj, data = RoleObj.data}
            end
        end
    end
end

function ParadeManager:InsertPlayer(data)
    local insertData = data
    local uid = insertData.uid
    -- BaseUtils.dump(data, "7777777777777777777777777777777777777777777777")
    local teamKey = string.format("%s_%s_%s", insertData.platform, insertData.zone_id, insertData.id)
    local selfuid = BaseUtils.Key(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
    insertData.battle_id = nil
    insertData.uid = nil
    for i,queue in ipairs(self.queue) do
        if queue[1].roleObj.data.id == uid then
            if self.playerInfo[data.id] ~= nil then
                return
            end
            if #queue >= 15 and (RoleManager.Instance.RoleData.id ~= data.id or RoleManager.Instance.RoleData.platform ~= data.platform or RoleManager.Instance.RoleData.zone_id ~= data.zone_id) and not TeamManager.Instance:IsInMyTeam(teamKey) then
                return
            end
            self.playerInfo[data.id] = true
            local bData = self:BuildPlayerData(insertData,queue[1])
            local uniqueid = BaseUtils.get_unique_roleid(insertData.id, insertData.zone_id, insertData.platform)
            SceneManager.Instance.sceneElementsModel:CreateVirtual_Unit(uniqueid, bData, nil)
            local roleObj = self:GetRoleObj(insertData.id, insertData.zone_id, insertData.platform)
            local scale = self:GetScale(insertData.figure)
            if roleObj ~= nil then
                -- print("改变样子")
                roleObj:SetScale(scale)
                roleObj.data = bData
                roleObj:ChangeLook()
            else
                print("单位还没创建")
            end
            -- local uniqueid = BaseUtils.get_unique_roleid(v.id, v.zone_id, v.platform)
            -- local data = self:BuildPlayerData(v,LeaderObj)
            -- SceneManager.Instance.sceneElementsModel:CreateVirtual_Unit(uniqueid, data, nil)
            -- local roleObj = self:GetRoleObj(v.id, v.zone_id, v.platform)
            -- roleObj.data = data
            -- roleObj:ChangeLook()
            -- table.insert( self.queue[i], roleObj)

            if data.has_food == 1 then
                if self.selfstatus == 1 then
                    self:ShowClickBubble(data.id, data.zone_id, data.platform)
                end
            end
            -- if #queue> 5 then
            --     roleObj.gameObject = nil
            -- end
            table.insert( self.queue[i], {roleObj = roleObj, data = data})
        else
            print("nonono")
        end
    end
end

function ParadeManager:RemovePlayer(data)
    self.playerInfo[data.id] = nil
    local temp = self.queue
    local queueindex = nil
    local targetindex = nil
    local RMobj = nil
    for i,queue in ipairs(temp) do
        queueindex = i
        for ii,obj in ipairs(queue) do
            if data.id == obj.data.rid and data.zone_id == obj.data.zone_id and data.platform == obj.data.platform then
                targetindex = ii
                local uniqueid = BaseUtils.get_unique_roleid(data.id, data.zone_id, data.platform)
                local obj = self:GetRoleObj(data.id, data.zone_id, data.platform)
                RMobj = obj
            end
        end
    end
    if targetindex ~= nil then
        table.remove( self.queue[queueindex], targetindex)
    end
    if RMobj ~= nil then
        RMobj.data.looks = {}
        if RMobj.data.oldLooks ~= nil then
            RMobj.data.looks = RMobj.data.oldLooks
        end
        BaseUtils.dump(RMobj.data.looks)
        RMobj:SetScale(1)
        RMobj.Speed = 240*SceneManager.Instance.sceneModel.mapsizeconvertvalue
        RMobj:ChangeLook()
        RMobj:StopMoveTo()
    else

    end
    if SceneManager.Instance.sceneElementsModel.self_view ~= nil and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.Parade then
        SceneManager.Instance.sceneElementsModel.self_view:SetScale(1)
    end
    local uniqueid = BaseUtils.get_unique_roleid(data.id, data.zone_id, data.platform)
    if (RoleManager.Instance.RoleData.id ~= data.id or RoleManager.Instance.RoleData.platform ~= data.platform or RoleManager.Instance.RoleData.zone_id ~= data.zone_id) then
        SceneManager.Instance.sceneElementsModel:RemoveVirtual_Unit(uniqueid)
    end
    SceneManager.Instance.sceneElementsModel.VirtualUnitData_List[SceneManager.Instance.sceneElementsModel.self_unique] = nil
end

function ParadeManager:InitLeader(LeaderObj, uid, unit_base_id)
    -- self.TalkTimer
    -- self:StopTimer()

    local key = tostring(SceneManager.Instance:CurrentMapId()).."_"..tostring(unit_base_id)
    local talkdata = DataParade.data_talk[key]
    local pathdata = DataParade.data_path[key].path
    local nextPos = pathdata[1]
    local pos = SceneManager.Instance.sceneModel:transport_small_pos(nextPos[1], nextPos[2])
    LeaderObj.moveEnd_CallBack = function() self:LeaderMovNext(LeaderObj, pathdata, 2) end
    LeaderObj:MoveTo_NoPaths(pos.x, pos.y)
    self:LeaderTalkNext(LeaderObj, talkdata, 2)
end

function ParadeManager:LeaderTalkNext(LeaderObj, Talkdata, index)
    if LeaderObj ~= nil then
        local time = Random.Range(Talkdata.min, Talkdata.max)
        local rindex = (index-1)%#Talkdata.words+1
        local _msg = Talkdata.words[rindex].key
        SceneTalk.Instance:ShowTalk_NPC(LeaderObj.data.id, LeaderObj.data.battleid, _msg, 5)  --暂时屏蔽说话
        LuaTimer.Add(time*1000, function() self:LeaderTalkNext(LeaderObj, Talkdata, index+1) end)
    end
end

function ParadeManager:LeaderMovNext(LeaderObj ,PathData, index)
    -- print("胖子走前头")
    if LeaderObj ~= nil then
        local nextPos = PathData[(index-1)%#PathData +1]
        local pos = SceneManager.Instance.sceneModel:transport_small_pos(nextPos[1], nextPos[2])
        LeaderObj.moveEnd_CallBack = function() self:LeaderMovNext(LeaderObj, PathData, index+1) end
        LeaderObj:MoveTo_NoPaths(pos.x, pos.y)
    end
end
--将所有游戏NPC设置为不隐藏
function ParadeManager:SetAllNpc()
    local units = SceneManager.Instance.sceneElementsModel:GetSceneData_Npc()
    for i,v in ipairs(units) do
        if v.battleid == 5 then
            local key = BaseUtils.get_unique_npcid(v.id, v.battleid)
            local npcdata = SceneManager.Instance.sceneElementsModel:GetSceneData_OneNpc(key)
            if npcdata ~= nil then
                npcdata.no_hide = true
                npcdata.exclude_outofview = true
                npcdata.no_facetopoint = true
                SceneManager.Instance.sceneElementsModel:CreateNpc(key,npcdata,nil)
            end
        end
    end
    -- SceneManager.Instance.sceneElementsModel:CreateSceneUnits()
end

function ParadeManager:GetNpcObj(id, battleid)
    local key = BaseUtils.get_unique_npcid(id, battleid)
    return SceneManager.Instance.sceneElementsModel.NpcView_List[key]
end

function ParadeManager:GetRoleObj(roleid, zoneid, platform)
    local key = BaseUtils.get_unique_roleid(roleid, zoneid, platform)
    return SceneManager.Instance.sceneElementsModel.RoleView_List[key]
end

function ParadeManager:StopTimer()
    -- print("<color='#FF0000'>停止</color>")
    self.playerInfo = {}
    if self.Timer ~= nil then
        LuaTimer.Delete(self.Timer)
        self.Timer = nil
    end
    if self.TalkTimer ~= nil then
        LuaTimer.Delete(self.TalkTimer)
        self.TalkTimer = nil
    end
end

function ParadeManager:BuildPlayerData(data,LeaderObj)
    --BaseUtils.dump(data,"BuildPlayerData")
    local rold_data = RoleData.New()
    local roleview = self:GetRoleObj(data.id, data.zone_id, data.platform)
    if roleview ~= nil then
        rold_data = roleview.data
    end

    local ndata = data
    if data.looks == nil then
        data.looks = {}
    end
    data.oldLooks = data.looks
    data.looks = {
     [1] = {
            looks_str = "",
            looks_type = SceneConstData.looktype_transform,
            looks_val = 30701,
            looks_mode = 0,
        },
    }
    data.x = LeaderObj.data.x
    data.y = LeaderObj.data.y
    data.unittype = SceneConstData.unittype_role
    data.speed = LeaderObj.data.speed
    data.guild_zone = data.g_zone_id
    data.guild_id = g_id
    data.guild_platform = g_platform
    data.event = RoleEumn.Event.Parade
    data.rid = data.id
    data.ride = SceneConstData.unitstate_walk
    rold_data:update_data(ndata)
    return rold_data
end

function ParadeManager:GetScale(figure)
    return 0.7+figure*0.15
end

function ParadeManager:OnStatusChange(data)
    local roleObj = self:GetRoleObj(data.id, data.zone_id, data.platform)
    if roleObj ~= nil then
        local scale = self:GetScale(data.figure)
        roleObj:SetScale(scale)
        if data.has_food == 1 then
            if self.selfstatus == 1 then
                self:ShowClickBubble(data.id, data.zone_id, data.platform)
            end
        else
            SceneTalk.Instance:HideBtn_Player(data.id, data.zone_id, data.platform)
        end
    end
    if RoleManager.Instance.RoleData.id == data.id and RoleManager.Instance.RoleData.zone_id == data.zone_id and RoleManager.Instance.RoleData.platform == data.platform then
        self.figure_score = data.figure_score
        self.figure = data.figure
        MainUIManager.Instance.mainuitracepanel.traceParade:Update()
    end
end
function ParadeManager:ShowClickBubble(id, zone_id, platform)
    local callback = function()
        self:Require13307(id,platform,zone_id)
    end
    SceneTalk.Instance:ShowBtn_Player(id, zone_id, platform, callback, 60)
end

function ParadeManager:ReleaseAll()
    -- print("释放所有")
    self.playerInfo = {}
    self:StopTimer()
    local temp = BaseUtils.copytab(self.queue)
    for i,queue in ipairs(temp) do
        local lastObj = nil
        for ii,obj in ipairs(queue) do
            if obj ~= nil and obj.roleObj ~= nil and ii>1 then
                self:RemovePlayer(obj.data)
                -- obj.roleObj.data.looks = {}
                -- obj.roleObj.Speed = 240*SceneManager.Instance.sceneModel.mapsizeconvertvalue
                -- obj.roleObj:ChangeLook()
                -- obj.roleObj:StopMoveTo()
            else
                -- BaseUtils.dump(obj,"看看")
                -- print("<color='#FF0000'>找补刀玩家！！</color>")
            end
        end
    end
    self.queue = {}
end

function ParadeManager:CheckoutSelfStatus()
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.Parade then
        -- if TeamManager.Instance:HasTeam() then
        --     LuaTimer.Add(50, function() TeamManager.Instance:Send11708() end)
        -- end
        self.selfstatus = 1
        RoleManager.Instance.RoleData.Event = RoleEumn.Event.Parade
        SceneManager.Instance.sceneElementsModel:Set_isovercontroll(false)
        MainUIManager.Instance.mainuitracepanel:ChangeShowType(TraceEumn.ShowType.Parade)
    elseif RoleManager.Instance.RoleData.event ~= RoleEumn.Event.Marry_cere and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.Marry_guest_cere then
        self.selfstatus = 0
        RoleManager.Instance.RoleData.Event = RoleEumn.Event.None
        SceneManager.Instance.sceneElementsModel:Set_isovercontroll(true)
        -- if not HomeManager.Instance:IsAtHome() then
        --     SceneManager.Instance.sceneElementsModel:Show_Self_Pet(true)
        --     SceneManager.Instance.sceneElementsModel:Show_Role_Wing(true)
        -- end
        -- SceneManager.Instance.sceneElementsModel:Set_isovercontroll(true)
    end
end

function ParadeManager:ClearAll()
    self:ReleaseAll()
    -- LuaTimer.Add(800, function() self:Require13300() end)
end

function ParadeManager:CountDownTime()
    if self.lastTime ~= nil then
        self.remain_time = self.remain_time - (Time.time - self.lastTime)
        self.lastTime = Time.time
    else
        self.lastTime = Time.time
    end
    if self.remain_time <= 0 then
        self.remain_time = 0
        LuaTimer.Delete(self.cdtimer)
        self.cdtimer = nil
        self.lastTime = nil
    end
end

function ParadeManager:EatCheckIn()
    if RoleManager.Instance.RoleData.lev >= 30 then
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.sureSecond = -1
        confirmData.cancelSecond = 180
        confirmData.sureLabel = TI18N("确认")
        confirmData.cancelLabel = TI18N("取消")
        confirmData.content = TI18N("是否参加吃货巡游?")
        confirmData.sureCallback = function() ParadeManager.Instance:Require13301() end

        if RoleManager.Instance.RoleData.cross_type == 1 then
            -- 如果处在中央服，先回到本服在参加活动
            RoleManager.Instance.jump_over_call = function() ParadeManager.Instance:Require13301() end
            confirmData.sureCallback = SceneManager.Instance.quitCenter
            confirmData.content = TI18N("是否<color='#ffff00'>返回原服</color>参加吃货巡游?")
        end

        NoticeManager.Instance:ConfirmTips(confirmData)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("30级方可参加巡游"))
    end
end