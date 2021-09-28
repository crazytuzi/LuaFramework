--MasterOffLine.lua
--/*-----------------------------------------------------------------
 --* Module:  MasterOffLine.lua
 --* Author:  Andy
 --* Modified: 2016年02月16日
 --* Purpose: 师徒关系中离线玩家数据结构,放公共服供其关系用户查找与修改
 -------------------------------------------------------------------*/
require ("base.class")
MasterOffLine = class()

local prop = Property(MasterOffLine)
prop:accessor("roleSID")
prop:accessor("name")
prop:accessor("school")
prop:accessor("level")
prop:accessor("battle")
prop:accessor("offLine", 0)			--下线时间
prop:accessor("word", "")			--师尊教诲
prop:accessor("expel", false)		--是否被师傅驱逐
prop:accessor("flower", 0)			--离线期间徒弟送花的数量
prop:accessor("taskIssue", false)	--任务是否已发布
prop:accessor("taskIssueTime", 0)	--任务发布的时间
prop:accessor("taskProgress", 0)	--任务完成进度
prop:accessor("taskFinish", false)	--任务是否已完成
prop:accessor("taskFinishTime", 0)	--任务完成的时间
prop:accessor("taskRewardTime", 0)	--任务奖励领取时间
prop:accessor("taskRewardCount", 0)	--任务领奖的次数(师傅)
prop:accessor("taskID", 0)			--任务ID(完成时记录,领奖则获取此档任务的奖励)

prop:accessor("updateDB", false)
prop:accessor("offLineUpdateDB", false)

function MasterOffLine:__init(roleSID, name, school, level, battle)
	prop(self, "roleSID", roleSID)
	prop(self, "name", name)
	prop(self, "school", school)
	prop(self, "level", level)
	prop(self, "battle", battle)

	------- 作为师傅的数据 -------
	self._applyApprenticeList = {}		--新增申请的徒弟列表
	self._removeApplyApprentice = {}	--删除申请的徒弟列表ID
	self._removeApprentice = {}			--叛师的徒弟列表ID
	------- 作为徒弟的数据 -------
	self._removeApplyMaster = {}		--拒绝申请的师傅ID

	self._experience = {}				--离线期间经历改变数据

	self._relatedUser = {}				--此离线数据关联的玩家ID,当关联玩家为0时释放此离线数据
end

function MasterOffLine:getApplyApprenticeList()
	return self._applyApprenticeList
end

function MasterOffLine:addApplyApprentice(roleSID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		local apprentice = {}
		apprentice.roleSID = roleSID
		apprentice.name = player:getName()
		apprentice.school = player:getSchool()
		apprentice.level = player:getLevel()
		self._applyApprenticeList[roleSID] = apprentice
		self:setUpdateDB(true)
	end
end

function MasterOffLine:addRemoveApplyApprentice(apprenticeSID)
	if not table.include(self._removeApplyApprentice, apprenticeSID) then
		table.insert(self._removeApplyApprentice, apprenticeSID)
		self:setUpdateDB(true)
	end
end

function MasterOffLine:getRemoveApplyApprentice()
	return self._removeApplyApprentice
end

function MasterOffLine:addRemoveApplyMaster(masterSID)
	if not table.include(self._removeApplyMaster, masterSID) then
		table.insert(self._removeApplyMaster, masterSID)
		self:setUpdateDB(true)
	end
end

function MasterOffLine:getRemoveApplyMaster()
	return self._removeApplyMaster
end

function MasterOffLine:addRemoveApprentice(apprenticeSID)
	if not table.include(self._removeApprentice, apprenticeSID) then
		table.insert(self._removeApprentice, apprenticeSID)
		self:castOffLine2DB()
	end
end

function MasterOffLine:getRemoveApprentice()
	return self._removeApprentice
end

--添加离线经历数据
function MasterOffLine:addExperience(flag, time, name)
	local experience = {
		flag = flag,
		time = time,
		name = name,
	}
	table.insert(self._experience, experience)
	self:setUpdateDB(true)
end

--获取离线经历数据
function MasterOffLine:getExperience()
	return self._experience
end

--增加关联的玩家
function MasterOffLine:addRelatedUser(roleSID)
	if not table.contains(self._relatedUser, roleSID) then
		table.insert(self._relatedUser, roleSID)
	end
end

--删除关联的玩家
function MasterOffLine:removeRelatedUser(roleSID)
	table.removeValue(self._relatedUser, roleSID)
end

--获取关联玩家的人数
function MasterOffLine:getRelatedUserCount()
	return table.size(self._relatedUser)
end

--是否有可以完成的师徒任务
function MasterOffLine:haveTask()
	local playerInfo = g_masterMgr:getPlayerInfoBySID2(self:getRoleSID())
	if playerInfo and playerInfo:getNowProfession() == MASTER_PROFESSION.APPRENTICE then
		local masterSID = playerInfo:getMasterSID()
		local masterOffLineInfo = g_masterMgr:getOffLineInfo(masterSID)
		if masterOffLineInfo then
			return masterOffLineInfo:getTaskIssue() and not self:getTaskFinish()
		end
	end
	return false
end

--重置师徒任务状态
function MasterOffLine:resetTaskState()
	local timeTick = time.toedition("day")
	if self:getTaskIssueTime() ~= timeTick then
		self:setTaskIssue(false)
	end
	if self:getTaskFinishTime() ~= timeTick then
		self:setTaskProgress(0)
		self:setTaskFinish(false)
	end
end

--玩家上线处理离线期间自己师徒数据的改变
function MasterOffLine:dealOffLineData()
	local playerInfo = g_masterMgr:getPlayerInfoBySID(self:getRoleSID())
	if playerInfo then
		local flag = false		--是否有数据改变需要重新存库
		if self:getExpel() and playerInfo:getNowProfession() == MASTER_PROFESSION.APPRENTICE then
			g_masterMgr:setDoubleXP(self:getRoleSID(), 0)
			playerInfo:setMasterSID("")
			playerInfo:setNowProfession(MASTER_PROFESSION.NOTHING)
			self:setExpel(false)
			flag = true
			g_masterMgr:sendErrMsg2Client(self:getRoleSID(), MASTER_ERR_MASTER_EXPEL, 0, {})
		end
		if self:getFlower() > 0 then
			playerInfo:setTotalFlower(playerInfo:getTotalFlower() + self:getFlower())
			flag = true
		end
		if table.size(self._applyApprenticeList) > 0 then
			for _, apprentice in pairs(self._applyApprenticeList or {}) do
				playerInfo:addApplyApprenticeOffLine(apprentice.roleSID, apprentice.name, apprentice.school, apprentice.level)
			end
			flag = true
		end
		if table.size(self._removeApplyApprentice) > 0 then
			for i = 1, table.size(self._removeApplyApprentice) do
				playerInfo:deleteApplyApprentice(self._removeApplyApprentice[i])
			end
			flag = true
		end
		if table.size(self._removeApplyMaster) > 0 then
			for i = 1, table.size(self._removeApplyMaster) do
				playerInfo:deleteApplyMaster(self._removeApplyMaster[i])
			end
			flag = true
		end
		if table.size(self._removeApprentice) > 0 then
			for i = 1, table.size(self._removeApprentice) do
				playerInfo:deleteApperntice(self._removeApprentice[i])
			end
			flag = true
		end
		if table.size(self._experience) > 0 then
			for i = 1, table.size(self._experience) do
				local experience = self._experience[i]
				g_masterMgr:pushExperience(self:getRoleSID(), experience.flag, experience.time, experience.name)
			end
			flag = true
		end
		self._applyApprenticeList = {}
		self._removeApplyApprentice = {}
		self._removeApplyMaster = {}
		self._removeApprentice = {}
		self._experience = {}
		if flag then
			playerInfo:cast2DB(true)
			self:setUpdateDB(true)
		end
	end
end

function MasterOffLine:castOffLine2DB2()
	if self:getUpdateDB() then
		self:castOffLine2DB()
	end
end

--师徒离线数据直接存库
function MasterOffLine:castOffLine2DB()
	self:setUpdateDB(false)
	local t1 = {}
	for _, apprentice in pairs(self._applyApprenticeList) do
		table.insert(t1, {roleSID = apprentice.roleSID, name = apprentice.name,	school = apprentice.school,	level = apprentice.level})
	end
	local dbData = {
		name = self:getName(),
		school = self:getSchool(),
		level = self:getLevel(),
		battle = self:getBattle(),
		word = self:getWord(),
		expel = self:getExpel(),
		out = self:getOffLine(),
		flower = self:getFlower(),
		t1 = t1,
		t2 = serialize(self._removeApplyApprentice),
		t3 = serialize(self._removeApplyMaster),
		t4 = serialize(self._removeApprentice),
		t5 = serialize(self._experience),
		taskIssue = self:getTaskIssue(),
		taskIssueTime = self:getTaskIssueTime(),
		taskProgress = self:getTaskProgress(),
		taskFinish = self:getTaskFinish(),
		taskFinishTime = self:getTaskFinishTime(),
		taskRewardTime = self:getTaskRewardTime(),
		taskRewardCount = self:getTaskRewardCount(),
	}
	local cache_buff = protobuf.encode("MasterProtocol2", dbData)
	if type(cache_buff) == "string" then
		g_entityDao:updateOffMaster(self:getRoleSID(), cache_buff, #cache_buff)
	end
end

--从库中加载师徒离线数据
function MasterOffLine:loadOffLineDBData(dbStr)
	if #dbStr > 0 then
		local dbData, errCode = protobuf.decode("MasterProtocol2", dbStr)
		if type(dbData) ~= "table" then
			return
		end
		self:setName(dbData.name)
		self:setSchool(dbData.school)
		self:setLevel(dbData.level)
		self:setBattle(dbData.battle)
		self:setWord(dbData.word)
		self:setExpel(dbData.expel)
		self:setOffLine(dbData.out)
		self:setFlower(dbData.flower)
		for _, apprentice in pairs(dbData.t1) do
			self._applyApprenticeList[apprentice.roleSID] = {roleSID = apprentice.roleSID, name = apprentice.name, school = apprentice.school, level = apprentice.level}
		end
		self._removeApplyApprentice = unserialize(dbData.t2) or {}
		self._removeApplyMaster = unserialize(dbData.t3) or {}
		self._removeApprentice = unserialize(dbData.t4) or {}
		self._experience = unserialize(dbData.t5) or {}
		self:setTaskIssue(dbData.taskIssue)
		self:setTaskIssueTime(dbData.taskIssueTime)
		self:setTaskProgress(dbData.taskProgress)
		self:setTaskFinish(dbData.taskFinish)
		self:setTaskFinishTime(dbData.taskFinishTime)
		self:setTaskRewardTime(dbData.taskRewardTime)
		self:setTaskRewardCount(dbData.taskRewardCount)

		self:dealOffLineData()
		self:resetTaskState()
	end
end