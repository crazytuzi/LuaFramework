-- FileName:CountryWarRankController.lua
-- Author:FQQ
-- Data:2015-11-9
-- Purpose:国战积分排行榜控制器
module("CountryWarRankController",package.seeall)
require "script/ui/countryWar/rank/CountryWarRankService"
--[[
	@des 	: 获取决赛的参赛选手，只在助威阶段需要使用
	@param 	: 
	@return : 
--]]
function getFinalMembers( pCallBack )
	CountryWarRankService.getFinalMembers(function ( pData )
		if pCallBack then
			-- 按积分排序
			local sortFun = function ( v1,v2 )
				return v1.audition_point > v2.audition_point
			end
			for k,info in pairs(pData.memberInfo) do
				for k,v in pairs(info) do
					table.sort(v,sortFun)
				end
			end
			pCallBack(pData)
		end
	end)
end
