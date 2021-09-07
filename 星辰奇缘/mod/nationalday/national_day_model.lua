--2016/9/21
--zzl
--国庆活动数据管理器
NationalDayModel = NationalDayModel or BaseClass(BaseModel)

function NationalDayModel:__init()
    self.mainWin = nil
    self.questionWin = nil
    --主界面的tab选项卡的手写配置
    self.tabDataList = {
        --btn_str:按钮的名字， iconW:按钮宽度，iconH：按钮高度, iconName:按钮资源名称, sortIndex:排序为
        [1] = {id = 1, btn_str = TI18N("蛋糕欢乐送"), iconW = 24, iconH = 21, iconName =  "29", sortIndex = 1, endTime = 0,campId=327}
        ,[2] = {id = 2, btn_str = TI18N("五彩遍山河"), iconW = 31, iconH = 25, iconName = "30", sortIndex = 2, endTime = 0,campId=328}
        ,[3] = {id = 3, btn_str = TI18N("超级智多星"), iconW = 26, iconH = 26, iconName = "31", sortIndex = 3, endTime = 0,campId=329}
        ,[4] = {id = 4, btn_str = TI18N("庆典贺华诞"), iconW = 26, iconH = 25, iconName = "32", sortIndex = 4, endTime = 0,campId=330}
        ,[5] = {id = 5, btn_str = TI18N("彩虹七天乐"), iconW = 30, iconH = 23, iconName = "33", sortIndex = 5, endTime = 0,campId=331}
        ,[6] = {id = 6, btn_str = TI18N("稀有之宝"), iconW = 24, iconH = 28, iconName = "TreasureIcon", sortIndex = 6, endTime = 0,campId=332}
        ,[7] = {id = 7, btn_str = TI18N("魔轮随心转"), iconW = 24, iconH = 28, iconName = "RotaryIcon", sortIndex = 7, endTime = 0, campId=333}
    }

    self.questteam_loaded = false
    EventMgr.Instance:AddListener(event_name.trace_quest_loaded, function() self.questteam_loaded = true self:UpdataQuest() end)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, function() self:OnItemChange() end)
    self.turnplateList = {}
    self.questionData = nil
    self.curQuestionData = nil
    self.freeSpace = 0

    self.defense_data = nil
    self.defenseQuestData =nil
    self.defensecake_data = nil
    self.waitOpenSuccessWin = false
end

function NationalDayModel:__delete()

end

function NationalDayModel:ShowRewardPanel(items)
    if self.mainWin ~= nil and self.multiItemPanel == nil then
        -- self.multiItemPanel = MultiItemPanel.New(self.mainWin)
        self.multiItemPanel = NationalDayRewardPanel.New(self)
    end
    self.multiItemPanel:Show(items)
    -- local info = {
    --     column = 5,
    --     list = {
    --         {
    --             title = "彩虹七天乐抽奖结果展示",
    --             items = items,
    --        }
    --     }
    -- }
    -- self.multiItemPanel:Show(info)
end

function NationalDayModel:CloseRewardPanel()
    if self.multiItemPanel ~= nil then
        self.multiItemPanel:DeleteMe()
        self.multiItemPanel = nil
    end
end

----------------------------界面打开关闭逻辑
--打开主界面
function NationalDayModel:InitMainUI(args)
    if self.mainWin == nil then
        self.mainWin = NationalDayMainWindow.New(self)
    end
    self.mainWin:Open(args)
end

function NationalDayModel:CloseMainUI()
    if self.mainWin ~= nil then
        WindowManager.Instance:CloseWindow(self.mainWin)
    end
    if self.mainWin == nil then
        -- print("===================self.mainWin is nil")
    else
        -- print("===================self.mainWin is not nil")
    end

    if self.multiItemPanel ~= nil then
        self.multiItemPanel:DeleteMe()
        self.multiItemPanel = nil
    end
end

--智多星答题
function NationalDayModel:InitQuestionUI(args)
    if self.questionWin == nil then
        self.questionWin = NationalDayQuestionWindow.New(self)
    end
    self.questionWin:Open(args)
end

function NationalDayModel:CloseQuestionUI()
    if self.questionWin ~= nil then
        WindowManager.Instance:CloseWindow(self.questionWin)
    end
    if self.questionWin == nil then
        -- print("===================self.questionWin is nil")
    else
        -- print("===================self.questionWin is not nil")
    end
end

----------------------------国庆保卫蛋糕
function NationalDayModel:InitDefenseQuestionUI(args)
    if self.defense_question_win == nil then
        self.defense_question_win = NationalDayDefenseQuestionWindow.New(self)
    end
    self.defense_question_win:Open(args)
end

function NationalDayModel:CloseDefenseQuestionUI()
    if self.defense_question_win ~= nil then
        WindowManager.Instance:CloseWindow(self.defense_question_win)
    end
    if self.defense_question_win == nil then
        -- print("===================self.defense_question_win is nil")
    else
        -- print("===================self.defense_question_win is not nil")
    end
end

function NationalDayModel:On14080(data)
    -- BaseUtils.dump(data, TI18N("<color=#FF0000>接收14080</color>"))

    self.defense_data = BaseUtils.copytab(data)
    EventMgr.Instance:Fire(event_name.nationalday_defense_update)
end

--打开保卫蛋糕答题界面
function NationalDayModel:On14081(data)
    BaseUtils.dump(data, TI18N("<color=#FF0000>接收14081</color>"))
    self.defenseQuestData = data.info

    local remainCount = 0
    if data ~= nil then
        for i,v in ipairs(self.defenseQuestData) do
            if v.status == 0 then
                remainCount = remainCount + 1
            end
        end
    end

    if remainCount > 0 then
        --停止寻路
        SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
        SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
        SceneManager.Instance.sceneElementsModel:Self_StopMove()

        self:InitDefenseQuestionUI()
        self.defense_question_win:UpdateQuestionInfo()
    end
end

function NationalDayModel:On14082(data)
    -- BaseUtils.dump(data, TI18N("<color=#FF0000>接收14082</color>"))
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if self.defense_question_win ~= nil then
        self.defense_question_win:UpdateAnswerResult(data)
    end
end

function NationalDayModel:On14085(data)
    self.waitOpenSuccessWin = true
end

function NationalDayModel:On14086(data)
    -- BaseUtils.dump(data, TI18N("<color=#FF0000>接收14086</color>"))

    self.defensecake_data = BaseUtils.copytab(data)
    EventMgr.Instance:Fire(event_name.nationalday_defense_update)
end

function NationalDayModel:CheckOpenSuccessWin()
    if self.waitOpenSuccessWin == true then
        self.waitOpenSuccessWin = false
        self:OpenSuccessWindow()
    end
end

----------------------------国庆五彩便河山
function NationalDayModel:CreatQuest()
    if self.quest_track then
        return
    end
    self.quest_track = MainUIManager.Instance.mainuitracepanel.traceQuest:AddCustom()

    self.quest_track.callback = function ()
        self:OnTrackFiveNpc()
    end
    self:UpdataQuest()
end

function NationalDayModel:DeleteQuest()
    if self.quest_track then
        MainUIManager.Instance.mainuitracepanel.traceQuest:DeleteCustom(self.quest_track.customId)
        self.quest_track = nil
    end
end

function NationalDayModel:UpdataQuest()
    if not self.questteam_loaded then return end
    if self.fiveData ~= nil and self.fiveData.id ~= 0 then
        if self.quest_track then
            local doneLen = 0
            for i=1,#self.fiveData.done_list do
                local tempData = self.fiveData.done_list[i]
                if tempData.done_id <= 5 then
                    doneLen = doneLen + 1
                end
            end

            if doneLen == 0 then
                doneLen = 1
            else
                if doneLen < 5 then
                    doneLen = doneLen + 1
                end
            end

            local data = DataBraveTrival.data_data[self.fiveData.id]
            local unit_data = DataUnit.data_unit[data.unit_id]
            if data == nil then
                self:DeleteQuest()
            else
                self.quest_track.title = string.format(TI18N("<color='#61e261'>[活动]五彩贺小年<color='#ff0000'>(%s/%s)</color></color>"), tostring(doneLen), tostring(#DataBraveTrival.data_data))
                self.quest_track.Desc = string.format(TI18N("打败 <color='#00ff00'>%s</color>"), unit_data.name)
                self.quest_track.fight = true
                self.quest_track.type = CustomTraceEunm.Type.ActivityShort

                MainUIManager.Instance.mainuitracepanel.traceQuest:UpdateCustom(self.quest_track)

                self:OnTrackFiveNpc()
            end
        else
            self:CreatQuest()
        end
    else
        self:DeleteQuest()
    end
end

function NationalDayModel:OnTrackFiveNpc()
    if self.inFive then
        if self.fiveData ~= nil then
            local data = DataBraveTrival.data_data[self.fiveData.id]
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
        QuestManager.Instance.model:FindNpc("58_1")
    end
end

function NationalDayModel:On14809(data)
    -- BaseUtils.dump(data, TI18N("<color=#FF0000>接收14809</color>"))
    self.fiveData = data
    self.inFive = (data.id ~= 0)

    self:UpdataQuest()
end

function NationalDayModel:On14810(data)
    -- BaseUtils.dump(data, TI18N("<color=#FF0000>接收14810</color>"))
    NoticeManager.Instance:FloatTipsByString(data.msg)

    if data.flag == 1 then
        NoticeManager.Instance:Send14809()
    end
end

function NationalDayModel:On14811(data)
    -- BaseUtils.dump(data, TI18N("<color=#FF0000>接收14811</color>"))
    if #data.gains == 0 then
        return
    end

    FinishCountManager.Instance.model.reward_win_data = {
                        titleTop = TI18N("五彩贺小年")
                        -- , val = string.format("目前排名：<color='#ffff00'>%s</color>", self.rank)
                        , val1 = ""
                        , val2 = TI18N("经过大家的努力终于夺回了所有的灯笼，感谢你的努力，一起准备度过欢乐新年吧！")
                        , title = TI18N("五彩贺小年奖励")
                        -- , confirm_str = "查看排名"
                        , reward_title = TI18N("活动奖励")
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

function NationalDayModel:CheckFiveOpen()
    local labourData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.NewLabour]
    if labourData ~= nil then
        NationalDayManager.Instance:Send14809()
    end
end

function NationalDayModel:Clear()
    self.lastId = nil
    self.quest_track = nil
end

function NationalDayModel:OpenOtherWindow(args)
    if self.otherWin == nil then
        self.otherWin = NationalDayOtherWindow.New(self)
    end
    self.otherWin:Open(args)
end

function NationalDayModel:OpenSuccessWindow(args)
    if self.previewWin == nil then
        self.previewWin = NationalDaySuccessWindow.New(self)
    end
    self.previewWin:Show(args)
end

function NationalDayModel:ClosePreviewWindow()
    if self.previewWin ~= nil then
        self.previewWin:Hiden(args)
        self.previewWin:DeleteMe()
        self.previewWin = nil
    end
end


------------------------智多星答题
function NationalDayModel:On14070(data)
    self.questionData = data
    self.questionData.left_time = self.questionData.left_time + Time.time
    local cfg_data = DataSystem.data_daily_icon[314]

    if MainUIManager.Instance.noticeView ~= nil then
        if data.status == 0 then
            --关闭
            self:CloseQuestionUI()
            -- MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
            MainUIManager.Instance.noticeView:DelAtiveIcon(cfg_data.id)
        elseif data.status == 2 then
            --准备中
            -- MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
            MainUIManager.Instance.noticeView:DelAtiveIcon(cfg_data.id)
            self:InitQuestionUI()
        else
            --开启
            self:CloseQuestionUI()
            local iconData = AtiveIconData.New()
            iconData.id = cfg_data.id
            iconData.iconPath = cfg_data.res_name
            iconData.timestamp = self.questionData.left_time
            iconData.timeoutCallBack = nil
            iconData.clickCallBack = function()
                self:InitQuestionUI()
            end
            iconData.sort = cfg_data.sort
            iconData.lev = cfg_data.lev
            -- iconData.createCallBack = function(gameObject)
            --     local fun = function(effectView)
            --         if not BaseUtils.is_null(gameObject) then
            --             local effectObject = effectView.gameObject
            --             effectObject.transform:SetParent(gameObject.transform)
            --             effectObject.transform.localScale = Vector3(1, 1, 1)
            --             effectObject.transform.localPosition = Vector3(0,32,-400)
            --             effectObject.transform.localRotation = Quaternion.identity
            --             Utils.ChangeLayersRecursively(effectObject.transform, "UI")
            --         end
            --     end
            --     BaseEffectView.New({effectId = 20256, time = nil, callback = fun})
            -- end
            -- MainUIManager.Instance:AddAtiveIcon(iconData)
            if cfg_data.lev <= RoleManager.Instance.RoleData.lev then
                MainUIManager.Instance.noticeView:AddAtiveIcon(iconData)
            end
        end
    end
end

--获取题目信息
function NationalDayModel:On14071(data)
    self.curQuestionData = data
    if data.err_code == 1 then
        if self.questionWin ~= nil then
            self.questionWin:UpdateQuestionInfo(data)
        end
    else

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
    --,{uint32, askid, "题目id"}
end

--智多星答题
function NationalDayModel:On14072(data)
    if data.err_code == 1 then
        LuaTimer.Add(600, function()
            self:CloseQuestionUI()
            local confirmData = NoticeConfirmData.New()
            confirmData.type = ConfirmData.Style.Sure
            confirmData.sureLabel = TI18N("确认")
            local option = "A"
            if data.anwer == 2 then
                option = "B"
            elseif data.anwer == 3 then
                option = "C"
            elseif data.anwer == 4 then
                option = "D"
            end
            confirmData.content = string.format(TI18N("你已完成作答，选择的答案是：<color='#00ff00'>%s</color>，题目正确答案将在答题结束时于<color='#ffff00'>世界频道</color>公布{face_1, 7}" ), option)
            NoticeManager.Instance:ConfirmTips(confirmData)
        end)
        if self.questionWin ~= nil then
            self.questionWin:UpdateAnswerResult(data)
        end
        local cfg_data = DataSystem.data_daily_icon[314]
        --关闭,答完直接关掉
        MainUIManager.Instance.noticeView:DelAtiveIcon(cfg_data.id)
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--智多星结算
function NationalDayModel:On14078(data)
    if #data.gains == 0 then
        return
    end

    local tempStr = ""
    if data.result == 1 then
        --答对
        if data.answer_times >= 13 then
            tempStr = TI18N("恭喜你回答正确，今日你参与答题<color='#00ff00'>超过13次</color>，不再获得道具奖励。本轮获得以下奖励")
        elseif data.answer_times >= 7 then
            tempStr = TI18N("恭喜你回答正确，今日你参与答题<color='#00ff00'>超过7次</color>，获得物品几率下降。本轮获得以下奖励")
        else
            tempStr = TI18N("恭喜你回答正确，获得以下奖励")
        end
    else
        --答错
        tempStr = TI18N("很遗憾你答错了，获得以下奖励")
    end

    local rewardLit = {}
    for i = 1, #data.gains do
        table.insert(rewardLit, {id = data.gains[i].assets, num = data.gains[i].val})
    end
    FinishCountManager.Instance.model.reward_win_data = {
                        titleTop = TI18N("智多星结算")
                        , val1 = ""
                        , val2 = string.format("\n%s", tempStr) --TI18N("\n<size=20>智多星抢答结束，您获得以下奖励</size>")
                        , title = TI18N("智多星奖励")
                        , share_str = TI18N("确定")
                        , reward_list = rewardLit
                        -- , confirm_callback = function() ClassesChallengeManager.Instance:Send14805() end
                        , share_callback = function()
                                    -- SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath_AndTopEffect()
                                    -- SceneManager.Instance.sceneElementsModel:Self_Transport(10001, 0, 0)
                        end
                    }
    FinishCountManager.Instance.model:InitRewardWin_Common()
end

--传入文本，确定下是否当前题目的答案内容，是的话发送答题协议，走答题流程
function NationalDayModel:CheckCanAnswerNationalDay(str)
    if self.questionData == nil then
        -- print("-----------------------没获得答题状态数据")
        return
    end
    if self.questionData.status == 0 then
        -- print("-----------------------没获得答题状态还没开启")
        return --还没开启
    end

    local cfgData = DataQuestion.data_national_day_question[self.questionData.askid]
    if cfgData == nil then
        -- print("-----------------------无效题目")
        return --无效题目
    end
    local option = 0
    if string.lower(str) == "a" then
        option = 1
    elseif string.lower(str) == "b" then
        option = 2
    elseif string.lower(str) == "c" then
        option = 3
    elseif string.lower(str) == "d" then
        option = 4
    end

    if option ~= 0 then
        if self.curQuestionData ~= nil then
            if self.curQuestionData.askid == self.questionData.askid and self.curQuestionData.done_answer ~= 0 then
                NoticeManager.Instance:FloatTipsByString(TI18N("你已经回答了问题，请等待正确答案的公布"))
                return
            end
        end
        --有对应的答案
        NationalDayManager.Instance:Send14071()
        NationalDayManager.Instance:Send14072(option, 1)
    end
end

-- 检查抽奖是否是免费刷新
-- 每小时会有一次免费机会
function NationalDayModel:IsFreeRefresh()
    self.freeSpace = 3600 - (BaseUtils.BASE_TIME - NationalDayManager.Instance.last_free_time)
    if self.freeSpace <= 0 then
        return true
    end
    return false
end

-- 检查福袋红点
function NationalDayModel:CheckBalloonRed()
    self.rollNeedRed = false
    local list = CampaignManager.Instance.campaign_bags.collected
    if list == nil then
        return self.rollNeedRed
    end
    for i,data in ipairs(list) do
        local base = DataCampaignBags.data_getBags[data.id]
        if base ~= nil then
            local has = BackpackManager.Instance:GetItemCount(data.id)
            if has >= base.need and data.status ~= 1 then
                self.rollNeedRed = true
            end
        end
    end
    NationalDayManager.Instance:check_red_point()
    return self.rollNeedRed
end

function NationalDayModel:OnItemChange()
    self:CheckBalloonRed()
end
