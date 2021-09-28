-- FileName: GuildRobBattleService.lua
-- Author: lichenyang
-- Date: 14-1-8
-- Purpose: 扫荡界面
-- @module GuildRobBattleService

module("GuildRobBattleService",package.seeall)
require "script/ui/guild/guildrob/GuildRobBattleData"

--- /**
--  * create 创建抢粮战
--  *
--  * @param int p_defenseGuildId 		被抢夺的军团ID
--  *
--  * @return string
--  * 'defense_too_much'				被抢夺的次数太多啦
--  * 'attack_too_much'    				抢夺的次数太多啦
--  * 'lack_fight_book'					缺少战书
--  * 'fighting'						两个军团有一个正在和别的军团干架
--  * 'ok'								可以开打
--  */
function create(p_defenseGuildId, p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(p_callbackFunc ~= nil) then
				p_callbackFunc(dictData.ret)
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(tonumber(p_defenseGuildId)))
	Network.rpc(requestFunc, "guildrob.create", "guildrob.create", args, true)
end

---
-- /**
--  * enter 							进入抢粮战
--  *
--  * @return string/int
--  * 'over'							不在抢粮的时间段内
--  * 'not_found'						没发现这个玩家所在的军团在任何一场抢粮战内
--  * 'full'							战场可能有参战人数限制，表示已满
--  * rob_id							进入正常，返回抢粮战id
--  */
function enter(p_robId, p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			if dictData.ret == "over" then
				AnimationTip.showTip(GetLocalizeStringBy("lcyx_181"))
				return
			end
			if dictData.ret == "not_found" then
				AnimationTip.showTip(GetLocalizeStringBy("lcyx_182"))
				return
			end
			if dictData.ret == "full" then
				AnimationTip.showTip(GetLocalizeStringBy("lcyx_183"))
				return
			end
			if(p_callbackFunc ~= nil) then
				p_callbackFunc(dictData.ret)
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(p_robId))
	Network.rpc(requestFunc, "guildrob.enter", "guildrob.enter", args, true)
end

-- /**
--  * getEnterInfo 					获得初始信息
--  *
--  * @return array
--  * ret=
--  * ok:
--  *
--  * res =
--  * <code>
--  * {
--  * 
--  * refreshMs:						刷新周期,单位 微秒
--  * readyDuration:                   准备时间,单位秒
--  * 
--  * attacker        					抢粮军团信息
--  * {
--  * 		guildId   	 				抢粮军团id   
--  * 		guildName					军团名字
--  *   	morale                      当前士气值
--  * 		totalMemberCount            军团成员总数
--  * 		robGrain	   				已经抢夺的粮草
--  * 		memberCount					抢粮军团在战场上的人数
--  * }
--  * 
--  * defender     					被抢粮军团信息
--  * {
--  * 		guildId	    				被抢粮军团id 
--  * 		guildName					军团名字
--  * 		totalMemberCount            军团成员总数
--  * 		robLimit					最多可以被抢多少粮草
--  * 		memberCount					被抢军团在战场上的人数
--  * }
--  *
--  * user	                			玩家信息
--  * {
--  * 		guildId						玩家所属的军团
--  * 		canJoinTime	    			能够参战的时间 leaveBattleTime + JoinCd  
--  * 		readyTime					能够进入战场的时间 quitBattleTime + JoinReady
--  * 		winStreak	      			连续击杀个数
--  *		extra           			其他信息   
--  *		{
--  *			info
--  *			{
--  *				removeCdNum			本次战斗中玩家消除cd的次数
--  *				speedUpNum         	本次战斗中玩家加速次数
--  *				killNum				本次战斗中玩家击杀个数
--  *				meritNum  			本次战斗中玩家获得功勋
--  *				userGrainNum		本次战斗中玩家为自己抢夺的粮草
--  *				guildGrainNum 		本次战斗中玩家为公会抢夺的粮草
--  *			}
--  *		}
--  * }
--  *
--  * field								战场信息
--  * {
--  * 		pastTime:					战场已经持续的时间，单位秒			
--  * 		endTime:					抢粮战结束时间，单位秒
--  * 		roadState					通道状态，1 代表目前属于较少通道 2 代表目前属于较多通道
--  * 		roadLength:[]               数组，表示通道的长度
--  * 		transfer:[1,3,0,4,6,1]  	传送阵信息，每个传送阵上的人数，传送阵标号按照从从上向下，从攻方到守方的顺序，从0开始 
--  * 		road						包含所有在通道上的单位的信息
--  *		[
--  *			id=>array				每个战斗单位数据如下
--  *			{
--  *				type 				如果没有这个字段，就认为是玩家，非NPC之类
--  *						
--  *									以下数据在两种情况下会有：[1]需要的信息的用户刚刚进入战场[2]当前单位刚刚进入通道
--  *				name        		战斗单位名称
--  *				tid					形象id
--  *				transferId  		传送阵id
--  *				maxHp      			最大血量
--  *						
--  *									以下数据在三种情况下会有：[1]需要的信息的用户刚刚进入战场[2]当前单位刚刚进入通道[3]速度发生变化
--  *				speed				速度
--  *							
--  *									以下数据在三种情况下会有：[1]需要的信息的用户刚刚进入战场；[2]当前单位刚刚进入通道；[3]当前单位血量发生改变
--  *				curHp				当前血量
--  *				winStreak			连杀次数
--  *							
--  *									以下数据在四种情况下会有：[1]需要的信息的用户刚刚进入战场；[2]当前单位刚刚进入通道；[3]当前单位发生移动 [4] 速度发生变化
--  *				roadX				在通道上的位置
--  *				stopX				预测单位可能会停止的位置
--  *			}
--  *		]
--  *		spec						蹲点粮仓信息，数组有两个元素，分别代表蹲点粮仓1和蹲点粮仓2
--  *		[
--  *			id=>array
--  *			{
--  *				name				玩家名称
--  *				guildId				所在军团ID
--  *				specId				所在蹲点粮仓，取0和1
--  *				maxHp				最大血量
--  *				currHp				当前血量
--  *				winStreak			连胜次数
--  *				duration			蹲点粮仓占领时间
--  *			}
--  *		]
--  *
--  * }
--  * </code>
--  */
function getEnterInfo(p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			GuildRobBattleData.setRobBattleInfo(dictData.ret.res)
			if(p_callbackFunc ~= nil) then
				p_callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "guildrob.getEnterInfo", "guildrob.getEnterInfo", nil, true)
end

-- /**
--  * join 							参加抢粮战
--  *
--  * @param int $transferId 			传送阵id
--  *
--  * @return string/array
--  * 
--  * 如果返回string,string取值如下其中之一
--  * 
--  * battling							玩家正在战斗中
--  * full								传送阵或者通道上的人数已满
--  * 
--  * 如果返回array,array取值如下其中之一
--  * 
--  * {
--  * 		ret = 'in_spec_barn'		在蹲点粮仓中，无法加入传送阵
--  * 		spec_pos => int				所在蹲点粮仓的编号，从0开始
--  * }
--  * 
--  * {
--  * 		ret = 'waitTime'			处于等待时间，无法加入传送阵
--  * 		waitTime => int				还需要等待的时间
--  * }
--  * 
--  * {
--  * 		ret = 'cdtime'				处于参战冷却时间，无法加入传送阵
--  * 		cdtime => int				还有多长的冷却时间
--  * }
--  * 
--  * {
--  * 		ret = 'ok'
--  * 		outTime = int				出阵时间戳，单位秒
--  * 		reward						参战奖励
--  * 		{	
--  * 			merit => int      
--  * 		}
--  * }
--  *
--  */
function join(p_transferId, p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if bRet == true then
			if dictData.ret.ret == "in_spec_barn" then
				AnimationTip.showTip(GetLocalizeStringBy("lcyx_184"))
				return
			end
			if(dictData.ret.ret == "ok") then
				--增加用户粮草
				GuildRobBattleData.addUserMerit(dictData.ret.reward.grain)
				--增加用户功勋
				GuildRobBattleData.addUserMerit(dictData.ret.reward.merit)
				--设置用户出阵时间
				GuildRobBattleData.setUserGoBattleTime(dictData.ret.outTime)
				if(p_callbackFunc ~= nil) then
					p_callbackFunc(dictData.ret.reward.merit, dictData.ret.outTime)
				end
			elseif dictData.ret.ret == "cdtime" then
				if(p_callbackFunc ~= nil) then
					p_callbackFunc(nil, nil, true)
				end
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(p_transferId))
	Network.rpc(requestFunc, "guildrob.join", "guildrob.join", args, true)
end
--- /**
--  * leave								退出战场
-- 
--  * @return string
--  * ret = ok 							成功
--  */
 function leave(p_callbackFunc)
 	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(p_callbackFunc ~= nil) then
				p_callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "guildrob.leave", "guildrob.leave", nil, true)
 end


---
--  removeJoinCd 						秒除参战冷却时间
--  @return string
--  * ret = ok 							成功
--  * res = 5 							实际花费的金币数
--  */
function removeJoinCd(p_callbackFunc)
 	local requestFunc = function( cbFlag, dictData, bRet )
 		if bRet == true then
 			if(dictData.ret== "nocd") then
 				AnimationTip.showTip(GetLocalizeStringBy("lcyx_185"))
 				return
 			end
	 		--减金币
			UserModel.addGoldNumber(-tonumber(dictData.ret.res))
			--更新cd时间
			GuildRobBattleData.setCanJoinTime(BTUtil:getSvrTimeInterval())
			--增加清除cd次数
			GuildRobBattleData.addRemoveCDNum(1)
			if(bRet == true) then
				if(p_callbackFunc ~= nil) then
					p_callbackFunc(dictData.ret.res)
				end
			end
		end
	end
	Network.rpc(requestFunc, "guildrob.removeJoinCd", "guildrob.removeJoinCd", nil, true)
end
--- /**
--  * speedUp 							加速
--  *
--  * @param int p_multiple 			加速的倍数
--  *
--  * @return string
--  * ret = ok 							成功
--  * 		 limit 						加速次数已经超过限制
--  * res = 5 							实际花费的金币数
--  */
function speedUp(p_multiple, p_callbackFunc)
 	local requestFunc = function( cbFlag, dictData, bRet )
	 	if bRet == true then
	 		if(dictData.ret == "not_in_road") then
	 			AnimationTip.showTip(GetLocalizeStringBy("lcyx_186"))
	 			return
	 		end
	 		if(dictData.ret == "not_in_transfer") then
	 			AnimationTip.showTip(GetLocalizeStringBy("lcyx_187"))
	 			return
	 		end
			-- 减金币
			UserModel.addGoldNumber(-tonumber(dictData.ret.res))
			GuildRobBattleData.setSpeedNum(1)
			if(bRet == true) then
				if(p_callbackFunc ~= nil) then
					p_callbackFunc()
				end
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(p_multiple))
	Network.rpc(requestFunc, "guildrob.speedUp", "guildrob.speedUp", args, true)
end
-- /**
--  * enterSpecBarn 					攻击牛掰粮仓
--  *
--  * @return string/array
--  * 
--  * 如果返回string，取值如下
--  * in_road							在传送阵或者通道中，无法进入蹲点粮仓	
--  * in_spec_barn						已经在蹲点粮仓上啦，不能再次进入
--  * waitTime							处于等待时间
--  * cdtime							处于冷却时间
--  * same_guild						当前蹲点粮仓上的成员是自己军团的，不能抢占
--  * fail								抢占蹲点粮仓失败				
--  * 
--  * 如果返回array,取值如下
--  * 
--  * array							表示占领蹲点粮仓成功
--  * {
--  * 		id=>array
--  *			{
--  *				name				玩家名称
--  *				tid					形象id
--  *				guildId				所在军团ID
--  *				specId				所在蹲点粮仓，取0和1
--  *				maxHp				最大血量
--  *				curHp				当前血量
--  *				winStreak			连胜次数
--  *				limit				蹲点粮仓最长占领时间
--  *				duration			蹲点粮仓占领时间
--  *			}
--  * }
--  */
function enterSpecBarn(p_pos, p_callbackFunc)
 	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			--此处暂时只发请求，不处理，由推送来处理
			-- if(dictData.ret == "in_road") then
			-- 	AnimationTip.showTip("你玩家已经加入了战斗！")
			-- 	return
			-- end
			-- if(dictData.ret == "fail") then
			-- 	AnimationTip.showTip("占领失败")
			-- 	return
			-- end
			-- if(dictData.ret == "same_guild") then
			-- 	AnimationTip.showTip("已经被己方玩家占领!")
			-- 	return
			-- end
			-- if(dictData.ret == "in_spec_barn") then
			-- 	AnimationTip.showTip("您只能占领1块粮草堆，不能再占领!")
			-- 	return
			-- end
			-- if(dictData.ret == "cdtime") then
			-- 	AnimationTip.showTip("你当前处于cd状态不能抢夺!")
			-- 	return
			-- end
			-- if(dictData.ret == "cdtime") then
			-- 	AnimationTip.showTip("你当前处于cd状态不能抢夺!")
			-- 	return
			-- end
			-- --更新蹲点粮仓信息 ,此信息由推送处理
			-- -- GuildRobBattleData.setSpecBronInfo(dictData.ret)
			-- if(p_callbackFunc ~= nil) then
			-- 	p_callbackFunc(GuildRobBattleData.getSpecBronInfo())
			-- end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(p_pos))
	Network.rpc(requestFunc, "guildrob.enterSpecBarn", "guildrob.enterSpecBarn", args, true)
end
--- /**
-- 
--  * getRankByKill 					获取击杀排行榜
--  *
--  * @return array
--  * 	topN							击杀排行榜
--  *	[
--  *		{
--  *			uid						战斗单位id
--  *			uname					战斗单位名称
--  *			kill					战斗单位击杀数量
--  *		}
--  *	]
--  */
function getRankByKill(p_callbackFunc)
 	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			GuildRobBattleData.setRankInfo(dictData.ret)
			if(p_callbackFunc ~= nil) then
				p_callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "guildrob.getRankByKill", "guildrob.getRankByKill", nil, true)
end
-- /*******************以下是后端推送给前端的数据****************************/
-- /*和getEnterInfo接口内容结构一致
-- }
function registerPushRefresh( p_callbackFunc )
	local requestCallback = function ( cbFlag, dictData, bRet )
		if (dictData.err == "ok") then
			--刷新战斗玩家信息
			GuildRobBattleData.refreshBattleInfo(dictData.ret)
			p_callbackFunc()
		end
	end
	Network.re_rpc(requestCallback, "push.guildrob.refresh", "push.guildrob.refresh")
end


-- [2]push.guildrob.fightResult 		任何一场战斗结束都需要向战场所有玩家广播战斗结果
-- {
-- 	winnerId						胜者id
-- 	loserId							败者id 
-- 	winnerName						胜者名字
-- 	loserName						败者名字
-- 	winStreak						胜利者连胜次数
-- 	loseStreak						失败者在此次失败之前的连胜次数
--  winnerOut						
-- 	brid							战报id
-- }
function registerPushFightResult( p_callback )
	local requestCallback = function ( cbFlag, dictData, bRet )
		--先回调
		if (dictData.err == "ok") then
			p_callback(dictData.ret)
		end
		GuildRobBattleData.addReportInfo(dictData.ret)
	end
	Network.re_rpc(requestCallback, "push.guildrob.fightResult", "push.guildrob.fightResult")
end



-- [3]push.guildrob.fightWin			给胜者单独发送的信息
-- {			
-- 	reward							胜者奖励信息
-- 	{
-- 		userGrain				   	用户获得的粮草
-- 		guildGrain  				公会获得的粮草
-- 		merit       				 用户获得的功勋
-- 		contr                       用户获得的个人贡献
-- 	}
-- 	extra							扩展信息
-- 	{
-- 		adversaryName				对手名称
-- 		joinCd                      从新参战的CD时间
--		winnerOut
-- 	}
-- }
function registerPushFightWin( p_callback )
	local requestCallback = function ( cbFlag, dictData, bRet )
		if (dictData.err == "ok") then
			if dictData.ret.extra.winnerOut == "true" then
				GuildRobBattleData.setCanJoinTime(dictData.ret.extra.joinCd)
			end
			--增加用户粮草
			GuildRobBattleData.addUserGrain(dictData.ret.reward.userGrain)
			--增加用户功勋
			GuildRobBattleData.addUserMerit(dictData.ret.reward.merit)
			--增加军团粮草
			GuildRobBattleData.addGuildGrain(dictData.ret.reward.guildGrain)
			--用户获得的军团贡献
			GuildDataCache.addGuildDonate(dictData.ret.reward.contr)
			if p_callback ~= nil then
				p_callback(dictData.ret)
			end
		end
	end
	Network.re_rpc(requestCallback, "push.guildrob.fightWin", "push.guildrob.fightWin")
end
	
-- [4]push.guildrob.fightLose			给败者单独发送的信息
-- {
-- 	reward							败者奖励信息，值为负代表需要扣除
-- 	{
-- 		userGrain				   	用户获得的粮草
-- 		guildGrain  				公会获得的粮草
-- 		merit       				 用户获得的功勋
-- 		contr                       用户获得的个人贡献
-- 	}
-- 	extra							扩展信息
-- 	{
-- 		adversaryName				对手名称
-- 		joinCd                      从新参战的CD时间
-- 	}
-- }
function registerPushFightLose( p_callback )
	local requestCallback = function ( cbFlag, dictData, bRet )

		if (dictData.err == "ok") then
			GuildRobBattleData.setCanJoinTime(dictData.ret.extra.joinCd)
			GuildRobBattleData.setSpeedNum(0)
			--增加用户粮草
			GuildRobBattleData.addUserGrain(dictData.ret.reward.userGrain)
			--增加用户功勋
			GuildRobBattleData.addUserMerit(dictData.ret.reward.merit)
			--增加军团粮草
			GuildRobBattleData.addGuildGrain(dictData.ret.reward.guildGrain)
			--用户获得的军团贡献
			GuildDataCache.addGuildDonate(dictData.ret.reward.contr)

			if p_callback ~= nil then
				p_callback(dictData.ret)
			end
		end
	end
	Network.re_rpc(requestCallback, "push.guildrob.fightLose", "push.guildrob.fightLose")
end

-- [5]push.guildrob.touchDown			给达阵者单独发送的信息
-- {
-- 	reward							达阵者奖励信息
-- 	{
-- 		userGrain				   	用户获得的粮草
-- 		guildGrain  				公会获得的粮草
-- 		merit       				 用户获得的功勋
-- 		contr                       用户获得的个人贡献
-- 	}
-- 	extra							扩展信息
-- 	{
-- 		joinCd                      从新参战的CD时间
-- 	}
-- }
function registerPushTouchDown( p_callback )
	local requestCallback = function ( cbFlag, dictData, bRet )
		if (dictData.err == "ok") then
			--更新cd时间
			GuildRobBattleData.setCanJoinTime(dictData.ret.extra.joinCd)
			--更新加速状态
			GuildRobBattleData.setSpeedNum(0)
			--增加用户粮草
			GuildRobBattleData.addUserGrain(dictData.ret.reward.userGrain)
			--增加用户功勋
			GuildRobBattleData.addUserMerit(dictData.ret.reward.merit)
			--增加军团粮草
			GuildRobBattleData.addGuildGrain(dictData.ret.reward.guildGrain)
			--用户获得的军团贡献
			GuildDataCache.addGuildDonate(dictData.ret.reward.contr)
			if p_callback ~= nil then
				p_callback(dictData.ret)
			end
		end
	end
	Network.re_rpc(requestCallback, "push.guildrob.touchDown", "push.guildrob.touchDown")
end
-- [6]push.guildrob.battleEnd          一整场战斗结束后发送的信息
-- {
-- 	ret = 'ok'
-- }
function registerPushBattleEnd( p_callback )
	local requestCallback = function ( cbFlag, dictData, bRet )
		if (dictData.err == "ok") then
			if p_callback ~= nil then 
				p_callback(dictData.ret)
			end
		end
	end
	Network.re_rpc(requestCallback, "push.guildrob.battleEnd", "push.guildrob.battleEnd")
end
-- [7]push.guildrob.reckon				战斗结束后的玩家结算数据
-- {
-- 	rank
-- 	kill
--  contr
-- 	userGrain
-- 	guildGrain
-- 	merit
-- 	duration
-- }
function registerPushReckon( p_callback )
	local requestCallback = function ( cbFlag, dictData, bRet )
		GuildRobBattleData.setAfterBattleInfo(dictData.ret)
		if (dictData.err == "ok") then
			if p_callback ~= nil then
				p_callback(dictData.ret)
			end
		end
	end
	Network.re_rpc(requestCallback, "push.guildrob.reckon", "push.guildrob.reckon")
end
-- [8]push.guildrob.topN			击杀排行榜
-- {
-- 	[
-- 		{
-- 			id						战斗单位id								
-- 			uname					战斗单位名称
-- 			killNum					击杀数量
--			rank 					排名
-- 		}
-- 	]
-- }
function registerPushTopN( p_callback )
	local requestCallback = function ( cbFlag, dictData, bRet )
		--刷新排行榜信息
		GuildRobBattleData.setRankInfo(dictData.ret)
		if (dictData.err == "ok") then
			if p_callback ~= nil then
				p_callback(dictData.ret)
			end
		end
	end
	Network.re_rpc(requestCallback, "push.guildrob.topN", "push.guildrob.topN")
end


-- [9]push.guildrob.info			军团抢粮区域推送信息
-- {
-- 	guildId							军团ID
-- 	name 							军团名称
-- 	grain							可抢粮草
-- 	barn_level						军团粮仓等级
-- 	robId                           抢粮战唯一ID，如果为0表示军团不在任何抢粮战中，如果不为0，表示抢粮战唯一ID
-- }

-- [10]push.guildrob.spec    			蹲点粮仓推送信息
-- [
-- 	userInfo => array
-- 	[
-- 		id => array
-- 		{
-- 										以下字段只有在蹲点粮仓占有者发生变化的时候才发送
-- 			name						玩家名称
-- 			tid							形象id
-- 			guildId						所在军团ID
-- 			specId						所在蹲点粮仓，取0和1
-- 			maxHp						最大血量
-- 			endTime:					蹲点到期时间
-- 										以下字段只有在血量发生变化的时候
-- 			curHp						当前血量
-- 										以下字段只有在连胜次数发生变化时候才发送
-- 			winStreak					连胜次数
-- 		}
-- 	]
-- 										这两个字段，只有在蹲点粮仓的时间达到上限以后，才会传递
-- 	outSpecId							如果传递了该字段，字段的值是蹲点粮仓编号，表示该蹲点粮仓需要置空
-- 	joinCd								原来在outSpecId的粮仓上的玩家的cd
-- ]
function registerPushSpec( p_callback )
	local requestCallback = function ( cbFlag, dictData, bRet )
		if (dictData.err == "ok") then
			GuildRobBattleData.setSpecBronInfo(dictData.ret)
			if p_callback ~= nil then
				p_callback(GuildRobBattleData.getSpecBronInfo())
			end
		end
	end
	Network.re_rpc(requestCallback, "push.guildrob.spec", "push.guildrob.spec")
end

function registerPushEnterSpecRet( p_callbackFunc )
	local requestCallback = function ( cbFlag, dictData, bRet )
		if (dictData.err == "ok") then
			if(dictData.ret == "in_road") then
				AnimationTip.showTip(GetLocalizeStringBy("lcyx_188"))
				return
			end
			if(dictData.ret == "fail") then
				AnimationTip.showTip(GetLocalizeStringBy("lcyx_189"))
				return
			end
			if(dictData.ret == "same_guild") then
				AnimationTip.showTip(GetLocalizeStringBy("lcyx_1810"))
				return
			end
			if(dictData.ret == "in_spec_barn") then
				AnimationTip.showTip(GetLocalizeStringBy("lcyx_1811"))
				return
			end
			if(dictData.ret == "cdtime") then
				AnimationTip.showTip(GetLocalizeStringBy("lcyx_1812"))
				return
			end
			if(dictData.ret == "cdtime") then
				AnimationTip.showTip(GetLocalizeStringBy("lcyx_1813"))
				return
			end
			--更新蹲点粮仓信息
			GuildRobBattleData.setSpecBronInfo(dictData.ret)
			if(p_callbackFunc ~= nil) then
				p_callbackFunc(GuildRobBattleData.getSpecBronInfo())
			end
		end
	end
	Network.re_rpc(requestCallback, "push.guildrob.enterSpecRet", "push.guildrob.enterSpecRet")
end


