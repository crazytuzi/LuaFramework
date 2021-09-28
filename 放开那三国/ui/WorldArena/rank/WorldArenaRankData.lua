-- FileName: WorldArenaRankData.lua
-- Author: licong
-- Date: 2015-07-01
-- Purpose: function description of module
--[[TODO List]]

module("WorldArenaRankData", package.seeall)

local _rankInfo 						= nil 	-- 排行数据

--[[
	@des 	: 设置排行数据
	@param 	: 
	@return :
--]]
function setRankInfo( p_info )
	_rankInfo = p_info
end

--[[
	@des 	: 得到排行数据
	@param 	: 
	@return :
--]]
function getRankInfo( ... )
	return _rankInfo 
end

--[[
	@des 	: 得到对应排行数据
	@param 	: p_type 1:击杀排行，2:连杀排行 3:对决排行
	@return :
--]]
function getRankInfoByTpye( p_type )
	if( table.isEmpty(_rankInfo) )then
		return {}
	end
	local tab = { _rankInfo.kill_rank, _rankInfo.conti_rank, _rankInfo.pos_rank }
	return tab[p_type]
end


--[[
	@des 	: 得到我的排行数据
	@param 	: p_type 1:击杀排行，2:连杀排行 3:对决排行
	@return :
--]]
function getMyRankInfoByTpye( p_type )
	if( table.isEmpty(_rankInfo) )then
		return {}
	end
	local myPid = WorldArenaMainData.getMyPid()
	local myServerId = WorldArenaMainData.getMyServerId()
	local rank = nil
	local tab = { _rankInfo.kill_rank, _rankInfo.conti_rank, _rankInfo.pos_rank }
	for k,v in pairs(tab[p_type]) do
		if( tonumber(v.pid) == myPid and tonumber(v.server_id) == myServerId )then
			rank = v.rank
			break
		end
	end
	return rank
end








