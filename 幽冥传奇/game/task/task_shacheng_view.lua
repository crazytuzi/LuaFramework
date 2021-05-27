TaskShangChengView = TaskShangChengView or BaseClass(BaseView)
function TaskShangChengView:__init( ... )
	self:SetBgOpacity(200)
	self:SetModal(true)

	self.texture_path_list = {
		"res/xui/task_ui.png",
		
	}
	self.config_tab = {
		--{"common_ui_cfg", 1, {0}},
		{"mainui_task_effect_ui_cfg", 3, {0}},
		--{"team_ui_cfg", 2, {0}},
		--{"common_ui_cfg", 2, {0}},
	}
	
end

function TaskShangChengView:__delete( ... )
	-- body
end

function TaskShangChengView:ReleaseCallBack( ... )
	-- if self.progress then
	-- 	self.progress:DeleteMe()
	-- 	self.progress = nil 
	-- end
	-- if self.delay_timer then
	-- 	GlobalTimerQuest:CancelQuest(self.delay_timer)
	-- 	self.delay_timer = nil
	-- end
	-- if self.effect_show1 then
	-- 	self.effect_show1:setStop()
	-- 	self.effect_show1 = nil
	-- end

	if self.flush_timer then
		GlobalTimerQuest:CancelQuest(self.flush_timer)
		self.flush_timer = nil
	end

end

function TaskShangChengView:LoadCallBack( ... )
	 XUI.AddClickEventListener(self.node_t_list.btn_enter.node, BindTool.Bind1(self.EnterFuben, self), true)
end


function TaskShangChengView:OpenCallBack()
	-- override
end

function TaskShangChengView:ShowIndexCallBack(index)
	self:Flush(index)
end

function TaskShangChengView:CloseCallBack(...)
	
end




function TaskShangChengView:OnFlush(param_list, index)

	for k, v in pairs(param_list) do
		if k == "param1" then
			self.data = v
			self.time = 3

			if self.flush_timer then
				GlobalTimerQuest:CancelQuest(self.flush_timer)
				self.flush_timer = nil
			end

			self.flush_timer = GlobalTimerQuest:AddTimesTimer(BindTool.Bind1(self.OnFlushCd, self), 1, 3)
			self:OnFlushCd()
		end
	end
end


function TaskShangChengView:OnFlushCd()
	if self.time == nil then
		return 
	end
	self.time = self.time - 1 
	if self.time <= 0 then
		TaskCtrl.SendEnterFubenReq(self.data.fuben_id)
		if self.flush_timer then
			GlobalTimerQuest:CancelQuest(self.flush_timer)
			self.flush_timer = nil
		end
		return
	end
	local text = string.format("%d秒后自动进入", self.time)
	self.node_t_list.text_refresh_time.node:setString(text)
end

function TaskShangChengView:EnterFuben( ... )
	if self.data ~= nil then
		TaskCtrl.SendEnterFubenReq(self.data.fuben_id)
	end
end