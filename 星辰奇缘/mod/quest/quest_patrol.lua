-- ------------------------------
-- 任务巡逻
-- hosr
-- ------------------------------
QuestPatrol = QuestPatrol or BaseClass()

function QuestPatrol:__init()
    self.patroling = false
    self.patrol_id = 0
    self.points = nil
    self.patrol_index = 0
    self.isfight = false

    self.sceneListener = function() self:TransportEnd() end
    self.beginFightListener = function() self:BeginFight() end
    self.endFightListener = function() self:EndFight() end
    self.cancalListener = function() self:CancelPatrol() end

    self.comming = false
end

function QuestPatrol:__delete()
end

-- 不在当前地图的先传送
function QuestPatrol:DoPatrol(map, points)
    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Follow then
        NoticeManager.Instance:FloatTipsByString(TI18N("在队伍跟随中,无法巡逻"))
        return
    end

    if points == nil then
        self:CancelPatrol()
        return
    end

    self.comming = true
    self.map = map
    self.points = points

    if SceneManager.Instance:CurrentMapId() ~= map then
        self:Transport()
    else
        self:BeginPatrol()
    end
end

function QuestPatrol:Transport()
    EventMgr.Instance:AddListener(event_name.scene_load, self.sceneListener)
    if self.map == 30001 then
        -- 公会地图要通过独立协议进入
        Connection.Instance:send(11128, {})
    else
        SceneManager.Instance.sceneElementsModel:Self_Transport_After_Clean(self.map, 0, 0)
    end
end

function QuestPatrol:TransportEnd()
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.sceneListener)
    LuaTimer.Add(500, function() self:BeginPatrol() end)
end

--执行巡逻
function QuestPatrol:BeginPatrol()

    if RoleManager.Instance.RoleData.status == RoleEumn.Status.Fight then
        -- NoticeManager.Instance:FloatTipsByString("战斗状态下,无法巡逻")
        return
    end

    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Follow then
        NoticeManager.Instance:FloatTipsByString(TI18N("在队伍跟随中,无法巡逻"))
        return
    end

    if self.points == nil then
        return
    end

    print(" ============== BeginPatrol ================")
    EventMgr.Instance:RemoveListener(event_name.begin_fight, self.beginFightListener)
    EventMgr.Instance:AddListener(event_name.begin_fight, self.beginFightListener)

    self.patroling = true

    local len = #self.points
    --取到不一样点
    math.randomseed(os.time())
    local ok = false
    local count = 0
    local index = self.patrol_index
    while count < 5 and index == self.patrol_index do
        count = count + 1
        index = math.random(1, len)
    end
    if self.patrol_index == index then
        --这样随机都一样，日了狗了
        self.patrol_index = self.patrol_index + 1

        if self.patrol_index > len then
            self.patrol_index = 1
        end
    else
        self.patrol_index = index
    end

    local pos = self.points[self.patrol_index]
    pos = SceneManager.Instance.sceneModel:transport_small_pos(pos[1], pos[2])

    if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
        SceneManager.Instance.sceneElementsModel.self_view.moveEnd_CallBack = function() self:MoveEnd() end
    end
    SceneManager.Instance.sceneElementsModel:Self_MoveToPoint(pos.x, pos.y)
    EventMgr.Instance:AddListener(event_name.map_click, self.cancalListener)
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(3)
end

function QuestPatrol:BeginFight()
    self.isfight = true
    if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
        SceneManager.Instance.sceneElementsModel.self_view:StopMoveTo()
    end
    self:CancelPatrol()
end

function QuestPatrol:EndFight(type, result)
    self.isfight = false
end

function QuestPatrol:MoveEnd()
    -- print("===============  QuestPatrol:MoveEnd  ================")
    if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
        SceneManager.Instance.sceneElementsModel.self_view.moveEnd_CallBack = nil
    end
    self:BeginPatrol()
end

--取消巡逻
function QuestPatrol:CancelPatrol()
    -- print("============= CancelPatrol ===========")
    if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
        SceneManager.Instance.sceneElementsModel.self_view.moveEnd_CallBack = nil
    end
    EventMgr.Instance:RemoveListener(event_name.map_click, self.cancalListener)
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.sceneListener)
    EventMgr.Instance:RemoveListener(event_name.begin_fight, self.beginFightListener)
    EventMgr.Instance:RemoveListener(event_name.end_fight, self.endFightListener)
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(4)
    self.patrol_id = 0
    self.points = nil
    self.patrol_index = 0
    self.comming = false
end