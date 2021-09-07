-- --------------------------
-- 子女任务
-- hosr
-- --------------------------
QuestChild = QuestChild or BaseClass()

function QuestChild:__init()
    self.find_baseid = nil

    self.sceneListener = function() self:OnMapLoaded() end
    self.sceneListener1 = function() self:UnitListUpdate() end
end

function QuestChild:__delete()
    EventMgr.Instance:RemoveListener(event_name.map_click, self.clickMapListener)
end

function QuestChild:OnMapLoaded()
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.sceneListener)
    LuaTimer.Add(1000, function()
        self:GoToSpecial(self.find_baseid)
    end)
end

function QuestChild:UnitListUpdate()
    EventMgr.Instance:RemoveListener(event_name.npc_list_update, self.sceneListener1)
    LuaTimer.Add(1000, function()
        self:GoToSpecial(self.find_baseid)
    end)
end

function QuestChild:FindSpecialUnit(task)
    -- if task.sec_type == QuestEumn.TaskType.child then
    if SceneManager.Instance:CurrentMapId() == 30012 or SceneManager.Instance:CurrentMapId() == 30013 then
        self:GoToSpecial(self.find_baseid)
    else
        EventMgr.Instance:AddListener(event_name.scene_load, self.sceneListener)
        EventMgr.Instance:AddListener(event_name.npc_list_update, self.sceneListener1)
        HomeManager.Instance:EnterHome()
    end
    -- end
end

function QuestChild:GoToSpecial(baseid)
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.sceneListener)
    EventMgr.Instance:RemoveListener(event_name.npc_list_update, self.sceneListener1)
    if self.find_baseid == 0 then
        self:GoToBed()
        self.find_baseid = nil
        return
    end
    self.find_baseid = nil


    for uniqueid,_ in pairs(SceneManager.Instance.sceneElementsModel.NpcView_List) do
        if string.find(uniqueid, tostring(baseid)) ~= nil then
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_AutoPath(SceneManager.Instance:CurrentMapId(), uniqueid)
            return
        end
    end
    for uniqueid,_ in pairs(SceneManager.Instance.sceneElementsModel.WaitForCreateUnitData_List) do
        if string.find(uniqueid, tostring(baseid)) ~= nil then
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_AutoPath(SceneManager.Instance:CurrentMapId(), uniqueid)
            return
        end
    end
end

function QuestChild:GoToBed()
    -- BaseUtils.dump(HomeManager.Instance.model.furniture_list, "家具列表")
    if not TeamManager.Instance:IsSelfCaptin() then
        return
    end
    local finished = function()
        QuestManager.Instance:Send10244()
    end
    local prepare = function()
        SceneManager.Instance.sceneElementsModel.collection.callback = finished
        SceneManager.Instance.sceneElementsModel.collection:Show({msg = TI18N("准备中..."), time = 2000})
    end
    for k,v in pairs(HomeManager.Instance.model.furniture_list) do
        local baseData = DataFamily.data_unit[v.base_id]
        if baseData.type == 10 then
            if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
                SceneManager.Instance.sceneElementsModel.self_view.moveEnd_CallBack = prepare
            end
            local posi = SceneManager.Instance.sceneModel:transport_small_pos(v.x, v.y)
            SceneManager.Instance.sceneElementsModel:Self_MoveToPoint(posi.x, posi.y)
            return
        end
    end
    NoticeManager.Instance:FloatTipsByString(TI18N("哥们，没床啊，你想在地板上完事？"))
end

function QuestChild:NpcState()
    local tempNpc = nil
    local tempData = nil
    for uniqueid,npcView in pairs(SceneManager.Instance.sceneElementsModel.NpcView_List) do
        if string.find(uniqueid, tostring(71150)) ~= nil then
            npcView.data.honorType = 0
            npcView:change_honor()
            tempNpc = npcView
        end
    end
    for uniqueid,data in pairs(SceneManager.Instance.sceneElementsModel.WaitForCreateUnitData_List) do
        if string.find(uniqueid, tostring(71150)) ~= nil then
            data.honorType = 0
            tempData = data
        end
    end

    local questData = QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.branch)
    if questData ~= nil then
        if tempNpc ~= nil then
            if questData.finish == QuestEumn.TaskStatus.CanAccept and questData.npc_accept == 71150 then
                tempNpc.data.honorType = 1
            elseif questData.finish == QuestEumn.TaskStatus.Finish and questData.npc_commit == 71150 then
                tempNpc.data.honorType = 2
            else
                tempNpc.data.honorType = 0
            end
            tempNpc:change_honor()
        elseif tempData ~= nil then
            if questData.finish == QuestEumn.TaskStatus.CanAccept and questData.npc_accept == 71150 then
                tempData.honorType = 1
            elseif questData.finish == QuestEumn.TaskStatus.Finish and questData.npc_commit == 71150 then
                tempData.honorType = 2
            else
                tempData.honorType = 0
            end
        end
    end
end