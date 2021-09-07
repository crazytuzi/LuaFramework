LabourCampaignModel = LabourCampaignModel or BaseClass(BaseModel)

function LabourCampaignModel:__init()
    self.quest_track = false
    self.questteam_loaded = false
    self.inTrials = false           -- 是否在试炼中
    self.lastId = nil

    EventMgr.Instance:AddListener(event_name.trace_quest_loaded, function() self.questteam_loaded = true self:UpdataQuest() end)
end

function LabourCampaignModel:__delete()
end

function LabourCampaignModel:CreatQuest()
    if self.quest_track then
        return
    end
    self.quest_track = MainUIManager.Instance.mainuitracepanel.traceQuest:AddCustom()

    self.quest_track.callback = function ()
        self:OnTrackTrialsNpc()
    end
    self:UpdataQuest()
end

function LabourCampaignModel:DeleteQuest()
    if self.quest_track then
        MainUIManager.Instance.mainuitracepanel.traceQuest:DeleteCustom(self.quest_track.customId)
        self.quest_track = nil
    end
end

function LabourCampaignModel:UpdataQuest()
    if not self.questteam_loaded then return end
    if self.trialsData ~= nil and self.trialsData.id ~= 0 then
        if self.quest_track then
            local index = #self.trialsData.done_list
            local data = DataBraveTrival.data_data[self.trialsData.id]
            local unit_data = DataUnit.data_unit[data.unit_id]
            if data == nil then
                self:DeleteQuest()
            else
                self.quest_track.title = string.format(TI18N("<color='#61e261'>[活动]四季挑战<color='#ff0000'>(%s/%s)</color></color>"), tostring(index), tostring(#DataBraveTrival.data_data))
                self.quest_track.Desc = string.format(TI18N("击败 <color='#00ff00'>%s</color>"), unit_data.name)
                self.quest_track.fight = true
                self.quest_track.type = CustomTraceEunm.Type.ActivityShort

                MainUIManager.Instance.mainuitracepanel.traceQuest:UpdateCustom(self.quest_track)

                self:OnTrackTrialsNpc()
            end
        else
            self:CreatQuest()
        end
    else
        self:DeleteQuest()
    end
end

function LabourCampaignModel:OnTrackTrialsNpc()
    if self.inTrials then
        if self.trialsData ~= nil then
            local data = DataBraveTrival.data_data[self.trialsData.id]
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath_AndTopEffect()
            local uniqueid = BaseUtils.get_unique_npcid(data.unit_id, 27)
            local npcData = SceneManager.Instance.sceneElementsModel:GetSceneData_OneNpc(uniqueid)
            if npcData == nil then
                SceneManager.Instance.sceneElementsModel:Self_AutoPath(data.location[1][1], uniqueid, data.location[1][2], data.location[1][3], true)
            else
                SceneManager.Instance.sceneElementsModel:Self_AutoPath(data.location[1][1], uniqueid, nil, nil, true)
            end
        end
    else
       -- QuestManager.Instance.model:FindNpc("48_1")
        QuestManager.Instance.model:FindNpc("54_1")
        -- ClassesChallengeManager.Instance:Send14807()
    end
end

function LabourCampaignModel:OnTrackMonkeyNpc()
    QuestManager.Instance.model:FindNpc("48_1")
end

function LabourCampaignModel:On14806(data)
    BaseUtils.dump(data, TI18N("<color=#FF0000>接收14806</color>"))
    self.trialsData = data
    self.inTrials = (data.id ~= 0)

    self:UpdataQuest()
end

function LabourCampaignModel:On14807(data)
    BaseUtils.dump(data, TI18N("<color=#FF0000>接收14807</color>"))
    NoticeManager.Instance:FloatTipsByString(data.msg)

    if data.flag == 1 then
        ClassesChallengeManager.Instance:Send14806()
    end
end

function LabourCampaignModel:CheckTrialOpen()
    local labourData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.NewLabour]
    if labourData ~= nil and labourData[CampaignEumn.NewLahourType.Type1] ~= nil then
        ClassesChallengeManager.Instance:Send14806()
    end
end

function LabourCampaignModel:Clear()
    self.lastId = nil
    self.quest_track = nil
end

function LabourCampaignModel:On14808(data)
    print("接收14808")
    if #data.gains == 0 then
        return
    end

    FinishCountManager.Instance.model.reward_win_data = {
                        titleTop = TI18N("四季挑战")
                        -- , val = string.format("目前排名：<color='#ffff00'>%s</color>", self.rank)
                        , val1 = ""
                        , val2 = TI18N("恭喜成功挑战所有四季精灵，获得以下奖励：")
                        , title = TI18N("四季挑战奖励")
                        -- , confirm_str = "查看排名"
                        , share_str = TI18N("回到主城")
                        , reward_list = data.gains
                        -- , confirm_callback = function() ClassesChallengeManager.Instance:Send14805() end
                        , share_callback = function()
                                if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Follow then
                                    NoticeManager.Instance:FloatTipsByString(TI18N("只有队长才能回城"))
                                else
                                    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath_AndTopEffect()
                                    SceneManager.Instance.sceneElementsModel:Self_Transport(10001, 0, 0)
                                end
                            end
                    }
    FinishCountManager.Instance.model:InitRewardWin_Common()
end

function LabourCampaignModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = NewLabourWindow.New(self)
    end
    self.mainWin:Open(args)
end
function LabourCampaignModel:CloseWindow()
    if self.mainWin ~= nil then
        WindowManager.Instance:CloseWindow(self.mainWin)
        self.mainWin = nil
    end
end
function LabourCampaignModel:FriendHelp()
    if self.help_bags_panel == nil then
        self.help_bags_panel = FriendHelpPanel.New()
    end
    self.help_bags_panel:Show()
end

