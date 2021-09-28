PkgModel = BaseClass(LuaModel)

function PkgModel:__init()
	self.openType = PkgConst.PanelType.bag -- 预打开面板类型
	self:ReSet()
end
function PkgModel:ReSet()
	self.selectGoodsBid = nil -- 设置默认选中id物品
	self.equipInfos = {} -- 装备信息数据（server）
	self.items = {} -- 所有背包数据（server）
	self.onGrids = {} -- 存在背包格子数据中的(client) state = 1
	self.onEquips = {} -- 穿戴或使用到身上的(client) state = 2
	self.bagGrid = 0 -- 背包格子数
	self.listPlayerBags = {} -- 背包数据列表
	self.listPlayerEquipments = {} -- 装备信息列表
	self.isInitedData = false -- 初始化状态数据
	self.wearHpTable = {0, 0, 0} -- 药剂面板三个红药栏(装备栏)
	self.wearMpTable = {0, 0, 0} -- 药剂面板三个蓝药栏（装备栏）
	self.hpList = {}
	self.mpList = {}
	self.isShowTip = true
end

-- 设置格子数量
function PkgModel:SetBagGrid(v)
	self.bagGrid = v
	self:DispatchEvent(PkgConst.GridChange)
end
-- 设置装备列表信息
function PkgModel:SetListPlayerEquipments(list)
	local hasChange = false
	SerialiseProtobufList( list, function ( data )
		local playerEquipmentId = toLong(data.playerEquipmentId)
		local info = self.equipInfos[playerEquipmentId]
		if info == nil then
			info = EquipInfo.New(data)
			self.equipInfos[playerEquipmentId] = info
			-- print("==============>", info.id, info.bid, info.state)
		else
			info:Update(data)
			-- 装备卸下
			if data.state == 1 then
				GlobalDispatcher:DispatchEvent(EventName.PlayerEquipStateChange, {state = 1, data = data.equipmentId} )
			-- 装备穿上
			elseif data.state == 2 then
				GlobalDispatcher:DispatchEvent(EventName.PlayerEquipStateChange, {state = 2, data = playerEquipmentId} )
			end
		end
		if data.state == 0 then -- 清除
			self.equipInfos[playerEquipmentId] = nil
		end
		-- print(" 装备变化：-->", info.bid, table.maxn(data.addPropertyMsg))
		hasChange = true
	end)
	if hasChange and self.isInitedData then
		GlobalDispatcher:Fire(EventName.EQUIPINFO_CHANGE)
	end
end
-- 设置背包列表信息
function PkgModel:SetListPlayerBags(list)
	local tmp = {} -- 变化数量收集 [bid] = num:正值增加，负值减少 0无数量变化但是有更新变化
	local tmpBid = 0
	SerialiseProtobufList( list, function ( data )
		local playerBagId = toLong(data.playerBagId)
		local vo = self.items[playerBagId]
		local num = 0
		local cfg = nil
		if vo == nil then
			num = data.num
			vo = GoodsVo.New(data)
			tmpBid = vo.bid
			self.items[playerBagId] = vo
			if self.isInitedData then
				vo.isNew = true
			end
		else
			local equipId = toLong(data.itemId) or 0
			-- 同一个格子物品改变,一个格子发2条BAG_CHANGE消息,一条删除旧的,一条增加新的
			if vo.bid and equipId and vo.bid ~= equipId then
				tmp[vo.bid] = {-1 * vo.num, clone(vo)}
				tmpBid = equipId
				num = data.num
			else
				num = data.num - vo.num
				tmpBid = vo.bid
			end
			vo:Update(data)
		end
		-- print("物品变化：-->", vo.id,vo.bid, vo.itemIndex, vo.num, vo.state)
		if self.isInitedData then
			if tmp[tmpBid] then
				tmp[tmpBid] = {tmp[tmpBid][1]+num, vo}
			else
				tmp[tmpBid] = {num, vo}
			end
		end
		if data.num == 0 or data.state == 0 then -- 清除
			self.items[playerBagId] = nil
		end
	end)
	self:Update()
	if next(tmp) then
		if self.isShowTip then
			local cd = 0
			for bid,v in pairs(tmp) do
				if v[1] > 0 then
					local cfg = v[2]:GetCfgData()
					if cfg then
						cd = cd + 0.1
						DelayCall(function ()
							Message:GetInstance():TipsMsg(StringFormat("您获得了 [color={0}]{1}[/color] x {2}个", GoodsVo.RareColor[cfg.rare], cfg.name, v[1]))
							ChatNewController:GetInstance():AddOperationMsgByCfg(cfg.id, v[1])
						end, cd)
					end
				end
			end
			GlobalDispatcher:Fire(EventName.BAG_CHANGE, tmp)
		else
			GlobalDispatcher:Fire(EventName.BAG_CHANGE, nil)
		end
	end
	tmp = nil
	self.isInitedData = true
end

-- 获取所有装备(身上+背包)
    function PkgModel:GetAllEquipInfos()
    	local result = {}
    	for _,v in pairs(self.equipInfos) do
			table.insert(result, v)
		end
    	return result
    end

 -- 获取所有装备(身上+背包)
     function PkgModel:GetAllEquipInfos2()
     	local result = {}
     	local vo = nil
     	for _,v in pairs(self.equipInfos) do
     		vo = v:ToGoodsVo()
     		vo.rare = vo.cfg.rare
 			table.insert(result, vo)
 		end
 		SortTableByKey(result, "rare", false)
     	return result
     end

-- 更新数据
	function PkgModel:Update()
		self.onGrids = {} -- 每次更新置空
		self.onEquips = {}
		for _,v in pairs(self.equipInfos) do
			if v.state == 2 then
				table.insert(self.onEquips, v)
			end
		end
		for _,v in pairs(self.items) do
			if v.state == 1 and v.num ~= 0 then
				table.insert(self.onGrids, v)
			end
		end
		self:UpdateMedicineTab()
	end

	function PkgModel:UpdateMedicineTab()
		for _, v in pairs(self.wearHpTable) do
			if v ~= 0 then
				self:DelwearTableHp(v)
			end
		end

		for _, v in pairs(self.wearMpTable) do
			if v ~= 0 then
				self:DelwearTableMp(v)
			end
		end
	end

-- 数据交互 【bid 表示通用 装备及物品表的id】
	-- 获取在【格子】中的数据
	function PkgModel:GetOnGrids()

		return self.onGrids
	end

	--整理背包格子，去除背包格子的‘新获取’的状态
	function PkgModel:TridOnGridsNewState()
		for _ , vo in pairs(self.onGrids) do
			if vo and vo.isNew == true then
				vo.isNew = false
			end
		end
	end

	-- 获取在【装备】中的数据
	function PkgModel:GetOnEquips()

		return self.onEquips
	end
	-- c由背包中的GoodsVo的id获取 装备 信息
	function PkgModel:GetEquipInfoByGoodsVoForId(id)

		return self:GetEquipInfoByGoodsVo(self.items[id])
	end
	-- c由背包中GoodsVo得到 装备 信息
	function PkgModel:GetEquipInfoByGoodsVo(vo)
		if vo then
			if vo.equipId ~= 0 then
				return self:GetEquipInfoByInfoId(vo.equipId)
			end
		else
			return nil
		end
	end
	-- c由背包中装备id得到 装备 信息
	function PkgModel:GetEquipInfoByInfoId(id)

		return self.equipInfos[id]
	end
	-- c由物品id行到 GoodsVO
	function PkgModel:GetGoodsVoById(id)

		return self.items[id]
	end
	-- c由物品bid得到 GoodsVo列表
	function PkgModel:GetGoodsVoListByBid(bid)
		local list = {}
		for _,v in pairs(self.items) do
			if v.bid == bid then
				table.insert(list, v)
			end
		end
		return list
	end
	-- c由物品bid得到 GoodsVo
	function PkgModel:GetGoodsVoByBid(bid)
		for _,v in pairs(self.items) do
			if v.bid == bid then
				return v
			end
		end
		return nil
	end
	-- c获取指定bid物品在背包中 总数量
	function PkgModel:GetTotalByBid(bid)
		local num = 0
		for _,v in pairs(self.items) do
			if v.bid == bid and v.state == 1 then
				num = num + (v.num or 1)
			end
		end
		return num
	end
	-- c获取指定子类型的物品 TinyType
	function PkgModel:GetGoodsVoByTinyType(t)
		local list = {}
		for _, v in pairs(self.items) do
			if v.goodsType ~= GoodsVo.GoodType.equipment then
				local cfg = v:GetCfgData()
				if cfg and cfg.tinyType == t then
					table.insert(list, v)
				end
			end
		end
		return list
	end
	-- c获取指定 非绑定 bid物品在背包中 总数量
	function PkgModel:GetNoBindTotalByBid(bid)
		local num = 0
		for i,v in ipairs(self.items) do
			if v.bid == bid and v.state == 1 and v.isBinding ~= 1 then
				num = num + (v.num or 1)
			end
		end
		return num
	end
	-- c物品bid是否在 背包中
	function PkgModel:IsOnBagByBid(bid)

		return self:GetTotalByBid(bid) ~= 0
	end
	-- c由装备信息的id是否在 背包中
	function PkgModel:IsOnBagByInfoId(id)
		local vo = self:GetEquipInfoByInfoId(id)
		if vo then
			return vo.state == 1
		end
		return false
	end
	-- c由装备信息的id是否在身上 装备中
	function PkgModel:IsOnEquipByInfoId(id)
		local vo = self:GetEquipInfoByInfoId(id)
		if vo then
			return vo.state == 2
		end
		return false
	end

	function PkgModel:IsOnBagByEffectType(effectType)
		if effectType then
			for k , v in pairs(self.items) do
				local cfg = v:GetCfgData() or nil
				if cfg and cfg.effectType == effectType then
					return true
				end
			end
		end
		return false
	end

	-- s通过后端给的playerEquipmentId 得到 GoodsVo
	function PkgModel:GetGoodsVoByServerEquipmentId(playerEquipmentId)
		local info = self:GetEquipInfoByInfoId(playerEquipmentId)
		if info then
			for k,v in pairs(self.items) do
				if v.equipId == info.id then
					return v
				end
			end
		end
		return nil
	end
	-- s通过后端给的playerBagId 得到 GoodsVo
	function PkgModel:GetGoodsVoByServerBagId(playerBagId)

		return self:GetGoodsVoById(playerBagId)
	end
	-- s通过后端给的playerEquipmentId 得到 装备 信息
	function PkgModel:GetEquipInfoByServerEquipmentId(playerEquipmentId)

		return self:GetEquipInfoByInfoId(playerEquipmentId)
	end
	-- s通过后端给的playerBagId 得到 装备 信息
	function PkgModel:GetEquipInfoByServerBagId(playerBagId)
		local vo = self:GetGoodsVoById(playerBagId)
		if vo and vo.goodsType == GoodsVo.GoodType.equipment then
			return self:GetEquipInfoByInfoId(vo.bid)
		end
		return nil
	end
	-- 比较装备战斗评分 返回比分结果，以及对比的目标
	function PkgModel:CompareScore(info)
		if not info then return 0, nil end
		local equip = nil
		for i,v in ipairs(self.onEquips) do
			if v.equipType == info.equipType and v ~= info then
				equip = v
				break
			end
		end
		if equip then
			return equip.score-info.score, equip
		else
			return 0, nil
		end
	end
	-- 获取当前部位上的装备
	function PkgModel:GetOnEquipByEquipType(t)
		if not t then return nil end
		for i,v in ipairs(self.onEquips) do
			if v.equipType == t then
				return v
			end
		end
		return nil
	end
	-- 构建以指定身上装备信息构建 GoodsVo
	function PkgModel:CreateOnEquipByEquipType(info)
		if not info then return nil end
		local vo = GoodsVo.New()
		vo:SetCfg(GoodsVo.GoodType.equipment, info.bid, 1, info.isBinding)
		vo.equipId = info.id
		vo.state = 2
		return vo
	end
	-- 获取物品列表中指定部位的所有装备列表
	function PkgModel:GetAllEquipByType(t)
		local result = {}
		for k,v in pairs(self.equipInfos) do
			if v.equipType == t then
				table.insert(result, v)
			end
		end
		return result
	end
	-- 获取当前职业下物品列表中指定部位的所有装备列表
	function PkgModel:GetRoleEquipByType(t, needCareer)
		local career = LoginModel:GetInstance():GetLoginRole().career
		local result = {}
		for k,v in pairs(self.equipInfos) do
			if v.equipType == t and v:GetCfgData() then
				if needCareer then
					if v:GetCfgData().needJob == 0 or v:GetCfgData().needJob == career then
						table.insert(result, v)
					end
				else
					table.insert(result, v)
				end
			end
		end
		return result
	end
	function PkgModel:IsRoleCareerData( v )
		local career = LoginModel:GetInstance():GetLoginRole().career
		if v and v:GetCfgData().needJob == 0 or v:GetCfgData().needJob == career then
			return true
		end
		return false
	end
	-- 获取相同bid的装备
	function PkgModel:GetAllSameBidEquips(bid)
		local result = {}
		for k,v in pairs(self.equipInfos) do
			if v.bid == bid then
				table.insert(result, v)
			end
		end
		return result
	end


-- 药品
	-- 获取装备药品中的数据列表 重构table,以方便处理排序等操作
	function PkgModel:ReSetByMedicineTable(list)
		return list
	end
	-- 卸下药品
	--根据装备药剂的索引删除卸下的药剂 红
	function PkgModel:DelwearTableHp(itemId)
		local num = self:GetTotalByBid(itemId)
		if num == 0 then
			for i,v in ipairs(self.wearHpTable) do
				if v and v == itemId then
					self.wearHpTable[i]=0
					PkgCtrl:GetInstance():C_PutdownDrug(1,itemId)
					break
				end
			end
		end
	end
	--根据装备药剂的索引删除卸下的药剂 蓝
	function PkgModel:DelwearTableMp(itemId)
		local num = self:GetTotalByBid(itemId)
		if num == 0 then
			for i,v in ipairs(self.wearMpTable) do
				if v and v == itemId then
					self.wearMpTable[i]=0
					PkgCtrl:GetInstance():C_PutdownDrug(2,itemId)
					break
				end
			end
		end
	end

-- 预打开面板类型
function PkgModel:SetOpenType(t)
	self.openType = t
end
-- 设置默认选中一个bid物品
function PkgModel:SetSelectGoodsBid(bid)
	self.selectGoodsBid = bid
end

--获取默认选中的物品的bid
function PkgModel:GetSelectGoodsBid()
	return self.selectGoodsBid
end

function PkgModel:CleanSelectGoodsBid()
	self.selectGoodsBid = nil
end


function PkgModel:GetInstance()
	if PkgModel.inst == nil then
		PkgModel.inst = PkgModel.New()
	end
	return PkgModel.inst
end
function PkgModel:__delete()
	PkgModel.inst = nil
	for i,v in ipairs(self.items) do
		v:Destroy()
	end
	for i,v in ipairs(self.equipInfos) do
		v:Destroy()
	end
	self.equipInfos=nil
	self.items = nil
	self.onGrids=nil
	self.onEquips=nil
	self.selectGoodsBid = nil
end

function PkgModel:SetShowTip(show)
	if show and show == 1 then
		self.isShowTip = false
	else
		self.isShowTip = true
	end
end