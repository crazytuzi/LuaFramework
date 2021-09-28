TipsKillBossView = TipsKillBossView or BaseClass(BaseView)

function TipsKillBossView:__init()
	self.ui_config = {"uis/views/tips/killbosstip_prefab", "KillBossTip"}
	self.select_item_id = 0
	self.play_audio = true
	self.view_layer = UiLayer.Pop
end

function TipsKillBossView:__delete()
end

function TipsKillBossView:LoadCallBack()
	self:ListenEvent("close_click",BindTool.Bind(self.OnCloseClick, self))
	self.kill_text_list = {}
	for i=1,5 do
		self.kill_text_list[i] = self:FindVariable("kill_text_" .. i)
	end
	self.show_no_text = self:FindVariable("show_no_text")
end


function TipsKillBossView:ReleaseCallBack()
	for i,v in pairs(self.kill_text_list) do
		if v then 
			v = nil
		end
	end
	self.kill_text_list = {}
	self.show_no_text = nil
end

function TipsKillBossView:SetData(data)
	self.data = data
	self:Flush()
end

function TipsKillBossView:OnFlush()
	if self.data and self.data.killer_info then
		local temp_table = {}
		for i,v in ipairs(self.data.killer_info) do
			if v.killier_time ~= 0 then
				table.insert(temp_table, v)
			end
		end
		for k,v in ipairs(temp_table) do
			local time_list = os.date("*t",v.killier_time)
			local time_desc = ToColorStr(TimeUtil.FormatTable2HMS(time_list), TEXT_COLOR.BLUE_SPECIAL)
			local kill_name = ToColorStr(v.killer_name, TEXT_COLOR.BLUE_SPECIAL)
			local boss_name = self.data.boss_name
			if self.kill_text_list[k] then
				self.kill_text_list[k]:SetValue(time_desc .. "  " .. boss_name..Language.Common.Bei.. kill_name .. Language.Dungeon.JiSha)
			end
		end

		for i = #temp_table + 1, #self.kill_text_list do
			self.kill_text_list[i]:SetValue("")
		end
		self.show_no_text:SetValue(#temp_table == 0)
	end
end

function TipsKillBossView:OnCloseClick()
	self:Close()
end