-- ----------------------------------------------------------
-- UI - 宠物查看窗口
-- ----------------------------------------------------------
PetQuickShowView = PetQuickShowView or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function PetQuickShowView:__init(model)
    self.model = model
    self.name = "PetQuickShowView"
    self.windowId = WindowConfig.WinID.petquickshow
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Destroy

    self.resList = {
        {file = AssetConfig.pet_quickshow_window, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
        ,{file  = AssetConfig.wingsbookbg, type  =  AssetType.Dep}
        , {file = AssetConfig.ride_texture, type = AssetType.Dep}
        ,{file = AssetConfig.petquickshowrunepanel_bg , type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

	------------------------------------------------
    self.skillicon_list = {}
    self.stone_list = {}
    self.itemSlot_list = {}
    self.model_preview = nil
    self.skillItemList = {}
    self.rune_list = {}
    self.smart_rune = nil

	------------------------------------------------
    self.slider1_tweenId = 0
    self.slider2_tweenId = 0
    self.slider3_tweenId = 0
    self.slider4_tweenId = 0
    self.slider5_tweenId = 0

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

function PetQuickShowView:__delete()
    for k,v in pairs(self.itemSlot_list) do
        v:DeleteMe()
        v = nil
    end

    if self.headLoader ~= nil then
        self.headLoader:DeleteMe()
        self.headLoader = nil
    end

    if self.headLoader2 ~= nil then
        self.headLoader2:DeleteMe()
        self.headLoader2 = nil
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

    if self.rune_list ~= nil then 
        for _,item in ipairs(self.rune_list) do
            if item.effect ~= nil then 
                item.effect:DeleteMe()
            end
            if item.effect2 ~= nil then 
                item.effect2:DeleteMe()
            end
            if item.iconloader ~= nil then 
                item.iconloader:DeleteMe()
            end
        end
    end

    if self.smart_rune ~= nil then 
        if self.smart_rune.effect ~= nil then 
            self.smart_rune.effect:DeleteMe()
        end
        if self.smart_rune.effect2 ~= nil then 
            self.smart_rune.effect2:DeleteMe()
        end
        if self.smart_rune.iconloader ~= nil then 
            self.smart_rune.iconloader:DeleteMe()
        end
    end

    BaseUtils.ReleaseImage(self.runePanel:Find("Bg"):GetComponent(Image))

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function PetQuickShowView:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pet_quickshow_window))
    self.gameObject.name = "PetQuickShowView"
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
    self.skillPanelObj = self.transform:Find("Main/SkillPanel").gameObject
    local soltPanel = self.transform:FindChild("Main/SkillPanel/SoltPanel").gameObject
    for i=1, 15 do
        local slot = SkillSlot.New()
        UIUtils.AddUIChild(soltPanel, slot.gameObject)
        table.insert(self.skillicon_list, slot)
    end

    self.rideSkillPanelObj =  self.transform:Find("Main/RideSkillPanel").gameObject
    self.skillContainer = self.transform:FindChild("Main/RideSkillPanel/Mask/Container")
    self.skillContainerRect = self.skillContainer:GetComponent(RectTransform)

    local rideSkillItemCloner = self.skillContainer:GetChild(1).gameObject
    for i = 1, 10 do
        local item = GameObject.Instantiate(rideSkillItemCloner)
        item:SetActive(true)
        item.transform:SetParent(self.skillContainer.transform)
        item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
        item:GetComponent(RectTransform).localPosition = Vector3(448 + i * 76, -2.3, 0)
    end

    local len = self.skillContainer.childCount
    for i = 1, len do
        local index = i
        local item = RideSkillItem.New(self.skillContainer:GetChild(i - 1).gameObject, self, true, false, index)
        item.specialNotice = TI18N("尚无坐骑<color='#ffff00'>契约技能</color>")
        table.insert(self.skillItemList, item)
    end

    self.transform:FindChild("Main/ModlePanel/Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.preview = self.transform:FindChild("Main/ModlePanel/Preview")

    local btn = self.transform:FindChild("Main/ModlePanel/Preview").gameObject:AddComponent(Button)
    btn.onClick:AddListener(function() self:PlayAction() end)

    -- 图鉴
    btn = self.transform:FindChild("Main/HandBookButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:onHandBookButtonClick() end)
    btn.gameObject:SetActive(true)
    self.handbookBtnObj = btn.gameObject

    self.handBookPanel = self.transform:FindChild("Main/HandBookPanel").gameObject
    self.handBookPanel:GetComponent(Button).onClick:AddListener(function() self:hideHandBookPanel() end)

    --附灵
    btn = self.transform:FindChild("Main/SpritButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:onSpritButtonClick() end)
    btn.gameObject:SetActive(true)
    self.spritBtnObj = btn.gameObject

    self.spritPanel = self.transform:FindChild("Main/SpritPanel").gameObject
    self.spritPanel:GetComponent(Button).onClick:AddListener(function() self:hideSpritPanel() end)

    self.skillSlot = SkillSlot.New()
    UIUtils.AddUIChild(self.spritPanel.transform:FindChild("Main/SkillPanel/SkillIcon").gameObject, self.skillSlot.gameObject)

    --内丹
    self.runePanel = self.transform:Find("Main/PetRunePanel")
    self.runePanel:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.petquickshowrunepanel_bg, "PetQuickShowRunePanelBg")
    for i = 1 ,5 do
        self.rune_list[i] = self:CreateRuneItem(self.runePanel:Find(string.format("Normal/Item%s",i)))
    end
    self.smart_rune = self:CreateRuneItem(self.runePanel:Find("Smart"))

    ----------------------------
    local setting = {
        perWidth = 70
        , perHeight = 30
        , isVertical = false
        , notAutoSelect = false
        , noCheckRepeat = false
        , spacing = 0
    }
    self.tabGroup = TabGroup.New(self.transform:FindChild("Main/TabGroup").gameObject, function(index) self:ChangeTab(index) end, setting)



    LuaTimer.Add(10, function() self:OnShow() self:ClearMainAsset() end)
end

function PetQuickShowView:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function PetQuickShowView:OnShow()
	self:update()
end

function PetQuickShowView:OnHide()
    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end

    if self.timeId_PlayIdleAction ~= nil then LuaTimer.Delete(self.timeId_PlayIdleAction) end
    if self.timeId_PlayAction ~= nil then LuaTimer.Delete(self.timeId_PlayAction) end
end

function PetQuickShowView:update()
    if self.model.quickshow_petdata == nil then return end

    self:update_model()
    self:update_base()
    self:update_stone()
    self:update_baseattrs()
    self:update_qualityattrs()
    self:update_skill()
    self:update_rideskill()
    self:update_rune()

    if self.model.quickshow_petdata.spirit_info ~= nil and #self.model.quickshow_petdata.spirit_info > 0 then
        -- self.handbookBtnObj.transform.localPosition = Vector2(-196.1, 147.5)
        self.spritBtnObj:SetActive(true)
    else
        -- self.handbookBtnObj.transform.localPosition = Vector2(-156, 147.5)
        self.spritBtnObj:SetActive(false)
    end
end

function PetQuickShowView:update_model()
    local petData = self.model.quickshow_petdata
    local petModelData = self.model:getPetModel(petData)

    local data = {type = PreViewType.Pet, skinId = petModelData.skin, modelId = petModelData.modelId, animationId = petData.base.animation_id, scale = petData.base.scale / 100, effects = petModelData.effects}
     --处理宠物幻化 jia
    local transList = petData.unreal;
    local isOpen = false;
    if transList ~= nil and #transList > 0 and DataPet.data_pet_trans_black[petData.base_id] == nil then
        isOpen = true
    end
    if isOpen and petData.unreal_looks_flag == 0 then
        local taransData = transList[1];
        local itemID = taransData.item_id
        local endTime = taransData.timeout
        if endTime > BaseUtils.BASE_TIME then
            local transTmp = DataPet.data_pet_trans[itemID];
            if transTmp ~= nil then
                local transFTmp = DataTransform.data_transform[transTmp.skin_id];
                if transFTmp ~= nil then
                    data.modelId = transFTmp.res
                    data.skinId = transFTmp.skin
                    data.animationId = transFTmp.animation_id
                    data.effects = transFTmp.effects
                    data.scale = transFTmp.scale / 100
                end
            end
        end
    end
    local setting = {
        name = "PetView"
        ,orthographicSize = 0.8
        ,width = 341
        ,height = 341
        ,offsetY = -0.3
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

function PetQuickShowView:update_base()
    local petData = self.model.quickshow_petdata
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

    if self.model.quickshow_petdata.handbook_attr == nil then
        self.handbookBtnObj:SetActive(false)
    else
        self.handbookBtnObj:SetActive(true)
    end
end

function PetQuickShowView:update_stone()
    local petData = self.model.quickshow_petdata
    local gameObject = self.transform:FindChild("Main/EquipPanel").gameObject
    local stone_hole = petData.grade + 2
    if stone_hole > 4 then stone_hole = 4 end

    for i=1,stone_hole do
        local icon = self.stone_list[i]
        local item_slot = self.itemSlot_list[i]

        local stonedata = nil
        if petData.stones ~= nil then
            for j=1,#petData.stones do
                if petData.stones[j].id == i then
                    stonedata = petData.stones[j]
                    break
                end
            end
        end

        if stonedata ~= nil then
            local itemData = ItemData.New()
            itemData:SetBase(BackpackManager:GetItemBase(stonedata.base_id))
            itemData.id = stonedata.id
            itemData.attr = stonedata.attr
            itemData.reset_attr = stonedata.reset_attr
            itemData.extra = stonedata.extra
            item_slot:SetAll(itemData)
            item_slot.gameObject:SetActive(true)

            --符石点击特殊处理
            if i > 1 then -- 除去第一个护符,只针对符石
                local dataTemp = DataPet.data_pet_grade[string.format("%s_%s", petData.base.id, petData.grade+1)]
                if dataTemp ~= nil then
                    --宠物还可以进阶
                    item_slot.noTips = false
                    item_slot.click_self_call_back = nil
                else
                    --宠物已经是最高阶了
                    item_slot.noTips = true
                    item_slot.click_self_call_back = self.onClickStoneShowWashPanelFun
                end
            end
        else
            item_slot.gameObject:SetActive(false)
        end
        icon.transform:FindChild("Image").gameObject:SetActive(true)
        icon.transform:FindChild("Lock").gameObject:SetActive(false)
    end

    for i=stone_hole+1,#self.stone_list do
        local icon = self.stone_list[i]
        icon.transform:FindChild("item_slot").gameObject:SetActive(false)
        icon.transform:FindChild("Image").gameObject:SetActive(false)
        icon.transform:FindChild("Lock").gameObject:SetActive(true)
    end
end

function PetQuickShowView:update_baseattrs()
    local petData = self.model.quickshow_petdata

    local gameObject = self.transform:FindChild("Main/AttrPanel").gameObject
    gameObject.transform:FindChild("AttrObject1/ValueText"):GetComponent(Text).text = string.format("%s/%s", petData.hp, petData.hp)
    gameObject.transform:FindChild("AttrObject2/ValueText"):GetComponent(Text).text = string.format("%s/%s", petData.mp, petData.mp)
    gameObject.transform:FindChild("AttrObject3/ValueText"):GetComponent(Text).text = tostring(petData.phy_dmg)
    gameObject.transform:FindChild("AttrObject4/ValueText"):GetComponent(Text).text = tostring(petData.magic_dmg)
    gameObject.transform:FindChild("AttrObject5/ValueText"):GetComponent(Text).text = tostring(petData.phy_def)
    gameObject.transform:FindChild("AttrObject6/ValueText"):GetComponent(Text).text = tostring(petData.magic_def)
    gameObject.transform:FindChild("AttrObject7/ValueText"):GetComponent(Text).text = tostring(petData.atk_speed)

    gameObject.transform:FindChild("AttrObject1/ValueText"):GetComponent(Text).color = Color(232/255, 250/255, 255/255)
    gameObject.transform:FindChild("AttrObject2/ValueText"):GetComponent(Text).color = Color(232/255, 250/255, 255/255)
end

function PetQuickShowView:update_qualityattrs()
    local petData = self.model.quickshow_petdata
    local gameObject = self.transform:FindChild("Main/WashPanel").gameObject
    gameObject.transform:FindChild("ValueSlider1/Text"):GetComponent(Text).text = string.format("%s/%s", petData.phy_aptitude, petData.max_phy_aptitude)
    gameObject.transform:FindChild("ValueSlider2/Text"):GetComponent(Text).text = string.format("%s/%s", petData.pdef_aptitude, petData.max_pdef_aptitude)
    gameObject.transform:FindChild("ValueSlider3/Text"):GetComponent(Text).text = string.format("%s/%s", petData.hp_aptitude, petData.max_hp_aptitude)
    gameObject.transform:FindChild("ValueSlider4/Text"):GetComponent(Text).text = string.format("%s/%s", petData.magic_aptitude, petData.max_magic_aptitude)
    gameObject.transform:FindChild("ValueSlider5/Text"):GetComponent(Text).text = string.format("%s/%s", petData.aspd_aptitude, petData.max_aspd_aptitude)

    gameObject.transform:FindChild("ValueSlider1/Text"):GetComponent(Text).color = Color(232/255, 250/255, 255/255)
    gameObject.transform:FindChild("ValueSlider2/Text"):GetComponent(Text).color = Color(232/255, 250/255, 255/255)
    gameObject.transform:FindChild("ValueSlider3/Text"):GetComponent(Text).color = Color(232/255, 250/255, 255/255)
    gameObject.transform:FindChild("ValueSlider4/Text"):GetComponent(Text).color = Color(232/255, 250/255, 255/255)
    gameObject.transform:FindChild("ValueSlider5/Text"):GetComponent(Text).color = Color(232/255, 250/255, 255/255)

    -- Tween.Instance:Cancel(self.slider1_tweenId)
    -- Tween.Instance:Cancel(self.slider2_tweenId)
    -- Tween.Instance:Cancel(self.slider3_tweenId)
    -- Tween.Instance:Cancel(self.slider4_tweenId)
    -- Tween.Instance:Cancel(self.slider5_tweenId)

    -- local slider1 = gameObject.transform:FindChild("ValueSlider1/Slider"):GetComponent(Slider)
    -- local fun1 = function(value) slider1.value = value end
    -- self.slider1_tweenId = Tween.Instance:ValueChange(slider1.value, ((petData.phy_aptitude - petData.base.phy_aptitude * 0.8) / (petData.max_phy_aptitude - petData.base.phy_aptitude * 0.8) * 0.8 + 0.2), 0.3, nil, LeanTweenType.linear, fun1).id

    -- local slider2 = gameObject.transform:FindChild("ValueSlider2/Slider"):GetComponent(Slider)
    -- local fun2 = function(value) slider2.value = value end
    -- self.slider2_tweenId = Tween.Instance:ValueChange(slider2.value, ((petData.pdef_aptitude - petData.base.pdef_aptitude * 0.8) / (petData.max_pdef_aptitude - petData.base.pdef_aptitude * 0.8) * 0.8 + 0.2), 0.3, nil, LeanTweenType.linear, fun2).id

    -- local slider3 = gameObject.transform:FindChild("ValueSlider3/Slider"):GetComponent(Slider)
    -- local fun3 = function(value) slider3.value = value end
    -- self.slider3_tweenId = Tween.Instance:ValueChange(slider3.value, ((petData.hp_aptitude - petData.base.hp_aptitude * 0.8) / (petData.max_hp_aptitude - petData.base.hp_aptitude * 0.8) * 0.8 + 0.2), 0.3, nil, LeanTweenType.linear, fun3).id

    -- local slider4 = gameObject.transform:FindChild("ValueSlider4/Slider"):GetComponent(Slider)
    -- local fun4 = function(value) slider4.value = value end
    -- self.slider4_tweenId = Tween.Instance:ValueChange(slider4.value, ((petData.magic_aptitude - petData.base.magic_aptitude * 0.8) / (petData.max_magic_aptitude - petData.base.magic_aptitude * 0.8) * 0.8 + 0.2), 0.3, nil, LeanTweenType.linear, fun4).id

    -- local slider5 = gameObject.transform:FindChild("ValueSlider5/Slider"):GetComponent(Slider)
    -- local fun5 = function(value) slider5.value = value end
    -- self.slider5_tweenId = Tween.Instance:ValueChange(slider5.value, ((petData.aspd_aptitude - petData.base.aspd_aptitude * 0.8) / (petData.max_aspd_aptitude- petData.base.aspd_aptitude * 0.8) * 0.8 + 0.2), 0.3, nil, LeanTweenType.linear, fun5).id

    gameObject.transform:FindChild("ValueSlider1/Slider"):GetComponent(Slider).value = ((petData.phy_aptitude - petData.base.phy_aptitude * 0.8) / (petData.max_phy_aptitude - petData.base.phy_aptitude * 0.8 + 0.0001) * 0.8 + 0.2)
    gameObject.transform:FindChild("ValueSlider2/Slider"):GetComponent(Slider).value = ((petData.pdef_aptitude - petData.base.pdef_aptitude * 0.8) / (petData.max_pdef_aptitude - petData.base.pdef_aptitude * 0.8 + 0.0001) * 0.8 + 0.2)
    gameObject.transform:FindChild("ValueSlider3/Slider"):GetComponent(Slider).value = ((petData.hp_aptitude - petData.base.hp_aptitude * 0.8) / (petData.max_hp_aptitude - petData.base.hp_aptitude * 0.8 + 0.0001) * 0.8 + 0.2)
    gameObject.transform:FindChild("ValueSlider4/Slider"):GetComponent(Slider).value = ((petData.magic_aptitude - petData.base.magic_aptitude * 0.8) / (petData.max_magic_aptitude - petData.base.magic_aptitude * 0.8 + 0.0001) * 0.8 + 0.2)
    gameObject.transform:FindChild("ValueSlider5/Slider"):GetComponent(Slider).value = ((petData.aspd_aptitude - petData.base.aspd_aptitude * 0.8) / (petData.max_aspd_aptitude- petData.base.aspd_aptitude * 0.8 + 0.0001) * 0.8 + 0.2)

    gameObject.transform:FindChild("GifeText"):GetComponent(Text).text = string.format("%s(%s)", self.model:gettalentclass(petData.talent), petData.talent)
    gameObject.transform:FindChild("GrowthImage"):GetComponent(Image).sprite
        = self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("PetGrowth%s", petData.growth_type))
end

function PetQuickShowView:update_skill()
    local petData = self.model.quickshow_petdata
    local skills = self.model:makeBreakSkill(petData.base.id, petData.skills)

    for i=1,#skills do
        local skilldata = skills[i]
        local icon = self.skillicon_list[i]
        local data = DataSkill.data_petSkill[string.format("%s_1", skilldata.id)]
        icon:SetAll(Skilltype.petskill, data)
        icon:ShowState(skilldata.source == 2)
        icon:ShowLabel(skilldata.source == 4 or skilldata.isBreak, TI18N("<color='#ffff00'>突破</color>"))
        icon:ShowBreak(skilldata.isBreak, TI18N("<color='#FF0000'>未激活</color>"))
    end

    for i=#skills+1,#self.skillicon_list do
        local icon = self.skillicon_list[i]
        icon:SetAll(Skilltype.petskill, nil)
        icon:ShowState(false)
    end
end

function PetQuickShowView:update_rideskill()
    local rideData = self.model.quickshow_petdata
    local list = rideData.mount_skills or {}
    table.sort(list, function(a,b) return a.skill_index < b.skill_index end)

    local skill_num = #list
    if skill_num < 4 then
        skill_num = 4
    end
    for i = 1, skill_num do
        local v = list[i]
        self.skillItemList[i]:SetData(v)
        self.skillItemList[i].gameObject.transform:FindChild("Name").gameObject:SetActive(false)
    end

    for i = skill_num + 1, #self.skillItemList do
        self.skillItemList[i].gameObject:SetActive(false)
    end

    self.skillContainerRect.sizeDelta = Vector2(75 * skill_num, 100)
end

function PetQuickShowView:update_rune()
    local petData = self.model.quickshow_petdata
    local runedata = petData.pet_rune
    -- BaseUtils.dump(runedata,"快速展示宠物内丹数据")

    for _, v in ipairs(runedata) do
        if v.rune_type == 1 then 
            self:SetRuneItemData(self.rune_list[v.rune_index], v)
        elseif v.rune_type == 2 then 
            self:SetRuneItemData(self.smart_rune, v)
        end
    end
end

function PetQuickShowView:onClickStoneShowWashPanel(slotItemData)
    -- BaseUtils.dump(slot,"PetQuickShowView:onClickStoneShowWashPanel(slot)===========")
    self.model:OpenPetStoneWashPanel(true,slotItemData,false)
end

function PetQuickShowView:PlayAction()
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

function PetQuickShowView:PlayIdleAction()
    if self.timeId_PlayAction == nil and self.previewComposite ~= nil and self.previewComposite.tpose ~= nil and self.model.quickshow_petdata ~= nil then
        local petData = self.model.quickshow_petdata

        local animationData = DataAnimation.data_npc_data[petData.base.animation_id]
        self.previewComposite.tpose:GetComponent(Animator):Play(string.format("Idle%s", animationData.idle_id))
    end
end

function PetQuickShowView:onHandBookButtonClick()
    -- self.handBookPanel:SetActive(true)
    -- local attrs = self.model:GetHandBookAttr(self.model.quickshow_petdata)
    -- local str1 = ""
    -- local str2 = ""
    -- local str3 = ""
    -- local str4 = ""
    -- local index = 0
    -- local mark = true

    -- for _, data in ipairs(attrs) do
    --     local key = data.key
    --     local value = data.value
    --     local attr_name = KvData.attr_name[key]
    --     if attr_name ~= nil then
    --         local color = "#23e3eb"
    --         if KvData.prop_percent[key] ~= nil then
    --             color = "#c179df"

    --             if mark then
    --                 mark = false
    --                 mark_index = index
    --                 str1 = string.format("%s\n", str1)
    --                 str2 = string.format("%s\n", str2)
    --                 str3 = string.format("%s\n", str3)
    --                 str4 = string.format("%s\n", str4)
    --                 if index % 2 == 1 then
    --                     str3 = string.format("%s\n", str3)
    --                     str4 = string.format("%s\n", str4)
    --                     index = index + 1
    --                 end
    --                 index = index + 2
    --             end
    --         end

    --         if index % 2 == 0 then
    --             if KvData.prop_percent[key] == nil then
    --                 str1 = string.format("%s\n<color='%s'>%s</color>", str1, color, attr_name)
    --                 str2 = string.format("%s\n<color='%s'>+%s</color>", str2, color, value)
    --             else
    --                 str1 = string.format("%s\n<color='%s'>%s</color>", str1, color, attr_name)
    --                 str2 = string.format("%s\n<color='%s'>+%s%%</color>", str2, color, value)
    --             end
    --         else
    --             if KvData.prop_percent[key] == nil then
    --                 str3 = string.format("%s\n<color='%s'>%s</color>", str3, color, attr_name)
    --                 str4 = string.format("%s\n<color='%s'>+%s</color>", str4, color, value)
    --             else
    --                 str3 = string.format("%s\n<color='%s'>%s</color>", str3, color, attr_name)
    --                 str4 = string.format("%s\n<color='%s'>+%s%%</color>", str4, color, value)
    --             end
    --         end
    --         index = index + 1
    --     end
    -- end

    -- self.handBookPanel.transform:FindChild("Main/I18NText1"):GetComponent(Text).text = str1
    -- self.handBookPanel.transform:FindChild("Main/NumText1"):GetComponent(Text).text = str2
    -- self.handBookPanel.transform:FindChild("Main/I18NText2"):GetComponent(Text).text = str3
    -- self.handBookPanel.transform:FindChild("Main/NumText2"):GetComponent(Text).text = str4

    -- self.handBookPanel.transform:FindChild("Main/StarText"):GetComponent(Text).text = string.format(TI18N("已使用兽王丹:<color='#8de92a'>%s/20</color>"), self.model.quickshow_petdata.feed_point)

    -- local rect = self.handBookPanel.transform:FindChild("Main"):GetComponent(RectTransform)
    -- local width = rect.sizeDelta.x
    -- local line1 = self.handBookPanel.transform:FindChild("Main/Line1")
    -- local line2 = self.handBookPanel.transform:FindChild("Main/Line2")
    -- if index == 0 then
    --     self.handBookPanel.transform:FindChild("Main/NoItemTips").gameObject:SetActive(true)

    --     self.handBookPanel.transform:FindChild("Main/StarText").gameObject:SetActive(false)
    --     rect.sizeDelta = Vector2(width, 180)
    --     line1.gameObject:SetActive(false)
    --     line2.gameObject:SetActive(false)
    -- else
    --     self.handBookPanel.transform:FindChild("Main/NoItemTips").gameObject:SetActive(false)

    --     local preferredHeight = self.handBookPanel.transform:FindChild("Main/I18NText1"):GetComponent(Text).preferredHeight
    --     -- self.handBookPanel.transform:FindChild("Main/StarText").localPosition = Vector2(0, preferredHeight - 130)
    --     self.handBookPanel.transform:FindChild("Main/StarText").localPosition = Vector2(0, - preferredHeight - 94)
    --     local hight = 120 + preferredHeight
    --     rect.sizeDelta = Vector2(width, hight)

    --     line1.gameObject:SetActive(true)
    --     line2.gameObject:SetActive(false)
    --     if mark then
    --         line1.localPosition = Vector2(0, -94 - math.floor(index/2) * 16)
    --     else
    --         line1.localPosition = Vector2(0, -94 - math.floor(mark_index/2) * 16)
    --     end
    -- end

    if self.model.quickshow_petdata.handbook_attr == nil then
        return
    end

    self.handBookPanel:SetActive(true)
    local attrs = self.model:GetHandBookAttr(self.model.quickshow_petdata)
    self.handBookPanel.transform:FindChild("Main/NumText1"):GetComponent(Text).text = string.format("+%s", attrs[4])
    self.handBookPanel.transform:FindChild("Main/NumText2"):GetComponent(Text).text = string.format("+%s", attrs[6])
    self.handBookPanel.transform:FindChild("Main/NumText3"):GetComponent(Text).text = string.format("+%s", attrs[5])
    self.handBookPanel.transform:FindChild("Main/NumText4"):GetComponent(Text).text = string.format("+%s", attrs[7])
    self.handBookPanel.transform:FindChild("Main/NumText5"):GetComponent(Text).text = string.format("+%s", attrs[1])
    self.handBookPanel.transform:FindChild("Main/NumText6"):GetComponent(Text).text = string.format("+%s", attrs[3])
    self.handBookPanel.transform:FindChild("Main/NumText7"):GetComponent(Text).text = string.format("+%s%%", attrs[54]/10)
    self.handBookPanel.transform:FindChild("Main/NumText8"):GetComponent(Text).text = string.format("+%s%%", attrs[51]/10)
    self.handBookPanel.transform:FindChild("Main/NumText9"):GetComponent(Text).text = string.format("+%s%%", attrs[55]/10)
    self.handBookPanel.transform:FindChild("Main/Line1").gameObject:SetActive(true)
    self.handBookPanel.transform:FindChild("Main/Line2").gameObject:SetActive(true)
    local handbookNumByActiveEffectType = HandbookManager.Instance:GetHandbookNumByActiveEffectType(1)
    local handbookNumByStarEffectType = HandbookManager.Instance:GetHandbookNumByStarEffectType(1)
    self.handBookPanel.transform:FindChild("Main/StarText"):GetComponent(Text).text =
            string.format(TI18N("宠物图鉴已激活：<color='#ffff00'>%s</color>/%s\n1★图鉴已激活：<color='#ffff00'>%s</color>/%s\n已使用兽王丹:<color='#ffff00'>%s</color>/20")
                , self.model.quickshow_petdata.handbook_num, handbookNumByActiveEffectType, self.model.quickshow_petdata.star_handbook_num, handbookNumByStarEffectType, self.model.quickshow_petdata.feed_point)
end

function PetQuickShowView:hideHandBookPanel()
    self.handBookPanel:SetActive(false)
end

function PetQuickShowView:onSpritButtonClick()
    if self.model.quickshow_petdata == nil then
        return
    end
    self.spritPanel:SetActive(true)

    local petData = self.model.quickshow_petdata
    local spritPetData = petData.spirit_info[1]
    local spritPetBaseData = DataPet.data_pet[spritPetData.spirit_base_id]

    if self.headLoader == nil then
        self.headLoader = SingleIconLoader.New(self.spritPanel.transform:FindChild("Main/MainPetHead/Head"):GetComponent(Image).gameObject)
    end
    self.headLoader:SetSprite(SingleIconType.Pet, petData.base.head_id)



    if self.headLoader2 == nil then
        self.headLoader2 = SingleIconLoader.New(self.spritPanel.transform:FindChild("Main/Head_78/Head"):GetComponent(Image).gameObject)
    end
    self.headLoader2:SetSprite(SingleIconType.Pet,spritPetBaseData.head_id)

    -- self.spritPanel.transform:FindChild("Main/MainPetHead/Head"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(petData.base.head_id), petData.base.head_id)
    -- self.spritPanel.transform:FindChild("Main/Head_78/Head"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(spritPetBaseData.head_id), spritPetBaseData.head_id)
    self.spritPanel.transform:FindChild("Main/MainPetLevel/Text"):GetComponent(Text).text = tostring(petData.lev)
    self.spritPanel.transform:FindChild("Main/SpirtPetLevel/Text"):GetComponent(Text).text = tostring(spritPetData.spirit_lev)

    local data_pet_spirt_score = self.model:GetPetSpirtScoreByTalent(spritPetData.spirit_base_id, spritPetData.spirit_talent)
    local data_pet_spirt_attr = DataPet.data_pet_spirt_attr[spritPetData.spirit_lev]
    local attr_ratio = data_pet_spirt_score.attr_ratio

    local attr_list = {}
    table.insert(attr_list, { key = 1, value = BaseUtils.Round(data_pet_spirt_attr.hp_max * attr_ratio / 1000) } )
    -- table.insert(attr_list, { key = 2, value = BaseUtils.Round(data_pet_spirt_attr.mp_max * attr_ratio / 1000) } )
    table.insert(attr_list, { key = 4, value = BaseUtils.Round(data_pet_spirt_attr.phy_dmg * attr_ratio / 1000) } )
    table.insert(attr_list, { key = 5, value = BaseUtils.Round(data_pet_spirt_attr.magic_dmg * attr_ratio / 1000) } )
    table.insert(attr_list, { key = 6, value = BaseUtils.Round(data_pet_spirt_attr.phy_def * attr_ratio / 1000) } )
    table.insert(attr_list, { key = 7, value = BaseUtils.Round(data_pet_spirt_attr.magic_def * attr_ratio / 1000) } )
    -- table.insert(attr_list, { key = 3, value = BaseUtils.Round(data_pet_spirt_attr.atk_speed * attr_ratio / 1000) } )

    for i=1, #attr_list do
        self.spritPanel.transform:FindChild(string.format("Main/AttrPanel/AttrObject%s/NameText", i)):GetComponent(Text).text = string.format("%s:", KvData.GetAttrName(attr_list[i].key))
        self.spritPanel.transform:FindChild(string.format("Main/AttrPanel/AttrObject%s/ValueText", i)):GetComponent(Text).text = string.format("+%s", math.ceil(attr_list[i].value))
        self.spritPanel.transform:FindChild(string.format("Main/AttrPanel/AttrObject%s/Icon", i)):GetComponent(Image).sprite
            = self.assetWrapper:GetSprite(AssetConfig.attr_icon, string.format("AttrIcon%s", tostring(KvData.attr_icon[attr_list[i].key])))
    end
    self.spritPanel.transform:FindChild("Main/AttrPanel/AttrObject6").gameObject:SetActive(false)



    local activeSkillMark = true
    if data_pet_spirt_score == nil or #data_pet_spirt_score.skills == 0 then
        data_pet_spirt_score = self.model:GetPetSpirtScoreBySkillLevel(petData.spirit_base_id, 0)
        activeSkillMark = false
    end
    local skillData = DataSkill.data_petSkill[string.format("%s_%s", data_pet_spirt_score.skills[1][1], data_pet_spirt_score.skills[1][2])]

    self.spritPanel.transform:FindChild("Main/SkillPanel/Text1"):GetComponent(Text).text = string.format("<color='#ffff00'>%s</color>", skillData.name)
    self.spritPanel.transform:FindChild("Main/SkillPanel/Text2"):GetComponent(Text).text = skillData.desc
    if activeSkillMark then
        local next_data_pet_spirt_score = self.model:GetPetSpirtScoreBySkillLevel(petData.base_id, data_pet_spirt_score.skill_lev)

        self.spritPanel.transform:FindChild("Main/SkillPanel/Text3"):GetComponent(Text).text = ""--TI18N("<color='#00ff00'>技能已激活</color>")

        self.skillSlot:SetAll(Skilltype.petskill, skillData)
        self.skillSlot:SetGrey(false)
    else
        self.spritPanel.transform:FindChild("Main/SkillPanel/Text3"):GetComponent(Text).text = ""--TI18N("<color='#ff0000'>技能未激活</color>")

        self.skillSlot:SetAll(Skilltype.petskill, skillData)
        self.skillSlot:SetGrey(true)
    end
end

function PetQuickShowView:hideSpritPanel()
    self.spritPanel:SetActive(false)
end

function PetQuickShowView:ChangeTab(index)
    if index == 1 then 
        self.skillPanelObj:SetActive(true)
        self.rideSkillPanelObj:SetActive(true)
        self.runePanel.gameObject:SetActive(false)
    elseif index == 2 then 
        self.skillPanelObj:SetActive(false)
        self.rideSkillPanelObj:SetActive(false)
        self.runePanel.gameObject:SetActive(true)
    end
end

function PetQuickShowView:CreateRuneItem(transform)
    local item = {}
    item["trans"] = transform 
    item["btn"] = transform:Find("BgImg"):GetComponent(Button)
    item["iconImg"] = transform:Find("BgImg/IconImg")
    item["iconloader"] = SingleIconLoader.New(item.iconImg.gameObject)
    item["abledImg"] = transform:Find("BgImg/AbledImg")
    item["lockImg"] = transform:Find("BgImg/LockImg")
    item["txt"] = transform:Find("TxtBg/Text"):GetComponent(Text)
    item["upgrade"] = transform:Find("BgImg/Upgrade").gameObject

    item["effect"] = BaseUtils.ShowEffect(20522, item.iconImg, Vector3.one, Vector3(0, 0, -400), nil, nil, function() BaseUtils.TposeEffectScale(item.effect, 0.15) end)
    item.effect:SetActive(false)

    item["effect2"] = BaseUtils.ShowEffect(20523, item.iconImg:Find("Effect"), Vector3(0.5,0.5,0.5), Vector3(0, 0, -400))
    item.effect2:SetActive(false)



    item.lockImg.gameObject:SetActive(true)
    item.abledImg.gameObject:SetActive(false)
    item.iconImg.gameObject:SetActive(false)
    item.upgrade:SetActive(false)
    
    item.btn.onClick:AddListener(function() NoticeManager.Instance:FloatTipsByString(self.noticeString) end)
    return item
end

function PetQuickShowView:SetRuneItemData(item,data)
    item.lockImg.gameObject:SetActive(data.rune_status == 0)
    item.abledImg.gameObject:SetActive(data.rune_status == 1)
    
    local txtString = TI18N("未开启")
    local fun = function() end
    if data.rune_status == 1 or data.rune_status == 2 or data.rune_status == 3 then 
        local key = BaseUtils.Key(data.rune_id, data.rune_lev)
        local rune_data = DataRune.data_rune[key]
        txtString = string.format("%s·%s", rune_data.name, rune_data.lev)
        item.lockImg.gameObject:SetActive(false)
        item.abledImg.gameObject:SetActive(false)
        item.iconImg.gameObject:SetActive(true)
        item.iconloader:SetSprite(SingleIconType.SkillIcon, DataSkill.data_petSkill[BaseUtils.Key(rune_data.skill_id, "1")].icon)
        fun =  function(id) TipsManager.Instance:ShowRuneTips({itemData = data, gameObject = item.trans.gameObject, extra = {nobutton = true}}) end
    else
        item.lockImg.gameObject:SetActive(true)
        item.abledImg.gameObject:SetActive(false)
        item.iconImg.gameObject:SetActive(false)
    end
    item.txt.text = txtString

    BaseUtils.TposeEffectScale(item.effect, 0.15)  --这里再设置一次
    item.effect:SetActive(data.is_resonance == 1)
    item.effect2:SetActive(data.is_resonance == 1)

    item.btn.onClick:RemoveAllListeners()
    item.btn.onClick:AddListener(fun)
end 