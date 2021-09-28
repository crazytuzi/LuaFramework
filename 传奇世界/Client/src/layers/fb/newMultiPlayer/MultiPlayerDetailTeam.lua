--Author:		bishaoqing
--DateTime:		2016-05-31 13:06:18
--Region:		多人守卫详细队伍对象
local MultiPlayerDetailTeam = class("MultiPlayerDetailTeam")
local MultiPlayerMem = require("src/layers/fb/newMultiPlayer/MultiPlayerMem")
--[[
message CopyGetTeamDataRetProtocol
{
	optional int32 teamId = 1;
	optional int32 copyId = 2;
	optional int32 createTime = 3;
	optional int32 memNum = 4;
	repeated CopyMemberInfo info = 5;
}
]]

function MultiPlayerDetailTeam:ctor( ... )
	-- body
	self.m_stAllMemObj = {}
	self.m_nMemUid = 0
end

function MultiPlayerDetailTeam:reset( stInfo )
	-- body
	self.m_stInfo = stInfo

	self.m_nTeamId = stInfo.teamId
	self.m_nCopyId = stInfo.copyId
	self.m_nCreateTime = stInfo.createTime
	self.m_nMemNum = stInfo.memNum

	
	self:resetMemInfo(stInfo.info)
end

function MultiPlayerDetailTeam:isFull( ... )
	-- body
	return self.m_nMemNum >= 4
end

function MultiPlayerDetailTeam:getInfo( ... )
	-- body
	return self.m_stInfo
end

function MultiPlayerDetailTeam:getTeamId( ... )
	-- body
	return self.m_nTeamId
end

function MultiPlayerDetailTeam:getCopyId( ... )
	-- body
	return self.m_nCopyId
end

function MultiPlayerDetailTeam:getCreateTime( ... )
	-- body
	return self.m_nCreateTime
end

function MultiPlayerDetailTeam:getMemNum( ... )
	-- body
	return self.m_nMemNum
end

function MultiPlayerDetailTeam:resetMemInfo( info )
	-- body
	self.m_vAllMemInfo = info
	self:clearAllMem()
	if not self.m_vAllMemInfo then
		return
	end
	for i,stInfo in ipairs(self.m_vAllMemInfo) do
		local oMem = self:createMemObj(stInfo)
		if oMem then
			if i == 1 then
				oMem:setIsCaptain(true)
			end
			self:addMemObj(oMem)
		end
	end
end

function MultiPlayerDetailTeam:getCapTain( ... )
	-- body
	for nUid,oMem in pairs(self.m_stAllMemObj) do
		if oMem:getIsCaptain() == true then
			return oMem
		end
	end
end

function MultiPlayerDetailTeam:isCaptain( nId )
	-- body
	print("isCaptain", nId)
	if not nId then
		return false
	end
	local oCaptain = self:getCapTain()
	print("oCaptain")
	if oCaptain then
		print("oCaptain:getMemberId", oCaptain:getMemberId(), nId)
		return oCaptain:getMemberId() == nId
	end
	return false
end

function MultiPlayerDetailTeam:createMemObj( stInfo )
	-- body
	self.m_nMemUid = self.m_nMemUid + 1
	local oMem = MultiPlayerMem.new(self.m_nMemUid)
	oMem:reset(stInfo)
	return oMem
end

function MultiPlayerDetailTeam:addMemObj( oMem )
	-- body
	if not oMem then
		return
	end
	local nUid = oMem:getUid()
	self.m_stAllMemObj[nUid] = oMem
end

function MultiPlayerDetailTeam:getMemObj( nUid )
	-- body
	return self.m_stAllMemObj[nUid]
end

function MultiPlayerDetailTeam:removeMemObj( nUid )
	-- body
	local oMem = self.m_stAllMemObj[nUid]
	if oMem then
		oMem:dispose()
		self.m_stAllMemObj[nUid] = nil
	end
end

function MultiPlayerDetailTeam:clearAllMem( ... )
	-- body

	for nUid,oMem in pairs(self.m_stAllMemObj) do
		self:removeMemObj(nUid)
	end
end

function MultiPlayerDetailTeam:getAllMem( bSort )
	-- body
	local vRet = {}
	for nUid,oMem in pairs(self.m_stAllMemObj) do
		table.insert(vRet, oMem)
	end
	if bSort then
		table.sort(vRet, function( a, b )
			-- body
			return a:getUid() < b:getUid()
		end)
	end
	return vRet
end

function MultiPlayerDetailTeam:dispose( ... )
	-- body
end

return MultiPlayerDetailTeam