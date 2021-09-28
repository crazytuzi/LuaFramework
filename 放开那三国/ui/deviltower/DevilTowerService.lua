-- FileName: DevilTowerService.lua
-- Author: lgx
-- Date: 2016-07-29
-- Purpose: 试炼梦魇网络接口

module("DevilTowerService", package.seeall)

require "script/ui/deviltower/DevilTowerDef"

-- 模块局部变量 --
local kTypeDevil = DevilTowerDef.kTowerTypeDevil

--[[
	@desc	: 获取某个用户试炼梦魇信息
    @param	: pCallback 回调方法
    @return	: 
/**
 * @return array
 * [
 * 	uid:int								玩家id
 * 	max_level:int						玩家达到塔层的最高级别
 * 	max_level_time:int					玩家达到最高塔层的时间
 * 	cur_level:int						当前所在的塔层
 * 	last_refresh_time:int				上一次刷新攻击次数、重置次数的时间
 *  reset_num:int                       可以重置的次数
 *  can_fail_num:int                    可以失败的次数
 *  gold_buy_num:int					使用金币购买挑战失败的次数
 *  buy_atk_num:int						购买攻击次数
 *  buy_special_num:int					购买神秘塔层次数	
 *  max_hell:int                        玩家达到试炼噩梦的最高级别
 *  cur_hell:int                        玩家当前所在试炼噩梦的级别
 *  reset_hell:int                      试炼噩梦的可重置次数
 *  can_fail_hell:int                   试炼噩梦的可失败次数
 *  gold_buy_hell:int                   试炼噩梦的金币购买挑战失败的次数
 *  buy_hell_num: int                   试炼噩梦的购买攻打次数
 *  
 * 	va_tower_info:array							
 * 				[
 *                  sweep_info:array
 *                  [
 *                     start_level:int
 *                     level_num:int
 *                     start_time:int
 *                  ]
 *                  cur_status:int        1表示通关了所有塔层，0表示没有通关所有塔层
 *                  special_tower:array
 *                  [
 *                      specail_tower_list:array
 *                      [
 *                          tower_level_id=>array
 *                          [
 *                              0=>int//据点id
 *                              1=>int//关卡开始时间
 *                              2=>int//攻击次关卡的次数
 *                          ]
 *                      ]
 *                  ]
 *                  sweep_hell_info:array
 *                  [
 *                     start_level:int
 *                     level_num:int
 *                     start_time:int
 *                  ]
 *                  cur_hell_status:int 1表示通关了所有塔层，0表示没有通关所有塔层
 * 				]
 * ]
 */
—-]]
function getTowerInfo( pCallback )
	local requestCallback = function(cbFlag,dictData,bRet)
        if dictData.err == "ok" then
            if(pCallback ~= nil)then
                pCallback(dictData.ret)
            end
        end
    end
	Network.rpc(requestCallback,"tower.getTowerInfo","tower.getTowerInfo",nil,true)
end

--[[
	@desc   : 进入某个塔层进行攻击
	@param	: pCallback 回调方法
    @param  : pLayerId 塔层id
    @param 	: pType 类型(1：普通试练塔 2：试炼梦魇)
    @return : 
/**
 * @return	string	'ok'
 */
--]]
function enterLevel( pCallback, pLayerId, pType )
	pType = pType or kTypeDevil
	local requestCallback = function(cbFlag,dictData,bRet)
        if dictData.err == "ok" then
            if(pCallback ~= nil)then
                pCallback(dictData.ret)
            end
        end
    end
	local args = Network.argsHandlerOfTable({ pLayerId,pType })
	Network.rpc(requestCallback,"tower.enterLevel","tower.enterLevel",args,true)
end

--[[
	@desc   : 击败塔层中的怪物
	@param	: pCallback 回调方法
    @param  : pLayerId 塔层id
	@param  : pArmyId 塔层据点id
    @param 	: pType 类型(1：普通试练塔 2：试炼梦魇)
    @return : 
/**
 * @return array
 * [
 * 	fightRet:
 * 	appraisal:int
 * 	reward:array
 * 			[
 * 				silver:int
 * 				soul:int
 * 				item:array
 * 				stamina:int
 * 				execution:int
 *				tower_num:int
 * 			]
 * cd:int
 * newcopyorbase:array     
 *     [
 *         pass:bool
 *         tower_info:array
 *     ]   
 * ]
 */
--]]
function defeatMonster( pCallback, pLayerId, pArmyId, pType )
	pType = pType or kTypeDevil
	local requestCallback = function(cbFlag,dictData,bRet)
        if dictData.err == "ok" then
            if(pCallback ~= nil)then
                pCallback(dictData.ret)
            end
        end
    end
	local args = Network.argsHandlerOfTable({ pLayerId,pArmyId,pType })
	Network.rpc(requestCallback,"tower.defeatMonster","tower.defeatMonster",args,true)
end

--[[
	@desc   : 离开某个塔层
	@param	: pCallback 回调方法
    @param  : pLayerId 塔层id
    @return : 
--]]
function leaveTowerLv( pCallback, pLayerId )
	local requestCallback = function(cbFlag,dictData,bRet)
        if dictData.err == "ok" then
            if(pCallback ~= nil)then
                pCallback(dictData.ret)
            end
        end
    end
	local args = Network.argsHandlerOfTable({ pLayerId })
	Network.rpc(requestCallback,"tower.leaveTowerLv","tower.leaveTowerLv",args,true)
end

--[[
	@desc   : 离开试炼梦魇系统
    @param	: pCallback 回调方法 
    @return : 
--]]
function leaveTower( pCallback )
	local requestCallback = function(cbFlag,dictData,bRet)
        if dictData.err == "ok" then
            if(pCallback ~= nil)then
                pCallback(dictData.ret)
            end
        end
    end
	Network.rpc(requestCallback,"tower.leaveTower","tower.leaveTower",nil,true)
end

--[[
	@desc   : 重置试炼梦魇
	@param	: pCallback 回调方法
	@param 	: pType 类型(1：普通试练塔 2：试炼梦魇)
    @return : 
--]]
function resetTower( pCallback, pType )
	pType = pType or kTypeDevil
	local requestCallback = function(cbFlag,dictData,bRet)
        if dictData.err == "ok" then
            if(pCallback ~= nil)then
                pCallback(dictData.ret)
            end
        end
    end
	local args = Network.argsHandlerOfTable({ pType })
	Network.rpc(requestCallback,"tower.resetTower","tower.resetTower",args,true)
end

--[[
	@desc   : 扫荡试炼梦魇
	@param	: pCallback 回调方法
    @param  : pCurLayerId 开始塔层id
	@param  : pEndLayerId 结束塔层id
	@param 	: pType 类型(1：普通试练塔 2：试炼梦魇)
    @return : 
/**
 * @return array        tower_info
 */
--]]
function sweep( pCallback, pCurLayerId, pEndLayerId, pType )
	pType = pType or kTypeDevil
	local requestCallback = function(cbFlag,dictData,bRet)
        if dictData.err == "ok" then
            if(pCallback ~= nil)then
                pCallback(dictData.ret)
            end
        end
    end
	local args = Network.argsHandlerOfTable({ pCurLayerId,pEndLayerId,pType })
	Network.rpc(requestCallback,"tower.sweep","tower.sweep",args,true)
end

--[[
	@desc   : 取消扫荡试炼梦魇
	@param	: pCallback 回调方法
    @param 	: pType 类型(1：普通试练塔 2：试炼梦魇)
    @return : 
/**
 * @return string 'ok'
 */
--]]
function endSweep( pCallback, pType )
	pType = pType or kTypeDevil
	local requestCallback = function(cbFlag,dictData,bRet)
        if dictData.err == "ok" then
            if(pCallback ~= nil)then
                pCallback(dictData.ret)
            end
        end
    end
	local args = Network.argsHandlerOfTable({ pType })
	Network.rpc(requestCallback,"tower.endSweep","tower.endSweep",args,true)
end

--[[
	@desc   : 立即完成试炼梦魇
	@param	: pCallback 回调方法
    @param  : pEndLayerId 指定塔层数
    @param 	: pType 类型(1：普通试练塔 2：试炼梦魇)
    @return : 
/**
 * @return array 同getTowerInfo
 * [
 *     
 * ]
 */
--]]
function sweepByGold( pCallback, pEndLayerId, pType )
	pType = pType or kTypeDevil
	local requestCallback = function(cbFlag,dictData,bRet)
        if dictData.err == "ok" then
            if(pCallback ~= nil)then
                pCallback(dictData.ret)
            end
        end
    end
	local args = Network.argsHandlerOfTable({ pEndLayerId,pType })
	Network.rpc(requestCallback,"tower.sweepByGold","tower.sweepByGold",args,true)
end

--[[
	@desc   : 购买挑战次数
	@param	: pCallback 回调方法
    @param 	: pType 类型(1：普通试练塔 2：试炼梦魇) 
    @return : 
--]]
function buyDefeatNum( pCallback, pType )
	pType = pType or kTypeDevil
	local requestCallback = function(cbFlag,dictData,bRet)
        if dictData.err == "ok" then
            if(pCallback ~= nil)then
                pCallback(dictData.ret)
            end
        end
    end
	local args = Network.argsHandlerOfTable({ pType })
	Network.rpc(requestCallback,"tower.buyDefeatNum","tower.buyDefeatNum",args,true)
end

--[[
	@desc   : 购买重置次数
	@param	: pCallback 回调方法
	@parrm 	: pBuyTimes 购买次数
    @param 	: pType 类型(1：普通试练塔 2：试炼梦魇)
    @return : 
--]]
function buyAtkNum( pCallback, pBuyTimes, pType )
	pBuyTimes = pBuyTimes or 1
	pType = pType or kTypeDevil
	local requestCallback = function(cbFlag,dictData,bRet)
        if dictData.err == "ok" then
            if(pCallback ~= nil)then
                pCallback(dictData.ret)
            end
        end
    end
	local args = Network.argsHandlerOfTable({ pBuyTimes,pType })
	Network.rpc(requestCallback,"tower.buyAtkNum","tower.buyAtkNum",args,true)
end