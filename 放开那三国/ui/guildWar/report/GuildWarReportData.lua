-- FileName: GuildWarReportData.lua 
-- Author: Zhang Zihang
-- Date: 15-1-20
-- Purpose:  战报数据

module("GuildWarReportData", package.seeall)

require "script/ui/guildWar/GuildWarDef"

local _mainReportInfo 			--主战报信息
local _detailReportInfo 		--详细战报信息

--[[
	@des 	:得到军团战绩cell数量
	@return :战报数量
--]]
function getMainCellNum()
	--淘汰赛战报数量
	local finalNum = 0
	for k,v in pairs(_mainReportInfo.finals) do
		if v.result ~= nil then
			finalNum = finalNum + 1
		end
	end

	local cellNum = #_mainReportInfo.audition + finalNum
	return cellNum
end

--[[
	@des 	:得到详细战报cell数量
	@param  :分组值（对于海选详细战报只有一个组，所以传1就行）
	@return :战报数量
--]]
function getDetailCellNum(p_index)
	local cellNum = #(_detailReportInfo[tonumber(p_index)].arrProcess)
	return cellNum
end

--[[
	@des 	:设置主战报信息
	@param  :后端返回的战报信息
--]]
function setMainReportInfo(p_info)
	local dataTable = p_info

	_mainReportInfo = dataTable
end

--[[
	@des 	:获取并排序详细战报信息
	@param  :后端返回的战报信息
--]]
function setAndSortDetailReportInfo(p_info)
	local dataTable = p_info
	local kTable = {}

	for k,v in pairs(dataTable) do
		table.insert(kTable,v)

		kTable[#kTable].replayId = tostring(k)
	end

	local sortFunction = function(w1,w2)
		if w1.replayId < w2.replayId then
			return true
		else
			return false
		end
	end

	table.sort(kTable,sortFunction)

	for i = (#kTable + 1),5 do
		kTable[i] = {}
		kTable[i].arrProcess = {}
	end

	_detailReportInfo = kTable
end

--[[
	@des 	:处理并返回详细战报信息
	@return :处理好的战报信息
--]]
function dealAndGetDetailReportInfo()
	local returnTable = {}
	for i = 1,#_detailReportInfo do
		local groupTable = {}
		local groupInfo = _detailReportInfo[i]
		local processInfo = groupInfo.arrProcess
		--因为要算cell的数量，所以空代表目前没有这个组别
		if not table.isEmpty(processInfo) then
			--是否进攻和防守转换
			local isRevert = isMyOwnGuild(tonumber(groupInfo.def_guild_id),tostring(groupInfo.def_server_id))
			for j = 1,#processInfo do
				local singleInfo = processInfo[j]
				local innerTable = {}
				if isRevert then
					innerTable.ownName = groupInfo.userList[tostring(singleInfo.def_uid)].name
					innerTable.opponentName = groupInfo.userList[tostring(singleInfo.atk_uid)].name
					innerTable.ownHtid = groupInfo.userList[tostring(singleInfo.def_uid)].htid
					innerTable.opponentHtid = groupInfo.userList[tostring(singleInfo.atk_uid)].htid
					innerTable.result = reverseDetailResult(singleInfo.result)
					innerTable.ownCommbo = singleInfo.def_max_win
					innerTable.opponentCommbo = singleInfo.atk_max_win
				else
					innerTable.ownName = groupInfo.userList[tostring(singleInfo.atk_uid)].name
					innerTable.opponentName = groupInfo.userList[tostring(singleInfo.def_uid)].name
					innerTable.ownHtid = groupInfo.userList[tostring(singleInfo.atk_uid)].htid
					innerTable.opponentHtid = groupInfo.userList[tostring(singleInfo.def_uid)].htid
					innerTable.result = tonumber(singleInfo.result)
					innerTable.ownCommbo = singleInfo.atk_max_win
					innerTable.opponentCommbo = singleInfo.def_max_win
				end

				innerTable.brid = singleInfo.brid

				table.insert(groupInfo,innerTable)
			end
			table.insert(returnTable,groupInfo)
		end
	end

	return returnTable
end

--[[
	@des 	:将比赛结果取反
	@param  :原始比赛结果
	@return :相反的比赛结果
--]]
function reverseResult(p_result)
	local result = tonumber(p_result)

	return (result == GuildWarDef.VICTORY) and GuildWarDef.FAILED or GuildWarDef.VICTORY
end

--[[
	@des 	:详细战报结果取反
	@param  :结果
	@return :相反的比赛结果（平局不变）
--]]
function reverseDetailResult(p_result)
	local result = tonumber(p_result)

	if result ~= GuildWarDef.DRAW then
		result = (result == GuildWarDef.VICTORY) and GuildWarDef.FAILED or GuildWarDef.VICTORY
	end

	return result
end

--[[
	@des 	:处理并返回主战报信息
	@return :处理好的战报信息
	@return :是否出局
--]]
function dealAndGetMainReportInfo()
	local isOver = false

	local returnTable = {}
	local auditionInfo = _mainReportInfo.audition
	--海选赛失败次数
	local auditionLostNum = 0

	for i = 1,#auditionInfo do
		local singleInfo = auditionInfo[i]
		local innerTable = {}
		if table.isEmpty(singleInfo.attacker) then
			innerTable.opponent = singleInfo.defender
			innerTable.result = tonumber(singleInfo.result)
		elseif table.isEmpty(singleInfo.defender) then
			innerTable.opponent = singleInfo.attacker
			innerTable.result = reverseResult(singleInfo.result)
		end

		if innerTable.result == GuildWarDef.FAILED then
			auditionLostNum = auditionLostNum + 1
		end

		--海选赛的轮次
		innerTable.round = i
		--类型
		innerTable.type = GuildWarDef.AUDITION
		--replayId
		innerTable.replayId = {singleInfo.replay_id}

		table.insert(returnTable,innerTable)
	end

	--淘汰赛失败次数
	local finalLostNum = 0
	local finalsInfo = _mainReportInfo.finals
	--for k,v in pairs(finalsInfo) do
	for j = GuildWarDef.ADVANCED_16,GuildWarDef.ADVANCED_2 do
		local singleInfo = finalsInfo[tostring(j)]
		if singleInfo ~= nil and singleInfo.result ~= nil then
			local innerTable = {}
			if table.isEmpty(singleInfo.attacker) then
				innerTable.opponent = singleInfo.defender
				innerTable.result = tonumber(singleInfo.result)
			elseif table.isEmpty(singleInfo.defender) then
				innerTable.opponent = singleInfo.attacker
				innerTable.result = reverseResult(singleInfo.result)
			end

			if innerTable.result == GuildWarDef.FAILED then
				finalLostNum = finalLostNum + 1
			end

			local tonumberK = j
			innerTable.type = tonumberK

			local replayTable = {}
			for i = 1,#singleInfo.sub_round do
				table.insert(replayTable,singleInfo.sub_round[i].replay_id)
			end

			innerTable.replayId = replayTable

			--returnTable[#auditionInfo + tonumberK - 2] = innerTable
			table.insert(returnTable,innerTable)
		end
	end
	--淘汰赛失败3场或淘汰赛出局，说明已经被淘汰了
	if auditionLostNum >= GuildWarDef.AUDITION_LOST_NUM or finalLostNum >= GuildWarDef.PLAYOFF_LOST_NUM then
		isOver = true
	end

	return returnTable,isOver
end

--[[
	@des 	:通过军团id和服务器id判断是否是自己的军团
	@param  : 军团id
	@param  : 服务器id
	@return : 是 true 否 false
--]]
function isMyOwnGuild(p_guildId,p_serverId)
	require "script/ui/guild/GuildDataCache"
	require "script/ui/guildWar/GuildWarMainData"

	if (p_guildId == GuildDataCache.getMineSigleGuildId()) and (p_serverId == GuildWarMainData.getMyServerId()) then
		return true
	else
		return false
	end
end

--[[
	@des 	:得到英雄品质
	@param  :htid
	@return :品质
--]]
function getHeroQuality(p_htid)
	require "db/DB_Heroes"
	local heroInfo = DB_Heroes.getDataById(p_htid)

	return tonumber(heroInfo.star_lv)
end

----------------------------------------------------------------------- 对战情况数据方法 -----------------------------------------------------------------------

local _reportData 				= nil 	-- 军团对战情况后端数据
local _oneGroupNum 				= 4 	-- 军团对战情况一组有4个人


--[[
	@des 	:设置军团对战情况数据
	@param 	:p_reportData:后端返回军团对战情况数据
	@return :
--]]
function setReportData( p_reportData )
	_reportData = p_reportData
	print("setReportData")
	print_t(_reportData)
end

--[[
	@des 	:得到军团对战情况数据
--]]
function getReportData()
	return _reportData 
end

--[[
	@des 	:得到军团的数据
	@param 	:p_guildId:军团id，p_serverId:服务器id
	@return :对应军团数据
--]]
function getGuildDataBy( p_guildId, p_serverId )
	local retData = nil
	local reportData = getReportData()
	if( tonumber(reportData.attacker.guild_id) == tonumber(p_guildId) and tonumber(reportData.attacker.guild_server_id) == tonumber(p_serverId) )then 
		retData = reportData.attacker
	elseif( tonumber(reportData.defender.guild_id) == tonumber(p_guildId) and tonumber(reportData.defender.guild_server_id) == tonumber(p_serverId) )then 
		retData = reportData.defender
	else
		print("no p_guildId no p_serverId",p_guildId,p_serverId)
	end
	return retData
end

--[[
	@des 	:是否有比赛结果
	@param 	:
	@return :true or false
--]]
function getIsHaveResult() 
	local retData = false
	local reportData = getReportData()
	local result = reportData.result
	if( result ~= nil )then
		retData = true
	else
		retData = false
	end
	return retData
end

--[[
	@des 	:得到这个军团是淘汰还是晋级
	@param 	:p_guildId:军团id，p_serverId:服务器id
	@return :true or false
--]]
function getIsWinBy( p_guildId, p_serverId )
	local retData = false
	local reportData = getReportData()
	if( tonumber(reportData.attacker.guild_id) == tonumber(p_guildId) and tonumber(reportData.attacker.guild_server_id) == tonumber(p_serverId) and tonumber(reportData.result) == GuildWarDef.VICTORY ) then 
		retData = true
	elseif( tonumber(reportData.defender.guild_id) == tonumber(p_guildId) and tonumber(reportData.defender.guild_server_id) == tonumber(p_serverId) and tonumber(reportData.result) == GuildWarDef.FAILED ) then 
		retData = true
	else
		retData = false
	end
	return retData
end

--[[
	@des 	:得到军团成员列表数据
	@param 	:p_guildId:军团id，p_serverId:服务器id
	@return :
--]]
function getMemberListData( p_guildId, p_serverId )
	local retData = nil
	local guildData = getGuildDataBy( p_guildId, p_serverId )
	if(guildData ~= nil)then
		retData = guildData.member
	end
	return retData
end

--[[
	@des 	:得到军团成员剩余人数
	@param 	:p_guildId:军团id，p_serverId:服务器id
	@return :
--]]
function getSurplusMemberNum( p_guildId, p_serverId )
	local retNum = 0
	local memberList = getMemberListData( p_guildId, p_serverId )
	if(not table.isEmpty(memberList) )then
		for k,v in pairs(memberList) do
			if( tonumber(v.state) == 1)then
				-- 可参战
				retNum = retNum + 1
			end
		end
	end
	return retNum
end

--[[
	@des 	:得到每一组的数据和这一组是否打完
	@param 	:p_index:第几组数据
	@return :是否打完,战报数据
--]]
function getIsOverAndReportDataByIndex( p_index )
	local retData = nil
	local isOver = false
	local reportData = getReportData()
	-- 先取改组对应的战报 取到就结束了 取不到就没打
	if(not table.isEmpty(reportData.sub_round) )then
		retData = reportData.sub_round[tonumber(p_index)]
		if(  table.isEmpty(retData) )then
			isOver = false 
		else
			isOver = true
		end
	end

	-- 有大结果就都是结束
	if(reportData.result ~= nil)then
		isOver = true
	end

	if(retData == nil)then
		retData = {}
	end
	return isOver, retData
end

--[[
	@des 	:得到每一组的数据和这一组是否打完
	@param 	:p_guildId:军团id，p_serverId:服务器id,p_index:第几组数据
	@return :listTab,isCurOver 
--]]
function getListDataAndIsOverByIndex( p_guildId, p_serverId, p_index )
	local retData = {}
	-- 当前组是否打完 和 战报数据
	local isCurOver,retData = getIsOverAndReportDataByIndex(p_index)
	
	-- 当前组没结束 返回对战信息
	if(isCurOver == false)then
		-- 上一组是否打完 和 战报数据
		local isUpOver,_ = getIsOverAndReportDataByIndex(p_index-1)
		-- 得到所有参战成员列表
		local curMemberList = getMemberListData(p_guildId, p_serverId)
		-- print("curMemberList",p_guildId,p_serverId,p_index,isCurOver) print_t(curMemberList)
	
		-- 上一组是否结束
		if(isUpOver)then
			-- 上一组结束了 就把当前组之前的可参战的人合并到当前组
			for i=1, p_index*_oneGroupNum do
				-- 可参战的加入本组
				if( not table.isEmpty(curMemberList) and not table.isEmpty(curMemberList[i]) and tonumber(curMemberList[i].state) == 1)then
					table.insert(retData,curMemberList[i])
				end
			end
		else
			-- 上一组没结束 则取当前组4个人
			for i=((p_index-1)*_oneGroupNum)+1,p_index*_oneGroupNum do
				-- 可参战的加入本组
				if( not table.isEmpty(curMemberList) and not table.isEmpty(curMemberList[i]) and tonumber(curMemberList[i].state) == 1)then
					table.insert(retData,curMemberList[i])
				end
			end
		end
	end

	return retData,isCurOver
end

--[[
	@des 	:得到是不是最后一组战报
	@param 	:p_index:第几组
	@return :true or false 
--]]
function getIsFinalByIndex( p_index )
	local retData = false
	local reportData = getReportData()
	local isHaveResult = getIsHaveResult()
	-- 没有出结果 返回false
	if( isHaveResult == false)then
		return retData
	end
	-- 是最后一组
	if( p_index == table.count(reportData.sub_round) )then 
		retData = true
	end
	return retData
end

--[[
	@des 	:得到剩余没上场的人
	@param 	:
	@return :table
--]]
function getNoFightUserTable()
	local retData = {}
	local reportData = getReportData()
	if( reportData.left_user ~= nil and reportData.result ~= nil)then
		retData = reportData.left_user
	end
	return retData
end

--[[
	@des 	:得到每一组处理后的数据 显示用
	@param 	:p_guildId:军团id，p_serverId:服务器id,p_index:第几组数据,p_isLeft:是否是左边军团
	@return :listTab
--]]
function getShowDataByIndex( p_guildId, p_serverId, p_index, p_isLeft )
	local retData = {}
	local listData,isCurOver = getListDataAndIsOverByIndex(p_guildId, p_serverId, p_index )

	if(isCurOver and not table.isEmpty(listData))then
		-- 结束 处理战报成显示数据格式
		for i=1,#listData.arrProcess.arrProcess do
			local temTab = {}
			temTab.index = i
			temTab.replay_id = listData.replay_id
			temTab.brid = listData.arrProcess.arrProcess[i].brid
			-- atk_uid 攻方有可能属于军团1 也有可能属于军团2 所有要判断军团id
			if( tonumber(listData.arrProcess.atk_guild_id) == tonumber(p_guildId) and tonumber(listData.arrProcess.atk_server_id) == tonumber(p_serverId) and p_isLeft == true )then 
				-- 数据1
				temTab.player1 = {}
				temTab.player1.guild_id = listData.arrProcess.atk_guild_id
				temTab.player1.server_id = listData.arrProcess.atk_server_id
				temTab.player1.uname = listData.arrProcess.userList[listData.arrProcess.arrProcess[i].atk_uid].name
				temTab.player1.fight_force = listData.arrProcess.userList[listData.arrProcess.arrProcess[i].atk_uid].fight_force
				temTab.player1.htid = listData.arrProcess.userList[listData.arrProcess.arrProcess[i].atk_uid].htid
				temTab.player1.max_win = listData.arrProcess.arrProcess[i].atk_max_win

				-- 数据2
				temTab.player2 = {}
				temTab.player2.guild_id = listData.arrProcess.def_guild_id
				temTab.player2.server_id = listData.arrProcess.def_server_id
				temTab.player2.uname = listData.arrProcess.userList[listData.arrProcess.arrProcess[i].def_uid].name
				temTab.player2.fight_force = listData.arrProcess.userList[listData.arrProcess.arrProcess[i].def_uid].fight_force
				temTab.player2.htid = listData.arrProcess.userList[listData.arrProcess.arrProcess[i].def_uid].htid
				temTab.player2.max_win = listData.arrProcess.arrProcess[i].def_max_win

				-- 胜负以攻击方为准 2为胜 1为平局 0为失败
				if(tonumber(listData.arrProcess.arrProcess[i].result) == GuildWarDef.VICTORY)then
					-- 胜利
					temTab.player1.isWin = GuildWarDef.VICTORY
					temTab.player2.isWin = GuildWarDef.FAILED
				elseif(tonumber(listData.arrProcess.arrProcess[i].result) == GuildWarDef.FAILED)then
					-- 失败
					temTab.player1.isWin = GuildWarDef.FAILED
					temTab.player2.isWin = GuildWarDef.VICTORY
				else
					-- 平局
					temTab.player1.isWin = GuildWarDef.DRAW
					temTab.player2.isWin = GuildWarDef.DRAW
				end
			else
				-- 数据1
				temTab.player1 = {}
				temTab.player1.guild_id = listData.arrProcess.def_guild_id
				temTab.player1.server_id = listData.arrProcess.def_server_id
				temTab.player1.uname = listData.arrProcess.userList[listData.arrProcess.arrProcess[i].def_uid].name
				temTab.player1.fight_force = listData.arrProcess.userList[listData.arrProcess.arrProcess[i].def_uid].fight_force
				temTab.player1.htid = listData.arrProcess.userList[listData.arrProcess.arrProcess[i].def_uid].htid
				temTab.player1.max_win = listData.arrProcess.arrProcess[i].def_max_win
	
				-- 数据2
				temTab.player2 = {}
				temTab.player2.guild_id = listData.arrProcess.atk_guild_id
				temTab.player2.server_id = listData.arrProcess.atk_server_id
				temTab.player2.uname = listData.arrProcess.userList[listData.arrProcess.arrProcess[i].atk_uid].name
				temTab.player2.fight_force = listData.arrProcess.userList[listData.arrProcess.arrProcess[i].atk_uid].fight_force
				temTab.player2.htid = listData.arrProcess.userList[listData.arrProcess.arrProcess[i].atk_uid].htid
				temTab.player2.max_win = listData.arrProcess.arrProcess[i].atk_max_win

				-- 胜负以攻击方为准 2为胜 1为平局 0为失败
				if(tonumber(listData.arrProcess.arrProcess[i].result) == GuildWarDef.VICTORY)then
					-- 胜利
					temTab.player1.isWin = GuildWarDef.FAILED
					temTab.player2.isWin = GuildWarDef.VICTORY
				elseif(tonumber(listData.arrProcess.arrProcess[i].result) == GuildWarDef.FAILED)then
					-- 失败
					temTab.player1.isWin = GuildWarDef.VICTORY
					temTab.player2.isWin = GuildWarDef.FAILED
				else
					-- 平局
					temTab.player1.isWin = GuildWarDef.DRAW
					temTab.player2.isWin = GuildWarDef.DRAW
				end
			end		
			table.insert(retData,temTab)
		end
		-- 最后一组战报 加上剩余没上场的人
		local isFinal = getIsFinalByIndex( p_index )
		print("isFinal..",isFinal)
		if(isFinal)then
			local tab = {}
			local isWinGuild = getIsWinBy( p_guildId, p_serverId )
			print("isWinGuild..",isWinGuild)
			local onFightTab = getNoFightUserTable()
			if( not table.isEmpty(onFightTab) )then 
				for k_index,v_info in pairs(onFightTab) do
					print("k_index",k_index)
					print_t(v_info)
					for k,v_user in pairs(v_info) do
						local temTab = {}
						if(isWinGuild == true and p_isLeft == true )then
							temTab.player1 = {}
							temTab.player1.uname = v_user.uname
							temTab.player1.fight_force = v_user.fight_force
							temTab.player1.htid = v_user.htid
						else
							temTab.player2 = {}
							temTab.player2.uname = v_user.uname
							temTab.player2.fight_force = v_user.fight_force
							temTab.player2.htid = v_user.htid
						end
						table.insert(tab,temTab)
					end
				end
				-- 按战斗力排序
				local sortFun = function( data1, data2 )
					local temData1 = data1.player1 or data1.player2
					local temData2 = data2.player1 or data2.player2
					return tonumber(temData1.fight_force) < tonumber(temData2.fight_force)
				end 
				table.sort( tab, sortFun)
				for i=1,#tab do
					tab[i].index = #retData + 1
					table.insert(retData,tab[i])
				end
			end
		end
	else
		-- 没结束 处理数据成预计出场数据格式
		for i=1,#listData do
			local temTab = {}
			temTab.index = i
			temTab.uname = listData[i].uname
			temTab.fight_force = listData[i].fight_force
			temTab.state = listData[i].state
			temTab.htid = listData[i].htid
			table.insert(retData,temTab)
		end
	end

	return retData
end








































