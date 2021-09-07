-- @author hze
-- @date 2017/06/12
--龙凤棋匹配

DragonChessMatch = DragonChessMatch or BaseClass(BaseWindow)

function DragonChessMatch:__init(model)
    self.model = model
    self.name = "DragonChessMatch"
    self.windowId = WindowConfig.WinID.dragon_chess_match

    self.resList = {
        {file = AssetConfig.dragon_chess_match, type = AssetType.Main},
        {file = AssetConfig.vsbg, type = AssetType.Main},
    }

    self.eventListener = function() self:OnEventChange() end
    self.updateListener = function()
        if self.gameObject == nil or BaseUtils.isnull(self.gameObject) then
            return
        end
        if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.DragonChessMatchSucc or RoleManager.Instance.RoleData.event ~= RoleEumn.Event.DragonChess then
            self.enemyInfo:setFunc({})
        else
            self.enemyInfo:setFunc(self.model.enemyInfo)
        end
    end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function DragonChessMatch:__delete()
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

function DragonChessMatch:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.dragon_chess_match))
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

    self.button1 = main:Find("Button1"):GetComponent(Button)
    self.button1Text = main:Find("Button1/Text"):GetComponent(Text)
    self.button1.onClick:AddListener(function() self:OnClickFriend() end)

    self.minButton = main:Find("Min"):GetComponent(Button)
    self.minButton.onClick:AddListener(function() self:OnMin() end)
    self.closeBtn = main:Find("Close"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClose() end)

    self.timeCount = main:Find("TimeCount").gameObject
    self.timeText = main:Find("TimeCount/Text"):GetComponent(Text)
    self.timeText1 = main:Find("Time"):GetComponent(Text)
    self.clockObj = main:Find("Clock").gameObject

    self.panelBtn = self.transform:Find("Panel"):GetComponent(Button)

    --屏蔽邀请好友功能
    -- self.button1.gameObject:SetActive(true)
end

function DragonChessMatch:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function DragonChessMatch:OnOpen()
    self:RemoveListeners()
    self.transform.localScale = Vector3.one
    DragonPhoenixChessManager.Instance.onChessEvent:AddListener(self.updateListener)   ---------------------------------------------
    EventMgr.Instance:AddListener(event_name.role_event_change, self.updateListener)
    EventMgr.Instance:AddListener(event_name.role_event_change, self.eventListener)

    self:OnEventChange()

    local data = BaseUtils.copytab(RoleManager.Instance.RoleData)
    data.grade = DragonPhoenixChessManager.Instance.dragonChessData.lev
    data.score = DragonPhoenixChessManager.Instance.dragonChessData.score
    self.myInfo:setFunc(data)
    if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.DragonChessMatchSucc and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.DragonChess then
        self.enemyInfo:setFunc({})
    else
        self.enemyInfo:setFunc(self.model.enemyInfo)
    end

    if self.model.iconView ~= nil then
        self.model.iconView:DeleteMe()
        self.model.iconView = nil
    end
end

function DragonChessMatch:OnHide()
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

    if RoleManager.Instance.RoleData.event == RoleEumn.Event.DragonChessMatch then
        self.model:OpenIconView()
    else
    end
end

function DragonChessMatch:RemoveListeners()
    DragonPhoenixChessManager.Instance.onChessEvent:RemoveListener(self.updateListener)
    EventMgr.Instance:RemoveListener(event_name.role_event_change, self.updateListener)
    EventMgr.Instance:RemoveListener(event_name.role_event_change, self.eventListener)
end

function DragonChessMatch:OnClick()
    if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.DragonChessMatchSucc
        and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.DragonChess
        then
        DragonPhoenixChessManager.Instance:Send20908()
        --记录开始匹配时间
        self.model.beginTime = BaseUtils.BASE_TIME
    end
end

function DragonChessMatch:SetRole(tab, data)
    if tab == nil or tab.classImage == nil then
        return
    end
    data = data or {}
    if data.classes == nil or data.classes == 0 then
        if RoleManager.Instance.RoleData.event == RoleEumn.Event.DragonChessMatch then
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
        if DataCampBlackWhiteChess.data_grade[data.grade] ~= nil then
            tab.valueText.text = DataCampBlackWhiteChess.data_grade[data.grade].name
        else
            tab.valueText.text = "???"
        end
        -- BaseUtils.dump(data)
        tab.classImage.gameObject:SetActive(true)
        tab.nameText.text = data.name
        tab.classImage.sprite = PreloadManager.Instance:GetClassesSprite(data.classes)
        tab.headSlot:SetAll(data, {isSmall = true, noPortrait = true})
    end
end

function DragonChessMatch:OnMin()
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
    end
    self.tweenId = Tween.Instance:ValueChange(1, 0.1, 0.2, function() self.tweenId = nil WindowManager.Instance:CloseWindow(self) end, LeanTweenType.easeOutQuad, function(value)
            self.transform.localScale = Vector3(value, value, value)
            self.transform.anchoredPosition = Vector2(0, (1 - value) * -150)
        end).id
end

function DragonChessMatch:OnClose()
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.DragonChessMatch then
        DragonPhoenixChessManager.Instance:Send20909()
    end
    WindowManager.Instance:CloseWindow(self)
end

function DragonChessMatch:OnFlash()
    self.counter = ((self.counter or 0) + 1) % 14
    self.enemyInfo.headSlot:Default()
    self.enemyInfo.headSlot.baseLoader.gameObject:SetActive(true)
    self.enemyInfo.headSlot.baseLoader:SetOtherSprite(PreloadManager.Instance:GetClassesHeadSprite(self.counter % 7 + 1, math.floor(self.counter / 7)))
    self.enemyInfo.classImage.gameObject:SetActive(true)
    self.enemyInfo.classImage.sprite = PreloadManager.Instance:GetClassesSprite(self.counter % 7 + 1)

    self.timeText.text = BaseUtils.formate_time_gap(BaseUtils.BASE_TIME - self.model.beginTime, ":", 0, BaseUtils.time_formate.MIN)
    self.enemyInfo.nameText.text = "???"
end

function DragonChessMatch:OnEventChange()
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
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.DragonChessMatch then
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
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.DragonChessMatchSucc then
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
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.DragonChess then
        WindowManager.Instance:CloseWindow(self)
    else
        self.minButton.gameObject:SetActive(true)
        self.timeText1.text = ""
        self.buttonText.text = TI18N("开始匹配")
        self.timeText.text = "00:00"
        self.timeCount:SetActive(false)
        self.clockObj:SetActive(false)
        self:ShowEffect(self.model.times > 0)
        self.panelBtn.onClick:RemoveAllListeners()
        self.panelBtn.onClick:AddListener(function() self:OnClose() end)
        self.timeText1.text = string.format(TI18N("<color='#00ff00'>剩余次数:%s/2</color>"), tostring(self.model.times or 0))
    end

    local data = BaseUtils.copytab(RoleManager.Instance.RoleData)
    data.grade = DragonPhoenixChessManager.Instance.dragonChessData.lev
    data.score = DragonPhoenixChessManager.Instance.dragonChessData.score
    self.myInfo:setFunc(data)
    self.enemyInfo:setFunc(self.model.enemyInfo)
end

function DragonChessMatch:OnCountdown()
    local dis = self.model.next_time_step - BaseUtils.BASE_TIME
    if dis < 0 then dis = 0 end
    self.timeText1.text = string.format(TI18N("%s秒后进入游戏"), dis)
end

function DragonChessMatch:ShowEffect(bool)
    if bool == true then
        if self.effect ~= nil then
            self.effect:SetActive(true)
        else
            self.effect = BibleRewardPanel.ShowEffect(20053, self.button.transform, Vector3(1.8, 0.7, 1), Vector3(-59.5, -15.33, -398))
        end
    else
        if self.effect ~= nil then
            self.effect:SetActive(false)
        end
    end
end

function DragonChessMatch:OnButtonText()
    self.buttonCounter = ((self.buttonCounter or 0) + 1) % 4
    local dotList = {}
    for i=1,self.buttonCounter do
        table.insert(dotList, ".")
    end
    self.buttonText.text = TI18N("匹配中") .. table.concat(dotList)
end

function DragonChessMatch:OnClickFriend()
    if self.model.times > 0 then 
        NoticeManager.Instance:FloatTipsByString(TI18N("需要完成2次匹配后，才可邀请好友进行友谊赛哦~{face_1,3}"))
    else
        local callBack = function(dat)
                for k,v in pairs(dat) do
                    DragonPhoenixChessManager.Instance:Send20912(v.id, v.platform, v.zone_id)
                end
            end
        -- NoticeManager.Instance:FloatTipsByString(TI18N("邀请好友<color='#c03e39'>不计入</color>每日的奖励次数哦~{face_1,22}"))
        --打开好友选择界面
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.friendselect, { callBack, 3 })
    end
end
