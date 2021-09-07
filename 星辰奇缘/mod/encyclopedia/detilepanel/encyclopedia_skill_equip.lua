-- @author hzf
-- @date 2016年7月7日,星期四

EncyclopediaEquipSkill = EncyclopediaEquipSkill or BaseClass(BasePanel)


function EncyclopediaEquipSkill:__init(parent)
    self.model = EncyclopediaManager.Instance.model
    self.parent = parent
    self.name = "EncyclopediaEquipSkill"

    self.resList = {
        {file = AssetConfig.equipskill_pedia, type = AssetType.Main},
        {file = AssetConfig.bible_textures, type = AssetType.Dep},
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.txtTab = {}
    self.type = nil

    self.btnList = {}
end

function EncyclopediaEquipSkill:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    if self.tabLayout ~= nil then
        self.tabLayout:DeleteMe()
    end
    self:AssetClearAll()
end

function EncyclopediaEquipSkill:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.equipskill_pedia))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.Desc = self.transform:Find("Desc"):GetComponent(Text) -- 描述内容
    local cfgdata = DataBrew.data_alldesc["equipskill"]
    if cfgdata ~= nil then
        self.Desc.text = cfgdata.desc1
    end


    self.gridBtn = self.transform:Find("ItemList/Mask/Scroll")
    self.itemBtn = self.gridBtn:Find("Item").gameObject
    self.itemBtn:SetActive(false)
    self.tabLayout = LuaBoxLayout.New(self.gridBtn.gameObject, {axis = BoxLayoutAxis.Y, spacing = 5})

    self.midAreaRect = self.transform:Find("Right/MidArea"):GetComponent(RectTransform)
    self.midAreaRect.sizeDelta = Vector2(297, 330)
    self.gridTxt = self.transform:Find("Right/MidArea/ScrollRect/Container")
    self.Container = self.gridTxt
    self.itemTxt = self.gridTxt:Find("BaseText").gameObject
    self.itemTxt:SetActive(false)
end

function EncyclopediaEquipSkill:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function EncyclopediaEquipSkill:OnOpen()
    self:RemoveListeners()

    if self.type == nil then
        self.type = RoleManager.Instance.RoleData.classes
    end
    self:updatePanel()
end

function EncyclopediaEquipSkill:updatePanel()
    self:UpdateBtn()
    self:UpdateAttr(self.type)
end

function EncyclopediaEquipSkill:UpdateBtn()
    for k,v in pairs(EncyclopediaManager.Instance.EquipSkillData) do
        local itemBtnTemp = self.btnList[k]
        if itemBtnTemp == nil then
            local obj = GameObject.Instantiate(self.itemBtn)
            obj.name = tostring(k)
            self.tabLayout:AddCell(obj)
            local selectobj = obj.transform:Find("Select").gameObject
            selectobj:SetActive(false)
            obj:GetComponent(Button).onClick:AddListener(function()
                if self.selectgo ~= nil then
                    self.selectgo:SetActive(false)
                end
                self.selectgo = selectobj
                self.selectgo:SetActive(true)
                self:UpdateAttr(k)
            end)
            self.btnList[k] = obj
            itemBtnTemp = obj
        end
        itemBtnTemp.transform:Find("SkillName"):GetComponent(Text).text = string.format(TI18N("%s特效"),BackpackEumn.ItemTypeName[k])
    end
end

function EncyclopediaEquipSkill:UpdateAttr(type)
    for i,v in ipairs(self.txtTab) do
        if v.gameObject ~= nil then
            v.gameObject:SetActive(false)
        end
    end
    ---可出现特效
    local effectList = EncyclopediaManager.Instance.EquipSkillData[type]
    -- BaseUtils.dump(effectList,"effectList ---- = ")
    local useCount = 0
    local hh = 0
    local temp_talent_h = 0
    if #effectList > 0 then
        useCount = useCount + 1
        local tab = self:GetItem(useCount)
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
        -- tab.txt.fontSize = 16
        tab.txt.text = string.format("<color='#d781f2'>%s:</color><color='#33CCFF'>%s</color>", skillData.name, skillData.desc)
        local w = tab.txt.preferredWidth
        local h = 25
        if w > 297 then
            h = math.ceil(w / 297) * 25
            w = 297
        end
        tab.rect.sizeDelta = Vector2(w, h)
        tab.rect.anchoredPosition = Vector2(0, -hh)
        hh = hh + h
    end


    --天赋技能的武器效果
    local talent_list = {}
    local talentEffectList = EncyclopediaManager.Instance.EquipSkillData[type]
    local list = {}
    for i,v in ipairs(talentEffectList) do
        local talent_skillData = nil
        if v.effect_type == 100 then
            talent_skillData = DataSkillTalent.data_skill_talent[v.val]
        end
        if talent_skillData ~= nil then
            table.insert(talent_list, talent_skillData)
        end
    end

    if #talent_list > 0 then
        -- self.midImgArrow:SetActive(true)
        useCount = useCount + 1
        local tab = self:GetItem(useCount)
        tab.txt.text = TI18N("<color='#ffff00'>可出现技能天赋:</color>")
        tab.rect.sizeDelta = Vector2(tab.txt.preferredWidth, 25)
        tab.rect.anchoredPosition = Vector2(0, -hh - 7)
        hh = hh + 25
    end

    table.sort(talent_list, function(a,b) return a.id < b.id end)
    temp_talent_h = hh
    for i,skillData in ipairs(talent_list) do
        useCount = useCount + 1
        local tab = self:GetItem(useCount)
        -- tab.txt.fontSize = 16
        tab.txt.text = string.format("<color='#d781f2'>%s:</color><color='#33CCFF'>%s</color>", skillData.talent3_name, skillData.talent3_desc3)
        local w = tab.txt.preferredWidth
        local h = 25
        if w > 297 then
            h = math.ceil(w / 297) * 25
            w = 297
        end
        tab.rect.sizeDelta = Vector2(w, h)
        tab.rect.anchoredPosition = Vector2(0, -temp_talent_h)
        temp_talent_h = temp_talent_h + h
    end

    self.Container:GetComponent(RectTransform).sizeDelta = Vector2(297, temp_talent_h)
    -- self.height = self.height + hh
end

function EncyclopediaEquipSkill:GetItem(index)
    local tab = self.txtTab[index]
    if tab == nil then
        tab = {}
        tab.gameObject = GameObject.Instantiate(self.itemTxt)
        tab.gameObject.name = "Txt"..index
        tab.transform = tab.gameObject.transform
        tab.transform:SetParent(self.Container)
        tab.transform.localScale = Vector3.one
        tab.rect = tab.gameObject:GetComponent(RectTransform)
        tab.txt = tab.gameObject:GetComponent(Text)
        -- tab.txt.fontSize = 18
        table.insert(self.txtTab, tab)
    end
    tab.gameObject:SetActive(true)
    return tab
end

function EncyclopediaEquipSkill:OnHide()
    self:RemoveListeners()
end

function EncyclopediaEquipSkill:RemoveListeners()
end
