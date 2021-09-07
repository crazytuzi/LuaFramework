QuestModel = QuestModel or BaseClass(BaseModel)

function QuestModel:__init()
    self.mgr = QuestManager.Instance

    -- 记录上次做的任务的类型
    self.lastType = 0
    -- 记录上次任务做什么类型
    self.lastClilabel = 0

    -- 是否直接飞到npc旁边
    self.direct_to_npc = false

    -- 任务巡逻,处理脚本
    self.questPatrol = QuestPatrol.New(self)
    -- 公会任务处理脚本
    self.questGuild = QuestGuild.New(self)
    -- 种植任务
    self.questPlant = QuestPlant.New(self)
    -- 子女任务
    self.questChild = QuestChild.New(self)

    -- npc头顶状态
    self.npcStateTab = {}

    self.assetWrapper = nil
    self.finishEffect = nil

    self.continueOffer = function()
        QuestManager.Instance.offerCome20 = false
        self:DoOffer()
    end
    self.cancelOffer = function() self.lastType = 0 end

    self.cycleNpc = {20, 21, 22, 23, 24}

    self.sureGetDouble = function() AgendaManager.Instance:Require12002() end

    self.sureTreasure = function()
        self:DoTreasuremap()
    end

    EventMgr.Instance:AddListener(event_name.npc_list_update, function() self:NpcListUpdate() end)

    self.lastGuidePetWash = nil

    self.timerIdForSeekChildNpc = 0
    self.timerIdForDefenseCakeNpc = 0

end

function QuestModel:__delete()
end

-- ------------------------------------------------------
-- 根据上次做的任务的类型来自动做下一个相同类型的任务
-- 1、这除了指引和支线任务外的，都会在更新任务时检查是否自动继续跑任务
-- 2、所以在 1 的前提下，相同类型的任务只有一个
-- ------------------------------------------------------
function QuestModel:Auto()
    if RoleManager.Instance.RoleData.drama_status == RoleEumn.DramaStatus.Running then
        Log.Debug("剧情中，无法自动跑任务")
        return
    end
    if RoleManager.Instance.RoleData.status == RoleEumn.Status.Fight then
        Log.Debug("战斗中，无法自动跑任务")
        return
    end
    if NoticeManager.Instance:HasAuto() then
        Log.Debug("快速使用，无法自动跑任务")
        return
    end

    -- 取到该类型当前的任务数据
    if self.lastType == 0 then
        Log.Debug("没有上次任务类型")
        return
    end

    local questData = self.mgr:GetQuestByType(self.lastType)
    Log.Debug("继续上次类型的任务sec_type="..self.lastType)

    if not self:CheckAuto(questData) then
        return
    end

    if not self:CheckSatiationOk(questData) then
        Log.Debug("饱食度为0，不自动跑悬赏")
        return
    end

    if self.lastType == QuestEumn.TaskType.offer and TeamManager.Instance:MyStatus() ~= RoleEumn.TeamStatus.Leader then
        Log.Debug("悬赏任务只有队长可以跑")
        return
    end

    Log.Debug("自动跑任务咯~~~")
    self:DoIt(questData, true)
end

-- 检查是否满足自动跑条件
function QuestModel:CheckAuto(quest)
    if quest ~= nil then
        if quest.auto_next == QuestEumn.AutoNext.AllYes then
            --全部执行
            return true
        elseif quest.auto_next == QuestEumn.AutoNext.AllNot then
            --全部不执行
            return false
        else
            if quest.auto_next == QuestEumn.AutoNext.NotAccept and quest.finish == QuestEumn.TaskStatus.CanAccept then
                --不去接
                return false
            elseif quest.auto_next == QuestEumn.AutoNext.NotForward and quest.finish == QuestEumn.TaskStatus.Doing then
                --不去做第一步
                --不去做在多步的情况下是第一步不去做
                if quest.id == 10084 or quest.id == 22084 then
                    return false
                end

                local sp = quest.progress_ser[1]
                if sp ~= nil and sp.finish ~= 1 then
                    return false
                end
                return true
            elseif quest.auto_next == QuestEumn.AutoNext.NotCommit and quest.finish == QuestEumn.TaskStatus.Finish then
                --不去提
                return false
            elseif quest.auto_next == QuestEumn.AutoNext.JustAccept then
                --只去接
                if quest.finish == QuestEumn.TaskStatus.CanAccept then
                    return true
                else
                    return false
                end
            else
                --执行
                return true
            end
        end
    end
    return true
end

-- 做指定任务id的任务
function QuestModel:DoIt(questData, auto)
    print("接取任务？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？")
    BaseUtils.dump(questData,"任务啊任务")
    AutoRunManager.Instance:ClearTime()

    QuestManager.Instance.offerCome20 = false

    if GuildManager.Instance.collection.running == true then
        GuildManager.Instance.collection:Cancel()
    end

    if questData == nil then
        return
    end

    if questData.id == 10000 or questData.id == 22000 then
        GuideManager.Instance:Finish()
    end

    -- if questData.sec_type == QuestEumn.TaskType.main then
    --     if questData.id == 22102 and questData.finish == 2 then
    --          WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rideChooseWindow,{})
    --     end
    -- end

    if questData.sec_type ~= QuestEumn.TaskType.cycle
        and questData.sec_type ~= QuestEumn.TaskType.guide
        and questData.sec_type ~= QuestEumn.TaskType.offer
        and questData.sec_type ~= QuestEumn.TaskType.treasuremap then
        if self:CheckCross() then
            return
        end
    end

    if RoleManager.Instance.RoleData.lev < questData.find_lev then
        if questData.find_lev_tips == "" then
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("要到%s级才能去做哦"), tostring(questData.find_lev)))
        else
            NoticeManager.Instance:FloatTipsByString(questData.find_lev_tips)
        end
        return
    end

    self.lastType = questData.sec_type
    Log.Debug("<color='#fff000'>跑类型的任务</color>sec_type="..self.lastType)

    self.lastClilabel = QuestManager.Instance:GetQuestCurrentLabel(questData)
    Log.Debug("上一次的Clilabel＝")
    Log.Debug(self.lastClilabel)

    -- inserted by 嘉俊
    -- print("**************"..questData.sec_type)
    if questData.sec_type == QuestEumn.TaskType.cycle or  questData.sec_type == QuestEumn.TaskType.chain then
        if TeamManager.Instance:MyStatus() ~= RoleEumn.TeamStatus.Follow then
            if questData.sec_type == QuestEumn.TaskType.chain then
                AutoQuestManager.Instance.model:AutoQuestSetting(1) -- 1 表示历练环
            else
                AutoQuestManager.Instance.model:AutoQuestSetting(2) -- 2 表示职业任务
            end
            -- if questData.sec_type == QuestEumn.TaskType.chain  then
            --     if AutoQuestManager.Instance.model.hasTreasureOfChain == 1 or AutoQuestManager.Instance.model.lockAuto then
            --         return
            --     end
            -- end
            if QuestManager.Instance.model.round_chain ~= 100 and  QuestManager.Instance.model.round_chain ~= 200 then
                AutoQuestManager.Instance.autoQuest:Fire()
            end
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("正在队伍跟随中"))
        end
    end
    -- end by 嘉俊

    -- 根据任务状态处理到npc处交接，或者做任务要求的内容
    local key = self:GetKey(questData)
    if key == "" then
        return
    end

    if RoleManager.Instance.RoleData.drama_status == RoleEumn.DramaStatus.Running then
        Log.Debug("剧情中，无法跑任务 1")
        return
    end

    if RoleManager.Instance.RoleData.status == RoleEumn.Status.Fight then
        Log.Debug("战斗中，无法跑任务 1")
        return
    end

    if questData ~= nil then
        MainUIManager.Instance:HideEffect(questData)
    end

    -- 根据得到的key寻路到场景目标交接或执行任务
    self:FindNpc(key)
end

function QuestModel:GetKey(questData)
    local key = ""
    local team_ok = TeamManager.Instance:CanRun()

    self.mgr.find_baseid = nil
    self.direct_to_npc = false
    if questData.finish == 0 and team_ok then
        --接取
        key = BaseUtils.get_unique_npcid(questData.npc_accept_id, questData.npc_accept_battle)
        --职业任务，除了第一环之外，其他的都不回到npc处接取
        if questData.sec_type == QuestEumn.TaskType.cycle then
            if self.mgr.time_cycle == self.mgr.time_cycle_max and self.mgr.round_cycle == 1 then
                --第二轮，第一环，要手动接取，处理为传送到npc，并打开对话框
                self.direct_to_npc = true
                return key
            else
                if self.mgr.round_cycle ~= 1 then
                    local data = {baseid = questData.npc_accept, id = questData.npc_accept_id}
                    key = ""
                    MainUIManager.Instance:OpenDialog(data)
                    return key
                end
            end
        end
    elseif questData.finish == 2 then
        --提交
        key = ""
        if questData.sec_type == QuestEumn.TaskType.kill then
            -- windows.open_window(windows.panel.taskstar)
            return key
        elseif questData.sec_type == QuestEumn.TaskType.guide then
            -- 指引任务完成了到面板提交
            if questData.progress ~= nil and #questData.progress == 0 then
                key = BaseUtils.get_unique_npcid(questData.npc_commit_id, questData.npc_commit_battle)
                return key
            end
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.biblemain, {2, questData.id})
            return key
        elseif questData.sec_type == QuestEumn.TaskType.chain then
            -- 任务链提交npc去统计数据
            if QuestManager.Instance.chainUnitId == 0 or QuestManager.Instance.chainBattleId == 0 then
                key = ""
                self.mgr:Send10206(questData.id)
            else
                key = BaseUtils.get_unique_npcid(QuestManager.Instance.chainUnitId, QuestManager.Instance.chainBattleId)
            end
            return key
        else
            if questData.npc_commit == 71150 then
                -- 家园特殊处理
                key = ""
                self.questChild.find_baseid = questData.npc_commit
                self.questChild:FindSpecialUnit(questData)
                return key
            elseif questData.npc_commit_id == 0 then
                if questData.sec_type == QuestEumn.TaskType.guild and team_ok then
                    --公会任务，公会地图里面的npc只能用baseid去找啊   日了狗
                    self.questGuild.find_baseid = questData.npc_commit
                    self.questGuild:FindSpecialUnit(questData)
                    return key
                elseif questData.sec_type == QuestEumn.TaskType.couple or questData.sec_type == QuestEumn.TaskType.ambiguous or questData.sec_type == QuestEumn.TaskType.teacher then
                    if team_ok then
                        self.mgr:Send10206(questData.id)
                    end
                    return key
                elseif questData.sec_type == QuestEumn.TaskType.king then
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.quest_king_progress)
                    return ""
                else
                    self.mgr:Send10206(questData.id)
                    return key
                end
            elseif team_ok then
                key = BaseUtils.get_unique_npcid(questData.npc_commit_id, questData.npc_commit_battle)
                local normal = function()
                    if questData.commit_type == 1 then
                        --npc处提交
                    elseif questData.commit_type == 2 then--直接打开面板提交
                        local data = {baseid = questData.npc_commit, id = questData.npc_commit_id}
                        key = ""
                        MainUIManager.Instance:OpenDialog(data)
                    end
                end
                normal()
                return key
            end
        end
    elseif questData.finish == 1 then
        --进行中
        key = BaseUtils.get_unique_npcid(questData.npc_commit_id, questData.npc_commit_battle)
        local ok = false
        for i,sp in ipairs(questData.progress_ser) do
            local cp = questData.progress[i]
            if cp.cli_label == QuestEumn.CliLabel.patrol and team_ok then
                --职业任务，巡逻类型
                key = ""
                self.patrol_id = questData.id
                local map = sp.ext_data[1].value
                local points = nil
                if questData.sec_type == QuestEumn.TaskType.guild then
                    points = DataQuestGuild.data_patrol[string.format("%d_%d", self.patrol_id, map)].points
                elseif questData.sec_type == QuestEumn.TaskType.cycle then
                    points = DataQuestClasses.data_patrol[string.format("%d_%d", self.patrol_id, map)].points
                elseif questData.sec_type == QuestEumn.TaskType.teacher then
                    points = DataQuestTeacher.data_patrol[string.format("%d_%d", self.patrol_id, map)].points
                elseif questData.sec_type == QuestEumn.TaskType.fineType then
                    points = DataQuestPursue.data_patrol[string.format("%d_%d", self.patrol_id, map)].points
                elseif questData.sec_type == QuestEumn.TaskType.child then
                    points = DataQuestChild.data_patrol[string.format("%d_%d", self.patrol_id, map)].points
                elseif questData.sec_type == QuestEumn.TaskType.childbreed then
                    points = DataQuestPregnancy.data_patrol[string.format("%d_%d", self.patrol_id, map)].points
                elseif questData.sec_type == QuestEumn.TaskType.king then
                    points = DataQuestKing.data_path[self.patrol_id].points
                end
                self.questPatrol:DoPatrol(map, points)
                return key
            elseif cp.cli_label == QuestEumn.CliLabel.publicity then --公会宣传
                self.questGuild:Publicity(questData,sp)
                key = ""
                return key
            elseif cp.cli_label == QuestEumn.CliLabel.rideChoose then --新手坐骑任务
                RideManager.Instance:Send17026(1)
                key = ""
                return key
            elseif cp.cli_label == QuestEumn.CliLabel.guild_plantflower then --公会种花
                self.questGuild:PlantFlower()
                key = ""
                return key
            elseif cp.cli_label == QuestEumn.CliLabel.fight and questData.sec_type == QuestEumn.TaskType.chain then
                -- 任务链的战斗npc要从服务端进度扩展数据里面取
                for i,v in ipairs(sp.ext_data) do
                    if v.key == QuestEumn.ExtType.TargetNpcId then
                        QuestManager.Instance.chainFightNpcId = v.value
                        key = BaseUtils.get_unique_npcid(v.value, 1)
                        return key
                    end
                end
            elseif cp.cli_label == QuestEumn.CliLabel.couple_answer then
                -- 伴侣答题
                QuestMarryManager.Instance:Send15400()
                return ""
            elseif cp.cli_label == QuestEumn.CliLabel.ambiguous_answer then
                -- 情缘答题
                QuestMarryManager.Instance:Send15700()
                return ""
            elseif cp.cli_label == QuestEumn.CliLabel.teacher_answer then
                -- 师徒答题
                QuestMarryManager.Instance:Send16100(self.mgr.teacher_question)
                return ""
            elseif cp.cli_label == QuestEumn.CliLabel.couple_flower then
                -- 伴侣送花
                local role = RoleManager.Instance.RoleData
                GivepresentManager.Instance:OpenGiveWin({id = role.lover_id , zone_id = role.lover_zone_id, platform = role.lover_platform, index = 2})
                return ""
            elseif cp.cli_label == QuestEumn.CliLabel.plant_tree then
                -- 种植
                key = ""
                self.questPlant:DoQuest(questData)
                return key
            elseif cp.cli_label == QuestEumn.CliLabel.goto_bed then
                key = ""
                self.questChild.find_baseid = 0
                self.questChild:FindSpecialUnit(questData)
                return key
            elseif cp.cli_label == QuestEumn.CliLabel.guild_talk then --公会说话
                ChatManager.Instance.model:ShowChatWindow({MsgEumn.ChatChannel.Guild})
                key = ""
                return key
            else

                if sp.finish ~= 1 then
                    local ss = StringHelper.MatchBetweenSymbols(cp.msg, "%[", "%]")[1]
                    if questData.sec_type == QuestEumn.TaskType.kill and team_ok then
                        key = ""
                        return key
                    end


                    local iswin = false
                    if ss ~= nil and ss ~= "" then
                        local args = StringHelper.Split(ss, ",")  --args(lab操作，面板id，...(打开面板时的参数))
                        local arg1 = tonumber(args[1])
                        local arg2 = tonumber(args[2])
                        local ll = {}
                        for i = 3, #args do
                            if ll == nil then ll = {} end
                            table.insert(ll, tonumber(args[i]))
                        end
                        if arg1 == QuestEumn.LabelAct.panel then
                            key = ""
                            iswin = true
                            if #ll == 0 then
                                ll = nil
                            end
                            WindowManager.Instance:OpenWindowById(arg2, ll)
                        elseif arg1 == QuestEumn.LabelAct.gohome then
                            self.questChild.find_baseid = arg2
                            self.questChild:FindSpecialUnit(questData)
                            key = ""
                            return key
                        else
                            if cp.cli_label == QuestEumn.CliLabel.fight and RoleManager.Instance.RoleData.lev <= 15 then
                                -- 15级前要杀的怪物有按钮的做下引导
                                local unitData = DataUnit.data_unit[tonumber(sp.target)]
                                if unitData ~= nil and #unitData.buttons > 0 then
                                    self.mgr.guideKillId = unitData.id
                                end
                                key = BaseUtils.get_unique_npcid(arg2, arg1)
                            elseif cp.cli_label == QuestEumn.CliLabel.gain or cp.cli_label == QuestEumn.CliLabel.catchpet then
                                -- 是寻物和捕虫的任务，同时配置带有npc寻路参数的才把目标加入到参数列表里面给功能定位具体项
                                if questData.sec_type == QuestEumn.TaskType.child then
                                    for i,v in ipairs(sp.ext_data) do
                                        if v.key == QuestEumn.ExtType.ItemType and v.value == BackpackEumn.ItemType.embryo then
                                            key = ""
                                            self.questChild.find_baseid = 71150
                                            self.questChild:FindSpecialUnit(questData)
                                            return key
                                        end
                                    end
                                end

                                if #ll > 0 then
                                    table.insert(ll, sp.target)
                                    self.mgr.taskArgs = ll
                                end
                                key = BaseUtils.get_unique_npcid(arg2, arg1)
                            else
                                key = BaseUtils.get_unique_npcid(arg2, arg1)
                            end

                        end
                    end

                    if RoleManager.Instance.RoleData.lev < 100 and iswin == false and cp.cli_label == QuestEumn.CliLabel.levelup then
                        key = self:NeedLevelUp()
                        return key
                    end
                    if RoleManager.Instance.RoleData.lev < cp.target_val and cp.cli_label == QuestEumn.CliLabel.levelup then
                        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>%s级</color>才再来哦，看看<color='#ffff00'>日程</color>里有什么可完成的{face_1,16}"), cp.target_val))
                        return key
                    end
                    break
                end
            end
        end
    end

    return key
end

-- 接取了某个任务
function QuestModel:AcceptOne(id)
    local task = QuestManager.Instance.questTab[id]
    -- BaseUtils.dump(task,"QuestModel:AcceptOne")
    if task == nil then
        return
    end
    if task.sec_type == QuestEumn.TaskType.offer then --and self.lastType ~= QuestEumn.TaskType.offer then
        -- 提示双倍点数
        self.lastType = QuestEumn.TaskType.offer
        self:ShowDobulePointNotice()
        if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader and QuestManager.Instance.round_offer ~= 20 then
            -- 第一次接悬赏的处理,其他的会有任务更新进行自动跑
            if self:CheckSatiationOk(task) then
                self:DoIt(task)
            end
        end
    elseif task.sec_type == QuestEumn.TaskType.child then
        BackpackManager.Instance:ReLoadAutoList()
        -- base_id == 23801 or base_id == 23802 or base_id == 23803
    elseif task.sec_type == QuestEumn.TaskType.guild and self.lastType ~= QuestEumn.TaskType.guild then
        self:DoIt(task)
    elseif task.sec_type == QuestEumn.TaskType.treasuremap and self.lastType ~= QuestEumn.TaskType.treasuremap then
        self:DoIt(task)
    elseif task.sec_type == QuestEumn.TaskType.chain then
        -- 任务链,接受完任务后显示对白
        QuestManager.Instance.chainFightNpcId = QuestManager.Instance:GetChainFightTarget(task)
        LuaTimer.Add(200, function() self:ShowChainDialog(task) end)
    elseif task.sec_type == QuestEumn.TaskType.couple or task.sec_type == QuestEumn.TaskType.ambiguous or task.sec_type == QuestEumn.TaskType.teacher then
        -- 伴侣任务上一个是对话的就自动寻路
        if self.lastClilabel == QuestEumn.CliLabel.visit then
            if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
                self:DoIt(task)
            end
        end
    elseif task.sec_type == QuestEumn.TaskType.plant then
        local base = nil
        if QuestManager.Instance.round_plant == 2 then
            local baseId = QuestEumn.PlantBaseId[QuestManager.Instance.plantData.phase]
            base = BaseUtils.copytab(DataUnit.data_unit[baseId])
            base.plot_talk = TI18N("祈福之树种子已经种下了，赶紧替他<color='#00ff00'>浇水</color>吧{face_1,2}")
        elseif QuestManager.Instance.round_plant == 1 then
            base = BaseUtils.copytab(DataUnit.data_unit[32023])
            base.buttons = {}
            base.plot_talk = TI18N("三月植树节，快来种植祈福之树<color='#00ff00'>祈福之树，传递绿光，播种希望</color>吧！这里有一袋希望之种和种植道具，祈福之树成熟结出果实后可<color='#ffff00'>呼朋唤友</color>组队来采摘的话，会有<color='#ffff00'>经验加成</color>哦{face_1,38}")
        elseif QuestManager.Instance.round_plant == 6 then
            base = BaseUtils.copytab(DataUnit.data_unit[QuestEumn.PlantBaseId[3]])
            base.plot_talk = TI18N("祈福植树结出果实啦，快来采摘吧，如果你能<color='#ffff00'>叫上伙伴</color>组队来的话，会有<color='#ffff00'>经验加成</color>哦{face_1,29}")
        end

        if base ~= nil then
            MainUIManager.Instance.dialogModel:SetAnywayCallback(function() self:DoPlant() end)
            MainUIManager.Instance:OpenDialog({id = QuestManager.Instance.plantData.unit_id, baseid = baseId}, {base = base}, true, true)
        end
    elseif task.sec_type == QuestEumn.TaskType.seekChild then
        --捉迷藏
        SummerManager.Instance.model:NpcState()

        local questData = DataQuest.data_get[task.id]
        -- print("捉迷藏")
        if questData ~= nil and questData.follow_npc ~= 0 then
            local dataInfo = SummerManager.Instance.npcDataSeekChild[questData.follow_npc]
            if dataInfo ~= nil then
                local battleId = dataInfo.battle_id
                local unitId = dataInfo.u_id
                local baseId = dataInfo.base_id
                local x = dataInfo.x
                local y = dataInfo.y
                local mapId = dataInfo.map
                -- --取出单位配置数据
                local baseData = DataUnit.data_unit[dataInfo.base_id]
                self.npcIdTemp = dataInfo.base_id
                -- --组装单位场景key id
                local uniquenpcid = BaseUtils.get_unique_npcid(dataInfo.u_id, dataInfo.battle_id)

                --模拟场景单位数据
                local data = {
                    battle_id = battleId,
                    id = unitId,
                    base_id = baseId,
                    type = baseData.type,
                    name = baseData.name,
                    status = 0,
                    guide_lev = 0,
                    speed = RoleManager.Instance.RoleData.speed,
                    x = x,
                    y = y,
                    gx = 0,
                    gy = 0,
                    looks = {},
                    prop = {},
                    is_virtual = false,
                    no_click = true,

                    -- dir = SceneConstData.UnitFaceToIndex[dir + 1],
                    -- sex = sex,
                    -- classes = classes,
                    -- action = SceneConstData.UnitActionStr[act],
                    -- no_hide = true,
                }

                local npc = NpcData.New()
                npc:update_data(data)
                npc.extData = {honorid = 0}

                -- 在当前场景就创建，不在就只记录下来
                if mapId == SceneManager.Instance:CurrentMapId() then
                    -- print("setFollowNpcData")
                    SceneManager.Instance.sceneElementsModel:setFollowNpcData(npc)

                    if self.timerIdForSeekChildNpc ~= 0 then
                        LuaTimer.Delete(self.timerIdForSeekChildNpc)
                        self.timerIdForSeekChildNpc = 0
                    end
                    self.timerIdForSeekChildNpc = LuaTimer.Add(1000, 20000, function()
                        --
                        -- BaseUtils.dump(SceneManager.Instance.sceneElementsModel.follow_npc_view,"follow_npc_view")
                        if SceneManager.Instance.sceneElementsModel.follow_npc_view ~= nil then
                            local msgsTemp = BaseUtils.split(DataCampHideSeek.data_child_unit[self.npcIdTemp].following_words,"|")
                            if msgsTemp ~= nil and #msgsTemp > 0 then
                                local indexTemp = math.random(1,#msgsTemp)
                                SceneTalk.Instance:ShowTalk_NPC(SceneManager.Instance.sceneElementsModel.follow_npc_view.data.id,
                                    SceneManager.Instance.sceneElementsModel.follow_npc_view.data.battle_id,msgsTemp[indexTemp],5)
                            else
                                if self.timerIdForSeekChildNpc ~= 0 then
                                    LuaTimer.Delete(self.timerIdForSeekChildNpc)
                                    self.timerIdForSeekChildNpc = 0
                                end
                            end
                        end
                    end)
                end
            end
        end
    elseif task.sec_type == QuestEumn.TaskType.defensecake then
        self.lastType = QuestEumn.TaskType.defensecake
        local questData = DataQuest.data_get[task.id]
        self:CreateDefenseCakeNpc(questData)
    end

    -- if task.id == 10040 then
    --     GuideManager.Instance:Start(10004)
    -- elseif task.id == 10084 then
    --     GuideManager.Instance:Start(10005)
    if task.sec_type == QuestEumn.TaskType.guild then
        DramaManager.Instance.model:JustPlayPlot(task.id)
    elseif task.sec_type == QuestEumn.TaskType.defensecake then
        DramaManager.Instance.model:JustPlayPlot(task.id, function()
            self:DoIt(task)
        end)
    elseif task.sec_type == QuestEumn.TaskType.acquaintance then
        DramaManager.Instance.model:JustPlayPlot(task.id, function()
            self:DoIt(task)
        end)
    end
end

-- 完成某个任务
function QuestModel:FinishOne(questData)
    if questData.sec_type ~= QuestEumn.TaskType.guide then
        local needDoMain = false
        if questData.id == 10300 or questData.id == 22300 then
            -- 宠物洗髓引导
            local func = function()
                local id = PetManager.Instance.model:getpetid_bybaseid(10003)
                if id ~= nil and id ~= 0 then
                    PetManager.Instance:Send10501(id, 1)
                end
                self.lastGuidePetWash = nil
                QuestManager.Instance.autoRun = true
                WindowManager.Instance:CloseWindowById(WindowConfig.WinID.pet)
                QuestManager.Instance:DoMain()
                PetManager.Instance.model:ClosepetWashWindow()
                PetManager.Instance.model:ClosePetWindow()
            end

            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Sure
            if self.lastGuidePetWash ~= nil then
                local petData,_ = PetManager.Instance.model:getpet_byid(PetManager.Instance.model:getpetid_bybaseid(10003))
                local newGuidePetWash = petData.talent
                data.content = string.format(TI18N("恭喜！通过洗髓花莹评分从<color='#ffff00'>%s</color>提升至<color='#ffff00'>%s</color>{face_1,18}"), self.lastGuidePetWash, newGuidePetWash)
                data.sureLabel = TI18N("确定")
                data.sureCallback = func
                NoticeManager.Instance:ConfirmTips(data)
                return
            else
                needDoMain = true
            end
        end
        if questData.sec_type == QuestEumn.TaskType.seekChild then
            --捉迷藏
            if questData.id == 81241 or questData.id == 81242 then
                local pos = SceneManager.Instance.sceneElementsModel.self_data
                -- BaseUtils.dump(pos,"============")
                EffectBrocastManager.Instance:On9907({id = 30074,type = 0,map = SceneManager.Instance:CurrentMapId(),x = pos.x,y = pos.y})
            end
            -- print("捉迷藏end")
            -- if questData ~= nil and questData.follow_npc ~= 0 then
            --     SceneManager.Instance.sceneElementsModel:setFollowNpcData(nil)
            --     if self.timerIdForSeekChildNpc ~= 0 then
            --         LuaTimer.Delete(self.timerIdForSeekChildNpc)
            --         self.timerIdForSeekChildNpc = 0
            --     end
            -- end
        elseif questData.sec_type == QuestEumn.TaskType.acquaintance then
            --结缘任务
            if questData.id == 83300 or questData.id == 83301 or questData.id == 83302 or questData.id == 83303 then
                local pos = SceneManager.Instance.sceneElementsModel.self_data
                -- BaseUtils.dump(pos,"============")
                EffectBrocastManager.Instance:On9907({id = 30074,type = 0,map = SceneManager.Instance:CurrentMapId(),x = pos.x,y = pos.y})
            end
        end

        for i,cp in ipairs(questData.progress) do
            -- 查看是否有这个任务打开的面板
            local ss = StringHelper.MatchBetweenSymbols(cp.msg, "%[", "%]")[1]
            if ss ~= nil and ss ~= "" then
                local args = StringHelper.Split(ss, ",")
                local arg1 = tonumber(args[1])
                local arg2 = tonumber(args[2])
                local arg3 = tonumber(args[3])
                if arg1 == QuestEumn.LabelAct.panel and questData.id ~= 22222 then
                    if arg2 == WindowConfig.WinID.biblemain then
                        LuaTimer.Add(8000, function() WindowManager.Instance:CloseWindowById(arg2) end)
                    else
                        WindowManager.Instance:CloseWindowById(arg2)
                    end
                end
            end

            if WindowManager.Instance.currentWin ~= nil then
                if cp.cli_label == QuestEumn.CliLabel.catchpet then
                    if WindowManager.Instance.currentWin.windowId == WindowConfig.WinID.market then
                        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.market)
                    end
                elseif cp.cli_label == QuestEumn.CliLabel.gain then
                    if WindowManager.Instance.currentWin.windowId == WindowConfig.WinID.market then
                        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.market)
                    elseif WindowManager.Instance.currentWin.windowId == WindowConfig.WinID.npcshop then
                        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.npcshop)
                    end
                elseif cp.cli_label == QuestEumn.CliLabel.petfight then
                    --宠物出战选中要操作的宠物
                    if WindowManager.Instance.currentWin.windowId == WindowConfig.WinID.pet then
                        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.pet)
                    end
                elseif cp.cli_label == QuestEumn.CliLabel.couple_flower then
                    -- 送花任务完成关掉送花面板
                    if WindowManager.Instance.currentWin.windowId == WindowConfig.WinID.giftwindow then
                        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.giftwindow)
                    end
                elseif cp.cli_label == QuestEumn.CliLabel.couple_answer then
                    -- 答题完成
                    -- QuestMarryManager.Instance:ClosePanel()
                elseif cp.cli_label == QuestEumn.CliLabel.wing_lev then
                    -- 翅膀升级
                end
            end
        end

        if needDoMain then
            self:DoMain()
        end
    end

    -- if questData.sec_type == QuestEumn.TaskType.treasuremap then
        -- if QuestManager.Instance.round_treasure == 10 then
        --     QuestManager.Instance.round_treasure = 1

        --     local data = NoticeConfirmData.New()
        --     data.type = ConfirmData.Style.Normal
        --     data.content = "你已经完成了10环宝图任务，是否前往<color='#ffff00'>王大可</color>处继续领取?"
        --     data.sureLabel = "确定"
        --     data.cancelLabel = "取消"
        --     data.sureCallback = self.sureTreasure
        --     NoticeManager.Instance:ConfirmTips(data)
        -- end
    if questData.sec_type == QuestEumn.TaskType.offer then
        if QuestManager.Instance.round_offer == 1 then
            -- 如果队伍没满重新招募
            if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader and TeamManager.Instance.teamNumber < 5 then
                TeamManager.Instance.offerCheckSure()
            end
        end

        if QuestManager.Instance.round_offer == 10 then
            if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
                QuestManager.Instance.autoRun = false
                QuestManager.Instance.offerCome20 = true

                LuaTimer.Add(1000, function() self:DoOffer() end)

                -- local data = NoticeConfirmData.New()
                -- data.type = ConfirmData.Style.Normal
                -- data.content = "当前已经进行了10环悬赏，是否继续？"
                -- data.sureLabel = "确定"
                -- data.cancelLabel = "取消"
                -- data.sureCallback = self.continueOffer
                -- data.cancelCallback = self.cancelOffer
                -- NoticeManager.Instance:ConfirmTips(data)
            end
        end
    end

    if questData.id == self.patrol_id then
        self.questPatrol:CancelPatrol()
    end

    if questData.id == 10030 or questData.id == 22030 then
        DramaManagerCli.Instance:FirstPetShow()
    elseif questData.id == 41261 then
        LuaTimer.Add(100, function() EventMgr.Instance:Fire(event_name.guide_equip_stone_end) end)
    elseif questData.id == 22170 then
        GuideManager.Instance:Finish()
    end
end

-- 提交某个任务
function QuestModel:CommitOne(id)
    local task = DataQuest.data_get[id]
    if task == nil then
        return
    end
    -- if task.sec_type == QuestEumn.TaskType.cycle then
        --职业任务提交完成后，播放一个剧本
        -- if not (self.mgr.round_cycle == 0 and self.mgr.time_cycle == 2) then
            -- DramaManager.Instance.model:JustPlayPlot(task.id)
        -- end
    -- elseif task.sec_type == QuestEumn.TaskType.chain then
    if task.sec_type == QuestEumn.TaskType.chain then
        QuestManager.Instance.chainFightNpcId = 0
    elseif task.sec_type == QuestEumn.TaskType.plant and (QuestManager.Instance.plantData.phase >= 2 and QuestManager.Instance.plantData.phase < 4) or task.id == 81010 then
        self.lastType = 0
        local baseId = QuestEumn.PlantBaseId[QuestManager.Instance.plantData.phase]
        local base = DataUnit.data_unit[baseId]
        MainUIManager.Instance:OpenDialog({id = QuestManager.Instance.plantData.unit_id, baseid = baseId}, {base = base}, false, false, true)
    elseif task.sec_type == QuestEumn.TaskType.seekChild then
        --捉迷藏
        print("捉迷藏end")
        if task ~= nil and task.follow_npc ~= 0 then
            SceneManager.Instance.sceneElementsModel:setFollowNpcData(nil)
            if self.timerIdForSeekChildNpc ~= 0 then
                LuaTimer.Delete(self.timerIdForSeekChildNpc)
                self.timerIdForSeekChildNpc = 0
            end
        end
    end

    if id == 10030 or id == 22030 then
        LuaTimer.Add(800, function() DramaManagerCli.Instance:Jump() end)
    end
    local showData = DataQuest.data_show_reward[id]
    if showData ~= nil and #showData.plot_id == 0 then
        self:OpenShowEquipPanel(id)
    end
end

function QuestModel:OpenShowEquipPanel(id)
    NoticeManager.Instance:HideAutoUse()
    QuestManager.Instance.autoRun = false
    if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
        SceneManager.Instance.sceneElementsModel.self_view:StopMoveTo()
        SceneManager.Instance.sceneElementsModel.self_view:StopMoveTo()
    end
    if self.showEquipPanel == nil then
        self.showEquipPanel = TeamQuestShowEquipPanel.New(self,id)
    end
    self.showEquipPanel:Show()
end

function QuestModel:CloseShowEquipPanel()
    if self.showEquipPanel ~= nil then
        self.showEquipPanel:DeleteMe()
        self.showEquipPanel = nil
    end
    NoticeManager.Instance:ShowAutoUse()
    if not NoticeManager.Instance:HasAuto() then
        QuestManager.Instance.autoRun = true
        QuestManager.Instance:DoMain()
    end
end

-- 删除已接任务
function QuestModel:RemoveOne(questData)
    if questData ~= nil and questData.sec_type == QuestEumn.TaskType.defensecake then
        self:RemoveDefenseCakeNpc()
    end
end

function QuestModel:CreateDefenseCakeNpc(questData)
    if questData == nil or questData.follow_npc == 0 or self.timerIdForDefenseCakeNpc ~= 0 or SceneManager.Instance.sceneElementsModel.self_data == nil then
        return
    end

    local battleId = questData.follow_npc
    local unitId = questData.follow_npc
    local baseId = questData.follow_npc
    local x = SceneManager.Instance.sceneElementsModel.self_data.x
    local y = SceneManager.Instance.sceneElementsModel.self_data.y
    -- --取出单位配置数据
    local baseData = DataUnit.data_unit[questData.follow_npc]
    self.npcIdTemp = questData.follow_npc
    -- --组装单位场景key id
    local uniquenpcid = BaseUtils.get_unique_npcid(questData.follow_npc, questData.follow_npc)

    --模拟场景单位数据
    local data = {
        battle_id = battleId,
        id = unitId,
        base_id = baseId,
        type = baseData.type,
        name = baseData.name,
        status = 0,
        guide_lev = 0,
        speed = RoleManager.Instance.RoleData.speed,
        x = x,
        y = y,
        gx = 0,
        gy = 0,
        looks = {},
        prop = {},
        is_virtual = false,
        no_click = true,
    }

    local npc = NpcData.New()
    npc:update_data(data)
    npc.extData = {honorid = 0}

    SceneManager.Instance.sceneElementsModel:setFollowNpcData(npc)
    self.timerIdForDefenseCakeNpc = LuaTimer.Add(1000, 20000, function()
        if SceneManager.Instance.sceneElementsModel.follow_npc_view ~= nil then
            local dataFollow = DataCampCake.data_follow_unit[self.npcIdTemp]
            local msgsTemp = nil
            if dataFollow ~= nil then
                msgsTemp = BaseUtils.split(dataFollow.following_words,"|")
            end

            if msgsTemp ~= nil and #msgsTemp > 0 then
                local indexTemp = math.random(1,#msgsTemp)
                SceneTalk.Instance:ShowTalk_NPC(SceneManager.Instance.sceneElementsModel.follow_npc_view.data.id,
                SceneManager.Instance.sceneElementsModel.follow_npc_view.data.battle_id,msgsTemp[indexTemp],5)
            else
                if self.timerIdForDefenseCakeNpc ~= 0 then
                    LuaTimer.Delete(self.timerIdForDefenseCakeNpc)
                    self.timerIdForDefenseCakeNpc = 0
                end
            end
        end
    end)
end

function QuestModel:RemoveDefenseCakeNpc()
    SceneManager.Instance.sceneElementsModel:setFollowNpcData(nil)
    if self.timerIdForDefenseCakeNpc and self.timerIdForDefenseCakeNpc ~= 0 then
        LuaTimer.Delete(self.timerIdForDefenseCakeNpc)
        self.timerIdForDefenseCakeNpc = 0
    end
end

--更新npc状态
function QuestModel:NpcListUpdate()
    self:NpcState()
end

--记录有任务npc的状态 1:可接 2:完成
function QuestModel:NpcState()
    if SceneManager.Instance:CurrentMapId() == 30001 then
        self.npcStateTab = {}
        self.questGuild:NpcState()
        return
    elseif SceneManager.Instance:CurrentMapId() == 30012 or SceneManager.Instance:CurrentMapId() == 30013 then
        self.npcStateTab = {}
        self.questChild:NpcState()
        return
    end

    for _,uniqueid in ipairs(self.npcStateTab) do
        local npcView = SceneManager.Instance.sceneElementsModel.NpcView_List[uniqueid]
        if npcView ~= nil then
            npcView.data.honorType = 0
            npcView:change_honor()
        else
            local data = SceneManager.Instance.sceneElementsModel.WaitForCreateUnitData_List[uniqueid]
            if data ~= nil then
                data.honorType = 0
            end
        end
    end
    self.npcStateTab = {}
    for questId,quest in pairs(self.mgr.questTab) do
        local uniqueid = ""
        if quest.finish == QuestEumn.TaskStatus.CanAccept then
            uniqueid = BaseUtils.get_unique_npcid(quest.npc_accept_id, quest.npc_accept_battle)
            local npcView = SceneManager.Instance.sceneElementsModel.NpcView_List[uniqueid]
            if npcView ~= nil then
                npcView.data.honorType = 1
                npcView:change_honor()
            else
                local data = SceneManager.Instance.sceneElementsModel.WaitForCreateUnitData_List[uniqueid]
                if data ~= nil then
                    data.honorType = 1
                end
            end
            table.insert(self.npcStateTab, uniqueid)
        elseif quest.finish == QuestEumn.TaskStatus.Finish then
            if quest.sec_type == QuestEumn.TaskType.chain then
                uniqueid = BaseUtils.get_unique_npcid(QuestManager.Instance.chainUnitId, QuestManager.Instance.chainBattleId)
            else
                uniqueid = BaseUtils.get_unique_npcid(quest.npc_commit_id, quest.npc_commit_battle)
            end
            local npcView = SceneManager.Instance.sceneElementsModel.NpcView_List[uniqueid]
            if npcView ~= nil then
                npcView.data.honorType = 2
                npcView:change_honor()
            else
                local data = SceneManager.Instance.sceneElementsModel.WaitForCreateUnitData_List[uniqueid]
                if data ~= nil then
                    data.honorType = 2
                end
            end
            table.insert(self.npcStateTab, uniqueid)
        end
    end
end

function QuestModel:SceneLoad()
    self:NpcState()
end

-- 等级要求做任务处理
-- 有职业任务做职业任务，没有打开日程
function QuestModel:NeedLevelUp()
    NoticeManager.Instance:FloatTipsByString(TI18N("请先提升等级，<color='#ffff00'>职业任务</color>可获得大量经验哦{face_1,18}"))
    local questData = self.mgr:GetQuestByType(QuestEumn.TaskType.cycle)
    if questData ~= nil then
        MainUIManager.Instance:HideEffect(questData)
        self.lastType = QuestEumn.TaskType.cycle
        return self:GetKey(questData)
    else
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.agendamain)
        return ""
    end
    return ""
end

-- 做主线任务
function QuestModel:DoMain()
    local questData = self.mgr:GetQuestMain()
    if questData == nil then
        QuestManager.Instance:Send10211(QuestEumn.TaskType.practice)
    else
        self:DoIt(questData)
    end
end

-- 外部调用做公会任务接口
function QuestModel:DoGuild()
    local questData = self.mgr:GetQuestByType(QuestEumn.TaskType.guild)
    if questData ~= nil then
        self:DoIt(questData)
    else
        self.questGuild.find_baseid = 20032
        local task = DataQuest.data_get[80000]
        self.questGuild:FindSpecialUnit(task)
    end
end

-- 外部调用做悬赏任务接口
function QuestModel:DoOffer()
    local questData = self.mgr:GetQuestByType(QuestEumn.TaskType.offer)
    if questData ~= nil then
        self:DoIt(questData)
        --第20环开始的时候，增加是否好友判定增加队长好友
        if QuestManager.Instance.round_offer ~= 20 then
           return
        end
        if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
            return
        end
        local captinId = TeamManager.Instance.captinId
        if captinId == "" then
            return
        end
        if FriendManager.Instance.friend_List[captinId] ~= nil then
             return
        end
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = string.format(TI18N("队长<color='#ffff00'>%s</color>辛劳带队，加个好友吧"),TeamManager.Instance.captinData.name)
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = SceneManager.Instance.quitCenter
        data.blueSure = true
        data.greenCancel = true
        data.contentSecond = 10
        NoticeManager.Instance:ConfirmTips(data)
    else
        local key = "25_1"
        self:FindNpc(key)
    end
end

-- 外部调用做职业任务接口
function QuestModel:DoCycle()
    local questData = self.mgr:GetQuestByType(QuestEumn.TaskType.cycle)
    if questData ~= nil then
        self:DoIt(questData)
    else
        local key = string.format("%s_1", self.cycleNpc[RoleManager.Instance.RoleData.classes])
        -- inserted by 嘉俊 关闭自动职业任务
        if self.mgr.time_cycle == 1 and AutoQuestManager.Instance.model.isOpen then
            print("职业任务结束导致自动停止") -- 用来找bug的输出 by 嘉俊 2017/9/1
            AutoQuestManager.Instance.disabledAutoQuest:Fire()
        end
        -- end by 嘉俊
        self:FindNpc(key)
    end
end

-- 外部调用做宝图任务接口
function QuestModel:DoTreasuremap()
    local questData = self.mgr:GetQuestByType(QuestEumn.TaskType.treasuremap)
    if questData ~= nil then
        self:DoIt(questData)
    else
        local key = "30_1"
        self:FindNpc(key)
    end
end

-- 做任务链接口
function QuestModel:DoChain()
    local questData = self.mgr:GetQuestByType(QuestEumn.TaskType.chain)
    if questData ~= nil then
        self:DoIt(questData)
    else
        -- inserted by 嘉俊 处理自动历练任务中由于网络延迟导致空的问题
        if AutoQuestManager.Instance.model.isOpen then
            return
        end
        -- end by 嘉俊
        local key = "10036_1"
        self:FindNpc(key)
    end
end

-- 做伴侣任务
function QuestModel:DoCouple()
    local questData = self.mgr:GetQuestByType(QuestEumn.TaskType.couple)
    if questData ~= nil then
        self:DoIt(questData)
    else

        local key = "44_1"
        self:FindNpc(key)
    end
end

-- 做情缘任务
function QuestModel:DoAmbiguous()
    local questData = self.mgr:GetQuestByType(QuestEumn.TaskType.ambiguous)
    if questData ~= nil then
        self:DoIt(questData)
    else
        local key = "44_1"
        self:FindNpc(key)
    end
end

-- 做种植任务
function QuestModel:DoPlant()
    local questData = self.mgr:GetQuestByType(QuestEumn.TaskType.plant)
    if questData ~= nil then
        self:DoIt(questData)
    else
        local key = "32023_1"
        self:FindNpc(key)
    end
end

-- 师徒任务
function QuestModel:DoTeacher()
    local questData = self.mgr:GetQuestByType(QuestEumn.TaskType.teacher)
    if questData ~= nil then
        self:DoIt(questData)
    else
        local key = "47_1"
        self:FindNpc(key)
    end
end

function QuestModel:FindNpc(key)
    print("到达指定NPC")
    if self.questPatrol ~= nil and self.questPatrol.comming then
        self.questPatrol:CancelPatrol()
    end
    EventMgr.Instance:Fire(event_name.cancel_colletion)

    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Follow then
        print("跟随中")
        SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath_AndTopEffect()
        return
    end
    AutoFarmManager.Instance:stopFarm()
    AutoFarmManager.Instance:StopAncientDemons()
    HomeManager.Instance:CancelFindTree()
    print(string.format("开始寻路到npc=%s", key))
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
    SceneManager.Instance.sceneElementsModel:Self_PathToTarget(key)
end

function QuestModel:OpenWindow(args)
    if self.questWindow == nil then
        self.questWindow = QuestWindow.New(self)
    end
    self.questWindow:Open(args)
end

function QuestModel:OpenDramaWindow(args)
    if self.dramaWindow == nil then
        self.dramaWindow = QuestDramaWindow.New(self)
    end
    self.dramaWindow:Open(args)
end

-- 显示任务链接取任务时显示的对话
function QuestModel:ShowChainDialog(questData)
    local baseid = QuestManager.Instance.chainBaseId
    local unitid = QuestManager.Instance.chainUnitId
    local battle_id = QuestManager.Instance.chainBattleId

    if MainUIManager.Instance.dialogModel.currentNpcData ~= nil then
        baseid = MainUIManager.Instance.dialogModel.currentNpcData.baseid
        unitid = MainUIManager.Instance.dialogModel.currentNpcData.id
        battle_id = MainUIManager.Instance.dialogModel.currentNpcData.battleid
    end

    local npcBase = BaseUtils.copytab(DataUnit.data_unit[baseid])
    if npcBase ~= nil then
        -- 99 这个参数是标志这个 15 的按钮不现实，然后点击任何地方都跑任务链
        npcBase.buttons = {{button_id = 15, button_args = {99}, button_desc = TI18N("对话框里面会修改这个显示内容"),button_show = "[]"}}
        local cli_label = QuestManager.Instance:GetQuestCurrentLabel(questData)
        local sp = QuestManager.Instance:GetTargetDataSer(questData)
        local chainPlot = nil
        if cli_label == QuestEumn.CliLabel.fight then
            -- 战斗
            local fightid = QuestManager.Instance:GetChainFightTarget(questData)
            chainPlot = DataQuestChain.data_plot[fightid]
            if chainPlot ~= nil then
                local npcData = DataUnit.data_unit[sp.target]
                local len = #chainPlot.talk
                local str = chainPlot.talk[math.random(1, len)].talk_val
                if npcData ~= nil then
                    str = string.gsub(str, "fight", npcData.name)
                end
                local npcData = DataUnit.data_unit[QuestManager.Instance.chainBaseId]
                if npcData ~= nil then
                    str = string.gsub(str, "npc", npcData.name)
                end
                npcBase.plot_talk = str
            end
        elseif cli_label == QuestEumn.CliLabel.gain then
            -- 获得道具
            chainPlot = DataQuestChain.data_commitPlot[QuestManager.Instance.chainUnitId]
            if chainPlot ~= nil then
                local itemData = DataItem.data_get[sp.target]
                local len = #chainPlot.find_talk
                local str = chainPlot.find_talk[math.random(1, len)].talk_val
                if itemData ~= nil then
                    str = string.gsub(str, "item", itemData.name)
                end
                local npcData = DataUnit.data_unit[QuestManager.Instance.chainBaseId]
                if npcData ~= nil then
                    str = string.gsub(str, "npc", npcData.name)
                end
                npcBase.plot_talk = str
            end
        elseif cli_label == QuestEumn.CliLabel.catchpet then
            -- 获得宠物
            chainPlot = DataQuestChain.data_commitPlot[QuestManager.Instance.chainUnitId]
            if chainPlot ~= nil then
                local petData = DataPet.data_pet[sp.target]
                local len = #chainPlot.catch_talk
                local str = chainPlot.catch_talk[math.random(1, len)].talk_val
                if petData ~= nil then
                    str = string.gsub(str, "pet", petData.name)
                end
                local npcData = DataUnit.data_unit[QuestManager.Instance.chainBaseId]
                if npcData ~= nil then
                    str = string.gsub(str, "npc", npcData.name)
                end
                npcBase.plot_talk = str
            end
        elseif cli_label == QuestEumn.CliLabel.visit then
            -- 拜访
            chainPlot = DataQuestChain.data_commitPlot[QuestManager.Instance.chainUnitId]
            if chainPlot ~= nil then
                local npcData = DataUnit.data_unit[QuestManager.Instance.chainBaseId]
                local len = #chainPlot.visit_talk
                local str = chainPlot.visit_talk[math.random(1, len)].talk_val
                if npcData ~= nil then
                    str = string.gsub(str, "npc", npcData.name)
                end
                npcBase.plot_talk = str
            end
        end
        local extra = {base = npcBase}
        local npcData = {baseid = baseid, id = unitid, battle_id = battle_id}
        npcData.classes = npcBase.classes
        npcData.sex = npcBase.sex
        npcData.looks = npcBase.looks
        MainUIManager.Instance:OpenDialog(npcData, extra, true, true)
        -- inserted by 嘉俊 100环，200环 对话3秒后自动关闭
        if QuestManager.Instance.round_chain == 100 or QuestManager.Instance.round_chain == 200 then
            LuaTimer.Add(3000,function() MainUIManager.Instance:HideDialog() end)
        end
        -- 101环领取奖励时不显示对话框
        if QuestManager.Instance.round_chain == 101  then
            MainUIManager.Instance:HideDialog()
        end
        -- end by 嘉俊
    end
end

-- 检查饱食度
function QuestModel:CheckSatiationOk(questData)
    if questData ~= nil and questData.sec_type == QuestEumn.TaskType.offer and RoleManager.Instance.RoleData.satiety == 0 then
        SatiationManager.Instance:DoSomethingSatietyIsZero()
        return false
    end
    return true
end

-- 根据任务id，完成状态，判断播放那些剧情
function QuestModel:CheckDramaCli(questId, type)
    local key = string.format("%s_%s", questId, type)
end

function QuestModel:ShowDobulePointNotice()
    local has = 60
    local agenda = AgendaManager.Instance:GetDataById(1000)
    if agenda ~= nil then
        has = agenda.max_try - agenda.engaged
    end

    if AgendaManager.Instance.double_point < has and AgendaManager.Instance.double_point < 10 and AgendaManager.Instance.max_double_point > 0 and TeamManager.Instance.showDoubleTips then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = string.format(TI18N("您的双倍点数不足，是否自动领取？"))
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = self.sureGetDouble
        data.cancelCallback = function() TeamManager.Instance.showDoubleTips = false end
        NoticeManager.Instance:ConfirmTips(data)
    end
end

function QuestModel:CheckCross()
    if RoleManager.Instance.RoleData.cross_type == 1 then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("跨服状态不能开始此任务，是否<color='#ffff00'>返回原服</color>？")
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = SceneManager.Instance.quitCenter
        data.blueSure = true
        data.greenCancel = true
        NoticeManager.Instance:ConfirmTips(data)
        return true
    end
    return false
end
