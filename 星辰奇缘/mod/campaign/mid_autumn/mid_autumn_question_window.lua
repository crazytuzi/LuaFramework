-- @author 黄耀聪
-- @date 2016年9月8日

MidAutumnQuestionWindow = MidAutumnQuestionWindow or BaseClass(BaseWindow)

function MidAutumnQuestionWindow:__init(model)
    self.model = model
    self.name = "MidAutumnQuestionWindow"
    self.mgr = MidAutumnFestivalManager.Instance
    self.windowId = WindowConfig.WinID.mid_autumn_question

    self.resList = {
        {file = AssetConfig.midAutumn_question_window, type = AssetType.Main}
        ,{file = string.format(AssetConfig.effect, 20157), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }

    self.optionList = {}
    self.checkAnswerListener = function(answer, result) self:CheckAnswer(answer, result) end
    self.tickListener = function() self:Countdown() end
    self.timeFormat = TI18N("<color='#00ff00'>%s</color>秒后飞走")
    self.descString = TI18N("答对将获得<color='#00ff00'>孔明灯会</color>的入场机会，与其他高手较量")


    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.previewComp1 = nil
    self.hasInit = false
end

function MidAutumnQuestionWindow:__delete()
    -- 记得这里销毁
    if self.previewComp1 ~= nil then
        self.previewComp1:DeleteMe()
        self.previewComp1 = nil
    end
    self.hasInit = false
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MidAutumnQuestionWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.midAutumn_question_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    local question = t:Find("Main/Bg/Question")
    local answer = t:Find("Main/Answers")
    self.questionText = question:Find("Desc"):GetComponent(Text)
    self.descText = t:Find("Main/Attention/Desc"):GetComponent(Text)
    self.timeSlider = t:Find("Main/Bg/Slider"):GetComponent(Slider)
    self.timeText = t:Find("Main/Bg/Text"):GetComponent(Text)

    self.Preview = t:Find("Main/Preview")

    self.answer_right_effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20157)))
    self.answer_right_effect.transform:SetParent(self.transform)
    self.answer_right_effect.transform.localRotation = Quaternion.identity
    self.answer_right_effect:SetActive(false)
    Utils.ChangeLayersRecursively(self.answer_right_effect.transform, "UI")
    self.answer_right_effect.transform.localScale = Vector3(1, 1, 1)
    self.answer_right_effect.transform.localPosition = Vector3(-110, 0, -100)

    local options = {"A", "B", "C", "D"}
    local optionsLower = {"a", "b", "c", "d"}
    for k,v in pairs(options) do
        local tab = {}
        tab.option = v
        tab.lower = optionsLower[k]
        tab.transform = answer:Find(v)
        tab.gameObject = tab.transform.gameObject
        tab.text = tab.transform:Find("Text"):GetComponent(Text)
        tab.btn = tab.gameObject:GetComponent(Button)
        tab.right = tab.transform:Find("Right").gameObject
        tab.wrong = tab.transform:Find("Wrong").gameObject
        self.optionList[k] = tab
        tab.btn.onClick:AddListener(function() self:Check(k) end)
    end

    t:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)
    self:update_sh_model()
    self.hasInit = true
end

function MidAutumnQuestionWindow:OnPlayRightEffect()
    if self.hasInit == false then
        return
    end
    self.answer_right_effect:SetActive(false)
    self.answer_right_effect:SetActive(true)
    LuaTimer.Add(1500, function()
        if self.hasInit == false then
            return
        end
        self.answer_right_effect:SetActive(false)
    end)
end

function MidAutumnQuestionWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MidAutumnQuestionWindow:OnOpen()
    self:RemoveListeners()
    self.mgr.answerEvent:AddListener(self.checkAnswerListener)
    self.mgr.tickEvent:AddListener(self.tickListener)
    self.timerId = LuaTimer.Add(0, 20, self.tickListener)

    self.askId = self.openArgs
    self.model.autoAnswerTime = os.clock() + 60
    self.mgr.askId = nil

    self:ReloadQuestion()

    if CampaignManager.Instance.campaignTab[315] ~= nil then
        self.descText.text = TI18N("答对将获得<color='#00ff00'>孔明灯会</color>的入场机会，与其他高手较量")
    elseif CampaignManager.Instance.campaignTab[1459] ~= nil then
        self.descText.text = TI18N("答对将获得<color='#00ff00'>孔明灯会</color>的入场机会，与其他高手较量")
    else
        if RoleManager.Instance.RoleData.event == RoleEumn.Event.SkyLantern then
            self.descText.text = TI18N("答对较多者<color='#ffff00'>可获大奖</color>，快快开动脑筋吧")
        else
            self.descText.text = TI18N("答对将获得<color='#00ff00'>孔明灯会</color>的入场机会，与其他高手较量")
        end
    end
    self:Countdown()
end

function MidAutumnQuestionWindow:OnHide()
    self:RemoveListeners()
end

function MidAutumnQuestionWindow:RemoveListeners()
    self.mgr.answerEvent:RemoveListener(self.checkAnswerListener)
    self.mgr.tickEvent:RemoveListener(self.tickListener)
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function MidAutumnQuestionWindow:ReloadQuestion()
    local question = DataQuestion.data_midautumn_question[self.askId]
    if question ~= nil then
        self.questionText.text = question.question
        -- BaseUtils.dump(question, "question")
        for _,v in pairs(self.optionList) do
            local s = tostring(question["option_"..v.lower])
            if s ~= "" then
                v.text.text = string.format("%s.%s", tostring(v.option), s)
                v.right:SetActive(false)
                v.wrong:SetActive(false)
                v.btn.enabled = true
                v.gameObject:SetActive(true)
            else
                v.gameObject:SetActive(false)
            end
        end
    end
end

function MidAutumnQuestionWindow:Check(index)
    for _,v in pairs(self.optionList) do
        v.btn.enabled = false
    end
    self.mgr:send14056(index)
end

function MidAutumnQuestionWindow:CheckAnswer(answer, result)
    self.optionList[answer].right:SetActive(result == answer)
    self.optionList[answer].wrong:SetActive(result ~= answer)
end

function MidAutumnQuestionWindow:Countdown()
    if self.model.autoAnswerTime > os.clock() then
        self.timeSlider.value = (self.model.autoAnswerTime - os.clock()) / 60
        if self.model.autoAnswerTime - os.clock() > 5 then
            self.timeText.text = string.format(self.timeFormat, tostring(math.ceil(self.model.autoAnswerTime - os.clock())))
        else
            self.timeText.text = string.format(self.timeFormat, string.format("<color='#ff0000'>%s</color>", tostring(math.ceil(self.model.autoAnswerTime - os.clock()))))
        end
    else
        self.timeSlider.value = 0
        self.timeText.text = TI18N("孔明灯飞走了~")
    end
end

function MidAutumnQuestionWindow:OnClose()
    WindowManager.Instance:CloseWindow(self)
end

function MidAutumnQuestionWindow:update_sh_model()
    local previewComp = nil
    local callback = function(composite)
        self:on_model_build_completed(composite)
    end

    local shdata = DataUnit.data_unit[74136]
    local setting = {
        name = "MidAutumnQuestionWindow"
        ,orthographicSize = 1
        ,width = 341
        ,height = 341
        ,offsetY = -0.4
    }
    local modelData = {type = PreViewType.Npc, skinId = shdata.skin, modelId = shdata.res, animationId = shdata.animation_id, scale = 1.5}
    if self.previewComp1 == nil then
        self.previewComp1 = PreviewComposite.New(callback, setting, modelData)

        -- 有缓存的窗口要写这个
        self.OnHideEvent:AddListener(function()
            if self.previewComp1 ~= nil then
                self.previewComp1:Hide()
            end
        end)
        self.OnOpenEvent:AddListener(function()
            if self.previewComp1 ~= nil then
                self.previewComp1:Show()
            end
        end)
    else
        self.previewComp1:Reload(modelData, callback)
    end
end

--守护模型加载完成
function MidAutumnQuestionWindow:on_model_build_completed(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.Preview)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
end

