-- Filename：	VIPBenefitService.lua
-- Author：		Fu Qiongqiong
-- Date：		2016-4-7
-- Purpose：		vip每周礼包网络层

module("VIPBenefitService", package.seeall)

-- /**
-- 	 * 购买vip每周礼包
-- 	 * 
-- 	 * @param int $vip 要购买的vip礼包
-- 	 * @return string "ok"
-- 	 */
function buyWeekGift(pId,pCallback)
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({pId})
	Network.rpc(requestFunc,"vipbonus.buyWeekGift","vipbonus.buyWeekGift",args,true)
end
-- /**
-- 	 * 获取vip福利信息
-- 	 * 
-- 	 * @return array
-- 	 * <code>
-- 	 * {
-- 	 * 		'bonus':int			是否领取vip每日福利，1是0否
-- 	 * 		'week_gift':array
-- 	 * 		{
-- 	 * 			$vip1, $vip2	已经购买的vip每周礼包
-- 	 * 		}
-- 	 * }
-- 	 * </code>
-- 	 */
function getVipBonusInfo( pCallback )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc,"vipbonus.getVipBonusInfo","vipbonus.getVipBonusInfo",nil,true)
	
end