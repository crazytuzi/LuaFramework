-- FileName: RechargeGiftService.lua
-- Author: yangrui
-- Date: 15-10-30
-- Purpose: function description of module

module ("RechargeGiftService", package.seeall)

require "script/ui/rechargeActive/rechargegift/RechargeGiftData"

-- /**
--  * 获取已经领过奖的id
--  * @return array[ 
--  * 			'acc_gold' => int 活动期间内的累计充值金币数量,
--  * 			'hadRewardArr' => array(1, 2, ...) 已经领取过奖励的奖励id数组 
--  * ]
--  */
-- public function getInfo();
function getInfo( pCallBack )
	local callBack = function ( pFlag, pData, pBool )
		if pData.err == "ok" then
			RechargeGiftData.setRechargeGiftInfo(pData.ret)
			if pCallBack ~= nil then
				pCallBack()
			end
		end
	end
	Network.rpc(callBack, "rechargegift.getInfo", "rechargegift.getInfo", nil, true)
end

-- /**
--  * 领取奖励
--  * @param int $rewardId		奖励档位
--  * @param int $select	如果是可选奖励类型,则传选择的奖励物品在奖励数组中的顺序编号;如果是不可选类型则这个字段前端不用传，默认补0
--  * @return 'ok'
--  */
-- public function obtainReward($rewardId, $select=0);
function obtainReward( pRewardId, pSelect, pCallBack )
	local callBack = function ( pFlag, pData, pBool )
		if pData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack()
			end
		elseif pData.err == "activity rechargeGift is not opened" then
			AnimationTip.showTip(GetLocalizeStringBy("yr_3006"))
			return
		end
	end
	local args = Network.argsHandlerOfTable({pRewardId, pSelect})
	Network.rpc(callBack, "rechargegift.obtainReward", "rechargegift.obtainReward", args, true)
end
