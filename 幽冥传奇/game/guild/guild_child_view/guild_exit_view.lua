GuildExitView = GuildExitView or BaseClass(XuiBaseView)

function GuildExitView:__init()
	self.texture_path_list[1] = 'res/xui/guild.png'
	self.config_tab = {
		{"guild_ui_cfg", 10, {0}},
	}
	self:SetIsAnyClickClose(true)
	
end

function GuildExitView:__Delete()

end

function GuildExitView:ReleaseCallBack()

end

function GuildExitView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		--btn_close_window
		RichTextUtil.ParseRichText(self.node_t_list.rich_txt_content.node, Language.Guild.Exit_Desc,20, COLOR3B.OLIVE)
		XUI.AddClickEventListener(self.node_t_list.btn_colse.node, BindTool.Bind(self.CloseWindow, self))
		XUI.AddClickEventListener(self.node_t_list.btn_exit_tip.node, BindTool.Bind(self.ExitSociety, self))
	end
end

function GuildExitView:CloseWindow()
	self:Close()
end

function GuildExitView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function GuildExitView:ShowIndexCallBack(index)
	self:Flush(index)
end

function GuildExitView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function GuildExitView:OnFlush(param_t, index)
	
end

function GuildExitView:ExitSociety()
	GuildCtrl.LeaveGuild()
	ViewManager.Instance:Close(ViewName.Guild)
	self:Close()
end

-- function GuildExitView:OnClickCreateGuild()
-- 	local guild_name = self.node_t_list.edit_create_guild.node:getText()
-- 	if guild_name ~= nil and guild_name ~= "" then
-- 		GuildCtrl.CreateGuild(1, guild_name)
-- 	end
-- end