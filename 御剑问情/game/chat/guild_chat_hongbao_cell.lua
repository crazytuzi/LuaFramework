-------------------------------------------------公会红包列表------------------------------------------------
GuildChatHongBaoCell = GuildChatHongBaoCell or BaseClass(BaseCell)

function GuildChatHongBaoCell:__init()
	self:ListenEvent("OnClick",
		BindTool.Bind(self.OnClick, self))
	self.show_effect = self:FindVariable("ShowEffect")
	self.gray = self:FindVariable("Gray")
	self.boss_count = self:FindVariable("BossCount")
end

function GuildChatHongBaoCell:__delete()
	self.callback = nil
end

function GuildChatHongBaoCell:OnFlush()
	local has_get = GuildData.Instance:IsGetGuildHongBao(self.index)
	if GuildData.Instance:IsCanGetGuildHongBao(self.index) and not has_get then
		self.show_effect:SetValue(true)
	else
		self.show_effect:SetValue(false)
	end
	if has_get then
		self.gray:SetValue(true)
	else
		self.gray:SetValue(false)
	end
	local need_count = GuildData.Instance:GetGuildHongBaoKillCount(self.index) or 0
	self.boss_count:SetValue(need_count)
end

function GuildChatHongBaoCell:ListenClick(callback)
	self.callback = callback
end

function GuildChatHongBaoCell:OnClick()
	if self.callback then
		self.callback(self.index)
	end
end