-- Filename: GuildTeamData.lua
-- Author: zhang zihang
-- Date: 2013-12-22
-- Purpose: 该文件用于: 军团副本的数据

module ("GuildTeamData", package.seeall)


require "db/DB_Legion_copy"
require "db/DB_Copy_team"
require "script/ui/guild/GuildDataCache"
require "script/model/user/UserModel"
require "script/ui/copy/CopyUtil"


local _copyTeamInfo		= {}			-- 组队副本信息

local _hallInfo = {}					-- 大厅信息

-- 获得组队副本信息
local function getCopyTeamInfo( )
	return _copyTeamInfo
end

function setCopyTeamInfo(copyInfo )
	_copyTeamInfo=copyInfo
end

-- 获得大厅的信息
function getHallInfo( )
	return _hallInfo
end

-- 设置大厅的信息
function sethallInfo( hallInfo)
	_hallInfo= hallInfo
end


-- 得到本周剩余的军团副本攻击次数
function getLeftGuildAtkNum( )
	if(table.isEmpty( _copyTeamInfo)) then
		return 0
	end
	local leftNum = tonumber(_copyTeamInfo.guild_atk_num)
	return leftNum
end

-- 修改军团副本的攻击次数
function addGuildAtkNum( num)
	_copyTeamInfo.guild_atk_num= tonumber( _copyTeamInfo.guild_atk_num) + num 
end

-- 得到军团协助副本次数
function getLeftHelpGuildNum()
	if(table.isEmpty(_copyTeamInfo)) then
		return 0
	end

	local guild_help_num =tonumber(_copyTeamInfo.guild_help_num)
	local legionCopy= DB_Legion_copy.getDataById(1)
	local leftHelpNum = legionCopy.helpNum - guild_help_num

	return leftHelpNum
end

-- 得到组队次数
function getBuyAtkNum(  )
	return _copyTeamInfo.buy_atk_num or 0
end

function addBuyAtkNum( num )
	 _copyTeamInfo.buy_atk_num= tonumber(_copyTeamInfo.buy_atk_num)+ tonumber(num)  
end


--[[
	@desc	获得军团副本的ID 和需要军团的限制等级

	@para 	
	@return table{copyId= , needGuildLevel="",}
--]]
function getGuildCopyIds(  )
	
	local legionCopy= DB_Legion_copy.getDataById(1)
	teamCopyIds = lua_string_split(legionCopy.teamCopy,",")

	local teamCopy = {}
	for i=1, #teamCopyIds do
		local tempTable = lua_string_split(teamCopyIds[i] ,"|")
		local tmpCopy = {}
		tmpCopy.needGuildLevel = tonumber(tempTable[1]) 
		tmpCopy.copyId= tonumber(tempTable[2]) 

		table.insert(teamCopy, tmpCopy)
	end

	return teamCopy

end

--[[
	@desc	得到组队军团副本的数据，
			最大的一个是未开启的副本
	
	@return table {copyId= , needGuildLevel="",}
--]]
function getCopyTeamData(  )
	local teamCopy = getGuildCopyIds()
	-- print("teamCopy  is : ")
	-- print_t(teamCopy)
	local teamCopyData= {}
	for i=1, #teamCopy do
		local tmpCopyData= {}
		if(isGuildCopyOpen(teamCopy[i]) )then
			tmpCopyData = DB_Copy_team.getDataById(teamCopy[i].copyId)
			tmpCopyData.needGuildLevel = teamCopy[i].needGuildLevel
			tmpCopyData.isGray= false
			table.insert(teamCopyData , tmpCopyData)
		else
			tmpCopyData = DB_Copy_team.getDataById(teamCopy[i].copyId)
			tmpCopyData.needGuildLevel = teamCopy[i].needGuildLevel
			tmpCopyData.isGray= true
			table.insert(teamCopyData , tmpCopyData)
			break
		end
		
	end
	
	return teamCopyData

end

-- 通过组队副本id ，判断军团副本是否开启
-- 1，当副本id< cur_guild_copy 时 ，开启
-- 2, 当副本id== cur_guild_copy时，四个条件： 玩家的等级>= levelLimit , 
-- 3
function isGuildCopyOpen(teamCopy )
	local copyId = tonumber(teamCopy.copyId) 
	print("copyId is : ", copyId)
	local needGuildLevel = tonumber(teamCopy.needGuildLevel)

	local copyData = DB_Copy_team.getDataById(copyId)
	local needPassCopy= tonumber(copyData.needPassCopy)

	if(tonumber(copyId)< tonumber(_copyTeamInfo.cur_guild_copy)) then
		return true
	elseif(tonumber(copyId)==tonumber(_copyTeamInfo.cur_guild_copy)) then
		if(UserModel.getHeroLevel() >= tonumber(copyData.levelLimit) and GuildDataCache.getCopyHallLevel()>= needGuildLevel and tonumber( CopyUtil.getLastPassedCopyId()) >= needPassCopy) then
			return true
		else
			return false
		end
	else
		return false
	end

end

-- 通过组队副本id ，获得当前已有的副本人数
function getTeamNumByCopyId( copyId)

	if(copyId== nil) then
		return 0
	end
	for i=1, table.count(_hallInfo.arrRoom) do
		if(tonumber(copyId) == tonumber( _hallInfo.arrRoom[i].id )) then
			return tonumber(_hallInfo.arrRoom[i].teamNum) 
		end
	end
	return 0

end

-- 通过副本id, 获得当前副本的teamLimit
function getTeamLimitById( copyId)
	local copyData = DB_Copy_team.getDataById(tonumber(copyId))

	local copyLimit= lua_string_split(copyData.teamLimit ,",")

	return tonumber(copyLimit[1])

end


-- 得到通过条件的字符
function getOpenStr(teamCopyInfo)
	local conditionStr = ""

	print("teamCopyInfo  is : ")
	print_t(teamCopyInfo)
	local needGuildLevel = tonumber(teamCopyInfo.needGuildLevel)
	local needPassCopy= tonumber(teamCopyInfo.needPassCopy)
	local lastPassedCopyId= tonumber(CopyUtil.getLastPassedCopyId())
	local cur_guild_copy = tonumber(_copyTeamInfo.cur_guild_copy)

	if( teamCopyInfo.levelLimit>UserModel.getHeroLevel() )then
		conditionStr = GetLocalizeStringBy("key_1130") .. teamCopyInfo.levelLimit .. GetLocalizeStringBy("key_2618")
	elseif(  GuildDataCache.getCopyHallLevel()< needGuildLevel) then
		conditionStr = GetLocalizeStringBy("key_2035") .. needGuildLevel .. GetLocalizeStringBy("key_2618")
	elseif(lastPassedCopyId< needPassCopy ) then
		require "db/DB_Copy"
		local copy_info = DB_Copy.getDataById(needPassCopy)
		conditionStr = GetLocalizeStringBy("key_2125") .. copy_info.name
	elseif(teamCopyInfo.id > cur_guild_copy) then
		local needPassTeamCopy=  teamCopyInfo.needPassTeamCopy
		if(needPassTeamCopy== nil) then
			return GetLocalizeStringBy("key_3292")
		end
		local copyDesc = DB_Copy_team.getDataById( tonumber(teamCopyInfo.needPassTeamCopy))
		conditionStr = GetLocalizeStringBy("key_2561") .. copyDesc.name
	else
		print(GetLocalizeStringBy("key_3002"))
		conditionStr= GetLocalizeStringBy("key_1452")
	end
	return conditionStr
end

-- 判断军团副本是否已经同通关
function isGuildCopyPass(teamCopyInfo)
	if(  teamCopyInfo.id >tonumber(_copyTeamInfo.va_copy_team.cur_passed_guild_copy)) then
		return false
	else
		return true
	end
end


--通过副本id 获得物品的信息
function getCopyItemsById(copyId )
	local copyInfo = DB_Copy_team.getDataById(tonumber(copyId))
	local strongHold= tonumber(copyInfo.strongHold)
	local holdInfo= DB_Stronghold.getDataById(strongHold)
	local itemTable = lua_string_split(holdInfo.reward_item_id_simple,",")
	local items= {}
	for i=1, #itemTable do 
		local item = {}
		local tempTable = lua_string_split(itemTable[i], "|")
		item.num =1
		item.tid = tonumber(tempTable[1])
		item.type = "item"
		item.desc=  tempTable[2]
		table.insert( items , item)
	end

	return items
end


