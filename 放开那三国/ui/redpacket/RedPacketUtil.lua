-- Filename: RedPacketUtil.lua
-- Author: llp
-- Date: 2015-12-25
-- Purpose: 红包各种方法

module("RedPacketUtil" , package.seeall)

function weatherHaveRedPacket( pNum )
	local havePacket = false
	local index 	 = 1
	if(tonumber(pNum)>0)then
		havePacket = true
		index	   = 2
	end
	return havePacket,index
end

