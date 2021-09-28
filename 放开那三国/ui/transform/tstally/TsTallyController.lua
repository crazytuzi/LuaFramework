-- FileName: TsTallyController.lua
-- Author: lgx
-- Date: 2016-08-22
-- Purpose: 兵符转换控制层

module("TsTallyController", package.seeall)

require "script/ui/transform/tstally/TsTallyService"

--[[
	@desc	: 兵符转换
    @param	: pCallback 回调方法 
    @param	: pItemId 原兵符id 
    @param 	: pOldTid 原兵符Tid
    @param	: pToTid 目标兵符Tid 
    @param	: pCostGold 花费的金币
    @return	: bool 是否发送了请求
—-]]
function transferTally( pCallback, pItemId, pOldTid, pToTid, pCostGold, pErrCallback )
	local isSend = false
	-- 1.判断原兵符id
	if ( pItemId == nil or tonumber(pItemId) <= 0 ) then
		AnimationTip.showTip(GetLocalizeStringBy("lgx_1104"))
		return isSend
	end

	-- 2.判断目标兵符Tid
	if ( pToTid == nil or tonumber(pToTid) <= 0 ) then
		AnimationTip.showTip(GetLocalizeStringBy("lgx_1105"))
		return isSend
	end

	-- 3.判断是否是相同Tid兵符
	if ( pOldTid ~= nil and tonumber(pOldTid) == tonumber(pToTid) ) then
		AnimationTip.showTip(GetLocalizeStringBy("lgx_1109")..GetLocalizeStringBy("lic_1773"))
		return isSend
	end

	-- 4.判断金币
	if (UserModel.getGoldNumber() < pCostGold ) then
		-- 金币不足提示
		require "script/ui/tip/LackGoldTip"
		LackGoldTip.showTip()
		return isSend
	end

	local requestCallback = function( pRet )
		-- 扣除金币
		UserModel.addGoldNumber(-pCostGold)
		-- 回调 刷UI
		if( pCallback )then
			pCallback( pRet )
		end
	end
	TsTallyService.transferTally(requestCallback,pItemId,pToTid,pErrCallback)
	isSend = true
	return isSend
end
