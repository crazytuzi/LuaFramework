GuildNoteView = GuildNoteView or BaseClass(XuiBaseView)

function GuildNoteView:__init()
	self.texture_path_list[1] = 'res/xui/guild.png'
	self.config_tab = {
		{"charge_ui_cfg", 5, {0}},
	}
end

function GuildNoteView:__delete()
end

function GuildNoteView:ReleaseCallBack()
	
end

function GuildNoteView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		XUI.AddClickEventListener(self.node_t_list.layout_get_reward.node, BindTool.Bind1(self.OpenGuild, self))
	end
end

function GuildNoteView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function GuildNoteView:ShowIndexCallBack(index)
	self:Flush(index)
end

function GuildNoteView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function GuildNoteView:OnFlush(param_t, index)
	
end

function GuildNoteView:OpenGuild()
	ViewManager.Instance:Open(ViewName.Guild)
	self:Close()
end