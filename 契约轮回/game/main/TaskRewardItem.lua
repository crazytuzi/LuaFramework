--
-- @Author: LaoY
-- @Date:   2018-12-06 11:43:31
--
TaskRewardItem = TaskRewardItem or class("TaskRewardItem",BaseCloneItem)
local TaskRewardItem = TaskRewardItem

function TaskRewardItem:ctor(obj,parent_node,layer)
	TaskRewardItem.super.Load(self)
end

function TaskRewardItem:dctor()
	if self.award_item then
		self.award_item:destroy()
		self.award_item = nil
	end
end

function TaskRewardItem:LoadCallBack()
	self.nodes = {
		"text_name",
	}
	self:GetChildren(self.nodes)
	self.text_name_component = self.text_name:GetComponent('Text')

	self.award_item = GoodsIconSettorTwo(self.transform)
	--self.award_item:SetPosition(-35,35)
	self:AddEvent()
end

function TaskRewardItem:AddEvent()
end

function TaskRewardItem:SetData(index,data)
	local config = Config.db_item[data[1]]
	local str = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(config.color),config.name)
	self.text_name_component.text = str

	local param = {}
	param["model"] = TaskModel:GetInstance()
	param["item_id"] = data[1]
	param["num"] = data[2]
	param["size"] = {x=70,y=70}
	self.award_item:SetIcon(param)
	--self.award_item:UpdateIconByItemIdClick(data[1],data[2],70)
end