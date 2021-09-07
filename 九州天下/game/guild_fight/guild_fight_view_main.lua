require("game/guild_fight/guild_fight_main_view")

GuildFightViewMain = GuildFightViewMain or BaseClass(BaseView)

function GuildFightViewMain:__init()
	self.ui_config = {"uis/views/guildfight","GuildFightViewMain"}
end

function GuildFightViewMain:__delete()

end

function GuildFightViewMain:LoadCallBack()
	self.main_panel = self:FindObj("MainPanel")
	self.main_view = GuildFightMainView.New(self.main_panel)
	self:Flush()
end

function GuildFightViewMain:ReleaseCallBack()
	if self.main_view then
		self.main_view:DeleteMe()
		self.main_view = nil
	end
end

function GuildFightViewMain:OpenCallBack()
	GuildFightCtrl.Instance:SendGBWinnerInfoReq()
end

function GuildFightViewMain:CloseMainView()
	self:Close()
end

function GuildFightViewMain:OnFlush()
	if self.main_view then
		self.main_view:Flush()
	end
end