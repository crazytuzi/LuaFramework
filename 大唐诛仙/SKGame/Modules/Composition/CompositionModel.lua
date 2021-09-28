CompositionModel =BaseClass(LuaModel)

function CompositionModel:__init()
	self:InitData()
	self:InitEvent()
end

function CompositionModel:__delete()
	self:CleanEvent()
	CompositionModel.inst = nil
end

function CompositionModel:GetInstance()
	if CompositionModel.inst == nil then
		CompositionModel.inst = CompositionModel.New()
	end

	return CompositionModel.inst
end

function CompositionModel:InitEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.BAG_CHANGE, function()
		self:HandleBagChange()
	end)
end

function CompositionModel:CleanEvent()
	GlobalDispatcher:RemoveEventListener(self.handler0)
	
end

function CompositionModel:InitData()
	self.items = {} --所有可合成的物品
	self.itemsTypeData = {} --合成分类数据
	self:InitItemsData()
	self:InitItemsTypeData()
end


function CompositionModel:HandleBagChange()
	self:DestroyItemsData()
	self:SetItemsData()
	self:DispatchEvent(CompositionConst.UpdateItems)
end

--[[
	初始化可合成的数据(来源于"cfg_compose"配置表中所有的可合成的数据)
]]
function CompositionModel:InitItemsData()
	self:SetItemsData()
end

--[[
	设置itemsData
]]
function CompositionModel:SetItemsData()
	local cfgData = GetCfgData("compose")
	for cfgKey, cfgValue in pairs(cfgData) do
		if type(cfgKey) == "number" and cfgValue.isCompose == 1 then
			table.insert(self.items, cfgValue)
		end
	end
	self:SortItemsData()
end

--[[
	是否可以合成
]]
function CompositionModel:IsCanComposition(bid)
	local rtnIsCan = false
	if bid then
		local compositionCfgVal = GetCfgData("compose"):Get(bid)
		if not TableIsEmpty(compositionCfgVal) then
			if compositionCfgVal.isCompose == 1 then
				rtnIsCan = true
			end		
		end
	end
	return rtnIsCan
end

--[[
	1 合成物品排序，当前是稀有度排序，请在当前稀有度排序规则上加上id排序。

	即：每种品质的物品再按照id由小到大排序。
]]
function CompositionModel:SortItemsData()
	table.sort(self.items, function (a, b)
		--return self:GetItemRare(a.id) < self:GetItemRare(b.id)
		
		-- local aRare = self:GetItemRare(a.id)
		-- local bRare = self:GetItemRare(b.id)
		-- if aRare == bRare then
		-- 	return a.id < b.id
		-- else
		-- 	return aRare < bRare
		-- end

		return a.id < b.id
	end)
end

--[[
	获取合成id对应的品阶
]]

function CompositionModel:GetItemRare(id)
	local rtnRare = 0
	local cfg = self:GetCfgData(id)
	if not TableIsEmpty(cfg) then
		if cfg.type == GoodsVo.GoodType.equipment then
			local equipCfg = GetCfgData("equipment"):Get(id)
			if not TableIsEmpty(equipCfg) then
				rtnRare = equipCfg.rare
			end
		elseif cfg.type == GoodsVo.GoodType.item then
			local itemCfg = GetCfgData("item"):Get(id)
			if not TableIsEmpty(itemCfg) then
				rtnRare = itemCfg.rare
			end
		end
	end
	return rtnRare
end

--[[
	销毁Items所有数据
]]
function CompositionModel:DestroyItemsData()
	for index = 1, #self.items do
		self.items[index] = nil
	end
	self.items = {}
end

--[[
	销毁某个配id对应的Items的数据
]]
function CompositionModel:DestroyItemsDataById(id)
	if id then
		for index = 1, #self.items do
			if self.items[index].id == id then
				local remGoodsVoObj = table.remove(self.items, index)
				break
			end
		end
	end
end

-- "分类id
-- 参考了商城分类，与lua中的配置id对应
-- 0：不可合成
-- 1：妙药
-- 2：灵石
-- 3：斗神印记"

function CompositionModel:InitItemsTypeData()
	self.itemsTypeData = {}
	self.itemsTypeData = {
		--[1] = {desc = "全部" , type = CompositionConst.ItemType.All},
		[1] = {desc = "药品类" , type = CompositionConst.ItemType.MiaoYao},
		[2] = {desc = "强化类" , type = CompositionConst.ItemType.Stone},
		[3] = {desc = "斗神印" , type = CompositionConst.ItemType.Rune},
		[4] = {desc = "道具类" , type = CompositionConst.ItemType.Item}
	}
end

function CompositionModel:GetItemsTypeData()
	return self.itemsTypeData
end

function CompositionModel:GetItemsTypeDataByIndex(index)
	return self.itemsTypeData[index] or {}
end

function CompositionModel:GetItemsData()
	return self.items
end


--[[
	根据类型来取对应的合成数据
	typeData:
	1 ---- 全部
	2 ---- 妙药
	3 ---- 灵石
	4 ---- 斗神印记
]]
function CompositionModel:GetItemsDataByType(typeData)
	local rtnItemsData = {}
	if typeData then
		local items = self:GetItemsData()
		if typeData == 1 then --妙药
			for index = 1 , #self.items do
				local curItemData = self.items[index]
				local id = curItemData.id
				if self:GetItemTradeType(id) == CompositionConst.ItemType.MiaoYao then
					table.insert(rtnItemsData , curItemData)
				end
			end
		elseif typeData == 2 then --灵石
 			for index = 1 , #self.items do
				local curItemData = self.items[index]
				local id = curItemData.id
				if self:GetItemTradeType(id) == CompositionConst.ItemType.Stone then
					table.insert(rtnItemsData , curItemData)
				end
			end
		elseif typeData == 3 then --斗神印记
			--合成界面——斗神印记分类中，
			--只显示和角色职业相同的斗神印，其他斗神印（包含通用类型的）不显示C出来
			for index = 1 , #self.items do
				local curItemData = self.items[index]
				local id = curItemData.id
				if self:GetItemTradeType(id) == CompositionConst.ItemType.Rune then
					if self:IsSameWithPlayerCareer(id) then
						table.insert(rtnItemsData , curItemData)
					end
				end
			end
		elseif typeData == 4 then --道具
			for index = 1 , #self.items do
				local curItemData = self.items[index]
				local id = curItemData.id
				if self:GetItemTradeType(id) == CompositionConst.ItemType.Item then
					table.insert(rtnItemsData , curItemData)
				end
			end
		end
	end
	return rtnItemsData
end

--获取某中类型的第一个可合成的物品数据
function CompositionModel:GetFirstItemDataByType(tabData)
	local rtnItemsData = {}
	local firstTabItemsData = self:GetItemsDataByType(tabData)
	if not TableIsEmpty(firstTabItemsData) then
		rtnItemsData = firstTabItemsData[1] or {}
	end
	return rtnItemsData
end

function CompositionModel:IsSameWithPlayerCareer(composeId)
	return GoodsVo.IsRoleCareerData(composeId)
end

function CompositionModel:GetItemTradeType(id)
	local rtnTradeType = -1
	local composeCfg = GetCfgData("compose"):Get(id)
	if not TableIsEmpty(composeCfg) then
		rtnTradeType = composeCfg.tradeType
	end
	return rtnTradeType
end

function CompositionModel:GetCfgData(id)
	local rtnCfg = {}
	if id then
		local composeCfg = GetCfgData("compose"):Get(id)
		if not TableIsEmpty(composeCfg) then
			rtnCfg = composeCfg
		end
	end
	
	return rtnCfg
end

--[[
	获取合成目标的类型
	1=装备
	2=物品
	3=金币
	4=钻石
	5=代金卷
	6=贡献值
	7=荣誉值
	8=经验
]]
function CompositionModel:GetItemsTypeById(id)
	local rtnType = -1
	local cfgData = self:GetCfgData(id)
	if cfgData then
		rtnType = cfgData.type
	end
	return rtnType
end

--[[
	根据合成消耗物品，获取合成目标ID（由于遍历查找消耗比较大，和策划约定好：合成目标ID = 合成消耗物品ID + 1）
]]

function CompositionModel:GetTargetID(originalId)
	local rtnTargetId = -1
	if originalId then
		rtnTargetId = originalId + 1
	end
	return rtnTargetId
end

--[[
	是否能满足合成资源条件
]]
function CompositionModel:IsEnoughToComposition(id)
	local rtnIsEnough = true
	if id then
		local compCfg = self:GetCfgData(id)
		if not TableIsEmpty(compCfg) then
			local mainPlayer = SceneModel:GetInstance():GetMainPlayer()
			local hasGoldCnt = mainPlayer.gold or 0
			for index = 1 , #compCfg.composeStr do
				local curComposeConsume = compCfg.composeStr[index]
				if curComposeConsume[1] == GoodsVo.GoodType.gold then
					local needGoldCnt = curComposeConsume[3]
					if hasGoldCnt < needGoldCnt then
						rtnIsEnough = false
						break
					end
				else
					local hasCnt = PkgModel:GetInstance():GetTotalByBid(curComposeConsume[2])
					local needCnt = curComposeConsume[3]
					if hasCnt < needCnt then
						rtnIsEnough = false
						break
					end
				end
			end
		end
	end
	return rtnIsEnough
end

function CompositionModel:Reset()
end