-- FileName: TsTreasureController.lua 
-- Author: licong 
-- Date: 16/3/4 
-- Purpose: 宝物转换控制器 


module("TsTreasureController", package.seeall)

require "script/ui/transform/TransformMainService"

--[[
	@des 	: 确定转换
	@param 	: 
	@return : bool 是否发送了请求
--]]
function transferTreasure( p_itemId, p_oldTid, p_toTid, p_costNum, p_callBack)
	local isSend = false
	-- 1.原宝物p_itemId
	if( p_itemId == nil)then
		AnimationTip.showTip( GetLocalizeStringBy("lic_1805"))
		return isSend
	end
	-- 2.目标宝物p_toTid
	if( p_toTid == nil)then
		AnimationTip.showTip( GetLocalizeStringBy("lic_1806"))
		return isSend
	end

	-- 3.判断是否是相同Tid
	if ( p_oldTid ~= nil and tonumber(p_oldTid) == tonumber(p_toTid) ) then
		AnimationTip.showTip(GetLocalizeStringBy("lgx_1109")..GetLocalizeStringBy("key_1848"))
		return isSend
	end

	-- 4.金币不足
	if(UserModel.getGoldNumber() < p_costNum )then
		-- 金币不足提示
		require "script/ui/tip/LackGoldTip"
		LackGoldTip.showTip()
		return isSend
	end

	local nextCallFun = function ( p_retItemId )
		-- 扣除金币
		UserModel.addGoldNumber(-p_costNum)
		-- 掉回调
		if( p_callBack )then
			p_callBack( p_retItemId )
		end
	end
	TransformMainService.transferTreasure(p_itemId, p_toTid, nextCallFun )
	isSend = true
	return isSend
end