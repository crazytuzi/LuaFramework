PetRecommendSkillView = PetRecommendSkillView or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject

function PetRecommendSkillView:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.recommendskillpanel
    self.name = "PetRecommendSkillView"
    self.resList = {
        {file = AssetConfig.recommendskillpanel, type = AssetType.Main}
    }

    -----------------------------------------
    self.Layout = nil
    self.CopyItem = nil

    self.slotList = {}

    self.type = 1
    -----------------------------------------
end

function PetRecommendSkillView:__delete()
    for i,v in ipairs(self.slotList) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    self.slotList = nil

    self:ClearDepAsset()
end

function PetRecommendSkillView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.recommendskillpanel))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.CloseButton = self.transform:Find("Panel")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.CopyItem = self.transform:Find("Main/SkillPanel/mask/Container/SkillItem").gameObject
    self.CopyItem:SetActive(false)

    -- local setting = {
    --     axis = BoxLayoutAxis.Y
    --     ,spacing = 5
    --     ,Left = nil
    --     ,Top = 4
    --     ,scrollRect = self.transform:Find("Main/mask")
    -- }
    -- self.Layout = LuaBoxLayout.New(self.transform:Find("Main/mask/ItemContainer"), setting)

    self.transform:Find("Main/Button"):GetComponent(Button).onClick:AddListener(function() self:ButtonClick() end)

    self.transform:Find("Main/DescButton"):GetComponent(Button).onClick:AddListener(function() self:DescButtonClick() end)

    self:Update()
end

function PetRecommendSkillView:Close()
    self.model:CloseRecommendSkillWindow()
end

function PetRecommendSkillView:Update()
    local data = DataPet.data_pet_recommend_skill[self.model.cur_petdata.base_id]

    self.transform:Find("Main/TypeText"):GetComponent(Text).text = data.recommend_type
    self.transform:Find("Main/TypeDescText"):GetComponent(Text).text = data.recommend_type_desc

    self.transform:Find("Main/DescText"):GetComponent(Text).text = TI18N("使用以上技能的<color='#00ff00'>高级版本</color>效果更佳")

    local parent = self.transform:Find("Main/SkillPanel/mask/Container")
    for k,v in ipairs(data.skill_list) do
        local item = GameObject.Instantiate(self.CopyItem)
        self:SetItem(item, v)
        item.gameObject:SetActive(true)
        item.transform:SetParent(parent)
        item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
        -- self.Layout:AddCell(item.gameObject)
    end

    -- self.Layout:ReSize()
end

function PetRecommendSkillView:SetItem(item, skill_id)
    local its = item.transform

    local data = DataPet.data_recommend_skill[skill_id]
    if data == nil then
        return
    end
    local skillData = DataSkill.data_petSkill[string.format("%s_1", data.id)]
    its:Find("NameText"):GetComponent(Text).text = skillData.name
    its:Find("DescText"):GetComponent(Text).text = data.skills_desc

    local slot = SkillSlot.New()
   	UIUtils.AddUIChild(its:FindChild("SkillSolt").gameObject, slot.gameObject)
   	slot:SetAll(Skilltype.petskill, skillData)
   	-- slot.bgImg:GetComponent(RectTransform).sizeDelta = Vector3(42, 42)
    -- slot.skillImg:GetComponent(RectTransform).sizeDelta = Vector3(42, 42)
    table.insert(self.slotList, slot)
end

function PetRecommendSkillView:ButtonClick()
    self:Close()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.market, {1, 3, 3})
end

function PetRecommendSkillView:DescButtonClick()
    -- TipsManager.Instance:ShowText({gameObject = self.transform:Find("Main/DescButton").gameObject, itemData = {"提示"}})
end