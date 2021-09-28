TradingModel = BaseClass(LuaModel)

function TradingModel:__init()
	self:ReSet()
end
function TradingModel:ReSet()
	self.tabType = TradingConst.tabType.store -- 默认选中 功能标签类型

	self.bigType1 = TradingConst.storeTabs[1][1] -- 默认选中 商店左侧一级类型
	self.subType1 = TradingConst.storeTabs[1][3][1][1] -- 默认选中 商店左侧二级类型

	self.bigType2 = TradingConst.stallTabs[1][1] -- 默认选中 寄售购买左侧一级类型
	self.subType2 = TradingConst.stallTabs[1][3][1][1] -- 默认选中 寄售购买左侧二级类型

	self.stallTabType = TradingConst.stallTabType.buy -- 默认选中 寄售类型（购买 出集）
	self.defaultBid = nil -- 默认选中要出售的物品

	self.reqSubType1 = nil -- 请求商店类型
	self.reqSubType2 = nil -- 请求寄售购买类型

	self.pkgModel = PkgModel:GetInstance() -- 背包数据模型

	-- 商店数据 （装备，物品 直接cfg数据）
	self.storeList = {} -- 商店数据列表 (子类物品配置)

	-- 出售面板
		self.equipInfos_my = {} -- 在货架上后端信息数据（类似背包）
		self.items_my = {}
		self.equipInfos_pkg = {} -- 在背包上的(直接拿背包数据)
		self.items_pkg = {}

		self.shelfNum = 0 -- 玩家货架数量

	-- 购买面板
		self.equipInfos_sys = {} -- 其他玩家信息数据
		self.items_sys = {}
end
-- 添加在打开出售时监听背包变化事件
function TradingModel:ListenStallEvent()
	if not self.bagChangeHandler then
		self.bagChangeHandler = GlobalDispatcher:AddEventListener(EventName.BAG_CHANGE, function ( data )
			self:UpdatePkgData()
		end)
	end
end
-- 移除在打开出售时监听背包变化事件
function TradingModel:RemoveStallEvent()
	GlobalDispatcher:RemoveEventListener(self.bagChangeHandler)
	self.bagChangeHandler = nil
end
-- 同步个人货架数据
function TradingModel:UpdateMyData( msg )
	SerialiseProtobufList( msg.listPlayerTradeEquipment, function ( info )
		self:UpdateMyEquipInfo( info )
	end)
	SerialiseProtobufList( msg.listPlayerTradebag, function ( vo )
		local data = self.items_my[vo.playerBagId]
		if not data then
			data = TradingGoodsVo.New()
			self.items_my[vo.playerBagId] = data
		end
		data:Update(vo, TradingConst.itemType.shelf)
	end)
	for id, v in pairs(self.items_my) do -- 删除多余的
		if v.state == 0 then
			if self.equipInfos_my[v.itemId] then
				self.equipInfos_my[v.itemId] = nil
			end
			self.items_my[id] = nil
		end
	end
	self:Fire(TradingConst.STALL_MY_CHANGED)
end
function TradingModel:UpdateMyEquipInfo( info )
	local data = self.equipInfos_my[info.playerEquipmentId]
	if not data then
		data = TradingEquipInfo.New()
		self.equipInfos_my[info.playerEquipmentId] = data
	end
	data:Update(info)
end
function TradingModel:UpdateMyGoodsVo(vo)
	local data = self.items_my[vo.playerBagId]
	if not data then
		data = TradingGoodsVo.New()
		self.items_my[vo.playerBagId] = data
	end
	data:Update(vo, TradingConst.itemType.shelf)
	for id, v in pairs(self.items_my) do -- 删除多余的
		if v.state == 0 then
			if self.equipInfos_my[v.itemId] then
				self.equipInfos_my[v.itemId] = nil
			end
			self.items_my[id] = nil
		end
	end
end

-- 同步背包数据
function TradingModel:UpdatePkgData()
	for id, info in pairs(self.pkgModel.equipInfos) do
		local data = self.equipInfos_pkg[id]
		if not data then
			data = TradingEquipInfo.New()
			self.equipInfos_pkg[id] = data
		end
		data:SetEquipInfo(info)
	end
	for id,v in pairs(self.equipInfos_pkg) do -- 多余的删掉
		if self.pkgModel.equipInfos[id] == nil then
			self.equipInfos_pkg[id] = nil
		end
	end
	self.items_pkg = {}
	for id, vo in pairs(self.pkgModel.items) do
		if vo.isBinding ~= 1 and vo:GetCfgData() and vo:GetCfgData().isTrade == 1 then
			local data = self.items_pkg[id]
			if not data then
				data = TradingGoodsVo.New()
				data:SetDataByGoodsVo(vo)
				self.items_pkg[id] = data
			else
				self.items_pkg[id]:SetDataByGoodsVo(vo)
			end
			--data:SetDataByGoodsVo(vo)
		end
	end
	for id,v in pairs(self.items_pkg) do -- 多余的删掉
		if self.pkgModel.items[id] == nil then
			self.items_pkg[id] = nil
		end
	end
	self:Fire(TradingConst.STALL_PKG_CHANGED)
end
-- 设置其他玩家信息数据
function TradingModel:UpdateSysData( msg )
	SerialiseProtobufList( msg.listPlayerTradeEquipment, function ( info )
		self:UpdateSysEquipInfo(info)
	end)
	SerialiseProtobufList( msg.listPlayerTradebag, function ( vo )
		local data = self.items_sys[vo.playerBagId]
		if not data then
			data = TradingGoodsVo.New()
			self.items_sys[vo.playerBagId] = data
		end
		data:Update(vo, TradingConst.itemType.sysSell)
	end)
	for id, v in pairs(self.items_sys) do -- 删除多余的
		if v.state == 0 then
			if self.equipInfos_sys[v.itemId] then
				self.equipInfos_sys[v.itemId] = nil
			end
			self.items_sys[id] = nil
		end
	end
	self:Fire(TradingConst.STALL_SYS_CHANGED)
end
function TradingModel:UpdateSysEquipInfo(info)
	local data = self.equipInfos_sys[info.playerEquipmentId]
	if not data then
		data = TradingEquipInfo.New()
		self.equipInfos_sys[info.playerEquipmentId] = data
	end
	data:Update(info)
end
function TradingModel:UpdateSysGoodsVo(vo)
	local data = self.items_sys[vo.playerBagId]
	if not data then
		data = TradingGoodsVo.New()
		self.items_sys[vo.playerBagId] = data
	end
	data:Update(vo, TradingConst.itemType.sysSell)
	for id, v in pairs(self.items_sys) do -- 删除多余的
		if v.state == 0 then
			if self.equipInfos_sys[v.itemId] then
				self.equipInfos_sys[v.itemId] = nil
			end
			self.items_sys[id] = nil
		end
	end
end

-- 获取寄售购买面板中的
	-- 物品信息(未必有排序)
	function TradingModel:GetSysItems()
		local list = {}
		for _, v in pairs(self.items_sys) do
			local cfg = v:GetCfgData()
			if cfg then
				local vo = {}
				vo.data = v
				vo.price = v.price
				vo.level = cfg.level
				vo.rare = cfg.rare
				table.insert(list, vo)
			else
				print("后端配置找不到-->交易商品:", v.id)
			end
		end
		return list
	end
	-- 装备信息
	function TradingModel:GetSysInfo(id)
		return self.equipInfos_sys[id]
	end
	function TradingModel:GetSysInfoByVo(vo)
		if not vo then return nil end
		return self.equipInfos_sys[vo.equipId]
	end
	-- 重置列表(切换类型时重置)
	function TradingModel:ResetSysItems()
		self.equipInfos_sys = {}
		self.items_sys = {}
	end
-- 获取寄售面板中
	-- 我的背包物品信息(未必有排序)
	function TradingModel:GetPkgItems()
		return self.items_pkg
	end
	-- 我的背包装备信息
	function TradingModel:GetPkgInfo(id)
		return self.equipInfos_pkg[id]
	end

	-- 我的寄售物品信息(未必有排序)
	function TradingModel:GetMyItems()
		return self.items_my
	end
	-- 我的寄售装备信息
	function TradingModel:GetMyInfo(id)
		return self.equipInfos_my[id]
	end
	function TradingModel:GetMyInfoBy(vo)
		if not vo then return nil end
		return self.equipInfos_my[vo.equipId]
	end
-- 扩展货架
	function TradingModel:SetShelfNum(v)
		self.shelfNum = v or self.shelfNum
		self:Fire(TradingConst.SHELF_NUM_CHANGE)
	end

-- 查询是否有存在二级类型在指定一级类型中
function TradingModel:IsSubTypeOnBigType(big, sub)
	if not TradingConst.bigType[big] then return false end
	local subs = TradingConst.bigType[big][3]
	if not subs then return false end
	for i,v in ipairs(subs) do
		if v[1] and v[1][1] == sub then return true end
	end
	return false
end

-- 初始化交易商城列表数据
function TradingModel:InitStoreCfg()
	local cfg = GetCfgData("trading")
	local list = nil
	local tb = nil
	local tmpList = {}
	for i=1,#TradingConst.subType do
		tb = TradingConst.subType[i]
		for k=1,#tb do
			t = tb[k][1]
			if t then
				list = {}
				for j=1, #cfg do
					local data = cfg[j]
					local vo = tmpList[data.goodsId]
					if not vo then
						vo = GoodsVo.New()
						vo:SetCfg(data.type, data.goodsId, 1, data.isBinding)
						tmpList[data.goodsId] = vo
					end
					if vo.cfg then
						if vo.goodsType == GoodsVo.GoodType.equipment then
							if vo.cfg.equipType == t then
								table.insert(list, vo)
							end
						else
							if vo.cfg.tradeType == t then
								table.insert(list, vo)
							end
						end
						
					end
				end
				self.storeList[t] = list
			end
		end
	end
end

function TradingModel:GetInstance()
	if TradingModel.inst == nil then
		TradingModel.inst = TradingModel.New()
	end
	return TradingModel.inst
end
function TradingModel:__delete()
	self:RemoveStallEvent()
	TradingModel.inst = nil
end

function TradingModel:ResetTradingData()
	self.items_sys = {}
	self.equipInfos_my = {}
end

function TradingModel:GetPriceColorStr(num)
	local color = "#2E3341"
	local showOutline = true
	if num then
		if num < 10 ^ 5 then
			color = "#000000"
			showOutline = false
		elseif num < 10 ^ 6 then
			color = GoodsVo.RareColor[2]
		elseif num < 10 ^ 7 then
			color = GoodsVo.RareColor[3]
		elseif num < 10 ^ 8 then
			color = GoodsVo.RareColor[4]
		elseif num < 10 ^ 9 then
			color = GoodsVo.RareColor[5]
		else
			color = GoodsVo.RareColor[6]
		end
	end
	return color, showOutline
end