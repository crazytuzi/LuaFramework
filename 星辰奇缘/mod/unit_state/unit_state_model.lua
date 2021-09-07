-- ------------------------------
-- 场景单位存活状态
-- hosr
-- ------------------------------

UnitStateModel = UnitStateModel or BaseClass(BaseModel)

function UnitStateModel:__init()
    self.sceneListener = function() self:OnMapLoaded() end
    self.sceneListener1 = function() self:UnitListUpdate() end
    self.mapid = 0
    self.lasttarget = 0
end

function UnitStateModel:__delete()
end

function UnitStateModel:OpenStatePanel(args)
	if self.statePanel == nil then
		self.statePanel = UnitStatePanel.New(self)
	end
	self.statePanel:Show(args)
end

function UnitStateModel:CloseStatePanel()
	if self.statePanel ~= nil then
		self.statePanel:DeleteMe()
		self.statePanel = nil
	end
end

-- battle_id =- 17
function UnitStateModel:FindStar(mapid)
	self.mapid = mapid
	self.find_baseid = 1
    if SceneManager.Instance:CurrentMapId() == mapid then
        self:GoToRandom()
    else
        EventMgr.Instance:RemoveListener(event_name.scene_load, self.sceneListener)
        EventMgr.Instance:RemoveListener(event_name.npc_list_update, self.sceneListener1)
        EventMgr.Instance:AddListener(event_name.scene_load, self.sceneListener)
        EventMgr.Instance:AddListener(event_name.npc_list_update, self.sceneListener1)
       	SceneManager.Instance.sceneElementsModel:Self_Transport(mapid, 0, 0)
    end
end

function UnitStateModel:FindRobber()
	self.mapid = 30001
	self.find_baseid = 2
    if SceneManager.Instance:CurrentMapId() == 30001 then
        self:GoToRandomRobber()
    else
        EventMgr.Instance:RemoveListener(event_name.scene_load, self.sceneListener)
        EventMgr.Instance:RemoveListener(event_name.npc_list_update, self.sceneListener1)
        EventMgr.Instance:AddListener(event_name.scene_load, self.sceneListener)
        EventMgr.Instance:AddListener(event_name.npc_list_update, self.sceneListener1)
		Connection.Instance:send(11128, {})
    end
end

function UnitStateModel:FindFox(mapid)
    self.mapid = mapid
    self.find_baseid = 3
    if SceneManager.Instance:CurrentMapId() == mapid then
        self:GoToRandom(UnitStateEumn.Type.Fox)
    else
        EventMgr.Instance:RemoveListener(event_name.scene_load, self.sceneListener)
        EventMgr.Instance:RemoveListener(event_name.npc_list_update, self.sceneListener1)
        EventMgr.Instance:AddListener(event_name.scene_load, self.sceneListener)
        EventMgr.Instance:AddListener(event_name.npc_list_update, self.sceneListener1)
        SceneManager.Instance.sceneElementsModel:Self_Transport(mapid, 0, 0)
    end
end

function UnitStateModel:FindCold(mapid,data,mount)
    self.mount = mount
    self.data = data
    self.mapid = mapid
    self.find_baseid = 5
    if SceneManager.Instance:CurrentMapId() == mapid then
        self:GoToCold(data)
    else
        EventMgr.Instance:RemoveListener(event_name.scene_load, self.sceneListener)
        EventMgr.Instance:RemoveListener(event_name.npc_list_update, self.sceneListener1)
        EventMgr.Instance:AddListener(event_name.scene_load, self.sceneListener)
        EventMgr.Instance:AddListener(event_name.npc_list_update, self.sceneListener1)
        SceneManager.Instance.sceneElementsModel:Self_Transport(mapid, 0, 0)
    end
end

function UnitStateModel:GoToCold(data)
    self.find_baseid = nil
    -- NoticeManager.Instance:FloatTipsByString(TI18N("金钱狐就在某个地方，快去挑战他吧！{face_1,38}"))

    SceneManager.Instance:Send10120()
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()

    math.randomseed(tostring(os.time()):reverse():sub(1,6))
    local count = math.random(1,self.mount)
    print(data[count].id)
    print(data[count].battleid)
    local key = BaseUtils.get_unique_npcid(data[count].id,data[count].battle_id)
    local nowData = data[count]
    DataWorldNpc.data_world_npc[key] = {}

    DataWorldNpc.data_world_npc[key].battleid = nowData.battle_id
    DataWorldNpc.data_world_npc[key].id = nowData.id
    DataWorldNpc.data_world_npc[key].baseid = nowData.base_id
    DataWorldNpc.data_world_npc[key].mapbaseid = nowData.map_id
    DataWorldNpc.data_world_npc[key].posx = nowData.x
    DataWorldNpc.data_world_npc[key].posy = nowData.y
    SceneManager.Instance.sceneElementsModel:Self_AutoPath(self.mapid,key)
end

function UnitStateModel:FindStarTrial(mapid)
    self.mapid = mapid
    self.find_baseid = 6
    if SceneManager.Instance:CurrentMapId() == mapid then
        self:GoToStarTrial()
    else
        EventMgr.Instance:RemoveListener(event_name.scene_load, self.sceneListener)
        -- EventMgr.Instance:RemoveListener(event_name.npc_list_update, self.sceneListener1)
        EventMgr.Instance:AddListener(event_name.scene_load, self.sceneListener)
        -- EventMgr.Instance:AddListener(event_name.npc_list_update, self.sceneListener1)
        SceneManager.Instance.sceneElementsModel:Self_Transport(mapid, 0, 0)
    end
end

function UnitStateModel:FindMoonStar(mapid)
    self.mapid = mapid
    self.find_baseid = 7
    if SceneManager.Instance:CurrentMapId() == mapid then
        self:GoToMoonStar()
    else
        EventMgr.Instance:RemoveListener(event_name.scene_load, self.sceneListener)
        -- EventMgr.Instance:RemoveListener(event_name.npc_list_update, self.sceneListener1)
        EventMgr.Instance:AddListener(event_name.scene_load, self.sceneListener)
        -- EventMgr.Instance:AddListener(event_name.npc_list_update, self.sceneListener1)
        SceneManager.Instance.sceneElementsModel:Self_Transport(mapid, 0, 0)
    end
end

function UnitStateModel:OnMapLoaded()
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.sceneListener)
    if self.find_baseid == 1 then
        self:GoToRandom()
    elseif self.find_baseid == 3 then
        self:GoToRandom(UnitStateEumn.Type.Fox)
    elseif self.find_baseid == 6 then
        self:GoToStarTrial()
    elseif self.find_baseid == 7 then
        self:GoToMoonStar()
    else
        self:GoToRandomRobber()
    end
end

function UnitStateModel:UnitListUpdate()
    EventMgr.Instance:RemoveListener(event_name.npc_list_update, self.sceneListener1)
    if self.find_baseid == 1 then
        self:GoToRandom()
    elseif self.find_baseid == 3 then
        self:GoToRandom(UnitStateEumn.Type.Fox)
    elseif self.find_baseid == 5 then
        self:GoToCold(self.data)
    elseif self.find_baseid == 6 then
        self:GoToStarTrial()
    elseif self.find_baseid == 7 then
        self:GoToMoonStar()
    else
    	self:GoToRandomRobber()
    end
end

function UnitStateModel:GoToRandomRobber()
    self.find_baseid = nil

    EventMgr.Instance:RemoveListener(event_name.scene_load, self.sceneListener)
    EventMgr.Instance:RemoveListener(event_name.npc_list_update, self.sceneListener1)

    for uniqueid,npcView in pairs(SceneManager.Instance.sceneElementsModel.NpcView_List) do
        if string.sub(uniqueid, -2, -1) == "_6" and npcView.data.status ~= 2 then
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_AutoPath(self.mapid, uniqueid)
            return
        end
    end
    for uniqueid,npcData in pairs(SceneManager.Instance.sceneElementsModel.WaitForCreateUnitData_List) do
        if string.sub(uniqueid, -2, -1) == "_6" and npcData.status ~= 2 then
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_AutoPath(self.mapid, uniqueid)
            return
        end
    end
end

-- 随机找一个非战斗的星
function UnitStateModel:GoToRandom(Unit_type)
    self.find_baseid = nil
    local battle_id = "_17"
    if Unit_type == UnitStateEumn.Type.Fox then
        battle_id = "_50"
    end
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.sceneListener)
    EventMgr.Instance:RemoveListener(event_name.npc_list_update, self.sceneListener1)
    local temp = {}
    local units = SceneManager.Instance.sceneElementsModel:GetSceneData_Npc()
    for k,v in pairs(units) do
        if string.find(v.uniqueid, battle_id) ~= nil and v.status ~= 2 then
            table.insert(temp, v.uniqueid)
        end
    end
    -- for uniqueid,npcView in pairs(SceneManager.Instance.sceneElementsModel.NpcView_List) do
    --     if string.find(uniqueid, "_17") ~= nil and npcView.data.status ~= 2 then
    --         table.insert(temp, uniqueid)
    --         -- SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
    --         -- SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
    --         -- SceneManager.Instance.sceneElementsModel:Self_AutoPath(self.mapid, uniqueid)
    --         -- return
    --     end
    -- end

    -- for uniqueid,npcData in pairs(SceneManager.Instance.sceneElementsModel.WaitForCreateUnitData_List) do
    --     if string.find(uniqueid, "_17") ~= nil and npcData.status ~= 2 then
    --         table.insert(temp, uniqueid)
    --         -- SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
    --         -- SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
    --         -- SceneManager.Instance.sceneElementsModel:Self_AutoPath(self.mapid, uniqueid)
    --         -- return
    --     end
    -- end
    local randval = Random.Range(1, #temp)
    if temp[randval] ~= nil then
        if self.lasttarget == temp[randval] then
            if #temp > 1 then
                if randval+1 > #temp then
                    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
                    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
                    SceneManager.Instance.sceneElementsModel:Self_AutoPath(self.mapid, temp[1])
                    self.lasttarget = temp[1]
                else
                    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
                    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
                    SceneManager.Instance.sceneElementsModel:Self_AutoPath(self.mapid, temp[randval+1])
                    self.lasttarget = temp[randval+1]
                end
            else
                SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
                SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
                SceneManager.Instance.sceneElementsModel:Self_AutoPath(self.mapid, temp[randval])
                self.lasttarget = temp[randval]
            end
        else
            self.lasttarget = temp[randval]
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_AutoPath(self.mapid, temp[randval])
        end
        return
    end
    -- 都在战斗就随便一只
    for uniqueid,npcView in pairs(SceneManager.Instance.sceneElementsModel.NpcView_List) do
        if string.find(uniqueid, battle_id) ~= nil then
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_AutoPath(self.mapid, uniqueid)
            return
        end
    end

    for uniqueid,npcData in pairs(SceneManager.Instance.sceneElementsModel.WaitForCreateUnitData_List) do
        if string.find(uniqueid, battle_id) ~= nil then
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_AutoPath(self.mapid, uniqueid)
            return
        end
    end
end

function UnitStateModel:GoToStarTrial()
    self.find_baseid = nil
    NoticeManager.Instance:FloatTipsByString(TI18N("银月贤者就在某个地方，快去拜访吧{face_1,25}"))
end

function UnitStateModel:GoToMoonStar()
    self.find_baseid = nil
    NoticeManager.Instance:FloatTipsByString(TI18N("幻月灵兽就在某个地方，快去拜访吧{face_1,25}"))
end

function UnitStateModel:Layout(hasHead)
	MainUIManager.Instance.noticeView:MoveActiceNotice(hasHead)
end
