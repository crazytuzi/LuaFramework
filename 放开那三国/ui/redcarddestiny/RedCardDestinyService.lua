-- FileName: RedCardDestinyService.lua 
-- Author: llp
-- Date: 16-05-30
-- Purpose: function description of module 

module("RedCardDestinyService", package.seeall)

function openDestiny( pHid,pDestinyId,pCallBack )
	local callBack = function ( pFlag, pData, pBool )
		if pData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack()
			end
		end
	end
	local args = Network.argsHandlerOfTable({pHid,pDestinyId})
	Network.rpc(callBack, "hero.activeDestiny", "hero.activeDestiny", args, true)
end

function resetDestiny( pHid,pCallBack )
	local callBack = function ( pFlag, pData, pBool )
		if pData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack()
			end
		end
	end
	local args = Network.argsHandlerOfTable({pHid})
	Network.rpc(callBack, "hero.resetDestiny", "hero.resetDestiny", args, true)
end