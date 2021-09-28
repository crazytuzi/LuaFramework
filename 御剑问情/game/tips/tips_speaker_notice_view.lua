TipSpeakerNoticeView = TipSpeakerNoticeView or BaseClass(BaseView)

local LeftTime = 10
local Speed = 30

function TipSpeakerNoticeView:__init()
	self.ui_config = {"uis/views/tips/speakertips_prefab","SpeakNoticeView"}
	self.view_layer = UiLayer.MainUIHigh
	self.user_name = ""
	self.str = ""
end

function TipSpeakerNoticeView:__delete()

end

function TipSpeakerNoticeView:ReleaseCallBack()
	self:StopTimeQuest()
	self:StopCheckTimeQuest()

	if self.chat_hight_change then
		GlobalEventSystem:UnBind(self.chat_hight_change)
		self.chat_hight_change = nil
	end

	if self.menu_toggle_change then
		GlobalEventSystem:UnBind(self.menu_toggle_change)
		self.menu_toggle_change = nil
	end

	if self.move_tween then
		self.move_tween:Kill()
		self.move_tween = nil
	end

	-- 清理变量和对象
	self.rich_text = nil
	self.labl_mask = nil
	self.name_text = nil
	self.max_mask = nil
	self.content = nil
	self.frame = nil
	self.name = nil
	self.show_panel = nil
end

function TipSpeakerNoticeView:LoadCallBack()
	-- 获取变量
	self.rich_text = self:FindObj("RichText")
	self.labl_mask = self:FindObj("LablMask")
	self.name_text = self:FindObj("NameText")
	self.max_mask = self:FindObj("MaxMask")
	self.content = self:FindObj("Content")
	self.frame = self:FindObj("Frame")

	self.name = self:FindVariable("Name")
	self.show_panel = self:FindVariable("ShowPanel")

	--间距
	self.content_spacing = self.content.horizontal_layout_group.spacing
end

function TipSpeakerNoticeView:SetUserName(name)
	self.user_name = name or ""
end

function TipSpeakerNoticeView:SetNotice(str)
	self.str = str or ""
end

function TipSpeakerNoticeView:StopTimeQuest()
	if self.close_time_quest then
		GlobalTimerQuest:CancelQuest(self.close_time_quest)
		self.close_time_quest = nil
	end
end

function TipSpeakerNoticeView:StartTimeQuest()
	self:StopTimeQuest()
	self.close_time_quest = GlobalTimerQuest:AddDelayTimer(function()
		self.close_time_out = true
	end, LeftTime)
end

function TipSpeakerNoticeView:StopCheckTimeQuest()
	if self.check_time_quest then
		GlobalTimerQuest:CancelQuest(self.check_time_quest)
		self.check_time_quest = nil
	end
end

function TipSpeakerNoticeView:StartCheckTimeQuest()
	self:StopCheckTimeQuest()
	self.check_time_quest = GlobalTimerQuest:AddRunQuest(function()
		if self.close_time_out and self.move_time_out then
			self:Close()
			self:StopCheckTimeQuest()
		end
	end, 0.1)
end

function TipSpeakerNoticeView:OpenCallBack()
	self.close_time_out = false					--是否已经超过最大时间限制
	self.move_time_out = false					--是否已经完全移动过一次了
	self:StartTimeQuest()
	self:StartCheckTimeQuest()
	self:StartNotice()
	GlobalEventSystem:Fire(MainUIEventType.CHAT_TOP_BUTTON_MOVE, true)

	self.chat_hight_change = GlobalEventSystem:Bind(MainUIEventType.CHAT_VIEW_HIGHT_CHANGE,
		BindTool.Bind(self.FulshPosition, self))

	self.menu_toggle_change = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.MenuToggleChange, self))

	--获取当前主界面聊天框是边长的还是变短的
	local chat_view_state = MainUIData.Instance:GetChatViewState()
	local posy = 118.5
	if chat_view_state == MainUIData.ChatViewState.Length then
		posy = 118.5 + 105
	end

	self.frame.rect.anchoredPosition = Vector2(-5, posy)
end

function TipSpeakerNoticeView:FulshPosition(param)
	if self.frame.gameObject.activeInHierarchy then
		local y = 118.5
		if param == "to_length" then
			y = 118.5 + 105
		end
		local tween = self.frame.rect:DOAnchorPosY(y, 0.5, false)
		tween:SetEase(DG.Tweening.Ease.Linear)
	end
end

function TipSpeakerNoticeView:MenuToggleChange(is_on)
	self.can_show = is_on
	self.show_panel:SetValue(self.can_show)
end

function TipSpeakerNoticeView:StartNotice()
	--设置文本
	self.name:SetValue(self.user_name)
	RichTextUtil.ParseRichText(self.rich_text.rich_text, self.str)

	--强制刷新结构
	UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.content.rect)
	UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.rich_text.rect)

	--计算总长度是否已超出
	local rich_text_width = self.rich_text.rect.rect.width
	local name_text_width = self.name_text.rect.rect.width
	local max_width = self.max_mask.rect.rect.width

	local other_width = name_text_width + self.content_spacing

	--设置文本遮罩大小
	local layout_element_min_width = max_width - other_width
	self.labl_mask.layout_element.minWidth = layout_element_min_width

	--强制刷新结构
	UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.labl_mask.rect)

	--重置richText位置
	self.rich_text.transform:SetLocalPosition(-self.labl_mask.rect.rect.width/2, 0, 0)

	--8个像素的误差
	if rich_text_width + other_width > max_width + 8 then
		--文本超出了最大显示范围,开始移动
		self:StartDoMove(rich_text_width, layout_element_min_width)
	else
		self.move_time_out = true
	end
end

function TipSpeakerNoticeView:StartDoMove(rich_text_width, layout_element_min_width)
	--计算超出的范围
	local out_width = rich_text_width - layout_element_min_width
	local duration = out_width / Speed
	self.move_tween = self.rich_text.rect:DOAnchorPosX(-out_width, duration)
	self.move_tween:SetEase(DG.Tweening.Ease.Linear)
	self.move_tween:OnStepComplete(function()
		self.move_time_out = true
	end)
	self.move_tween:SetLoops(-1, DG.Tweening.LoopType.Yoyo)
end

function TipSpeakerNoticeView:CloseCallBack()
	self:StopTimeQuest()
	self:StopCheckTimeQuest()

	GlobalEventSystem:Fire(MainUIEventType.CHAT_TOP_BUTTON_MOVE, false)

	if self.move_tween then
		self.move_tween:Kill()
		self.move_tween = nil
	end

	if self.chat_hight_change then
		GlobalEventSystem:UnBind(self.chat_hight_change)
		self.chat_hight_change = nil
	end

	if self.menu_toggle_change then
		GlobalEventSystem:UnBind(self.menu_toggle_change)
		self.menu_toggle_change = nil
	end
end