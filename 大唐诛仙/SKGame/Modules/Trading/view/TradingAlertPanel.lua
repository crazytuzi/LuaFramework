TradingAlertPanel = BaseClass(LuaUI)
-- type:0 购买 1 上架
function TradingAlertPanel:__init(type)
	self.type = type
	self.model = TradingModel:GetInstance()
	self:RegistUI()
end

-- 回调返回 数据vo及数量
function TradingAlertPanel:SetData(data, max, callback )
	self.data =  data
	self.callback = callback
	self.num = 1
	if self.type == 1 then
		if data.cfg then
			self.price = data.cfg.tradeInitPrice or data.cfg.tradeMinPrice
		else
			self.price = data.price
		end
	else
		self.price = data.price -- 价格
	end
	-- print("原来价格:-->",self.price)
	self.numBar:SetValue(1)
	self.numBar:SetMax(max or 99)
	self:Update()
end

function TradingAlertPanel:RegistUI()
	self.ui = UIPackage.CreateObject("Trading", "TradingAlertPanel")
	self.btnClose = self.ui:GetChild("btnClose")
	self.txtName = self.ui:GetChild("txtName")
	self.txtDesc = self.ui:GetChild("txtDesc")
	self.numBar = self.ui:GetChild("numBar")
	self.btnApply = self.ui:GetChild("btnApply")

	self.icon = PkgCell.New(self.ui)
	self.icon:SetScale(1.2, 1.2)
	self.icon:SetXY(269, 59)

	self.numBar = NumberBar.Create(self.numBar)
	self.numBar:SetMax(99)
	self.numBar:SetStep(1)
	self.numBar:SetTypeCallback(function ( num )
		self.num = num
		self:Update()
	end)

	self.btnApply.onClick:Add(function ()
		self.callback(self.data, self.num, self.price)
		UIMgr.HidePopup(self.ui)
	end)
	self.btnClose.onClick:Add(function ()
		UIMgr.HidePopup(self.ui)
	end)

	
	self.labelTotal = self:CreateLabel("总价:", 123, 446, 0)
	if self.type == 1 then
		self.btnApply.title = "上架"
		self.ui.height = 689
		self.labelPrice = self:CreateLabel("单价:", 123, 381, 1)
		local input = self.labelPrice:GetChild("txt")
		input.onFocusOut:Add(function ()
			local cfg = self.data:GetCfgData()
			if not cfg then
				input.text = "0"
				self.price = 0
				self:Update()
				return
			end
			self.price = tonumber(input.text)
			if self.price == nil then
				self.price = cfg.tradeInitPrice or cfg.tradeMinPrice
				input.text = self.price
			elseif self.price <= cfg.tradeMinPrice then-- 最低价
				self.price = cfg.tradeMinPrice
				input.text = self.price
			elseif self.price >= cfg.tradeMaxPrice then -- 最高价
				self.price = cfg.tradeMaxPrice
				input.text = self.price
			end
			self:Update()
		end)

		self.labelFee = self:CreateLabel("手续费:", 123, 513, 0)
		self.labelFee.icon = GoodsVo.GetIconUrl( TradingConst.Fee[1], 0 )
	else
		self.labelPrice = self:CreateLabel("单价:", 123, 381, 0)
	end

	self.labelPrice.icon = GoodsVo.GetIconUrl( TradingConst.TradeType, 0 )
	self.labelTotal.icon = GoodsVo.GetIconUrl( TradingConst.TradeType, 0 )
	
end

function TradingAlertPanel:Update()
	if not self.data then return end
	local data = self.data
	self.icon:SetData(data)
	self.icon:SetNum(0)
	local cfg = data:GetCfgData()
	if cfg then
		self.txtDesc.text = self:CreateDesc(cfg.des, cfg.tinyType, cfg.effectValue)
		self.txtName.text = cfg.name
	else
		self.txtDesc.text = ""
		self.txtName.text = ""
	end
	local num = self.num
	self.labelPrice:GetChild("txt").text = self.price
	self.labelTotal:GetChild("txt").text = self.price*num
	if self.type ==1 then
		self.labelFee:GetChild("txt").text = math.ceil(self.price*num*0.1)
	end
end

function TradingAlertPanel:CreateLabel(label, x, y, type)
	local lbl = nil
	if type == 1 then
		lbl = UIPackage.CreateObject("Common", "CustomLabel1") -- 带输入
	else
		lbl = UIPackage.CreateObject("Common", "CustomLabel0") -- 普通文本
	end
	lbl.title = label
	self.ui:AddChild(lbl)
	lbl:SetXY(x, y)
	return lbl
end

-- 增加描述
function TradingAlertPanel:CreateDesc(content, tinyType, effectValue)
	if tinyType == GoodsVo.TinyType.gift and effectValue then -- 礼包处理
		local giftCfg = GetCfgData("gift"):Get(effectValue)
		local career = LoginModel:GetInstance():GetLoginRole().career
		if giftCfg and giftCfg.reward then
			local s = ""
			local rewardList = {}
			for i,v in ipairs(giftCfg.reward) do
				if v[1]==0 or v[1]==career then
					table.insert(rewardList, v)
				end
			end
			local list = {}
			for i,v in ipairs(rewardList) do
				local num = v[5]
				local cfg = GoodsVo.GetCfg(v[3], v[4])
				if cfg then
					local c = StringFormat("[color={0}]{1}[/color]x{2}", GoodsVo.RareColor[cfg.rare], cfg.name, num)
					table.insert(list, c)
				end
			end
			content = StringFormatII(content, list)
		end
	end
	return content
end

function TradingAlertPanel:__delete()
	TradingAlertPanel.instII = nil
	TradingAlertPanel.instI = nil
end

function TradingAlertPanel.ShowI(data, max, callback)
	if TradingAlertPanel.instI == nil then
		TradingAlertPanel.instI = TradingAlertPanel.New(0)
	end
	TradingAlertPanel.instI:SetData(data, max, callback)
	UIMgr.ShowCenterPopup(TradingAlertPanel.instI,nil,false)
end
function TradingAlertPanel.ShowII(data, max, callback)
	if TradingAlertPanel.instII == nil then
		TradingAlertPanel.instII = TradingAlertPanel.New(1)
	end
	TradingAlertPanel.instII:SetData(data, max, callback)
	UIMgr.ShowCenterPopup(TradingAlertPanel.instII,nil,false)
end
function TradingAlertPanel.DestroyAll()
	if TradingAlertPanel.instII then
		TradingAlertPanel.instII:Destroy()
	end
	if TradingAlertPanel.instI then
		TradingAlertPanel.instI:Destroy()
	end
	TradingAlertPanel.instII = nil
	TradingAlertPanel.instI = nil
end