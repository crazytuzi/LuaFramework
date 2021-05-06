local CItemCtrl = class("CItemCtrl", CCtrlBase)

 CItemCtrl.ARRANGE_ITEM_TIME = 3 		--整理背包时间

function CItemCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_RefreshTimer = nil
	self.m_RefreshPriceTimer = nil
	self.m_RefreshFuwenTimer = nil

	-- 背包
	-- 背包分页记录
	-- 0表示不在背包界面
	-- 1表示在背包普通标签，2表示背包材料标签，3表示背包宝石标签，4表示背包装备标签
	self.m_RecordItemPageTab = 0	

	-- 背包画面当前属于哪个状态
	-- 0表示当前不在背包界面，1表示背包在正常预览状态，2表示背包在出售状态
	self.m_RecordItembBagViewState = 0

	--背包道具的分类
	self.m_BagType = 
	{
		[1] = define.Item.ItemBagShowType.Genernal, 	--普通
		[2] = define.Item.ItemBagShowType.Material, 	--材料
		[3] = define.Item.ItemBagShowType.Equip, 		--装备灵石(客户端显示装备)
		[4] = define.Item.ItemBagShowType.Partner, 		--伙伴
		[5] = define.Item.ItemBagShowType.Chip, 		--碎片
	}

	-- 背包出售道具队列缓存
	--[[格式类型： 
		{	标签类型	 序号	 道具信息 出售数量
			[type] = {  [indx] = {[1] = titem, [2] = count} },
		}
	]]	
	self.m_RecordSellItemCache = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
	}

	--背包排序(每个标签单独控制)
	--(key = 1 普通标签，2 材料标签，3 装备标签, 4 伙伴标签 5 碎片标签
	self.m_RecordItembBagSortTypeCache = 
	{
		[1] = 1,
		[2] = 1,
		[3] = 1,
		[4] = 1,
		[5] = 1,
	}
	self.m_IsInitBagSortType = false	--加载背包标签序号(每次重登第一次打开背包时加载)

	--背包总列表
	self.m_BagItems = {}

	--背包分类列表(标签变化，排序变化，道具发生变动, 出售状态切换 才会更新)
	self.m_BagTabItemsCache = {}

	--材料的价格缓存，每次得到的价格都缓存在这里。格式 sid = price
	self.m_MaterailPriceCache = {}

	--装备
	self.m_EquipedItems = {}

	--装备强化画面，元宝自动填充材料
	self.m_ForgeStrengthAutoFill = false 

	--装备符文，元宝自动填充材料
	self.m_ForgeFuwenAutoFill = false 

	--当前出售的道具的系统id
	self.m_CurSellItemId = 0
	--当前使用的道具的系统id
	self.m_CurUseItemId = 0 

	--背包整理计时
	self.m_ArrangeItemTimer = 0

	--背包红点提示id(系统id)缓存
	self.m_RedDotIdTable = {}

	--快捷使用道具(系统id)缓存
	self.m_QuickUseIdCache = {}
	self.m_QuickUseTimer = nil

	self.m_ForgeFuwenName = {}

	--显示属性变化飘字相关
	if self.m_ShowAttrTimer ~= nil then
		Utils.DelTimer(self.m_ShowAttrTimer)
		self.m_ShowAttrTimer = nil
	end
	self.m_ShowAttrCacheKey = {}
	self.m_ShowAttrCacheAttr = {}
	self.m_ShowAttrChangeFlag = false
end

-- [[数据逻辑处理]]
function CItemCtrl.GetBagItemListByType(self, sType)
	local list = {}
	local insert = false
	for _, oItem in pairs(self.m_BagItems) do
		if oItem:IsBagItemPos() then
			if sType == g_ItemCtrl.m_BagTypeEnum.equip then
				insert = oItem:IsEquip()
			elseif sType == g_ItemCtrl.m_BagTypeEnum.consume then
				insert = oItem:IsConsume()
			else
				insert = true
			end
			if insert then
				table.insert(list, oItem)
			end
		end
	end
	return list
end

-- [[界面刷新]]
function CItemCtrl.RefreshUI(self)
	if self.m_RefreshTimer then
		Utils.DelTimer(self.m_RefreshTimer)
	end
	local function update()
		self:OnEvent(define.Item.Event.RefreshBagItem)
		return false
	end
	self.m_RefreshTimer = Utils.AddTimer(update, 0.1, 0.2)
end

-- 返回指定sid的list(oItem1, oItem2)
function CItemCtrl.GetBagItemListBySid(self, sid)
	if sid and sid > 0 then
		local list = {}
		for _,v in pairs(self.m_BagItems) do
			if sid == v:GetValue("sid") then
				table.insert(list, v)
			end
		end
		return list
	end
end

-- 返回指定sid的所有数量
function CItemCtrl.GetBagItemAmountBySid(self, sid)
	local itemList = self:GetBagItemListBySid(sid)
	if itemList then
		local amount = 0
		for _,v in ipairs(itemList) do
			amount = amount + v:GetValue("amount")
		end
		return amount
	end
	return 0
end

function CItemCtrl.SetEquipedItem(self, iPos, oItem)
	self.m_EquipedItems[iPos] = oItem
	self:OnEvent(define.Item.Event.RefreshEquip)
end

-- 获取指定pos的装备
function CItemCtrl.GetEquipedByPos(self, iPos)
	return self.m_EquipedItems[iPos]
end

function CItemCtrl.GetAllItem(self)
	local t = {}
	for _, v in pairs(self.m_BagItems) do
		table.insert(t, v)
	end
	table.sort(t, function(a, b) return a:GetValue("pos") < b:GetValue("pos") end)
	return t
end

--获取身上及背包所有装备
--@param iSchool 公会 -1 or nil 代表选择全部类型
--@param iSex 性别
--@param iLevel 最小装备等级
--@param iPos 装备位置
--@param iQuality 装备品质
function CItemCtrl.GetEquipList(self, iSchool, iSex, iLevel, iPos, iQuality)
	iSchool = 0 ---TODO:公会暂时没有填表数据，默认0
	iSchool = iSchool or -1
	iSex = iSex or -1
	iLevel = iLevel or -1
	iPos = iPos or -1
	iQuality = iQuality or -1
	-- table.print({iSchool = iSchool, iSex = iSex, iLevel = iLevel, iPos = iPos, iQuality = iQuality})

	local list = {}
	for _,v in pairs(self.m_BagItems) do
		local dEquipData = v
		if v:IsEquip() then
			if iSex ~= -1 and v:GetValue("sex") ~= 0 and 
				v:GetValue("sex") ~= iSex then
				dEquipData = nil
			end 
			if iQuality ~= -1 and v:GetValue("itemlevel") < iQuality then
				print("")
				dEquipData = nil
			end
			if iSchool ~= -1 and v:GetValue("school") ~= iSchool then
				dEquipData = nil
			end
			if iPos ~= -1 and v:GetValue("pos") ~= iPos then
				dEquipData = nil
			end
			local equipLevel = tonumber(v:GetValue("equipLevel"))
			if iLevel ~= -1 and equipLevel < iLevel then 
				dEquipData = nil
			end
			if dEquipData then
				table.insert(list, dEquipData)
			end
		end
	end
	local function sort(equip1, equip2)
		return equip1:GetValue("pos") < equip2:GetValue("pos")
	end 
	table.sort(list, sort)
	return list
end



--返回装备预览数据
--@param citem 物品数据
function CItemCtrl.GetEquipPreview(self, citem)
	local result = {}
	local dAttrData = data.equipdata.EQUIP_ATTR[citem:GetValue("pos")]
	if not dAttrData then
		return
	end
	-- table.print(dAttrData)
	local tRange = DataTools.GetEquipAttrRange()
	for k,v in pairs(dAttrData.attr) do
		local tAttr = {}
		local tStrArr = string.split(v, "=")

		local sAttrName = data.attrnamedata.DATA[tStrArr[1]].name
		local formula = string.gsub(tStrArr[2],"ilv",citem:GetValue("equip_level"))
		local func = loadstring("return "..formula) 
		local iValue = func()
		tAttr.name = sAttrName
		tAttr.min = math.floor(iValue * tRange.min/100)
		tAttr.max = math.floor(iValue * tRange.max/100)
		table.insert(result, tAttr)
	end
	return result
end

--获取背包所有神魂
--@param iPos 装备位置
--@param iMinLevel 最小装备等级
function CItemCtrl.GetEquipSoulList(self, iMinLevel, iPos)
	local list = {}
	local tSoulList = self:GetEquipSoulListByPos(iPos)
	if not tSoulList then
		return list
	end
	for _,v in pairs(tSoulList) do
		if v:IsEquipSoul() and v:GetValue("level") <= iMinLevel and 
		   v:GetValue("pos") == iPos then
			table.insert(list, v)
		end
	end
	--TODO:排序条件待补充
	local function sort(equip1, equip2)
		return equip1:GetValue("pos") < equip2:GetValue("pos")
	end 
	table.sort(list, sort)
	return list
end

--返回装备预览数据
--@param citem 物品数据
function CItemCtrl.GetEquipPreview(self, citem)
	local result = {}
	local dAttrData = data.equipdata.EQUIP_ATTR[citem:GetValue("pos")]
	if not dAttrData then
		return
	end
	-- table.print(dAttrData)
	local tRange = DataTools.GetEquipAttrRange()
	for k,v in pairs(dAttrData.attr) do
		local tAttr = {}
		local tStrArr = string.split(v, "=")

		local sAttrName = data.attrnamedata.DATA[tStrArr[1]].name
		local formula = string.gsub(tStrArr[2],"ilv",citem:GetValue("equip_level"))
		local func = loadstring("return "..formula) 
		local iValue = func()
		tAttr.name = sAttrName
		tAttr.min = math.floor(iValue * tRange.min/100)
		tAttr.max = math.floor(iValue * tRange.max/100)
		table.insert(result, tAttr)
	end
	return result
end

--返回附魂的效果列表
--@param citem 物品数据
--@return result table{{name,value}}
function CItemCtrl.GetSoulEffectList(self, citem)
	local result = {}
	local dAttrData = data.equipdata.EQUIP_ATTR[citem:GetValue("pos")]
	if not dAttrData then
		return
	end
	local iRatio = 0
	for k,v in pairs(citem:GetValue("apply_info")) do
		if v.key == "ratio" then
			iRatio = v.value
			break
		end
	end
	-- table.print(dAttrData)
	for k,v in pairs(dAttrData.attrList) do
		local tAttr = {}

		local sAttrName = data.attrnamedata.DATA[v].name
		local iValue = iRatio
		tAttr.name = sAttrName
		tAttr.value = iValue
		result[v] = tAttr
		-- table.insert(result, tAttr)
	end
	return result
end

function CItemCtrl.GetStrengthInfo(self)
	return self.m_StrengthInfo
end

-----------------------N1 Add----------------------------------------------

function CItemCtrl.ItemSortTypeFunc(self, arg)
	local func = nil 
	func = function( a, b) 
		local len = #arg
		local t = {}
		for i = 1, len do
			local  condition = {}
			condition.a = a:GetValue(arg[i].sortType)
			condition.b = b:GetValue(arg[i].sortType)
			table.insert(t, condition)
		end

		if t[1].a == t[1].b and len > 1 then
			if t[2].a == t[2].b and len > 2 then
				if t[3].a == t[3].b and len > 3 then
					if t[4].a == t[4].b and len > 4 then
						if t[5].a == t[5].b and len > 5 then
							if arg[6].isGreate	== false then
								return t[6].a < t[6].b
							else
								return t[6].a > t[6].b
							end
						else
							if arg[5].isGreate == false then
								return t[5].a < t[5].b
							else
								return t[5].a > t[5].b
							end
						end					
					else
						if arg[4].isGreate == false then						
							return t[4].a < t[4].b
						else
							return t[4].a > t[4].b
						end	
					end			
				else
					if arg[3].isGreate == false then
						return t[3].a < t[3].b
					else
						return t[3].a > t[3].b	
					end						
				end
			else
				if arg[2].isGreate == false then
					return t[2].a < t[2].b
				else
					return t[2].a > t[2].b 
				end					
			end
		else
			if arg[1].isGreate == false then
				return t[1].a < t[1].b
			else
				return t[1].a > t[1].b
			end				
		end
	end
	return func
end

--背包排序池 isGreate = false 升序   isGreate == true 表示降序
CItemCtrl.tSortPool = 
{
	time = {sortType = "create_time", isGreate = true},
	itemLevel = {sortType = "itemlevel", isGreate = true},
	sid = {sortType = "sid", isGreate = false},
	amount = {sortType = "amount", isGreate = false},
	subType = {sortType = "sub_type", isGreate = false},
	level = {sortType = "level", isGreate = true},
	pos = {sortType = "pos", isGreate = false},
	sort = {sortType = "sort", isGreate = false}, --排序的字类型（烹饪，宝图类等等）
	state = {sortType = "state", isGreate = false},
	groupAmount = {sortType = "group_amount", isGreate = false},
	stateGroupAmount = {sortType = "state_group_amount", isGreate = false},
	canEquipLevel = {sortType = "can_equip_level", isGreate = true},
	greateSelfScore = {sortType = "greate_self_score", isGreate = true},
	baseScore = {sortType = "base_score", isGreate = true},
	rare = {sortType = "rare", isGreate = true},
}

--获取背包指定类型所有道具
--@param iType 道具类型 GetValue("type")
--@param iSex 排序方式
--@param isSell 出售是在出售状态(在出售状态下，会过滤价格为0的道具)
function CItemCtrl.GetAllItemsByTypeAndSort(self, iType, sort, isSell)
	local t = {}
	for _, v in pairs(self.m_BagItems) do
		local Process = function ( )
			if v:GetValue("type") == iType then
				table.insert(t, v)
			end
		end
		if isSell == true then
			if v:GetValue("sale_price") ~= 0 and not v:IsEuqipLock() then
				Process()
			end
		else
			Process()
		end
	end

	--普通类型物品排序
	if iType == define.Item.ItemType.Genernal then
		if sort == define.Item.SortType.Sid then			
			table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.sid,
				[2] = CItemCtrl.tSortPool.groupAmount,
				[3] = CItemCtrl.tSortPool.state,
				[4] = CItemCtrl.tSortPool.time,
			}))		
		elseif sort == define.Item.SortType.Itemlevel then			
			table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.itemLevel,
				[2] = CItemCtrl.tSortPool.sort,
				[3] = CItemCtrl.tSortPool.sid,
				[4] = CItemCtrl.tSortPool.state,
				[5] = CItemCtrl.tSortPool.amount,
				[6] = CItemCtrl.tSortPool.time,
			}))
		elseif sort == define.Item.SortType.Type then			
			table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.sort,
				[2] = CItemCtrl.tSortPool.sid,
				[3] = CItemCtrl.tSortPool.state,
				[4] = CItemCtrl.tSortPool.amount,
				[5] = CItemCtrl.tSortPool.time,				
			}))
		elseif sort == define.Item.SortType.Amount then			
			table.sort(t, self:ItemSortTypeFunc({
				--数量排序，组合排序之后，先比较sid，在比较单个物品的数量
				[1] = CItemCtrl.tSortPool.groupAmount,
				[2] = CItemCtrl.tSortPool.sid,
				[3] = CItemCtrl.tSortPool.stateGroupAmount,   --同一状态的道具，组合排序
				[4] = CItemCtrl.tSortPool.state,		
				[5] = CItemCtrl.tSortPool.amount,
				[6] = CItemCtrl.tSortPool.time,	
			}))
		else 
			table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.time,	
				[2] = CItemCtrl.tSortPool.amount,					
			}))
		end		

	--材料类型物品排序
	elseif iType == define.Item.ItemType.Material then
		if sort == define.Item.SortType.Sid then			
			table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.sid,
				[2] = CItemCtrl.tSortPool.groupAmount,
				[3] = CItemCtrl.tSortPool.state,
				[4] = CItemCtrl.tSortPool.time,
			}))			
		elseif sort == define.Item.SortType.Level then	
			table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.level,
				[2] = CItemCtrl.tSortPool.sort,
				[3] = CItemCtrl.tSortPool.sid,
				[4] = CItemCtrl.tSortPool.state,
				[5] = CItemCtrl.tSortPool.amount,
				[6] = CItemCtrl.tSortPool.time,				
			}))
		elseif sort == define.Item.SortType.Type then			
			table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.sort,
				[2] = CItemCtrl.tSortPool.sid,
				[3] = CItemCtrl.tSortPool.state,				
				[4] = CItemCtrl.tSortPool.amount,
				[5] = CItemCtrl.tSortPool.time,					
			}))
		elseif sort == define.Item.SortType.Amount then	
			table.sort(t, self:ItemSortTypeFunc({
				--数量排序，组合排序之后，先比较sid，在比较单个物品的数量
				[1] = CItemCtrl.tSortPool.groupAmount,	
				[2] = CItemCtrl.tSortPool.sid,
				[3] = CItemCtrl.tSortPool.stateGroupAmount,    --同一状态的道具，组合排序
				[4] = CItemCtrl.tSortPool.state,		
				[5] = CItemCtrl.tSortPool.amount,
				[6] = CItemCtrl.tSortPool.time,				
			}))
		else 
			table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.time,
				[2] = CItemCtrl.tSortPool.amount,					
			}))
		end		

	--宝石类型物品排序
	elseif iType == define.Item.ItemType.Gem then
		if sort == define.Item.SortType.Sid then			
			table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.sid,
				[2] = CItemCtrl.tSortPool.groupAmount,
				[3] = CItemCtrl.tSortPool.state,
				[4] = CItemCtrl.tSortPool.time,
			}))			
		elseif sort == define.Item.SortType.Level then	
			table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.level,
				[2] = CItemCtrl.tSortPool.sid,
				[3] = CItemCtrl.tSortPool.state,					
				[4] = CItemCtrl.tSortPool.amount,
				[5] = CItemCtrl.tSortPool.time,	
			}))
		elseif sort == define.Item.SortType.Type then			
			table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.pos,
				[2] = CItemCtrl.tSortPool.sid,
				[3] = CItemCtrl.tSortPool.state,					
				[4] = CItemCtrl.tSortPool.amount,
				[5] = CItemCtrl.tSortPool.time,				
			}))
		elseif sort == define.Item.SortType.Amount then	
			table.sort(t, self:ItemSortTypeFunc({
				--数量排序，组合排序之后，先比较sid，在比较单个物品的数量
				[1] = CItemCtrl.tSortPool.groupAmount,	
				[2] = CItemCtrl.tSortPool.sid,
				[3] = CItemCtrl.tSortPool.stateGroupAmount,   --同一状态的道具，组合排序
				[4] = CItemCtrl.tSortPool.state,		
				[5] = CItemCtrl.tSortPool.amount,
				[6] = CItemCtrl.tSortPool.time,					
			}))
		else 
			table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.time,
				[2] = CItemCtrl.tSortPool.amount,				
			}))
		end

	--装备类物品排序
	elseif iType == define.Item.ItemType.EquipStone then
		if sort == define.Item.SortType.Equip then			
			table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.canEquipLevel,
				[2] = CItemCtrl.tSortPool.greateSelfScore,
				[3] = CItemCtrl.tSortPool.baseScore,
				[4] = CItemCtrl.tSortPool.time,
			}))			
		elseif sort == define.Item.SortType.Level then	
			table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.level,
				[2] = CItemCtrl.tSortPool.itemLevel,
				[3] = CItemCtrl.tSortPool.pos,
				[4] = CItemCtrl.tSortPool.sid,	
				[5] = CItemCtrl.tSortPool.state,	
				[6] = CItemCtrl.tSortPool.time,
			}))
		elseif sort == define.Item.SortType.Pos then	
			table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.pos,
				[2] = CItemCtrl.tSortPool.level,
				[3] = CItemCtrl.tSortPool.itemLevel,
				[4] = CItemCtrl.tSortPool.sid,	
				[5] = CItemCtrl.tSortPool.state,				
				[6] = CItemCtrl.tSortPool.time,				
			}))
		elseif sort == define.Item.SortType.Itemlevel then
			table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.itemLevel,
				[2] = CItemCtrl.tSortPool.level,
				[3] = CItemCtrl.tSortPool.pos,
				[4] = CItemCtrl.tSortPool.sid,
				[5] = CItemCtrl.tSortPool.state,	
				[6] = CItemCtrl.tSortPool.time,					
			}))
		else
			table.sort(t, self:ItemSortTypeFunc({			
				[1] = CItemCtrl.tSortPool.time,								
			}))
		end

	else
		table.sort(t, self:ItemSortTypeFunc({
			[1] = CItemCtrl.tSortPool.sid,
			[2] = CItemCtrl.tSortPool.time,					
		}))

	end
	return t
end

--获取背包指定类型所有道具(通过显示类型)
--@param iShowType 道具显示类型(就是背包的标签)
--@param sort 排序方式
--@param isSell 出售是在出售状态(在出售状态下，会过滤价格为0的道具)
function CItemCtrl.GetAllBagItemsByShowTypeAndSort(self, iShowType, sort, isSell)
	local t = {}
	for _, v in pairs(self.m_BagItems) do
		local Process = function ( )		
			if v:GetValue("bag_show_type") == iShowType then
				table.insert(t, v)
			end
		end
		if isSell == true then
			if v:GetValue("sale_price") ~= 0 and not v:IsEuqipLock() then
				Process()
			end
		else
			Process()
		end
	end
	
	--如果是数量排序为主排序，则需要重置物品的组合数量
 	if sort == define.Item.SortType.Amount then
 		self:RefreshBagItemsGroupAmount(t)
 	end

	--普通类型物品排序
	if iShowType == define.Item.ItemBagShowType.Genernal then
		if sort == define.Item.SortType.Sid then			
			table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.sid,
				[2] = CItemCtrl.tSortPool.groupAmount,
				[3] = CItemCtrl.tSortPool.state,
				[4] = CItemCtrl.tSortPool.time,
			}))		
		elseif sort == define.Item.SortType.Itemlevel then			
			table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.itemLevel,
				[2] = CItemCtrl.tSortPool.sort,
				[3] = CItemCtrl.tSortPool.sid,
				[4] = CItemCtrl.tSortPool.state,
				[5] = CItemCtrl.tSortPool.amount,
				[6] = CItemCtrl.tSortPool.time,
			}))
		elseif sort == define.Item.SortType.Type then			
			table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.sort,
				[2] = CItemCtrl.tSortPool.sid,
				[3] = CItemCtrl.tSortPool.state,
				[4] = CItemCtrl.tSortPool.amount,
				[5] = CItemCtrl.tSortPool.time,				
			}))
		elseif sort == define.Item.SortType.Amount then			
			table.sort(t, self:ItemSortTypeFunc({
				--数量排序，组合排序之后，先比较sid，在比较单个物品的数量
				[1] = CItemCtrl.tSortPool.groupAmount,
				[2] = CItemCtrl.tSortPool.sid,
				[3] = CItemCtrl.tSortPool.stateGroupAmount,   --同一状态的道具，组合排序
				[4] = CItemCtrl.tSortPool.state,		
				[5] = CItemCtrl.tSortPool.amount,
				[6] = CItemCtrl.tSortPool.time,	
			}))
		else 
			table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.time,	
				[2] = CItemCtrl.tSortPool.amount,					
			}))
		end		

	--材料类型物品排序
	elseif iShowType == define.Item.ItemBagShowType.Material then
		if sort == define.Item.SortType.Sid then			
			table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.sid,
				[2] = CItemCtrl.tSortPool.groupAmount,
				[3] = CItemCtrl.tSortPool.state,
				[4] = CItemCtrl.tSortPool.time,
			}))			
		elseif sort == define.Item.SortType.Level then	
			table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.level,
				[2] = CItemCtrl.tSortPool.sort,
				[3] = CItemCtrl.tSortPool.sid,
				[4] = CItemCtrl.tSortPool.state,
				[5] = CItemCtrl.tSortPool.amount,
				[6] = CItemCtrl.tSortPool.time,				
			}))
		elseif sort == define.Item.SortType.Type then			
			table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.sort,
				[2] = CItemCtrl.tSortPool.sid,
				[3] = CItemCtrl.tSortPool.state,				
				[4] = CItemCtrl.tSortPool.amount,
				[5] = CItemCtrl.tSortPool.time,					
			}))
		elseif sort == define.Item.SortType.Amount then	
			table.sort(t, self:ItemSortTypeFunc({
				--数量排序，组合排序之后，先比较sid，在比较单个物品的数量
				[1] = CItemCtrl.tSortPool.groupAmount,	
				[2] = CItemCtrl.tSortPool.sid,
				[3] = CItemCtrl.tSortPool.stateGroupAmount,    --同一状态的道具，组合排序
				[4] = CItemCtrl.tSortPool.state,		
				[5] = CItemCtrl.tSortPool.amount,
				[6] = CItemCtrl.tSortPool.time,				
			}))
		else 
			table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.time,
				[2] = CItemCtrl.tSortPool.amount,					
			}))
		end		
	elseif iShowType == define.Item.ItemBagShowType.Equip then
		if sort == define.Item.SortType.Equip then			
			table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.canEquipLevel,
				[2] = CItemCtrl.tSortPool.greateSelfScore,
				[3] = CItemCtrl.tSortPool.baseScore,
				[4] = CItemCtrl.tSortPool.time,
			}))			
		elseif sort == define.Item.SortType.Level then	
			table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.level,
				[2] = CItemCtrl.tSortPool.itemLevel,
				[3] = CItemCtrl.tSortPool.pos,
				[4] = CItemCtrl.tSortPool.sid,	
				[5] = CItemCtrl.tSortPool.state,	
				[6] = CItemCtrl.tSortPool.time,
			}))
		elseif sort == define.Item.SortType.Pos then	
			table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.pos,
				[2] = CItemCtrl.tSortPool.level,
				[3] = CItemCtrl.tSortPool.itemLevel,
				[4] = CItemCtrl.tSortPool.sid,	
				[5] = CItemCtrl.tSortPool.state,				
				[6] = CItemCtrl.tSortPool.time,				
			}))
		elseif sort == define.Item.SortType.Itemlevel then
			table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.itemLevel,
				[2] = CItemCtrl.tSortPool.level,
				[3] = CItemCtrl.tSortPool.pos,
				[4] = CItemCtrl.tSortPool.sid,
				[5] = CItemCtrl.tSortPool.state,	
				[6] = CItemCtrl.tSortPool.time,					
			}))
		else
			table.sort(t, self:ItemSortTypeFunc({			
				[1] = CItemCtrl.tSortPool.time,								
			}))
		end
	-- 伙伴型物品排序
	elseif iShowType == define.Item.ItemBagShowType.Partner then
		table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.pos,
				[2] = CItemCtrl.tSortPool.sid,
				[3] = CItemCtrl.tSortPool.time,					
			}))

	-- 碎片类型物品排序
	elseif iShowType == define.Item.ItemBagShowType.Chip then
		table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.rare,
				[2] = CItemCtrl.tSortPool.sid,
				[3] = CItemCtrl.tSortPool.time,					
			}))
	-- 其他类型物品排序
	else 
		table.sort(t, self:ItemSortTypeFunc({
				[1] = CItemCtrl.tSortPool.sid,
				[2] = CItemCtrl.tSortPool.time,					
			}))
	end

	return t		
end


--获取背包所有可出售的道具
function CItemCtrl.GetAllCanSellItems(self)
	local t = {}
	for _, v in pairs(self.m_BagItems) do		
		if v:GetValue("sale_price") ~= 0 and not v:IsEquip() then
			table.insert(t, v)
		end
	end
	return t
end

--获取背包上的装备灵石
--@param iPos 装备部位 (为 nil时，表示所有有部位的灵石)
function CItemCtrl.GetEquipStoneByEquipPos(self, iPos)
	local t = {}
	local allEquip = self:GetAllBagItemsByShowTypeAndSort(define.Item.ItemBagShowType.Equip, define.Item.SortType.Level)
	if iPos ~= nil then
		for k, v in pairs(allEquip) do
			if v:GetValue("pos") == iPos then
				table.insert(t, v)
			end
		end
	end
	return t
end

--获取背包上的宝石
--@param iPos 装备部位 (为 nil时，表示所有有部位的灵石)
function CItemCtrl.GetGemByEquipPos(self, iPos)
	local t = {}
	for _, v in pairs(self.m_BagItems) do	

		if v:GetItemSubType() == define.Item.ItemSubType.Gem then
			if iPos ~= nil then
				if iPos == v:GetValue("pos") then
					table.insert(t, v)					
				end
			else
				table.insert(t, v)			
			end
		end
	end

	return t
end

--获取指定部位装备，强化数据
--@param iPos 装备部位 
--@param iLevel,指定等级
function CItemCtrl.GetEquipStrengthDataByPosAndLevel(self, iPos, iLevel)
	--key为1的数据，对应等级为0的强刷数据
	local t = data.itemdata.STRENGTH[iPos][iLevel + 1]
	return t
end

--获取指定装备部位，指定等级的本地符文数据
--@param iPos 装备部位 
--@param iLevel,指定等级
function CItemCtrl.GetEquipFuwenDataByPosAndLevel(self, iPos, iLevel)
	local t = nil
	for _, v in pairs(data.itemdata.FUWEN[iPos]) do
		if v.level == iLevel then
			t = v
			break
		end
	end
	return t
end

--根据人物等级，获取宝石槽的个数
--@param iLevel,指定等级
function CItemCtrl.GetGemSlotCountByLevel(self, iLevel)
	local tData = data.itemdata.GEM_LEVEL
	local iCount = 0
	local iMinKey = nil
	local iMaxKey = nil
	local t = {}
---------------------------------
--保证宝石槽开放个数数据是连续的
	for _,v in pairs (tData) do
		table.insert(t, v)
	end
	table.sort(t, function (a, b )
		return a.grade < b.grade
	end)
----------------------------------
	for k, v in pairs(t) do
		if iMinKey == nil then
			iMinKey = k
		end
		iMaxKey = k
		if v.grade <= iLevel then
			iCount = v.gem_cnt
		else
			break
		end
	end
	return iCount
end

--根据宝石槽的位置，返回该槽解锁等级
function CItemCtrl.GetGemSlotOpenLevelCountByPos(self, pos)
	local tData = data.itemdata.GEM_LEVEL
	local level = 0
	local t = {}

	for k, v in pairs(tData) do
		if v.gem_cnt == pos then
			level = v.grade
			break
		end
	end
	return level
end

--获取伙伴装备 isall为true包括狗粮符文
function CItemCtrl.GetPartnerEquip(self, isall)
	local t = {}
	for _, v in pairs(self.m_BagItems) do
		if v:IsPartnerEquip() then
			table.insert(t, v)
		end
	end
	return t
end

--获取伙伴装备 所有没有没穿戴的符文
function CItemCtrl.GetPartnerUnEquipedEquip(self)
	local t = {}
	for _, v in pairs(self.m_BagItems) do
		if v:IsPartnerEquip() and v:GetValue("parid") == 0 then
			table.insert(t, v)
		end
	end
	return t
end

--获取伙伴装备 isall为true包括狗粮符文
function CItemCtrl.GetPartnerStone(self)
	local t = {}
	for _, v in pairs(self.m_BagItems) do
		if v:IsPartnerStone() then
			table.insert(t, v)
		end
	end
	return t
end

function CItemCtrl.GetParSoulList(self)
	local t = {}
	for _, v in pairs(self.m_BagItems) do
		if v:IsPartnerSoul() then
			table.insert(t, v)
		end
	end
	return t
end

function CItemCtrl.GetParSoulListBySoulType(self, soul_type)
	local t = {}
	for _, v in pairs(self.m_BagItems) do
		if v:IsPartnerSoul() and v:GetValue("soul_type") == soul_type then
			table.insert(t, v)
		end
	end
	return t
end

--获取伙伴装备
function CItemCtrl.GetPartnerChip(self)
	local t = {}
	for _, v in pairs(self.m_BagItems) do
		if v:IsPartnerChip() then
			table.insert(t, v)
		end
	end
	return t
end

--获取游历道具
function CItemCtrl.GetTravelItems(self)
	local t = {}
	for _, v in pairs(self.m_BagItems) do
		if v:IsTravel() then
			table.insert(t, v)
		end
	end
	return t
end

--添加物品
function CItemCtrl.AddItem(self, itemdata)
	printc("AddItem")
	if itemdata then
		local id = itemdata.id
		if self.m_BagItems[id] then
			printc("道具更新 >>> 道具ID:", id)
		end
		local oItem = CItem.New(itemdata)
		self.m_BagItems[id] = oItem

		--如果是装备，则不刷新背包
		if oItem:IsEquiped() then
			--先处理是否要显示更换装备属性
			--self:ShowEquipChangeAttrTips(itemdata.equip_info.pos, oItem)
			self:SetEquipedItem(itemdata.equip_info.pos, oItem)
		elseif oItem:IsPartnerSkin() then
			self:OnEvent(define.Item.Event.RefreshPartnerSkin)
		else
			self:CheckLocalQuickEquip(oItem)
			self:RefreshUI()
		end

		self:AddItemGetTips(id)

		--检测任务道具
		g_TaskCtrl:CheckTaskItemAmount(oItem:GetValue("sid"))
		-- 刷新符文图鉴
		g_PartnerCtrl:UpdatePartnrEquipGuide(oItem)
		--检测王者契约的引导
		if oItem:GetValue("sid") == 10021 then
			g_GuideCtrl:CheckWZQYTipsGuide(oItem:GetValue("amount"))
		end
		self:OnEvent(define.Item.Event.AddItem, oItem)
	end
end

--删除道具
function CItemCtrl.DelItem(self, id)
	if not self.m_BagItems[id] then
		--printerror("道具删 >>> 不存在道具ID:", id)
		return
	end

	--检测任务道具
	g_TaskCtrl:CheckTaskItemAmount(self.m_BagItems[id]:GetValue("sid"))
	self.m_BagItems[id] = nil
	self:OnEvent(define.Item.Event.DelItem, id)
	self:RefreshUI()
end

function CItemCtrl.GetItem(self, itemid)
	return self.m_BagItems[itemid]
end

function CItemCtrl.GetItemListBySid(self, sid)
	local itemList = {}
	for _, v in pairs(self.m_BagItems) do
		if sid == v:GetValue("sid") then
			table.insert(itemList, v:GetValue("id"))
		end
	end
	return itemList
end

function CItemCtrl.GetItemSerberIdListBySid(self, sid)
	local id
	local itemList = {}
	for _, v in pairs(self.m_BagItems) do
		if sid == v:GetValue("sid") then
			table.insert(itemList, v)
		end
	end
	if #itemList > 0 then
		if #itemList > 1 then
			local func = function (a, b)
				return a:GetValue("amount") < b:GetValue("amount")
			end	
			table.sort(itemList, func)
		end
		id = itemList[1]:GetValue("id")
	end
	return id
end

function CItemCtrl.GetItemIDListBySid(self, sid)
	local itemList = {}
	for _, v in pairs(self.m_BagItems) do
		if sid == v:GetValue("sid") then
			table.insert(itemList, v.m_ID)
		end
	end
	return itemList
end

--根据sid 获取该道具的数量
-- sid 物品的sid
-- state 道具的状态（失效，限时，绑定，正常）
function CItemCtrl.GetTargetItemCountBySid(self, sid, state)
	local count = 0
	for _, v in pairs(self.m_BagItems) do
		if sid == v:GetValue("sid") then
			if state ~= nil then
				 if state == v:GetValue("state") then
					count = count + v:GetValue("amount") 	
				 end
			else
				count = count + v:GetValue("amount")
			end
			
		end
	end
	return count
end

--根据id 获取该道具的数量 若不存在，则返回0
function CItemCtrl.GetTargetItemCountById(self, id)
	local count = 0
	for _, v in pairs(self.m_BagItems) do
		if id == v:GetValue("id") then
			count = count + v:GetValue("amount")
			break
		end
	end
	return count
end

--请求打造强化和符文材料的价格
function CItemCtrl.RequestForgeMaterailPrice(self)
	local tSid = {}
	
	--每个装备部位需要的强化材料
	for i = 1, define.Equip.Pos.Shoes do
		local equipData = self:GetEquipedByPos(i)
		local strenthLevel = equipData and equipData:GetStrengthLevel() or 1
		local data = self:GetEquipStrengthDataByPosAndLevel(i, strenthLevel)
		for k = 1, #data.sid_list do
			if not table.index(tSid, data.sid_list[k].sid) then
				table.insert(tSid, data.sid_list[k].sid)
			end
		end
	end

	--符文材料sid，目前只有1个
	local fuwenId = tonumber(data.globaldata.GLOBAL.attr_fuwen_itemid.value) 
	table.insert(tSid, fuwenId)

	self:C2GSItemPrice(tSid)
end

function CItemCtrl.QuickUseItem(self, id)
	local oItem = self.m_BagItems[id]
	if not oItem then
		printc("道具快捷 >>> 不存在唯一道具ID:", id)
		return
	end
	local minGrade = oItem:GetValue("min_grade")
	if minGrade and g_AttrCtrl.grade >= minGrade and not CItemBagMainView:GetView() then
		if #self.m_QuickUseIdCache == 0 then			
			table.insert(self.m_QuickUseIdCache, id)
		else
			local needInsert = true
			--缓存中的装备与当前的道具进行比较								
			if oItem:GetValue("type") == define.Item.ItemType.EquipStone then
				for i = 1, #self.m_QuickUseIdCache do
					local tItem = self.m_BagItems[self.m_QuickUseIdCache[i]]			
					if tItem and tItem:GetValue("type") == define.Item.ItemType.EquipStone and oItem:GetValue("type") == define.Item.ItemType.EquipStone and
						tItem:GetValue("pos") == oItem:GetValue("pos") then
						if self:CheckEquipScore(oItem, tItem) then
							needInsert = false
							self.m_QuickUseIdCache[i] = id
							break 
						end
					end
				end
			end	
			if needInsert then
				table.insert(self.m_QuickUseIdCache, id)
			end
		end
		if self.m_QuickUseTimer then
			Utils.DelTimer(self.m_QuickUseTimer)
			self.m_QuickUseTimer = nil
		end
		self.m_QuickUseTimer = Utils.AddTimer(callback(self, "LocalShowQuickUse"), 0, 0.3)		
	end
end

function CItemCtrl.LocalShowQuickUse(self)
	--打开快捷菜单白名单界面
	if CHeroboxView:GetView() then
		return true
	end
	local function OpenQuickContion()
		local b = true
		if g_WarCtrl:IsWar() then
			b = false
		end
		-- local contion = 
		-- {
		-- 	"CMainMenuView",
		-- 	"CNotifyView",
		-- 	"CGmView",
		-- 	"CChatMainView",
		-- 	"CLoadingView",
		-- 	"CBottomView",
		-- 	"CTeamBulletScreenView",

		-- }
		-- for k,v in pairs(g_ViewCtrl.m_Views) do
		-- 	if v:GetActive() and table.index(contion, v.classname) == nil then
		-- 		--printc("  other view ", v.classname)
		-- 		b = t
		-- 	end
		-- end
		return b
	end
	if #self.m_QuickUseIdCache > 0 then
		local oItem = self.m_BagItems[self.m_QuickUseIdCache[1]]
		local oView = CItemQuickUseView:GetView()		
		if oView and oView.m_Item and oItem then			
			if oView.m_Item:GetValue("type") == define.Item.ItemType.EquipStone and oItem:GetValue("type") == define.Item.ItemType.EquipStone and
				oView.m_Item:GetValue("pos") == oItem:GetValue("pos") then				
				if self:CheckEquipScore(oItem, oView.m_Item) then
					oView:SetItem(oItem)
				else
					table.remove(self.m_QuickUseIdCache, 1)
				end
			else								
				--直接跳过但是还在快捷使用缓存中
			end
			return
		end
		if oItem and OpenQuickContion() and not g_WarCtrl:IsWar() then
			CItemQuickUseView:ShowView(function(oView)
					oView:SetItem(oItem)
			end)
			if #self.m_QuickUseIdCache > 0 then
				table.remove(self.m_QuickUseIdCache, 1)
			end			
		end		
	end
end

-- 返回指定id的道具(服务器唯一id),如果不存在返回nil
function CItemCtrl.GetBagItemById(self, id)
	local oItem  = nil
	for k,item in pairs(self.m_BagItems )  do
		if item:GetValue("id") == id then
			oItem = item
			break
		end
	end
	return oItem
end

-- [[客户端协议处理]]
--打造，装备升级
function CItemCtrl.C2GSPromoteEquipLevel(self, pos, itemid)
	self:SetShowAttrChangeFlag(true)
	netitem.C2GSPromoteEquipLevel(pos, itemid)
end

--打造，装备强化
function CItemCtrl.C2GSEquipStrength(self, pos, strength_info)
	self:SetShowAttrChangeFlag(true)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSEquipStrength"]) then
		netitem.C2GSEquipStrength(pos, strength_info)	
	end
end

--打造，装备一键强化
function CItemCtrl.C2GSFastStrength(self)
	self:SetShowAttrChangeFlag(true)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSFastStrength"]) then
		netitem.C2GSFastStrength()
	end
end

--打造，装备符文重置
function CItemCtrl.C2GSResetFuWen( self, pos, price)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSResetFuWen"]) then
		netitem.C2GSResetFuWen(pos, price)
	end
end

--打造，装备符文保存
function CItemCtrl.C2GSSaveFuWen( self, pos)
	self:SetShowAttrChangeFlag(true)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSSaveFuWen"]) then
		netitem.C2GSSaveFuWen(pos)
	end
end

--打造，宝石镶嵌
function CItemCtrl.CtrlC2GSInlayGem( self, pos, gem_pos, itemid)
	self:SetShowAttrChangeFlag(true)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSInlayGem"]) then
		netitem.C2GSInlayGem(pos, gem_pos, itemid)	
	end
end

--打造，宝石拆卸
function CItemCtrl.CtrlC2GSUnInlayGem( self, pos, gem_pos)
	self:SetShowAttrChangeFlag(true)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSInlayGem"]) then
		netitem.C2GSInlayGem(pos, gem_pos, 0)	
	end
end

--打造，宝石一键镶嵌
function CItemCtrl.CtrlC2GSInlayAllGem(self)
	self:SetShowAttrChangeFlag(true)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSInlayAllGem"]) then
		netitem.C2GSInlayAllGem()	
	end
end

--打造，宝石合成
--amount == 0 为合成全部
function CItemCtrl.CtrlC2GSComposeGem(self, sid, amount)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSComposeGem"]) then
		netitem.C2GSComposeGem(sid, amount)	
	end
end

--打造，请求材料的价格
function CItemCtrl.C2GSItemPrice( self, sid_list)
	netitem.C2GSItemPrice(sid_list)
end

--道具 使用
function CItemCtrl.C2GSItemUse(self, itemid, target, amount)
	self.m_CurUseItemId = itemid
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSItemUse"]) then
		netitem.C2GSItemUse(itemid, target, amount)
	end
end

--道具 一键整理
function CItemCtrl.C2GSArrangeItem(self)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSArrangeItem"]) then
		netitem.C2GSArrangeItem()
	end
end

--道具 出售
function CItemCtrl.C2GSRecycleItem(self, itemid, amount)
	self.m_CurSellItemId = itemid 
	netitem.C2GSRecycleItem(itemid, amount)
end

--断线重连重置
function CItemCtrl.ResetCtrl(self)

	self.m_BagItems = {}
	self.m_EquipedItems = {}
	self.m_QuickUseIdCache = {}
	if self.m_QuickUseTimer then
		Utils.DelTimer(self.m_QuickUseTimer)
	end
	self.m_RedDotIdTable = {}
	self.m_ShowAttrChangeFlag = false
	if self.m_ShowAttrTimer ~= nil then
		Utils.DelTimer(self.m_ShowAttrTimer)
		self.m_ShowAttrTimer = nil
	end
	self.m_ShowAttrCacheAttr = {}
	self.m_ShowAttrCacheKey = {}	
end

-- [[服务器数据接收处理]]
-- 登录道具数据
function CItemCtrl.LoginItem(self, extsize, itemdata, buffitem)
	local function check()
		if not g_AttrCtrl.pid or g_AttrCtrl.pid <= 0 then
			return true
		end
	end
	Utils.AddTimer(check, 0.1, 0.1)
	printc("loginitem")
	self:InitItems(itemdata)
	g_PlayerBuffCtrl:InitBuff(buffitem)
end

--道具初始化
function CItemCtrl.InitItems(self, itemdata)
	if itemdata then
		local isRefresh = false
		local itemDic = self.m_BagItems
		for i, dItem in ipairs(itemdata) do

			local oItem = CItem.New(dItem)
			itemDic[dItem.id] = oItem

			if not isRefresh then
				isRefresh = true
			end
			if oItem:IsEquiped() then
				self:SetEquipedItem(dItem.equip_info.pos, oItem)
			end
		end
		self.m_BagItems = itemDic
		if isRefresh then
			self:RefreshUI()
		end
	end
end

--道具数量变更
function CItemCtrl.SetItemAmount(self, id, amount, create_time)
	local oItem = self.m_BagItems[id]
	if not oItem then
		printc("道具改 >>> 不存在道具ID:", id)
		return
	end

	--若道具数量变更为0，表示不存在
	if amount == 0 then
		g_ItemCtrl:DelItem(id)
		self:RefeshItemGetTipsById(id)
	else
		oItem.m_IsAddAmount = false
		if oItem.m_SData.amount < amount then
			self:AddItemGetTips(id)
			oItem.m_IsAddAmount = true
		end
		oItem.m_SData.amount = amount
		oItem.m_SData.create_time = create_time

		--检测王者契约的引导	
		if oItem:GetValue("sid") == 10021 then
			g_GuideCtrl:CheckWZQYTipsGuide(oItem:GetValue("amount"))
		end
		self:OnEvent(define.Item.Event.RefreshSpecificItem, oItem)
	end

	--检测任务道具
	g_TaskCtrl:CheckTaskItemAmount(oItem:GetValue("sid"))
end

function CItemCtrl.UpdateMaterailPriceCache(self, itemInfo)
	
	for k ,v in pairs (itemInfo) do
		self.m_MaterailPriceCache[v.sid] = v.price or 0
	end
	--刷新价格，做延迟处理，保证在刷新道具之后
	if self.m_RefreshPriceTimer then
		Utils.DelTimer(self.m_RefreshPriceTimer)
	end
	local function update( )
		self:OnEvent(define.Item.Event.RefreshItemPrice, itemInfo)
	end
	self.m_RefreshPriceTimer = Utils.AddTimer(update, 0.1, 0.3)
end

function CItemCtrl.UpdateResetFuwenCache(self, itemId, cur_plan, fuwen)
	local oItem = self.m_BagItems[itemId]
	oItem.m_SData.equip_info = table.copy(oItem.m_SData.equip_info)
	oItem.m_SData.equip_info.fuwen_plan = cur_plan
	oItem.m_SData.equip_info.fuwen = fuwen	
	if self.m_RefreshFuwenTimer  then
		Utils.DelTimer(self.m_RefreshFuwenTimer)
	end
	local function update()
		self:OnEvent(define.Item.Event.RefreshFuwen)
		return false
	end
	self.m_RefreshFuwenTimer = Utils.AddTimer(update, 0, 0.1)
end

function CItemCtrl.UpdateLock(self, itemid, info)
	local oItem = self.m_BagItems[itemid]
	if not oItem then
		return
	end
	oItem:UpdateLock(info)
	self:OnEvent(define.Item.Event.RefreshSpecificItem, oItem)
end

function CItemCtrl.UpdatePartnerEquip(self, itemid, equipinfo)
	local oItem = self.m_BagItems[itemid]
	if not oItem then
		return
	end
	oItem:UpdatePartnerEquip(equipinfo)
	self:OnEvent(define.Item.Event.RefreshPartnerEquip, itemid)
end

function CItemCtrl.UpdatePartnerSoul(self, itemid, equipinfo)
	local oItem = self.m_BagItems[itemid]
	if not oItem then
		return
	end
	oItem:UpdatePartnerSoul(equipinfo)
	self:OnEvent(define.Item.Event.RefreshPartnerSoul, itemid)
end

--合成伙伴装备结果
function CItemCtrl.ComposePartnerEquip(self, itemid)
	self:OnEvent(define.Item.Event.ComposePartnerEquip, itemid)	
end

--获取整套伙伴装备总属性
function CItemCtrl.GetEquipListAttr(self, itemlist)
	local attrdict = {}
	local typedict = {} -- 套装效果
	for k, v in pairs(data.partnerequipdata.EQUIPATTR) do
		attrdict[k] = {}
		attrdict[k]["name"] = v["name"]
		attrdict[k]["value"] = 0
	end
	for _, itemid in pairs(itemlist) do
		local dict = self:GetEquipAttr(itemid)
		for attrkey, value in pairs(dict) do
			attrdict[attrkey]["value"] = attrdict[attrkey]["value"] + value
		end
	end
	return attrdict
end

function CItemCtrl.GetSoulListAttr(self, itemlist)
	local attrdict = {}
	local typedict = {} -- 套装效果
	for k, v in pairs(data.partnerequipdata.EQUIPATTR) do
		attrdict[k] = {}
		attrdict[k]["name"] = v["name"]
		attrdict[k]["value"] = 0
	end
	for _, itemid in pairs(itemlist) do
		local oItem = g_ItemCtrl:GetItem(itemid)
		local dict = {}
		if oItem then
			dict = oItem:GetParSoulAttr()
		end
		for attrkey, value in pairs(dict) do
			attrdict[attrkey]["value"] = attrdict[attrkey]["value"] + value
		end
	end
	return attrdict
end

--获取单个伙伴装备属性
function CItemCtrl.GetEquipAttr(self, itemid)
	local oItem = self:GetItem(itemid)
	if oItem then
		return oItem:GetParEquipAttr()
	else
		return {}
	end
end

--获取伙伴套装类型
function CItemCtrl.GetEquipType(self, itemlist)
	local typedict = {}
	for _, itemid in ipairs(itemlist) do
		local oItem = self:GetItem(itemid)
		local equiptype = oItem:GetValue("equip_type")
		if not typedict[equiptype] then
			typedict[equiptype] = 1
		else
			typedict[equiptype] = typedict[equiptype] + 1
		end
	end
	return typedict
end

function CItemCtrl.GetParEquipShape(self, iPos, iStar, iLevel)
	return 6000000 + iPos * 100000 + iStar * 1000 + iLevel
end

function CItemCtrl.InitParSoul(self)
	if not self.m_ParSoulData then
		self.m_ParSoulData = {}
		for _, v in ipairs(data.partnerequipdata.ParSoulUpGrade) do
			self.m_ParSoulData[v.level] = self.m_ParSoulData[v.level] or {}
			self.m_ParSoulData[v.level][v.quality] = v
		end
	end
end

function CItemCtrl.GetParSoulExp(self, oItem)
	self:InitParSoul()
	local iLevel = oItem:GetValue("level")
	local iQuality = oItem:GetValue("soul_quality")
	local iTotalExp = oItem:GetValue("exp")
	local iExp = 0
	for i = 1, iLevel-1 do
		iExp = iExp + self.m_ParSoulData[i][iQuality]["upgrade_exp"]
	end
	local iCurExp = iTotalExp - iExp
	local iNextLevel = math.min(15, iLevel)

	local iNeedExp = self.m_ParSoulData[iNextLevel][iQuality]["upgrade_exp"]
	if iNextLevel == 15 then
		iNeedExp = 999999999
	end
	return iCurExp, iNeedExp
end

function CItemCtrl.IsBagViewOpening(self)
	return CItemBagMainView:GetView() ~= nil
end

----------------------------------界面跳转函数相关开始------------------------------------
--ItemUseSwitchTo工具函数
function CItemCtrl.FindWayCheckLevel(self, level, findWay)
	local b = false 
	if findWay == true then
		b = (g_AttrCtrl.grade < level)
	end
	return b
end

--ItemUseSwitchTo工具函数
function CItemCtrl.FindWayCheckCondition(self, condition, findWay)
	local b = false 
	if findWay == true then
		b = not condition
	end
	return b
end

--道具使用画面跳转
--oItem  道具的信息
--useType 如果指定useType表示，使用oItem中的use_type
--findWay 是否是获取途径的界面跳转
function CItemCtrl.ItemUseSwitchTo(self, oItem, useType, findWay)
	local isCloseView = false
	local b2
	local b3
	local str1
	local str2
	local use_type = (useType ~= nil) and useType or oItem:GetValue("use_type")
	if use_type == "bag" then	
		--Do Nothing

	--装备 合成(具体标签)
	elseif use_type ~= "" and string.find(use_type, "forge_compose") then
		isCloseView, b2, b3 = self:ItemUseSwitchTo_forge_compose(use_type, findWay)		

	--装备 指定宝石界面
	elseif use_type ~= "" and string.find(use_type, "gemmerge") then
		isCloseView = self:ItemUseSwitchTo_gemmerge(use_type)

	--商店界面
	elseif use_type ~= "" and string.find(use_type, "shop") then
		isCloseView, b2, b3 = self:ItemUseSwitchTo_shop(use_type, findWay)

	--修改名字界面
	elseif use_type == "change_name" then
		CAttrChangeNameView:ShowView()

	elseif use_type == "org_change_name" then
		if not g_OrgCtrl:HasOrg() then
			g_NotifyCtrl:FloatMsg("请先加入公会")
		elseif g_AttrCtrl.org_pos == 1 then
			COrgChangeNameView:ShowView()
		else
			g_NotifyCtrl:FloatMsg("该物品仅限会长使用")
		end
	elseif use_type == "buff" then
		g_PlayerBuffCtrl:UseBuffItem(oItem:GetValue("id"))

	elseif use_type == "travel_exchange" then
		isCloseView, b2, b3 = self:ItemUseSwitchTo_travel_exchange(oItem, findWay)

	elseif use_type == "composite_in_bag" then
		isCloseView = self:ItemUseSwitchTo_composite_in_bag(oItem, findWay)

	elseif use_type ~= "" and string.find(use_type, "targetcard") then
		isCloseView, b2, b3 = self:ItemUseSwitchTo_targetcard(use_type, findWay)

	elseif use_type ~= "" and string.find(use_type, "targetchapterfuben") then
		isCloseView, b2, b3 = self:ItemUseSwitchTo_targetchapterfuben(use_type, findWay)

	elseif use_type ~= "" and string.find(use_type, "targetchapterhardfuben") then
		isCloseView, b2, b3 = self:ItemUseSwitchTo_targetchapterhardfuben(use_type, findWay)		

	elseif use_type ~= "" and string.find(use_type, "partner_equiptargetupstone") then
		isCloseView, b2, b3 = self:ItemUseSwitchTo_partner_equiptargetupstone(use_type)
	else
		--通用跳转处理
		local ItemFunc = string.format("ItemUseSwitchTo_Item_%s", use_type)
		local FindFunc = string.format("ItemUseSwitchTo_Find_%s", use_type)
		--带item参数
		if self[ItemFunc] then
			--挖宝搜素	use_type == "treasure_desc"
			--伙伴觉醒道具合成	use_type == "partner_awakeitem"
			--伙伴觉醒			use_type == "partner_awake"	
			--伙伴碎片			use_type == "partner_chip"
			--伙伴符文符石		use_type == "partner_equip_upstone"	
			--伙伴指定等级符石合成  use_type == "partner_target_stone_compose"		
			--指定人物宝石		use_type == "target_gem_compose"
			--装备 强化界面 	use_type == "forge_strength"
			--装备 符文界面		use_type == "forge_fuwen"
			--装备 宝石界面		use_type == "forge_gem"	
			--背包中合成		use_type == "composite_in_bag"	
			isCloseView, b2, b3, str1, str2 = self[ItemFunc](self, oItem)

		--带findway 或者 不带参数
		elseif self[FindFunc] then			
			--伙伴符文分解	use_type == "partner_equip_compose"
			--伙伴符石合成  use_type == "partner_stone_compose"
			--猎灵 			 use_type == "partner_huntsoul"
			--装备 合成  	use_type == "forge_composite"

			--伙伴主界面	use_type == "partner_main_base"
			--伙伴符文		use_type == "partner_equip_base"	
			--伙伴御灵		use_type == "partner_soul"	
			--伙伴皮肤		use_type == "partner_skin"	

			--伙伴升级		use_type == "partner_upgrade"	
			--伙伴升星		use_type == "partner_upstar"	
			--伙伴升技能	use_type == "partner_upskill"	

			--伙伴符文升级	use_type == "partner_equip_upgrade"	
			--伙伴符文升星	use_type == "partner_equip_upstar"	

			--技能 技能界面	use_type == "school_skill"
			--技能 修炼界面	use_type == "school_cultivate"
			--抽卡界面		use_type == "card"
			--月见幻境界面	use_type == "endless_pve"
			--爬塔界面		use_type == "pata" 
			--世界Boss		use_type == "world_boss"
			--比武场		use_type == "arena"
			--酒馆比武		use_type == "arena_club"
			--学渣的逆袭	use_type == "quesion_answer"
			--日程    		use_type == "schedule" 
			--宅邸			use_type == "house"
			--埋骨之地		use_type == "equip_fuben"
			--异空流放		use_type == "pefuben"
			--每日修行		use_type == "daily_cultivate"
			--登录奖励		use_type == "loginreward"
			--任务已接任务界面	use_type == "task_cur"
			--暗雷			use_type == "anlei"
			--金币购买		use_type == "exchange_coin"
			--图鉴主界面		use_type == "map_book_main"
			--图鉴(伙伴装备)	use_type == "map_book_partner_equip"
			--图鉴(伙伴传记)	use_type == "map_book_partner_book"	

			--日程任务 	use_type == "daily_task"
			--公会  	use_type == "org"
			--公会建设	use_type == "org_build"
			--公会红包	use_type == "org_redbag"
			--公会许愿池use_type == "org_wish"	
			--公会活动 	use_type == "org_fuben"		
			--公会说话  use_type == "org_talk"
			--公会祈坛 	use_type == "org_fuli"	
			--公会战	use_type == "org_war"
			--野外boss	use_type == "fieldboss"
			--据点战	use_type == "terrawars"
			--游历  	use_type == "travel"

			--游历道具 	use_type == "travel_item"
			--幸运转盘	use_type == "limitreward_limitdraw"
			--消费积分	use_type == "limitreward_costscore" 
			--月卡		use_type == "welfare_yueka"
			--成长基金	use_type == "welfare_czjj"
			--剧情副本	use_type == "chapterfuben"
			--协同比武	use_type == "teampvp"
			--协同比武	use_type == "equalarena"
			--成就		use_type == "achieve"
			--怪物攻城  use_type == "monsteratkcity"
			--在线奖励  use_type == "online_gift"
			--情侣 		use_type == "marry"
			--累计充值	use_type ==	"total_pay"
			--灵魂宝箱 	use_type == "soulbox"

			isCloseView, b2, b3, str1, str2 = self[FindFunc](self, findWay)
		end
	end

	if b2 ~= nil and b3 ~= nil then
		return b2, b3, str1, str2
	else
		return isCloseView
	end
end

function CItemCtrl.ItemUseSwitchTo_Find_org_fuli(self, findWay)
	local b1 = g_OpenUICtrl:OpenOrgShop()
	return b1
end

function CItemCtrl.ItemUseSwitchTo_Find_online_gift(self, findWay)
	local b1 = g_OpenUICtrl:OpenOnlineGift()
	return b1
end

function CItemCtrl.ItemUseSwitchTo_Find_monsteratkcity(self, findWay)
	local b1 = g_OpenUICtrl:OpenMonsterAtkCityMainView()
	return b1
end

function CItemCtrl.ItemUseSwitchTo_Find_total_pay(self, findWay)
	if g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.limit_kuanghuan.open_grade then
		CLimitRewardView:ShowView(function (oView)
			oView:ShowTotalPayPage()
		end)		
		return true
	else
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.limit_kuanghuan.open_grade))
	end
	return false
end

function CItemCtrl.ItemUseSwitchTo_Find_soulbox(self, findWay)
	if g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.herobox.open_grade then
		nethuodong.C2GSFindHuodongNpc("herobox")
		return true
	else
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.herobox.open_grade))
	end
	return false
end

function CItemCtrl.ItemUseSwitchTo_Find_achieve(self, findWay)
	local b1 = g_OpenUICtrl:OpenAchieveMainView()
	return b1
end

function CItemCtrl.ItemUseSwitchTo_Find_equalarena(self, findWay)
	local b1 = g_OpenUICtrl:OpenEqualArenaView()
	return b1
end

function CItemCtrl.ItemUseSwitchTo_Find_teampvp(self, findWay)
	local b1 = g_OpenUICtrl:OpenTeamPvp()
	return b1
end

function CItemCtrl.ItemUseSwitchTo_Find_chapterfuben(self, findWay)
	local b1 = g_OpenUICtrl:OpenChapterFubenMainView()
	return b1
end

function CItemCtrl.ItemUseSwitchTo_Find_welfare_czjj(self, findWay)
	local b1 = g_OpenUICtrl:OpenJijin()
	return b1
end

function CItemCtrl.ItemUseSwitchTo_Find_limitreward_limitdraw(self, findWay)
	local b1 = g_OpenUICtrl:OpenLimitDraw()
	return b1
end

function CItemCtrl.ItemUseSwitchTo_Find_limitreward_costscore(self, findWay)
	local b1 = g_OpenUICtrl:OpenCostScore()
	return b1
end

function CItemCtrl.ItemUseSwitchTo_Find_welfare_yueka(self, findWay)
	local b1 = g_OpenUICtrl:OpenYueKa()
	return b1
end

function CItemCtrl.ItemUseSwitchTo_Item_partner_awakeitem(self, oItem)
	if oItem:GetValue("composable") == 1 then
		CAwakeItemComposeView:ShowView(function(oView)
			oView:SetItem(oItem.m_CDataGetter()["id"])
		end)
	end
end

function CItemCtrl.ItemUseSwitchTo_Find_partner_main_base(self, findWay)
	local oParnter = g_PartnerCtrl:GetMainFightPartner()
	if not oParnter then
		g_NotifyCtrl:FloatMsg("当前未拥有伙伴~")
		return false
	end
	CPartnerMainView:ShowView(function(oView)
		oView:OnChangePartner(oParnter:GetValue("parid"))
		oView:ShowMainPage()	
	end)
	return true
end
function CItemCtrl.ItemUseSwitchTo_Find_partner_equip_base(self, findWay)
	local oParnter = g_PartnerCtrl:GetMainFightPartner()
	if not oParnter then
		g_NotifyCtrl:FloatMsg("当前未拥有伙伴~")
		return false
	end
	CPartnerMainView:ShowView(function(oView)
		oView:OnChangePartner(oParnter:GetValue("parid"))
		oView:ShowEquipPage()	
	end)
	return true
end

function CItemCtrl.ItemUseSwitchTo_Find_partner_soul(self, findWay)
	local oParnter = g_PartnerCtrl:GetMainFightPartner()
	if not oParnter then
		g_NotifyCtrl:FloatMsg("当前未拥有伙伴~")
		return false
	end
	CPartnerMainView:ShowView(function(oView)
		oView:OnChangePartner(oParnter:GetValue("parid"))
		oView:ShowSoulPage()
	end)
	return true
end

function CItemCtrl.ItemUseSwitchTo_Find_partner_skin(self, findWay)
	local oParnter = g_PartnerCtrl:GetMainFightPartner()
	if not oParnter then
		g_NotifyCtrl:FloatMsg("当前未拥有伙伴~")
		return false
	end
	CPartnerMainView:ShowView(function(oView)
		oView:OnChangePartner(oParnter:GetValue("parid"))
		oView:ShowSkinPage()
	end)
	return true
end

function CItemCtrl.ItemUseSwitchTo_Find_partner_upgrade(self, findWay)
	local oParnter = g_PartnerCtrl:GetMainFightPartner()
	if not oParnter then
		g_NotifyCtrl:FloatMsg("当前未拥有伙伴~")
		return false
	end
	CPartnerMainView:ShowView(function(oView)
		oView:OnChangePartner(oParnter:GetValue("parid"))
		CPartnerImproveView:ShowView(function(oView)
			oView:OnChangePartner(oParnter:GetValue("parid"))
			oView:ShowUpGradePage()
		end)	
	end)
	return true
end

function CItemCtrl.ItemUseSwitchTo_Find_partner_upstar(self, findWay)
	local oParnter = g_PartnerCtrl:GetMainFightPartner()
	if not oParnter then
		g_NotifyCtrl:FloatMsg("当前未拥有伙伴~")
		return false
	end
	CPartnerMainView:ShowView(function(oView)
		oView:OnChangePartner(oParnter:GetValue("parid"))
			CPartnerImproveView:ShowView(function(oView)
			oView:OnChangePartner(oParnter:GetValue("parid"))
			oView:OnShowStar()
		end)	
	end)
	return true
end

function CItemCtrl.ItemUseSwitchTo_Item_partner_chip(self, oItem)
	if not oItem then
		return false
	end
	if not g_PartnerCtrl:GetMainFightPartner() then
		g_NotifyCtrl:FloatMsg("当前未拥有伙伴~")
		return false
	end
	local shape = oItem:GetValue("icon")	
	local oParnter = g_PartnerCtrl:GetTargetPartnerByPartnerType(shape)
	if oParnter then
		CPartnerImproveView:ShowView(function(oView)
			oView:OnChangePartner(oParnter:GetValue("parid"))
			oView:OnShowStar()
		end)			
	else
		CPartnerMainView:ShowView(function (oView)
			oView:ChangeComposePage(tonumber(20000 + tonumber(shape)))
		end)
	end
	return true
end

function CItemCtrl.ItemUseSwitchTo_Find_partner_upskill(self, findWay)
	local oParnter = g_PartnerCtrl:GetMainFightPartner()
	if not oParnter then
		g_NotifyCtrl:FloatMsg("当前未拥有伙伴~")
		return false
	end

	CPartnerMainView:ShowView(function(oView)
		oView:OnChangePartner(oParnter:GetValue("parid"))
		CPartnerImproveView:ShowView(function(oView)
			oView:OnChangePartner(oParnter:GetValue("parid"))
			oView:OnShowSkill()
		end)
	end)
	return true
end

function CItemCtrl.ItemUseSwitchTo_Item_partner_awake(self, oItem)
	local oParnter = g_PartnerCtrl:GetMainFightPartner()
	if not oParnter then
		g_NotifyCtrl:FloatMsg("当前未拥有伙伴~")
		return false
	end
	local isInbagView = CItemBagMainView:GetView() ~= nil
	if isInbagView then
		CPartnerMainView:ShowView(function(oView)
			oView:OnChangePartner(oParnter:GetValue("parid"))
			--暂时不开详情界面
			-- CPartnerImproveView:ShowView(function(oView)
			-- 	oView:OnChangePartner(oParnter:GetValue("parid"))
			-- 	oView:OnShowAwake()
			-- end)
		end)

	else
		if oItem:GetValue("composable") == 1 then
			CAwakeItemComposeView:ShowView(function(oView)
				oView:SetItem(oItem.m_CDataGetter()["id"])
			end)
		end
	end
	return true
end

function CItemCtrl.GetPartnerEquipSwitchItem(self, pos)
	local oItem = nil
	local list = self:GetPartnerEquip()
	if #list == 1 then
		if not pos or pos == list[1]:GetValue("pos") then			
			oItem = list[1]
		end	
	elseif #list > 1 then
		local function sort(a, b)
			return a:GetValue("parid") > b:GetValue("parid")
		end
		table.sort(list, sort)
		oItem = list[1]
		if oItem:GetValue("parid") ~= 0 then
			local oParnter = g_PartnerCtrl:GetMainFightPartner()
			if oParnter then
				local mainParid = oParnter:GetValue("parid")
				for i = 2, #list do
					local parid = list[i]:GetValue("parid")				
					if parid == mainParid then						
						if not pos or pos == list[i]:GetValue("pos") then							
							return list[i]													
						end						
					elseif parid == 0 then
						if pos then							
							return nil											
						end											
						return oItem
					end
				end
			end
		else
			if pos and pos ~= oItem:GetValue("pos") then			
				oItem = nil
			end	
		end
	end	
	return oItem
end

function CItemCtrl.ItemUseSwitchTo_Find_partner_equip_upgrade(self, findWay)
	local oParnter = g_PartnerCtrl:GetMainFightPartner()
	if not oParnter then
		g_NotifyCtrl:FloatMsg("当前未拥有伙伴~")
		return false
	end	
	local oItem = self:GetPartnerEquipSwitchItem()
	if not oItem then
		g_NotifyCtrl:FloatMsg("当前未拥有符文~")
		return false
	end
	CPartnerMainView:ShowView(function(oView)
		oView:OnChangePartner(oParnter:GetValue("parid"))
		oView:ShowEquipPage()
		if oView.m_PartnerEquipPage then
			oView.m_PartnerEquipPage:ShowUpGradePart(oItem)		
		end			
	end)
	return true
end

function CItemCtrl.ItemUseSwitchTo_Find_partner_equip_upstar(self, findWay)
	local oParnter = g_PartnerCtrl:GetMainFightPartner()
	if not oParnter then
		g_NotifyCtrl:FloatMsg("当前未拥有伙伴~")
		return false
	end		
	local oItem = self:GetPartnerEquipSwitchItem()
	if not oItem then
		g_NotifyCtrl:FloatMsg("当前未拥有符文~")
		return false
	end
	CPartnerMainView:ShowView(function(oView)
		oView:OnChangePartner(oParnter:GetValue("parid"))
		oView:ShowEquipPage()
		if oView.m_PartnerEquipPage then
			oView.m_PartnerEquipPage:ShowUpStarPart(oItem)		
		end			
	end)	
	return true
end

function CItemCtrl.ItemUseSwitchTo_Item_partner_equip_upstone(self, oItem)
	local oParnter = g_PartnerCtrl:GetMainFightPartner()
	if not oParnter then
		g_NotifyCtrl:FloatMsg("当前未拥有伙伴~")
		return false
	end		
	CPartnerMainView:ShowView(function(oView)
		oView:OnChangePartner(oParnter:GetValue("parid"))
		oView:ShowEquipPage()
		if oView.m_PartnerEquipPage then
			oView.m_PartnerEquipPage:ShowUpStonePart(oItem:GetValue("equip_pos"))		
		end		
	end)	
	return true
end

function CItemCtrl.ItemUseSwitchTo_Item_partner_target_stone_compose(self, oItem)	
	local iPos = 1
	local iLevel = 1
	if oItem then
		iPos = oItem:GetValue("equip_pos") or 1
		iLevel = oItem:GetValue("level") or 1
	end
	if iLevel > 1 then
		iLevel = iLevel - 1
	end
	CPartnerStoneComposeView:ShowView(function (oView)
		oView:InitStoneType(iPos, iLevel)
	end)
end

function CItemCtrl.ItemUseSwitchTo_Item_target_gem_compose(self, oItem)	
	local iPos = oItem:GetValue("pos") or 1
	local iLevel = oItem:GetValue("level") or 1
	if iLevel > 1 then
		iLevel = iLevel - 1
	end
	CForgeGemCompositeView:ShowView(function (oView)
		oView:SetContent(iPos, iLevel)
	end)
	local oView = CItemTipsSimpleInfoView:GetView()
	if oView then
		oView:CloseView()
	end
end

function CItemCtrl.ItemUseSwitchTo_partner_equiptargetupstone(self, use_type)
	local oParnter = g_PartnerCtrl:GetMainFightPartner()
	if not oParnter then
		g_NotifyCtrl:FloatMsg("当前未拥有伙伴~")
		return false
	end			
	local list = string.split(use_type, "_")
	local pos = 1
	if #list >= 3 then
		pos = tonumber(list[3])
	end
	local oItem = self:GetPartnerEquipSwitchItem(pos)
	if not oItem then
		g_NotifyCtrl:FloatMsg("当前未拥有符文~")
		return false
	end
	CPartnerMainView:ShowView(function(oView)
		oView:OnChangePartner(oParnter:GetValue("parid"))
		oView:ShowEquipPage()
		CPartnerEquipImproveView:ShowView(function(oView)
			oView:SetItemData(oItem)
			oView:ShowStonePage()
		end)
	end)	
	return true
end


--装备 强化界面
function CItemCtrl.ItemUseSwitchTo_Item_forge_strength(self, oItem)
	local b1 = false
	if g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.forge_strength.open_grade then
		b1 = true
		local pos = define.Equip.Pos.Weapon
		if oItem then
			local pos = oItem:GetValue("pos") or define.Equip.Pos.Weapon
		end			
		CForgeMainView:ShowView(function (oView)
			oView:ShowIntensifyPage()
			oView:OnEquipClick(pos)
		end)
	else
		g_NotifyCtrl:FloatMsg(string.format("%d级开启突破功能哦", data.globalcontroldata.GLOBAL_CONTROL.forge_strength.open_grade))
	end
	return b1
end

--装备 符文界面
function CItemCtrl.ItemUseSwitchTo_Item_forge_fuwen(self, oItem)
	local b1 = false
	if g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.forge_fuwen.open_grade then
		b1 = true
		local pos = define.Equip.Pos.Weapon
		if oItem then
			pos = oItem:GetValue("pos") or define.Equip.Pos.Weapon
		end
		CForgeMainView:ShowView(function (oView)
			oView:ShowRunePage()
			oView:OnEquipClick(pos)
		end)
	else
		g_NotifyCtrl:FloatMsg(string.format("%d级开启淬灵功能哦", data.globalcontroldata.GLOBAL_CONTROL.forge_fuwen.open_grade))
	end
	return b1
end

--装备 宝石界面
function CItemCtrl.ItemUseSwitchTo_Item_forge_gem(self, oItem)
	local b1 = false
	if g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.forge_gem.open_grade then
		b1 = true
		local pos = oItem:GetValue("pos") or define.Equip.Pos.Weapon
		CForgeMainView:ShowView(function (oView)
			oView:ShowGemPage()
			oView:OnEquipClick(pos)
		end)
	else
		g_NotifyCtrl:FloatMsg(string.format("%d级开启宝石功能哦", data.globalcontroldata.GLOBAL_CONTROL.forge_gem.open_grade))
	end
	return b1
end

--背包中合成操作
function CItemCtrl.ItemUseSwitchTo_composite_in_bag(self, oItem, findWay)
	if not oItem then
		return false
	end
	local sid = oItem:GetValue("sid")
	if findWay then
		sid = sid - 1
	end
	if g_AttrCtrl.grade >= oItem:GetValue("min_grade") then
		CItemTipsPropComposeView:ShowView(function (oView)
			oView:SetItem(sid)
		end)
	else
		g_NotifyCtrl:FloatMsg(string.format("%d级开启此功能哦", oItem:GetValue("min_grade")))
	end
end

--装备 装备合成
function CItemCtrl.ItemUseSwitchTo_Find_forge_composite(self)
	local b1 = false
	if g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.forge_composite.open_grade then
		b1 = true
		CForgeMainView:ShowView(function (oView)
			local _, pos = self:ShowForgeRedDotByComposite()
			if not pos then
				pos = 1
			end
			oView:ShowComposite(1)
			oView.m_CompositePage:OnClickEquipBox(pos)

		end)
	else
		g_NotifyCtrl:FloatMsg(string.format("%d级开启装备合成功能哦", data.globalcontroldata.GLOBAL_CONTROL.forge_composite.open_grade))
	end
	return b1
end


--装备 指定宝石界面
function CItemCtrl.ItemUseSwitchTo_gemmerge(self, use_type)
	local b1 = false
	if g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.forge_gem.open_grade then
		local gemMerge = string.split(use_type, "_")
		if #gemMerge == 2 then
			b1 = true
			local pos = tonumber(gemMerge[2])
			CForgeMainView:ShowView(function (oView)
				oView:ShowGemPage()
				oView:OnEquipClick(pos)
			end)
		end		
	else
		g_NotifyCtrl:FloatMsg(string.format("%d级开启宝石功能哦", data.globalcontroldata.GLOBAL_CONTROL.forge_gem.open_grade))
	end	
	return b1
end

--技能 技能界面
function CItemCtrl.ItemUseSwitchTo_Find_school_skill(self, findWay)
	local b1 = false
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.school_skill.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.school_skill.open_grade))
	else
		CSkillMainView:ShowView(function (oView)
			oView:OnClick("SwitchTab", CSkillMainView.EnumPage.SchoolPage)
		end)
		b1 = true
	end
	return b1
end

--技能 修炼界面
function CItemCtrl.ItemUseSwitchTo_Find_school_cultivate(self, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.cultivate_skill.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.cultivate_skill.open_grade))
		b2 = false
		b3 = false
	else
		if data.globalcontroldata.GLOBAL_CONTROL.cultivate_skill.is_open == "y" then
			b1 = true
			CSkillMainView:ShowView(function (oView )
				oView:OnClick("SwitchTab", CSkillMainView.EnumPage.CultivatePage)
			end)
		else
			b1 = false
			g_NotifyCtrl:FloatMsg("该功能正在维护，已临时关闭，请您留意官网相关信息。")
		end				
	end
	return b1, b2, b3
end

function CItemCtrl.ItemUseSwitchTo_targetcard(self, use_type, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.draw_card.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.draw_card.open_grade))
		b2 = false
		b3 = false
	else
		
		local list = string.split(use_type, "_")
		local partner_type 
		local iType = 1

		if #list >= 2 then
			partner_type = tonumber(list[2])
			local d = data.partnerdata.DATA[partner_type]
			if d then
				iType = d.rare
			end
		end	
		local oView = CPartnerHireView:GetView()
		if oView then
			if partner_type then
				oView:SetPartner(partner_type)
				if iType == 2 then
					oView:SetChangeType(iType)
				end
			end
		else
			CPartnerHireView:ShowView(function (oView)
				if partner_type then
					oView:SetPartner(partner_type)
					if iType == 2 then
						oView:SetChangeType(iType)
					end
				end
			end)
			b1 = true
		end
	end
	return b1, b2, b3
end

-- 抽卡界面
function CItemCtrl.ItemUseSwitchTo_Find_card(self, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.draw_card.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.draw_card.open_grade))
		b2 = false
		b3 = false
	else
		b1 = true
		CPartnerHireView:ShowView()
	end
	return b1, b2, b3
end

-- 月见幻境界面
function CItemCtrl.ItemUseSwitchTo_Find_endless_pve(self, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.endless_pve.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.endless_pve.open_grade))
		b2 = false
		b3 = false
	else
		if g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.endless_pve.open_grade then
			if self:GetTargetItemCountBySid(10022) > 0 then
				g_EndlessPVECtrl:GetChipList()
				b1 = true
			else
				g_NotifyCtrl:FloatMsg("镜花水月可从活跃度奖励获得")								
			end			
		else
			g_NotifyCtrl:FloatMsg(data.globalcontroldata.GLOBAL_CONTROL.endless_pve.open_grade .. "级后方可使用")			
		end		
	end
	return b1, b2, b3
end

--爬塔界面
function CItemCtrl.ItemUseSwitchTo_Find_pata(self, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.pata.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.pata.open_grade))
		b2 = false
		b3 = false
	else
		if data.globalcontroldata.GLOBAL_CONTROL.pata.is_open == "y" then
			if g_PataCtrl:PaTaEnterView() == true then
				b1 = true
			else
				b1 = false	
			end
		else
			b1 = false
			g_NotifyCtrl:FloatMsg("该功能正在维护，已临时关闭，请您留意官网相关信息。")
		end			
	end
	return b1, b2, b3
end

--挖宝搜素
function CItemCtrl.ItemUseSwitchTo_Item_treasure_desc(self, oItem)
	local b1 = true
	local itemid = oItem:GetValue("id")
	g_TreasureCtrl:OpenTreasureDescView(itemid)
	return b1
end

--商店界面
function CItemCtrl.ItemUseSwitchTo_shop(self, use_type, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.shop.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.shop.open_grade))
		b2 = false
		b3 = false
	else
		local shopConfig = string.split(use_type, "_")
		if #shopConfig >= 3 then
			local main = tonumber(shopConfig[2]) or 1
			local sub = tonumber(shopConfig[3]) or 1
			local mainId = data.npcstoredata.PageSort[main]
			if shopConfig[4] then
				g_NpcShopCtrl:SetQuickBuyGood(tonumber(shopConfig[4]))
			end
			if mainId and data.npcstoredata.StorePage[mainId] and  data.npcstoredata.StorePage[mainId].subId[sub] then
				local shopId = data.npcstoredata.StorePage[mainId].subId[sub]
				if shopId then
					b1 = g_NpcShopCtrl:OpenShop(shopId)
				end			
			end			
		end		
	end
	return b1, b2, b3
end

function CItemCtrl.ItemUseSwitchTo_targetchapterhardfuben(self, use_type, findWay)
	local b1 = false
	local b2 
	local b3	
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.chapterfuben.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg("战役未开启")
		b2 = false
		b3 = false
	else
		local shopConfig = string.split(use_type, "_")
		if #shopConfig >= 2 then
			local isOpenDetail = false
			local chapter = tonumber(shopConfig[2]) or 1
			local level = nil
			if shopConfig[3] then
				level = tonumber(shopConfig[3])
			end
			local maxChapter = g_ChapterFuBenCtrl:GetCurMaxChapter(define.ChapterFuBen.Type.Difficult)
			if level then
				if g_ChapterFuBenCtrl:CheckChapterLevelOpen(define.ChapterFuBen.Type.Difficult, chapter, level) then
					isOpenDetail = true
				end
			end
			if chapter > maxChapter then
				chapter = maxChapter
				if findWay then
					g_NotifyCtrl:FloatMsg("当前未开启该章节，请继续通关")
					return
				end
			end
			if isOpenDetail then
				g_ChapterFuBenCtrl.m_WarAfterReshow = true
				g_ChapterFuBenCtrl:ForceChapterLevel(define.ChapterFuBen.Type.Difficult, chapter, level)
			else
				CChapterFuBenMainView:ShowView(function (oView)
					oView:ForceChapterInfo(define.ChapterFuBen.Type.Difficult, chapter)
				end)
			end
		end	
		b1 = true	
	end
	return b1, b2, b3
end

function CItemCtrl.ItemUseSwitchTo_targetchapterfuben(self, use_type, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.chapterfuben.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg("战役未开启")
		b2 = false
		b3 = false
	else
		local shopConfig = string.split(use_type, "_")
		if #shopConfig >= 2 then
			local isOpenDetail = false
			local chapter = tonumber(shopConfig[2]) or 1
			local level = nil
			if shopConfig[3] then
				level = tonumber(shopConfig[3])
			end
			local maxChapter = g_ChapterFuBenCtrl:GetCurMaxChapter(define.ChapterFuBen.Type.Simple)
			if level then
				if g_ChapterFuBenCtrl:CheckChapterLevelOpen(define.ChapterFuBen.Type.Simple, chapter, level) then
					isOpenDetail = true
				end
			end
			if chapter > maxChapter then
				chapter = maxChapter
				if findWay then
					g_NotifyCtrl:FloatMsg("当前未开启该章节，请继续通关")
					return
				end
			end
			if isOpenDetail then
				g_ChapterFuBenCtrl.m_WarAfterReshow = true
				g_ChapterFuBenCtrl:ForceChapterLevel(define.ChapterFuBen.Type.Simple, chapter, level)
			else
				CChapterFuBenMainView:ShowView(function (oView)
					oView:ForceChapterInfo(define.ChapterFuBen.Type.Simple, chapter)
				end)
			end
		end	
		b1 = true	
	end
	return b1, b2, b3
end
--世界Boss
function CItemCtrl.ItemUseSwitchTo_Find_world_boss(self, findWay)
	local b1 = false
	local b2 
	local b3
	local str 
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.worldboss.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.worldboss.open_grade))
		b2 = false
		b3 = false
	end
	if self:FindWayCheckCondition(g_ActivityCtrl:IsOpen(1001), findWay) then
		local time = tonumber(data.playconfigdata.WORLDBOSS.start_time.val)
		str = string.format("%d:00", time)
		b2 = false
		b3 = true
	else
		if g_AttrCtrl.grade < data.globalcontroldata.GLOBAL_CONTROL.worldboss.open_grade then
			g_NotifyCtrl:FloatMsg("未达到开放等级。")
		elseif not g_ActivityCtrl:IsOpen(1001) then
		 	g_NotifyCtrl:FloatMsg("活动未开启。")
		elseif g_ActivityCtrl:IsOpen(1001) and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.worldboss.open_grade then			
			b1 = true
			nethuodong.C2GSOpenBossUI()
		end				
	end
	return b1, b2, b3, str
end

--比武场
function CItemCtrl.ItemUseSwitchTo_Find_arena(self, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.arenagame.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.arenagame.open_grade))
		b2 = false
		b3 =  false
	else
		b1 = true
		g_ArenaCtrl:ShowArena()	
	end
	return b1, b2, b3
end

--学渣的逆袭
function CItemCtrl.ItemUseSwitchTo_Find_quesion_answer(self, findWay)
	local b1 = false
	local b2 
	local b3
	local str1
	local str2
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.question.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.question.open_grade))
		b2 = false
		b3 = false
	else
		local oCtrl = g_ActivityCtrl:GetQuesionAnswerCtrl()
		if oCtrl then		
			if self:FindWayCheckCondition(oCtrl:IsInReadyTime(), findWay) then							
				b2 = false
				b3 = true
				str1 = "11:50"
				str2 = "12:00"
			else
				b1 = oCtrl:EnterActicity()
				if b1 == false then
					b2 = false
					b3 = true
				end				
			end
		end		
	end
	return b1, b2, b3, str1, str2
end

--公会
function CItemCtrl.ItemUseSwitchTo_Find_org(self, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.org.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.org.open_grade))
		b2 = false
		b3 = false
	else
		b1 = true
		g_OrgCtrl:OpenOrg()
	end
	return b1, b2, b3
end

--日程
function CItemCtrl.ItemUseSwitchTo_Find_schedule(self, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.schedule.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.schedule.open_grade))
		b2 = false
		b3 = false
	else
		b1 = true
		--打开日程的每日必做
		g_ScheduleCtrl:C2GSOpenScheduleUI()
	end
	return b1, b2, b3
end

--宅邸
function CItemCtrl.ItemUseSwitchTo_Find_house(self, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.house.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.house.open_grade))
		b2 = false
		b3 = false
	else
		b1 = true
		nethouse.C2GSEnterHouse(g_AttrCtrl.pid)
	end
	return b1, b2, b3
end

--埋骨之地
function CItemCtrl.ItemUseSwitchTo_Find_equip_fuben(self, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.equipfuben.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.equipfuben.open_grade))
		b2 = false
		b3 = false
	else
		b1 = true
		g_OpenUICtrl:WalkToEquipFubenNpc()	
	end
	return b1, b2, b3
end

--异空流放
function CItemCtrl.ItemUseSwitchTo_Find_pefuben(self, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.pefuben.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.pefuben.open_grade))
		b2 = false
		b3 = false
	else
		b1 = true
		netopenui.C2GSClickSchedule(define.Schedule.ID.PEFb)
	end
	return b1, b2, b3
end

--每日修行
function CItemCtrl.ItemUseSwitchTo_Find_daily_cultivate(self, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.lilian.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.lilian.open_grade))
		b2 = false
		b3 = false
	else
		b1 = true
		g_OpenUICtrl:WalkToDailyTrainNpc()
	end
	return b1, b2, b3
end

--登录奖励
function CItemCtrl.ItemUseSwitchTo_Find_loginreward(self, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.loginreward.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.loginreward.open_grade))
		b2 = false
		b3 = false
	else
		b1 = true
		CLoginRewardView:ShowView()		
	end
	return b1, b2, b3
end

--任务已接任务界面
function CItemCtrl.ItemUseSwitchTo_Find_task_cur(self, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.task.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.task.open_grade))
		b2 = false
		b3 = false
	else
		b1 = true
		CTaskMainView:ShowView(function (oView)
			oView:ShowDefaultTask()
		end)		
	end
	return b1, b2, b3
end

--暗雷
function CItemCtrl.ItemUseSwitchTo_Find_anlei(self, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.trapmine.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.trapmine.open_grade))
		b2 = false
		b3 = false
	else
		b1 = true
		g_MainMenuCtrl:OpenWoldMap({key = "anlei"})
	end
	return b1, b2, b3
end

--金币购买
function CItemCtrl.ItemUseSwitchTo_Find_exchange_coin(self, findWay)
	local b1 = false
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.shop.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.shop.open_grade))
	else
		g_NpcShopCtrl:ShowGold2CoinView()
		b1 = true	
	end	
	return b1
end

--伙伴符文分解
function CItemCtrl.ItemUseSwitchTo_Find_partner_equip_compose(self)
	local b1 = true
	CPartnerEquipComposeView:ShowView()
	return b1
end

--装备合成
function CItemCtrl.ItemUseSwitchTo_forge_compose(self,  use_type, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.forge_composite.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.forge_composite.open_grade))
		b2 = false
		b3 = false
	else
		local composeConfig = string.split(use_type, "_")
		if #composeConfig == 4 then
			b1 = true
			local type = tostring(composeConfig[3]) or "equip"
			local pos = tonumber(composeConfig[4]) or 1			
			CForgeMainView:ShowView(function (oView)
				oView:ShowComposite(1)
				if oView.m_CompositePage then
					if type == "equip" then
						oView.m_CompositePage:SetEquipPosAndItemIdx(pos, 1)
					elseif type == "item" then
						oView.m_CompositePage:SetEquipPosAndItemIdx(1, pos)
					else
						oView.m_CompositePage:SetEquipPosAndItemIdx(1, 1)
					end
				end
			end)
		end		
	end
	return b1, b2, b3
end

--图鉴主界面
function CItemCtrl.ItemUseSwitchTo_Find_map_book_main(self, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.mapbook.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.mapbook.open_grade))
		b2 = false
		b3 = false
	else
		b1 = true
		CMapBookView:ShowView()
	end
	return b1, b2, b3
end

--伙伴装备图鉴
function CItemCtrl.ItemUseSwitchTo_Find_map_book_partner_equip(self, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.fuwenbook.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.fuwenbook.open_grade))
		b2 = false
		b3 = false
	else
		b1 = true
		CMapBookView:ShowView(function (oView)
			oView:ShowLostBookPage()
		end)
	end
	return b1, b2, b3
end

--图鉴伙伴传记
function CItemCtrl.ItemUseSwitchTo_Find_map_book_partner_book(self, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.mapbook.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.fuwenbook.open_grade))
		b2 = false
		b3 = false
	else
		b1 = true
		CMapBookView:ShowView(function (oView)
			oView:ShowPartnerBookPage()
		end)
	end
	return b1, b2, b3
end

--游历
function CItemCtrl.ItemUseSwitchTo_Find_travel(self, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.travel.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.travel.open_grade))
		b2 = false
		b3 = false
	else
		b1 = true
		CTravelView:ShowView()
	end
	return b1, b2, b3
end

--日常任务
function CItemCtrl.ItemUseSwitchTo_Find_daily_task(self, findWay)
	local b1 = false
	local b2 
	local b3
	local oTask = g_TaskCtrl:GetMissMengTask()
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.task.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.task.open_grade))
		b2 = false
		b3 = false
	elseif not oTask then
		g_NotifyCtrl:FloatMsg("没有日常任务!")
		b2 = false
		b3 = false
	else
		g_TaskCtrl:ClickTaskLogic(oTask)
		b1 = true
	end
	return b1, b2, b3
end

--公会建设
function CItemCtrl.ItemUseSwitchTo_Find_org_build(self, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.org.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.org.open_grade))
		b2 = false
		b3 = false
	elseif not g_OrgCtrl:HasOrg() then
		b2 = false
		b3 = false
		g_NotifyCtrl:FloatMsg(string.format("请先加入公会"))
	else
		g_OpenUICtrl:OpenOrgBuildPage()
		b1 = true
	end
	return b1, b2, b3
end

--公会红包
function CItemCtrl.ItemUseSwitchTo_Find_org_redbag(self, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.org.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.org.open_grade))
		b2 = false
		b3 = false
	elseif not g_OrgCtrl:HasOrg() then
		b2 = false
		b3 = false
		g_NotifyCtrl:FloatMsg(string.format("请先加入公会"))
	else
		g_OpenUICtrl:OpenOrgRedBagPage()
		b1 = true
	end
	return b1, b2, b3
end

--公会许愿池
function CItemCtrl.ItemUseSwitchTo_Find_org_wish(self, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.org.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.org.open_grade))
		b2 = false
		b3 = false
	elseif not g_OrgCtrl:HasOrg() then
		b2 = false
		b3 = false
		g_NotifyCtrl:FloatMsg(string.format("请先加入公会"))
	else
		g_OpenUICtrl:OpenOrgWish()
		b1 = true
	end
	return b1, b2, b3
end

--公会活动
function CItemCtrl.ItemUseSwitchTo_Find_org_fuben(self, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.org.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.org.open_grade))
		b2 = false
		b3 = false
	elseif not g_OrgCtrl:HasOrg() then
		b2 = false
		b3 = false
		g_NotifyCtrl:FloatMsg(string.format("请先加入公会"))
	else
		g_OpenUICtrl:OpenOrgFubenPage()
		b1 = true
	end
	return b1, b2, b3
end

--公会议事厅
function CItemCtrl.ItemUseSwitchTo_Find_org_talk(self, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.org.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.org.open_grade))
		b2 = false
		b3 = false
	elseif not g_OrgCtrl:HasOrg() then
		b2 = false
		b3 = false
		g_NotifyCtrl:FloatMsg(string.format("请先加入公会"))
	else
		COrgMainView:SetShowCB(function ()
			COrgChamberView:ShowView()
			COrgMainView:ClearShowCB()
		end)
		COrgMainView:ShowView()
		b1 = true
	end
	return b1, b2, b3
end

--野外boss
function CItemCtrl.ItemUseSwitchTo_Find_fieldboss(self, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.fieldboss.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.fieldboss.open_grade))
		b2 = false
		b3 = false
	else
		b1 = true
		nethuodong.C2GSOpenFieldBossUI()
	end
	return b1, b2, b3
end

--据点战
function CItemCtrl.ItemUseSwitchTo_Find_terrawars(self, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.org.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.org.open_grade))
		b2 = false
		b3 = false
	elseif not g_OrgCtrl:HasOrg() then
		b2 = false
		b3 = false
		g_NotifyCtrl:FloatMsg(string.format("请先加入公会"))
	else
		g_TerrawarCtrl:C2GSTerrawarMain()
		b1 = true
	end
	return b1, b2, b3
end

function CItemCtrl.ItemUseSwitchTo_travel_exchange(self, oItem, findWay)
	local b1 = false
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.travel.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.travel.open_grade))

	else
		if oItem then
			g_TravelCtrl.m_DefaultSelectTraveShopSid = oItem:GetValue("sid")
		end
		netstore.C2GSOpenShop(define.Store.Page.TravelShop)
	end
	return b1
end

function CItemCtrl.ItemUseSwitchTo_Find_travel_item(self, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.travel.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.travel.open_grade))
		b2 = false
		b3 = false
	else
		CTravelView:ShowView(function ()
			CTravelItemView:ShowView()
		end)
		b1 = true
	end
	return b1, b2, b3
end

function CItemCtrl.ItemUseSwitchTo_Find_partner_huntsoul(self, findWay)
	local b1 = g_OpenUICtrl:OpenHuntPartnerSoul()
	return b1
end

function CItemCtrl.ItemUseSwitchTo_Find_partner_stone_compose(self, findWay)
	local b1 = true
	CPartnerStoneComposeView:ShowView()
	return b1
end

function CItemCtrl.ItemUseSwitchTo_Find_arena_club(self, findWay)
	local b1 = g_OpenUICtrl:OpenClubArenaView()
	return b1
end

function CItemCtrl.ItemUseSwitchTo_Find_org_war(self, findWay)
	local b1 = false
	local b2 
	local b3
	if self:FindWayCheckLevel(data.globalcontroldata.GLOBAL_CONTROL.org.open_grade, findWay) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.org.open_grade))
		b2 = false
		b3 = false
	elseif not g_OrgCtrl:HasOrg() then
		b2 = false
		b3 = false
		g_NotifyCtrl:FloatMsg(string.format("请先加入公会"))
	else
		g_OpenUICtrl:OpenOrgWarPage()
		b1 = true
	end
	return b1, b2, b3
end

function CItemCtrl.ItemUseSwitchTo_Find_marry(self, findWay)
	local b1 = g_OpenUICtrl:WalkToMarryNpc()

	return b1
end

----------------------------------界面跳转函数相关结束------------------------------------

--重置道具的组合数量(sid组合数 和 状态组合数) 
function CItemCtrl.RefreshBagItemsGroupAmount(self, items)
	local t = {}
	for i = 1, #items do
		local item = items[i]
		local sid = item:GetValue("sid")
		local groupAmount = 0
		local stateGroupAmount = 0
		if t[sid] == nil then			
			t[sid] = t[sid] or {}
			t[sid].group_amount = self:GetTargetItemCountBySid(sid)			
		end
		local state = item:GetValue("state")
		if t[sid][state] == nil then
			t[sid][state] = self:GetTargetItemCountBySid(sid, state)	
		end
		groupAmount = t[sid].group_amount
		stateGroupAmount = t[sid][state]
		item:SetGroupAmount(groupAmount)
		item:SetStateGroupAmount(stateGroupAmount)		
	end
end

function CItemCtrl.CanFastStrength(self)
	local b = true
	local unneedCount = 0
	local maxLevelCount = 0
	for i = define.Equip.Pos.Weapon, define.Equip.Pos.Shoes do
		local equipData = g_ItemCtrl:GetEquipedByPos(i)
		local level = equipData and equipData:GetStrengthLevel() or 0	
		local strengthData = g_ItemCtrl:GetEquipStrengthDataByPosAndLevel(i, level) or {}
		local tSidList = strengthData.sid_list or {}
		if level < CForgeStrengthPage.StrengthMaxLevel and level < g_AttrCtrl.grade then
			for i = 1, 3 do
				if i <= #tSidList then					
					local needCount = tonumber(tSidList[i].amount) 
					local sid = tSidList[i].sid				
					local oItem = CItem.NewBySid(sid)
					local ownCount = g_ItemCtrl:GetTargetItemCountBySid(sid)
					if needCount > ownCount then
						unneedCount = unneedCount + 1	
						break
					end					
				end
			end	
		else
			maxLevelCount = maxLevelCount + 1
		end
	end
	if maxLevelCount == define.Equip.Pos.Shoes then
		g_NotifyCtrl:FloatMsg("所有装备已经突破到最高等级")
		b = false
	elseif unneedCount + maxLevelCount == define.Equip.Pos.Shoes then
		g_NotifyCtrl:FloatMsg("材料不足")
		b = false
	end	
	return b
end

function CItemCtrl.CanFastAddGemExp(self)
	local b = true
	local gemList = self:GetGemByEquipPos()
	if #gemList == 0 then
		g_NotifyCtrl:FloatMsg("没有宝石可以融合")	
		return false
	end
	local AllMaxLevelCount = 0
	local AllHaveTargetPosGem = 0
	local gemSlotCount = self:GetGemSlotCountByLevel(g_AttrCtrl.grade)
	for i = define.Equip.Pos.Weapon, define.Equip.Pos.Shoes do
		local maxLevelCount = 0
		local haveTargetPosGem = false
		local equipData = g_ItemCtrl:GetEquipedByPos(i) 
		if equipData then
			local tAllGemLevel = {}
			local isAllGemMaxLevel = true
			for i = 1, 6 do				
				--只计算已经开启的宝石槽
				if gemSlotCount >= i then
					local gemData = equipData:GetEquipPerGemDataByPos(i)
					if gemData then
						--如果该宝石已经镶嵌则缓存等级
						local data = data.itemdata.GEM[gemData.sid]
						tAllGemLevel[i] = data.level 
					else
						--如果该宝石已经镶嵌则缓存0级
						tAllGemLevel[i] = 0
					end
				end 				
			end
			--判断该装备所有的宝石是否满级，如果有其中一个没满级，则可以升级
			for _,v in pairs(tAllGemLevel) do
				if v < CForgeGemPage.GemMaxLevel then
					isAllGemMaxLevel = false
					break
				end
			end		
			--如果该装备宝石都满级，则满级计数 + 1
			if isAllGemMaxLevel == true then
				maxLevelCount = maxLevelCount + 1
			else
				--如果没满级，获取该装备有没有相应的宝石可以升级
				local targetPosGem = self:GetGemByEquipPos(i)
				if #targetPosGem ~= 0 then
					haveTargetPosGem = true
				end
			end
		end
		if maxLevelCount == gemSlotCount then
			AllMaxLevelCount = AllMaxLevelCount + 1
		elseif haveTargetPosGem == false then
			AllHaveTargetPosGem = AllHaveTargetPosGem + 1
		end			
	end

	if AllMaxLevelCount == define.Equip.Pos.Shoes then
		g_NotifyCtrl:FloatMsg("所有装备的所有宝石已经满级")	
		b = false
	elseif AllHaveTargetPosGem + AllMaxLevelCount == define.Equip.Pos.Shoes then
		g_NotifyCtrl:FloatMsg("没有相应的宝石可以融合")	
		b = false
	end	
	return b
end

--打造画面，是否显示红点
--pos 装备位置
--装备界面操作类型  Strength = 1,Gem = 2,Fuwen = 3,		
function CItemCtrl.ShowForgeRedDotByPos(self, pos, type)
	local b = false

	--是否能强化
	if b == false and type == CForgeMainView.TabIndex.Strength and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.forge_strength.open_grade then
		local unHaveMaterial = false
		local isMaxLevel = false
		local equipData = self:GetEquipedByPos(pos)
		local level = equipData and equipData:GetStrengthLevel() or 0	
		local strengthData = self:GetEquipStrengthDataByPosAndLevel(pos, level) or {}
		local tSidList = strengthData.sid_list or {}
		if level < CForgeStrengthPage.StrengthMaxLevel and level < g_AttrCtrl.grade then
			for i = 1, 3 do
				if i <= #tSidList then					
					local needCount = tonumber(tSidList[i].amount) 
					local sid = tSidList[i].sid				
					local oItem = CItem.NewBySid(sid)
					local ownCount = self:GetTargetItemCountBySid(sid)
					if needCount > ownCount then
						unHaveMaterial = true	
						break
					end					
				end
			end	
		else
			isMaxLevel = true
		end
		if isMaxLevel then			
			b = false
		elseif unHaveMaterial then			
			b = false
		else
			b = true
		end
	end

	--符文重置暂时不判断
	--是否能够重置符文
	-- if b == false and type == CForgeMainView.TabIndex.Fuwen and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.forge_fuwen.open_grade then
	-- 	local fuwenSid = tonumber(data.globaldata.GLOBAL.attr_fuwen_itemid.value)
	-- 	local ownCount = self:GetTargetItemCountBySid(fuwenSid)
	-- 	local tEuqipData = g_ItemCtrl:GetEquipedByPos(pos)
	-- 	local tFuwenData = g_ItemCtrl:GetEquipFuwenDataByPosAndLevel(tEuqipData:GetValue("pos"), tEuqipData:GetValue("equip_level"))
	-- 	local needCount = tFuwenData.count	
	-- 	if ownCount < needCount then
	-- 		b = false
	-- 	else
	-- 		b = true
	-- 	end
	-- end

	--是否能够升级宝石
	if b == false and type == CForgeMainView.TabIndex.Gem and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.forge_gem.open_grade then
		local gemList = self:GetGemCountByTypeAndLevel(pos)
		--该部位是否有宝石
		if next(gemList) then			
			local gemSlotCount = self:GetGemSlotCountByLevel(g_AttrCtrl.grade)
			local equipData = self:GetEquipedByPos(pos) 
			if equipData then
				local maxLevel = self:GetGemMaxLevelByType(pos)			
				for i = 1, 6 do				
					--只计算已经开启的宝石槽
					if gemSlotCount >= i then
						local gemData = equipData:GetEquipPerGemDataByPos(i)
						if gemData then
							local data = data.itemdata.GEM[gemData.sid]
							--如果该高数等级，比背包中最高级宝石低级
							if data.level < maxLevel then
								b = true
								return b
							--如果该槽有宝石，并且不是10级，则看看背包是否有2个以上
							elseif data.level < 10 and gemList[data.level] and gemList[data.level] >= 2 then
								b = true
								return b
							end		
						else
							--如果该曹没有宝石，则为0级
							b = true
							return b
						end
					end 				
				end
			end
		end			
	end
	return b
end

--打造画面，是否显示红点
--type 强化类型（0 所有类型 1 突破， 2 宝石,  3 萃灵，）
function CItemCtrl.ShowForgeRedDotByType(self, type)
	local b = false
	if type == 1 then
		b = self:ShowForgeRedDotByStrength()
	elseif type == 2 then
		b = self:ShowForgeRedDotByGem()
	elseif type == 3 then
		--b = self:ShowForgeRedDotByFuwen()		
	elseif type == nil or type == 0 then
		b = self:ShowForgeRedDotByStrength()
		-- if b == false then
		-- 	b = self:ShowForgeRedDotByFuwen()
		-- end		
		if b == false then
			b = self:ShowForgeRedDotByGem()
		end
	end
	return b
end

--打造画面，打造是否显示红点（突破）
function CItemCtrl.ShowForgeRedDotByStrength(self)
	local b = false
	if g_AttrCtrl.grade < data.globalcontroldata.GLOBAL_CONTROL.forge_strength.open_grade then
		return b
	end

	for pos = define.Equip.Pos.Weapon, define.Equip.Pos.Shoes do
		local unHaveMaterial = false
		local isMaxLevel = false
		local equipData = self:GetEquipedByPos(pos)
		local level = equipData and equipData:GetStrengthLevel() or 0	
		local strengthData = self:GetEquipStrengthDataByPosAndLevel(pos, level) or {}
		local tSidList = strengthData.sid_list or {}
		if level < CForgeStrengthPage.StrengthMaxLevel and level < g_AttrCtrl.grade then
			for i = 1, 3 do
				if i <= #tSidList then					
					local needCount = tonumber(tSidList[i].amount) 
					local sid = tSidList[i].sid				
					local oItem = CItem.NewBySid(sid)
					local ownCount = self:GetTargetItemCountBySid(sid)
					if needCount > ownCount then
						unHaveMaterial = true	
						break
					end					
				end
			end	
		else
			isMaxLevel = true
		end

		if isMaxLevel then			
			b = false
		elseif unHaveMaterial then			
			b = false
		else
			b = true
			return b
		end	
	end

	return b
end

--打造画面，打造是否显示红点(萃灵)
function CItemCtrl.ShowForgeRedDotByFuwen(self)
	local b = false
	if g_AttrCtrl.grade < data.globalcontroldata.GLOBAL_CONTROL.forge_fuwen.open_grade then
		return b
	end
	for pos = define.Equip.Pos.Weapon, define.Equip.Pos.Shoes do
		local fuwenSid = tonumber(data.globaldata.GLOBAL.attr_fuwen_itemid.value)		
		local ownCount = self:GetTargetItemCountBySid(fuwenSid)
		local tEuqipData = g_ItemCtrl:GetEquipedByPos(pos)
		if not tEuqipData then
			return false
		end
		local tFuwenData = g_ItemCtrl:GetEquipFuwenDataByPosAndLevel(tEuqipData:GetValue("pos"), tEuqipData:GetValue("equip_level"))
		local needCount = tFuwenData.count	
		if ownCount >= needCount then
			b = true
			return b
		else
			b = false			
		end
	end
	return b
end

--打造画面，打造是否显示红点（宝石）
function CItemCtrl.ShowForgeRedDotByGem(self)
	local b = false
	if g_AttrCtrl.grade < data.globalcontroldata.GLOBAL_CONTROL.forge_gem.open_grade then
		return b
	end

	for pos = define.Equip.Pos.Weapon, define.Equip.Pos.Shoes do
		local gemList = self:GetGemCountByTypeAndLevel(pos)
		--该部位是否有宝石
		if next(gemList) then			
			local gemSlotCount = self:GetGemSlotCountByLevel(g_AttrCtrl.grade)
			local equipData = self:GetEquipedByPos(pos) 
			if equipData then
				local maxLevel = self:GetGemMaxLevelByType(pos)			
				for i = 1, 6 do				
					--只计算已经开启的宝石槽
					if gemSlotCount >= i then
						local gemData = equipData:GetEquipPerGemDataByPos(i)
						if gemData then							
							local data = data.itemdata.GEM[gemData.sid]
							--如果该高数等级，比背包中最高级宝石低级
							if data.level < maxLevel then
								b = true
								return b
							--如果该槽有宝石，并且不是10级，则看看背包是否有2个以上
							elseif data.level < 10 and gemList[data.level] and gemList[data.level] >= 2 then
								b = true
								return b
							end
						else
							--如果该曹没有宝石，则为0级
							b = true
							return b
						end
					end 				
				end
			end
		end			
	end
	return b
end

--装备合成是否有红点
function CItemCtrl.ShowForgeRedDotByComposite(self)
	local b = false
	local pos = 0
	if g_AttrCtrl.grade < data.globalcontroldata.GLOBAL_CONTROL.forge_composite.open_grade then
		return false
	end
	local levelPool = self:GetCompositeLevelPool()
	local tipsLevel = 0
	for i, v in ipairs(levelPool) do
		if g_AttrCtrl.grade >= v and g_AttrCtrl.grade - v < 10 then
			tipsLevel = v
		end
	end
	if tipsLevel ~= 0 then
		b, pos = self:CanCompositeEquipByLevel(tipsLevel)
	end
	return b, pos
end

function CItemCtrl.InitBagSortType(self)
	if self.m_IsInitBagSortType == false then
		self.m_IsInitBagSortType = true
		self.m_RecordItembBagSortTypeCache[1] = IOTools.GetClientData(string.format("bag_sort_type_%d_%d",g_AttrCtrl.pid, 1)) or 1
		self.m_RecordItembBagSortTypeCache[2] = IOTools.GetClientData(string.format("bag_sort_type_%d_%d",g_AttrCtrl.pid, 2)) or 1
		self.m_RecordItembBagSortTypeCache[3] = IOTools.GetClientData(string.format("bag_sort_type_%d_%d",g_AttrCtrl.pid, 3)) or 1
		self.m_RecordItembBagSortTypeCache[4] = IOTools.GetClientData(string.format("bag_sort_type_%d_%d",g_AttrCtrl.pid, 4)) or 1		
		self.m_RecordItembBagSortTypeCache[4] = IOTools.GetClientData(string.format("bag_sort_type_%d_%d",g_AttrCtrl.pid, 5)) or 1		
	end
end

function CItemCtrl.SaveBagSortType(self, tab)
	IOTools.SetClientData(string.format("bag_sort_type_%d_%d",g_AttrCtrl.pid, tab), self.m_RecordItembBagSortTypeCache[tab])
end

--计时通用处理
-- timer 计时器
-- timeeOffset 时间间隔
-- notify 不满足条件时的提示
-- force 忽略时间间隔强制执行
function CItemCtrl.CanDoProcess(self, timer, timeeOffset, notify, force)
	local b = false
	if timer ~= 0 and force ~= true then
		local now = g_TimeCtrl:GetTimeS()
		local offset = now - timer
		if offset >= timeeOffset then
			b = true
			timer = now
		else
			if notify ~= "" then
				g_NotifyCtrl:FloatMsg( string.format(notify, timeeOffset - offset))
			end			
		end	
	else
		b = true
		timer = g_TimeCtrl:GetTimeS()
	end 
	return b, timer
end

function CItemCtrl.CanArrangeItem( self, force, hastips)
	local b = false
	local timer = 0
	if hastips then
		b, timer = self:CanDoProcess(self.m_ArrangeItemTimer, CItemCtrl.ARRANGE_ITEM_TIME, "整理过于频繁，请%d秒后整理", force)
	else
		b, timer = self:CanDoProcess(self.m_ArrangeItemTimer, CItemCtrl.ARRANGE_ITEM_TIME, "", force)
	end
	self.m_ArrangeItemTimer = timer
	return b 	
end

--百分百属性转换
--key 属性
--attr 属性值
--isDown 非百分比属性（属性向下取整）
function CItemCtrl.AttrStringConvert(self, key, attr, isDown)
	if key and attr and (string.find(key, "ratio") or key == "critical_damage" ) then
		attr = tonumber(attr)
		attr = math.floor(attr / 10)
		attr = attr / 10
		attr = ""..attr.."%"
	elseif attr then
		if isDown == true then
			attr = tonumber(attr)
			attr = math.floor(attr)
		end
		attr = tostring(attr)
	end
	return attr
end

--获取字符串奖励分割
-- 1010(value=3000) 返回 1010 3000
function CItemCtrl.SplitSidAndValue(self, str)
	local sid = tonumber(string.split(str, "(")[1]) 
	local value = 0
	for out in string.gmatch(str, "=(%w+)") do
		value = tonumber(out)
	end
	return sid, value
end

--获取字符串伙伴奖励分割
--1010(partner=405, star=3) 返回 1010 405 3, 
function CItemCtrl.SplitSidToPartner(self, str)
	local sid = tonumber(string.split(str, "(")[1]) 
	local partner, star
	for out in string.gmatch(str, "=(%w+)") do
		if not partner then
			partner = tonumber(out)
		else
			star = tonumber(out)
		end
	end
	return sid, partner, star
end	

--获取字符串宅邸伙伴奖励分割
--1025(house_partner=1003) 返回 1025 1003
function CItemCtrl.SplitSidToHousePartner(self, str)
	local sid = tonumber(string.split(str, "(")[1]) 
	local house_partner = 0
	for out in string.gmatch(str, "=(%w+)") do
		house_partner = tonumber(out)
	end
	return sid, house_partner
end

--获取字符串主角皮肤奖励分割
--1027(shape=113) 返回 1027 113
function CItemCtrl.SplitSidToRoleSkin(self, str)
	local sid = tonumber(string.split(str, "(")[1]) 
	local roleSkin = 0
	for out in string.gmatch(str, "=(%w+)") do
		roleSkin = tonumber(out)
	end
	return sid, roleSkin
end

--道具获取时，红点提示
function CItemCtrl.AddItemGetTips(self, id)
	if not CItemBagMainView:GetView() then 
		local oItem = self:GetBagItemById(id)
		if oItem then
			if oItem:GetValue("red_dot") == 0 or oItem:GetValue("red_dot") == nil then
				local type = oItem:GetValue("bag_show_type")	
				if type and type ~= 0 then
					self.m_RedDotIdTable[type] = self.m_RedDotIdTable[type] or {}
					self.m_RedDotIdTable[type][id] = true
					self:OnEvent(define.Item.Event.RefreshItemGetRedDot)
				end							
			end						
		end		
	end
end

--道具消耗，红点更新提示
function CItemCtrl.RefeshItemGetTipsById(self, id)
	local oItem = self:GetBagItemById(id)
	if not oItem or ( oItem and oItem:GetValue("amount") <= 0 )then
		if next(self.m_RedDotIdTable) then
			for type, list in pairs(self.m_RedDotIdTable) do
				if next(list) then
					for key, _ in pairs(list) do
						if key == id then
							list[key] = nil							
							self:OnEvent(define.Item.Event.RefreshItemGetRedDot)
							return
						end
					end
				end
			end
		end		
	end
end

--背包页签，红点更新提示
function CItemCtrl.RefeshItemGetTipsByType(self, type)
	if self.m_RedDotIdTable[type] then
		self.m_RedDotIdTable[type] = nil	
		self:OnEvent(define.Item.Event.RefreshItemGetRedDot)
	end	
end

--获取有红点的道具标签，没有返回第一个标签（普通）
function CItemCtrl.GetRedDotTab(self)
	local tab = 1
	for i = 1, 5 do
		if self.m_RedDotIdTable[i] and next(self.m_RedDotIdTable[i]) then
			tab = i
			break
		end
	end
	return tab
end


--道具获取途径跳转
function CItemCtrl.ItemFindWayToSwitch(self, findId, oItem)
	--获取途经等级检测
	local function CheckLevel(level)
		printc(" g_AttrCtrl.grade ", g_AttrCtrl.grade, level)
		return (g_AttrCtrl.grade < level)
	end

	local d = data.itemdata.MODULE_SRC[findId]
	local bClose = false
	local bTips = false
	local time = ""
	local time2 = ""

	if d then
		if d.go_inwar == 1 and g_WarCtrl:IsWar() then
			g_NotifyCtrl:FloatMsg("战斗中无法进行该操作")
			return
		end
		--切换页面
		if d.type == 1 then
			if d.config ~= "" then
				bClose, bTips, time, time2= self:ItemUseSwitchTo(oItem, d.config, true)
				if bClose == false and bTips == true then
					if time and time ~= "" and d.name and d.name ~= "" then
						if time2 and time2 ~= "" then
							g_NotifyCtrl:FloatMsg(string.format("【%s】将在【%s】到【%s】开启", d.name, time, time2))
						else
							g_NotifyCtrl:FloatMsg(string.format("【%s】将在【%s】开启", d.name, time))
						end						
					end					
				end
			end		

		--寻找静态NPC
		elseif d.type == 2 then
			if d.config ~= "" and d.arg ~= "" then
				if d.config == "daily_cultivate" then
					bTips = CheckLevel(data.globalcontroldata.GLOBAL_CONTROL.lilian.open_grade)
				elseif d.config == "yjfuben" then
					bTips = CheckLevel(data.globalcontroldata.GLOBAL_CONTROL.yjfuben.open_grade)
				elseif d.config == "convoy" then
					bTips = CheckLevel(data.globalcontroldata.GLOBAL_CONTROL.convoy.open_grade)
				elseif d.config == "newshimen" then
					bTips = CheckLevel(data.globalcontroldata.GLOBAL_CONTROL.shimen.open_grade)
				end
				if bTips then
					if d.tips ~= "" then
						g_NotifyCtrl:FloatMsg(d.tips)
					end		
				else
					local taskData = 
					{
						acceptnpc = tonumber(d.arg),
					}
					local oTask = CTask.NewByData(taskData)
					bClose = g_TaskCtrl:ClickTaskLogic(oTask)			
				end
				
			end
		--点击提示飘字
		elseif d.type == 3 then
			if d.tips ~= "" then
				g_NotifyCtrl:FloatMsg(d.tips)
			end	

		--寻找动态NPC
		elseif d.type == 4 then

		end

	end

	return bClose
end

function CItemCtrl.ClientShowReward(self,  type, sid, value, bind)
	local rewardItem = {
		sid = sid,
		count = value,
		bind = bind,
		type = type,
	}

	--即时触发
	g_WindowTipCtrl:SetWindowItemRewardList({rewardItem})

end

--获取符文波动最大和最小值
function CItemCtrl.GetFuwenWaveRange(self)
	local min = 100
	local max = 100
	local d = data.itemdata.FUWEN_WAVE
	for k, v in pairs(d) do
		if v.min_ratio < min then
			min = v.min_ratio
		end

		if v.max_ratio > max then
			max = v.max_ratio
		end
	end
	return min, max
end

--获装备波动最大和最小值
function CItemCtrl.GetEquipWaveRange(self)
	local min = 100
	local max = 100
	local d = data.itemdata.EQUIP_WAVE
	for k, v in pairs(d) do
		if v.min_ratio < min then
			min = v.min_ratio
		end

		if v.max_ratio > max then
			max = v.max_ratio
		end
	end
	return min, max
end

function CItemCtrl.ShowEquipChangeAttrTips(self, pos, new)
	local old = self:GetEquipedByPos(pos)
	if not old or not new then
		return
	end

	local function inserKey(t, key)
		for k, v in pairs(t) do
			if v == key then
				return 
			end
		end
		table.insert(t, key)
	end

	local function sortKey(tData)
		local t = {}
		for _k, _v in pairs(define.Attr.AttrKey) do 
			for k,v in pairs(tData) do
				if _v == v then
					table.insert(t,v)
					break
				end				
			end
		end
		return t
	end	

	local tKey = {} 	
 	local tAttr = {}

	local tOld = old:GetEquipAttrBase() or {}
	for _,v in pairs (tOld) do
		if define.Attr.String[v.key] ~= nil and v.value ~= 0 then
			--缓存已装备属性值	
			tAttr[v.key] = tAttr[v.key] or {}
			tAttr[v.key].from = v.value
			inserKey(tKey, v.key)
		end
	end

	local tNew = new:GetEquipAttrBase() or {}
	for _,v in pairs (tNew) do
		if define.Attr.String[v.key] ~= nil and v.value ~= 0 then
			--缓存已装备属性值	
			tAttr[v.key] = tAttr[v.key] or {}
			tAttr[v.key].to = v.value
			inserKey(tKey, v.key)
		end
	end	
	if #tKey > 0 then
		tKey = sortKey(tKey)	
		self:ShowAttrChangeTipsFution(tKey, tAttr)		
	end
end

function CItemCtrl.ShowAttrChangeAttrTips(self, oAttr, nAttr)
	if not next(oAttr) or not next(nAttr) then
		return
	end

	local function changeKey(t)
		local d = {}
		for _k, _v in pairs(t) do 
			if _k == "max_hp" then
				d["maxhp"] = _v
			else
				d[_k] = _v
			end
		end
		return d
	end
	oAttr = changeKey(oAttr)
	nAttr = changeKey(nAttr)
	local function inserKey(t, key)
		for k, v in pairs(t) do
			if v == key then
				return 
			end
		end
		table.insert(t, key)
	end

	local function sortKey(tData)
		local t = {}
		for _k, _v in pairs(define.Attr.AttrKey) do 
			for k,v in pairs(tData) do
				if _v == v then
					table.insert(t,v)
					break
				end				
			end
		end
		return t
	end	

	local function mergeKey(t1, t2)
		local t = {}
		for k,v in pairs(t1) do
			inserKey(t, v)
		end
		for k,v in pairs(t2) do
			inserKey(t, v)
		end
		return t
	end

	local function mergeAttr(t1, t2)
		local t = {}
		for k,v in pairs(t1) do
			t[k] = t[k] or {}
			if t2[k] then
				if t2[k].from < v.from then
					t[k].from = t2[k].from
				else	
					t[k].from = v.from					
				end
				if t2[k].to > v.to then
					t[k].to = t2[k].to
				else
					t[k].to = v.to
				end
			else
				t[k] = v
			end
		end
		for k,v in pairs(t2) do
			if t1[k] then
				if t1[k].from < v.from then
					t[k].from = t1[k].from
				else	
					t[k].from = v.from					
				end
				if t1[k].to > v.to then
					t[k].to = t1[k].to
				else
					t[k].to = v.to
				end
			else
				t[k] = v
			end
		end
		return t
	end

	local tKey = {} 	
 	local tAttr = {}
	for k, v in pairs (oAttr) do
		if define.Attr.String[k] ~= nil and v ~= 0 then
			tAttr[k] = tAttr[k] or {}
			tAttr[k].from = v
			inserKey(tKey, k)
		end
	end
	for k, v in pairs (nAttr) do
		if define.Attr.String[k] ~= nil and v ~= 0 then	
			tAttr[k] = tAttr[k] or {}
			tAttr[k].to = v
			inserKey(tKey, k)
		end
	end	
	if #tKey > 0 then
		if self.m_ShowAttrTimer ~= nil then
			Utils.DelTimer(self.m_ShowAttrTimer)
			self.m_ShowAttrTimer = nil
		end
		self.m_ShowAttrCacheKey = mergeKey(self.m_ShowAttrCacheKey, tKey)
		self.m_ShowAttrCacheAttr = mergeAttr(self.m_ShowAttrCacheAttr, tAttr)	
		self.m_ShowAttrCacheKey = sortKey(self.m_ShowAttrCacheKey)		
		local cb = function()			
			self:ShowAttrChangeTipsFution(self.m_ShowAttrCacheKey, self.m_ShowAttrCacheAttr)		
			self.m_ShowAttrTimer = nil
			self.m_ShowAttrCacheAttr = {}
			self.m_ShowAttrCacheKey = {}	
		end
		self.m_ShowAttrTimer = Utils.AddTimer(cb, 0, 0.3)
	end
end

--tKey 参数格式
--tKey = {[1] = "attack",[2] = "critical_ratio"}
--tAttr 参数格式
-- tAttr = {
-- attack = { from = 544, to = 376}
-- critical_ratio = { from = 180,to = 120}
-- }
function CItemCtrl.ShowAttrChangeTipsFution(self, tKey, tAttr)
	local function CheckRatioAttr(key, offset)
		if key and offset and (string.find(key, "ratio") or key == "critical_damage" )  then
			if math.abs(offset) < 10 then
				return false
			end
		end
		return true
	end	
	for i = 1, #tKey do
		local key = define.Attr.String[tKey[i]]
		if key and tAttr[tKey[i]].from then
			local from = tAttr[tKey[i]].from or 0
			local to = tAttr[tKey[i]].to or 0			
			if from ~= to and CheckRatioAttr(tKey[i], from - to) then
				if tKey[i] == "power" then
					g_NotifyCtrl:ShowPowerChange(from, to)
				else
					if from > to then						
						local converKey = tKey[i] 
						local converFrom = from
						local converTo = to
						--属性变化速度
						local AttrChangeSpeed = math.floor((converFrom - converTo))

						local sFrom = g_ItemCtrl:AttrStringConvert(tKey[i], converFrom)	
						local sOffset = g_ItemCtrl:AttrStringConvert(tKey[i], from - to )
						local oBox = g_NotifyCtrl:FloatMsgAttrChange(string.format("%s: %s #R 下降 %s", key, sFrom, sOffset), {hideTime = 2})						
						local function wrap(dt)
							if not Utils.IsNil(oBox) then
								converFrom = math.floor(converFrom - dt * AttrChangeSpeed)
								if converFrom < converTo then
									converFrom = converTo									
								end
								local str =  g_ItemCtrl:AttrStringConvert(tKey[i], converFrom)
								local temp
								if converKey == "power" then
									temp = string.format("#Y%s: %s #R 下降 %s", key, str, sOffset)
								else
									temp = string.format("%s: %s #R 下降 %s", key, str, sOffset)
								end
								 
								temp = string.getstringdark(temp)	
								oBox:SetText(temp)														
								if converFrom == converTo then
									return false
								end
							else
								return false
							end
							return true
						end
						Utils.AddTimer(wrap, 0, 0)						
					else
						local converKey = tKey[i] 
						local converFrom = from
						local converTo = to

						--属性变化速度
						local AttrChangeSpeed = math.floor((converTo - converFrom))

						local sFrom = g_ItemCtrl:AttrStringConvert(tKey[i], converFrom)	
						local sOffset = g_ItemCtrl:AttrStringConvert(tKey[i], to - from)
						local oBox = g_NotifyCtrl:FloatMsgAttrChange(string.format("%s: %s #G 上升 %s", key, sFrom, sOffset), {hideTime = 2})						
						local function wrap(dt)
							if not Utils.IsNil(oBox) then
								converFrom = math.floor(converFrom + dt * AttrChangeSpeed)
								if converFrom > converTo then
									converFrom = converTo									
								end
								local str =  g_ItemCtrl:AttrStringConvert(tKey[i], converFrom)

								local temp
								if converKey == "power" then
									temp = string.format("#Y%s: %s #G 上升 %s", key, str, sOffset)
								else
									temp = string.format("%s: %s #G 上升 %s", key, str, sOffset)
								end							
								local 
								temp = string.getstringdark(temp)	
								oBox:SetText(temp)													
								if converFrom == converTo then
									return false
								end
							else
								return false
							end
							return true
						end
						Utils.AddTimer(wrap, 0, 0)							
					end
				end				
			end
		end
	end
end

function CItemCtrl.GetItemSubTypeBySid(self, sid)
	local iType = define.Item.ItemSubType.Virtual
	local t = define.Item.ItemSubTypeRange

	for k,v in pairs(t) do
		if sid >= v[1] and sid <= v[2] then
			iType = k
			break
		end
	end
	return iType
end

function CItemCtrl.CheckOpenCondition(self, sid)
	sid = tostring(sid)	
	local b = true
	--通用屏蔽
	b = g_ActivityCtrl:ActivityBlockContrl("item", true, sid)
	
	return b
end

--获取背包的装备
--pos 装备部位
--maxLevel 最大等级
function CItemCtrl.GetEquipByPosAndMaxLevel(self, pos, maxLevel)
	local t = {}
	for _, oItem in pairs(self.m_BagItems) do
		if oItem:GetValue("sub_type") == define.Item.ItemSubType.EquipStone then 
			local itemPos = oItem:GetValue("pos")
			local level = oItem:GetValue("level")
			if pos == itemPos and level <= maxLevel then
				table.insert(t, oItem)
			end  
		end
	end
	if #t > 1 then
		local sortFunction = function (a, b)
			if a:GetEquipBaseScore() == b:GetEquipBaseScore() then
				return a:GetValue("id") < b:GetValue("id")
			else
				return a:GetEquipBaseScore() > b:GetEquipBaseScore()
			end
		end
		table.sort(t, sortFunction)
	end
	return t
end

--通关方案获取符文总属性
--isFilled 是否补齐属性
function CItemCtrl.GetEquipFuwenAttByPlan(self, plan, isFilled)
	local t = {}
	for i = define.Equip.Pos.Weapon, define.Equip.Pos.Shoes do
		local equipData = self:GetEquipedByPos(i)
		if equipData then
			local attr = equipData:GetEquipAttrFuWen(plan)
			for k = 1, #attr do
				local info = attr[k]
				t[info.key] = t[info.key] or 0
				t[info.key] = t[info.key] + tonumber(info.value)
			end
		end
	end
	if isFilled then
		for _k, _v in pairs(define.Attr.AttrKey) do 
			if not t[_v] and _v ~= "power" then
				t[_v] = 0
			end
		end
	end
	if next(t) then
		t = self:SortAttr(t, isFilled)
	end
	return t
end

--属性排序
--参数格式   {maxhp = 100, attack=10}
--返回格式   {[1] = {key = "maxhp", value = 100}, [2] = {key = "attack", value = 10}}
--isFilled 是否补齐属性
function CItemCtrl.SortAttr(self, attrs, isFilled)
	local t = {}
	for _k, _v in pairs(define.Attr.AttrKey) do 
		for k,v in pairs(attrs) do
			if define.Attr.String[k] ~= nil and _v == k then
				if isFilled or  v ~= 0 then
					local d = {key = k, value = v}
					table.insert(t, d)
				end				
			end
		end
	end
	return t
end

--获取当前的萃灵方案
function CItemCtrl.GetFuwenPlan(self)
	local t = 1
	for i = define.Equip.Pos.Weapon, define.Equip.Pos.Shoes do
		local equipData = self:GetEquipedByPos(i)
		if equipData then
			t = equipData.m_SData.equip_info.fuwen_plan
		end
	end
	return t
end

function CItemCtrl.CtrlGS2CFuWenPlanName(self, fuwenName)
	if fuwenName then
		for k, v in pairs(fuwenName) do
			self.m_ForgeFuwenName[v.plan] = v.name
		end
	end
	self:OnEvent(define.Item.Event.RefreshFuwenName)
end

function CItemCtrl.GetFuwenPlanName(self, plan)
	local str = ""
	if self.m_ForgeFuwenName[plan] then
		str = self.m_ForgeFuwenName[plan]
	end
	if str == "" then
		if plan == 1 then
			str = "默认方案"
		else
			str = "备选方案"
		end
	end
	return str
end

function CItemCtrl.GetCanResolveEquip(self, isExchange)
	local t = {}
	if isExchange then
		for i = 1, 6 do
			local oItem = self:GetEquipedByPos(i)
			local sid = oItem:GetValue("stone_sid")
			if data.forgedata.DE_COMPOSITE[sid] then
				table.insert(t, oItem)
			end			
		end
	end

	--装备标签， 按等级排序， 未解锁(和出售的条件一样)
	local temp = self:GetAllBagItemsByShowTypeAndSort(3, define.Item.SortType.Level, true)
	for i = 1, #temp do
		local oItem = temp[i]
		local sid = oItem:GetValue("sid")
		--在分解列表中，才能分解
		if data.forgedata.DE_COMPOSITE[sid] then
			table.insert(t, oItem)
		end
	end
	return t
end

--通过装备灵石的sid，获取装备灵石适用
function CItemCtrl.GetEquipFitInfoBySid(self, sid)
	local oItem = data.itemdata.EQUIPSTONE[sid]
	local str = ""
	if oItem then
		local pos = oItem.pos
		if pos == define.Equip.Pos.Weapon then
			local weaponType = oItem.weapon_type
			local branch = 1
			for k, v in ipairs(data.itemdata.SCHOOL_WEAPON) do
				if v.weapon == weaponType then
					branch = k
					break
				end
			end
			str = data.roletypedata.BRANCH_TYPE[branch].name
			
		elseif pos == define.Equip.Pos.Necklace or pos == define.Equip.Pos.Ring then
			str = "全部"
		else
			if oItem.sex == 2 then
				str = "女"
			else
				str = "男"
			end
		end
	end
	return str
end

function CItemCtrl.CtrlGS2CCompoundSuccess(self)
	self:OnEvent(define.Item.Event.ForgeCompositeSuccess)
end

function CItemCtrl.CtrlGS2CDeComposeSuccess(self)
	self:OnEvent(define.Item.Event.ForgerResolveSuccess)
end

function CItemCtrl.CtrlGS2CExchangeSuccess(self, itemid)
	itemid = itemid or 0
	if itemid then
		local oItem = g_ItemCtrl:GetBagItemById(itemid)
		if oItem then
			local list = {}
			list[1] = 
			{
				amount = 1,
				id = itemid,
				sid = oItem:GetItemStoneSid(),				
			}
			g_WindowTipCtrl:SetWindowAllItemRewardList(list)
		end
	end
	self:OnEvent(define.Item.Event.ForgeExchangeSuccess, {id = itemid})
end

--装备加/解锁
function CItemCtrl.SwitchEquipLock(self, oItem)
	if oItem then
		if oItem:GetValue("type") == define.Item.ItemType.EquipStone then
			netitem.C2GSLockEquip(oItem:GetValue("id"))
		elseif oItem:GetValue("type") == define.Item.ItemType.Equip then
			netitem.C2GSLockEquip(nil, oItem:GetValue("pos"))
		end
	end
end

--检测当时是否需要快捷使用装备
function CItemCtrl.CheckLocalQuickEquip(self, oItem)
	if oItem then
		if oItem:GetValue("type") == define.Item.ItemType.EquipStone then
			local pos = oItem:GetValue("pos")	
			if self:CheckEquipScore(oItem, nil, pos) then
				self:QuickUseItem(oItem:GetValue("id"))
			end
		end
	end
end

--比较新装备和旧装备的战力
function CItemCtrl.CheckEquipScore(self, newItem, oldItem, pos)
	if not newItem or (not oldItem and not pos ) then
		return false
	end
	local newScore = newItem:GetEquipBaseScore()
	if pos then		
		oldItem	 = self:GetEquipedByPos(pos)
	end	
	local oldScore = oldItem:GetEquipBaseScore()
	return newScore > oldScore
end

function CItemCtrl.SetShowAttrChangeFlag(self, b)
	self.m_ShowAttrChangeFlag = b
end

function CItemCtrl.GetShowAttrChangeFlag(self)
	return self.m_ShowAttrChangeFlag
end

function CItemCtrl.GetTotalFuwenLevel(self)
	local totalLevel = 0
	for i = 1, 6 do
		local oItem = g_ItemCtrl:GetEquipedByPos(i)
		if oItem then
			totalLevel = totalLevel + oItem:GetEquipFuWenLevel()
		end
	end
	return totalLevel
end

--通过导表id获取道具的套装技能和等级
function CItemCtrl.GetEuipSetTypeAndLevelBySid(self, sid)
	local setType 
	local skillLevel 
	local equipLevel 
	local oItem = CItem.NewBySid(sid)
	if oItem and oItem:GetValue("type") == define.Item.ItemType.EquipStone then
		setType = oItem:GetValue("set_type")
		skillLevel = oItem:GetValue("skill_level")
		equipLevel = oItem:GetValue("level")
	end
	return setType, skillLevel, equipLevel
end


function CItemCtrl.GetItemAttrBySid(self, sid)
	local t = {}
	local oItem =  data.itemdata.EQUIPSTONE[sid]
	if oItem then
		for k,v in pairs (oItem) do
			if define.Attr.String[k] ~= nil and type(v) == "number" and v ~= 0 then
				t[k] = v
			end
		end	
		t = self:SortAttr(t)
	end
	return t
end

--根据部位和材料列表，判断身上或者背包有没有此可以升级的装备
function CItemCtrl.GetCompositeUpgradeBySid(self, pos, sidList)
	--身上的装备
	local t = {}
	local oItem = self:GetEquipedByPos(pos)
	for i, v in ipairs(sidList) do
		if oItem and oItem.m_SData.equip_info.stone_sid == v then
			table.insert(t, oItem)
		end
	end
	--背包的装备
	for i, v in ipairs(sidList) do
		for _, _v in pairs(self.m_BagItems) do		
			if v  == _v:GetValue("sid") then
				table.insert(t, _v)				
			end
		end
	end
	return t
end

--根据类型获取合成宝石列表
function CItemCtrl.GetGemListCompositeByType(self, iType)
	local t = {}
	local list = self:GetAllItemsByTypeAndSort(define.Item.ItemType.Gem, define.Item.SortType.Sid) 
	if iType ~= 0 then
		if next(list) then
			for i, v in ipairs(list) do
				if v:GetValue("pos") == iType then
					table.insert(t, v)
				end
			end
		end
	else
		t = list
	end
	return t
end

--根据某一类宝石，获取背包中最高的等级
function CItemCtrl.GetGemMaxLevelByType(self, iType)
	local level = 0
	local list = self:GetAllItemsByTypeAndSort(define.Item.ItemType.Gem, define.Item.SortType.Sid) 
	local t = {}
	if next(list) then
		for i, v in ipairs(list) do
			if v:GetValue("pos") == iType then
				if v:GetValue("level") > level then
					level = v:GetValue("level")
				end
			end
		end
	end
	return level
end

--获取某一类宝石，等级为key,宝石数量数组
function CItemCtrl.GetGemCountByTypeAndLevel(self, iType)
	local list = self:GetAllItemsByTypeAndSort(define.Item.ItemType.Gem, define.Item.SortType.Sid) 
	local t = {}
	if next(list) then
		for i, v in ipairs(list) do
			if v:GetValue("pos") == iType then
				local level = v:GetValue("level")
				t[level] = t[level] or 0
				t[level] = t[level] + v:GetValue("amount")
			end
		end
	end
	return t
end

function CItemCtrl.IsTargetGemSoltHaveRodDot(self, iType, slot)
	local b = false
	local gemList = self:GetGemCountByTypeAndLevel(iType)
	--该部位是否有宝石
	if next(gemList) then			
		local gemSlotCount = self:GetGemSlotCountByLevel(g_AttrCtrl.grade)
		local equipData = self:GetEquipedByPos(iType) 
		if equipData then
			local maxLevel = self:GetGemMaxLevelByType(iType)			
			if gemSlotCount >= slot then
				local gemData = equipData:GetEquipPerGemDataByPos(slot)
				if gemData then
					local data = data.itemdata.GEM[gemData.sid]
					--如果该高数等级，比背包中最高级宝石低级
					if data.level < maxLevel then
						b = true
						return b
					--如果该槽有宝石，并且不是10级，则看看背包是否有2个以上
					elseif data.level < 10 and gemList[data.level] and gemList[data.level] >= 2 then
						b = true
						return b
					end					
				else
					--如果该曹没有宝石，则为0级
					b = true
					return b
				end
			end 				
		end
	end	
	return b
end

function CItemCtrl.GetFuwenCanResetQualityPoolString(self, pos, level)
	local str = ""
	pos = pos or 1
	level = level / 10 + 1 
	local t = data.itemdata.FUWEN[pos][level].quality
	for i, v in ipairs(t) do
		if v ~= 0 then
			str = string.format("%s %s%s", str, self:GetFuwenQualityColor(i), self:GetFuwenQualityName(i))
		end		
	end
	return str
end

function CItemCtrl.GetFuwenCanResetQuality(self, pos, level)
	local maxQuality = 1
	local minQuality = 1
	pos = pos or 1
	level = level / 10 + 1 
	local t = data.itemdata.FUWEN[pos][level].quality
	for i = #t, 1, -1 do
		if t[i] ~= 0 then
			maxQuality = i
			break
		end
	end
	return minQuality, maxQuality
end

function CItemCtrl.GetFuwenQualityColor(self, quality)
	local pool = 
	{
		[1] = {color = "[ffffff]",},
		[2] = {color = "[34c8f4]",},
		[3] = {color = "[e110fa]",},
		[4] = {color = "[fab310]",},
		[5] = {color = "[ff0000]",},
	}
	if quality < 1 then
		quality = 1
	end
	if quality > 5 then
		quality = 5
	end
	return pool[quality].color
end

function CItemCtrl.GetFuwenQualityName(self, quality)
	local pool = 
	{
		[1] = {name = "[普通]"},
		[2] = {name = "[优良]"},
		[3] = {name = "[精致]"},
		[4] = {name = "[稀有]"},
		[5] = {name = "[极品]"},
	}
	if quality < 1 then
		quality = 1
	end
	if quality > 5 then
		quality = 5
	end
	return pool[quality].name
end

function CItemCtrl.CtrlGS2CGemCompose(self, gemSid, amount)	
	self:OnEvent(define.Item.Event.ForgeGemComposite, {sid = gemSid, amount = amount})
end

function CItemCtrl.GetCompositeLevelPool(self)
	local t = {}
	for i,v in ipairs(data.forgedata.COMPOSITE_EQUIP[1]) do
		if g_AttrCtrl.grade >= v.grade then
			table.insert(t, v.grade)
		end
	end
	return t
end

function CItemCtrl.GetCompositeDataByPosAndLevel(self, pos, level)
	local d 
	local t = data.forgedata.COMPOSITE_EQUIP[pos]
	for i, v in ipairs(t) do
	 	if level == v.grade then
	 		d = v
	 		break
	 	end
	 end 
	return d
end

function CItemCtrl.GetFitCompositeSidFromSidList(self, sidList)
	local sid
	for i, v in ipairs(sidList) do
		local oItem = CItem.NewBySid(v.sid)
		if oItem and oItem:IsFit() then
			sid = v.sid 
			break
		end
	end
	return sid
end

function CItemCtrl.CanCompositeEquipByLevel(self, level)
	local canPos = 0
	local b = false
	if g_AttrCtrl.grade < data.globalcontroldata.GLOBAL_CONTROL.forge_composite.open_grade then
		return false
	end
	--如果不在装备等级池，则忽略
	local levelPool = self:GetCompositeLevelPool()
	if not table.key(levelPool, level) then
		return false
	end

	--判断每个部位的装备
	for pos = define.Equip.Pos.Weapon, define.Equip.Pos.Shoes do
		local cpd = self:GetCompositeDataByPosAndLevel(pos, level)
		if cpd then
			--身上是否有可以升级的装备
			local t = self:GetCompositeUpgradeBySid(pos, cpd.upgrade_weapon)
			local upgradeItem = t[1]
			local item_list = {}
			local cost = 0
			if upgradeItem then
				item_list = cpd.upgrade_material
				cost = cpd.upgrade_coin
			else
				item_list = cpd.sid_item_list
				cost = cpd.cost								
			end
			local isNeed = false
			--判断金币
			if cost > g_AttrCtrl.coin then
				isNeed = true				
			end
			--判断材料
			if isNeed == false then
				for i,v in ipairs(item_list) do
					local myCnt = self:GetTargetItemCountBySid(v.sid)
					local amount = v.amount
					if amount > myCnt then
						isNeed = true
						break
					end					
				end
			end
			--如果金币和材料都足够，则可以合成装备
			if isNeed == false then
				canPos = pos
				return true, canPos
			end
		end
	end
	return b
end

function CItemCtrl.GetFuwenCanResetAttrPool(self, quality, level)
	local t = {}
	local d = data.itemdata.FUWEN_ATTR_WAVE
	for i, v in ipairs(d) do
		if v.level == level and v.quality == quality then
			t = v
			break
		end
	end
	return t
end

return CItemCtrl