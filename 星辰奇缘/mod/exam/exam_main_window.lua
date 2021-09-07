ExamMainWindow  =  ExamMainWindow or BaseClass(BaseWindow)

function ExamMainWindow:__init(model)
    self.name  =  "ExamMainWindow"
    self.model  =  model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.exam_question_win, type  =  AssetType.Main},
        {file = AssetConfig.midAutumn_textures, type = AssetType.Dep},
        {file  =  AssetConfig.wingsbookbg, type  =  AssetType.Dep},
    }

    self.windowId = WindowConfig.WinID.exam_main_win

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.isHideMainUI = false

    self.total_time = 30 --答一道题的时间是三十秒
    self.timer_id = 0
    self.next_timer_id = 0
    self.total_timer_id = 0
    self.close_timer_id = 0
    self.close_tick_time = 0
    self.next_time_num = 2
    self.has_init = false
    self.result_time_str = ""
    self.result_reward_str = ""
    self.previewComp1 = nil
    self.animator = nil
end

function ExamMainWindow:OnHide()
    if self.previewComp1 ~= nil then
        self.previewComp1:Hide()
    end
end

function ExamMainWindow:OnShow()
    if self.previewComp1 ~= nil then
        self.previewComp1:Show()
    end
    self:update_question_info(self.model.cur_question_data)
end

function ExamMainWindow:__delete()
    self.PreviewBg.sprite = nil
    self.animator = nil
    if self.previewComp1 ~= nil then
        self.previewComp1:DeleteMe()
        self.previewComp1 = nil
    end
    if self.TalkTxtMsg ~= nil then
        self.TalkTxtMsg:DeleteMe()
        self.TalkTxtMsg = nil
    end
    if self.TxtExpMsg ~= nil then
        self.TxtExpMsg:DeleteMe()
        self.TxtExpMsg = nil
    end
    if self.TxtCoinMsg ~= nil then
        self.TxtCoinMsg:DeleteMe()
        self.TxtCoinMsg = nil
    end
    if self.TxtQuestionMsg ~= nil then
        self.TxtQuestionMsg:DeleteMe()
        self.TxtQuestionMsg = nil
    end
    self.has_init = false
    self:stop_timer()
    self:stop_total_timer()
    self:stop_next_timer()
    self:AssetClearAll()
end


function ExamMainWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.exam_question_win))
    self.gameObject:SetActive(false)
    self.gameObject.name = "ExamMainWindow"
    self.transform = self.gameObject.transform


    -- UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    UIUtils.AddUIChild(ChatManager.Instance.model.chatCanvas, self.gameObject)
    self.transform:SetAsLastSibling()
    -- self.transform:SetAsFirstSibling()

    self.transform:GetComponent(RectTransform).localPosition = Vector3.zero

    self.MainCon = self.gameObject.transform:Find("MainCon")
    local closeBtn = self.MainCon:Find("CloseButton"):GetComponent(Button)
    closeBtn.onClick:AddListener(function()
        self.model:CloseMainUI()
    end)

    self.MainCon:Find("ImgTitle/TxtTitle"):GetComponent(Text).text = TI18N("智慧闯关")
    self.LeftCon = self.MainCon:FindChild("LeftCon")
    self.LeftBottomCon = self.LeftCon:FindChild("BottomCon")
    self.PreviewBg = self.LeftBottomCon:FindChild("ImgBg"):GetComponent(Image)
    self.PreviewBg.sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.PreviewBg.gameObject:SetActive(true)
    self.TalkTxt = self.LeftBottomCon.transform:FindChild("ImgTalk"):FindChild("Text"):GetComponent(Text)
    self.TalkTxtMsg = MsgItemExt.New(self.TalkTxt, 190, 16, 23)
    self.Preview = self.LeftBottomCon.transform:FindChild("Preview").gameObject
    self.LeftTopCon = self.LeftCon:FindChild("TopCon")
    self.TxtConRightNum = self.LeftTopCon:FindChild("TxtConRightNum"):GetComponent(Text)
    self.TxtRightNum = self.LeftTopCon:FindChild("TxtRightNum"):GetComponent(Text)
    self.TxtWeekScore = self.LeftTopCon:FindChild("TxtWeekScore"):GetComponent(Text)
    self.TxtClock = self.LeftTopCon:FindChild("TxtClock"):GetComponent(Text)

    self.RightCon = self.MainCon:FindChild("RightCon")
    self.RightBottom = self.RightCon:FindChild("BottomCon")
    self.TxtExp = self.RightBottom:FindChild("TxtExp"):GetComponent(Text)
    self.TxtCoin = self.RightBottom:FindChild("TxtCoin"):GetComponent(Text)
    self.TxtExpMsg = MsgItemExt.New(self.TxtExp, 180, 17, 23)
    self.TxtCoinMsg = MsgItemExt.New(self.TxtCoin, 180, 17, 23)
    self.TxtScore = self.RightBottom:FindChild("TxtScore"):GetComponent(Text)
    self.BtnHelp = self.RightBottom:FindChild("BtnHelp"):GetComponent(Button)
    self.BtnHelpTxt = self.RightBottom:FindChild("BtnHelp"):FindChild("Text"):GetComponent(Text)
    self.ImgTanhao = self.RightBottom:FindChild("ImgTanhao"):GetComponent(Button)
    self.ImgTanhao.onClick:AddListener(function() self:on_click_tanhao() end)
    self.BtnHelp.onClick:AddListener(function()
        if self.data.can_ask <= 0 then
            NoticeManager.Instance:FloatTipsByString(TI18N("很抱歉，您的求助机会已经用尽了~{face_1 ,22}"))
        else
            self.transform:SetAsFirstSibling()
            SosManager.Instance:Send16000(22)
        end
    end)
    self.TxtExpMsg:SetData("0")
    self.TxtCoinMsg:SetData("0")

    self.UnOpenCon = self.RightCon:FindChild("UnOpenCon")
    self.UnOpenCon_Txt = self.UnOpenCon:FindChild("Txt"):GetComponent(Text)
    self.UnOpenGoNextBtn = self.UnOpenCon:FindChild("BtnGoNext"):GetComponent(Button)
    self.UnOpenGoNextBtn.gameObject:SetActive(false)
    self.OpenCon = self.RightCon:FindChild("OpenCon")
    self.ImgTec = self.OpenCon:FindChild("ImgTec")
    self.TxtLevDesc = self.ImgTec:FindChild("TxtLevDesc"):GetComponent(Text)
    self.TxtQuestion = self.OpenCon:FindChild("TxtQuestion"):GetComponent(Text)
    self.TxtQuestionMsg = MsgItemExt.New(self.TxtQuestion, 451, 17, 23)

    self.MidCon = self.OpenCon:FindChild("MidCon")
    self.TxtProgTime = self.MidCon:FindChild("TxtProgTime"):GetComponent(Text)
    self.ImgProg = self.MidCon:FindChild("ImgProg")
    self.ImgBar = self.ImgProg:FindChild("ImgBar")
    self.ImgBar_rect = self.ImgBar:GetComponent(RectTransform)
    self.TxtProgTime = self.MidCon:FindChild("TxtProgTime"):GetComponent(Text)

    self.btn_list = {}
    self.BottomCon = self.OpenCon:FindChild("BottomCon")
    self.Btn_A = self.BottomCon:FindChild("Btn_A"):GetComponent(Button)
    self.Text_A = self.Btn_A.transform:FindChild("Text"):GetComponent(Text)

    self.Btn_B = self.BottomCon:FindChild("Btn_B"):GetComponent(Button)
    self.Text_B = self.Btn_B.transform:FindChild("Text"):GetComponent(Text)

    self.Btn_C = self.BottomCon:FindChild("Btn_C"):GetComponent(Button)
    self.Text_C = self.Btn_C.transform:FindChild("Text"):GetComponent(Text)

    self.Btn_D = self.BottomCon:FindChild("Btn_D"):GetComponent(Button)
    self.Text_D = self.Btn_D.transform:FindChild("Text"):GetComponent(Text)

    table.insert(self.btn_list, self.Btn_A)
    table.insert(self.btn_list, self.Btn_B)
    table.insert(self.btn_list, self.Btn_C)
    table.insert(self.btn_list, self.Btn_D)

    self.ScoreCon = self.RightCon:FindChild("ScoreCon")
    self.option_normal_sprite = self.Btn_B.image.sprite
    self.option_unable_sprite = self.Btn_A.image.sprite
    self.Btn_A.onClick:AddListener(function() self:on_click_answer(1) end)
    self.Btn_B.onClick:AddListener(function() self:on_click_answer(2) end)
    self.Btn_C.onClick:AddListener(function() self:on_click_answer(3) end)
    self.Btn_D.onClick:AddListener(function() self:on_click_answer(4) end)
    self.UnOpenGoNextBtn.onClick:AddListener(function() self:on_click_go_next() end)
    self.has_init = true
    self:update_question_info(self.model.cur_question_data)
    self:update_sh_model()

    self:set_npc_talk(TI18N("请选出你认为正确的答案"))
end

------------------------------各种事件监听
--前往下一个考官
function ExamMainWindow:on_click_go_next()
    -- print("-----------------------------------------前往下一个考官")
    if self.model.cur_exam_type == 2 then
        --会试，还没答完所有考官则自动寻路到下一个考官
        local week_day = tonumber(os.date("%w",BaseUtils.BASE_TIME))
        week_day = week_day == 0 and 7 or week_day
        local today_npc_data = DataExamination.data_get_examiner[week_day]
        local npc_data = today_npc_data.location[self.data.subject+1]
        local id_battle_id = BaseUtils.get_unique_npcid(npc_data[1], 12)
        SceneManager.Instance.sceneElementsModel:Self_AutoPath(npc_data[2], id_battle_id, nil, nil, false)
    end

    self.model:CloseMainUI()
end

--选择答案
function ExamMainWindow:on_click_answer(index)
    self.transform:SetAsLastSibling()
    for i=1,#self.btn_list do
        self.btn_list[i].enabled = false
    end
    ExamManager.Instance:request14504(index)
end

--点击叹号
function ExamMainWindow:on_click_tanhao()
    local tips = {}
    local str = string.format("%s%s", self.model.exam_names[self.model.cur_exam_type], TI18N("答题："))
    if self.model.cur_exam_type == 1 then
        str = string.format("%s%s", str, TI18N("\n答对一题<color='#00ff00'>+12</color>分，答错一题<color='#ff0000'>+6</color>分"))
    else
        str = string.format("%s%s", str, TI18N("\n答对一题<color='#00ff00'>+12</color>分，答错一题<color='#ff0000'>+6</color>分，连续答对10题，分数额外<color='#00ff00'>+6</color>分"))
    end
    table.insert(tips, str)
    TipsManager.Instance:ShowText({gameObject =  self.ImgTanhao.gameObject, itemData = tips})
end


---- ------------------------各种更新事件
--更新答题结果
function ExamMainWindow:update_answer_result(data)
    if data.flag ~= 0 then
        -- print("=====================================自动回答成功，启动倒计时三秒请求14503下一题")
        self:start_next_timer()
    end
    self.BtnHelp.enabled = false

    for i=1,#self.btn_list do
        self:set_btn_answer_state(self.btn_list[i], 0)
    end
    self.TxtConRightNum.text = string.format("%s:%s", TI18N("连对"), data.successive_right)
    if data.answer == data.option then
        if data.answer ~= 0 then
            self:set_btn_answer_state(self.btn_list[data.answer], 1)
        end
        if data.successive_right >= 3 then
            self:set_npc_talk(string.format(TI18N("<color='#ff0000'>%s</color>连对了！你可真厉害{face_1,38}"), data.successive_right))
        else
            self:set_npc_talk(TI18N("答对了！你真棒{face_1,38}"))
        end
        self:play_action(1)
    else
        --错的
        if data.option ~= 0 then
            self:set_btn_answer_state(self.btn_list[data.option], 2)
        end
        if data.answer ~= 0 then
            self:set_btn_answer_state(self.btn_list[data.answer], 1)
        end
        self:set_npc_talk(TI18N("真遗憾，你回答错误了{face_1,21}"))
        self:play_action(2)
    end
    for i=1,#self.btn_list do
        self.btn_list[i].enabled = false
    end
end

--填充npc对话
function ExamMainWindow:set_npc_talk(str)
    self.TalkTxtMsg:SetData(str)
    local rect = self.TalkTxt.transform:GetComponent(RectTransform)
    rect.anchoredPosition = Vector2((200 - self.TalkTxtMsg.selfWidth) / 2 + 15, (50 - self.TalkTxtMsg.selfHeight) / 2 - 2)
end

--根据答对和答错播放动作
function ExamMainWindow:play_action(actionType)
    if actionType == 1 then
        --对
        if self.animator ~= nil then
            self.animator:Play("Idle1")
        end
        SoundManager.Instance:Play(247)
    else
        --错
        if self.animator ~= nil then
            self.animator:Play("Idle2")
        end
    end
end

--更新答题总成绩到面板
function ExamMainWindow:update_exam_result(data)
    self.UnOpenGoNextBtn.gameObject:SetActive(false)
    -- 喜您在今日院试中共答对了10题，总计获得了1000经验、800银币奖励，总耗时10分58秒
    local time_str = self.TxtClock.text
    local str = string.format("%s%s%s<color='#248813'>%s</color>%s", TI18N("恭喜您在今日"), self.model.exam_names[self.model.cur_exam_type] , TI18N("中共答对了"), data.right_num,TI18N("题，总计获得了"))
    str = string.format("%s<color='#248813'>%s</color>%s", str, data.exp ,TI18N("经验、"))
    str = string.format("%s<color='#248813'>%s</color>%s", str, data.coin ,TI18N("银币奖励，"))
    self.result_time_str = self.TxtClock.text
    self.result_reward_str = str
    str = string.format("%s%s", str, time_str)
    self.UnOpenCon_Txt.text = str
end

--更新问题内容
function ExamMainWindow:update_question_info(data)
    if self.has_init == false then
        return
    end
    self.BtnHelp.enabled = true
    self.transform:SetAsLastSibling()
    self.data = data
    self.UnOpenCon.gameObject:SetActive(false)
    self.UnOpenGoNextBtn.gameObject:SetActive(false)
    self.OpenCon.gameObject:SetActive(false)

    if data.question == 0 then
        --已经没有题目
        self.UnOpenCon.gameObject:SetActive(true)
        self:stop_total_timer()
        self.TxtScore.text = string.format("%s:<color='#ffff00'>%s</color>", TI18N("得分"), data.score)
        if self.model.cur_exam_type ~= 2 then
            self.total_time_num = data.elapsed + BaseUtils.BASE_TIME - data.started
        else
            self.total_time_num = BaseUtils.BASE_TIME - data.started
        end
        local my_date, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(self.total_time_num)
        my_minute = my_minute >= 10 and tostring(my_minute) or string.format("0%s", my_minute)
        my_second = my_second >= 10 and tostring(my_second) or string.format("0%s", my_second)
        self.TxtClock.text = string.format(TI18N("总耗时:<color='#248813'>%s分%s秒</color>"), my_minute, my_second)

        self.result_time_str = self.TxtClock.text
        self.UnOpenCon_Txt.text = string.format("%s%s", self.result_reward_str, self.result_time_str)

        if data.total <= data.answered then
            --答完所有题请求总成绩
            ExamManager.Instance:request14505()
        elseif self.model.cur_exam_type == 2 then
            --会试，一个考官答完了题
            self.UnOpenGoNextBtn.gameObject:SetActive(true)
        end
        return
    end
    self.OpenCon.gameObject:SetActive(true)

    for i=1,#self.btn_list do
        self.btn_list[i].enabled = true
    end

    self.data.left_time = data.expire - BaseUtils.BASE_TIME

    if (self.data.left_time > 20 or self.data.left_time <= 0) and self.model.cur_exam_type ~= 3  then
        self.MidCon.gameObject:SetActive(false)
        self:stop_timer()
    elseif self.data.left_time <= 0 and self.model.cur_exam_type == 3 then
        --殿试超时，这道题已经超时，自动帮他回答
        self:on_click_answer(0)
    else
        self.MidCon.gameObject:SetActive(true)
        self.data.left_time = self.data.left_time > 20 and 20 or self.data.left_time
        self:start_timer()
    end

    -- local question_cfg_data = DataQuestion.data_guild_question_cfg[data.question]
    local question_cfg_data = nil
    if data.dynamics ~= nil then
        for k, v in pairs(data.dynamics) do
            if v.id == data.question then
                question_cfg_data = {id = v.id, question = v.desc, option_a = "", option_b = "", option_c = "", option_d = "", subject = 6}
                for k2, v2 in pairs(v.options) do
                    if v2.opt_id == 1 then
                        question_cfg_data.option_a = v2.opt_desc
                    elseif v2.opt_id == 2 then
                        question_cfg_data.option_b = v2.opt_desc
                    elseif v2.opt_id == 3 then
                        question_cfg_data.option_c = v2.opt_desc
                    elseif v2.opt_id == 4 then
                        question_cfg_data.option_d = v2.opt_desc
                    end
                end
                break
            end
        end
    end
    if question_cfg_data == nil then
        question_cfg_data = DataQuestion.data_guild_question_cfg[data.question]
    end

    self.TxtLevDesc.text = self.model.exam_names[self.model.cur_exam_type]
    local total = data.total
    local fenzi = data.answered+1
    if self.model.cur_exam_type == 2 then
        --会试
        total = 3
        fenzi = fenzi%3
        fenzi = fenzi == 0 and 3 or fenzi
    end
    self.TxtQuestionMsg:SetData(string.format("<color='#3166ad'>%s%s/%s%s:</color><color='%s'>[%s]</color>%s", TI18N("第"), fenzi, total, TI18N("题"), self.model.exam_type_name_colors[question_cfg_data.subject] , self.model.exam_type_name[question_cfg_data.subject], question_cfg_data.question))
    -- self.TxtQuestion.text = string.format("<color='#7EB9F7'>%s%s/%s%s:</color><color='%s'>[%s]</color>%s", TI18N("第"), fenzi, total, TI18N("题"), self.model.exam_type_name_colors[question_cfg_data.subject] , self.model.exam_type_name[question_cfg_data.subject], question_cfg_data.question)

    self:update_btn_state(self.Btn_A, self.Text_A, question_cfg_data.option_a, "A.")
    self:update_btn_state(self.Btn_B, self.Text_B, question_cfg_data.option_b, "B.")
    self:update_btn_state(self.Btn_C, self.Text_C, question_cfg_data.option_c, "C.")
    self:update_btn_state(self.Btn_D, self.Text_D, question_cfg_data.option_d, "D.")


    self.TxtScore.text = string.format("%s:<color='#ffff00'>%s</color>", TI18N("得分"), data.score)

    if data.question == 0 then
        self.total_time_num = data.elapsed
    else
        if self.model.cur_exam_type ~= 2 then
            self.total_time_num = data.elapsed + BaseUtils.BASE_TIME - data.started
        else
            self.total_time_num = BaseUtils.BASE_TIME - data.started
        end
    end

    if self.model.cur_exam_type == 3 then
        self.ScoreCon.gameObject:SetActive(false)
    else
        self.ScoreCon.gameObject:SetActive(true)
    end

    self:start_total_timer()
    if self.data.can_ask <= 0 then
        --按钮灰掉
        self.BtnHelp.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.BtnHelpTxt.color = ColorHelper.DefaultButton4
    else
        self.BtnHelp.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        self.BtnHelpTxt.color = ColorHelper.DefaultButton2
    end
    self.BtnHelpTxt.text = string.format("%s(%s/%s)", TI18N("求助"), self.data.can_ask, self.model:get_help_num())
    self.TxtConRightNum.text = string.format("%s:%s", TI18N("连对"), self.data.successive_right)
    self.TxtRightNum.text = string.format("%s:%s/%s", TI18N("正确数"), self.data.right_num, self.data.answered)
    self.TxtWeekScore.text = string.format("%s:%s", TI18N("本周智慧积分"), self.data.score_all)
    self.TxtExpMsg:SetData(string.format("%s", self.data.exp))
    self.TxtCoinMsg:SetData(string.format("%s", self.data.pet_ext))

    -- if self.data.successive_right >= 3 then
    --     self:set_npc_talk(string.format(TI18N("<color='#ffff00'>%s</color>连对了！你可真厉害{face_1,11}"), self.data.successive_right))
    -- else
        self:set_npc_talk(TI18N("请选出你认为正确的答案"))
    -- end
end

--根据传入的答案状态设置按钮是否显示
function ExamMainWindow:update_btn_state(btn, btn_txt, btn_str, prefix)
    if btn_str == "" then
        btn.gameObject:SetActive(false)
        self:set_btn_state(btn, false)
    else
        btn.gameObject:SetActive(true)
        self:set_btn_state(btn, true)
        self:set_btn_answer_state(btn, 0)
        btn_txt.text = string.format("%s%s" , prefix, btn_str)
    end
end

--更新传入按钮的状态
function ExamMainWindow:set_btn_state(btn, state)
    btn.enabled = state
    if state then
        btn.image.sprite = self.option_normal_sprite
    else
        btn.image.sprite = self.option_unable_sprite
    end
end

--设置按钮的对错状态
function ExamMainWindow:set_btn_answer_state(btn, flag)
    local imgRight = btn.transform:FindChild("ImgRight").gameObject
    local imgWrong = btn.transform:FindChild("ImgWrong").gameObject
    if flag == 0 then
        imgRight:SetActive(false)
        imgWrong:SetActive(false)
    elseif flag == 1 then
        imgRight:SetActive(true)
        imgWrong:SetActive(false)
    elseif flag == 2 then
        imgRight:SetActive(false)
        imgWrong:SetActive(true)
    end
end

--更新按钮答案内容
function ExamMainWindow:update_btn_txt(btn_txt, btn_str)
    btn_txt.text = btn_str
end




-----------------------------更新得分
function ExamMainWindow:update_score()
    self.TxtScore.text = ""
end

----------------------------更新时间
function ExamMainWindow:update_time()
    self.TxtClock.text = ""
end



-----------------------------------------------计时器逻辑
--开始战斗倒计时
function ExamMainWindow:start_timer()
    self:stop_timer()
    self.timer_id = LuaTimer.Add(0, 100, function() self:timer_tick() end)
end

function ExamMainWindow:stop_timer()
    if self.timer_id ~= 0 then
        LuaTimer.Delete(self.timer_id)
        self.timer_id = 0
    end
end

function ExamMainWindow:timer_tick()
    if self.data == nil or self.data.left_time == nil then
        self:stop_timer()
        return
    end
    self.data.left_time = self.data.left_time - 0.1
    if self.data.left_time >= 0 then
        local percent = self.data.left_time/20
        self.ImgBar_rect.sizeDelta = Vector2(342*percent, 14)
        self.TxtProgTime.text = string.format("%s%s", math.floor(self.data.left_time), TI18N("秒后下一题"))
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("答题超时"))
        self:on_click_answer(0)
        self:stop_timer()
    end
end


------------------------------请求下一道题计时
function ExamMainWindow:start_next_timer()
    self:stop_next_timer()
    self.next_timer_id = LuaTimer.Add(0, 1000, function() self:timer_next_tick() end)
end

function ExamMainWindow:stop_next_timer()
    if self.next_timer_id ~= 0 then
        LuaTimer.Delete(self.next_timer_id)
        self.next_timer_id = 0
        self.next_time_num = 2
    end
end

function ExamMainWindow:timer_next_tick()
    self.next_time_num = self.next_time_num - 1
    if self.next_time_num >= 0 then

    else
        ExamManager.Instance:request14503()
        self:stop_next_timer()
    end
end


--累计总耗时计时器
function ExamMainWindow:start_total_timer()
    self:stop_total_timer()
    self.total_timer_id = LuaTimer.Add(0, 1000, function() self:timer_total_tick() end)
end

function ExamMainWindow:stop_total_timer()
    if self.total_timer_id ~= 0 then
        LuaTimer.Delete(self.total_timer_id)
        self.total_timer_id = 0
    end
end

function ExamMainWindow:timer_total_tick()
    self.total_time_num = self.total_time_num + 1
    local my_date, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(self.total_time_num)
    my_minute = my_minute >= 10 and tostring(my_minute) or string.format("0%s", my_minute)
    my_second = my_second >= 10 and tostring(my_second) or string.format("0%s", my_second)
    self.TxtClock.text = string.format("%s:<color='#248813'>%s%s%s%s</color>", TI18N("总耗时"), my_minute, TI18N("分"), my_second, TI18N("秒"))
end


--计时关掉界面
function ExamMainWindow:start_close_timer()
    self:stop_close_timer()
    self.close_timer_id = LuaTimer.Add(0, 1000, function() self:timer_close_tick() end)
end

function ExamMainWindow:stop_close_timer()
    if self.close_timer_id ~= 0 then
        LuaTimer.Delete(self.close_timer_id)
        self.close_timer_id = 0
        self.close_tick_time = 0
    end
end

function ExamMainWindow:timer_close_tick()
    self.close_tick_time = self.close_tick_time + 1
    if self.close_tick_time >= 3 then
        self:stop_close_timer()
        self.model:CloseMainUI()
    end
end

--显示模型模型
function ExamMainWindow:update_sh_model()
    local cfgData = DataUnit.data_unit[self.model.exam_model_id]
    local previewComp = nil
    local callback = function(composite)
        self:on_model_build_completed(composite)
    end
    local setting = {
        name = "ExamModel"
        ,orthographicSize = 0.65
        ,width = 341
        ,height = 341
        ,offsetY = -0.4
    }
    local modelData = {type = PreViewType.Npc, skinId = cfgData.skin, modelId = cfgData.res, animationId = cfgData.animation_id, scale = 1.5}
    if self.previewComp1 == nil then
        self.previewComp1 = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp1:Reload(modelData, callback)
    end
end

--守护模型加载完成
function ExamMainWindow:on_model_build_completed(composite)
    local rawImage = composite.rawImage
    self.animator = composite.tpose:GetComponent(Animator)
    rawImage.transform:SetParent(self.Preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
end
