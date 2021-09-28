-- FileName: DevelopSoulService.lua 
-- Author: licong 
-- Date: 15/8/31 
-- Purpose: 战魂进阶网络接口


module("DevelopSoulService", package.seeall)

-- /**
-- * 进化战魂
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
-- * 		}
-- * }
-- * </code>
-- */
function fightSoulDevelop(p_itemId, p_itemIds, p_callBack)
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			print("--------后端返回数据--fightSoulDevelop-----------")
			print_t(dictData)
			if(p_callBack ~= nil)then
				p_callBack(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ p_itemId, p_itemIds })
	Network.rpc(requestFunc,"forge.fightSoulDevelop","forge.fightSoulDevelop",args,true)
end



-- /**
-- * 卸下战魂
-- * @param int $hid
-- * @param int $pos
-- * @return string 'ok'
-- */
function removeFightSoul(p_hid, p_pos, p_callBack)
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			print("--------后端返回数据--removeFightSoul-----------")
			print_t(dictData)
			if dictData.ret == "ok" then
				if(p_callBack ~= nil)then
					p_callBack()
				end
			end
		end
	end
	local args = Network.argsHandlerOfTable({ p_hid, p_pos })
	Network.rpc(requestFunc,"hero.removeFightSoul","hero.removeFightSoul",args,true)
end


