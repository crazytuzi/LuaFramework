-- @author 黄耀聪
-- @date 2017年6月19日, 星期一

IngotCrashVote = IngotCrashVote or BaseClass(BaseWindow)

function IngotCrashVote:__init(model)
    self.model = model
    self.name = "IngotCrashVote"
    self.windowId = WindowConfig.WinID.ingot_crash_vote

    self.resList = {
        {file = AssetConfig.ingotcrash_vote, type = AssetType.Main}
        , {file = AssetConfig.ingotcrash_textures, type = AssetType.Dep}
    }

    self.dropFormat = "%s {assets_2,29255}"
    self.descFormat = TI18N("若猜中预计可获得<color='#00ff00'>%s</color>{assets_2,%s}，猜错将返还<color='#00ff00'>%s</color>{assets_2, %s}")
    self.maxSliderLength = 388.5
    self.maxVoteValue = 60
    self.playerList = {}
    self.dropItemList = {}

    self.player1 = {}
    self.player2 = {}

    self.voteListener = function(rid1, platform1, zone_id1, rid2, platform2, zone_id2) self:SetVoteValue(rid1, platform1, zone_id1, rid2, platform2, zone_id2) end
    self.updateListener = function() self:Reload() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function IngotCrashVote:__delete()
    self.OnHideEvent:Fire()
    if self.dropAssetsLoader ~= nil then
        self.dropAssetsLoader:DeleteMe()
        self.dropAssetsLoader = nil
    end
    if self.playerList ~= nil then
        for _,v in pairs(self.playerList) do
            if v.headSlot ~= nil then
                v.headSlot:DeleteMe()
            end
        end
        self.playerList = nil
    end
    if self.dropItemList ~= nil then
        for _,v in pairs(self.dropItemList) do
            if v ~= nil then
                v.assetsLoader:DeleteMe()
            end
        end
        self.dropItemList = nil
    end
    if self.dropLayout ~= nil then
        self.dropLayout:DeleteMe()
        self.dropLayout = nil
    end
    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end
    self:AssetClearAll()
end

function IngotCrashVote:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.ingotcrash_vote))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    local main = t:Find("Main")
    self.titleText = main:Find("Title/Text"):GetComponent(Text)
    self.closeBtn = main:Find("Close"):GetComponent(Button)

    for i=1,2 do
        local tab = {}
        tab.transform = main:Find("Player" .. i)
        tab.gameObject = tab.transform.gameObject
        tab.select = tab.transform:Find("Select").gameObject
        tab.headSlot = HeadSlot.New()
        NumberpadPanel.AddUIChild(tab.transform:Find("Head"), tab.headSlot.gameObject)
        tab.nameText = tab.transform:Find("Name"):GetComponent(Text)
        tab.serverText = tab.transform:Find("Server"):GetComponent(Text)
        tab.btn = tab.transform:GetComponent(Button)
        tab.tick = tab.transform:Find("Toggle/Tick").gameObject
        self.playerList[i] = tab

        tab.select:SetActive(false)
        tab.nameText.text = ""
        tab.serverText.text = ""
        local j = i
        tab.btn.onClick:AddListener(function() if self:CheckLock() then self:ClickToggle(j) end end)
        tab.tick:SetActive(false)
        tab.select:SetActive(false)
    end

    self.sliderRect = main:Find("Slider/Blue")
    self.sliderEffectTrans = main:Find("Slider/Effect")
    self.sliderText1 = main:Find("Slider/Text1"):GetComponent(Text)
    self.sliderText2 = main:Find("Slider/Text2"):GetComponent(Text)

    self.noticeBtn = main:Find("Notice"):GetComponent(Button)

    self.dropBtn = main:Find("Drop"):GetComponent(Button)
    self.dropText = main:Find("Drop/Text"):GetComponent(Text)
    self.dropAssetsLoader = SingleIconLoader.New(main:Find("Drop/Assets").gameObject)
    self.dropArea = main:Find("DropArea")
    self.dropCloner = self.dropArea:Find("Mask/Cloner").gameObject
    self.dropLayout = LuaBoxLayout.New(self.dropArea:Find("Mask/Container"), {axis = BoxLayoutAxis.Y, cspacing = 0, border = 0})
    self.voteBtn = main:Find("Button"):GetComponent(Button)
    self.voteImage = self.voteBtn.gameObject:GetComponent(Image)
    self.voteText = self.voteBtn.transform:Find("Text"):GetComponent(Text)
    self.noticeBtn.gameObject:SetActive(false)

    self.descExt = MsgItemExt.New(main:Find("Text"):GetComponent(Text), 400, 18, 20.85)

    self.dropArea.gameObject:SetActive(false)
    self.noticeBtn.onClick:AddListener(function() self:OnNotice() end)
    self.dropBtn.onClick:AddListener(function() if self:CheckLock() then self:ReloadDropArea() end end)
    self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    self.voteBtn.onClick:AddListener(function() self:OnClick() end)
end

function IngotCrashVote:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function IngotCrashVote:OnOpen()
    self:RemoveListeners()
    IngotCrashManager.Instance.onUpdateInfo:AddListener(self.updateListener)
    IngotCrashManager.Instance.onUpdateVote:AddListener(self.voteListener)

    self.player1 = self.model.best16Tab[self.openArgs.player1]
    self.player2 = self.model.best16Tab[self.openArgs.player2]

    self.winner = nil

    if self.player1 ~= nil and self.player2 ~= nil then
        if (self.player1.is_lose == 0 and self.player2.is_lose == 0)    -- 正常晋级
            or (self.player1.is_lose == 1 and self.player1.lose_round == IngotCrashManager.Instance.max_round - 1
                and self.player2.is_lose == 1 and self.player2.lose_round == IngotCrashManager.Instance.max_round - 1
                and self.player1.rank == 0)     -- 季军赛
            then
            -- 未完成战斗
            if IngotCrashManager.Instance.model.guessTab[BaseUtils.Key(self.player1.rid, self.player1.platform, self.player1.zone_id)] ~= nil
                or IngotCrashManager.Instance.model.guessTab[BaseUtils.Key(self.player2.rid, self.player2.platform, self.player2.zone_id)] ~= nil
                then
                self.isLock = 1     -- 已下注
            else
                self.isLock = 2     -- 未下注
            end
        else
            -- 打完，只能看录像
            self.isLock = 4
        end

        if self.player1.is_lose == 0 and self.player2.is_lose == 1 then
            self.winner = self.player1
        elseif self.player2.is_lose == 0 and self.player1.is_lose == 1 then
            self.winner = self.player2
        else
            if self.player1.lose_round < self.player2.lose_round then
                self.winner = self.player1
            elseif self.player1.lose_round > self.player2.lose_round then
                self.winner = self.player2
            else
                if self.player1.rank < self.player2.rank then
                    self.winner = self.player1
                elseif self.player1.rank > self.player2.rank then
                    self.winner = self.player2
                else
                    self.winner = {}
                end
            end
        end
    else
        self.isLock = 3         -- 人未定
        self.winner = nil
    end
    IngotCrashManager.Instance:send20015(self.player1.rid,self.player1.platform,self.player1.zone_id,self.player2.rid,self.player2.platform,self.player2.zone_id)

    if self.openArgs.type == 1 then -- 十六强
        self.titleText.text = TI18N("16进8")
    elseif self.openArgs.type == 2 then -- 八强
        self.titleText.text = TI18N("8进4")
    elseif self.openArgs.type == 3 then -- 半决赛
        self.titleText.text = TI18N("半决赛")
    elseif self.openArgs.type == 4 then -- 决赛
        self.titleText.text = TI18N("决赛")
    else
        self.titleText.text = TI18N("季军赛")
    end
    self:SetVoteValue(self.player1.rid, self.player1.platform, self.player1.zone_id, self.player2.rid, self.player2.platform, self.player2.zone_id)
    self:ClickValue(1)

    self:Reload()

    if self.model.guessTab[BaseUtils.Key(self.player1.rid, self.player1.platform, self.player1.zone_id)] ~= nil then
        self.lastIndex = 1
    elseif self.model.guessTab[BaseUtils.Key(self.player2.rid, self.player2.platform, self.player2.zone_id)] ~= nil then
        self.lastIndex = 2
    end

    if self.winner == nil and self.lastIndex ~= nil then
        self:ClickToggle(self.lastIndex)
    end

end

function IngotCrashVote:OnHide()
    self:RemoveListeners()
end

function IngotCrashVote:RemoveListeners()
    IngotCrashManager.Instance.onUpdateInfo:RemoveListener(self.updateListener)
    IngotCrashManager.Instance.onUpdateVote:RemoveListener(self.voteListener)
end

function IngotCrashVote:CheckLock()
    if IngotCrashManager.Instance.phase ~= IngotCrashEumn.Phase.Guess then
        if self.winner == nil then
            NoticeManager.Instance:FloatTipsByString(TI18N("比赛进行中"))
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("比赛已结束"))
        end
        return false
    end
    if self.isLock == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("已下注，不能修改{face_1,2}"))
        return false
    elseif self.isLock == 4 then
        NoticeManager.Instance:FloatTipsByString(TI18N("本场比赛已结束，可查看录像{face_1,18}"))
        return false
    elseif self.isLock == 3 then
        NoticeManager.Instance:FloatTipsByString(TI18N("对局双方尚未确定"))
        return false
    end
    return true
end

function IngotCrashVote:SetSlider(value1, value2)
    local value = 0
    local beginValue = 0.2
    if value1 == value2 then
        value = 0.5
    else
        value = beginValue + (1 - 2 * beginValue) * value1 / (value1 + value2)
    end

    self.sliderText1.text = string.format("%s%%", Mathf.Round(value * 100))
    self.sliderText2.text = string.format("%s%%", Mathf.Round((1 - value) * 100))
    self.sliderRect.sizeDelta = Vector2(self.maxSliderLength * value, 22)
    self.sliderEffectTrans.anchoredPosition = Vector2(self.maxSliderLength * value, 0)
end

function IngotCrashVote:ReloadDropArea()
    self.dropCloner:SetActive(false)
    if self.isDrop ~= true then
        self.dropArea.gameObject:SetActive(true)
        self.dropLayout:ReSet()
        for i,v in ipairs(DataGoldLeague.data_grade) do
            local value = BaseUtils.copytab(v)
            if value.type == 90026 then
                value.type = 29255
            end
            local tab = self.dropItemList[i]
            if tab == nil then
                tab = {}
                tab.gameObject = GameObject.Instantiate(self.dropCloner)
                tab.transform = tab.gameObject.transform
                tab.text = tab.transform:Find("Text"):GetComponent(Text)
                tab.assetsLoader = SingleIconLoader.New(tab.transform:Find("Assets").gameObject)
                local j = i
                tab.gameObject:GetComponent(Button).onClick:AddListener(function() self:ClickValue(j) end)
                self.dropItemList[i] = tab
            end
            tab.text.text = value.gold
            if GlobalEumn.CostTypeIconName[value.type] == nil then
                tab.assetsLoader:SetSprite(SingleIconType.Item, DataItem.data_get[value.type].icon)
            else
                tab.assetsLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[value.type]))
            end
            self.dropLayout:AddCell(tab.gameObject)
        end
        for i=#DataGoldLeague.data_grade+1,#self.dropItemList do
            self.dropItemList[i].contentTrans.gameObject:SetActive(false)
        end
        self.isDrop = true
    else
        self.isDrop = false
        self.dropArea.gameObject:SetActive(false)
    end

    self.dropArea.sizeDelta = Vector2(190, 145)
end

function IngotCrashVote:ClickValue(index)
    if index == nil then
        return
    end
    self.selectIndex = index

    local player = self[string.format("player%s", self.lastIndex or 0)]

    local cfgData = DataGoldLeague.data_grade[index]
    if GlobalEumn.CostTypeIconName[cfgData.type] == nil then
        self.dropAssetsLoader:SetSprite(SingleIconType.Item, DataItem.data_get[cfgData.type].icon)
    else
        self.dropAssetsLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[cfgData.type]))
    end
    self.dropText.text = cfgData.gold
    if self.isDrop == true then
        self:ReloadDropArea()
    end

    if player == nil then
        self.descExt:SetData(TI18N("请选择一个玩家"))
        local size = self.descExt.contentTrans.sizeDelta
        self.descExt.contentTrans.anchoredPosition = Vector2(-size.x / 2, -92)
        return
    end
    local sum = ((self.model.guessNumTab[BaseUtils.Key(self.player1.rid, self.player1.platform, self.player1.zone_id)] or {}).num or 0) + ((self.model.guessNumTab[BaseUtils.Key(self.player2.rid, self.player2.platform, self.player2.zone_id)] or {}).num or 0) + DataGoldLeague.data_grade[index].gold
    local goldScale = (((self.model.guessNumTab[BaseUtils.Key(player.rid, player.platform, player.zone_id)] or {}).num or 0) + DataGoldLeague.data_grade[index].gold) / sum

    if goldScale > 0.8 then goldScale = 0.8
    elseif goldScale < 0.2 then goldScale = 0.2
    end

    local odds = 1 / goldScale

    local back = math.ceil(cfgData.gold * odds)
    if cfgData.max_gold ~= 0 then
    --     if back > self.maxVoteValue then back = self.maxVoteValue end
    -- else
        if back > cfgData.max_gold then back = cfgData.max_gold end
    end

    if self.lastIndex ~= nil then
        self.descExt:SetData(string.format(self.descFormat, back, cfgData.type, cfgData.gold * 0.5, cfgData.cacl_type))
    else
        self.descExt:SetData(TI18N("请选择一个玩家"))
    end
    local size = self.descExt.contentTrans.sizeDelta
    self.descExt.contentTrans.anchoredPosition = Vector2(-size.x / 2, -92)
end

function IngotCrashVote:OnNotice()
    TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = {"哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈"}})
end

function IngotCrashVote:ClickToggle(index)
    if self.lastIndex ~= nil then
        self.playerList[self.lastIndex].tick:SetActive(false)
        self.playerList[self.lastIndex].select:SetActive(false)
    end
    self.playerList[index].tick:SetActive(true)
    self.playerList[index].select:SetActive(true)
    self.lastIndex = index

    self:ClickValue(self.selectIndex)
end

function IngotCrashVote:SetPlayer(data, index)
    local player = self.playerList[index]

    if data == nil then
        player.headSlot:SetMystery()
        player.nameText.text = TI18N("神秘高手")
    else
        player.headSlot:SetAll({id = data.rid, platform = data.platform, zone_id = data.zone_id, classes = data.classes, sex = data.sex}, {isSmall = true})
        player.nameText.text = data.name
    end
    player.serverText.text = BaseUtils.GetServerName(data.platform, data.zone_id)
end

function IngotCrashVote:SetVoteValue(rid1, platform1, zone_id1, rid2, platform2, zone_id2)
    if self.player1.rid == rid1 and self.player1.platform == platform1 and self.player1.zone_id == zone_id1
        and self.player2.rid == rid2 and self.player2.platform == platform2 and self.player2.zone_id == zone_id2
        then
        self:SetSlider((self.model.guessNumTab[BaseUtils.Key(rid1, platform1, zone_id1)] or {}).num or 0, (self.model.guessNumTab[BaseUtils.Key(rid2, platform2, zone_id2)] or {}).num or 0)
    end
end

function IngotCrashVote:OnClick()
    self.player1 = self.model.best16Tab[self.player1.pos]
    self.player2 = self.model.best16Tab[self.player2.pos]
    if self.isLock == 1 then
        if IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Guess then
        elseif self.player1.is_combat > 0 then
            IngotCrashManager.Instance:send20010(self.player1.rid, self.player1.platform, self.player1.zone_id)
            WindowManager.Instance:CloseWindow(self, false)
        else
            -- 录像
            IngotCrashManager.Instance:send20027(self.player1.rid, self.player1.platform, self.player1.zone_id, self.player2.rid, self.player2.platform, self.player2.zone_id)
            WindowManager.Instance:CloseWindow(self, false)
        end
    elseif self.isLock == 2 then
        if IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Guess then
            self:OnVote()
        elseif self.player1.is_combat > 0 then
            IngotCrashManager.Instance:send20010(self.player1.rid, self.player1.platform, self.player1.zone_id)
            WindowManager.Instance:CloseWindow(self, false)
        else
            -- 录像
            IngotCrashManager.Instance:send20027(self.player1.rid, self.player1.platform, self.player1.zone_id, self.player2.rid, self.player2.platform, self.player2.zone_id)
            WindowManager.Instance:CloseWindow(self, false)
        end
    elseif self.isLock == 3 then
    elseif self.isLock == 4 then
        IngotCrashManager.Instance:send20027(self.player1.rid, self.player1.platform, self.player1.zone_id, self.player2.rid, self.player2.platform, self.player2.zone_id)
        WindowManager.Instance:CloseWindow(self, false)
    end
end

function IngotCrashVote:Reload()
    if self.isLock == 1 then
        -- 已下注
        if IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Guess then
            self.voteImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            self.voteText.color = ColorHelper.DefaultButton4
            self.voteText.text = TI18N("已下注")
        elseif self.player1.is_combat == 1 then
            self.voteImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            self.voteText.color = ColorHelper.DefaultButton2
            self.voteText.text = TI18N("准备中")
            self.descExt:SetData(TI18N("比赛即将开始！"))
        elseif self.player1.is_combat == 2 then
            self.voteImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            self.voteText.color = ColorHelper.DefaultButton2
            self.voteText.text = TI18N("观 战")
            self.descExt:SetData(TI18N("比赛进行中，可观战"))
        else
            self.voteImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
            self.voteText.color = ColorHelper.DefaultButton1
            self.voteText.text = TI18N("录 像")
        end
    elseif self.isLock == 2 then
        -- 未下注
        if IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Guess then
            self.voteImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            self.voteText.color = ColorHelper.DefaultButton3
            self.voteText.text = TI18N("下 注")
        elseif self.player1.is_combat == 1 then
            self.voteImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            self.voteText.color = ColorHelper.DefaultButton2
            self.voteText.text = TI18N("准备中")
            self.descExt:SetData(TI18N("比赛即将开始！"))
        elseif self.player1.is_combat == 2 then
            self.voteImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            self.voteText.color = ColorHelper.DefaultButton2
            self.voteText.text = TI18N("观 战")
            self.descExt:SetData(TI18N("比赛进行中，可观战"))
        else
            self.voteImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
            self.voteText.color = ColorHelper.DefaultButton1
            self.voteText.text = TI18N("录 像")
        end
    elseif self.isLock == 4 then
        self.voteImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        self.voteText.color = ColorHelper.DefaultButton1
        self.voteText.text = TI18N("录 像")
        self.descExt:SetData(string.format(TI18N("本场比赛已结束，恭喜<color='#00ffff'>%s</color>获胜"), self.winner.name or ""))
    elseif self.isLock == 3 then
        self.voteImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.voteText.color = ColorHelper.DefaultButton4
        self.voteText.text = TI18N("等待对手")
    end


    local size = self.descExt.contentTrans.sizeDelta
    self.descExt.contentTrans.anchoredPosition = Vector2(-size.x / 2, -92)

    self:SetPlayer(self.player1, 1)
    self:SetPlayer(self.player2, 2)
end

function IngotCrashVote:OnVote()
    if self.model.guessTab[BaseUtils.Key(self.player1.rid, self.player1.platform, self.player1.zone_id)] ~= nil or self.model.guessTab[BaseUtils.Key(self.player1.rid, self.player1.platform, self.player1.zone_id)] ~= nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("已下注，不能修改哦{face_1,2}"))
        return
    end

    if self.lastIndex == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择一个玩家"))
        return
    end

    if self.selectIndex == nil then
        return
    end

    local player = self["player" .. self.lastIndex]

    local confirmData = NoticeConfirmData.New()
    confirmData.content = string.format(TI18N("是否确认下注<color='#ffff00'>%s</color>{assets_2,%s}支持 <color='#00ffff'>%s</color>？"), DataGoldLeague.data_grade[self.selectIndex].gold, DataGoldLeague.data_grade[self.selectIndex].type, player.name)
    confirmData.sureCallback = function() IngotCrashManager.Instance:send20016(player.rid, player.platform, player.zone_id, self.selectIndex) end
    NoticeManager.Instance:ConfirmTips(confirmData)
end

