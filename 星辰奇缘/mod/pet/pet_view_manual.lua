-- ----------------------------------------------------------
-- UI - 宠物窗口 图鉴面板
-- ----------------------------------------------------------
PetView_Manual = PetView_Manual or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3
local Color = UnityEngine.Color

function PetView_Manual:__init(parent)
	self.parent = parent
    self.model = parent.model
    self.name = "PetView_Manual"
    self.resList = {
        {file = AssetConfig.pet_window_manual, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
        ,{file  =  AssetConfig.wingsbookbg, type  =  AssetType.Dep}
        ,{file = AssetConfig.petevaluation_texture,type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil
    self.init = false

    ------------------------------------------------
    self.manualHeadContainer = nil
    self.manualheadobject = nil
    self.showtype = 1
    self.headlist = {}
    self.petdata = nil
    self.skilllist = {}
    self.gray_pet_list = {}
    self.headLoaderList = {}

    self.select_baseid = nil
    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function PetView_Manual:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pet_window_manual))
    self.gameObject.name = "PetView_Manual"
    self.gameObject.transform:SetParent(self.parent.mainTransform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.transform = self.gameObject.transform

    -----------------------------------------
    local transform = self.transform

    transform:FindChild("InfoPanel/ModlePanel/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")

    -- 按钮功能绑定
    local btn
    btn = transform:FindChild("HeadPanel/TabButtonGroup/Button1"):GetComponent(Button)
    btn.onClick:AddListener(function() self:showhead1() end)

    btn = transform:FindChild("HeadPanel/TabButtonGroup/Button2"):GetComponent(Button)
    btn.onClick:AddListener(function() self:showhead2() end)

    btn = transform:FindChild("InfoPanel/ModlePanel/DescButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:showTips() end)

    btn = transform:FindChild("InfoPanel/ModlePanel/Preview").gameObject:AddComponent(Button)
    btn.onClick:AddListener(function() self.parent:PlayAction() end)

    self.manualHeadContainer = transform:FindChild("HeadPanel/mask/HeadContainer").gameObject
    self.manualHeadObject = transform:FindChild("HeadPanel/mask/HeadContainer/PetHead").gameObject

    self.attrsPanel = self.transform:FindChild("InfoPanel/AttrsPanel")
    self.skillPanel = self.transform:FindChild("InfoPanel/SkillPanel")
    self.skillSpirtPanel = self.transform:FindChild("InfoPanel/SpiritSkillPanel")

    self.skillPanelText1 = self.skillSpirtPanel:FindChild("Text1"):GetComponent(Text)
    self.skillPanelText2 = self.skillSpirtPanel:FindChild("Text2"):GetComponent(Text)
    self.skillPanelText3 = self.skillSpirtPanel:FindChild("Text3"):GetComponent(Text)
    self.skillPanelText4 = self.skillSpirtPanel:FindChild("Text4"):GetComponent(Text)
    self.skillSpirtPanelSkillIcon = SkillSlot.New()
    UIUtils.AddUIChild(self.skillSpirtPanel.transform:FindChild("SkillIcon").gameObject, self.skillSpirtPanelSkillIcon.gameObject)

    -- 初始化技能图标
    local soltPanel = transform:FindChild("InfoPanel/SkillPanel/SoltPanel/Container").gameObject
    local textObject = transform:FindChild("InfoPanel/SkillPanel/SkillText").gameObject
    for i=1, 6 do
        local slot = SkillSlot.New()
        UIUtils.AddUIChild(soltPanel, slot.gameObject)
        table.insert(self.skilllist, slot)

        local text = GameObject.Instantiate(textObject)
        UIUtils.AddUIChild(slot, text)
        text.name = "Text"
        text:GetComponent(RectTransform).anchoredPosition = Vector2(0, -40)
    end

    --评论按钮
    self.evaluationbtn = transform:Find("InfoPanel/EvaluationButton").gameObject:GetComponent(Button)
    self.evaluationbtn.onClick:AddListener(function()
         WindowManager.Instance:OpenWindowById(WindowConfig.WinID.petevaluation,{self.petdata,1})
     end
    )

    --评论按钮
    self.skinbtn = transform:Find("InfoPanel/SkinButton").gameObject:GetComponent(Button)
    self.skinbtn.onClick:AddListener(function()
            self.model:OpenPetSkinPreviewWindow({self.petdata})
        end)

    self.tabMaskTransform = transform:FindChild("InfoPanel/TabMask")
    self.tabGroupObj = transform:FindChild("InfoPanel/TabMask/TabButtonGroup").gameObject
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:ChangeTab(index) end)

    transform:FindChild("InfoPanel/SpiritSkillPanel/HandBookButton"):GetComponent(Button).onClick:AddListener(function() self:onHandBookButtonClick() end)

    -----------------------------------------
    self.init = true
    self:OnShow()
    self:ClearMainAsset()
end

function PetView_Manual:__delete()
    self:OnHide()

    for _, data in ipairs(self.skilllist) do
        data:DeleteMe()
    end
    if self.headLoaderList ~= nil then
        for k,v in pairs(self.headLoaderList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.headLoaderList = nil
    end
    self.skilllist = {}

    if self.gameObject ~= nil then
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function PetView_Manual:OnShow()
    if self.parent.openArgs ~= nil and #self.parent.openArgs > 1 then
        self.select_baseid = self.parent.openArgs[2]
    elseif self.model.cur_petdata ~= nil then
        self.select_baseid = self.model.cur_petdata.base.id
    else
        self.select_baseid = nil
    end

    if self.select_baseid ~= nil and DataPet.data_pet[self.select_baseid] ~= nil and (DataPet.data_pet[self.select_baseid].genre == 2 or DataPet.data_pet[self.select_baseid].genre == 4) then
        self:showhead2()
    else
        self:showhead1()
    end
end

function PetView_Manual:OnHide()
end

function PetView_Manual:showhead1()
    self.transform:FindChild("HeadPanel/TabButtonGroup/Button1/Select").gameObject:SetActive(true)
    self.transform:FindChild("HeadPanel/TabButtonGroup/Button2/Select").gameObject:SetActive(false)
    self.transform:FindChild("HeadPanel/TabButtonGroup/Button1/Normal").gameObject:SetActive(false)
    self.transform:FindChild("HeadPanel/TabButtonGroup/Button2/Normal").gameObject:SetActive(true)

    self.showtype = 1
    self:update_tab()
    self:update_head()
end

function PetView_Manual:showhead2()
    self.transform:FindChild("HeadPanel/TabButtonGroup/Button1/Select").gameObject:SetActive(false)
    self.transform:FindChild("HeadPanel/TabButtonGroup/Button2/Select").gameObject:SetActive(true)
    self.transform:FindChild("HeadPanel/TabButtonGroup/Button1/Normal").gameObject:SetActive(true)
    self.transform:FindChild("HeadPanel/TabButtonGroup/Button2/Normal").gameObject:SetActive(false)

    self.showtype = 2
    self:update_tab()
    self:update_head()
end

function PetView_Manual:update_head()
    local headlist = self.headlist
    local manualHeadObject = self.manualHeadObject
    local manualHeadContainer = self.manualHeadContainer
    local headlist_index = 1
    local select_head = nil
    local pet_list = {}
    local manual_lev = 10000
    local role_lve = RoleManager.Instance.RoleData.lev
    if role_lve < 15 then
        manual_lev = 15
    elseif role_lve < 35 then
        manual_lev = 35
    elseif role_lve < 45 then
        manual_lev = 45
    elseif role_lve < 55 then
        manual_lev = 55
    elseif role_lve < 65 then
        manual_lev = 65
    elseif role_lve < 75 then
        manual_lev = 75
    elseif role_lve < 85 then
        manual_lev = 85
    elseif role_lve < 95 then
        manual_lev = 95
    elseif role_lve < 105 then
        manual_lev = 105
    elseif role_lve < 115 then
        manual_lev = 115
    elseif role_lve < 125 then
        manual_lev = 125
    elseif role_lve < 135 then
        manual_lev = 135
    end

    local lev_break_times = RoleManager.Instance.RoleData.lev_break_times

    self.gray_pet_list = {}
    for k,v in pairs(DataPet.data_pet) do
        if v.manual_type == self.showtype and v.genre ~= 6 and v.show_manual == 1 and ( (v.need_lev_break <= lev_break_times and v.manual_level <= manual_lev) or (v.need_lev_break > lev_break_times and v.manual_level <= manual_lev - 10 )) then
                if v.manual_level < manual_lev and v.need_lev_break <= lev_break_times then
                    table.insert(pet_list, {data = v, gray = false})
                    self.gray_pet_list[v.id] = false
                else
                    table.insert(pet_list, {data = v, gray = true})
                    self.gray_pet_list[v.id] = true
                end
        end
    end

    local sortfunction = function(a,b) return a.data.manual_sort < b.data.manual_sort end
    table.sort(pet_list, sortfunction)

    for i = 1,#pet_list do
        local data = pet_list[i].data
        local gray = pet_list[i].gray
        local headitem = headlist[headlist_index]

        if headitem == nil then
            local item = GameObject.Instantiate(manualHeadObject)
            item:SetActive(true)
            item.transform:SetParent(manualHeadContainer.transform)
            item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
            local fun = function() self:onheaditemclick(item) end
            item:GetComponent(Button).onClick:AddListener(fun)
            headlist[headlist_index] = item
            headitem = item
        end
        headitem:SetActive(true)

        headitem.name = tostring(data.id)
        local loaderId = headitem.transform:FindChild("Head"):GetComponent(Image).gameObject:GetInstanceID()
        if self.headLoaderList[loaderId] == nil then
            self.headLoaderList[loaderId] = SingleIconLoader.New(headitem.transform:FindChild("Head"):GetComponent(Image).gameObject)
        end
        self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,data.head_id)

        -- headitem.transform:FindChild("Head"):GetComponent(Image).sprite
        --     = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(data.head_id), tostring(data.head_id))

        if data.need_lev_break == 0 then
            headitem.transform:FindChild("LVText"):GetComponent(Text).text = string.format("%s", data.manual_level)
            headitem.transform:FindChild("Image"):GetComponent(Image).rectTransform.sizeDelta = Vector2(35.7, 18.8)
        else
            headitem.transform:FindChild("LVText"):GetComponent(Text).text = string.format("突破%s", data.manual_level)
            headitem.transform:FindChild("Image"):GetComponent(Image).rectTransform.sizeDelta = Vector2(62, 18.8)
        end

        if gray then
            headitem.transform:FindChild("Head"):GetComponent(Image).color = Color.gray
            headitem.transform:FindChild("LVText"):GetComponent(Text).color = Color.red
        else
            headitem.transform:FindChild("Head"):GetComponent(Image).color = Color.white
            headitem.transform:FindChild("LVText"):GetComponent(Text).color = Color.white
        end

        headlist_index = headlist_index + 1

        if self.select_baseid == data.id then
            select_head = headitem
        end
    end
    local headitem = {}
    for i = headlist_index, #headlist do
        local headitem = headlist[i]
        headitem:SetActive(false)
    end

    if select_head ~= nil then
        self:onheaditemclick(select_head)
    elseif #headlist > 0 then
        self:onheaditemclick(headlist[1])
    end
end

function PetView_Manual:onheaditemclick(item)
    self.petdata = DataPet.data_pet[tonumber(item.name)]

    self:update()

    local head
    for i = 1, #self.headlist do
        self.head = self.headlist[i]
        self.head.transform:FindChild("Select").gameObject:SetActive(false)
    end
    item.transform:FindChild("Select").gameObject:SetActive(true)
end

function PetView_Manual:update()
    self:UpdateSpirtTab()

    self:update_model()
    self:updata_base()
    self:update_qualityattrs()
    self:update_skill()
    self:update_skill_spirt()
end

function PetView_Manual:UpdateSpirtTab()
    if self.petdata == nil then return end
    local data_pet_spirt_score_level0 = self.model:GetPetSpirtScoreBySkillLevel(self.petdata.id, 0)
    if data_pet_spirt_score_level0 == nil then
        if (self.showtype == 1 and self.spirtTabMark) or (self.showtype == 2 and self.spirtTabMark) then
            self.tabGroup:ChangeTab(1)
        end
        if self.showtype == 1 then
            self.tabGroup.buttonTab[4].gameObject:SetActive(false)
        elseif self.showtype == 2 then
            self.tabGroup.buttonTab[5].gameObject:SetActive(false)
        end
    else
        if self.showtype == 1 then
            self.tabGroup.buttonTab[4].gameObject:SetActive(true)
        elseif self.showtype == 2 then
            self.tabGroup.buttonTab[5].gameObject:SetActive(true)
        end
    end
end

function PetView_Manual:update_model()
    if self.petdata == nil then return end

    local transform = self.transform
    local preview = transform:FindChild("InfoPanel/ModlePanel/Preview")

    local petdata = self.petdata
    local data = {type = PreViewType.Pet, skinId = petdata.skin_id_0, modelId = petdata.model_id, animationId = petdata.animation_id, scale = petdata.scale / 100, effects = petdata.effects_0}
    if self.showtype == 1 then
        if self.manual_type == 1 then
            data.modelId = petdata.model_id
            data.skinId = petdata.skin_id_0
            data.effects = petdata.effects_0
        elseif self.manual_type == 2 then
            data.modelId = petdata.model_id
            data.skinId = petdata.skin_id_s0
            data.effects = petdata.effects_s0
        elseif self.manual_type == 3 then
            data.modelId = petdata.model_id
            data.skinId = petdata.skin_id_0
            data.effects = petdata.effects_0
        end
    elseif self.showtype == 2 then
        if self.manual_type == 1 then
            data.modelId = petdata.model_id
            data.skinId = petdata.skin_id_0
            data.effects = petdata.effects_0
        elseif self.manual_type == 2 then
            data.modelId = petdata.model_id1
            data.skinId = petdata.skin_id_1
            data.effects = petdata.effects_1
        elseif self.manual_type == 3 then
            data.modelId = petdata.model_id2
            data.skinId = petdata.skin_id_2
            data.effects = petdata.effects_2
        elseif self.manual_type == 4 then
            data.modelId = petdata.model_id3
            data.skinId = petdata.skin_id_3
            data.effects = petdata.effects_3
        end
    end
    self.parent:load_preview(preview, data)
end

function PetView_Manual:updata_base()
    if self.petdata == nil then return end

    local transform = self.transform
    local petdata = self.petdata
    local panel = transform:FindChild("InfoPanel/ModlePanel").gameObject
    panel.transform:FindChild("NameText"):GetComponent(Text).text = self.model:get_petname(petdata)--petdata.name
    if petdata.need_lev_break > 0 then
        panel.transform:FindChild("LevelText"):GetComponent(Text).text = string.format(TI18N("突破%s"), petdata.manual_level)
    else
        panel.transform:FindChild("LevelText"):GetComponent(Text).text = string.format(" %s", petdata.manual_level)
    end

    if petdata.genre == 2 or petdata.genre == 4 or petdata.genre == 5 then
        panel.transform:FindChild("GenreImage"):GetComponent(Image).sprite
            = self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("I18N_Genre%s", (petdata.genre+1)))
        panel.transform:FindChild("GenreImage").gameObject:SetActive(true)
    else
        panel.transform:FindChild("GenreImage").gameObject:SetActive(false)
    end

    if petdata.genre == 2 or petdata.genre == 4 then
        panel.transform:FindChild("DescButton").gameObject:SetActive(true)
    else
        panel.transform:FindChild("DescButton").gameObject:SetActive(false)
    end

    panel = transform:FindChild("InfoPanel/AccessPanel").gameObject
    local btn = nil
    local manual_access = BaseUtils.match_between_symbols(petdata.manual_access, "{", "}")
    btn = panel.transform:FindChild("Button1").gameObject
    if #manual_access > 0 then
        local access = BaseUtils.split(manual_access[1], ",")
        btn:SetActive(true)
        btn.transform:FindChild("Text"):GetComponent(Text).text = access[1]
        local fun = function() self:click_manual_access(tonumber(access[2]), tonumber(access[3])) end
        btn:GetComponent(Button).onClick:RemoveAllListeners()
        btn:GetComponent(Button).onClick:AddListener(fun)

        if tonumber(access[2]) == 1 then
            btn:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        else
            btn:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        end
    else
        btn:SetActive(false)
    end

    btn = panel.transform:FindChild("Button2").gameObject
    if #manual_access > 1 then
        local access = BaseUtils.split(manual_access[2], ",")
        btn:SetActive(true)
        btn.transform:FindChild("Text"):GetComponent(Text).text = access[1]
        local fun = function() self:click_manual_access(tonumber(access[2]), tonumber(access[3])) end
        btn:GetComponent(Button).onClick:RemoveAllListeners()
        btn:GetComponent(Button).onClick:AddListener(fun)

        if tonumber(access[2]) == 1 then
            btn:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        else
            btn:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        end
    else
        btn:SetActive(false)
    end

    if self.showtype == 1 then
        if self.manual_type == 1 then
            panel.transform:FindChild("Button1").gameObject:SetActive(#manual_access > 0)
            panel.transform:FindChild("Button2").gameObject:SetActive(#manual_access > 1)
            panel.transform:FindChild("DescText").gameObject:SetActive(false)
        elseif self.manual_type == 2 then
            panel.transform:FindChild("Button1").gameObject:SetActive(false)
            panel.transform:FindChild("Button2").gameObject:SetActive(false)
            panel.transform:FindChild("DescText").gameObject:SetActive(true)
            panel.transform:FindChild("DescText"):GetComponent(Text).text = TI18N("通过<color='#00ff00'>【洗髓】</color>有几率触发变异")
        elseif self.manual_type == 3 then
            panel.transform:FindChild("Button1").gameObject:SetActive(#manual_access > 0)
            panel.transform:FindChild("Button2").gameObject:SetActive(#manual_access > 1)
            panel.transform:FindChild("DescText").gameObject:SetActive(false)
        end
    elseif self.showtype == 2 then
        if self.manual_type == 1 then
            panel.transform:FindChild("Button1").gameObject:SetActive(#manual_access > 0)
            panel.transform:FindChild("Button2").gameObject:SetActive(#manual_access > 1)
            panel.transform:FindChild("DescText").gameObject:SetActive(false)
        else
            panel.transform:FindChild("Button1").gameObject:SetActive(false)
            panel.transform:FindChild("Button2").gameObject:SetActive(false)
            panel.transform:FindChild("DescText").gameObject:SetActive(true)
            panel.transform:FindChild("DescText"):GetComponent(Text).text = TI18N("通过<color='#00ff00'>【进阶】</color>可获得")
        end
    end

    if DataPet.data_pet_skin[string.format("%s_%s", self.petdata.id, 1)] ~= nil then
        self.skinbtn.gameObject:SetActive(true)
    else
        self.skinbtn.gameObject:SetActive(false)
    end
end

function PetView_Manual:update_qualityattrs()
    if self.petdata == nil then return end

    local transform = self.transform
    local petdata = self.petdata
    local panel = transform:FindChild("InfoPanel/AttrsPanel").gameObject

    if self.petdata.hide_aptitude == 1 then
        panel.transform:FindChild("ValueText1"):GetComponent(Text).text = "1??0~1??0"
        panel.transform:FindChild("ValueText2"):GetComponent(Text).text = "1??0~1??0"
        panel.transform:FindChild("ValueText3"):GetComponent(Text).text = "1??0~1??0"
        panel.transform:FindChild("ValueText4"):GetComponent(Text).text = "1??0~1??0"
        panel.transform:FindChild("ValueText5"):GetComponent(Text).text = "1??0~1??0"
    else
        if self.showtype == 1 then
            if self.manual_type == 1 then
                panel.transform:FindChild("ValueText1"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.phy_aptitude * 0.8 + 0.5), petdata.phy_aptitude)
                panel.transform:FindChild("ValueText2"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.pdef_aptitude * 0.8 + 0.5), petdata.pdef_aptitude)
                panel.transform:FindChild("ValueText3"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.hp_aptitude * 0.8 + 0.5), petdata.hp_aptitude)
                panel.transform:FindChild("ValueText4"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.magic_aptitude * 0.8 + 0.5), petdata.magic_aptitude)
                panel.transform:FindChild("ValueText5"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.aspd_aptitude * 0.8 + 0.5), petdata.aspd_aptitude)
            elseif self.manual_type == 2 then
                panel.transform:FindChild("ValueText1"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.phy_aptitude * 0.8 * 1.02 + 0.5), math.floor(petdata.phy_aptitude * 1.02 + 0.5))
                panel.transform:FindChild("ValueText2"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.pdef_aptitude * 0.8 * 1.02 + 0.5), math.floor(petdata.pdef_aptitude * 1.02 + 0.5))
                panel.transform:FindChild("ValueText3"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.hp_aptitude * 0.8 * 1.02 + 0.5), math.floor(petdata.hp_aptitude * 1.02 + 0.5))
                panel.transform:FindChild("ValueText4"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.magic_aptitude * 0.8 * 1.02 + 0.5), math.floor(petdata.magic_aptitude * 1.02 + 0.5))
                panel.transform:FindChild("ValueText5"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.aspd_aptitude * 0.8 * 1.02 + 0.5), math.floor(petdata.aspd_aptitude * 1.02 + 0.5))
            elseif self.manual_type == 3 then
                panel.transform:FindChild("ValueText1"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.phy_aptitude * 0.81 + 0.5), math.floor(petdata.phy_aptitude * 0.82 + 0.5))
                panel.transform:FindChild("ValueText2"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.pdef_aptitude * 0.81 + 0.5), math.floor(petdata.pdef_aptitude * 0.82 + 0.5))
                panel.transform:FindChild("ValueText3"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.hp_aptitude * 0.81 + 0.5), math.floor(petdata.hp_aptitude * 0.82 + 0.5))
                panel.transform:FindChild("ValueText4"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.magic_aptitude * 0.81 + 0.5), math.floor(petdata.magic_aptitude * 0.82 + 0.5))
                panel.transform:FindChild("ValueText5"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.aspd_aptitude * 0.81 + 0.5), math.floor(petdata.aspd_aptitude * 0.82 + 0.5))
            end
        else
            if self.manual_type == 1 then
                panel.transform:FindChild("ValueText1"):GetComponent(Text).text = string.format("%s~%s", petdata.phy_aptitude, petdata.phy_aptitude)
                panel.transform:FindChild("ValueText2"):GetComponent(Text).text = string.format("%s~%s", petdata.pdef_aptitude, petdata.pdef_aptitude)
                panel.transform:FindChild("ValueText3"):GetComponent(Text).text = string.format("%s~%s", petdata.hp_aptitude, petdata.hp_aptitude)
                panel.transform:FindChild("ValueText4"):GetComponent(Text).text = string.format("%s~%s", petdata.magic_aptitude, petdata.magic_aptitude)
                panel.transform:FindChild("ValueText5"):GetComponent(Text).text = string.format("%s~%s", petdata.aspd_aptitude, petdata.aspd_aptitude)
            elseif self.manual_type == 2 then
                panel.transform:FindChild("ValueText1"):GetComponent(Text).text = string.format("%s~%s", petdata.phy_aptitude, petdata.phy_aptitude + 30)
                panel.transform:FindChild("ValueText2"):GetComponent(Text).text = string.format("%s~%s", petdata.pdef_aptitude, petdata.pdef_aptitude + 30)
                panel.transform:FindChild("ValueText3"):GetComponent(Text).text = string.format("%s~%s", petdata.hp_aptitude, petdata.hp_aptitude + 30)
                panel.transform:FindChild("ValueText4"):GetComponent(Text).text = string.format("%s~%s", petdata.magic_aptitude, petdata.magic_aptitude + 30)
                panel.transform:FindChild("ValueText5"):GetComponent(Text).text = string.format("%s~%s", petdata.aspd_aptitude, petdata.aspd_aptitude + 30)
            elseif self.manual_type == 3 then
                panel.transform:FindChild("ValueText1"):GetComponent(Text).text = string.format("%s~%s", petdata.phy_aptitude, petdata.phy_aptitude + 60)
                panel.transform:FindChild("ValueText2"):GetComponent(Text).text = string.format("%s~%s", petdata.pdef_aptitude, petdata.pdef_aptitude + 60)
                panel.transform:FindChild("ValueText3"):GetComponent(Text).text = string.format("%s~%s", petdata.hp_aptitude, petdata.hp_aptitude + 60)
                panel.transform:FindChild("ValueText4"):GetComponent(Text).text = string.format("%s~%s", petdata.magic_aptitude, petdata.magic_aptitude + 60)
                panel.transform:FindChild("ValueText5"):GetComponent(Text).text = string.format("%s~%s", petdata.aspd_aptitude, petdata.aspd_aptitude + 60)
            elseif self.manual_type == 4 then
                panel.transform:FindChild("ValueText1"):GetComponent(Text).text = string.format("%s~%s", petdata.phy_aptitude, petdata.phy_aptitude + 90)
                panel.transform:FindChild("ValueText2"):GetComponent(Text).text = string.format("%s~%s", petdata.pdef_aptitude, petdata.pdef_aptitude + 90)
                panel.transform:FindChild("ValueText3"):GetComponent(Text).text = string.format("%s~%s", petdata.hp_aptitude, petdata.hp_aptitude + 90)
                panel.transform:FindChild("ValueText4"):GetComponent(Text).text = string.format("%s~%s", petdata.magic_aptitude, petdata.magic_aptitude + 90)
                panel.transform:FindChild("ValueText5"):GetComponent(Text).text = string.format("%s~%s", petdata.aspd_aptitude, petdata.aspd_aptitude + 90)
            end
        end
    end
    panel.transform:FindChild("GrowthImage"):GetComponent(Image).sprite
        = self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("PetGrowth%s", 5))
    panel.transform:FindChild("GrowthText"):GetComponent(Text).text = string.format("%.2f", petdata.growth_red / 500)

    for i = 1, 5 do
        panel.transform:FindChild(string.format("Recommend%s", i)).gameObject:SetActive(table.containValue(petdata.recommend_aptitudes, i))
    end
end

function PetView_Manual:update_skill()
    if self.petdata == nil then return end

    local transform = self.transform
    local base_skills = self.petdata.base_skills
    local tempList = {}
    for i = 1, #base_skills do
        tempList[i] = { id = base_skills[i][1] }
    end

    local skills = PetManager.Instance.model:ProcessingSkillData({ base_id = self.petdata.id, skills = tempList }).skills
    skills = self.model:makeBreakSkill(self.petdata.id, skills)

    local change_skill_data = DataPet.data_pet_change_skill[self.petdata.id]
    if change_skill_data ~= nil then
        table.insert(skills, 1, { id = change_skill_data.skill_id, isBreak = false })
    end

    for i=1,#skills do
        local skill_id = skills[i].id
        local icon = self.skilllist[i]
        icon.gameObject.name = skill_id
        local skill_data = DataSkill.data_petSkill[string.format("%s_1", skill_id)]
        icon:SetAll(Skilltype.petskill, skill_data)
        icon:ShowLabel(skills[i].isBreak, TI18N("<color='#ffff00'>突破</color>"))
        -- icon:ShowBreak(skills[i].isBreak, TI18N("未激活"))
        icon.gameObject.transform:FindChild("Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultStr, BaseUtils.string_cut(skill_data.name, 12, 9))
    end

    for i=#skills+1,#self.skilllist do
        local icon = self.skilllist[i]
        icon.gameObject.name = ""
        icon:Default()
        icon.skillData = nil
        icon.gameObject.transform:FindChild("Text"):GetComponent(Text).text = ""
    end
end

function PetView_Manual:update_skill_spirt()
    if self.petdata == nil then return end

    local petData = self.petdata
    local data_pet_spirt_score_level0 = self.model:GetPetSpirtScoreBySkillLevel(petData.id, 0)
    if data_pet_spirt_score_level0 == nil then
        return
    end

    local data_pet_spirt_score = self.model:GetPetSpirtScoreBySkillLevel(petData.id, 3)

    local skillData = DataSkill.data_petSkill[string.format("%s_%s", data_pet_spirt_score.skills[1][1], data_pet_spirt_score.skills[1][2])]

    self.skillPanelText1.text = string.format("<color='#ffff00'>%s</color>", skillData.name)
    self.skillPanelText2.text = skillData.desc

    self.skillSpirtPanelSkillIcon:SetAll(Skilltype.petskill, skillData)

    skillData = DataSkill.data_petSkill[BaseUtils.Key(data_pet_spirt_score.skills[1][1], data_pet_spirt_score.skills[1][2])]
    self.skillPanelText3.text = string.format(TI18N("达到<color='#00ff00'>%s评分</color>激活<color='#ffff00'>%s</color>"), data_pet_spirt_score.talent_min, skillData.name)
    self.skillPanelText4.text = TI18N("<color='#00ff00'>附灵可激活</color>")
end

function PetView_Manual:click_manual_access(btn_type, args)
    -- print(string.format("点击了按钮%s,", btn_type, args))
    if self.showtype == 1 and self.manual_type == 2 then return end -- 如果是变异的情况，按钮不做响应

    if btn_type == 1 then
        if RoleManager.Instance.RoleData.lev < 5 then
            NoticeManager.Instance:FloatTipsByString(TI18N("角色达到<color='#ffff00'>5级</color>才能使用市场功能"))
        elseif self.gray_pet_list[self.petdata.id] then
            NoticeManager.Instance:FloatTipsByString(TI18N("携带等级不足，无法前往<color='#ffff00'>宠物商店</color>购买"))
        else
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.market, {2, 5, args})
        end
    elseif btn_type == 2 then
         AutoFarmManager.Instance:tofarm(args)
         self.parent:OnClickClose()
    elseif btn_type == 3 then
         WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godanimal_window, {args})
    elseif btn_type == 4 then
         WindowManager.Instance:OpenWindowById(WindowConfig.WinID.firstrecharge_window)
    elseif btn_type == 5 then
         WindowManager.Instance:OpenWindowById(WindowConfig.WinID.biblemain, {args})
    elseif btn_type == 6 then
         NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#00ff00'>%s</color>只在<color='#ffff00'>特殊活动</color>中少量出现，如若有缘相遇不要错过哦{face_1,22}"), self.petdata.name))
    elseif btn_type == 7 then
         WindowManager.Instance:OpenWindowById(WindowConfig.WinID.petfusewindow, {args})
    end
end

function PetView_Manual:showTips()
    local petdata = self.petdata

    if petdata.genre == 2 then
        TipsManager.Instance:ShowText({gameObject = self.transform:FindChild("InfoPanel/ModlePanel/DescButton").gameObject
            , itemData = { TI18N("神兽天赋：进阶可获得全资质提升<color='#00ff00'>+30</color>") }})
    elseif petdata.genre == 4 then
        TipsManager.Instance:ShowText({gameObject = self.transform:FindChild("InfoPanel/ModlePanel/DescButton").gameObject
            , itemData = { TI18N("珍兽天赋：进阶可获得全资质提升<color='#00ff00'>+30</color>") }})
    end
end

function PetView_Manual:update_tab()
    if self.showtype == 1 then
        self.tabGroup.buttonTab[1].transform:Find("Normal/Text"):GetComponent(Text).text = TI18N("普通")
        self.tabGroup.buttonTab[1].transform:Find("Select/Text"):GetComponent(Text).text = TI18N("普通")
        self.tabGroup.buttonTab[2].transform:Find("Normal/Text"):GetComponent(Text).text = TI18N("变异")
        self.tabGroup.buttonTab[2].transform:Find("Select/Text"):GetComponent(Text).text = TI18N("变异")
        self.tabGroup.buttonTab[3].transform:Find("Normal/Text"):GetComponent(Text).text = TI18N("野生")
        self.tabGroup.buttonTab[3].transform:Find("Select/Text"):GetComponent(Text).text = TI18N("野生")
        self.tabGroup.buttonTab[4].transform:Find("Normal/Text"):GetComponent(Text).text = TI18N("附灵")
        self.tabGroup.buttonTab[4].transform:Find("Select/Text"):GetComponent(Text).text = TI18N("附灵")

        self.tabGroup.buttonTab[5].gameObject:SetActive(false)
    else
        self.tabGroup.buttonTab[1].transform:Find("Normal/Text"):GetComponent(Text).text = TI18N("未提升")
        self.tabGroup.buttonTab[1].transform:Find("Select/Text"):GetComponent(Text).text = TI18N("未提升")
        self.tabGroup.buttonTab[2].transform:Find("Normal/Text"):GetComponent(Text).text = TI18N("提升一次")
        self.tabGroup.buttonTab[2].transform:Find("Select/Text"):GetComponent(Text).text = TI18N("提升一次")
        self.tabGroup.buttonTab[3].transform:Find("Normal/Text"):GetComponent(Text).text = TI18N("提升二次")
        self.tabGroup.buttonTab[3].transform:Find("Select/Text"):GetComponent(Text).text = TI18N("提升二次")
        self.tabGroup.buttonTab[4].transform:Find("Normal/Text"):GetComponent(Text).text = TI18N("提升三次")
        self.tabGroup.buttonTab[4].transform:Find("Select/Text"):GetComponent(Text).text = TI18N("提升三次")
        self.tabGroup.buttonTab[5].transform:Find("Normal/Text"):GetComponent(Text).text = TI18N("附灵")
        self.tabGroup.buttonTab[5].transform:Find("Select/Text"):GetComponent(Text).text = TI18N("附灵")

        self.tabGroup.buttonTab[4].gameObject:SetActive(true)
        self.tabGroup.buttonTab[5].gameObject:SetActive(true)
    end
    self.tabGroup:ChangeTab(1)
end

function PetView_Manual:ChangeTab(index)
    if self.showtype == 1 then
        if index == 4 then
            self.skillSpirtPanel.gameObject:SetActive(true)
            self.attrsPanel.gameObject:SetActive(false)
            self.skillPanel.gameObject:SetActive(false)
            index = 1
            self.spirtTabMark = true
        else
            self.skillSpirtPanel.gameObject:SetActive(false)
            self.attrsPanel.gameObject:SetActive(true)
            self.skillPanel.gameObject:SetActive(true)
            self.spirtTabMark = false
        end
    elseif self.showtype == 2 then
        if index == 5 then
            self.skillSpirtPanel.gameObject:SetActive(true)
            self.attrsPanel.gameObject:SetActive(false)
            self.skillPanel.gameObject:SetActive(false)
            index = 1
            self.spirtTabMark = true
        else
            self.skillSpirtPanel.gameObject:SetActive(false)
            self.attrsPanel.gameObject:SetActive(true)
            self.skillPanel.gameObject:SetActive(true)
            self.spirtTabMark = false
        end
    end

    self.manual_type = index

    self:updata_base()
    self:update_model()
    self:update_qualityattrs()
end

function PetView_Manual:close_all_tips()
end

function PetView_Manual:onHandBookButtonClick()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.strategy_window, {1, 3, 2})
end