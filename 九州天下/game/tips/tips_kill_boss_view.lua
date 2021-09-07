TipsKillBossView = TipsKillBossView or BaseClass(BaseView)

function TipsKillBossView:__init()
	self.ui_config = {"uis/views/tips/killbosstip", "KillBossTip"}
	self.select_item_id = 0
	self.play_audio = true
	self.view_layer = UiLayer.Pop
end

function TipsKillBossView:__delete()
end

function TipsKillBossView:ReleaseCallBack()
	self.kill_text_list = nil
	self.show_no_text = nil
	self.data = nil
end

function TipsKillBossView:LoadCallBack()
	self:ListenEvent("close_click",BindTool.Bind(self.OnCloseClick, self))
	self.kill_text_list = {}
	for i=1,5 do
		self.kill_text_list[i] = self:FindVariable("kill_text_" .. i)
	end
	self.show_no_text = self:FindVariable("show_no_text")
end

function TipsKillBossView:OpenCallBack()
	self:Flush()
end

function TipsKillBossView:SetData(data)
	self.data = data
	self:Flush()
end

function TipsKillBossView:OnFlush()
	local count = 1
	if self.data then
		for i = 1, #self.data do
			if self.data[i].killier_time ~= 0 then
				count = count + 1
			end
		end
		for i = 1, #self.data do
			if self.data[i].killier_time ~= 0 then
				local time_list = os.date("*t",self.data[i].killier_time)
				local time_desc = time_list.hour .. Language.Common.TimeList.h .. time_list.min .. Language.Common.TimeList.min .. time_list.sec..Language.Common.TimeList.s
				local kill_name = ToColorStr(self.data[i].killer_name, TEXT_COLOR.GREEN)
				self.kill_text_list[count - i]:SetValue(time_desc .. Language.Common.Bei.. kill_name .. Language.Dungeon.JiSha)
			else
				self.kill_text_list[i]:SetValue("")
			end
		end
		self.show_no_text:SetValue(count == 1)
	end
end

function TipsKillBossView:OnCloseClick()
	self:Close()
end