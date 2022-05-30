-- --------------------------------------------------------------------
-- --------------------------------------------------------------------
InviteCodeModel = InviteCodeModel or BaseClass()

local tesk_list = Config.InviteCodeData.data_tesk_list
local table_insert = table.insert
local table_sort = table.sort
function InviteCodeModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function InviteCodeModel:config()
	self.teskData = {}
	self.friend_data = {}
	self.friend_chat_data = {}
end

function InviteCodeModel:setInviteCode(code)
	self.invite_code = code
end
function InviteCodeModel:getInviteCode()
	return self.invite_code or "获取推荐码失败"
end
--是否可领取的数据
function InviteCodeModel:setInviteCodeTeskData(data)
	for i,v in pairs(data) do
		self.teskData[v.id] = v
	end
	self:checkoutInviteRedPoint()
end
--数据更新
function InviteCodeModel:setUpdataInviteCodeTeskData(data)
	if self.teskData and self.teskData[data.id] then
		local tab = {}
		tab.id = data.id
		tab.had = data.had
		tab.num = data.num
		self.teskData[data.id] = tab
	end
	self:checkoutInviteRedPoint()
end

function InviteCodeModel:checkoutInviteRedPoint()
	local red_point = false
	if self.teskData then
		for i,v in pairs(self.teskData) do
			if v.num > v.had then
				red_point = true
				break
			end
		end
	end
	self.invite_redpoint = red_point
	WelfareController:getInstance():setWelfareStatus(WelfareIcon.invicode,red_point)
end
--邀请红点
function InviteCodeModel:inviteRedPoint()
	if self.invite_redpoint then
		return self.invite_redpoint
	end
	return false
end

function InviteCodeModel:getInviteCodeFinishData(id)
	if self.teskData and self.teskData[id] then
		return self.teskData[id]
	end
	return {} 
end
--配置表任务
function InviteCodeModel:getInviteCodeTeskData()
	local list = {}
	for i,v in pairs(tesk_list) do
		v.status = 0 --未完成
		if self.teskData[v.id] then
			if self.teskData[v.id].had >= v.num then
				v.status = 2 --完成
			else
				v.status = 1 --领取
			end
		end
		table_insert(list,v)
	end
	self:setSortItem(list)
	return list
end
function InviteCodeModel:setSortItem(data_list)
    local tempsort = {
        [0] = 2,
        [1] = 1,
        [2] = 3,
    }
    local function sortFunc(objA,objB)
        if objA.status ~= objB.status then
            if tempsort[objA.status] and tempsort[objB.status] then
                return tempsort[objA.status] < tempsort[objB.status]
            else
                return false
            end
        else
            return objA.id < objB.id
        end
    end
    table_sort(data_list, sortFunc)
end
--获取个人信息，私聊用到
function InviteCodeModel:setFriendChatData()
	if self.friend_data then
		for i,v in pairs(self.friend_data) do
			local key = getNorKey(v.rid, v.srv_id)
			self.friend_chat_data[key] = v
		end
	end
end

function InviteCodeModel:addFriendChatData(data)
	if not data or next(data) == nil then return end
	local key = getNorKey(data.rid, data.srv_id)
	if self.friend_chat_data[key] == nil then
		self.friend_chat_data[key] = data
	end
end

function InviteCodeModel:getFriendChatData(rid, srv_id)
	if self.friend_chat_data then
		local key = getNorKey(rid, srv_id)
		return self.friend_chat_data[key] or nil
	end
	return nil
end
--已邀请好友
function InviteCodeModel:setAlreadyFriendData(data)
	for i,v in pairs(data) do
		local key = getNorKey(v.rid, v.srv_id)
		self.friend_data[key] = v
	end
	self:setFriendChatData()
end
function InviteCodeModel:getAlreadyFriendData()
	if not self.friend_data or next(self.friend_data) == nil then return {} end
	local list = {}
	for i,v in pairs(self.friend_data) do
		table_insert(list,v)
	end
	return list
end
function InviteCodeModel:setUpdataAlreadyFriendData(data)
	if not self.friend_data or not data then return end
	for i,v in pairs(self.friend_data) do
		local key = getNorKey(v.rid, v.srv_id)
		self.friend_data[key] = v
	end
	local key = getNorKey(data.rid, data.srv_id)
	self.friend_data[key] = data

	self:setFriendChatData()
end
--获取邀请好友个数
function InviteCodeModel:getFirendNum()
	local num = self:getAlreadyFriendData()
	return #num or 0
end

-----------------------------
--老友回归
function InviteCodeModel:setFriendReturnData()
	local return_data = Config.InviteCodeData.data_return_list
	if return_data then
		self.return_list = {}
		for i,v in pairs(return_data) do
			table_insert(self.return_list,v)
		end
		table_sort(self.return_list, function(a,b) return a.id < b.id end)
	end
end
function InviteCodeModel:getFriendReturnData()
	if self.return_list then
		return self.return_list
	end
	return nil
end
--回归奖励信息
function InviteCodeModel:setReturnReawrdList(data)
	if data and data.list then
		self.reward_list = {}
		for i,v in pairs(data.list) do
			self.reward_list[v.id] = v
		end
		self:checkRedPoint()
	end
end
function InviteCodeModel:getReturnReawrdList(id)
	if self.reward_list and self.reward_list[id] then
		return self.reward_list[id]
	end
	return nil
end
--更新数据
function InviteCodeModel:setUpdataReturnReawrdList(data)
	if data then
		if self.reward_list and self.reward_list[data.id] then
			self.reward_list[data.id].num = data.num
			self.reward_list[data.id].had = data.had
		end
		self:checkRedPoint()
	end
end
--邀请回归红点
function InviteCodeModel:checkRedPoint()
	if self.reward_list then
		local is_open = ReturnActionController:getInstance():getModel():getActionIsOpen()
		if is_open == 0 then return end

		local red_point = false
		if SHOW_SINGLE_INVICODE then
			for i,v in pairs(self.reward_list) do
				if v.num > v.had then
					red_point = true
					break
				end
			end
		end
		self.return_redpoint = red_point
		WelfareController:getInstance():setWelfareStatus(WelfareIcon.invicode,red_point)
	end
end
function InviteCodeModel:getReturnRedPoint()
	if self.return_redpoint then
		return self.return_redpoint
	end
	return false
end

function InviteCodeModel:setOpenServerTime(data)
	if data and data.open_timestamp then
		self.open_timestamp = data.open_timestamp
	end
end

function InviteCodeModel:getOpenServerTime()
	if self.open_timestamp ~= nil then
		return self.open_timestamp
	end
	return 0
end

function InviteCodeModel:__delete()
end