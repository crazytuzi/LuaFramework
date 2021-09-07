-- ------------------------------
-- 幻化手册商城结构项
-- hosr
-- ------------------------------
HandbookShopItem = HandbookShopItem or BaseClass()

function HandbookShopItem:__init(gameObject, parent, callback)
	self.parent = parent
	self.callback = callback
	self.gameObject = gameObject
	self.transform = gameObject.transform

	self:InitPanel()
end

function HandbookShopItem:__delete()
	if self.iconloader ~= nil then
		self.iconloader:DeleteMe()
		self.iconloader = nil
	end
	if self.imgiconloader ~= nil then
		self.imgiconloader:DeleteMe()
		self.imgiconloader = nil
	end
	self.icon.sprite = nil
	self.img.sprite = nil
end

function HandbookShopItem:InitPanel()
	self.gameObject:GetComponent(Button).onClick:AddListener(function() self:ClickSelf() end)
	self.select = self.transform:Find("Select").gameObject
	self.select:SetActive(false)
	self.name = self.transform:Find("Name"):GetComponent(Text)
	self.price = self.transform:Find("PriceBg/Price"):GetComponent(Text)
	self.icon = self.transform:Find("PriceBg/Currency"):GetComponent(Image)
	self.iconloader = SingleIconLoader.New(self.icon.gameObject)
	self.iconloader:SetSprite(SingleIconType.Item, 90024)
	self.num = self.transform:Find("Num"):GetComponent(Text)
	self.img = self.transform:Find("IconBg/Icon"):GetComponent(Image)
	self.tips = self.transform:Find("TipsLabel").gameObject
	self.tips:SetActive(false)
	self.tipsTxt = self.transform:Find("TipsLabel/Text"):GetComponent(Text)
	self.discount = self.transform:Find("Discount").gameObject
	self.discount:SetActive(false)
	self.discountTxt = self.transform:Find("Discount/Discount"):GetComponent(Text)
	self.soldcout = self.transform:Find("SoldoutImage").gameObject
end

--{uint16, idx, "道具编号"}
--,{uint32, id, "道具id"}
--,{uint32, num, "道具数量"}
--,{uint32, val,  "价值"}
--,{uint8,  flag,  "1:已买,0:未买"}
function HandbookShopItem:SetData(data)
	self.data = data
	self.base = DataItem.data_get[data.id]
	self.name.text = self.base.name
	self.num.text = data.num
	self.price.text = data.val
	self.imgiconloader = SingleIconLoader.New(self.img.gameObject)
	self.imgiconloader:SetSprite(SingleIconType.Item, self.base.icon)
	self.soldcout:SetActive(data.flag == 1)

	local need = HandbookManager.Instance.model:GetIdNeedById(self.data.id)
	if need then
		self.discount:SetActive(false)
		self.tips:SetActive(true)
		self.tips.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Tipslabel4")
		self.tipsTxt.text = TI18N("需求")
	else
		self.tips:SetActive(false)
	end
end

function HandbookShopItem:Select(bool)
	self.select:SetActive(bool)
end

function HandbookShopItem:ClickSelf()
	if self.data ~= nil and self.callback ~= nil then
		self.callback(self)
	end
end