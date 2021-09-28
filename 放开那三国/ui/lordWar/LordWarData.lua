-- Filename: LordWarData.lua
-- Author: lichenyang
-- Date: 2014-08-14
-- Purpose: 个人跨服赛数据层

module("LordWarData", package.seeall)

require "db/DB_Kuafu_challengereward"
require "db/DB_Kuafu_personchallenge"
require "script/utils/LuaUtil"
require "script/model/utils/ActivityConfigUtil"
require "script/utils/TimeUtil"


local _cheerRewards        = nil       -- 助威奖励

-- 模块全局常量
kWinLordType 			= 1001 -- 傲视群雄组
kLoseLordType 			= 1002 -- 初出茅庐组

-- 玩家状态定义
kUserInitial      	= 0 -- 初始状态 
kUserFail 			= 1 -- 淘汰状态
kUserWin 			= 2 -- 晋级状态

-- 服内or跨服Type
kInnerType 			= 101 -- 服内标识
kCrossType 			= 102 -- 跨服标识
---------------------------------------[[ 阶段定义 ]]------------------------------
kOutRange 			= 0 	--不在活动期间
kBlank 				= 1 	--活动期间的非round时间
kRegister			= 2   	--报名
kInnerAudition		= 3 	--服内海选赛
kInner32To16		= 4
kInner16To8			= 5
kInner8To4			= 6
kInner4To2			= 7
kInner2To1 			= 8
kCrossAudition      = 9		--跨服海选赛
kCross32To16 		= 10
kCross16To8  		= 11
kCross8To4 			= 12
kCross4To2 			= 13
kCross2To1 			= 14

--阶段状态
kRoundNo			= 0 		--异常状态
kRoundPrepare		= 10
kRoundFighting		= 20
kRoundFighted		= 30
kRoundReward		= 40
kRoundEnd			= 100
----------------------------------------[[ 排名定义 ]]----------------------------
kRank32				= 32
kRank16				= 16
kRank8				= 8
kRank4				= 4
kRank2				= 2
kRank1				= 1

local _promotionInfo 		= nil   		-- 后端晋级赛原始数据
local _processPromotionInfo = nil   		-- 晋级赛处理后数据
local _lordInfo 			= {}         	-- 
local _curMinRank         = nil             -- 当前最小的排名
local _templeInfo 			= {}			-- 上届冠军
local _is_32                                -- 是否是32强以上
local _myInfo               = nil           -- 自己的排名信息
local _isShowWinEffect   = false         -- 是否播放胜利特效


--[[
	@des:显示小红点
--]]
function isShowRedTip()
	if ActivityConfigUtil.isActivityOpen("lordwar") == false then
		return false
	end
	--检查报名等级
	if(UserModel.getHeroLevel() < LordWarData.getRegisgterLevel()) then	
		return false
	end
	require "script/ui/lordWar/LordWarMainLayer"
	if LordWarMainLayer.getIsEneter() then
		return false
	else
		local time = TimeUtil.getSvrTimeByOffset()
		local bTime = getRoundStartTime(kRegister)
		local eTime = getRoundEndTime(kRegister)
		if time > bTime and time < eTime then
			if getLordIsOk() and not isRegister() then
				return true
			end
		end
		return false
	end
end

--[[
    @des: 得到是否播放特效
--]]
function isShowWinEffect()
    return _isShowWinEffect
end

--[[
    @des: 设置是否播放特效
--]]
function setShowWinEffect(showWinEffect)
    _isShowWinEffect = showWinEffect
end

--得到上届冠军信息
function getTempleInfo( ... )
	return _templeInfo
end

--得到上届冠军信息
function setTempleInfo( p_data )
	_templeInfo = p_data
    for k, v in pairs(_templeInfo) do
        v.fightForce = tostring(tonumber(v.fightForce))
    end
end

-- 得到第几届
function getLordWarNum()
    return (tonumber(ActivityConfigUtil.getDataByKey("lordwar").data[1].num) -1)
end

function getRefreshFightValueCD()
    return tonumber(ActivityConfigUtil.getDataByKey("lordwar").data[1].cd)
end


function getHeroDatas()
    return _hero_datas
end

--[[
	@des  : 得到ui显示位置 
	@parm : p_rank 玩家排名
	@parm : p_serverPos 后端比赛位置
	@ret  : 1-32
--]]
function getUiPos( p_rank, p_serverPos )
	local uiPos = math.ceil((p_serverPos)/(32/p_rank))
	return uiPos
end

--[[
	@des 	:得到阶段对应的排名
	@param 	:p_round 阶段编号
	@param 	:p_roundStatus 阶段状态
--]]
function getRoundRank( p_round, p_roundStatus )
	local rankTable = {}
    rankTable[kInnerAudition] = 32
    rankTable[kCrossAudition] = 32
	rankTable[kInner32To16] = 32
	rankTable[kInner16To8]  = 16
	rankTable[kInner8To4]   = 8
	rankTable[kInner4To2]   = 4
	rankTable[kInner2To1]   = 2
	rankTable[kCross32To16] = 32
	rankTable[kCross16To8]  = 16
	rankTable[kCross8To4]   = 8
	rankTable[kCross4To2]   = 4
	rankTable[kCross2To1]   = 2

	if(p_round == kCross2To1 and p_roundStatus == kRoundEnd) then
		rankTable[kCross2To1]   = 1
	end
	if(p_round == kInner2To1 and p_roundStatus == kRoundEnd) then
		rankTable[kInner2To1]   = 1
	end
	if(p_round == kInnerAudition and p_roundStatus == kRoundFighted) then
		rankTable[kInnerAudition]   = 32
	end
	-- if(p_round == kCrossAudition and p_roundStatus == kRoundFighted) then
	-- 	rankTable[kCrossAudition]   = 32
	-- end
	-- if(p_round == kCross8To4 and p_roundStatus == kRoundFighted) then
	-- 	rankTable[kCross8To4]   = 4
	-- end
	-- if(p_round == kInner8To4 and p_roundStatus == kRoundFighted) then
	-- 	rankTable[kInner8To4]   = 4
	-- end
	return rankTable[p_round] or 0
end

--[[
	@des 	:得到阶段对应的编号
	@param 	:p_roundRank 阶段排名 p_InnerOrCross 服内 or 跨服
	@param 	:
--]]
function getRoundByRoundRank( p_roundRank, p_InnerOrCross )
	local innerTable = {}
	innerTable[kRank32]  = kInner32To16
	innerTable[kRank16]  = kInner16To8
	innerTable[kRank8]   = kInner8To4
	innerTable[kRank4]   = kInner4To2
	innerTable[kRank2]   = kInner2To1
	local crossTable = {}
	crossTable[kRank32]  = kCross32To16
	crossTable[kRank16]  = kCross16To8
	crossTable[kRank8]   = kCross8To4
	crossTable[kRank4]   = kCross4To2
	crossTable[kRank2]   = kCross2To1

	local curRound = getCurRound()
    local retData = nil
	if(curRound >= LordWarData.kInnerAudition and curRound <=LordWarData.kInner2To1) then
		-- 服内
		retData = innerTable[p_roundRank]
	elseif(curRound >= LordWarData.kCrossAudition and curRound <=LordWarData.kCross2To1) then
		-- 跨服
		retData = crossTable[p_roundRank]
	end

	-- 回顾历史 p_InnerOrCross
	if(p_InnerOrCross ~= nil)then
		if( p_InnerOrCross == kInnerType)then
			-- 服内
			retData = innerTable[p_roundRank]
		elseif( p_InnerOrCross == kCrossType)then
			-- 跨服
			retData = crossTable[p_roundRank]
		else
			print("erro p_InnerOrCross")
		end
	end
	return retData
end

--[[
	@des 	: 得到是否在服内
	@param 	: p_showTpye:回顾类型
	@return : true 在服内
--]]
function isInInner( p_showTpye )
	local retData = false
	if(p_showTpye == nil)then
		local curRound = getCurRound()
		if curRound <=LordWarData.kInner2To1 then
			retData = true
		end
	else
		if(p_showTpye == kInnerType)then
			retData = true
		end
	end
	return retData
end

--[[
	@des 	: 处理各阶段比赛数据
	@param 	: p_Data:后端返回晋级赛原始数据
	@return : table:{   //key=>number                        
						uiPos=>table{ 
							//32个人的信息，32条数据，每条中包含当前名次，每次战斗对手信息和结果
							uiPos=> table{ key=>string
									uname => ,
									htid => ,
									vip => ,
									dress =>,
									serverName => ,
									rank => ,
									fightForce =>,
									userStatus =>  玩家状态  kUserInitial:初始,kUserFail:淘汰,kUserWin:晋级
									serverPos => 服务器位置
									serverId=>
								}
							}
						}
--]]

--[[
    @des 获取当前最小排名
--]]
function getCurMinRank()
    return _curMinRank
end

--[[
    @des 初始化当前最小排名
--]]
function initCurMinRank(p_data)
    for k, v in pairs(p_data) do
        if v.pid ~= "0" then
            local rank = tonumber(v.rank)
            if rank < _curMinRank then
                _curMinRank = rank
            end
        end
    end
end

--[[
    @des: 是否是32
--]]
function is32()
    return _is_32
end

function processPromotionInfoFun( p_Data, p_InnerOrCross)
	local retTable = {}
	-- 得到当前阶段
	local curRound = getCurRound()
	local curStatus= getCurRoundStatus() 
	-- 当前阶段的排名
    initCurMinRank(p_Data)
	local cur_min_rank = getCurMinRank()
    if cur_min_rank ~= 1 then
        local roundByRank = getRoundByRoundRank(cur_min_rank, p_InnerOrCross)
        print("roundByRank=", roundByRank, cur_min_rank, p_InnerOrCross)
        if curRound < roundByRank - 2
            or (curRound == roundByRank - 1 and curStatus < kRoundFighted) then
            cur_min_rank = cur_min_rank * 2
        end
    end
    -- todo test
    --curRoundRank = 4
    --
	for k,v in pairs(p_Data) do
		if(tonumber(v.pid) ~= 0) then
            v.fightForce = tostring(tonumber(v.fightForce))
            local is_me = nil
            if v.serverId == getMyServerId() and v.uid == tostring(UserModel.getUserUid()) then
                _is_32 = true
                _myInfo = v
            end
            if tonumber(v.rank) < cur_min_rank then
                v.rank = cur_min_rank
            end
		    local cur_rank = tonumber(v.rank)
		    while cur_rank <= 32 do
		    	local temp = table.hcopy(v, {})
				if(tonumber(temp.rank) < cur_rank )then
					-- 晋级
					temp.userStatus = kUserWin
				elseif tonumber(temp.rank) > cur_rank * 0.5 and cur_rank > cur_min_rank then
					-- 淘汰
					temp.userStatus = kUserFail
				else
					-- 初始
					temp.userStatus = kUserInitial
				end
				if(retTable[cur_rank] == nil)then
					retTable[cur_rank] = {}
				end
				-- 服务器位置
				temp.serverPos = tonumber(k)
				-- ui位置
				local uiPos = getUiPos( cur_rank, temp.serverPos )
				retTable[cur_rank][uiPos] = temp
		        cur_rank = cur_rank * 2
		    end
		end
	end
    print("retTable=")
    print_t(retTable)
	return retTable
end

--[[
	@des 	: 处理各阶段比赛数据
	@param 	: 
	@return : table:{                         
						winLord=>table{ //傲视群雄组 key=>number
							32=>table{ 
								//32个人的信息，32条数据，每条中包含当前名次，每次战斗对手信息和结果
								uiPos=> table{ //key=>string
										uname => ,
										htid => ,
										vip => ,
										dress =>,
										serverName => ,
										rank => ,
										fightForce =>,
										userStatus =>  玩家状态  kUserInitial:初始,kUserFail:淘汰,kUserWin:晋级
										serverPos => 服务器位置
										serverId=>
									}
								}
							}
						} 
						loseLord=>table{ //初出茅庐组 
							@see winLord
						} 
					}
--]]
function processPromotionInfo(p_InnerOrCross)
	_processPromotionInfo = {}
	_processPromotionInfo.winLord = {}
	_processPromotionInfo.loseLord = {}
    _is_32 = false
    _curMinRank = 32
    _is_in = true
	_processPromotionInfo.winLord = processPromotionInfoFun(_promotionInfo.winLord, p_InnerOrCross)
	_processPromotionInfo.loseLord = processPromotionInfoFun(_promotionInfo.loseLord, p_InnerOrCross)
	-- print("处理后数据")
	-- printTable("处理后数据",_processPromotionInfo)
end

function getMyPageIndex(lord_type)
	local info = nil
	if lord_type == kWinLordType then
		info = _processPromotionInfo.winLord
	else
		info = _processPromotionInfo.loseLord
	end
	local pageIndex = 1
	if info ~= nil and info[32] ~= nil then
		for k, v in pairs(info[32]) do
			if tostring(v.uid) == tostring(UserModel.getUserUid()) then
				pageIndex = math.ceil(k / 8)
				break
			end
		end
	end
	return pageIndex
end

--[[
	@des 	: 处理各阶段比赛数据
	@param 	: p_lordType:组别, p_rank:排名 number, p_uiPos:玩家UI位置 number
	@return : table{ 
					uname => ,
					htid => ,
					vip => ,
					dress =>,
					serverName => ,
					rank => ,
					fightForce =>,
					userStatus =>  玩家状态  kUserInitial:初始,kUserFail:淘汰,kUserWin:晋级
					serverPos => 服务器位置
					serverId=>
				} or nil:表示该位置没有玩家
--]]
function getProcessPromotionInfoBy( p_lordType, p_rank, p_uiPos )
    -- print("getProcessPromotionInfoBy传入参数：", p_lordType, p_rank, p_uiPos)
	local retTable = nil
	if(p_lordType == kWinLordType)then
		if(_processPromotionInfo.winLord[p_rank])then
			retTable = _processPromotionInfo.winLord[p_rank][p_uiPos]
		end
	elseif(p_lordType == kLoseLordType)then
		if(_processPromotionInfo.loseLord[p_rank])then
			retTable = _processPromotionInfo.loseLord[p_rank][p_uiPos]
		end
	else
		print("erro p_lordType in  getProcessPromotionInfoBy")
	end
	return retTable
end

--[[
	@des : 修改晋级赛数据
--]]
function setPromotionInfo( p_promotionInfo, p_InnerOrCross)
	_promotionInfo = p_promotionInfo
	processPromotionInfo(p_InnerOrCross) -- 处理数据
end

----------------------------------------[[ 报名和阶段相关 ]]------------------------------------
--[[
	@des : 得到lord
--]]
function getLordInfo( ... )
	return _lordInfo
end

--[[
	@des : 得到当前服有没有开跨服赛
--]]
function getLordIsOk( ... )
	print("_lordInfo.ret", _lordInfo.ret)
	if not _lordInfo then
		return false
	end 
	if(_lordInfo.ret == "ok") then
		return true
	else
		return false
	end
end

--[[
	@des : 得到自己的server_id
--]]
function getMyServerId( ... )
	return _lordInfo.server_id
end


--[[
	@des : 填充lord
--]]
function setLordInfo( p_lordInfo )
	_lordInfo = p_lordInfo
    if _lordInfo.status ~= nil and tonumber(_lordInfo.status) >= kRoundFighted then
        _lordInfo.subRound = "4"
    end
    _lordInfo.subRound = _lordInfo.subRound or "-1"
    if tonumber(_lordInfo.status) == LordWarData.kRoundFighted then
		LordWarData.setCheerInfo("0", "0")
	end
end

--更改敬酒次数
function addCheerTimes()
	-- body
	_lordInfo.worship_num = _lordInfo.worship_num+1
end


--[[
	@des : 得到服务器列表信息
--]]
function getServerInfo( ... )
	local serverInfo = {}
	for k,v in pairs(_lordInfo.teamInfo) do
		-- serverInfo[k] = v 
		local value = {}
		value.name = v
		value.key  = tonumber(k)
		table.insert(serverInfo, value)
	end

	table.sort( serverInfo, function ( h1, h2 )
		return h1.key < h2.key
	end )
	printTable("serverInfo", serverInfo)
	return serverInfo
end

--[[
	@des : 得到自己的服务器描述
--]]
function getMyServerName( ... )
	local serverName = nil
	if(_lordInfo.server_id ~= nil)then
		serverName = _lordInfo.teamInfo[_lordInfo.server_id]
	end
	return serverName or "nil"
end


-- 获取当前比赛阶段
function getCurRound()
    return tonumber(_lordInfo.round)
    -- test
end


--[[
	@des :更新round和status
--]]
function setCurRound( p_round )
	_lordInfo.round = p_round
end

--[[
	@des : 设置当前状态
--]]
function setCurStatus( p_status )
	_lordInfo.status = p_status
end

--[[
    @des: 设置当前结束轮
--]]
function setCurSubRound(p_subRound)
    _lordInfo.subRound = p_subRound
end

--[[
    @des: 得到当前结束轮
--]]
function getCurSubRound()
    local subRound = tonumber(_lordInfo.subRound)
    if subRound == 4 then
        subRound = -1
    end
    return subRound
end

--[[
	@des :得到当前阶段状态
--]]
function getCurRoundStatus( ... )
	return tonumber(_lordInfo.status)
end

--[[
	@des :得到当前阶段的结束时间
	@ret : int
--]]
function getCurRoundEndTime( ... )
	local curRound = getCurRound()
	local curRoundEndTime =	getRoundEndTime(curRound)
	return curRoundEndTime
end

--[[
  @des: 得到当前阶段的开始时间  
--]]
function getCurRoundStartTime( ... )
	local curRound = getCurRound()
	local curRoundStartTime = getRoundStartTime(curRound)
	return curRoundStartTime
end

--[[
    @des: 得到当前阶段剩余时间
--]]
function getCurRoundRemainTime()
   local endTime = getCurRoundEndTime()
   local curTime = BTUtil:getSvrTimeInterval()
   local remainTime = endTime - curTime
   return remainTime
end
--[[
	@des : 得到某个阶段的开始时间
--]]
function getRoundStartTime( p_round )
	require "script/model/utils/ActivityConfigUtil"
	local data = ActivityConfigUtil.getDataByKey("lordwar").data
	local lastTimeArrConfig = string.split(data[1].lastTimeArr, ",")
	local activityStartTime = tonumber(ActivityConfig.ConfigCache.lordwar.start_time)

	local timeConfig = {}
	timeConfig[kRegister]      = lastTimeArrConfig[1]
	timeConfig[kInnerAudition] = lastTimeArrConfig[2]
	timeConfig[kInner32To16]   = lastTimeArrConfig[3]
	timeConfig[kInner16To8]    = lastTimeArrConfig[4]
	timeConfig[kInner8To4]     = lastTimeArrConfig[5]
	timeConfig[kInner4To2]     = lastTimeArrConfig[6]
	timeConfig[kInner2To1]     = lastTimeArrConfig[7]
	timeConfig[kCrossAudition] = lastTimeArrConfig[8]
	timeConfig[kCross32To16]   = lastTimeArrConfig[9]
	timeConfig[kCross16To8]    = lastTimeArrConfig[10]
	timeConfig[kCross8To4]     = lastTimeArrConfig[11]
	timeConfig[kCross4To2]     = lastTimeArrConfig[12]
	timeConfig[kCross2To1]     = lastTimeArrConfig[13]
	
	local startTimeConfig = string.split(timeConfig[p_round], "|")
	printTable("timeConfig",timeConfig)
	print("activityStartTime:", activityStartTime, "p_round:",p_round)
	local startTime       = activityStartTime + 86400 * tonumber(startTimeConfig[1]) + tonumber(startTimeConfig[2])
	return startTime
end


--[[
	@des : 得到某个阶段的结束时间
--]]
function getRoundEndTime( p_round )
	local data    = ActivityConfigUtil.getDataByKey("lordwar").data[1]
	local endTime = 0
	if(p_round == kRegister) then
		--报名结束时间
		endTime = getRoundStartTime(kRegister) + tonumber(data.applyTime)
	elseif(p_round == kCross2To1) then
		--跨服赛结束时间
		endTime = getRoundStartTime(kCross2To1) + tonumber(data.championLastTime)
	--elseif p_round == kInnerAudition then
        -- 海选结束时间
    --    data.haixuanTime = data.haixuanTime or "20"
    --    endTime = getRoundStartTime(kInnerAudition) + tonumber(data.haixuanTime)
    else
		endTime = getRoundStartTime(p_round + 1) 
	end
	return endTime
end

--[[
	@des : 刷新更新战斗力时间
--]]
function setUpdateInfoTime( p_time )
	_lordInfo.update_fmt_time = tonumber(p_time)
end

--[[
    @des  获取清除CD所需的金币数量
--]]
function getCleanCdGoldCount()
	require "script/model/utils/ActivityConfigUtil"
	local data = ActivityConfigUtil.getDataByKey("lordwar").data[1]
    return  tonumber(data.refreshFightCdCost)
end

--[[
    @des 获取助威的奖励
--]]
function getCheerRewards()
    if _cheerRewards == nil then
        require "script/model/utils/ActivityConfig"
        local data = ActivityConfig.ConfigCache.lordwar.data[1]
        local cheerRewardsDb = string.split(data.cheerReward, ",")
        print("dataReward=", data.cheerReward)
        print_t(cheerRewardsDb)
        local index = 1
        local curRound = getCurRound()
        if curRound >= kCrossAudition then
            index = 2
        end
        
        local cheerRewardDb = string.split(DB_Kuafu_challengereward.getDataById(tonumber(cheerRewardsDb[index])).reward, ",")
        _cheerRewards = ItemUtil.getItemsDataByStr(DB_Kuafu_challengereward.getDataById(tonumber(cheerRewardsDb[index])).reward)
    end
    return _cheerRewards
end

--[[
	@des : 得到报名状态当前
--]]
function isRegister( ... )

	local lastRegisterTime = tonumber(_lordInfo.register_time)
	local registerTime      = getRoundStartTime(kRegister)
	print("registerTime", registerTime)
	print("lastRegisterTime", lastRegisterTime)
	if(lastRegisterTime >= registerTime) then
		return true
	else
		return false
	end
end

--[[
	@des: 修改报名时间
--]]
function setRegisterTime( p_time )
	_lordInfo.register_time = p_time
end


--[[
	@des : 得打主界面的现实状态
        0.报名未开始             -- 报名
		101.报名中已报名          ——报名不可点击，更新战斗信息     
		1.报名中未报名    			——报名
		102.已报名海选中          ——查看，更新战斗信息
		2.未报名海选中            --报名不可点击
		103.已报名已32强 			——进入赛场，我的战绩，更新战斗信息
		3.未报名已32强 			——进入赛场
		104.已报名跨服赛海选中     ——查看战绩, 更新战斗信息，服内战况回顾
		4.已报名跨服赛海选         ——我的战绩 更新战斗力 服内战况回顾
		105.已报名跨服32强        ——查看战绩，更新信息，进入赛场，服内战况回顾
	    5.服内海选战斗结束         ——进入赛场, 服内战况回顾
        8.结束                   --膜拜冠军，服内战况回顾，跨服战况回顾 
--]]
function getMainLayerState( ... )
	local retStatus = nil
	local curTime = BTUtil:getSvrTimeInterval()
    local isRegister = isRegister()
    local curRound = getCurRound()
    local curStatus = getCurRoundStatus()
    local curSubRound = getCurSubRound()
    local isRegisterTag = nil 
    if isRegister == true then
        isRegisterTag = 100
    elseif isRegister == false then
        isRegisterTag = 0
    end
    if curRound == kOutRange then
        retStatus = 0
    elseif curRound == kRegister then
        -- 报名中
        retStatus = isRegisterTag + 1 
    elseif (curTime >= getRoundEndTime(kRegister) and curRound < kInnerAudition)
        or (curRound == kInnerAudition and curStatus < kRoundEnd) then
        -- 报名结束 到 海选结束
        retStatus = isRegisterTag + 2
    elseif curRound < kInner2To1 or (curRound == kInner2To1 and curStatus < kRoundFighted) then
        -- 服内32进1进行中
        retStatus = isRegisterTag + 3
    elseif curRound < kCrossAudition or (curRound == kCrossAudition and curStatus < kRoundEnd) then
        -- 服内比赛结束 到 跨服海选结束
        retStatus = isRegisterTag + 4
    elseif curRound < kCross2To1 or (curRound == kCross2To1 and curStatus < kRoundFighted) then
        -- 跨服32进1进行中
        retStatus = isRegisterTag + 5
    else
        retStatus = 8
    end
    return retStatus
end

kingInfo = nil
----------设置全服冠军信息
function setKingInfo( dataCache )
	-- body
	kingInfo = dataCache
end
----------

----------获取全服冠军信息
function getKingInfo()
	-- body
	return kingInfo
end
----------

supportInfo = nil
-----------设置我的支持数据
function setMySupportInfo( dataCache )
	-- body
	supportInfo = dataCache
end
-----------获取我的支持数据
function getMySupportInfo()
	-- body
	return supportInfo
end

--[[
	@des : 得到每一小轮的间隔时间
	@return : 秒数
--]]
function getOneTurnIntervalTime( ... )
	require "script/model/utils/ActivityConfigUtil"
	local data = ActivityConfigUtil.getDataByKey("lordwar").data
	local intervalTime = tonumber(data[1].kuafu_SroundGapTime)
	return intervalTime
end

--[[
    @des 得到助威的花费
--]]
function getCheerCost()
    require "script/model/utils/ActivityConfig"
    local data = ActivityConfig.ConfigCache.lordwar.data[1]
    local cost_db = strToTable(data.cheerCost)
    local cur_round = getCurRound()
    local cost_count = nil
    if cur_round <= kInner2To1 then -- 服内
        cost_count = table.hcopy(cost_db[1], {})
    else                            -- 跨服
        cost_count = table.hcopy(cost_db[2], {})
    end     
    cost_count[2] = cost_count[2] * UserModel.getHeroLevel()
    return cost_count
end

--[[
    @des 是否已经助威
--]]
function isCheered(hero_data, rank)
    if hero_data ~= nil and _lordInfo.support_serverid == hero_data.serverId and _lordInfo.support_uid == hero_data.uid then
        if rank ~= nil then
            if rank == 32 and tonumber(hero_data.rank) == 16 then
                return true
            end
            if rank == tonumber(hero_data.rank) then
                return true
            end
        end
    end
    return false
end

--[[
    @des: 设置助威信息
--]]
function setCheerInfo(server_id, uid)
    _lordInfo.support_serverid = server_id
    _lordInfo.support_uid = uid
end

--[[    
    @des: 得到助威信息
--]]
function getCheerInfo()
    local ret = {}
    ret.support_serverid = _lordInfo.support_serverid
    ret.support_uid = _lordInfo.support_uid
    return ret
end

--[[
    @des 是否可以助威
--]]
function canCheer()
    local ret = nil
    if _lordInfo.support_serverid == "0" then
        ret = true
    else
        ret = false
    end
    return ret
end

--[[
	@des: 得到更新cd结束时间
--]]
function getUpdateInfoCDTime( ... )
	require "script/model/utils/ActivityConfigUtil"
	local data = ActivityConfigUtil.getDataByKey("lordwar").data
	local lastUpataTime = tonumber(_lordInfo.update_fmt_time)
	local timeConfigs = string.split(data[1].cd, ",")
	-- printTable("timeConfigs", timeConfigs)
	local curRound  = getCurRound()
	local curStatus  = getCurRoundStatus()

	local cdTimeConfig = {}
	for i=kInnerAudition,kCross2To1 do
		cdTimeConfig[i] = tonumber(timeConfigs[i-kInnerAudition+1])
	end

	local nowCDTime = 0 -- 当前阶段更新战斗力需要的cd时间
	if curRound <= kInnerAudition then
		nowCDTime = cdTimeConfig[kInnerAudition]
	else
		nowCDTime = cdTimeConfig[curRound]
	end

	-- local endCDTime = lastUpataTime + (nowCDTime or 0)
	local endCDTime = lastUpataTime + tonumber(timeConfigs[1]) 
	local cdTime = endCDTime - BTUtil:getSvrTimeInterval()
	return cdTime
end

--[[
	@des 	:处理我的战报界面所需的数据
	@param 	:我的战报返回的数据
	@return :
--]]
function dealMyReportInfo(p_battleInfo)
	require "script/model/user/UserModel"
	local myReportTable = {}

	--innerTable 结构
	--[[
			type 		:类型 			1 服内海选
										2 服内淘汰
										3 跨服海选
										4 跨服淘汰
			round 		:阶段 			如果是淘汰赛 记录的是轮次
										如果是海选   记录的是海选轮次
			vsMan 		:对手			名字
			vsServer	:对手服务器名字
			ownGet  	:自己得分			我方胜场数
			heGet  	 	:对方得分 		对方胜场数
			bid 		:传给战报的信息 	
	--]]

	for k,v in pairs(p_battleInfo) do
		--服内海选
		if (tonumber(k) == kInnerAudition) or (tonumber(k) == kCrossAudition) then
			for i = 1,#v do
				local innerTable = {}
				innerTable.ownGet = 0
				innerTable.heGet = 0

				if tonumber(k) == kInnerAudition then
					innerTable.type = 1
				else
					innerTable.type = 3
				end
				innerTable.round = i

				if table.isEmpty(v[i].def) then
					if tonumber(v[i].res) == 1 then 
						innerTable.ownGet = innerTable.ownGet + 1
					else
						innerTable.heGet = innerTable.heGet + 1
					end
					innerTable.vsMan = v[i].atk.uname
					innerTable.vsServer = v[i].atk.serverName
				else
					if tonumber(v[i].res) == 0 then 
						innerTable.ownGet = innerTable.ownGet + 1
					else
						innerTable.heGet = innerTable.heGet + 1
					end
					innerTable.vsMan = v[i].def.uname
					innerTable.vsServer = v[i].def.serverName
				end

				innerTable.bid = v[i].replyId

				table.insert(myReportTable,innerTable)
			end
		else
			local innerTable = {}
			innerTable.ownGet = 0
			innerTable.heGet = 0
			if (tonumber(k) <= kInner2To1) and (tonumber(k) >= kInner32To16) then
				innerTable.type = 2
			else
				innerTable.type = 4
			end
			innerTable.round = tonumber(k)
			local atkTable = {}
			local defTable = {}

			require "script/model/user/UserModel"
			require "script/model/hero/HeroModel"

			local secondWinNum = 0
			local firstWinNum = 0

			for i = 1,#v do
				if table.isEmpty(v[i].def) then
					if tonumber(v[i].res) == 1 then 
						innerTable.ownGet = innerTable.ownGet + 1
					else
						innerTable.heGet = innerTable.heGet + 1
					end
					innerTable.vsMan = v[i].atk.uname
					innerTable.vsServer = v[i].atk.serverName

					if i == 1 then
						innerTable.vsMan = v[i].atk.uname
						innerTable.vsServer = v[i].atk.serverName
						innerTable.heServerId = v[i].atk.serverId
						innerTable.heUid = v[i].atk.uid
						innerTable.teamType = v[i].teamType
					end
				else
					if tonumber(v[i].res) == 0 then 
						innerTable.ownGet = innerTable.ownGet + 1
					else
						innerTable.heGet = innerTable.heGet + 1
					end
					innerTable.vsMan = v[i].def.uname
					innerTable.vsServer = v[i].def.serverName

					if i == 1 then
						innerTable.vsMan = v[i].def.uname
						innerTable.vsServer = v[i].def.serverName
						innerTable.heServerId = v[i].def.serverId
						innerTable.heUid = v[i].def.uid
						innerTable.teamType = v[i].teamType
					end
				end

				if i == 1 then
					if table.isEmpty(v[i].atk) then
						atkTable.level = UserModel.getHeroLevel()
						atkTable.htid = UserModel.getAvatarHtid()
						-- local dressInfo = HeroModel.getNecessaryHero().equip.dress
						-- if table.isEmpty(dressInfo) or HeroModel.getNecessaryHero().equip.dress["1"] == 0 then
						-- 	atkTable.dress = dressInfo
						-- else
						-- 	atkTable.dress = {}
      --                       print("fuck=", HeroModel.getNecessaryHero().equip.dress["1"])
						-- 	atkTable.dress["1"] = HeroModel.getNecessaryHero().equip.dress["1"].item_template_id
						-- end
						atkTable.dress = UserModel.getDress(1)

						atkTable.uid = UserModel.getUserUid()
						atkTable.serverId = getMyServerId()
						atkTable.uname = UserModel.getUserName()
						atkTable.vip = UserModel.getVipLevel()
						atkTable.serverName = getMyServerName()

						print("代发地方发护发方法将案件_1",getMyServerName())

						defTable = v[i].def
					else
						atkTable = v[i].atk

						defTable.level = UserModel.getHeroLevel()
						defTable.htid = UserModel.getAvatarHtid()
						-- local dressInfo = HeroModel.getNecessaryHero().equip.dress
						-- if table.isEmpty(dressInfo) or HeroModel.getNecessaryHero().equip.dress["1"] == 0 then
						-- 	defTable.dress = dressInfo
						-- else
						-- 	defTable.dress = {}
						-- 	defTable.dress["1"] = HeroModel.getNecessaryHero().equip.dress["1"].item_template_id
						-- end
						defTable.dress = UserModel.getDress(1)

						defTable.uid = UserModel.getUserUid()
						defTable.serverId = getMyServerId()
						print("代发地方发护发方法将案件_2",getMyServerName())
						defTable.uname = UserModel.getUserName()
						defTable.vip = UserModel.getVipLevel()
						defTable.serverName = getMyServerName()
					end
				end

				if table.isEmpty(v[i].atk) then
					v[i].atk.level = UserModel.getHeroLevel()
					v[i].atk.htid = UserModel.getAvatarHtid()
					--v[i].atk.dress = HeroModel.getNecessaryHero().equip.dress
					v[i].atk.dress = UserModel.getDress()
					v[i].atk.uid = UserModel.getUserUid()
					v[i].atk.serverId = getMyServerId()
					v[i].atk.uname = UserModel.getUserName()
					v[i].atk.vip = UserModel.getVipLevel()
					v[i].atk.serverName = getMyServerName()
				else
					v[i].def.level = UserModel.getHeroLevel()
					v[i].def.htid = UserModel.getAvatarHtid()
					v[i].def.dress = UserModel.getDress()
					v[i].def.uid = UserModel.getUserUid()
					v[i].def.serverId = getMyServerId()
					v[i].def.uname = UserModel.getUserName()
					v[i].def.vip = UserModel.getVipLevel()
					v[i].def.serverName = getMyServerName()
				end

				if tonumber(v[i].def.uid) == tonumber(atkTable.uid) then
					if tonumber(v[i].res) == 0 then
						secondWinNum = secondWinNum + 1
					else
						firstWinNum = firstWinNum + 1
					end
				else
					if tonumber(v[i].res) == 0 then
						firstWinNum = firstWinNum + 1
					else
						secondWinNum = secondWinNum + 1
					end
				end
			end

			innerTable.atkTable = atkTable
			innerTable.defTable = defTable
			innerTable.atkWinNum = firstWinNum
			innerTable.defWinNum = secondWinNum
			innerTable.allTable = v

			table.insert(myReportTable,innerTable)
		end
	end

	local sortFunction = function(w1,w2)
		if w1.type > w2.type then
			return true
		elseif w1.type == w2.type then
			if w1.round > w2.round then
				return true
			else
				return false
			end
		else
			return false
		end
	end
	table.sort(myReportTable,sortFunction)

	return myReportTable
end

--[[
    @des                : 得到后端胜者组和败者组的标识
    @param p_lordType   : 前端后端胜者组和败者组的的标识
--]]
function getServerTeamType(p_lordType)
    local serverTeamType = nil
    if p_lordType == kWinLordType then
        serverTeamType = 1
    elseif p_lordType == kLoseLordType then
        serverTeamType = 2
    else
        error("p_lordType有误")
    end
    return serverTeamType
end

--[[
	@des 	: 返回玩家数据
	@param 	: p_serverId, p_uid 
	@return : table{ 
					uname => ,
					htid => ,
					vip => ,
					dress =>,
					serverName => ,
					rank => ,
					fightForce =>,
					serverId =>  
					uid =>  
				} or nil:表示没有玩家
--]]
function getUserInfoBy( p_serverId, p_uid )
	if(_promotionInfo == nil)then
		return nil
	end
	print_t(_promotionInfo.winLord)
	print_t(_promotionInfo.loseLord)
	local retData = nil
	for k,v in pairs(_promotionInfo.winLord) do
		if(tonumber(v.serverId) == tonumber(p_serverId) and tonumber(v.uid) == tonumber(p_uid))then
			retData = v
			return retData
		end
	end
	for k,v in pairs(_promotionInfo.loseLord) do
		if(tonumber(v.serverId) == tonumber(p_serverId) and tonumber(v.uid) == tonumber(p_uid))then
			retData = v
			return retData
		end
	end
	return retData
end

--[[
	@des ： 得到报名等级
--]]
function getRegisgterLevel( ... )
	require "script/model/utils/ActivityConfigUtil"
	local data = ActivityConfigUtil.getDataByKey("lordwar").data
	return tonumber(data[1].level)
end

