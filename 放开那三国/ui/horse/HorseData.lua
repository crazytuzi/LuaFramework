-- FileName: HorseData.lua 
-- Author: llp
-- Date: 16-03-31
-- Purpose: function description of module 

module("HorseData", package.seeall)

require "db/DB_Kuafu_contest"
require "db/DB_Kuafu_contest_dayreward"

local _horseInfo = nil  -- 木流牛马数据
local _robTime   = 0    -- 抢夺次数
local _carryTime = 0    -- 运送次数
local _helpTime  = 0 	-- 协助次数
local _friendData = {}
local _invitedFriendData = {}
local _otherHelpFriendData = {}
local _teamInfo = {}
local _isDouble = false
function getTeamInfo(  )
	-- body
	return _teamInfo
end

function setTeamInfo( pInfo )
	-- body
	_teamInfo = pInfo
end

function setDouble( pDouble )
	-- body
	_isDouble = pDouble
end

function getDouble()
	-- body
	return _isDouble
end

function setTeamRageByType( pType )
	-- body
	_teamInfo[pType].have_rage = 1
end

function sethorseInfo( phorseData )
	_horseInfo = phorseData
end

function gethorseInfo( ... )
	return _horseInfo
end

function setHaveFriend( ... )
	-- body
end

function setHaveSelf( pHave )
	-- body
	_horseInfo.have_charge_dart = pHave
end

function setHorseQuality( pStage )
	-- body
	_horseInfo.stage_id = pStage
end

function getHorseQuality(  )
	-- body
	return tonumber(_horseInfo.stage_id)
end

--[[
	@des 	: 设置抢夺次数
	@param 	: 
	@return : 
--]]
function setRobTimes( pRobTimes )
	_horseInfo.rest_rob_num = tonumber(_horseInfo.rest_rob_num)+pRobTimes
end

--[[
	@des 	: 获取挑战完成次数
	@param 	: 
	@return : 
--]]
function getRobTimes( ... )
	return _horseInfo.rest_rob_num
end


function setHaveRobNum( pNum )
	-- body
	_horseInfo.rob_num = tonumber(_horseInfo.rob_num) + pNum
end
--[[
	@des 	: 设置运送次数
	@param 	: 
	@return : 
--]]
function setCarryTimes( pNum )
	_horseInfo.rest_ship_num = tonumber(_horseInfo.rest_ship_num)+pNum
end

function getCarryTimes( ... )
	-- body
	return tonumber(_horseInfo.rest_ship_num)
end

function setShippingNum( pNum )
	-- body
	 _horseInfo.shipping_num = tonumber(_horseInfo.shipping_num)+pNum
end

--[[
	@des 	: 获取协助次数
	@param 	: 
	@return : 
--]]
function getHelpTimes( ... )
	return _horseInfo.rest_assistance_num
end

--[[
	@des 	: 设置协助次数
	@param 	: 
	@return : 
--]]
function setHelpTimes( pNum )
	_horseInfo.rest_assistance_num = tonumber(_horseInfo.rest_assistance_num)+pNum
end

--[[
	@des 	: 获取车的信息
	@param 	: 
	@return : 
--]]
function gethorseInfoByHid( pHid )
	-- body
	for k,v in pairs(_horseInfo.horseInfo) do
		if(v.hid==pHid)then
			return v
		end
	end
end

function setOnlineFriendData( pData )
	-- body
	local data = {}
	for k,v in pairs(pData)do
		if(tonumber(v.status)==1)then
			table.insert(data,v)
		end
	end
	_friendData = data
end

function getOnlineFriendData()
	-- body
	return _friendData
end

function isSelfInfo(pUid)
	local userId = UserModel.getUserUid()
	if(userId==pUid)then
		return "true"
	else
		return "false"
	end
end

function removeInviteByUid(uid )
	local uname = ""
	for i=1, table.count(_friendData) do
		if(tonumber(_friendData[i].uid) == tonumber(uid)) then
			uname = _friendData[i].uname
			table.remove(_friendData, i)
			--break
			return uname
		end
	end
	return uname
end

function getInvitedData(  )
	-- body
	return _invitedFriendData
end

function addInvitedData( pData )
	-- body
	local haveSame = false
	for k,v in pairs(_invitedFriendData) do
		if(tonumber(v.uid)==tonumber(pData.uid))then
			haveSame = true
			break
		end
	end
	if(haveSame==false)then
		table.insert(_invitedFriendData,pData)
	end
end

function removeInvitedDataByUid( pUid )
	for k,v in pairs(_invitedFriendData) do
		if(tonumber(v.uid)==pUid)then
			table.remove(_invitedFriendData,k)
			break
		end
	end
end

function getOtherData()
	-- body
	return _otherHelpFriendData
end

function addOtherHelpData( pData )
	local haveSame = false
	for k,v in pairs( _otherHelpFriendData ) do
		if(tonumber(v.uid)==tonumber(pData.uid))then
			haveSame = true
			break
		end
	end
	if(haveSame==false)then
		table.insert(_otherHelpFriendData,pData)
	end
end

function removeOtherDataByUid( pUid )
	for k,v in pairs(_otherHelpFriendData) do
		if(tonumber(v.uid)==pUid)then
			table.remove(_otherHelpFriendData,k)
			break
		end
	end
end

function isHaveInvite(  )
	-- body
	if(not table.isEmpty(_otherHelpFriendData))then
		return true
	else
		return false
	end
end

function clearOtherData( ... )
	-- body
	_otherHelpFriendData = {}
end

function isDoubleTime( pTime )
	-- body
	local dbInfo = DB_Mnlm_rule.getDataById(1)
    local timeArry = string.split(dbInfo.doubletime,",")
    _timePoint = {}
    for k,v in pairs(timeArry)do
        local timeData = string.split(v,"|")
        for key,value in pairs(timeData)do
            local time = tonumber(value)/3600
            table.insert(_timePoint,tonumber(time))
        end
    end

    local temp = os.date("*t", pTime)
    if(temp.hour>=_timePoint[1] and temp.hour<_timePoint[2])then
        return true
    elseif(temp.hour>=_timePoint[3] and temp.hour<_timePoint[4])then
        return true
    else
        return false
    end
end

function getTipLabelStr( ... )
	-- body
	require "db/DB_Mnlm_items"
	local rewardData = DB_Mnlm_items.getDataById(1).reward
	local levelRewardData = string.split(rewardData,";")
	local userLevel = UserModel.getAvatarLevel()
	local levelTable = {}
	for k,v in pairs(levelRewardData) do
		local data = string.split(v,",")
		table.insert(levelTable,data[1])
	end

	local userLevel = UserModel.getAvatarLevel()
	local index = 1
	for k,v in pairs(levelTable) do
		if(userLevel>=tonumber(v))then
			index = k
		end
	end
	local str = "images/active/activeList/" .. index .. ".png"
	return str
end

function getLevelNameByStage( pStageId )
	-- body
	local horseNameTable = {
		GetLocalizeStringBy("llp_352"),
		GetLocalizeStringBy("llp_353"),
		GetLocalizeStringBy("llp_354"),
		GetLocalizeStringBy("llp_355")
	}
	return horseNameTable[pStageId]
end