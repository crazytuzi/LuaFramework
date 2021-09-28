-- Filename: FindTreasureService.lua
-- Author: bzx
-- Date: 2014-12-15
-- Purpose: 寻龙探宝service

module("FindTreasureService", package.seeall)
require "script/ui/forge/FindTreasureData"
-- 地图
function dragonGetMap(callback, isNotCheckTreasure)
	local handle = function ( cbFlag, dictData, bRet )
		if dictData.err ~= "ok" then
			return
		end
		print("dragon.getMap=====")
		print_t(dictData)
		FindTreasureData.handleGetMap(dictData)
		require "script/ui/forge/FindTreasureLayer"
		FindTreasureLayer.setMapInfo(FindTreasureData.getMapInfo())
		if callback ~= nil then
			callback(isNotCheckTreasure)
		end
	end
    Network.rpc(handle, "dragon.getMap", "dragon.getMap", nil, true)
    return "dragon.getMap"
end

-- 移动
function dragonMove(callback, params, nextPlayerIndex)
	local handle = function ( cbFlag, dictData, bRet )
		if dictData.err ~= "ok" then
			return
		end
	    FindTreasureData.handleMove(dictData, nextPlayerIndex)
	    if callback ~= nil then
	    	callback()
	    end
	end
	local args = Network.argsHandlerOfTable(params)
    Network.rpc(handle, "dragon.move", "dragon.move", args, true)
    return "dragon.move"
end

-- 自动寻路 
function dragonAutoMove(callback, params)
	local handle = function ( cbFlag, dictData, bRet )
		if dictData.err ~= "ok" then
			return
		end
		if callback ~= nil then
			callback(dictData)
		end
	end
	local args = Network.argsHandlerOfTable(params)
    Network.rpc(handle, "dragon.autoMove", "dragon.autoMove", args, true)
    return "dragon.autoMove"
end

-- 自动探宝
function dragonAiDo(callback, params, autoGoldCount, autoActCount, selectedBoxIndex, selectedFloorIndex)
	local handle = function ( cbFlag, dictData, bRet )
		if dictData.err ~= "ok" then
			return
		end
	    FindTreasureData.handleAiDo(dictData, autoGoldCount, autoActCount, selectedBoxIndex, selectedFloorIndex)
	    if callback ~= nil then
	    	callback()
	    end
	end
	local args = Network.argsHandlerOfTable(params)
    Network.rpc(handle, "dragon.aiDo", "dragon.aiDo", args, true)
    return "dragon.aiDo"
end

-- 重置
function dragonReset(callback)
	local handle = function ( cbFlag, dictData, bRet )
		if dictData.err ~= "ok" then
			return
		end
		FindTreasureData.handleReset(dictData)
		if callback ~= nil then
			callback(dictData)
		end
	end
    Network.rpc(handle, "dragon.reset", "dragon.reset", nil, true)
    return "dragon.reset"
end

-- 双倍领取
-- function dragonDoublePrize(fn_cb, params)
--     Network.rpc(fn_cb, "dragon.doublePrize", "dragon.doublePrize", params, true)
--     return "dragon.doublePrize"
-- end

-- 买血
function dragonBuyHp(callback, params, mapDb, buyHpGoldCount)
	local handle = function ( cbFlag, dictData, bRet )
		if dictData.err ~= "ok" then
			return
		end
		FindTreasureData.handleBuyHp(dictData, mapDb, buyHpGoldCount)
	    if callback ~= nil then
	    	callback()
	    end
	end
	local args = Network.argsHandlerOfTable(params)
    Network.rpc(handle, "dragon.buyHp", "dragon.buyHp", args, true)
    return "dragon.buyHp"
end

-- 贿赂
function dragonBribe(callback, params, event)
	local handle = function ( cbFlag, dictData, bRet )
		if dictData.err ~= "ok" then
			return
		end
        FindTreasureData.handleBribe(dictData, event)
		if callback ~= nil then
			callback()
		end
	end
	local args = Network.argsHandlerOfTable(params)
    Network.rpc(handle, "dragon.bribe", "dragon.bribe", args, true)
    return "dragon.bribe"
end

-- 买行动力
function dragonBuyAct(callback, params, buyActTotalGoldCount, buyActCount)
	local handle = function ( cbFlag, dictData, bRet )
		if dictData.err ~= "ok" then
			return
		end
	   	FindTreasureData.handleBuyAct(dictData, buyActTotalGoldCount, buyActCount)
    	if callback ~= nil then
    		callback()
    	end
	end
	local args = Network.argsHandlerOfTable(params)
    Network.rpc(handle, "dragon.buyAct", "dragon.buyAct", args, true)
    return "dragon.buyAct"
end

-- 战斗
function dragonFight(callback, params)
	local handle = function ( cbFlag, dictData, bRet )
		if dictData.err ~= "ok" then
			return
		end
		FindTreasureData.handleFight(dictData)
        if callback ~= nil then
        	callback(dictData)
        end
	end
	local args = Network.argsHandlerOfTable(params)
    Network.rpc(handle, "dragon.fight", "dragon.fight", args, true)
    return "dragon.fight"
end

-- 获取阵型
function dragonGetUserBf(callback, resetData)
	local handle = function ( cbFlag, dictData, bRet )
		if dictData.err ~= "ok" then
			return
		end
		FindTreasureData.handleGetUserBf(dictData, resetData)
		if callback ~= nil then
			callback()
		end
	end
    Network.rpc(handle, "dragon.getUserBf", "dragon.getUserBf", nil, true)
    return "dragon.getUserBf"
end

-- 一键答题
function dragonOnekey(callback, params, event)
	local handle = function ( cbFlag, dictData, bRet )
        FindTreasureData.handleOnekey(dictData, event)
        if callback ~= nil then
        	callback()
        end
	end
	local args = Network.argsHandlerOfTable(params)
    Network.rpc(handle, "dragon.onekey", "dragon.onekey", args, true)
    return "dragon.onekey"
end

-- 答题
function dragonAnswer(callback, params, event)
	local handle = function ( cbFlag, dictData, bRet )
		if dictData.err ~= "ok" then
			return
		end
       local add_point = FindTreasureData.handleAnswer(dictData, event)
        if callback ~= nil then
        	callback(dictData, add_point)
        end
	end
	local args = Network.argsHandlerOfTable(params)
    Network.rpc(handle, "dragon.answer", "dragon.answer", args, true)
    return "dragon.answer"
end

-- 跳过
function dragonSkip(callback, params)
	local handle = function ( cbFlag, dictData, bRet )
		if dictData.err ~= "ok" then
			return
		end
		FindTreasureData.handleSkip(dictData)
		if callback ~= nil then
			callback()
		end
	end
	local args = Network.argsHandlerOfTable(params)
	Network.rpc(handle, "dragon.skip", "dragon.skip", args, true)
end

-- 购买商品
function dragonBuyGood(callback, params, eventShopDb)
	local handle = function ( cbFlag, dictData, bRet )
		if dictData.err ~= "ok" then
			return
		end
		FindTreasureData.handleBuyGood(dictData, eventShopDb)
		if callback ~= nil then
			callback()
		end
	end
	local args = Network.argsHandlerOfTable(params)
	Network.rpc(handle, "dragon.buyGood", "dragon.buyGood", args, true)
end

-- 捐献物品
function dragonContribute(callback, params, eventShopDb, itemId, itemCount)
	local handle = function ( cbFlag, dictData, bRet )
		if dictData.err ~= "ok" then
			return
		end
		FindTreasureData.handleContribute(dictData, eventShopDb, itemId, itemCount)
		if callback ~= nil then
			callback()
		end
	end
	local args = Network.argsHandlerOfTable(params)
	Network.rpc(handle, "dragon.contribute", "dragon.contribute", args, true)
end

-- 打试炼boss
function dragonFightBoss(callback, params, bossIndex , eventDb)
	local handle = function ( cbFlag, dictData, bRet )
		if dictData.err ~= "ok" then
			return
		end
		FindTreasureData.handleFightBoss( dictData, bossIndex, eventDb)
		if callback ~= nil then
			callback(dictData)
		end
	end
	local args = Network.argsHandlerOfTable(params)
	Network.rpc(handle, "dragon.fightBoss", "dragon.fightBoss", args, true)
end

-- 试炼Boss直接胜利
function directWin( callback, params, bossIndex, eventDb )
	local handle = function ( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		FindTreasureData.handleDirectBoss(bossIndex, eventDb)
		if callback ~= nil then
			callback(dictData)
		end
	end
	local args = Network.argsHandlerOfTable(params)
	Network.rpc(handle, "dragon.bossDirectWin", "dragon.bossDirectWin", args, true)
end




-- 进入试炼
function dragonTrial(callback, params)
	local handle = function ( cbFlag, dictData, bRet )
		if dictData.err ~= "ok" then
			return
		end
		FindTreasureData.handleTrial(dictData)
		if callback ~= nil then
			callback()
		end
	end
	Network.rpc(handle, "dragon.trial", "dragon.trial", params, true)
end
