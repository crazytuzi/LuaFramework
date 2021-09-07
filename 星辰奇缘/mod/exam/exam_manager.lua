ExamManager = ExamManager or BaseClass(BaseManager)

function ExamManager:__init()
    if ExamManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    ExamManager.Instance = self;
    self.data_14503 = nil
    self:InitHandler()
    -- self.mark_lev = RoleManager.Instance.RoleData.lev
    self.model = ExamModel.New()
end

function ExamManager:__delete()
    self.model:DeleteMe()
    self.model = nil
end

function ExamManager:InitHandler()
    self:AddNetHandler(14500,self.on14500)
    self:AddNetHandler(14501,self.on14501)
    self:AddNetHandler(14502,self.on14502)
    self:AddNetHandler(14503,self.on14503)
    self:AddNetHandler(14504,self.on14504)
    self:AddNetHandler(14505,self.on14505)
    self:AddNetHandler(14506,self.on14506)
    self:AddNetHandler(14507,self.on14507)
    self:AddNetHandler(14508,self.on14508)
    self:AddNetHandler(14509,self.on14509)
    self:AddNetHandler(14510,self.on14510)
    self:AddNetHandler(14511,self.on14511)
    self:AddNetHandler(14512,self.on14512)
    self:AddNetHandler(14513,self.on14513)
    self:AddNetHandler(14514,self.on14514)
    self:AddNetHandler(14515,self.on14515)
    self:AddNetHandler(14516,self.on14516)
    self:AddNetHandler(14517,self.on14517)
    self:AddNetHandler(14518,self.on14518)
    self:AddNetHandler(14519,self.on14519)

    self.on_role_change = function(data)
        self:request14500()
    end
    EventMgr.Instance:AddListener(event_name.role_level_change, self.on_role_change)
end

function ExamManager:RequestInitData()
    self:request14500()
    self:request14509()

    if self.main_win ~= nil then
        self.model:CloseMainUI()
        self:request14503()
    end
    if self.final_exam_win ~= nil then
        self.model:CloseFinalExamUI()
        self:request14510()
        self:request14512()
        self:request14516()
    end
end

---------------------------------------协议接收逻辑
--活动状态返回
function ExamManager:on14500(data)
    -- print("==================================收到14500")

    self.model.cur_exam_type = data.type
    self.model.cur_exam_status = data.status
    self.model.cur_exam_left_time = data.timeout

    local cfg_data = DataSystem.data_daily_icon[106]
    MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
    if cfg_data.lev > RoleManager.Instance.RoleData.lev then
        return
    end
    if self.model.cur_exam_status == 2 then
        self:request14508()
    end

    if self.model.cur_exam_status ~= 0 then
        if self.model.cur_exam_type == 1 then
            --院试开始，出现图标
        elseif self.model.cur_exam_type == 2 then
            if RoleManager.Instance.RoleData.event == RoleEumn.Event.Exam then
                return
            end

            --会试
            local click_callback = function()
                --寻路到报名npc
                if RoleManager.Instance.RoleData.cross_type == 1 then
                    -- 如果处在中央服，先回到本服在参加活动
                    local confirmData = NoticeConfirmData.New()
                    confirmData.type = ConfirmData.Style.Normal
                    confirmData.sureSecond = -1
                    confirmData.cancelSecond = 180
                    confirmData.sureLabel = TI18N("确认")
                    confirmData.cancelLabel = TI18N("取消")
                    RoleManager.Instance.jump_over_call = function() self:on_find_path() end
                    confirmData.sureCallback = SceneManager.Instance.quitCenter
                    confirmData.content = string.format("<color='#ffff00'>%s</color>%s", TI18N("智慧闯关半决赛"), TI18N("活动已开启，是否<color='#ffff00'>返回原服</color>参加？"))
                    NoticeManager.Instance:ConfirmTips(confirmData)
                else
                    self:on_find_path()
                end
            end

            local timeout_callback = function()
                self:request14500()
            end

            local iconData = AtiveIconData.New()
            iconData.id = cfg_data.id
            iconData.iconPath = cfg_data.res_name
            iconData.clickCallBack = click_callback
            iconData.sort = cfg_data.sort
            iconData.lev = cfg_data.lev
            if self.model.cur_exam_status == 2 then
                iconData.timestamp = data.timeout + Time.time
                iconData.timeoutCallBack = timeout_callback
                MainUIManager.Instance:AddAtiveIcon(iconData)
            end
        elseif self.model.cur_exam_type == 3 then

        end
    else
        self.model:CloseMainUI()
    end
end

--寻路通用逻辑
function ExamManager:on_find_path()
    local npc_data = self.model:get_npc_data_by_date()
    local id_battle_id = BaseUtils.get_unique_npcid(npc_data[1], 12)
    SceneManager.Instance.sceneElementsModel:Self_AutoPath(npc_data[2], id_battle_id, nil, nil, true)
end


--参与返回
function ExamManager:on14501(data)
    -- print("===============================收到14501")
    if data.flag == 0 then
        --失败
        local unitData = {baseid = data.unit_base}
        local base = BaseUtils.copytab(DataUnit.data_unit[data.unit_base])
        base.buttons = {}
        base.plot_talk = data.msg
        local extra = {base = base}
        MainUIManager.Instance:OpenDialog(unitData, extra)
    elseif data.flag == 1 then
        --成功
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end

end

--退出返回
function ExamManager:on14502(data)
    if data.flag == 0 then
        --失败
    elseif data.flag == 1 then
        --成功

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--查看当前答题信息返回
function ExamManager:on14503(data)
    self.data_14503 = data

    if (self.model.cur_exam_type == 2 and self.model.cur_exam_status == 2) or self.model.cur_exam_type == 3 then
        if MainUIManager.Instance.mainuitracepanel.childTab[TraceEumn.ShowType.ExamQuestion] ~= nil and not BaseUtils.isnull(MainUIManager.Instance.mainuitracepanel.childTab[TraceEumn.ShowType.ExamQuestion].gameObject) then
            MainUIManager.Instance.mainuitracepanel.childTab[TraceEumn.ShowType.ExamQuestion]:update_info(data)
        end
    end

    if data.question ~= 0 then
        self.model.cur_question_data = data
        self.model:InitMainUI()
    else
        --置空题已答完
        self.model.cur_question_data = nil

        if data.answered == 0 and self.model.cur_exam_type == 2 then
            --会试，刚报名，没有答任何一道题，则自动寻路到下一个考官
            --在这里进行寻路
            local week_day = tonumber(os.date("%w",BaseUtils.BASE_TIME))
            week_day = week_day == 0 and 7 or week_day
            local today_npc_data = DataExamination.data_get_examiner[week_day]
            local npc_data = today_npc_data.location[data.subject+1]
            local id_battle_id = BaseUtils.get_unique_npcid(npc_data[1], 12)
            SceneManager.Instance.sceneElementsModel:Self_AutoPath(npc_data[2], id_battle_id, nil, nil, true)
        end
    end

    if data.total == data.answered then
        self:request14508()
    end
end

--答题返回
function ExamManager:on14504(data)
    -- print("----------------------------收到14504")
    if data.flag == 0 then
        --失败
    elseif data.flag == 1 then
        --答对
    elseif data.flag == 2 then

    end
    self.model:update_answer_result(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--答题结束获取总成绩返回
function ExamManager:on14505(data)
    -- print("----------------------------------收到14505")
    if self.model.cur_exam_type == 3 then
        --决赛
        if self.model.cur_final_question_data ~= nil then
            self.model:OpenFinalExamRankUI()
        end
    else
        --非决赛
        LuaTimer.Add(2000, function()
            self:request14503()
            FinishCountManager.Instance.model.reward_win_data = {}
            FinishCountManager.Instance.model.reward_win_data.scoket_data = data
            FinishCountManager.Instance.model.reward_win_data.title_str = TI18N("智慧闯关")
            FinishCountManager.Instance.model.reward_win_data.mid_title_1 = TI18N("智慧闯关")
            FinishCountManager.Instance.model.reward_win_data.mid_title_2 = TI18N("答题奖励总计")
            FinishCountManager.Instance.model.reward_win_data.reward_list = {{id = 90010, num = data.exp}}
            if data.pet_exp ~= 0 then
                table.insert(FinishCountManager.Instance.model.reward_win_data.reward_list, {id = 90005, num = data.pet_exp})
            end
            FinishCountManager.Instance.model.reward_win_data.callback = function() self:on_click_finish_count() end
            FinishCountManager.Instance.model:InitRewardWin()
        end)
    end
end

function ExamManager:on_click_finish_count()
    if ExamManager.Instance.model.cur_exam_type == 2 then
        if self.data_14503 ~= nil and self.data_14503.answered ~= 30 then
            --会试，还没答完所有考官则自动寻路到下一个考官
            local week_day = tonumber(os.date("%w",BaseUtils.BASE_TIME))
            week_day = week_day == 0 and 7 or week_day
            local today_npc_data = DataExamination.data_get_examiner[week_day]
            local npc_data = today_npc_data.location[self.data_14503.subject+1]
            local id_battle_id = BaseUtils.get_unique_npcid(npc_data[1], 12)


            SceneManager.Instance.sceneElementsModel:Self_AutoPath(npc_data[2], id_battle_id, nil, nil, false)
        end

    end
end

--进入殿试场景返回
function ExamManager:on14506(data)
    -- print("----------------------------------收到14506")
    if data.flag == 0 then
        --失败
    elseif data.flag == 1 then
        --成功
        --寻路到npc报名答题
        --进入成功，进行寻路
        local next_cfg_data = DataExamination.data_get_examiner[7]
        local npc_data = next_cfg_data.location[2]
        local id_battle_id = BaseUtils.get_unique_npcid(npc_data[1], 12)
        SceneManager.Instance.sceneElementsModel:Self_AutoPath(npc_data[2], id_battle_id, nil, nil, false)

        self.exam_scene_type = 3

        --切任务面板到殿试状态
        -- if MainUIManager.Instance.mainuitracepanel ~= nil then
        --     MainUIManager.Instance.mainuitracepanel:ChangeShowType(TraceEumn.ShowType.ExamQuestion)
        -- end
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--进入殿试场景返回
function ExamManager:on14507(data)
    -- print("----------------------------------收到14507")
     self.model.my_score_data = data
     self.model:InitMyScoreUI()
end

--
function ExamManager:on14508(data)
    -- print("------------------------------------收到14508")

    local cfg_data = DataSystem.data_daily_icon[106]


    if data.flag == 0 then
        --不可以参加
        AgendaManager.Instance:SetCurrLimitID(2007, false)
        AgendaManager.Instance:SetCurrLimitID(2008, false)
        AgendaManager.Instance:SetCurrLimitID(2009, false)
        MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
    else
        AgendaManager.Instance:SetCurrLimitID(2007, self.model.cur_exam_status == 2 and self.model.cur_exam_type == 1)
        AgendaManager.Instance:SetCurrLimitID(2008, self.model.cur_exam_status == 2 and self.model.cur_exam_type == 2)
        AgendaManager.Instance:SetCurrLimitID(2009, self.model.cur_exam_status == 2 and self.model.cur_exam_type == 3)

        --可以参加
        if self.model.cur_exam_type == 1 then
            --院试
            --弹出确认框，通知是否参加
            if self.model.cur_exam_status == 2 then
                if ActivityManager.Instance:GetNoticeState(GlobalEumn.ActivityEumn.exam) == false then
                    local str = TI18N("<color='#ffff00'>智慧闯关</color>活动即将开启，是否前往参加？")
                    if data.status == 2 then
                        str = TI18N("<color='#ffff00'>智慧闯关</color>活动已开启，是否前往参加？")
                    end
                    local data = NoticeConfirmData.New()
                    data.type = ConfirmData.Style.Normal
                    data.content = str
                    data.sureLabel = TI18N("确认")
                    data.cancelLabel = TI18N("取消")
                    data.cancelSecond = 30
                    data.sureCallback = function()
                        --自动寻路到npc
                        -- self:on_find_path()
                        ExamManager.Instance:request14501(79843)
                    end
                    NoticeManager.Instance:ActiveConfirmTips(data)

                    ActivityManager.Instance:MarkNoticeState(GlobalEumn.ActivityEumn.exam)
                end
            end

            if self.model.cur_exam_status == 2 then
                local click_callback = function()
                    --直接弹答题界面
                    ExamManager.Instance:request14501(79843)
                end

                local timeout_callback = function()
                    self:request14500()
                end

                local iconData = AtiveIconData.New()
                iconData.id = cfg_data.id
                iconData.iconPath = cfg_data.res_name
                iconData.clickCallBack = click_callback
                iconData.sort = cfg_data.sort
                iconData.lev = cfg_data.lev
                if self.model.cur_exam_status == 2 then
                    iconData.timestamp = self.model.cur_exam_left_time + Time.time
                    iconData.timeoutCallBack = timeout_callback
                    MainUIManager.Instance:AddAtiveIcon(iconData)
                end
            end


        elseif self.model.cur_exam_type == 2 then
            if RoleManager.Instance.RoleData.event == RoleEumn.Event.Exam then
                return
            end
            --会试
            if self.model.cur_exam_status == 2 then
                if ActivityManager.Instance:GetNoticeState(GlobalEumn.ActivityEumn.exam) == false then
                    --没有提示，则提示一下
                    local str = TI18N("<color='#ffff00'>智慧闯关</color>半决赛即将开启，是否前往参加？")
                    if data.status == 2 then
                        str = TI18N("<color='#ffff00'>智慧闯关</color>半决赛已开启，是否前往参加？")
                    end
                    local data = NoticeConfirmData.New()
                    data.type = ConfirmData.Style.Normal
                    data.content = str
                    data.sureLabel = TI18N("确认")
                    data.cancelLabel = TI18N("取消")
                    data.cancelSecond = 30
                    data.sureCallback = function()
                        --寻路到报名npc
                        self:on_find_path()
                    end

                    if RoleManager.Instance.RoleData.cross_type == 1 then
                        -- 如果处在中央服，先回到本服在参加活动
                        RoleManager.Instance.jump_over_call = function() self:on_find_path() end
                        data.sureCallback = SceneManager.Instance.quitCenter
                        if data.status == 2 then
                            data.content = TI18N("<color='#ffff00'>智慧闯关</color>半决赛已经开始，是否<color='#ffff00'>返回原服</color>参加？")
                        else
                            data.content = TI18N("<color='#ffff00'>智慧闯关</color>半决赛即将开始，是否<color='#ffff00'>返回原服</color>参加？")
                        end
                    end

                    NoticeManager.Instance:ActiveConfirmTips(data)
                    ActivityManager.Instance:MarkNoticeState(GlobalEumn.ActivityEumn.exam)
                end
            end
        elseif self.model.cur_exam_type == 3 then
            --决赛
            if RoleManager.Instance.RoleData.event == RoleEumn.Event.Event_examination_palace then
                return
            end

            if self.model.cur_exam_status == 2 then
                if ActivityManager.Instance:GetNoticeState(GlobalEumn.ActivityEumn.exam) == false then
                    --殿试
                    local str = TI18N("<color='#ffff00'>智慧闯关</color>决赛即将开启，是否前往参加？")
                    if data.status == 2 then
                        str = TI18N("<color='#ffff00'>智慧闯关</color>决赛已开启，是否前往参加？")
                    end
                    local data = NoticeConfirmData.New()
                    data.type = ConfirmData.Style.Normal
                    data.content = str
                    data.sureLabel = TI18N("确认")
                    data.cancelLabel = TI18N("取消")
                    data.cancelSecond = 30
                    data.sureCallback = function()
                        --寻路到报名npc
                        ExamManager.Instance:request14506()
                    end

                    if RoleManager.Instance.RoleData.cross_type == 1 then
                        -- 如果处在中央服，先回到本服在参加活动
                        RoleManager.Instance.jump_over_call = function() ExamManager.Instance:request14506() end
                        data.sureCallback = SceneManager.Instance.quitCenter
                        if data.status == 2 then
                            data.content = TI18N("<color='#ffff00'>智慧闯关</color>决赛已经开始，是否<color='#ffff00'>返回原服</color>参加？")
                        else
                            data.content = TI18N("<color='#ffff00'>智慧闯关</color>决赛即将开始，是否<color='#ffff00'>返回原服</color>参加？")
                        end
                    end

                    NoticeManager.Instance:ActiveConfirmTips(data)
                    ActivityManager.Instance:MarkNoticeState(GlobalEumn.ActivityEumn.exam)
                end

                local click_callback = function()
                    --直接弹答题界面
                    if RoleManager.Instance.RoleData.cross_type == 1 then
                        -- 如果处在中央服，先回到本服在参加活动
                        local confirmData = NoticeConfirmData.New()
                        confirmData.type = ConfirmData.Style.Normal
                        confirmData.sureSecond = -1
                        confirmData.cancelSecond = 180
                        confirmData.sureLabel = TI18N("确认")
                        confirmData.cancelLabel = TI18N("取消")
                        RoleManager.Instance.jump_over_call = function() ExamManager.Instance:request14506() end
                        confirmData.sureCallback = SceneManager.Instance.quitCenter
                        confirmData.content = string.format("<color='#ffff00'>%s</color>%s", TI18N("智慧闯关决赛"), TI18N("活动已开启，是否<color='#ffff00'>返回原服</color>参加？"))
                        NoticeManager.Instance:ConfirmTips(confirmData)
                    else
                        ExamManager.Instance:request14506()
                    end
                end

                local timeout_callback = function()
                    self:request14500()
                end

                local iconData = AtiveIconData.New()
                iconData.id = cfg_data.id
                iconData.iconPath = cfg_data.res_name
                iconData.clickCallBack = click_callback
                iconData.sort = cfg_data.sort
                iconData.lev = cfg_data.lev
                if self.model.cur_exam_status == 2 then
                    iconData.timestamp = self.model.cur_exam_left_time + Time.time
                    iconData.timeoutCallBack = timeout_callback
                    MainUIManager.Instance:AddAtiveIcon(iconData)
                end
            end

        end
    end
end


----------------决赛部分
--活动状态
function ExamManager:on14509(data)
    -- print("---------------------------收到14509")
    BaseUtils.dump(data)
    if data.status == 2 then
        self.model.final_exam_answers = {}
    end

    local cfg_data = DataSystem.data_daily_icon[117]

    -- self.model.cur_exam_type = 3
    self.model.cur_exam_status = data.status
    self.model.cur_exam_left_time = data.timeout


    AgendaManager.Instance:SetCurrLimitID(2009, false)

    MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
    if cfg_data.lev > RoleManager.Instance.RoleData.lev then
        return
    end

    if self.model.cur_exam_status ~= 0 then

        AgendaManager.Instance:SetCurrLimitID(2009, self.model.cur_exam_status == 2 and self.model.cur_exam_type == 3)
        if self.model.cur_exam_status == 2 then
            self.model:do_update_view()
        end
        if self.model.cur_exam_status == 1 then
            local callfun = function()
                if self.model.final_exam_win == nil or self.model.final_exam_win.isOpen == false then
                    --弹出确认框
                    local confirmData = NoticeConfirmData.New()
                    confirmData.type = ConfirmData.Style.Normal
                    confirmData.sureLabel = TI18N("确认")
                    confirmData.cancelLabel = TI18N("取消")
                    confirmData.cancelSecond = 90
                    confirmData.sureCallback = function()
                        self.model:OpenFinalExamUI()
                    end
                    confirmData.content =  TI18N("智力闯关决赛即将开始，是否参加？")
                    NoticeManager.Instance:ConfirmTips(confirmData)
                end
            end
            if self.model.cur_exam_left_time <= 120 then
                callfun()
            else
                --开启计时器
                local left_time = self.model.cur_exam_left_time - 120
                LuaTimer.Add(left_time*1000, callfun)
            end

            self.model.cur_final_prepare_left_time = self.model.cur_exam_left_time + Time.time
        elseif self.model.cur_exam_status == 2 then
             local confirmData = NoticeConfirmData.New()
            confirmData.type = ConfirmData.Style.Normal
            confirmData.sureLabel = TI18N("确认")
            confirmData.cancelLabel = TI18N("取消")
            confirmData.cancelSecond = 90
            confirmData.sureCallback = function()
                self.model:OpenFinalExamUI()
            end
            confirmData.content =  TI18N("智力闯关决赛已开始，是否参加？")
            NoticeManager.Instance:ConfirmTips(confirmData)
        end


        local click_callback = function()
            --准备中，弹出界面但不请求答题
            -- NoticeManager.Instance:FloatTipsByString(TI18N("智慧闯关决赛即将开始，请耐心等待"))
            self.model:OpenFinalExamUI()
        end
        local iconData = AtiveIconData.New()
        iconData.id = cfg_data.id
        iconData.iconPath = cfg_data.res_name
        iconData.clickCallBack = click_callback
        iconData.sort = cfg_data.sort
        iconData.lev = cfg_data.lev
        if self.model.cur_exam_status == 1 then
            iconData.text = TI18N("准备中")
        else
            iconData.timestamp = data.timeout + Time.time
        end
        MainUIManager.Instance:AddAtiveIcon(iconData)
    else
        self.model:CloseFinalExamUI()
        self:request14500()
    end
end

--查看当前答题信息
function ExamManager:on14510(data)
    -- print("---------------------------收到14510")
    self.model.cur_final_question_data = data
    if self.model.final_exam_answers[self.model.cur_final_question_data.qid] == nil then
        self.model.final_exam_answers[self.model.cur_final_question_data.qid] = {}
    end
    for i=1,#data.answers do
        local temp_data_1= data.answers[i]

        local is_no_in = true
        for i=1,#self.model.final_exam_answers[self.model.cur_final_question_data.qid] do
            local temp_data_2 = self.model.final_exam_answers[self.model.cur_final_question_data.qid][i]
            if temp_data_2.rid == temp_data_1.rid and temp_data_2.platform == temp_data_1.platform and temp_data_2.zone_id == temp_data_1.zone_id then
                is_no_in = false
                break
            end
        end
        if is_no_in then
            table.insert(self.model.final_exam_answers[self.model.cur_final_question_data.qid], temp_data_1)
        end

    end
    self.model:update_final_question()
    self.model:update_final_answers_list()
end

--回答问题
function ExamManager:on14511(data)
    -- print("---------------------------收到14511")

    self.model:update_final_answer_result(data)
    if data.flag == 1 then

    else

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--获取本届排行榜信息
function ExamManager:on14512(data)
    -- print("---------------------------收到14512")
    BaseUtils.dump(data)
    self.model.cur_final_rank_list = data.examination_taker
    self.model:update_final_rank_list(data)
    self.model:update_final_rank_win()
end

--偷看答案
function ExamManager:on14513(data)
    -- print("---------------------------收到14513")
    if data.flag == 1 then
        self.model:update_final_cheat_data(data)
    else

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--新加回答者推送
function ExamManager:on14514(data)
    -- print("---------------------------收到14514")

    if self.model.cur_final_question_data == nil then
        return
    end
    if self.model.final_exam_answers[self.model.cur_final_question_data.qid] == nil then
        self.model.final_exam_answers[self.model.cur_final_question_data.qid] = {}
    end

    local is_no_in = true
    for i=1,#self.model.final_exam_answers[self.model.cur_final_question_data.qid] do
        local temp_data = self.model.final_exam_answers[self.model.cur_final_question_data.qid][i]
        if temp_data.rid == data.rid and temp_data.platform == data.platform and temp_data.zone_id == data.zone_id then
            is_no_in = false
            break
        end
    end
    if is_no_in then
        table.insert(self.model.final_exam_answers[self.model.cur_final_question_data.qid], data)
    end
    self.model:update_final_answers_list()
end


--降低难度
function ExamManager:on14515(data)
    -- print("---------------------------收到14515")
    if data.flag == 1 then
        self.model:update_final_erase_data(data)
    else

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--获取个人信息
function ExamManager:on14516(data)
    -- print("---------------------------收到14516")
    self.model.cur_final_person_data = data
    self.model:update_final_person_data()
end


--使用双倍积分
function ExamManager:on14517(data)
    -- print("---------------------------收到14517")
    if data.flag == 1 then
        self.model:update_final_double_effect()
    else

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--帮助题目数据
function ExamManager:on14518(data)
    self.model.examHelpData = data
    self.model:OpenExamHelpUI()
end

--回应帮助请求
function ExamManager:on14519(data)
    self.model:CloseExamHelpUI()
    if data.flag == 1 then

    else

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


----------------------------------------协议请求逻辑
--请求活动状态
function ExamManager:request14500()
    Connection.Instance:send(14500, {})
end

--请求参与
function ExamManager:request14501(_unit_base)
    -- print("---------------------------------请求14501")
    Connection.Instance:send(14501, {unit_base = _unit_base})
end

--请求退出
function ExamManager:request14502()
    Connection.Instance:send(14502, {})
end

--请求查看当前答题信息
function ExamManager:request14503()
    -- print("---------------------------------请求14503")
    Connection.Instance:send(14503, {})
end

--请求回答问题
function ExamManager:request14504(_option)
    -- print("---------------------------------请求14504")
    Connection.Instance:send(14504, {option = _option})
end

--请求获取总成绩
function ExamManager:request14505()
    -- print("---------------------------------请求14505")
    Connection.Instance:send(14505, {})
end


--请求进入殿试场景
function ExamManager:request14506()
    -- print("---------------------------------请求14506")
    Connection.Instance:send(14506, {})
end

--请求进入殿试场景
function ExamManager:request14507()
    -- print("---------------------------------请求14507")
    Connection.Instance:send(14507, {})
end

--请求活动是否可以参加
function ExamManager:request14508()
    -- print("---------------------------------请求14508")
    Connection.Instance:send(14508, {})
end


---------决赛部分
--活动状态
function ExamManager:request14509()
    -- print("---------------------------------请求14509")
    Connection.Instance:send(14509, {})
end

--查看当前答题信息
function ExamManager:request14510()
    -- print("---------------------------------请求14510")
    Connection.Instance:send(14510, {})
end

--回答问题
function ExamManager:request14511(_id, _option)
    -- print("---------------------------------请求14511")
    Connection.Instance:send(14511, {id = _id, choice = _option})
end

--获取本届排行榜信息
function ExamManager:request14512()
    -- print("---------------------------------请求14512")
    Connection.Instance:send(14512, {})
end

--偷看答案
function ExamManager:request14513(_id)
    -- print("---------------------------------请求14513")
    print(_id)
    Connection.Instance:send(14513, {id = _id})
end

--新加回答者推送
function ExamManager:request14514()
    -- print("---------------------------------请求14514")
    Connection.Instance:send(14514, {})
end



--降低难度
function ExamManager:request14515(_id)
    -- print("---------------------------------请求14515")
    print(_id)
    Connection.Instance:send(14515, {id = _id})
end


--获取个人信息
function ExamManager:request14516()
    -- print("---------------------------------请求14516")
    Connection.Instance:send(14516, {})
end

--使用双倍积分
function ExamManager:request14517(_id)
    -- print("---------------------------------请求14517")
    Connection.Instance:send(14517, {id = _id})
end

--回应帮助请求
function ExamManager:request14519(id, option)
    -- print("---------------------------------请求14519")
    Connection.Instance:send(14519, {id = id, option = option})
end
