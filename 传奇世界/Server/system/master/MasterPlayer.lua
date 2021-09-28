--MasterPlayer.lua
--/*-----------------------------------------------------------------
 --* Module:  MasterPlayer.lua
 --* Author:  Andy
 --* Modified: 2016年02月16日
 --* Purpose: Implementation of the class MasterPlayer
 -------------------------------------------------------------------*/
require ("base.class")
MasterPlayer = class()

local prop = Property(MasterPlayer)
prop:accessor("roleSID")
prop:accessor("name", "")
prop:accessor("school")
prop:accessor("level", 1)
prop:accessor("apprenticeCD", 0)		--徒弟惩罚CD开始时间戳,0为没有处罚CD
prop:accessor("masterCD", 0)			--师傅惩罚CD开始时间戳,0为没有处罚CD
prop:accessor("masterSID", "")			--师傅的静态ID,""为未拜师
prop:accessor("initiative", true)		--允许主动拜师
prop:accessor("nowProfession")			--当前的师徒类型(1、师傅 2、徒弟 3、都不是 4、可出师)
prop:accessor("totalApprentice", 0)		--收徒总数
prop:accessor("totalExpel", 0)			--驱逐出去的弟子总数
prop:accessor("totalFlower", 0)			--收到徒弟送花总数
prop:accessor("totalFinish", 0)			--成功出师的弟子总数
prop:accessor("totalBetray", 0)			--背叛师门的弟子总数
prop:accessor("finalMaster", 0)			--最终的师傅
prop:accessor("finalName", "")			--最终的师傅名称
prop:accessor("finishTime", 0)			--出师时间

prop:accessor("loadDB", false)

function MasterPlayer:__init(roleSID, name, school, level)
	prop(self, "roleSID", roleSID)
	prop(self, "name", name)
	prop(self, "school", school)
	prop(self, "level", level)
	prop(self, "nowProfession", MASTER_PROFESSION.NOTHING)

	self._applyMasterList = {}			--申请的师傅列表(自己申请的师傅)
	self._applyApprenticeList = {}		--申请的徒弟列表(别人申请自己做师傅)
	self._apprentice = {}				--徒弟列表

	self._refuseList = {}				--拜师被拒绝的师傅ID,用于申请冷却提示
	self._refuseList2 = {}				--收徒被拒绝的徒弟ID,用于申请冷却提示
	self._masterRep = {}				--发起收徒的师傅列表
	self._apprenticeReq = {}			--发起拜师的徒弟列表
end

--徒弟自己出师
function MasterPlayer:apprenticeFinish()
	g_masterMgr:setDoubleXP(self:getRoleSID(), 0)
	self:setNowProfession(MASTER_PROFESSION.MASTER)
	self:setMasterSID("")
	self:setFinishTime(os.time())
	self._applyMasterList = {}
	self:setApprenticeCD(0)
	self:cast2DB()
end

--获取徒弟数据
function MasterPlayer:getApprentice()
	return self._apprentice or {}
end

--获取徒弟数量
function MasterPlayer:getApprenticeCount()
	return table.size(self._apprentice)
end

--增加徒弟
function MasterPlayer:addApprentice(apprenticeSID)
	if not table.contains(self._apprentice, apprenticeSID) then
		table.insert(self._apprentice, apprenticeSID)
		self:deleteApplyApprentice(apprenticeSID)
		self:cast2DB()
		if self:getApprenticeCount() >= APPRENTICE_MAX_COUNT then
			g_masterMgr:releaseMasterUser(self:getRoleSID())
		end
	end
end

--删除徒弟
function MasterPlayer:deleteApperntice(apprenticeSID)
	if table.contains(self._apprentice, apprenticeSID) then
		table.removeValue(self._apprentice, apprenticeSID)
		self:cast2DB()
		self:canBecomeMaster()
	end
end

--获取申请的师傅数据
function MasterPlayer:getApplyMasterList()
	return self._applyMasterList
end

--根据ID获取申请的师傅数据
function MasterPlayer:getApplyMaster(masterSID)
	return self._applyMasterList[masterSID]
end

--增加申请的师傅
function MasterPlayer:addApplyMaster(masterSID, name, school, level)
	local master = {}
	master.roleSID = masterSID
	master.name = name
	master.school = school
	master.level = level
	self._applyMasterList[masterSID] = master
	self:cast2DB()
end

--删除申请的师傅
function MasterPlayer:deleteApplyMaster(masterSID)
	self._applyMasterList[masterSID] = nil
	self:cast2DB()
end

function MasterPlayer:getApprenticeApplyCount()
	return table.size(self._applyApprenticeList)
end

--获取申请的徒弟数据
function MasterPlayer:getApplyApprenticeList()
	return self._applyApprenticeList
end

--根据ID获取申请的徒弟数据
function MasterPlayer:getApplyApprentice(apprenticeSID)
	return self._applyApprenticeList[apprenticeSID]
end

--增加申请的徒弟
function MasterPlayer:addApplyApprentice(roleSID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		local apprentice = {}
		apprentice.roleSID = roleSID
		apprentice.name = player:getName()
		apprentice.school = player:getSchool()
		apprentice.level = player:getLevel()
		self._applyApprenticeList[apprentice.roleSID] = apprentice
		self:cast2DB()
	end
end

--增加申请的徒弟(离线增加的)
function MasterPlayer:addApplyApprenticeOffLine(roleSID, name, school, level)
	local apprentice = {}
	apprentice.roleSID = roleSID
	apprentice.name = name
	apprentice.school = school
	apprentice.level = level
	self._applyApprenticeList[apprentice.roleSID] = apprentice
	self:cast2DB()
end

--删除申请的徒弟
function MasterPlayer:deleteApplyApprentice(apprenticeSID)
	self._applyApprenticeList[apprenticeSID] = nil
	self:cast2DB()
end

--增加拒绝拜师的师傅拒绝时间
function MasterPlayer:addRefuseList(masterSID)
	self._refuseList[masterSID] = os.time()
end

--获取师傅的拒绝时间
function MasterPlayer:getRefuseTime(masterSID)
	return self._refuseList[masterSID] or 0
end

--增加拒绝收徒的徒弟拒绝时间
function MasterPlayer:addRefuseList2(apprenticeSID)
	self._refuseList2[apprenticeSID] = os.time()
end

--获取徒弟的拒绝时间
function MasterPlayer:getRefuseTime2(apprenticeSID)
	return self._refuseList2[apprenticeSID] or 0
end

--增加向自己发起收徒的师傅
function MasterPlayer:addMasterRep(masterSID)
	if not table.contains(self._masterRep, masterSID) then
		table.insert(self._masterRep, masterSID)
	end
end

--是否向自己发起过收徒的师傅
function MasterPlayer:isMasterReqUser(masterSID)
	return table.contains(self._masterRep, masterSID)
end

--增加向自己发起拜师的徒弟
function MasterPlayer:addApprenticeRep(apprenticeSID)
	if not table.contains(self._apprenticeReq, apprenticeSID) then
		table.insert(self._apprenticeReq, apprenticeSID)
	end
end

--是否向自己发起过拜师的徒弟
function MasterPlayer:isApprenticeReqUser(apprenticeSID)
	return table.contains(self._apprenticeReq, apprenticeSID)
end

--是否可以做师傅,符合师傅条件的加到师傅推荐列表
function MasterPlayer:canBecomeMaster()
	local cdTime = self:getMasterCD() 
	if cdTime ~= 0 and os.time() - cdTime <= MASTER_PUNISH_CD or self:getApprenticeCount() >= APPRENTICE_MAX_COUNT or
	self:getLevel() < MASTER_MIN_LEVEL or not self:getInitiative() or self:getApprenticeApplyCount() > MASTER_APPLY_MAX_COUNT then
		return
	else
		local master = {}
		master.roleSID = self:getRoleSID()
		master.name = self:getName()
		master.school = self:getSchool()
		master.level = self:getLevel()
		g_masterMgr:addMasterUser(master.roleSID, master)
	end
end

function MasterPlayer:loadDBData(dbstr, isDelete)
	self:setLoadDB(true)
	if #dbstr > 0 then
		local dbData, errCode = protobuf.decode("MasterProtocol", dbstr)
		if type(dbData) ~= "table" then
			return
		end
		self:setApprenticeCD(dbData.CD1)
		self:setMasterCD(dbData.CD2)
		self:setMasterSID(dbData.SID)
		self:setInitiative(dbData.initiative)
		self:setNowProfession(dbData.now)
		self:setTotalApprentice(dbData.count)
		self:setTotalBetray(dbData.betray)
		self:setTotalExpel(dbData.expel)
		self:setTotalFlower(dbData.flower)
		self:setTotalFinish(dbData.finish)
		self:setFinalMaster(dbData.master)
		self:setFinalName(dbData.name)
		self:setFinishTime(dbData.time)
		self:setName(dbData.selfName)
		for _, master in pairs(dbData.t1) do
			self._applyMasterList[master.roleSID] = {roleSID = master.roleSID, name = master.name, school = master.school, level = master.level}
			g_masterMgr:loadOffLineDBData(master.roleSID, self:getRoleSID())
		end
		for _, apprentice in pairs(dbData.t2) do
			self._applyApprenticeList[apprentice.roleSID] = {roleSID = apprentice.roleSID, name = apprentice.name, school = apprentice.school, level = apprentice.level}
		end
		self._apprentice = unserialize(dbData.t3) or {}

		--创建玩家相关的师徒的离线数据
		g_masterMgr:loadOffLineDBData(self:getRoleSID(), self:getRoleSID(), true)
		local masterSID = self:getMasterSID()
		if #masterSID > 0 then
			g_masterMgr:loadOffLineDBData(masterSID, self:getRoleSID())
			if not isDelete and self:getNowProfession() == MASTER_PROFESSION.APPRENTICE then
				g_masterMgr:setDoubleXP(self:getRoleSID(), masterSID)
			end
		end
		local apprentices = self:getApprentice()
		for i = 1, #apprentices do
			local apprenticeSID = apprentices[i]
			g_masterMgr:loadOffLineDBData(apprenticeSID, self:getRoleSID())
			if not isDelete then
				--给徒弟提示上线信息
				local apprenticeInfo = g_masterMgr:getPlayerInfoBySID2(apprenticeSID)
				if apprenticeInfo and apprenticeInfo:getNowProfession() == MASTER_PROFESSION.APPRENTICE then
					g_masterMgr:sendErrMsg2Client(apprenticeSID, MASTER_ERR_MASTER_ONLINE, 0, {})
					g_masterMgr:setDoubleXP(apprenticeSID, self:getRoleSID())
				end
			end
		end
		for apprenticeSID, _ in pairs(self:getApplyApprenticeList() or {}) do
			g_masterMgr:loadOffLineDBData(apprenticeSID, self:getRoleSID())
		end
		if self:getApprenticeCount() >= APPRENTICE_MAX_COUNT then
			for apprenticeSID, _ in pairs(self:getApplyApprenticeList() or {}) do
				g_masterSer:masterDeleteApply(self:getRoleSID(), apprenticeSID)
			end
		end
		local player = g_entityMgr:getPlayerBySID(self:getRoleSID())
		if player then
			self:setName(player:getName())
			self:setSchool(player:getSchool())
			self:setLevel(player:getLevel())
		end
		if not isDelete then
			self:canBecomeMaster()
		end
	end
end

--重要数据及时存数据库
function MasterPlayer:cast2DB()
	if not self:getLoadDB() then
		return
	end
	local t1, t2 = {}, {}
	for _, master in pairs(self._applyMasterList) do
		table.insert(t1, {roleSID = master.roleSID, name = master.name,	school = master.school,	level = master.level})
	end
	for _, apprentice in pairs(self._applyApprenticeList) do
		table.insert(t2, {roleSID = apprentice.roleSID,	name = apprentice.name,	school = apprentice.school,	level = apprentice.level})
	end
	local dbData = {
		CD1 = self:getApprenticeCD(),
		CD2 = self:getMasterCD(),
		SID = self:getMasterSID(),
		initiative = self:getInitiative(),
		now = self:getNowProfession(),
		count = self:getTotalApprentice(),
		betray = self:getTotalBetray(),
		expel = self:getTotalExpel(),
		flower = self:getTotalFlower(),
		finish = self:getTotalFinish(),
		master = self:getFinalMaster(),
		name = self:getFinalName(),
		time = self:getFinishTime(),
		selfName = self:getName(),
		t1 = t1,
		t2 = t2,
		t3 = serialize(self._apprentice),
	}
	local cache_buff = protobuf.encode("MasterProtocol", dbData)
	g_engine:savePlayerCache(self:getRoleSID(), FIELD_MASTER, cache_buff, #cache_buff)
end