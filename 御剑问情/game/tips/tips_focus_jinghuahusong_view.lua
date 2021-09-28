TipsFocusJingHuaHuSongView = TipsFocusJingHuaHuSongView or BaseClass(BaseView)			--精华护送提醒弹窗，精华刷新的时候弹出

function TipsFocusJingHuaHuSongView:__init()
	self.ui_config = {"uis/views/tips/focustips_prefab", "FocusJingHuaHuSongTips"}
	self.view_layer = UiLayer.Pop
end

function TipsFocusJingHuaHuSongView:LoadCallBack()
	self:ListenEvent("close_click",BindTool.Bind(self.CloseClick, self))
	self:ListenEvent("go_click",BindTool.Bind(self.GoClick, self))
	self:ListenEvent("go_click_2",BindTool.Bind(self.GoClick2, self))
	self.time = self:FindVariable("time")
end

function TipsFocusJingHuaHuSongView:ReleaseCallBack()
	self.time = nil
end

function TipsFocusJingHuaHuSongView:OpenCallBack()
	self:Flush()
end

function TipsFocusJingHuaHuSongView:CloseClick()
	self:Close()
end

function TipsFocusJingHuaHuSongView:GoClick()
	if JingHuaHuSongCtrl.Instance then
		JingHuaHuSongCtrl.Instance:ContinueJingHuaHuSong(JingHuaHuSongData.JingHuaType.Small)			--前往精华护送,小灵石
	end
	self:Close()
end

function TipsFocusJingHuaHuSongView:GoClick2()
	if JingHuaHuSongCtrl.Instance then
		JingHuaHuSongCtrl.Instance:ContinueJingHuaHuSong(JingHuaHuSongData.JingHuaType.Big)				--前往精华护送,大灵石
	end
	self:Close()
end

function TipsFocusJingHuaHuSongView:CloseCallBack()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function TipsFocusJingHuaHuSongView:OnFlush()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.time:SetValue(15)
	self.count_down = CountDown.Instance:AddCountDown(15, 1, BindTool.Bind(self.CountDown, self))
end

function TipsFocusJingHuaHuSongView:CountDown(elapse_time, total_time)
	self.time:SetValue(total_time - elapse_time)
	if elapse_time >= total_time then
		if self.count_down then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		self:Close()
	end
end