FeedbackView = FeedbackView or BaseClass(XuiBaseView)

CHAT_FONT_SIZE = 20

FeedbackViewIndex = {
	All = 1,
	Near =2,
	World = 3,
	Guild = 4,
	Team = 5,
	Private = 6,
}

function FeedbackView:__init()
	-- self:SetModal(true)
	self.def_index = 1
	self.last_view = 1

	self.texture_path_list[1] = "res/xui/feedback.png"
	self.title_img_path = ResPath.GetFeedBack("img_title")
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"feedback_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
	}
	self.root_node_off_pos = {x = -57.5, y = 0}
	self.real_content_text = ""
end

function FeedbackView:__delete()
	self.real_content_text = ""
end

function FeedbackView:LoadCallBack(index, loaded_times)
	self.node_t_list.edit_feedback_qus.node:setPlaceHolder(Language.Feedback.DefTexts[1])
	if loaded_times <= 1 then
		self.node_t_list.edit_feedback_qus.node:setFontSize(20)
		self.node_t_list.edit_feedback_qus.node:setFontColor(COLOR3B.OLIVE)
		self.node_t_list.edit_feedback_qus.node:registerScriptEditBoxHandler(BindTool.Bind(self.ExamineQuesEditTextNum, self, self.node_t_list.edit_feedback_qus.node, 60))
		-- self.node_t_list.btn_feedback_type_chose.node:setVisible(false)
		self.content_text_node = self.node_t_list.txt_feedback_content.node
		
		XUI.AddClickEventListener(self.node_t_list.btn_feedback_send.node, BindTool.Bind(self.SendFeedbackClick, self))
		local role_vo =  GameVoManager.Instance:GetMainRoleVo()
		local role_name = role_vo and role_vo.name or ""
		local id = AgentAdapter:GetSpid()

		local txt = "" 
		local qq = self:GetPlatQQ(id)
		if qq then
			txt = string.format(Language.Feedback.ConcatTipFormat,qq)
		end	
		
		local content = string.format(Language.Feedback.Tip, role_name, txt)
		RichTextUtil.ParseRichText(self.node_t_list.rich_feedback_tip.node, content)
		self:CreateEditBox()
	end
end

function FeedbackView:GetPlatQQ(spid)
	for _,v in pairs(ClientFeedbackCfg) do
		local plats = v[1]
		for _,v2 in pairs(plats) do
			if spid == v2 then
				return v[2]
			end	
		end	
	end	
	return nil
end	

function FeedbackView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()

end

function FeedbackView:ShowIndexCallBack(index)

end

function FeedbackView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.real_content_text = ""
	if self.content_text_node then
		self.content_text_node:setString("")
		self.node_t_list.edit_feedback_qus.node:setText("")
		self.node_t_list.img_input_tip.node:setVisible(self.real_content_text == "")
	end
end

function FeedbackView:ReleaseCallBack()
	self.real_content_text = ""
	if self.content_edit then
		self.content_edit:removeFromParent()
		self.content_edit = nil
	end
end

function FeedbackView:OnCloseHandler()
	ViewManager.Instance:Close(ViewName.Setting)
	self:Close()
end

function FeedbackView:OnFlush(param_list, index)
	self.node_t_list.img_input_tip.node:setVisible(self.real_content_text == "")
	-- for k,v in pairs(param_list) do

	-- end
end

function FeedbackView:CreateEditBox()
	if self.content_edit ~= nil then return end

	local bg_path = ResPath.GetCommon("img9_transparent")
	local ph = self.ph_list.ph_edit_content
	self.content_edit = XUI.CreateEditBox(ph.x, ph.y, ph.w, ph.h, nil, 0, 3, bg_path, true)
	self.content_edit:setFontSize(24)
	self.content_edit:setPlaceholderFontSize(10)
	self.content_edit:setMaxLength(ph.w - 10)
	self.content_edit:registerScriptEditBoxHandler(BindTool.Bind(self.OnEditEvent, self))

	self.node_t_list.layout_feed_back.node:addChild(self.content_edit, 100)

	self.is_changed = false
	self.old_str = ""
end

function FeedbackView:OnEditEvent(event_type, sender)
	if "began" == event_type then
		self.is_changed = false
		self.old_str = self.content_text_node:getString()
		self.content_text_node:setString("")
		sender:setText(self.old_str)
	elseif "changed" == event_type then
		self.is_changed = true

		local str = sender:getText()
		if AdapterToLua:utf8FontCount(str) > GuildInfoPage.PUBLISH_WORD_SIZE then
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.ContentToLong)
			str = AdapterToLua:utf8TruncateByFontCount(str, GuildInfoPage.PUBLISH_WORD_SIZE)
			sender:setText(str)
		end
	elseif "ended" == event_type then
		if self.is_changed then
			-- GuildCtrl.SetGuildAffiche(1, sender:getText())
			self.content_text_node:setString(sender:getText())
			self.real_content_text = sender:getText()
		else
			self.content_text_node:setString(self.old_str)
		end
		sender:setText("")

		self:Flush()
	end
end

function FeedbackView:ExamineQuesEditTextNum(edit, num, e_type)
	if e_type == "return" then
		local str = edit:getText()
		local text_num = AdapterToLua:utf8FontCount(str)
		if text_num > num then
			str = AdapterToLua:utf8TruncateByFontCount(str, num)
			edit:setText(str)
			SysMsgCtrl.Instance:ErrorRemind(Language.Chat.ContentToLong)
		end
	end
end

function FeedbackView:SendFeedbackClick()
	if not self.content_edit then return end
	local issue_subject = self.node_t_list.edit_feedback_qus.node:getText()
	local issue_content = self.real_content_text
	if issue_subject ~= "" and issue_content ~= "" then
		AgentMs:ContactGm(1, issue_subject, issue_content)
		self:Close()
	else
		if issue_subject == "" then
			SysMsgCtrl.Instance:ErrorRemind(Language.Feedback.NoContents[1])
		end

		if issue_content == "" then
			SysMsgCtrl.Instance:ErrorRemind(Language.Feedback.NoContents[2])
		end
	end
	AudioManager.Instance:PlayClickBtnSoundEffect()
end