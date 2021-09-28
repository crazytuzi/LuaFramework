TipsFloatingManager = TipsFloatingManager or BaseClass()

function TipsFloatingManager:__init()
	if TipsFloatingManager.Instance ~= nil then
		error("[TipsFloatingManager] attempt to create singleton twice!")
		return
	end
	TipsFloatingManager.Instance = self
	self.floating_view = TipsFloatingView.New()
	self.floating_view:SetCallBack(BindTool.Bind(self.RemoveListCallBack, self))
	self.next_time = 0.0
	self.list = {}
	Runner.Instance:AddRunObj(self, 3)
	self.play_audio = true

	self.is_pausing = false
	self.next_pause_invalid_time = 0  -- 错误恢复，防止一直暂停
end

function TipsFloatingManager:__delete()
	self.list = {}
	if self.floating_view then
		self.floating_view:DeleteMe()
		self.floating_view = nil
	end
	Runner.Instance:RemoveRunObj(self)
end

function TipsFloatingManager:Update(now_time, elapse_time)
	if not self.is_pausing then
		-- if self.next_time > 0.0 then
		-- 	self.next_time = self.next_time - UnityEngine.Time.deltaTime
		-- else
		-- 	self.next_time = 0.0
		-- end
		if #self.list > 5 then
			self.floating_view:RemoveMsg()
			-- table.remove(self.list, 1)
		end
		if #self.list > 0 and self.next_time <= 0.0 then
			self:OpenFloatingView()
			-- self.floating_view:Show(self.list[1])
			self.floating_view:ShowText()
			-- self.next_time = 0.5
		end
	end

	if self.next_pause_invalid_time > 0 and now_time >= self.next_pause_invalid_time then
		self.is_pausing = false
		self.next_pause_invalid_time = 0
	end
end

function TipsFloatingManager:RemoveListCallBack()
	table.remove(self.list, 1)
end

function TipsFloatingManager:ShowFloatingTips(msg)
	self:OpenFloatingView()

	table.insert(self.list, msg)
	self.floating_view:InsertMsg(msg)

	-- if self.next_time > 0.0 or self.is_pausing then
	-- else
	-- 	self.next_time = 0.5
	-- end
end

function TipsFloatingManager:PauseFloating()
	self:OpenFloatingView()
	self.is_pausing = true
	self.next_pause_invalid_time = Status.NowTime + 5
end

function TipsFloatingManager:OpenFloatingView()
	if not self.floating_view:IsOpen() then
		self.floating_view:Open()
	end
end

function TipsFloatingManager:StartFloating()
	self.is_pausing = false
end