-- @author 黄耀聪
-- @date 2017年5月3日

AnimalChessMatch = AnimalChessMatch or BaseClass(BaseWindow)

function AnimalChessMatch:__init(model)
    self.model = model
    self.name = "AnimalChessMatch"
    self.windowId = WindowConfig.WinID.animal_chess_match

    self.resList = {
        {file = AssetConfig.animal_chess_match, type = AssetType.Main},
        {file = AssetConfig.vsbg, type = AssetType.Main},
    }

    self.eventListener = function() self:OnEventChange() end
    self.updateListener = function()
        if self.gameObject == nil or BaseUtils.isnull(self.gameObject) then
            return
        end
        if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.AnimalChessMatchSucc or RoleManager.Instance.RoleData.event ~= RoleEumn.Event.AnimalChess then
            self.enemyInfo:setFunc({})
        else
            self.enemyInfo:setFunc(self.model.enemyInfo)
        end
    end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function AnimalChessMatch:__delete()
    self.OnHideEvent:Fire()
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    if self.myInfo.classImage ~= nil then
        self.myInfo.classImage.sprite = nil
        self.myInfo.classImage = nil
    end
    if self.enemyInfo.classImage ~= nil then
        self.enemyInfo.classImage.sprite = nil
        self.enemyInfo.classImage = nil
    end
    if self.myInfo.headSlot ~= nil then
        self.myInfo.headSlot:DeleteMe()
        self.myInfo.headSlot = nil
    end
    if self.enemyInfo.headSlot ~= nil then
        self.enemyInfo.headSlot:DeleteMe()
        self.enemyInfo.headSlot = nil
    end
    self:AssetClearAll()
end

function AnimalChessMatch:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.animal_chess_match))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    local main = t:Find("Main")
    UIUtils.AddBigbg(main:Find("Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.vsbg)))

    self.myInfo = {
        headSlot = HeadSlot.New(),
        nameText = main:Find("Left/NameBg/Name"):GetComponent(Text),
        classImage = main:Find("Left/ClassImage"):GetComponent(Image),
        valueText = main:Find("Left/ValueBg/Text"):GetComponent(Text),
        setFunc = function(tab, data) self:SetRole(tab, data) end,
    }
    NumberpadPanel.AddUIChild(main:Find("Left/Head"), self.myInfo.headSlot.gameObject)
    self.enemyInfo = {
        headSlot = HeadSlot.New(),
        nameText = main:Find("Right/NameBg/Name"):GetComponent(Text),
        classImage = main:Find("Right/ClassImage"):GetComponent(Image),
        valueText = main:Find("Right/ValueBg/Text"):GetComponent(Text),
        setFunc = function(tab, data) self:SetRole(tab, data) end,
    }
    NumberpadPanel.AddUIChild(main:Find("Right/Head"), self.enemyInfo.headSlot.gameObject)

    self.button = main:Find("Button"):GetComponent(Button)
    self.buttonText = main:Find("Button/Text"):GetComponent(Text)
    self.button.onClick:AddListener(function() self:OnClick() end)

    self.minButton = main:Find("Min"):GetComponent(Button)
    self.minButton.onClick:AddListener(function() self:OnMin() end)
    self.closeBtn = main:Find("Close"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClose() end)

    self.timeCount = main:Find("TimeCount").gameObject
    self.timeText = main:Find("TimeCount/Text"):GetComponent(Text)
    self.timeText1 = main:Find("Time"):GetComponent(Text)
    self.clockObj = main:Find("Clock").gameObject

    self.panelBtn = self.transform:Find("Panel"):GetComponent(Button)
end

function AnimalChessMatch:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function AnimalChessMatch:OnOpen()
    self:RemoveListeners()
    self.transform.localScale = Vector3.one
    AnimalChessManager.Instance.onChessEvent:AddListener(self.updateListener)
    EventMgr.Instance:AddListener(event_name.role_event_change, self.updateListener)
    EventMgr.Instance:AddListener(event_name.role_event_change, self.eventListener)

    self:OnEventChange()

    local data = BaseUtils.copytab(RoleManager.Instance.RoleData)
    data.grade = AnimalChessManager.Instance.animalChessData.lev
    data.score = AnimalChessManager.Instance.animalChessData.score
    self.myInfo:setFunc(data)
    if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.AnimalChessMatchSucc and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.AnimalChess then
        self.enemyInfo:setFunc({})
    else
        self.enemyInfo:setFunc(self.model.enemyInfo)
    end

    if self.model.iconView ~= nil then
        self.model.iconView:DeleteMe()
        self.model.iconView = nil
    end
end

function AnimalChessMatch:OnHide()
    self:RemoveListeners()
    if self.buttonTimerId ~= nil then
        LuaTimer.Delete(self.buttonTimerId)
        self.buttonTimerId = nil
    end
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.countTimerId ~= nil then
        LuaTimer.Delete(self.countTimerId)
        self.countTimerId = nil
    end

    if RoleManager.Instance.RoleData.event == RoleEumn.Event.AnimalChessMatch then
        self.model:OpenIconView()
    else
    end
end

function AnimalChessMatch:RemoveListeners()
    AnimalChessManager.Instance.onChessEvent:RemoveListener(self.updateListener)
    EventMgr.Instance:RemoveListener(event_name.role_event_change, self.updateListener)
    EventMgr.Instance:RemoveListener(event_name.role_event_change, self.eventListener)
end

function AnimalChessMatch:OnClick()
    if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.AnimalChessMatchSucc
        and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.AnimalChess
        then
        AnimalChessManager.Instance:send17847()
        self.model.beginTime = BaseUtils.BASE_TIME
    end
end

function AnimalChessMatch:SetRole(tab, data)
    if tab == nil or tab.classImage == nil then
        return
    end
    data = data or {}
    if data.classes == nil or data.classes == 0 then
        if RoleManager.Instance.RoleData.event == RoleEumn.Event.AnimalChessMatch then
        else
            if self.countTimerId ~= nil then
                LuaTimer.Delete(self.countTimerId)
                self.countTimerId = nil
            end
            tab.classImage.gameObject:SetActive(false)
            tab.nameText.text = TI18N("神秘人")
            tab.headSlot:Default()
            tab.headSlot.baseLoader.gameObject:SetActive(true)
            tab.headSlot:SetMystery()
        end
        tab.valueText.text = "???"
    else
        if DataCampAnimalChess.data_grade[data.grade] ~= nil then
            tab.valueText.text = DataCampAnimalChess.data_grade[data.grade].name
        else
            tab.valueText.text = "???"
        end
        BaseUtils.dump(data)
        tab.classImage.gameObject:SetActive(true)
        tab.nameText.text = data.name
        tab.classImage.sprite = PreloadManager.Instance:GetClassesSprite(data.classes)
        tab.headSlot:SetAll(data, {isSmall = true})
    end
end

function AnimalChessMatch:OnMin()
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
    end
    self.tweenId = Tween.Instance:ValueChange(1, 0.1, 0.2, function() self.tweenId = nil WindowManager.Instance:CloseWindow(self) end, LeanTweenType.easeOutQuad, function(value)
            self.transform.localScale = Vector3(value, value, value)
            self.transform.anchoredPosition = Vector2(0, (1 - value) * -150)
        end).id
end

function AnimalChessMatch:OnClose()
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.AnimalChessMatch then
        AnimalChessManager.Instance:send17847()
        NoticeManager.Instance:FloatTipsByString(TI18N("取消匹配"))
    end
    WindowManager.Instance:CloseWindow(self)
end

function AnimalChessMatch:OnFlash()
    self.counter = ((self.counter or 0) + 1) % 14
    self.enemyInfo.headSlot:Default()
    self.enemyInfo.headSlot.baseLoader.gameObject:SetActive(true)
    self.enemyInfo.headSlot.baseLoader:SetOtherSprite(PreloadManager.Instance:GetClassesHeadSprite(self.counter % 7 + 1, math.floor(self.counter / 7)))
    self.enemyInfo.classImage.gameObject:SetActive(true)
    self.enemyInfo.classImage.sprite = PreloadManager.Instance:GetClassesSprite(self.counter % 7 + 1)

    self.timeText.text = BaseUtils.formate_time_gap(BaseUtils.BASE_TIME - self.model.beginTime, ":", 0, BaseUtils.time_formate.MIN)
    self.enemyInfo.nameText.text = "???"
end

function AnimalChessMatch:OnEventChange()
    if self.gameObject == nil or BaseUtils.isnull(self.gameObject) then
        return
    end
    if self.buttonTimerId ~= nil then
        LuaTimer.Delete(self.buttonTimerId)
        self.buttonTimerId = nil
    end
    if self.countTimerId ~= nil then
        LuaTimer.Delete(self.countTimerId)
        self.countTimerId = nil
    end
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.AnimalChessMatch then
        self.model.enemyInfo = {}
        self.buttonText.text = TI18N("匹配中")
        self.timeText1.text = ""
        self.minButton.gameObject:SetActive(true)
        self.closeBtn.gameObject:SetActive(true)
        self.timeCount:SetActive(true)
        self.clockObj:SetActive(true)
        self:ShowEffect(false)
        self.panelBtn.onClick:RemoveAllListeners()
        self.panelBtn.onClick:AddListener(function() self:OnMin() end)

        self.buttonTimerId = LuaTimer.Add(0, 800, function() self:OnButtonText() end)
        self.timeText1.text = string.format(TI18N("<color='#00ff00'>剩余次数:%s/2</color>"), tostring(self.model.times or 0))
        self.countTimerId = LuaTimer.Add(0, 100, function() self:OnFlash() end)
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.AnimalChessMatchSucc
        then
        self.minButton.gameObject:SetActive(false)
        self.closeBtn.gameObject:SetActive(false)
        self.timeCount:SetActive(false)
        self.clockObj:SetActive(false)
        self.buttonText.text = TI18N("匹配成功")
        if self.timerId ~= nil then
            LuaTimer.Delete(self.timerId)
        end
        self.timerId = LuaTimer.Add(0, 160, function() self:OnCountdown() end)
        self:ShowEffect(false)
        self.panelBtn.onClick:RemoveAllListeners()
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.AnimalChess then
        WindowManager.Instance:CloseWindow(self)
    else
        self.minButton.gameObject:SetActive(true)
        self.timeText1.text = ""
        self.buttonText.text = TI18N("开始匹配")
        self.timeText.text = "00:00"
        self.timeCount:SetActive(false)
        self.clockObj:SetActive(false)
        self:ShowEffect(true)
        self.panelBtn.onClick:RemoveAllListeners()
        self.panelBtn.onClick:AddListener(function() self:OnClose() end)
        self.timeText1.text = string.format(TI18N("<color='#00ff00'>剩余次数:%s/2</color>"), tostring(self.model.times or 0))
    end

    local data = BaseUtils.copytab(RoleManager.Instance.RoleData)
    data.grade = AnimalChessManager.Instance.animalChessData.lev
    data.score = AnimalChessManager.Instance.animalChessData.score
    self.myInfo:setFunc(data)
    self.enemyInfo:setFunc(self.model.enemyInfo)
end

function AnimalChessMatch:OnCountdown()
    local dis = self.model.next_time_stemp - BaseUtils.BASE_TIME
    if dis < 0 then dis = 0 end
    self.timeText1.text = string.format(TI18N("%s秒后进入游戏"), dis)
end

function AnimalChessMatch:ShowEffect(bool)
    if bool == true then
        if self.effect ~= nil then
            self.effect:SetActive(true)
        else
            self.effect = BibleRewardPanel.ShowEffect(20053, self.button.transform, Vector3(1.8, 0.7, 1), Vector3(-59.5, -15.33, -400))
        end
    else
        if self.effect ~= nil then
            self.effect:SetActive(false)
        end
    end
end

function AnimalChessMatch:OnButtonText()
    self.buttonCounter = ((self.buttonCounter or 0) + 1) % 4
    local dotList = {}
    for i=1,self.buttonCounter do
        table.insert(dotList, ".")
    end
    self.buttonText.text = TI18N("匹配中") .. table.concat(dotList)
end

