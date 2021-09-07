-- ----------------------------------------------------------
-- UI - 宠物合成窗口
-- ----------------------------------------------------------
PetFuseView = PetFuseView or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function PetFuseView:__init(model)
    self.model = model
    self.name = "PetFuseView"
    self.windowId = WindowConfig.WinID.petquickshow
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Destroy

    self.resList = {
        {file = AssetConfig.petfusewindow, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
        ,{file  = AssetConfig.wingsbookbg, type  =  AssetType.Dep}
        , {file = AssetConfig.ride_texture, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

	------------------------------------------------
    self.petData = nil

    self.petFuesDataList = {}
    self.index = 1


    self.skillicon_list = {}
    self.itemSlot_list = {}
    self.model_preview = nil
    self.skillItemList = {}

	------------------------------------------------

    self.timeId_PlayAction = nil
    self.timeId_PlayIdleAction = nil
    self.actionIndex_PlayAction = 1
    ------------------------------------------------

    self.onClickStoneShowWashPanelFun = function (slotItemData)
        self:onClickStoneShowWashPanel(slotItemData)
    end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function PetFuseView:__delete()
    if self.itemSolt ~= nil then
        self.itemSolt:DeleteMe()
        self.itemSolt = nil
    end
    self:OnHide()

    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end

    for i,v in ipairs(self.skillicon_list) do
        v:DeleteMe()
    end
    self.skillicon_list = nil

    for i,v in ipairs(self.skillItemList) do
        v:DeleteMe()
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function PetFuseView:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.petfusewindow))
    self.gameObject.name = "PetFuseView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform


    self.closeBtn = self.transform:FindChild("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    ----------------------------
    -- 初始化技能图标
    local soltPanel = self.transform:FindChild("Main/Panel/SkillPanel/Mask/SoltPanel").gameObject
    for i=1, 10 do
        local slot = SkillSlot.New()
        UIUtils.AddUIChild(soltPanel, slot.gameObject)
        table.insert(self.skillicon_list, slot)
    end

    self.transform:FindChild("Main/Panel/ModelPanel"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.preview = self.transform:FindChild("Main/Panel/ModelPanel/Preview")

    self.needItem = self.transform:Find("Main/Panel/ItemPanel/NeedItem/ImageParent")
    self.needCount = self.transform:Find("Main/Panel/ItemPanel/NeedItem/CntImage/Text"):GetComponent(Text)
    self.itemSolt = ItemSlot.New()
    UIUtils.AddUIChild(self.needItem.gameObject, self.itemSolt.gameObject)

    self.nextButton = self.transform:Find("Main/Panel/NextButton").gameObject
    self.nextButton:GetComponent(Button).onClick:AddListener(function() self:OnNextButtonClick() end)
    self.preButton = self.transform:Find("Main/Panel/PreButton").gameObject
    self.preButton:GetComponent(Button).onClick:AddListener(function() self:OnPreButtonClick() end)

    local btn = self.transform:FindChild("Main/Panel/ModelPanel/Preview").gameObject:AddComponent(Button)
    btn.onClick:AddListener(function() self:PlayAction() end)

    self.transform:FindChild("Main/Panel/OkButton"):GetComponent(Button).onClick:AddListener(function() self:OnOkButtonClick() end)
    ----------------------------
    LuaTimer.Add(10, function() self:OnShow() self:ClearMainAsset() end)
end

function PetFuseView:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function PetFuseView:OnShow()
    if self.openArgs ~= nil and #self.openArgs > 0 then
        self.petData = BaseUtils.copytab(DataPet.data_pet[self.openArgs[1]])

        self.petFuesDataList = {}
        self.index = 1
        local pet_fues_data = DataPet.data_pet_fues[self.openArgs[1]]
        for key, value in pairs(DataPet.data_pet_fues) do
            if value.need_lev_break_times == pet_fues_data.need_lev_break_times and value.need_lev == pet_fues_data.need_lev then
                table.insert(self.petFuesDataList, value)
                if value.base_id == self.petData.id then
                    self.index = #self.petFuesDataList
                end
            end
        end

        -- self.transform:FindChild("Main/Title/Text"):GetComponent(Text).text = string.format(TI18N("%s宠物召唤"), pet_fues_data.need_lev)
        self.transform:FindChild("Main/Title/Text"):GetComponent(Text).text = TI18N("宠物召唤")
    end

    self:update_page()
	self:update()
end

function PetFuseView:OnHide()
    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end

    if self.timeId_PlayIdleAction ~= nil then LuaTimer.Delete(self.timeId_PlayIdleAction) end
    if self.timeId_PlayAction ~= nil then LuaTimer.Delete(self.timeId_PlayAction) end
end

function PetFuseView:update()
    if self.petData == nil then return end

    self:update_model()
    self:update_base()
    self:update_skill()
    self:update_item()
end

function PetFuseView:update_model()
    local petData = self.petData

    local data = {type = PreViewType.Pet, skinId = petData.skin_id_s0, modelId = petData.model_id, animationId = petData.animation_id, scale = petData.scale / 100, effects = petData.effects_s0}

    local setting = {
        name = "PetView"
        ,orthographicSize = 0.6
        ,width = 341
        ,height = 341
        ,offsetY = -0.22
    }

    local fun = function(composite)
        if BaseUtils.is_null(self.gameObject) or BaseUtils.is_null(self.preview) then
            -- bugly #29765622 hosr 20160722
            return
        end
        local rawImage = composite.rawImage
        rawImage.transform:SetParent(self.preview)
        rawImage.transform.localPosition = Vector3(0, 0, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
        composite.tpose.transform.localRotation = Quaternion.identity
        composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))

        if self.timeId_PlayIdleAction ~= nil then LuaTimer.Delete(self.timeId_PlayIdleAction) end
        self.timeId_PlayIdleAction = LuaTimer.Add(0, 15000, function() self:PlayIdleAction() end)
    end

    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end
    self.previewComposite = PreviewComposite.New(fun, setting, data)
    self.previewComposite:BuildCamera(true)
end

function PetFuseView:update_base()
    local petData = self.petData

    self.transform:FindChild("Main/Panel/ModelPanel/NameText"):GetComponent(Text).text = petData.name

    local storyText = self.transform:FindChild("Main/Panel/StoryPanel/Mask/StoryText"):GetComponent(Text)
    storyText.text = self.petFuesDataList[self.index].story
    local preferredHeight = storyText.preferredHeight
    local rectTransform = storyText.gameObject:GetComponent(RectTransform)
    rectTransform.sizeDelta = Vector2(285.85, preferredHeight)
    rectTransform.anchoredPosition = Vector2(-2.5, 0)
end

function PetFuseView:update_skill()
    local petData = self.petData
    local base_skills = petData.base_skills
    local tempList = {}
    for i = 1, #base_skills do
        tempList[i] = { id = base_skills[i][1] }
    end

    local skills = self.model:makeBreakSkill(petData.id, tempList)

    local change_skill_data = DataPet.data_pet_change_skill[petData.id]
    if change_skill_data ~= nil then
        table.insert(skills, 1, { id = change_skill_data.skill_id, isBreak = false })
    end

    for i=1,#skills do
        local skilldata = skills[i]
        local icon = self.skillicon_list[i]
        local data = DataSkill.data_petSkill[string.format("%s_1", skilldata.id)]
        icon:SetAll(Skilltype.petskill, data)
        icon:ShowState(skilldata.source == 2)
        icon:ShowLabel(skilldata.source == 4 or skilldata.isBreak, TI18N("<color='#ffff00'>突破</color>"))
        icon:ShowBreak(skilldata.isBreak, TI18N("<color='#FF0000'>未激活</color>"))
        icon.gameObject:SetActive(true)
    end

    for i=#skills+1,#self.skillicon_list do
        local icon = self.skillicon_list[i]
        -- icon:SetAll(Skilltype.petskill, nil)
        -- icon:ShowState(false)
        icon.gameObject:SetActive(false)
    end
end

function PetFuseView:update_item()
    local fuesData = self.petFuesDataList[self.index]

    local itembase = BackpackManager.Instance:GetItemBase(fuesData.loss[1][1])
    local itemData = ItemData.New()
    itemData:SetBase(itembase)
    self.itemSolt:SetAll(itemData)

    local num = BackpackManager.Instance:GetItemCount(fuesData.loss[1][1])
    local need = fuesData.loss[1][2]
    self.enough = num >= need
    local color = self.enough and ColorHelper.color[1] or ColorHelper.color[4]
    self.needCount.text = string.format("<color='%s'>%s</color>/%s", color, num, need)
end

function PetFuseView:update_page()
    if self.index == 1 then
        self.preButton:SetActive(false)
    else
        self.preButton:SetActive(true)
    end
    if self.index == #self.petFuesDataList then
        self.nextButton:SetActive(false)
    else
        self.nextButton:SetActive(true)
    end
end

function PetFuseView:OnNextButtonClick()
    if self.index < #self.petFuesDataList then
        self.index = self.index + 1
        self.petData = BaseUtils.copytab(DataPet.data_pet[self.petFuesDataList[self.index].base_id])
        self:update_page()
        self:update()
    end
end

function PetFuseView:OnPreButtonClick()
    if self.index > 1 then
        self.index = self.index - 1
        self.petData = BaseUtils.copytab(DataPet.data_pet[self.petFuesDataList[self.index].base_id])
        self:update_page()
        self:update()
    end
end

function PetFuseView:PlayAction()
    if self.timeId_PlayAction == nil and self.previewComposite ~= nil and self.previewComposite.tpose ~= nil and self.petData ~= nil then
        local petData = self.petData

        local animationData = DataAnimation.data_npc_data[petData.animation_id]
        local action_list = { "1000", "2000", string.format("Idle%s", animationData.idle_id) }
        self.actionIndex_PlayAction = self.actionIndex_PlayAction + math.random(1, 2)
        if self.actionIndex_PlayAction > #action_list then self.actionIndex_PlayAction = self.actionIndex_PlayAction - #action_list end
        local action_name = action_list[self.actionIndex_PlayAction]
        self.previewComposite.tpose:GetComponent(Animator):Play(action_name)

        local motion_event = DataMotionEvent.data_motion_event[string.format("%s_%s", action_name, petData.model_id)]
        if motion_event ~= nil then
            if action_name == "1000" then
                self.timeId_PlayAction = LuaTimer.Add(motion_event.total, function() self.timeId_PlayAction = nil if not BaseUtils.isnull(self.previewComposite.tpose) then self.previewComposite.tpose:GetComponent(Animator):Play(string.format("Stand%s", animationData.idle_id)) end end)
            elseif action_name == "2000" then
                self.timeId_PlayAction = LuaTimer.Add(motion_event.total, function() self.timeId_PlayAction = nil if not BaseUtils.isnull(self.previewComposite.tpose) then self.previewComposite.tpose:GetComponent(Animator):Play(string.format("Stand%s", animationData.idle_id)) end end)
            else
                self.timeId_PlayAction = LuaTimer.Add(motion_event.total, function() self.timeId_PlayAction = nil end)
            end
        end
    end
end

function PetFuseView:PlayIdleAction()
    if self.timeId_PlayAction == nil and self.previewComposite ~= nil and self.previewComposite.tpose ~= nil and self.petData ~= nil then
        local petData = self.petData

        local animationData = DataAnimation.data_npc_data[petData.animation_id]
        self.previewComposite.tpose:GetComponent(Animator):Play(string.format("Idle%s", animationData.idle_id))
    end
end

function PetFuseView:OnOkButtonClick()
    if self.enough then
        PetManager.Instance:Send10560(self.petData.id)
    else
        TipsManager.Instance:ShowItem(self.itemSolt)
        NoticeManager.Instance:FloatTipsByString(TI18N("道具不足，无法召唤"))
    end
end