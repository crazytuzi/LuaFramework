--CopyTeam.lua
--副本队伍

CopyTeam = class()
local prop = Property(CopyTeam)
prop:accessor("teamID", 0)	
prop:accessor("maxMemCnt", 0)	--最大人数
prop:accessor("copyID", 0)	--副本proto ID
prop:accessor("needBattle", 0)	--需要的战力
prop:accessor("leaderName", "")	--需要的战力
prop:accessor("inCopy", false)	--是否在副本里面
prop:accessor("createTime",0)--创建时间
prop:accessor("leaderBattle",0)--队长战力

function CopyTeam:__init(playerID, teamID)
	prop(self, "teamID", teamID)
	self._memSorts = {playerID}
	self._memID = {[playerID] = true}
	self._hurts = {[playerID] = 0}
	self._lastBroadCastTime = 0
end

function CopyTeam:getLastBroadCastTime()
	return self._lastBroadCastTime
end

function CopyTeam:setLastBroadCastTime(time)
	self._lastBroadCastTime = time
end

--添加成员
function CopyTeam:addCopyMem(roleID)
	if not table.contains(self._memSorts, roleID) then
		table.insert(self._memSorts, roleID)
	end
	self._memID[roleID] = false
	self._hurts[roleID] = 0
end

function CopyTeam:removeCopyMem(roleID)
	table.removeValue(self._memSorts, roleID)
	self._memID[roleID] = nil
	self._hurts[roleID] = nil
end

function CopyTeam:setMemState(roleID, flag)
	self._memID[roleID] = flag
end

function CopyTeam:getMemState(roleID)
	return self._memID[roleID]
end

function CopyTeam:getMemCnt()
	return #self._memSorts
end

function CopyTeam:getAllMems()
	return self._memSorts
end

--是否所有人准备好了
function CopyTeam:isAllReady()
	for k, v in pairs(self._memID) do
		if not v then
			return false
		end
	end
	return true
end

function CopyTeam:hasMem(roleID)
	return self._memID[roleID] ~= nil
end

function CopyTeam:changeState(roleID, flag)
	self._memID[roleID] = (flag == true and true or false)
end

function CopyTeam:addHurt(roleID, hurt)
	self._hurts[roleID] = self._hurts[roleID] and self._hurts[roleID]+hurt or hurt
end

function CopyTeam:getHurts()
	return self._hurts
end
