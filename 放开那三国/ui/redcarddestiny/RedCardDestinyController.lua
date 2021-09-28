-- Filename：    RedCardDestinyController.lua
-- Author：      LLP
-- Date：        2016-5-30
-- Purpose：     丹药控制层
module("RedCardDestinyController", package.seeall)
require "script/ui/redcarddestiny/RedCardDestinyService"
require "script/model/hero/HeroModel"
function openDestiny( pHid,pDestinyId,pItem,pCallBack )
	local item = pItem
	local requestCallback = function( pRetData )
		if(pCallBack)then
			HeroModel.addDestinyByHid(pHid)
			RedCardDestinyData.clearTotalAttForFightForce(pHid)
			pCallBack(item)
		end
	end
	RedCardDestinyService.openDestiny(pHid,pDestinyId,requestCallback)
end

function resetDestiny( pHid,pCallBack )
	local requestCallback = function( pRetData )
		if(pCallBack)then
			pCallBack()
		end
	end
	RedCardDestinyService.resetDestiny(pHid,requestCallback)
end