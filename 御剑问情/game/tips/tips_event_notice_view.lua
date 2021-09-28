TipsEventNoticeView = TipsEventNoticeView or BaseClass(BaseView)

function TipsEventNoticeView:__init()
	self.ui_config = {"uis/views/tips/tipsevent_prefab", "TipsEventView"}
	self.view_layer = UiLayer.PopTop

	self.messge = nil
	self.close_timer = nil

	self.is_hide = false
	self.play_audio = true
end

function TipsEventNoticeView:__delete()
	if self.close_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.CloseTips)
	end
end

function TipsEventNoticeView:LoadCallBack()
	self.rich_text1 = self:FindObj("MsgText1"):GetComponent(typeof(RichTextGroup))
	self.rich_text2 = self:FindObj("MsgText2"):GetComponent(typeof(RichTextGroup))

	self.obj1 = self:FindObj("Animator1")
	self.obj2 = self:FindObj("Animator2")
	self.text_animator1 = self:FindObj("Animator1").animator
	self.text_animator2 = self:FindObj("Animator2").animator
end


function TipsEventNoticeView:ReleaseCallBack()
	-- 清理变量和对象
	self.rich_text1 = nil
	self.rich_text2 = nil
	self.obj2 = nil
	self.obj1 = nil
	self.text_animator1 = nil
	self.text_animator2 = nil
end

function TipsEventNoticeView:Show(msg, types)
	-- print_error(msg, types)
	self.messge = msg
	self.open_type = types + 1
	self:Open()
	self.is_hide = false
	self:Flush()
end

function TipsEventNoticeView:CloseTips()
	-- print("关闭")
	self:Close()
end

function TipsEventNoticeView:AnimatorIsHide()
	return self.is_hide
end

function TipsEventNoticeView:OnFlush(param_list)
	-- RichTextUtil.ParseRichText(self.rich_text.rich_text, self.messge)
	RichTextUtil.ParseRichText(self["rich_text" .. self.open_type], self.messge, nil, nil, nil, nil, 24)
	self.obj1:SetActive(self.open_type == 1)
	self.obj2:SetActive(self.open_type == 2)
	self["text_animator" .. self.open_type]:SetBool("show", true)

	self["text_animator" .. self.open_type]:WaitEvent("enter", function(param)
		self["text_animator" .. self.open_type]:SetBool("show", false)
		self.is_hide = true
	end)
end
