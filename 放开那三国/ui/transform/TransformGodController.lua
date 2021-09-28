-- FileName: TransformGodController.lua 
-- Author: licong 
-- Date: 16/3/1 
-- Purpose: 转换神兵控制器


module("TransformGodController", package.seeall)

require "script/ui/transform/TransformMainService"

--[[
	@des 	: 确定转换
	@param 	: 
	@return : bool 是否发送了请求
--]]
function transformGodWp( p_itemId, p_oldTid, p_toTid, p_costNum, p_callBack)
	local isSend = false
	-- 1.原神兵p_itemId
	if( p_itemId == nil)then
		AnimationTip.showTip( GetLocalizeStringBy("lic_1796"))
		return isSend
	end
	-- 2.目标神兵p_toTid
	if( p_toTid == nil)then
		AnimationTip.showTip( GetLocalizeStringBy("lic_1798"))
		return isSend
	end

	-- 3.判断是否是相同Tid
	if ( p_oldTid ~= nil and tonumber(p_oldTid) == tonumber(p_toTid) ) then
		AnimationTip.showTip(GetLocalizeStringBy("lgx_1109")..GetLocalizeStringBy("lic_1418"))
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
	TransformMainService.transfer(p_itemId, p_toTid, nextCallFun )
	isSend = true
	return isSend
end