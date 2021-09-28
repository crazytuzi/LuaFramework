-- FileName: TreasureRuneService.lua 
-- Author: licong 
-- Date: 15/5/4 
-- Purpose: 宝物镶嵌后端接口 


module("TreasureRuneService", package.seeall)

-- /**
-- * 宝物镶嵌符印
-- * 
-- * @param int $itemIda	宝物id
-- * @param int $itemIdb	符印id
-- * @param int $index	第几孔,1,2,3,4
-- * @param int $resItemId 	原始宝物id
-- * @return string $ret 结果:'ok'成功,'err'失败
-- */
function inlay(p_treasureItemId,p_runeItemId, p_index, p_resTreasureItemId, p_callback )
	local requestFunc = function ( cbFlag, dictData, bRet )
		print ("inlay---后端数据")
		if(bRet == true)then
			if(dictData.ret == "ok")then
				if(p_callback ~= nil)then
					p_callback()
				end
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(tonumber(p_treasureItemId)))
	args:addObject(CCInteger:create(tonumber(p_runeItemId)))
	args:addObject(CCInteger:create(tonumber(p_index)))
	local temp = p_resTreasureItemId or 0
	args:addObject(CCInteger:create(tonumber(temp)))
	Network.rpc(requestFunc, "forge.inlay", "forge.inlay", args, true)
end

-- /**
-- * 宝物卸下符印
-- * 
-- * @param int $itemId
-- * @param int $index
-- * @return string $ret 结果:'ok'成功,'err'失败
-- */
function outlay(p_treasureItemId, p_index, p_callback )
	local requestFunc = function ( cbFlag, dictData, bRet )
		print ("outlay---后端数据")
		if(bRet == true)then
			if(dictData.ret == "ok")then
				if(p_callback ~= nil)then
					p_callback()
				end
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(tonumber(p_treasureItemId)))
	args:addObject(CCInteger:create(tonumber(p_index)))
	Network.rpc(requestFunc, "forge.outlay", "forge.outlay", args, true)
end




































