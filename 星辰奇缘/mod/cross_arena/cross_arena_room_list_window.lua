-- 跨服擂台房间列表窗口
-- ljh 20190329

CrossArenaRoomListWindow = CrossArenaRoomListWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function CrossArenaRoomListWindow:__init(model)
    self.model = model

    self.windowId = WindowConfig.WinID.crossarenaroomlistwindow
    self.winLinkType = WinLinkType.Single
    -- self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
        {file = AssetConfig.crossarenaroomlistwindow, type = AssetType.Main},
        {file = AssetConfig.crossarena_bg, type = AssetType.Main},
        {file = string.format(AssetConfig.effect, 20486), type = AssetType.Main},
        {file = AssetConfig.crossarena_textures, type = AssetType.Dep},
    }

    self.gameObject = nil
    self.transform = nil

    self.mainTransform = nil

    ------------------------------------------------
    self.roomItemList = {}

    self.roomListType = 1

    ------------------------------------------------

    ------------------------------------------------
    self._Update = function() self:Update() end
    self._Refresh = function() self:OnClickRefreshButton() end
    self._JumpToRoom = function() self:JumpToRoom() end
    self._UpdateFight = function() self:UpdateFight() end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function CrossArenaRoomListWindow:__delete()
    self:OnHide()

    for _,v in pairs(self.roomItemList) do
        if v.headSlot ~= nil then
            v.headSlot:DeleteMe()
            v.headSlot = nil
        end
    end

    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function CrossArenaRoomListWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.crossarenaroomlistwindow))
    self.gameObject.name = "CrossArenaRoomListWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    local bgtitle = GameObject.Instantiate(self:GetPrefab(AssetConfig.crossarena_bg))
    UIUtils.AddBigbg(self.mainTransform:FindChild("Bg"), bgtitle)

    if BaseUtils.IsWideScreen() then
        local scaleX = (ctx.ScreenWidth / ctx.ScreenHeight) / (16 / 9)
        bgtitle.transform.localScale = Vector3(scaleX, 1, 1)
        self.mainTransform:FindChild("Title").localScale = Vector3(scaleX, 1, 1)
    else
        local scaleY = (ctx.ScreenHeight/ ctx.ScreenWidth) / (9 / 16)
        bgtitle.transform.localScale = Vector3(1, scaleY, 1)
    end

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.refreshButton = self.mainTransform:FindChild("RefreshButton"):GetComponent(Button)
    self.refreshButton.onClick:AddListener(function() self:OnClickRefreshButton() end)
    
    self.teamButton = self.mainTransform:FindChild("TeamButton"):GetComponent(Button)
    self.teamButton.onClick:AddListener(function() self:OnClickTeamButton() end)
    
    self.joinRoomButton = self.mainTransform:FindChild("JoinRoomButton"):GetComponent(Button)
    self.joinRoomButton.onClick:AddListener(function() self:OnClickJoinRoomButton() end)
    
    self.createRoomButton = self.mainTransform:FindChild("CreateRoomButton"):GetComponent(Button)
    self.createRoomButton.onClick:AddListener(function() self:OnClickCreateRoomButton() end)
    self.createRoomButtonText = self.createRoomButton.transform:FindChild("Text"):GetComponent(Text)

    self.noRoomTips = self.mainTransform:FindChild("Panel/Mask/NoRoomTips").gameObject   
    self.noRoomTips:SetActive(false)
    self.noRoomTipsText = self.noRoomTips.transform:FindChild("Text"):GetComponent(Text)
    self.noRoomTipsTextRect = self.noRoomTipsText:GetComponent(RectTransform)
    self.noRoomTipsRect = self.noRoomTips:GetComponent(RectTransform)

    self.cloner = self.mainTransform:FindChild("Panel/Mask/Container/Cloner").gameObject   
    local effect = GameObject.Instantiate(self:GetPrefab(string.format(AssetConfig.effect, 20486)))
    local effectTransform = effect.transform
    effectTransform:SetParent(self.cloner.transform:FindChild("BattleTypeText/Effect"))
    effectTransform.localScale = Vector3.one
    effectTransform.localPosition = Vector3(0, 0, -150)
    effectTransform.localRotation = Quaternion.identity
    self.cloner:SetActive(false)
    self.container = self.mainTransform:FindChild("Panel/Mask/Container").gameObject   

    self.tabGroupObj = self.mainTransform:FindChild("TabButtonGroup").gameObject   
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:ChangeTab(index) end)
    -- self.tabGroupObj.transform:GetChild(1).localPosition = Vector3(58.5, -176.5, 0)
    -- self.tabGroupObj.transform:GetChild(2).localPosition = Vector3(58.5, -99.5, 0)

    self.toggle1 = self.tabGroup.buttonTab[1].select.transform:FindChild("Toggle"):GetComponent(Toggle)
    self.toggle1.onValueChanged:AddListener(function(on) self:OnToggleChange1(on) end)

    self.toggle2 = self.tabGroup.buttonTab[2].select.transform:FindChild("Toggle"):GetComponent(Toggle)
    self.toggle2.onValueChanged:AddListener(function(on) self:OnToggleChange2(on) end)

    self.toggle3 = self.tabGroup.buttonTab[3].select.transform:FindChild("Toggle"):GetComponent(Toggle)
    self.toggle3.onValueChanged:AddListener(function(on) self:OnToggleChange3(on) end)

    self.passWorkPanel = self.transform:FindChild("PassWorkPanel").gameObject   
    
    self.passWordInput = self.passWorkPanel.transform:FindChild("Main/PassWordInput"):GetComponent(InputField)
    self.passWordInput.textComponent = self.passWordInput.gameObject.transform:FindChild("Text").gameObject:GetComponent(Text)
    self.passWordInput.placeholder = self.passWordInput.gameObject.transform:FindChild("Placeholder").gameObject:GetComponent(Graphic)
    self.passWordInput.characterLimit = 4

    self.passWorkPanel.transform:FindChild("Panel"):GetComponent(Button).onClick:AddListener(function() self:OnClickPassWorkPanelCloseButton() end)
    self.passWorkPanel.transform:FindChild("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:OnClickPassWorkPanelCloseButton() end)
    self.passWorkPanel.transform:FindChild("Main/OkButton"):GetComponent(Button).onClick:AddListener(function() self:OnClickPassWorkPanelButton() end)

    ----------------------------

    self.OnOpenEvent:Fire()
    self:ClearMainAsset()
end

function CrossArenaRoomListWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
    -- self.model:OpenCrossArenaWindow()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.crossarenawindow)
end

function CrossArenaRoomListWindow:OnShow()
    self.refreshTimerId = LuaTimer.Add(0, 10000, self._Refresh)

    self:Update()
    -- BaseUtils.dump(self.openArgs)

    if self.openArgs ~= nil then
        
    end

    CrossArenaManager.Instance.OnUpdateRoomList:AddListener(self._Update)
    CrossArenaManager.Instance.OnUpdateRoomInfo:AddListener(self._JumpToRoom)

    EventMgr.Instance:AddListener(event_name.end_fight, self._UpdateFight)
    EventMgr.Instance:AddListener(event_name.begin_fight, self._UpdateFight)
end

function CrossArenaRoomListWindow:OnHide()
    if self.refreshTimerId ~= nil then
        LuaTimer.Delete(self.refreshTimerId)
        self.refreshTimerId = nil
    end
    CrossArenaManager.Instance.OnUpdateRoomList:RemoveListener(self._Update)
    CrossArenaManager.Instance.OnUpdateRoomInfo:RemoveListener(self._JumpToRoom)

    EventMgr.Instance:RemoveListener(event_name.end_fight, self._UpdateFight)
    EventMgr.Instance:RemoveListener(event_name.begin_fight, self._UpdateFight)
end

function CrossArenaRoomListWindow:Update()
    self:UpdateToggle()
    self:UpdateRoomList()
end

function CrossArenaRoomListWindow:ChangeTab(index)
    -- if index == 2 then
    --     NoticeManager.Instance:FloatTipsByString(TI18N("尚未开启敬请期待{face_1,3}"))
    --     self.tabGroup:ChangeTab(self.roomListType)
    --     return
    -- end
    self.roomListType = index

    if self.roomListType == 1 or self.roomListType == 3 then
        self.joinRoomButton.gameObject:SetActive(true)
        self.createRoomButtonText.text = TI18N("创建房间")
    else
        self.joinRoomButton.gameObject:SetActive(false)
        self.createRoomButtonText.text = TI18N("发布战书")
    end
    

    self:UpdateRoomList()
end

function CrossArenaRoomListWindow:UpdateRoomList()
    local dataList = self.model:GetRoomList(self.roomListType)

    if #dataList == 0 then
        self.container:SetActive(false)
        self.noRoomTips:SetActive(true)

        if self.roomListType == 1 then
            self.noRoomTipsText.text = TI18N("目前没有合适的房间，快<color='#ffff00'>创建房间</color>发起约战吧~")
        elseif self.roomListType == 2 then
            self.noRoomTipsText.text = TI18N("目前没有匹配的战书，可以发起<color='#ffff00'>跨服战书</color>哟~")
        elseif self.roomListType == 3 then
            self.noRoomTipsText.text = TI18N("目前没有可观战的战斗")
        end

        self.noRoomTipsTextRect.sizeDelta = Vector2(self.noRoomTipsText.preferredWidth, 30)
        self.noRoomTipsRect.sizeDelta = Vector2(self.noRoomTipsText.preferredWidth + 80, 40)
    else
        self.container:SetActive(true)
        self.noRoomTips:SetActive(false)
    end

    for i, v in ipairs(dataList) do
        local item = self.roomItemList[i]
        if item == nil then
            item = { transform = GameObject.Instantiate(self.cloner).transform, headSlot = nil }
            item.headSlot = HeadSlot.New()
            item.headSlot.transform.anchoredPosition = Vector2(0, 0)
            item.headSlot.transform.sizeDelta = Vector2(52, 52)
            item.headSlot:SetRectParent(item.transform:Find("Head").gameObject)

            item.transform:SetParent(self.container.transform)
            item.transform.localScale = Vector3.one
            self.roomItemList[i] = item

            item.transform.gameObject:GetComponent(Button).onClick:AddListener(function() self:OnClickRoomItem(item) end)

            item.transform:Find("Level"):GetComponent(RectTransform).sizeDelta = Vector2(30, 24)
            item.transform:Find("Level/Text"):GetComponent(RectTransform).sizeDelta = Vector2(30, 24)
        end
        item.transform.gameObject:SetActive(true)

        local transform = item.transform
        local headSlot = item.headSlot
        item.data = v

        headSlot:SetAll({id = v.rid, platform = v.platform, zone_id = v.zone_id, classes = v.master_class, sex = v.master_sex}, {isSmall = true})
        if v.status == 2 then
            item.transform:Find("Label").gameObject:SetActive(true)
        else
            item.transform:Find("Label").gameObject:SetActive(false)
        end

        local lev_string
        if self.roomListType == 2 then
            lev_string = string.format(TI18N("%s-%s级"), CrossArenaManager.Instance:GetLevelString(v.book_lev_min, v.min_lev_break), CrossArenaManager.Instance:GetLevelString(v.book_lev_max, v.max_lev_break))
        else
            lev_string = string.format(TI18N("%s-%s级"), CrossArenaManager.Instance:GetLevelString(v.room_lev_min, v.min_lev_break), CrossArenaManager.Instance:GetLevelString(v.room_lev_max, v.max_lev_break))
        end
        if lev_string == TI18N("0-突破200级") then
            lev_string = TI18N("任意等级")
        end

        if self.roomListType == 2 then
            if v.mode == 1 then
                item.transform:Find("LimitText"):GetComponent(Text).text = string.format(TI18N("无限制 %s"), lev_string)
            elseif v.mode == 2 then
                item.transform:Find("LimitText"):GetComponent(Text).text = string.format(TI18N("1v1单挑 %s"), lev_string)
            elseif v.mode == 3 then
                item.transform:Find("LimitText"):GetComponent(Text).text = string.format(TI18N("多人组队 %s"), lev_string)
            end

            item.transform:Find("BattleTypeText"):GetComponent(Text).text = TI18N("")
            item.transform:Find("BattleTypeText/Effect").gameObject:SetActive(false)

            item.transform:Find("Lock").gameObject:SetActive(false)
        else
            item.transform:Find("LimitText"):GetComponent(Text).text = lev_string

            if v.provocation_type == 0 then
                item.transform:Find("BattleTypeText"):GetComponent(Text).text = TI18N("友谊赛")
                item.transform:Find("BattleTypeText/Effect").gameObject:SetActive(false)
            else
                item.transform:Find("BattleTypeText"):GetComponent(Text).text = TI18N("擂台决斗")
                item.transform:Find("BattleTypeText/Effect").gameObject:SetActive(true)
            end

            if v.password == "" then
                item.transform:Find("Lock").gameObject:SetActive(false)
            else
                item.transform:Find("Lock").gameObject:SetActive(true)
            end
        end

        item.transform:Find("NameText"):GetComponent(Text).text = v.master_name
        item.transform:Find("DescText"):GetComponent(Text).text = v.name
        item.transform:Find("Level/Text"):GetComponent(Text).text = tostring(v.master_lev)
    end

    for i = #dataList + 1, #self.roomItemList do 
        self.roomItemList[i].transform.gameObject:SetActive(false)
    end
end

function CrossArenaRoomListWindow:UpdateToggle()
    self.toggle1.isOn = self.model.room_check == 1
    self.toggle2.isOn = self.model.book_check == 1
    self.toggle3.isOn = self.model.video_check == 1
end

function CrossArenaRoomListWindow:OnClickRefreshButton()
    CrossArenaManager.Instance:Send20700(0)
    CrossArenaManager.Instance:Send20725(0)
    CrossArenaManager.Instance:Send20730(0)
end

function CrossArenaRoomListWindow:OnClickTeamButton()

end

function CrossArenaRoomListWindow:OnClickJoinRoomButton()
    CrossArenaManager.Instance:Send20713()
end

function CrossArenaRoomListWindow:OnClickCreateRoomButton()
    if self.roomListType == 1 then
        self.model:OpenCrossArenaCreateTeamWindow({1, 1})
    elseif self.roomListType == 2 then
        self.model:OpenCrossArenaCreateTeamWindow({3, 2})
    elseif self.roomListType == 3 then
        self.model:OpenCrossArenaCreateTeamWindow({1, 1})
    end
end

function CrossArenaRoomListWindow:OnClickRoomItem(item)
    if self.roomListType == 1 then
        if item.data.password == "" then
            CrossArenaManager.Instance:Send20705(item.data.id, item.data.password)
        else
            self.joinRoomId = item.data.id
            self.passWorkPanel:SetActive(true) 
        end
    elseif self.roomListType == 2 then
        local roomData = item.data
        local roleData = RoleManager.Instance.RoleData
        if roleData.id == roomData.rid and roleData.platform == roomData.platform and roleData.zone_id == roomData.zone_id then
            self.model:OpenCrossArenaCreateTeamWindow({4, 1, roomData.id})
        else
            FriendManager.Instance:TalkToUnknowMan({id = roomData.rid, platform = roomData.platform, zone_id = roomData.zone_id, sex = roomData.master_sex, classes = roomData.master_class, lev = roomData.master_lev, name = roomData.master_name })
        end
    elseif self.roomListType == 3 then
        CombatManager.Instance:Send10705(item.data.rid, item.data.platform, item.data.zone_id)
    end
end

function CrossArenaRoomListWindow:JumpToRoom()
    WindowManager.Instance:CloseWindow(self)
    self.model:OpenCrossArenaRoomWindow()
end

function CrossArenaRoomListWindow:UpdateFight()
    if not BaseUtils.is_null(self.gameObject) then
        local roleData = RoleManager.Instance.RoleData
        if roleData.status == RoleEumn.Status.Fight then
            self.gameObject:SetActive(false)
        else
            self.gameObject:SetActive(true)
        end
    end
end

function CrossArenaRoomListWindow:OnToggleChange1(on)
    if on and self.model.room_check ~= 1 then
        self.model.room_check = 1
        CrossArenaManager.Instance:Send20718(self.model.room_check, self.model.book_check, self.model.video_check)
    elseif not on and self.model.room_check ~= 0 then
        self.model.room_check = 0
        CrossArenaManager.Instance:Send20718(self.model.room_check, self.model.book_check, self.model.video_check)
    end
end

function CrossArenaRoomListWindow:OnToggleChange2(on)
    if on and self.model.book_check ~= 1 then
        self.model.book_check = 1
        CrossArenaManager.Instance:Send20718(self.model.room_check, self.model.book_check, self.model.video_check)
    elseif not on and self.model.book_check ~= 0 then
        self.model.book_check = 0
        CrossArenaManager.Instance:Send20718(self.model.room_check, self.model.book_check, self.model.video_check)
    end
end

function CrossArenaRoomListWindow:OnToggleChange3(on)
    if on and self.model.video_check ~= 1 then
        self.model.video_check = 1
        CrossArenaManager.Instance:Send20718(self.model.room_check, self.model.book_check, self.model.video_check)
    elseif not on and self.model.video_check ~= 0 then
        self.model.video_check = 0
        CrossArenaManager.Instance:Send20718(self.model.room_check, self.model.book_check, self.model.video_check)
    end
end

function CrossArenaRoomListWindow:OnClickPassWorkPanelButton()
    CrossArenaManager.Instance:Send20705(self.joinRoomId, self.passWordInput.text)
    self.passWorkPanel:SetActive(false)
end 

function CrossArenaRoomListWindow:OnClickPassWorkPanelCloseButton()
    self.passWorkPanel:SetActive(false) 
end