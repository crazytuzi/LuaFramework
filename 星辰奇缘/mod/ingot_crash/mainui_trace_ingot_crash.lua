-- @author 黄耀聪
-- @date 2017年6月19日, 星期一

MainuiTraceIngotCrash = MainuiTraceIngotCrash or BaseClass(BaseTracePanel)

function MainuiTraceIngotCrash:__init(main)
    self.main = main
    self.name = "MainuiTraceIngotCrash"

    self.resList = {
        {file = AssetConfig.ingotcrash_content, type = AssetType.Main},
        {file = AssetConfig.ingotcrash_textures, type = AssetType.Dep},
    }

    self.updateListener = function() self:ChangePhase(IngotCrashManager.Instance.phase) end

    self.ruleDescString = TI18N([[1.活动开始后将进行单人对决
<color='#00ff00'>资格赛</color>获胜将获得大量{assets_2,90026}
2.资格赛排名前列的勇者将晋级<color='#00ff00'>淘汰赛</color>，争夺<color='#00ff00'>冠军</color>荣耀以及大量{assets_2,90026}奖励]])

    self.battleItemList = {}

    self.gameObject = nil
    self.isInit = false

    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:Hiden() end)
end

function MainuiTraceIngotCrash:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.ingotcrash_content))
    self.gameObject.name = self.name

    self.transform = self.gameObject.transform

    local transform = self.transform
    transform:SetParent(self.main.mainObj.transform)
    transform.localScale = Vector3.one
    transform.anchoredPosition = Vector2(0, -43)

    self.content = transform:Find("Content")

    local buttonArea = transform:Find("ButtonArea")
    self.rankButton = buttonArea:Find("Rank"):GetComponent(Button)
    self.exitButton = buttonArea:Find("Exit"):GetComponent(Button)
    self.rewardButton = buttonArea:Find("Reward"):GetComponent(Button)
    self.rankButtonText = self.rankButton.transform:Find("Text"):GetComponent(Text)
    self.rewardIconloader = SingleIconLoader.New(buttonArea:Find("Reward/Image").gameObject)

    self.infoObj = transform:Find("Content/Info").gameObject
    self.descText = transform:Find("Content/Info/Desc"):GetComponent(Text)
    self.clockImage = transform:Find("Content/Info/Clock"):GetComponent(Image)
    self.timeText = transform:Find("Content/Info/Time"):GetComponent(Text)
    self.text1 = transform:Find("Content/Info/Text1"):GetComponent(Text)

    self.readyContent = transform:Find("Content/Ready")
    self.readyExt = MsgItemExt.New(self.readyContent:Find("Text"):GetComponent(Text), 210, 16, 18.53)

    self.battleContent = transform:Find("Content/Battle")
    self.battleNotice = self.battleContent:Find("Notice")
    self.battleNoticeExt = MsgItemExt.New(self.battleNotice:Find("Text"):GetComponent(Text), 170, 17, 19.684)
    self.battleItem = self.battleContent:Find("Item").gameObject

    self.battleLayout = LuaBoxLayout.New(self.battleContent, {axis = BoxLayoutAxis.Y, cspacing = 0, border = 0})

    self.battleItem:SetActive(false)

    self.rankButton.onClick:AddListener(function() self:OnRank() end)
    self.exitButton.onClick:AddListener(function() IngotCrashManager.Instance:OnExit() end)
    self.rewardButton.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ingot_crash_reward) end)

    transform:Find("Content/Title/Text"):GetComponent(Text).text = IngotCrashManager.Instance.activityName
    transform:Find("Content"):GetComponent(Button).onClick:AddListener(function() self:OnRules() end)

    self.rewardIconloader:SetSprite(SingleIconType.Item, 90026)
end

function MainuiTraceIngotCrash:OnRules()
    TipsManager.Instance:ShowRules({gameObject = self.content.gameObject, title = TI18N("活动规则"), text = TI18N([[1.<color='#ffff00'>预选赛</color><color='#00ff00'>20:05</color>开启，按积分排名32强晋级淘汰赛
2.<color='#ffff00'>淘汰赛</color><color='#00ff00'>20:16</color>开启，每获胜1次即可晋级下一轮
3.联赛冠军将获得无上荣耀以及累计<color='#ffff00'>1500钻石</color>奖励
4.从16进8比赛开始，所有玩家可下注赢取钻石奖励]]), width = 500})
end

function MainuiTraceIngotCrash:OnRank()
    if IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Kickout or IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Champion or IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Guess or IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Close then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ingot_crash_content)
    else
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ingot_crash_rank)
    end
end

function MainuiTraceIngotCrash:__delete()
    if self.battleLayout ~= nil then
        self.battleLayout:DeleteMe()
        self.battleLayout = nil
    end
    if self.readyExt ~= nil then
        self.readyExt:DeleteMe()
        self.readyExt = nil
    end
    if self.rewardIconloader ~= nil then
        self.rewardIconloader:DeleteMe()
        self.rewardIconloader = nil
    end
end

function MainuiTraceIngotCrash:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MainuiTraceIngotCrash:OnShow()
    self:RemoveListeners()
    IngotCrashManager.Instance.onUpdateInfo:AddListener(self.updateListener)

    self.gameObject:SetActive(true)
    self:ChangePhase(IngotCrashManager.Instance.phase)

    if self.timerId2 == nil then
        self.timerId2 = LuaTimer.Add(0, 10 * 1000, function() IngotCrashManager.Instance:send20007() end)
    end
end

function MainuiTraceIngotCrash:Hiden()
    self:RemoveListeners()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    if self.timerId2 ~= nil then
        LuaTimer.Delete(self.timerId2)
        self.timerId2 = nil
    end
end

function MainuiTraceIngotCrash:Init()
end

function MainuiTraceIngotCrash:RemoveListeners()
    IngotCrashManager.Instance.onUpdateInfo:RemoveListener(self.updateListener)
end

function MainuiTraceIngotCrash:ChangePhase(phase)
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    self.readyContent.gameObject:SetActive(false)
    self.battleContent.gameObject:SetActive(false)

    if phase == IngotCrashEumn.Phase.Ready then
        self:PhaseReady()
    elseif phase == IngotCrashEumn.Phase.Qualifier then
        self:PhaseQualifier()
    elseif phase == IngotCrashEumn.Phase.Kickout or phase == IngotCrashEumn.Phase.Guess then
        self:PhaseKickout()
    elseif phase == IngotCrashEumn.Phase.Close then
        self:PhaseClose()
    end
end

function MainuiTraceIngotCrash:PhaseClose()
    self.readyContent.gameObject:SetActive(true)
    self.descText.text = TI18N("淘汰赛决赛\n已结束")
    self.readyExt:SetData(TI18N("钻石联赛圆满结束\n请有序离开赛场"))

    local parentWidth = self.readyExt.contentTrans.parent.rect.width
    local size = self.readyExt.contentTrans.sizeDelta
    self.readyExt.contentTrans.anchoredPosition = Vector2(parentWidth / 2 - size.x / 2, 0)

    self.text1.text = ""
    self.timeText.text = ""
    self.clockImage.gameObject:SetActive(false)
    self.rankButton.gameObject:SetActive(true)
    self.exitButton.transform.anchoredPosition = Vector2(58, 0)
end

-- 准备阶段
function MainuiTraceIngotCrash:PhaseReady()
    self.readyContent.gameObject:SetActive(true)
    self.descText.text = TI18N("准备阶段")
    self.text1.text = TI18N("活动即将开始")
    self.clockImage.gameObject:SetActive(true)

    self.text1.transform.anchoredPosition = Vector2(-92,3)
    self.clockImage.transform.anchoredPosition = Vector2(22,-12)
    self.timeText.transform.anchoredPosition = Vector2(38, 3)

    self.readyExt:SetData(self.ruleDescString)
    self.rankButtonText.text = TI18N("排行榜")

    local parentWidth = self.readyExt.contentTrans.parent.rect.width
    local size = self.readyExt.contentTrans.sizeDelta
    self.readyExt.contentTrans.anchoredPosition = Vector2(parentWidth / 2 - size.x / 2, 0)

    self.timerId = LuaTimer.Add(0, 50, function() self:OnTime() end)

    self.rankButton.gameObject:SetActive(false)
    self.rewardButton.gameObject:SetActive(true)
    -- self.exitButton.transform.anchoredPosition = Vector2(0, 0)
end

-- 资格赛阶段
function MainuiTraceIngotCrash:PhaseQualifier()
    local num = (IngotCrashManager.Instance.model.personData.win or 0) + (IngotCrashManager.Instance.model.personData.lose or 0) + 1
    if num == 4 then
        self.text1.text = TI18N("下一场")
        num = 3
    else
        if CombatManager.Instance.isFighting then
            self.text1.text = TI18N("战斗中")
        else
            self.text1.text = TI18N("匹配中")
        end
    end
    self.descText.text = string.format(TI18N("%s-资格赛第%s轮"), DataGoldLeague.data_group[IngotCrashManager.Instance.group_id].name, num)

    self.text1.transform.anchoredPosition = Vector2(-114,3)
    self.clockImage.transform.anchoredPosition = Vector2(2,-12)
    self.timeText.transform.anchoredPosition = Vector2(16, 3)

    for _,v in pairs(self.battleItemList) do
        if v ~= nil then
            v.gameObject:SetActive(false)
        end
    end

    self.layoutIndex = 0
    self.battleLayout:ReSet()

    self:AddBattleItem(TI18N("当前战绩:"), string.format(TI18N("%s战%s胜"), (IngotCrashManager.Instance.model.personData.win or 0) + (IngotCrashManager.Instance.model.personData.lose or 0), (IngotCrashManager.Instance.model.personData.win or 0)))
    if IngotCrashManager.Instance.model.personData.rank == nil or IngotCrashManager.Instance.model.personData.rank == 0 then
        self:AddBattleItem(TI18N("我的排名:"), TI18N("未上榜"))
    else
        self:AddBattleItem(TI18N("我的排名:"), string.format(TI18N("第%s名"), IngotCrashManager.Instance.model.personData.rank or 1))
    end

    local rewardData = DataGoldLeague.data_battle_reward[string.format("%s_1", IngotCrashManager.Instance:CurrentType())]
    self:AddBattleItem(TI18N("本轮获胜奖励:"), string.format(TI18N("{assets_2, %s}%s"), rewardData.base_id, rewardData.num))

    if IngotCrashManager.Instance.model.personData.reward ~= nil and IngotCrashManager.Instance.model.personData.reward[1] ~= nil then
        self:AddBattleItem(TI18N("已累计奖励:"), string.format(TI18N("{assets_2, %s}%s"), IngotCrashManager.Instance.model.personData.reward[1].assets, IngotCrashManager.Instance.model.personData.reward[1].val))
    end

    self.battleNoticeExt:SetData(string.format(TI18N("<color='#ffff00'>前%s名</color>晋级淘汰赛"), IngotCrashManager.Instance.model.canUpgradeNum or 32))
    self.battleNotice.sizeDelta = Vector2(200, self.battleNoticeExt.contentTrans.sizeDelta.y)
    self.battleLayout:AddCell(self.battleNotice.gameObject)
    self.rankButtonText.text = TI18N("排行榜")

    self.timerId = LuaTimer.Add(0, 50, function() self:OnTime() end)
    self.battleContent.gameObject:SetActive(true)

    self.rankButton.gameObject:SetActive(true)
    self.rewardButton.gameObject:SetActive(false)
end

-- 16强赛阶段
function MainuiTraceIngotCrash:PhaseKickout()
    self.battleContent.gameObject:SetActive(true)

    local loss_num = 16 - (IngotCrashManager.Instance.num or 16)

    local str = ""
    if IngotCrashManager.Instance.max_round - IngotCrashManager.Instance.now_round < 4 then
        if loss_num >= 14 then
            local roleData = RoleManager.Instance.RoleData
            local isThird = false
            for _,player in pairs(IngotCrashManager.Instance.model.base16Tab or {}) do
                if player.rid == roleData.id and player.platform == roleData.platform and player.zone_id == roleData.zone_id then
                    if player.loss_round == IngotCrashManager.Instance.max_round - 1 then
                        isThird = true
                    end
                    break
                end
            end
            if isThird then
                self.descText.text = TI18N("第三名决赛")
                str = TI18N("夺得季军")
            else
                self.descText.text = TI18N("淘汰赛决赛")
                str = TI18N("夺得冠军")
            end
        elseif loss_num >= 12 then
            self.descText.text = TI18N("淘汰赛半决赛")
            str = TI18N("晋级决赛")
        elseif loss_num >= 8 then
            self.descText.text = TI18N("淘汰赛8进4")
            str = TI18N("晋级4强")
        else
            self.descText.text = TI18N("淘汰赛16进8")
            str = TI18N("晋级8强")
        end
        self.text1.text = TI18N("下一场")
    else
        self.descText.text = string.format(TI18N("%s-淘汰赛进行中"), DataGoldLeague.data_group[IngotCrashManager.Instance.group_id].name)
        self.text1.text = TI18N("下一轮")
        if IngotCrashManager.Instance.max_round - IngotCrashManager.Instance.now_round == 4 then
            str = TI18N("晋级16强")
        elseif IngotCrashManager.Instance.max_round - IngotCrashManager.Instance.now_round == 5 then
            str = TI18N("晋级32强")
        elseif IngotCrashManager.Instance.max_round - IngotCrashManager.Instance.now_round == 6 then
            str = TI18N("晋级64强")
        elseif IngotCrashManager.Instance.max_round - IngotCrashManager.Instance.now_round == 7 then
            str = TI18N("晋级128强")
        end
    end

    self.rankButtonText.text = TI18N("冠军之路")

    for _,v in pairs(self.battleItemList) do
        if v ~= nil then
            v.gameObject:SetActive(false)
        end
    end

    self.text1.transform.anchoredPosition = Vector2(-114,3)
    self.clockImage.transform.anchoredPosition = Vector2(2,-12)
    self.timeText.transform.anchoredPosition = Vector2(18, 3)

    self.layoutIndex = 0
    self.battleLayout:ReSet()

    self:AddBattleItem(TI18N("剩余比赛人数:"), IngotCrashManager.Instance.num or 0)

    local rewardData = DataGoldLeague.data_battle_reward[string.format("%s_1", IngotCrashManager.Instance:CurrentType())]
    if rewardData ~= nil then
        self:AddBattleItem(TI18N("本轮获胜奖励:"), string.format(TI18N("{assets_2, %s}%s"), rewardData.base_id, rewardData.num))
    end
    if IngotCrashManager.Instance.model.personData.reward ~= nil and IngotCrashManager.Instance.model.personData.reward[1] ~= nil then
        self:AddBattleItem(TI18N("已累计奖励:"), string.format(TI18N("{assets_2, %s}%s"), IngotCrashManager.Instance.model.personData.reward[1].assets, IngotCrashManager.Instance.model.personData.reward[1].val))
    end

    -- if all < 16 then
    --     self.battleNoticeExt:SetData(TI18N("本场获胜将晋级16强，向冠军发起冲锋！"))
    -- elseif loss_num
    -- end
    self.battleNoticeExt:SetData(string.format(TI18N("本场获胜<color=#ffff00>%s</color>"), str))
    self.battleNotice.sizeDelta = Vector2(200, self.battleNoticeExt.contentTrans.sizeDelta.y)

    self.battleLayout:AddCell(self.battleNotice.gameObject)
    self.timerId = LuaTimer.Add(0, 50, function() self:OnTime() end)

    self.rankButton.gameObject:SetActive(true)
    self.rewardButton.gameObject:SetActive(false)
end

function MainuiTraceIngotCrash:AddBattleItem(content, ext)
    self.layoutIndex = self.layoutIndex + 1
    local tab = self.battleItemList[self.layoutIndex]
    if tab == nil then
        tab = {}
        tab.gameObject = GameObject.Instantiate(self.battleItem)
        tab.transform = tab.gameObject.transform
        tab.contentExt = MsgItemExt.New(tab.transform:Find("Text"):GetComponent(Text), 177, 16, 18.53)
        tab.extraExt = MsgItemExt.New(tab.transform:Find("Ext"):GetComponent(Text), 177, 16, 18.53)
        self.battleItemList[self.layoutIndex] = tab
    end
    tab.contentExt:SetData(content)

    tab.extraExt:SetData(ext or "")
    local size = tab.extraExt.contentTrans.sizeDelta
    tab.extraExt.contentTrans.anchoredPosition = Vector2(-size.x, size.y / 2)
    tab.transform.sizeDelta = Vector2(200, tab.contentExt.contentTrans.sizeDelta.y - tab.contentExt.contentTrans.anchoredPosition.y)
    self.battleLayout:AddCell(tab.gameObject)
end

function MainuiTraceIngotCrash:OnTime()
    local min = nil
    local sec = nil
    if  IngotCrashManager.Instance.time < BaseUtils.BASE_TIME then
        min = "00"
        sec = "00"
    else
        min = math.floor((IngotCrashManager.Instance.time - BaseUtils.BASE_TIME) / 60)
        sec = (IngotCrashManager.Instance.time - BaseUtils.BASE_TIME) % 60
        if min < 10 then min = string.format("0%s", min) end
        if sec < 10 then sec = string.format("0%s", sec) end
    end

    if IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Ready then
        self.timeText.text = string.format("%s:%s", min, sec)
    elseif IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Qualifier
        or IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Kickout
        or IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Guess
        then
        if CombatManager.Instance.isFighting ~= true then
            self.timeText.text = string.format("%s:%s", min, sec)
            self.clockImage.gameObject:SetActive(true)
        else
            self.timeText.text = ""
            self.text1.text = TI18N("匹配中")
            self.clockImage.gameObject:SetActive(false)
        end
    end
end
