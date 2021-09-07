-- ----------------------------------------------------------
-- UI - 宠物窗口 主窗口
-- ----------------------------------------------------------
PetChangeSkillPanel = PetChangeSkillPanel or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function PetChangeSkillPanel:__init(model)
    self.model = model
    self.name = "PetChangeSkillPanel"
    self.windowId = WindowConfig.WinID.pet_feed
    self.winLinkType = WinLinkType.Link

    self.resList = {
        {file = AssetConfig.petskillselect, type = AssetType.Main}
    }

    self.gameObject = nil
    self.transform = nil


	------------------------------------------------
    self.skillList = {}
    self.skillNameList = {}
    self.skillSelectObjList = {}

	------------------------------------------------
    self.selectIndex = 0
    self.pet_id = 0
    self.pet_base_id = 0
    self.skill_id  = 0
    self.itemEnough = true

    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self._Update = function() self:Update() end
end

function PetChangeSkillPanel:__delete()
    self:OnHide()

    if self.skillList ~= nil then
        for i=1, #self.skillList do 
            self.skillList[i]:DeleteMe()
        end
        self.skillList = nil
    end
end

function PetChangeSkillPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.petskillselect))
    self.gameObject.name = "PetChangeSkillPanel"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    -- 初始化技能图标
    local soltPanel = self.mainTransform:FindChild("Container")
    local soltNum = soltPanel.childCount - 1
    for i=0, soltNum do
        local slot = SkillSlot.New()
        local item = soltPanel:GetChild(i)
        UIUtils.AddUIChild(item.gameObject, slot.gameObject)
        slot.transform:SetAsFirstSibling()
        table.insert(self.skillList, slot)
        table.insert(self.skillNameList, item:Find("Text"):GetComponent(Text))
        table.insert(self.skillSelectObjList, item:Find("Select").gameObject)
    end

    self.itemSolt = ItemSlot.New()
    UIUtils.AddUIChild(self.mainTransform:Find("ItemSlot").gameObject, self.itemSolt.gameObject)
    self.itemNameText = self.mainTransform:Find("ItemName"):GetComponent(Text)
    self.itemNumText = self.mainTransform:Find("ItemNum"):GetComponent(Text)

    self.mainTransform:FindChild("Button"):GetComponent(Button).onClick:AddListener(function() self:OnClickButton() end)

    ----------------------------
    self:OnShow()
    self:ClearMainAsset()
end

function PetChangeSkillPanel:OnClickClose()
    -- WindowManager.Instance:CloseWindow(self)
    self.model:ClosePetChangeSkillPanel()
end

function PetChangeSkillPanel:OnShow()
    if self.openArgs ~= nil and #self.openArgs > 2 then
        self.pet_id = self.openArgs[1]
        self.pet_base_id = self.openArgs[2]
        self.skill_id = self.openArgs[3]
    end

    self:Update()

    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self._Update)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self._Update)
end

function PetChangeSkillPanel:OnHide()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self._Update)
end

function PetChangeSkillPanel:Update()
    local data_pet_change_skill = DataPet.data_pet_change_skill[self.pet_base_id]
    if data_pet_change_skill == nil then
        return
    end

    local itemId = data_pet_change_skill.cost[1][1]
    local costNum = data_pet_change_skill.cost[1][2]
    local num = BackpackManager.Instance:GetItemCount(itemId)
    local itemBase = BackpackManager.Instance:GetItemBase(itemId)
    local itemData = ItemData.New()
    itemData:SetBase(itemBase)
    self.itemSolt:SetAll(itemData)
    self.itemNameText.text = itemData.name
    if self.skill_id == 0 then
        self.itemNumText.text = string.format("<color='#00ff00'>%s/%s</color>", num, 0)
        self.itemEnough = true
    else
        if num < costNum then
            self.itemNumText.text = string.format("<color='#ff0000'>%s/%s</color>", num, costNum)
            self.itemEnough = false
        else
            self.itemNumText.text = string.format("<color='#00ff00'>%s/%s</color>", num, costNum)
            self.itemEnough = true
        end
    end

    for i = 1, #data_pet_change_skill.skills do
        local skillData = DataSkill.data_petSkill[string.format("%s_1", data_pet_change_skill.skills[i][1])]
        self.skillList[i]:SetAll(Skilltype.petskill, skillData)
        self.skillList[i]:SetSelectSelfCallback(function() self:OnSelectSkill(i, skillData.id) end)
        self.skillNameList[i].text = skillData.name
    end
end

function PetChangeSkillPanel:OnSelectSkill(index, skillId)
    for i = 1, 5 do
        self.skillSelectObjList[i]:SetActive(false)
    end
    self.skillSelectObjList[index]:SetActive(true)
    self.selectIndex = index
    self.selectSkillId = skillId

    if self.skill_id == self.selectSkillId then
        NoticeManager.Instance:FloatTipsByString(TI18N("当前技能正在使用中"))
    else
        local data_petSkill = DataSkill.data_petSkill[string.format("%s_1", self.selectSkillId)]
        if data_petSkill ~= nil then
            BaseUtils.dump(data_petSkill)
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("已选择<color='#00ff00'>%s</color>"), data_petSkill.name))
        end
    end
end

function PetChangeSkillPanel:OnClickButton()
    if self.selectSkillId == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择任一宠物技能"))
        return
    end
    if not self.itemEnough then
        local data_pet_change_skill = DataPet.data_pet_change_skill[self.pet_base_id]
        if data_pet_change_skill == nil then
            return
        end

        local itemId = data_pet_change_skill.cost[1][1]
        local itemBase = BackpackManager.Instance:GetItemBase(itemId)
        TipsManager.Instance:ShowItem({ gameObject = self.mainTransform:FindChild("Button").gameObject, itemData = itemBase })
        return
    end
    PetManager.Instance:Send10573(self.pet_id, self.selectSkillId)
end