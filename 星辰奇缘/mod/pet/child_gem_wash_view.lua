-- ----------------------------------------------------------
-- UI - 孩子项链技能洗炼
-- ----------------------------------------------------------
ChildGemWashView = ChildGemWashView or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function ChildGemWashView:__init(model)
    self.model = model
    self.name = "ChildGemWashView"
    self.windowId = WindowConfig.WinID.childgenwash
    self.winLinkType = WinLinkType.Link

    self.resList = {
        {file = AssetConfig.childgenwash, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

	------------------------------------------------
	self.container = nil
	self.gemItem = nil
	self.skillPanel = nil
	self.item = nil
	self.Button = nil
	self.buttonscript = nil

	------------------------------------------------
	self.itemList = {}
	self.itemSlotList = {}
	self.skillIcon_List = {}
	self.skillSlot_List = {}

	-- self.itemId = 0
	self.selectitem = nil
	self.selectitemdata = nil

    self.tempSkillList = {}
    ------------------------------------------------
    self._update = function() self:update() end

    self._updateFrezzonButton = function() self:EnableFreezonBtn() end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function ChildGemWashView:__delete()
    if self.itemSlot ~= nil then
        self.itemSlot:DeleteMe()
        self.itemSlot = nil
    end

    for i,v in ipairs(self.skillSlot_List) do
        v:DeleteMe()
    end
    self.skillSlot_List = nil

    for k,v in pairs(self.itemSlotList) do
        v:DeleteMe()
        v = nil
    end


    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end

    if self.buttonscript ~= nil then
        self.buttonscript:DeleteMe()
        self.buttonscript = nil
    end
    self:OnHide()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function ChildGemWashView:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.childgenwash))
    self.gameObject.name = "ChildGemWashView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    ----------------------------
   	self.container = self.transform:FindChild("Main/GemListPanel/Mask/Container").gameObject
	self.gemItem = self.container.transform:FindChild("Item").gameObject

	self.skillPanel = self.transform:FindChild("Main/WashPanel/SoltPanel").gameObject
	self.skillItem = self.skillPanel.transform:FindChild("SkillItem").gameObject

	self.item = self.transform:FindChild("Main/WashPanel/Item").gameObject
	self.itemSlot = ItemSlot.New()
	UIUtils.AddUIChild(self.item, self.itemSlot.gameObject)

	self.Button = self.transform:FindChild("Main/WashPanel/Button").gameObject
    self.buttonscript = BuyButton.New(self.Button, TI18N("重 置"), false)
    self.buttonscript.key = "ChildGemWash"
    self.buttonscript.protoId = 10526
    self.buttonscript:Show()

    self.saveButton = self.transform:FindChild("Main/WashPanel/SaveButton").gameObject
    self.saveButton:SetActive(false)
    self.saveButton:GetComponent(Button).onClick:AddListener(function() self:OnSaveButton() end)
    ----------------------------
    self:OnShow()
    self:ClearMainAsset()
end

function ChildGemWashView:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function ChildGemWashView:OnShow()
	-- if self.openArgs ~= nil and #self.openArgs > 0 then self.itemId = self.openArgs[1] end
    self.tempSkillList = {}

	self:update()
	EventMgr.Instance:AddListener(event_name.backpack_item_change, self._update)

    self:RemoveListeners()
    PetManager.Instance.On10526ButtonFreezon:Add(self._updateFrezzonButton)
end

function ChildGemWashView:OnHide()
    self.tempSkillList = {}
	EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self._update)

    self:RemoveListeners()
end

function ChildGemWashView:RemoveListeners()
    PetManager.Instance.On10526ButtonFreezon:Remove(self._updateFrezzonButton)
end

function ChildGemWashView:update()
	self:updateItem()
end


function ChildGemWashView:updateItem()
    local skillgem_list = BackpackManager.Instance:GetItemByBaseid(23856)
    local temp = BackpackManager.Instance:GetItemByBaseid(23857)
    for key, value in pairs(temp) do
        table.insert(skillgem_list, value)
    end
    temp = BackpackManager.Instance:GetItemByBaseid(23858)
    for key, value in pairs(temp) do
        table.insert(skillgem_list, value)
    end

    local itempanel = self.container
    local itemobject = self.gemItem

	for i=1,#skillgem_list do
	    local itemdata = skillgem_list[i]
	    local item = self.itemList[i]
	    if item == nil then
	        item = GameObject.Instantiate(itemobject)
	        UIUtils.AddUIChild(itempanel, item)
	        table.insert(self.itemList, item)

	    end
	    item:SetActive(true)

        local fun = function()
            self:item_click(item, itemdata)
        end
        item:GetComponent(Button).onClick:RemoveAllListeners()
        item:GetComponent(Button).onClick:AddListener(fun)

	    local slot = self.itemSlotList[i]
	    if slot == nil then
	    	slot = ItemSlot.New()
	    	UIUtils.AddUIChild(item.transform:FindChild("Item").gameObject, slot.gameObject)
	    	table.insert(self.itemSlotList, slot)
	    end
	    slot:SetAll(itemdata)

	    item.transform:FindChild("Name"):GetComponent(Text).text = itemdata.name
	    self:setitemattr(item, itemdata.attr)

	    -- if itemdata.id == self.itemId then self:item_click(item, itemdata) end
        if self.selectitemdata ~= nil and itemdata.id == self.selectitemdata.id then self:item_click(item, itemdata) end
	end

    -- if #self.itemList > 0 and self.selectitem == nil then self:item_click(self.itemList[1], skillgem_list[1]) end

	for i = #skillgem_list+1, #self.itemList do
		local item = self.itemList[i]
		item:SetActive(false)
	end
end

function ChildGemWashView:setitemattr(item, attr)
    local attr_str = ""
    local skill_str = ""
    for k,v in pairs(attr) do
        if v.type == GlobalEumn.ItemAttrType.base then
            if v.name ~= KvData.attrname_skill then
                attr_str = attr_str..string.format("%s: +%s", KvData.attr_name[v.name], v.val)
            else
                skill_str = skill_str..string.format("[%s]", DataSkill.data_petSkill[string.format("%s_1", v.val)].name)
            end
        end
    end
    if attr_str == "" then
        item.transform:FindChild("Desc"):GetComponent(Text).text = TI18N("技能:")
        item.transform:FindChild("Skill"):GetComponent(Text).text = skill_str
    else
        item.transform:FindChild("Desc"):GetComponent(Text).text = attr_str
    end
end

function ChildGemWashView:item_click(item, itemdata)
    if self.selectitem ~= nil then
        self.selectitem.transform:FindChild("Select").gameObject:SetActive(false)
    end
    self.selectitem = item
    self.selectitemdata = itemdata
    item.transform:FindChild("Select").gameObject:SetActive(true)

    self:updateInfo()
end

function ChildGemWashView:updateInfo()
    local tempAttrList = self.tempSkillList[self.selectitemdata.id]

    if tempAttrList == nil then
        PetManager.Instance:Send10563(self.selectitemdata.id)
    end

    if tempAttrList == nil or #tempAttrList == 0 then
        self.saveButton:SetActive(false)
        self.Button.transform.localPosition = Vector2(0, -124)
    else
        self.saveButton:SetActive(true)
        self.Button.transform.localPosition = Vector2(55, -124)
    end

    local attrList = self.selectitemdata.attr
    if tempAttrList ~= nil and #tempAttrList > 0 then
        attrList = tempAttrList
    end

	local index = 1
	for k,v in pairs(attrList) do
        if v.type == GlobalEumn.ItemAttrType.base then
            if v.name == KvData.attrname_skill then
                local skillData = DataSkill.data_petSkill[string.format("%s_1", v.val)]
                local skillIcon = self.skillIcon_List[index]
                if skillIcon == nil then
                	skillIcon = GameObject.Instantiate(self.skillItem)
                	UIUtils.AddUIChild(self.skillPanel, skillIcon)
	        		table.insert(self.skillIcon_List, skillIcon)
                end

                local skillSlot = self.skillSlot_List[index]
                if skillSlot == nil then
                	skillSlot = SkillSlot.New()
                	UIUtils.AddUIChild(skillIcon, skillSlot.gameObject)
	        		table.insert(self.skillSlot_List, skillSlot)
                end

                skillIcon:SetActive(true)

                skillSlot:SetAll(Skilltype.petskill, skillData)
        		skillSlot:ShowState(true)

        		skillIcon.transform:FindChild("Text"):GetComponent(Text).text = string.format("[%s]", skillData.name)

				index = index + 1
            end
        end
    end

    for i = index, #self.skillIcon_List do
		local skillIcon = self.skillIcon_List[i]
		skillIcon:SetActive(false)
	end

	-----------------------------------------------------------------
	-- 更新消耗物品
	-----------------------------------------------------------------

	local loss = DataPet.data_pet_gem_reset[self.selectitemdata.base_id].loss[1]
	local loss_base_id = loss[1]
	local loss_num = loss[2]
	local itemData = ItemData.New()
	itemData:SetBase(BackpackManager.Instance:GetItemBase(loss_base_id))
	itemData.quantity = BackpackManager.Instance:GetItemCount(loss_base_id)
	itemData.need = loss_num
	self.itemSlot:SetAll(itemData)

	self.buttonscript:Layout({[loss_base_id] = {need = loss_num}}, function() PetManager.Instance:Send10526(self.selectitemdata.id) end,  function(baseidToBuyInfo) self:lackCallback(baseidToBuyInfo) end, { antofreeze = false})

    if itemData.quantity >= itemData.need then
        self.item.transform:Find("Num").gameObject:SetActive(false)
    end
end

function ChildGemWashView:lackCallback(baseidToBuyInfo)
    local coins = RoleManager.Instance.RoleData.coins
    local gold_bind = RoleManager.Instance.RoleData.gold_bind

    for k,v in pairs(baseidToBuyInfo) do
        local t = self.item.transform
        local numText = t:Find("Num"):GetComponent(Text)

        if self.imgLoader == nil then
            local go = t:Find("Num/Currency").gameObject
            self.imgLoader = SingleIconLoader.New(go)
        end
        self.imgLoader:SetSprite(SingleIconType.Item, v.assets)

        if v.allprice < 0 then
            numText.text = "<color=#FF0000>"..tostring(0 - v.allprice).."</color>"
        else
            numText.text = tostring(v.allprice)
        end

        t:Find("Num").gameObject:SetActive(true)
    end
end

function ChildGemWashView:SetTempAttr(data)
    self.tempSkillList[data.id] = data.attr
    if self.selectitemdata.id == data.id then
        self:updateInfo()
    end
end

function ChildGemWashView:OnSaveButton()
    if self.tempSkillList[self.selectitemdata.id] ~= nil then
        self.tempSkillList[self.selectitemdata.id] = nil
        PetManager.Instance:Send10564(self.selectitemdata.id)
    end
end

function ChildGemWashView:EnableFreezonBtn()
    self.buttonscript:EnableBtn(PetManager.Instance.model.On10526ButtonState)
end
