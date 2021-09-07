-- @author 黄耀聪
-- @date 2016年8月16日

BackendTwoExchange = BackendTwoExchange or BaseClass(BasePanel)

function BackendTwoExchange:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "BackendTwoExchange"
	self.mgr = BackendManager.Instance

    self.resList = {
        {file = AssetConfig.backend_two_excharge, type = AssetType.Main},
        {file = AssetConfig.backend_textures, type = AssetType.Dep},
    }

	self.singlePerLine = 5
	self.multiPerLine = 4
	self.singlePageList = {}
	self.multiPageList = {}

	self.leftDays = 0
	self.leftHours = 0
	self.leftMinutes = 0
	self.leftSeconds = 	0

	self.timeFormat1 = TI18N("活动倒计时：%s天%s小时")
	self.timeFormat2 = TI18N("活动倒计时：%s小时%s分")
	self.timeFormat3 = TI18N("活动倒计时：%s分%s秒")
	self.timeFormat4 = TI18N("活动倒计时：%s秒")

	self.timeListener = function() self:OnTime() end
	self.reloadListener = function() self:ReloadSingleList() self:ReloadMultiList() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function BackendTwoExchange:__delete()
    self.OnHideEvent:Fire()
	if self.singlePageList ~= nil then
		for _,v in pairs(self.singlePageList) do
			if v ~= nil then
				for _,item in pairs(v.items) do
					if item.slot ~= nil then
						item.slot:DeleteMe()
					end
					if item.data ~= nil then
						item.data:DeleteMe()
					end
				end
			end
		end
		self.singlePageList = nil
	end
	if self.multiPageList ~= nil then
		for _,v in pairs(self.multiPageList) do
			if v ~= nil then
				for _,item in pairs(v.items) do
					if item.slot1 ~= nil then
						item.slot1:DeleteMe()
					end
					if item.slot2 ~= nil then
						item.slot2:DeleteMe()
					end
					if item.data1 ~= nil then
						item.data1:DeleteMe()
					end
					if item.data2 ~= nil then
						item.data2:DeleteMe()
					end
					if item.layout ~= nil then
						item.layout:DeleteMe()
					end
					if item.msgExt ~= nil then
						item.msgExt:DeleteMe()
					end
				end
			end
		end
		self.multiPageList = nil
	end
	if self.singleLayout ~= nil then
		self.singleLayout:DeleteMe()
		self.singleLayout = nil
	end
	if self.multiLayout ~= nil then
		self.multiLayout:DeleteMe()
		self.multiLayout = nil
	end
	if self.singleTabbed ~= nil then
		self.singleTabbed :DeleteMe()
		self.singleTabbed = nil
	end
	if self.multiTabbed ~= nil then
		self.multiTabbed:DeleteMe()
		self.multiTabbed = nil
	end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function BackendTwoExchange:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.backend_two_excharge))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.titleText1 = t:Find("Title/Text1"):GetComponent(Text)
    self.titleText2 = t:Find("Title/Text2"):GetComponent(Text)
    self.singleTitleText = t:Find("Single/Title/Text"):GetComponent(Text)
    self.timeText = t:Find("Single/Title/Clock/Text"):GetComponent(Text)
    self.singleContainer = t:Find("Single/Scroll/Container")
    self.singlePage = t:Find("Single/Scroll/Page").gameObject
    self.singleToggleContainer = t:Find("Single/ToggleGroup")
    self.singleToggleCloner = t:Find("Single/ToggleGroup/Toggle"):GetComponent(Toggle)
    self.singleLayout = LuaBoxLayout.New(self.singleContainer, {axis = BoxLayoutAxis.X, cspacing = 0})
	self.singleTabbed = TabbedPanel.New(self.singleContainer.parent.gameObject, 1, 542, 0.6)

    self.multiTitleText = t:Find("Multi/Title/Text"):GetComponent(Text)
    self.multiContainer = t:Find("Multi/Scroll/Container")
    self.multiPage = t:Find("Multi/Scroll/Page").gameObject
    self.multiLayout = LuaBoxLayout.New(self.multiContainer, {axis = BoxLayoutAxis.X, cspacing = 0})
	self.multiTabbed = TabbedPanel.New(self.multiContainer.parent.gameObject, 1, 540, 0.6)

	self.singlePage:SetActive(false)
	self.multiPage:SetActive(false)
end

function BackendTwoExchange:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function BackendTwoExchange:OnOpen()
	local model = self.model
    self:RemoveListeners()
	EventMgr.Instance:AddListener(event_name.backend_campaign_change, self.reloadListener)
	self.mgr.onTick:AddListener(self.timeListener)

    self.campId = self.openArgs.campId
    self.menuId = self.openArgs.menuId

    self.menuData = self.model.backendCampaignTab[self.campId].menu_list[self.menuId]

	self.singleData = {}
	self.multiData = {}
	for _,v in pairs(self.menuData.camp_list) do
		if v.val1 ~= 1 then
			table.insert(self.multiData, v)
		else
			table.insert(self.singleData, v)
		end
	end

    self:ReloadSingleList()
	self:ReloadMultiList()
	self:OnTime()
	self:InitInfo()
end

function BackendTwoExchange:OnHide()
    self:RemoveListeners()
end

function BackendTwoExchange:RemoveListeners()
	self.mgr.onTick:RemoveListener(self.timeListener)
	EventMgr.Instance:RemoveListener(event_name.backend_campaign_change, self.reloadListener)
end

function BackendTwoExchange:ReloadSingleList()
	local singleData = self.singleData
	local tab = nil

	for i,v in ipairs(singleData) do
		tab = self.singlePageList[math.ceil(i / self.singlePerLine)]
		if tab == nil then
			tab = {}
			tab.obj = GameObject.Instantiate(self.singlePage)
			tab.obj.name = tostring(math.ceil(i / self.singlePerLine))
			tab.trans = tab.obj.transform
			tab.items = {}
			for j=1,tab.trans.childCount do
				local t = tab.trans:GetChild(j - 1)
				tab.items[j] = {}
				tab.items[j].obj = t.gameObject
				tab.items[j].slot = ItemSlot.New()
				tab.items[j].data = ItemData.New()
				NumberpadPanel.AddUIChild(t:Find("Con"), tab.items[j].slot.gameObject)
				tab.items[j].pointText = t:Find("Points"):GetComponent(Text)
				tab.items[j].btn = t:Find("Button"):GetComponent(Button)
				tab.items[j].btnText = t:Find("Button/Text"):GetComponent(Text)
			end
			self.singlePageList[math.ceil(i / self.singlePerLine)] = tab
			self.singleLayout:AddCell(tab.obj)
		end
		local itemTab = tab.items[(i - 1) % self.singlePerLine + 1]
		local baseData = DataItem.data_get[v.items[1].base_id]
		if baseData ~= nil then
			itemTab.data:SetBase(baseData)
			itemTab.slot:SetAll(itemTab.data, {inbag = false, nobutton = true})
			itemTab.slot:SetNum(v.items[1].num)
		else
			itemTab.slot:Default()
		end
		itemTab.obj:SetActive(true)
        tab.obj:SetActive(true)
		itemTab.btn.onClick:RemoveAllListeners()
		itemTab.btn.onClick:AddListener(function() self.mgr:send14053(self.campId, self.menuId, v.n, 1) end)
	end
	for i=(#singleData - 1)%self.singlePerLine + 2, self.singlePerLine do
		tab.items[i].obj:SetActive(false)
	end
	local endIndex = math.ceil(#singleData / self.singlePerLine)
	for i=endIndex + 1, #self.singlePageList do
		self.singlePageList[i].obj:SetActive(false)
	end
    self.singleTabbed:SetPageCount(endIndex)
end

function BackendTwoExchange:ReloadMultiList()
	local multiData = self.multiData
	local tab = nil

	for i,v in ipairs(multiData) do
		tab = self.multiPageList[math.ceil(i / self.multiPerLine)]
		if tab == nil then
			tab = {}
			tab.obj = GameObject.Instantiate(self.multiPage)
			tab.obj.name = tostring(math.ceil(i / self.multiPerLine))
			tab.trans = tab.obj.transform
			tab.items = {}
			for j=1,tab.trans.childCount do
				local t = tab.trans:GetChild(j - 1)
				tab.items[j] = {}
				tab.items[j].obj = t.gameObject
				tab.items[j].layout = LuaBoxLayout.New(t:Find("Container"), {axis = BoxLayoutAxis.X, cspacing = 0})
				tab.items[j].slot1 = ItemSlot.New()
				tab.items[j].data1 = ItemData.New()
				NumberpadPanel.AddUIChild(t:Find("Item1"), tab.items[j].slot1.gameObject)
				tab.items[j].slot2 = ItemSlot.New()
				tab.items[j].data2 = ItemData.New()
				NumberpadPanel.AddUIChild(t:Find("Item2"), tab.items[j].slot2.gameObject)
				tab.items[j].msgExt = MsgItemExt.New(t:Find("Button/Text"):GetComponent(Text), 110, 17, 19)
				tab.items[j].btn = t:Find("Button"):GetComponent(Button)
			end
			self.multiPageList[math.ceil(i / self.multiPerLine)] = tab
			self.multiLayout:AddCell(tab.obj)
		end
		local itemTab = tab.items[(i - 1) % self.multiPerLine + 1]
		itemTab.layout:ReSet()
		for j=1,2 do
			if v.items[j] ~= nil then
				local baseData = DataItem.data_get[v.items[j].base_id]
				if baseData ~= nil then
					itemTab["data"..j]:SetBase(baseData)
					itemTab["slot"..j]:SetAll(itemTab["data"..j], {inbag = false, nobutton = true})
					itemTab["slot"..j]:SetNum(v.items[j].num)
				else
					itemTab["slot"..j]:Default()
				end
				itemTab["slot"..j].gameObject:SetActive(true)
				itemTab.layout:AddCell(itemTab["slot"..j].transform.parent.gameObject)
			else
				itemTab["slot"..j].gameObject:SetActive(false)
			end
		end
		itemTab.obj:SetActive(true)
        tab.obj:SetActive(true)
		if #v.loss_items == 0 then
			itemTab.msgExt:SetData(TI18N("领取"))
		elseif #v.loss_items == 1 and GlobalEumn.AssetName[v.loss_items[1].base_id] ~= nil then
			itemTab.msgExt:SetData(string.format(TI18N("%s{assets_2, %s}购买"), tostring(v.loss_items[1].num), tostring(v.loss_items[1].base_id)))
		else
			itemTab.msgExt:SetData(TI18N("兑换"))
		end
		local size = itemTab.msgExt.contentRect.sizeDelta
		itemTab.msgExt.contentRect.anchoredPosition = Vector2(-size.x / 2, size.y / 2)
		itemTab.btn.onClick:RemoveAllListeners()
		itemTab.btn.onClick:AddListener(function() self.mgr:send14053(self.campId, self.menuId, v.n, 1) end)
	end

	for i=(#multiData - 1)%self.multiPerLine + 2, self.multiPerLine do
		tab.items[i].obj:SetActive(false)
	end
	local endIndex = math.ceil(#multiData / self.multiPerLine)
	for i=endIndex + 1,#self.multiPageList do
		self.multiPageList[i].obj:SetActive(false)
	end
    self.multiTabbed:SetPageCount(endIndex)
end

function BackendTwoExchange:OnTime()
	local model = self.model
	local end_time = self.menuData.end_time
	self.leftDays, self.leftHours, self.leftMinutes, self.leftSeconds = BaseUtils.time_gap_to_timer(end_time - BaseUtils.BASE_TIME)
	if self.leftDays > 0 then
		self.timeText.text = string.format(self.timeFormat1, tostring(self.leftDays), tostring(self.leftHours))
	elseif self.leftHours > 0 then
		self.timeText.text = string.format(self.timeFormat2, tostring(self.leftHours), tostring(self.leftMinutes))
	elseif self.leftMinutes > 0 then
		self.timeText.text = string.format(self.timeFormat3, tostring(self.leftMinutes), tostring(self.leftSeconds))
	elseif self.leftSeconds > 0 then
		self.timeText.text = string.format(self.timeFormat4, tostring(self.leftSeconds))
	else
		self.timeText.text = TI18N("活动已结束")
	end
end

function BackendTwoExchange:InitInfo()
	self.titleText1.text = self.menuData.title
	self.titleText2.text = self.menuData.title2
end


