NewExamTopWindow  =  NewExamTopWindow or BaseClass(BasePanel)

function NewExamTopWindow:__init(model)
    self.name  =  "NewExamTopWindow"
    self.model  =  model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.newexamtopwindow, type  =  AssetType.Main}
        , {file = AssetConfig.exam_res, type = AssetType.Dep}
        ,{file = string.format(AssetConfig.effect, 20157), type = AssetType.Main}
        -- ,{file = string.format(AssetConfig.effect, 20396), type = AssetType.Main}
    }

    self._UpdateTime = function() self:UpdateTime() end
    self._Update = function() self:Update() end

    ------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function NewExamTopWindow:OnHide()
    NewExamManager.Instance.OnUpdateQuestionData:Remove(self._Update)

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function NewExamTopWindow:OnShow()
    NewExamManager.Instance.OnUpdateQuestionData:Remove(self._Update)
    NewExamManager.Instance.OnUpdateQuestionData:Add(self._Update)

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    self.timerId = LuaTimer.Add(0, 1000, self._UpdateTime)

    self:Update()
end

function NewExamTopWindow:__delete()
    self:OnHide()

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function NewExamTopWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.newexamtopwindow))
    self.gameObject.name = "NewExamTopWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    self.transform.localPosition = Vector3(0, 0, 600)

    self.exitButton = self.transform:Find("MainCon/ExitButton"):GetComponent(Button)
    self.exitButton.onClick:AddListener(function() self:OnClickExitButton() end)
    self.exitButton.gameObject:SetActive(false)

    self.titleText = self.transform:Find("MainCon/ImgTitle/TxtTitle"):GetComponent(Text)

    self.questionText = self.transform:Find("MainCon/QuestionText"):GetComponent(Text)
    self.numText1 = self.transform:Find("MainCon/NumText1"):GetComponent(Text)
    self.numText2 = self.transform:Find("MainCon/NumText2"):GetComponent(Text)
    
    self.buttonAZone = self.transform:Find("MainCon/Btn_A").gameObject
    self.buttonAZoneRect = self.buttonAZone:GetComponent(RectTransform)
    self.buttonA = self.transform:Find("MainCon/Btn_A/Btn"):GetComponent(Button)
    self.buttonA.onClick:AddListener(function() self:OnClickButtonA() end)
    self.buttonAText = self.transform:Find("MainCon/Btn_A/Btn/Text"):GetComponent(Text)
    self.buttonAText2 = self.transform:Find("MainCon/Btn_A/Btn/Text2"):GetComponent(Text)
    self.buttonANumText = self.transform:Find("MainCon/Btn_A/NumText"):GetComponent(Text)
    self.buttonAImgRight = self.transform:Find("MainCon/Btn_A/Btn/ImgRight").gameObject
    self.buttonAImgWrong = self.transform:Find("MainCon/Btn_A/Btn/ImgWrong").gameObject
    self.buttonASelect = self.transform:Find("MainCon/Btn_A/Btn/Select").gameObject
    self.buttonAI18NSelect = self.transform:Find("MainCon/Btn_A/Btn/I18NSelect").gameObject

    self.buttonBZone = self.transform:Find("MainCon/Btn_B").gameObject
    self.buttonBZoneRect = self.buttonBZone:GetComponent(RectTransform)
    self.buttonB = self.transform:Find("MainCon/Btn_B/Btn"):GetComponent(Button)
    self.buttonB.onClick:AddListener(function() self:OnClickButtonB() end)
    self.buttonBText = self.transform:Find("MainCon/Btn_B/Btn/Text"):GetComponent(Text)
    self.buttonBText2 = self.transform:Find("MainCon/Btn_B/Btn/Text2"):GetComponent(Text)
    self.buttonBNumText = self.transform:Find("MainCon/Btn_B/NumText"):GetComponent(Text)
    self.buttonBImgRight = self.transform:Find("MainCon/Btn_B/Btn/ImgRight").gameObject
    self.buttonBImgWrong = self.transform:Find("MainCon/Btn_B/Btn/ImgWrong").gameObject
    self.buttonBSelect = self.transform:Find("MainCon/Btn_B/Btn/Select").gameObject
    self.buttonBI18NSelect = self.transform:Find("MainCon/Btn_B/Btn/I18NSelect").gameObject

    self.numImage1 = self.transform:Find("MainCon/ImageNum/Image1").gameObject
    self.numImage2 = self.transform:Find("MainCon/ImageNum/Image2").gameObject

    self.answerRightEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20157)))
    self.answerRightEffect.transform:SetParent(self.transform)
    self.answerRightEffect.transform.localRotation = Quaternion.identity
    self.answerRightEffect:SetActive(false)
    Utils.ChangeLayersRecursively(self.answerRightEffect.transform, "UI")
    self.answerRightEffect.transform.localScale = Vector3(1, 1, 1)
    self.answerRightEffect.transform.localPosition = Vector3(-110, 0, -100)

    -- self.answerWrongEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20396)))
    -- self.answerWrongEffect.transform:SetParent(self.transform)
    -- self.answerWrongEffect.transform.localRotation = Quaternion.identity
    -- self.answerWrongEffect:SetActive(false)
    -- Utils.ChangeLayersRecursively(self.answerWrongEffect.transform, "UI")
    -- self.answerWrongEffect.transform.localScale = Vector3(1, 1, 1)
    -- self.answerWrongEffect.transform.localPosition = Vector3(0, 0, -400)

    self:OnShow()
end

function NewExamTopWindow:OnClickExitButton()
    -- self.model:CloseNewExamTop()
    NewExamManager.Instance:send20104()
end

function NewExamTopWindow:OnClickButtonA()
    NewExamManager.Instance:GotoJumpPointB(true)
    if self.model.last_choose == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("你已经在本区域"))
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("已经选择答案A{face_1,3}"))
    end
end

function NewExamTopWindow:OnClickButtonB()
    NewExamManager.Instance:GotoJumpPointA(true)
    if self.model.last_choose == 2 then
        NoticeManager.Instance:FloatTipsByString(TI18N("你已经在本区域"))
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("已经选择答案B{face_1,3}"))
    end
end

function NewExamTopWindow:Update()
    if BaseUtils.is_null(self.gameObject) then
        return
    end

    local questionData = self.model.questionData
    local myQuestionData = self.model.myQuestionData

    if questionData ~= nil then
        if questionData.status == 2 then
            self.titleText.text = string.format(TI18N("第%s题"), questionData.round)
            self.buttonANumText.text = ""
            self.buttonBNumText.text = ""
            self.buttonAText.text = ""
            self.buttonBText.text = ""
            self.buttonAImgRight:SetActive(false)
            self.buttonAImgWrong:SetActive(false)
            self.buttonBImgRight:SetActive(false)
            self.buttonBImgWrong:SetActive(false)
            self.buttonASelect:SetActive(false)
            self.buttonAI18NSelect:SetActive(false)
            self.buttonBSelect:SetActive(false)
            self.buttonBI18NSelect:SetActive(false)
            -- self.buttonAZone:SetActive(false)
            -- self.buttonBZone:SetActive(false)
            self:BtnTweenHide()

            if questionData.round == 1 then
                self.questionText.text = TI18N("准备开始")
            -- elseif questionData.round == 20 then
            --     self.questionText.text = TI18N("答题结束，正在统计分数")
            else
                self.questionText.text = TI18N("准备下一题.........")
            end
        elseif questionData.status == 3 then
            self.titleText.text = string.format(TI18N("第%s题"), questionData.round)

            local data_new_question = DataQuestion.data_new_question[questionData.question_id]
            if data_new_question ~= nil then
                self.questionText.text = string.format(TI18N("问:%s"), data_new_question.question)
                self.buttonAText.text = string.format("A.%s", data_new_question.option_a)
                self.buttonBText.text = string.format("B.%s", data_new_question.option_b)
                -- self.buttonAText.text = "A"
                -- self.buttonBText.text = "B"
                -- self.buttonAText2.text = string.format("(%s)", data_new_question.option_a)
                -- self.buttonBText2.text = string.format("(%s)", data_new_question.option_b)
            else
                self.questionText.text = string.format(TI18N("题目id不存在："), questionData.question_id)
            end
            self.buttonANumText.text = string.format(TI18N("选择人数：%s"), self.model.chooseA_count)
            self.buttonBNumText.text = string.format(TI18N("选择人数：%s"), self.model.chooseB_count)

            self.buttonAImgRight:SetActive(false)
            self.buttonAImgWrong:SetActive(false)
            self.buttonBImgRight:SetActive(false)
            self.buttonBImgWrong:SetActive(false)
            -- self.buttonAZone:SetActive(true)
            -- self.buttonBZone:SetActive(true)
            self:BtnTweenShow()

            if self.model.last_choose == 1 then
                self.buttonASelect:SetActive(true)
                self.buttonAI18NSelect:SetActive(true)
                self.buttonBSelect:SetActive(false)
                self.buttonBI18NSelect:SetActive(false)
            elseif self.model.last_choose == 2 then
                self.buttonASelect:SetActive(false)
                self.buttonAI18NSelect:SetActive(false)
                self.buttonBSelect:SetActive(true)
                self.buttonBI18NSelect:SetActive(true)
            else
                self.buttonASelect:SetActive(false)
                self.buttonAI18NSelect:SetActive(false)
                self.buttonBSelect:SetActive(false)
                self.buttonBI18NSelect:SetActive(false)
            end
        elseif questionData.status == 4 then
            self.titleText.text = string.format(TI18N("第%s题"), questionData.round)

            local data_new_question = DataQuestion.data_new_question[questionData.question_id]
            if data_new_question ~= nil then
                self.buttonAText.text = string.format("A：%s", data_new_question.option_a)
                self.buttonBText.text = string.format("B：%s", data_new_question.option_b)
                -- self.buttonAText.text = "A"
                -- self.buttonBText.text = "B"
                -- self.buttonAText2.text = string.format("(%s)", data_new_question.option_a)
                -- self.buttonBText2.text = string.format("(%s)", data_new_question.option_b)
                self.buttonANumText.text = string.format(TI18N("选择人数：%s"), self.model.chooseA_count)
                self.buttonBNumText.text = string.format(TI18N("选择人数：%s"), self.model.chooseB_count)

                -- self.buttonAZone:SetActive(true)
                -- self.buttonBZone:SetActive(true)
                self:BtnTweenShow()

                if questionData.answer == 1 then
                    self.questionText.text = string.format(TI18N("本题答案为：%s"), data_new_question.option_a)

                    self.buttonAImgRight:SetActive(true)
                    self.buttonAImgWrong:SetActive(false)
                    self.buttonBImgRight:SetActive(false)
                    self.buttonBImgWrong:SetActive(true)

                    if self.lastRightEffectRound ~= questionData.round then
                        if self.model.last_choose == 1 then
                            self.answerRightEffect:SetActive(false)
                            self.answerRightEffect:SetActive(true)
                        else
                        --     self.answerWrongEffect:SetActive(false)
                        --     self.answerWrongEffect:SetActive(true)
                            -- NoticeManager.Instance:FloatTipsByString(TI18N("哈哈{face_1,17},你回答错了被变成了小猪{face_1,17}！"))
                        end
                    end
                    self.lastRightEffectRound = questionData.round
                elseif questionData.answer == 2 then
                    self.questionText.text = string.format(TI18N("本题答案为：%s"), data_new_question.option_b)

                    self.buttonAImgRight:SetActive(false)
                    self.buttonAImgWrong:SetActive(true)
                    self.buttonBImgRight:SetActive(true)
                    self.buttonBImgWrong:SetActive(false)

                    if self.lastRightEffectRound ~= questionData.round then
                        if self.model.last_choose == 2 then
                            self.answerRightEffect:SetActive(false)
                            self.answerRightEffect:SetActive(true)
                        else
                        --     self.answerWrongEffect:SetActive(false)
                        --     self.answerWrongEffect:SetActive(true)
                            -- NoticeManager.Instance:FloatTipsByString(TI18N("哈哈{face_1,17},你回答错了被变成了小猪{face_1,17}！"))
                        end
                    end
                    self.lastRightEffectRound = questionData.round
                end

                if self.model.last_choose == 1 then
                    self.buttonASelect:SetActive(true)
                    self.buttonAI18NSelect:SetActive(true)
                    self.buttonBSelect:SetActive(false)
                    self.buttonBI18NSelect:SetActive(false)
                elseif self.model.last_choose == 2 then
                    self.buttonASelect:SetActive(false)
                    self.buttonAI18NSelect:SetActive(false)
                    self.buttonBSelect:SetActive(true)
                    self.buttonBI18NSelect:SetActive(true)
                else
                    self.buttonASelect:SetActive(false)
                    self.buttonAI18NSelect:SetActive(false)
                    self.buttonBSelect:SetActive(false)
                    self.buttonBI18NSelect:SetActive(false)
                end
            else
                self.questionText.text = string.format(TI18N("题目id不存在："), questionData.question_id)
            end
        elseif questionData.status == 5 then
            self.titleText.text = string.format(TI18N("第%s题"), questionData.round)
            self.buttonANumText.text = ""
            self.buttonBNumText.text = ""
            self.buttonAText.text = ""
            self.buttonBText.text = ""
            self.buttonAImgRight:SetActive(false)
            self.buttonAImgWrong:SetActive(false)
            self.buttonBImgRight:SetActive(false)
            self.buttonBImgWrong:SetActive(false)
            self.buttonASelect:SetActive(false)
            self.buttonAI18NSelect:SetActive(false)
            self.buttonBSelect:SetActive(false)
            self.buttonBI18NSelect:SetActive(false)
            -- self.buttonAZone:SetActive(false)
            -- self.buttonBZone:SetActive(false)
            self:BtnTweenHide()

            self.questionText.text = TI18N("答题结束，正在统计分数")
        elseif questionData.status == 6 then
            self.titleText.text = string.format(TI18N("第%s题"), questionData.round)
            self.buttonANumText.text = ""
            self.buttonBNumText.text = ""
            self.buttonAText.text = ""
            self.buttonBText.text = ""
            self.buttonAImgRight:SetActive(false)
            self.buttonAImgWrong:SetActive(false)
            self.buttonBImgRight:SetActive(false)
            self.buttonBImgWrong:SetActive(false)
            self.buttonASelect:SetActive(false)
            self.buttonAI18NSelect:SetActive(false)
            self.buttonBSelect:SetActive(false)
            self.buttonBI18NSelect:SetActive(false)
            -- self.buttonAZone:SetActive(false)
            -- self.buttonBZone:SetActive(false)
            self:BtnTweenHide()

            self.questionText.text = TI18N("答题结束正在退出")
        end

        self.numText1.text = string.format(TI18N("剩余题目:%s"), 20 - questionData.round)
    end

    if myQuestionData ~= nil then
        self.numText2.text = string.format(TI18N("<color='#00ff00'>答对题目:%s</color>"), myQuestionData.right_count)
    end
end

function NewExamTopWindow:UpdateTime()
    local questionData = self.model.questionData

    if questionData ~= nil then
        NewExamManager.Instance:CheckOnArena()
        SceneManager.Instance.MainCamera:SetOffsetTargetvalue(0.04)
        if MainUIManager.Instance.MainUIIconView ~= nil then
            if not MainUIManager.Instance.MainUIIconView.hide_icon_id_list[303] then
                MainUIManager.Instance.MainUIIconView:Set_ShowTop(false, {})
                MainUIManager.Instance.MainUIIconView:hide_icon_by_idlist(303, true)
            end
        end

        local diff = BaseUtils.Round(self.model.lessTime)
        if diff >= 10 then
            self.numImage1:SetActive(true)
            self.numImage2:SetActive(true)

            local num1 = math.floor(diff / 10) % 10
            local num2 = diff % 10

            self.numImage1:GetComponent(Image).sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_3, "Num3_"..tostring(num1))
            self.numImage2:GetComponent(Image).sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_3, "Num3_"..tostring(num2))
        else
            self.numImage1:SetActive(false)
            self.numImage2:SetActive(true)
            self.numImage2:GetComponent(Image).sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_3, "Num3_"..tostring(diff))
        end

        self.model.lessTime = self.model.lessTime - 1
    else
        self.numImage1:SetActive(false)
        self.numImage2:SetActive(false)
    end
end

function NewExamTopWindow:BtnTweenHide()
    Tween.Instance:MoveX(self.buttonAZoneRect, 0, 0.2)
    Tween.Instance:MoveX(self.buttonBZoneRect, 0, 0.2)
end

function NewExamTopWindow:BtnTweenShow()
    Tween.Instance:MoveX(self.buttonAZoneRect, -248.5, 0.2)
    Tween.Instance:MoveX(self.buttonBZoneRect, 248.5, 0.2)
end
