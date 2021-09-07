-- ----------------------------------
-- 分享兑换界面
-- hosr
-- ----------------------------------
ShareShopWindow = ShareShopWindow or BaseClass(BaseWindow)

function ShareShopWindow:__init(model)
	self.model = model
    self.name = "ShareShopWindow"
    self.windowId = WindowConfig.WinID.share_shop

	self.resList = {
		{file = AssetConfig.shareshopwindow, type = AssetType.Main},
		{file = AssetConfig.shareres, type = AssetType.Dep},
	}

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.toggleList = {}
    self.pageList = {}
    self.itemList = {}
    self.listener = function() self:SetData() end
    self.assetListener = function() self:UpdateAssets() end
    self.currItem = nil
    self.currPage = 1
    self.currCount = 1
end

function ShareShopWindow:__delete()
	if self.imgLoader ~= nil then
	    self.imgLoader:DeleteMe()
	    self.imgLoader = nil
	end
	if self.imgLoader2 ~= nil then
	    self.imgLoader2:DeleteMe()
	    self.imgLoader2 = nil
	end
	if self.imgLoader3 ~= nil then
	    self.imgLoader3:DeleteMe()
	    self.imgLoader3 = nil
	end

	EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.assetListener)
	ShopManager.Instance.onUpdateBuyPanel:RemoveListener(self.listener)
	if self.tabbedPanel ~= nil then
		self.tabbedPanel:DeleteMe()
		self.tabbedPanel = nil
	end

	if self.itemList ~= nil then
		for i,item in ipairs(self.itemList) do
			item:DeleteMe()
		end
		self.itemList = nil
	end
	if self.msgItem ~= nil then
		self.msgItem:DeleteMe()
		self.msgItem = nil
	end
end

function ShareShopWindow:OnShow()
    self.currCount = 1
	if self.currItem ~= nil then
		self.currItem:Select(false)
	end
	self.currItem = nil
	self.info:SetActive(false)
	self.girl:SetActive(true)

	self:Update()
	EventMgr.Instance:AddListener(event_name.role_asset_change, self.assetListener)
	ShopManager.Instance.onUpdateBuyPanel:AddListener(self.listener)
end

function ShareShopWindow:OnHide()
	EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.assetListener)
	ShopManager.Instance.onUpdateBuyPanel:RemoveListener(self.listener)
end

function ShareShopWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shareshopwindow))
    self.gameObject.name = "ShareShopWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindowById(WindowConfig.WinID.share_shop) end)

    self.pageBase = self.transform:Find("Main/SelectPanel/GoodsPanel/ItemPage").gameObject
    self.pageBase:SetActive(false)

    self.panel = self.transform:Find("Main/SelectPanel/GoodsPanel/Panel").gameObject
    self.container = self.transform:Find("Main/SelectPanel/GoodsPanel/Panel/Container").gameObject
    self.containerRect = self.container:GetComponent(RectTransform)

    self.toggleBase = self.transform:Find("Main/SelectPanel/ToggleGroup/Toggle").gameObject
    self.toggleContainer = self.transform:Find("Main/SelectPanel/ToggleGroup").gameObject
    table.insert(self.toggleList, self.toggleBase:GetComponent(Toggle))

    self.girl = self.transform:Find("Main/InfoArea/GoodsTips/GirlGuide").gameObject
    self.girl.transform:Find("Desc"):GetComponent(Text).text = ""
    -- self.msgItem = MsgItemExt.New(self.girl.transform:Find("Desc"):GetComponent(Text), 211, 16)
    -- self.msgItem:SetData("1、每天{string_2,#ffff00,22点}刷新碎片 \n2、分解图鉴碎片可获得{assets_2,90026} \n3、万能碎片可用于{string_2,#ffff00,所有图鉴}")
    self.info = self.transform:Find("Main/InfoArea/GoodsTips/GoodsInfo").gameObject
    local transform = self.info.transform
    self.name = transform:Find("Name"):GetComponent(Text)
    self.desc = MsgItemExt.New(transform:Find("Describe"):GetComponent(Text), 200, 16)
    self.limit = transform:Find("Restraint"):GetComponent(Text)

    transform = self.transform:Find("Main/InfoArea/BuyArea")
    self.count = transform:Find("BuyCount/CountBg/Count"):GetComponent(Text)
    -- transform:Find("BuyCount/CountBg"):GetComponent(Button).onClick:AddListener(function() self:OpenNumpad() end)
    transform:Find("BuyCount/AddBtn"):GetComponent(Button).onClick:AddListener(function() self:ClickAdd() end)
    transform:Find("BuyCount/MinusBtn"):GetComponent(Button).onClick:AddListener(function() self:ClickMinus() end)
    self.price = transform:Find("BuyPrice/PriceBg/Price"):GetComponent(Text)
    self.priceIcon = transform:Find("BuyPrice/PriceBg/Currency")
    self.has = transform:Find("OwnAsset/AssetBg/Asset"):GetComponent(Text)
    self.hasIcon = transform:Find("OwnAsset/AssetBg/Currency")
    transform:Find("BtnArea/Button"):GetComponent(Button).onClick:AddListener(function() self:ClickBuy() end)
    transform:Find("BtnArea/Refresh"):GetComponent(Button).onClick:AddListener(function() self:ClickRefresh() end)
    if self.imgLoader == nil then
	    local go = transform:Find("BtnArea/Refresh/Icon").gameObject
	    self.imgLoader = SingleIconLoader.New(go)
	end
	self.imgLoader:SetSprite(SingleIconType.Item, 90026)

    self.val = transform:Find("BtnArea/Refresh/Val"):GetComponent(Text)
    self.val.text = "<color='#ffff00'>2</color>"

	if self.imgLoader2 == nil then
	    local go = self.priceIcon.gameObject
	    self.imgLoader2 = SingleIconLoader.New(go)
	end
	self.imgLoader2:SetSprite(SingleIconType.Item, 90026)

	if self.imgLoader3 == nil then
	    local go = self.hasIcon.gameObject
	    self.imgLoader3 = SingleIconLoader.New(go)
	end
	self.imgLoader3:SetSprite(SingleIconType.Item, 90026)

    self:OnShow()
end

function ShareShopWindow:Update()
	self.has.text = RoleManager.Instance.RoleData:GetMyAssetById(90026)
	self:SetData()
end

function ShareShopWindow:SetData()
	self.list = ShopManager.Instance.model.datalist[2][8]
	self:UpdatePage()
	self:UpdateData()
	self:UpdateInfo(self.itemList[1])
end

function ShareShopWindow:UpdateData()
	for i,item in ipairs(self.itemList) do
		local data = self.list[i]
		if data == nil then
			item.gameObject:SetActive(false)
		else
			item:SetData(data)
			item.gameObject:SetActive(true)
		end
	end
	self.tabbedPanel:TurnPage(self.currPage)
end

function ShareShopWindow:CreatePage(index)
	local page = GameObject.Instantiate(self.pageBase)
	local transform = page.transform
	local rect = page:GetComponent(RectTransform)
	transform:SetParent(self.container.transform)
	transform.localScale = Vector3.one
	transform.localPosition = Vector3.zero
	rect.anchoredPosition = Vector2((index - 1) * 494, -10)
	local len = transform.childCount
	for i = 1, len do
		local item = ShareShopItem.New(transform:GetChild(i - 1).gameObject, self, function(data) self:UpdateInfo(data) end)
		table.insert(self.itemList, item)
	end
	page:SetActive(true)
	table.insert(self.pageList, page)
end

function ShareShopWindow:UpdatePage()
	self.maxPage = math.ceil(#self.list / 8)
	for i = 1, self.maxPage do
		local page = self.pageList[i]
		if page == nil then
			page = self:CreatePage(i)
		end
	end
	self.containerRect.sizeDelta = Vector2(494 * self.maxPage, 394)

	if self.tabbedPanel == nil then
	    self.tabbedPanel = TabbedPanel.New(self.panel, self.maxPage, 494)
	    self.tabbedPanel.MoveEndEvent:Add(function(currentPage, direction) self:OnMoveEnd(currentPage, direction) end)
	else
		self.tabbedPanel:SetPageCount(self.maxPage)
	end

	local needToggle = self.maxPage - 1
	for i = 1, needToggle do
		local toggle = GameObject.Instantiate(self.toggleBase)
		local transform = toggle.transform
		transform:SetParent(self.toggleContainer.transform)
		transform.localScale = Vector3.one
		table.insert(self.toggleList, toggle:GetComponent(Toggle))
	end
end

function ShareShopWindow:OnMoveEnd(currentPage, direction)
	self.currPage = currentPage
	local toggle = self.toggleList[currentPage]
	if toggle ~= nil then
		toggle.isOn = true
	end
end

function ShareShopWindow:ClickAdd()
	if self.currItem == nil or self.currItem.data == nil then
		return
	end

	if self.currCount == self.currItem.data.limit_role then
		NoticeManager.Instance:FloatTipsByString(TI18N("不能购买更多了"))
		return
	end
	self.currCount = self.currCount + 1
    self.count.text = self.currCount
end

function ShareShopWindow:ClickMinus()
	if self.currItem == nil or self.currItem.data == nil then
		return
	end

	if self.currCount == 1 then
		NoticeManager.Instance:FloatTipsByString(TI18N("最少购买一个"))
		return
	end
    self.currCount = self.currCount - 1
    self.count.text = self.currCount
end

function ShareShopWindow:ClickBuy()
	if self.currItem ~= nil and self.currItem.data ~= nil then
		ShopManager.Instance:send11303(self.currItem.data.id, self.currCount)
	else
		NoticeManager.Instance:FloatTipsByString(TI18N("先选择要购买的道具"))
	end
end

-- 根据选中的道具更新右侧信息
function ShareShopWindow:UpdateInfo(item)
	self.currCount = 1
	self.count.text = self.currCount
	self.info:SetActive(true)
	self.girl:SetActive(false)

	if self.currItem ~= nil then
		self.currItem:Select(false)
	end
	self.currItem = item
	self.currItem:Select(true)

	local base = self.currItem.base
	local data = self.currItem.data
	self.name.text = ColorHelper.color_item_name(base.quality, base.name)
	self.desc:SetData(base.desc)
	local shopData = ShopManager.Instance.itemPriceTab[data.id]
	if shopData.limit_type == "day" then
		self.limit.text = string.format(TI18N("每日限购:%s"), data.limit_role)
	elseif shopData.limit_type == "week" then
		self.limit.text = string.format(TI18N("每周限购:%s"), data.limit_role)
	elseif shopData.limit_type == "forever" then
		self.limit.text = string.format(TI18N("角色限购:%s"), data.limit_role)
	elseif shopData.limit_type == "normal" then
		self.limit.text = ""
	end
	self.price.text = data.price
	self.has.text = RoleManager.Instance.RoleData:GetMyAssetById(90026)
end

function ShareShopWindow:ClickRefresh()
end

function ShareShopWindow:UpdateAssets()
	if self.has ~= nil then
		self.has.text = RoleManager.Instance.RoleData:GetMyAssetById(90026)
	end
end