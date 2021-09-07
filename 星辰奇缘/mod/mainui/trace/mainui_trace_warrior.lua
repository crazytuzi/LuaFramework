MainuiTraceWarrior = MainuiTraceWarrior or BaseClass(BaseTracePanel)

local GameObject = UnityEngine.GameObject

function MainuiTraceWarrior:__init(main)
    self.main = main
    self.isInit = true
    self.model = WarriorManager.Instance.model
    self.time = nil     -- 完整阶段剩余时间，从报名到退出

    self.state = nil

    self.phaseList = {
        self.PhaseNull
        , self.PhaseReady
        , self.PhaseBattle
        , self.PhaseSettle
        , self.PhaseReward
    }

    WarriorManager.Instance.callback = function(i)
        if SceneManager.Instance:CurrentMapId() == 51001 or SceneManager.Instance:CurrentMapId() == 51000 then
            self:HideAll()
            if self.model.phase > 1 then
                self:GoToPhase(self.model.phase - 1)
            else
                self:GoToPhase(1)
                self.model.warrior_magic_buff = nil
                self.model.warriors = nil
            end
        else
            self:GoToPhase(1)
            self.model.warrior_magic_buff = nil
            self.model.warriors = nil
        end
    end

    self.resList = {
        {file = AssetConfig.warrior_content, type = AssetType.Main}
    }

    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MainuiTraceWarrior:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MainuiTraceWarrior:__delete()

end

function MainuiTraceWarrior:OnShow()
    WarriorManager.Instance:send14200()
end

function MainuiTraceWarrior:OnHide()
end

function MainuiTraceWarrior:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.warrior_content))
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.transform:Find("Main/Container"))
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition3D = Vector2(0, -33, 0)

    self.groupNameText = self.transform:Find("Level/Text"):GetComponent(Text)
    local container = self.transform:Find("Container")
    self.bgRect = self.transform:Find("ImgBg"):GetComponent(RectTransform)
    self.zoneNameText = container:Find("ImgTitle/TxtDesc"):GetComponent(Text)
    self.eyeBtn = container:Find("Eye"):GetComponent(Button)
    self.noticeBtn = container:Find("Notice"):GetComponent(Button)
    self.groupObj = self.transform:Find("Level").gameObject
    self.zoneObj = container:Find("ImgTitle").gameObject
    self.toggle = self.bgRect.gameObject.transform:Find("Toggle"):GetComponent(Toggle)
    self.toggle:GetComponent(RectTransform).sizeDelta = Vector2(180, 30)
    self.toggleHeight = 35
    self.infoPanel = container:Find("Info").gameObject          -- 信息面板，包括神器拥有着，刷新倒计时，复活次数等
    self.rankPanel = container:Find("RankPanel").gameObject     -- 排名面板（前三名）
    self.readyPanel = container:Find("Ready").gameObject        -- 准备面板，准备倒计时
    self.resultPanel = container:Find("Result").gameObject      -- 胜利面板，退出倒计时
    self.settlePanel = container:Find("Settle").gameObject      -- 结算面板
    self.exit = self.transform:Find("ImgBg/Exit"):GetComponent(Button)
    self.show = self.transform:Find("ImgBg/Show"):GetComponent(Button)
    self.showRed = self.transform:Find("ImgBg/Show/NotifyPoint").gameObject
    self.icon = container:Find("ImgTitle/Icon"):GetComponent(Image)
    self.exit.onClick:RemoveAllListeners()
    self.exit.onClick:AddListener(function()
        WarriorManager.Instance:OnExit(2)
    end)

    local btn = self.rankPanel:GetComponent(Button)
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.warrior_window, {})
    end)

    self.toggle.onValueChanged:RemoveAllListeners()
    self.toggle.isOn = (WarriorManager.Instance.isHide == true)
    self.toggle.onValueChanged:AddListener(function (status)
        WarriorManager.Instance.isHide = (status == true)
        WarriorManager.Instance:HidePersons()
    end)
    self.isInit = true

    self.levelObj = self.transform:Find("Level").gameObject
    self.levelText = self.transform:Find("Level/Text"):GetComponent(Text)
    self.timerId = LuaTimer.Add(0, 1000, function() self:OnTick() end)
    self.eyeBtn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.warrior_desc_window) end)
    self.noticeBtn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.warrior_desc_window) end)
    self.readyPanel:GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.warrior_desc_window) end)
    self.show.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.warrior_desc_window) end)
    self.zoneObj:GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.warrior_desc_window) end)
end

function MainuiTraceWarrior:GoToPhase(i)
    self:HideAll()
    if self.isInit == true then
        self.phaseList[i](self)
    end
    if self.isInit == true then
        self.showRed:SetActive(WarriorManager.Instance:CheckRed())
    end
end

function MainuiTraceWarrior:HideAll()
    if self.isInit == true then
        self.infoPanel:SetActive(false)
        self.rankPanel:SetActive(false)
        self.readyPanel:SetActive(false)
        self.resultPanel:SetActive(false)
        self.settlePanel:SetActive(false)
    end
end

function MainuiTraceWarrior:PhaseNull()
    self.groupObj:SetActive(false)
end

function MainuiTraceWarrior:PhaseReady()
    self.readyPanel:SetActive(true)
    self.readyPanel:GetComponent(RectTransform).anchoredPosition = Vector2(0, 0)
    -- self.bgRect.localPosition = Vector2。zero
    self.zoneObj:SetActive(true)
    self.groupObj:SetActive(true)
    self.eyeBtn.gameObject:SetActive(true)
    self.noticeBtn.gameObject:SetActive(false)
    self.groupObj.transform:Find("Text"):GetComponent(Text).text = TI18N("勇士战场")
    self.toggle.gameObject:SetActive(false)
    self.icon.gameObject:SetActive(true)
    self.icon.sprite = self.main.assetWrapper:GetSprite(AssetConfig.teamquest, WarriorManager.Instance.model.modeRes[WarriorManager.Instance.model.mode] or WarriorManager.Instance.model.modeRes[1])

    local descText = self.readyPanel.transform:Find("Desc"):GetComponent(Text)
    descText.lineSpacing = 1.1
    descText.text = self.model.modeShortString[self.model.mode] or self.model.modeShortString[1]
    descText.transform.anchoredPosition = Vector2(0, -40)

    local rect = self.readyPanel.transform:Find("Time"):GetComponent(RectTransform)
    rect.anchoredPosition = Vector2(0, descText.transform.anchoredPosition.y - descText.preferredHeight - rect.sizeDelta.y / 2)
    self.exit.gameObject:SetActive(true)
    self.show.gameObject:SetActive(true)
    self.exit.transform.anchoredPosition = Vector2(57.99997, -22.34982)
    self.bgRect.sizeDelta = Vector2(226, math.ceil(descText.preferredHeight - descText.transform.anchoredPosition.y + 3) + self.toggleHeight + rect.sizeDelta.y)

    self:UpdateReady()
end

function MainuiTraceWarrior:UpdateReady()
    local t = self.readyPanel.transform
    local timeText = t:Find("Time"):GetComponent(Text)
    if self.model.restTime ~= nil then
        local m = nil
        local s = nil
        local h = nil
        local d = nil
        d,h,m,s = BaseUtils.time_gap_to_timer(self.model.restTime)
        if m < 10 then m = "0" .. m end
        if s < 10 then s = "0" .. s end
        timeText.text = string.format(TI18N("<color=#C7F9FF>战场开启倒计时</color> %s"), string.format("00:%s:%s", tostring(m), tostring(s)))
    else
        timeText.text = TI18N("<color=#C7F9FF>战场开启倒计时</color> --:--:--")
    end

    self.zoneNameText.text = self.model.titleString[self.model.mode] or self.model.titleString[1]
    self.icon.transform.anchoredPosition = Vector2(-50, 0)
    local descText = self.readyPanel.transform:Find("Desc"):GetComponent(Text)
    descText.lineSpacing = 1.1
    descText.text = self.model.modeShortString[self.model.mode] or self.model.modeShortString[1]
end

function MainuiTraceWarrior:UpdateInfo()
    local t = self.infoPanel.transform
    -- local swordNameText = t:Find("Sword/Name"):GetComponent(Text)
    local swordKeeperText = t:Find("Sword/KeeperName"):GetComponent(Text)
    -- local shieldNameText = t:Find("Sheild/Name"):GetComponent(Text)
    local shieldKeeperText = t:Find("Sheild/KeeperName"):GetComponent(Text)
    local groupImage = t:Find("Group/Image"):GetComponent(Image)
    local groupText = t:Find("Group/Name"):GetComponent(Text)
    local groupScore = t:Find("Group/Value"):GetComponent(Text)
    local rebornText = t:Find("Reborn/Value"):GetComponent(Text)
    local rebornObj = t:Find("Reborn").gameObject
    local dieObj = t:Find("Die").gameObject
    local watchBtn = t:Find("Die/Watch"):GetComponent(Button)

    local model = self.model
    -- print("<color=#0000FF>-------------------UpdateInfo------------------</color> "..tostring(model.revive))
    if model.revive == nil then
        rebornText.text = "--"
        rebornObj:SetActive(true)
        dieObj:SetActive(false)
    else
        if model.revive == 0 then
            watchBtn.onClick:RemoveAllListeners()
            watchBtn.onClick:AddListener(function () self:OnWatch() end)
            rebornText.text = "0"
            rebornObj:SetActive(true)
            dieObj:SetActive(true)
        else
            dieObj:SetActive(false)
            rebornText.text = tostring(model.revive - 1)
            rebornObj:SetActive(true)
        end
    end

    -- swordNameText.text =
    if self.model.mode == 1 then
        swordKeeperText.text = WarriorManager.Instance:GetSwordKeeperName()
    end
    shieldKeeperText.text = WarriorManager.Instance:GetShieldKeeperName()
end

function MainuiTraceWarrior:OnWatch()
    WarriorManager.Instance:send14210()
end

function MainuiTraceWarrior:PhaseBattle()
    self.eyeBtn.gameObject:SetActive(false)
    self.noticeBtn.gameObject:SetActive(true)
    self.groupObj:SetActive(true)
    self.infoPanel:SetActive(true)
    self.rankPanel:SetActive(true)
    self.groupObj:SetActive(true)
    self.toggle.gameObject:SetActive(true)
    self.groupObj.transform:Find("Text"):GetComponent(Text).text = TI18N("勇士战场")
    self.zoneObj:SetActive(true)
    self.exit.gameObject:SetActive(true)
    self.show.gameObject:SetActive(true)
    self.exit.transform.anchoredPosition = Vector2(57.99997, -22.34982)
    self.icon.gameObject:SetActive(true)
    self.icon.sprite = self.main.assetWrapper:GetSprite(AssetConfig.teamquest, WarriorManager.Instance.model.modeRes[WarriorManager.Instance.model.mode] or WarriorManager.Instance.model.modeRes[1])
    local campMsg = ""
    if self.model.camp == 1 then
        campMsg = TI18N("[青龙]")
    elseif self.model.camp == 2 then
        campMsg = TI18N("[白虎]")
    end
    self.zoneNameText.text = string.format("%s %s", self.model.titleString[self.model.mode] or self.model.titleString[1], campMsg)
    self.icon.transform.anchoredPosition = Vector2(-85, 0)

    local btn = self.infoPanel:GetComponent(Button)
    if btn == nil then
        btn = self.infoPanel.gameObject:AddComponent(Button)
    end
    btn.onClick:RemoveAllListeners()
    if self.model.mode == 1 then
        btn.onClick:AddListener(function()
            local desc = {TI18N("1.圣剑可增强攻击、定时获得功勋")
            , TI18N("2.战斗胜利可夺取对方的圣剑")}
            TipsManager.Instance:ShowText({gameObject = self.infoPanel.gameObject, itemData = desc})
        end)
        self.infoPanel.transform:Find("Sword").gameObject:SetActive(true)
        self.infoPanel.transform:Find("Reborn").anchoredPosition = Vector2(0, -32.3)
        self.bgRect.sizeDelta = Vector2(226, 225 + self.toggleHeight)
        self.rankPanel.transform.anchoredPosition = Vector2(0, -88.3)
    else
        self.infoPanel.transform:Find("Sword").gameObject:SetActive(false)
        self.infoPanel.transform:Find("Reborn").anchoredPosition = Vector2(0, 0)
        self.bgRect.sizeDelta = Vector2(226, 210 + self.toggleHeight)
        self.rankPanel.transform.anchoredPosition = Vector2(0, -62.3)
    end

    self:UpdateTitle()
    self:UpdateInfo()
    self:UpdateTop3()
end

function MainuiTraceWarrior:PhaseSettle()
    local panel = self.settlePanel.transform
    self.groupObj:SetActive(true)
    self.settlePanel:SetActive(true)
    self.zoneObj:SetActive(true)
    self.eyeBtn.gameObject:SetActive(false)
    self.noticeBtn.gameObject:SetActive(true)
    self.toggle.gameObject:SetActive(true)
    self.exit.gameObject:SetActive(true)
    self.show.gameObject:SetActive(false)
    self.exit.transform.anchoredPosition = Vector2(0, -22.34982)
    self.icon.sprite = self.main.assetWrapper:GetSprite(AssetConfig.teamquest, WarriorManager.Instance.model.modeRes[WarriorManager.Instance.model.mode] or WarriorManager.Instance.model.modeRes[1])
    local campMsg = ""
    if self.model.camp == 1 then
        campMsg = TI18N("[青龙]")
    elseif self.model.camp == 2 then
        campMsg = TI18N("[白虎]")
    end
    if self.model.mode > 0 then
        self.zoneNameText.text = string.format("%s %s", self.model.titleString[self.model.mode] or self.model.titleString[1], campMsg)
    else
        self.zoneNameText.text = TI18N("结算阶段")
    end
    self.icon.transform.anchoredPosition = Vector2(-70, 0)
    self.icon.gameObject:SetActive(false)
    self.noticeBtn.gameObject:SetActive(false)
    self.groupObj:SetActive(true)
    self.groupObj.transform:Find("Text"):GetComponent(Text).text = TI18N("勇士战场")
    self.rankPanel:SetActive(false)
    self.bgRect.sizeDelta = Vector2(226, 120 + self.toggleHeight)
    panel:Find("Time").gameObject:SetActive(true)
    panel:Find("Time"):GetComponent(Text).text = TI18N("胜利宝箱<color='#FFFF00'>2分钟</color>后掉落")

    self:UpdateTitle()
    self:UpdateSettle()
end

function MainuiTraceWarrior:PhaseReward()
    self.groupObj:SetActive(true)
    self.resultPanel:SetActive(true)
    self.groupObj:SetActive(true)
    self.toggle.gameObject:SetActive(true)
    self.exit.gameObject:SetActive(true)
    self.show.gameObject:SetActive(false)
    self.exit.transform.anchoredPosition = Vector2(0, -22.34982)
    self.eyeBtn.gameObject:SetActive(false)
    self.noticeBtn.gameObject:SetActive(false)
    self.icon.gameObject:SetActive(false)
    self.groupObj.transform:Find("Text"):GetComponent(Text).text = TI18N("勇士战场")
    -- self.icon.sprite = self.main.assetWrapper:GetSprite(AssetConfig.teamquest, WarriorManager.Instance.model.modeRes[WarriorManager.Instance.model.mode] or WarriorManager.Instance.model.modeRes[1])
    self.zoneObj:SetActive(true)
    local campMsg = ""
    if self.model.camp == 1 then
        campMsg = TI18N("[青龙]")
    elseif self.model.camp == 2 then
        campMsg = TI18N("[白虎]")
    end
    if self.model.mode > 0 then
        self.zoneNameText.text = string.format("%s %s", self.model.titleString[self.model.mode] or self.model.titleString[1], campMsg)
    else
        self.zoneNameText.text = TI18N("宝箱奖励")
    end

    self.icon.transform.anchoredPosition = Vector2(-70, 0)
    self.bgRect.sizeDelta = Vector2(226, 110 + self.toggleHeight)

    self:UpdateReward()
    -- self:UpdateTitle()
end

function MainuiTraceWarrior:UpdateTop3()
    local panel = self.rankPanel.transform
    local model = self.model
    local rank = TI18N("榜外")
    local score = "--"
    if model.rank ~= nil and model.rank > 0 then
        rank = model.rank
    end
    if model.score ~= nil and model.score > 0 then
        score = model.score
    end
    local scoreText = panel:Find("Text"):GetComponent(Text)
    -- scoreText.color = Color(1, 1, 1)
    scoreText.text = string.format(TI18N("我的功勋:<color=#fff000>%s</color> 排名:<color=#fff000>%s</color>"), tostring(score), tostring(rank))

    if model.warriors == nil then
        model.warriors = {}
    end

    table.sort(model.warriors, function (a, b)
        if a.score == b.score then
            if a.kill == b.kill then
                return a.revive > b.revive
            else
                return a.kill > b.kill
            end
        else
            return a.score > b.score
        end
    end)

    for i=1,3 do
        local item = panel:Find("Item"..i)
        local groupImage = item:Find("Group"):GetComponent(Image)
        local rankText = item:Find("Rank"):GetComponent(Text)
        local nameText = item:Find("Name"):GetComponent(Text)
        -- local jobImage = item:Find("Job"):GetComponent(Image)
        local scoreText = item:Find("Score"):GetComponent(Text)

        item.gameObject:SetActive(true)
        if model.warriors[i] ~= nil then
            -- rankText.text = tostring(model.warriors[i].rank)
            nameText.text = model.warriors[i].name
            scoreText.text = tostring(model.warriors[i].score)
            -- print("阵营.."..model.warriors[i].camp)
            groupImage.gameObject:SetActive(true)
            groupImage.sprite = self.main.assetWrapper:GetSprite(AssetConfig.teamquest, "Group"..model.warriors[i].camp)
        else
            -- rankText.text = ""
            scoreText.text = "0"
            nameText.text = TI18N("虚位以待")
            groupImage.gameObject:SetActive(false)
        end
        -- print(self.main.assetWrapper)
    end
end

function MainuiTraceWarrior:UpdateReward()
    local panel = self.resultPanel.transform
    local timeText = panel:Find("Time"):GetComponent(Text)
    local restText = panel:Find("Rest"):GetComponent(Text)
    local titleText = panel:Find("Title"):GetComponent(Text)

    titleText.gameObject:SetActive(false)
    if self.model.group_id ~= nil then
        self.zoneNameText.text = string.format(TI18N("%s宝箱奖励"), DataWarrior.data_group[self.model.group_id].name)
    else
        self.zoneNameText.text = TI18N("宝箱奖励")
    end
    if self.model.rewardNum ~= nil then
        restText.text = TI18N("赶快领取胜利宝箱吧")
    end
    timeText.text = os.date("00:%M:%S", self.model.restTime)
    timeText.transform.anchoredPosition = Vector2(0, 30)
    restText.transform.anchoredPosition = Vector2(0, 2)
end

function MainuiTraceWarrior:UpdateSettle()
    local panel = self.settlePanel.transform
    local campText = panel:Find("Group"):GetComponent(Text)
    local campImage = panel:Find("Image"):GetComponent(Image)
    local vicImage = panel:Find("Vic"):GetComponent(Image)

    if self.model.group_id ~= nil then
        -- titleText.text = DataWarrior.data_group[self.model.group_id].name..TI18N("结算阶段")
    end

    local camp = "1"
    if self.model.score1 > self.model.score2 then
        camp = "1"
    elseif self.model.score1 < self.model.score2 then
        camp = "2"
    end

    if camp == "1" then
        campText.text = TI18N("青龙阵营")
    else
        campText.text = TI18N("白虎阵营")
    end
    campImage.sprite = self.main.assetWrapper:GetSprite(AssetConfig.teamquest, "Group"..camp)
    vicImage.sprite = self.main.assetWrapper:GetSprite(AssetConfig.teamquest, "I18NVictory")
end

function MainuiTraceWarrior:OnTick()
    if SceneManager.Instance:CurrentMapId() == 51000 then
        if self.model.phase == 3 then
            self:UpdateReady()
        end
    elseif SceneManager.Instance:CurrentMapId() == 51001 then
        if self.model.phase == 4 then
            self:UpdateInfo()
            self:UpdateTop3()
            self:UpdateTitle()
        elseif self.model.phase == 5 then
            self:UpdateSettle()
            self:UpdateTop3()
        elseif self.model.phase == 6 then
            self:UpdateReward()
        end
    end
end

function MainuiTraceWarrior:UpdateTitle()
    if self.model.group_id ~= nil then
        self.groupNameText.text = DataWarrior.data_group[self.model.group_id].name
    else
        self.groupNameText.text = ""
    end
    local campMsg = ""
    if self.model.camp == 1 then
        campMsg = TI18N("[青龙]")
    elseif self.model.camp == 2 then
        campMsg = TI18N("[白虎]")
    end
    self.zoneNameText.text = string.format("%s %s", self.model.titleString[self.model.mode] or self.model.titleString[1], campMsg)
    self.icon.transform.anchoredPosition = Vector2(-85, 0)
end
