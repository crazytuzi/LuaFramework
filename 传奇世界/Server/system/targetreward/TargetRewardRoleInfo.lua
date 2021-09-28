--TargetRewardRoleInfo.lua
--/*-----------------------------------------------------------------
 --* Module:  TargetRewardRoleInfo.lua
 --* Author:  liucheng
 --* Modified: 20160321
 --* Purpose: Implementation of the class TargetRewardRoleInfo
 -------------------------------------------------------------------*/

 TargetRewardRoleInfo = class()

local prop = Property(TargetRewardRoleInfo)
prop:accessor("roleSID", 0)

function TargetRewardRoleInfo:__init()
	self._TargetReward = {1,1,1}
	self._loadDB = 0   									--是否加载了数据库的数据
end

function TargetRewardRoleInfo:loadDBData(dataTb)
	local dataTmp = unserialize(dataTb)
	if dataTmp.t then
		self._TargetReward = dataTmp.t		
	else
		self:cast2DB()
	end

	self._loadDB = 1
	self:SendTargetReward()
end

function TargetRewardRoleInfo:SendTargetReward()	
	if self._loadDB>0 then		
		local player = g_entityMgr:getPlayerBySID(self:getRoleSID())
		if player then
			local school = player:getSchool()		
			local TargetRecordID = self:GetTargetReward(school)

			local retData = {}
			retData.targetRewardID = TargetRecordID			
			fireProtoMessage(player:getID(),TARGETREWARD_SC_CHECK_RET,"CheckTargetRewardRetProtocol",retData)
		end
	end	
end

function TargetRewardRoleInfo:GetTargetReward(tSchool)
	if self._loadDB<1 then return -1 end
	if tSchool then
		local TargetNO = self._TargetReward[tSchool]
		if 0==TargetNO then return TargetNO end
		local getride = g_rideMgr:getRideActiveState(self:getRoleSID())
		if getride then
			if TargetNO<4 then
				TargetNO = 4
			end
		end
		if TargetNO>8 then
			TargetNO = 0
		end
		return TargetNO
	end
end

function TargetRewardRoleInfo:cast2DB()	
	local dbStr = {t=self._TargetReward}
	local cache_buf = serialize(dbStr)
	g_engine:savePlayerCache(self:getRoleSID(), FIELD_TARGETREWARD, cache_buf, #cache_buf)
end

function TargetRewardRoleInfo:switchOut(peer, dbid, mapID)
	local luaBuf = g_buffMgr:getLuaEventEx(LOGIN_WW_SWITCH_WORLD)
	luaBuf:pushInt(dbid)
	luaBuf:pushShort(EVENT_TARGET_REWARD_SET)
	--具体数据跟在后面
	luaBuf:pushInt(self._loadDB)
	luaBuf:pushString(serialize(self._TargetReward))
end

function TargetRewardRoleInfo:switchIn(player, luaBuf)
	if luaBuf:size() > 0 then
		self._loadDB = luaBuf:popInt()
		local target = luaBuf:popString()
		self._TargetReward = unserialize(target)
	end
end

--领取目标奖励	20150304
function TargetRewardRoleInfo:OwnGetReward(tplayer,tRecordID)		--动态ID 目标奖励的记录ID
	if self._loadDB<1 then return end
	if not tRecordID then return end

	if not tplayer then	return end
	local tSchool = tplayer:getSchool()
	local tLevel = tplayer:getLevel()
	--判断tRecordID 是不是 当前要领的这个
	local TargetIDTemp = self:GetTargetReward(tSchool)
	if tRecordID~=TargetIDTemp then
		local retData = {}
		retData.getResult = false
		retData.nextTargetRewardID = tRecordID
		fireProtoMessage(tplayer:getID(),TARGETREWARD_SC_GET_RET,"GetTargetRewardRetProtocol",retData)
		return
	end

	local TargetRecord = g_TargetRewardMgr:getTargetReward(tSchool)	
	if not TargetRecord then
		return
	end
	local hasRecord = false		--是否存在 记录ID=RecordID 的记录
	local OnceRun = false
	local nextRecordID = 0		--下一条记录ID是多少
	local tRecord = nil			--当前可以领取的整条记录
	for i,v in pairs(TargetRecord) do
		if OnceRun then
			nextRecordID = v.record_id
			break
		end
		if tRecordID==v.record_id then
			hasRecord = true
			OnceRun = true
			tRecord = v
		end
	end
	if not hasRecord or not tRecord then
		return
	end	

	--判断职业、等级，获取物品ID，塞进玩家背包，修改可以获取的目标奖励记录ID
	if tRecord.q_job~=tSchool then
		return
	end
	if tRecord.q_level>tLevel then
		return
	end
	local roleSID = tplayer:getSerialID()
	local Operation = false;
	if 4==tRecord.q_level then				--技能	1002攻杀		2002雷电		3002灵魂火符
		local skillMgr = tplayer:getSkillMgr()
		skillMgr:learnSkill(tRecord.q_id, 0)
		Operation = true
	elseif 13==tRecord.q_level then
		tplayer:setMoney(tplayer:getMoney() + tRecord.q_num)
		Operation = true
		g_logManager:writeMoneyChange(roleSID,"",1,95,tplayer:getMoney(),tRecord.q_num,1)
	--elseif 15==tRecord.q_level then			--坐骑
		--Operation = g_rideMgr:firstActiveRide(tplayer)
	elseif 35==tRecord.q_level then			--绑定元宝
		tplayer:setBindIngot(tplayer:getBindIngot() + tRecord.q_num)
		Operation = true
		--货币变化日志	20150907
		g_logManager:writeMoneyChange(roleSID,"",4,95,tplayer:getBindIngot(),tRecord.q_num,1)
	else
		--如果是物品就直接放入背包
		local itemMgr = tplayer:getItemMgr()
		local freeSlotNum = itemMgr:getEmptySize()		----如果物品格子数不够就发邮件
		local offlineMgr = g_entityMgr:getOfflineMgr()
		if freeSlotNum < 1 then
			local email = offlineMgr:createEamil()
			local emailConfigId = 42
			email:setDescId(emailConfigId)
			email:insertProto(tonumber(tRecord.q_id), tonumber(tRecord.q_num), true)
			offlineMgr:recvEamil(tplayer:getSerialID(), email, 95, 0)
			Operation = true
		else
			Operation = itemMgr:addItem(1, tRecord.q_id, tRecord.q_num, 1, 0, 0, 0, 0)

			--产出物品日志	20150907
			g_logManager:writePropChange(roleSID,1,95,tRecord.q_id,0,tRecord.q_num,1)
		end
	end

	--添加提示
	g_ChatSystem:GetMoneyIntoChat(roleSID, tonumber(tRecord.q_id), tonumber(tRecord.q_num))

	--更新数据库中下一目标奖励的ID值
	if self._TargetReward[tSchool] then
		if Operation then
			--修改目标奖励
			self._TargetReward[tSchool] = nextRecordID
			self:cast2DB()
		else
			nextRecordID = self._TargetReward[tSchool]		--nextRecordID 回退
		end
	end

	local retData = {}
	retData.getResult = Operation
	retData.nextTargetRewardID = nextRecordID
	fireProtoMessage(tplayer:getID(),TARGETREWARD_SC_GET_RET,"GetTargetRewardRetProtocol",retData)	
end