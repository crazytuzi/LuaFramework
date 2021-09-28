-- FileName: ChariotIllustrateController.lua
-- Author: lgx
-- Date: 2016-06-27
-- Purpose: 战车图鉴控制层

module("ChariotIllustrateController", package.seeall)

require "script/ui/chariot/illustrate/ChariotIllustrateService"
require "script/ui/chariot/illustrate/ChariotIllustrateData"

--[[
	@des 	: 获得战车图鉴信息
	@param 	: 
	@return : 
--]]
function getChariotBook( pCallBack )
	local serviceCallBack = function ( pData )
		ChariotIllustrateData.setChariotBookInfo(pData)
		if pCallBack then
			pCallBack()
		end
	end
    local uid = UserModel.getUserUid()
	ChariotIllustrateService.getChariotBook(serviceCallBack,uid)
end