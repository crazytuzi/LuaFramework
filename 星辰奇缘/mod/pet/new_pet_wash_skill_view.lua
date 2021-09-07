NewPetWashSkillView = NewPetWashSkillView or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject

function NewPetWashSkillView:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.newpetwashskillwindow
    self.name = "NewPetWashSkillView"
    self.resList = {
        {file = AssetConfig.newpetwashskillwindow, type = AssetType.Main}
    }

    -----------------------------------------
    self.skillList = {}
    self.skillSlotList = {}
    self.skillTextList = {}

    -----------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function NewPetWashSkillView:__delete()
    self:OnHide()
    for i,v in ipairs(self.skillSlotList) do
        v:DeleteMe()
    end
    self.skillSlotList = nil

    self:ClearDepAsset()
end

function NewPetWashSkillView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.newpetwashskillwindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.CloseButton = self.transform:Find("Main/CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.soltPanel = self.transform:FindChild("Main/Mask/SoltPanel").gameObject
    self.icon = self.transform:FindChild("Main/Icon").gameObject
    self.text = self.transform:FindChild("Main/I18N_Text"):GetComponent(Text)

    self:OnShow()
end

function NewPetWashSkillView:Close()
    self.model:CloseNewPetWashSkillWindow()
end

function NewPetWashSkillView:OnShow()
    if self.openArgs ~= nil and #self.openArgs > 0 then
        self.petId = self.openArgs[1]
        self.petData = self.model:getpet_byid(self.petId)
    end

    if self.petData ~= nil then
        local petBaseData = DataPet.data_pet[self.petData.base.id]
        if petBaseData == nil then return end
        if #petBaseData.base_skills > 4 then
            self.text.text = string.format(TI18N("您的宠物<color='#00ff00'>%s</color>触发了幸运降临，下次洗髓必定获得以下所有技能(变异状态下无效):"), self.petData.name)
        else
            self.text.text = string.format(TI18N("您的宠物<color='#00ff00'>%s</color>触发了幸运降临，下次洗髓必定会获得以下技能(变异下状态无效):"), self.petData.name)
        end
        self:UpdateList()
    end
end

function NewPetWashSkillView:OnHide()
end

function NewPetWashSkillView:UpdateList()
    local petBaseData = DataPet.data_pet[self.petData.base.id]
    if petBaseData == nil then return end

    local list = petBaseData.base_skills
    for k,v in pairs(list) do
        local icon = self.skillList[k]
        local slot = self.skillSlotList[k]
        local text = self.skillTextList[k]
        if icon == nil then
            icon = GameObject.Instantiate(self.icon)
            UIUtils.AddUIChild(self.soltPanel, icon)
            table.insert(self.skillList, icon)

            slot = SkillSlot.New()
            UIUtils.AddUIChild(icon, slot.gameObject)
            table.insert(self.skillSlotList, slot)

            text = icon.transform:FindChild("Text"):GetComponent(Text)
            table.insert(self.skillTextList, text)
        end
        self:SetItem(slot, text, v[1])
    end
end

function NewPetWashSkillView:SetItem(slot, text, skill_id)
    local skill_data = DataSkill.data_petSkill[string.format("%s_1", skill_id)]
    slot:SetAll(Skilltype.petskill, skill_data)
    text.text = BaseUtils.string_cut(skill_data.name, 12, 9)
end