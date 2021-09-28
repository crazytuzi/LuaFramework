--FactionMember.lua

FactionMember = class(nil , Serializable)

local prop = Property(FactionMember)

prop:accessor("factionID")
prop:accessor("roleSID")
prop:accessor("name")
prop:accessor("level")
prop:accessor("school")
prop:accessor("ability", 0)	--战斗力
prop:accessor("activeState") --在线状态，如果是0表示在线，非0表示上次下线的时间
--prop:accessor("contribution", 0) --帮贡
prop:accessor("position", FACTION_POSITION.Member)	--职务
prop:accessor("joinTime", 0)	--加入帮会时间
prop:accessor("sex", 1)	--性别
prop:accessor("weapon", 1)	--武器
prop:accessor("upperBody", 1)	--衣服
prop:accessor("wingID", 0)	--光翼
prop:accessor("fireNum", FACTION_ADD_FIRE_TIMES)	--添火次数


function FactionMember:__init(roleSID)
	prop(self, "roleSID", roleSID)
	self._contribution = 0
	--行会祈福
	self._dayPrayCounts = {}		--每天祈福的次数
	self._prayTimeStamp = 0			--时间戳
end

function FactionMember:getContribution()
	return self._contribution
end

function FactionMember:setContribution(value)
	self._contribution = value
	local player = g_entityMgr:getPlayerBySID(self:getRoleSID())
	if player then
		player:setContribute(value)
	end
end

--是否有某一项权利
function FactionMember:hasDroit(droit)
	local droits = FACTION_POS_DROIT[self:getPosition()]
	if table.include(droits, droit) then
		return true
	else
		return false
	end
end

function FactionMember:writeObject()

end

function FactionMember:readObject()

end

function FactionMember:getPrayTimeStamp()
	return self._prayTimeStamp
end

function FactionMember:setPrayTimeStamp(time)
	local retime = time
	local t=os.date("*t",time)
	if (time > 0) and (t["hour"] ~= UPDATE_COPY_TIME) then
		t.hour = UPDATE_COPY_TIME
		t.min = 0
		t.sec = 0
		retime = os.time(t)
	end
	self._prayTimeStamp = retime
	--print("FactionMember:setPrayTimeStamp",time,self._prayTimeStamp)
end

--获取祈福的次数
function FactionMember:_getDayPrayCount(prayType)
	return self._dayPrayCounts[prayType] or 0
end

function FactionMember:getDayPrayCount(prayType)
	local nowTime = os.time()

	if not self._dayPrayCounts[prayType] then
		self._dayPrayCounts[prayType] = 0
	end
	--print('FactionMember:getDayPrayCount',self._prayTimeStamp,self._dayPrayCounts)
	--判断是否是新CD
	if (self._prayTimeStamp > nowTime) or (nowTime - self._prayTimeStamp > ONE_DAY_SEC) then
		self._dayPrayCounts = {}
		self._dayPrayCounts[prayType] = 0
		self._prayTimeStamp  = getNormalUpdateTime(self._prayTimeStamp)
	end
	return self._dayPrayCounts[prayType] or 0
end

--增加祈福的次数
function FactionMember:addDayPrayCount(prayType)
	local nowTime = os.time()
	--判断是否是新CD
	if (self._prayTimeStamp > nowTime) or (nowTime - self._prayTimeStamp > ONE_DAY_SEC) then
		self._dayPrayCounts = {}
		self._dayPrayCounts[prayType] = 1
		self._prayTimeStamp  = getNormalUpdateTime(self._prayTimeStamp)
	else
		local cdCnt = self._dayPrayCounts[prayType] or 0
		self._dayPrayCounts[prayType] = cdCnt + 1	
	end
end

--写数据转字符串
function FactionMember:update2DB(factionID)
	local luaBuf2 = self:writeString()
	g_entityDao:updateFactionMember(self:getRoleSID(),factionID, luaBuf2, #luaBuf2)
end

--写数据转字符串
function FactionMember:writeString()
	local data = {}
	data.name = self:getName()
	data.level = self:getLevel()
	data.sex = self:getSex()
	data.school = self:getSchool()
	data.ability = self:getAbility()
	data.activeState = self:getActiveState()>0 and self:getActiveState() or os.time()
	data.contribution = self:getContribution()
	data.position = self:getPosition()
	data.joinTime = self:getJoinTime()
	data.weapon = self:getWeapon()
	data.upperBody = self:getUpperBody()
	data.wingID = self:getWingID()
	
	--行会祈福
	data.praytimestamp = self:getPrayTimeStamp()
	local prayinfos = {}
	for type, count in pairs(self._dayPrayCounts) do
		table.insert(prayinfos, {praytype = type, praycount = count})
	end
	data.prayinfos = prayinfos
	data.fireNum = self:getFireNum()
	return protobuf.encode("FacmemProtocol", data)
end

--读数据解析字符串
function FactionMember:readString(buff)
	if #buff > 0 then
		local datas = protobuf.decode("FacmemProtocol", buff)
		self:setName(datas.name)
		self:setLevel(datas.level)
		self:setSex(datas.sex)
		self:setSchool(datas.school)
		self:setAbility(datas.ability)
		self:setActiveState(datas.activeState)
		self:setContribution(datas.contribution)
		self:setPosition(datas.position)
		self:setJoinTime(datas.joinTime)
		self:setWeapon(datas.weapon)
		self:setUpperBody(datas.upperBody)
		self:setWingID(datas.wingID)

		--行会祈福
		self:setPrayTimeStamp(datas.praytimestamp)
		for _, prayinfo in pairs(datas.prayinfos) do
			self._dayPrayCounts[prayinfo.praytype] = prayinfo.praycount
		end
		
		self:setFireNum(datas.fireNum)
	end
end