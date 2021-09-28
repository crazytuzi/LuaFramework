-- FileName: EvolveSoulService.lua 
-- Author: licong 
-- Date: 15/8/31 
-- Purpose: 战魂精炼网络接口 


module("EvolveSoulService", package.seeall)

-- /**
-- * 精炼战魂
-- *
-- * @param int $itemId			物品id
-- * @param int $itemIds			消耗的物品id组
-- * @return array
-- * <code>
-- * {
-- * 		item_id:int				物品ID
-- * 		item_template_id:int	物品模板ID
-- * 		item_num:int			物品数量
-- * 		item_time:int			物品产生时间
-- * 		va_item_text:			物品扩展信息
-- * 		{
-- * 			fsLevel:int	当前等级
-- * 			fsExp:int	总经验值
-- * 			fsEvolve:int 精炼等级 （不能精炼的战魂没有这个字段）
-- * 		}
-- * }
-- * </code>
-- */
function fightSoulEvolve(p_itemId, p_itemIds, p_callBack)
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			print("--------后端返回数据--fightSoulEvolve-----------")
			print_t(dictData)
			if(p_callBack ~= nil)then
				p_callBack(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ p_itemId, p_itemIds })
	Network.rpc(requestFunc,"forge.fightSoulEvolve","forge.fightSoulEvolve",args,true)
end

