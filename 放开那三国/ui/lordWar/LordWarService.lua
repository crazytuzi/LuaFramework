-- Filename: LordWarService.lua
-- Author: lichenyang
-- Date: 2014-08-14
-- Purpose: 个人跨服赛网络层

require "script/ui/lordWar/LordWarData"

module("LordWarService", package.seeall)

-- /**
--  * 进入跨服场景，为推送
-- */
function enterLordwar(p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			if(p_callbackFunc ~= nil) then
				p_callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "lordwar.enterLordwar", "lordwar.enterLordwar", nil, true)
end

-- /**
--  * 离开跨服场景
-- */
function leaveLordwar(p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			if(p_callbackFunc ~= nil) then
				p_callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "lordwar.leaveLordwar", "lordwar.leaveLordwar", nil, true)
end

-- /**
--  * 报名
-- */
function register(p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			--修改报名时间
			LordWarData.setRegisterTime(BTUtil:getSvrTimeInterval())
			if(p_callbackFunc ~= nil) then
				p_callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "lordwar.register", "lordwar.register", nil, true)
end


-- /**
--  * @我的战绩
--  * @return array(
--  * 		round => array( subRound1 => array(@see below), subRound2 => array(),... )
--  * 		round => array( subRound1 => array(),subRound2 => array(), )
--  * 		...
--  * )
--  * 
--  * below:
--  * winner => array
--  * (
--  * 		uname => '',
--  * 		serverId => ,
--  * 		serverName=>,
--  *		pid => ,
--  * 		bid => ,
--  * )
--  * loser => 
--  * (
--  * 		uname => '',
--  * 		serverId => ,
--  * 		serverName=>,
--  *		pid => ,
--  * 		bid => ,
--  * )
--  * replyId => ,
--  * )
--  */
function getMyRecord(p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			if(p_callbackFunc ~= nil) then
				print("得到的数据")
				print_t(dictData.ret)
				p_callbackFunc(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc, "lordwar.getMyRecord", "lordwar.getMyRecord", nil, true)
end

-- /**
--  * @更新战斗信息
--  * @ret
--  */
function updateFightInfo(p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			if dictData.ret.update == "ok" then
				--刷新更新时间
				LordWarData.setUpdateInfoTime(dictData.ret.time)
			end
			if(p_callbackFunc ~= nil) then
				p_callbackFunc(dictData.ret.update)
			end
		end
	end
	Network.rpc(requestFunc, "lordwar.updateFightInfo", "lordwar.updateFightInfo", nil, true)
end

-- /**
--  * 清更新战斗信息的cd
--  * @ret{
--  *   gold=> 花费金币
--  *   time=> 上次更新战斗力时间
--  *}
-- */
function clearFmtCd(p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			UserModel.addGoldNumber(-LordWarData.getCleanCdGoldCount()) -- 减金币
			LordWarData.setUpdateInfoTime(-tonumber(dictData.ret.time))
			if(p_callbackFunc ~= nil) then
				p_callbackFunc(tonumber(dictData.ret.gold))
			end
		end
	end
	Network.rpc(requestFunc, "lordwar.clearFmtCd", "lordwar.clearFmtCd", nil, true)
end

-- /**
--  * 上届冠军
--  * array(
--  * 		0 => array(
--  * 			uname => ,
--  * 			serverId => ,
--  * 			serverName=>,
--  * 			pid => ,
--  * 			htid => ,
-- 			dress => ,
--  * 			...
--  * 			
--  * 		),
--  * 		1 => array(),
--  * 		2 => array(),
--  * )
--  * 
--  */
function getTempleInfo(p_callbackFunc)
 	local requestFunc = function( cbFlag, dictData, bRet )
 		-- local dictData = {}
 		-- dictData.err = "ok"
 		-- dictData.ret = {
 		-- 	[1]={uname="123", serverId="12123", pid="12123", htid="20002", dress = {}, title = 2},
 		-- 	[2]={uname="345", serverId="12123", pid="12123", htid="20002", dress = {}, title = 1},
 		-- 	[3]={uname="645", serverId="12123", pid="12123", htid="20002", dress = {}, title = 4},
 		-- }
 		LordWarData.setTempleInfo(dictData.ret)
		if(dictData.err == "ok") then
			if(p_callbackFunc ~= nil) then
				p_callbackFunc()
			end
		end
	end
	-- requestFunc()
	Network.rpc(requestFunc, "lordwar.getTempleInfo", "lordwar.getTempleInfo", nil, true)
end

touchTag = 0

function setTouchTag( _touchTag )
 	-- body
 	touchTag = _touchTag
 end 

-- /**
--  * 
--  * @param int $type 膜拜类型
--  * 
--  */
function worship(p_pos, p_type, p_callbackFunc)
    
 	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			local dbDataCache = DB_Kuafu_personchallenge.getDataById(1).wishCost

			local dbDataArry = string.split(dbDataCache,",")
			local partDbDataArry = string.split(dbDataArry[p_type + 1],"|")
			if(partDbDataArry[1]== "1")then
				UserModel.addSilverNumber(-tonumber(partDbDataArry[3]))
			elseif(partDbDataArry[1]== "3")then
				UserModel.addGoldNumber(-tonumber(partDbDataArry[3]))		
			end
			
			if(p_callbackFunc ~= nil) then
				p_callbackFunc()
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(p_pos))
	args:addObject(CCInteger:create(p_type))
	Network.rpc(requestFunc, "lordwar.worship", "lordwar.worship", args, true)
end

-- /**
--  * 支持
--  * @param int $p_pos
--  * @param int $p_type 1 傲视群雄 2 初出茅庐
--  */
function support( p_pos, p_type, p_callbackFunc)
 	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			if(p_callbackFunc ~= nil) then
				p_callbackFunc()
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(p_pos))
	args:addObject(CCInteger:create(p_type))
	Network.rpc(requestFunc, "lordwar.support", "lordwar.support", args, true)
end

-- /**
--  * array(
--  * 		round => array(serverId,serverName,uid,uname,result),
--  * 		round => array(serverId,serverName,uid,uname,result),
--  * )
--  */
function getMySupport(p_callbackFunc)
 	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			LordWarData.setMySupportInfo(dictData.ret)
			if(p_callbackFunc ~= nil) then
				p_callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "lordwar.getMySupport", "lordwar.getMySupport", nil, true)
end

-- /**
--  * 获取用户信息
--  * @return array							
--  *	( 
--  * 		team_type:						组别, 初始为0, 胜者组为1, 负者组为 2
--  * 		worship_num:					膜拜次数
--  * 		update_fmt_time:				更新战斗力时刻
--  * 		register_time:					报名时间
--  * 		round => int 					当前阶段
--  *		status => int,					阶段状态
--  *		server_id => int,				服务器id
--  *       support_serverid =>int,         助威的人的服务器id
--  *       support_uid => int              助威的人的uid
--  *  )	
--  */
function getLordInfo(p_callbackFunc)
 	local requestFunc = function( cbFlag, dictData, bRet )
	 	if(dictData.err == "ok") then
            print("lordwar.getLordInfo")
            print_t(dictData)
			LordWarData.setLordInfo(dictData.ret) --存储lordInfo 信息
			if(p_callbackFunc ~= nil) then
				p_callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "lordwar.getLordInfo", "lordwar.getLordInfo", nil, true)
end

-- /**
--  * //拉取战斗进度、结果等信息，其实主要就是拉取晋级赛的信息
--  * array(                         
--  * 		round => int 
--  *		status => int,
--  *		upLord=>array(
--  *			//32个人的信息，32条数据，每条中包含当前名次，每次战斗对手信息和结果
--  *			0=> array(
--  *					uname => ,
--  *					htid => ,
--  *					vip => ,
--  *					dress =>,
--  *					serverId => ,
--  *					rank => ,
--  *					fightForce =>,
--  *				 	)
--  *		), 
--  * 		)
--  *		downLord=>array(
--  *			//32个人的信息，32条数据，每条中包含当前名次，每次战斗对手信息和结果
--  *			0=> array(
--  *					uname => ,
--  *					htid => ,
--  *					vip => ,
--  *					dress =>,
--  *					serverId => ,
--  *					rank => ,
--  *					fightForce =>,
--  *				 	)
--  *		), 
--  * 		)
--  * 
--  */
function getPromotionInfo(p_callbackFunc)
    print(debug.traceback())
 	local requestFunc = function( cbFlag, dictData, bRet )
	 	if(dictData.err == "ok") then
            -- print("lordwar.getPromotionInfo")
            -- print_t(dictData)
	 		LordWarData.setPromotionInfo(dictData.ret)
			if(p_callbackFunc ~= nil) then
				p_callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "lordwar.getPromotionInfo", "lordwar.getPromotionInfo", nil, true)
end

-- /**
--  * 获取某个阶段，晋级赛某两个人的战报id
--  * @return
--  * array(
--  * subround=> 
--  * array(
--  * winner => array
--  * (
--  * 		uname => '',
--  * 		serverId => ,
--  * 		serverName=>,
--  *		pid => ,
--  * 		bid => ,
--  * )
--  * loser => 
--  * (
--  * 		uname => '',
--  * 		serverId => ,
--  * 		serverName=>,
--  *		pid => ,
--  * 		bid => ,
--  * )
--  * replyId => ,
--  * 				
--  * 			)
--  * )
--  */
function getPromotionBtl( p_round, p_teamType,p_serverId1, p_uid1, p_serverId2, p_uid2, p_callbackFunc)
 	local requestFunc = function( cbFlag, dictData, bRet )
 		print("拉去战报返回值")
 		print_t(dictData)
		if(dictData.err == "ok") then
			if(p_callbackFunc ~= nil) then
				p_callbackFunc(dictData.ret)
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(p_round))
	args:addObject(CCInteger:create(p_teamType))
	args:addObject(CCInteger:create(p_serverId1))
	args:addObject(CCInteger:create(p_uid1))
	args:addObject(CCInteger:create(p_serverId2))
	args:addObject(CCInteger:create(p_uid2))
	Network.rpc(requestFunc, "lordwar.getPromotionBtl", "lordwar.getPromotionBtl", args, true)
end

--[[
	@des : 活动历史晋级赛信息
	@parm: round 轮次
--]]
function getPromotionHistory( p_round, p_callbackFunc )
	local requestFunc = function( cbFlag, dictData, bRet )
        if p_round == LordWarData.kInner2To1 then
            LordWarData.setPromotionInfo(dictData.ret, LordWarData.kInnerType)
        elseif p_round == LordWarData.kCross2To1 then
            LordWarData.setPromotionInfo(dictData.ret, LordWarData.kCrossType)
        end
		if(dictData.err == "ok") then
			if(p_callbackFunc ~= nil) then
				p_callbackFunc()
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(p_round))
	Network.rpc(requestFunc, "lordwar.getPromotionHistory", "lordwar.getPromotionHistory", args, true)
end


--[[
	@des 	:推送的阶段id和阶段状态
	@return :
	{
		round:int
		status: int
		subRound: int
	}
 --]]
function regisgerRoundPush( p_callback )
	local requestCallback = function ( callbackFlag, dictData, bSucceed )
		if(dictData.err == "ok") then
            print("收到push.lordwar.update")
            local curTime = BTUtil:getSvrTimeInterval()
            print("time=", TimeUtil.getTimeFormatYMDHMS(curTime))
            dictData.ret.subRound = dictData.ret.subRound or "-1"
             p_callback(tonumber(dictData.ret.round), tonumber(dictData.ret.status), tonumber(dictData.ret.subRound))
		end
	end
	Network.re_rpc(requestCallback,"push.lordwar.update", "push.lordwar.update")
end




