-- @author 黄耀聪
-- @date 2017年2月27日

GuildSiegeForce = GuildSiegeForce or BaseClass(BasePanel)

function GuildSiegeForce:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.guildList = {}
    self.assetWrapper = assetWrapper

    self.updateListener = function() self:InitTempData() self:Reload() end

    self.guardSelectListener = function(index) self:SelectGuard(index) end
    self.formationSelectListener = function(index) self:SelectFormat(index) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.tempForce = {
        pet_id = nil,
        formation = nil,
        formation_lev = nil,
        guard_id_1 = nil,
        guard_id_2 = nil,
        guard_id_3 = nil,
        guard_id_4 = nil,
    }

    self:InitPanel()
end

function GuildSiegeForce:__delete()
    self.OnHideEvent:Fire()

    self.saveImage.sprite = nil

    if self.headLoader ~= nil then
        self.headLoader:DeleteMe()
        self.headLoader = nil
    end

    if self.guildList ~= nil then
        for _,v in pairs(self.guildList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
    end

    GuildSiegeForceGuild.__delete(self.pet)

    if self.guardSelect ~= nil then
        self.guardSelect:DeleteMe()
        self.guardSelect = nil
    end
    if self.formationSelect ~= nil then
        self.formationSelect:DeleteMe()
        self.formationSelect = nil
    end

    self.assetWrapper = nil
end

function GuildSiegeForce:InitPanel()
    local t = self.gameObject.transform
    self.transform = t

    t:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)

    t = t:Find("Main")

    -- 模拟一个GuildSiegeForceGuild
    self.pet = {
        transform = t:Find("Pet"),
        iconImage = t:Find("Pet/Icon/Image"):GetComponent(Image),
        attrObj = t:Find("Pet/Icon/Attr").gameObject,
        attrText = t:Find("Pet/Icon/Attr/Text"):GetComponent(Text),
        arrowImage1 = t:Find("Pet/Icon/Attr/Arrow1"):GetComponent(Image),
        arrowImage2 = t:Find("Pet/Icon/Attr/Arrow2"):GetComponent(Image),
        addObj = t:Find("Pet/Icon/Add").gameObject,
        btn = t:Find("Pet/Icon"):GetComponent(Button),
    }

    local guildContainer = t:Find("Guild/Container")
    for i=1,4 do
        self.guildList[i] = GuildSiegeForceGuild.New(self.model, guildContainer:GetChild(i - 1).gameObject)
    end

    self.formationBtn = t:Find("Formation/Format"):GetComponent(Button)
    self.formationText = t:Find("Formation/Format/Text"):GetComponent(Text)
    self.saveBtn = t:Find("Formation/Save"):GetComponent(Button)

    self.guardSelect = ArenaGuardSelect.New(self.model, self.transform:Find("TeamChangeGuard").gameObject, self.assetWrapper, self.guardSelectListener)
    self.formationSelect = ArenaFormationSelect.New(self.model, self.transform:Find("FormatChangeGuard").gameObject, self.assetWrapper, self.formationSelectListener)

    self.saveBtn.onClick:AddListener(function() self:OnSave() end)
    self.saveImage = self.saveBtn.gameObject:GetComponent(Image)
    self.saveText = self.saveBtn.transform:Find("Text"):GetComponent(Text)

    self.guardSelect:Hiden()
    self.formationSelect:Hiden()
end

function GuildSiegeForce:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildSiegeForce:OnOpen()
    self:StatusSave(false)

    self:RemoveListeners()
    GuildSiegeManager.Instance.onUpdateMy:AddListener(self.updateListener)
    -- GuildSiegeManager.Instance.onUpdateMy:AddListener(self.petListener)
    -- GuildSiegeManager.Instance.onUpdateMy:AddListener(self.formationListener)
    -- GuildSiegeManager.Instance.onUpdateMy:AddListener(self.guardListener)

    self:InitTempData()

    self:Reload()
end

function GuildSiegeForce:Reload()
    self:UpdateGuard()
    self:UpdatePet()
    self:UpdateFormation()
end

function GuildSiegeForce:OnHide()
    self:RemoveListeners()
    GuildSiegeManager.Instance.onUpdateStatus:Fire()
end

function GuildSiegeForce:RemoveListeners()
    GuildSiegeManager.Instance.onUpdateMy:RemoveListener(self.updateListener)
    -- GuildSiegeManager.Instance.onUpdateMy:RemoveListener(self.petListener)
    -- GuildSiegeManager.Instance.onUpdateMy:RemoveListener(self.formationListener)
    -- GuildSiegeManager.Instance.onUpdateMy:RemoveListener(self.guardListener)
end

-- 更新阵型信息
function GuildSiegeForce:UpdateFormation()
    local id = self.tempForce.formation
    local lev = self.tempForce.formation_lev

    local baseData = DataFormation.data_list[id .. "_" .. lev]
    for i,v in ipairs(self.guildList) do
        v:SetAttr(baseData["attr_" .. (i + 1)])
    end
    GuildSiegeForceGuild.SetAttr(self.pet, baseData.pet_attr)

    self.formationText.text = string.format("%s Lv.%s", baseData.name, tostring(lev))
    self.formationBtn.onClick:RemoveAllListeners()
    self.formationBtn.onClick:AddListener(function() self.formationSelect:Show(FormationManager.Instance.formationList, (self.model.myCastle or {}).formation or 1) end)
end

-- 更新宠物信息
function GuildSiegeForce:UpdatePet()
    local base_id = nil
    for _,v in ipairs(PetManager.Instance.model.petlist) do
        if self.tempForce.pet_id == v.id then
            base_id = v.base_id
            break
        end
    end
    if base_id == nil then
        for _,v in ipairs(PetManager.Instance.model.petlist) do
            if self.tempForce.pet_id == v.base_id then
                base_id = v.base_id
                break
            end
        end
    end

    self.pet.btn.onClick:RemoveAllListeners()
    if base_id == nil then
        self.pet.iconImage.gameObject:SetActive(false)
        self.pet.addObj:SetActive(true)
    else
        self.pet.iconImage.gameObject:SetActive(true)
        self.pet.addObj:SetActive(false)
        if self.headLoader == nil then
                self.headLoader = SingleIconLoader.New(self.pet.iconImage.gameObject)
        end
        self.headLoader:SetSprite(SingleIconType.Pet,DataPet.data_pet[base_id].head_id)
        -- self.pet.iconImage.sprite = PreloadManager.Instance:GetPetSprite(DataPet.data_pet[base_id].head_id)
    end
    self.pet.btn.onClick:AddListener(function() self:ClickPet() end)
end

function GuildSiegeForce:ClickPet()
    local exceptionList = {}
    local attachPetList = PetManager.Instance.model:GetAttachPetList()
    for _, value in ipairs(attachPetList) do
        table.insert(exceptionList, value.id)
    end
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.petselect, { function() end, function(data) self:SelectPetCallBack(data) end, 1, exceptionList})
end

function GuildSiegeForce:SelectPetCallBack(data)
    if data ~= nil then
        -- if (self.model.myCastle or {}).pet_id == data.id then
        --     NoticeManager.Instance:FloatTipsByString(TI18N("当前宠物已出阵"))
        -- else
            self.tempForce.pet_id = data.id
            -- GuildSiegeManager.Instance:send19107(data.id)
        -- end
    end
    self:UpdatePet()
end

-- 更新阵型信息
function GuildSiegeForce:UpdateGuard()
    -- BaseUtils.dump(self.tempForce, "tempForce")
    local guards = {
        {guard_id = self.tempForce.guard_id_1, war_id = 2},
        {guard_id = self.tempForce.guard_id_2, war_id = 3},
        {guard_id = self.tempForce.guard_id_3, war_id = 4},
        {guard_id = self.tempForce.guard_id_4, war_id = 5},
    }
    for i=1,4 do
        self.guildList[i].btn.onClick:RemoveAllListeners()
        if guards[i] == nil or guards[i].guard_id == 0 then
            self.guildList[i].addObj:SetActive(true)
            self.guildList[i].iconImage.gameObject:SetActive(false)
        else
            self.guildList[i].addObj:SetActive(false)
            self.guildList[i].iconImage.gameObject:SetActive(true)
            self.guildList[i].iconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.guard_head, tostring(guards[i].guard_id))
        end
        local j = i
        self.guildList[i].btn.onClick:AddListener(function()
        self.guardWarId = j self.guardSelect:Show(BaseUtils.copytab(ShouhuManager.Instance.model.my_sh_list), j, guards[j], {id = ((self.model.myCastle or {}).formation or 1), lev = (self.model.myCastle or {}).formation_lev or 1}, Vector2(238 + (j - 1) * 74, 60)) end)
    end
    self:UpdateFormation()
end

function GuildSiegeForce:InitTempData()
    -- 宠物id

    BaseUtils.dump(self.model.myCastle, "self.model.myCastle")
    local base_id = (self.model.myCastle or {}).pet_id
    self.tempForce.pet_id = 0
    for i,v in ipairs(PetManager.Instance.model.petlist) do
        if v.base_id == base_id then
            self.tempForce.pet_id = v.id
            break
        end
    end

    -- 阵型
    self.tempForce.formation = (self.model.myCastle or {}).formation or 1
    self.tempForce.formation_lev = (self.model.myCastle or {}).formation_lev or 1

    -- 守护
    for i=1,4 do
        self.tempForce["guard_id_" .. i] = 0
    end
    for i=1,4 do
        local g = ((self.model.myCastle or {}).guards or {})[i]
        if g ~= nil then
            self.tempForce["guard_id_" .. (g.war_id - 1)] = g.guard_id
        end
    end
end

function GuildSiegeForce:SelectGuard(index)
    local model = self.model
    self.guardSelect:Hiden()
    self.formationSelect:Hiden()

    local guards = (model.myCastle or {}).guards or {}

    self.guardSelect:UnSelect(self.guardSelect.lastSelect)
    local tab = self.guardSelect.selectTab
    if self.guardSelect.lastSelect == nil then
        tab[index] = true
        self.guardSelect.lastSelect = index
    elseif self.guardSelect.lastSelect == index then
        tab[index] = false
        self.guardSelect.lastSelect = nil
    else
        tab[self.guardSelect.lastSelect] = false
        tab[index] = true
        self.guardSelect.lastSelect = index
    end
    self.guardSelect:Select(self.guardSelect.lastSelect)

    local selectIndex = self.guardSelect:GetSelection()

    -- for i=1,4 do
    --     local g = guards[i]
    --     if g ~= nil then
    --         self.tempForce["guard_id_" .. (g.war_id - 1)] = g.guard_id
    --     end
    -- end

    if selectIndex ~= nil then
        local base_id = ShouhuManager.Instance.model.my_sh_list[selectIndex].base_id

        local swap_base_id = nil
        -- BaseUtils.dump(self.tempForce, "self.tempForce")
        -- print(self.guardWarId)
        for i=1,4 do
            if guards[i] ~= nil and (i == self.guardWarId) then
                -- swap_base_id = guards[i].guard_id
                swap_base_id = self.tempForce["guard_id_" .. i]
                break
            end
        end

        -- print(swap_base_id)

        local swap_index = nil
        for i=1,4 do
            if base_id == self.tempForce["guard_id_" .. i] then
                swap_index = i
                break
            end
        end
        self.tempForce["guard_id_" .. self.guardWarId] = base_id or 0
        if swap_index ~= nil then
            self.tempForce["guard_id_" .. swap_index] = swap_base_id or 0
        end

        -- BaseUtils.dump(self.tempForce, "<colo=#ffff00>self.tempForce</color>")
        -- GuildSiegeManager.Instance:send19104(self.tempForce)
    else
        self.tempForce["guard_id_" .. self.guardWarId] = 0
        NoticeManager.Instance:FloatTipsByString(TI18N("该守护已经上阵"))
    end

    self:UpdateGuard()
    self:StatusSave(true)
end

function GuildSiegeForce:SelectFormat(index)
    self.guardSelect:Hiden()
    self.formationSelect:Hiden()

    self.formationSelect:UnSelect(self.formationSelect.lastSelect)
    local tab = self.formationSelect.selectTab
    if self.formationSelect.lastSelect ~= nil then
        tab[self.formationSelect.lastSelect] = false
    end
    tab[index] = true
    self.formationSelect.lastSelect = index
    self.formationSelect:Select(self.formationSelect.lastSelect)

    local selectIndex = self.formationSelect:GetSelection()
    if selectIndex ~= nil then
        self.tempForce["formation"] = FormationManager.Instance.formationList[selectIndex].id
        self.tempForce["formation_lev"] = FormationManager.Instance.formationList[selectIndex].lev
    end
    -- GuildSiegeManager.Instance:send19104(self.tempForce)
    self:UpdateFormation()
    self:StatusSave(true)
end

function GuildSiegeForce:OnSave()
    local force = {
        formation = self.tempForce.formation,
        guard_id_1 = self.tempForce.guard_id_1,
        guard_id_2 = self.tempForce.guard_id_2,
        guard_id_3 = self.tempForce.guard_id_3,
        guard_id_4 = self.tempForce.guard_id_4,
    }
    GuildSiegeManager.Instance:send19104(force)
    GuildSiegeManager.Instance:send19107(self.tempForce.pet_id)
end

function GuildSiegeForce:StatusSave(bool)
    if bool then
        self.saveImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        self.saveText.color = ColorHelper.DefaultButton2
    else
        self.saveImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.saveText.color = ColorHelper.DefaultButton3
    end
end


-- 阵法单位信息
GuildSiegeForceGuild = GuildSiegeForceGuild or BaseClass()

function GuildSiegeForceGuild:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject

    local t = gameObject.transform
    self.transform = t
    self.addObj = t:Find("Add").gameObject
    self.iconImage = t:Find("Image"):GetComponent(Image)
    self.attrObj = t:Find("Attr").gameObject
    self.attrText = t:Find("Attr/Text"):GetComponent(Text)
    self.arrowImage1 = t:Find("Attr/Arrow1"):GetComponent(Image)
    self.arrowImage2 = t:Find("Attr/Arrow2"):GetComponent(Image)
    self.btn = gameObject:GetComponent(Button)
end

function GuildSiegeForceGuild:__delete()
    self.iconImage.sprite = nil
    self.arrowImage2.sprite = nil
    self.arrowImage1.sprite = nil
end

function GuildSiegeForceGuild:SetAttr(effects)
    local attrString = nil
    local effect_data = effects[1]
    if effect_data == nil then
        self.arrowImage1.gameObject:SetActive(false)
    else
        attrString = KvData.attr_name_show[effect_data.attr_name]
        if effect_data.val > 0 then
            self.arrowImage1.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow2")
        else
            self.arrowImage1.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow1")
        end
        self.arrowImage1.gameObject:SetActive(true)
    end
    -- 属性2
    effect_data = effects[2]
    if effect_data == nil then
        self.arrowImage2.gameObject:SetActive(false)
    else
        attrString = string.format("%s\n%s", attrString, KvData.attr_name_show[effect_data.attr_name])
        if effect_data.val > 0 then
            self.arrowImage2.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow2")
        else
            self.arrowImage2.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow1")
        end
        self.arrowImage2.gameObject:SetActive(true)
    end

    self.attrText.text = attrString
    self.arrowImage1.transform.sizeDelta = Vector2(24, 24)
    self.arrowImage2.transform.sizeDelta = Vector2(24, 24)

    if #effects == 0 then
        self.attrObj:SetActive(false)
    elseif #effects == 1 then
        self.attrObj:SetActive(true)
        self.arrowImage1.transform.anchoredPosition = Vector2(20.9, 3)
    else
        self.attrObj:SetActive(true)
        self.arrowImage1.transform.anchoredPosition = Vector2(20.9, 12.4)
    end
end
