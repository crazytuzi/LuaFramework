require("game/guild/guild_info_invite_view")
GuildInfoOperationView = GuildInfoOperationView or BaseClass(BaseView)

function GuildInfoOperationView:__init()
	self.ui_config = {"uis/views/guildview_prefab","InfoOperationWindow"}
	self.view_layer = UiLayer.Pop
end

function GuildInfoOperationView:__delete()

end

function GuildInfoOperationView:LoadCallBack()
	self.invite_window = GuildInfoInviteView.New()

	self:ListenEvent("OnQuitGuild",
		BindTool.Bind(self.QuitGuild, self))
	self:ListenEvent("OnGuildCheckCanDelate",
		BindTool.Bind(self.SendGuildCheckCanDelate, self))
	self:ListenEvent("OpenInvite",
		BindTool.Bind(self.OpenInvite, self))
	self:ListenEvent("OnOpenApplyWindow",
		BindTool.Bind(self.OnOpenApplyWindow, self))
	self:ListenEvent("OnClickClose",
		BindTool.Bind(self.Close, self))

	self.variables = {}
	self.variables.show_invite_btn = self:FindVariable("ShowInviteBtn")
	self.variables.show_delate_btn = self:FindVariable("ShowDelateBtn")
	self.variables.exit_guild = self:FindVariable("ExitGuild")
	self.variables.red_point_apply = self:FindVariable("PointRedApply")
end

function GuildInfoOperationView:OpenCallBack()
	local post = GuildData.Instance:GetGuildPost()
	if GuildDataConst.GUILD_APPLYFOR_LIST.count > 0 and (post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG) then
		self.variables.red_point_apply:SetValue(true)
	else
		self.variables.red_point_apply:SetValue(false)
	end
	self:Flush()
end

function GuildInfoOperationView:ReleaseCallBack()
	if self.invite_window then
		self.invite_window:DeleteMe()
		self.invite_window = nil
	end
	self.variables.show_invite_btn = nil
	self.variables.show_delate_btn = nil
	self.variables.exit_guild = nil
	self.variables = nil
end

function GuildInfoOperationView:CloseCallBack()

end

function GuildInfoOperationView:OnFlush()
	local info = GuildData.Instance:GetGuildMemberInfo()
	if info then
		if info.post == GuildDataConst.GUILD_POST.TUANGZHANG then
			self.variables.exit_guild:SetValue(Language.Guild.JieSanXianMeng)
		else
			self.variables.exit_guild:SetValue(Language.Guild.TuiChuGuild)
		end
	end

	self.variables.show_delate_btn:SetValue(true)
	self.variables.show_invite_btn:SetValue(true)
	post = GuildData.Instance:GetGuildPost()
	if post == GuildDataConst.GUILD_POST.TUANGZHANG then
		self.variables.show_delate_btn:SetValue(false)
	elseif post ~= GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		self.variables.show_invite_btn:SetValue(false)
	end

	if GuildDataConst.GUILD_APPLYFOR_LIST.count > 0 and (post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG) then
		self.variables.red_point_apply:SetValue(true)
	else
		self.variables.red_point_apply:SetValue(false)
	end

end

-- 打开操作面板
function GuildInfoOperationView:QuitGuild()
	local describe = ""
	local yes_func = nil

	local post = GuildData.Instance:GetGuildPost()
	if post then
		if post == GuildDataConst.GUILD_POST.TUANGZHANG then
			yes_func = BindTool.Bind(self.SendQuitGuildReq, self, 1)
			describe = Language.Guild.ConfirmDismissGuildTip
		else
			yes_func = BindTool.Bind(self.SendQuitGuildReq, self, 0)
			describe = Language.Guild.QuitGuildTip
		end
	end

	TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
end

-- 请求退出公会 flag = 1 解散公会
function GuildInfoOperationView:SendQuitGuildReq(flag)
	if flag == 1 then
		local guild_id = GuildData.Instance.guild_id
		if guild_id then
			GuildCtrl.Instance:SendDismissGuildReq(guild_id)
		end
	else
		GuildCtrl.Instance:SendQuitGuildReq()
	end
end

-- 检查能否弹劾会长
function GuildInfoOperationView:SendGuildCheckCanDelate()
	local describe = Language.Guild.ConfirmTanHeMengZhuTip
	local yes_func = function() GuildCtrl.Instance:SendGuildCheckCanDelateReq() end
	local delete_id = GuildData.Instance:GetGuildDeleteId()
	if not delete_id then return end
	local number = ItemData.Instance:GetItemNumInBagById(delete_id)
	if number < 1 then
		local func = function(item_id, num, is_bind, is_tip_use) ExchangeCtrl.Instance:SendCSShopBuy(item_id, num, is_bind, is_tip_use, 0, 0) end
		TipsCtrl.Instance:ShowCommonBuyView(func, delete_id, nil, 1)
	else
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	end
end

--打开申请列表
function GuildInfoOperationView:OnOpenApplyWindow()
	ViewManager.Instance:Open(ViewName.GuildApply)
end

-------------------------------------------------------------------- 招人面板 -----------------------------------------------------------------------
function GuildInfoOperationView:OpenInvite()
	local post = GuildData.Instance:GetGuildPost()
	if post then
		if post ~= GuildDataConst.GUILD_POST.TUANGZHANG and post ~= GuildDataConst.GUILD_POST.FU_TUANGZHANG then
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoPower)
			return
		end
	end
	self.invite_window:Open()
end




