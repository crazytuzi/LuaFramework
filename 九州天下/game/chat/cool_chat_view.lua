require("game/chat/big_face_view")
require("game/chat/gold_text_view")
require("game/chat/special_view")
require("game/chat/bubble_view")
require("game/chat/head_frame_content")

CoolChatView = CoolChatView or BaseClass(BaseRender)

function CoolChatView:__init()
	-- self.ui_config = {"uis/views/chatview","ChatFuncView"}
	-- self.play_audio = true
end

function CoolChatView:__delete()
	if self.bigface_view then
		self.bigface_view:DeleteMe()
		self.bigface_view = nil
	end

	if self.gold_text_view then
		self.gold_text_view:DeleteMe()
		self.gold_text_view = nil
	end

	if self.special_view then
		self.special_view:DeleteMe()
		self.special_view = nil
	end

	if self.bubble_view then
		self.bubble_view:DeleteMe()
		self.bubble_view = nil
	end

	if self.head_frame_view then
		self.head_frame_view:DeleteMe()
		self.head_frame_view = nil
	end

	-- 清理变量和对象
	self.show_bubble_red = nil
	self.show_big_face_red = nil
	self.show_gold_red = nil
	self.show_head_red = nil
	for i = 1, 4 do
		self["tab" .. i] = nil
	end
end

function CoolChatView:LoadCallBack()
	local bigface_content = self:FindObj("BigFaceView")
	bigface_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.big_face
		self.bigface_view = BigFaceView.New(obj)
		self.bigface_view:OpenCallBack()
		self.bigface_view:FlushBigFaceView()
	end)

	local gold_text_content = self:FindObj("GoldView")
	gold_text_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.gold_text
		self.gold_text_view = GoldTextView.New(obj)
		self.gold_text_view:FlushGoldTextView()
	end)

	local bubble_content = self:FindObj("BubbleView")
	bubble_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.bubble
		self.bubble_view = BubbleView.New(obj)
		self.bubble_view:FlushBubbleView()
	end)

	local head_frame_content = self:FindObj("HeadFrameView")
	head_frame_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.head_frame
		self.head_frame_view = HeadFrameContent.New(obj)
		self.head_frame_view:Flush()
	end)

	self.show_bubble_red = self:FindVariable("ShowBubbleRed")
	self.show_big_face_red = self:FindVariable("ShowBigFaceRed")
	self.show_gold_red = self:FindVariable("ShowGoldRed")
	self.show_head_red = self:FindVariable("ShowHeadRed")

	for i = 1, 4 do
		self["tab" .. i] = self:FindObj("Tab" .. i)
		self["tab" .. i].toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, 800 + i))
	end
	self:OpenCallBack()
	-- self:ListenEvent("Close",BindTool.Bind(self.CloseWindow, self))
end

function CoolChatView:OpenCallBack()
	self:ChangeBubbleRed()
	if self.tab1.toggle.isOn and self.bigface_view then
		self.show_index = TabIndex.big_face
		self.bigface_view:OpenCallBack()
		self.bigface_view:FlushBigFaceView()
	elseif self.tab2.toggle.isOn and self.gold_text_view then
		self.show_index = TabIndex.gold_text
		self.gold_text_view:FlushGoldTextView()
	elseif self.tab3.toggle.isOn and self.bubble_view then
		self.show_index = TabIndex.bubble
		self.bubble_view:FlushBubbleView()
		CoolChatCtrl.Instance:SendPersonalizeWindowOperaReq(PERSONALIZE_WINDOW_OPERA_TYPE.PERSONALIZE_WINDOW_BUBBLE_INFO, 0, 0, 0)
	elseif self.tab4.toggle.isOn and self.head_frame_view then
		self.show_index = TabIndex.head_frame
		self.head_frame_view:Flush()
		CoolChatCtrl.Instance:SendPersonalizeWindowOperaReq(PERSONALIZE_WINDOW_OPERA_TYPE.PERSONALIZE_FRAME_INFO, 0, 0, 0)
	end
end

function CoolChatView:ChangeBubbleRed()
	if self.show_bubble_red then
		local state = CoolChatData.Instance:GetBubbleCanActivate()
		self.show_bubble_red:SetValue(state)
	end
	if self.show_big_face_red then
		local state = CoolChatData.Instance:GetBigFaceRedPoint()
		self.show_big_face_red:SetValue(state)
	end
	if self.show_gold_red then
		local state = CoolChatData.Instance:GetGoldTextRedPoint()
		self.show_gold_red:SetValue(state)
	end
	if self.show_head_red then
		local state = HeadFrameData.Instance:GetHeadFrameRedPoint()
		self.show_head_red:SetValue(state)
	end
	RemindManager.Instance:Fire(RemindName.CoolChat)
end

function CoolChatView:ShowIndexCallBack(index)
	if index == TabIndex.big_face then
		self.tab1.toggle.isOn = true
	elseif index == TabIndex.gold_text then
		self.tab2.toggle.isOn = true
	elseif index == TabIndex.bubble then
		self.tab3.toggle.isOn = true
	elseif index == TabIndex.head_frame then
		self.tab4.toggle.isOn = true
	end
end

function CoolChatView:ToggleChange(index, ison)
	if ison then
		if index == self.show_index then
			return
		end
		self.show_index = index
		if index == TabIndex.big_face then
			if self.bigface_view then
				self.bigface_view:FlushBigFaceView()
			end
		elseif index == TabIndex.gold_text then
			if self.gold_text_view then
				self.gold_text_view:FlushGoldTextView()
			end
		elseif index == TabIndex.bubble then
			if self.bubble_view then
				self.bubble_view:FlushBubbleView()
			end
		elseif index == TabIndex.head_frame then
			if self.head_frame_view then
				self.head_frame_view:Flush()
			end
		end
		self:ShowIndexCallBack(index)
	end
end

function CoolChatView:CloseWindow()
	self:Close()
end

function CoolChatView:OnFlush(param)
	for k, v in pairs(param) do
		if k == "all" then
			if self.tab1.toggle.isOn and self.bigface_view then
				self.bigface_view:FlushBigFaceView()
			elseif self.tab2.toggle.isOn and self.gold_text_view then
				self.gold_text_view:FlushGoldTextView()
			elseif self.tab3.toggle.isOn and self.bubble_view then
				self.bubble_view:FlushBubbleView()
			elseif self.tab4.toggle.isOn and self.head_frame_view then
				self.head_frame_view:Flush()
			end
		elseif k == "big_face" and self.tab1.toggle.isOn then
			if self.bigface_view then
				self.bigface_view:FlushBigFaceView()
			end
		elseif k == "gold_text" and self.tab2.toggle.isOn then
			if self.gold_text_view then
				self.gold_text_view:FlushGoldTextView()
			end
		elseif k == "bubble" and self.tab3.toggle.isOn then
			if self.bubble_view then
				self.bubble_view:FlushBubbleView(v)
			end
		elseif k == "head_frame" and self.tab4.toggle.isOn then
			if self.head_frame_view then
				self.head_frame_view:Flush()
			end
		end
	end
	self:ChangeBubbleRed()
end