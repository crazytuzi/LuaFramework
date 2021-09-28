--RoleRelationInfo.lua
--/*-----------------------------------------------------------------
 --* Module:  RoleRelationInfo.lua
 --* Author:  seezon
 --* Modified: 2014年4月21日
 --* Purpose: Implementation of the class RoleRelationInfo
 -------------------------------------------------------------------*/

RoleRelationInfo = class()

local prop = Property(RoleRelationInfo)
prop:accessor("roleSID")
prop:accessor("roleID")
prop:accessor("timeStamp", 0)--玩家的时间戳
prop:accessor("gotoStamp")--玩家的传送时间戳
prop:accessor("queryStamp")--玩家的查询仇敌位置时间戳
prop:accessor("stamp", 0)	--玩家的时间戳
prop:accessor("enemyWord", "")	--玩家的时间戳


function RoleRelationInfo:__init()
	self._friends = {}	        --好友集
	self._enemys = {}	        --仇敌集
	self._blacks = {}	        --黑名单集
	self._meets = {}	        --熟人列表
	self._beFriends = {}        --被视为好友的ID集
	self._beEnemys = {}     	--被视为仇敌的ID集
    self._beBlacks = {}     	--被视为黑名单的ID集
	self._gifts = {}			--赠送礼物的ID集
	self._beGifts = {}			--被赠送礼物的ID集
	self._upFlag = {}			--脏数据标示
    self:setGotoStamp(os.time())
    self:setQueryStamp(os.time())
	self:setEnemyWord(EMEMY_WORD)--仇敌宣言初始化
end

--判断能否传送，能传送就同时更新时间戳
function RoleRelationInfo:canGoto()
    if (os.time() - self:getGotoStamp()) > 10 then
        self:setGotoStamp(os.time())
        return true
    else
        return false
    end
end

--判断能否查询，能查询就同时更新时间戳
function RoleRelationInfo:canQueryEnemy()
    if (os.time() - self:getQueryStamp()) > 10 then
        self:setQueryStamp(os.time())
        return true
    else
        return false
    end
end


--增加数据
function RoleRelationInfo:addRelationData(luabuf)
	local targetid = luabuf:popString()
	local _type = luabuf:popInt()
	local param1 = luabuf:popInt()
	local param2 = luabuf:popInt()
	local name = luabuf:popString()
	local level = luabuf:popInt()
	local sex = luabuf:popInt()
	local worldid = luabuf:popInt()
	local school = luabuf:popInt()
	local battle = luabuf:popInt()
	
	local tb = {}
	tb.roleSid = targetid
	tb.name = name
	tb.level = level
	tb.school = school
	tb.sex = sex
	tb.fightAbility = battle
	tb.isOnLine = false

	if _type == RelationKind.Friend then
		tb.giveFlower = param1
		tb.beGiveFlower = param2
		self._friends[targetid] = tb
	elseif _type == RelationKind.Enemy then
		tb.killNum = param1
		tb.beKillNum = param2
		self._enemys[targetid] = tb
	elseif _type == RelationKind.Black then
		self._blacks[targetid] = tb
	end
end

--增加被动数据
function RoleRelationInfo:addPassivityData(relationType, targetRoleSid)
	if relationType == RelationKind.Friend then
		table.insert(self._beFriends, targetRoleSid)
	elseif relationType == RelationKind.Enemy then
		table.insert(self._beEnemys, targetRoleSid)
	elseif relationType == RelationKind.Black then
		table.insert(self._beBlacks, targetRoleSid)
	end
end



--增加一个好友
function RoleRelationInfo:addFriend(roleSid, friendTb)
    if not self._friends[roleSid] then
		friendTb.giveFlower = 0
		friendTb.beGiveFlower = 0
		self._friends[roleSid] = friendTb
		self:addRelation2DB(RelationKind.Friend, roleSid, friendTb.giveFlower, friendTb.beGiveFlower)
    end
end

--移除一个好友
function RoleRelationInfo:romoveFriend(roleSid)
	self._friends[roleSid] = nil
	self:deleteRelation2DB(RelationKind.Friend, roleSid)
end

---获取某个好友
function RoleRelationInfo:getFriend(roleSid)
	return self._friends[roleSid]
end

---获取全部好友
function RoleRelationInfo:getAllFriend()
	self:freshRelationData(RelationKind.Friend)
	return self._friends
end

---获取好友数量
function RoleRelationInfo:getFriendNum()
	return table.size(self._friends)
end

--增加一个仇敌
function RoleRelationInfo:addEnemy(roleSid, fromCLient)
    if not self._enemys[roleSid] then
	    local enemy = {}
        local targetPlayer = g_entityMgr:getPlayerBySID(roleSid)
		if targetPlayer then
			enemy.roleSid = roleSid
			enemy.name = targetPlayer:getName()
			enemy.level = targetPlayer:getLevel()
			enemy.school = targetPlayer:getSchool()
			enemy.sex = targetPlayer:getSex()
			enemy.isOnLine = true--第一次添加关系的时候肯定是在线的
			enemy.fightAbility = targetPlayer:getbattle()
			enemy.killNum = 0
			--如果是客户端主动增加的,说明没被杀
			if fromCLient then
				enemy.beKillNum = 0
			else--是服务器自动加的，所以已经被杀过一次了
				enemy.beKillNum = 1
			end
			self._enemys[roleSid] = enemy

			self:addRelation2DB(RelationKind.Enemy, roleSid, enemy.killNum, enemy.beKillNum)
		else
			print("增加仇敌数据错误", roleSid, toString(enemy), debug.traceback())
			return
		end
    end
end

--增加一个熟人
function RoleRelationInfo:addMeet(roleSid)
    if not self._meets[roleSid] and not self._friends[roleSid] then
		if table.size(self._meets) < MEETNUM then
			local meet = {}
			local targetPlayer = g_entityMgr:getPlayerBySID(roleSid)
			if targetPlayer then
				meet.roleSid = roleSid
				meet.name = targetPlayer:getName()
				meet.level = targetPlayer:getLevel()
				meet.school = targetPlayer:getSchool()
				meet.sex = targetPlayer:getSex()
				meet.isOnLine = true--第一次添加关系的时候肯定是在线的
				meet.fightAbility = targetPlayer:getbattle()

				self._meets[roleSid] = meet
			end
		end
    end
end

--移除一个仇敌
function RoleRelationInfo:romoveEnemy(roleSid)
	self._enemys[roleSid] = nil
    self:deleteRelation2DB(RelationKind.Enemy, roleSid)
end

---获取某个仇敌
function RoleRelationInfo:getEnemy(roleSid)
	return self._enemys[roleSid]
end

--获取仇敌数量
function RoleRelationInfo:getEnemyNum()
	return table.size(self._enemys)
end

--获取全部仇敌
function RoleRelationInfo:getAllEnemy()
	return self._enemys
end

--增加一个黑名单
function RoleRelationInfo:addBlack(roleSid, friendTb)
    if not self._blacks[roleSid] then
	    self._blacks[roleSid] = friendTb
	    self:addRelation2DB(RelationKind.Black, roleSid, 0, 0)
     else
		print("增加黑名单数据错误", roleSid, toString(black), debug.traceback())
		return
     end
end

--移除一个黑名单
function RoleRelationInfo:romoveBlack(roleSid)
	self._blacks[roleSid] = nil
    self:deleteRelation2DB(RelationKind.Black, roleSid)
end

---判断是否黑名单
function RoleRelationInfo:getBlack(roleSid)
    return self._blacks[roleSid]
end

---判断是否黑名单
function RoleRelationInfo:getBlackByName(name)
    for _,black in piars(self._blacks) do
		if black.name == name then
			return black
		end
	end
end

---获取黑名单数量
function RoleRelationInfo:getBlackNum()
	return table.size(self._blacks)
end

--增加一个被视为好友
function RoleRelationInfo:addBeFriend(roleSid)
    if not self:isBeFriend(roleSid) then
        table.insert(self._beFriends, roleSid)
    end
end

--移除一个被视为好友
function RoleRelationInfo:romoveBeFriend(roleSid)
	if self:isBeFriend(roleSid) then
        table.removeValue(self._beFriends, roleSid)
    end
end

---判断是否被视为好友
function RoleRelationInfo:isBeFriend(roleSid)
	return table.contains(self._beFriends, roleSid)
end

---获取全部被视为好友
function RoleRelationInfo:getAllBeFriend()
	return self._beFriends
end

--增加一个被视为仇敌
function RoleRelationInfo:addBeEnemy(roleSid)
    if not self:isBeEnemy(roleSid) then
        table.insert(self._beEnemys, roleSid)
    end
end

--移除一个被视为仇敌
function RoleRelationInfo:romoveBeEnemy(roleSid)
	if self:isBeEnemy(roleSid) then
        table.removeValue(self._beEnemys, roleSid)
    end
end

---判断是否被视为仇敌
function RoleRelationInfo:isBeEnemy(roleSid)
	return table.contains(self._beEnemys, roleSid)
end

---获取全部被视为仇敌
function RoleRelationInfo:getAllBeEnemy()
	return self._beEnemys
end

--增加一个被视为黑名單
function RoleRelationInfo:addBeBlack(roleSid)
    if not self:isBeBlack(roleSid) then
        table.insert(self._beBlacks, roleSid)
    end
end

--移除一个被视为黑名單
function RoleRelationInfo:romoveBeBlack(roleSid)
	if self:isBeBlack(roleSid) then
        table.removeValue(self._beBlacks, roleSid)
    end
end

---判断是否被视为黑名單
function RoleRelationInfo:isBeBlack(roleSid)
	return table.contains(self._beBlacks, roleSid)
end

---获取全部被视为黑名單
function RoleRelationInfo:getAllBeBlack()
	return self._beBlacks
end

--有玩家删除通知
function RoleRelationInfo:playerDelete(roleSID)
	if self._friends[roleSID] then
		g_relationServlet:sendErrMsg2Client(self:getRoleID(), RELATION_ERR_FRIEND_DELETE, 1, {self._friends[roleSID].name})
		self._friends[roleSID] = nil
	end

	if self._enemys[roleSID] then
		g_relationServlet:sendErrMsg2Client(self:getRoleID(), RELATION_ERR_ENEMY_DELETE, 1, {self._enemys[roleSID].name})
		self._enemys[roleSID] = nil
	end

	if self._blacks[roleSID] then
		g_relationServlet:sendErrMsg2Client(self:getRoleID(), RELATION_ERR_BLACK_DELETE, 1, {self._blacks[roleSID].name})
		self._blacks[roleSID] = nil
	end

	self._beFriends[roleSID] = nil
	self._beEnemys[roleSID] = nil
    self._beBlacks[roleSID] = nil
end

function RoleRelationInfo:checkStamp()
	local timeStamp = tonumber(time.toedition("day"))
	if timeStamp ~= self:getStamp() then
		self:setStamp(timeStamp)
		self._gifts = {}
		self._beGifts = {}
	end
end

function RoleRelationInfo:canGift(roleSID)
	self:checkStamp()
	if not table.contains(self._gifts, roleSID) then
		return true
	end
	return false
end

function RoleRelationInfo:canPickGift(roleSID)
	self:checkStamp()
	if table.contains(self._beGifts, roleSID) then
		return true
	end
	return false
end

function RoleRelationInfo:pickGitf(roleSID)
	table.removeValue(self._beGifts, roleSID)

	local player = g_entityMgr:getPlayerBySID(self:getRoleSID())
	local ecode = 0
	local itemMgr = player:getItemMgr()
	local rewardData = itemMgr:addItemByDropList(Item_BagIndex_Bag, RELATION_REALFRIEND_REWARDID, 22, ecode)
	local item = unserialize(rewardData)
	if item[1] then
		g_relationServlet:sendErrMsg2Client(player:getID(), RELATION_ERR_GAIN_BY_GIFT, 1, {item[1].count})
	end

	self:castGift2DB()
end

function RoleRelationInfo:giveGitf(roleSID)
	table.insert(self._gifts, roleSID)
	self:castGift2DB()
end

function RoleRelationInfo:beGiveGitf(roleSID)
	table.insert(self._beGifts, roleSID)
	self:castGift2DB()
end

function RoleRelationInfo:changeEnmeyWord(word)
	self:setEnemyWord(word or "")
	self:castGift2DB()
end

function RoleRelationInfo:castGift2DB()
	local datas = {}
	datas.stamp = self:getStamp()
	datas.enemyWord = self:getEnemyWord()
	datas.gift = self._gifts
	datas.beGift = self._beGifts
	local cache_buff = protobuf.encode("RelationProtocol", datas)
	g_engine:savePlayerCache(self:getRoleSID(), FIELD_RELATION, cache_buff, #cache_buff)
end

function RoleRelationInfo:loadRelationData(cache_buf)
	if #cache_buf > 0 then
		local datas = protobuf.decode("RelationProtocol", cache_buf)
		self:setStamp(datas.stamp or 0)
		self:setEnemyWord(datas.enemyWord or "")
		self._gifts = datas.gift
		self._beGifts = datas.beGift
	end
	self:checkStamp()
end

--刷新在线社交的数据
function RoleRelationInfo:freshRelationData(relationType)
	if relationType == RelationKind.Friend then
		for k,v in pairs(self._friends or {}) do
			v.isOnLine = false
		    local targetPlayer = g_entityMgr:getPlayerBySID(k)
		    if targetPlayer then
				v.level = targetPlayer:getLevel()
				v.fightAbility = targetPlayer:getbattle()
				if targetPlayer:getStatus() == eEntityNormal then
					v.isOnLine = true
				end
		    end
		end
	elseif relationType == RelationKind.Enemy then
		for k,v in pairs(self._enemys or {}) do
			v.isOnLine = false
		    local targetPlayer = g_entityMgr:getPlayerBySID(k)
		    if targetPlayer then
				v.level = targetPlayer:getLevel()
				v.fightAbility = targetPlayer:getbattle()
				if targetPlayer:getStatus() == eEntityNormal then
					v.isOnLine = true
				end
		    end
		end
	elseif relationType == RelationKind.Black then
		for k,v in pairs(self._blacks or {}) do
			v.isOnLine = false
		    local targetPlayer = g_entityMgr:getPlayerBySID(k)
		    if targetPlayer then
				v.level = targetPlayer:getLevel()
				v.fightAbility = targetPlayer:getbattle()
				if targetPlayer:getStatus() == eEntityNormal then
					v.isOnLine = true
				end
		    end
		end
	elseif relationType == RelationKind.Meet then
		for k,v in pairs(self._meets or {}) do
			v.isOnLine = false
		    local targetPlayer = g_entityMgr:getPlayerBySID(k)
		    if targetPlayer then
				v.level = targetPlayer:getLevel()
				v.fightAbility = targetPlayer:getbattle()
				if targetPlayer:getStatus() == eEntityNormal then
					v.isOnLine = true
				end
		    end
		end
	end
end

--写入好友信息，用来发送到客户端
function RoleRelationInfo:writeFriendData()
	local roleData = {}
	self:freshRelationData(RelationKind.Friend)
    for _,v in pairs(self._friends or {}) do
		local roleInfo = {}
		roleInfo.roleSid = v.roleSid
		roleInfo.name = v.name
		roleInfo.level = v.level
		roleInfo.sex = v.sex
		roleInfo.school = v.school
		roleInfo.fightAbility = v.fightAbility
		roleInfo.isOnLine = v.isOnLine
		table.insert(roleData, roleInfo)
    end
	return roleData
end

--写入仇敌信息，用来发送到客户端
function RoleRelationInfo:writeEnemyData()
	local roleData = {}
	self:freshRelationData(RelationKind.Enemy)
	for _,v in pairs(self._enemys or {}) do
		local roleInfo = {}
		roleInfo.roleSid = v.roleSid
		roleInfo.name = v.name
		roleInfo.level = v.level
		roleInfo.sex = v.sex
		roleInfo.school = v.school
		roleInfo.fightAbility = v.fightAbility
		roleInfo.isOnLine = v.isOnLine
		roleInfo.killNum = v.killNum
		roleInfo.beKillNum = v.beKillNum
		table.insert(roleData, roleInfo)
    end
	return roleData
end

--写入黑名单信息，用来发送到客户端
function RoleRelationInfo:writeBlackData()
	local roleData = {}
	self:freshRelationData(RelationKind.Black)
	for _,v in pairs(self._blacks or {}) do
		local roleInfo = {}
		roleInfo.roleSid = v.roleSid
		roleInfo.name = v.name
		roleInfo.level = v.level
		roleInfo.sex = v.sex
		roleInfo.school = v.school
		roleInfo.fightAbility = v.fightAbility
		roleInfo.isOnLine = v.isOnLine
		table.insert(roleData, roleInfo)
    end
	return roleData
end

--写入附近人信息，用来发送到客户端
function RoleRelationInfo:writeNearData()
	local roleData = {}
	local player = g_entityMgr:getPlayerBySID(self:getRoleSID())
    local pos = player:getPosition()

	local scene = g_sceneMgr:getPublicScene(player:getMapID())
	if player:getMapID() == FACTION_AREA_MAP_ID then
		scene = g_sceneMgr:getFacAreaScene(player:getAreaFactionID())
	end

	if scene then
		local curScenePlayer = scene:getEntities(0, pos.x, pos.y, 10, eClsTypePlayer, 0) or {}
		if #curScenePlayer > 0 then
			for i=1, #curScenePlayer do
				local tmpplayer = g_entityMgr:getPlayer(curScenePlayer[i])
				if tmpplayer and tmpplayer:getSerialID() ~= player:getSerialID()then
					local info = {}
					info.roleSid = tmpplayer:getSerialID()
					info.name = tmpplayer:getName()
					info.sex = tmpplayer:getSex()
					info.school = tmpplayer:getSchool()
					info.level = tmpplayer:getLevel()
					info.isOnLine = true
					info.fightAbility = tmpplayer:getbattle()
					table.insert(roleData, info)
				end
			end
		end
	end
	
	return roleData
end

--写入熟人信息，用来发送到客户端
function RoleRelationInfo:writeMeetData()
	local roleData = {}
	self:freshRelationData(RelationKind.Meet)
	for _,v in pairs(self._meets or {}) do
		local roleInfo = {}
		roleInfo.roleSid = v.roleSid
		roleInfo.name = v.name
		roleInfo.level = v.level
		roleInfo.sex = v.sex
		roleInfo.school = v.school
		roleInfo.fightAbility = v.fightAbility
		roleInfo.isOnLine = v.isOnLine
		table.insert(roleData, roleInfo)
    end
	return roleData
end

function RoleRelationInfo:getEnemyName(relationType)
	local ret = {}
	local nameList = {}
	if relationType == RelationKind.Friend then
		for _,friend in pairs(self._friends) do
			table.insert(nameList, friend.name)
		end
	elseif relationType == RelationKind.Enemy then
		for _,enemy in pairs(self._enemys) do
			table.insert(nameList, enemy.name)
		end
	elseif relationType == RelationKind.Black then
		for _,black in pairs(self._blacks) do
			table.insert(nameList, black.name)
		end
	elseif relationType == RelationKind.Meet then
		for _,meet in pairs(self._meets) do
			table.insert(nameList, meet.name)
		end
	end

	ret.name = nameList
	ret.relationType = relationType
	fireProtoMessage(self:getRoleID(), RELATION_SC_GETENEMYNAME_RET, 'GetEnemyNameRetProtocol', ret)
end

function RoleRelationInfo:getMeetMen()
	local ret = {}
	local info = {}
	for _,enemy in pairs(self._enemys) do
		local info = {}
		info.roleSID = tmpplayer:getSerialID()
		info.name = tmpplayer:getName()
		info.sex = tmpplayer:getSex()
		info.school = tmpplayer:getSchool()
		info.level = tmpplayer:getLevel()
		info.battle = tmpplayer:getbattle()
		tabale.insert(ret.info, info)
	end

	fireProtoMessage(self:getRoleID(), RELATION_SC_GETNEARMEN_RET, 'GetMeetMenRetProtocol', ret)
end

--杀死仇敌处理，返回（被杀次数—击杀次数）值
function RoleRelationInfo:killEnemy(enemy)
	enemy.killNum = enemy.killNum + 1
	self:addUpdateFlag(enemy.roleSid)
    return enemy.beKillNum - enemy.killNum
end

--杀死仇敌处理，返回（被杀次数—击杀次数）值
function RoleRelationInfo:beKillByEnemy(enemy)
	enemy.beKillNum = enemy.beKillNum + 1
	self:addUpdateFlag(enemy.roleSid)
    return enemy.beKillNum - enemy.killNum
end

function RoleRelationInfo:getUpdateFlag(roleSID)
	if table.contains(self._upFlag, roleSID) then
		return true
	end
	return false
end

function RoleRelationInfo:addUpdateFlag(roleSID)
	if not table.contains(self._upFlag, roleSID) then
		table.insert(self._upFlag, roleSID)
	end
end

function RoleRelationInfo:clearUpdateFlag()
		self._upFlag = {}
end

--保存到数据库
function RoleRelationInfo:cast2DB()
	for k,v in pairs(self._friends or {}) do
		if self:getUpdateFlag(k) then
			self:updateRelation2DB(RelationKind.Friend, k, v.giveFlower, v.beGiveFlower)
		end
	end

	for k,v in pairs(self._enemys or {}) do
		if self:getUpdateFlag(k) then
			self:updateRelation2DB(RelationKind.Enemy, k, v.killNum, v.beKillNum)
		end
	end

	for k,v in pairs(self._blacks or {}) do
		if self:getUpdateFlag(k) then
			self:updateRelation2DB(RelationKind.Black, k, 0, 0)
		end
	end
	self:clearUpdateFlag()
end

--加载关系数据
function RoleRelationInfo:loadData()
	g_entityDao:loadRelationData(self:getRoleSID())
end

--加载被动关系数据
function RoleRelationInfo:loadPassivityData()
	g_entityDao:loadPassivityData(self:getRoleSID())
end

--增加一个关系数据到数据库
function RoleRelationInfo:addRelation2DB(relationType, targetRoleSid, param1, param2)
	sql1 = string.format("replace into relation (roleID, targetRoleID, type, param1, param2) values ('%s', '%s', %d, %d, %d);",self:getRoleSID(),targetRoleSid,relationType,param1,param2)
	apiEntry.exeSQL(sql1, self:getRoleSID())
	sql2 = string.format("replace into passivity_relation (roleID, targetRoleID, type) values ('%s', '%s', %d);",targetRoleSid,self:getRoleSID(),relationType)
	apiEntry.exeSQL(sql2, self:getRoleSID())
	if relationType==1 then
		sql3 = string.format("DELETE FROM passivity_relation WHERE roleID = '%s' AND targetRoleID = '%s' AND type = 3;",targetRoleSid,self:getRoleSID())
		apiEntry.exeSQL(sql3, self:getRoleSID())
	elseif relationType==3 then
		sql3 = string.format("DELETE FROM passivity_relation WHERE roleID = '%s' AND targetRoleID = '%s' AND type = 1;",targetRoleSid,self:getRoleSID())
		apiEntry.exeSQL(sql3, self:getRoleSID())
	end
end

--删除数据库一个关系
function RoleRelationInfo:deleteRelation2DB(relationType, targetRoleSid)
	rId = self:getRoleSID()
	sql1 = string.format("delete from relation where roleID = %d and targetRoleID = %d and type =%d;",rId,targetRoleSid,relationType)
	apiEntry.exeSQL(sql1, rId)
	sql2 = string.format("delete from passivity_relation where roleID =%d and targetRoleID = %d and type =%d;",targetRoleSid,rId,relationType)
	apiEntry.exeSQL(sql2, rId)
end

--更新数据库一个关系
function RoleRelationInfo:updateRelation2DB(relationType, targetRoleSid, param1, param2)
	rId = self:getRoleSID()
	sql = string.format("update relation set param1 = %d,param2 =%d where roleID = %d and targetRoleID = %d and type =%d;",param1,param2,rId,targetRoleSid,relationType)
	apiEntry.exeSQL(sql, rId)
end