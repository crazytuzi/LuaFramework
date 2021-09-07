-- -------------------------------
-- 幻化手册兑换商店
-- hosr
-- -------------------------------
HandbookShopPanel = HandbookShopPanel or BaseClass(BasePanel)

function HandbookShopPanel:__init(parent)
	self.parent = parent

	self.resList = {
		{file = AssetConfig.handbook_shop, type = AssetType.Main},
		{file = AssetConfig.handbook_res, type = AssetType.Dep},
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
    self.iconloader = {}
end

function HandbookShopPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.handbook_shopupdate, self.listener)
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.assetListener)
    for k,v in pairs(self.iconloader) do
        v:DeleteMe()
    end
    self.iconloader = {}
	if self.tabbedPanel ~= nil then
		self.tabbedPanel:DeleteMe()
		self.tabbedPanel = nil
	end
	if self.priceIcon ~= nil then
		self.priceIcon.sprite = nil
		self.priceIcon = nil
	end
	if self.hasIcon ~= nil then
		self.hasIcon.sprite = nil
		self.hasIcon = nil
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

function HandbookShopPanel:OnShow()
	if self.currItem ~= nil then
		self.currItem:Select(false)
	end
	self.currItem = nil
	self.info:SetActive(false)
	self.girl:SetActive(true)

	self:Update()
	EventMgr.Instance:AddListener(event_name.handbook_shopupdate, self.listener)
	EventMgr.Instance:AddListener(event_name.role_asset_change, self.assetListener)
end

function HandbookShopPanel:OnHide()
	EventMgr.Instance:RemoveListener(event_name.handbook_shopupdate, self.listener)
	EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.assetListener)
end

function HandbookShopPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.handbook_shop))
    self.gameObject.name = "HandbookShopPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.mainTransform)
    self.transform.localScale = Vector3.one
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.rect.anchoredPosition = Vector2(0, -10)

    self.pageBase = self.transform:Find("SelectPanel/GoodsPanel/ItemPage").gameObject
    self.pageBase:SetActive(false)

    self.panel = self.transform:Find("SelectPanel/GoodsPanel/Panel").gameObject
    self.container = self.transform:Find("SelectPanel/GoodsPanel/Panel/Container").gameObject
    self.containerRect = self.container:GetComponent(RectTransform)

    self.toggleBase = self.transform:Find("SelectPanel/ToggleGroup/Toggle").gameObject
    self.toggleContainer = self.transform:Find("SelectPanel/ToggleGroup").gameObject
    table.insert(self.toggleList, self.toggleBase:GetComponent(Toggle))

    self.girl = self.transform:Find("InfoArea/GoodsTips/GirlGuide").gameObject
    self.msgItem = MsgItemExt.New(self.girl.transform:Find("Desc"):GetComponent(Text), 211, 16)
    self.msgItem:SetData("1、每天{string_2,#ffff00,21点}刷新碎片 \n2、分解图鉴碎片可获得{assets_2,90024} \n3、万能碎片可用于{string_2,#ffff00,所有图鉴}")
    self.info = self.transform:Find("InfoArea/GoodsTips/GoodsInfo").gameObject
    local transform = self.info.transform
    self.name = transform:Find("Name"):GetComponent(Text)
    self.desc = MsgItemExt.New(transform:Find("Describe"):GetComponent(Text), 200, 16)
    self.limit = transform:Find("Restraint"):GetComponent(Text)

    transform = self.transform:Find("InfoArea/BuyArea")
    self.count = transform:Find("BuyCount/CountBg/Count"):GetComponent(Text)
    -- transform:Find("BuyCount/CountBg"):GetComponent(Button).onClick:AddListener(function() self:OpenNumpad() end)
    transform:Find("BuyCount/AddBtn"):GetComponent(Button).onClick:AddListener(function() self:ClickAdd() end)
    transform:Find("BuyCount/MinusBtn"):GetComponent(Button).onClick:AddListener(function() self:ClickMinus() end)
    self.price = transform:Find("BuyPrice/PriceBg/Price"):GetComponent(Text)
    self.priceIcon = transform:Find("BuyPrice/PriceBg/Currency"):GetComponent(Image)
    self.has = transform:Find("OwnAsset/AssetBg/Asset"):GetComponent(Text)
    self.hasIcon = transform:Find("OwnAsset/AssetBg/Currency"):GetComponent(Image)
    transform:Find("BtnArea/Button"):GetComponent(Button).onClick:AddListener(function() self:ClickBuy() end)
    transform:Find("BtnArea/Refresh"):GetComponent(Button).onClick:AddListener(function() self:ClickRefresh() end)
    self.iconloader[1] = SingleIconLoader.New(transform:Find("BtnArea/Refresh/Icon").gameObject)
    self.iconloader[1]:SetSprite(SingleIconType.Item, 90024)
    self.val = transform:Find("BtnArea/Refresh/Val"):GetComponent(Text)
    self.val.text = "2"

    self.iconloader[2] = SingleIconLoader.New(self.priceIcon.gameObject)
    self.iconloader[2]:SetSprite(SingleIconType.Item, 90024)
    self.iconloader[3] = SingleIconLoader.New(self.hasIcon.gameObject)
    self.iconloader[3]:SetSprite(SingleIconType.Item, 90024)

    self:OnShow()
end

function HandbookShopPanel:Update()
	self.has.text = RoleManager.Instance.RoleData:GetMyAssetById(90024)
    if HandbookManager.Instance.update_time_stemp < BaseUtils.BASE_TIME then
    	HandbookManager.Instance:Send17106()
    end
    self:SetData()
end

function HandbookShopPanel:SetData()
	self.list = HandbookManager.Instance.shopItemList
	self:UpdatePage()
	self:UpdateData()
end

function HandbookShopPanel:UpdateData()
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
	-- if self.currItem ~= nil then
	-- 	self:UpdateInfo(self.currItem)
	-- else
	-- 	self.info:SetActive(false)
	-- 	self.girl:SetActive(true)
	-- end
end

function HandbookShopPanel:CreatePage(index)
	local page = GameObject.Instantiate(self.pageBase)
	local transform = page.transform
	local rect = page:GetComponent(RectTransform)
	transform:SetParent(self.container.transform)
	transform.localScale = Vector3.one
	transform.localPosition = Vector3.zero
	rect.anchoredPosition = Vector2((index - 1) * 494, -10)
	local len = transform.childCount
	for i = 1, len do
		local item = HandbookShopItem.New(transform:GetChild(i - 1).gameObject, self, function(data) self:UpdateInfo(data) end)
		table.insert(self.itemList, item)
	end
	page:SetActive(true)
	table.insert(self.pageList, page)
end

function HandbookShopPanel:UpdatePage()
	self.maxPage = math.ceil(#self.list / 8)
	for i = 1, self.maxPage do
		local page = self.pageList[i]
		if page == nil then
			page = self:CreatePage(i)
		end
	end

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

function HandbookShopPanel:OnMoveEnd(currentPage, direction)
	self.currPage = currentPage
	local toggle = self.toggleList[currentPage]
	if toggle ~= nil then
		toggle.isOn = true
	end
end

function HandbookShopPanel:ClickAdd()
	NoticeManager.Instance:FloatTipsByString(TI18N("不能购买更多了"))
end

function HandbookShopPanel:ClickMinus()
	NoticeManager.Instance:FloatTipsByString(TI18N("最少购买一个"))
end

function HandbookShopPanel:ClickBuy()
	if self.currItem ~= nil and self.currItem.data ~= nil then
		HandbookManager.Instance:Send17107(self.currItem.data.idx)
	else
		NoticeManager.Instance:FloatTipsByString(TI18N("先选择要购买的道具"))
	end
end

-- 根据选中的道具更新右侧信息
function HandbookShopPanel:UpdateInfo(item)
	self.info:SetActive(true)
	self.girl:SetActive(false)

	if self.currItem ~= nil then
		self.currItem:Select(false)
	end
	self.currItem = item
	self.currItem:Select(true)

	local base = self.currItem.base
	local data = self.currItem.data
	self.name.text = base.name
	self.desc:SetData(base.desc)
	self.limit.text = ""
	self.price.text = data.val
	self.has.text = RoleManager.Instance.RoleData:GetMyAssetById(90024)
end

function HandbookShopPanel:ClickRefresh()
	HandbookManager.Instance:Send17109()
end

function HandbookShopPanel:UpdateAssets()
	if self.has ~= nil then
		self.has.text = RoleManager.Instance.RoleData:GetMyAssetById(90024)
	end
end