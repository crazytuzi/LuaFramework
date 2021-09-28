RegistModules("Trading/TradingConst")
RegistModules("Trading/TradingModel")
RegistModules("Trading/Vo/TradingEquipInfo")
RegistModules("Trading/Vo/TradingGoodsVo")

RegistModules("Trading/View/TradingItem")
RegistModules("Trading/View/StorePanel")
RegistModules("Trading/View/StallPanel")
RegistModules("Trading/View/TradingAlertPanel")
RegistModules("Trading/TradingMainPanel")

TradingController = BaseClass(LuaController)
function TradingController:__init()
	self:Config()
	self:RegistProto()
	self:InitEvent()
	self.isInitStoreData = false -- 是否初始化过商城物质 trading 表数据
end
function TradingController:Config()
	self.model = TradingModel:GetInstance()
end
function TradingController:InitEvent()
	self.handle = GlobalDispatcher:AddEventListener(EventName.ENTER_DATA_INITED, function ()
		GlobalDispatcher:RemoveEventListener(self.handle)
		self.model.shelfNum = LoginModel:GetInstance():GetEquipmentGrid() -- 初始开启货架格子数量
	end)
	
	if not self.reloginHandle then
		self.reloginHandle = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE, function ()
			self.isInitStoreData = false
			self.model:ReSet()
			self.handle = GlobalDispatcher:AddEventListener(EventName.ENTER_DATA_INITED, function ()
				GlobalDispatcher:RemoveEventListener(self.handle)
				self.model.shelfNum = LoginModel:GetInstance():GetEquipmentGrid() -- 初始开启货架格子数量
			end)
		end)
	end

end
function TradingController:RegistProto()
	self:RegistProtocal("S_GetPlayerTradeList") -- 玩家个人交易信息
	self:RegistProtocal("S_SynTradeList") -- 交易行信息改变通知
	self:RegistProtocal("S_TradeBuy") -- 购买
	self:RegistProtocal("S_TradeSell") -- 出售
	self:RegistProtocal("S_OffShelf") -- 下架
	self:RegistProtocal("S_ExtendGrid") -- 扩展货架
	self:RegistProtocal("S_ReUpShelf")
end

-- 接收
-- 玩家个人交易信息
function TradingController:S_GetPlayerTradeList(buff)
	local msg = self:ParseMsg(trading_pb.S_GetPlayerTradeList(), buff)
	self.model:UpdateMyData(msg)
end
-- 交易行信息改变通知
function TradingController:S_SynTradeList(buff)
	local msg = self:ParseMsg(trading_pb.S_SynTradeList(), buff)
	self.model:UpdateSysData(msg)
end
-- 购买
function TradingController:S_TradeBuy(buff)
	local msg = self:ParseMsg(trading_pb.S_TradeBuy(), buff)
	-- self.model:UpdateMyEquipInfo(msg.playerTradeEquipment)
	self.model:UpdateMyGoodsVo(msg.playerTradeBag)
	self.model:Fire(TradingConst.STALL_SYS_CHANGED)
end
-- 上架
function TradingController:S_TradeSell(buff)
	local msg = self:ParseMsg(trading_pb.S_TradeSell(), buff)
	self.model:UpdateMyEquipInfo(msg.playerTradeEquipment)
	self.model:UpdateMyGoodsVo(msg.playerTradeBag)
	self.model:Fire(TradingConst.STALL_MY_CHANGED)
end
-- 下架
function TradingController:S_OffShelf(buff)
	local msg = self:ParseMsg(trading_pb.S_OffShelf(), buff)
	-- self.model:UpdateMyEquipInfo(msg.playerTradeEquipment)
	self.model:UpdateMyGoodsVo(msg.playerTradeBag)
	self.model:Fire(TradingConst.STALL_MY_CHANGED)
end
-- 扩展货架
function TradingController:S_ExtendGrid(buff)
	local msg = self:ParseMsg(trading_pb.S_ExtendGrid(), buff)
	if msg.gridNum ~= self.model.shelfNum and msg.gridNum ~= 0 then
		self.model:SetShelfNum(msg.gridNum)
	end
end

-- 重新上架
function TradingController:S_ReUpShelf(buff)
	local msg = self:ParseMsg(trading_pb.S_ReUpShelf(), buff)
	self.model:UpdateMyGoodsVo(msg.playerTradeBag)
	self.model:Fire(TradingConst.STALL_MY_CHANGED)
end

-- 请求

-- 玩家个人交易信息
function TradingController:C_GetPlayerTradeList()
	self:SendEmptyMsg(trading_pb, "C_GetPlayerTradeList")
end
-- 交易信息 (分页) 寄售
function TradingController:C_GetTradeList(type, typeId, start)
	local msg = trading_pb.C_GetTradeList()
	msg.type = type
	msg.typeId = typeId
	msg.start = start  or 1
	msg.offset = TradingConst.Offset
	self:SendMsg("C_GetTradeList", msg)
end
-- 购买
function TradingController:C_TradeBuy(id, num)
	local msg = trading_pb.C_TradeBuy()
	msg.playerBagId = id
	msg.num = num
	self:SendMsg("C_TradeBuy", msg)
end
-- 上架
function TradingController:C_TradeSell(id, num, price)
	local msg = trading_pb.C_TradeSell()
	msg.playerBagId = id
	msg.num = num
	msg.price = price
	self:SendMsg("C_TradeSell", msg)
end
-- 下架
function TradingController:C_OffShelf(id)
	local msg = trading_pb.C_OffShelf()
	msg.playerBagId = id
	self:SendMsg("C_OffShelf", msg)
end
-- 扩展货架
function TradingController:C_ExtendGrid()
	self:SendEmptyMsg(trading_pb, "C_ExtendGrid")
end

-- print("商店请求：-- 购买")
function TradingController:C_SystemItemBuy(itemId, num)
	local msg = trading_pb.C_SystemItemBuy()
	msg.itemId = itemId
	msg.num = num
	self:SendMsg("C_SystemItemBuy", msg)
end

-- 重新上架
function TradingController:C_ReUpShelf(id)
	local msg = trading_pb.C_ReUpShelf()
	msg.playerTradeBagId = id
	self:SendMsg("C_ReUpShelf", msg)
end


-- 面板 (条件指向打开 tabType 功能标签类型 bigType 左侧一级类型 subType 左侧二级类型 stallTabType 寄售标签（购买|寄售） defaultBid 选中要出售的物品bid)
function TradingController:Open(tabType, bigType1, subType1, bigType2, subType2, stallTabType, defaultBid)
	if tabType then self.model.tabType = tabType end
	if bigType1 then self.model.bigType1 = bigType1 end -- 商店
	if subType1 then self.model.subType1 = subType1 end
	if bigType2 then self.model.bigType2 = bigType2 end -- 寄售购买
	if subType2 then self.model.subType2 = subType2 end
	if stallTabType then self.model.stallTabType = stallTabType end
	if defaultBid then self.model.defaultBid = defaultBid end

	self:C_GetPlayerTradeList()
	if not self.isInitStoreData then
		self.isInitStoreData = true
		self.model:InitStoreCfg()
	end

	self:GetMainPanel():Open()
end

function TradingController:Close()
	self:GetMainPanel():Close()
end
-- 获取主面板
function TradingController:GetMainPanel()
	if not self:IsExistView() then
		self.view = TradingMainPanel.New()
	end
	return self.view
end
-- 判断主面板是否存在
function TradingController:IsExistView()
	return self.view and self.view.isInited
end

function TradingController:GetInstance()
	if TradingController.inst == nil then
		TradingController.inst = TradingController.New()
	end
	return TradingController.inst
end
function TradingController:__delete()
	GlobalDispatcher:RemoveEventListener(self.reloginHandle)
	GlobalDispatcher:RemoveEventListener(self.handle)
	if self:IsExistView() then
		self.view:Destroy()
	end
	self.view = nil
	if self.model then
		self.model:Destroy()
	end
	self.model = nil
	TradingController.inst = nil
end