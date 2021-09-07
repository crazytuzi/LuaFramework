-- @author hzf
-- @date 2016年7月7日,星期四

EncyclopediaPet = EncyclopediaPet or BaseClass(BasePanel)


function EncyclopediaPet:__init(parent)
    self.model = EncyclopediaManager.Instance.model
    self.parent = parent
    self.name = "EncyclopediaPet"

    self.resList = {
        {file = AssetConfig.pet_pedia, type = AssetType.Main},
        {file = AssetConfig.petevaluation_texture,type = AssetType.Dep},
        {file = AssetConfig.pet_textures, type = AssetType.Dep},
        {file = AssetConfig.attr_icon, type = AssetType.Dep},
    }
    self.currPetData = nil
    self.currGroup = 1
    self.currType = 1
    self.petdata = {}
    self.petdata[1] = {}
    self.petdata[2] = {}
    self.headLoaderList = {}
    self.skilllist = {}
    self.selectgo = nil

    local maxlev = 10000
    local role_lve = RoleManager.Instance.RoleData.lev
    if role_lve < 15 then
        maxlev = 15
    elseif role_lve < 35 then
        maxlev = 35
    elseif role_lve < 45 then
        maxlev = 45
    elseif role_lve < 55 then
        maxlev = 55
    elseif role_lve < 65 then
        maxlev = 65
    elseif role_lve < 75 then
        maxlev = 75
    elseif role_lve < 85 then
        maxlev = 85
    elseif role_lve < 95 then
        maxlev = 95
    elseif role_lve < 105 then
        maxlev = 105
    elseif role_lve < 115 then
        maxlev = 115
    elseif role_lve < 125 then
        maxlev = 125
    elseif role_lve < 135 then
        maxlev = 135
    end

    for k,v in pairs(DataPet.data_pet) do
        if v.genre ~= 6 and v.show_manual == 1 then
            if v.genre ~= 2 and v.genre ~= 4 and maxlev >= v.manual_level then
                table.insert(self.petdata[1], v)
            elseif maxlev >= v.manual_level then
                table.insert(self.petdata[2], v)
            end
        end
    end

    table.sort(self.petdata[1], function(a,b)
        return a.manual_level < b.manual_level or (a.manual_level < b.manual_level and a.id<b.id)
    end)
    table.sort(self.petdata[2], function(a,b)
        return a.manual_level < b.manual_level or (a.manual_level < b.manual_level and a.id<b.id)
    end)
    self.gray_pet_list = {}
    for k,v in pairs(DataPet.data_pet) do
        if v.manual_type == self.showtype and v.manual_level <= manual_lev then
            if v.manual_level < manual_lev then
                table.insert(pet_list, {data = v, gray = false})
                self.gray_pet_list[v.id] = false
            else
                table.insert(pet_list, {data = v, gray = true})
                self.gray_pet_list[v.id] = true
            end
        end
    end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function EncyclopediaPet:__delete()
    self.OnHideEvent:Fire()
    if self.tabgroup ~= nil then
        self.tabgroup:DeleteMe()
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

    if self.skilllist ~= nil then
        for k,v in ipairs(self.skilllist) do
            v:DeleteMe()
        end
    end

    if self.Layout1 ~= nil then
        self.Layout1:DeleteMe()
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function EncyclopediaPet:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pet_pedia))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    if self.isHiden then
        self.gameObject:SetActive(false)
    end

    self.ToggleList = t:Find("ToggleList")
    self.Background = t:Find("ToggleList/Background").gameObject
    self.Label = t:Find("ToggleList/Label"):GetComponent(Text)
    self.ToggleList:GetComponent(Button).onClick:AddListener(function()
        local open = self.Background.activeSelf
        self.Background:SetActive(open == false)
        self.LevList:SetActive(open == false)
    end)

    self.LevList = t:Find("LevList").gameObject
    self.LevListbtn = t:Find("LevList/Button"):GetComponent(Button)
    self.LevListbtn.onClick:AddListener(function()
        self.Background:SetActive(false)
        self.LevList:SetActive(false)
    end)
    self.LevListCon = t:Find("LevList/Mask/Scroll")
    self.LevListItem = t:Find("LevList/Mask/Scroll"):GetChild(0).gameObject
    self.LevListItem:SetActive(false)

    self.ItemListCon = t:Find("ItemList/Mask/Scroll")
    self.ItemListItem = t:Find("ItemList/Mask/Scroll"):GetChild(0).gameObject
    self.tabCon = t:Find("Right/TabButtonGroup")

    self.PetName = t:Find("Right/Name"):GetComponent(Text)
    local soltPanel = t:Find("Right/SkillPanel/SoltPanel").gameObject
    local textObject = t:Find("Right/SkillPanel/SkillText").gameObject

    self.evaluationbtn = t:Find("Right/EvaluationButton").gameObject:GetComponent(Button)
    self.evaluationbtn.onClick:AddListener(function()
         WindowManager.Instance:OpenWindowById(WindowConfig.WinID.petevaluation,{self.currPetData,1})
     end
    )
    for i=1, 6 do
        local slot = SkillSlot.New()
        UIUtils.AddUIChild(soltPanel, slot.gameObject)
        table.insert(self.skilllist, slot)

        local text = GameObject.Instantiate(textObject)
        UIUtils.AddUIChild(slot, text)
        text.name = "Text"
        text:GetComponent(RectTransform).anchoredPosition = Vector2(0, -40)
    end
    local setting1 = {
        axis = BoxLayoutAxis.Y
        ,spacing = 0
        ,Left = 4
        ,Top = 0
    }
    self.Layout1 = LuaBoxLayout.New(self.LevListCon, setting1)
    for i=1,2 do
        local item = GameObject.Instantiate(self.LevListItem)
        self.Layout1:AddCell(item)
        if i == 1 then
            item.transform:Find("I18NText"):GetComponent(Text).text = TI18N("普通宠物")
            item.transform:GetComponent(Button).onClick:AddListener(function()
                self.Label.text = TI18N("普通宠物")
                self.currGroup = 1
                self.Background:SetActive(false)
                self.LevList:SetActive(false)
                self:InitPetList()
            end)
        else
            item.transform:Find("I18NText"):GetComponent(Text).text = TI18N("神兽")
            item.transform:GetComponent(Button).onClick:AddListener(function()
                self.Label.text = TI18N("神兽")
                self.currGroup = 2
                self.Background:SetActive(false)
                self.LevList:SetActive(false)
                self:InitPetList()
            end)
        end
    end
    self.Label.text = TI18N("普通宠物")
    self.currGroup = 1
    self.Background:SetActive(false)
    self.LevList:SetActive(false)
    self:InitPetList()
    self.tabgroup = TabGroup.New(self.tabCon.gameObject, function (tab) self:OnTabChange(tab) end)
end

function EncyclopediaPet:OnTabChange(index)
    self.currType = index
    self:SetPetData(self.currPetData)
end

-- function EncyclopediaPet:OnInitCompleted()
--     self.OnOpenEvent:Fire()
-- end

function EncyclopediaPet:OnOpen()
    self:RemoveListeners()
end

function EncyclopediaPet:OnHide()
    self:RemoveListeners()
end

function EncyclopediaPet:RemoveListeners()
end

function EncyclopediaPet:InitPetList()
    local oldList = {}
    for i=1, self.ItemListCon.childCount do
        self.ItemListCon:GetChild(i-1).gameObject:SetActive(false)
        table.insert(oldList, self.ItemListCon:GetChild(i-1))
    end
    local petList = self.petdata[self.currGroup]
    BaseUtils.dump(petList,"宠物大全================================================================")
    for i,v in ipairs(petList) do
        local Petitem = nil
        if #oldList > 0 then
            Petitem = oldList[#oldList]
            table.remove(oldList)
            Petitem.transform:SetParent(self.ItemListCon)
        else
            Petitem = GameObject.Instantiate(self.ItemListItem)
            Petitem.transform:SetParent(self.ItemListCon)
        end
        Petitem.gameObject:SetActive(true)
        Petitem.transform.localScale = Vector3.one

        local loaderId = Petitem.transform:Find("Head"):GetComponent(Image).gameObject:GetInstanceID()
        if self.headLoaderList[loaderId] == nil then
            self.headLoaderList[loaderId] = SingleIconLoader.New(Petitem.transform:Find("Head"):GetComponent(Image).gameObject)
        end
        self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,v.head_id)
        Petitem.transform:Find("Head"):GetComponent(Image).color = Color(1,1,1,1)

        -- Petitem.transform:Find("Head"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(v.head_id), tostring(v.head_id))
        if v.need_lev_break > 0 then
            Petitem.transform:Find("Lv"):GetComponent(Text).text = string.format("突破%s", tostring(v.manual_level))
        else
            Petitem.transform:Find("Lv"):GetComponent(Text).text = v.manual_level
        end
        Petitem.transform:Find("Lv").sizeDelta = Vector2(math.ceil(Petitem.transform:Find("Lv"):GetComponent(Text).preferredWidth), 20)
        if v.manual_level > RoleManager.Instance.RoleData.lev or v.need_lev_break > RoleManager.Instance.RoleData.lev_break_times then
            Petitem.transform:Find("Lv"):GetComponent(Text).color = Color(1,0,0)
        else
            Petitem.transform:Find("Lv"):GetComponent(Text).color = Color(1,1,1)
        end
        Petitem.transform:Find("numbg").sizeDelta = Petitem.transform:Find("Lv").sizeDelta
        Petitem.transform:Find("Select").gameObject:SetActive(false)
        Petitem.transform:GetComponent(Button).onClick:RemoveAllListeners()
        Petitem.transform:GetComponent(Button).onClick:AddListener(function()
            if self.selectgo ~= nil then
                self.selectgo:SetActive(false)
            end
            self.selectgo = Petitem.transform:Find("Select").gameObject
            self.selectgo:SetActive(true)
            self:SetPetData(v)
        end)
        if i == 1 then
            if self.selectgo ~= nil then
                self.selectgo:SetActive(false)
            end
            self.selectgo = Petitem.transform:Find("Select").gameObject
            self.selectgo:SetActive(true)

            self:SetPetData(v)
        end
    end
end

function EncyclopediaPet:SetPetData(data)
    if data == nil then return end
    self.currPetData = data
    local transform = self.transform
    local petdata = data
    local panel = transform:FindChild("Right/AttrsPanel").gameObject
    self.PetName.text = data.name
    self.tabCon.gameObject:SetActive(self.currGroup == 1)
    if petdata.hide_aptitude == 1 then
        panel.transform:FindChild("ValueText1"):GetComponent(Text).text = "1??0~1??0"
        panel.transform:FindChild("ValueText2"):GetComponent(Text).text = "1??0~1??0"
        panel.transform:FindChild("ValueText3"):GetComponent(Text).text = "1??0~1??0"
        panel.transform:FindChild("ValueText4"):GetComponent(Text).text = "1??0~1??0"
        panel.transform:FindChild("ValueText5"):GetComponent(Text).text = "1??0~1??0"
    else
        if self.currGroup == 1 then
            if self.currType == 1 then
                panel.transform:FindChild("ValueText1"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.phy_aptitude * 0.8 + 0.5), petdata.phy_aptitude)
                panel.transform:FindChild("ValueText2"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.pdef_aptitude * 0.8 + 0.5), petdata.pdef_aptitude)
                panel.transform:FindChild("ValueText3"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.hp_aptitude * 0.8 + 0.5), petdata.hp_aptitude)
                panel.transform:FindChild("ValueText4"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.magic_aptitude * 0.8 + 0.5), petdata.magic_aptitude)
                panel.transform:FindChild("ValueText5"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.aspd_aptitude * 0.8 + 0.5), petdata.aspd_aptitude)
            elseif self.currType == 2 then
                panel.transform:FindChild("ValueText1"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.phy_aptitude * 0.8 * 1.02 + 0.5), math.floor(petdata.phy_aptitude * 1.02 + 0.5))
                panel.transform:FindChild("ValueText2"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.pdef_aptitude * 0.8 * 1.02 + 0.5), math.floor(petdata.pdef_aptitude * 1.02 + 0.5))
                panel.transform:FindChild("ValueText3"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.hp_aptitude * 0.8 * 1.02 + 0.5), math.floor(petdata.hp_aptitude * 1.02 + 0.5))
                panel.transform:FindChild("ValueText4"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.magic_aptitude * 0.8 * 1.02 + 0.5), math.floor(petdata.magic_aptitude * 1.02 + 0.5))
                panel.transform:FindChild("ValueText5"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.aspd_aptitude * 0.8 * 1.02 + 0.5), math.floor(petdata.aspd_aptitude * 1.02 + 0.5))
            elseif self.currType == 3 then
                panel.transform:FindChild("ValueText1"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.phy_aptitude * 0.81 + 0.5), math.floor(petdata.phy_aptitude * 0.82 + 0.5))
                panel.transform:FindChild("ValueText2"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.pdef_aptitude * 0.81 + 0.5), math.floor(petdata.pdef_aptitude * 0.82 + 0.5))
                panel.transform:FindChild("ValueText3"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.hp_aptitude * 0.81 + 0.5), math.floor(petdata.hp_aptitude * 0.82 + 0.5))
                panel.transform:FindChild("ValueText4"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.magic_aptitude * 0.81 + 0.5), math.floor(petdata.magic_aptitude * 0.82 + 0.5))
                panel.transform:FindChild("ValueText5"):GetComponent(Text).text = string.format("%s~%s", math.floor(petdata.aspd_aptitude * 0.81 + 0.5), math.floor(petdata.aspd_aptitude * 0.82 + 0.5))
            end
        else
            -- if self.currType == 1 then
                panel.transform:FindChild("ValueText1"):GetComponent(Text).text = string.format("%s~%s", petdata.phy_aptitude, petdata.phy_aptitude)
                panel.transform:FindChild("ValueText2"):GetComponent(Text).text = string.format("%s~%s", petdata.pdef_aptitude, petdata.pdef_aptitude)
                panel.transform:FindChild("ValueText3"):GetComponent(Text).text = string.format("%s~%s", petdata.hp_aptitude, petdata.hp_aptitude)
                panel.transform:FindChild("ValueText4"):GetComponent(Text).text = string.format("%s~%s", petdata.magic_aptitude, petdata.magic_aptitude)
                panel.transform:FindChild("ValueText5"):GetComponent(Text).text = string.format("%s~%s", petdata.aspd_aptitude, petdata.aspd_aptitude)
            -- elseif self.currType == 2 then
            --     panel.transform:FindChild("ValueText1"):GetComponent(Text).text = string.format("%s~%s", petdata.phy_aptitude, petdata.phy_aptitude + 30)
            --     panel.transform:FindChild("ValueText2"):GetComponent(Text).text = string.format("%s~%s", petdata.pdef_aptitude, petdata.pdef_aptitude + 30)
            --     panel.transform:FindChild("ValueText3"):GetComponent(Text).text = string.format("%s~%s", petdata.hp_aptitude, petdata.hp_aptitude + 30)
            --     panel.transform:FindChild("ValueText4"):GetComponent(Text).text = string.format("%s~%s", petdata.magic_aptitude, petdata.magic_aptitude + 30)
            --     panel.transform:FindChild("ValueText5"):GetComponent(Text).text = string.format("%s~%s", petdata.aspd_aptitude, petdata.aspd_aptitude + 30)
            -- elseif self.currType == 3 then
            --     panel.transform:FindChild("ValueText1"):GetComponent(Text).text = string.format("%s~%s", petdata.phy_aptitude, petdata.phy_aptitude + 60)
            --     panel.transform:FindChild("ValueText2"):GetComponent(Text).text = string.format("%s~%s", petdata.pdef_aptitude, petdata.pdef_aptitude + 60)
            --     panel.transform:FindChild("ValueText3"):GetComponent(Text).text = string.format("%s~%s", petdata.hp_aptitude, petdata.hp_aptitude + 60)
            --     panel.transform:FindChild("ValueText4"):GetComponent(Text).text = string.format("%s~%s", petdata.magic_aptitude, petdata.magic_aptitude + 60)
            --     panel.transform:FindChild("ValueText5"):GetComponent(Text).text = string.format("%s~%s", petdata.aspd_aptitude, petdata.aspd_aptitude + 60)
            -- elseif self.currType == 4 then
            --     panel.transform:FindChild("ValueText1"):GetComponent(Text).text = string.format("%s~%s", petdata.phy_aptitude, petdata.phy_aptitude + 90)
            --     panel.transform:FindChild("ValueText2"):GetComponent(Text).text = string.format("%s~%s", petdata.pdef_aptitude, petdata.pdef_aptitude + 90)
            --     panel.transform:FindChild("ValueText3"):GetComponent(Text).text = string.format("%s~%s", petdata.hp_aptitude, petdata.hp_aptitude + 90)
            --     panel.transform:FindChild("ValueText4"):GetComponent(Text).text = string.format("%s~%s", petdata.magic_aptitude, petdata.magic_aptitude + 90)
            --     panel.transform:FindChild("ValueText5"):GetComponent(Text).text = string.format("%s~%s", petdata.aspd_aptitude, petdata.aspd_aptitude + 90)
            -- end
        end
    end
    panel.transform:FindChild("GrowthImage"):GetComponent(Image).sprite
        = self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("PetGrowth%s", 5))
    panel.transform:FindChild("GrowthText"):GetComponent(Text).text = string.format("%.2f", petdata.growth_red / 500)

    for i = 1, 5 do
        panel.transform:FindChild(string.format("Recommend%s", i)).gameObject:SetActive(table.containValue(petdata.recommend_aptitudes, i))
    end
    self:SetPetSkill()
    self:updata_base()
end


function EncyclopediaPet:updata_base()
    if self.currPetData == nil then return end

    local transform = self.transform
    local petdata = self.currPetData


    local panel = transform:Find("Right/AccessPanel").gameObject
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
            btn:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        else
            btn:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
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
            btn:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        else
            btn:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        end
    else
        btn:SetActive(false)
    end

    if self.currGroup == 1 then
        if self.currType == 1 then
            panel.transform:FindChild("Button1").gameObject:SetActive(#manual_access > 0)
            panel.transform:FindChild("Button2").gameObject:SetActive(#manual_access > 1)
            panel.transform:FindChild("DescText").gameObject:SetActive(false)
        elseif self.currType == 2 then
            panel.transform:FindChild("Button1").gameObject:SetActive(false)
            panel.transform:FindChild("Button2").gameObject:SetActive(false)
            panel.transform:FindChild("DescText").gameObject:SetActive(true)
            panel.transform:FindChild("DescText"):GetComponent(Text).text = TI18N("通过<color='#00ff00'>【洗髓】</color>有几率触发变异")
        elseif self.currType == 3 then
            panel.transform:FindChild("Button1").gameObject:SetActive(#manual_access > 0)
            panel.transform:FindChild("Button2").gameObject:SetActive(#manual_access > 1)
            panel.transform:FindChild("DescText").gameObject:SetActive(false)
        end
    elseif self.currGroup == 2 then
        -- if self.currType == 1 then
            panel.transform:FindChild("Button1").gameObject:SetActive(#manual_access > 0)
            panel.transform:FindChild("Button2").gameObject:SetActive(#manual_access > 1)
            panel.transform:FindChild("DescText").gameObject:SetActive(false)
        -- else
        --     panel.transform:FindChild("Button1").gameObject:SetActive(false)
        --     panel.transform:FindChild("Button2").gameObject:SetActive(false)
        --     panel.transform:FindChild("DescText").gameObject:SetActive(true)
        --     panel.transform:FindChild("DescText"):GetComponent(Text).text = "通过<color='#00ff00'>【进阶】</color>可获得"
        -- end
    end
end

function EncyclopediaPet:SetPetSkill()
    if self.currPetData == nil then return end

    local transform = self.transform
    local base_skills = self.currPetData.base_skills
    BaseUtils.dump(base_skills)

    local tempList = {}
    for i = 1, #base_skills do
        tempList[i] = { id = base_skills[i][1] }
    end

    local skills = PetManager.Instance.model:makeBreakSkill(self.currPetData.id, tempList)


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


function EncyclopediaPet:click_manual_access(btn_type, args)
    -- print(string.format("点击了第%s个按钮", btn_type))
    if self.currGroup == 1 and self.currType == 2 then return end -- 如果是变异的情况，按钮不做响应

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
    end
end
