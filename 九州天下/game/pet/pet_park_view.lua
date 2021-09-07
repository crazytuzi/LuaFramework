PetParkView = PetParkView or BaseClass(BaseRender)

PET_PARK_STATE =
{
	MINE = 0,
	FRIEND = 1,
}

function PetParkView:__init(instance)
	PetParkView.Instance = self
	self.pet_list = {}
	self.pet_obj_list = {}
	local all_info_list = PetData.Instance:GetAllInfoList()
	for i = 1, 10 do
		self.pet_obj_list[i] = self:FindObj("pet_"..i)
		self.pet_list[i] = PetParkItem.New(self.pet_obj_list[i])
		self.pet_list[i]:SetPetInfo(all_info_list.pet_list[i])
		self.pet_list[i]:OnFlush()
		self.pet_list[i].time = 0
	end
	self:ListenEvent("check_pet_click", BindTool.Bind(self.CheckPetClick, self))
	self:ListenEvent("question_click", BindTool.Bind(self.QuestionClick, self))
	self:ListenEvent("check_youshan_click", BindTool.Bind(self.CheckYouShanClick, self))
	self:ListenEvent("check_friend_click", BindTool.Bind(self.CheckFriendClick, self))
	self:ListenEvent("back_btn_click", BindTool.Bind(self.BackBtnClick, self))
	self:ListenEvent("exchange_click", BindTool.Bind(self.ExchangeClick, self))
	self:ListenEvent("pet_bag_click", BindTool.Bind(self.PetBagClick, self))
	self.my_youshan_text = self:FindVariable("my_youshan_text")
	self.show_check_pet_btn = self:FindVariable("show_check_pet_btn")
	self.show_back_btn = self:FindVariable("show_back_btn")
	self.show_go_park_btn = self:FindVariable("show_go_park_btn")
	self.is_have_pet = self:FindVariable("is_have_pet")
	self.cur_exchang_num = self:FindVariable("cur_exchang_num")
	self.all_exchang_num = self:FindVariable("all_exchang_num")
	self.show_red_point = self:FindVariable("show_red_point")
	self.pet_timer_list = {}
	self.pet_target_pos_lsit = {}
	for i = 1, 10 do
		local pos = {x = 0, y = 0}
		self.pet_target_pos_lsit[i] = pos
		self:InitPetPosition(i)
	end
	self.pet_park_state = PET_PARK_STATE.MINE
	self.timer = 1
end

function PetParkView:InitPetPosition(i)
	if self.pet_obj_list[i]:GetActive() then
		local x = math.random(PET_RUN_RANGE.MIN.X, PET_RUN_RANGE.MAX.X)
		local y = math.random(PET_RUN_RANGE.MIN.Y, PET_RUN_RANGE.MAX.Y)
		self.pet_target_pos_lsit[i].x = x
		self.pet_target_pos_lsit[i].y = y
		self.pet_obj_list[i].rect:SetLocalPosition(x, y, 0)
		local angle = math.random(0,360)
		self.pet_list[i].pet_model.ui3d_display:SetRotation(Vector3(0, angle, 0))
		self.pet_list[i].model_view:SetInteger("Status", 0)  --idle
	end
end

function PetParkView:PetMove(i)
	local speed = 1
	local time = 0
	if self.pet_obj_list[i]:GetActive() then
		local timer = GlobalTimerQuest:AddRunQuest(function()

				local cur_pos_x = self.pet_obj_list[i].rect.localPosition.x
				local cur_pos_y = self.pet_obj_list[i].rect.localPosition.y

				if self.pet_target_pos_lsit[i].x == cur_pos_x and self.pet_target_pos_lsit[i].y == cur_pos_y then
					--到达目标点
					self.pet_list[i].angle = self:SetNextTagetPosAndAngle(i)
					self:SetPetIdle(i)
					self.pet_list[i].time = 0
				end

				--定时每秒执行
				self.timer = self.timer - UnityEngine.Time.deltaTime
				if self.timer < 0 then
					self.timer = 1
					self.pet_list[i].time = self.pet_list[i].time + 1

					if self.pet_list[i].time%5 == 0 then
						self:SetPetRun(i)
						self.pet_list[i].pet_model.ui3d_display:SetRotation(Vector3(0, self.pet_list[i].angle, 0))
					end
				end

				if self.pet_list[i].status_value == 1 then
					--移动到下一个点
					local next_x = cur_pos_x
					local next_y = cur_pos_y
					if cur_pos_x < self.pet_target_pos_lsit[i].x then
						next_x = next_x + speed
					elseif cur_pos_x > self.pet_target_pos_lsit[i].x then
						next_x = next_x - speed
					end
					if cur_pos_y < self.pet_target_pos_lsit[i].y then
						next_y = next_y + speed
					elseif cur_pos_y > self.pet_target_pos_lsit[i].y then
						next_y = next_y - speed
					end
					self.pet_obj_list[i].rect:SetLocalPosition(next_x, next_y, 0)
				end
			end, 0)
		self.pet_timer_list[i] = timer
	end
end

function PetParkView:SetNextTagetPosAndAngle(index)
	local x = math.random(PET_RUN_RANGE.MIN.X, PET_RUN_RANGE.MAX.X)
	local y = math.random(PET_RUN_RANGE.MIN.Y, PET_RUN_RANGE.MAX.Y)

	local dy, dx = y - self.pet_target_pos_lsit[index].y, x - self.pet_target_pos_lsit[index].x
	local angle = math.atan2(dy,dx)* 180 / math.pi
	self.pet_target_pos_lsit[index].x = x
	self.pet_target_pos_lsit[index].y = y
	if x > self.pet_target_pos_lsit[index].x then
		angle = 360 - angle
	else
		angle = -angle
	end
	return angle
end

function PetParkView:SetPetIdle(index)
	if self.pet_list[index].status_value ~= 0 then
		self.pet_list[index].status_value = 0   --idle
		self.pet_list[index].model_view:SetInteger("Status", self.pet_list[index].status_value)
	end
end
function PetParkView:SetPetRun(index)
	if self.pet_list[index].status_value ~= 1 then
		self.pet_list[index].status_value = 1	--run
		self.pet_list[index].model_view:SetInteger("Status", self.pet_list[index].status_value)
	end
end

function PetParkView:CancelPetMoveTimer()
	for k,v in pairs(self.pet_timer_list) do
		if v ~= nil then
			GlobalTimerQuest:CancelQuest(v)
			v = nil
		end
	end
end

function PetParkView:CancelPetMoveTimerByIndex(index)
	if self.pet_timer_list[index] ~= nil then
		GlobalTimerQuest:CancelQuest(self.pet_timer_list[index])
		self.pet_timer_list[index] = nil
	end
end

function PetParkView:OpenCallback()
	for i = 1, 10 do
		self:PetMove(i)
	end
	local all_pet_info = PetData.Instance:GetAllInfoList()
	self.show_red_point:SetValue( all_pet_info.score >= 30 and not PetData.Instance:GetIsOpenedExchange())
	self:FlushYouShanValue()
end

function PetParkView:FlushYouShanValue()
	local orther_cfg = PetData.Instance:GetOtherCfg()[1]
	local all_pet_info = PetData.Instance:GetAllInfoList()
	local you_shan_value = all_pet_info.score
	self.my_youshan_text:SetValue(you_shan_value)
	self.cur_exchang_num:SetValue(all_pet_info.interact_times)
	self.all_exchang_num:SetValue(orther_cfg.total_interact_count)
end

function PetParkView:CheckPetClick()
	if not self:JudgePetCount() then return end
	TipsCtrl.Instance:ShowPetAttributeView()
end

function PetParkView:JudgePetCount()
	if PetData.Instance:GetAllInfoList().pet_count == 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Pet.NoPet)
		return false
	end
	return true
end

function PetParkView:QuestionClick()
	local tips_id = 90 -- 宠物乐园帮助
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function PetParkView:CheckYouShanClick()
	-- local text_list = {}
	PetCtrl.Instance:SendLittlePetREQ(LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_INTERACT_LOG, 0, 0, 0)
	-- TipsCtrl.Instance:ShowPetYouShanView(text_list)
end

function PetParkView:CheckFriendClick()
	PetCtrl.Instance:SendLittlePetREQ(LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_PET_FRIEND_INFO, 0, 0, 0)
end

function PetParkView:BackBtnClick()
	self:GoMyPark()
end

function PetParkView:ExchangeClick()
	if not PetData.Instance:GetIsOpenedExchange() then
		PetData.Instance:SetIsOpenedExchange(true)
		self.show_red_point:SetValue(false)
	end
	TipsCtrl.Instance:ShowPetExchangeView()
end

function PetParkView:FlushFriendClick()
	ScoietyCtrl.Instance:ShowApplyView(APPLY_OPEN_TYPE.PET)
end

function PetParkView:FlushPet()
	self:CancelPetMoveTimer()
	local all_info_list = PetData.Instance:GetAllInfoList()
	for i = 1, 10 do
		self.pet_list[i]:SetPetInfo(all_info_list.pet_list[i])
		self.pet_list[i]:OnFlush()
		self:InitPetPosition(i)
		self:PetMove(i)
	end
end

function PetParkView:FlushPetByIndex(index)
	local all_info_list = PetData.Instance:GetAllInfoList()
	self.pet_list[index]:SetPetInfo(all_info_list.pet_list[index])
	self.pet_list[index]:OnFlush()
end

function PetParkView:FlushPetSliderByIndex(index)
	local all_info_list = PetData.Instance:GetAllInfoList()
	self.pet_list[index]:SetPetInfo(all_info_list.pet_list[index])
	self.pet_list[index]:OnFlushSlider()
	self.pet_list[index]:FLushPetStatus()
end

function PetParkView:GoFriendPark()
	self.pet_park_state = PET_PARK_STATE.FRIEND
	self.show_go_park_btn:SetValue(false)
	self.show_back_btn:SetValue(true)
	self.show_check_pet_btn:SetValue(false)
	local friend_pet_list_info = PetData.Instance:GetFriendPetListInfo()
	if friend_pet_list_info.count == 0 then
		friend_pet_list_info.pet_list = {}
	end

	self:CancelPetMoveTimer()
	for i=1,10 do
		self.pet_list[i]:SetPetInfo(friend_pet_list_info.pet_list[i])
		self.pet_list[i]:OnFlushFriend()

		self:InitPetPosition(i)
		self:PetMove(i)
	end

end

function PetParkView:GoMyPark()
	self.pet_park_state = PET_PARK_STATE.MINE
	self.show_go_park_btn:SetValue(true)
	self.show_back_btn:SetValue(false)
	self.show_check_pet_btn:SetValue(true)
	self:FlushPet()
end

function PetParkView:GetPetParkState()
	return self.pet_park_state
end

--点击宠物背包
function PetParkView:PetBagClick()
	TipsCtrl.Instance:OpenPetBag(SHOW_BAG_TYPE.PET_BAG)
end

------------------------------------------------------
PetParkItem = PetParkItem  or BaseClass(BaseCell)
local SHOW_CHAT_TIME = 2

function PetParkItem:__init()
	self.pet_slider = self:FindVariable("pet_slider")
	self.cur_value_text = self:FindVariable("cur_value_text")
	self.total_value_text = self:FindVariable("total_value_text")
	self.chat_text = self:FindVariable("chat_text")
	self.show_hu_dong = self:FindVariable("show_hu_dong")
	self.show_feed_value = self:FindVariable("show_feed_value")
	self.show_chat = self:FindVariable("show_chat")
	self.show_chat:SetValue(false)
	self.pet_name = self:FindVariable("pet_name")
	self.all_hu_dong_num = self:FindVariable("all_hu_dong_num")
	self.cur_hu_dong_num = self:FindVariable("cur_hu_dong_num")
	self.countdown_text = self:FindVariable("countdown_text")
	self.show_timer = self:FindVariable("show_timer")
	self.pet_info = nil
	self.pet_model = self:FindObj("pet_model")
	self.model_view = RoleModel.New()
	self.model_view:SetDisplay(self.pet_model.ui3d_display)
	self:ListenEvent("chat_click", BindTool.Bind(self.OnChatClick, self))
	self:ListenEvent("hu_dong_click", BindTool.Bind(self.OnHuDongClick, self))
	self:ListenEvent("block_click", BindTool.Bind(self.OnBlockClick, self))
	self.color = {
		[0] = "<color='#00ABFFFF'>%s</color>",
		[1] = "<color='#D100FFFF'>%s</color>",
		[2] = "<color='#FF8400FF'>%s</color>",
	}
	self.time = 0
	self.status_value = 0
	self.is_click = false
	self.is_stay_mine_part = true
	self.show_chat:SetValue(false)
	self.show_hu_dong:SetValue(false)
	self.angle = 0
	self.model_id = nil
	self.timer = 0
end

function PetParkItem:__delete()
	if nil ~= self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end
	
	self:CancelCalTime()
end

function PetParkItem:SetPetInfo(pet_info)
	self.root_node:SetActive(true)
	self.pet_info = pet_info
	if pet_info == nil then
		self.root_node:SetActive(false)
		return
	end
	local pet_id = pet_info.id or pet_info.pet_id
	local pet_cfg = PetData.Instance:GetSinglePetCfg(pet_id)
	self.model_id = pet_cfg.using_img_id
end

function PetParkItem:OnFlushSlider()
	local total_feed = PetData.Instance:GetSingleQuality(self.pet_info.id).max_feed_degree
	self.pet_slider:SetValue(self.pet_info.feed_degree/total_feed)
	self.cur_value_text:SetValue(self.pet_info.feed_degree)
	self.total_value_text:SetValue(total_feed)
end
function PetParkItem:FlushPetName()
	local pet_cfg =  PetData.Instance:GetSinglePetCfg(self.pet_info.id)
	local pet_name = string.format(self.color[pet_cfg.quality_type], self.pet_info.pet_name)
	self.pet_name:SetValue(pet_name)
end

function PetParkItem:FLushPetStatus()
	local total_feed = PetData.Instance:GetSingleQuality(self.pet_info.id).max_feed_degree
	if self.pet_info.feed_degree < total_feed then
		self.chat_text:SetValue(Language.Pet.GiveEat)
		-- self.show_timer:SetValue(false)
	else
		self.chat_text:SetValue(Language.Pet.HadFull)
		-- self.show_timer:SetValue(true)
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		-- self:FlushTime()
	end
end

function PetParkItem:OnFlush()
	self.is_stay_mine_part = true
	self.show_feed_value:SetValue(true)
	if self.pet_info == nil then
		return
	end
	self.show_hu_dong:SetValue(false)

	self:OnFlushSlider()

	self:FlushPetName()

	self:FLushPetStatus()

	self.model_view:SetMainAsset(ResPath.GetPetModel(self.model_id))
end

function PetParkItem:FlushTime()
	self.timer_quest = GlobalTimerQuest:AddRunQuest(function()
		if nil == self.pet_info then
			GlobalTimerQuest:CancelQuest(self.timer_quest)
			return
		end
		local feed_clear_interval_h = PetData.Instance:GetOtherCfg()[1].feed_clear_interval_h
		local can_chest_time = self.pet_info.baoshi_active_time

		can_chest_time = can_chest_time + (feed_clear_interval_h * 3600)
		local remain_time = can_chest_time - math.floor(TimeCtrl.Instance:GetServerTime())

		if remain_time < 0 then
			self.show_timer:SetValue(false)
			GlobalTimerQuest:CancelQuest(self.timer_quest)
		else
			local remain_hour = tostring(math.floor(remain_time / 3600))
			local remain_min = tostring(math.floor((remain_time - remain_hour * 3600) / 60))
			local remain_sec = tostring(math.floor(remain_time - remain_hour * 3600 - remain_min * 60))
			local show_time = remain_hour .. ":" .. remain_min .. ":" .. remain_sec
			self.countdown_text:SetValue(show_time)
		end
	end, 0)
end

function PetParkItem:CancelCalTime()
	GlobalTimerQuest:CancelQuest(self.timer_quest)
end

function PetParkItem:OnFlushFriend()
	self.is_stay_mine_part = false
	self.show_chat:SetValue(false)
	self.show_feed_value:SetValue(false)
	if self.pet_info == nil then
		return
	end
	self:CancelCalTime()
	self.show_timer:SetValue(false)

	local pet_cfg =  PetData.Instance:GetSinglePetCfg(self.pet_info.pet_id)
	local pet_name = string.format(self.color[pet_cfg.quality_type], self.pet_info.pet_name)
	self.pet_name:SetValue(pet_name)
	local orther_cfg = PetData.Instance:GetOtherCfg()[1]

	local interact_times = string.format("<color='#00FF02FF'>%s</color>",self.pet_info.interact_times)
	if self.pet_info.interact_times == orther_cfg.per_interact_count then
		self.show_hu_dong:SetValue(false)
		interact_times = string.format("<color='#FF0000FF'>%s</color>",self.pet_info.interact_times)
	end
	self.cur_hu_dong_num:SetValue(interact_times)
	self.all_hu_dong_num:SetValue(orther_cfg.per_interact_count)
	self.model_view:SetMainAsset(ResPath.GetPetModel(self.model_id))
end

function PetParkItem:OnChatClick()
	self.is_click = false
	local total_feed = PetData.Instance:GetSingleQuality(self.pet_info.id).max_feed_degree
	if self.pet_info.feed_degree >= total_feed then
		TipsCtrl.Instance:ShowSystemMsg(Language.Pet.TipsFull)
		return
	end
	if UnityEngine.PlayerPrefs.GetInt("pet_feed") == 1 then
		PetCtrl.Instance:SendLittlePetREQ(LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_FEED, self.pet_info.index, self.pet_info.info_type, 0)
	else
		local func = function()
			self.is_click = false
			PetCtrl.Instance:SendLittlePetREQ(LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_FEED, self.pet_info.index, self.pet_info.info_type, 0)
		end
		TipsCtrl.Instance:ShowCommonTip(func, nil, Language.Common.PetFeedTip, nil, nil, true, false,"pet_feed")
	end
end

function PetParkItem:OnHuDongClick()
	self.is_click = false
	PetCtrl.Instance:SendLittlePetREQ(LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_INTERACT, self.pet_info.index, PetData.Instance:GetFriendId(), self.pet_info.info_type)
end

function PetParkItem:OnBlockClick()
	self.timer = SHOW_CHAT_TIME
	if PetParkView.Instance:GetPetParkState() == PET_PARK_STATE.MINE then
		self.show_chat:SetValue(true)
	else
		self.show_hu_dong:SetValue(true)
	end
	if self.show_chat_quest then
		GlobalTimerQuest:CancelQuest(self.show_chat_quest)
		self.show_chat_quest = nil
	end
	self.show_chat_quest = GlobalTimerQuest:AddRunQuest(function()
		self.timer = self.timer - UnityEngine.Time.deltaTime
		if self.timer <= 0 then
			self.show_chat:SetValue(false)
			self.show_hu_dong:SetValue(false)
			GlobalTimerQuest:CancelQuest(self.show_chat_quest)
			self.show_chat_quest = nil
		end
	end, 0)
end


function PetParkItem:GetPetInfo()
	return self.pet_info
end