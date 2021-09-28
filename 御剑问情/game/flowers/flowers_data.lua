FlowersData = FlowersData or BaseClass()

FLOWER_ID_LIST = {
	26903, 	--1朵玫瑰
	26904,	--99朵玫瑰
	26905,	--520朵玫瑰
	26906,	--999朵玫瑰
}

function FlowersData:__init()
	if FlowersData.Instance ~= nil then
		print_error("[FlowersData] Attemp to create a singleton twice !")
	end
	FlowersData.Instance = self

	self.friend_name = ""
	self.friend_iamge = nil
	self.flower_iamge =	nil

	self.is_buy = false
	self.is_not_tips = false
	self.from_uid_list = {}

	self.roleinfo = {}
	self.flowers_info = {}
	self.flowers_info.item_id = 26903
	self.flowers_info.target_uid = -1
	self.flowers_info.is_anonymity = 0
	self.flowers_info.is_marry = 0
	self.max_free_send_flower_times = ConfigManager.Instance:GetAutoConfig("friendgift_auto").other[1].free_song_hua_times or 0
	self.flower_play_state = false 				--是否在播放中

	self.use_free_times = 0
end

function FlowersData:__delete()
	FlowersData.Instance = nil
end

function  FlowersData:SetIsNotTips(is_not_tips)
	self.is_not_tips = is_not_tips
end

function FlowersData:GetIsTips()
	return nil == self.from_uid_list[self.flowers_info.from_uid]
end

function FlowersData:RegisterFromUid(from_uid)
	self.from_uid_list[from_uid] = from_uid
end

function FlowersData:UnRegisterFromUid(from_uid)
	self.from_uid_list[from_uid] = nil
end

function FlowersData:SetFreeFlowerTime(use_free_times)
	self.use_free_times = use_free_times
end

function FlowersData:GetFreeFlowerTime()
	return self.use_free_times
end

function  FlowersData:GetFriendName()
	return self.friend_name
end

function FlowersData:GetSendFlowerCfgFreeTime()
	return self.max_free_send_flower_times
end

function FlowersData:GetFlowerName()
	return self.flower_name
end

function FlowersData:ClearFlowerId()
	self.flowers_info.item_id = 26903
	self.flowers_info.target_uid = -1
end

function FlowersData:SetFlowersNum(flowersnum)
	self.flowers_info.flower_num1 = flowersnum.flower_num1
	self.flowers_info.flower_num2 = flowersnum.flower_num2
	self.flowers_info.flower_num3 = flowersnum.flower_num3
	self.flowers_info.flower_num4 = flowersnum.flower_num4
end

function FlowersData:OnGiveFlower(infotable)
	self.flowers_info.target_uid = infotable.target_uid
	self.flowers_info.from_uid = infotable.from_uid
	self.flowers_info.flower_num = infotable.flower_num
	self.flowers_info.is_anonymity = infotable.is_anonymity
	self.flowers_info.target_name = infotable.target_name
	self.flowers_info.from_name = infotable.from_name
	self.flowers_info.item_id = infotable.item_id
	self.flowers_info.reserve = infotable.reserve
end

function FlowersData:GetFlowersInfo()
	return self.flowers_info
end

function FlowersData:GetFriendInfo()
	return self.friend_name,self.flowers_info.target_uid
end

function FlowersData:GetRoleInfo()
	return self.roleinfo
end

function FlowersData:GetFlowerInfo()
	local flower_num = ItemData.Instance:GetItemNumInBagById(self.flowers_info.item_id)
	return self.flower_name,self.flowers_info.item_id,flower_num
end

function FlowersData:SetFlowersInfo(info)
	self.flowers_info.grid_index = info.grid_index
	self.flowers_info.item_id = info.item_id
	self.flowers_info.target_uid = info.user_id
	self.flowers_info.is_anonymity = 0
	self.flowers_info.is_marry = 0
end

function FlowersData:SetFlowerId(item_id)
	self.flowers_info.item_id = item_id
	self.flower_name = ItemData.Instance:GetItemConfig(item_id).name
	self.flowers_info.grid_index = ItemData.Instance:GetItemIndex(item_id)
end

function FlowersData:SetFriendInfo(info)
	if info.user_id then
		self.flowers_info.target_uid = info.user_id
		self.friend_name = info.user_name
	else
		self.flowers_info.target_uid = info.role_id
		self.friend_name = info.role_name
	end
	self.roleinfo = info
end