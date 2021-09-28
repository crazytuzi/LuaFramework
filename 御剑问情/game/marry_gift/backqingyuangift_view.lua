BackQingYuanGiftView = BackQingYuanGiftView or BaseClass(BaseView)

function BackQingYuanGiftView:__init()
	self.ui_config = {"uis/views/marrygiftview_prefab", "BackQingYuanGift"}
	self.full_screen = false
	self.play_audio = true
	self.role_infotable = {}
end

function BackQingYuanGiftView:__delete()

end

function BackQingYuanGiftView:LoadCallBack()
	self:ListenEvent("close_view", BindTool.Bind(self.CloseView,self))
	self:ListenEvent("chosen_chat", BindTool.Bind(self.ChosenChat,self))
	self:ListenEvent("chosen_qingyuan", BindTool.Bind(self.ChosenBackQingYuan,self))
	self.backFlowersInfo = self:FindVariable("BackQingYuanInfos")

end

function BackQingYuanGiftView:ReleaseCallBack()
	self.backFlowersInfo = nil
end

function BackQingYuanGiftView:OpenCallBack()
	self:Flush()
end

function BackQingYuanGiftView:CloseCallBack()
end

function BackQingYuanGiftView:OnFlush()
	local info = MarryGiftData.Instance:GetGiftRemindInfo()
	local cfg = MarryGiftData.Instance:GetMarryGiftSeqCfg(info.buy_seq, info.openserver_day)
	if cfg then
		self.backFlowersInfo:SetValue(cfg.client_des)
	end
end

function BackQingYuanGiftView:CloseView()
	self:Close()
end

function BackQingYuanGiftView:ChosenChat()
	if not ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.SINGLE) then
		return
	end
	local private_obj = {}
	if nil == ChatData.Instance:GetPrivateObjByRoleId(self.role_infotable.role_id) then
			private_obj = ChatData.CreatePrivateObj()
			private_obj.role_id = self.role_infotable.role_id
			private_obj.username = self.role_infotable.role_name
			private_obj.sex = self.role_infotable.sex
			private_obj.camp = self.role_infotable.camp
			private_obj.prof = self.role_infotable.prof
			private_obj.avatar_key_small = self.role_infotable.avatar_key_small
			private_obj.level = self.role_infotable.level
			ChatData.Instance:AddPrivateObj(private_obj.role_id, private_obj)
	end
	ChatData.Instance:SetCurrentId(self.role_infotable.role_id)

	if ViewManager.Instance:IsOpen(ViewName.ChatGuild) then
		ViewManager.Instance:FlushView(ViewName.ChatGuild, "new_chat", {CHANNEL_TYPE.PRIVATE, self.role_infotable.role_id})
	else
		ViewManager.Instance:Open(ViewName.ChatGuild)
	end

	self:Close()
end

function BackQingYuanGiftView:SetRoleInfotable(info)
	self.role_infotable.role_id = info.role_id
	self.role_infotable.role_name = info.role_name
	self.role_infotable.sex = info.sex
	self.role_infotable.camp = info.camp
	self.role_infotable.prof = info.prof
	self.role_infotable.avatar_key_small = info.avatar_key_small
	self.role_infotable.avatar_key_big = info.avatar_key_big
	self.role_infotable.level = info.level
	self:Flush()
end

function BackQingYuanGiftView:OnTipsClick()

 end

function BackQingYuanGiftView:ChosenBackQingYuan()
	ViewManager.Instance:Open(ViewName.MarryGift)
	self:Close()
end
