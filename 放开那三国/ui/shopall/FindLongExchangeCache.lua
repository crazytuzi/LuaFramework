-- Filename: ExchangeCache.lua
-- Author: FQQ
-- Date: 2015-09-07
-- Purpose: 寻龙积分兑换数据处理

module("FindLongExchangeCache",package.seeall)

require "db/DB_Explore_long_shop"

local _exchangeDataTable = nil		--存储配置表中可兑换商品数据
local _exchangeInfo = nil			--存储后端拉取的已兑换商品数据


function setExchangeDataTable()
	if _exchangeDataTable ~= nil then return end

	_exchangeDataTable = {}
	local count = table.count(DB_Explore_long_shop.Explore_long_shop)

	--for i = 1,count do
	for i,v in pairs(DB_Explore_long_shop.Explore_long_shop) do
		local tempTable = DB_Explore_long_shop.getDataById(v[1])
		if tempTable.isSold then
			tempTable.itemsTable = lua_string_split(tempTable.items,'|')

			local tempTable2 = {}
			tempTable2.type = tonumber(tempTable.itemsTable[1])
			tempTable2.tid  = tonumber(tempTable.itemsTable[2])
			tempTable2.num  = tonumber(tempTable.itemsTable[3])
			tempTable.itemsTable = tempTable2

			--兑换时需要其它物品
			if tempTable.addItems ~= nil then
				tempTable.needItem = lua_string_split(tempTable.addItems, '|')
				local  tempNeedTable = {}
				tempNeedTable.tid = tonumber(tempTable.needItem[1])
				tempNeedTable.num = tonumber(tempTable.needItem[2])
				tempTable.needItem = tempNeedTable
			end

			--print("ttt:")
			if _exchangeInfo ~= nil then
				--print("_exchangeInfo 1...")
			 	if _exchangeInfo[tostring(tempTable.id)] ~= nil then
			 		--print("_exchangeInfo 2...")
			 		tempTable.remainExchangeNum = tempTable.baseNum - _exchangeInfo[tostring(tempTable.id)].num
			 	else
			 		--print("_exchangeInfo 3...")
			 		tempTable.remainExchangeNum = tempTable.baseNum
			 	end
			else
				--print("_exchangeInfo 4...")
			 	tempTable.remainExchangeNum = tempTable.baseNum
			end
			
			table.insert(_exchangeDataTable,tempTable)
		end
	end

	local function sortFunc(value1,value2)
		return tonumber(value1.sortType) < tonumber(value2.sortType) 
	end
	table.sort(_exchangeDataTable,sortFunc)
end

--过滤数据，获得剩余次数大于零的数据
function filterExchangeDataTable()
	local temp = {}
	-- 当剩余兑换次数大于0时才在table中显示出来
	for _,v in pairs(_exchangeDataTable) do
		if v.remainExchangeNum > 0 then
			table.insert(temp,v)
		end
	end
	return temp
end

function getExchangeInfo()
	return _exchangeInfo
end

function getExchangeDataTable()
	return _exchangeDataTable
end

--	判断背包是否还能容纳充值回馈奖励
function canBagReceiveFeedback(cellData)
	local isItem = false
	if tonumber(cellData.itemsTable.type) == 1 then
		isItem = true
	end
	require "script/ui/item/ItemUtil"
	if isItem and ItemUtil.isBagFull() then
		return false
	else
		return true
	end
end

--	判断携是否还能携带充值回馈奖励武将
function canCarryHero(cellData)
	local isHero = false
	if tonumber(cellData.itemsTable.type) == 2 then
		isHero = true
	end
	require "script/ui/hero/HeroPublicUI"
	if isHero and HeroPublicUI.showHeroIsLimitedUI() then
		return false
	else
		return true
	end
end

-- --通过 item_template_id 得到缓存匹配的第一条数据
-- --原ItemUtil.lua中的 getCacheItemInfoBy 函数只能获取道具、装备、武将碎片的信息，无法获得装备碎片的数据，在这里再次封装
-- function getCacheItemInfoBy(item_template_id)
-- 	item_template_id = tonumber(item_template_id)
-- 	require "script/ui/item/ItemUtil"
-- 	local cacheItemInfo = ItemUtil.getCacheItemInfoBy(item_template_id)

-- 	if cacheItemInfo ~= nil then return cacheItemInfo end

-- 	require "script/model/DataCache"
-- 	local allBagInfo = DataCache.getRemoteBagInfo()

-- 	if( not table.isEmpty(allBagInfo)) then
-- 		-- 宝物
-- 		if(cacheItemInfo==nil and not table.isEmpty( allBagInfo.treas)) then
-- 			for k,item_info in pairs( allBagInfo.treas) do
-- 				if(tonumber(item_info.item_template_id) == item_template_id) then
-- 					cacheItemInfo = item_info
-- 					cacheItemInfo.gid = k
-- 				end
-- 			end
-- 		end

-- 		-- 装备碎片
-- 		if(cacheItemInfo==nil and not table.isEmpty( allBagInfo.armFrag)) then
-- 			for k,item_info in pairs( allBagInfo.armFrag) do
-- 				if(tonumber(item_info.item_template_id) == item_template_id) then
-- 					cacheItemInfo = item_info
-- 					cacheItemInfo.gid = k
-- 				end
-- 			end
-- 		end
-- 		-- 战魂
-- 		if(cacheItemInfo==nil and not table.isEmpty( allBagInfo.fightSoul)) then
-- 			for k,item_info in pairs( allBagInfo.fightSoul) do
-- 				if(tonumber(item_info.item_template_id) == item_template_id) then
-- 					cacheItemInfo = item_info
-- 					cacheItemInfo.gid = k
-- 				end
-- 			end
-- 		end 
-- 		-- 时装
-- 		if(cacheItemInfo==nil and not table.isEmpty( allBagInfo.dress)) then
-- 			for k,item_info in pairs( allBagInfo.dress) do
-- 				if(tonumber(item_info.item_template_id) == item_template_id) then
-- 					cacheItemInfo = item_info
-- 					cacheItemInfo.gid = k
-- 				end
-- 			end
-- 		end 
-- 		-- 宠物碎片
-- 		if(cacheItemInfo==nil and not table.isEmpty( allBagInfo.petFrag)) then
-- 			for k,item_info in pairs( allBagInfo.petFrag) do
-- 				if(tonumber(item_info.item_template_id) == item_template_id) then
-- 					cacheItemInfo = item_info
-- 					cacheItemInfo.gid = k
-- 				end
-- 			end
-- 		end
-- 	end

-- 	return cacheItemInfo
-- end

-----------------------------------------------------------后端接口调用------------------------------------------------------------
--[[
interface IDragonShop
{
	http://192.168.1.177:8080/docs/
	/**
	 * 获取商店信息
	 *
	 * @return array
	 * <code>
	 * {
	 * 		$goodsId					商品id
	 * 		{
	 * 			'num'					购买次数
	 * 			'time'					购买时间
	 * 		}
	 * }
	 * </code>
	 */
	public function getShopInfo();
	
	/**
	 * 商店兑换商品
	 *
	 * @param int $goodsId				商品id
	 * @param int $num					数量
	 * @param string 'ok'
	 */
	public function buy($goodsId, $num);
}
--]]
function getExchangeInfoFromSever(funcCb)

	print("getExchangeInfoFromSever request... ")
	local function getExchangeInfoCb(cbFlag, dictData, bRet)
		if bRet == true then
			_exchangeInfo = dictData.ret
			print("=======_exchangeInfo begin========")
			print(_exchangeInfo)
			print_t(dictData.ret)
			print("=======_exchangeInfo end========")
			setExchangeDataTable()
			if funcCb ~= nil then
				print("request end")
				funcCb()
			end
		end
	end

	require "script/network/Network"
	Network.rpc(getExchangeInfoCb,"dragonshop.getShopInfo","dragonshop.getShopInfo",nil,true)
end

--	增加服务器中的用户数据
function addUserServerData(funcCb,args)
	Network.rpc(funcCb,"dragonshop.buy","dragonshop.buy",args,true)
end