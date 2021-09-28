-- Filename: RedPacketController.lua
-- Author: llp
-- Date: 2015-12-25
-- Purpose: 红包总调度中心
require "script/ui/redpacket/RedPacketService"
require "script/ui/redpacket/SendPacketDialog"
module("RedPacketController" , package.seeall)

function freshCount( pCount )
	SendPacketDialog.freshRedPacketNumFunction(pCount)
end

function freshGoldCount( pCount )
	SendPacketDialog.freshRedPacketGoldNumFunction(pCount)
end

function setEditBoxSize()
	SendPacketDialog.setEditBoxContentSize()
end

function getInfo( pCallBack, pType )
	local getInfoCallBack = function ( pInfo )
		require "script/ui/redpacket/RedPacketData"
		RedPacketData.setRedPacketData(pInfo)
		if( pCallBack )then
			pCallBack(pInfo)
		end
	end
	RedPacketService.getInfo(getInfoCallBack, pType)
end

function getSingleRedPacketInfo( pCallBack,pEid )
    local eid = pEid
	local getSingleInfoCallBack = function ( pInfo )
        RedPacketData.setSingleData(pInfo,eid)
		if( pCallBack )then
			pCallBack(pInfo)
		end
	end
	RedPacketService.getSingleRedPacketInfo(getSingleInfoCallBack, pEid)
end

function getLeftRedPacketInfo( pCallBack, pEid )
	local eid = pEid
	local getLeftInfoCallBack = function ( pInfo )
		RedPacketData.setSingleData(pInfo,eid)
		if( pCallBack )then
			pCallBack(pInfo)
		end
	end
	RedPacketService.getLeftRedPacketInfo(getLeftInfoCallBack, pEid)
end

function sendRedPacket( pCallBack, pType, pGoldNum, pShareNum, pMsg )
	local goldNum = pGoldNum
	if(tonumber(goldNum)>UserModel.getGoldNumber())then
		require "script/ui/tip/LackGoldTip"
		LackGoldTip.showTip()
		return
	end
	local sendCallBack = function ( ... )
		UserModel.addGoldNumber(-goldNum)
		if( pCallBack )then
			pCallBack()
		end
	end
	RedPacketService.sendRedPacket(sendCallBack, pType, pGoldNum, pShareNum, pMsg)
end

function openRedPacket( pCallBack, pEid )
	local openCallBack = function ( pInfo )
		if(tonumber(pInfo)==0)then
			AnimationTip.showTip(GetLocalizeStringBy("llp_290"))
		end
		UserModel.addGoldNumber(tonumber(pInfo))
		if( pCallBack )then
			pCallBack(pInfo)
		end
	end
	RedPacketService.openRedPacket(openCallBack, pEid)
end