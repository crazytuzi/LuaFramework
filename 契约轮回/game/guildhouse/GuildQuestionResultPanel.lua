GuildQuestionResultPanel = GuildQuestionResultPanel or class("GuildQuestionResultPanel",BasePanel)
local GuildQuestionResultPanel = GuildQuestionResultPanel

function GuildQuestionResultPanel:ctor()
	self.abName = "guild_house"
	self.assetName = "GuildQuestionResultPanel"
	self.layer = "Bottom"

	self.use_background = true
	self.change_scene_close = true
	self.click_bg_close = true

	self.model = GuildHouseModel:GetInstance()
	self.item_list = {}
end

function GuildQuestionResultPanel:dctor()
end

function GuildQuestionResultPanel:Open(data)
	GuildQuestionResultPanel.super.Open(self)
	self.data = data
end

function GuildQuestionResultPanel:LoadCallBack()
	self.nodes = {
		"rank", "score","ScrollView/Viewport/Content","end_item",
	}
	self:GetChildren(self.nodes)
	self.rank = GetText(self.rank)
	self.score = GetText(self.score)
	self:AddEvent()
end

function GuildQuestionResultPanel:AddEvent()

end

function GuildQuestionResultPanel:OpenCallBack()
	self:UpdateView()
end

function GuildQuestionResultPanel:UpdateView( )
	local data = {
		isClear = true,
		star = 7,
		IsCancelAutoSchedule = true
	}
	self.enditem = DungeonEndItem(self.end_item, data)
	self.enditem:ShowStars(true)
	self.enditem:StartAutoClose(5)
	local function closeCallBack()
		self:Close()
	end
	self.enditem:SetAutoCloseCallBack(closeCallBack)
	self.rank.text = self.data.rank
	self.score.text = self.data.score
	local rewards = self.model:GetRankReward(self.data.rank)
	if rewards then
		rewards = String2Table(rewards)
		for i=1, #rewards do
			local item = self.item_list[i] or GoodsIconSettorTwo(self.Content)
			local reward = rewards[i]
			local param = {
				item_id = reward[1],
				num = reward[2],
				can_click = true,
			}
			item:SetIcon(param)
			self.item_list[i] = item
		end
	end
end

function GuildQuestionResultPanel:CloseCallBack(  )
	if self.enditem then
		self.enditem:destroy()
	end
	for i=1, #self.item_list do
		self.item_list[i]:destroy()
	end
end