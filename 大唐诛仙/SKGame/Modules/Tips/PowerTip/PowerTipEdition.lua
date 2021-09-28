PowerTipEdition = BaseClass()

function PowerTipEdition:__init()
	self.tipPools = {}
	self.component = nil
	self:Init()
	self.old = 0
end

function PowerTipEdition:Init()
	if self.component == nil then 
		self.component = GComponent.New()
		self.component.name = "PowerTip"
		layerMgr:GetMSGLayer():AddChild(self.component)
	end
	self:CreatePool()
	self.handler1=GlobalDispatcher:AddEventListener(EventName.MAINPLAYER_UPDATE, function ( key, value, pre )
		self:PowerChange(key, value, pre)
	end)
	self.handler2=CommonModel:GetInstance():AddEventListener(CommonConst.EventName_PowerTipEnqueue, function ( data )
		self:PowerTipEnqueue(data)
	end)
end
--添加缓存池
function PowerTipEdition:CreatePool()
	for i = 1, 10 do
		local powerTip = PowerTips.New(self.component)
		if powerTip ~= nil then 
			powerTip:OnDisable()
	  		table.insert(self.tipPools, powerTip)
		end
	end
end
--获取一个tip
function PowerTipEdition:GetPowerTipFromPool()
	if #self.tipPools ~= 0 then																																													   
		return table.remove(self.tipPools, 1)
	end
	local powerTip = PowerTips.New(self.component)
	if powerTip ~= nil then 
		powerTip:OnDisable()
	end
	return powerTip
end

function PowerTipEdition:PowerChange(key, value, pre)
	if key == "battleValue" then
		self:ShowPowerTip(value,pre)
	end
end

function PowerTipEdition:ShowPowerTip(newValue,oldValue)
	local tip = self:GetPowerTipFromPool()
	if tip == nil then return end
	tip:ShowPowerTip(newValue,oldValue)
end
--归队
function PowerTipEdition:PowerTipEnqueue(data)
	table.insert(self.tipPools, data)
end
function PowerTipEdition:__delete()
	for i,v in ipairs(self.tipPools) do
		v:Destroy()
	end
	self.tipPools = {}
	if self.component then
		destroyUI( self.component )
	end
	self.component = nil
	GlobalDispatcher:RemoveEventListener(self.handler1)
	CommonModel:GetInstance():RemoveEventListener(self.handler2)
end
