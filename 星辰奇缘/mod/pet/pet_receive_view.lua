-- ----------------------------------------------------------
-- UI - 宠物查看窗口
-- ----------------------------------------------------------
PetReceiveView = PetReceiveView or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function PetReceiveView:__init(model)
    self.model = model
    self.name = "PetReceiveView"
    self.windowId = WindowConfig.WinID.petquickshow
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Destroy

    self.effectPath = "prefabs/effect/20104.unity3d"
    self.effect = nil

    self.resList = {
        {file = AssetConfig.pet_receive_window, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
        ,{file  =  AssetConfig.wingsbookbg, type  =  AssetType.Dep}
    }

    if RoleManager.Instance.RoleData.lev < 20 then
        table.insert(self.resList, {file = self.effectPath, type = AssetType.Dep})
    end

    self.gameObject = nil
    self.transform = nil

	------------------------------------------------
    self.skillicon_list = {}
    self.stone_list = {}
    self.itemSlot_list = {}
    self.model_preview = nil

	------------------------------------------------
    self.slider1_tweenId = 0
    self.slider2_tweenId = 0
    self.slider3_tweenId = 0
    self.slider4_tweenId = 0
    self.slider5_tweenId = 0

    self.timeId_PlayAction = nil
    self.actionIndex_PlayAction = 1
    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function PetReceiveView:__delete()
    for k,v in pairs(self.itemSlot_list) do
        v:DeleteMe()
        v = nil
    end

    if self.skillicon_list ~= nil then
        for i,v in ipairs(self.skillicon_list) do
            v:DeleteMe()
        end
    end
    self.skillicon_list = nil

    self:OnHide()

    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end

    if self.effect ~= nil then
        GameObject.DestroyImmediate(self.effect)
        self.effect = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function PetReceiveView:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pet_receive_window))
    self.gameObject.name = "PetReceiveView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.closeBtn = self.transform:FindChild("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    ----------------------------
    -- 初始化宝石图标
    local stonePanel = self.transform:FindChild("Main/EquipPanel").gameObject
    for i=1, 4 do
        local slot = ItemSlot.New()
        slot.gameObject.name = "item_slot"
        table.insert(self.itemSlot_list, slot)
        local stone = stonePanel.transform:FindChild("gem"..i).gameObject
        stone.name = tostring(i)
        UIUtils.AddUIChild(stone, slot.gameObject)
        table.insert(self.stone_list, stone)
    end

    -- 初始化技能图标
    local soltPanel = self.transform:FindChild("Main/SkillPanel/SoltPanel").gameObject
    for i=1, 8 do
        local slot = SkillSlot.New()
        UIUtils.AddUIChild(soltPanel, slot.gameObject)
        table.insert(self.skillicon_list, slot)
    end

    self.transform:FindChild("Main/ModlePanel/Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.preview = self.transform:FindChild("Main/ModlePanel/Preview")

    local btn = self.transform:FindChild("Main/ModlePanel/Preview").gameObject:AddComponent(Button)
    btn.onClick:AddListener(function() self:PlayAction() end)

    self.button = self.transform:FindChild("Main/Button").gameObject
    self.button_text = self.button.transform:FindChild("Text"):GetComponent(Text)
    self.button:GetComponent(Button).onClick:AddListener(function() self:click_button() end)

    if RoleManager.Instance.RoleData.lev < 20 then
        self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
        self.effect.transform:SetParent(self.button.transform)
        self.effect.transform.localScale = Vector3.one
        self.effect.transform.localPosition = Vector3(0, 0, -400)
        Utils.ChangeLayersRecursively(self.effect.transform, "UI")
        self.effect:SetActive(true)
    end

    ----------------------------
    LuaTimer.Add(10, function() self:OnShow() self:ClearMainAsset() end)
end

function PetReceiveView:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function PetReceiveView:OnShow()
	self:update()
end

function PetReceiveView:OnHide()
    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end

    if self.timeId_PlayIdleAction ~= nil then LuaTimer.Delete(self.timeId_PlayIdleAction) end
    if self.timeId_PlayAction ~= nil then LuaTimer.Delete(self.timeId_PlayAction) end
end

function PetReceiveView:update()
    self.cur_petdata = DataPet.data_pet_fresh[self.model.fresh_id]
    self.cur_petdata.base = BaseUtils.copytab(DataPet.data_pet[self.cur_petdata.base_id])
    if self.cur_petdata == nil then return end

    self:update_model()
    self:update_base()
    self:update_stone()
    self:update_baseattrs()
    self:update_qualityattrs()
    self:update_skill()
    self:update_button()
end

function PetReceiveView:update_model()
    local petData = self.cur_petdata
    local petModelData = self.model:getPetModel(petData)

    local data = {type = PreViewType.Pet, skinId = petModelData.skin, modelId = petModelData.modelId, animationId = petData.base.animation_id, scale = petData.base.scale / 100, effects = petModelData.effects}

    local setting = {
        name = "PetView"
        ,orthographicSize = 0.9
        ,width = 341
        ,height = 341
        ,offsetY = -0.4
    }

    local fun = function(composite)
        if BaseUtils.is_null(self.gameObject) then
            return
        end
        local rawImage = composite.rawImage
        rawImage.transform:SetParent(self.preview)
        rawImage.transform.localScale = Vector3(1, 1, 1)
        rawImage.transform.localPosition = Vector3(0, 0, 0)
        composite.tpose.transform.localRotation = Quaternion.identity
        composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))

        if self.timeId_PlayIdleAction ~= nil then LuaTimer.Delete(self.timeId_PlayIdleAction) end
        self.timeId_PlayIdleAction = LuaTimer.Add(0, 15000, function() self:PlayIdleAction() end)
    end

    self.previewComposite = PreviewComposite.New(fun, setting, data)
    self.previewComposite:BuildCamera(true)
end

function PetReceiveView:update_base()
    local petData = self.cur_petdata
    local gameObject = self.transform:FindChild("Main/ModlePanel").gameObject

    gameObject.transform:FindChild("NameText"):GetComponent(Text).text = petData.base.name
    gameObject.transform:FindChild("LevelText"):GetComponent(Text).text = string.format("Lv.%s", petData.lev)
    if petData.genre == 0 or petData.genre == 1 or petData.genre == 3 then
        gameObject.transform:FindChild("GenreImage"):GetComponent(Image).sprite
            = self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("I18N_Genre%s", (petData.genre+1)))
        gameObject.transform:FindChild("GenreImage").gameObject:SetActive(true)
    else
        gameObject.transform:FindChild("GenreImage").gameObject:SetActive(false)
    end
end

function PetReceiveView:update_stone()
    local petData = self.cur_petdata
    local gameObject = self.transform:FindChild("Main/EquipPanel").gameObject
    -- local stone_hole = petData.grade + 2

    -- for i=1,stone_hole do
    --     local icon = self.stone_list[i]
    --     local item_slot = self.itemSlot_list[i]

    --     local stonedata = nil
    --     for j=1,#petData.stones do
    --         if petData.stones[j].id == i then
    --             stonedata = petData.stones[j]
    --             break
    --         end
    --     end

    --     if stonedata ~= nil then
    --         local itemData = ItemData.New()
    --         itemData:SetBase(BackpackManager:GetItemBase(stonedata.base_id))
    --         itemData.attr = stonedata.attr
    --         item_slot:SetAll(itemData)
    --         item_slot.gameObject:SetActive(true)
    --     else
    --         item_slot.gameObject:SetActive(false)
    --     end
    --     icon.transform:FindChild("Image").gameObject:SetActive(true)
    --     icon.transform:FindChild("Lock").gameObject:SetActive(false)
    -- end

    -- for i=stone_hole+1,#self.stone_list do
    --     local icon = self.stone_list[i]
    --     icon.transform:FindChild("item_slot").gameObject:SetActive(false)
    --     icon.transform:FindChild("Image").gameObject:SetActive(false)
    --     icon.transform:FindChild("Lock").gameObject:SetActive(true)
    -- end
    for i=1,#self.stone_list do
        local icon = self.stone_list[i]
        icon.transform:FindChild("item_slot").gameObject:SetActive(false)
        icon.transform:FindChild("Image").gameObject:SetActive(false)
        icon.transform:FindChild("Lock").gameObject:SetActive(true)
    end
end

function PetReceiveView:update_baseattrs()
    local petData = self.cur_petdata

    local gameObject = self.transform:FindChild("Main/AttrPanel").gameObject
    gameObject.transform:FindChild("AttrObject1/ValueText"):GetComponent(Text).text = string.format("%s/%s", petData.hp, petData.hp)
    gameObject.transform:FindChild("AttrObject2/ValueText"):GetComponent(Text).text = string.format("%s/%s", petData.mp, petData.mp)
    gameObject.transform:FindChild("AttrObject3/ValueText"):GetComponent(Text).text = tostring(petData.phy)
    gameObject.transform:FindChild("AttrObject4/ValueText"):GetComponent(Text).text = tostring(petData.magic)
    gameObject.transform:FindChild("AttrObject5/ValueText"):GetComponent(Text).text = tostring(petData.pdef)
    gameObject.transform:FindChild("AttrObject6/ValueText"):GetComponent(Text).text = tostring(petData.mdef)
    gameObject.transform:FindChild("AttrObject7/ValueText"):GetComponent(Text).text = tostring(petData.aspd)
end

function PetReceiveView:update_qualityattrs()
    local petData = self.cur_petdata
    local gameObject = self.transform:FindChild("Main/WashPanel").gameObject
    gameObject.transform:FindChild("ValueSlider1/Text"):GetComponent(Text).text = string.format("%s/%s", petData.phy_aptitude, petData.phy_aptitude)
    gameObject.transform:FindChild("ValueSlider2/Text"):GetComponent(Text).text = string.format("%s/%s", petData.pdef_aptitude, petData.pdef_aptitude)
    gameObject.transform:FindChild("ValueSlider3/Text"):GetComponent(Text).text = string.format("%s/%s", petData.hp_aptitude, petData.hp_aptitude)
    gameObject.transform:FindChild("ValueSlider4/Text"):GetComponent(Text).text = string.format("%s/%s", petData.magic_aptitude, petData.magic_aptitude)
    gameObject.transform:FindChild("ValueSlider5/Text"):GetComponent(Text).text = string.format("%s/%s", petData.aspd_aptitude, petData.aspd_aptitude)

    -- Tween.Instance:Cancel(self.slider1_tweenId)
    -- Tween.Instance:Cancel(self.slider2_tweenId)
    -- Tween.Instance:Cancel(self.slider3_tweenId)
    -- Tween.Instance:Cancel(self.slider4_tweenId)
    -- Tween.Instance:Cancel(self.slider5_tweenId)

    -- local slider1 = gameObject.transform:FindChild("ValueSlider1/Slider"):GetComponent(Slider)
    -- local fun1 = function(value) slider1.value = value end
    -- self.slider1_tweenId = Tween.Instance:ValueChange(slider1.value, ((petData.phy_aptitude - petData.base.phy_aptitude * 0.8) / (petData.phy_aptitude - petData.base.phy_aptitude * 0.8) * 0.8 + 0.2), 0.3, nil, LeanTweenType.linear, fun1).id

    -- local slider2 = gameObject.transform:FindChild("ValueSlider2/Slider"):GetComponent(Slider)
    -- local fun2 = function(value) slider2.value = value end
    -- self.slider2_tweenId = Tween.Instance:ValueChange(slider2.value, ((petData.pdef_aptitude - petData.base.pdef_aptitude * 0.8) / (petData.pdef_aptitude - petData.base.pdef_aptitude * 0.8) * 0.8 + 0.2), 0.3, nil, LeanTweenType.linear, fun2).id

    -- local slider3 = gameObject.transform:FindChild("ValueSlider3/Slider"):GetComponent(Slider)
    -- local fun3 = function(value) slider3.value = value end
    -- self.slider3_tweenId = Tween.Instance:ValueChange(slider3.value, ((petData.hp_aptitude - petData.base.hp_aptitude * 0.8) / (petData.hp_aptitude - petData.base.hp_aptitude * 0.8) * 0.8 + 0.2), 0.3, nil, LeanTweenType.linear, fun3).id

    -- local slider4 = gameObject.transform:FindChild("ValueSlider4/Slider"):GetComponent(Slider)
    -- local fun4 = function(value) slider4.value = value end
    -- self.slider4_tweenId = Tween.Instance:ValueChange(slider4.value, ((petData.magic_aptitude - petData.base.magic_aptitude * 0.8) / (petData.magic_aptitude - petData.base.magic_aptitude * 0.8) * 0.8 + 0.2), 0.3, nil, LeanTweenType.linear, fun4).id

    -- local slider5 = gameObject.transform:FindChild("ValueSlider5/Slider"):GetComponent(Slider)
    -- local fun5 = function(value) slider5.value = value end
    -- self.slider5_tweenId = Tween.Instance:ValueChange(slider5.value, ((petData.aspd_aptitude - petData.base.aspd_aptitude * 0.8) / (petData.aspd_aptitude- petData.base.aspd_aptitude * 0.8) * 0.8 + 0.2), 0.3, nil, LeanTweenType.linear, fun5).id

    gameObject.transform:FindChild("ValueSlider1/Slider"):GetComponent(Slider).value = ((petData.phy_aptitude - petData.base.phy_aptitude * 0.8) / (petData.phy_aptitude - petData.base.phy_aptitude * 0.8 + 0.0001) * 0.8 + 0.2)
    gameObject.transform:FindChild("ValueSlider2/Slider"):GetComponent(Slider).value = ((petData.pdef_aptitude - petData.base.pdef_aptitude * 0.8) / (petData.pdef_aptitude - petData.base.pdef_aptitude * 0.8 + 0.0001) * 0.8 + 0.2)
    gameObject.transform:FindChild("ValueSlider3/Slider"):GetComponent(Slider).value = ((petData.hp_aptitude - petData.base.hp_aptitude * 0.8) / (petData.hp_aptitude - petData.base.hp_aptitude * 0.8 + 0.0001) * 0.8 + 0.2)
    gameObject.transform:FindChild("ValueSlider4/Slider"):GetComponent(Slider).value = ((petData.magic_aptitude - petData.base.magic_aptitude * 0.8) / (petData.magic_aptitude - petData.base.magic_aptitude * 0.8 + 0.0001) * 0.8 + 0.2)
    gameObject.transform:FindChild("ValueSlider5/Slider"):GetComponent(Slider).value = ((petData.aspd_aptitude - petData.base.aspd_aptitude * 0.8) / (petData.aspd_aptitude- petData.base.aspd_aptitude * 0.8 + 0.0001) * 0.8 + 0.2)

    gameObject.transform:FindChild("GifeText"):GetComponent(Text).text = string.format("%s(%s)", self.model:gettalentclass(petData.talent), petData.talent)
    gameObject.transform:FindChild("GrowthImage"):GetComponent(Image).sprite
        = self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("PetGrowth%s", petData.growth_type))
end

function PetReceiveView:update_skill()
    local petData = self.cur_petdata

    for i=1,#petData.skills do
        local skill_id = petData.skills[i]
        local icon = self.skillicon_list[i]
        local data = DataSkill.data_petSkill[string.format("%s_1", skill_id)]
        icon:SetAll(Skilltype.petskill, data)
    end

    for i=#petData.skills+1,#self.skillicon_list do
        local icon = self.skillicon_list[i]
        icon:SetAll(Skilltype.petskill, nil)
    end
end

function PetReceiveView:update_button()
    local petData = self.cur_petdata

    if RoleManager.Instance.RoleData.lev < petData.need_lev then
        self.button_text.text = string.format(TI18N("%s级领取"), petData.need_lev)
    else
        self.button_text.text = TI18N("领 取")
        local fun = function(effectView)
            local effectObject = effectView.gameObject

            effectObject.transform:SetParent(self.button.transform)
            effectObject.transform.localScale = Vector3(1, 0.85, 1)
            effectObject.transform.localPosition = Vector3(-50, 24, -10)
            effectObject.transform.localRotation = Quaternion.identity

            Utils.ChangeLayersRecursively(effectObject.transform, "UI")
            effectObject:SetActive(true)
        end
        BaseEffectView.New({effectId = 20118 , time = nil, callback = fun})
    end
end

function PetReceiveView:click_button()
    local petData = self.cur_petdata

    if RoleManager.Instance.RoleData.lev < petData.need_lev then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("要%s级才能领取哦"), petData.need_lev))
    else
        PetManager.Instance:Send10527()
        self:OnClickClose()
    end
end

function PetReceiveView:PlayAction()
    if self.timeId_PlayAction == nil and self.previewComposite ~= nil and self.previewComposite.tpose ~= nil and self.model.quickshow_petdata ~= nil then
        local petData = self.model.quickshow_petdata
        local petModelData = self.model:getPetModel(petData)

        local animationData = DataAnimation.data_npc_data[petData.base.animation_id]
        local action_list = { "1000", "2000", string.format("Idle%s", animationData.idle_id) }
        self.actionIndex_PlayAction = self.actionIndex_PlayAction + math.random(1, 2)
        if self.actionIndex_PlayAction > #action_list then self.actionIndex_PlayAction = self.actionIndex_PlayAction - #action_list end
        local action_name = action_list[self.actionIndex_PlayAction]
        self.previewComposite.tpose:GetComponent(Animator):Play(action_name)

        local motion_event = DataMotionEvent.data_motion_event[string.format("%s_%s", action_name, petModelData.modelId)]
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

function PetReceiveView:PlayIdleAction()
    if self.timeId_PlayAction == nil and self.previewComposite ~= nil and self.previewComposite.tpose ~= nil and self.model.quickshow_petdata ~= nil then
        local petData = self.model.quickshow_petdata

        local animationData = DataAnimation.data_npc_data[petData.base.animation_id]
        self.previewComposite.tpose:GetComponent(Animator):Play(string.format("Idle%s", animationData.idle_id))
    end
end