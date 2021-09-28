-- Filename: RedPacketData.lua
-- Author: llp
-- Date: 2015-12-25
-- Purpose: 红包数据中心

module("RedPacketData" , package.seeall)

local _redPacketData = nil
local _singleRedPacketData = nil
local _clickTag = 1
local _isShowRedPacket = false

function setShowRedPacket( pShow )
	_isShowRedPacket = pShow
end

function getShowRedPacket(  )
	return _isShowRedPacket
end

function setRedPacketData( pData )
	_redPacketData = pData
end

function getRedPacketData()
	return _redPacketData
end

function setSingleData( pData,pEid )
	_singleRedPacketData = pData
	_singleRedPacketData.eid = pEid
end

function getSingleData( ... )
	return _singleRedPacketData
end

function isActiveOpen()
	-- body
	if(not table.isEmpty(_redPacketData))then
		return true
	else
		return false
	end
end

function setClickTag( pTag )
	_clickTag = pTag
end

function getClickTag( ... )
	return _clickTag
end

function isHaveRob(  )
	local data = RedPacketData.getSingleData()
	local isHaveRob = false
	for index,robinfo in ipairs(data.rankList) do
		if(tonumber(robinfo.uid)==UserModel.getUserUid())then
			isHaveRob =  true
			break
		end
	end
	return isHaveRob
end

function isShowRed()
	local redInfo = getRedPacketData()
	if(redInfo==nil)then
		_isShowRedPacket = false
		return _isShowRedPacket
	end
	if(table.isEmpty(redInfo.rankList))then
		_isShowRedPacket = false
		return _isShowRedPacket
	end

	local serverTime = tonumber(TimeUtil.getSvrTimeByOffset())
	for i,v in ipairs(redInfo.rankList) do
		local endtime = tonumber(v.sendTime) + tonumber(ActivityConfig.ConfigCache.envelope.data[1].time)
		require "script/ui/redpacket/RedPacketLayer"
		local isShow = RedPacketLayer.getIsRedLayer()
		if(tonumber(v.left)~=0 and serverTime<endtime and isShow==false )then
			_isShowRedPacket = true
			return _isShowRedPacket
		end
	end
	return _isShowRedPacket
end

function isRedPacketOpen()
	require "script/model/utils/ActivityConfigUtil"
	if(  ActivityConfigUtil.isActivityOpen("envelope") == false)then
		return false
	end
	return tonumber(ActivityConfig.ConfigCache.envelope.data[1].level)<=tonumber(UserModel.getHeroLevel())
end


