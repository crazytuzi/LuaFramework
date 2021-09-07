-- @author 黄耀聪
-- @date 2017/8/17

ExquisiteShelfManager = ExquisiteShelfManager or BaseClass(BaseManager)

function ExquisiteShelfManager:__init()
    if ExquisiteShelfManager.Instance ~= nil then
        Log.Error("不可重复实例化")
        return
    end
    ExquisiteShelfManager.Instance = self

    self.model = ExquisiteShelfModel.New()

    self.wave = nil

    self.name = TI18N("玲珑宝阁")
    self.readyMapId = 53006
    self.firstMapId = 53007
    self.secondMapId = 53008
    self.transportBaseId = 58031
    self.finalWave = 9
    self.firstWave = 6
    self.finalLevel = 2

    self:InitNetHandlers()

    self.simulate = true

    self.onUpdateEvent = EventLib.New()
    self.onRewardEvent = EventLib.New()
    self.onGetMonsterMsg = EventLib.New()
    self.nowBaseId = nil
end

function ExquisiteShelfManager:__delete()
end

function ExquisiteShelfManager:InitNetHandlers()
    if self:Blockout() then
        return
    end
    self:AddNetHandler(20300, self.on20300)
    self:AddNetHandler(20301, self.on20301)
    -- self:AddNetHandler(20302, self.on20302)
    self:AddNetHandler(20303, self.on20303)
    self:AddNetHandler(20304, self.on20304)
    self:AddNetHandler(20305, self.on20305)
    self:AddNetHandler(20306, self.on20306)
    self:AddNetHandler(20307, self.on20307)
    self:AddNetHandler(20308, self.on20308)
    self:AddNetHandler(20309, self.on20309)
    self:AddNetHandler(20310, self.on20310)
    self:AddNetHandler(20302,self.on20302)

    EventMgr.Instance:AddListener(event_name.scene_load, function() self:SceneLoad() end)
    EventMgr.Instance:AddListener(event_name.role_event_change, function() self.model:EnterScene() end)
    EventMgr.Instance:AddListener(event_name.end_fight, function(type, result) self:EndFight(type, result) end)
    EventMgr.Instance:AddListener(event_name.npc_list_update, function() self:CreateNpc() end)
    EventMgr.Instance:AddListener(event_name.begin_fight, function(type) self:BeginFight(type) end)
end

--
function ExquisiteShelfManager:send20300()
    Connection.Instance:send(20300, {})
end

function ExquisiteShelfManager:on20300(data)
    --BaseUtils.dump(data, "<color='#ffff00'>on20300</color>")
    self.lastMaxWave = self.model.shelfData.max_wave
    self.model.shelfData.max_wave = data.max_wave
    self.model.hasNotReward = data.flag
    self.onUpdateEvent:Fire()
end

-- 开启宝阁战斗,789
function ExquisiteShelfManager:send20301(wave)
    --print(wave)
    Connection.Instance:send(20301, {wave = wave})
end

function ExquisiteShelfManager:on20301(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 退出准备区场景
function ExquisiteShelfManager:send20302()
    Connection.Instance:send(20302, {})
end

function ExquisiteShelfManager:on20302(data)
    -- BaseUtils.dump(data,"协议回调20302====================================")
    local id = nil
    for k,v in pairs(data.unit_info) do
        if v.wave == 7 then
            id = v.base_id
        end
    end

    self.monsterId = id

    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.exquisite_shelf_show_window)
end

-- 查询进入层
function ExquisiteShelfManager:send20303()
    Connection.Instance:send(20303, {})
end

function ExquisiteShelfManager:on20303(data)
    -- self.model.shelfData.wave = data.wave
    -- NoticeManager.Instance:FloatTipsByString(data.msg)
    self:Enter(data.wave)
end

-- 开始挑战
function ExquisiteShelfManager:send20304(is_restart, is_plot)
    Connection.Instance:send(20304, {is_restart = is_restart, is_plot = is_plot})
end

function ExquisiteShelfManager:on20304(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 退出挑战
function ExquisiteShelfManager:send20305()
    Connection.Instance:send(20305, {})
end

function ExquisiteShelfManager:on20305(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 当前副本刷怪状态
function ExquisiteShelfManager:send20306()
    Connection.Instance:send(20306, {})
end

function ExquisiteShelfManager:on20306(data)
    -- BaseUtils.dump(data, "on20306")-- .. tostring(os.date("%X", BaseUtils.BASE_TIME)))
    -- if IS_DEBUG then
    --     NoticeManager.Instance:FloatTipsByString(tostring(os.date("%X", BaseUtils.BASE_TIME)))
    -- end
    self.model.shelfData.wave = data.wave
    self.model.shelfData.battle_id = data.battle_id
    self.model.shelfData.base_id = data.base_id
    self.model.shelfData.status = data.status

    self.onUpdateEvent:Fire()

    if data.base_id > 0 and (not CombatManager.Instance.isFighting) and self.plotPlaying ~= true then
        self:PlayFollow()
    end
end

-- 进入下一层
function ExquisiteShelfManager:send20307()
    -- print("<color='#ffff00'>send20307</color>")
    Connection.Instance:send(20307, {})
end

function ExquisiteShelfManager:on20307(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 翻牌信息
function ExquisiteShelfManager:send20308()
    Connection.Instance:send(20308, {})
end

function ExquisiteShelfManager:on20308(data)
    -- 战斗未结束就等待结束
    if CombatManager.Instance.isFighting and self.model.rewardWin == nil then
        LuaTimer.Add(1000, function() self:on20308(data) end)
        return
    end

    for i,v in ipairs(data.normal_gain_list) do
        if v.is_get == 1 then
            data.normal_gain_list[i],data.normal_gain_list[v.index] = data.normal_gain_list[v.index],data.normal_gain_list[i]
        end
    end
    for i,v in ipairs(data.gold_gain_list) do
        if v.is_get == 1 then
            data.gold_gain_list[i],data.gold_gain_list[v.index] = data.gold_gain_list[v.index],data.gold_gain_list[i]
        end
    end

    -- print(debug.traceback())
    -- BaseUtils.dump(data, "<color='#00ff00'>on20308</color>")
    if #data.normal_gain_list + #data.gold_gain_list == 0 or (self.model.rewardWin == nil or self.model.rewardWin.isOpen ~= true) then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.exquisite_shelf_reward, {type = data.type, data = data})
    else
        self.onRewardEvent:Fire(data)
    end

    self:send20300()
end

-- 请求翻牌数据
function ExquisiteShelfManager:send20309()
    Connection.Instance:send(20309, {})
end

function ExquisiteShelfManager:on20309(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 翻牌
function ExquisiteShelfManager:send20310(order, type)
    local dat = {order = order, type = type}
    -- BaseUtils.dump(dat, "send20310")
    Connection.Instance:send(20310, dat)
end

function ExquisiteShelfManager:on20310(data)
    -- BaseUtils.dump(data, "<color='#ff0000'>on20310</color>")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.err_code == 0 then
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.exquisite_shelf_reward)
    end
end

-- ================================================================
--                以下是外部调用接口
-- ================================================================

-- 进准备区
function ExquisiteShelfManager:EnterReady()
    -- self.confirmData = self.confirmData or NoticeConfirmData.New()
    -- self.confirmData.content = string.format(TI18N("是否进入<color='#ffff00'>%s</color>？"), self.name)
    -- self.confirmData.sureCallback = function() SceneManager.Instance.sceneElementsModel:Self_Transport(self.readyMapId, 0, 0) WindowManager.Instance:CloseWindowById(WindowConfig.WinID.exquisite_shelf) end
    -- self.confirmData.sureLabel = TI18N("确 定")
    -- self.confirmData.cancelCallback = nil
    -- self.confirmData.cancelLabel = TI18N("取 消")
    -- NoticeManager.Instance:ConfirmTips(self.confirmData)
    SceneManager.Instance.sceneElementsModel:Self_Transport(self.readyMapId, 0, 0)
    -- if RoleManager.Instance:CanConnectCenter() then
    --     SceneManager.Instance:Send10170(self.readyMapId)
    -- else
    -- end
end

function ExquisiteShelfManager:Enter(wave)
    wave = wave or 1
    if wave > 1 then
        self.confirmData = self.confirmData or NoticeConfirmData.New()
        self.confirmData.showClose = 1

        if wave > self.firstWave then
            self.confirmData.content = TI18N("是否从<color='#ffff00'>内阁王者</color>开始挑战？")
        else
            self.confirmData.content = string.format(TI18N("是否从<color='#ffff00'>第%s位宝阁王者</color>开始挑战？"), BaseUtils.NumToChn(wave))
        end
        self.confirmData.sureCallback = function() self:send20304(0, 0) end
        self.confirmData.sureLabel = TI18N("确 定")
        self.confirmData.cancelCallback = function() self:send20304(1, 1) end
        self.confirmData.cancelLabel = TI18N("重新开始")
        NoticeManager.Instance:ConfirmTips(self.confirmData)
    else
        self:send20304(0, 1)
    end
end

-- 退出场景
function ExquisiteShelfManager:Exit()
    if self.plotPlaying then
        NoticeManager.Instance:FloatTipsByString(TI18N("正在播放剧情，请稍后"))
        return
    end
    self.confirmData = self.confirmData or NoticeConfirmData.New()
    self.confirmData.showClose = -1
    self.confirmData.content = string.format(TI18N("是否退出<color='#ffff00'>%s</color>？"), self.name)
    self.confirmData.sureCallback = function() self:send20305() end
    self.confirmData.sureLabel = TI18N("确 定")
    self.confirmData.cancelCallback = nil
    self.confirmData.cancelLabel = TI18N("取 消")
    NoticeManager.Instance:ConfirmTips(self.confirmData)
end

-- 登录初始化
function ExquisiteShelfManager:RequestInitData()
    if self:Blockout() then
        return
    end
    if self.textPanel ~= nil then
        self.textPanel:DeleteMe()
        self.textPanel = nil
    end
    self.model.shelfData = {}
    self.lastMapId = nil
    self.lastMaxWave = nil
    self:send20306()
    self:send20300()
end

-- 去下一层
function ExquisiteShelfManager:NextFloor()
    self:send20307()
end

-- 获取当前层
function ExquisiteShelfManager:GetCurrentLevel(wave)
    wave = wave or self.model.shelfData.wave or 1
    if wave > self.firstWave then
        return wave - self.firstWave + 1
    else
        return 1
    end
end

-- 可开启箱子数目
function ExquisiteShelfManager:GetBoxNum()
    local maxWave = self.model.shelfData.max_wave or 1
    if maxWave > self.firstWave then
        return maxWave - self.firstWave
    else
        return 0
    end
end

-- 当前层的怪都打完了吗？
function ExquisiteShelfManager:IsCurrentLevelFinish()
    return self.model.shelfData.status == ExquisiteShelfEumn.MosterStatus.Finish
end

function ExquisiteShelfManager:IsAllFinish()
    return self.model.shelfData.wave == self.finalWave and self:IsCurrentLevelFinish()
end

function ExquisiteShelfManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

function ExquisiteShelfManager:OpenShowWindow(args)
    self.model:OpenShowWindow(args)
end

function ExquisiteShelfManager:OpenReward(args)
    self.model:OpenReward(args)
end

function ExquisiteShelfManager:SceneLoad()
    local mapId = SceneManager.Instance:CurrentMapId()
    local t = MainUIManager.Instance.MainUIIconView
    if self.lastMapId == self.readyMapId and mapId == self.firstMapId then
        self:PlayPlot()
        if t ~= nil then
            t:Set_ShowTop(false, {17, 107})
        end
    elseif (self.lastMapId == self.firstMapId or self.lastMapId == self.secondMapId) and mapId == self.readyMapId then
        if t ~= nil then
            t:Set_ShowTop(true, {17, 107})
        end

        if self.textPanel ~= nil then
            self.textPanel:DeleteMe()
            self.textPanel = nil
        end

    elseif self.lastMapId ~= self.readyMapId and self.lastMapId ~= self.secondMapId and mapId == self.readyMapId then
        if RoleManager.Instance:CanConnectCenter() and RoleManager.Instance.RoleData.cross_type ~= 1 then
            SceneManager.Instance:Send10170(self.readyMapId)
        end
        self:send20302()


    end

    if mapId ~= self.readyMapId then
        if self.model.showWin ~= nil then
            WindowManager.Instance:CloseWindow(self.model.showWin)
        end
    end

    self.lastMapId = mapId

    self:CreateNpc()
end

function ExquisiteShelfManager:GotoTransport()
    local npcList = SceneManager.Instance.sceneElementsModel:GetSceneData_Npc()
    for _,npc in ipairs(npcList) do
        if npc.unittype == SceneConstData.unittype_exquisite_shelf then
            SceneManager.Instance.sceneElementsModel:Self_AutoPath(SceneManager.Instance:CurrentMapId(), npc.uniqueid, nil, nil, true)
            break
        end
    end
end

function ExquisiteShelfManager:GotoMoster()
    if self.model.shelfData.status == ExquisiteShelfEumn.MosterStatus.Move then
        return
    end

    local npcList = SceneManager.Instance.sceneElementsModel:GetSceneData_Npc()
    for _,npc in ipairs(npcList) do
        if npc.baseid == self.model.shelfData.base_id and npc.battleid == self.model.shelfData.battle_id then
            if self:GetCurrentLevel() == 1 and self.model.shelfData.status == ExquisiteShelfEumn.MosterStatus.Move then
                NoticeManager.Instance:FloatTipsByString(TI18N("请等待宝阁王者进入擂台"))
            else
                SceneManager.Instance.sceneElementsModel:Self_AutoPath(SceneManager.Instance:CurrentMapId(), npc.uniqueid, nil, nil, true)
            end
            break
        end
    end
end

function ExquisiteShelfManager:PlayPlot(isSecond)
    if self.model.shelfData.wave ~= 1 then
        return
    end
    local npcList = SceneManager.Instance.sceneElementsModel:GetSceneData_Npc()

    if isSecond and #npcList == 0 then
        return
    elseif #npcList == 0 then
        LuaTimer.Add(1200, function() self:PlayPlot(true) end)
        return
    end

    local g = Vector2.zero
    for _,v in ipairs(npcList) do
        g = g + Vector2(v.x, v.y)
    end
    g = g / #npcList
    for i,v in ipairs(npcList) do
        local n = (Vector2(v.x, v.y) - g).normalized
        if v.y < g.y then
            v.theta = -math.acos(Vector2.Dot(n, Vector2(-1, 0)))
        else
            v.theta = math.acos(Vector2.Dot(n, Vector2(-1, 0)))
        end
        -- SceneManager.Instance.sceneElementsModel:CreateNpc(v.uniqueid,v,nil)
    end
    table.sort(npcList, function(a,b) return a.theta < b.theta end)

    -- BaseUtils.dump(npcList, "npcList")
    if #npcList < 6 then
        return
    end

    local dramaList = {
        {type = DramaEumn.ActionType.Cameramoveto, x = 1989, y = 512, time = 1000}
        , {type = DramaEumn.ActionType.Animationplaypoint, x = npcList[1].x, y = npcList[1].y, res_id = 30019}
        , {type = DramaEumn.ActionType.Plotunitcreate, unit_id = 1, battle_id = 0, unit_base_id = npcList[1].baseid, msg = npcList[1].name, mapid = 53007, x = npcList[1].x, y = npcList[1].y}

        , {type = DramaEumn.ActionType.Cameramoveto, x = 1567, y = 408, time = 1000}
        , {type = DramaEumn.ActionType.Animationplaypoint, x = npcList[2].x, y = npcList[2].y, res_id = 30019}
        , {type = DramaEumn.ActionType.Plotunitcreate, unit_id = 2, battle_id = 0, unit_base_id = npcList[2].baseid, msg = npcList[2].name, mapid = 53007, x = npcList[2].x, y = npcList[2].y}

        , {type = DramaEumn.ActionType.Cameramoveto, x = 1169, y = 516, time = 1000}
        , {type = DramaEumn.ActionType.Animationplaypoint, x = npcList[3].x, y = npcList[3].y, res_id = 30019}
        , {type = DramaEumn.ActionType.Plotunitcreate, unit_id = 3, battle_id = 0, unit_base_id = npcList[3].baseid, msg = npcList[3].name, mapid = 53007, x = npcList[3].x, y = npcList[3].y}

        , {type = DramaEumn.ActionType.Cameramoveto, x = 1051, y = 845, time = 1000}
        , {type = DramaEumn.ActionType.Animationplaypoint, x = npcList[4].x, y = npcList[4].y, res_id = 30019}
        , {type = DramaEumn.ActionType.Plotunitcreate, unit_id = 4, battle_id = 0, unit_base_id = npcList[4].baseid, msg = npcList[4].name, mapid = 53007, x = npcList[4].x, y = npcList[4].y}

        , {type = DramaEumn.ActionType.Cameramoveto, x = 1367, y = 870, time = 1000}
        , {type = DramaEumn.ActionType.Animationplaypoint, x = npcList[5].x, y = npcList[5].y, res_id = 30019}
        , {type = DramaEumn.ActionType.Plotunitcreate, unit_id = 5, battle_id = 0, unit_base_id = npcList[5].baseid, msg = npcList[5].name, mapid = 53007, x = npcList[5].x, y = npcList[5].y}

        , {type = DramaEumn.ActionType.Cameramoveto, x = 1647, y = 795, time = 800}
        , {type = DramaEumn.ActionType.Animationplaypoint, x = npcList[6].x, y = npcList[6].y, res_id = 30019}
        , {type = DramaEumn.ActionType.Plotunitcreate, unit_id = 6, battle_id = 0, unit_base_id = npcList[6].baseid, msg = npcList[6].name, mapid = 53007, x = npcList[6].x, y = npcList[6].y}

        , {type = DramaEumn.ActionType.Camerareset, time = 1000}
        , {type = DramaEumn.ActionType.Plotunitdel, unit_id = 1}
        , {type = DramaEumn.ActionType.Plotunitdel, unit_id = 2}
        , {type = DramaEumn.ActionType.Plotunitdel, unit_id = 3}
        , {type = DramaEumn.ActionType.Plotunitdel, unit_id = 4}
        , {type = DramaEumn.ActionType.Plotunitdel, unit_id = 5}
        , {type = DramaEumn.ActionType.Plotunitdel, unit_id = 6}

        , {type = DramaEumn.ActionType.Endplot, callback = function() self:EndPlot() end}
    }
    DramaManagerCli.Instance:ExquisiteShelf(dramaList)
    self:BeginPlot()
end

-- 便捷组队
function ExquisiteShelfManager:OnTeam()
    local cfgData = DataTeam.data_match[self:GetTeamType()]
    TeamManager.Instance.TypeOptions = {}
    TeamManager.Instance.TypeOptions[cfgData.type] = cfgData.id
    TeamManager.Instance.LevelOption = 1
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team, {1})
end

function ExquisiteShelfManager:DisappearText(frame)
    if self.textPanel ~= nil then
        self.textPanel:Disappear(frame)
    end
end

function ExquisiteShelfManager:PlayFollow()
    local currentLevel = self:GetCurrentLevel()

    local recommand_lev = (DataExquisiteShelf.data_reward[BaseUtils.Key(self:GetCurrentShelfLev(), self.model.shelfData.wave)] or {}).lev or 0
    if self.model.shelfData.status == ExquisiteShelfEumn.MosterStatus.Stay then
        if recommand_lev == 0 then
            if currentLevel == 1 then
                self:ShowText(string.format(TI18N("第%s位宝阁王者<color='#00ff00'>%s</color>正在等待你的挑战"), BaseUtils.NumToChn(self.model.shelfData.wave or 1), DataUnit.data_unit[self.model.shelfData.base_id].name))
            else
                self:ShowText(string.format(TI18N("本层你将迎来<color='#00ff00'>%s</color>的考验"), DataUnit.data_unit[self.model.shelfData.base_id].name))
            end
        else
            if currentLevel == 1 then
                self:ShowText(string.format(TI18N("第%s位宝阁王者<color='#00ff00'>%s</color>正在等待你的挑战（推荐等级<color='#00ff00'>%s</color>）"), BaseUtils.NumToChn(self.model.shelfData.wave or 1), DataUnit.data_unit[self.model.shelfData.base_id].name, recommand_lev))
            else
                self:ShowText(string.format(TI18N("本层你将迎来<color='#00ff00'>%s</color>的考验（推荐等级<color='#00ff00'>%s</color>）"), DataUnit.data_unit[self.model.shelfData.base_id].name, recommand_lev))
            end
        end
        LuaTimer.Add(2000, function()
            self:ResetCamera()
            self:SetMove(true)
        end)
    elseif self.model.shelfData.status == ExquisiteShelfEumn.MosterStatus.Move then
        if not self:CheckNpc(self.model.shelfData.base_id, self.model.shelfData.battle_id) then
            LuaTimer.Add(200, function() self:PlayFollow() end)
            return
        end
        if recommand_lev == 0 then
            if currentLevel == 1 then
                self:ShowText(string.format(TI18N("第%s位宝阁王者<color='#00ff00'>%s</color>正在进入擂台"), BaseUtils.NumToChn(self.model.shelfData.wave or 1), DataUnit.data_unit[self.model.shelfData.base_id].name))
            else
                self:ShowText(string.format(TI18N("本层你将迎来<color='#00ff00'>%s</color>的考验"), DataUnit.data_unit[self.model.shelfData.base_id].name))
            end
        else
            if currentLevel == 1 then
                self:ShowText(string.format(TI18N("第%s位宝阁王者<color='#00ff00'>%s</color>正在进入擂台（推荐等级<color='#00ff00'>%s</color>）"), BaseUtils.NumToChn(self.model.shelfData.wave or 1), DataUnit.data_unit[self.model.shelfData.base_id].name, recommand_lev))
            else
                self:ShowText(string.format(TI18N("本层你将迎来<color='#00ff00'>%s</color>的考验（推荐等级<color='#00ff00'>%s</color>）"), DataUnit.data_unit[self.model.shelfData.base_id].name, recommand_lev))
            end
        end
        if currentLevel > 1 then        -- 只有内阁需要移动镜头
            SceneManager.Instance.MainCamera:SetFolloewObject(SceneManager.Instance.sceneElementsModel.NpcView_List[BaseUtils.Key(self.model.shelfData.base_id, self.model.shelfData.battle_id)].gameObject, true)
            LuaTimer.Add(300, function() self:SetMove(false) end)
        end
    elseif self.model.shelfData.status == ExquisiteShelfEumn.MosterStatus.Finish then
        if currentLevel == 1 then
            self:ShowText(string.format(TI18N("恭喜通关%s外阁"), self.name))
            LuaTimer.Add(2000, function() self:DisappearText(20) end)
        elseif self:IsAllFinish() then
            self:ShowText(string.format(TI18N("恭喜%s全通"), self.name))
            LuaTimer.Add(2000, function() self:DisappearText(20) end)
        else
            self:ShowText(string.format(TI18N("恭喜您通过了<color='#00ff00'>%s</color>的考验，可以进入下一层"), DataUnit.data_unit[self.model.shelfData.base_id].name))
        end
    end
end

function ExquisiteShelfManager:ResetCamera()
    SceneManager.Instance.sceneElementsModel:teamfollow()
end

function ExquisiteShelfManager:CheckNpc(id, battleid)
    -- BaseUtils.dump(SceneManager.Instance.sceneElementsModel.NpcView_List)
    -- for _,npc in pairs(SceneManager.Instance.sceneElementsModel.NpcView_List) do
    --     if npc.baseData.id == id then
    --         return true
    --     end
    -- end
    return SceneManager.Instance.sceneElementsModel.NpcView_List[BaseUtils.Key(id, battleid)] ~= nil
end

-- 退出准备区
function ExquisiteShelfManager:ExitReady()
    -- 回主城
    SceneManager.Instance.sceneElementsModel:Self_Transport(10001, 0, 0)
end

-- 是否屏蔽此功能
function ExquisiteShelfManager:Blockout()
    -- return not (IS_DEBUG or Application.platform == RuntimePlatform.WindowsPlayer or Application.platform == RuntimePlatform.WindowsEditor)
    return false
end

-- 是否允许移动
function ExquisiteShelfManager:SetMove(bool)
    SceneManager.Instance.sceneElementsModel:Set_isovercontroll(bool == true)
    -- SceneManager.Instance.sceneElementsModel.isovercontroll = (bool == true)
end

function ExquisiteShelfManager:BeginPlot()
    if MainUIManager.Instance.mainuitracepanel ~= nil then
        MainUIManager.Instance.mainuitracepanel:TweenHiden()
    end
    self.plotPlaying = true
    self:ShowText(string.format(TI18N("欢迎来到玲珑宝阁，你将面对%s位宝阁王者的考验"), self.firstWave))
    LuaTimer.Add(800, function() self:SetMove(false) end)
end

function ExquisiteShelfManager:EndPlot()
    if MainUIManager.Instance.mainuitracepanel ~= nil then
        MainUIManager.Instance.mainuitracepanel:TweenShow()
    end
    self.plotPlaying = false
    self:SetMove(true)

    self:PlayFollow()
end

-- 是否没领奖，提升用
function ExquisiteShelfManager:HasnotReward()
    return self.model.hasNotReward == 1
end

function ExquisiteShelfManager:GetTeamType()
    local idList = {115,116}
    local need_id = nil
    for i,id in ipairs(idList) do
        if DataTeam.data_match[id].open_lev <= RoleManager.Instance.RoleData.lev and RoleManager.Instance.RoleData.lev <= DataTeam.data_match[id].open_lev_limit then
            need_id = id
            break
        end
    end

    return need_id
end

-- 当前层是否领奖
function ExquisiteShelfManager:HasRewardCurrentLevel()
    if self.lastMaxWave == nil then return false end
    local maxWave = self.lastMaxWave or 0
    if maxWave < self.firstWave then
        maxWave = 0
    else
        maxWave = maxWave - self.firstWave + 1
    end
    return maxWave >= ExquisiteShelfManager.Instance:GetCurrentLevel()
end

function ExquisiteShelfManager:EndFight(type, result)
    if type == 63 and result == 1 then
        local npcList = SceneManager.Instance.sceneElementsModel:GetSceneData_Npc()
        for i,v in ipairs(npcList) do
            v.exclude_outofview = true
            local key = BaseUtils.get_unique_npcid(v.id, v.battleid)
            local npcdata = SceneManager.Instance.sceneElementsModel:GetSceneData_OneNpc(key)
            SceneManager.Instance.sceneElementsModel:CreateNpc(key,npcdata,nil)
        end

        if self:HasRewardCurrentLevel() and self.model.shelfData.wave == self.firstWave and self.model.shelfData.status == ExquisiteShelfEumn.MosterStatus.Finish then
            self:ShowTeamUp()
        end

        if self.model.shelfData.wave <= self.firstWave and self.model.shelfData.status ~= ExquisiteShelfEumn.MosterStatus.Finish and TeamManager.Instance:IsSelfCaptin() then
            LuaTimer.Add(2000, function() self:send20307() end)
        end
        if self:IsAllFinish() then
            self:ShowText(string.format(TI18N("恭喜%s全通"), self.name))
            self:PlayFollow()
        elseif self:GetCurrentLevel() > 1 or self.model.shelfData.wave == self.firstWave then
            self:ShowText(string.format(TI18N("恭喜您通过了<color='#00ff00'>%s</color>的考验，可以进入下一层"), DataUnit.data_unit[self.model.shelfData.base_id].name))
            self:PlayFollow()
        else
            self:ShowText(string.format(TI18N("恭喜您已经击败<color='#00ff00'>%s</color>，等待下一位宝阁王者进场"), DataUnit.data_unit[self.model.shelfData.base_id].name))
        end
    end
end

function ExquisiteShelfManager:ShowTeamUp()
    if self.model.shelfData.wave ~= self.firstWave then
        return
    end
    local info = {
        Desc = string.format(TI18N("恭喜您！击败了外阁%s位宝阁王者，<color='#00ff00'>玲珑内阁</color>已开启，是否进入？（内阁王者拥有强大实力）"), self.firstWave),
        Mtxt = TI18N("确 定"),
        MCallback = function() self:GotoTransport() end,
    }
    TipsManager.Instance.model:ShowTeamUp(info)
end

function ExquisiteShelfManager:CreateNpc()
    local mapId = SceneManager.Instance:CurrentMapId()
    if mapId == self.firstMapId or mapId == self.secondMapId then
        local npcList = SceneManager.Instance.sceneElementsModel:GetSceneData_Npc()
        for _,npc in ipairs(npcList) do
            npc.exclude_outofview = true
            local key = BaseUtils.get_unique_npcid(npc.id, npc.battleid)
            local npcdata = SceneManager.Instance.sceneElementsModel:GetSceneData_OneNpc(key)
            SceneManager.Instance.sceneElementsModel:CreateNpc(key,npcdata,nil)
        end
    end
end

function ExquisiteShelfManager:GetCurrentShelfLev()
    local beg = 1
    for index,v in pairs(DataExquisiteShelf.data_group) do
        if v.max_lev >= RoleManager.Instance.RoleData.lev and RoleManager.Instance.RoleData.lev >= v.min_lev then
            beg = index
        end
    end
    return beg
end

function ExquisiteShelfManager:ShowText(str)
    if self.textPanel == nil then
        self.textPanel = ExquisiteShelfIcon.New(ctx.CanvasContainer)
    end
    self.textPanel:Show(str)
end


function ExquisiteShelfManager:BeginFight(type)
    if type == 63 then
        self:DisappearText(30)
    end
end
