--作者:hzf
--01/09/2017 11:15:33
--功能:子女系统选择容器

ChildrenContainerPanel = ChildrenContainerPanel or BaseClass(BasePanel)
function ChildrenContainerPanel:__init(parent)
	self.parent = parent
	self.resList = {
		{file = AssetConfig.childrencontainerpanel, type = AssetType.Main},
		{file = AssetConfig.childrentextures, type = AssetType.Dep},

	}
	--self.OnOpenEvent:Add(function() self:OnOpen() end)
	--self.OnHideEvent:Add(function() self:OnHide() end)
	self.ShopItem = {
		[1] = 2101,
		[2] = 2102
	}
	self.ShopId = {
		[1] = 2101,
		[2] = 2102
	}
	self.icondata = {
		[1] = 23804,
		[2] = 23805
	}
	self.hasInit = false

	self.LiconLoader = nil
	self.RiconLoader = nil
end

function ChildrenContainerPanel:__delete()
	if self.LiconLoader ~= nil then
		self.LiconLoader:DeleteMe()
		self.LiconLoader = nil
	end

	if self.RiconLoader ~= nil then
		self.RiconLoader:DeleteMe()
		self.RiconLoader = nil
	end

	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function ChildrenContainerPanel:OnHide()

end

function ChildrenContainerPanel:OnOpen()

end

function ChildrenContainerPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.childrencontainerpanel))
	self.gameObject.name = "ChildrenContainerPanel"

	self.transform = self.gameObject.transform
	UIUtils.AddUIChild(MainUIManager.Instance.MainUICanvasView.gameObject, self.gameObject)
	self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function()
		self:OnClose()
	end)
	-- self.Tips = self.transform:Find("Tips")
	-- self.Title = self.transform:Find("Tips/Title")

	self.transform:Find("Tips/LButton"):GetComponent(Button).onClick:AddListener(function()
		local itemdata = DataItem.data_get[self.icondata[1]]
		TipsManager.Instance:ShowItem({["gameObject"] = self.transform:Find("Tips/LButton").gameObject, ["itemData"] = itemdata, extra = { nobutton = true } })
	end)
	-- self.Image = self.transform:Find("Tips/LButton/Image"):GetComponent(Image)
	self.LText = self.transform:Find("Tips/LButton/Text"):GetComponent(Text)
	self.Licon = self.transform:Find("Tips/LButton/icon"):GetComponent(Image)
	self.LText.text = DataItem.data_get[self.icondata[1]].name

    if self.LiconLoader == nil then
        local go = self.Licon.gameObject
        self.LiconLoader = SingleIconLoader.New(go)
    end
    self.LiconLoader:SetSprite(SingleIconType.Item, DataItem.data_get[self.icondata[1]].icon)

	self.transform:Find("Tips/RButton"):GetComponent(Button).onClick:AddListener(function()
		local itemdata = DataItem.data_get[self.icondata[2]]
		TipsManager.Instance:ShowItem({["gameObject"] = self.transform:Find("Tips/RButton").gameObject, ["itemData"] = itemdata, extra = { nobutton = true } })
	end)
	-- self.Image = self.transform:Find("Tips/RButton/Image"):GetComponent(Image)
	self.RText = self.transform:Find("Tips/RButton/Text"):GetComponent(Text)
	self.Ricon = self.transform:Find("Tips/RButton/icon"):GetComponent(Image)
	self.RText.text = DataItem.data_get[self.icondata[2]].name
    if self.RiconLoader == nil then
        local go = self.Ricon.gameObject
        self.RiconLoader = SingleIconLoader.New(go)
    end
    self.RiconLoader:SetSprite(SingleIconType.Item, DataItem.data_get[self.icondata[2]].icon)

	-- self.LNeedText = self.transform:Find("Tips/LNeedText"):GetComponent(Text)
	-- self.RNeedText = self.transform:Find("Tips/RNeedText"):GetComponent(Text)
	self.LExt = MsgItemExt.New(self.transform:Find("Tips/LNeedText"):GetComponent(Text), 149.7, 16, 19)
	self.RExt = MsgItemExt.New(self.transform:Find("Tips/RNeedText"):GetComponent(Text), 149.7, 16, 19)
	self:InitPrice()
	self.LEffectText = self.transform:Find("Tips/LEffectText"):GetComponent(Text)
	self.LEffect = {}

	self.REffectText = self.transform:Find("Tips/REffectText"):GetComponent(Text)
	self.REffect = {}

	for i=1,3 do
		table.insert(self.LEffect, self.transform:Find("Tips/LEffectText/"..tostring(i)))
		table.insert(self.REffect, self.transform:Find("Tips/REffectText/"..tostring(i)))
	end

	self.transform:Find("Tips/LBuyButton"):GetComponent(Button).onClick:AddListener(function()
		self:OnLBuy()
	end)
	self.Text = self.transform:Find("Tips/LBuyButton/Text"):GetComponent(Text)
	self.transform:Find("Tips/RBuyButton"):GetComponent(Button).onClick:AddListener(function()
		self:OnRBuy()
	end)
	self.Text = self.transform:Find("Tips/LBuyButton/Text"):GetComponent(Text)
	self.transform:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function()
		self:OnClose()
	end)
end

function ChildrenContainerPanel:InitPrice()
	local cost_type = ""
	local cfg_cost_data = ShopManager.Instance.itemPriceTab[self.ShopItem[1]]
    if cfg_cost_data.assets_type == "gold" then
        cost_type = "90002"
    elseif cfg_cost_data.assets_type == "gold_bind" then
        cost_type = "90003"
    elseif cfg_cost_data.assets_type == "coin" then
        cost_type = "90000"
    end
    print(cost_type.."  "..cfg_cost_data.price)
	self.LExt:SetData(string.format(TI18N("花费：%s{assets_2,%s}"), tostring(cfg_cost_data.price), cost_type))
	cfg_cost_data = ShopManager.Instance.itemPriceTab[self.ShopItem[2]]
    if cfg_cost_data.assets_type == "gold" then
        cost_type = "90002"
    elseif cfg_cost_data.assets_type == "gold_bind" then
        cost_type = "90003"
    elseif cfg_cost_data.assets_type == "coin" then
        cost_type = "90000"
    end
    print(cost_type.."  "..cfg_cost_data.price)
	self.RExt:SetData(string.format(TI18N("花费：%s{assets_2,%s}"), tostring(cfg_cost_data.price), cost_type))
end

function ChildrenContainerPanel:OnClose()
	ChildrenManager.Instance.model:CloseContainerPanel()
end

function ChildrenContainerPanel:OnLBuy()
	ShopManager.Instance:send11303(self.ShopId[1], 1)
	self:OnClose()
end

function ChildrenContainerPanel:OnRBuy()
	ShopManager.Instance:send11303(self.ShopId[2], 1)
	self:OnClose()
end
