PetBreakSkillView = PetBreakSkillView or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject

function PetBreakSkillView:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.skilltalentwindow
    self.name = "PetBreakSkillView"
    self.resList = {
        {file = AssetConfig.skilltalentwindow, type = AssetType.Main}
    }

    -----------------------------------------
    self.skillList = {}
    self.skillIdList = {}
    self.skillSlotList = {}
    -----------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function PetBreakSkillView:__delete()
    self:OnHide()

    for i,v in ipairs(self.skillSlotList) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    self.skillSlotList = nil

    self:ClearDepAsset()
end

function PetBreakSkillView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.skilltalentwindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.CloseButton = self.transform:Find("Main/CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.soltPanel = self.transform:FindChild("Main/Mask/SoltPanel").gameObject
    self.talentIcon = self.transform:FindChild("Main/TalentIcon").gameObject

    self.transform:Find("Main/Title/Text"):GetComponent(Text).text = TI18N("激活突破技能")
    self.transform:Find("Main/I18N_Text"):GetComponent(Text).text = TI18N("成功进阶激活了突破技能，点击图标可查看详情")

    self:OnShow()
end

function PetBreakSkillView:Close()
    self.model:ClosePetBreakSkillView()
end

function PetBreakSkillView:OnShow()
    if self.openArgs ~= nil and #self.openArgs > 0 then
        self.skillIdList = self.openArgs[1]
    end
    self:UpdateList()
end

function PetBreakSkillView:OnHide()
end

function PetBreakSkillView:UpdateList()
    local list = self.skillIdList
    for k,v in pairs(list) do
        local icon = self.skillList[k]
        if icon == nil then
            icon = GameObject.Instantiate(self.talentIcon)
            UIUtils.AddUIChild(self.soltPanel, icon)
            table.insert(self.skillList, icon)
        end
        self:SetItem(icon, v)
    end
end

function PetBreakSkillView:SetItem(item, data)
    local skill_data = DataSkill.data_petSkill[string.format("%s_1", data)]
    item.transform:FindChild("Image").gameObject:SetActive(false)
    item.transform:FindChild("Text"):GetComponent(Text).text = BaseUtils.string_cut(skill_data.name, 12, 9)

    local slot = SkillSlot.New()
    UIUtils.AddUIChild(item, slot.gameObject)
    slot:SetAll(Skilltype.petskill, skill_data)
    slot:ShowLabel(true, TI18N("<color='#ffff00'>突破</color>"))

    table.insert(self.skillSlotList, slot)
end
