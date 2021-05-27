require("scripts/game/chat/cross_server_chat_limit")

ChatData = ChatData or BaseClass()

MAX_CHANNEL_MSG_NUM	= 100							-- 频道消息最大数量
MAX_PRESERVE_MSG_NUM = 100							-- 私聊消息最大数量
MAX_TRANSMIT_MSG_NUM = 10							-- 喇叭消息最大数量

CHAT_EDIT_MAX = 60									-- 聊天输入最大字符限制

CHAT_POS_MAX = 1									-- 发送坐标最大数量
CHAT_ITEM_MAX = 3									-- 发送道具最大数量
CHAT_FACE_MAX = 5									-- 发送表情最大数量	

--聊天频道的ID定义
CHANNEL_TYPE =  {
	PRIVATE = 0,									-- 私聊,密语 
	NEAR = 1,  										-- 附近频道，同屏
	SPEAKER = 2, 									-- 喇叭传音频道
	GUILD = 3, 										-- 工会，帮派
	TEAM = 4, 										-- 队伍频道,5人
	BIGTEAM = 5, 									-- 团队,20人
	SCENE = 6,  									-- 地图，本地图可见
	TIPMSG = 7, 									-- 系统提示
	CAMP =  8, 										-- 阵营频道
	SYSTEM = 9,										-- 系统频道
	WORLD = 10,										-- 世界频道
	HELP = 11,										-- 呼救频道
	SELL = 12,										-- 出售频道
	FRIEND = 13,									-- 好友聊天
	CROSS = 9999,									-- 跨服
	ALL = 255,										-- 全部
}
CHANNEL_LV = {
	[CHANNEL_TYPE.PRIVATE] = 310,
	[CHANNEL_TYPE.NEAR] = 310,
	[CHANNEL_TYPE.SPEAKER] = 310,
	[CHANNEL_TYPE.GUILD] = 310,
	[CHANNEL_TYPE.TEAM] = 310,
	[CHANNEL_TYPE.BIGTEAM] = 310,
	[CHANNEL_TYPE.SCENE] = 310,
	[CHANNEL_TYPE.TIPMSG] = 310,
	[CHANNEL_TYPE.CAMP] = 310,
	[CHANNEL_TYPE.SYSTEM] = 310,
	[CHANNEL_TYPE.WORLD] = 310,
	[CHANNEL_TYPE.HELP] = 310,
	[CHANNEL_TYPE.SELL] = 310,
	[CHANNEL_TYPE.FRIEND] = 310,
	[CHANNEL_TYPE.CROSS] = 310,
}
CHANNEL_COLOR = {
	[CHANNEL_TYPE.PRIVATE] = cc.c3b(0xdf, 0x7d, 0xe0),
	[CHANNEL_TYPE.NEAR] = cc.c3b(0xff, 0xff, 0xff),
	[CHANNEL_TYPE.SPEAKER] = COLOR3B.YELLOW,
	[CHANNEL_TYPE.GUILD] = cc.c3b(0x53, 0xcc, 0x58),
	[CHANNEL_TYPE.TEAM] = cc.c3b(0x01, 0x65, 0xdd),
	[CHANNEL_TYPE.BIGTEAM] = COLOR3B.YELLOW,
	[CHANNEL_TYPE.SCENE] = COLOR3B.YELLOW,
	[CHANNEL_TYPE.TIPMSG] = cc.c3b(0xec, 0xe0, 0x57),
	[CHANNEL_TYPE.CAMP] = COLOR3B.YELLOW,
	[CHANNEL_TYPE.SYSTEM] = cc.c3b(0xec, 0xe0, 0x57),
	[CHANNEL_TYPE.WORLD] = cc.c3b(0xd6, 0xa2, 0x03),
	[CHANNEL_TYPE.HELP] = COLOR3B.YELLOW,
	[CHANNEL_TYPE.SELL] = COLOR3B.YELLOW,
	[CHANNEL_TYPE.FRIEND] = COLOR3B.YELLOW,
	[CHANNEL_TYPE.CROSS] = COLOR3B.YELLOW,
}

--系统提示的类型
tagTipmsgType = 
{
	ttInvalidTmType = -1,							-- 无效的Tipmsg类型
	ttTipmsgWindow = 1,								-- 1区域：杀怪获得人物经验+内功经验提示、拾取和失去提示、输入指令提示
	ttFlyTip = 2,									-- 2区域：各种点击操作提示显示
	ttChatWindow = 4,								-- 3区域：聊天框全服显示
	ttScreenCenter = 8,								-- 4区域：顶上特殊全服显示. 屏幕中央，用于xxx把xxx强化到6级之类的全服公告
	ttMessage = 16,									-- 5区域：喇叭内容显示
	ttAboveChatWindow = 32,							-- 6区域：聊天框上方的显示
}	

function ChatData:__init()
	if ChatData.Instance then
		ErrorLog("[ChatData]:Attempt to create singleton twice!")
	end
	ChatData.Instance = self

	self.face_tab = {}								-- 表情列表，每次添加表情的时候插入这个列表，发送之前进行校验
	self.item_tab = {}								-- 物品列表，每次添加物品的时候插入这个列表，发送之前进行校验
	self.point_tab = {}								-- 坐标列表，每次添加坐标的时候插入这个列表，发送之前进行校验

	self.transmit_msg_list = {}						-- 喇叭消息列表

	self.msg_id_inc = 0
	self.channel_list = {}							-- 频道列表

	self.private_id_inc = 0							-- 私聊增长id
	self.private_obj_map = {}						-- 私聊对象map
	self.private_obj_list = {}						-- 私聊对象list
	self.private_unread_list = {}					-- 私聊未读列表

	self.team_unread_list = {}						-- 组队未读列表
	self.blacklist = {}

	self.chat_role_list = {}
	self.surplus_horn = 0

    self.private_select_name = ""
    self:SetChatLimitData()
	self:Init()
end

function ChatData:__delete()

end

function ChatData.UploadChannelType(channel_type)
	if channel_type == CHANNEL_TYPE.PRIVATE then
		return 5
	elseif channel_type == CHANNEL_TYPE.NEAR then
		return 6
	elseif channel_type == CHANNEL_TYPE.SPEAKER then
		return 7
	elseif channel_type == CHANNEL_TYPE.GUILD then
		return 3
	elseif channel_type == CHANNEL_TYPE.TEAM or channel_type == CHANNEL_TYPE.BIGTEAM then
		return 4
	elseif channel_type == CHANNEL_TYPE.CAMP then
		return 2
	end
	return 1
end

function ChatData:Init()
	for k, v in pairs(CHANNEL_TYPE) do
		self.channel_list[v] = ChatData.CreateChannel()
	end
end

function ChatData:GetMsgId()
	self.msg_id_inc = self.msg_id_inc + 1
	return self.msg_id_inc
end

----------------------------------------------------
-- 频道begin
----------------------------------------------------
-- 创建频道
function ChatData.CreateChannel()
	return {
		is_pingbi = false,							-- 是否屏蔽
		cd_end_time = 0,							-- CD结束时间
		unread_num = 0,								-- 未读数量
		msg_list = {},								-- 消息列表
	}
end

-- 创建消息
function ChatData.CreateMsgInfo()
	return {
		msg_id = 0,									-- 消息id

		role_id = 0,
		channel_type = 0,
		tips_type = 0,
		name = "",
		content = "",
		sex = 0,
		flag = 0,
		zhuansheng = 0,
		fengshen_lv = 0,
		sbk_occupation = 0,
		identifying_code = 0,
		camp_id = 0,
		camp_occupation = 0,
		vip = 0,
	}
end

-- 获取频道
function ChatData:GetChannel(channel_type)
	return self.channel_list[channel_type]
end

-- 获取CD结束时间
function ChatData:GetChannelCdEndTime(channel_type)
	if nil ~= self.channel_list[channel_type] then
		return self.channel_list[channel_type].cd_end_time
	end
	return 0
end

-- 设置CD结束时间
function ChatData:SetChannelCdEndTime(channel_type)
	if nil ~= self.channel_list[channel_type] then
		self.channel_list[channel_type].cd_end_time = Status.NowTime + 10
		return self.channel_list[channel_type].cd_end_time
	end
end

-- 获取CD是否结束时间
function ChatData:GetChannelCdIsEnd(channel_type)
	if nil ~= self.channel_list[channel_type] then
		return (self.channel_list[channel_type].cd_end_time - Status.NowTime) <= 0
	end
	return false
end

-- 添加频道消息
function ChatData:AddChannelMsg(msg_info)
	-- if msg_info.channel_type == CHANNEL_TYPE.SYSTEM
	-- and SETTING_TYPE.SHIELD_SYSTEM_NOTICE
	-- and SettingData.Instance:GetOneSysSetting(SETTING_TYPE.SHIELD_SYSTEM_NOTICE)
	-- then 
	-- 	return
	-- end
	msg_info.msg_id = self:GetMsgId()

	local channel = self:GetChannel(msg_info.channel_type)
	if nil ~= channel then
		self:InsertMsgToChannel(channel, msg_info, msg_info.channel_type)
	end

	-- 系统、仙盟消息不插入“所有”频道
	if msg_info.channel_type ~= CHANNEL_TYPE.SPEAKER then
		self:InsertMsgToChannel(self.channel_list[CHANNEL_TYPE.ALL], msg_info)
	end
	if msg_info.name and msg_info.name ~= "" and (msg_info.name ~= RoleData.Instance:GetAttr("name") or msg_info.to_name ~= nil) then
		local name = msg_info.to_name ~= nil and msg_info.to_name or msg_info.name
		self:AddNearChatRole(name, msg_info.role_id, msg_info.channel_type)
		self:AddNearChatRole(name, msg_info.role_id, CHANNEL_TYPE.ALL)
	end
end
-- 删除频道消息
function ChatData:RemoveChannelMsg(channel_type)
    if CHANNEL_TYPE.ALL == channel_type then
         for k,v  in pairs(self.channel_list) do
            v.msg_list = {}
            v.unread_num = 0
         end
    else
        local channel = self:GetChannel(channel_type)
	    if nil ~= channel then
           channel.msg_list = {}
           channel.unread_num = 0
        end
    end
end

function ChatData:AddNearChatRole(name, role_id, channel, add_private)
	self.chat_role_list[channel] = self.chat_role_list[channel] or  {}
	for k,v in pairs(self.chat_role_list[channel]) do
		if v.role_id ~= 0 and v.role_id == role_id then
			if add_private then
				return v.name
			else
				v.name = name
				return
			end
		end
		if v.name == name then
			return 
		end
	end
	table.insert(self.chat_role_list[channel], 1, {name = name, role_id = role_id})
	if #self.chat_role_list[channel] > 15 then
		table.remove(self.chat_role_list[channel], #self.chat_role_list[channel])
	end
end

function ChatData:GetChatRoleList(channel)
	return self.chat_role_list[channel] or {}
end

-- 插入消息到频道
function ChatData:InsertMsgToChannel(channel, msg_info)
	table.insert(channel.msg_list, msg_info)
	channel.unread_num = math.min(channel.unread_num + 1, MAX_CHANNEL_MSG_NUM)

	if #channel.msg_list > MAX_CHANNEL_MSG_NUM then
		table.remove(channel.msg_list, 1)
	end
end

-- 是否屏蔽
function ChatData:IsPingBiChannel(channel_type)
	if nil ~= self.channel_list[channel_type] then
		return self.channel_list[channel_type].is_pingbi
	end

	return false
end
----------------------------------------------------
-- 频道end
----------------------------------------------------

----------------------------------------------------
-- 私聊begin
----------------------------------------------------
-- 创建私聊对象
function ChatData.CreatePrivateObj()
	return {
		role_id = 0,								-- 角色id
		username = "",								-- 角色名字
		sex = 0,									-- 性别
		camp = 0,									-- 阵营
		prof = 0,									-- 职业
		authority_type = 0,							-- 权限类型，GM、新手指导员之类
		level = 0,									-- 等级
		vip_level = 0,								-- vip等级
		unread_num = 0,								-- 未读消息数量
		msg_list = {},								-- 消息列表
	}
end

-- 添加私聊对象
function ChatData:AddPrivateObj(role_id, private_obj)
	if nil == self.private_obj_map[role_id] then
		self.private_obj_map[role_id] = private_obj
		table.insert(self.private_obj_list, private_obj)
	end
end

-- 移除私聊对象
function ChatData:RemovePrivateObj(private_obj)
	if nil ~= self.private_obj_map[private_obj.role_id] then
		self.private_obj_map[private_obj.role_id] = nil

		local index = self:GetPrivateIndex(private_obj.role_id)
		if index > 0 then
			table.remove(self.private_obj_list, index)
		end
	end
end

-- 根据索引移除私聊对象
function ChatData:RemovePrivateObjByIndex(index)
	local private_obj = self.private_obj_list[index]
	if nil ~= private_obj then
		table.remove(self.private_obj_list, index)
		self.private_obj_map[private_obj.role_id] = nil
	end
end

-- 获取私聊列表
function ChatData:GetPrivateObjList()
	return self.private_obj_list
end

-- 获取私聊对象数量
function ChatData:GetPrivateObjCount()
	return #self.private_obj_list
end

-- 根据索引获取私聊对象
function ChatData:GetPrivateObjByIndex(index)
	return self.private_obj_list[index]
end

-- 根据角色id获取私聊对象
function ChatData:GetPrivateObjByRoleId(role_id)
	return self.private_obj_map[role_id]
end

-- 获取私聊对象索引
function ChatData:GetPrivateIndex(role_id)
	for k, v in pairs(self.private_obj_list) do
		if role_id == v.role_id then
			return k
		end
	end

	return 0
end

-- 添加私聊消息
function ChatData:AddPrivateMsg(role_id, msg_info)
	local private_obj = self.private_obj_map[role_id]
	if nil == private_obj then
		private_obj = ChatData.CreatePrivateObj()
		private_obj.role_id = msg_info.from_uid
		private_obj.username = msg_info.username
		private_obj.sex = msg_info.sex
		private_obj.camp = msg_info.camp
		private_obj.prof = msg_info.prof
		private_obj.authority_type = msg_info.authority_type
		private_obj.level = msg_info.level
		private_obj.vip_level = msg_info.vip_level
		self:AddPrivateObj(role_id, private_obj)
	end

	msg_info.msg_id = self:GetMsgId()

	table.insert(private_obj.msg_list, msg_info)
	private_obj.unread_num = private_obj.unread_num + 1

	if #private_obj.msg_list > MAX_PRESERVE_MSG_NUM then
		table.remove(private_obj.msg_list, 1)
	end
end

-- 私聊未读列表
function ChatData:GetPrivateUnreadList()
	return self.private_unread_list
end

-- 添加私聊未读消息
function ChatData:AddPrivateUnreadMsg(msg_info)
	table.insert(self.private_unread_list, msg_info)
end

-- 移除私聊未读消息
function ChatData:RemPrivateUnreadMsg(uid)
	for k,v in pairs(self.private_unread_list) do
		if v.from_uid == uid then
			table.remove(self.private_unread_list, k)
		end
	end
end
----------------------------------------------------
-- 私聊end
----------------------------------------------------

-- 组队未读信息列表
function ChatData:GetTeamUnreaList()
	return self.team_unread_list
end

-- 添加组队未读消息
function ChatData:AddTeamUnreadMsg(msg_info)
	table.insert(self.team_unread_list, msg_info)
end

-- 移除组队未读消息
function ChatData:RemTeamUnreadMsg()
	self.team_unread_list = {}
end

-- 添加喇叭消息
function ChatData:AddTransmitInfo(transmit_info)
	table.insert(self.transmit_msg_list, TableCopy(transmit_info))
	if #self.transmit_msg_list > MAX_TRANSMIT_MSG_NUM then
		table.remove(self.transmit_msg_list, 1)
	end
end

-- 弹出第一个喇叭消息
function ChatData:PopTransmit()
	return table.remove(self.transmit_msg_list, 1)
end

--向表情列表中插入表情
function ChatData:InsertFaceTab(face_id)
	table.insert(self.face_tab, "{face;".. face_id .."}")
end

function ChatData:InsertItemTab(item_data, is_bag)
	local item_txt = RichTextUtil.CreateItemStr(item_data)
	if item_txt then
		table.insert(self.item_tab, item_txt)
	end
end

function ChatData:InsertPointTab(map_name, point_x, point_y, scene_id)
	table.insert(self.point_tab, "{point;".. map_name .. ";" .. point_x .. ";" .. point_y .. ";" .. scene_id .. "}")
end

function ChatData:CheckFaceAndItem(msg)
	local str = msg
	--格式化列表中的表情
	for i,v in ipairs(self.face_tab) do
		local params = self:GetSplitData(v)

		local i, j = 0, 0
		while true do
			i, j = string.find(str, "(%/[0-9][0-9])", j+1)
			if nil == i or nil == j then 
				break 
			elseif params[2] == string.sub(str, i+1, j) then
				local src = string.sub(str, i, j)

				str = string.gsub(str, src, v)
			end
		end
	end

	--格式化输入的表情
	local i, j = 0, 0
	while true do
		i, j = string.find(str, "(%/[0-9][0-9])", j + 1)
		if nil == i or nil == j then 
			break 
		else
			local num =  string.sub(str, i + 1, j) + 0
			if num >= 1 and num <= 32 then
				local src = string.sub(str, i, j)

				str = string.gsub(str, src, "{face;" .. string.format("%02d", num) .. "}")
			end
		end
	end 

	--格式化坐标列表中的数据
	for i,v in ipairs(self.point_tab) do
		local params = self:GetSplitData(v)
		local match = params[2] .. "%(" .. params[3] .. "," .. params[4] .. "%)"

		local i, j = 0, 0
		while true do
			i, j = string.find(str, match, j + 1)
			if nil == i or nil == j then 
				break 
			else
				local a, b = string.find(str, params[2], i)
				local src = string.sub(str, b + 1 , j - 1)

				str = string.gsub(str, params[2] .. "%(" .. src .. "%)", v)
			end
		end
	end

	--格式化物品列表中的物品
	for i,v in ipairs(self.item_tab) do
		local params = self:GetSplitData(v)

		local i, j = 0, 0
		while true do
			i, j = string.find(str, "(%[.-%])", j + 1)
			if nil == i or nil == j then 
				break 
			elseif params[3] == string.sub(str, i + 1, j - 1) then
				local src = string.sub(str, i + 1, j - 1)
				src = string.gsub(src, "%)", "%%%)")
				src = string.gsub(src, "%(", "%%%(")
				str = string.gsub(str, "%[" .. src .. "%]", v)
			end
		end
	end
	return str
end

-- 格式化，过滤文本
function ChatData:FormattingMsg(msg, content_type)
	if content_type == CHAT_CONTENT_TYPE.AUDIO then
		return msg
	end
	msg = string.gsub(msg, "{", "(")
	msg = string.gsub(msg, "}", ")")
	msg = string.match(msg,"%s*(.-)%s*$") 
	local str = self:CheckFaceAndItem(msg)
	return str
end

function ChatData:GetSplitData(value)
	local mark
	mark = string.gsub(value, "{", "")
	mark = string.gsub(mark, "}", "")

	return Split(mark, ";")
end

function ChatData:ClearInput()
	self.face_tab = {}
	self.item_tab = {}
	self.point_tab = {}
end

-- 校验列表与输入框
function ChatData.ExamineListByEditText(msg, n)
	local lists = 
	{
		ChatData.Instance.point_tab, 
		ChatData.Instance.item_tab, 
		ChatData.Instance.face_tab
	}
	local list = lists[n]
	local str = msg
	local find_str = ""
	local i, j = 1, 1
	local appear_num = 0
	for k,v in pairs(list) do
		local find_arr = Split(v, ";")
		if #find_arr > 0 then 
			if n == 1 then
				find_str = find_arr[2] .. "%(" .. find_arr[3] .. "," .. find_arr[4] .. "%)"
			elseif n == 2 then
				find_str = "%[" .. find_arr[3] .. "%]"
			elseif n == 3 then
				find_str = "%/" .. find_arr[2] 
			end
			find_str = string.gsub(find_str, "}", "")
			find_str = string.gsub(find_str, "{", "")
			if 2 == n then
				find_str = string.gsub(find_str, "%)", "%%%)")
				find_str = string.gsub(find_str, "%(", "%%%(")
			end

			i, j = string.find(str, find_str, j)
			if j == nil then 
				table.remove(list, k)
			else
			local n = 0
			msg, n = string.gsub(msg, find_str, "")
			appear_num = appear_num + n
			end
		end
	end
	return appear_num
end

-- 检查文本内容
function ChatData.ExamineEditText(msg, n)
	local num = n > 0 and 1 or 0
	local boolean = true
	local max_arr = {CHAT_POS_MAX, CHAT_ITEM_MAX, CHAT_FACE_MAX}
	for i = 1, 3 do
		local appear_num = num + ChatData.ExamineListByEditText(msg, i)
		if appear_num > max_arr[i] then
			if n == 0 or n == i then
				SysMsgCtrl.Instance:ErrorRemind(Language.Chat["TipMax" .. i])
				boolean = false
			end
		end
	end
	return boolean
end

-- 聊天输入最大字符限制，超出直接截断
function ChatData.ExamineEditTextNum(edit, num, e_type)
	if e_type == "return" then
		local str = edit:getText()
		local text_num = AdapterToLua:utf8FontCount(str)
		if text_num > num then
			str = AdapterToLua:utf8TruncateByFontCount(str, num)
			edit:setText(str)
			SysMsgCtrl.Instance:ErrorRemind(Language.Chat.ContentToLong)
		end
	end
end

-- 名字输入最大字符限制，去除空格，超出直接截断
function ChatData.ExamineEditNameNum(edit, num, e_type)
	if e_type == "return" then
		local text = edit:getText()
		text = string.gsub(text, "%s", "")			-- 空白符
		text = string.gsub(text, "　", "")			-- 全角空格
		edit:setText(text)
		ChatData.ExamineEditTextNum(edit, num, e_type)
	end
end

-- 检查频道规则
function ChatData.ExamineChannelRule(channel)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	--判断等级是否足够
	if main_role_vo[OBJ_ATTR.CREATURE_LEVEL] < COMMON_CONSTS.CHAT_LEVEL_LIMIT then
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.LevelDeficient, COMMON_CONSTS.CHAT_LEVEL_LIMIT))
		return false
	end

	--组队聊天是判断是否有队伍
	if channel == CHANNEL_TYPE.TEAM and not TeamData.Instance:HasTeam() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NoTeam)
		return false
	end
	return true
end


function ChatData.FormattingMsgType(msg_type)
	local type_t = {}
	for i = 1, 32 do
		if msg_type >= bit.data32[i] then
			table.insert(type_t, bit.data32[i])
			msg_type = msg_type - bit.data32[i]
		end
	end

	return type_t
end

function ChatData:SetSurplusHorn(count)
	self.surplus_horn = count
end

function ChatData:GetSurplusHorn()
	return self.surplus_horn
end

function ChatData.GetChannelIndex(channel_type)
	if channel_type == CHANNEL_TYPE.PRIVATE then
		return ChatViewIndex.Private
	elseif channel_type == CHANNEL_TYPE.NEAR then
		return ChatViewIndex.Near
	elseif channel_type == CHANNEL_TYPE.WORLD then
		return ChatViewIndex.World
	elseif channel_type == CHANNEL_TYPE.GUILD then
		return ChatViewIndex.Guild
	elseif channel_type == CHANNEL_TYPE.TEAM then
		return ChatViewIndex.Team
	end
	return ChatViewIndex.All
end

-- 是否允许聊天
function ChatData:IsCanChat()
	if IS_ON_CROSSSERVER then
		if ChatData.CROSS_SERVER_CHAT_LIMIT_SPID then
			local plat_id = AgentAdapter.GetSpid and AgentAdapter:GetSpid() or ""
			for _, spid in pairs(ChatData.CROSS_SERVER_CHAT_LIMIT_SPID) do
				if spid == plat_id then
					return false, Language.Common.OnCrossServerTip
				end
			end
		end
	end

	return true
end

function ChatData:SetChatLimitData()
	self.chat_limit_data = {}
	local verify_callback = function(url, arg, data, size)
		local ret_t = cjson.decode(data)
		if ret_t and ret_t.ret == 0 and ret_t.data and type(ret_t.data) == "table" then
			self.chat_limit_data = ret_t.data
		end
	end
	local real_url = string.format("http://l.cqtest.jianguogame.com:88/api/chat_limit.php?plat_id=%s", AgentAdapter:GetSpid())
	HttpClient:Request(real_url, "", verify_callback)
end

function ChatData:GetChatLimitData(key)
    return self.chat_limit_data[key]
end