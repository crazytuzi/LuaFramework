YYLotteryHistoryPanel = YYLotteryHistoryPanel or class("YYLotteryHistoryPanel",WindowPanel)
local YYLotteryHistoryPanel = YYLotteryHistoryPanel

function YYLotteryHistoryPanel:ctor()
	self.abName = "search_treasure"
	self.assetName = "YYLotteryHistoryPanel"
	self.layer = "UI"
	
	self.panel_type = 3								--窗体样式  1 1280*720  2 850*545
	self.model = SearchTreasureModel:GetInstance()
	self.item_list = {}
	self.events = {}
end

function YYLotteryHistoryPanel:dctor()
	self.model:RemoveTabListener(self.events)
	self.events = nil
	for i=1, #self.item_list do
		self.item_list[i]:destroy()
	end
	self.item_list = nil
end

function YYLotteryHistoryPanel:Open( )
	YYLotteryHistoryPanel.super.Open(self)
end

function YYLotteryHistoryPanel:LoadCallBack()
	self.nodes = {
		"ScrollView/Viewport/Content","ScrollView/Viewport/Content/YYLotteryHistoryItem",
	}
	self:GetChildren(self.nodes)
	self.YYLotteryHistoryItem_gameobject = self.YYLotteryHistoryItem.gameObject
	self:AddEvent()

	SearchTreasureController:GetInstance():RequestGetRecords(self.model.act_id, 2)

	self:SetTileTextImage("search_treasure_image", "yylottery_history_title")
	self:SetPanelSize(700, 510)
	SetLocalPositionZ(self.transform, -165)
end

function YYLotteryHistoryPanel:AddEvent()
	local function call_back()
		self:UpdateView()
	end
	self.events[#self.events+1] = self.model:AddListener(SearchTreasureEvent.UpdateMessages, call_back)
end

function YYLotteryHistoryPanel:OpenCallBack()
	self:UpdateView()
end

function YYLotteryHistoryPanel:UpdateView( )
	local messages = self.model:GetMessages(self.model.act_id, 2)
	if messages then
		for i=1, #messages do
			local item = self.item_list[i] or YYLotteryHistoryItem(self.YYLotteryHistoryItem_gameobject, self.Content)
			item:SetData(messages[i], i)
			self.item_list[i] = item
		end
	end
end

function YYLotteryHistoryPanel:CloseCallBack(  )

end
function YYLotteryHistoryPanel:SwitchCallBack(index)
	if self.table_index == index then
		return
	end
	if self.child_node then
	 	self.child_node:SetVisible(false)
	end
	self.table_index = index
	--if self.table_index == 1 then
		-- if not self.show_panel then
		-- 	self.show_panel = ChildPanel(self.transform)
		-- end
		-- self:PopUpChild(self.show_panel)
	--end
end