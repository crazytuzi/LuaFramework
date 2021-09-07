-- -------------------------------
-- 分享兑换商城元素
-- hosr
-- -------------------------------
ShareShopItem = ShareShopItem or BaseClass()

function ShareShopItem:__init(gameObject, parent, callback)
	self.parent = parent
	self.callback = callback
	self.gameObject = gameObject
	self.transform = gameObject.transform

	self:InitPanel()
end

function ShareShopItem:__delete()
	if self.imgLoader ~= nil then
	    self.imgLoader:DeleteMe()
	    self.imgLoader = nil
	end

	if self.imgLoader2 ~= nil then
	    self.imgLoader2:DeleteMe()
	    self.imgLoader2 = nil
	end

	self.icon.sprite = nil
	self.img.sprite = nil
end

function ShareShopItem:InitPanel()
	self.gameObject:GetComponent(Button).onClick:AddListener(function() self:ClickSelf() end)
	self.select = self.transform:Find("Select").gameObject
	self.select:SetActive(false)
	self.name = self.transform:Find("Name"):GetComponent(Text)
	self.price = self.transform:Find("PriceBg/Price"):GetComponent(Text)
	self.icon = self.transform:Find("PriceBg/Currency")
	if self.imgLoader == nil then
	    local go = self.icon.gameObject
	    self.imgLoader = SingleIconLoader.New(go)
	end
	self.imgLoader:SetSprite(SingleIconType.Item, 90026)

	self.num = self.transform:Find("Num"):GetComponent(Text)
	self.img = self.transform:Find("IconBg/Icon")
	self.transform:Find("IconBg"):GetComponent(Button).enabled = false
	self.tips = self.transform:Find("TipsLabel").gameObject
	self.tips:SetActive(false)
	self.tipsTxt = self.transform:Find("TipsLabel/Text"):GetComponent(Text)
	self.discount = self.transform:Find("Discount").gameObject
	self.discount:SetActive(false)
	self.discountTxt = self.transform:Find("Discount/Discount"):GetComponent(Text)
	self.soldcout = self.transform:Find("SoldoutImage").gameObject
end

-- [DEBUG] ddddddddddddddddddddd = {
--     tab2 = 8,
--     num = 1,
--     tab = 2,
--     label = 0,
--     id = 1000,
--     limit_role = 10,
--     price = 500,
--     base_id = 29101,
-- }
function ShareShopItem:SetData(data)
	self.data = data
	self.base = DataItem.data_get[data.base_id]
	self.name.text = string.format("<color='#c7f9ff'>%s</color>", self.base.name)
	self.num.text = data.num
	self.price.text = data.price

	if self.imgLoader2 == nil then
	    local go = self.img.gameObject
	    self.imgLoader2 = SingleIconLoader.New(go)
	end
	self.imgLoader2:SetSprite(SingleIconType.Item, self.base.icon)


	local bool = false
	local buyNum = ShopManager.Instance.model.hasBuyList[data.id] or 0
	self.soldcout:SetActive(data.limit_role == buyNum)
end

function ShareShopItem:Select(bool)
	self.select:SetActive(bool)
end

function ShareShopItem:ClickSelf()
	if self.data ~= nil and self.callback ~= nil then
		self.callback(self)
	end
end