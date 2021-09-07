CombatQuestionPanel = CombatQuestionPanel or BaseClass(BasePanel)

function CombatQuestionPanel:__init(model)
    self.name  =  "CombatQuestionPanel"
    self.model  =  model

    self.resList  =  {
        {file = AssetConfig.combat_questionwindow, type = AssetType.Main}
    }

    self.timeMax = 10
    self.lessTime = self.timeMax
    self.timerId = nil

    -- 窗口隐藏事件
    self.OnHideEvent:Add(function() self:OnHide() end)
    -- 窗口打开事件
    self.OnOpenEvent:Add(function() self:OnShow() end)
end

function CombatQuestionPanel:__delete()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    
    self.model = nil
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
end

function CombatQuestionPanel:Close()
    CombatManager.Instance.WatchLogmodel:CloseQuestionPanel()
end

function CombatQuestionPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.combat_questionwindow))
    self.gameObject.name = "CombatQuestionPanel"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform
    self.transform:Find("MainCon/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.titleTxt = self.transform:Find("MainCon/ImgTitle/TxtTitle"):GetComponent(Text)
    
    self.answerTitle = self.transform:Find("MainCon/Con/ImgTec/TxtLevDesc"):GetComponent(Text)
    self.question = self.transform:Find("MainCon/Con/TxtQuestion"):GetComponent(Text)

    self.progressObj = self.transform:Find("MainCon/Con/MidCon").gameObject
    self.barRect = self.transform:Find("MainCon/Con/MidCon/ImgProg/ImgBar"):GetComponent(RectTransform)
    self.timeTxt = self.transform:Find("MainCon/Con/MidCon/TxtProgTime"):GetComponent(Text)

    self.btnA = self.transform:Find("MainCon/Con/BottomCon/Btn_A")
    self.btnB = self.transform:Find("MainCon/Con/BottomCon/Btn_B")
    self.btnC = self.transform:Find("MainCon/Con/BottomCon/Btn_C")
    self.btnD = self.transform:Find("MainCon/Con/BottomCon/Btn_D")

    self.btnA:GetComponent(Button).onClick:AddListener(function() self:ClickBtn(1) end)
    self.btnB:GetComponent(Button).onClick:AddListener(function() self:ClickBtn(2) end)
    self.btnC:GetComponent(Button).onClick:AddListener(function() self:ClickBtn(3) end)
    self.btnD:GetComponent(Button).onClick:AddListener(function() self:ClickBtn(4) end)

    self.buttons = {
        {
            gameObject = self.btnA.gameObject,
            txt = self.btnA:Find("Text"):GetComponent(Text),
            img = self.btnA.gameObject:GetComponent(Image),
        },
        {
            gameObject = self.btnB.gameObject,
            txt = self.btnB:Find("Text"):GetComponent(Text),
            img = self.btnB.gameObject:GetComponent(Image)
        },
        {
            gameObject = self.btnC.gameObject,
            txt = self.btnC:Find("Text"):GetComponent(Text),
            img = self.btnC.gameObject:GetComponent(Image)
        },
        {
            gameObject = self.btnD.gameObject,
            txt = self.btnD:Find("Text"):GetComponent(Text),
            img = self.btnD.gameObject:GetComponent(Image)
        },
    }

    self:OnShow()
end

function CombatQuestionPanel:OnShow()
	if self.openArgs ~= nil then
        self.data = self.openArgs
    end
    self:Update()
end

function CombatQuestionPanel:OnHide()
end

function CombatQuestionPanel:Update()
	self.titleTxt.text = self.data.title
	self.answerTitle.text = self.data.answerTitle
	self.question.text = self.data.question
	self.callBack = self.data.callBack
	for i = 1, 4 do
		local answer = self.data.answer[i]
		if answer ~= nil then
			self.buttons[i].txt = answer
			self.buttons[i].gameObject:SetActive(true)
		else
			self.buttons[i].gameObject:SetActive(false)
		end
	end

	if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    self.timerId = LuaTimer.Add(0, 1000, function() self:UpdateTime() end)
end

function CombatQuestionPanel:UpdateTime()
    if self.lessTime >= 0 then
        self.timeTxt.text = string.format(TI18N("剩余:%s"), math.max(math.ceil(self.lessTime), 0))
        self.barRect.sizeDelta = Vector2(345 * (self.lessTime / self.timeMax), 14)
        self.lessTime = self.lessTime - 1
    else
        self:TimeOut()
    end
end

function CombatQuestionPanel:TimeOut()
	self:Close()
end

function CombatQuestionPanel:ClickBtn(index)
	if self.callBack ~= nil then
		self.callBack(index)
	end
	self:Close()
end

