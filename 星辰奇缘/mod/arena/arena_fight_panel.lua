ArenaFightPanel = ArenaFightPanel or BaseClass(BasePanel)

function ArenaFightPanel:__init(model, parent)
    self.parent = parent
    self.model = model
    self.mgr = ArenaManager.Instance
    self.effectCounter = 0
    self.effectShakeCounter = 0

    self.resList = {
        {file = AssetConfig.arena_fight_panel, type = AssetType.Main}
        , {file = AssetConfig.arena_textures, type = AssetType.Dep}
        , {file = AssetConfig.half_length, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
    }

    self.separator = {}
    self.recordObjList = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil}
    self.fellowObjList = {nil, nil, nil, nil, nil}
    self.destList = {TI18N("你对<color=#e8faff>%s</color>发起了战斗,你胜利了"), TI18N("你对<color=#e8faff>%s</color>发起了战斗,你失败了"), TI18N("<color=#e8faff>%s</color>对你发起了战斗,你胜利了"), TI18N("<color=#e8faff>%s</color>对你发起了战斗,你失败了")}
    self.helpText = {TI18N("1.主动挑战,胜利可得杯数,失败<color=#FFFF00>不会</color>损失杯数。"),
        TI18N("2.防守战中失败时<color=#FFFF00>会</color>损失杯数。"),
    TI18N("3.当天没有进行<color=#FFFF00>任意一场</color>竞技场将不会获得<color=#FFFF00>积分奖励</color>。"),
    TI18N("4.竞技场每日<color=#FFFF00>5:00</color>重置挑战次数,每日<color=#FFFF00>00:00</color>刷新排行榜并发放排名奖励。"),
    TI18N("5.排名进入前<color=#FFFF00>50名</color>,第二天竞技场自动化身为神秘高手。"),
    TI18N("6.<color=#FFFF00>神秘高手</color>对外隐藏<color=#FFFF00>职业、性别、杯数</color>。"),
    TI18N("7.神秘高手进攻神秘高手不会被反击。"),}
    self.name = RoleManager.Instance.RoleData.name

    self.updateMyDataListener = function()
        self:UpdateMydata()
        self:UpdateFellowList()
        self:UpdateRecordList()
    end

    self.timeListener = function() self:UpdateTimes() end
    self.checkRedListener = function() self:CheckRed() end
    -- self.recruitListener = function() self:RecruitedGuard() end

    self.OnOpenEvent:AddListener(function () self:OnOpen() end)
    self.OnHideEvent:AddListener(function () self:OnHide() end)
end

function ArenaFightPanel:__delete()
    self.OnHideEvent:Fire()

    if self.cupImage ~= nil then
        self.cupImage.sprite = nil
    end

    if self.myLookImage ~= nil then
        self.myLookImage.sprite = nil
    end

    if self.soulImageTimerId ~= nil then
        LuaTimer.Delete(self.soulImageTimerId)
        self.soulImageTimerId = nil
    end

    for i,v in ipairs(self.fellowObjList) do
        v:DeleteMe()
    end
    self.fellowObjList = nil

    if self.shakeTimerId ~= nil then
        LuaTimer.Delete(self.shakeTimerId)
        self.shakeTimerId = nil
    end
    if self.soulTimerId ~= nil then
        LuaTimer.Delete(self.soulTimerId)
        self.soulTimerId = nil
    end
    if self.treasureEffect ~= nil then
        self.treasureEffect:DeleteMe()
        self.treasureEffect = nil
    end
    if self.soulEffect ~= nil then
        self.soulEffect:DeleteMe()
        self.soulEffect = nil
    end
    if self.msgItemExt ~= nil then
        self.msgItemExt:DeleteMe()
        self.msgItemExt = nil
    end
    if self.recordLayout ~= nil then
        self.recordLayout:DeleteMe()
        self.recordLayout = nil
    end
    if self.fellowLayout ~= nil then
        self.fellowLayout:DeleteMe()
        self.fellowLayout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ArenaFightPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.arena_fight_panel))
    self.gameObject.name = "ArenaFightPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform
    local main = self.gameObject.transform
    self.recordContainer = main:Find("Record/Scroll/Container")
    self.recordTemplate = self.recordContainer:Find("Item").gameObject
    self.fellowContainer = main:Find("Fellows/Scroll/Container")
    self.fellowTemplate = self.fellowContainer:Find("Item").gameObject
    self.myLookImage = main:Find("Record/MySoul/Half"):GetComponent(Image)
    self.myscoreText = main:Find("Record/MyScore/Score"):GetComponent(Text)
    self.remainTimes = main:Find("TimesBg/Text"):GetComponent(Text)
    self.cupImage = main:Find("Record/MyScore/Cup"):GetComponent(Image)
    -- self.starScoreText = main:Find("Record/MyScore/Bg/StarScoreText"):GetComponent(Text)
    self.soulSlider = main:Find("Record/MySoul/TreasureArea/Slider"):GetComponent(Slider)
    self.soulSliderText = main:Find("Record/MySoul/TreasureArea/Slider/ProgressTxt"):GetComponent(Text)
    self.soulImageRect = main:Find("Record/MySoul/TreasureArea/Image"):GetComponent(RectTransform)
    self.treasureMaskBtn = main:Find("Record/MySoul"):GetComponent(Button)
    self.treasureMaskTbtn = main:Find("Record/MySoul"):GetComponent(TransitionButton)
    self.weaponFashionPreviewBtn = main:Find("Record/MySoul/KingWeaponPreviewButton"):GetComponent(Button)
    self.weaponFashionPreviewBtn.onClick:AddListener(function()
        FashionManager.Instance.model:InitWeaponFashionPreviewWindow()
    end)

    -- self.jumpToShouhuRedPoint = main:Find("JumpToShouhu/NotifyPoint").gameObject
    self.treasureBtn = main:Find("Record/Treasure"):GetComponent(Button)
    self.treasureRect = self.treasureBtn:GetComponent(RectTransform)

    self.jumpToVictoryBtn = main:Find("JumpToVictory"):GetComponent(Button)
    self.jumpToVictoryRedPoint = self.jumpToVictoryBtn.gameObject.transform:Find("NotifyPoint").gameObject

    local sliderFill = self.soulSlider.gameObject.transform:Find("Fill Area")
    for i=1,5 do
        self.separator[i] = sliderFill:Find("Separator"..i).gameObject
    end

    self.cupImage.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon1001")
    self.cupImage.gameObject:SetActive(true)
    self.soulSlider.value = 0

    self.recordTemplate:SetActive(false)
    self.fellowTemplate:SetActive(false)
    self.remainTimes.text = ""

    self.treasureMaskBtn.onClick:AddListener(function()
        self:OnShowPresent(2)
    end)

    if BaseUtils.IsVerify == true then
        main:Find("JumpToRank").gameObject:SetActive(false)
    end

    main:Find("JumpToShop"):GetComponent(Button).onClick:AddListener(function () WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {2, 1}) end)
    main:Find("JumpToRank"):GetComponent(Button).onClick:AddListener(function () WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ui_rank, {1, 30}) end)
    self.jumpToVictoryBtn.onClick:AddListener(function()
            if ArenaManager.Instance.model.arenaWin ~= nil then
                ArenaManager.Instance.model.arenaWin.cacheMode = CacheMode.Visible
            end
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.arena_victory_window)
        end)
    main:Find("Refresh"):GetComponent(Button).onClick:AddListener(function ()
        if self.model.countDown > 0 then
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("冷却时间还剩%s秒，不能刷新"), self.model.countDown))
        else
            ArenaManager.Instance:send12202()
        end
    end)
    local helpBtn = main:Find("Record/MyScore/Help"):GetComponent(Button)
    helpBtn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = helpBtn.gameObject, itemData = self.helpText}) end)

    self.treasureBtn.onClick:AddListener(function() self:OnShowPresent(1) end)

    self.recordLayout = nil
    if self.recordLayout == nil then
        local setting = {
            axis = BoxLayoutAxis.Y
            ,spacing = 0
        }
        self.recordLayout = LuaBoxLayout.New(self.recordContainer, setting)
    end
    local obj = nil
    for i=1,10 do
        obj = GameObject.Instantiate(self.recordTemplate)
        obj.name = tostring(i)
        self.recordLayout:AddCell(obj)
        if i % 2 == 1 then
            obj.transform:Find("Bg").gameObject:SetActive(true)
        else
            obj.transform:Find("Bg").gameObject:SetActive(false)
        end
        self.recordObjList[i] = obj
    end

    self.fellowLayout = nil
    if self.fellowLayout == nil then
        local setting = {
            axis = BoxLayoutAxis.Y
            ,spacing = 5
        }
        self.fellowLayout = LuaBoxLayout.New(self.fellowContainer, setting)
    end
    for i=1,5 do
        obj = GameObject.Instantiate(self.fellowTemplate)
        obj.name = tostring(i)
        self.fellowLayout:AddCell(obj)
        self.fellowObjList[i] = ArenaFellowItem.New(self.model, obj, self.assetWrapper)
    end

    self:ClearFellows()
    self:ClearRecords()

    self.OnOpenEvent:Fire()
end

function ArenaFightPanel:RemoveListeners()
    self.mgr.onUpdateMyScore:RemoveListener(self.updateMyDataListener)
    self.mgr.onUpdateTime:RemoveListener(self.timeListener)
    -- self.mgr.onUpdateNewGuard:RemoveListener(self.recruitListener)
    self.mgr.onUpdateRed:RemoveListener(self.checkRedListener)
end

function ArenaFightPanel:OnOpen()
    if self.model.fellows == nil then
        ArenaManager.Instance:send12200()

        ArenaManager.Instance:send12205()
    else
        self:UpdateMydata()
        self:UpdateRecordList()
        self:UpdateFellowList()
        self:UpdateTimes()
    end

    self.mgr.redPoint[1] = (self.model.roll_time > 0)

    self:RemoveListeners()
    self.mgr.onUpdateMyScore:AddListener(self.updateMyDataListener)
    self.mgr.onUpdateTime:AddListener(self.timeListener)
    self.mgr.onUpdateRed:AddListener(self.checkRedListener)
    -- self.mgr.onUpdateNewGuard:AddListener(self.recruitListener)

    -- self.jumpToShouhuRedPoint:SetActive(self.mgr.hasNewGuard == true)

    self.mgr.onUpdateRed:Fire()
end

function ArenaFightPanel:OnHide()
    self:RemoveListeners()
end

function ArenaFightPanel:ClearRecords()
    for i=1,10 do
        self.recordObjList[i]:SetActive(false)
    end
end

function ArenaFightPanel:ClearFellows()
    for i=1,5 do
        self.fellowObjList[i]:SetActive(false)
    end
end

function ArenaFightPanel:UpdateRecordList()
    local recordList = self.model.records

    if recordList == nil then
        recordList = {}
    end

    local l = #recordList
    if l < 5 then
        l = 5
    end

    local rect = self.recordContainer:GetComponent(RectTransform)
    local w = rect.sizeDelta.x
    local h = self.recordTemplate:GetComponent(RectTransform).sizeDelta.y
    for i=1,l do
        self:SetRecordItem(self.recordObjList[i], recordList[i])
    end
    rect.sizeDelta = Vector2(w, h * l)
    self.recordContainer.transform.anchoredPosition = Vector3.zero
end

function ArenaFightPanel:UpdateFellowList()
    local fellowList = self.model.fellows

    if fellowList == nil then
        fellowList = {}
    end

    for i=1,5 do
        self.fellowObjList[i]:SetData(fellowList[i], i)
    end
end

function ArenaFightPanel:UpdateMydata()
    local model = self.model
    local roledata = RoleManager.Instance.RoleData
    self.myLookImage.gameObject:SetActive(true)
    self.myLookImage.sprite = self.assetWrapper:GetSprite(AssetConfig.half_length, "half_"..roledata.classes..roledata.sex)
    self.myscoreText.text = tostring(model.cup)
    local soul = model.has_soul
    if soul > model.max_soul then soul = model.max_soul end

    if self.treasureEffect ~= nil then self.treasureEffect:DeleteMe() end
    if self.shakeTimerId ~= nil then LuaTimer.Delete(self.shakeTimerId) end
    if model.has_soul >= model.max_soul then
        self.treasureEffect = BibleRewardPanel.ShowEffect(20140, self.treasureBtn.gameObject.transform, Vector3(0.5, 0.5, 0), Vector3(-6, -6, 0))
        self.shakeTimerId = LuaTimer.Add(0, 20, function() self:ShakeGameObject() end)
    end

    if self.soulTimerId ~= nil then LuaTimer.Delete(self.soulTimerId) self.soulTimerId = nil end
    if model.old_soul ~= nil and model.old_soul < model.has_soul then
        if self.soulEffect ~= nil then self.soulEffect:DeleteMe() end
        self.soulEffect = BibleRewardPanel.ShowEffect(20139, self.transform, Vector3(1, 1, 1), Vector3(-201, 107, 0), 2000)
        SoundManager.Instance:Play(265)
        self.soulCounter = 1
        self.soulImageCounter = 1
        self.soulDiff = soul - model.old_soul
        LuaTimer.Add(2000, function ()
            if BaseUtils.isnull(self.gameObject) then
                return
            end
            SoundManager.Instance:Play(241)
            self.soulTimerId = LuaTimer.Add(0, 50, function() self:SoulSliderTween() end)
        end)
        LuaTimer.Add(1000, function ()
            if BaseUtils.isnull(self.gameObject) then
                return
            end
            self.soulImageTimerId = LuaTimer.Add(0, 50, function() self:SoulImageTween() end)
        end)
    else
        self:SetSliderValue(soul / model.max_soul)
    end
    self.soulSliderText.text = tostring(soul).."/"..tostring(model.max_soul)
    model.old_soul = model.has_soul
end

function ArenaFightPanel:SetRecordItem(obj, data)
    obj:SetActive(true)

    local t = obj.transform
    local descText = t:Find("Desc"):GetComponent(Text)
    local viewbackButton = t:Find("ViewBack"):GetComponent(Button)
    local fightbackButton = t:Find("FightBack"):GetComponent(Button)
    local disscoreText = t:Find("DisScore"):GetComponent(Text)
    local arrowObj = t:Find("Arrow").gameObject
    if data == nil then
        descText.gameObject:SetActive(false)
        viewbackButton.gameObject:SetActive(false)
        fightbackButton.gameObject:SetActive(false)
        disscoreText.gameObject:SetActive(false)
        arrowObj:SetActive(false)
        return
    else
        descText.gameObject:SetActive(true)
        viewbackButton.gameObject:SetActive(true)
        disscoreText.gameObject:SetActive(true)
        arrowObj:SetActive(true)
    end

    local updownTrans = t:Find("DisScore/UpDown")
    local roleData = RoleManager.Instance.RoleData

    if BaseUtils.get_unique_roleid(roleData.id, roleData.zone_id, roleData.platform) == BaseUtils.get_unique_roleid(data.s_id, data.s_zone, data.s_platform) then        -- “我”是发起方
        if data.result == 1 then
            descText.text = string.format(self.destList[1], data.t_name)
        else
            descText.text = string.format(self.destList[2], data.t_name)
        end
        disscoreText.text = tostring(math.abs(data.s_cup_change))
        disscoreText.gameObject:SetActive(false)
        if data.s_cup_change > 0 then
            disscoreText.gameObject:SetActive(true)
            updownTrans.localScale = Vector3(1, 1, 1)
        elseif data.s_cup_change < 0 then
            updownTrans.localScale = Vector3(1, -1, 1)
        end
    else
        if data.result == 1 then
            descText.text = string.format(self.destList[4], data.s_name)
        else
            descText.text = string.format(self.destList[3], data.s_name)
        end
        disscoreText.text = tostring(math.abs(data.t_cup_change))
        disscoreText.gameObject:SetActive(false)
        if data.t_cup_change > 0 then
            updownTrans.localScale = Vector3(1, 1, 1)
        elseif data.t_cup_change < 0 then
            disscoreText.gameObject:SetActive(true)
            updownTrans.localScale = Vector3(1, -1, 1)
        end
    end

    if data.feedback == 1 then
        fightbackButton.gameObject:SetActive(true)
    else
        fightbackButton.gameObject:SetActive(false)
    end

    local fightBackBtn = obj.transform:Find("FightBack"):GetComponent(Button)
    fightBackBtn.onClick:RemoveAllListeners()
    fightBackBtn.onClick:AddListener(function ()
        self:Fightback(data.log_id)
    end)
    viewbackButton.onClick:RemoveAllListeners()
    viewbackButton.onClick:AddListener(function()
        self.mgr:send12215(data.log_id)
    end)
end

function ArenaFightPanel:SetFellowItem(obj, data)
end

function ArenaFightPanel:UpdateTimes()
    local model = self.model
    local times = model.times
    if times == nil then
        times = 10
    end
    self.remainTimes.text = TI18N("挑战次数 ")..tostring(times)

    -- if self.msgItemExt ~= nil then self.msgItemExt:DeleteMe() end
    -- self.msgItemExt = MsgItemExt.New(self.starScoreText, 218, 16, 20)

    -- local score = model.score
    -- if score == nil then score = 0 end
    -- local msg = string.format("今天已获:%s{assets_2, 90012}", tostring(score))
    -- self.msgItemExt:SetData(msg, true)
end

function ArenaFightPanel:Fightback(record_id)
    ArenaManager.Instance:send12204(record_id)
end

function ArenaFightPanel:OnShowPresent(type)
    local model = self.model
    if model.has_soul < model.max_soul then
        if self.shakeTimerId ~= nil then LuaTimer.Delete(self.shakeTimerId) end
        self.effectShakeCounter = 0
        self.shakeTimerId = LuaTimer.Add(0, 20, function() self:ShakeGameObject(true) end)

        local go = nil
        if type == 1 then
            -- 点击宝箱
            self.treasureMaskTbtn:OnPointerDown()
            LuaTimer.Add(100, function()
                if BaseUtils.isnull(self.gameObject) then
                    return
                end
                self.treasureMaskTbtn:OnPointerUp()
            end)
            go = self.treasureBtn.gameObject
        else
            -- 点击信息
            go = self.soulSliderText.gameObject
        end
        TipsManager.Instance:ShowText({gameObject = go, itemData = {
            TI18N("1、竞技场对手根据实力，会拥有<color=#00FF00>1</color>个或<color=#00FF00>2</color>个<color=#00FF00>战魂</color>"),
            TI18N("2、击败对手可获得相应数量的<color=#00FF00>战魂</color>"),
            TI18N("3、集齐战魂可开启<color=#00FF00>战魂之心</color>宝箱获得奖励"),
            }})
    else
        self.mgr:send12210()
    end
end

function ArenaFightPanel:ShakeGameObject(bool)
    local maxTime = 6280
    self.effectCounter = (self.effectCounter + 40) % maxTime
    self.effectShakeCounter = (self.effectShakeCounter + 2) % 100
    if bool == true and self.effectShakeCounter >= 30 then
        if self.shakeTimerId ~= nil then
            LuaTimer.Delete(self.shakeTimerId)
            self.shakeTimerId = nil
        end
        self.treasureRect.rotation = Quaternion.Euler(0, 0, 0)
        return
    end
    local status = 1
    if self.effectShakeCounter > 30 then status = 0 end
    local diff = math.sin(self.effectCounter / 20)
    self.treasureRect.rotation = Quaternion.Euler(0, 0, diff * status * 5)
end

function ArenaFightPanel:SoulSliderTween()
    if self.soulCounter > 20 then
        if self.soulTimerId ~= nil then
            LuaTimer.Delete(self.soulTimerId)
            self.soulTimerId = nil
        end
        SoundManager.Instance:StopId(241)
        return
    end
    local soul = self.model.has_soul
    local old_soul = soul - self.soulDiff
    self:SetSliderValue((old_soul + (self.soulDiff * self.soulCounter / 20)) / self.model.max_soul)
    self.soulCounter = self.soulCounter + 1
end

function ArenaFightPanel:SetSliderValue(value)
    self.soulSlider.value = value
    local num = math.ceil(value * 6)
    for i=1,num do
        if self.separator[i] ~= nil then
            self.separator[i]:SetActive(true)
        end
    end
    for i=num,5 do
        if self.separator[i] ~= nil then
            self.separator[i]:SetActive(false)
        end
    end
end

function ArenaFightPanel:CheckRed()
    self.jumpToVictoryRedPoint:SetActive(self.model.roll_time > 0)
end

function ArenaFightPanel:SoulImageTween()
    if self.soulImageCounter > 10 then
        if self.soulImageTimerId ~= nil then
            LuaTimer.Delete(self.soulImageTimerId)
            self.soulImageTimerId = nil
        end
        self.soulImageRect.localScale = Vector3.one
        return
    end
    local scale = 1.5 + (math.sin(math.pi / 2.5 * self.soulImageCounter) / 6)
    self.soulImageCounter = self.soulImageCounter + 1
    self.soulImageRect.localScale = Vector3(scale, scale, 1)
end
