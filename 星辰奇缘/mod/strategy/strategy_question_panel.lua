-- @author 黄耀聪
-- @date 2016年7月8日

StrategyQuestionPanel = StrategyQuestionPanel or BaseClass(BasePanel)

function StrategyQuestionPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "StrategyQuestionPanel"
    self.mgr = StrategyManager.Instance

    self.resList = {
        {file = AssetConfig.strategy_question_panel, type = AssetType.Main},
    }

    self.options = {nil, nil, nil, nil}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function StrategyQuestionPanel:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function StrategyQuestionPanel:InitPanel()
    if self.parent == nil then
        self:AssetClearAll()
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.strategy_question_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    t:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self.model:CloseQuestionPanel() end)
    t:Find("MainCon/CloseButton"):GetComponent(Button).onClick:AddListener(function() self.model:CloseQuestionPanel() end)

    local main = t:Find("MainCon")

    self.titleText = main:Find("ImgTitle/TxtTitle"):GetComponent(Text)
    self.questionTitleText = main:Find("OpenCon/ImgTec/TxtLevDesc"):GetComponent(Text)
    self.questionText = main:Find("OpenCon/TxtQuestion"):GetComponent(Text)

    local optionCon = main:Find("OpenCon/BottomCon")
    local len = optionCon.childCount
    for i=0,len-1 do
        local tab = {}
        tab.trans = optionCon:GetChild(i)
        tab.obj = tab.trans.gameObject
        tab.image = tab.obj:GetComponent(Image)
        tab.text = tab.trans:Find("Text"):GetComponent(Text)
        tab.right = tab.trans:Find("ImgRight").gameObject
        tab.wrong = tab.trans:Find("ImgWrong").gameObject
        tab.btn = tab.obj:GetComponent(Button)
        tab.btn.onClick:AddListener(function() self:Check(i + 1) end)
        self.options[i + 1] = tab
    end

    main:Find("ImgClock").gameObject:SetActive(false)
    main:Find("TxtClock").gameObject:SetActive(false)
    main:Find("OpenCon/MidCon").gameObject:SetActive(false)

    main:Find("ScoreCon/ImgBookIcon"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Attention")
    self.attentionText = main:Find("ScoreCon/TxtScore"):GetComponent(Text)
    main:Find("ScoreCon/ImgTanhao").gameObject:SetActive(false)
    local rect = self.attentionText.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(0, 1)
    rect.anchorMin = Vector2(0, 1)
    rect.pivot = Vector2(0, 1)
    rect.anchoredPosition = Vector2(30.1, -1.4)
    self.msgItemExt = MsgItemExt.New(self.attentionText, 467, 17, 20)
    self.msgItemExt:SetData(TI18N("回答全部问题后可获得<color='#00FF00'>奖励</color>，关闭界面可再次查看攻略"), true)

    self.titleText.text = TI18N("攻略答题")
end

function StrategyQuestionPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function StrategyQuestionPanel:OnOpen()
    self:RemoveListeners()

    local model = self.model
    self.titleId = self.openArgs
    self.currentStep = 1
    local answer = model.questionsTab[self.titleId].answer
    for i,v in ipairs(answer) do
        if v.result ~= true then
            self.currentStep = i
            break
        end
    end

    self:Update(answer[self.currentStep])
end

function StrategyQuestionPanel:OnHide()
    self:RemoveListeners()
end

function StrategyQuestionPanel:RemoveListeners()
end

function StrategyQuestionPanel:Update(data)
    self.lock = false
    self.questionTitleText.text = TI18N("攻略答题")
    self.questionText.text = data.name
    local tab = {"A", "B", "C", "D"}
    for i,v in ipairs(self.options) do
        if data.list[i] == nil then
            v.obj:SetActive(false)
        else
            local optionData = data.list[i]
            v.obj:SetActive(true)
            v.text.text = string.format("%s %s", tostring(tab[optionData.question_num]), optionData.question_name)
            v.right:SetActive(false)
            v.wrong:SetActive(false)
            v.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        end
    end
end

function StrategyQuestionPanel:Check(index)
    local model = self.model
    if self.lock then
        return
    end
    local data = model.questionsTab[self.titleId].answer[self.currentStep]
    if data.correct == index then
        self.lock = true
        self.options[index].right:SetActive(true)
        data.result = true
        NoticeManager.Instance:FloatTipsByString(TI18N("恭喜你回答<color='#FFFF00'>正确</color>{face_1,38}"))
        if self.currentStep == #model.questionsTab[self.titleId].answer then
            self.mgr:send16607(self.titleId)
            LuaTimer.Add(2000, function() model:CloseQuestionPanel() end)
        else
            LuaTimer.Add(2000, function() self:GoNext() end)
        end
    else
        self.options[index].wrong:SetActive(true)
        NoticeManager.Instance:FloatTipsByString(TI18N("回答<color='#FFFF00'>错误</color>，再仔细思考一下吧{face_1,26}"))
    end
end

function StrategyQuestionPanel:GoNext()
    if BaseUtils.is_null(self.gameObject) then
        return
    end
    self.currentStep = self.currentStep + 1
    self:Update(self.model.questionsTab[self.titleId].answer[self.currentStep])
end

