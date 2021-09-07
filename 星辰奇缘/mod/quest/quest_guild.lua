-- --------------------------------
-- 公会任务特殊处理脚本
-- hosr
-- --------------------------------
QuestGuild = QuestGuild or BaseClass()

function QuestGuild:__init()
    self.find_baseid = nil

    self.sceneListener = function() self:OnMapLoaded() end
    self.sceneListener1 = function() self:UnitListUpdate() end

    self.sceneListener2 = function() self:OnMapLoadedForPlantFlower() end
    self.sceneListener3 = function() self:UnitListUpdateForPlantFlower() end
    self.posData = nil

    self.reachTargeCallbackInGuildArea = function ()
        self:ReachTargeCallbackInGuildArea()
    end
    self.reachGuildAreaCallback = function ()
        return self:ReachGuildAreaCallback()
    end

    self.lastPublicityIndex = -1

    self.clickMapListener = function ()
        self:onClickMap()
    end
    EventMgr.Instance:AddListener(event_name.map_click, self.clickMapListener)
end

function QuestGuild:__delete()
    EventMgr.Instance:RemoveListener(event_name.map_click, self.clickMapListener)
end

function QuestGuild:OnMapLoaded()
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.sceneListener)
    self:GoToSpecial(self.find_baseid)
end

function QuestGuild:UnitListUpdate()
    EventMgr.Instance:RemoveListener(event_name.npc_list_update, self.sceneListener1)
    self:GoToSpecial(self.find_baseid)
end

function QuestGuild:FindSpecialUnit(task)
    if task.sec_type == QuestEumn.TaskType.guild then
        --公会任务
        if SceneManager.Instance:CurrentMapId() == 30001 then
            self:GoToSpecial(self.find_baseid)
        else
            EventMgr.Instance:AddListener(event_name.scene_load, self.sceneListener)
            EventMgr.Instance:AddListener(event_name.npc_list_update, self.sceneListener1)
            QuestManager.Instance:Send(11128, {})
        end
    end
end

function QuestGuild:GoToSpecial(baseid)
    self.find_baseid = nil

    EventMgr.Instance:RemoveListener(event_name.scene_load, self.sceneListener)
    EventMgr.Instance:RemoveListener(event_name.npc_list_update, self.sceneListener1)

    for uniqueid,_ in pairs(SceneManager.Instance.sceneElementsModel.NpcView_List) do
        if string.find(uniqueid, tostring(baseid)) ~= nil then
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_AutoPath(30001, uniqueid)
            return
        end
    end
    for uniqueid,_ in pairs(SceneManager.Instance.sceneElementsModel.WaitForCreateUnitData_List) do
        if string.find(uniqueid, tostring(baseid)) ~= nil then
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_AutoPath(30001, uniqueid)
            return
        end
    end
end

function QuestGuild:onClickMap()
    --GuildManager.Instance:request11163()
    NoticeManager.Instance:HideGuildPublicity()
end
--公会宣读任务
function QuestGuild:Publicity(questData,progress)
    -- BaseUtils.dump(questData, "QuestGuild:Publicity--questData")
    --BaseUtils.dump(progress, "QuestGuild:Publicity--progress")
    local nextOrder = progress.value + 1

    if nextOrder <= DataQuestGuild.data_publicity_length then
        local publicityData = DataQuestGuild.data_publicity[nextOrder]
        local randomIndex = Random.Range(1,#publicityData.points+1)

        if GuildManager.Instance.randomIndex == -1 then
            while self.lastPublicityIndex == randomIndex do
                randomIndex = Random.Range(1,#publicityData.points+1)
            end
            self.lastPublicityIndex = randomIndex
            GuildManager.Instance.randomIndex = randomIndex
        end
        local mapXY = publicityData.points[GuildManager.Instance.randomIndex]
        --Log.Error(string.format("----=====%s %s %s",mapXY[1],mapXY[2],mapXY[3]))
        self.fun = function ()
            if SceneManager.Instance.sceneElementsModel.self_view == nil then
                return
            end
            -- 打开宣读道具快速使用窗口
            local pos = SceneManager.Instance.sceneElementsModel.self_view.gameObject.transform.position
            local curPos = SceneManager.Instance.sceneModel:transport_big_pos(pos.x,pos.y)
            local dis = Vector2.Distance(curPos,Vector2(mapXY[2],mapXY[3]))
            --Log.Error(string.format("----%s %s %s %s %s %s",mapXY[2],mapXY[3],pos.x,pos.y,curPos.x,curPos.y))
            --Log.Error(dis)
            if dis < 10 then
                --Log.Error("到达宣读地点")
                if self.autoData == nil then
                    self.autoData = AutoUseData.New()
                end
                self.autoData.callback = function()
                    --进行宣读
                    --Log.Error("发协议到后端 进行宣读")
                    --GuildManager.Instance:request11163()
                    self.newItem = nil
                    self.autoData = nil
                    GuildManager.Instance:ShowPublicityCollection(2000)
                end
                if self.newItem == nil then
                    self.newItem = ItemData.New()
                end
                self.newItem:SetBase(DataItem.data_get[20099])
                self.autoData.itemData = self.newItem
                self.autoData.title = TI18N("公会宣读")
                self.autoData.label = TI18N("宣 读")
                NoticeManager.Instance:GuildPublicity(self.autoData)

                -- local data = NoticeConfirmData.New()
                -- data.type = ConfirmData.Style.Sure
                -- data.content = "种花%s后"
                -- data.contentSecond = 12 * 60 * 60
                -- data.sureLabel = "公会求助"
                -- -- data.cancelLabel = "取消"
                -- data.sureCallback = function ()
                --     print("公会求助")
                -- end
                -- --data.cancelCallback = self.sureMatch
                -- NoticeManager.Instance:ConfirmTips(data)
            else
                --Log.Error("未到达，切场景回调")
                --SceneManager.Instance.sceneElementsModel.self_view.moveEnd_CallBack = self.fun
            end
        end
        SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
        SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
        SceneManager.Instance.sceneElementsModel:Self_AutoPath(mapXY[1],nil, mapXY[2],mapXY[3],true,self.fun)
    end
end

function QuestGuild:OnMapLoadedForPlantFlower()
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.sceneListener2)
    self:goToPlantInGuildArea()
end

function QuestGuild:UnitListUpdateForPlantFlower()
    EventMgr.Instance:RemoveListener(event_name.npc_list_update, self.sceneListener3)
    self:goToPlantInGuildArea()
end

--公会种花
function QuestGuild:PlantFlower()
    GuildManager.Instance:request11169()
end

function QuestGuild:GoPlantFlower(battleid,uid)
    self.battleidPF = battleid
    self.uidPF = uid
    if battleid == 0 and uid == 0 then --自己没有种花
        if SceneManager.Instance:CurrentMapId() == 30001 then
            self:goToPlantInGuildArea()
        else
            EventMgr.Instance:AddListener(event_name.scene_load, self.sceneListener2)
            EventMgr.Instance:AddListener(event_name.npc_list_update, self.sceneListener3)
            QuestManager.Instance:Send(11128, {})
        end
    else --自己有种花
        if self.posData == nil then
            GuildManager.Instance.gotoGuildAreaModel:GoToGuildAreaThenDoSomething(battleid,uid,nil,self.reachTargeCallbackInGuildArea,self.reachGuildAreaCallback)
        else
            GuildManager.Instance.gotoGuildAreaModel:GoToGuildAreaThenDoSomething(battleid,uid,self.posData,self.reachTargeCallbackInGuildArea,self.reachGuildAreaCallback)
        end
    end
end

function QuestGuild:ReachGuildAreaCallback()
    local unitEleList = SceneManager.Instance.sceneElementsModel:GetSceneData_Npc()
    for i,v in ipairs(unitEleList) do
        if v.battleid == self.battleidPF and v.id == self.uidPF then
           if v.baseid == 70111 then
                self.posData = {x = v.x,y = v.y}
                -- BaseUtils.dump(self.posData,"self.posData==in=")
                self:RemoveFlower(self.uidPF,self.battleidPF)
           end
           break
        end
    end
    -- BaseUtils.dump(self.posData,"self.posData===")
    return self.posData
end

function QuestGuild:ReachTargeCallbackInGuildArea()
    --自己已种过花
    if self.posData == nil then --种过的花未成熟
        GuildManager.Instance:request11166(self.battleidPF,self.uidPF)
    else --种过的花已成熟
        -- SceneManager.Instance.sceneElementsModel:RemoveNpc(BaseUtils.get_unique_npcid(posData.id,posData.battleid))
        self:goToPlantInGuildArea()
    end
end

function QuestGuild:RemoveFlower(uid,battleid)
    if uid ~= 0 and battleid ~= 0 then
        SceneManager.Instance.sceneElementsModel:RemoveNpc(BaseUtils.get_unique_npcid(uid,battleid))
    end
end

function QuestGuild:goToPlantInGuildArea()
    local pos = self:checkPFPos()
    -- if posTemp ~= nil then
    --     SceneManager.Instance.sceneElementsModel:RemoveNpc(BaseUtils.get_unique_npcid(posTemp.id,posTemp.battleid))
    -- end
    if pos ~= nil then
        SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
        SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
        SceneManager.Instance.sceneElementsModel:Self_AutoPath(30001,nil, pos.x,pos.y,true,function ()
            local autoData = AutoUseData.New()
            autoData.callback = function()
                --显示种花读条
                GuildManager.Instance:ShowPlantFlowerCollection(2000,pos)
            end
            local newItem = ItemData.New()
            newItem:SetBase(DataItem.data_get[20100])
            autoData.itemData = newItem
            autoData.title = TI18N("公会种花")
            autoData.label = TI18N("种 花")
            NoticeManager.Instance:GuildPublicity(autoData)
        end)
    end
end

function QuestGuild:checkPFPos()
    local pos = nil
    local unitEleList = SceneManager.Instance.sceneElementsModel:GetSceneData_Npc()
    local times = 1
    local isGetPos = true
    local posListCanPlantFlower = {}

    for index,vpos in ipairs(DataQuestGuild.data_plantpos) do
        isGetPos = true
        for i,v in ipairs(unitEleList) do
            -- BaseUtils.dump(v,string.format("index=%d, i=%d",index,i))
            if v.x == vpos.x and v.y == vpos.y then
                isGetPos = false
                break
            end
        end
        if isGetPos == true then
            -- pos = vpos
            table.insert(posListCanPlantFlower,vpos)
            break
        end
    end
    if #posListCanPlantFlower == 0 then --没有空的种花点
        local posListOpen = {}
        for i,v in ipairs(unitEleList) do
            if v.baseid == 70111 then
               table.insert(posListOpen,v)
            end
        end
        if #posListOpen == 0 then
            NoticeManager.Instance:FloatTipsByString(TI18N("公会种花的地点已满，请有空缺后再来"))
        else
            --顶掉盛开的花的点
            if self.posData ~= nil then
                for i,v in ipairs(posListOpen) do
                    if v.x == self.posData.x and v.y == self.posData.y then
                        pos = self.posData
                    end
                end
            end
            if pos == nil then
                local vv = Random.Range(1,#posListOpen+1)
                pos = posListOpen[vv]
                self.posData = {x = pos.x, y = pos.y}
                -- BaseUtils.dump(pos,"pos-----------")
                -- self:RemoveFlower(pos.id,pos.battleid)
            end
        end
        -- pos = DataQuestGuild.data_plantpos[Random.Range(1,DataQuestGuild.data_plantpos_length+1)]
    else
        if self.posData ~= nil then
            for i,v in ipairs(posListCanPlantFlower) do
                if v.x == self.posData.x and v.y == self.posData.y then
                    pos = self.posData
                end
            end
        end
        if pos == nil then
            pos = posListCanPlantFlower[Random.Range(1,#posListCanPlantFlower+1)]
            self.posData = pos
        end
    end
    -- BaseUtils.dump(pos,"pos===")
    return pos
end

function QuestGuild:NpcState()
    local tempNpc = nil
    local tempData = nil
    for uniqueid,npcView in pairs(SceneManager.Instance.sceneElementsModel.NpcView_List) do
        if string.find(uniqueid, tostring(20032)) ~= nil then
            npcView.data.honorType = 0
            npcView:change_honor()
            tempNpc = npcView
        end
    end
    for uniqueid,data in pairs(SceneManager.Instance.sceneElementsModel.WaitForCreateUnitData_List) do
        if string.find(uniqueid, tostring(20032)) ~= nil then
            data.honorType = 0
            tempData = data
        end
    end

    local questData = QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.guild)
    if questData ~= nil then
        if tempNpc ~= nil then
            if questData.finish == QuestEumn.TaskStatus.CanAccept and questData.npc_accept == 20032 then
                tempNpc.data.honorType = 1
            elseif questData.finish == QuestEumn.TaskStatus.Finish and questData.npc_commit == 20032 then
                tempNpc.data.honorType = 2
            else
                tempNpc.data.honorType = 0
            end
            tempNpc:change_honor()
        elseif tempData ~= nil then
            if questData.finish == QuestEumn.TaskStatus.CanAccept and questData.npc_accept == 20032 then
                tempData.honorType = 1
            elseif questData.finish == QuestEumn.TaskStatus.Finish and questData.npc_commit == 20032 then
                tempData.honorType = 2
            else
                tempData.honorType = 0
            end
        end
    end
end