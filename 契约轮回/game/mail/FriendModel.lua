FriendModel = FriendModel or class("FriendModel",BaseBagModel)
local FriendModel = FriendModel
local tableInsert = table.insert
local json = require "cjson"
json.encode_sparse_array(true)

function FriendModel:ctor()
	FriendModel.Instance = self

	self:Reset()
end

function FriendModel:Reset()
	self.all = {}
	self.contact_list = {}
	self.contact = {}
	self.friends = {}
	self.enemylist = {}
	self.blacklist = {}
	self.apply_list = {}
	self.manage_roles = {}
	self.messages = {}
	self.stranger = nil --私聊的陌生人
	self.select_role_id = 0

	self.change_recommend = 0 --换一批推荐人时间
end

function FriendModel.GetInstance()
	if FriendModel.Instance == nil then
		FriendModel()
	end
	return FriendModel.Instance
end


function FriendModel:SetFriendList(friend_list)
	for i=1, #friend_list do
		local friend = friend_list[i]
		if friend.relation == enum.RELATION.RELATION_FRIEND then
			self.friends[friend.base.id] = friend
		elseif friend.relation == enum.RELATION.RELATION_BLACK then
			self.blacklist[friend.base.id] = friend
		end
		if friend.is_enemy == 1 then
			self.enemylist[friend.base.id] = friend
		end
		self.all[friend.base.id] = friend
	end
end

function FriendModel:GetFriendList()
	return self.friends
end

function FriendModel:IsFriend(role_id)
	return self.friends[role_id]
end

function FriendModel:GetPFriend(role_id)
	return self.all[role_id] or self.contact_list[role_id]
end

function FriendModel:UpdateFriendBase(rolebase)
	if self.all[rolebase.id] then
		self.all[rolebase.id].base = rolebase
		self:Brocast(FriendEvent.UpdateFrinds)
	end
end

function FriendModel:UpdatePFriendOnlie(role_id, is_online)
	if self.all[role_id] then
		self.all[role_id].is_online = is_online
	end
	if self.contact_list[role_id] then
		self.contact_list[role_id].is_online = is_online
	end
end

function FriendModel:RemoveFriend(role_id)
	self.friends[role_id] = nil
	self.all[role_id] = nil
end

function FriendModel:GetEnemyList()
	return self.enemylist
end

function FriendModel:RemoveBlack(role_id)
	self.blacklist[role_id] = nil
	self.all[role_id] = nil
end

function FriendModel:GetBlackList()
	return self.blacklist
end

function FriendModel:SetContactList(contact_list)
    self.contact = contact_list
	self.contact_list = {}
	for i=1, #contact_list do
		local friend = contact_list[i]
		self.contact_list[friend.base.id] = friend
	end
end

function FriendModel:GetContactList()
	return self.contact
end

function FriendModel:SetApplyList(apply_list)
    self.apply_list = self.apply_list or {}
	for i=1, #apply_list do
		local apply = apply_list[i]
		self.apply_list[apply.id] = apply
	end
end

function FriendModel:GetApplyList()
	return self.apply_list
end

function FriendModel:RemoveFromApplyList(role_id)
	self.apply_list[role_id] = nil
end

function FriendModel:GetOnlineNum(FriendList)
	local num, total_num = 0, 0
	for _, friend in pairs(FriendList) do
		if friend.is_online then
			num = num + 1
		end
		total_num = total_num + 1
	end
	return num, total_num
end

--增加好友管理点击的
function FriendModel:AddManageRole(role_id)
	self.manage_roles[role_id] = 1
end
--删除好友管理点击的
function FriendModel:RemoveManageRole(role_id)
	self.manage_roles[role_id] = nil
end

function FriendModel:GetManageRoles()
	return self.manage_roles
end


--添加私聊消息
function FriendModel:AddMessage(message)
	local main_role_id = RoleInfoModel:GetInstance():GetMainRoleId()
	local role = message.sender
	self:UpdateFriendBase(role)
	local role_id = role.id
	--自己发送的消息
	local save_role_id
	if role_id == main_role_id then
		save_role_id = message.to_role_id
	else
		save_role_id = role_id
	end
	self.messages[main_role_id] = self.messages[main_role_id] or {}
	self.messages[main_role_id][save_role_id] = self.messages[main_role_id][save_role_id] or {}
	tableInsert(self.messages[main_role_id][save_role_id], message)
	if #self.messages[main_role_id][save_role_id] > 10 then
		table.remove(self.messages[main_role_id][save_role_id], 1)
	end

	CacheManager:GetInstance():SetString("chat_message", json.encode(self.messages))
end

--获取私聊消息
function FriendModel:GetMessages(role_id)
	local main_role_id = RoleInfoModel:GetInstance():GetMainRoleId()
	local messages = self.messages[main_role_id] or {}
	return messages[role_id] or {}
end

--更新已读状态
function FriendModel:UpdateReadMessage(message)
	message.is_read = true
	CacheManager:GetInstance():SetString("chat_message", json.encode(self.messages))
end

--获取有未读信息的角色id
function FriendModel:GetUnReadMessagesRoleId()
	local main_role_id = RoleInfoModel:GetInstance():GetMainRoleId()
	local messages = self.messages[main_role_id] or {}
	for role_id, arr_message in pairs(messages) do
		for i=1, #arr_message do
			if not arr_message[i].is_read then
				return role_id
			end
		end
	end
	return ""
end

function FriendModel:ClearMessages()
	local main_role_id = RoleInfoModel:GetInstance():GetMainRoleId()
	local messages = self.messages[main_role_id] or {}
	for role_id, _ in pairs(messages) do
		if not self.contact_list[role_id] then
			messages[role_id] = nil
		end
	end
end

--是否在黑名单
function FriendModel:IsInBlack(role_id)
	if self.blacklist[role_id] then
		return true
	else
		return false 
	end
end

function FriendModel:UpdateContact(pfriend)
	if self.contact_list[pfriend.base.id] then
		local old_pfriend
		for i=1, #self.contact do
			if self.contact[i].base.id == pfriend.base.id then
				old_pfriend = table.remove(self.contact, i)
				break
			end
		end
		table.insert(self.contact, 1, old_pfriend)
	else
		table.insert(self.contact, 1, pfriend)
	end
	self.contact_list[pfriend.base.id] = pfriend
end


