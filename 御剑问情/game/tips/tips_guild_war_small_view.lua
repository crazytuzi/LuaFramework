TipsGuildWarSmallView = TipsGuildWarSmallView or BaseClass(BaseView)
function TipsGuildWarSmallView:__init()
    self.ui_config = {"uis/views/guildview_prefab", "GuildRewardSmallTips"}
	self.item_list = {}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
end

function TipsGuildWarSmallView:__delete()
	self.item_list = {}
end

function TipsGuildWarSmallView:LoadCallBack()
    --获取变量
	for i = 1, 3 do
		local item_obj = self:FindObj("Item"..i)
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(item_obj)
		self.item_list[i - 1] = {item_obj = item_obj, item_cell = item_cell}
	end

    self.show_gray = self:FindVariable("ShowGray")
    self.show_button = self:FindVariable("ShowButton")
    self.war_text = self:FindVariable("War_Text")

    self:ListenEvent("CloseView", BindTool.Bind(self.CloseView, self))
    self:ListenEvent("ClickReward", BindTool.Bind(self.ClickReward, self))
end

function TipsGuildWarSmallView:ReleaseCallBack()
	self.show_gray = nil
	self.show_button = nil
	self.war_text = nil

	for k,v in pairs(self.item_list) do
		v.item_cell:DeleteMe()
	end
	self.item_list = {}
end

function TipsGuildWarSmallView:CloseView()
    self:Close()
end

function TipsGuildWarSmallView:ClickReward()
	if self.ok_callback then
		self.ok_callback()
	end
	self:Close()
end

function TipsGuildWarSmallView:CloseCallBack()

end

function TipsGuildWarSmallView:OpenCallBack()
	self:Flush()
end

function TipsGuildWarSmallView:OnFlush()
	if self.data_list ~= nil then
		for k, v in pairs(self.item_list) do
			if self.data_list[k] then
				v.item_cell:SetData(self.data_list[k])
				v.item_obj:SetActive(true)
			else
				v.item_obj:SetActive(false)
			end
		end

		self.show_button:SetValue(self.show_button_value == true)

		local guild_war_info = GuildFightData.Instance:GetGuildBattleDailyRewardFlag()
		if guild_war_info then
			self.show_gray:SetValue(guild_war_info.had_fetch == 1)
		end

		if self.top_title then
			self.war_text:SetValue(self.top_title)
		end
	end
end

function TipsGuildWarSmallView:SetData(items, show_gray, ok_callback, show_button, top_title_id)
	self.data_list = items
	self.show_gray_data = show_gray
	self.ok_callback = ok_callback
	self.show_button_value = show_button
	self.top_title = top_title_id
end
