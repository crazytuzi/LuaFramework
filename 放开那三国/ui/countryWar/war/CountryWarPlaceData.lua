-- FileName: CountryWarPlaceData.lua 
-- Author: licong 
-- Date: 15/11/12 
-- Purpose: 主战场数据


module("CountryWarPlaceData", package.seeall)

------------------------------[[ 模块变量 ]]------------------------------
local _warBattleInfo 								= {}
local _battleReportInfo 							= {}
local _goBattleTime 								= 0 	--玩家从传送阵出阵时间
local _userUuid 									= nil  	-- 玩家的uuid

--[[
	@des 	: 初始化
	@param 	: 
	@return : 
--]]
function init( ... )
	_warBattleInfo 								= {}
	_battleReportInfo 							= {}
	_goBattleTime 								= 0 
end

--[[
	@des 	: 设置战场信息
	@param 	: 
	@return : 
--]]
function setEnterInfo( p_info )
	convertData(p_info)
	table.paste(_warBattleInfo, p_info)
	-- print("_warBattleInfo==>")
	print_t(_warBattleInfo)
end

--[[
	@des 	: 得到战场信息
	@param 	: 
	@return : 
--]]
function getEnterInfo( ... )
	return _warBattleInfo
end

--[[
	@des 	: 转换战场信息
	@param 	: 
	@return : 
--]]
function convertData( p_dataInfo )
	p_dataInfo.field.road = p_dataInfo.field.road or {}
	
	--将数组类型的road 替换成id 
	local temTab = {}
	for k,v_player in pairs(p_dataInfo.field.road) do
		temTab[v_player.id] = v_player
	end
	p_dataInfo.field.road = temTab

	-- 将touchdown的数组类型替换成id
	p_dataInfo.field.touchdown = p_dataInfo.field.touchdown or {}
	for i=1,#p_dataInfo.field.touchdown do
		local v = p_dataInfo.field.touchdown[i]
		p_dataInfo.field.touchdown[i] = v.id
	end
	-- 转换level数据
	p_dataInfo.field.leave = p_dataInfo.field.leave or {}
	for i=1,#p_dataInfo.field.leave do
		local v = p_dataInfo.field.leave[i]
		p_dataInfo.field.leave[i] = v.id
	end
end

--[[
	@des : 得到后端路线逻辑长度
	@param 	: 
	@return :
--]]
function getServerRoadLength( p_roadId )
	local roadLength = _warBattleInfo.field.roadLength[tonumber(p_roadId)]
	return tonumber(roadLength)
end

--[[
	@des 	: 刷新玩家信息
	@param 	: 
	@return :
--]]
function refreshBattleInfo( p_refreshInfo )
	convertData(p_refreshInfo)
	table.paste(_warBattleInfo, p_refreshInfo) 
	-- print("refreshBattleInfo")
	-- print_t(_warBattleInfo)

	--先标记为要清楚数据，延迟1秒后删除
	for k,v in pairs(_warBattleInfo.field.road) do
		--清除达阵玩家数据
		for touchKey,touchValue in pairs(_warBattleInfo.field.touchdown) do
			if _warBattleInfo.field.road[touchValue] ~= nil then
				_warBattleInfo.field.road[touchValue].exit = 1
			end
		end
		--清除掉线玩家数据
		for levelKey,levelValue in pairs(_warBattleInfo.field.leave) do
			if _warBattleInfo.field.road[levelValue] ~= nil then
				_warBattleInfo.field.road[levelValue].exit = 1
			end
		end
	end
	performCallfunc(function ( ... )
		--清楚数据
		_warBattleInfo.field = _warBattleInfo.field or {}
		_warBattleInfo.field.road = _warBattleInfo.field.road or {}
		for k,v in pairs(_warBattleInfo.field.road) do
			if(v.exit == 1) then
				_warBattleInfo.field.road[k] = nil
			end
			--清除达阵玩家数据
			for touchKey,touchValue in pairs(_warBattleInfo.field.touchdown) do
				_warBattleInfo.field.road[touchValue] = nil
			end
			--清除掉线玩家数据
			for levelKey,levelValue in pairs(_warBattleInfo.field.leave) do
				_warBattleInfo.field.road[levelValue] = nil
			end
		end
	end, 1)
end

--[[
	@des: 得到在路上的玩家信息
--]]
function getRoadPlayerInfo( p_playerId )
	local retData = nil
	for k,v in pairs(_warBattleInfo.field.road) do
		if tonumber(k) == tonumber(p_playerId) then
			retData = v
			break
		end
	end
	return retData
end

--[[
	@des 	: 设置可以参战cd
	@param 	: 
	@return :
--]]
function setCanJoinTime( p_time )
	_warBattleInfo.user.canJoinTime = p_time 
end

--[[
	@des 	: 得到可以参战cd
	@param 	: 
	@return :
--]]
function getCanJoinTime( ... )
	-- body
	_warBattleInfo.user.canJoinTime = _warBattleInfo.user.canJoinTime or 0
	_warBattleInfo.user.readyTime = _warBattleInfo.user.readyTime or 0
	return math.max(tonumber(_warBattleInfo.user.canJoinTime), tonumber(_warBattleInfo.user.readyTime))
end

--[[
	@des 	: 得到路的状态
	@param 	: 通道状态，1 代表目前属于较少通道 2 代表目前属于较多通道 默认较少
	@return :
--]]
function getReadState()
	local roadState = _warBattleInfo.field.roadState or 1 
	return tonumber(roadState)
end

--[[
	@des 	: 得到退出战场 参战cd
	@param 	:
	@return :
--]]
function getQuitReadyTime( ... )
	_warBattleInfo.user.readyTime = _warBattleInfo.user.readyTime or 0 
	return tonumber(_warBattleInfo.user.readyTime)
end

--[[
	@des: 判断玩家是不是攻击者
--]]
function isUserAttacker()
	local retData = false
	if( tonumber(_warBattleInfo.user.groupId) == 1)then 
		retData = true
	else
		retData = false
	end
	return retData
end

--[[
	@des: 设置用户出阵时间
--]]
function setUserGoBattleTime( p_time )
	_goBattleTime = tonumber(p_time)
end

--[[
	@des: 得到玩家从传送阵出阵时间
--]]
function getUserGoBattleTime( p_time )
	return tonumber(_goBattleTime)
end

--[[
	@des: 设置用户的uuid
--]]
function setUserUuid( p_uuid )
	_userUuid = p_uuid
end

--[[
	@des: 得到玩家从传送阵出阵时间
--]]
function getUserUuid()
	return _userUuid
end

--[[
	@des :得到传送阵中玩家数量
--]]
function getTranferPlayerNum( p_tranferId )
	local retNum = 0  
	if( isUserAttacker() )then
		retNum = tonumber(_warBattleInfo.field.transfer[p_tranferId])
	else
		local temTranferId = nil
		if( p_tranferId > 4 )then
			temTranferId = p_tranferId - 4
		else
			temTranferId = p_tranferId + 4
		end
		retNum = tonumber(_warBattleInfo.field.transfer[temTranferId])
	end
	return retNum
end

--[[
	@des: 得到准备时间
--]]
function getReadyTime( ... )
	local time = tonumber(_warBattleInfo.readyDuration) - tonumber(_warBattleInfo.field.pastTime) 
	if time < 0 then
		time = 0
	end
	return  time
end


--[[
	@des: 得到下方的势力名字，总人数，参战人数，资源数量  我所在的一方
	 		groupId : "1"
     		groupName : "attacker"
            totalMemberCount : "1"
            memberCount : "1"
            resource : "998"
--]]
function getOneCountryInfo( ... )
	local retData = {}
	if( isUserAttacker() )then
		retData.groupId 				= _warBattleInfo.attacker.groupId
		retData.groupName 				= _warBattleInfo.attacker.groupName
		retData.totalMemberCount 		= _warBattleInfo.attacker.totalMemberCount
		retData.memberCount 			= _warBattleInfo.attacker.memberCount
		retData.resource 				= _warBattleInfo.attacker.resource
	else
		retData.groupId 				= _warBattleInfo.defender.groupId
		retData.groupName 				= _warBattleInfo.defender.groupName
		retData.totalMemberCount 		= _warBattleInfo.defender.totalMemberCount
		retData.memberCount 			= _warBattleInfo.defender.memberCount
		retData.resource 				= _warBattleInfo.defender.resource
	end
	return retData
end

--[[
	@des: 得到上方的势力名字，总人数，参战人数，资源数量  敌对的一方
	 		groupId : "1"
     		groupName : "attacker"
            totalMemberCount : "1"
            memberCount : "1"
            resource : "998"
--]]
function getTwoCountryInfo( ... )
	local retData = {}
	if( isUserAttacker() )then
		retData.groupId 				= _warBattleInfo.defender.groupId
		retData.groupName 				= _warBattleInfo.defender.groupName
		retData.totalMemberCount 		= _warBattleInfo.defender.totalMemberCount
		retData.memberCount 			= _warBattleInfo.defender.memberCount
		retData.resource 				= _warBattleInfo.defender.resource
	else
		retData.groupId 				= _warBattleInfo.attacker.groupId
		retData.groupName 				= _warBattleInfo.attacker.groupName
		retData.totalMemberCount 		= _warBattleInfo.attacker.totalMemberCount
		retData.memberCount 			= _warBattleInfo.attacker.memberCount
		retData.resource 				= _warBattleInfo.attacker.resource
	end
	return retData
end

--[[
	@des 	: 战场结束时间
	@param 	: 
	@return :
--]]
function getBattleEndTime()
	return tonumber(_warBattleInfo.field.endTime)
end

--[[
	@des 	: 得到自动回血的状态
	@param 	: 
	@return :1开启 2关闭 默认关闭
--]]
function getAutoRecoverState()
	return tonumber(_warBattleInfo.user.extra.info.auto_recover)
end

--[[
	@des 	: 设置自动回血的状态
	@param 	: p_state  1开启 2关闭 默认关闭
	@return :
--]]
function setAutoRecoverState( p_state )
	_warBattleInfo.user.extra.info.auto_recover = p_state
end

--[[
	@des 	: 判断下一次自动回血是否满足
	@param 	: 
	@return : 
--]]
function judgeNextAutoRecoveryBlood( ... )
	require "script/ui/countryWar/encourage/CountryWarEncourageData"
	local curHaveCocoin = CountryWarMainData.getCocoin()
	local needCocoin = CountryWarEncourageData.getRecoveryBloodCost()
	if curHaveCocoin < needCocoin then
		-- 取消自动勾选的状态
        setAutoRecoverState(false)
	end
end

--[[
	@des 	: 得到自动回血的点 以10000为基数的百分比
	@param 	: 
	@return :
--]]
function getAutoRecoverPoint()
	return tonumber(_warBattleInfo.user.extra.info.recover_percent)/10000*100
end

--[[
	@des 	: 得到自动回血的点 以10000为基数的百分比
	@param 	: p_point
	@return :
--]]
function setAutoRecoverPoint( p_point )
	_warBattleInfo.user.extra.info.recover_percent = p_point
end

--[[
	@des 	: 得到自己在路上的数据
	@param 	: 
	@return :
			{	id : "10629"
               	name : "777"
              	tid : "20105"
               	transferId : "0"
               	maxHp : "4705912"
               	speed : "1"
               	roadX : "0"
               	stopX : "10000"
                curHp : "4705912"
                winStreak : "0" }
--]]
function getUserInfoOnRoad()
	local retData = nil
	local myUUid = getUserUuid() 
	if( not table.isEmpty(_warBattleInfo.field.road) )then
		retData = _warBattleInfo.field.road[myUUid]
	end
	return retData
end

--[[
	@des 	: 手动回血数据
	@param 	: 
	@return :
--]]
function setUserRecoverOnRoad()
	local myUUid = getUserUuid() 
	if( not table.isEmpty(_warBattleInfo.field.road[myUUid] ) )then
		_warBattleInfo.field.road[myUUid].curHp = _warBattleInfo.field.road[myUUid].maxHp
	end
end

--[[
	@des 	: 得到加入传送阵获得积分
	@param 	:
	@return :
--]]
function getJoinPoint()
	require "db/DB_National_war"
	local data = DB_National_war.getDataById(1)
	return tonumber(data.enter_point)
end

--[[
	@des 	: 得到达阵获得积分
	@param 	:
	@return :
--]]
function getTouchDownPoint()
	require "db/DB_National_war"
	local data = DB_National_war.getDataById(1)
	return tonumber(data.reach_point)
end

--[[
	@des 	: 得到初始资源
	@param 	:
	@return :
--]]
function getBeginResource()
	require "db/DB_National_war"
	local data = DB_National_war.getDataById(1)
	return tonumber(data.final_resource)
end

--[[
	@des 	: 得到资源百分比 
	@param 	:
	@return : 0-1
--]]
function getResourcePercent( p_num )
	local beginNum = getBeginResource()
	return tonumber(p_num)/(beginNum*2)
end

--[[
	@des 	: 得到可以参加决赛的排名
	@param 	:
	@return :
--]]
function getCanJoinFinalsRank()
	require "db/DB_National_war"
	local data = DB_National_war.getDataById(1)
	return tonumber(data.final_num)
end

--[[
	@des 	: 得到攻击鼓舞等级
	@param 	:
	@return :
--]]
function getAttkackLevel()
	return tonumber(_warBattleInfo.user.extra.info.attackLevel)
end

--[[
	@des 	: 得到离场强制cd
	@param 	:
	@return :
--]]
function getOutCd()
	require "db/DB_National_war"
	local data = DB_National_war.getDataById(1)
	return tonumber(data.cd)
end

--[[
	@des 	: 得到击杀活的的积分
	@param 	: p_num 击杀数
	@return :
--]]
function getKillPoint( p_num )
	require "db/DB_National_war"
	local data = DB_National_war.getDataById(1)
	local strTab = string.split(data.kill_point, ",") 
	local retNum = 0
	for i=1,#strTab do
		local temTab = string.split(strTab[i], "|") 
		if( tonumber(p_num) >= tonumber(temTab[1]) )then
			retNum = tonumber(temTab[2])
		end
	end
	return retNum
end


--[[
	@des 	: 得到终结击杀活的的积分
	@param 	: p_num 终结击杀数
	@return :
--]]
function getEndKillPoint( p_num )
	require "db/DB_National_war"
	local data = DB_National_war.getDataById(1)
	local strTab = string.split(data.end_point, ",") 
	local retNum = 0
	for i=1,#strTab do
		local temTab = string.split(strTab[i], "|") 
		if( tonumber(p_num) >= tonumber(temTab[1]) )then
			retNum = tonumber(temTab[2])
		end
	end
	return retNum
end


------------------------------------------------------------------- 战报推送相关 -----------------------------------------------------------------------------
--[[
	@des 	: 清除玩家
	@param 	: 
	@return :
--]]
function clearPlayInfoById( p_playerId )
	for k,v in pairs(_warBattleInfo.field.road) do		
		if(tonumber(v.id) == tonumber(p_playerId)) then
			_warBattleInfo.field.road[tostring(k)] = nil
			-- print("addReportInfo clear lose player id =",k )
			break
		end
	end
end

--[[
	@des 	: 增加战报数据
	@param 	: 
	@return :
--]]
function addReportInfo( p_battleInfo )
	--增加战报数据
	table.insert(_battleReportInfo,p_battleInfo)
	--清除战败玩家在场数据
	local loserId = p_battleInfo.loserId
	local winnerId = p_battleInfo.winnerId
	performCallfunc(function ( ... )
		clearPlayInfoById(loserId)
		if p_battleInfo.winnerOut == "true" then
			clearPlayInfoById(winnerId)
		end
	end, 0.5)
	-- printTable("addReportInfo", _robBattleInfo)
end

------------------------------------------------------------------- 排行榜相关 -----------------------------------------------------------------------------

--[[
	@des 	: 得到排行榜
	@param 	: 
	@return :
--]]
function getRankInfo( p_rankInfo )
	local retData = p_rankInfo
	for i=1,#retData do
		retData[i].rank = i
	end
	return retData
end

--[[
	@des 	: 得到排行榜
	@param 	: 
	@return :
--]]
function getMyRankInfo( p_rankInfo )
	local retData = nil
	local myUUid = getUserUuid()
	for i=1,#p_rankInfo do
		if( tonumber(myUUid) == tonumber(p_rankInfo[i].uuid) )then
			retData = p_rankInfo[i]
			break
		end
	end
	return retData
end

--[[
	@des 	: 得到排名奖励
	@param 	: p_type 1初赛，2决赛，p_rank排名
	@return :
--]]
function getRankReward( p_type, p_rank )
	require "db/DB_National_war_reward"
	local rewardTab = {}
	for k,v in pairs(DB_National_war_reward.National_war_reward) do
		local temData = DB_National_war_reward.getDataById(v[1])
		if( tonumber(temData.first_final) == p_type )then
			table.insert(rewardTab,temData)
		end
	end
	local rewardStr = nil
	for i=1,#rewardTab do
		local curData = rewardTab[i]
		if( tonumber(curData.num1) <= tonumber(p_rank) and tonumber(curData.num2) >= tonumber(p_rank) )then
			rewardStr = curData.reward
			break
		end
	end

	local retData = ItemUtil.getItemsDataByStr(rewardStr)
	return retData
end

------------------------------------------------------------- 登陆跨服是否成功 ------------------------------------------------------------------------
local _loginInfo = nil
--[[
	@des 	: 设置是否登陆成功
	@param 	: 
	@return :
--]]
function setLoginCrossData( p_data )
	_loginInfo = p_data
end

--[[
	@des 	: 是否登陆成功 
	@param 	: 
	@return :
--]]
function isLoginCrossOK()
	if table.isEmpty(_loginInfo) then
		return false
	end

	if _loginInfo.err ~= "ok" then
		return false
	end

	if table.isEmpty(_loginInfo.ret) then
		return false
	end

	if _loginInfo.ret.ret ~= "ok" then
		return false
	end
	return true
end




