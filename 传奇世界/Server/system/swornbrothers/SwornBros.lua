--SwornBros.lua
require ("base.class")

SwornBros = class(nil, Timer)

local prop = Property(SwornBros)

prop:accessor("swornID")
prop:accessor("leaderID")
prop:accessor("time")
prop:accessor("skillPoints")
prop:accessor("relation")
prop:accessor("relationLvl")
prop:accessor("maxRelationLvl")
prop:accessor("timerStatus")
function removeSwornActiveSkills(player)
	local skillMgr = player:getSkillMgr()
	local ret = { skillId = {},}
	local skills = ret.skillId
	if skillMgr:delSkill(SwornActiveSkill.TRANS_ID) == true then
		table.insert(skills, SwornActiveSkill.TRANS_ID)
	end
	if skillMgr:delSkill(SwornActiveSkill.GATHER_ID) == true then
		table.insert(skills, SwornActiveSkill.GATHER_ID)
	end
	if table.len(skills) > 0 then
		fireProtoMessage(player:getID(), SKILL_SC_DELETESKILL, "SkillDelteProtocol", ret)
	end
end
function SwornBros:__init(ID)
	prop(self, "swornID", ID)
	prop(self, "skillPoints", SWORN_INIT_SKILL_POINT)
	prop(self, "relation", 0)
	prop(self, "relationLvl", 1)
	prop(self, "maxRelationLvl", 1)
	prop(self, "timerStatus", SwornTimerStatus.INVALID)
	self._cur_num = 0
	self._daily_inc_relation = 0
	self._skills = {}	--id collection of passive skills
	self._members = {}
	self._last_update = os.time()
	self._update_times = 0
	self._need_save = false
	self._online_num = 0
	self._map_player = {}	--self._map_player = {map1={id1,id2}, map2={id1,id2},}
end

function SwornBros:__release()
	table.clear(self._members)
	table.clear(self._skills)
	gTimerMgr:unregTimer(self)
end

function SwornBros:resetRelationLvl()
	local curRelation = self:getRelation()
	local datas = g_swornBrosMgr.relationData
	local items = #datas
	while items > 0 do
		local data = datas[items]
		if data.value <= curRelation then
			self:setRelationLvl(items)
			return
		else
			items = items - 1
		end
	end
end
local function printMember(data)
	print(string.format("member, id=%s, name=%s, level=%d, pro=%d, hint=%s", data.sid, data.name, data.level, data.profession, tostring(data.hint)))
end

function SwornBros:loadFromBuff(buff)
	self:setLeaderID(buff:popString())
	self:setTime(buff:popInt())
	self:setSkillPoints(buff:popInt())
	self:setRelation(buff:popInt())
	self:resetRelationLvl()
	self:setMaxRelationLvl(buff:popInt())
	self._last_update = buff:popInt()
	self._daily_inc_relation = buff:popInt()

	local memberStr = buff:popString()
	local memberData = protobuf.decode("SwornBrosProtocol", memberStr)
	
	for _, memData in pairs(memberData.info) do
		self:loadMember(memData)
	end
	
	local skillStr = buff:popString()
	local skillData = protobuf.decode("SwornBrosSkillProtocol", skillStr)
	if skillData then
		for _, skillID in pairs(skillData.skills) do
			table.insert(self._skills, skillID)
		end
	end
end

function SwornBros:loadMember(data)
	--printMember(data)
	self._members[data.sid] = data
	self._cur_num = self._cur_num + 1
end

function SwornBros:hasMember(sid)
	for k,v in pairs(self._members) do
		if k == sid and v then
			return true
		end
	end
	return false
end

function SwornBros:serializeSkills()
	local data = {skills = {},}

	for _, skill in pairs(self._skills) do
		table.insert(data.skills, skill)
	end
	
	return protobuf.encode("SwornBrosSkillProtocol", data)
end
function SwornBros:serializeMembers()
	local data = {info = {},}

	for _, mem in pairs(self._members) do
		table.insert(data.info, mem)
	end
	
	return protobuf.encode("SwornBrosProtocol", data)
end

function doSwornActionRet(playerID, errCode, targetSID)	-- send return message to player
	local ret = {result = errCode, }
	if targetSID then
		ret.sid = targetSID
	end
	print("==========ROLEID====="..playerID .. " fail to do sworn action cause " .. tostring(errCode))
	fireProtoMessage(playerID, SWORN_SC_ENTER_SCENE, "EnterSwornSceneRes", ret)
end
function doSwornActionRetBySID(SID, errCode, targetSID)
	local ret = {result = errCode,}
	if targetSID then
		ret.sid = targetSID
	end	
	print("===========SID====="..SID .. " fail to do sworn action cause " .. tostring(errCode))	
	fireProtoMessageBySid(SID, SWORN_SC_ENTER_SCENE, "EnterSwornSceneRes", ret)	
end
local function diffDay(ts1, ts2)
	if ts1 == 0 or ts2 == 0 then
		return true
	end
	local DAY_SEC = 24 * 3600
	if ts2 < ts1 then
		ts1, ts2 = ts2, ts1
	end
	if ts2 - ts1 > DAY_SEC then
		return true
	end
	
	local t1 = os.date("*t", ts1)
	local t2 = os.date("*t", ts2)
	t1.hour, t1.min, t1.sec = 0,0,0
	t2.hour, t2.min, t2.sec = 0,0,0

	ts1 = os.time(t1)
	ts2 = os.time(t2)
	return ts1 ~= ts2
end
local function diffWeek(ts1, ts2)
	if ts1 == 0 or ts2 == 0 then
		return true
	end
	local DAY_SEC = 24 * 3600
	local WEEK_SEC = 7 * DAY_SEC
	if ts2 < ts1 then
		ts1, ts2 = ts2, ts1
	end
	if ts2 - ts1 > WEEK_SEC then
		return true
	end
	
	local t1 = os.date("*t", ts1)
	local t2 = os.date("*t", ts2)
	t1.hour, t1.min, t1.sec = 0,0,0
	t2.hour, t2.min, t2.sec = 0,0,0
	--wday starts from 1(Sunday), so we need to sub 2 
	--if one week starts from Monday in our convention
	local day1 = ((t1.wday == 1) and 8 or t1.wday) - 2
	local day2 = ((t2.wday == 1) and 8 or t2.wday) - 2

	ts1 = os.time(t1)
	ts2 = os.time(t2)
	return (ts1 - day1 * DAY_SEC) ~= (ts2 - day2 * DAY_SEC)
end

function SwornBros:getCurNum()
	return self._cur_num
end

function SwornBros:addMember(player)
	print("SwornBros addMember:",player:getSerialID())
	if player then
		local sid = player:getSerialID()
		local exitsed_mem = self._members[sid]
		if exitsed_mem then
			print("player ", player:getSerialID(), "is in swornbros:", self:getSwornID())
			return false
		end
		g_swornBrosMgr:setSwornID(player:getSerialID(), self:getSwornID())
		local new_mem = {}
		new_mem.name = player:getName()
		new_mem.sid = sid
		new_mem.level = player:getLevel()
		new_mem.profession = player:getSchool()
		new_mem.hint = true
		
		self._members[new_mem.sid] = new_mem
		self._cur_num = self._cur_num + 1
		
		self:onNewMember(player)
		return true
	end
	return false
end

function SwornBros:removeMember(targetID, removeType)
	print("SwornBros", self:getSwornID()," remove:", targetID, "removeType:", removeType)
	local member = self._members[targetID]
	if member then
		print("SwornBros remove:", targetID)
		self._cur_num = self._cur_num - 1
		self._members[targetID] = nil
		if removeType == SwornActionType.LEAVE then
			g_swornBrosMgr:setSwornLeaveTime(targetID, 0)
		else
			g_swornBrosMgr:setSwornID(targetID, 0)
		end
		local player = g_entityMgr:getPlayerBySID(targetID)
		if player then
			removeSwornActiveSkills(player)
			self:removeAllPsvSkills(player)
			self:onPlayerOnline(player, false)
		end
		return true
	end
	return false
end
function SwornBros:getMember(sid)
	local player = g_entityMgr:getPlayerBySID(sid)
	return self._members[sid], player
end
function SwornBros:addNewMembers(members)
	local ret = false
	for _, member in pairs(members) do
		if self:addMember(member) == true then
			ret = true
		end
	end
	if ret == true then
		self:saveMembers()
		self:sendBasicInfoToAll()
	end
	return ret
end
function SwornBros:onNewMember(member)
	for _,v in pairs(self._skills) do
		local skill_data = g_swornBrosMgr:getPsvSkill(v)
		if skill_data then
			if skill_data.id <= SWORN_MAX_ACTIVE_SKILL then
				local skillMgr = member:getSkillMgr()
				skillMgr:learnSkill(skill_data.skill_id, 0)
			end
		end
	end
	self:onPlayerOnline(member, true)
end
function SwornBros:update()
	local map_count = {}
	local function mem_count(member)
		local mapID = member:getMapID()
		local count = map_count[mapID]
		if count then
			map_count[mapID] = count + 1
		else
			map_count[mapID] = 1
		end
	end
	self:execOnlineMembers(mem_count)
	local inc = 0
	for k,v in pairs(map_count) do
		if v >= SWORN_RELATION_MIN_BROS then
			inc = inc + v
		end
	end
	if inc > 0 then
		self:increaseRelation(inc * RELATION_RATE, true)
	end
	if self._last_update > 0 and diffWeek(self._last_update, os.time()) then
		self:decreaseRelation()
	end
	if self._last_update > 0 and diffDay(self._last_update, os.time()) then
		self._daily_inc_relation = 0
		self:forceSaveData()
	end
	self._last_update = os.time()
end
function SwornBros:incUpdateTimes()
	self._update_times = self._update_times + 1
	self._need_save = true
	if self._update_times >= 3 then
		self:saveData()
		self._update_times = 0
	end
end

function SwornBros:sendBasicInfo(player)
	if not player then
		return
	end
	local ret = {}
	ret.sworn_id = self:getSwornID()
	ret.relation = self:getRelation()

	ret.bros = {}
	local function fillInfo(member)
		local memInfo = {}
		memInfo.role_id = member.sid
		memInfo.name = member.name
		memInfo.level = member.level
		memInfo.profession = member.profession
		memInfo.is_leader = (self:getLeaderID() == member.sid and true or false)
		table.insert(ret.bros, memInfo)
		
		if member.sid == player:getSerialID() then
			ret.online_hint = member.hint
		end
	end
	self:execMembers(fillInfo)
	fireProtoMessage(player:getID(), SWORN_SC_BASIC_INFO, "SwornBasicInfoRet", ret)
end

function SwornBros:sendSkillInfo(player)
	if not player then
		return
	end
	local ret = {}
	ret.points = self:getSkillPoints()
	ret.skills = {}
	for _, skill in pairs(self._skills) do
		table.insert(ret.skills, skill)
	end
	fireProtoMessage(player:getID(), SWORN_SC_SKILL_INFO, "SwornSkillInfoRet", ret)
end
function SwornBros:decreaseRelation()
	local cur_lvl = self:getRelationLvl()
	local tbl = g_swornBrosMgr:getRelationData(cur_lvl)
	if not tbl then
		return
	end
	local old_value = self:getRelation()

	print("Sworn ", self:getSwornID(), " decreaseRelation!!!,curRelation:", old_value, "curLevel:", cur_lvl)
	value = (old_value >= tbl.decrease and (old_value - tbl.decrease) or 0)
	if old_value == value then
		return
	end
	self:setRelation(value)
	self:incUpdateTimes()
	local need_value = tbl.value
	local need_notify = false
	while value < need_value do
		cur_lvl = cur_lvl - 1
		need_notify = true
		local tbl = g_swornBrosMgr:getRelationData(cur_lvl)
		if tbl then
			need_value = tbl.value
		else
			break
		end
	end
	if need_notify then
		self:setRelationLvl(cur_lvl)
		self:onRelationLvlChanged(cur_lvl, false)

		print("Sworn ", self:getSwornID(), "now relationLevel=", cur_lvl)
	end
end
function SwornBros:increaseRelation(value, checkMax)
	if checkMax and SWORN_RELATION_DAILY_MAX - self._daily_inc_relation < value then
		value = SWORN_RELATION_DAILY_MAX - self._daily_inc_relation
	end
	if value == 0 then
		return
	end
	self._daily_inc_relation = self._daily_inc_relation + value
	value = self:getRelation() + value
	self:setRelation(value)
	self:incUpdateTimes()
	local cur_lvl = self:getRelationLvl()
	local tbl = g_swornBrosMgr:getRelationData(cur_lvl+1)
	if not tbl then
		return
	end
	local max_relation_lvl = self:getMaxRelationLvl()
	local need_value = tbl.value
	local need_notify = false
	local add_points = 0
	while value >= need_value do
		need_notify = true
		cur_lvl = cur_lvl + 1
		if cur_lvl > max_relation_lvl then
			add_points = tbl.points + add_points
		end
		tbl = g_swornBrosMgr:getRelationData(cur_lvl+1)
		if tbl then
			need_value = tbl.value
		else
			break
		end
	end
	if need_notify then
		if max_relation_lvl < cur_lvl then
			self:setMaxRelationLvl(cur_lvl)
			self:setSkillPoints(self:getSkillPoints() + add_points)
		end
		print("relation level changed!curLevel:",cur_lvl,"cur_value:",value, "addPoints:", add_points)
		self:setRelationLvl(cur_lvl)
		self:onRelationLvlChanged(cur_lvl, true)
	end
end
function SwornBros:forceSaveData()
	self._update_times = 0
	self._need_save = true
	self:saveData()
end
function SwornBros:onRelationLvlChanged(level, up)
	local ret = {relation_lvl = level, upgrade = up}
	self:sendToAll(SWORN_SC_RELATION_LVL_RET, "NotifySwornRelationLvl", ret)
	self:forceSaveData()
end
function SwornBros:setHint(player)

	--print("SwornBros:setHint", player:getSerialID())
	local member = self._members[player:getSerialID()]
	if member then
		member.hint = not member.hint
		self:saveMembers()
	end	
end
function SwornBros:kick(player, targetID)
	if self:getCurNum() > SWORN_BROTHERS_MINNUM then

		print("SwornBros:kick ", player:getSerialID(), targetID)
		if self:removeMember(targetID, SwornActionType.KICK) then
			local ret = {}
			ret.type = SwornActionType.KICK
			ret.target_id = targetID
			ret.leader_id = self:getLeaderID()
			self:sendToAll(SWORN_SC_DO_ACTION_RET, "SwornDoActionRet", ret)
			local target = g_entityMgr:getPlayerBySID(targetID)
			if target then 
				fireProtoMessage(target:getID(), SWORN_SC_DO_ACTION_RET, "SwornDoActionRet", ret)
			end
			self:saveMembers()
		else
			print("kick player:", targetID, " failed!!!")
		end
	else
		return g_swornBrosMgr:dismissSwornBors(self)	
	end
end
function SwornBros:leave(player)
	if self:getCurNum() > SWORN_BROTHERS_MINNUM then
		if self:removeMember(player:getSerialID(), SwornActionType.LEAVE) then
			if self:getLeaderID() == player:getSerialID() then
				self:setRandLeader()
			end
			local ret = {}
			ret.type = SwornActionType.LEAVE
			ret.target_id = player:getSerialID()
			ret.leader_id = self:getLeaderID()
			self:sendToAll(SWORN_SC_DO_ACTION_RET, "SwornDoActionRet", ret)
			fireProtoMessage(player:getID(), SWORN_SC_DO_ACTION_RET, "SwornDoActionRet", ret)
			self:saveMembers()
			return true
		else
			print("player:", player:getSerialID()," leave failed!!!")
			return false
		end
	else
		return g_swornBrosMgr:dismissSwornBors(self, player:getSerialID())
	end
end
function SwornBros:onMemberDelete(sid)
	if self:getCurNum() > SWORN_BROTHERS_MINNUM then
		if self:removeMember(sid, SwornActionType.LEAVE) then
			if self:getLeaderID() == sid then
				self:setRandLeader()
			end
			local ret = {}
			ret.type = SwornActionType.LEAVE
			ret.target_id = sid
			ret.leader_id = self:getLeaderID()
			self:sendToAll(SWORN_SC_DO_ACTION_RET, "SwornDoActionRet", ret)
			self:saveMembers()
			return true
		else
			print("sworn player:", sid," delete failed!!!")
			return false
		end
	else
		return g_swornBrosMgr:dismissSwornBors(self, sid)
	end
end

function SwornBros:setRandLeader()
	for _, member in pairs(self._members) do
		print("choose :",member.sid," as new leader!")
		self:setLeaderID(member.sid)
		return
	end
end

function SwornBros:learnPsvSkill(player, skill_id)

	print(player:getSerialID()," learnPsvSkill:", skill_id)
	if not player or skill_id == 0 then
		return
	end
	local skills = self._skills
	if table.include(skills, skill_id) then
		return doSwornActionRet(player:getID(), SwornBrosErrCode.SKILL_LEARNED)
	end

	local new_skill = g_swornBrosMgr:getPsvSkill(skill_id)
	if not new_skill then
		return doSwornActionRet(player:getID(), SwornBrosErrCode.INVALID_SKILL)
	end
	local points = self:getSkillPoints()
	if points < new_skill.cost then
		return doSwornActionRet(player:getID(), SwornBrosErrCode.NO_SKILL_POINT)
	end

	for _,prev_id in pairs(new_skill.prev) do 	--check prev skills
		if not table.include(skills, prev_id) then
			return doSwornActionRet(player:getID(), SwornBrosErrCode.NO_PREV_SKILL)
		end
	end
	
	table.insert(skills, skill_id)
	self:setSkillPoints(points - new_skill.cost)
	local ret = {}
	ret.type = SwornPsvSkillOpType.LEARN
	ret.skill_id = skill_id
	ret.points = self:getSkillPoints()
	self:sendToAll(SWORN_SC_OPERATE_PSV_SKILLRET, "OperateSwornPsvSkillRet", ret)
	
	self:onSkillLearned(new_skill)
end
function SwornBros:onSkillLearned(skill_data)
	if skill_data.id > SWORN_MAX_ACTIVE_SKILL then	--Passive skills here
		local map_ids = {}
		local function countMapIDs(member)
			local mapID = member:getMapID()
			local tbl = map_ids[mapID]
			if not tbl then
				map_ids[mapID] = {member,}
			else
				table.insert(tbl, member)
			end
		end
		self:execOnlineMembers(countMapIDs)
		for _,v in pairs(map_ids) do
			if #v >= SWORN_RELATION_MIN_BROS then
				for _, member in pairs(v) do
					self:addPsvSkill(member, skill_data)
				end
			end
		end
	else	--Active skills here
		local function addAtvSkill(member)
			local skillMgr = member:getSkillMgr()
			local ret = skillMgr:learnSkill(skill_data.skill_id, 0)
			print("player:",member:getSerialID(),"learn skill",skill_data.skill_id,"result:",ret)
		end

		self:execOnlineMembers(addAtvSkill)
	end
	self:saveSkills()
end

function SwornBros:resetPsvSkill(player)
	print(player:getSerialID()," resetPsvSkill")
	local cost = 0
	local num = 0
	local remove_psv_skills = {}
	local remove_atv_skills = { skillId = {},}
	for k,v in pairs(self._skills) do
		local skill_data = g_swornBrosMgr:getPsvSkill(v)
		if skill_data then
			if skill_data.id <= SWORN_MAX_ACTIVE_SKILL then
				table.insert(remove_atv_skills.skillId, skill_data.skill_id)
			else
				table.insert(remove_psv_skills, skill_data)			
			end
			num = num + 1
			cost = skill_data.cost + cost
			self._skills[k] = nil
		end
	end
	if num == 0 then
		return doSwornActionRet(player:getID(), SwornBrosErrCode.NO_PSV_SKILL)
	end

	for _, players in pairs(self._map_player) do		--remove passive skills
		if #players >= SWORN_RELATION_MIN_BROS then
			for _, id in pairs(players) do

				local player = g_entityMgr:getPlayerBySID(id)
				if player then
					for _, skill_data in pairs(remove_psv_skills) do 
						self:removeSwornSkill(player, skill_data)
					end
				end
			end
		end
	end
	
	print(num.." skills removed, "..cost.." points get!")
	local function removeActiveSkills(member)				--remove active skills
		for _, atv_skill_id in pairs(remove_atv_skills.skillId) do
			local skillMgr = member:getSkillMgr()
			skillMgr:delSkill(atv_skill_id)
		end
		fireProtoMessage(member:getID(), SKILL_SC_DELETESKILL, "SkillDelteProtocol", remove_atv_skills)
	end
	self:execOnlineMembers(removeActiveSkills)
	local points = self:getSkillPoints() + cost
	self:setSkillPoints(points)
	local ret = {}
	ret.type = SwornPsvSkillOpType.RESET
	ret.points = points
	fireProtoMessage(player:getID(), SWORN_SC_OPERATE_PSV_SKILLRET, "OperateSwornPsvSkillRet", ret)
	self:saveSkills()
end
function SwornBros:saveSkills()
	local skill_buf = self:serializeSkills()
	g_entityDao:saveSwornSkills(SPDEF_SAVESWORNSKILLS, self:getSwornID(), self:getSkillPoints(), skill_buf, #skill_buf)
end
function SwornBros:saveMembers()
	local mem_buf = self:serializeMembers()
	g_entityDao:saveSwornMembers(SPDEF_SAVESWORNMEMBERS, self:getSwornID(), self:getLeaderID(), mem_buf, #mem_buf)
end
function SwornBros:saveData()
	if self._need_save then
		g_entityDao:saveSwornData(SPDEF_SAVESWORNDATA, self:getSwornID(), self:getRelation(), self._daily_inc_relation, self._last_update, self:getMaxRelationLvl(), self:getSkillPoints())
		self._need_save = false
	end
end
function SwornBros:sendToAll(protoNum, protoName, data)
	for _, mem in pairs(self._members) do
		local member = g_entityMgr:getPlayerBySID(mem.sid)
		if member then
			fireProtoMessage(member:getID(), protoNum, protoName, data)		
		end
	end
end
function SwornBros:execMembers(func)
	for _, mem in pairs(self._members) do
		if mem then
			func(mem)
		end
	end
end
function SwornBros:execOnlineMembers(func)
	for _, mem in pairs(self._members) do
		local member = g_entityMgr:getPlayerBySID(mem.sid)
		if member then
			func(member)
		end
	end
end
function SwornBros:sendBasicInfoToAll()
	for _, mem in pairs(self._members) do
		local member = g_entityMgr:getPlayerBySID(mem.sid)
		if member then
			self:sendBasicInfo(member)
		end
	end
end
local function transmitToTarget(player, target, type)
	if not player or not target then
		return false
	end
	local tar_pos = target:getPosition()
	local tar_map = target:getMapID()
	if not g_entityMgr:canSendto(player:getID(), tar_map, tar_pos.x, tar_pos.y) then
		print("not canSendto")
		return false
	end

	if g_sceneMgr:posValidate(tar_map, tar_pos.x, tar_pos.y) then
		print("transmitToTarget======posValidate")
		--doSwornActionRet(player:getID(), SwornBrosErrCode.SUCCEED)
		local old_pos = player:getPosition()
		player:setLastMapID(player:getMapID())
		player:setLastPosX(old_pos.x)
		player:setLastPosY(old_pos.y)
		g_sceneMgr:enterPublicScene(player:getID(), tar_map, tar_pos.x, tar_pos.y)
		return true
	else
		return false
	end
end
function SwornBros:reqAtvSkillInfo(player)
	local retData = {bros = {},}
	local function fillBrosInfo(mem)
		local info = {}
		info.sid = mem.sid
		info.name = mem.name
		local member = g_entityMgr:getPlayerBySID(mem.sid)
		if member then
			info.map = member:getMapID()
			local pos = member:getPosition()
			info.x = pos.x
			info.y = pos.y
		else
			info.map = 0
		end
		table.insert(retData.bros, info)
	end
	self:execMembers(fillBrosInfo)
	fireProtoMessage(player:getID(), SWORN_SC_ATV_SKILL_INFO_RET, "SwornAtvSkillInfoRet", retData)
end

function SwornBros:operateAtvSkill(player, req_type, target_id)
	print("player:"..player:getSerialID().." use skill:"..req_type..",target:"..target_id or 0)
	local skillMgr = player:getSkillMgr()
	if req_type == SwornAtvOperateType.Transmit then
		if self:transmitTo(player, target_id) == true then
			skillMgr:beginCooling(SwornActiveSkill.TRANS_ID)
		else
			skillMgr:clearCool(SwornActiveSkill.TRANS_ID)
		end
	elseif req_type == SwornAtvOperateType.ReqGather then
		if self:reqGather(player) == true then
			skillMgr:beginCooling(SwornActiveSkill.GATHER_ID)
		else
			skillMgr:clearCool(SwornActiveSkill.GATHER_ID)
		end
	elseif req_type == SwornAtvOperateType.AgreeGather then
		self:agreeGather(player, target_id)
	else
		print("wrong type in operateAtvSkill:".. req_type)
	end
end

function SwornBros:transmitTo(player, target_id)
	local _, target = self:getMember(target_id)
	print("Player:",player:getSerialID()," transmitTo:", target_id)
	if not target then
		doSwornActionRet(player:getID(), SwornBrosErrCode.CANT_TRANSMIT)
		return false
	end
	if player:getSerialID() == target_id then
		doSwornActionRet(player:getID(), SwornBrosErrCode.CANT_TRANSMIT)
		return false
	end
	if transmitToTarget(player, target, SwornAtvOperateType.Transmit) == false then
		--doSwornActionRet(player:getID(), SwornBrosErrCode.CANT_TRANSMIT)
		return false
	end
	return true
end

function SwornBros:reqGather(player)
	local ret = {}
	ret.sid = player:getSerialID()
	ret.name = player:getName()
	ret.map = player:getMapID()
	print("player:",ret.name,"req gather to map:", ret.map)
	self:sendToAll(SWORN_SC_SKILL_GATHER_BRO, "SwornSkillGatherBro", ret)
	return true
end

function SwornBros:agreeGather(player, target_id)
	local _,target = self:getMember(target_id)
	if not target then
		return doSwornActionRet(player:getID(), SwornBrosErrCode.INVALID_GATHER)
	end
	
	if transmitToTarget(player, target, SwornAtvOperateType.AgreeGather) == false then
		--return doSwornActionRet(player:getID(), SwornBrosErrCode.CANT_TRANSMIT)
	end
end
function SwornBros:addAllPsvSkills(player)

	print("Player:",player:getSerialID()," addAllPsvSkills!!!")
	for _,id in pairs(self._skills) do
		if id > SWORN_MAX_ACTIVE_SKILL then	 --passive skills
			local skill_data = g_swornBrosMgr:getPsvSkill(id)
			self:addPsvSkill(player, skill_data)
		end
	end
end
function SwornBros:removeAllPsvSkills(player)

	print("Player:",player:getSerialID()," removeAllPsvSkills!!!")
	for _,id in pairs(self._skills) do
		if id > SWORN_MAX_ACTIVE_SKILL then		--passive skills
			local skill_data = g_swornBrosMgr:getPsvSkill(id)
			self:removeSwornSkill(player, skill_data)
		end
	end
end
function SwornBros:addPsvSkill(player, skill_data)

	player:setMinDF(player:getMinDF() + skill_data.def_min)
	player:setMaxDF(player:getMaxDF() + skill_data.def_max)
	player:setTenacity(player:getTenacity() + skill_data.tenacity)
	player:setMinAT(player:getMinAT() + skill_data.att_min)
	player:setMaxAT(player:getMaxAT() + skill_data.att_max)
	player:setMinDT(player:getMinDT() + skill_data.dc_att_min)
	player:setMaxDT(player:getMaxDT() + skill_data.dc_att_max)
	player:setMinMT(player:getMinMT() + skill_data.mag_att_min)
	player:setMaxMT(player:getMaxMT() + skill_data.mag_att_max) 
	player:setMinMF(player:getMinMF() + skill_data.mag_def_min)
	player:setMaxMF(player:getMaxMF() + skill_data.mag_def_max)
	player:setHit(player:getHit() + skill_data.hit)
	player:setDodge(player:getDodge() + skill_data.dodge)
	player:setCrit(player:getCrit() + skill_data.crit)
end

function SwornBros:ensurePositive(origin, subtract)
	if origin > subtract then
		return origin - subtract
	end
	return 0
end

function SwornBros:removeSwornSkill(player, skill_data)
	print("removeSwornSkill:", skill_data.id)
	if skill_data.id <= SWORN_MAX_ACTIVE_SKILL then	--active skills
		local skillMgr = player:getSkillMgr()
		skillMgr:delSkill(skill_data.skill_id)
		print("player:",player:getSerialID(),"del skill:",skill_data.skill_id)
	else	-- passive skills
		player:setMinDF(self:ensurePositive(player:getMinDF(), skill_data.def_min))
		player:setMaxDF(self:ensurePositive(player:getMaxDF(), skill_data.def_max))
		player:setTenacity(self:ensurePositive(player:getTenacity(), skill_data.tenacity))
		player:setMinAT(self:ensurePositive(player:getMinAT(), skill_data.att_min))
		player:setMaxAT(self:ensurePositive(player:getMaxAT(), skill_data.att_max))
		player:setMinDT(self:ensurePositive(player:getMinDT(), skill_data.dc_att_min))
		player:setMaxDT(self:ensurePositive(player:getMaxDT(), skill_data.dc_att_max))
		player:setMinMT(self:ensurePositive(player:getMinMT(), skill_data.mag_att_min))
		player:setMaxMT(self:ensurePositive(player:getMaxMT(), skill_data.mag_att_max))
		player:setMinMF(self:ensurePositive(player:getMinMF(), skill_data.mag_def_min))
		player:setMaxMF(self:ensurePositive(player:getMaxMF(), skill_data.mag_def_max))
		player:setHit(self:ensurePositive(player:getHit(), skill_data.hit))
		player:setDodge(self:ensurePositive(player:getDodge(), skill_data.dodge))
		player:setCrit(self:ensurePositive(player:getCrit(), skill_data.crit))
	end
end
function SwornBros:checkActiveSkills(player)
	local retData = {skillId = {},}
	for i = 1, SWORN_MAX_ACTIVE_SKILL do
		local skill_data = g_swornBrosMgr:getPsvSkill(i)
		if skill_data then
			local skillMgr = player:getSkillMgr()
			if table.include(self._skills, i) then	-- swornbros has skill i
				local ret = skillMgr:learnSkill(skill_data.skill_id, 0)
				print("player:",player:getSerialID(),"learn skill",skill_data.skill_id,"result:",ret)
			else	-- swornbros has no skill i
				local ret = skillMgr:delSkill(skill_data.skill_id)
				if ret == true then
					table.insert(retData.skillId, skill_data.skill_id)
				end
			end
		end
	end
	if table.len(retData.skillId) > 0 then
		fireProtoMessage(player:getID(), SKILL_SC_DELETESKILL, "SkillDelteProtocol", retData)
	end
end

function SwornBros:getAllPsvSkillsProp()
	local ret = {}
	for _,id in pairs(self._skills) do
		if id > SWORN_MAX_ACTIVE_SKILL then	 --passive skills
			local skill_data = g_swornBrosMgr:getPsvSkill(id)
			if skill_data then
				ret[ROLE_MIN_DF] = (ret[ROLE_MIN_DF] or 0) + (skill_data.def_min or 0)
				ret[ROLE_MAX_DF] = (ret[ROLE_MAX_DF] or 0) + (skill_data.def_max or 0)
				ret[ROLE_MIN_AT] = (ret[ROLE_MIN_AT] or 0) + (skill_data.att_min or 0)
				ret[ROLE_MAX_AT] = (ret[ROLE_MAX_AT] or 0) + (skill_data.att_max or 0)
				ret[ROLE_MIN_DT] = (ret[ROLE_MIN_DT] or 0) + (skill_data.dc_att_min or 0)
				ret[ROLE_MAX_DT] = (ret[ROLE_MAX_DT] or 0) + (skill_data.dc_att_max or 0)
				ret[ROLE_MIN_MT] = (ret[ROLE_MIN_MT] or 0) + (skill_data.mag_att_min or 0)
				ret[ROLE_MAX_MT] = (ret[ROLE_MAX_MT] or 0) + (skill_data.mag_att_max or 0)
				ret[ROLE_MIN_MF] = (ret[ROLE_MIN_MF] or 0) + (skill_data.mag_def_min or 0)
				ret[ROLE_MAX_MF] = (ret[ROLE_MAX_MF] or 0) + (skill_data.mag_def_max or 0)
				ret[ROLE_HIT] = (ret[ROLE_HIT] or 0) + (skill_data.hit or 0)
				ret[ROLE_DODGE] = (ret[ROLE_DODGE] or 0) + (skill_data.dodge or 0)
				ret[ROLE_CRIT] = (ret[ROLE_CRIT] or 0) + (skill_data.crit or 0)
				ret[ROLE_TENACITY] = (ret[ROLE_TENACITY] or 0) + (skill_data.tenacity or 0)
			end
		end
	end
	return ret
end

function SwornBros:onPlayerOnline(player, online)

	--print(player:getSerialID(),"onPlayerOnline to others:", online)
	local ret = {}
	ret.sid = player:getSerialID()
	ret.online = online
	local function hintBro(member)
		if member:getID() ~= player:getID() then
			local memInfo = self:getMember(member:getSerialID())
			if memInfo and memInfo.hint then
				fireProtoMessage(member:getID(), SWORN_SC_BRO_ONLINE_STATUS, "SwornBroOnlieStatus", ret)
			end
		end
	end
	self:execOnlineMembers(hintBro)
	
	if online then
		self._online_num = self._online_num + 1
		self:onPlayerSwitchScene(player, player:getMapID())		
	else
		self._online_num = self._online_num - 1
		self:onPlayerOutScene(player, player:getMapID())
	end
	
	if self._online_num >= SWORN_RELATION_MIN_BROS then
		if self:getTimerStatus() == SwornTimerStatus.INVALID then
			gTimerMgr:regTimer(self, SWORN_TIMER_PERIOD, SWORN_TIMER_PERIOD)
			self:setTimerStatus(SwornTimerStatus.RUNNING)
		end
	elseif self:getTimerStatus() == SwornTimerStatus.RUNNING then
		gTimerMgr:unregTimer(self)
		self:setTimerStatus(SwornTimerStatus.INVALID)
	end
end
function SwornBros:onPlayerOutScene(player, mapID)
	print("onPlayerOutScene ", player:getSerialID(), mapID)
	if not mapID then
		return
	end
	local map_ids = self._map_player[mapID]
	if map_ids then		--the map player left
		local num = 0	--the number of players after player left

		for k,sid in pairs(map_ids) do
			if player:getSerialID() == sid then
				map_ids[k] = nil
			else
				num = num + 1
			end
		end
		if num >= SWORN_RELATION_MIN_BROS then
			self:removeAllPsvSkills(player)
		elseif num == SWORN_RELATION_MIN_BROS - 1 then	--all need remove passive skills

			for _,sid in pairs(map_ids) do
				local pl = g_entityMgr:getPlayerBySID(sid)
				if pl then
					self:removeAllPsvSkills(pl)
				end
			end
			self:removeAllPsvSkills(player)
		end

		if num == 0 then
			self._map_player[mapID] = nil
		end
	end
end

function SwornBros:onPlayerSwitchScene(player, mapID, lastMapID)

	print("onPlayerSwitchScene player:", player:getSerialID(), ", mapID:", mapID, "lastMapID:", lastMapID)
	self:onPlayerOutScene(player, lastMapID)
	
	local map_ids = self._map_player[mapID]
	if map_ids then-- there are players on this map

		table.insert(map_ids, player:getSerialID())
		local cur_num = table.size(map_ids)
		if cur_num > SWORN_RELATION_MIN_BROS then
			self:addAllPsvSkills(player)
		elseif cur_num == SWORN_RELATION_MIN_BROS then

			for _,sid in pairs(map_ids) do
				local p = g_entityMgr:getPlayerBySID(sid)
				if p then
					self:addAllPsvSkills(p)
				end
			end
		end
	else

		local new_map = {player:getSerialID(),}
		self._map_player[mapID] = new_map
		if SWORN_RELATION_MIN_BROS <= 1 then
			self:addAllPsvSkills(player)			
		end
	end
end

function SwornBros:onPlayerLevelChanged(player)
	local info = self._members[player:getSerialID()]
	if info then
		info.level = player:getLevel()
		self:saveMembers()
	end
end
function SwornBros:printAllData()

	print("=============Print data for SwornBros: "..self:getSwornID().."=============")
	print(string.format("relation:%d, level:%d, maxLevel:%d, points:%d, dailyInc:%d, online_num:%d, timerStatus:%d", 
		  self:getRelation(), self:getRelationLvl(), self:getMaxRelationLvl(), self:getSkillPoints(), 
		  self._daily_inc_relation, self._online_num, self:getTimerStatus()))
	print(self._cur_num," cur members:")
	for _,v in pairs(self._members) do
		print(string.format("name:%s, sid:%d, level:%d", v.name, v.sid, v.level))	
	end
	print("Players in map:")
	for k,v in pairs(self._map_player) do

		local tmp_str = "map[" .. k .. "] = {"
		for _,id in pairs(v) do

			tmp_str = tmp_str .. id .. ","
		end
		tmp_str = tmp_str .. "}"
		print(tmp_str)
	end
	print("===================================")
end
