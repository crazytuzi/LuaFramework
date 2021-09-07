--2016/9/23
--xjlong
--国庆活动保卫蛋糕答题
NationalDayDefenseQuestionWindow = NationalDayDefenseQuestionWindow or BaseClass(BaseWindow)

function NationalDayDefenseQuestionWindow:__init(model)
    self.name  =  "NationalDayDefenseQuestionWindow"
    self.model  =  model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.national_day_defense_question_window, type  =  AssetType.Main}
    }

    self.windowId = WindowConfig.WinID.national_day_defense_question_window

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.isHideMainUI = false

    self.timerId = nil

    self.hasInit = false
    return self
end

function NationalDayDefenseQuestionWindow:OnHide()

end

function NationalDayDefenseQuestionWindow:OnShow()
end

function NationalDayDefenseQuestionWindow:__delete()
    self.hasInit = false
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
    end

    self:AssetClearAll()
end

function NationalDayDefenseQuestionWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.national_day_defense_question_window))
    self.gameObject:SetActive(false)
    self.gameObject.name = "NationalDayDefenseQuestionWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)
    self.transform:GetComponent(RectTransform).localPosition = Vector3.zero
    self.mainCon = self.gameObject.transform:Find("MainCon")
    local closeBtn = self.gameObject.transform:Find("MainCon/CloseButton"):GetComponent(Button)
    closeBtn.onClick:AddListener(function()
        self.model:CloseDefenseQuestionUI()
    end)

    self.mainCon:Find("ImgTitle/TxtTitle"):GetComponent(Text).text = TI18N("答题")
    self.OpenCon = self.mainCon:FindChild("OpenCon")
    self.ImgTec = self.OpenCon:FindChild("ImgTec")
    self.TxtTitle = self.ImgTec:FindChild("TxtLevDesc"):GetComponent(Text)
    self.TxtQuestion = self.OpenCon:FindChild("TxtQuestion"):GetComponent(Text)

    self.btnList = {}
    self.BottomCon = self.OpenCon:FindChild("BottomCon")
    self.BtnA = self.BottomCon:FindChild("Btn_A"):GetComponent(Button)
    self.TextA = self.BtnA.transform:FindChild("Text"):GetComponent(Text)

    self.BtnB = self.BottomCon:FindChild("Btn_B"):GetComponent(Button)
    self.TextB = self.BtnB.transform:FindChild("Text"):GetComponent(Text)

    self.BtnC = self.BottomCon:FindChild("Btn_C"):GetComponent(Button)
    self.TextC = self.BtnC.transform:FindChild("Text"):GetComponent(Text)

    self.BtnD = self.BottomCon:FindChild("Btn_D"):GetComponent(Button)
    self.TextD = self.BtnD.transform:FindChild("Text"):GetComponent(Text)

    table.insert(self.btnList, self.BtnA)
    table.insert(self.btnList, self.BtnB)
    table.insert(self.btnList, self.BtnC)
    table.insert(self.btnList, self.BtnD)

    self.optionNormalSprite = self.BtnB.image.sprite
    self.optionUnableSprite = self.BtnA.image.sprite

    self.BtnA.onClick:AddListener(function() self:OnClickAnswer(1) end)
    self.BtnB.onClick:AddListener(function() self:OnClickAnswer(2) end)
    self.BtnC.onClick:AddListener(function() self:OnClickAnswer(3) end)
    self.BtnD.onClick:AddListener(function() self:OnClickAnswer(4) end)
    self.hasInit = true
    self:UpdateQuestionInfo()
end

------------------------------各种事件监听
--选择答案
function NationalDayDefenseQuestionWindow:OnClickAnswer(index)
    for i=1,#self.btnList do
        self.btnList[i].enabled = false
    end
    NationalDayManager:Send14082(self.data.id, index)

    --self:UpdateAnswerResult({err_code = 2, answer = index, right_answer = 1})
end

---- ------------------------各种更新事件
--更新答题结果
function NationalDayDefenseQuestionWindow:UpdateAnswerResult(questdata)
    for i=1,#self.btnList do
        self:SetBtnAnswerState(self.btnList[i], 0)
    end

    if questdata.err_code == 1 then
        self:SetBtnAnswerState(self.btnList[questdata.answer], 1)
    elseif questdata.err_code == 2 then
        self:SetBtnAnswerState(self.btnList[questdata.answer], 2)
        self:SetBtnAnswerState(self.btnList[questdata.right_answer], 1)
    end

    for i=1,#self.btnList do
        self.btnList[i].enabled = false
    end

    self.timerId = LuaTimer.Add(1500, function(id) self:NextQuestion() end)
end

function NationalDayDefenseQuestionWindow:NextQuestion()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
    end

    self.timerId = nil
    self:UpdateQuestionInfo()
end

--更新问题内容
function NationalDayDefenseQuestionWindow:UpdateQuestionInfo()
    if self.hasInit == false or self.timerId ~= nil then
        return
    end

    self.data = nil
    local rightCount = 0
    local remainCount = 0
    local defenseQuestData = NationalDayManager.Instance.model.defenseQuestData
    for i,v in ipairs(defenseQuestData) do
        if v.status == 0 then
            if self.data == nil then
                self.data = v
            end
            remainCount = remainCount + 1
        elseif v.status == 1 then
            rightCount = rightCount + 1
        end
    end

    if self.data == nil then
        self.model:CloseDefenseQuestionUI()
        local questData = QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.defensecake)
        if questData ~= nil then
            QuestManager.Instance:DoQuest(questData)
        end

        return
    end

    self.OpenCon.gameObject:SetActive(true)

    for i=1,#self.btnList do
        self.btnList[i].enabled = true
    end

    local question_cfg_data = DataCampCake.data_question_list[self.data.id]
    local total = 3
    local fenzi = 3 - remainCount + 1
    self.TxtQuestion.text = string.format(TI18N("<color='#7EB9F7'>第%s/%s题:</color>%s"), fenzi, total, question_cfg_data.question)
    self:UpdateBtnstate(self.BtnA, self.TextA, question_cfg_data.option_a, "A.")
    self:UpdateBtnstate(self.BtnB, self.TextB, question_cfg_data.option_b, "B.")
    self:UpdateBtnstate(self.BtnC, self.TextC, question_cfg_data.option_c, "C.")
    self:UpdateBtnstate(self.BtnD, self.TextD, question_cfg_data.option_d, "D.")

    self.TxtTitle.text = string.format(TI18N("答对题数：%s/2(完成智慧小精灵的考验可额外获得奖励)"), rightCount)
end

--根据传入的答案状态设置按钮是否显示
function NationalDayDefenseQuestionWindow:UpdateBtnstate(btn, btn_txt, btn_str, prefix)
    if btn_str == "" then
        btn.gameObject:SetActive(false)
        self:SetBtnState(btn, false)
    else
        btn.gameObject:SetActive(true)
        self:SetBtnState(btn, true)
        self:SetBtnAnswerState(btn, 0)
        btn_txt.text = string.format("%s%s", prefix, btn_str)
    end
end

--更新传入按钮的状态
function NationalDayDefenseQuestionWindow:SetBtnState(btn, state)
    btn.enabled = state
    if state then
        btn.image.sprite = self.optionNormalSprite
    else
        btn.image.sprite = self.optionUnableSprite
    end
end

--设置按钮的对错状态
function NationalDayDefenseQuestionWindow:SetBtnAnswerState(btn, flag)
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
