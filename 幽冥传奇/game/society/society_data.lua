--------------------------------------------------------
-- 好友数据
--------------------------------------------------------

----------好友全局定义----------

--关系类型
SOCIETY_RELATION_TYPE = 
{
	FRIEND = 0,				--好友
	ENEMY = 1,				--仇敌
	BLACKLIST = 2,			--黑名单
}
--添加删除操作
SOCIETY_OPERATE_TYPE = 
{
	ADD = 0,			--添加
	DEL = 1,			--删除
}
--仇人处理操作
SOCIETY_ENEMY_DEAL_TYPE = 
{
	CHECK = 1,			--查看
	DEL = 2,			--删除
}
--是否同意
SOCIETY_IS_AGREE_FRIEND = 
{
	NO = 0,				--不同意
	YES = 1,			--同意
}

SOCIETY_ONLINE = 1
SOCIETY_OFFLINE = 0

-- 数量统计
SOCIETY_SUM_UP = 
{
	[SOCIETY_RELATION_TYPE.FRIEND] = {online = 0, total = 0},					--好友在线与总数量统计
	[SOCIETY_RELATION_TYPE.ENEMY] = {online = 0, total = 0},					--仇敌在线与总数量统计
	[SOCIETY_RELATION_TYPE.BLACKLIST] = {online = 0, total = 0},				--黑名单在线与总数量统计
}

----------end----------

SocietyData = SocietyData or BaseClass()

-- 数据改变监听
SocietyData.SHOW_RULES_CHANGE = "show_rules_change"
-- SocietyData.TRACE_INFO_DATA_CHANGE = "trace_info_data_change"
SocietyData.SOCIETY_LIST_CHANGE = "society_list_change"

function SocietyData:__init()
	if SocietyData.Instance then
		ErrorLog("[SocietyData]:Attempt to create singleton twice!")
	end

	SocietyData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.search_result = {}
	self.relation_list = {}
	self.apply_list = {}
	self.trace_target_info = {}
	self.enemy_list = {}
	self.info_index = 0
	self.rules = true -- 显示规则,默认显示全部


	-- 绑定红点提示触发条件
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.ApplyAddFriends)
end

function SocietyData:__delete()
	SocietyData.Instance = nil
end

function SocietyData:SetSearchResultData(protocol)
	self.search_result = protocol.search_result_list
	-- for k,v in pairs(protocol.search_result_list) do
	-- 	table.insert(self.search_result, v)
	-- end
	self:DispatchEvent(SocietyData.SOCIETY_LIST_CHANGE)
end

function SocietyData:GetSearchResult()
	return self.search_result
end

function SocietyData:EmptySearchResult()
	self.search_result = {}
end

function SocietyData:EmptyApplyList()
	self.apply_list = {}
end

function SocietyData:IsFriend(name)
	local is_friend = false
	for k, v in pairs(self:GetFriendList()) do
		if v.name == name then
			return true
		end
	end
	return is_friend
end

--获取某一类关系列表
function SocietyData:GetRelationshipList(type)
	return self.relation_list[type] or {}
end

--获取好友列表
function SocietyData:GetFriendList()
	return self.relation_list[SOCIETY_RELATION_TYPE.FRIEND] or {}
end

--更新关系总列表
function SocietyData:UpdateRelationshipList(protocol)
	local change_type_t = {}	-- 记录所有变化的信息类型
	for i, v in pairs(protocol.relation_info_list) do
		for k1, v1 in pairs(v.type) do
			if "number" == type(v1) and 0 <= v1 then
				local data = TableCopy(v)
				self:SetRelationListData(v1, data)
				change_type_t[v1] = 1
			end
		end
	end
	for k,v in pairs(change_type_t) do
		GlobalEventSystem:Fire(OtherEventType.RERATION_INFO_CHANGE, k)
	end
	if next(self.relation_list) then
		self:SortAndSumUpRelationList()
	end
end

function SocietyData:SetRelationListData(rel_type, data)
	if not rel_type or not data then
		return
	end

	if nil == self.relation_list[rel_type] then
		self.relation_list[rel_type] = {}
	end
	local list = self.relation_list[rel_type]

	local data_key = nil
	for k, v in pairs(list) do
		if data.role_id == v.role_id then
			data_key = k
			break
		end
	end
	data.type = rel_type
	if nil ~= data_key then
		-- 更新数据
		list[data_key] = {
			type = rel_type,
			role_id = data.role_id,
			name = data.name,
			prof = data.prof,
			level = data.level,
			avatar_id = data.avatar_id,
			feel = data.feel,
			sex = data.sex,
			guild_name = data.guild_name,
			is_online = data.is_online,
			intimacy = data.intimacy,
		}
	else
		-- 增加数据
		table.insert(list, data)
	end
end

--申请列表数据
function SocietyData:SetApplyListData(protocol)
	local data = {}
	data.role_id = protocol.self_id
	data.name = protocol.self_name
	data.level = protocol.level
	data.prof = protocol.prof
	data.guild_name = protocol.guild_name
	for k,v in pairs(self.apply_list) do
		if v.role_id == protocol.self_id then
			return
		end
	end
	table.insert(self.apply_list, data)
	self:DispatchEvent(SocietyData.SOCIETY_LIST_CHANGE)
	RemindManager.Instance:DoRemindDelayTime(RemindName.ApplyAddFriends)
end

function SocietyData:GetApplyListData()
	return self.apply_list
end

function SocietyData:DelAskAddSendData(opposite_id)
	local del_index = nil
	for k, v in pairs(self.apply_list) do
		if v.role_id == opposite_id then
			del_index = k
		end
	end
	if del_index then
		table.remove(self.apply_list, del_index)
	end
end

function SocietyData:DelSearchResultData(role_id)
	local del_index = nil
	for k, v in pairs(self.search_result) do
		if v.role_id == role_id then
			del_index = k
		end
	end
	if del_index then
		table.remove(self.search_result, del_index)
	end
end

--根据名称获取role_id
function SocietyData:GetFriendIdByName(role_name)
	for _,v in pairs(self:GetFriendList()) do
		if v.name == role_name then
			return v.role_id
		end	
	end	
	return -1
end

function SocietyData:GetFriendLevelByName(role_name)
	for _,v in pairs(self:GetFriendList()) do
		if v.name == role_name then
			return v.level
		end	
	end	
	return 0
end

--添加或删除某人
function SocietyData:AddOrDelSomeOneData(protocol)
	self.relation_list[protocol.relate_column] = self.relation_list[protocol.relate_column] or {}
	if protocol.op_type == SOCIETY_OPERATE_TYPE.ADD then		--添加
		self:SetRelationListData(protocol.relate_column, protocol.opposite_info)
		self:DelAskAddSendData(protocol.opposite_info.role_id)
	elseif protocol.op_type == SOCIETY_OPERATE_TYPE.DEL then	--删除
		for k,v in pairs(self.relation_list[protocol.relate_column]) do
			if v.role_id == protocol.role_id then
				table.remove(self.relation_list[protocol.relate_column], k)
				break
			end
		end
	end
	self:SortAndSumUpRelationList()
	GlobalEventSystem:Fire(OtherEventType.RERATION_INFO_CHANGE, protocol.relate_column)
	self:DispatchEvent(SocietyData.SOCIETY_LIST_CHANGE)
	RemindManager.Instance:DoRemindDelayTime(RemindName.ApplyAddFriends)
end

--仇人列表仇人信息
function SocietyData:SetEnemyListData(protocol)
	self.enemy_list = protocol.enemy_list
end

function SocietyData:GetEnemyListData()
	return self.enemy_list
end

--追踪目标信息
function SocietyData:SetTraceInfoData(protocol)
	self.info_index = self.info_index + 1
	local data = {}
	data.role_id = protocol.role_id
	data.name = protocol.name
	data.scene_id = protocol.scene_id
	data.scene_name = protocol.scene_name
	data.pos_x = protocol.pos_x
	data.pos_y = protocol.pos_y
	data.index = self.info_index
	for k,v in pairs(self.trace_target_info) do
		if v.role_id == data.role_id then 
			self.trace_target_info[k] = data
			return
		end
	end
	table.insert(self.trace_target_info, data)
	-- self:DispatchEvent(SocietyData.TRACE_INFO_DATA_CHANGE)
end

function SocietyData:GetTraceInfoData()
	return self.trace_target_info
end

--获取人数统计
function SocietyData.GetOnlineAndTotalNum(index)
	local sum_list = {}
	if index == 1 then
		sum_list = SOCIETY_SUM_UP[SOCIETY_RELATION_TYPE.FRIEND]
	elseif index == 2 then
		sum_list = SOCIETY_SUM_UP[SOCIETY_RELATION_TYPE.ENEMY]
	elseif index == 3 then
		sum_list = SOCIETY_SUM_UP[SOCIETY_RELATION_TYPE.BLACKLIST]
	end
	return sum_list
end

--排序统计在线及总人数
function SocietyData:SortAndSumUpRelationList()
	for i = 0, 2 do
		self.relation_list[i] = self.relation_list[i] or {}
		--排序
		if next(self.relation_list[i]) then
			table.sort(self.relation_list[i], SortTools.KeyUpperSorters("is_online", "level"))
		end
		-- 统计每种关系中在线人数和总人数
		local online_num = 0
		local total_num  = 0
		total_num = #self.relation_list[i]
		for k_2,v_2 in pairs(self.relation_list[i]) do
			if v_2.is_online == SOCIETY_ONLINE then
				online_num = online_num + 1
			end
		end
		SOCIETY_SUM_UP[i].online = online_num
		SOCIETY_SUM_UP[i].total = total_num
	end
	-- --排序
	-- for k,v in pairs(self.relation_list) do
	-- 	if next(v) then
	-- 		table.sort(v, SortTools.KeyUpperSorters("is_online", "level"))
	-- 	end
	-- end
end


-- 下发请求结婚
function SocietyData:SetRequestMarry(protocol)
	self.request_marry_list = {}
	self.request_marry_list.role_id = protocol.role_id
	self.request_marry_list.role_name = protocol.role_name
end

-- 设置显示规则 true表示显示所有,false表示只显示在线
function SocietyData:SetShowRules(bool)
	self.rules = not bool
	self:DispatchEvent(SocietyData.SHOW_RULES_CHANGE)
end

function SocietyData:GetShowRules()
	return self.rules
end

-- 获取提醒显示索引 0不显示红点, 1显示红点
function SocietyData.GetRemindIndex()
	local list = SocietyData.Instance:GetApplyListData()
	local index = nil ~= list[1] and 1 or 0
	return index
end
