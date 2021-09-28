--SwornBrothersManager.lua

require ("system.swornbrothers.SwornBrosConstant")
require ("system.swornbrothers.SwornBros")
require ("system.swornbrothers.SwornBrosServlet")

SwornBrosManager = class(nil, Singleton)

SwornBrosManager.relationData = {}

function SwornBrosManager:__init()
	g_listHandler:addListener(self)
	self._max_id = g_worldID * 100000		-- reserve 100k for id
	self._sworn_bros = {}
	self._temp_teams = {}	-- teamid:serialID of members, leaderSID, count
	self._psvSkillData = {}
	--self._prevMapPos = {}
	
	g_entityDao:loadMaxSwornID()
	g_entityDao:loadAllData("swornbros", g_frame:getWorldId())
end

function SwornBrosManager:genSwornID()
	self._max_id = self._max_id + 1
	return self._max_id
end

function SwornBrosManager:setMaxSwornID(id)
	print("setMaxSwornBrosID:", id)
	if id > 0 then
		self._max_id = id
	end
end
--[[
function SwornBrosManager:setPrevPos(roleID, mapID, x, y)
	local pos = {mapID, x, y}
	self._psvSkillData[roleID] = pos
end
--]]

function SwornBrosManager.loadSwornBros(id, buff)
	local luabuf = tolua.cast(buff, "LuaMsgBuffer")
	local sworn = SwornBros(id)
	sworn:loadFromBuff(luabuf)
	SwornBrosManager.getInstance():addSwornBros(sworn)
end
function SwornBrosManager:setSwornID(sid, swornID)
	print("sworn member:",sid, " set swornID:", swornID)
	local player = g_entityMgr:getPlayerBySID(sid)
	if player then
		player:setSwornBrosID(swornID)
	end
	g_entityDao:updateSwornBros(sid, swornID, 0)
end
function SwornBrosManager:setSwornLeaveTime(sid, swornID)
	local time = os.time()
	print("sworn member:",sid, " set swornID:", swornID, " set leaveTime:", time)	
	local player = g_entityMgr:getPlayerBySID(sid)
	if player then
		player:setSwornBrosID(swornID)
		player:setLeaveSwornTime(time)
	end
	g_entityDao:updateSwornBros(sid, swornID, time)
end

--members is a table of the serialID collection of team members
function SwornBrosManager:addTempTeam(teamID, members, leaderSID, swornBrosID)	
	if teamID ~= 0 and #members > 0 then
		print("swornMgr add team:",teamID," members are:")
		for _,m in pairs(members) do
			print(members)
		end
		self._temp_teams[teamID] = {members , leaderSID, 0, swornBrosID}	-- 0 represents number of members who agreed
	end
end
function SwornBrosManager:getTempTeam(teamID)
	local data = self._temp_teams[teamID]
	if data then
		return data[1]
	end
	return nil
end
function SwornBrosManager:removeTempTeam(teamID)
	print("swornMgr remove team:", teamID)
	self._temp_teams[teamID] = nil
end

function SwornBrosManager:onSwornAgree(player, teamID)
	print("=====onSwornAgree:", player:getSerialID(), teamID)
	local info = self._temp_teams[teamID]
	if not info then
		print("***************can't find sworn!!!")
		return doSwornActionRet(player:getID(), SwornBrosErrCode.INEXISTENT_SWORN)
	end

	local members = info[1]
	if not table.include(members, player:getSerialID()) then
		print("can't find sworn data for player:", player:getSerialID())
		return doSwornActionRet(player:getID(), SwornBrosErrCode.INEXISTENT_SWORN)
	end
	info[3] = info[3] + 1
	local done = (info[3] == #members) and true or false
	local retData = {}
	retData.roleId = player:getSerialID()
	retData.done = done
	if not done then
		for _, memberSID in pairs(members) do
			print("fireProtoMessageBySid to ", memberSID,"done=",done)
			fireProtoMessageBySid(memberSID, SWORN_SC_AGREE_ACTION, "AgreeSwornAction", retData)	
		end
	end
	if done then
		local ret = self:onSwornAllAgree(teamID, info)
		if ret == true then
			for _, memberSID in pairs(members) do
				print("fireProtoMessageBySid to ", memberSID,"done=",done)
				fireProtoMessageBySid(memberSID, SWORN_SC_AGREE_ACTION, "AgreeSwornAction", retData)	
			end
		else
			return doSwornActionRet(player:getID(), INEXISTENT_SWORN)
		end
	end
end

function SwornBrosManager:onActivePlayer(player)
	print("SwornBrosManager:onActivePlayer:"..player:getSerialID())
	local sworn = self:getSwornBrosByPlayer(player)
	if sworn then
		sworn:sendBasicInfo(player)
	else
		local ret = {}
		ret.sworn_id = 0
		fireProtoMessage(player:getID(), SWORN_SC_BASIC_INFO, "SwornBasicInfoRet", ret)
		removeSwornActiveSkills(player)
	end
end

function SwornBrosManager:onSwornAllAgree(teamID, info)
	print("=====SwornBrosManager:onSwornAllAgree for team:", teamID)
	-- check again, cause the process is asynchronism
	local members = {}
	local leaderSID = info[2]
	local leader_found = false
	local swornBrosID = info[4]

	for _, memberSID in pairs(info[1]) do
		local member = g_entityMgr:getPlayerBySID(memberSID)
		if member then
			if memberSID == leaderSID then 
				leader_found = true
			end
			if swornBrosID == 0 or member:getSwornBrosID() ~= swornBrosID then
				members[#members+1] = member
				if not isMatEnough(member, SWORN_ITEM_ID, SWORN_ITEM_NUM) then
					return doSwornActionRetBySID(leaderSID, SwornBrosErrCode.NO_SWORN_ITEM, memberSID)
				end
			end
		end
	end
	if leader_found == false then
		print("erro!!! check failed!!! leader_found for team:"..teamID)
		return false
	end

	for _, member in pairs(members) do
		costMat(member, SWORN_ITEM_ID, SWORN_ITEM_NUM, SWORN_COST_TYPE, 0)
	end
	self:removeTempTeam(teamID)
	if swornBrosID == 0 then
		return self:createNewSworn(teamID, members, leaderSID)
	else
		local sworn = self:getSwornBrosByID(swornBrosID)
		if sworn then
			return sworn:addNewMembers(members)
		else
			print("Error!!!!!!!!!!can't find sworn:", swornBrosID)
		end
	end
	return false
end

function SwornBrosManager:createNewSworn(teamID, members, leaderSID)
	local swornID = self:genSwornID()
	local sworn = SwornBros(swornID)
	print("======new sworn created!", swornID, " leader:", leaderSID)
	sworn:setLeaderID(leaderSID)
	sworn:setTime(os.time())
	self:addSwornBros(sworn)
	for _, member in pairs(members) do
		sworn:addMember(member)
	end
	sworn:sendBasicInfoToAll()

	local member_buf = sworn:serializeMembers()
	g_entityDao:createSwornBros(SPDEF_CREATESWORNBROS, swornID, leaderSID, sworn:getTime(), sworn:getSkillPoints(), member_buf, #member_buf)
	gTimerMgr:regTimer(sworn, SWORN_TIMER_PERIOD, SWORN_TIMER_PERIOD)
	return true
end

function SwornBrosManager:addSwornBros(swornBros)
	--print("addSwornBros, id=", swornBros:getSwornID())
	self._sworn_bros[swornBros:getSwornID()] = swornBros
end

function SwornBrosManager:getSwornBrosByID(id)
	return self._sworn_bros[id]
end
function SwornBrosManager:getSwornBrosByPlayer(player)
	if player then
		local swornID = player:getSwornBrosID()
		return self:getSwornBrosByID(swornID)
	end
	return nil
end
function SwornBrosManager:dismissSwornBors(swornBros, leaveSID)
	print("SwornBros dismiss:", swornBros:getSwornID())
	if leaveSID then
		print("leavePlayer:", leaveSID)
	end
	local swornID = swornBros:getSwornID()
	local ret = {}
	ret.type = SwornActionType.DISMISS
	swornBros:sendToAll(SWORN_SC_DO_ACTION_RET, "SwornDoActionRet", ret)
	local function removeBro(member)
		if leaveSID == member.sid then
			swornBros:removeMember(member.sid, SwornActionType.LEAVE)
		else
			swornBros:removeMember(member.sid, SwornActionType.KICK)
		end
	end
	swornBros:execMembers(removeBro)
	self._sworn_bros[swornID] = nil
	release(swornBros)
	g_entityDao:deleteSwornBros(swornID)
	return true
end
local function printAllPsvSkills(skills)
	for i, s in pairs(skills) do 
		print("===============skill "..i.."===============")
		for k,v in pairs(s) do
			if type(v) == "table" then
				print("prevSkills:")
				for _,n in pairs(v) do 
					print(n)
				end
			else
				print(k..":",v)
			end
		end
	end
end
local function parsePrevSkills(prevStr)
	local strTbl = string.split1(prevStr, ',')
	local numTbl = {}
	for _, str in pairs(strTbl) do
		local id = tonumber(str)
		if id then
			table.insert(numTbl, id)
		end
	end
	return numTbl
end
function SwornBrosManager:loadPsvSkillData()
	local data = require "data.SwornSkill" or {}
	local size = #data
	
	for i=1, size do 
		local skill = data[i]
		local new_data = {}
		new_data.id = skill.q_id
		new_data.skill_id = skill.q_skillID
		new_data.cost = skill.q_cost
		new_data.prev = parsePrevSkills(skill.q_PreSkillID)
		new_data.def_min = skill.q_defense_min or 0
		new_data.def_max = skill.q_defense_max or 0
		new_data.tenacity = skill.q_tenacity or 0
		new_data.att_min = skill.q_attack_min or 0
		new_data.att_max = skill.q_attack_max or 0
		new_data.dc_att_min = skill.q_dc_attack_min or 0
		new_data.dc_att_max = skill.q_dc_attack_max or 0
		new_data.mag_att_min = skill.q_magic_attack_min or 0
		new_data.mag_att_max = skill.q_magic_attack_max or 0
		new_data.mag_def_min = skill.q_magic_defence_min or 0
		new_data.mag_def_max = skill.q_magic_defence_max or 0
		new_data.hit = skill.q_hit or 0
		new_data.dodge = skill.q_dodge or 0
		new_data.crit = skill.q_crit or 0	
		self._psvSkillData[skill.q_id] = new_data
	end
	--printAllPsvSkills(self._psvSkillData)
end
function SwornBrosManager:getPsvSkill(skill_id)
	return self._psvSkillData[skill_id]
end

function SwornBrosManager:loadRelationData()
	local data = require "data.qyz_info" or {}
	local size = #data
	
	for i=1, size do
		local or_data = data[i]
		local new_data = {}
		new_data.value = or_data.qyzNum
		new_data.decrease = or_data.qyzAutoDown
		new_data.points = or_data.q_skillNum
		self.relationData[or_data.level] = new_data
	end
end
function SwornBrosManager:getRelationData(level)
	return self.relationData[level]
end
function SwornBrosManager:onPlayerLoaded(player)
	local sworn = self:getSwornBrosByPlayer(player)
	if sworn then
		sworn:sendBasicInfo(player)
		sworn:onPlayerOnline(player, true)
		sworn:checkActiveSkills(player)
	else
		local ret = {}
		ret.sworn_id = 0
		fireProtoMessage(player:getID(), SWORN_SC_BASIC_INFO, "SwornBasicInfoRet", ret)
		removeSwornActiveSkills(player)
	end
end

function SwornBrosManager:onPlayerOffLine(player)
	local sworn = self:getSwornBrosByPlayer(player)
	if sworn then
		sworn:onPlayerOnline(player, false)
	end
end

function SwornBrosManager:onSwitchScene(player, mapID, lastMapID)
	local sworn = self:getSwornBrosByPlayer(player)
	if sworn then
		sworn:onPlayerSwitchScene(player, mapID, lastMapID)
	end
	local petid = player:getPetID()
	if mapID == SWORN_SCENE_ID and petid > 0 then
		g_entityMgr:destoryEntity(petid)
	end
end

 function SwornBrosManager:onLevelChanged(player)
	local sworn = self:getSwornBrosByPlayer(player)
	if sworn then
		sworn:onPlayerLevelChanged(player)
	end
end
function SwornBrosManager:onPlayerDelete(roleSID)
	print("onPlayerDelete:", roleSID)
	for _, sworn in pairs(self._sworn_bros) do
		if sworn and sworn:hasMember(roleSID) then
			print("sworn:", sworn:getSwornID()," delete member")
			sworn:onMemberDelete(roleSID)
		end
	end
end

function SwornBrosManager.getInstance()
	return SwornBrosManager()
end

g_swornBrosMgr = SwornBrosManager.getInstance()
g_swornBrosMgr:loadPsvSkillData()
g_swornBrosMgr:loadRelationData()
