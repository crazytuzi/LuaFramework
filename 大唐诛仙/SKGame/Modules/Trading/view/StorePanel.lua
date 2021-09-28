-- 商  店
StorePanel = BaseClass()
function StorePanel:__init(root)
	self.ui = UIPackage.CreateObject("Trading","StorePanel")
	self.bgRare = self.ui:GetChild("bgRare")
	self.txtName = self.ui:GetChild("txtName")
	self.txtLev = self.ui:GetChild("txtLev")
	self.txtSubType = self.ui:GetChild("txtSubType")
	self.txtDesc = self.ui:GetChild("txtDesc")
	self.txtDesc.UBBEnabled = true
	self.iconPay = self.ui:GetChild("iconPay")
	self.txtPrice = self.ui:GetChild("txtPrice")
	self.btnBuy = self.ui:GetChild("btnBuy")
	self.numBar = self.ui:GetChild("numBar")
	self.tabConn = self.ui:GetChild("tabConn") -- 类型容器
	self.itemConn = self.ui:GetChild("itemConn") -- 商品列表容器

	self.icon = PkgCell.New(self.ui)
	self.icon:SetXY(581, 25)
	self.bgRare.url = "Icon/Common/tipbg_r0"
	root:AddChild(self.ui)
	self:SetXY(143, 111)
	self:Config()
	self:Layout()
	self:InitEvent()
end
function StorePanel:Config()
	self.model = TradingModel:GetInstance()
	self.items = {}
	self.selected = nil
	self.bigType = TradingConst.storeTabs[1][1]
	self.subType = TradingConst.storeTabs[1][3][1][1] 
	self.curType = 0
	self.buyNum = 0
end
function StorePanel:InitEvent()
	self.btnBuy.onClick:Add(function ()
		if self.selected == nil or self.selected.data == nil or self.selected.data.cfg == nil then return end
		local cfg = self.selected.data.cfg
		local role = LoginModel:GetInstance():GetLoginRole()
		local owner = role:GetAssets(TradingConst.storePayType)
		if self.buyNum * cfg.buyPrice > role:GetAssets(TradingConst.storePayType) then
			UIMgr.Win_FloatTip(StringFormat("您的{0}不足!请前往充值!!", GoodsVo.GoodTypeName[TradingConst.storePayType]))
			return
		end
		if self.buyNum > 0 and cfg.id then
			TradingController:GetInstance():C_SystemItemBuy(cfg.id, self.buyNum)
		end
		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
	end)
	if not self.pkgChangeHandler then
		self.pkgChangeHandler = GlobalDispatcher:AddEventListener(EventName.BAG_CHANGE, function ()
			if self.ui and self.ui.visible then
				self:UpdateAfterBuy()
			end
		end)
	end

end
function StorePanel:Layout()
	local accordion = Accordion.New()
	accordion:AddTo(self.tabConn)
	accordion:SetXY(4, 0)
	self.accordion = accordion
	accordion:SetData( TradingConst.storeTabs, function ( selectData )
		if self.subType == selectData[2] or not selectData[2] then return end
		self.bigType = selectData[1]
		self.subType = selectData[2]
		if self.selected then
			self.selected:SetSelected(false)
			self.selected = nil
			self.icon:Clear()
		end
		self:UpdateInfo()
		self:Update()
	end)

	function numchange( v )
		self:NumChangeHandler(v)
	end
	self.numBar = NumberBar.Create(self.numBar)
	self.numBar:SetMax(99)
	self.numBar:SetStep(1)
	self.numBar:SetValue(0)
	self.numBar:SetTypeCallback(numchange)
	self.iconPay.url = GoodsVo.GetIconUrl(TradingConst.storePayType, 0)
	-- debugDrag(accordion)
end

function StorePanel:NumChangeHandler( v )
	self.buyNum = v
	if self.selected == nil or self.selected.data == nil or self.selected.data.cfg == nil then return end
	local data = self.selected.data.cfg
	local role = LoginModel:GetInstance():GetLoginRole()
	local owner = role:GetAssets(TradingConst.storePayType)
	local price = tonumber(data.buyPrice or 0) * tonumber(v)
	self.txtPrice.color = price <= owner and newColorByString("#2E3341") or newColorByString("#e32321")
	self.txtPrice.text = price
end
function StorePanel:UpdateAfterBuy() -- 购买成功后再更新一下，以即时显示玩家身上钱的购买情况
	self:NumChangeHandler( self.buyNum or 0 )
end

function StorePanel:Update()
	self.costPrice = 0
	local model = self.model
	local type1 = self.bigType
	local type2 = self.subType
	if self.curType == type2 then return end
	self.curType = type2
	local storeList = model.storeList
	local list = storeList[type2] or {}
	local item = nil
	local curList = {}

	local function callBack(obj)
		self:OnClickItemHandler(obj)
	end
	for i, v in ipairs(list) do
		item = self.items[i]
		if item == nil then
			item = TradingItem.New()
			item:SetScale(0.9, 0.9)
			self.items[i] = item
			item:SetCallback(callBack)
		end
		item:SetXY(0,(i-1)*108)
		item:AddTo(self.itemConn)
		item:Update(v)
		item:SetNum(1)
		curList[i] = true
	end
	for i, v in ipairs(self.items) do
		if not curList[i] then
			v:RemoveFromParent()
		end
	end
	if #curList ~= 0 then
		if self.model.defaultBid then
			for i,v in ipairs(self.items) do
				if curList[i] and self.items[i].data and self.items[i].data.bid == self.model.defaultBid then
					self.model.defaultBid = nil
					self:OnClickItemHandler(v)
					break
				end
			end
		end
		if self.selected == nil then
			local isSelected = true
			self:OnClickItemHandler(self.items[1] , isSelected)
		end
	end
end
function StorePanel:SetVisible(bool)
	self.ui.visible = bool
	if bool then
		local model = self.model
		if self.bigType ~= model.bigType1 or self.subType ~= model.subType1 then 
			local result = self.accordion:SetSelect(model.bigType1, model.subType1)
			if result then
				model.bigType1 = nil
				model.subType1 = nil
			end
		end
	end
end
function StorePanel:OnClickItemHandler( obj , isSelected )
	if self.selected ~= obj then
		if self.selected then
			self.selected:SetSelected(false)
		end
		self.selected = obj
	end
	obj:SetSelected(true)
	if self.selected then
		self.numBar:SetValue(1)
		self:NumChangeHandler(1)
	end
	self:UpdateInfo(obj)
	if not isSelected then
		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
	end
end
function StorePanel:UpdateInfo( obj )
	if not obj or not obj.data or not obj.data.cfg then 
		self.bgRare.url = "Icon/Common/tipbg_r0"
		self.txtName.text = ""
		self.txtLev.text = ""
		self.txtSubType.text = ""
		self.txtDesc.text = ""
		return
	end
	
	local data = obj.data
	local cfg = data.cfg
	if self.bgRare.url ~= "Icon/Common/tipbg_r"..cfg.rare then
		self.bgRare.url = "Icon/Common/tipbg_r"..cfg.rare
	end

	self.txtName.text = cfg.name
	self.txtName.color = newColorByString(GoodsVo.RareColor[cfg.rare])
	self.txtLev.text = StringFormat("{0}级",cfg.level)
	local role = LoginModel:GetInstance():GetLoginRole()
	self.txtLev.color = cfg.level <= role.level and newColorByString("#CDBF87") or newColorByString("#e32321")
	if data.goodsType == GoodsVo.GoodType.equipment then
		self.txtSubType.text = StringFormat("{0}", GoodsVo.EquipTypeName[cfg.equipType] or "")
		self.numBar:SetMax(1)
	else
		self.txtSubType.text = StringFormat("{0}", GoodsVo.TinyTypeName[cfg.tinyType] or "")
		self.numBar:SetMax(99)
	end
	self.txtDesc.text = cfg.des

	self.icon:SetData(data)
end

function StorePanel:SetXY(x, y)
	self.ui:SetXY(x, y)
end

function StorePanel:__delete()
	GlobalDispatcher:RemoveEventListener(self.pkgChangeHandler)
	for k,v in pairs(self.items) do
		v:Destroy()
	end
	destroyUI(self.ui)
	self.accordion:Destroy()
	self.accordion = nil
	self.numBar:Destroy()
	self.numBar = nil
	self.icon:Destroy()
	self.icon = nil

end