TradingItem = BaseClass(LuaUI)
-- type:TradingConst.itemType sysSell | pkgStall | shelf
function TradingItem:__init(type)
	self.type = type
	self:RegistUI()
	self:Config()
end
function TradingItem:Config()
	self.isLock = false
	self.num = nil
end

function TradingItem:Update(data)
	self.data = data
	local tradeModel = TradingModel:GetInstance()
	if data then
		self.mainGroup.visible = true
		self.icon:SetVisible(true)
		self.icon:OpenTips(true)
		local cfg = data:GetCfgData()
		if not cfg then print("配置有问题！！！") return end
		local num = data.price or cfg.buyPrice
		local colorStr, showOutline = tradeModel:GetPriceColorStr(tonumber(num))
		self.txtPrice.text = StringFormat( "[color={0}]{1}[/color]", colorStr, number_format(num, ','))
		if showOutline then
			self.txtPrice.stroke = 1
		else
			self.txtPrice.stroke = 0
		end
		self.txtName.text = cfg.name
		self.txtName.color = newColorByString(GoodsVo.RareColor[cfg.rare or 0])
		if self.payIcon.url ~= GoodsVo.GetIconUrl(TradingConst.storePayType, 0) then
			self.payIcon.url = GoodsVo.GetIconUrl(TradingConst.storePayType, 0)
		end
		self.icon:SetData(data)
		self.lockMask.visible = false
		if self.type == TradingConst.itemType.shelf then -- 启动定时器 5 少检查一次
			self:CheckOverTime()
			setupFuiRender(self.ui, function ()
				self:CheckOverTime()
			end, 5)
		end
	else
		self.lockMask.visible = false
		self.icon:SetData(nil)
		self.icon:OpenTips(false)
		self.txtName.text = ""
		self.txtPrice.text = ""
		self.payIcon.url = nil
		if self.iconOverTime then
			self.iconOverTime.visible = false
		end
	end
end
function TradingItem:CheckOverTime()
	local data = self.data
	if self.iconOverTime and data and data.overTime then
		local expired = data.overTime < TimeTool.GetCurTime()
		self.iconOverTime.visible = expired
		self.lockMask.visible = expired
		self.data.expired = expired
	end
end
function TradingItem:SetNum(v)
	self.num = v or 0
	if self.data then
		self.data.num = v
	end
	self.icon:SetNum(v)
end
function TradingItem:SetType( type )
	self.type = type
	self.icon:SetTipsType(self.type)
end
function TradingItem:SetLock( v )
	local lock = v==1
	self.mainGroup.visible = not lock
	if not lock then self:Update(nil) end
	if lock == self.isLock then return end
	self.isLock = lock
	self.lockGroup.visible = self.isLock
	if self.isLock then
		self.lockMask.visible = true
		self.lock.url = "Icon/Other/lock"
		self.txtLock.text = getRichTextContent(StringFormat("解锁花费:[img=42,42]Icon/Goods/{0}[/img]x{1}", 
			GoodsVo.GoodIcon[TradingConst.OpenStallGridPrice[1]], TradingConst.OpenStallGridPrice[2]))
	end
end
function TradingItem:SetCallback( cb )
	self.ui.onClick:Add(function ()
		cb(self)
		if self.data and (self.type == TradingConst.itemType.shelf or self.type == TradingConst.itemType.sysSell ) then
			self.icon:ShowTips(false)
		end
	end)
end
function TradingItem:SetSelected( bool )
	self.select.visible = bool
end

function TradingItem:RegistUI()
	self.ui = UIPackage.CreateObject("Trading","TradingItem")
	self.select = self.ui:GetChild("select")
	self.txtName = self.ui:GetChild("txtName")
	self.payIcon = self.ui:GetChild("payIcon")
	self.txtPrice = self.ui:GetChild("txtPrice")
	self.mainGroup = self.ui:GetChild("mainGroup")
	self.lockMask = self.ui:GetChild("lockMask")
	self.lock = self.ui:GetChild("lock")
	self.txtLock = self.ui:GetChild("txtLock")
	self.lockGroup = self.ui:GetChild("lockGroup")

	self.txtPrice.UBBEnabled = true

	self.icon = PkgCell.New(self.ui)
	self.icon:SetTipsType(self.type)
	self.icon:OpenTips(false)
	self.icon:SetXY(16, 13)
	if self.type == TradingConst.itemType.shelf then
		self.iconOverTime = UIPackage.CreateObject("Common", "font_yiguoqi")
		self.ui:AddChild(self.iconOverTime)
		self.iconOverTime:SetXY(291, 4)
		self.iconOverTime.visible = false
	end
end

function TradingItem:__delete()
	self.icon:Destroy()
end