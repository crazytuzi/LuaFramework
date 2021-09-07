-- ----------------------------------------------------------
-- UI - 孩子查看窗口
-- ----------------------------------------------------------
ChildQuickShowView = ChildQuickShowView or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function ChildQuickShowView:__init(model)
    self.model = model
    self.name = "ChildQuickShowView"
    self.windowId = WindowConfig.WinID.childquickshow
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Destroy

    self.resList = {
        {file = AssetConfig.childquickshow, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
        ,{file  = AssetConfig.wingsbookbg, type  =  AssetType.Dep}
        , {file = AssetConfig.childtelenticon, type = AssetType.Dep}
        ,{file = AssetConfig.childhead,type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

	------------------------------------------------
    self.skillicon_list = {}
    self.stone_list = {}
    self.itemSlot_list = {}
    self.model_preview = nil
    self.skillItemList = {}
    self.telnetItemList = {}

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

function ChildQuickShowView:__delete()
    self:OnHide()

    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end

    for i,v in ipairs(self.skillicon_list) do
        v:DeleteMe()
    end
    self.skillicon_list = nil

    for i,v in ipairs(self.itemSlot_list) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    self.itemSlot_list = nil

    for i,v in ipairs(self.skillItemList) do
        v:DeleteMe()
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function ChildQuickShowView:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.childquickshow))
    self.gameObject.name = "ChildQuickShowView"
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
    for i=1, 15 do
        local slot = SkillSlot.New()
        UIUtils.AddUIChild(soltPanel, slot.gameObject)
        table.insert(self.skillicon_list, slot)
    end

    local container = self.transform:Find("Main/TelentPanel")
    container.transform.localPosition = Vector2(178, -180)
    -- local len = container.childCount
    local len = 4
    for i = 1, len do
        local index = i
        local item = PetChildTelnetItem.New(container:Find("Item" .. i).gameObject, self, index)
        item.showTips = true
        item.quickShowMark = true
        table.insert(self.telnetItemList, item)
    end

    self.transform:FindChild("Main/ModlePanel/Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.preview = self.transform:FindChild("Main/ModlePanel/Preview")

    local btn = self.transform:FindChild("Main/ModlePanel/Preview").gameObject:AddComponent(Button)
    btn.onClick:AddListener(function() self:PlayAction() end)

    btn = self.transform:FindChild("Main/HandBookButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:onHandBookButtonClick() end)
    btn.gameObject:SetActive(true)
    self.handbookBtnObj = btn.gameObject

    self.handBookPanel = self.transform:FindChild("Main/HandBookPanel").gameObject
    self.handBookPanel:GetComponent(Button).onClick:AddListener(function() self:hideHandBookPanel() end)

    self.transform:FindChild("Main/Title/Text"):GetComponent(Text).text = "查看子女"
    self.transform:FindChild("Main/WashPanel/I18N_Text"):GetComponent(Text).text = "评分:"

    self.spritPanel = self.transform:FindChild("Main/SpritPanel").gameObject
    self.spritPanel:GetComponent(Button).onClick:AddListener(function() self:hideSpritPanel() end)

    btn = self.transform:FindChild("Main/SpritButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:onSpritButtonClick() end)
    btn.gameObject:SetActive(true)
    self.spritBtnObj = btn.gameObject

    self.skillSlot = SkillSlot.New()
    UIUtils.AddUIChild(self.spritPanel.transform:FindChild("Main/SkillPanel/SkillIcon").gameObject, self.skillSlot.gameObject)
        ----------------------------
    LuaTimer.Add(10, function() self:OnShow() self:ClearMainAsset() end)
end

function ChildQuickShowView:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function ChildQuickShowView:hideSpritPanel()
    self.spritPanel:SetActive(false)
end
function ChildQuickShowView:OnShow()
	self:update()
end

function ChildQuickShowView:OnHide()
    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end

    if self.timeId_PlayIdleAction ~= nil then LuaTimer.Delete(self.timeId_PlayIdleAction) end
    if self.timeId_PlayAction ~= nil then LuaTimer.Delete(self.timeId_PlayAction) end
end

function ChildQuickShowView:update()
    if ChildrenManager.Instance.quickShowChildData == nil then return end

    self:update_model()
    self:update_base()
    self:update_stone()
    self:update_baseattrs()
    self:update_qualityattrs()
    self:update_skill()
    self:update_telent()

    if ChildrenManager.Instance.quickShowChildData.spirit_info ~= nil and #ChildrenManager.Instance.quickShowChildData.spirit_info > 0 then
        self.handbookBtnObj.transform.localPosition = Vector2(-196.1, 147.5)
        self.spritBtnObj:SetActive(true)
    else
        self.handbookBtnObj.transform.localPosition = Vector2(-156, 147.5)
        self.spritBtnObj:SetActive(false)
    end
end

function ChildQuickShowView:update_model()
    local petData = ChildrenManager.Instance.quickShowChildData
    local pet = DataChild.data_child[petData.base_id]
    local modelData = nil
    if pet ~= nil then
        local skinId = 0
        local modelId = 0
        if petData.grade == 0 then
            skinId = pet.skin_id_0
            modelId = pet.model_id
        elseif petData.grade == 1 then
            skinId = pet.skin_id_1
            modelId = pet.model_id1
        elseif petData.grade == 2 then
            skinId = pet.skin_id_2
            modelId = pet.model_id2
        elseif petData.grade == 3 then
            skinId = pet.skin_id_3
            modelId = pet.model_id3
        end

        local animationId = pet.animation_id
        local effects = pet.effects_0

        local child_skin_info = petData.child_skin or {}
        local skinid = 0
        for k,v in ipairs(child_skin_info) do
            if v.skin_active_flag == 2 then
                skinid = v.skin_id
                break
            end
        end
        local data_child_skin = DataChild.data_child_skin[skinid]
        if data_child_skin ~= nil then
            skinId = data_child_skin.texture
            modelId = data_child_skin.model_id
            animationId = data_child_skin.animation_id
        end

        modelData = {type = PreViewType.Pet, skinId = skinId, modelId = modelId, animationId = animationId, effects = effects, scale = 1.5}
    end

    if modelData == nil then
        return
    end

    local setting = {
        name = "ChildView"
        ,orthographicSize = 0.9
        ,width = 341
        ,height = 341
        ,offsetY = -0.35
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
    self.previewComposite = PreviewComposite.New(fun, setting, modelData)
    self.previewComposite:BuildCamera(true)
end

function ChildQuickShowView:update_base()
    local petData = ChildrenManager.Instance.quickShowChildData
    local gameObject = self.transform:FindChild("Main/ModlePanel").gameObject

    gameObject.transform:FindChild("NameText"):GetComponent(Text).text = petData.name
    gameObject.transform:FindChild("LevelText"):GetComponent(Text).text = string.format("Lv.%s", petData.lev)
    if petData.genre == 0 or petData.genre == 1 or petData.genre == 3 then
        gameObject.transform:FindChild("GenreImage"):GetComponent(Image).sprite
            = self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("I18N_Genre%s", (petData.genre+1)))
        gameObject.transform:FindChild("GenreImage").gameObject:SetActive(true)
    else
        gameObject.transform:FindChild("GenreImage").gameObject:SetActive(false)
    end

    if ChildrenManager.Instance.quickShowChildData.handbook_attr == nil then
        self.handbookBtnObj:SetActive(false)
    else
        self.handbookBtnObj:SetActive(true)
    end
end

function ChildQuickShowView:update_stone()
    local petData = ChildrenManager.Instance.quickShowChildData
    local baseData = DataChild.data_child[petData.base_id]
    local gameObject = self.transform:FindChild("Main/EquipPanel").gameObject
    local stone_hole = 3

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

function ChildQuickShowView:update_baseattrs()
    local petData = ChildrenManager.Instance.quickShowChildData

    local gameObject = self.transform:FindChild("Main/AttrPanel").gameObject
    gameObject.transform:FindChild("AttrObject1/ValueText"):GetComponent(Text).text = string.format("%s/%s", petData.hp, petData.hp)
    gameObject.transform:FindChild("AttrObject2/ValueText"):GetComponent(Text).text = string.format("%s/%s", petData.mp, petData.mp)
    gameObject.transform:FindChild("AttrObject3/ValueText"):GetComponent(Text).text = tostring(petData.phy_dmg)
    gameObject.transform:FindChild("AttrObject4/ValueText"):GetComponent(Text).text = tostring(petData.magic_dmg)
    gameObject.transform:FindChild("AttrObject5/ValueText"):GetComponent(Text).text = tostring(petData.phy_def)
    gameObject.transform:FindChild("AttrObject6/ValueText"):GetComponent(Text).text = tostring(petData.magic_def)
    gameObject.transform:FindChild("AttrObject7/ValueText"):GetComponent(Text).text = tostring(petData.atk_speed)
end

function ChildQuickShowView:update_qualityattrs()
    local petData = ChildrenManager.Instance.quickShowChildData
    local gameObject = self.transform:FindChild("Main/WashPanel").gameObject
    gameObject.transform:FindChild("ValueSlider1/Text"):GetComponent(Text).text = string.format("%s/%s", petData.phy_aptitude, petData.max_phy_aptitude)
    gameObject.transform:FindChild("ValueSlider2/Text"):GetComponent(Text).text = string.format("%s/%s", petData.pdef_aptitude, petData.max_pdef_aptitude)
    gameObject.transform:FindChild("ValueSlider3/Text"):GetComponent(Text).text = string.format("%s/%s", petData.hp_aptitude, petData.max_hp_aptitude)
    gameObject.transform:FindChild("ValueSlider4/Text"):GetComponent(Text).text = string.format("%s/%s", petData.magic_aptitude, petData.max_magic_aptitude)
    gameObject.transform:FindChild("ValueSlider5/Text"):GetComponent(Text).text = string.format("%s/%s", petData.aspd_aptitude, petData.max_aspd_aptitude)

    gameObject.transform:FindChild("ValueSlider1/Slider"):GetComponent(Slider).value = petData.phy_aptitude / petData.max_phy_aptitude
    gameObject.transform:FindChild("ValueSlider2/Slider"):GetComponent(Slider).value = petData.pdef_aptitude / petData.max_pdef_aptitude
    gameObject.transform:FindChild("ValueSlider3/Slider"):GetComponent(Slider).value = petData.hp_aptitude / petData.max_hp_aptitude
    gameObject.transform:FindChild("ValueSlider4/Slider"):GetComponent(Slider).value = petData.magic_aptitude / petData.max_magic_aptitude
    gameObject.transform:FindChild("ValueSlider5/Slider"):GetComponent(Slider).value = petData.aspd_aptitude / petData.max_aspd_aptitude

    -- gameObject.transform:FindChild("GifeText"):GetComponent(Text).text = string.format("%.2f", petData.growth / 500)
    gameObject.transform:FindChild("GifeText"):GetComponent(Text).text = string.format("%s(%s)", PetManager.Instance.model:gettalentclass(petData.talent), petData.talent)
    gameObject.transform:FindChild("GrowthImage"):GetComponent(Image).sprite
        = self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("PetGrowth%s", petData.growth_type))
end

function ChildQuickShowView:update_skill()
    local petData = ChildrenManager.Instance.quickShowChildData

    local count = 0

    local baseData = DataChild.data_child[petData.base_id]
    for i,v in ipairs(baseData.classes_skills) do
        count = count + 1
        local slot = self.skillicon_list[count]
        local skillData = DataSkill.data_child_skill[v[1]]
        slot:SetAll(Skilltype.childskill, skillData, {classes = petData.classes})
        slot.gameObject:SetActive(true)
        if petData.grade >= v[2] then
            slot:ShowOnOpen(false)
        else
            slot:ShowOnOpen(true, TI18N("<color='#ffff00'>进阶\n开放</color>"))
        end
    end

    for i,v in ipairs(petData.skills) do
        if v.source ~= 2 then
            count = count + 1
            local slot = self.skillicon_list[count]
            local skillData = DataSkill.data_child_skill[v.id]
            slot:SetAll(Skilltype.petskill, skillData)
            slot.gameObject:SetActive(true)

            if v.source == 3 then
                slot:ShowChildState(true)
            else
                slot:ShowChildState(false)
            end
        end
    end

    -- for i,v in ipairs(petData.talent_skills) do
    --     count = count + 1
    --     local slot = self.skillicon_list[count]
    --     local skillData = DataSkill.data_child_telent[v.id]
    --     slot:SetAll(Skilltype.childtelent, skillData)
    --     slot.gameObject:SetActive(true)
    -- end

    count = count + 1
    for i = count , 15 do
        -- self.skillicon_list[i].gameObject:SetActive(false)
        local slot = self.skillicon_list[i]
        slot:SetAll(Skilltype.petskill, nil)
    end
end

function ChildQuickShowView:update_telent()
    local petData = ChildrenManager.Instance.quickShowChildData

    local grade = petData.grade + 1
    for i,item in ipairs(self.telnetItemList) do
        if i > grade then
            item:Lock(true)
        else
            local telent = petData.talent_skills[i]
            if telent.id == 0 then
                item:Lock(true)
            else
                item:Lock(false)
                item:SetData(telent)
            end
        end
    end
end

function ChildQuickShowView:PlayAction()
    -- if self.timeId_PlayAction == nil and self.previewComposite ~= nil and self.previewComposite.tpose ~= nil and ChildrenManager.Instance.quickShowChildData ~= nil then
    --     local petData = ChildrenManager.Instance.quickShowChildData
    --     local petModelData = self.model:getPetModel(petData)

    --     local animationData = DataAnimation.data_npc_data[petData.base.animation_id]
    --     local action_list = { "1000", "2000", string.format("Idle%s", animationData.idle_id) }
    --     self.actionIndex_PlayAction = self.actionIndex_PlayAction + math.random(1, 2)
    --     if self.actionIndex_PlayAction > #action_list then self.actionIndex_PlayAction = self.actionIndex_PlayAction - #action_list end
    --     local action_name = action_list[self.actionIndex_PlayAction]
    --     self.previewComposite.tpose:GetComponent(Animator):Play(action_name)

    --     local motion_event = DataMotionEvent.data_motion_event[string.format("%s_%s", action_name, petModelData.modelId)]
    --     if motion_event ~= nil then
    --         if action_name == "1000" then
    --             self.timeId_PlayAction = LuaTimer.Add(motion_event.total, function() self.timeId_PlayAction = nil if not BaseUtils.isnull(self.previewComposite.tpose) then self.previewComposite.tpose:GetComponent(Animator):Play(string.format("Stand%s", animationData.idle_id)) end end)
    --         elseif action_name == "2000" then
    --             self.timeId_PlayAction = LuaTimer.Add(motion_event.total, function() self.timeId_PlayAction = nil if not BaseUtils.isnull(self.previewComposite.tpose) then self.previewComposite.tpose:GetComponent(Animator):Play(string.format("Stand%s", animationData.idle_id)) end end)
    --         else
    --             self.timeId_PlayAction = LuaTimer.Add(motion_event.total, function() self.timeId_PlayAction = nil end)
    --         end
    --     end
    -- end
end

function ChildQuickShowView:PlayIdleAction()
    if self.timeId_PlayAction == nil and self.previewComposite ~= nil and self.previewComposite.tpose ~= nil and ChildrenManager.Instance.quickShowChildData ~= nil then
        local petData = ChildrenManager.Instance.quickShowChildData

        local petBaseData = DataChild.data_child[petData.base_id]
        local animationData = DataAnimation.data_npc_data[petBaseData.animation_id]
        self.previewComposite.tpose:GetComponent(Animator):Play(string.format("Idle%s", animationData.idle_id))
    end
end

function ChildQuickShowView:onHandBookButtonClick()
    -- self.handBookPanel:SetActive(true)
    -- local attrs = self.model:GetHandBookAttr(ChildrenManager.Instance.quickShowChildData)
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

    -- self.handBookPanel.transform:FindChild("Main/StarText"):GetComponent(Text).text = string.format(TI18N("已使用兽王丹:<color='#8de92a'>%s/20</color>"), ChildrenManager.Instance.quickShowChildData.feed_point)

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

    if ChildrenManager.Instance.quickShowChildData.handbook_attr == nil then
        return
    end

    self.handBookPanel:SetActive(true)
    local attrs = self.model:GetHandBookAttr(ChildrenManager.Instance.quickShowChildData)
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
                , ChildrenManager.Instance.quickShowChildData.handbook_num, handbookNumByActiveEffectType, ChildrenManager.Instance.quickShowChildData.star_handbook_num, handbookNumByStarEffectType, ChildrenManager.Instance.quickShowChildData.feed_point)
end

function ChildQuickShowView:hideHandBookPanel()
    self.handBookPanel:SetActive(false)
end

function ChildQuickShowView:onSpritButtonClick()
    self.spritPanel:SetActive(true)

    local childData = ChildrenManager.Instance.quickShowChildData
    local spritchildData = childData.spirit_info[1]
    local spritPetBaseData = DataPet.data_pet[spritchildData.spirit_base_id]

    if self.headLoader == nil then
        self.headLoader = SingleIconLoader.New(self.spritPanel.transform:FindChild("Main/MainPetHead/Head"):GetComponent(Image).gameObject)
    end
    self.headLoader:SetOtherSprite(self.assetWrapper:GetSprite(AssetConfig.childhead,string.format("%s%s", childData.classes_type, childData.sex)))



    if self.headLoader2 == nil then
        self.headLoader2 = SingleIconLoader.New(self.spritPanel.transform:FindChild("Main/Head_78/Head"):GetComponent(Image).gameObject)
    end
    self.headLoader2:SetSprite(SingleIconType.Pet,spritPetBaseData.head_id)

    -- self.spritPanel.transform:FindChild("Main/MainPetHead/Head"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(childData.base.head_id), childData.base.head_id)
    -- self.spritPanel.transform:FindChild("Main/Head_78/Head"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(spritPetBaseData.head_id), spritPetBaseData.head_id)
    self.spritPanel.transform:FindChild("Main/MainPetLevel/Text"):GetComponent(Text).text = tostring(childData.lev)
    self.spritPanel.transform:FindChild("Main/SpirtPetLevel/Text"):GetComponent(Text).text = tostring(spritchildData.spirit_lev)

    local data_child_spirt_score = PetManager.Instance.model:GetChildSpirtScoreByTalent(spritchildData.spirit_base_id, spritchildData.spirit_talent)
    local data_child_spirt_attr = DataPet.data_child_spirt_attr[spritchildData.spirit_lev]
    local attr_ratio = data_child_spirt_score.attr_ratio

    local attr_list = {}
    table.insert(attr_list, { key = 1, value = BaseUtils.Round(data_child_spirt_attr.hp_max * attr_ratio / 1000) } )
    -- table.insert(attr_list, { key = 2, value = BaseUtils.Round(data_child_spirt_attr.mp_max * attr_ratio / 1000) } )
    table.insert(attr_list, { key = 4, value = BaseUtils.Round(data_child_spirt_attr.phy_dmg * attr_ratio / 1000) } )
    table.insert(attr_list, { key = 5, value = BaseUtils.Round(data_child_spirt_attr.magic_dmg * attr_ratio / 1000) } )
    table.insert(attr_list, { key = 6, value = BaseUtils.Round(data_child_spirt_attr.phy_def * attr_ratio / 1000) } )
    table.insert(attr_list, { key = 7, value = BaseUtils.Round(data_child_spirt_attr.magic_def * attr_ratio / 1000) } )
    -- table.insert(attr_list, { key = 3, value = BaseUtils.Round(data_child_spirt_attr.atk_speed * attr_ratio / 1000) } )

    for i=1, #attr_list do
        self.spritPanel.transform:FindChild(string.format("Main/AttrPanel/AttrObject%s/NameText", i)):GetComponent(Text).text = string.format("%s:", KvData.GetAttrName(attr_list[i].key))
        self.spritPanel.transform:FindChild(string.format("Main/AttrPanel/AttrObject%s/ValueText", i)):GetComponent(Text).text = string.format("+%s", math.ceil(attr_list[i].value))
        self.spritPanel.transform:FindChild(string.format("Main/AttrPanel/AttrObject%s/Icon", i)):GetComponent(Image).sprite
            = self.assetWrapper:GetSprite(AssetConfig.attr_icon, string.format("AttrIcon%s", tostring(KvData.attr_icon[attr_list[i].key])))
    end
    self.spritPanel.transform:FindChild("Main/AttrPanel/AttrObject6").gameObject:SetActive(false)



    local activeSkillMark = true
    if data_child_spirt_score == nil or #data_child_spirt_score.skills == 0 then
        data_child_spirt_score = PetManager.Instance.model:GetChildSpirtScoreBySkillLevel(childData.spirit_base_id, 0)
        activeSkillMark = false
    end
    local skillData = DataSkill.data_petSkill[string.format("%s_%s", data_child_spirt_score.skills[1][1], data_child_spirt_score.skills[1][2])]

    self.spritPanel.transform:FindChild("Main/SkillPanel/Text1"):GetComponent(Text).text = string.format("<color='#ffff00'>%s</color>", skillData.name)
    self.spritPanel.transform:FindChild("Main/SkillPanel/Text2"):GetComponent(Text).text = skillData.desc
    if activeSkillMark then
        local next_data_child_spirt_score = PetManager.Instance.model:GetChildSpirtScoreBySkillLevel(childData.base_id, data_child_spirt_score.skill_lev)

        self.spritPanel.transform:FindChild("Main/SkillPanel/Text3"):GetComponent(Text).text = ""--TI18N("<color='#00ff00'>技能已激活</color>")

        self.skillSlot:SetAll(Skilltype.petskill, skillData)
        self.skillSlot:SetGrey(false)
    else
        self.spritPanel.transform:FindChild("Main/SkillPanel/Text3"):GetComponent(Text).text = ""--TI18N("<color='#ff0000'>技能未激活</color>")

        self.skillSlot:SetAll(Skilltype.petskill, skillData)
        self.skillSlot:SetGrey(true)
    end
end
