--FactionSocial.lua
--行会之间建立的唯一外交关系

FactionSocial = class()

local prop = Property(FactionSocial)

--缓存信息
prop:accessor("uniqueID")		--当前关系唯一标识
prop:accessor("aFactionID",0)		--a行会ID
prop:accessor("bFactionID",0)		--b行会ID
prop:accessor("state", 0)		--当前状态
prop:accessor("opRoleSID","")		--操作人roleSID
prop:accessor("opFactionID",0)		--操作方行会ID
prop:accessor("opTime",0)		--操作时间
prop:accessor("aFactionOpTime",0)	--a行会操作时间(申请)
prop:accessor("bFactionOpTime",0)	--b行会操作时间(申请)

function FactionSocial.GetUniqueID(aFactionID,bFactionID)
	if aFactionID > bFactionID then
		return (aFactionID..bFactionID)
	else
		return (bFactionID..aFactionID)
	end
end

--异步数据库操作上下文信息 重置
function FactionSocial:resetAsynOpContext()
	self._asynOp = SocialOperator.None		--操作类型
	self._asynOpRoleSID = ""			--操作人roleSID
	self._asynOpFactionID = 0			--操作方行会ID
	self._asynOpState = 0				--操作状态
	self._asynOpTime = 0				--操作时间
	self._asynOpAFactionOpTime = 0			--a行会操作时间(申请)
	self._asynOpBFactionOpTime = 0			--b行会操作时间(申请)
end

--异步数据库操作上下文信息 设置
function FactionSocial:setAsynOpContext(operator,opRoleSID,opFactionID,state,aFactionOpTime,bFactionOpTime)
	self._asynOp = operator				--操作类型
	self._asynOpRoleSID = opRoleSID			--操作人roleSID
	self._asynOpFactionID = opFactionID		--操作方行会ID
	self._asynOpState = state			--操作状态
	self._asynOpTime = os.time()			--操作时间
	self._asynOpAFactionOpTime = aFactionOpTime	--a行会操作时间(申请)
	self._asynOpBFactionOpTime = bFactionOpTime	--b行会操作时间(申请)
end

--获取异步数据库操作上下文信息
function FactionSocial:getAsynOp()
	return self._asynOp
end

function FactionSocial:getAsynOpRoleSID()
	return self._asynOpRoleSID
end

function FactionSocial:getAsynOpFactionID()
	return self._asynOpFactionID
end

function FactionSocial:getAsynOpState()
	return self._asynOpState
end

function FactionSocial:getAsynOpTime()
	return self._asynOpTime
end

function FactionSocial:getAsynOpAFactionOpTime()
	return self._asynOpAFactionOpTime
end

function FactionSocial:getAsynOpBFactionOpTime()
	return self._asynOpBFactionOpTime
end

--初始化外交关系
function FactionSocial:__init(aFactionID,bFactionID)
	prop(self, "uniqueID", FactionSocial.GetUniqueID(aFactionID,bFactionID))
	prop(self, "aFactionID", aFactionID)
	prop(self, "bFactionID", bFactionID)

	--数据库操作上下文信息
	self:resetAsynOpContext()
end

--根据操作行会ID 设置对应的操作时间(只有申请才设置)
function FactionSocial:_getOpTimes(operator,opFactionID)
	--当前保存的操作时间
	local optimes = {aoptime = self:getAFactionOpTime(), boptime = self:getBFactionOpTime()}

	if operator == SocialOperator.ApplyUnion or operator == SocialOperator.ApplyHostility then	
		--设置操作时间
		if opFactionID == self:getAFactionID() then
			optimes.aoptime = os.time()
		elseif opFactionID == self:getBFactionID() then
			optimes.boptime = os.time()
		end
	end

	return optimes
end

function FactionSocial:_getOpTime(opFactionID)
	local optime = 0
	if opFactionID == self:getAFactionID() then
		optime = self:getAFactionOpTime()
	elseif opFactionID == self:getBFactionID() then
		optime = self:getBFactionOpTime()
	end
	return optime
end

--设置外交关系 数据存储
function FactionSocial:updateState(operator,state,opRoleSID,opFactionID)
	local oprid = opRoleSID and opRoleSID or ""
	local opfid = opFactionID and opFactionID or 0
	local opTimes = self:_getOpTimes(operator,opfid)

	--请求数据库更新 记录日志
	--保存上下文
	self:setAsynOpContext(operator,oprid,opfid,state,opTimes.aoptime,opTimes.boptime)

	--发出请求
	--记录日志
	--print("FactionSocial:updateState",self:getAFactionID(),self:getBFactionID(),self:getState(),operator,oprid,opfid,state)

	--[[local luaBuf = LuaEventManager:instance():getExchangeLuaBuffer()
	luaBuf:pushBool(true)
	luaBuf:pushInt(SPDEF_UPDATEFACTIONSOCIAL)
	luaBuf:pushString("_SocialID")
	luaBuf:pushString(self:getUniqueID())

	luaBuf:pushString("_WorldID")
	luaBuf:pushInt(g_frame:getWorldId())

	luaBuf:pushString("_AFactionID")
	luaBuf:pushInt(self:getAFactionID())

	luaBuf:pushString("_BFactionID")
	luaBuf:pushInt(self:getBFactionID())
	
	luaBuf:pushString("_State")
	luaBuf:pushInt(state)

	luaBuf:pushString("_OpRoleID")
	luaBuf:pushInt(oprid)

	luaBuf:pushString("_OpFactionID")
	luaBuf:pushInt(opfid)

	luaBuf:pushString("_OpTime")
	luaBuf:pushInt(os.time())
	
	luaBuf:pushString("_AFactionOpTime")
	luaBuf:pushInt(opTimes.aoptime)

	luaBuf:pushString("_BFactionOpTime")
	luaBuf:pushInt(opTimes.boptime)]]

	local sql = string.format([[INSERT INTO factionsocial VALUES ('%s', %d, %d, %d, %d, '%s', %d, 
		%d, %d, %d, '', NOW()) ON DUPLICATE KEY UPDATE State=%d, OpRoleID='%s', OpFactionID=%d, 
	OpTime=%d, AFactionOpTime=%d, BFactionOpTime=%d, UpdateTime=NOW();]],self:getUniqueID(),g_frame:getWorldId(),
	self:getAFactionID(),self:getBFactionID(),state,oprid,opfid,os.time(),opTimes.aoptime,opTimes.boptime,state,oprid,opfid,os.time(),opTimes.aoptime,
	opTimes.boptime)

	g_entityDao:updateFactionSocial(self:getUniqueID(),operator,sql)
	return SocialOperator_Success
end

--数据库操作成功返回 更新缓存
function FactionSocial:onUpdateState(state,opRoleSID,opFactionID,opTime,aFactionOpTime,bFactionOpTime)
	--记录日志
	--print("FactionSocial:onUpdateState",self:getAFactionID(),self:getBFactionID(),self:getState(),self._asynOp,self._asynOpRoleSID,self._asynOpFactionID,state)

	--同步缓存
	prop(self, "state", state)

	local oprid = opRoleSID and opRoleSID or ""
	prop(self, "opRoleSID", oprid)
	
	local opfid = opFactionID and opFactionID or 0
	prop(self, "opFactionID", opfid)
	
	local time = opTime and opTime or os.time()
	prop(self, "opTime", time)
	
	if aFactionOpTime then
		prop(self, "aFactionOpTime", aFactionOpTime)
	end

	if bFactionOpTime then
		prop(self, "bFactionOpTime", bFactionOpTime)
	end

	self:resetAsynOpContext()
end

function FactionSocial:update()
	--异步数据库操作是否返回
	if self._asynOp ~= SocialOperator.None then
		return
	end

	local now = os.time()
	local state = self:getState()
	if state == SocialState.Hostility then			--敌对状态
		if(now > self:getOpTime() + HostilityLastTime) then
			--print('FactionSocial:update SocialState.Hostility',self:getAFactionID(),self:getBFactionID(),self:getState(),self._asynOp,self._asynOpRoleSID,self._asynOpFactionID)
			self:updateState(SocialOperator.ServerSet,SocialState.Neutral)
		end
	elseif state == SocialState.ApplyUnion then		--申请联盟状态
		if(now > self:getOpTime() + ApplyUnionLastTime) then
			print('FactionSocial:update SocialState.ApplyUnion',self:getAFactionID(),self:getBFactionID(),self:getState(),self:getOpRoleSID())
			self:updateState(SocialOperator.RefuseUnion,SocialState.Neutral)
		end
	end
end

--判断某个行会的操作是否在冷却中
function FactionSocial:isCoolDown(opFactionID)
	local now = os.time()
	local opTime = self:_getOpTime(opFactionID)
	if opTime ~= 0 and (now < opTime + SocialOperatorCoolDown) then
		return true
	else
		return false
	end	
end

--由一个选另一个
function FactionSocial:getDstFactionID(srcFactionID)
	if self:getAFactionID() == srcFactionID then
		return self:getBFactionID()
	else
		return self:getAFactionID()
	end
end

--操作的有效性检测
function FactionSocial:isValidOperator(operator,opFactionID)
	local state = self:getState()
	local ret = {restate = state, recode = SocialOperator_Success}
	if operator == SocialOperator.ApplyUnion then								--申请联盟
		if state == SocialState.Neutral and not self:isCoolDown(opFactionID) then
			ret.restate = SocialState.ApplyUnion
		elseif state ~= SocialState.Neutral then
			ret.recode = ApplyUnionError_State
		else
			ret.recode = SocialOperatorError_InCD
		end
	elseif operator == SocialOperator.AcceptUnion then							--接受联盟
		if state == SocialState.ApplyUnion and opFactionID ~= self:getOpFactionID() then
			ret.restate = SocialState.Union
		else
			ret.recode = AcceptOrRefuseUnionError_State
		end
	elseif operator == SocialOperator.RefuseUnion then							--拒绝联盟
		if state == SocialState.ApplyUnion and opFactionID ~= self:getOpFactionID() then
			ret.restate = SocialState.Neutral
		else
			ret.recode = AcceptOrRefuseUnionError_State
		end
	elseif operator == SocialOperator.StopUnion then							--终止联盟
		if state == SocialState.Union then
			ret.restate = SocialState.Neutral
		else
			ret.recode = StopUnionError_State
		end
	elseif operator == SocialOperator.ApplyHostility then							--宣战
		if state == SocialState.Neutral and not self:isCoolDown(opFactionID) then
			ret.restate = SocialState.Hostility
		elseif state ~= SocialState.Neutral then
			ret.recode = ApplyHostilityError_State
		else
			ret.recode = SocialOperatorError_InCD
		end
	else
		ret.recode = SocialOperatorError_Invalid
	end
	return ret
end

--写基本数据buffer
function FactionSocial:writeBaseBuffer(buffer,factionID)
	local state = self:getState()
	buffer:pushInt(self:getAFactionID())					--a行会ID
	buffer:pushInt(self:getBFactionID())					--b行会ID
	buffer:pushChar(state)							--当前状态
	buffer:pushInt(self:getOpFactionID())					--操作方行会ID
	
	local time = 0
	if state == SocialState.Neutral then
		if factionID == self:getAFactionID() then
			time = (self:getAFactionOpTime() > 0) and (self:getAFactionOpTime() + SocialOperatorCoolDown - os.time()) or 0
		else
			time = (self:getBFactionOpTime() > 0) and (self:getBFactionOpTime() + SocialOperatorCoolDown - os.time()) or 0
		end
	elseif state == SocialState.Hostility then
		time = (self:getOpTime() > 0) and (self:getOpTime() + HostilityLastTime - os.time()) or 0
	end
	
	time = time > 0 and time or 0
	buffer:pushInt(time)							--倒计时剩余时间(秒) 中立状态下为本行会剩余操作冷却时间 敌对状态下为敌对状态剩余时间 其他状态无视
end

--处理行会外交操作
function FactionSocial:doOperator(operator,opRoleSID,opFactionID)
	--print("FactionSocial:doOperator",self:getAFactionID(),self:getBFactionID(),self:getState(),operator,opRoleSID,opFactionID)
	
	--异步数据库操作是否返回
	if self._asynOp ~= SocialOperator.None then
		return SocialOperatorError_InBusy
	end

	--检测当前状态下操作的有效性
	local opret = self:isValidOperator(operator,opFactionID)
	if opret.recode ~= SocialOperator_Success then
		return opret.recode
	end
	
	--数据更新 发出异步数据库请求
	return self:updateState(operator,opret.restate,opRoleSID,opFactionID)
end