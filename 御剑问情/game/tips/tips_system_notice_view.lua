TipSystemNoticeView = TipSystemNoticeView or BaseClass(BaseView)

local SPEED = 100						-- 字幕滚动的速度(像素/秒)

function TipSystemNoticeView:__init()
	self.ui_config = {"uis/views/tips/noticeview_prefab", "SystemNoticeView"}

	self.view_layer = UiLayer.Pop

	self.is_open = false
	self.str_list = {}
	self.current_index = 1
	self.total_count = 0
	self.calculate_time_quest = nil
end

function TipSystemNoticeView:__delete()
	if nil ~= self.calculate_time_quest then
		GlobalTimerQuest:CancelQuest(self.calculate_time_quest)
		self.calculate_time_quest = nil
	end

	self.is_open = false
end

function TipSystemNoticeView:LoadCallBack()
	self.text_obj = self:FindObj("Text")
	self.text_trans = self:FindObj("Text"):GetComponent(typeof(UnityEngine.RectTransform))

	self.mask_width = self:FindObj("Text"):GetComponent(typeof(UnityEngine.RectTransform)).parent:GetComponent(typeof(UnityEngine.RectTransform)).sizeDelta.x
	self.mask_width_cost_time = self.mask_width / SPEED
	self.is_open = true
	self.shield_hearsay = GlobalEventSystem:Bind(
		SettingEventType.CLOSE_HEARSAY,
		BindTool.Bind1(self.OnShieldHearsay, self))
end

function TipSystemNoticeView:ReleaseCallBack()
	if self.shield_hearsay then
		GlobalEventSystem:UnBind(self.shield_hearsay)
		self.shield_hearsay = nil
	end

	-- 清理变量和对象
	self.text_obj = nil
	self.text_trans = nil
	self.tweener = nil
end

function TipSystemNoticeView:OnShieldHearsay(value)
	if value then
		self:Close()
	end
end

function TipSystemNoticeView:OpenCallBack()
	--不允许随机公告出现
	RandSystemCtrl.Instance:SetCanOpenSystem(false)
	self.tweener = nil
end

function TipSystemNoticeView:CloseCallBack()
	--允许随机公告出现
	RandSystemCtrl.Instance:SetCanOpenSystem(true)
	if self.tweener then
		self.tweener:Pause()
	end
end

function TipSystemNoticeView:SetNotice(str)
	local shield_hearsay = SettingData.Instance:GetSettingData(SETTING_TYPE.CLOSE_HEARSAY)
	if shield_hearsay then
		return
	end
	if not self.is_open then
		self:Open()
		self.str_list = {}
		self.current_index = 1
		self.total_count = 0
		self:AddNotice(str)
		self:Flush()
	else
		self:AddNotice(str)
	end
end

function TipSystemNoticeView:AddNotice(str)
	self.total_count = self.total_count + 1
	self.str_list[self.total_count] = str
end

function TipSystemNoticeView:OnFlush()
	if(self.current_index <= self.total_count) then
		local str = self.str_list[self.current_index]
		RichTextUtil.ParseRichText(self.text_obj.rich_text, str, nil, nil, nil, true)
		self.text_trans.anchoredPosition = Vector2(0, 0)

		self.calculate_time_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.Calculate, self), 0.1)
	end
end

-- 计算滚动的时间的位置
function TipSystemNoticeView:Calculate()
	self.calculate_time_quest = nil
	local width = self.text_trans.sizeDelta.x
	local duration = width / SPEED + self.mask_width_cost_time
	width = width + self.mask_width
	-- print_log(width,self.mask_width,duration,self.mask_width_cost_time)
	local tweener = self.text_trans:DOAnchorPosX(-width, duration, false)
	self.tweener = tweener
	tweener:SetEase(DG.Tweening.Ease.Linear)
	tweener:OnComplete(BindTool.Bind(self.OnMoveEnd, self))
end

function TipSystemNoticeView:OnMoveEnd()
	self.current_index = self.current_index + 1
	if(self.current_index > self.total_count) then
		self:Close()
	else
		self:Flush()
	end
end