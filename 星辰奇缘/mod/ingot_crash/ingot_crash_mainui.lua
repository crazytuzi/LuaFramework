IngotCrashMainUI = IngotCrashMainUI or BaseClass(BasePanel)

function IngotCrashMainUI:__init(model, parent)
    self.model = model
    self.name = "IngotCrashMainUI"
    self.parent = parent

    self.resList = {
        {file = AssetConfig.ingotcrash_mainui, type = AssetType.Main},
        {file = AssetConfig.ingotcrash_textures, type = AssetType.Dep},
    }

    self.status = 0
    self.buttonY = -48

    self.updateListener = function() self:Update() end
    self.beginFightListener = function() self:BeginFight() end
    self.moveListener = function() self:BeginMove() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function IngotCrashMainUI:__delete()
    self.OnHideEvent:Fire()
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
    if self.readyHeadSlot1 ~= nil then
        self.readyHeadSlot1:DeleteMe()
        self.readyHeadSlot1 = nil
    end
    if self.readyHeadSlot2 ~= nil then
        self.readyHeadSlot2:DeleteMe()
        self.readyHeadSlot2 = nil
    end
    self:AssetClearAll()
end

function IngotCrashMainUI:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.ingotcrash_mainui))
    local t = self.gameObject.transform
    self.transform = t

    self:SetParent(self.parent)

    self.gameObject.name = self.name

    self.top = t:Find("Top")
    self.button = t:Find("Top/Button"):GetComponent(Button)
    self.buttonArrow = t:Find("Top/Button/Image"):GetComponent(Image)

    self.qualifier = self.top:Find("Qualifier")
    self.qualifierNameText = self.qualifier:Find("Name"):GetComponent(Text)
    self.qualifierTimeText = self.qualifier:Find("Time"):GetComponent(Text)

    self.ready = self.top:Find("Ready")
    self.readyNameText1 = self.ready:Find("Name1"):GetComponent(Text)
    self.readyNameText2 = self.ready:Find("Name2"):GetComponent(Text)
    self.readyDescText = self.ready:Find("Desc"):GetComponent(Text)
    self.readyHeadSlot1 = HeadSlot.New()
    self.readyHeadSlot2 = HeadSlot.New()
    NumberpadPanel.AddUIChild(self.ready:Find("Head1"), self.readyHeadSlot1.gameObject)
    NumberpadPanel.AddUIChild(self.ready:Find("Head2"), self.readyHeadSlot2.gameObject)

    self.battle = self.top:Find("Battle")
    self.battleText = self.battle:Find("Text"):GetComponent(Text)
    self.battleTimeText = self.battle:Find("Time"):GetComponent(Text)
    self.battleClockImage = self.battle:Find("Clock"):GetComponent(Image)
    self.battleNoticeBtn = self.battle:Find("Notice"):GetComponent(Button)

    self.watchBtn = self.top:Find("Watch"):GetComponent(Button)

    self.battleNoticeBtn.onClick:AddListener(function() self:OnNotice() end)
    self.button.onClick:AddListener(function() self:OnClick() end)
    self.watchBtn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ingot_crash_watch) end)

    self.isShow = true
    self.battleText.transform.sizeDelta = Vector2(300, 30)
end

function IngotCrashMainUI:TweenHide()
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
    if self.tweenButtonId ~= nil then
        Tween.Instance:Cancel(self.tweenButtonId)
        self.tweenButtonId = nil
    end
    self.tweenId = Tween.Instance:MoveY(self.top, 24 - self.buttonY, 0.5, function() self.tweenId = nil end, LeanTweenType.linear).id

    self.isShow = false

    self.button.transform.localScale = Vector2(1, -1, 1)
end

function IngotCrashMainUI:TweenShow()
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
    if self.tweenButtonId ~= nil then
        Tween.Instance:Cancel(self.tweenButtonId)
        self.tweenButtonId = nil
    end
    local y = self.button.transform.anchoredPosition.y
    self.button.transform.localScale = Vector2.one

    self.tweenId = Tween.Instance:MoveY(self.top, 0, 0.5, function() self.tweenId = nil end, LeanTweenType.linear).id
    self.tweenButtonId = Tween.Instance:MoveY(self.button.transform, self.buttonY, math.abs(self.buttonY - self.button.transform.anchoredPosition.y) / 180, function() self.tweenButtonId = nil end, LeanTweenType.linear).id

    self.isShow = true

    -- self:Update()
end

function IngotCrashMainUI:SetQualifier()
    self.status = 1
    self.ready.gameObject:SetActive(false)
    self.battle.gameObject:SetActive(false)
    self.qualifier.gameObject:SetActive(true)

    self.isShow = true
    self.button.transform.localScale = Vector2.one
    if IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Qualifier then
        local num = (self.model.personData.win or 0) + (self.model.personData.lose or 0) + 1
        if num == 4 then
            num = 3
        end
        self.qualifierNameText.text = string.format(TI18N("资格赛第%s轮"), num)
    elseif IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Kickout or IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Guess then
        self.qualifierNameText.text = TI18N("淘汰赛进行中")
    elseif IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Close then
        self.qualifierNameText.text = TI18N("活动已结束")
    end

    self.buttonY = -48

    if not CombatManager.Instance.isFighting and SceneManager.Instance:CurrentMapId() ~= 53004 then
        self:TweenShow()
    end
end

function IngotCrashMainUI:SetReady()
    self.status = 2
    self.qualifier.gameObject:SetActive(false)
    self.battle.gameObject:SetActive(false)
    self.ready.gameObject:SetActive(true)

    self.isShow = true
    self.button.transform.localScale = Vector2.one
    self.buttonY = -72

    self.readyHeadSlot1:SetAll(RoleManager.Instance.RoleData, {isSmall = true})
    self.readyNameText1.text = RoleManager.Instance.RoleData.name

    if self.model.enemyData == nil then
        self.readyHeadSlot2:SetMystery()
        self.readyNameText2.text = TI18N("神秘高手")
    else
        self.readyHeadSlot2:SetAll(self.model.enemyData, {isSmall = true})
        self.readyNameText2.text = self.model.enemyData.name
    end

    if not CombatManager.Instance.isFighting and SceneManager.Instance:CurrentMapId() ~= 53004 then
        self:TweenShow()
    end
end

function IngotCrashMainUI:SetBattle()
    self.status = 3
    self.ready.gameObject:SetActive(false)
    self.qualifier.gameObject:SetActive(false)
    self.battle.gameObject:SetActive(true)

    self.battleText.text = TI18N("战斗剩余时间:")

    self.battleText.transform.anchoredPosition = Vector2(-5, 0)
    self.battleClockImage.transform.anchoredPosition = Vector2(10, 0)
    self.battleTimeText.transform.anchoredPosition = Vector2(22, 0)

    self.isShow = true
    self.buttonY = -48
    self.button.transform.localScale = Vector2.one

    if not CombatManager.Instance.isFighting and SceneManager.Instance:CurrentMapId() ~= 53004 then
        self:TweenShow()
    end
end

function IngotCrashMainUI:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function IngotCrashMainUI:OnHide()
    self:RemoveListeners()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
end

function IngotCrashMainUI:OnOpen()
    self:RemoveListeners()
    IngotCrashManager.Instance.onUpdateInfo:AddListener(self.updateListener)
    EventMgr.Instance:AddListener(event_name.begin_fight, self.updateListener)
    EventMgr.Instance:AddListener(event_name.begin_fight, self.beginFightListener)
    EventMgr.Instance:AddListener(event_name.end_fight, self.updateListener)
    EventMgr.Instance:AddListener(event_name.scene_load, self.updateListener)
    IngotCrashManager.Instance.onUpdateMove:AddListener(self.moveListener)

    IngotCrashManager.Instance:send20019()

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 40, function() self:OnTime() end)
    end

    self:Update()
end

function IngotCrashMainUI:RemoveListeners()
    IngotCrashManager.Instance.onUpdateInfo:RemoveListener(self.updateListener)
    EventMgr.Instance:RemoveListener(event_name.begin_fight, self.updateListener)
    EventMgr.Instance:RemoveListener(event_name.begin_fight, self.beginFightListener)
    EventMgr.Instance:RemoveListener(event_name.end_fight, self.updateListener)
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.updateListener)
    IngotCrashManager.Instance.onUpdateMove:RemoveListener(self.moveListener)
end

function IngotCrashMainUI:OnTime()
    if self.status == 0 then
        return
    end

    local timeText = nil
    local dis = (IngotCrashManager.Instance.time or 0) - BaseUtils.BASE_TIME
    if CombatManager.Instance.isFighting or RoleManager.Instance.RoleData.event == RoleEumn.Event.IngotCrashPVP then
        dis = (IngotCrashManager.Instance.combat_stemp or BaseUtils.BASE_TIME) - BaseUtils.BASE_TIME
    end
    local min_str = nil
    local sec_str = nil
    local time_str = nil
    if dis < 0 then
        dis = 0
    end
    min_str = math.floor(dis / 60)
    sec_str = dis % 60
    if min_str < 10 then
        min_str = string.format("0%s", min_str)
    end
    if sec_str < 10 then
        sec_str = string.format("0%s", sec_str)
    end

    if self.status == 1 then
        self.qualifierTimeText.text = string.format("%s:%s", min_str, sec_str)
    elseif self.status == 2 then
        self.readyDescText.text = string.format(TI18N("<color='#00ff00'>%s秒</color>后将发起战斗！"), dis)
    elseif self.status == 3 then
        self.battleTimeText.text = string.format("%s:%s", min_str, sec_str)
    end
end

function IngotCrashMainUI:OnClick()
    if self.isShow then
        self:TweenHide()
    else
        self:TweenShow()
    end
end

function IngotCrashMainUI:OnNotice()
    TipsManager.Instance:ShowText({gameObject = self.battleNoticeBtn.gameObject, itemData = {
            TI18N("战斗限制："),
            TI18N("1.每场战斗最长<color='#00ff00'>12回合</color>"),
            TI18N("2.<color='#00ff00'>资格赛</color>每场战斗时限为<color='#00ff00'>4分钟</color>"),
            TI18N("3.<color='#00ff00'>淘汰赛</color>每场战斗时限为<color='#00ff00'>8分钟</color>"),
            TI18N("4.超出限制将按照单位数量、血量判定胜负"),
        }})
end

function IngotCrashMainUI:SetParent(parent)
    self.parent = parent
    self.transform:SetParent(parent.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero

    if self.isShow == true then
        self:TweenShow()
    elseif self.isShow == false then
        self:TweenHide()
    else
        self.transform.anchoredPosition = Vector2.zero
    end
end

function IngotCrashMainUI:Update()
    local phase = IngotCrashManager.Instance.phase

    if RoleManager.Instance.RoleData.event == RoleEumn.Event.IngotCrashPVP then
        if CombatManager.Instance.isFighting == true then
            self:SetBattle()
        else
            self:SetReady()
        end
    else
        self:SetQualifier()
    end

    self.top.gameObject:SetActive(phase ~= IngotCrashEumn.Phase.Close and phase ~= IngotCrashEumn.Phase.Ready)
    self.watchBtn.gameObject:SetActive(CombatManager.Instance.isFighting ~= true and SceneManager.Instance:CurrentMapId() ~= 53004)
end

function IngotCrashMainUI:BeginFight()
    self:TweenHide()
end

function IngotCrashMainUI:BeginMove()
    self:TweenHide()
end
