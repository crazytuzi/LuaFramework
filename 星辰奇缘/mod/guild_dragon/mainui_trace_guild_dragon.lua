MainuiTraceGuildDragon = MainuiTraceGuildDragon or BaseClass(BaseTracePanel)

function MainuiTraceGuildDragon:__init(main)
    self.main = main

    self.resList = {
        {file = AssetConfig.guilddragon_content, type = AssetType.Main},
        {file = AssetConfig.guilddragon_textures, type = AssetType.Dep},
        {file = AssetConfig.rank_textures, type = AssetType.Dep},
        {file = AssetConfig.combat_texture, type = AssetType.Dep},
        {file = AssetConfig.combat2_texture, type = AssetType.Dep},
    }

    self.isOnToggle = false
    self.rankListener = function() self:OnRank() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MainuiTraceGuildDragon:__delete()
    self.OnHideEvent:Fire()
    if self.titleLoader ~= nil then
        self.titleLoader:DeleteMe()
        self.titleLoader = nil
    end
    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end
    if self.fireEffect ~= nil then
        self.fireEffect:DeleteMe()
        self.fireEffect = nil
    end
    self.main = nil
end

function MainuiTraceGuildDragon:RemoveListeners()
    GuildDragonManager.Instance.updateRankEvent:RemoveListener(self.rankListener)
    GuildDragonManager.Instance.stateEvent:RemoveListener(self.rankListener)
end

function MainuiTraceGuildDragon:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guilddragon_content))
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.transform:Find("Main/Container"))
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition3D = Vector3(0, -40, 0)

    local panel = self.transform:Find("Panel")
    local battle = panel:Find("Battle")
    local ready = panel:Find("Ready")

    self.battle = battle
    self.ready = ready
    self.panel = panel

    self.nameText = battle:Find("NameText"):GetComponent(Text)
    self.rankButton = panel:Find("Rank"):GetComponent(Button)
    self.exitButton = panel:Find("ExitButton"):GetComponent(Button)
    self.taskImage = battle:Find("Task"):GetComponent(Image)
    self.slider = battle:Find("Slider"):GetComponent(Slider)
    self.sliderText = battle:Find("Slider/ProgressTxt"):GetComponent(Text)
    self.toggleBtn = battle:Find("Toggle"):GetComponent(Button)
    self.toggleTickObj = battle:Find("Toggle/Bg/Tick").gameObject

    local rank = battle:Find("Rank")
    self.rankList = {}
    for i=1,3 do
        local tab = {}
        local trans = rank:GetChild(i)
        tab.image = trans:GetComponent(Image)
        tab.nameText = trans:Find("Name"):GetComponent(Text)
        tab.scoreText = trans:Find("Score"):GetComponent(Text)
        self.rankList[i] = tab
    end

    self.titleLoader = SingleIconLoader.New(rank:Find("Title/Score").gameObject)
    self.titleLoader:SetSprite(SingleIconType.Item, 90054)

    self.myRankObj = rank:Find("My").gameObject
    self.myNameText = self.myRankObj.transform:Find("Name"):GetComponent(Text)
    self.myIndexText = self.myRankObj.transform:Find("Index"):GetComponent(Text)
    self.myScoreText = self.myRankObj.transform:Find("Score"):GetComponent(Text)

    self.battleTimeObj = battle:Find("Time").gameObject
    self.battleTimeDescText = battle:Find("Time/I18N"):GetComponent(Text)
    self.battleTimeText = battle:Find("Time/Text"):GetComponent(Text)

    self.readyTimeObj = ready:Find("Time").gameObject
    self.readyTimeDescText = ready:Find("Time/I18N"):GetComponent(Text)
    self.readyTimeText = ready:Find("Time/Text"):GetComponent(Text)

    self.descExt = MsgItemExt.New(ready:Find("DescText"):GetComponent(Text), 195, 15, 20.52)

    self.damakuBtn = battle:Find("Damaku"):GetComponent(Button)
    self.nodamakuBtn = battle:Find("NoDamaku"):GetComponent(Button)
    -- self.closeDamakuObj = self.transform:Find("CloseDamaku").gameObject

    self.descExt:SetData(TI18N(
        [[1.每次<color='#ffff00'>挑战巨龙</color>可获得龙币
2.可掠夺<color='#ffff00'>其他公会玩家</color>的龙币
3.巨龙龙威极强挑战后需<color='#ffff00'>3分钟</color>恢复体力
4.巨龙血量越低<color='#ffff00'>抢夺龙币</color>越多
5.最后根据<color='#ffff00'>公会龙币</color>发放宝物奖励，奖励将存入公会拍卖行]]
        ))


    self.rankButton.onClick:AddListener(function() self:OnRankWindow() end)
    self.exitButton.onClick:AddListener(function() GuildDragonManager.Instance:Exit() end)

    self.fireEffect = BaseUtils.ShowEffect(20338, battle:Find("Head"), Vector3.one, Vector3(0, 0, -400))
    self.slider.gameObject:SetActive(false)
    self.battleTimeObj:SetActive(true)
    self.readyTimeObj:SetActive(true)

    self.button = self.transform:Find("Panel"):GetComponent(Button)
    self.button.onClick:AddListener(function() GuildDragonManager.Instance:Challenge() end)

    self.toggleTickObj:SetActive(false)
    self.toggleBtn.onClick:AddListener(function() self:OnToggle() end)
    self.nodamakuBtn.onClick:AddListener(function() self:ShowCloseDamaku() end)
    self.damakuBtn.onClick:AddListener(function() self:OpenDamaku() end)
end

function MainuiTraceGuildDragon:OnRankWindow()
    if GuildDragonManager.Instance.state == GuildDragonEnum.State.Ready then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>%s分钟</color>后可进入巨龙峡谷挑战巨龙"), math.ceil((GuildDragonManager.Instance.end_time - BaseUtils.BASE_TIME) / 60)))
    else
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guilddragon_main)
    end
end

function MainuiTraceGuildDragon:OnInitCompleted()
    self.OnOpenEvent:Fire()

    SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(false)
    self.isOnToggle = false
    self.toggleTickObj:SetActive(false)
end

function MainuiTraceGuildDragon:OnOpen()
    self:RemoveListeners()
    GuildDragonManager.Instance.updateRankEvent:AddListener(self.rankListener)
    GuildDragonManager.Instance.stateEvent:AddListener(self.rankListener)

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 200, function() self:UpdateStatus() end)
    end
    if self.rankTimerId == nil then
        self.rankTimerId = LuaTimer.Add(0, 30 * 1000, function() GuildDragonManager.Instance:send20502(1, 3) end)
    end
    self:OnRank()
end


function MainuiTraceGuildDragon:OnHide()
    self:RemoveListeners()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function MainuiTraceGuildDragon:UpdateStatus()
    if GuildDragonManager.Instance.state == GuildDragonEnum.State.Ready then
        self.readyTimeDescText.text = TI18N("开始倒计时")
        self.readyTimeText.text = BaseUtils.formate_time_gap(GuildDragonManager.Instance:GetRestTime(), ":", 0, BaseUtils.time_formate.MIN)
        self.ready.gameObject:SetActive(true)
        self.battle.gameObject:SetActive(false)
    elseif GuildDragonManager.Instance.state == GuildDragonEnum.State.Reward then
        self.battleTimeDescText.text = TI18N("退出倒计时")
        self.battleTimeText.text = BaseUtils.formate_time_gap(GuildDragonManager.Instance:GetRestTime(), ":", 0, BaseUtils.time_formate.MIN)
        self.ready.gameObject:SetActive(false)
        self.battle.gameObject:SetActive(true)
    else
        self.battleTimeDescText.text = TI18N("活动倒计时")
        self.battleTimeText.text = BaseUtils.formate_time_gap(GuildDragonManager.Instance:GetRestTime(), ":", 0, BaseUtils.time_formate.MIN)
        self.ready.gameObject:SetActive(false)
        self.battle.gameObject:SetActive(true)
    end
    -- self.nameText.text = DataUnit.data_unit[32011].name

    if GuildDragonManager.Instance:InDragonCD() then
        self.nameText.text = string.format(TI18N("<color='#ffff00'>%s</color>后可挑战巨龙"), BaseUtils.formate_time_gap(GuildDragonManager.Instance.model.myData.challenge_time - BaseUtils.BASE_TIME, ":", 1, BaseUtils.time_formate.MIN))
    else
        self.nameText.text = TI18N("当前可<color='#ffff00'>挑战巨龙</color>")
    end
end

function MainuiTraceGuildDragon:OnJump()
    GuildDragonManager.Instance:GotoJumpArea()
end

function MainuiTraceGuildDragon:OnToggle()
    self.isOnToggle = not self.isOnToggle
    self.toggleTickObj:SetActive(self.isOnToggle)
    SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(self.isOnToggle)
end

function MainuiTraceGuildDragon:ShowCloseDamaku()
    GuildDragonManager.Instance.model:OpenDamakuSetting()
end

function MainuiTraceGuildDragon:OpenDamaku()
    if GuildDragonManager.Instance.model.myData.barrage_time > BaseUtils.BASE_TIME then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("刚刚发送弹幕完毕，<color=#00ff00>%s秒</color>后可发言"), GuildDragonManager.Instance.model.myData.barrage_time - BaseUtils.BASE_TIME))
    else
        self.damakuCallback = self.damakuCallback or function(msg)
            GuildDragonManager.Instance:send20514(msg)
        end
        DanmakuManager.Instance.model:OpenPanel({sendCall = self.damakuCallback})
    end
end

function MainuiTraceGuildDragon:OnRank()
    if GuildDragonManager.Instance.state == GuildDragonEnum.State.Ready then
        self.transform.anchoredPosition3D = Vector3(0, -40, 0)
        self.panel.sizeDelta = Vector2(230, 250)
        return
    end

    local inTop3 = nil
    local index = 0
    local list = GuildDragonManager.Instance.model.rank_list[1] or {}
    local roleData = RoleManager.Instance.RoleData

    local list = {}
    for i=1,3 do
        table.insert(list, (GuildDragonManager.Instance.model.rank_list[1] or {})[i])
    end

    for i=1,100 do
        local data = (GuildDragonManager.Instance.model.rank_list[1] or {})[i]
        if data == nil then
            break
        elseif data.id == roleData.id and data.platform == roleData.platform and data.zone_id == roleData.zone_id then
            if i <= 3 then inTop3 = true end
            index = i
            break
        end
    end

    if not inTop3 then
        local myPoint = (GuildDragonManager.Instance.model.myData or {}).point or 0
        for i=1,#list do
            if myPoint > list[i].point then
                table.insert(list, i, {
                    id = roleData.id,
                    platform = roleData.platform,
                    zone_id = roleData.zone_id,
                    point = myPoint,
                    classes = roleData.classes,
                    sex = roleData.sex,
                    target_name = roleData.name,
                })
                inTop3 = true
                break
            end
        end
    end

    for i=1,3 do
        self.rankList[i].image.enabled = false
        if list[i] ~= nil then
            self.rankList[i].nameText.text = list[i].target_name
            self.rankList[i].scoreText.text = list[i].point
        else
            self.rankList[i].nameText.text = TI18N("虚位以待")
            self.rankList[i].scoreText.text = "---"
        end
    end

    self.myRankObj:SetActive(not inTop3)
    self.transform.anchoredPosition3D = Vector3(0, -25, 0)
    if inTop3 then
        self.panel.sizeDelta = Vector2(230, 260)
    else
        self.myNameText.text = roleData.name
        if index == 0 then
            self.myIndexText.text  = TI18N("未上榜")
        else
            self.myIndexText.text  = index
        end
        self.myScoreText.text = (GuildDragonManager.Instance.model.myData or {}).point or 0
        self.panel.sizeDelta = Vector2(230, 290)
    end
end
