ExamModel = ExamModel or BaseClass(BaseModel)

function ExamModel:__init()
    self.main_win = nil

    self.exam_names = {[1] = TI18N("智慧闯关"), [2] = TI18N("智慧闯关-半决赛"), [3] = TI18N("智慧闯关-决赛")}
    self.exam_type_name = {[0]= TI18N("百科"), [1] = TI18N("历史"), [2] = TI18N("科普"), [3] = TI18N("常识"), [4] = TI18N("游戏"), [5] = TI18N("益智"), [6] = TI18N("动态")}

    self.exam_type_name_colors = {[0]= "#ff0000", [1] = "#e9e22a", [2] = "#248813", [3] = "#248813", [4] = "#d781f2", [5] = "#c3692c", [6] = "#c3692c"}


    self.final_exam_answers = nil  --决赛回答者列表
    self.cur_final_question_data = nil
    self.cur_final_person_data = nil
    self.cur_final_rank_list = {}

    self.cur_exam_type = 0 --"类型：1院试，2会试，3殿试"}
    self.cur_exam_status = -1 --"0未开始，1通知，2开始"}
    self.cur_exam_left_time = 0 --"剩余时间(秒)"}
    self.cur_final_prepare_left_time = 0
    self.main_win = nil
    self.my_score_win = nil
    self.final_exam_win = nil
    self.final_exam_rank_win = nil
    self.help_exam_win = nil
    self.my_score_data = nil
    self.exam_model_id = 79850
    self.examHelpData = nil

    self.newExamDescWindow = nil
    self.newExamTopWindow = nil
    self.newExamRankWindow = nil
end

function ExamModel:__delete()

end

------------------------------打开界面和关闭界面逻辑
--打开主界面
function ExamModel:InitMainUI()
    if self.main_win == nil then
        self.main_win = ExamMainWindow.New(self)
        self.main_win:Open()
    else
        self.main_win:update_question_info(self.cur_question_data)
    end
end

function ExamModel:CloseMainUI()
    if self.main_win ~= nil then
        WindowManager.Instance:CloseWindow(self.main_win)
    end
    if self.main_win == nil then
        -- print("===================self.main_win is nil")
    else
        -- print("===================self.main_win is not nil")
    end
end


--打开我的得分界面
function ExamModel:InitMyScoreUI()
    if self.my_score_win == nil then
        self.my_score_win = ExamMyScoreWindow.New(self)
        self.my_score_win:Open()
    end
end

function ExamModel:CloseMyScoreUI()
    if self.my_score_win ~= nil then
        WindowManager.Instance:CloseWindow(self.my_score_win)
    end
    if self.my_score_win == nil then
        -- print("===================self.my_score_win is nil")
    else
        -- print("===================self.my_score_win is not nil")
    end
end


--打开答题决赛界面
function ExamModel:OpenFinalExamUI()
    if self.final_exam_win == nil then
        self.final_exam_win = ExamFinalWindow.New(self)
    end
    self.final_exam_win:Open()
end

--关闭答题决赛界面
function ExamModel:CloseFinalExamUI()
    if self.final_exam_win ~= nil then
        WindowManager.Instance:CloseWindow(self.final_exam_win)
    end
    if self.final_exam_win == nil then
        -- print("===================self.final_exam_win is nil")
    else
        -- print("===================self.final_exam_win is not nil")
    end
end

--打开答题决赛排行榜界面
function ExamModel:OpenFinalExamRankUI()
    if self.final_exam_rank_win == nil then
        self.final_exam_rank_win = ExamFinalRankWindow.New(self)
    end
    self.final_exam_rank_win:Open()
end

--关闭答题决赛排行榜界面
function ExamModel:CloseFinalExamRankUI()
    if self.final_exam_rank_win ~= nil then
        WindowManager.Instance:CloseWindow(self.final_exam_rank_win)
    end
    if self.final_exam_rank_win == nil then
        -- print("===================self.final_exam_rank_win is nil")
    else
        -- print("===================self.final_exam_rank_win is not nil")
    end
end

--开启答题帮助界面
function ExamModel:OpenExamHelpUI()
    if self.help_exam_win == nil then
        self.help_exam_win = ExamMainHelpWindow.New(self)
    end
    self.help_exam_win:Open()
end

--关闭答题帮助界面
function ExamModel:CloseExamHelpUI()
    if self.help_exam_win ~= nil then
        WindowManager.Instance:CloseWindow(self.help_exam_win)
    end
    if self.help_exam_win == nil then
        -- print("===================self.help_exam_win is nil")
    else
        -- print("===================self.help_exam_win is not nil")
    end
end

-------------------------------各种更新界面逻辑
--更新答题界面信息
function ExamModel:update_question_info(data)
    if self.main_win ~= nil then
        self.main_win:update_question_info(data)
    end
end

--更新答题结果
function ExamModel:update_answer_result(data)
    if self.main_win ~= nil then
        self.main_win:update_answer_result(data)
    end
end

--更新答题总成绩到答题面板
function ExamModel:update_exam_result(data)
    if self.main_win ~= nil then
        self.main_win:update_exam_result(data)
    end
end

--更新决赛界面的题目信息
function ExamModel:update_final_question()
    if self.final_exam_win ~= nil then
        self.final_exam_win:update_question_info()
    end
end

--更新决赛界面的排行榜信息
function ExamModel:update_final_rank_list(data)
    if self.final_exam_win ~= nil then
        self.final_exam_win:update_rank_list(data)
    end
end

--更新决赛界面回答者列表
function ExamModel:update_final_answers_list()
    if self.final_exam_win ~= nil then
        self.final_exam_win:update_answer_list()
    end
end

--更新决赛答题结果
function ExamModel:update_final_answer_result(data)
    if self.final_exam_win ~= nil then
        self.final_exam_win:update_answer_result(data)
    end
end

--更新决赛面板底部个人信息
function ExamModel:update_final_person_data()
    if self.final_exam_win ~= nil then
        self.final_exam_win:update_final_person_data()
    end
end

--降低难度某个答案
function ExamModel:update_final_erase_data(data)
    if self.final_exam_win ~= nil then
        self.final_exam_win:update_final_erase_data(data)
    end
end


--偷看答案
function ExamModel:update_final_cheat_data(data)
    if self.final_exam_win ~= nil then
        self.final_exam_win:update_final_cheat_data(data)
    end
end

--播放双倍特效
function ExamModel:update_final_double_effect()
    if self.final_exam_win ~= nil then
        self.final_exam_win:update_final_double_effect()
    end
end

--答题决赛，显示
function ExamModel:do_update_view()
    if self.final_exam_win ~= nil then
        self.final_exam_win:do_show_view()
    end
end

--答题决赛排行榜
function ExamModel:update_final_rank_win()
    if self.final_exam_rank_win ~= nil then
        self.final_exam_rank_win:update_info()
    end
end


--根据当前时间日期，获取npcdata
function ExamModel:get_npc_data_by_date()
    local week_day = tonumber(os.date("%w",BaseUtils.BASE_TIME))
    week_day = week_day == 0 and 7 or week_day
    local cfg_data = DataExamination.data_get_examiner[week_day]
    local npc_data = cfg_data.location[1]
    return npc_data
end

--根据当前是周几，获取答题的可帮助次数
function ExamModel:get_help_num()
    local week_day = tonumber(os.date("%w",BaseUtils.BASE_TIME))
    week_day = week_day == 0 and 7 or week_day
    if week_day == 6 then
        return 3
    else
        return 2
    end
end