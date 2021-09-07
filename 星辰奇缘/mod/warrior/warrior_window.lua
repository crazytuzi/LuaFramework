WarriorWindow = WarriorWindow or BaseClass(BaseWindow)

function WarriorWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.warrior_window
    self.cacheMode = CacheMode.Visible
    self.resList = {
        {file = AssetConfig.warriorRankWindow, type = AssetType.Main}
        , {file = AssetConfig.warrior_textures, type = AssetType.Dep}
        , {file = AssetConfig.heads, type = AssetType.Dep}
    }
    self.warriorObjList = {}
    self.openListener = function() self:OnOpen() end
    self.OnOpenEvent:AddListener(self.openListener)
end

function WarriorWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.warriorRankWindow))
    self.gameObject.name = "WarriorRankWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    local main = self.gameObject.transform:Find("Main")

    self.vScroll = main:Find("RankPanel/Scroll"):GetComponent(RectTransform)
    self.cloner = main:Find("RankPanel/Scroll/Container/Cloner").gameObject
    self.cloner:SetActive(false)
    main:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function()
        self:OnClose()
    end)

    self.score1Text = main:Find("Title/Group1/Score1"):GetComponent(Text)
    self.score2Text = main:Find("Title/Group2/Score2"):GetComponent(Text)
    self.vic1Obj = main:Find("Title/Group1/Vic").gameObject
    self.vic2Obj = main:Find("Title/Group2/Vic").gameObject
    self.myRankText = main:Find("MyData/MyRank"):GetComponent(Text)
    self.myScoreText = main:Find("MyData/MyScore"):GetComponent(Text)

    self.score1Text.text = tostring(self.model.score1)
    self.score2Text.text = tostring(self.model.score2)
    self.myCamp1Obj = main:Find("Title/Group1/MyCamp").gameObject
    self.myCamp2Obj = main:Find("Title/Group2/MyCamp").gameObject
    self.myRankText.text = TI18N("我的排名:")..tostring(self.model.rank)
    self.myScoreText.text = TI18N("我的功勋:")..tostring(self.model.score)

    self.nothing = main:Find("RankPanel/Nothing").gameObject
    self.questionBtn = main:Find("Question"):GetComponent(Button)
    self.questionBtn.transform:Find("Text"):GetComponent(Text).text = TI18N("排名奖励")

    self.exit = main:Find("MyData/Button"):GetComponent(Button)
    self.exit.gameObject:SetActive(false)
    self.exit.onClick:RemoveAllListeners()
    self.exit.onClick:AddListener(function()
        self:OnClose()
    end)

    local helpBtn = main:Find("RankPanel/Title/I18N_TextHelp/Button"):GetComponent(Button)
    helpBtn.onClick:RemoveAllListeners()
    helpBtn.onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = helpBtn.gameObject, itemData = {
            TI18N("1.圣剑可增强攻击、定时获得功勋")
            , TI18N("2.战斗胜利可夺取对方的圣剑")
        }})
    end)

    if self.model.phase > 4 then
        if self.model.score1 > self.model.score2 then
            self.vic1Obj:SetActive(true)
            self.vic2Obj:SetActive(false)
        elseif self.model.score1 < self.model.score2 then
            self.vic1Obj:SetActive(false)
            self.vic2Obj:SetActive(true)
        else
            self.vic1Obj:SetActive(false)
            self.vic2Obj:SetActive(false)
        end
    end

    local datalist = self.model.rankList

    if datalist == nil then
        datalist = {}
    end

    local roledata = RoleManager.Instance.RoleData
    for i=1,#datalist do
        if roledata.id == datalist[i].id and roledata.zone_id == datalist[i].zone_id and roledata.platform == datalist[i].platform then
            if datalist[i].camp == 1 then
                self.myCamp1Obj:SetActive(true)
                self.myCamp2Obj:SetActive(false)
            elseif datalist[i].camp == 2 then
                self.myCamp2Obj:SetActive(true)
                self.myCamp1Obj:SetActive(false)
            end
            break
        end
    end

    if self.boxYLayout == nil then
        self.boxYLayout = LuaBoxLayout.New(main:Find("RankPanel/Scroll/Container").gameObject, {cspacing = 0, axis = BoxLayoutAxis.Y, scrollRect = self.vScroll})
    end

    self.questionBtn.onClick:AddListener(function() TipsManager.Instance:ShowItem({gameObject = self.questionBtn.gameObject, itemData = DataItem.data_get[21160], extra = {nobutton = true}}) end)

    self.OnOpenEvent:Fire()
end

function WarriorWindow:OnOpen()
    if self.openArgs ~= nil and #self.openArgs > 0 then
        self.exit.gameObject:SetActive(true)
        self.questionBtn.gameObject:SetActive(false)
    else
        self.exit.gameObject:SetActive(false)
        self.questionBtn.gameObject:SetActive(true)
    end

    self.score1Text.text = tostring(self.model.score1)
    self.score2Text.text = tostring(self.model.score2)
    self.myRankText.text = TI18N("我的排名:")..tostring(self.model.rank)
    self.myScoreText.text = TI18N("我的功勋:")..tostring(self.model.score)

    WarriorManager.Instance:send14208(function()
        LuaTimer.Add(50, function() if WarriorManager.Instance.model.warriorWin ~= nil then self:Update() end end)
    end)

    local title = self.transform:Find("Main/RankPanel/Title")
    if self.model.mode == 1 then
        title:GetChild(5).gameObject:SetActive(true)
        title:GetChild(6).anchoredPosition = Vector2(218.2, 0)
        title:GetChild(7).anchoredPosition = Vector2(571.6, 0)
    else
        title:GetChild(5).gameObject:SetActive(false)
        title:GetChild(6).anchoredPosition = Vector2(161.44, 0)
        title:GetChild(7).anchoredPosition = Vector2(540.3, 0)
    end
end

function WarriorWindow:__delete()
    if self.boxYLayout ~= nil then
        self.boxYLayout:DeleteMe()
        self.boxYLayout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function WarriorWindow:Update()
    local datalist = self.model.rankList

    if datalist == nil then
        datalist = {}
    end
    table.sort(datalist, function(a, b)
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

    local length = #datalist
    for i=1,length do
        if self.warriorObjList[i] == nil then
            self.warriorObjList[i] = GameObject.Instantiate(self.cloner)
            self.warriorObjList[i].name = tostring(i)
            self.warriorObjList[i]:SetActive(true)
            self.boxYLayout:AddCell(self.warriorObjList[i])
        end
        self:SetItem(datalist[i], self.warriorObjList[i], i)
    end
    for i=length + 1, #self.warriorObjList do
        self.warriorObjList[i]:SetActive(false)
    end
    local rect = self.gameObject.transform:Find("Main/RankPanel/Scroll/Container"):GetComponent(RectTransform)
    rect.sizeDelta = Vector2(608, 46 * length)
    rect.anchoredPosition = Vector2.zero
    self.boxYLayout:OnScroll(rect.sizeDelta, Vector2.zero)
    self.myRankText.text = TI18N("我的排名:")..tostring(self.model.rank)
    self.myScoreText.text = TI18N("我的功勋:")..tostring(self.model.score)

    self.nothing:SetActive(length == 0)
end

function WarriorWindow:SetItem(data, obj, index)
    local t = obj.transform
    local bgImage = t:Find("Bg"):GetComponent(Image)
    local groupImage = t:Find("Group"):GetComponent(Image)
    local rankText = t:Find("Rank"):GetComponent(Text)
    local headImage = t:Find("Player/HeadBg/Image"):GetComponent(Image)
    local nameText = t:Find("Player/Name"):GetComponent(Text)
    local jobText = t:Find("Job"):GetComponent(Text)
    local artifactImage = t:Find("Artifact"):GetComponent(Image)
    local artifactTextObj = t:Find("Text").gameObject
    local reviveTimesText = t:Find("Times"):GetComponent(Text)
    local scoreText = t:Find("Scores"):GetComponent(Text)
    local vicNumText = t:Find("VicNum"):GetComponent(Text)
    local hightlightObj = t:Find("HighLight").gameObject

    if index % 2 == 1 then
        bgImage.color = ColorHelper.ListItem1
    else
        bgImage.color = ColorHelper.ListItem2
    end
    rankText.text = tostring(index)
    scoreText.text = tostring(data.score)
    jobText.text = KvData.classes_name[data.classes]
    groupImage.sprite = self.assetWrapper:GetSprite(AssetConfig.warrior_textures, "Group"..data.camp)
    headImage.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex)
    nameText.text = data.name
    if data.revive == 0 then
        reviveTimesText.text = tostring(data.revive)
    else
        reviveTimesText.text = tostring(data.revive - 1)
    end
    vicNumText.text = tostring(data.kill)
    local button = obj:GetComponent(Button)

    button.onClick:RemoveAllListeners()
    button.onClick:AddListener(function()
        if self.lastIndex ~= nil then
            self.warriorObjList[self.lastIndex].transform:Find("Select").gameObject:SetActive(false)
        end
        self.lastIndex = index
        self.warriorObjList[self.lastIndex].transform:Find("Select").gameObject:SetActive(true)
    end)

    if self.model.mode == 1 then
        if data.magic_buff == nil or #data.magic_buff == 0 then
            artifactImage.gameObject:SetActive(false)
            artifactTextObj:SetActive(true)
        elseif #data.magic_buff == 1 then
            artifactImage.gameObject:SetActive(true)
            artifactTextObj:SetActive(false)
            artifactImage.sprite = self.assetWrapper:GetSprite(AssetConfig.warrior_textures, tostring(data.magic_buff[1].buff_id))
        elseif #data.magic_buff == 2 then
            artifactImage.gameObject:SetActive(false)
            artifactTextObj:SetActive(false)

            for i=1,2 do
                self["artifact"..i.."Image"].sprite = self.assetWrapper:GetSprite(AssetConfig.warrior_textures, tostring(data.magic_buff[i].buff_id))
            end
        end
        reviveTimesText.transform.anchoredPosition = Vector2(219.3, 0)
        scoreText.transform.anchoredPosition = Vector2(262.4, 0)
    else
        artifactImage.gameObject:SetActive(false)
        artifactTextObj.gameObject:SetActive(false)
        reviveTimesText.transform.anchoredPosition = Vector2(156.5, 0)
        scoreText.transform.anchoredPosition = Vector2(234.1, 0)
    end

    local roledata = RoleManager.Instance.RoleData
    obj.transform:Find("Select").gameObject:SetActive(false)
    if roledata.id == data.id and roledata.zone_id == data.zone_id and roledata.platform == data.platform then
        self.model.rank = index
        self.model.score = data.score
        hightlightObj:SetActive(true)
    else
        hightlightObj:SetActive(false)
    end
end

function WarriorWindow:__DoClickPanel()
    if self.gameObject ~= nil then
        local panel = self.gameObject.transform:FindChild("Panel")
        if panel ~= nil then
            local panelBut = panel:GetComponent(Button)
            if panelBut ~= nil then
                local onClick = function()
                    self:OnClose()
                end
                panelBut.onClick:AddListener(onClick)
            end
        end
    end
end

function WarriorWindow:OnClose()
    if self.openArgs ~= nil and self.openArgs[1] ~= nil then
        self.model:Close()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.warrior_settle_window, {self.openArgs[1], self.model.revive})
    else
        self.model:Close()
    end
end
