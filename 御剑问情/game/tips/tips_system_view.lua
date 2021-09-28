TipsSystemView = TipsSystemView or BaseClass(BaseView)

function TipsSystemView:__init()
	self.ui_config = {"uis/views/tips/systemtips_prefab", "SystemTips"}
	self.view_layer = UiLayer.Pop

	self.messge = nil
	self.close_timer = nil
	self.anim_speed = 1
end

function TipsSystemView:__delete()
	if self.close_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.CloseTips)
	end
end

function TipsSystemView:LoadCallBack()
	self.rich_text = self:FindObj("RichText")
	self.system_tips = self:FindObj("SystemTips")
	self.anim = self.system_tips:GetComponent(typeof(UnityEngine.Animator))
	self.anim:SetFloat("Speed", self.anim_speed)
end

function TipsSystemView:ReleaseCallBack()
	-- 清理变量和对象
	self.rich_text = nil
	self.system_tips = nil
	self.anim = nil
end

function TipsSystemView:Show(msg, speed)
	speed = speed or 1
	self.anim_speed = speed
	if self.anim then
		self.anim:SetFloat("Speed", speed)
	end
	if self.close_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.CloseTips)
	end
	self.close_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.CloseTips, self), 5)
	self.messge = msg
	self:Open()
	self:Flush()
end

function TipsSystemView:CloseTips()
	self:Close()
end

function TipsSystemView:OnFlush(param_list)
	RichTextUtil.ParseRichText(self.rich_text.rich_text, self.messge)
end
