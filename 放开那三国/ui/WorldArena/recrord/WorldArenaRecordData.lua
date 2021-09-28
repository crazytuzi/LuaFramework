-- FileName: WorldArenaRecordData.lua
-- Author: licong
-- Date: 2015-07-01
-- Purpose: 战报数据
--[[TODO List]]

module("WorldArenaRecordData", package.seeall)

local _recordInfo 						= nil 	-- 战报数据

--[[
	@des 	: 设置战报数据
	@param 	: 
	@return :
--]]
function setRecordInfo( p_info )
	_recordInfo = p_info
end

--[[
	@des 	: 得到战报数据
	@param 	: 
	@return :
--]]
function getRecordInfo( ... )
	return _recordInfo 
end


--[[
	@des 	: 得到是否连杀战报1
	@param 	: p_data
	@return : true or false
--]]
function isContiRecord1( p_data )
	local retData = false
	-- 攻方连杀是5的倍数 
	if( tonumber(p_data.attacker_conti) > 0 and tonumber(p_data.attacker_conti)%5 == 0 )then
		retData = true
	end
	return retData
end

--[[
	@des 	: 得到是否连杀战报2
	@param 	: p_data
	@return : true or false
--]]
function isContiRecord2( p_data )
	local retData = false
	-- 终结对方连杀  对方连杀数是大于等于5的 
	if( tonumber(p_data.attacker_terminal_conti) >= 5 )then
		retData = true
	end
	return retData
end

--[[
	@des 	: 得到是我的战报 id 3
	@param 	: p_data
	@return : true or false
--]]
function isMyRecord3( p_data )
	local myPid = WorldArenaMainData.getMyPid()
	local myServerId = WorldArenaMainData.getMyServerId()
	local retData = false
	-- 我是守方 赢
	if( myPid == tonumber(p_data.defender_pid) and myServerId == tonumber(p_data.defender_server_id) and tonumber(p_data.result) == 0 )then
		retData = true
	end
	return retData
end

--[[
	@des 	: 得到是我的战报4
	@param 	: p_data
	@return : true or false
--]]
function isMyRecord4( p_data )
	local myPid = WorldArenaMainData.getMyPid()
	local myServerId = WorldArenaMainData.getMyServerId()
	local retData = false
	-- 我是攻方 赢 排名上升 大于1连杀
	if( myPid == tonumber(p_data.attacker_pid) and myServerId == tonumber(p_data.attacker_server_id) and tonumber(p_data.result) == 1 
		and tonumber(p_data.attacker_rank) > tonumber(p_data.defender_rank) and tonumber(p_data.attacker_conti) > 1)then
		retData = true
	end
	return retData
end


--[[
	@des 	: 得到我的战报5
	@param 	: p_data
	@return : true or false
--]]
function isMyRecord5( p_data )
	local myPid = WorldArenaMainData.getMyPid()
	local myServerId = WorldArenaMainData.getMyServerId()
	local retData = false
	-- 我是守方 输
	if( myPid == tonumber(p_data.defender_pid) and myServerId == tonumber(p_data.defender_server_id) and tonumber(p_data.result) == 1 )then
		retData = true
	end
	return retData
end

--[[
	@des 	: 得到我的战报6
	@param 	: p_data
	@return : true or false
--]]
function isMyRecord6( p_data )
	local myPid = WorldArenaMainData.getMyPid()
	local myServerId = WorldArenaMainData.getMyServerId()
	local retData = false
	-- 我是攻方 输
	if( myPid == tonumber(p_data.attacker_pid) and myServerId == tonumber(p_data.attacker_server_id) and tonumber(p_data.result) == 0 )then
		retData = true
	end
	return retData
end

--[[
	@des 	: 得到我的战报7
	@param 	: p_data
	@return : true or false
--]]
function isMyRecord7( p_data )
	local myPid = WorldArenaMainData.getMyPid()
	local myServerId = WorldArenaMainData.getMyServerId()
	local retData = false
	-- 我是攻方 赢 自己排名不变 
	if( myPid == tonumber(p_data.attacker_pid) and myServerId == tonumber(p_data.attacker_server_id) and tonumber(p_data.result) == 1
	  and tonumber(p_data.attacker_rank) < tonumber(p_data.defender_rank) and tonumber(p_data.attacker_conti) > 1 )then
		retData = true
	end
	return retData
end

--[[
	@des 	: 得到我的战报8
	@param 	: p_data
	@return : true or false
--]]
function isMyRecord8( p_data )
	local myPid = WorldArenaMainData.getMyPid()
	local myServerId = WorldArenaMainData.getMyServerId()
	local retData = false
	-- 我是攻方 赢 自己排名上升 1连杀
	if( myPid == tonumber(p_data.attacker_pid) and myServerId == tonumber(p_data.attacker_server_id) and tonumber(p_data.result) == 1
	  and tonumber(p_data.attacker_rank) > tonumber(p_data.defender_rank) and tonumber(p_data.attacker_conti) <= 1 )then
		retData = true
	end
	return retData
end

--[[
	@des 	: 得到我的战报9
	@param 	: p_data
	@return : true or false
--]]
function isMyRecord9( p_data )
	local myPid = WorldArenaMainData.getMyPid()
	local myServerId = WorldArenaMainData.getMyServerId()
	local retData = false
	-- 我是攻方 赢 自己排名不变  1连杀
	if( myPid == tonumber(p_data.attacker_pid) and myServerId == tonumber(p_data.attacker_server_id) and tonumber(p_data.result) == 1
	  and tonumber(p_data.attacker_rank) < tonumber(p_data.defender_rank) and tonumber(p_data.attacker_conti) <= 1 )then
		retData = true
	end
	return retData
end

--[[
	@des 	: 得到连杀战报数据
	@param 	:
	@return : 
--]]
function getContiListData()
	if( table.isEmpty(_recordInfo.conti) )then
		return {}
	end
	local retData = {}

	local contiTab = {
		isContiRecord1,
		isContiRecord2,	
	}
	local idTab = {1,2}

	for k,v in pairs(_recordInfo.conti) do
		for i=1,#contiTab do
			local isTrue = contiTab[i](v)
			if( isTrue )then
				local tab = table.hcopy(v,{})
				tab.id = idTab[i]
				table.insert(retData,tab)
			end
		end
	end

	local sortfunction = function ( p_data1, p_data2 )
		return tonumber(p_data1.attack_time) > tonumber(p_data2.attack_time) 
	end
	table.sort( retData, sortfunction )

	return retData
end


--[[
	@des 	: 得到我的战报数据
	@param 	:
	@return : 
--]]
function getMyListData()
	if( table.isEmpty(_recordInfo.my) )then
		return {}
	end
	local retData = {}
	
	local myTab = {
		isMyRecord3,
		isMyRecord4,
		isMyRecord5,
		isMyRecord6,
		isMyRecord7,
		isMyRecord8,
		isMyRecord9,	
	}
	local idTab = {3,4,5,6,7,8,9}

	for k,v in pairs(_recordInfo.my) do
		for i=1,#myTab do
			local isTrue = myTab[i](v)
			if( isTrue )then
				local tab = table.hcopy(v,{})
				tab.id = idTab[i]
				table.insert(retData,tab)
			end
		end
	end

	local sortfunction = function ( p_data1, p_data2 )
		return tonumber(p_data1.attack_time) > tonumber(p_data2.attack_time) 
	end
	table.sort( retData, sortfunction )
	
	return retData
end

--[[
	@des 	: 得到我的战报数据
	@param 	:p_type 1连杀战报 2我的战报
	@return : 
--]]
function getListData(p_type)
	local retData = {}
	if( p_type == 1 )then
		retData = getContiListData()
	elseif( p_type == 2)then
		retData = getMyListData()
	else
	end
	return retData
end













