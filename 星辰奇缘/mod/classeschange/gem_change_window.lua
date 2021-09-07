-- ----------------------------------------------------------
-- UI - 宝石转换
-- ljh 2016.10.10
-- ----------------------------------------------------------
GemChangeWindow = GemChangeWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function GemChangeWindow:__init(model)
    self.model = model
    self.name = "GemChangeWindow"
    self.windowId = WindowConfig.WinID.gemchangewindow
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Destroy

    self.resList = {
        {file = AssetConfig.gemchangewindow, type = AssetType.Main}
        , {file = AssetConfig.createrole_texture, type = AssetType.Dep}
        , {file = AssetConfig.stongbg, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

	self.mainTransform = nil

	------------------------------------------------

    -- self.descString = TI18N("1、成功转职可以进行装备宝石切换\n2、成功转职7天内可进行16次转换\n3、英雄宝石无法进行转换")
    self.descString = TI18N("1.成功转职后，7天内可以进行宝石免费转换\n2.宝石将按市场价折算等级，超出部分邮件返还\n3.高价宝石只能进行同级转换，多出的差价不返还")

	------------------------------------------------
    self.okButtonText = nil
    self.timesText = nil

    self.container = nil
    self.gemitemobject = nil
    self.noitemtips = nil

    self.gemlist = {}
    self.gemItemSlotList = {}

    self.itemSlot1 = nil
    self.itemSlot2 = nil
    self.itemNameText1 = nil
    self.itemNameText2 = nil

    self.i18NText2 = nil
	self.tipsText = nil

    self.selectItem_container = nil
	self.selectItem_itemobject = nil
    self.selectItem_itemlist = {}
    self.selectItem_itemSlotList = {}

    self.select_item = nil
	self.select_data = nil

	self.effect = nil
	self.base_id_dic = {}

    self.gemSlotList = {}
    self.selectItemSlotList = {}
    ------------------------------------------------
    self._on12416_callback = function(priceByBaseid) self:on12416_callback(priceByBaseid) end
    self._update = function() self:update() end
    self._ChangeSuccess = function() self:ChangeSuccess() end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function GemChangeWindow:__delete()
    if self.itemSlot1 ~= nil then
        self.itemSlot1:DeleteMe()
        self.itemSlot1 = nil
    end

    if self.itemSlot2 ~= nil then
        self.itemSlot2:DeleteMe()
        self.itemSlot2 = nil
    end

    for _, slot in pairs(self.gemSlotList) do
        slot:DeleteMe()
    end
    self.gemSlotList = {}

    for _, slot in pairs(self.selectItemSlotList) do
        slot:DeleteMe()
    end
    self.selectItemSlotList = {}

    self:OnHide()

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function GemChangeWindow:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.gemchangewindow))
    self.gameObject.name = "GemChangeWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

	self.transform.transform:Find("Main/ItemPanel/ItemBg1"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.stongbg, "StoneBg")
	self.transform.transform:Find("Main/ItemPanel/ItemBg2"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.stongbg, "StoneBg")
    ----------------------------
    local transform = self.transform

    self.mainPanel = transform:FindChild("Main").gameObject
    self.selectItemPanel = transform:FindChild("ItemSelect").gameObject

    transform:FindChild("Main/ItemPanel/DescText"):GetComponent(Text).text = self.descString

    self.okButton = transform:FindChild("Main/ItemPanel/OkButton")
    self.okButton:GetComponent(Button).onClick:AddListener(function() self:OnOkButton() end)
    self.okButtonText = transform:FindChild("Main/ItemPanel/OkButton/Text"):GetComponent(Text)

	self.timesText = transform:FindChild("Main/ItemPanel/TimesText"):GetComponent(Text)
	self.priceText1 = transform:FindChild("Main/ItemPanel/Price1/Price"):GetComponent(Text)
	self.priceText2 = transform:FindChild("Main/ItemPanel/Price2/Price"):GetComponent(Text)

    self.container = transform:FindChild("Main/GemPanel/Mask/Container").gameObject
    self.gemitemobject = self.container.transform:FindChild("Item").gameObject

    self.noitemtips = self.transform:FindChild("Main/GemPanel/NoItemTips").gameObject
    GameObject.Destroy(self.noitemtips:GetComponent(Button))

    self.itemNameText1 = transform:FindChild("Main/ItemPanel/ItemName1"):GetComponent(Text)
    self.itemNameText2 = transform:FindChild("Main/ItemPanel/ItemName2"):GetComponent(Text)

    transform:FindChild("Main/ItemPanel"):GetChild(5):GetComponent(Text).text = TI18N("<color='#3166ad'>转换说明</color>")

    self.i18NText2 = transform:FindChild("Main/ItemPanel/I18NText2").gameObject
    self.tipsText = transform:FindChild("Main/ItemPanel/TipsText").gameObject

    self.itemSlot1 = ItemSlot.New()
	UIUtils.AddUIChild(transform:FindChild("Main/ItemPanel/Item1"), self.itemSlot1.gameObject)

    self.itemSlot2 = ItemSlot.New()
	UIUtils.AddUIChild(transform:FindChild("Main/ItemPanel/Item2"), self.itemSlot2.gameObject)
	self.itemSlot2:SetNotips(true)
	self.itemSlot2.gameObject:GetComponent(Button).onClick:AddListener(function() self:Select_ChangeGgem() end)

	transform:FindChild("Main/ItemPanel/ChangeButton"):GetComponent(Button).onClick:AddListener(function() self:Select_ChangeGgem() end)

	transform:FindChild("ItemSelect/Panel"):GetComponent(Button).onClick:AddListener(function() self:CloseSelectItemPanel() end)
	transform:FindChild("ItemSelect/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:CloseSelectItemPanel() end)

	self.selectItem_container = transform:FindChild("ItemSelect/MainCon/Con/Layout").gameObject
    self.selectItem_itemobject = self.selectItem_container.transform:FindChild("Item").gameObject

    ----------------------------
    self:OnShow()
    self:ClearMainAsset()
end

function GemChangeWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function GemChangeWindow:OnShow()
	EventMgr.Instance:AddListener(event_name.equip_item_change, self._update)
	EventMgr.Instance:AddListener(event_name.gem_change_success, self._ChangeSuccess)

	MarketManager.Instance:send12416({ base_ids = { {base_id = 20800}, {base_id = 20801}, {base_id = 20802}, {base_id = 20803}, {base_id = 20804}, {base_id = 20805}, {base_id = 20806}, {base_id = 20807} } }, self._on12416_callback)

	self:update()
end

function GemChangeWindow:OnHide()
	EventMgr.Instance:RemoveListener(event_name.equip_item_change, self._update)
	EventMgr.Instance:RemoveListener(event_name.gem_change_success, self._ChangeSuccess)
end

function GemChangeWindow:update()
	self:update_gemlist()
end

function GemChangeWindow:update_gemlist()
	local gemdatalist = {}
    local gemlist = self.gemlist
    local gemItemSlotList = self.gemItemSlotList
    local gemitemobject = self.gemitemobject
    local container = self.container

    for _,equipData in pairs(BackpackManager.Instance.equipDic) do
		for i=1,#equipData.attr do
		    local ed = equipData.attr[i]
		    if ed.type == GlobalEumn.ItemAttrType.gem
		    	and (tonumber(ed.name) == 110 or tonumber(ed.name) == 111 or tonumber(ed.name) == 112 ) then
		    	table.insert(gemdatalist, { equipData = equipData, gemIndex = tonumber(ed.name), baseId = ed.val })
		    end
		end
    end

	local function sortfun(a,b)
	    return self.model:GetGemChangeFree(a) and not self.model:GetGemChangeFree(b)
	end
	table.sort(gemdatalist, sortfun)

    local selectItem = nil
    local selectData = nil
    for i = 1, #gemdatalist do
        local data = gemdatalist[i]
        local gemitem = gemlist[i]
        local itemSlot = gemItemSlotList[i]

        if gemitem == nil then
			local item = GameObject.Instantiate(gemitemobject)
			item:SetActive(true)
			item.transform:SetParent(container.transform)
			item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
			gemlist[i] = item
			gemitem = item

			local slot = ItemSlot.New()
            table.insert(self.gemSlotList, slot)
			UIUtils.AddUIChild(item.transform:FindChild("ItemSlot"), slot.gameObject)
			gemItemSlotList[i] = slot
			itemSlot = slot
        end

        local itembase = BackpackManager.Instance:GetItemBase(data.baseId)
        local itemData = ItemData.New()
        itemData:SetBase(itembase)
        itemSlot:SetAll(itemData)

        gemitem.transform:FindChild("NameText"):GetComponent(Text).text = itemData.name

        local cfg_data = DataBacksmith.data_gem_base[data.baseId]
        if cfg_data == nil then
        		cfg_data = DataBacksmith.data_hero_stone_base[data.baseId]
        end

        gemitem.transform:FindChild("AttrText"):GetComponent(Text).text = string.format("%s+%s", KvData.attr_name_show[cfg_data.attr[1].attr_name], cfg_data.attr[1].val1)

        local equipitembase = BackpackManager.Instance:GetItemBase(data.equipData.base_id)
        gemitem.transform:FindChild("TypeText"):GetComponent(Text).text = BackpackEumn.GetEquipNameByType(equipitembase.type)

        if self.model:GetGemChangeFree(data) then
        	gemitem.transform:FindChild("RedPointImage").gameObject:SetActive(true)
        	gemitem.transform:FindChild("Label").gameObject:SetActive(false)
        else
        	gemitem.transform:FindChild("RedPointImage").gameObject:SetActive(false)
        	gemitem.transform:FindChild("Label").gameObject:SetActive(true)
        end

        local button = gemitem:GetComponent(Button)
        button.onClick:RemoveAllListeners()
        button.onClick:AddListener(function() self:OnGemItemClick(gemitem, data) end)

        -- if self.select_item == gemitem then
        -- 	selectItem = gemitem
        -- 	selectData = data
        -- end
        if selectItem == nil then
        	selectItem = gemitem
        	selectData = data
        end
    end

    if #gemdatalist == 0 then
		self.noitemtips:SetActive(true)
		self.select_data = nil
		self:update_price()
	else
		self.noitemtips:SetActive(false)
	end

    if selectItem ~= nil and selectData ~= nil then
    	self:OnGemItemClick(selectItem, selectData)
    end
end

function GemChangeWindow:OnGemItemClick(item, data)
	-- BaseUtils.dump(data, "OnGemItemClick")
	if self.select_item ~= nil then
		self.select_item.transform:FindChild("Select").gameObject:SetActive(false)
	end
	self.select_item = item
	self.select_data = data

	self.select_item.transform:FindChild("Select").gameObject:SetActive(true)

	self:update_geminfo()
end

function GemChangeWindow:update_geminfo()
	local itembase = BackpackManager.Instance:GetItemBase(self.select_data.baseId)
	local itemData = ItemData.New()
	itemData:SetBase(itembase)
	self.itemSlot1:SetAll(itemData)

	self.itemNameText1.text = itemData.name

	self.itemSlot2:SetAll(nil)

	self.itemNameText2.text = ""

	self.targetGemData = nil

	self.base_id_dic = self:GetGemCanChange()
	if #self.base_id_dic > 0 and self.model:GetGemChangeFree(self.select_data) then
		self.i18NText2:SetActive(true)
		self.tipsText:SetActive(false)
		self:Select_ChangeGgem_CallBack(self.base_id_dic[1])
	else
		self.i18NText2:SetActive(false)
		self.tipsText:SetActive(true)
		self.select_data = nil
		self:update_price()
	end
end

function GemChangeWindow:Select_ChangeGgem()
	if not self.model:GetGemChangeFree(self.select_data) then
		NoticeManager.Instance:FloatTipsByString("当前宝石无法转换")
	elseif #self.base_id_dic == 0 then
		NoticeManager.Instance:FloatTipsByString("当前宝石没有可转换的目标宝石")
	else
		self.mainPanel:SetActive(false)
		self.selectItemPanel:SetActive(true)
		if self.effect ~= nil then
			self.effect:SetActive(false)
		end

		local base_id_dic = self:GetGemCanChange()

		-- 刷新显示列表
	    for i = 1, #base_id_dic do
	        local data = base_id_dic[i]
	        local item = self.selectItem_itemlist[i]
	        local itemSlot = self.selectItem_itemSlotList[i]

	        if item == nil then
				local tempItem = GameObject.Instantiate(self.selectItem_itemobject)
				tempItem:SetActive(true)
				tempItem.transform:SetParent(self.selectItem_container.transform)
				tempItem:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
				self.selectItem_itemlist[i] = tempItem
				item = tempItem

				local slot = ItemSlot.New()
                table.insert(self.selectItemSlotList, slot)
				UIUtils.AddUIChild(tempItem.transform:FindChild("icon"), slot.gameObject)
				self.selectItem_itemSlotList[i] = slot
				itemSlot = slot
	        end
	        item.gameObject:SetActive(true)

	        local itembase = BackpackManager.Instance:GetItemBase(data)
	        local itemData = ItemData.New()
	        itemData:SetBase(itembase)
	        itemSlot:SetAll(itemData)

	        item.transform:FindChild("name"):GetComponent(Text).text = itemData.name

	        local cfg_data = DataBacksmith.data_gem_base[data]
	        if cfg_data == nil then
	        	cfg_data = DataBacksmith.data_hero_stone_base[data]
	        end
	        item.transform:FindChild("desc"):GetComponent(Text).text = string.format("%s+%s", KvData.attr_name_show[cfg_data.attr[1].attr_name], cfg_data.attr[1].val1)

	        local button = item:GetComponent(Button)
	        button.onClick:RemoveAllListeners()
	        button.onClick:AddListener(function() self:Select_ChangeGgem_CallBack(data) end)
	    end

	    if #base_id_dic+1 <= #self.selectItem_itemlist then
		    for i=#base_id_dic+1, #self.selectItem_itemlist do
		    	local item = self.selectItem_itemlist[i]
		    	item.gameObject:SetActive(false)
		    end
		end
	end
end

function GemChangeWindow:CloseSelectItemPanel()
	self.mainPanel:SetActive(true)
	self.selectItemPanel:SetActive(false)
end

function GemChangeWindow:GetGemCanChange()
	-- 筛选出可转换的宝石
	local base_id_dic = {}

	if self.select_data == nil then
		return base_id_dic
	end

	local equipitembase = BackpackManager.Instance:GetItemBase(self.select_data.equipData.base_id)
	local select_gem_baseData = DataBacksmith.data_gem_base[self.select_data.baseId]
	local price_dic = {}
	local temp_dic = {}
	local allow_list = {}

	if select_gem_baseData ~= nil then -- 普通宝石
		allow_list = DataBacksmith.data_gem_limit[equipitembase.type].allow

		local base_price = EquipStrengthManager.Instance.model:count_gem_prive(self.select_data.baseId) -- 当前选中的宝石价钱
		for k,v in pairs(DataBacksmith.data_gem_base) do
			if v.lev <= select_gem_baseData.lev then
				local price = EquipStrengthManager.Instance.model:count_gem_prive(v.id)
				if (temp_dic[v.type] == nil and v.lev == 1) or (temp_dic[v.type] == nil and base_price >= price)
					or (temp_dic[v.type] ~= nil and base_price >= price and temp_dic[v.type].price < price) then
					temp_dic[v.type] = { data = v, price = price }
				end
			end
	    end

	    for i=1,#allow_list do
		    local allow_data = allow_list[i]
		    if temp_dic[allow_data.attr_name] ~= nil then
			    local temp_dic_data = temp_dic[allow_data.attr_name].data
			    if temp_dic_data ~= nil and self.select_data.baseId ~= temp_dic_data.id then
			        table.insert(base_id_dic, temp_dic_data.id)
			    end
			end
		end
	else -- 判断是否英雄宝石
		select_gem_baseData = DataBacksmith.data_hero_stone_base[self.select_data.baseId]

		if select_gem_baseData ~= nil then -- 英雄宝石
			local new_allow_list = {}
			allow_list = DataBacksmith.data_hero_stone_limit[equipitembase.type].allow
			for i=1,#allow_list do
				local allow_data = allow_list[i]
				local temp_data = DataBacksmith.data_hero_stone_base[allow_data[1]]
				for k,v in pairs(DataBacksmith.data_hero_stone_base) do
					if v.lev == select_gem_baseData.lev and v.type == temp_data.type then
						table.insert(new_allow_list, v)
					end
				end
			end

			for i=1,#new_allow_list do
			    local allow_data = new_allow_list[i]
				if self.select_data.baseId ~= allow_data.id then
				    table.insert(base_id_dic, allow_data.id)
				end
			end
		end
	end

	return base_id_dic
end

function GemChangeWindow:Select_ChangeGgem_CallBack(data)
	local itembase = BackpackManager.Instance:GetItemBase(data)
	local itemData = ItemData.New()
	itemData:SetBase(itembase)
	self.itemSlot2:SetAll(itemData)

	self.itemNameText2.text = itemData.name

	self.targetGemData = data

	self:CloseSelectItemPanel()

	self:update_price()
end

function GemChangeWindow:update_price()
	-- self.timesText.text = string.format(TI18N("剩余免费次数：%s"), 0)
	self.timesText.text = ""

	if self.model:GetGemChangeFree(self.select_data) then
		self.okButtonText.text = TI18N("免费转换")
		self.okButton:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
	else
		self.okButtonText.text = TI18N("无法转换")
		self.okButton:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
	end

	self.priceText1.text = "0"
	self.priceText2.text = tostring(RoleManager.Instance.RoleData.gold_bind)
end

function GemChangeWindow:OnOkButton()
	if self.select_data == nil then
		NoticeManager.Instance:FloatTipsByString("你没有选择要转换的宝石")
		return
	end
	if self.targetGemData == nil then
		NoticeManager.Instance:FloatTipsByString("你没有选择要转换的目标宝石")
		return
	end
	if self.model:GetGemChangeFree(self.select_data) then
		print(self.select_data.equipData.id .. ", " ..self.select_data.gemIndex .. ", " .. self.targetGemData)
		ClassesChangeManager.Instance:Send10625(self.select_data.equipData.id, self.select_data.gemIndex, self.targetGemData)
	else
		NoticeManager.Instance:FloatTipsByString("没有免费转换次数，无法转换")
	end
end

function GemChangeWindow:ChangeSuccess()
	if self.effect == nil then
	    local fun = function(effectView)
	        local effectObject = effectView.gameObject

	        self.washEffect = effectObject

	        Utils.ChangeLayersRecursively(effectObject.transform, "UI")

	        effectObject.transform:SetParent(self.transform:FindChild("Main/ItemPanel/Item1"))
	        effectObject.transform.localScale = Vector3(1, 1, 1)
	        effectObject.transform.localPosition = Vector3(0, 0, -400)
	        effectObject.transform.localRotation = Quaternion.identity

	        self.effect = effectView
	    end
	    self.effect = BaseEffectView.New({effectId = 20049, time = nil, callback = fun})
	else
		self.effect:SetActive(false)
		self.effect:SetActive(true)
	end
end

function GemChangeWindow:on12416_callback(priceByBaseid)
	EquipStrengthManager.Instance.model.gem_priceByBaseid = priceByBaseid
	self:update()
end
