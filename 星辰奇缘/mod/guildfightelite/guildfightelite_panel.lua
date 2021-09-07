-- 公会英雄战，任务追踪面板
-- @author zgs
GuildfightElitePanel = GuildfightElitePanel or BaseClass(BaseTracePanel)

local GameObject = UnityEngine.GameObject

function GuildfightElitePanel:__init(main)
    self.main = main
    self.isInit = false

    self.timerId = 0

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
    -- self.lastRoleEvent = RoleEumn.Event.GuildEliteFight

    self.resList = {
        {file = AssetConfig.guildelitefight_content, type = AssetType.Main}
    }

    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GuildfightElitePanel:on_role_event_change(event,oldEvent)
    -- print(RoleManager.Instance.RoleData.event.." GuildfightElitePanel:Update() "..debug.traceback())
    if event == RoleEumn.Event.GuildEliteFight then
        -- self.lastRoleEvent = RoleEumn.Event.GuildEliteFight
        GuildFightEliteManager.Instance:send16205()

        local t = MainUIManager.Instance.MainUIIconView
        if t ~= nil then
            t:Set_ShowTop(false, {17, 107,113})
        end
    elseif oldEvent == RoleEumn.Event.GuildEliteFight then
        -- self.lastRoleEvent = RoleManager.Instance.RoleData.event
        SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(SettingManager.Instance:GetResult(SettingManager.Instance.THidePerson))
        local t = MainUIManager.Instance.MainUIIconView
        if t ~= nil then
            t:Set_ShowTop(true, {107})
        end
    end
end

function GuildfightElitePanel:__delete()
    self.OnHideEvent:Fire()
    -- if self.timerId ~= nil and self.timerId ~= 0 then
    --     LuaTimer.Delete(self.timerId)
    -- end
    -- EventMgr.Instance:RemoveListener(event_name.guild_elite_war_match_info_change, self.guildfightDataUpdateFun)
    -- EventMgr.Instance:RemoveListener(event_name.role_event_change, self.roleEventChange)
end

function GuildfightElitePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildelitefight_content))
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.transform:Find("Main/Container"))
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition = Vector3(0, -45, 0)

    self.transform:Find("Level/Text"):GetComponent(Text).text = TI18N("公会英雄战")
    self.startingContent = self.transform:Find("Starting").gameObject
    self.imgBgBtn = self.startingContent.gameObject:AddComponent(Button)-- self.startingContent.transform:Find("ImgBg").gameObject:AddComponent("Button)
    self.imgBgBtn.onClick:AddListener(function() self:ShowEliteLookWindow() end)
    -- self.ruleBtn = self.startingContent.transform:Find("RuleImage").gameObject
    -- self.ruleBtn:GetComponent(Button).onClick:AddListener(function() self:ShowRule() end)
    self.descText = self.startingContent.transform:Find("DescText"):GetComponent(Text) --第一轮对手
    self.guildNameText = self.startingContent.transform:Find("GuildNameText"):GetComponent(Text) --公会名

    self.shPersonTog = self.startingContent.transform:Find("Toggle"):GetComponent(Toggle)
    self.shPersonTog.transform:Find("Background/Checkmark").gameObject:SetActive(true)
    self.shPersonTog.onValueChanged:AddListener(function (status)
        if status == true then
            SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(true)
        else
            SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(false)
        end
    end)
    SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(false)

    self.gameList = {}
    for i=1,3 do
        local item = {}
        item.obj = self.startingContent.transform:Find("G_"..i)
        item.descText = item.obj:Find("SunDescText"):GetComponent(Text)
        item.leftText = item.obj:Find("NameText_11"):GetComponent(Text)
        item.rightText = item.obj:Find("NameText_12"):GetComponent(Text)
        item.resultText = item.obj:Find("ResultText_1"):GetComponent(Text)
        item.imgObj = item.obj:Find("Image_1").gameObject
        item.resultBg = item.obj:Find("ResultBgImage").gameObject
        item.resultBg:SetActive(false)

        table.insert(self.gameList,item)
    end
    self.game_1 = self.startingContent.transform:Find("G_1")

    self.timeDescText = self.startingContent.transform:Find("DescText_3"):GetComponent(Text) --离第二轮匹配时间

    self.rankBtn = self.startingContent.transform:Find("Hide/Button").gameObject
    self.rankBtn:GetComponent(Button).onClick:AddListener(function() self:ShowElitePanel() end)
    -- self.rankBtn.transform:Find("Text"):GetComponent(Text).text = "战绩排行"
    self.exitBtn = self.startingContent.transform:Find("GiveUP/Button").gameObject
    self.exitBtn:GetComponent(Button).onClick:AddListener(function() self:onClickExitBtn() end)

    self.isInit = true

    if RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildEliteFight then
        GuildFightEliteManager.Instance:send16205()
    end
end

function GuildfightElitePanel:ShowEliteLookWindow()
    GuildFightEliteManager.Instance.model:ShowEliteLookWindow(true)
end

function GuildfightElitePanel:ShowElitePanel()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guildfightelite_window)
end

--退出
function GuildfightElitePanel:onClickExitBtn()
    GuildFightEliteManager.Instance:send16204()
    SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(SettingManager.Instance:GetResult(SettingManager.Instance.THidePerson))
end

function GuildfightElitePanel:changeName(name)
    --
    -- print(string.utf8len(name).."------"..name)
    if string.utf8len(name) > 4 then
        local strList = StringHelper.ConvertStringTable(name)
        local str = string.format("<color='#ffff00'>%s%s%s..</color>",strList[1],strList[2],strList[3])
        return str
    end
    return string.format("<color='#ffff00'>%s</color>",name)
end

function GuildfightElitePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildfightElitePanel:OnShow()
    self:RemoveListeners()

    EventMgr.Instance:AddListener(event_name.setting_change, self._SettingUpdate)
    EventMgr.Instance:AddListener(event_name.guild_elite_war_match_info_change, self.guildfightDataUpdateFun)
    EventMgr.Instance:AddListener(event_name.role_event_change, self.roleEventChange)
    self:Update()
    GuildfightManager.Instance.model:CheckTeamVisible()
end

function GuildfightElitePanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.guild_elite_war_match_info_change, self.guildfightDataUpdateFun)
    EventMgr.Instance:RemoveListener(event_name.role_event_change, self.roleEventChange)
    EventMgr.Instance:RemoveListener(event_name.setting_change, self._SettingUpdate)
end

function GuildfightElitePanel:OnHide()
    if self.timerId ~= nil and self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
    end
    self:RemoveListeners()
    GuildfightManager.Instance.model:CheckTeamVisible()
end

function GuildfightElitePanel:SettingUpdate(key, value)
    if key == SettingManager.Instance.THidePerson then
        if self.shPersonTog ~= nil then
            self.shPersonTog.isOn = value
        end
    end
end

function GuildfightElitePanel:Update()
    local guildMatchInfo = GuildFightEliteManager.Instance.guildEliteWarMatch
    if self.isInit == false or guildMatchInfo == nil then
        return
    end
    SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(false) --进入默认不省流量
    if self.shPersonTog ~= nil then
        SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(self.shPersonTog.isOn) --跟随界面的设置
    end
    local t = MainUIManager.Instance.MainUIIconView
    if t ~= nil then
        t:Set_ShowTop(false, {17, 107,113})
    end
    self:updateTime(guildMatchInfo)
    if guildMatchInfo.round == 1 then
        self.descText.text = TI18N("第一轮对手")
    elseif guildMatchInfo.round == 2 then
        self.descText.text = TI18N("第二轮对手")
    end
    local guildNameTemp ,flag = self:GetFighterGuildName()
    if flag == nil then
        self.guildNameText.text = string.format("<color='%s'>%s</color>","#23f0f7",guildNameTemp)
    else
        self.guildNameText.text = guildNameTemp
    end
    local myList ,otherList = self:GetFightList()
    for i=1,3 do
        local gameItem = self.gameList[i]
        if i == 1 then
            gameItem.descText.text = TI18N("太阳代表队")
            i = 2
        elseif i == 2 then
            gameItem.descText.text = TI18N("月亮代表队")
            i = 1
        else
            gameItem.descText.text = TI18N("星辰代表队")
        end
        local myTeam = myList[i]
        local otherTeam = otherList[i]
        local isKnowWinner = false
        if myTeam ~= nil then
            gameItem.leftText.text = self:changeName(myTeam.name)

            isKnowWinner = true
            if myTeam.is_win == 0 then
                --未出结果
                gameItem.resultText.text = ""
                gameItem.resultBg:SetActive(false)
                gameItem.imgObj:SetActive(true)
            elseif myTeam.is_win == 1 then
                --胜利
                gameItem.resultText.text = string.format(TI18N("<color='%s'>胜</color>"),ColorHelper.color[1])
                gameItem.resultBg:SetActive(true)
                gameItem.imgObj:SetActive(false)
            else
                --失败
                gameItem.resultText.text = string.format(TI18N("<color='%s'>败</color>"),ColorHelper.color[6])
                gameItem.resultBg:SetActive(true)
                gameItem.imgObj:SetActive(false)
            end
        else
            gameItem.leftText.text = TI18N("暂无")
            isKnowWinner = true

            gameItem.resultText.text = string.format(TI18N("<color='%s'>败</color>"),ColorHelper.color[6])
            gameItem.resultBg:SetActive(true)
            gameItem.imgObj:SetActive(false)
        end
        if otherTeam ~= nil then
            gameItem.rightText.text = self:changeName(otherTeam.name)

            -- if isKnowWinner == false then
            --     if otherTeam.is_win == 0 then
            --         --未出结果
            --         gameItem.resultText.text = ""
            --         gameItem.resultBg:SetActive(false)
            --         gameItem.imgObj:SetActive(true)
            --     elseif otherTeam.is_win == 1 then
            --         --对方胜利
            --         gameItem.resultText.text = string.format("<color='%s'>败</color>",ColorHelper.color[6])
            --         gameItem.resultBg:SetActive(true)
            --         gameItem.imgObj:SetActive(false)
            --     else
            --         --对方失败
            --         gameItem.resultText.text = string.format("<color='%s'>胜</color>",ColorHelper.color[1])
            --         gameItem.resultBg:SetActive(true)
            --         gameItem.imgObj:SetActive(false)
            --     end
            -- end
        else
            gameItem.rightText.text = TI18N("暂无")
        end
        if myTeam == nil and otherTeam == nil then
            gameItem.resultText.text = ""
            gameItem.resultBg:SetActive(false)
            gameItem.imgObj:SetActive(true)
        end
    end
end
function GuildfightElitePanel:updateTime(guildMatchInfo)
    if self.timerId ~= nil and self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
    end
    local timeOver = BaseUtils.BASE_TIME - guildMatchInfo.time -- 已经过去了的秒数
    self.timerId = LuaTimer.Add(0, 1000, function()
        --
        if GuildFightEliteManager.Instance.eliteWarInfo.status == 2 then
            --准备阶段
            local day,hour,min,second = BaseUtils.time_gap_to_timer(math.floor(GuildFightEliteManager.Instance.eliteWarInfo.timeout  - Time.time))
            -- print(math.floor(GuildFightEliteManager.Instance.eliteWarInfo.timeout  - Time.time))
            if min == 0 and second > 0 then
                min = 1
            end
            self.timeDescText.text = string.format(TI18N("对手将在<color='%s'>%d分</color>后公布"),ColorHelper.color[1],min)
        elseif GuildFightEliteManager.Instance.eliteWarInfo.status == 3 then
            --开始阶段
            timeOver = BaseUtils.BASE_TIME - guildMatchInfo.time
            -- print("timeOver = "..timeOver)
            if timeOver < 60 then --300
                local day,hour,min,second = BaseUtils.time_gap_to_timer(math.floor(60 - timeOver))
                if min == 0 and second > 0 then
                    min = 1
                end
                self.timeDescText.text = string.format(TI18N("<color='%s'>%d分</color>后正式开战"),ColorHelper.color[1],min)
            elseif timeOver < 960 then
                if guildMatchInfo.round == 1 then
                    local day,hour,min,second = BaseUtils.time_gap_to_timer(math.floor(960 - timeOver))
                    if min == 0 and second > 0 then
                        min = 1
                    end
                    self.timeDescText.text = string.format(TI18N("第二轮对手<color='%s'>%d分</color>后公布"),ColorHelper.color[1],min)
                else
                    self.timeDescText.text = string.format(TI18N("第二轮<color='%s'>英雄战</color>已经开启"),ColorHelper.color[1])
                end
            else
                self.timeDescText.text = string.format(TI18N("没新的匹配信息"))
            end
        end
    end)
end
--取对战的公会名称
function GuildfightElitePanel:GetFighterGuildName()
    local myGuildData = GuildManager.Instance.model.my_guild_data
    local guildMatchInfo = GuildFightEliteManager.Instance.guildEliteWarMatch
    if guildMatchInfo.g_id2 == 0 and guildMatchInfo.g_name2 == "" then
        if guildMatchInfo.round == 1 then
            self.descText.text = TI18N("第一轮轮空，")
            return TI18N("<color='#c7f9ff'>请等待第二轮</color>") , 1
        end
        return TI18N("暂无")
    end
    if myGuildData ~= nil and guildMatchInfo ~= nil then
        if myGuildData.GuildId == guildMatchInfo.g_id1
            and myGuildData.PlatForm == guildMatchInfo.g_platform1
            and myGuildData.ZoneId == guildMatchInfo.g_zone_id1 then
            return guildMatchInfo.g_name2
        else
            return guildMatchInfo.g_name1
        end
    end
    return TI18N("暂无")
end

function GuildfightElitePanel:GetFightList()
    local myGuildData = GuildManager.Instance.model.my_guild_data
    local guildMatchInfo = GuildFightEliteManager.Instance.guildEliteWarMatch
    if myGuildData ~= nil and guildMatchInfo ~= nil then
        local myList = {}
        local otherList = {}
        for i,v in ipairs(guildMatchInfo.leaders) do
            if myGuildData.GuildId == v.g_id
                and myGuildData.PlatForm == v.g_platform
                and myGuildData.ZoneId == v.g_zone_id then
                myList[v.position] = v
            else
                otherList[v.position] = v
            end
        end
        return myList,otherList
    end
    return nil,nil
end
