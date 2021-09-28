-- FileName: MissonTaskCell.lua
-- Author: shengyixian
-- Date: 2015-08-28
-- Purpose: 悬赏榜商店数据
module("MissionShopData",package.seeall)

require "db/DB_Bounty_shop"

-- 商品信息
local _shopInfo = nil

--[[
	@des 	: 解析商店配置文件，把数据修改成方便使用的格式
	@param 	: 
	@return : 
--]]
function initShopInfoByDB(info)
	_shopInfo = {}
	for k,v in pairs(DB_Bounty_shop.Bounty_shop) do
		local t = DB_Bounty_shop.getDataById(v[1])
		local bool = false
		if (tonumber(t.limitType) == 1) then
			bool = true
			if (info[t.id] ~= nil) then
				t.receiveTimes = info[t.id]
			else
				t.receiveTimes = 0
			end
		else
			if (info[t.id] ~= nil) then
				bool = true
				t.receiveTimes = info[t.id]
			end
		end

		if bool then
			local ary = string.split(t.items,"|")
			t.goodType = ary[1]
			t.goodID = ary[2]
			t.goodNum = ary[3]
			table.insert(_shopInfo,t)
		end
	end

	table.sort(_shopInfo,function (v1,v2)
		return v1.sortId < v2.sortId
	end)
end
--[[
	@des 	: 解析从后端获取到的数据
	@param 	: 
	@return : 
--]]
function setInfo(ret)
	local info = {}
	for k,v in pairs(ret) do
		info[tonumber(k)] = tonumber(v)
	end
	initShopInfoByDB(info)
end
--[[
	@des 	: 获取商品信息
	@param 	: 
	@return : 
--]]
function getShopInfo()
	return _shopInfo
end
