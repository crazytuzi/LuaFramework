--Team.lua
--/*-----------------------------------------------------------------
 --* Module:  Team.lua
 --* Author:  Wang Lin
 --* Modified: 2014年4月3日 15:49:14
 --* Purpose: Implementation of the class Team
 -------------------------------------------------------------------*/
require ("base.class")
Team = class()

local prop = Property(Team)
prop:accessor("teamID")
prop:accessor("leaderID")
prop:accessor("autoInvited", true) 			--自动允许申请入队
prop:accessor("targetType",1)
--copy team related
prop:accessor("copyID")
prop:accessor("maxMemCnt", 0)	
prop:accessor("needBattle", 0)	
prop:accessor("leaderName", "")	
prop:accessor("inCopy", false)	
prop:accessor("createTime",0)
prop:accessor("leaderBattle",0)

function Team:__init(teamid, leaderID)
	self._onLineMems = {} 					--在线队员  存的静态ID
	self._onLineMemsID = {} 				--在线队员  存的动态ID
	self._offLineMems = {} 					--离线队员  存的静态ID
	self._applyInfo = {}
	self._memID = {[leaderID] = true}
	prop(self, "teamID", teamid)
	prop(self, "leaderID", leaderID)

end

--brief:添加入队申请
function Team:addNewApply(tLeaderSID,sRoleSID)
	local now = os.time()
	local apply = {}
	apply.leaderID = tLeaderSID
	apply.roleSID = sRoleSID
	apply.time = now

	table.insert(self._applyInfo, apply)
end

function Team:getApplyInfo()
	return self._applyInfo
end

function Team:isApplyed(applyId)
	for _, v in pairs(self._applyInfo) do
		if v.roleSID == applyId then
			return true
		end
	end
	return false
end

function Team:updateApplyTime(applyId)
	for _, v in pairs(self._applyInfo) do
		if v.roleSID == applyId then
			v.time = os.time()
			break
		end
	end
end

function Team:removeApplyID(applyID)
	for i, v in pairs(self._applyInfo) do
		if v.roleSID == applyID then
			table.remove(self._applyInfo, i)
			break
		end
	end
end

function Team:getApplyCnt()
	return table.size(self._applyInfo)
end

--brief:提升队长
function Team:changeLeader(newLeaderID)
	self.leaderID = newLeaderID
end

--获取所有队员
function Team:getAllMember()
	local tmp = {}
	for i=1, #self._onLineMems do
		table.insert(tmp, self._onLineMems[i])
	end
	for i=1, #self._offLineMems do
		table.insert(tmp, self._offLineMems[i])
	end
	return tmp
end

function Team:getMemCount()
	return table.size(self._onLineMems) + table.size(self._offLineMems)
end

function Team:addOnLineMem(memberSID)
	if table.contains(self._onLineMems,memberSID) then return end
	table.insert(self._onLineMems, memberSID)
end

function Team:addOnLineMemID(memberID)
	if table.contains(self._onLineMemsID,memberID) then return end
	table.insert(self._onLineMemsID, memberID)
end

function Team:removeOnLineMem(memberSID)
	table.removeValue(self._onLineMems, memberSID)
end

function Team:removeOnLineMemID(memberID)
	table.removeValue(self._onLineMemsID, memberID)
end

--获取所有在线队员静态ID
function Team:getOnLineMems()
	return self._onLineMems
end

--获取所有在线队员动态ID
function Team:getOnLineMemsID()
	return self._onLineMemsID
end

--获取在线队员数量
function Team:getOnLineCnt()
	return #self._onLineMems
end

--获取所有离线队员
function Team:getOffLineMems()
	return self._offLineMems
end

--获取所有离线队员数量
function Team:getOffLineCnt()
	return self._offLineMems
end

function Team:addOffLineMem(memberID)
	if table.contains(self._offLineMems,memberID) then return end
	table.insert(self._offLineMems, memberID)
end

function Team:removeOffLineMem(memberID)
	table.removeValue(self._offLineMems, memberID)
end

--获取伤害加成
function Team:getHurtInc()
	return (self:getOnLineCnt()-1)/100
end

--获取经验加成
function Team:getExpInc()
	return (self:getOnLineCnt()-1)/100
end


function Team:setMemState(roleID, flag)
	self._memID[roleID] = flag
end

function Team:getMemState(roleID)
	return self._memID[roleID]
end