MailData = MailData or BaseClass()

--邮件事件类型
-- MailEventType = {
-- 	mailRecvFlower = 1,				--// 接收鲜花
-- 	mailRebackRedPacket = 2,		--// 返还红包
-- 	mailActorKilled = 3,			--// 死亡记录
-- 	mailGuildFunds = 4,				--// 行会资金
-- 	mailServiceActivity = 5,		--// 全服活动或公告
-- }
function MailData:__init()
	if MailData.Instance then
		ErrorLog("[MailData] attempt to create singleton twice!")
		return
	end
	MailData.Instance = self
	self.mail_list = {}
	self.mail_id = nil 
	self.key = 0
end

function MailData:__delete()
end

function MailData:GetAllMail(protocol)
	if protocol.packet_idx == 0 then
		self.mail_list = {}
	end

	for k,v in pairs(protocol.mail_tab) do
		v.reward_id = bit:_and(v.reward_item, 0xffff)
		v.reward_num = bit:_rshift(v.reward_item, 16)
		v.tab = {}
		if v.mail_type == 5 then
			v.mail_content_spare = v.mail_content_spare
		else
			v.tab = Split(v.mail_content_spare, ";")
			for k1, v1 in pairs(v.tab) do
				local t = Split(v1, ",")
				v.tab[k1] = {item_type = tonumber(t[1]), id = tonumber(t[2]), count = tonumber(t[3]), is_bind = tonumber(t[4]) or 1}
			end
		end
	end

	local mail_tab = protocol.mail_tab

	for k,v in pairs(mail_tab) do
		table.insert(self.mail_list, 1, v)
	end
end

function MailData:AddMail(protocol)
	local onemail_info = {}
	onemail_info.mail_id = protocol.mail_id 
	onemail_info.mail_type = protocol.mail_type 
	onemail_info.reward_type = protocol.reward_type
	onemail_info.is_read = protocol.is_read
	onemail_info.is_get_reward = protocol.is_get_reward 
	onemail_info.sender_id = protocol.sender_id 
	onemail_info.title = protocol.title
	onemail_info.reward_item = protocol.reward_item
	onemail_info.reward_id = bit:_and(protocol.reward_item, 0xffff)
	onemail_info.reward_num = bit:_rshift(protocol.reward_item, 16)
	onemail_info.send_time = protocol.send_time
	onemail_info.tab = {}
	if onemail_info.mail_type == 5 then
		onemail_info.mail_content_index = protocol.mail_content_index
	elseif onemail_info.mail_type == MailEventType.mailNewCrossRetBagItem then
		onemail_info.item_data = protocol.item_data
	else
		onemail_info.mail_content_spare = protocol.mail_content_spare
		onemail_info.tab = Split(protocol.mail_content_spare, ";")
		for k, v in pairs(onemail_info.tab) do
			local t = Split(v, ",")
			onemail_info.tab[k] = {item_type = tonumber(t[1]), id = tonumber(t[2]), count = tonumber(t[3]), is_bind = tonumber(t[4]) or 1}
		end
	end
	onemail_info.content_desc = protocol.content_desc
	table.insert(self.mail_list, 1, onemail_info)	--新来的在前面
	for k,v in pairs(self.mail_list) do
		if #self.mail_list > 100 then --每次显示100封
			table.remove(self.mail_list, #self.mail_list)
		end
	end
end

function MailData:DeleteMail(protocol)
	for k,v in pairs(self.mail_list) do
		if v.mail_id == protocol.mail_id then
			table.remove(self.mail_list, k)
			break
		end
	end
end

function MailData:ReadMail(protocol)
	for k,v in pairs(self.mail_list) do
		if v.mail_id == protocol.mail_id then
			v.is_read = 1
		end
	end
end

function MailData:GetRewardMail(protocol)
	for k,v in pairs(self.mail_list) do
	 	if v.mail_id == protocol.mail_id then
	 		v.is_get_reward = 1
	 	end
	end 
end

function MailData:GetAllRewardMail(protocol)
	for k,v in pairs(self.mail_list) do
		for k1, v1 in pairs(protocol.mail_item_list) do
			if v.mail_id == v1.mail_id then
				v.is_read = v1.is_read
				v.is_get_reward = v1.is_get_reward
				v.num = 0
			end
		end
	end
end

function MailData:GetMailContent()
	local mail_list = TableCopy(self.mail_list)
	table.sort(mail_list, function(a, b)
		if a.is_read < b.is_read then
			return true
		elseif a.is_read == b.is_read then
			if a.send_time > b.send_time then return true end
		end
		return false
	end)

	return mail_list
end

function MailData:GetMailRemindNum()
	local remind_num = 0
	for k,v in pairs(self.mail_list) do
		if v.is_read == 0 or 
			(v.mail_type ~= MailEventType.mailActorKilled 
			and v.mail_type ~= MailEventType.mailGuildFunds
			and v.mail_type ~= MailEventType.mailPayNotice
			and v.mail_type ~= MailEventType.mailServiceActivity 
			and #v.tab > 0 
			and v.is_get_reward == 0) then
			remind_num = remind_num + 1
		end
	end

	return remind_num
end
