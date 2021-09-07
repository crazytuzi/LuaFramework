-- ----------------------------------------------------------
-- UI - 坐骑窗口
-- @ljh 2016.5.24
-- ----------------------------------------------------------
RideView = RideView or BaseClass(BaseWindow)

function RideView:__init(model)
    self.model = model
    self.name = "RideView"
    self.windowId = WindowConfig.WinID.ridewindow
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
        {file = AssetConfig.ridewindow, type = AssetType.Main},
        {file = AssetConfig.ride_texture, type = AssetType.Dep},
    }

    self.gameObject = nil
    self.transform = nil

    self.mainTransform = nil

    ------------------------------------------------
    self.currentIndex = 1

    self.childIndex = {
    	headbar = 0,
        base = 1,
        upgrade = 2, --- 升级
        skill = 3, -- 技能
        control = 4, -- 契约
        transformation = 5, -- 幻化
    }

    ------------------------------------------------
    self.tabGroup = nil
    self.tabGroupObj = nil

    self.childTab = {}
    self.headbar = nil

    self.model_data = nil
    self.previewComposite = nil
    self.rawImage = nil

    self.timeId_PlayIdleAction = nil
    self.timeId_Stand = nil
    -- self.rideIdleTime = {
    --     [80002] = 2000
    --     ,[80003] = 2600
    --     ,[80004] = 2000
    --     ,[80005] = 2800
    --     ,[80006] = 2300
    --     ,[80006] = 2300
    --     ,[4006301] = 2000
    -- }

    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function RideView:__delete()
    self:OnHide()

    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end

    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end

    for _, child in pairs(self.childTab) do
        child:DeleteMe()
        child = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    if self.timeId_PlayIdleAction ~= nil then
        LuaTimer.Delete(self.timeId_PlayIdleAction)
    end
    if self.timeId_Stand ~= nil then
        LuaTimer.Delete(self.timeId_Stand)
    end

    self:AssetClearAll()
end

function RideView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.ridewindow))
    self.gameObject.name = "RideView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")
    self.mainTransform:GetComponent(RectTransform).anchoredPosition = Vector2(-35, -5)

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.tabGroupObj = self.mainTransform:FindChild("TabButtonGroup")
    self.tabGroupObj.transform.anchoredPosition = Vector2(814,-62)

    self.tabGroupSetting = {
        notAutoSelect = true,
        openLevel = {7,75,75,75,7},
        spacing =10,
        offsetHeight =3,
        offsetWidth = 44,
        perHeight = 58,
        isVertical = true
    }
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index,otherOpenArgs) self:ChangeTab(index,otherOpenArgs) end, self.tabGroupSetting)
    for i,v in ipairs(self.tabGroup.buttonTab) do
        v.gameObject:SetActive(false)
    end

    local setting = {
        name = "RideView"
        ,modelData = 1
        ,width = 300
        ,height = 500
        ,offsetY = -0.4
    }

    self.previewComposite = PreviewComposite.New(nil, setting, {})
    self.previewComposite:BuildCamera(true)
    self.rawImage = self.previewComposite.rawImage
    self.rawImage.transform:SetParent(self.transform)
    self.rawImage.transform.localPosition = Vector3(0, 0, 0)
    self.rawImage.transform.localScale = Vector3(1, 1, 1)
    self.rawImage.transform:SetAsFirstSibling()

    self.OnHideEvent:AddListener(function() self.previewComposite:Hide() end)
    self.OnOpenEvent:AddListener(function() self.previewComposite:Show() end)
    ----------------------------

    self:OnShow()
end

function RideView:OnClickClose()
    self:OnHide()
    WindowManager.Instance:CloseWindow(self)
end

function RideView:OnShow()
    -- self.cacheMode = CacheMode.Destroy
    if self.openArgs ~= nil and #self.openArgs > 0 then
        if self.childTab[self.currentIndex] ~= nil then
            self.childTab[self.currentIndex]:Hiden()
        end
        self.currentIndex = self.openArgs[1]
    end

    self.tabGroup.noCheckRepeat = true
    self.tabGroup:ChangeTab(self.currentIndex)
    self.tabGroup.noCheckRepeat = false
    self:addevents()

    self:CheckIsEgg()

    local state = self.model:updateRedPoint_GetEgg() or self.model:updateRedPoint_Egg()
    self.tabGroup:ShowRed(1, state)
    self.tabGroup:ShowRed(2, self.model.canUpgrade)
    self.tabGroup:ShowRed(5, self.model.canActivation)

    MainUIManager.Instance.OnUpdateIcon:Fire(35, false)
end

function RideView:OnHide()
    self.openArgs = nil
    if self.headbar ~= nil then
		self.headbar:Hiden()
	end
    local child = self.childTab[self.currentIndex]
    if child ~= nil then
        child:Hiden()
    end
    GuideManager.Instance:CloseWindow(self.windowId)
    self:removeevents()

    if self.timeId_PlayIdleAction ~= nil then
        LuaTimer.Delete(self.timeId_PlayIdleAction)
    end

    if self.timeId_Stand ~= nil then
        LuaTimer.Delete(self.timeId_Stand)
    end
end

function RideView:ChangeTab(index,otherOpenArgs)
	self:Show_Headbar(index == self.childIndex.base or index == self.childIndex.control or index == self.childIndex.upgrade or index == self.childIndex.skill)

    if self.currentIndex ~= 0 and self.currentIndex ~= index then
        if self.childTab[self.currentIndex] ~= nil then
            self.childTab[self.currentIndex]:Hiden()
        end
    end
    self.currentIndex = index
    local child = self.childTab[self.currentIndex]
    if child == nil then
        if index == self.childIndex.base then
            child = RideView_Base.New(self)
        elseif index == self.childIndex.upgrade then
            child = RideUpgradePanel.New(self)
        elseif index == self.childIndex.control then
            child = RideContractPanel.New(self)
        -- elseif index == self.childIndex.reset then
            -- child = RideSkillResetPanel.New(self)
        elseif index == self.childIndex.transformation then
            child = RideView_Transformation.New(self)
        elseif index == self.childIndex.skill then
            child = RideSkillPanel.New(self)
        else
            child = RideView_Base.New(self)
        end
        self.childTab[self.currentIndex] = child
    end
    if otherOpenArgs ~= nil then
        if self.openArgs == nil then
            self.openArgs = {}
            self.openArgs.transfigurationOpenStatus = otherOpenArgs
        else
             self.openArgs.transfigurationOpenStatus = otherOpenArgs
        end
    end
    child:Show(self.openArgs)
    if self.headbar ~= nil then
        self.headbar:updateridehead()
    end

    self.tabGroup:ShowRed(self.currentIndex, false)
end

function RideView:Show_Headbar(show)
	if show then
		if self.headbar == nil then
			self.headbar = RideView_HeadBar.New(self)
		end
		self.headbar:Show()
	else
		if self.headbar ~= nil then
			self.headbar:Hiden()
		end
	end
end

function RideView:addevents()
    -- EventMgr.Instance:AddListener(event_name.backpack_item_change, self._update_item)
    -- EventMgr.Instance:AddListener(event_name.role_asset_change, self._update_item)
    -- SkillManager.Instance.OnUpdateMarrySkill:Add(self._update_marryskill)
end

function RideView:removeevents()
    -- EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self._update_item)
    -- EventMgr.Instance:RemoveListener(event_name.role_asset_change, self._update_item)
    -- SkillManager.Instance.OnUpdateMarrySkill:Remove(self._update_marryskill)
end

-- 切换选中坐骑
-- 坐骑生长状态 1 蛋  2 可孵化 3 已孵化
function RideView:SelectRide()
    local isEgg = self:CheckIsEgg()

    if isEgg then
        return
    end

    local child = self.childTab[self.currentIndex]
    if child ~= nil then
        if child.init then child:update() end
    end
end

function RideView:load_preview(model_preview, data)
    -- self:event_pet_update({"upgrade"})

    if not BaseUtils.sametab(data, self.model_data) then
        self.model_data = data

        self.model_preview = model_preview
        self.previewComposite:Reload(self.model_data, function(composite) self:preview_loaded(composite) end)
    else
        self.model_preview = model_preview
        local rawImage = self.previewComposite.rawImage
        rawImage.transform:SetParent(self.model_preview)
        rawImage.transform.localPosition = Vector3(7, -35, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)

        self.previewComposite:NpcPlayAction(FighterAction.Stand)

        if self.timeId_PlayIdleAction ~= nil then
            LuaTimer.Delete(self.timeId_PlayIdleAction)
        end

        if self.timeId_Stand ~= nil then
            LuaTimer.Delete(self.timeId_Stand)
        end
        if self.model_data ~= nil then
            if self.model_data.isEgg then
                self.timeId_PlayIdleAction = LuaTimer.Add(500, 25000, function() self:PlayIdleAction() end)
            else
                self.timeId_PlayIdleAction = LuaTimer.Add(500, 15000, function() self:PlayIdleAction() end)
            end
        end


          local myEffectLoader = false
          if self.previewComposite.rideEffect ~= nil and self.previewComposite.rideEffect.gameObject ~= nil then
                if  RideManager.Instance.model.cur_ridedata ~= nil and RideManager.Instance.model.cur_ridedata.decorate_list ~= nil then
                    for k2,v2 in pairs(RideManager.Instance.model.cur_ridedata.decorate_list) do
                        if v2.decorate_index == 1 then
                            myEffectLoader = true

                        end
                    end
                end
                -- end
            -- end
        -- end_tim
                local mountData = nil
                if self.previewComposite.nowBaseId ~= nil then
                    mountData = DataMount.data_ride_data[self.previewComposite.nowBaseId]
                end
                if mountData ~= nil and mountData.notshowprevew == 1 then
                     self.previewComposite.rideEffect.gameObject:SetActive(false)
                else
                   if myEffectLoader == true then
                        self.previewComposite.rideEffect.gameObject:SetActive(true)
                    else
                        self.previewComposite.rideEffect.gameObject:SetActive(false)
                    end
                end
          end
    end
end

function RideView:preview_loaded(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.model_preview)
    rawImage.transform.localPosition = Vector3(7,-35, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)



    composite.tpose.transform.localRotation = Quaternion.identity
    if self:CheckIsEgg() then
        composite.tpose.transform.localScale = Vector3(4.3,4.3,4.3)
    end
    composite.tpose.transform:Rotate(Vector3(-6, SceneConstData.UnitFaceTo.RightForward, 6))

    if self.timeId_PlayIdleAction ~= nil then
        LuaTimer.Delete(self.timeId_PlayIdleAction)
    end
    if self.timeId_Stand ~= nil then
        LuaTimer.Delete(self.timeId_Stand)
    end
    if self.model_data ~= nil then
        if self.model_data.isEgg then
            self.timeId_PlayIdleAction = LuaTimer.Add(500, 25000, function() self:PlayIdleAction() end)
        else
            self.timeId_PlayIdleAction = LuaTimer.Add(500, 15000, function() self:PlayIdleAction() end)
        end
    end
end

function RideView:PlayIdleAction()
    if self.previewComposite ~= nil and self.previewComposite.tpose ~= nil and self.model_data ~= nil then
        local animationData = nil
        local animationId = nil
        if self.model_data.isGetEgg then
            animationId = 4006301
            animationData = DataAnimation.data_npc_data[animationId]
        elseif self.model_data.isEgg then
            animationId = 4006301
            animationData = DataAnimation.data_npc_data[animationId]
        else
            animationId = 0
            animationData = nil
            local baseid = nil
            for _, looks in ipairs(self.model_data.looks) do
                if looks.looks_type == SceneConstData.looktype_ride then
                    baseid = looks.looks_val
                end
            end
            if baseid ~= nil and DataMount.data_ride_data[baseid] ~= nil then
                animationId = DataMount.data_ride_data[baseid].animation_id
                animationData = DataAnimation.data_ride_data[animationId]
            end
        end
        if animationData ~= nil then
            self.previewComposite.tpose:GetComponent(Animator):Play(string.format("Idle%s", animationData.idle_id))
            self.timeId_Stand = LuaTimer.Add(self:GetRideIdleTime(animationId), function() self:PlayStand() end)
        end
    end
end

function RideView:PlayStand()
    if self.previewComposite ~= nil and self.previewComposite.tpose ~= nil and self.model_data ~= nil then
        if self.model_data.isGetEgg then
            local animationData = DataAnimation.data_npc_data[4006301]
            self.previewComposite.tpose:GetComponent(Animator):Play(string.format("Stand%s", animationData.stand_id))
        elseif self.model_data.isEgg then
            local animationData = DataAnimation.data_npc_data[4006301]
            self.previewComposite.tpose:GetComponent(Animator):Play(string.format("Stand%s", animationData.stand_id))
        else
            local animationData = nil
            local baseid = nil
            for _, looks in ipairs(self.model_data.looks) do
                if looks.looks_type == SceneConstData.looktype_ride then
                    baseid = looks.looks_val
                end
            end
            if baseid ~= nil and DataMount.data_ride_data[baseid] ~= nil then
                local animationId = DataMount.data_ride_data[baseid].animation_id
                animationData = DataAnimation.data_ride_data[animationId]
            end

            if animationData ~= nil then
                self.previewComposite.tpose:GetComponent(Animator):Play(string.format("Stand%s", animationData.stand_id))
            end
        end
    end
end

function RideView:GetRideIdleTime(animationId)
    local time = 3000
    local animData = DataAnimation.data_ride_data[animationId]
    if animData ~= nil and animData.idle_time ~= nil then
        time = animData.idle_time
    end
    return time
end

-- 头像切换到蛋的相关处理
-- 1.隐藏除信息外的标签
-- 2.条回到信息标签
function RideView:CheckIsEgg()
    local bool = true
    if self.model.cur_ridedata ~= nil and self.model.cur_ridedata.live_status < 3 then
        bool = false
        if self.currentIndex == self.childIndex.base then
            local child = self.childTab[self.currentIndex]
            if child ~= nil then
                if child.init then child:update() end
            end
        else
            self.tabGroup.noCheckRepeat = true
            self.tabGroup:ChangeTab(self.childIndex.base)
            self.tabGroup.noCheckRepeat = false
        end
    end
    for i,v in ipairs(self.tabGroup.buttonTab) do
        v.gameObject:SetActive(bool)
    end


    if bool == true and  self.model.cur_ridedata ~= nil and DataMount.data_ride_data[self.model.cur_ridedata.mount_base_id] ~= nil  then
        if self.model.cur_ridedata ~= nil and DataMount.data_ride_new_data[self.model.cur_ridedata.mount_base_id] ~= nil then
            self.tabGroup.openLevel = {7,200,200,200,7}
        elseif DataMount.data_ride_new_data[self.model.cur_ridedata.mount_base_id] == nil then
            self.tabGroup.openLevel = {7,75,75,75,7}
        end
        self.tabGroup:Layout()
    end

    return not bool
end
