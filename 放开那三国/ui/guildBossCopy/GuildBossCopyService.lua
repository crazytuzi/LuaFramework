-- FileName: GuildBossCopyService.lua
-- Author: bzx
-- Date: 15-03-31 
-- Purpose: 军团副本接口

module("GuildBossCopyService", package.seeall)

require "script/ui/guildBossCopy/GuildBossCopyData"
-- /**
--  * 获得玩家军团副本的基本信息，如果玩家不在任何军团，则返回空数组
--  * 
--  * @return
--  * {
--  * 		curr        	   						今天攻击目标副本Id
--  * 		next    								明天攻击目标副本Id
--  *      max_pass_copy							通关的最大军团副本id
--  *      refresh_num								军团今天使用“全团突击”的次数，为军团全体成员加n次攻击次数
--  *      refresh_time							玩家自己今天点击“全团突击”的时间，如果为0，代表今天还没有点击过
--  *      pass_time								当前副本通关时间，如果为0代表当前副本没有通关         （前端没有用这个字段，是根据curr_hp来判断的）
--  * 		atk_damage								玩家今天造成的总伤害
--  * 		atk_num      							玩家今天总的可以攻击的次数（包括系统默认的，“全团突击”的，自己买的）
--  * 		buy_num 	   							已经购买的次数
--  * 		recv_pass_reward_time					通关后，领取阳光普照奖的时间，如果为0，代表今天未领取
--  * 		recv_box_reward_time					通关后，领取宝箱奖励的时间，如果为0，代表今天未领取
--  * 		total_hp								当前副本拥有的总血量
--  * 		curr_hp									当前副本剩余的总血量
--  * }
function getUserInfo(p_callback)
	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		GuildBossCopyData.setUserInfo(dictData.ret)
		if p_callback then
			p_callback()
		end
	end
	Network.rpc(requestFunc, "guildcopy.getUserInfo", "guildcopy.getUserInfo", nil, true)
end

	-- /**
	--  * 获取副本信息
	--  * 
	--  * @param int $copyId
	--  * @return 
	--  * [
	--  * 		base_id => array                 	据点信息
 --     *      {
 --     *    	     hp => array                  	据点血量信息，如果没有被攻打过，没有hp
 --     *           [
 --     *               htid => array(total,curr) 	武将血量信息
 --     *           ]
 --     *           type => array()               	据点类型（魏蜀吴群,1234）
 --     *           max_damager => array           造成最大伤害的玩家信息，如果没有被攻打过，就没有max_damager
 --     *           {
 --     *               htid							
 --     *               uname						
 --     *               damage
 --     *           }
 --     *      }
	--  * ]
	--  */
function getCopyInfo( p_callback, p_copyId )
	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		GuildBossCopyData.setCopyInfo(dictData.ret)
		if p_callback then
			p_callback()
		end
	end
	local args = Network.argsHandler(p_copyId)
	Network.rpc(requestFunc, "guildcopy.getCopyInfo", "guildcopy.getCopyInfo", args, true)
	-- local data = {
 --          	ret = {
 --        	    hp = {
 --                  ["1000"] = {
 --                  	total = "100",
 --                  	curr = "13",
 --                  }
 --               	},
 --              	type = {"1", "2"},
 --              	max_damager = {
 --                  htid = "20101",						
 --                  uname = "刘鹏鹏", 					
 --                  damage = "322131",
 --              }
 --        }
 --       requestFunc(nil, data, true)
end

-- /**
--  * 设置攻打目标副本
--  * 
--  * @param int $copyId
--  * 
--  * @throws
--  * @return 'ok'
--  */
function setTarget( p_callback, p_copyId )
	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		GuildBossCopyData.setTarget(p_copyId)
		if p_callback then
			p_callback()
		end
	end
	local args = Network.argsHandler(p_copyId)
	Network.rpc(requestFunc, "guildcopy.setTarget", "guildcopy.setTarget", args, true)
end

-- /**
--  * 攻击据点
--  * 
--  * @param int $copyId
--  * @param int $baseIndex
--  * 
--  * @return
--  * {
--  * 		ret => 'ok'|'dead'				以下字段只有在ok的情况下才有效,dead代表这个据点已经被击破啦
--  * 		fight_ret => array()			战斗战斗串
--  * 		damage => int 					伤害
-- 			hp => array                  	据点血量信息，如果没有被攻打过，没有hp
--  *           [
--  *               htid => array(total,curr) 	武将血量信息
--  *           ]
--  * 		kill => int 					是否击杀0|1
--  * } 
--  */
function attack( p_callback, p_copyId, p_baseIndex )
	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		GuildBossCopyData.attack(dictData.ret, p_baseIndex)
		if p_callback then
			p_callback(dictData.ret)
		end
	end
	local args = Network.argsHandler(p_copyId, p_baseIndex)
	Network.rpc(requestFunc, "guildcopy.attack", "guildcopy.attack", args, true)
	-- local data = {
 --      	ret = {
 --         	ret = "dead",
 --         -- 	fight_ret = "eJylUz9oE2EUvy95Tb0eoR4xxNpBFC2CEpK0NTGUorWUVERKU9oS0fo19yU5cv/87q5at4ZAi5UOIt1cXBycHPyHiA52cai7u4uD0k2cfF/uUicR6vAd7+/v99679/oUEl+mnmcwOUr6FKKiTKtNxqH16uuOqrEaszTU3n1ZiNOqp9sWrDcUbvuWBiRFOZ9lgTlI7zeppdl3rCiIDJWHTiAJDJ2kJq2HPEmto8ytOgxxAmWeGj6D1hwhGO44nOouNWK95XJZXq5PayDJngiX+k3f1asdwzLXNXhyXfW5sSTk2IkL+dF8bXQ4p+Xz1cwIrSkeo2YWGWWLmiwWz+aymUy+18e8tWenFYOtMAMqKc/2qFFyLtuuB5KquzMGXWU82o9llxi35bgoureBWWIucsNDaVdVHdvVOw1KaSADbMU2VthSgCkpJr1bcmDrllr1cU7YIEQS7LavO9NWzUa4OOWmbtVRimZBiubwDeMbAYkk3KZuGBO23ZQJUT2co+tzhpFTIJXQr2icuW6gk0RNrze8su0bGJyo29oCow7+ETFHjrRlgQXrPBX821BtiI7OQ+v5x7cFWHscKwJJQ2UMIuOwwy9CZALdk/uMV0C6irWNIt01BJ75U8psWMUcmucFZ2Bo7xGyCO0bFWgvhkxvPg0WYPdsESI4rDGQxuGB+Reif5Iswua9Cmw6IfTrnz8K8LlUhGgX+n7vwaG3T1Zg+2gI/fLRHlZ9pAjQhX6YPDj0RroCG6f2R/8BoRNF6OlCbx3/D+hjCH2YJDvbMGXzKoNf5QFDF8c9xXW84+D0kPjFt+9InCwiQBKXgoduQpQqpzUPg3pwv7HhQTSJA8qh6UxMxtMZPgfrzTT0ZKA1lIuMdCHx2gvi09mioJfWkOhF7C8eUWfpZFHm+4kKPD1EbkLbIqmazl3vUmctgZDfFQgF+A==",
 --         -- 	damage = "294",
 --        	-- kill = "1",
 --        }
	-- }
	-- requestFunc(nil, data, true)
end


-- /**
-- * 获得排行榜信息，包含全服排行和军团排行
-- * 
-- * @return
-- * {
-- * 		all => array
-- * 		[
-- * 			{
-- * 				rank
-- * 				htid
-- * 				vip
-- *              level
-- *              fight_force
-- *              dress => array()
-- * 				uname
-- * 				guild_name
-- * 				damage
-- * 			}
-- * 		]
-- * 		guild => array
-- * 		[
-- * 			{
-- * 				rank
-- * 				htid
-- * 				vip
-- *              level
-- *              fight_force
-- *              dress => array()
-- * 				uname
-- * 				damage
-- * 			}
-- * 		]
-- *		guild_copy => array
-- * 		[
-- * 			{
-- *				rank
-- *				guild_id
-- * 				guild_name
-- *				guild_level
-- *				fight_force
-- *				max_pass_copy
-- *				pass_time
-- *			}
-- * 		]
-- * }
-- * 
-- */
function getRankList( p_callback )
	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		GuildBossCopyData.setRankList(dictData.ret)
		if p_callback then
			p_callback()
		end
	end
	Network.rpc(requestFunc, "guildcopy.getRankList", "guildcopy.getRankList", nil, true)
end
	
-- /**
--  * 玩家自己通过购买增加攻击次数
--  * 
--  * @return 'ok'/'already_pass'
--  */
function addAtkNum( p_callback )
	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		if dictData.ret == "ok" then
			GuildBossCopyData.buyAtkNum()
		end
		if p_callback then
			p_callback(dictData.ret)
		end
	end
	Network.rpc(requestFunc, "guildcopy.addAtkNum", "guildcopy.addAtkNum", nil, true)
	-- local data = {
	-- 	ret = {
	-- 		ret = "ok"
	-- 	}
	-- }
	-- requestFunc(nil, data, true)
end

-- /**
--  * 刷新全体军团成员攻击次数
--  * 
--  * @return 'ok'/'already_pass'/'lack'  分别代表  ‘没问题’/‘军团已经通关’/‘军团今天总的全团突击次数用光’
--  */
function refresh( p_callback )
	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		if dictData.ret == "ok" then
			GuildBossCopyData.buyAllKill()
		end
		if p_callback then
			p_callback(dictData.ret)
		end
	end
	Network.rpc(requestFunc, "guildcopy.refresh", "guildcopy.refresh", nil, true)
	-- local data = {
	-- 	ret = "ok"
	-- }
	-- requestFunc(nil, data, true)
end
	
-- /**
--  * 通过副本后，军团成员领取"阳光普照奖"
--  * 
--  * @return 'ok'/'after_pass'
--  */
function recvPassReward( p_callback )
	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		GuildBossCopyData.recvPassReward()
		if p_callback then
			p_callback(dictData.ret)
		end
	end
	Network.rpc(requestFunc, "guildcopy.recvPassReward", "guildcopy.recvPassReward", nil, true)
end
	
-- /**
--  * 获得宝箱的信息，为空数组，代表没有人领取了任何一个宝箱
--  * 
--  * @return
--  * [
--  * 		id => array
--  * 		{
--  * 			uid			领取这个宝箱的uid
--  * 			uname		领取这个宝箱的uname
--  * 			reward		这个宝箱中的奖励Id
--  * 		}
--  * ]
--  */
function getBoxInfo( p_callback )
	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		local data = {
			last = "1",
			box = dictData.ret
		}
		-- GuildBossCopyData.setLastBoxInfo(data)
		GuildBossCopyData.setBoxInfo(dictData.ret)
		if p_callback then
			p_callback()
		end
	end
	Network.rpc(requestFunc, "guildcopy.getBoxInfo", "guildcopy.getBoxInfo", nil, true)
	-- local data = {
	-- 	ret = {
	-- 		["1"] = {
	-- 			uname = "hehe", 
	-- 			reward = "0",
	-- 		}
	-- 	}
	-- }
	-- requestFunc(nil, data, true)
end

-- /**
--  * 获得宝箱的信息，为空数组，代表昨天没有开启这个功能
--  * 
--  * @return
--  * {
--  *   last = int 			昨天攻打的groupCopyId
--  * 	box => array
--  *	[
-- 	*	
--  * 		id => array
--  * 		{
--  * 			uid			领取这个宝箱的uid
--  * 			uname		领取这个宝箱的uname
--  * 			reward		这个宝箱中的奖励Id
--  * 		}
--  * 	]
--  * }
--  */
function getLastBoxInfo( p_callback )
	local requestFunc = function ( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		GuildBossCopyData.setLastBoxInfo(dictData.ret)
		if p_callback then
			p_callback()
		end
	end
	Network.rpc(requestFunc, "guildcopy.getLastBoxInfo", "guildcopy.getLastBoxInfo", nil, true)
end

-- /**
--  * 通关副本后，军团成员抽取"宝箱奖励"
--  * 
--  * @param int $boxId
--  * @return
--  * {
--  * 		ret：'ok'/'already'/'after_pass'，分别代表“没问题”/“这个宝箱已经被别人领走啦”/“通过后才加入的军团”
--  * 		extra: 如果是ok，这里是奖励Id
--  * 			         如果是already，这个是领取者的数组
--  * 				{
--  * 					uid => int
--  * 					uname => string
--  * 					reward => 奖励Id
--  * 				}
--  * }
--  */
function openBox( p_callback, p_boxId )
	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		local openBoxInfo = nil
		if dictData.ret.ret == "ok" then
			openBoxInfo = {}
			openBoxInfo.uid = UserModel.getUserUid()
			openBoxInfo.htid = UserModel.getAvatarHtid()
			openBoxInfo.uname = UserModel.getUserName()
			openBoxInfo.reward = dictData.ret.extra
		elseif dictData.ret.ret == "already" then
			openBoxInfo = dictData.ret.extra
		end
		if openBoxInfo ~= nil then
			GuildBossCopyData.setOpenBoxInfo(openBoxInfo, p_boxId)
		end

		if p_callback then
			p_callback(dictData.ret)
		end
	end
	local args = Network.argsHandler(p_boxId)
	Network.rpc(requestFunc, "guildcopy.openBox", "guildcopy.openBox", args, true)

  	-- local data = {
   --    	err = "ok",
   --    	callback = {
   --            callbackName = "guildcopy.openBox"
   --        },
   --    	ret = {
   --            ret = "already",
   --            extra = {
   --            	htid = UserModel.getAvatarHtid(),
   --            	uname = "{",
   --            	reward = 1,
   --        	}
   --        }
  	-- }
  	-- requestFunc(nil, data, true)
end

-- /**
--  * 获取商店信息
--  *
--  * @return array
--  * [
--  * 		$goodsId => array			商品id
--  * 		{
--  * 			'num' => int			购买次数
--  * 			'time' => int			购买时间
--  * 		}
--  * ]
--  */
function getShopInfo( p_callback )
	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		GuildBossCopyData.setShopInfo(dictData.ret)
		if p_callback then
			p_callback()
		end
	end
	Network.rpc(requestFunc, "guildcopy.getShopInfo", "guildcopy.getShopInfo", nil, true)
end

	
-- /**
--  * 兑换商品
--  *
--  * @param int $goodsId				商品id
--  * @param int $num					数量
--  * 
--  * @return string 'ok'
-- */
function buy( p_callback, p_goodsId, p_num )
	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		GuildBossCopyData.buy(p_goodsId, p_num)
		if p_callback then
			p_callback()
		end
	end
	local args = Network.argsHandler(p_goodsId, p_num)
	Network.rpc(requestFunc, "guildcopy.buy", "guildcopy.buy", args, true)
	-- local data = {
	-- 	ret = "ok"
	-- }
	-- requestFunc(nil, data, true)
end

--  *{
--  *		total => int
--  *		uname => string
--  *}
--  */
function rePushGuildcopyUpdateRefreshNum()
 	local pushFunc = function ( cbFlag, dictData, bRet )
 		if not bRet then
 			return
 		end
 		GuildBossCopyData.pushGuildcopyUpdateRefreshNum(dictData.ret)
 		require "script/ui/guildBossCopy/CopyPointLayer"
 		CopyPointLayer.refreshRemainAttackTimes()
 		CopyPointLayer.loadBuyAllAttackTip()
 	end
 	Network.re_rpc(pushFunc,"push.guildcopy.update_refresh_num","push.guildcopy.update_refresh_num")
-- local data = {
--       err = "ok",
--       callback = {
--               callbackName = "pubsh.guildcopy.update_refresh_num"
--           },
--       ret = {
--               total = "6",
--               uname = "deve"
--           }
--   }
--   pushFunc(nil, data, true)
end

 -- *
 -- *{
 -- *		uname => string
 -- *}
function rePushGuildcopyCurrCopyPass( ... )
 	local pushFunc = function ( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		GuildBossCopyData.pushGuildcopyCurrCopyPass()
		require "script/ui/guildBossCopy/CopyPointLayer"
		CopyPointLayer.refreAllPointSprite()
 	end
 	Network.re_rpc(pushFunc,"push.guildcopy.curr_copy_pass", "push.guildcopy.curr_copy_pass")
end

-- /**
-- 	 * Boss信息
-- 	 * 
-- 	 * @param void
-- 	 * @return array  
-- 	 * { 
-- 	 *  hp : int ,							当前boss血量
-- 	 *  max_hp : int,						boss最高血量
-- 	 *  cd : int , 							下一次boss刷新时间	
-- 	 * 	atk_boss_num : int ,				当前进攻的次数
-- 	 *  buy_boss_num : int ,    			购买的次数
--  	 * }
-- 	 * */
-- 	public function bossInfo();
function getBossInfo(p_callback)
	print("getBossInfo")
	local getBossFunc = function ( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		GuildBossCopyData.setBossInfo(dictData.ret)
		if(p_callback)then
			p_callback(dictData.ret.hp)
		end
 	end
 	Network.rpc(getBossFunc,"guildcopy.bossInfo", "guildcopy.bossInfo", nil, true)
end

-- /**
-- 	 * 购买BOSS攻击次数
-- 	 * @param $count int 购买的次数
-- 	 * 
-- 	 * @return 'ok'
-- 	 * */
-- 	public function buyBoss($count);
function buyBossTime( p_callback,p_gold )
	-- body
	local buyTimeFunc = function ( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		UserModel.addGoldNumber(-p_gold)
		GuildBossCopyData.setBuyTime()
		if(p_callback)then
			p_callback(dictData.ret)
		end
 	end
 	local args = Network.argsHandler(1)
 	Network.rpc(buyTimeFunc,"guildcopy.buyBoss", "guildcopy.buyBoss", args ,true)
end

-- /**
-- 	 * 攻击BOSS
-- 	 * @param void
-- 	 * 
-- 	 * @return 
-- 	 * [
-- 	 * 		ret => 'ok'|'conflict'|'cd'			以下字段只有在ok的情况下才有效,conflict代表别人同时在请求，cd代表BOSS正在CD中
-- 	 * 		fight_ret => array()				战斗战斗串
-- 	 * 		kill => int 						是否击杀0|1
-- 	 * 		boss_info => array ( 'hp'=> int , 'cd' => int, 'max_hp' => int )
-- 	 * ]
-- 	 * */
-- 	public function attackBoss();
function attackBoss(p_callback)
	-- body
	print("attackBoss")
	local buyTimeFunc = function ( cbFlag, dictData, bRet )
		if not bRet or dictData.ret.ret~="ok" then
			return
		end
		if(p_callback)then
			p_callback(dictData.ret)
		end
 	end
 	Network.rpc(buyTimeFunc,"guildcopy.attackBoss", "guildcopy.attackBoss", nil, true)
end