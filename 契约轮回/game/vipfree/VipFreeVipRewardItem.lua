VipFreeVipRewardItem = VipFreeVipRewardItem or class("VipFreeVipRewardItem",BaseCloneItem)
local VipFreeVipRewardItem = VipFreeVipRewardItem

function VipFreeVipRewardItem:ctor(obj,parent_node,layer)
	VipFreeVipRewardItem.super.Load(self)
end

function VipFreeVipRewardItem:dctor()
	if self.item then
		self.item:destroy()
		self.item = nil
	end
	if self.events then
		GlobalEvent:RemoveTabListener(self.events)
		self.events = nil
	end
end

function VipFreeVipRewardItem:LoadCallBack()
	self.nodes = {
		"icon", "got", "vipbg"
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
end

function VipFreeVipRewardItem:AddEvent()

	self.events = self.events or {}
	local function call_back(data)
		if self.act_id == data.act_id and data.id == self.rewardid then
			self.item:SetIconGray()
			SetVisible(self.got, true)
		end
	end
	self.events[#self.events+1] = GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD, call_back)
end

function VipFreeVipRewardItem:SetData(data, task, act_id, rewardid, show_v4)
	self.data = data
	self.task = task
	self.act_id = act_id
	self.show_v4 = show_v4
	self.rewardid = rewardid
	if self.is_loaded then
		self:UpdateView()
	end
end

function VipFreeVipRewardItem:UpdateView()
	if self.data then
		if not self.item then
			self.item = GoodsIconSettorTwo(self.icon)
		end
		self.item:SetIcon(self.data)
		SetVisible(self.vipbg, self.show_v4)
		if self.task and self.task.state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
			self.item:SetIconGray()
			SetVisible(self.got, true)
		else
			self.item:SetIconNormal()
			SetVisible(self.got, false)
		end
	end
end