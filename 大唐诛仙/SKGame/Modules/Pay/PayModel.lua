PayModel = BaseClass(LuaModel)

function PayModel:__init()
	self:InitEvent()
end

function PayModel:Regist( ctrl )
	self.payCtrl = ctrl
	self.checkPanel = nil
	self.payType = 1
	self.yichong = {}
	self.payCellList = {} -- 充值
	self.growupList = {} -- 成长基金
	self.vipList = {}
	self:GetCellList()
end

function PayModel:InitEvent()
	self:AddHandler()
end

function PayModel:AddHandler()
	if not self.handler then
		self.handler = GlobalDispatcher:AddEventListener(EventName.PayPanelLayout, function ( isInited )
			if isInited then
				-- 发送协议
				self.payCtrl:C_GetFristPayIdList()
			end
		end)
	end

	-- 切换账号清除信息
	self.reloginHandler = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE, function ()
		self:Clear()
	end)
end

function PayModel:Clear()
	self.checkPanel = nil
	self.payType = 1
	self.yichong = {}
	self.growupList = {} -- 成长基金
	self.vipList = {}
end

function PayModel:GetInstance()
	if PayModel.inst == nil then
		PayModel.inst = PayModel.New()
	end
	return PayModel.inst
end

-- 得到已充列表
function PayModel:SetYCList( yichong )
	self.yichong = yichong
	GlobalDispatcher:DispatchEvent(EventName.GetFirstPayList)
end

-- 得到列表
function PayModel:GetCellList()
	local cfg = GetCfgData("charge")
	for k , v in pairs(cfg) do
		if type(v) ~= 'function' and v then
			if v.type == PayConst.PayType.NormalCard then
				table.insert(self.payCellList, v.id)
			elseif v.type == PayConst.PayType.Growup then
				table.insert(self.growupList, v.id)
			elseif v.type == PayConst.PayType.Vip then
				table.insert(self.vipList, v.id)
			end
		end
	end
	table.sort(self.payCellList)
	table.sort(self.growupList)
	table.sort(self.vipList)
end

-- 是否为cellList
function PayModel:IsCellList( id )
	for i,v in ipairs(self.payCellList) do
		if id == v then
			return true
		end
	end
	return false
end

--是否已经进行了月卡充值
function PayModel:HasMonthCardPay()
	for __ , payItemId in pairs(self.yichong) do
		local payItemCfg = GetCfgData("charge"):Get(payItemId)
		if payItemCfg and payItemCfg.type == PayConst.PayType.MonthCard then
			return true
		end
	end
	return false
end

-- 单元点击事件
function PayModel:OnCellClick( eve )
	if self.checkPanel then return end
	local id = eve.sender.data
	if GameConst.isAppleIAP then
		PayCtrl:GetInstance():C_Pay(tonumber(id), 3)
	else
		if isSDKPlat then
			PayCtrl:GetInstance():C_Pay(tonumber(id), 3)
		else
			self.checkPanel = PayCheckPanel.New( id )
			self.checkPanel:SetPayPanel()
			UIMgr.ShowCenterPopup(self.checkPanel, function ()
				self.checkPanel = nil
			end, true)
		end
		
	end
	
end

--获取某个商品对应的信息
function PayModel:GetPriceByPayItem(itemId, typeValue)
	local rtnInfo = 0
	if itemId and typeValue then
		local info = GetCfgData("charge"):Get(itemId)
		if info then
			rtnInfo = info[typeValue]
		end
	end
	return rtnInfo
end

function PayModel:__delete()
	GlobalDispatcher:RemoveEventListener(self.handler)
	GlobalDispatcher:RemoveEventListener(self.reloginHandler)
	self.checkPanel = nil
	self.payCtrl = nil
	self.payType = 1
	self.yichong = {}
	self.payCellList = {}
	self.growupList = {}
	PayModel.inst = nil
end
