GrowUpPanel = BaseClass(LuaUI)
function GrowUpPanel:__init( ... )
	self.URL = "ui://wvu017cpts5tp";
	self:__property(...)
	self:Config()
	self:AddEvent()
	self:InitEvent()
	self:LoadGrowJijinList()
	self:RefreshRed()
end
-- Set self property
function GrowUpPanel:SetProperty( ... )
end
-- start
function GrowUpPanel:Config()
	self.model = RechargeModel:GetInstance()
	
	self.tab0_btnFenyeJijin.title = "[color=#ffffff]成长基金[/color]"
	self.tab1_btnFenyeAll.title = "[color=#2e3314]全民福利[/color]"

	self.itemJijin = {}
	self.itemAll = {}
	self.pepleBuyNum.text = self.model.buyGrowthFundNum
end
-- wrap UI to lua
function GrowUpPanel:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Recharge","GrowUpPanel");

	self.fenyeTab = self.ui:GetController("fenyeTab")
	self.btnBuyJijin = self.ui:GetChild("btnBuyJijin")
	self.pepleBuyNum = self.ui:GetChild("pepleBuyNum")
	self.tab0_btnFenyeJijin = self.ui:GetChild("tab0_btnFenyeJijin")
	self.tab1_btnFenyeAll = self.ui:GetChild("tab1_btnFenyeAll")
	self.jijinList = self.ui:GetChild("jijinList")
	self.allWelFareList = self.ui:GetChild("allWelFareList")
	self.redTipUp = self.ui:GetChild("redTipUp")
	self.redTipAll = self.ui:GetChild("redTipAll")

end

function GrowUpPanel:InitEvent()
	self.tab0_btnFenyeJijin.onChanged:Add(function()
		if self.itemJijin then
			for i,v in ipairs(self.itemJijin) do
				v:Destroy()
			end
			self.itemJijin = {}
		end
		if self.itemAll then
			for i,v in ipairs(self.itemAll) do
				v:Destroy()
			end
			self.itemAll = {}
		end
		self:BtnTextColor(0)
		self:LoadGrowJijinList()
		end)
	self.tab1_btnFenyeAll.onChanged:Add(function()
		if self.itemJijin then
			for i,v in ipairs(self.itemJijin) do
				v:Destroy()
			end
			self.itemJijin = {}
		end
		if self.itemAll then
			for i,v in ipairs(self.itemAll) do
				v:Destroy()
			end
			self.itemAll = {}
		end
		self:BtnTextColor(1)
		self:LoadAllWelFareList()
	end)
	if self.model.isbuyGrowthFund == 0 then
		self.btnBuyJijin.title = "购买基金"
		self.btnBuyJijin.onClick:Add(function ()
			local resNum = self.model:GetGrowJJResNum()
			local str = StringFormat("是否花费{0}元宝，购买成长基金？", resNum)
			UIMgr.Win_Confirm("温馨提示", str, "确认", "取消", function()
				RechargeController:GetInstance():C_BuyGrowthFound()
			end)
		end)
	else
		self.btnBuyJijin.title = "已购买"
		self.btnBuyJijin.touchable = false
	end
end

function GrowUpPanel:AddEvent()
	self.handler0 = self.model:AddEventListener( RechargeConst.LQJijinData, function()
		if self.itemJijin then
			local lv = self.model:GetMainPlayerLv()
			for i,v in ipairs(self.itemJijin) do
				v:RefreshBtn()
			end
		end
	end)
	self.handler1 = self.model:AddEventListener( RechargeConst.allRewardData, function()
		if self.itemAll then
			for i,v in ipairs(self.itemAll) do
				v:RefreshBtn()
			end
		end
	end)
	self.handler2 = self.model:AddEventListener( RechargeConst.SuccessJiJinBuy, function()
		--self.model.isbuyGrowthFund = 1
		--self.model.buyGrowthFundNum = self.model.buyGrowthFundNum + 1
		if self.btnBuyJijin and self.pepleBuyNum then
			self.btnBuyJijin.title = "已购买"
			self.btnBuyJijin.touchable = false
			self.pepleBuyNum.text = self.model.buyGrowthFundNum
		end

		if self.itemJijin and #self.itemJijin > 0 then
			local lv = self.model:GetMainPlayerLv()
			for i,v in ipairs(self.itemJijin) do
				v:Refresh(self.model.isbuyGrowthFund, lv)
			end
		end
		if self.itemAll and #self.itemAll then
			for i,v in ipairs(self.itemAll) do
				v:Refresh(self.model.buyGrowthFundNum)
			end
		end
	end)	
	self.handler3 = self.model:AddEventListener(RechargeConst.LQJijinData, function()
		if self.ui then
			self:RefreshRed()
		end
	end)
	self.handler4 = self.model:AddEventListener(RechargeConst.allRewardData, function()
		if self.ui then
			self:RefreshRed()
		end
	end)
end

function GrowUpPanel:BtnTextColor(i)
	if i == 0 then
		self.tab0_btnFenyeJijin.title = "[color=#ffffff]成长基金[/color]"
		self.tab1_btnFenyeAll.title = "[color=#2e3314]全民福利[/color]"
	elseif i == 1 then
		self.tab0_btnFenyeJijin.title = "[color=#2e3314]成长基金[/color]"
		self.tab1_btnFenyeAll.title = "[color=#ffffff]全民福利[/color]"
	end
end

function GrowUpPanel:LoadGrowJijinList()    --加载成长基金
	local lv = self.model:GetMainPlayerLv()
	local listJijin = self.model:GetGrowJijinTabData()
	if #listJijin > 0 then
		for i, v in ipairs(listJijin) do
			local itemObj = JijinItem.New()
			itemObj.id = v[3]
			itemObj:Updata(v, self.model.isbuyGrowthFund)
			itemObj:Refresh(self.model.isbuyGrowthFund, lv)
			table.insert(self.itemJijin, itemObj)
			self.jijinList:AddChild(itemObj.ui)
		end
	end
end

function GrowUpPanel:LoadAllWelFareList()	--加载全民福利
	local listAll = self.model:GetAllTabData()
	if #listAll > 0 then
		for i, v in ipairs(listAll) do
			local itemObj = AllWelfareItem.New()
			itemObj.id = v[3]
			itemObj:Updata(v)
			itemObj:Refresh(self.model.buyGrowthFundNum)
			table.insert(self.itemAll, itemObj)
			self.allWelFareList:AddChild(itemObj.ui)
		end
	end
end

function GrowUpPanel:RefreshRed()
	self.redTipUp.visible = self.model:IsJijinRed()
	self.redTipAll.visible = self.model:IsAllWelfareRed() 
end

-- Combining existing UI generates a class
function GrowUpPanel.Create( ui, ...)
	return GrowUpPanel.New(ui, "#", {...})
end
function GrowUpPanel:__delete()
	if self.model then
		self.model:RemoveEventListener(self.handler0)
		self.model:RemoveEventListener(self.handler1)
		GlobalDispatcher:RemoveEventListener(self.handler2)
		self.model:RemoveEventListener(self.handler3)
		self.model:RemoveEventListener(self.handler4)
	end
	if self.itemJijin then
		for i,v in ipairs(self.itemJijin) do
			v:Destroy()
		end
		self.itemJijin = nil
	end
	if self.itemAll then
		for i,v in ipairs(self.itemAll) do
			v:Destroy()
		end
		self.itemAll = nil
	end

end