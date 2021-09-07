-- 峡谷之巅-manager（冠军联赛改）
-- @author hze
-- @date 2018/07/20

CanYonManager  = CanYonManager or BaseClass(BaseManager)

function CanYonManager:__init()
    if CanYonManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    CanYonManager.Instance = self

    self.activity_time = 0             --结束时间戳
    self.cannonCd = 0                  --大炮cd
    self.is_win = 0                    --胜利状态(0未出结果/1胜利/2失败)
    
    self.self_side = nil               --阵营（1联盟/2部落）    
    self.group_id = nil                --分组Id
    self.match_id = nil                --战场Id
    
    self.self_remain_num = 0           --己方剩余人数
    self.self_member_num = 0           --己方参与人数
    self.collectstatus = {}            --所有队伍操作单位的状态
    
    self.loading = false               --处理动态遮挡区域中
    self.fightinfolist = {}            --对阵信息
    
    self.memberFigthInfo = {}          --成员战绩信息
    self.teamFigthInfo = {}            --队伍战绩信息
    
    self.currData = nil                --当前个人行动力信息
    self.towerData = nil               --当前水晶塔状态

    self.activity_time_ready = 0 


    self.delayTimeSure = {300,120,30}

    self.model = CanYonModel.New()

    self.CanYonUpdateStatus = EventLib.New()           -- 活动状态变更
    self.CanYonUpdateGroupName = EventLib.New()        -- 组名更新
    self.CanYonFightInfoUpdate = EventLib.New()        -- 对战信息更新
    self.CanYonMovabilityChange = EventLib.New()       -- 行动力更新
    self.CanYonTowerChange = EventLib.New()            -- 战场塔血量更新
    self.CanYonMemberFightInfoChange = EventLib.New()  -- 成员战绩更新
    self.CanYonTeamFightInfoChange = EventLib.New()    -- 队伍战绩更新

    -- self.guessDataUpdate = EventLib.New()           -- 竞猜数据更新
    -- self.liveDataRefresh = EventLib.New()           -- 直播数据更新

    self.collection = CanYonCollectPanel.New()

    self.soundcfg = {
        ready = 566,
        start = 567,
        cannon = 568,
        selfbroken = 569,
        otherbroken = 570,
        win = 571,
        fire = 666,
        hit = 667
    }

    self.CannonPosition = Vector2(7.49, 11.57)
    self:InitHandler()
    self:InitArenaInfo()
end

function CanYonManager:InitHandler()
    self:AddNetHandler(21100, self.On21100)
    self:AddNetHandler(21101, self.On21101)
    self:AddNetHandler(21102, self.On21102)
    self:AddNetHandler(21103, self.On21103)
    self:AddNetHandler(21104, self.On21104)
    self:AddNetHandler(21105, self.On21105)
    self:AddNetHandler(21106, self.On21106)
    self:AddNetHandler(21107, self.On21107)
    self:AddNetHandler(21108, self.On21108)
    self:AddNetHandler(21109, self.On21109)
    self:AddNetHandler(21110, self.On21110)
    self:AddNetHandler(21111, self.On21111)
    self:AddNetHandler(21112, self.On21112)
    self:AddNetHandler(21113, self.On21113)
    self:AddNetHandler(21114, self.On21114)
    self:AddNetHandler(21115, self.On21115)
    -- self:AddNetHandler(21116, self.On21116)
    self:AddNetHandler(21117, self.On21117)
    self:AddNetHandler(21118, self.On21118)
    -- self:AddNetHandler(21119, self.On21119)
    -- self:AddNetHandler(21120, self.On21120)
    self:AddNetHandler(21121, self.On21121)
    self:AddNetHandler(21122, self.On21122)
   

    EventMgr.Instance:AddListener(event_name.scene_load, function() self:BarrierArea() end)
    -- EventMgr.Instance:AddListener(event_name.mainui_loaded, function() self:SceneEnter() end)
    EventMgr.Instance:AddListener(event_name.role_event_change, function(event, old_event) self:SceneEnter(event, old_event) end)
    EventMgr.Instance:AddListener(event_name.role_level_change, function() self:UpdateIcon() end)
  
    EventMgr.Instance:AddListener(event_name.begin_fight, function()
        if self.collection.running then
            self.collection:Cancel()
        end
    end)

end

function CanYonManager:RequestInitData()
    self:Send21100()

    self:InitData()
end

function CanYonManager:InitData()
    self.activity_time = 0  
    self.activity_time_ready = 0  
    self.cannonCd = 0          
    self.is_win = 0

    self.fightinfolist = {} 

    self.group_id = nil
    self.self_side = nil
    self.self_remain_num = 0
    self.self_member_num = 0
    self.collectstatus = {}   

    self.currData = nil 
    self.towerData = nil 

    if RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYonReady then
        self:Send21121()
    end

    if RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYon then 
        if MainUIManager.Instance.MainUIIconView ~= nil then
            MainUIManager.Instance.MainUIIconView:Set_ShowTop(false, {17})
        end
        self:Send21114()
        if CanYonManager.Instance.currstatus == CanYonEumn.Status.Playing then 
            self:Send21122()
        end
    end
end

function CanYonManager:Send21100()
    Connection.Instance:send(21100,{})
end

--活动状态
function CanYonManager:On21100(data)
    -- BaseUtils.dump(data, "<color='#00ff00'>On21100</color>")
    self.old_status = self.currstatus
    self.currstatus = data.status
    self.activity_time = data.timeout

    if CanYonEumn.Status.Reading then 
        self.activity_time_ready = data.timeout + 10
    end

    self.CanYonUpdateStatus:Fire()

    self:UpdateIcon()
end

--进准备区
function CanYonManager:Send21101()
    Connection.Instance:send(21101,{})
end


function CanYonManager:On21101(data)
    -- BaseUtils.dump(data, "<color='#00ff00'>On21101</color>")
end

--退出准备区
function CanYonManager:Send21102()
    --只有准备阶段才可退出，其余阶段操作禁止退队退场
    if self.currstatus == CanYonEumn.Status.Reading then 
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("峡谷之巅<color='#ffff00'>准备阶段</color>，退出可<color='#ffff00'>再次入场</color>\n（正式开始后将<color='#ffff00'>不可入场</color>，记得看好时间哦{face_1,3}）")
        data.sureLabel = TI18N("确认退出")
        data.cancelLabel = TI18N("取消")
        data.cancelSecond = 60
        data.sureCallback = function()
            if TeamManager.Instance:HasTeam() then
                TeamManager.Instance:Send11708()
            end
            Connection.Instance:send(21102,{})
        end
        NoticeManager.Instance:ConfirmTips(data)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("战场已开启，暂时不能退出，请等待进入战场吧！{face_1,3}"))
    end
end


function CanYonManager:On21102(data)
    -- BaseUtils.dump(data, "<color='#00ff00'>On21102</color>")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--退出战场
function CanYonManager:Send21103()
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = TI18N("正式比赛已经开始，提前<color='#ffff00'>退出</color>将<color='#ffff00'>不能再次入场</color>")
    data.sureLabel = TI18N("退出")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function()
        if TeamManager.Instance:HasTeam() then
            TeamManager.Instance:Send11708()
        end
        Connection.Instance:send(21103,{})
    end
    NoticeManager.Instance:ConfirmTips(data)
end


function CanYonManager:On21103(data)
    -- BaseUtils.dump(data, "<color='#00ff00'>On21103</color>")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--发起战斗
function CanYonManager:Send21104(id,platform,zone_id)
    Connection.Instance:send(21104,{id = id, platform = platform, zone_id = zone_id})
end


function CanYonManager:On21104(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


--查看个人信息
function CanYonManager:Send21105()
    Connection.Instance:send(21105,{})
end


function CanYonManager:On21105(data)
    -- BaseUtils.dump(data, string.format("On21105, 当前自己的数据--%s",RoleManager.Instance.RoleData.name))
    self.currData = data
    self.self_side = data.side
    self:Do05and06Data()
    self.CanYonMovabilityChange:Fire()
end

--查看对阵信息
function CanYonManager:Send21106()
    Connection.Instance:send(21106,{})
end

function CanYonManager:On21106(data)
    -- BaseUtils.dump(data, "<color='#00ff00'>On21106</color>")
    self.fightinfolist = data.canyon_summit_side

    self:Do05and06Data()
    self.CanYonFightInfoUpdate:Fire()

    --分胜负打开结算面板
    if self.is_win ~= 0 then 
        self.model:OpenResultpanel()
    end
end

function CanYonManager:Do05and06Data()
    if self.self_side == nil or next(self.fightinfolist) == nil then return end
    for _,v in pairs(self.fightinfolist) do
        if self.self_side == v.side_id then
            self.self_remain_num = v.remain_num
            self.self_member_num = v.member_num
            self.is_win = v.is_win
            self.group_id = v.group_id
            self.match_id = v.match_id
        end
    end
end

--成员战绩信息
function CanYonManager:Send21107()
    Connection.Instance:send(21107,{})
end


function CanYonManager:On21107(data)
    -- BaseUtils.dump(data, "<color='#00ff00'>On21107</color>")
    self.memberFigthInfo = data.canyon_summit_role
    self.CanYonMemberFightInfoChange:Fire()
end


-- 队伍成员信息
function CanYonManager:Send21108()
    Connection.Instance:send(21108,{})
end


function CanYonManager:On21108(data)
    -- BaseUtils.dump(data, "<color='#00ff00'>On21108</color>")
    self.teamFigthInfo = data.canyon_summit_role
    self.CanYonTeamFightInfoChange:Fire()
end

--活动退出推送
function CanYonManager:Send21109(id, platform, zone_id)
    Connection.Instance:send(21109,{id = id, platform = platform, zone_id = zone_id})
end


function CanYonManager:On21109(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--攻塔或使用大炮
function CanYonManager:Send21110(battle_id, id)
    local real_battle_id = 0
    for k,v in pairs(SceneManager.Instance.sceneElementsModel.NpcView_List) do
        if v.data.unittype == 1 and v.data.id == id then
            real_battle_id = v.data.battleid
        end
    end
    if real_battle_id == nil then
        real_battle_id = battle_id
    end
    Connection.Instance:send(21110,{battle_id = real_battle_id, id = id})
end


function CanYonManager:On21110(data)
    -- BaseUtils.dump(data, "On21110,攻塔或使用大炮")
    if data.flag == 1 then
        self.collection.callback = function()
            self.collection.cancelCallBack = nil
            self:Send21112()
        end
        self.collection.cancelCallBack = function()
            self:Send21113()
        end
        if data.id == 7 then
            self.collection:Show({msg = "操作大炮中...", time = 20000, optype = 1})
        else
            self.collection:Show({msg = "攻塔中...", time = 20000, optype = 2})
        end
        if self.model.fightinfopanel ~= nil then
            self.model.fightinfopanel:HideIcon()
        end
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--守塔或打断大炮
function CanYonManager:Send21111(battle_id, id)
    local real_battle_id = 0
    for k,v in pairs(SceneManager.Instance.sceneElementsModel.NpcView_List) do
        if v.data.unittype == 1 and v.data.id == id then
            real_battle_id = v.data.battleid
        end
    end
    if real_battle_id == nil then
        real_battle_id = battle_id
    end
    Connection.Instance:send(21111,{battle_id = real_battle_id, id = id})
end

function CanYonManager:On21111(data)
    -- BaseUtils.dump(data, "On21111,守塔或打断大炮")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        self.collection.callback = function()
            self.collection.cancelCallBack = nil
        end
        self.collection.cancelCallBack = function()
            self:Send21113()
        end
        self.collection:Show({msg = "守塔中...", time = 6000000, optype = 3})
    end
    if self.model.fightinfopanel ~= nil then
        self.model.fightinfopanel:HideIcon()
    end
end

--完成攻塔或使用大炮
function CanYonManager:Send21112()
    -- print("Send21112")
    Connection.Instance:send(21112,{})
end

function CanYonManager:On21112(data)
    -- BaseUtils.dump(data, "On21112, 开炮结算")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        self.model:FinishMotion(data.id)
        if data.id ~= 7 then
            local Confirmdata = NoticeConfirmData.New()
            Confirmdata.type = ConfirmData.Style.Sure
            if data.id == 1 or data.id == 4 then
                Confirmdata.content = TI18N("我队对敌方<color='#01c0ff'>1号水晶塔</color>造成了一定伤害{face_1,18}\n<color='#ffff00'>（队伍人数越多，造成伤害越大）</color>")
            elseif data.id == 2 or data.id == 5 then
                Confirmdata.content = TI18N("我队对敌方<color='#01c0ff'>2号水晶塔</color>造成了一定伤害{face_1,18}\n<color='#ffff00'>（队伍人数越多，造成伤害越大）</color>")
            elseif data.id == 3 or data.id == 6 then
                Confirmdata.content = TI18N("我队对敌方<color='#01c0ff'>3号水晶塔</color>造成了一定伤害{face_1,18}\n<color='#ffff00'>（队伍人数越多，造成伤害越大）</color>")
            else
                Confirmdata.content = TI18N("我队对敌方<color='#01c0ff'>水晶塔</color>造成了一定伤害{face_1,18}\n<color='#ffff00'>（队伍人数越多，造成伤害越大）</color>")
            end
            Confirmdata.sureLabel = TI18N("确定")
            Confirmdata.sureSecond = 5
            NoticeManager.Instance:ConfirmTips(Confirmdata)
        end
    end
    self.collection:Cancel()
end

--中断单位操作
function CanYonManager:Send21113()
    Connection.Instance:send(21113,{})
end

function CanYonManager:On21113(data)
    -- BaseUtils.dump(data, "On21113, 中断操作")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--获取双方水晶塔的状态
function CanYonManager:Send21114()
    Connection.Instance:send(21114,{})
end


function CanYonManager:On21114(data)
    -- BaseUtils.dump(data, string.format("On21114, 水晶塔状态--%s",RoleManager.Instance.RoleData.name))
    self.towerData = data.canyon_summit_unit
    self.CanYonTowerChange:Fire()
end

--手动进场
function CanYonManager:Send21115()
    Connection.Instance:send(21115,{})
end


function CanYonManager:On21115(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--大炮打中的单位
function CanYonManager:On21117(data)
    -- BaseUtils.dump(data, "On21117, 大炮开火")
    if CombatManager.Instance.isFighting == true then
        return
    end
    self:PlayCannonAction(data)
end

--角色操作单位标识
function CanYonManager:On21118(data)
    -- BaseUtils.dump(data, "On21118, 操作状态")
    local uniqueroleid = BaseUtils.get_unique_roleid(data.rid, data.zone_id, data.platform)
    local rv = SceneManager.Instance.sceneElementsModel.RoleView_List[uniqueroleid]
    self.collectstatus[uniqueroleid] = {status = data.status, time = BaseUtils.BASE_TIME}
    if rv == nil then
        return
    end
    if TeamManager.Instance:IsInMyTeam(uniqueroleid) then
        if SceneManager.Instance.sceneElementsModel.self_view ~= rv then
            self.collection.callback = function() end
            self.collection.cancelCallBack = function() end
            if data.status == 1 then
                if BaseUtils.isnull(rv.gameObject) == false then
                    local pos = rv.gameObject.transform.position
                    -- print(Vector2.Distance(Vector2(pos.x, pos.y), self.CannonPosition))
                    if Vector2.Distance(Vector2(pos.x, pos.y), self.CannonPosition) <= 2 then
                        self.collection:Show({msg = "操作大炮中...", time = 20000, optype = 1, special = true})
                    else
                        self.collection:Show({msg = "攻塔中...", time = 20000, optype = 2, special = true})
                    end
                end
            elseif data.status == 2 then
                self.collection:Show({msg = "守塔中...", time = 6000000, optype = 3, special = true})
            else
                self.collection:Cancel()
            end
        end
    end
    if data.status == 1 then
        rv:ShowCollectStatusEffect()
    else
        rv:ClearCollectStatusEffect()
    end
end

--请求玩家所在分组
function CanYonManager:Send21121()
    Connection.Instance:send(21121,{})
end

function CanYonManager:On21121(data)
    -- BaseUtils.dump(data, "On21121, 请求玩家所在分组")
    if data.group_id == 0 then 
        Log.Error("等级段异常"..tostring(data.group_id))
    end

    self.group_id = data.group_id
    self.CanYonUpdateGroupName:Fire()
end

--大炮cd
function CanYonManager:Send21122()
    Connection.Instance:send(21122,{})
end

function CanYonManager:On21122(data)
    -- BaseUtils.dump(data, "On21122, 大炮CD")
    self.cannonCd = data.cd + Time.time--BaseUtils.BASE_TIME
end

-------------------------分割线
--单位初始化
function CanYonManager:InitArenaInfo()
    self.pointList = {
        {name = "A上路水晶塔", unitytype = 1, side = 1, baseid = 79571, id = 1, Position = Vector2(1885, 1647)},
        {name = "A中路水晶塔", unitytype = 1, side = 1, baseid = 79572, id = 2, Position = Vector2(1030, 2073)},
        {name = "A下路水晶塔", unitytype = 1, side = 1, baseid = 79573, id = 3, Position = Vector2(328, 2496)},
        {name = "B上路水晶塔", unitytype = 1, side = 2, baseid = 79574, id = 4, Position = Vector2(2666, 1256)},
        {name = "B中路水晶塔", unitytype = 1, side = 2, baseid = 79575, id = 5, Position = Vector2(3471, 852)},
        {name = "B下路水晶塔", unitytype = 1, side = 2, baseid = 79576, id = 6, Position = Vector2(4349, 352)},
        {name = "大炮", unitytype = 2, side = 0, baseid = 79579, id = 7, Position = Vector2(1320, 904)},
        {name = "A基地", unitytype = 3, side = 1, baseid = 79577, id = 8, Position = Vector2(303, 2092)},
        {name = "B基地", unitytype = 3, side = 2, baseid = 79578, id = 9, Position = Vector2(3731, 266)},
    }
end

--是否在单位范围内
function CanYonManager:CheckOnArena()
    --不在活动中/操作单位/备战/胜利  不检测区域
    if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.CanYon or self.collection.running or self.currstatus == CanYonEumn.Status.Preparing  or self.is_win == 1 then
        return
    end

    local selfposi = Vector2.zero
    if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
        local p = SceneManager.Instance.sceneElementsModel.self_view:GetCachedTransform().localPosition
        p = SceneManager.Instance.sceneModel:transport_big_pos(p.x, p.y)
        selfposi = Vector2(p.x, p.y)
    end
    for k,v in pairs(self.pointList) do
        local dis = Vector2.Distance(selfposi, v.Position)
        if dis <= 320 then
            self.model:EnterArea(v)
            return
        end
    end
    self.model:EnterArea(nil)
end

--进入场景
function CanYonManager:SceneEnter(event, old_event)
    if event ~= RoleEumn.Event.CanYon and old_event == RoleEumn.Event.CanYon then
        if MainUIManager.Instance.MainUIIconView ~= nil then
            MainUIManager.Instance.MainUIIconView:Set_ShowTop(true)
        end
        self.model:CloseFightInfoPanel()
        self.model:StopTowerControll()
    elseif event == RoleEumn.Event.CanYon and old_event ~= RoleEumn.Event.CanYon then
        if self.currstatus == CanYonEumn.Status.Preparing then 
            SoundManager.Instance:PlayCombatChat(self.soundcfg.ready)
        end
        if MainUIManager.Instance.MainUIIconView ~= nil then
            MainUIManager.Instance.MainUIIconView:Set_ShowTop(false, {17})
        end
        self.model:StartTowerControll()
        self.model:OpenFightInfoPanel()
        self:Send21105()
        self:Send21106()
        self:Send21114()
    end

    if event == RoleEumn.Event.CanYonReady and old_event ~= RoleEumn.Event.CanYonReady then
        self:Send21121()
        self.model:OpenMakeTeamPanel()
    elseif event ~= RoleEumn.Event.CanYonReady and old_event == RoleEumn.Event.CanYonReady then
        self.model:CloseMakeTeamPanel()
    end
end

--大炮开火动作
function CanYonManager:PlayCannonAction(data)
    local unitview = nil
    local target_unitview = nil
    for k,v in pairs(SceneManager.Instance.sceneElementsModel.NpcView_List) do
        if v.data.unittype == 1 and v.data.id == 7 then
            unitview = v
        end
        if v.data.unittype == 1 and data.id == v.data.id then
            target_unitview = v
        end
    end
    if target_unitview == nil or unitview == nil or BaseUtils.isnull(unitview.gameObject) then
        return
    end
    local selfposi = Vector2.zero
    if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
        local p = SceneManager.Instance.sceneElementsModel.self_view:GetCachedTransform().position
        p = SceneManager.Instance.sceneModel:transport_big_pos(p.x, p.y)
        selfposi = Vector2(p.x, p.y)
    end
    self.ShakeAction = DramaCameraShake.New()
    self.FireAction = DramaCameraMove.New()
    self.FireAction.callback = function()
        if data.id > 3 then
            unitview:play_action_name("Hit1")
        else
            unitview:play_action_name("Hit2")
        end
        local trans = unitview:GetCachedTransform()
        -- print(trans:Find("topse"))
        self.FireEffect.transform:SetParent(trans:Find("tpose/bp_paokou"))
        self.FireEffect.transform.localScale = -Vector3.one
        self.FireEffect.transform.localPosition = Vector3.zero
        self.FireEffect.transform.localRotation = Quaternion.identity
        -- self.FireEffect.transform:Rotate(Vector3(320, 0, 0))
        Utils.ChangeLayersRecursively(self.FireEffect.transform, "Model")
        self.FireEffect.gameObject:SetActive(false)
        self.FireEffect.gameObject:SetActive(true)
        LuaTimer.Add(1000, function()
            SoundManager.Instance:PlayCombatChat(self.soundcfg.fire)
            self.ShakeAction:Show({mode = 1, time = 500})
        end)
        LuaTimer.Add(2000, function()
            local delaytime = Vector2.Distance(Vector2(target_unitview.data.x, target_unitview.data.y), self.pointList[7].Position)/3
            self.HitAction:Show({x=target_unitview.data.x, y = target_unitview.data.y, time = delaytime})
        end)
        LuaTimer.Add(3000, function()
            self.FireEffect:DeleteMe()
            self.FireEffect = nil
            self.palycannonactioning = false
        end)
    end
    self.HitAction = DramaCameraMove.New()
    self.HitAction.callback = function()
        local trans = target_unitview:GetCachedTransform()
        self.HitEffect.transform:SetParent(trans:Find("tpose"))
        self.HitEffect.transform.localScale = Vector3.one
        self.HitEffect.transform.localPosition = Vector3.zero
        self.HitEffect.transform.localRotation = Quaternion.identity
        self.HitEffect.transform:Rotate(Vector3(0, 180, 0))
        Utils.ChangeLayersRecursively(self.HitEffect.transform, "Model")
        self.HitEffect.gameObject:SetActive(false)
        self.HitEffect.gameObject:SetActive(true)

        SoundManager.Instance:PlayCombatChat(self.soundcfg.hit)
        self.ShakeAction:Show({mode = 1, time = 500})
        LuaTimer.Add(1000, function()
            self.BackAction:Show({x=selfposi.x, y = selfposi.y, time = 1000})
        end)
    end
    self.BackAction = DramaCameraMove.New()
    self.BackAction.callback = function()
        DramaManager.Instance.model:ShowUIHided()
        SceneManager.Instance.MainCamera.lock = false
        self.HitEffect:DeleteMe()
        self.HitEffect = nil
        -- MainUIManager.Instance.MainUIIconView:hidebaseicon3()
        self.HitAction:DeleteMe()
        self.BackAction:DeleteMe()
        self.FireAction:DeleteMe()
        DramaManager.Instance.model:ShowAllUnit()
        SceneManager.Instance.sceneElementsModel:teamfollow()
    end
    local hitLoaded = function()
        local delaytime = Vector2.Distance(selfposi, self.pointList[7].Position)/3
        self.FireEffect = BaseEffectView.New({ effectId = 30145, callback = function() DramaManager.Instance.model:HideMain() self.FireAction:Show({x = self.pointList[7].Position.x, y = self.pointList[7].Position.y, time = 2000}) end })
    end
    self.HitEffect = BaseEffectView.New({ effectId = 30146, callback = hitLoaded })
end

--是否采集状态
function CanYonManager:IsCollecting(uniqueroleid)
    if self.currstatus ~= CanYonEumn.Status.Playing then
        return false
    end
    if self.collectstatus[uniqueroleid] == nil then
        return false
    elseif self.collectstatus[uniqueroleid].status ~= 0 and BaseUtils.BASE_TIME - self.collectstatus[uniqueroleid].time < 20 then
        return true
    elseif self.collectstatus[uniqueroleid].status ~= 0 and BaseUtils.BASE_TIME - self.collectstatus[uniqueroleid].time >= 20 then
        self.collectstatus[uniqueroleid].status = 0
        return false
    else
        return false
    end
end


function CanYonManager:BarrierArea()
    if SceneManager.Instance:CurrentMapId() == 52001 and self.currstatus == CanYonEumn.Status.Preparing then
        local datapos = {}
        local num = 1
        for i,v in ipairs(DataMap.active_region[52001]) do
            local key = math.ceil(num/100)
            if datapos[key] == nil then
                datapos[key] = {}
            end
            table.insert(datapos[key], {x = v[1], y = v[2]})
            num = num + 1
        end
        for k,v in pairs(datapos) do
            LuaTimer.Add(k*250, function()
                local data = {base_id = 52001, flag = 1, pos = v}
                SceneManager.Instance:On10102(data)
            end)
        end
    elseif SceneManager.Instance:CurrentMapId() == 52001 and self.currstatus == CanYonEumn.Status.Playing then
        local datapos = {}
        local num = 1
        for i,v in ipairs(DataMap.active_region[52001]) do
            local key = math.ceil(num/100)
            if datapos[key] == nil then
                datapos[key] = {}
            end
            table.insert(datapos[key], {x = v[1], y = v[2]})
            num = num + 1
        end
        for k,v in pairs(datapos) do
            LuaTimer.Add(k*350, function()
                local data = {base_id = 52001, flag = 0, pos = v}
                SceneManager.Instance:On10102(data)
            end)
        end
    end

end


function CanYonManager:UpdateIcon()
    if self.iconEffect ~= nil then
        self.iconEffect:DeleteMe()
    end

    local cfg_data = DataSystem.data_daily_icon[123]
    MainUIManager.Instance:DelAtiveIcon(cfg_data.id)

    --未达到开放条件
    if cfg_data.lev > RoleManager.Instance.RoleData.lev or RoleManager.Instance.world_lev < 70 then
        return
    end

    local callback = function()
            if RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYon or RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYonReady then
                local npcBase = DataUnit.data_unit[20060]
                npcBase.buttons = {}
                npcBase.plot_talk = TI18N("已经在活动中")
                MainUIManager.Instance:OpenDialog({baseid = npcBase.id, name = npcBase.name}, {base = npcBase}, true, true)
            elseif self.currstatus ~= CanYonEumn.Status.Reading then 
                local npcBase = DataUnit.data_unit[20060]
                npcBase.buttons = {}
                npcBase.plot_talk = TI18N("峡谷之巅已经开始，战火纷飞不宜出入，以免误伤。还请下次尽早入场哦~{face_1,22}")
                MainUIManager.Instance:OpenDialog({baseid = npcBase.id, name = npcBase.name}, {base = npcBase}, true, true)
            else
                self:Send21101()
            end
        end

    -- AgendaManager.Instance:SetCurrLimitID(2028, self.currstatus == 2)
    if self.currstatus == CanYonEumn.Status.Reading or self.currstatus == CanYonEumn.Status.Grouping or self.currstatus == CanYonEumn.Status.Preparing or self.currstatus == CanYonEumn.Status.Playing or self.currstatus == CanYonEumn.Status.Finished then        --进行中
        --动态图标
        local iconData = AtiveIconData.New()
        iconData.id = cfg_data.id
        iconData.iconPath = cfg_data.res_name
        iconData.clickCallBack = callback
        iconData.sort = cfg_data.sort
        iconData.lev = cfg_data.lev
        if self.currstatus == CanYonEumn.Status.Reading or self.currstatus == CanYonEumn.Status.Grouping then
            iconData.text = TI18N("准备中")
        elseif self.currstatus == CanYonEumn.Status.Preparing then
            iconData.timestamp = self.activity_time + 2400 + 300 - BaseUtils.BASE_TIME + Time.time
        elseif self.currstatus == CanYonEumn.Status.Playing then 
            iconData.timestamp = self.activity_time + 300 - BaseUtils.BASE_TIME + Time.time
        elseif self.currstatus == CanYonEumn.Status.Finished then
            iconData.timestamp = self.activity_time - BaseUtils.BASE_TIME + Time.time
        end
        iconData.timeoutCallBack = function() self:Send21100() end --MainUIManager.Instance:DelAtiveIcon(cfg_data.id)  end 

        --动态图标特效
        self.icon = MainUIManager.Instance:AddAtiveIcon(iconData)
        if BaseUtils.isnull(self.icon) then
            if self.iconEffect ~= nil then
                self.iconEffect:DeleteMe()
                self.iconEffect = nil
            end
        else
            if self.iconEffect == nil then 
                self.iconEffect = BaseUtils.ShowEffect(20256,self.icon.transform,Vector3(1,1,1),Vector3(0, 32, -400))
            end
        end

        --活动开启提示框
        if self.currstatus == CanYonEumn.Status.Reading and RoleManager.Instance.RoleData.lev >= cfg_data.lev and not (RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYon or RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYonReady)  then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("<color='#ffff00'>峡谷之巅</color>活动正在进行中，是否前往参加？")
            data.sureLabel = TI18N("确定")
            data.cancelLabel = TI18N("取消")
            data.cancelSecond = 180
            data.sureCallback = callback
            NoticeManager.Instance:ActiveConfirmTips(data)
        end

        --备战阻挡区
        self:BarrierArea()

        -- 正式开始语音
        if self.old_status ~= CanYonEumn.Status.Playing and self.currstatus == CanYonEumn.Status.Playing and RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYon then 
            SoundManager.Instance:PlayCombatChat(self.soundcfg.start)
        end

        --正式开始再请求大炮cd
        if CanYonManager.Instance.currstatus == CanYonEumn.Status.Playing and RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYon then 
            self:Send21122()
        end
    end
end

--外部判断是否正在攻塔、守塔、开炮...
function CanYonManager:CanyonRunningStatus()
    local mark = false
    if CanYonManager.Instance.collection ~= nil and CanYonManager.Instance.collection.running == true and RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYon then
        if CanYonManager.Instance.collection.openArgs ~= nil and CanYonManager.Instance.collection.openArgs.optype ~= 3 then 
            mark = true
        end
    end
    return mark
end

function CanYonManager:ChangeTeamStopCanyonRunning()
    if CanYonManager.Instance.collection.openArgs ~= nil then 
        if CanYonManager.Instance.collection.openArgs.optype == 1 then 
            NoticeManager.Instance:FloatTipsByString(TI18N("正在操作大炮，稍后再调整队伍吧{face_1,22}"))
        elseif CanYonManager.Instance.collection.openArgs.optype == 2 then 
            NoticeManager.Instance:FloatTipsByString(TI18N("正在进攻敌方水晶塔，稍后再调整队伍吧{face_1,22}"))
        end
    end
end

--对应data_team表id
function CanYonManager:GetTeamTypeID()
    --策划说这里暂时不做了，改成默认悬赏(teamdata ID)
    return 51
    -- if self.group_id == nil then
    --     return 122
    -- end
    -- return self.group_id + 121
end