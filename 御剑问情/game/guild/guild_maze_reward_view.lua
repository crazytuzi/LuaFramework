GuildMazeRewardView = GuildMazeRewardView or BaseClass(BaseView)

function GuildMazeRewardView:__init()
	self.ui_config = {"uis/views/guildview_prefab","MazeRankRewardView"}
	self.view_layer = UiLayer.Pop
end

function GuildMazeRewardView:__delete()

end

function GuildMazeRewardView:LoadCallBack()
	self.item_panel_list = {}
	for i = 1, 3 do
		self.item_panel_list[i] = GuildMazeRewardCell.New(self:FindObj("ItemPanel" .. i))
		local cfg = GuildData.Instance:GetMazeRankCfgByRank(i)
		if cfg then
			local data = {}
			for k,v in pairs(cfg.reward_item) do
				table.insert(data, v)
			end
			self.item_panel_list[i]:SetData(data)
		end
	end
	self:ListenEvent("OnClickClose",
		BindTool.Bind(self.Close, self))
end

function GuildMazeRewardView:OpenCallBack()

end

function GuildMazeRewardView:ReleaseCallBack()
	for k,v in pairs(self.item_panel_list) do
		v:DeleteMe()
	end
	self.item_panel_list = {}
end

function GuildMazeRewardView:CloseCallBack()

end

function GuildMazeRewardView:OnFlush()

end

--------------------------------------GuildMazeRewardCell-----------------------------------------

GuildMazeRewardCell = GuildMazeRewardCell or BaseClass(BaseCell)

function GuildMazeRewardCell:__init()
	self.item_cell_list = {}
	for i = 1, 2 do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self:FindObj("ItemCell" .. i))
	end
end

function GuildMazeRewardCell:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function GuildMazeRewardCell:OnFlush()
	if self.data then
		for i = 1, 2 do
			self.item_cell_list[i]:SetParentActive(false)
			local data = self.data[i]
			if data then
				self.item_cell_list[i]:SetData(data)
				self.item_cell_list[i]:SetParentActive(true)
			end
		end
	end
end