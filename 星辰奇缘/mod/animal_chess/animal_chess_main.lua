-- @author 黄耀聪
-- @date 2017年4月27日

AnimalChessMain = AnimalChessMain or BaseClass(BasePanel)

function AnimalChessMain:__init(model)
    self.model = model
    self.name = "AnimalChessMain"

    self.model.selectPath = self.model.selectPath or "prefabs/effect/30002.unity3d"
    self.originGridPos = Vector2(3, -118.5)
    self.originShowDelta = Vector2(240, 0)

    self.resList = {
        {file = AssetConfig.animal_chess_main, type = AssetType.Main},
        {file = AssetConfig.animal_chess_bg, type = AssetType.Main},
        {file = AssetConfig.animal_chess_textures, type = AssetType.Dep},
        {file = AssetConfig.mainui_textures, type = AssetType.Dep},
    }

    if BaseUtils.IsWideScreen() then
        table.insert(self.resList, {file = AssetConfig.animal_chess_left, type = AssetType.Main})
        table.insert(self.resList, {file = AssetConfig.animal_chess_right, type = AssetType.Main})
    end

    self.chessTab = {{}, {}, {}, {}, {}, {}}

    self.mainUIButtonList = {}
    self.systemBtnList = {
        {id = 18, showFunc = function() return true end, clickFunc = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.market) end, res = "I18NMarketButtonIcon"},     -- 市场
        {id = 6, showFunc = function() return true end, clickFunc = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop) end, res = "I18NShopButtonIcon"},      -- 商城
        {id = 14, showFunc = function() return true end, clickFunc = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.agendamain) end, res = "I18NAgenda"},     -- 日程
        {id = 17, showFunc = function() return true end, clickFunc = function() ImproveManager.Instance.model:OpenMyWindow() end, res = "I18NUpgradeButtonIcon"},     -- 提升
        {id = 8, showFunc = function() return true end, clickFunc = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.setting_window) end, res = "I18NSettingsButtonIcon2"},      -- 设置
        {id = 28, showFunc = function() return true end, clickFunc = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.arena_window) end, res = "I18NArenaButtonIcon"},     -- 竞技场
        {id = 29, showFunc = function() return true end, clickFunc = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.autofarmwin) end, res = "I18NHandupButtonIcon"},     -- 挂机
        {id = 37, showFunc = function() return true end, clickFunc = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.reward_back_window) end, res = "I18NRewardBackButton"},     -- 奖励找回
        {id = 107, showFunc = function() return not FirstRechargeManager.Instance:isHadDoFirstRecharge() end, clickFunc = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.firstrecharge_window) end},    -- 首充
    }

    self.mainUIButtonListRightDown = {}
    self.systemBtnListRightDown = {
        {id = 22, showFunc = function() return true end, clickFunc = function()
            -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.biblemain)
            AnimalChessManager.Instance:InitChess()
        end, res = "I18NRewards"},     -- 市场
        {id = 2, showFunc = function() return true end, clickFunc = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guildinfowindow) end, res = "I18NGuildButtonIcon"},      -- 公会
        {id = 1, showFunc = function() return true end, clickFunc = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.backpack) end, res = "I18NBackpackButtonIcon"},     -- 背包
    }

    self.controllor = AnimalChessControllor.New(self.model)

    self.updateListener = function(type, coordinate1, coordinate2) self:Update(type, coordinate1, coordinate2) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function AnimalChessMain:__delete()
    self.OnHideEvent:Fire()
    if self.numList ~= nil then
        for _,num in pairs(self.numList) do
            if num ~= nil then
                num.sprite = nil
            end
        end
    end
    if self.mainuiIconLayout ~= nil then
        self.mainuiIconLayout:DeleteMe()
        self.mainuiIconLayout = nil
    end
    if self.rolePreview ~= nil then
        self.rolePreview:DeleteMe()
        self.rolePreview = nil
    end
    if self.enemyPreview ~= nil then
        self.enemyPreview:DeleteMe()
        self.enemyPreview = nil
    end
    if self.chessBoard ~= nil then
        self.chessBoard:DeleteMe()
        self.chessBoard = nil
    end
    if self.controllor ~= nil then
        self.controllor:DeleteMe()
        self.controllor = nil
    end
    if self.roleInfo ~= nil then
        self.roleInfo:DeleteMe()
        self.roleInfo = nil
    end
    if self.enemyInfo ~= nil then
        self.enemyInfo:DeleteMe()
        self.enemyInfo = nil
    end
    if self.roleTurnEffect ~= nil then
        self.roleTurnEffect:DeleteMe()
        self.roleTurnEffect = nil
    end
    if self.enemyTurnEffect ~= nil then
        self.enemyTurnEffect:DeleteMe()
        self.enemyTurnEffect = nil
    end
    if self.chessTab ~= nil then
        for _,list in pairs(self.chessTab) do
            if list ~= nil then
                for _,item in pairs(list) do
                    if item ~= nil then
                        item:DeleteMe()
                    end
                end
            end
        end
    end
    self:AssetClearAll()
end

function AnimalChessMain:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.animal_chess_main))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    t.localPosition = Vector3(0, 0, 800)

    local main = t:Find("Main")
    self.chessArea = main:Find("InfoArea/CheckArea")
    local showArea = main:Find("InfoArea/ShowArea")
    local clickArea = main:Find("InfoArea/ClickArea")
    self.followArea = main:Find("InfoArea/FollowArea")

    self.chessArea.anchoredPosition = Vector2(-18,-17)
    self.chessArea.sizeDelta = Vector2(994,495)

    self.gameObject:GetComponent(Canvas).overrideSorting = true

    local bg = GameObject.Instantiate(self:GetPrefab(AssetConfig.animal_chess_bg))
    UIUtils.AddBigbg(main:Find("Bg"), bg)
    bg.transform.anchorMax = Vector2(0.5, 0.5)
    bg.transform.anchorMin = Vector2(0.5, 0.5)
    bg.transform.pivot = Vector2(0.5, 0.5)
    bg.transform.anchoredPosition = Vector2.zero

    local x = nil
    local y = nil
    for i=1,36 do
        x = math.ceil(i / 6)
        y = (i - 1) % 6 + 1
        self.chessTab[x][y] = AnimalChessItem.New(self.model, clickArea:GetChild(36 - i).gameObject)
        self.chessTab[x][y].image = showArea:GetChild(36 - i):GetComponent(Image)
        self.chessTab[x][y].x = x
        self.chessTab[x][y].y = y
        self.model.positionTab[x][y] = Vector3(self.chessTab[x][y].transform.anchoredPosition.x, self.chessTab[x][y].transform.anchoredPosition.y - 3, -800 + 60 * (x + y))
        local x1 = x
        local y1 = y
        self.chessTab[x][y].button.onClick:AddListener(function() self:OnClick(x1, y1) end)
    end

    self.model.xNormalVector3 = self.model.positionTab[6][1] - self.model.positionTab[1][1]
    self.model.normalVector3 = Vector3.Cross(self.model.positionTab[6][1] - self.model.positionTab[1][1], self.model.positionTab[1][6] - self.model.positionTab[1][1])
    self.model.quaternion = Quaternion.FromToRotation(Vector3(0, 1, 0),self.model.normalVector3.normalized)

    for x=1,6 do
        for y=1,6 do
            self.chessTab[x][y].next[1] = self.chessTab[x][y + 1]
            self.chessTab[x][y].next[2] = self.chessTab[x][y - 1]
            self.chessTab[x][y].next[3] = (self.chessTab[x - 1] or {})[y]
            self.chessTab[x][y].next[4] = (self.chessTab[x + 1] or {})[y]
        end
    end

    self.titleText = t:Find("Main/Title/Text"):GetComponent(Text)

    self.showBtn = t:Find("Main/InfoArea/Show"):GetComponent(Button)
    self.showBtn.onClick:AddListener(function() self:ShowMainUIIcon() end)
    self.mainuiIconArea = t:Find("Main/InfoArea/MainUIButtonGrid").gameObject
    self.buttonGrid = t:Find("Main/InfoArea/MainUIButtonGrid/Scroll/Container")
    self.buttonCloner = t:Find("Main/InfoArea/MainUIButtonGrid/Scroll/Container/Button").gameObject
    self.buttonCloner:SetActive(false)

    self.enemyPreviewContainer = t:Find("Main/Enemy")
    self.rolePreviewContainer = t:Find("Main/Role")
    self.roleText1 = self.rolePreviewContainer:GetChild(0):GetComponent(Text)
    self.roleText2 = self.rolePreviewContainer:GetChild(1):GetComponent(Text)
    self.roleText3 = self.rolePreviewContainer:GetChild(2):GetComponent(Text)
    self.roleText4 = self.rolePreviewContainer:GetChild(3):GetComponent(Text)
    self.enemyText1 = self.enemyPreviewContainer:GetChild(0):GetComponent(Text)
    self.enemyText2 = self.enemyPreviewContainer:GetChild(1):GetComponent(Text)
    self.enemyText3 = self.enemyPreviewContainer:GetChild(2):GetComponent(Text)
    self.enemyText4 = self.enemyPreviewContainer:GetChild(3):GetComponent(Text)

    self.mainuiIconRightDown = t:Find("Main/InfoArea/MainUIButtonLayout")
    self.mainuiIconLayout = LuaBoxLayout.New(t:Find("Main/InfoArea/MainUIButtonLayout/Container"), {axis = BoxLayoutAxis.X, cspacing = 0, border = 0})

    self.countDownContainer = t:Find("Main/CountDown")
    self.numList = {}
    for i=1,3 do
        self.numList[i] = self.countDownContainer:GetChild(i - 1):GetComponent(Image)
    end

    self.chessBoard = AnimalChessBoard.New(self.model, self.controllor, self.chessArea, self.followArea, self.assetWrapper)

    self.chessArea.gameObject:SetActive(true)

    self.roleInfo = AnimalChessRole.New(t:Find("Main/InfoArea/Role").gameObject, self.assetWrapper)
    self.enemyInfo = AnimalChessRole.New(t:Find("Main/InfoArea/Enemy").gameObject, self.assetWrapper)

    self.enemyInfo.statusImage.gameObject:SetActive(false)
    self.mainuiIconRightDown.gameObject:SetActive(false)

    self:AdaptIPhoneX()
    if BaseUtils.IsWideScreen() then
        self:LoadAssetsWideScreen()
    end
end

function AnimalChessMain:OnInitCompleted()
    self.assetWrapper:ClearMainAsset()
    self.OnOpenEvent:Fire()
end

function AnimalChessMain:OnOpen()
    self:RemoveListeners()
    AnimalChessManager.Instance.onChessEvent:AddListener(self.updateListener)

    self:ReloadMainUIIconRightDown()

    self:SetNum(0)
    self:ShowMainUIIcon()

    if MainUIManager.Instance.mapInfoView ~= nil and not BaseUtils.isnull(MainUIManager.Instance.mapInfoView.gameObject) then
        MainUIManager.Instance.mapInfoView.gameObject:SetActive(false)
    end
    if MainUIManager.Instance.roleInfoView ~= nil and not BaseUtils.isnull(MainUIManager.Instance.roleInfoView.gameObject) then
        MainUIManager.Instance.roleInfoView.gameObject:SetActive(false)
    end
    if MainUIManager.Instance.petInfoView ~= nil and not BaseUtils.isnull(MainUIManager.Instance.petInfoView.gameObject) then
        MainUIManager.Instance.petInfoView.gameObject:SetActive(false)
    end
    if MainUIManager.Instance.MainUIIconView ~= nil and not BaseUtils.isnull(MainUIManager.Instance.MainUIIconView.gameObject) then
        MainUIManager.Instance.MainUIIconView.gameObject:SetActive(false)
    end

    if AnimalChessManager.Instance.simulate then
        if self.model.chessLastTab == nil then
            AnimalChessManager.Instance:InitChess()
        else
            self:Update()
        end
    else
        self:Update()
    end

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 200, function() self:OnTime() end)
    end

    self:UpdatePreview()
end

function AnimalChessMain:OnHide()
    self:RemoveListeners()
    if self.moveTweenId ~= nil then
        Tween.Instance:Cancel(self.moveTweenId)
        self.moveTweenId = nil
    end
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.rolePreview ~= nil then
        self.rolePreview:Hide()
    end
    if self.enemyPreview ~= nil then
        self.enemyPreview:Hide()
    end


    if MainUIManager.Instance.mapInfoView ~= nil and not BaseUtils.isnull(MainUIManager.Instance.mapInfoView.gameObject) then
        MainUIManager.Instance.mapInfoView.gameObject:SetActive(true)
    end
    if MainUIManager.Instance.roleInfoView ~= nil and not BaseUtils.isnull(MainUIManager.Instance.roleInfoView.gameObject) then
        MainUIManager.Instance.roleInfoView.gameObject:SetActive(true)
    end
    if MainUIManager.Instance.petInfoView ~= nil and not BaseUtils.isnull(MainUIManager.Instance.petInfoView.gameObject) then
        MainUIManager.Instance.petInfoView.gameObject:SetActive(true)
    end
    if MainUIManager.Instance.MainUIIconView ~= nil and not BaseUtils.isnull(MainUIManager.Instance.MainUIIconView.gameObject) then
        MainUIManager.Instance.MainUIIconView.gameObject:SetActive(true)
    end
end

function AnimalChessMain:RemoveListeners()
    AnimalChessManager.Instance.onChessEvent:RemoveListener(self.updateListener)
end

function AnimalChessMain:ReloadMainUIIcon()
    for i,v in ipairs(self.systemBtnList) do
        local btn = self.mainUIButtonList[i]
        if btn == nil then
            btn = {}
            btn.gameObject = GameObject.Instantiate(self.buttonCloner)
            btn.transform = btn.gameObject.transform
            btn.transform:SetParent(self.buttonGrid)
            btn.transform.localScale = Vector3.one
            if DataSystem.data_icon[v.id] ~= nil then
                btn.gameObject:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.mainui_textures, v.res)
            elseif DataSystem.data_daily_icon[v.id] ~= nil then
                btn.gameObject:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.mainui_textures, DataSystem.data_daily_icon[v.id].res_name)
            end
            local func = v.clickFunc
            btn.gameObject:GetComponent(Button).onClick:AddListener(function() self:ShowMainUIIcon() func() end)
            self.mainUIButtonList[i] = btn
        end
        if DataSystem.data_icon[v.id] ~= nil then
            btn.gameObject:SetActive(RoleManager.Instance.RoleData.lev >= DataSystem.data_icon[v.id].lev and v.showFunc())
        else
            btn.gameObject:SetActive(v.showFunc())
        end
    end
end

function AnimalChessMain:ShowMainUIIcon()
    self.isShowMainUIIcon = self.isShowMainUIIcon or false
    self.mainuiIconArea:SetActive(self.isShowMainUIIcon)
    if self.isShowMainUIIcon then
        self.showBtn.transform.anchoredPosition = Vector2(20,-130) + self.originShowDelta
        self.showBtn.transform.localScale = Vector3(-1, 1, 1)
        self:ReloadMainUIIcon()
    else
        self.showBtn.transform.anchoredPosition = Vector2(20,-130)
        self.showBtn.transform.localScale = Vector3.one
    end
    self.isShowMainUIIcon = not self.isShowMainUIIcon
end

function AnimalChessMain:ReloadMainUIIconRightDown()
    for i,v in ipairs(self.systemBtnListRightDown) do
        local btn = self.mainUIButtonListRightDown[i]
        if btn == nil then
            btn = {}
            btn.gameObject = GameObject.Instantiate(self.buttonCloner)
            btn.gameObject.transform.sizeDelta = Vector2(72, 72)
            self.mainuiIconLayout:AddCell(btn.gameObject)
            if DataSystem.data_icon[v.id] ~= nil then
                btn.gameObject:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.mainui_textures, v.res)
            elseif DataSystem.data_daily_icon[v.id] ~= nil then
                btn.gameObject:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.mainui_textures, DataSystem.data_daily_icon[v.id].res_name)
            end
            local func = v.clickFunc
            btn.gameObject:GetComponent(Button).onClick:AddListener(function() self:ShowMainUIIcon() func() end)
            self.mainUIButtonList[i] = btn
        end
        if DataSystem.data_icon[v.id] ~= nil then
            btn.gameObject:SetActive(RoleManager.Instance.RoleData.lev >= DataSystem.data_icon[v.id].lev and v.showFunc())
        else
            btn.gameObject:SetActive(v.showFunc())
        end
    end
    self.mainuiIconRightDown.sizeDelta = self.mainuiIconLayout.panel.transform.sizeDelta
end

-- 最多支持三位数
function AnimalChessMain:SetNum(num)
    if num < 0 then
        self:SetNum(0)
    else
        local num1 = num
        local numList = {}
        if num1 > 0 then
            while num1 > 0 do
                table.insert(numList, num1 % 10)
                num1 = math.floor(num1 / 10)
            end
        else
            numList[1] = 0
        end
        for i=1,#numList do
            self.numList[#numList - i + 1].sprite = PreloadManager.Instance.assetWrapper:GetTextures(AssetConfig.maxnumber_4, string.format("Num4_%s", numList[i]))
            self.numList[#numList - i + 1].gameObject:SetActive(true)
        end
        self.countDownContainer.sizeDelta = Vector2(28 * #numList, 32)
        for i=#numList + 1,#self.numList do
            self.numList[i].gameObject:SetActive(false)
        end
        self.countDownContainer.gameObject:SetActive(true)
    end
end

function AnimalChessMain:LookAt(direction)
end

function AnimalChessMain:OnClick(x, y)
    if IS_DEBUG then
        print(string.format("self.model.isPlaying: %s", self.model.isPlaying))
    end

    if self.model.isPlaying == true then
        return
    end

    if AnimalChessManager.Instance.simulate then
        local clock = os.clock()
        if self.lastClock ~= nil and clock - self.lastClock < 0.5 then
            if self.lastClickId ~= nil and (self.lastClickId.x == x and self.lastClickId.y == y) then
                self.model:CloseMain()
                self.lastClickId = nil
            end
            self.lastClock = clock
            return
        end
        self.lastClock = clock
    end


    if self.model.next_move ~= self.model.myCamp then
        NoticeManager.Instance:FloatTipsByString(TI18N("当前是<color='#ff0000'>对方</color>回合！请稍等后再进行操作{face_1 ,22}"))
        if self.lastClickId ~= nil then
            self.chessTab[self.lastClickId.x][self.lastClickId.y]:Select(false)
            self.chessBoard:Select(self.lastClickId.x, self.lastClickId.y, false)
        end
        self.lastClickId = nil
        return
    end

    if self.lastClickId ~= nil then
        self.chessTab[self.lastClickId.x][self.lastClickId.y]:Select(false)
        self.chessBoard:Select(self.lastClickId.x, self.lastClickId.y, false)
    end

    if IS_DEBUG then
        print(string.format("self.model.chessInfoTab[x][y].status: %s", self.model.chessInfoTab[x][y].status))
    end

    if self.model.chessInfoTab[x][y].status == AnimalChessEumn.SlotStatus.UnOpen then
        AnimalChessManager.Instance:send17852(x, y)
    elseif self.model.chessInfoTab[x][y].status == AnimalChessEumn.SlotStatus.Opened then
        if self.lastClickId == nil then
            if self.model.chessInfoTab[x][y].camp ~= self.model.myCamp and not AnimalChessManager.Instance.simulate then
                NoticeManager.Instance:FloatTipsByString(TI18N("不能操作敌方单位"))
            else
                self:ForbidenAll(true)
                self.lastClickId = {x = x, y = y}
                self.chessTab[x][y]:Select(true)
                self.chessBoard:Select(x, y, true)
                return
            end
        else
            if self.lastClickId.x == x and self.lastClickId.y == y then
            elseif self.model.chessInfoTab[self.lastClickId.x][self.lastClickId.y].status == AnimalChessEumn.SlotStatus.Opened then
                if self.model.chessInfoTab[x][y].camp == self.model.chessInfoTab[self.lastClickId.x][self.lastClickId.y].camp then
                    -- 切换
                    if self.lastClickId ~= nil then
                        self.chessTab[self.lastClickId.x][self.lastClickId.y]:Select(false)
                        self.chessBoard:Select(self.lastClickId.x, self.lastClickId.y, false)
                        self.lastClickId = nil
                        self.lastClock = nil
                    end
                    self:OnClick(x, y)
                    return
                else
                    -- 进攻
                    AnimalChessManager.Instance:send17849(self.lastClickId.x, self.lastClickId.y, x, y)
                    self:ForbidenAll(false)
                end
            end
        end
    elseif self.model.chessInfoTab[x][y].status == AnimalChessEumn.SlotStatus.Empty then
        if self.lastClickId == nil then
            self:ForbidenAll(true)
            self.lastClickId = {x = x, y = y}
            self.chessTab[x][y]:Select(true)
            self.chessBoard:Select(x, y, true)
            return
        else
            if self.lastClickId.x == x and self.lastClickId.y == y then
            elseif self.model.chessInfoTab[self.lastClickId.x][self.lastClickId.y].status == AnimalChessEumn.SlotStatus.Opened then
                AnimalChessManager.Instance:send17849(self.lastClickId.x, self.lastClickId.y, x, y)
                self:ForbidenAll(false)
            end
        end
    end
    if self.lastClickId ~= nil then
        self.chessTab[self.lastClickId.x][self.lastClickId.y]:Select(false)
        self.chessBoard:Select(self.lastClickId.x, self.lastClickId.y, false)
    end
    self.lastClickId = nil
end

function AnimalChessMain:ForbidenAll(bool)
    for _,list in pairs(self.chessTab) do
        for _,item in pairs(list) do
            item.canClick = not bool
        end
    end
end

function AnimalChessMain:Update(type, coordinate1, coordinate2)
    if self.model.myInfo.sex ~= nil then
        self.roleInfo:SetData(self.model.myInfo)
        self.enemyInfo:SetData(self.model.enemyInfo)

        if self.model.next_move == self.model.myCamp then
            self.titleText.text = string.format(TI18N("我方行动(%s/80)"), tostring(self.model.round or 0))
            self.roleInfo.statusImage.gameObject:SetActive(true)
            self.enemyInfo.statusImage.gameObject:SetActive(false)
            self.roleInfo:SetStatus(true)
            if self.model.next_move == self.model.myCamp then
                Tween.Instance:Scale(self.titleText.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
            end
        else
            self.titleText.text = string.format(TI18N("敌方行动(%s/80)"), tostring(self.model.round or 0))
            self.roleInfo.statusImage.gameObject:SetActive(false)
            self.enemyInfo.statusImage.gameObject:SetActive(true)
            self.enemyInfo:SetStatus(false)
        end
    end

    self:SetNameAndHonor(self.roleText1, self.roleText2, self.roleText3, self.roleText4, self.model.myInfo, self.model.myCamp or 1)
    self:SetNameAndHonor(self.enemyText1, self.enemyText2, self.enemyText3, self.enemyText4, self.model.enemyInfo, 3 - (self.model.myCamp or 1))

    self.chessBoard:Update(type, coordinate1, coordinate2)
    self:UpdatePreview()
end


function AnimalChessMain:OnTime()
    local dis = (self.model.next_time_stemp or 0) - BaseUtils.BASE_TIME

    if dis > 0 then
        if dis > 20 then
            self.countDownContainer.gameObject:SetActive(false)
            -- self:SetNum(999)
        else
            self:SetNum(dis)
        end
    else
        self:SetNum(0)
    end
end

function AnimalChessMain:UpdatePreview()
    if (self.model.myInfo or {}).looks == nil then
        return
    end

    local roleInfo = self.model.myInfo
    local callback = function(composite)
        composite.tpose.transform.localRotation = Quaternion.Euler(20.68393, 131.9303, 340.775)
        local rawImage = composite.rawImage
        rawImage.transform:SetParent(self.rolePreviewContainer)
        rawImage.transform.localPosition = Vector3(0, 0, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
        self.rolePreviewContainer.gameObject:SetActive(true)
        self.roleTurnEffect = self:LoadTurnEffect(composite.tpose)
        self.roleTurnEffect:SetActive(self.model.next_move == self.model.myCamp)
    end
    local setting = {
        name = "AnimalChessMain"
        ,orthographicSize = 1.5
        ,width = 400
        ,height = 400
        ,offsetY = -0.29
        ,offsetX = 0.04
    }
    local modelData = {type = PreViewType.Role, classes = roleInfo.classes, sex = roleInfo.sex, looks = roleInfo.looks}

    if self.rolePreview == nil then
        self.rolePreview = PreviewComposite.New(callback, setting, modelData)
    end
    self.rolePreview:Show()

    local roleInfo = self.model.enemyInfo
    local callback = function(composite)
        composite.tpose.transform.localRotation = Quaternion.Euler(339.3161, 311.9303, 19.91244)
        local rawImage = composite.rawImage
        rawImage.transform:SetParent(self.enemyPreviewContainer)
        rawImage.transform.localPosition = Vector3(0, 0, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
        self.enemyPreviewContainer.gameObject:SetActive(true)
        self.enemyTurnEffect = self:LoadTurnEffect(composite.tpose)
        self.enemyTurnEffect:SetActive(self.model.next_move ~= self.model.myCamp)
    end
    local setting = {
        name = "Enemy"
        ,orthographicSize = 1.5
        ,width = 400
        ,height = 400
        ,offsetY = -0.29
        ,offsetX = -0.02
    }
    local modelData = {type = PreViewType.Role, classes = roleInfo.classes, sex = roleInfo.sex, looks = roleInfo.looks}

    if self.enemyPreview == nil then
        self.enemyPreview = PreviewComposite.New(callback, setting, modelData)
    end
    self.enemyPreview:Show()

    if self.roleTurnEffect ~= nil then
        self.roleTurnEffect:SetActive(self.model.next_move == self.model.myCamp)
    end
    if self.enemyTurnEffect ~= nil then
        self.enemyTurnEffect:SetActive(self.model.next_move ~= self.model.myCamp)
    end
end

function AnimalChessMain:SetNameAndHonor(text1, text2, text3, text4, info, camp)
    local num = 0
    for _,list in pairs(self.model.chessInfoTab) do
        for _,info in pairs(list) do
            if info.status ~= AnimalChessEumn.SlotStatus.Empty and info.camp == camp then
                num = num + 1
            end
        end
    end

    text1.text = info.name
    text2.text = info.name
    text3.text = string.format(TI18N("剩余棋子:%s"), num)
    text4.text = string.format(TI18N("剩余棋子:%s"), num)
end

function AnimalChessMain:LoadTurnEffect(tpose)
    local fun = function(effectView)
        local effectObject = effectView.gameObject
        effectObject.transform:SetParent(tpose.transform)
        effectObject.name = "Effect"
        effectObject.transform.localScale = Vector3.one
        effectObject.transform.localPosition = Vector3.zero
        effectObject.transform.localRotation = Quaternion.identity
        effectObject.transform:GetChild(0):GetChild(0).renderer.material.shader = PreloadManager.Instance:GetSubAsset(AssetConfig.shader_effects, "ParticlesAdditive")
        Utils.ChangeLayersRecursively(effectObject.transform, "ModelPreview")
    end
    return BaseEffectView.New({effectId = 30200, callback = fun})
end

function AnimalChessMain:AdaptIPhoneX()
    if MainUIManager.Instance.adaptIPhoneX then
        if Screen.orientation == ScreenOrientation.LandscapeRight then
            self.originGridPos = Vector2(40, -118.5)
            self.originShowDelta = Vector2(230, 0)
        else
            self.originGridPos = Vector2(3, -118.5)
            self.originShowDelta = Vector2(280, 0)
        end
    else
        self.originGridPos = Vector2(3, -118.5)
        self.originShowDelta = Vector2(230, 0)
    end

    self.mainuiIconArea.transform.anchoredPosition = self.originGridPos
end

function AnimalChessMain:LoadAssetsWideScreen()
    local left = GameObject.Instantiate(self.assetWrapper:GetMainAsset(AssetConfig.animal_chess_left))
    UIUtils.AddBigbg(self.transform:Find("Main/Bg/Left"), left)

    local right = GameObject.Instantiate(self.assetWrapper:GetMainAsset(AssetConfig.animal_chess_right))
    UIUtils.AddBigbg(self.transform:Find("Main/Bg/Right"), right)
end


