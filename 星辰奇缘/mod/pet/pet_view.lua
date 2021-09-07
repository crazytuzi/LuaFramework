-- ----------------------------------------------------------
-- UI - 宠物窗口 主窗口
-- ----------------------------------------------------------
PetView = PetView or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function PetView:__init(model)
    self.model = model
    self.name = "PetView"
    self.windowId = WindowConfig.WinID.pet
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.pet_window, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

	self.mainTransform = nil

	------------------------------------------------
    self.model_data = nil

	self.currentIndex = 0

	self.childIndex = {
		headbar = 0,
		base = 1,
		wash = 2,
		manual = 3,
		-- possession = 4
        child = 4
	}

    self.subIndex = 1

	------------------------------------------------
	self.tabGroup = nil
	self.tabGroupObj = nil

	self.childTab = {}
	self.headbar = nil
    self.childheadbar = nil

    self.previewComposite = nil
    self.rawImage = nil
    self.model_effect_list = {}
    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.guideScript = nil
    self.canGuideSecond = false
    self.canUpdateHead = false

    self.timeId_PlayAction = nil
    self.timeId_PlayIdleAction = nil
    self.actionIndex_PlayAction = 1
end

function PetView:__delete()

    self.model.childVewIndex = nil
    self:OnHide()
    if self.childTab ~= nil then
        for _, child in pairs(self.childTab) do
            if child ~= nil then
                child:DeleteMe()
            end
        end
        self.childTab = nil
    end

    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end


    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end

    if self.headbar ~= nil then
        self.headbar:DeleteMe()
        self.headbar = nil
    end

    if self.childheadbar ~= nil then
        self.childheadbar:DeleteMe()
        self.childheadbar = nil
    end

    self:AssetClearAll()
end

function PetView:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pet_window))
    self.gameObject.name = "PetView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

	self.tabGroupObj = self.mainTransform:FindChild("TabButtonGroup")    --侧边栏

    local tabGroupSetting = {
        notAutoSelect = true,
        noCheckRepeat = true,
        openLevel = {0, 0, 0, 68},
        perWidth = 62,
        perHeight = 100,
        isVertical = true
    }
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:ChangeTab(index) end, tabGroupSetting)

    local setting = {
        name = "PetView"
        ,orthographicSize = 1
        ,width = 328
        ,height = 341
        ,offsetY = -0.4
    }
    -- local modelData = {type = PreViewType.Pet, skinId = 30000, modelId = 30000, animationId = 3000001, scale = 1}
    self.previewComposite = PreviewComposite.New(nil, setting, {})
    self.previewComposite:BuildCamera(true)
    self.rawImage = self.previewComposite.rawImage
    self.rawImage.transform:SetParent(self.transform)
    self.rawImage.transform.localPosition = Vector3(0, 0, 0)
    self.rawImage.transform.localScale = Vector3(1, 1, 1)

    self.OnHideEvent:AddListener(function() self.previewComposite:Hide() end)
    self.OnOpenEvent:AddListener(function() self.previewComposite:Show() end)
    ----------------------------

    self:OnShow()
    self:ClearMainAsset()
end

function PetView:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function PetView:OnShow()
    self.tabGroup.noCheckRepeat = true
    if self.openArgs ~= nil and #self.openArgs > 0 then
        if self.openArgs[2] ~= nil then
            self.subIndex = self.openArgs[2]
        end
        self.tabGroup:ChangeTab(self.openArgs[1])
    else
        if self.currentIndex == 0 then
            self.tabGroup:ChangeTab(1)
        else
            self.tabGroup:ChangeTab(self.currentIndex)
        end
    end

    self:CheckGuide()
end

function PetView:OnHide()
    self.model.mySubIndex = self.subIndex
	if self.headbar ~= nil then
		self.headbar:Hiden()
	end
    if self.childheadbar ~= nil then
        self.childheadbar:Hiden()
    end
	local child = self.childTab[self.currentIndex]
    if child ~= nil then
        child:Hiden()
    end
    GuideManager.Instance:CloseWindow(self.windowId)

    if self.timeId_PlayIdleAction ~= nil then LuaTimer.Delete(self.timeId_PlayIdleAction) end
    if self.timeId_PlayAction ~= nil then LuaTimer.Delete(self.timeId_PlayAction) end

    if self.guideScript ~= nil then
        self.guideScript:DeleteMe()
        self.guideScript = nil
    end
    self.canGuideSecond = false
    self.canUpdateHead = false
end

function PetView:ChangeTab(index)
    if index == self.childIndex.child then              --如果是侧边栏4
        if #ChildrenManager.Instance:GetChildAdult() == 0 then
            -- 没有成年孩子数据,跳转
            if ChildrenManager.Instance:GetChildhood() ~= nil then
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.child_study_win,{self.subIndex})
            else
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.child_get_win,{self.subIndex})
            end
            return
        end
    end

	self:Show_Headbar((index ~= self.childIndex.manual and index ~= self.childIndex.child))  --不等于图鉴或子女，显示左侧边栏宠物头像
    self:Show_ChildHeadBar(index == self.childIndex.child)         --等于子女，显示子女头像

	if self.currentIndex ~= 0 and self.currentIndex ~= index then
        if self.childTab[self.currentIndex] ~= nil then
            self.childTab[self.currentIndex]:Hiden()
        end
    end
    self.currentIndex = index    --currentIndex赋值为1
    local child = self.childTab[self.currentIndex]
    if child == nil then
        if index == self.childIndex.base then
        	child = PetView_Base.New(self)
        elseif index == self.childIndex.wash then
            child = PetView_Wash.New(self)
        elseif index == self.childIndex.manual then
            child = PetView_Manual.New(self)
        elseif index == self.childIndex.child then
            child = PetChildView.New(self)
        else
        	child = PetView_Base.New(self)
        end
        self.childTab[self.currentIndex] = child
    end

    child:Show(self.subIndex)
    if index == self.childIndex.child and self.model.childVewIndex ~= nil then
        -- print("233333333333333333333333333333333333333333333333:" .. self.model.childVewIndex)
        child.tabGroup:ChangeTab(self.model.childVewIndex)
    end
    self.subIndex =nil
end

function PetView:Show_Headbar(show)
	if show then
		if self.headbar == nil then
			self.headbar = PetView_HeadBar.New(self)
		end
		self.headbar:Show()
	else
		if self.headbar ~= nil then
			self.headbar:Hiden()
		end
	end
end

function PetView:Show_ChildHeadBar(show)
    if show then
        if self.childheadbar == nil then
            self.childheadbar = PetChildHeadBar.New(self)
        end
        self.childheadbar:Show()
    else
        if self.childheadbar ~= nil then
            self.childheadbar:Hiden()
        end
    end
end

-------------------------------------
function PetView:SelectPet()
    local child = self.childTab[self.currentIndex]   --右侧边栏索引
    if child ~= nil then
        if child.init then child:update() child:close_all_tips() end
        -- if self.currentIndex == self.childIndex.wash then child:update_toggle() end
    end
end

function PetView:SelectChild()
    if self.currentIndex == self.childIndex.child then
        local child = self.childTab[self.currentIndex]
        if child ~= nil then
            if child.isInit then
                child:Update()
            end
        end
    end
end

function PetView:CloseAllTips()
    local child = self.childTab[self.currentIndex]
    if child ~= nil then
        if child.init then child:close_all_tips() end
        -- if self.currentIndex == self.childIndex.wash then child:update_toggle() end
    end
end

function PetView:load_preview(model_preview, data)
    -- self:event_pet_update({"upgrade"})

    if not BaseUtils.sametab(data, self.model_data) then
        self.model_data = data

        self.model_preview = model_preview
        local model_data = BaseUtils.copytab(self.model_data)
        self.previewComposite:Reload(model_data, function(composite) self:preview_loaded(composite) end)
    else
        self.model_preview = model_preview
        local rawImage = self.previewComposite.rawImage
        rawImage.transform:SetParent(self.model_preview)
        rawImage.transform.localPosition = Vector3(0, 0, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
    end
end

function PetView:preview_loaded(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.model_preview)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)

    composite.tpose.transform.localRotation = Quaternion.identity
    composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))

    if self.timeId_PlayIdleAction ~= nil then LuaTimer.Delete(self.timeId_PlayIdleAction) end
    self.timeId_PlayIdleAction = LuaTimer.Add(0, 15000, function() self:PlayIdleAction() end)

    self:showmodeleffectlist()
end


function PetView:showmodeleffect(effectid)
    if self.previewComposite.tpose ~= nil then
        print( string.format("effectid %s ", effectid))
        local fun = function(effectView)
            -- bugly #29717687 hosr 20160722
            if BaseUtils.isnull(self.previewComposite) or BaseUtils.isnull(self.previewComposite.tpose) then
                GameObject.Destroy(effectView.gameObject)
                return
            end

            local effectObject = effectView.gameObject

            effectObject.transform:SetParent(self.previewComposite.tpose.transform)
            effectObject.transform.localScale = Vector3.one
            effectObject.transform.localPosition = Vector3.zero
            effectObject.transform.localRotation = Quaternion.identity

            effectObject.transform:SetParent(PreviewManager.Instance.container.transform)

            Utils.ChangeLayersRecursively(effectObject.transform, "ModelPreview")
        end
        BaseEffectView.New({effectId = effectid, time = 1000, callback = fun})
    end
end

function PetView:showmodeleffectlist()
    for k,v in pairs(self.model_effect_list) do
        self:showmodeleffect(v)
    end
    self.model_effect_list = {}
end

-- function PetView:model_idle()
--     if transform ~= nil then
--         ModelPreview.Instance:PlayAction("idle")
--     end
-- end

function PetView:event_pet_update(update_list)
    for k,v in pairs(update_list) do
        if v == "genre" then
            table.insert(self.model_effect_list, 20008)
            self:showmodeleffectlist()
        elseif v == "upgrade" then
            table.insert(self.model_effect_list, 20010)
            self:showmodeleffectlist()
        end
    end
end

function PetView:selectPetObjByBaseId(baseid)
    return self.headbar:selectPetObjByBaseId(baseid)
end

function PetView:CheckGuide()
    if RoleManager.Instance.RoleData.lev >= 15 and RoleManager.Instance.RoleData.lev < 50 and PetManager.Instance.model:getpetid_bybaseid(10003) ~= nil then
        if QuestManager.Instance.questTab[10300] ~= nil or QuestManager.Instance.questTab[22300] ~= nil then
            -- 宠物洗髓
            local petData,_ = PetManager.Instance.model:getpet_byid(PetManager.Instance.model:getpetid_bybaseid(10003))
            QuestManager.Instance.model.lastGuidePetWash = petData.talent
            local questData = QuestManager.Instance.questTab[10300]
            if questData == nil then
                questData = QuestManager.Instance.questTab[22300]
            end

            if questData ~= nil then
                if questData.finish == QuestEumn.TaskStatus.Finish then
                    if self.guideScript ~= nil then
                        self.guideScript:DeleteMe()
                        self.guideScript = nil
                    end
                    -- if self.guideScript == nil then
                    --     self.guideScript = GuidePetWashClose.New(self)
                    --     self.guideScript:Show()
                    -- end
                else
                    PetManager.Instance.isWash = false
                    self.canUpdateHead = false
                    if self.guideScript == nil then
                        self.guideScript = GuidePetWash.New(self)
                        self.guideScript:Show(petData.status)
                    end
                end
            end

        -- elseif QuestManager.Instance.questTab[41560] ~= nil then
        --     -- 宠物打书
        --     local list = BackpackManager.Instance:GetItemByType(BackpackEumn.ItemType.petskillbook)
        --     local questData = QuestManager.Instance.questTab[41560]
        --     if #list > 0 and questData ~= nil and questData.finish ~= QuestEumn.TaskStatus.Finish then
        --         if self.guideScript == nil then
        --             self.guideScript = GuidePetBook.New(self)
        --             self.guideScript:Show()
        --         end
        --     end
        end
    end
end

function PetView:PlayAction()
    if self.timeId_PlayAction == nil and self.previewComposite ~= nil and self.previewComposite.tpose ~= nil and self.model_data ~= nil then
        local animationData = DataAnimation.data_npc_data[self.model_data.animationId]
        local action_list = { "1000", "2000", string.format("Idle%s", animationData.idle_id) }
        self.actionIndex_PlayAction = self.actionIndex_PlayAction + math.random(1, 2)

        --精灵少女宠物先屏蔽2000这个动作
        print(self.actionIndex_PlayAction)
        if self.model_data.modelId == 30264 and self.actionIndex_PlayAction == 2 then
            print("进来了,屏蔽")
            return
        end

        if self.actionIndex_PlayAction > #action_list then self.actionIndex_PlayAction = self.actionIndex_PlayAction - #action_list end
        local action_name = action_list[self.actionIndex_PlayAction]
        -- self.previewComposite.tpose:GetComponent(Animator):Play(action_name)
        self.previewComposite:PlayAnimation(action_name)
        local motion_event = DataMotionEvent.data_motion_event[string.format("%s_%s", action_name, self.model_data.modelId)]
        if motion_event ~= nil then
            if action_name == "1000" then
                self.timeId_PlayAction = LuaTimer.Add(motion_event.total, function()
                        self.timeId_PlayAction = nil
                        if not BaseUtils.isnull(self.previewComposite.tpose) then
                            -- self.previewComposite.tpose:GetComponent(Animator):Play(string.format("Stand%s", animationData.idle_id))
                            self.previewComposite:PlayMotion(FighterAction.Stand)
                        end
                    end)
            elseif action_name == "2000" then
                self.timeId_PlayAction = LuaTimer.Add(motion_event.total, function()
                        self.timeId_PlayAction = nil
                        if not BaseUtils.isnull(self.previewComposite.tpose) then
                            -- self.previewComposite.tpose:GetComponent(Animator):Play(string.format("Stand%s", animationData.idle_id))
                            self.previewComposite:PlayMotion(FighterAction.Stand)
                        end
                    end)
            else
                self.timeId_PlayAction = LuaTimer.Add(motion_event.total, function() self.timeId_PlayAction = nil end)
            end
        end
    end
end

function PetView:PlayIdleAction()
    if self.timeId_PlayAction == nil and self.previewComposite ~= nil and self.previewComposite.tpose ~= nil and self.model_data ~= nil then
        local animationData = DataAnimation.data_npc_data[self.model_data.animationId]
        -- self.previewComposite.tpose:GetComponent(Animator):Play(string.format("Idle%s", animationData.idle_id))
        self.previewComposite:PlayMotion(FighterAction.Idle)
    end
end

function PetView:CheckGuidePoint()
    if self.childTab ~= nil and self.childTab[1] ~= nil then
        self.childTab[1]:CheckGuidePoint()
    end
end

