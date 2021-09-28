--SpillFlowerManager.lua
--/*-----------------------------------------------------------------
--* Module:  SpillFlowerManager.lua
--* Author:  liucheng
--* Modified: 2015年6月1日
--* Purpose: Implementation of the class SpillFlowerManager
-------------------------------------------------------------------*/
require "system.spillflower.SpillFlowerInfo"

SpillFlowerManager = class(nil, Singleton, Timer)

function SpillFlowerManager:__init()
	self._flowerActive = 1
	self._arrowActive = 1
	self._sendOffDataToRank = false 		--是否发送离线数据给排行榜
	self._useArrowInfo = {}
	self._mapDBInfo = {}
	self._user = {}
	self._flowerCfg = {}
	self._offLineInfo = {}
	self._offLineOperator = {}				--A 给 B送花  [A]=B.name  查看离线资料
	self._offLinePlayerMiniInfo = {}
	self._offGiveFlowerInfo = {}			--A 给 B送花  [A]={B.name}
	self._fieldMapInfo = {} 				--记录此地图是不是野外地图

	self:loadFlowerDB()
	self:loadMapDB()
	g_listHandler:addListener(self)
	gTimerMgr:regTimer(self,3000,1000)
	print("SpillFlowerManager Timer ID: ", self._timerID_)
end

function SpillFlowerManager:loadMapDB()
	local records = require "data.MapDB"
	for _, record in pairs(records) do
		if record then
			local mapID = tonumber(record.q_map_id or 0)
			local canEnterIn = tonumber(record.xianzhiEnter or 0)
			self._mapDBInfo[mapID] = canEnterIn

			if record.q_Is_yewai then
				self._fieldMapInfo[mapID] = tonumber(record.q_Is_yewai)
			end
		end
	end
end

function SpillFlowerManager:loadFlowerDB()
	local tmpData = require "data.GiveflowerDB"
	if tmpData then
		for i=1, #tmpData do
			local data = tmpData[i]
			if data.q_style then
				self._flowerCfg[data.q_style] = data
			end
		end
	end
end

--玩家上线
function SpillFlowerManager:onPlayerLoaded(player)
	if not player then return end
	local UID = player:getID()
	local SID = player:getSerialID()

	local user = self:getUserInfo(SID)
	if not user then
		user = SpillFlowerInfo(UID, SID)
		self._user[SID] = user
	end
	
	--通知公共服玩家上线
	--if g_spaceID == 0 or g_spaceID == SPILLFLOWER_PUBLIC_SPACE then
	if g_SpillFlowerPublic then
		g_SpillFlowerPublic:SendOffData(PLAYER_LOGIN,SID,0)
	end
end

--玩家下线
function SpillFlowerManager:onPlayerOffLine(player)
	if not player then return end
	local UID = player:getID()
	local SID = player:getSerialID()
	
	if self._user[SID] then
		local user = self._user[SID]
		if user then
			user:cast2DB()
		end
		self._user[SID] = nil
	end
end

--切换出world的通知
function SpillFlowerManager:onSwitchWorld2(roleID, peer, dbid, mapID)
	local player = g_entityMgr:getPlayer(roleID)
	if not player then return end
	local roleSID = player:getSerialID()
	
	local User = self:getUserInfo(roleSID)
	if User then
		User:switchOut(peer, dbid, mapID)
	end
end

--切换到本world的通知
function SpillFlowerManager:onPlayerSwitch(player, type, luabuf)
	if type == EVENT_SPILLFLOWER_SETS then
		if not player then return end		
		local UID = player:getID()
		local SID = player:getSerialID()
		
		local User = self:getUserInfo(SID)		--没有将会新建
		if not User then
			--如果没有，则创建新的信息
			User = SpillFlowerInfo(UID, SID)			
		end

		if User then
			self._user[SID] = User
			User:switchIn(luabuf)
		end
	end
end

function SpillFlowerManager.loadDBData(player, cacha_buf, roleSid)
	g_SpillFlowerMgr:loadDBDataImpl(player, cacha_buf, roleSid)
end

--数据库加载回调
function SpillFlowerManager:loadDBDataImpl(player, cacha_buf, roleSid)
	if not player then return end
	local roleSID = player:getSerialID()
	local roleID = player:getID()

	local User = self:getUserInfo(roleSID)
	if not User then
		User = SpillFlowerInfo(roleID, roleSID)
		self._user[roleSID] = User
	end
	
	if not User then return end

	local data = unserialize(cacha_buf)
	User:loadDBData(data)
end

function SpillFlowerManager:getFlowerInfo(Type)
	return self._flowerCfg[Type]
end

function SpillFlowerManager:getUserInfo(SID)
	return self._user[SID]
end

function SpillFlowerManager:canGiveFlower(player,Type,giveNum)
	if not player then return false end
	local roleSID = player:getSerialID()

	local user = self:getUserInfo(roleSID)
	if not user then return false end

	local flowerInfo = self:getFlowerInfo(Type)
	if not flowerInfo then return false end

	if 1==Type then
		if not giveNum or giveNum<=0 then 
			return false 
		end
		--判断道具数目
		local itemMgr = player:getItemMgr()
		if not itemMgr then return false end
		local count = itemMgr:getItemCount(BASIC_FLOWER_ITEM_ID)
		if count < giveNum then 
			local ItemTmp = itemMgr:findItemByItemID(BASIC_FLOWER_ITEM_ID)
			self:sendErrMsg2Client(roleID, EVENT_ITEM_SETS, -32, 1, {ItemTmp:getName() or ""})
			return false
		end
	else
		if 0 == user:getGiveTime(Type) then
			if 3 == Type or 4 == Type then
				if 3 == flowerInfo.q_costType then 			--元宝送花
					--local curIngot = player:getIngot()
					--if curIngot<tonumber(flowerInfo.q_costValue) then
					if not isIngotEnough(player, tonumber(flowerInfo.q_costValue)) then
						self:sendErrMsg2Client(player:getID(),EVENT_RELATION_SETS,RELATION_ERR_YUANBAO_NOT_ENOUGH,0,{})
						return false
					end
				elseif 2 == flowerInfo.q_costType then
					if player:getBindIngot() < tonumber(flowerInfo.q_costValue) then
						self:sendErrMsg2Client(player:getID(), EVENT_RELATION_SETS, RELATION_ERR_BINDYUANBAO_NOT_ENOUGH, 0, {})
						return false
					end
				else
				end
			end
		else
			--同类型的花每天只能赠送一次
			self:sendErrMsg2Client(player:getID(),EVENT_RELATION_SETS,SPILLFLOWER_ERR_TIMES_LIMIT,0,{})
			return false
		end
	end
	return true
end

--玩家请求获取剩余赠花次数
function SpillFlowerManager:getRemainFlowerNum(player)
	if not player then return end
	local roleID = player:getID()
	local roleSID = player:getSerialID()

	local user = self:getUserInfo(roleSID)
	if not user then return end

	local retData = {}
	--判断道具数目
	local firstFlower = 1
	local itemMgr = player:getItemMgr()
	if not itemMgr then return end
	local count = itemMgr:getItemCount(BASIC_FLOWER_ITEM_ID)
	if count > 0 then firstFlower = 0  end

	retData.firstFlowerNum = firstFlower
	--retData.firstFlowerNum = user:getGiveTime(1)
	retData.secondFlowerNum = user:getGiveTime(2)
	retData.thirdFlowerNum = user:getGiveTime(3)
	retData.fourthFlowerNum = user:getGiveTime(4)
	fireProtoMessage(roleID,RELATION_SC_GETREMAINFLOWERNUM_RET,"GetRemainFlowerRetProtocol",retData)
end

function SpillFlowerManager:GiveFlower(player,targetSid,targetName,giveType,giveNum)
	if ""==targetName then
		print("SpillFlowerManager:GiveFlower name is Null")
		return
	end

	if not player then return end
	local roleID = player:getID()
	local roleSID = player:getSerialID()

	if player:getName() == targetName then
		self:sendErrMsg2Client(roleID,EVENT_RELATION_SETS,SPILLFLOWER_ERR_TO_SELF,0,{})
		return
	end

	--送花等级 24
	if player:getLevel()<SPILLFLOWER_LEVEL_LIMIT then
		self:sendErrMsg2Client(roleID,EVENT_RELATION_SETS,SPILLFLOWER_ERR_LEVEL_LIMIT,0,{})
		return
	end

	if not self:canGiveFlower(player,giveType,giveNum) then 
		return 
	end

	local tplayerTmp = g_entityMgr:getPlayerByName(targetName)
	if tplayerTmp then
		targetSid = tplayerTmp:getSerialID()
		local targetSex = tplayerTmp:getSex()
		local targetLevel = tplayerTmp:getLevel()
		local targetBattle = tplayerTmp:getbattle()
		local targetInfo = {tSID = targetSid, tSex = targetSex, tName = targetName, tLevel = targetLevel, tBattle = targetBattle}
		self:dealGiveFlower(player,targetInfo,giveType,giveNum)
	else
		self:LoadOffPlayerData(0,targetName)
		--g_entityDao:loadOffGiveFlower(5)
		--self:loadGiveFlowerOffData(targetSid)
		local tmp = {}
		tmp.uid = roleID
		tmp.tName = targetName
		tmp.giveType = giveType
		tmp.giveNum = giveNum
		self._offGiveFlowerInfo[roleID] = tmp
	end
end

function SpillFlowerManager:dealGiveFlower(player,targetInfo,giveType,giveNum)
	if not player then return end
	local roleID = player:getID()
    local roleSID = player:getSerialID()

	local flowerInfo = self:getFlowerInfo(giveType)
	if not flowerInfo then return end
	if not targetInfo.tSID or not targetInfo.tName or not targetInfo.tSex or not targetInfo.tLevel or not targetInfo.tBattle then 
		return 
	end
	
	if 1 == giveType or 2 == giveType then
		self:dealGiveFlowerThen(player,targetInfo,giveType,giveNum)
		return
	elseif 3 == giveType or 4 == giveType then
		local gCostValue = tonumber(flowerInfo.q_costValue) or 0
		if gCostValue > 0 then
			if 3 == flowerInfo.q_costType then 			--元宝
				local context = {rSID=roleSID, tSID=targetInfo.tSID, tName=targetInfo.tName, tSex=targetInfo.tSex, tLevel=targetInfo.tLevel, tBattle=targetInfo.tBattle, fType=giveType, gNum=giveNum}
				local ret = g_tPayMgr:TPayScriptUseMoney(player,flowerInfo.q_costValue,22,"Ingot give flower",0,0,"SpillFlowerManager.GiveFlowerIngotCallBack", serialize(context)) 
				if ret ~= 0 then
					self:sendErrMsg2Client(roleID, EVENT_COPY_SETS, -57, 0, {})
				end
			elseif 2 == flowerInfo.q_costType then 		--绑定元宝
				if player:getBindIngot() >= gCostValue then
					player:setBindIngot(player:getBindIngot() - gCostValue)
					g_logManager:writeMoneyChange(roleSID,"",4,22,player:getBindIngot(),gCostValue,2)
					self:dealGiveFlowerThen(player,targetInfo,giveType,giveNum)
				end
			else
			end
		end
	else
	end
end

function SpillFlowerManager:dealGiveFlowerThen(player,targetInfo,giveType,giveNum)
	if not targetInfo.tSID or not targetInfo.tName or not targetInfo.tSex or not targetInfo.tLevel or not targetInfo.tBattle then 
		return 
	end

	local targetSid = targetInfo.tSID
	local targetName = targetInfo.tName

	if not player then return false end
	local roleID = player:getID()
	local roleSID = player:getSerialID()
	local roleName = player:getName()

	local gflowerNum = 1 					--本次送了多少朵花
	local flowerInfo = self:getFlowerInfo(giveType)
	if not flowerInfo then return false end
	if flowerInfo.q_giveflowerNum then
		gflowerNum = tonumber(flowerInfo.q_giveflowerNum)
	end
	
	local user = self:getUserInfo(roleSID)
	if not user then return false end

	--处理送花次数
	local curGiveTime = user:getGiveTime(giveType)
	if giveType> 1 then
		user:setGiveTime(giveType,curGiveTime+1)
	end
	g_normalMgr:activeness(roleID, ACTIVENESS_TYPE.FLOWER)

	local tipsID = RELATION_ERR_GIVE_FLOWER_SUCCESS
	local tipsID2 = RELATION_ERR_BEGIVE_FLOWER
	local tipsID3 = RELATION_ERR_BE_SEND_FLOWER
	local addGlamour = gflowerNum 			--本次给对方增加多少魅力值

	if 1==giveType or 2==giveType then
		if 1==giveType then
			--删除道具数目  随机魅力值
			tipsID = RELATION_ERR_GIVE_FLOWER_SUCCESS_2
			tipsID2 = RELATION_ERR_BEGIVE_FLOWER_2
			tipsID3 = RELATION_ERR_BE_SEND_FLOWER_2

			local minGlamour = giveNum or 1
			local maxGlamour = 3*giveNum
			local curGlamour = math.random(0, maxGlamour-minGlamour) + minGlamour
			gflowerNum = giveNum
			addGlamour = curGlamour

			local itemMgr = player:getItemMgr()
			if not itemMgr then return false end
			local errId = 0
			local deleteRet = itemMgr:destoryItem(BASIC_FLOWER_ITEM_ID, giveNum, errId)
			if not deleteRet then return false end

			g_logManager:writePropChange(roleSID,2,22,BASIC_FLOWER_ITEM_ID,0,giveNum,1) 		--没有记录 玫瑰 是绑定的还是不绑定的
		end
	else
		g_PayRecord:Record(player:getID(), -flowerInfo.q_costValue, CURRENCY_INGOT, 10)
		if 4==giveType then
			--特效
			g_SpillFlowerMgr:SpillFlower(player,targetSid,targetName,0,"")
		end
	end

	g_achieveSer:achieveNotify(roleSID, AchieveNotifyType.giveFlower, targetSid, gflowerNum)
	g_masterMgr:giveFlower(roleSID, targetSid, gflowerNum)
	--player:setVital(player:getVital() + flowerInfo.q_getVital)
	--通知任务系统
	g_taskMgr:NotifyListener(player, "onGiveFlower")
	--写入赠花记录
	user:addFlowerRecord(roleName, targetName, giveType, gflowerNum, os.time())
	g_tlogMgr:TlogSendFlowerFlow(player, targetSid, giveType, gflowerNum, targetInfo.tSex, targetInfo.tLevel, targetInfo.tBattle)

	local tRoleMiniInfo ={}
	local tPlayer = g_entityMgr:getPlayerBySID(targetSid)
	if tPlayer then
		print("SpillFlowerManager:dealGiveFlowerThen online",roleID,targetSid,targetName,giveType)
		g_relationMgr:updateFriendFlower(roleSID, targetSid, gflowerNum, 0)
		g_relationMgr:updateFriendFlower(targetSid, roleSID, 0, gflowerNum)

		--增加被送花记录
		local tUser = self:getUserInfo(targetSid)
		if tUser then
			tUser:addFlowerRecord(roleName,tPlayer:getName(),giveType,gflowerNum,os.time())
		else
			print("SpillFlowerManager:dealGiveFlowerThen 03",targetSid)
		end

		--tPlayer:setVital(tPlayer:getVital() + flowerInfo.q_friendGetVital)
		tPlayer:setGlamour(tPlayer:getGlamour() + addGlamour)
		tPlayer:setTotalGlamour(tPlayer:getTotalGlamour() + addGlamour)
		g_RankMgr:onGlamourChanged(tPlayer)		--魅力值改变

		--写个提示通知被赠花的人
		self:sendErrMsg2Client(tPlayer:getID(), EVENT_RELATION_SETS, tipsID2, 2, {roleName, gflowerNum})
		g_ChatSystem:SystemMsgIntoChat(targetSid,2,"",EVENT_RELATION_SETS,tipsID3,2,{roleName, gflowerNum})
	else
		print("SpillFlowerManager:dealGiveFlowerThen offline",roleID,targetSid,targetName,giveType)
		if self._offLinePlayerMiniInfo[targetSid] then
			tRoleMiniInfo = self._offLinePlayerMiniInfo[targetSid]
		end
		g_relationMgr:update2DB(targetSid, roleSID, gflowerNum)

		--if g_spaceID == 0 or g_spaceID == SPILLFLOWER_PUBLIC_SPACE then
		if g_SpillFlowerPublic then
			g_SpillFlowerPublic:AddOffLineData(roleSID,targetSid,gflowerNum,giveType,addGlamour,roleName,targetName,serialize(tRoleMiniInfo))
		end
	end

	--给客户端发送提示消息
	self:sendErrMsg2Client(roleID, EVENT_RELATION_SETS, tipsID, 4, {targetName,gflowerNum,targetName,addGlamour})
	
	local retData = {}
	retData.giveType = giveType
	retData.getGlamour = addGlamour
	fireProtoMessage(roleID,RELATION_SC_GIVEFLOWER_RET,"GiveFlowerRetProtocol",retData)

    --发送各种类型的赠花次数
    self:getRemainFlowerNum(player)
    return true
end

function SpillFlowerManager.GiveFlowerIngotCallBack(roleSID, payRet, money, itemId, itemCount, callBackContext)
	if 0==payRet then
		local context = unserialize(callBackContext)
		local roleSID = context.rSID or 0
		local targetSid = context.tSID or 0
		local targetName = context.tName or 0
		local targetSex = context.tSex or 0
		local targetLevel = context.tLevel or 0
		local targetBattle = context.tBattle or 0
		local giveType = context.fType or 0
		local giveNum = context.gNum or 0

		local player = g_entityMgr:getPlayerBySID(roleSID)
		local targetInfo = {tSID = targetSid, tSex = targetSex, tName = targetName, tLevel = targetLevel, tBattle = targetBattle}
		local ret = g_SpillFlowerMgr:dealGiveFlowerThen(player,targetInfo,giveType,giveNum)
		if ret then
			return TPAY_SUCESS
		end
	end
	return TPAY_FAILED
end

function SpillFlowerManager:getFlowerRecord(player)
	if not player then return end
    local roleSID = player:getSerialID()
	
	local user = self:getUserInfo(roleSID)
	if not user then return end
	
	user:sendFlowerRecord()
end

function SpillFlowerManager:sendErrMsg2Client(roleId, eventID, errId, paramCount, params)
	fireProtoSysMessage(SpillFlowerServlet.getInstance():getCurEventID(), roleId, eventID, errId, paramCount, params)
end

--类似跑马灯消息
function SpillFlowerManager:sendBroad2Client(errId, paramCount, params, roleID)
	local ret = {}
	ret.eventId = EVENT_PUSH_MESSAGE
	ret.eCode = errId
	ret.mesId = XunBaoServlet.getInstance():getCurEventID()
	ret.param = {}
	paramCount = paramCount or 0
	for i=1, paramCount do
		table.insert(ret.param, params[i] and tostring(params[i]) or "")
	end
	boardProtoMessage(FRAME_SC_MESSAGE, "FrameScMessageProtocol", ret)
end

--全服撒花
function SpillFlowerManager:SpillFlower(player,TRoleSID,TRoleName,slotIndex,message)
	if not player then return end
	local roleName = player:getName()

	--广播给全服玩家
	local retData = {}
	retData.sourceID = player:getID()
	retData.sourceName = roleName
	retData.targetSID = TRoleSID
	retData.targetName = TRoleName
	retData.message = message
	boardProtoMessage(SPILLFLOWER_SC_RET, "GiveFlowerNoticeProtocol", retData)
end

--使用穿云箭
function SpillFlowerManager:CallMember(player,slotIndex)
	if not player then return end
	local roleID = player:getID()
	local roleSID = player:getSerialID()
	local RoleName = player:getName()
	local copyID = player:getCopyID()
	local curmapID = player:getMapID()		--6004 竞技场
	local curPos = player:getPosition()
	local activityMap = {6000,6001,6002,6003,6004,7000,7001,7002,7003}
	if copyID>0 then 		--or table.contains(activityMap,curmapID)
		self:sendErrMsg2Client(player:getID(),EVENT_LITTERFUN_SETS,CALL_MEMBER_COPYMAP,0)			--在副本中无法使用此道具
		return
	end

	local factionID = player:getFactionID()
	if not factionID or factionID<=0 then
		self:sendErrMsg2Client(player:getID(),EVENT_LITTERFUN_SETS,CALL_MEMBER_NO_FACTINO,0)		--没有帮会
		return
	end

	--自己是否在驻守
	local isGarrison = g_shaWarMgr:isInHold(roleSID)
	if isGarrison then
		self:sendErrMsg2Client(player:getID(),EVENT_LITTERFUN_SETS,CALL_MEMBER_ERR_STATION,0)
		return
	end

	local nowTime = os.time()
	if not self._useArrowInfo[factionID] then
		self._useArrowInfo[factionID] = {0,0}  		--该行会穿云箭使用时间戳，传送了多少人
	end

	if nowTime-self._useArrowInfo[factionID][1]<CALL_MEMBER_SPACE then
		local leftTime = CALL_MEMBER_SPACE - (nowTime - self._useArrowInfo[factionID][1])
		self:sendErrMsg2Client(player:getID(),EVENT_LITTERFUN_SETS,CALL_MEMBER_IN_CD,1,{leftTime})	--同行会已有人使用
		return
	end
	
	if not self._mapDBInfo[curmapID] or self._mapDBInfo[curmapID]>0 then
		self:sendErrMsg2Client(player:getID(),EVENT_LITTERFUN_SETS,CALL_MEMBER_COPYMAP,0)			
		return
	end

	local itemMgr = player:getItemMgr()
	if not itemMgr then return end

	local item = itemMgr:findItem(slotIndex)
	if not item then						--指定的物品
		--self:fireMessage(ITEM_CS_COMPOUND, {roleID}, EVENT_ITEM_SETS, Item_OP_Result_ItemNotExist, 0)
		return
	end

	local sourceItemID = item:getProtoID()
	local sourceName = item:getName()
	local sourceCnt = item:getCount()
	if sourceCnt<1 or sourceItemID~=ARROW_ITEM_ID then
		return
	end

	local flag=0
	local errcode=0
	flag, errcode = itemMgr:removeBagItem(slotIndex, 1, errcode)
	if not flag then									--去掉原物品个数 失败
		--self:fireMessage(ITEM_CS_COMPOUND, {roleID}, EVENT_ITEM_SETS, errcode, 0)
		return
	end

	self._useArrowInfo[factionID][1] = nowTime
	self._useArrowInfo[factionID][2] = 0
	self:sendErrMsg2Client(player:getID(),EVENT_ITEM_SETS,CALL_MEMBER_SUCC,1,{sourceName})	--使用成功
	
	local roleCurPos = {x=curPos.x,y=curPos.y}
	self:NoticeToMember(roleSID,factionID,curmapID,roleCurPos,RoleName)

	--20150907
	local BindTmp = item:isBinded() and 1 or 0
	g_logManager:writePropChange(roleSID,2,113,sourceItemID,0,1,BindTmp)
	g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.useArrow, 1)
end

function SpillFlowerManager:NoticeToMember(roleSID,factionID,curmapID,roleCurPos,RoleName)
	local faction = g_factionMgr:getFaction(factionID)
	if not faction then return end

	local allFacMem = faction:getAllMembers()
	local allMem = {}
	for k,v in pairs(allFacMem) do
		if v:getActiveState() and v:getRoleSID()~=roleSID then
			if isLeader then 
				if v:hasDroit(FACTION_DROIT.TakeInMember) then
					table.insert(allMem, v:getRoleSID())
				end
			else
				table.insert(allMem, v:getRoleSID())
			end
		end
	end

	local retData = {}
	retData.roleSID = roleSID
	retData.roleName = RoleName
	retData.roleMapID = curmapID
	retData.rolePos = serialize(roleCurPos)
	fireProtoMessageToGroup(allMem, SPILLFLOWER_SC_CALLMEMBER, "NoticeFactionMemProtocol",retData)
	--g_frame:sendMsgToPeerGroupBySid(allMem, buffer1)
	--g_factionMgr:send2AllMem(factionID, buffer1)
end

--传送到玩家身边
function SpillFlowerManager:SendToMember(player,TRoleSID,TRoleMapID,TRolePos)
	if not player then return end
	local RoleID = player:getID()
	local roleSID = player:getSerialID()
	local factionID = player:getFactionID()
	local copyID = player:getCopyID()
	local curmapID = player:getMapID()
	if copyID>0 then --or 6004==curmapID or 7002==curmapID or 6000==curmapID or 6003==curmapID 
		self:sendErrMsg2Client(player:getID(),EVENT_LITTERFUN_SETS,CALL_MEMBER_IN_COPY,0)			--请结束战斗后再支援
		return
	end

	--自己是否在驻守
	local isGarrison = g_shaWarMgr:isInHold(roleSID)
	if isGarrison then
		self:sendErrMsg2Client(player:getID(),EVENT_LITTERFUN_SETS,CALL_MEMBER_ERR_STATION_OUT,0)
		return
	end
	
	if not self._useArrowInfo[factionID] or not self._useArrowInfo[factionID][2] then 
		self:sendErrMsg2Client(player:getID(),EVENT_LITTERFUN_SETS,CALL_MEMBER_ERR_FACTION,0,{})
		print("SpillFlowerManager:SendToMember no data",factionID)
		return 
	end
	if self._useArrowInfo[factionID][2] >= CALL_MEMBER_MAX then
		self:sendErrMsg2Client(player:getID(),EVENT_LITTERFUN_SETS,CALL_MEMBER_ERR_MAX,0,{})
		return
	end	

	--local Tplayer = g_entityMgr:getPlayerBySID(TRoleSID)
	--if not Tplayer then return end
	--local pos = Tplayer:getPosition()
	--local TcurmapID = Tplayer:getMapID()		--6004 竞技场	
	--g_sceneMgr:enterPublicScene(roleID, Tplayer:getMapID(), pos.x, pos.y)
	local curPos = unserialize(TRolePos)
	if g_entityMgr:canEnterIn(RoleID, TRoleMapID, curPos.x, curPos.y) then
		g_sceneMgr:enterPublicScene(RoleID, TRoleMapID, curPos.x, curPos.y)
		self._useArrowInfo[factionID][2] = self._useArrowInfo[factionID][2] + 1
	end
end

function SpillFlowerManager:LoadOffPlayer(data)
	if not data then return end
	local tName = data.name
	if tName then
		--处理获取陌生人信息
		local operatorSID = 0
		for j,k in pairs(self._offLineOperator) do
			if k==tName then
				operatorSID = j
				if operatorSID ~= "" then			--operatorSID>0
					local retData = {}
					retData.online = false 							--对方在线
					retData.targetRoleSID = data.roleID or 0 		--对方的静态ID
					retData.targetName = data.name or "" 			--对方名字
					retData.targetSex = data.sex or 1 				--对方性别
					retData.targetSchool = data.school or 1 		--对方职业
					retData.targetLevel = data.level or 1 			--对方等级
					retData.targetVip = 0 							--对方VIP等级
					retData.targetBattle = data.battle or 1 		--对方战斗力
					fireProtoMessageBySid(operatorSID, CHAT_SC_SENDSTRANGERMSG, "SendStrangerMsgProtocol", retData)				
				end
				self._offLineOperator[j] = 0
				break
			end
		end

		for j,k in pairs(self._offLineOperator) do
			if 0==k then
				self._offLineOperator[j] = nil
			end
		end
		
		if data.roleID then
			if not self._offLinePlayerMiniInfo[data.roleID] then
				self._offLinePlayerMiniInfo[data.roleID] = {}
			end
			self._offLinePlayerMiniInfo[data.roleID].name = data.name or ""
			self._offLinePlayerMiniInfo[data.roleID].school = data.school or 1
			self._offLinePlayerMiniInfo[data.roleID].sex = data.sex or 1
			self._offLinePlayerMiniInfo[data.roleID].level = data.level or 1
			self._offLinePlayerMiniInfo[data.roleID].glamour = data.glamour or 0
		end

		--处理刚才的送花
		for j,k in pairs(self._offGiveFlowerInfo) do
			if k.tName==tName then
				if self._offGiveFlowerInfo[j] then
					local roleID = self._offGiveFlowerInfo[j].uid
					local targetSid = data.roleID or 0
					local targetName = tName
					local targetSex = data.sex or 1
					local targetLevel = data.level or 1
					local targetBattle = data.battle or 1
					local giveType = self._offGiveFlowerInfo[j].giveType
					local giveNum = self._offGiveFlowerInfo[j].giveNum

					local playerTmp = g_entityMgr:getPlayer(roleID)
					local targetInfo = {tSID = targetSid, tSex = targetSex, tName = targetName, tLevel = targetLevel, tBattle = targetBattle}
					self:dealGiveFlower(playerTmp,targetInfo,giveType,giveNum)
					self._offGiveFlowerInfo[j] = nil
				end
				break
			end
		end
	end	
end

function SpillFlowerManager:LoadOffPlayerData(roleSID,name)
	if name then
		--[[local params = {
			{
				_name = name,
				spName = "sp_LoadOffPlayer",
				dataBase = 1,
				sort = "_name",
			}
		}
		local operId =  LuaDBAccess.callDB(params, apiEntry.onloadOffPlayer)]]
		g_entityDao:loadOffPlayer(name)

		if roleSID ~= "" then 			--roleSID>0
			if not self._offLineOperator[roleSID] then
				self._offLineOperator[roleSID] = 0
			end		
			self._offLineOperator[roleSID] = name
		end
	end
end

function SpillFlowerManager:dealOffData(roleSID,dataTmp)
	local User = self:getUserInfo(roleSID)
	if User then
		User:dealOffData(dataTmp)
	end
end

function SpillFlowerManager:getUserArrowInfo(SID)
	return self._useArrowInfo[SID] or 0
end

function SpillFlowerManager:setUserArrowInfo(SID,value)
	if not self._useArrowInfo[SID] then
		self._useArrowInfo[SID] = 0
	end
	self._useArrowInfo[SID] = tonumber(value)
end

function SpillFlowerManager:setFlowerActive(value)
	self._flowerActive = tonumber(value)
end

function SpillFlowerManager:setArrowActive(value)
	self._arrowActive = tonumber(value)
end

function SpillFlowerManager:getFlowerActive()
	return self._flowerActive
end

function SpillFlowerManager:getArrowActive()
	return self._arrowActive
end

function SpillFlowerManager:checkIsFieldMap(mapID)
	if mapID and mapID > 0 then
		if self._fieldMapInfo[mapID] and self._fieldMapInfo[mapID] > 0 then
			return true
		end
	end
	return false
end

--延迟3秒 	把所有的离线魅力值数据都发给排行榜
function SpillFlowerManager:update()
	if g_SpillFlowerPublic then
		if not self._sendOffDataToRank then
			self._sendOffDataToRank = true
			gTimerMgr:unregTimer(self)
			g_SpillFlowerPublic:sendOffDataToRank()
		end
	end
end

function SpillFlowerManager.getInstance()
	return SpillFlowerManager()
end

g_SpillFlowerMgr = SpillFlowerManager.getInstance()