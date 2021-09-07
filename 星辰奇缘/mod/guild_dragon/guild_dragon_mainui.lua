GuildDragonMainUI = GuildDragonMainUI or BaseClass(BasePanel)

function GuildDragonMainUI:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "GuildDragonMainUI"

    self.resList = {
        {file = AssetConfig.guilddragon_mainui, type = AssetType.Main},
        {file = AssetConfig.guilddragon_textures, type = AssetType.Dep},
    }

    self.beginFightListener = function() self:CheckFight(true) end
    self.endFightListener = function() self:CheckFight(false) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GuildDragonMainUI:__delete()
    self.OnHideEvent:Fire()
    if self.iconLoader ~= nil then
        self.iconLoader:DeleteMe()
        self.iconLoader = nil
    end
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    if self.readyEffect ~= nil then
        self.readyEffect:DeleteMe()
        self.readyEffect = nil
    end
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function GuildDragonMainUI:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guilddragon_mainui))
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform.localPosition = Vector3(0, 0, 1000)

    local battle = self.transform:Find("Battle")
    self.iconLoader = SingleIconLoader.New(battle:Find("Icon").gameObject)
    self.iconButton = battle:Find("Icon"):GetComponent(Button)

    self.slider1 = battle:Find("Slider/Value1"):GetComponent(Slider)
    self.slider2 = battle:Find("Slider/Value2"):GetComponent(Slider)
    self.slider3 = battle:Find("Slider/Value3"):GetComponent(Slider)
    self.sliderText = battle:Find("Slider/Text"):GetComponent(Text)
    self.sliderBtn = battle:Find("Slider"):GetComponent(Button)
    self.sliderHeadBtn = battle:Find("Slider/Head"):GetComponent(Button)

    self.text = battle:Find("Text"):GetComponent(Text)
    self.textBg = battle:Find("Bg")
    self.timeText = battle:Find("Time"):GetComponent(Text)
    self.multiText = battle:Find("Multi"):GetComponent(Text)

    self.renderers = {}
    self.renderers[1] = self.text.gameObject:GetComponent(Renderer)
    self.renderers[2] = self.textBg.gameObject:GetComponent(Renderer)

    self.nameText = battle:Find("Name/Text"):GetComponent(Text)
    self.battle = battle
    self.rects = self.gameObject:GetComponentsInChildren(RectTransform)

    self.iconButton.onClick:AddListener(function() self:OnClickIcon() end)
    self.iconLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "364"))
    self.timeText.text = ""

    self.sliderBtn.onClick:AddListener(function() GuildDragonManager.Instance:Challenge() end)
    self.sliderHeadBtn.onClick:AddListener(function() GuildDragonManager.Instance:Challenge() end)
end

function GuildDragonMainUI:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildDragonMainUI:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.begin_fight, self.beginFightListener)
    EventMgr.Instance:AddListener(event_name.end_fight, self.endFightListener)

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 2000, function() self:Update() end)
    end

    self:CheckFight(CombatManager.Instance.isFighting)

    if self.openArgs ~= nil then
        self:ShowText(self.openArgs or "")
        -- self.timeText.text = BaseUtils.formate_time_gap(GuildDragonManager.Instance.end_time - BaseUtils.BASE_TIME, ":", 0, BaseUtils.time_formate.MIN)
        -- self.sliderText.text = string.format(TI18N("剩余时间：%s"), BaseUtils.formate_time_gap(GuildDragonManager.Instance.end_time - BaseUtils.BASE_TIME, ":", 0, BaseUtils.time_formate.MIN))
        self.sliderText.text = string.format("%s%%", math.ceil(GuildDragonManager.Instance:GetRest(BaseUtils.BASE_TIME) / 10))
        self:CheckRod()
        self:CheckReadyEffect()
        self:OnBattle()
    end
end

function GuildDragonMainUI:OnHide()
    self:RemoveListeners()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.alphaTimerId ~= nil then
        LuaTimer.Delete(self.alphaTimerId)
        self.alphaTimerId = nil
    end
end

function GuildDragonMainUI:Update()
    -- local value = GuildDragonManager.Instance:GetRest(BaseUtils.BASE_TIME)

    if GuildDragonManager.Instance.state == GuildDragonEnum.State.Ready
        or GuildDragonManager.Instance.state == GuildDragonEnum.State.Countdown
        or GuildDragonManager.Instance.state == GuildDragonEnum.State.First
        then
        self.slider1.value = (GuildDragonManager.Instance.end_time - BaseUtils.BASE_TIME) / (GuildDragonManager.Instance.end_time - GuildDragonManager.Instance.start_time)
        self.slider2.value = 1
        self.slider3.value = 0
        self.multiText.text = string.format(TI18N("第%s阶段：抢夺龙币×%s"), BaseUtils.NumToChn(1), GuildDragonEnum.Power[GuildDragonManager.Instance.state])
    elseif GuildDragonManager.Instance.state == GuildDragonEnum.State.Second then
        self.slider2.value = (GuildDragonManager.Instance.end_time - BaseUtils.BASE_TIME) / (GuildDragonManager.Instance.end_time - GuildDragonManager.Instance.start_time)
        self.slider3.value = 1
        self.slider1.value = 0
        self.multiText.text = string.format(TI18N("第%s阶段：抢夺龙币×%s"), BaseUtils.NumToChn(2), GuildDragonEnum.Power[GuildDragonManager.Instance.state])
    else
        self.slider3.value = (GuildDragonManager.Instance.boss_end_time - BaseUtils.BASE_TIME) / (GuildDragonManager.Instance.boss_end_time - GuildDragonManager.Instance.start_time)
        self.slider1.value = 0
        self.slider2.value = 0
        self.multiText.text = string.format(TI18N("第%s阶段：抢夺龙币×%s"), BaseUtils.NumToChn(3), GuildDragonEnum.Power[GuildDragonManager.Instance.state])
    end

    self.nameText.text = DataUnit.data_unit[32011].name
end

function GuildDragonMainUI:ShowText(text)
    self.text.text = text
    self.textBg.sizeDelta = Vector2(math.ceil(self.text.preferredWidth + 20), 30)
end

function GuildDragonMainUI:Disappear(frame)
    if self.alphaTimerId == nil then
        self.counter = frame
        self.alphaTimerId = LuaTimer.Add(0, 44, function()
            self.counter = self.counter - 1 self:SetAlpha(self.counter / frame)
            if self.counter == 0 then
                LuaTimer.Delete(self.alphaTimerId)
                self.alphaTimerId = nil
                self:Hiden()
            end
        end)
    end
end

function GuildDragonMainUI:SetAlpha(alpha)
    if self.renderers ~= nil then
        for _,renderer in pairs(self.renderers) do
            renderer:SetAlpha(alpha)
        end
    end
end

function GuildDragonMainUI:CheckFight(bool)
    if not self.counting then
        for _,rect in pairs(self.rects) do
            rect.gameObject:SetActive(not bool)
        end
    end
    -- self.iconLoader.gameObject:SetActive(false)
end

function GuildDragonMainUI:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.begin_fight, self.beginFightListener)
    EventMgr.Instance:RemoveListener(event_name.end_fight, self.endFightListener)
end

function GuildDragonMainUI:OnClickIcon()
    if GuildDragonManager.Instance.state == GuildDragonEnum.State.Ready then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>%s分钟</color>后可进入巨龙峡谷挑战巨龙"), math.ceil((GuildDragonManager.Instance.end_time - BaseUtils.BASE_TIME) / 60)))
    else
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guilddragon_main)
    end
end

function GuildDragonMainUI:CheckRod()
    if not GuildDragonManager.Instance:InDragonCD() or not GuildDragonManager.Instance:InLootCD() then
        if self.effect ~= nil then
            self.effect:SetActive(true)
        else
            self.effect = BaseUtils.ShowEffect(20273, self.iconLoader.gameObject.transform, Vector3(0.9, 0.9, 0.9), Vector3(0, 0, 0))
        end
    else
        if self.effect ~= nil then
            self.effect:SetActive(false)
        end
    end
end

function GuildDragonMainUI:CheckReadyEffect()
    if GuildDragonManager.Instance.state == GuildDragonEnum.State.Countdown then
        if BaseUtils.BASE_TIME - GuildDragonManager.Instance.start_time < 2 then
            self.counting = true
            if self.readyEffect ~= nil then
                self.readyEffect:SetActive(true)
            else
                self.readyEffect = BaseUtils.ShowEffect(20397, self.transform, Vector3.one, Vector3(0, 170, 0))
            end
            self.textBg.gameObject:SetActive(false)
            self.text.gameObject:SetActive(false)
        else
        end
    else
        self.counting = false
        if self.readyEffect ~= nil then
            self.readyEffect:SetActive(false)
        end
    end
end

function GuildDragonMainUI:OnBattle()
    self.battle.gameObject:SetActive((GuildDragonManager.Instance.state == GuildDragonEnum.State.First
        and BaseUtils.BASE_TIME - GuildDragonManager.Instance.start_time > 5)
        or GuildDragonManager.Instance.state == GuildDragonEnum.State.Second
        or GuildDragonManager.Instance.state == GuildDragonEnum.State.Third)
end

