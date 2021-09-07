-- ----------------------------------------------------------
-- UI - 宠物选择符石窗口
-- ----------------------------------------------------------
PetGemSelect = PetGemSelect or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function PetGemSelect:__init(model)
    self.model = model
    self.name = "PetGemSelect"
    self.windowId = WindowConfig.WinID.petgenselect
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Destroy

    self.resList = {
        {file = AssetConfig.petgenselect, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

	self.mainTransform = nil

	------------------------------------------------

    self.attr = {}

    self.select = 2
	------------------------------------------------
    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function PetGemSelect:__delete()
    if self.itemSlot1 ~= nil then
        self.itemSlot1:DeleteMe()
        self.itemSlot1 = nil
    end
    if self.itemSlot2 ~= nil then
        self.itemSlot2:DeleteMe()
        self.itemSlot2 = nil
    end

    self:OnHide()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function PetGemSelect:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.petgenselect))
    self.gameObject.name = "PetGemSelect"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.descText = self.transform:FindChild("Main/Text"):GetComponent(Text)
    self.descText.text = TI18N("人品爆发！恭喜您合成时出现了稀有的<color='#c3692c'>[彩虹护符]</color>")

	self.itemSlot1 = ItemSlot.New()
	UIUtils.AddUIChild(self.mainTransform:FindChild("Item1/Item").gameObject, self.itemSlot1.gameObject)
	self.itemNameText1 = self.mainTransform:FindChild("Item1/Text"):GetComponent(Text)
	self.itemSkillText1 = self.mainTransform:FindChild("Item1/SkillText"):GetComponent(Text)
	self.itemSkilSelect1 = self.mainTransform:FindChild("Item1/Select").gameObject
	self.mainTransform:FindChild("Item1"):GetComponent(Button).onClick:AddListener(function() self:OnSelect(1) end)

	self.itemSlot2 = ItemSlot.New()
	UIUtils.AddUIChild(self.mainTransform:FindChild("Item2/Item").gameObject, self.itemSlot2.gameObject)
	self.itemNameText2 = self.mainTransform:FindChild("Item2/Text"):GetComponent(Text)
	self.itemSkillText2 = self.mainTransform:FindChild("Item2/SkillText"):GetComponent(Text)
	self.itemSkilSelect2 = self.mainTransform:FindChild("Item2/Select").gameObject
	self.mainTransform:FindChild("Item2"):GetComponent(Button).onClick:AddListener(function() self:OnSelect(2) end)

	self.mainTransform:FindChild("SaveButton"):GetComponent(Button).onClick:AddListener(function() self:OnButtonClick() end)
	self.itemSkilSelect1:SetActive(false)
	self.itemSkilSelect2:SetActive(true)
    ----------------------------
    self:OnShow()
    self:ClearMainAsset()
end

function PetGemSelect:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function PetGemSelect:OnShow()
	local openArgs = self.openArgs
	if #openArgs > 0 then
		self.item_id = openArgs[1]
		local itemData = BackpackManager.Instance:GetItemById(self.item_id)
		self.attr = itemData.attr
	else
		local list = BackpackManager.Instance:GetItemByType(BackpackEumn.ItemType.petsupergem)
		if #list > 0 then
			self.item_id = list[1].id
			local itemData = list[1]
			self.attr = itemData.attr
		end
	end

	self:Update()
end

function PetGemSelect:OnHide()
end

function PetGemSelect:Update()
	local itemData1 = { base_id = 0, skills = {} }
	local itemData2 = { base_id = 0, skills = {} }

    for i,v in ipairs(self.attr) do 
    	local flag = v.flag % 10
    	if flag == 1 then
    		itemData1.base_id = math.floor(v.flag / 10)
    		table.insert(itemData1.skills, v.val)
    	else
    		itemData2.base_id = math.floor(v.flag / 10)
    		table.insert(itemData2.skills, v.val)
    	end
    end

    if itemData1.base_id ~= 0 and itemData2.base_id ~= 0 then
    	local itemData = ItemData.New()
    	local itemBase = BackpackManager.Instance:GetItemBase(itemData1.base_id)
	    itemData:SetBase(itemBase)
	    local skillNameString = ""
	    for i=1, #itemData1.skills do
		    table.insert(itemData.attr, { name = 100, val = itemData1.skills[i]})
		    local petSkillData = DataSkill.data_petSkill[string.format("%s_1", itemData1.skills[i])]
		    if i == 1 then
		    	skillNameString = string.format("[%s]",petSkillData.name)
		    else
			    skillNameString = string.format("%s\n[%s]", skillNameString, petSkillData.name)
			end
		end
	    local extra = {inbag = true ,nobutton = true}
	    self.itemSlot1:SetAll(itemData, extra) 
	    self.itemSlot1:SetSelectSelfCallback(function() self:OnSelect(1) end)
	    self.itemNameText1.text = itemBase.name
	    self.itemSkillText1.text = skillNameString

	    itemData = ItemData.New()
    	itemBase = BackpackManager.Instance:GetItemBase(itemData2.base_id)
	    itemData:SetBase(itemBase)
	    skillNameString = ""
	    for i=1, #itemData2.skills do
		    table.insert(itemData.attr, { name = 100, val = itemData2.skills[i]})
		    local petSkillData = DataSkill.data_petSkill[string.format("%s_1", itemData2.skills[i])]
		    if i == 1 then
		    	skillNameString = string.format("[%s]",petSkillData.name)
		    else
			    skillNameString = string.format("%s\n[%s]", skillNameString, petSkillData.name)
			end
		end
	    self.itemSlot2:SetAll(itemData, extra) 
	    self.itemSlot2:SetSelectSelfCallback(function() self:OnSelect(2) end)
	    self.itemNameText2.text = itemBase.name
	    self.itemSkillText2.text = skillNameString
    end
end

function PetGemSelect:OnSelect(index)
	self.select = index
	if index == 1 then
		self.itemSkilSelect1:SetActive(true)
		self.itemSkilSelect2:SetActive(false)
	else
		self.itemSkilSelect1:SetActive(false)
		self.itemSkilSelect2:SetActive(true)
	end
end

function PetGemSelect:OnButtonClick()
	if self.select ~= 0 then
	    PetManager.Instance:Send10337(self.item_id, self.select)
	    self:OnClickClose()
	else
		NoticeManager.Instance:FloatTipsByString(TI18N("请选择一个护符"))
	end
end