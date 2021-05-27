ChatTransmitPopView = ChatTransmitPopView or BaseClass(XuiBaseView)

ChatTransmitPopView.TransmitType = {
	dalaba = 2,
	xiaolaba = 1,
}

function ChatTransmitPopView:__init()
	self.is_modal = true

	self.cur_win_type = -1 		--当前窗口类型
	self.local_gold = 10
	self.cross_gold = 30

	self.texture_path_list[1] = 'res/xui/chat.png'
	self.texture_path_list[2] = 'res/xui/face.png'
	self.config_tab = {{"chat_ui_cfg", 4, {0}}}
end

function ChatTransmitPopView:LoadCallBack()
	local content_size = self.root_node:getContentSize()
	local x = content_size.width / 2
	local y = content_size.height - 16
	self.node_t_list.edit_contentbg_0.node:registerScriptEditBoxHandler(BindTool.Bind2(ChatData.ExamineEditTextNum, self.node_t_list.edit_contentbg_0.node, CHAT_EDIT_MAX))

	self.node_t_list.layout_chat_pop_face.node:setTouchEnabled(true)
	self.node_t_list.layout_chat_pop_face.node:setIsHittedScale(true)

	-- self.rich_xiaolaba = XUI.CreateRichText(self.ph_list.ph_rich_xiaolaba.x, self.ph_list.ph_rich_xiaolaba.y, 305, 26, false)
	-- self.rich_xiaolaba:setAnchorPoint(0, 0.5)
	-- self.rich_xiaolaba:setVerticalSpace(20)
	-- self.node_t_list.layout_transmit_pop.node:addChild(self.rich_xiaolaba, 999, 999)

	-- self.rich_dalaba = XUI.CreateRichText(self.ph_list.ph_rich_dalaba.x, self.ph_list.ph_rich_dalaba.y, 305, 26, false)
	-- self.rich_dalaba:setAnchorPoint(0, 0.5)
	-- self.node_t_list.layout_transmit_pop.node:addChild(self.rich_dalaba, 999, 999)

	RichTextUtil.ParseRichText(self.node_t_list.rich_xiaolaba.node, Language.Transmit.Small, 18, nil)
	RichTextUtil.ParseRichText(self.node_t_list.rich_dalaba.node, Language.Transmit.Big, 18, nil)


	local toggle_list = {
	self.node_t_list.toggle_radio0.node,
	self.node_t_list.toggle_radio1.node,
 	}

	self.choose_button = RadioButton.New()
	self.choose_button:SetToggleList(toggle_list)
	self.choose_button:SetSelectCallback(BindTool.Bind1(self.ChooseTransmitCallback, self))
	
	self:InitTransmit()
	self:RegisterTransmitEvent()
end

function ChatTransmitPopView:InitTransmit()
	self.node_t_list.edit_contentbg_0.node:setFont(COMMON_CONSTS.FONT, CHAT_FONT_SIZE)
	self.pop_alert = Alert.New()
	self.cross_alert = Alert.New()
end

function ChatTransmitPopView:RegisterTransmitEvent()
	self.node_t_list.btn_close.node:addClickEventListener(BindTool.Bind1(self.CloseTransmitPop, self))
	self.node_t_list.layout_chat_pop_face.node:addClickEventListener(BindTool.Bind1(ChatCtrl.Instance.OpenFace, ChatCtrl.Instance))
	self.node_t_list.btn_send.node:addClickEventListener(BindTool.Bind1(self.SendTransmitMsg, self))
end

function ChatTransmitPopView:ChooseTransmitCallback(index)
	self.cur_win_type = index
end

function ChatTransmitPopView:OpenTransmitPop(type)
	self.cur_win_type = type
	self:Open()
end

function ChatTransmitPopView:OpenCallBack()

end

function ChatTransmitPopView:ShowIndexCallBack()
	--self:OpenTransmitCallBack(self.cur_win_type)
	self.choose_button:ChangeToIndex(self.cur_win_type)
	self.transmit_is_popup = true
end

function ChatTransmitPopView:CloseCallBack()
	self.transmit_is_popup = false
end

function ChatTransmitPopView:OpenTransmitCallBack(type)
	local horn_type
	local des = " "
	local word_x , word_y = self.node_t_list.img_word_bg.node:getPosition()
	if ChatTransmitPopView.TransmitType.dalaba == type then--大喇叭
		des = Language.Transmit.Big
		self:CreateTopTitle(ResPath.GetChat("t_big_horn"), word_x, word_y, self.node_t_list.layout_transmit_pop.node)
	else--小喇叭
		des = Language.Transmit.Small
		self:CreateTopTitle(ResPath.GetChat("t_small_horn"), word_x, word_y, self.node_t_list.layout_transmit_pop.node)
	end
	RichTextUtil.ParseRichText(self.rich_xiaolaba, des, 20, nil)
end

function ChatTransmitPopView:CloseTransmitPop()
	self:Close()
	ChatCtrl.Instance:CloseFace()
	self:ClearInput()
end

function ChatTransmitPopView:GetEditText()
	if nil ~= self.node_t_list.edit_contentbg_0 then
		return self.node_t_list.edit_contentbg_0.node
	end
	return nil
end

function ChatTransmitPopView:ClearInput()
	if nil ~= self.node_t_list.edit_contentbg_0 then
		self.node_t_list.edit_contentbg_0.node:setText("")
	end
	ChatData.Instance:ClearInput()
end

function ChatTransmitPopView:SendTransmitMsg()
	if nil == self.node_t_list.edit_contentbg_0.node then
		return
	end

	local text = self.node_t_list.edit_contentbg_0.node:getText()
	local len = string.len(text)
	if len <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NilContent)
		return
	end
	if len >= COMMON_CONSTS.MAX_CHAT_MSG_LEN then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.ContentToLong)
		return
	end

	if ChatData.ExamineEditText(text, 0) == false then return end

	local message = ChatData.Instance:FormattingMsg(text, 0)

	if self.cur_win_type == ChatTransmitPopView.TransmitType.dalaba then
		local item_index = BagData.Instance:GetItemIndex(26907)
		if -1 ~= item_index then
			ChatCtrl.Instance:SendCurrentTransmit(0, message, nil, SPEAKER_TYPE.SPEAKER_TYPE_CROSS)

			self:CloseTransmitPop()
			self:ClearInput()
		else
			self.cross_alert:SetOkFunc(BindTool.Bind2(self.SendCrossTransmitUseGold, self, message))
			local des = string.format(Language.Chat.SendSrossByGold, self.cross_gold)
			self.cross_alert:SetLableString(des)
			self.cross_alert:SetShowCheckBox(true)
			self.cross_alert:Open()
		end
	else
		local item_index = BagData.Instance:GetItemIndex(26908)
		if -1 ~= item_index then
			ChatCtrl.Instance:SendCurrentTransmit(0, message, nil, SPEAKER_TYPE.SPEAKER_TYPE_LOCAL)

			self:CloseTransmitPop()
			self:ClearInput()
		else
			self.pop_alert:SetOkFunc(BindTool.Bind2(self.SendTransmitUseGold, self, message))
			local des = string.format(Language.Chat.SendByGold, self.local_gold)
			self.pop_alert:SetLableString(des)
			self.pop_alert:SetShowCheckBox(true)
			self.pop_alert:Open()
		end
	end
end

function ChatTransmitPopView:SendTransmitUseGold(message)
	-- if not RoleData.Instance:GetIsEnoughUseGold(self.local_gold) then
	-- 	UiInstanceMgr.Instance:ShowChongZhiView()
	-- 	return
	-- end

	-- ChatCtrl.Instance:SendCurrentTransmit(1, message, nil, SPEAKER_TYPE.SPEAKER_TYPE_LOCAL)
	-- self:CloseTransmitPop()
	-- self:ClearInput()
end

function ChatTransmitPopView:SendCrossTransmitUseGold(message)
	-- if not RoleData.Instance:GetIsEnoughUseGold(self.cross_gold) then
	-- 	UiInstanceMgr.Instance:ShowChongZhiView()
	-- 	return
	-- end

	-- ChatCtrl.Instance:SendCurrentTransmit(1, message, nil, SPEAKER_TYPE.SPEAKER_TYPE_CROSS)
	-- self:CloseTransmitPop()
	-- self:ClearInput()
end

function ChatTransmitPopView:IsTransmitOpen()
	return self.transmit_is_popup
end