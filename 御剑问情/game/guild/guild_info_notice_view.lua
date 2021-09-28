GuildInfoNoticeView = GuildInfoNoticeView or BaseClass(BaseView)

function GuildInfoNoticeView:__init()
	self.ui_config = {"uis/views/guildview_prefab","InfoNoticeWindow"}
	self.view_layer = UiLayer.Pop
end

function GuildInfoNoticeView:__delete()

end

function GuildInfoNoticeView:LoadCallBack()
	self:ListenEvent("OnClickClose",
		BindTool.Bind(self.Close, self))
	self:ListenEvent("OnNoticeChange",
		BindTool.Bind(self.OnNoticeChange, self))	

	self.input_field = self:FindObj("InputField"):GetComponent("InputField")	
end

function GuildInfoNoticeView:OpenCallBack()
	self:FlushNotice()
end

function GuildInfoNoticeView:ReleaseCallBack()
	self.input_field = nil
end

function GuildInfoNoticeView:CloseCallBack()

end

function GuildInfoNoticeView:OnFlush()

end

-- 更改公告
function GuildInfoNoticeView:OnNoticeChange()
	local notice = self.input_field.text
	if(notice == "") then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotEmptyContent)
		return
	end
	if ChatFilter.Instance:IsIllegal(notice, false) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.ContentUnlawful)
		return
	end
	GuildCtrl.Instance:SendGuildChangeNoticeReq(notice)
	GuildCtrl.Instance:SendGuildInfoReq()
end

--刷新公告面板
function GuildInfoNoticeView:FlushNotice()
	self.input_field.text = GuildDataConst.GUILDVO.guild_notice
end
