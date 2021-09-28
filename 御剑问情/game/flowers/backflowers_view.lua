BackFlowersView = BackFlowersView or BaseClass(BaseView)

function BackFlowersView:__init()
	self.ui_config = {"uis/views/flowersview_prefab","BackFlowers"}
	self.full_screen = false
	self.play_audio = true
	self.role_infotable = {}
end

function BackFlowersView:__delete()

end

function BackFlowersView:LoadCallBack()
	self:ListenEvent("close_view", BindTool.Bind(self.CloseView,self))
	self:ListenEvent("chosen_chat", BindTool.Bind(self.ChosenChat,self))
	self:ListenEvent("chosen_backflower", BindTool.Bind(self.ChosenBackFlower,self))
	--self:ListenEvent("tips_click", BindTool.Bind(self.OnTipsClick,self))

	self.backFlowersInfo = self:FindVariable("backFlowersInfo")

	--self.tips_toggle = self:FindObj("tips_toggle")
end

function BackFlowersView:ReleaseCallBack()
	self.backFlowersInfo = nil
	--self.tips_toggle = nil
end

function BackFlowersView:OpenCallBack()
	self:Flush()
end

function BackFlowersView:CloseCallBack()
end

function BackFlowersView:OnFlush()
	local color = "#ffff00"
	self.backFlowersInfo:SetValue(string.format(Language.Flower.ReceiveFlowerTxt,
		ToColorStr(self.target_name, color),ToColorStr(self.flower_name, color)))
end

function BackFlowersView:CloseView()
	self:Close()
end

function BackFlowersView:ChosenChat()
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

function BackFlowersView:SetRoleInfotable(info)
	self.role_infotable.role_id = info.role_id
	self.role_infotable.role_name = info.role_name
	self.role_infotable.sex = info.sex
	self.role_infotable.camp = info.camp
	self.role_infotable.prof = info.prof
	self.role_infotable.avatar_key_small = info.avatar_key_small
	self.role_infotable.avatar_key_big = info.avatar_key_big
	self.role_infotable.level = info.level
end

function BackFlowersView:OnTipsClick()
-- 	FlowersData.Instance:SetIsNotTips(self.tips_toggle.toggle.isOn)
-- 	if self.tips_toggle.toggle.isOn then
-- 		FlowersData.Instance:RegisterFromUid(self.from_uid)
-- 	else
-- 		FlowersData.Instance:UnRegisterFromUid(self.from_uid)
-- 	end
 end

function BackFlowersView:ChosenBackFlower()
	FlowersCtrl.Instance:SetFriendInfo(self.role_infotable)
	ViewManager.Instance:Open(ViewName.Flowers)
	self:Close()
end

function BackFlowersView:SetInfo(backflowersinfo)
	self.from_uid = backflowersinfo.from_uid
	self.target_name = backflowersinfo.from_name
	self.item_cfg = ItemData.Instance:GetItemConfig(backflowersinfo.item_id)

	self.flower_name = self.item_cfg.name
	self.flower_num = backflowersinfo.flower_num
end
