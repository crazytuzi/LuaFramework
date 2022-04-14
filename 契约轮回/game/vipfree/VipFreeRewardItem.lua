VipFreeRewardItem = VipFreeRewardItem or class("VipFreeRewardItem",BaseCloneItem)
local VipFreeRewardItem = VipFreeRewardItem

function VipFreeRewardItem:ctor(obj,parent_node,layer)
	VipFreeRewardItem.super.Load(self)
end

function VipFreeRewardItem:dctor()
	if self.item_list then
		for i=1, #self.item_list do
			self.item_list[i]:destroy()
		end
		self.item_list = nil
	end
	GlobalEvent:RemoveTabListener(self.global_events)
	self.global_events = nil
	if self.reddot then
		self.reddot:destroy()
		self.reddot = nil
	end
end

function VipFreeRewardItem:LoadCallBack()
	self.nodes = {
		"day","ScrollView/Viewport/Content", "paybutton", "rewardbutton", "got"
	}
	self:GetChildren(self.nodes)
	self.day = GetText(self.day)
	self.global_events = {}
	self:AddEvent()
	self.item_list = {}
end

function VipFreeRewardItem:AddEvent()
	local function call_back(target,x,y)
		GlobalEvent:Brocast(VipEvent.OpenVipPanel, 2)
	end
	AddButtonEvent(self.paybutton.gameObject,call_back)

	local function call_back(target,x,y)
		OperateController.GetInstance():Request1700004(self.act_id, self.data.id, self.data.level)
	end
	AddButtonEvent(self.rewardbutton.gameObject,call_back)

	local function call_back()
		self:UpdateButton()
	end
	self.global_events[#self.global_events+1] = GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD, call_back)
end

function VipFreeRewardItem:SetData(data, act_id)
	self.data = data
	self.act_id = act_id
	if self.is_loaded then
		self:UpdateView()
	end
end

function VipFreeRewardItem:UpdateView()
	if self.data then
		local rewards = String2Table(self.data.reward)
		for i=1, #rewards do
			local reward = rewards[i]
			local param = {}
			param["item_id"] = reward[1]
			param["num"] = reward[2]
			param["bind"] = reward[3]
			param["can_click"] = true
			param["color_effect"] = 4
			param["effect_type"] = 2
			local item = GoodsIconSettorTwo(self.Content)
			item:SetIcon(param)
			self.item_list[#self.item_list+1] = item
		end
		local task = String2Table(self.data.task)
		self.day.text = task[2]
		self:UpdateButton()
	end
end

function VipFreeRewardItem:UpdateButton()
	local task = self:GetTaskByRewardId(self.data.id)
	self:ShowRedDot(false)
	if task and task.state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
		SetVisible(self.got, true)
		SetVisible(self.paybutton, false)
		SetVisible(self.rewardbutton, false)
	else
		SetVisible(self.got, false)
		if task and task.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
			SetVisible(self.paybutton, false)
			SetVisible(self.rewardbutton, true)
			self:ShowRedDot(true)
		else
			SetVisible(self.paybutton, true)
			SetVisible(self.rewardbutton, false)
		end
	end
end

function VipFreeRewardItem:ShowRedDot(flag)
	if not self.reddot then
		self.reddot = RedDot(self.rewardbutton)
		SetLocalPosition(self.reddot.transform, 55, 14)
	end
	SetVisible(self.reddot, flag)
end

function VipFreeRewardItem:GetTaskByRewardId(reward_id)
	local act_info = OperateModel:GetInstance():GetActInfo(self.act_id)
	local tasks = act_info.tasks
	for i=1, #tasks do
		if tasks[i].id == reward_id then
			return tasks[i]
		end
	end
end