-- Filename：	FestivalActiveService.lua
-- Author：		Zhang Zihang
-- Date：		2015-1-9
-- Purpose：		节日活动网络层

module("FestivalActiveService", package.seeall)

require "script/ui/rechargeActive/festivalActive/FestivalActiveData"

--[[
	@des 	:得到合成信息
	@param 	:回调
--]]
function getFestivalInfo(p_callBack)
	local callBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end

		if cbFlag == "festival.getFestivalInfo" then
			--设置后端返回数据
			FestivalActiveData.setServiceComposeInfo(dictData.ret)

			p_callBack()
		end
	end

	Network.rpc(callBack, "festival.getFestivalInfo","festival.getFestivalInfo", nil, true)
end

--[[
	@des 	:合成
	@param 	: $ p_formulaNum 	: 公式编号，从1开始
	@param 	: $ p_num 			: 合成数量
	@param 	: $ p_callBack 		: 回调
--]]
function compose(p_formulaNum,p_num,p_callBack)
	local callBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end

		if cbFlag == "festival.compose" then
			p_callBack(p_num)
		end
	end

	local args = CCArray:create()
	args:addObject(CCInteger:create(p_formulaNum))
	args:addObject(CCInteger:create(p_num))

	Network.rpc(callBack, "festival.compose","festival.compose", args, true)
end