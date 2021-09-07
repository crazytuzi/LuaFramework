-- ------------------------------
-- 师徒答题界面
-- hosr
-- ------------------------------
QuestAnswerTeacherPanel = QuestAnswerTeacherPanel or BaseClass(BasePanel)

function QuestAnswerTeacherPanel:__init(model)
    self.model = model

    self.path = "prefabs/ui/exam/teacherquestionwindow.unity3d"

    self.resList = {
        {file = self.path, type = AssetType.Main}
    }

    -- 窗口隐藏事件
    self.OnHideEvent:Add(function() self:OnHide() end)
    -- 窗口打开事件
    self.OnOpenEvent:Add(function() self:OnShow() end)

    self.answerTab = {}
    self.buttons = {}

    self.loopId = nil

    -- 是否选择答案
    self.isSelect = false
    self.isTimeout = false

    self.prefix = {"A.", "B.", "C.", "D."}

    self.nextId = 0

    self.pos1 = Vector2(18, 0)
    self.pos2 = Vector2(75, 0)

    self.option2index = {}
    self.barMax = 345

    -- 上一次题目
    self.lastSid = 0

    self.hasDestory = false
end

function QuestAnswerTeacherPanel:__delete()
    self.hasDestory = true
    if self.loopId ~= nil then
        LuaTimer.Delete(self.loopId)
        self.loopId = nil
    end
    if self.nextId ~= 0 then
        LuaTimer.Delete(self.nextId)
        self.nextId = 0
    end
    self.model = nil
    self.answerTab = nil
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.lastSid = 0
end

function QuestAnswerTeacherPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "QuestAnswerTeacherPanel"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform
    self.transform:Find("MainCon/CloseButton"):GetComponent(Button).onClick:AddListener(function() QuestMarryManager.Instance:ClosePanel()end)
    self.titleTxt = self.transform:Find("MainCon/ImgTitle/TxtTitle"):GetComponent(Text)
    self.titleTxt.text = TI18N("师徒答题")

    self.scoreObj = self.transform:Find("MainCon/ScoreCon").gameObject
    self.scoreObj:SetActive(false)
    self.answerTitle = self.transform:Find("MainCon/OpenCon/ImgTec/TxtLevDesc"):GetComponent(Text)
    self.answerTitle.text = TI18N("心有灵犀")

    self.question = self.transform:Find("MainCon/OpenCon/TxtQuestion"):GetComponent(Text)

    self.progressObj = self.transform:Find("MainCon/OpenCon/MidCon").gameObject
    self.statusTxt = self.transform:Find("MainCon/OpenCon/MidCon/Status"):GetComponent(Text)
    self.statusTxt.text = ""
    self.barRect = self.transform:Find("MainCon/OpenCon/MidCon/ImgProg/ImgBar"):GetComponent(RectTransform)
    self.barRect.sizeDelta = Vector2.zero
    self.timeTxt = self.transform:Find("MainCon/OpenCon/MidCon/TxtProgTime"):GetComponent(Text)

    self.btnA = self.transform:Find("MainCon/OpenCon/BottomCon/Btn_A")
    self.btnB = self.transform:Find("MainCon/OpenCon/BottomCon/Btn_B")
    self.btnC = self.transform:Find("MainCon/OpenCon/BottomCon/Btn_C")
    self.btnD = self.transform:Find("MainCon/OpenCon/BottomCon/Btn_D")

    self.btnA:GetComponent(Button).onClick:AddListener(function() self:ClickBtn(1) end)
    self.btnB:GetComponent(Button).onClick:AddListener(function() self:ClickBtn(2) end)
    self.btnC:GetComponent(Button).onClick:AddListener(function() self:ClickBtn(3) end)
    self.btnD:GetComponent(Button).onClick:AddListener(function() self:ClickBtn(4) end)

    self.buttons = {
        {
            gameObject = self.btnA.gameObject,
            txt = self.btnA:Find("Text"):GetComponent(Text),
            hasbund = self.btnA:Find("ImgHasbund").gameObject,
            wife = self.btnA:Find("ImgWife").gameObject,
            hasbundRect = self.btnA:Find("ImgHasbund"):GetComponent(RectTransform),
            wifeRect = self.btnA:Find("ImgWife"):GetComponent(RectTransform),
            img = self.btnA.gameObject:GetComponent(Image),
            tick = self.btnA:Find("Tick").gameObject,
        },
        {
            gameObject = self.btnB.gameObject,
            txt = self.btnB:Find("Text"):GetComponent(Text),
            hasbund = self.btnB:Find("ImgHasbund").gameObject,
            wife = self.btnB:Find("ImgWife").gameObject,
            hasbundRect = self.btnB:Find("ImgHasbund"):GetComponent(RectTransform),
            wifeRect = self.btnB:Find("ImgWife"):GetComponent(RectTransform),
            img = self.btnB.gameObject:GetComponent(Image),
            tick = self.btnB:Find("Tick").gameObject,
        },
        {
            gameObject = self.btnC.gameObject,
            txt = self.btnC:Find("Text"):GetComponent(Text),
            hasbund = self.btnC:Find("ImgHasbund").gameObject,
            wife = self.btnC:Find("ImgWife").gameObject,
            hasbundRect = self.btnC:Find("ImgHasbund"):GetComponent(RectTransform),
            wifeRect = self.btnC:Find("ImgWife"):GetComponent(RectTransform),
            img = self.btnC.gameObject:GetComponent(Image),
            tick = self.btnC:Find("Tick").gameObject,
        },
        {
            gameObject = self.btnD.gameObject,
            txt = self.btnD:Find("Text"):GetComponent(Text),
            hasbund = self.btnD:Find("ImgHasbund").gameObject,
            wife = self.btnD:Find("ImgWife").gameObject,
            hasbundRect = self.btnD:Find("ImgHasbund"):GetComponent(RectTransform),
            wifeRect = self.btnD:Find("ImgWife"):GetComponent(RectTransform),
            img = self.btnD.gameObject:GetComponent(Image),
            tick = self.btnD:Find("Tick").gameObject,
        },
    }

    self:OnShow()
end

function QuestAnswerTeacherPanel:OnShow()
    self:UpdateQuestion()
end

function QuestAnswerTeacherPanel:OnHide()
end

function QuestAnswerTeacherPanel:ClickBtn(index)
    if not self.isTimeout then
        if self.isSelect then
            return
        end
        self:ShowWhoAnswered(index, true)
        self.isSelect = true
        local answer = self.answerTab[index]
        local id = answer.id
        QuestMarryManager.Instance:Send16101(QuestManager.Instance.teacher_question, self.openArgs.sid, answer.id)
        self:TimeOut()
    else
        print("已提交过超时作答")
    end
end

function QuestAnswerTeacherPanel:TimeOut()
    if not self.isSelect and self.openArgs.status == 0 then
        -- print("==================== 发送答题超时 ================")
        self:Over()
        self.isTimeout = true
        QuestMarryManager.Instance:Send16101(QuestManager.Instance.teacher_question, self.openArgs.sid, 0)
    end
end

function QuestAnswerTeacherPanel:Over()
    if self.loopId ~= nil then
        LuaTimer.Delete(self.loopId)
        self.loopId = nil
    end
    self.timeTxt.text = ""
    self.barRect.sizeDelta = Vector2(0, 14)
end

function QuestAnswerTeacherPanel:Reset()
    if self.loopId ~= nil then
        LuaTimer.Delete(self.loopId)
        self.loopId = nil
    end
    if self.nextId ~= 0 then
        LuaTimer.Delete(self.nextId)
        self.nextId = 0
    end
    self.statusTxt.text = ""
    self.timeTxt.text = ""
    for i,v in ipairs(self.buttons) do
        v.hasbund:SetActive(false)
        v.wife:SetActive(false)
        v.img.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        v.tick:SetActive(false)
    end
end

function QuestAnswerTeacherPanel:UpdateQuestion()
    print("更新题目")

    self:Reset()

    self.isSelect = false
    self.isTimeout = false

    self.questionData = DataQuestion.data_teacher_question[self.openArgs.qid]
    local questionStr = self.questionData.question

    self.answerTab = {}
    if self.questionData.option_a ~= "" then
        table.insert(self.answerTab, {id = 1, str = self.questionData.option_a})
    end
    if self.questionData.option_b ~= "" then
        table.insert(self.answerTab, {id = 2, str = self.questionData.option_b})
    end
    if self.questionData.option_c ~= "" then
        table.insert(self.answerTab, {id = 3, str = self.questionData.option_c})
    end
    if self.questionData.option_d ~= "" then
        table.insert(self.answerTab, {id = 4, str = self.questionData.option_d})
    end

    self.question.text = string.format(TI18N("第%s/3题:%s"), self.openArgs.sid, questionStr)

    self.option2index = {}
    self:ShowAnswer()

    self:SetTimeout()

    -- 根据当前状态恢复
    self:UpdateStatus(self.openArgs.status, self.openArgs.option)
end

function QuestAnswerTeacherPanel:UpdateStatus(status, option)
    if self.statusTxt == nil then
        return
    end
    if status == 1 then
        self.isSelect = true
        self.statusTxt.text = TI18N("等待对方选择")
        local index = self.option2index[option]
        self:ShowWhoAnswered(index, true)
    elseif status == 2 then
        self.statusTxt.text = TI18N("对方已经选择")
    end
end

function QuestAnswerTeacherPanel:ShowAnswer()
    for i,btn in ipairs(self.buttons) do
        local answer = self.answerTab[i]
        if answer ~= nil then
            btn.txt.text = self.prefix[i] .. answer.str
            btn.gameObject:SetActive(true)
            self.option2index[answer.id] = i
            btn.img.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        else
            btn.gameObject:SetActive(false)
        end
    end
end

function QuestAnswerTeacherPanel:SetTimeout()
    self.less = 20 - (BaseUtils.BASE_TIME - self.openArgs.start_time)
    if self.less > 0 then
        self.loopId = LuaTimer.Add(0, 100, function() self:Loop() end)
    else
        self:TimeOut()
    end
end

function QuestAnswerTeacherPanel:Loop()
    if self.less > 0.1 then
        self.less = self.less - 0.1
        self.timeTxt.text = string.format(TI18N("剩余时间:%s"), math.max(math.ceil(self.less), 0))
        self.barRect.sizeDelta = Vector2(345 * (self.less / 20), 14)
    else
        self:TimeOut()
    end
end

-- 展示双方结果
function QuestAnswerTeacherPanel:ShowOption(dat)
    self:Over()

    for i,v in ipairs(self.buttons) do
        v.hasbund:SetActive(false)
        v.wife:SetActive(false)
    end
    local selfNot = false
    local otherNot = false
    for i,v in ipairs(dat.opts) do
        local uniqueid = BaseUtils.get_unique_roleid(v.rid, v.zone_id, v.platform)
        local isSelf = (uniqueid == BaseUtils.get_self_id())
        if v.option ~= 0 then
            local index = self.option2index[v.option]
            self:ShowWhoAnswered(index, isSelf)
        else
            -- 未答题情况
            if isSelf then
                selfNot = true
            else
                otherNot = true
            end
        end
    end

    if selfNot and otherNot then
        self.statusTxt.text = TI18N("双方未做选择")
    elseif selfNot then
        self.statusTxt.text = TI18N("自己未做选择")
    elseif otherNot then
        self.statusTxt.text = TI18N("对方未做选择")
    else
        self.statusTxt.text = ""
    end

    if self.questionData ~= nil and self.buttons[self.questionData.answer] ~= nil then
        self.buttons[self.questionData.answer].tick:SetActive(true)
    end

    self:BeginNextTimeout()
end

function QuestAnswerTeacherPanel:ShowWhoAnswered(index, isSelf)
    local btn = self.buttons[index]
    if btn ~= nil then
        local isMale = false
        if isSelf then
            isMale = TeacherManager.Instance.model.myTeacherInfo.status == TeacherEnum.Type.Teacher
        else
            isMale = not (TeacherManager.Instance.model.myTeacherInfo.status == TeacherEnum.Type.Teacher)
        end
        if isMale then
            btn.hasbund:SetActive(true)
            if btn.wife.activeSelf then
                -- 两个同时存在，排版
                btn.hasbundRect.anchoredPosition = self.pos1
                btn.wifeRect.anchoredPosition = self.pos2
            else
                btn.hasbundRect.anchoredPosition = self.pos2
            end
        else
            btn.wife:SetActive(true)
            if btn.hasbund.activeSelf then
                -- 两个同时存在，排版
                btn.hasbundRect.anchoredPosition = self.pos1
                btn.wifeRect.anchoredPosition = self.pos2
            else
                btn.wifeRect.anchoredPosition = self.pos2
            end
        end
    end
end

function QuestAnswerTeacherPanel:AllGrey()
    for i,btn in ipairs(self.buttons) do
        btn.img.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
    end
end

-- 开始进入下一题倒计时
function QuestAnswerTeacherPanel:BeginNextTimeout()
    if self.nextId ~= 0 then
        LuaTimer.Delete(self.nextId)
        self.nextId = 0
    end
    self.nextTime = 3
    self.nextId = LuaTimer.Add(0, 100, function() self:NextLoop() end)
end

function QuestAnswerTeacherPanel:NextLoop()
    if self.nextTime > 0.1 then
        self.nextTime = self.nextTime - 0.1
        self.timeTxt.text = string.format(TI18N("%s秒后下一题"), math.max(math.ceil(self.nextTime), 0))
        self.barRect.sizeDelta = Vector2(345 * (self.nextTime / 3), 14)
    else
        self:Next()
    end
end

function QuestAnswerTeacherPanel:Next()
    self.timeTxt.text = TI18N("下一题")
    if self.nextId ~= 0 then
        LuaTimer.Delete(self.nextId)
        self.nextId = 0
    end
    if self.openArgs.sid == 3 then
        -- 最后一题，请求统计
        QuestMarryManager.Instance.finish = true
        QuestMarryManager.Instance:OpenAward(QuestionEumn.Type.Teacher)
    else
        QuestMarryManager.Instance:Send16100(QuestManager.Instance.teacher_question)
    end
end
