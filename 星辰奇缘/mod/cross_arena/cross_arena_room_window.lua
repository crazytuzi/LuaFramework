-- 跨服擂台房间列表窗口
-- ljh 20190329

CrossArenaRoomWindow = CrossArenaRoomWindow or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function CrossArenaRoomWindow:__init(model)
    self.model = model

    self.windowId = WindowConfig.WinID.crossarenaroomwindow
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
        {file = AssetConfig.crossarenaroomwindow, type = AssetType.Main},
        {file = AssetConfig.crossarena_bg, type = AssetType.Main},
        {file = string.format(AssetConfig.effect, 20486), type = AssetType.Main},
        {file = AssetConfig.crossarena_textures, type = AssetType.Dep},
        {file = AssetConfig.guard_head, type = AssetType.Dep},
        {file = AssetConfig.teamquest, type = AssetType.Dep},
        {file = AssetConfig.classcardgroup_textures, type = AssetType.Dep},
    }

    self.gameObject = nil
    self.transform = nil

    self.mainTransform = nil

    self.miniMark = false

    self.tweenId = nil
    self.moveTweenId = nil
    ------------------------------------------------
    
    self.mySideItemList = {}
    self.otherSideItemList = {}

    self.mySide = 0
    self.isTeamLeader = false
    self.isRoomOwner = false

    self.myMemberData = nil
    self.myGuardsData = nil

    self.myPreviewTabList = {}     
    self.otherPreviewTabList = {}

    self.queue = BaseUtils.create_queue()
    self.bubbleList = {}
    ------------------------------------------------

    ------------------------------------------------
    self.adaptListener = function() self:AdaptIPhoneX() end


    self._Update = function() self:Update() end
    self._UpdateFormation = function() self:UpdateFormation() end
    self._UpdatePet = function() self:UpdatePet() end
    self._UpdateFight = function() self:UpdateFight() end
    self._UpdateNotice = function() self:UpdateNotice() end
    self._OnChatMain = function(bool) self:OnChatMain(bool) end


    self._FormationSelectListener = function(index) self:FormationSelectListener(index) end
    self._GuardSelectListener = function(index) self:GuardSelectListener(index) end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function CrossArenaRoomWindow:__delete()
    self:OnHide()

    for k,v in pairs(self.myPreviewTabList) do
        if v.previewComp ~= nil then
            v.previewComp:DeleteMe()
            v.previewComp = nil
        end
    end

    for k,v in pairs(self.otherPreviewTabList) do
        if v.previewComp ~= nil then
            v.previewComp:DeleteMe()
            v.previewComp = nil
        end
    end

    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end

    if self.moveTweenId ~= nil then
        Tween.Instance:Cancel(self.moveTweenId)
        self.moveTweenId = nil
    end

    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end

    if self.invitationPanel ~= nil then
        self.invitationPanel:DeleteMe()
        self.invitationPanel = nil
    end

    if self.invitationEnemyPanel ~= nil then
        self.invitationEnemyPanel:DeleteMe()
        self.invitationEnemyPanel = nil
    end

    if self.duangTimerId ~= nil then
        LuaTimer.Delete(self.duangTimerId)
        self.duangTimerId = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function CrossArenaRoomWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.crossarenaroomwindow))
    self.gameObject.name = "CrossArenaRoomWindow"
    UIUtils.AddUIChild(ChatManager.Instance.model.chatCanvas, self.gameObject)

    self.transform = self.gameObject.transform
    self.transform:SetSiblingIndex(3)

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

    self.miniBtn = self.mainTransform:FindChild("MiniButton"):GetComponent(Button)
    self.miniBtn.onClick:AddListener(function() self:OnClickMini() end)

    self.showButtonTransform = self.mainTransform:Find("ShowButton")
    self.showButtonTransform:GetComponent(Button).onClick:AddListener(function()
        self.transform:SetSiblingIndex(3)
        self:ChangeChatMainCanvasPositionZ(-300)
        self:ChangeChatMiniPositionZ(300)
        -- ChatManager.Instance.model:ShowChatWindow({2})
        ChatManager.Instance.model:ShowChatWindow()
    end)

    ---------------------------- 右部

    self.invitationButton = self.mainTransform:FindChild("Button1"):GetComponent(Button)
    self.invitationButton.onClick:AddListener(function() self:OnClickInvitationButton() end)
    
    self.skipperButton = self.mainTransform:FindChild("Button2"):GetComponent(Button)
    self.skipperButton.onClick:AddListener(function() self:OnClickSkipperButton() end)

    self.startButton = self.mainTransform:FindChild("Button3"):GetComponent(Button)
    self.startButton.onClick:AddListener(function() self:OnClickStartButton() end)

    self.stateText = self.mainTransform:FindChild("StateText"):GetComponent(Text)

    self.mainTransform:FindChild("PetHead"):GetComponent(Button).onClick:AddListener(function() self:OnClickPetHead() end)
    self.petHeadLoader = SingleIconLoader.New(self.mainTransform:FindChild("PetHead/Image").gameObject)
        
    self.mainTransform:FindChild("FormationButton"):GetComponent(Button).onClick:AddListener(function() self:OnClickFormationButton() end)
    self.formationButtonText = self.mainTransform:FindChild("FormationButton/Text"):GetComponent(Text)

    self.formationSelect = ArenaFormationSelect.New(self.model, self.mainTransform:FindChild("FormatChangeGuard").gameObject, self.assetWrapper, self._FormationSelectListener)
    self.formationSelect.gameObject.transform.localPosition = Vector3(0, 0, -300)
    self.guardSelect = ArenaGuardSelect.New(self.model, self.mainTransform:FindChild("TeamChangeGuard").gameObject, self.assetWrapper, self._GuardSelectListener)
    self.guardSelect.gameObject.transform.localPosition = Vector3(0, 0, -300)
    
    ---------------------------- 顶部

    self.changeRoomSettingButton = self.mainTransform:FindChild("Top/Button"):GetComponent(Button)
    self.changeRoomSettingButton.onClick:AddListener(function() self:OnClickChangeRoomSettingButton() end)

    self.roomDescText = self.mainTransform:FindChild("Top/RoomDesc"):GetComponent(Text)
    self.levText = self.mainTransform:FindChild("Top/LevText"):GetComponent(Text)
    self.roomType = self.mainTransform:FindChild("Top/RoomType"):GetComponent(Text)
    
    self.roomTypeEffect = GameObject.Instantiate(self:GetPrefab(string.format(AssetConfig.effect, 20486)))
    local effectTransform = self.roomTypeEffect.transform
    effectTransform:SetParent(self.roomType.transform)
    effectTransform.localScale = Vector3.one
    effectTransform.localPosition = Vector3(-58, 0, -300)
    effectTransform.localRotation = Quaternion.identity

    ---------------------------- 左部

    self.addItem = self.mainTransform:FindChild("Panel/OhterSide/AddItem")
    self.addItem:FindChild("Button"):GetComponent(Button).onClick:AddListener(function() self:OnClickInvitationEnemyButton() end)
    self.addItem:FindChild("Button1"):GetComponent(Button).onClick:AddListener(function() self:OnClickInvitationEnemyButton() end)
    self.addItemButton2 = self.addItem:FindChild("Button2"):GetComponent(Button)
    self.addItemButton2.onClick:AddListener(function() self:OnClickTalkButton() end)
    self.addItemButton3 = self.addItem:FindChild("Button3"):GetComponent(Button)
    self.addItemButton3.onClick:AddListener(function() self:OnClickBattleButton() end)

    self.addButton = self.addItem:FindChild("Button")

    self.mySideItemList = {}
    self.formationItemList = {}
    for i = 1, 5 do
        self.mySideItemList[i] = self.mainTransform:FindChild("Panel/MySide/Item"..i)

        if i ~= 1 then
            self.mainTransform:FindChild("Panel/MySide/Item"..i.."/ChangeGuardButton"):GetComponent(Button).onClick:AddListener(function() self:OnClickChangeGuardButton(i) end)
            self.mainTransform:FindChild("Panel/MySide/Item"..i.."/ChangeButton"):GetComponent(Button).onClick:AddListener(function() self:OnClickChangePosButton(i) end)
        end

        self.formationItemList[i] = {
            formation1 = self.mySideItemList[i]:Find("FormationInfo1").gameObject,
            formation2 = self.mySideItemList[i]:Find("FormationInfo2").gameObject,
            formation_txt1 = self.mySideItemList[i]:Find("FormationInfo1/Text"):GetComponent(Text),
            formation_img1 = self.mySideItemList[i]:Find("FormationInfo1/Image"):GetComponent(Image),
            formation_txt2 = self.mySideItemList[i]:Find("FormationInfo2/Text"):GetComponent(Text),
            formation_img2 = self.mySideItemList[i]:Find("FormationInfo2/Image"):GetComponent(Image),
            rect1 = self.mySideItemList[i]:Find("FormationInfo1"):GetComponent(RectTransform),
            rect2 = self.mySideItemList[i]:Find("FormationInfo2"):GetComponent(RectTransform),
        }
    end

    self.otherSideItemList = {}
    for i = 1, 5 do
        self.otherSideItemList[i] = self.mainTransform:FindChild("Panel/OhterSide/Item"..i)
    end

    self.mainTransform:FindChild("Panel/OhterSide/Item1/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:KickOff() end)

    local bubblePanel = self.mainTransform:FindChild("BubblePanel")
    for i = 1, 10 do
        self.bubbleList[i] = {}

        local bubbleItem = bubblePanel:GetChild(i-1)
        self.bubbleList[i].bubble = bubbleItem
        self.bubbleList[i].bubbleText = bubbleItem:Find("Text"):GetComponent(Text)
        self.bubbleList[i].Ext = MsgItemExt.New(self.bubbleList[i].bubbleText, 159.65, 19, 29)

        bubbleItem.gameObject:SetActive(false)
    end
    bubblePanel.gameObject:SetActive(true)
    ----------------------------

    self.chatnotice = self.transform:FindChild("Notice/ChatNotice").gameObject
    self.chatnotice_text = self.transform:FindChild("Notice/ChatNotice/Text"):GetComponent(Text)
    self.chatnotice:GetComponent(Button).onClick:AddListener(function() self:ChatNoticeClick() end)


    ----------------------------    

    self.OnOpenEvent:Fire()
    self:ClearMainAsset()
end

function CrossArenaRoomWindow:OnInitCompleted()
    while self.queue.len ~= 0 do
        local func = BaseUtils.dequeue(self.queue)
        if func == nil then
            break
        else
            func()
        end
    end
    BaseUtils.clearqueue(self.queue)
end

function CrossArenaRoomWindow:OnClickClose()
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    if self.model.myRoomData.target_rid ~= 0 and self.model.myRoomData.horn_rid ~= 0 then
        local battleString = string.format(TI18N("<color='#23F0F7'>%s</color>对<color='#23F0F7'>%s</color>"), self.model:GetMemberNameById(self.model.myRoomData.horn_rid, self.model.myRoomData.horn_platform, self.model.myRoomData.horn_zone_id)
                , self.model:GetMemberNameById(self.model.myRoomData.target_rid, self.model.myRoomData.target_platform, self.model.myRoomData.target_zone_id))
        local roleData = RoleManager.Instance.RoleData
        if TeamManager.Instance:HasTeam() and TeamManager.Instance:IsSelfCaptin() then
            data.content = string.format(TI18N("%s发起了<color='#ffff00'>决斗</color>，若提前离开房间将自动取消决斗，但<color='#ffff00'>不返还任何费用或奖励</color>，是否离开？"), battleString)
            data.sureCallback = function() 
                CrossArenaManager.Instance:Send20707()
                CrossArenaManager.Instance.model:CloseCrossArenaRoomWindow()
                CrossArenaManager.Instance.model:OpenCrossArenaRoomListWindow()
            end
            data.sureLabel = TI18N("确定离开")
            data.cancelLabel = TI18N("取消")
        elseif (roleData.id == self.model.myRoomData.horn_rid and roleData.platform == self.model.myRoomData.horn_platform and roleData.zone_id == self.model.myRoomData.horn_zone_id)
            or (roleData.id == self.model.myRoomData.target_rid and roleData.platform == self.model.myRoomData.target_platform and roleData.zone_id == self.model.myRoomData.target_zone_id) then
            data.content = string.format(TI18N("%s发起了<color='#ffff00'>决斗</color>，若提前离开房间将自动取消决斗，但<color='#ffff00'>不返还任何费用或奖励</color>，是否离开？"), battleString)
            data.sureCallback = function() 
                TeamManager.Instance:Send11708()
                CrossArenaManager.Instance.model:CloseCrossArenaRoomWindow()
                CrossArenaManager.Instance.model:OpenCrossArenaRoomListWindow()
            end
            data.sureLabel = TI18N("确定离开")
            data.cancelLabel = TI18N("取消")
        end
    else
        if TeamManager.Instance:HasTeam() and not TeamManager.Instance:IsSelfCaptin() then
            data.content = TI18N("<color='#ffff00'>退出房间</color>将同时<color='#ffff00'>退出队伍</color>，是否确定？")
            data.sureCallback = function() 
                TeamManager.Instance:Send11708()
                CrossArenaManager.Instance.model:CloseCrossArenaRoomWindow()
                CrossArenaManager.Instance.model:OpenCrossArenaRoomListWindow()
            end
            data.sureLabel = TI18N("确定退出")
            data.cancelLabel = TI18N("取消")
        else
            data.content = TI18N("是否确认<color='#ffff00'>退出房间</color>？")
            data.sureCallback = function() 
                CrossArenaManager.Instance:Send20707()
                CrossArenaManager.Instance.model:CloseCrossArenaRoomWindow()
                CrossArenaManager.Instance.model:OpenCrossArenaRoomListWindow()
            end
            data.sureLabel = TI18N("确定退出")
            data.cancelLabel = TI18N("取消")
        end
    end

    NoticeManager.Instance:ConfirmTips(data)
end

function CrossArenaRoomWindow:OnClickMini()
    if self.tweenId == nil then
        -- self.tweenId = Tween.Instance:Scale(self.gameObject, Vector3(0.1, 0.1, 1), 0.2, function() self.miniMark = true self.gameObject:SetActive(false) self:OnHide() self.tweenId = nil end, LeanTweenType.easeOutQuart).id
        self.tweenId = Tween.Instance:Scale(self.gameObject, Vector3(0.1, 0.1, 1), 0.2, function() self.miniMark = true self.gameObject:SetActive(false) self:OnHide() self.tweenId = nil end, LeanTweenType.easeOutQuart).id
        self.moveTweenId = Tween.Instance:MoveY(self.gameObject, -0.6, 0.2, function() self.moveTweenId = nil end, LeanTweenType.easeOutQuart).id

        self:ChangeChatMainCanvasPositionZ(0)
        self:ChangeChatMiniPositionZ(0)
    end
end

function CrossArenaRoomWindow:OnShow()
    self.model.currentSHList = BaseUtils.copytab(ShouhuManager.Instance.model.my_sh_list)
    table.sort(self.model.currentSHList, function(a,b) return a.score > b.score end)

    if self.miniMark then
        self.miniMark = false
        self.gameObject:SetActive(true)
        self.transform.localPosition = Vector3.zero
        self.transform.localScale = Vector3.one
    end

    self:Update()
    -- BaseUtils.dump(self.openArgs)

    if self.openArgs ~= nil then
        
    end

    self:RemoveListeners()
    self:AddListeners()

    if MainUIManager.Instance.MainUIIconView ~= nil then
        MainUIManager.Instance.MainUIIconView:hide_icon_by_idlist(303, true)
    end

    self:ChangeChatMainCanvasPositionZ(-300)
    self:ChangeChatMiniPositionZ(300)
    self:AdaptIPhoneX()
end

function CrossArenaRoomWindow:OnHide()
    for k,v in pairs(self.myPreviewTabList) do
        if v.previewComp ~= nil then
            v.previewComp:DeleteMe()
            v.previewComp = nil
        end
    end

    for k,v in pairs(self.otherPreviewTabList) do
        if v.previewComp ~= nil then
            v.previewComp:DeleteMe()
            v.previewComp = nil
        end
    end

    self:RemoveListeners()

    self:ChangeChatMainCanvasPositionZ(0)
    self:ChangeChatMiniPositionZ(0)
end

function CrossArenaRoomWindow:AddListeners()
    EventMgr.Instance:AddListener(event_name.adapt_iphonex, self.adaptListener)

    CrossArenaManager.Instance.OnUpdateRoomInfo:AddListener(self._Update)
    EventMgr.Instance:AddListener(event_name.formation_update, self._UpdateFormation)
    EventMgr.Instance:AddListener(event_name.battlepet_update, self._UpdatePet)
    EventMgr.Instance:AddListener(event_name.begin_fight, self._UpdateFight)
    EventMgr.Instance:AddListener(event_name.end_fight, self._UpdateFight)
    EventMgr.Instance:AddListener(event_name.chat_main_show, self._OnChatMain)
    EventMgr.Instance:AddListener(event_name.mainui_notice_update, self._UpdateNotice)
end

function CrossArenaRoomWindow:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.adapt_iphonex, self.adaptListener)
    
    CrossArenaManager.Instance.OnUpdateRoomInfo:RemoveListener(self._Update)
    EventMgr.Instance:RemoveListener(event_name.formation_update, self._UpdateFormation)
    EventMgr.Instance:RemoveListener(event_name.battlepet_update, self._UpdatePet)
    EventMgr.Instance:RemoveListener(event_name.begin_fight, self._UpdateFight)
    EventMgr.Instance:RemoveListener(event_name.end_fight, self._UpdateFight)
    EventMgr.Instance:RemoveListener(event_name.chat_main_show, self._OnChatMain)
    EventMgr.Instance:RemoveListener(event_name.mainui_notice_update, self._UpdateNotice)
end

function CrossArenaRoomWindow:OnChatMain(bool)
    if bool then
        LuaTimer.Add(150, function()
            -- self.transform.localPosition = Vector3(0, 0, 300)
            self:ChangeChatMainCanvasPositionZ(-300)

            self:SetPreviewShow(1, 1, false)
            self:SetPreviewShow(1, 2, false)
            self:SetPreviewShow(1, 3, false)
            self:SetPreviewShow(2, 1, false)
            self:SetPreviewShow(2, 2, false)
            self:SetPreviewShow(2, 3, false)
        end)
    else
        LuaTimer.Add(150, function()
            -- self.transform.localPosition = Vector3(0, 0, 0)
            self:SetPreviewShow(1, 1, true)
            self:SetPreviewShow(1, 2, true)
            self:SetPreviewShow(1, 3, true)
            self:SetPreviewShow(2, 1, true)
            self:SetPreviewShow(2, 2, true)
            self:SetPreviewShow(2, 3, true)
        end)
    end
end

function CrossArenaRoomWindow:UpdateFight()
    local roleData = RoleManager.Instance.RoleData
    if roleData.status == RoleEumn.Status.Fight then
        self:OnClickMini()
    else
        self:OnShow()
    end
end

function CrossArenaRoomWindow:Update()
    self:UpdatePet()
    self:UpdateFormation()
    self:UpdateRoomInfo()
    self:UpdateMember()
    self:UpdateButton()
    self:UpdateNotice()
end

function CrossArenaRoomWindow:UpdatePet()
    local data = PetManager.Instance.model.battle_petdata
    if data == nil then
        self.petHeadLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "BidAddImage"))
        self.petHeadLoader.image.rectTransform.sizeDelta = Vector2(32, 36)
    else
        self.petHeadLoader:SetSprite(SingleIconType.Pet, data.base.head_id)
        self.petHeadLoader.image.rectTransform.sizeDelta = Vector2(64, 64)
    end
end

function CrossArenaRoomWindow:UpdateFormation()
    local typeData = TeamManager.Instance.TypeData
    local formationId = typeData.team_formation
    local formationLev = typeData.team_formation_lev
    if not TeamManager.Instance:IsSelfCaptin() then
        formationId = FormationManager.Instance.formationId
        formationLev = FormationManager.Instance.formationLev
    end
    
    local attrs = {{}, {}, {}, {}, {}}
    local formationData = DataFormation.data_list[formationId.."_"..formationLev]
    if formationData ~= nil then
        self.formationButtonText.text = formationData.name.."Lv."..formationLev

        attrs = {formationData.attr_1, formationData.attr_2, formationData.attr_3, formationData.attr_4, formationData.attr_5}
    end

    for i,attr in ipairs(attrs) do
        local formationItem = self.formationItemList[i]
        if #attr == 0 then
            formationItem.formation2:SetActive(false)
            formationItem.formation_txt2.gameObject:SetActive(false)
            formationItem.formation_img2.gameObject:SetActive(false)

            formationItem.formation1:SetActive(true)
            formationItem.formation_txt1.gameObject:SetActive(true)
            formationItem.formation_img1.gameObject:SetActive(false)

            formationItem.formation_txt1.text = TI18N("无加成")
            formationItem.rect1.anchoredPosition = Vector2(5, -52)
        elseif #attr == 1 then
            formationItem.formation1:SetActive(true)
            formationItem.formation2:SetActive(false)
            formationItem.formation_txt1.gameObject:SetActive(true)
            formationItem.formation_img1.gameObject:SetActive(true)
            formationItem.formation_txt2.gameObject:SetActive(false)
            formationItem.formation_img2.gameObject:SetActive(false)

            formationItem.formation_txt1.text = KvData.attr_name_show[attr[1].attr_name]
            if attr[1].val > 0 then
                formationItem.formation_img1.sprite = self.assetWrapper:GetSprite(AssetConfig.crossarena_textures, "GreenUp")
            else
                formationItem.formation_img1.sprite = self.assetWrapper:GetSprite(AssetConfig.crossarena_textures, "RedDown")
            end
            formationItem.rect1.anchoredPosition = Vector2(0, -52)

        elseif #attr == 2 then
            formationItem.formation1:SetActive(true)
            formationItem.formation2:SetActive(true)
            formationItem.formation_txt1.gameObject:SetActive(true)
            formationItem.formation_img1.gameObject:SetActive(true)
            formationItem.formation_txt2.gameObject:SetActive(true)
            formationItem.formation_img2.gameObject:SetActive(true)

            formationItem.formation_txt1.text = KvData.attr_name_show[attr[1].attr_name]
            formationItem.formation_txt2.text = KvData.attr_name_show[attr[2].attr_name]
            if attr[1].val > 0 then
                formationItem.formation_img1.sprite = self.assetWrapper:GetSprite(AssetConfig.crossarena_textures, "GreenUp")
            else
                formationItem.formation_img1.sprite = self.assetWrapper:GetSprite(AssetConfig.crossarena_textures, "RedDown")
            end
            formationItem.rect1.anchoredPosition = Vector2(-28, -52)

            if attr[2].val > 0 then
                formationItem.formation_img2.sprite = self.assetWrapper:GetSprite(AssetConfig.crossarena_textures, "GreenUp")
            else
                formationItem.formation_img2.sprite = self.assetWrapper:GetSprite(AssetConfig.crossarena_textures, "RedDown")
            end
            formationItem.rect2.anchoredPosition = Vector2(31, -52)
        end
    end
end

function CrossArenaRoomWindow:UpdateRoomInfo()
    if self.model.myRoomData == nil then
        return
    end
    local data = self.model.myRoomData

    self.roomDescText.text = data.name
    if data.room_lev_min == 0 and data.min_lev_break == 0 and data.room_lev_max == 200 and data.max_lev_break == 1 then
        self.levText.text = TI18N("任意等级")
    else
        self.levText.text = string.format(TI18N("%s-%s级"), CrossArenaManager.Instance:GetLevelString(data.room_lev_min, data.min_lev_break), CrossArenaManager.Instance:GetLevelString(data.room_lev_max, data.max_lev_break))
    end
    -- if data.mode == 0 then
    --     self.roomType.text = TI18N("无限制")
    -- elseif data.mode == 1 then
    --     self.roomType.text = TI18N("1v1单挑")
    -- elseif data.mode == 2 then
    --     self.roomType.text = TI18N("多人组队")
    -- end
    if data.provocation_type == 0 then
        self.roomType.text = TI18N("友谊赛")
        self.roomTypeEffect.gameObject:SetActive(false)
    else
        self.roomType.text = TI18N("跨服决斗")
        self.roomTypeEffect.gameObject:SetActive(true)
    end

    if data.password == "" then
        self.mainTransform:FindChild("Top/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.crossarena_textures, "UnLock")
    else
        self.mainTransform:FindChild("Top/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.crossarena_textures, "Lock")
    end
end

function CrossArenaRoomWindow:UpdateMember()
    if self.model.myRoomData == nil then
        return
    end

    self.mySide, self.isTeamLeader, self.isRoomOwner = self.model:FindMyState()
    if self.mySide == 0 then
        return
    end

    local data = nil
    local modelData = nil

    self.myMemberData = self.model:GetMember(self.mySide)
    self.myGuardsData = self.model:GetGuards(self.mySide)
    for index, item in ipairs(self.mySideItemList) do
        data = self.myMemberData[index]
        if data ~= nil  then -- 是队员
            item:Find("Name/Text"):GetComponent(Text).text = data.name
            item:Find("Classes"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" .. data.classes)
            item:Find("Classes").gameObject:SetActive(true)
            item:Find("Preview").gameObject:SetActive(true)
            item:Find("ChangeGuardButton").gameObject:SetActive(false)
            item:Find("GuardMark").gameObject:SetActive(false)
            item:Find("Shadow").gameObject:SetActive(false)
            item:Find("LevelText").gameObject:SetActive(true)
            item:Find("LevelText"):GetComponent(Text).text = string.format("<color='#2763B0'>Lv.%s</color>", data.lev)

            if self.mySide == 1 and index == 1 then
                item:Find("TeamLeaderMark").gameObject:SetActive(true)
            else
                item:Find("TeamLeaderMark").gameObject:SetActive(false)
            end

            modelData = {type = PreViewType.Role, classes = data.classes, sex = data.sex, looks = data.looks}
            self:SetPreview(1, index, item, modelData)
        else -- 没有队员，找守护顶上
            data = self.myGuardsData[index-#self.myMemberData]
            if data == nil then -- 没有守护，重置item
                item:Find("Name/Text"):GetComponent(Text).text = TI18N("<color='#ffff00'>未上阵</color>")
                item:Find("Classes").gameObject:SetActive(false)
                item:Find("Preview").gameObject:SetActive(false)
                item:Find("ChangeGuardButton").gameObject:SetActive(true)
                item:Find("GuardMark").gameObject:SetActive(true)
                item:Find("Shadow").gameObject:SetActive(true)
                item:Find("TeamLeaderMark").gameObject:SetActive(false)
                item:Find("LevelText").gameObject:SetActive(false)
            else
                local baseData = DataShouhu.data_guard_base_cfg[data.base_id]

                local res_id = baseData.res_id
                local animation_id = baseData.animation_id
                local paste_id = baseData.paste_id
                local wakeUpCfgData = DataShouhu.data_guard_wakeup_upgrade[string.format("%s_%s", data.base_id, data.quality)]
                if wakeUpCfgData ~= nil and wakeUpCfgData.model ~= 0 then
                    res_id = wakeUpCfgData.model
                    paste_id = wakeUpCfgData.skin
                    animation_id = wakeUpCfgData.animation
                end

                item:Find("Name/Text"):GetComponent(Text).text = baseData.name
                item:Find("Classes").gameObject:SetActive(false)
                item:Find("Preview").gameObject:SetActive(true)
                item:Find("ChangeGuardButton").gameObject:SetActive(true)
                item:Find("GuardMark").gameObject:SetActive(true)
                item:Find("Shadow").gameObject:SetActive(false)
                item:Find("TeamLeaderMark").gameObject:SetActive(false)
                item:Find("LevelText").gameObject:SetActive(false)

                modelData = {type = PreViewType.Npc, skinId = paste_id, modelId = res_id, animationId = animation_id, scale = 1}
                self:SetPreview(1, index, item, modelData)

                -- modelData = {type = PreViewType.Role, classes = 1, sex = 1, looks = {}}
                -- self:SetPreview(1, index, item, modelData)
            end
        end
    end

    local otherSide = 1
    if self.mySide == 1 then
        otherSide = 2
    end
    local memberData = self.model:GetMember(otherSide)
    local guardsData = self.model:GetGuards(otherSide)
    for index, item in ipairs(self.otherSideItemList) do
        data = memberData[index]
        if data ~= nil  then -- 是队员
            item:Find("Name/Text"):GetComponent(Text).text = data.name
            item:Find("Classes"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" .. data.classes)
            item:Find("Classes").gameObject:SetActive(true)
            item:Find("Preview").gameObject:SetActive(true)
            item:Find("ChangeGuardButton").gameObject:SetActive(false)
            item:Find("GuardMark").gameObject:SetActive(false)
            item:Find("Shadow").gameObject:SetActive(false)
            item:Find("LevelText").gameObject:SetActive(true)
            item:Find("LevelText"):GetComponent(Text).text = string.format("<color='#2763B0'>Lv.%s</color>", data.lev)

            if self.mySide == 2 and index == 1 then
                item:Find("TeamLeaderMark").gameObject:SetActive(true)
            else
                item:Find("TeamLeaderMark").gameObject:SetActive(false)
            end

            if self.isRoomOwner and index == 1 then
                item:Find("CloseButton").gameObject:SetActive(true)
            else
                item:Find("CloseButton").gameObject:SetActive(false)
            end

            -- 不显示模型了，改为图片
            -- modelData = {type = PreViewType.Role, classes = data.classes, sex = data.sex, looks = data.looks}
            -- self:SetPreview(2, index, item, modelData)

            item:Find("Preview/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.classcardgroup_textures, string.format("%s_%s", data.classes, data.sex))

        else -- 没有队员，找守护顶上
            data = guardsData[index-#memberData]
            if data == nil then -- 没有守护，重置item
                item:Find("Name/Text"):GetComponent(Text).text = TI18N("<color='#ffff00'>未上阵</color>")
                item:Find("Classes").gameObject:SetActive(false)
                item:Find("Preview").gameObject:SetActive(false)
                item:Find("ChangeGuardButton").gameObject:SetActive(false)
                item:Find("GuardMark").gameObject:SetActive(false)
                item:Find("Shadow").gameObject:SetActive(true)
                item:Find("TeamLeaderMark").gameObject:SetActive(false)
                item:Find("LevelText").gameObject:SetActive(false)
            else
                item:Find("Name/Text"):GetComponent(Text).text = TI18N("守护")
                item:Find("Classes").gameObject:SetActive(false)
                item:Find("Preview").gameObject:SetActive(false)
                item:Find("ChangeGuardButton").gameObject:SetActive(false)
                item:Find("GuardMark").gameObject:SetActive(false)
                item:Find("Shadow").gameObject:SetActive(true)
                item:Find("TeamLeaderMark").gameObject:SetActive(false)
                item:Find("LevelText").gameObject:SetActive(false)
            end
        end
    end

    if #memberData == 0 then
        self.addItem.gameObject:SetActive(true)
        self:ShowDuang(true)
        self.otherSideItemList[1].gameObject:SetActive(false)
    else
        self.addItem.gameObject:SetActive(false)
        self:ShowDuang(false)
        self.otherSideItemList[1].gameObject:SetActive(true)
    end
end

function CrossArenaRoomWindow:UpdateButton()
    if self.model.myRoomData == nil then
        return
    end

    -- if self.isRoomOwner then
    --     self.changeRoomSettingButton.gameObject:SetActive(true)
    -- else
    --     self.changeRoomSettingButton.gameObject:SetActive(false)
    -- end

    if self.isTeamLeader then
        if self.isRoomOwner then
            -- self.mainTransform:FindChild("Button2/Text"):GetComponent(Text).text = TI18N("发布招募")
            self.mainTransform:FindChild("Button2/Text"):GetComponent(Text).text = TI18N("队伍聊天")
        else
            self.mainTransform:FindChild("Button2/Text"):GetComponent(Text).text = TI18N("队伍聊天")
        end
    else
        self.mainTransform:FindChild("Button2/Text"):GetComponent(Text).text = TI18N("顶替队长")
    end

    self:ShowStartButtonEffect(false)
    if self.mySide == 1 then
        self.mainTransform:FindChild("Button3/Text"):GetComponent(Text).text = TI18N("开 战")
        if self.isTeamLeader then
            if self.model.myRoomData.status ~= 3 then
                self.mainTransform:FindChild("Button3/Text"):GetComponent(Text).color = ColorHelper.DefaultButton4
                self.mainTransform:FindChild("Button3"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            else
                self.mainTransform:FindChild("Button3/Text"):GetComponent(Text).color = ColorHelper.DefaultButton3
                self.mainTransform:FindChild("Button3"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                self:ShowStartButtonEffect(true)
            end
        else
            self.mainTransform:FindChild("Button3/Text"):GetComponent(Text).color = ColorHelper.DefaultButton4
            self.mainTransform:FindChild("Button3"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        end
    else
        if self.isTeamLeader then
            self.mainTransform:FindChild("Button3/Text"):GetComponent(Text).color = ColorHelper.DefaultButton3
            self.mainTransform:FindChild("Button3"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            if self.model.myRoomData.status ~= 3 then
                self.mainTransform:FindChild("Button3/Text"):GetComponent(Text).text = TI18N("准 备")
                self:ShowStartButtonEffect(true)
            else
                self.mainTransform:FindChild("Button3/Text"):GetComponent(Text).text = TI18N("已准备")
            end
        else
            self.mainTransform:FindChild("Button3/Text"):GetComponent(Text).text = TI18N("准 备")
            self.mainTransform:FindChild("Button3/Text"):GetComponent(Text).color = ColorHelper.DefaultButton4
            self.mainTransform:FindChild("Button3"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        end
    end

    if self.isTeamLeader then
        if self.mySide == 1 then
            if self.model.myRoomData.status ~= 3 then
                self.mainTransform:FindChild("StateText"):GetComponent(Text).text = TI18N("等待对手准备")
            else
                self.mainTransform:FindChild("StateText"):GetComponent(Text).text = ""
            end
        else
            -- if self.model.myRoomData.status ~= 3 then
            --     self.mainTransform:FindChild("StateText"):GetComponent(Text).text = TI18N("等待对手准备")
            -- else
            --     self.mainTransform:FindChild("StateText"):GetComponent(Text).text = ""
            -- end
            self.mainTransform:FindChild("StateText"):GetComponent(Text).text = ""
        end
    else
        if self.model.myRoomData.status ~= 3 then
            self.mainTransform:FindChild("StateText"):GetComponent(Text).text = TI18N("等待队长操作")
        else
            self.mainTransform:FindChild("StateText"):GetComponent(Text).text = ""
        end
    end

    -- if self.model.myRoomData.provocation_type == 0 then
    --     self.addItemButton2.gameObject:SetActive(true)
    --     self.addItemButton3.gameObject:SetActive(false)
    -- else
    --     self.addItemButton2.gameObject:SetActive(false)
    --     self.addItemButton3.gameObject:SetActive(true)
    --     if self.model.myRoomData.target_rid == 0 and self.model.myRoomData.horn_rid == 0 then
    --         self.addItemButton3:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
    --         self.addItemButton3.transform:Find("Text"):GetComponent(Text).color = ColorHelper.DefaultButton3
    --         self.addItemButton3.transform:Find("Text"):GetComponent(Text).text = TI18N("发起决斗")
    --     else
    --         self.addItemButton3:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
    --         self.addItemButton3.transform:Find("Text"):GetComponent(Text).color = ColorHelper.DefaultButton4
    --         self.addItemButton3.transform:Find("Text"):GetComponent(Text).text = TI18N("等待应战")
    --     end
    -- end

    self.addItemButton2.gameObject:SetActive(true)
    self.addItemButton3.gameObject:SetActive(false)
    if self.model.myRoomData.provocation_type == 0 then
        self.addItemButton2:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.addItemButton2.transform:Find("Text"):GetComponent(Text).color = ColorHelper.DefaultButton3
        self.addItemButton2.transform:Find("Text"):GetComponent(Text).text = TI18N("聊天招募")
    else
        self.addItemButton2:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.addItemButton2.transform:Find("Text"):GetComponent(Text).color = ColorHelper.DefaultButton4
        self.addItemButton2.transform:Find("Text"):GetComponent(Text).text = TI18N("聊天招募")
    end
end

function CrossArenaRoomWindow:UpdateNotice()
    if MainUIManager.Instance.noticeView ~= nil then
        local chatnoticeNum = MainUIManager.Instance.noticeView.chatnotice_num
        if chatnoticeNum == 0 then
            self.chatnotice:SetActive(false)
        else
            self.chatnotice:SetActive(true)
            self.chatnotice_text.text = tostring(chatnoticeNum)
        end
    end
end

function CrossArenaRoomWindow:SetPreview(side, index, item, modelData)
    if item ~= nil and modelData ~= nil then
        local previewTabList = self.myPreviewTabList
        -- 对方不用模型预览了，屏蔽掉
        -- if side ~= self.mySide then
        --     previewTabList = self.otherPreviewTabList
        -- end
        local tab = previewTabList[index]
        if tab == nil then
            tab = {}
            previewTabList[index] = tab
        end

        local callback = function(composite)

        end
        
        if modelData.scale == nil then
            modelData.scale = 1.1
        else
            modelData.scale = modelData.scale * 1.1
        end
        if tab.previewComp == nil then
            local setting = {
                name = string.format("CrossArenaRoomWindow_%s_%s", side, index)
                ,layer = "UI"
                ,parent = item:Find("Preview/Image")
                ,localRot = Vector3(0, 0, 0)
                ,localPos = Vector3(0, -60, -150)
                ,usemask = false
                ,sortingOrder = 10
            }
            tab.previewComp = PreviewmodelComposite.New(callback, setting, modelData)
            tab.parent = item:Find("Preview")
        else
            if not BaseUtils.sametab(tab.modelData, modelData) then
                tab.previewComp:Reload(modelData, callback)
            end
        end
        tab.modelData = modelData
        tab.previewComp:Show()
        tab.previewComp:PlayAction(FighterAction.Stand)
    end
end

function CrossArenaRoomWindow:SetPreviewShow(side, index, show)
    local previewTabList = self.myPreviewTabList
    if side ~= self.mySide then
        previewTabList = self.otherPreviewTabList
    end
    local tab = previewTabList[index]
    if tab ~= nil and tab.previewComp ~= nil then
        if show then
            tab.parent.gameObject:SetActive(true)
            tab.previewComp:Show()
            tab.previewComp:PlayAction(FighterAction.Stand)
        else
            tab.parent.gameObject:SetActive(false)
            tab.previewComp:Hide()
        end
    end
end

function CrossArenaRoomWindow:OnClickInvitationButton() 
    if self.invitationPanel == nil then
        local setting = {
            ismulti = true,
            callback = function(list) self.model:SendInvitationFriend(list) end,
            list_type = 3,
            btnname = TI18N("邀 请"),
            localPosition = Vector3(0, 0, -300)
        }
        self.invitationPanel = FriendSelectPanel.New(self.gameObject, setting)
    end
    self.invitationPanel:Show()
end

function CrossArenaRoomWindow:OnClickSkipperButton() 
    if self.model.myRoomData == nil then
        return
    end

    if self.isTeamLeader then
        if self.isRoomOwner then
            -- 发布招募
            -- local btns = {}
            -- table.insert(btns, {label = TI18N("世界频道"), callback = function() CrossArenaManager.Instance.model:PublicRecruit(2, MsgEumn.ChatChannel.World) end})
            -- table.insert(btns, {label = TI18N("约战场景"), callback = function() CrossArenaManager.Instance.model:PublicRecruit(2, MsgEumn.ChatChannel.Scene) end})
            -- table.insert(btns, {label = TI18N("公会频道"), callback = function() CrossArenaManager.Instance.model:PublicRecruit(2, MsgEumn.ChatChannel.Guild) end})
            -- table.insert(btns, {label = TI18N("跨服频道"), callback = function() CrossArenaManager.Instance.model:PublicRecruit(2, MsgEumn.ChatChannel.MixWorld) end})
            -- TipsManager.Instance:ShowButton({gameObject = self.skipperButton.gameObject, data = btns})

            self.transform:SetSiblingIndex(3)
            ChatManager.Instance.model:ShowChatWindow({2})
        else
            -- 队伍聊天
            self.transform:SetSiblingIndex(3)
            ChatManager.Instance.model:ShowChatWindow({2})
        end
    else
        -- 顶替队长
        TeamManager.Instance:Send11730()
    end
end

function CrossArenaRoomWindow:OnClickStartButton() 
    if self.model.myRoomData == nil then
        return
    end

    if self.mySide == 1 then
        if self.isTeamLeader then
            if self.model.myRoomData.status ~= 3 then
                -- NoticeManager.Instance:FloatTipsByString(TI18N("对方还没准备好"))
                ChatManager.Instance:Send10400(MsgEumn.ChatChannel.Scene, TI18N("我方准备好了，请准备{face_1,7}"))
            else
                -- 开战
                if self.model.myRoomData.provocation_type == 0 then
                    CrossArenaManager.Instance:Send20711()    
                else
                    local confirmData = NoticeConfirmData.New()
                    confirmData.type = ConfirmData.Style.Normal
                    confirmData.content = TI18N("正在进行<color='#ffff00'>跨服决斗</color>，战斗开始后<color='#ffff00'>双方队长</color>将消耗<color='#ffff00'>300</color>{assets_2, 90002}战斗结束后，胜方队长将获得<color='#FAA507'>[不服就战·称号卡]</color>和<color='#AA23D6'>[决斗胜利红包]</color>战斗结果将全服公告，战败方无奖励")
                    confirmData.sureLabel = TI18N("确认开始")
                    confirmData.cancelLabel = TI18N("取消")
                    confirmData.sureCallback = function()
                            CrossArenaManager.Instance:Send20711()
                        end
                    NoticeManager.Instance:ConfirmTips(confirmData)
                end
            end
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("等待队长操作"))
        end
    else
        if self.isTeamLeader then
            if self.model.myRoomData.status ~= 3 then
                -- 准备
                if self.model.myRoomData.provocation_type == 0 then
                    CrossArenaManager.Instance:Send20710()
                else
                    local confirmData = NoticeConfirmData.New()
                    confirmData.type = ConfirmData.Style.Normal
                    confirmData.content = TI18N("正在进行<color='#ffff00'>跨服决斗</color>，战斗开始后<color='#ffff00'>双方队长</color>将消耗<color='#ffff00'>300</color>{assets_2, 90002}战斗结束后，胜方队长将获得<color='#FAA507'>[不服就战·称号卡]</color>和<color='#AA23D6'>[决斗胜利红包]</color>战斗结果将全服公告，战败方无奖励")
                    confirmData.sureLabel = TI18N("确认准备")
                    confirmData.cancelLabel = TI18N("取消")
                    confirmData.sureCallback = function()
                            CrossArenaManager.Instance:Send20710()
                        end
                    NoticeManager.Instance:ConfirmTips(confirmData)
                end
            else
                CrossArenaManager.Instance:Send20719()
            end
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("等待队长操作"))
        end
    end
end

function CrossArenaRoomWindow:OnClickPetHead()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.petselect, { function() end, function(data) 
        if data == nil then
            NoticeManager.Instance:FloatTipsByString(TI18N("请选择出战宠物"))
        else
            PetManager.Instance:Send10501(data.id, 1)
        end
    end })
end

function CrossArenaRoomWindow:OnClickFormationButton()
    self.guardSelect:Hiden()
    if self.formationSelect.isOpen == true then
        self.formationSelect:Hiden()
    else
        self.formationSelect:Show(FormationManager.Instance.formationList, FormationManager.Instance.formationId)
    end
end


function CrossArenaRoomWindow:OnClickChangeRoomSettingButton()
    if self.isRoomOwner then
        self.model:OpenCrossArenaCreateTeamWindow({2})
    else
        TipsManager.Instance:ShowText({gameObject = self.changeRoomSettingButton.gameObject
            , itemData = {TI18N("<color='#ffff00'>友谊赛模式</color>")
                        , TI18N("以武会友，自由对战 ")
                        , TI18N("<color='#ffff00'>跨服决斗模式</color>")
                        , TI18N("双方队长消耗300钻，获胜者将赢得荣誉和奖励")}
            })
    end
end

function CrossArenaRoomWindow:OnClickInvitationEnemyButton()
    if self.invitationEnemyPanel == nil then
        local setting = {
            ismulti = false,
            callback = function(list) self.model:SendInvitation(list) end,
            list_type = 3,
            btnname = TI18N("邀 请"),
            localPosition = Vector3(0, 0, -300)
        }
        self.invitationEnemyPanel = FriendSelectPanel.New(self.gameObject, setting)
    end
    self.invitationEnemyPanel:Show()
end

function CrossArenaRoomWindow:OnClickTalkButton()
    if self.model.myRoomData.provocation_type == 0 then
        local btns = {}
        table.insert(btns, {label = TI18N("世界频道"), callback = function() CrossArenaManager.Instance.model:PublicRecruit(1, MsgEumn.ChatChannel.World) end})
        table.insert(btns, {label = TI18N("约战场景"), callback = function() CrossArenaManager.Instance.model:PublicRecruit(1, MsgEumn.ChatChannel.Scene) end})
        table.insert(btns, {label = TI18N("公会频道"), callback = function() CrossArenaManager.Instance.model:PublicRecruit(1, MsgEumn.ChatChannel.Guild) end})
        table.insert(btns, {label = TI18N("跨服频道"), callback = function() CrossArenaManager.Instance.model:PublicRecruit(1, MsgEumn.ChatChannel.MixWorld) end})
        -- TipsManager.Instance:ShowButton({gameObject = self.addItem:FindChild("Button2").gameObject, data = btns})
        TipsManager.Instance:ShowButton({gameObject = self.mainTransform:FindChild("Panel/OhterSide/Item3").gameObject, data = btns})
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("<color='#ffff00'>决斗模式</color>请直接邀请对手{face_1,2}"))
    end
end

function CrossArenaRoomWindow:OnClickBattleButton() 
    if self.model.myRoomData ~= nil and self.model.myRoomData.target_rid == 0 and self.model.myRoomData.horn_rid == 0 then
        self.model:OpenCrossArenaFighterWindow()
    else
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("已对%s发起决斗邀请，请耐心等待{face_1,25}"), self.model:GetMemberNameById(self.model.myRoomData.target_rid, self.model.myRoomData.target_platform, self.model.myRoomData.target_zone_id)))
    end
end

function CrossArenaRoomWindow:OnClickChangeGuardButton(index)
    self.formationSelect:Hiden()
    if self.guardSelect.isOpen == true then
        self.guardSelect:Hiden()
    else
        local typeData = TeamManager.Instance.TypeData
        local formationId = typeData.team_formation
        local formationLev = typeData.team_formation_lev
        if not TeamManager.Instance:IsSelfCaptin() then
            formationId = FormationManager.Instance.formationId
            formationLev = FormationManager.Instance.formationLev
        end

        local curBaseId = 0
        local guardIndex = index - #self.myMemberData
        if self.myGuardsData[guardIndex] then
            curBaseId = self.myGuardsData[guardIndex].base_id
        end
        self.guardWarId = curBaseId

        for i, v in ipairs(self.myGuardsData) do
            self.model["guardId"..i] = v.base_id
        end
        self.guardSelect:Show(self.model.currentSHList, index-1, curBaseId, {id = formationId, lev = formationLev}, Vector2(-70 + (index - 2) * 140, -15))
    end
end

function CrossArenaRoomWindow:OnClickChangePosButton(index)
    if self.myMemberData[index] == nil and self.myGuardsData[index-#self.myMemberData] == nil then
        self:OnClickChangeGuardButton(index)
        return
    end

    if TeamManager.Instance:MyStatus() ~= RoleEumn.TeamStatus.Leader and TeamManager.Instance:MyStatus() ~= RoleEumn.TeamStatus.None then
        --队长才能进入交互位置模式
        return
    end

    if self.changePosMode then
        if index == self.changePosIndex then
            --重复点击为取消选中
            -- self.mainPanel:ChangeButtonType("normal")
            self.changePosIndex = 0
            self:ExitChangeMode()
        else
            local data = self.myMemberData[index]
            local type = 1 -- 1.玩家 2.守护
            if data == nil then
                data = self.myGuardsData[index-#self.myMemberData]
                type = 2
            end

            local selectData = self.myMemberData[self.changePosIndex]
            local selectType = 1 -- 1.玩家 2.守护
            if selectData == nil then
                selectData = self.myGuardsData[self.changePosIndex-#self.myMemberData]
                selectType = 2
            end

            if type ~= selectType then
                NoticeManager.Instance:FloatTipsByString(TI18N("玩家和守护无法交换位置"))
            else
                if type == 1 then
                    -- 人换人
                    FormationManager.Instance:Send12903(data.rid, data.platform, data.zone_id, selectData.rid, selectData.platform, selectData.zone_id)
                else
                    -- 守护换守护
                    FormationManager.Instance:Send12905(data.base_id, 1, selectData.base_id)
                end
            end
            self.changePosIndex = 0
            self:ExitChangeMode()
        end
    else
        if index == self.changePosIndex then
            --重复点击为取消选中
            self:ExitChangeMode()
            -- self.mainPanel:ChangeButtonType("normal")
            self.changePosIndex = 0
        else
            self:ExitChangeMode()
            self.changePosIndex = index
            self.mySideItemList[index]:Find("Select").gameObject:SetActive(true)
            self.changePosMode = true
            for i,item in ipairs(self.mySideItemList) do
                if i ~= 1 and i ~= self.changePosIndex then
                    item:Find("Black").gameObject:SetActive(true)
                    item:Find("Select").gameObject:SetActive(false)
                end
            end
        end
    end
end

--退出交互模式
function CrossArenaRoomWindow:ExitChangeMode()
    for i,item in ipairs(self.mySideItemList) do
        if i ~= 1 then
            item:Find("Black").gameObject:SetActive(false)
            item:Find("Select").gameObject:SetActive(false)
        end
    end
    self.changePosMode = false
end

function CrossArenaRoomWindow:KickOff()
    if self.isRoomOwner then
        local provocation_team = self.model.myRoomData.provocation_team[2]
        if provocation_team ~= nil then
            local leaderData = nil
            for i, v in ipairs(provocation_team.team_mate) do
                if v.status == 1 or (v.status == 3 and #provocation_team.team_mate == 1) then
                    leaderData = v
                end
            end
            if leaderData ~= nil then
                CrossArenaManager.Instance:Send20708(leaderData.rid, leaderData.platform, leaderData.zone_id)
            end
        end
    end
end

function CrossArenaRoomWindow:FormationSelectListener(index)
    self.guardSelect:Hiden()
    self.formationSelect:Hiden()
    self.formationSelect:UnSelect(self.formationSelect.lastSelect)
    local tab = self.formationSelect.selectTab
    if self.formationSelect.lastSelect ~= nil then
        tab[self.formationSelect.lastSelect] = false
    end
    tab[index] = true
    self.formationSelect.lastSelect = index
    self.formationSelect:Select(self.formationSelect.lastSelect)

    local selectIndex = self.formationSelect:GetSelection()
    if selectIndex ~= nil then
        local selectID = FormationManager.Instance.formationList[selectIndex].id
        FormationManager.Instance:Send12901(selectID)
    end
end

function CrossArenaRoomWindow:GuardSelectListener(index)
    self.guardSelect:Hiden()
    self.formationSelect:Hiden()
    self.guardSelect:UnSelect(self.guardSelect.lastSelect)
    local tab = self.guardSelect.selectTab
    if self.guardSelect.lastSelect == nil then
        tab[index] = true
        self.guardSelect.lastSelect = index
    elseif self.guardSelect.lastSelect == index then
        tab[index] = false
        self.guardSelect.lastSelect = nil
    else
        tab[self.guardSelect.lastSelect] = false
        tab[index] = true
        self.guardSelect.lastSelect = index
    end
    self.guardSelect:Select(self.guardSelect.lastSelect)

    local selectIndex = self.guardSelect:GetSelection()
    if selectIndex ~= nil then
        local base_id = self.model.currentSHList[selectIndex].base_id
        FormationManager.Instance:Send12905(base_id, 1, self.guardWarId)
    end
end

function CrossArenaRoomWindow:ShowStartButtonEffect(show)
    if show then
        if self.startButtonEffect == nil then
            local fun = function(effectView)
                local effectObject = effectView.gameObject
                effectObject.transform:SetParent(self.mainTransform:FindChild("Button3"))
                effectObject.transform.localScale = Vector3(2.3, 0.8, 1)
                effectObject.transform.localPosition = Vector3(-72, -18, -300)
                effectObject.transform.localRotation = Quaternion.identity
                effectObject.name = "StartButtonEffect"

                Utils.ChangeLayersRecursively(effectObject.transform, "UI")
            end
            self.startButtonEffect = BaseEffectView.New({effectId = 20053, callback = fun})
        else
            self.startButtonEffect:SetActive(true)
        end
    else
        if self.startButtonEffect ~= nil then
            self.startButtonEffect:SetActive(false)
        end
    end    
end

function CrossArenaRoomWindow:ShowDuang(show)
    if show then
        if self.duangTimerId == nil then
            self.duangTimerId = LuaTimer.Add(1000, 3000, function()
                self.addButton.transform.localScale = Vector3(1.2,1.1,1)
                Tween.Instance:Scale(self.addButton.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
            end)
        end
    else
        if self.duangTimerId ~= nil then
            LuaTimer.Delete(self.duangTimerId)
            self.duangTimerId = nil
        end
    end
end

function CrossArenaRoomWindow:ShowMsg(channel, rid, platform, zone_id, text, BubbleID)
    if self.loading then
        BaseUtils.enqueue(self.queue, function() self:ShowMsg(channel, rid, platform, zone_id, text, BubbleID) end)
        return
    end
    if self.bubbleList == nil then
        return
    end
    if self.model.myRoomData == nil then
        return
    end
    if self.myMemberData == nil then
        return
    end
    
    local channelString = ""
    if channel == MsgEumn.ChatChannel.Team then
        channelString = TI18N("{string_2, #00C2C0, [队伍]}%s")
    elseif channel == MsgEumn.ChatChannel.Scene then
        channelString = TI18N("{string_2, #22b14c, [场景]}%s")
    end
    -- 己方聊天
    for i=1,#self.myMemberData do
        local member = self.myMemberData[i]
        if member.rid == rid and member.platform == platform and member.zone_id == zone_id then
            self.bubbleList[i].Ext:SetData(string.format(channelString, text))
            self.bubbleList[i].bubble.gameObject:SetActive(true)
            local size = self.bubbleList[i].bubbleText.transform.sizeDelta
            self.bubbleList[i].bubble.sizeDelta = Vector2(size.x+33, size.y+16)
            local ID = Time.time
            self.bubbleList[i].bubbleID = ID
            LuaTimer.Add(3500, function()
                if self.bubbleList ~= nil and BaseUtils.isnull(self.bubbleList[i].bubble) == false and self.bubbleList[i].bubbleID == ID then
                    self.bubbleList[i].bubble.gameObject:SetActive(false)
                end
            end)
            break
        end
    end

    -- 对方聊天
    local otherSide = 1
    if self.mySide == 1 then
        otherSide = 2
    end
    local memberData = self.model:GetMember(otherSide)
    for i=6,#memberData+5 do
        local member = memberData[i-5]
        if member.rid == rid and member.platform == platform and member.zone_id == zone_id then
            self.bubbleList[i].Ext:SetData(string.format(channelString, text))
            self.bubbleList[i].bubble.gameObject:SetActive(true)
            local size = self.bubbleList[i].bubbleText.transform.sizeDelta
            self.bubbleList[i].bubble.sizeDelta = Vector2(size.x+33, size.y+16)
            local ID = Time.time
            self.bubbleList[i].bubbleID = ID
            LuaTimer.Add(3500, function()
                if self.bubbleList ~= nil and BaseUtils.isnull(self.bubbleList[i].bubble) == false and self.bubbleList[i].bubbleID == ID then
                    self.bubbleList[i].bubble.gameObject:SetActive(false)
                end
            end)
            break
        end
    end
end

function CrossArenaRoomWindow:ChatNoticeClick()
    if MainUIManager.Instance.noticeView ~= nil then
        if FriendManager.Instance.noReadMsg > 0 then
            FriendManager.Instance.model:OpenWindow({1})
        else
            FriendManager.Instance.model:OpenWindow({3})
        end
        MainUIManager.Instance.noticeView:set_chatnotice_num(0)
        self:UpdateNotice()
    end
end

function CrossArenaRoomWindow:ChangeChatMainCanvasPositionZ(z)
    if ChatManager.Instance.model.chatWindow ~= nil and not BaseUtils.isnull(ChatManager.Instance.model.chatWindow.transform) then
        local pos = ChatManager.Instance.model.chatWindow.transform.localPosition
        ChatManager.Instance.model.chatWindow.transform.localPosition = Vector3(pos.x, pos.y, z)
    end
end

function CrossArenaRoomWindow:ChangeChatMiniPositionZ(z)
    if ChatManager.Instance.model.chatMini ~= nil and not BaseUtils.isnull(ChatManager.Instance.model.chatMini.transform) then
        local pos = ChatManager.Instance.model.chatMini.transform.localPosition
        ChatManager.Instance.model.chatMini.transform.localPosition = Vector3(pos.x, pos.y, z)
    end
end

function CrossArenaRoomWindow:AdaptIPhoneX()
    -- BaseUtils.AdaptIPhoneX(self.showButtonTransform)
    -- BaseUtils.AdaptIPhoneX(self.transform)
    -- self.showButtonTransform.localPosition = Vector3(24, 0, 0)
    self.showButtonTransform.offsetMin = Vector2(30, 10)
    self.showButtonTransform.offsetMax = Vector2(30, 10)
    if MainUIManager.Instance.adaptIPhoneX then
        if Screen.orientation == ScreenOrientation.LandscapeRight then
            self.showButtonTransform.offsetMin = Vector2(30, 10)
            self.showButtonTransform.offsetMax = Vector2(30, 10)
        else
            self.showButtonTransform.offsetMin = Vector2(0, 0)
            self.showButtonTransform.offsetMax = Vector2(0, 0)
        end
    else
    end
end