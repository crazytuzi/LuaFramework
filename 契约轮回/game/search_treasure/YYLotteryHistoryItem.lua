YYLotteryHistoryItem = YYLotteryHistoryItem or class("YYLotteryHistoryItem",BaseCloneItem)
local YYLotteryHistoryItem = YYLotteryHistoryItem

function YYLotteryHistoryItem:ctor(obj,parent_node,layer)
	YYLotteryHistoryItem.super.Load(self)
end

function YYLotteryHistoryItem:dctor()
	self.time_txt = nil
	self.record_txt = nil
end

function YYLotteryHistoryItem:LoadCallBack()
	self.nodes = {
		"bg", "bg2", "time", "record"
	}
	self:GetChildren(self.nodes)
	self.time_txt = GetText(self.time)
	self.record_txt = GetText(self.record)
	self:AddEvent()
end

function YYLotteryHistoryItem:AddEvent()
end

--data:p_searchtreasure_message_item
function YYLotteryHistoryItem:SetData(data, index)
	self.data = data
	self.index = index
	if self.is_loaded then
		self:UpdateView()
	end
end

function YYLotteryHistoryItem:UpdateView()
	local mod = self.index % 2
	if mod == 0 then
		SetVisible(self.bg, false)
		SetVisible(self.bg2, true)
	else
		SetVisible(self.bg, true)
		SetVisible(self.bg2, false)
	end
	local date = os.date("*t", self.data.time)
	self.time_txt.text = string.format("%02d:%02d:%02d", date.hour, date.min, date.sec)
	local item = Config.db_item[self.data.item_id]
	local item_name = ColorUtil.GetHtmlStr(item.color, item.name)
	self.record_txt.text = string.format("<color=#0e9017>%s</color> Total draws <color=#eb5901>%s</color>times and won grand prize[%s]×%s", self.data.name,self.data.count,item_name,self.data.num)
end