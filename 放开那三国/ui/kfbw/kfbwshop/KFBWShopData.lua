-- FileName: KFBWShopData.lua
-- Author: shengyixian
-- Date: 2015-09-30
-- Purpose: 跨服比武商店数据层
module("KFBWShopData",package.seeall)
require "db/DB_Kuafu_contest_shop"
-- 当前要显示的物品信息
local _tItemInfo = nil
--[[
	@des 	: 根据返回的数据设置当前显示的物品信息
	@param 	: 
	@return : 
--]]
function setItemInfo( data )
	-- body
	_tItemInfo = {}
	-- data = data or {[1] = 100,[3] = 100,[4] = 1000}
	for k,v in pairs(DB_Kuafu_contest_shop.Kuafu_contest_shop) do
		local t = DB_Kuafu_contest_shop.getDataById(v[1])
		if(tonumber(t.isSold) == 1)then
			--isSold 为1显示 为0不显示
			t.id = tostring(t.id)
			t.baseNum = tonumber(t.baseNum)
			local bool = false
			local limitType = tonumber(t.limitType)
			if (limitType == 1 or limitType == 3) then
				bool = true
				if (data[t.id] ~= nil) then
					t.exchangeTimes = t.baseNum - tonumber(data[t.id].num)
				else
					t.exchangeTimes = t.baseNum
				end
			else
				if (data[t.id] ~= nil) then
					if (t.baseNum > tonumber(data[t.id].num)) then
						bool = true
						t.exchangeTimes = t.baseNum - tonumber(data[t.id].num)
					end
				else
					bool = true
					t.exchangeTimes = t.baseNum
				end
			end

			if bool then
				if UserModel.getHeroLevel() >= t.display_lv then
					local ary = string.split(t.items,"|")
					t.itemType = ary[1]
					t.itemID = ary[2]
					t.itemNum = ary[3]
					-- 解析价格数据
					t.priceAry = ItemUtil.getItemsDataByStr(t.price)
					table.insert(_tItemInfo,t)
				end
			end
		end
		table.sort(_tItemInfo,function ( t1,t2 )
			-- body
			return t1.sortId < t2.sortId
		end)
	end
		
end
--[[
	@des 	: 获取当前显示的物品信息
	@param 	: 
	@return : 
--]]
function getItemInfo( ... )
	-- body
	return _tItemInfo
end