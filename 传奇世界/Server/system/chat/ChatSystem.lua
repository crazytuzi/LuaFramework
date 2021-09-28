--ChatSystem.lua
require "system.chat.ChatConstant"

ChatSystem = class(EventSetDoer, Singleton, Timer)

function ChatSystem:__init()
	self._playerChatTime = {}		--玩家的发言时间记录表
	self._bugleMsg = {}				--小喇叭消息表
	self._worldMsg = {} 			--世界聊天消息表
	self._recentMsg = {}			--最近信息
	self._bugleTime = 0				--发送小喇叭的时间
	self._timerCount = 0 			--定时器计数  		--20160202 检查定时器死循环
	self._privateMsg = {}			--私聊数据
	self._phraseInfo = {}			--短语内容
	self._BagShare = {}
	self._EquipShare = {}		
	self._StoreShare = {}

	self._doer = {
			[CHAT_CS_SENDCHATMSG]		=	ChatSystem.doSendChatMsg,
			[CHAT_CS_CLICKANCHOR]		=	ChatSystem.doClickAnchor,
			[CHAT_CS_GETSTRANGERMSG] 	= 	ChatSystem.doDealStrangerMsg,		--与陌生玩家私聊时获取其信息
			[CHAT_CS_GET_HORSE_MSG] 	= 	ChatSystem.doDealHorseMsg,			--拉取跑馬燈消息
			[CHAT_CS_CALL_MSG] 			= 	ChatSystem.doSendCallMsg,
			[CHAT_CS_SHARE_ITEM]		=	ChatSystem.doShareItem,
			[CHAT_CS_SET_PHRASE]		= 	ChatSystem.doSetPhrase,
			[CHAT_CS_GET_PHRASE]		=	ChatSystem.doGetPhrase,
		}
	g_listHandler:addListener(self)
	
	g_frame:registerMsg(CHAT_CS_CLICKANCHOR)
	gTimerMgr:regTimer(self, 1000, 1000)
	print("ChatSystem Timer ID: ", self._timerID_)
end

function ChatSystem:checkShareInfo()
	local curTick = os.time()
	for i,v in pairs(self._BagShare or {}) do
		for j,k in pairs(v or {}) do
			v[j].times = v[j].times+1
			--if j>0 and curTick-j>ITEM_SHARE_TIME then
			if j>0 and v[j].times>ITEM_SHARE_TIME then
				for m,n in pairs(k.info or {}) do
					if type(n) == "table" then					
						if n.data then
							local LuaMsgBuff = n.data
							LuaMsgBuff:delete()
						end
					end
				end
				if type(v) == "table" then
					v[j] = nil							
					table.remove(v,j)
				end
			end		
		end
	end	

	for i,v in pairs(self._EquipShare or {}) do
		for j,k in pairs(v or {}) do
			v[j].times = v[j].times+1
			if j>0 and v[j].times>ITEM_SHARE_TIME then
				for m,n in pairs(k.info or {}) do
					if n.data then
						local LuaMsgBuff = n.data
						LuaMsgBuff:delete()
					end
				end
				if type(v) == "table" then
					v[j] = nil
					table.remove(v,j)
				end
			end		
		end
	end

	for i,v in pairs(self._StoreShare or {}) do
		for j,k in pairs(v or {}) do
			v[j].times = v[j].times+1
			if j>0 and v[j].times>ITEM_SHARE_TIME then
				for m,n in pairs(k.info or {}) do
					if n.data then
						local LuaMsgBuff = n.data
						LuaMsgBuff:delete()
					end
				end
				if type(v) == "table" then
					v[j] = nil
					table.remove(v,j)
				end
			end		
		end
	end
end

--function ChatSystem:onOneMinute()	
--end

--获取链接数据
function ChatSystem:doClickAnchor(buffer1)
	local params = buffer1:getParams()
	local pbc_string = params[1]
	local dbid = params[2]
	local req, err = protobuf.decode("ClickAnchorProtocol" , pbc_string)
	if not req then
		print('ChatSystem:doClickAnchor '..tostring(err))
		return
	end

	local player = g_entityMgr:getPlayerBySID(dbid)
	if not player then return end
	local roleID = player:getID()

	--local buff = params[1]
	--local roleID = buffer:popInt()
	local tRoleSID = req.targetRoleSID
	local itemID = req.itemID
	local slot = req.slot
	local bagIdx = req.bagIndex
	local Tick = req.timeTick
	
	if 1==bagIdx then
		if not self._BagShare or not self._BagShare[tRoleSID] or not self._BagShare[tRoleSID][Tick] then
			local retData = {}
			retData.param = {}	
			retData.eventId = EVENT_CHAT_SETS
			retData.eCode = CHATERR_ITEM_CHANGED
			retData.mesId = CHAT_SC_CLICKANCHORRET
			fireProtoMessageBySid(dbid, FRAME_SC_MESSAGE, "FrameScMessageProtocol", retData)
			return
		end

		for i,v in pairs(self._BagShare[tRoleSID][Tick].info or {}) do
			if i==slot then
				if v.itemID==itemID and v.data then				
					local retData = {}
					retData.itemInfo = v.data:popPbc()
					fireProtoMessageBySid(dbid,CHAT_SC_CLICKANCHORRET,"ClickAnchorRetProtocol",retData)
					return
				else
					local retData = {}
					retData.param = {}	
					retData.eventId = EVENT_CHAT_SETS
					retData.eCode = CHATERR_ITEM_CHANGED
					retData.mesId = CHAT_SC_CLICKANCHORRET
					fireProtoMessageBySid(dbid, FRAME_SC_MESSAGE, "FrameScMessageProtocol", retData)					
					return
				end
				return
			end			
		end
	elseif 3== bagIdx then
		if not self._EquipShare or not self._EquipShare[tRoleSID] or not self._EquipShare[tRoleSID][Tick] then
			local retData = {}
			retData.param = {}	
			retData.eventId = EVENT_CHAT_SETS
			retData.eCode = CHATERR_ITEM_CHANGED
			retData.mesId = CHAT_SC_CLICKANCHORRET
			fireProtoMessageBySid(dbid, FRAME_SC_MESSAGE, "FrameScMessageProtocol", retData)
			return
		end

		for i,v in pairs(self._EquipShare[tRoleSID][Tick].info or {}) do
			if i==slot then
				if v.itemID==itemID and v.data then
					local retData = {}
					retData.itemInfo = v.data:popPbc()			
					fireProtoMessageBySid(dbid,CHAT_SC_CLICKANCHORRET,"ClickAnchorRetProtocol",retData)

					---local retBuff = g_buffMgr:getLuaRPCEvent(CHAT_SC_CLICKANCHORRET)
					--retBuff:append(v.data)
					--g_engine:fireClientEvent(hGate, dbid, retBuff)
					return
				else
					local retData = {}
					retData.param = {}
					retData.eventId = EVENT_CHAT_SETS
					retData.eCode = CHATERR_ITEM_CHANGED
					retData.mesId = CHAT_SC_CLICKANCHORRET
					fireProtoMessageBySid(dbid, FRAME_SC_MESSAGE, "FrameScMessageProtocol", retData)
					return
				end
			end			
		end
	elseif 2==bagIdx then
		if not self._StoreShare or not self._StoreShare[tRoleSID] or not self._StoreShare[tRoleSID][Tick] then
			local retData = {}
			retData.param = {}	
			retData.eventId = EVENT_CHAT_SETS
			retData.eCode = CHATERR_ITEM_CHANGED
			retData.mesId = CHAT_SC_CLICKANCHORRET
			fireProtoMessageBySid(dbid, FRAME_SC_MESSAGE, "FrameScMessageProtocol", retData)
			return
		end

		for i,v in pairs(self._StoreShare[tRoleSID][Tick].info or {}) do
			if i==slot then
				if v.itemID==itemID and v.data then
					local retData = {}
					retData.itemInfo = v.data:popPbc()			
					fireProtoMessageBySid(dbid,CHAT_SC_CLICKANCHORRET,"ClickAnchorRetProtocol",retData)
					return
				else
					local retData = {}
					retData.param = {}	
					retData.eventId = EVENT_CHAT_SETS
					retData.eCode = CHATERR_ITEM_CHANGED
					retData.mesId = CHAT_SC_CLICKANCHORRET
					fireProtoMessageBySid(dbid, FRAME_SC_MESSAGE, "FrameScMessageProtocol", retData)
					return
				end
			end
		end
	else
	end
end

function ChatSystem:pullRecentMsg(player)
	--发送最近世界消息
	local recentSize = self._recentMsg and #self._recentMsg or 0
	if recentSize > 0 then
		local retData = {}
		retData.recentMsg = {}
		retData.recentMsgSize = recentSize
		for i= 1, recentSize do
			local tmpMsg = self._recentMsg[i]
			local recentMsgInfo = {}
			recentMsgInfo.roleSID = tmpMsg[1]
			recentMsgInfo.roleName = tmpMsg[2]
			recentMsgInfo.message = tmpMsg[3]
			recentMsgInfo.vip = tmpMsg[5] 				--VIP等级
			recentMsgInfo.title = tmpMsg[7] 			--增加Title
			table.insert(retData.recentMsg, recentMsgInfo)
		end
		fireProtoMessage(player:getID(),CHAT_SC_SENDRECMSG,"SendRecentMsgProtocol",retData)
	end
end

function ChatSystem:onPlayerLoaded(player)
	if player then	
		self:pullRecentMsg(player)
		--g_entityDao:loadRole(player:getSerialID(), "chat")
	end
end

--玩家下线
function ChatSystem:onPlayerOffLine(player)
	if player then	
		local roleSID = player:getSerialID()
		--存入数据库
		self:cast2DB(roleSID)
		--清除私聊数据
		self._privateMsg[player:getSerialID()] = nil
		if self._phraseInfo[roleSID] then
			self._phraseInfo[roleSID] = nil
		end
	end	
end

--切换出world的通知 
function ChatSystem:onSwitchWorld2(roleID, peer, dbid, mapID)
	local player = g_entityMgr:getPlayer(roleID)
	if player then
		local roleSID = player:getSerialID()

		local luaBuf = g_buffMgr:getLuaEventEx(LOGIN_WW_SWITCH_WORLD)
		luaBuf:pushInt(dbid)
		luaBuf:pushShort(EVENT_CHAT_SETS)
		--具体数据跟在后面
		luaBuf:pushString(serialize(self._phraseInfo[roleSID]))
		g_engine:fireSwitchBuffer(peer, mapID, luaBuf)
	end	
end

--切换到本world的通知
function ChatSystem:onPlayerSwitch(player, type, luabuf)
	if type == EVENT_CHAT_SETS then
		if not player then return end
		local roleSID = player:getSerialID()

		if luabuf:size() > 0 then
			self._phraseInfo[roleSID] = unserialize(luabuf:popString())			
		end		
	end
end

--加载私聊内容
function ChatSystem.onLoadRoleChat(roleID, msgStr)
	local self = ChatSystem.getInstance()
	local dataTab = {}
	for w in string.gmatch(msgStr, "[%&]-([^%&]+)") do
		table.insert(dataTab, w)
	end

	local tid = tonumber(dataTab[1])			--静态ID
	if not tid then return end

	local tp = g_entityMgr:getPlayerBySID(tid)
	local tmpData = {}
	if tp then
		table.insert(tmpData, true)
	else
		table.insert(tmpData, false)
	end
	table.insert(tmpData, dataTab[2])	--名字
	table.insert(tmpData, tonumber(dataTab[3]))	--性别
	table.insert(tmpData, tonumber(dataTab[4]))	--职业
	table.insert(tmpData, tonumber(dataTab[5]))	--等级
	table.insert(tmpData, tonumber(dataTab[6]))	--VIP等级
	table.insert(tmpData, tonumber(dataTab[7]))	--战斗力
	table.insert(tmpData, tonumber(dataTab[8]))	--titleID
	local msgNum = tonumber(dataTab[9]) or 0 	--消息条数
	tmpData.msg = {}
	local num = 9
	if msgNum > 10 then msgNum = 10	end
	for i=1, msgNum do
		local chatData = {}
		table.insert(chatData, dataTab[num+1])	--发送者名字
		table.insert(chatData, dataTab[num+2])	--消息内容
		num = num+2
		local anchors
		anchors, num = self:readAnchor(dataTab, num)
		table.insert(chatData, anchors)
		table.insert(tmpData.msg, chatData)		--连接数据数目？
	end
	self._privateMsg[roleID] = self._privateMsg[roleID] or {}
	local roleChatData = self._privateMsg[roleID]
	roleChatData.tids = roleChatData.tids or {}

	table.insert(roleChatData.tids, tid)
	table.insert(roleChatData, tid, tmpData)
	roleChatData.updateSign = false
end

--反转链接表
--tab为数据表,i为链接开始的下标-1
function ChatSystem:readAnchor(tab, i)
	local anchor = {}
	return anchor, i+1
end

--链接转存数据库字符串
function ChatSystem:anchor2str(anchor)
	return "0&"
end

--校验玩家是否可以发言
function ChatSystem:_verifyPlayerState(channel, player, nowTime)
	--获取CD 时间
	local level = player:getLevel()
	if channel == Channel_ID_World and level < CHAT_WORLD_LEVEL then 
		return false, CHATERR_WORLD_LEVEL, 1, {CHAT_WORLD_LEVEL}
	end
	local cdTab = {}
	if level > 35 then
		cdTab = CHAT_CD_TIME[2]
	else
		cdTab = CHAT_CD_TIME[1]
	end

	local roleSID = player:getSerialID()
	--验证是否禁言 小喇叭不需要判断  --channel ~= Channel_ID_World or 
	if channel ~= Channel_ID_Privacy and channel ~= Channel_ID_System and channel ~= Channel_ID_Bugle then  --Channel_ID_Bugle
		if -1 == player:getSpeakTick() then
			return false, CHATERR_BESILENT_EVER, 1, {player:getSilentReason() or ""}
		end
		if tonumber(nowTime) <= player:getSpeakTick() then
			local silentData = os.date("%Y-%m-%d %H:%M:%S", player:getSpeakTick())			
			return false, CHATERR_BESILENT, 2, {player:getSilentReason() or "", silentData}
		end
	end

	--获取玩家的聊天时间表
	local roleChatTime = self._playerChatTime[roleSID] or {}
	local preTime = roleChatTime[channel] or 0
	if nowTime - preTime >= cdTab[channel] then
		return true
	else
		return false, CHATERR_CHAT_INCD, 1, {cdTab[channel] - nowTime + preTime}
	end
end

--发送提示消息
function ChatSystem:fireMessage(mesID, roleIDs, eventID, eCode, paramCnt, params)
	local retData = {}
	retData.param = {}	
	retData.eventId = eventID
	retData.eCode = eCode
	retData.mesId = mesID
	--retData.paramCnt = paramCnt or 0
	for i=1, #params do
		table.insert(retData.param, params[i])
	end
	for k,v in pairs(roleIDs) do
		--g_engine:fireLuaEvent(v, buffer)
		fireProtoMessage(v,FRAME_SC_MESSAGE,"FrameScMessageProtocol",retData)
	end
end

--聊天
function ChatSystem:doSendChatMsg(event)
	local params = event:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]
	local strBuff = pbc_string

	local req, err = protobuf.decode("SendChatProtocol", strBuff)
	if not req then
		print('ChatSystem:doSendChatMsg '..tostring(err))
		return
	end

	--处理翻译
	if #req.fileid > 0  then
		--print("------apollovoice:settype-"..tostring(g_gameSetMgr:getRoleGameSetValue(roleSID,GAME_SET_VOICE_V2W)))
		--print("------apollovoice:nettype-"..g_tFactionVoiceMgr:GetUserNetInfo(roleSID))
		-- if g_tFactionVoiceMgr:GetUserNetInfo(roleSID) ~= "WIFI" then	
		-- 	if g_gameSetMgr:getRoleGameSetValue(roleSID,GAME_SET_VOICE_V2W) == 0 then
		-- 		self:funSendChatMsg(roleSID,strBuff);
		-- 		return;
		-- 	end	
		-- end
		g_tFactionVoiceMgr:TranslateVoiceMsg(roleSID,pbc_string)
		return
	end
	self:funSendChatMsg(roleSID,strBuff);
end

function ChatSystem.OnAppCall_ChatMsg(roleSID,strBuff,Errno)
	g_ChatSystem:retSendChatMsg(roleSID,strBuff,Errno);
end


--实时翻译回调接口
function ChatSystem:retSendChatMsg(roleSID,strBuff,Errno)
	if Errno ~= 0 then
		self:fireMessage(CHAT_CS_SENDCHATMSG, {player:getID()}, EVENT_CHAT_SETS, CHATERR_TRANSLATE_TIMEOUT, 0, {})
		return
	end
	self:funSendChatMsg(roleSID,strBuff);
end


--聊天
function ChatSystem:funSendChatMsg(roleSID,strBuff)
	local req, err = protobuf.decode("SendChatProtocol", strBuff)
	if not req then
		print('ChatSystem:doSendChatMsg111 '..tostring(err))
		return
	end
	
	local channel = req.channel or 0
	local message = req.message or ""
	local fileid = req.fileid or ""
	local voicelen = req.voicelen or 0

	if channel<=0 then return end
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end
	local roleID = player:getID()
	local roleName = player:getName()

	local nowTime = os.time()
	if #message > MSG_MAX_LENGTH then
		self:fireMessage(CHAT_CS_SENDCHATMSG, {roleID}, EVENT_CHAT_SETS, CHATERR_MAX_LENGTH, 0, {})		
		return
	end
	--条件判断
	local flag, eCode, paramNum, errParam = self:_verifyPlayerState(channel, player, nowTime)
	if not flag then
		self:fireMessage(CHAT_CS_SENDCHATMSG, {roleID}, EVENT_CHAT_SETS, eCode, paramNum, errParam)
		return
	end

	local vip = 0
	if channel == Channel_ID_Team then			--队伍频道
		local teamID = 0
		local memInfo = g_TeamPublic:getMemInfoBySID(roleSID)
		if memInfo then
			teamID = memInfo:getTeamID()
		end

		if teamID>0 then
			local retbuff = self:getComMsgBuffer(roleSID, roleName, vip, message, channel, false, "", 0, 0, {}, fileid, voicelen)
			g_TeamPublic:SendToTeamMem(teamID,retbuff)
			g_tlogMgr:TlogSecTalkFlow(player, 3, message)
		else
			--没有加入队伍提示
			self:fireMessage(CHAT_CS_SENDCHATMSG, {roleID}, EVENT_CHAT_SETS, CHATERR_NOT_INTEAM, 0, {})
		end
	elseif channel == Channel_ID_System then    --系统频道
		return
		--local retData = self:getComMsgBuffer(roleSID, roleName, vip, message, channel, false, "", 0, 0, {}, fileid, voicelen)
		--boardProtoMessage(CHAT_SC_RECEIVEMSG,"ReceiveMsgProtocol",retData)
	elseif channel == Channel_ID_Area then		--区域频道
		local buffer = self:getComMsgBuffer(roleSID, roleName, vip, message, channel, false, "", 0, 0, {}, fileid, voicelen)
		boardSceneProtoMessage(player:getSceneID(),CHAT_SC_RECEIVEMSG,"ReceiveMsgProtocol",buffer)
		--g_engine:broadSceneEvent(player:getMapID(), buffer)
		g_tlogMgr:TlogSecTalkFlow(player, 4, message)
	elseif channel == Channel_ID_Faction then	--帮会频道
		local factionID = player:getFactionID()
		if factionID > 0 then
			--发给所有成员
			local retbuff = self:getComMsgBuffer(roleSID, roleName, vip, message, channel, false, "", 0, 0, {}, fileid, voicelen)
			--g_factionMgr:send2AllMem(sender, retbuff) CHAT_SC_RECEIVEMSG,"ReceiveMsgProtocol",retData
			local faction = g_factionMgr:getFaction(factionID)
			if not faction then return end
			local allFacMem = faction:getAllMembers()
			local allMem = {}
			for k,v in pairs(allFacMem) do
				if v:getActiveState() then				
					table.insert(allMem, v:getRoleSID())
				end
			end
			fireProtoMessageToGroup(allMem, CHAT_SC_RECEIVEMSG, 'ReceiveMsgProtocol',retbuff)
			g_tlogMgr:TlogSecTalkFlow(player, 2, message)
		else
			--没有帮会提示
			self:fireMessage(CHAT_CS_SENDCHATMSG, {roleID}, EVENT_CHAT_SETS, CHATERR_NOT_INFACTION, 0, {})
		end
	elseif channel == Channel_ID_Bugle then		-- 小喇叭
		local eCode = 0
		local itemMgr = player:getItemMgr()
		if not itemMgr then return end
		local num = itemMgr:getItemCount(BUGLE_ITEMID)
		if not isMatEnough(player, BUGLE_ITEMID, 1) then
		--if num<1 then
			self:fireMessage(CHAT_CS_SENDCHATMSG, {roleID}, EVENT_CHAT_SETS, CHATERR_HAS_NO_BUGLE, 0, {})
			return
		end

		costMat(player, BUGLE_ITEMID, 1, 115, 1)
		self:fireMessage(CHAT_CS_SENDCHATMSG, {roleID}, EVENT_ITEM_SETS, Item_OP_Result_ReduceItem, 1, {'[传音号角]X1'})

		--聊天信息
		local chatInfo = {roleSID, roleName, vip, message, false, channel, fileid, voicelen}
		table.insert(self._bugleMsg, chatInfo)

		--存储最近消息
		self._recentMsg = self._recentMsg or {}
		if #self._recentMsg >= MAX_MSG_STORE then
			table.remove(self._recentMsg, 1)
		end
		table.insert(self._recentMsg, {roleSID, roleName, message, {}, vip, player:getbattle(), 0, fileid, voicelen})
		g_tlogMgr:TlogSecTalkFlow(player, 6, message)
	elseif channel == Channel_ID_World then 	--世界频道
		--聊天信息
		local chatInfo = {roleSID, roleName, vip, message, false, channel,req.fileid,req.voicelen}
		table.insert(self._worldMsg, chatInfo)

		--存储最近消息
		self._recentMsg = self._recentMsg or {}
		if #self._recentMsg >= MAX_MSG_STORE then
			table.remove(self._recentMsg, 1)
		end
		table.insert(self._recentMsg, {roleSID, roleName, message, {}, vip, player:getbattle(), 0, fileid, voicelen})
		g_tlogMgr:TlogSecTalkFlow(player, 5, message)
	elseif channel == Channel_ID_Privacy then	--私聊频道		
		local tName = req.targetName or ""
		if roleName == tName then
			self:fireMessage(CHAT_CS_SENDCHATMSG, {roleID}, EVENT_CHAT_SETS, CHATERR_INPUT_ERR, 0, {})
			return
		end

		local tRoleSID = 0
		local tplayerOnline = false
		local targetPlayer = g_entityMgr:getPlayerByName(tName)
		if targetPlayer then
			tplayerOnline = true
			tRoleSID = targetPlayer:getSerialID()
		end

		if tplayerOnline then
			g_relationMgr:addMeet(roleID, tRoleSID)  		--第一个是玩家动态ID，第二个是熟人静态ID
			g_relationMgr:addMeet(targetPlayer:getID(), roleSID)  	--第一个是玩家动态ID，第二个是熟人静态ID

			--添加数据给player
			local buffer2 = self:getComMsgBuffer(roleSID, player:getName(), vip, message, channel, false, tName, 0, 0, {}, fileid, voicelen)
			fireProtoMessage(roleID,CHAT_SC_RECEIVEMSG,"ReceiveMsgProtocol",buffer2)
			fireProtoMessageBySid(tRoleSID, CHAT_SC_RECEIVEMSG,"ReceiveMsgProtocol",buffer2)
			g_tlogMgr:TlogSecTalkFlow(player, 1, message, targetPlayer)

			--给双方发送对方的信息
			local privateBuf = {}
			privateBuf.roleSID = tRoleSID
			privateBuf.roleSchool = targetPlayer:getSchool()
			privateBuf.roleLevel = targetPlayer:getLevel()
			privateBuf.roleName = targetPlayer:getName()
			privateBuf.roleRelation = 3
			if g_relationMgr:isFriend(roleID, tRoleSID) then
				privateBuf.roleRelation = 1
			end
			if g_relationMgr:isEnemy(roleID, tRoleSID) then
				privateBuf.roleRelation = 2
			end
			fireProtoMessageBySid(roleSID,CHAT_SC_PRIVATE_INFO,"PrivateOtherInfo",privateBuf)

			local tRoleID = targetPlayer:getID()
			privateBuf.roleSID = roleSID
			privateBuf.roleSchool = player:getSchool()
			privateBuf.roleLevel = player:getLevel()
			privateBuf.roleName = roleName
			privateBuf.roleRelation = 3
			if g_relationMgr:isFriend(tRoleID, roleSID) then
				privateBuf.roleRelation = 1
			end
			if g_relationMgr:isEnemy(tRoleID, roleSID) then
				privateBuf.roleRelation = 2
			end
			fireProtoMessageBySid(tRoleSID,CHAT_SC_PRIVATE_INFO,"PrivateOtherInfo",privateBuf)
		else
			self:fireMessage(CHAT_CS_SENDCHATMSG, {roleID}, EVENT_CHAT_SETS, CHATERR_PLAYER_OFFLINE, 0, {})
		end
	end

	self._playerChatTime[roleSID] = self._playerChatTime[roleSID] or {}
	self._playerChatTime[roleSID][channel] = nowTime
end

--清除角色在服务器缓存的聊天消息
function ChatSystem:clearMsgBySID(roleSID)
	if roleSID <= 0 then return end
	--处理小喇叭
	local msgNum = table.size(self._bugleMsg)
	if msgNum > 0 then
		for i=msgNum,1,-1 do
			local roleSIDTmp = self._bugleMsg[i][1]
			if roleSIDTmp == roleSID then
				table.remove(self._bugleMsg, i)
			end
		end
	end

	--处理世界聊天
	msgNum = table.size(self._worldMsg)
	if msgNum > 0 then
		for i=msgNum,1,-1 do
			local roleSIDTmp = self._worldMsg[i][1]
			if roleSIDTmp == roleSID then
				table.remove(self._worldMsg, i)
			end
		end
	end

	--处理服务器存储的最近的三十条聊天消息
	msgNum = table.size(self._recentMsg)
	if msgNum > 0 then
		for i=msgNum,1,-1 do
			local roleSIDTmp = self._recentMsg[i][1]
			if roleSIDTmp == roleSID then
				table.remove(self._recentMsg, i)
			end
		end
	end
	
	--广播协议给客户端
	local retbuff = {}
	retbuff.roleSID = roleSID
	retbuff.roleName = ""
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		retbuff.roleName = player:getName()
	end
	boardProtoMessage(CHAT_SC_CLEAR_MSG, "ClearChatMsgProtocol", retbuff)
end

--小喇叭消息处理
function ChatSystem:dealBugleMsg()
	--处理小喇叭
	local nowTime = os.time()
	if table.size(self._bugleMsg) > 0 and nowTime - self._bugleTime >= BUGLE_REGTIME then
		self._bugleTime = os.time()
		local sendMsg = table.size(self._bugleMsg)
		if sendMsg > ONCE_SEND_BUGLE then
			sendMsg = ONCE_SEND_BUGLE
		end

		for i=1,sendMsg do
			local chatInfo = self._bugleMsg[i]
			local retbuff = self:getComMsgBuffer(chatInfo[1] or 0, chatInfo[2] or "", chatInfo[3] or 0, chatInfo[4] or "", chatInfo[6] or 5, false, "", 0, 0, {}, chatInfo[7], chatInfo[8])  		--Channel_ID_Bugle
			--g_engine:broadWorldEvent(retbuff)
			boardProtoMessage(CHAT_SC_RECEIVEMSG, "ReceiveMsgProtocol", retbuff)
		end
		for i=1,sendMsg do
			table.remove(self._bugleMsg, sendMsg+1 - i)
		end
	end

	--处理世界聊天
	if table.size(self._worldMsg) > 0 then
		local sendMsg = table.size(self._worldMsg)
		if sendMsg > ONCE_SEND_WORLD then
			sendMsg = ONCE_SEND_WORLD
		end

		for i=1,sendMsg do
			local chatInfo = self._worldMsg[i]
			local retbuff = self:getComMsgBuffer(chatInfo[1] or 0, chatInfo[2] or "", chatInfo[3] or 0, chatInfo[4] or "", chatInfo[6] or 5, false, "", 0, 0, {}, chatInfo[7], chatInfo[8])  		--Channel_ID_Bugle
			--g_engine:broadWorldEvent(retbuff)
			boardProtoMessage(CHAT_SC_RECEIVEMSG, "ReceiveMsgProtocol", retbuff)
		end
		for i=1,sendMsg do
			table.remove(self._worldMsg, sendMsg+1 - i)
		end
	end
end

function ChatSystem:update()	
	self:dealBugleMsg()

	self._timerCount = self._timerCount + 1
	if self._timerCount%5 == 0 then
		self._timerCount = 0
		self:checkShareInfo()
	end
end

--与陌生玩家私聊时获取其信息  通过 世界聊天界面  点击名字 右键私聊
function ChatSystem:doDealStrangerMsg(buffer)
	local params = buffer:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]				--发起聊天者静态ID

	local req, err = protobuf.decode("GetStrangerMsgProtocol", pbc_string)
	if not req or not req.targetName then
		print('ChatSystem:doDealStrangerMsg 01'..tostring(err))
		return
	end
	local targetName = req.targetName or ""

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then		
		local tPlayer = g_entityMgr:getPlayerByName(targetName)
		if not tPlayer then
			--self:fireMessage(CHAT_CS_GETSTRANGERMSG, {player:getID()}, EVENT_CHAT_SETS, CHATERR_PLAYER_OFFLINE, 0)
			g_SpillFlowerMgr:LoadOffPlayerData(roleSID,targetName)
			return
		end

		local retData = {}		
		retData.online = true 						--对方在线
		retData.targetRoleSID = tPlayer.dbid 		--对方的静态ID
		retData.targetName = targetName 			--对方名字
		retData.targetSex = tPlayer.sex 			--对方性别
		retData.targetSchool = tPlayer.school 		--对方职业
		retData.targetLevel = tPlayer.level 		--对方等级
		retData.targetVip = tPlayer.vip 			--对方VIP等级
		retData.targetBattle = tPlayer.battle   	--对方战斗力
		fireProtoMessage(player:getID(),CHAT_SC_SENDSTRANGERMSG,"SendStrangerMsgProtocol",retData)
	end	
end

function ChatSystem:doDealHorseMsg(buffer)			--客户端拉取跑马灯信息
	local params = buffer:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		print("ChatSystem:doDealHorseMsg no player")
		return
	end

	local req, err = protobuf.decode("CreateFaction" , pbc_string)
	if not req then
		print('ChatSystem:doDealHorseMsg '..tostring(err))
		return
	end

	local roleID = player:getID()
	g_dealLoopMsg:notify2Client(roleID)
end

function ChatSystem:doSendCallMsg(buffer1)
	local params = buffer1:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]
	local req, err = protobuf.decode("CallMsgProtocol" , pbc_string)
	if not req then
		print('ChatSystem:doSendCallMsg'..tostring(err))
		return
	end
	local channel = req.channel
	local message = req.message
	--local roleSID = buff:popInt()
	local area = req.area
	local callType = req.callType
	local paramNum = #req.callParams 		--req.paramNum
	local paramList = {}

	for i = 1, paramNum or 0 do		
		paramList[i] = req.callParams[i]
	end

	local player = g_entityMgr:getPlayerBySID(roleSID)

	if player then
		
		--判断是否大于发言时间间隔
		local nowTime = os.time()
		local flag, eCode, paramNums, errParam = self:_verifyPlayerState(channel, player, nowTime)
		if not flag then
			self:fireMessage(CHAT_CS_SENDCHATMSG, {player:getID()}, EVENT_CHAT_SETS, eCode, paramNums, errParam)
			return
		end

		local buffer = self:getComMsgBuffer(roleSID, player:getName(), 0, message, channel, false, "", callType, paramNum, paramList,"",0)
		if Channel_ID_Area==channel then
			--g_engine:broadSceneEvent(player:getMapID(), buffer)
			boardSceneProtoMessage(player:getSceneID(), CHAT_SC_RECEIVEMSG, "ReceiveMsgProtocol", buffer)
		elseif Channel_ID_Privacy == channel then
			local count = 0
			for _,rId in pairs(req.targetRoleId) do
				if count>4 then
					break
				end
				fireProtoMessageBySid(rId,CHAT_SC_RECEIVEMSG, "ReceiveMsgProtocol", buffer)
				count = count+1
			end
		else
			--g_engine:broadWorldEvent(buffer)
			if callType > 0 then
				--组队喊人不仅广播给世界玩家
				boardProtoMessage(CHAT_SC_RECEIVEMSG, "ReceiveMsgProtocol", buffer)
				--同时发送到区域频道
				local buffer2 = self:getComMsgBuffer(roleSID, player:getName(), 0, message, Channel_ID_Area, false, "", callType, paramNum, paramList,"",0)
				boardSceneProtoMessage(player:getSceneID(), CHAT_SC_RECEIVEMSG, "ReceiveMsgProtocol", buffer2)
			end
		end

		local retData = {}
		retData.callMsgRet = true
		retData.channel = channel
		fireProtoMessage(player:getID(),CHAT_SC_CALL_RET,"CallMsgRetProtocol",retData)
		self._playerChatTime[roleSID] = self._playerChatTime[roleSID] or {}
		self._playerChatTime[roleSID][channel] = nowTime
	end
end

--组建 CHAT_SC_RECEIVEMSG 协议内容
function ChatSystem:getComMsgBuffer(roleSid, roleName, vip, msg, channel, showname, targetName, callType, paramNum, paramList,fileid,voicelen)
	local retData = {}	
	retData.callParams = {}
	retData.channel = channel  			--频道
	retData.message = msg 				--聊天内容
	retData.roleSID = roleSid 			--说话人静态ID
	retData.roleName = roleName 		--说话人名字
	retData.showname = showname 		--是否显示说话人名字
	retData.vip = vip 					--vip等级
	retData.curBattle = 0 				--当前战力
	retData.title = 0 					--王帮皇帮
	retData.targetName = targetName 	--对方名字  (对谁说的)
	retData.callType = callType 		--喊人类型
	retData.paramNum = paramNum 		--附加参数个数
	for i = 1, paramNum do
		table.insert(retData.callParams, paramList[i])
	end	
	retData.fileid = fileid or ""
	retData.voicelen = voicelen or 0
	return retData
end

function ChatSystem:getSystemMsgBuffer(type1,msg,eventID,tipsID,paramsCount,params)
	local retData = {}
	retData.params = {}
	retData.type = type1
	retData.message = msg or ""
	retData.timeTick = tonumber(os.time())
	retData.eventID = eventID
	retData.tipsID = tipsID
	retData.paramNUm = paramsCount
	for i=1, paramsCount do
		table.insert(retData.params, tostring(params[i]) or "")
	end
	return retData
end

function ChatSystem:doShareItem(event)
	local params = event:getParams()
	local pbc_string = params[1]
	local dbid = params[2]
	local req, err = protobuf.decode("ShareItemProtocol", pbc_string)
	if not req then
		print('ChatSystem:doShareItem '..tostring(err))
		return
	end

	local roleSID = dbid
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end
	local itemMgr = player:getItemMgr()
	if not itemMgr then return end

	local count = req.shareCount
	local PublicSvr = FACTION_DATA_SERVER_ID or 1
	if #req.itemInfo>0 then		
		local ShareBuffAll = {}
		for i,v in pairs(req.itemInfo or {}) do
			local itemInfoTmp = v
			local itemIDTmp = itemInfoTmp.itemID
			local slotTmp = itemInfoTmp.slot
			local bagIndexTmp = itemInfoTmp.bagIndex
			local TickTmp = itemInfoTmp.timeTick

			local shareTmp ={itemID=itemIDTmp,slot=slotTmp,bagIndex=bagIndexTmp,tick=TickTmp}
			table.insert(ShareBuffAll, shareTmp)
		end

		for i,v in pairs(ShareBuffAll or {}) do
			if v.slot and v.bagIndex and v.itemID and v.tick then
				local item = itemMgr:findItem(v.slot, v.bagIndex)
				if item and item:getProtoID() == v.itemID then
					local itembuff = LuaMsgBuffer:new()
					itemMgr:writeItem4lua(itembuff, v.slot, v.bagIndex)
					self:doAddShareData(roleSID,v.itemID,v.bagIndex,v.slot,v.tick,itembuff)
				end
			end			
		end
	end
end

function ChatSystem:doAddShareData(roleSID,itemID,bagIndex,slot,Tick,buffData)
	local sharebuff = LuaMsgBuffer:new()
	sharebuff:append(buffData)

	if 1==bagIndex and self._BagShare then
		if not self._BagShare[roleSID] then
			self._BagShare[roleSID] = {}
		end

		self._BagShare[roleSID][Tick] = {}
		self._BagShare[roleSID][Tick].times = 0
		self._BagShare[roleSID][Tick].info = {}
		local TmpShare = self._BagShare[roleSID][Tick].info
		TmpShare[slot] = {}
		TmpShare[slot].itemID = itemID
		TmpShare[slot].data = sharebuff		
	elseif 3==bagIndex and self._EquipShare then
		if not self._EquipShare[roleSID] then
			self._EquipShare[roleSID] = {}
		end

		self._EquipShare[roleSID][Tick] = {}
		self._EquipShare[roleSID][Tick].times = 0
		self._EquipShare[roleSID][Tick].info = {}
		local TmpShare = self._EquipShare[roleSID][Tick].info
		TmpShare[slot] = {}
		TmpShare[slot].itemID = itemID
		TmpShare[slot].data = sharebuff
	elseif 2==bagIndex and self._StoreShare then
		if not self._StoreShare[roleSID] then
			self._StoreShare[roleSID] = {}
		end

		self._StoreShare[roleSID][Tick] = {}
		self._StoreShare[roleSID][Tick].times = 0
		self._StoreShare[roleSID][Tick].info = {}
		local TmpShare = self._StoreShare[roleSID][Tick].info
		TmpShare[slot] = {}
		TmpShare[slot].itemID = itemID
		TmpShare[slot].data = sharebuff
	else
	end
end

function ChatSystem:CallTestMsg(roleSID,roleName,vip,message,channel)
	local buffer2 = self:getComMsgBuffer(roleSID, roleName, vip, message, channel, false, roleName, 0, 0, {}, "", 0)
	fireProtoMessageBySid(roleSID, CHAT_SC_RECEIVEMSG, "ReceiveMsgProtocol", buffer2)

	--local buffer = self:getComMsgBuffer(roleSID, roleName, vip, message, channel, false, "", 0, 0, {})
	--g_engine:broadWorldEvent(buffer)
end

function ChatSystem:doSystemChat(roleID, words, tRoleIDs, Channel)
	--如果频道不填 默认为系统频道
	if not Channel then
		Channel = Channel_ID_System
	end

	if not words then return end
	local online = false
	local role = g_entityMgr:getPlayer(roleID)	--说话的人	动态ID
	if role then online = true end

	local retData = {}
	retData.callParams = {}
	retData.channel = Channel
	retData.message = words
	retData.roleSID = role and role:getSerialID() or 0
	retData.roleName = role and role:getName() or ""
	retData.showname = online
	retData.vip = 0
	retData.curBattle = 0  									--当前战力
	retData.title = 0 										--王帮皇帮
	retData.targetName = ""
	retData.callType = 0 									--喊人类型
	retData.paramNum = 0

	if tRoleIDs then
		for k,v in pairs(tRoleIDs or {}) do
			--g_engine:fireLuaEvent(v, buffer)
			fireProtoMessage(v,CHAT_SC_RECEIVEMSG,"ReceiveMsgProtocol",retData)
		end
	else
		boardProtoMessage(CHAT_SC_RECEIVEMSG, "ReceiveMsgProtocol", retData)
		--g_engine:broadWorldEvent(buffer)
	end
end
--g_ChatSystem:doSendSystemMsg(2,"",EVENT_PUSH_MESSAGE,SPILLFLOWER_BROAD_MSG_ID,3, {RoleName,ToRoleName,Message})

--客户端提示表消息进入系统频道
function ChatSystem:SystemMsgIntoChat(roleSID,type1,msg,eventID,tipsID,paramsCount,params)
	local retData = self:getSystemMsgBuffer(type1,msg,eventID,tipsID,paramsCount,params)
	if roleSID ~= "" then
		local player = g_entityMgr:getPlayerBySID(roleSID)
		if player then
			fireProtoMessageBySid(roleSID, CHAT_SC_SYSTEM_MSG, "SystemMsgProtocol", retData)
		end
	else
		--g_engine:broadWorldEvent(buffer)
		boardProtoMessage(CHAT_SC_SYSTEM_MSG, "SystemMsgProtocol", retData)
	end
end

function ChatSystem:SpeMsgIntoChat(channel,msg,eventID,tipsID,params,roleSID,tRoleSID)
	if Channel_ID_Privacy == channel then
		local player = g_entityMgr:getPlayerBySID(roleSID)
		if not player then return end
		
		local tPlayer = g_entityMgr:getPlayerBySID(tRoleSID)
		if not tPlayer then return end

		local buffer = self:getComMsgBuffer(roleSID, player:getName(), 0, msg, channel, false, tPlayer:getName(), 0, 0, {},"",0)
		fireProtoMessageBySid(roleSID,CHAT_SC_RECEIVEMSG,"ReceiveMsgProtocol",buffer)
		fireProtoMessageBySid(tRoleSID, CHAT_SC_RECEIVEMSG,"ReceiveMsgProtocol",buffer)
	end
end

--查询系统状态  返回的一些信息
function ChatSystem:QueryMsgIntoChat(roleSID, param)
	self:SystemMsgIntoChat(roleSID,2,"",EVENT_PUSH_MESSAGE,103,1,{param})
end

function ChatSystem:GetMoneyIntoChat(roleSID, itemID, itemNum)
	--添加提示
	if 999998 == itemID or 888888 == itemID or 222222 == itemID then
		local retData = {}
		retData.type = 2
		retData.value = itemID
		retData.num = itemNum
		fireProtoMessageBySid(roleSID, FRAME_SC_PICKUP, "FramePickUpRetProtocol", retData)

		local params = {Type = 1, ItemID = itemID, ItemNum = itemNum}
		g_ChatSystem:DropMsgIntoChat(roleSID,serialize(params))
	end
end

function ChatSystem.GetMoney2Chat(roleSID, itemID, itemNum)
	g_ChatSystem:GetMoneyIntoChat(roleSID, itemID, itemNum)
end

function ChatSystem:DropMsgIntoChat(roleSID,param)
	local paramTmp = unserialize(param)
	local ItemNum = paramTmp.ItemNum or 1
	if paramTmp.ItemID and paramTmp.ItemID>0 then
		local itemProto = g_entityMgr:getConfigMgr():getItemProto(paramTmp.ItemID)
		if itemProto then
			local ItemName = itemProto.name or ""
			local ItemColor = itemProto.defaultColor or 1			
			local MsgTmp = paramTmp.Msg or ""
			local MsgType = 0
			if #MsgTmp<=0 then
				MsgType = 2
			else
				MsgType = 1
			end
			
			if MsgType<=0 then return end
			if not paramTmp.Type then return end
			
			if 1== paramTmp.Type then				
				--捡到东西
				local msgIndex = ItemColor+4
				if 2==MsgType then
					self:SystemMsgIntoChat(roleSID,MsgType,MsgTmp,1,msgIndex,2,{ItemName,ItemNum})
				end
			elseif 2==paramTmp.Type then				
				--爆出东西
				local msgIndex = ItemColor+9
				if 2==MsgType then
					self:SystemMsgIntoChat(roleSID,MsgType,MsgTmp,1,msgIndex,2,{ItemName,ItemNum})
				end
			elseif 3==paramTmp.Type then
				--掉落东西 16 17 g_engine:broadSceneEvent(player:getMapID(), buffer)
				local playerTmp = g_entityMgr:getPlayerBySID(roleSID)
				if not playerTmp then return end
				local curMapID = playerTmp:getSceneID()

				local msgIndex = 0
				if 4==ItemColor then
					msgIndex = 16
				elseif 5==ItemColor then
					msgIndex = 17
				else
				end
				if msgIndex<=0 then return end
				
				local MapID = paramTmp.MapID or 0
				if MapID<=0 then return end
				
				if 2==MsgType then
					local retData = self:getSystemMsgBuffer(MsgType,"",1,msgIndex,2,{ItemName, ItemNum})
					boardSceneProtoMessage(curMapID, CHAT_SC_SYSTEM_MSG, "SystemMsgProtocol", retData)
				end
			else
			end
		end
	end
end

function ChatSystem.DropMsg2Chat(roleSID,param)
	g_ChatSystem:DropMsgIntoChat(roleSID,param)
end

function ChatSystem:doSetPhrase(event)
	local params = event:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]
	local req, err = protobuf.decode("SetPhraseProtocol" , pbc_string)
	if not req then
		print('ChatSystem:doSetPhrase '..tostring(err))
		return
	end

	local index = req.index
	local phrase = req.phrase
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end

	if index>PHRASE_MAX_INDEX then return end
	if #phrase>PHRASE_MAX_LEN*4 then return end

	if not self._phraseInfo[roleSID] then
		self._phraseInfo[roleSID] = Phrase_Old
	end
	self._phraseInfo[roleSID][index] = phrase	
	--存入数据库
	self:cast2DB(roleSID)

	local retData = {}
	retData.phraseInfo = {}
	retData.phraseCount = PHRASE_MAX_INDEX
	if not self._phraseInfo[roleSID] then
		for i,v in pairs(Phrase_Old or {}) do
			table.insert(retData.phraseInfo, v)
		end
	else
		for i,v in pairs(self._phraseInfo[roleSID] or {}) do
			table.insert(retData.phraseInfo, v)
		end
	end
	fireProtoMessage(player:getID(),CHAT_SC_GET_PHRASE_RET,"GetPhraseRetProtocol",retData)
end

function ChatSystem:doGetPhrase(event)
	local params = event:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]
	local req, err = protobuf.decode("GetPhraseProtocol" , pbc_string)
	if not req then
		print('ChatSystem:doGetPhrase '..tostring(err))
		return
	end

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end

	local retData = {}
	retData.phraseInfo = {}
	retData.phraseCount = PHRASE_MAX_INDEX
	if not self._phraseInfo[roleSID] then
		for i,v in pairs(Phrase_Old or {}) do
			table.insert(retData.phraseInfo, v)
		end
	else
		for i,v in pairs(self._phraseInfo[roleSID] or {}) do
			table.insert(retData.phraseInfo, v)
		end
	end
	fireProtoMessage(player:getID(),CHAT_SC_GET_PHRASE_RET,"GetPhraseRetProtocol",retData)
end

--数据库加载回调
function ChatSystem.loadDBData(player, cacha_buf, roleSid)
	g_ChatSystem:loadDBDataImpl(player, cacha_buf, roleSid)
end

--数据库加载回调
function ChatSystem:loadDBDataImpl(player, cacha_buf, roleSid)
	if not player then return end
	local roleSID = player:getSerialID()
	if not self._phraseInfo[roleSID] then
		self._phraseInfo[roleSID] = Phrase_Old
	end

	local data = unserialize(cacha_buf)
	self._phraseInfo[roleSID] = data.p or Phrase_Old
end

function ChatSystem:cast2DB(roleSID)
	local dbStr = {p=self._phraseInfo[roleSID]}
	local cache_buf = serialize(dbStr)
	g_engine:savePlayerCache(roleSID, FIELD_ROLECHAT, cache_buf, #cache_buf)	
end

function ChatSystem.getInstance(buffer1)
	return ChatSystem()
end

g_ChatSystem = ChatSystem.getInstance()
g_eventMgr:addEventListener(ChatSystem.getInstance())
