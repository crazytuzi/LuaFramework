-- 公会战，任务追踪面板
-- @author zgs
GuildfightPanel = GuildfightPanel or BaseClass(BaseTracePanel)

local GameObject = UnityEngine.GameObject

function GuildfightPanel:__init(main)
    self.main = main
    self.isInit = false

    self.timerIdBefore = 0
    self.countDataBefore = 0
    self.timeReadyArea = 120

    self.descString = TI18N("1.公会战最多可有<color='#ffff00'>100</color>名公会成　员参加\n2.可自由组成5人队伍参加\n3.初始有<color='#ffff00'>%s</color>行动力，行动力为<color='#ffff00'>0</color>　时将传出场外\n4.活动结束时<color='#ffff00'>人数高</color>的一方获胜")

    self.guildfightDataUpdateFun = function ()
        --更新任务追踪界面
        self:Update()
    end

    self.roleEventChange = function (event,oldEvent)
        self:on_role_event_change(event,oldEvent)
    end

    self._SettingUpdate = function(key, value)
        self:SettingUpdate(key, value)
    end

    self.resList = {
        {file = AssetConfig.guildfight_content, type = AssetType.Main}
    }

    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GuildfightPanel:on_role_event_change(event,oldEvent)
    if (oldEvent == RoleEumn.Event.GuildFightReady or oldEvent == RoleEumn.Event.GuildFight) and (event ~= RoleEumn.Event.GuildFightReady and event ~= RoleEumn.Event.GuildFight) then
        self:Exit(false)
    elseif event == RoleEumn.Event.GuildFightReady or event == RoleEumn.Event.GuildFight then
        self:Update()
    end
end

function GuildfightPanel:__delete()
    self.OnHideEvent:Fire()
    -- if self.timerIdBefore ~= nil and self.timerIdBefore ~= 0 then
    --     LuaTimer.Delete(self.timerIdBefore)
    -- end
    -- if self.timerIdBeforeStarting ~= nil and self.timerIdBeforeStarting ~= 0 then
    --     LuaTimer.Delete(self.timerIdBeforeStarting)
    -- end
    -- if self.bev ~= nil then
    --     self.bev:DeleteMe()
    -- end
    -- EventMgr.Instance:RemoveListener(event_name.guild_fight_data_update, self.guildfightDataUpdateFun)
    -- EventMgr.Instance:RemoveListener(event_name.role_event_change, self.roleEventChange)
end

function GuildfightPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildfight_content))
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.transform:Find("Main/Container"))
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition3D = Vector3(0, -45, 0)

    self.startingContent = self.transform:Find("Starting").gameObject
    self.ruleBtn = self.startingContent.transform:Find("RuleImage").gameObject
    self.ruleBtn:GetComponent(Button).onClick:AddListener(function() self:ShowRule() end)
    self.activeText = self.startingContent.transform:Find("ActiveText"):GetComponent(Text)
    self.startingContent.transform:Find("DescText_3"):GetComponent(Text).text = TI18N("已击败队伍")
    self.killCountText = self.startingContent.transform:Find("KillCntText"):GetComponent(Text)
    self.rankBtn = self.startingContent.transform:Find("Hide/Button").gameObject
    self.rankBtn:GetComponent(Button).onClick:AddListener(function() self:ShowIntegralPanel() end)
    self.rankBtn.transform:Find("Text"):GetComponent(Text).text = TI18N("战绩排行")
    self.exitBtn = self.startingContent.transform:Find("GiveUP/Button").gameObject
    self.exitBtn:GetComponent(Button).onClick:AddListener(function() self:onClickExitBtn() end)
    self.shPersonTog = self.startingContent.transform:Find("ImgBg/Toggle"):GetComponent(Toggle)
    self.shPersonTog.onValueChanged:AddListener(function (status)
        if status == true then
            SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(true)
        else
            SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(false)
        end
    end)
    SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(false)

    self.activeCount = 1000

    self.beforeContent = self.transform:Find("Before").gameObject
    self.activeTextBefore = self.beforeContent.transform:Find("ActiveText"):GetComponent(Text)
    self.desctextBefore = self.beforeContent.transform:Find("DescText_2"):GetComponent(Text)
    self.desctextBefore.lineSpacing = 1.2

    self.beforeBg = self.beforeContent.transform:Find("ImgBg")

    self.desctextBefore.transform.sizeDelta = Vector2(217, 140)
    self.beforeBg.sizeDelta = Vector2(226, 210)
    self.ruleBtnBefore = self.beforeContent.transform:Find("ImgBg/Hide/Button").gameObject
    self.ruleBtnBefore.transform.anchoredPosition = self.ruleBtnBefore.transform.anchoredPosition + Vector2(0, -40)
    self.ruleBtnBefore:GetComponent(Button).onClick:AddListener(function() self:ShowRule() end)
    -- self.ruleBtnBefore.transform.sizeDelta = Vector2(40, -47)
    self.exitBtnBefore = self.beforeContent.transform:Find("ImgBg/GiveUP/Button").gameObject
    self.exitBtnBefore.transform.anchoredPosition = self.exitBtnBefore.transform.anchoredPosition + Vector2(0, -40)
    self.exitBtnBefore:GetComponent(Button).onClick:AddListener(function() self:onClickExitBtnBefore() end)
    self.descRuleBtnBefore = self.beforeContent.transform:Find("RuleDescBtn").gameObject
    self.descRuleBtnBefore:GetComponent(Button).onClick:AddListener(function() self:ShowDescRule(self.descRuleBtnBefore) end)
    self.descRuleBtnBefore:GetComponent(RectTransform).anchoredPosition = Vector2(34,-36)

    self.beforeStartingContent = self.transform:Find("BeforeStarting").gameObject
    self.activeTextBeforeStarting = self.beforeStartingContent.transform:Find("ActiveText"):GetComponent(Text)
    self.desctextBeforeStarting = self.beforeStartingContent.transform:Find("DescText_2"):GetComponent(Text)
    self.desctextBeforeStarting.transform.sizeDelta = Vector2(217, 135)
    self.desctextBeforeStarting.lineSpacing = 1.2

    self.beforeStartingContent.transform:Find("DescAcitveText"):GetComponent(Text).text = ColorHelper.Fill(ColorHelper.color[5], TI18N("开始倒计时"))
    self.beforeStartingBg = self.beforeStartingContent.transform:Find("ImgBg")
    self.beforeStartingBg.sizeDelta = Vector2(226, 210)
    self.ruleBtnBeforeStarting = self.beforeStartingContent.transform:Find("ImgBg/Hide/Button").gameObject
    self.ruleBtnBeforeStarting.transform.anchoredPosition = self.ruleBtnBeforeStarting.transform.anchoredPosition + Vector2(0, -40)
    self.ruleBtnBeforeStarting:GetComponent(Button).onClick:AddListener(function() self:enterFightScene() end)
    self.exitBtnBeforeStarting = self.beforeStartingContent.transform:Find("ImgBg/GiveUP/Button").gameObject
    self.exitBtnBeforeStarting.transform.anchoredPosition = self.exitBtnBeforeStarting.transform.anchoredPosition + Vector2(0, -40)
    self.exitBtnBeforeStarting:GetComponent(Button).onClick:AddListener(function() self:onClickExitBtnBefore() end)
    local fun2 = function(effectView)
        local effectObject = effectView.gameObject

        effectObject.transform:SetParent(self.ruleBtnBeforeStarting.transform)
        effectObject.transform.localScale = Vector3(1, 1, 1)
        effectObject.transform.localPosition = Vector3(-50, 27, -1000)
        effectObject.transform.localRotation = Quaternion.identity

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
        effectObject:SetActive(true)
    end
    self.bev = BaseEffectView.New({effectId = 20118, time = nil, callback = fun2})
    self.descRuleBtnBeforeStarting = self.beforeStartingContent.transform:Find("RuleDescBtn").gameObject
    self.descRuleBtnBeforeStarting:GetComponent(Button).onClick:AddListener(function() self:ShowDescRule(self.descRuleBtnBeforeStarting) end)
    self.descRuleBtnBeforeStarting:GetComponent(RectTransform).anchoredPosition = Vector2(34,-36)
    -- local btn = self.main.tabGroup.buttonTab[TraceEumn.BtnType.GuildFight].gameObject
    -- local imageTemp = btn.transform:Find("Image"):GetComponent(Image)
    -- imageTemp.sprite = self.assetWrapper:GetSprite(AssetConfig.guild_build_icon , tostring(self.data.ToTem))

    self.isInit = true
end

function GuildfightPanel:ShowDescRule(btnObj)
    self.descRole = {
        TI18N("1.行动力初始为<color='#ffff00'>1000</color>，等级较于世界等级越低拥有的初始行动力越少"),
        TI18N("2.精英及以上初始行动力为<color='#ffff00'>1000</color>，成员及新秀初始行动力为<color='#ffff00'>800</color>"),
    }
    TipsManager.Instance:ShowText({gameObject = btnObj, itemData = self.descRole})
end

function GuildfightPanel:enterFightScene()
    if self.timerIdBeforeStarting ~= nil and self.timerIdBeforeStarting ~= 0 then
        LuaTimer.Delete(self.timerIdBeforeStarting)
    end
    self.timeReadyArea = 120
    -- GuildfightManager.Instance:send15502()
    GuildfightManager.Instance:GuildFightCheckIn()
    self:Update()
end

function GuildfightPanel:onClickExitBtn()
    --
    self:fightingAreaExit()
end

function GuildfightPanel:fightingAreaExit()
    if TeamManager.Instance:HasTeam() == true then
        NoticeManager.Instance:FloatTipsByString(TI18N("请先退出队伍，再尝试退出战场"))
    else
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("战友们需要你！现在退出将无法再次进入！")
        data.sureLabel = TI18N("退出")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function ()
            self:Exit()
        end
        NoticeManager.Instance:ConfirmTips(data)
    end
end

function GuildfightPanel:onClickExitBtnBefore()
    self:readyAreaExit()
end

function GuildfightPanel:readyAreaExit()
    if TeamManager.Instance:HasTeam() == true then
        NoticeManager.Instance:FloatTipsByString(TI18N("请先退出队伍，再尝试退出战场"))
    else
        self:Exit()
    end
end

function GuildfightPanel:Exit(isNeedSend15503)
    self.timeReadyArea = 120
    if isNeedSend15503 == nil or isNeedSend15503 == true then
        GuildfightManager.Instance:send15503()
    end
    local mgr = GuildfightManager.Instance
    mgr.model:ExitScene()
    SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(SettingManager.Instance:GetResult(SettingManager.Instance.THidePerson))
    GuildfightManager.Instance.model:CheckTeamVisible()
end
function GuildfightPanel:ShowRule()
    self.descRole = {
        TI18N("1、<color='#ffff00'>行动力为0</color>时，将会自动退场结算奖励"),
        TI18N("2、每次战败扣除<color='#ffff00'>300</color>行动力，发起战斗最多消耗<color='#ffff00'>70</color>行动力"),
        TI18N("3、公会战结束时，<color='#ffff00'>存活人数多</color>的一方获胜"),
        TI18N("4、公会战结束后场上将会投放<color='#ffff00'>珍稀宝箱</color>，场上的获胜方可以拾取"),
        -- "1、<color='#ffff00'>主动发起</color>战斗扣除50行动力。",
        -- "2、<color='#ffff00'>战斗失败</color>扣除1000行动力。",
        -- "3、公会战开启后15分钟内进入需扣除<color='#ffff00'>500</color>行动力。",
        -- "4、行动力为<color='#ffff00'>0</color>时，自动退出战场结算奖励。",
        -- "5、公会总战力由所有参战成员的<color='#ffff00'>等级</color>和<color='#ffff00'>行动力</color>决定。",
        -- "6、公会战时间结束时，公会总战力高的一方获胜。",
        -- "7、任一方公会总战力为<color='#ffff00'>0</color>时，即算失败，结束公会战。",
    }
    TipsManager.Instance:ShowText({gameObject = self.ruleBtn.gameObject, itemData = self.descRole})
end
--战绩排名
function GuildfightPanel:ShowIntegralPanel()
    local mgr = GuildfightManager.Instance
    mgr.model:OpenGuildFightIntegralPanel()
end

function GuildfightPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildfightPanel:OnShow()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.setting_change, self._SettingUpdate)
    EventMgr.Instance:AddListener(event_name.guild_fight_data_update, self.guildfightDataUpdateFun)
    EventMgr.Instance:AddListener(event_name.role_event_change, self.roleEventChange)

    if GuildManager.Instance.model.my_guild_data ~= nil 
        and GuildManager.Instance.model.my_guild_data.MyPost ~= nil 
            and GuildManager.Instance.model.my_guild_data.MyPost < 20 then
        self.activeCount = self.activeCount * 0.8
    end

    local roleLev = RoleManager.Instance.RoleData.lev
    if RoleManager.Instance.RoleData.lev_break_times > 0 then
        roleLev = roleLev + 5
    end
    if roleLev <= RoleManager.Instance.world_lev - 20 then
        self.activeCount = self.activeCount * 0.1
    elseif roleLev <= RoleManager.Instance.world_lev - 15 then
        self.activeCount = self.activeCount * 0.3
    elseif roleLev <= RoleManager.Instance.world_lev - 10 then
        self.activeCount = self.activeCount * 0.4
    elseif roleLev <= RoleManager.Instance.world_lev - 5 then
        self.activeCount = self.activeCount * 0.6
    end

    self.desctextBefore.text = string.format(self.descString, self.activeCount)
    self.activeText.text = GuildfightManager.Instance.mineinfo.movability or self.activeCount
    self.beforeStartingContent.transform:Find("DescText_2"):GetComponent(Text).text = string.format(self.descString, self.activeCount)

    self:Update()
end

function GuildfightPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.guild_fight_data_update, self.guildfightDataUpdateFun)
    EventMgr.Instance:RemoveListener(event_name.role_event_change, self.roleEventChange)
    EventMgr.Instance:RemoveListener(event_name.setting_change, self._SettingUpdate)
end

function GuildfightPanel:OnHide()
    if self.timerIdBefore ~= nil and self.timerIdBefore ~= 0 then
        LuaTimer.Delete(self.timerIdBefore)
    end
    if self.timerIdBeforeStarting ~= nil and self.timerIdBeforeStarting ~= 0 then
        LuaTimer.Delete(self.timerIdBeforeStarting)
    end
    -- if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.GuildFightReady and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.GuildFight then
    --     EventMgr.Instance:RemoveListener(event_name.guild_fight_data_update, self.guildfightDataUpdateFun)
    --     EventMgr.Instance:RemoveListener(event_name.role_event_change, self.roleEventChange)
    --     EventMgr.Instance:RemoveListener(event_name.setting_change, self._SettingUpdate)
    -- end

    self:RemoveListeners()
    -- local mgr = GuildfightManager.Instance
    -- mgr.model:ExitScene()
end

function GuildfightPanel:SettingUpdate(key, value)
    if key == SettingManager.Instance.THidePerson then
        if self.shPersonTog ~= nil then
            self.shPersonTog.isOn = value
        end
    end
end

function GuildfightPanel:Update()
    if self.isInit == false then
        return
    end
    SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(false) --进入默认不省流量
    if self.shPersonTog ~= nil then
        SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(self.shPersonTog.isOn) --跟随界面的设置
    end
    if self.timerIdBeforeStarting ~= nil and self.timerIdBeforeStarting ~= 0 then
        LuaTimer.Delete(self.timerIdBeforeStarting)
    end
    local mgr = GuildfightManager.Instance
    -- if mgr.stateInfo.status == 1 then
    -- print("GuildfightPanel:Update()="..RoleManager.Instance.RoleData.event)
    GuildfightManager.Instance.model:CheckTeamVisible()
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildFightReady then
        --准备区阶段
        if mgr.stateInfo.status == 1 then
            self.startingContent:SetActive(false)
            self.beforeStartingContent:SetActive(false)
            self.beforeContent:SetActive(true)
            -- self.activeTextBefore.text = ""

            if self.timerIdBefore ~= nil and self.timerIdBefore ~= 0 then
                LuaTimer.Delete(self.timerIdBefore)
            end
            -- self.countDataBefore = mgr.stateInfo.timeout
            -- print("GuildfightPanel:Update()=timeout="..mgr.stateInfo.timeout)
            self.timerIdBefore = LuaTimer.Add(0, 1000, function()
                --print(self.clickInterval)
                self.activeTextBefore.text = BaseUtils.formate_time_gap(mgr.stateInfo.timeout - Time.time,":",0,BaseUtils.time_formate.MIN)
            end)
        elseif mgr.stateInfo.status == 2 then
            self.startingContent:SetActive(false)
            self.beforeStartingContent:SetActive(true)
            self.beforeContent:SetActive(false)

            self.timerIdBeforeStarting = LuaTimer.Add(0, 1000, function()
                --print(self.clickInterval)
                if self.timeReadyArea > 0 then
                    self.timeReadyArea = self.timeReadyArea - 1
                    self.activeTextBeforeStarting.text = BaseUtils.formate_time_gap(self.timeReadyArea,":",0,BaseUtils.time_formate.MIN)
                else
                    self.activeTextBeforeStarting.text = "00:00"
                    LuaTimer.Delete(self.timerIdBeforeStarting)
                    self.timeReadyArea = 120
                    -- print("GuildfightPa222222222222nel:Update()="..RoleManager.Instance.RoleData.event)
                    if RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildFightReady or RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildFight then
                        if TeamManager.Instance:HasTeam() == true then
                            if TeamManager.Instance:IsSelfCaptin() == true then
                                self:enterFightScene()
                            end
                        else
                            self:enterFightScene()
                        end
                    end
                end
            end)
        elseif mgr.stateInfo.status == 0 then
        end
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildFight then
        --进行中
        BaseUtils.dump(mgr.mineinfo,"-----mgr.mineinfo-------")
        self.startingContent:SetActive(true)
        self.beforeStartingContent:SetActive(false)
        self.beforeContent:SetActive(false)
        self.activeText.text = tostring(mgr.mineinfo.movability)
        self.killCountText.text = tostring(mgr.mineinfo.win)

        mgr.model:EnterScene()
    end
end
