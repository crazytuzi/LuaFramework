--在GuildManager里面初始化
GuildGotoGuildArea = GuildGotoGuildArea or BaseClass(BaseModel)

function GuildGotoGuildArea:__init()
    self.sceneListener2 = function() self:OnMapLoadedForPlantFlower() end
    self.sceneListener3 = function() self:UnitListUpdateForPlantFlower() end

    self.bittleId = nil --单位战场ID
    self.id = nil --单位ID
    self.pos = nil --坐标

    self.reachThenCallBack = nil --到达后回调函数
    self.reachGuildAreaCallBack = nil --去到公会领地，就回调
end

function GuildGotoGuildArea:__delete()

end
function GuildGotoGuildArea:OnMapLoadedForPlantFlower()
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.sceneListener2)
    self:ReachAreaThenGoToTarge()
end

function GuildGotoGuildArea:UnitListUpdateForPlantFlower()
    EventMgr.Instance:RemoveListener(event_name.npc_list_update, self.sceneListener3)
    self:ReachAreaThenGoToTarge()
end

--去公会领域
--battle_id 单位战场ID ; uid 单位ID
--pos  坐标
--callbackFun 到达的回调函数
--reachGuildAreaCallBack 到达公会领地回调
function GuildGotoGuildArea:GoToGuildAreaThenDoSomething(battle_id,uid,pos,callbackFun,reachGuildAreaCallBack)
    self.bittleId = battle_id --单位战场ID
    self.id = uid --单位ID
    self.pos = pos --坐标
    self.reachThenCallBack = callbackFun --到达后回调函数
    self.reachGuildAreaCallBack = reachGuildAreaCallBack

    if SceneManager.Instance:CurrentMapId() == 30001 then
        self:ReachAreaThenGoToTarge()
    else
        EventMgr.Instance:AddListener(event_name.scene_load, self.sceneListener2)
        EventMgr.Instance:AddListener(event_name.npc_list_update, self.sceneListener3)
        QuestManager.Instance:Send(11128, {})
    end
end

function GuildGotoGuildArea:ReachAreaThenGoToTarge()
    if self.reachGuildAreaCallBack ~= nil then
        self.pos = self.reachGuildAreaCallBack()
    end
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
    if self.pos ~=  nil then
        SceneManager.Instance.sceneElementsModel:Self_AutoPath(30001,nil, self.pos.x,self.pos.y,true,self.reachThenCallBack)
    else
        local key = BaseUtils.get_unique_npcid(self.id, self.bittleId)
        SceneManager.Instance.sceneElementsModel:Self_MoveToTarget(key)
    end
end

