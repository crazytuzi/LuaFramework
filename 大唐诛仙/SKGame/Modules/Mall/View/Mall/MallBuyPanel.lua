MallBuyPanel = BaseClass(BaseView)
function MallBuyPanel:__init( ... )
	MallView.LoadAB()

	self.ui = UIPackage.CreateObject("Mall","MallBuyPanel");
	
	self.n33 = self.ui:GetChild("n33")
	self.hehua = self.ui:GetChild("hehua")
	self.opoInfo = self.ui:GetChild("opoInfo")
	self.btnClose = self.ui:GetChild("btnClose")
	self.sortInfo = self.ui:GetChild("sortInfo")
	self.limitBuy = self.ui:GetChild("limitBuy")
	self.n30 = self.ui:GetChild("n30")
	self.numBar = self.ui:GetChild("numBar")
	self.buyBtn = self.ui:GetChild("buyBtn")
	self.popbg2 = self.ui:GetChild("popbg2")
	self.popTitle = self.ui:GetChild("popTitle")
	self.labelBar = self.ui:GetChild("labelBar")
	self.n41 = self.ui:GetChild("n41")
	self.putawayText = self.ui:GetChild("putawayText")

	self.numBar = NumberBar.Create(self.numBar)
	self.numBar:SetTypeCallback(function(data)
		self:UpdateCost(data)
	end)

	self.labelBar:GetChild("title").text = "总价:"
	self.costIcon = self.labelBar:GetChild("icon")
	self.costInfo = self.labelBar:GetChild("txt")

	self:AddEvents()
	
	self.buyNum = 0
	self.data = nil
	self.leftTime = nil
	self.price = 0
end

function MallBuyPanel:AddEvents()
	self.btnClose.onClick:Add(self.ClosePanel, self)
	self.buyBtn.onClick:Add(self.OnBuyHandler, self)
end

function MallBuyPanel:RemoveEvents()
	self.btnClose.onClick:Remove(self.ClosePanel, self)
	self.buyBtn.onClick:Remove(self.OnBuyHandler, self)
end

function MallBuyPanel:OnBuyHandler()
	local function buyFun()
		 MallController:GetInstance():ReqBuy(self.data.marketId, tonumber(self.buyNum), false)
		 UIMgr.HidePopup()

		 if self.callBack then
		 	self.callBack()
		 	self.callBack = nil
		 end
	end

	local isActive , activeType = MallModel:GetInstance():IsWingOrStyleActive(self.data.itemId)
	if isActive then
		local strContent = ""
		if activeType == MallConst.ActiveType.Style then
			strContent = "您已激活该时装，无法继续购买！"
		elseif activeType == MallConst.ActiveType.Wing then
			strContent = "您已激活该翅膀，无法继续购买！"
		end
		UIMgr.HidePopup()
		UIMgr.Win_Alter("提示" , strContent , "确认" ,function() end , nil )
	else
		buyFun()
	end
end

function MallBuyPanel:Update(data, callBack)
	self.data = data
	self.callBack = callBack

	local goodVo = GoodsVo.GetCfg(self.data.itemType, self.data.itemId)
	self.popTitle.text = StringFormat("[color={0}]{1}[/color]",GoodsVo.RareColor[goodVo.rare],goodVo.name)
	self.opoInfo.text = self:CreateDesc(goodVo.des, goodVo.tinyType, goodVo.effectValue)
	self.sortInfo.text = self.data.des

	if self.data.limitNum == 0 then
		self.limitBuy.visible = false
		self.leftTime = 99
	else
		self.limitBuy.visible = true
		local curTime = MallModel:GetInstance():GetBuyInfo(self.data.marketId) or 0
		self.leftTime = self.data.limitNum - curTime
		self.limitBuy.text = StringFormat("[color=#43596b]每日限购:[color=#3370b7]{0}[/color]/{1}[/color]",self.leftTime,self.data.limitNum)
	end

	self.costIcon.url = GoodsVo.GetIconUrl(self.data.moneyType)

	if self.leftTime < 1 then
		self.numBar:Lock()
		self.buyNum = 0
	else
		self.numBar:UnLock()
		self.buyNum = 1
	end

	if self.data.discount == 0 then
		self.price = self.data.price
	else
		self.price = math.ceil(self.data.price*self.data.discount/100) 
	end

	self:ShowItem()
	self.numBar:SetMax(self.leftTime)
	self.numBar:SetValue(self.buyNum)
	self:UpdateCost(self.buyNum)
end

function MallBuyPanel:ShowItem()
	local pkgCell = PkgCell.New(self.ui)
	pkgCell:SetDataByCfg(self.data.itemType, self.data.itemId, 1, 0)
	pkgCell:SetXY(self.hehua.x + (self.hehua.width - pkgCell.ui.width)*0.5, self.hehua.y + 20)	
	pkgCell:OpenTips(true)

	local isActive , activeType = MallModel:GetInstance():IsWingOrStyleActive(self.data.itemId)
	if isActive then
		local activeIconURL = "Icon/Vip/jihuo"
		pkgCell:SetLeftTopLoader(activeIconURL)
	end
end

function MallBuyPanel:UpdateCost(num)
	self.buyNum = num
	self.costInfo.text = self.price*tonumber(num)

	if tonumber(num) <= 0 then
		self.buyBtn.grayed = true
		self.buyBtn.touchable = false
	else
		self.buyBtn.grayed = false
		self.buyBtn.touchable = true
	end
end

-- 增加描述
function MallBuyPanel:CreateDesc(content, tinyType, effectValue)
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

-- --关闭界面
function MallBuyPanel:ClosePanel()
	UIMgr.HidePopup()
	if self.callBack then
		self.callBack()
		self.callBack = nil
	end
end

-- Dispose use MallBuyPanel obj:Destroy()
function MallBuyPanel:__delete()
	self:RemoveEvents()

	-- destroyUI(self.numBar.ui)

	self.numBar:Destroy()
	self.popBg = nil
	self.popbg2 = nil
	self.popTitle = nil
	self.opoInfo = nil
	self.btnEquipSold = nil
	self.btnEquipSell = nil
	self.btnClose = nil
	self.popBtnUp = nil
	self.popBtnSub = nil
	self.popBtnAdd = nil
	self.popInputText = nil
	self.sortInfo = nil
	self.putawayText = nil
	self.putawayNum = nil
	self.n30 = nil
end