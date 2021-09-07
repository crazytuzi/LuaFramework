LevelJumpModel = LevelJumpModel or BaseClass(BaseModel)

function LevelJumpModel:__init()
    self.window = nil

    self.targetData = nil

    self.questteam_loaded = false -- 任务追踪模块初始化完成
    self.quest_track = nil -- 突破任务的任务追踪项
    self.questData = nil -- 突破任务的任务追踪数据
    -- EventMgr.Instance:AddListener(event_name.trace_quest_loaded, function() self.questteam_loaded = true self:UpdataQuest() end)
end

function LevelJumpModel:__delete()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function LevelJumpModel:OpenWindow(args)
    if self.window == nil then
        self.window = LevelJumpWindow.New(self)
    end

    self.window:Open(args)
end

function LevelJumpModel:CloseWindow()
    if self.window ~= nil then
        WindowManager.Instance:CloseWindow(self.window)
    end
end

function LevelJumpModel:OpenScorePanel(args)
    if self.scorepanel == nil then
        self.scorepanel = LevelJumpScorePanel.New(self)
    end
    self.scorepanel:Show(args)
end

function LevelJumpModel:CloseScorePanel(args)
    if self.scorepanel ~= nil then
        self.scorepanel:DeleteMe()
        self.scorepanel = nil
    end
end

function LevelJumpModel:CheckAllQuestFinished()
    if self.targetData then
        for k,v in pairs(self.targetData.goals) do
            if v.finish == 0 then
                return false
            end
        end

        return true
    end

    return false
end

function LevelJumpModel:CheckWolrdCollected()
    if self.targetData == nil then return false end

    for k,v in pairs(self.targetData.goals) do
        if v.id == 1001 then
            return v.progress[1].value >= v.progress[1].target_val
        end
    end

    return false
end

function LevelJumpModel:CheckChallenge()
    if self.targetData then

        for k,v in pairs(self.targetData.goals) do
            if v.id ~= 1008 then--1008为要挑战的目标 不需检测
                if v.finish == 0 then
                    return false
                end
            end
        end

        return true
    end

    return false
end

function LevelJumpModel:SetQuestData(data)
    self.questData = {}
    self.questData.contribution = data.contribution
    self.questData.need = data.need
end

function LevelJumpModel:CreatQuest()
    if self.quest_track then
        return
    end

    self.quest_track = MainUIManager.Instance.mainuitracepanel.traceQuest:AddCustom()
    self.quest_track.callback = function ()
            if QuestManager.Instance.model:CheckCross() then
                return
            end

            QuestManager.Instance.model:FindNpc("60_1")
        end

    self:UpdataQuest()
end

function LevelJumpModel:DeleteQuest()
    if self.quest_track then
        MainUIManager.Instance.mainuitracepanel.traceQuest:DeleteCustom(self.quest_track.customId)
        self.quest_track = nil
    end
end

function LevelJumpModel:UpdataQuest()
    if not self.questteam_loaded then return end

    local quest = QuestManager.Instance:GetQuest(44020)
    if quest ~= nil then
        if self.questData ~= nil then
            if self.questData.contribution < self.questData.need then
                if self.quest_track then
                    self.quest_track.title = TI18N("<color='#fa74ff'>[突破]重建星途</color>")
                    self.quest_track.Desc = string.format("共同收集<color='#00ff12'>星光碎片</color>，重建星途<color='#00ff12'>（%s/%s）</color>", self.questData.contribution, self.questData.need)

                    MainUIManager.Instance.mainuitracepanel.traceQuest:UpdateCustom(self.quest_track)
                else
                    self:CreatQuest()
                end
            else
                self.questData = nil
                self:DeleteQuest()
            end
        else
            LevelBreakManager.Instance:send17404()
        end
    end
end
