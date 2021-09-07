-- --------------------------
-- 科举答题
-- --------------------------
MainuiExamQuestionPanel = MainuiExamQuestionPanel or BaseClass(BaseTracePanel)

function MainuiExamQuestionPanel:__init(main)
    self.main = main
    self.isInit = true
    self.model = ExamManager.Instance.model
    self.left_time = 0
    self.timer_id = 0

    self.resList = {
        {file = AssetConfig.examqueston_content, type = AssetType.Main}
    }

    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MainuiExamQuestionPanel:__delete()
    self.OnHideEvent:Fire()
    self.isInit = false
end

function MainuiExamQuestionPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.examqueston_content))
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.transform:Find("Main/Container"))
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition = Vector3(0, -45, 0)

    self.rect = self.gameObject:GetComponent(RectTransform)

    self.transform = self.gameObject.transform
    self.imgBg_btn = self.transform:FindChild("ImgBg"):GetComponent(Button)
    self.FinishContainer = self.transform:FindChild("FinishContainer")
    self.FinishTxt = self.FinishContainer:FindChild("TxtDesc"):GetComponent(Text)
    self.GuildQuestionContainer = self.transform:FindChild("GuildQuestionContainer")
    self.Act_name_txt = self.GuildQuestionContainer:FindChild("TxtDesc"):GetComponent(Text)
    self.con_btn = self.GuildQuestionContainer:GetComponent(Button)
    self.taskItem = self.GuildQuestionContainer:FindChild("taskItem")
    self.mobnameText = self.taskItem:FindChild("mobnameText"):GetComponent(Text)
    self.ActText_1 = self.taskItem:FindChild("ActText")
    self.ClockImage_1 = self.taskItem:FindChild("ClockImage")

    self.taskItem2 = self.GuildQuestionContainer:FindChild("taskItem2")
    self.mobnameText2 = self.taskItem2:FindChild("mobnameText"):GetComponent(Text)
    self.ActText_2 = self.taskItem2:FindChild("ActText")
    self.ClockImage_2 = self.taskItem2:FindChild("ClockImage")

    self.taskItem5 = self.GuildQuestionContainer:FindChild("taskItem5")
    self.TxtTeacher_desc = self.taskItem5:FindChild("Text")
    self.TxtTeacher = self.taskItem5:FindChild("TxtDesc"):GetComponent(Text)

    self.mobnameText.transform:GetComponent(CanvasGroup).blocksRaycasts = false
    self.ActText_1:GetComponent(CanvasGroup).blocksRaycasts = false
    self.ClockImage_1:GetComponent(CanvasGroup).blocksRaycasts = false
    self.mobnameText2.transform:GetComponent(CanvasGroup).blocksRaycasts = false
    self.ClockImage_2:GetComponent(CanvasGroup).blocksRaycasts = false
    self.ActText_2:GetComponent(CanvasGroup).blocksRaycasts = false
    self.TxtTeacher_desc:GetComponent(CanvasGroup).blocksRaycasts = false
    self.TxtTeacher.transform:GetComponent(CanvasGroup).blocksRaycasts = false

    self.BtnQuick = self.transform:FindChild("BtnQuick"):GetComponent(Button)

    self.FinishContainer.gameObject:SetActive(false)
    self.GuildQuestionContainer.gameObject:SetActive(true)

    self.BtnQuick.onClick:AddListener(function() self:on_click_quick() end)
    self.con_btn.onClick:AddListener(function() self:on_click_con() end)
    self.imgBg_btn.onClick:AddListener(function() self:on_click_con() end)
    self.isInit = true

    if self.data ~= nil then
        self:update_info(self.data)
    end
    ExamManager.Instance:request14503()
end

function MainuiExamQuestionPanel:OnShow()
end

function MainuiExamQuestionPanel:OnHide()
end

function MainuiExamQuestionPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end


--点击事件
--点击退出按钮
function MainuiExamQuestionPanel:on_click_quick()
    if self.model.cur_exam_type == 2 then
        --会试
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("退出考试后再进行考试会额外增加30秒用时，是否确认要退出考试？")
        data.sureLabel = TI18N("确认")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function() ExamManager.Instance:request14502()  end
        NoticeManager.Instance:ConfirmTips(data)
    elseif self.model.cur_exam_type == 3 then
        --殿试
        SceneManager.Instance.sceneElementsModel:Self_Transport(10001, 0, 0)
    end
end

--点击主容器寻路到npc
function MainuiExamQuestionPanel:on_click_con()
    -- local cfg_data = DataExamination.data_get_examiner[self.data.subject]
    -- if self.data.next_subject ~= 0 then
    --有下任考官
    local index = 2
    if self.model.cur_exam_type == 2 then
        --会试
        index = 2
    elseif self.model.cur_exam_type == 3 then
        index = 1
    end
    local week_day = tonumber(os.date("%w",BaseUtils.BASE_TIME))
    week_day = week_day == 0 and 7 or week_day
    local today_npc_data = DataExamination.data_get_examiner[week_day]
    local npc_data = today_npc_data.location[self.data.subject+1]
    local id_battle_id = BaseUtils.get_unique_npcid(npc_data[1], 12)
    SceneManager.Instance.sceneElementsModel:Self_AutoPath(npc_data[2], id_battle_id, nil, nil, false)
end

--更新面板信息
function MainuiExamQuestionPanel:update_info(data)
    self.data = data
    if self.isInit == false then
        return
    end

    self.FinishContainer.gameObject:SetActive(false)
    self.GuildQuestionContainer.gameObject:SetActive(true)

    local week_day = tonumber(os.date("%w",BaseUtils.BASE_TIME))
    week_day = week_day == 0 and 7 or week_day
    local today_npc_data = DataExamination.data_get_examiner[week_day]
    local next_cfg_data = today_npc_data.location[data.subject + 1]

    local npc_data = self.model:get_npc_data_by_date()


    self.Act_name_txt.text = string.format("%s%s%s", TI18N("您的当前"), self.model.exam_names[self.model.cur_exam_type],TI18N("成绩："))

    if self.model.cur_exam_type == 2 then
        --会试
        self.TxtTeacher_desc:GetComponent(Text).text = TI18N("前往下一考官:")
    elseif self.model.cur_exam_type == 3 then
        --殿试
        self.TxtTeacher_desc:GetComponent(Text).text = TI18N("前往总考官:")

        if data.total <= data.answered then
            self.FinishContainer.gameObject:SetActive(true)
            self.GuildQuestionContainer.gameObject:SetActive(false)
            self.FinishTxt.text = string.format(TI18N("您已经完成了<color='#ffff00'>%s</color>所有答题，决赛最终成绩会在活动结束时发布"), self.model.exam_names[self.model.cur_exam_type])
        end
    end

    --更新答对数
    self.mobnameText2.text = string.format("%s%s", data.right_num, TI18N("题"))
    if next_cfg_data ~= nil then
        self.TxtTeacher.text = DataUnit.data_unit[next_cfg_data[1]].name
    else
        self.TxtTeacher.text = TI18N("已完成")
    end

    if data.question == 0 then
        self.time_num = data.elapsed
    else
        if self.model.cur_exam_type ~= 2 then
            self.time_num = data.elapsed + BaseUtils.BASE_TIME - data.started
        else
            self.time_num = BaseUtils.BASE_TIME - data.started
        end
    end

    local _,_, my_minute, my_second = BaseUtils.time_gap_to_timer(self.time_num)
    my_minute = my_minute >= 10 and tostring(my_minute) or string.format("0%s", my_minute)
    my_second = my_second >= 10 and tostring(my_second) or string.format("0%s", my_second)
    self.mobnameText.text = string.format("<color='#8DE92A'>%s:%s</color>", my_minute, my_second)

    self:start_timer()
end

--更新答对数
function MainuiExamQuestionPanel:update_mid_time()
    self.mobnameText2.text = ""
end

--更新下一位考官
function MainuiExamQuestionPanel:update_next_teacher()
    self.TxtTeacher.text = ""
end


------------------------------------------计时关掉界面
function MainuiExamQuestionPanel:start_timer()
    self:stop_timer()
    self.timer_id = LuaTimer.Add(0, 1000, function() self:timer_tick() end)
end

function MainuiExamQuestionPanel:stop_timer()
    if self.timer_id ~= 0 then
        LuaTimer.Delete(self.timer_id)
        self.timer_id = 0
    end
end

function MainuiExamQuestionPanel:timer_tick()
    self.time_num = self.time_num + 1
    local _,_, my_minute, my_second = BaseUtils.time_gap_to_timer(self.time_num)
    my_minute = my_minute >= 10 and tostring(my_minute) or string.format("0%s", my_minute)
    my_second = my_second >= 10 and tostring(my_second) or string.format("0%s", my_second)
    self.mobnameText.text = string.format("<color='#8DE92A'>%s:%s</color>", my_minute, my_second)
end


