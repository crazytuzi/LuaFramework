-- FileName: GodInheritService.lua 
-- Author: licong 
-- Date: 15/4/1 
-- Purpose: 神兵洗练属性传承网络接口 


module("GodInheritService", package.seeall)

-- /**
-- * 洗练属性传承
-- * @param $arrItemId array ($itemId1 洗练源, $itemId2 洗练目标)
-- * @param $arrIndex array (1, 2, 3 ...) 层数 从1开始
-- * @return string ok
-- */
-- param:p_srcItemId原神兵， p_disItemId目标神兵， p_fixIndexTab传承洗练层index 
function legend(p_srcItemId,p_disItemId, p_fixIndexTab, p_callback )
	local requestFunc = function ( cbFlag, dictData, bRet )
		print ("legend---后端数据")
		if(bRet == true)then
			if(dictData.ret == "ok")then
				if(p_callback ~= nil)then
					p_callback()
				end
			end
		end
	end
	local args = CCArray:create()
	local args1 = CCArray:create()
	args1:addObject(CCInteger:create(tonumber(p_srcItemId)))
	args1:addObject(CCInteger:create(tonumber(p_disItemId)))
	args:addObject(args1)
	local args2 = CCArray:create()
	for k,v in pairs(p_fixIndexTab) do
		args2:addObject(CCInteger:create(tonumber(v)))
	end
	args:addObject(args2)
	Network.rpc(requestFunc, "godweapon.legend", "godweapon.legend", args, true)
end

































