ZhenBaoGeData = ZhenBaoGeData or BaseClass()
State = {
	HasReceive = 0,    	--已领取，图标为灰色
	CanReceive  =1, 	--可领取，领取提示
	CanNotReceive = 2,  --不可领取
}
ZhenBaoGeData.SetDice = "set_dice"
ZhenBaoGeData.InfoChange = "info_change"
ZhenBaoGeData.LayerRewardChange = "layer_reward_change"
ZhenBaoGeData.ExchangeListUpdate = "exchange_list_update"
function ZhenBaoGeData:__init()
	if ZhenBaoGeData.Instance then
		ErrorLog("[ZhenBaoGeData] attempt to create singleton twice!")
		return
	end
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()
	ZhenBaoGeData.Instance = self
	self.zhen_bao_ge_info = {}         	--珍宝阁零散信息
	self.layer_reward_list = {}  		--层数奖励
	self.step_reward_list = nil 		--步数奖励
	self.remind_num = 0
	self.exchange_list_remind = 0
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.ZhenBaoGeReward)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetExchangeListRemindNum, self), RemindName.ZhenBaoGeExchange)
	GlobalEventSystem:Bind(OtherEventType.MAIN_ROLE_CIRCLE_CHANGE, BindTool.Bind(self.DoRemind, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.SetExchangeList, self))
end

function ZhenBaoGeData:DoRemind()
	RemindManager.Instance:DoRemind(RemindName.ZhenBaoGeReward)
	self:DispatchEvent(ZhenBaoGeData.LayerRewardChange)
end

function ZhenBaoGeData:SetZhenBaoGeInfo(protocol)
	
	--self.zhen_bao_ge_info.cur_step = protocol.step
	self.zhen_bao_ge_info.rest_time  = JewelPavilionConfig.freeCount - protocol.use_times  --剩余免费次数
	self.zhen_bao_ge_info.layer_step = JewelPavilionConfig.layerStep    					  --每一层的步数

	self.cur_step_reward_mark = protocol.step_reward                      --当前步数奖励领取标志

	self.layer_reward_list = {}
	for k,v in pairs(JewelPavilionConfig.layerAwards) do
		if type(v) == "table" then
			self.layer_reward_list[k] = {}
			self.layer_reward_list[k].need_step = v.needStep
			if type(v.awards) == "table" then
				self.layer_reward_list[k].awards = {}
				for k1,v1 in pairs(v.awards) do
					table.insert(self.layer_reward_list[k].awards, ItemData.FormatItemData(v1))
				end
			end
		end
	end

	self.step_reward_list  = {}
	for k,v in pairs(JewelPavilionConfig.Awards) do
		if type(v) == "table" then
			for k1,v1 in pairs(v) do
				table.insert(self.step_reward_list, ItemData.FormatItemData(v1))
			end
		end
	end

	--总步数
	self.zhen_bao_ge_info.setp_number = #self.step_reward_list
	--总层数
	self.zhen_bao_ge_info.layer_number = math.floor(( self.zhen_bao_ge_info.setp_number - 1) / self.zhen_bao_ge_info.layer_step) + 1
	--当前步数
	self:SetCurStep(protocol.step)

	if protocol.step >= self.zhen_bao_ge_info.setp_number then
		self.zhen_bao_ge_info.rest_time = 0
	end

	--层数奖励
	self.layer_reward_mark =  bit:d2b(protocol.layer_reward_mark)
	self:SetLayerRewardMark(self.layer_reward_mark)
	--兑换列表
	self:SetExchangeList()
end

function ZhenBaoGeData:SetCurStep(step)
	if step > self.zhen_bao_ge_info.setp_number then
		self.zhen_bao_ge_info.cur_step = self.zhen_bao_ge_info.setp_number
	elseif step < 0 then
		self.zhen_bao_ge_info.cur_step = 0
	else
		self.zhen_bao_ge_info.cur_step = step
	end
end

function ZhenBaoGeData:SetLayerRewardMark(data)
	self.remind_num = 0
	for k,v in pairs (self.layer_reward_list) do
		if data[33-k] == 1 then
			self.layer_reward_list[k].state  = State.HasReceive
		else
			if self.zhen_bao_ge_info.cur_step < v.need_step then
				self.layer_reward_list[k].state  = State.CanNotReceive
			else
				self.layer_reward_list[k].state  = State.CanReceive
				self.remind_num = self.remind_num + 1
			end
		end
	end

	if self.zhen_bao_ge_info.rest_time then
		self.remind_num = self.remind_num + self.zhen_bao_ge_info.rest_time
	end 

	RemindManager.Instance:DoRemind(RemindName.ZhenBaoGeReward)
	self:DispatchEvent(ZhenBaoGeData.LayerRewardChange)
end

function ZhenBaoGeData:GetRemindNum()
	return self.remind_num 
end

function ZhenBaoGeData:SetExchangeList()
	self.exchange_list_remind = 0
	local color_stone_value = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_COLOR_STONE)
	local dargon_value = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_DRAGON_SPITIT)
	self.exchange_list = {}
	local data_list = ItemSynthesisConfig[ITEM_SYNTHESIS_TYPES.COLOR_STONE].itemList
	for k,v in pairs (data_list)do
		self.exchange_list[k] = {}
		self.exchange_list[k].awards = {}
		for k1,v1 in pairs (v.award) do
			table.insert(self.exchange_list[k].awards, ItemData.FormatItemData(v1))
		end
		self.exchange_list[k].consume = {}
		for k1,v1 in pairs (v.consume) do
			table.insert(self.exchange_list[k].consume,v1)
		end
		if v.consume[1].type == tagAwardType.qatColorStone then
			if  v.consume[1].count <= color_stone_value then
				self.exchange_list[k].can_exchange = 1
				self.exchange_list_remind = self.exchange_list_remind + 1
			else
				self.exchange_list[k].can_exchange = 0
			end
		elseif v.consume[1].type == tagAwardType.qatDragonSpitit then
			if  v.consume[1].count <= dargon_value then
				self.exchange_list[k].can_exchange = 1
				self.exchange_list_remind = self.exchange_list_remind + 1
			else
				self.exchange_list[k].can_exchange = 0
			end
		else 
			self.exchange_list[k].can_exchange = 0
		end
	end
	RemindManager.Instance:DoRemind(RemindName.ZhenBaoGeExchange)
	self:DispatchEvent(ZhenBaoGeData.ExchangeListUpdate)
end

function ZhenBaoGeData:GetExchangeListRemindNum()
	return self.exchange_list_remind
end

function ZhenBaoGeData:GetExchangeList()
	return self.exchange_list
end

function ZhenBaoGeData:GetLayerRewardList()
	return self.layer_reward_list
end

function ZhenBaoGeData:GetLayerRewardList()
	return self.layer_reward_list
end

function ZhenBaoGeData:GetStepRewardList()
	return self.step_reward_list
end

function ZhenBaoGeData:GetZhenBaoGeData()
	return self.zhen_bao_ge_info
end

function ZhenBaoGeData:SetDiceResult(protocol)
	self:SetCurStep(protocol.step)
	self.zhen_bao_ge_info.dice_number = protocol.dice_number 
	self.zhen_bao_ge_info.cur_step_reward_mark = protocol.step_reward
	self.zhen_bao_ge_info.rest_time = JewelPavilionConfig.freeCount - protocol.use_times  --剩余免费次数
	self:DispatchEvent(ZhenBaoGeData.SetDice)
end

function ZhenBaoGeData:SetStepRewardResult(protocol)
	self:DispatchEvent(ZhenBaoGeData.InfoChange)
	self:SetLayerRewardMark(self.layer_reward_mark)
	local item_id  = self.step_reward_list[self.zhen_bao_ge_info.cur_step].item_id
	ZhenBaoGeCtrl.Instance:StartFlyItem(item_id)
end

function ZhenBaoGeData:SetLayerRewardResult(protocol)
	self.layer_reward_mark  = bit:d2b(protocol.layer_result)
	self:SetLayerRewardMark(self.layer_reward_mark)
end
