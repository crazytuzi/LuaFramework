-- FileName: CountryWarPlaceService.lua 
-- Author: licong 
-- Date: 15/11/12 
-- Purpose: 战场后端接口


module("CountryWarPlaceService", package.seeall)
require "script/ui/countryWar/war/CountryWarPlaceData"


-- 国战相关：
-- 1、建立国战Socket： Network.connectCountrySocket( ipStr, port )

-- 2、国战Socket相关rpc请求：	Network.rpcCountry(cbFunc, cbFlag, rpcName, args )
-- 						Network.noLoadingRpcCountry( cbFunc, cbFlag, rpcName, args)

-- 3、关闭国战Socket： Network.closeCountrySocket()

-- 4、推送和原来一样：Network.re_rpc( cbFunc, cbFlag, rpcName)

--------------------------------------------------------------------- 国战跨服类接口 START --------------------------------------------------------------------------
-- /**
-- * 登录跨服机器，参数含义@seegetLoginInfo
-- *
-- * @param int $serverId 				原服务器id		
-- * @param int $pid						玩家pid
-- * @param string $token					登录校验串
-- *
-- * @return
-- * 
-- * <code>
-- * 
-- * {
-- * 		ret => string,				'ok'|'fail'
-- * }
-- * 
-- * </code>
-- * 
-- * 	TODO修改超时时间配置lcserver
-- */
-- public function loginCross( $serverId,$pid, $token );
function loginCross( p_serverId, p_pid, p_token, p_callBack )
	local requestFunc = function(cbFlag,dictData,bRet)
		if(p_callBack ~= nil)then
			p_callBack(dictData)
		end
	end
	local args = Network.argsHandlerOfTable({ p_serverId, p_pid, p_token })
	Network.rpcCountry(requestFunc,"countrywarcross.loginCross","countrywarcross.loginCross",args)
end

-- /**
-- * 进入战场
-- * 轻量级，初始化及标识场景的功能
-- * @return string
-- * 
-- * <code>
-- * 
-- * 		'over'											结束了
-- * 		'not_found'										没发现战场
-- * 		'full'											战场有参战人数限制，表示已满
-- * 		'ok'											进入正常
-- * 		'expired' 										时间不对
-- * 
-- * </code>
-- */
-- public function enter( $countryId );
function enter( p_countryId, p_callBack )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(p_callBack ~= nil)then
				p_callBack( dictData )
			end
		end
	end
	local args = Network.argsHandlerOfTable({ p_countryId })
	Network.rpcCountry(requestFunc,"countrywarcross.enter","countrywarcross.enter",args)
end


-- /**
-- * 标识场景的功能
-- * @return
-- * 
-- * <code>
-- * 
-- * {
-- * 		retcode:string 						'ok'|'fail'								
-- * }
-- * 
-- * </code>
-- * 
-- */
-- public function leave();
function leave( p_callBack )
	local requestFunc = function(cbFlag,dictData,bRet)
		if(dictData.err == "ok")then
			if(p_callBack ~= nil)then
				p_callBack(dictData)
			end
		end
	end
	Network.rpcCountry(requestFunc,"countrywarcross.leave","countrywarcross.leave",nil)
end


-- /**
--  * 进入场景后获取的场景信息
--  * getEnterInfo
--  *
--  * @return
--  * 
--  * <code>
--  * 
--  * {
--  * 		retcode = ok|
--  * 		res = array
--  * 		{
--  * 			refreshMs=>int						刷新周期,单位 微秒
--  * 			readyDuration=>int                  准备时间,单位秒
--  *			attacker : 
--  *   			dictionary{
--  *      			groupId : "1"
--  *      			groupName : "attacker"
--  *       		totalMemberCount : "1"
--  *      			memberCount : "2"
--  *       		resource : "0"
--  *  			}
-- 	*			defender : 
--  *   			dictionary{
--  *       			groupId : "2"
--  *       			groupName : "defender"
--  *       			totalMemberCount : "1"
--  *       			memberCount : "1"
--  *       			resource : "0"
--  *   		}
--  * 			user	                		玩家信息
--  * 			{	
--  *  				groupId : "1" 				玩家分组（判断攻守方）
--  *  				winStreak : "1"				连续击杀个数
--  * 				canJoinTime	    			能够参战的时间 leaveBattleTime + JoinCd 可清的
--  * 				readyTime					能够进入战场的时间 quitBattleTime + JoinReady
--  * 				canInspreTime				能够鼓舞的时间lastInspireTime + cdTime
-- 	*				extra           			其他信息
--  *				{
--  *					info
--  *					{	
--  * 						attackLevel 		攻击鼓舞等级
--  *						auto_recover 		自动回血的状态
--  *						recover_percent		自动回血的点
--  *					}
--  *				}
--  * 			}
--  * 			field							战场信息
--  * 			{
--  * 				pastTime:					战场已经持续的时间，包括准备时间和正式开战时间，单位秒
--  * 				endTime:					抢粮战结束时间，单位秒
--  * 				roadState					通道状态，1 代表目前属于较少通道 2 代表目前属于较多通道
--  * 				roadAddLimit				人数达到多少后，需要2变4
--  * 				roadLength:[]               数组，表示通道的长度
--  * 				transfer:[1,3,0,4,6,1]  	传送阵信息，每个传送阵上的人数，传送阵标号按照从从上向下，从攻方到守方的顺序，从0开始
--  * 				road						包含所有在通道上的单位的信息
--  *				[
--  *					array					每个战斗单位数据如下    TODO	跨服的东西需要server_id，pid
--  *					{
--  *						id					玩家id
--  *						type 				如果没有这个字段，就认为是玩家，非NPC之类
--  *						serverName			服务器名字
--  *
--  *											以下数据在两种情况下会有：[1]需要的信息的用户刚刚进入战场[2]当前单位刚刚进入通道
--  *						name        		战斗单位名称
--  *						tid					形象id
--  *						transferId  		传送阵id
--  *						maxHp      			最大血量
--  *
--  *											以下数据在三种情况下会有：[1]需要的信息的用户刚刚进入战场[2]当前单位刚刚进入通道[3]速度发生变化
--  *						speed				速度
--  *
--  *											以下数据在三种情况下会有：[1]需要的信息的用户刚刚进入战场；[2]当前单位刚刚进入通道；[3]当前单位血量发生改变
--  *						curHp				当前血量
--  *						winStreak			连杀次数
--  *
--  *											以下数据在四种情况下会有：[1]需要的信息的用户刚刚进入战场；[2]当前单位刚刚进入通道；[3]当前单位发生移动 [4] 速度发生变化
--  *						roadX				在通道上的位置
--  *						stopX				预测单位可能会停止的位置
--  *					}
--  *				]
--  * 			}
--  * 		}
--  * }
--  * 
--  * </code>
--  * 
-- */
-- public function getEnterInfo();
function getEnterInfo( p_callBack )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(p_callBack ~= nil)then
				p_callBack( dictData.ret )
			end
		end
	end
	Network.rpcCountry(requestFunc,"countrywarcross.getEnterInfo","countrywarcross.getEnterInfo",nil)
end

-- /**
--  * join 							参加抢粮战
--  *
--  * @param int  			传送阵id
--  *
--  *@return
--  *
--  *<code>
--  *
--  *{
--  *	retcode:状态如下 
--  *	battling正在战斗, 
--  *	full传送阵已满, 
--  *	waitTime等冷却, 
--  *	cdtime达阵失败后的再次出阵cd,
--  *	ok 出阵成功
--  *
--  *	timeNeed:int 			retcode为waitTime|cdtime时有效,什么时间可以参战
--  *	outtime:int				retcode为ok时有效
--  *}
--  *
--  *</code>
--  *
-- */
-- public function joinTransfer( $transferId );
local index = 0
local isSend = false
function joinTransfer( p_transferId, p_callBack )
	if(isSend == true)then
		return
	end
	local requestFunc = function(cbFlag,dictData,bRet)
		isSend = false
		if dictData.err == "ok" then
			if(p_callBack ~= nil)then
				p_callBack(dictData.ret)
			end
		end
	end
	isSend = true
	index = index + 1
	local args = Network.argsHandlerOfTable({ p_transferId })
	Network.rpcCountry(requestFunc,"countrywarcross.joinTransfer" .. index,"countrywarcross.joinTransfer",args)
end

-- /**
--  * @return
--  * 	 			[
--  * 						{
--  * 							uname
--  * 							htid
--  * 							vip
--  * 							level
--  * 							fight_force
--  * 						}
--  * 				 ]
--  */
-- public function getRankList();
function getRankList( p_callBack )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(p_callBack ~= nil)then
				p_callBack(dictData.ret)
			end
		end
	end
	Network.rpcCountry(requestFunc,"countrywarcross.getRankList","countrywarcross.getRankList",nil)
end


-- /*******************后端推送给前端的数据****************************/
-- 	/*
-- 	 [1]push.countrywarcross.refresh			一个刷新周期内发送的信息
-- 	{
-- 		attacker						攻方信息，如果有人达阵，才会有这个字段的信息
-- 		{
-- 			resource					当前资源数
-- 			memberCount					战场上的人数
-- 		}
	
-- 		defender						守方信息，如果有人达阵，才会有这个字段的信息
-- 		{
-- 			resource					当前资源数
-- 			memberCount					战场上的人数
-- 		}
	
-- 		field							战场信息
-- 		{
-- 			endTime						抢粮战结束时间，单位秒，如果结束时间发生变化，会传这个字段
-- 			roadState					通道状态，1 代表目前属于较少通道 2 代表目前属于较多通道，如果通道的状态没有发生变化，则没有这个字段，这个字段值会在getEnterInfo时获取一次
-- 			transfer					每个传送阵上的人数，传送阵标号按照从从左向右，从攻方到守方的顺序，从0开始
-- 			[
-- 				1						第0个传送阵上的战斗单位数量，以下类似
-- 				2
-- 				0
-- 				3
-- 				2
-- 				1
-- 			]
-- 			road						包含所有在通道上的单位的信息
-- 			[
-- 				array					每个战斗单位数据如下
-- 				{
-- 					id 					玩家id
-- 					type 				如果没有这个字段，就认为是玩家，非NPC之类
		
-- 					以下数据在两种情况下会有：[1]需要的信息的用户刚刚进入战场[2]当前单位刚刚进入通道
-- 					name        		战斗单位名称
-- 					tid					形象id
-- 					transferId  		传送阵id
-- 					maxHp      			最大血量
		
-- 					以下数据在三种情况下会有：[1]需要的信息的用户刚刚进入战场[2]当前单位刚刚进入通道[3]速度发生变化
-- 					speed				速度
	
-- 					以下数据在三种情况下会有：[1]需要的信息的用户刚刚进入战场；[2]当前单位刚刚进入通道；[3]当前单位血量发生改变
-- 					curHp				当前血量
-- 					winStreak			连杀次数
	
-- 					以下数据在四种情况下会有：[1]需要的信息的用户刚刚进入战场；[2]当前单位刚刚进入通道；[3]当前单位发生移动 [4] 速度发生变化
-- 					roadX				在通道上的位置
-- 					stopX				预测单位可能会停止的位置
-- 				}
-- 			]
-- 			touchdown					这个周期内达阵的战斗单位id数组
-- 			[
-- 				array
-- 				{
-- 					id					达阵的id
-- 					type 				如果没有这个字段，就认为是玩家，非NPC之类
-- 				}
-- 			]
-- 			leave						这个周期内掉线或者主动离开战场的战斗单位id数组
-- 			[
-- 				array
-- 				{
-- 					id					离开的id
-- 					type 				如果没有这个字段，就认为是玩家，非NPC之类
-- 				}
-- 			]
-- 		}
-- 	}
function registerPushRefresh( p_callback )
	local requestCallback = function ( cbFlag, dictData, bRet )
		if (dictData.err == "ok") then
			--刷新战斗玩家信息
			CountryWarPlaceData.refreshBattleInfo(dictData.ret)
			if p_callback ~= nil then
				p_callback()
			end
		end
	end
	Network.re_rpc(requestCallback, "push.countrywarcross.refresh", "push.countrywarcross.refresh")
end

	
-- 	[2]push.countrywarcross.fightResult 		任何一场战斗结束都需要向战场所有玩家广播战斗结果
-- 	{
-- 		winnerId						胜者id
-- 		loserId							败者id
-- 		winnerName						胜者名字//TODO 服的名字
-- 		loserName						败者名字
-- 		winStreak						胜利者连胜次数
-- 		terminalStreak					失败者在此次失败之前的连胜次数
-- 		brid							战报id
-- 		winnerOut						默认赢家是不会被移出战场的，但是出现同归于尽的情况，虽然判一方胜，但是该胜者也需要移出战场
-- 	}
function registerPushFightResult( p_callback )
	local requestCallback = function ( cbFlag, dictData, bRet )
		if (dictData.err == "ok") then
			if p_callback ~= nil then
				p_callback(dictData.ret)
			end
			CountryWarPlaceData.addReportInfo(dictData.ret)
		end
	end
	Network.re_rpc(requestCallback, "push.countrywarcross.fightResult", "push.countrywarcross.fightResult")
end
	
-- 	[3]push.countrywarcross.fightWin			给胜者单独发送的信息
-- 	{
-- 		reward							胜者奖励信息
-- 		{
-- 			point					   	用户获得的积分
-- 		}
-- 		extra							扩展信息
-- 		{
-- 			adversaryName				对手名称
-- 			winnerOut					默认赢家是不会被移出战场的，但是出现同归于尽的情况，虽然判一方胜，但是该胜者也需要移出战场
-- 			joinCd						如果赢家也要被移出战场，这个是重新参战的时间
-- 		}
-- 		hpRecover
-- 		{
-- 			cost
-- 		}
-- 	}
function registerPushFightWin( p_callback )
	local requestCallback = function ( cbFlag, dictData, bRet )
		if (dictData.err == "ok") then
			if dictData.ret.extra.winnerOut == "true" then
				CountryWarPlaceData.setCanJoinTime(dictData.ret.extra.joinCd)
			end
			--  自动回血扣国战币
			if(dictData.ret.hpRecover and dictData.ret.hpRecover.cost)then
				CountryWarMainData.addCocoin( -tonumber(dictData.ret.hpRecover.cost) )
			end

			-- 刷新自动勾选的状态
        	CountryWarPlaceData.judgeNextAutoRecoveryBlood()

			if p_callback ~= nil then
				p_callback(dictData.ret)
			end
		end
	end
	Network.re_rpc(requestCallback, "push.countrywarcross.fightWin", "push.countrywarcross.fightWin")
end
	
-- 	[4]push.countrywarcross.fightLose		给败者单独发送的信息
-- 	{
-- 		reward							败者奖励信息，值为负代表需要扣除
-- 		{
-- 			point					   	用户获得的积分
-- 		}
-- 		extra							扩展信息
-- 		{
-- 			adversaryName				对手名称
-- 			joinCd                      从新参战的CD时间
-- 		}
-- 	}
function registerPushFightLose( p_callback )
	local requestCallback = function ( cbFlag, dictData, bRet )
		if (dictData.err == "ok") then
			CountryWarPlaceData.setCanJoinTime(dictData.ret.extra.joinCd)
			if p_callback ~= nil then
				p_callback(dictData.ret)
			end
		end
	end
	Network.re_rpc(requestCallback, "push.countrywarcross.fightLose", "push.countrywarcross.fightLose")
end

-- 	[5]push.countrywarcross.touchDown		给达阵者单独发送的信息
-- 	{
-- 		reward							达阵者奖励信息
-- 		{
-- 			point					   	用户获得的积分
-- 		}
-- 		extra							扩展信息
-- 		{
-- 			joinCd                      从新参战的CD时间
-- 		}
-- 	}
function registerPushTouchDown( p_callback )
	local requestCallback = function ( cbFlag, dictData, bRet )
		if (dictData.err == "ok") then
			CountryWarPlaceData.setCanJoinTime(dictData.ret.extra.joinCd)
			if p_callback ~= nil then
				p_callback(dictData.ret)
			end
		end
	end
	Network.re_rpc(requestCallback, "push.countrywarcross.touchDown", "push.countrywarcross.touchDown")
end

-- 	[6]push.countrywarcross.battleEnd        一整场战斗结束后发送的信息
-- 	{
-- 		ret = 'ok'
-- 	}
function registerPushBattleEnd( p_callback )
	local requestCallback = function ( cbFlag, dictData, bRet )
		if (dictData.err == "ok") then
			if p_callback ~= nil then
				p_callback(dictData.ret)
			end
		end
	end
	Network.re_rpc(requestCallback, "push.countrywarcross.battleEnd", "push.countrywarcross.battleEnd")
end

-- 	[7]push.countrywarcross.reckon			战斗结束后的玩家结算数据
-- 	{
-- 		rank							排名
-- 		point							积分
-- 	}
function registerPushReckon( p_callback )
	local requestCallback = function ( cbFlag, dictData, bRet )
		if (dictData.err == "ok") then
			if p_callback ~= nil then
				p_callback(dictData.ret)
			end
		end
	end
	Network.re_rpc(requestCallback, "push.countrywarcross.reckon", "push.countrywarcross.reckon")
end

-- 	[8]push.countrywarcross.topN				排行榜
-- 	{
-- 		[
-- 			id => array
-- 			{
-- 				rank					战斗单位排名
-- 				uname					战斗单位名称
-- 				point					积分
-- 			}
-- 		]
-- 	}
-- function registerPushTopN( p_callback )
-- 	local requestCallback = function ( cbFlag, dictData, bRet )
-- 		if (dictData.err == "ok") then
-- 			if p_callback ~= nil then
-- 				p_callback(dictData.ret)
-- 			end
-- 		end
-- 	end
-- 	Network.re_rpc(requestCallback, "push.countrywarcross.topN", "push.countrywarcross.topN")
-- end
	
-- 	[9]push.countrywarcross.reset			场上玩家回血
-- 	[
-- 		id
-- 	]
-- function registerPushReset( p_callback )
-- 	local requestCallback = function ( cbFlag, dictData, bRet )
-- 		if (dictData.err == "ok") then
-- 			if p_callback ~= nil then
-- 				p_callback(dictData.ret)
-- 			end
-- 		end
-- 	end
-- 	Network.re_rpc(requestCallback, "push.countrywarcross.reset", "push.countrywarcross.reset")
-- end

--------------------------------------------------------------------- 国战跨服类接口 END --------------------------------------------------------------------------


-- /**
-- * 获取登录跨服要用到的信息
-- * @return
-- * 
-- * <code>
-- * 
-- * {
-- * 		ret => string 								ok|fail|errtime,成功|失败|时间不对
-- * 		serverIp=>string								跨服服务器ip
-- * 		port=>int										端口
-- * 		token=>string									跨服服务器身份验证
-- *		uuid=>string 									玩家跨服服务器上的id
-- * }
-- * 
-- * </code>
-- * 
-- */
-- 	public function getLoginInfo();
function getLoginInfo( p_callBack )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(p_callBack ~= nil)then
				p_callBack(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc,"countrywarinner.getLoginInfo","countrywarinner.getLoginInfo",nil,true)
end


