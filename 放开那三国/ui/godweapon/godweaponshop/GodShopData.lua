-- FileName: GodShopData.lua 
-- Author: DJN
-- Date: 14-12-20 
-- Purpose: 神兵商店数据

module("GodShopData", package.seeall)
require "db/DB_Overcomeshop_items"
require "script/ui/item/ItemUtil"
require "db/DB_Overcomeshop"
local _shopInfo = {}      ----后端返回商店信息
local _goodList = {}      ----奖励列表
local _refreshCd = nil    ----下次自动刷新的时间戳
local _goldTime = nil     ----今日已经使用金币刷新的次数
local _numberRef = nil    -----当日免费刷新次数
----------------------------------------商店-------------------------------------------
---设置商店信息数据
function setShopInfo( data )
	print("GodShopData setShopInfo ")
	print_t(data)
	-- print("设置值")
	-- print_t(data)
	_shopInfo = data
	--setRefreshCd(_shopInfo.refresh_cd)
	setGoldTime(_shopInfo.gold_refresh_num)

end
---得到商店信息数据
function getShopInfo( ... )
    print("来取值")
	print_t(_shopInfo)
	return _shopInfo
end
--获取免费刷新次数  add by fuqiongqiong 
function getNumberRef( ... )
	print("getNumberRef:")
	print(tonumber(_shopInfo.free_refresh))
	return tonumber(_shopInfo.free_refresh)
end

---旧的获取奖励列表的方法
function getGoodList( ... )
	local list = getShopInfo().goods_list or {}
	_goodList = {}
	for k,v in pairs(list)do
		local data = {}
		data.id = tonumber(k)
		data.count = tonumber(v)
		table.insert(_goodList,data)
	end
	return _goodList
end
--交换一个table中 a b 两个位置的元素
function switchTablePos(p_table,p_a,p_b)
	-- print("进来交换table位置")
	-- print("交换前")
	-- print_t(p_table)
	local contentA = p_table[p_a]
	p_table[p_a] = p_table[p_b]
	p_table[p_b] = contentA
	-- print("交换后")
	-- print_t(p_table)
end
---新的获取奖励列表的方法，适应新需求
function getGoodListForCell( ... )
	local list = getShopInfo().goods_list or {}
	local goodList = {}
	local haveSpecial = false
	for k,v in pairs(list)do
		local data = {}
		data.id = tonumber(k)
		data.count = tonumber(v)
		data.isSpecial = false
		table.insert(goodList,data)
	end
	local specialNum = table.count(getShopInfo().exclude)
	for specialLocation = 1,specialNum do
		local specialList = getShopInfo().exclude[specialLocation]
		local findFlag = false
		for k,v in pairs(specialList)do			
			for i,j in pairs(goodList)do
				if(tonumber(v) == j.id)then
					haveSpecial = true
					j.isSpecial = true
	                switchTablePos(goodList,specialLocation,i)
	                findFlag = true
	                break
				end
			end
			if(findFlag)then
				break
			end
		end
	end
	return goodList,haveSpecial
end
-------更改本地缓存
-------p_id是key count是数量
function changeGoodList(p_id,p_count)
	local shopInfo = getShopInfo()
	-- local list = shopInfo.goods_list
	--local count = 0
	local id = tonumber(p_id)
	for k,v in pairs(shopInfo.goods_list)do
		--count = count +1
		--if(count == id)then
		if(tonumber(k) == p_id)then
			-- print("变化前")
			-- print(v)
			v = tonumber(v) + tonumber(p_count)
			shopInfo.goods_list[k] = v
			-- if(v > 0)then
			-- 	shopInfo.goods_list[k] = v
			-- else
			-- 	shopInfo.goods_list[k] = nil
			-- end
			-- print("变化后")
			-- print(v)
		end
	end
	setShopInfo(shopInfo)
end

function getRewardInDb(p_id )
	local db = DB_Overcomeshop_items.getDataById(p_id).items
	-- print("转换前")
	-- print(db)
	db = ItemUtil.getItemsDataByStr(db)
	print("返回的item")
	print_t(db)
	return db
end
function getCostById( p_id)
	-- print("计算cost的id",p_id)
	local cost = {}
	table.insert(cost,DB_Overcomeshop_items.getDataById(p_id).costType)
	table.insert(cost,DB_Overcomeshop_items.getDataById(p_id).costNum)
    return cost
end
------闯关令是否足够
function isTokenEnough(p_num )
	local token = GodWeaponCopyData.getCopyInfo().coin
	if(tonumber(token) >= tonumber(p_num))then
		return true
	else
		return false
	end
end
------金币是否足够
function isGoldEnough(p_num )
	local curGold  = UserModel.getGoldNumber()
	if((curGold - tonumber(p_num)) >= 0 )then
		return true
	else
		return false
	end
end
------银币是否足够
function isSilverEnough(p_num )
	local curSilver  = UserModel.getSilverNumber()
	if((curSilver - tonumber(p_num)) >= 0 )then
		return true
	else
		return false
	end
end
-------更新扣得资源
-------传入奖励的id
function updateCost( p_id )
	local cost = getCostById(p_id)
	if(cost[1] == 1)then
		local allData = GodWeaponCopyData.getCopyInfo()
		allData.coin = allData.coin - cost[2]
		GodWeaponCopyData.setCopyInfo(allData)
	elseif(cost[1] == 2)then
		UserModel.addGoldNumber(- cost[2])
	elseif(cost[1] == 3)then
		UserModel.addSilverNumber(- cost[2])
	end


end
-------设置下次刷新倒计时
--function setRefreshCd( data)
	--_refreshCd = data
--end
------获取下次刷新倒计时
--function getRefreshCd( ... )
	--return _refreshCd
--end
-------设置今日金币刷新次数
function setGoldTime( data)
	_goldTime = data
end
function getGoldTime( ... )
	return _goldTime
end
------获取本次刷新需要的金币数量，参数为取已经刷新的次数+1
function getRefreshCost(p_time)
	--print("本次是刷新的第*次",p_time)
	require "script/utils/LuaUtil"
	local curTime = tonumber(p_time)
	local info = DB_Overcomeshop.getDataById(1).goldGost
	info = parseField(info, 2)
	-- print("info")
	-- print_t(info)
	-- print("DbInfo")
	-- print_t(info)
	for k,v in pairs(info)do
        if(v[1] >= curTime)then
        	return v[2]
        end
	end
end
------得到表中的碎片合成需要数量
function getTotalNumInDb(p_id )
	--通过ID获取某个物品的属性所有信息，从中获取碎片合成需要数量
	local db = ItemUtil.getItemById(p_id).need_part_num  
	return db
end