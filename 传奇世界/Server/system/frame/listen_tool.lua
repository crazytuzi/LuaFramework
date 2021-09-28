--listen_tool.lua

------------------------------------------------------------------------------------
--若干全局函数
------------------------------------------------------------------------------------
--物品原型
function init_config_proto()
	g_item_protos = {}
	local protos = require "frame.ItemDB"
	for _, record in pairs(protos or table.empty) do
		g_item_protos[record.q_id] = 
		{
			name = record.q_name,
			quality = record.q_default,
		}
	end
	g_skill_protos = {}
	local protos2 = require "frame.SkillDB"
	for _, record in pairs(protos2 or table.empty) do
		g_skill_protos[record.skillID] = record.name
	end
	g_ride_protos = {}
	local protos3 = require "frame.RideDB"
	for _, record in pairs(protos3 or table.empty) do
		g_ride_protos[record.q_ID] = {
			name = record.q_name,
			level = record.q_needLevel,
		}
	end
end

------------------------------------------------------------------------------------
--若干框架函数
------------------------------------------------------------------------------------
listenTool = {}
--辅助功能接口
------------------------------------------------------------

--查询技能
function listenTool.parse_skill_data(skill_group, skill_str)
	local hex_skill_str = queryHexString(skill_str, #skill_str)
	local skill_data, errorCode = protobuf.decode("SkillProtocol", hex_skill_str)
	if skill_data then
		for i, skill in pairs(skill_data.skills) do
			local tb = {}
			tb.t = skill.id
			tb.SkillLevel = skill.level
			tb.SkillSlotId = skill.key
			tb.SkillProficiency = skill.exp
			tb.SkillName = encodeURIValue(g_skill_protos[tb.SkillId])
			table.insert(skill_group.SkillList, tb)
		end
	end
	skill_group.SkillList_count = #skill_group.SkillList
end

--查询坐骑
function listenTool.parse_ride_data(ride_group, ride_str)
	local hex_ride_str = queryHexString(ride_str, #ride_str)
	local ride_data, errorCode = protobuf.decode("RideProtocol", hex_ride_str)
	if ride_data then
		for i, rideId in pairs(ride_data.rides) do
			local tb = {}
			tb.SteedId = rideId
			tb.SteedName = encodeURIValue(g_ride_protos[rideId].name)
			tb.Level = g_ride_protos[rideId].level
			tb.Status = 0
			tb.Exp = 0
			table.insert(ride_group.SteelList, tb)
		end
	end
	ride_group.SteelList_count = #ride_group.SteelList
end

--查询交易行
function listenTool.parse_stall_data(stall_group, stall_str)
	local hex_stall_str = queryHexString(stall_str, #stall_str)
	local stall_data, errorCode = protobuf.decode("StallProtocol", hex_stall_str)
	if stall_data then
		for i, itemv in pairs(stall_data.stalls) do
			local proto = g_item_protos[itemv.protoId]
			if proto then
				local tb = {}
				tb.PriceType = 1
				tb.Uuid = itemv.guid
				tb.ItemNum = itemv.count
				tb.Price = itemv.stallprice
				tb.TransactionType = 1
				tb.ItemName = encodeURIValue(proto.name)
				table.insert(stall_group.DealList, tb)
			end	
		end
		for i, itemv in pairs(stall_data.mygots) do
			local proto = g_item_protos[itemv.protoId]
			if proto then
				local tb = {}
				tb.PriceType = 1
				tb.Uuid = itemv.guid
				tb.ItemNum = itemv.count
				tb.Price = itemv.stallprice
				tb.TransactionType = 2
				tb.ItemName = encodeURIValue(proto.name)
				table.insert(stall_group.DealList, tb)
			end	
		end
	end
	stall_group.TotalCount = #stall_group.DealList
	stall_group.DealList_count = #stall_group.DealList
end

--查询邮件
function listenTool.parse_email_data(email_group, emailid, email_str)
	local hex_email_str = queryHexString(email_str, #email_str)
	local email_data, errorCode = protobuf.decode("EmailProtocol", hex_email_str)
	if email_data then
		local tb = {}
		tb.IsRead = 1
		tb.IsTake = 0
		tb.Status = 0
		tb.MailId = emailid
		tb.MailTitle = email_data.title
		tb.MailContent = email_data.desc
		tb.ReceiveTime = email_data.startDate
		
		for i = 1, 8 do
			local item = email_data.items[i]
			local proto = item and g_item_protos[item.itemId or 0]
			tb['Item'.. i.. 'Id'] = item and item.itemId or 0
			tb['Item'.. i.. 'Num'] = item and item.count or 0
			tb['ItemName'.. i] = proto and encodeURIValue(proto.name) or ""
		end
		table.insert(email_group.MailList, tb)
	end
end

--查询行会成员
function listenTool.parse_member_data(member_group, roleId, member_str)
	local hex_member_str = queryHexString(member_str, #member_str)
	local member_data, errorCode = protobuf.decode("FacmemProtocol", hex_member_str)
	if member_data then
		local tb = {}
		tb.RoleId = roleId
		tb.Job = member_data.school
		tb.Level = member_data.level
		tb.Fight = member_data.ability
		tb.Position = member_data.position
		tb.JoinTime = member_data.joinTime		
		tb.Contribute = member_data.contribution
		tb.IsOnline = (member_data.activeState == 0)
		tb.RoleName = encodeURIValue(member_data.name)
		table.insert(member_group.MemberList, tb)
	end
end

--查询行会申请列表
function listenTool.parse_apply_data(apply_group, apply_str)
	local hex_apply_str = queryHexString(apply_str, #apply_str)
	local apply_data, errorCode = protobuf.decode("FacApplyRoleProtocol", hex_apply_str)
	if apply_data and apply_data.appInfo then
		for i, apply_info in pairs(apply_data.appInfo) do
			local tb = {}
			tb.IsOnline = 0
			tb.Job = apply_info.school
			tb.Level = apply_info.level
			tb.Fight = apply_info.battle
			tb.RoleId = apply_info.roleSID
			tb.RoleName = encodeURIValue(apply_info.name)
			table.insert(apply_group.ApplicationList, tb)
		end	
	end
end


--查询物品
function listenTool.parse_item_data(item_group, item_str, page)
	local bagSize, itemSize = 0
	local hex_item_str = queryHexString(item_str, #item_str)
	local group, errorCode = protobuf.decode("PBItemGroup", hex_item_str)
	if group then
		bagSize = group.capacity
		if page < 1 then page = 1 end
		for i, itemv in pairs(group.items) do
			if itemv.slot > (page - 1) * IDIP_BAG_ITEM_PAGE_SIZE and itemv.slot <= page  * IDIP_BAG_ITEM_PAGE_SIZE then
				local proto = g_item_protos[itemv.protoId]
				if proto then
					local tb = {}
					tb.LocationId = itemv.slot
					tb.EquipNun = itemv.count			
					tb.EquipId = itemv.guid
					tb.ImprovedLevel = itemv.strength
					tb.IsBind = itemv.bind and 1 or 0

					tb.Fight = proto.fight or 0
					tb.EquipName = encodeURIValue(proto.name)
					tb.Quality = proto.quality
					tb.Level = proto.level

					tb.Health = 0
					tb.AttackLowerLimit = 0
					tb.AttackUpperLimit = 0
					tb.MagicLowerLimit = 0
					tb.MagicUpperLimit = 0
					tb.TaoismLowerLimit = 0
					tb.TaoismUpperLimit = 0
					tb.DefenseLowerLimit = 0
					tb.DefenseUpperLimit = 0
					tb.MagicDefenseLowerLimit = 0
					tb.MagicDefenseUpperLimit = 0
					tb.Hit = 0
					tb.Dodge = 0
					tb.Critical = 0
					tb.Tenacity = 0
					tb.Lucky = 0

					tb.SanctityProperty1 = ""
					tb.SanctityProperty2 = ""
					tb.SanctityProperty3 = ""
					tb.SanctityProperty4 = ""
					
					tb.Property22 = ""
					tb.Property23 = ""
					tb.Property24 = ""
					tb.Property25 = ""
					tb.Property26 = ""
					tb.Property27 = ""
					tb.Property28 = ""
					tb.Property29 = ""
					tb.Property30 = ""
					table.insert(item_group, tb)
				end
			end			
		end
	end
	itemSize = #item_group
	return itemSize, bagSize
end

--转移物品
function listenTool.trans_item_data(roleSid, targetSid, itemID, itemCount, groupIdx, item_str)
	local hex_item_str = queryHexString(item_str, #item_str)
	local group, errorCode = protobuf.decode("PBItemGroup", hex_item_str)
	if group then
		local item_group = {}
		item_group.id = group.id
		item_group.capacity = group.capacity
		item_group.items = {}
		local bChanged = false
		for i, itemv in pairs(group.items) do
			local item = {}
			item.bind = itemv.bind
			item.slot = itemv.slot		
			item.guid = itemv.guid
			item.luck = itemv.luck
			item.count = itemv.count
			item.tlimit = itemv.tlimit
			item.protoId = itemv.protoId
			item.strength = itemv.strength
			item.stalltime = itemv.stalltime
			item.stallprice = itemv.stallprice
			item.attrs = {}
			for i, attr in pairs(itemv.attrs) do
				local new_attr = {}
				new_attr.propId = attr.propId
				new_attr.value = attr.value
				table.insert(item.attrs, new_attr)
			end
			if item.guid ~= itemID then
				table.insert(item_group.items, item)
			else
				bChanged = true
				local newguid = NEW_GUID_STR(g_serverId, 9)
				--发送邮件
				local email_pb = {
					sender = 0, startDate = os.time(), endDate = os.time() + 86400 * 30,
					title = "", desc = "", descId = 72, emailId = NEW_GUID_STR(g_serverId, 9), insItems = {}
				}
				if item.count > itemCount then
					item.count = item.count - itemCount
					table.insert(item_group.items, item)
					item.count = itemCount
				end
				table.insert(email_pb.insItems, item)
				local email_str, error = protobuf.encode("EmailProtocol", email_pb)
				if email_str then
					local sql = string.format([[replace into email (roleID, emailIndex, datas) values ('%s', '%s', '%s')]], 
						targetSid, email_pb.emailId, email_str)
					mysql_callSQL(mysql_game, sql)
				end
			end
		end
		if bChanged then
			local new_group, errorCode = protobuf.encode("PBItemGroup", item_group)
			if new_group then
				local hex_group_str = buildHexString(new_group, #new_group)
				local sql = string.format([[replace into item (roleID, groupIndex, datas) values ('%s', %d, '%s')]], roleSid, groupIdx, hex_group_str)
				mysql_callSQL(mysql_game, sql)
			end
			return true
		end
	end
	return false
end

--删除物品
function listenTool.delete_item_data(roleSid, itemID, remainCnt, needDelCnt, groupIdx, item_str)
	local hex_item_str = queryHexString(item_str, #item_str)
	local group, errorCode = protobuf.decode("PBItemGroup", hex_item_str)
	if group then
		local item_group = {}
		item_group.id = group.id
		item_group.capacity = group.capacity
		item_group.items = {}
		local bChanged = false
		for i, itemv in pairs(group.items) do
			local item = {}
			item.bind = itemv.bind
			item.slot = itemv.slot
			item.guid = itemv.guid
			item.luck = itemv.luck
			item.count = itemv.count
			item.tlimit = itemv.tlimit
			item.protoId = itemv.protoId
			item.strength = itemv.strength
			item.stalltime = itemv.stalltime
			item.stallprice = itemv.stallprice
			item.attrs = {}
			for i, attr in pairs(itemv.attrs) do
				local new_attr = {}
				new_attr.propId = attr.propId
				new_attr.value = attr.value
				table.insert(item.attrs, new_attr)
			end
			if item.protoId ~= itemID then
				table.insert(item_group.items, item)
			else
				if item.count > needDelCnt then
					remainCnt = remainCnt + item.count
					if needDelCnt > 0 then
						bChanged = true
						remainCnt = remainCnt - needDelCnt	
						item.count = item.count - needDelCnt
						needDelCnt = 0
					end
					table.insert(item_group.items, item)
				else
					bChanged = true
					needDelCnt = needDelCnt - item.count
				end
			end
		end
		if bChanged then
			local new_group, errorCode = protobuf.encode("PBItemGroup", item_group)
			if new_group then
				local hex_group_str = buildHexString(new_group, #new_group)
				local sql = string.format([[replace into item (roleID, groupIndex, datas) values ('%s', %d, '%s')]], roleSid, groupIdx, hex_group_str)
				mysql_callSQL(mysql_game, sql)
			end
		end		
	end
	return remainCnt, needDelCnt
end

--删除邦元
function listenTool.delete_player_cash(roleId, cash)
	local remainCash = 0
	local sql = string.format([[select Cash from player WHERE RoleID = '%s']], roleId)
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records and records[1] then
		remainCash = records[1].Cash - cash
		if remainCash < 0 then remainCash = 0 end
		sql = string.format([[update player set Cash = %d WHERE RoleID = '%s']], remainCash, roleId)
		mysql_callSQL(mysql_game, sql)
		return true, remainCash
	end
	return false
end

--更新邦元
function listenTool.update_player_cash(roleId, cash)
	local sql = string.format([[select Cash from player WHERE RoleID = '%s']], roleId)
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records and records[1] then
		local remainCash = records[1].Cash + cash
		if remainCash < 0 then remainCash = 0 end
		sql = string.format([[update player set Cash = %d WHERE RoleID = '%s']], remainCash, roleId)
		mysql_callSQL(mysql_game, sql)
		return true
	end
	return false
end

--更新元宝
function listenTool.update_player_ingot(roleId, ingot)
	local sql = string.format([[select Ingot from player WHERE RoleID = '%s']], roleId)
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records and records[1] then
		sql = string.format([[update player set Ingot = %d WHERE RoleID = '%s']], ingot, roleId)
		mysql_callSQL(mysql_game, sql)
		return true
	end
	return false
end

--更新金币
function listenTool.update_player_money(roleId, money)
	local sql = string.format([[select Money from player WHERE RoleID = '%s']], roleId)
	local result, records = mysql_callSQL(mysql_game, sql)
	if result and records and records[1] then
		local remainCash = records[1].Money + money
		if remainCash < 0 then remainCash = 0 end
		sql = string.format([[update player set Money = %d WHERE RoleID = '%s']], remainCash, roleId)
		mysql_callSQL(mysql_game, sql)
		return true
	end
	return false
end

--修改技能
function listenTool.modify_skill_data(roleSid, context, skill_str)	
	local id = context.id or 0
	local xp = context.xp or 0
	local level = context.level or 0
	local hex_skill_str = queryHexString(skill_str, #skill_str)
	local skill_data, errorCode = protobuf.decode("SkillProtocol", hex_skill_str)
	if skill_data and id > 0 then
		local hasSkill = false
		local skill_group = {skills = {}}
		for i, skillv in pairs(skill_data.skills) do
			local skill = {}
			skill.id = skillv.id
			skill.key = skillv.key
			skill.exp = (xp > 0 and skillv.id == id) and xp or skillv.exp
			skill.level = (level > 0 and skillv.id == id) and level or skillv.level
			table.insert(skill_group.skills, skill)
			if skillv.id == id then
				hasSkill = true
			end
		end
		if not hasSkill then
			local skill = {id = id, key = 0, level = level, exp = xp}
			if skill.level > 0 then
				table.insert(skill_group.skills, skill)
			end
		end
		local new_skill, errorCode = protobuf.encode("SkillProtocol", skill_group)
		if new_skill then
			local hex_skill_str2 = buildHexString(new_skill, #new_skill)
			local sql = string.format([[replace into skill (roleID, datas) values ('%s', '%s')]], roleSid, hex_skill_str2)
			local result, records = mysql_callSQL(mysql_game, sql)
			return result
		end
	end
	return false
end