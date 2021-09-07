ChatData = ChatData or BaseClass()

MAX_CHANNEL_MSG_NUM	= 50							-- 频道消息最大数量
MAX_PRESERVE_MSG_NUM = 50							-- 私聊消息最大数量
MAX_TRANSMIT_MSG_NUM = 10							-- 喇叭消息最大数量

CHAT_EDIT_MAX = 90									-- 聊天输入最大字符限制

CHAT_POS_MAX = 1									-- 发送坐标最大数量
CHAT_ITEM_MAX = 3									-- 发送道具最大数量
CHAT_FACE_MAX = 5									-- 发送表情最大数量

local CacheMsgMaxCount = 20				--聊天缓存队列最大长度

NO_FILTER_LIST =
{
	QUESTION_ANSWER = "{question_answer}",
}

QUICK_CHAT_TYPE = {
	NORMAL = 1,
	GUILD = 2,
}

--特殊聊天id
SPECIAL_CHAT_ID = {
	GUILD = 1,
	TEAM = 2,
	CAMP = 3,
	ALL = 100,					--100之后的都默认为私聊id
}

local ChatProfItems = {
	"prof_one_item",
	"prof_two_item",
	"prof_three_item",
	"prof_four_item",
}

function ChatData:__init()
	if ChatData.Instance then
		print_error("[ChatData]:Attempt to create singleton twice!")
	end
	ChatData.Instance = self

	self.face_tab = {}								-- 表情列表，每次添加表情的时候插入这个列表，发送之前进行校验
	self.item_tab_from_chat = {}					-- 物品列表，每次添加物品的时候插入这个列表，发送之前进行校验(从聊天面板打开)
	self.item_tab_from_guild = {}					-- 物品列表，每次添加物品的时候插入这个列表，发送之前进行校验(从群聊面板打开)
	self.point_tab = {}								-- 坐标列表，每次添加坐标的时候插入这个列表，发送之前进行校验

	self.transmit_msg_list = {}						-- 喇叭消息列表

	self.msg_id_inc = 0
	self.channel_list = {}							-- 频道列表

	self.private_id_inc = 0							-- 私聊增长id
	self.private_obj_map = {}						-- 私聊对象map
	self.private_obj_list = {}						-- 私聊对象list
	self.private_unread_list = {}					-- 私聊未读列表

	self.team_unread_list = {}						-- 组队未读列表
	self.team_unread_count = 0						-- 组队未读消息数目
	self.blacklist = {}

	self.headsay_state = false						-- 是否屏蔽传闻

	self.chat_channel_size_list = {}				--记录不同频道item的高度

	self.is_lock = false							--是否锁定界面
	self.is_pop_guild_chat = false					--是否弹出公会气泡框
	self.is_pop_main_chat = false					--是否弹出主界面气泡框
	self.guild_chat_type = nil

	self.temp_world_list = {}						--世界缓存列表
	self.temp_system_list = {}						--系统缓存列表

	self.world_voice_state = true					--自动播放世界语音
	self.team_voice_state = true					--自动播放队伍语音
	self.guild_voice_state = true					--自动播放公会语音
	self.privite_voice_state = true					--自动播放私聊语音
	self.show_red_value = false 					--家族群聊私聊红点(有私信时)
	self.guild_chat_dati = false 					--家族群聊私聊红点(有家族答题时)
	self.normal_chat_list_map = {}					--总聊天列表（以聊天id为key的表）
	self.normal_chat_list = {}						--总聊天列表（数组表）
	self.chat_info_list = {}
	self.ignore_level_limit = 99999999
	self.chat_open_level = {}
	self:Init()
end

function ChatData:__delete()
	ChatData.Instance = nil
end

function ChatData:Init()
	for k, v in pairs(CHANNEL_TYPE) do
		if v ~= CHANNEL_TYPE.PRIVATE then
			self.channel_list[v] = ChatData.CreateChannel()
		end
		self.chat_channel_size_list[v] = {}
	end
end

-- 公会气泡框数据
function ChatData:GetIsPopChat()
	return self.is_pop_guild_chat
end

-- 主界面气泡框数据
function ChatData:GetIsPopMainChat()
	return self.is_pop_main_chat
end

function ChatData:SetIsPopMainChat(flag)
	self.is_pop_main_chat = flag
end


function ChatData:SetGuildChatType(chat_type)
	self.guild_chat_type = chat_type
end

function ChatData:GetGuildChatType()
	return self.guild_chat_type
end

--设置聊天等级限制
function ChatData:SetChatOpenLevelLimit(protocol)
	self.ignore_level_limit = protocol.ignore_level_limit
	self.chat_open_level = protocol.open_level
end

--获取聊天等级限制
function ChatData:GetIgnoreChatOpenLevelLimit()
	return self.ignore_level_limit
end

--获取聊天等级限制
function ChatData:GetChatOpenLevel(chat_type)
	local history_recharge = DailyChargeData.Instance:GetHistoryRecharge()
	if history_recharge >= self.ignore_level_limit then
		return 0
	else
		return self.chat_open_level[chat_type] or COMMON_CONSTS.CHAT_LEVEL_LIMIT
	end
end

function ChatData:SetIsPopChat(is_pop)
	self.is_pop_guild_chat = is_pop
end

function ChatData:SetRedChat(value)
	self.show_red_value = value
	MainUICtrl.Instance:ShowGuildChatRes()
end

function ChatData:GetRedChat()
	return self.show_red_value
end

function ChatData:SetGuildChatDaTi(is_show)
	self.guild_chat_dati = is_show
	MainUICtrl.Instance:ShowGuildChatDaTi()
end

function ChatData:GetGuildChatDaTi()
	return self.guild_chat_dati
end

-----------------------------------------

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
		from_uid = 0,								-- 发送者id
		username = "",								-- 发送者名字
		sex = 0,									-- 性别
		camp = 0,									-- 阵营
		prof = 0,									-- 职业
		authority_type = 0,							-- 权限类型，GM、新手指导员之类
		content_type = 0,							-- 内容类型
		tuhaojin_color = 0,							-- 发消息字体颜色(土豪金)
		bigchatface_status = 0,						-- 大表情
		level = 0,									-- 等级
		vip_level = 0,								-- vip等级
		channel_type = 0,							-- 频道类型
		send_time_str = "",							-- 发送时间
		content = "",								-- 消息内容
		from_type = 0,							-- 是否是系统发的
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
	cd_s = CHANNEL_CD[channel_type] or 0
	if nil ~= self.channel_list[channel_type] then
		self.channel_list[channel_type].cd_end_time = Status.NowTime + cd_s
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
	msg_info.msg_id = self:GetMsgId()

	local channel_type = msg_info.channel_type
	if channel_type == CHANNEL_TYPE.SPEAKER or channel_type == CHANNEL_TYPE.CROSS then
		channel_type = CHANNEL_TYPE.WORLD
	end
	local channel = self:GetChannel(channel_type)
	if nil ~= channel then
		self:InsertMsgToChannel(channel, msg_info)
	end
	--场景频道和公会不插入全部
	--if channel_type ~= CHANNEL_TYPE.SCENE and channel_type ~= CHANNEL_TYPE.GUILD then
	if channel_type ~= CHANNEL_TYPE.SCENE then
		self:InsertMsgToChannel(self.channel_list[CHANNEL_TYPE.ALL], msg_info)
	end

	self.personalize_channel_window_bubble_type = msg_info.personalize_channel_window_bubble_type
	self.personalize_speaker_window_bubble_type = msg_info.personalize_speaker_window_bubble_type
end

function ChatData:GetChannelBubbleType()
	return self.personalize_channel_window_bubble_type
end

function ChatData:GetSpeakerBubbleType()
	return self.personalize_speaker_window_bubble_type
end

function ChatData:RemoveMsgToChannel(channel_type)
	local channel = self:GetChannel(channel_type)
	channel.msg_list = {}
end

-- 插入消息到频道
function ChatData:InsertMsgToChannel(channel, msg_info, channel_type)
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

function ChatData:DelChannelList()
	for k, v in pairs(self.channel_list) do
		for i = #v.msg_list, 1, -1 do
			if v.msg_list[i] then
				if ScoietyData.Instance:IsBlack(v.msg_list[i].from_uid) then
					table.remove(v.msg_list, i)
				end
			end
		end
	end
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
		-- self:AddNormalChatList(private_obj)
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
		self:RemoveNormalChatList(private_obj.role_id)
	end
end

-- 根据索引移除私聊对象
function ChatData:RemovePrivateObjByIndex(index)
	local private_obj = self.private_obj_list[index]
	if nil ~= private_obj then
		table.remove(self.private_obj_list, index)
		self.private_obj_map[private_obj.role_id] = nil
		self:RemoveNormalChatList(private_obj.role_id)
	end
end

--添加总聊天列表
function ChatData:AddNormalChatList(data)
	if nil == self.normal_chat_list_map[data.role_id] then
		self.normal_chat_list_map[data.role_id] = data
		table.insert(self.normal_chat_list, data)
		table.sort(self.normal_chat_list, ChatData.SortNormalChatList)
	end
end

--移除总聊天列表
function ChatData:RemoveNormalChatList(role_id)
	if nil ~= self.normal_chat_list_map[role_id] then
		self.normal_chat_list_map[role_id] = nil

		for k, v in ipairs(self.normal_chat_list) do
			if v.role_id == role_id then
				table.remove(self.normal_chat_list, k)
			end
		end
	end
end

--获取聊天对象信息
function ChatData:GetTargetDataByRoleId(role_id)
	return self.normal_chat_list_map[role_id]
end

function ChatData:GetNormalChatList()
	return self.normal_chat_list
end

function ChatData.SortNormalChatList(a, b)
	local order_a = 1000
	local order_b = 1000
	if a.role_id == SPECIAL_CHAT_ID.GUILD or b.role_id == SPECIAL_CHAT_ID.GUILD then
		if a.role_id == SPECIAL_CHAT_ID.GUILD then
			order_a = order_a + 100
		else
			order_b = order_b + 100
		end
	elseif a.role_id == SPECIAL_CHAT_ID.TEAM or b.role_id == SPECIAL_CHAT_ID.TEAM then
		if a.role_id == SPECIAL_CHAT_ID.TEAM then
			order_a = order_a + 10
		else
			order_b = order_b + 10
		end
	elseif a.create_time < b.create_time then
		order_a = order_a + 1
	elseif a.create_time > b.create_time then
		order_b = order_b + 1
	end
	return order_a > order_b
 end

-- 移除黑名单对应私聊对象
function ChatData:RemovePrivateObjIsBlack()
	if not next(self.private_obj_list) then return end
	for i = #self.private_obj_list, 1, -1 do
		if self.private_obj_list[i] then
			local role_id = self.private_obj_list[i].role_id
			if ScoietyData.Instance:IsBlack(role_id) then
				table.remove(self.private_obj_list, i)
				self:RemoveNormalChatList(role_id)
			end
		end
	end
end

-- 获取私聊列表
function ChatData:GetPrivateObjList()
	if nil ~= self.private_obj_list then
		return self.private_obj_list
	end
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
		private_obj.guildname = msg_info.guildname
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

	self.private_window_bubble_type = msg_info.personalize_window_bubble_type
end

function ChatData:GetPrivateBubbleType()
	return self.private_window_bubble_type
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
	local i = 1
	while i <= #self.private_unread_list do
		if self.private_unread_list[i].from_uid == uid then
			table.remove(self.private_unread_list, i)
		else
		i = i + 1
		end
	end
end

-- 记录当前聊天对象id
function ChatData:SetCurrentRoleId(role_id)
	if GameVoManager.Instance:GetMainRoleVo().role_id == role_id then
		print_warning("异常id", role_id)
		role_id = 0
	end
	self.current_id = role_id
end


function ChatData:GetCurrentRoleId()
	return self.current_id or 0
end

--设置是否有新的私聊消息
function ChatData:SetHavePriviteChat(value)
	self.have_privite_chat = value
end

--获取是否有未读消息
function ChatData:GetIsHavePrivateUnreadMsg(uid)
	local is_have = false
	for k, v in ipairs(self.private_unread_list) do
		if uid == v.from_uid then
			is_have = true
			break
		end
	end
	return is_have
end

function ChatData:GetHavePriviteChat()
	return self.have_privite_chat
end

--获取当前私聊id的未读消息数量
function ChatData:GetPrivateUnreadMsgCountById(role_id)
	local count = 0
	for _, v in ipairs(self.private_unread_list) do
		if role_id == v.from_uid then
			count = count + 1
		end
	end
	return count
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
	self.team_unread_count = self.team_unread_count + 1
end

-- 移除组队未读消息
function ChatData:RemTeamUnreadMsg()
	self.team_unread_list = {}
	self.team_unread_count = 0
end

-- 获取组队未读消息数目
function ChatData:GetTeamUnreadCount()
	return self.team_unread_count
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

function ChatData:InsertItemTab(item_data, from_view)
	local mark = ""
	local param_str = ""
	local config, item_type = ItemData.Instance:GetItemConfig(item_data.item_id)
	if item_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT then
		mark = "myeq"
		local param = item_data.param or {}

		local param_data = {}
		table.insert(param_data, param.strengthen_level or 0)
		table.insert(param_data, param.quality or 0)
		table.insert(param_data, param.shen_level or 0)
		table.insert(param_data, param.fuling_level or 0)
		table.insert(param_data, param.has_lucky or 0)
		table.insert(param_data, param.star_level or 0)
		for i=1,COMMON_CONSTS.XIANPIN_MAX_NUM do
			local xianpin_type = param.xianpin_type_list[i] or 0
			if xianpin_type > 0 then
				table.insert(param_data, xianpin_type)
			end
		end

		param_str = config.id
		for i, v in ipairs(param_data) do
			param_str = param_str .. ":" .. v
		end
	else
		mark = "myi"
	end
	if from_view == TipsShowProViewFrom.FROM_CHAT then
		table.insert(self.item_tab_from_chat, "{" .. mark .. ";".. item_data.item_id .. ";" .. param_str .."}")
	elseif from_view == TipsShowProViewFrom.FROM_GUILD then
		table.insert(self.item_tab_from_guild, "{" .. mark .. ";".. item_data.item_id .. ";" .. param_str .."}")
	end
end


function ChatData:InsertPointTab(map_name, point_x, point_y, scene_id, scene_key)
	table.insert(self.point_tab, "{point;".. map_name .. ";" .. point_x .. ";" .. point_y .. ";" .. scene_id .. ";" .. scene_key .. "}")
end

function ChatData:CheckFaceAndItem(msg, from_view)
	local str = msg
	--格式化列表中的表情
	for _,v in ipairs(self.face_tab) do
		local params = self:GetSplitData(v)

		local i, j = 0, 0
		while true do
			i, j = string.find(str, "(%/[0-9][0-9][0-9])", j+1)
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
		i, j = string.find(str, "(%/[0-9][0-9][0-9])", j + 1)
		if nil == i or nil == j then
			break
		else
			local num =  string.sub(str, i + 1, j) + 0
			if num >= 1 and num <= 32 then
				local src = string.sub(str, i, j)

				str = string.gsub(str, src, "{face;" .. string.format("%03d", num) .. "}")
			end
		end
	end

	--格式化坐标列表中的数据
	for _,v in ipairs(self.point_tab) do
		local params = self:GetSplitData(v)
		local match = params[2] .. "%(" .. params[3] .. "," .. params[4] .. "%)"

		i, j = 0, 0
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
	local function format_item_tab(item_tab)
		for _,v in ipairs(item_tab) do
			local params = self:GetSplitData(v)

			i, j = 0, 0
			while true do
				i, j = string.find(str, "(%[.-%])", j + 1)
				if nil == i or nil == j then
					break
				elseif ItemData.Instance:GetItemName(params[2] + 0) == string.sub(str, i + 1, j - 1) then
					local src = string.sub(str, i + 1, j - 1)
					src = string.gsub(src, "%)", "%%%)")
					src = string.gsub(src, "%(", "%%%(")
					str = string.gsub(str, "%[" .. src .. "%]", v)
				end
			end
		end
	end

	if from_view == TipsShowProViewFrom.FROM_CHAT then
		format_item_tab(self.item_tab_from_chat)
	elseif from_view == TipsShowProViewFrom.FROM_GUILD then
		format_item_tab(self.item_tab_from_guild)
	end
	return str
end

-- 格式化，过滤文本
function ChatData:FormattingMsg(msg, content_type, from_view)

	if content_type == CHAT_CONTENT_TYPE.AUDIO then
		return msg
	end
	msg = string.gsub(msg, "{", "(")
	msg = string.gsub(msg, "}", ")")
	msg = string.match(msg,"%s*(.-)%s*$")
	local str = self:CheckFaceAndItem(msg, from_view)
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
	self.item_tab_from_chat = {}
	self.item_tab_from_guild = {}
	self.point_tab = {}
end

-- 校验列表与输入框
function ChatData.ExamineListByEditText(msg, n)
	local lists =
	{
		TableCopy(ChatData.Instance.point_tab),
		ChatData.Instance.item_tab_from_chat,
		ChatData.Instance.face_tab,
		ChatData.Instance.item_tab_from_guild
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
			elseif n == 2 or n == 4 then
				find_str = "%[" .. ItemData.Instance:GetItemName(find_arr[2] + 0) .. "%]"
			elseif n == 3 then
				find_str = "%/" .. find_arr[2]
			end
			find_str = string.gsub(find_str, "}", "")
			find_str = string.gsub(find_str, "{", "")
			if n == 2 or n == 4 then
				find_str = string.gsub(find_str, "%)", "%%%)")
				find_str = string.gsub(find_str, "%(", "%%%(")
			end

			i, j = string.find(str, find_str, j)
			if j == nil then
				table.remove(list, k)
			else
				local m = 0
				msg, m = string.gsub(msg, find_str, "")
				appear_num = appear_num + m
			end
		end
	end
	return appear_num
end

-- 检查文本内容
function ChatData.ExamineEditText(msg, n)
	local num = n > 0 and 1 or 0
	local boolean = true
	local max_arr = {CHAT_POS_MAX, CHAT_ITEM_MAX, CHAT_FACE_MAX, CHAT_ITEM_MAX}
	for i = 1, 4 do
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
	local str = edit.input_field.text
	--local text_num = AdapterToLua:utf8FontCount(str)
	if string.len(str) > num then
		--str = AdapterToLua:utf8TruncateByFontCount(str, num)
		str = string.sub(str,1,num)
		edit.input_field.text = str
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.ContentToLong)
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
	if main_role_vo.level < COMMON_CONSTS.CHAT_LEVEL_LIMIT then
		local level_str = PlayerData.GetLevelString(COMMON_CONSTS.CHAT_LEVEL_LIMIT)
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.LevelDeficient, level_str))
		return false
	end

	--组队聊天是判断是否有队伍
	if channel == CHANNEL_TYPE.TEAM and not ScoietyData.Instance:GetTeamState() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NoTeam)
		return false
	end

	return true
end

-- 过滤消息，返回是否显示
function ChatData.FiltrationMsg(content)
	local is_show = true
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	local find_pos = string.find(content, "{team;")
	if nil ~= find_pos then
		local team_element = string.sub(content, find_pos, string.len(content))
		team_element = string.gsub(team_element, "{", "")
		team_element = string.gsub(team_element, "}", "")
		local params = Split(team_element, ";")
		local team_index = tonumber(params[3])
		local team_lev = tonumber(params[4]) or 0

		if team_index == ScoietyData.Instance:GetTeamIndex() then
			is_show = false
		end
		if role_vo.level < team_lev then
			is_show = false
		end
	end
	return is_show
end

function ChatData:SetHeadSayState(value)
	self.headsay_state = value
end

function ChatData:GetHeadSayState()
	return self.headsay_state
end

function ChatData:SetChannelItemHeight(channel_type, msg_id, height)
	local channel_list = self.chat_channel_size_list[channel_type]
	if channel_list then
		channel_list[msg_id] = height
	end
end

function ChatData:GetChannelItemHeight(channel_type, msg_id)
	local channel_list = self.chat_channel_size_list[channel_type]
	if channel_list then
		return channel_list[msg_id] or 0
	end
	return nil
end

function ChatData:SetIsLockState(state)
	self.is_lock = state
end

function ChatData:GetIsLockState()
	return self.is_lock
	-- return false
end

-- 获取中英混合字符串
function ChatData:SubStringUTF8(str, startIndex, endIndex)
    if startIndex < 0 then
        startIndex = self:SubStringGetTotalIndex(str) + startIndex + 1
    end

    if endIndex ~= nil and endIndex < 0 then
        endIndex = self:SubStringGetTotalIndex(str) + endIndex + 1
    end

    if endIndex == nil then
        return string.sub(str, self:SubStringGetTrueIndex(str, startIndex))
    else
        return string.sub(str, self:SubStringGetTrueIndex(str, startIndex), self:SubStringGetTrueIndex(str, endIndex + 1) - 1)
    end
end

--获取中英混合UTF8字符串的真实字符数量
function ChatData:SubStringGetTotalIndex(str)
    local curIndex = 0
    local i = 1
    local lastCount = 1
    repeat
        lastCount = self:SubStringGetByteCount(str, i)
        i = i + lastCount
        curIndex = curIndex + 1
    until(lastCount == 0)
    return curIndex - 1
end

function ChatData:SubStringGetTrueIndex(str, index)
    local curIndex = 0
    local i = 1
    local lastCount = 1
    repeat
        lastCount = self:SubStringGetByteCount(str, i)
        i = i + lastCount
        curIndex = curIndex + 1
    until(curIndex >= index)
    return i - lastCount
end

--返回当前字符实际占用的字符数
function ChatData:SubStringGetByteCount(str, index)
    local curByte = string.byte(str, index)
    local byteCount = 1
    if curByte == nil then
        byteCount = 0
    elseif curByte > 0 and curByte <= 127 then
        byteCount = 1
    elseif curByte>=192 and curByte<=223 then
        byteCount = 2
    elseif curByte>=224 and curByte<=239 then
        byteCount = 3
    elseif curByte>=240 and curByte<=247 then
        byteCount = 4
    end
    return byteCount
end

--添加系统缓存数据
function ChatData:AddTempSystemList(msg_info)
	if #self.temp_system_list >= CacheMsgMaxCount then
		table.remove(self.temp_system_list, 1)
	end
	table.insert(self.temp_system_list, msg_info)
end

function ChatData:RemoveTempSystemList(key)
	table.remove(self.temp_system_list, key)
end

function ChatData:GetTempSystemList()
	return self.temp_system_list
end

--添加世界缓存数据
function ChatData:AddTempWorldList(msg_info)
	table.insert(self.temp_world_list, msg_info)
end

function ChatData:RemoveTempWorldList(key)
	table.remove(self.temp_world_list, key)
end

function ChatData:GetTempWorldList()
	return self.temp_world_list
end

function ChatData:GetGuildUnreadMsg()
	return self.guild_unread_msg
end

--清除公会未读消息
function ChatData:ClearGuildUnreadMsg()
	self.guild_unread_msg = nil
end

--设置是否发送语音
function ChatData:SetCanSendVoice(state)
	self.can_send_voice = state
end

function ChatData:CanSendVoice()
	return self.can_send_voice
end

--设置是否播放世界语音
function ChatData:SetAutoWorldVoice(state)
	self.world_voice_state = state
end

function ChatData:GetAutoWorldVoice()
	return self.world_voice_state
end

--设置是否播放队伍语音
function ChatData:SetAutoTeamVoice(state)
	self.team_voice_state = state
end

function ChatData:GetAutoTeamVoice()
	return self.team_voice_state
end

--设置是否播放公会语音
function ChatData:SetAutoGuildVoice(state)
	self.guild_voice_state = state
end

function ChatData:GetAutoGuildVoice()
	return self.guild_voice_state
end

--设置是否播放私聊语音
function ChatData:SetAutoPriviteVoice(state)
	self.privite_voice_state = state
end

function ChatData:GetAutoPriviteVoice()
	return self.privite_voice_state
end

function ChatData:GetShowRed()
	local big_face_level = CoolChatData.Instance:GetBigFaceLevel() or 0 -- 当前等级
	local big_face_cfg = CoolChatData.Instance:GetBigFaceConfig()
	local level_cfg = big_face_cfg.level_cfg
	local cfg = level_cfg[big_face_level + 1]
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local prof_item = ChatProfItems[main_role_vo.prof]

	if cfg and CoolChatData.Instance:GetCoolChatRedPoint() then 
		local has_num = ItemData.Instance:GetItemNumInBagById(cfg[prof_item].item_id) or 0
		if has_num >= cfg[prof_item].num then
			return 1
		end
	end

	if HeadFrameData.Instance:GetHeadFrameRedPoint() then
		return 1
	end
	
	return 0
end

function ChatData:SetChatInfoList(info)
	self.chat_info_list = info or {}
end

function ChatData:GetChatInfoList()
	if self.chat_info_list ~= nil then
		return self.chat_info_list
	end
end