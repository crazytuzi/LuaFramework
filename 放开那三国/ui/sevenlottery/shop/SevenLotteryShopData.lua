-- FileName: SevenLotteryShopData.lua 
-- Author: fuqiongqiong
-- Date: 2016-8-4
-- Purpose: 七星台商店Data

module("SevenLotteryShopData",package.seeall)
require "db/DB_Sevenstar_shop"

local _sevenLotteryShopInfo = nil
function setShopInfo( pData )
	_sevenLotteryShopInfo = pData
	print("_sevenLotteryShopInfo-----")
	print_t(_sevenLotteryShopInfo)
end


-- 得到表配置的所有商品数据
function getSevenLotteryShopInfo()
	local tData = {}
	for k, v in pairs(DB_Sevenstar_shop.Sevenstar_shop) do
		table.insert(tData, v)
	end
	local allGoods = {}
	for k,v in pairs(tData) do
		-- isSold为1的显示到出售列表
		if( tonumber(DB_Sevenstar_shop.getDataById(v[1]).isSold) == 1 )then
			table.insert(allGoods, DB_Sevenstar_shop.getDataById(v[1]))
		end
	end
	tData = nil

	local function keySort ( goods_1, goods_2 )
	   	return tonumber(goods_1.sortType) > tonumber(goods_2.sortType)
	end
	table.sort( allGoods, keySort )

	return allGoods
end

function getItemById( tag )
	local arrayInfo = getSevenLotteryAllShopInfo()
	return arrayInfo[tag]
end
-- 得到商店显示数据  
-- limitType 2:永久次数限制 此类型兑换次数达上限就不显示
function getSevenLotteryAllShopInfo()
	local showGoods = {}
	local dbGoods = getSevenLotteryShopInfo()
	for k,v in pairs(dbGoods) do
		if( tonumber(v.limitType) == 2 )then
			local haveNum = getBuyNumBy(v.id)
			if(haveNum < tonumber(v.baseNum))then
				table.insert(showGoods,v)
			end
		else
			table.insert(showGoods,v)
		end
	end
	return showGoods
end

function getScoreOfSevenLottery( ... )
	
	return tonumber(_sevenLotteryShopInfo.point)
end
function setScoreOfSevenLottery( pNum )
	_sevenLotteryShopInfo.point = tonumber(_sevenLotteryShopInfo.point) - pNum
end
-- 获取某个物品的当前购买次数
function getBuyNumBy( goods_id )
	local goods_id = tonumber(goods_id)
	local number = 0
	if(not  table.isEmpty(_sevenLotteryShopInfo.goods)) then
		for k_id, v in pairs(_sevenLotteryShopInfo.goods) do
			if(tonumber(k_id) == goods_id) then
				number = tonumber(v.num)
				break
			end
		end
	end
	return number
end


-- 得到兑换物品的 物品类型，物品id，物品数量
function getItemData( item_str )
	local tab = string.split(item_str,"|")
	return tonumber(tab[1]),tonumber(tab[2]),tonumber(tab[3])
end

-- array
--  *         [
--  *             $goodsId	商品id
--               {
--					'num'  购买次数
--					'time' 购买时间
--                 }
--  *         ]
-- 修改摸个商品的购买次数
function addBuyNumberBy( pIndex, n_addNum )
	print("pIndex----",pIndex)
	local addNum = tonumber(n_addNum)
	local goods_id = tonumber(getItemById(pIndex).id)
	print("goods_id-----",goods_id)
	local goodsInfoArray = _sevenLotteryShopInfo.goods
	local isExit = false
	if(not table.isEmpty(goodsInfoArray))then
		for k,v in pairs(goodsInfoArray) do
			if(tonumber(k) == tonumber(goods_id))then
				goodsInfoArray[tostring(k)].num = tonumber(v.num) + addNum
				isExit = true
				break
			end
		end
		if(not isExit)then
			_sevenLotteryShopInfo.goods[tostring(goods_id)] = {}
			_sevenLotteryShopInfo.goods[tostring(goods_id)]["num"] = addNum
			
		end
	else
		_sevenLotteryShopInfo.goods[tostring(goods_id)] = {}
		_sevenLotteryShopInfo.goods[tostring(goods_id)]["num"] = addNum

	end	
	print("_sevenLotteryShopInfo.goods")
	print_t(_sevenLotteryShopInfo.goods)
end

--获取下一个级别，当前兑换次数
function getLevelnumber(goods_data)
	local nextLv = -1
	local curNum = 1
	local goodsStr = string.split(goods_data.level_num,",")
	local length = #goodsStr
	--对表进行倒序
	for i=1,length do
		local goods_info = string.split(goodsStr[length - i + 1],"|")
		local first_data = string.split(goodsStr[1],"|")
		
		if( UserModel.getHeroLevel() >= tonumber(goods_info[1]) )then
			
		 	curNum = tonumber(goods_info[2])  --当前刷新次数
		 	if( 1 == i )then
		 		-- 当达到最大等级的时候
		 		nextLv = -1
		 	else
		 		-- 正常情况
		 		local data_goods = string.split(goodsStr[length - i +1 +1],"|")
		 		nextLv = tonumber(data_goods[1])  --要显示的下一级别
		 	end
			break
		end
	end
	return curNum,nextLv
end