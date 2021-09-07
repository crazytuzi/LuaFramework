ExperienceBottleModel = ExperienceBottleModel or BaseClass(BaseModel)

function ExperienceBottleModel:__init()
    self.questteam_loaded = false
    self.quest_track = nil
    self.tab = nil
    self.flag = 0
    self.val = 0
    self.target_val = 0

    EventMgr.Instance:AddListener(event_name.trace_quest_loaded, function() self.questteam_loaded = true self:UpdataQuest() end)
end

function ExperienceBottleModel:__delete()

end

function ExperienceBottleModel:CreatQuest()
    if self.quest_track then
        return
    end

    self.show_quest_track_effect = false
    if self.val == 0 then
        self.show_quest_track_effect = true
    end
    self.quest_track, self.tab = MainUIManager.Instance.mainuitracepanel.traceQuest:AddCustom(self.show_quest_track_effect)

    self.quest_track.callback = function ()
            if self.show_quest_track_effect then
                MainUIManager.Instance.mainuitracepanel.traceQuest:HideEffectBefore()
                self.show_quest_track_effect = false
            end
            if self.quest_track.finish == false then
                NoticeManager.Instance:FloatTipsByString(TI18N("获取<color='#00ffaa'>人物经验</color>可增加经验<color='#00ffaa'>圣水进度</color>哦"))
            elseif self.quest_track.finish == true then
                MainUIManager.Instance.mainuitracepanel.traceQuest:HideEffectBefore()
                ExperienceBottleManager.Instance:Send10260()
            end
        end

    self:UpdataQuest()

    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.backpack)
    MainUIManager.Instance.mainuitracepanel:ChangeShowType(TraceEumn.ShowType.Normal)
end

function ExperienceBottleModel:DeleteQuest()
    if self.quest_track then
        MainUIManager.Instance.mainuitracepanel.traceQuest:DeleteCustom(self.quest_track.customId)
        self.quest_track = nil
    end
end

function ExperienceBottleModel:UpdataQuest()
    if not self.questteam_loaded then return end
    if self.flag == 1 then
        if self.val >= self.target_val then
            -- self:DeleteQuest()
            if self.quest_track then
                self.quest_track.title = TI18N("[经验]经验圣水")
                self.quest_track.Desc = string.format(TI18N("收集进度<color='#00ffaa'>%.2f%%</color>"), 100)
                self.quest_track.fight = false
                self.quest_track.finish = true
                --特效
                local traceQuest = MainUIManager.Instance.mainuitracepanel.traceQuest
                if traceQuest ~= nil then
                    traceQuest:UpdateCustom(self.quest_track)
                    if self.tab ~= nil and traceQuest ~= nil and not BaseUtils.isnull(self.tab.gameObject) then
                        traceQuest:LoadEffect(self.tab.gameObject.transform)
                    end
                end

            else
                self:CreatQuest()
            end
            --ExperienceBottleManager.Instance:Send10260()
        else
            if self.quest_track then
                self.quest_track.title = TI18N("[经验]经验圣水")
                self.quest_track.Desc = string.format(TI18N("收集进度<color='#00ffaa'>%.2f%%</color>"), self.val / self.target_val * 100)
                self.quest_track.fight = false
                self.quest_track.finish = false

                MainUIManager.Instance.mainuitracepanel.traceQuest:UpdateCustom(self.quest_track)
            else
                self:CreatQuest()
            end
        end
    else
        self:DeleteQuest()
    end
end

function ExperienceBottleModel:ClearData()
    self.quest_track = nil
    self.tab = nil
    self.flag = 0
    self.val = 0
    self.target_val = 0
end
