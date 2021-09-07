-- ------------------------------
-- 职业绝招预览 tips
-- xhs
-- ------------------------------

SkillFinalPreview = SkillFinalPreview or BaseClass(BasePanel)

function SkillFinalPreview:__init(parent)
    self.model = SkillManager.Instance.model
    self.parent = parent
    self.resList = {
        {file = AssetConfig.skill_final_preview, type = AssetType.Main},
    }
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function SkillFinalPreview:__delete()
    self.OnHideEvent:Fire()
    if self.currentloader ~= nil then
        self.currentloader:DeleteMe()
        self.currentloader = nil
    end
    if self.nextloader ~= nil then
        self.nextloader:DeleteMe()
        self.nextloader = nil
    end
    self:AssetClearAll()

end

function SkillFinalPreview:OnShow()
    self:Update()
end

function SkillFinalPreview:OnHide()

end

function SkillFinalPreview:Close()
    self:Hiden()
    SkillManager.Instance.OnHideTips:Fire()
end

function SkillFinalPreview:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.skill_final_preview))
    self.gameObject.name = "SkillFinalPreview"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.current = self.transform:Find("Current")
    self.next = self.transform:Find("Next")

    self.currentPos = self.current:GetComponent(RectTransform)
    self.nextPos = self.next:GetComponent(RectTransform)

    self.currentName = self.current:Find("Name"):GetComponent(Text)
    self.currentLev = self.current:Find("Lev"):GetComponent(Text)
    self.currentDesc = self.current:Find("Desc"):GetComponent(Text)
    self.currentCd = self.current:Find("CoolDown/Text"):GetComponent(Text)




    self.nextName = self.next:Find("Name"):GetComponent(Text)
    self.nextLev = self.next:Find("Lev"):GetComponent(Text)
    self.nextDesc = self.next:Find("Desc"):GetComponent(Text)
    self.nextCd = self.next:Find("CoolDown/Text"):GetComponent(Text)



    self.current:GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.next:GetComponent(Button).onClick:AddListener(function() self:Close() end)


end

function SkillFinalPreview:OnInitCompleted()
    self:OnShow()
end

function SkillFinalPreview:Update()

    local skill = self.model.finalSkill.skill_unique[1].id
    local lev = self.model.finalSkill.skill_unique[1].lev
    local stage = 1
    local nextlev = 15

    if lev < 15 then
        nextlev = 15
    elseif lev < 30 then
        nextlev = 30
    elseif lev < 45 then
        nextlev = 45
    elseif lev < 55 then
        nextlev = 55
    elseif lev < 65 then
        nextlev = 65
    elseif lev < 70 then
        nextlev = 70
    else
        nextlev = 71
    end
    local nextData = DataSkill.data_skill_role[string.format("%s_%s", skill,nextlev)]
    local currentData = DataSkill.data_skill_role[string.format("%s_%s", skill,lev)]

    self.currentName.text = currentData.name
    self.currentLev.text = "Lv."..currentData.lev
    self.currentDesc.text = currentData.desc
    self.currentCd.text = DataCombatSkill.data_combat_skill[string.format("%s_%s", skill,lev)].cooldown.."回合"
    if self.currentloader == nil then
        self.currentloader = SingleIconLoader.New(self.current:Find("Icon").gameObject)
    end
    self.currentloader:SetSprite(SingleIconType.SkillIcon, currentData.icon)

    if nextData ~= nil then
        self.currentPos.localPosition = Vector2(-168,4)
        self.nextPos.localPosition = Vector2(224,4)
        self.current.gameObject:SetActive(true)
        self.next.gameObject:SetActive(true)
        self.nextName.text = nextData.name
        self.nextLev.text = "Lv."..nextData.lev
        self.nextDesc.text = nextData.desc
        self.nextCd.text = DataCombatSkill.data_combat_skill[string.format("%s_%s", skill,nextlev)].cooldown.."回合"
        if self.nextloader == nil then
            self.nextloader = SingleIconLoader.New(self.next:Find("Icon").gameObject)
        end
        self.nextloader:SetSprite(SingleIconType.SkillIcon, nextData.icon)
    else
        self.currentPos.localPosition = Vector2(50,4)
        self.current.gameObject:SetActive(true)
        self.next.gameObject:SetActive(false)
    end
end


