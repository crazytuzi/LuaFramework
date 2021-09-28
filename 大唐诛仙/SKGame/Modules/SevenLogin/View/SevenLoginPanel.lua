SevenLoginPanel = BaseClass(BaseView)
function SevenLoginPanel:__init( ... )
	self.ui = UIPackage.CreateObject("SevenLogining","SevenLoginPanel"); -- self.URL = "ui://gyl54s25f3gzd";
	
	self.btnClose = self.ui:GetChild("btnClose")
	self.itemList = self.ui:GetChild("itemList")
	self.id = "SevenLoginPanel"
	
	self.model = SevenLoginModel:GetInstance()
	self.items = {}
	self:LoadDayItem()
	self:InitEvent()
	self:AddEvent()

end
function SevenLoginPanel:InitEvent()
	--[[
		self.closeCallback = function() end
		self.openCallback  = function() end
	--]]
	self.openCallback  = function()
		SevenLoginController:GetInstance():C_GetOpenServerData()
	end

	self.btnClose.onClick:Add(function ()
		SevenLoginController:GetInstance():Close()
	end)
end

function SevenLoginPanel:AddEvent()
	self.handler0 = self.model:AddEventListener(SevenLoginConst.RewardLQ, function()
		local day =  self.model.totleLoginDay
		if self.items then
			for i,v in ipairs(self.items) do
				v:Refresh(day)
			end
		end
	end)
	self.handler1 = self.model:AddEventListener(SevenLoginConst.InitSevenData, function()
		local day =  self.model.totleLoginDay
		if self.items then
			for i,v in ipairs(self.items) do
				v:Refresh(day)
			end
		end
	end)
end

function SevenLoginPanel:LoadDayItem()
	local list = self.model:GetRewardList()
	local loginDay = self.model.totleLoginDay
	for i, v in ipairs(list) do
		local itemObj = DayItem.New()
		itemObj.id = v[1]
		itemObj:Updata(v)
		itemObj:Refresh(loginDay)
		table.insert(self.items, itemObj)
		self.itemList:AddChild(itemObj.ui)
	end
end

function SevenLoginPanel:__delete()
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
	if SevenLoginController:GetInstance().isTan then
		GlobalDispatcher:DispatchEvent(EventName.PopCheckStateChange, {id = MainUIConst.PopModule.SevenLogin, show = false, isClose = true})
	end
end