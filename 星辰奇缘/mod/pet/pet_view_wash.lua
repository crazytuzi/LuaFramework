-- ----------------------------------------------------------
-- UI - 宠物窗口 洗髓面板
-- ----------------------------------------------------------
PetView_Wash = PetView_Wash or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3
local Color = UnityEngine.Color

function PetView_Wash:__init(parent)
	self.parent = parent
    self.model = parent.model
    self.name = "PetView_Wash"
    self.resList = {
        {file = AssetConfig.pet_window_wash, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil
    self.init = false
    ------------------------------------------------
    self.watchItemSolt = nil
    self.watchItemSolt2 = nil
    self.watchItemToggle = nil
    self.soltPanel = nil
    self.watchbutton = nil
    self.watchbuttonscript = nil
    self.skillList = {}

    self.slider1_tweenId = 0
    self.slider2_tweenId = 0
    self.slider3_tweenId = 0
    self.slider4_tweenId = 0
    self.slider5_tweenId = 0

    ------------------------------------------------
    self._update_one = function(update) self:update_one(update) end
    self._update_item = function() self:update_item() end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.guideScript = nil
end

function PetView_Wash:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pet_window_wash))
    self.gameObject.name = "PetView_Wash"
    self.gameObject.transform:SetParent(self.parent.mainTransform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.transform = self.gameObject.transform
    self.transform:SetAsFirstSibling()

    self.transform:FindChild("QualityPanel/ValueSlider1/Text"):GetComponent(Text).color = Color(232/255, 250/255, 255/255)
    self.transform:FindChild("QualityPanel/ValueSlider2/Text"):GetComponent(Text).color = Color(232/255, 250/255, 255/255)
    self.transform:FindChild("QualityPanel/ValueSlider3/Text"):GetComponent(Text).color = Color(232/255, 250/255, 255/255)
    self.transform:FindChild("QualityPanel/ValueSlider4/Text"):GetComponent(Text).color = Color(232/255, 250/255, 255/255)
    self.transform:FindChild("QualityPanel/ValueSlider5/Text"):GetComponent(Text).color = Color(232/255, 250/255, 255/255)

    --------------------------------
    self.watchItemSolt = ItemSlot.New()
    UIUtils.AddUIChild(self.transform:FindChild("ItemSolt").gameObject, self.watchItemSolt.gameObject)

    self.watchItemSolt2 = ItemSlot.New()
    UIUtils.AddUIChild(self.transform:FindChild("ItemSolt2").gameObject, self.watchItemSolt2.gameObject)

    self.watchItemToggle = self.transform:FindChild("Toggle"):GetComponent(Toggle)
    self.watchItemToggle.isOn = false

    -- 按钮功能绑定
    local btn
    local watchbutton = self.transform:FindChild("WashButton").gameObject


    self.washNewBtn = self.transform:FindChild("WashBtn"):GetComponent(Button)
    self.washNewBtn.onClick:AddListener(function() self:towash() end)
    -- washNewBtn.gameObject:SetActive(false)
    -- watchbutton:SetActive(true)
    -- watchbutton:AddComponent(Button).onClick:AddListener(function() self:towash() end)
    self.watchbuttonscript = BuyButton.New(watchbutton, TI18N("洗 髓"), false)
    self.watchbuttonscript.key = "PetWash2"
    self.watchbuttonscript:Show()

    btn = self.transform:FindChild("DescButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:ondesc() end)

    btn = self.transform:FindChild("QualityPanel/Growthbg"):GetComponent(Button)
    btn.onClick:AddListener(function() self:showgiftimagetips() end)

    btn = self.transform:FindChild("QualityPanel/GrowthImage"):GetComponent(Button)
    btn.onClick:AddListener(function() self:showgiftimagetips() end)

    btn = self.transform:FindChild("QualityPanel/GrowthText"):GetComponent(Button)
    btn.onClick:AddListener(function() self:showgiftimagetips() end)

    btn = self.transform:FindChild("GiftTips"):GetComponent(Button)
    btn.onClick:AddListener(function() self:hidegiftimagetips() end)

    ------------------  宠物锁定  ---------------------
    btn = self.transform:FindChild("ModelPanel/LockBtn"):GetComponent(Button)
    btn.onClick:AddListener(function() self:lockpetbuttonclick() end)

    btn = self.transform:FindChild("LockPanel"):GetComponent(Button)
    btn.onClick:AddListener(function() self:hidelockpetpanel() end)

    btn = self.transform:FindChild("LockPanel/Main/OkButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:lockpet() end)

    btn = self.transform:FindChild("LockPanel/Main/CancelButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:hidelockpetpanel() end)

    btn = self.transform:FindChild("ModelPanel/Preview").gameObject:AddComponent(Button)
    btn.onClick:AddListener(function() self.parent:PlayAction() end)
    ------------------------------------------------------

    -- 初始化技能图标
    self.soltPanel = self.transform:FindChild("SkillPanel/Mask/SoltPanel").gameObject
    local textObject = self.transform:FindChild("SkillPanel/SkillText").gameObject
    for i=1, 15 do
        local slot = SkillSlot.New()
        UIUtils.AddUIChild(self.soltPanel, slot.gameObject)
        table.insert(self.skillList, slot)

        local text = GameObject.Instantiate(textObject)
        UIUtils.AddUIChild(slot.gameObject, text)
        text.name = "Text"
        text:GetComponent(RectTransform).anchoredPosition = Vector2(0, -40)
    end

    self.skillPanel = self.transform:FindChild("SkillPanel")
    self.eggPanel = self.transform:FindChild("EggPanel")
    self.eggPanel:Find("DescText"):GetComponent(Text).text = TI18N("1. 鸿福兔纸和瑞兔送福均不能进行洗髓\n2. 鸿福兔纸可携带出战升级至<color='#ffff00'>30级</color>\n3. 进化后可参与每晚<color='#ffff00'>21至23点</color>开启赢大奖")

    -----------------------
    self.init = true
    self:OnShow()
    self:ClearMainAsset()
end

function PetView_Wash:__delete()
    if self.watchItemSolt ~= nil then
        self.watchItemSolt:DeleteMe()
        self.watchItemSolt = nil
    end

    if self.watchItemSolt2 ~= nil then
        self.watchItemSolt2:DeleteMe()
        self.watchItemSolt2 = nil
    end

    for _, data in ipairs(self.skillList) do
        data:DeleteMe()
        data = nil
    end
    self.skillList = {}

    if self.watchbuttonscript ~= nil then
        self.watchbuttonscript:DeleteMe()
        self.watchbuttonscript = nil
    end

    self:OnHide()
    if self.gameObject ~= nil then
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function PetView_Wash:OnShow()
    self:addevents()
    self:update()
end

function PetView_Wash:OnHide()
    self:removeevents()
    self.watchItemToggle.isOn = false

    if self.guideScript ~= nil then
        self.guideScript:DeleteMe()
        self.guideScript = nil
    end
end

function PetView_Wash:addevents()
    PetManager.Instance.OnPetUpdate:Add(self._update_one)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self._update_item)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self._update_item)
end

function PetView_Wash:removeevents()
    PetManager.Instance.OnPetUpdate:Remove(self._update_one)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self._update_item)
end

function PetView_Wash:update()
    if BaseUtils.isnull(self.gameObject) then return end
    local curPetData = self.model.cur_petdata
    -- if curPetData ~= nil and curPetData.genre==6 then
    --     NoticeManager.Instance:FloatTipsByString(TI18N("精灵蛋无法洗髓"))
    --     if curPetData.status ==1 then
    --         PetManager.Instance.OnSelectPet:Fire(self.model.petlist[2].base_id)
    --         self.model.cur_petdata =self.model.petlist[2]
    --     elseif curPetData.status ==0 then
    --         PetManager.Instance.OnSelectPet:Fire(self.model.petlist[1].base_id)
    --         self.model.cur_petdata =self.model.petlist[1]
    --     end
    -- end

    if self.model.cur_petdata ~= nil then
        self:update_model()
        self:updata_base()
        self:update_qualityattrs()
        self:update_skill()
        self:update_item()

        self:hidelockpetpanel()
        self:ChangeCheck()

        self:GodPetSetting()
    else
        self.watchItemSolt.gameObject:SetActive(false)
        self.watchItemSolt2.gameObject:SetActive(false)
        self.watchItemToggle.gameObject:SetActive(false)
    end
end

function PetView_Wash:update_one(update)
    if self.model.cur_petdata == nil then return end
    if BaseUtils.isnull(self.gameObject) then return end

    self.parent:event_pet_update(update)

    if table.containValue(update, "info") then
        self:updata_base()
        self:update_model()
        self:update_item()
    end
    if table.containValue(update, "quality") then
        self:update_qualityattrs()
    end
    if table.containValue(update, "skills") then
        self:update_skill()
    end
    if table.containValue(update, "grade") then
        self:update_model()
    end
    if table.containValue(update, "upgrade") then
        self:update_model()
    end
    if table.containValue(update, "genre") then
        -- self:update_model()
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Sure
        data.content = string.format(TI18N("你的宠物<color='#00ff00'>%s Lv.%s</color>发生变异了！"), self.model.cur_petdata.name, self.model.cur_petdata.lev)
        data.sureLabel = TI18N("确认")
        -- data.sureCallback = function()
        --         table.insert(self.parent.model_effect_list, 20008)
        --         self.parent:showmodeleffectlist()
        --     end
        NoticeManager.Instance:ConfirmTips(data)
    end
    if table.containValue(update, "washitem") then
        self:update_item()
    end
end

function PetView_Wash:update_model()
    local transform = self.transform
    local preview = transform:FindChild("ModelPanel/Preview")

    local petData = self.model.cur_petdata
    local petModelData = self.model:getPetModel(petData)

    local data = {type = PreViewType.Pet, skinId = petModelData.skin, modelId = petModelData.modelId, animationId = petData.base.animation_id, scale = petData.base.scale / 100, effects = petModelData.effects}
    self.parent:load_preview(preview, data)
end

function PetView_Wash:updata_base()
    local petData = self.model.cur_petdata
    local gameObject = self.transform:FindChild("ModelPanel").gameObject
    gameObject.transform:FindChild("NameText"):GetComponent(Text).text = self.model:get_petname(petData)--petData.name
    gameObject.transform:FindChild("GifeText"):GetComponent(Text).text = string.format("%s(%s)", self.model:gettalentclass(petData.talent), petData.talent)
    gameObject.transform:FindChild("GenreImage"):GetComponent(Image).sprite
        = self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("I18N_Genre%s", (petData.genre+1)))
    if petData.genre == 6 then
        gameObject.transform:FindChild("GenreImage"):GetComponent(Image).sprite
        = self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("I18N_Genre%s", 1))
    end
    gameObject.transform:FindChild("GenreImage").gameObject:SetActive(true)

    if petData.lock == 1 then
        gameObject.transform:FindChild("LockBtn/LockImg").gameObject:SetActive(true)
        gameObject.transform:FindChild("LockBtn/UnLockImg").gameObject:SetActive(false)
    else
        gameObject.transform:FindChild("LockBtn/LockImg").gameObject:SetActive(false)
        gameObject.transform:FindChild("LockBtn/UnLockImg").gameObject:SetActive(true)
    end
end

function PetView_Wash:update_qualityattrs()
    local petData = self.model.cur_petdata
    local transform = self.transform
    if (petData.phy_aptitude / petData.base.phy_aptitude) > 0.97 then
        transform:FindChild("QualityPanel/ValueSlider1/Text"):GetComponent(Text).text = string.format("<color='#ffffff'>%s/%s</color>", petData.phy_aptitude, petData.max_phy_aptitude)
    else
        transform:FindChild("QualityPanel/ValueSlider1/Text"):GetComponent(Text).text = string.format("%s/%s", petData.phy_aptitude, petData.max_phy_aptitude)
    end
    if (petData.pdef_aptitude / petData.base.pdef_aptitude) > 0.97 then
        transform:FindChild("QualityPanel/ValueSlider2/Text"):GetComponent(Text).text = string.format("<color='#ffffff'>%s/%s</color>", petData.pdef_aptitude, petData.max_pdef_aptitude)
    else
        transform:FindChild("QualityPanel/ValueSlider2/Text"):GetComponent(Text).text = string.format("%s/%s", petData.pdef_aptitude, petData.max_pdef_aptitude)
    end
    if (petData.hp_aptitude / petData.base.hp_aptitude) > 0.97 then
        transform:FindChild("QualityPanel/ValueSlider3/Text"):GetComponent(Text).text = string.format("<color='#ffffff'>%s/%s</color>", petData.hp_aptitude, petData.max_hp_aptitude)
    else
        transform:FindChild("QualityPanel/ValueSlider3/Text"):GetComponent(Text).text = string.format("%s/%s", petData.hp_aptitude, petData.max_hp_aptitude)
    end
    if (petData.magic_aptitude / petData.base.magic_aptitude) > 0.97 then
        transform:FindChild("QualityPanel/ValueSlider4/Text"):GetComponent(Text).text = string.format("<color='#ffffff'>%s/%s</color>", petData.magic_aptitude, petData.max_magic_aptitude)
    else
        transform:FindChild("QualityPanel/ValueSlider4/Text"):GetComponent(Text).text = string.format("%s/%s", petData.magic_aptitude, petData.max_magic_aptitude)
    end
    if (petData.aspd_aptitude / petData.base.aspd_aptitude) > 0.97 then
        transform:FindChild("QualityPanel/ValueSlider5/Text"):GetComponent(Text).text = string.format("<color='#ffffff'>%s/%s</color>", petData.aspd_aptitude, petData.max_aspd_aptitude)
    else
        transform:FindChild("QualityPanel/ValueSlider5/Text"):GetComponent(Text).text = string.format("%s/%s", petData.aspd_aptitude, petData.max_aspd_aptitude)
    end

    Tween.Instance:Cancel(self.slider1_tweenId)
    Tween.Instance:Cancel(self.slider2_tweenId)
    Tween.Instance:Cancel(self.slider3_tweenId)
    Tween.Instance:Cancel(self.slider4_tweenId)
    Tween.Instance:Cancel(self.slider5_tweenId)

    local slider1 = transform:FindChild("QualityPanel/ValueSlider1/Slider"):GetComponent(Slider)
    local fun1 = function(value) slider1.value = value end
    self.slider1_tweenId = Tween.Instance:ValueChange(slider1.value, ((petData.phy_aptitude - petData.base.phy_aptitude * 0.8) / (petData.max_phy_aptitude - petData.base.phy_aptitude * 0.8 + 0.0001) * 0.8 + 0.2), 0.3, nil, LeanTweenType.linear, fun1).id

    local slider2 = transform:FindChild("QualityPanel/ValueSlider2/Slider"):GetComponent(Slider)
    local fun2 = function(value) slider2.value = value end
    self.slider2_tweenId = Tween.Instance:ValueChange(slider2.value, ((petData.pdef_aptitude - petData.base.pdef_aptitude * 0.8) / (petData.max_pdef_aptitude - petData.base.pdef_aptitude * 0.8 + 0.0001) * 0.8 + 0.2), 0.3, nil, LeanTweenType.linear, fun2).id

    local slider3 = transform:FindChild("QualityPanel/ValueSlider3/Slider"):GetComponent(Slider)
    local fun3 = function(value) slider3.value = value end
    self.slider3_tweenId = Tween.Instance:ValueChange(slider3.value, ((petData.hp_aptitude - petData.base.hp_aptitude * 0.8) / (petData.max_hp_aptitude - petData.base.hp_aptitude * 0.8 + 0.0001) * 0.8 + 0.2), 0.3, nil, LeanTweenType.linear, fun3).id

    local slider4 = transform:FindChild("QualityPanel/ValueSlider4/Slider"):GetComponent(Slider)
    local fun4 = function(value) slider4.value = value end
    self.slider4_tweenId = Tween.Instance:ValueChange(slider4.value, ((petData.magic_aptitude - petData.base.magic_aptitude * 0.8) / (petData.max_magic_aptitude - petData.base.magic_aptitude * 0.8 + 0.0001) * 0.8 + 0.2), 0.3, nil, LeanTweenType.linear, fun4).id

    local slider5 = transform:FindChild("QualityPanel/ValueSlider5/Slider"):GetComponent(Slider)
    local fun5 = function(value) slider5.value = value end
    self.slider5_tweenId = Tween.Instance:ValueChange(slider5.value, ((petData.aspd_aptitude - petData.base.aspd_aptitude * 0.8) / (petData.max_aspd_aptitude- petData.base.aspd_aptitude * 0.8 + 0.0001) * 0.8 + 0.2), 0.3, nil, LeanTweenType.linear, fun5).id


    -- tween:DoSlider(transform:FindChild("WashPanel/ValueSlider1/Slider").gameObject
    --     , (petData.phy_aptitude - petData.base.phy_aptitude * 0.8) / (petData.max_phy_aptitude - petData.base.phy_aptitude * 0.8) * 0.8 + 0.2, 0.3)
    -- tween:DoSlider(transform:FindChild("WashPanel/ValueSlider2/Slider").gameObject
    --     , (petData.pdef_aptitude - petData.base.pdef_aptitude * 0.8) / (petData.max_pdef_aptitude - petData.base.pdef_aptitude * 0.8) * 0.8 + 0.2, 0.3)
    -- tween:DoSlider(transform:FindChild("WashPanel/ValueSlider3/Slider").gameObject
    --     , (petData.hp_aptitude - petData.base.hp_aptitude * 0.8) / (petData.max_hp_aptitude - petData.base.hp_aptitude * 0.8) * 0.8 + 0.2, 0.3)
    -- tween:DoSlider(transform:FindChild("WashPanel/ValueSlider4/Slider").gameObject
    --     , (petData.magic_aptitude - petData.base.magic_aptitude * 0.8) / (petData.max_magic_aptitude - petData.base.magic_aptitude * 0.8) * 0.8 + 0.2, 0.3)
    -- tween:DoSlider(transform:FindChild("WashPanel/ValueSlider5/Slider").gameObject
    --     , (petData.aspd_aptitude - petData.base.aspd_aptitude * 0.8) / (petData.max_aspd_aptitude- petData.base.aspd_aptitude * 0.8) * 0.8 + 0.2, 0.3)

    transform:FindChild("QualityPanel/GrowthText"):GetComponent(Text).text = string.format("%s<color='%s'>[%s]</color>", string.format("%.2f", petData.growth / 500), self.model.petGrowthColorList[petData.growth_type] ,self.model.petGrowthList[petData.growth_type])
    transform:FindChild("QualityPanel/GrowthImage"):GetComponent(Image).sprite
        = self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("PetGrowth%s", petData.growth_type))

    for i = 1, 5 do
        transform:FindChild(string.format("QualityPanel/Recommend%s", i)).gameObject:SetActive(table.containValue(petData.base.recommend_aptitudes, i))
    end
end

function PetView_Wash:update_skill()
    local petData = self.model.cur_petdata
    local skills = self.model:makeBreakSkill(petData.base.id, petData.skills)

    for i=1,#skills do
        local skilldata = skills[i]
        local icon = self.skillList[i]
        icon.gameObject.name = tostring(skilldata.id)
        local skill_data = DataSkill.data_petSkill[string.format("%s_1", skilldata.id)]
        icon:SetAll(Skilltype.petskill, skill_data)
        icon:ShowState(skilldata.source == 2)
        icon:ShowLabel(skilldata.source == 4 or skilldata.isBreak, TI18N("<color='#ffff00'>突破</color>"))
        icon:ShowBreak(skilldata.isBreak, TI18N("<color='#FF0000'>未激活</color>"))
        icon.gameObject.transform:FindChild("Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultStr, BaseUtils.string_cut(skill_data.name, 12, 9))
        icon.gameObject:SetActive(true)
    end

    local length = #skills+1
    if length < 7 then
        length = 7
    end

    for i=#skills+1,length do
        local icon = self.skillList[i]
        icon.gameObject.name = ""
        icon:Default()
        icon:ShowState(false)
        icon.skillData = nil
        icon.gameObject.transform:FindChild("Text"):GetComponent(Text).text = ""
        icon.gameObject:SetActive(true)
    end

    if length < #self.skillList then
        for i=length+1,#self.skillList do
            local icon = self.skillList[i]
            icon.gameObject:SetActive(false)
        end
    end
end

function PetView_Wash:update_item()
    if self.model.cur_petdata ~= nil then
        local cost = self.model.cur_petdata.base.cost[1]
        -- local slot_info = {trans = watchItemSolt.transform, data = { base = mod_item.item_base_data(cost[1]) }
        -- , is_equip = false, num_need = 0, show_num = false, is_lock = false, show_name = "", is_new = false, is_select = false, inbag = false, show_tips = true, show_select = false}
        -- slot_item.set_data(slot_info)
        local itembase = BackpackManager.Instance:GetItemBase(cost[1])
        local watchItemData = ItemData.New()
        watchItemData:SetBase(itembase)
        self.watchItemSolt:SetAll(watchItemData)

        self.transform:FindChild("ItemNameText"):GetComponent(Text).text = string.format("<color='#225ee7'>%s</color>", itembase.name)--ColorHelper.color_item_name(itembase.quality, itembase.name)
        local neednum = cost[2]
        -- if self.model.cur_petdata.genre == 1 then neednum = neednum * 2 end
        local num = BackpackManager.Instance:GetItemCount(cost[1])
        self.transform:FindChild("ItemNumText"):GetComponent(Text).text = string.format("%s/%s", num, neednum)
        if num < neednum then
            self.transform:FindChild("ItemNumText"):GetComponent(Text).color = Color.red
        else
            self.transform:FindChild("ItemNumText"):GetComponent(Text).color = Color.green
        end

        -- 版号需求
        -- if PrivilegeManager.Instance.charge < 1000 and self.model.today_wash_num >= 10 then
        --     self.watchbuttonscript:Layout({}, function() self:towash() end, nil, { antofreeze = false })
        -- else
            self.watchbuttonscript:Layout({[cost[1]] = {need = neednum}}, function() self:towash() end, nil, { antofreeze = false })
        -- end

        -------------------------------------------------------------------------------
        local cost2 = 29100
        if self.model.cur_petdata.genre == 1 then
            cost2 = 29101
        end
        local itembase2 = BackpackManager.Instance:GetItemBase(cost2)
        local watchItemData2 = ItemData.New()
        watchItemData2:SetBase(itembase2)
        self.watchItemSolt2:SetAll(watchItemData2)

        self.transform:FindChild("ItemNameText2"):GetComponent(Text).text = ColorHelper.color_item_name(itembase2.quality, itembase2.name)
        local num = BackpackManager.Instance:GetItemCount(cost2)
        self.transform:FindChild("ItemNumText2"):GetComponent(Text).text = string.format("%s/%s", num, 1)
        if num < 1 then
            self.transform:FindChild("ItemNumText2"):GetComponent(Text).color = Color.red
        else
            self.transform:FindChild("ItemNumText2"):GetComponent(Text).color = Color.green
        end

        if num < 1 or self.model.cur_petdata.grade ~= 0 then
            self.transform:FindChild("ItemSolt2").gameObject:SetActive(false)
            self.transform:FindChild("ItemNameText2").gameObject:SetActive(false)
            self.transform:FindChild("ItemNumText2").gameObject:SetActive(false)
            self.transform:FindChild("Image2").gameObject:SetActive(false)

            self.watchItemSolt2.gameObject:SetActive(false)
            self.watchItemToggle.gameObject:SetActive(false)
            self.watchItemToggle.isOn = false
        else
            self.transform:FindChild("ItemSolt2").gameObject:SetActive(true)
            self.transform:FindChild("ItemNameText2").gameObject:SetActive(true)
            self.transform:FindChild("ItemNumText2").gameObject:SetActive(true)
            self.transform:FindChild("Image2").gameObject:SetActive(true)
            self.watchItemSolt2.gameObject:SetActive(true)
            self.watchItemToggle.gameObject:SetActive(true)
        end
        self.watchItemSolt.gameObject:SetActive(true)
    else
        self.watchItemSolt.gameObject:SetActive(false)
        self.watchItemSolt2.gameObject:SetActive(false)
        self.watchItemToggle.gameObject:SetActive(false)
    end

    -- self.transform:FindChild("ItemSolt").gameObject:SetActive(false)
    self.transform:FindChild("ItemSolt2").gameObject:SetActive(false)
    self.transform:FindChild("DescButton").gameObject:SetActive(false)
    -- self.transform:FindChild("ItemNameText").gameObject:SetActive(false)
    self.transform:FindChild("ItemNameText2").gameObject:SetActive(false)
    -- self.transform:FindChild("ItemNumText").gameObject:SetActive(false)
    self.transform:FindChild("ItemNumText2").gameObject:SetActive(false)
    -- self.transform:FindChild("Image").gameObject:SetActive(false)
    self.transform:FindChild("Image2").gameObject:SetActive(false)
    self.transform:FindChild("Toggle").gameObject:SetActive(false)
end

function PetView_Wash:update_toggle()
    if self.watchItemToggle ~= nil then self.watchItemToggle.isOn = false end
end

function PetView_Wash:towash()

    if self.model.cur_petdata.genre == 2 then
        NoticeManager.Instance:FloatTipsByString(TI18N("神兽无法洗髓"))
    elseif self.model.cur_petdata.genre == 4 then
        NoticeManager.Instance:FloatTipsByString(TI18N("珍兽无法洗髓"))
    elseif self.model.cur_petdata.lock == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("锁定宠物无法洗髓"))
    elseif self.model.cur_petdata.status == 1  then
        NoticeManager.Instance:FloatTipsByString(TI18N("出战宠物无法洗髓"))
    elseif self.model.cur_petdata.grade ~= 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("进阶宠物无法洗髓"))
    else
        self.model:OpenPetWashWindow()
        self.watchbuttonscript:ReleaseFrozon()
    end


    -- local petData = self.model.cur_petdata
    -- if petData == nil then return end
    -- local item_flag = 0
    -- if self.watchItemToggle.isOn then item_flag = 1 end
--
    -- if not self.model.isnotify_watch then
        -- if petData.genre == 1 and not self.watchItemToggle.isOn then
            -- local data = NoticeConfirmData.New()
            -- data.type = ConfirmData.Style.Normal
            -- data.content = TI18N("宠物已经<color='#ffff00'>发生变异</color>，继续洗髓将有概率将变异宠物变为普通宝宝，是否继续进行洗髓？")
            -- data.sureLabel = TI18N("同意")
            -- data.cancelLabel = TI18N("拒绝")
            -- data.sureCallback = function()
                    -- self.watchbuttonscript:Freeze()
                    -- PetManager.Instance:Send10505(petData.id, item_flag)
                    -- self.model.isnotify_watch = true
                -- end
            -- NoticeManager.Instance:ConfirmTips(data)
            -- return
        -- end
    -- end
--
    -- if not self.model.isnotify_watch_baobao and not self.parent.canGuideSecond then
        -- if petData.genre == 0 then
            -- local data = NoticeConfirmData.New()
            -- data.type = ConfirmData.Style.Normal
            -- data.content = TI18N("这种宠物是<color='#ffff00'>宝宝</color>，确定要对其进行洗髓吗？")
            -- data.sureLabel = TI18N("同意")
            -- data.cancelLabel = TI18N("拒绝")
            -- data.sureCallback = function()
                    -- self.watchbuttonscript:Freeze()
                    -- PetManager.Instance:Send10505(petData.id, item_flag)
                    -- self.model.isnotify_watch_baobao = true
                -- end
            -- NoticeManager.Instance:ConfirmTips(data)
            -- return
        -- end
    -- end
    -- self.watchbuttonscript:Freeze()
--
    -- PetManager.Instance:Send10505(petData.id, item_flag)
end

function PetView_Wash:ondesc()
    TipsManager.Instance:ShowText({gameObject = self.transform:FindChild("DescButton").gameObject
            , itemData = { TI18N("使用<color='#ffff00'>星辰精华</color>进行洗髓，会出现以下效果：")
                            , TI18N("1.改变宠物的资质和技能")
                            , TI18N("2.有几率<color='#00ff00'>变异</color>，变异后洗髓有几率变回普通宠物")
                            , TI18N("3.变异后可能附带<color='#ffff00'>额外技能</color>")
                            , TI18N("4.变异后可能出现资质最大值<color='#ffff00'>突破基础上限</color>")
                            , TI18N("5.使用<color='#ffff00'>苏醒仙泉</color>洗髓必定使宠物<color='#ffff00'>发生变异</color>")
                            , TI18N("6.使用<color='#ffff00'>仙灵卷轴</color>洗髓必定使变异宠<color='#ffff00'>保持变异</color>")
                            , TI18N("7.洗髓一定次数后将会触发<color='#ffff00'>多技能保底</color>（必定获得4技能，且变异宠物不生效）")
                            , TI18N("8.当天内洗髓每消耗一定量的星辰精华，将会获得一张<color='#ffff00'>仙灵卷轴</color>")
                            , TI18N("9.专有技能<color='#ffff00'>不会</color>被学习技能/洗髓<color='#00ff00'>替换掉</color>，会一直存在")
                        }})
end

function PetView_Wash:showgiftimagetips()
    if self.model.cur_petdata ~= nil then
        self.transform:FindChild("GiftTips").gameObject:SetActive(true)
        -- transform:FindChild("GiftTips/Tips/Text"):GetComponent(Text).text = tostring(math.floor(mod_pet.cur_petdata.growth / 5) / 100)
        self.transform:FindChild("GiftTips/Tips/Text"):GetComponent(Text).text = string.format("%.2f", self.model.cur_petdata.growth / 500)
    end
end

function PetView_Wash:hidegiftimagetips()
    self.transform:FindChild("GiftTips").gameObject:SetActive(false)
end

function PetView_Wash:lockpetbuttonclick()
    if self.model.cur_petdata ~= nil then
        if self.model.cur_petdata.lock == 0 then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("对宠物加锁后，将无法进行<color='#ffff00'>洗髓、放生、学习技能、洗点</color>。解锁不需要消耗任何资源。是否进行加锁？")
            data.sureLabel = TI18N("加锁")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = function() PetManager.Instance:Send10537(self.model.cur_petdata.id) end
            NoticeManager.Instance:ConfirmTips(data)
        else
            self.transform:FindChild("LockPanel").gameObject:SetActive(true)
            local input_field = self.transform:FindChild("LockPanel/Main/InputCon"):FindChild("InputField"):GetComponent(InputField)
            input_field.textComponent = self.transform:FindChild("LockPanel/Main/InputCon/InputField/Text"):GetComponent(Text)
            input_field.text = TI18N("请输入上方的验证码")

            -- self.lockKey = "1234"
            self.lockKey = tostring(math.random(1000, 9999))
            self.transform:FindChild("LockPanel/Main/Key_Text"):GetComponent(Text).text = self.lockKey
        end
    end
end

function PetView_Wash:hidelockpetpanel()
    self.transform:FindChild("LockPanel").gameObject:SetActive(false)
end

function PetView_Wash:lockpet()
    if self.model.cur_petdata ~= nil then
        local input_field = self.transform:FindChild("LockPanel/Main/InputCon"):FindChild("InputField"):GetComponent(InputField)
        local str = input_field.text
        if str == self.lockKey then
            self:hidelockpetpanel()
            PetManager.Instance:Send10538(self.model.cur_petdata.id)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("验证码错误"))
        end
    end
end

function PetView_Wash:ChangeCheck()
    if RoleManager.Instance.RoleData.lev >= 15 and PetManager.Instance.model:getpetid_bybaseid(10003) ~= nil and self.parent.canGuideSecond and not PetManager.Instance.isWash then
        local questData = QuestManager.Instance.questTab[10300]
        if questData == nil then
            questData = QuestManager.Instance.questTab[22300]
        end

        local petData,_ = PetManager.Instance.model:getpet_byid(PetManager.Instance.model:getpetid_bybaseid(10003))
        if questData ~= nil and questData.finish ~= QuestEumn.TaskStatus.Finish then
            local data = self.model.cur_petdata
            if self.guideScript ~= nil then
                self.guideScript:DeleteMe()
                self.guideScript = nil
            end
            if data ~= nil and data.base_id == 10003 and petData.status == 0 then
                if self.guideScript == nil then
                    self.guideScript = GuidePetWashSec.New(self)
                    self.guideScript:Show()
                end
            end
        end
    end
end

function PetView_Wash:close_all_tips()
    self:hidelockpetpanel()
    self:hidegiftimagetips()
end

function PetView_Wash:GodPetSetting()
    if self.model.cur_petdata.genre == 6 then -- 如果是神兽蛋，做特殊处理
        self.skillPanel.gameObject:SetActive(false)
        self.eggPanel.gameObject:SetActive(true)

        local modelPanel = self.transform:FindChild("ModelPanel")
        modelPanel:GetChild(5).gameObject:SetActive(false)
        modelPanel:GetChild(6).gameObject:SetActive(false)
        modelPanel:GetChild(7).gameObject:SetActive(false)

        self.transform:FindChild("ItemSolt").gameObject:SetActive(false)
        self.transform:FindChild("ItemNameText").gameObject:SetActive(false)
        self.transform:FindChild("ItemNumText").gameObject:SetActive(false)
        self.transform:FindChild("Image").gameObject:SetActive(false)
        self.transform:FindChild("Line").gameObject:SetActive(false)
        self.transform:FindChild("WashBtn").gameObject:SetActive(false)
    else
        self.skillPanel.gameObject:SetActive(true)
        self.eggPanel.gameObject:SetActive(false)

        local modelPanel = self.transform:FindChild("ModelPanel")
        modelPanel:GetChild(5).gameObject:SetActive(true)
        modelPanel:GetChild(6).gameObject:SetActive(true)
        modelPanel:GetChild(7).gameObject:SetActive(true)

        self.transform:FindChild("ItemSolt").gameObject:SetActive(true)
        self.transform:FindChild("ItemNameText").gameObject:SetActive(true)
        self.transform:FindChild("ItemNumText").gameObject:SetActive(true)
        self.transform:FindChild("Image").gameObject:SetActive(true)
        self.transform:FindChild("Line").gameObject:SetActive(true)
        self.transform:FindChild("WashBtn").gameObject:SetActive(true)
    end
end
