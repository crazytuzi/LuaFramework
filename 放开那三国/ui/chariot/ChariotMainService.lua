-- FileName: ChariotMainService.lua
-- Author: lgx
-- Date: 2016-06-27
-- Purpose: 战车网络接口中心

module("ChariotMainService", package.seeall)

--[[
	@desc   : 装备战车
	@param	: pPos 战车位置
    @param  : pItemId 战车物品Id
    @return : 
	/**
 	* 装备战车
 	* @param unknown $pos是装备战车的位置 $itemId是对应的物品ID
		返回ok
 	*/
	chariot.equip($pos,$itemId);
--]]
function equip( pCallback, pPos, pItemId )
	local requestFunc = function(cbFlag,dictData,bRet)
        if dictData.err == "ok" then
            if(pCallback ~= nil)then
                pCallback(dictData.ret)
            end
        end
    end
	local args = Network.argsHandlerOfTable({ pPos,pItemId })
	Network.rpc(requestFunc,"chariot.equip","chariot.equip",args,true)
end

--[[
	@desc   : 卸下战车
	@param	: pPos 战车位置
    @param  : pItemId 战车物品Id
    @return : 
    /**
 	* 卸下战车，参数$pPos是卸下战车的位置 $itemId是对应的物品ID
    	返回ok
 	* @param unknown $itemId
 	*/
	chariot.unEquip($pos,$itemId);
--]]
function unEquip( pCallback, pPos, pItemId )
	local requestFunc = function(cbFlag,dictData,bRet)
        if dictData.err == "ok" then
            if(pCallback ~= nil)then
                pCallback(dictData.ret)
            end
        end
    end
	local args = Network.argsHandlerOfTable({ pPos,pItemId })
	Network.rpc(requestFunc,"chariot.unequip","chariot.unequip",args,true)
end

--[[
	@desc   : 强化战车
    @param  : pItemId 战车物品Id
    @return : 
   	/**
 	* 强化战车，参数$itemId是对应的物品ID
    	返回ok
 	* @param unknown $itemId
 	*/
	chariot.enforce($itemId);
--]]
function enforce( pCallback, pItemId )
	local requestFunc = function(cbFlag,dictData,bRet)
        if dictData.err == "ok" then
            if(pCallback ~= nil)then
                pCallback(dictData.ret)
            end
        end
    end
	local args = Network.argsHandlerOfTable({ pItemId })
	Network.rpc(requestFunc,"chariot.enforce","chariot.enforce",args,true)
end
