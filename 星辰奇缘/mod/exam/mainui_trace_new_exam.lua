MainuiTraceNewExam = MainuiTraceNewExam or BaseClass(BaseTracePanel)

local GameObject = UnityEngine.GameObject

function MainuiTraceNewExam:__init(main)
    self.main = main
    self.isInit = false

    self.resList = {
        {file = AssetConfig.newexam_content, type = AssetType.Main},
        {file = AssetConfig.rank_textures, type = AssetType.Dep},
    }
    self.timerId = nil
    self.changeFromOutside = true

    self._Update = function() self:Update() end
    self._UpdateTime = function() self:UpdateTime() end
    self.isInit = true

    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MainuiTraceNewExam:__delete()
    self.OnHideEvent:Fire()
end

function MainuiTraceNewExam:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.newexam_content))
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.transform:Find("Main/Container"))
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition3D = Vector3(0, -45, 0)

    self.panel = self.transform:Find("Panel")
    self.panel2 = self.transform:Find("Panel2")


    self.panel_RankItem1 = self.panel:Find("Content/Rank/Item1")
    self.panel_RankItem2 = self.panel:Find("Content/Rank/Item2")
    self.panel_RankItem3 = self.panel:Find("Content/Rank/Item3")

    self.panel_RankItem1.gameObject:AddComponent(Button).onClick:AddListener(function() self:OnClickRankButton() end)
    self.panel_RankItem2.gameObject:AddComponent(Button).onClick:AddListener(function() self:OnClickRankButton() end)
    self.panel_RankItem3.gameObject:AddComponent(Button).onClick:AddListener(function() self:OnClickRankButton() end)

    self.panel_RankItem1_NameText = self.panel_RankItem1:Find("Name"):GetComponent(Text)
    self.panel_RankItem1_ScoreText = self.panel_RankItem1:Find("Score"):GetComponent(Text)
    self.panel_RankItem1_Button = self.panel_RankItem1:Find("Button").gameObject
    self.panel_RankItem1_Button:GetComponent(Button).onClick:AddListener(function() self:OnClickItemButton(1) end)

    self.panel_RankItem2_NameText = self.panel_RankItem2:Find("Name"):GetComponent(Text)
    self.panel_RankItem2_ScoreText = self.panel_RankItem2:Find("Score"):GetComponent(Text)
    self.panel_RankItem2_Button = self.panel_RankItem2:Find("Button").gameObject
    self.panel_RankItem2_Button:GetComponent(Button).onClick:AddListener(function() self:OnClickItemButton(2) end)

    self.panel_RankItem3_NameText = self.panel_RankItem3:Find("Name"):GetComponent(Text)
    self.panel_RankItem3_ScoreText = self.panel_RankItem3:Find("Score"):GetComponent(Text)
    self.panel_RankItem3_Button = self.panel_RankItem3:Find("Button").gameObject
    self.panel_RankItem3_Button:GetComponent(Button).onClick:AddListener(function() self:OnClickItemButton(3) end)

    self.panel_ExpText = self.panel:Find("Content/ExpText"):GetComponent(Text)
    self.panel_ScoreText = self.panel:Find("Content/ScoreText"):GetComponent(Text)

    self.descButton = self.panel:Find("Content/DescButton").gameObject
    self.descButton:GetComponent(Button).onClick:AddListener(function() self:OnClickDescButton() end)

    self.exitButton = self.panel:Find("ExitButton").gameObject
    self.exitButton:GetComponent(Button).onClick:AddListener(function() self:OnClickExitButton() end)

    self.rankButton = self.panel:Find("RankButton").gameObject
    self.rankButton:GetComponent(Button).onClick:AddListener(function() self:OnClickRankButton() end)
    self.toggle = self.panel:Find("Content/Toggle"):GetComponent(Toggle)

    self.panel2_DescText = self.panel2:Find("Content/DescText"):GetComponent(Text)
    self.panel2_ActiveText = self.panel2:Find("Content/ActiveText"):GetComponent(Text)

    self.exitButton2 = self.panel2:Find("ExitButton").gameObject
    self.exitButton2:GetComponent(Button).onClick:AddListener(function() self:OnClickExitButton() end)
    self.toggle.onValueChanged:AddListener(function() self:OnToggle() end)
end

function MainuiTraceNewExam:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MainuiTraceNewExam:OnShow()
    self:RemoveListeners()
    NewExamManager.Instance.OnUpdateQuestionData:Add(self._Update)
    NewExamManager.Instance.OnUpdateRankData:Add(self._Update)

    self.changeFromOutside = true
    self.toggle.isOn = (NewExamManager.Instance.model.limitStatus == 1)
    self.changeFromOutside = false

    self:Update()
end

function MainuiTraceNewExam:OnHide()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    self:RemoveListeners()
end

function MainuiTraceNewExam:RemoveListeners()
    NewExamManager.Instance.OnUpdateQuestionData:Remove(self._Update)
    NewExamManager.Instance.OnUpdateRankData:Remove(self._Update)
end

function MainuiTraceNewExam:Update()
    if NewExamManager.Instance.model.status == 1 then
        self.panel2.gameObject:SetActive(true)
        self.panel.gameObject:SetActive(false)
        self:UpdatePanel2()
    else
        self.panel.gameObject:SetActive(true)
        self.panel2.gameObject:SetActive(false)
        self:UpdatePanel()
    end
end

function MainuiTraceNewExam:UpdatePanel()
    local myQuestionData = NewExamManager.Instance.model.myQuestionData
    if myQuestionData ~= nil then
        self.panel_ExpText.text = string.format(TI18N("获得经验：%s"), myQuestionData.exp)
        self.panel_ScoreText.text = string.format(TI18N("获得积分：<color='#00ff00'>%s</color>"), myQuestionData.score)
    end

    local questionRankData = NewExamManager.Instance.model.questionRankData
    if questionRankData ~= nil then
        if questionRankData[1] ~= nil then
            self.panel_RankItem1_NameText.text = questionRankData[1].name
            self.panel_RankItem1_ScoreText.text = questionRankData[1].score
        else
            self.panel_RankItem1_NameText.text = TI18N("虚位以待")
            self.panel_RankItem1_ScoreText.text = "0"
        end
        if questionRankData[2] ~= nil then
            self.panel_RankItem2_NameText.text = questionRankData[2].name
            self.panel_RankItem2_ScoreText.text = questionRankData[2].score
        else
            self.panel_RankItem2_NameText.text = TI18N("虚位以待")
            self.panel_RankItem2_ScoreText.text = "0"
        end
        if questionRankData[3] ~= nil then
            self.panel_RankItem3_NameText.text = questionRankData[3].name
            self.panel_RankItem3_ScoreText.text = questionRankData[3].score
        else
            self.panel_RankItem3_NameText.text = TI18N("虚位以待")
            self.panel_RankItem3_ScoreText.text = "0"
        end
    else
        self.panel_RankItem1_NameText.text = TI18N("虚位以待")
        self.panel_RankItem1_ScoreText.text = "0"
        self.panel_RankItem2_NameText.text = TI18N("虚位以待")
        self.panel_RankItem2_ScoreText.text = "0"
        self.panel_RankItem3_NameText.text = TI18N("虚位以待")
        self.panel_RankItem3_ScoreText.text = "0"
    end
end

function MainuiTraceNewExam:UpdatePanel2()
    self.panel2_DescText.text = TI18N("1.根据题目<color='#ffff00'>点击答案</color>，即可跳跃到<color='#ffff00'>对应平台</color>\n2.越早进入<color='#ffff00'>正确答案平台</color>积分越多\n3.<color='#ffff00'>答错的玩家</color>将会变成<color='#ffff00'>小猪</color>，直到答对题目\n4.获得本场比赛的<color='#ffff00'>前三名</color>可以获得<color='#ffff00'>[跳跃吧！智者猪]</color>称号")

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    self.timerId = LuaTimer.Add(0, 200, self._UpdateTime)
end

function MainuiTraceNewExam:UpdateTime()
    local endTime = NewExamManager.Instance.model.endtime
    if endTime ~= nil then
        self.panel2_ActiveText.text = BaseUtils.formate_time_gap(endTime - BaseUtils.BASE_TIME, ":", 0, BaseUtils.time_formate.MIN)
    end
end

function MainuiTraceNewExam:OnClickDescButton()
    TipsManager.Instance:ShowText({gameObject = self.descButton
            , itemData = {TI18N("1.根据题目<color='#ffff00'>点击答案</color>，即可跳跃到<color='#ffff00'>对应平台</color>")
                        , TI18N("2.越早进入<color='#ffff00'>正确答案平台</color>积分越多")
                        , TI18N("3.<color='#ffff00'>答错的玩家</color>将会变成<color='#ffff00'>小猪</color>，直到答对题目")
                        , TI18N("4.获得本场比赛的<color='#ffff00'>前三名</color>可以获得<color='#ffff00'>[跳跃吧！智者猪]</color>称号")}})
end

function MainuiTraceNewExam:OnClickExitButton()
    local confirmData = NoticeConfirmData.New()
    confirmData.type = ConfirmData.Style.Normal
    confirmData.content = TI18N("你是否要退出小猪快跳？可在活动时间内再次加入！")
    confirmData.sureLabel = TI18N("确认")
    confirmData.cancelLabel = TI18N("取消")
    -- confirmData.cancelSecond = 30
    confirmData.sureCallback = function()
            NewExamManager.Instance:send20104()
        end

    NoticeManager.Instance:ConfirmTips(confirmData)
end

function MainuiTraceNewExam:OnClickRankButton()
    NewExamManager.Instance:send20109()
end

function MainuiTraceNewExam:OnClickItemButton(rankIndex)
    local questionRankData = NewExamManager.Instance.model.questionRankData
    if questionRankData ~= nil then
        if questionRankData[rankIndex] ~= nil then
            if questionRankData[rankIndex].choose == 1 then
                NewExamManager.Instance:GotoJumpPointB()
                NoticeManager.Instance:FloatTipsByString(string.format(TI18N("已跟随[%s]选择答案A"), questionRankData[rankIndex].name))
            elseif questionRankData[rankIndex].choose == 2 then
                NewExamManager.Instance:GotoJumpPointA()
                NoticeManager.Instance:FloatTipsByString(string.format(TI18N("已跟随[%s]选择答案B"), questionRankData[rankIndex].name))
            end
        end
    end
end

function MainuiTraceNewExam:OnToggle()
    if not self.changeFromOutside then
        NewExamManager.Instance.model.limitStatus = 1 - NewExamManager.Instance.model.limitStatus
        NewExamManager.Instance.model:SetLimitLocal(NewExamManager.Instance.model.limitStatus == 1)
        SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(NewExamManager.Instance.model.limitStatus == 1)
    end
end
