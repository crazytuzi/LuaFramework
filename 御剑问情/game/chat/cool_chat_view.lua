require("game/chat/big_face_view")
require("game/chat/gold_text_view")
require("game/chat/special_view")
require("game/chat/bubble_view")
require("game/chat/head_frame/head_frame_content")

CoolChatView = CoolChatView or BaseClass(BaseView)

function CoolChatView:__init()
	self.ui_config = {"uis/views/chatview_prefab","ChatFuncView"}
	self.play_audio = true
end

function CoolChatView:__delete()

end

function CoolChatView:ReleaseCallBack()
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
	for i = 1, 5 do
		self["tab" .. i] = nil
	end

	self.bigface_content = nil
	self.gold_text_content = nil
	self.bubble_content = nil
	self.show_head_frame_red = nil
	self.head_frame_content = nil
end

function CoolChatView:LoadCallBack()
	self.bigface_content = self:FindObj("BigFaceView")
	self.gold_text_content = self:FindObj("GoldView")
	self.bubble_content = self:FindObj("BubbleView")
	self.head_frame_content = self:FindObj("head_frame_content")

	self.show_bubble_red = self:FindVariable("ShowBubbleRed")
	self.show_big_face_red = self:FindVariable("ShowBigFaceRed")
	self.show_gold_red = self:FindVariable("ShowGoldRed")
	self.show_head_frame_red = self:FindVariable("show_head_frame_red")

	for i = 1, 5 do
		self["tab" .. i] = self:FindObj("Tab" .. i)
		self["tab" .. i].toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, 800 + i))
	end

	self:ListenEvent("Close",BindTool.Bind(self.CloseWindow, self))
	self:ShowIndex(TabIndex.big_face)
end

function CoolChatView:OpenCallBack()
	CoolChatData.Instance:SetIsOpen()
	RemindManager.Instance:Fire(RemindName.CoolChat)
	RemindManager.Instance:Fire(RemindName.BeStrength)
	-- RemindManager.Instance:Fire(RemindName.GuildChat)
	
	self:ChangeBubbleRed()
	if self.tab1.toggle.isOn and self.bigface_view then
		self.show_index = TabIndex.big_face
		self.bigface_view:OpenCallBack()
		self.bigface_view:FlushBigFaceView()
	elseif self.tab2.toggle.isOn and self.gold_text_view then
		self.show_index = TabIndex.gold_text
		self.gold_text_view:FlushGoldTextView()
	elseif self.tab4.toggle.isOn and self.bubble_view then
		self.show_index = TabIndex.bubble
		self.bubble_view:FlushBubbleView()
		CoolChatCtrl.Instance:SendPersonalizeWindowOperaReq(PERSONALIZE_WINDOW_OPERA_TYPE.PERSONALIZE_WINDOW_BUBBLE_INFO, 0, 0, 0)
	elseif self.tab5.toggle.isOn and self.head_frame_view then
		self.show_index = TabIndex.head_frame
		self.head_frame_view:OpenCallBack()
		CoolChatCtrl.Instance:SendPersonalizeWindowOperaReq(PERSONALIZE_WINDOW_OPERA_TYPE.PERSONALIZE_FRAME_INFO, 0, 0, 0)

	end
end

function CoolChatView:CloseCallBack()
	if self.show_big_face_red then
		local state = CoolChatData.Instance:GetBigFaceRedPoint()
		if state then
			self.show_big_face_red:SetValue(not state)
		end
	end
end

function CoolChatView:ChangeBubbleRed()
	if self.show_bubble_red then
		local state = CoolChatData.Instance:GetBubbleCanActivate()
		self.show_bubble_red:SetValue(state)
	end

	if self.show_big_face_red  then
		local state = CoolChatData.Instance:GetBigFaceRedPoint()
		self.show_big_face_red:SetValue(state)
	end
	
	if self.show_gold_red then
		local state = CoolChatData.Instance:GetGoldTextRedPoint()
		self.show_gold_red:SetValue(state)
	end

	if self.show_head_frame_red then
		local state = HeadFrameData.Instance:GetHeadFrameRedPoint()
		self.show_head_frame_red:SetValue(state)
	end
	RemindManager.Instance:Fire(RemindName.CoolChat)
end



function CoolChatView:ShowIndexCallBack(index)
	self:AsyncLoadView(index)
	if index == TabIndex.big_face then
		self.tab1.toggle.isOn = true
	elseif index == TabIndex.gold_text then
		self.tab2.toggle.isOn = true
	elseif index == TabIndex.bubble then
		self.tab4.toggle.isOn = true
	elseif index == TabIndex.head_frame then
		self.tab5.toggle.isOn = true
		if self.head_frame_view then
			self.head_frame_view:OpenCallBack()
		end
	end
end

function CoolChatView:AsyncLoadView(index)
	if index == TabIndex.big_face and not self.bigface_view then
		UtilU3d.PrefabLoad("uis/views/chatview_prefab", "BigFaceContentView",
			function(obj)
				obj.transform:SetParent(self.bigface_content.transform, false)
				obj = U3DObject(obj)
				self.show_index = TabIndex.big_face
				self.bigface_view = BigFaceView.New(obj)
				self.bigface_view:OpenCallBack()
				self.bigface_view:FlushBigFaceView()
			end)
	end
	if index == TabIndex.gold_text and not self.gold_text_view then
		UtilU3d.PrefabLoad("uis/views/chatview_prefab", "GoldContentView",
			function(obj)
				obj.transform:SetParent(self.gold_text_content.transform, false)
				obj = U3DObject(obj)
				self.show_index = TabIndex.gold_text
				self.gold_text_view = GoldTextView.New(obj)
				self.gold_text_view:FlushGoldTextView()
			end)
	end
	if index == TabIndex.bubble and not self.bubble_view then
		UtilU3d.PrefabLoad("uis/views/chatview_prefab", "BubbleContentView",
			function(obj)
				obj.transform:SetParent(self.bubble_content.transform, false)
				obj = U3DObject(obj)
				self.show_index = TabIndex.bubble
				self.bubble_view = BubbleView.New(obj)
				self.bubble_view:FlushBubbleView()
			end)
	end
	if index == TabIndex.head_frame and not self.head_frame_view then
		UtilU3d.PrefabLoad("uis/views/chatview_prefab", "HeadFrameContent",
			function(obj)
				obj.transform:SetParent(self.head_frame_content.transform, false)
				obj = U3DObject(obj)
				self.show_index = TabIndex.head_frame
				self.head_frame_view = HeadFrameContent.New(obj)
				self.head_frame_view:OpenCallBack()
			end)
	end
	
end
function CoolChatView:ToggleChange(index, ison)
	if ison then
		if index == self.show_index then
			return
		end
		self:ShowIndex(index)
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
				self.head_frame_view:OpenCallBack()
			end
		end
	end
end

function CoolChatView:CloseWindow()
	self:Close()
end

function CoolChatView:OnFlush(param)

	for k, v in pairs(param) do
		if k == "big_face" and self.tab1.toggle.isOn then
			if self.bigface_view then
				self.bigface_view:FlushBigFaceView()
			end
		elseif k == "gold_text" and self.tab2.toggle.isOn then
			if self.gold_text_view then
				self.gold_text_view:FlushGoldTextView()
			end
		-- elseif k == "special" and self.tab3.toggle.isOn then
		-- 	self.special_view:FlushSpecialView()
		elseif k == "bubble" and self.tab4.toggle.isOn then
			if self.bubble_view then
				self.bubble_view:FlushBubbleView(v)
			end
		elseif k == "head_frame" and self.tab5.toggle.isOn then
			if self.head_frame_view then
				self.head_frame_view:Flush(v)
			end
		end
	end
	self:ChangeBubbleRed()
end