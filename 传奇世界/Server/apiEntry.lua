--apiEntry.lua
apiEntry = {}

g_miniplayers = {}

function apiEntry.onFastFrame()
	lua_mem_gc()
	lua_whole_clock()
end

--切换world的通知
function apiEntry.onSwitchWorld(roleID, peer, dbid, mapId, buff)
	apiEntry.switchCount = 0
	local headBuf = tolua.cast(buff, "LuaMsgBuffer")
	if headBuf then
		--第一类转移
		local luaBuf = g_buffMgr:getExchangeLuaBuffer()
		g_listHandler:notifyListener("onSwitchWorld", roleID, luaBuf)
		headBuf:pushShort(apiEntry.switchCount)
		headBuf:append(luaBuf)
		g_engine:fireSwitchBuffer(peer, mapId, headBuf)
		--第二类转移
		g_listHandler:notifyListener("onSwitchWorld2", roleID, peer, dbid, mapId)
	end
end

--切换到本world的通知
function apiEntry.onPlayerSwitch(roleID, buff)
	local luabuf = tolua.cast(buff, "LuaMsgBuffer")
	local player = g_entityMgr:getPlayer(roleID)
	local count = luabuf:popShort()
	if player and luabuf then
		for idx = 1, count do
			local type = luabuf:popShort()
			g_listHandler:notifyListener("onPlayerSwitch", player, type, luabuf)
		end
	end
end

--切换到本world的通知
function apiEntry.onPlayerSwitch2(roleID, type, buff)
	local luabuf = tolua.cast(buff, "LuaMsgBuffer")
	local player = g_entityMgr:getPlayer(roleID)
	if player and luabuf then
		if type == EVENT_ACTIVITY_SETS then
			local modelID = luabuf:popInt()
			local activityID = luabuf:popInt()
			g_ActivityMgr:playerSwitch(player:getSerialID(), modelID, activityID, luabuf)
		else
			g_listHandler:notifyListener("onPlayerSwitch", player, type, luabuf)
		end
	end
end

--玩家删除的消息
function apiEntry.onPlayerDelete(roleSID)
	g_listHandler:notifyListener("onPlayerDelete", roleSID)
end

--玩家登陆的消息
function apiEntry.onPlayerLoaded(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	if player then
		--Tlog[PlayerRegister]第一次登录
		if player:getLoginCnt() == 0 then
			g_tlogMgr:TlogPlayerRegister(player)
		end

		player:setLoginCnt(player:getLoginCnt() + 1)
		g_listHandler:notifyListener("onPlayerLoaded", player)
		
		--Tlog[PlayerLogin]其他模块需要准备登入Tlog需要记录的数据?
		local friendNum = g_relationMgr:getFriendNum(roleID)
		local factionlv = 0
		local faction = g_factionMgr:getFaction(player:getFactionID())
		if faction then
			factionlv = faction:getLevel()
		end
		g_tlogMgr:TlogPlayerLogin(player,friendNum,factionlv)
	end
end

--玩家掉线的消息
function apiEntry.onPlayerInactive(roleID)
    local player = g_entityMgr:getPlayer(roleID)
	if player then
		g_listHandler:notifyListener("onPlayerInactive",player)
	end 
end

--玩家离线的消息
function apiEntry.onPlayerOffLine(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	if player then
		local friendNum = g_relationMgr:getFriendNum(roleID)
		local factionlv = 0
		local faction = g_factionMgr:getFaction(player:getFactionID())
		if faction then
			factionlv = faction:getLevel()
		end

		g_listHandler:notifyListener("onPlayerOffLine", player)
		local roleInfo = g_miniplayers[player:getSerialID()]
		if roleInfo then
			player:setOnlineTime(player:getOnlineTime() + (os.time() - roleInfo.onlineTime))
		end

		if player:getLastLogin() > 0 and os.time() > player:getLastLogin() then
			player:setOnceOnlineTime(os.time() - player:getLastLogin())
		end

		--Tlog[PlayerLogout]其他模块需要准备登出Tlog需要记录的数据?
		g_tlogMgr:TlogPlayerLogout(player,friendNum,factionlv)
		print("onPlayerOffLine",player:getOnceOnlineTime())
	end 
end

--头顶显示物品
function apiEntry.showDropItem(roleSID, itemID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		g_listHandler:notifyListener("onShowDropItem", player, itemID)
	end 
end

--获得头顶物品
function apiEntry.gotDropItem(roleSID, itemID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		g_listHandler:notifyListener("onGotDropItem", player, itemID)
	end 
end

--掉落头顶物品
function apiEntry.dropShowItems(roleSID,itemID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		g_listHandler:notifyListener("onDropShowItems", player, itemID)
	end 
end

function apiEntry.onPlayerCast2DB(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	if player then
		g_listHandler:notifyListener("onPlayerCast2DB",player)
	end 
end

function apiEntry.onMonsterStop(monsterID)
	g_listHandler:notifyListener("onMonsterStop", monsterID)
end

--玩家掉线登陆的消息
function apiEntry.onActivePlayer(roleID)	--掉线登陆
	local player = g_entityMgr:getPlayer(roleID)
	if player then
		g_listHandler:notifyListener("onActivePlayer",player)
	end 
end

--玩家战斗力改变
function apiEntry.battleChange(roleID, battle)
	local player = g_entityMgr:getPlayer(roleID)
	if player then
		g_listHandler:notifyListener("battleChanged", player, battle)
	end
end

function apiEntry.upSkillLevel(roleSID, skillId, level)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		g_taskMgr:NotifyListener(player, "onSkillLevelUp", level)
		if level >= 3 then
			g_taskMgr:NotifyListener(player, "onUpSkill")
		end
		if level == 4 then
			g_RedBagMgr:skillLevelUp(player)
		end
		if level == 5 then			

		end
	end
end

--玩家经验改变
function apiEntry.onExpChanged(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	if player then
		-- g_listHandler:notifyListener("onExpChanged", player)
		--经验频繁改变,跳过监听直接通知到系统
		g_RankMgr:onExpChanged(player)
		g_achieveMgr:onExpChanged(player)
	end 
end

--玩家升级消息
function apiEntry.onLevelChanged(roleID, oldLevel, level)
	local player = g_entityMgr:getPlayer(roleID)
	if player then
		g_listHandler:notifyListener("onLevelChanged", player, level, oldLevel)
	end 
end

--怪物被杀死消息
function apiEntry.onMonsterKill(monSID, roleID, monID, mapID)
	g_listHandler:notifyListener("onMonsterKill", monSID, roleID, monID, mapID)
	local xp, yieldRate, mul = 1, 100, 1	--经验倍率 收益加成概率 单个奖励倍数
	xp = xp + g_masterMgr:hasDoubleXP(roleID)
	yieldRate, mul = g_ActivityMgr:GetMonsterYieldRate(roleID, monSID)
	return yieldRate * 10000 + mul * 100 + xp
end

--怪物被杀死消息
function apiEntry.onMonsterHurt(monSID, roleID, hurt, monID)
	g_listHandler:notifyListener("onMonsterHurt", monSID, roleID, hurt, monID)
end

function apiEntry.onPkChanged(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	if player then
		g_RankMgr:pkChaneged(player)
		g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.pkChange, player:getPK())
	end
end

-- 金币改变
function apiEntry.onMoneyChange(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	if player then
		g_achieveSer:onMoneyChange(player:getSerialID())
	end
end

--玩家死亡消息
function apiEntry.onPlayerDied(roleID, killerID, bAchieve)
	local player = g_entityMgr:getPlayer(roleID)
	if player then
		if killerID > 0 and bAchieve then

		end		
		g_listHandler:notifyListener("onPlayerDied", player, killerID)
		return g_shaWarMgr:isInShaWar(player)
	end
	return 0
end

--玩家充值
function apiEntry.onRequestCharge(roleID, ctype, guid)	
	local player = g_entityMgr:getPlayer(roleID)
	if player then
		--已经有月卡了
		if ctype == 3 then
			--月卡不能继续冲			
			fireProtoSysMessage(FRAME_SC_CHARGE_REQ, roleID, EVENT_FRAME_SETS, -1, 0)
			return
		end

		local protoData = {
			charNo = guid,
			worldID = g_worldID,
		}
		fireProtoMessage(roleID, FRAME_SC_CHARGE_REQ, "FrameChargeRetProtocol", protoData)
	end
end

--玩家充值
function apiEntry.onPlayerCharge(roleSID, sourceIngot, ctype)	
	print("apiEntry.onPlayerCharge", roleSID, sourceIngot, ctype)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		g_listHandler:notifyListener("onPlayerCharge", player, sourceIngot, ctype)
	end 
	return sourceIngot
end

--玩家消耗元宝
function apiEntry.onPlayerConsume(roleSID, ingot)
	print("apiEntry.onPlayerConsume", roleSID, ingot)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		g_ActivityMgr:onPlayerConsume(player, ingot)
	end
end

--玩家装备提升
function apiEntry.equipDevelop(roleID, opType, equipId, level, param)
	local player = g_entityMgr:getPlayer(roleID)
	if player then
		g_listHandler:notifyListener("onEquipDevelop", player, opType, equipId, level, param)
	end 
end

--后台发送活动配置
function apiEntry.sendActivityConfig(command)
end

--后台发送世界福利配置
function apiEntry.sendRewardConfig(command)
end

--后台命令/cls 1:GM 2:踢人
function apiEntry.onBackCommand(cls, command)
	cls = toNumber(cls, 0)
	if cls == 1 then
		ShellSystem.getInstance():shellCmd(command)
	elseif cls == 2 then
		local roleSid = toNumber(command, 0)
		g_entityMgr:tickOutPlayer(roleSid, 3)
	end
end

--后台在线查询功能
function apiEntry.onOnlineQuery(cls, command)
	return ""
end

--活动参数
function apiEntry.onActivityPublish(cmdId, content)
	print("apiEntry.onActivityPublish", content)
	local dataPacket = unserialize(content)
	--写Tlog
	apiEntry.onDataPacketTlog(cmdId, dataPacket.body)
	--具体的一些处理
	local rsp_body = {Result = 0, RetMsg = "success"}
	if cmdId == 4203 then
		--增加运营活动
		rsp_body.ActivityId = dataPacket.body.ActivityId
		g_DataMgr:addActivity(dataPacket.body, rsp_body)
	elseif cmdId == 4207 then
		--修改运营活动
		g_DataMgr:updateActivity(dataPacket.body, rsp_body)
	elseif cmdId == 4209 then
		--删除运营活动
		g_DataMgr:deleteActivity(dataPacket.body, rsp_body)
	end
	local response = {head = dataPacket.head, body = rsp_body}
	response.head.Cmdid = cmdId + 1
	response.head.Result = 0
	return cjson.encode(response)
end

--后台数据包命令
function apiEntry.onDataPacket(cmdId, content)
	print("apiEntry.onDataPacket", content)
	--分发处理
	local dataPacket = unserialize(content)
	g_listHandler:notifyListener("onDataPacket", cmdId, dataPacket.body)
	--写Tlog
	apiEntry.onDataPacketTlog(cmdId, dataPacket.body)
	--具体的一些处理
	local player = g_entityMgr:getPlayerBySID(dataPacket.body.RoleId or dataPacket.body.OutRoleId)
	local result = apiEntry.onDataPacketDeal(player, cmdId, dataPacket.body, ret_params)
	--返回参数
	return result
end

function apiEntry.onDataPacketDeal(player, cmdId, data_body, ret_params)
	if player then
		if cmdId == 4133 then
			--禁言
			local lock_time = toNumber(data_body.Time, -1)
			player:setSpeakTick(lock_time > 0 and os.time() + lock_time or -1)
			player:setSilentReason(data_body.Reason or "")
		elseif cmdId == 4219 then
			--禁言
			local lock_time = toNumber(data_body.Time, -1)
			player:setSpeakTick(lock_time > 0 and os.time() + lock_time or -1)
			player:setSilentReason(data_body.BanChatReason or "")
		elseif cmdId == 4135 then
			--解除禁言
			player:setSpeakTick(0)
			player:setSilentReason("")
		elseif cmdId == 4229 then
			--解除禁言
			if data_body.UnBanChat then
				player:setSpeakTick(0)
				player:setSilentReason("")
			end
		elseif cmdId == 4115 then
			--删除绑元
			local bindRemain = player:getBindIngot() - data_body.GoldNum
			player:setBindIngot(bindRemain > 0 and bindRemain or 0)
		elseif cmdId == 4217 then
			--更新游戏币
			local moneyRemain = player:getMoney() + data_body.Num
			player:setMoney(moneyRemain > 0 and moneyRemain or 0)
		elseif cmdId == 4215 then			
			if data_body.Type == 1 then
				--更新元宝
			--	player:setIngot(data_body.Num)							
			elseif data_body.Type == 2 then
				--更新绑元
				local bindRemain = player:getBindIngot() + data_body.Num
				player:setBindIngot(bindRemain > 0 and bindRemain or 0)
			end
			if data_body.NeedLogin == 1 then
				g_entityMgr:tickOutPlayer(data_body.RoleId, 3)
			end
		elseif cmdId == 4117 then
			--删除物品
			local errorCode = 0
			local result_code = 10000000
			local deleteCnt, remainCnt = 0, 0
			local itemMgr = player:getItemMgr()
			if itemMgr then
				local bagCnt = itemMgr:getItemCount(data_body.ItemId, Item_BagIndex_Bag)
				local bankCnt = itemMgr:getItemCount(data_body.ItemId, Item_BagIndex_Bank)
				if bagCnt >= data_body.ItemNum then
					itemMgr:destoryItem(data_body.ItemId, data_body.ItemNum, errorCode)					
					deleteCnt = data_body.ItemNum
				else
					itemMgr:destoryItem(data_body.ItemId, bagCnt, errorCode)
					local needDelete = data_body.ItemNum - bagCnt
					if bankCnt >= needDelete then
						itemMgr:destoryItem(data_body.ItemId, needDelete, errorCode, Item_BagIndex_Bank)
						deleteCnt = data_body.ItemNum	
					else
						itemMgr:destoryItem(data_body.ItemId, bankCnt, errorCode, Item_BagIndex_Bank)
						deleteCnt = bagCnt + bankCnt
					end
				end	
				remainCnt = bagCnt + bankCnt - deleteCnt
			end			
			result_code = result_code + remainCnt * 1000 + deleteCnt
			return result_code 
		elseif cmdId == 4121 then
			--封角
			g_entityMgr:tickOutPlayer(data_body.RoleId, 3)
		elseif cmdId == 4227 then
			--封角
			g_entityMgr:tickOutPlayer(data_body.RoleId, 3)
		elseif cmdId == 4193 then 
			--踢出玩家
			g_entityMgr:tickOutPlayer(data_body.RoleId, 3)
		elseif cmdId == 4189 then
			--下架物品到寄售行
			g_entityMgr:downStall(data_body.RoleId, data_body.ItemId, data_body.ItemNum)
		elseif cmdId == 4191 then
			--强制转移物品(从背包/仓库)
			local itemMgr = player:getItemMgr()
			if itemMgr then
				itemMgr:trandItemByGuid(data_body.InRoleId, data_body.ItemId, data_body.ItemNum)
			end
		elseif cmdId == 4211 then
			--强制把收益包裹物品给其他人
			g_entityMgr:transStall2Email(data_body.OutRoleId, data_body.InRoleId, data_body.ItemId, data_body.ItemNum)
		end
	else
		if cmdId == 4125 then 
			--封号
			g_entityMgr:tickOutPlayerByOpenID(data_body.OpenId, 3)
		else
			--删除缓存
			if cmdId == 4133 or cmdId == 4219 or cmdId == 4135 or cmdId == 4115 or cmdId == 4117 or cmdId == 4191 or cmdId == 4217 or cmdId == 4215 then
				g_entityMgr:deleteCache(data_body.RoleId or data_body.OutRoleId)
			end
			--返回参数
			if cmdId == 4191 or cmdId == 4117 then				
				return 1
			end
		end
	end
	return 0
end

function apiEntry.onDataPacketTlog(cmdId, body)
	if cmdId == 4109 then	
		--IDIP_DO_MAIL_SEND_BIND_GOLD_REQ
		g_tlogMgr:TlogIDIPItemFlow(body.AreaId, body.OpenId, body.GoldId, body.GoldNum, body.Serial, body.Source, cmdId)
		print(string.format([[TLOG IDIP: IDIPHandselItemFlow|%s|%s|%d|%d|%d|%s|%d|%d]], 
			time.tostring(os.time()), body.OpenId, body.AreaId, body.GoldId or 0, body.GoldNum, body.Serial, body.Source, cmdId))
	elseif cmdId == 4111 then		
		--IDIP_DO_MAIL_SEND_MONEY_REQ
		g_tlogMgr:TlogIDIPItemFlow(body.AreaId, body.OpenId, body.GoldId, body.GoldNum, body.Serial, body.Source, cmdId)
		print(string.format([[TLOG IDIP: IDIPHandselItemFlow|%s|%s|%d|%d|%d|%s|%d|%d]], 
			time.tostring(os.time()), body.OpenId, body.AreaId, body.GoldId or 0, body.GoldNum, body.Serial, body.Source, cmdId))
	elseif cmdId == 4113 then
		--IDIP_DO_MAIL_SEND_ITEM_REQ
		g_tlogMgr:TlogIDIPItemFlow(body.AreaId, body.OpenId, body.ItemId, body.ItemNum, body.Serial, body.Source, cmdId)
		print(string.format([[TLOG IDIP: IDIPHandselItemFlow|%s|%s|%d|%d|%d|%s|%d|%d]], 
			time.tostring(os.time()), body.OpenId, body.AreaId, body.ItemId, body.ItemNum, body.Serial, body.Source, cmdId))
	elseif cmdId == 4115 then
		--IDIP_DO_DEL_BIND_GOLD_REQ
		g_tlogMgr:TlogIDIPItemFlow(body.AreaId, body.OpenId, body.GoldId, body.GoldNum, body.Serial, body.Source, cmdId)	
		print(string.format([[TLOG IDIP: IDIPHandselItemFlow|%s|%s|%d|%d|%d|%s|%d|%d]], 
			time.tostring(os.time()), body.OpenId, body.AreaId, body.GoldId, body.GoldNum, body.Serial, body.Source, cmdId))
	elseif cmdId == 4117 then
		--IDIP_DO_DEL_ITEM_REQ
		g_tlogMgr:TlogIDIPItemFlow(body.AreaId, body.OpenId, body.ItemId, body.ItemNum, body.Serial, body.Source, cmdId)
		print(string.format([[TLOG IDIP: IDIPHandselItemFlow|%s|%s|%d|%d|%d|%s|%d|%d]], 
			time.tostring(os.time()), body.OpenId, body.AreaId, body.ItemId, body.ItemNum, body.Serial, body.Source, cmdId))
	end	
end

--执行技能脚本
function apiEntry.execSkill(roleID, scriptId, targetID)
	local player = g_entityMgr:getPlayer(roleID)
	if player then
		SkillScript.exec(player, scriptId, targetID)
	else
		local monster = g_entityMgr:getMonster(roleID)
		if monster then
			SkillScript.exec(monster, scriptId, targetID)
		end
	end 
end

--http异步回调
function apiEntry.onHttpResult(opId, result)
	g_listHandler:notifyListener("onHttpResult", opId, result)
end

--写一些数据
function apiEntry.writeRelation(roleID, buff)
	local player = g_entityMgr:getPlayer(roleID)
	local luaBuff = tolua.cast(buff, "LuaMsgBuffer")
	if player and luaBuff then
		--[[			
			local rides = { ... }
			local wings = { ... }
			luaBuff:pushLString(proto.encode("PBRide", rides))
			luaBuff:pushLString(proto.encode("PBWing", wings))
		]]
		g_rideMgr:writrRideInfo(roleID, luaBuff)
		g_wingMgr:writrWingInfo(roleID, luaBuff)
	end
end


--数据库回调的消息
function apiEntry.onExeSP(operationID, recordList,result)
	LuaDBAccess.onExeSP(operationID, recordList,result)
end

function apiEntry.exeSP(params,bNonNeedCallback,level)
	if not level then level=flushLevel end
	local la=CLuaArray:createLuaArray()
	la:setResult(nil,0,params)
	opId=g_dbProxy:callSP(la,bNonNeedCallback,level)
	la:destroyLuaArray()
	return opId
end

function apiEntry.exeSQL(sql,roleId)
	local opID = g_dbProxy:callSQL(roleId,sql)
	return opID
end

function apiEntry.onloadPassivityData(data)
	if data._result == 0 then
		g_relationMgr:onloadPassivityData(data)
	end
end

function apiEntry.onloadWingRole(data)
	local buff = tolua.cast(data, "LuaMsgBuffer")
	local bufftable = {}
	
	local roleSID = buff:popString()
	bufftable.wingID = buff:popInt()
	bufftable.wingSkill = buff:popString()
	bufftable.pomoteTime = buff:popInt()
	bufftable.successTime = buff:popInt()
	bufftable.state = buff:popInt()	

	g_wingMgr:onloadWingRole(roleSID, bufftable)

	--buff <<  roleid<< wingid << wingSkill << pomoteTime << winglevel << wingstar << successtime<<fightability<<state;
end

function apiEntry.onloadXunbao(data)
	if data._result == 0 then
		--g_XunBaoMgr:onloadXunbao(data)
	end
end

function apiEntry.onloadOffPlayer(data)
	local buff = tolua.cast(data, "LuaMsgBuffer")
	local bufftable = {}
	bufftable.name = buff:popString()
	bufftable.roleID = buff:popString()
	bufftable.sex = buff:popInt()
	bufftable.school = buff:popInt()
	bufftable.level = buff:popInt()
	bufftable.battle = buff:popInt()
	bufftable.glamour = buff:popInt()
	g_SpillFlowerMgr:LoadOffPlayer(bufftable)
end

function apiEntry.onloadOffGiveFlower(data)
	if data._result == 0 then	
		g_SpillFlowerMgr:loadGiveFlowerOffDataBack(data)
	end
end

--使用物品
function apiEntry.onMaterialUsed(effectID, inContext, outContext, useCnt)
	local incontext = tolua.cast(inContext, "UseItemInContext")	
	local outcontext = tolua.cast(outContext, "UseItemOutContext")	
	local src = incontext.srcRoleID
	local target = incontext.targetRoleID
	local effData = EffectRecord[effectID]
	if effData then
		local effType = effData.effectType
		local effect = EffectTypeMap[effType](effData)
		local ret = effect:doTest(src, target, incontext, outcontext, useCnt)
		if ret then
			return effect:doEffect(src, target, incontext, outcontext, useCnt)
		else
			return 0
		end
	end
	return 0
end

--数据库加载回调
function apiEntry.yxtest(teamData)
	teamData = tolua.cast(teamData, "FightTeamData")
	teamData.fightTeamID = 111
	teamData.teamName = "云峰"
	teamData.win = 10
	for i = 1, 3 do
		teamData.members[i].roleSID = i
		teamData.members[i].name = "haha"
	end
end

--数据库加载回调
function apiEntry.onCallSp(roleID, tabName, datas)
	local player = g_entityMgr:getPlayer(roleID)
	if player then
		g_listHandler:notifyListener("onCallSp", player, tabName, datas)	
	end 
end

--全局数据加载回调
function apiEntry.onLoadAll(key, value, tabName, key2)
	if tabName == "faction" then
		FactionManager.loadFaction(key, value, key2)
	elseif tabName == "factionmem" then	
		FactionManager.loadFactionMember(key, value, key2)
	elseif tabName == "allcopy" then	
		CopyManager.onLoadCopyData(key, value, key2)
	elseif tabName == "allpvp" then	
		SinpvpServlet.onLoadRank(key, value)
	end
end

--切地图
function apiEntry.onSwitchScene(roleID, mapID, lastMapID)
	local player = g_entityMgr:getPlayer(roleID)
	if player then
		g_listHandler:notifyListener("onSwitchScene", player, mapID, lastMapID)
	end 
end

function apiEntry.onSwitchLine(roleID, lineID, lastLineID)
	local player = g_entityMgr:getPlayer(roleID)
	if player then
		g_listHandler:notifyListener("onSwitchLine", player, lineID, lastLineID)
	end 
end

function apiEntry.onPlayerMoveInCeremony(roleID)
	g_listHandler:notifyListener("onPlayerMoveInCeremony", roleID)
end

--获取配置的UTF8字符串
function apiEntry.getStrByKey(key)
    local str_tab = require "data.StringCfg"
    if str_tab[key] then
        return str_tab[key]
    else
        return ""
    end  
end

--玩家复活的消息
function apiEntry.onPlayerRelive(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	if player then
		g_listHandler:notifyListener("onPlayerRelive", player)
	end
end

--创建3v3队伍
function apiEntry.create3V3Team(teamA, teamB)
	g_TeamPublic:createTeamBySIDList(teamA)
	g_TeamPublic:createTeamBySIDList(teamB)
end

--解散3v3队伍
function apiEntry.leave3V3Team(fights)
	g_TeamPublic:leaveTeamBySIDList(fights)
end

-- 添加队伍成员
function apiEntry.memJoinTeamBySID(roleSID, teamID)
	g_TeamPublic:memJoinTeamBySID(teamID, roleSID)
end

--缓存回调接口
function apiEntry.onCchePlayer(roleId, roleSid, field, cacha_buf)
	local player_cache_callback_list = {
		--[FIELD_PVP] = SinpvpMgr.loadDBData,
		[FIELD_TASK] = TaskManager.loadDBData,
		[FIELD_TASK2] = TaskManager.loadDBData2,
		[FIELD_COMMON] = CommonManager.loadDBData,
		[FIELD_DIGMINE] = DigMineManager.loadDBData,
		[FIELD_TRADE] = TradeManager.loadDBData,
		[FIELD_GAMESET] = GameSetManager.loadDBData,
		[FIELD_RIDE] = RideManager.loadDBData,
		[FIELD_ACHIEVE] = AchieveManager.loadAchieveDBData,
		[FIELD_ACHIEVE_EVENT] = AchieveManager.loadAchieveEventDBData,
		[FIELD_TITLE] = AchieveManager.loadTitleDBData,
		[FIELD_ADORE] = AdoreManager.loadDBData,
		[FIELD_LITTLEFUN] = LitterfunManager.loadDBData,
		[FIELD_MYSTERYSHOP] = MysteryShopManager.loadDBData,
		[FIELD_ROLECHAT] = ChatSystem.loadDBData,
		[FIELD_GIVEWINE] = GiveWineManager.loadDBData,
		[FIELD_GIVEFLOWER] = SpillFlowerManager.loadDBData,
		[FIELD_PLAYERDROPITEM] = PlayerDropItemManager.loadDBData,
		[FIELD_COMPETITION] = CompetitionManager.loadDBData,
		[FIELD_MASTER] = MasterManager.loadDBData2,
		[FIELD_PLAYESECONDPASS] = SecondPassManager.loadDBData,
		[FIELD_RELATION] = RelationManager.loadDBData,
		[FIELD_ACTIVITY_NORMAL] = ActivityNormalManager.loadDBData,
		[FIELD_QQVIP_INFO] = QQVipRewardManger.loadDBData,
		[FIELD_ENVOY_INFO] = EnvoyManager.loadDBData,
		[FIELD_TREASURE] = TreasureManger.loadDBData,
 	}
	local player = g_entityMgr:getPlayer(roleId)
	if player then
		if player_cache_callback_list[field] and type(player_cache_callback_list[field]) == "function" then
			player_cache_callback_list[field](player, cacha_buf, roleSid)
		end
	end
end

function apiEntry.onGetMaxFactionID(id)
	g_factionMgr:setMaxFactionID(id)
end
function apiEntry.onGetMaxSwornID(id)
	g_swornBrosMgr:setMaxSwornID(id)
end
function apiEntry.onGetMaxRewardTaskGUID(id)
	g_RewardTaskMgr:onLoadMaxTaskID(id)
end

--[[
function apiEntry.onGetMaxMarriageID(id)
	g_marriageMgr:setMaxMarriageID(id)
end
]]

function t()
	local resp_body = {
		[999] = {6, 7, 8} 
	}
	
	cjson.encode_sparse_array(true)
	print(cjson.encode(resp_body))

	local resp_body2 = {
		[99] = {6, 7, 8} 
	}
	print(cjson.encode(resp_body2))
end

function t2()
	mt2 = {}
	mt2.__index = function (t, k)
		return t[k]
	end

	a = {vtbl = {} }	
	mt = {}
	mt.__index = function (t, k)
		return rawget(t.vtbl, k)
	end

	setmetatable(a, mt)
	setmetatable(a.vtbl, mt2)
	print(a[1])
end

function t3()
	local retBuff = g_buffMgr:getLuaEvent(20102)
	retBuff:pushInt(g_last_player)
	retBuff:pushChar(0)
	g_engine:fireWorldEvent(0, retBuff)
end

function t4(roleSID)
	g_entityMgr:dropItemToEmail(roleSID, 601001, FACTIONCOPY_REWARD_EMAIL_COFIG2, 107, 0, true, "1")
end
