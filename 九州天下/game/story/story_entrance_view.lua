StoryEntranceView = StoryEntranceView or BaseClass(BaseView)

function StoryEntranceView:__init()
	self.ui_config = {"uis/views/story", "StoryEntranceView"}
	self.enter_callback = nil
	self.remain_time = 0
	self.close_time_stamp = 0
	self.guide_fb_type = 0

	self.guide_fb_type_map = {}
	self.guide_fb_type_map[GUIDE_FB_TYPE.ROBERT_BOSS] = "BossEntranceAct"
	self.guide_fb_type_map[GUIDE_FB_TYPE.BE_ROBERTED_BOSS] = "BossEntranceAct"
	self.guide_fb_type_map[GUIDE_FB_TYPE.GONG_CHENG_ZHAN] = "GongChengEntranceAct"
	self.guide_fb_type_map[GUIDE_FB_TYPE.SHUIJING] = "ShuijingEntranceAct"
end

function StoryEntranceView:__delete()

end

function StoryEntranceView:SetEnterCallback(enter_callback)
	self.enter_callback = enter_callback
end

function StoryEntranceView:SetGuideFbType(guide_fb_type)
	self.guide_fb_type = guide_fb_type
end

function StoryEntranceView:ReleaseCallBack()
	self.time_txt = nil
end

function StoryEntranceView:LoadCallBack()
	self.time_txt = self:FindVariable("time_txt")
	self:ListenEvent("OnClickEnterFb", BindTool.Bind(self.OnClickEnterFb, self))
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
end

function StoryEntranceView:OpenCallBack()
	self.remain_time = 10
	self.time_txt:SetValue(string.format(Language.Story.AutoTimeEnter, self.remain_time))
	self.count_down = CountDown.Instance:AddCountDown(self.remain_time, 1, BindTool.Bind(self.UpdateTime, self))

	for _, v in pairs(self.guide_fb_type_map) do
		self:FindVariable(v):SetValue(false)
	end

	local act_name = self.guide_fb_type_map[self.guide_fb_type]
	if nil ~= act_name then
		self:FindVariable(act_name):SetValue(true)
	end
end

function StoryEntranceView:CloseCallBack()
	self:RemoveCountDown()
	self.close_time_stamp = Status.NowTime
end

function StoryEntranceView:GetCloseTimeStamp()
	return self.close_time_stamp
end

function StoryEntranceView:UpdateTime(elapse_time, total_time)
    self.remain_time = total_time - elapse_time
    self.time_txt:SetValue(string.format(Language.Story.AutoTimeEnter, math.ceil(self.remain_time)))

    if(self.remain_time <= 0) then
        self.remain_time = 0
        self:RemoveCountDown()
        self:OnClickEnterFb()
    end
end

function StoryEntranceView:RemoveCountDown()
    if self.count_down then
        CountDown.Instance:RemoveCountDown(self.count_down)
        self.count_down = nil
    end
end

function StoryEntranceView:OnClickEnterFb()
	self:Close()

	if nil ~= self.enter_callback then
		self.enter_callback()
	end
end

function StoryEntranceView:OnClickClose()
	self:Close()
end