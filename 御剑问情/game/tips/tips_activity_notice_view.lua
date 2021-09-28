TipsActivityNoticeView = TipsActivityNoticeView or BaseClass(BaseView)

function TipsActivityNoticeView:__init()
	self.ui_config = {"uis/views/tips/activitynotice_prefab", "ActivityNoticeTips"}
	self.view_layer = UiLayer.PopTop

	self.messge = nil
	self.close_timer = nil

	self.is_hide = false
	self.play_audio = true
end

function TipsActivityNoticeView:__delete()
	if self.close_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.CloseTips)
	end
end

function TipsActivityNoticeView:LoadCallBack()
	self.rich_text = self:FindVariable("MsgText")

	self.text_animator = self:FindObj("Animator").animator
end

function TipsActivityNoticeView:ReleaseCallBack()
	-- 清理变量和对象
	self.rich_text = nil
	self.text_animator = nil
end

function TipsActivityNoticeView:Show(msg)
	if self.close_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.CloseTips)
	end
	-- self.close_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.CloseTips, self), 3)
	self.messge = RichTextUtil.GetAnalysisText(msg, color)
	self:Open()
	self.is_hide = false
	self:Flush()
end

function TipsActivityNoticeView:CloseTips()
	-- print("关闭")
	self:Close()
end

function TipsActivityNoticeView:AnimatorIsHide()
	return self.is_hide
end

function TipsActivityNoticeView:OnFlush(param_list)
	-- RichTextUtil.ParseRichText(self.rich_text.rich_text, self.messge)
	self.text_animator:SetBool("show", true)

	self.rich_text:SetValue(self.messge)
	self.text_animator:WaitEvent("enter", function(param)
		self.text_animator:SetBool("show", false)
		self.is_hide = true
	end)
end
