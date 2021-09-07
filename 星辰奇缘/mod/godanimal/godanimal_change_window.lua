GodAnimalChangeWindow = GodAnimalChangeWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject

function GodAnimalChangeWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.godanimal_change_window
    self.name = "GodAnimalChangeWindow"
    self.resList = {
        {file = AssetConfig.godanimal_change_window, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
    }

    -----------------------------------------
    self.type = 1

	self.selectItem = nil
	self.selectItemData = nil
	self.itemList = {}

	self.itemobject =  nil
	self.itemcontainer =  nil
	self.noitemtips =  nil
	self.okButton =  nil
	self.descText  = nil

	self.therionList = {}
	self.therionDataList = {}
	self.petExchange_DataList = {}
	self.therionGroup = nil
	self.exchangePanelTransform = nil
    self.cloner = nil
    self.container = nil
    self.skillSlotList = {}
    self.skillNameTextList = {}
	self.tabbedPanel = nil
    self.headLoaderList = {}
	self.pageCount = 1
	self.isMoving = false
    self.buttonscript = nil
    -----------------------------------------
    self.setting = {
        notAutoSelect = true,
        perWidth = 146,
        perHeight = 202,
        isVertical = false,
        spacing = 17
    }

    self.updateListener = function() if self.therionGroup ~= nil and self.therionGroup.currentIndex > 0 then local index = self.therionGroup.currentIndex  self.therionGroup.currentIndex = 0 self.therionGroup:ChangeTab(index) end end

    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.updateListener)
end

function GodAnimalChangeWindow:__delete()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.updateListener)

    if self.headLoaderList ~= nil then
     for k,v in pairs(self.headLoaderList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.headLoaderList = nil
    end
	if self.skillSlotList ~= nil then
        for k,v in pairs(self.skillSlotList) do
            if v ~= nil then
                v:DeleteMe()
                self.skillSlotList[k] = nil
                v = nil
            end
        end
        self.skillSlotList = nil
    end
    if self.therionList ~= nil then
        for k,v in pairs(self.therionList) do
            if v ~= nil then
                v:DeleteMe()
                self.therionList[k] = nil
                v = nil
            end
        end
        self.therionList = nil
    end
    if self.tabbedPanel ~= nil then
        self.tabbedPanel:DeleteMe()
        self.tabbedPanel = nil
    end
    if self.buttonscript ~= nil then
        self.buttonscript:DeleteMe()
        self.buttonscript = nil
    end
    if self.skillLayout ~= nil then
        self.skillLayout:DeleteMe()
        self.skillLayout = nil
    end
    if self.therionGroup ~= nil then
        self.therionGroup:DeleteMe()
        self.therionGroup = nil
    end

    if self.itemSolt ~= nil then
        self.itemSolt:DeleteMe()
        self.itemSolt = nil
    end
    self:ClearDepAsset()
end

function GodAnimalChangeWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godanimal_change_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:Close() end)

    self.itemcontainer = self.transform:FindChild("Main/mask/ItemContainer").gameObject
    self.itemobject =  self.transform:FindChild("Main/mask/ItemContainer/Item").gameObject
    self.itemobject:SetActive(false)

    self.noitemtips = self.transform:FindChild("Main/mask/NoItemTips").gameObject
    self.noitemtips.transform:FindChild("Button"):GetComponent(Button).onClick:AddListener(function() self.model:OpenWindow({self.type}) end)

    self.okButton = self.transform:FindChild("Main/OkButton").gameObject
    self.okButton:GetComponent(Button).onClick:AddListener(function() self:openExchangePanel() end)
    -- self.okButton:SetActive(false)

    self.descText = self.transform:FindChild("Main/DescText"):GetComponent(Text)

    self.exchangePanelTransform = self.transform:FindChild("ExchangePanel")

    self.exchangePanelTransform:FindChild("Close"):GetComponent(Button).onClick:AddListener(function() self:openMain() end)

    self.container = self.exchangePanelTransform:FindChild("Main/ShowArea/MaskLayer/ScrollLayer/Container")

    self.cloner = self.exchangePanelTransform:FindChild("Main/ShowArea/MaskLayer/ScrollLayer/Cloner").gameObject
    self.cloner:SetActive(false)

    self.skillContainer = self.exchangePanelTransform:FindChild("Main/SkillArea/MaskLayer/ScrollLayer/Container")
    self.skillCloner = self.exchangePanelTransform:FindChild("Main/SkillArea/MaskLayer/ScrollLayer/Cloner").gameObject

    self.skillLayout = LuaBoxLayout.New(self.skillContainer, {axis = BoxLayoutAxis.X})
    self.skillCloner:SetActive(false)

    self.itemSolt = ItemSlot.New()
    UIUtils.AddUIChild(self.exchangePanelTransform:FindChild("Main/Item").gameObject, self.itemSolt.gameObject)

    self.scrollRect = self.exchangePanelTransform:FindChild("Main/ShowArea/MaskLayer/ScrollLayer"):GetComponent(ScrollRect)
    self.prePageEnable = self.exchangePanelTransform:FindChild("Main/ShowArea/Prepage/Enable").gameObject
    self.prePageDisable = self.exchangePanelTransform:FindChild("Main/ShowArea/Prepage/Disable").gameObject
    self.nextPageEnable = self.exchangePanelTransform:FindChild("Main/ShowArea/Nextpage/Enable").gameObject
    self.nextPageDisable = self.exchangePanelTransform:FindChild("Main/ShowArea/Nextpage/Disable").gameObject
    self.prePageBtn = self.exchangePanelTransform:FindChild("Main/ShowArea/Prepage"):GetComponent(Button)
    self.nextPageBtn = self.exchangePanelTransform:FindChild("Main/ShowArea/Nextpage"):GetComponent(Button)



    local btn = nil
    btn = self.exchangePanelTransform:FindChild("Main/Button")
    -- btn:GetComponent(Button).onClick:AddListener(function() self:ButtonClick() end)
    self.buttonscript = BuyButton.New(btn, TI18N("转 换"))
    self.buttonscript.key = "GodAnimalTrans"
    self.buttonscript.protoId = 10539
    self.buttonscript:Show()

    self.transform:FindChild("Main/DescnButton"):GetComponent(Button).onClick:AddListener(function()
    					TipsManager.Instance:ShowText({gameObject = self.transform:FindChild("Main/DescnButton").gameObject
            				, itemData = { TI18N("1.出战中的神兽和进阶过的神兽无法进行转换")
            							,TI18N("2.转换后神兽等级经验不变，加点重置，宠物护符和符石保留") }})
    				 end)

    self.exchangePanelTransform:FindChild("Main/DescnButton"):GetComponent(Button).onClick:AddListener(function()
    					TipsManager.Instance:ShowText({gameObject = self.exchangePanelTransform:FindChild("Main/DescnButton").gameObject
            				, itemData = { TI18N("1.出战中的神兽和进阶过的神兽无法进行转换")
            							,TI18N("2.转换后神兽等级经验不变，加点重置，宠物护符和符石保留") }})
    				 end)

    if self.openArgs ~= nil and #self.openArgs > 0 then
        self.type = self.openArgs[1]
    end

    if self.type == 1 then
        self.mainTransform:FindChild("Title/Text"):GetComponent(Text).text = TI18N("我的神兽")
        self.exchangePanelTransform:FindChild("Title/Text"):GetComponent(Text).text = TI18N("选择神兽")

        self.mainTransform:FindChild("DescText"):GetComponent(Text).text = TI18N("选择你需要更换的神兽")
        self.noitemtips.transform:FindChild("Text"):GetComponent(Text).text = TI18N("当前没有任何神兽")
    elseif self.type == 2 then
        self.mainTransform:FindChild("Title/Text"):GetComponent(Text).text = TI18N("我的珍兽")
        self.exchangePanelTransform:FindChild("Title/Text"):GetComponent(Text).text = TI18N("选择珍兽")

        self.mainTransform:FindChild("DescText"):GetComponent(Text).text = TI18N("选择你需要更换的珍兽")
        self.noitemtips.transform:FindChild("Text"):GetComponent(Text).text = TI18N("当前没有任何珍兽")
    end

    self:openMain()
end

function GodAnimalChangeWindow:Close()
    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.godanimal_change_window)
end

function GodAnimalChangeWindow:UpdatePetList()
	for key,value in pairs(self.itemList) do
		GameObject.DestroyImmediate(value)
	end
	self.itemList = {}
	self.selectItem = nil
    self.selectItemData = nil

	local petList = PetManager.Instance.model.petlist
	local index = 1
	for key,value in pairs(petList) do
		if ((self.type == 1 and value.genre == 2) or (self.type == 2 and value.genre == 4)) and value.base_id ~= 20005 and value.base_id ~= 20006 and value.base_id ~= 20007 then
            index = index + 1
			local itemdata = value
            local item = GameObject.Instantiate(self.itemobject)
            UIUtils.AddUIChild(self.itemcontainer, item)
            table.insert(self.itemList, item)
            local fun = function()
                self:selectMainPet(item, itemdata)
            end
            item:GetComponent(Button).onClick:AddListener(fun)

            item.transform:FindChild("NameText"):GetComponent(Text).text = itemdata.name
            item.transform:FindChild("LevText"):GetComponent(Text).text = string.format("Lv.%s", itemdata.lev)
            item.transform:FindChild("ScoreText"):GetComponent(Text).text = string.format("%s(%s)", PetManager.Instance.model:gettalentclass(itemdata.talent), itemdata.talent)

            local headId = tostring(itemdata.base.head_id)

            local loaderId = item.transform:FindChild("HeadImageBg/Image").gameObject:GetInstanceID()
            if self.headLoaderList[loaderId] == nil then
                self.headLoaderList[loaderId] = SingleIconLoader.New(item.transform:FindChild("HeadImageBg/Image").gameObject)
            end
            self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,headId)

        	-- item.transform:FindChild("HeadImageBg/Image"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(headId), headId)

        	local headbg = PetManager.Instance.model:get_petheadbg(itemdata)
        	item.transform:FindChild("HeadImageBg"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, headbg)

        	item.transform:FindChild("FightFlag"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, "I18N_PetBattle")
        	item.transform:FindChild("FightFlag").gameObject:SetActive(itemdata.status == 1)
		end
	end

    if index == 1 then
        self.noitemtips:SetActive(true)
    else
        self.noitemtips:SetActive(false)
    end
end

function GodAnimalChangeWindow:UpdateExchangePanel()
	self.therionDataList = {}
	self.petExchange_DataList = {}
	for key,value in pairs(DataPet.data_pet_exchange) do
		if (self.type == 1 and value.change_cost[1][1] == 20038) or (self.type == 2 and value.change_cost[1][1] == 20095) then
			table.insert(self.therionDataList, DataPet.data_pet[value.base_id])
			table.insert(self.petExchange_DataList, value)
		end
	end

    local selectTab = nil

	local obj = nil
    local rect = nil
    for i,v in ipairs(self.therionDataList) do
        if self.therionList[i] == nil then
            obj = GameObject.Instantiate(self.cloner)
            obj.name = tostring(i)
            obj.transform:SetParent(self.container)
            obj.transform.localScale = Vector3.one
            rect = obj:GetComponent(RectTransform)
            rect.pivot = Vector2(0, 1)
            rect.anchoredPosition = Vector2((i - 1) * (self.setting.perWidth + self.setting.spacing), 0)
            self.therionList[i] = TherionItem.New(self.model, obj)
        end
        self.therionList[i]:SetData(v,i)
        if self.selectItemData.base_id ~= v.id and selectTab == nil then selectTab = i end
    end

    self.therionGroup = TabGroup.New(self.container, function(index) self:SelectTherion(index) end, self.setting)

    if selectTab ~= nil then
        self.therionGroup.noCheckRepeat = true
        self.therionGroup:ChangeTab(selectTab)
        self.therionGroup.noCheckRepeat = false
    end

    if self.tabbedPanel == nil then
	    self.pageCount = #self.therionDataList - math.ceil(self.scrollRect:GetComponent(RectTransform).sizeDelta.x / self.setting.perWidth) + 1
	    self.tabbedPanel = TabbedPanel.New(self.scrollRect.gameObject, self.pageCount, self.setting.perWidth, 0.5)
	    self.tabbedPanel.MoveEndEvent:AddListener(function(currentPage, direction) self:OnDragEnd(currentPage, direction) end)

	    self.prePageBtn.onClick:AddListener(function()
	        if self.tabbedPanel.currentPage > 1 then
	            self.tabbedPanel:TurnPage(self.tabbedPanel.currentPage - 1)
	        end
	    end)
	    self.nextPageBtn.onClick:AddListener(function()
	        if self.tabbedPanel.currentPage < self.pageCount then
	            self.tabbedPanel:TurnPage(self.tabbedPanel.currentPage + 1)
	        end
	    end)
	    self.scrollRect.onValueChanged:AddListener(function(data) self:OnDrag(data) end)
	else
		self.pageCount = #self.therionDataList - math.ceil(self.scrollRect:GetComponent(RectTransform).sizeDelta.x / self.setting.perWidth) + 1
		self.tabbedPanel:SetPageCount(self.pageCount)
	end
end

function GodAnimalChangeWindow:openMain()
	self.mainTransform.gameObject:SetActive(true)
	self.exchangePanelTransform.gameObject:SetActive(false)

	self:UpdatePetList()
end

function GodAnimalChangeWindow:openExchangePanel()
	if self.selectItemData == nil then
        if self.type == 1 then
            NoticeManager.Instance:FloatTipsByString(TI18N("没有选中宠物"))
        elseif self.type == 2 then
            NoticeManager.Instance:FloatTipsByString(TI18N("没有选中宠物"))
        end
		return
	end
	if self.selectItemData.status == 1 then
        if self.type == 1 then
            NoticeManager.Instance:FloatTipsByString(TI18N("出战状态的神兽无法进行转换"))
        elseif self.type == 2 then
            NoticeManager.Instance:FloatTipsByString(TI18N("出战状态的珍兽无法进行转换"))
        end
		return
	end
	if self.selectItemData.grade > 0 then
        if self.type == 1 then
            NoticeManager.Instance:FloatTipsByString(TI18N("进阶过的神兽无法进行转换"))
        elseif self.type == 2 then
            NoticeManager.Instance:FloatTipsByString(TI18N("进阶过的珍兽无法进行转换"))
        end
		return
	end
	self.mainTransform.gameObject:SetActive(false)
	self.exchangePanelTransform.gameObject:SetActive(true)

	self:UpdateExchangePanel()
end

function GodAnimalChangeWindow:selectMainPet(item, itemdata)
	if self.selectItem ~= nil then
		self.selectItem.transform:FindChild("SelectedImage").gameObject:SetActive(false)
	end
	self.selectItem = item
	self.selectItemData = itemdata
	self.selectItem.transform:FindChild("SelectedImage").gameObject:SetActive(true)

	if itemdata.status == 1 and itemdata.grade > 0 then
		self.okButton:SetActive(false)
	else
		self.okButton:SetActive(true)
	end
end

function GodAnimalChangeWindow:SelectTherion(index)
    if self.therionDataList[index].genre == 2 then
        self.isTherion = 1
    else
        self.isTherion = 2
    end

    local skillDatas = self.therionDataList[index].base_skills

    local obj = nil
    for i,v in ipairs(skillDatas) do
        if self.skillSlotList[i] == nil then
            obj = GameObject.Instantiate(self.skillCloner)
            obj.name = tostring(i)
            self.skillLayout:AddCell(obj)
            self.skillSlotList[i] = SkillSlot.New()
            self.skillNameTextList[i] = obj.transform:Find("Name"):GetComponent(Text)
            NumberpadPanel.AddUIChild(obj.transform:Find("SlotBg").gameObject, self.skillSlotList[i].gameObject)
        end
        local data = DataSkill.data_petSkill[v[1].."_1"]
        self.skillSlotList[i]:SetAll(Skilltype.petskill, data)
        self.skillNameTextList[i].text = data.name
        self.skillSlotList[i].gameObject:SetActive(true)
    end

    for i=#skillDatas + 1, #self.skillSlotList do
        self.skillSlotList[i].gameObject.transform.parent.parent.gameObject:SetActive(false)
    end

	local cost = self.petExchange_DataList[index].change_cost[1][1]
	local itembase = BackpackManager.Instance:GetItemBase(cost)
	local itemData = ItemData.New()
	itemData:SetBase(itembase)
	itemData.quantity = BackpackManager.Instance:GetItemCount(cost)
	itemData.need = self.petExchange_DataList[index].change_cost[1][2]
	self.itemSolt:SetAll(itemData)

	self.buttonscript:Layout({[cost] = {need = self.petExchange_DataList[index].change_cost[1][2]}}, function() self:toExchange(self.therionDataList[index].id) end, nil, { antofreeze = false })
end

function GodAnimalChangeWindow:toExchange(base_id)
	GodAnimalManager.Instance:send10539(self.selectItemData.id, base_id)
    self:Close()
end

function GodAnimalChangeWindow:OnDrag(data)
    if self.isMoving == false then
        self.isMoving = true
        local x = math.ceil(data[1] * self.pageCount)
        if x > self.pageCount then
            x = self.pageCount
        elseif x < 1 then
            x = 1
        end
        self:OnDragEnd(x)
        self.tabbedPanel.currentPage = x
    end
end

function GodAnimalChangeWindow:OnDragEnd(currentPage, direction)
    if currentPage < self.pageCount then
        self.nextPageEnable:SetActive(true)
        self.nextPageDisable:SetActive(false)
    else
        self.nextPageEnable:SetActive(false)
        self.nextPageDisable:SetActive(true)
    end
    if currentPage > 1 then
        self.prePageEnable:SetActive(true)
        self.prePageDisable:SetActive(false)
    else
        self.prePageEnable:SetActive(false)
        self.prePageDisable:SetActive(true)
    end

    self.isMoving = false
end
