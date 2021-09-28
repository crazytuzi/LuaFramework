TipNewSystemNoticeView = TipNewSystemNoticeView or BaseClass(BaseView)

local MaxLeftTime = 3			--最长存在时间
local MinLeftTime = 1			--最小存在时间

function TipNewSystemNoticeView:__init()
	self.ui_config = {"uis/views/tips/noticeview_prefab","NewSystemNoticeView"}
	self.view_layer = UiLayer.Pop
	self.str = ""
	self.early_close_state = false
end

function TipNewSystemNoticeView:__delete()
end

function TipNewSystemNoticeView:ReleaseCallBack()
	-- 清理变量和对象
	self.rich_text = nil
	self:StopCountDown()
end

function TipNewSystemNoticeView:LoadCallBack()
	-- 获取变量
	self.rich_text = self:FindObj("RichText")
end

--设置是否提前关闭
function TipNewSystemNoticeView:SetEarlyCloseState(state)
	self.early_close_state = state
end

function TipNewSystemNoticeView:SetNotice(str)
	self.str = str or ""
end

function TipNewSystemNoticeView:StopCountDown()
	if self.close_count_down then
		CountDown.Instance:RemoveCountDown(self.close_count_down)
		self.close_count_down = nil
	end
end

function TipNewSystemNoticeView:StartCountDown()
	self:StopCountDown()
	self.close_count_down = CountDown.Instance:AddCountDown(MaxLeftTime, 0.1, function(elapse_time, total_time)
		if (self.early_close_state and elapse_time > MinLeftTime) or elapse_time >= total_time then
			self:StopCountDown()
			self:Close()
			return
		end
	end)
end

function TipNewSystemNoticeView:OpenCallBack()
	self.early_close_state = false
	self:StartCountDown()
	RichTextUtil.ParseRichText(self.rich_text.rich_text, self.str, nil, nil, nil, true)
end

function TipNewSystemNoticeView:CloseCallBack()
	self:StopCountDown()
end