YYLotteryRewardItem = YYLotteryRewardItem or class("YYLotteryRewardItem",BaseItem)
local YYLotteryRewardItem = YYLotteryRewardItem

function YYLotteryRewardItem:ctor(parent_node,layer)
	self.abName = "search_treasure"
	self.assetName = "YYLotteryRewardItem"
	self.layer = layer

	self.model = SearchTreasureModel:GetInstance()
	YYLotteryRewardItem.super.Load(self)
	self.events = {}
end

function YYLotteryRewardItem:dctor()
	if self.goodsitem then
		self.goodsitem:destroy()
		self.goodsitem = nil
	end
	self.Text_txt = nil
	GlobalEvent:RemoveTabListener(self.events)
	self.events = nil

	if self.reddot then
		self.reddot:destroy()
		self.reddot = nil
	end
end

function YYLotteryRewardItem:LoadCallBack()
	self.nodes = {
		"icon", "got", "Text", "touch"
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
	self.Text_txt = GetText(self.Text)
	self:UpdateView()
end

function YYLotteryRewardItem:AddEvent()

	local function call_back(target,x,y)
		local act_info = OperateModel:GetInstance():GetActInfo(self.model.act_id)
		local tasks = act_info.tasks
		local task = self:GetTaskByRewardId(tasks, self.data.id)
		if task then
			if task.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
				OperateController.GetInstance():Request1700004(self.model.act_id, self.data.id, self.data.level)
			elseif task.state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
				Notify.ShowText("Claimed")
			else 
				Notify.ShowText("Pending")
			end
		end
	end
	AddClickEvent(self.touch.gameObject,call_back)

	local function call_back()
		self:UpdateView()
	end
	self.events[#self.events+1] = GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD, call_back)
	self.events[#self.events+1] = GlobalEvent:AddListener(OperateEvent.DLIVER_YY_INFO, call_back)
end

--data:p_yy_reward
function YYLotteryRewardItem:SetData(data)
	self.data = data
	if self.is_loaded then
		self:UpdateView()
	end
end

function YYLotteryRewardItem:UpdateView()
	local act_info = OperateModel:GetInstance():GetActInfo(self.model.act_id)
	local tasks = act_info.tasks
	if not self.goodsitem then
		local reward = String2Table(self.data.reward)[1]
		local param = {}
		param["item_id"] = reward[1]
		param["num"] = reward[2]
		param["bind"] = reward[3]
		param["color_effect"] = 4
		param["effect_type"] = 2
		param["can_click"] = true
		self.goodsitem = GoodsIconSettorTwo(self.icon)
		self.goodsitem:SetIcon(param)
		self.Text_txt.text = self.data.name
	end
	local task = self:GetTaskByRewardId(tasks, self.data.id)
	if task and task.state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
		SetVisible(self.got, true)
		SetVisible(self.touch, false)
		self.goodsitem:SetIconGray()
		if self.reddot then
			self.reddot:destroy()
			self.reddot = nil
		end
	else
		SetVisible(self.got, false)
		self.goodsitem:SetIconNormal()
		if task and task.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
			if not self.reddot then
				self.reddot = RedDot(self.icon)
				SetLocalPosition(self.reddot.transform, 24, 22)
				SetVisible(self.reddot, true)
			end
			SetVisible(self.touch, true)
		else
			SetVisible(self.touch, false)
		end
	end
end

function YYLotteryRewardItem:GetTaskByRewardId(tasks, reward_id)
	for i=1, #tasks do
		if tasks[i].id == reward_id then
			return tasks[i]
		end
	end
end