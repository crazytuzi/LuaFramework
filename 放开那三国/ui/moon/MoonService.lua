-- Filename：	MoonService.lua
-- Author：		bzx
-- Date：		2015-05-06
-- Purpose：		水月之镜网络层

module("MoonService", package.seeall)

btimport "script/ui/moon/MoonData"
-- <?php
-- /***************************************************************************
--  * 
--  * Copyright (c) 2010 babeltime.com, Inc. All Rights Reserved
--  * $Id: IMoon.class.php 170909 2015-05-05 05:23:50Z BaoguoMeng $
--  * 
--  **************************************************************************/

--  /**
--  * @file $HeadURL: svn://192.168.1.80:3698/C/trunk/card/rpcfw/module/moon/IMoon.class.php $
--  * @author $Author: BaoguoMeng $(mengbaoguo@babeltime.com)
--  * @date $Date: 2015-05-05 13:23:50 +0800 (星期二, 05 五月 2015) $
--  * @version $Revision: 170909 $
--  * @brief 
--  *  
--  **/

-- /*******************************接口修改记录*******************************
--  * 创建接口 									20150421-14:20:00
--  * 商店的接口去掉了一些不必须要的字段					20150422-18:48:00
--  * 商店增加buyBox接口，开宝箱						20150505-12:04:00
--  * getShopInfo增加字段buy_box_count			20150505-13:18:00
-- *
-- * @author Administrator
-- * 
-- *
-- */
 
-- interface IMoon
-- {
-- 	/**
-- 	 * 获得基本信息
-- 	 * 
-- 	 * @return
-- 	 * {
-- 	 * 		tg_num								天工令，操蛋的名字
-- 	 * 		atk_num								攻击BOSS的次数
-- 	 * 		buy_num								今天购买的次数
-- 	 * 		max_pass_copy						已经通关的最大副本Id
-- 	 * 		nightmare_atk_num 					梦魇可攻打次数（购买次数 + 免费剩余次数）
--   * 		nightmare_buy_num 					梦魇购买次数
-- 	 * 		max_nightmare_pass_copy 			已经通关的最大梦魇bossId
-- 	 * 		grid => array						最新的副本信息
-- 	 * 		[
-- 	 * 			index => status					index取值1-9,status取值1-3分别代表 锁定/解锁/已攻打或者已领取
-- 	 * 		]
-- 	 * }
-- 	 */
function getMoonInfo(p_callback)
	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		MoonData.setMoonInfo(dictData.ret)
		if p_callback then
			p_callback()
		end
	end
	Network.rpc(requestFunc, "moon.getMoonInfo", "moon.getMoonInfo", nil, true)
end
-- 	/**
-- 	 * 攻打某个副本某个格子的怪物
-- 	 * 
-- 	 * @param int $copyId
-- 	 * @param int $gridId
-- 	 * @return array
-- 	 * {
-- 	 * 		ret	=> 'ok'							返回值
-- 	 * 		fightRet => string					战斗串
-- 	 * 		appraise => int						战斗评价
-- 	 * 		open_grid => array(index)			开启的所有新格子
-- 	 * 		open_boss => int					是否开启了本副本的BOSS，1开启，0未开启
-- 	 * }
-- 	 */
function attackMonster(p_callback, p_copyId, p_gridId)
	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		MoonData.setAttackMonsterInfo(dictData.ret, p_gridId)
		if p_callback then
			p_callback(dictData.ret)
		end
	end
	local args = Network.argsHandler(p_copyId, p_gridId)
	Network.rpc(requestFunc, "moon.attackMonster", "moon.attackMonster", args, true)
end
	
-- 	/**
-- 	 * 领取某个副本某个格子的的宝箱
-- 	 *
-- 	 * @param int $copyId
-- 	 * @param int $gridId
-- 	 * @return array
-- 	 * {
-- 	 * 		ret	=> 'ok'							返回值
-- 	 * 		open_grid => array(index)			开启的所有新格子
-- 	 * 		open_boss => int					如果胜利的话，并且开启了所有的格子，这个字段是1,否则是0
-- 	 * }
-- 	 */
function openBox(p_callback, p_copyId, p_gridId)
	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		MoonData.setOpenBoxInfo(dictData.ret, p_gridId)
		if p_callback then
			p_callback()
		end
	end
	local args = Network.argsHandler(p_copyId, p_gridId)
	Network.rpc(requestFunc, "moon.openBox", "moon.openBox", args, true)
	-- local data = {
 --      	err = "ok",
 --      	callback = {
 --            callbackName = "moon.openBox",
 --        },
 --     	ret = {
 --            ret = "ok",
 --            open_grid = {
 --            	"4"
 --           	},
 --            open_boss = "0",
 --        }
 --  	}
 --  	requestFunc(nil, data, true)
end	
-- 	/**
-- 	 * 攻打某个副本的BOSS
-- 	 * 
-- 	 * @param int $copyId
--   * @param int $bossType   是否为梦魇模式 0或1  不传识为0
-- 	 * @return array
-- 	 * {
-- 	 * 		ret => 'ok'							返回值
-- 	 * 		fightRet => string					战斗串
-- 	 * 		appraise => int						战斗评价
-- 	 * 		drop => array						掉落
-- 	 *      open_copy => int					开启的新副本
-- 	 * }
-- 	 */
function attackBoss(p_callback, p_copyId, p_bossType)
	local bossType = p_bossType or MoonData.kNormal
	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		if dictData.ret.appraise ~= "E" and dictData.ret.appraise ~= "F" then
			if bossType == MoonData.kNormal then
				MoonData.addAttackNum(-1)
			else
				MoonData.addHighAttackNum(-1)
			end
			MoonData.addBossReward(p_copyId, bossType)
			MoonData.setAttackBossData(dictData.ret, p_copyId, bossType)
		end
		if p_callback then
			p_callback(dictData.ret)
		end
	end
	local args = nil
	if bossType == MoonData.kNormal then
		args = Network.argsHandler(p_copyId)
	else
		args = Network.argsHandler(p_copyId, 1)
	end
	Network.rpc(requestFunc, "moon.attackBoss", "moon.attackBoss", args, true)
	-- local data = {
	-- 	err = "ok",
	-- 	ret = {
	-- 	      	ret = "ok",
	-- 	      	fightRet = "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",
	-- 	      	appraise = "SS",
	-- 	      	drop = {
	-- 	              ["410044"] = "1",
	-- 	              ["410045"] = "1",
	-- 	              ["410046"] = "1",
	-- 	              ["410047"] = "1",
	-- 	              ["410048"] = "1",
	-- 	              ["410049"] = "1",
	-- 	              ["410050"] = "1",
	-- 	              ["410051"] = "1",
	-- 	              ["410052"] = "1",
	-- 	              ["410053"] = "1",
	-- 	              ["410054"] = "1",
	-- 	              ["410055"] = "1",
	-- 	              ["410056"] = "1",
	-- 	       	},
	-- 	     	open_copy = "2",
	-- 	  	}

	-- 	}
	-- requestFunc(nil, data, true)
end
	
-- 	/**
-- 	 * 花金币购买攻击次数
-- 	 * @param int $nightmare 是否为梦魇模式0或1，0为默认值
-- 	 * @return ok
-- 	 */
function addAttackNum(p_callback, p_bossType)
	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		if p_bossType == 1 then
			MoonData.addBuyHighAttackNum(1)
		else
			MoonData.addBuyAttackNum(1)
		end
		if p_callback then
			p_callback()
		end
	end
	local args = nil
	if p_bossType ~= nil then
		args = Network.argsHandler(p_bossType)
	end
	Network.rpc(requestFunc, "moon.addAttackNum", "moon.addAttackNum", args, true)
end
	
-- 	/**
-- 	 * 花金币开宝箱
-- 	 * @return
-- 	 * {
-- 	 * 		ret => 'ok'							返回值
-- 	 * 		drop => array						掉落的奖励
-- 	 * 		{
-- 	 * 			array(1,0,200)					银币200
-- 	 * 			array(7,60007,20)				物品60007 20个
-- 	 * 			......
-- 	 * 		}
-- 	 * }
-- 	 */
function buyBox(p_callback)
	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		MoonData.setBuyBoxInfo(dictData.ret)
		if p_callback then
			p_callback()
		end
	end
	Network.rpc(requestFunc, "moon.buyBox", "moon.buyBox", nil, true)
	-- local data = {
	-- 	ret = 
	-- 	{
	-- 		{1, 0, 200},
	-- 		{7, 60007, 20},
	-- 	}
	-- }
	-- requestFunc(nil, data, true)
end
	
-- 	/**
-- 	 * 商店信息
-- 	 *
-- 	 * @return array
-- 	 * <code>
-- 	 * [
-- 	 *     goods_list:array
-- 	 *     [
-- 	 *         goodsId=>canBuyNum
-- 	 *     ]
-- 	 *     refresh_cd:int          		下次系统刷新商品列表时间
-- 	 *     refresh_num:int   			 玩家当日刷新次数
-- 	 *     buy_box_count:int			 玩家当日买宝箱的次数
-- 	 * ]
-- 	 * </code>
-- 	 */
function getShopInfo(p_callback)
	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		MoonData.setShopInfo(dictData.ret)
		if p_callback then
			p_callback()
		end
	end
	Network.rpc(requestFunc, "moon.getShopInfo", "moon.getShopInfo", nil, true)
end
	
-- 	/**
-- 	 * 购买物品
-- 	 *
-- 	 * @param int $goodsId
-- 	 * @return array
-- 	 * <code>
-- 	 * [
-- 	 *     ret:string            'ok'
-- 	 *     drop					 如果没有的话是空数组
-- 	 * ]
-- 	 * </code>
-- 	 */
function buyGoods(p_callback, p_goodsId)
	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		MoonData.handleBuyGoods(p_goodsId)
		if p_callback then
			p_callback()
		end
	end
	local args = Network.argsHandler(p_goodsId)
	Network.rpc(requestFunc, "moon.buyGoods", "moon.buyGoods", args, true)
end
	
-- 	/**
-- 	 * 刷新商品
-- 	 *
-- 	 * @return array
-- 	 * <code>
-- 	 * [
-- 	 *     goods_list:array
-- 	 *     [
-- 	 *         goodsId=>canBuyNum
-- 	 *     ]
-- 	 *     refresh_cd:int             下次系统刷新商品列表时间
-- 	 *     refresh_num:int            玩家当日刷新次数
-- 	 * ]
-- 	 * </code>
-- 	 */
function refreshGoodsList(p_callback)
	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		MoonData.setRefreshGoodsList(dictData.ret)
		if p_callback then
			p_callback()
		end
	end
	Network.rpc(requestFunc, "moon.refreshGoodsList", "moon.refreshGoodsList", nil, true)
	-- local data = {
	-- ret = {
	-- 	goods_list = {
	-- 		["1"] = 3,
	-- 		["2"] = 3,
	-- 		["3"] = 4,
	-- 		["4"] = 5,
	-- 	},
	-- 	refresh_cd = TimeUtil.getSvrTimeByOffset() + 30,
	-- 	}
	-- }	
	-- requestFunc(nil, data, true)
end

-- 参数：0为普通模式，1为梦魇模式
-- 返回值：
-- array(
-- 0=>array() 奖励三元组，第一次的奖励
-- 1=>array() 奖励三元组，第二次的奖励
-- )
function sweep(p_callback, p_nightmare)
	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		local moonInfo = MoonData.getMoonInfo()
		local smallCopyId = 0
		local bossType = 0
		local count = 0
		if p_nightmare == 0 then
			smallCopyId = tonumber(moonInfo.max_pass_copy)
			bossType = MoonData.kNormal
			count = MoonData.getAttackNum()
		else
			smallCopyId = tonumber(moonInfo.max_nightmare_pass_copy)
			bossType = MoonData.kHigh
			count = MoonData.getHighAttackNum()
		end
		for i = 1, count do
			MoonData.addBossReward(smallCopyId, bossType)
		end
		if p_callback then
			p_callback(dictData.ret)
		end
	end
	local args = Network.argsHandler(p_nightmare)
	Network.rpc(requestFunc, "moon.sweep", "moon.sweep", args, true)
end

-- /* vim: set ts=4 sw=4 sts=4 tw=100 noet: */