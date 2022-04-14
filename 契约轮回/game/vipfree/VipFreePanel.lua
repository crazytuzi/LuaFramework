VipFreePanel = VipFreePanel or class("VipFreePanel",BasePanel)
local VipFreePanel = VipFreePanel

function VipFreePanel:ctor()
	self.abName = "vipfree"
	self.assetName = "VipFreePanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true
	self.panel_type = 1

	self.item_list = {}
	self.reward_list = {}
	self.items = {}
	self.model = VipFreeModel:GetInstance()
	self.goto_VipVFourPanel = false
	self.global_events = {}
end

function VipFreePanel:dctor()
end

function VipFreePanel:Open( )
	VipFreePanel.super.Open(self)
end

function VipFreePanel:LoadCallBack()
	self.nodes = {
		"btnclose","left_bg/left_model","left_bg/power_bg/power","left_bg/effect","left_bg/bg/charge_day",
		"right_top/proslider","right_top/anypay/ScrollView1/Viewport/Content1","right_top/anypay/button1",
		"right_top/anypay/rewardbutton","countdown","right_bottom/VipFreeRewardItem","right_top/anypay/got",
		"right_bottom/item1","right_bottom/item2","right_bottom/item3","right_top/VipFreeVipRewardItem",
		"right_top/anypay/button1/Text","right_top/vip_bg/daybg1","right_top/vip_bg2/daybg2",
		"right_top/vip_bg3/daybg3","right_top/vip_bg4/daybg4",
	}
	self:GetChildren(self.nodes)

	self.VipFreeRewardItem_go = self.VipFreeRewardItem.gameObject
	SetVisible(self.VipFreeRewardItem_go, false)
	self.VipFreeVipRewardItem_go = self.VipFreeVipRewardItem.gameObject
	SetVisible(self.VipFreeVipRewardItem_go, false)
	self.proslider = GetSlider(self.proslider)
	self.charge_day = GetText(self.charge_day)
	self.Text = GetText(self.Text)
	self.power = GetText(self.power)
	self.daybg1 = GetImage(self.daybg1)
	self.daybg2 = GetImage(self.daybg2)
	self.daybg3 = GetImage(self.daybg3)
	self.daybg4 = GetImage(self.daybg4)
	self.items[1] = self.item1
	self.items[2] = self.item2
	self.items[3] = self.item3

	self:AddEvent()
	self.ui_effect = UIEffect(self.effect, 10311)
	LayerManager:GetInstance():AddOrderIndexByCls(self,self.left_model.transform,nil,true,nil,nil,4)
end

function VipFreePanel:AddEvent()
	local function call_back(target,x,y)
		self:Close()
	end
	AddButtonEvent(self.btnclose.gameObject,call_back)

	local function call_back(target,x,y)
		if self.goto_VipVFourPanel then
			lua_panelMgr:GetPanelOrCreate(VipVFourPanel):Open()
		else
			GlobalEvent:Brocast(VipEvent.OpenVipPanel, 2)
		end
	end
	AddButtonEvent(self.button1.gameObject,call_back)

	local function call_back(target,x,y)
		local viplevel = RoleInfoModel:GetInstance():GetMainRoleVipLevel()
		if self.task1 and self.task1.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH and viplevel>=4 then
			OperateController.GetInstance():Request1700004(self.act_id1, self.task1.id, self.task1.level)
		end
		if self.task2 and self.task2.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
			OperateController.GetInstance():Request1700004(self.act_id1, self.task2.id, self.task2.level)
		end
	end
	AddButtonEvent(self.rewardbutton.gameObject,call_back)

	local function call_back(data)
		if data.act_id == self.act_id1 or data.act_id == self.act_id2 then
			self:ShowFirstReward()
		end
	end
	self.global_events[#self.global_events+1] = GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD, call_back)

	local function call_back(data)
		if data.id == self.act_id1 or data.id == self.act_id2 then
			self:ShowFirstReward()
			self:ShowRewards(true)
		end
	end
	self.global_events[#self.global_events+1] = GlobalEvent:AddListener(OperateEvent.DLIVER_YY_INFO, call_back)
	
	local function call_back()
		self:ShowFirstReward()
		self:ShowRewards(true)
	end
	self.role_buff_event_id = RoleInfoModel:GetInstance():GetMainRoleData():BindData("viplv", call_back)
end

function VipFreePanel:OpenCallBack()
	self:UpdateView()
end

function VipFreePanel:UpdateView( )
	self.act_id1 = OperateModel.GetInstance():GetActIdByType(self.model.first_type)
	self.act_id2 = OperateModel.GetInstance():GetActIdByType(self.model.charge_type)
	self:ShowPetModel()
	self:ShowFirstReward()
	self:ShowRewards()
end

function VipFreePanel:ShowPetModel()
	if not self.pet_model then
		local actconfig = OperateModel.GetInstance():GetConfig(self.act_id1)
		local reqs = String2Table(actconfig.reqs)
		local model_str = reqs[1][3]
		self.pet_model = UIModelCommonCamera(self.left_model, nil, "model_pet_" .. model_str)
		self.power.text = reqs[2][2]
		self:ShowTime()
	end
end

--每日首充奖励
function VipFreePanel:ShowFirstReward()
	local act_info = OperateModel.GetInstance():GetActInfo(self.act_id1)
	local rewardcfgs = OperateModel.GetInstance():GetRewardConfig(self.act_id1)
	local function check_vip(reqs, vip)
		for i=1, #reqs do
			local req = reqs[i]
			if req[1] == "vip" and req[2] >= vip then
				return true
			end
		end
		return false
	end
	local function check_opendays(reqs, opdays)
		for i=1, #reqs do
			local req = reqs[i]
			if req[1] == "opdays" and opdays >= req[2] and opdays <= req[3] then
				return true
			end
		end
		return false
	end
	local open_days = LoginModel.GetInstance():GetOpenTime()
	local reward_id1, reward_id2 = 0, 0
	local rewards, rewards2 = {}, {}
	for _, v in pairs(rewardcfgs) do
		local reqs = String2Table(string.format("{%s}", v.reqs))
		if check_vip(reqs, 4) then
			if check_opendays(reqs, open_days) then
				table.insertto(rewards,  String2Table(v.reward), 1)
				reward_id1 = v.id
			end
		else
			if check_opendays(reqs, open_days) then
				table.insertto(rewards2, String2Table(v.reward), #rewards2+1)
				reward_id2 = v.id
			end
		end
	end
	local task1 = self:GetTaskByRewardId(act_info.tasks, reward_id1)
	local task2 = self:GetTaskByRewardId(act_info.tasks, reward_id2)
	self.task1 = task1
	self.task2 = task2
	if #self.item_list == 0 then
		for i=1, #rewards do
			local reward = rewards[i]
			local param = {}
			param["item_id"] = reward[1]
			param["num"] = reward[2]
			param["bind"] = reward[3]
			param["can_click"] = true
			param["color_effect"] = 4
			param["effect_type"] = 2
			local item = VipFreeVipRewardItem(self.VipFreeVipRewardItem_go, self.Content1)
			item:SetData(param, self.task1, self.act_id1, reward_id1, true)
			self.item_list[#self.item_list+1] = item
		end
		for i=1, #rewards2 do
			local reward = rewards2[i]
			local param = {}
			param["item_id"] = reward[1]
			param["num"] = reward[2]
			param["bind"] = reward[3]
			param["can_click"] = true
			param["color_effect"] = 4
			param["effect_type"] = 2
			local item = VipFreeVipRewardItem(self.VipFreeVipRewardItem_go, self.Content1)
			item:SetData(param, self.task2, self.act_id1, reward_id2, false)
			self.item_list[#self.item_list+1] = item
		end
	end
	self:ShowRedDot(false)
	self.Text.text = "Recharge"
	if self.task1 and self.task2 then
		local rewardcfg = OperateModel:GetInstance():GetRewardConfig(self.act_id1, self.task1.id)
		local reqs = (rewardcfg and rewardcfg.reqs or "{}")
		reqs = String2Table(string.format("{%s}", reqs))
		if self.task1.state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD 
		  and self.task2.state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
			SetVisible(self.got, true)
			SetVisible(self.button1, false)
			SetVisible(self.rewardbutton, false)
		elseif self.task1.state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE 
		  and self.task2.state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then 
			SetVisible(self.got, false)
			SetVisible(self.button1, true)
			SetVisible(self.rewardbutton, false)
		elseif self.task2.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH
		  or (self.task1.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH and self.model:CheckReqs(reqs)) then
		  	SetVisible(self.got, false)
			SetVisible(self.button1, false)
			SetVisible(self.rewardbutton, true)
			self:ShowRedDot(true)
		elseif self.task2.state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD and 
		  self.task1.state ~= enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
		  	SetVisible(self.got, false)
			SetVisible(self.button1, true)
			SetVisible(self.rewardbutton, false)
			self:ShowRedDot(false)
			self.Text.text = "VIP4 player can claim missed items"
			self.goto_VipVFourPanel = true
		else
			SetVisible(self.got, false)
			SetVisible(self.button1, true)
			SetVisible(self.rewardbutton, false)
		end
	else
		SetVisible(self.got, false)
		SetVisible(self.button1, true)
		SetVisible(self.rewardbutton, false)
	end
end

function VipFreePanel:ShowRedDot(flag)
	if not self.reddot then
		self.reddot = RedDot(self.rewardbutton)
		SetLocalPosition(self.reddot.transform, 55, 14)
	end
	SetVisible(self.reddot, flag)
end



--累充奖励
function VipFreePanel:ShowRewards(flag)
	local rewardcfgs = OperateModel.GetInstance():GetRewardConfig(self.act_id2)
	local act_info = OperateModel.GetInstance():GetActInfo(self.act_id2)
	if flag then
		if #self.reward_list > 0 then
			for i=1, #self.reward_list do
				self.reward_list[i]:destroy()
			end
			self.reward_list = {}
		end
	end
	if #self.reward_list == 0 then
		local viplevel = RoleInfoModel:GetInstance():GetMainRoleVipLevel()
		local mutex_ids = {}
		for _, v in pairs(rewardcfgs) do
			local task = self:GetTaskByRewardId(act_info.tasks, v.id)
			local reqs = String2Table(v.reqs)
			if task.state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
				mutex_ids[self.model:GetMutex(reqs)] = true
			end
		end

		local items = {}
		for _, v in pairs(rewardcfgs) do
			local task = self:GetTaskByRewardId(act_info.tasks, v.id)
			if task.state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
				items[#items + 1] = v
			else
				if not mutex_ids[v.id] then
					if viplevel>=4 then
						if string.find(v.reqs, "{vip,4}") then
							items[#items + 1] = v
						end
					else
						if not string.find(v.reqs, "{vip,4}") then
							items[#items + 1] = v
						end
					end
				end
			end
		end
		local function sort_items(a, b)
			return a.id < b.id
		end
		table.sort(items, sort_items)
		for i=1, #items do
			local item = VipFreeRewardItem(self.VipFreeRewardItem_go, self.items[i])
			item:SetData(items[i], self.act_id2)
			self.reward_list[#self.reward_list+1] = item
		end
	end
	local total_days = self:GetMaxDays(act_info.tasks)
	self.proslider.value = total_days
	self.charge_day.text = total_days
	SetGray(self.daybg1, total_days == 0)
	SetGray(self.daybg2, total_days < 3)
	SetGray(self.daybg3, total_days < 6)
	SetGray(self.daybg4, total_days < 11)
end

function VipFreePanel:GetMaxDays(tasks)
	if not tasks then
		return 0
	end
	local day = 0
	for i=1, #tasks do
		if tasks[i].count > day then
			day = tasks[i].count
		end
	end
	return day
end

function VipFreePanel:ShowTime()
	local act_info = OperateModel.GetInstance():GetAct(self.act_id1)
	if not self.countdown_item then
		local param = {}
		param["duration"] = 0.3
		param["isChineseType"] =  true
		param["isShowDay"] = true 
		param["isShowHour"] = true 
		self.countdown_item = CountDownText(self.countdown, param)
		local function end_func()
			self:Close()
		end
		self.countdown_item:StartSechudle(act_info.act_etime, end_func)
	end
end

function VipFreePanel:CloseCallBack(  )
	if self.pet_model then
		self.pet_model:destroy()
		self.pet_model = nil
	end
	if self.item_list then
		for i=1, #self.item_list do
			self.item_list[i]:destroy()
		end
		self.item_list = nil
	end
	if self.reward_list then
		for i=1, #self.reward_list do
			self.reward_list[i]:destroy()
		end
		self.reward_list = nil
	end
	if self.countdown_item then
		self.countdown_item:destroy()
		self.countdown_item = nil
	end
	self.items = nil
	self.task1 = nil
	self.task2 = nil

	GlobalEvent:RemoveTabListener(self.global_events)
	self.global_events = nil 
	if self.ui_effect then
		self.ui_effect:destroy()
		self.ui_effect = nil
	end
	if self.reddot then
		self.reddot:destroy()
		self.reddot = nil
	end
	if self.role_buff_event_id then
		RoleInfoModel:GetInstance():GetMainRoleData():RemoveListener(self.role_buff_event_id)
		self.role_buff_event_id = nil
	end
end

function VipFreePanel:GetTaskByRewardId(tasks, reward_id)
	for i=1, #tasks do
		if tasks[i].id == reward_id then
			return tasks[i]
		end
	end
	return nil
end