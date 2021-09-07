-- ----------------------------------------------------------
-- UI - 游戏登录
-- ----------------------------------------------------------
SkillView = SkillView or BaseClass(BaseWindow)

function SkillView:__init(model)
    self.model = model
    self.name = "SkillView"
    self.windowId = WindowConfig.WinID.skill
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
        {file = AssetConfig.skill_window, type = AssetType.Main}
    }

    self.gameObject = nil
    self.transform = nil

    self.mainTransform = nil

    ------------------------------------------------
    self.currentIndex = 1

    self.childIndex = {
        base = 1,
        prac = 2,
        life = 3,
        assist = 4
    }

    ------------------------------------------------
    self.tabGroup = nil
    self.tabGroupObj = nil

    self.childTab = {}
    self.headbar = nil

    ------------------------------------------------
    self._update_item = function() self:update_item() end
    self._update_marryskill = function() self:update_marryskill() end
    self._update_roleskill = function() self:update_roleskill() end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function SkillView:__delete()
    self:OnHide()

    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end

    if self.childTab ~= nil then
        for _, child in pairs(self.childTab) do
            if child ~= nil then
                child:DeleteMe()
            end
        end
    end

    self:AssetClearAll()
end

function SkillView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.skill_window))
    self.gameObject.name = "SkillView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.tabGroupObj = self.mainTransform:FindChild("TabButtonGroup")

    local tabGroupSetting = {
        notAutoSelect = true,
        openLevel = {0, 30, 25, 25},
        perWidth = 62,
        perHeight = 88,
        isVertical = true
    }
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index)
        self:ChangeTab(index)
    end, tabGroupSetting)

    ----------------------------

    self:OnShow()
end

function SkillView:OnClickClose()
    -- self:OnHide()
    WindowManager.Instance:CloseWindow(self)
end

function SkillView:OnShow()
    if self.openArgs ~= nil and #self.openArgs > 0 then
        if self.childTab[self.currentIndex] ~= nil then
            self.childTab[self.currentIndex]:Hiden()
        end
        self.currentIndex = self.openArgs[1]
    end

    self.tabGroup.noCheckRepeat = true
    self.tabGroup:ChangeTab(self.currentIndex)
    self.tabGroup.noCheckRepeat = false
    self:removeevents()
    self:addevents()
    self:update_item()
    self:update_marryskill()
    self:update_roleskill()
    SkillManager.Instance:Send10822()
end

function SkillView:OnHide()
    self.openArgs = nil
    local child = self.childTab[self.currentIndex]
    if child ~= nil then
        child:Hiden()
    end
    -- if self.model.finalSkillStudyPanel ~= nil then
    --     self.model.finalSkillStudyPanel:Hiden()
    -- end
    -- if self.model.finalSkillPanel ~= nil then
    --     self.model.finalSkillPanel:Hiden()
    -- end
    GuideManager.Instance:CloseWindow(self.windowId)
    self:removeevents()
end

function SkillView:ChangeTab(index)
    if self.currentIndex ~= 0 and self.currentIndex ~= index then
        if self.childTab[self.currentIndex] ~= nil then
            self.childTab[self.currentIndex]:Hiden()
        end
    end
    self.currentIndex = index
    local child = self.childTab[self.currentIndex]
    if child == nil then
        if index == self.childIndex.base then
            child = SkillView_Base.New(self)
        elseif index == self.childIndex.prac then
            child = SkillView_Prac.New(self)
        elseif index == self.childIndex.life then
            child = SkillViewTabThree.New(self)
        elseif index == self.childIndex.assist then
            child = SkillView_Assist.New(self)
        else
            child = SkillView_Base.New(self)
        end
        self.childTab[self.currentIndex] = child
    end
    child:Show(self.openArgs)
end

function SkillView:addevents()
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self._update_item)
    EventMgr.Instance:AddListener(event_name.role_asset_change, self._update_item)
    SkillManager.Instance.OnUpdateRoleSkill:Add(self._update_roleskill)
    SkillManager.Instance.OnUpdateMarrySkill:Add(self._update_marryskill)
end

function SkillView:removeevents()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self._update_item)
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self._update_item)
    SkillManager.Instance.OnUpdateRoleSkill:Remove(self._update_roleskill)
    SkillManager.Instance.OnUpdateMarrySkill:Remove(self._update_marryskill)
end

function SkillView:update_item() -- 20025
    local num = BackpackManager.Instance:GetItemCount(20025)
    self.tabGroup:ShowRed(2, self.model.skill_prac_redpoint and num > 0)

    local state = self.model:check_huoli_val()
    self.tabGroup:ShowRed(3, state)
end

--更新
function SkillView:UpdateSkillLife()
    local child = self.childTab[self.childIndex.life]
    if child ~= nil then
        child:socket_back_update()
    end
end

function SkillView:update_marryskill()
    local mark = false

    local skilllist = self.model.marry_skill

    local data

    for i = 1, #skilllist do
        data = skilllist[i]

        local marryskill
        if data.lev == 0 then
            marryskill = self.model:getmarryskilldata(data.id, 1)
            if marryskill ~= nil then
                local roleData = RoleManager.Instance.RoleData
                if marryskill.love_var <= roleData.love then
                    if marryskill.intimacy <= FriendManager.Instance:GetIntimacy(roleData.lover_id, roleData.lover_platform, roleData.lover_zone_id) then
                        mark = true
                    end
                end
            end
        end
    end

    self.tabGroup:ShowRed(4,  mark)
end

function SkillView:update_roleskill()
    local mark = false

    local skilllist = self.model.role_skill

    local data

    local roleData = RoleManager.Instance.RoleData

    for i = 1, #skilllist do
        data = skilllist[i]
        local skilldata = self.model:getroleskilldata(data.id, 1)
        if data.lev < roleData.lev and skilldata.study_lev <= roleData.lev then
            mark = true
            break
        end
    end

    mark = self.model.finalskillred
    self.tabGroup:ShowRed(1,  mark)
end