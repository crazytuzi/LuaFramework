--FactionServlet.lua

FactionServlet = class(EventSetDoer, Singleton)

function FactionServlet:__init()
	self._doer = {
			[FACTION_CS_APPLYJOIN] =			FactionServlet.doSendJoinApply,
			[FACTION_CS_CANCEL_APPLY] =			FactionServlet.doCancelApply,
			[FACTION_CS_GETFACTIONINFO]	=		FactionServlet.getFactionInfo,
			[FACTION_CS_CREATEFACTION] =		FactionServlet.doCreateFaction,
			[FACTION_SS_CREATEFACTION] =		FactionServlet.onCreateFaction,
			[FACTION_SS_CREATEFACTION2] =		FactionServlet.onCreateFaction2,
			[FACTION_CS_AGREE_JOIN] =			FactionServlet.doJoinFaction,
			--[FACTION_SS_AGREE_JOIN] =			FactionServlet.onJoinFaction,
			[FACTION_CS_REFUSE_APPLY] =			FactionServlet.doRefuseApply,
			[FACTION_SS_REFUSE_APPLY] =			FactionServlet.onRefuseApply,
			[FACTION_CS_GETAPPLYINFO] =			FactionServlet.doGetApplyInfos,
			[FACTION_CS_GETALLMEMBER] =			FactionServlet.getAllMemberInfo,
			[FACTION_CS_APPOINTPOSITION] =		FactionServlet.doAppointPos,
			[FACTION_CS_LEAVEFACTION] =			FactionServlet.doLeaveFaction,
			[FACTION_SS_LEAVEFACTION] =			FactionServlet.onLeaveFaction,
			[FACTION_CS_REMOVEMEMBER] =		    FactionServlet.doRemoveMember,
			[FACTION_SS_REMOVEMEMBER] =		    FactionServlet.onRemoveMember,
			[FACTION_CS_GETSTOREINFO] =			FactionServlet.doGetStoreInfo,
			[FACTION_CS_EDITCOMMENT] =			FactionServlet.doEditComment,
			[FACTION_CS_CHANGEAUTOJOIN] =		FactionServlet.doChangeAutoJoin,
			[FACTION_CS_GETMSGRECORD] =			FactionServlet.getMsgRecord,	
			[FACTION_CS_GETMYFACTIONDATA] = 	FactionServlet.doGetMyFactionData,	
			[FACTION_SS_LOAD_PLAYER] =			FactionServlet.onLoadPlayer,
			[FACTION_SS_LOAD_PLAYER2] =			FactionServlet.onLoadPlayer2,
			[FACTION_SS_ADDCONTRIBUTION] =		FactionServlet.OnAddContribution,
			[FACTION_CS_ADDSTATUE] =			FactionServlet.doAddStatue,
			[FACTION_CS_GETSTATUERANK] =		FactionServlet.doGetStatueRank,
			[FACTION_CS_GETSTATUERD] =			FactionServlet.doGetStatueRd,

			--ÐÐ»áÍâ½»
			[FACTION_CS_GETSOCIALINFO] =			FactionServlet.getFactionSocialInfo,		--»ñÈ¡Ä³ÐÐ»áÍâ½»ÐÅÏ¢
			[FACTION_CS_SOCIALOPERATOR] =			FactionServlet.reqFactionSocialOperator,	--ÐÐ»áÍâ½»²Ù×÷ÇëÇó
			[FACTION_SS_SOCIALOPERATOR] =			FactionServlet.doFactionSocialOperator,		--ÐÐ»áÍâ½»²Ù×÷ÇëÇó´¦Àí

			--ÐÐ»áÆí¸£
			[FACTION_CS_GETPRAYINFO] =		FactionServlet.getFactionPrayInfo,			--»ñÈ¡ÐÐ»áÆí¸£Êý¾Ý
			[FACTION_CS_PRAY] =			FactionServlet.doFactionPray,

			[FACTION_CS_ENTERAREA] =		FactionServlet.doEnterArea,
			[FACTION_CS_OUTAREA] =			FactionServlet.doOutArea,

			--ÐÐ»á¹«¹²ÈÎÎñ
			[FACTION_CS_GETTASKINFO] =		FactionServlet.getFactionTaskInfo,			--»ñÈ¡ÐÐ»á¹«¹²ÈÎÎñÊý¾Ý

			--ÑûÇëÍæ¼ÒÈë»á
			[FACTION_CS_INVITE_JONE] =      FactionServlet.OnInviteRoleJoin,
			[FACTION_CS_INVITE_JOIN_CHOOSE] = FactionServlet.OnOperatorInvite,

			[FACTION_VOICE_CS_CREATE_ROOM] = FactionServlet.OnFactionVoiceCreateRoom,
			[FACTION_VOICE_CS_JOIN_ROOM] = FactionServlet.OnFactionVoiceJoinRoom,
			[FACTION_VOICE_CS_EXIT_ROOM] = FactionServlet.onFactionVoiceExitRoom,
			[FACTION_VOICE_CS_CLOSE_ROOM] = FactionServlet.onFactionVoiceCloseRoom,


			[FACTION_COMMAND_CS_SET_USERID] = FactionServlet.onSetFactionCommandId,

			[FACTION_OPENID_CS_BIND] = FactionServlet.onBindFactionOpenId,
			[FACTION_OPENID_CS_GET] = FactionServlet.onGetFactionOpenId,
			[FACTION_CS_GET_EVENT_RD] = FactionServlet.onGetEventRd,

			}

			if g_spaceID == 0 or g_spaceID == FACTION_DATA_SERVER_ID then
				g_frame:registerMsg(FACTION_CS_GETFACTIONINFO, false) 
				g_frame:registerMsg(FACTION_CS_GETAPPLYINFO, false) 
				g_frame:registerMsg(FACTION_CS_CANCEL_APPLY, false)
				g_frame:registerMsg(FACTION_CS_OPENCONTRIWIN, false)
				g_frame:registerMsg(FACTION_CS_UPLEVEL, false)
				g_frame:registerMsg(FACTION_CS_PREUPLEVEL, false)
				g_frame:registerMsg(FACTION_CS_GETALLMEMBER, false)
				g_frame:registerMsg(FACTION_CS_GETSTOREINFO, false)
				g_frame:registerMsg(FACTION_CS_EDITCOMMENT, false)
				g_frame:registerMsg(FACTION_CS_CHANGEAUTOJOIN, false)
				g_frame:registerMsg(FACTION_CS_GETMSGRECORD, false)
				g_frame:registerMsg(FACTION_CS_GETMYFACTIONDATA, false)
				g_frame:registerMsg(FACTION_CS_AGREE_JOIN, false)
				g_frame:registerMsg(FACTION_CS_REFUSE_APPLY, false)
				g_frame:registerMsg(FACTION_CS_APPOINTPOSITION, false)
				g_frame:registerMsg(FACTION_CS_LEAVEFACTION, false)
				g_frame:registerMsg(FACTION_CS_REMOVEMEMBER, false)
				g_frame:registerMsg(FACTION_CS_GETSTATUERANK, false)
				g_frame:registerMsg(FACTION_CS_GETSTATUERD, false)

				--ÐÐ»áÍâ½»
				g_frame:registerMsg(FACTION_CS_GETSOCIALINFO, false)
				--ÐÐ»áÆí¸£
				g_frame:registerMsg(FACTION_CS_GETPRAYINFO, false)
				--ÐÐ»á¹«¹²ÈÎÎñ
				g_frame:registerMsg(FACTION_CS_GETTASKINFO, false)

				--ÑûÇëÍæ¼ÒÈë»á
				g_frame:registerMsg(FACTION_CS_INVITE_JONE, false)
				g_frame:registerMsg(FACTION_CS_INVITE_JOIN_CHOOSE, false)

				g_frame:registerMsg(FACTION_OPENID_CS_BIND, false)
				g_frame:registerMsg(FACTION_OPENID_CS_GET, false)
			end
end

--¸ø¿Í»§¶Ë·¢ËÍ´íÎóÌáÊ¾µÄ½Ó¿Ú
function FactionServlet:sendErrMsg2Client(roleId, errId, paramCount, params)
	fireProtoSysMessage(self:getCurEventID(), roleId, EVENT_FACTION_SETS, errId, paramCount, params)
end

--¸ø¿Í»§¶Ë·¢ËÍ´íÎóÌáÊ¾µÄ½Ó¿Ú
function FactionServlet:sendErrMsg2Client2(dbid, hGate, errId, paramCount, params)
	fireProtoSysMessageBySid(self:getCurEventID(), dbid, EVENT_FACTION_SETS, errId, paramCount, params)	
end

--»ñÈ¡×Ô¼ºµÄ°ï»áµÈ¼¶ÒÑ¾­°ï¹±
function FactionServlet:doGetMyFactionData(buffer1)
	local params = buffer1:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("GetMyFactionData" , buffer)
	if not req then
		print('FactionServlet:doGetMyFactionData '..tostring(err))
		return
	end

	local roleID = dbid
	local factionID = req.factionID
	local faction = g_factionMgr:getFaction(factionID)
	if faction then
		local mem = faction:getMember(dbid)
		if mem then
			local ret = {}
			ret.storeLv = faction:getStoreLvl()
			ret.contribution = mem:getContribution()
			fireProtoMessageBySid(dbid, FACTION_SC_GETMYFACTIONDATARET, "GetMyFactionDataRet", ret)
		end
	end
end

--´´½¨°ï»á
function FactionServlet:doCreateFaction(buffer1)
	print('FactionServlet:doCreateFaction')
	local params = buffer1:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("CreateFaction" , buffer)
	if not req then
		print('FactionServlet:doCreateFaction '..tostring(err))
		return
	end
	
	local facName = req.facName
	local cType = req.cType
	local player = g_entityMgr:getPlayerBySID(dbid)
	if player then
		local roleID = player:getID()
		--facName = string.gsub(facName, "[& ]", "")
		local suc, eCode = g_factionMgr:createFaction(player, facName, cType, hGate)
		if not suc then
			self:sendErrMsg2Client(player:getID(), eCode, 0)
			print(''..roleID..' createFaction failed')
		else
			print(''..roleID..' createFaction')
		end
	else
		print(''..roleID..' cannot find')
	end
end

--´´½¨°ï»á
function FactionServlet:onCreateFaction(buffer1)
	print('FactionServlet:onCreateFaction')
	local params = buffer1:getParams()
	print('FactionServlet:onCreateFaction', #params, params[1], params[2], params[3])
	local buffer, serverId = params[1], params[2]
	local dbid = buffer:popString()
	local hGate = buffer:popInt()
	local cType = buffer:popInt()
	local facName = buffer:popString()
	local level = buffer:popInt()
	local playerName = buffer:popString()
	local school = buffer:popInt()
	local sex = buffer:popInt()
	local battle = buffer:popInt()
	local weaponID = buffer:popInt()
	local clothID = buffer:popInt()
	local wingID = buffer:popInt()

	--ÅÐ¶ÏÊÇ·ñÃû×ÖÒÑ±»×¢²á
	local existFac = g_factionMgr:getFactionByName(facName)
	if existFac then
		self:sendErrMsg2Client2(dbid, hGate, FACERR_FACTIONHASEXIST, 0)
		print(''..dbid..' FACERR_FACTIONHASEXIST')
		return
	end

	--¹¹Ôì³ÉÔ±
	local member = FactionMember(dbid)
	member:setFactionID(factionID)
	member:setActiveState(os.time())
	member:setLevel(level)
	member:setName(playerName)
	member:setSchool(school)
	member:setAbility(battle)	--Õ½¶·Á¦
	member:setPosition(FACTION_POSITION.Leader)
	member:setJoinTime(os.time())
	member:setSex(sex)
	member:setWeapon(weaponID)
	member:setUpperBody(clothID)
	member:setWingID(wingID)
	local player = g_entityMgr:getPlayerBySID(dbid)
	if player then
		member:setContribution(player:getContribute())
	end
	local memBuffStr = member:writeString()

	
	--±£´æÁÙÊ±Êý¾Ý
	g_factionMgr:setFacTmpData(dbid, memBuffStr, cType, serverId, facName)
	self:checkUniqueName(serverId, dbid, facName)
end

function FactionServlet:checkUniqueName(serverId, dbid, facName)
	g_commonMgr:insertUniqueName("faction", dbid, facName)
end

function FactionServlet:onCheckUniNameRet(dbid, result)
	print(string.format("Faction check name ret, roleSID=%d, result=%s", dbid, tostring(result)))
	
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not player then
		print("onCheckUniNameRet while player " .. dbid .. "not found!!!")
		return
	end
	if result ~= true then
		g_factionMgr:clearFacTmpData(dbid)
		self:sendErrMsg2Client2(dbid, 0, FACERR_FACTIONHASEXIST, 0)
		print(''..dbid..' FACERR_FACTIONHASEXIST')
		return
	end

	local luaBuf = LuaEventManager:instance():getExchangeLuaBuffer()
	local data = g_factionMgr:getFacTmpData(dbid)
	if not data then
		print("FacTmpData: "..dbid.." not found!")
		return
	end
	luaBuf:pushLString(data.memBuffStr, #data.memBuffStr)
	--g_entityDao:callSpForLua(SPDEF_CREATEFACTION, luaBuf, true)
	local factionid = g_factionMgr:getNewFactionID()
	print(">>>>>>1",factionid)
	g_entityDao:createFaction(SPDEF_CREATEFACTION, factionid, dbid, data.facName, player:getName(), luaBuf, data.cType,g_frame:getWorldId())
	g_factionMgr:deleteRoleApply(dbid)
end


--´´½¨°ï»á
function FactionServlet:onCreateFaction2(buffer1)
	print('FactionServlet:onCreateFaction2')
	local params = buffer1:getParams()
	local buffer, serverId = params[1], params[2]
	local dbid = buffer:popString()
	local factionID = buffer:popInt()
	local factionName = buffer:popString()
	local factionRank = buffer:popInt()
	local cType = buffer:popInt()
	--Tlog[GuildFlow]
	local factionLv = buffer:popChar()
	local factionNum = buffer:popChar()

	local player = g_entityMgr:getPlayerBySID(dbid)
	if player then
		player:setFactionID(factionID)

		--添加BUFF
		local buffmgr = player:getBuffMgr()
		local buffId = g_luaFactionDAO:getBannerBuffId(factionLv)
		buffmgr:addBuff(buffId, 0)


		if buffmgr:isExist(EXIT_FACTION_BUFFID) then
			buffmgr:delBuff(EXIT_FACTION_BUFFID)
		end


		local ret = {}
		ret.result = FACTION_CREATE_SUCCESS
		ret.facName = factionName
		ret.playername = player:getName()
		ret.factionRank = factionRank
		ret.factionID = factionID
		fireProtoMessage(player:getID(), FACTION_SC_CREATEFACTION_RET, 'CreateFactionRet', ret)
		--player:setFactionID(factionID)
		player:setFactionName(factionName)
		self:sendErrMsg2Client(player:getID(), FACTION_CREATE_SUCCESS, 1, {factionName})
		g_factionMgr:deleteRoleApply(dbid)

		g_taskMgr:NotifyListener(player, "onJoinFac")
		g_listHandler:notifyListener("onJoinFaction", player:getID())

		g_factionMgr:NotifyPalyerFactionPosition(dbid)


		g_tlogMgr:TlogGuildFlow(player,1,factionID,factionLv,factionNum)

		if cType == CREATE_MODE.HornCreate then
			local itemMgr = player:getItemMgr()
			itemMgr:destoryItem(CREATE_HORNID, 1, 0) 
			g_logManager:writePropChange(player:getSerialID(), 2 ,47, CREATE_HORNID, 0, 1, 0)

			costMoney(player, CREATE_FACTION_MONEY, 47)
		elseif cType == CREATE_MODE.MoneyCreate then
			local ret = g_tPayMgr:TPayScriptUseMoney(player, CREATE_FACTION_INGOT, 47, "CreateFaction", 0, 0, "FactionServlet.doYuanbaoCreateFaction") 
		end
	end
end

function FactionServlet.doYuanbaoCreateFaction(roleSID, payRet, money, itemId, itemCount, callBackContext)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end
	return true--TPAY_SUCESS
end


--¾Ü¾ø¼ÓÈë°ï»áÉêÇë
function FactionServlet:doRefuseApply(buffer1)
	local params = buffer1:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("RefuseJoinFaction" , buffer)
	if not req then
		print('FactionServlet:doRefuseApply '..tostring(err))
		return
	end

	local factionID = req.factionID
	local roleSID = req.opRoleSID
	if roleSID == 0 then
		--¾Ü¾øËùÓÐ
		self:refuseAll(dbid, hGate, factionID)
	else
		--¾Ü¾øroleSID
		self:refuseOne(roleSID, dbid, hGate, factionID)
	end
end

--¾Ü¾øµ¥¸öÉêÇë
function FactionServlet:refuseOne(roleSID, dbid, hGate, factionID)
	local faction = g_factionMgr:getFaction(factionID)
	if faction then
		if not faction:isInApplyRole(roleSID) then
			--roleSID²»ÔÚÉêÇëÁÐ±íÀïÃæ
			self:sendErrMsg2Client2(dbid, hGate, FACERR_ISIN_APPLY, 0)
			return
		end
		local leaderMem = faction:getMember(dbid)
		--ÊÇ·ñÓÐÈ¨Àû
		local hasDuty = leaderMem:hasDroit(FACTION_DROIT.TakeInMember)
		if hasDuty then
			--É¾³ýÉêÇë¼ÇÂ¼
			--·µ»Ø¸øLeaderID¸üÐÂÃæ°å
			local ret = {}
			ret.opRoleSID = roleSID
			fireProtoMessageBySid(dbid, FACTION_SC_REFUSE_APPLY_RET, "RefuseJoinFactionRet", ret)

			local appCnt = faction:removeApplyRole(roleSID)
			--Í¨Öª°ïÖ÷¸±°ïÖ÷ÉêÇëÈË±ä¶¯
			local ret = {}
			ret.count = appCnt		
			g_factionMgr:sendProtoMsg2AllMem(factionID, FACTION_SC_APPLYCNT_RET, "ApplyCntNotify", ret, true)
			g_factionMgr:removeApply(roleSID, faction:getFactionID())

			--Í¨Öª±»¾Ü¾øÕß
			--ÇÐ»»µ½Íæ¼Ò·þ´¦Àí
			local retBuff = LuaEventManager:instance():getWorldEvent(FACTION_SS_REFUSE_APPLY)
			retBuff:pushString(roleSID)
			retBuff:pushString(faction:getName())
			g_engine:fireWorldEvent(0, retBuff)
		else
			--ÌáÊ¾Ã»ÓÐ²Ù×÷È¨ÏÞ
			self:sendErrMsg2Client2(dbid, hGate, FACERR_NO_DROIT, 0)
		end
	else
		self:sendErrMsg2Client2(dbid, hGate, FACERR_HAS_NO_FACTION, 0)
	end
end

--¾Ü¾øËùÓÐÉêÇë
function FactionServlet:refuseAll(dbid, hGate, factionID)
	local faction = g_factionMgr:getFaction(factionID)
	if faction then
		local leaderMem = faction:getMember(dbid)
		--ÊÇ·ñÓÐÈ¨Àû
		local hasDuty = leaderMem:hasDroit(FACTION_DROIT.TakeInMember)
		if hasDuty then 
			local applyRoles = faction:getAllApplies()
			local refuseTmp = {}
			for roleSID, applyRole in pairs(applyRoles) do
				table.insert(refuseTmp, roleSID)
				applyRoles[roleSID] = nil
				g_factionMgr:removeApply(roleSID, faction:getFactionID())
				--Í¨Öª±»¾Ü¾øÕß
				--ÇÐ»»µ½Íæ¼Ò·þ´¦Àí
				local retBuff = LuaEventManager:instance():getWorldEvent(FACTION_SS_REFUSE_APPLY)
				retBuff:pushString(roleSID)
				retBuff:pushString(faction:getName())
				g_engine:fireWorldEvent(0, retBuff)
			end
			--·µ»Ø¸øLeaderID¸üÐÂÃæ°å
			local ret = {}
			ret.opRoleSID = ""
			fireProtoMessageBySid(dbid, FACTION_SC_REFUSE_APPLY_RET, "RefuseJoinFactionRet", ret)
			--Í¨Öª°ïÖ÷¸±°ïÖ÷ÉêÇëÈË±ä¶¯
			local ret = {}
			ret.count = 0		
			g_factionMgr:sendProtoMsg2AllMem(factionID, FACTION_SC_APPLYCNT_RET, "ApplyCntNotify", ret, true)
		else
			--ÌáÊ¾Ã»ÓÐ²Ù×÷È¨ÏÞ
			self:sendErrMsg2Client2(dbid, hGate, FACERR_NO_DROIT, 0)
		end
	else
		self:sendErrMsg2Client2(dbid, hGate, FACERR_HAS_NO_FACTION, 0)
	end
end

--¾Ü¾øÉêÇë
function FactionServlet:onRefuseApply(buffer1)
	local params = buffer1:getParams()
	local buffer, serverId = params[1], params[2]
	local dbid = buffer:popString()
	local factionName = buffer:popString()

	local player = g_entityMgr:getPlayerBySID(dbid)

	if player then
		self:sendErrMsg2Client(player:getID(), FACERR_APPLY_REFUSED, 1, {factionName})
	end
end

--¼ÓÈë°ï»á
function FactionServlet:doJoinFaction(buffer1)
	local params = buffer1:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("AgreeJoinFaction" , buffer)
	if not req then
		print('FactionServlet:doJoinFaction '..tostring(err))
		return
	end

	local factionID = req.factionID
	local roleSID = req.opRoleSID

	if roleSID == 0 then
		self:agreeAll(dbid, hGate, factionID)
	else
		self:agreeOne(roleSID, dbid, hGate, factionID)
	end
end

--Åú×¼µ¥¸öÉêÇëÕß¼ÓÈë
function FactionServlet:agreeOne(roleSID, dbid, hGate, factionID)
	local faction = g_factionMgr:getFaction(factionID)
	if faction then
		if not faction:isInApplyRole(roleSID) then
			--roleSID²»ÔÚÉêÇëÁÐ±íÀïÃæ
			self:sendErrMsg2Client2(dbid, hGate, FACERR_ISIN_APPLY, 0)
			return
		end
		local leaderMem = faction:getMember(dbid)
		--ÊÇ·ñÓÐÈ¨Àû
		local hasDuty = leaderMem:hasDroit(FACTION_DROIT.TakeInMember)
		if hasDuty then 
			--ÅÐ¶ÏÈËÊý  
			if faction:getAllMemberCnt() >= g_luaFactionDAO:getfacMaxMemNum(faction:getLevel()) then
				--´ïµ½×î´óÈËÊýÌáÊ¾
				self:sendErrMsg2Client2(dbid, hGate, FACERR_MAX_MEMBER, 0)
			else
				g_achieveSer:achieveNotify(roleSID, AchieveNotifyType.joinFation, 1)

				local factionID = faction:getFactionID()
				local applyInfo = faction:getApplyRole(roleSID)
				local player = g_entityMgr:getPlayerBySID(roleSID)

				local newFacMem = FactionMember(roleSID)
				newFacMem:setFactionID(factionID)
				newFacMem:setJoinTime(os.time())
				newFacMem:setName(applyInfo.name)
				newFacMem:setSchool(applyInfo.school)
				newFacMem:setSex(applyInfo.sex)
				newFacMem:setActiveState(os.time())
				newFacMem:setLevel(applyInfo.level)
				newFacMem:setAbility(applyInfo.battle)	--Õ½¶·Á¦
				newFacMem:setWingID(applyInfo.wingID)
				newFacMem:setContribution(applyInfo.contri)

				--ÇÐ»»µ½Íæ¼Ò·þ´¦Àí
				--[[
				local retBuff = LuaEventManager:instance():getWorldEvent(FACTION_SS_AGREE_JOIN)
				retBuff:pushInt(roleSID)
				retBuff:pushInt(factionID)
				retBuff:pushString(faction:getName())
				retBuff:pushInt(faction:getLevel())
				--Tlog[GuildFlow]
				retBuff:pushChar(faction:getLevel())
				retBuff:pushChar(faction:getAllMemberCnt()+1)
				g_engine:fireWorldEvent(0, retBuff)
				]]

				self:onJoinFaction(roleSID,factionID,faction:getName(),faction:getLevel(),faction:getLevel(),faction:getAllMemberCnt()+1)

				

				faction:addFactionMember(newFacMem)
				--¸üÐÂÊý¾Ý¿â
				newFacMem:update2DB(factionID)
				g_factionMgr:clearCache(roleSID)
				
				--Í¬²½Íæ¼ÒÁªÃËÐÐ»áÐÅÏ¢
				g_factionMgr:synFactionPlayerUnionInfo(roleSID,factionID)
				--Í¬²½Íæ¼ÒÐûÕ½ÐÐ»áÐÅÏ¢
				g_factionMgr:synFactionPlayerHostilityInfo(roleSID,factionID)

				--Í¨ÖªËùÓÐ³ÉÔ±ÓÐÈË¼ÓÈë
				--[[local retBuff = LuaEventManager:instance():getLuaRPCEvent(FRAME_SC_MESSAGE)
				retBuff:pushShort(EVENT_FACTION_SETS)
				retBuff:pushShort(FACTION_ADD_NEWMEMBER)
				retBuff:pushShort(FACTION_CS_AGREE_JOIN)
				retBuff:pushChar(1)
				retBuff:pushString(applyInfo.name)
				g_factionMgr:send2AllMem(factionID, retBuff)]]--

				local allret = {}
				allret.eventId = EVENT_FACTION_SETS
				allret.eCode = FACTION_ADD_NEWMEMBER
				allret.mesId = FACTION_CS_AGREE_JOIN
				allret.param = {}
				table.insert(allret.param, applyInfo.name)
				g_factionMgr:sendProtoMsg2AllMem(factionID, FRAME_SC_MESSAGE, "FrameScMessageProtocol", allret)

				faction:addMsgRecord(FACTION_ADD_NEWMEMBER, {applyInfo.name}, {{roleSID, applyInfo.name}, })
				--·µ»Ø¸øLeaderID¸üÐÂÃæ°å
				local ret = {}
				ret.opRoleSID = roleSID
				fireProtoMessageBySid(dbid, FACTION_SC_AGREE_JOIN_RET, "AgreeJoinFactionRet", ret)
				g_factionMgr:deleteRoleApply(roleSID)
				--Í¨Öª°ïÖ÷¸±°ïÖ÷ÉêÇëÈË±ä¶¯
				local applies = faction:getAllApplies()
				local ret = {}
				ret.count = table.size(applies)		
				g_factionMgr:sendProtoMsg2AllMem(factionID, FACTION_SC_APPLYCNT_RET, "ApplyCntNotify", ret, true)
			end
		else
			--ÌáÊ¾Ã»ÓÐ²Ù×÷È¨ÏÞ
			self:sendErrMsg2Client2(dbid, hGate, FACERR_NO_DROIT, 0)
		end
	else
		self:sendErrMsg2Client2(dbid, hGate, FACERR_HAS_NO_FACTION, 0)
	end
end

--Åú×¼ËùÓÐÉêÇëÕß¼ÓÈë
function FactionServlet:agreeAll(dbid, hGate, factionID)
	local faction = g_factionMgr:getFaction(factionID)
	if faction then
		local leaderMem = faction:getMember(dbid)
		--ÊÇ·ñÓÐÈ¨Àû
		local hasDuty = leaderMem:hasDroit(FACTION_DROIT.TakeInMember)
		if hasDuty then
			local factionID = faction:getFactionID()
			local applyRoles = faction:getAllApplies()
			--ÅÐ¶ÏÊÇ·ñ´ïµ½×î´óÈËÊý  
			if table.size(applyRoles) + faction:getAllMemberCnt() > g_luaFactionDAO:getfacMaxMemNum(faction:getLevel()) then
				self:sendErrMsg2Client2(dbid, hGate, FACERR_MAX_MEMBER, 0)
				return
			end
			for roleSID, applyRole in pairs(applyRoles) do
				g_achieveSer:achieveNotify(roleSID, AchieveNotifyType.joinFation, 1)

				local player = g_entityMgr:getPlayerBySID(roleSID)
				local newFacMem = FactionMember(roleSID)
				newFacMem:setFactionID(factionID)
				newFacMem:setJoinTime(os.time())
				newFacMem:setName(applyRole.name)
				newFacMem:setSchool(applyRole.school)
				newFacMem:setSex(applyRole.sex)
				newFacMem:setActiveState(os.time())
				newFacMem:setLevel(applyRole.level)
				newFacMem:setAbility(applyRole.battle)	--Õ½¶·Á¦
				newFacMem:setWingID(applyRole.wingID)
				newFacMem:setContribution(applyRole.contri)

				--ÇÐ»»µ½Íæ¼Ò·þ´¦Àí
				--[[
				local retBuff = LuaEventManager:instance():getWorldEvent(FACTION_SS_AGREE_JOIN)
				retBuff:pushInt(roleSID)
				retBuff:pushInt(factionID)
				retBuff:pushString(faction:getName())
				retBuff:pushInt(faction:getLevel())
				--Tlog[GuildFlow]
				retBuff:pushChar(faction:getLevel())
				retBuff:pushChar(faction:getAllMemberCnt()+1)

				g_engine:fireWorldEvent(0, retBuff)
				]]

				self:onJoinFaction(roleSID,factionID,faction:getName(),faction:getLevel(),faction:getLevel(),faction:getAllMemberCnt()+1)

				faction:addFactionMember(newFacMem)
				newFacMem:update2DB(factionID)
				g_factionMgr:clearCache(roleSID)
				faction:addFactionMember(newFacMem)
				--faction:setMemberSyn(true)
				
				--Í¬²½Íæ¼ÒÁªÃËÐÐ»áÐÅÏ¢
				g_factionMgr:synFactionPlayerUnionInfo(roleSID,factionID)
				--Í¬²½Íæ¼ÒÐûÕ½ÐÐ»áÐÅÏ¢
				g_factionMgr:synFactionPlayerHostilityInfo(roleSID,factionID)

				--Í¨ÖªËùÓÐ³ÉÔ±ÓÐÈË¼ÓÈë
				--[[local retBuff = LuaEventManager:instance():getLuaRPCEvent(FRAME_SC_MESSAGE)
				retBuff:pushShort(EVENT_FACTION_SETS)
				retBuff:pushShort(FACTION_ADD_NEWMEMBER)
				retBuff:pushShort(FACTION_CS_AGREE_JOIN)
				retBuff:pushChar(1)
				retBuff:pushString(newFacMem:getName())
				g_factionMgr:send2AllMem(factionID, retBuff)]]--

				local allret = {}
				allret.eventId = EVENT_FACTION_SETS
				allret.eCode = FACTION_ADD_NEWMEMBER
				allret.mesId = FACTION_CS_AGREE_JOIN
				allret.param = {}
				table.insert(allret.param, newFacMem:getName())
				g_factionMgr:sendProtoMsg2AllMem(factionID, FRAME_SC_MESSAGE, "FrameScMessageProtocol", allret)

				faction:addMsgRecord(FACTION_ADD_NEWMEMBER, {applyRole.name}, {{roleSID, applyRole.name}, })
				g_factionMgr:deleteRoleApply(roleSID)
			end
			
			--·µ»Ø¸øLeaderID¸üÐÂÃæ°å
			local ret = {}
			ret.opRoleSID = ""
			fireProtoMessageBySid(dbid, FACTION_SC_AGREE_JOIN_RET, "AgreeJoinFactionRet", ret)

			--Í¨Öª°ïÖ÷¸±°ïÖ÷ÉêÇëÈË±ä¶¯
			local ret = {}
			ret.count = 0	
			g_factionMgr:sendProtoMsg2AllMem(factionID, FACTION_SC_APPLYCNT_RET, "ApplyCntNotify", ret, true)
		else
			--ÌáÊ¾Ã»ÓÐ²Ù×÷È¨ÏÞ
			self:sendErrMsg2Client2(dbid, hGate, FACERR_NO_DROIT, 0)
		end
	else
		self:sendErrMsg2Client2(dbid, hGate, FACERR_HAS_NO_FACTION, 0)
	end
end

--¼ÓÈë°ï»á´¦Àí
function FactionServlet:onJoinFaction(dbid,factionID,factionName,bannerLvl,factionLv,factionNum)
	--[[
	local params = buffer1:getParams()
	local buffer, serverId = params[1], params[2]
	local dbid = buffer:popInt()
	local factionID = buffer:popInt()
	local factionName = buffer:popString()
	local bannerLvl = buffer:popInt()
	--Tlog[GuildFlow]
	local factionLv = buffer:popChar()
	local factionNum = buffer:popChar()
	]]

	local player = g_entityMgr:getPlayerBySID(dbid)

	if player then
		player:setFactionID(factionID)
		player:setFactionName(factionName)
		
		--Ôö¼Ó°ï»áBUFF
		local buffmgr = player:getBuffMgr()
		local buffId = g_luaFactionDAO:getBannerBuffId(bannerLvl)
		buffmgr:addBuff(buffId, 0)
		--ÌáÊ¾¼ÓÈë³É¹¦
		self:sendErrMsg2Client(player:getID(), FACTION_JOIN_SUCCESS, 1, {factionName})

		--ÌáÊ¾¼ÓÈë³É¹¦
		local ret = {}
		ret.joinResult = 1
		ret.factionID = factionID
		ret.resultCode = FACTION_JOIN_SUCCESS
		fireProtoMessage(player:getID(), FACTION_SC_APPLYJOIN_RET, "ApplyJoinFactionRet", ret)

		--ÈÎÎñÄ¿±êÍ¨Öª
		g_taskMgr:NotifyListener(player, "onJoinFac")
		g_listHandler:notifyListener("onJoinFaction", player:getID())

		--Í¬²½³ÉÔ±ÐÐ»áµÄÖ°¼¶
		g_factionMgr:NotifyPalyerFactionPosition(dbid)

		--Tlog[GuildFlow]
		g_tlogMgr:TlogGuildFlow(player,4,factionID,factionLv,factionNum)
	end
end

--ÉêÇëÈë°ï
function FactionServlet:doSendJoinApply(buffer1)
	print("doSendJoinApply")
	local params = buffer1:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("ApplyJoinFaction" , buffer)
	if not req then
		print('FactionServlet:doSendJoinApply '..tostring(err))
		return
	end

	local factionID = req.factionID
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not player then
		return 
	end

	local roleID = player:getID()

	local facID = player:getFactionID()
	if facID > 0 then
		self:sendErrMsg2Client(roleID, FACERR_HAS_FACTION, 0)
		return
	end
	
	local faction = g_factionMgr:getFaction(factionID)

	if not faction then
		return
	end

	local applyInfo = g_factionMgr:getApplyInfo(dbid)
	--ÒÑ¾­ÉêÇë¹ýÁË
	if applyInfo and applyInfo[factionID] then
		self:sendErrMsg2Client(player:getID(), FACERR_HAS_APPLY, 0)
	--´ïµ½×î´óÉêÇëÊýÁ¿
	elseif table.size(applyInfo) >= FACTION_MAX_APPLY_COUNT then
		self:sendErrMsg2Client(player:getID(), FACERR_MAX_APPLY, 0)
	elseif table.size(faction:getAllApplies()) >= FACTION_MAX_BE_APPLY_COUNT then
		self:sendErrMsg2Client(player:getID(), FACERR_FACTION_MAX_APPLY, 0)
	else 
		if faction:getAllMemberCnt() >= g_luaFactionDAO:getfacMaxMemNum(faction:getLevel()) then
			self:sendErrMsg2Client(player:getID(), FACERR_MAX_MEMBER, 0)
			return
		end
		if faction:getAutoJoin() then	--×Ô¶¯Åú×¼
			local roleSID = dbid
			local newFacMem = FactionMember(roleSID)
			newFacMem:setFactionID(factionID)
			newFacMem:setActiveState(0)
			newFacMem:setLevel(player:getLevel())
			newFacMem:setName(player:getName())
			newFacMem:setSchool(player:getSchool())
			newFacMem:setPosition(FACTION_POSITION.Member)
			newFacMem:setJoinTime(os.time())
			newFacMem:setSex(player:getSex())
			local itemMgr = player:getItemMgr()
			newFacMem:setWeapon(itemMgr:getWeaponID())
			newFacMem:setUpperBody(itemMgr:getClothID())
			newFacMem:setWingID(player:getCurWingID())
			newFacMem:setAbility(player:getbattle())	--Õ½¶·Á¦ 
			newFacMem:setContribution(player:getContribute())
			
			local player = g_entityMgr:getPlayerBySID(roleSID)
			if player then
				newFacMem:setContribution(player:getContribute())	--Íæ¼Ò°ï¹±
				g_achieveSer:achieveNotify(roleSID, AchieveNotifyType.joinFation, 1)
			end
			
			faction:addFactionMember(newFacMem)
			newFacMem:update2DB(factionID)
			g_factionMgr:clearCache(roleSID)

			local allret = {}
			allret.eventId = EVENT_FACTION_SETS
			allret.eCode = FACTION_ADD_NEWMEMBER
			allret.mesId = FACTION_CS_APPLYJOIN
			allret.param = {}
			table.insert(allret.param, newFacMem:getName())
			g_factionMgr:sendProtoMsg2AllMem(factionID, FRAME_SC_MESSAGE, "FrameScMessageProtocol", allret)

			faction:addMsgRecord(FACTION_ADD_NEWMEMBER, {player:getName()}, {{roleSID, player:getName()}, })
			g_factionMgr:deleteRoleApply(roleSID)
			
			g_factionMgr:synFactionPlayerUnionInfo(roleSID,factionID)
			g_factionMgr:synFactionPlayerHostilityInfo(roleSID,factionID)

			


			player:setFactionID(factionID)
			player:setFactionName(faction:getName())


			--Ôö¼Ó°ï»áBUFF
			local buffmgr = player:getBuffMgr()
			local buffId = g_luaFactionDAO:getBannerBuffId(faction:getLevel())
			buffmgr:addBuff(buffId, 0)

			--ÌáÊ¾¼ÓÈë³É¹¦
			local ret = {}
			ret.joinResult = 1
			ret.factionID = factionID
			ret.resultCode = FACTION_JOIN_SUCCESS
			fireProtoMessage(player:getID(), FACTION_SC_APPLYJOIN_RET, "ApplyJoinFactionRet", ret)

			--Í¨ÖªÈÎÎñÄ¿±ê
			g_taskMgr:NotifyListener(player, "onJoinFac")
			g_listHandler:notifyListener("onJoinFaction", player:getID())

			g_factionMgr:NotifyPalyerFactionPosition(roleSID)

			--Tlog[GuildFlow]
			g_tlogMgr:TlogGuildFlow(player,4,factionID,faction:getLevel(),faction:getAllMemberCnt())
		else
			g_factionMgr:addApply(dbid, factionID)
			local appCnt = faction:addApplyRole(dbid, player:getLevel(), player:getName(), player:getSchool(), player:getbattle(), player:getSex(), player:getCurWingID(), player:getContribute())
			--ÉêÇë³É¹¦
			local ret = {}
			ret.joinResult = 0
			ret.factionID = factionID
			ret.resultCode = FACTION_SEND_APPLYSUCCEED
			fireProtoMessageBySid(dbid, FACTION_SC_APPLYJOIN_RET, "ApplyJoinFactionRet", ret)

			local ret = {}
			ret.count = appCnt	
			g_factionMgr:sendProtoMsg2AllMem(factionID, FACTION_SC_APPLYCNT_RET, "ApplyCntNotify", ret, true)
		end
	end
end

--Íæ¼ÒµÇÈë´¦Àí
function FactionServlet:onLoadPlayer(buffer1)
	local params = buffer1:getParams()
	local buffer, serverId = params[1], params[2]
	local dbid = buffer:popString()
	local level = buffer:popInt()
	local playerName = buffer:popString()
	local factionID = buffer:popInt()
	local faction = g_factionMgr:getFaction(factionID)
	
	--Èç¹ûÃ»ÓÐÐÐ»á ²éÕÒÊÇ²»ÊÇÀëÏß¼ÓÈëµÄÐÐ»á
	if not faction then
		local factionlist = g_factionMgr:getAllFactions()
		for facID, fac in pairs(factionlist) do
			if fac:hasMember(dbid) then
				faction = fac
			end
		end
	end
	
	if faction and faction:hasMember(dbid) then
		factionID = faction:getFactionID()
		local myMem = faction:getMember(dbid)
		if myMem then
			if myMem:getRoleSID() == faction:getLeaderID() and myMem:getPosition() ~= FACTION_POSITION.Leader then
				myMem:setPosition(FACTION_POSITION.Leader)
			end

			myMem:setName(playerName)
			myMem:setActiveState(0)
			myMem:setLevel(level)
			local applies = faction:getAllApplies()
			--Èç¹ûÓÐÊÕÈËÈ¨ÏÞ²¢ÇÒÓÐÈËÉêÇëÈë°ïÒªÍ¨Öª
			if table.size(applies) > 0 then
				local ret = {}
				ret.count = table.size(applies)
				g_factionMgr:sendProtoMsg2AllMem(factionID, FACTION_SC_APPLYCNT_RET, "ApplyCntNotify", ret, true)
			end

			local retBuff = LuaEventManager:instance():getWorldEvent(FACTION_SS_LOAD_PLAYER2)
			retBuff:pushString(dbid)
			retBuff:pushInt(factionID)
			retBuff:pushString(faction:getName())
			retBuff:pushInt(faction:getLevel())
			--Tlog[GuildFlow]
			retBuff:pushChar(faction:getLevel())
			retBuff:pushChar(faction:getAllMemberCnt())

			g_engine:fireWorldEvent(serverId, retBuff)


			
			--ÐÐ»áÍâ½»ÐÅÏ¢Íæ¼ÒÉÏÏßÍ¨Öª
			if myMem:getPosition() == FACTION_POSITION.Leader or myMem:getPosition() == FACTION_POSITION.AssociateLeader then
				local notify = false                              
				local factionSocials = g_factionMgr:getFactionSocials(factionID)		--ÓëÐÐ»áÒÑ¾­½¨Á¢¹ØÏµµÄÍâ½»ÐÅÏ¢											
				for _, facSocial in pairs(factionSocials) do
					if facSocial:getState() == SocialState.ApplyUnion and factionID ~= facSocial:getOpFactionID() then
						notify = true
						break
					end
				end
				if notify then
					local msg = LuaEventManager:instance():getLuaRPCEvent(FACTION_SC_SOCIALAPPLYUNION)
					g_engine:fireSerialEvent(dbid, msg)
				end
			end

			--Í¬²½Íæ¼ÒÁªÃËÐÐ»áÐÅÏ¢
			g_factionMgr:synFactionPlayerUnionInfo(dbid,factionID)
			--Í¬²½Íæ¼ÒÐûÕ½ÐÐ»áÐÅÏ¢
			g_factionMgr:synFactionPlayerHostilityInfo(dbid,factionID)

			--ÐÐ»á¹«¹²ÈÎÎñ Íæ¼ÒÉÏÏßÍ¨Öª
			local factionTaskInfo = g_factionMgr:getFactionTaskInfo(factionID)
			if factionTaskInfo then
				local factionTaskMsg = factionTaskInfo:buildFactionTaskMsg(FACTIONTASK_ALLTASK_ID,dbid)
				g_engine:fireSerialEvent(dbid, factionTaskMsg)
			end
			
			--Í¬²½³ÉÔ±ÐÐ»áµÄÖ°¼¶
			g_factionMgr:NotifyPalyerFactionPosition(dbid)

		else
			print("----load player faction err")
		end
	else
		if factionID > 0 then
			local retBuff = LuaEventManager:instance():getWorldEvent(FACTION_SS_LOAD_PLAYER2)
			retBuff:pushString(dbid)
			retBuff:pushInt(0)
			retBuff:pushString("")
			retBuff:pushInt(0)
			--Tlog[GuildFlow]
			retBuff:pushChar(0)
			retBuff:pushChar(0)
			g_engine:fireWorldEvent(serverId, retBuff)
		end
	end
end


--Íæ¼ÒµÇÈë´¦Àí2
function FactionServlet:onLoadPlayer2(buffer1)
	local params = buffer1:getParams()
	local buffer, serverId = params[1], params[2]
	local dbid = buffer:popString()
	local factionID = buffer:popInt()
	local factionName = buffer:popString()
	local bannerLvl = buffer:popInt()
	--Tlog[GuildFlow]
	local factionLv = buffer:popChar()
	local factionNum = buffer:popChar()

	local player = g_entityMgr:getPlayerBySID(dbid)
	if player then
		local oldfacid = player:getFactionID()
		player:setFactionName(factionName)
		player:setFactionID(0)
		player:setFactionID(factionID)
		
		if factionID > 0 then
			--ÊÇÀëÏß¼ÓÈëµÄÐÐ»á
			if oldfacid ~= factionID then
				--Í¨ÖªÈÎÎñÄ¿±ê
				g_taskMgr:NotifyListener(player, "onJoinFac")
				g_listHandler:notifyListener("onJoinFaction", player:getID())

				--Tlog[GuildFlow]
				g_tlogMgr:TlogGuildFlow(player,4,factionID,factionLv,factionNum)
			end

			--Ôö¼Ó°ï»áBUFF
			local buffmgr = player:getBuffMgr()
			local buffId = g_luaFactionDAO:getBannerBuffId(bannerLvl)
			buffmgr:addBuff(buffId, 0)
		end

		--print('FactionServlet:onLoadPlayer2',player:getSerialID(),player:getFactionID(),player:getFactionName())
	end
end


function FactionServlet:OnAddContribution(buffer1)
	local params = buffer1:getParams()
	local buffer, serverId = params[1], params[2]
	local dbid = buffer:popString()
	local factionID = buffer:popInt()
	local num = buffer:popInt()
	local faction = g_factionMgr:getFaction(factionID)

	if not faction then
		return
	end 
	
	local mem = faction:getMember(dbid)
	
	if mem then
		mem:setContribution(mem:getContribution() + num)
		faction:addUpdateMem(dbid)
	end
end

--È¡ÏûÉêÇëÈë°ï
function FactionServlet:doCancelApply(buffer1)
	local params = buffer1:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("CancelApplyJoinFaction" , buffer)
	if not req then
		print('FactionServlet:doCancelApply '..tostring(err))
		return
	end
	local roleID = dbid
	local factionID = req.factionID

	local faction = g_factionMgr:getFaction(factionID)
	if faction then
		local applyInfo = g_factionMgr:getApplyInfo(dbid)
		--Ã»ÓÐÉêÇë¹ý
		if not applyInfo or not applyInfo[factionID] then
			self:sendErrMsg2Client2(dbid, hGate, FACERR_NOT_APPLY, 0)
		else
			g_factionMgr:removeApply(dbid, factionID)
			--ÉêÇë³É¹¦
			local ret = {}
			ret.factionID = factionID
			ret.resultCode = FACTION_CANCEL_APPLYSUCCEED
			fireProtoMessageBySid(dbid, FACTION_SC_CANCEL_APPLY_RET, "CancelApplyJoinFactionRet", ret)
			local appCnt = faction:removeApplyRole(dbid)
			--Í¨Öª°ïÖ÷¸±°ïÖ÷ÉêÇëÈË±ä¶¯
			local ret = {}
			ret.count = appCnt
			g_factionMgr:sendProtoMsg2AllMem(factionID, FACTION_SC_APPLYCNT_RET, "ApplyCntNotify", ret, true)
		end
	end
end

--»ñÈ¡°ï»áÊý¾Ý
--Ã»ÓÐ°ï»áÔò»ñÈ¡ËùÓÐ°ï»áÁÐ±í
function FactionServlet:getFactionInfo(buffer1)
	print("getFactionInfo")
	local params = buffer1:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("GetFactionInfo" , buffer)
	if not req then
		print('FactionServlet:getFactionInfo '..tostring(err))
		return
	end

	local roleID = dbid
	local factionID = req.factionID
	local faction = g_factionMgr:getFaction(factionID)

	if faction then
		local myMem = faction:getMember(dbid)
		if myMem then
			--°ï»áÐÅÏ¢
			local ret = {}
			ret.info = {}
			ret.info.id = faction:getFactionID()		--°ï»áID
			ret.info.lv = faction:getLevel()
			ret.info.bannerlv = faction:getLevel()	--ÆìÖÄµÈ¼¶
			ret.info.storelv = 1	--ÉÌµêµÈ¼¶
			ret.info.name = faction:getName()
			ret.info.leaderName = faction:getLeaderName()
			ret.info.rank = faction:getRank()
			ret.info.allMemberCnt = faction:getAllMemberCnt()
			ret.info.money = faction:getMoney()
			ret.info.Comment = faction:getComment()
			ret.info.facXp = faction:getXp()
			ret.contribution = myMem:getContribution()
			ret.position = myMem:getPosition()
			fireProtoMessageBySid(dbid, FACTION_SC_GETFACTIONINFO_RET, "GetFactionInfoRet", ret)
		else
			--Ã»ÓÐ°ï»á·µ»ØËùÓÐ°ï»áÊý¾Ý
			local ret = {}
			ret.infos = {}
			local allFaction = g_factionMgr:getAllFactions()
			for _, fac in pairs(allFaction) do
				local facinfo = {}
				facinfo.id = fac:getFactionID()
				facinfo.name = fac:getName()
				facinfo.lv = fac:getLevel()
				facinfo.allMemberCnt = fac:getAllMemberCnt()
				facinfo.maxMemberCnt = g_luaFactionDAO:getfacMaxMemNum(fac:getLevel())
				facinfo.totalAbility = fac:getTotalAbility()

				local flag = false --Ö»ÐèÒª°ïÖ÷¸±°ïÖ÷ÔÚÏßµÄ
				local leaderMem = fac:getMember(fac:getLeaderID())
				if leaderMem and leaderMem:getActiveState() == 0 then
					flag = true
				else 
					for _, mem in pairs(fac._factionMembers) do
						if mem:getPosition() == FACTION_POSITION.AssociateLeader and mem:getActiveState() == 0 then
							flag = true
							break
						end
					end
				end
		
				facinfo.leaderOnline = flag and 1 or 0
				facinfo.autoJoin = fac:getAutoJoin() and 1 or 0
				table.insert(ret.infos,facinfo)
			end
			
			ret.applyedFactions = {}
			--»ñÈ¡ÉêÇë°ï»áÁÐ±í
			local applyFacs = g_factionMgr:getApplyInfo(dbid)
			for facID, _ in pairs(applyFacs) do
				table.insert(ret.applyedFactions,facID)
			end
			fireProtoMessageBySid(dbid, FACTION_SC_GETALLFACTION_RET, "GetAllFactionInfoRet", ret)
		end
	else
		--Ã»ÓÐ°ï»á·µ»ØËùÓÐ°ï»áÊý¾Ý
		local ret = {}
		ret.infos = {}
		local allFaction = g_factionMgr:getAllFactions()
		for _, fac in pairs(allFaction) do
			local facinfo = {}
			facinfo.id = fac:getFactionID()
			facinfo.name = fac:getName()
			facinfo.lv = fac:getLevel()
			facinfo.allMemberCnt = fac:getAllMemberCnt()
			facinfo.maxMemberCnt = g_luaFactionDAO:getfacMaxMemNum(fac:getLevel())
			facinfo.totalAbility = fac:getTotalAbility()

			local flag = false --Ö»ÐèÒª°ïÖ÷¸±°ïÖ÷ÔÚÏßµÄ
			local leaderMem = fac:getMember(fac:getLeaderID())
			if leaderMem and leaderMem:getActiveState() == 0 then
				flag = true
			else 
				for _, mem in pairs(fac._factionMembers) do
					if mem:getPosition() == FACTION_POSITION.AssociateLeader and mem:getActiveState() == 0 then
						flag = true
						break
					end
				end
			end
		
			facinfo.leaderOnline = flag and 1 or 0
			facinfo.autoJoin = fac:getAutoJoin() and 1 or 0
			table.insert(ret.infos,facinfo)
		end
		
		ret.applyedFactions = {}
		--»ñÈ¡ÉêÇë°ï»áÁÐ±í
		local applyFacs = g_factionMgr:getApplyInfo(dbid)
		for facID, _ in pairs(applyFacs) do
			table.insert(ret.applyedFactions,facID)
		end

		fireProtoMessageBySid(dbid, FACTION_SC_GETALLFACTION_RET, "GetAllFactionInfoRet", ret)
	end
end

--»ñÈ¡ÉêÇëÁÐ±íÊý¾Ý
function FactionServlet:doGetApplyInfos(buffer1)
	local params = buffer1:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("GetApplyFactionInfo" , buffer)
	if not req then
		print('FactionServlet:doGetApplyInfos '..tostring(err))
		return
	end

	local roleID = dbid
	local factionID = req.factionID

	local faction = g_factionMgr:getFaction(factionID)
	if faction then
		local myMem = faction:getMember(dbid)
		
		if myMem then
			--ÅÐ¶ÏÓÐÃ»ÓÐÈ¨Àû
			if myMem:hasDroit(FACTION_DROIT.TakeInMember) then
				local ret = {}
				ret.autoJoin = faction:getAutoJoin() and 1 or 0
				ret.infos = {}
				local allApply = faction:getAllApplies()
				for roleSID, apply in pairs(allApply) do
					table.insert(ret.infos,{roleSID = roleSID,lv = apply.level,name = apply.name,job = apply.school,battle = apply.battle})
				end
				fireProtoMessageBySid(dbid, FACTION_SC_GETAPPLYINFO_RET, "GetApplyFactionInfoRet", ret)
			else
				self:sendErrMsg2Client2(roleID, 0, FACERR_NO_DROIT, 0)
			end
		else
			print("ÔõÃ´»áÃ»ÓÐÕâ¸ö³ÉÔ±",myMem:getName())
		end
	else
		self:sendErrMsg2Client2(roleID, 0, FACERR_HAS_NO_FACTION, 0)
	end
end

--»ñÈ¡ËùÓÐ³ÉÔ±Êý¾Ý
function FactionServlet:getAllMemberInfo(buffer1)
	local params = buffer1:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("GetAllFactionMemberInfo" , buffer)
	if not req then
		print('FactionServlet:getAllMemberInfo '..tostring(err))
		return
	end

	local roleID = dbid
	local factionID = req.factionID
	local faction = g_factionMgr:getFaction(factionID)
	if faction then
		local ret = {}
		ret.members = {}
		local allMember = faction:getAllMembers()
		for memSID, member in pairs(allMember) do
			local level,activeState
			local player = g_entityMgr:getPlayerBySID(memSID)
			if player then
				level = player:getLevel()
				member:setLevel(level)
				activeState = 0
			else
				level = member:getLevel()
				activeState = member:getActiveState()
			end
			
			local info = {}
			info.memSID = memSID
			info.lv = level
			info.name = member:getName()
			info.job = member:getSchool()
			info.position = member:getPosition()
			info.ability = member:getAbility()
			info.activeState = activeState
			info.contribution = member:getContribution()
			table.insert(ret.members,info)
		end
		fireProtoMessageBySid(dbid, FACTION_SC_GETALLMEMBER_RET, "GetAllFactionMemberInfoRet", ret)

		--[[local retBuff = LuaEventManager:instance():getLuaRPCEvent(FACTION_SC_GETALLMEMBER_RET) 
		retBuff:pushChar(faction:getAllMemberCnt())
		local allMember = faction:getAllMembers()
		for memSID, member in pairs(allMember) do
			retBuff:pushInt(memSID)
			retBuff:pushShort(level)
			retBuff:pushString(member:getName())
			retBuff:pushChar(member:getSchool())
			retBuff:pushChar(0)
			retBuff:pushChar(member:getPosition())
			retBuff:pushInt(member:getAbility())
			retBuff:pushInt(activeState)
			retBuff:pushInt(member:getContribution())
		end
		g_engine:fireClientEvent(hGate, dbid, retBuff)
		]]--
	else
		self:sendErrMsg2Client2(dbid, hGate, FACERR_HAS_NO_FACTION, 0)
	end
end

--ÈÎÃüÖ°Îñ
function FactionServlet:doAppointPos(buffer1)
	local params = buffer1:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("AppointPosition" , buffer)
	if not req then
		print('FactionServlet:doAppointPos '..tostring(err))
		return
	end

	local roleID = dbid
	local factionID = req.factionID
	local tRoleSID = req.opRolesSID
	local pos = req.opPosition	--Ä¿±êÖ°Î»

	local hasPos = false
	for _, posId in pairs(FACTION_POSITION) do
		if pos == posId then
			hasPos = true
		end
	end
	
	if not hasPos then
		return
	end

	if pos > FACTION_POSITION.Leader then print("±È°ïÖ÷´óµÄÖ°ÎñÔõÃ´À´µÄ",tRoleSID) end

	local faction = g_factionMgr:getFaction(factionID)
	if faction then
		local sMember = faction:getMember(dbid)
		if sMember then
			if pos == FACTION_POSITION.Leader and sMember:getPosition() ~= FACTION_POSITION.Leader then
				self:sendErrMsg2Client2(dbid, hGate, FACERR_NO_DROIT, 0)
				return
			end
			local tMember = faction:getMember(tRoleSID)
			if tMember then
				if sMember:hasDroit(FACTION_DROIT.Appoint) then
					if sMember:getPosition() > tMember:getPosition() then
						if pos == FACTION_POSITION.AssociateLeader then
							if faction:getAssLeaderNum() >= ASSLEADER_NUM then
								self:sendErrMsg2Client2(dbid, hGate, FACERR_ASSLEADER_IS_MAX, 0)
								return
							else
								faction:setAssLeaderID(tRoleSID)
								tMember:setPosition(FACTION_POSITION.AssociateLeader)
								faction:setFactionSyn(true)

								--faction:setMemberSyn(true)
								faction:addUpdateMem(tRoleSID)
								fireProtoSysMessageBySid(FACTION_CS_APPOINTPOSITION, dbid, EVENT_FACTION_SETS, FACTION_APPOINT_SUCCESS, 3, {sMember:getName(),tMember:getName(),FACTION_POS_2_STR[pos]})
								fireProtoSysMessageBySid(FACTION_CS_APPOINTPOSITION, tRoleSID, EVENT_FACTION_SETS, FACTION_APPOINT_SUCCESS, 3, {sMember:getName(),tMember:getName(),FACTION_POS_2_STR[pos]})
								--¹ã²¥
								--g_factionMgr:send2AllMem(factionID, retBuff)   --Ö»¸øÏàÓ¦µÄÍæ¼ÒÌáÊ¾
								faction:addMsgRecord(FACTION_APPOINT_SUCCESS, {sMember:getName(), tMember:getName(), FACTION_POS_2_STR[pos]}, {{dbid, sMember:getName()}, {tRoleSID, tMember:getName()}})
								

								--ÈÎÃüÖ°Îñ·µ»Ø
								local ret = {}
								ret.rolesSID = sMember:getRoleSID()
								ret.position = sMember:getPosition()
								ret.opRolesSID = tMember:getRoleSID()
								ret.opPosition = pos
								fireProtoMessageBySid(dbid, FACTION_SC_APPOINTPOSITION_RET, "AppointPositionRet", ret)
								fireProtoMessageBySid(tRoleSID, FACTION_SC_APPOINTPOSITION_RET, "AppointPositionRet", ret)
							end
						else
							if tMember:getPosition() == FACTION_POSITION.AssociateLeader then
								faction:setAssLeaderID(0)
								faction:setFactionSyn(true)
							end

							tMember:setPosition(pos)

							if pos == FACTION_POSITION.Leader then
								g_factionMgr:updateLeader(factionID, tRoleSID)
								sMember:setPosition(FACTION_POSITION.Member)
								faction:addUpdateMem(dbid)
							end

							fireProtoSysMessageBySid(FACTION_CS_APPOINTPOSITION, dbid, EVENT_FACTION_SETS, FACTION_APPOINT_SUCCESS, 3, {sMember:getName(),tMember:getName(),FACTION_POS_2_STR[pos]})
							fireProtoSysMessageBySid(FACTION_CS_APPOINTPOSITION, tRoleSID, EVENT_FACTION_SETS, FACTION_APPOINT_SUCCESS, 3, {sMember:getName(),tMember:getName(),FACTION_POS_2_STR[pos]})
							--¹ã²¥
							--g_factionMgr:send2AllMem(factionID, retBuff)
							faction:addMsgRecord(FACTION_APPOINT_SUCCESS, {sMember:getName(), tMember:getName(), FACTION_POS_2_STR[pos]}, {{dbid, sMember:getName()}, {tRoleSID, tMember:getName()}})
							--ÈÎÃüÖ°Îñ·µ»Ø
							local ret = {}
							ret.rolesSID = sMember:getRoleSID()
							ret.position = sMember:getPosition()
							ret.opRolesSID = tMember:getRoleSID()
							ret.opPosition = pos
							fireProtoMessageBySid(dbid, FACTION_SC_APPOINTPOSITION_RET, "AppointPositionRet", ret)
							fireProtoMessageBySid(tRoleSID, FACTION_SC_APPOINTPOSITION_RET, "AppointPositionRet", ret)
						end

						--任职结束后，这2个人都判断下夺旗状态
						if tMember:getPosition() ~= FACTION_POSITION.Leader and tMember:getPosition() ~= FACTION_POSITION.AssociateLeader then
							local tPlayer = g_entityMgr:getPlayerBySID(tRoleSID)
							if tPlayer then
								g_manorWarMgr:clearManorData(tPlayer)
							end
						end

						if sMember:getPosition() ~= FACTION_POSITION.Leader and sMember:getPosition() ~= FACTION_POSITION.AssociateLeader then
							local sPlayer = g_entityMgr:getPlayerBySID(dbid)
							if sPlayer then
								g_manorWarMgr:clearManorData(sPlayer)
							end
						end
					else
						self:sendErrMsg2Client2(dbid, hGate, FACERR_NO_DROIT, 0)
					end
					--Í¬²½³ÉÔ±ÐÐ»áµÄÖ°¼¶
					g_factionMgr:NotifyPalyerFactionPosition(tRoleSID)
				else
					--Ã»ÓÐÈÎÃüÖ°ÎñµÄÈ¨Àû
					self:sendErrMsg2Client2(dbid, hGate, FACERR_NO_DROIT, 0)
				end
			else
				--Ã»ÓÐÕâ¸öÈË
				self:sendErrMsg2Client2(dbid, hGate, FACERR_NO_THIS_MEMBER, 0)
			end
		end
	else
		self:sendErrMsg2Client2(dbid, hGate, FACERR_HAS_NO_FACTION, 0)
	end
end

--Àë¿ª°ï»á
function FactionServlet:doLeaveFaction(buffer1)
	local params = buffer1:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("LeaveFaction" , buffer)
	if not req then
		print('FactionServlet:doLeaveFaction '..tostring(err))
		return
	end

	--二次密码验证
	if g_SecondPassMgr:IsRoleHasCheckedForLua(dbid) ~= 1 then
		return
	end	

	local factionID = req.factionID
	local playerName = req.name
	local faction = g_factionMgr:getFaction(factionID)
	if faction then
		local roleSID = dbid
		local myMem = faction:getMember(roleSID)
		if myMem then
			--°ï»á³ÉÔ±´óÓÚ1£¬°ïÖ÷²»ÄÜÍË³ö°ï»á
			if myMem:getPosition() == FACTION_POSITION.Leader then
				if faction:getAllMemberCnt() > 1 then
					self:sendErrMsg2Client2(dbid, hGate, FACERR_LEADER_LEAVE, 0)
					return
				else
					local  player = g_entityMgr:getPlayerBySID(roleSID)
					if player then
						g_manorWarMgr:sendOut(player:getID())
					end
					g_factionMgr:disbandFaction(faction)

					--ÇÐ»»µ½Íæ¼Ò·þ´¦Àí
					local retBuff = LuaEventManager:instance():getWorldEvent(FACTION_SS_LEAVEFACTION)
					retBuff:pushString(dbid)
					retBuff:pushInt(faction:getLevel())
					retBuff:pushBool(true)
					--Tlog[GuildFlow]
					retBuff:pushInt(factionID)
					retBuff:pushChar(faction:getLevel())
					retBuff:pushChar(0)

					g_engine:fireWorldEvent(0, retBuff)
					
					--Í¬²½Íæ¼ÒÁªÃËÐÐ»áÐÅÏ¢
					g_factionMgr:synFactionPlayerUnionInfo(dbid)
					--Í¬²½Íæ¼ÒÐûÕ½ÐÐ»áÐÅÏ¢
					g_factionMgr:synFactionPlayerHostilityInfo(dbid)


					self:sendErrMsg2Client2(dbid, hGate, FACTION_DISBAND_FACTION, 0)
					return
				end
			end
			if myMem:getPosition() == FACTION_POSITION.AssociateLeader then
				faction:setAssLeaderID(0)
				faction:setFactionSyn(true)
			end
			
			--ÇÐ»»µ½Íæ¼Ò·þ´¦Àí
			local retBuff = LuaEventManager:instance():getWorldEvent(FACTION_SS_LEAVEFACTION)
			retBuff:pushString(roleSID)
			retBuff:pushInt(faction:getLevel())
			retBuff:pushBool(false)
			--Tlog[GuildFlow]
			retBuff:pushInt(factionID)
			retBuff:pushChar(faction:getLevel())
			retBuff:pushChar(faction:getAllMemberCnt()-1)

			g_engine:fireWorldEvent(0, retBuff)

			faction:removeMember(roleSID)
			--faction:setMemberSyn(true)
			g_entityDao:updateFactionMember(roleSID, factionID, "", 0)
			
			--[[local retBuff2 = LuaEventManager:instance():getLuaRPCEvent(FRAME_SC_MESSAGE) 
			retBuff2:pushShort(EVENT_FACTION_SETS)
			retBuff2:pushShort(FACTION_LEAVE_FACTION)
			retBuff2:pushShort(FACTION_CS_LEAVEFACTION)
			retBuff2:pushChar(1)
			retBuff2:pushString(playerName)
			--¹ã²¥
			g_factionMgr:send2AllMem(factionID, retBuff2)]]--
			
			local allret = {}
			allret.eventId = EVENT_FACTION_SETS
			allret.eCode = FACTION_LEAVE_FACTION
			allret.mesId = FACTION_CS_LEAVEFACTION
			allret.param = {}
			table.insert(allret.param, playerName)
			g_factionMgr:sendProtoMsg2AllMem(factionID, FRAME_SC_MESSAGE, "FrameScMessageProtocol", allret)

			self:sendErrMsg2Client2(dbid, hGate, FACTION_LEAVE_FACTION_RET, 0)
			faction:addMsgRecord(FACTION_LEAVE_FACTION, {playerName}, {{roleSID, playerName}, })

			--处理领地战
			local tplayer = g_entityMgr:getPlayerBySID(roleSID)
			if tplayer then
				g_manorWarMgr:sendOut(tplayer:getID())
			end

			--Í¬²½Íæ¼ÒÁªÃËÐÐ»áÐÅÏ¢
			g_factionMgr:synFactionPlayerUnionInfo(roleSID)
			--Í¬²½Íæ¼ÒÐûÕ½ÐÐ»áÐÅÏ¢
			g_factionMgr:synFactionPlayerHostilityInfo(roleSID)

		else
			print("------doLeaveFactionÔõÃ´ÕÒ²»µ½³ÉÔ±",player:getSerialID())
		end
	else
		self:sendErrMsg2Client2(dbid, hGate, FACERR_HAS_NO_FACTION, 0)
	end
end

--ÍË³ö°ï»áÍæ¼Ò´¦Àí
function FactionServlet:onLeaveFaction(buffer1)
	local params = buffer1:getParams()
	local buffer, serverId = params[1], params[2]
	local dbid = buffer:popString()
	local bannerLvl = buffer:popInt()
	local isLeader = buffer:popBool()
	--Tlog[GuildFlow]
	local factionID = buffer:popInt()
	local factionLv = buffer:popChar()
	local factionNum = buffer:popChar()

	local player = g_entityMgr:getPlayerBySID(dbid)
	if player then
		player:setFactionID(0)
		player:setFactionName("")

		local buffmgr = player:getBuffMgr()
		if not isLeader then
			g_factionMgr:addExitBuff(player)
		end
		local buffId = g_luaFactionDAO:getBannerBuffId(bannerLvl)
		buffmgr:delBuff(buffId)
		
		--Tlog[GuildFlow]
		g_tlogMgr:TlogGuildFlow(player,5,factionID,factionLv,factionNum)
		if isLeader == true then
			g_tlogMgr:TlogGuildFlow(player,2,factionID,factionLv,factionNum)
		end

		--Í¨Öª×Ô¼ºÀë¿ª°ï»á
		local ret = {}
		ret.result = FACTION_DISBAND_FACTION
		fireProtoMessage(player:getID(), FACTION_SC_LEAVEFACTION_RET, "LeaveFactionRet", ret)

		--Í¬²½³ÉÔ±ÐÐ»áµÄÖ°¼¶
		g_factionMgr:NotifyPalyerFactionPosition(dbid)
		g_factionMgr:outFactionArea(dbid)

		local itemID = player:getShowItemID()
		local factionDart = g_factionMgr._factionDart
		if itemID ~= 0 and factionDart and factionDart._curFactionOwner[itemID].roleSID == player:getSerialID() then 
			player:dropShowItems()
		end

		g_listHandler:notifyListener("onLeaveFaction", player:getID())
	end
end

--Ìß³ö°ï»á
function FactionServlet:doRemoveMember(buffer1)
	local params = buffer1:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("RemoveFactionMember" , buffer)
	if not req then
		print('FactionServlet:doRemoveMember '..tostring(err))
		return
	end

	--二次密码验证
	if g_SecondPassMgr:IsRoleHasCheckedForLua(dbid) ~= 1 then
		return
	end	

	local sRoleID = dbid
	local factionID = req.factionID
	local tRoleSID = req.opRoleSID
	local faction = g_factionMgr:getFaction(factionID)
	if faction then
		local sMember = faction:getMember(dbid)	
		if sMember then
			--È¨ÏÞÅÐ¶Ï
			if sMember:hasDroit(FACTION_DROIT.RemoveMember) then
				local tMember = faction:getMember(tRoleSID)	
				if tMember then
					--Ö°Îñ±ØÐë´óÓÚ¶Ô·½
					if sMember:getPosition() > tMember:getPosition() then
						if tMember:getPosition() == FACTION_POSITION.AssociateLeader then
							--¸±°ïÖ÷ÊýÁ¿¼õÒ»
							faction:setAssLeaderID(0)
							faction:setFactionSyn(true)
						end

						g_factionMgr:freshUI(factionID, tRoleSID)
						faction:removeMember(tRoleSID)
						--faction:setMemberSyn(true)
						g_entityDao:updateFactionMember(tRoleSID, factionID, "", 0)

						g_factionMgr:clearCache(tRoleSID)
						--ÇÐ»»µ½Íæ¼Ò·þ´¦Àí
						local retBuff = LuaEventManager:instance():getWorldEvent(FACTION_SS_REMOVEMEMBER)
						retBuff:pushString(tRoleSID)
						retBuff:pushInt(faction:getLevel())
						--Tlog[GuildFlow]
						retBuff:pushInt(factionID)
						retBuff:pushChar(faction:getLevel())
						retBuff:pushChar(faction:getAllMemberCnt())

						g_engine:fireWorldEvent(0, retBuff)
						
						--Í¬²½Íæ¼ÒÁªÃËÐÐ»áÐÅÏ¢
						g_factionMgr:synFactionPlayerUnionInfo(tRoleSID)
						--Í¬²½Íæ¼ÒÐûÕ½ÐÐ»áÐÅÏ¢
						g_factionMgr:synFactionPlayerHostilityInfo(tRoleSID)

						--·¢ÓÊ¼þ
						local offlineMgr = g_entityMgr:getOfflineMgr()
						local email = offlineMgr:createEamil()
						local emailConfigId = 16
						email:setDescId(emailConfigId)
						email:insertParam(time.tostring(os.time()))
						email:insertParam(sMember:getName())
						email:insertParam(faction:getName())
						offlineMgr:recvEamil(tRoleSID, email, 0)
						--Í¨Öª×Ô¼ºÌß³ö°ï»á³É¹¦
						local ret = {}
						ret.opRoleSID = tRoleSID
						ret.opRoleName = tMember:getName()
						g_factionMgr:sendProtoMsg2AllMem(factionID, FACTION_SC_REMOVEMEMBER_RET, "RemoveFactionMemberRet", ret)

						--处理领地战
						local tplayer = g_entityMgr:getPlayerBySID(tRoleSID)
						if tplayer then
							g_manorWarMgr:sendOut(tplayer:getID())
						end
						

						--[[local retBuff3 = LuaEventManager:instance():getLuaRPCEvent(FRAME_SC_MESSAGE)
						retBuff3:pushShort(EVENT_FACTION_SETS)
						retBuff3:pushShort(FACTION_REMOVE_MEMBER_RET)
						retBuff3:pushShort(FACTION_CS_REMOVEMEMBER)
						retBuff3:pushChar(1)
						retBuff3:pushString(tMember:getName())
						g_factionMgr:send2AllMem(factionID, retBuff3)]]--
						
						local allret = {}
						allret.eventId = EVENT_FACTION_SETS
						allret.eCode = FACTION_REMOVE_MEMBER_RET
						allret.mesId = FACTION_CS_REMOVEMEMBER
						allret.param = {}
						table.insert(allret.param, tMember:getName())
						g_factionMgr:sendProtoMsg2AllMem(factionID, FRAME_SC_MESSAGE, "FrameScMessageProtocol", allret)

						faction:addMsgRecord(FACTION_REMOVE_MEMBER_RET, {tMember:getName()}, {{tRoleSID, tMember:getName()}, })
						--g_engine:fireLuaEvent(sRoleID, retBuff2)
					else
						self:sendErrMsg2Client2(dbid, hGate, FACERR_NO_DROIT, 0)
					end
				else
					self:sendErrMsg2Client2(dbid, hGate, FACERR_NO_THIS_MEMBER, 0)
				end
			else
				--Ã»ÓÐÈÎÃüÖ°ÎñµÄÈ¨Àû
				self:sendErrMsg2Client2(dbid, hGate, FACERR_NO_DROIT, 0)
			end
		else
			print("------doRemoveMemberÔõÃ´ÕÒ²»µ½³ÉÔ±",sMember:getName())
		end
	else
		self:sendErrMsg2Client2(dbid, hGate, FACERR_HAS_NO_FACTION, 0)
	end
end

--Ìß³ö°ï»áÍæ¼Ò´¦Àí
function FactionServlet:onRemoveMember(buffer1)
	local params = buffer1:getParams()
	local buffer, serverId = params[1], params[2]
	local dbid = buffer:popString()
	local bannerLvl = buffer:popInt()
	--Tlog[GuildFlow]
	local factionID = buffer:popInt()
	local factionLv = buffer:popChar()
	local factionNum = buffer:popChar()

	local tPlayer = g_entityMgr:getPlayerBySID(dbid)
	if tPlayer then
		local oldBattle = tPlayer:getbattle()
		tPlayer:setFactionID(0)
		tPlayer:setFactionName("")
		
		--Ìí¼ÓÀë»áBUFF
		local buffmgr = tPlayer:getBuffMgr()
		if not isLeader then
			g_factionMgr:addExitBuff(tPlayer)
		end
		--É¾³ý°ï»á¼¼ÄÜ
		local buffId = g_luaFactionDAO:getBannerBuffId(bannerLvl)
		buffmgr:delBuff(buffId)
		self:sendErrMsg2Client(tPlayer:getID(), FACTION_LEAVE_FACTION_RET, 0)

		--Í¬²½³ÉÔ±ÐÐ»áµÄÖ°¼¶
		g_factionMgr:NotifyPalyerFactionPosition(dbid)

		--Tlog[GuildFlow]
		g_tlogMgr:TlogGuildFlow(tPlayer,5,factionID,factionLv,factionNum)

		g_factionMgr:outFactionArea(dbid)

		local itemID = tPlayer:getShowItemID()
		local factionDart = g_factionMgr._factionDart
		if itemID ~= 0 and factionDart and factionDart._curFactionOwner[itemID].roleSID == tPlayer:getSerialID() then 
			tPlayer:dropShowItems()
		end

		g_listHandler:notifyListener("onLeaveFaction", tPlayer:getID())
	else
		g_factionMgr:addOffRemoveBuff(dbid)
	end
end

--»ñÈ¡°ï»áÉÌµêÊý¾Ý
function FactionServlet:doGetStoreInfo(buffer1)
	local params = buffer1:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("GetStroeInfo" , buffer)
	if not req then
		print('FactionServlet:doGetStoreInfo '..tostring(err))
		return
	end

	local roleID = dbid
	local factionID = req.factionID
	local faction = g_factionMgr:getFaction(factionID)
	if faction then
		local myMem = faction:getMember(dbid)
		if myMem then
			local ret = {}
			ret.factionlv = faction:getLevel()
			ret.infos = {}
			local storeInfo = faction:getStoreInfo()
			for itemID, info in pairs(storeInfo) do
				table.insert(ret.infos,{itemID = itemID,soldCnt = info.soldCnt})
			end
			fireProtoMessageBySid(dbid, FACTION_SC_GETSTOREINFO_RET, "GetStroeInfoRet", ret)
		else
			print("------doGetStoreInfoÔõÃ´ÕÒ²»µ½³ÉÔ±")
		end
	else
		self:sendErrMsg2Client2(dbid, hGate, FACERR_HAS_NO_FACTION, 0)
	end
end

--ÐÞ¸Ä°ï»á¹«¸æ
function FactionServlet:doEditComment(buffer1)
	print("doEditComment")
	local params = buffer1:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("EditComment" , buffer)
	if not req then
		print('FactionServlet:doEditComment '..tostring(err))
		return
	end

	local roleID = dbid
	local factionID = req.factionID
	local comment = req.comment

	print("doEditComment",factionID,comment)
	if #comment > 256 then
		print('FactionServlet:doEditComment too long '..tostring(#comment))
		self:sendErrMsg2Client2(dbid, hGate, FACERR_COMMENT_TOOLONG, 0)
		return
	end

	local faction = g_factionMgr:getFaction(factionID)
	if faction then
		local myMem = faction:getMember(dbid)
		if myMem then
			if myMem:hasDroit(FACTION_DROIT.EditComment) then
				--UTF-8ºº×ÖÕ¼3¸ö×Ö½Ú
				string.gsub(comment, "[& ]", "")
				local ansi = string.len(string.gsub(comment, "[\128-\254]+",""))
				local total = string.len(comment)
				if (ansi+2*(total-ansi)/3) > FACTION_COMMENT_LEN then
					comment = string.sub(comment, 1, FACTION_COMMENT_LEN)
				end
				faction:setComment(comment)
				faction:setFactionSyn(true)
				local ret = {}
				ret.comment = comment
				fireProtoMessageBySid(dbid, FACTION_SC_EDITCOMMENT_RET, "EditCommentRet", ret)
				--¹ã²¥
				--[[local retBuff1 = LuaEventManager:instance():getLuaRPCEvent(FRAME_SC_MESSAGE) 
				retBuff1:pushShort(EVENT_FACTION_SETS)
				retBuff1:pushShort(FACTION_EDIT_COMMENT)
				retBuff1:pushShort(FACTION_CS_EDITCOMMENT)
				retBuff1:pushChar(0)
				g_factionMgr:send2AllMem(factionID, retBuff1)]]--

				local allret = {}
				allret.eventId = EVENT_FACTION_SETS
				allret.eCode = FACTION_EDIT_COMMENT
				allret.mesId = FACTION_CS_EDITCOMMENT
				allret.param = {}
				g_factionMgr:sendProtoMsg2AllMem(factionID, FRAME_SC_MESSAGE, "FrameScMessageProtocol", allret)

				faction:addMsgRecord(FACTION_EDIT_COMMENT, {}, {})

				g_factionMgr:freshUI(factionID)
			else
				--Ã»ÓÐÈ¨ÏÞ
				self:sendErrMsg2Client2(dbid, hGate, FACERR_NO_DROIT, 0)
			end
		else
			print("------doEditCommentÔõÃ´ÕÒ²»µ½³ÉÔ±")
		end
	else
		self:sendErrMsg2Client2(dbid, hGate, FACERR_HAS_NO_FACTION, 0)
	end
end

--ÉèÖÃÊÇ·ñ×Ô¶¯Åú×¼¼ÓÈë
function FactionServlet:doChangeAutoJoin(buffer1)
	local params = buffer1:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("ChangeFactionAutoJoin" , buffer)
	if not req then
		print('FactionServlet:doChangeAutoJoin '..tostring(err))
		return
	end

	local roleID = dbid
	local factionID = req.factionID
	local autoJoin = req.autoJoin > 0
	local faction = g_factionMgr:getFaction(factionID)
	if faction then
		local myMem = faction:getMember(dbid)
		if myMem then
			if myMem:hasDroit(FACTION_DROIT.TakeInMember) then
				faction:setAutoJoin(autoJoin)
				faction:setFactionSyn(true)
				--Í¬ÒâËùÓÐ
				if autoJoin == true then
					--self:agreeAll(roleID)
				end
			else
				self:sendErrMsg2Client2(dbid, hGate, FACERR_NO_DROIT, 0)
			end
		else
			print("-----doChangeAutoJoinÔõÃ´ÕÒ²»µ½³ÉÔ±")
		end
	else
		self:sendErrMsg2Client2(dbid, hGate, FACERR_HAS_NO_FACTION, 0)
	end
end

--»ñÈ¡°ï»áÈÕÖ¾
--ÕâÊÇÒ»¸öÔöÁ¿¸üÐÂ
function FactionServlet:getMsgRecord(buffer1)
	print("getMsgRecord")
	local params = buffer1:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("GetFactionMsgRecord" , buffer)
	if not req then
		print('FactionServlet:getMsgRecord '..tostring(err))
		return
	end

	local roleID = dbid
	local factionID = req.factionID
	local lowNum = req.lowNum
	local highNum = req.highNum
	
	lowNum = lowNum>0 and lowNum or 1
	highNum = highNum>0 and highNum or 1
	
	print("getMsgRecord",lowNum,highNum)
	if highNum<lowNum then
		print("-------FactionServlet:getMsgRecord²ÎÊý³ö´í",highNum,lowNum)
		return
	end
	
	local faction = g_factionMgr:getFaction(factionID)
	if faction then
		local ret = {}
		ret.records = {}
		local msgRecords = faction:getMsgRecord()
		local cnt = #msgRecords
		print("getMsgRecord",lowNum,highNum,cnt)
		--ÎÞ¼ÇÂ¼²»×ö·´Ó¦
		if lowNum > cnt then
			--retBuff:pushChar(0)	--ÎÞ¼ÇÂ¼
			--g_engine:fireClientEvent(hGate, dbid, retBuff)
			fireProtoMessageBySid(dbid, FACTION_SC_GETMSGRECORD_RET, "GetFactionMsgRecordRet", ret)
		else
			if highNum > cnt then
				highNum = cnt
			end

			for i=lowNum, highNum do
				print("msgRecords",i)
				local record = msgRecords[i]
				local recordinfo = {}
				recordinfo.time = record[1]	--Ê±¼ä
				recordinfo.id = record[2]	--¼ÇÂ¼ID
				recordinfo.params = {}
				for j=1, #record[3] do
					--retBuff:pushString(record[3][j])
					table.insert(recordinfo.params,record[3][j])
				end
				recordinfo.links = {}
				for k=1, #record[4] do
					--retBuff:pushInt(record[4][k][1])	--¾²Ì¬ID
					--retBuff:pushString(record[4][k][2])	--Ãû×Ö
					table.insert(recordinfo.links,{id = record[4][k][1],name = record[4][k][2]})
				end
				table.insert(ret.records,recordinfo)
			end

			--g_engine:fireClientEvent(hGate, dbid, retBuff)
			fireProtoMessageBySid(dbid, FACTION_SC_GETMSGRECORD_RET, "GetFactionMsgRecordRet", ret)
		end
	end
end


--¾èÏ×µñÏñ
function FactionServlet:doAddStatue(buffer1)
	local params = buffer1:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("FactionAddStatue" , buffer)
	if not req then
		print('FactionServlet:doAddStatue '..tostring(err))
		return
	end

	local roleSID = dbid
	local addNum = req.addNum
	if addNum < 0 then
		return
	end
	
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		local roleID = player:getID()
		if not g_shaWarMgr:canAddStatue() then
			self:sendErrMsg2Client(roleID, FACERR_NOT_ALLOW_STATUE, 0)
			return
		end
		local facID = player:getFactionID()
		if facID <= 0 then
			self:sendErrMsg2Client(roleID, FACERR_HAS_NO_FACTION, 0)
			return
		end

		--ÅÐ¶ÏµñÏñÊýÁ¿¹»²»¹»
		local itemMgr = player:getItemMgr()
		if not isMatEnough(player, FACTION_STATUE_ID, addNum) then
			self:sendErrMsg2Client(roleID, FACERR_STATUE_NOT_ENOUGH, 0)
			return
		end

		--ÏûºÄµñÏñ
		costMat(player, FACTION_STATUE_ID, addNum, 98, 0)		
		g_factionMgr:addStatue(player, facID, player:getName(), addNum)
	end
end

--»ñÈ¡¾èÏ×µñÏñÅÅÃû
function FactionServlet:doGetStatueRank(buffer1)
	local params = buffer1:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("FactionGetStatueRank" , buffer)
	if not req then
		print('FactionServlet:doGetStatueRank '..tostring(err))
		return
	end

	g_factionMgr:getStatueRank(hGate, dbid)
end

--»ñÈ¡¾èÏ×µñÏñ¼ÇÂ¼
function FactionServlet:doGetStatueRd(buffer1)
	local params = buffer1:getParams()
	local buffer, dbId, hGate = params[1], params[2], params[3]
	local roleID = buffer:popString()

	g_factionMgr:getStatueRd(hGate, dbId)
end

--------------------------------------------------------------ÐÐ»áÍâ½»---------------------------------------------------------------------
--ÇëÇóÄ³¸öÐÐ»áµÄÍâ½»ÐÅÏ¢ ÒÑ¾­×ªµ½ÐÐ»áGS´¦Àí
function FactionServlet:getFactionSocialInfo(buffer1)
	local params = buffer1:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("GetFactionSocialInfo" , buffer)
	if not req then
		print('FactionServlet:getFactionSocialInfo '..tostring(err))
		return
	end

	local roleID = dbid
	local factionID = req.factionID
	
	print("FactionServlet:getFactionSocialInfo",dbid,factionID)

	local ret = {}
	ret.factionID = factionID
	ret.allFactions = {}
	--ËùÓÐµÄÐÐ»áÐÅÏ¢
	local allFaction = g_factionMgr:getAllFactions()
	for _, fac in pairs(allFaction) do
		local facinfo = {}
		print("getFactionSocialInfo",fac:getFactionID())
		facinfo.id = fac:getFactionID()
		facinfo.name = fac:getName()
		facinfo.lv = fac:getLevel()
		facinfo.allMemberCnt = fac:getAllMemberCnt()
		facinfo.maxMemberCnt = g_luaFactionDAO:getfacMaxMemNum(fac:getLevel())
		facinfo.totalAbility = fac:getTotalAbility()

		local flag = false --Ö»ÐèÒª°ïÖ÷¸±°ïÖ÷ÔÚÏßµÄ
		local leaderMem = fac:getMember(fac:getLeaderID())
		if leaderMem and leaderMem:getActiveState() == 0 then
			flag = true
		else 
			for _, mem in pairs(fac._factionMembers) do
				if mem:getPosition() == FACTION_POSITION.AssociateLeader and mem:getActiveState() == 0 then
					flag = true
					break
				end
			end
		end
		facinfo.leaderOnline = flag and 1 or 0
		facinfo.autoJoin = 0
		table.insert(ret.allFactions,facinfo)
	end
	
	ret.socials = {}
	--ÓëÐÐ»áÒÑ¾­½¨Á¢¹ØÏµµÄÍâ½»ÐÅÏ¢
	local factionSocials = g_factionMgr:getFactionSocials(factionID)												
	for _, facSocial in pairs(factionSocials) do
		local social = {}
		local state = facSocial:getState()
		social.aFactionID = facSocial:getAFactionID()				--aÐÐ»áID
		social.bFactionID = facSocial:getBFactionID()				--bÐÐ»áID
		social.state = state							--µ±Ç°×´Ì¬
		social.opFactionID = facSocial:getOpFactionID()				--²Ù×÷·½ÐÐ»áID

		local time = 0
		if state == SocialState.Neutral then
			if factionID == facSocial:getAFactionID() then
				time = (facSocial:getAFactionOpTime() > 0) and (facSocial:getAFactionOpTime() + SocialOperatorCoolDown - os.time()) or 0
			else
				time = (facSocial:getBFactionOpTime() > 0) and (facSocial:getBFactionOpTime() + SocialOperatorCoolDown - os.time()) or 0
			end
		elseif state == SocialState.Hostility then
			time = (facSocial:getOpTime() > 0) and (facSocial:getOpTime() + HostilityLastTime - os.time()) or 0
		end
	
		time = time > 0 and time or 0
		social.time = time							--µ¹¼ÆÊ±Ê£ÓàÊ±¼ä(Ãë) ÖÐÁ¢×´Ì¬ÏÂÎª±¾ÐÐ»áÊ£Óà²Ù×÷ÀäÈ´Ê±¼ä µÐ¶Ô×´Ì¬ÏÂÎªµÐ¶Ô×´Ì¬Ê£ÓàÊ±¼ä ÆäËû×´Ì¬ÎÞÊÓ
		table.insert(ret.socials,social)
	end
	fireProtoMessageBySid(dbid, FACTION_SC_GETSOCIALINFO_RET, "GetFactionSocialInfoRet", ret)
end

--ÐÐ»áÍâ½»²Ù×÷ÇëÇó ±¾GS´¦Àí
function FactionServlet:reqFactionSocialOperator(buffer1)
	local params = buffer1:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("FactionSocialOperator" , buffer)
	if not req then
		print('FactionServlet:reqFactionSocialOperator '..tostring(err))
		return
	end

	local roleID = dbid
	local operator = req.opType			--²Ù×÷ÀàÐÍ
	local srcfactionID = req.srcFactionID		--µ±Ç°ÐÐ»áID
	local dstfactionID = req.dstFactionID		--Ä¿±êÐÐ»áID

	--print("FactionServlet:reqFactionSocialOperator",dbid,operator,srcfactionID,dstfactionID)
	
	--ÐÐ»áÍâ½»²Ù×÷Ô¤´¦Àí(¼ì²éÎïÆ· ÌáÇ°ÊÕÎïÆ·)
	local retCode = g_factionMgr:reqFactionSocialOperator(dbid,operator,srcfactionID,dstfactionID)
	if retCode ~= SocialOperator_Success then
		local ret = {}
		--²Ù×÷·µ»ØÖµ
		ret.retCode = retCode
		--²Ù×÷ÉÏÏÂÎÄ
		ret.opType = operator
		ret.srcFactionID = srcfactionID
		ret.dstfactionID = dstfactionID
		fireProtoMessageBySid(dbid, FACTION_SC_SOCIALOPERATOR_RET, "FactionSocialOperatorRet", ret)
	else
		--ÇÐ»»µ½Êý¾Ý·þºóÐø´¦Àí 
		local retBuff = LuaEventManager:instance():getWorldEvent(FACTION_SS_SOCIALOPERATOR)
		retBuff:pushString(dbid)
		retBuff:pushInt(hGate)
		retBuff:pushChar(operator)
		retBuff:pushInt(srcfactionID)
		retBuff:pushInt(dstfactionID)
		g_engine:fireWorldEvent(FACTION_DATA_SERVER_ID, retBuff)
	end
end

--´¦ÀíÐÐ»áÍâ½»²Ù×÷ÇëÇó ÒÑ¾­×ªµ½ÐÐ»áGS´¦Àí
function FactionServlet:doFactionSocialOperator(buffer1)
	local params = buffer1:getParams()
	local buffer, serverId = params[1], params[2]
	local dbid = buffer:popString()
	local hGate = buffer:popInt()
	local operator = buffer:popChar()	--²Ù×÷ÀàÐÍ
	local srcfactionID = buffer:popInt()	--µ±Ç°ÐÐ»áID
	local dstfactionID = buffer:popInt()	--Ä¿±êÐÐ»áID

	--print("FactionServlet:doFactionSocialOperator",serverId,dbid,operator,srcfactionID,dstfactionID)
	
	local retCode = g_factionMgr:doFactionSocialOperator(dbid,operator,srcfactionID,dstfactionID)
	--ÐÐ»á²Ù×÷Ê§°Ü´¦Àí
	if retCode ~= SocialOperator_Success then
		g_factionMgr:factionSocialOperatorFail(dbid,operator,srcfactionID,dstfactionID)
		
		local ret = {}
		--²Ù×÷·µ»ØÖµ
		ret.retCode = retCode
		--²Ù×÷ÉÏÏÂÎÄ
		ret.opType = operator
		ret.srcFactionID = srcfactionID
		ret.dstfactionID = dstfactionID
		fireProtoMessageBySid(dbid, FACTION_SC_SOCIALOPERATOR_RET, "FactionSocialOperatorRet", ret)
	end
end
---------------------------------------------------------------ÐÐ»áÆí¸£-----------------------------------------------------------------------
--ÇëÇóÍæ¼ÒÔÚÄ³¸öÐÐ»áµÄÆí¸£ÐÅÏ¢ ÒÑ¾­×ªµ½ÐÐ»áGS´¦Àí
function FactionServlet:getFactionPrayInfo(buffer1)
	local params = buffer1:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("GetFactionPrayInfo" , buffer)
	if not req then
		print('FactionServlet:getFactionPrayInfo '..tostring(err))
		return
	end
	local factionID = req.factionID
	--print("FactionServlet:getFactionPrayInfo",dbid,factionID)

	--ÐÐ»áµÄÓÐÐ§ÐÔ¼ì²â
	local faction = g_factionMgr:getFaction(factionID)
	if not faction then
		return
	end
	
	--ÐÐ»á³ÉÔ±ÐÅÏ¢¼ì²â
	local facMem = faction:getMember(dbid)
	if not facMem then 
		return
	end
	
	--·µ»ØÐÐ»á³ÉÔ±½ñÈÕÊ£ÓàÐÐ»áÆí¸£Êý¾Ý
	local prayDayLeft = {}
	local needUpdate = false
	for prayType, _ in pairs(CONTRIBUTION_DATA) do
		local oldcount = facMem:_getDayPrayCount(prayType)
		local curcount = facMem:getDayPrayCount(prayType)
		if oldcount ~= curcount then
			needUpdate = true
		end
		
		--Ã¿ÈÕÆí¸£ÉÏÏÞÅäÖÃ
		local contriData = CONTRIBUTION_DATA[prayType]
		local dayLimit = contriData.num
		local left = (dayLimit > curcount) and (dayLimit - curcount) or 0
		prayDayLeft[prayType] = left

	end
	
	local ret = {}
	ret.infos = {}
	for type, count in pairs(prayDayLeft) do
		table.insert(ret.infos,{prayType = type,dayLeftCount = count})
	end
	fireProtoMessageBySid(dbid, FACTION_SC_GETPRAYINFO_RET, "GetFactionPrayInfoRet", ret)

	if needUpdate == true then
		faction:addUpdateMem(dbid)
	end
end

--ÐÐ»áÆí¸£²Ù×÷ÇëÇó ËùÔÚGS
function FactionServlet:doFactionPray(buffer1)
	local params = buffer1:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("FactionPray" , buffer)
	if not req then
		print('FactionServlet:doFactionPray '..tostring(err))
		return
	end
	local prayType = req.prayType	--Æí¸£ÀàÐÍ
	--print("FactionServlet:doFactionPray",dbid,prayType)
	
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not player then
		return
	end

	local retCode = g_factionMgr:FactionPray(dbid,prayType)
	if retCode ~= FactionPray_Success then
		local ret = {}
		--²Ù×÷·µ»ØÖµ
		ret.retCode = retCode
		--²Ù×÷ÉÏÏÂÎÄ
		ret.prayType = prayType
		fireProtoMessageBySid(dbid, FACTION_SC_PRAY_RET, "FactionPrayRet", ret)
	end
end

function FactionServlet:doEnterArea(buffer1)
	local params = buffer1:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]

	local player = g_entityMgr:getPlayerBySID(dbid)
	if not player then
		return
	end

	if player:getFactionID() > 0 then
		g_factionMgr:enterFactionArea(dbid, 11, 35)
	end
end

function FactionServlet:doOutArea(buffer1)
	local params = buffer1:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local player = g_entityMgr:getPlayer(roleID)

	if not player then
		return
	end

	if player:getFactionID() > 0 then
		g_factionMgr:outFactionArea(dbid)
	end
end

---------------------------------------------------------------ÐÐ»á¹«¹²ÈÎÎñ-----------------------------------------------------------------------
--Íæ¼ÒÇëÇóÔÚÄ³¸öÐÐ»áµÄ¹«¹²ÈÎÎñÐÅÏ¢
function FactionServlet:getFactionTaskInfo(buffer1)
	local params = buffer1:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("GetFactionTaskInfo" , buffer)
	if not req then
		print('FactionServlet:getFactionTaskInfo '..tostring(err))
		return
	end
	local factionID = req.factionID
	--print("FactionServlet:getFactionTaskInfo",dbid,factionID)
	
	--ÐÐ»áµÄÓÐÐ§ÐÔ¼ì²â
	local faction = g_factionMgr:getFaction(factionID)
	if not faction then
		return
	end
	
	--ÐÐ»á³ÉÔ±ÐÅÏ¢¼ì²â
	local facMem = faction:getMember(dbid)
	if not facMem then 
		return
	end
	
	local factionTaskInfo = g_factionMgr:getFactionTaskInfo(factionID)
	if factionTaskInfo then
		local factionTaskMsg = factionTaskInfo:buildFactionTaskMsg(FACTIONTASK_ALLTASK_ID,dbid)
		g_engine:fireClientEvent(hGate, dbid, factionTaskMsg)
	end
end


--ÑûÇëÍæ¼ÒÈë»áÇëÇó
function FactionServlet:OnInviteRoleJoin(buffer1)
	local params = buffer1:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("FactionInviteJoin" , buffer)
	if not req then
		print('FactionServlet:OnInviteRoleJoin '..tostring(err))
		return
	end
	local strRoleName = req.opRoleName
	local cPlayer = g_entityMgr:getPlayerBySID(dbid);
	
	print("FactionServlet:OnInviteRoleJoin",strRoleName)
	local cBeInvitePlayer = g_entityMgr:getPlayerByName(strRoleName);
	local nRoleId = cPlayer:getID();

	if not cBeInvitePlayer then
		self:sendErrMsg2Client(nRoleId, FACERR_BEINVITE_OFFLINE, 0)
		return
	end

	if cBeInvitePlayer:getFactionID() > 0 then
		print("OnInviteRoleJoin",FACERR_BEINVITE_ALREADY_HAS_FACTION)
		self:sendErrMsg2Client(nRoleId, FACERR_BEINVITE_ALREADY_HAS_FACTION, 0)
		return
	end

	local cInvitePlayer = g_entityMgr:getPlayerBySID(dbid)
	if cInvitePlayer then
		local nFactionId = cInvitePlayer:getFactionID()
		if nFactionId <= 0 then
			self:sendErrMsg2Client(nRoleId, FACERR_HAS_NO_FACTION, 0)
			return
		end

		local cFaction = g_factionMgr:getFaction(nFactionId)
		if not cFaction then
			self:sendErrMsg2Client(nRoleId, FACERR_HAS_NO_FACTION, 0)
			return
		end

		local cMember = cFaction:getMember(dbid)
		if not cMember then
			self:sendErrMsg2Client(nRoleId, FACERR_HAS_NO_FACTION, 0)
			return
		end

		if cMember:getPosition() ~= FACTION_POSITION.Leader and cMember:getPosition() ~= FACTION_POSITION.AssociateLeader then
			self:sendErrMsg2Client(nRoleId, FACERR_BEINVITE_ONLY_LEADER, 0)
			return
		end

		--»Ø¸´ÑûÇëÈË
		local retBuff = LuaEventManager:instance():getLuaRPCEvent(FACTION_SC_INVITE_JONE)
		g_engine:fireLuaEvent(cInvitePlayer:getID(), retBuff)

		--Í¨Öª±»ÑûÇëÈË
		local ret = {}
		ret.inviteRoleSID = dbid
		ret.inviteRoleName = cInvitePlayer:getName()
		ret.factionID = nFactionId
		ret.factionName = cFaction:getName()
		fireProtoMessage(cBeInvitePlayer:getID(), FACTION_SC_INVITE_NOTIFY_JONE, "FactionInviteJoinNotify", ret)
	end
end

--ÊÜÑûÈË¶ÔÑûÇëµÄ²Ù×÷
function FactionServlet:OnOperatorInvite(buffer1)
	local params = buffer1:getParams();
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("FactionInviteJoinChoose" , buffer)
	if not req then
		print('FactionServlet:OnOperatorInvite '..tostring(err))
		return
	end

	local byChoose = req.choose;
	local nInviteRoleId = req.inviteRoleSID;
	local nInviteFactionId = req.factionID;

	local cPlayer = g_entityMgr:getPlayerBySID(dbid);
	if cPlayer then
		local nEntityId = cPlayer:getID();

		local cInvitePlayer = g_entityMgr:getPlayerBySID(nInviteRoleId);

		if byChoose ~= 1 then
			--Í¨ÖªÑûÇëÈË
			if cInvitePlayer then
				local ret = {}
				ret.playerName = cPlayer:getName()
				ret.choose = byChoose
				--local retBuff = LuaEventManager:instance():getLuaRPCEvent(FACTION_SC_INVITE_NOTIFY_CHOOSE)
				--retBuff:pushString(cPlayer:getName())
				--retBuff:pushChar(byChoose)
				--g_engine:fireLuaEvent(cInvitePlayer:getID(),retBuff)
				fireProtoMessage(cInvitePlayer:getID(), FACTION_SC_INVITE_NOTIFY_CHOOSE, "FactionInviteJoinChooseNotify", ret)
			end
			return
		end

		if cPlayer:getFactionID() > 0 then
			self:sendErrMsg2Client(nEntityId, FACERR_ALREADY_HAS_FACTION, 0)
			return
		end

		
		if cInvitePlayer then
			if cInvitePlayer:getFactionID() ~= nInviteFactionId then
				self:sendErrMsg2Client(nEntityId, FACERR_INVITE_FACTION_CHANGE, 0)
				return
			end	
		end

		local cFaction = g_factionMgr:getFaction(nInviteFactionId);
		if not cFaction then
			self:sendErrMsg2Client(nEntityId, FACERR_INVITE_FACTION_NOT_EXIST, 0)
			return
		end

		if cFaction:getAllMemberCnt() >= g_luaFactionDAO:getfacMaxMemNum(cFaction:getLevel()) then
			--´ïµ½×î´óÈËÊýÌáÊ¾
			self:sendErrMsg2Client(nEntityId, FACERR_MAX_MEMBER, 0)
			return
		else
			g_achieveSer:achieveNotify(dbid, AchieveNotifyType.joinFation, 1)
			
			local newFacMem = FactionMember(dbid)
			newFacMem:setFactionID(nInviteFactionId)
			newFacMem:setJoinTime(os.time())
			newFacMem:setName(cPlayer:getName())
			newFacMem:setSchool(cPlayer:getSchool())
			newFacMem:setSex(cPlayer:getSex())
			newFacMem:setActiveState(os.time())
			newFacMem:setLevel(cPlayer:getLevel())
			newFacMem:setAbility(cPlayer:getbattle())	--Õ½¶·Á¦

			-- Í¨ÖªÍæ¼ÒÈë»á
			--[[
			local retBuff = LuaEventManager:instance():getWorldEvent(FACTION_SS_AGREE_JOIN)
			retBuff:pushInt(dbid)
			retBuff:pushInt(nInviteFactionId)
			retBuff:pushString(cFaction:getName())
			retBuff:pushInt(cFaction:getLevel())
			--Tlog[GuildFlow]
			retBuff:pushChar(cFaction:getLevel())
			retBuff:pushChar(cFaction:getAllMemberCnt()+1)
			g_engine:fireWorldEvent(0, retBuff)
			]]

			self:onJoinFaction(dbid,nInviteFactionId,cFaction:getName(),cFaction:getLevel(),cFaction:getLevel(),cFaction:getAllMemberCnt()+1)


			cFaction:addFactionMember(newFacMem)
			--¸üÐÂÊý¾Ý¿â
			newFacMem:update2DB(nInviteFactionId)
			g_factionMgr:clearCache(dbid)
			
			--Í¬²½Íæ¼ÒÁªÃËÐÐ»áÐÅÏ¢
			g_factionMgr:synFactionPlayerUnionInfo(dbid,nInviteFactionId)
			--Í¬²½Íæ¼ÒÐûÕ½ÐÐ»áÐÅÏ¢
			g_factionMgr:synFactionPlayerHostilityInfo(dbid,nInviteFactionId)

			--Í¨ÖªËùÓÐ³ÉÔ±ÓÐÈË¼ÓÈë
			--[[local retBuff = LuaEventManager:instance():getLuaRPCEvent(FRAME_SC_MESSAGE)
			retBuff:pushShort(EVENT_FACTION_SETS)
			retBuff:pushShort(FACTION_ADD_NEWMEMBER)
			retBuff:pushShort(FACTION_CS_AGREE_JOIN)
			retBuff:pushChar(1)
			retBuff:pushString(cPlayer:getName())
			g_factionMgr:send2AllMem(nInviteFactionId, retBuff)]]--

			local allret = {}
			allret.eventId = EVENT_FACTION_SETS
			allret.eCode = FACTION_ADD_NEWMEMBER
			allret.mesId = FACTION_CS_AGREE_JOIN
			allret.param = {}
			table.insert(allret.param, cPlayer:getName())
			g_factionMgr:sendProtoMsg2AllMem(factionID, FRAME_SC_MESSAGE, "FrameScMessageProtocol", allret)

			cFaction:addMsgRecord(FACTION_ADD_NEWMEMBER, {cPlayer:getName()}, {{dbid, cPlayer:getName()}, })

			g_factionMgr:deleteRoleApply(dbid)

			--Í¨ÖªÑûÇëÈË
			if cInvitePlayer then
				local ret = {}
				ret.playerName = cPlayer:getName()
				ret.choose = byChoose
				fireProtoMessage(cInvitePlayer:getID(), FACTION_SC_INVITE_NOTIFY_CHOOSE, "FactionInviteJoinChooseNotify", ret)
			end
		end
	end
end

function FactionServlet.NpcFactionDartPick(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	if player then 
		local factionID = player:getFactionID()
		local faction = g_factionMgr:getFaction(factionID)
		local factionDart = g_factionMgr._factionDart

		if not factionDart then 
			fireProtoSysMessage(0, roleID, EVENT_FACTION_SETS, FACTION_DART_NOT_TIME , 0, {})  
			return 
		end		
		
		if not faction then		--玩家没有行会
			fireProtoSysMessage(0, roleID, EVENT_FACTION_SETS, FACTION_DART_NOJOIN , 0, {})  
			return
		elseif not factionDart:isHasManor(factionID) then   --判断是否有领地
			fireProtoSysMessage(0, roleID, EVENT_FACTION_SETS, FACTION_DART_NOMANOR , 0, {})
		elseif factionDart:getDartState(factionID) == 1  then --判断是否已经参加过活动
			fireProtoSysMessage(0, roleID, EVENT_FACTION_SETS, FACTION_DART_RUNING , 0, {})
		elseif factionDart:getDartState(factionID) == 4 then  
			fireProtoSysMessage(0, roleID, EVENT_FACTION_SETS, FACTION_DART_ALREADY_JOIN , 0, {})
		elseif  player:getSerialID() == faction:getLeaderID() or player:getSerialID() == faction:getAssLeaderID() then --正副会长才能开启
			if  player:getShowItemID() == 0 then 
				g_rideMgr:offRide(player:getSerialID())
	
				factionDart:join(player, faction)

			else
				fireProtoSysMessage(0, roleID, EVENT_FACTION_SETS, FACTION_DART_NO_GIVEN , 0, {})
			end
		else
			fireProtoSysMessage(0, roleID, EVENT_FACTION_SETS, FACTION_DART_LEADER , 0, {})
		end
	end
	-- body
end

function FactionServlet.NpcFactionDartSend( roleID )
	local player = g_entityMgr:getPlayer(roleID)
	if player then 
		local itemID = player:getShowItemID()
		local factionDart = g_factionMgr._factionDart
		if itemID ~= 0 and factionDart and factionDart._curFactionOwner[itemID].roleSID == player:getSerialID() then 
			local factionID = player:getFactionID()
			local faction = g_factionMgr:getFaction(factionID)
			if faction then 
				factionDart:finishDart(factionID,itemID)	
				factionDart:sendReward(player,faction,itemID)
				player:deleteShowItems()

				fireProtoSysMessage(0, roleID, EVENT_FACTION_SETS, FACTION_DART_GIVE_GOOD , 0, {})
			end	
		else
			fireProtoSysMessage(0, roleID, EVENT_FACTION_SETS, FACTION_DART_NO_GOODS , 0, {})
		end
	end
	-- body
end


---------------------------------------行会实时语音--------------------------------------------------------------


--创建房间
function FactionServlet:OnFactionVoiceCreateRoom(buffer1)
	local params = buffer1:getParams();
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("FactionVoiceCreateRoomProtocol" , buffer)
	if not req then
		print('FactionServlet:FactionVoiceCreateRoom '..tostring(err))
		return
	end
	local cPlayer = g_entityMgr:getPlayerBySID(dbid);
	if not cPlayer then
		print("FactionServlet:FactionVoiceCreateRoom Palyer Not Exist,dbid:"..tostring(dbid));
		return
	end

	local nFactionId = cPlayer:getFactionID();
	local cFaction = g_factionMgr:getFaction(nFactionId);
	if not cFaction then
		print("FactionServlet:FactionVoiceCreateRoom cFaction Not Exist,dbid:"..tostring(dbid)..",factionid:"..tostring(nFactionId));
		return
	end

	--只有指挥者能创建房间
	if dbid ~= cFaction:getCommandId() then
		g_FactionServlet:sendErrMsg2Client(cPlayer:getID(), FACTION_VOICE_CREATE_ROOM_PERMISSION_ERROR, 0)
		return
	end

	local tVoiceInfo = g_factionMgr:getFactionVoiceInfo(nFactionId)
	if tVoiceInfo then
		strGid = tVoiceInfo[1];
		strRoomId = tVoiceInfo[2];
		strRoomKey = tVoiceInfo[3];
		g_tFactionVoiceMgr:CheckVoiceRoomIsExist(dbid,nFactionId,strGid,strRoomId,strRoomKey,1);
	else
		g_tFactionVoiceMgr:CreateVoiceRoom(dbid,nFactionId);
	end
end

--创建房间时检查房间是否存在,如果不存在执行创建,然后C++回调此函数
function FactionServlet.checkRoomExistOnCreateRoom(roleSID,nFactionId,nExist,nErrno)
	if nExist ~= 1 then
		g_FactionServlet:BroadcastRoomClose(nFactionId);
		g_tFactionVoiceMgr:CreateVoiceRoom(roleSID,nFactionId);
	end
end

--玩家登陆时如果存在房间,就会去检查这个房间是否存在,然后C++回调此函数
function FactionServlet.checkRoomExistOnLogin(roleSID,nFactionId,nExist,nErrno)
	if nExist ~= 1 then
		g_FactionServlet:BroadcastRoomClose(nFactionId);
	end
end


--创建房间后C++回调此函数
function FactionServlet.FactionVoiceCreateRoomRet(roleSID,nFactionId,strBuff,nErrNo)
	local cPlayer = g_entityMgr:getPlayerBySID(dbid);

	if nErrNo ~= 0 then
		if cPlayer then
			g_FactionServlet:sendErrMsg2Client(cPlayer:getID(), FACTION_VOICE_CREATE_ROOM_ERROR, 0)
		end
		return
	end	

	local cFaction = g_factionMgr:getFaction(nFactionId);
	if not cFaction then
		return
	end

	local tVoiceInfo = g_factionMgr:getFactionVoiceInfo(nFactionId);
	if tVoiceInfo then
		return;
	end

	g_factionMgr:setFacionVoiceInfo(nFactionId,strBuff);
	g_FactionServlet:BroadcastRoomCreate(nFactionId);

	if cPlayer then
		fireProtoMessage(cPlayer:getID(), FACTION_VOICE_SC_CREATE_ROOM, "FactionVoiceCreateRoomRetProtocol", ret)
	end
end

--创建房间通知 
function FactionServlet:BroadcastRoomCreate(nFactionId)
	g_factionMgr:sendProtoMsg2AllMem(nFactionId, FACTION_VOICE_SC_NTF_CREATE_ROOM, "FactionVoiceCreateRoomNtfProtocol", {})
end

--关闭房间通知 
function FactionServlet:BroadcastRoomClose(nFactionId)
	g_factionMgr:sendProtoMsg2AllMem(nFactionId, FACTION_VOICE_SC_NTF_CLOSE_ROOM, "FactionVoiceCloseRoomNtfProtocol", {})
end

--加入房间
function FactionServlet:OnFactionVoiceJoinRoom( buffer1 )
	local params = buffer1:getParams();
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("FactionVoiceJoinRoomProtocol" , buffer)
	if not req then
		print('FactionServlet:OnFactionVoiceJoinRoom '..tostring(err))
		return
	end

	local cPlayer = g_entityMgr:getPlayerBySID(dbid);
	if not cPlayer then
		print("FactionServlet:OnFactionVoiceJoinRoom Palyer Not Exist,dbid:"..tostring(dbid));
		return;
	end
	local nFactionId = cPlayer:getFactionID();

	local cFaction = g_factionMgr:getFaction(nFactionId);
	if not cFaction then
		print("FactionServlet:OnFactionVoiceJoinRoom cFaction Not Exist,dbid:"..tostring(dbid)..",factionid:"..tostring(nFactionId));
		return
	end	
	
	--只有指挥者是演讲者
	local nJoinType = 2
	if dbid ==  cFaction:getCommandId() then
		nJoinType = 1;
	end

	local tVoiceInfo = g_factionMgr:getFactionVoiceInfo(nFactionId)
	if tVoiceInfo then
		g_tFactionVoiceMgr:JoinVoiceRoom(dbid,nFactionId,tVoiceInfo[1],tVoiceInfo[2],tVoiceInfo[3],nJoinType,tVoiceInfo[6]);
	else
		self:sendErrMsg2Client(cPlayer:getID(), FACTION_VOICE_JOIN_ROOM_NOT_EXIST, 0)
	end
end

--加入房间的C++回调
function FactionServlet.doRetFactionVoiceJoinRoom(roleSID,nFactionIdRet,strBuff,nErrno)
	local cPlayer = g_entityMgr:getPlayerBySID(roleSID);
	if not cPlayer then
		print("FactionServlet:doRetFactionVoiceJoinRoom Palyer Not Exist,dbid:"..tostring(dbid));
		return
	end

	local nFactionId = cPlayer:getFactionID();
	if nFactionIdRet ~= nFactionId then
		g_FactionServlet:sendErrMsg2Client(cPlayer:getID(), FACTION_VOICE_JOIN_ROOM_FACTION_ID_NOT_SAME, 0)
		return
	end

	if nErrno > 0 then
		g_FactionServlet:sendErrMsg2Client(cPlayer:getID(), FACTION_VOICE_JOIN_ROOM_FAILED, 0)
		return
	end

	local req, err = protobuf.decode("FactionVoiceJoinRoomRetProtocol" , strBuff)
	if not req then
		print('FactionManager:doRetFactionVoiceJoinRoom '..tostring(err) .. ",roleid:" .. tostring(roleSID))
		g_FactionServlet:sendErrMsg2Client(cPlayer:getID(), FACTION_VOICE_JOIN_ROOM_FAILED, 0)
		return
	end

	fireProtoMessage(cPlayer:getID(), FACTION_VOICE_SC_JOIN_ROOM, "FactionVoiceJoinRoomRetProtocol", req);
end

--退出房间-- 此协议可以不处理
function FactionServlet:onFactionVoiceExitRoom( buffer1 )
	local params = buffer1:getParams();
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("FactionVoiceExitRoomProtocol" , buffer)
	if not req then
		print('FactionServlet:onFactionVoiceExitRoom '..tostring(err))
		return
	end

	local cPlayer = g_entityMgr:getPlayerBySID(dbid);
	if not cPlayer then
		print("FactionServlet:onFactionVoiceExitRoom Palyer Not Exist,dbid:"..tostring(dbid));
	end

	local nFactionId = cPlayer:getFactionID();

end

--关闭房间
function FactionServlet:onFactionVoiceCloseRoom( buffer1 )
	local params = buffer1:getParams();
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("FactionVoiceJoinRoomProtocol" , buffer)
	if not req then
		print('FactionServlet:onFactionVoiceCloseRoom '..tostring(err))
		return
	end

	local cPlayer = g_entityMgr:getPlayerBySID(dbid);
	if not cPlayer then
		print("FactionServlet:onFactionVoiceCloseRoom Palyer Not Exist,dbid:"..tostring(dbid));
	end

	local nFactionId = cPlayer:getFactionID();

	local cFaction = g_factionMgr:getFaction(nFactionId);
	if not cFaction then
		print("FactionServlet:onFactionVoiceCloseRoom cFaction Not Exist,dbid:"..tostring(dbid)..",factionid:"..tostring(nFactionId));
		return
	end	

	--只有指挥者能关闭房间
	if dbid ~= cFaction:getCommandId() then
		g_FactionServlet:sendErrMsg2Client(cPlayer:getID(), FACTION_VOICE_CREATE_ROOM_PERMISSION_ERROR, 0)
		return
	end

	local tVoiceInfo = g_factionMgr:getFactionVoiceInfo(nFactionId)
	if not tVoiceInfo  then
		self:sendErrMsg2Client(cPlayer:getID(), FACTION_VOICE_EXIT_ROOM_NOT_EXIST, 0)
	end 

	g_tFactionVoiceMgr:CloseVoiceRoom(dbid,nFactionId,tVoiceInfo[1],tVoiceInfo[2],tVoiceInfo[3]);

	self:BroadcastRoomClose(nFactionId);

	g_factionMgr:clearFactionVoiceInfo(nFactionId)
end

--设定指挥者
function FactionServlet:onSetFactionCommandId( buffer1 )
	--print("----------------a----------------")
	local params = buffer1:getParams();
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("FactionCommandSetUserIdProtocol" , buffer)
	if not req then
		print('FactionServlet:onSetFactionCommandId '..tostring(err))
		return
	end
	--print("----------------b----------------")
	--权限检查
	local cPlayer = g_entityMgr:getPlayerBySID(dbid);
	if not cPlayer then
		print("FactionServlet:onSetFactionCommandId Palyer Not Exist,dbid:"..tostring(dbid));
		return;
	end
	--print("----------------c----------------")
	local nFactionId = cPlayer:getFactionID();

	local cFaction = g_factionMgr:getFaction(nFactionId);
	if not cFaction then
		print("FactionServlet:onSetFactionCommandId cFaction Not Exist,dbid:"..tostring(dbid)..",factionid:"..tostring(nFactionId));
		return
	end	
	--print("----------------d----------------")
	--帮主和副帮主能设定指挥者
	local leaderMem = cFaction:getMember(dbid)
	if leaderMem:getPosition() ~= FACTION_POSITION.Leader and leaderMem:getPosition() ~= FACTION_POSITION.AssociateLeader and dbid ~= cFaction:getCommandId() then
		self:sendErrMsg2Client(cPlayer:getID(), FACTION_SET_COMMAND_PERMISSION_ERROR, 0)
		return
	end
	--print("----------------e----------------")
	-- local tCommandMember = cFaction:getMember(req.memberid);
	-- if not tCommandMember then
	-- 	self:sendErrMsg2Client(cPlayer:getID(), FACTION_SET_COMMAND_DBID_ERROR, 0)
	-- 	return
	-- end
	cFaction:setCommandId(req.memberid)
	cFaction:setFactionSyn(true)

	local ret = {}
	ret.memberid = req.memberid
	fireProtoMessage(cPlayer:getID(), FACTION_COMMAND_SC_SET_USERID, "FactionCommandSetUserIdRetProtocol", ret)

	local ntf = {}
	ntf.memberid = req.memberid
	g_factionMgr:sendProtoMsg2AllMem(nFactionId, FACTION_COMMAND_SC_NTF_USERID, "FactionCommandSetUserIdNtfProtocol", ntf)
end


--行会会长绑定行会QQ群
function FactionServlet:onBindFactionOpenId( buffer1 )
	print("FactionServlet:onBindFactionOpenId req")
	local params = buffer1:getParams();
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("FactionOpenIdBind" , buffer)
	if not req then
		print('FactionServlet:onBindFactionOpenId '..tostring(err))
		return
	end
	
	if #(req.openId) > 32 then
		print('FactionServlet:onBindFactionOpenId openId too long: '..(req.openId))
		return
	end

	--权限检查
	local cPlayer = g_entityMgr:getPlayerBySID(dbid);
	if not cPlayer then
		print("FactionServlet:onBindFactionOpenId Palyer Not Exist,dbid:"..tostring(dbid));
		return;
	end
	
	local nFactionId = cPlayer:getFactionID();

	local cFaction = g_factionMgr:getFaction(nFactionId);
	if not cFaction then
		print("FactionServlet:onBindFactionOpenId cFaction Not Exist,dbid:"..tostring(dbid)..",factionid:"..tostring(nFactionId));
		self:sendErrMsg2Client(cPlayer:getID(), FACTION_OPENID_BIND_FACTIONID_ERROR, 0)
		return
	end	
	
	if nFactionId ~= req.factionID then
		print("FactionServlet:onBindFactionOpenId cFaction invalid,dbid:"..tostring(dbid)..",factionid:"..tostring(nFactionId).."req:"..tostring(req.factionID));
		self:sendErrMsg2Client(cPlayer:getID(), FACTION_OPENID_BIND_FACTIONID_ERROR, 0)
		return
	end

	--帮主绑定QQ群
	local leaderMem = cFaction:getMember(dbid)
	if leaderMem:getPosition() ~= FACTION_POSITION.Leader then
		self:sendErrMsg2Client(cPlayer:getID(), FACTION_OPENID_BIND_PERMISSION_ERROR, 0)
		return
	end

	cFaction:setOpenId(req.openId)
	cFaction:setFactionSyn(true)
	--self:sendErrMsg2Client(cPlayer:getID(), FACTION_OPENID_BIND_SUCESS, 0)
	
	--local buff = LuaEventManager:instance():getLuaRPCEvent(FACTION_OPENID_SC_BIND_RET)		
	--g_engine:fireLuaEvent(cPlayer:getID(), buff)
end

--获取行会绑定QQ群
function FactionServlet:onGetFactionOpenId( buffer1 )
	print("FactionServlet:onGetFactionOpenId req")
	local params = buffer1:getParams();
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local cPlayer = g_entityMgr:getPlayerBySID(dbid);
	if not cPlayer then
		print("FactionServlet:onGetFactionOpenId Palyer Not Exist,dbid:"..tostring(dbid));
		return;
	end
	
	local openId = ""
	local nFactionId = cPlayer:getFactionID();
	local cFaction = g_factionMgr:getFaction(nFactionId);

	if cFaction then
		openId = cFaction:getOpenId()
	end	
	
	print("FactionServlet:onGetFactionOpenId ret ", nFactionId, openId)
	local ret = {}
	ret.openId = openId
	fireProtoMessage(cPlayer:getID(), FACTION_OPENID_SC_NTF, "FactionOpenIdNotify", ret)
end

--获取行会军机处数据
function FactionServlet:onGetEventRd( buffer1 )
	print("FactionServlet:onGetEventRd req")
	local params = buffer1:getParams();
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("FactionGetEventRd" , buffer)
	if not req then
		print('FactionServlet:onGetEventRd '..tostring(err))
		return
	end

	g_factionMgr:getEventRd(dbid)
end

function FactionServlet.getInstance()
	return FactionServlet()
end

g_FactionServlet = FactionServlet.getInstance()

g_eventMgr:addEventListener(FactionServlet.getInstance())