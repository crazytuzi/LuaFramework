-- ---------------------------
-- 装备扩展显示
-- hosr
-- ---------------------------
EquipTipsExt = EquipTipsExt or BaseClass()

function EquipTipsExt:__init(gameObject, parent)
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    self.gameObject:SetActive(false)
    self.parent = parent


    self.minScale = 0.8
    self.maxScale = 1.05

    self.width = 315
    self.height = 0

    self.txtTab = {}

    self:InitPanel()
end

function EquipTipsExt:__delete()
    if self.itemCell ~= nil then
        self.itemCell:DeleteMe()
        self.itemCell = nil
    end
end

function EquipTipsExt:InitPanel()
    self.rect = self.gameObject:GetComponent(RectTransform)

    local head = self.transform:Find("HeadArea")
    self.itemCell = ItemSlot.New(head:Find("ItemSlot").gameObject)
    self.itemCell:SetNotips()
    self.itemCell:ShowEnchant(true)
    self.itemCell:ShowLevel(true)
    self.nameTxt = head:Find("Name"):GetComponent(Text)
    self.levelTxt = head:Find("Level"):GetComponent(Text)
    self.bindObj = head:Find("Bind").gameObject
    self.bindObj:SetActive(false)



    self.midImgArrow = self.transform:Find("ImgArrow").gameObject

    local mid = self.transform:Find("MidArea")
    self.midTransform = mid.transform
    self.midRect = mid.gameObject:GetComponent(RectTransform)
    self.ScrollRect = mid:Find("ScrollRect")
    self.Container = self.ScrollRect:Find("Container")
    self.baseTxt = self.Container:Find("BaseText").gameObject
    self.baseTxt:SetActive(false)

    self.ScrollRect:GetComponent(ScrollRect).onValueChanged:AddListener(function()
        -- self.midImgArrow:SetActive(false)
    end)
end

function EquipTipsExt:Show(info, unlocat)

    self.itemData = info

    local name_str = ColorHelper.color_item_name(info.quality, info.name)
    if info ~= nil and info.extra ~= nil then
        --装备神器图标统一处理
        for i=1,#info.extra do
             if info.extra[i].name == 9 then
                local temp_id = info.extra[i].value
                name_str = ColorHelper.color_item_name(DataItem.data_get[temp_id].quality, DataItem.data_get[temp_id].name)
                break
             end
        end
    end


    self.nameTxt.text = name_str
    self.levelTxt.text = string.format(TI18N("部位:%s"), BackpackEumn.GetEquipNameByType(info.type))
    self.itemCell:SetAll(info)
    self.itemCell:ShowEnchant(true)
    self.itemCell:ShowLevel(true)
    -- self.bindObj:SetActive(info.bind == 1)

    --加上上部分的高度
    self.height = 80

    self:UpdateAttr()

    self.height = self.height + 40

    if unlocat == true then
    else
        self.rect.sizeDelta = Vector2(self.width, self.height)
    end
    self.gameObject:SetActive(true)

    local v2 = ctx.UICamera.camera:WorldToScreenPoint(self.transform.position)
    local scaleWidth = ctx.ScreenWidth
    local scaleHeight = ctx.ScreenHeight
    local origin = 960 / 540
    local currentScale = scaleWidth / scaleHeight

    local newx = 0
    local newy = 0
    local cw = 0
    local ch = 0
    if currentScale > origin then
        -- 以宽为准
        ch = 540
        cw = 960 * currentScale / origin
    else
        -- 以高为准
        ch = 540 * origin / currentScale
        cw = 960
    end
    newx = v2.x * cw / scaleWidth
    newy = v2.y * ch / scaleHeight

    local nx = 0
    local ny = 0
    if self.height > newy then
        -- 超出底了
        ny = self.rect.anchoredPosition.y + self.height - newy
    else
        ny = 0
    end

    if newx + self.width > cw then
        nx = -310
    else
        nx = 310
    end
    if unlocat == true then
    else
        self.rect.anchoredPosition = Vector2(nx, ny)
    end
end

function EquipTipsExt:Hide()
    self.gameObject:SetActive(false)
    self.rect.anchoredPosition = Vector2(310, 0)
end

function EquipTipsExt:GetAllEffect(effectData)
    local list = {}
    for i,v in ipairs(effectData) do
        if v.classes == 0 or v.classes == RoleManager.Instance.RoleData.classes then
            for i,v1 in ipairs(v.effect) do
                table.insert(list, v1)
            end
        end
    end
    return list
end

function EquipTipsExt:UpdateAttr()
    for i,v in ipairs(self.txtTab) do
        v.gameObject:SetActive(false)
    end

    self.midImgArrow:SetActive(false)

    local baseAttrList = {}
    local lev = self.itemData.lev
    lev = math.floor(lev  / 10) * 10
    local key = string.format("%s_%s", self.itemData.type, lev)
    local baseAttr = EquipStrengthManager.Instance.model:get_equip_base_prop_list(key)
    for name,val in pairs(baseAttr) do
        if val ~= 0 then
            table.insert(baseAttrList, {name = name, val = val})
        end
    end
    table.sort(baseAttrList, function(a,b) return GlobalEumn.AttrSort[a.name] < GlobalEumn.AttrSort[b.name] end)

    local hh = 0
    local temp_talent_h = 0
    local useCount = 0
    for i,v in ipairs(baseAttrList) do
        useCount = useCount + 1
        local tab = self:GetItem(useCount)
        -- tab.txt.text = string.format("<color='#97abb4'>%s</color><color='#4dd52b'>+%s</color> <color='#C7F9FF'>+%s~%s</color>",  KvData.attr_name[v.name], v.val, math.floor(v.val * self.minScale), math.floor(v.val * self.maxScale))
        tab.txt.text = string.format("<color='#8dcfec'>%s</color> <color='#C7F9FF'>+%s~%s</color>",  KvData.attr_name[v.name], math.floor(v.val * self.minScale), Mathf.Round(v.val * self.maxScale))
        tab.rect.sizeDelta = Vector2(tab.txt.preferredWidth, 25)
        tab.rect.anchoredPosition = Vector2(0, -hh - (i - 1) * 25)
    end
    hh = hh + 25 * #baseAttrList

    local effectData = DataEqm.data_effect[string.format("%s_%s", self.itemData.type, lev)]
    ---可出现特效
    if effectData ~= nil then
        local effectList = self:GetAllEffect(effectData)
        if #effectList > 0 then
            useCount = useCount + 1
            local tab = self:GetItem(useCount)
            tab.txt.fontSize = 16
            tab.txt.text = TI18N("<color='#ffff00'>可出现特效:</color>")
            tab.rect.sizeDelta = Vector2(tab.txt.preferredWidth, 25)
            tab.rect.anchoredPosition = Vector2(0, -hh)
            hh = hh + 25
        end
        local list = {}
        local hasRoleSkill = false
        for i,v in ipairs(effectList) do
            local skillData = nil
            if v.effect_type == 100 then
                -- 技能
                if v.val < 80000 and not hasRoleSkill then
                    hasRoleSkill = true
                    skillData = DataSkill.data_skill_effect[81999]
                elseif v.val >= 80000 then
                    skillData = DataSkill.data_skill_effect[v.val]
                end
            elseif v.effect_type == 150 then
                -- 易强化
                skillData = DataSkill.data_skill_effect[81019]
            elseif v.effect_type == 151 then
                -- 易成长
                skillData = DataSkill.data_skill_effect[81020]
            end

            if skillData ~= nil then
                table.insert(list, skillData)
            end
        end
        table.sort(list, function(a,b) return a.id < b.id end)
        for i,skillData in ipairs(list) do
            useCount = useCount + 1
            local tab = self:GetItem(useCount)
            tab.txt.fontSize = 16
            tab.txt.text = string.format("<color='#d781f2'>%s:</color><color='#33CCFF'>%s</color>", skillData.name, skillData.desc)
            local w = tab.txt.preferredWidth
            local h = 25
            if w > 250 then
                h = math.ceil(w / 250) * 25
                w = 250
            end
            tab.rect.sizeDelta = Vector2(w, h)
            tab.rect.anchoredPosition = Vector2(0, -hh)
            hh = hh + h
        end


        --天赋技能的武器效果
        local talent_list = {}
        local talentEffectList = self:GetAllEffect(effectData)
        local list = {}
        for i,v in ipairs(talentEffectList) do
            local talent_skillData = nil
            if v.effect_type == 100 then
                talent_skillData = DataSkillTalent.data_skill_talent[v.val]
                if talent_skillData ~= nil then
                    table.insert(talent_list, talent_skillData)
                end
            end
        end

        if #talent_list > 0 then
            self.midImgArrow:SetActive(true)
            useCount = useCount + 1
            local tab = self:GetItem(useCount)
            tab.txt.fontSize = 16
            tab.txt.text = TI18N("<color='#ffff00'>可出现技能天赋:</color>")
            tab.rect.sizeDelta = Vector2(tab.txt.preferredWidth, 25)
            tab.rect.anchoredPosition = Vector2(0, -hh)
            hh = hh + 25
        end

        table.sort(talent_list, function(a,b) return a.id < b.id end)
        temp_talent_h = hh
        for i,skillData in ipairs(talent_list) do
            useCount = useCount + 1
            local tab = self:GetItem(useCount)
            tab.txt.fontSize = 16
            tab.txt.fontSize = 16
            tab.txt.text = string.format("<color='#d781f2'>%s:</color><color='#33CCFF'>%s</color>", skillData.talent3_name, skillData.talent3_desc3)
            local w = tab.txt.preferredWidth
            local h = 25
            if w > 250 then
                h = math.ceil(w / 250) * 25
                w = 250
            end
            tab.rect.sizeDelta = Vector2(w, h)
            tab.rect.anchoredPosition = Vector2(0, -temp_talent_h)
            temp_talent_h = temp_talent_h + h
        end
    end

    local wingEffectData = DataEqm.data_wing_effect[string.format("%s_%s", self.itemData.type, self.itemData.lev)]
    if wingEffectData ~= nil then
        --翅膀技能的武器效果
        local wing_list = {}
        local effectList = self:GetAllEffect(wingEffectData)
        local list = {}
        for i,v in ipairs(effectList) do
            local wing_skillData = nil
            if v.effect_type == 100 then
                wing_skillData = DataSkill.data_wing_skill[string.format("%s_1", v.val)]
                if wing_skillData ~= nil then
                    table.insert(wing_list, wing_skillData)
                end
            end
        end

        if #wing_list > 0 then
            self.midImgArrow:SetActive(true)
            useCount = useCount + 1
            local tab = self:GetItem(useCount)
            tab.txt.fontSize = 16
            tab.txt.text = TI18N("<color='#ffff00'>可出现特技:</color>")
            tab.rect.sizeDelta = Vector2(tab.txt.preferredWidth, 25)
            tab.rect.anchoredPosition = Vector2(0, -hh)
            hh = hh + 25
        end

        table.sort(wing_list, function(a,b) return a.id < b.id end)
        temp_talent_h = hh
        for i,skillData in ipairs(wing_list) do
            useCount = useCount + 1
            local tab = self:GetItem(useCount)
            tab.txt.fontSize = 16
            tab.txt.text = string.format("<color='#d781f2'>%s:</color><color='#33CCFF'>%s</color>", skillData.name, skillData.desc)
            local w = tab.txt.preferredWidth
            local h = 25
            if w > 250 then
                h = math.ceil(w / 250) * 25
                w = 250
            end
            tab.rect.sizeDelta = Vector2(w, h)
            tab.rect.anchoredPosition = Vector2(0, -temp_talent_h)
            temp_talent_h = temp_talent_h + h
        end
    end

    self.Container:GetComponent(RectTransform).sizeDelta = Vector2(250, temp_talent_h)
    self.midRect.sizeDelta = Vector2(250, hh)
    self.height = self.height + hh
end

function EquipTipsExt:GetItem(index)
    local tab = self.txtTab[index]
    if tab == nil then
        tab = {}
        tab.gameObject = GameObject.Instantiate(self.baseTxt)
        tab.gameObject.name = "Txt"..index
        tab.transform = tab.gameObject.transform
        tab.transform:SetParent(self.Container)
        tab.transform.localScale = Vector3.one
        tab.rect = tab.gameObject:GetComponent(RectTransform)
        tab.txt = tab.gameObject:GetComponent(Text)
        tab.txt.fontSize = 18
        table.insert(self.txtTab, tab)
    end
    tab.gameObject:SetActive(true)
    return tab
end