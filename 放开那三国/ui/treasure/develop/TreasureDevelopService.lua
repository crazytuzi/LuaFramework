-- FileName: TreasureDevelopService.lua 
-- Author: licong 
-- Date: 15/4/22 
-- Purpose: 宝物进阶后端接口


module("TreasureDevelopService", package.seeall)
-- /**
-- * 进阶宝物
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
-- * 			treasureLevel:int	当前等级
-- * 			treasureExp:int		总经验值
-- * 			treasureEvolve:int	进阶等级
-- * 			treasureDevelop:int	进阶阶数
-- * 		}
-- * }
-- * </code>
-- */
function develop(p_itemId, p_itemIdTab, p_callBack)
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			print("--------后端返回数据--develop-----------")
			print_t(dictData)
			if(p_callBack ~= nil)then
				p_callBack(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({p_itemId, p_itemIdTab})
	Network.rpc(requestFunc,"forge.develop","forge.develop",args,true)
end














