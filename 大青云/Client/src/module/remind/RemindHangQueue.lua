--[[
挂机提醒
]]

_G.RemindHangQueue = RemindQueue:new();
--time key(30秒无操作确认面板自动关闭)
RemindHangQueue.timerKey = nil;
RemindHangQueue.isShow = true

function RemindHangQueue:GetType()
	return RemindConsts.Type_HANG;
end

--获取按钮上显示的数字
function RemindHangQueue:GetShowNum()
	return 0;
end

--是否显示
function RemindHangQueue:GetIsShow()
	return self.isShow;
end

function RemindHangQueue:GetLibraryLink()
	return "RemindHang";
end

function RemindHangQueue:GetPos()
	return 2;
end

function RemindHangQueue:GetShowIndex()
	return 4;
end

function RemindHangQueue:GetBtnWidth()
	return 60;
end

function RemindHangQueue:AddData(data)
	if data == 1 then
		self.isShow = false
		self:HideButton()
		self:StopTimer();
		UIConfirm:Close(self.confirmUID);
		return
	end

	-- self.isShow = true
	-- self:RefreshData();
	self:DoClick()
end

function RemindHangQueue:DoClick()
	self.isShow = true
	self:RefreshData();

	local confirmFunc = function()
		self.isShow = false
		self:RefreshData();
		
		AutoBattleController:ShowPfx()
		
		self:StopTimer();
	end
	local cancelFunc = function()
		self:StopTimer();
	end
	self.confirmUID = UIConfirm:Open( StrConfig["confirmName8"], confirmFunc, cancelFunc, StrConfig['confirmName9'], StrConfig['confirmName10'] );
	self:OnUIConfirmOpen();
end

function RemindHangQueue:OnUIConfirmOpen()
	self:StartTimer();
end

function RemindHangQueue:StartTimer()
	self.timerKey = TimerManager:RegisterTimer( function() self:OnTimeUp() end, TeamConsts.AutoRefuseTime, 2 );
end

--鼠标移上
function RemindHangQueue:DoRollOver()
	TipsManager:ShowBtnTips(StrConfig["remind002"]);
end

--鼠标移出处理
function RemindHangQueue:DoRollOut()
	TipsManager:Hide();
end

function RemindHangQueue:StopTimer()
	if self.timerKey then
		TimerManager:UnRegisterTimer( self.timerKey );
		self.timerKey = nil;
	end
end

--30秒未处理，自动关闭
function RemindHangQueue:OnTimeUp()
	RemindHangQueue:StopTimer();
	UIConfirm:Close(self.confirmUID)
end