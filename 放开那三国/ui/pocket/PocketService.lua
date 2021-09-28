-- FileName: PocketService.lua
-- Author:
-- Date: 2014-04-00
-- Purpose: 锦囊系统网络层
--[[TODO List]]

module("PocketService", package.seeall)

-- /**
--  *
--  * @param int $itemId
--  * @param array $itemIds
--  * @return array
--  * <code>
--  * {
--  * 		item_id:int				物品ID
--  * 		item_template_id:int	物品模板ID
--  * 		item_num:int			物品数量
--  * 		item_time:int			物品产生时间
--  * 		va_item_text:			物品扩展信息
--  * 		{
--  * 			pocketLevel:int		当前等级
--  * 			pocketExp:int		总经验值
--  * 		}
--  * }
--  */
function upgradePocket(pItemId, pItemIds, pCallBack)
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true)then
			local dataRet = dictData.ret
			-- 回调
			if(pCallBack)then
				pCallBack(dataRet.va_item_text.pocketLevel,dataRet.va_item_text.pocketExp,dataRet.item_id)
			end
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(pItemId))
	local idArray = CCArray:create()
	for k,v in pairs(pItemIds) do
		idArray:addObject(CCInteger:create(v))
	end
	args:addObject(idArray)
	Network.rpc(requestFunc,"forge.upgradePocket","forge.upgradePocket",args,true)
end

-- return: 'ok'
-- access: public
-- string addPocket (int $hid, int $pos, int $itemId, [int $fromHid = 0])
-- int $hid: 装备锦囊的武将id
-- int $pos: 装备锦囊的位置
-- int $itemId: 装备的锦囊物品id
-- int $fromHid: 锦囊原来属于的武将id 如果是从背包装备 此参数是0
function addPocket(p_hid, p_pos, p_info, p_fromhid, pCallBack)
	local requestFunc = function(cbFlag,dictData,bRet)
		if bRet == true then
			if(pCallBack ~= nil)then
				pCallBack(p_hid, p_pos, p_info, p_fromhid)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ p_hid,p_pos,p_info.item_id,p_fromhid})
	Network.rpc(requestFunc,"hero.addPocket","hero.addPocket",args,true)
end

-- removePocket
-- 卸下锦囊

-- return: 'ok'
-- access: public
-- string removePocket (int $hid, int $pos)
-- int $hid
-- int $pos
function removePocket(p_hid, p_pos, pCallBack)
	local requestFunc = function(cbFlag,dictData,bRet)
		if bRet == true then
			if(pCallBack ~= nil)then
				pCallBack(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ p_hid, p_pos })
	Network.rpc(requestFunc,"hero.removePocket","hero.removePocket",args,true)
end

function lockPocket( pitemId,pCallBack )
	local requestFunc = function(cbFlag,dictData,bRet)
		if bRet == true then
			if(pCallBack ~= nil)then
				pCallBack(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ pitemId })
	Network.rpc(requestFunc,"forge.lock","forge.lock",args,true)
end

function unlockPocket( pitemId,pCallBack )
	local requestFunc = function(cbFlag,dictData,bRet)
		if bRet == true then
			if(pCallBack ~= nil)then
				pCallBack(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ pitemId })
	Network.rpc(requestFunc,"forge.unlock","forge.unlock",args,true)
end