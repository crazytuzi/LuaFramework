-- -----------------------------
-- 组队按钮操作界面
-- hosr
-- -----------------------------
TeamButtonPanel = TeamButtonPanel or BaseClass(BasePanel)

function TeamButtonPanel:__init(mainPanel)
    self.mainPanel = mainPanel
    self.parent = self.mainPanel.gameObject.transform
    self.name = "TeamButtonPanel"
    self.transform = nil

    self.normalArea = nil
    self.optionArea = nil
    self.listArea = nil

    self.leaveOrCreateBtn = nil
    self.leaveOrCreateImg = nil
    self.leaveOrCreateTxt = nil
    self.callFriendBtn = nil
    self.callFriendImg = nil
    self.myGuardBtn = nil
    self.lookListBtn = nil
    self.lookListTxt = nil
    self.lookListImg = nil
    self.redPoint = nil

    self.optionArrow = nil
    self.addFriendBtn = nil
    self.lookInfoBtn = nil
    self.giveCaptin = nil
    self.kickOutBtn = nil

    self.refreshBtn = nil
    self.backBtn = nil

    self.listener = function() self:Update() end

    self.arrowPosition = {-290, -145, 0, 145, 290}

    self.currentMember = nil

    self.resList = {
        {file = AssetConfig.teambutton, type = AssetType.Main},
        {file = AssetConfig.teammark_icon, type = AssetType.Dep},
    }

    self.canRefresh = true

    self.loading = false
    self.isInit = false
end

function TeamButtonPanel:__delete()
    self:OnClose()
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
    self.isInit = false
end

function TeamButtonPanel:OnClose()
    EventMgr.Instance:RemoveListener(event_name.team_create, self.listener)
    EventMgr.Instance:RemoveListener(event_name.team_update, self.listener)
    EventMgr.Instance:RemoveListener(event_name.team_leave, self.listener)
    EventMgr.Instance:RemoveListener(event_name.team_list_update, self.listener)

    self.mainPanel = nil
    self.parent = nil
    self.transform = nil
    self.normalArea = nil
    self.optionArea = nil
    self.listArea = nil
    self.leaveOrCreateBtn = nil
    self.leaveOrCreateImg = nil
    self.leaveOrCreateTxt = nil
    self.callFriendBtn = nil
    self.callFriendImg = nil
    self.myGuardBtn = nil
    self.lookListBtn = nil
    self.lookListTxt = nil
    self.lookListImg = nil
    self.redPoint = nil
    self.optionArrow = nil
    self.addFriendBtn = nil
    self.lookInfoBtn = nil
    self.giveCaptin = nil
    self.kickOutBtn = nil
    self.refreshBtn = nil
    self.backBtn = nil
    self.listener = nil
    self.arrowPosition = nil
end

function TeamButtonPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.teambutton))
    self.transform =  self.gameObject.transform
    self.gameObject.name = "TeamButtonPanel"
    self.transform:SetParent(self.parent)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3(0, -215, 0)

    self.normalArea = self.transform:Find("Normal").gameObject
    self.optionArea = self.transform:Find("Option").gameObject
    self.listArea = self.transform:Find("List").gameObject

    self.leaveOrCreateBtn = self.normalArea.transform:Find("LeaveorCreate"):GetComponent(Button)
    self.leaveOrCreateImg = self.leaveOrCreateBtn.gameObject:GetComponent(Image)
    self.leaveOrCreateTxt = self.leaveOrCreateBtn.transform:Find("Text"):GetComponent(Text)
    self.callFriendBtn = self.normalArea.transform:Find("CallFriend"):GetComponent(Button)
    self.callFriendTxt = self.callFriendBtn.transform:Find("Text"):GetComponent(Text)
    self.callFriendImg = self.callFriendBtn:GetComponent(Image)
    self.myGuardBtn = self.normalArea.transform:Find("MyGuard"):GetComponent(Button)
    self.lookListBtn = self.normalArea.transform:Find("LookList"):GetComponent(Button)
    self.lookListTxt = self.lookListBtn.transform:Find("Text"):GetComponent(Text)
    self.lookListImg = self.lookListBtn:GetComponent(Image)
    self.teamMarkBtn = self.normalArea.transform:Find("TeamMark"):GetComponent(Button)
    self.redPoint = self.normalArea.transform:Find("RedPoint").gameObject
    self.redPoint:SetActive(false)
    self.normalArea.transform:Find("TeamMark/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.teammark_icon, "30016")

    self.optionArrow = self.optionArea.transform:Find("Arrow").gameObject
    self.addFriendBtn = self.optionArea.transform:Find("AddFriend"):GetComponent(Button)
    self.lookInfoBtn = self.optionArea.transform:Find("LookInfo"):GetComponent(Button)
    self.giveCaptin = self.optionArea.transform:Find("GiveCaptin"):GetComponent(Button)
    self.giveTxt = self.optionArea.transform:Find("GiveCaptin/Text"):GetComponent(Text)
    self.kickOutBtn = self.optionArea.transform:Find("KickOut"):GetComponent(Button)
    self.kickTxt = self.optionArea.transform:Find("KickOut/Text"):GetComponent(Text)

    self.refreshBtn = self.listArea.transform:Find("Refresh"):GetComponent(Button)
    self.refreshBtn.gameObject:SetActive(false)
    self.backBtn = self.listArea.transform:Find("Back"):GetComponent(Button)

    self.normalArea:SetActive(false)
    self.optionArea:SetActive(false)
    self.listArea:SetActive(false)

    self.leaveOrCreateBtn.onClick:AddListener(function() self:CreateOrLeave() end)
    self.callFriendBtn.onClick:AddListener(function() self:CallFriend() end)
    self.myGuardBtn.onClick:AddListener(function() self:ClickGuard() end)
    -- self.lookListBtn.onClick:AddListener(function() self.mainPanel:OpenCloseList() end)
    self.lookListBtn.onClick:AddListener(function() self:LookList() end)
    self.teamMarkBtn.onClick:AddListener(function() self:TeamMark() end)
    self.addFriendBtn.onClick:AddListener(function() self:AddFriend() end)
    self.lookInfoBtn.onClick:AddListener(function() self:LookInfo() end)
    self.giveCaptin.onClick:AddListener(function() self:GiveCaptin() end)
    self.kickOutBtn.onClick:AddListener(function() self:KickOut() end)
    self.refreshBtn.onClick:AddListener(function() self:Refresh() end)
    self.backBtn.onClick:AddListener(function() self.mainPanel:OpenCloseList() end)

    EventMgr.Instance:AddListener(event_name.team_create, self.listener)
    EventMgr.Instance:AddListener(event_name.team_update, self.listener)
    EventMgr.Instance:AddListener(event_name.team_leave, self.listener)
    EventMgr.Instance:AddListener(event_name.team_list_update, self.listener)

    self.isInit = true
end

function TeamButtonPanel:Show(arge)
    if self.loading then
        return
    end

    self.openArgs = arge
    if self.gameObject ~= nil then
        self.loading = false
        self:Update()
        self.gameObject:SetActive(true)
        self.OnOpenEvent:Fire()
    else
        -- 如果有资源则加载资源，否则直接调用初始化接口
        self.loading = true
        if self.resList ~= nil and #self.resList > 0 then
            self:LoadAssetBundleBatch()
        else
            self:OnResLoadCompleted()
        end
    end
end

function TeamButtonPanel:OnInitCompleted()
    self.loading = false
    self:Update()
    self:ShowType(self.openArgs)
end

function TeamButtonPanel:Update()
    if BaseUtils.is_null(self.gameObject) then
        self:OnClose()
        return
    end

    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None then
        self.callFriendImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.callFriendBtn.enabled = true
        self.callFriendBtn.gameObject:SetActive(false)
        self.callFriendTxt.color = ColorHelper.DefaultButton3

        self.leaveOrCreateImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.leaveOrCreateTxt.text = TI18N("创建队伍")
        self.leaveOrCreateTxt.color = ColorHelper.DefaultButton3

        self.lookListTxt.text = TI18N("队伍列表")
        self.lookListBtn.enabled = true
        self.lookListImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.lookListBtn.gameObject:SetActive(true)
        self.lookListTxt.color = ColorHelper.DefaultButton3
    elseif TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
        self.leaveOrCreateImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.leaveOrCreateTxt.text = TI18N("退出队伍")
        self.leaveOrCreateTxt.color = ColorHelper.DefaultButton3

        self.lookListTxt.text = TI18N("附近玩家")
        self.lookListImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.lookListBtn.enabled = true
        self.lookListBtn.gameObject:SetActive(true)
        self.lookListTxt.color = ColorHelper.DefaultButton3

        self.callFriendImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.callFriendBtn.enabled = true
        self.callFriendBtn.gameObject:SetActive(true)
        self.callFriendTxt.color = ColorHelper.DefaultButton3
    else
        self.leaveOrCreateImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.leaveOrCreateTxt.text = TI18N("退出队伍")
        self.leaveOrCreateTxt.color = ColorHelper.DefaultButton3

        -- self.lookListTxt.text = "附近玩家"
        self.lookListImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        -- self.lookListBtn.enabled = false
        -- self.lookListBtn.gameObject:SetActive(false)
        self.lookListBtn.enabled = true
        self.lookListBtn.gameObject:SetActive(true)
        self.lookListTxt.color = ColorHelper.DefaultButton3

        self.callFriendBtn.enabled = true
        self.callFriendImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.callFriendBtn.gameObject:SetActive(true)
        self.callFriendTxt.color = ColorHelper.DefaultButton3

        if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
            self.lookListTxt.text = TI18N("附近玩家")
        elseif TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None then
            self.lookListTxt.text = TI18N("队伍列表")
        elseif TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Follow then
            -- self.callFriendTxt.text = "暂离"
            self.lookListTxt.text = TI18N("暂离")
        elseif TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Away then
            -- self.callFriendTxt.text = "归队"
            self.lookListTxt.text = TI18N("归队")
        end
    end

    if TeamManager.Instance:MyStatus() ~= RoleEumn.TeamStatus.None then
        if TeamManager.Instance.endFightQuit then
            self.leaveOrCreateTxt.text = TI18N("取消退出")
        else
            self.leaveOrCreateTxt.text = TI18N("退出队伍")
        end
    end

    if (TeamManager.Instance:HasApply() or TeamManager.Instance:HasRequest()) and (TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader or TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None) then
        self:ShowRedPoint(true)
    else
        self:ShowRedPoint(false)
    end
end

function TeamButtonPanel:ShowType(type)
    if BaseUtils.is_null(self.normalArea) then
        return
    end
    if type == "normal" then
        self.normalArea:SetActive(true)
        self.optionArea:SetActive(false)
        self.listArea:SetActive(false)
    elseif type == "option" then
        self.optionArea:SetActive(true)
        self.normalArea:SetActive(false)
        self.listArea:SetActive(false)
    elseif type == "list" then
        self.listArea:SetActive(true)
        self.normalArea:SetActive(false)
        self.optionArea:SetActive(false)
    end
end

function TeamButtonPanel:CallFriend()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.friend)

    -- if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None or TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
    --     WindowManager.Instance:OpenWindowById(WindowConfig.WinID.friend)
    -- else
    --     if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Follow then
    --         -- 跟随中。点击暂离
    --         TeamManager.Instance:Send11706()
    --     elseif TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Away then
    --         -- 暂离，点击跟随
    --         TeamManager.Instance:Send11707()
    --     end
    -- end
end

function TeamButtonPanel:SelectMember(member)
    self.currentMember = member
    self.optionArrow.transform.localPosition = Vector3(self.arrowPosition[member["id"]], 30, 0)
    self:OptionButtonUpdateTxt()
end

function TeamButtonPanel:OptionButtonUpdateTxt()
    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
        local rid = self.currentMember.info.rid
        local zone = self.currentMember.info.zone_id
        local pf = self.currentMember.info.platform
        self.giveTxt.text = TI18N("委任队长")
        self.kickTxt.text = TI18N("踢出队伍")
        if rid == TeamManager.Instance.giveRid and pf == TeamManager.Instance.givePlatform and zone == TeamManager.Instance.giveZoneId then
            if TeamManager.Instance.endFightGive then
                self.giveTxt.text = TI18N("取消委任")
            else
                self.giveTxt.text = TI18N("委任队长")
            end

            if TeamManager.Instance.endFightKick then
                self.kickTxt.text = TI18N("取消踢出")
            else
                self.kickTxt.text = TI18N("踢出队伍")
            end
        end
        self.giveCaptin.gameObject:SetActive(true)
        self.kickOutBtn.gameObject:SetActive(true)
    else
        self.giveCaptin.gameObject:SetActive(false)
        self.kickOutBtn.gameObject:SetActive(false)
    end
end

function TeamButtonPanel:ShowRedPoint(bool)
    self.redPoint:SetActive(bool)
end

function TeamButtonPanel:ClickGuard()
    self.mainPanel.cacheMode = CacheMode.Visible
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guardian)
end

function TeamButtonPanel:AddFriend()
    if self.currentMember ~= nil then
        local id = self.currentMember.info.rid
        local pf = self.currentMember.info.platform
        local zone = self.currentMember.info.zone_id
        FriendManager.Instance:Require11804(id, pf, zone)
    end
end

function TeamButtonPanel:GiveCaptin()
    if self.currentMember ~= nil then
        local id = self.currentMember.info.rid
        local pf = self.currentMember.info.platform
        local zone = self.currentMember.info.zone_id
        local name = self.currentMember.info.name
        TeamManager.Instance:Send11705(id, pf, zone, name)
    end
end

function TeamButtonPanel:KickOut()
    if self.currentMember ~= nil then
        local id = self.currentMember.info.rid
        local pf = self.currentMember.info.platform
        local zone = self.currentMember.info.zone_id
        local name = self.currentMember.info.name
        TeamManager.Instance:Send11710(id, pf, zone, name)
    end
end

function TeamButtonPanel:LookInfo()
    if self.currentMember ~= nil then
        TipsManager.Instance:ShowPlayer(self.currentMember.info)
    end
end

function TeamButtonPanel:CreateOrLeave()
    if TeamManager.Instance:HasTeam() then
        TeamManager.Instance:Send11708()
        if TeamManager.Instance.endFightQuit then
            self.leaveOrCreateTxt.text = TI18N("取消退出")
        else
            self.leaveOrCreateTxt.text = TI18N("退出队伍")
        end
    else
        TeamManager.Instance:Send11701()
    end
end

function TeamButtonPanel:Refresh()
    if not TeamManager.Instance.model.canRefresh then
        return
    end
    TeamManager.Instance.model:RefreshCd(function() self:RefreshCount() end)
    EventMgr.Instance:Fire(event_name.team_list_update)
end

function TeamButtonPanel:RefreshCount()
end

function TeamButtonPanel:LookList()
    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader or TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None then
        self.mainPanel:OpenCloseList()
    elseif TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Follow then
        -- 跟随中。点击暂离
        TeamManager.Instance:Send11706()
    elseif TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Away then
        -- 暂离，点击跟随
        TeamManager.Instance:Send11707()
    end
end

function TeamButtonPanel:TeamMark()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.achievementshopwindow, {1,4})
end