
FriendDataManager = {}

FriendDataManager.chat_channel_world = 1; -- 世界频道
FriendDataManager.chat_channel_meipai = 2; -- 门派频道
FriendDataManager.chat_channel_team = 3; -- 队伍频道
FriendDataManager.chat_channel_self = 4; -- 私聊频道

FriendDataManager.chat_data_type_txt = 1; -- 聊天内容 文本
FriendDataManager.chat_data_type_voice = 2; -- 聊天内容 语音

FriendDataManager.type_friend = 1 -- 好友
FriendDataManager.type_enemy = 2  -- 仇人
FriendDataManager.type_stranger = 3  -- 陌生人

FriendDataManager.friend_max_num = 50;
FriendDataManager.enemy_max_num = 50;

FriendDataManager.curr_classify = "";

FriendDataManager.MESSAGE_PLAYER_CHANGE = "MESSAGE_PLAYER_CHANGE";
FriendDataManager.MESSAGE_CHAT_DATA_CHANGE = "MESSAGE_CHAT_DATA_CHANGE";
FriendDataManager.MESSAGE_CHAT_CHECK_CHANGE = "MESSAGE_CHAT_CHECK_CHANGE";
FriendDataManager.MESSAGE_STRANGER_CHANGE = "MESSAGE_STRANGER_CHANGE";
FriendDataManager.MESSAGE_SETSTRANGERLIST_COMPLETE = "MESSAGE_SETSTRANGERLIST_COMPLETE";
FriendDataManager.MESSAGE_CHAT_TIP_CHANGE = "MESSAGE_CHAT_TIP_CHANGE";
FriendDataManager.MESSAGE_CLASSIFY_CHANGE = "MESSAGE_CLASSIFY_CHANGE";
FriendDataManager.MESSAGE_REMOVEFRIENDCOMPLETE = "MESSAGE_REMOVEFRIENDCOMPLETE";
FriendDataManager.MESSAGE_SEND_CHAT_MSG_COMPLETE = "MESSAGE_SEND_CHAT_MSG_COMPLETE";

local friendList = {};
local enemyList = {};
FriendDataManager.strangerList = {}; -- 陌生人， 这个是 table 表的

FriendDataManager.need_get_strangerList = {}; -- 需要从后台获取数据的 id 列表

FriendDataManager.newChatList = {}; -- 最近聊天的 玩家
FriendDataManager.curr_select_stranger_id = "";


FriendDataManager.strangerList_order = 1;


FriendDataManager.charMsg = {}; -- 聊天 记录

FriendDataManager.needShowTips = {}; -- 是否有新聊天记录


FriendDataManager.currSelectTarget = nil; -- 当前选中的目标
FriendDataManager.lastTargetId = nil; -- 上次对话的目标pid

local _sortfunc = table.sort
local _insert = table.insert
-- 添加聊天记录
function FriendDataManager.AddChatMsg(id, chatData, needSetshowMg, check_autoRecStMsg)
	
	
	if check_autoRecStMsg and not AutoFightManager.autoRecStMsg then
		-- 不接收 陌生人信息 (只要不在好友列表里面的)
		local in_fd = FriendDataManager.GetFriend(id);
		
		local me = HeroController:GetInstance();
		local heroInfo = me.info;
		local my_id = tonumber(heroInfo.id);
		
		if in_fd == nil and my_id ~= tonumber(id) then
			return;
		end
	end
	
	
	needSetshowMg = id ~= PlayerManager.playerId;
	
	
	if id == PlayerManager.playerId then
		id = FriendDataManager.lastTargetId;
	end
	
	if FriendDataManager.charMsg[id] == nil then
		FriendDataManager.charMsg[id] = {};
	end
	
	local msg = FriendDataManager.charMsg[id];
	
	
	local old = ChatManager.VoiecHandler(msg, chatData)
	if old then
		-- 第二次语音翻译回包
		MessageManager.Dispatch(FriendDataManager, FriendDataManager.MESSAGE_CHAT_DATA_CHANGE, old)
		return
	end
	if chatData.s_id == PlayerManager.playerId then
		chatData.isMe = true;
		
	else
		chatData.isMe = false;
		
	end
	
	chatData.readed = chatData.isMe
	
	local t_num = table.getn(msg);
 
	chatData.sysTime = os.date("%Y-%m-%d %H:%M:%S", chatData.date / 1000);
	
	if t_num > 0 then
		local oldt = msg[t_num].date
		-- sys_time
		local dt = chatData.date - oldt
		-- sys_time - oldt;
		if dt > 90000 then
			chatData.needShowTime = true;
		else
			chatData.needShowTime = false;
		end
	else
		chatData.needShowTime = true;
	end
	
	t_num = t_num + 1;
	msg[t_num] = chatData;
	
	
	
	-- 添加 排序点， 用于 最近联系列表  排序
	msg[1].order = FriendDataManager.strangerList_order;
	FriendDataManager.strangerList_order = FriendDataManager.strangerList_order + 1;
	
	 
	-- 需要判断 是否需要显示 系统时间
	if needSetshowMg then
		if FriendDataManager.currSelectTarget == nil then
			FriendDataManager.needShowTips[id] = true;
			MessageManager.Dispatch(FriendDataManager, FriendDataManager.MESSAGE_CHAT_TIP_CHANGE);
		else
			
			local cid = FriendDataManager.currSelectTarget.id .. "";
			if cid ~= id then
				FriendDataManager.needShowTips[id] = true;
				MessageManager.Dispatch(FriendDataManager, FriendDataManager.MESSAGE_CHAT_TIP_CHANGE);
			end
		end
		
	end
	
	
	
	FriendDataManager.UpstrangerList();
	
	
	
	MessageManager.Dispatch(FriendDataManager, FriendDataManager.MESSAGE_CHAT_DATA_CHANGE, chatData);
end



function FriendDataManager.UpstrangerList(list)
	
	
	--   -- strangerList   这里需要 陌生人 对象
	FriendDataManager.need_get_strangerList = {};
	local need_index = 1;
	local st_change = false;
	
	local n_strangerList = {};
	for key, value in pairs(FriendDataManager.charMsg) do
		
		local obj = FriendDataManager.strangerList[key];
		
		if obj == nil then
			FriendDataManager.need_get_strangerList[need_index] = key;
			need_index = need_index + 1;
			st_change = true;
			
		else
			n_strangerList[key] = obj;
			
			----------------------- ------------------------------------------------------------------------------
			if list ~= nil then
				-- 是重 0x1202 拉数据的
				-- 需要同步 最近联系人数据
				------------------------------------------------------------------------------
				local m_id = tonumber(obj.id);
				for l_key, l_value in pairs(list) do
					local l_id = tonumber(l_value.id);
					if l_id == m_id then
						n_strangerList[key] = l_value;
					end
				end
				
				--------------------------------------------------------------------------
			end
			----------------------- ------------------------------------------------------------------------------
		end
		
		
	end
	
	FriendDataManager.strangerList = n_strangerList;
	
	
	if st_change then
		MessageManager.Dispatch(FriendDataManager, FriendDataManager.MESSAGE_STRANGER_CHANGE);
	end
	
end

--  需要 获取 新 玩家信息的时候获取
function FriendDataManager.SetStrangerList(list)
	
	for key, value in pairs(list) do
		local id = value.id .. "";
		-- 需要判断 这个对象 是否 是好友， 如果是的话， 那么就 在好友列表中 找到 对应的 tid
		local fd = FriendDataManager.GetFriend(id);
		
		if fd ~= nil then
			value.tid = fd.tid;
			
		end;
		
		FriendDataManager.strangerList[id] = value;
		
	end
	
	MessageManager.Dispatch(FriendDataManager, FriendDataManager.MESSAGE_SETSTRANGERLIST_COMPLETE);
end


function FriendDataManager.Get_strangerList()
	
	local arr = {};
	local arrIndex = 1;
	
	for key, value in pairs(FriendDataManager.strangerList) do
		arr[arrIndex] = value;
		arrIndex = arrIndex + 1;
	end
	
	FriendDataManager.TrySortList(arr);
	
	
	return arr;
end

function FriendDataManager.TrySortList(list)
	local t_num = table.getn(list);
	if t_num > 1 then
		_sortfunc(list, FriendDataManager.listSort);
	end
end

function FriendDataManager.listSort(a, b)
	local a_is_online = a.is_online;
	local b_is_online = b.is_online;
	
	if(a_is_online > b_is_online) then
		return true
	else
		return false
	end
end

function FriendDataManager.DispatchShowChatListEvent()
	MessageManager.Dispatch(FriendDataManager, FriendDataManager.MESSAGE_CHAT_CHECK_CHANGE);
end

--[[

]]
function FriendDataManager.SetHasNewChatMsg(id)
	
	for key, value in pairs(FriendDataManager.needShowTips) do
		if key == id then
			FriendDataManager.needShowTips[key] = nil;
			
		end
	end
end

function FriendDataManager.GetNeedShowTip(id)
	
	for key, value in pairs(FriendDataManager.needShowTips) do
		if key == id then
			return FriendDataManager.needShowTips[key];
		end
	end
	
	return false;
end

function FriendDataManager.HasNewChatMsg()
	
	for key, value in pairs(FriendDataManager.needShowTips) do
		if value == true then
			return true;
		end
	end
	
	return false;
end

-- 获取聊天 记录
function FriendDataManager.GetChatMsg(id)
	if FriendDataManager.charMsg[id] == nil then
		return {};
	else
		local msg = FriendDataManager.charMsg[id];
		_sortfunc(msg, function(a, b) return a.date > b.date end)
		return msg;
	end
	
	
end

function FriendDataManager.GetFriendList()
	return friendList
end

function FriendDataManager.GetEnemList()
	return enemyList
end

--获取所有关系 sdk用
--如果没有角色就设置为
function FriendDataManager.GetAllRelationList()
	local result = {}
	local has  = false
	if(friendList) then
		for k, v in ipairs(friendList) do
			local item = {}
			item.roleId = v.id
			item.intimacy = 0
			item.nexusId = 6
			item.nexusName = "好友"
			_insert(result, item)
			has = true
		end		
	end
	
	 
	if(enemyList) then		
		for k, v in ipairs(enemyList) do
			local item = {}
			item.roleId = v.id
			item.intimacy = 0
			item.nexusId = 5
			item.nexusName = "仇人"
			_insert(result, item)
			has = true
		end				
	end
	
	if(has == false) then
		return nil
	end
	return result
end

function FriendDataManager.Init(list)
	
	friendList = {};
	enemyList = {};
	--  FriendDataManager.strangerList = { }; 这里不能 重置  strangerList
	local friend_index = 1;
	local enemy_index = 1;
	
	for key, value in pairs(list) do
		local type = value.type;
		if type == FriendDataManager.type_friend then
			friendList[friend_index] = value;
			friend_index = friend_index + 1;
		elseif type == FriendDataManager.type_enemy then
			enemyList[enemy_index] = value;
			enemy_index = enemy_index + 1;	
			
		end
	end
	
	
	
	FriendDataManager.TrySortList(friendList);
	FriendDataManager.TrySortList(enemyList);
	
	
	FriendDataManager.DispatchEvent(FriendDataManager.type_friend);
	FriendDataManager.DispatchEvent(FriendDataManager.type_enemy);
	
	
	FriendDataManager.UpstrangerList(list);
	
	FriendDataManager.DispatchEvent(FriendDataManager.type_stranger);
end

--[[-k= [101000]
--msg= [0]
--lv= [100]
--s_id= [20100413]
--date= [1473387260890]
--s_name= [令狐北]
--c= [3]
--t= [1]

]]
-- 尝试 和目标人物 进行 私聊 
function FriendDataManager.TryOpenCharUI(p_id)
	
	FriendDataManager.TryOpenCharUIFor_target_id = p_id;
	FriendDataManager.curr_select_stranger_id = p_id .. "";
	FriendDataManager.lastTargetId = p_id;
	
	if FriendDataManager.TryOpenCharUIFor_target_id ~= nil then
		local temMsg = {msg = "", s_id = p_id, c = 4, t = 1, time = "", s_name = "--", prohibit_show = true, date = 100000000};
		-- prohibit_show 是禁止显示
		FriendDataManager.AddChatMsg(temMsg.s_id, temMsg, false, false)
		FriendDataManager.TryOpenCharUIFor_target_id = nil;
	end
	
	
	ModuleManager.SendNotification(FriendNotes.OPEN_FRIENDPANEL, FriendNotes.PANEL_FRIEND);
	
	
	
	-- {"msg":"dfgdfgrd","s_id":"20102690","c":4,"t":1,"time":"2016-05-30 11:17:07","s_name":"宇文英基"}
end

-- 删除 好友
function FriendDataManager.RemoveFriend(tid)
	tid = tid .. "";
	
	for key, value in ipairs(friendList) do
		local mtid = value.tid .. "";
		
		if tid == mtid then
			table.remove(friendList, key)		
			break	
		end
	end
	
	FriendDataManager.currSelectTarget = nil;
	
	-- friendList = newList;
	FriendDataManager.TrySortList(friendList);
	
	
	FriendDataManager.strangerList = {};
	FriendDataManager.UpstrangerList();
	
	
	
	MessageManager.Dispatch(FriendDataManager, FriendDataManager.MESSAGE_REMOVEFRIENDCOMPLETE);
	
	FriendDataManager.DispatchEvent(FriendDataManager.type_friend);
	FriendDataManager.DispatchEvent(FriendDataManager.type_enemy);
	FriendDataManager.DispatchEvent(FriendDataManager.type_stranger);
	
end

-- "friend":{"is_online":1,"id":"10100040","id":"206","type":1,"name ":"文霄师"}
function FriendDataManager.SetFriend(data)
	
	for key, value in pairs(friendList) do
		local id = value.id;
		if id == data.id then
			friendList[key] = data;
		end
	end
	
	if data.type == FriendDataManager.type_friend then
		
		-- 添加
		local t_num = table.getn(friendList);
		t_num = t_num + 1;
		
		friendList[t_num] = data;
		FriendDataManager.TrySortList(friendList);
		
	elseif data.type == FriendDataManager.type_enemy then
		
		local t_num = table.getn(enemyList);
		t_num = t_num + 1;
		
		enemyList[t_num] = data;
		FriendDataManager.TrySortList(enemyList);
		
	end
	
	
	
	FriendDataManager.DispatchEvent(FriendDataManager.type_friend);
	FriendDataManager.DispatchEvent(FriendDataManager.type_stranger);
	FriendDataManager.DispatchEvent(FriendDataManager.type_enemy);
	
end

function FriendDataManager.GetFriendNum()
	if friendList == nil then
		return 0;
	end
	local t_num = table.getn(friendList);
	return t_num;
end

function FriendDataManager.GetFriend(d_id)
	
	d_id = tonumber(d_id);
	for key, value in pairs(friendList) do
		local id = value.id + 0;
		if id == d_id then
			return value;
		end
	end
	
	return nil;
end

function FriendDataManager.IsFriend(d_id)
	if d_id == PlayerManager.playerId then return true end
	return FriendDataManager.GetFriend(d_id) ~= nil
end

function FriendDataManager.GetEnemy(d_id)
	
	d_id = tonumber(d_id);
	for key, value in pairs(enemyList) do
		local id = value.id + 0;
		if id == d_id then
			return value;
		end
	end
	
	return nil;
end



function FriendDataManager.SetNewChater(data)
	
	for key, value in pairs(FriendDataManager.newChatList) do
		local id = value.id;
		if id == data.id then
			FriendDataManager.newChatList[key] = data;
		end
	end
	
	-- 添加
	local t_num = table.getn(FriendDataManager.newChatList);
	t_num = t_num + 1;
	
	FriendDataManager.newChatList[t_num] = data;
	
	FriendDataManager.DispatchEvent(FriendDataManager.type_stranger)
end

function FriendDataManager.DispatchEvent(type)
	MessageManager.Dispatch(FriendDataManager, FriendDataManager.MESSAGE_PLAYER_CHANGE, type);
end 