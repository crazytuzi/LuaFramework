-- @author 黄耀聪
-- @date 2017年2月27日

GuildSiegeCheckPlayer = GuildSiegeCheckPlayer or BaseClass(BasePanel)

function GuildSiegeCheckPlayer:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "GuildSiegeCheckPlayer"

    self.resList = {
        {file = AssetConfig.guildsiege_checkplayer, type = AssetType.Main},
        {file = AssetConfig.guildsiege, type = AssetType.Dep},
        {file = AssetConfig.arena_textures, type = AssetType.Dep},
        {file = AssetConfig.guard_head, type = AssetType.Dep},
    }

    self.panelList = {}
    self.updateListener = function() self.tabGroup:ChangeTab(self.currnetIndex or 1) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GuildSiegeCheckPlayer:__delete()
    self.OnHideEvent:Fire()
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.panelList ~= nil then
        for _,v in pairs(self.panelList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.panelList = nil
    end
    self:AssetClearAll()
end

function GuildSiegeCheckPlayer:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildsiege_checkplayer))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    t.localPosition = Vector3(0, 0, -1500)

    t:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)

    self.main = t:Find("Main")
    self.panelList[1] = GuildSiegeCheckInfo.New(self.model, t:Find("Main/Info").gameObject, self.assetWrapper)
    self.panelList[2] = GuildSiegeDefendLog.New(self.model, t:Find("Main/Rank").gameObject, self.assetWrapper)
    self.panelList[3] = GuildSiegeStarSelect.New(self.model, t:Find("FightPanel").gameObject, self.assetWrapper)

    self.main:Find("Left"):GetComponent(Button).onClick:AddListener(function() self:GoNext(false) end)
    self.main:Find("Right"):GetComponent(Button).onClick:AddListener(function() self:GoNext(true) end)

    self.tabGroup = TabGroup.New(t:Find("Main/TabButtonGroup").gameObject, function(index) self:ChangeTab(index) end, {notAutoSelect = true, noCheckRepeat = true, perWidth = 100, perHeight = 30, isVertical = true, spacing = 2})

    for _,v in ipairs(self.panelList) do
        v:Hiden()
    end
end

function GuildSiegeCheckPlayer:GoNext(isRight)
    local order = self.castle.order
    local maxOrder = order

    if self.model.statusData ~= nil and self.model.statusData.guild_match_list ~= nil then 
        for _,v in pairs(self.model.statusData.guild_match_list[self.castle.type].castle_list) do
            if v.order > maxOrder then
                maxOrder = v.order
            end
        end
        if maxOrder > 0 then
            if isRight == true then
                if order == maxOrder then
                    order = 1
                else
                    order = order + 1
                end
            else
                if order == 1 then
                    order = maxOrder
                else
                    order = order - 1
                end
            end
            for _,v in pairs(self.model.statusData.guild_match_list[self.castle.type].castle_list) do
                if v.order == order then
                    self.openArgs = v
                    self.OnOpenEvent:Fire()
                end
            end
        end
    end
end

function GuildSiegeCheckPlayer:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildSiegeCheckPlayer:OnOpen()
    self.castle = self.openArgs or {}
    self.main.gameObject:SetActive(true)
    -- BaseUtils.dump(self.castle, "castle")

    self.panelList[3]:Hiden()

    if (self.castle.order or 0) > 0 then
        GuildSiegeManager.Instance:send19102(self.castle.type, self.castle.order)
    end

    self.isOpen = true
    self:RemoveListeners()

    if self.castle.order == 0 then
        self.tabGroup.gameObject:SetActive(false)
        self.tabGroup:ChangeTab(1)
        return
    else
        self.tabGroup.gameObject:SetActive(true)
    end
    self.tabGroup:ChangeTab(self.currnetIndex or 1)
end

function GuildSiegeCheckPlayer:OnHide()
    self:RemoveListeners()
    self.isOpen = false
    if self.currnetIndex ~= nil then
        self.panelList[self.currnetIndex]:Hiden()
        self.currnetIndex = nil
    end
    GuildSiegeManager.Instance.onUpdateStatus:Fire()
end

function GuildSiegeCheckPlayer:RemoveListeners()
end

function GuildSiegeCheckPlayer:ChangeTab(index)
    if self.currnetIndex ~= nil then
        self.panelList[self.currnetIndex]:Hiden()
    end
    self.panelList[index].castle = self.castle
    self.panelList[index]:Show()

    self.currnetIndex = index
    if index == 1 then
        self.main.sizeDelta = Vector2(self.panelList[index].transform.rect.width, self.panelList[index].transform.rect.height + 10)
    end
end

function GuildSiegeCheckPlayer:OnAttack(castle)
    if ((self.model.myCastle or {}).atk_times or 0) == 2 then
        NoticeManager.Instance:FloatTipsByString(TI18N("进攻次数已用完，不能发起进攻"))
        return
    end

    local castleData = DataGuildSiege.data_castle[castle.order]
    local bool = true
    local castle_list = self.model.statusData.guild_match_list[2].castle_list
    for _,order in pairs(castleData.need_check) do
        for i,v in ipairs(castle_list) do
            if order == v.order then
                bool = bool and (v.loss_star == 3)
                break
            end
        end
    end
    if bool == true then
        self.main.gameObject:SetActive(false)
        if self.model.statusData.guild_match_list[1].score >= 100 then
            self.panelList[3]:Show({
                loss_star = 0,
                order = castle.order,
                })
        else
            self.panelList[3]:Show(castle)
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("必须<color='#ffff00'>3星</color>摧毁保护塔才能进攻"))
    end
end

GuildSiegeCheckInfo = GuildSiegeCheckInfo or BaseClass(BasePanel)

function GuildSiegeCheckInfo:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.assetWrapper = assetWrapper

    self.rewardList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.updateListener = function(type, order) self:Update(type, order) end

    self:InitPanel()
end

function GuildSiegeCheckInfo:__delete()
    self.OnHideEvent:Fire()
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.castleExt ~= nil then
        self.castleExt:DeleteMe()
        self.castleExt = nil
    end
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    self.assetWrapper = nil
end

function GuildSiegeCheckInfo:InitPanel()
    local t = self.gameObject.transform
    self.transform = t

    -- 个人信息区域
    self.infoArea = t:Find("Info").gameObject
    self.infoText = t:Find("Info/TimeDesc"):GetComponent(Text)

    self.roleArea = t:Find("RoleInfo").gameObject
    self.roleImage = t:Find("RoleInfo/Head/Icon"):GetComponent(Image)
    self.roleLevBg = t:Find("RoleInfo/Head/LevBg").gameObject
    self.roleLevText = t:Find("RoleInfo/Head/Lev"):GetComponent(Text)
    self.roleNameText = t:Find("RoleInfo/Forces/Name"):GetComponent(Text)
    self.unknownText = t:Find("RoleInfo/Unknow"):GetComponent(Text)
    self.guideList = {}
    self.guideContainer = t:Find("RoleInfo/Forces")
    for i=1,4 do
        self.guideList[i] = {
            gameObject = self.guideContainer:GetChild(i).gameObject,
            icon = self.guideContainer:GetChild(i):Find("Icon"):GetComponent(Image),
        }
    end

    -- 进攻记录区域
    self.attackList = {}
    for i=1,2 do
        local tab = {}
        tab.transform = t:Find("Attach" .. i)
        tab.gameObject = tab.transform.gameObject
        tab.descText = tab.transform:Find("TimeDesc"):GetComponent(Text)
        tab.star1 = tab.transform:Find("Star1"):GetComponent(Image)
        tab.star2 = tab.transform:Find("Star2"):GetComponent(Image)
        tab.star3 = tab.transform:Find("Star3"):GetComponent(Image)
        tab.playBtn = tab.transform:Find("Play"):GetComponent(Button)
        self.attackList[i] = tab
    end

    -- 敌人进攻记录区域
    self.enemyObj = t:Find("Enemy").gameObject
    self.enemyText = t:Find("Enemy/TimeDesc"):GetComponent(Text)
    self.enemyStar1 = t:Find("Enemy/Star1"):GetComponent(Image)
    self.enemyStar2 = t:Find("Enemy/Star2"):GetComponent(Image)
    self.enemyStar3 = t:Find("Enemy/Star3"):GetComponent(Image)
    self.enemyPlayBtn = t:Find("Enemy/Play"):GetComponent(Button)

    self.enemyText.transform.anchoredPosition = Vector2(-56,-1)
    t:Find("Enemy/Sword").anchoredPosition = Vector2(-155,-1)

    -- 发起进攻区域
    self.attackArea = t:Find("AttackArea").gameObject
    self.attackText = t:Find("AttackArea/Button/Text"):GetComponent(Text)
    self.attackBtnImage = t:Find("AttackArea/Button/Image"):GetComponent(Image)
    self.attackBtn = t:Find("AttackArea/Button"):GetComponent(Button)
    self.attackNoticeBtn = t:Find("AttackArea/Notice"):GetComponent(Button)
    self.leftTime = self.attackArea.transform:Find("I18N"):GetComponent(Text)
    self.attackImage = self.attackArea.transform:Find("Image"):GetComponent(Image)
    self.attackBtn.onClick:AddListener(function() self.model:OnAttack(self.castle) end)

    self.line1 = t:Find("Line1").gameObject
    self.line2 = t:Find("Line2").gameObject

    -- 查看城堡区域
    self.castleArea = t:Find("Castle").gameObject
    self.castleImage = t:Find("Castle/Image"):GetComponent(Image)
    self.castleExt = MsgItemExt.New(t:Find("Castle/Text"):GetComponent(Text), 180, 17, 27.7)

    self.layout = LuaBoxLayout.New(t, {axis = BoxLayoutAxis.Y, cspacing = 5, border = 0})

    self.unknownText.text = self.model.unknownString

    -- print(self.model.unknownString)
    -- self:OnOpen()

    self.attackNoticeBtn.onClick:AddListener(function() self:OnNotice() end)
end

function GuildSiegeCheckInfo:Update(type, order)
    if type == self.castle.type and order == self.castle.order then
        self:UpdateForce(self.castle)
        if order ~= nil and order > 0 then
            -- self:ReloadReward()
        end
        self:UpdateInfo()

        self:Reload()
    end
end

function GuildSiegeCheckInfo:OnOpen()
    self:RemoveListeners()
    GuildSiegeManager.Instance.onUpdateCastle:AddListener(self.updateListener)
    GuildSiegeManager.Instance.onUpdateMy:AddListener(self.updateListener)

    self:Update(self.castle.type, self.castle.order)
end

function GuildSiegeCheckInfo:OnHide()
    if self.effTweenId ~= nil then
        Tween.Instance:Cancel(self.effTweenId)
        self.effTweenId = nil
    end
    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end
    self:RemoveListeners()
end

function GuildSiegeCheckInfo:RemoveListeners()
    GuildSiegeManager.Instance.onUpdateMy:RemoveListener(self.updateListener)
    GuildSiegeManager.Instance.onUpdateCastle:RemoveListener(self.updateListener)
end

function GuildSiegeCheckInfo:UpdateForce(castle)
    if castle.type == 1 or castle.can_look == 1 then
        self.roleImage.sprite = PreloadManager.Instance:GetClassesHeadSprite(castle.classes, castle.sex)
        self.roleLevBg.gameObject:SetActive(true)
        self.roleLevText.text = castle.lev
        self.guideContainer.gameObject:SetActive(true)
        self.unknownText.gameObject:SetActive(false)

        for i,v in ipairs(self.guideList) do
            if (castle.guards or {})[i] == nil then
                v.icon.gameObject:SetActive(false)
            else
                v.icon.gameObject:SetActive(true)
                -- print((castle.guards or {})[i].guard_id)
                v.icon.sprite = self.assetWrapper:GetSprite(AssetConfig.guard_head, (castle.guards or {})[i].guard_id or 0)
            end
        end
    else
        self.roleImage.sprite = self.assetWrapper:GetSprite(AssetConfig.arena_textures, "Unknow")
        self.roleLevText.text = ""
        self.roleLevBg.gameObject:SetActive(true)
        self.guideContainer.gameObject:SetActive(false)
        self.unknownText.gameObject:SetActive(true)
    end

    if castle.loss_star == 3 then
        self.castleImage.sprite = self.assetWrapper:GetSprite(AssetConfig.guildsiege, "Destroyed")
        self.attackBtn.gameObject:SetActive(false)
        self.attackImage.gameObject:SetActive(true)
        self.leftTime.gameObject:SetActive(false)

        if self.model.statusData.guild_match_list[1].score >= 100 then
            self.leftTime.gameObject:SetActive(true)
            self.attackImage.gameObject:SetActive(false)
            self.attackBtn.gameObject:SetActive(true)
        end
    else
        self.castleImage.sprite = self.assetWrapper:GetSprite(AssetConfig.guildsiege, "Castle" .. ((DataGuildSiege.data_castle[castle.order] or {}).type or 0))
        self.leftTime.gameObject:SetActive(true)
        self.attackImage.gameObject:SetActive(false)
        self.attackBtn.gameObject:SetActive(true)
        if self.effTimerId == nil then
            self.effTimerId = LuaTimer.Add(1000, 3000, function()
                self.attackBtn.gameObject.transform.localScale = Vector3(1.2,1.1,1)
                if self.effTweenId ~= nil then
                    Tween.Instance:Cancel(self.effTweenId)
                    self.effTweenId = nil
                end
                self.effTweenId = Tween.Instance:Scale(self.attackBtn.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic).id
            end)
        end
    end

    local typeString = TI18N("我方")
    if castle.type == 1 then
        typeString = TI18N("敌方")
    end

    local castleData = DataGuildSiege.data_castle[castle.order] or {}
    if castleData.desc ~= nil and castleData.desc ~= "" then
        self.castleExt:SetData(string.format(TI18N("第<color='#ffff00'>%s</color>号建筑-<color='#ffff00'>%s</color>\n效果:%s"), castle.order, GuildSiegeEumn.CastleType[castleData.type], castleData.desc))
    else
        self.castleExt:SetData(string.format(TI18N("第<color='#ffff00'>%s</color>号建筑-<color='#ffff00'>%s</color>\n效果:被完全摧毁时，\n%s将获得{assets_2,90002}<color='#ffff00'>×3</color>"), castle.order, GuildSiegeEumn.CastleType[castleData.type], typeString))
            self.castleExt.contentTrans:Find("Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guildsiege, "Star")
    end

    local size = self.castleExt.contentTrans.sizeDelta
    self.castleExt.contentTrans.anchoredPosition = Vector2(-20, size.y / 2)

    if size.y + 20 > self.castleArea.transform.sizeDelta.y then
        self.castleArea.transform.sizeDelta = Vector2(self.castleArea.transform.sizeDelta.x, size.y + 20)
    end
end

function GuildSiegeCheckInfo:UpdateInfo()
    if self.castle.is_combat == 0 then
        self.infoText.text = string.format(TI18N("剩余进攻次数<color='#00ff00'>%s/2</color>"), 2 - self.castle.atk_times)
        self.attackText.text = TI18N("进 攻")
        self.attackBtnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "QulifyIcon")
    else
        self.infoText.text = TI18N("")
        self.attackText.text = TI18N("观 战")
        self.attackBtnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "PlayerTips_watchicon")
    end

    local tab = {}
    local enemy = nil
    local roleData = RoleManager.Instance.RoleData

    for i,v in ipairs(self.castle.castle_log or {}) do
        if self.castle.r_id == v.r_id_1 and self.castle.r_plat == v.r_plat_1 and self.castle.r_zone == v.r_zone_1 then
            table.insert(tab, v)
        elseif v.is_win == 1 then
            if enemy == nil or enemy.star < v.star then
                enemy = v
            end
        end
    end
    table.sort(tab, function(a,b) return a.time > b.time end)
    for i=1,2 do self:UpdateAttack(i, tab[i]) end

    if (self.castle.order or 0) > 0 then
        self.roleNameText.text = string.format("%s.%s", self.castle.order, self.castle.name)
    else
        self.roleNameText.text = RoleManager.Instance.RoleData.name
    end

    if enemy == nil then
        if self.castle.def_times == 0 then
            self.enemyText.text = TI18N("<color='#00ff00'>暂未遭到攻击</color>")
        else
            self.enemyText.text = string.format(TI18N("<color='#00ff00'>已防守成功<color='#ffff00'>%s</color>次</color>"), self.castle.def_times)
        end
        for i=1,3 do
            self["enemyStar" .. i].gameObject:SetActive(false)
        end
        self.enemyPlayBtn.gameObject:SetActive(false)
    else
        if self.castle.def_times - self.castle.def_win_times == 0 then
            self.enemyText.text = string.format(TI18N("<color='#00ff00'>已防守成功<color='#ffff00'>%s</color>次</color>"), self.castle.def_times)
        else
            self.enemyText.text = string.format(TI18N("最佳进攻：%s"), BaseUtils.string_cut_utf8(enemy.role_name_1, 15, 12))
        end
        self.enemyPlayBtn.gameObject:SetActive(true)
        for i=1,3 do
            self["enemyStar" .. i].gameObject:SetActive(true)
            if i <= enemy.star then
                self["enemyStar" .. i].sprite = self.assetWrapper:GetSprite(AssetConfig.guildsiege, "Star")
            else
                self["enemyStar" .. i].sprite = self.assetWrapper:GetSprite(AssetConfig.guildsiege, "DarkStar")
            end
        end
        self.enemyPlayBtn.onClick:RemoveAllListeners()
        self.enemyPlayBtn.onClick:AddListener(function() GuildSiegeManager.Instance:send19111(enemy.replay_id, enemy.replay_plat, enemy.replay_zone) end)
    end

    if self.castle.is_combat == 1 then
        self.enemyText.text = TI18N("正在受到攻击，请点击观战")
    end

    if self.castle.is_combat == 0 then
        local time = (self.model.myCastle or {}).atk_times or 0
        if time ~= 2 then
            self.leftTime.text = string.format(TI18N("剩余次数:<color='#ffff00'>%s</color>/2"), 2 - time)
        else
            self.leftTime.text = TI18N("剩余次数:<color='#ff0000'>0</color>/2")
        end
    else
        self.leftTime.text = ""
    end

    if self.castle.order ~= nil and self.castle.order > 0 then
        local castleData = DataGuildSiege.data_castle[self.castle.order]
        if castleData.type ~= 0 then
            if self.effect ~= nil then self.effect:DeleteMe() end
            if castleData.type == 1 then
                self.effect = BibleRewardPanel.ShowEffect(20307, self.castleImage.transform, Vector3(0.625, 0.625, 0.625), Vector3(0, 48, -400))
            elseif castleData.type == 2 then
                self.effect = BibleRewardPanel.ShowEffect(20306, self.castleImage.transform, Vector3(1, 1, 1), Vector3(0, 0, -400))
            elseif castleData.type == 3 then
                self.effect = BibleRewardPanel.ShowEffect(20308, self.castleImage.transform, Vector3(1, 1, 1), Vector3(0, 48, -400))
            end
        else
            if self.effect ~= nil then
                self.effect:SetActive(false)
            end
        end
    else
        if self.effect ~= nil then
            self.effect:SetActive(false)
        end
    end
    
    if self.model.statusData ~= nil and self.model.statusData.guild_match_list ~= nil then 
        self.attackNoticeBtn.gameObject:SetActive(self.castle.type == 2 and (self.castle.loss_star == 3 or self.model.statusData.guild_match_list[1].score >= 100))
    end
end

function GuildSiegeCheckInfo:UpdateAttack(i, data)
    local tab = self.attackList[i]
    if data == nil then
        tab.descText.text = BaseUtils.string_cut_utf8(string.format(TI18N("第%s次进攻:%s"), BaseUtils.NumToChn(i), TI18N("暂无记录")), 11, 15)
        tab.playBtn.gameObject:SetActive(false)
    else
        tab.descText.text = BaseUtils.string_cut_utf8(string.format(TI18N("第%s次进攻:%s"), BaseUtils.NumToChn(i), data.role_name_2), 11, 15)
        tab.playBtn.gameObject:SetActive(true)
    end

    data = data or {star = 0}
    for i=1,3 do
        tab["star" .. i].gameObject:SetActive(i <= data.star)
        if data.is_win == 1 then
            tab["star" .. i].sprite = self.assetWrapper:GetSprite(AssetConfig.guildsiege, "Star")
        else
            tab["star" .. i].sprite = self.assetWrapper:GetSprite(AssetConfig.guildsiege, "DarkStar")
        end
    end

    tab.playBtn.onClick:RemoveAllListeners()
    tab.playBtn.onClick:AddListener(function() self:OnPlay(data.replay_id, data.replay_plat, data.replay_zone) end)
end

function GuildSiegeCheckInfo:Reload()
    self.roleArea.gameObject:SetActive(false)
    self.attackArea.gameObject:SetActive(false)
    self.infoArea.gameObject:SetActive(false)
    self.castleArea.gameObject:SetActive(false)
    self.attackList[1].gameObject:SetActive(false)
    self.attackList[2].gameObject:SetActive(false)
    self.line1.gameObject:SetActive(false)
    self.enemyObj:SetActive(false)

    self.layout:ReSet()

    if self.castle.order == 0 then
        for i,v in ipairs(self.guideList) do
            v.gameObject:SetActive(false)
        end
        self.roleNameText.transform.anchoredPosition = Vector2(0, -20)

        self.layout:AddCell(self.line1)
        self.layout:AddCell(self.attackList[1].gameObject)
        self.layout:AddCell(self.attackList[2].gameObject)
    else
        self.layout:AddCell(self.roleArea)
        for i,v in ipairs(self.guideList) do
            v.gameObject:SetActive(true)
        end
        self.roleNameText.transform.anchoredPosition = Vector2(0, 0)

        self.layout:AddCell(self.castleArea)

        -- if self.castle.type == 2 then
        --     self.layout:AddCell(self.infoArea)
        -- end
    end

    self.layout:AddCell(self.line2)

    if self.castle.order ~= nil and self.castle.order > 0 then
        self.layout:AddCell(self.enemyObj)
    end

    if self.castle.type == 2 then                                   -- 敌方城堡
        self.layout:AddCell(self.attackArea)
    elseif self.castle.type == 1 and self.castle.is_combat == 1 then    -- 己方城堡正遭到攻击
        self.layout:AddCell(self.attackArea)
    end

    self.layout.panelRect.pivot = Vector2(0.5, 1)
    self.layout.panelRect.anchoredPosition = Vector2(0, 0)
end

function GuildSiegeCheckInfo:OnPlay(replay_id, replay_plat, replay_zone)
    GuildSiegeManager.Instance:send19111(replay_id, replay_plat, replay_zone)
end

function GuildSiegeCheckInfo:OnNotice()
    TipsManager.Instance:ShowText({gameObject = self.attackNoticeBtn.gameObject, itemData = {
        TI18N("公会总星数达到<color='#ffff00'>100星</color>时，可再次挑战<color='#ffff00'>已3星摧毁</color>的建筑"),
        }})
end
