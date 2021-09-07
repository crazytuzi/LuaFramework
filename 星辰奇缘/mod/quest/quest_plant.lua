-- -----------------------------
-- 种植任务处理脚本
-- hosr
-- -----------------------------
QuestPlant = QuestPlant or BaseClass()

function QuestPlant:__init(model)
    self.model = model
    self.sceneLoad = function() self:OnSceneLoad() end
    self.clickMap = function() self:OnClickMap() end
end

function QuestPlant:DoQuest(questData)
    -- if QuestManager.Instance.plantData == nil then
        -- QuestManager.Instance:Send10224()
    -- else
        if QuestManager.Instance.plantData.phase == 0 then
            -- 未种植, 传送
            if SceneManager.Instance:CurrentMapId() ~= QuestManager.Instance.plantData.map then
                EventMgr.Instance:AddListener(event_name.scene_load, self.sceneLoad)
                self:Transpot()
            else
                self:TranspotEnd()
            end
        else
            local key = BaseUtils.get_unique_npcid(QuestManager.Instance.plantData.unit_id, 0)
            self.model:FindNpc(key)
        end
    -- end
end

function QuestPlant:OnClickMap()
    EventMgr.Instance:RemoveListener(event_name.map_click, self.clickMap)
    if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
        SceneManager.Instance.sceneElementsModel.self_view.moveEnd_CallBack = nil
    end
end

function QuestPlant:OnSceneLoad()
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.sceneLoad)
    self:TranspotEnd()
end

function QuestPlant:Transpot()
    SceneManager.Instance.sceneElementsModel:Self_Transport(QuestManager.Instance.plantData.map, 0, 0)
end

function QuestPlant:TranspotEnd()
    EventMgr.Instance:AddListener(event_name.map_click, self.clickMap)
    if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
        SceneManager.Instance.sceneElementsModel.self_view.moveEnd_CallBack = function() self:MoveEnd() end
    end
    local pos = SceneManager.Instance.sceneModel:transport_small_pos(QuestManager.Instance.plantData.x - 100, QuestManager.Instance.plantData.y - 100)
    SceneManager.Instance.sceneElementsModel:Self_MoveToPoint(pos.x, pos.y)
end

function QuestPlant:MoveEnd()
    -- 快速使用
    EventMgr.Instance:RemoveListener(event_name.map_click, self.clickMap)
    if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
        SceneManager.Instance.sceneElementsModel.self_view.moveEnd_CallBack = nil
    end
    local item = ItemData.New()
    item:SetBase(DataItem.data_get[29988])
    local autoData = AutoUseData.New()
    autoData.callback = function() self:Plant() end
    autoData.itemData = item
    NoticeManager.Instance:GuildPublicity(autoData)
end

function QuestPlant:Plant()
    SceneManager.Instance.sceneElementsModel.collection.callback = function() QuestManager.Instance:Send10225() end
    SceneManager.Instance.sceneElementsModel.collection:Show({msg = TI18N("种植中.."), time = 2000})
end
