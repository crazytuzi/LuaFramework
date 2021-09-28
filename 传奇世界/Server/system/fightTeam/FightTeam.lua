--FightTeam.lua
require ("base.class")

FightTeam = class(nil)

local prop = Property(FightTeam)

prop:accessor("fightID", 0)
prop:accessor("fightName", "")
prop:accessor("leaderID", 0)
prop:accessor("leaderName", 0)
prop:accessor("winNum", 0)
prop:accessor("loseNum", 0)

function FightTeam:__init()
	self._fightMembers = {}	--成员列表
end

function FightTeam:__release()
	table.clear(self._fightMembers)
end

--添加成员 
function FightTeam:addFactionMember(member)
	self._fightMembers[member:getRoleSID()] = member
end

--添加新成员 
function FightTeam:addNewMember(roleSID, isLeader)
	local memPlayer = g_entityMgr:getPlayerBySID(roleSID)
	if not memPlayer then
		return
	end

	local mem = FightTeamMember(roleSID, self:getFightID())
	mem:setName(memPlayer:getName())
	mem:setLevel(memPlayer:getLevel())
	mem:setSchool(memPlayer:getSchool())
	mem:setAbility(memPlayer:getbattle())
	if isLeader then
		mem:setPosition(FIGHTTEAM_POSITION.Leader)
	end

	self._fightMembers[roleSID] = mem

	--给玩家设置战队ID
	memPlayer:setFightTeamID(self:getFightID())

	mem:updateMem(self:getFightID())
end

--删除成员
function FightTeam:removeMember(roleSID)
	local memPlayer = g_entityMgr:getPlayerBySID(roleSID)
	if memPlayer then
		memPlayer:setFightTeamID(0)
	end
	self._fightMembers[roleSID] = nil
	
	g_entityDao:updateFightTeamMember(roleSID,self:getFightID(),"", 0)
end

--获取成员
function FightTeam:getMember(roleSID)
	return self._fightMembers[roleSID]
end

function FightTeam:hasMember(roleSID)
	return self._fightMembers[roleSID] and true or false
end

--获取所有战队成员
function FightTeam:getAllMembers()
	return self._fightMembers or {}
end

--获取除队长外战力最高的成员
function FightTeam:getHighBattleMem()
	local maxBattle = 0
	local retSID = 0
	for roleSID, mem in pairs(self._fightMembers or {}) do
		if mem:getPosition() ~= FIGHTTEAM_POSITION.Leader and mem:getAbility() > maxBattle then
			maxBattle = mem:getAbility()
			retSID = roleSID
		end
	end

	return retSID
end

--获取战队成员数量
function FightTeam:getAllMemberCnt()
	return table.size(self._fightMembers or {})
end


function FightTeam:getTotalAbility()
	local totalBattle = 0
	for roleSID, mem in pairs(self._fightMembers) do
		local battle = mem:getAbility()
		local memPlayer = g_entityMgr:getPlayerBySID(roleSID)
		if memPlayer then
			battle = memPlayer:getbattle()
		end
		totalBattle = totalBattle + battle
	end
	return totalBattle
end

function FightTeam:update2DB()
	g_entityDao:updateFightTeam(self:getFightID(), self:getLeaderID(),self:getLeaderName(), self:getWinNum(),self:getLoseNum())
end

--读数据解析字符串
function FightTeam:readString(buff)
	self:setFightID(buff:popInt())
	self:setFightName(buff:popString())
	self:setLeaderID(buff:popString())
	self:setLeaderName(buff:popString())
	self:setWinNum(buff:popInt())
	self:setLoseNum(buff:popInt())
end
