--listen_packet.lua

------------------------------------------------------------------------------------
--若干全局函数
------------------------------------------------------------------------------------
--构建返回消息数据
function send_response_data(opid, phead, result, pbody)
	local response = {head = phead}
	response.head.Result = result
	response.head.Cmdid = phead.Cmdid + 1
	response.head.RetErrMsg = ERROR_MESSAGE_LIST[result] or ""	
	if result == 0 then response.body = pbody end

	--发送消息给中心服务器
	local ret_buff = g_luaBuffMgr:getLuaEvent(MANAGER_SM_COMMAND)
	ret_buff:pushShort(eDataPacket)
	ret_buff:pushInt(opid)
	ret_buff:pushString(cjson.encode(response))	
	ret_buff:pushString("")
	g_frame:send2Server(0, ret_buff)
end

------------------------------------------------------------------------------------
--若干框架函数
------------------------------------------------------------------------------------
listenPacket = {}

--查询包裹数据
function listenPacket.query_item_data(opid, head, body)
	local sql = string.format([[SELECT item.datas, player.Name FROM item, player WHERE groupIndex < 200 and item.roleID = '%s' 
			and player.roleID = item.roleID and player.UserID = '%s']], body.RoleId or "", body.OpenId or "")
	
	local resultCode = 1 
	local resp_body = {RoleNick = "", BagSize = 0, BagList_count = 0, BagList = {}}
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records then
		for i, record in pairs(records) do
			resultCode = 0
			resp_body.RoleNick = encodeURIValue(record.Name)
			resp_body.BagList_count, resp_body.BagSize = listenTool.parse_item_data(resp_body.BagList, record.datas, body.PageNo or 1)
		end
	end
	--处理查询结果
	send_response_data(opid, head, resultCode, resp_body)
	return resultCode == 0
end

--查询仓库数据
function listenPacket.query_bank_data(opid, head, body)
	local sql = string.format([[SELECT item.datas, player.Name FROM item, player WHERE groupIndex >= 200 and groupIndex < 300
			and item.roleID = '%s'  and player.roleID = item.roleID and player.UserID = '%s']], body.RoleId or "", body.OpenId or "")
	
	local resultCode = 1 
	local resp_body = {RoleNick = "", BagSize = 0, BagList_count = 0, BagList = {}}
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records then		
		for i, record in pairs(records) do
			resultCode = 0
			resp_body.RoleNick = encodeURIValue(record.Name)
			resp_body.BagList_count, resp_body.DepotSize = listenTool.parse_item_data(resp_body.BagList, record.datas, body.PageNo or 1)
		end	
	end
	--处理查询结果
	send_response_data(opid, head, resultCode, resp_body)
	return resultCode == 0
end

--查询装备数据
function listenPacket.query_equip_data(opid, head, body)
	local sql = string.format([[SELECT item.datas, player.Name FROM item, player WHERE groupIndex >= 300 and groupIndex < 400
			and item.roleID = '%s'  and player.roleID = item.roleID and player.UserID = '%s']], body.RoleId or "", body.OpenId or "")

	local resultCode = 1 
	local resp_body = {RoleNick = "", EquipList_count = 0, EquipList = {}}
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records then	
		for i, record in pairs(records) do	
			resultCode = 0 
			resp_body.RoleNick = encodeURIValue(record.Name)
			resp_body.EquipList_count = listenTool.parse_item_data(resp_body.EquipList, record.datas, 1)
		end
	end
	--处理查询结果
	send_response_data(opid, head, resultCode, resp_body)
	return resultCode == 0
end

--查询技能数据
function listenPacket.query_skill_data(opid, head, body)
	local sql = string.format([[SELECT skill.datas, player.Name FROM skill, player WHERE skill.roleID = '%s' 
			and player.roleID = skill.roleID and player.UserID = '%s']], body.RoleId or "", body.OpenId or "")
	
	local resultCode = 1 
	local resp_body = {RoleNick = "", SkillList_count = 0, SkillList = {}}
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records then
		if records[1] then
			resultCode = 0
			resp_body.RoleNick = encodeURIValue(records[1].Name)
			listenTool.parse_skill_data(resp_body, records[1].datas)
		end		
	end
	--处理查询结果
	send_response_data(opid, head, resultCode, resp_body)
	return resultCode == 0
end

--查询坐骑数据
function listenPacket.query_ride_data(opid, head, body)
	local sql = string.format([[SELECT ride.datas, player.Name FROM ride, player WHERE ride.roleID = '%s' 
			and player.roleID = ride.roleID and player.UserID = '%s']], body.RoleId or "", body.OpenId or "")
	
	local resultCode = 1 
	local resp_body = {RoleNick = "", SteelList_count = 0, SteelList = {}}
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records then
		if records[1] then
			resultCode = 0
			resp_body.RoleNick = encodeURIValue(records[1].Name)
			listenTool.parse_ride_data(resp_body, records[1].datas)
		end		
	end
	--处理查询结果
	send_response_data(opid, head, resultCode, resp_body)
	return resultCode == 0
end

--查询光翼数据
function listenPacket.query_wing_data(opid, head, body)
	local sql = string.format([[SELECT wing.*, player.Name FROM wing, player WHERE wing.roleID = '%s' 
			and player.roleID = wing.roleID and player.UserID = '%s']], body.RoleId or "", body.OpenId or "")
	
	local resultCode = 1 
	local resp_body = {}
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records then
		if records[1] then
			resultCode = 0
			resp_body.WingID = records[1].wingID
			resp_body.WingLevel = records[1].wingLevel
			resp_body.WingExp = records[1].wingStar
			resp_body.WingSkill = records[1].wingSkill
			resp_body.State = records[1].state
			resp_body.Fight = records[1].fightAbility
			resp_body.RoleNick = encodeURIValue(records[1].Name)
		end		
	end
	--处理查询结果
	send_response_data(opid, head, resultCode, resp_body)
	return resultCode == 0
end

--查询角色数据
function listenPacket.query_player_data(opid, head, body)
	local sql = ""
	if body.RoleId and body.RoleId ~= "0" then
		sql = string.format([[SELECT * FROM player WHERE player.roleID = '%s' and player.UserID = '%s']], 
			body.RoleId or "", body.OpenId or "")
	else
		sql = string.format([[SELECT player.* FROM player WHERE player.UserID = '%s']], body.OpenId or "")
	end

	local resultCode = 1 
	local resp_body = {RoleList = {}, RoleList_count = 0}
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records then		
		for i, record in pairs(records) do
			resultCode = 0
			resp_body.RoleList_count = resp_body.RoleList_count + 1
			resp_body.RoleList[i] = {}
			resp_body.RoleList[i].RoleId = record.RoleID
			resp_body.RoleList[i].RoleName = encodeURIValue(record.Name)
			resp_body.RoleList[i].Sex = record.Sex
			resp_body.RoleList[i].Job = record.School
			resp_body.RoleList[i].Exp = record.Exp
			resp_body.RoleList[i].Level = record.Level
			resp_body.RoleList[i].Scene = record.MapID
			resp_body.RoleList[i].Location = record.MapPos
			resp_body.RoleList[i].PkValue = record.PkValue
			resp_body.RoleList[i].Fight = record.Battle
			resp_body.RoleList[i].Guild = record.Faction
			resp_body.RoleList[i].Contribute = record.Contribute or 0
			resp_body.RoleList[i].Title = record.Title or 0
			resp_body.RoleList[i].Rank = record.Rank or 1000
			resp_body.RoleList[i].Charm = record.Glamour
			resp_body.RoleList[i].Gold = record.Ingot
			resp_body.RoleList[i].Money = record.Money		
			resp_body.RoleList[i].BindGold = record.Cash
			resp_body.RoleList[i].Reputation = record.Vital
			resp_body.RoleList[i].Exploit = record.Meritorious
			resp_body.RoleList[i].Smelting = record.SoulScore
			resp_body.RoleList[i].RedScoreNum = record.RedScoreNum or 0
			resp_body.RoleList[i].MedalLevel = record.MedalLevel
			resp_body.RoleList[i].TotalPay = record.IngotAll
			resp_body.RoleList[i].Time = record.OnlineTime
			resp_body.RoleList[i].TotalGoldConsume = 0
			resp_body.RoleList[i].LastLogoutTime = record.LastLogin
			resp_body.RoleList[i].RegisterTime = time.totime(record.CreateDate)
			resp_body.RoleList[i].IsOnline = (record.Status == 2) and 1 or 0
			resp_body.RoleList[i].ConsumeType = 0
			resp_body.RoleList[i].MedalExp = 0
		end
	end
	--处理查询结果
	send_response_data(opid, head, resultCode, resp_body)	
	return resultCode == 0
end

--查询角色数据
function listenPacket.query_lock_player_aq(opid, head, body)
	local sql = ""	
	if body.RoleId and body.RoleId == "0" then
		sql = string.format([[select player.Name, player.RoleID, lockplayer.LockDate from
			player LEFT JOIN lockplayer on player.RoleID = lockplayer.RoleID
			WHERE player.UserID = '%s']], body.OpenId or "")
	else
		sql = string.format([[select player.Name, player.RoleID, lockplayer.LockDate from
			player LEFT JOIN lockplayer on player.RoleID = lockplayer.RoleID
			WHERE player.RoleID = '%s']], body.RoleId or "")
	end

	local resultCode = 1
	local resp_body = { Num = 0, SampleRoleList_count = 0, SampleRoleList = {} }
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records then
		for i, record in pairs(records) do
			resultCode = 0			
			resp_body.Num = resp_body.Num + 1
			if not record.LockDate then record.LockDate = 0 end
			resp_body.SampleRoleList_count = resp_body.SampleRoleList_count + 1
			resp_body.SampleRoleList[i] = {}
			resp_body.SampleRoleList[i].RoleNick = encodeURIValue(record.Name)
			resp_body.SampleRoleList[i].RoleId = record.RoleID
			resp_body.SampleRoleList[i].Status = ((record.LockDate - os.time()) > 0) and 1 or 0
		end
	end
	--处理查询结果
	send_response_data(opid, head, resultCode, resp_body)
	return resultCode == 0
end

--查询角色数据(安全)
function listenPacket.query_player_data_aq(opid, head, body)
	local sql = string.format([[SELECT * FROM player WHERE player.roleID = '%s' and player.UserID = '%s']], 
			body.RoleId or 0, body.OpenId or "")

	local resp_body = {}
	local resultCode = 1 
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records and records[1] then		
		resultCode = 0
		resp_body.Gold = records[1].Money		
		resp_body.Ingot = records[1].Ingot
		resp_body.BindIngot = records[1].Cash
		resp_body.CommunityID = records[1].Faction
		resp_body.RoleName = encodeURIValue(records[1].Name)
	end
	--处理查询结果
	send_response_data(opid, head, resultCode, resp_body)	
	return resultCode == 0
end

--激活账号，白名单
function listenPacket.request_active_user(opid, head, body)
	local sql = string.format("replace into whitelist (OpenId, Status) values ('%s', %d)", body.OpenId or "", body.Level or 2)
	mysql_callSQL(mysql_game, sql)
	--处理查询结果
	send_response_data(opid, head, 0, {Result = 0, RetMsg = "success"})
	return true
end

--封账号
function listenPacket.request_lock_user(opid, head, body)
	local sql = string.format("select count(*) as UserCount from user where Username = '%s'", body.OpenId or "")
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records and records[1] and tonumber(records[1].UserCount) > 0 then
		local reason = body.BanReason or ""
		if not body.Time then body.Time = 120 end
		local tick = body.Time > 0 and (os.time() + body.Time) or -1
		local sql = string.format("replace into lockuser (OpenId, LockDate, LockReason) values ('%s', %d, '%s')", body.OpenId or "", tick, reason)
		mysql_callSQL(mysql_game, sql)
		--处理查询结果
		send_response_data(opid, head, 0, {Result = 0, RetMsg = "success"})
		return true
	else
		send_response_data(opid, head, 1)
		return false
	end
end

--解封账号
function listenPacket.request_unlock_user(opid, head, body)
	local sql = string.format("select count(*) as UserCount from user where Username = '%s'", body.OpenId or "")
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records and records[1] and tonumber(records[1].UserCount) > 0 then
		local sql = string.format("UPDATE lockuser SET LockDate = 0, LockReason = '' WHERE OpenId = '%s'", body.OpenId or "")
		mysql_callSQL(mysql_game, sql)
		--处理查询结果
		send_response_data(opid, head, 0, {Result = 0, RetMsg = "success"})
		return true
	else
		send_response_data(opid, head, 1)
		return false
	end
end

--查询封账号
function listenPacket.query_lock_user(opid, head, body)
	local sql = string.format("select lockuser.* from lockuser, user WHERE OpenId = '%s' and user.Username = '%s'", body.OpenId or 0, body.OpenId or "")
	local result, records = mysql_callSQL(mysql_game, sql)

	local resp_body = {}
	local result_code = 1
	if result and records and records[1] then
		result_code = 0
		resp_body.BanEndTime = records[1].LockDate
		resp_body.BanReason = encodeURIValue(records[1].LockReason)
		resp_body.Status = (records[1].LockDate - os.time() > 0) and 1 or 0
		resp_body.Time = (records[1].LockDate - os.time() > 0) and records[1].LockDate - os.time() or 0
	end
	--处理查询结果
	send_response_data(opid, head, result_code, resp_body)
	return result_code == 0
end

--封角色
function listenPacket.request_lock_player(opid, head, body)
	local sql = string.format([[select count(*) as PlayerCount from player where 
		player.roleID = '%s' and player.UserID = '%s']], body.RoleId or "", body.OpenId or "")
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records and records[1] and tonumber(records[1].PlayerCount) > 0 then
		local reason = body.BanReason or ""
		if not body.Time then body.Time = 120 end
		local tick = body.Time > 0 and (os.time() + body.Time) or -1
		local sql = string.format([[replace into lockplayer (RoleID, LockDate, LockReason) values ('%s', %d, '%s')]], body.RoleId or "", tick, reason)
		mysql_callSQL(mysql_game, sql)
		--处理查询结果
		send_response_data(opid, head, 0, {Result = 0, RetMsg = "success"})
		return true
	else
		send_response_data(opid, head, 1)
		return false
	end
end

--封角色
function listenPacket.request_lock_player_aq(opid, head, body)
	local sql = string.format([[select count(*) as PlayerCount from player where 
		player.roleID = '%s' and player.UserID = '%s']], body.RoleId or "", body.OpenId or "")
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records and records[1] and tonumber(records[1].PlayerCount) > 0 then
		local reason = body.BanUserReason or ""
		if not body.Time then body.Time = 120 end
		local tick = body.Time > 0 and (os.time() + body.Time) or -1
		local sql = string.format([[replace into lockplayer (RoleID, LockDate, LockReason) values ('%s', %d, '%s')]], body.RoleId or "", tick, reason)
		mysql_callSQL(mysql_game, sql)
		--处理查询结果
		send_response_data(opid, head, 0, {Result = 0, RetMsg = "success"})
		return true
	else
		send_response_data(opid, head, 1)
		return false
	end
end

--解封角色
function listenPacket.request_unlock_player(opid, head, body)
	local sql = string.format([[select count(*) as PlayerCount from player where 
		player.roleID = '%s' and player.UserID = '%s']], body.RoleId or "", body.OpenId or "")
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records and records[1] and tonumber(records[1].PlayerCount) > 0 then
		local sql = string.format([[UPDATE lockplayer SET LockDate = 0, LockReason = '' WHERE RoleID = '%s']], body.RoleId or "")
		mysql_callSQL(mysql_game, sql)
		send_response_data(opid, head, 0, {Result = 0, RetMsg = "success"})
		return true
	else
		send_response_data(opid, head, 1)
		return false
	end
end

--解封角色
function listenPacket.request_unlock_player_aq(opid, head, body)
	local sql = string.format([[select count(*) as PlayerCount from player where 
		player.roleID = '%s' and player.UserID = '%s']], body.RoleId or "", body.OpenId or "")
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records and records[1] and tonumber(records[1].PlayerCount) > 0 then
		if body.UnBanUser == 1 then	
			local sql = string.format([[UPDATE lockplayer SET LockDate = 0, LockReason = '' WHERE RoleID = '%s']], body.RoleId or "")
			mysql_callSQL(mysql_game, sql)
		end
		if body.UnBanChat == 1 then	
			local sql = string.format([[update player set SpeakTick = 0, SilentReason = '' WHERE RoleID = '%s']], body.RoleId or "")
			mysql_callSQL(mysql_game, sql)
		end
		send_response_data(opid, head, 0, {Result = 0, RetMsg = "success"})
		return true
	else
		send_response_data(opid, head, 1)
		return false
	end
end

--查询封角色
function listenPacket.query_lock_player(opid, head, body)
	local sql = ""	
	if not body.RoleId then body.RoleId = 0	end
	if body.RoleId == 0 then
		sql = string.format([[select lockplayer.*, player.Name from lockplayer, player WHERE 
			player.UserID = '%s' and lockplayer.RoleID = player.RoleID]], body.OpenId or "")
	else
		sql = string.format([[select lockplayer.*, player.Name from lockplayer, player WHERE 
			lockplayer.RoleID = '%s' and lockplayer.RoleID = player.RoleID and player.UserID = '%s']],
			body.RoleId or "", body.OpenId or "")
	end

	local resultCode = 1
	local resp_body = { RoleBanList_count = 0, RoleBanList = {} }
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records then
		for i, record in pairs(records) do
			resultCode = 0
			resp_body.RoleBanList_count = resp_body.RoleBanList_count + 1
			resp_body.RoleBanList[i] = {}
			resp_body.RoleBanList[i].RoleName = encodeURIValue(record.Name)
			resp_body.RoleBanList[i].RoleId = record.RoleID
			resp_body.RoleBanList[i].BanEndTime = record.LockDate
			resp_body.RoleBanList[i].BanReason = encodeURIValue(record.LockReason)
			resp_body.RoleBanList[i].Status = ((record.LockDate - os.time()) > 0) and 1 or 0
			resp_body.RoleBanList[i].Time = ((record.LockDate - os.time()) > 0) and  (record.LockDate - os.time()) or 0
		end
	end
	--处理查询结果
	send_response_data(opid, head, resultCode, resp_body)
	return resultCode == 0
end

--转发给游戏服务器
function listenPacket.do_game_trans_data(opid, cmdId, head, body)
	local dataPaccket = {head = head, body = body}
	local lua_buff = g_luaBuffMgr:getLuaEventEx(MANAGER_MS_COMMAND)
	lua_buff:pushShort(eDataPacket)
	lua_buff:pushInt(opid)
	lua_buff:pushInt(cmdId)
	lua_buff:pushString(serialize(dataPaccket))
	g_frame:send2Server(listen_world_id, lua_buff)
end

--请求禁言
function listenPacket.request_lock_speak(opid, head, body)
	local sql = string.format([[select count(*) as PlayerCount from player where 
		player.roleID = '%s' and player.UserID = '%s']], body.RoleId or "", body.OpenId or "")
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records and records[1] and tonumber(records[1].PlayerCount) > 0 then
		if not body.Time then body.Time = 120 end
		local reason = body.Reason or ""
		local tick = body.Time > 0 and (os.time() + body.Time) or -1
		local sql = string.format([[update player set SpeakTick = %d, SilentReason = '%s' WHERE RoleID = '%s']], tick, reason, body.RoleId or "")
		mysql_callSQL(mysql_game, sql)
		send_response_data(opid, head, 0, {Result = 0, RetMsg = "success"})
		return true
	else
		send_response_data(opid, head, 1)
		return false
	end
end

--请求禁言
function listenPacket.request_lock_speak_aq(opid, head, body)
	local sql = string.format([[select count(*) as PlayerCount from player where 
		player.roleID = '%s' and player.UserID = '%s']], body.RoleId or "", body.OpenId or "")
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records and records[1] and tonumber(records[1].PlayerCount) > 0 then
		if not body.Time then body.Time = 120 end
		local reason = body.BanChatReason or ""
		local tick = body.Time > 0 and (os.time() + body.Time) or -1
		local sql = string.format([[update player set SpeakTick = %d, SilentReason = '%s' WHERE RoleID = '%s']], tick, reason, body.RoleId or "")
		mysql_callSQL(mysql_game, sql)
		send_response_data(opid, head, 0, {Result = 0, RetMsg = "success"})
		return true
	else
		send_response_data(opid, head, 1)
		return false
	end
end

--解除禁言
function listenPacket.request_unlock_speak(opid, head, body)
	local sql = string.format([[select count(*) as PlayerCount from player where 
		player.roleID = '%s' and player.UserID = '%s']], body.RoleId or "", body.OpenId or "")
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records and records[1] and tonumber(records[1].PlayerCount) > 0 then
		local sql = string.format([[update player set SpeakTick = 0, SilentReason = '' WHERE RoleID = '%s']], body.RoleId or "")
		mysql_callSQL(mysql_game, sql)
		send_response_data(opid, head, 0, {Result = 0, RetMsg = "success"})
		return true
	else
		send_response_data(opid, head, 1)
		return false
	end
end

--发送金币
function listenPacket.request_send_money(opid, head, body)
	if not body.GoldNum or body.GoldNum <= 0 then
		send_response_data(opid, head, ERROR_COUNT_NOT_VAILD)
		return false
	end
	local sql = string.format([[select count(*) as PlayerCount from player where 
		player.roleID = '%s' and player.UserID = '%s']], body.RoleId or "", body.OpenId or "")

	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records and records[1] and tonumber(records[1].PlayerCount) > 0 then
		send_response_data(opid, head, 0, {Result = 0, RetMsg = "success"})
		return true
	else
		send_response_data(opid, head, 1)
	end
	return false
end

--发送物品
function listenPacket.request_send_item(opid, head, body)
	if not body.ItemId or not g_item_protos[body.ItemId] then
		send_response_data(opid, head, ERROR_ITEMID_NOT_VAILD)
		return false
	end
	if not body.ItemNum or body.ItemNum <= 0 then
		send_response_data(opid, head, ERROR_COUNT_NOT_VAILD)
		return false
	end
	local sql = string.format([[select count(*) as PlayerCount from player where 
		player.roleID = '%s' and player.UserID = '%s']], body.RoleId, body.OpenId)

	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records and records[1] and tonumber(records[1].PlayerCount) > 0 then
		send_response_data(opid, head, 0, {Result = 0, RetMsg = "success"})
		return true
	else
		send_response_data(opid, head, 1)
		return false
	end
end

--群发邮件
function listenPacket.request_send_group(opid, head, body)
	if not body.ItemList or #body.ItemList <= 0 then
		send_response_data(opid, head, ERROR_ITEMID_NOT_VAILD)
		return false
	end
	for i, item_info in pairs(body.ItemList) do
		if not item_info.ItemId or not g_item_protos[item_info.ItemId] then
			send_response_data(opid, head, ERROR_ITEMID_NOT_VAILD)
			return false
		end
		if not item_info.ItemNum or item_info.ItemNum <= 0 then
			send_response_data(opid, head, ERROR_COUNT_NOT_VAILD)
			return false
		end
	end

	listenPacket.do_game_trans_data(opid, head.Cmdid, head, body)
	send_response_data(opid, head, 0, {Result = 0, RetMsg = "success", EventId = body.EventId})
	return false
end

--删除物品
function listenPacket.request_delete_item(opid, head, body)
	if not body.ItemId or not g_item_protos[body.ItemId] then
		send_response_data(opid, head, ERROR_ITEMID_NOT_VAILD)
		return false
	end
	if not body.ItemNum or body.ItemNum <= 0 or body.ItemNum > 999 then
		send_response_data(opid, head, ERROR_COUNT_NOT_VAILD)
		return false
	end
	--转发给服务器先处理
	listenPacket.do_game_trans_data(opid, head.Cmdid, head, body)
	return false
end

--删除绑元
function listenPacket.request_delete_cash(opid, head, body)
	local result, remain = listenTool.delete_player_cash(body.RoleId, body.GoldNum)
	if result then
		local rsp_body = {
			OpenId = body.OpenId, RoleId = body.RoleId, ItemId = body.GoldId, SuccessDelGoldNum = body.GoldNum, RemainBindGoldNum = remain,
		}
		send_response_data(opid, head, 0, rsp_body)
		return true
	else
		send_response_data(opid, head, 1, {})
		return false
	end
end

--更新金币
function listenPacket.request_update_money_aq(opid, head, body)
	local result = listenTool.update_player_money(body.RoleId, body.Num)
	if result then
		send_response_data(opid, head, 0, {Result = 0, RetMsg = "success"})
		return true
	else
		send_response_data(opid, head, 1, {})
		return false
	end
end

--更新元宝
function listenPacket.request_update_ingot_aq(opid, head, body)
	if body.Type == 1 then			--元宝
		local result = listenTool.update_player_ingot(body.RoleId, body.Num)
		if result then
			send_response_data(opid, head, 0, {Result = 0, RetMsg = "success"})
			return true
		else
			send_response_data(opid, head, 1, {})
			return false
		end
	elseif body.Type == 2 then		--绑元
		local result = listenTool.update_player_cash(body.RoleId, body.Num)
		if result then
			send_response_data(opid, head, 0, {Result = 0, RetMsg = "success"})
			return true
		else
			send_response_data(opid, head, 1, {})
			return false
		end
	else
		send_response_data(opid, head, ERROR_AQ_INGOT_TYPE_VAILD)
		return false
	end
end

--踢出玩家
function listenPacket.request_tick_player(opid, head, body)
	local sql = string.format([[select count(*) as PlayerCount from player where 
	player.roleID = '%s' and player.UserID = '%s']], body.RoleId, body.OpenId)

	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records and records[1] and tonumber(records[1].PlayerCount) > 0 then
		send_response_data(opid, head, 0, {Result = 0, RetMsg = "success"})
		return true
	else
		send_response_data(opid, head, 1)
	end
	return false
end

--恢复角色
function listenPacket.request_recover_player(opid, head, body)
	local sql = string.format([[select player.RoleID, UNIX_TIMESTAMP(player.DeleteTime) as DeleteTick from player 
	where player.UserID = '%s']], body.OpenId)

	local roleCnt = 0
	local hasRole = false
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records then
		for i, record in pairs(records) do
			if tonumber(record.RoleID) == body.RoleId then hasRole = true end
			if tonumber(record.DeleteTick) == 0 then roleCnt = roleCnt + 1 end
		end
	end
	if roleCnt < 3 then
		if hasRole then
			sql = string.format([[update player set player.DeleteTime = 0 WHERE player.RoleID = '%s' and
				player.UserID = '%s']], body.RoleId, body.OpenId)
			mysql_callSQL(mysql_game, sql)
			send_response_data(opid, head, 0, {Result = 0, RetMsg = "success"})
			return true
		else
			send_response_data(opid, head, 1)
		end		
	else
		send_response_data(opid, head, ERROR_USER_ROLE_HAS_FULL)
	end
	return false
end

--查询昵称
function listenPacket.request_query_nick(opid, head, body)
	local sql = string.format([[select player.Name, player.Level, player.RoleID, player.LastLogin, player.UserID
		from player where player.Name like '%s']], body.Nick)

	local rsp_body = {
		Nick_count = 0,
		Nick = {},
	}
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records then
		for i, record in pairs(records) do
			if i > body.Page * 50 and i < (body.Page + 1) * 50 then
				local info = {
					AreaId = body.AreaId, PlatId = body.PlatId, Partition = body.Partition, 
					Level = record.Level,  RoleId = record.RoleID, RoleNick = encodeURIValue(record.Name), 
					OpenId = record.UserID, LastLoginTime = record.LastLogin, 
				}
				table.insert(rsp_body.Nick, info)
			end			
		end	
		rsp_body.Nick_count = #rsp_body.Nick
		send_response_data(opid, head, 0, rsp_body)
	else
		send_response_data(opid, head, 1)
	end
	return false
end

--查询累积信息
function listenPacket.request_total_info(opid, head, body)
	local sql = ""
	if body.RoleId == 0 then	
		sql = string.format([[select player.IngotAll, player.TotalGainIngot, player.TotalCosIngot, player.MonsterKillNum
		from player where player.UserID = '%s']], body.OpenId)
	else
		sql = string.format([[select IngotAll, TotalGainIngot, TotalCosIngot, MonsterKillNum
		from player where player.RoleID = '%s']], body.RoleId)
	end

	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records and #records > 0 then
		local rsp_body = {
			TotalPayGold = 0, TotalGetGold = 0, 
			TotalGoldConsume = 0,  TotalKillMonster = 0, 
		}
		for i, record in pairs(records) do
			rsp_body.TotalPayGold = rsp_body.TotalPayGold + (record.IngotAll or 0)
			rsp_body.TotalGetGold = rsp_body.TotalGetGold + (record.TotalGainIngot or 0)
			rsp_body.TotalGoldConsume = rsp_body.TotalGoldConsume + (record.TotalCosIngot or 0)
			rsp_body.TotalKillMonster = rsp_body.TotalKillMonster + (record.MonsterKillNum or 0)
		end
		send_response_data(opid, head, 0, rsp_body)
	else
		send_response_data(opid, head, 1)
	end
	return false
end

--查询等级排行榜
function listenPacket.request_level_rank(opid, head, body)
	local sql = "select Name, Level, RoleID, School from player order by Level desc limit 100"
	local rsp_body = {
		RankList = {},
		RankList_count = 0
	}
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records then
		for i, record in pairs(records) do	
			rsp_body.RankList_count = i
			local info = {
				Type = 1, Rank = i, Name = encodeURIValue(record.Name), Job = record.School,
				PlayerId = record.RoleID, Level = record.Level
			}
			table.insert(rsp_body.RankList, info)
		end
	end
	send_response_data(opid, head, 0, rsp_body)
	return false
end

--查询行会排行榜
function listenPacket.request_faction_rank(opid, head, body)
	local sql = "select name, factionID, level, ability from faction order by level desc, ability desc limit 100"
	local rsp_body = {
		GuildRankList = {},
		GuildRankList_count = 0
	}
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records then
		for i, record in pairs(records) do	
			rsp_body.GuildRankList_count = i
			local info = {
				Type = 2, Rank = i, GuildName = encodeURIValue(record.name), TotalFight = record.ability,
				GuildId = record.factionID, GuildLevel = record.level
			}
			table.insert(rsp_body.GuildRankList, info)
		end
	end
	send_response_data(opid, head, 0, rsp_body)
	return false
end

--查询恶人排行榜
function listenPacket.request_pk_rank(opid, head, body)
	local sql = "select Name, PkValue, RoleID, School from player order by PkValue desc limit 100"
	local rsp_body = {
		EvilRankList = {},
		EvilRankList_count = 0
	}
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records then
		for i, record in pairs(records) do	
			rsp_body.EvilRankList_count = i
			local info = {
				Type = 3, Rank = i, Name = encodeURIValue(record.Name), Job = record.School,
				PlayerId = record.RoleID, PkValue = record.PkValue
			}
			table.insert(rsp_body.EvilRankList, info)
		end
	end
	send_response_data(opid, head, 0, rsp_body)
	return false
end

--查询好友
function listenPacket.request_query_friend(opid, head, body)
	local sql = string.format([[select player.Name from player where 
		player.roleID = '%s' and player.UserID = '%s']], body.RoleId or "", body.OpenId or "")

	local rsp_body = {
		FriendList_count = 0,
		FriendList = {},
	}
	local resultCode = 1 
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records and records[1] and records[1].Name then
		resultCode = 0
		local roleNickName = records[1].Name
		local sql = string.format([[select player.Name, relation.targetRoleID, player.UserID from player, relation
			where relation.roleID = '%s' and relation.targetRoleID = player.RoleID and relation.type = %d]], body.RoleId, body.Type)
		local result, records = mysql_callSQL(mysql_game, sql)
		if result and records then
			for i, record in pairs(records) do
				if i > body.PageNo * 50 and i <= (body.PageNo + 1) * 50 then
					rsp_body.FriendList[i] = {}
					rsp_body.FriendList[i].Type = body.Type
					rsp_body.FriendList[i].AreaId = body.AreaId
					rsp_body.FriendList[i].PlatId = body.PlatId
					rsp_body.FriendList[i].Partition = body.Partition
					rsp_body.FriendList[i].RoleId = record.targetRoleID
					rsp_body.FriendList[i].RoleNick = encodeURIValue(roleNickName)
					rsp_body.FriendList[i].FriendNick = encodeURIValue(record.Name)
					rsp_body.FriendList[i].OpenId = record.UserID
				end
			end
			rsp_body.FriendList_count = #rsp_body.FriendList
		end
	end
	send_response_data(opid, head, resultCode, rsp_body)
	return false
end

--查询行会
function listenPacket.request_query_faction(opid, head, body)
	local sql = ""
	if body.RoleId and body.RoleId ~= "0" then
		sql = string.format([[select faction.* from player, faction where
			faction.factionID = player.Faction and player.RoleId = '%s']], body.RoleId)
	else
		sql = string.format([[select * from faction where factionID = %d]], body.GuildId)
	end

	local rsp_body = {}
	local resultCode = 1 
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records and records[1] then
		resultCode = 0
		rsp_body.GuildRank = 1
		rsp_body.RoleId = records[1].leaderID
		rsp_body.Fund = tonumber(records[1].money)
		rsp_body.GuildLevel = tonumber(records[1].level)
		rsp_body.Num = tonumber(records[1].allMemberCnt)
		rsp_body.TotalMoney = tonumber(records[1].money)
		rsp_body.GuildId = tonumber(records[1].factionID)
		rsp_body.ContainNum = tonumber(records[1].allMemberCnt)
		rsp_body.GuildName = encodeURIValue(records[1].name)
		rsp_body.Leader = encodeURIValue(records[1].leaderName)
		rsp_body.GuildNoticeContent = encodeURIValue(records[1].comment)
	end
	send_response_data(opid, head, resultCode, rsp_body)
	return false
end

--查询行会成员
function listenPacket.request_query_member(opid, head, body)
	local sql = ""
	if body.RoleId and body.RoleId ~= "0" then
		sql = string.format([[select rolefaction.* from player, rolefaction where
			rolefaction.factionID = player.Faction and player.RoleId = '%s']], body.RoleId)
	else
		sql = string.format([[select * from rolefaction where factionID = %d]], body.GuildId)
	end

	local rsp_body = {
		MemberList_count = 0,
		MemberList = {}
	}
	local resultCode = 1 
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records then
		resultCode = 0
		for i, record in pairs(records) do
			listenTool.parse_member_data(rsp_body, body.RoleId, record.datas)
		end
		rsp_body.MemberList_count = #rsp_body.MemberList		
	end
	send_response_data(opid, head, resultCode, rsp_body)
	return false
end

--查询行会申请列表
function listenPacket.request_query_apply(opid, head, body)
	local sql = ""
	if body.RoleId > 0 then
		sql = string.format([[select faction.apply from player, faction where
			faction.factionID = player.Faction and player.RoleId = '%s']], body.RoleId)
	else
		sql = string.format([[select apply from faction where factionID = %d]], body.GuildId)
	end
	local rsp_body = {
		ApplicationList_count = 0,
		ApplicationList = {}
	}
	local resultCode = 1 
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records and records[1] then
		resultCode = 0
		listenTool.parse_apply_data(rsp_body, records[1].apply)
		rsp_body.ApplicationList_count = #rsp_body.ApplicationList
	end
	send_response_data(opid, head, resultCode, rsp_body)
	return false
end

--查询行会社交
function listenPacket.request_query_social(opid, head, body)
	local sql = ""
	if body.RoleId and body.RoleId ~= "0" then
		sql = string.format([[select factionsocial.*, faction.* from player, faction, factionsocial where
			(factionsocial.AFactionID = faction.factionID or factionsocial.BFactionID = faction.factionID)
			and faction.factionID = player.Faction and player.RoleID = '%s']], body.RoleId)
	else
		sql = string.format([[factionsocial.*, faction.* from factionsocial, faction where
			(factionsocial.AFactionID = faction.factionID or factionsocial.BFactionID = faction.factionID) 
			and faction.factionID = %d]], body.GuildId)
	end
	local rsp_body = {
		DiplomacyList_count = 0,
		DiplomacyList = {}
	}
	local resultCode = 1 
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records then
		resultCode = 0
		for i, record in pairs(records) do
			rsp_body.DiplomacyList[i] = {}
			rsp_body.DiplomacyList[i].GuildRank = i
			rsp_body.DiplomacyList[i].RoleId = record.leaderID
			rsp_body.DiplomacyList[i].Status = tonumber(record.State)
			rsp_body.DiplomacyList[i].Num = tonumber(record.allMemberCnt)
			rsp_body.DiplomacyList[i].GuildId = tonumber(record.factionID)
			rsp_body.DiplomacyList[i].ContainNum = tonumber(record.allMemberCnt)
			rsp_body.DiplomacyList[i].GuildName = encodeURIValue(record.name)
			rsp_body.DiplomacyList[i].Leader = encodeURIValue(record.leaderName)
		end
		rsp_body.DiplomacyList_count = #rsp_body.DiplomacyList
	end
	send_response_data(opid, head, resultCode, rsp_body)
	return false
end

--查询行会贡献
function listenPacket.request_query_contribute(opid, head, body)
	local sql = ""
	if body.RoleId and body.RoleId ~= "0" then
		sql = string.format([[select factioncontrird.*, faction.name, faction.money from player, factioncontrird, faction where
			factioncontrird.RoleID = '%s' and factioncontrird.FactionID = player.Faction and 
			faction.factionID = player.Faction]], body.RoleId)
	else
		sql = string.format([[select factioncontrird.*, faction.name, faction.money from factioncontrird, faction where 
			factioncontrird.FactionID = %d and factioncontrird.factionID = factioncontrird.FactionID]], body.GuildId)
	end
	local rsp_body = {
		GuildContributeList_count = 0,
		GuildContributeList = {},
		Totalpage = 0,
	}
	local resultCode = 1
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records then
		resultCode = 0
		for i, record in pairs(records) do
			if i >= body.PageNo * 20 and i <= (body.PageNo + 1) * 20 then
				rsp_body.GuildContributeList[i] = {}
				rsp_body.GuildContributeList[i].RoleId = record.RoleID
				rsp_body.GuildContributeList[i].RoleName = encodeURIValue(record.RoleName)
				rsp_body.GuildContributeList[i].GuildName = encodeURIValue(record.name)
				rsp_body.GuildContributeList[i].Time = tonumber(record.ContriTime)
				rsp_body.GuildContributeList[i].TotalMoney = tonumber(record.money)
				rsp_body.GuildContributeList[i].Amount = tonumber(record.ContriNum)
				rsp_body.GuildContributeList[i].GuildId = tonumber(record.FactionID)
				rsp_body.GuildContributeList[i].BeginAmount = tonumber(record.FacMoneyBefore)
				rsp_body.GuildContributeList[i].EndAmount = tonumber(record.FacMoneyAfter)
			end	
		end	
		rsp_body.GuildContributeList_count = #rsp_body.GuildContributeList
		rsp_body.Totalpage = math.ceil(rsp_body.GuildContributeList_count / 20)
	end
	send_response_data(opid, head, resultCode, rsp_body)
	return false
end

--查询邮件
function listenPacket.request_player_email(opid, head, body)
	local sql = string.format([[select player.Name from player where
	player.roleID = '%s' and player.UserID = '%s']], body.RoleId or "", body.OpenId or "")
	
	local rsp_body = {
		AreaId = body.AreaId, 
		PlatId = body.PlatId, 
		Partition = body.Partition, 
		OpenId = body.OpenId, 
		RoleId = body.RoleId, 
		RoleName = "",

		TotalPageNo = 0,
		TotalCount = 0,
		MailList_count = 0,
		MailList = {},
	}
	local resultCode = 1 
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records and records[1] then
		resultCode = 0
		rsp_body.RoleName = encodeURIValue(records[1].Name)
		local sql = string.format([[select * from email where roleID = '%s']], body.RoleId or "")
		local result, records = mysql_callSQL(mysql_game, sql)
		if result and records then
			for i, record in pairs(records) do
				if i >= body.PageNo * 20 and i <= (body.PageNo + 1) * 20 then
					listenTool.parse_email_data(rsp_body, record.emailIndex, record.datas)
					rsp_body.MailList_count = rsp_body.MailList_count + 1
				end
			end
			rsp_body.TotalCount = #records
			rsp_body.TotalPageNo = math.ceil(#records / 20)
		end
	end
	send_response_data(opid, head, resultCode, rsp_body)
	return false
end

--查询交易行
function listenPacket.request_query_stall(opid, head, body)
	local sql = string.format([[select count(*) as PlayerCount from player where 
	player.roleID = '%s' and player.UserID = '%s']], body.RoleId or "", body.OpenId or "")
	
	local rsp_body = {
		TotalCount = 0,
		TotalPageNo = 1,
		DealList_count = 0,
		DealList = {},
	}
	local resultCode = 1 
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records and records[1] and tonumber(records[1].PlayerCount) > 0 then		
		resultCode = 0
		local sql = string.format([[select * from stall where roleID = '%s']], body.RoleId)
		local result, records = mysql_callSQL(mysql_game, sql)
		if result and records and records[1] then
			listenTool.parse_stall_data(rsp_body, records[1].datas)
		end
	end
	send_response_data(opid, head, resultCode, rsp_body)
	return false
end

--中转指令检查后直接返回
function listenPacket.request_trans_cmd(opid, head, body)
	local sql = string.format([[select count(*) as PlayerCount from player where 
	player.roleID = '%s' and player.UserID = '%s']], body.RoleId or body.OutRoleId, body.OpenId or body.OutOpenId)

	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records and records[1] and tonumber(records[1].PlayerCount) > 0 then
		send_response_data(opid, head, 0, {Result = 0, RetMsg = "success"})
		return true
	else
		send_response_data(opid, head, 1)
	end
	return false
end

--中转指令检查后直接返回
function listenPacket.request_trans_cmd_aq(opid, head, body)
	local sql = string.format([[select count(*) as PlayerCount from player where 
	player.roleID = '%s' and player.UserID = '%s']], body.RoleId or body.OutRoleId, body.OpenId or body.OutOpenId)

	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records and records[1] and tonumber(records[1].PlayerCount) > 0 then
		listenPacket.do_game_trans_data(opid, head.Cmdid, head, body)
		send_response_data(opid, head, 0, {Result = 0, RetMsg = "success"})
		return true
	else
		send_response_data(opid, head, 1)
	end
	return false
end

--处理接口
local packet_deal_list = {
	[IDIP_QUERY_ROLE_INFO_REQ]	= listenPacket.query_player_data,
	[IDIP_QUERY_BAG_REQ]		= listenPacket.query_item_data,
	[IDIP_QUERY_DEPOT_REQ]		= listenPacket.query_bank_data,
	[IDIP_QUERY_EQUIP_INFO_REQ]	= listenPacket.query_equip_data,
	[IDIP_QUERY_SKILL_REQ]		= listenPacket.query_skill_data,
	[IDIP_QUERY_STEED_REQ]		= listenPacket.query_ride_data,

	[IDIP_DO_DEL_BIND_GOLD_REQ] = listenPacket.request_delete_cash,
	[IDIP_DO_DEL_ITEM_REQ]		= listenPacket.request_delete_item,
	
	[IDIP_DO_ACTIVE_USR_REQ]	= listenPacket.request_active_user,
	[IDIP_DO_BAN_USR_REQ]		= listenPacket.request_lock_user,
	[IDIP_DO_UNBAN_USR_REQ]		= listenPacket.request_unlock_user,
	[IDIP_DO_BAN_ROLE_REQ]		= listenPacket.request_lock_player,
	[IDIP_DO_UNBAN_ROLE_REQ]	= listenPacket.request_unlock_player,
	[IDIP_QUERY_REGION_BAN_INFO_REQ]	= listenPacket.query_lock_user,
	[IDIP_QUERY_ROLE_BAN_INFO_REQ]		= listenPacket.query_lock_player,

	[IDIP_DO_MASK_CHAT_REQ]		= listenPacket.request_lock_speak,
	[IDIP_DO_UNMASK_CHAT_REQ]	= listenPacket.request_unlock_speak,	

	[IDIP_DO_MAIL_SEND_BIND_GOLD_REQ]	= listenPacket.request_send_money,
	[IDIP_DO_MAIL_SEND_MONEY_REQ]		= listenPacket.request_send_money,
	[IDIP_DO_MAIL_SEND_ITEM_REQ]		= listenPacket.request_send_item,
	[IDIP_DO_GROUP_SEND_MAIL_REQ]		= listenPacket.request_send_group,

	--二期
	[IDIP_QUERY_TOTAL_INFO_REQ]		= listenPacket.request_total_info,
	[IDIP_DO_KICK_USR_OFF_REQ]		= listenPacket.request_tick_player,
	[IDIP_DO_RECOVER_DEL_ROLE_REQ]	= listenPacket.request_recover_player,
	[IDIP_QUERY_NICK_REQ]			= listenPacket.request_query_nick,
	[IDIP_QUERY_MAIL_REQ]			= listenPacket.request_player_email,
	[IDIP_QUERY_PLAYER_DEAL_REQ]	= listenPacket.request_query_stall,
	[IDIP_QUERY_FRIEND_REQ]			= listenPacket.request_query_friend,
	[IDIP_QUERY_GUILD_INFO_REQ]		= listenPacket.request_query_faction,
	[IDIP_QUERY_GUILD_MEMBER_REQ]	= listenPacket.request_query_member,	
	[IDIP_QUERY_GUILD_DIPLOMACY_REQ]= listenPacket.request_query_social,
	[IDIP_QUERY_GUILD_APPLICATION_LIST_REQ]	= listenPacket.request_query_apply,

	[IDIP_QUERY_GUILD_CONTRIBUTE_INFO_REQ] = listenPacket.request_query_contribute,
 
	[IDIP_QUERY_LEVEL_RANK_REQ]		= listenPacket.request_level_rank,
	[IDIP_QUERY_GUILD_RANK_REQ]		= listenPacket.request_faction_rank,
	[IDIP_QUERY_EVIL_RANK_REQ]		= listenPacket.request_pk_rank,
	
	[IDIP_DO_DEL_MAIL_REQ]				= listenPacket.request_trans_cmd,
	[IDIP_DO_DOWN_DEAL_ITEM_REQ]		= listenPacket.request_trans_cmd,
	[IDIP_DO_AUCTION_TRANSFER_ITEM_REQ]	= listenPacket.request_trans_cmd,
	[IDIP_DO_HOT_UPDATE_REQ]			= listenPacket.request_trans_cmd,

	--安全
	[IDIP_AQ_QUERY_OPENID_INFO_REQ]		= listenPacket.query_player_data_aq,
	[IDIP_AQ_QUERY_ROLE_INFO_REQ]		= listenPacket.query_lock_player_aq,	
	[IDIP_AQ_DO_UPDATE_MONEY_REQ]		= listenPacket.request_update_ingot_aq,
	[IDIP_AQ_DO_UPDATE_GAMECOIN_REQ]	= listenPacket.request_update_money_aq,
	[IDIP_AQ_DO_CLEAR_SPEAK_REQ]		= listenPacket.request_trans_cmd_aq,
	[IDIP_AQ_DO_SEND_MESSAGE_REQ]		= listenPacket.request_trans_cmd_aq,
	[IDIP_AQ_DO_MASK_CHAT_REQ]			= listenPacket.request_lock_speak_aq,
	[IDIP_AQ_DO_BAN_USR_REQ]			= listenPacket.request_lock_player_aq,
	[IDIP_AQ_DO_UNBAN_USR_REQ]			= listenPacket.request_unlock_player_aq,
}

packet_event_list = {
	[IDIP_DO_GAME_POPUP_REQ]			= true,
	[IDIP_DO_HOUSE_LAMP_REQ]			= true,
	[IDIP_DO_DEL_NOTICE_REQ]			= true,
	[IDIP_DO_ADD_ACTIVITY_REQ]			= true,
	[IDIP_DO_UPDATE_ACTIVITY_REQ]		= true,
	[IDIP_DO_DEL_ACTIVITY_REQ]			= true,
	[IDIP_DO_FORCE_TRANSFER_ITEM_REQ]	= true,
}

function listenPacket.deal_data_packet(opid, head, body)
	if packet_deal_list[head.Cmdid] then
		local cmdId = head.Cmdid
		local result = packet_deal_list[head.Cmdid](opid, head, body)	
		if result and body.Source and body.Serial then
			listenPacket.do_game_trans_data(opid, cmdId, head, body)
		end
	elseif packet_event_list[head.Cmdid] then
		listenPacket.do_game_trans_data(opid, head.Cmdid, head, body)
		local rsp_body = {Result = 0, RetMsg = "success"}
		if head.Cmdid == IDIP_DO_DEL_NOTICE_REQ or head.Cmdid == IDIP_DO_FORCE_TRANSFER_ITEM_REQ then
			send_response_data(opid, head, 0, rsp_body)
		elseif head.Cmdid == IDIP_DO_GAME_POPUP_REQ or head.Cmdid == IDIP_DO_HOUSE_LAMP_REQ then
			rsp_body.EventId = body.EventId
			send_response_data(opid, head, 0, rsp_body)
		end
	else
		send_response_data(opid, head, ERROR_CMDID_NOT_VAILD)
	end
end
