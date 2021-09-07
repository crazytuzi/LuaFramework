-- @author 黄耀聪
-- @date 2017年2月27日

-- 统计窗口

GuildSiegeStatistics = GuildSiegeStatistics or BaseClass(BasePanel)

function GuildSiegeStatistics:__init(model, parent)
    self.model = model
    self.name = "GuildSiegeStatistics"
    self.parent = parent

    self.resList = {
        {file = AssetConfig.guildsiege_statistics, type = AssetType.Main},
        {file = AssetConfig.guildsiege, type = AssetType.Dep},
        {file = AssetConfig.guildleague_texture, type = AssetType.Dep},
    }

    self.panelList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GuildSiegeStatistics:__delete()
    self.OnHideEvent:Fire()
    if self.panelList ~= nil then
        for _,v in pairs(self.panelList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
    end
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    self:AssetClearAll()
end

function GuildSiegeStatistics:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildsiege_statistics))
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    t:Find("Main").localPosition = Vector3(0, 0, -1500)

    t:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)
    t:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)

    self.panelList[1] = GuildSiegeOverall.New(self.model, t:Find("Main/Overall").gameObject, self.assetWrapper)
    self.panelList[2] = GuildSiegeAttackLog.New(self.model, t:Find("Main/Rank").gameObject, self.assetWrapper)

    self.tabGroup = TabGroup.New(t:Find("Main/TabButtonGroup").gameObject, function(index) self:ChangeTab(index) end, {notAutoSelect = true, noCheckRepeat = true, perWidth = 100, perHeight = 30, isVertical = true, spacing = 2})

    for _,v in pairs(self.panelList) do
        v:Hiden()
    end
end

function GuildSiegeStatistics:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildSiegeStatistics:OnOpen()
    self:RemoveListeners()
    self.isOpen = true

    self.tabGroup:ChangeTab(self.currnetIndex or 1)
end

function GuildSiegeStatistics:OnHide()
    self:RemoveListeners()
    self.isOpen = false
    if self.currnetIndex ~= nil then
        self.panelList[self.currnetIndex]:Hiden()
        self.currnetIndex = nil
    end
    GuildSiegeManager.Instance.onUpdateStatus:Fire()
end

function GuildSiegeStatistics:RemoveListeners()
end

function GuildSiegeStatistics:ChangeTab(index)
    if self.currnetIndex ~= nil then
        self.panelList[self.currnetIndex]:Hiden()
    end
    self.currnetIndex = index
    self.panelList[index]:Show()
end

GuildSiegeOverall = GuildSiegeOverall or BaseClass(BasePanel)

function GuildSiegeOverall:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.assetWrapper = assetWrapper

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self:InitPanel()
end

function GuildSiegeOverall:InitPanel()
    self.transform = self.gameObject.transform
    local t = self.transform

    self.guildInfoList = {{}, {}}

    self.scoreText = t:Find("ResultTitle/Score"):GetComponent(Text)
    for i=1,2 do
        local guild = self.guildInfoList[i]
        guild.nameText = t:Find("ResultTitle/Name" .. i):GetComponent(Text)
        guild.starText3 = t:Find("BestResult1/Result" .. i):GetComponent(Text)
        guild.starText2 = t:Find("BestResult2/Result" .. i):GetComponent(Text)
        guild.starText1 = t:Find("BestResult3/Result" .. i):GetComponent(Text)
        guild.attackText1 = t:Find("AttachResult1/Result" .. i):GetComponent(Text)
        guild.attackText2 = t:Find("AttachResult2/Result" .. i):GetComponent(Text)
        guild.bestAttackText = t:Find("PlayerResult1/Result" .. i):GetComponent(Text)
        guild.bestAttackPlayBtn = t:Find("PlayerResult1/Play" .. i):GetComponent(Button)
        guild.bestDefendText = t:Find("PlayerResult2/Result" .. i):GetComponent(Text)
        guild.bestDefendPlayBtn = t:Find("PlayerResult2/Play" .. i):GetComponent(Button)
        t:Find("AttachResult2/Result" .. i .. "/Icon").gameObject:SetActive(false)
    end

    t:Find("AttachResult1/Text"):GetComponent(Text).text = TI18N("总进攻次数")
    t:Find("AttachResult2/Text"):GetComponent(Text).text = TI18N("胜率")

    self.result = t:Find("Result"):GetComponent(Image)
end

function GuildSiegeOverall:__delete()
    self.gameObject = nil
    self.assetWrapper = nil
    self.model = nil
end

function GuildSiegeOverall:Update()
    local status = self.model:FinalResult()
    if status == GuildSiegeEumn.ResultType.None then
        self.result.gameObject:SetActive(false)
    else
        self.result.gameObject:SetActive(true)
        if status == GuildSiegeEumn.ResultType.Draw then        -- 平局
            self.result.sprite = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture, "tide")
        elseif status == GuildSiegeEumn.ResultType.Loss then    -- 完败
            self.result.sprite = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture, "lose1")
        elseif status == GuildSiegeEumn.ResultType.Fail then    -- 惜败
            self.result.sprite = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture, "lose2")
        elseif status == GuildSiegeEumn.ResultType.Win then     -- 险胜
            self.result.sprite = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture, "win2")
        elseif status == GuildSiegeEumn.ResultType.Victory then -- 完胜
            self.result.sprite = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture, "win1")
        end
    end

    self.model:Stat()

    for type,v in ipairs(self.guildInfoList) do
        local statData = self.model.statRes[type]
        v.nameText.text = statData.name or TI18N("暂无数据")
        v.starText1.text = statData.star1 or TI18N("暂无数据")
        v.starText2.text = statData.star2 or TI18N("暂无数据")
        v.starText3.text = statData.star3 or TI18N("暂无数据")
        v.attackText1.text = string.format("%s", statData.all_atk_times or 0)
        -- v.attackText2.text = statData.destroy_rate or TI18N("- -")
        v.attackText2.text = string.format("%s%%",math.floor((statData.win_rate or 0) * 100))
        v.bestAttackPlayBtn.onClick:RemoveAllListeners()
        v.bestDefendPlayBtn.onClick:RemoveAllListeners()
        if statData.best_attack == nil or statData.best_attack.name == "" then
            v.bestAttackText.text = TI18N("暂无数据")
            v.bestAttackPlayBtn.gameObject:SetActive(false)
        else
            v.bestAttackText.text = statData.best_attack.name
            v.bestAttackPlayBtn.gameObject:SetActive(true)
            v.bestAttackPlayBtn.onClick:AddListener(function() self:OnPlay(statData.best_attack.replay_id, statData.best_attack.replay_plat, statData.best_attack.replay_zone) end)
        end
        if statData.best_defend == nil or statData.best_defend.name == "" then
            v.bestDefendText.text = TI18N("暂无数据")
            v.bestDefendPlayBtn.gameObject:SetActive(false)
        else
            v.bestDefendText.text = statData.best_defend.name
            v.bestDefendPlayBtn.gameObject:SetActive(true)
            v.bestDefendPlayBtn.onClick:AddListener(function() self:OnPlay(statData.best_defend.replay_id, statData.best_defend.replay_plat, statData.best_defend.replay_zone) end)
        end
    end

    self.scoreText.text = string.format("%s-%s", self.model.statRes[1].score or 0, self.model.statRes[2].score or 0)
end

function GuildSiegeOverall:OnHide()
end

function GuildSiegeOverall:OnOpen()
    self:Update()
end

function GuildSiegeOverall:OnPlay(replay_id, replay_plat, replay_zone)
    GuildSiegeManager.Instance:send19111(replay_id, replay_plat, replay_zone)
end