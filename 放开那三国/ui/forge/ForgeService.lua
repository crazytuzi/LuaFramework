-- FileName: ForgeService.lua 
-- Author: licong 
-- Date: 14-6-12 
-- Purpose: function description of module 


module("ForgeService", package.seeall)

--[[
	@des 	:橙装锻造
	@param 	: p_method:方法id,  p_itemId:物品id
	@return : 'ok'成功,'err'失败
]]
function compose( p_method, p_itemId, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		if(dictData.err == "ok")then
			local dataRet = dictData.ret
			if(dataRet == "ok")then
				if(callbackFunc ~= nil)then
					callbackFunc(true)
				end
			else
				if(callbackFunc ~= nil)then
					callbackFunc(false)
				end
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCString:create(p_method))
	args:addObject(CCString:create(p_itemId))
	Network.rpc(requestFunc, "forge.compose", "forge.compose", args, true)
end


-- /**
-- * 一键兑换合成材料
-- * 
-- * @param int $method 方法id
-- * @param int $itemId 紫装物品id
-- * @return string $ret 结果:'ok'成功,'err'失败
-- */
function composeQuickBuy( p_method, p_itemTid, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		if(dictData.err == "ok")then
			local dataRet = dictData.ret
			if(dataRet == "ok")then
				if(callbackFunc ~= nil)then
					callbackFunc()
				end
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCString:create(p_method))
	args:addObject(CCString:create(p_itemTid))
	Network.rpc(requestFunc, "forge.composeQuickBuy", "forge.composeQuickBuy", args, true)
end
