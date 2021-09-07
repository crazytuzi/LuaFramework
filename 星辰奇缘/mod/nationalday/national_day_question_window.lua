--2016/9/22
--zzl
--国庆活动在线抢答
NationalDayQuestionWindow  =  NationalDayQuestionWindow or BaseClass(BaseWindow)

function NationalDayQuestionWindow:__init(model)
    self.name  =  "NationalDayQuestionWindow"
    self.model  =  model
    self.cacheMode = CacheMode.Visible
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.national_day_question_window, type  =  AssetType.Main}
        ,{file  =  AssetConfig.rolebg, type  =  AssetType.Dep}
        ,{file = string.format(AssetConfig.effect, 20157), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }
    self.windowId = WindowConfig.WinID.exam_main_win
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.isHideMainUI = false

    self.totalTime = 30 --答一道题的时间是三十秒
    self.hasInit = false
    self.resultTimeStr = ""
    self.resultRewardStr = ""
    self.timer_id = 0
    self.answer_timer_id = 0
    self.previewComp1 = nil
    self.looks = nil
    self.wrongGap = 10
    return self
end

function NationalDayQuestionWindow:OnHide()
    if self.previewComp1 ~= nil then
        self.previewComp1:Hide()
    end
end

function NationalDayQuestionWindow:OnShow()
    if self.previewComp1 ~= nil then
        self.previewComp1:Show()
    end
    self:update_info_mem_model()
    self.UnOpenCon.gameObject:SetActive(true)
    self.OpenCon.gameObject:SetActive(false)
    if self.model.questionData.status == 2 then
        --准备
    elseif self.model.questionData.status == 1 then
        --开始
        NationalDayManager.Instance:Send14071()
    end
end

function NationalDayQuestionWindow:__delete()
    self.looks = nil
    if self.previewComp1 ~= nil then
        self.previewComp1:DeleteMe()
        self.previewComp1 = nil
    end
    self:stop_timer()
    self.hasInit = false
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function NationalDayQuestionWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.national_day_question_window))
    self.gameObject:SetActive(false)
    self.gameObject.name = "NationalDayQuestionWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)
    self.transform:GetComponent(RectTransform).localPosition = Vector3.zero
    self.mainCon = self.gameObject.transform:Find("MainCon")
    local closeBtn = self.gameObject.transform:Find("MainCon/CloseButton"):GetComponent(Button)
    closeBtn.onClick:AddListener(function()
        self.model:CloseQuestionUI()
    end)

    self.PreviewCon = self.mainCon:FindChild("PreviewCon")
    self.ImgPreviewBg = self.PreviewCon:FindChild("ImgPreviewBg"):GetComponent(Image)
    self.ImgPreviewBg.sprite = self.assetWrapper:GetSprite(AssetConfig.rolebg, "rolebg")
    self.ImgPreviewBg.gameObject:SetActive(true)
    self.Preview = self.PreviewCon:FindChild("Preview")
    self.TxtLuck1 = self.PreviewCon:FindChild("ImgLuck1"):FindChild("TxtLuck1"):GetComponent(Text)
    self.TxtLuck2 = self.PreviewCon:FindChild("ImgLuck2"):FindChild("TxtLuck2"):GetComponent(Text)
    self.TxtLuck3 = self.PreviewCon:FindChild("ImgLuck3"):FindChild("TxtLuck3"):GetComponent(Text)

    self.UnOpenCon = self.mainCon:FindChild("UnOpenCon")
    self.UnOpenCon_Txt = self.UnOpenCon:FindChild("Text"):GetComponent(Text)
    self.OpenCon = self.mainCon:FindChild("OpenCon")
    self.ImgTec = self.OpenCon:FindChild("ImgTec")
    self.TxtLevDesc = self.OpenCon:FindChild("TxtLevDesc"):GetComponent(Text)
    self.TxtQuestion = self.OpenCon:FindChild("TxtQuestion"):GetComponent(Text)
    self.TxtLevDesc.text = TI18N("超级智多星说明：\n每天<color='#00ff00'>10：00-19：00</color>每隔20分钟随机出题\n玩家在题目出现后<color='#00ff00'>60秒</color>内作答，答案在答题倒计时结束时公布\n参与玩家均有奖励，<color='#00ff00'>前20名</color>参与玩家随机<color='#00ff00'>抽取3名</color>获得幸运大奖\n<color='#00ff00'>12点，14点，18点，19点</color>整点必出题目")
    self.TxtLevDesc2 = self.ImgTec:FindChild("TxtLevDesc"):GetComponent(Text)
    self.TxtLevDesc2.text = TI18N("国庆答题")

    --答对播特效
    self.answer_right_effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20157)))
    self.answer_right_effect.transform:SetParent(self.OpenCon)
    self.answer_right_effect.transform.localRotation = Quaternion.identity
    self.answer_right_effect:SetActive(false)
    Utils.ChangeLayersRecursively(self.answer_right_effect.transform, "UI")
    self.answer_right_effect.transform.localScale = Vector3(1, 1, 1)
    self.answer_right_effect.transform.localPosition = Vector3(0, 0, -100)

    self.MidCon = self.OpenCon:FindChild("MidCon")
    self.MidCon.gameObject:SetActive(true)
    self.ImgProg = self.MidCon:FindChild("ImgProg")
    self.TxtProgTime = self.ImgProg:FindChild("TxtNum"):GetComponent(Text)
    self.ImgBar = self.ImgProg:FindChild("ImgBar")
    self.ImgBar_rect = self.ImgBar:GetComponent(RectTransform)
    self.TxtProgTime = self.ImgProg:FindChild("TxtNum"):GetComponent(Text)

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
    self.UnOpenCon.gameObject:SetActive(true)
    self.OpenCon.gameObject:SetActive(false)
    if self.model.questionData.status == 2 then
        --准备

    elseif self.model.questionData.status == 1 then
        --开始
        NationalDayManager.Instance:Send14071()
    end
end

------------------------------各种事件监听
--选择答案
function NationalDayQuestionWindow:OnClickAnswer(index)
    if self.hasAnswer then
        NoticeManager.Instance:FloatTipsByString(TI18N("你已经回答了问题，请等待正确答案的公布"))
        return
    end
    NationalDayManager.Instance:Send14072(index)
end

------------------------各种更新事件
--更新答题结果
function NationalDayQuestionWindow:UpdateAnswerResult(data)
    for i=1,#self.btnList do
        self:SetBtnAnswerState(self.btnList[i], 0)
    end

    self:SetBtnAnswerState(self.btnList[data.anwer], 3)
    self.hasAnswer = true
    if data.anwer == data.result then
        --答对了
        -- self.answer_right_effect:SetActive(false)
        -- self.answer_right_effect:SetActive(true)
        -- LuaTimer.Add(1500, function() self.answer_right_effect:SetActive(false) end)
    else
        --错的
        -- if data.anwer ~= 0 then
        --     local imgWrong = self.btnList[data.anwer].transform:FindChild("ImgWrong"):GetComponent(Image)
        --     imgWrong.gameObject:SetActive(true)
        --     Tween.Instance:Alpha(imgWrong.rectTransform, 1, 0.2, function()
        --         Tween.Instance:Alpha(imgWrong.rectTransform, 0, 0.2, function()
        --             imgWrong.gameObject:SetActive(false)
        --         end)
        --     end)
        -- end
        -- LuaTimer.Add(self.wrongGap*1000, function() self.hasAnswer = false end)
        self.leftAnswerTime = self.wrongGap
        -- self:start_answer_timer()
    end
end

--更新问题内容
function NationalDayQuestionWindow:UpdateQuestionInfo(data)
    -- print("====================dddddd")
    -- BaseUtils.dump(data)

    if self.hasInit == false then
        return
    end

    self.UnOpenCon.gameObject:SetActive(false)
    self.OpenCon.gameObject:SetActive(true)
    if self.data ~= nil and self.data.askid == data.askid then
        return
    end

    self.data = data
    self.UnOpenCon.gameObject:SetActive(false)
    self.OpenCon.gameObject:SetActive(true)
    self.MidCon.gameObject:SetActive(true)

    for i=1,#self.btnList do
        self.btnList[i].enabled = true
    end

    local question_cfg_data = DataQuestion.data_national_day_question[self.data.askid]
    self.TxtQuestion.text = string.format("%s", question_cfg_data.question)
    self:UpdateBtnstate(self.BtnA, self.TextA, question_cfg_data.option_a, "A.")
    self:UpdateBtnstate(self.BtnB, self.TextB, question_cfg_data.option_b, "B.")
    self:UpdateBtnstate(self.BtnC, self.TextC, question_cfg_data.option_c, "C.")
    self:UpdateBtnstate(self.BtnD, self.TextD, question_cfg_data.option_d, "D.")

    if self.data.done_answer ~= 0 then
        self:SetBtnAnswerState(self.btnList[self.data.done_answer], 3)
        self.hasAnswer = true
    else
        self.hasAnswer = false
    end

    --幸运玩家逻辑
    table.sort(self.data.lockylist, function(a, b)
        return a.rank < b.rank
    end)
    if self.data.lockylist[1] ~= nil then
        self:update_info_mem_model(self.data.lockylist[1].looks, self.data.lockylist[1].classes, self.data.lockylist[1].sex)
    else
        self:update_info_mem_model()
    end
    self.TxtLuck1.text = TI18N("上轮幸运玩家：无")
    self.TxtLuck2.text = TI18N("上轮幸运玩家：无")
    self.TxtLuck3.text = TI18N("上轮幸运玩家：无")
    for i=1, #self.data.lockylist do
        local luckData = self.data.lockylist[i]
        if i == 1 then
            self.TxtLuck1.text = string.format(TI18N("上轮幸运玩家：%s"), luckData.name)
        elseif i == 2 then
            self.TxtLuck2.text = string.format(TI18N("上轮幸运玩家：%s"), luckData.name)
        elseif i == 3 then
            self.TxtLuck3.text = string.format(TI18N("上轮幸运玩家：%s"), luckData.name)
        end
    end

    --跑条
    self.total_time = 60
    self.left_time = self.model.questionData.left_time - Time.time
    self:start_timer()
end

--根据传入的答案状态设置按钮是否显示
function NationalDayQuestionWindow:UpdateBtnstate(btn, btn_txt, btn_str, prefix)
    if btn_str == "" then
        btn.gameObject:SetActive(false)
        self:SetBtnState(btn, false)
    else
        btn.gameObject:SetActive(true)
        self:SetBtnState(btn, true)
        self:SetBtnAnswerState(btn, 0)
        btn_txt.text = string.format("%s%s" , prefix, btn_str)
    end
end

--更新传入按钮的状态
function NationalDayQuestionWindow:SetBtnState(btn, state)
    btn.enabled = state
    if state then
        btn.image.sprite = self.optionNormalSprite
    else
        btn.image.sprite = self.optionUnableSprite
    end
end

--设置按钮的对错状态
function NationalDayQuestionWindow:SetBtnAnswerState(btn, flag)
    local imgRight = btn.transform:FindChild("ImgRight").gameObject
    local imgWrong = btn.transform:FindChild("ImgWrong").gameObject
    local ImgSelected = btn.transform:FindChild("ImgSelected").gameObject
    if flag == 0 then
        imgRight:SetActive(false)
        imgWrong:SetActive(false)
        ImgSelected:SetActive(false)
    elseif flag == 1 then
        imgRight:SetActive(true)
        imgWrong:SetActive(false)
        ImgSelected:SetActive(false)
    elseif flag == 2 then
        imgRight:SetActive(false)
        imgWrong:SetActive(true)
        ImgSelected:SetActive(false)
    elseif flag == 3 then
        imgRight:SetActive(false)
        imgWrong:SetActive(false)
        ImgSelected:SetActive(true)
    end
end


-----------------------------------------------计时器逻辑
--开始战斗倒计时
function NationalDayQuestionWindow:start_timer()
    self:stop_timer()
    self.timer_id = LuaTimer.Add(0, 100, function() self:timer_tick() end)
end

function NationalDayQuestionWindow:stop_timer()
    if self.timer_id ~= 0 then
        LuaTimer.Delete(self.timer_id)
        self.timer_id = 0
    end
end

function NationalDayQuestionWindow:timer_tick()
    self.left_time = self.left_time - 0.1
    if self.left_time >= 0 then
        local percent = self.left_time/self.total_time
        self.ImgBar_rect.sizeDelta = Vector2(342*percent, 14)
        self.TxtProgTime.text = string.format("%s/%s", math.floor(self.left_time), self.total_time)
    else
        self:stop_timer()
        self.model:CloseQuestionUI()
    end
end

--回答倒计时
function NationalDayQuestionWindow:start_answer_timer()
    self:stop_answer_timer()
    self.answer_timer_id = LuaTimer.Add(0, 1000, function() self:timer_answer_tick() end)
end

function NationalDayQuestionWindow:stop_answer_timer()
    if self.answer_timer_id ~= 0 then
        LuaTimer.Delete(self.answer_timer_id)
        self.answer_timer_id = 0
    end
end

function NationalDayQuestionWindow:timer_answer_tick()
    self.leftAnswerTime = self.leftAnswerTime - 1
    if self.leftAnswerTime <= 0 then
        self.hasAnswer = false
        self:stop_answer_timer()
    end
end

--模型逻辑
--更新模型
function NationalDayQuestionWindow:update_info_mem_model(looks, classes, sex)
    local _looks = looks
    local tempClasses = classes
    local tempSex = sex

    if _looks == nil then
        _looks = self.looks
    end
    if tempClasses == nil then
        tempClasses = self.curClasses
    end
    if tempSex == nil then
        tempSex = self.curSex
    end
    if _looks == nil then
        local myData = SceneManager.Instance:MyData()
        if myData ~= nil then
            _looks = myData.looks
        end
    end
    if tempClasses == nil then
        tempClasses = RoleManager.Instance.RoleData.classes
    end
    if tempSex == nil then
        tempSex = RoleManager.Instance.RoleData.sex
    end

    if _looks == nil then return end

    self.looks = _looks
    self.curClasses = tempClasses
    self.curSex = tempSex

    local previewComp = nil
    local callback = function(composite)
        self:on_model_build_completed(composite)
    end

    local setting = {
        name = "NationalDayQuestionWindow"
        ,orthographicSize = 0.9
        ,width = 341
        ,height = 341
        ,offsetY = -0.4
    }

    local modelData = {type = PreViewType.Role, classes = tempClasses, sex = tempSex, looks = _looks}
    if self.previewComp1 == nil then
        self.previewComp1 = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp1:Reload(modelData, callback)
    end
end

--模型完成加载
function NationalDayQuestionWindow:on_model_build_completed(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.Preview)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
end
