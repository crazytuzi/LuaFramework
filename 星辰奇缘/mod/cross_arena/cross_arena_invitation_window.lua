-- 跨服擂台创建房间窗口
-- ljh 20190329
CrossArenaInvitationWindow = CrossArenaInvitationWindow or BaseClass(BasePanel)

function CrossArenaInvitationWindow:__init(model)
    self.model = model

    self.resList = {
        {file = AssetConfig.crossarenainvitation, type = AssetType.Main}
    }

    -----------------------------------------------------------

    -----------------------------------------------------------

    -----------------------------------------------------------

    self._Update = function() self:Update() end

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function CrossArenaInvitationWindow:__delete()
    self.OnHideEvent:Fire()

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function CrossArenaInvitationWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.crossarenainvitation))
    self.gameObject.name = "CrossArenaInvitationWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    	
    self.transform:FindChild("Panel"):GetComponent(Button).onClick:AddListener(function() self:OnClickClose() end)

    self.mainTransform = self.transform:FindChild("Main")
    self.mainTransform:FindChild("CloseButton"):GetComponent(Button).onClick:AddListener(function() self:OnClickClose() end)

    self.mainTransform:FindChild("OkButton"):GetComponent(Button).onClick:AddListener(function() self:OnClickOkButton() end)
    self.mainTransform:FindChild("CancelButton"):GetComponent(Button).onClick:AddListener(function() self:OnClickCancelButton() end)

    self.head1 = self.mainTransform:Find("Head1")
    self.nameText1 = self.mainTransform:Find("NameText1"):GetComponent(Text)
    -- self.levelText1 = self.mainTransform:Find("Level1/Text"):GetComponent(Text)

    self.headSlot1 = HeadSlot.New()
    self.headSlot1:SetRectParent(self.head1.transform)
    self.headSlot1:HideSlotBg()

    self.head2 = self.mainTransform:Find("Head2")
    self.nameText2 = self.mainTransform:Find("NameText2"):GetComponent(Text)
    -- self.levelText2 = self.mainTransform:Find("Level2/Text"):GetComponent(Text)

    self.headSlot2 = HeadSlot.New()
    self.headSlot2:SetRectParent(self.head2.transform)
    self.headSlot2:HideSlotBg()

    self.typeText = self.mainTransform:Find("TypeText"):GetComponent(Text)

    self.addButton = self.mainTransform:Find("Add"):GetComponent(Button)
    self.addButton.onClick:AddListener(function() self:OnClickOkButton() end)

    self.okButtonText = self.mainTransform:FindChild("OkButton/Text"):GetComponent(Text)
    self.cancelButtonText = self.mainTransform:FindChild("CancelButton/Text"):GetComponent(Text)

    self.cancelButtonText.text = TI18N("前往约战")
end

function CrossArenaInvitationWindow:OnClickClose()
    self.model:CloseCrossArenaInvitationWindow()
end

function CrossArenaInvitationWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function CrossArenaInvitationWindow:OnOpen()
    -- if self.openArgs ~= nil and #self.openArgs > 0 then
    --     self.room_id = self.openArgs[1]
    --     CrossArenaManager.Instance:Send20729(self.room_id)
    -- end

    self:Update()

    -- CrossArenaManager.Instance.OnUpdateRoomInfo:RemoveListener(self._Update)
    -- CrossArenaManager.Instance.OnUpdateRoomInfo:AddListener(self._Update)
end

function CrossArenaInvitationWindow:OnHide()
    -- CrossArenaManager.Instance.OnUpdateRoomInfo:RemoveListener(self._Update)
end

function CrossArenaInvitationWindow:Update()
    local data = self.model.invitationRoomData
    if self.model.invitationRoomData ~= nil then
        local headData = { id = data.m_rid, platform = data.m_platform, zone_id = data.m_zone_id, classes = data.master_class, sex = data.master_sex}
        self.headSlot1:SetAll(headData, {isSmall = true})
        self.nameText1.text = data.master_name

        -- 房间模式 1：任意模式；2：1v1约战；3：5v5约战
        if data.mode == 1 then
            self.typeText.text = TI18N("任意人数")
        elseif data.mode == 2 then
            self.typeText.text = TI18N("单人战斗")
        elseif data.mode == 3 then
            self.typeText.text = TI18N("组队战斗")
        end

        if data.status == 1 then
            self.nameText2.text = ""
            self.okButtonText.text = TI18N("接受挑战")
        else
            self.addButton.gameObject:SetActive(false)

            local headData2 = { id = data.c_rid, platform = data.c_platform, zone_id = data.c_zone_id, classes = data.customer_class, sex = data.customer_sex}
            self.headSlot2:SetAll(headData2, {isSmall = true})
            self.nameText2.text = data.customer_name

            if data.status == 4 then
                self.okButtonText.text = TI18N("观战")
            else
                if data.r_id == 0 then
                    self.okButtonText.text = TI18N("请稍候")
                else
                    self.okButtonText.text = TI18N("录像")
                end
                
            end
        end
    end
end

function CrossArenaInvitationWindow:OnClickOkButton()
    local data = self.model.invitationRoomData
    if data == nil then
        return
    end

    if self.model.myRoomData ~= nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("您已经有了房间了"))
        return
    end

    if data.status == 1 then -- 接受挑战
        -- CrossArenaManager.Instance:Send20705(data.id, data.password)
        CrossArenaManager.Instance:Send20732(data.id, 2, data.password, data.r_id, data.r_platform, data.r_zone_id)
    else
        if data.status == 4 then -- 观战
            -- CombatManager.Instance:Send10705(data.r_id, data.r_platform, data.r_zone_id)
            CrossArenaManager.Instance:Send20732(data.id, 1, data.password, data.r_id, data.r_platform, data.r_zone_id)
        else
            if data.r_id == 0 then
                NoticeManager.Instance:FloatTipsByString(TI18N("请稍候"))
            else -- 录像
                -- CrossArenaManager.Instance:Send20717(data.r_id, data.r_platform, data.r_zone_id)
                CrossArenaManager.Instance:Send20732(data.id, 3, data.password, data.r_id, data.r_platform, data.r_zone_id)
            end
        end
    end
    self:OnClickClose()
end

function CrossArenaInvitationWindow:OnClickCancelButton()
    self:OnClickClose()

    local roleData = RoleManager.Instance.RoleData
    if roleData.event == RoleEumn.Event.Provocation then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.crossarenawindow)
    elseif roleData.event == RoleEumn.Event.ProvocationRoom then
        self.model:OpenCrossArenaRoomWindow()
    else
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("是否前往<color='#00ff00'>跨服约战大厅</color>？")
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function() 
            CrossArenaManager.Instance:Send20701()
        end
        NoticeManager.Instance:ConfirmTips(data)
    end
end