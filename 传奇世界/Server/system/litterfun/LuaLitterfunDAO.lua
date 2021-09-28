--LuaLitterfunDAO.lua
--/*-----------------------------------------------------------------
 --* Module:  LuaLitterfunDAO.lua
 --* Author:  seezon
 --* Modified: 2014年12月19日
 --* Purpose: 小功能数据池
 -------------------------------------------------------------------*/
--]]
--------------------------------------------------------------------------------
LuaLitterfunDAO = class(nil, Singleton)

function LuaLitterfunDAO:__init()
	self._staticPotencys = {}
	self._staticCharges = {}

	--加载所有的潜能丹原型
	local potencyDBs = require "data.PotencyDB"
	for _, record in pairs(potencyDBs or table.empty) do
		self._staticPotencys[record.q_itemID] = record
	end

	--加载所有的充值原型
	local chargeDBs = require "data.ChargeDB"
	for _, record in pairs(chargeDBs or table.empty) do
		self._staticCharges[record.q_limit] = record
	end
end


--获取潜能丹数据
function LuaLitterfunDAO:getPotencyDB(itemID)
	if itemID then
	    return self._staticPotencys[itemID]
	end
end

--根据潜能丹类型和门派获取潜能丹ID
function LuaLitterfunDAO:getPotencyID(DanType, school)
	for _, v in pairs(self._staticPotencys or table.empty) do
		if DanType == v.q_type and school == v.q_school then
			return v.q_itemID
		end
	end
end

--获取充值配置
function LuaLitterfunDAO:getChargeData(ingot)
	for _, v in pairs(self._staticCharges or table.empty) do
		if ingot == v.q_limit then
			return v
		end
	end
end

function LuaLitterfunDAO.getInstance()
	return LuaLitterfunDAO()
end