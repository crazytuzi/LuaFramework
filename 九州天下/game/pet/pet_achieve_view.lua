PetAchieveView = PetAchieveView or BaseClass(BaseRender)

function PetAchieveView:__init(instance)
	PetAchieveView.Instance = self
	self:ListenEvent("one_click", BindTool.Bind(self.OnOneClick, self))
	self:ListenEvent("ten_click", BindTool.Bind(self.OnTenClick, self))
	self:ListenEvent("one_block_click", BindTool.Bind(self.OnOneBlockClick, self))
	self:ListenEvent("question_click", BindTool.Bind(self.OnQuestionClick, self))
	self:ListenEvent("mask_click", BindTool.Bind(self.CheckBoxClick, self))
	self.show_block = self:FindVariable("show_block")
	self.check_box = self:FindVariable("is_mask")
	self.one_time_gold = self:FindVariable("one_time_gold")
	self.ten_time_gold = self:FindVariable("ten_time_gold")
	self.countdown_text = self:FindVariable("countdown_text")
	self.show_timer = self:FindVariable("show_timer")
	self.turn_go = self:FindObj("turn_gameObject")
	self.one_btn = self:FindObj("one_btn")
	self.ten_btn = self:FindObj("ten_btn")
	self.go_btn = self:FindObj("go_btn")
	self.item_list = {}
	local items_cfg = PetData.Instance:GetChoujiangCfg()
	for i = 1, 8 do
		local handler = function()
			local close_call_back = function()
				self.item_list[i]:SetToggle(false)
				self.item_list[i]:ShowHighLight(false)
			end
			self.item_list[i]:SetToggle(true)
			self.item_list[i]:ShowHighLight(true)
			TipsCtrl.Instance:OpenItem(self.item_list[i]:GetData(), nil, nil, close_call_back)
		end
		self.item_list[i] = ItemCell.New(self:FindObj("item_" .. i))
		self.item_list[i]:ListenClick(handler)
		local data = items_cfg[i].reward_item
		self.item_list[i]:SetData(data)
	end
	self.model_right = self:FindObj("model_right")
	self.model_view_right = RoleModel.New()
	self.model_view_right:SetDisplay(self.model_right.ui3d_display)


	self.model_left = self:FindObj("model_left")
	self.model_view_left = RoleModel.New()
	self.model_view_left:SetDisplay(self.model_left.ui3d_display)
	self.cur_index = 0
	self.choujiang_type = 0
end

function PetAchieveView:SetRedPoint(is_show)
	self.show_timer:SetValue(is_show)
end

function PetAchieveView:__delete()
	if self.model_view_right ~= nil then
		self.model_view_right:DeleteMe()
		self.model_view_right = nil
	end
	if self.model_view_left ~= nil then
		self.model_view_left:DeleteMe()
		self.model_view_left = nil
	end
	GlobalTimerQuest:CancelQuest(self.timer_quest)
end

function PetAchieveView:OpenFreeTimer()
	local all_pet_info = PetData.Instance:GetAllInfoList()
	if all_pet_info.free_chou_timestamp ~= 0 then
		self.show_timer:SetValue(true)
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self:FlushTime()
	else
		self.show_timer:SetValue(false)
	end
end

function PetAchieveView:FlushTime()
	self.timer_quest = GlobalTimerQuest:AddRunQuest(function()
		local all_pet_info = PetData.Instance:GetAllInfoList()
		local free_chou_interval_h = PetData.Instance:GetOtherCfg()[1].free_chou_interval_h
		local can_chest_time = all_pet_info.free_chou_timestamp

		can_chest_time = can_chest_time + (free_chou_interval_h * 3600)
		local remain_time = can_chest_time - math.floor(TimeCtrl.Instance:GetServerTime())

		if remain_time < 0 then
			self.show_timer:SetValue(false)
			GlobalTimerQuest:CancelQuest(self.timer_quest)
		else
			local remain_hour = tostring(math.floor(remain_time / 3600))
			local remain_min = tostring(math.floor((remain_time - remain_hour * 3600) / 60))
			local remain_sec = ""
			if remain_time - remain_hour * 3600 - remain_min * 60 > 9 then
				remain_sec = tostring(math.floor(remain_time - remain_hour * 3600 - remain_min * 60))
			else
				remain_sec = "0" .. remain_sec
			end

			local show_time = remain_hour .. ":" .. remain_min .. ":" .. remain_sec
			self.countdown_text:SetValue(show_time .. Language.Pet.AfterFree)
		end
	end, 0)
end

function PetAchieveView:SetOneAndTenChouGold()
	local other_cfg = PetData.Instance:GetOtherCfg()
	self.one_time_gold:SetValue(other_cfg[1].one_chou_consume_gold)
	self.ten_time_gold:SetValue(other_cfg[1].ten_chou_consume_gold)
end

function PetAchieveView:FlushModel()
	local pet_data = PetData.Instance
	local res_id = pet_data:GetShowResId(pet_data:GetShowRandomZhenXiUseImgId())
	self.model_view_right:SetMainAsset(ResPath.GetMountModel(res_id))
	self.turn_go:SetLocalPosition(0, 0, 0)

	local res_id_left = pet_data:GetShowResId(pet_data:GetShowRandomZhenXiUseImgId())
	self.model_view_left:SetMainAsset(ResPath.GetMountModel(res_id_left))

	self:SetOneAndTenChouGold()
	PetData.Instance:SetIsMask(false)
	self.check_box:SetValue(false)
end

function PetAchieveView:OnReward()
	if self.choujiang_type == PET_CHOUJIANG_TYPE.ONE and not PetData.Instance:GetIsMask() then
		local pet_data = PetData.Instance
		local reward_list = pet_data:GetRewardList()[1]
		local reward_index = pet_data:GetRewardIndex(reward_list.item_id, reward_list.item_num)

		self.cur_index = (self.cur_index + reward_index)%8
		if self.cur_index == reward_index then
			self.cur_index = 0
		end
		self:ControllRotate(PetData.Instance:GetAngle(self.cur_index, reward_index))
	elseif self.choujiang_type == PET_CHOUJIANG_TYPE.TEN then
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_PET_10)
	end
end

function PetAchieveView:OnOneClick()
	local bag_empty_num = ItemData.Instance:GetEmptyNum()
	if bag_empty_num < 1 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
		return
	end

	self.show_block = true
	local is_mask = PetData.Instance:GetIsMask()
	local gold_num = GameVoManager.Instance:GetMainRoleVo().gold

	local other_cfg = PetData.Instance:GetOtherCfg()
	if not is_mask and gold_num >= other_cfg[1].one_chou_consume_gold then
		self.one_btn.button.interactable = false
		self.ten_btn.button.interactable = false
		self.go_btn.button.interactable = false
	end
	self.choujiang_type = PET_CHOUJIANG_TYPE.ONE
	PetCtrl.Instance:SendLittlePetREQ(LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_CHOUJIANG, 1, 0, 0)
end

function PetAchieveView:OnTenClick()
	local bag_empty_num = ItemData.Instance:GetEmptyNum()
	if bag_empty_num < 10 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
		return
	end

	self.show_block = true
	self.choujiang_type = PET_CHOUJIANG_TYPE.TEN
	PetCtrl.Instance:SendLittlePetREQ(LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_CHOUJIANG, 10, 0, 0)
end

function PetAchieveView:OnOneBlockClick()
	TipsCtrl.Instance:ShowSystemMsg("正在抽奖")
end

function PetAchieveView:OnQuestionClick()
	local tips_id = 92 -- 宠物获取帮助
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function PetAchieveView:ControllRotate(angle)
	local transform = self.turn_go.transform
	local position = transform.position
	local rotate_self = transform:DOLocalRotate(
		Vector3(0, 0, angle), 2, DG.Tweening.RotateMode.FastBeyond360)
	local sequence = DG.Tweening.DOTween.Sequence()
	sequence:Append(rotate_self)
	sequence:AppendCallback(function()
		self.show_block = false
		self.one_btn.button.interactable = true
		self.ten_btn.button.interactable = true
		self.go_btn.button.interactable = true
	end)
end

function PetAchieveView:CheckBoxClick()
	local is_mask = PetData.Instance:GetIsMask()
	PetData.Instance:SetIsMask(not is_mask)
	self.check_box:SetValue(not is_mask)
end