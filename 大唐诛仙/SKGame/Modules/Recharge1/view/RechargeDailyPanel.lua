RechargeDailyPanel = BaseClass(LuaUI)
function RechargeDailyPanel:__init( ... )
	self.URL = "ui://wvu017cpts5t0";
	self:__property(...)
	self:Config()
	self:AddEvent()
	self:InitEvent()
	self:LoadItemList()
end
-- Set self property
function RechargeDailyPanel:SetProperty( ... )
end
-- start
function RechargeDailyPanel:Config()
	self.model = RechargeModel:GetInstance()
	self.items = {}

end
-- wrap UI to lua
function RechargeDailyPanel:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Recharge","RechargeDailyPanel");

	self.btnRechardDaily = self.ui:GetChild("btnRechardDaily")
	self.rechardNumDaily = self.ui:GetChild("rechardNumDaily")
	self.textTime = self.ui:GetChild("textTime")
	self.rewardItemList = self.ui:GetChild("rewardItemList")
end

function RechargeDailyPanel:AddEvent()
	self.handler0 = self.model:AddEventListener(RechargeConst.DailyRechargeGet, function()
		if self.items then
			for i,v in ipairs(self.items) do
				v:RefreshBtn()
			end
		end
	end)
	self.handler1 = self.model:AddEventListener(RechargeConst.DailyRechargeData, function()
		self:RefreshUI()
	end)
end

function RechargeDailyPanel:InitEvent()
	self.btnRechardDaily.onClick:Add(function ()
		MallController:GetInstance():OpenMallPanel(0, 2)
	end)
end

function RechargeDailyPanel:RefreshUI()
	if self.items then
		for i,v in ipairs(self.items) do
			v:Destroy()
		end
		self.items = {}
	end
	self:LoadItemList()
end

function RechargeDailyPanel:LoadItemList()
	self.rechardNumDaily.text = self.model.dailyRecharge
	local list = self.model:GetDailyRechargeTabData()
	if #list > 0 then
		for i, v in ipairs(list) do
			local itemObj = RewardItem.New()
			itemObj.id = v[3]
			itemObj:Updata(v)
			itemObj.yiLQicon.visible = false
			itemObj.btnIsLingqu.visible = true
			itemObj:Refresh(self.model.dailyRecharge)
			table.insert(self.items, itemObj)
			self.rewardItemList:AddChild(itemObj.ui)
		end
	end
end

-- Combining existing UI generates a class
function RechargeDailyPanel.Create( ui, ...)
	return RechargeDailyPanel.New(ui, "#", {...})
end

function RechargeDailyPanel:__delete()
	if self.model then
		self.model:RemoveEventListener(self.handler0)
		self.model:RemoveEventListener(self.handler1)
	end
	if self.items then
		for i,v in ipairs(self.items) do
			v:Destroy()
		end
		self.items = nil
	end
end